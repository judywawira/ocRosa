//
//  EpiSurveyor.m
//  ocRosa
//
//  Created by Michael Willekes on 11-06-25.
//  Copyright 2011 n/a. All rights reserved.
//

#import "EpiSurveyor.h"

@implementation EpiSurveyor

@synthesize delegate;
@synthesize username, password, receivedData;

- (void)dealloc {
    self.username = nil;
    self.password = nil;
    self.receivedData = nil;
    [super dealloc];
}

- (void) login {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/AuthenticateLogin?id=%@&pwd=%@&version=2.3",
            self.username,
            self.password];
    
    [self requestWithURL:url];
}
     
- (void)requestFormList {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/GetFormList?userid=%@&pwd=%@&version=2.3&formtype=private",
            self.username,
            self.password];
    
    [self requestWithURL:url]; 
}

- (void)requestForm:(NSString *)xFormID {
    NSString *url = 
        [NSString stringWithFormat:@"http://episurveyor.org/GetSurveyForm?userId=%@&pwd=%@&version=2.3&formtype=private",
            self.username,
            self.password];
    
    [self requestWithURL:url];    
}

- (void) requestWithURL:(NSString *)url {

    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60];
    
    if ([NSURLConnection connectionWithRequest:theRequest delegate:self] == nil) {
        [self requestFailedWithMessage:@"Unable to initiate request"];
    }
}

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
    
    NSString *result = [NSString stringWithFormat:@"%.*s", [self.receivedData length], [self.receivedData bytes]];
    
    // From http://www.datadyne.org/episurveyor/api :
    // 600 = MOBILE_RESPONSE_SUCCESS_CODE. This is the most welcome code that signifies the
    // success of any action or request to the server for which do data response is expected
    // from the server. This code is returned for successful login, successful form data upload
    // and many more other successful operations.
    if ([result isEqualToString:@"600"]) {
        [self requestSuccessful];
    } else {
        // TODO: Better failure messages!
        [self requestFailedWithMessage:@"Failed!"];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self requestFailedWithMessage:[error localizedDescription]];
}

@end
