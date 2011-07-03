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

#import "SelectView.h"
#import "QuestionController.h"
#import "ocRosa.h"

@implementation SelectView

@synthesize answers;

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"SelectView" owner:self options:nil];
    UIView* myView = [nibViews objectAtIndex: 0];
    [super addSubview:myView];
    
    return self;
}


- (void)adjustSubviews {
    [super adjustSubviews];
    
    // Set the delegate and datasource to be our ViewController
    answers.dataSource = self.controller;
    answers.delegate = self.controller;
    
    // Dynamically place the Picker below the 'hint'
    CGRect answersFrame = answers.frame;
    answersFrame.size.height = self.superview.frame.size.height;
    answersFrame.origin.x = 0;
    answersFrame.origin.y = hint.frame.origin.y + hint.frame.size.height;
    answers.frame = answersFrame;
    
    [answers reloadData];
}

- (void)willEndView {
    [super willEndView];
    //[self.controller.control encodeResultFromDate:[picker date]];
}
@end
