/*************************************************************************************
Trigger Name - NOB_ContentDocumentTriggerHandler
Version - 1.0
Created Date - 29/12/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Bhavish		29/12/2020 	Original Version
* Hansraj       19-04-2022  RSIW 12130 
*************************************************************************************/
public with sharing class NOB_ContentDocumentTriggerHandler {

    public void onBeforeUpdate(List<ContentDocument> lstContentDocumentsNew, List<ContentDocument> lstContentDocumentsOld){
        //HMO -- RSIW 12130
        Map<Id, ContentDocument> mapContentUpdate = new Map<Id, ContentDocument>();
        Map<Id, Id> mapCDExpsId = new Map<Id,Id>();
        

        if(ASPISTools.canTrigger('NOB_AP58') || ASPISTools.canTrigger('NOB_LC54_ConteurComm')) {
            List<ContentDocument> lstDocs = new List<ContentDocument>();
            for(Integer i=0; i<lstContentDocumentsNew.size(); i++){
                if((lstContentDocumentsNew[i].FileType != null && lstContentDocumentsNew[i].FileType != lstContentDocumentsOld[i].FileType) ||
                    (lstContentDocumentsNew[i].ContentSize != null && lstContentDocumentsNew[i].ContentSize != lstContentDocumentsOld[i].ContentSize)){
                    lstDocs.add(lstContentDocumentsNew[i]);
                }

                //HMO -- RSIW 12130
                if (lstContentDocumentsNew[i].FileType == 'SNOTE'){
                    
                    mapContentUpdate.put(lstContentDocumentsNew[i].Id, lstContentDocumentsNew[i]);
                }
            }
            NOB_AP58_ContentDocumentCheck.checkDocument(lstDocs);
            
            if (!mapContentUpdate.isEmpty()){
               
            	//NOB_LC54_ConteurComm.preventNotesDML(mapContentUpdate, lstContentDocumentsOld);
            	for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId, LinkedEntity.type from ContentDocumentLink where ContentDocumentId IN: mapContentUpdate.keySet()]){
                if (cdl.LinkedEntity.type == 'NOB_Expedition__c'){
                  
                    mapCDExpsId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                		}
            	}
        	}

            if (!mapCDExpsId.isEmpty()){
                 
                NOB_LC54_ConteurComm.preventNotesDML(mapContentUpdate, mapCDExpsId );
            }
        }

    }

    //HMO -- RSIW 12130
    public void onBeforeDelete(List<ContentDocument> lstContentDocumentsOld){
        Map<Id, ContentDocument> mapContentDelete = new Map<Id, ContentDocument>();
        Map<Id, Id> mapCDExpsId = new Map<Id,Id>();
		
        if(ASPISTools.canTrigger('NOB_LC54_ConteurComm')) {
           
            for (ContentDocument cd : lstContentDocumentsOld){
                if (cd.FileType == 'SNOTE'){
                    mapContentDelete.put(cd.Id, cd);
                }
            }

            if (!mapContentDelete.isEmpty()){
            // NOB_LC54_ConteurComm.preventNotesDML(mapContentDelete, null);
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId, LinkedEntity.type from ContentDocumentLink where ContentDocumentId IN: mapContentDelete.keySet()]){
                    if (cdl.LinkedEntity.type == 'NOB_Expedition__c'){
                        mapCDExpsId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
            }

            if (!mapCDExpsId.isEmpty()){
                NOB_LC54_ConteurComm.preventNotesDML(mapContentDelete, mapCDExpsId );
            }
        }

    }

}