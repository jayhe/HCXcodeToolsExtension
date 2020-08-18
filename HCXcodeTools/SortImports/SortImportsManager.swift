//
//  SortImportsManager.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/29.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

/// 对import的头文件按照定义的规则进行排序；使得头文件的引入看的有层次感，模块清晰
class SortImportsManager : HCEditorCommondHandler {
    
    static let sharedInstance = SortImportsManager()
    var currentClassNameString: NSString?
    var showSeperateLine = true // 是否按类分组后展示一行换行
    lazy var vcArray: [NSString] = Array.init()
    lazy var viewArray: [NSString] = Array.init()
    lazy var thirdpartyArray: [NSString] = Array.init()
    lazy var otherArray: [NSString] = Array.init()
    lazy var modelArray: [NSString] = Array.init()
    lazy var categroyArray: [NSString] = Array.init()
    lazy var managerArray: [NSString] = Array.init()
    
    
    func processCodeWithInvocation(invocation: XCSourceEditorCommandInvocation) {
        // 清除数据
        self.clearData()
        // 对import的内容进行分组
        self.groupImports(with: invocation)
        // 按照顺序排序头文件
        self.sortImports(with: invocation);
    }
    
    private func groupImports(with invocation: XCSourceEditorCommandInvocation) {
        let endIndex = invocation.buffer.lines.count - 1
        let startIndex = self.firstImportLineIndex(of: invocation.buffer.lines) // 头文件导入的首行
        let classNameString = invocation.buffer.lines.fetchClassName() ?? ""
        guard startIndex < endIndex else {
            return
        }
        for index in startIndex...endIndex {
            let lineString: NSString = invocation.buffer.lines.object(at: index) as! NSString
            var contentString: NSString = lineString.mutableCopy() as! NSString
            contentString = contentString.deleteSpaceAndNewLine().lowercased as NSString
            if contentString.hasPrefix("#import") == false {
                continue
            }
            // 这里设置的import排序规则 view > manager > vc > thirdlib > models > category > other；可以按照自己项目的规范定义这个顺序
            if contentString.checkHasContainString(inStrings: [NSString.init(format: "%@.h", classNameString.lowercased as NSString)], notInStrings: ["+"]) {
                self.currentClassNameString = lineString
            } else if contentString.checkHasContainString(inStrings: self.viewSuffix() as NSArray, notInStrings: ["+"]) {
                self.viewArray.append(lineString)
            } else if contentString.checkHasContainString(inStrings: self.managerSuffix() as NSArray, notInStrings: ["+"]) {
                self.managerArray.append(lineString)
            } else if contentString.checkHasContainString(inStrings: self.vcSuffix() as NSArray, notInStrings: ["+"]) {
                self.vcArray.append(lineString)
            } else if contentString.checkHasContainString(inStrings: self.thirdpartySuffix() as NSArray, notInStrings: ["+"]) {
                self.thirdpartyArray.append(lineString)
            } else if contentString.checkHasContainString(inStrings: self.modelSuffix() as NSArray, notInStrings: ["+"]) {
                self.modelArray.append(lineString)
            } else if contentString.contains("+") {
                self.categroyArray.append(lineString)
            } else {
                self.otherArray.append(lineString)
            }
        }
    }
    
    private func sortImports(with invocation: XCSourceEditorCommandInvocation) {
        // 删除行信息
        if self.currentClassNameString != nil {
            invocation.buffer.lines.removeObject(identicalTo: self.currentClassNameString!)
        }
        let startIndex = self.firstImportLineIndex(of: invocation.buffer.lines) // 头文件导入的首行
        var importIndex = startIndex + 1
        invocation.buffer.lines.removeObjects(in: self.viewArray)
        invocation.buffer.lines.removeObjects(in: self.managerArray)
        invocation.buffer.lines.removeObjects(in: self.vcArray)
        invocation.buffer.lines.removeObjects(in: self.thirdpartyArray)
        invocation.buffer.lines.removeObjects(in: self.modelArray)
        invocation.buffer.lines.removeObjects(in: self.categroyArray)
        invocation.buffer.lines.removeObjects(in: self.otherArray)
        // 插入行信息
        if self.currentClassNameString != nil {
            let tmpArray: [NSString] = [self.currentClassNameString ?? ""]
            importIndex = self.insertLines(withArray: tmpArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.viewArray.count > 0 {
            importIndex = self.insertLines(withArray: self.viewArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.managerArray.count > 0 {
            importIndex = self.insertLines(withArray: self.managerArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.vcArray.count > 0 {
            importIndex = self.insertLines(withArray: self.vcArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.thirdpartyArray.count > 0 {
            importIndex = self.insertLines(withArray: self.thirdpartyArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.modelArray.count > 0 {
            importIndex = self.insertLines(withArray: self.modelArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.categroyArray.count > 0 {
            importIndex = self.insertLines(withArray: self.categroyArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
        if self.otherArray.count > 0 {
            importIndex = self.insertLines(withArray: self.otherArray, toArray: invocation.buffer.lines, fromIndex: importIndex)
        }
    }
    
    private func insertLines(withArray: [NSString], toArray: NSMutableArray, fromIndex: NSInteger) -> NSInteger {
        if withArray.count > 0 {
            var itemsArray = withArray
            if self.showSeperateLine {
                itemsArray.append("\n")
            }
            toArray.insertItems(itemsArray: itemsArray as NSArray, fromIndex: fromIndex)
            return fromIndex + itemsArray.count
        }
        
        return fromIndex
    }
    
    private func firstImportLineIndex(of lines: NSMutableArray) -> NSInteger {
        var commentLastIndex = NSNotFound
        for index in 0...lines.count {
            var lineString: NSString = lines.object(at: index) as! NSString
            lineString = lineString.deleteSpaceAndNewLine()
            if lineString.hasPrefix("//") || lineString.length == 0 {
                commentLastIndex = index
            } else {
                break
            }
        }
        if commentLastIndex != NSNotFound {
            return commentLastIndex + 1
        } else {
            return 0
        }
    }
    
    private func viewSuffix() -> [NSString] {
        return [
            "view.h",
            "cell.h",
            "bar.h",
            "button.h",
            "field.h",
            "label.h"
        ]
    }
    
    private func managerSuffix() -> [NSString] {
        return [
            "manager.h",
            "utils.h",
            "utility.h",
            "service.h",
            "helper.h",
            "handler.h",
            "logic.h",
            "db.h"
        ]
    }
    
    private func vcSuffix() -> [NSString] {
        return [
            "vc.h",
            "controller.h",
        ]
    }
    
    private func thirdpartySuffix() -> [NSString] {
        return [
            ".h>"
        ]
    }
    
    private func modelSuffix() -> [NSString] {
        return [
            "vm.h",
            "viewmodel.h",
            "model.h"
        ]
    }
    
    private func clearData() {
        self.currentClassNameString = nil
        self.vcArray.removeAll()
        self.viewArray.removeAll()
        self.thirdpartyArray.removeAll()
        self.otherArray.removeAll()
        self.modelArray.removeAll()
        self.categroyArray.removeAll()
        self.managerArray.removeAll()
    }
}
