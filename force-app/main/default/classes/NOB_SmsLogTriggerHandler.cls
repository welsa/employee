/**
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_SmsLogTriggerHandler
  -- - Author        : hansraj.mohiputlall@spoonconsulting.com
  -- - Description   : 
  -- - #Ticket       : 
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 07-07-2021      HMO    1.0     Initial version - RSIW 10319
  **********************************************************************
*/

public without sharing class NOB_SmsLogTriggerHandler {

    private boolean bIsExecuting = false;
	private integer iBatchSize = 0;

    public NOB_SmsLogTriggerHandler(Boolean executing, Integer size) {
        this.bIsExecuting = executing;
        this.iBatchSize = size;
    }

    public void onAfterInsert(List<NOB_SMSLog__c> lstNewLogs){
        Set<Id> setSmsLogIds = new Set<Id>();
        if (lstNewLogs.size()>0){
            for(NOB_SMSLog__c log : lstNewLogs){
                setSmsLogIds.add(log.Id);
            }
            NOB_AP51_SMSSender.sendSMS(setSmsLogIds);
        }
    }

    public void onAfterUpdate(List<NOB_SMSLog__c> lstNewLogs){
        Set<Id> setSmsLogIds = new Set<Id>();
        if (lstNewLogs.size()>0){
            for(NOB_SMSLog__c log : lstNewLogs){
                setSmsLogIds.add(log.Id);
            }
            NOB_AP51_SMSSender.sendSMS(setSmsLogIds);
        }
    }

}