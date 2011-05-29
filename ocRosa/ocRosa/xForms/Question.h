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

/*
 * This class represents a set of Answers for a given Record in a structure
 * that is quick to access from a UITableView without needing to perform 
 * any XPath/XML operations. 
 */

#import <Foundation/Foundation.h>
#import "DatabaseRecord.h"

@class DatabaseOperations;

@interface Question : DatabaseRecord {
    
    NSNumber *recordDBID;
    
    NSNumber *controlDBID;
    
}

@property (nonatomic, readonly) NSNumber *recordDBID;
@property (nonatomic, readonly) NSNumber *controlDBID;
@property (nonatomic) BOOL isRelevant;
@property (nonatomic) BOOL isRequired;
@property (nonatomic) BOOL isAnswered;
@property (nonatomic, assign) NSString *answer;

// Create the empty unasnwered Question placeholders in the database
+ (void)initializeEmptyAnswersForRecord:(NSNumber *)recordDBID
                        usingOperations:(DatabaseOperations *)ops
                                  error:(NSError **)error;

@end