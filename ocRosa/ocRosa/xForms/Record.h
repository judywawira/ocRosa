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
    
    RecordXML *xml;                 // xml <instance>
    
    NSArray *questions;              // An ordered list of Question dbids

    NSString *constraintMessage;    // Message to display if constraint evaluation fails
}

@property (nonatomic, readonly) RecordXML *xml;
@property (nonatomic, readonly) NSArray *questions;
@property (nonatomic, copy)     NSString *constraintMessage;

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

// Get the progress (% complete) from 0.0 to 1.0
@property (nonatomic, readonly) float progress;

// A Questions 'relevant' (skip-logic) and 'required'
// flags are XPath expressions that depends on previous answers.
// iterate through every Question in 'questions' recalculate these flags.
- (void)recalculateGlobalQuestionState;

// Get the Control that corresponds to the Question (in 'questions') 
// at the specified index. Will return nil if index is out-of-range or
// if binding 'relevant' is not satisfied
- (Control *)getControl:(NSInteger)index;

// Get just the 'label' of the Control at the specified index.
// Useful if we want to show a summary list of all Questions
// without incurring the cost of constructing a Control. Will
// return nil if index is out of range
- (NSString *)getLabel:(NSInteger)index;

- (BOOL)isAnswered:(NSInteger)index;

- (NSString *)getAnswer:(NSInteger)index;

- (BOOL)isRelevant:(NSInteger)index;

- (BOOL)isRequired:(NSInteger)index;

// Return YES if the current Question has a 'previous' Question
// or NO if the current Question is the first. Note: Bindings
// are not considered - just the raw list of Questions
- (BOOL)hasPrevious:(NSInteger)index;

// Return YES if the current Question has a 'next' Question
// or NO if the current Question is the last. Note: Bindings
// are not considered - just the raw list of Questions
- (BOOL)hasNext:(NSInteger)index;

// Set record state to 'Complete'
- (void)complete;

// Set record state to 'Submitted'
- (void)submitted;

// Update this Record with the results of the Control. Returns YES if
// the record was successfully updated, or NO otherwise. If NO,
// the property 'constraintMessage' will contain a message to display
- (BOOL)updateRecordWithControlResult:(Control *)control;


@end
