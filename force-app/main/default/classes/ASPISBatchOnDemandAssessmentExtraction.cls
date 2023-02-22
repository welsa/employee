/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchOnDemandAssessmentExtraction 
  -- - Author        : WCH
  -- - Description   : Class populating Assessment__c.BI_on_demand_extraction_date__c so that SystemModstamp is updated for BI Assessment Extraction
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 16-JUL-2016  WCH    1.0     C-003852 - BI needs to be able to identify which records on the object assessments they want ETL to extract on-demand.
  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class ASPISBatchOnDemandAssessmentExtraction implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    String errorMsg;

    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new ASPISBatchOnDemandAssessmentExtraction(), 200);  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START ASPISBatchOnDemandAssessmentExtraction - start ----------------------------------');

        errorMsg = ''; 
        String query = 'select Id'+
                       ' From Assessment__c ' +
                       ' Where TECH_EntityCountryCode__c IN ' + (Test.isRunningTest() ? '(\'FR\',\'IT\',\'DE\',\'ES\')' : System.label.BI_OnDemandExtraction_CountryCodeList) + ' AND CALENDAR_YEAR(createddate) IN '+(Test.isRunningTest() ? ('('+Date.Today().Year()+')') : System.label.BI_OnDemandExtraction_YearList);
        system.debug('## query:'+query);
        System.debug('---------------------------------- END ASPISBatchOnDemandAssessmentExtraction - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Assessment__c> scope) {

        System.debug('---------------------------------- START ASPISBatchOnDemandAssessmentExtraction - execute ----------------------------------');

        List<Assessment__c> listAssessmentToUpdate = new List<Assessment__c>();
        
        for (Assessment__c currentAssessment : scope){
            currentAssessment.BI_on_demand_extraction_date__c=system.today();
            listAssessmentToUpdate.add(currentAssessment);
        }
        
        if(listAssessmentToUpdate.size() > 0){
            Database.SaveResult[] srList = Database.update(listAssessmentToUpdate, false);Integer i=0;
            for(Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg+=(listAssessmentToUpdate.get(i).Id+';'+err.getStatusCode() + ': ' + err.getMessage()+'.Fields that affected this error:'+err.getFields()+'\n');
                    }
                }
                i++;
            }
        }
        
        System.debug('---------------------------------- END ASPISBatchOnDemandAssessmentExtraction - execute ----------------------------------');
        
    }

    global void finish(Database.BatchableContext context) {
        Document d = new Document();
        d.Name = 'ASPISBatchOnDemandAssessmentExtraction_'+(System.today().format());
        String myContent = errorMsg;
        d.folderId='00l24000000n9pq';
        d.Body = Blob.valueOf(myContent);
        d.ContentType = 'text/plain';
        d.Type = 'txt';insert d;
    }

}