/*
  ----------------------------------------------------------------------
  -- - Name          : RESTrunSubstitution_TEST 
  -- - Author        : ASE 
  -- - Description   : Test class for WS RESTrunSubstitution
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 16-AUG-2016  ASE    1.0     Initial Version
  -- 17-AUG-2016  ABT    2.0     Wrote whole class
  -- 07-FEB-2019  RLA     3.0     C-002901: RunSubstitution: GT Motive doit envoyer le Transaction ID

  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class RESTrunSubstitution_TEST {

    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PartList__c> partList;
    static List<CrossReference__c> crossReferenceList;

    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;

    static List<CarMapping__c> carMappingList;
    static List<AccountRef__c> accountRefList;


    static
    {
        UserRole spainAlphaUserRole = new UserRole(Name = 'ES - AlphaScale');

        insert spainAlphaUserRole;

        adminUser = TestFactory.createUser('adminUser');
        
        // setting the role of the User with a prefix ES
        adminUser.UserRoleId = spainAlphaUserRole.Id;

        insert adminUser;

        System.runAs(adminUser)
        {
            // Generating the account
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_3', 'ES'),
                TestFactory.createAccountDistributor('Distributor_1', 'ES')
            };

            insert accountList;
            
            accountRefList = new List<AccountRef__c>
            {
                TestFactory.createAccountRef('2763223904', accountList[0].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223905', accountList[1].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223904', accountList[2].Id, 'GTDECALE'),
                TestFactory.createAccountRef('2763223906', '001000101001001', 'GTMOTIVE')

            };

            insert accountRefList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_ES', accountList[0])
            };
            assessmentList[0].AssessmentNumber__c = 'test';
            assessmentList[0].TECH_EntityCountryCode__c = 'ES';
            assessmentList[0].Manufacturer__c           = 'Renault';
            assessmentList[0].EntityCode__c             = '299';
            assessmentList[0].Status__c                 = 'SUBSTITUTION';
            assessmentList[0].AssessmentID__c           = 'SUBSTIT' 
                                                        + 'ES' 
                                                        + accountRefList[0].Name.substringAfter('-')
                                                        //+ assessmentList[0].Manufacturer__c 
                                                        + 'RE1'
                                                        + assessmentList[0].AssessmentNumber__c;

            insert assessmentList;

            partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0])
            };

            insert partList;

            crossReferenceList = new List<CrossReference__c>
            {
                TestFactory.createCrossReference('ES', 'A10 11 1290', 'Mercedes', 60.0, true),
                TestFactory.createCrossReference('ES', 'A10 11 1291', 'Renault',  40.0, true),
                TestFactory.createCrossReference('ES', 'A10 11 1292', 'BMW',      50.0, true),
                TestFactory.createCrossReference('ES', '0A10 11 1293', 'Mercedes', 40.0, true),
                TestFactory.createCrossReference('ES', '0A10 11 1293', 'Mercedes', 60.0, true),
                TestFactory.createCrossReference('ES', 'A10 11 1294', 'Mercedes', 60.0, false),
                TestFactory.createCrossReference('ES', 'A10 11 1295', 'Mercedes', 60.0, true),
                TestFactory.createCrossReference('ES', 'A10 11 1296', 'Mercedes', 60.0, true)
            };

            crossReferenceList[6].IAMPartDescription__c = null;
            crossReferenceList[6].ASPublicPrice__c = null;
            crossReferenceList[6].IAMPublicPrice__c = 60.0;
            crossReferenceList[6].OEMPartDescription__c = 'test';

            crossReferenceList[7].IAMPartDescription__c = null;
            crossReferenceList[7].ASPublicPrice__c = null;
            crossReferenceList[7].IAMPublicPrice__c = null;
            crossReferenceList[7].OEMPartDescription__c = 'test';

            insert crossReferenceList;

            List<CrossReference__c> updatedCRList = new List<CrossReference__c>();
            crossReferenceList[0].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[0]);
            crossReferenceList[1].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[1]);
            crossReferenceList[2].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[2]);
            crossReferenceList[3].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[3]);
            crossReferenceList[4].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[4]);
            crossReferenceList[5].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[5]);
            crossReferenceList[6].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[6]);
            crossReferenceList[7].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[7]);
            update updatedCRList;

            carMappingList = new List<CarMapping__c>();
            carMappingList.addAll(TestFactory.createCarMappingList('GTMOTIVE'));
            carMappingList.addAll(TestFactory.createCarMappingList('GTDECALE'));

            insert carMappingList;


            masterRuleList = new List<MasterRules__c>
            {
                TestFactory.createMasterRule('ES299', 'SUBSTITUTION', 'CrossReference__c')
            };

            insert masterRuleList;

            detailRuleList = new List<DetailRule__c>
            {
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Name,OEMPartNumber__c,OEMKey__c ,OEMManufacturer__c,IAMPublicPrice__c,ActiveForSubstitution__c,IAMManufacturer__c,IAMPartClass__c,IAMPartDescription__c,IAMPartNumber__c,ASPublicPrice__c,IAMCertifyingOrganization__c,OEMCleanPartNumber__c,ASNetPrice__c,OEMPartDescription__c', null, null, 'Primary Fields Needed', 'CrossReference__c', 1),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'OEMCleanPartNumber__c-OEMManufacturer__c', null, null, 'Key Field', 'CrossReference__c', 2),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'ASPublicPrice__c', 'MIN', null, 'Criteria', 'CrossReference__c', 3),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'SelectedByBS__c', 'EQUALS', 'TRUE', 'Update Field', 'PartList__c', 4),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'RecommendedByAS__c', 'EQUALS', 'TRUE', 'Update Field', 'PartList__c', 5)
            };

            insert detailRuleList;
        }
    }

    @isTest static void runSubstitution_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","TransactionID":"12345","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,TransactionId__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(1, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(2, assessmentCreatedList[0].PartsLists__r.size());
            System.assertEquals(false, assessmentCreatedList[0].PartsLists__r[1].SelectedByBS__c);
            System.assertEquals('12345', assessmentCreatedList[0].TransactionId__c);
        }
    }

    @isTest static void noAccountRefFound_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"TESTAAA","TransactionID":"12345","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.assertEquals(true, jsonResponseString.contains('Error: No Account Reference Mapping found'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,TransactionId__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(0, assessmentCreatedList.size());
            //System.assertEquals('12345', assessmentCreatedList[0].TransactionId__c);

        }
    }

    //@isTest static void noCarMappingFound_TEST()
    //{
    //    System.runAs(adminUser)
    //    {
    //        String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"M111"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

    //        RestRequest request         = new RestRequest();
    //        request.httpMethod          = 'POST';
    //        request.requestURI          = '/v1.0/runSubstitution/*';
    //        request.requestBody         = Blob.valueOf(requestJSONString);

    //        RestContext.request         = request;
    //        RestContext.response        = new RestResponse();

    //        Test.startTest();
    //            RESTrunSubstitution.runSubstitution();
    //        Test.stopTest();

    //        Blob jsonBlob               = RestContext.response.responseBody;

    //        System.assertNotEquals(null, jsonBlob);

    //        String jsonResponseString   =  jsonBlob.toString();

    //        System.assertEquals(true, jsonResponseString.contains('Error: No Car Mapping found'));

    //        List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
    //                                                            EntityCode__c, Manufacturer__c, VINCheck__c,
    //                                                            (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
    //                                                             FROM   PartsLists__r)
    //                                                     FROM   Assessment__c
    //                                                     WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

    //        System.assertEquals(0, assessmentCreatedList.size());
    //    }
    //}

    @isTest static void runSubstitutionWithMultipleAssessment_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","TransactionID":"12345","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessmentNumber2","TransactionID":"123456","EntityCode":"299","Name":"ABTTEST002","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1291","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"RE1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[1].Name.substringAfter('-') + '"}},{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessmentNumber3","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,TransactionId__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c IN ('runSubsNewAssessment', 'runSubsNewAssessmentNumber2', 'runSubsNewAssessmentNumber3')];

            System.assertEquals(3, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(accountList[1].Id, assessmentCreatedList[1].BodyShop__c);
            System.assertEquals(accountList[0].Id, assessmentCreatedList[2].BodyShop__c);
            System.assertEquals('12345', assessmentCreatedList[0].TransactionId__c);
            System.assertEquals('123456', assessmentCreatedList[1].TransactionId__c);
            System.assertEquals(null, assessmentCreatedList[2].TransactionId__c);


            
            for(Assessment__c assessment : assessmentCreatedList)
            {
                System.assertEquals(2, assessment.PartsLists__r.size());
            }
        }
    }

    //@isTest static void runSubstitutionWithMatchingAssessmentId_TEST()
    //{
    //    System.runAs(adminUser)
    //    {
    //        Assessment__c duplicateAssessment   = TestFactory.createAssessment('Assessment_ES', accountList[0]);
    //        duplicateAssessment.AssessmentNumber__c = 'test';
    //        duplicateAssessment.AssessmentID__c = assessmentList[0].AssessmentID__c + '-1';
    //        insert duplicateAssessment;

    //        String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"' + assessmentList[0].AssessmentNumber__c + '","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1291","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"RE1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

    //        RestRequest request         = new RestRequest();
    //        request.httpMethod          = 'POST';
    //        request.requestURI          = '/v1.0/runSubstitution/*';
    //        request.requestBody         = Blob.valueOf(requestJSONString);

    //        RestContext.request         = request;
    //        RestContext.response        = new RestResponse();

    //        Test.startTest();
    //            RESTrunSubstitution.runSubstitution();
    //        Test.stopTest();

    //        Blob jsonBlob               = RestContext.response.responseBody;

    //        System.assertNotEquals(null, jsonBlob);

    //        String jsonResponseString   =  jsonBlob.toString();

    //        System.debug('## jsonResponseString: ' + jsonResponseString);

    //        System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

    //        List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c, AssessmentID__c,
    //                                                            EntityCode__c, Manufacturer__c, VINCheck__c,
    //                                                            (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
    //                                                             FROM   PartsLists__r)
    //                                                     FROM   Assessment__c
    //                                                     //WHERE  AssessmentID__c =: assessmentList[0].AssessmentID__c + '-2'];
    //                                                     where AssessmentNumber__c = 'test' order by createdDate DESC limit 1];
    //                                                     system.debug('## assessId: '+assessmentCreatedList[0].AssessmentID__c);

    //        System.assertEquals(1, assessmentCreatedList.size());
    //        System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
    //        System.assertEquals(2, assessmentCreatedList[0].PartsLists__r.size());
    //        System.assertEquals(true, assessmentCreatedList[0].PartsLists__r[1].SelectedByBS__c);
    //    }
    //}

    @isTest static void runSubstitutionWithMultipleSubstitution_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1293","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(1, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(3, assessmentCreatedList[0].PartsLists__r.size());
        }
    }

    @isTest static void runSubstitutionWithAssessmentMissingFields_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Exceptions: Missing fields:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void runSubstitutionWithMissingPartNumber_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13"},"currentBodyShop":{"ReferenceNumberaa":""}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Exceptions: Missing fields:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void runSubstitutionWithOneSuccessAndOneFailure_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}, {"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment1","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Exceptions: Missing fields:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c IN ('runSubsNewAssessment', 'runSubsNewAssessment1')];

            System.assertEquals(1, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(2, assessmentCreatedList[0].PartsLists__r.size());
            System.assertEquals(false, assessmentCreatedList[0].PartsLists__r[1].SelectedByBS__c);
        }
    }

    @isTest static void runSubstitutionWithFlowException_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":"0a","Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void runSubstitutionWithInvalidBodyShopId_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[3].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(true, jsonResponseString.contains(Label.Error));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void runSubstitutionWithIAMPartDescAndASPriceNull_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1295","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment'];

            System.assertEquals(1, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(2, assessmentCreatedList[0].PartsLists__r.size());
            System.assertEquals(false, assessmentCreatedList[0].PartsLists__r[1].SelectedByBS__c);
        }
    }

    @isTest static void runSubstitutionWithIAMPartDescAndASPriceNullAndIAMPriceNull_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment2543543","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1296","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            /*System.assertNotEquals(null, jsonBlob);*/

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            /*System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));*/

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c = 'runSubsNewAssessment2543543'];

            /*System.assertEquals(1, assessmentCreatedList.size());
            System.assertEquals(accountList[0].Id, assessmentCreatedList[0].BodyShop__c);
            System.assertEquals(1, assessmentCreatedList[0].PartsLists__r.size());
            System.assertEquals(false, assessmentCreatedList[0].PartsLists__r[0].SelectedByBS__c);*/
        }
    }

    @isTest static void runSubstitutionWithLengthOver30000_TEST()
    {
        System.runAs(adminUser)
        {
            String requestJSONString    = '[{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment1","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment2","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment3","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment4","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment5","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment6","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment7","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment8","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment9","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment10","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment11","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment12","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment13","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment14","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment15","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment16","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment17","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment18","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment19","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment20","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment21","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment22","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment23","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment24","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment25","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment26","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment27","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment28","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment29","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment30","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment31","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment32","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment33","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment34","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment35","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment36","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment37","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment38","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment39","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment40","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment41","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment42","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment43","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment44","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment45","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment46","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment47","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment48","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment49","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment50","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment51","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment52","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment53","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment54","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment55","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment56","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}},' +
                                            '{"callerSystem":"GTMOTIVE","AssessmentNumber":"runSubsNewAssessment57","EntityCode":"299","Name":"ABTTEST001","VINCheck":0,"Parts":[{"Description":"Front Left Grille","Name":"FRONT LWR AIR GRILLE","PartNumber":"A10 11 1290","Price":58,"Manufacturer":"BOSH","Quantity":10,"RecordType":"Material","Type":"A","Compliance":true,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"FirstRegistrationDate":"2015-04-13","Brand":"MB1"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') + '"}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/runSubstitution/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTrunSubstitution.runSubstitution();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            System.debug('## jsonResponseString: ' + jsonResponseString);

            System.assertEquals(false, jsonResponseString.contains('ErrorMessage'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c,
                                                                (SELECT Id, Name, SelectedByBS__c, RecommendedByAS__c, OriginalPart__c
                                                                 FROM   PartsLists__r)
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'runSubsNewAssessment%'];

            System.assertEquals(58, assessmentCreatedList.size());
        }
    }
}