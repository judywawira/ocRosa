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

#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import "iRosaAppDelegate.h"
#import "ocRosa.h"

@implementation LoginViewController

@synthesize title, username, password, remeberSwitch;

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


- (IBAction)login:(id)sender {

    id<OpenRosaServer> server = [[EpiSurveyor alloc] init];
    server.delegate = self;
    server.username = self.username.text;
    server.password = self.password.text;
    [server login];
    
}

- (void)requestSuccessful:(id<OpenRosaServer>)server {
    // Login succeeded
    
    // Add username (usually an email address) and password to the keychain
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"OPENROSA" accessGroup:nil];
    [keychain setObject:self.username.text forKey:(id)kSecAttrAccount];
    [keychain setObject:self.password.text forKey:(id)kSecValueData];
    [keychain release];
    
    [self dismissModalViewControllerAnimated:YES];
    
    NSError *error = nil;
    UIAppDelegate.formManager = [FormManager createEncryptedFormManager:self.username.text
                                                             passphrase:self.password.text
                                                                  error:&error];

    [server release];
}

- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message {
    // Login failed
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
    [[UIScreen mainScreen] applicationFrame];
    // Do any additional setup after loading the view from its nib.
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
