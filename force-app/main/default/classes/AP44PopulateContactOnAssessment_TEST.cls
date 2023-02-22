/*************************************************************************************
Class Name - AP22PopulateContactOnAccount_TEST
Version - 1.0
Function - Class to populate the ContactUser__c on Assessment 

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* RLA            08-AUG-2018  Original Version
*************************************************************************************/
@isTest
public class AP44PopulateContactOnAssessment_TEST {
  
    static list<Account> accountList = new list<Account>();
    static List<Assessment__c> assessmentList = new List <Assessment__c>();
    static user adminUser = new user();


    static
    {
        adminUser = TestFactory.createUser('adminUser');
        adminUser.LanguageLocaleKey = 'fr';

        insert adminUser;

        System.runAs(adminUser)
        {
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ES', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES')

            };
            accountList[0].ContactUser__c = adminUser.Id;
            accountList[0].isEligibleSourcing__c = false;
            accountList[2].ContactUser__c = adminUser.Id;
            accountList[2].isEligibleSourcing__c = false;

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),             
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[4])
            };

            insert assessmentList;

            
        }
    }
    static testMethod void testContactUserOnAssessment() {

        System.runAs(adminUser){
            assessmentList[0].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId() ;
            assessmentList[0].OrderStatus__c = 'PENDING DISTRIBUTOR (CARE)';  
            assessmentList[0].TECH_EntityCountryCode__c = 'DE';  
            assessmentList[0].Status__c = 'SOURCED';  

            assessmentList[1].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId() ;
            assessmentList[1].OrderStatus__c = 'PENDING DISTRIBUTOR (CARE)';  
            assessmentList[1].TECH_EntityCountryCode__c = 'DE';  
            assessmentList[1].Status__c = 'SOURCED';

            assessmentList[2].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() ;
            assessmentList[2].TECH_EntityCountryCode__c = 'DE';  
            assessmentList[2].Status__c = 'SOURCED';

            assessmentList[3].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() ;
            assessmentList[3].TECH_EntityCountryCode__c = 'DE';  
            assessmentList[3].Status__c = 'SOURCED';

            assessmentList[4].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() ;
            assessmentList[4].TECH_EntityCountryCode__c = 'FR';  
            assessmentList[4].Status__c = 'SOURCED';

            assessmentList[5].RecordTypeId  =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() ;
            assessmentList[5].TECH_EntityCountryCode__c = 'DE';  
            assessmentList[5].Status__c = 'SOURCED';


            Test.startTest();
                update assessmentList;
            Test.stopTest();

            System.assertEquals(AP44PopulateContactOnAssessment.emailResultList.size(), 4);




        }

            
    }
}