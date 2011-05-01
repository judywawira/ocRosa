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

#import "SelectOneView.h"
#import "QuestionController.h"
#import "ocRosa.h"

@implementation SelectOneView

@synthesize picker;

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"SelectOneView" owner:self options:nil];
    UIView* myView = [nibViews objectAtIndex: 0];
    [super addSubview:myView];
        
    return self;
}


- (void)adjustSubviews {
    [super adjustSubviews];
    
    // Set the delegate and datasource to be our ViewController
    picker.dataSource = self.controller;
    picker.delegate = self.controller;
    
    // Dynamically place the Picker below the 'hint'
    CGRect pickerFrame = picker.frame;
    pickerFrame.origin.x = 0;
    pickerFrame.origin.y = hint.frame.origin.y + hint.frame.size.height;
    picker.frame = pickerFrame;
    
    // Figure out which row should be selected    
    NSMutableArray *selection = [NSMutableArray arrayWithArray:[self.controller.control decodeResultToSelection]];
    
    // Find the first item that's true
    NSInteger selectedIndex = 0;
    for (int i = 0; i < [selection count]; i++) {
        if ([[selection objectAtIndex:i] boolValue]) {
            selectedIndex = i;
            break;
        }
    }
       
    [picker selectRow:selectedIndex inComponent:0 animated:NO];
    [selection replaceObjectAtIndex:selectedIndex withObject:[NSNumber numberWithBool:YES]];
    [self.controller.control encodeResultFromSelection:selection];
}

@end
