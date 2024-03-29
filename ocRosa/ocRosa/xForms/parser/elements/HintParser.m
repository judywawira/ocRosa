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

@implementation HintParser

- (BOOL)endElement:(NSError **)error {
    [super endElement:error];
    
    // The Hint is CData: <xf:hint>A Hint</xf:hint>
    // We don't commit a hint to the database directly,
    // rather, a hint is always nested under a control
    [self.parentElementParser.attributes setValue:self.cdata forKey:kHintElement];
    return YES;
}

@end