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

#import "QuestionViewFactory.h"
#import "QuestionView.h"
#import "SelectOneView.h"
#import "ocRosa.h"

@implementation QuestionViewFactory

+ (NSInteger)getViewTagForControl:(Control *)control {
    
    if (control.type == kControlType_Input_Text)            return kQuestionViewType_Input_Text; 
    else if (control.type == kControlType_Input_Number)     return kQuestionViewType_Input_Number; 
    else if (control.type == kControlType_Input_Date)       return kQuestionViewType_Input_Date;
    else if (control.type == kControlType_Input_LatLong)    return kQuestionViewType_Input_LatLong;
    else if (control.type == kControlType_Output)           return kQuestionViewType_Output;
    else if (control.type == kControlType_Select)           return kQuestionViewType_Select;
    else if (control.type == kControlType_SelectOne)        return kQuestionViewType_SelectOne;
    
    return kQuestionViewType_Input_Text;
}

+ (NSString *)getViewTypeForControl:(Control *)control {
    
    if (control.type == kControlType_Input_Text)            return @"TextView"; 
    else if (control.type == kControlType_Input_Number)     return @"NumberView"; 
    else if (control.type == kControlType_Input_Date)       return @"DateView";
    else if (control.type == kControlType_Input_LatLong)    return @"QuestionView";
    else if (control.type == kControlType_Output)           return @"QuestionView";
    else if (control.type == kControlType_Select)           return @"SelectView";
    else if (control.type == kControlType_SelectOne)        return @"SelectOneView";
    
    return @"QuestionView";
}

- (id)init {
    
    if (!(self = [super init]))
        return nil;

    tag = -1;   // Can't match any kQuestionView_Type constants
    
    [views release];
    views = [[NSMutableDictionary alloc] initWithCapacity:kCount_QuestionViewTypes];
    
    return self;
}

- (void)dealloc {
    [views release];
    [super dealloc];
}

- (QuestionView *)createViewForControl:(Control *)control
                   usingViewController:(QuestionController *)viewController {
    
    NSInteger newtag = [QuestionViewFactory getViewTagForControl:control];
    if (newtag == tag) {
        // We've been asked to create the same view type as the previous
        // request. In this case, set tag to the 'alternate'
        newtag += kCount_QuestionViewTypes;
    }
    
    QuestionView *view = [views objectForKey:[NSNumber numberWithInt:newtag]];
    
    // If the view is already cached - return it
    if (view) {
        tag = newtag;
        return view;
    }
    
    // Otherwise create our view
    Class viewClass = NSClassFromString([QuestionViewFactory getViewTypeForControl:control]);
    view = [[viewClass alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    view.tag = newtag;
    
    // Add our view to the dictionary so it can be reused
    [views setObject:view forKey:[NSNumber numberWithInt:newtag]];
    
    // All of the question views use the same view-controller
    view.controller = viewController;
    
    // Store the tag of the view we just created
    tag = newtag;
    return view;
}



@end
