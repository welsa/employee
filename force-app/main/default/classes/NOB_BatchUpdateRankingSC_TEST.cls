/*************************************************************************************
Class Name - NOB_Batch_UpdateRankingSC_TEST
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 26-09-2021
Function - Class  NOB_Batch_UpdateRankingServiceContracts testClass
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           26/09/2021   Initial version
*************************************************************************************/

@isTest
public without sharing class NOB_BatchUpdateRankingSC_TEST {
    public NOB_BatchUpdateRankingSC_TEST() {

    }

    static User userAdmin;
    static List<Account> lstReparateurs;
    static List<ServiceContract> lstServiceContracts;

    static{
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('userBatchRanking');
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

            lstServiceContracts = new List<ServiceContract>();
			Id recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByName().get('Contrat Réparateur').getRecordTypeId();
		
			for (integer i = 0; i < 50; i++){
				lstServiceContracts.add(new ServiceContract(
					AccountId = lstReparateurs[0].Id,
					startDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
					endDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+100),
					recordTypeId = recordTypeId,
					NOB_DateDeFormation__c = Date.today(),
					Name = 'spoonSC '+ i,
					NOB_RankingRep_Q1__c = 'Bronze', 
					NOB_RankingRep_Q2__c= 'Bronze', 
					NOB_RankingRep_Q3__c = 'Bronze', 
					NOB_TechToProcess__c = false, 
					NOB_RankingRep_Q4N1__c = null,
                    NOB_RankingRep_Q1N1__c = null,
                    NOB_RankingRep_Q2N1__c = null,
                    NOB_RankingRep_Q3N1__c = null
				    )
                );
			}
        }

    }

    //HMO -- 25-09-2021
	/*@isTest
	public static void testClearRanking(){
		Test.startTest();
			NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 04, 12);
			insert lstServiceContracts;	


            //f- majH t - clearR
            Database.executeBatch(new NOB_Batch_UpdateRankingServiceContracts(false, true));
		Test.stopTest();

		for(ServiceContract sc : [SELECT NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_TechToProcess__c, NOB_RankingRep_Q4N1__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_ContexteEngagement__c from ServiceContract where Id IN: lstServiceContracts]){

            System.assertEquals(sc.NOB_RankingRep_Q1__c, null);
            System.assertEquals(sc.NOB_RankingRep_Q2__c, null);
            System.assertEquals(sc.NOB_RankingRep_Q3__c, null);
		}
	}*/

        //HMO -- 25-09-2021
	@isTest
	public static void testOnUpdate1stQuarter(){
		Test.startTest();
			NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 04, 12);
			insert lstServiceContracts;	

            //f- majH t - clearR
            Database.executeBatch(new NOB_Batch_UpdateRankingServiceContracts(true, false));
		Test.stopTest();

		for(ServiceContract sc : [SELECT NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_TechToProcess__c, NOB_RankingRep_Q4N1__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_ContexteEngagement__c from ServiceContract where Id IN: lstServiceContracts]){

            System.assertEquals(sc.NOB_RankingRep_Q1__c, lstReparateurs[0].NOB_Ranking__c);
		}
	}

	//HMO -- 25-09-2021
	@isTest
	public static void testOnUpdate2ndQuarterH(){
		Test.startTest();
			NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 08, 12);
			insert lstServiceContracts;
            
            Database.executeBatch(new NOB_Batch_UpdateRankingServiceContracts(true, false));
		Test.stopTest();

		for(ServiceContract sc : [SELECT NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_TechToProcess__c, NOB_RankingRep_Q4N1__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_ContexteEngagement__c from ServiceContract where Id IN: lstServiceContracts]){

			System.assertEquals(sc.NOB_RankingRep_Q2N1__c, sc.NOB_RankingRep_Q2__c);

		}
	}

	//HMO -- 25-09-2021
	@isTest
	public static void testOnUpdate3rdQuarter(){
		Test.startTest();
			NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 12, 12);
			insert lstServiceContracts;

            Database.executeBatch(new NOB_Batch_UpdateRankingServiceContracts(true, false));
		Test.stopTest();

		for(ServiceContract sc : [SELECT NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_TechToProcess__c, NOB_RankingRep_Q4N1__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_ContexteEngagement__c from ServiceContract where Id IN: lstServiceContracts]){
	
			System.assertEquals(sc.NOB_RankingRep_Q3N1__c, sc.NOB_RankingRep_Q3__c);

		}
	}

	//HMO -- 25-09-2021
	@isTest
	public static void testOnQ4N1Quarter(){
		Test.startTest();
			NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 02, 12);
			insert lstServiceContracts;
            Database.executeBatch(new NOB_Batch_UpdateRankingServiceContracts(true, false));
		Test.stopTest();

		for(ServiceContract sc : [SELECT NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_TechToProcess__c, NOB_RankingRep_Q4N1__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_ContexteEngagement__c from ServiceContract where Id IN: lstServiceContracts]){
			System.assertEquals(sc.NOB_RankingRep_Q4N1__c, lstReparateurs[0].NOB_Ranking__c);
		}
	}
}