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

@class QuestionView;
@class Control;
@class QuestionController;

@interface QuestionViewFactory : NSObject {
    
    NSMutableDictionary *views; // The primary views. As user navigates
                                // through questions, we reuse the same
                                // set of views over and over...
    
    
    NSInteger tag;  // The view-tag of the last-created view
    
}

// Get the ViewType (i.e. kQuestionViewType_Output) for the specified control.
+ (NSInteger)getViewTagForControl:(Control *)control;

+ (NSString *)getViewTypeForControl:(Control *)control;

// Class Cluster. Create the appropriate type of view (subclass of QuestionView)
// for the specified Control. Return QuestionView must be manually released!
- (QuestionView *)createViewForControl:(Control *)control
                   usingViewController:(QuestionController *)viewController;

@end
