/*************************************************************************************
Class Name - PFR_docFinTriggerHandler
Version - 1.0
Created Date - 11/17/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                Description
* ----------            ----------          -----------------------
* Telesio               11/17/2020           Original Version
*Spoon Consulting ABH   09/03/2021           v1.1 RSIW-3991
*Spoon Consulting KPA   05/05/2021           v1.2 RSIW-8385
*Spoon Consulting KPA   05/06/2021           v1.3 RSIW-7051
*Spoon Consulting KPA   05/07/2021           v1.4 RSIW-8381
*Spoon Consulting HMO   08/07/2021           v1.5 RSIW-10319
*Telesio          SRA   14/07/2021           v1.5 RSIW-9832
*Spoon Consulting HMO   18/10/2021           v1.6 RSIW-10330
*Spoon Consulting HMO   02-05-2022           V1.7   RSIW-11049
*************************************************************************************/
public class PFR_docFinTriggerHandler {
   
    public static boolean SkipValidation=false;
    public String profileName = NOBTools.ProfileName();
    
    //Spoon Consulting     ABH   09/03/2021    RSIW-3991
    public void onBeforeUpdate(List<PFR_FinancialDocument__c> lstNew, Map<Id, PFR_FinancialDocument__c> mapOld){
        System.debug('#### Start onBeforeUpdate PFR_docFinTriggerHandler');
        Set<String> setUid = new Set<String>();
        
        //KPA RSIW-7051 
        //HMO 09-07-2021 -- RSIW 10319
        if(profileName =='PRE_Integration'){
            SkipValidation=true;
        }
        //RLA optimisation 09/07/2021
        List<PermissionSetAssignment> lstpsa = new list<PermissionSetAssignment>();
        if(!SkipValidation && (profileName == 'PRE_Back office/Credit management')){
            lstpsa =[ SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() ];

        }
        
        //HMO -- RSIW 11049
        List<Id> lstApportaireBev = (System.label.NOB_ApportaireFRNonValidation).split(',');
        Set<Id> setApportaireIds = new Set<Id>(lstApportaireBev);
        List<PFR_FinancialDocument__c> lstFRCheck = new List<PFR_FinancialDocument__c>();
        Map<Id, List<PFR_FinancialDocument__c>> mapFS = new Map<Id,List<PFR_FinancialDocument__c>>();
        //HMO -- RSIW 11049
        

        for (PFR_FinancialDocument__c fd: lstNew) {
            if(    fd.PFR_RecordTypeTech__c == 'FR' 
               && (fd.PFR_TechUniqueDocIdentifier__c == null || fd.PFR_TechUniqueDocIdentifier__c == '')
               && mapOld.get(fd.Id).PFR_TechUniqueDocIdentifier__c!=fd.PFR_TechUniqueDocIdentifier__c
               && fd.PFR_FinancialDocumentFrom__c!=null && String.isNotBlank(fd.PFR_RepairInvoiceNumber__c)){
                   string uid=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+fd.PFR_RepairInvoiceNumber__c;
                   setUid.add(uid);
               }
            else if((fd.PFR_TechUniqueDocIdentifier__c == null || fd.PFR_TechUniqueDocIdentifier__c == '') && mapOld.get(fd.Id).PFR_TechUniqueDocIdentifier__c!=fd.PFR_TechUniqueDocIdentifier__c && fd.PFR_RecordTypeTech__c == 'FS' && fd.PFR_FinancialDocumentFrom__c!=null && String.isNotBlank(fd.PFR_ContractNumber__c)){
                string uidFS=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+fd.PFR_ContractNumber__c;
                setUid.add(uidFS);
            }
            else if((fd.PFR_TechUniqueDocIdentifier__c == null || fd.PFR_TechUniqueDocIdentifier__c == '') && mapOld.get(fd.Id).PFR_TechUniqueDocIdentifier__c!=fd.PFR_TechUniqueDocIdentifier__c && fd.PFR_RecordTypeTech__c == 'AV' && fd.PFR_FinancialDocumentFrom__c!=null){
                string uidAV=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+(String.isNotBlank(fd.PFR_CreditNumber__c)?fd.PFR_CreditNumber__c:fd.Id);
                setUid.add(uidAV);
            }
            
               System.debug('##NOBTools.ProfileName2(): '+profileName);
               System.debug('##SkipValidation '+SkipValidation);
            
            if(!SkipValidation && (profileName == 'PRE_Back office/Credit management')){
               
                Set<Id> setError = new Set<Id>();
                boolean userHasPermissionSet=false;
                
                for(PermissionSetAssignment psa : lstpsa){
                    if(psa.Id != null && psa.PermissionSet.Name=='PRE_Documents_Financiers'){
                        userHasPermissionSet=true;
                      }
                }
                System.debug('###fd.PFR_RecordTypeTech__c: '+fd.PFR_RecordTypeTech__c);
                System.debug('###fd.RecordType.DeveloperName: '+fd.RecordType.DeveloperName);
                System.debug('###fd.PFR_DocumentStatus__c: '+fd.PFR_DocumentStatus__c);
			    System.debug('###userHasPermissionSet: '+userHasPermissionSet);
                
                if( (fd.PFR_DocumentStatus__c=='NU' || fd.PFR_DocumentStatus__c=='MA') && fd.PFR_DocumentStatus__c==mapOld.get(fd.id).PFR_DocumentStatus__c) {
                   System.debug('###Check Status');
                    if(!(fd.PFR_RecordTypeTech__c =='FR' || fd.PFR_RecordTypeTech__c =='FS' || (userHasPermissionSet && (fd.PFR_RecordTypeTech__c =='AV' || fd.PFR_RecordTypeTech__c =='FC'))) ){
                        fd.addError(System.label.NOB_DocFinBackOfficeError);
					   }
                     
				 }
                else{
                    String ReadOnlyFields = System.label.NOB_DocFinReadOnlyFields+System.label.NOB_DocFinReadOnlyFields2;
                    List<String> lstFields = ReadOnlyFields.split(';');
                        for(String field: lstFields){
                                if(fd.get(field) !=  mapOld.get(fd.id).get(field)){
                                setError.add(fd.Id);
                            }
						}		
					}
                if(setError.size()>0){
  					fd.addError(System.label.NOB_DocFinBackOfficeError);                                        
				}
                              
            }
             System.debug('##NOBTools.ProfileName3(): '+profileName);  
            
            //KPA 05/05/2021 RSIW-8385
            if((profileName =='CCP Bodyshop') &&  mapOld.get(fd.id).PFR_DocumentStatus__c!='NU' && mapOld.get(fd.id).PFR_RecordTypeTech__c!='FG'){
                fd.addError(System.label.NOB_DocFinReparateurStatusNewError);
            }

            //HMO -- RSIW 11049
 
            if (setApportaireIds.size() > 0 
            && fd.PFR_CaseBusinessProvider__c != null 
            && (!setApportaireIds.contains(fd.PFR_CaseBusinessProvider__c)) 
            && fd.PFR_DocumentStatus__c != 'VL' 
            && fd.PFR_RecordTypeTech__c == 'FR'
            && fd.PFR_InsurerCaseNumber__c != null
            && fd.PFR_VATAmount__c != null 
            && fd.PFR_InclVATTotalAmount__c != null
            && (/*fd.PFR_InsurerCaseNumber__c != mapOld.get(fd.Id).PFR_InsurerCaseNumber__c || fd.PFR_CaseBusinessProvider__c != mapOld.get(fd.Id).PFR_CaseBusinessProvider__c ||*/ fd.PFR_VATAmount__c != mapOld.get(fd.Id).PFR_VATAmount__c || fd.PFR_InclVATTotalAmount__c != mapOld.get(fd.Id).PFR_InclVATTotalAmount__c)
            ){
                lstFRCheck.add(fd);
                if(mapFS.containsKey(fd.PFR_Case__c)) {
                    mapFS.get(fd.PFR_Case__c).add(fd);
                } else {
                    mapFS.put(fd.PFR_Case__c, new List<PFR_FinancialDocument__c>{fd});
                }
            }
            //HMO -- RSIW 11049

        }
        SkipValidation = true;
        
        if(!setUid.isEmpty()) checkFRNumber(lstNew, setUid);
        
       //HMO -- RSIW 11049
        if (!mapFS.isEmpty()){
            NOB_AP56_DocumentFinancierSharing.checkValidationFR(lstFRCheck, mapFS);
        }
        //HMO -- RSIW 11049
        System.debug('#### End onBeforeUpdate PFR_docFinTriggerHandler');
    }
    
    public void onBeforeInsert(List<PFR_FinancialDocument__c> lstNew){
        System.debug('#### Start onBeforeInsert PFR_docFinTriggerHandler');
        Set<String> setUid = new Set<String>();
        //String profileName = NOBTools.ProfileName();
        //Spoon Consulting     ABH   09/03/2021    RSIW-3991
        //Set<String> setInvNumbers = new Set<String>();
        //RSIW-7051 - BBH - skip validation on insert
        if(profileName=='PRE_Integration' || profileName == 'PRE_Back office/Credit management'){
            SkipValidation=true;
        }
        
        
     
        List<User> lstUser = [SELECT Name, AccountId,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
	
        for (PFR_FinancialDocument__c fd: lstNew) {


            if(fd.PFR_RecordTypeTech__c == 'FR' && fd.PFR_FinancialDocumentFrom__c!=null && String.isNotBlank(fd.PFR_RepairInvoiceNumber__c)){
                string uid=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+fd.PFR_RepairInvoiceNumber__c;
                setUid.add(uid);
                System.debug('#### onBeforeInsert uid:'+uid);
                //setInvNumbers.add(fd.PFR_RepairInvoiceNumber__c);
            }else if((fd.PFR_TechUniqueDocIdentifier__c == null || fd.PFR_TechUniqueDocIdentifier__c == '') && fd.PFR_RecordTypeTech__c == 'FS' && fd.PFR_FinancialDocumentFrom__c!=null && String.isNotBlank(fd.PFR_ContractNumber__c)){
                string uidFS=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+fd.PFR_ContractNumber__c;
                setUid.add(uidFS);
            }
            else if((fd.PFR_TechUniqueDocIdentifier__c == null || fd.PFR_TechUniqueDocIdentifier__c == '') && fd.PFR_RecordTypeTech__c == 'AV' && fd.PFR_FinancialDocumentFrom__c!=null && String.isNotBlank(fd.PFR_CreditNumber__c)){
                string uidAV=fd.PFR_FinancialDocumentFrom__c+'_'+fd.PFR_RecordTypeTech__c+'_'+fd.PFR_CreditNumber__c;
                setUid.add(uidAV);
            }
            
            //KPA 07/05/2021  RSIW-8381
            for(User usr:lstUser){
                if(usr.Id!=null && usr.Profile.Name=='CCP Bodyshop'){
                     fd.PFR_FinancialDocumentFrom__c=usr.AccountId;
				}
            }

        }
        //checkFRNumbber(lstNew, setInvNumbers);
        if(!setUid.isEmpty()) checkFRNumber(lstNew, setUid);
       
        System.debug('#### End onBeforeInsert PFR_docFinTriggerHandler');
    }
    
    
    
    /**
    * **** commented on 26-04-2021 -- HMO
    * **** decommented on 29/04/2021 -- LMU RSIW-9557
    */
    private void checkFRNumber(List<PFR_FinancialDocument__c> listNewFinDoc, Set<String> setUid){
        
    
        Map<String, PFR_FinancialDocument__c> mapDuplicate = new Map<String, PFR_FinancialDocument__c>();
        
        for (PFR_FinancialDocument__c fd : [SELECT id,name,PFR_TechUniqueDocIdentifier__c from PFR_FinancialDocument__c where PFR_TechUniqueDocIdentifier__c IN : setUid]) {
            String key =  fd.PFR_TechUniqueDocIdentifier__c;
            mapDuplicate.put(key, fd);
        }

        System.debug('#### checkFRNumber mapDuplicate:'+mapDuplicate);

        for(PFR_FinancialDocument__c nfd : listNewFinDoc){
            string uid = ''; 
            
            //Facture de Réparation
            if(nfd.PFR_RecordTypeTech__c == 'FR'){
                uid=nfd.PFR_FinancialDocumentFrom__c+'_'+nfd.PFR_RecordTypeTech__c+'_'+nfd.PFR_RepairInvoiceNumber__c;
                System.debug('#### checkFRNumber uid:'+uid);
                if (mapDuplicate.containsKey(uid)) {
                    nfd.addError(System.Label.NOB_FRnumber_ErrorMsg);
                }
                else {
                    nfd.PFR_TechUniqueDocIdentifier__c=uid;
                }
            }

            //Avoir
            if(nfd.PFR_RecordTypeTech__c == 'AV'){
                String uidAV01 = '';
                String uidAV02 = '';
                if (nfd.PFR_CreditNumber__c == null) {
                    uidAV02 = nfd.PFR_FinancialDocumentFrom__c + '_' + nfd.PFR_RecordTypeTech__c + '_' + nfd.Id;
                } else if (nfd.id != null) {
                    
                    uidAV01 = nfd.PFR_FinancialDocumentFrom__c + '_' + nfd.PFR_RecordTypeTech__c + '_' + nfd.PFR_CreditNumber__c;
                } else {
                    uidAV01 = null;
                }

                System.debug('#### checkFRNumber uid:'+uid);
                
                if (mapDuplicate.containsKey(uidAV01) || mapDuplicate.containsKey(uidAV02)) {
                    nfd.addError(System.Label.NOB_AVnumber_ErrorMsg);
                }
                else {
                    nfd.PFR_TechUniqueDocIdentifier__c = (nfd.PFR_CreditNumber__c == null)? uidAV02 : uidAV01;
                }
            }

            // Facture de Service
            if(nfd.PFR_RecordTypeTech__c == 'FS'){
                uid=nfd.PFR_FinancialDocumentFrom__c + '_' + nfd.PFR_RecordTypeTech__c + '_' + nfd.PFR_ContractNumber__c;
                System.debug('#### checkFRNumber uid:'+uid);
                if (mapDuplicate.containsKey(uid)) {
                    nfd.addError(System.Label.NOB_FSnumber_ErrorMsg);
                }
                else {
                    nfd.PFR_TechUniqueDocIdentifier__c = uid;
                }
            }
        }
    }


// SRA - RSIW-9832 - Check the rigths of visbility after insert of Document Financier from user's compte partie facturée
public void onAfterInsert(List<PFR_FinancialDocument__c> lstNew){
    System.debug('#### Start onAfterInsert PFR_docFinTriggerHandler');
    List<PFR_FinancialDocument__c> lstDocFin = new List<PFR_FinancialDocument__c>();
    Set<Id> setComptePartieFactureeId = new Set<Id>();
    Set<Id> setComptePartieFactureeIdValide = new Set<Id>();

    //HMO -- RSIW 11049
    List<Id> lstApportaireBev = (System.label.NOB_ApportaireFRNonValidation).split(',');
    Set<Id> setApportaireIds = new Set<Id>(lstApportaireBev);
    List<PFR_FinancialDocument__c> lstFRCheck = new List<PFR_FinancialDocument__c>();
    Map<Id, List<PFR_FinancialDocument__c>> mapFS = new Map<Id,List<PFR_FinancialDocument__c>>();
    //HMO -- RSIW 11049


    for (PFR_FinancialDocument__c docFinIns : lstNew) {
        if (docFinIns.PFR_DocumentStatus__c == 'VL' && String.isNotBlank(docFinIns.PFR_BilledPartyAccount__c) /*&& docFinIns.PFR_BilledPartyAccount__r.RecordType.DeveloperName == NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP*/ ) {
            lstDocFin.add(docFinIns);
            setComptePartieFactureeId.add(docFinIns.PFR_BilledPartyAccount__c);
        }

        //HMO -- RSIW 11049
        if (setApportaireIds.size() > 0 
        && docFinIns.PFR_CaseBusinessProvider__c != null 
        && (!setApportaireIds.contains(docFinIns.PFR_CaseBusinessProvider__c)) 
        && docFinIns.PFR_DocumentStatus__c != 'VL' 
        && docFinIns.PFR_RecordTypeTech__c == 'FR'
        && docFinIns.PFR_VATAmount__c != null 
        && docFinIns.PFR_InclVATTotalAmount__c != null
        && docFinIns.PFR_InsurerCaseNumber__c != null){

            lstFRCheck.add(docFinIns);
            if(mapFS.containsKey(docFinIns.PFR_Case__c)) {
                mapFS.get(docFinIns.PFR_Case__c).add(docFinIns);
            } else {
                mapFS.put(docFinIns.PFR_Case__c, new List<PFR_FinancialDocument__c>{docFinIns});
            }
        }
        //HMO -- RSIW 11049

    }

    

    if(lstDocFin.size() > 0) {
        System.debug('#### OKOK11');
       /*  //HMO -- rsiw 10330 -- 18-10-2021
        for (Account acc : [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN: setComptePartieFactureeId ]){
            if (acc.RecordType.DeveloperName == NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP) {
                setComptePartieFactureeIdValide.add(acc.Id);
                System.debug('#### setComptePartieFactureeIdValide == ' + setComptePartieFactureeIdValide);
            }
        } */
        NOB_AP56_DocumentFinancierSharing.documentFinancierSharing(lstDocFin, setComptePartieFactureeId);
        System.debug('#### OKOK22');
    }

    //HMO -- RSIW 11049
    if (!mapFS.isEmpty()){
        NOB_AP56_DocumentFinancierSharing.checkValidationFR(lstFRCheck, mapFS);
    }
    //HMO -- RSIW 11049
    System.debug('#### End onAfterInsert PFR_docFinTriggerHandler');
}

// SRA - RSIW-9832 Check the rigths of visbility after upadte of Document Financier from user's compte partie facturée
public void onAfterUpdate(List<PFR_FinancialDocument__c> lstNew,  Map<Id, PFR_FinancialDocument__c> mapOld){
        System.debug('#### Start onAfterUpdate PFR_docFinTriggerHandler');
        //Set<String> setUid = new Set<String>();
        //String profileName = NOBTools.ProfileName();
        if(profileName=='PRE_Integration' || profileName== 'PRE_Back office/Credit management'){
            SkipValidation=true;
        }
        //AND NOB_BodyShop__r.RecordType.DeveloperName=:NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP 
        List<PFR_FinancialDocument__c> lstNewDocFin = new List<PFR_FinancialDocument__c>();
        Set<Id> comptePartieFactId = new Set<Id>();
        List<PFR_FinancialDocument__c> lstOldDocFin = new List<PFR_FinancialDocument__c>();
        Set<Id> setComptePartieFactOldId = new Set<Id>();
        Set<Id> setComptePartieFactOldIdValide = new Set<Id>();

        //HMO -- RSIW 11049
        List<Id> lstApportaireBev = (System.label.NOB_ApportaireFRNonValidation).split(',');
        Set<Id> setApportaireIds = new Set<Id>(lstApportaireBev);
        List<PFR_FinancialDocument__c> lstFRCheck = new List<PFR_FinancialDocument__c>();
        Map<Id, List<PFR_FinancialDocument__c>> mapFS = new Map<Id,List<PFR_FinancialDocument__c>>();
        //HMO -- RSIW 11049

        for (PFR_FinancialDocument__c docFin : lstNew) {
            if (mapOld.get(docFin.id).PFR_DocumentStatus__c == 'VL'){
                System.debug('#### mapOld.get(docFin.id).PFR_DocumentStatus__c == ' + mapOld.get(docFin.id).PFR_DocumentStatus__c);
                System.debug('#### docFin.PFR_DocumentStatus__c == ' + docFin.PFR_DocumentStatus__c);
                System.debug('#### mapOld.get(docFin.id).PFR_BilledPartyAccount__c == ' + mapOld.get(docFin.id).PFR_BilledPartyAccount__c);
                System.debug('#### docFin.PFR_BilledPartyAccount__r.PFR_AccountRecordTypeTech__c == ' + docFin.PFR_BilledPartyAccount__r.PFR_AccountRecordTypeTech__c);
                if ( mapOld.get(docFin.id).PFR_DocumentStatus__c == docFin.PFR_DocumentStatus__c && 
                     String.isNotBlank(mapOld.get(docFin.id).PFR_BilledPartyAccount__c) /*&& 
                     mapOld.get(docFin.id).PFR_BilledPartyAccount__r.RecordType.DeveloperName == NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP*/){
                        lstOldDocFin.add(mapOld.get(docFin.id));
                        setComptePartieFactOldId.add(mapOld.get(docFin.id).PFR_BilledPartyAccount__c);
                        System.debug('#### setComptePartieFactOldId == ' + setComptePartieFactOldId);
                }

            }

            //HMO -- RSIW 11049
            if (setApportaireIds.size() > 0 
            && docFin.PFR_CaseBusinessProvider__c != null 
            && (!setApportaireIds.contains(docFin.PFR_CaseBusinessProvider__c)) 
            && docFin.PFR_DocumentStatus__c != 'VL' 
            && docFin.PFR_RecordTypeTech__c == 'FR'
            && docFin.PFR_VATAmount__c != null
            && docFin.PFR_InclVATTotalAmount__c != null
            && docFin.PFR_InsurerCaseNumber__c != null
            && (docFin.PFR_InsurerCaseNumber__c != mapOld.get(docFin.Id).PFR_InsurerCaseNumber__c || docFin.PFR_CaseBusinessProvider__c != mapOld.get(docFin.Id).PFR_CaseBusinessProvider__c)){
                lstFRCheck.add(docFin);
                if(mapFS.containsKey(docFin.PFR_Case__c)) {
                    mapFS.get(docFin.PFR_Case__c).add(docFin);
                } else {
                    mapFS.put(docFin.PFR_Case__c, new List<PFR_FinancialDocument__c>{docFin});
                }
            }
            //HMO -- RSIW 11049
        }

        
        System.debug('#### lstOldDocFin == ' + lstOldDocFin);
        if(lstOldDocFin.size() > 0) {
            //HMO -- rsiw 10330 -- 18-10-2021
            /* for (Account acc : [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN: setComptePartieFactOldId ]){
                if (acc.RecordType.DeveloperName == NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP) {
                    setComptePartieFactOldIdValide.add(acc.Id);
                    System.debug('#### setComptePartieFactOldIdValide == ' + setComptePartieFactOldIdValide);
                }
            } */
            NOB_AP56_DocumentFinancierSharing.documentFinancierSharing(lstOldDocFin, setComptePartieFactOldId);
        }

        
        //HMO -- RSIW 11049
        if (!mapFS.isEmpty()){
            NOB_AP56_DocumentFinancierSharing.checkValidationFR(lstFRCheck, mapFS);
        }
        //HMO -- RSIW 11049
        System.debug('#### End onAfterUpdate PFR_docFinTriggerHandler');

/*
        Set<Id> setDocIdBilledPartyAccount = new Set<Id>();
        Set<Id> setDocFinId = new Set<Id>();
        //Set<Id> setDocFinIdRelated = new Set<Id>();
        //String idDoc = '';
        Set<Id> setUserIds = new Set<Id>();
        List<PFR_FinancialDocument__Share> lstdocFinShare = new List<PFR_FinancialDocument__Share> ();

         for (PFR_FinancialDocument__c dcF : lstNew){
                if (dcF.PFR_DocumentStatus__c == 'VL'){
                        setDocFinId.add(dcF.Id);
                }else{
                        setDocFinId.add(dcF.Id);
                }
            }   
        
         system.debug('setDocFinId==' + setDocFinId);

         if (setDocFinId.size() >0 ){
            /*PFR_FinancialDocument__c docFinn = [SELECT Id,(SELECT Id FROM DocumentReference__r) FROM PFR_FinancialDocument__c WHERE Id IN: setDocFinId];

            Integer sizeTrans = (docFinn.DocumentReference__r).size();
            system.debug('sizeTrans==' + sizeTrans);
            for(PFR_FinancialDocument__c t : docFinn.DocumentReference__r){
                if(t.Id != null){
                    setDocFinIdRelated.add(t.Id);               
                }
            }
    
            system.debug('setDocFinIdRelated==' + setDocFinIdRelated);*/
            //List<PFR_Transaction__c> lstransaction = [SELECT Name, PFR_DebtOrCreditThirdPartyAccount__c, PFR_ReferenceFinDoc__c FROM PFR_Transaction__c WHERE PFR_ReferenceFinDoc__c =: idDoc];
            //PFR_FinancialDocument__c docFinn = [SELECT Id, (SELECT PFR_DebtOrCreditThirdPartyAccount__c, PFR_ReferenceFinDoc__c FROM Transactions__r WHERE PFR_DebtOrCreditThirdPartyAccount__c != null) FROM PFR_FinancialDocument__c WHERE Id =: idDoc];
            /*List<PFR_FinancialDocument__c> lstDocFin = [SELECT Id, PFR_BilledPartyAccount__c,PFR_BilledPartyAccount__r.RecordType.DeveloperName FROM PFR_FinancialDocument__c WHERE Id IN: setDocFinId];
            system.debug('lstDocFin==' + lstDocFin);
            system.debug('lstDocFinSIZE==' + lstDocFin.size());
    
            if(lstDocFin.size() > 0){
                for(PFR_FinancialDocument__c d : lstDocFin){
                        /*if(d.PFR_BilledPartyAccount__c != null){*/
                       /* if(d.PFR_BilledPartyAccount__c != null && d.PFR_BilledPartyAccount__r.RecordType.DeveloperName == NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP){
                            setDocIdBilledPartyAccount.add(d.PFR_BilledPartyAccount__c);
                            system.debug('setDocIdBilledPartyAccount==' + setDocIdBilledPartyAccount);
                        }
                }
                
            }
    
            /*system.debug('setDocIdBilledPartyAccountExterne==' + setDocIdBilledPartyAccount);
    
            List<User> lstUsers = new List<User>();
            for (user u : [SELECT Id, AccountId 
                            FROM User 
                            WHERE AccountId IN :setDocIdBilledPartyAccount AND IsActive = TRUE]) {
                 lstUsers.add(u);
            }
            for (Id docFin: setDocFinId){
                system.debug('lstUsers==' + lstUsers);
                    for (User u : lstUsers) {
                        PFR_FinancialDocument__Share dcShare = new PFR_FinancialDocument__Share();
                        dcShare.ParentId = docFin;
                        dcShare.UserOrGroupId = u.Id;
                        dcShare.AccessLevel = 'Read';
                        dcShare.RowCause  = Schema.PFR_FinancialDocument__Share.RowCause.Manual;
                        lstdocFinShare.add(dcShare);
                       // dcF.addError('Vous n\'avez pas le droit de modifier cet enregistrement');
                    }
    
                if (lstdocFinShare.size()>0) {
                    insert lstdocFinShare;               
                }
                system.debug('lstdocFinShare2==' + lstdocFinShare);
            }
         }*/
    }   
}