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

#import "DatabaseConnection.h"
#import "DatabaseOperations.h"
#import "FormDownloader.h"
#import "FormParser.h"
#import "Question.h"
#import "FormManager.h"

@implementation FormManager

+ (FormManager *)createTemporaryFormManager:(NSError **)error {
        
    NSString *templatePath = [DatabaseConnection getDefaultTemplateDatabasePath];
    DatabaseConnection *databaseConnection = [DatabaseConnection openInMemoryDatabaseWithTemplate:templatePath
                                                                                            error:error];
    
    return [[[FormManager alloc] initWithDatabase:databaseConnection] autorelease];
}

+ (FormManager *)createEncryptedFormManager:(NSString *)localStorageFilename
                                 passphrase:(NSString *)key 
                                      error:(NSError **)error {
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *targetPath = [documentsDirectory stringByAppendingPathComponent:localStorageFilename];
    
    NSString *templatePath = [DatabaseConnection getDefaultTemplateDatabasePath];
    
    DatabaseConnection *databaseConnection = [DatabaseConnection openEncryptedDatabase:targetPath
                                                                          withTemplate:templatePath
                                                                            passphrase:key
                                                                                 error:error]; 
    
    return [[[FormManager alloc] initWithDatabase:databaseConnection] autorelease];
}

- (id)initWithDatabase:(DatabaseConnection *)db {
    
    if (!(self = [super initWithDatabase:db]))
        return nil;
        
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)downloadAndParseFromURL:(NSURL *)url {
    
    return [FormDownloader downloadAndParseFromURL:url 
                                        toDatabase:connection
                                             error:&error];
}

#pragma mark Forms

- (NSNumber *)countForms {
    return [operations countForms:&error];
}

- (NSArray *)getFormDBIDs {
    return [operations getFormDBIDs:&error];
}

#pragma mark Records

- (NSNumber *)createRecordForForm:(NSNumber *)dbid {
    
    NSNumber *recordDBID = [operations createRecordForForm:(NSNumber *)dbid error:&error]; 
    
    // Initialize the set of (empty) Answer place-holders    
    [Question initializeEmptyAnswersForRecord:recordDBID
                              usingOperations:self.operations
                                        error:&error];
    
    return recordDBID;
}

@end
