/*************************************************************************************
Class Name - NOB_Batch_UpdateMissionsSC_TEST
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 09-09-2021
Function - Class  NOB_Batch_UpdateMissionsServiceContrat testClass
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           09/09/2021   Initial version
*************************************************************************************/
@isTest
public class NOB_Batch_UpdateMissionsSC_TEST {
    static User userAdmin;
    static List<ServiceContract> lstServiceContracts;
    static List<NOB_Planning__c> lstPlannings;
    static List<Case> lstCases;
    static Pricebook2 pricebook;
    static NOB_AccountPricebook__c catalogueCompte;
    static List<WorkOrder> lstWorkOrder;
    static List<Account> lstReparateurs;
    static account compteAssureur;
    static contact contactAssureur;
    static List<Account> gesReseaureparateur;

    static{
        userAdmin = TestFactory.createPrefikarUser('BatchMissionUser');
        userAdmin.Username = 'utilisateur@spoonTest.za';
        insert userAdmin;

        System.runAs(userAdmin){
          
			//HMO -- 25-09-2021

			lstReparateurs = new List<Account>();
			lstReparateurs.add(TestFactory.createPrefikarBodyAccount('ReparateurSPOON ', 'Réseau Premium'));
			lstReparateurs[0].ContactEmail__c = 'spoonltdzzz@gmail.com';
			lstReparateurs[0].VATNumber__c = 'vat12349';
			lstReparateurs[0].ReferenceNumber__c = 'FR0000888888';
			lstReparateurs[0].ASEntity__c = 'ASFR1';
			lstReparateurs[0].ExpertSubstitutionMethod__c='FORCED';
            lstReparateurs[0].NOB_Ranking__c = NOB_AP00_Constants.ACCOUNT_RANKING_GOLD;
			insert lstReparateurs;

            compteAssureur = new Account();
            compteAssureur = TestFactory.createInsurerAccount('accAssureur','Nord');
            compteAssureur.Nob_CTICampaignNumber__c = 'Test';
			compteAssureur.ReferenceNumber__c = 'FR0121237264';
			compteAssureur.Phone = '0123456789';
            insert compteAssureur;

            //create Gestionnaire de réseau de réparateur
            gesReseaureparateur = new List<Account>{
            TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
            };
            gesReseaureparateur[0].ReferenceNumber__c = 'FR0121456789';
            insert gesReseaureparateur;

            lstPlannings = new List<NOB_Planning__c>();
            for (integer i = 0; i < 5; i++){
                lstPlannings.add(TestFactory.createPlanning(lstReparateurs[0].Id));
            }
            lstPlannings[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 9, 30, 0);
            lstPlannings[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 10, 30, 0);

            lstPlannings[1].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+2, 9, 30, 0);
            lstPlannings[1].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+2, 10, 30, 0);

            lstPlannings[2].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 9, 30, 0);
            lstPlannings[2].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 10, 30, 0);

            lstPlannings[3].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month()+2, System.today().day()+1, 9, 30, 0);
            lstPlannings[3].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month()+2, System.today().day()+1, 10, 30, 0);

            lstPlannings[4].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month() + 2, System.today().day()+2, 9, 30, 0);
            lstPlannings[4].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month() + 2, System.today().day()+2, 10, 30, 0);
            insert lstPlannings;

            pricebook = new Pricebook2(Name='DR',NOB_Offer__c=NOB_AP00_Constants.PRICEBOOK_OFFRE_DR,IsActive=true);
            insert pricebook;
            
            catalogueCompte = new NOB_AccountPricebook__c(Name='Offre DR',NOB_Account__c = compteAssureur.Id,NOB_Pricebook__c=pricebook.Id); 
            insert catalogueCompte;

            contactAssureur = TestFactory.createInsuredContact('contact', 'Assuree', compteAssureur.Id,'Nord');
            contactAssureur.Email = 'assureur@test.au';
            insert contactAssureur;

            lstCases = new List<Case>();
            lstCases.add(TestFactory.createCaseStandard('Facturation', contactAssureur.Id, compteAssureur.Id, 'KIA', 'Eltrix','12345asd','test1', Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));

            lstCases.add(TestFactory.createCaseStandard('Facturation', contactAssureur.Id, compteAssureur.Id, 'BMW', 'X6','128765sdd','test2',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR16534','Body','Réparation'));

            lstCases[0].NOB_Pricebook__c=catalogueCompte.Id;
            lstCases[0].NOB_ContactPickup__c= contactAssureur.Id;
            lstCases[0].NOB_BodyShop__c = lstReparateurs[0].Id;

            lstCases[1].NOB_Pricebook__c=catalogueCompte.Id;
            lstCases[1].NOB_ContactPickup__c= contactAssureur.id;
            lstCases[1].NOB_BodyShop__c = lstReparateurs[0].Id;

            insert lstCases;

            
            lstWorkOrder = new List<WorkOrder>();
            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));

            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[1].Id));


            for (integer i = 0; i < lstWorkOrder.size(); i++){
                lstWorkOrder[i].recordTypeId = recordTypeWo;
                lstWorkOrder[i].PFR_ExcludeFG__c = false;
                lstWorkOrder[i].NOB_BusinessProvider__c = compteAssureur.Id;
                lstWorkOrder[i].PFR_TECH_Planning_StartDate__c = null;
                lstWorkOrder[i].PFR_TECH_Planning_EndDate__c = null;
            }
            insert lstWorkOrder;

            lstServiceContracts = new List<ServiceContract>();
			Id recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByName().get('Contrat Réparateur').getRecordTypeId();
		
			for (integer i = 0; i < 20; i++){
				lstServiceContracts.add(new ServiceContract(
					AccountId = lstReparateurs[0].Id,
					startDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
					endDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+100),
					recordTypeId = recordTypeId,
					Name = 'spoonSC '+ i,
                    NOB_DateDeFormation__c = Date.today(),
                    NOB_MissionsEnvoyeeReparateurQ1N1__c = null,
                    NOB_MissionsEnvoyeeReparateurQ1__c = 5,
                    NOB_MissionsEnvoyeeReparateurQ2N1__c = null, 
                    NOB_MissionsEnvoyeeReparateurQ2__c = 5,
                    NOB_MissionsEnvoyeeReparateurQ3N1__c = null, 
                    NOB_MissionsEnvoyeeReparateurQ3__c = 5,
                    NOB_MissionsEnvoyeeReparateurQ4N1__c = null, 
                    NOB_MissionsEnvoyeeReparateurQ4__c = 5,
        
                    NOB_MissionsEnvoyeeReparateurQ1N1Globale__c = null,
                    NOB_MissionsEnvoyeeReparateurQ1Globale__c = 10,
                    NOB_MissionsEnvoyeeReparateurQ2N1Globale__c =null, 
                    NOB_MissionsEnvoyeeReparateurQ2Globale__c = 10,
                    NOB_MissionsEnvoyeeReparateurQ3N1Globale__c = null,
                    NOB_MissionsEnvoyeeReparateurQ3Globale__c = 10,
                    NOB_MissionsEnvoyeeReparateurQ4N1Globale__c = null, 
                    NOB_MissionsEnvoyeeReparateurQ4Globale__c = 10
				    )
                );
			}

            NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            insert lstServiceContracts;
        }
        
    }

    @isTest
    public static void runBatchHQ3(){
        Test.startTest();
        NOB_Batch_UpdateMissionsServiceContrat.testDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            Database.executeBatch(new NOB_Batch_UpdateMissionsServiceContrat(true));
        Test.stopTest();

        for(ServiceContract sc : [select Id, NOB_MissionsEnvoyeeReparateurQ1N1__c,NOB_MissionsEnvoyeeReparateurQ2N1__c,NOB_MissionsEnvoyeeReparateurQ3N1__c,NOB_MissionsEnvoyeeReparateurQ4N1__c,NOB_MissionsEnvoyeeReparateurQ1N1Globale__c,
        NOB_MissionsEnvoyeeReparateurQ2N1Globale__c,NOB_MissionsEnvoyeeReparateurQ3N1Globale__c,NOB_MissionsEnvoyeeReparateurQ4N1Globale__c from ServiceContract WHERE Id IN: lstServiceContracts]){
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1Globale__c, 10);
        }
    }

    @isTest
    public static void runBatchHQ2(){
        Test.startTest();
        NOB_Batch_UpdateMissionsServiceContrat.testDate = Date.newInstance(System.today().year(), System.today().month()-2, System.today().day());
            Database.executeBatch(new NOB_Batch_UpdateMissionsServiceContrat(true));
        Test.stopTest();

        for(ServiceContract sc : [select Id, NOB_MissionsEnvoyeeReparateurQ1N1__c,NOB_MissionsEnvoyeeReparateurQ2N1__c,NOB_MissionsEnvoyeeReparateurQ3N1__c,NOB_MissionsEnvoyeeReparateurQ4N1__c,NOB_MissionsEnvoyeeReparateurQ1N1Globale__c,
        NOB_MissionsEnvoyeeReparateurQ2N1Globale__c,NOB_MissionsEnvoyeeReparateurQ3N1Globale__c,NOB_MissionsEnvoyeeReparateurQ4N1Globale__c from ServiceContract WHERE Id IN: lstServiceContracts]){
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1Globale__c, 10);
        }
    }

    @isTest
    public static void runBatchHQ1(){
        Test.startTest();
        NOB_Batch_UpdateMissionsServiceContrat.testDate = Date.newInstance(System.today().year(), System.today().month()-7, System.today().day());
            Database.executeBatch(new NOB_Batch_UpdateMissionsServiceContrat(true));
        Test.stopTest();

        for(ServiceContract sc : [select Id, NOB_MissionsEnvoyeeReparateurQ1N1__c,NOB_MissionsEnvoyeeReparateurQ2N1__c,NOB_MissionsEnvoyeeReparateurQ3N1__c,NOB_MissionsEnvoyeeReparateurQ4N1__c,NOB_MissionsEnvoyeeReparateurQ1N1Globale__c,
        NOB_MissionsEnvoyeeReparateurQ2N1Globale__c,NOB_MissionsEnvoyeeReparateurQ3N1Globale__c,NOB_MissionsEnvoyeeReparateurQ4N1Globale__c from ServiceContract WHERE Id IN: lstServiceContracts]){
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1Globale__c, 10);
        }
    }

    @isTest
    public static void runBatchHQ4(){
        Test.startTest();
        NOB_Batch_UpdateMissionsServiceContrat.testDate = Date.newInstance(System.today().year(), System.today().month()+2, System.today().day());
            Database.executeBatch(new NOB_Batch_UpdateMissionsServiceContrat(true));
        Test.stopTest();

        for(ServiceContract sc : [select Id, NOB_MissionsEnvoyeeReparateurQ1N1__c,NOB_MissionsEnvoyeeReparateurQ2N1__c,NOB_MissionsEnvoyeeReparateurQ3N1__c,NOB_MissionsEnvoyeeReparateurQ4N1__c,NOB_MissionsEnvoyeeReparateurQ1N1Globale__c,
        NOB_MissionsEnvoyeeReparateurQ2N1Globale__c,NOB_MissionsEnvoyeeReparateurQ3N1Globale__c,NOB_MissionsEnvoyeeReparateurQ4N1Globale__c from ServiceContract WHERE Id IN: lstServiceContracts]){
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1__c, 5);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3N1Globale__c, 10);
            System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4N1Globale__c, 10);
        }
    }

    // @isTest
    // public static void runBatchPresentQuarter(){
    //     // lstCases[0].NOB_DamageType__c = 'testCase';
    //     // update lstCases;

    //     Test.startTest();
    //     NOB_Batch_UpdateMissionsServiceContrat.testDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
    //         Database.executeBatch(new NOB_Batch_UpdateMissionsServiceContrat(true));
    //     Test.stopTest();

    //     for(ServiceContract sc : [select Id, NOB_MissionsEnvoyeeReparateurQ1__c,NOB_MissionsEnvoyeeReparateurQ2__c,NOB_MissionsEnvoyeeReparateurQ3__c,NOB_MissionsEnvoyeeReparateurQ4__c,NOB_MissionsEnvoyeeReparateurQ1Globale__c,
    //     NOB_MissionsEnvoyeeReparateurQ2Globale__c,NOB_MissionsEnvoyeeReparateurQ3Globale__c,NOB_MissionsEnvoyeeReparateurQ4Globale__c from ServiceContract WHERE Id IN: lstServiceContracts]){
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1__c, 5);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2__c, 5);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3__c, 3);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4__c, 5);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ1Globale__c, 10);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ2Globale__c, 10);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ3Globale__c, 6);
    //         System.assertEquals(sc.NOB_MissionsEnvoyeeReparateurQ4Globale__c, 10);
    //     }
    // }
}