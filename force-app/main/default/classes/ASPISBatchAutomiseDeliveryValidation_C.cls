/*************************************************************************************
Class Name - ASPISBatchAutomiseDeliveryValidation_C
Version - 1.0
Created Date - 26 Feb 2016
Function -

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Welsa C      14/04/2020   used to target specific SO in custom label ASPISBatchAutomiseDeliveryValidationSO
*************************************************************************************/

/************************************************************************************
Execute batch on execute Anonymous:
Database.executeBatch(new ASPISBatchAutomiseDeliveryValidation_C(), 200);
*************************************************************************************/
global class ASPISBatchAutomiseDeliveryValidation_C implements Schedulable, Database.Batchable<sObject>,Database.Stateful
{
    //AMI 27/02/18 : Adding Callout to POSTSO after batch finishes run
    //             : this set will be used to hold all SO id for them to be processed in batch in the finish method
    set <id> setSOId = new set <id>();
    
    public String query =   'SELECT Id, OrderLine__c, OrderLine__r.OriginalItem__c, OrderLine__r.OriginalItem__r.OriginalItem__c, PrerequisiteOrder__c ' + 
                            'FROM Offer__c ' + 
                            'WHERE Accepted__c = \'YES\' ' + 
                            'AND DeliveryStatus__c = \'INDELIVERY\' ' + 
                            'AND Prerequisiteorder__r.SLAInDeliveryLevel3__c <= TODAY ' + 
                            'AND Prerequisiteorder__r.Status__c IN (\'INDELIVERY\', \'DELIVERED\') ' + (Test.isRunningTest() ? '' : ('and Prerequisiteorder__c IN ' + System.label.ASPISBatchAutomiseDeliveryValidationSO))
                            ;

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ASPISBatchAutomiseDeliveryValidation_C(), 15);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List <Offer__c> scope) {
        System.debug('-------------------------- START METHOD ASPISBatchAutomiseDeliveryValidation_C - execute --------------------------');

        List<Offer__c> offerListToUpdate            = new List<Offer__c>();
        Map<Id, OrderLine__c> orderLinesToUpdate    = new Map<Id, OrderLine__c>();

        for(Offer__c off : scope)
        {
            //DUN 27/05/2016  C-001637 add field RealDeliveryDate__c
            offerListToUpdate.add(new Offer__c( Id = off.Id, 
                                                DeliveryStatus__c = 'DELIVERED', 
                                                RealDeliveryDate__c = System.today()));
            
            // There is no need to update the orderline related directly to the offer as it will be updated by the trigger
            // Update the parent orderline of the offer
            if(off.OrderLine__c != null &&
               off.OrderLine__r.OriginalItem__c != null)
            {
                orderLinesToUpdate.put(off.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                    = off.OrderLine__r.OriginalItem__c,
                                                                                          DeliveryStatus__c     = 'DELIVERED',
                                                                                          RealDeliveryDate__c   = System.today()));
            }

            //AMI 27/02/18 : Adding Callout to POSTSO after batch finishes run
            //             : build setSOId
            setSOId.add(off.PrerequisiteOrder__c);
        }

        if(offerListToUpdate.size() > 0){
            update offerListToUpdate;
        }

        // Updating the parents of the orderline attached to the offer
        if(orderLinesToUpdate.size() > 0)
        {
            update orderLinesToUpdate.values();
        }

        System.debug('-------------------------- END METHOD ASPISBatchAutomiseDeliveryValidation_C - execute --------------------------');
    }

    global void finish(Database.BatchableContext BC) {
        //AMI 27/02/18 : Adding Callout to POSTSO after batch finishes run
        //             : call batch to execute callout based on setSOId
        if(!test.isRunningTest()){
            system.debug('## setSOId ' + setSOId);
            if(!setSOId.isEmpty()){
                database.executeBatch(new ASPISBatchRestPostSO(setSOId),system.label.BatchSizeForICESO != null ? integer.valueOf(system.label.BatchSizeForICESO) : 25);
            }
        }
    }
}