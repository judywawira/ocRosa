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
#import "ocRosa.h"

@implementation RemoteForm

@synthesize surveyID, surveyName, surveyOwner;

- (void)dealloc {
    surveyID = nil;
    surveyName = nil;
    surveyOwner = nil;
    [super dealloc];
}

@end

@implementation FormDownloadViewController

@synthesize currentXMLString, currentRemoteForm;

- (id)initWithFormManager:(FormManager *)manager {
    
    if (!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    formManager = [manager retain];
    
    remoteForms = [[NSMutableArray alloc] initWithCapacity:12];
    
    return self;  
}

- (void)dealloc {
    [formManager release];
    [remoteForms release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Download Form List

- (void)downloadRemoteFormList {
    NSURL *downloadURL = [NSURL URLWithString:@"https://www.episurveyor.org/api/surveys"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"username=mikewillekes@gmail.com&accesstoken=Dqf2XspqOJhT9M8khj3o";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    self.currentXMLString = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *) qualifiedName 
                                          attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"Survey"]) {
        self.currentRemoteForm = [[RemoteForm alloc] init];
    } else {
        [currentXMLString setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"SurveyId"]) {
        currentRemoteForm.surveyID = currentXMLString;
        
    } else if ([elementName isEqualToString:@"SurveyName"]) {
        currentRemoteForm.surveyName = currentXMLString;
    
    } else if ([elementName isEqualToString:@"Owner"]) {
        currentRemoteForm.surveyOwner= currentXMLString;
    
    } else if ([elementName isEqualToString:@"Survey"]) {
        [remoteForms addObject:currentRemoteForm];
        self.currentRemoteForm = nil;        
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentXMLString appendString:string];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Download Forms";
    [self downloadRemoteFormList];
    
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
    return [remoteForms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    RemoteForm *form = [remoteForms objectAtIndex:indexPath.row];
    cell.textLabel.text = form.surveyName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    RemoteForm *form = [remoteForms objectAtIndex:indexPath.row];
    
    // TODO: Obviously hard-coding to download a single form from Dropbox is not the correct solution :-)
    NSString *url = 
        [NSString stringWithFormat:@"http://dl.dropbox.com/u/7669704/DisabilitySurvey2_SurveySpec_2011_04_05.xhtml",
            form.surveyID];
    
    NSError *error = nil;
    if (![formManager downloadAndParseFromURL:[NSURL URLWithString:url]]) {
        
        error = [formManager error];
        DLog(@"%@",[error localizedDescription]);
    }
    
    
    // We download one form at a time... pop back to the root
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
