//
//  InitViewManager.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

enum HCInitViewType {
    case Undefined
    case Common
    case TableViewCell
    case TableHeaderFooterView
    case ViewController
}

/// 给VC或者常用的view添加生命周期的代码块
class InitViewManager : HCEditorCommondHandler {
    static let sharedInstance = InitViewManager()
    lazy var indexSet: NSMutableIndexSet = NSMutableIndexSet()
    
    func processCodeWithInvocation(invocation : XCSourceEditorCommandInvocation) -> Void {
        self.indexSet.removeAllIndexes()
        /* 添加extension代码 */
        // 获取本文件的类
        let className: NSString? = invocation.buffer.lines.fetchClassName()
        guard className != nil else {
            return
        }
        let interfaceString: NSString = NSString.init(format: "@interface %@ ()", className!)
        if invocation.buffer.lines.indexOfFirstItemContainString(string: interfaceString) != NSNotFound { // 判断是否有写extension的代码
            // 默认的extension代码
            let extensionString: NSString = NSString.init(format: kInitViewExtensionCode as NSString, className!)
            let extensionContents = extensionString.components(separatedBy: "\n")
            // 查找插入的位置
            let insertIndex = invocation.buffer.lines.indexOfFirstItemContainString(string: kImplementation as NSString)
            // 将extension的代码插入到implementation的前面
            invocation.buffer.lines.insertItems(itemsArray: extensionContents as NSArray, fromIndex: insertIndex)
        }
        /* 根据类的类型来添加对应的UI初始化代码 */
        let viewType = self.getInitViewType(className: className ?? "")
        guard viewType != HCInitViewType.Undefined else {
            return
        }
        let needInsert = self.checkNeedInsert(viewType: viewType, lines: invocation.buffer.lines)
        guard needInsert else {
            return
        }
        var insertCode: NSString?
        switch viewType {
        case .Common:
            insertCode = kInitViewLifeCycleCode as NSString
            break
        case .TableHeaderFooterView:
            insertCode = kInitTableViewHeaderFooterViewLifeCycleCode as NSString
            break
        case .TableViewCell:
            insertCode = kInitTableViewCellLifeCycleCode as NSString
            break
        case .ViewController:
            insertCode = kInitViewControllerLifeCycleCode as NSString
            break
        default:
            insertCode = nil
            break
        }
        guard insertCode != nil else {
            return
        }
        // 删除掉@implementation和@end之间的代码
        self.deleteImplementationCode(with: invocation.buffer.lines)
        let insertIndex = invocation.buffer.lines.indexOfFirstItemContainString(string: kImplementation as NSString)
        guard insertIndex != NSNotFound else {
            return
        }
        // 插入自定义的代码片段
        let insertCodeArray = insertCode?.components(separatedBy: "\n")
        invocation.buffer.lines.insertItems(itemsArray: insertCodeArray! as NSArray, fromIndex: insertIndex + 1)
    }
    
    // MARK: 工具函数
    private func deleteImplementationCode(with lines: NSMutableArray) -> Void {
        let impIndex = lines.indexOfFirstItemContainString(string: kImplementation as NSString)
        guard impIndex != NSNotFound else {
            return
        }
        let endIndex = lines.indexOfFirstItem(containedString: kEnd as NSString, fromIndex: impIndex)
        guard endIndex != NSNotFound else {
            return
        }
        for index in (impIndex+1)...(endIndex-1) { // 遍历开始行和结束行之前的行信息，如果剔除空格或者换行内容不为空，则将该行号暂存起来
            let content = lines.object(at: index)
            guard content is NSString else {
                continue
            }
            var contentString: NSString = content as! NSString
            contentString = contentString.deleteSpaceAndNewLine()
            if contentString.length > 0 {
                self.indexSet.add(index)
            }
        }
        if self.indexSet.count > 0 {
            lines.removeObjects(at: self.indexSet as IndexSet)
        }
    }
    private func getInitViewType(className: NSString) -> HCInitViewType {
        var viewType = HCInitViewType.Undefined
        if self.checkIsCommonViewClass(className: className) {
            viewType = HCInitViewType.Common
        }else if self.checkIsControllerClass(className: className) {
            viewType = HCInitViewType.ViewController
        } else if self.checkIsTableCellClass(className: className) {
            viewType = HCInitViewType.TableViewCell
        } else if self.checkIsTableHeaderFooterlClass(className: className) {
            viewType = HCInitViewType.TableHeaderFooterView
        }
        
        return viewType
    }
    private func checkNeedInsert(viewType: HCInitViewType, lines: NSMutableArray) -> Bool {
        var needInsert = false
        var checkCode : NSString?
        switch viewType {
        case .Common:
            checkCode = NSString.init(string: "(instancetype)initWithFrame")
            break
        case .TableHeaderFooterView:
            checkCode = NSString.init(string: "(instancetype)initWithReuseIdentifier:")
            break
        case .TableViewCell:
            checkCode = NSString.init(string: "instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier")
            break
        case .ViewController:
            checkCode = NSString.init(string: kGetterSetterPragmaMark)
            break
        default:
            break
        }
        if checkCode?.length ?? 0 > 0 {
            needInsert = lines.indexOfFirstItemContainString(string: checkCode ?? "") != NSNotFound
        } else {
            needInsert = false
        }
        
        return needInsert
    }
    private func checkIsCommonViewClass(className: NSString) -> Bool {
        guard className.length > 0 else {
            return false
        }
        var flag = false
        let lowercasedClassName = className.lowercased
        if lowercasedClassName.hasSuffix("view")
        || lowercasedClassName.hasSuffix("bar")
        || lowercasedClassName.hasSuffix("collectioncell")
        || lowercasedClassName.hasSuffix("collectionviewcell") {
            flag = true
        }
        
        return flag
    }
    
    private func checkIsControllerClass(className: NSString) -> Bool {
        guard className.length > 0 else {
            return false
        }
        var flag = false
        let lowercasedClassName = className.lowercased
        if lowercasedClassName.hasSuffix("controller")
        || lowercasedClassName.hasSuffix("vc") {
            flag = true
        }
        
        return flag
    }
    
    private func checkIsTableCellClass(className: NSString) -> Bool {
        guard className.length > 0 else {
            return false
        }
        var flag = false
        let lowercasedClassName = className.lowercased
        if lowercasedClassName.hasSuffix("tablecell")
        || lowercasedClassName.hasSuffix("tableviewcell") {
            flag = true
        }
        
        return flag
    }
    
    private func checkIsTableHeaderFooterlClass(className: NSString) -> Bool {
        guard className.length > 0 else {
            return false
        }
        var flag = false
        let lowercasedClassName = className.lowercased
        if lowercasedClassName.hasSuffix("headerview")
        || lowercasedClassName.hasSuffix("footerview") {
            flag = true
        }
        
        return flag
    }
}
