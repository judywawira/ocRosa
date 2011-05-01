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
#import "DataClass.h"

@class Form;

@interface FormManager : DataClass {
}

// Create a temporary FormManager. Fully functional, but
// all data is unencrypted and in-memory
+ (FormManager *)createTemporaryFormManager:(NSError **)error;

// Create a FormManager that uses a local, encrypted datastore
+ (FormManager *)createEncryptedFormManager:(NSString *)localStorageFilename
                                 passphrase:(NSString *)key
                                      error:(NSError **)error;

- (id)initWithDatabase:(DatabaseConnection *)db;

#pragma mark Load and Parse

- (BOOL)downloadAndParseFromURL:(NSURL *)url;

- (BOOL)loadAndParseFromTile:(NSString *)path;

- (BOOL)readAndParseFromBuffer:(NSData *)data
                originalSource:(NSString *)source;

#pragma mark Forms

// Count number of downloaded and parsed forms
- (NSNumber *)countForms;
 
// Return an array of form dbids (NSNumbers) 
- (NSArray *)getFormDBIDs;

#pragma mark Records

// Create an new Record (result) for the specified Form.
// Return the new Record's dbid or nil if there was a problem.
- (NSNumber *)createRecordForForm:(NSNumber *)dbid;


@end

