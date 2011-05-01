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

#import "ElementParser.h"
#import "Elements.h"
#import "GTMNSString+XML.h"
#import "DatabaseOperations.h"

@implementation ElementParser

@synthesize name;
@synthesize attributes;
@synthesize parentElementParser;
@synthesize innerMarkup;
@synthesize cdata;
@synthesize operations;
@synthesize dbid;

+ (id)newParserForElement:(NSString *)elementName
             namespaceURI:(NSString *)namespaceURI
            qualifiedName:(NSString *)qualifiedName
               attributes:(NSDictionary *)xmlAttributes
      parentElementParser:(ElementParser *)parent 
          usingOperations:(DatabaseOperations *)ops {
    
    Class parserClass = NSClassFromString([Elements parserNameForElement:elementName
                                                            namespaceURI:namespaceURI
                                                           qualifiedName:qualifiedName]);
    
    return [[[parserClass alloc] 
        initWithElement:elementName
             attributes:xmlAttributes
             parentElementParser:parent
             usingOperations:ops] autorelease];
}

- (id)init {
    return [self initWithElement:nil 
                      attributes:nil
             parentElementParser:nil
                 usingOperations:nil];
}

- (id)initWithElement:(NSString *)xmlElement
           attributes:(NSDictionary *)xmlAttributes
  parentElementParser:(ElementParser *)parent
      usingOperations:(DatabaseOperations *)ops {
    
    if (!(self = [super init]))
        return nil;
    
    [name release];
    name = [xmlElement copy];
          
    attributes = [[NSMutableDictionary alloc] init];
    [attributes setDictionary:xmlAttributes];
    
    [parentElementParser release];
    parentElementParser = [parent retain];
    
    [dbid release];
    dbid = (parentElementParser == nil) ? 
                [[NSNumber alloc] initWithInt:0] :
                [parentElementParser.dbid copy];
       
    innerMarkup = [NSMutableString stringWithCapacity:64];
    
    cdata = [NSMutableString stringWithCapacity:64];
    
    [operations release];
    operations = [ops retain];
    
    return self;
}

- (void)dealloc {
    self.dbid = nil;
    [name release];
    [attributes release];
    [parentElementParser release];
    [operations release];
    [super dealloc];
}

- (void)addMarkup:(NSString *)string {
    [innerMarkup appendString:string];
}

- (NSString *)markup {
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@", name];
    for(id key in attributes) {
        [result appendFormat:@" %@=\"%@\"", 
         key, [[attributes objectForKey:key] gtm_stringBySanitizingAndEscapingForXML]];
    }
    [result appendString:@">"];
    [result appendString:innerMarkup];
    [result appendFormat:@"</%@>", name];
    
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)addCData:(NSString *)string {
    NSString *trimmed = [string stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [cdata appendString:trimmed];
    [self addMarkup:trimmed];
}

- (BOOL)beginElement:(NSError **)error {
    // Intentionally does nothing. Child classes will override this method
    // to perform custom database operations when encountering a new
    // XML element
    return YES;
}

- (BOOL)endElement:(NSError **)error {
    [parentElementParser addMarkup:self.markup];
    return YES;
}

- (id)getAttribute:(NSString *)attribute {
    
    // Because of the arguments to SQL statements are 
    // passed as a nil-terminated array, if the specified 
    // attribute doesn't exist we return NSNull (which 
    // is entered into the database as SQL NULL)
    
    if (!attributes)
        return [NSNull null];

    return (nil != [attributes objectForKey:attribute])
                ? [attributes objectForKey:attribute]
                : [NSNull null];
}


@end
