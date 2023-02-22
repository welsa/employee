/*
  ----------------------------------------------------------------------
  -- - Name          : PRE_SchedulableDailyDeleteDarvaTags
  -- - Author        : NPE
  -- - Description   : Schedulable class for PRE_BatchDeleteRecords
  --
  -- Maintenance History:
  --
  -- Date         	Name  Versions  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 10-DEC-2021	NPE		1.0    	Initial version
  ----------------------------------------------------------------------
  **********************************************************************
*/

global class PRE_SchedulableMonthlyDeleteRecords  implements schedulable {
    
    global void execute(SchedulableContext sc) {

        ConfigurationFlux__mdt cf = ConfigurationFlux__mdt.getInstance('PRE_SchedulableDeleteRecords');
        System.debug('##Shane run delete record' + cf);
        if (cf != null && cf.Runnable__c) {

            List<NOB_BatchDeleteRecordsConfigs__mdt> lstBatchDelete = NOB_BatchDeleteRecordsConfigs__mdt.getAll().values();
            System.debug('##Shane BU' + lstBatchDelete);
            for (NOB_BatchDeleteRecordsConfigs__mdt bu : lstBatchDelete) {
                String queryDarvatags;
                String queryR3Assessments;

                if (bu.Active__c && bu.DeveloperName == 'NOB_DarvaTags') {
                    queryDarvatags = bu.Query__c;
                    Database.executeBatch(new PRE_BatchDeleteRecords(queryDarvatags,false), 200);
                    
                }

                if (bu.Active__c && bu.DeveloperName == 'ASPIS_DeleteR3Assessments') {
                    queryR3Assessments = bu.Query__c;
                    Database.executeBatch(new PRE_BatchDeleteRecords(queryR3Assessments,true ), 200);
                    System.debug('##Shane run delete record');
                }
            }

        }
    }
}