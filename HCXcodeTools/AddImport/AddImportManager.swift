//
//  AddImportManager.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/21.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

/// 选中某个类，快速的导入该类头文件
class AddImportManager : HCEditorCommondHandler {
    static let sharedInstance = AddImportManager()
    func processCodeWithInvocation(invocation : XCSourceEditorCommandInvocation) -> Void {
        print("add import")
        guard invocation.buffer.selections.count > 0 else {
            return
        }
        let selectRange: XCSourceTextRange = invocation.buffer.selections.firstObject as! XCSourceTextRange
        let startLine = selectRange.start.line // 选中的开始行
        let endLine = selectRange.end.line // 选中的结束行
        let startColumn = selectRange.start.column // 选中的内容开始列
        let endColumn = selectRange.end.column // 选中的内容结束列
        guard startLine == endLine && startColumn != endColumn else { // 支持单行选中，并且需要选中内容
            return
        }
        let selectedLineString: NSString = invocation.buffer.lines.object(at: startLine) as! NSString
        let selectedContentString : NSString = selectedLineString.substring(with: NSMakeRange(startColumn, endColumn - startColumn)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        guard selectedContentString.length > 0 else {
            return
        }
        // 拼接导入头文件的内容
        let insertString: NSString = NSString.init(format: "#import \"%@.h\"", selectedContentString)
        var alreadyIndex: NSInteger = 0
        alreadyIndex = invocation.buffer.lines.indexOfFirstItemContainString(string: insertString) // 获取是否已经导入过了
        if alreadyIndex != NSNotFound { // 已经导入过头文件了
            return
        }
        // 查找import的最后一行的index
        var lastImportLine = NSNotFound
        for index in 0...invocation.buffer.lines.count-1 {
            let lineString = invocation.buffer.lines[index]
            if lineString is NSString {
                var tempString: NSString = lineString as! NSString
                tempString = tempString.deleteSpaceAndNewLine()
                if tempString.contains("import") {
                    lastImportLine = index
                }
            }
        }
        // 设置插入的行号，如果buffer中已经有import过则lastImportIndex不为NSNotFound，此时插入到lastImportIndex的后一行；否则就插入在首行
        var insertLine = 0
        if lastImportLine != NSNotFound {
            insertLine = lastImportLine + 1
        }
        invocation.buffer.lines.insert(insertString, at: insertLine)
    }
}
