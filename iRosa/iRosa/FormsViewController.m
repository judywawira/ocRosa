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
#import "ocRosa.h"

@implementation FormsViewController

- (void)dealloc {
    [formManager release];
    [forms release];
    [detailController release];
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
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] 
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                            target:self
                                                            action:@selector(addForm)];
                               
    
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    // Get the xForms FormManager
    [formManager release];
    formManager = [UIAppDelegate.formManager retain];
    
    // Get the list of Forms (id's only)
    [forms release];
    forms = [[formManager getFormDBIDs] retain];
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
    
    [forms release];
    forms = [[formManager getFormDBIDs] retain];
    
    [self.tableView reloadData];
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedRowIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
}


#pragma mark - Actions

- (void) addForm  {    
    FormDownloadViewController *download = [[FormDownloadViewController alloc] initWithFormManager:formManager];
    [self.navigationController pushViewController:download animated:YES];
    [download release];
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
                                   database:formManager.connection];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = form.title;
    
    [form release];
    
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.detailController.formManager = formManager;
    self.detailController.formDBID = [forms objectAtIndex:indexPath.row];
    self.detailController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:self.detailController animated:YES];
}

@end
