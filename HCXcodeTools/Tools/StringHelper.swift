//
//  StringHelper.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/18.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation

extension String {
    
    /// 获取leftString和rightString之间的字符串
    /// - Parameters:
    ///   - leftString: 左字符串
    ///   - rightString: 右字符串
    func stringBetween(leftString:String?, rightString:String) -> String {
        var string = ""
        var array = [String]()
        if leftString == nil {
            let characterSet = CharacterSet(charactersIn: rightString)
            array = self.components(separatedBy: characterSet)
            if array.count > 0 {
                string = array[0]
            }
        } else {
            let characterSet = CharacterSet(charactersIn: leftString)
            array = self.components(separatedBy: characterSet)
            if array.count > 1 {
                let subArray : [String] = array.last?.components(separatedBy: characterSet) ?? []
                if subArray.count > 0 {
                    string = subArray.first ?? ""
                    if string.contains("_") {
                        string = self.replacingOccurrences(of: "_", with: "")
                    }
                }
            }
        }
        
        return string.deleteSpaceAndNewLine()
    }
    
    /// 删除掉空格和换行
    func deleteSpaceAndNewLine() -> String {
        var string = self.replacingOccurrences(of: " ", with: "")
        let characterSet = CharacterSet.whitespacesAndNewlines
        string = string.trimmingCharacters(in: characterSet)
        
        return string
    }
    
    /// 从string中提取类名
    func fetchClassNameString() -> String? {
        let tempString = self.deleteSpaceAndNewLine()
        var classNameString : String? = nil
        if tempString.contains("*") {
            // 判断NSMutableArray<NSString *> *testArray 这样的情况来处理
            if tempString.contains("<") {
                classNameString = tempString.stringBetween(leftString: ")", rightString: "*>")
                classNameString = classNameString?.appending("*>")
            } else if tempString.contains(")") {
                classNameString = tempString.stringBetween(leftString: ")", rightString: "*")
            } else {
                classNameString = tempString.stringBetween(leftString: nil, rightString: "*")
            }
        } else {
            let tempString0 = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let characterSet = CharacterSet(charactersIn: " ")
            let itemArray = tempString0.components(separatedBy: characterSet)
            if !tempString0.hasPrefix("@property") && itemArray.count == 2 {
                classNameString = itemArray[0]
            }
        }
        
        return classNameString?.deleteSpaceAndNewLine()
    }
    
    func fetchPropertyNameString() -> String? {
        /*
         - (NSString *)fetchPropertyNameStr {
             NSString *propertyNameStr = nil;

             if ([self containsString:@"*"]) {
                 NSString *tempStr = [self deleteSpaceAndNewLine];
                 NSString *propertyNameStr = [tempStr stringBetweenLeftStr:@"*" andRightStr:@";"];
                 return [propertyNameStr deleteSpaceAndNewLine];
             } else {
                 NSString *tempStr0 = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                 NSArray *itemArray = [tempStr0 componentsSeparatedByString:@" "];
                 if (![tempStr0 hasPrefix:@"@property"] && [itemArray count] == 2) {
                     propertyNameStr = [itemArray[1] deleteSpaceAndNewLine];
                     NSRange tempRange = [propertyNameStr rangeOfString:@";"];
                     if (tempRange.location != NSNotFound) {
                         propertyNameStr = [propertyNameStr substringToIndex:tempRange.location];
                     }
                     return propertyNameStr;
                 }
             }
             return propertyNameStr;
         }
         */
        var propertyNameString : String? = nil
        if self.contains("*") {
            let tempString = self.deleteSpaceAndNewLine()
            propertyNameString = tempString.stringBetween(leftString: "*", rightString: ";")
            propertyNameString = propertyNameString?.deleteSpaceAndNewLine()
        } else {
            let tempString0 = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let itemArray = tempString0.components(separatedBy: " ")
            if !tempString0.hasPrefix("@property") && itemArray.count == 2 {
                propertyNameString = itemArray[1].deleteSpaceAndNewLine()
                let tempRange : Range? = propertyNameString?.range(of: ";")
                if let index = tempRange?.lowerBound , let string = propertyNameString {
                    //propertyNameString = string.substring(from: range.lowerBound)
                    propertyNameString = String(string[index...])
                }
            }
        }
        
        return propertyNameString
    }
    
    func checkHasContainString(inStrings: Array<String>, notInStrings: Array<String>) -> Bool {
        /*
         BOOL tag0Success = NO;
         BOOL tag1Success = YES;
         for (NSString *tempStr in strArray) {
             if ([self containsString:tempStr]) {
                 tag0Success = YES;
             }
         }
         for (NSString *tempStr in noHasStrsArray) {
             if ([self containsString:tempStr]) {
                 tag1Success = NO;
             }
         }
         return tag0Success && tag1Success;
         */
        var inFlag = false, notInTag = false
        for tempString in inStrings {
            if self.contains(tempString) {
                inFlag = true
            }
        }
        
        for tempString in notInStrings {
            if self.contains(tempString) {
                notInTag = false
            }
        }
        
        return inFlag && notInTag
    }
}
