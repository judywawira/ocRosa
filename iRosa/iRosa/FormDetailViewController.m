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

#import "FormDetailViewController.h"
#import "QuestionsViewController.h"
#import "RecordsViewController.h"
#import "iRosaAppDelegate.h"
#import "ocRosa.h"

@implementation FormDetailViewController

@synthesize formDBID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.formDBID = nil;
    [form release];
    
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

    
    // "+" button to create a new Record
    UIBarButtonItem *button = [[UIBarButtonItem alloc] 
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                               target:self
                               action:@selector(addRecord)];
    
    
    self.navigationItem.rightBarButtonItem = button;
    [button release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {

    // formDBID and formManager are assigned when a cell is selected
    // in FormViewController
    [form release];
    form = [[Form alloc] initWithDBID:formDBID
                             database:UIAppDelegate.formManager.connection];
    
    [self.tableView reloadData];
    
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

#pragma mark - Questions

- (QuestionsViewController *)questionsController {
    if (!questionsController)
        questionsController = [[QuestionsViewController alloc] initWithStyle:UITableViewStylePlain];
    
    return questionsController;
}

- (void) addRecord  {
    // Create a new, empty record
    NSNumber *recordDBID = [UIAppDelegate.formManager createRecordForForm:formDBID];
    
    self.questionsController.formTitle = form.title;
    self.questionsController.formDetails = self;

    Record *record= [[Record alloc] initWithDBID:recordDBID
                                        database:UIAppDelegate.formManager.connection];
    self.questionsController.record = record;
    [record release];
    
    [self.navigationController pushViewController:self.questionsController animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 2 sections
    //  - Form summary details
    //  - Records
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 3;
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"Records";
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // In this table view we are only ever showing a small (< 5) number of cells,
    // and they are created with different styles - so we won't dequeueReusableCell
    UITableViewCell *cell;
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (section) {
            
        case 0: // Details Section
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;    // Info only - can't select
            
            switch (row) {
                
                case 0:
                    cell.textLabel.text = @"Title";
                    cell.detailTextLabel.text = form.title;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Size";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Questions", form.questionCount];
                    break;
                
                case 2:
                    cell.textLabel.text = @"Date";
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    cell.detailTextLabel.text = [dateFormatter stringFromDate:form.downloadDate];
                    [dateFormatter release];
                    break;
                    
                case 3:
                    cell.textLabel.text = @"GPS";
                    cell.detailTextLabel.text = @"Yes";
                    break;
                    
            }
            break;

        case 1: // Records Section
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (row) {
                    
                case 0:
                    cell.textLabel.text = @"In-Progress";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
                                                  [form countRecordsWithState:
                                                    [NSNumber numberWithInt:kRecordState_InProgress]]];
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Completed";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
                                                  [form countRecordsWithState:
                                                    [NSNumber numberWithInt:kRecordState_Completed]]];
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Submitted";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
                                                  [form countRecordsWithState:
                                                    [NSNumber numberWithInt:kRecordState_Submitted]]];
                    break;
            }
            
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (1 == [indexPath section]) {
     
        // Create and push a RecordsViewController onto our navigation stack. Depending on which
        // cell was selected ('in-progress', 'completed' or 'submitted') fetch the appropriate list
        // of Records
        RecordsViewController *recordsController = [[RecordsViewController alloc] initWithStyle:UITableViewStylePlain];
        
        NSInteger row = [indexPath row];  
            
        switch (row) {
                    
            case 0:
                recordsController.title = @"In-Progress";
                recordsController.state = [NSNumber numberWithInt:kRecordState_InProgress];
                break;
                    
            case 1:
                recordsController.title = @"Completed";
                recordsController.state = [NSNumber numberWithInt:kRecordState_Completed];
                break;
                    
            case 2:
                recordsController.title = @"Submitted";
                recordsController.state = [NSNumber numberWithInt:kRecordState_Submitted];                    
                break;
        }
        
        recordsController.form = form;
        recordsController.formDetails = self;
        
        [self.navigationController pushViewController:recordsController animated:YES];
        [recordsController release];
        
    }

}

@end
