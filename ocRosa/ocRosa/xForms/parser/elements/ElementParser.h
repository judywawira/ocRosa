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

@class DatabaseOperations;

@interface ElementParser : NSObject {
    NSString *name;
    NSMutableDictionary *attributes;
    ElementParser *parentElementParser;
    NSMutableString *innerMarkup;
    NSMutableString *cdata;
    DatabaseOperations *operations;
    NSNumber *dbid;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSMutableDictionary *attributes;
@property (nonatomic, readonly) ElementParser *parentElementParser;
@property (nonatomic, readonly) NSMutableString *markup;
@property (nonatomic, readonly) NSMutableString *innerMarkup;
@property (nonatomic, readonly) NSMutableString *cdata;
@property (nonatomic, readonly) DatabaseOperations *operations;
@property (nonatomic, retain)   NSNumber *dbid;

+ (id)newParserForElement:(NSString *)elementName
             namespaceURI:(NSString *)namespaceURI
            qualifiedName:(NSString *)qualifiedName
               attributes:(NSDictionary *)xmlAttributes
      parentElementParser:(ElementParser *)parent
          usingOperations:(DatabaseOperations *)ops;

- (id)initWithElement:(NSString *)elementName
           attributes:(NSDictionary *)xmlAttributes
  parentElementParser:(ElementParser *)parent
      usingOperations:(DatabaseOperations *)ops;

- (id)init;

- (void)addMarkup:(NSString *)string;

- (void)addCData:(NSString *)string;

- (BOOL)beginElement:(NSError **)error;

- (BOOL)endElement:(NSError **)error;

- (id)getAttribute:(NSString *)attribute;

@end
