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

#import "FormDownloader.h"
#import "FormParser.h"
#import "DatabaseOperations.h"
#import "DatabaseConnection.h"

@implementation FormDownloader

+ (BOOL)downloadAndParseFromURL:(NSURL *)formURL toDatabase:(DatabaseConnection *)database error:(NSError **)error {
        
    NSURLRequest *request = [NSURLRequest requestWithURL:formURL];
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    if (!data) {
        return NO;
    }
    
    NSNumber *formID = [self parseData:data toDatabase:database error:error];
    if (!formID) {
        return NO;
    }
    
    DatabaseOperations *ops = [[DatabaseOperations alloc] initWithDatabase:database];
    if (![ops setFormURL:formURL form:formID error:error]) {
        return NO;
    }
    
    [ops release];
    return YES;
}

+ (BOOL)loadAndParseFromFile:(NSString *)path toDatabase:(DatabaseConnection *)database error:(NSError **)error {
    // TODO: implement this!
    return NO; 
}

+ (NSNumber *)parseData:(NSData *)data toDatabase:(DatabaseConnection *)database error:(NSError **)error {

    // Parse within a transaction... It's faster and if anything goes wrong
    // we'll roll-back
    [database beginTransaction];
    
    FormParser *parser = [[FormParser alloc] initWithDatabase:database];    
    NSNumber *formID = [parser parse:data];
    if (!formID) {
        *error = [parser error];
    }
    [parser release];
    
    DatabaseOperations *ops = [[DatabaseOperations alloc] initWithDatabase:database];
    
    // Once parsing is complete set the date to 'now' and dump the bytestream into the database
    if (formID 
        && [ops setFormDate:[NSDate date] form:formID error:error]
        && [ops setFormContents:data form:formID error:error]
        ) {
        [database commit];      // Everything went well
    } else {
        [database rollback];    // Oh noes!
    }
    
    [ops release];
                   
    // If parsing was successful, 'formID' will be the dbid of the newly parsed form
    // or nil if parsing was unsuccessful 
    return formID;
}



@end
