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

#import "Answers.h"
#import "DatabaseOperations.h"

@implementation Answers

+ (void)initializeEmptyAnswerSetForRecord:(NSNumber *)recordDBID
                          usingOperations:(DatabaseOperations *)ops
                                    error:(NSError **)error {
    
    // Create an initial 'Answer' entry for each control
    NSArray *controls = [ops getControlDBIDs:recordDBID error:error];
    for (NSNumber *currentControlDBID in controls) {
        [ops createAnswerForRecord:recordDBID control:currentControlDBID error:error];

    }
    
}

@end
