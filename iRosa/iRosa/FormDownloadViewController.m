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

#import "FormDownloadViewController.h"
#import "LoginViewController.h"
#import "iRosaAppDelegate.h"
#import "FormDetailViewController.h"
#import "DSActivityView.h"
#import "ocRosa.h"

@implementation FormDownloadViewController

@synthesize xFormIDs, xFormNames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [xFormIDs release];
    [xFormNames release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Download Forms";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.xFormIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.xFormNames objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *username;
    NSString *password;
    
    if (![LoginViewController authenticateFromKeychainUsername:&username andPassword:&password]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [LoginViewController showLoginModallyOverView:
            [self.navigationController.viewControllers objectAtIndex:0]];
    }
    
    
    [DSActivityView activityViewForView:self.view withLabel:@"Downloading..." width:140];

    
    id<OpenRosaServer> server = [[OPENROSA_SERVER alloc] init];
    server.delegate = self;
    server.username = username;
    server.password = password;
    [server requestForm:[xFormIDs objectAtIndex:indexPath.row]];
}

- (void)requestSuccessful:(id<OpenRosaServer>)server {
    NSError *error = nil;
    NSNumber *formDBID = [FormParser parseData:server.receivedData
                                    toDatabase:UIAppDelegate.formManager.connection 
                                         error:(NSError **)error];

    if (!formDBID) {
        DLog(@"%@",[error localizedDescription]);
    }
    
    [DSActivityView removeView];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [server release];
}

- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message {
    // Login failed
}

@end
