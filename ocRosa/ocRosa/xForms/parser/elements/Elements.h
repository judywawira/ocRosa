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

// Namespaces
extern NSString *const kNamespaceDD;
extern NSString *const kNamespaceJR;
extern NSString *const kNamespaceXF;
extern NSString *const kNamespaceXSD;
extern NSString *const kNamespaceXHTML;

extern NSString *const kDefaultParser;

// <title>
extern NSString *const kTitleElement;
extern NSString *const kTitleParser;

// <xf:model>
extern NSString *const kModelElement;
extern NSString *const kModelParser;

// <xf:instance>
extern NSString *const kInstanceElement;
extern NSString *const kInstanceParser;

// <xf:bind>
extern NSString *const kBindElement;
extern NSString *const kBindParser;

// <xf:output>
extern NSString *const kOutputElement;
extern NSString *const kOutputParser;

// <xf:input>
extern NSString *const kInputElement;
extern NSString *const kInputParser;

// <xf:select>
extern NSString *const kSelectElement;
extern NSString *const kSelectParser;

// <xf:select1>
extern NSString *const kSelectOneElement;
extern NSString *const kSelectOneParser;

// <xf:label>
extern NSString *const kLabelElement;
extern NSString *const kLabelParser;

// <xf:value>
extern NSString *const kValueElement;
extern NSString *const kValueParser;

// <xf:hint>
extern NSString *const kHintElement;
extern NSString *const kHintParser;

// <xf:item>
extern NSString *const kItemElement;
extern NSString *const kItemParser;



#pragma mark -

@interface Elements : NSObject {
}
    
+ (NSString *)parserNameForElement:(NSString *)elementName
                      namespaceURI:(NSString *)namespaceURI
                     qualifiedName:(NSString *)qualifiedName;

@end

@interface TitleParser : ElementParser {}
@end

@interface InstanceParser : ElementParser {} 
@end

@interface ModelParser : ElementParser {}
@end

@interface BindParser : ElementParser {}
@end

@interface ControlParser : ElementParser {}
@end

@interface LabelParser : ElementParser {}
@end

@interface ValueParser : ElementParser {}
@end

@interface HintParser : ElementParser {}
@end

@interface ItemParser : ElementParser {}
@end

