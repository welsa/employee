/*************************************************************************************
Class Name - ASPISCtrlMasterRuleClone
Version - 1.0
Created Date - 15 APRIL 2015
Function - Controller extension for cloning of master rule object

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole (SC)    15/04/2015  Original Version
* Hirikesh Dussoye      20/04/2015  Use max Version ann icrement by 1 for clone rule 
* Dourga U              20/08/2015  Added code to create log in catch part
* Ashwina S             18/11/2015  C-001342
**************************************************************************************/
public with sharing class ASPISCtrlMasterRuleClone {

	//Varaible Declaration
    public ApexPages.StandardController controller {get;set;}
    public MasterRules__c mr {get;set;}
    public Id newMRId {get;set;}

	//Initialisation of constructor
    public ASPISCtrlMasterRuleClone(ApexPages.StandardController controller) {
        this.controller = controller;
        mr = (MasterRules__c)controller.getRecord();
    }

	//Method of type page reference to clone master rule(parent) and detail rules(child)
    public PageReference cloneMasterDetail(){
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
		
		//Varaible Declaration
        MasterRules__c newMR;
        List<Schema.SObjectField> fieldListMasterRule = schema.SObjectType.MasterRules__c.fields.getMap().values();
        String masterRuleId = (String)mr.Id;
		
		//Building the string to query from master rule
        String queryMasterRule = 'SELECT ';
        for(Schema.SObjectField s : fieldListMasterRule){
            if( s.getDescribe().isUpdateable()){
                queryMasterRule += s.getDescribe().getName() + ',';  
            }         
        }
        queryMasterRule = queryMasterRule.substring(0,queryMasterRule.length()-1);
        queryMasterRule += ' FROM MasterRules__c WHERE id =: masterRuleId';
        try{
			//Selecting the master rule to clone
            mr =  Database.query(queryMasterRule); /*[select Id, ConditionLogic__c , Description__c , Entity__c , FilterLogic__c , InputLogic__c ,
                         NumberOfRuleDetails__c , Process__c , RuleStatus__c , RuleUnicityHandler__c ,
                         sObject__c , version__c , OrderExecution__c , RuleSet__c , RecordTypeId,Country__c
                  from MasterRules__c
                  where id =:mr.Id];*/
            
			//Selecting the version of the master rule
            list<aggregateResult> aggResults = [SELECT MAX(version__c)maxVersion FROM MasterRules__c where Entity__c = :mr.Entity__c AND Process__c =  :mr.Process__c];
            
			//Cloning the master rule
            newMR = mr.clone();
            newMR.TECH_MasterClone__c = mr.Id;
            
            //Incrementing the version of the rule
            if(aggResults[0].get('maxVersion') != null){
                newMR.version__c = Integer.valueOf(aggResults[0].get('maxVersion'))+1;
            }
            else{
                newMR.version__c = 1;
            }
			//Setting the status to draft, IsPrimary to false and ExternalID to null
            newMR.RuleStatus__c = 'DRAFT';
            newMR.IsPrimary__c = false;
			// ASE: 20151118: C-001342: clear the field External ID.
			newMR.ExternalID__c += '-cloned';
			
			//Inserting the master rule
            insert newMR;
            //mr.RuleStatus__c = 'ARCHIVED';
            //update mr;
			
            list <DetailRule__c> detailRuleList = new list <DetailRule__c>();
            list<Schema.SObjectField> fieldListDetailRule = schema.SObjectType.DetailRule__c.fields.getMap().values();

			//Building the string to query from detail rule
            String queryDetailRule = 'SELECT ';
            for(Schema.SObjectField s : fieldListDetailRule){
                if(s.getDescribe().isUpdateable()){
                    queryDetailRule += s.getDescribe().getName() + ',';   
                }            
            }
            queryDetailRule = queryDetailRule.substring(0,queryDetailRule.length()-1);
			// ASE: 20151118: C-001342: When we clone a master rule, the field Number of all criterias is different than the original. Added 'Order BY Number__c'
            queryDetailRule += ' FROM DetailRule__c WHERE MasterRule__c = : masterRuleId Order BY Number__c';
			
			//Selecting the detail rules to clone and adding them to a list
            for(DetailRule__c dr : Database.query(queryDetailRule) /*[select MasterRule__c , Action__c , Description__c , FieldsAPI__c , Number__c , 
                                           Operator__c , OutputParam__c , Process__c , sObject__c , Value__c,ValueFrom__c   
                                    from DetailRule__c
                                    where MasterRule__c = :mr.Id]*/){
                DetailRule__c newDR = dr.clone();
                newDR.MasterRule__c = newMR.Id;
                detailRuleList.add(newDR);
            }

            //system.debug('## detailRuleList'+detailRuleList.size());
			// inserting the detail rules
            if(detailRuleList.size() > 0){
                insert detailRuleList;
            }
        }
        catch (Exception e){	
			//Creating a log if exception occurs
            Utils_ManageLogs.createLogFromException('ASPISCtrlMasterRuleClone', 'MasterRule__c', e);
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        newMRId = newMR.Id;
        return null;
    }
}