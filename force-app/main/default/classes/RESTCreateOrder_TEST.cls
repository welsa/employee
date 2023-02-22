/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 09-15-2020
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   09-15-2020   ARA   Initial Version
**/
@isTest
public with sharing class RESTCreateOrder_TEST {
   
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


    static{

        adminUser = new User(Username = 'testAdminUser123@gmail.com',
                            LastName = 'Ramkelowan',
                            FirstName = 'Ashutosh',
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
            lstAccount[3].Tech_Distributor__c = 'COLER';
            lstAccount[2].DistributorConnected__c = true;
            

            insert lstAccount;
            

                // recordType
                Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
                Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();	

                //Creating Assessment

                lstAssessment =new List<Assessment__c> 

            {
                TestFactory.createAssessment('Assessment_DE01', lstAccount[0]),
                TestFactory.createAssessment('Assessment_DE02', lstAccount[2]),
                TestFactory.createAssessment('Assessment_DE03', lstAccount[4]),
                TestFactory.createAssessment('Assessment_DE04', lstAccount[6])
                    
                
            };

            //countrycode
            lstAssessment[0].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[1].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[2].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[3].TECH_EntityCountryCode__c = 'DE';

            //AssessmentID__c
            lstAssessment[0].AssessmentID__c = 'DEIG'+lstAssessment[0].AssessmentNumber__c;
            lstAssessment[1].AssessmentID__c = 'DEIG'+lstAssessment[1].AssessmentNumber__c+'-1';
            lstAssessment[2].AssessmentID__c = 'DEIG'+lstAssessment[2].AssessmentNumber__c+'-1';
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
            lstAssessment[2].PlateNumber2__c = '8702MR2020';
            lstAssessment[3].PlateNumber2__c = '4503MR2020';

            //insurancebroker
            lstAssessment[1].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[2].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[3].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[0].InsuranceBroker__c= system.label.InsBrokerName;



            lstAssessment[0].RecordTypeId 		= claimRecordTypeId;
            lstAssessment[1].RecordTypeId 		= claimOrderRecordTypeId;
            lstAssessment[2].RecordTypeId 		= claimOrderRecordTypeId;
            lstAssessment[3].RecordTypeId 		= claimRecordTypeId;

            insert lstAssessment;

            lstAssessment[1].ParentAssessment__c = lstAssessment[0].Id;
            // lstAssessment[0].ParentAssessment__c = lstAssessment[2].Id;// cannot be linked to claim

            lstAssessment[1].Comment__c = 'TEst';
            lstAssessment[1].OrderOrigin__c = 'Legacy';


            update lstAssessment;

            // create partList
            lstPartListClaim =new List<PartList__c>
            {
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[0])
               
            };

            insert lstPartListClaim;

             // create partList
             lstPartListClaimOrder =new List<PartList__c>
             {
                 TestFactory.createPartList(lstAssessment[1]),
                 TestFactory.createPartList(lstAssessment[1]),
                 TestFactory.createPartList(lstAssessment[1])
 
             };
             lstPartListClaimOrder[0].OriginalPart__c = lstPartListClaim[0].Id;
             lstPartListClaimOrder[1].OriginalPart__c = lstPartListClaim[1].Id;
             lstPartListClaimOrder[2].OriginalPart__c = lstPartListClaim[2].Id;
 
             insert lstPartListClaimOrder;

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
            salesOrderList = new list <PrerequisiteOrder__c>{
                TestFactory.createSalesOrder(lstAssessment[1], lstAccount[2], '')};
            
            salesOrderList[0].BodyShopOrderNumber__c = '1234';
            salesOrderList[0].Status__c = 'PREACCEPTANCE';

            insert salesOrderList; 
         
            //creating PO
            purchaseOrderList = new list <PurchaseOrder__c>{
                TestFactory.createPurchaseOrder(lstAssessment[1], salesOrderList[0], lstAccount[2], lstAccount[3], '')};

            purchaseOrderList[0].Status__c = 'DRAFTQOUTE';

            insert purchaseOrderList;  

            // Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinalWithPartList(1000, purchaseOrderList[0],lstPartListClaimOrder[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY')

				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY')
            };
            insert orderLineList;
            
            offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS)
				// TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], 'INDELIVERY'),

				// TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], 'INDELIVERY'),
				// TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], 'INDELIVERY'),
				// TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], 'INDELIVERY'),
				// TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], 'INDELIVERY')
            };
            insert offerList;

        }
            
    }

    @isTest static void createOrderNoBSFound(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DIVA","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BSReferenceNumber":"2763223906","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0]+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1]+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2]+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderBSBlank(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DIVA","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BSReferenceNumber":"IG123","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0]+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1]+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2]+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }


    @isTest static void createOrderMandatoryFieldsKO(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DIVA","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0]+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1]+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2]+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderInvalidJson(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DIVA""Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0]+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1]+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2]+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderMandatoryFieldsKO2(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    ='{"callerSystem":"DE_IG","Assessments":[{"InsBrokerNumber":"IG129C","BSReferenceNumber":"IG123","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0].Id+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1].Id+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2].Id+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderNoAssess(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DE_IG","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"12345","BSReferenceNumber":"IG123","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0].Id+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1].Id+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2].Id+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ lstPartListClaimOrder[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + lstPartListClaimOrder[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ lstPartListClaimOrder[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderNoPartlists(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DE_IG","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BSReferenceNumber":"IG123","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ lstPartListClaimOrder[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + lstPartListClaimOrder[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ lstPartListClaimOrder[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void createOrderOK(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '{"callerSystem":"DE_IG","Assessments":[{"InsBrokerNumber":"IG129C","AssessmentID":"'+lstAssessment[1].AssessmentID__c +'","BSReferenceNumber":"IG123","BodyShopOrderReference":"X123","Comment":"please recheck references based on VIN","Parts":[{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"'+orderLineList[0].Id+'","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"'+orderLineList[1].Id+'","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"'+orderLineList[2].Id+'","Order":false},{"Quantity":1,"PartNumber":"IGP-7LA831055","ID":"a0H5E000004TolYUAS","Order":true},{"Quantity":1,"PartNumber":"IGO-7LA831056","ID":"a0H5E000004TolZUAS","Order":true},{"Quantity":1,"PartNumber":"987831055","ID":"a0H5E000004R5ncUAC","Order":true}]}]}';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v1.0/createOrder/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ lstPartListClaimOrder[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + lstPartListClaimOrder[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ lstPartListClaimOrder[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

            RESTCreateOrder.createOrder();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    // @isTest static void validatePurchaseOrderOK(){
    //     System.runAs(adminUser) {
    //         System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

    //         map<String, Object> mapParams = new map<String, Object>();
    //         mapParams.put()
            

    //         Test.startTest();
    //             RESTCreateOrder.validatePurchaseOrder();
    //         Test.stopTest();

            
    //     }
    // }

    
}