/*************************************************************************************
Class Name - NOB_TransactionTriggerHandler
Version - 1.0
Created Date - 10/12/2021
Function - Class to Manage transaction Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Welsa        10/12/2021  Original Version
*************************************************************************************/
public without sharing class NOB_TransactionTriggerHandler {
    private boolean bIsExecuting = false;
    private integer iBatchSize = 0;
    public static boolean bFirstRun = true;
    
    public NOB_TransactionTriggerHandler(boolean isExecuting, integer size){
        bIsExecuting = isExecuting;
        iBatchSize = size;
    }
    public void OnBeforeUpdate(PFR_Transaction__c[] oldTransaction, PFR_Transaction__c[] updatedTransaction, Map<ID, PFR_Transaction__c> TransactionMap){
        System.debug('OnBeforeUpdate transaction');
        Boolean isPref = NOBTools.isPrefikarUser();
        Boolean isMigrationUser = NOBTools.isMigrationUser();
        for(PFR_Transaction__c t : updatedTransaction){
            if(t.PFR_ReferenceFinDoc__c != TransactionMap.get(t.id).PFR_ReferenceFinDoc__c && !isMigrationUser && !t.PRE_canUpdateDocFin__c){
                t.PFR_ReferenceFinDoc__c=TransactionMap.get(t.id).PFR_ReferenceFinDoc__c;
            }
            if(t.PRE_canUpdateDocFin__c){t.PRE_canUpdateDocFin__c=false;}
  //SPOON - 16-02-2022 - RSIW 10890
            if (!isMigrationUser && isPref &&  t.PFR_TransactionStatus__c != TransactionMap.get(t.Id).PFR_TransactionStatus__c && t.PFR_TransactionStatus__c == 'NP' && TransactionMap.get(t.Id).PFR_TransactionStatus__c == 'AT' && (t.PFR_Tech_TransactionStatus__c == 'ST' || t.PFR_Tech_TransactionStatus__c == 'PR')){
          
                t.PFR_Tech_TransactionStatus__c = 'TP5';
            }
        }
        
    }

}