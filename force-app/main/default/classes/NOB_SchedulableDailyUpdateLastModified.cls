/**
 * @description       : Schedulable class for NOB_BatchUpdateLastModifiedDate
 * @author            : GBH
 * @group             : 
 * @last modified on  : 08-04-2021
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-04-2021   GBH   Initial Version
**/

global class NOB_SchedulableDailyUpdateLastModified  implements schedulable {
    
    global void execute(SchedulableContext sc) {

        ConfigurationFlux__mdt cf = ConfigurationFlux__mdt.getInstance('NOB_SchedulableDailyUpdateLastModified');

        if (cf != null && cf.Runnable__c) {

            List<NOB_BatchUpdateLastModifiedDate__mdt> lstBatchUpdate = test.isRunningTest()? new List<NOB_BatchUpdateLastModifiedDate__mdt>{ new NOB_BatchUpdateLastModifiedDate__mdt(active__c = true, query__c = 'SELECT Id, NOB_TECH_ExtractByETL__c, Status, EndDate FROM ServiceContract WHERE Status = \'Expired\' AND NOB_TECH_ExtractByETL__c = False AND EndDate < TODAY',  FieldToUpdate__c = 'NOB_TECH_ExtractByETL__c===true;NOB_ContractsType__c===Partinium;NOB_TauxEngagement__c===3;StartDate===11/27/2021;NOB_Dispo_entrees_annee__c===5') } : NOB_BatchUpdateLastModifiedDate__mdt.getAll().values();
            
            for (NOB_BatchUpdateLastModifiedDate__mdt bu : lstBatchUpdate) {
                String query;
                List<String> fieldsToUpdate = new List<String>();
                map <String, String> mapfieldValue = new map <String, String>();

                if (bu.Active__c) {
                    query = bu.Query__c;

                    List<String> tmp = bu.FieldToUpdate__c.split(';');

                    for (String s : tmp) {
                        List<String> fieldValues = s.split('===');
                        fieldsToUpdate.add(fieldValues[0]);
                        mapfieldValue.put(fieldValues[0], fieldValues[1]);
                    }
                    
                    
                    Database.executeBatch(new NOB_BatchUpdateLastModifiedDate(query, fieldsToUpdate, mapfieldValue), 200);
                }
            }

        }
    }
}