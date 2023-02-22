/*
 @File Name          : NOB_LC50_SemaineType_TEST
 @Description        : Test class for NOB_LC50_SemaineType
 @Author             : HMO
 @Group              : 
 @TicketNumber       : RSIW - 1668
 @Last Modified By   : ARA
 @Last Modified On   : 01-26-2021
 @Modification Log   : 

 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    27/11/2020, 13.42     HMO      1.0
*/

@isTest
public without sharing class NOB_LC50_SemaineType_TEST {
    static User userAdmin;
    static Account bodyshopAcc;
    static List<NOB_Planning__c> lstPlanning;
    
    static{
        userAdmin = TestFactory.createPrefikarUser('userAdmin');
        userAdmin.NOB_SemaineType__c ='';

        insert userAdmin;

        lstPlanning = new List<NOB_Planning__c>();

        System.runAs(userAdmin){
            bodyshopAcc = TestFactory.createPrefikarBodyAccount('reparateurNobilas', 'Réseau Premium','siret123','Actif');
            insert bodyshopAcc;

            lstPlanning.add(TestFactory.createPlanning(bodyshopAcc.Id));
            lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),System.today().month(), System.today().day()+1, 7, 00, 00);
            lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),System.today().month(), System.today().day()+1, 8, 00, 00);
            lstPlanning[0].NOB_IntegrerEnSemaineType__c = true;
            lstPlanning[0].NOB_DeSemaineType__c = true;
            lstPlanning[0].NOB_Status__c = 'Disponible';
            //lstPlanning[0].Name = '';
            lstPlanning[0].NOB_OriginalStartDate__c = Datetime.newInstance(System.today().year(),System.today().month(), System.today().day()+1, 7, 00, 00);
            lstPlanning[0].NOB_OriginalEndDate__c = Datetime.newInstance(System.today().year(),System.today().month(), System.today().day()+1, 8, 00, 00);
            lstPlanning[0].NOB_BodyShop__c = bodyshopAcc.Id;

            insert lstPlanning;

            //insert times
            //insert va;
            //planninginstance
        }
    }

    @isTest
    public static void testaddInSemaineTypeNotNullDispo(){
        System.runAs(userAdmin){
            Test.startTest();
                String semaineType = '{"config":{"Lundi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Vendredi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';
                userAdmin.NOB_SemaineType__c = semaineType;
                update userAdmin;

                lstPlanning[0].NOB_Status__c = 'Disponible';
                update lstPlanning;

                String semainTypeUser = NOB_LC50_SemaineType.getSemaineType();
            Test.stopTest();
            System.assertEquals(semaineType, semainTypeUser);
        }
    }

    @isTest
    public static void testaddInSemaineTypeNullDispo(){
        System.runAs(userAdmin){
            Test.startTest();
                String semaineType ='{"config":{"Lundi":{"dispo":[],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[],"abs":[]},"Vendredi":{"dispo":[],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';
                userAdmin.NOB_SemaineType__c = semaineType;
                update userAdmin;

                lstPlanning[0].NOB_Status__c = 'Absence';
                update lstPlanning;
                String semainTypeUser = NOB_LC50_SemaineType.getSemaineType();
            Test.stopTest();
            System.assertEquals(semaineType, semainTypeUser);
        }
    }

    @isTest
    public static void testAddInSemaineType(){
        System.runAs(userAdmin){
            Test.startTest();
            String semaineType = '{"config":{"Lundi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[{"from":"15:00","to":"16:00","quantity":4}],"abs":[]},"Vendredi":{"dispo":[],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';
                 NOB_LC50_SemaineType.addInSemaineType(lstPlanning);
            Test.stopTest();
        }
    }

    @isTest
    public static void testEmptySemaineType(){
        System.runAs(userAdmin){
            Test.startTest();
            String semaineType = '{"config":{"Lundi":{"dispo":[],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[],"abs":[]},"Vendredi":{"dispo":[],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';
                NOB_LC50_SemaineType.addInSemaineType(lstPlanning);
            Test.stopTest();
        }
    }

    @isTest
    public static void testAddInSemaineTypeAbsence(){
        System.runAs(userAdmin){
            Test.startTest();
            String semaineType = '{"config":{"Lundi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[{"from":"15:00","to":"16:00","quantity":4}],"abs":[]},"Vendredi":{"dispo":[],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';

            lstPlanning[0].NOB_Status__c = 'Absence';
            update lstPlanning;
                 NOB_LC50_SemaineType.addInSemaineType(lstPlanning);
            Test.stopTest();
        }
    }

    @isTest
    public static void testSaveSemaineType(){
        System.runAs(userAdmin){
            Test.startTest();
            String semaineType = '{"config":{"Lundi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Mardi":{"dispo":[],"abs":[]},"Mercredi":{"dispo":[],"abs":[]},"Jeudi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Vendredi":{"dispo":[{"from":"07:00","to":"08:00","quantity":1}],"abs":[]},"Samedi":{"dispo":[],"abs":[]}},"until":"2020-12-30T00:00:00.000Z"}';
            userAdmin.NOB_SemaineType__c = semaineType;
            update userAdmin;

            String semainTypeUser = NOB_LC50_SemaineType.getSemaineType();

            lstPlanning[0].NOB_Status__c = 'Disponible';
            update lstPlanning;

            NOB_LC50_SemaineType.addInSemaineType(lstPlanning);
                 User u = NOB_LC50_SemaineType.saveSemaineType(semainTypeUser);
            Test.stopTest();
            List<User> lstUser = [SELECT Id, NOB_SemaineType__c FROM User WHERE Id =: u.Id];
            System.assertEquals(lstUser[0].Id, u.Id);
        }
    }
}