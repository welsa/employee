/*************************************************************************************
Class Name - ASPISProcessFlow
Version - 1.0
Created Date - 21 JAN 2015
Function - ASPISProcessFlow call apex class

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina Seetaram      21/01/2016  Original Version
*************************************************************************************/
global without sharing class ASPISProcessFlow {

    public class variableWrapper{
        @InvocableVariable
        public String sObjectId;
        @InvocableVariable
        public String sObjectType;  
    }

    @InvocableMethod
    public static void updateDateField(list<variableWrapper> variableList){
        //system.debug('######## start of updateDateField');
        //system.debug('######## variableList: '+variableList);
        //Variables
        set<Id> invIdSet = new set<Id>(); 
        set<Id> POidSet = new set<Id>(); 
        list<Invoice__c> updatedInvList = new list<Invoice__c>();
        list<PurchaseOrder__c> updatedPOList = new list<PurchaseOrder__c>();

        // processing variableList to get invID and POId
        for(variableWrapper vw: variableList){
            if(vw.sObjectType == 'Invoice'){
                invIdSet.add(vw.sObjectId);
            }
            if(vw.sObjectType == 'PurchaseOrder'){
                POidSet.add(vw.sObjectId);
            }
        }

        updatePoInvoiceSync(invIdSet, POidSet);
/*
        //updatePoInvoice(invIdSet, POidSet);
        // retrive custom setting CaseDetailsProcessMapping__c
        Map<String,CaseDetailsProcessMapping__c> configCaseDetails = CaseDetailsProcessMapping__c.getAll();
        
        if(invIdSet.size()>0){
            // update TriggeredDelayDate__c in Invoice
            for(Invoice__c inv : [Select id, TriggeredDelayDate__c, TechCountryCode__c from Invoice__c where id IN : invIdSet]){
                if(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid')!=null){
                    if(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid').TriggeredDelayDays__c!=null){
                        Invoice__c updatedInv  = new Invoice__c(id= inv.Id, TriggeredDelayDate__c = system.now().addDays(Integer.valueOf(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid').TriggeredDelayDays__c)));
                        updatedInvList.add(updatedInv);
                    }
                }
                //system.debug(updatedInvList);
            }
        }
        
        if(POidSet.size()>0){
            // update TriggeredDelayDate__c in PurchaseOrder
            for(PurchaseOrder__c PO : [Select id, TriggeredDelayDate__c, TECH_AssessmentCountryCode__c from PurchaseOrder__c where id IN : POIdSet]){
                if(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated')!=null){
                    if(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated').TriggeredDelayDays__c!=null){
                        PurchaseOrder__c updatedPO  = new PurchaseOrder__c(id= PO.Id, TriggeredDelayDate__c = system.now().addDays(Integer.valueOf(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated').TriggeredDelayDays__c)));
                        //Shamina M - 20160212-uncomment for testing delay of 2 mins
                        //PurchaseOrder__c updatedPO  = new PurchaseOrder__c(id= PO.Id, TriggeredDelayDate__c = system.now().addMinutes(2));            
                        
                        updatedPOList.add(updatedPO);
                    }
                }
                //system.debug(updatedPOList); 
            }
        }
        //Shamina M -20160212 - manage exceptions
        try{
            system.debug('updatedInvList.size()='+updatedInvList.size());
            if(updatedInvList.size()>0){
                update updatedInvList;
            }   
            system.debug('updatedPOList.size()='+updatedPOList.size());
            if(updatedPOList.size()>0){
                update updatedPOList;
            }
        }
        catch(Exception ex){
            Utils_ManageLogs.createLogFromException('ASPISProcessFlow', null, ex);
        }*/
    }


    // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded / problem with more than 2000 invoices)
    @future
    public static void updatePoInvoice(Set<Id> invIdSet, Set<Id> POidSet) {
        updatePoInvoiceSync(invIdSet, POidSet);
    }

    public static void updatePoInvoiceSync(Set<Id> invIdSet, Set<Id> POidSet) {

        list<Invoice__c> updatedInvList = new list<Invoice__c>();
        list<PurchaseOrder__c> updatedPOList = new list<PurchaseOrder__c>();

        // retrive custom setting CaseDetailsProcessMapping__c
        Map<String,CaseDetailsProcessMapping__c> configCaseDetails = CaseDetailsProcessMapping__c.getAll();
        
        if(invIdSet != null && invIdSet.size()>0){
            // update TriggeredDelayDate__c in Invoice
            for(Invoice__c inv : [Select id, TriggeredDelayDate__c, TechCountryCode__c from Invoice__c where id IN : invIdSet]){
                if(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid')!=null){
                    if(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid').TriggeredDelayDays__c!=null){
                        Invoice__c updatedInv  = new Invoice__c(id= inv.Id, TriggeredDelayDate__c = system.now().addDays(Integer.valueOf(configCaseDetails.get(inv.TechCountryCode__c+'-INV-OrderNotPaid').TriggeredDelayDays__c)));
                        updatedInvList.add(updatedInv);
                    }
                }
                //system.debug(updatedInvList);
            }
        }
        
        if(POidSet != null && POidSet.size()>0){
            // update TriggeredDelayDate__c in PurchaseOrder
            for(PurchaseOrder__c PO : [Select id, TriggeredDelayDate__c, TECH_AssessmentCountryCode__c from PurchaseOrder__c where id IN : POIdSet]){
                if(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated')!=null){
                    if(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated').TriggeredDelayDays__c!=null){
                        PurchaseOrder__c updatedPO  = new PurchaseOrder__c(id= PO.Id, TriggeredDelayDate__c = system.now().addDays(Integer.valueOf(configCaseDetails.get(PO.TECH_AssessmentCountryCode__c+'-PO-NoInvoiceCreated').TriggeredDelayDays__c)));
                        //Shamina M - 20160212-uncomment for testing delay of 2 mins
                        //PurchaseOrder__c updatedPO  = new PurchaseOrder__c(id= PO.Id, TriggeredDelayDate__c = system.now().addMinutes(2));            
                        
                        updatedPOList.add(updatedPO);
                    }
                }
                //system.debug(updatedPOList); 
            }
        }
        //Shamina M -20160212 - manage exceptions
        try{
            if(updatedInvList.size()>0){
                update updatedInvList;
            }   
            if(updatedPOList.size()>0){
                update updatedPOList;
            }
        }
        catch(Exception ex){
            Utils_ManageLogs.createLogFromException('ASPISProcessFlow', null, ex);
        }
    }
}