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

#import <Foundation/Foundation.h>
#import "DatabaseRecord.h"

// XForm Control Types
extern NSInteger const kControlType_Output;
extern NSInteger const kControlType_Input;
extern NSInteger const kControlType_Select;
extern NSInteger const kControlType_SelectOne;

// Specific Input Types
extern NSInteger const kControlType_Input_Text;
extern NSInteger const kControlType_Input_Number;
extern NSInteger const kControlType_Input_Date;
extern NSInteger const kControlType_Input_LatLong;

@class Binding;

@interface Control : DatabaseRecord {
    
    Binding *binding;   // Binding that corresponds to this Control
    
    NSInteger type;     // One of the kControlTypes. Query
                        // binding.type to get specific data type
             
    NSString *label;    // Text label to display
    
    NSString *hint;     // Help/Hint to display
    
    NSArray *items;     // If item is a Select/Select1, this is
                        // the list of choices
    
    NSArray *values;    // List of values encoded into result
                        // corresponding to items (i.e. the item
                        // might be "Female", and the value "f")
    
    NSString *result;   // Encoded result. Inserted into the <instance>.
    
    NSInteger index;    // Index of this Control in the Record
}

@property (nonatomic, readonly) NSInteger type;
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *hint;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, copy) NSString *result;
@property (nonatomic) NSInteger index;

- (id)initWithDBID:(NSNumber *)controlDBID
           binding:(Binding *)controlBinding
          database:(DatabaseConnection *)db;

// Selected items is an array of integers that corresponds
// to the indices of the selected Items/Values
// Encoded string is stored in 'result'.
// 'result' will nil if selectedItems is nil or empty. 
- (void)encodeResultFromSelection:(NSArray *)selectedItems;

// Reverse. Decode 'result' to generate an array of
// integers that correspond to selected Items/Values
- (NSArray *)decodeResultToSelection;


- (void)encodeResultFromDate:(NSDate *)date;
- (NSDate *)decodeResultToDate;

@end
