//
//  SourceEditorExtension.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/18.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

let kSourceEditorClassName = "HCSourceEditorCommand"
let kAddLazyCodeIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.AddLazyCode"
let kAddLazyCodeName = "AddLazyCode"
let kInitViewIdentifier = "com.he.HCXcodeToolsExtension.HCXcodeTools.InitVIew"
let kInitViewName = "InitVIew"

class HCSourceEditorExtension: NSObject, XCSourceEditorExtension {

    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        let addLazyCodeItem : [XCSourceEditorCommandDefinitionKey: String] = [
            XCSourceEditorCommandDefinitionKey.classNameKey : kSourceEditorClassName,
            XCSourceEditorCommandDefinitionKey.identifierKey: kAddLazyCodeIdentifier,
            XCSourceEditorCommandDefinitionKey.nameKey: kAddLazyCodeName
        ]
        let initViewItem : [XCSourceEditorCommandDefinitionKey: String] = [
            XCSourceEditorCommandDefinitionKey.classNameKey : kSourceEditorClassName,
            XCSourceEditorCommandDefinitionKey.identifierKey: kInitViewIdentifier,
            XCSourceEditorCommandDefinitionKey.nameKey: kInitViewName
        ]
        
        return [addLazyCodeItem,
                initViewItem]
    }
    
}
