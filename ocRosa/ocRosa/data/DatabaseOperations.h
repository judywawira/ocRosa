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
@class Form;

@interface DatabaseOperations : NSObject {
    DatabaseConnection *connection;
}
    
- (id)initWithDatabase:(DatabaseConnection *)db;

#pragma mark Form Parsing

- (NSNumber *)createForm:(NSError **)error;

- (BOOL)setFormTitle:(NSString *)title
                form:(NSNumber *)dbid
               error:(NSError **)error;

- (BOOL)setFormURL:(NSURL *)url
              form:(NSNumber *)dbid
             error:(NSError **)error;

- (BOOL)setFormDate:(NSDate *)date
               form:(NSNumber *)dbid
              error:(NSError **)error;

- (BOOL)setFormContents:(NSData *)data
                   form:(NSNumber *)dbid
                  error:(NSError **)error;

#pragma mark Form Usage

- (NSNumber *)countForms:(NSError **)error;

- (NSArray *)getFormDBIDs:(NSError **)error;

- (NSString *)getFormTitle:(NSNumber *)dbid
                     error:(NSError **)error;

- (NSString *)getFormServerID:(NSNumber *)dbid
                        error:(NSError **)error;

- (NSString *)getFormDownloadURL:(NSNumber *)dbid
                           error:(NSError **)error;

- (NSDate *)getFormDownloadDate:(NSNumber *)dbid
                          error:(NSError **)error;

- (NSNumber *)getFormQuestionCount:(NSNumber *)dbid
                             error:(NSError **)error;

- (NSNumber *)getFormRecordCount:(NSNumber *)formDBID
                           state:(NSNumber *)state
                           error:(NSError **)error;

- (NSArray *)getFormRecordDBIDs:(NSNumber *)formDBID
                          state:(NSNumber *)state
                          error:(NSError **)error;

#pragma mark Model Parsing

- (NSNumber *)createModelInForm:(NSNumber *)formDBID 
                       xFormsID:(NSString *)xFormsID
                       serverID:(NSString *)serverID
                         geotag:(NSNumber *)geotag
                          error:(NSError **)error;

#pragma mark Instance Parsing

- (NSNumber *)createInstanceInModel:(NSNumber *)modelDBID
                              error:(NSError **)error;

- (BOOL)setInstanceData:(NSData *)data
              instance:(NSNumber *)dbid
                 error:(NSError **)error;

#pragma mark Instance Usage

- (NSNumber *)getInstanceForForm:(NSNumber *)formDBID
                           error:(NSError **)error;

#pragma mark Record Usage

- (NSNumber *)createRecordForForm:(NSNumber *)formDBID
                            error:(NSError **)error;

- (NSData *)getRecordXML:(NSNumber *)recordDBID
                   error:(NSError **)error;

- (BOOL)setRecordXML:(NSData *)xml
              record:(NSNumber *)dbid
               error:(NSError **)error;

- (BOOL)setRecordInProgress:(NSNumber *)recordDBID
                      error:(NSError **)error;

- (BOOL)setRecordComplete:(NSNumber *)recordDBID
                    error:(NSError **)error;

- (BOOL)setRecordSubmitted:(NSNumber *)recordDBID
                     error:(NSError **)error;

- (NSNumber *)getRecordState:(NSNumber *)recordDBID
                       error:(NSError **)error;

- (NSDate *)getRecordCreateDate:(NSNumber *)recordDBID
                          error:(NSError **)error;

- (NSDate *)getRecordCompleteDate:(NSNumber *)recordDBID
                            error:(NSError **)error;

- (NSDate *)getRecordSubmitDate:(NSNumber *)recordDBID
                          error:(NSError **)error;

- (NSArray *)getRecordControlDBIDs:(NSNumber *)recordDBID
                             error:(NSError **)error;

- (NSArray *)getRecordQuestionDBIDs:(NSNumber *)recordDBID
                              error:(NSError **)error;

- (NSNumber *)getRecordProgress:(NSNumber *)recordDBID
                          error:(NSError **)error;

#pragma mark Questions Usage

- (NSNumber *)createQuestionForRecord:(NSNumber *)recordDBID
                              control:(NSNumber *)controlDBID
                                error:(NSError **)error;

- (NSNumber *)getQuestionRecord:(NSNumber *)questionDBID
                           error:(NSError **)error;

- (NSNumber *)getQuestionControl:(NSNumber *)questionDBID
                           error:(NSError **)error;

- (NSString *)getQuestionLabel:(NSNumber *)questionDBID
                         error:(NSError **)error;

- (BOOL)getQuestionRelevant:(NSNumber *)questionDBID
                      error:(NSError **)error;

- (BOOL)setQuestionRelevant:(BOOL)isRelevant
                forQuestion:(NSNumber *)questionDBID
                      error:(NSError **)error;


- (BOOL)getQuestionRequired:(NSNumber *)questionDBID
                      error:(NSError **)error;

- (BOOL)setQuestionRequired:(BOOL)isRequired
                forQuestion:(NSNumber *)questionDBID
                      error:(NSError **)error;


- (BOOL)getQuestionAnswered:(NSNumber *)questionDBID
                      error:(NSError **)error;

- (BOOL)setQuestionAnswered:(BOOL)isAnswered
                forQuestion:(NSNumber *)questionDBID
                      error:(NSError **)error;

- (NSString *)getQuestionAnswer:(NSNumber *)questionDBID
                          error:(NSError **)error;

- (BOOL)setQuestionAnswer:(NSString *)answer
              forQuestion:(NSNumber *)questionDBID
                    error:(NSError **)error;

#pragma mark Bind Parsing

- (NSNumber *)createBindingInModel:(NSNumber *)modelDBID
                          xFormsID:(NSString *)xFormsID
                           nodeset:(NSString *)nodeset
                        constraint:(NSString *)constraint
                 constraintMessage:(NSString *)constraintMessage
                              type:(NSString *)type
                          required:(NSString *)required
                          relevant:(NSString *)relevant
                             error:(NSError **)error;

#pragma mark Bind Usage

- (NSString *)getBindingNodeset:(NSNumber *)bindingDBID
                          error:(NSError **)error;

- (NSString *)getBindingConstraint:(NSNumber *)bindingDBID
                             error:(NSError **)error;

- (NSString *)getBindingConstraintMsg:(NSNumber *)bindingDBID
                                error:(NSError **)error;

- (NSString *)getBindingType:(NSNumber *)bindingDBID
                       error:(NSError **)error;

- (NSString *)getBindingRequired:(NSNumber *)bindingDBID
                           error:(NSError **)error;

- (NSString *)getBindingRelevant:(NSNumber *)bindingDBID
                           error:(NSError **)error;

#pragma mark Control Parsing

- (NSNumber *)createControlInForm:(NSNumber *)formDBID
                             type:(NSNumber *)type
                          binding:(NSString *)binding
                              ref:(NSString *)ref
                            error:(NSError **)error;

- (BOOL)setControlLabel:(NSString *)label
                control:(NSNumber *)dbid
                  error:(NSError **)error;

- (BOOL)setControlHint:(NSString *)hint
               control:(NSNumber *)dbid
                 error:(NSError **)error;

#pragma mark Control Usage

- (NSNumber *)getBindingForControl:(NSNumber *)controlDBID
                             error:(NSError **)error;

- (NSInteger)getControlType:(NSNumber *)controlDBID
                      error:(NSError **)error;

- (NSString *)getControlLabel:(NSNumber *)controlDBID
                        error:(NSError **)error;

- (NSString *)getControlHint:(NSNumber *)controlDBID
                       error:(NSError **)error;

- (NSArray *)getControlItems:(NSNumber *)controlDBID
                       error:(NSError **)error;

- (NSArray *)getControlValues:(NSNumber *)controlDBID
                        error:(NSError **)error;

#pragma mark Item

- (NSNumber *)createItemInControl:(NSNumber *)controlDBID
                            error:(NSError **)error;

- (BOOL)setItemLabel:(NSString *)label
                item:(NSNumber *)dbid
               error:(NSError **)error;

- (BOOL)setItemValue:(NSString *)value
                item:(NSNumber *)dbid
               error:(NSError **)error;


@end
