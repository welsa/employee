/*
----------------------------------------------------------------------
-- - Name          : ASPISBatchCataloguePurge_TEST
-- - Author        : ABT
-- - Description   : Test class for the batch of ASPISBatchCataloguePurge
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 08-JUN-2017  ABT     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class ASPISBatchCataloguePurge_TEST
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<CrossReference__c> crossRefList;
    static List<PartList__c> partList;

    static
    {
        adminUser = TestFactory.createUser('adminUser');
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

            assessmentList[1].TECH_EntityCountryCode__c = 'ES';

            assessmentList[0].PlateNumber2__c           = '1234MR17';
            assessmentList[1].PlateNumber2__c           = '4567MR17';

            assessmentList[0].Manufacturer__c           = 'NISSAN';
            assessmentList[1].Manufacturer__c           = 'BMW';

            insert assessmentList;

            crossRefList = new List<CrossReference__c>
            {
                TestFactory.createCrossReference('FR', '123456', 'NISSAN', 1000, true),
                TestFactory.createCrossReference('FR', '654321', 'NISSAN', 1000, true),
                TestFactory.createCrossReference('ES', '123456', 'BMW', 1000, true),
                TestFactory.createCrossReference('ES', '741852', 'BMW', 1000, true)
            };

            crossRefList[0].isDeleted__c = true;
            crossRefList[1].isDeleted__c = true;
            crossRefList[2].isDeleted__c = true;
            crossRefList[3].isDeleted__c = true;

            insert crossRefList;

            partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1])
            };

            insert partList;

            partList[1].OriginalPart__c     = partList[0].Id;
            partList[3].OriginalPart__c     = partList[2].Id;

            partList[1].CrossReferenceId__c = crossRefList[1].Id;
            partList[3].CrossReferenceId__c = crossRefList[3].Id;

            update partList;
        }
    }

    @isTest static void runBatch()
    {
        System.runAs(adminUser)
        {
            ASPISBatchCataloguePurge batch = new ASPISBatchCataloguePurge();

            Test.startTest();
                Id processId = Database.executeBatch(batch);
            Test.stopTest();

            List<CrossReference__c> remainingCrossRefList = [SELECT Id
                                                             FROM   CrossReference__c
                                                             WHERE  Id IN: crossRefList];

            // Should remain 2 cross refs as the 2 were referenced in the part lists
            System.assertEquals(2, remainingCrossRefList.size());
        }
    }

    @isTest static void scheduleBatchCataloguePurge()
    {
        System.runAs(adminUser)
        {
            ASPISBatchCataloguePurge scheduler = new ASPISBatchCataloguePurge();
            String sch = '0 0 0 * * ?';

            Test.startTest();
                Id processId = System.schedule('Test cross ref delete batch scheduler', sch, scheduler);
            Test.stopTest();

            CronTrigger ct = [SELECT Id, CronExpression
                              FROM   CronTrigger
                              WHERE  Id =: processId];

            System.assertEquals(sch, ct.CronExpression);
        }
    }
}