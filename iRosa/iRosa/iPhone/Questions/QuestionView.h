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

// The Rosa xForms spec allows for four types of controls 
// (intput, output, select and selectone). However depending
// on the control + binding type, there are many types of 
// question views that we present to the user

extern NSInteger const kQuestionViewType_Output;

extern NSInteger const kQuestionViewType_Input_Text;
extern NSInteger const kQuestionViewType_Input_Number;
extern NSInteger const kQuestionViewType_Input_Date;
extern NSInteger const kQuestionViewType_Input_LatLong;

extern NSInteger const kQuestionViewType_Select;
extern NSInteger const kQuestionViewType_SelectOne;

extern NSUInteger const kCount_QuestionViewTypes; // Number of unique types Views

@class QuestionController;

@interface QuestionView : UIView {
    
    IBOutlet UILabel *title;
    IBOutlet UIProgressView *progress;
    IBOutlet UITextView *question;
    IBOutlet UITextView *hint;
    QuestionController *controller;
    
}

@property (nonatomic, readonly) UILabel *title;
@property (nonatomic, readonly) UIProgressView *progress;
@property (nonatomic, readonly) UITextView *question;
@property (nonatomic, readonly) UITextView *hint;
@property (nonatomic, retain) QuestionController *controller;

// Fine tune adjustement of subviews
- (void)adjustSubviews;

// Called by question controller just before this view
// is switched with another.
- (void)willEndView;

@end
