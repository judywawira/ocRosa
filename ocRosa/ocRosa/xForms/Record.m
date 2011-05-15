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

#import "Record.h"
#import "RecordXML.h"
#import "Binding.h"
#import "DatabaseOperations.h"
#import "Control.h"
#import "GTMNSString+XML.h"

NSInteger const kRecordState_InProgress = -1;
NSInteger const kRecordState_Completed  = 0;
NSInteger const kRecordState_Submitted  = 1;

@implementation Record

@synthesize constraintMessage, controlIndex;

- (id)initWithDBID:(NSNumber *)recordDBID
          database:(DatabaseConnection *)db; {
    
    if (!(self = [super initWithDBID:recordDBID database:db]))
        return nil;
    
    controlIndex = 0;
    
    return self;
}

- (void)dealloc {
    [xml release];
    [controls release];
    [super dealloc];
}

- (RecordXML *)xml {
    if (!xml) 
        xml = [[RecordXML alloc] initWithUTF8Data:[operations getRecordXML:self.dbid error:&error]];
    
    return xml;
}

- (NSArray *)controls {
    if (!controls)
        controls = [[operations getControlDBIDs:self.dbid error:&error] copy];
    
    return controls;
}

- (NSInteger)state {
    return [[operations getRecordState:self.dbid error:&error] integerValue];
}

- (NSDate *)createDate {
    return [operations getRecordCreateDate:self.dbid error:&error];
}

- (NSDate *)completeDate {
    return [operations getRecordCompleteDate:self.dbid error:&error];
}

- (NSDate *)submitDate {
    return [operations getRecordSubmitDate:self.dbid error:&error];
}

- (NSDate *)date {
    switch (self.state) {
        case kRecordState_InProgress:
            return self.createDate;
            break;
        case kRecordState_Completed:
            return self.completeDate;
            break;
        case kRecordState_Submitted:
            return self.submitDate;
            break;
    }
    return self.createDate;;
}

- (void)complete {
    [operations setRecordComplete:(NSNumber *)dbid error:&error]; 
}

- (float)getProgress {
    return (float)controlIndex / ([controls count] - 1);
}

- (Control *)getControlAtIndex {
    
    if ([self.controls count] == 0 || controlIndex < 0 || controlIndex >= [self.controls count] ) {
        ALog(@"Control index out-of-range"); // Assert, because should never happen
        return nil;
    }
    
    NSNumber *currentControlDBID = [controls objectAtIndex:controlIndex];
    
    // Get the Binding that corresponds to this Control
    [binding release];
    binding = [[Binding alloc] initWithDBID:[operations getBindingForControl:currentControlDBID error:&error]
                                   database:connection
                                        xml:[self xml]];

    Control *control = [[Control alloc] initWithDBID:currentControlDBID
                                             binding:binding
                                            database:connection];
    
    control.result = [xml getValueFromNodeset:[binding nodeset] error:&error];
    
    // Evaluate the 'relevent' XPath expression against the current <instance> document.
    // If YES then return the current control dbid, if NO then try the next one.
    // If relevant is nil (no restrictions) then return the current control.
    if (![binding relevant] || [xml evaluateXPathExpression:[binding relevant] error:&error])
        control.isRelevant = YES;
    
    return control;
}

- (NSString *)getLabelOfControlAtIndex:(NSInteger)index {
   
    if ([self.controls count] == 0 || index < 0 || index >= [self.controls count] ) {
        ALog(@"Control index out-of-range"); // Assert, because should never happen
        return nil;
    }
    
    return [operations getControlLabel:[controls objectAtIndex:index] error:&error];    
}

- (BOOL)hasPreviousControl {
    if ([self.controls count] == 0 || (controlIndex - 1) < 0 || (controlIndex - 1) >= [self.controls count]) {
        // Out of range / no more controls
        return NO;
    }
    return YES;
}

- (BOOL)hasNextControl {
    if ([self.controls count] == 0 || (controlIndex + 1) < 0 || (controlIndex + 1) >= [self.controls count]) {
        // Out of range / no more controls
        return NO;
    }
    return YES;
}

- (BOOL)updateRecordWithControlResult:(Control *)control {
    
    // If an answer is required but none was provided, return NO
    if ([binding required] && 
        [xml evalXPath:[binding required] error:&error] &&
        ![control result]) {
            self.constraintMessage = @"Answer required";
            return NO;
    }
    
    // If the control has no result.. and a result is not
    // required return immediatley
    if (![control result])
        return YES;
    
    // We need to get a duplicate copy of the <instance>,
    // update that copy with the control.result, and then
    // evaluate the binding constraint. If the constraint
    // evaluates to YES then we can go ahead and apply the
    // control.result to the actual <instance>, otherwise
    // the user has to tweak their answer.
    if ([binding constraint]) {
    
        RecordXML *duplicateXML = [[RecordXML alloc] initWithUTF8Data:[operations getRecordXML:self.dbid error:&error]];
        
        // Update the in-memory <instance> with the Control result
        if (![duplicateXML setValue:control.result forNodeset:[binding nodeset] error:&error]) {
            ALog(@"Unable to set <instance> value '%@' for nodeset '%@'", control.result, [binding nodeset]); // Assert, because should never happen
            [duplicateXML release];
            return NO;
        }
        
        // Validate against the binding's constraints
        if (![duplicateXML evaluateXPathExpression:[binding constraint] error:&error]) {
            self.constraintMessage = [binding constraintMsg];
            [duplicateXML release];
            return NO;
        }
         
        // Constrating check was successful..
        [duplicateXML release];
    }
    
    // Update <instance> with our result
    if (![xml setValue:[control.result gtm_stringBySanitizingAndEscapingForXML] forNodeset:[binding nodeset] error:&error]) {
        ALog(@"Unable to set <instance> value '%@' for nodeset '%@'", control.result, [binding nodeset]); // Assert, because should never happen
        return NO;
    }
 
    // Commit to the Database
    if (![operations setRecordXML:[xml xmlBuffer] record:self.dbid error:&error])
        return NO;
 
    DLog(@"%@", [xml xmlString]);
    
    // Everything worked
    return YES;
}

- (BOOL)clearRecordForInvalidControl:(Control *)control {
    
    control.result = @"";
    
    // Update <instance> with our result
    if (![xml setValue:[control.result gtm_stringBySanitizingAndEscapingForXML] forNodeset:[binding nodeset] error:&error]) {
        ALog(@"Unable to set <instance> value '%@' for nodeset '%@'", control.result, [binding nodeset]); // Assert, because should never happen
        return NO;
    }
    
    // Commit to the Database
    if (![operations setRecordXML:[xml xmlBuffer] record:self.dbid error:&error])
        return NO;
    
    DLog(@"%@", [xml xmlString]);
    
    // Everything worked
    return YES;  
}


@end
