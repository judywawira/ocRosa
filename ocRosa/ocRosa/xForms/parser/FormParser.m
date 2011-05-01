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

#import "FormParser.h"
#import "ElementParser.h"
#import "DatabaseOperations.h"
#import "CHListStack.h"
#import "FMDatabase.h"

@implementation FormParser

- (id)initWithDatabase:(DatabaseConnection *)db {
    if (!(self = [super initWithDatabase:db]))
        return nil;

    // 'dbid' will store the database primary key of the form that we're parsing
    // Initialze to 0 which in an invalid SQLite primary key
    dbid = [NSNumber numberWithInt:0];
    
    // We use a stack of ElementParsers to track where we are in
    // the source XML document. Every time we get a new XML element
    // we generate a new ElementParser for that element and then
    // push the previous ElementParser onto the stack.
    parsers = [[CHListStack alloc] init];

    // Initially, no error
    parserError = 0x0;
    
    return self;
}

- (void)dealloc {
    [parsers release];
    [xmlParser release];
    [super dealloc];
}

-(NSNumber *)parse:(NSData *)data {

    [xmlParser release];
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    
    [xmlParser setShouldProcessNamespaces:YES];
    [xmlParser setShouldReportNamespacePrefixes:YES];
    
    // If parsing was successful, return the dbid of the newly parsed form
    if ([xmlParser parse]) {
        return dbid;
    } else {
        if (parserError) {
            error = parserError;
        } else {
            error = [xmlParser parserError];
        }
        return nil;
    }
}

- (void)abort {
    [xmlParser abortParsing];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    // Document parsing has started. Create a new entry in the 'forms' table
    dbid = [operations createForm:&parserError];
    if (!dbid) {
        [self abort];
    }

    // Create an empty (no name, no attrbiutes) ElementParser that 
    // acts as a placeholder for this document's dbid

    ElementParser *rootElementParser = [[ElementParser alloc] init];
    rootElementParser.dbid = dbid;
    [parsers pushObject:rootElementParser];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qualifiedName
                                          attributes:(NSDictionary *)attributeDict {
      
    ElementParser *elementParser = [ElementParser newParserForElement:elementName
                                                         namespaceURI:namespaceURI
                                                        qualifiedName:qualifiedName
                                                           attributes:attributeDict
                                                  parentElementParser:[parsers topObject]
                                                      usingOperations:operations];
    
    if (!elementParser || ![elementParser beginElement:&parserError])
        [self abort];
    
    [parsers pushObject:elementParser];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [[parsers topObject] addCData:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    ElementParser *elementParser = [parsers topObject];
    [parsers popObject];
    
    if (![elementParser endElement:&parserError]) {
        [self abort];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    ElementParser *rootElementParser = [parsers topObject];
    [rootElementParser release];
    [parsers popObject];
}

@end
