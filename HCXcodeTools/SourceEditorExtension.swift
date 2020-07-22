//
//  SourceEditorExtension.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/18.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        let addLazyCodeItem : [XCSourceEditorCommandDefinitionKey: Any] = [
            XCSourceEditorCommandDefinitionKey.classNameKey : kSourceEditorClassName,
            XCSourceEditorCommandDefinitionKey.identifierKey: kAddLazyCodeIdentifier,
            XCSourceEditorCommandDefinitionKey.nameKey: kAddLazyCodeName
        ]
        let initViewItem : [XCSourceEditorCommandDefinitionKey: Any] = [
            XCSourceEditorCommandDefinitionKey.classNameKey : kSourceEditorClassName,
            XCSourceEditorCommandDefinitionKey.identifierKey: kInitViewIdentifier,
            XCSourceEditorCommandDefinitionKey.nameKey: kInitViewName
        ]
        let addImportItem : [XCSourceEditorCommandDefinitionKey: Any] = [
            XCSourceEditorCommandDefinitionKey.classNameKey : kSourceEditorClassName,
            XCSourceEditorCommandDefinitionKey.identifierKey : kAddImportIdentifier,
            XCSourceEditorCommandDefinitionKey.nameKey : kAddImportName
        ]
        
        return [addLazyCodeItem,
                addImportItem,
                initViewItem
        ]
    }
    */
}
