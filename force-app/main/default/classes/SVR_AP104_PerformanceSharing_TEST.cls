/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   02-19-2021   ARA   Initial Version
**/
@isTest
public with sharing class SVR_AP104_PerformanceSharing_TEST {
    
    static List<User> listUser;
    static List<User> listPortalUser;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static List<SVR_Performance__c> listPerformance;

    static{
        //Create User 'System admin'
        listUser = new List<User>{
            TestFactory.createPrefikarUser('userAdmin'),
            TestFactory.createPrefitoolUser('responsableSecteur'),
            TestFactory.createPrefitoolGestionnaireUser('Gestionnaire'),
            TestFactory.createPrefitoolGestionnaireUser('Gestionnaire2'),
            TestFactory.createPrefitoolUser('responsableSecteur2')
        };
        insert listUser;
        System.runAs(listUser[0]){
            // create Account
            listAccount = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage Prefitool Spoon', 'Réseau Platinium')
            };
            listAccount[0].SVR_AreaManager__c = listUser[1].Id;
            insert listAccount;
            //create contact
            listContact = new List<Contact>{
                TestFactory.createBodyshopContact('Luffy', 'Monkey', listAccount[0].Id)
            };
            insert listContact;
            // create Performance
            listPerformance = new List<SVR_Performance__c>{
                TestFactory.createPerformance(listAccount[0],listUser[2])
            };
            
        }
    }
    @isTest
    public static void onAfterInsertTest(){
        System.runAs(listUser[0]){
            Test.startTest();
            insert listPerformance;
            Test.stopTest();
            List<SVR_Performance__c> lstPreformanceInserted =([SELECT Id,Name,SVR_NomGestionnaire__c FROM SVR_Performance__c]);
            system.debug('taghs'+lstPreformanceInserted[0].SVR_NomGestionnaire__c);
            system.assertEquals(listUser[2].id, lstPreformanceInserted[0].SVR_NomGestionnaire__c);
        }
    }
    @isTest
    public static void onAfterUpdateTest(){
        System.runAs(listUser[0]){
            insert listPerformance;
            Test.startTest();
            listPerformance[0].SVR_NomGestionnaire__c = listUser[3].Id;
            listPerformance[0].SVR_ResponsableSecteur__c = listUser[4].Id;
            update listPerformance[0];
            Test.stopTest();
            List<SVR_Performance__c> lstPreformanceUpdated =([SELECT Id,Name,SVR_NomGestionnaire__c FROM SVR_Performance__c]);
            system.debug('taghs'+lstPreformanceUpdated[0].SVR_NomGestionnaire__c);
            system.assertEquals(listUser[3].Id, lstPreformanceUpdated[0].SVR_NomGestionnaire__c);
        }
    }
}