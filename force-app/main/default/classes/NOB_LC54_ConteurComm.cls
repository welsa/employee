/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC54_ConteurComm
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
public without sharing class NOB_LC54_ConteurComm {

    public NOB_LC54_ConteurComm() {
     
    }

    @AuraEnabled
    public static String getUrl(){
      return URL.getSalesforceBaseUrl().toExternalForm();
    }

    @AuraEnabled
    public static Integer getUnreadComm(Id userId){
      
      List<NOB_Communication__c> lstComm = new List<NOB_Communication__c>();
      for (NOB_Communication__c comm : [SELECT Id from NOB_Communication__c where NOB_Reception__c =: NOB_AP00_Constants.COMMUNICATION_NONLUE AND NOB_UtilisateurGarage__c =: UserInfo.getUserId() AND NOB_Expedition__c != null and NOB_DateLue__c = null]){
       
        lstComm.add(comm);
      }

      return (lstComm.size() > 0) ? lstComm.size() : 0;
    }

    @AuraEnabled
    public static WrapComm renderCommunication(Id recordId){
   

      String content;
      String title;
      Boolean userPortal = false;
      WrapComm communication;
      NOB_Communication__c com;

      for (Profile profile : [SELECT Name from profile where Id =: userInfo.getProfileId() limit 1]){
        if (profile.Name == System.Label.NOB_CCP_Bodyshop){
          userPortal = true;
        }
      }

      for (NOB_Communication__c record : [SELECT id, NOB_Expedition__c, NOB_Tech_Sujet__c, Name from NOB_Communication__c where id =: recordId Limit 1]){
       
        com = new NOB_Communication__c();
        com = record;
      }
     
      
      if (com != null){
 
        set<Id> setContentDocId = new set<Id>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId
                                        FROM ContentDocumentLink 
                                        WHERE 
                                        LinkedEntityId =: com.NOB_Expedition__c]){
            setContentDocId.add(cdl.ContentDocumentId);
        }

        

        for (ContentVersion cv :[SELECT Id,Title,TextPreview,VersionNumber,CreatedBy.Name,CreatedDate,VersionData from ContentVersion where isLatest = true
        and (ContentDocumentId IN:setContentDocId) and FileType = 'SNOTE' ORDER BY CreatedDate ASC Limit 1]){

          content = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData)).toString();
          title = cv.Title;

        }

        communication = new WrapComm(content, com.NOB_Tech_Sujet__c, title, com.Name, userPortal );
       

      }

      return (communication != null) ? communication : new WrapComm('', '', '', '', false);
    }



    public class WrapComm{
      @AuraEnabled
      public String contenu;

      @AuraEnabled
      public String sujet;

      @AuraEnabled
      public String titre;

      @AuraEnabled
      public String nom;

      @AuraEnabled
      public Boolean userPortail;

      public wrapComm(String content, String subject, String title, String name, Boolean userPortal){
       
        contenu = content;
        sujet = subject;
        titre = title;
        nom = name;
        userPortail = userPortal;
      }
    }


    @AuraEnabled
    public static Boolean setLue(Id recordId){
      Boolean isSuccess = false;
      Map<Id, NOB_Communication__c> mapCommUpdate = new Map<Id, NOB_Communication__c>();
      NOB_Communication__c updateComm = new NOB_Communication__c(
        Id = recordId,
        NOB_Reception__c = NOB_AP00_Constants.COMMUNICATION_LUE,
        NOB_DateLue__c = Datetime.parse(DateTime.now().format())
      );
      mapCommUpdate.put(updateComm.Id, updateComm);

      if (!mapCommUpdate.isEmpty()){
        persistRecords(mapCommUpdate, 'update');
        isSuccess = true;
      }

      return isSuccess;
    }

    //xpeditions status changed to publish
    //rules -> cannot have expedition publish without 1 note
    // 1 expedition cannot have 2 notes
    public static void createComunication(set<Id> setExpeditions){
      String profileName = System.Label.NOB_CCP_Bodyshop;
      Map<Id, NOB_Communication__c> mapCommsInsert = new Map<Id, NOB_Communication__c>();

      for (User user : [SELECT Id, AccountId from User where profile.Name =: profileName AND NOB_isPrefikar__c = TRUE AND isActive = TRUE]){
        for (Id exp : setExpeditions){
          NOB_Communication__c comm = new NOB_Communication__c(
            NOB_Expedition__c = exp,
            NOB_UtilisateurGarage__c = user.Id,
            NOB_UnValidatedByTrigger__c = false,
            NOB_Reception__c = NOB_AP00_Constants.COMMUNICATION_NONLUE,
            NOB_Bodyshop__c = user.AccountId
          );

          if (mapCommsInsert != null && !mapCommsInsert.containsKey(comm.NOB_UtilisateurGarage__c)){
              mapCommsInsert.put(comm.NOB_UtilisateurGarage__c, comm);
          }
        }
      }

      if (!mapCommsInsert.isEmpty()){
        persistRecords(mapCommsInsert, 'insert');
      }
    }

    
    public static void persistRecords(Map<Id, SObject> Mapobjs,  String operationType){
      if (!Mapobjs.isEmpty()){
          //try{
              
              if (operationType == 'insert'){
                insert Mapobjs.values();
              }

              if (operationType == 'update'){
                update Mapobjs.values();
              }
              
          //}catch(DmlException dmle){
              //system.debug(LoggingLevel.ERROR, 'Error : '+ dmle.getMessage() + 'at' + dmle.getStackTraceString());
          //}
      }
    }

    // public static void preventPublishOnInsert(List<NOB_Expedition__c> lstNewExpeditions){
    //   for (NOB_Expedition__c exp : lstNewExpeditions){
    //     if (exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
    //         exp.addError('custom label error publish on creation');
    //     }
    //   }
    // }

    //prevent delete of expedition if contains communication
    // public static void preventDeleteExp(List<NOB_Expedition__c> lstOldExpeditions){
    //   for (NOB_Expedition__c exp : lstOldExpeditions){
    //     if (exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
    //         exp.addError('custom label error publish on delete');
    //     }
    //   }
    // }

    //prevent delete of communication if contains expedition published
    public static void preventDeleteComm(Map<Id,NOB_Communication__c> mapOldComms){
      Map<Id, NOB_Communication__c> mapCommPublished = new Map<Id, NOB_Communication__c>();
      for(NOB_Communication__c comm : [SELECT Id from NOB_Communication__c where NOB_Expedition__r.NOB_StatutDeploiement__c =: NOB_AP00_Constants.EXPEDITION_PUBLISH AND id IN: mapOldComms.keySet()]){
        if (!mapCommPublished.containsKey(comm.Id)){
          mapCommPublished.put(comm.Id, comm);
        }
      }

      if (!mapCommPublished.isEmpty()){
        for (Id comId : mapOldComms.keySet()){
          if (mapCommPublished.containsKey(comId)){
            mapOldComms.get(comId).addError(String.format(System.Label.NOB_ErrorNewsletter, 
            new List<Object>{ 'La suppression'}));
          }
  
        }
      }
    }

    //prevent update of expedition if status = 'published'
    public static void preventUpdateExpedition(List<NOB_Expedition__c> lstExpeditionPublished){
      for (NOB_Expedition__c exp : lstExpeditionPublished){
        exp.addError(String.format(System.Label.NOB_ErrorNewsletter, 
        new List<Object>{ 'La mise à jour'}));
      }
    }

    //RaiseError if expedition has > 1 notes on publish
    public static void preventPublish(Map<Id, NOB_Expedition__c> mapExpPreventPublish){
      Map<Id, List<ContentDocumentLink>> mapFiles = checkNoteSize(mapExpPreventPublish);
      for (Id expId : mapExpPreventPublish.keySet()){
        if (mapFiles != null && mapFiles.containsKey(expId)){
          if (mapFiles.get(expId).size() > 1){
            mapExpPreventPublish.get(expId).addError(System.Label.NOB_Newsletter_Note_error);
          }

          //expedition in bulk
          if (mapFiles.get(expId).isEmpty()){
            mapExpPreventPublish.get(expId).addError(System.Label.NOB_Newsletter_Note_error);
          }

          //save and getPublishedDate
          if (mapFiles.get(expId).size() == 1){
            mapExpPreventPublish.get(expId).NOB_Tech_DateDePublication__c = Datetime.parse(DateTime.now().format());
          }

        }

        //1 expedition
        if (mapFiles.isEmpty()){
          mapExpPreventPublish.get(expId).addError(System.Label.NOB_Newsletter_Note_error);
        }
      }
    }

    private static Map<Id, List<ContentDocumentLink>> checkNoteSize(Map<Id, NOB_Expedition__c> mapExpeditions){
      Map<Id,List<ContentDocumentLink>> mapNotes = new Map<Id,List<ContentDocumentLink>>();
      for (ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId IN :mapExpeditions.keySet() and ContentDocument.FileType = 'SNOTE']){
        if(mapNotes.containsKey(cdl.LinkedEntityId)) {
          mapNotes.get(cdl.LinkedEntityId).add(cdl);
        } else {
          mapNotes.put(cdl.LinkedEntityId, new List<ContentDocumentLink>{cdl});
        }
      }

      return mapNotes;
    }

    public static void preventNotesDML(Map<Id, ContentDocument> mapContentDocument, Map<Id, Id> mapCDLink){
      Map<Id, NOB_Expedition__c> mapExpeditions = new Map<Id, NOB_Expedition__c>();

      if (!mapCDLink.isEmpty()){
        for (NOB_Expedition__c exp : [SELECT Id, NOB_StatutDeploiement__c from NOB_Expedition__c where Id IN: mapCDLink.values() and NOB_StatutDeploiement__c =: NOB_AP00_Constants.EXPEDITION_PUBLISH]){
          mapExpeditions.put(exp.Id, exp);
        }
      }

      if(!mapExpeditions.isEmpty()){
        for (id cdId : mapContentDocument.keySet()){
          if (mapCDLink.containsKey(cdId)){
            if (mapExpeditions.containsKey(mapCDLink.get(cdId))){
              mapContentDocument.get(cdId).addError(String.format(System.Label.NOB_ErrorNewsletter, 
              new List<Object>{ 'La mise à jour'}));
            }
          }
        }
      }
    }

    public static void removeRecOnNoteNotAllowed2(List<ContentDocumentLink> listCDLinkToInsert, set<Id> setIds){
     
      Map<Id, NOB_Expedition__c> mapExpeditionPublished = new Map<Id, NOB_Expedition__c>();
      for (NOB_Expedition__c exp : [SELECT Id, NOB_StatutDeploiement__c from NOB_Expedition__c where Id IN: setIds and NOB_StatutDeploiement__c =: NOB_AP00_Constants.EXPEDITION_PUBLISH]){
        mapExpeditionPublished.put(exp.Id, exp);
      }


      if (!mapExpeditionPublished.isEmpty()){
  
        for (ContentDocumentLink cdl : listCDLinkToInsert){

          if (mapExpeditionPublished.containsKey(cdl.LinkedEntityId)){
      
            cdl.addError(String.format(System.Label.NOB_ErrorNewsletter, 
            new List<Object>{ 'La suppression'}));
          }
        }
      }
    }

    public static void deleteRecipient (set<Id> setExpeditionsToDelete){

      List<NOB_Communication__c> lstCommDel = new list<NOB_Communication__c>();

      for(NOB_Communication__c comm : [SELECT Id from NOB_Communication__c where NOB_Expedition__c IN: setExpeditionsToDelete]){
        lstCommDel.add(comm);
      }
      if (lstCommDel.size() > 0){

        delete lstCommDel;

      }

    }


}