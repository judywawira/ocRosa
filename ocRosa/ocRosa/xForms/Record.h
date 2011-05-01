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
    
    Binding *binding;       // Current Binding
    
    NSArray *controls;      // An ordered list of dbids
    
    NSInteger controlIndex; // Current Control in controls

    NSString *constraintMessage;    // Message to display if constraint evaluation fails
}

@property (nonatomic, readonly) RecordXML *xml;
@property (nonatomic, readonly) NSArray *controls;
@property (nonatomic, copy) NSString *constraintMessage;
@property (nonatomic) NSInteger controlIndex;

// Return YES if the current control is relevant.
// Relevance is determined by evaluating the Binding
// xPath expression 'relevant' against the current result
// XML. If that expression returns FALSE then this
// returns NO.
- (BOOL)isRelevant:(NSNumber *)controlDBID;

// Similar to 'isRelevant'. Constraints are evaluated
// after the XML is updated.
- (BOOL)areConstraintsSatisfied:(NSNumber *)controlDBID;

// Get the progress (% complete) from 0.0 to 1.0
- (float)getProgress;

// Get the control at the current controlIndex. Will return nil
// if index is out-of-range or if binding constraint is not
// satisfied
- (Control *)getControlAtIndex;

// Get just the 'label' of the Control at the specified index.
// Useful if we want to show a summary list of all Controls
// without incurring the cost of constructing a Control. Will
// return nil if index is out of Range
- (NSString *)getLabelOfControlAtIndex:(NSInteger)index;

// Return YES if the current control has a 'previous' control
// or NO if the current control is the first. Note: Bindings
// are not considered - just the raw list of controls.
- (BOOL)hasPreviousControl;

// Return YES if the current control has a 'next' control
// or NO if the current control is the last. Note: Bindings
// are not considered - just the raw list of controls.
- (BOOL)hasNextControl;

// This record is complete
- (void)complete;

// Update this Record with the results
// of the Control (Question). Returns YES
// if the record was successfully updated,
// or NO otherwise. If NO, the output
// parameter failureMessage will contain the
// reason why the update failed.
- (BOOL)updateRecordWithControlResult:(Control *)control;

// As we skip over controls that are invalid,
// we want to clear any existing results for those countrols
// (i.e. suppose user accidentally answered questions about
// subject's pregnancy... but there was a collection-error
// and the subject isn't actually pregnant)
- (BOOL)clearRecordForInvalidControl:(Control *)control;

@end
