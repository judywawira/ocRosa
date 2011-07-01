//
//  EpiSurveyor.m
//  ocRosa
//
//  Created by Michael Willekes on 11-06-25.
//  Copyright 2011 n/a. All rights reserved.
//

#import "EpiSurveyor.h"
#import "Record.h"
#import "RecordXML.h"
#import "Form.h"

NSInteger const kOpenRosaServer_Request_Login       = 1;
NSInteger const kOpenRosaServer_Request_FormList    = 2;
NSInteger const kOpenRosaServer_Request_Form        = 3;
NSInteger const kOpenRosaServer_Request_Submit      = 4;

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

@implementation EpiSurveyor

@synthesize delegate;
@synthesize requestType, username, password, receivedData, xFormIDs, xFormNames;

- (void)dealloc {
    self.username = nil;
    self.password = nil;
    self.xFormIDs = nil;
    self.xFormNames = nil;
    self.receivedData = nil;
    [super dealloc];
}

#pragma mark OpenRosaServer Methods

- (void) login {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/AuthenticateLogin?id=%@&pwd=%@&version=2.3",
            self.username,
            self.password];
    
    self.requestType = kOpenRosaServer_Request_Login;
    [self requestWithURL:url];
}
     
- (void)requestFormList {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/GetFormList?userid=%@&pwd=%@&version=2.3&formtype=private",
            self.username,
            self.password];
    
    self.requestType = kOpenRosaServer_Request_FormList;
    [self requestWithURL:url]; 
}

- (void)requestForm:(NSString *)xFormID {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/GetSurveyForm?userId=%@&pwd=%@&version=2.3&formId=%@",
            self.username,
            self.password,
            xFormID];
    
    self.requestType = kOpenRosaServer_Request_Form;
    [self requestWithURL:url];    
}

- (void)submitRecord:(Record *)record
             forForm:(Form *)form {
    
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/UploadRecordsNew?version=2.3"];  
    
    self.requestType = kOpenRosaServer_Request_Submit;
    
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

    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60];
    
    if ([NSURLConnection connectionWithRequest:theRequest delegate:self] == nil) {
        [self requestFailedWithMessage:@"Unable to initiate request"];
    }
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
    
    if ([elementName isEqualToString:@"formlist"]) {
        
        [xFormIDs release];
        xFormIDs = [[NSMutableArray alloc] init];
        
        [xFormNames release];
        xFormNames = [[NSMutableArray alloc] init];
        
    } else if ([elementName isEqualToString:@"form"]) {
    
        [currentXMLString setString:@""];
        [xFormIDs addObject:[attributeDict objectForKey:@"formid"]];
        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"form"]) {
        [xFormNames addObject:[NSString stringWithString:currentXMLString]];
        
    } else if ([elementName isEqualToString:@"formlist"]) {
        [self requestSuccessful];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentXMLString appendString:string];
}

#pragma mark NSURLConnection Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    
    if (statusCode < 400) {
        
        // Response was successful
        long long contentLength = [response expectedContentLength];
        if (contentLength == NSURLResponseUnknownLength) {
            contentLength = 500000;
        }
        self.receivedData = [NSMutableData dataWithCapacity:(NSUInteger)contentLength];
    
    } else {
        
        self.receivedData = nil;
        
        // TODO: Better failure messages!
        [self requestFailedWithMessage:@"Failed!"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
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
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.receivedData];
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

/*
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSString *foo = protectionSpace.authenticationMethod;
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSArray *trustedHosts = [NSArray arrayWithObjects:@"episurveyor.org", nil];

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
 
 */
@end
