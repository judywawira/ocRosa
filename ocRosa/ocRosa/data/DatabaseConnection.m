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
#import "FMDatabase.h"

NSString *const kDatabase_Error_Domain      = @"Database";
NSString *const kDatabase_Error_Message     = @"SQLiteErrMsg";
NSString *const kDatabase_Error_SQL         = @"SQL";
NSString *const kDatabase_Error_Argument    = @"arg";

@implementation DatabaseConnection

@synthesize db;

+ (DatabaseConnection *)openInMemoryDatabaseWithTemplate:(NSString *)templateDatabasePath
                                                   error:(NSError **)error {
    
    // Open the template database
    FMDatabase *template_db = [self openTemplateDatabaseAtPath:templateDatabasePath
                                                         error:error];
    if (!template_db)
        return nil;  
    
    // Open the target In-Memory database
    FMDatabase *target_db = [self openDatabaseAtPath:@":memory:"
                                                  error:error];
    if (!target_db) {
        [template_db close];
        return nil;
    }
    
    // Copy schmea. 
    if (![self copySchemaFromTemplate:template_db toDatabase:target_db error:error]) {
        [template_db close];
        [target_db close];
        return nil;
    }
    
    [template_db close];
    
    return [[[DatabaseConnection alloc] initWithFMDatabase:target_db] autorelease];
}

+ (DatabaseConnection *)openEncryptedDatabase:(NSString *)encryptedDatabasePath 
                                 withTemplate:(NSString *)templateDatabasePath
                                   passphrase:(NSString *)key
                                        error:(NSError **)error {
    
    // Open the template database
    FMDatabase *template_db = [self openTemplateDatabaseAtPath:templateDatabasePath
                                                                       error:error];
    if (!template_db)
        return nil;  
    
    // Open the target (encrypted) database
    FMDatabase *encrypted_db = [self openDatabaseAtPath:encryptedDatabasePath
                                                  error:error];
    if (!encrypted_db) {
        [template_db close];
        return nil;
    }
        
    // Set the encryption Key
    if (![self keyDatabase:encrypted_db passphrase:key error:error]) {
        [template_db close];
        [encrypted_db close];
        return nil;
    }
    
    // Copy schmea. 
    if (![self copySchemaFromTemplate:template_db toDatabase:encrypted_db error:error]) {
        [template_db close];
        [encrypted_db close];
        return nil;
    }
    
    [template_db close];
    
    return [[[DatabaseConnection alloc] initWithFMDatabase:encrypted_db] autorelease];
}

+ (NSString *)getDefaultTemplateDatabasePath {
    return [[NSBundle mainBundle] pathForResource:@"ocRosa" ofType:@"sqlite"];    
}

+ (FMDatabase *)openTemplateDatabaseAtPath:(NSString *)path
                                     error:(NSError **)error {
    // Verify template database exists 
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        *error = [self createError:[NSString stringWithFormat:@"Template datebase '%@' does not exist", path]];
        return nil;
    }

    // Open the template database
    return [self openDatabaseAtPath:path error:error];
}

+ (FMDatabase *)openDatabaseAtPath:(NSString *)path
                             error:(NSError **)error {
    
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    if (![database open]) {
        *error = [self createError:[NSString stringWithFormat:@"Cannot open database '%@'", path] 
                       forDatabase:database];
        return nil;  
    }
    
    [database setBusyRetryTimeout:10]; 
    return database;
}

+ (BOOL)keyDatabase:(FMDatabase *)database
         passphrase:(NSString *)key 
              error:(NSError **)error {
    
    // Set the encryption Key
    if (![database setKey:key]) {
        *error = [self createError:@"Cannot key database"
                       forDatabase:database];
        return NO;
    }
    
    // Verify we succesfully keyed the encrypted database by executing a query
    [database executeQuery:@"SELECT count(*) FROM sqlite_master;"];
    if ([database hadError]) {
        *error = [self createError:@"Invalid key for datebase"
                       forDatabase:database];
        return NO;
    }    

    return YES;
}

+ (BOOL)copySchemaFromTemplate:(FMDatabase *)template_db
                    toDatabase:(FMDatabase *)target_db
                         error:(NSError **)error {
                            
    // Create the schema in the target database by copying the sqlite_master table
    FMResultSet *rs = [template_db executeQuery:@"SELECT sql FROM sqlite_master ORDER BY rowid;"];
    if (!rs) {
        *error = [self createError:@"Cannot read schema from template database"
                       forDatabase:template_db];
        return NO;
    }
                            
    while ([rs next]) {
        if (![target_db executeUpdate:[rs stringForColumn:@"sql"]]) {
            *error = [self createError:@"Cannot create schema in target database"
                           forDatabase:target_db];
            [rs close];
            return NO;
        }
    }
    
    [rs close];
    return YES;
}

#pragma mark Errors

+ (NSError *)createError:(NSString *)description {
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:description 
               forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:kDatabase_Error_Domain 
                               code:0
                           userInfo:details];
}


+ (NSError*)createError:(NSString *)description
            forDatabase:(FMDatabase *)database {
    
    if (![database hadError])
        return [self createError:description];
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:description 
               forKey:NSLocalizedDescriptionKey];
    
    [details setValue:[database lastErrorMessage] 
               forKey:kDatabase_Error_Message];
    
    return [NSError errorWithDomain:kDatabase_Error_Domain 
                               code:[database lastErrorCode]
                           userInfo:details];
}

// Create an NSError. Add underlying SQLite error info
+ (NSError *)createError:(NSString *)description
                 fromSQL:(NSString *)sql
           withArguments:(NSArray *)arguments
             forDatabase:(FMDatabase *)database {
    
    if (![database hadError])
        return [self createError:description];
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:description 
               forKey:NSLocalizedDescriptionKey];
    
    [details setValue:[database lastErrorMessage] 
               forKey:kDatabase_Error_Message];
    
    [details setValue:sql
               forKey:kDatabase_Error_SQL];
    
    for (int i = 0; i < [arguments count]; i++)
        [details setValue:[arguments objectAtIndex:i]
                   forKey:[NSString stringWithFormat:@"%@%d", kDatabase_Error_Argument, i]];
    
    return [NSError errorWithDomain:kDatabase_Error_Domain 
                               code:[database lastErrorCode]
                           userInfo:details];
}

#pragma mark -

- (id)initWithFMDatabase:(FMDatabase *)database {
 
    if (!(self = [super init]))
        return nil;
    
    db = [database retain];
    
    return self;
}

- (void)dealloc {
    [db release];
    [super dealloc];
}

#pragma mark -

- (NSNumber *)lastInsertRowID {
    return [NSNumber numberWithLongLong:[db lastInsertRowId]];
}

- (BOOL)beginTransaction {
    return [db beginTransaction];
}

- (BOOL)commit {
    return [db commit];
}

- (BOOL)rollback {
    return [db rollback];
}

#pragma mark Convenience Operations

- (BOOL)executeScalar:(NSString *)sql
            arguments:(NSArray *)arguments
         errorMessage:(NSString *)message
                error:(NSError **)error {
    
    if ([db executeUpdate:sql withArgumentsInArray:arguments])
        return YES;
    
    *error = [DatabaseConnection createError:message
                                     fromSQL:sql
                               withArguments:arguments
                                 forDatabase:db];
    return NO;
}

- (NSNumber *)executeInsert:(NSString *)sql
                  arguments:(NSArray *)arguments
               errorMessage:(NSString *)message
                      error:(NSError **)error {
    
    if ([db executeUpdate:sql withArgumentsInArray:arguments])
        return [self lastInsertRowID];    
    
    *error = [DatabaseConnection createError:message
                                     fromSQL:sql
                               withArguments:arguments
                                 forDatabase:db];
    return nil;
}

#pragma mark -

- (FMResultSet *)resultSetFromQuery:(NSString *)sql
                          arguments:(NSArray *)arguments
                       errorMessage:(NSString *)message
                              error:(NSError **)error {
    
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:arguments];
    if (!rs) {
        *error = [DatabaseConnection createError:message
                                         fromSQL:sql
                                   withArguments:arguments
                                     forDatabase:db];
        return nil;
    }
    return rs;
}

- (NSString *)stringFromQuery:(NSString *)sql
                    arguments:(NSArray *)arguments
                 errorMessage:(NSString *)message
                        error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    // Even though we're only getting the first row from the result,
    // FMBD doesn't call sqlite3_step() until will call 'next'
    [rs next];
    
    NSString *result = ([rs columnIndexIsNull:0])
                        ? nil
                        : [NSString stringWithString:[rs stringForColumnIndex:0]];
    
    [rs close];
    return result;
}

- (NSNumber *)numberFromQuery:(NSString *)sql
                    arguments:(NSArray *)arguments
                 errorMessage:(NSString *)message
                        error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    [rs next];  // sqlite3_step()
    
    NSNumber *result = ([rs columnIndexIsNull:0])
                        ? nil
                        : [NSNumber numberWithLongLong:[rs longLongIntForColumnIndex:0]];
    
    [rs close];
    return result;
}

- (NSDate *)dateFromQuery:(NSString *)sql
              arguments:(NSArray *)arguments
           errorMessage:(NSString *)message
                  error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    [rs next];  // sqlite3_step()
    
    NSDate *result = ([rs columnIndexIsNull:0])
                        ? nil
                        : [rs dateForColumnIndex:0];
    
    [rs close];
    return result;   
}

- (NSData *)bufferFromQuery:(NSString *)sql
                  arguments:(NSArray *)arguments
               errorMessage:(NSString *)message
                      error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    [rs next];  // sqlite3_step()
    
    NSData *result = ([rs columnIndexIsNull:0])
                        ? nil
                        : [rs dataForColumnIndex:0];
    
    [rs close];
    return result;
}

- (NSArray *)numberArrayFromQuery:(NSString *)sql
                        arguments:(NSArray *)arguments
                     errorMessage:(NSString *)message
                            error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([rs next]) {
        [result addObject:([rs columnIndexIsNull:0])
                            ? nil
                            : [NSNumber numberWithLongLong:[rs longLongIntForColumnIndex:0]]];
    }
    
    [rs close];
    return [NSArray arrayWithArray:result]; // Return immutable copy
}

- (NSArray *)stringArrayFromQuery:(NSString *)sql
                        arguments:(NSArray *)arguments
                     errorMessage:(NSString *)message
                            error:(NSError **)error {
    
    FMResultSet *rs = [self resultSetFromQuery:sql arguments:arguments errorMessage:message error:error];
    if (!rs)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([rs next]) {        
        [result addObject:([rs columnIndexIsNull:0])
                            ? nil
                            : [rs stringForColumnIndex:0]];
    }
    
    [rs close];
    return [NSArray arrayWithArray:result]; // Return immutable copy
}

@end
