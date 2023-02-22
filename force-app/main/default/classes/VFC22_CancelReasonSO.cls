/*
----------------------------------------------------------------------
-- - Name          : VFC22_CancelReasonSO
-- - Author        : VSU
-- - Description   : Controller for VFP22_CancelReasonSO
--
-- Maintenance History:
--
-- Date      Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 19-JUL-2018  VSU    1.0      C-002565 CANCELATION PICKLIST IN SO
-- 14-JAN-2022  NPE    1.1      C-004547: Not allow the BS to cancel the SO without cancelling reason (Total Cancelation)
----------------------------------------------------------------------
**********************************************************************
*/
public class VFC22_CancelReasonSO{
    public String soId{get;set;}
    public PrerequisiteOrder__c so{get;set;}
    
    public VFC22_CancelReasonSO() {
        if(ApexPages.currentPage().getParameters().get('Id') != null){
            soId = ApexPages.currentPage().getParameters().get('Id');
            system.debug('##id so: '+ApexPages.currentPage().getParameters().get('Id'));
            so = [select id,cancelationReason__c, TECH_BodyshopCountryCode__c from PrerequisiteOrder__c where id=: soId LIMIT 1]; //NPE  C-004547
            system.debug('##so: '+so);
        }
    }
    
    public PageReference savePicklist(){
        try{
            system.debug('##so: '+so.id);
            if(so.cancelationReason__c != '' && so.cancelationReason__c != null){
                so.Comment__c = so.cancelationReason__c;
                so.Status__c = 'CANCELED';
                update so;      
            }    
                
            //NPE  C-004547
            else {
                if (so.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeES)){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,  Label.ReasonCancellation));
                }
            }   
        }
        catch(Exception e){
            system.debug('##e.getMessage() '+e.getLineNumber());
        }
        return null;
    }

    /*public static List<SelectOption> getMySelectOptions() {

        // do a field describe of the picklist field
        Schema.DescribeFieldResult describeResult = PrerequisiteOrder__c.cancelationReason__c.getDescribe();

        // get the picklist values from this describe result
        List<Schema.PicklistEntry> entries = describeResult.getPicklistValues();

        // list of options to be returned to the VF page
        List<SelectOption> optionsToReturn = new List<SelectOption>();

        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                optionsToReturn.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }

        return optionsToReturn;
    }*/
}