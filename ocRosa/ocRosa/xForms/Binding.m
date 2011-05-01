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

#import "Binding.h"
#import "DatabaseOperations.h"

NSString *const kBindType_Information   = @"xsd:information";
NSString *const kBindType_String        = @"xsd:string";
NSString *const kBindType_Integer       = @"xsd:integer";
NSString *const kBindType_Date          = @"xsd:date";
NSString *const kBindType_Geopoint      = @"jr:geopoint";
NSString *const kBindType_Checkbox      = @"xsd:checkbox";
NSString *const kBindType_Radio         = @"xsd:radio";

@implementation Binding

- (id)initWithDBID:(NSNumber *)bindingDBID
          database:(DatabaseConnection *)db
               xml:(RecordXML *)instance {
    
    if (!(self = [super initWithDBID:bindingDBID database:db]))
        return nil;
    
    xml = [instance retain];
    
    return self;
}

- (void)dealloc {
    [xml release];
    [nodeset release];
    [constraint release];
    [constraintMsg release];
    [type release];
    [required release];
    [relevant release];
    [super dealloc];
}

- (NSString *)nodeset {
    if (!nodeset)
        nodeset = [[operations getBindingNodeset:self.dbid error:&error] copy];
    
    return nodeset;
}

- (NSString *)constraint {
    if (!constraint)
        constraint = [[operations getBindingConstraint:self.dbid error:&error] copy];
    
    return constraint;
}

- (NSString *)constraintMsg {
    if (!constraintMsg)
        constraintMsg = [[operations getBindingConstraintMsg:self.dbid error:&error] copy];
    
    return constraintMsg;
}

- (NSString *)type {
    if (!type)
        type = [[operations getBindingType:self.dbid error:&error] copy];
    
    return type;
}

- (NSString *)required {
    if (!required)
        required = [[operations getBindingRequired:self.dbid error:&error] copy];
    
    return required;
}

- (NSString *)relevant {
    if (!relevant)
        relevant = [[operations getBindingRelevant:self.dbid error:&error] copy];
    
    return relevant;
}


@end
