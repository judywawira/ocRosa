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

#import "RecordSubmitViewController.h"
#import "iRosaAppDelegate.h"
#import "LoginViewController.h"
#import "ocRosa.h"

@implementation RecordSubmitViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [records release];
    [forms release];
    [formManager release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the xForms FormManager
    [formManager release];
    formManager = [UIAppDelegate.formManager retain];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Our 'records' is a dictionary where
    //  key = form dbid
    //  value = array of completed records dbids
    [records release];
    records = [[NSMutableDictionary alloc] init];
    
    for (NSNumber *formDBID in [formManager getFormDBIDs]) {
        Form *form = [[Form alloc] initWithDBID:formDBID database:formManager.connection];

        NSInteger count = [[form countRecordsWithState:[NSNumber numberWithInt:kRecordState_Completed]] intValue];
        
        if (count > 0) { // Skip Forms with no completed records
            
            [records setObject:[form getRecordDBIDsWithState:[NSNumber numberWithInt:kRecordState_Completed]]
                        forKey:formDBID];
        }
        
        [form release];
    }
  
    // The 'records' dictionary now contains ids of all the completed records, keyed by formDBID
    // Our 'forms' array is a copy of the keys of 'records'
    [forms release];
    forms = [[records allKeys] retain];
    
    // The number of completed / submitted forms may have changed so rebuild the table
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [forms count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[records objectForKey:[forms objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Form *form = [[Form alloc] initWithDBID:[forms objectAtIndex:section] database:formManager.connection];
    NSString *title = [NSString stringWithString:form.title];
    [form release];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSNumber *formDBID = [forms objectAtIndex:indexPath.section];
    NSNumber *recordDBID = [[records objectForKey:formDBID] objectAtIndex:indexPath.row];
    
    Record *record = [[Record alloc] initWithDBID:recordDBID
                                         database:formManager.connection];
    
    // Main text is always the Date/Time the record date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:record.date]];
   
    [dateFormatter release];
    
    // Default Cell style is Black text, no acccessory
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (record.state == kRecordState_Completed) {
        cell.detailTextLabel.text = @"Tap to Submit";
        
    } else if (record.state == kRecordState_Completed) {
        cell.detailTextLabel.text = @"Submitted";
        
        // Make text grey and add a check-mark
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    [record release];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
    
        // Cell is not checked - which means that record is not submitted
        NSNumber *formDBID = [forms objectAtIndex:indexPath.section];
        NSNumber *recordDBID = [[records objectForKey:formDBID] objectAtIndex:indexPath.row];
        
        Form *form = [[Form alloc] initWithDBID:formDBID
                                       database:formManager.connection];
        
        Record *record = [[Record alloc] initWithDBID:recordDBID
                                             database:formManager.connection];
        
        // Add an Activity Indicator (spinner) to the cell while we're uploading 
        UIActivityIndicatorView *activityView = 
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [activityView startAnimating];
        cell.accessoryView = activityView;
        [activityView release];

        cell.detailTextLabel.text = @"Submitting";
        
        // Submit the Record
        id<OpenRosaServer> server = [[OPENROSA_SERVER alloc] init];
        server.delegate = self;
        server.username = username;
        server.password = password;
        
        [server submitRecord:record
                     forForm:form];
        
        //[record submitted];
        [record release];
        [form release];

    }
}

- (void)requestSuccessful:(id<OpenRosaServer>)server {

    NSUInteger section = [forms indexOfObject:server.submittedForm.dbid];
    NSUInteger row = [[records objectForKey:server.submittedForm.dbid] 
                        indexOfObject:server.submittedRecord.dbid];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // Make text grey and add a check-mark
    cell.detailTextLabel.text = @"Submitted";
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor grayColor];
    
    [server.submittedRecord submitted];
    [server release];
}

- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message {
    // Login failed
}


@end
