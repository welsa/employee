/*
 @File Name          : NOB_AP51_SMSSender_TEST
 @Description        : Test class for NOB_AP51_SMSSender
 @Author             : JPI
 @Group              : 
 @Last Modified By   : hansraj.mohiputlall@spoonconsulting.com
 @Last Modified On   : 16-07-2021
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    20/11/2020, 16:50               JPI      1.0
  1.1    16-07-2021, 10:03               HMO      resolving duplication error on Accounts + rsiw 10319
*/
@isTest
public with sharing class NOB_AP51_SMSSender_TEST {

    static User userAdmin;
    static List<Contact> listContact;
    static List<Account> listAccount;
    static List<NOB_Planning__c> listPlanning;
    static List<WorkOrder> ListWorkOrder;
    static List<NOB_SMSLog__c> listSMSLog;
    static List<Case> listCase;
    static List<NOB_SMSLogConfig__c> lstSmsConfig;

    static {

        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        userAdmin.BypassValidationRules__c = true;
        insert userAdmin;

        system.runas(userAdmin){
            NOB_SMSLogConfig__c config = new NOB_SMSLogConfig__c();
            config.Name = 'Config 1';
            config.NOB_ClientId__c = '10d0e1adc5c149ca8d6eae19dc38e247';
            config.NOB_ClientSecret__c = '8387887837';
            config.NOB_Endpoint__c = 'test';
            config.Etape6AXA__c = ' Bonjour ,La restitution de votre véhicule aura lieu le {0} à l’adresse indiquée.Merci de votre confiance.Votre garage (test axa)';
            config.Etape5AXA__c = 'Bonjour,Vos réparations sont un peu plus long que prévu, nous sommes desoles de reporter la date de fin de réparations au {0}.Vous serez contacté 24h avant pour fixer un RDV de restitution.Merci de votre compréhension Votre garage (test axa)';
            config.Etape3AXA__c = 'Bonjour,RDV confirmé le {0} entre {1} et {2} avec notre garage joignable au {3}.Service A Domicile (test axa)';
            //HMO -- 27-04-2021
            config.Etape1AXA__c = 'testEtape1A';
            config.Etape1DA__c = 'testEtape1D';
            config.Etape2AXA__c = 'testEtape2A';
            config.Etape2DA__c = 'testEtape2D';
            config.Etape3DA__c = 'testEtape3D';
            config.Etape4AXA__c = 'testEtape4A';
            config.Etape4DA__c = 'testEtape4D';
            config.Etape5bAXA__c = 'testEtape5Ba';
            config.Etape5bDA__c = 'testEtape5Bd';
            config.Etape5DA__c = 'testEtape5DA';
            config.Etape6DA__c = 'Etape6Da';
            //
            insert config;

            //HMO -- 16-07-2021
            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('TestAcc1','Nord'),
                TestFactory.createPrefikarBodyAccount('TestAcc2', 'Réseau Platinium','','actif'),
                TestFactory.createInsurerAccount('TestAcc3','Bourgogne'),
                TestFactory.createPrefikarBodyAccount('TestAcc4', 'Réseau Platinium','','actif')
            };
            listAccount[0].NOB_SiretHeadquarters__c = '874932442423';
            listAccount[0].NOB_GTACode__c = '89749';
            listAccount[0].VATNumber__c = '0974208232323';
            listAccount[0].NOB_DarvaIdentifier__c = '82298303';
            listAccount[0].ReferenceNumber__c = '640283';

            listAccount[1].NOB_SiretHeadquarters__c = '97632832690921';
            listAccount[1].NOB_DarvaIdentifier__c = '97232399';
            listAccount[1].VATNumber__c = '422';
            listAccount[1].ReferenceNumber__c = '986444';

            listAccount[2].NOB_SiretHeadquarters__c = '43243221312113';
            listAccount[2].NOB_GTACode__c = '08078';
            listAccount[2].VATNumber__c = '908323327';
            listAccount[2].NOB_DarvaIdentifier__c = '45216';


            listAccount[3].NOB_SiretHeadquarters__c = '31049995900891';
            listAccount[3].Phone = '23232323';
            listAccount[3].NOB_DarvaIdentifier__c = '25426';
            
            insert listAccount;

            listContact = new List<Contact>{
                TestFactory.createInsuredContact('Test', 'One', listAccount[0].id,'Nord'),
                TestFactory.createInsuredContact('Test', 'Three', listAccount[0].id,'Bourgogne'),
                    TestFactory.createInsuredContact('Test', 'Threed', listAccount[0].id,'Bourgogne'),
                    TestFactory.createInsuredContact('Test', 'Threed', listAccount[0].id,'Bourgogne'),
                    TestFactory.createInsuredContact('Test', 'Threeds', listAccount[0].id,'Bourgogne'),
                    TestFactory.createInsuredContact('Test', 'Threed34', listAccount[0].id,'Bourgogne'),
                    TestFactory.createInsuredContact('Test', 'Threeds32', listAccount[0].id,'Bourgogne')
            };
            listContact[0].AssistantPhone = '+990734343432';
            listContact[0].Phone = '+90712345637653';
            listContact[0].MobilePhone = '00062543752356';
            listContact[0].OtherPhone = '+990712345637653';
            listContact[0].HomePhone = null;
            listContact[1].AssistantPhone = '00000343432';
            
            listContact[1].Phone = '345637653';
            listContact[1].MobilePhone = '000000752356';
            listContact[1].OtherPhone = '345637653';
            listContact[1].HomePhone = null;
            
            listContact[2].AssistantPhone = '000000343432';
            listContact[2].Phone = '345637653';
            listContact[2].MobilePhone = '0712345637653';
            listContact[2].OtherPhone = '345637653';
            listContact[2].HomePhone = null;
            
            listContact[3].AssistantPhone = '00000000343432';
            listContact[3].Phone = '345637653';
            listContact[3].MobilePhone = '000752356';
            listContact[3].OtherPhone = '0712345637653';
            listContact[3].HomePhone = null;
            
            listContact[4].AssistantPhone = '00000343432';
            listContact[4].Phone = '345637653';
            listContact[4].MobilePhone = '00000752356';
            listContact[4].OtherPhone = '345637653';
            listContact[4].HomePhone = '0712345637653';

            listContact[5].AssistantPhone = '00000343432';
            listContact[5].Phone = '345637653';
            listContact[5].MobilePhone = '00000752356';
            listContact[5].OtherPhone = '345637653';
            listContact[5].HomePhone = '0712345637653';

            listContact[6].AssistantPhone = '00000343432';
            listContact[6].Phone = '345637653';
            listContact[6].MobilePhone = '00000752356';
            listContact[6].OtherPhone = '345637653';
            listContact[6].HomePhone = '0712345637653';
            
            insert listContact;

            listPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(listAccount[1].Id)
            };
            insert listPlanning;

            listCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', listContact[0].id, listAccount[0].id, 'AUDI', '3061','12345asd','test1',Datetime.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day()-5, 17, 00, 0),'AR1234','Body','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', listContact[1].id, listAccount[0].id, 'TESL', '3061','123456ab','test2',Datetime.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day()-6, 17, 00, 0),'AR345','Body1','Peinture')
            };
            listCase[0].NOB_TECH_DispoId__c = listPlanning[0].Id;
            listCase[0].NOB_BodyShop__c = listAccount[1].Id;
            //listCase[1].NOB_Integration__c = 'Échec';
            insert listCase;

            ListWorkOrder = new List<WorkOrder>{
                TestFactory.createWorkOrder('Nouveau', listCase[1].Id),
                TestFactory.createWorkOrder('Nouveau', listCase[0].Id)

            };
            insert ListWorkOrder;

            listSMSLog = new List<NOB_SMSLog__c>{
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_1', NOB_Contact__c = listContact[0].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_2', NOB_Contact__c = listContact[1].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_3', NOB_Contact__c = listContact[2].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_4', NOB_Contact__c = listContact[3].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_5', NOB_Contact__c = listContact[4].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_5B', NOB_Contact__c = listContact[0].Id),
                new NOB_SMSLog__c(NOB_Case__c = listCase[1].Id, NOB_Statut__c = 'To be send', NOB_Subject__c = 'Etape_6', NOB_Contact__c = listContact[1].Id),
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_2',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[1].Id,
                    NOB_Contact__c = listContact[1].Id,
                    NOB_WorkOrder__c = ListWorkOrder[1].Id
                ),
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_3',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[1].Id,
                    NOB_Contact__c = listContact[2].Id,
                    NOB_WorkOrder__c = ListWorkOrder[1].Id
                ),
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_4',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[1].Id,
                    NOB_Contact__c = listContact[3].Id,
                    NOB_WorkOrder__c = ListWorkOrder[1].Id
                ),
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_5',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[1].Id,
                    NOB_Contact__c = listContact[4].Id,
                    NOB_WorkOrder__c = ListWorkOrder[1].Id
                ),
                //HMO -- 16-07-2021
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_5B',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[0].Id,
                    NOB_Contact__c = listContact[0].Id,
                    NOB_WorkOrder__c = ListWorkOrder[0].Id
                ),
                new NOB_SMSLog__c(
                    NOB_Subject__c = 'Etape_6',
                    NOB_Statut__c = 'To be send',
                    NOB_Case__c = listCase[1].Id,
                    NOB_Contact__c = listContact[1].Id,
                    NOB_WorkOrder__c = ListWorkOrder[1].Id
                )     
            };
              for(NOB_SMSLog__c sms : listSMSLog){
                  sms.NOB_WorkOrder__c = ListWorkOrder[1].Id;
            }
        }

    }

    @isTest
    public static void insertSMSLogs(){
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMockResponse()); 
        insert listSMSLog;
        Test.stopTest();
    }

    @isTest
    public static void updateSMSLogs(){
        insert listSMSLog;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMockResponse()); 
        listSMSLog[0].NOB_Subject__c = 'Etape_3';
        update listSMSLog;
        Test.stopTest();
    }

    public with sharing class HttpMockResponse  implements HttpCalloutMock  {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('content-Type', 'application/json');
            res.setBody('{"message":"Bonjour,\r\nRDV confirmé le 11/01/2021 entre 10:00 et 11:00 avec notre garage joignable au 0145261167. \r\nService A Domicile (test axa)","telephone":"22222222222"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testSetSms(){
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

          Test.startTest();
            insert listSMSLog;
            
            NOB_AP51_SMSSender.setSMS('NOB_SMS_Etape_1', listContact[0].Phone, listSMSLog[0].Id);
            Test.stopTest();
    }
}