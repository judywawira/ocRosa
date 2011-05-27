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

extern NSInteger const kRecordState_InProgress;
extern NSInteger const kRecordState_Completed;
extern NSInteger const kRecordState_Submitted;

@class Control;
@class RecordXML;
@class Binding;

@interface Record : DatabaseRecord {
    
    RecordXML *xml;         // xml <instance>
    
    
    NSArray *controls;      // An ordered list of dbids

    NSString *constraintMessage;    // Message to display if constraint evaluation fails
}

@property (nonatomic, readonly) RecordXML *xml;
@property (nonatomic, readonly) NSArray *controls;
@property (nonatomic, copy) NSString *constraintMessage;

@property (nonatomic, readonly) NSInteger state;
@property (nonatomic, readonly) NSDate *createDate;
@property (nonatomic, readonly) NSDate *completeDate;
@property (nonatomic, readonly) NSDate *submitDate;

// Return a 'context sensitive' date.
//
//  State:                      Returns:
//  kRecordState_InProgress     createDate
//  kRecordState_Completed      completeDate
//  kRecordState_Submitted      submitDate
@property (nonatomic, readonly) NSDate *date;

// The 'Answer Set' is a set of entries in the database
// that indicates if a given question is relevant and/or 
// has been answered. The Answer Set provides a quick way
// to see the summary state of the form, without having to
// incur to cost of evaluating XML XPath expressions
// for each Control.
- (void)initializeAnswerSet;

// Get the progress (% complete) from 0.0 to 1.0
- (float)getProgress;

// Get the control at the current controlIndex. Will return nil
// if index is out-of-range or if binding 'relevant' is not
// satisfied
- (Control *)getControlAtIndex:(NSInteger)index;

// Get just the 'label' of the Control at the specified index.
// Useful if we want to show a summary list of all Controls
// without incurring the cost of constructing a Control. Will
// return nil if index is out of Range
- (NSString *)getLabelOfControlAtIndex:(NSInteger)index;

- (BOOL)isControlAtIndexAnswered:(NSInteger)index;

- (NSString *)getAnswerOfControlAtIndex:(NSInteger)index;

- (BOOL)isControlAtIndexRelevant:(NSInteger)index;

// Return YES if the current control has a 'previous' control
// or NO if the current control is the first. Note: Bindings
// are not considered - just the raw list of controls.
- (BOOL)hasPreviousControl:(NSInteger)index;

// Return YES if the current control has a 'next' control
// or NO if the current control is the last. Note: Bindings
// are not considered - just the raw list of controls.
- (BOOL)hasNextControl:(NSInteger)index;

// This record is complete
- (void)complete;

// Update this Record with the results
// of the Control (Question). Returns YES
// if the record was successfully updated,
// or NO otherwise. If NO, the output
// parameter failureMessage will contain the
// reason why the update failed.
- (BOOL)updateRecordWithControlResult:(Control *)control;


@end
