/*
  ----------------------------------------------------------------------
  -- - Name          : PRE_BatchDeleteRecords
  -- - Author        : NPE
  -- - Description   : Batch to delete darva tags and R3 Assessments
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 10-DEC-2021	NPE		1.0    	Initial version
  -- 15-MAR-2022    NPE     1.1     C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
  -- 08-DEC-2022    RBE     1.2     C-004871: R4 Claims created from R3 NewAssessments are being deleted by the PRE_SchedulableMonthlyDeleteRecords batch
  ----------------------------------------------------------------------
  **********************************************************************
*/

public class PRE_BatchDeleteRecords implements Database.Batchable<SObject> {
    public final String Query;
    public  Boolean AssessmentR3;
    List<NOB_BatchDeleteRecordsConfigs__mdt> bu;
    Boolean R3AssessmentToDel = false;


    //NPE 09/03/2022 C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
    Set<Id> setcurrentAss = new Set<Id>();
    List <Database.Saveresult> lstResultsAssUpdate;
    Set<Assessment__c> assToUpdateSet = new Set<Assessment__c>();

    public PRE_BatchDeleteRecords(String q, Boolean R3AssessmentsToDel) { 
        Query=q;
        bu= bu;
        R3AssessmentToDel = R3AssessmentsToDel;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(Query);
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('#### scope ' + scope);
        if (scope.size() > 0) {
            //RBE 08/12/2022 C-004871
            Set<SObject> setsObjectToDelete = new Set<SObject>();
            Id claimRecTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            Id newAssRecTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            for (sObject o : scope) {
                String objectName = o.Id.getSObjectType().getDescribe().getName();
                System.debug('#### objectName ' + objectName);
                System.debug('#### o.Id ' + o.Id);

                //new sObject instance
                SObject record = Id.valueOf(o.Id).getSObjectType().newSObject();
                System.debug('#### record ' + record);

                
                //to del R3 assessment
                if (R3AssessmentToDel){
                    //RBE 08/12/2022 C-004871
                    system.debug('Object Record Type ' + o.get('RecordTypeId'));
                    //if object is a claim, delete the newAssessment from which it was created 
                    if(o.get('RecordTypeId') == claimRecTypeId && o.get('R3_Assessment__c') != null){
                        system.debug('Object: '+ o.Id +' is a Claim');

                        record.put('Id', o.get('R3_Assessment__c'));                                                
                        //NPE 09/03/2022 C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
                        setcurrentAss.add(o.Id);
                    }
                    // if object is a newAssessment, delete directly
                    else if(o.get('RecordTypeId') == newAssRecTypeId){
                        //KEM 07/11/2022 C-004540: check the checkbox "R3AssessmentToBeDeleted__c" R3 Assessment to be deleted
                        record.put('Id', o.Id);
                    } 
                    System.debug('####@@@ record2' + record);
                }

                //to del darva tags
                else {
                    record.put('Id', o.Id);
                    System.debug('@@@@ record3' + record);
                }
                try {
                    //RBE 08/12/2022 C-004871
                    if(record.get('Id') != NULL){
                        setsObjectToDelete.add(record);
                    }
                    
                    System.debug('#### setsObjectToDelete ' + setsObjectToDelete);
                } 
                catch (Exception e) {
                    Utils_ManageLogs.NOBCreateLogFromException('PRE_BatchDeleteRecords', objectName, e, o.Id);
                }
            }

            //delete sObject
            if (setsObjectToDelete.size()>0) { 
                
                //delete lstsObjectToDelete;         
                //RBE 08/12/2022 C-004871
                List<SObject> lstsObjectsToDelete = new List<sObject>(setsObjectToDelete);
                Database.DeleteResult[] drList = Database.delete(lstsObjectsToDelete, false);

                // Iterate through each returned result
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted account with ID: ' + dr.getId());

                        //NPE 09/03/2022 C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
                        if (R3AssessmentToDel){
                            if(setcurrentAss.size()> 0){
                                for( Id ass : setcurrentAss){
                                    assToUpdateSet.add(new Assessment__c(id=ass, R3AssessmentToBeDeleted__c = false)); 
                                }
                            }
                        }

                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.  ' + err.getMessage() );                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }

                //NPE 09/03/2022 C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
                if(!assToUpdateSet.isEmpty()){
                    List<Assessment__c> lstUpdateAss = new List<Assessment__c>(assToUpdateSet);
                    lstResultsAssUpdate = Database.update(lstUpdateAss, false);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        
    }
}