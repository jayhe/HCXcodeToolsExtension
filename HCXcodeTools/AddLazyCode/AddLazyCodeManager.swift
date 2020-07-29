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
            let currentClassName = invocation.buffer.lines.fetchCurrentClassName(to: startLine) // 获取当前需要插入懒加载代码片段的属性所在的类
            let impIndex = invocation.buffer.lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
            let endIndex = invocation.buffer.lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex) // 获取@end的位置
            let existIndex = invocation.buffer.lines.indexOfFirstItem(containedString: firstString as! NSString, fromIndex: impIndex, toIndex: endIndex)
            let existLazyMethod = self.checkExistLazyMethod(with: className ?? "", propertyName: propertyName ?? "", lines: invocation.buffer.lines, startLine: startLine)
            if existIndex == NSNotFound && existLazyMethod == false { // 如果没有写过懒加载代码就插入
                // 待插入的懒加载代码
                self.lazyCodeArray.add(lazyCodeArray as! [Any])
                // 待插入的delegate方法
                let delegateCodeArray = self.fetchDelegateContents(className: className!, fromSelectIndex: startLine, lines: invocation.buffer.lines)
                if delegateCodeArray != nil {
                    self.delegateCodeArray.add(delegateCodeArray as! [Any])
                }
            }
            // 添加代理的声明代码
            self.addDelegateDeclareCode(with: className!, lines: invocation.buffer.lines, selectStartLine: startLine)
        }
        // 添加delegate方法
        self.addDelegateMethodList(with: invocation.buffer.lines, selectStartLine: startLine)
        // 添加懒加载代码
        self.addLazyCode(with: invocation.buffer.lines, selectStartLine: startLine)
    }
    
    private func addDelegateDeclareCode(with className: NSString, lines: NSMutableArray, selectStartLine: NSInteger) {
        let delegateDeclareString = self.fetchDelegateDeclareString(with: className)
        guard delegateDeclareString != nil else {
            return
        }
        for lineIndex in (0...selectStartLine).reversed() {
            let lineText: NSString = lines.object(at: lineIndex) as! NSString
            if lineText.contains(kInterface) {
                var checkText: String
                if delegateDeclareString?.contains(",") != false {
                    let delegates = delegateDeclareString?.components(separatedBy: ",")
                    checkText = delegates?.first?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
                } else {
                    checkText = delegateDeclareString! as String
                }
                if lineText.contains(checkText) != false { // 判断是否加入了delegate其中的一个；这里可以优化为多个代理的判断，筛选出没加的加入
                    break
                }
                // 插入代码操作
                if lineText.contains("<") != false && lineText.contains(">") != false {
                    let range: NSRange = lineText.range(of: "<")
                    let prefixText = lineText.substring(to: range.location)
                    let suffixText = lineText.substring(from: range.location + 1)
                    let codeString: NSString = NSString.init(format: "%@<%@, %@", prefixText as NSString, delegateDeclareString!, suffixText as NSString)
                    lines.replaceObject(at: lineIndex, with: codeString)
                } else {
                    let codeString: NSString = NSString.init(format: "%@ <%@>", lineText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), delegateDeclareString!)
                    lines.replaceObject(at: lineIndex, with: codeString)
                }
                break
            }
        }
    }
    
    private func addDelegateMethodList(with lines: NSMutableArray, selectStartLine: NSInteger) {
        let currentClassName = lines.fetchCurrentClassName(to: selectStartLine) // 获取当前需要插入懒加载代码片段的属性所在的类
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
        let endIndex = lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex) // 获取@end的位置
        var insertIndex = lines.indexOfFirstItem(containedString: kGetterSetterPragmaMark as NSString, fromIndex: impIndex, toIndex: endIndex)
        if insertIndex != NSNotFound {
            insertIndex = insertIndex - 1 // 在getter setter前面插入
        } else {
            insertIndex = endIndex
        }
        for item in self.delegateCodeArray {
            guard let codeArray: NSArray = item as? NSArray else {
                continue
            }
            lines.insertItems(itemsArray: codeArray, fromIndex: insertIndex)
            insertIndex = insertIndex + codeArray.count
        }
    }
    
    private func addLazyCode(with lines: NSMutableArray, selectStartLine: NSInteger) {
        let currentClassName = lines.fetchCurrentClassName(to: selectStartLine) // 获取当前需要插入懒加载代码片段的属性所在的类
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
        let endIndex = lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex) // 获取@end的位置
        var insertIndex = lines.indexOfFirstItem(containedString: kGetterSetterPragmaMark as NSString, fromIndex: impIndex, toIndex: endIndex)
        if insertIndex != NSNotFound {
            insertIndex = insertIndex + 1 // 在getter setter后面插入
        } else {
            insertIndex = endIndex
        }
        for item in self.lazyCodeArray {
            guard let codeArray: NSArray = item as? NSArray else {
                continue
            }
            lines.insertItems(itemsArray: codeArray, fromIndex: insertIndex)
            insertIndex = insertIndex + codeArray.count
        }
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
    func fetchDelegateContents(className: NSString, fromSelectIndex: NSInteger, lines: NSMutableArray) -> NSArray?
    func checkExistLazyMethod(with className: NSString, propertyName: NSString, lines: NSMutableArray, startLine: NSInteger) -> Bool
    func fetchDelegateDeclareString(with className: NSString) -> NSString?
}

extension AddLazyCodeManager : AddLazyCodeHelper {
    
    func fetchGetterContents(className: NSString, propertyName: NSString) -> NSArray? {
        guard className.length > 0 && propertyName.length > 0 else {
            return nil
        }
        var contentString: NSString
        let classNameString = className as String
        switch classNameString {
        case kUIButton:
            contentString = NSString.init(format: kLazyButtonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kUIView:
            contentString = NSString.init(format: kLazyUIViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName)
            break
        case kUILabel:
            contentString = NSString.init(format: kLazyLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kYYLabel:
            contentString = NSString.init(format: kLazyYYLabelCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kUIScrollView:
            contentString = NSString.init(format: kLazyScrollViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
            break
        case kUITableView:
            contentString = NSString.init(format: kLazyUITableViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kUICollectionView:
            contentString = NSString.init(format: kLazyUICollectionViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName)
            break
        case kUITextField:
            contentString = NSString.init(format: kLazyUITextFieldCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kUITextView:
            contentString = NSString.init(format: kLazyUITextViewCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName)
            break
        case kUIImageView:
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
    
    func fetchDelegateContents(className: NSString, fromSelectIndex: NSInteger, lines: NSMutableArray) -> NSArray? {
        guard className.length > 0 && fromSelectIndex < lines.count else {
            return nil
        }
        let currentClassName = lines.fetchCurrentClassName(to: fromSelectIndex)
        guard currentClassName != nil else {
            return nil
        }
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!))
        let endIndex = lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex)
        var delegateCodeArray: NSArray?
        var delegateCodeString: String?
        var checkNeedInsertString: String?
        switch className as String {
        case kUITableView:
            delegateCodeString = kAddLazyCodeTableViewDataSourceAndDelegate
            checkNeedInsertString = "- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section"
            break
        case kUICollectionView:
            delegateCodeString = kAddLazyCodeUICollectionViewDelegate
            checkNeedInsertString = "- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section"
            break
        case kUIScrollView:
            delegateCodeString = kAddLazyCodeUIScrollViewDelegate
            checkNeedInsertString = "- (void)scrollViewDidScroll:(UIScrollView *)scrollView"
            break
        default:
            break
        }
        guard (delegateCodeString != nil) && (checkNeedInsertString != nil) else {
            return nil
        }
        let needInsert = lines.indexOfFirstItem(containedString: checkNeedInsertString! as NSString, fromIndex: impIndex, toIndex: endIndex) == NSNotFound
        if needInsert {
            var tempArray: [String] = (delegateCodeString?.components(separatedBy: "\n"))!
            tempArray.append("")
            delegateCodeArray = tempArray as NSArray
        }
        
        return delegateCodeArray
    }
    
    func checkExistLazyMethod(with className: NSString, propertyName: NSString, lines: NSMutableArray, startLine: NSInteger) -> Bool {
        var existLazyMethod = false
        let lazyFirstLine = NSString.init(format: "-(%@*)%@", className, propertyName)
        let currentClassName = lines.fetchCurrentClassName(to: startLine)
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: kImplementation as NSString, currentClassName!))
        let endIndex = lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex)
        guard impIndex != NSNotFound && endIndex != NSNotFound else {
            return true
        }
        for lineIndex in impIndex...endIndex {
            var lineText: NSString = lines.object(at: lineIndex) as! NSString
            lineText = lineText.deleteSpaceAndNewLine()
            if lineText.contains(lazyFirstLine as String) {
                existLazyMethod = true
                break
            }
        }
        
        return existLazyMethod
    }
    
    func fetchDelegateDeclareString(with className: NSString) -> NSString? {
        var delegateDeclareString: String?
        switch className as String {
        case kUITableView:
            delegateDeclareString = "UITableViewDelegate, UITableViewDataSource"
            break
        case kUICollectionView:
            delegateDeclareString = "UICollectionViewDelegate, UICollectionViewDataSource"
            break
        case kUIScrollView:
            delegateDeclareString = "UIScrollViewDelegate"
            break
        default:
            break
        }
        
        return delegateDeclareString as NSString?
    }
    
}

/*
@objc protocol AddLazyCodeLogic {
    @objc optional func someLogic() -> Void
}

extension AddLazyCodeManager : AddLazyCodeLogic {
    
}
*/
