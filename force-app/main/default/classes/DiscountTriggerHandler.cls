/*************************************************************************************
Class Name - DiscountTriggerHandler
Version - 1.0
Created Date - 2 APR 2015
Function - Class to Manage Discount Changes.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      07/12/2015  Original Version
*************************************************************************************/
public class DiscountTriggerHandler {
 
    private boolean bIsExecuting = false;
    private integer iBatchSize = 0;
    public static boolean bFirstRun = true;
    public static Integer runNumber = 0;    
    
    public DiscountTriggerHandler(boolean isExecuting, integer size){
        bIsExecuting = isExecuting;
        iBatchSize = size;
    }
    
    public void OnBeforeInsert(Discount__c[] newDiscounts){
        for(Discount__c disc : newDiscounts){
            // Copy the values of multi-select picklist Brand in a text field.
            disc.TECH_BrandsText__c = disc.Brand__c;
        }
    }
    
    public void OnBeforeUpdate(Discount__c[] oldDiscounts, Discount__c[] updatedDiscounts, Map<ID, Discount__c> discountMap){
        for(Discount__c disc : updatedDiscounts){
            // Copy the values of multi-select picklist Brand in a text field.
            if(disc.Brand__c != discountMap.get(disc.Id).Brand__c)
                disc.TECH_BrandsText__c = disc.Brand__c;
        }
    }
}