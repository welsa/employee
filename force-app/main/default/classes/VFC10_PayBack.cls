/*************************************************************************************
Class Name - VFC10_PayBack
Version - 1.0
Created Date - 22 MAR 2016
Function - Generate a "pay back" and "Generate again" process for invoices

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             22/03/2016  Original Version:C-001572:  
* Ashwina S             31/05/2016  Updated version:C-001572
*************************************************************************************/
public without sharing class VFC10_PayBack {
    public PrerequisiteOrder__c so{get;set;}

    public VFC10_PayBack(ApexPages.StandardController controller) {
        system.debug('######## START VFC10_PayBack');
        this.so = (PrerequisiteOrder__c)controller.getRecord(); 

        // query SO
        so = [Select Id
                    ,TECH_BodyshopCountryCode__c
                    ,Assessment__c
                    ,BodyShop__c
                    ,PaymentTerms__c
              from PrerequisiteOrder__c 
              where id =:this.so.id];   
        system.debug('######## END VFC10_GenerateInvoiceProcess');      
    }

    public PageReference payBackProcess(){
        system.debug('######## START payBackProcess');  
        list<Invoice__c> invoiceList = new list<Invoice__c>();
        List<Invoice__c> updatedInvList = new List<Invoice__c>();                   
        map<String, set<Id>> parentChildInvoiceSet = new map<String, set<Id>>();
        
        map<Id, Invoice__c> invoiceMap = new map<Id, Invoice__c>([Select Id, RecordTypeID, Type__c, ParentInvoice__c, (select id from offers__r), (select id from CreditNoteOffers__r) from Invoice__c where Number__c!=null and PrerequisiteOrder__c = :so.Id]);
                
        if (!invoiceMap.isEmpty()){ 
            //save keyset in a set and use in dynamic query
            set<ID> keys = invoiceMap.keyset();
            map<Id, Offer__c> updatedOfferMap = new map<Id, Offer__c>();  
            map<Id, Invoice__c> originalCloneMap = new map<Id, Invoice__c>();

            // dynamically select fields that can be created for invoice
            String invSOQL =getCreatableFieldsSOQL('Invoice__c', 'id in :keys');
            map<Id,Invoice__c> mapClonedInvoice = new map <Id,Invoice__c>((list<Invoice__c>)Database.query(invSOQL));
            for(Id invId: invoiceMap.keySet()){
                String externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());  
                Invoice__c clonedInv = mapClonedInvoice.get(invId).clone(false, true);
                clonedInv.Number__c=null;
                clonedInv.InvoiceReference__c=null; 
                clonedInv.Date__c= system.today();
                clonedInv.TECH_InvoiceParent__c= externalNumber;
                clonedInv.InvoiceSent__c= false;
                clonedInv.TECH_Number__c = null;//RLA 15/06/2018 case 2617 - Duplicate TechNumber
                
                if(invoiceMap.get(invId).Type__c =='INVOICE'){                  
                    clonedInv.Type__c ='CREDITNOTE';
                    clonedInv.RecordTypeID =Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();
                }
                else if(invoiceMap.get(invId).Type__c =='CREDITNOTE'){
                    clonedInv.Type__c ='INVOICE';
                    clonedInv.RecordTypeID =Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
                }
                // ASE: 30/05/2016
                // attaching offers     
                for(Offer__c offer:invoiceMap.get(invId).offers__r){
                    if(invoiceMap.get(invId).Type__c =='INVOICE'){  
                        if(!updatedOfferMap.containsKey(offer.Id)){
                            offer__c updatedOffer= new offer__c(id= offer.Id);                      
                            updatedOffer.CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = externalNumber);                        
                            updatedOfferMap.put(updatedOffer.Id,updatedOffer);
                        }
                        else{
                            updatedOfferMap.get(offer.Id).CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = externalNumber);
                        }
                    }
                }
                for(Offer__c offer:invoiceMap.get(invId).CreditNoteOffers__r){
                    if(invoiceMap.get(invId).Type__c =='CREDITNOTE'){
                        if(!updatedOfferMap.containsKey(offer.Id)){
                            offer__c updatedOffer= new offer__c(id= offer.Id);                  
                            updatedOffer.Invoice__r = new Invoice__c(TECH_InvoiceParent__c = externalNumber); 
                            updatedOfferMap.put(updatedOffer.Id,updatedOffer);
                        }
                        else{
                            updatedOfferMap.get(offer.Id).Invoice__r = new Invoice__c(TECH_InvoiceParent__c = externalNumber);
                        }           
                    }
                    
                }
                invoiceList.add(clonedInv);
                originalCloneMap.put(invId,clonedInv);
            }
            //insert invoices/CR
            if (!invoiceList.isEmpty()){ 
                upsert invoiceList TECH_InvoiceParent__c;
            }
            if(!updatedOfferMap.isEmpty()){
                update updatedOfferMap.values();
            }

            // ASE: 30/05/2016
            // updating invoice parent Ids
            for(Invoice__c inv: invoiceList){
                if(inv.ParentInvoice__c !=null){
                    Invoice__c updatedInvoice= new Invoice__c(id= inv.Id,ParentInvoice__c= originalCloneMap.get(inv.ParentInvoice__c).Id);
                    updatedInvList.add(updatedInvoice);         
                }

                if (!updatedInvList.isEmpty()){ 
                        update updatedInvList;
                }
            }
        }
        system.debug('######## END payBackProcess');
        return new PageReference('/'+so.Id);    
    }

    //method to be used for cloning invoices
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    /******************************************************************/
}