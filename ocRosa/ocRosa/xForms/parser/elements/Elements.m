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

#import "Elements.h"
#import "Control.h"

// Namespaces

NSString *const kNamespaceDD        = @"http://datadyne.org/javarosa";
NSString *const kNamespaceJR        = @"http://openrosa.org/javarosa";
NSString *const kNamespaceXF        = @"http://www.w3.org/2002/xforms";
NSString *const kNamespaceXSD       = @"http://www.w3.org/2001/XMLSchema";
NSString *const kNamespaceXHTML     = @"http://www.w3.org/1999/xhtml";

NSString *const kDefaultParser      = @"ElementParser";

NSString *const kModelElement       = @"model";
NSString *const kModelParser        = @"ModelParser";

NSString *const kTitleElement       = @"title";
NSString *const kTitleParser        = @"TitleParser";

NSString *const kInstanceElement    = @"instance";
NSString *const kInstanceParser     = @"InstanceParser";

NSString *const kBindElement        = @"bind";
NSString *const kBindParser         = @"BindParser";

// Elements <input>, <output>, <select> and <select1> all use the same Parser

NSString *const kOutputElement      = @"output";
NSString *const kOutputParser       = @"ControlParser";

NSString *const kInputElement       = @"input";
NSString *const kInputParser        = @"ControlParser";

NSString *const kSelectElement      = @"select";
NSString *const kSelectParser       = @"ControlParser";

NSString *const kSelectOneElement   = @"select1";
NSString *const kSelectOneParser    = @"ControlParser";

NSString *const kLabelElement       = @"label";
NSString *const kLabelParser        = @"LabelParser";

NSString *const kValueElement       = @"value";
NSString *const kValueParser        = @"ValueParser";

NSString *const kHintElement        = @"hint";
NSString *const kHintParser         = @"HintParser";

NSString *const kItemElement        = @"item";
NSString *const kItemParser         = @"ItemParser";



#pragma mark -

@implementation Elements

+ (NSString *)parserNameForElement:(NSString *)elementName
                      namespaceURI:(NSString *)namespaceURI
                     qualifiedName:(NSString *)qualifiedName {

    if ([namespaceURI isEqualToString:kNamespaceXHTML]) {
        if      ([elementName isEqualToString:kTitleElement])       return kTitleParser;
    }
    
    if ([namespaceURI isEqualToString:kNamespaceXF]) {
    
             if ([elementName isEqualToString:kBindElement])        return kBindParser; 
        else if ([elementName isEqualToString:kOutputElement])      return kOutputParser; 
        else if ([elementName isEqualToString:kInputElement])       return kInputParser;
        else if ([elementName isEqualToString:kSelectElement])      return kSelectParser;
        else if ([elementName isEqualToString:kSelectOneElement])   return kSelectOneParser;
        else if ([elementName isEqualToString:kLabelElement])       return kLabelParser;
        else if ([elementName isEqualToString:kValueElement])       return kValueParser;
        else if ([elementName isEqualToString:kHintElement])        return kHintParser;
        else if ([elementName isEqualToString:kItemElement])        return kItemParser;
        else if ([elementName isEqualToString:kModelElement])       return kModelParser;
        else if ([elementName isEqualToString:kInstanceElement])    return kInstanceParser;
       
        // Model and Instance are last in the 'if' block because they
        // occur with least frequency.
    }
    
    return kDefaultParser;
}

@end