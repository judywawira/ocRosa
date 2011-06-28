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

#import "Question.h"
#import "DatabaseOperations.h"

@implementation Question

+ (void)initializeEmptyAnswersForRecord:(NSNumber *)recordDBID
                        usingOperations:(DatabaseOperations *)ops
                                  error:(NSError **)error {
    
    NSArray *controls = [ops getRecordControlDBIDs:recordDBID error:error];
    
    // Create an initial unanswered Question entry for each Control
    for (NSNumber *currentControlDBID in controls) {
        [ops createQuestionForRecord:recordDBID 
                             control:currentControlDBID 
                               error:error];
    }
}


- (id)initWithDBID:(NSNumber *)questionDBID
          database:(DatabaseConnection *)db {
    
    if (!(self = [super initWithDBID:questionDBID database:db]))
        return nil;
    
    return self;
}

- (void)dealloc {
    [recordDBID release];
    [controlDBID release];
    [super dealloc];
}


- (NSNumber *)recordDBID {
    if (!recordDBID) 
        recordDBID = [[operations getQuestionRecord:self.dbid error:&error] copy];
    
    return recordDBID;
}

- (NSNumber *)controlDBID {
    if (!controlDBID) 
        controlDBID = [[operations getQuestionControl:self.dbid error:&error] copy];
    
    return controlDBID;
}

- (BOOL)isRelevant {
    return [operations getQuestionRelevant:self.dbid error:&error];
}

- (void)setIsRelevant:(BOOL)isRelevant {
    [operations setQuestionRelevant:isRelevant forQuestion:self.dbid error:&error];
}

- (BOOL)isRequired {
    return [operations getQuestionRequired:self.dbid error:&error];
}

- (void)setIsRequired:(BOOL)isRequired {
    [operations setQuestionRequired:isRequired forQuestion:self.dbid error:&error];
}

- (BOOL)isAnswered {
    return [operations getQuestionAnswered:self.dbid error:&error];
}

- (void)setIsAnswered:(BOOL)isAnswered {
    [operations setQuestionAnswered:isAnswered forQuestion:self.dbid error:&error];
}

- (NSString *)answer {
    return [operations getQuestionAnswer:self.dbid error:&error];
}

- (void)setAnswer:(NSString *)answer {
    [operations setQuestionAnswer:answer forQuestion:self.dbid error:&error];
}

@end
