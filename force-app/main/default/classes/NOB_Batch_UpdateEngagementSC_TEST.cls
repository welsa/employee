/*************************************************************************************
Class Name - NOB_Batch_UpdateEngagementSC_TEST
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 27-07-2021
Function - Class  NOB_Batch_UpdateEngagementServiceContract testClass
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           27/07/2021   Initial version
*************************************************************************************/
@isTest
public without sharing class NOB_Batch_UpdateEngagementSC_TEST {
    public NOB_Batch_UpdateEngagementSC_TEST() {

    }

    static User userAdmin;
    static List<Account> lstAcc;
    static List<ServiceContract> lstServiceContracts;

    static{
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLotEngagement');
        userAdmin.Username = 'utilisateur@spoonTest.za';
        insert userAdmin;

        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US')
            };
            lstAcc.get(0).NOB_isPrefikar__c = true;
            lstAcc.get(0).ShippingCity = 'Curepipe';
            lstAcc.get(0).ShippingCountry = 'United States';
            lstAcc.get(0).ShippingState = 'California';
            lstAcc.get(0).ShippingCountryCode = 'US';
            lstAcc.get(0).NOB_Statut__c = 'Actif';
            lstAcc.get(0).NOB_Ranking__c = 'Gold';
            lstAcc.get(0).NOB_TrainingDate__c =  Date.newInstance(2018,05, 20);
            lstAcc.get(0).NOB_isPrefikar__c = true;
            insert lstAcc;


            String recordTypeIdz = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
            .get('NOB_BodyshopContract').getRecordTypeId();

            lstServiceContracts = new List<ServiceContract>{
                new ServiceContract(Name = 'contratVivea', NOB_ContractsType__c = 'Proximité',/* NOB_NumRCSRM__c = 'ABE12345',*/ AccountId = lstAcc[0].Id, StartDate=Date.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day()),
                EndDate= Date.newInstance(System.today().year(),
                System.today().month() +12, 
                System.today().day()),
                NOB_DateDeFormation__c = Date.today(),
                NOB_NombreMissionAnnuel__c = 600,

                NOB_EngagementQ1__c = 56,
                NOB_EngagementQ1N1__c = null,
                NOB_EngagementQ2__c = 56,
                NOB_EngagementQ2N1__c = null,
                NOB_EngagementQ3__c = 56,
                NOB_EngagementQ3N1__c = null,
                NOB_EngagementQ4__c = 56,
                NOB_EngagementQ4N1__c = null,
                NOB_TechToProcess__c = true,
                recordTypeId = recordTypeIdz
                ),

                new ServiceContract(Name = 'contratENL', NOB_ContractsType__c = 'Proximité',/* NOB_NumRCSRM__c = 'ABE12345',*/ AccountId = lstAcc[0].Id, StartDate=Date.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day()),
                NOB_DateDeFormation__c = Date.today(),
                EndDate= Date.newInstance(System.today().year(),
                System.today().month() +12, 
                System.today().day()),
                NOB_NombreMissionAnnuel__c = 600,

                NOB_EngagementQ1__c = 200,
                NOB_EngagementQ1N1__c = null,
                NOB_EngagementQ2__c = 400,
                NOB_EngagementQ2N1__c = null,
                NOB_EngagementQ3__c = 100,
                NOB_EngagementQ3N1__c = null,
                NOB_EngagementQ4__c = 50,
                NOB_EngagementQ4N1__c = null,
                recordTypeId = recordTypeIdz
                )
            };
        }
        
    }

    @IsTest
    public static void testQuarterEqualsJan(){

        //NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2022, 01, 01);
        NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year()+1, 01, 01);
        insert lstServiceContracts;

        Test.startTest();
            //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2022, 01, 01);
            NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year()+1, 01, 01);
            Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(false, false));
        Test.stopTest();

        List<ServiceContract> lstResult = [SELECT  NOB_EngagementQ1__c,
                                        NOB_EngagementQ1N1__c ,
                                        NOB_EngagementQ2__c,
                                        NOB_EngagementQ2N1__c,
                                        NOB_EngagementQ3__c,
                                        NOB_EngagementQ3N1__c,
                                        NOB_EngagementQ4__c,
                                        NOB_EngagementQ4N1__c,
                                        NOB_TechToProcess__c,
                                        toLabel(NOB_ContexteEngagement__c)
                                        FROM ServiceContract WHERE Id IN :lstServiceContracts];

       System.assertEquals(150, lstResult.get(0).NOB_EngagementQ1__c);
       System.assertEquals(null, lstResult.get(0).NOB_EngagementQ1N1__c);
       System.assertEquals(150, lstResult.get(0).NOB_EngagementQ2__c);
       System.assertEquals(null, lstResult.get(0).NOB_EngagementQ2N1__c);
       System.assertEquals(150, lstResult.get(0).NOB_EngagementQ3__c);
       System.assertEquals(null, lstResult.get(0).NOB_EngagementQ3N1__c);
       System.assertEquals(150, lstResult.get(0).NOB_EngagementQ4__c);
       System.assertEquals(null, lstResult.get(0).NOB_EngagementQ4N1__c);
       System.assertEquals(false, lstResult.get(0).NOB_TechToProcess__c);
       System.assertEquals('Creation', lstResult.get(0).NOB_ContexteEngagement__c);
    }

    // @IsTest
    // public static void testToProcess(){
    //     Test.startTest();
    //         lstServiceContracts[0].NOB_NombreMissionAnnuel__c = 1000;
    //         update lstServiceContracts;
    //         NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2021, 04, 04);
    //         Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(true, true));
    //     Test.stopTest();

    //     List<ServiceContract> lstResult = [SELECT  NOB_EngagementQ1__c,
    //                                     NOB_EngagementQ1N1__c ,
    //                                     NOB_EngagementQ2__c,
    //                                     NOB_EngagementQ2N1__c,
    //                                     NOB_EngagementQ3__c,
    //                                     NOB_EngagementQ3N1__c,
    //                                     NOB_EngagementQ4__c,
    //                                     NOB_EngagementQ4N1__c
    //                                     FROM ServiceContract WHERE Id IN :lstServiceContracts];

    //    System.assertEquals(150, lstResult.get(0).NOB_EngagementQ1__c);
    //    System.assertEquals(56, lstResult.get(0).NOB_EngagementQ1N1__c);
    //    System.assertEquals(150, lstResult.get(0).NOB_EngagementQ2__c);
    //    System.assertEquals(56, lstResult.get(0).NOB_EngagementQ2N1__c);
    //    System.assertEquals(150, lstResult.get(0).NOB_EngagementQ3__c);
    //    System.assertEquals(56, lstResult.get(0).NOB_EngagementQ3N1__c);
    //    System.assertEquals(150, lstResult.get(0).NOB_EngagementQ4__c);
    //    System.assertEquals(56, lstResult.get(0).NOB_EngagementQ4N1__c);
    //    System.assertEquals(false, lstResult.get(0).NOB_TechToProcess__c);
    // }

    @IsTest
    public static void testRankingChanged(){

       // NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2022, 01, 01);
       NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year(), 01, 01);
        insert lstServiceContracts;

        Test.startTest();

            //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2022, 01, 01);
            NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year(), 01, 01);
            Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(false, true)); 

        Test.stopTest();

        
        lstAcc[0].NOB_Ranking__c = 'Silver';
        update lstAcc;

        List<ServiceContract> lstResult = [SELECT NOB_TechToProcess__c, toLabel(NOB_ContexteEngagement__c) FROM ServiceContract WHERE Id IN :lstServiceContracts];
        System.assertEquals(true, lstResult.get(0).NOB_TechToProcess__c);
        System.assertEquals('Ranking', lstResult.get(0).NOB_ContexteEngagement__c);

    }

    @IsTest
    public static void testEngagementGoldChanged(){

        //NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2022, 01, 01);
        NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year(), 01, 01);
        insert lstServiceContracts;
        
        Test.startTest();
        //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2022, 01, 01);
        NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year(), 01, 01);
        Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(false, false));

        Test.stopTest();
        
              
        lstServiceContracts[0].NOB_NombreMissionAnnuel__c = 250;
        update lstServiceContracts;

        List<ServiceContract> lstResult = [SELECT NOB_TechToProcess__c,NOB_ContexteEngagement__c  FROM ServiceContract WHERE Id IN :lstServiceContracts];
        System.assertEquals(true, lstResult.get(0).NOB_TechToProcess__c);
        //System.assertEquals('EG', lstResult.get(0).NOB_ContexteEngagement__c);
    }

    @IsTest
    public static void testDFChanged(){

        //NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2022, 01, 01);
        NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year(), 01, 01);
        insert lstServiceContracts;

        Test.startTest();
        //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2022, 01, 01);
        NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year(), 01, 01);
            Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(false, false));


        Test.stopTest();
        
        
        lstAcc[0].NOB_TrainingDate__c = Date.newInstance(2021, 05, 05);
        update lstAcc;

        List<ServiceContract> lstResult = [SELECT NOB_TechToProcess__c, NOB_ContexteEngagement__c FROM ServiceContract WHERE Id IN :lstServiceContracts];
        System.assertEquals(true, lstResult.get(0).NOB_TechToProcess__c);
        System.assertEquals('DF', lstResult.get(0).NOB_ContexteEngagement__c);
    }


    //Rannking is changed
    @IsTest
    public static void test1stQuarterRk(){

        NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year(), 03, 14); //HRM
        lstServiceContracts[0].NOB_NombreMissionAnnuel__c = 250;
        insert lstServiceContracts;

        lstAcc[0].NOB_TrainingDate__c = Date.newInstance(System.today().year(), 01, 05); //HRM
        update lstAcc;




        Test.startTest();
        NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year(), 03, 14); //HRM
        Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(true, true));
        Test.stopTest();

          
        List<ServiceContract> lstResult = [SELECT  NOB_EngagementQ1__c,
        NOB_EngagementQ1N1__c ,
        NOB_EngagementQ2__c,
        NOB_EngagementQ2N1__c,
        NOB_EngagementQ3__c,
        NOB_EngagementQ3N1__c,
        NOB_EngagementQ4__c,
        NOB_EngagementQ4N1__c,
        NOB_ContexteEngagement__c,
        NOB_TechToProcess__c
        FROM ServiceContract WHERE Id =: lstServiceContracts.get(0).Id];

        System.debug('££££ service contract retrieved'+ lstServiceContracts);

        System.assertEquals(58, lstResult.get(0).NOB_EngagementQ1__c);
   
        System.assertEquals(62, lstResult.get(0).NOB_EngagementQ2__c);
       
        System.assertEquals(62, lstResult.get(0).NOB_EngagementQ3__c);
       
        System.assertEquals(62, lstResult.get(0).NOB_EngagementQ4__c);
        System.assertEquals(false, lstResult.get(0).NOB_TechToProcess__c);
        System.assertEquals('DF', lstResult.get(0).NOB_ContexteEngagement__c);
    }
    
    //Rannking is changed
    @IsTest
    public static void test2ndQuarterCR(){

        lstAcc[0].NOB_TrainingDate__c = Date.newInstance(System.today().year(), 04, 05);
        update lstAcc;

        NOB_AP61_UpdateRankingQuarter.testDate =  Date.newInstance(2021, 05, 14);
        insert lstServiceContracts;

        Test.startTest();
        //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2021, 05, 14);
        NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year()-1, 05, 14);
        Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(true, true));
        Test.stopTest();

          
        List<ServiceContract> lstResult = [SELECT  NOB_EngagementQ1__c,
        NOB_EngagementQ1N1__c ,
        NOB_EngagementQ2__c,
        NOB_EngagementQ2N1__c,
        NOB_EngagementQ3__c,
        NOB_EngagementQ3N1__c,
        NOB_EngagementQ4__c,
        NOB_EngagementQ4N1__c,
        NOB_ContexteEngagement__c,
        NOB_TechToProcess__c
        FROM ServiceContract WHERE Id =: lstServiceContracts.get(0).Id];

        System.debug('££££ service contract retrieved'+ lstServiceContracts);

        System.assertEquals(56, lstResult.get(0).NOB_EngagementQ1__c);
        System.assertEquals(56, lstResult.get(0).NOB_EngagementQ1N1__c);
        System.assertEquals(142, lstResult.get(0).NOB_EngagementQ2__c);
        System.assertEquals(56, lstResult.get(0).NOB_EngagementQ2N1__c);
        System.assertEquals(150, lstResult.get(0).NOB_EngagementQ3__c);
        System.assertEquals(56, lstResult.get(0).NOB_EngagementQ3N1__c);
        System.assertEquals(150, lstResult.get(0).NOB_EngagementQ4__c);
        System.assertEquals(56, lstResult.get(0).NOB_EngagementQ4N1__c);
        System.assertEquals(false, lstResult.get(0).NOB_TechToProcess__c);
        System.assertEquals('CR', lstResult.get(0).NOB_ContexteEngagement__c);
    }

    
     //EG is changed
     @IsTest
     public static void test3rdQuarterEG(){
      
        
        lstAcc[0].NOB_TrainingDate__c = Date.newInstance(2021, 07, 05);
        update lstAcc;

        //NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(2021, 09, 05);
        NOB_AP61_UpdateRankingQuarter.testDate = Date.newInstance(System.today().year()-1, 09, 05);
        insert lstServiceContracts;

        lstServiceContracts[0].NOB_NombreMissionAnnuel__c = 1000;
        update lstServiceContracts;
 
         Test.startTest();
         
          System.debug('££££ start of test3rdQuarterEG');
         //NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(2021, 09, 05);
         NOB_Batch_UpdateEngagementServiceContrat.runDate = Date.newInstance(System.today().year()-1, 05, 14);
         Database.executeBatch(new NOB_Batch_UpdateEngagementServiceContrat(true, false));
         
          System.debug('££££ end of test3rdQuarterEG');
         Test.stopTest();
 
           
         List<ServiceContract> lstResult = [SELECT  NOB_EngagementQ1__c,
         NOB_EngagementQ1N1__c ,
         NOB_EngagementQ2__c,
         NOB_EngagementQ2N1__c,
         NOB_EngagementQ3__c,
         NOB_EngagementQ3N1__c,
         NOB_EngagementQ4__c,
         NOB_EngagementQ4N1__c, NOB_TechToProcess__c
         FROM ServiceContract WHERE Id =: lstServiceContracts.get(0).Id];
 
         System.debug('££££ service contract retrieved'+ lstResult);
  
         //System.assertEquals(56, lstResult.get(0).NOB_EngagementQ3__c);

         System.assertEquals(250, lstResult.get(0).NOB_EngagementQ4__c);

         System.assertEquals(false, lstResult.get(0).NOB_TechToProcess__c);
         
     
    }

}