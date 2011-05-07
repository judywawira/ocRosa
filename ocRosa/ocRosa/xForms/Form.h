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

@interface Form : DatabaseRecord {
    NSString    *title;
    NSURL       *downloadURL;
    NSDate      *downloadDate;
    NSNumber    *questionCount;
}

@property (nonatomic, readonly) NSString  *title;
@property (nonatomic, readonly) NSURL     *downloadURL;
@property (nonatomic, readonly) NSDate    *downloadDate;
@property (nonatomic, readonly) NSNumber  *questionCount;

// Get/Count all of this Form's Records
- (NSArray *)getRecordDBIDs;    
- (NSNumber *)countRecords;

// Get/Count Records in a particular state
- (NSArray *)getRecordDBIDsWithState:(NSNumber *)state;
- (NSNumber *)countRecordsWithState:(NSNumber *)state;

@end
