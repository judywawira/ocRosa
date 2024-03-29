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

// Replicate Java's DataOutputStream methods
- (void)writeUTF:(NSString *)value toBuffer:(NSMutableData *)buffer;
- (void)writeUTFDate:(NSDate *)date toBuffer:(NSMutableData *)buffer;

@end
