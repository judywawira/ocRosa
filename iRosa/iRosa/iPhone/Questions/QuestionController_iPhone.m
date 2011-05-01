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

#import <QuartzCore/QuartzCore.h>

#import "QuestionController_iPhone.h"
#import "QuestionViewFactory.h"
#import "QuestionView.h"
#import "ocRosa.h"

@implementation QuestionController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        return nil;
    
    viewFactory = [[QuestionViewFactory alloc] init];

    return self;
}

- (void)dealloc {
    [viewFactory release];
    [super dealloc];
}

// There are many different types of questions (a.k.a xForms controls). Rather than mantaining a giant
// set of nibs, we'll construct the view hierarchy programatically. Lots more code, but easier to control
- (void)loadView {
    [super loadView];
    QuestionView *view = [viewFactory createViewForControl:control usingViewController:self];
    [self.view addSubview:(UIView *)view];
    [self configureView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildNavigationButtons];
}

- (void)buildNavigationButtons {
    
    BOOL hasPrevious = [record hasPreviousControl];
    BOOL hasNext = [record hasNextControl];
    
    // Create a custom toolbar to navigate forwards and backwards through the questions.
    // This custom toolbar will be embedded into the right-side of the navigation bar.
    
    CGFloat toolbarWidth = 10; // Padding from Right Edge
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (hasPrevious) {
        // Button in Nav bar to goto previous Question
        UIBarButtonItem* prevButton = [[UIBarButtonItem alloc] initWithTitle:@"<" 
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(previousQuestion)];
        prevButton.width = 50;
        toolbarWidth += prevButton.width;
        [buttons addObject:prevButton];
        [prevButton release];
        
        // There's always a 'next' (or 'Done') button. If there's also a 'previous' then add a Spacer
        UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
        toolbarWidth += 10;
        [buttons addObject:spacer];
        [spacer release];
    }
    
    if (hasNext) {
        // Button in Nav bar to advance to next Question
        UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@">" 
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(nextQuestion)];
        nextButton.width = 50;
        toolbarWidth += nextButton.width;
        [buttons addObject:nextButton];
        [nextButton release];
        
    } else {
        // No more Questions. Show 'DONE' button
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"^" 
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(done)];
        doneButton.width = 50;
        toolbarWidth += doneButton.width;
        [buttons addObject:doneButton];
        [doneButton release];
    }
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, toolbarWidth, 44.01)];
    [toolbar setItems:buttons animated:NO];
    [buttons release];
    
    // Add custom toolbar to the Nav Bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    [toolbar release];
}

- (void)switchQuestion:(NSString *)transitionSubType {
   
    // Rebuild the navigation buttons based on the current control
    [self buildNavigationButtons];
    
    // Get the view that should be displayed next. If that view's tag is not
    // in the view hierarchy then add it. If that view's tag is already in the
    // view hierarchy then bring it to the front).
    QuestionView *nextView = [viewFactory createViewForControl:control usingViewController:self];
    NSInteger tag = ((UIView *)nextView).tag;
    
    // Find the view with that tag
    UIView *taggedView = [self.view viewWithTag:tag];
    
    if (!taggedView) {
        // View hierarchy does not contain a view of this type. Add it...
        [self.view addSubview:(UIView *)nextView];
    } else {
        nextView = (QuestionView *)taggedView;
        [self.view bringSubviewToFront:taggedView];
    }

    [self configureView:nextView];
    
    /*
    //TODO: figure out how to get this animation working correctly 
     
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = transitionSubType;
    [self.view.layer addAnimation:transition forKey:@"push-transition"];  
    */
}

- (void)configureView:(QuestionView *)view {
    
    activeView = view;
    
    view.title.text = self.formTitle;
    view.progress.progress = record.getProgress;
    view.question.text = control.label;
    view.hint.text = control.hint;
    
    [view adjustSubviews];
}

- (BOOL)nextQuestion {
    [activeView willEndView];
    
    if (![super nextQuestion])
        return NO;
    
    [self switchQuestion:kCATransitionFromRight];
    return YES;
}

- (BOOL)previousQuestion {
    [activeView willEndView];
    
    if (![super previousQuestion])
        return NO;
    
    [self switchQuestion:kCATransitionFromLeft];
    return YES;
}

@end
