//
//  AddLazyCodeManager.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

class AddLazyCodeManager : HCEditorCommondHandler {
    static let sharedInstance = AddLazyCodeManager()
    lazy var lazyCodeArray: NSMutableArray = NSMutableArray.init()
    lazy var delegateCodeArray: NSMutableArray = NSMutableArray.init()
    
    func processCodeWithInvocation(invocation: XCSourceEditorCommandInvocation) -> Void {
        for item in invocation.buffer.selections { // 遍历每一行选中的去添加lazy code
            self.addLazyCode(textRange: item as! XCSourceTextRange, invocation: invocation)
        }
    }
    
    private func addLazyCode(textRange: XCSourceTextRange, invocation: XCSourceEditorCommandInvocation) {
        self.clearData()
        let startLine = textRange.start.line
        let endLine = textRange.end.line
        for lineIndex in startLine...endLine {
            var lineText: NSString = invocation.buffer.lines.object(at: lineIndex) as! NSString
            lineText = lineText.deleteSpaceAndNewLine()
            if lineText.length <= 0 {
                continue
            }
            let className = lineText.fetchClassNameString()
            let propertyName = lineText.fetchPropertyNameString()
            let shouldAdd = lineText.contains("*")
            guard className != nil && propertyName != nil && shouldAdd else { // 不是oc对象或者选中的行没有类名和属性名
                continue
            }
            // 格式化代码
            let formattedLineContent = self.formattedLineContent(by: lineText, className: className ?? "", propertyName: propertyName ?? "")
            invocation.buffer.lines.replaceObject(at: lineIndex, with: formattedLineContent)
            // 根据类名及属性名获取懒加载代码片段转化成的数组
            let lazyCodeArray: NSArray? = self.fetchGetterContents(className: className ?? "", propertyName: propertyName ?? "")
            guard lazyCodeArray != nil && lazyCodeArray!.count > 1 else {
                return
            }
            var firstString = lazyCodeArray?.object(at: 1)
            lazyCodeArray?.enumerateObjects({ (lazyCode, index, stop) in
                var lazyCodeString: NSString = lazyCode as! NSString
                lazyCodeString = lazyCodeString.deleteSpaceAndNewLine()
                if lazyCodeString.contains("-") {
                    firstString = lazyCodeString
                }
            })
            let currentClassName = invocation.buffer.lines.fetchCurrentClassName(with: startLine) // 获取当前需要插入懒加载代码片段的属性所在的类
            let impIndex = invocation.buffer.lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
            let endIndex = invocation.buffer.lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex) // 获取@end的位置
            let existIndex = invocation.buffer.lines.indexOfFirstItem(containedString: firstString as! NSString, fromIndex: impIndex, toIndex: endIndex)
            let existLazyMethod = self.checkExistLazyMethod(with: className ?? "", propertyName: propertyName ?? "", invocation: invocation, startLine: startLine)
            if existIndex != NSNotFound && existLazyMethod == false {
                self.lazyCodeArray.addObjects(from: lazyCodeArray as! [Any])
            }
        }
    }
    
    private func checkExistLazyMethod(with className: NSString, propertyName: NSString, invocation: XCSourceEditorCommandInvocation, startLine: NSInteger) -> Bool {
        var existLazyMethod = false
        let lazyFirstLine = NSString.init(format: "-(%@*)%@", className, propertyName)
        let currentClassName = invocation.buffer.lines.fetchCurrentClassName(with: startLine)
        let impIndex = invocation.buffer.lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!))
        let endIndex = invocation.buffer.lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex)
        for lineIndex in impIndex...endIndex {
            var lineText: NSString = invocation.buffer.lines.object(at: lineIndex) as! NSString
            lineText = lineText.deleteSpaceAndNewLine()
            if lineText.contains(lazyFirstLine as String) {
                existLazyMethod = true
                break
            }
        }
        
        return existLazyMethod
    }
    
    private func clearData() {
        self.lazyCodeArray.removeAllObjects()
        self.delegateCodeArray.removeAllObjects()
    }
    
    private func formattedLineContent(by originContent: NSString, className: NSString, propertyName: NSString) -> NSString {
        guard originContent.length > 0 && className.length > 0 && propertyName.length > 0 else {
            return ""
        }
        var formattedLineContent: NSString
        if originContent.contains("*") {
            formattedLineContent = NSString.init(format: "@property (nonatomic, strong) %@ *%@;", className, propertyName)
        } else {
            formattedLineContent = NSString.init(format: "@property (nonatomic, assign) %@ %@;", className, propertyName)
        }
        
        return formattedLineContent
    }
}

protocol AddLazyCodeHelper {
    func fetchGetterContents(className: NSString, propertyName: NSString) -> NSArray?
}

extension AddLazyCodeManager : AddLazyCodeHelper {
    
    func fetchGetterContents(className: NSString, propertyName: NSString) -> NSArray? {
        guard className.length > 0 && propertyName.length > 0 else {
            return nil
        }
        var contentString: NSString
        let classNameString = className as String
        switch classNameString {
        case "UIButton":
            contentString = NSString.init(format: kLazyButtonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "UIView":
            contentString = NSString.init(format: kLazyUIViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName)
            break
        case "UILabel":
            contentString = NSString.init(format: kLazyLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "YYLabel":
            contentString = NSString.init(format: kLazyYYLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "UIScrollView":
            contentString = NSString.init(format: kLazyScrollViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
            break
        case "UITableView":
            contentString = NSString.init(format: kLazyUITableViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "UICollectionView":
            contentString = NSString.init(format: kLazyUICollectionViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
            break
        case "UITextField":
            contentString = NSString.init(format: kLazyUITextFieldCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "UITextView":
            contentString = NSString.init(format: kLazyUITextViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case "UIImageView":
            contentString = NSString.init(format: kLazyImageViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName)
            break
        default:
            contentString = NSString.init(format: kLazyCommonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName)
            break
        }
        /*
        if className.contains(kUIButton) {
            contentString = NSString.init(format: kLazyButtonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUIView) {
            contentString = NSString.init(format: kLazyUIViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName)
        } else if className.contains(kUILabel) {
            contentString = NSString.init(format: kLazyLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kYYLabel) {
            contentString = NSString.init(format: kLazyYYLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUIScrollView) {
            contentString = NSString.init(format: kLazyScrollViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUITableView) {
            contentString = NSString.init(format: kLazyUITableViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUICollectionView) {
            contentString = NSString.init(format: kLazyUICollectionViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUIImageView) {
            contentString = NSString.init(format: kLazyImageViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName)
        } else if className.contains(kUITextField) {
            contentString = NSString.init(format: kLazyUITextFieldCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else if className.contains(kUITextView) {
            contentString = NSString.init(format: kLazyUITextViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
        } else {
            contentString = NSString.init(format: kLazyCommonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName)
        }
         */
        var contents = contentString.components(separatedBy: "\n")
        contents.append("")
        
        return contents as NSArray
    }
    
}

/*
@objc protocol AddLazyCodeLogic {
    @objc optional func someLogic() -> Void
}

extension AddLazyCodeManager : AddLazyCodeLogic {
    
}
*/
