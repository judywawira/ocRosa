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

#import "Elements.h"
#import "Control.h" // For ControlTypes
#import "DatabaseConnection.h"
#import "DatabaseOperations.h"

@implementation ControlParser

- (BOOL)beginElement:(NSError **)error {
    [super beginElement:error];
 
    NSInteger controlType = -1;
    if ([self.name isEqualToString:kOutputElement]) {
        controlType = kControlType_Output;
    } else if ([self.name isEqualToString:kInputElement]) {
        controlType = kControlType_Input;
    } else if ([self.name isEqualToString:kSelectElement]) {
        controlType = kControlType_Select;
    } else if ([self.name isEqualToString:kSelectOneElement]) {
        controlType = kControlType_SelectOne;
    }
    
    // We don't need to deal with unsupported control-types here,
    // the newParserForElement factory method won't even create a 
    // ControlParser unless it's a supported control type
    
    self.dbid = [self.operations createControlInForm:self.parentElementParser.dbid
                                                type:[NSNumber numberWithInt:controlType]
                                             binding:[self getAttribute:@"bind"]
                                                 ref:[self getAttribute:@"ref"]
                                               error:error];
     
    return (self.dbid != nil);
}

- (BOOL)endElement:(NSError **)error {
    [super endElement:error];
    
    if (![self.operations setControlLabel:[self getAttribute:kLabelElement]
                                  control:self.dbid
                                    error:error])
        return NO;
    

    if (![self.operations setControlHint:[self getAttribute:kHintElement]
                                  control:self.dbid
                                    error:error])
        return NO;
    
    
    return YES;
}

@end