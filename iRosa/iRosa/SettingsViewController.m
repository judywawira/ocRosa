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

#import "SettingsViewController.h"
#import "LoginViewController.h"


@implementation SettingsViewController

@synthesize appTitle, appVersion, username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    self.appTitle.text = [infoPList objectForKey:@"CFBundleDisplayName"];
    self.appVersion.text = [infoPList objectForKey:@"CFBundleVersion"]; 
    
    NSString *keychainUsername = nil;
    NSString *keychainPassword = nil;
        
    if ([LoginViewController authenticateFromKeychainUsername:&keychainUsername andPassword:&keychainPassword]) {
        
        self.username.text = keychainUsername;
        self.username.enabled = NO;
        
    } else {
        [LoginViewController showLoginModallyOverView:self];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)logout:(id)sender {
    [LoginViewController logout];
    [LoginViewController showLoginModallyOverView:self];
}

@end
