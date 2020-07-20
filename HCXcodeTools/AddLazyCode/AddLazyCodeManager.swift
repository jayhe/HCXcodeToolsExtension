//
//  AddLazyCodeManager.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

class AddLazyCodeManager {
    static func sharedInstance() -> AddLazyCodeManager {
        let _instance = AddLazyCodeManager.init()
        return _instance
    }
    
    func processCodeWithInvocation(invocation : XCSourceEditorCommandInvocation) -> Void {
        
    }
}
