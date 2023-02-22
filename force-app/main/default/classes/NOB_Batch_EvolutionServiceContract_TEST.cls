/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_Batch_EvolutionServiceContract_TEST
  -- - Author        : HMO
  -- - Description   : Test class for class NOB_Batch_EvolutionServiceContract
  -- - #Ticket       : RSIW : 5686
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 17-01-2022      HMO     1.0     Initial version
  **********************************************************************
*/

@isTest
private with sharing class NOB_Batch_EvolutionServiceContract_TEST {
    private NOB_Batch_EvolutionServiceContract_TEST() {

    }

    static User userAdmin;
    static List<Account> lstReps;
    static List<ServiceContract> lstServiceContracts;
    static List<Account> lstReparmut;
    static List<NOB_AccountRelationship__c> lstRelations;
    static Set<Id> setIdsAcc = new Set<Id>();

    static {
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLotEVOLUTION');
        userAdmin.Username = 'utilisateur@spoonTest.za';
        insert userAdmin;

        System.runAs(userAdmin){

            lstReps = new List<Account>();
            for (Integer i = 0; i < 5; i++){
                lstReps.add(TestFactory.createAccountBodyshop('compteReparateur'+i, 'FR'));
                lstReps.get(i).NOB_isPrefikar__c = true;
                lstReps.get(i).ShippingCity = 'Curepipe';
                lstReps.get(i).ShippingCountry = 'United States';
                lstReps.get(i).ShippingState = 'California';
                lstReps.get(i).ShippingCountryCode = 'US';
                lstReps.get(i).NOB_Statut__c = 'Actif';
                lstReps.get(i).NOB_Ranking__c = 'Gold';
                lstReps.get(i).NOB_TrainingDate__c =  Date.newInstance(2018,05, 20);
                lstReps.get(i).NOB_NetworkType__c = '';
                lstReps.get(i).NOB_SkillSet__c = i < 2 ? '30' : i < 3 ? '100000052' : '';
                lstReps.get(i).NOB_SubscriptionStartDate__c = Date.newInstance(2021, 05, 20);
                lstReps.get(i).NOB_SubscriptionEndDate__c = Date.newInstance(2022, 07, 15);
            }
            insert lstReps;
            for(Account acc: lstReps){
                setIdsAcc.add(acc.Id);
            }
            String rtService = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
            .get('NOB_BodyshopContract').getRecordTypeId();
            lstServiceContracts = new List<ServiceContract>{ 
                new ServiceContract(
                    Name = 'contratProxi', 
                    NOB_ContractsType__c = 'Proximité',
                    //NOB_NumRCSRM__c = 'ABE12345', 
                    AccountId = lstReps[0].Id, 
                    StartDate=Date.newInstance(System.today().year(),System.today().month(), System.today().day()),
                    NOB_endDate__c = Date.newInstance(System.today().year(),System.today().month(), System.today().day()+ 2),
                    NOB_DateDeFormation__c = Date.today()    
                ),
                new ServiceContract(
                    Name = 'contratProxi', 
                    NOB_ContractsType__c = 'Proximité',
                    //NOB_NumRCSRM__c = 'ABE12345', 
                    AccountId = lstReps[0].Id, 
                    StartDate=Date.newInstance(System.today().year(),System.today().month(), System.today().day()),
                    NOB_endDate__c = Date.newInstance(System.today().year(),System.today().month(), System.today().day()),
                    NOB_DateDeFormation__c = Date.today()    
                )
            };

            lstReparmut = new List<Account>();
            lstReparmut.add(TestFactory.createInsurerAccount('AREAS', 'AREAS'));
            lstReparmut.add(TestFactory.createInsurerAccount('MACSF', 'MACSF'));
            lstReparmut.add(TestFactory.createInsurerAccount('LIBEA', 'LIBEA'));
            lstReparmut.add(TestFactory.createInsurerAccount('MFA', 'MFA'));
            lstReparmut.add(TestFactory.createInsurerAccount('MUTUELLE DE POITIERS', 'MAF'));
            lstReparmut.add(TestFactory.createInsurerAccount('SWISSLIFE', 'SWISSLIFE'));

            lstReparmut[0].NOB_ClientId__c ='FR000003';
            lstReparmut[0].NOB_Statut__c = 'Actif';

            lstReparmut[1].NOB_ClientId__c ='FR000020';
            lstReparmut[1].NOB_Statut__c = 'Actif';

            lstReparmut[2].NOB_ClientId__c = 'FR110257';
            lstReparmut[2].NOB_Statut__c = 'Actif';

            lstReparmut[3].NOB_ClientId__c = 'FR000022';
            lstReparmut[3].NOB_Statut__c = 'Actif';

            lstReparmut[4].NOB_ClientId__c = 'FR000024';
            lstReparmut[4].NOB_Statut__c = 'Actif';

            lstReparmut[5].NOB_ClientId__c = 'FR000030';
            lstReparmut[5].NOB_Statut__c = 'Actif';

            insert lstReparmut;

            lstRelations = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstReps[0].Id, lstReparmut[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReps[0].Id,  lstReparmut[1].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReps[0].Id,  lstReparmut[2].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReps[0].Id,  lstReparmut[3].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReps[0].Id,  lstReparmut[4].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReps[0].Id,  lstReparmut[5].Id, 'Réparateur - Assureur')
            };

            lstRelations[0].PFR_inactive__c = false;
            lstRelations[1].PFR_inactive__c = false;
            lstRelations[2].PFR_inactive__c = false;
            lstRelations[3].PFR_inactive__c = false;
            lstRelations[4].PFR_inactive__c = false;
            lstRelations[5].PFR_inactive__c = false;
            insert lstRelations;

        }
    }

    @isTest
    private static void constructorCheck(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            insert lstServiceContracts;
            NOB_Batch_EvolutionServiceContract bat = new NOB_Batch_EvolutionServiceContract();
            Database.executeBatch(bat);
        Test.stopTest();
    }

    @isTest
    private static void checkFirstTime(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Privilège';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Premium';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }


    /**
     * sc type = 'privilege'
     * acc type = privilege
     */
    @isTest
    private static void firstContractSameType1(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Privilège';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Premium';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

     /**
     * sc type = 'proxi'
     * acc type = proxi
     */
    @isTest
    private static void firstContractSameType2(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Proximité';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Proximité';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

    /**
     * sc type = 'privilege'
     * acc type = 
     */
    @isTest
    private static void firstContractNoType(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Privilège';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = '';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }


    /**
     * sc type = 'privilege'
     * acc type = proxi
     */
    @isTest
    private static void contractDifferent1(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Privilège';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Proximité';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

     /**
     * sc type = 'proxi'
     * acc type = privilege
     */
    @isTest
    private static void contractDifferent2(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Proximité';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Premium';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

     /**
     * sc type = 'partinum'
     * acc type = privilege
     */
    @isTest
    private static void contractDifferent3(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Partinium';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Premium';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

     /**
     * sc type = 'partinum'
     * acc type = proxi
     */
    @isTest
    private static void contractDifferent4(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Partinium';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Proximité';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

    /**
     * sc type = 'proxi'
     * acc type = partinium
     */
    @isTest
    private static void contractDifferent5(){
        Test.startTest();
            NOB_AP61_UpdateRankingQuarter.testDate = Date.today();
            lstServiceContracts.get(0).NOB_ContractsType__c = 'Proximité';
            insert lstServiceContracts;
            lstReps.get(0).NOB_NetworkType__c = 'Réseau Platinium';
            update lstReps;
            Database.executeBatch(new NOB_Batch_EvolutionServiceContract());
        Test.stopTest();
    }

}