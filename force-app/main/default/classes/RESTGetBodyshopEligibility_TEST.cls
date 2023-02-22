/*
  ----------------------------------------------------------------------
  -- - Name          : RESTUpsertAssessmentV1_TEST 
  -- - Author        : ABT 
  -- - Description   : Test class for WS RESTUpsertAssessment
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-AUG-2016  ABT    1.0     Initial Version
  -- 30-AUG-2016  DUN    1.1     Updated Version
  -- 23-AUG-2018  RLA    1.2     Updated Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class RESTGetBodyshopEligibility_TEST {

    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PartList__c> partList;
    static List<CrossReference__c> crossReferenceList;

    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;

    static List<CarMapping__c> carMappingList;
    static List<AccountRef__c> accountRefList;


    static {

        adminUser = TestFactory.createUser('adminUser');
        insert adminUser;

        System.runAs(adminUser) {

            // Generating the account
            accountList = new List<Account> {
                TestFactory.createAccountBodyshop('BodyShop_1', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_3', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_4', 'FR')
            };

            accountList[0].isEligibleSourcing__c        = true;
            accountList[0].isEligibleSubstitution__c    = true;
            accountList[0].ContactUser__c               = adminUser.Id;

            accountList[1].isEligibleSourcing__c        = true;
            accountList[1].isEligibleSubstitution__c    = false;
            accountList[1].ContactUser__c               = adminUser.Id;

            accountList[2].isEligibleSourcing__c        = true;
            accountList[2].isEligibleSubstitution__c    = false;
            accountList[2].ContactEmail__c              = 'test@test.com';

            accountList[3].isEligibleSourcing__c        = true;
            accountList[3].isEligibleSubstitution__c    = false;
            accountList[3].ContactEmail__c              = 'test@test.com';

            insert accountList;
            
            accountRefList = new List<AccountRef__c> {
                TestFactory.createAccountRef('2763223904', accountList[0].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223905', accountList[1].Id, 'DIVA'),
                TestFactory.createAccountRef('2763223906', null, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223907', null, 'DIVA'),
                TestFactory.createAccountRef('2763223910', accountList[2].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223911', accountList[3].Id, 'DIVA')
            };

            accountRefList[0].SubstitutionAccepted__c = true;
            accountRefList[1].SubstitutionAccepted__c = true;
            accountRefList[2].SubstitutionAccepted__c = true;
            accountRefList[3].SubstitutionAccepted__c = true;
            accountRefList[4].SubstitutionAccepted__c = true;
            
            insert accountRefList;

            assessmentList = new list <Assessment__c>();
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accountList[0]);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.AssessmentNumber__c = 'ASSESS_TEST-0001';
            assessmentList.add(ass1);

            insert assessmentList;

            System.debug('@@@@ assessmentList: '+assessmentList);
        }
    }

    @isTest static void getBodyshopEligibilityPassed_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystem":"DIVA","BodyshopReference":"2763223905"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223904"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            String expectedResponse = '{"Version":"2.22","Bodyshops":[{"callerSystem":"DIVA","BodyshopReference":"2763223905","isEligibleSubstitution":true,"OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223904","isEligibleSubstitution":true,"OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false}],"OperationType":"get","Success":true,"Warning":null,"ErrorMessage":null}';
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage : Exceptions'));
            System.assertEquals(expectedResponse, jsonResponseString);
        }
    }

    
    @isTest static void getBodyshopEligibilityException_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '{"callerSystem":"DIVA","BodyshopReference":"2763223905"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223904"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('"Success":false'));
        }
    }

    
    @isTest static void getBodyshopEligibilityMissingFields_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystemX":"DIVA","BodyshopReference":"2763223907"},{"callerSystem":"GTMOTIVE","BodyshopReferenceX":"2763223907"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Missing fields:'));
        }
    }

    @isTest static void getBodyshopEligibilityNoMappingFound_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystem":"DIVA","BodyshopReference":"2763223908"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223908"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('No mapping found for:'));
        }
    }

    @isTest static void getBodyshopEligibilityWithNullInternalReference_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystem":"DIVA","BodyshopReference":"2763223907"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223906"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('The bodyshops are not found:'));
        }
    }

    @isTest static void getBodyshopEligibilityWithoutContactUser_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystem":"DIVA","BodyshopReference":"2763223911"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223910"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            String expectedResponse = '{"Version":"2.22","Bodyshops":[{"callerSystem":"DIVA","BodyshopReference":"2763223911","isEligibleSubstitution":true,"OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223910","isEligibleSubstitution":true,"OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false}],"OperationType":"get","Success":true,"Warning":null,"ErrorMessage":null}';
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage : Exceptions'));
            System.assertEquals(expectedResponse, jsonResponseString);
        }
    }

    @isTest static void getBodyshopEligibilityGreaterThan30000_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},'  +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"},' +
                                            '{"callerSystemX":"DIVA","BodyshopReferenceX":"2763223905"},{"callerSystemX":"GTMOTIVE","BodyshopReference":"2763223904"}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Missing fields:'));
        }
    }

    @isTest static void getBodyshopEligibilityPassedV2_TEST(){
        System.runAs(adminUser){
            String requestJSONString    = '[{"callerSystem":"DIVA","BodyshopReference":"2763223905"},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223904", "AssessmentNumber": "ASSESS_TEST-0001"}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/getBodyshopEligibility/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTGetBodyshopEligibility.processResponse();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            String expectedResponse = '{"Version":"2.22","Bodyshops":[{"callerSystem":"DIVA","BodyshopReference":"2763223905","isEligibleSubstitution":true,"isEligibleSourcing":true,"OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false},{"callerSystem":"GTMOTIVE","BodyshopReference":"2763223904","isEligibleSubstitution":true,"isEligibleSourcing":true,"SubstitutionIn":"null","OrderFromAT":false,"SendingAccepted":false,"VinCheckAuto":false}],"OperationType":"get","Success":true,"Warning":null,"ErrorMessage":null}';
            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage : Exceptions'));
            //System.assertEquals(expectedResponse, jsonResponseString);
        }
    }

}