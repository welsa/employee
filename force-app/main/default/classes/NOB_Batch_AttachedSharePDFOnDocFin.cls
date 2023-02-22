/*************************************************************************************
Class Name - NOB_Batch_AttachedSharePDFOnDocFin
Created by - sedera.rakotomalala@telesio.fr
Version - 1.0
Created Date - 26-09-2021
Function - Class to search, attach and Share the pdf on DocFin from EmailService
#Ticket  - RSIW : 10882

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SRA           26-09-2021   Initial version
*************************************************************************************/
global class NOB_Batch_AttachedSharePDFOnDocFin implements Database.Batchable<SObject>, Schedulable{

    @InvocableMethod(label='execute the batch NOB_Batch_AttachedSharePDFOnDocFin' description='This method will be execute NOB_Batch_AttachedSharePDFOnDocFin')
    public static void executeBatchMethod() {
    Database.executeBatch(new NOB_Batch_AttachedSharePDFOnDocFin(), 200);
  }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(Test.isRunningTest()){
            //query='SELECT Id, PFR_KeyD365Contentversion__c, ContentDocumentId FROM ContentVersion WHERE PFR_KeyD365Contentversion__c != null';
            query='select Id,FileType, Title,FileExtension, Versiondata,PFR_KeyD365Contentversion__c, ContentDocumentId  from ContentVersion where islatest=true';
 
       }else{
            query = 'SELECT Id, PFR_KeyD365Contentversion__c, ContentDocumentId FROM ContentVersion WHERE PFR_KeyD365Contentversion__c != null order by LastModifiedDate';
        System.debug('££££ queryString '+ query);
       }
        return Database.getQueryLocator(query);     
    }
    global void execute(Database.BatchableContext BC, List<sObject> lstScope){
        System.debug('lstScope==' + lstScope);
        List<String> lstKeyCVPDF = new List<String>();
        List<String> lstContentDocId = new List<String>();
        Set<Id> contentDocumentIdSet = new Set<Id>();
            
        List<String> lstTransRefDoc = new List<String> ();
        List<PFR_FinancialDocument__c> lstDocFin = new List<PFR_FinancialDocument__c> ();
        List<PFR_Transaction__c> lstTrans = new List<PFR_Transaction__c> ();
        List<PFR_FinancialDocument__c> lstDocFinUpdate = new List<PFR_FinancialDocument__c> ();
        PFR_FinancialDocument__c d = new PFR_FinancialDocument__c();
        List<ContentDocumentLink> lstContentDoc = new List<ContentDocumentLink>();
        ContentVersion c = new ContentVersion();
        ContentVersion cc = new ContentVersion();
        map<String, Id> keyIdDocFinMap = new map<String, Id> ();
        map<String, Id> IdkeyCdlMap = new map<String, Id> ();
        map<Id, Id> IdCdlDocFinIdMap = new map<Id, Id> ();
        map<Id, Id> IdDocFinIdCdlMap = new map<Id, Id> ();
        if(lstScope.size()>0){
            for(sObject cv : lstScope){
                c = (ContentVersion)cv;
                lstKeyCVPDF.add(c.PFR_KeyD365Contentversion__c);
                System.debug('lstKeyCVPDF==' + lstKeyCVPDF);
                IdkeyCdlMap.put(c.PFR_KeyD365Contentversion__c, c.ContentDocumentId);
                System.debug('IdkeyCdlMap==' + IdkeyCdlMap);
            }
        }
        for (PFR_Transaction__c trans : [SELECT Id, PFR_TECH_D365externalkey__c, PFR_ReferenceFinDoc__c FROM PFR_Transaction__c WHERE PFR_TECH_D365externalkey__c  IN:lstKeyCVPDF ]){
            lstTrans.add(trans);
            System.debug('lstTrans==' + lstTrans);
        }

        for (PFR_Transaction__c trans : lstTrans){
            keyIdDocFinMap.put(trans.PFR_TECH_D365externalkey__c, trans.PFR_ReferenceFinDoc__c);
            System.debug('keyIdDocFinMap==' + keyIdDocFinMap);
            if (IdkeyCdlMap.containsKey(trans.PFR_TECH_D365externalkey__c)){
                IdCdlDocFinIdMap.put(IdkeyCdlMap.get(trans.PFR_TECH_D365externalkey__c), trans.PFR_ReferenceFinDoc__c);
                System.debug('IdCdlDocFinIdMap==' + IdCdlDocFinIdMap);
            }
        }

        if (IdCdlDocFinIdMap.size()>0){
            System.debug('OKOK EXIST');
            lstDocFin = [SELECT Id, PFR_IsPDFAttachedAndShare__c FROM PFR_FinancialDocument__c WHERE Id IN: IdCdlDocFinIdMap.values() AND PFR_IsPDFAttachedAndShare__c = false];                 
            System.debug('lstDocFin==' + lstDocFin);
            if (lstDocFin.size()>0){  
                List<ContentDocumentLink> lstContentDocumentlink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:IdCdlDocFinIdMap.keySet()];
                System.debug('lstContentDocumentlink ==' + lstContentDocumentlink);
                System.debug('IdCdlDocFinIdMap2222 ==' + IdCdlDocFinIdMap);

                for (PFR_FinancialDocument__c docId : lstDocFin){
                    for (String key : IdCdlDocFinIdMap.keyset()){
                        if (docId.Id == IdCdlDocFinIdMap.get(key)){
                            IdDocFinIdCdlMap.put(docId.Id, key);
                        }   
                    }                               
                }
                System.debug('IdDocFinIdCdlMap ==' + IdDocFinIdCdlMap);
                    for( Id idCDL : IdDocFinIdCdlMap.keySet()){ //IdCdlDocFinIdMap.keySet()

                        if(!listContains(lstContentDocumentlink, idCDL)){
                            ContentDocumentLink conDocLink = new ContentDocumentLink();
                            conDocLink.LinkedEntityId =  idCDL;
                            conDocLink.ContentDocumentId = IdDocFinIdCdlMap.get(idCDL);
                            conDocLink.shareType = 'I';
                            conDocLink.Visibility = 'AllUsers';
                            lstContentDoc.add(conDocLink);   
                        }
                    }
                
                for(PFR_FinancialDocument__c docFin : lstDocFin){
                    docFin.PFR_IsPDFAttachedAndShare__c = true;
                    lstDocFinUpdate.add(docFin);
                } 
            }
            if (lstContentDoc.size()>0){
                insert lstContentDoc;
                System.debug('lstContentDoc==' + lstContentDoc);
            }

            if (lstDocFinUpdate.size()>0){
                update lstDocFinUpdate;
                System.debug('lstDocFinUpdate==' + lstDocFinUpdate);
            }           
        }    
    }

    public Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }
    global void finish(Database.BatchableContext BC){
        System.debug('#### End Execute Batch');
    } //END finish
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new NOB_Batch_AttachedSharePDFOnDocFin());
    }
}