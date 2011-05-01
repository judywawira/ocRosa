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

#import "NumberView.h"
#import "QuestionController.h"
#import "ocRosa.h"

@implementation NumberView

@synthesize answer;

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"NumberView" owner:self options:nil];
    UIView* myView = [nibViews objectAtIndex: 0];
    [super addSubview:myView];
    
    return self;
}

- (void)adjustSubviews {
    [super adjustSubviews];

    // Set the delegate to be our ViewController
    answer.delegate = self.controller;
    
    /*
    [answer addTarget:self.controller
               action:@selector(updateResultUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
     */
    
    // Dynamically place the text field below the 'hint'
    CGRect answerFrame = answer.frame;
    answerFrame.origin.x = hint.frame.origin.x;
    answerFrame.origin.y = hint.frame.origin.y + hint.frame.size.height;
    answer.frame = answerFrame;
    
    // Populate the answer
    answer.text = self.controller.control.result;
}

- (void)willEndView {
    [super willEndView];
    [answer resignFirstResponder];
    self.controller.control.result = answer.text;
}

@end
