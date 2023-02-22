/*************************************************************************************
Class Name - NOB_AP58_ContentDocumentCheck
Version - 1.0
Created Date - 29/12/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Bhavish		29/12/2020 	Original Version
*************************************************************************************/
public with sharing class NOB_AP58_ContentDocumentCheck {
    /**
     * @description checks if document is of allowed type and size is not greater than 2 gb
     *
     * @param  lstContentDocuments  list of content documents
     * @return void
     */

    public static void checkDocument(List<ContentDocument> lstContentDocuments){
        String currentUserProfile = NOBTools.ProfileName();
        Set<String> fileAdminProfiles = new Set<String>((Label.NOB_FileAdminProfiles).split(';'));
        Set<String> allowedFileTypesAdmin = new Set<String>((Label.NOB_AllowedFileTypeAdmin).split(';'));
        Set<String> setAllowedTypes = new Set<String>((Label.NOB_AllowedFileType).split(';')); //new Set<String>{'PDF','GIF','JPG','PNG', 'SNOTE'};
        for(ContentDocument cd: lstContentDocuments) {
            if(!(setAllowedTypes.contains(cd.FileType) || (fileAdminProfiles.contains(currentUserProfile) && allowedFileTypesAdmin.contains(cd.FileType)))) {
                cd.addError(System.label.NOB_ErrorFileType);
            }
            if(cd.ContentSize > 2147483647){
                cd.addError(System.label.NOB_ErrorFileSize);
            }
        }
    }
    //RLA 17/12/2021 RSIW-5638: Contr?le sur la pr?sence dans photos Prospect -> En attente (8 photos mini.)
    public static void checkPhotos(Map<Id,Account> mapAcc){

        List<Id> lstContentDocId = new List<Id>();
        // Map<Id,Integer> mapContentNoOfFiles = new Map<Id,Integer>();
        Map<Id,Integer> mapAccountNoOfFiles = new Map<Id,Integer>();
        Map<Id,Id> mapContentVersionAccId = new map<Id,Id>();
        Set<Id> newSetAcc = mapAcc.keySet();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId
                                        FROM ContentDocumentLink 
                                        WHERE 
                                        LinkedEntityId IN: newSetAcc]){
            lstContentDocId.add(cdl.ContentDocumentId);
            mapContentVersionAccId.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        system.debug('@@ lstContentDocId:'+lstContentDocId);
        system.debug('@@ mapContentVersionAccId:'+mapContentVersionAccId);


        for (ContentVersion cv : [SELECT Id, contentDocumentId  FROM ContentVersion where NOB_Category__c = 'Garage (catégorie Candidature)' AND NOB_SubCategory__c = 'Photos' AND  ContentDocumentId IN: lstContentDocId ORDER BY createdDate]){

            Id accId = mapContentVersionAccId.get(cv.contentDocumentId);

            if (mapAccountNoOfFiles.containsKey(accId)){
                mapAccountNoOfFiles.put(accId, ((mapAccountNoOfFiles.get(accId))+1));
            }
            else{
                mapAccountNoOfFiles.put(accId,1);
            }
        }
        system.debug('@@ mapAccountNoOfFiles:'+mapAccountNoOfFiles);

        for (Id accId: mapAcc.keyset()){
            system.debug('@@ accId:'+accId);


            if (!mapAccountNoOfFiles.containsKey(accId)){
               mapAccountNoOfFiles.put(accId,0); 
            }

        }
        system.debug('@@ mapAccountNoOfFiles:'+mapAccountNoOfFiles);

        for (Id accId: mapAccountNoOfFiles.keyset()){

            Integer noOfFiles = mapAccountNoOfFiles.get(accId);
            system.debug('@@ noOfFiles:'+noOfFiles);

            Account acc = mapAcc.get(accId);

            if (noOfFiles < (integer.valueof(system.label.Pre_MinimumNoOfPhotos))){
                acc.addError(system.label.Pre_messageErrorPhotos);
            }

        }


    }
}