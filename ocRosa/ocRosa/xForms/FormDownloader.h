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

@class DatabaseConnection;

@interface FormDownloader : NSObject {
}

// Download the form. When download is complete, hand-off to parser
+ (BOOL)downloadAndParseFromURL:(NSURL *)url
                     toDatabase:(DatabaseConnection *)database
                          error:(NSError **)error;

+ (BOOL)loadAndParseFromFile:(NSString *)path
                  toDatabase:(DatabaseConnection *)database
                       error:(NSError **)error;

+ (NSNumber *)parseData:(NSData *)data
             toDatabase:(DatabaseConnection *)database
                  error:(NSError **)error;

@end
