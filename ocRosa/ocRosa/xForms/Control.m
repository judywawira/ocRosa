/*
 * Copyright © 2011 Michael Willekes
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

#import "Control.h"
#import "GTMNSString+XML.h"
#import "DatabaseOperations.h"

NSInteger const kControlType_Output     = 0;
NSInteger const kControlType_Input      = 1;
NSInteger const kControlType_Select     = 2;
NSInteger const kControlType_SelectOne  = 3;

@implementation Control

@synthesize binding;
@synthesize result;

- (id)initWithDBID:(NSNumber *)controlDBID
           binding:(Binding *)controlBinding
          database:(DatabaseConnection *)db {
    
    if (!(self = [super initWithDBID:controlDBID database:db]))
        return nil;
    
    self.result = nil;
    
    binding = [controlBinding retain];
    
    type = -1;  // Initialize to invalid control type
        
    return self;
}

- (void)dealloc {
    self.result = nil;
    [binding release];
    [label release];
    [hint release];
    [items release];
    [values release];
    [super dealloc];
}

- (NSInteger)type {
    if (type < 0) 
        type = [operations getControlType:self.dbid error:&error];
    
    return type;
}

- (NSString *)label {
    if (!label) 
        label = [operations getControlLabel:self.dbid error:&error];
    
    return label;
}

- (NSString *)hint {
    if (!hint) 
        hint = [operations getControlHint:self.dbid error:&error];
    
    return hint;
}

// 'items' and 'values' arrays are autoreleased by 'operations'. Since these
// are added to controls in the QuestionViews - need to retain them.

- (NSArray *)items {
    if (!items)
        items = [[operations getControlItems:self.dbid error:&error] retain];
    
    return items;
}

- (NSArray *)values {
    if (!values)
        values = [[operations getControlValues:self.dbid error:&error] retain];
    
    return values;
}

- (void)encodeResultFromSelection:(NSArray *)selectedItems {
    
    if (!selectedItems || [selectedItems count] != [self.values count])
        return;
    
    // Figure out how many selected items we have
    NSInteger count = 0;
    for (NSNumber *number in selectedItems) {
        if ([number boolValue])
            count++;
    }
    
    NSMutableString *encodedResult = [NSMutableString stringWithCapacity:64];
    
    for (int i = 0; i < [selectedItems count]; i++) {
        BOOL isSelected = [[selectedItems objectAtIndex:i] boolValue];
        if (isSelected) {
            [encodedResult appendString:[self.values objectAtIndex:i]];
            count--;
            if (count > 0) {
                // If there's at least one selected item,
                // and there are more items, append a "|"
                [encodedResult appendString:@" | "];
            }
        }
    }
    
    self.result = encodedResult;
}

- (NSArray *)decodeResultToSelection {
    
    // Initially - set all of our 'selected' entries to 'NO'
    NSMutableArray *selectedItems = [NSMutableArray arrayWithCapacity:[self.values count]];
    for (int i = 0; i < [self.values count]; i++) {
        [selectedItems addObject:[NSNumber numberWithBool:NO]];
    }
    
    if (!self.result || [self.result length] == 0)
        return [NSArray arrayWithArray:selectedItems];
                
    NSArray *tokens = [self.result componentsSeparatedByString: @"|"];    
    for (id token in tokens) {
        NSNumber *index = [NSNumber numberWithUnsignedInteger:
                                [self.values indexOfObject:
                                    [token stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        
        [selectedItems replaceObjectAtIndex:[index unsignedIntValue] 
                                 withObject:[NSNumber numberWithBool:YES]];
    }

    return [NSArray arrayWithArray:selectedItems];
}

- (void)encodeResultFromDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSince1970];
    self.result = [NSString stringWithFormat:@"%f", interval];
}

- (NSDate *)decodeResultToDate {
    if (!self.result)
        return [NSDate date]; // No result - return 'now'
    
    return [NSDate dateWithTimeIntervalSince1970:[self.result doubleValue]];
}

@end
