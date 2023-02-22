/*
  ----------------------------------------------------------------------
  -- - Name          : AP21AssessmentSharing_TEST 
  -- - Author        : ABT 
  -- - Description   : AP21AssessmentSharing_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer      Date        Description
  -- ----------     ----------  -----------------------
  -- Brayan         30/11/2015  Original Version
 **********************************************************************
*/
@isTest
public class AP21AssessmentSharing_TEST 
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<InvoiceMargin__c> invoiceMarginList;

    static
    {
        adminUser = TestFactory.createUser('adminUser');

        insert adminUser;

        System.runAs(adminUser)
        {
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'FR')
            };

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment1', accountList[0]),
                TestFactory.createAssessment('Assessment2', accountList[1])
            };

            //insert assessmentList;

            invoiceMarginList = new List<InvoiceMargin__c>
            {
                new InvoiceMargin__c(Name                = 'FR',
                                     CountryCode__c      = 'FR',
                                     ValidationMargin__c = 1.00)
            };

            insert invoiceMarginList;
        }
    }

    @isTest static void assessmentInsert_TEST()
    {
        System.runAs(adminUser)
        {
            Test.startTest();
                insert assessmentList;
            Test.stopTest();

            List<Assessment__Share> assessmentShareList = [ SELECT  Id
                                                            FROM    Assessment__Share
                                                            WHERE   ParentId IN: assessmentList];

            System.assertEquals(true, assessmentShareList.size() > 0);
            System.assertEquals(4,    assessmentShareList.size());
        }
    }

    @isTest static void assessmentUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            insert assessmentList;

            List<PrerequisiteOrder__c> salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
                TestFactory.createSalesOrder(assessmentList[1], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
            };

            insert salesOrderList;

            assessmentList[1].BodyShop__c = accountList[0].Id;

            Test.startTest();
                update assessmentList;
            Test.stopTest();

            List<Assessment__Share> assessmentShareList = [ SELECT  Id
                                                            FROM    Assessment__Share
                                                            WHERE   ParentId IN: assessmentList];

            System.assertEquals(true, assessmentShareList.size() > 0);
            System.assertEquals(4,    assessmentShareList.size());

        }
    }
}