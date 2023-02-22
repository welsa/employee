/*
----------------------------------------------------------------------
-- - Name          : VFC17_PrintPartListForAssessment_TEST
-- - Author        : VSU
-- - Description   : Test class for VFC17_PrintPartListForAssessment
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 16-JUN-2017  VSU     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/@isTest
public with sharing class   VFC17_PrintPartListForAssessment_TEST
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<partList__c> partList;
    
    static
    {
        adminUser           = TestFactory.createUser('adminUser');
        insert adminUser;

        System.runAs(adminUser)
        {
            // Generating the account
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
                TestFactory.createAccountDistributor('Distributor_2', 'ES')
            };

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2])
            };

            insert assessmentList;

            partList = new list <partList__c>{
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[1])
            };

            insert partlist;
        }

    }

    @isTest static void quote_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP17_PrintPartListForAssessment);

            ApexPages.currentPage().getParameters().put('Id', assessmentList[0].Id);
            ApexPages.currentPage().getParameters().put('force_download', 'true');

            Test.startTest();
                VFC17_PrintPartListForAssessment controller = new VFC17_PrintPartListForAssessment();
            Test.stopTest();

            System.assertEquals(assessmentList[0].Id, controller.currentAssessment.Id);
            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(2, controller.mapPartListsWrapper.size());
            System.assertEquals(true, ApexPages.currentPage().getHeaders().get('content-disposition').startsWith('attachment;'));
        }
    }

     @isTest static void quoteNoForceDownload_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP17_PrintPartListForAssessment);

            ApexPages.currentPage().getParameters().put('Id', assessmentList[1].Id);

            Test.startTest();
                VFC17_PrintPartListForAssessment controller = new VFC17_PrintPartListForAssessment();
            Test.stopTest();

            System.assertEquals(assessmentList[1].Id, controller.currentAssessment.Id);
            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(1, controller.mapPartListsWrapper.size());
            System.assertEquals(true, ApexPages.currentPage().getHeaders().get('content-disposition').startsWith('inline;'));
        }
    }
}