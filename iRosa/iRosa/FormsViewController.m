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

#import "FormsViewController.h"
#import "FormDetailViewController.h"
#import "FormDownloadViewController.h"
#import "iRosaAppDelegate.h"
#import "LoginViewController.h"
#import "DSActivityView.h"
#import "ocRosa.h"

@implementation FormsViewController

- (void)dealloc {
    [forms release];
    [detailController release];
    [addButton release];
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
    
    [addButton release];
    addButton = [[UIBarButtonItem alloc] 
                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                target:self
                                                action:@selector(addForm)];
                               
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSString *username;
    NSString *password;
    
    if ([LoginViewController authenticateFromKeychainUsername:&username andPassword:&password]) {
        
        [LoginViewController authenticateLocalDatabaseWithUsername:username
                                                       andPassword:password];
    } else {
        [LoginViewController showLoginModallyOverView:self];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Form Details

- (FormDetailViewController *)detailController {
    if (!detailController)
        detailController = [[FormDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    return detailController;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Get the list of Forms (id's only)
    [forms release];
    forms = [[UIAppDelegate.formManager getFormDBIDs] retain];
    
    [self.tableView reloadData];
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedRowIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
}


#pragma mark - Download Forms

- (void) addForm  {    
    
    [addButton setEnabled:NO];
    
    NSString *username;
    NSString *password;
    
    if (![LoginViewController authenticateFromKeychainUsername:&username andPassword:&password]) {
        [LoginViewController showLoginModallyOverView:self];
    }
    
    [DSActivityView activityViewForView:self.view withLabel:@"Downloading" width:140];
    
    id<OpenRosaServer> server = [[OPENROSA_SERVER alloc] init];
    server.delegate = self;
    server.username = username;
    server.password = password;
    [server requestFormList];
}

- (void)requestSuccessful:(id<OpenRosaServer>)server {

    FormDownloadViewController *download = [[FormDownloadViewController alloc] init];    
    download.xFormIDs = [NSArray arrayWithArray:server.xFormIDs];
    download.xFormNames = [NSArray arrayWithArray:server.xFormNames];

    [self.navigationController pushViewController:download animated:YES];
    [download release];
    [server release];
    
    [DSActivityView removeView];
    [addButton setEnabled:YES];

}

- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message {
    // Login failed
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [forms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Form *form = [[Form alloc] initWithDBID:[forms objectAtIndex:indexPath.row]
                                   database:UIAppDelegate.formManager.connection];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = form.title;
    
    [form release];
    
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.detailController.formDBID = [forms objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.detailController animated:YES];
}

@end
