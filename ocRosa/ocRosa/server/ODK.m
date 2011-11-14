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

#import "ODK.h"
#import "ASIHTTPRequest.h"
#import "Record.h"
#import "RecordXML.h"
#import "Form.h"

//NSInteger const kOpenRosaServer_Request_Login       = 1;
//NSInteger const kOpenRosaServer_Request_FormList    = 2;
//NSInteger const kOpenRosaServer_Request_Form        = 3;
//NSInteger const kOpenRosaServer_Request_Submit      = 4;

// Constants from http://www.datadyne.org/episurveyor/api
static NSString * const kMOBILE_RESPONSE_ERROR_IN_DOWNLOAD                  = @"400";
static NSString * const kMOBILE_RESPONSE_SURVEYNOTEXIST                     = @"401";
static NSString * const kMOBILE_RESPONSE_NODOWNLOAD_PERMISSION              = @"402";

static NSString * const kMOBILE_RESPONSE_SUCCESS_CODE                       = @"600";
static NSString * const kMOBILE_RESPONSE_TYPE_INVALIDUSER                   = @"601";
static NSString * const kMOBILE_RESPONSE_TYPE_DBERROR                       = @"602";
static NSString * const kMOBILE_RESPONSE_TYPE_SURVEYNOTEXIST                = @"603";
static NSString * const kMOBILE_RESPONSE_TYPE_USER_NEW                      = @"604";
static NSString * const kMOBILE_RESPONSE_TYPE_NO_DOWNLOAD_PERMISSION        = @"605";
static NSString * const kMOBILE_RESPONSE_TYPE_INVALID_FIELDS                = @"606";

static NSString * const kMOBILE_RESPONSE_TYPE_USER_VALID                    = @"700";
static NSString * const kMOBILE_RESPONSE_TYPE_INVALIDUSER_FOR_FORMLIST      = @"701";
static NSString * const kMOBILE_RESPONSE_TYPE_DBERROR_FOR_FORMLIST          = @"702";
static NSString * const kMOBILE_RESPONSE_TYPE_SURVEYNOTEXIST_FOR_FORMLIST   = @"703";

@implementation ODK

@synthesize delegate;
@synthesize requestType, username, password, xFormIDs, xFormNames, receivedData;
@synthesize requestedFormID, submittedRecord, submittedForm;

- (void)dealloc {
    self.username = nil;
    self.password = nil;
    self.xFormIDs = nil;
    self.xFormNames = nil;
    self.receivedData = nil;
    self.submittedRecord = nil;
    self.submittedForm = nil;
    [super dealloc];
}

#pragma mark OpenRosaServer Methods

- (void) login {
    ASIHTTPRequest *theRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/ODKAggregate/local_login.html"]];
	[theRequest setDelegate:self];
    [theRequest setUsername:username];
    [theRequest setPassword:password];
	[theRequest setDidFinishSelector:@selector(loginRequestFinished:)];
    [theRequest startAsynchronous];
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request {
    [request setUsername:username];
    [request setPassword:password];
    [request retryUsingSuppliedCredentials];
}

- (void)proxyAuthenticationNeededForRequest:(ASIHTTPRequest *)request {
    [request setProxyUsername:username];
    [request setProxyPassword:password];
    [request retryUsingSuppliedCredentials];
}

- (void)requestFormList {
    self.requestType = kOpenRosaServer_Request_FormList;
    [self login];
}

- (void)doRequestFormList {
    NSString *url = @"http://localhost:8080/ODKAggregate/formList";
    [self requestWithURL:url]; 
}

- (void)requestForm:(NSString *)xFormID {
    self.requestedFormID = xFormID;
    self.requestType = kOpenRosaServer_Request_Form;
    [self login];    
}

- (void)doRequestForm {
    NSString* url = [NSString stringWithFormat:@"http://localhost:8080/ODKAggregate/formXml?formId=%@", self.requestedFormID];
    [self requestWithURL:url];
}

- (void)submitRecord:(Record *)record
             forForm:(Form *)form {
    
    self.submittedRecord = record;
    self.submittedForm = form;
    
    self.requestType = kOpenRosaServer_Request_Submit;
    
    NSString *url = 
    [NSString stringWithFormat:@"http://episurveyor.org/UploadRecordsNew?version=2.3"];  
    
    
    // Note: we're creating a mutable request so we can change the HTTPBody buffer
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:60];
    /*
     The EpiSurveyor API docs: http://www.datadyne.org/episurveyor/api
     
     "The client uses the DataOutputStream to write the records to the server."
     
     */
    
    NSMutableData *data = [NSMutableData data];    
    
    [self writeUTF:self.username toBuffer:data];    
    [self writeUTF:self.password toBuffer:data];
    [self writeUTF:form.serverID toBuffer:data];
    [self writeUTFDate:record.completeDate toBuffer:data];
    [self writeUTF:@"0" toBuffer:data];
    [self writeUTF:[record.xml xmlString] toBuffer:data];
    
    //long long tempy = 0x7FF8000000000000L;
    long long tempy = 0x0000000000000000L;
    [data appendBytes:&tempy length:sizeof(long long)];
    [data appendBytes:&tempy length:sizeof(long long)];
    
    [self writeUTF:@"2.6" toBuffer:data];
    [self writeUTF:@"a6393b90-6694-42a3-9ff8-c2d91ea9e66c" toBuffer:data];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:data];
    [theRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    if ([NSURLConnection connectionWithRequest:theRequest delegate:self] == nil) {
        [self requestFailedWithMessage:@"Unable to initiate request"];
    }
}

// Simulate Java DataOutputStream.writeUTF()
- (void)writeUTF:(NSString *)value toBuffer:(NSMutableData *)buffer {
    
    // Convert 'value' to a UTF8 buffer
    NSData *utfData = [value dataUsingEncoding:NSUTF8StringEncoding];
    uint16_t utfDataSize = (uint16_t)[utfData length];
    
    // Write 2 bytes which number of bytes in string to follow
    uint16_t size = htons(utfDataSize);
    [buffer appendBytes:&size length:sizeof(uint16_t)];
    
    // Write Buffer
    [buffer appendData:utfData];
}

- (void)writeUTFDate:(NSDate *)date toBuffer:(NSMutableData *)buffer {
    
    // Date Format Expected: 2011-07-01 13:35:53
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self writeUTF:[dateFormatter stringFromDate:date] toBuffer:buffer];
    [dateFormatter release];
}

#pragma mark ---

- (void)requestWithURL:(NSString *)url {
        
    ASIHTTPRequest *theRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	
    [theRequest setUseKeychainPersistence:false]; // We've implemented our own Keychain access
	[theRequest setDelegate:self];
	[theRequest setShouldPresentAuthenticationDialog:false];
    [theRequest setUsername:username];
    [theRequest setPassword:password];
	[theRequest startAsynchronous];
}

#pragma mark OpenRosaServerDelegate Responders

- (void)requestSuccessful {
    if([[self delegate] respondsToSelector:@selector(requestSuccessful:)]) {
        [[self delegate] requestSuccessful:self];
    }
}

- (void)requestFailedWithMessage:(NSString *)message {
    if([[self delegate] respondsToSelector:@selector(requestFailed:)]) {
        [[self delegate] requestFailed:self withMessage:message];
    }  
}

#pragma mark NSXMLParser Delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *) qualifiedName 
    attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"forms"]) {
        
        [xFormIDs release];
        xFormIDs = [[NSMutableArray alloc] init];
        
        [xFormNames release];
        xFormNames = [[NSMutableArray alloc] init];
        
    } else if ([elementName isEqualToString:@"form"]) {
        
        [currentXMLString setString:@""];
        
        // The form element looks like this:
        // <form url="http://localhost:8080/ODKAggregate/formXml?formId=build_Test-Form-001_1319933414">Test Form 001</form>
        // We want the form ID "build_Test-Form-001_1319933414"
        
        // Even though we have the url, we extract just the ID
        NSString *url = [attributeDict objectForKey:@"url"];
        NSRange formIDRange = [url rangeOfString:@"formId=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [url length])];
        if (formIDRange.location != NSNotFound) {

            int pos = formIDRange.location + 7;
            NSString *formID = [url substringFromIndex:pos];
            [xFormIDs addObject:formID];
            
        } else {
            // Use the entire URL as the ID
            [xFormIDs addObject:[attributeDict objectForKey:@"url"]];

        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"form"]) {
        [xFormNames addObject:[NSString stringWithString:currentXMLString]];
        
    } else if ([elementName isEqualToString:@"forms"]) {
        [self requestSuccessful];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentXMLString appendString:string];
}

#pragma mark NSURLConnection Delegates

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Failed");
}

- (void)loginRequestFinished:(ASIHTTPRequest *)request {
    if (self.requestType == kOpenRosaServer_Request_FormList) {
        [self doRequestFormList];
    } else if (self.requestType == kOpenRosaServer_Request_Form) { 
        [self doRequestForm];
    } else {
        [self requestSuccessful];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
        
    self.receivedData = nil;
    self.receivedData = [NSData dataWithData:[request responseData]];
        
    if ([self.receivedData length] == 3) {
        NSString *result = [NSString stringWithFormat:@"%.*s", [receivedData length], [receivedData bytes]];
        if ([result isEqualToString:@"600"]) {
            [self requestSuccessful];
            return;
        } else {
            // TODO: Better failure messages!
            [self requestFailedWithMessage:@"Failed!"];
            return;
        }
    }
    
    if (self.requestType == kOpenRosaServer_Request_FormList) {
        currentXMLString = [NSMutableString string];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];
        parser.delegate = self;
        [parser parse];
        [parser release];
    } else {
        [self requestSuccessful];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self requestFailedWithMessage:[error localizedDescription]];
}

@end
