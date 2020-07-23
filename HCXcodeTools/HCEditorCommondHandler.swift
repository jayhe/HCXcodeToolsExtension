//
//  HCEditorCommondHandler.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/23.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation
import XcodeKit

protocol HCEditorCommondHandler {
    func processCodeWithInvocation(invocation : XCSourceEditorCommandInvocation) -> Void
}
