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

#import "RecordXML.h"

#import <libxml/parser.h>
#import <libxml/xpathInternals.h>

NSString *const kXML_Error_Domain   = @"XML";
NSString *const kXML_Error_Message  = @"LibxmlMsg";
NSString *const kXML_Error_XML      = @"xml";
NSString *const kXML_Error_XPATH    = @"xpath";

@implementation RecordXML

+ (NSError *)createError:(NSString *)description
                     xml:(NSString *)xml
                   xpath:(NSString *)xpath {
   
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:[NSString stringWithString:description] 
               forKey:NSLocalizedDescriptionKey];
    
    [details setValue:[NSString stringWithString:xml]
               forKey:kXML_Error_XML];
    
    [details setValue:[NSString stringWithString:xpath]
               forKey:kXML_Error_XPATH];
    
    return [NSError errorWithDomain:kXML_Error_Domain 
                               code:0
                           userInfo:details];
}

+ (NSError *)createError:(NSString *)description
                     xml:(NSString *)xml
                   xpath:(NSString *)xpath
                 context:(xmlXPathContextPtr)context {
  
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:[NSString stringWithString:description] 
               forKey:NSLocalizedDescriptionKey];
    
    [details setValue:[NSString stringWithString:xml]
               forKey:kXML_Error_XML];
    
    [details setValue:[NSString stringWithString:xpath]
               forKey:kXML_Error_XPATH];
    
    xmlError err = context->lastError;
    if (err.message) {
        [details setValue:[NSString stringWithCString:err.message encoding:NSUTF8StringEncoding]
                   forKey:kXML_Error_Message];
    }
    
    return [NSError errorWithDomain:kXML_Error_Domain 
                               code:err.code
                           userInfo:details];
    
}

#pragma mark -

- (id)initWithString:(NSString *)xmlString {
    
    // Convert xmlString (which is internally stored using UTF16)
    // to a UTF8 encoded data buffer
    return [self initWithUTF8Data:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithUTF8Data:(NSData *)xmlBuffer {
    
    if (!(self = [super init]))
        return nil;

    doc = xmlReadMemory([xmlBuffer bytes], [xmlBuffer length], "", "UTF-8", XML_PARSE_RECOVER);
	
    if (!doc)
		return nil;
   
    return self;
}

- (void)dealloc {
    if (NULL != doc)
        xmlFreeDoc(doc);
    
    [super dealloc];
}

#pragma mark -

- (NSData *)xmlBuffer {
    xmlChar *buffer;
    int size;
    
    xmlKeepBlanksDefault(0);
    xmlDocDumpFormatMemory(doc, &buffer, &size, 0);
    
    // 'dataWithBytes' makes a copy of the buffer
    NSData *result = [NSData dataWithBytes:buffer length:size]; 
    xmlFree(buffer);
    return result;
}

- (NSString *)xmlString {
    return [[[NSString alloc] initWithData:[self xmlBuffer] 
                                  encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark XPath

- (xmlXPathObjectPtr)evalXPath:(NSString *)xpath
                         error:(NSError **)error {
    
    xmlXPathContextPtr xpathContext; 
    xmlXPathObjectPtr  xpathObject; 
    
    if (!doc) {
        *error = [RecordXML createError:@"XML Document is NULL"
                                    xml:nil
                                  xpath:xpath];
        return NULL;
    }
    
    /* Create xpath evaluation context */
    xpathContext = xmlXPathNewContext(doc);
    if(!xpathContext) {
        *error = [RecordXML createError:@"Cannot create XPath context"
                                    xml:[self xmlString]
                                  xpath:xpath];
		return NULL;
    }
    
    /* Evaluate xpath expression */
    xpathObject = xmlXPathEvalExpression((xmlChar *)[xpath cStringUsingEncoding:NSUTF8StringEncoding], xpathContext);
    if(xpathObject == NULL) {
        *error = [RecordXML createError:@"Cannot evaluate XPath expression"
                                    xml:[self xmlString]
                                  xpath:xpath
                                context:xpathContext];
		return NULL;
    }
	
    xmlXPathFreeContext(xpathContext);
    return xpathObject;    
}


- (BOOL)evaluateXPathExpression:(NSString *)xpath
                          error:(NSError **)error {
    
    
    xmlXPathObjectPtr  xpathObject = [self evalXPath:xpath error:error];
    
    if (!xpathObject)
        return NO;
    
    BOOL result = xpathObject->boolval;
    xmlXPathFreeObject(xpathObject);
    
    return result;
}

- (BOOL)setValue:(NSString *)value
      forNodeset:(NSString *)nodeset
           error:(NSError **)error {
    
    xmlXPathObjectPtr xpathObject = [self evalXPath:nodeset error:error];
    
    if (!xpathObject)
        return NO;
    
    xmlNodeSetPtr nodes = xpathObject->nodesetval;
	if (!nodes) {
        xmlXPathFreeObject(xpathObject);
        *error = [RecordXML createError:@"XPath expression returned no nodes"
                                    xml:[self xmlString]
                                  xpath:nodeset];
		return NO;
	}
	
    for (int i = 0; i < nodes->nodeNr; i++) {
        
        xmlNodePtr node = nodes->nodeTab[i];
        xmlNodeSetContent(node, (xmlChar *)[value cStringUsingEncoding:NSUTF8StringEncoding]);
	} 

    xmlXPathFreeObject(xpathObject);    
    return YES;
}

- (NSString *)getValueFromNodeset:(NSString *)nodeset
                            error:(NSError **)error {

    xmlXPathObjectPtr xpathObject = [self evalXPath:nodeset error:error];
    
    if (!xpathObject)
        return nil;
    
    xmlNodeSetPtr nodes = xpathObject->nodesetval;
	if (!nodes) {
        xmlXPathFreeObject(xpathObject);
        *error = [RecordXML createError:@"XPath expression returned no nodes"
                                    xml:[self xmlString]
                                  xpath:nodeset];
		return nil;
	}
	
    xmlNodePtr node = nodes->nodeTab[0]; // Even if the xpath expression returned multiple
                                         // nodes - we just care about the 1st one
    
    xmlChar *text = xmlNodeGetContent(node);
    if (!text) {
        // node has no child TEXT elements
        xmlXPathFreeObject(xpathObject);
        return nil;
    }
    
    NSString *value = [NSString stringWithCString:(char *)text encoding:NSUTF8StringEncoding];
    xmlFree(text);
    xmlXPathFreeObject(xpathObject);
    return ([value length] != 0) ? value : nil;
}

@end
