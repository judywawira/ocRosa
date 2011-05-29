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

/********************************************************************************
	Create the empty SQLite (schema) database for the ocRosa iOS client.
	This database is bundled with the iOS App and deployed to the device on 
	first-launch.
	
	Reminder: Any changes to this schema (table names, column names) will need
    to be reflected in the corresponding xCode project.
	
	As a convention primary keys are called "dbid" to distinguish from XML strings
	called "id" in the incoming xForms documents.
	
	A Reminder about Foreign Keys: FK support is OFF by default and must be
	enabled at run-time (for each db connection) by calling

		PRAGMA foreign_keys = ON;

*********************************************************************************/

/* 
	The OpenRosa specification defines xForm embedded in a 'container' XML document
    (usually an xHTML document). For reference, the basic hierarchy looks like this:

	-- Begin xhtml document
	<html>
		<head>
			<meta/>
			<title/>
			<xf:model>
				<xf:instance>
					-- XML instance --
				</xf:instance>
				<xf:bind/>
				<xf:bind/>
				<xf:bind/>
				...
			</xf:model>
		</head>
		
		<body>
			<!-- Controls -->
			<xf:input>
			<xf:input>
		</body>
	</html>
	-- End xhtml document
	
	After initial download, the container document is parsed and the various
	xForms elements are extracted and stored in this SQLite database.
*/

-- -----------------------------------------------------------------------------

/* 
	The Forms table is the entry point into the parsed-and-stored xForm.
	
	During parsing, the xForms model, instance, bindings and controls are
	extracted from an incoming XML or XHTML document and stored in this
	database.

	Parsing occurs within a single SQL transaction and rolled-back if
	parsing fails for any reason.  Thus, there are no 'orphaned' model,
	instance, bindings or controls entries.

	This means that we can start with the dbid of a parsed 'Form' and walk
	the record hierarchy to build-up all the elements necessary to work 
	with the form. Since everything we need to present/display/fill-out the
	form is in this database, we never need to load the entire original
    XML/XHTML document once parsing is complete.
	
	dbid:			Primary key
	title:			Title of the Form
	download_url:	Source URL of the form
	download_date:	(Local) Date/Time form was downloaded
	data:			Raw Bytestream of Form container document
	
*/
CREATE TABLE Forms (
	dbid INTEGER PRIMARY KEY,
	title TEXT,
	download_url TEXT,
	download_date REAL,
	data BLOB
);


/*
	The Models table stores the xForms models.  The W3C xForms spec allows
	multiple models per document, but this is not currently used.
	
	dbid:			Primary key
	document_dbid:	Ref back to document containing this model
	form_id:		Named id of the xForms model
	server_id:		Server identifer of this model.  Used by ocRosa when uploaded data.
	geotag:			Boolean value.  True if this form will be geotagged.
*/
CREATE TABLE Models (
	dbid INTEGER PRIMARY KEY,
	form_dbid INTEGER NOT NULL,
	xforms_id TEXT,
	server_id INTEGER,
	geotag INTEGER,
	FOREIGN KEY (form_dbid) REFERENCES Forms (dbid)
);


/*
	The Instances table stores the xForms instance templates.  The W3C xForms spec allows
	multiple instances per model, but this is not currently used.
	
	dbid:			Primary Key
	model_dbid:		Ref back to model containing this instance
	xml:            Serialized (XML) instance template
*/
CREATE TABLE Instances (
	dbid INTEGER PRIMARY KEY,
	model_dbid INTEGER NOT NULL,
	xml BLOB,
	FOREIGN KEY (model_dbid) REFERENCES Models (dbid)
);


/*
	The Records table stores in-progress and completed results. When we want to begin filling-in
	a new Record (result set) we copy the appropriate instance. As questions (controls) are
	answered the 'result' XML document is populated.
	
	dbid:			Primary Key
	instance_dbid:	Ref back to the instance
	result:			Serializes (XML) result
	state:			-1 = In Progress
					0 = Completed
					1 = Submitted
	control_dbid:	Ref to the most-recent accesses contol. Allows us to resume an in-progress
					survey where we left off. Will initially be set to forms first control. If
					survey is completed, will be the last control.
	create_date:	(Local) Date/Time this record was created ("YYYY-MM-DD HH:MM:SS.SSS")
	complete_date:	(Local) Date/Time this record was completed ("YYYY-MM-DD HH:MM:SS.SSS")
	submit_date:	(Local) Date/Time this record was submitted ("YYYY-MM-DD HH:MM:SS.SSS")
*/

CREATE TABLE Records (
	dbid INTEGER PRIMARY KEY,
	instance_dbid INTEGER NOT NULL,
	result BLOB,
	state INTEGER,
	control_dbid INTEGER NOT NULL,
	create_date REAL,
	complete_date REAL,
	submit_date REAL,
	FOREIGN KEY (instance_dbid) REFERENCES Instances (dbid),
	FOREIGN KEY (control_dbid) REFERENCES Controls (dbid)
);

/*

*/
CREATE TABLE Questions (
	dbid INTEGER PRIMARY KEY,
	record_dbid INTEGER NOT NULL,
	control_dbid INTEGER NOT NULL,
	next_question INTEGER,
	relevant INTEGER NOT NULL,
	required INTEGER NOT NULL,
	answered INTEGER NOT NULL,
	answer TEXT,
	FOREIGN KEY (record_dbid) REFERENCES Records (dbid),
	FOREIGN KEY (control_dbid) REFERENCES Controls (dbid)
);
CREATE INDEX Questions_Record_Index ON Questions (record_dbid);
CREATE INDEX Questions_Control_Index ON Questions (control_dbid);
CREATE INDEX Questions_Relevant_Index ON Questions (relevant);
CREATE INDEX Questions_Answered_Index ON Questions (answered);

/*
	Bindings are used to add constraints or additional logic to a portion of the instance.
    Constraints and control-flow are achieved by specifying xPath expressions which are evaluated
    against the current <instance/> data.
    
	
	dbid:				Primary Key

	model_dbid:			Ref back to model containing this binding
	
	xforms_id:			The xForms id of this binding

	nodeset:			An xPath expression that selects which instance nodes this binding applies to
	
	constraint_expression:	xPath expression that is evaluated after question is answered.  If the expression evaluates
							to 'false' then the question is not accepted and the user must choose/enter a different answer

	constraint_message:		Custom alert displayed to the user if the constraint is not satisfied
	
	type:				Datatype.  Controls which type of GUI form is displayed for the specific input control
	
	required:			An xPath expression.  If the expression evaluates to 'true' an answer must be provided
						before user can continue to a new question.  Usually forms will simply have "true()"
						
	relevant:			An xPath expression used for skip logic.  If 'true' the question is shown, otherwise the
						question is skipped
*/
CREATE TABLE Bindings (
	dbid INTEGER PRIMARY KEY,
	model_dbid INTEGER NOT NULL,
	xforms_id TEXT,
	nodeset TEXT,
	constraint_expression TEXT,
	constraint_message TEXT,
	type TEXT,
	required TEXT,
	relevant TEXT,
	FOREIGN KEY (model_dbid) REFERENCES Models (dbid)
);

-- We index the xforms_id field because this field is used
-- by the Controls table
CREATE INDEX Bindings_xForms_ID_Index ON Bindings (xforms_id);


/*
	The Controls table stores each of the controls for the form. Each Control
	maps one-to-one to a single question that is displayed to the user.
	Additionally there is a Control_Types table that is used as a lookup for 
	the names of the various types of controls.
	
	dbid:				Primary Key
	
	type:				Ref to Control_Types lookup table
	
	ref:				xPath expression that selects the instance node to insert
						the result of this control.  If no 'ref' is speficied then
						binding_dbid must be specified.
	
	binding_xforms_id:	Ref to binding for this control. Note: this is a reference
						to the text binding name (Bindings.xforms_id) not the dbid
						primary key
						
	label:				Primary message/question to display to the user
	
	hint:				Secondary message/question to display to the user	
*/

CREATE TABLE Control_Types (
	type INTEGER,
	type_name TEXT
);

-- The xForms spec has many different types of controls.  Currently
-- only this sub-set is supported:
CREATE INDEX Control_Types_Type_Index ON Control_Types (type);
INSERT INTO Control_Types (type, type_name) VALUES (0, 'output');
INSERT INTO Control_Types (type, type_name) VALUES (1, 'input');
INSERT INTO Control_Types (type, type_name) VALUES (2, 'select');
INSERT INTO Control_Types (type, type_name) VALUES (3, 'select1');

CREATE TABLE Controls (
	dbid INTEGER PRIMARY KEY,
	form_dbid INTEGER NOT NULL,
	type INTEGER,
	ref TEXT,
	binding_xforms_id TEXT,
	label TEXT,
	hint TEXT,	
	FOREIGN KEY (form_dbid) REFERENCES Forms (dbid),
	FOREIGN KEY (binding_xforms_id) REFERENCES Bindings (xforms_id),
	FOREIGN KEY (type) REFERENCES Control_Types(type)
);


/*
	For 'select' or 'select1' controls the user picks from a list
	of possible values.
	
	dbid:			Primary Key
	control_dbid:	Ref back to the select or select1 control
	label:			Text to display to the user
	value:			Text to insert into the instance if this value is chosen
*/
CREATE TABLE Control_Items (
	dbid INTEGER PRIMARY KEY,
	control_dbid INTEGER,
	label TEXT,
	value TEXT,	
	FOREIGN KEY (control_dbid) REFERENCES Controls (dbid)
);