public without sharing class PRE_DarvaLogEventsTriggerHandler {
    
    public void handleAfterInsert(List<PRE_DarvaLog_Events__e> lstPRE_DarvaLogEvt){
        this.updateDarvaLogStatus(lstPRE_DarvaLogEvt);
    }
    
    private void updateDarvaLogStatus(List<PRE_DarvaLog_Events__e> lstPRE_DarvaLogEvt){
        List<NOB_DarvaMessageLog__c> lstDarvaLogtoUpdate = new List<NOB_DarvaMessageLog__c>();
        for (PRE_DarvaLog_Events__e DE : lstPRE_DarvaLogEvt) {
            NOB_DarvaMessageLog__c dL = new NOB_DarvaMessageLog__c(
                Id= DE.PRE_DarvaLogId__c, 
                NOB_Status__c= DE.PRE_DarvaLogStatus__c
            );
            
            lstDarvaLogtoUpdate.add(dL);
        }
        
        if (lstDarvaLogtoUpdate.size()>0) { update lstDarvaLogtoUpdate; }
    }
}