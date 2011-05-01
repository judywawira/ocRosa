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

#import <UIKit/UIKit.h>

@class FormManager;
@class Form;
@class Record;
@class FormDetailViewController;

@interface QuestionsViewController : UITableViewController {
    
    FormDetailViewController *formDetails;
    
    NSString *formTitle;        // Passed-in from FormDetailController
    
    FormManager *formManager;   // Passed-in from FormDetailController
        
    Record *record;             // Passed-in from FormDetailController
    
    NSArray *questions;         // List of this record's questions
}

@property (nonatomic, copy) NSString *formTitle;
@property (nonatomic, retain) FormManager *formManager;
@property (nonatomic, retain) Record *record;
@property (nonatomic, retain) FormDetailViewController *formDetails;

@end
