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

@protocol OpenRosaServer <NSObject>

- (void)login;

- (void)requestFormList;

- (void)requestForm:(NSString *)xFormID;

- (void)submitRecord:(NSNumber *)recordDBD
         forFormName:(NSString *)formName
           forFormID:(NSString *)xFormID
        withContents:(NSString *)xFormXMLTree;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, assign) id delegate;

@end


// Implemented by client to respond to events
@protocol OpenRosaServerDelegate <NSObject>
- (void)requestSuccessful:(id<OpenRosaServer>)server;
- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message;
@end

