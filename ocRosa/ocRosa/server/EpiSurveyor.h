//
//  EpiSurveyor.h
//  ocRosa
//
//  Created by Michael Willekes on 11-06-25.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenRosaServer.h"

@interface EpiSurveyor : NSObject <OpenRosaServer, NSXMLParserDelegate> {

    id <OpenRosaServerDelegate> delegate;

    NSInteger requestType;
    
    NSString *username;
    
    NSString *password;
    
    NSMutableData *receivedData;

    NSMutableArray *xFormIDs;
    NSMutableArray *xFormNames;
    NSMutableString *currentXMLString;
}

- (void)requestWithURL:(NSString *)url;

- (void)requestSuccessful;

- (void)requestFailedWithMessage:(NSString *)message;

@end
