/*************************************************************************************
Class Name - ASPISProcessBuilderGlobalVariables
Version - 1.0
Created Date - 21 JAN 2015
Function - Define all invocable variables to be used in invocable methods

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* Ashwina Seetaram		27/01/2016  Original Version
*************************************************************************************/

global with sharing class ASPISProcessBuilderGlobalVariables {
	global class variableWrapper{
        @InvocableVariable
        public String objCode;
        @InvocableVariable
        public String countryCode;  
        @InvocableVariable
        public Id accountId;
        @InvocableVariable
        public Id assessmentId;  
        @InvocableVariable
        public Id poId;
        @InvocableVariable
        public Id soId;  
        @InvocableVariable
        public String comment; 
        @InvocableVariable
        public String userId; 
        @InvocableVariable
        public String csProcessName;
    }
}