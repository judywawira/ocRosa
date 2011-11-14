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

//#define OPENROSA_SERVER EpiSurveyor
#define OPENROSA_SERVER ODK

#import <Foundation/Foundation.h>

extern NSInteger const kOpenRosaServer_Request_Login;
extern NSInteger const kOpenRosaServer_Request_FormList;
extern NSInteger const kOpenRosaServer_Request_Form;
extern NSInteger const kOpenRosaServer_Request_Submit;

@class Record;
@class Form;

@protocol OpenRosaServer <NSObject>

- (void)login;

- (void)requestFormList;

- (void)requestForm:(NSString *)xFormID;

- (void)submitRecord:(Record *)record
             forForm:(Form *)form;

@property (nonatomic) NSInteger requestType;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, retain) NSData *receivedData;

// After requesting the FormList, this is an array of remote xForm IDs
// Order matches xFormsNames
@property (nonatomic, retain) NSMutableArray *xFormIDs;

// After requesting the FormList, this is an array of remote xForm names
// Order matches xFormIDs
@property (nonatomic, retain) NSMutableArray *xFormNames;

@property (nonatomic, assign) id delegate;

// Most-recently submitted Record
@property (nonatomic, retain) Record *submittedRecord;

// Most-recently submitted Form
@property (nonatomic, retain) Form *submittedForm;

@end

// Implemented by client to respond to events
@protocol OpenRosaServerDelegate <NSObject>
- (void)requestSuccessful:(id<OpenRosaServer>)server;
- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message;
@end

