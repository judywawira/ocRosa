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

// Abstracts all the XML DOM stuff

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/xpath.h>

extern NSString *const kXML_Error_Domain;
extern NSString *const kXML_Error_Message;
extern NSString *const kXML_Error_XML;
extern NSString *const kXML_Error_XPATH;

@interface RecordXML : NSObject {
    xmlDocPtr doc;
}

+ (NSError *)createError:(NSString *)description
                     xml:(NSString *)xml
                   xpath:(NSString *)xpath;

+ (NSError *)createError:(NSString *)description
                     xml:(NSString *)xml
                   xpath:(NSString *)xpath
                 context:(xmlXPathContextPtr)context;

#pragma mark -

- (id)initWithString:(NSString *)xmlString;

- (id)initWithUTF8Data:(NSData *)xmlBuffer;

#pragma mark -

// Return a UTF-8 Encoded buffer of the XML DOM tree
- (NSData *)xmlBuffer;

// Retrun XML DOM tree formatted as a String
- (NSString *)xmlString;

#pragma mark XPath

- (xmlXPathObjectPtr)evalXPath:(NSString *)xpath
                         error:(NSError **)error;

// Evaluate the expression and return YES or NO depending
// if the expression was TRUE (1) or FALSE (0). If NO
// double-check the output error parameter.
- (BOOL)evaluateXPathExpression:(NSString *)xpath
                          error:(NSError **)error;

// Evaluate the 'nodeset' xpath expression to locate a node
// and set the text value: <node>value</node>
// If the expression selects multiple nodes, all will have the
// same value.
- (BOOL)setValue:(NSString *)value
      forNodeset:(NSString *)nodeset
            error:(NSError **)error;

// Evaluate the 'nodeset' xpath expression to locate a node
// and return the text value: <node>value</node>
// If the expression selects multiple nodes, only the first 
// value will be used.
- (NSString *)getValueFromNodeset:(NSString *)nodeset
                            error:(NSError **)error;


@end
