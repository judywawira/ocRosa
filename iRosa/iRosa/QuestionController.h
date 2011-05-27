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

@class Record;
@class Control;
@class FormManager;
@class FormDetailViewController;

@interface QuestionController : UIViewController 
        <UIPickerViewDataSource,
        UIPickerViewDelegate, 
        UITextFieldDelegate, 
        UITextViewDelegate,
        UITableViewDelegate,
        UITableViewDataSource> {
    
    Record *record;
    Control *control;
    NSInteger controlIndex;
    NSString *formTitle;
    FormManager *formManager;
    FormDetailViewController *formDetails;
}

@property (nonatomic, retain) Control *control;
@property (nonatomic) NSInteger controlIndex;
@property (nonatomic, retain) Record *record;
@property (nonatomic, retain) FormManager *formManager;
@property (nonatomic, retain) FormDetailViewController *formDetails;
@property (nonatomic, copy) NSString *formTitle;

- (BOOL)nextQuestion;

- (BOOL)previousQuestion;

- (void)done;

@end
