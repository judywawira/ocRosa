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

extern NSString *const kDatabase_Error_Domain;
extern NSString *const kDatabase_Error_Message;
extern NSString *const kDatabase_Error_SQL;
extern NSString *const kDatabase_Error_Argument;

@class FMDatabase;
@class FMResultSet;

@interface DatabaseConnection : NSObject {
    FMDatabase *db;
}

@property (nonatomic, readonly) FMDatabase *db;

// Using the specified template, create a new encrypted database at the
// specified location. If the destination database already exists,
// this method does nothing.
+ (DatabaseConnection *)openEncryptedDatabase:(NSString *)encryptedDatabasePath 
                                 withTemplate:(NSString *)templateDatabasePath
                                   passphrase:(NSString *)key
                                        error:(NSError **)error;

// Using the specified template, create an unencrypted, in-memory database
+ (DatabaseConnection *)openInMemoryDatabaseWithTemplate:(NSString *)templateDatabasePath
                                                   error:(NSError **)error;

// Return the default path of the template database (which ships with the app-bundle)
+ (NSString *)getDefaultTemplateDatabasePath;

// Open the template database at the specified path
+ (FMDatabase *)openTemplateDatabaseAtPath:(NSString *)path
                                     error:(NSError **)error;

// Open a database at the specified path. If no database exists,
// one will be created. Return nil if the database cannot be open.
+ (FMDatabase *)openDatabaseAtPath:(NSString *)path
                             error:(NSError **)error;

// (SQLCipher) key the database. Return true if the operation was
// successful, false otherwise. If the database is a new, empty
// database (conains no pages) this will encrypt the database.
+ (BOOL)keyDatabase:(FMDatabase *)database
         passphrase:(NSString *)key
              error:(NSError **)error;

// The Schema is stored in an empty database that is shipped
// with the app. SQLCipher encryption has to be applied *before*
// any pages are written, so the way to create an encrypted database
// on the device is to create an empty database, encrypt it, then
// copy over the schema from an unencrypted template database.
+ (BOOL)copySchemaFromTemplate:(FMDatabase *)template_db
                    toDatabase:(FMDatabase *)target_db
                         error:(NSError **)error;

#pragma mark Errors

// Create a default NSError 
+ (NSError *)createError:(NSString *)description;

// Create an NSError. Add underlying SQLite error info
+ (NSError *)createError:(NSString *)description
             forDatabase:(FMDatabase *)database;

// Create an NSError. Add underlying SQLite error info
+ (NSError *)createError:(NSString *)description
                 fromSQL:(NSString *)sql
           withArguments:(NSArray *)arguments
             forDatabase:(FMDatabase *)database;

#pragma mark -

// Initialize a database connection with the encrypted SQLite database
// at the specified path. This database file must already exist. Use
// createEncryptedDatabaseFromTemplate:path:passphrase to create it.
- (id)initWithFMDatabase:(FMDatabase *)database;

// Number that represent that last-inserted auto increment row ID
- (NSNumber *)lastInsertRowID;

- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;

#pragma mark Convenience Operations

// Convenient wrappers around common SQLite operations

// Execute the SQL statment as a scalar (return no value)
// and return YES if the operation was successful
- (BOOL)executeScalar:(NSString *)sql
            arguments:(NSArray *)arguments
         errorMessage:(NSString *)message
                error:(NSError **)error;

// Execute the SQL statement and return the 'lastInsertRowID'
// if successful, or nil if failed
- (NSNumber *)executeInsert:(NSString *)sql
                  arguments:(NSArray *)arguments
               errorMessage:(NSString *)message
                      error:(NSError **)error;

#pragma mark -

- (FMResultSet *)resultSetFromQuery:(NSString *)sql
                          arguments:(NSArray *)arguments
                       errorMessage:(NSString *)message
                              error:(NSError **)error;

// Read a single string from the SQLite database by executing the SQL
// query and return the first result (first column of first record)
// as an NSString. Return nil if unsuccessful. Additional data in
// result-set (extra columns, rows) is ignored
- (NSString *)stringFromQuery:(NSString *)sql
                    arguments:(NSArray *)arguments
                 errorMessage:(NSString *)message
                        error:(NSError **)error;

// Read a single number from the SQLite database by executing the SQL
// query and return the first result (first column of first record)
// as an NSString. Return nil if unsuccessful. Additional data in
// result-set (extra columns, rows) is ignored
- (NSNumber *)numberFromQuery:(NSString *)sql
                    arguments:(NSArray *)arguments
                 errorMessage:(NSString *)message
                        error:(NSError **)error;

- (NSDate *)dateFromQuery:(NSString *)sql
                arguments:(NSArray *)arguments
             errorMessage:(NSString *)message
                    error:(NSError **)error;

- (NSData *)bufferFromQuery:(NSString *)sql
                  arguments:(NSArray *)arguments
               errorMessage:(NSString *)message
                      error:(NSError **)error;

// Read an array of 'dbids' form the SQLite database by executing the SQL
// query and returning the first column set as an NSArray. Return nil if
// unsuccessful. Additional data in result-set (extra columns) is ignored
- (NSArray *)numberArrayFromQuery:(NSString *)sql
                        arguments:(NSArray *)arguments
                     errorMessage:(NSString *)message
                            error:(NSError **)error;

- (NSArray *)stringArrayFromQuery:(NSString *)sql
                        arguments:(NSArray *)arguments
                     errorMessage:(NSString *)message
                            error:(NSError **)error;


@end
