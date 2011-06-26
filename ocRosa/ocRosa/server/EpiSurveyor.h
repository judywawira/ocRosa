//
//  EpiSurveyor.h
//  ocRosa
//
//  Created by Michael Willekes on 11-06-25.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenRosaServer.h"

@interface EpiSurveyor : NSObject <OpenRosaServer> {

    id <OpenRosaServerDelegate> delegate;

    NSMutableData *receivedData;
    
    NSString *username;
    
    NSString *password;
}

- (void)requestWithURL:(NSString *)url;

- (void)requestSuccessful;

- (void)requestFailedWithMessage:(NSString *)message;

@end
