/*
----------------------------------------------------------------------
-- - Name          : VFC_PostAssessmentPostSO_TEST
-- - Author        : KPA
-- - Description   : Test Class VFC_PostAssessmentPostSO
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-OCT-2020  KPA   1.0      Initial Version
----------------------------------------------------------------------*/ 
@isTest

public class VFC_PostAssessmentPostSO_TEST {
    static User user1;
    static Account bs1;
    static Assessment__c Ass1;
    static PrerequisiteOrder__c SO1;
    


    static{
        
        user1 = TestFactory.createUser('user1');
        insert user1;

       system.runAs(user1){
       /*
        Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.DistributorConnected__c = true;
            bs1.ReferenceNumber__c = '258974136';
            bs1.Type = 'Standard';
            bs1.isEligibleShippingCost__c = true;
            bs1.Feature__c = 'PilotDirectSourcing';
            bs1.ShippingPostalCode = '12';
           
            insert bs1;


       Assessment__c Ass1= TestFactory.createAssessment('Ass1',bs1);
           insert Ass1;


       PrerequisiteOrder__c SO1 = TestFactory.createSalesOrder(Ass1,Bs1,'MANAGED');
       insert SO1;
*/
       }



    }


    @isTest
    static void launchPostAssessmentCallOut_Test(){
        System.debug('~~~~~~ startlaunchPostAssessmentCallOutTest~~~~~~~');
     system.runAs(user1){

        Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
        bs1.IsEligible__c = true;
        bs1.DistributorConnected__c = true;
        bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        bs1.Type = 'Standard';
        bs1.isEligibleShippingCost__c = true;
        bs1.Feature__c = 'PilotDirectSourcing';
        bs1.ShippingPostalCode = '12';
       
        insert bs1;


   Assessment__c Ass1= TestFactory.createAssessment('Ass1',bs1);
   Ass1.EntityRules__c='FR392';
   Ass1.EntityCode__c = '392';
       insert Ass1;


   PrerequisiteOrder__c SO1 = TestFactory.createSalesOrder(Ass1,bs1,'MANAGED');
   insert SO1;

   
    
   list <PrerequisiteOrder__c> lstSO =[SELECT id,name,Assessment__r.EntityRules__c,TECH_AssessmentEntityRules__c,Assessment__r.id FROM  PrerequisiteOrder__c WHERE id =:SO1.id];
 System.debug('~~~~~ query '+lstSO);


        Test.startTest();

        System.debug('~~~~~~ start test~~~~~~~');
        System.debug('~~~~~ S01.id: ' +SO1.id);

        Test.setCurrentPage(Page.VFP_PostAssessmentPostSO);
        ApexPages.currentPage().getParameters().put('Id', SO1.id);
       
        String idz= String.valueOf(SO1.id);
        System.debug('~~~~~ String idz: '+idz);


        VFC_PostAssessmentPostSO.launchPostAssessmentCallOut(idz);
        
        Test.stopTest();

        System.debug('~~~ Ass1.EntityRules__c '+ Ass1.EntityRules__c);
        System.debug('~~~~~~~ SO1.TECH_AssessmentEntityRules__c '+SO1.TECH_AssessmentEntityRules__c);
        System.debug('~~~~~~~~SO1.Assessment__r.EntityRules__c '+SO1.Assessment__r.EntityRules__c);
        System.debug('~~~~~~~~~~~ Assessment id '+Ass1.id);
        System.debug('~~~~~~~~ SO1.Assessment__r.id '+SO1.Assessment__r.id);
        System.debug('~~~~~~~~ SO1.Assessment__c '+SO1.Assessment__c);


        



     }
    }

  
    

    @isTest
    static void launchPostSalesOrderCallOut_Test(){
        System.debug('~~~~~~ startlaunchPostlaunchPostSalesOrderCallOut_Test~~~~~~~');
     system.runAs(user1){

        Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
        bs1.IsEligible__c = true;
        bs1.DistributorConnected__c = true;
        bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        bs1.Type = 'Standard';
        bs1.isEligibleShippingCost__c = true;
        bs1.Feature__c = 'PilotDirectSourcing';
        bs1.ShippingPostalCode = '12';
       
        insert bs1;


   Assessment__c Ass1= TestFactory.createAssessment('Ass1',bs1);
       insert Ass1;


   PrerequisiteOrder__c SO1 = TestFactory.createSalesOrder(Ass1,Bs1,'MANAGED');
   insert SO1;
        
        Test.startTest();

        System.debug('~~~~~~ start test2~~~~~~~');
        System.debug('~~~~~ 2 S01.id: ' +SO1.id);

        Test.setCurrentPage(Page.VFP_PostAssessmentPostSO);
        ApexPages.currentPage().getParameters().put('Id', SO1.id);
       
        String idz= String.valueOf(SO1.id);
        System.debug('~~~~~ 2 String idz: '+idz);


        VFC_PostAssessmentPostSO.launchPostSalesOrderCallOut(idz);
        
        Test.stopTest();
     }
    }


}