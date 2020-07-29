//
//  SourceEditorCommand.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/18.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        let identifier = invocation.commandIdentifier
        print(identifier)
        if identifier == kAddLazyCodeIdentifier {
            AddLazyCodeManager.sharedInstance.processCodeWithInvocation(invocation: invocation)
        } else if identifier == kInitViewIdentifier {
            InitViewManager.sharedInstance.processCodeWithInvocation(invocation: invocation)
        } else if identifier == kAddImportIdentifier {
            AddImportManager.sharedInstance.processCodeWithInvocation(invocation: invocation)
        } else if identifier == kSortImportsIdentifier {
            SortImportsManager.sharedInstance.processCodeWithInvocation(invocation: invocation)
        }
        completionHandler(nil)
    }
    
}
