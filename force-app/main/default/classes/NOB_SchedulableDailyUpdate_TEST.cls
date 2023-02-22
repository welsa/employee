/**
 * @description       : Test class for 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 08-10-2021
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-10-2021   GBH   Initial Version
**/
@isTest
public with sharing class NOB_SchedulableDailyUpdate_TEST {
    
    static User userAdmin;
    static List<Account> lstAcc;
    static List<ServiceContract> lstServiceContracts;


    static{
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;

        System.runAs(userAdmin){

            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US')
            };
            lstAcc[0].NOB_isPrefikar__c = true;
            lstAcc[0].ShippingCity = 'Curepipe';
            lstAcc[0].ShippingCountry = 'United States';
            lstAcc[0].ShippingState = 'California';
            lstAcc[0].ShippingCountryCode = 'US';
            lstAcc[0].NOB_Statut__c = 'Actif';
            insert lstAcc;


            lstServiceContracts = new List <ServiceContract> {
                Testfactory.createServCon(lstAcc[0].id, 'scTestActive', 'Proximité', 'ABE1234', Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()), Date.newInstance(System.today().year(), System.today().month()-1, System.today().day()))
            };
            //HMO -- 25-01-2022
            lstServiceContracts[0].NOB_DateDeFormation__c =  Date.newInstance(2020, System.today().month()-2, System.today().day());
            insert lstServiceContracts;
        }
    }

    @isTest
    public static void executeTEST(){
        
        System.runAs(userAdmin){
            Test.startTest();
            List<ServiceContract> lstBefore = new List<ServiceContract>([select id, status, NOB_TECH_ExtractByETL__c, NOB_DateDeFormation__c, StartDate from servicecontract]);
			System.debug('### executeTest.lstBefore ' + lstBefore);
            NOB_SchedulableDailyUpdateLastModified s = new NOB_SchedulableDailyUpdateLastModified();
            s.execute(null);

            Test.stopTest();
            List<ServiceContract> lstAfter = new List<ServiceContract>([select id, status, NOB_TECH_ExtractByETL__c from servicecontract]);
            System.assertEquals(true, lstAfter[0].NOB_TECH_ExtractByETL__c);
            System.assertEquals(false, lstBefore[0].NOB_TECH_ExtractByETL__c);
        }
        
    }
}