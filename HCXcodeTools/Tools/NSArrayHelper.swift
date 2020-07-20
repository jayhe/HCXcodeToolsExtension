//
//  NSArrayHelper.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation

extension NSArray {
    
    func indexOfFirstItemContainString(string: String) -> NSInteger {
        /*
         str = [str deleteSpaceAndNewLine];
         NSInteger index = NSNotFound;
         for (int i = 0; i < self.count; i++) {
             NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
             NSRange range = [contentStr rangeOfString:str];
             if (range.location != NSNotFound) {
                 index = i;
                 break;
             }
         }
         return index;
         */
        let tempString = string.deleteSpaceAndNewLine() as String
        var index = NSNotFound
        var loopIndex = 0
        for item in self {
            var aString : NSString = item as! NSString
            aString = aString.deleteSpaceAndNewLine()
            let range = aString.range(of: tempString)
            if range.location != NSNotFound {
                index = loopIndex
                break
            }
            loopIndex += 1
        }
        
        return index
    }
    
    
}
