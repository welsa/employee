/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 01-27-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-18-2021   ARA   Initial Version
**/
@isTest
public with sharing class NOB_AP59_TauxEngagementPourcentCal_TEST {
    static User userAdmin;
    static list<Account> lstBodyShop;
    static list<NOB_Planning__c> lstPlanning;
    static list<ServiceContract> lstServiceContracts;

    static{
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){
            //create bodyshop
            lstBodyShop = new List<Account>{
                TestFactory.createPrefikarBodyAccount('bs1', '','',''),
                TestFactory.createPrefikarBodyAccount('bs2', '','',''),
                TestFactory.createPrefikarBodyAccount('bs3', '','','')
                  
            };

            lstBodyShop[0].NOB_Ranking__c = 'Gold';
            lstBodyShop[1].NOB_Ranking__c = 'Silver';
            lstBodyShop[2].NOB_Ranking__c = 'Bronze';

            lstBodyShop[0].NOB_SiretHeadquarters__c ='Test';
            lstBodyShop[1].NOB_SiretHeadquarters__c ='Test1';
            lstBodyShop[2].NOB_SiretHeadquarters__c ='Test2';

            lstBodyShop[2].BillingCity = 'Paris';
            lstBodyShop[2].BillingCountry = 'France';
            lstBodyShop[2].BillingStreet = 'Chemin endans';
            lstBodyShop[2].BillingPostalCode = '3070';
            lstBodyShop[1].BillingCity = 'Paris';
            lstBodyShop[1].BillingCountry = 'France';
            lstBodyShop[1].BillingStreet = 'Chemin endans';
            lstBodyShop[1].BillingPostalCode = '3070';
            lstBodyShop[0].BillingCity = 'Paris';
            lstBodyShop[0].BillingCountry = 'France';
            lstBodyShop[0].BillingStreet = 'Chemin endans';
            lstBodyShop[0].BillingPostalCode = '3070';
            insert lstBodyShop;
            //create planning
            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstBodyShop[0].id),
                TestFactory.createPlanning(lstBodyShop[1].id),
                TestFactory.createPlanning(lstBodyShop[2].id),
                TestFactory.createPlanning(lstBodyShop[1].id)
            };

            for(integer i = 0; i <= 2; i++){
                lstPlanning[i].NOB_Status__c = 'Disponible';
                lstPlanning[i].IsDelete__c = false;
                lstPlanning[i].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 16, 00, 0);
                lstPlanning[i].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 17, 00, 0);
            }
            
            //create Service Contracts
            lstServiceContracts = new List<ServiceContract>{
                new ServiceContract(Name = 'contrat 1', AccountId=lstBodyShop[0].id,
                                   StartDate=Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month() +12, 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.today(),
                                   NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 7,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0,NOB_NombreMissionAnnuel__c =500),
                new ServiceContract(Name = 'contrat 2', AccountId=lstBodyShop[1].id,
                                   StartDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month()+12, 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.today(),
                                   NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 10,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0),
                new ServiceContract(Name = 'contrat 3', AccountId=lstBodyShop[2].id,
                                   StartDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.today(),
                                   NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 20,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0)
            };
            insert lstServiceContracts;

        }
    }
    @isTest
    public static void updateMissionReserveTest(){
        System.runAs(userAdmin){
            Test.startTest();
            lstPlanning[0].NOB_Status__c = 'Réservé';
            insert lstPlanning;
            Test.stopTest();
        List<NOB_Planning__c> lstPlanInserted = [SELECT Id,NOB_Status__c FROM NOB_Planning__c WHERE Id =: lstPlanning];
        string result = lstPlanInserted[0].NOB_Status__c;

        //Assertion
        System.assertEquals('Réservé', result);
        }
    }
}