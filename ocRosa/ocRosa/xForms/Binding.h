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

extern NSString *const kBindType_Information;
extern NSString *const kBindType_String;
extern NSString *const kBindType_Integer;
extern NSString *const kBindType_Date;
extern NSString *const kBindType_Geopoint;
extern NSString *const kBindType_Checkbox;
extern NSString *const kBindType_Radio;

@class RecordXML;

@interface Binding : DatabaseRecord {
    
    RecordXML *xml;             // XML <instance>
    
    NSString *nodeset;          // xpath expression that result from
                                // Control is applied to
    
    NSString *constraint;       // xpath expression evaluated after question
                                // is answered. If constraint evaluates to 'false'
                                // then question is not accepted
    
    NSString *constraintMsg;    // message to display when constraint fails
    
    NSString *type;             // Datatype of result/control
    
    NSString *required;         // xpath expression. If evaluates to 'true' then 
                                // an answer must be provided
    
    NSString *relevant;         // xpath expression. Evaluated before a question is
                                // displayed. If 'false' question is skipped.
}

@property (nonatomic, readonly) NSString *nodeset;
@property (nonatomic, readonly) NSString *constraint;
@property (nonatomic, readonly) NSString *constraintMsg;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *required;
@property (nonatomic, readonly) NSString *relevant;

- (id)initWithDBID:(NSNumber *)bindingDBID
          database:(DatabaseConnection *)db
               xml:(RecordXML *)instance;

@end
