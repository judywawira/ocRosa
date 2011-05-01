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

#import "Form.h"
#import "Record.h"
#import "DatabaseOperations.h"

@implementation Form

- (void)dealloc {
    [title release];
    [downloadDate release];
    [downloadURL release];
    [questionCount release];
    [super dealloc];
}

- (NSString *)title {
    if (!title)
        title = [[operations getFormTitle:dbid error:&error] copy];
    
    return title;
}

- (NSURL *)downloadURL {
    if (!downloadURL)
        downloadURL = [[NSURL URLWithString:[operations getFormDownloadURL:self.dbid error:&error]] copy];
    
    return downloadURL;
}

- (NSDate *)downloadDate {
    if (!downloadDate)
        downloadDate = [[operations getFormDownloadDate:self.dbid error:&error] copy];
    
    return downloadDate;
}

- (NSNumber *)questionCount {
    if (!questionCount) 
        questionCount = [[operations getFormQuestionCount:self.dbid error:&error] copy];
        
    return questionCount;
}

- (NSArray *)getInProgressRecordDBIDs {return nil;}

- (NSNumber *)countInProgressRecords {
    return [operations getFormRecordCount:self.dbid state:kRecordState_InProgress error:&error];
}

- (NSArray *)getCompletedRecordDBIDs {return nil;}

- (NSNumber *)countCompletedRecords {
    return [operations getFormRecordCount:self.dbid state:kRecordState_Completed error:&error];
}

- (NSArray *)getSubmittedRecordDBIDs {return nil;}

- (NSNumber *)countSubmittedRecords {
    return [operations getFormRecordCount:self.dbid state:kRecordState_Submitted error:&error];
}


@end
