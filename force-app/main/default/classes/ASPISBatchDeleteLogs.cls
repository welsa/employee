/*************************************************************************************
Class Name - ASPISBatchDeleteLogs
Version - 1.0
Created Date - 04 AUG 2015
Function - Batch to delete Logs

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* Brayan Nunhuck 05/08/2015     Original Version
* Shamina M     16/02/2016      C-001518: Removed unnecessary debug logs
*************************************************************************************/
global class ASPISBatchDeleteLogs implements Database.Batchable<sObject> {
    
    String query;
    global map<String,DelayForDeletion__c> mapDelay;
    
    global ASPISBatchDeleteLogs() {
        mapDelay = DelayForDeletion__c.getAll();
        //system.debug('//// mapDelay: ' + mapDelay);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,Tech_FormulaCreatedDate__c from Log__c where ETL_INTERFACE_NAME__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Log__c> scope) {
        //system.debug('/// scope.size(): ' + scope.size());
        Decimal delay = 0;
        list<Log__c> logListToDelete = new list<Log__c>();
        if(mapDelay.containsKey('DELETE-FROM')){
            if(mapDelay.get('DELETE-FROM').PurgePeriodLogsDays__c != null){
                delay = mapDelay.get('DELETE-FROM').PurgePeriodLogsDays__c;
            }
        }
        //system.debug('//// delay: ' + delay);

        if(delay > 0){
            Date todayDT = Date.today().addDays(-(integer.valueOf(delay)));
            //system.debug('//// todayDT: ' + todayDT);
            DateTime dtEnd = datetime.newInstance(todayDT.year(),todayDT.month(), todayDT.day());
            //system.debug('//// dtEnd: ' + dtEnd);

            if(scope.size() > 0){
                for(Log__c logs : scope){
                    //system.debug('//// logs.Tech_FormulaCreatedDate__c: ' + logs.Tech_FormulaCreatedDate__c);
                    if(logs.Tech_FormulaCreatedDate__c < dtEnd){
                        logListToDelete.add(logs);
                    }
                }
            }

            //system.debug('//// logListToDelete: ' + logListToDelete);
            if(logListToDelete.size() > 0){
                delete logListToDelete;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}