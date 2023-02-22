/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_CDocumentTriggerHandler
  -- - Author        : HMO
  -- - Description   : 
  -- - #Ticket       : RSIW : 12130
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- -               HMO     1.0     Initial version
  **********************************************************************
*/
public with sharing class NOB_CDocumentTriggerHandler {
    public NOB_CDocumentTriggerHandler() {

    }

    public void onBeforeInsert(List<ContentDocumentLink> lstNewCD){
        String expeditionId = (String.isNotBlank(System.Label.NOB_ExpeditionIdPrefix)) ? System.Label.NOB_ExpeditionIdPrefix : '';
        List<ContentDocumentLink> lstCDLinkInsert = new List<ContentDocumentLink>();
        Set<Id> setEntityId = new Set<Id>();
        for (ContentDocumentLink cdl : lstNewCD){

            //implies sObject = Expedition/no describe call in forloop
            if (String.valueOf(cdl.LinkedEntityId).startsWith(expeditionId)){
        
                cdl.Visibility = 'AllUsers';
                cdl.shareType = 'V';
                lstCDLinkInsert.add(cdl);
                setEntityId.add(cdl.LinkedEntityId);
            }

        }

        
        if (!lstCDLinkInsert.isEmpty() && setEntityId.size() > 0){
           
            NOB_LC54_ConteurComm.removeRecOnNoteNotAllowed2(lstCDLinkInsert,setEntityId);
        }

    }

    public void onBeforeUpdate(List<ContentDocumentLink> lstNewCD, Map<Id, ContentDocumentLink> mapContentDocsOld){
           String expeditionId = (String.isNotBlank(System.Label.NOB_ExpeditionIdPrefix)) ? System.Label.NOB_ExpeditionIdPrefix : '';
        for (ContentDocumentLink cdl : lstNewCD){

            //implies sObject = Expedition/no describe call in forloop
            if (String.valueOf(cdl.LinkedEntityId).startsWith(expeditionId) &&  cdl.Visibility != 'AllUsers'){
            
                cdl.Visibility = 'AllUsers';
                cdl.shareType = 'V';
            }
        }
    }

    public void onBeforeDelete(List<ContentDocumentLink> lstCDLinkOld){
        List<ContentDocumentLink> lstCDLinkDelete = new List<ContentDocumentLink>();
        String expeditionId = (String.isNotBlank(System.Label.NOB_ExpeditionIdPrefix)) ? System.Label.NOB_ExpeditionIdPrefix : '';
        Set<Id> setEntityId = new Set<Id>();
        for (ContentDocumentLink cdl : lstCDLinkOld){

            //implies sObject = Expedition/no describe call in forloop
            if (String.valueOf(cdl.LinkedEntityId).startsWith(expeditionId)){
               
                lstCDLinkDelete.add(cdl);
                setEntityId.add(cdl.LinkedEntityId);
            }
        }
		
         
        if (!lstCDLinkDelete.isEmpty() && setEntityId.size() > 0){
            
            NOB_LC54_ConteurComm.removeRecOnNoteNotAllowed2(lstCDLinkDelete,setEntityId);
        }
    }
}