/**
 * @description       : Test Class for NOB_LC51_RelatedPlanning
 * @author            : GBH
 * @group             : 
 * @last modified on  : 01-27-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-06-2020   GBH   Initial Version
 * 1.1   27-01-2020   ARA
**/
@isTest
public with sharing class NOB_LC51_RelatedPlanning_TEST {
    static User userAdmin;
    static list<Account> lstBodyShop;
    static list<NOB_Planning__c> lstPlanning;

    static {
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){
            lstBodyShop = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Test 3', 'Réseau Premium', '44057565200035','Actif')
            };
            lstBodyShop[0].BillingStreet = 'Rue de la Fontaine dAscot';
            lstBodyShop[0].BillingPostalCode = '95420';
            lstBodyShop[0].BillingCity = 'Cléry-en-Vexin';
            lstBodyShop[0].BillingCountry = 'France';
            lstBodyShop[0].BillingState = 'Val-d\'Oise';
            insert lstBodyShop;

            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstBodyShop[0].id)
                ,TestFactory.createPlanning(lstBodyShop[0].id)
                ,TestFactory.createPlanning(lstBodyShop[0].id)
                ,TestFactory.createPlanning(lstBodyShop[0].id)
            };

            for(integer i = 0; i <= lstPlanning.size()-1; i++){
                lstPlanning[i].NOB_Status__c = 'Réservé';
                lstPlanning[i].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 16, 00, 0);
                lstPlanning[i].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 17, 00, 0);
            }

            lstPlanning[0].NOB_Status__c = 'Disponible';
            lstPlanning[0].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();

            lstPlanning[1].NOB_Status__c = 'Absence';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();

            lstPlanning[1].NOB_Status__c = 'Réservé';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningHorsNobilas').getRecordTypeId();

            lstPlanning[3].NOB_Status__c = 'Disponible';
            lstPlanning[3].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();
            lstPlanning[3].IsDelete__c = true;

            insert lstPlanning;
        }
    }
    @isTest
    public static void getPlanningsTest(){
        System.runAs(userAdmin){
            Test.startTest();
            List<NOB_Planning__c> lstRs = NOB_LC51_RelatedPlanning.getPlannings(lstBodyShop[0].Id,'Disponible','Planning Prefikar');
            Test.stopTest();

            System.assertEquals(1, lstRs.size());
        }
    }

    @isTest
    public static void getNonDeletedPlannings(){
        System.runAs(userAdmin){
            Test.startTest();
            List<NOB_Planning__c> lstRs = NOB_LC51_RelatedPlanning.getPlannings(lstBodyShop[0].Id,'Disponible','Planning Prefikar');
            Test.stopTest();

            System.assertEquals(1, lstRs.size());
        }
    }

    @isTest
    public static void checkProfileRightsTest(){
        System.runAs(userAdmin){
            Test.startTest();
            Boolean result = NOB_LC51_RelatedPlanning.checkProfileRights();
            Test.stopTest();

            System.assertEquals(true, result);
        }
    }

    @isTest
    public static void getRecordTypeIdTest(){
        System.runAs(userAdmin){
            Test.startTest();
            Id result = NOB_LC51_RelatedPlanning.getRecordTypeId('Planning Prefikar');
            Test.stopTest();

            System.assertEquals(Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId(), result);
        }
    }
}