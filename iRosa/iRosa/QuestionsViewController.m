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

#import "QuestionsViewController.h"
#import "QuestionController.h"
#import "QuestionController_iPhone.h"
#import "ocRosa.h"

@implementation QuestionsViewController

@synthesize formTitle, record, formDetails;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.formDetails = nil;
    [record release];
    [questions release];
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
}

- (void)done {
    [self.record complete];    
    [self.navigationController popToViewController:(UITableViewController*)self.formDetails
                                          animated:YES];
}

- (void)edit {
    [self.record inProgress];    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(done)];          
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    [self.tableView reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"Record %@", record.dbid];
    
    // If the Record state is "In-Progress" show a "Done" button,
    // or if the Record state is "Complete" or "Submitted" show an "Edit" button
    if (record.state == kRecordState_InProgress) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(done)];          
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    } else {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(edit)];  
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }
    
    // Get the list of Questions (id's only)
    [questions release];
    questions = [record.questions retain];
    
    [self.tableView reloadData];

    // Reset scroll position to top 
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [self.record recalculateGlobalQuestionState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    
    // The main text is the Question
    cell.textLabel.textColor = [UIColor blackColor];
    if ([record isRequired:indexPath.row]) {
        // Add a "*" if the question is required
        cell.textLabel.text = [NSString stringWithFormat:@"* %@", [record getLabel:indexPath.row]];
    } else {
        cell.textLabel.text = [record getLabel:indexPath.row];
    }

    // Skip or not?
    if ([record isRelevant:indexPath.row]) {
        // Questions is relevant
        
        if (record.state == kRecordState_InProgress) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType  = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            
        // If the question has an answer
        if ([record isAnswered:indexPath.row]) {
            cell.detailTextLabel.text = [record getAnswer:indexPath.row];
        } else {
            cell.detailTextLabel.text = @"";
        }
        
    } else {
        // Question is not relevant (will be skipped)
        cell.detailTextLabel.text = @""; // If there's an answer - clear it
        cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.textColor                = [UIColor grayColor];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([record isRelevant:indexPath.row]) {
       
        QuestionController *questionController = [[QuestionController_iPhone alloc] initWithNibName:nil bundle:nil];
    
        // Set all of the necessary properties of the questionController
        questionController.record = record;
        questionController.control = [record getControl:indexPath.row];
        questionController.controlIndex = indexPath.row;
        questionController.formTitle = self.formTitle;
        questionController.formDetails = self.formDetails; // So we can pop back to 'FormDetails' when done
    
        [self.navigationController pushViewController:questionController animated:YES];
        [questionController release];
    }
}

@end
