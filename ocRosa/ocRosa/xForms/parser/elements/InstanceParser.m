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
#import "RecordXML.h"

@implementation InstanceParser


- (BOOL)beginElement:(NSError **)error {
    [super beginElement:error];
    
    self.dbid = [self.operations createInstanceInModel:self.parentElementParser.dbid
                                                 error:error];
    
    return (self.dbid != nil);
}

- (BOOL)endElement:(NSError **)error {
    [super endElement:error];
    
    RecordXML *xml = [[RecordXML alloc] initWithString:self.innerMarkup];
    NSData *xmlBuffer = [xml xmlBuffer];    
    [xml release];
    
    return [self.operations setInstanceData:xmlBuffer instance:self.dbid error:error];
}


@end