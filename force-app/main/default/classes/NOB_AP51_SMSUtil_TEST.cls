/*
 @File Name          : NOB_AP51_SMSUtil_TEST
 @Description        : Test class for NOB_AP51_SMSUtil
 @Author             : HMO
 @Group              : 
 @Last Modified By   : HMO
 @Last Modified On   : 03/12/2020, 16:15
 @Modification Log   : 
 @TicketNumber       :
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    03/12/2020, 16.45     HMO      1.0
  1.1    12/02/2021, 19.15     HMO      1.1
*/

@isTest
public without sharing class NOB_AP51_SMSUtil_TEST {
    public NOB_AP51_SMSUtil_TEST() {

    }

    static User userAdmin;
    static List<NOB_SMSLog__c> lstSmsLog;
    static List<NOB_SMSLogConfig__c> lstSmsConfig;
    static Account accAssureur;
    static Account accBodyshop;
    static NOB_Planning__c dispo;
    static Case requete;
    static Contact contactAssure;
    static List<WorkOrder> lstWorkOrder;
    static String label;
    static Datetime testDate = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()+1, 15,0,0);
    
    static{
      userAdmin = new User();
      userAdmin = TestFactory.createUser('adminUser');
      userAdmin.BypassValidationRules__c = true;
      userAdmin.BypassWorkflows__c = true;
      insert userAdmin;

      accBodyshop = new Account();
      accAssureur = new Account();
      contactAssure = new Contact();
      requete = new Case();
      lstWorkOrder = new List<WorkOrder>();
      dispo = new NOB_Planning__c();

      System.runAs(userAdmin){
        accBodyshop = TestFactory.createPrefikarBodyAccount('accReparateur', '	Réseau Premium', '23232343', 'Actif');
        insert accBodyshop;

        accAssureur = TestFactory.createInsurerAccount('accAssureur', '4545434');
        insert accAssureur;

        contactAssure = TestFactory.createInsuredContact('contact', 'Assuree', accAssureur.Id,'Alsace Lorraine');
        insert contactAssure;

        requete = TestFactory.createCaseStandard('Nouvelle', contactAssure.Id, accAssureur.Id, 'KIA', 'Eltrix', '8987596','Darva',Date.today()-1,'DC-09', 'Pare Chocs','Réparation');
        requete.NOB_DamageType__c = 'aile-gauche';
        requete.NOB_InsurerClaimNumber__c = '987643567';
        requete.PFR_TECH_STDClaimNr__c = '1234567654';
        requete.PFR_CalculatedCallPreferedStartTime__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 16, 00, 0);
        requete.PFR_CalculatedCallPreferedEndTime__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 17, 00, 0);
        NOB_CaseTriggerHandler.testDate = testDate;
        insert requete;

        String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
        lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', requete.Id));
        lstWorkOrder[0].recordTypeId = recordTypeWo;
        lstWorkOrder[0].NOB_VehiculeReturnDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+2, 16, 00, 0);
        insert lstWorkOrder;

        dispo = TestFactory.createPlanning(accBodyshop.Id);
        dispo.NOB_WorkOrder__c = lstWorkOrder[0].Id;
        insert dispo;

        requete.NOB_TECH_DispoId__c = dispo.Id;
        requete.NOB_BodyShop__c = accBodyshop.Id;
        update requete;

        lstSmsLog = new List<NOB_SMSLog__c>{
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_1'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_2'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_3'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_4'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_5'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_5B'),
          new NOB_SMSLog__c(NOB_Case__c = requete.Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_6')
      };
        for(NOB_SMSLog__c sms : lstSmsLog){
            sms.NOB_WorkOrder__c = lstWorkOrder[0].Id;
        }
        insert lstSmsLog;

        lstSmsConfig = new List<NOB_SMSLogConfig__c>{
          new NOB_SMSLogConfig__c(Name = 'config1',
                                  NOB_ClientId__c = '1009932323',
                                  NOB_ClientSecret__c = '8387887837',
                                  NOB_Endpoint__c = 'test',
                                  Etape1AXA__c = 'NOB_SMS_Etape_1',
                                  Etape1DA__c = 'NOB_SMS_Etape_1',
                                  Etape2AXA__c = 'NOB_SMS_Etape_2',
                                  Etape2DA__c = 'NOB_SMS_Etape_2',
                                  Etape3AXA__c = 'NOB_SMS_Etape_3',
                                  Etape3DA__c = 'NOB_SMS_Etape_3',
                                  Etape4AXA__c = 'NOB_SMS_Etape_4',
                                  Etape4DA__c = 'NOB_SMS_Etape_4',
                                  Etape5AXA__c = 'NOB_SMS_Etape_5',
                                  Etape5bAXA__c = 'NOB_SMS_Etape_5b',
                                  Etape5bDA__c = 'NOB_SMS_Etape_5b',
                                  Etape5DA__c = 'NOB_SMS_Etape_5',
                                  Etape6AXA__c = 'NOB_SMS_Etape_6',
                                  Etape6DA__c = 'NOB_SMS_Etape_6')
        };
        insert lstSmsConfig;
      }
    }

    @isTest
    public static void testEtape1(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_1';
        requete.NOB_InsurerClaimNumber__c = '87864478';
        update requete;
        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[0], requete, lstWorkOrder[0],  lstSmsConfig[0]);
        Test.stopTest();

        List<Case> lstCase = [SELECT Id, PFR_CalculatedCallPreferedStartTime__c, PFR_CalculatedCallPreferedEndTime__c FROM Case WHERE Id=:requete.Id];
        System.assert(lstCase[0].PFR_CalculatedCallPreferedStartTime__c != null);
        System.assert(lstCase[0].PFR_CalculatedCallPreferedEndTime__c != null);
      }
    }

    @isTest
    public static void testEtape2(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_2';
        requete.NOB_InsurerClaimNumber__c = '866899875';
        update requete;

        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[1], requete, lstWorkOrder[0],lstSmsConfig[0]);
          system.debug('## rawLabel 2:'+rawLabel);
        Test.stopTest();
        System.assertEquals(rawlabel, lstSmsConfig[0].Etape2DA__c);
      }
    }

    @isTest
    public static void testEtape3(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_3';
        requete.NOB_InsurerClaimNumber__c = '987638292';
        update requete;
		lstSmsLog[2].NOB_WorkOrder__c = lstWorkOrder[0].Id;
        update lstSmsLog[2];
          String rawLabel = '';
          try{
        	rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[2], requete, lstWorkOrder[0], lstSmsConfig[0]);
          }
          catch(Exception e){
              rawLabel = e.getMessage();
          }         
          system.debug('## rawLabel:'+rawLabel);
          Test.stopTest();
       System.assertEquals(rawlabel,'Impossible de récupérer les informations de rendez-vous');
      }
    }

    @isTest
    public static void testEtape4(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_4';
        requete.NOB_InsurerClaimNumber__c = '6783920298';
        update requete;
        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[3],requete, lstWorkOrder[0],lstSmsConfig[0]);
        Test.stopTest();
        System.assertEquals(rawlabel, lstSmsConfig[0].Etape4DA__c);
      }
    }

    @isTest
    public static void testEtape5(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_5';
        requete.NOB_InsurerClaimNumber__c = '54537272';
        update requete;
        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[4], requete, lstWorkOrder[0], lstSmsConfig[0]);
        Test.stopTest();
        System.assertEquals(rawlabel, lstSmsConfig[0].Etape5DA__c);
      }
    }

    @isTest
    public static void testEtape5B(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_5b';
        requete.NOB_InsurerClaimNumber__c = '32526722';
        update requete;
        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[5], requete, lstWorkOrder[0], lstSmsConfig[0]);
        Test.stopTest();
        System.assertEquals(rawlabel, lstSmsConfig[0].Etape5bDA__c);
      }
    }


    @isTest
    public static void testEtape6(){
      System.runAs(userAdmin){
        Test.startTest();
        label = 'NOB_SMS_Etape_6';
        requete.NOB_InsurerClaimNumber__c = '335352722';
        update requete;
        String rawLabel = NOB_AP51_SMSUtil.getMessage(label, lstSmsLog[6], requete, lstWorkOrder[0], lstSmsConfig[0]);
        Test.stopTest();
        System.assertEquals(rawlabel, lstSmsConfig[0].Etape6DA__c);
      }
    }

    @isTest
    public static void testisAxa(){
        System.runAs(userAdmin){
          Test.startTest();
          accAssureur.NOB_SiretHeadquarters__c = System.Label.PFR_SiretAXA;
          update accAssureur;
          Test.stopTest();

          List<Account> lstAcc = [SELECT Id, NOB_SiretHeadquarters__c FROM Account WHERE Id =: accAssureur.id];
          System.assertEquals(lstAcc[0].NOB_SiretHeadquarters__c, System.Label.PFR_SiretAXA);
          
        }
    }

    // @isTest
    // public static void testReplaceEtapeOne(){
    //   System.runAs(userAdmin){
    //     Test.startTest();

    //     Test.stopTest();
    //   }
    // }
}