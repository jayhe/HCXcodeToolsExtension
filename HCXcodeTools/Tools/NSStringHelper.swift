//
//  NSStringHelper.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation

extension NSString {
    
    /// 获取leftString和rightString之间的字符串
    /// - Parameters:
    ///   - leftString: 左字符串
    ///   - rightString: 右字符串
    public func stringBetween(leftString: NSString?, rightString: NSString) -> NSString {
        var string = ""
        var array = [String]()
        if leftString == nil {
            let tempRightString = rightString as String
            let characterSet = CharacterSet(charactersIn: tempRightString)
            array = self.components(separatedBy: characterSet)
            if array.count > 0 {
                string = array[0]
            }
        } else {
            let tempLeftString = leftString! as String
            let characterSet = CharacterSet(charactersIn: tempLeftString)
            array = self.components(separatedBy: characterSet)
            if array.count > 1 {
                let subArray: [String] = array.last?.components(separatedBy: characterSet) ?? []
                if subArray.count > 0 {
                    string = subArray.first ?? ""
                    if string.contains("_") {
                        string = self.replacingOccurrences(of: "_", with: "")
                    }
                }
            }
        }
        let returnString = string as NSString
        return returnString.deleteSpaceAndNewLine()
    }
    
    /// 删除掉空格和换行
    public func deleteSpaceAndNewLine() -> NSString {
        let tempString = self as String
        var string = tempString.replacingOccurrences(of: " ", with: "")
        let characterSet = CharacterSet.whitespacesAndNewlines
        string = string.trimmingCharacters(in: characterSet)
        
        return string as NSString
    }
    
    /// 从string中提取类名
    public func fetchClassNameString() -> NSString? {
        let tempString = self.deleteSpaceAndNewLine()
        var classNameString : String? = nil
        if tempString.contains("*") {
            // 判断NSMutableArray<NSString *> *testArray 这样的情况来处理
            if tempString.contains("<") {
                classNameString = tempString.stringBetween(leftString: ")", rightString: "*>") as String
                classNameString = classNameString?.appending("*>")
            } else if tempString.contains(")") {
                classNameString = tempString.stringBetween(leftString: ")", rightString: "*") as String
            } else {
                classNameString = tempString.stringBetween(leftString: nil, rightString: "*") as String
            }
        } else {
            let tempString0 = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let characterSet = CharacterSet(charactersIn: " ")
            let itemArray = tempString0.components(separatedBy: characterSet)
            if !tempString0.hasPrefix("@property") && itemArray.count == 2 {
                classNameString = itemArray[0]
            }
        }
        let returnClassName : NSString = classNameString! as NSString
        
        return returnClassName.deleteSpaceAndNewLine()
    }
    /// 截取property line中的属性名
    public func fetchPropertyNameString() -> NSString? {
        var propertyNameString : String? = nil
        if self.contains("*") {
            let tempString = self.deleteSpaceAndNewLine()
            propertyNameString = tempString.stringBetween(leftString: "*", rightString: ";") as String
            propertyNameString = propertyNameString?.deleteSpaceAndNewLine() as String?
        } else {
            let tempString0 = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let itemArray = tempString0.components(separatedBy: " ")
            if !tempString0.hasPrefix("@property") && itemArray.count == 2 {
                propertyNameString = itemArray[1].deleteSpaceAndNewLine() as String
                let tempRange: Range? = propertyNameString?.range(of: ";")
                if let index = tempRange?.lowerBound , let string = propertyNameString {
                    //propertyNameString = string.substring(from: range.lowerBound)
                    propertyNameString = String(string[index...])
                }
            }
        }
        
        return propertyNameString as NSString?
    }
    
    /// 判断是否包含某些字符串并且不包含某些字符串
    /// - Parameters:
    ///   - inStrings: 包含的字符串数组
    ///   - notInStrings: 不包含的字符串数组
    public func checkHasContainString(inStrings: NSArray, notInStrings: NSArray) -> Bool {
        var inFlag = false, notInTag = false
        for tempString in inStrings {
            if self.contains(tempString as! String) {
                inFlag = true
            }
        }
        
        for tempString in notInStrings {
            if self.contains(tempString as! String) {
                notInTag = false
            }
        }
        
        return inFlag && notInTag
    }
}
