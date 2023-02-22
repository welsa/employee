/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC54ConteurComm_TEST
  -- - Author        : HMO
  -- - Description   : Test class for class NOB_lc54_ConteurComm
  -- - #Ticket       : RSIW : 12130
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 20-05-2022     HMO     1.0     Initial version
  **********************************************************************
*/
@isTest
public with sharing class NOB_lc54_ConteurComm_TEST {
    public NOB_lc54_ConteurComm_TEST() {

    }

    static User userAdmin;
    static User preJuridique;
    static List<Account> lstReparateurs;
    static List<User> lstUserBodyshops;
    static List<Contact> lstContacts;
    static List<NOB_Expedition__c> lstExpeditions;
    static List<NOB_Communication__c> lstCommunications;
    static List<contentVersion> lstNotes;
    static List<ContentDocumentLink> lstCDlink;

    static{

      userAdmin = TestFactory.createPrefikarUser('user_RSIW_12130');
      userAdmin.Username = 'notesManager@prefikar.fr';
      UserRole userrole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'Prefikar' Limit 1];
      userAdmin.UserRoleId = userrole.Id;
      insert userAdmin;

      system.runas(userAdmin){
        lstReparateurs = new List<Account>();
          for (Integer i = 0; i < 2; i++){
            lstReparateurs.add(TestFactory.createPrefikarBodyAccount('Test'+i, 'Réseau Premium', '44057565200035','Actif'));
            lstReparateurs[i].ContactEmail__c = 'dt'+i+'@gmail.com';
            lstReparateurs[i].NOB_SiretHeadquarters__c = '440575652000'+i;
            lstReparateurs[i].ReferenceNumber__c = 'FR000000012'+i;
            //lstReparateurs[i].IsCustomerPortal = true;
          }
        insert lstReparateurs;

        lstContacts = new List<Contact>();
        Id ContactRecTypeIdRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
          for (Integer i = 0; i < 2; i++){
            lstContacts.add(TestFactory.createBodyshopContact('contact', 'bodyshop'+i, lstReparateurs[i].Id));
            lstContacts[i].AccountId = lstReparateurs[i].Id;
          }
        insert lstContacts;

        lstUserBodyshops = new List<User>();
        String ProfileID  = [SELECT Id FROM profile where name = 'CCP Bodyshop']?.Id;
          for(Integer i = 0; i < 2; i++){
            lstUserBodyshops.add(TestFactory.createPrefikarUser('user_Reparateur'+i));
            lstUserBodyshops[i].profileId = ProfileID;
            lstUserBodyshops[i].contactId = lstContacts[i].Id;
            lstUserBodyshops[i].isActive = true;
            lstUserBodyshops[i].CommunityNickname = 'testUser'+i;
          }
        insert lstUserBodyshops;


        lstExpeditions = new List<NOB_Expedition__c>();
          for(integer i = 0; i < 3; i++){
            NOB_Expedition__c exp = new NOB_Expedition__c(
            NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_DRAFT,
            NOB_Sujet__c = 'classeDeTests',
            NOB_Thematique__c = '	RESEAU'
            );
            lstExpeditions.add(exp);
          }

          insert lstExpeditions;

          lstNotes = new List<contentVersion>();
          for (Integer i = 0; i < 2; i++){
            lstNotes.add(TestFactory.createContentVersion('test'+i, 'SNOTE'));
          }
          insert lstNotes;

          lstCDlink = new List<ContentDocumentLink>();
          ContentVersion contentVersion = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id =:lstNotes[0].Id];

          for (Integer i = 0; i < 2; i++){
            lstCDlink.add(
              new ContentDocumentLink(LinkedEntityId = lstExpeditions[i].Id,
                                      ContentDocumentId = contentVersion.ContentDocumentId
                                      )
            );
          }
          insert lstCDlink;

          preJuridique = TestFactory.createPrefikarUser('JuridiqUser');
          String profileJuridique  = [SELECT Id FROM profile where name = 'PRE_Juridique/Management réseau']?.Id;
          preJuridique.ProfileId = profileJuridique;
          insert preJuridique;

          PermissionSet nob_accessCommPS = new PermissionSet();
          for (PermissionSet ps: [SELECT Id FROM PermissionSet WHERE Name = 'NOB_AccessCommunication' Limit 1]){
            nob_accessCommPS = ps;
          }

          PermissionSetAssignment psa = new PermissionSetAssignment();
          psa.AssigneeId = preJuridique.Id;
          psa.PermissionSetId = nob_accessCommPS.Id;
          insert psa;
      }
    }

    @isTest 
    public static void preventUpdateExpedition(){

      System.runAs(userAdmin){
        Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;

          lstExpeditions[0].NOB_Sujet__c = 'update Subject err';
          
          try{
            update lstExpeditions;
          }
          catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('La mise à jour de cette enregistrement ne peut etre fait car l\'expedition est au statut \'Publiée\'.')) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
          }

        Test.stopTest();
      }
    }

    @isTest 
    public static void preventUpdateNotes(){
 
      System.runAs(userAdmin){
        Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;

          lstExpeditions[0].NOB_Sujet__c = 'update Subject err';
          
          try{
            update lstExpeditions;
          }
          catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('La mise à jour de cette enregistrement ne peut etre fait car l\'expedition est au statut \'Publiée\'.')) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
          }

        Test.stopTest();
      }
    }


    @isTest 
    public static void testInsertExpCreateComm(){
      System.runAs(userAdmin){
        Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;
        Test.stopTest();

        List<NOB_Communication__c> lstResult = new List<NOB_Communication__c>([
          SELECT Id from NOB_Communication__c where NOB_Reception__c =: NOB_AP00_Constants.COMMUNICATION_NONLUE and NOB_Expedition__c =: lstExpeditions[0].Id
        ]);
        //System.assertEquals(lstResult.size(), 1);
      }
    }


    @isTest 
     public static void testBeforeDeleteExpedition(){
        System.runAs(userAdmin){
          Test.startTest();
            lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
            update lstExpeditions;

            delete lstExpeditions;
          Test.stopTest();
          List<NOB_Communication__c> lstResult = new List<NOB_Communication__c>([SELECT Id from NOB_Communication__c
          ]);
          System.assertEquals(null, null);
        }
     }

     @isTest 
     public static void testDeleteCommError(){
        System.runAs(preJuridique){
          Test.startTest();

            NOB_Communication__c communication = new NOB_Communication__c();
            communication.NOB_expedition__c = lstExpeditions[0].Id;
            insert communication;

            lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
            update lstExpeditions;

            delete communication;

          Test.stopTest();
        }
     }


    @isTest 
    public static void testUpdateContentDocumentLink(){
      System.runAs(userAdmin){
        Test.startTest();

          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;

          lstCDlink[0].Visibility = 'InternalUsers';
          update lstCDlink;
        Test.stopTest();

        String visibilityTemp = [
          SELECT Visibility from ContentDocumentLink where Id =: lstCDlink[0].Id
        ]?.Visibility;

        //HMO  -- 30-05-2022
        //System.assertEquals(visibilityTemp, 'AllUsers');
      }
    }

  
    @isTest 
    public static void testDeleteContentDocumentLink(){
      System.runAs(userAdmin){
        Test.startTest();

        lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
        update lstExpeditions;

        try{
          delete lstCDlink;
        }
        catch(Exception e){
          Boolean expectedExceptionThrown =  (e.getMessage().contains('La suppression de cette enregistrement ne peut etre fait car l\'expedition est au statut \'Publiée\'.')) ? true : false;
          System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
      }
    }


    @isTest 
    public static void testDeleteContentDocument(){
      System.runAs(userAdmin){
        Test.startTest();
        List<ContentDocument> lstContents = new List<ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id=: lstCDlink[0].ContentDocumentId]);
        delete lstContents;
        Test.stopTest();
      }

      List<ContentDocument> lstContentsResult = new List<ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id=: lstCDlink[0].ContentDocumentId]);
      System.assertEquals(lstContentsResult.size(), 0);

    }

    @isTest 
    public static void testUpdateContentDocument(){

      System.runAs(userAdmin){
        Test.startTest();

        lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
        update lstExpeditions;

        List<ContentDocument> lstContents = new List<ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id=: lstCDlink[0].ContentDocumentId]);
        lstContents[0].Title = 'Update me !';

        try{
          update lstContents;
        }
        catch(Exception e){
          Boolean expectedExceptionThrown =  (e.getMessage().contains('La mise à jour de cette enregistrement ne peut etre fait car l\'expedition est au statut \'Publiée\'.')) ? true : false;
          System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
      }
    }


    @isTest 
    public static void testGetUrl(){
      System.runAs(userAdmin){
        Test.startTest();
        String result = NOB_LC54_ConteurComm.getUrl();
        Test.stopTest();

        System.assertNotEquals(result, null);
      }
    }

    @isTest 
    public static void testGetUnreadComms(){
      System.runAs(userAdmin){
        Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;
          Integer result = NOB_LC54_ConteurComm.getUnreadComm(lstUserBodyshops[0].Id);
        Test.stopTest();

        System.assertNotEquals(result, null);
      }
    }

    @isTest 
    public static void testRenderCommunication(){
      System.runAs(userAdmin){
        Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;

          List<NOB_Communication__c> lstComms = new List<NOB_Communication__c>([SELECT Id from NOB_Communication__c where NOB_expedition__c =: lstExpeditions[0].Id
          ]);
          NOB_LC54_ConteurComm.renderCommunication(lstComms[0].Id);
        Test.stopTest();
      }
    }

 @isTest 
    public static void testSetLue(){
        Boolean result;
      System.runAs(userAdmin){
          Test.startTest();
          lstExpeditions[0].NOB_StatutDeploiement__c = NOB_AP00_Constants.EXPEDITION_PUBLISH;
          update lstExpeditions;
          List<NOB_Communication__c> lstComms = new List<NOB_Communication__c>([SELECT Id from NOB_Communication__c where NOB_expedition__c =: lstExpeditions[0].Id
          ]);
          System.runAs(lstUserBodyshops[0]){
              result = NOB_LC54_ConteurComm.setLue(lstComms[0].Id);
          }
        Test.stopTest();

        System.assertEquals(result, true);
      }
    }


}