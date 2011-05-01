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

@implementation ValueParser

- (BOOL)endElement:(NSError **)error {
    [super endElement:error];
    
    // The Value is CData: <xf:value>A Value</xf:value>
    // We don't commit a value to the database directly,
    // rather, a value is always nested under a <item/>
    [self.parentElementParser.attributes setValue:self.cdata forKey:kValueElement];
    return YES;
}

@end