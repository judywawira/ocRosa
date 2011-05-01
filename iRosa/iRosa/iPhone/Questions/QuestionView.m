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

#import "QuestionView.h"
#import "QuestionController.h"

// Start counting at 1
NSInteger const kQuestionViewType_Output        = 1;

NSInteger const kQuestionViewType_Input_Text    = 2;
NSInteger const kQuestionViewType_Input_Number  = 3;
NSInteger const kQuestionViewType_Input_Date    = 4;
NSInteger const kQuestionViewType_Input_LatLong = 5;

NSInteger const kQuestionViewType_Select        = 6;
NSInteger const kQuestionViewType_SelectOne     = 7;

// Total number of unique types Views
NSUInteger const kCount_QuestionViewTypes       = 7;


@implementation QuestionView

@synthesize title, progress, question, hint, controller;

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"QuestionView" owner:self options:nil];
    UIView* myView = [nibViews objectAtIndex: 0];
    [self addSubview:myView];
    
    return self;
}

- (void)adjustSubviews {
    
    // Dynamically adjust the side of the 'question' UITextView to
    // hold the question text
    CGRect questionFrame = question.frame;
    questionFrame.size.height = question.contentSize.height;
    question.frame = questionFrame;
    
    // Dynamically place the 'hint' below the question
    CGRect hintFrame = hint.frame;
    hintFrame.size.height = hint.contentSize.height;
    hintFrame.origin.y = questionFrame.origin.y + questionFrame.size.height;
    hint.frame = hintFrame;
}

- (void)willEndView {
    // Intentionally Blank
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	self.view.backgroundColor = [UIColor yellowColor];
	
	UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 80)];
	myLabel.text = control.label;
	myLabel.textAlignment = UITextAlignmentCenter;	
	myLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.5 alpha:0.3];
    
    [self.view addSubview:myLabel];
}
*/


- (void)dealloc {
    [title release];
    [progress release];
    [question release];
    [controller release];
    [super dealloc];
}

@end
