/*************************************************************************************
Class Name - NOB_BatchWeeklySC_TEST
Version - 1.0
Created Date - 25-01-2021
Function - Test class to set fields to 0 on a weekly basis - class : NOB_BatchWeekly_UpdateServiceContrat
#Ticket  - RSIW : 7183

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           25-01-2021   Initial version
*************************************************************************************/
@IsTest
public with sharing class NOB_BatchWeeklySC_TEST {
    public NOB_BatchWeeklySC_TEST() {

    }
    static User userAdmin;
    static List<Account> lstAcc;
    static List<ServiceContract> lstServiceContracts;
    static List<NOB_Planning__c> lstDispoSemaine;
    static List<NOB_Planning__c> lstDispoReserve;
    static List<Datetime> lstDateThisWeek;

    static{
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;

        System.runAs(userAdmin){

            String recordTypeApporteur = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Assureur').getRecordTypeId();

            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US')
            };
            lstAcc.get(0).NOB_isPrefikar__c = true;
            lstAcc.get(0).ShippingCity = 'Curepipe';
            lstAcc.get(0).ShippingCountry = 'United States';
            lstAcc.get(0).ShippingState = 'California';
            lstAcc.get(0).ShippingCountryCode = 'US';
            lstAcc.get(0).NOB_Statut__c = 'Actif';
            insert lstAcc;

            lstServiceContracts = new List<ServiceContract>{
                new ServiceContract(Name = 'scTestActive', NOB_ContractsType__c = 'Proximité', /*NOB_NumRCSRM__c = 'ABE1234',*/ AccountId = lstAcc[0].Id, StartDate=Date.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day()),
                NOB_DateDeFormation__c = Date.today(),
                EndDate= Date.newInstance(System.today().year(),
                System.today().month() +12, 
                System.today().day())
                )
            };
            insert lstServiceContracts;

            lstDispoSemaine = new List<NOB_Planning__c>{
             TestFactory.createPlanning(lstAcc[0].Id),
             TestFactory.createPlanning(lstAcc[0].Id)
            };
            lstDispoSemaine[1].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 14, 00, 0).addDays(2);
            lstDispoSemaine[1].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 15, 00, 0).addDays(2);
            lstDispoSemaine.get(0).IsDelete__c = false;
            lstDispoSemaine.get(1).IsDelete__c = false;
            insert lstDispoSemaine; 

            lstDispoReserve = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstAcc[0].Id),
                TestFactory.createPlanning(lstAcc[0].Id)
            };
            lstDispoReserve[1].NOB_StartDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 15, 00, 0).addDays(2);
            lstDispoReserve[1].NOB_EndDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 16, 00, 0).addDays(2);
            lstDispoReserve.get(0).IsDelete__c = false;
            lstDispoReserve.get(1).IsDelete__c = false;
            lstDispoReserve.get(0).NOB_Status__c = 'Réservé';
            lstDispoReserve.get(1).NOB_Status__c = 'Réservé';
            insert lstDispoReserve;
        }
    }


    @IsTest
    public static void testBatchWeeklyPass(){
        Test.startTest();
            Database.executeBatch(new NOB_BatchWeekly_UpdateServiceContract());
        Test.stopTest();

        List<ServiceContract> lstResult = [SELECT NOB_Dispo_entrees_semaine__c, NOB_TauxEngagement__c, Account.NOB_TauxEngagement__c, NOB_TauxEngagementPourcent__c FROM ServiceContract WHERE Id IN :lstServiceContracts];

        List<Account> lstResultAcc = [SELECT NOB_TauxEngagement__c FROM Account WHERE Id IN :lstAcc];


        // System.assertEquals(4, lstResult.get(0).NOB_Dispo_entrees_semaine__c);

        // System.assertEquals(2, lstResult.get(0).NOB_TauxEngagement__c);

        // System.assertEquals(lstResultAcc.get(0).NOB_TauxEngagement__c, lstResult.get(0).NOB_TauxEngagementPourcent__c);
    }

    /*
    @isTest
    public static void testScheduleInDB(){
        String scheduleDate = '0 0 5 ? * MON';
        Test.startTest();
            String jobId = NOB_BatchWeekly_UpdateServiceContract.scheduleClassInDB();
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];
        System.assertEquals(scheduleDate, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2021-02-01 05:00:00', String.valueOf(ct.NextFireTime));
    }
   */
}