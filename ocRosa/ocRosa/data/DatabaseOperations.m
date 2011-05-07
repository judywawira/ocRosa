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

#import "DatabaseOperations.h"
#import "DatabaseConnection.h"
#import "Record.h"
#import "FMDatabase.h"

@implementation DatabaseOperations

- (id)initWithDatabase:(DatabaseConnection *)db {
    
    if (!(self = [super init]))
        return nil;
    
    connection = [db retain];
    
    return self;
}

- (void)dealloc {
    [connection release];
    [super dealloc];
}

#pragma mark Form Parsing

- (NSNumber *)createForm:(NSError**)error {
    
    return [connection executeInsert:@"INSERT INTO Forms DEFAULT VALUES;"
                           arguments:nil
                        errorMessage:@"Cannot create Form"
                               error:error];
}

- (BOOL)setFormTitle:(NSString *)title
                form:(NSNumber *)dbid
               error:(NSError**)error {
    
    return [connection executeScalar:@"UPDATE Forms SET title = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:title, dbid, nil]
                        errorMessage:@"Cannot set title for Form"
                               error:error];
}

- (BOOL)setFormURL:(NSURL *)url
              form:(NSNumber *)dbid
             error:(NSError**)error {
    
    return [connection executeScalar:@"UPDATE Forms SET download_url = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:url, dbid, nil]
                        errorMessage:@"Cannot set download_url for Form"
                               error:error];
}

- (BOOL)setFormDate:(NSDate *)date
               form:(NSNumber *)dbid
              error:(NSError**)error {
    
    return [connection executeScalar:@"UPDATE Forms SET download_date = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:date, dbid, nil]
                        errorMessage:@"Cannot set download_date for Form"
                               error:error];
}

- (BOOL)setFormContents:(NSData *)data
                   form:(NSNumber *)dbid
                  error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Forms SET data = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:data, dbid, nil]
                        errorMessage:@"Cannot set data for Form"
                               error:error];
}

#pragma mark Form Usage

- (NSNumber *)countForms:(NSError**)error {
    
    return [connection numberFromQuery:@"SELECT count(*) FROM Forms;"
                             arguments:nil
                          errorMessage:@"Cannot count Forms"
                                 error:error];
}

- (NSArray *)getFormDBIDs:(NSError**)error {
    
    return [connection numberArrayFromQuery:@"SELECT dbid FROM Forms;"
                                  arguments:nil
                               errorMessage:@"Cannot get list of Forms IDs"
                                      error:error];
}

- (NSString *)getFormTitle:(NSNumber *)dbid 
                     error:(NSError**)error {
    
    return [connection stringFromQuery:@"SELECT title FROM Forms WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:dbid, nil] 
                          errorMessage:@"Cannot get Form title"
                                 error:error];
}

- (NSString *)getFormDownloadURL:(NSNumber *)dbid 
                           error:(NSError**)error {
    
    return [connection stringFromQuery:@"SELECT download_url FROM Forms WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:dbid, nil] 
                          errorMessage:@"Cannot get Form download_url"
                                 error:error];
}

- (NSDate *)getFormDownloadDate:(NSNumber *)dbid 
                            error:(NSError**)error {
    
    return [connection dateFromQuery:@"SELECT download_date FROM Forms WHERE dbid = ?;" 
                           arguments:[NSArray arrayWithObjects:dbid, nil] 
                        errorMessage:@"Cannot get Form download_date"
                               error:error];
}

- (NSNumber *)getFormQuestionCount:(NSNumber *)dbid
                             error:(NSError **)error {
    
    return [connection numberFromQuery:@"SELECT count(*) FROM Controls WHERE form_dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:dbid, nil] 
                          errorMessage:@"Cannot count Form questions"
                                 error:error];
}

- (NSNumber *)getFormRecordCount:(NSNumber *)formDBID
                           state:(NSNumber *)state
                           error:(NSError **)error {
    
    // Get the specified Form's (only) instance
    NSNumber *instance = [self getInstanceForForm:formDBID error:error];
    
    if (!instance)
        return nil;
    
    if (!state) {
        // state is nil - count all records
        return [connection numberFromQuery:@"SELECT count(*) FROM Records WHERE instance_dbid = ?;" 
                                 arguments:[NSArray arrayWithObjects:instance, nil] 
                              errorMessage:@"Cannot count Records"
                                     error:error];
    }
    
    return [connection numberFromQuery:@"SELECT count(*) FROM Records WHERE state = ? AND instance_dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:state, instance, nil] 
                          errorMessage:@"Cannot count Records"
                                 error:error];
}

- (NSArray *)getFormRecordDBIDs:(NSNumber *)formDBID
                          state:(NSNumber *)state
                          error:(NSError **)error {
    
    // Get the specified Form's (only) instance
    NSNumber *instance = [self getInstanceForForm:formDBID error:error];
    
    if (!instance)
        return nil;
    
    if (!state) {
        // state is nil - get all records
        return [connection numberArrayFromQuery:@"SELECT dbid FROM Records WHERE instance_dbid = ? ORDER BY create_date;" 
                                      arguments:[NSArray arrayWithObjects:instance, nil] 
                                   errorMessage:@"Cannot get Records"
                                          error:error];
    }
    
    return [connection numberArrayFromQuery:@"SELECT dbid FROM Records WHERE state = ? AND instance_dbid = ? ORDER BY create_date;" 
                                  arguments:[NSArray arrayWithObjects:state, instance, nil] 
                               errorMessage:@"Cannot get Records"
                                      error:error];
}

#pragma mark Model Parsing

- (NSNumber *)createModelInForm:(NSNumber *)formDBID 
                       xFormsID:(NSString *)xFormsID
                       serverID:(NSString *)serverID
                         geotag:(NSNumber *)geotag
                          error:(NSError **)error {
    
    return [connection executeInsert:@"INSERT INTO Models (form_dbid, xforms_id, server_id, geotag) VALUES (?, ?, ?, ?);"
                           arguments:[NSArray arrayWithObjects:formDBID, xFormsID, serverID, geotag, nil]
                        errorMessage:@"Cannot create Model"
                               error:error];
}

#pragma mark Instance Parsing

- (NSNumber *)createInstanceInModel:(NSNumber *)modelDBID
                              error:(NSError**)error {
    
    return [connection executeInsert:@"INSERT INTO Instances (model_dbid) VALUES (?);"
                           arguments:[NSArray arrayWithObjects:modelDBID, nil]
                        errorMessage:@"Cannot create Instance"
                               error:error];
}

- (BOOL)setInstanceData:(NSData *)data
               instance:(NSNumber *)dbid
                  error:(NSError**)error {
    
    return [connection executeScalar:@"UPDATE Instances SET xml = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:data, dbid, nil]
                        errorMessage:@"Cannot set Instance xml"
                               error:error];
}

#pragma mark Instance Usage

- (NSNumber *)getInstanceForForm:(NSNumber *)formDBID
                           error:(NSError **)error {
    
    return [connection numberFromQuery:@"SELECT Instances.dbid FROM Models, Instances " 
                                        "WHERE Instances.model_dbid = Models.dbid AND "
                                        "Models.form_dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:formDBID, nil] 
                          errorMessage:@"Cannot get default Instance for Form"
                                 error:error];
}


#pragma mark Record Usage

- (NSNumber *)createRecordForForm:(NSNumber *)formDBID
                            error:(NSError **)error {
    
    // Creating an new Record (to hold a single result) is a multi-step operation:
    
    // Get the specified Form's (only) instance
    NSNumber *instance = [self getInstanceForForm:formDBID error:error];
    
    if (!instance)
        return nil;
    
    
    // Get the Instance XML
    NSData *xmlBuffer = [connection bufferFromQuery:@"SELECT xml FROM Instances WHERE dbid = ?;" 
                                          arguments:[NSArray arrayWithObjects:instance, nil] 
                                       errorMessage:@"Cannot get Instance xml"
                                              error:error];
    if (!xmlBuffer)
        return nil;
    
    // Get the dbid of the first Contol (Question)
    NSNumber *control = [connection numberFromQuery:@"SELECT dbid FROM Controls WHERE form_dbid = ? ORDER BY dbid;"
                                          arguments:[NSArray arrayWithObjects:formDBID, nil] 
                                       errorMessage:@"Cannot get first Control for Form"
                                              error:error];   
    if (!control)
        return nil;
    
    return [connection executeInsert:@"INSERT INTO Records (instance_dbid, result, state, control_dbid, create_date) "
                                    "VALUES (?, ?, ?, ?, ?);"
                           arguments:[NSArray arrayWithObjects:
                                                    instance, 
                                                    xmlBuffer, 
                                                    [NSNumber numberWithInt:kRecordState_InProgress],
                                                    control,
                                                    [NSDate date],
                                                    nil]
                        errorMessage:@"Cannot create Record"
                               error:error];
}

- (NSData *)getRecordXML:(NSNumber *)recordDBID
                   error:(NSError **)error {
    return [connection bufferFromQuery:@"SELECT result FROM Records WHERE dbid = ?;"
                             arguments:[NSArray arrayWithObjects:recordDBID, nil]
                          errorMessage:@"Cann get Record result xml"
                                 error:error];
}


- (BOOL)setRecordXML:(NSData *)xml
              record:(NSNumber *)dbid
               error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Records SET result = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:xml, dbid, nil]
                        errorMessage:@"Cannot set XML hint for Control"
                               error:error];
    
}

- (BOOL)setRecordComplete:(NSNumber *)recordDBID
                    error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Records SET state = ?, complete_date = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:
                                        [NSNumber numberWithInt:kRecordState_Completed],
                                        [NSDate date],
                                        recordDBID,
                                        nil]
                        errorMessage:@"Cannot set Record to 'completed'"
                               error:error]; 
}

#pragma mark Bind Parsing

- (NSNumber *)createBindingInModel:(NSNumber *)modelDBID
                          xFormsID:(NSString *)xFormsID
                           nodeset:(NSString *)nodeset
                        constraint:(NSString *)constraint
                 constraintMessage:(NSString *)constraintMessage
                              type:(NSString *)type
                          required:(NSString *)required
                          relevant:(NSString *)relevant
                             error:(NSError **)error {
    
    return [connection executeInsert:@"INSERT INTO Bindings (model_dbid, xforms_id, nodeset, constraint_expression, constraint_message, type, required, relevant) "
                                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
                           arguments:[NSArray arrayWithObjects:modelDBID, xFormsID, nodeset, constraint, constraintMessage, type, required, relevant, nil]
                        errorMessage:@"Cannot create Binding"
                               error:error];
}

#pragma mark Bind Usage

- (NSString *)getBindingNodeset:(NSNumber *)bindingDBID
                          error:(NSError **)error {

    return [connection stringFromQuery:@"SELECT nodeset FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding nodeset"
                                 error:error];
}

- (NSString *)getBindingConstraint:(NSNumber *)bindingDBID
                             error:(NSError **)error {

    return [connection stringFromQuery:@"SELECT constraint_expression FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding constraint"
                                 error:error];
}

- (NSString *)getBindingConstraintMsg:(NSNumber *)bindingDBID
                                error:(NSError **)error {

    return [connection stringFromQuery:@"SELECT constraint_message FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding constraint_message"
                                 error:error];
}

- (NSString *)getBindingType:(NSNumber *)bindingDBID
                       error:(NSError **)error {
    
    return [connection stringFromQuery:@"SELECT type FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding type"
                                 error:error];
}

- (NSString *)getBindingRequired:(NSNumber *)bindingDBID
                           error:(NSError **)error {
    
    return [connection stringFromQuery:@"SELECT required FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding required"
                                 error:error];
}

- (NSString *)getBindingRelevant:(NSNumber *)bindingDBID
                           error:(NSError **)error {
    
    return [connection stringFromQuery:@"SELECT relevant FROM Bindings WHERE dbid = ?;" 
                             arguments:[NSArray arrayWithObjects:bindingDBID, nil] 
                          errorMessage:@"Cannot get Binding relevant"
                                 error:error];
}

#pragma mark Control Parsing

- (NSNumber *)createControlInForm:(NSNumber *)formDBID
                             type:(NSNumber *)type
                          binding:(NSString *)binding
                              ref:(NSString *)ref
                            error:(NSError **)error {
    
    return [connection executeInsert:@"INSERT INTO Controls (form_dbid, type, ref, binding_xforms_id) VALUES (?, ?, ?, ?);"
                           arguments:[NSArray arrayWithObjects:formDBID, type, ref, binding, nil]
                        errorMessage:@"Cannot create Control"
                               error:error];    
}

- (BOOL)setControlLabel:(NSString *)label
                control:(NSNumber *)dbid
                  error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Controls SET label = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:label, dbid, nil]
                        errorMessage:@"Cannot set label for Control"
                               error:error];
}

- (BOOL)setControlHint:(NSString *)hint
               control:(NSNumber *)dbid
                 error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Controls SET hint = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:hint, dbid, nil]
                        errorMessage:@"Cannot set hint for Control"
                               error:error];
}

#pragma mark Control Usage

- (NSArray *)getControlDBIDs:(NSNumber *)recordDBID
                       error:(NSError **)error {
    
    NSNumber *formDBID = [connection numberFromQuery:@"SELECT Forms.dbid FROM Records, Instances, Models, Forms " 
                                                      "WHERE Records.instance_dbid = Instances.dbid AND "
                                                      "Instances.model_dbid = Models.dbid AND "
                                                      "Models.form_dbid = Forms.dbid AND "
                                                      "Records.dbid = ?;"
                                          arguments:[NSArray arrayWithObjects:recordDBID, nil] 
                                       errorMessage:@"Cannot get first Control for Form"
                                              error:error];   
    
    return [connection numberArrayFromQuery:@"SELECT dbid FROM Controls WHERE Controls.form_dbid = ? ORDER BY dbid;"
                                  arguments:[NSArray arrayWithObjects:formDBID, nil] 
                               errorMessage:@"Cannot get list of Control IDs"
                                      error:error];
}

- (NSNumber *)getBindingForControl:(NSNumber *)controlDBID
                             error:(NSError **)error {
 
    return [connection numberFromQuery:@"SELECT Bindings.dbid FROM Controls, Bindings " 
                                        "WHERE Controls.binding_xforms_id = Bindings.xforms_id AND "
                                        "Controls.dbid = ?;"
                             arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                          errorMessage:@"Cannot get Binding for Control"
                                 error:error];
}

- (NSInteger)getControlType:(NSNumber *)controlDBID
                      error:(NSError **)error {
    
    return [[connection numberFromQuery:@"SELECT type FROM Controls WHERE dbid = ?;"
                             arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                          errorMessage:@"Cannot get Control type"
                                 error:error] integerValue];
}

- (NSString *)getControlLabel:(NSNumber *)controlDBID
                        error:(NSError **)error {
    
    return [connection stringFromQuery:@"SELECT label FROM Controls WHERE dbid = ?;"
                              arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                           errorMessage:@"Cannot get Control label"
                                  error:error];
}

- (NSString *)getControlHint:(NSNumber *)controlDBID
                       error:(NSError **)error {
    
    return [connection stringFromQuery:@"SELECT hint FROM Controls WHERE dbid = ?;"
                             arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                          errorMessage:@"Cannot get Control hint"
                                 error:error];
}

- (NSArray *)getControlItems:(NSNumber *)controlDBID
                       error:(NSError **)error {
    
    return [connection stringArrayFromQuery:@"SELECT label FROM Control_Items WHERE control_dbid = ?;"
                                  arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                               errorMessage:@"Cannot get Control items"
                                      error:error];
}

- (NSArray *)getControlValues:(NSNumber *)controlDBID
                        error:(NSError **)error {
    
    return [connection stringArrayFromQuery:@"SELECT value FROM Control_Items WHERE control_dbid = ?;"
                                  arguments:[NSArray arrayWithObjects:controlDBID, nil] 
                               errorMessage:@"Cannot get Control values"
                                      error:error];
}


#pragma mark Item

- (NSNumber *)createItemInControl:(NSNumber *)controlDBID
                            error:(NSError **)error {
    
    return [connection executeInsert:@"INSERT INTO Control_Items (control_dbid) VALUES (?);"
                           arguments:[NSArray arrayWithObjects:controlDBID, nil]
                        errorMessage:@"Cannot create Control_Item"
                               error:error];
}

- (BOOL)setItemLabel:(NSString *)label
                item:(NSNumber *)dbid
               error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Control_Items SET label = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:label, dbid, nil]
                        errorMessage:@"Cannot set label for Control_Item"
                               error:error];
}

- (BOOL)setItemValue:(NSString *)value
                item:(NSNumber *)dbid
               error:(NSError **)error {
    
    return [connection executeScalar:@"UPDATE Control_Items SET value = ? WHERE dbid = ?;"
                           arguments:[NSArray arrayWithObjects:value, dbid, nil]
                        errorMessage:@"Cannot set value for Control_Item"
                               error:error];
}

@end
