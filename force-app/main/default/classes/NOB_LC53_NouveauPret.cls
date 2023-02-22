public without sharing class NOB_LC53_NouveauPret {
    public NOB_LC53_NouveauPret() {

    }

    @AuraEnabled
    public static Boolean checkVR(String vrId){
        
            Boolean isObsolete = false;
            isObsolete = [SELECT Id, NOB_IsObsolete__c from Asset WHERE Id =: vrId]?.NOB_IsObsolete__c;
            return isObsolete;
        
    }

    @AuraEnabled
    public static workOrder getWorkOrderFields(String recordId){
     
            WorkOrder wo = null;
            for (WorkOrder worder : [SELECT Id, NOB_VehiculeReturnDate__c, WorkOrderNumber, NOB_TECHDateRendezVousPrisEnCharge__c from WorkOrder where Id =: recordId]){
               wo = worder;
            }
            return wo != null ? wo : new WorkOrder();
    }
}