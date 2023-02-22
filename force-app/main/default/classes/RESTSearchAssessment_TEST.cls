@isTest
public with sharing class RESTSearchAssessment_TEST {
/*************************************************************************************
Class Name - RESTSearchAssessment_TEST
Version - 1.0
Created Date - 15 SEP 2020
Function - Class to order

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L   		15/09/2020  Original Version
*************************************************************************************/

    // List And Map
    static List<Account> lstAccount;
    static List<Assessment__c> lstAssessment;
    static List<PartList__c> lstPartListClaim;
    static List<PartList__c> lstPartListClaimOrder;

    // user
    static User adminUser;

    static List<AccountRef__c> accountRefList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static list <PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;

    static List<DirectOrder__c> directOrderList;

    static BusinessHours defaultHours;
    
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;


    static{

        adminUser = new User(Username = 'testAdminUser986@gmail.com',
                            LastName = 'Doe',
                            FirstName = 'John',
                            LanguageLocaleKey = 'en_US',
                            Email = 'testAdminUser@gmail.com',
                            Alias = 'ARA',
                            TimeZoneSidKey = 'Europe/Berlin',
                            LocaleSidKey = 'en_US',
                            IsActive = true,
                            ProfileId = ASPISConstants.getProfileAdminId(),
                            EmailEncodingKey = 'UTF-8'
                            );

        insert adminUser;
        
        System.runAs(adminUser){

            //Creating Account

            lstAccount= new List<Account>
            {
                TestFactory.createAccountBodyshop('BS_1', 'DE'),
                TestFactory.createAccountDistributor('Distributor_1', 'DE'),
                
                TestFactory.createAccountBodyshop('BS_2', 'DE'),
                TestFactory.createAccountDistributor('Distributor_2', 'DE'),

                TestFactory.createAccountBodyshop('BS_3', 'DE'),
                TestFactory.createAccountDistributor('Distributor_3', 'DE'),
                
                TestFactory.createAccountBodyshop('BS_4', 'DE'),
                TestFactory.createAccountDistributor('Distributor_4', 'DE')

                
            };
            lstAccount[3].OrderRequest__c = 'OrderR4';
            lstAccount[3].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');
            lstAccount[3].ConnectedEndtoEnd__c = true;
            lstAccount[3].Tech_Distributor__c = 'COLER';
            lstAccount[3].Tech_ATConfirmed__c = 'Available';
            lstAccount[3].Tech_ATConfirmedWithDelay__c = 'Available';
            lstAccount[3].Tech_ATPartial__c = 'Unavailable';
            lstAccount[3].Tech_ATNotFound__c = 'Unavailable';
            lstAccount[3].Tech_ATOther__c = 'Unavailable';
            lstAccount[2].DistributorConnected__c = true;

            lstAccount[3].PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48_48}';
            

            insert lstAccount;

            directOrderList = new list<DirectOrder__c> {
                TestFactory.createDirectOrder(lstAccount[2].Id,lstAccount[3].Id)

            };
            directOrderList[0].Part_Type__c ='A';
            insert directOrderList;

            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DE', defaultHours.Id)
			};

			insert countryCodeMappingList;
            

                // recordType
                Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
                Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();	

                //Creating Assessment

                lstAssessment =new List<Assessment__c> 

            {
                TestFactory.createAssessment('Assessment_DE01', lstAccount[2]),
                TestFactory.createAssessment('Assessment_DE02', lstAccount[2]),
                TestFactory.createAssessment('Assessment_DE03', lstAccount[4]),
                TestFactory.createAssessment('Assessment_DE04', lstAccount[2])
                    
                
            };

            //countrycode
            lstAssessment[0].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[1].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[2].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[3].TECH_EntityCountryCode__c = 'DE';

            //AssessmentID__c
            lstAssessment[0].AssessmentID__c = 'DEIG'+lstAssessment[0].AssessmentNumber__c;
            lstAssessment[1].AssessmentID__c = 'DEIG'+lstAssessment[1].AssessmentNumber__c;
            lstAssessment[2].AssessmentID__c = 'DEIG'+lstAssessment[2].AssessmentNumber__c;
            lstAssessment[3].AssessmentID__c = 'DEIG'+lstAssessment[3].AssessmentNumber__c;

            //entitycode

            lstAssessment[0].EntityCode__c ='IG';
            lstAssessment[1].EntityCode__c ='IG';
            lstAssessment[2].EntityCode__c ='5515';
            lstAssessment[3].EntityCode__c ='IG';

            //entityrules

            lstAssessment[0].EntityRules__c='DEIG';
            lstAssessment[1].EntityRules__c='DEIG';
            lstAssessment[2].EntityRules__c='DE5515';
            lstAssessment[3].EntityRules__c='DEIG';

            //orderorigin

            lstAssessment[1].OrderOrigin__c='Order';
            lstAssessment[2].OrderOrigin__c='Order';
            


            //PlateNumber
            lstAssessment[0].PlateNumber2__c = 'AR777';
            lstAssessment[1].PlateNumber2__c = '0101MR2020';
            lstAssessment[2].PlateNumber2__c = '0101MR2020';
            lstAssessment[3].PlateNumber2__c = '4503MR2020';

            //insurancebroker
            lstAssessment[1].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[2].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[3].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[0].InsuranceBroker__c= system.label.InsBrokerName;

             //InsBrokerNumber__c
             lstAssessment[1].InsBrokerNumber__c= 'IG123';
             lstAssessment[2].InsBrokerNumber__c= 'IG123';
             lstAssessment[3].InsBrokerNumber__c= 'IG1234';
             lstAssessment[0].InsBrokerNumber__c= 'IG1234';

             lstAssessment[3].AssessmentExternalId__c= 'IG1234';
             lstAssessment[0].AssessmentExternalId__c= 'IG1234';

             lstAssessment[3].AssessmentVersion__c= 2;
             lstAssessment[0].AssessmentVersion__c= 1;

             //InsBrokerNumber__c
             lstAssessment[1].VINNumber__c= '12345';
             lstAssessment[2].VINNumber__c= '12345';
             lstAssessment[3].VINNumber__c= '12345';
             lstAssessment[0].VINNumber__c= '123458';



            lstAssessment[0].RecordTypeId 		= claimRecordTypeId;
            lstAssessment[1].RecordTypeId 		= claimRecordTypeId;
            lstAssessment[2].RecordTypeId 		= claimRecordTypeId;
            lstAssessment[3].RecordTypeId 		= claimRecordTypeId;


            lstAssessment[1].CapturedDistributors__c = 'P0-'+lstAccount[3].Id;
            lstAssessment[1].Tech_DirectOrders__c = directOrderList[0].Id;
            lstAssessment[1].MREligibility__c = true;
            lstAssessment[1].FirstRegistrationDate__c = Date.today();


            insert lstAssessment;

            // lstAssessment[1].ParentAssessment__c = lstAssessment[0].Id;
            // // lstAssessment[0].ParentAssessment__c = lstAssessment[2].Id;// cannot be linked to claim

            // lstAssessment[1].Comment__c = 'TEst';
            // lstAssessment[1].OrderOrigin__c = 'Legacy';


            // update lstAssessment;

            // create partList
            lstPartListClaim =new List<PartList__c>
            {
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[2]),
                TestFactory.createPartList(lstAssessment[3]),
                TestFactory.createPartList(lstAssessment[3]),
                TestFactory.createPartList(lstAssessment[3])
                
            };

            lstPartListClaim[3].SelectedByBS__c  = true;
            lstPartListClaim[4].SelectedByBS__c  = true;
            lstPartListClaim[5].SelectedByBS__c  = true;
            lstPartListClaim[6].SelectedByBS__c  = true;
            lstPartListClaim[7].SelectedByBS__c  = true;
            lstPartListClaim[8].SelectedByBS__c  = false;

            lstPartListClaim[3].TECH_OriginalPart__c  = 'abc1';
            lstPartListClaim[4].TECH_OriginalPart__c  = 'abc2';
            lstPartListClaim[5].TECH_OriginalPart__c  = 'abc3';
            lstPartListClaim[6].TECH_OriginalPart__c  = 'abc4';
            lstPartListClaim[7].TECH_OriginalPart__c  = 'abc5';

            lstPartListClaim[3].Type__c  = 'A';
            lstPartListClaim[4].Type__c  = 'A';
            lstPartListClaim[5].Type__c  = 'A';
            lstPartListClaim[6].Type__c  = 'A';
            lstPartListClaim[7].Type__c  = 'A';

            insert lstPartListClaim;

            lstPartListClaim[6].Alpha_Scale_MRID__c = 'IGO-1234';
            lstPartListClaim[6].OriginalPart__c = lstPartListClaim[8].Id;

            update lstPartListClaim[6];

            // // create partList
            // lstPartListClaimOrder =new List<PartList__c>
            // {
            //     TestFactory.createPartList(lstAssessment[1]),
            //     TestFactory.createPartList(lstAssessment[1]),
            //     TestFactory.createPartList(lstAssessment[1])

            // };
            // lstPartListClaimOrder[0].OriginalPart__c = lstPartListClaim[0].Id;
            // lstPartListClaimOrder[1].OriginalPart__c = lstPartListClaim[1].Id;
            // lstPartListClaimOrder[2].OriginalPart__c = lstPartListClaim[2].Id;

            // insert lstPartListClaimOrder;

            system.debug('@@@ lstAccount: '+lstAccount);

            accountRefList = new List<AccountRef__c>{
                //TestFactory.createAccountRef('2763223904', accountList[0].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('IG123', lstAccount[2].Id, 'DE_IG'),
                TestFactory.createAccountRef('2763223906', null, 'DIVA')
                // TestFactory.createAccountRef('2763223907', accountList[2].Id, 'DIVA'),
                // TestFactory.createAccountRef('2763223904', accountList[2].Id, 'FR_DIVA'),
                // TestFactory.createAccountRef('404483367', accountList[6].Id, 'BE_INFORMEX'),
                // TestFactory.createAccountRef('18690', accountList[7].Id, 'BE_INFORMEX')

            };

            insert accountRefList;
            system.debug('@@@ accountRefList: '+accountRefList);

            //creating SO
            // salesOrderList = new list <PrerequisiteOrder__c>{
            //     TestFactory.createSalesOrder(lstAssessment[1], lstAccount[2], '')};
            
            // salesOrderList[0].BodyShopOrderNumber__c = '1234';
            // salesOrderList[0].Status__c = 'PREACCEPTANCE';

            // insert salesOrderList; 
        
            // //creating PO
            // purchaseOrderList = new list <PurchaseOrder__c>{
            //     TestFactory.createPurchaseOrder(lstAssessment[1], salesOrderList[0], lstAccount[2], lstAccount[3], '')};

            // purchaseOrderList[0].Status__c = 'DRAFTQOUTE';

            // insert purchaseOrderList;  

            // // Generating Order Line
            // orderLineList = new List<OrderLine__c>
            // {
            //     TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
            //     TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
            //     TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY')

            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY')
            // };
            // insert orderLineList;
            
            // offerList = new List<Offer__c>
            // {
            //     TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
            //     TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
            //     TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS)
            //     // TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], 'INDELIVERY'),

            //     // TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], 'INDELIVERY'),
            //     // TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], 'INDELIVERY')
            // };
            // insert offerList;

        }
            
    }

    @isTest static void searchAssessMandatoryFieldsKO(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"123456","AssessmentID":"","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessNoBS(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"123456","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"Sidexa"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }


    @isTest static void searchAssessNointRef(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"123456","AssessmentID":"","BSReferenceNumber":"2763223906","callerSystem":"DIVA"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyInsBrokerNumber(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"IG123","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyPlate(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"0101MR2020","VIN":"","InsBrokerNumber":"","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyVin(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"12345","InsBrokerNumber":"","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyVinAndPlate(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"0101MR2020","VIN":"12345","InsBrokerNumber":"","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessNoQuery(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessInvalidJson(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"""VIN":"","InsBrokerNumber":"","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyInsBrokerNumberVersions(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"IG1234","AssessmentID":"","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void searchAssessbyAssessId(){
        System.runAs(adminUser) {

            String requestJSONString    = '{"Plate":"","VIN":"","InsBrokerNumber":"","AssessmentID":"'+lstAssessment[1].AssessmentID__c+'","BSReferenceNumber":"IG123","callerSystem":"DE_IG"}';

            string jsonResponse = '{"ClaimReference":"","Request":"DRAFT","Distributors":{"COLER":{"ExternalOrderReference":"","Lines":[{"ID":"abc1-null-1","Quantity":1,"PartNumber":"6999G9","Type":"A","Manufacturer":"Peugeot","Description":"Bef Schild Vo","CatalogPrice":17.28,"AlphaScaleDiscount":0.0,"BodyShopDiscount":0.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"abc2-null-1","Quantity":1,"PartNumber":"6438E4","Type":"A","Manufacturer":"Peugeot","Description":"Satz Kappe","CatalogPrice":106.54,"AlphaScaleDiscount":0.0,"BodyShopDiscount":0.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"abc3-null-1","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":65.87,"AlphaScaleDiscount":0.0,"BodyShopDiscount":0.0,"Status":"PARTIAL","Bundle":false,"DeliveryDays":"1"},{"ID":"abc4-null-1","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":65.87,"AlphaScaleDiscount":0.0,"BodyShopDiscount":0.0,"Status":"NOTFOUND","Bundle":false,"DeliveryDays":"1"},{"ID":"abc5-null-1","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":65.87,"AlphaScaleDiscount":0.0,"BodyShopDiscount":0.0,"Status":"OTHER","Bundle":false,"DeliveryDays":"1"}],"Success":"true"},"NORA":{"Success":"false","Message":"500 - Internal Server Error"}},"BodyShop":{"VATNumber":"DE253475183","Name":"Car Top Zentrum Stuttgart","ExternalReference":"DE22628"},"Vehicle":{"VinNumber":"VF32D9HZA44782784","PlateNumber":"OGSW7404","Model":"206 CC (2D) Cabrio ab 09/00-04/07 [11]","FirstRegistrationDate":"2005-08-01","Brand":"Peugeot"}}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/searchAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK', jsonResponse)); 

            RESTSearchAssessment.searchAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }


    public class MockSearchAssess implements HttpCalloutMock {

        protected Integer code;
        protected String status;
        protected String body;

        public MockSearchAssess(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            
                HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
                return res;
            
        }
    }


}