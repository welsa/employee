/*
----------------------------------------------------------------------
-- - Name          : RESTPostAssessment_TEST
-- - Author        : ABT
-- - Description   : Test class for RESTPostAssessment
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 06-MAR-2017  ABT     1.0    Initial version
-- 24-MAY-2017  ABT     1.1    Modified all methods as RESTPostAssessment is no more called from trigger
-- 14-NOV-2017  AMI     1.2    Updating test class following updates/evolution in RESTPostAssessment
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class RESTPostAssessment_TEST
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
	static List<PartList__c> partList;
	static List<PrerequisiteOrder__c> salesOrderList;
    static Id claimRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
    static Id claimOrderRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

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

			accountList[0].AXAPartner__c = true;
			accountList[2].AXAPartner__c = true;

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR_1', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_FR_2', accountList[0]),
                TestFactory.createAssessment('Assessment_FR_3', accountList[0]),
                TestFactory.createAssessment('Assessment_FR_ClaimOrder', accountList[0])
            };

            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[1].TECH_EntityCountryCode__c = 'ES';
            assessmentList[2].TECH_EntityCountryCode__c = 'FR';
            assessmentList[3].TECH_EntityCountryCode__c = 'FR';
            assessmentList[4].TECH_EntityCountryCode__c = 'FR';

            assessmentList[0].EntityCode__c             = '299';
            assessmentList[1].EntityCode__c             = '01';
            assessmentList[2].EntityCode__c             = '392';
            assessmentList[3].EntityCode__c             = '392';
            assessmentList[4].EntityCode__c             = '392';

            assessmentList[0].EntityRules__c            = 'FR299';
            assessmentList[1].EntityRules__c            = 'ES01';
            assessmentList[2].EntityRules__c            = 'FR392';
            assessmentList[3].EntityRules__c            = 'FR392';
            assessmentList[4].EntityRules__c            = 'FR392';

            assessmentList[0].RecordTypeId              = claimRecordTypeId;
            assessmentList[1].RecordTypeId              = claimRecordTypeId;
            assessmentList[2].RecordTypeId              = claimRecordTypeId;
            assessmentList[3].RecordTypeId              = claimRecordTypeId;
            assessmentList[4].RecordTypeId              = claimOrderRecordTypeId;

            insert assessmentList;

            assessmentList[4].ParentAssessment__c       = assessmentList[3].Id;

            update assessmentList;

			partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),

                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1]),

                TestFactory.createPartList(assessmentList[2]),
                TestFactory.createPartList(assessmentList[2]),

                TestFactory.createPartList(assessmentList[3]),
                TestFactory.createPartList(assessmentList[3])
            };

            insert partList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], 'PREACCEPTANCE')
            };

            insert salesOrderList;
        }
    }

    //AMI 14/11/17 : Creating mock class
    public class ICECallOut implements HttpCalloutMock{
        
        Integer code;
        String status;
        String body;

        public ICECallOut(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.body);
            response.setStatusCode(this.code);
            response.setStatus(this.status);
            return response;
        }    
    }

    //AMI 14/11/17 : Test callout successfully processed with log created
    @isTest static void buildJSONAsyncPassed(){
        system.debug('## Start buildJSONAsyncPassed');
        
        system.runAs(adminUser){
            //insert assessment
            assessmentList[0].IsShoppingList__c = false;
            assessmentList[0].PlateNumber2__c = 'AZ5020';
            assessmentList[0].ClaimReference__c = 'claimref';

            update assessmentList[0];

            string body = '{"Result" : [{"TechnicalId":"' + assessmentList[0].Id + '","FunctionalId":"","Success":true,"ErrorMessage":""}]}';
            Test.setMock(HttpCalloutMock.class,new ICECallOut(200,'OK',body));

            Test.startTest();
                RESTPostAssessment.buildJSONAsync(new set<Id>{assessmentList[0].Id});
            Test.stopTest();

            // Asserting that the latest log should be Passed as all are successful
            List<Log__c> logList = [SELECT  Id, Status__c
                                    FROM    Log__c
                                    Order By DateLog__c DESC
                                    LIMIT   1];

            System.assertEquals(1, logList.size());
            System.assertEquals('Passed', logList[0].Status__c);
        }
        system.debug('## End buildJSONAsyncPassed');
    }

    //AMI 14/11/17 : Test callout error without any log created
    @isTest static void buildJSONAsyncNoLogGenerated(){
        system.debug('## Start buildJSONAsyncNoLogGenerated');
        
        system.runAs(adminUser){
            string body = 'Test Body';
            Test.setMock(HttpCalloutMock.class,new ICECallOut(200,'OK',body));

            Test.startTest();
                RESTPostAssessment.buildJSONAsync(new set<Id>{assessmentList[0].Id});
            Test.stopTest();

            // Asserting that the latest log should be Passed as all are successful
            List<Log__c> logList = [SELECT  Id, Status__c
                                    FROM    Log__c
                                    Order By DateLog__c DESC
                                    LIMIT   1];

            System.assertEquals(0, logList.size());
        }
        system.debug('## End buildJSONAsyncNoLogGenerated');
    }

    //AMI 14/11/17 : Test callout error with log created
    @isTest static void buildJSONAsyncFailed(){
        system.debug('## Start buildJSONAsyncFailed');
        
        system.runAs(adminUser){
            //insert assessment
            assessmentList[0].IsShoppingList__c = false;
            assessmentList[0].PlateNumber2__c = 'AZ5020';
            assessmentList[0].ClaimReference__c = 'claimref';

            update assessmentList[0];

            string body = '{"Result" : [{"TechnicalId":"' + assessmentList[0].Id + '","FunctionalId":"","Success":false,"ErrorMessage":"error"}]}';
            Test.setMock(HttpCalloutMock.class,new ICECallOut(200,'OK',body));

            Test.startTest();
                RESTPostAssessment.buildJSONAsync(new set<Id>{assessmentList[0].Id});
            Test.stopTest();

            // Asserting that the latest log should be Passed as all are successful
            List<Log__c> logList = [SELECT  Id, Status__c
                                    FROM    Log__c
                                    Order By DateLog__c DESC
                                    LIMIT   1];

            System.assertEquals(1, logList.size());
            System.assertEquals('Failed', logList[0].Status__c);
        }
        system.debug('## End buildJSONAsyncFailed');
    }

    //AMI 14/11/17 : Test callout exception error with log created
    @isTest static void buildJSONAsyncExceptionFailed(){
        system.debug('## Start buildJSONAsyncExceptionFailed');
        
        system.runAs(adminUser){
            //insert assessment
            assessmentList[0].IsShoppingList__c = false;
            assessmentList[0].PlateNumber2__c = 'AZ5020';
            assessmentList[0].ClaimReference__c = 'claimref';

            update assessmentList[0];

            string body = '{"Result" : [{"TechnicalId":"' + assessmentList[0].Id + '","FunctionalId":"","Success":false,"ErrorMessage":"error"]}';
            Test.setMock(HttpCalloutMock.class,new ICECallOut(200,'OK',body));

            Test.startTest();
                RESTPostAssessment.buildJSONAsync(new set<Id>{assessmentList[0].Id});
            Test.stopTest();

            // Asserting that the latest log should be Passed as all are successful
            List<Log__c> logList = [SELECT  Id, Status__c
                                    FROM    Log__c
                                    Order By DateLog__c DESC
                                    LIMIT   1];

            System.assertEquals(1, logList.size());
            System.assertEquals('Failed', logList[0].Status__c);
        }
        system.debug('## End buildJSONAsyncExceptionFailed');
    }
}