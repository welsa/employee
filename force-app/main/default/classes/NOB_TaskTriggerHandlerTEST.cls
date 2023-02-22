@isTest
public with sharing class NOB_TaskTriggerHandlerTEST {
    static User userAdmin;
    static List<Account> lstInsurerAccount;
    static List<Contact> lstInsuredContact;
    static List<Case> lstCase;
    static List<WorkOrder> lstWorkOrder;
    static List<Account> lstAccountBodyshop;
    static List<Task> lstTask;
    private static list<Nob_MesDocuments__c> lstMesDoc;
    private static List<Account> lstAcc;
    private static List<Contact> lstCon;
    private static User bodyShopContact;


    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        insert userAdmin;
        
        lstInsurerAccount = new List<Account>();
        lstInsuredContact = new List<Contact>();
        lstCase = new List<Case>();
        lstWorkOrder = new List<WorkOrder>();
        lstAccountBodyshop = new List<Account>();

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Prefikar' Limit 1];

        userAdmin.UserRoleId = userRole.Id;
        update userAdmin;


        System.runAs(userAdmin){
            Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month()-1, System.today().day(), 17, 00, 0);

            lstInsurerAccount = new List<Account>{
                TestFactory.createInsurerAccount('testAccAssure', '49492059811')
            };
            lstInsurerAccount[0].Nob_CTICampaignNumber__c = 'test13345';
            insert lstInsurerAccount;
            
            lstInsuredContact = new List<Contact> {
                TestFactory.createInsuredContact('test', 'contactAssure', lstInsurerAccount[0].Id, 'Alsace Lorraine')
            };
            
            lstCase = new List<Case> {
                TestFactory.createCaseStandard('Nouvelle', lstInsuredContact[0].Id, lstInsurerAccount[0].Id, 'Audi', 'Quattro','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture')
            };
            lstAccountBodyshop = new List<Account>{
                TestFactory.createPrefikarBodyAccount('testAccBodyshop', '', '49492059811', 'actif')
            };

            

            lstInsuredContact[0].FirstName='John';
            lstInsuredContact[0].LastName='Smith';
            lstInsuredContact[0].Phone = '55555555';
            lstInsuredContact[0].Email = 'johntest@test.eu';
            lstInsuredContact[0].MailingPostalCode = '98980';
            lstInsuredContact[0].MailingCity = 'Roswell';
            lstInsuredContact[0].MailingStreet = '09 street';
            lstInsuredContact[0].MobilePhone = '00000001';
            lstInsuredContact[0].OtherPhone = '10000000';


            lstCase[0].NOB_Franchise__c = 2000;
            lstCase[0].NOB_Variable__c = 10;
            lstCase[0].NOB_VariableMax__c = 15;
            lstCase[0].NOB_VariableMin__c = 5;
            lstCase[0].NOB_InsurerClaimNumber__c = '123456789zxx';
            lstCase[0].NOB_ContractRefVR__c = '1234567x';
            lstCase[0].NOB_ContractRefSAD__c = '546627x';

            lstAccountBodyshop[0].BillingCity= 'Curepipe';
            lstAccountBodyshop[0].BillingPostalCode = '97025';
            lstAccountBodyshop[0].BillingStreet = 'Elf street';
            lstAccountBodyshop[0].Fax = '12345678';
            lstAccountBodyshop[0].Name = 'Bob Sinclaire';
            lstAccountBodyshop[0].Phone = '12345678';

            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US'),
                TestFactory.createAccountBodyshop('cmptRep', 'US')
            };
            for(Account acc: lstAcc){
                acc.NOB_isPrefikar__c = true;
                acc.NOB_Statut__c = 'Actif';
            }
            insert lstAcc;
            lstCon = new List<Contact>{
                TestFactory.createBodyshopContact('test', 'test', lstAcc.get(0).Id),
                TestFactory.createBodyshopContact('test2', 'test2', lstAcc.get(1).Id)
            };
            lstCon.get(0).AccountId = lstAcc.get(0).Id;
            lstCon.get(1).AccountId = lstAcc.get(1).Id;
            for(Integer i = 0; i < lstCon.size(); i++){
                lstCon.get(i).email = 'test'+ i +'@test.com';
                lstCon.get(i).NOB_FunctionServices__c = 'Dirigeant';
                lstCon.get(i).NOB_Status__c = 'Actif';
            }
            insert lstCon;

            lstMesDoc = new List<Nob_MesDocuments__c>{
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(1).Id, lstAcc.get(1).Id),
                TestFactory.createAttestationAssurance(lstCon.get(1).Id, lstAcc.get(1).Id)
            };
            lstMesDoc.get(1).NOB_Status__c = 'Active';
            lstMesDoc.get(1).NOB_DateFin__c = NOB_BatchMyDocs.getDatesAfter();
            lstMesDoc.get(2).NOB_Status__c = 'Expired';
            lstMesDoc.get(2).NOB_DateDebut__c = Date.today().addDays(-7);
            lstMesDoc.get(3).NOB_DateFin__c = Date.today();
            lstMesDoc.get(3).NOB_Status__c = 'Active';
            lstMesDoc.get(4).NOB_Status__c = 'Expired';
            lstMesDoc.get(4).NOB_DateDebut__c = Date.today().addDays(-7);
            lstMesDoc.get(4).NOB_DateFin__c = Date.today();
            lstMesDoc.get(4).NOB_LastSentEmail__c = NOB_BatchMyDocs.getDatesBefore();
            insert lstMesDoc;

            bodyShopContact = TestFactory.createPrefikarUser('Rep');
            bodyShopContact.contactId = lstCon[0].Id;
            Id profileIdz = [SELECT Id from Profile where Name = 'CCP Bodyshop']?.Id;
            bodyShopContact.profileId = ProfileIdz;
            insert bodyShopContact;

            
            insert lstInsuredContact;
            insert lstCase;
            insert lstAccountBodyshop;

            lstTask = new List<Task>{
                new Task(whatid = lstCase[0].id,
                        subject = NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie, 
                        Type = 'Call',
                        PFR_CallStatus__c = 'À appeler',
                        PFR_CallPreferedStartTime__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 07, 00, 0),
                        PFR_CallPreferedEndTime__c =Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 17, 00, 0)
                        ),
                new Task(whatid = lstCase[0].id,
                        subject = NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie, 
                        Type = 'Call',
                        PFR_CallStatus__c = 'À appeler',
                        PFR_CallPreferedStartTime__c = Datetime.newInstance(2038, 1, 1, 19, 00, 0),
                        PFR_CallPreferedEndTime__c =Datetime.newInstance(2038, 1, 1, 20, 00, 0)
                        ),
                new Task(whatid = lstCase[0].id,
                        subject = NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie, 
                        Type = 'Call',
                        PFR_CallStatus__c = 'À appeler',
                        PFR_CallPreferedStartTime__c = Datetime.newInstance(2038, 1, 2, 19, 00, 0),
                        PFR_CallPreferedEndTime__c =Datetime.newInstance(2038, 1, 2, 20, 00, 0)
                        ),
                new Task(whatid = lstCase[0].id,
                        subject = NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie, 
                        Type = 'Call',
                        PFR_CallStatus__c = 'À appeler',
                        PFR_CallPreferedStartTime__c = Datetime.newInstance(2038, 1, 3, 19, 00, 0),
                        PFR_CallPreferedEndTime__c =Datetime.newInstance(2038, 1, 3, 20, 00, 0)
                        ),
                new Task(whatid = lstCase[0].id,
                        subject = NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie, 
                        Type = 'Call',
                        PFR_CallStatus__c = 'À appeler'
                        ),
                new Task(
                         subject = 'Task Attestation',
                         Type = NOB_AP00_Constants.TASK_TYPE_DOCUMENTCONTRACUEL,
                         OwnerId = userAdmin.Id,
                         WhoId = lstCon[0].Id,
                         WhatId = lstMesDoc[0].Id,
                         TaskSubtype = 'Email'
                        )
            };

        }
    }

    @isTest
    public static void preferedTimeNotNullBeforeInsertTEST(){
        System.runAs(userAdmin){
            Test.startTest();
            NOB_TaskTriggerHandler.testDate =Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+7,06,00,0);
            
            insert lstTask;
            Test.stopTest();
        }
    }
     @isTest
    public static void preferedTimeIsNullBeforeInsertTEST(){
        System.runAs(userAdmin){
            Test.startTest();  
            
          NOB_TaskTriggerHandler.testDate =Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+7,09,00,0);
            
            insert lstTask;
            Test.stopTest();
        }
    }
    @isTest
    public static void CreatedTimeGreaterMorningStartAndLessEveningEnd(){
        System.runAs(userAdmin){
            Test.startTest();  
            
          NOB_TaskTriggerHandler.testDate =Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+3,20,00,0);
            
            insert lstTask;
            Test.stopTest();
        }
    }

    //HMO -- 29-03-2022
    @isTest
    public static void onBeforeDelete(){
        System.runAs(userAdmin){
            insert lstTask;
            Test.startTest();
                delete lstTask[5];
            Test.stopTest();
        }
    }
        
}