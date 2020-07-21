//
//  NSArrayHelper.swift
//  HCXcodeTools
//
//  Created by 贺超 on 2020/7/20.
//  Copyright © 2020 贺超. All rights reserved.
//

import Foundation

extension NSMutableArray {
    
    func indexOfFirstItemContainString(string: NSString) -> NSInteger {
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
            if item is NSString {
                var aString: NSString = item as! NSString
                aString = aString.deleteSpaceAndNewLine()
                let range = aString.range(of: tempString)
                if range.location != NSNotFound {
                    index = loopIndex
                    break
                }
            }
            loopIndex += 1
        }
        
        return index
    }
    
    func indexOfFirstItemContainStringsArray(strings : NSArray) -> NSInteger {
        /*
         NSInteger index = NSNotFound;
         for (int i = 0; i < self.count; i++) {
             NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
             BOOL isOk = YES;
             for (int j = 0; j < [strsArray count]; j++) {
                 NSString *tempStr = strsArray[j];
                 if (![contentStr containsString:tempStr]) {
                     isOk = NO;
                 }
             }

             if (isOk) {
                 index = i;
                 break;
             }
             
         }
         return index;
         */
        var index = NSNotFound
        var i = 0
        for item in self {
            var isMatch = true
            if item is NSString {
                var aString: NSString = item as! NSString
                aString = aString.deleteSpaceAndNewLine()
                for innerItem in strings {
                    guard let bString: NSString = innerItem as? NSString else {
                        continue
                    }
                    if !aString.contains(bString as String) {
                        isMatch = false
                        break
                    }
                }
            }
            if isMatch {
                index = i
                break
            }
            i += 1
        }
        
        return index
    }
    
    func indexOfFirstItem(containedString: NSString, fromIndex : NSInteger) -> NSInteger {
        /*
         str = [str deleteSpaceAndNewLine];
         NSInteger index = NSNotFound;
         for (NSInteger i = fromIndex; i < self.count; i++) {
             NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
             NSRange range = [contentStr rangeOfString:str];
             if (range.location != NSNotFound) {
                 index = i;
                 break;
             }
         }
         return index;
         */
        return self.indexOfFirstItem(containedString: containedString, fromIndex: fromIndex, toIndex: self.count)
    }
    
    func indexOfFirstItem(containedString: NSString, fromIndex: NSInteger, toIndex: NSInteger) -> NSInteger {
        var index = NSNotFound
        guard fromIndex <= self.count && toIndex <= self.count && containedString.length > 0 else {
            return index
        }

        for itemIndex in (fromIndex...toIndex) {
            guard var contentString = self.object(at: itemIndex) as? NSString else {
                continue
            }
            contentString = contentString.deleteSpaceAndNewLine()
            let range = contentString.range(of: containedString as String)
            if range.location != NSNotFound {
                index = itemIndex
                break
            }
        }
        
        return index
    }
    
    func insertItems(itemsArray: NSArray, fromIndex: NSInteger) -> Void {
        guard itemsArray.count > 0 && fromIndex <= self.count else {
            return
        }
        var insertIndex = fromIndex
        for item in itemsArray {
            guard let insertString: NSString = item as? NSString else {
                continue
            }
            self.insert(insertString, at: insertIndex)
            insertIndex += 1
        }
    }
    
    func fetchReferenceClassName() -> NSString? {
        /*
         NSString *className = nil;
         NSRange range;
         NSString *str0 = [self[1] deleteSpaceAndNewLine]; // 例如：//  NSMutableArray+GHWExtension.m ===> //NSMutableArray+GHWExtension.m
         if ([str0 hasPrefix:@"//"] && [str0 hasSuffix:@".m"]) {
             if ([str0 containsString:@"+"]) {
                 range = [str0 rangeOfString:@"+"]; // 如果是分类则取+号前面的部分
             } else {
                 range = [str0 rangeOfString:@"."]; // 否则取.号前面的部分
             }
             className = [str0 substringWithRange:NSMakeRange(2, range.location - 2)]; // 剔除//就是类名
         }
         return className;
         */
        var className: NSString? = nil
        guard self.count >= 1 else {
            return className
        }
        var classNameComment = self[1] as! NSString
        var range: NSRange? = nil
        
        classNameComment = classNameComment.deleteSpaceAndNewLine()
        if classNameComment.hasPrefix("//") && classNameComment.hasSuffix(".m") {
            if classNameComment.contains("+") {
                range = classNameComment.range(of: "+") // 如果是分类则取+号前面的部分
            } else {
                range = classNameComment.range(of: ".") // 否则取.号前面的部分
            }
            guard range?.location != NSNotFound else {
                return className
            }
            className = classNameComment.substring(with: NSMakeRange(2, range!.location - 2)) as NSString // 剔除//就是类名
        }
        
        return className
    }
    /// 本文件类名
    /// @discussion 这里主要是处理当一个文件中写了多个类的声明或者类的实现的场景；通过批对跟类文件注释中的类名来确定该文件的类名
    func fetchClassName() -> NSString? {
        /*
         NSString *referenceClassName = [self fetchReferenceClassName];
         NSString *className = @"";
         for (int i = 0; i < [self count]; i++) {
             NSString *tempStr = [self[i] deleteSpaceAndNewLine];
             if ([tempStr hasPrefix:kImplementation]) {
                 if ([tempStr containsString:@"("]) {
                     className = [tempStr stringBetweenLeftStr:kImplementation andRightStr:@"("];
                 } else {
                     className = [tempStr substringFromIndex:[kImplementation length]];
                 }
             } else if ([tempStr hasPrefix:kInterface]) {
                 if ([tempStr containsString:@":"]) {
                     className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@":"];

                 } else if ([tempStr containsString:@"("]) {
                     className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@"("];

                 }
             }
             if (referenceClassName && [referenceClassName isEqualToString:className]) {
                 return referenceClassName;
             }
         }
         return className;
         */
        let referenceClassname: NSString? = self.fetchReferenceClassName()
        var className: NSString = ""
        for item in self {
            guard let tempString: NSString = item as? NSString else {
                continue
            }
            if tempString.hasPrefix(kImplementation) {
                let implementationString: NSString = kImplementation as NSString
                if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: implementationString, rightString: "(")
                } else {
                    className = tempString.substring(from: implementationString.length) as NSString
                }
            } else if tempString.hasPrefix(kInterface) {
                if tempString.contains(":") {
                    className = tempString.stringBetween(leftString: kInterface as NSString, rightString: ":")
                } else if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: kInterface as NSString, rightString: "(")
                }
            }
            if (referenceClassname != nil) && referenceClassname?.isEqual(to: className) == true {
                return referenceClassname
            }
        }
        
        return className
    }
    
    func fetchCurrentClassName(with currentLineIndex: NSInteger) -> NSString? {
        /*
         NSString *className = nil;
         for (NSInteger i = currentIndex; i >= 0; i--) {
             NSString *tempStr = [self[i] deleteSpaceAndNewLine];
             if ([tempStr hasPrefix:kImplementation]) {
                 if ([tempStr containsString:@"("]) {
                     className = [tempStr stringBetweenLeftStr:kImplementation andRightStr:@"("];
                 } else {
                     className = [tempStr substringFromIndex:[kImplementation length]];
                 }
                 break;
             } else if ([tempStr hasPrefix:kInterface]) {
                 if ([tempStr containsString:@":"]) {
                     className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@":"];
                     
                 } else if ([tempStr containsString:@"("]) {
                     className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@"("];
                     
                 }
                 break;
             }
         }
         return className;
         */
        var className: NSString? = nil
        guard currentLineIndex <= self.count else {
            return className
        }
        for index in (0...currentLineIndex).reversed() {
            guard var tempString: NSString = self.object(at: index) as? NSString else {
                continue
            }
            tempString = tempString.deleteSpaceAndNewLine()
            if tempString.hasPrefix(kImplementation) {
                let implementationString = kImplementation as NSString
                if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: implementationString, rightString: "(")
                } else {
                    className = tempString.substring(from: implementationString.length) as NSString
                }
                break
            } else if tempString.hasPrefix(kInterface) {
                let interfaceString = kInterface as NSString
                if tempString.contains(":") {
                    className = tempString.stringBetween(leftString: interfaceString, rightString: ":")
                } else if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: interfaceString, rightString: "(")
                }
                break
            }
        }
        
        return className
    }
    
    func deleteItems(fromFirstItemContains: NSString, toLastItemContains: NSString) -> Void {
        /*
         NSInteger deleteFirstLine = 0;
         NSInteger deleteLastLine = 0;
         for (int i = 0; i < [self count]; i++) {
             NSString *tempStr = self[i];
             tempStr = [tempStr deleteSpaceAndNewLine];
             if ([tempStr hasPrefix:@"/*"]) {
                 deleteFirstLine = i;
             } else if ([tempStr hasPrefix:@"*/"]) {
                 deleteLastLine = i;
             }
         }
         if (deleteLastLine != deleteFirstLine) {
             [self removeObjectsInRange:NSMakeRange(deleteFirstLine, deleteLastLine - deleteFirstLine + 1)];
         }
         */
        var deleteFirstLine = 0, deleteLastLine = 0
        for index in (0...self.count) {
            guard var tempString: NSString = self.object(at: index) as? NSString else {
                continue
            }
            tempString = tempString.deleteSpaceAndNewLine()
            if tempString.hasPrefix("/*") {
                deleteFirstLine = index
            } else if tempString.hasPrefix("*/") {
                deleteLastLine = index
            }
        }
        guard deleteLastLine > deleteFirstLine else {
            return
        }
        self.removeObjects(in: NSMakeRange(deleteFirstLine, deleteLastLine - deleteFirstLine + 1))
    }
    
    func arrayWithNoSameItem() -> NSArray {
        let set = NSSet(array: self as! [Any])
        
        return NSArray(array: set.allObjects)
    }
    
    func printList() -> Void {
        for item in self {
            print(item)
        }
    }
    
}
