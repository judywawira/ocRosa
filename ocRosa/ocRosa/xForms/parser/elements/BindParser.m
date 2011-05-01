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
#import "DatabaseOperations.h"

@implementation BindParser

- (BOOL)beginElement:(NSError **)error {
    [super beginElement:error];
    
    self.dbid = [self.operations createBindingInModel:self.parentElementParser.dbid
                                             xFormsID:[self getAttribute:@"id"]
                                              nodeset:[self getAttribute:@"nodeset"]
                                           constraint:[self getAttribute:@"constraint"]
                                    constraintMessage:[self getAttribute:@"jr:constraintMsg"]
                                                 type:[self getAttribute:@"type"]
                                             required:[self getAttribute:@"required"]
                                             relevant:[self getAttribute:@"relevant"]
                                                error:error];
    
    return (self.dbid != nil);
}


@end