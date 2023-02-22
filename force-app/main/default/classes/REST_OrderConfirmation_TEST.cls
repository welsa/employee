/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 09-14-2020
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-21-2020   ARA   Initial Version
**/
@isTest
public class REST_OrderConfirmation_TEST   {

    static List<Account> lstAccount;
    static List<PurchaseOrder__c> lstPurchaseOrder ;
    static List<Assessment__c> lstAssessment;
    static List<OrderLine__c> lstOrdrLine;
    static List<PrerequisiteOrder__c> lstSalesOrder;
    static List<Offer__c> lstOffer;
    static List<PartList__c> lstPartList;
    static map<String,String> mapOrderConfirmation;
    static  map<String, Object> mapOutParamsCloseAssess;

    // variables
        static Boolean doOrderConfirmation = true;
        static String jsonResponse= ''; 
        static String jsonmessage= ''; 
        static PurchaseOrder__c poToUpdate;
        static String response = '';
        static String responseSimulated;
        static Boolean isSimulation = false;
        static Boolean hasError = false;
        static String wsResponse = null;

    
    static User adminUser;
    
    static
    {
        
        
        adminUser = new User(Username = 'testAdminUser12345@gmail.com',
                             LastName = 'Ramkelowan',
                             FirstName = 'Ashvin',
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

        System.runAs(adminUser)
        {
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
            lstAccount[0].BillingCity='Nimes';
			lstAccount[0].BillingCountry='France';
			lstAccount[0].BillingStreet='st martin 2de chez yvone';
			lstAccount[0].BillingPostalCode='12345';

            lstAccount[2].BillingCity='Nimes';
			lstAccount[2].BillingCountry='France';
			lstAccount[2].BillingStreet='st martin 2de chez yvone';
			lstAccount[2].BillingPostalCode='12345';

            lstAccount[4].BillingCity='Nimes';
			lstAccount[4].BillingCountry='France';
			lstAccount[4].BillingStreet='st martin 2de chez yvone';
			lstAccount[4].BillingPostalCode='12345';

            lstAccount[6].BillingCity='Nimes';
			lstAccount[6].BillingCountry='France';
			lstAccount[6].BillingStreet='st martin 2de chez yvone';
			lstAccount[6].BillingPostalCode='12345';
            

            insert lstAccount;

            // recordType
			Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id newAssessmentRecordTypeId	= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();	

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
			lstAssessment[3].RecordTypeId 		= newAssessmentRecordTypeId;

            insert lstAssessment;

            lstAssessment[0].ParentAssessment__c = lstAssessment[1].Id;
            lstAssessment[0].ParentAssessment__c = lstAssessment[2].Id;// cannot be linked to claim

            update lstAssessment;

            // create partList
            lstPartList =new List<PartList__c>
            {
                TestFactory.createPartList(lstAssessment[0]),
                TestFactory.createPartList(lstAssessment[1]),
                TestFactory.createPartList(lstAssessment[2]),
                TestFactory.createPartList(lstAssessment[3])

            };

            insert lstPartList;
            

            //create SalesOrder
            lstSalesOrder =new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(lstAssessment[1], lstAccount[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[1], lstAccount[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[2], lstAccount[4], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[3], lstAccount[6], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)

                // TestFactory.createSalesOrder(lstAssessment[2], lstAccount[4], 'Eliminated'),
                // TestFactory.createSalesOrder(lstAssessment[3], lstAccount[6], 'InDelivery')

            };

            insert lstSalesOrder;


            //create purchaseOrder
           lstPurchaseOrder = new List<PurchaseOrder__c>
            {

                TestFactory.createPurchaseOrder( lstAssessment[1],lstSalesOrder[0], lstAccount[0], lstAccount[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder( lstAssessment[1],lstSalesOrder[1], lstAccount[2], lstAccount[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder( lstAssessment[2],lstSalesOrder[2], lstAccount[4], lstAccount[5], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder( lstAssessment[3],lstSalesOrder[3], lstAccount[6], lstAccount[7], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)

                
            };

            

            insert lstPurchaseOrder;

            //create Orderline

            lstOrdrLine = new List<OrderLine__c>
            {
                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[0], lstPartList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(400, lstPurchaseOrder[0], lstPartList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(450, lstPurchaseOrder[0], lstPartList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(550, lstPurchaseOrder[0], lstPartList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[1], lstPartList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(600, lstPurchaseOrder[1], lstPartList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(700, lstPurchaseOrder[1], lstPartList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(200, lstPurchaseOrder[1], lstPartList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[2], lstPartList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(670, lstPurchaseOrder[2], lstPartList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(230, lstPurchaseOrder[2], lstPartList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(550, lstPurchaseOrder[2], lstPartList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[3], lstPartList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(560, lstPurchaseOrder[3], lstPartList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(570, lstPurchaseOrder[3], lstPartList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(800, lstPurchaseOrder[3], lstPartList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS)

            };

            lstOrdrLine[1].PartNUmber__c='7464';
            lstOrdrLine[1].Description__c= 'good';
            lstOrdrLine[2].PartNUmber__c='7465';
            lstOrdrLine[2].Description__c= 'good';
            lstOrdrLine[3].PartNUmber__c='7466';
            lstOrdrLine[3].Description__c= 'good';

            insert lstOrdrLine;

            //  create Offer

            lstOffer= new List<Offer__c>
            {
                TestFactory.createOfferLine(lstOrdrLine[0], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[1], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[2], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[3], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[4], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[5], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[6], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[7], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[8], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[9], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[10], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[11], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[12], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[13], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[14], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[15], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS)


            };

            insert lstOffer;



        }

    }
    static testmethod void testStatus(){

        System.runAs(adminUser)
        {
            mapOrderConfirmation = new map<String,String>();
            mapOrderConfirmation.put(lstPurchaseOrder[1].Id,lstPurchaseOrder[1].Name);

            System.debug('@@mapOrderConfirmation'+mapOrderConfirmation);

            lstPurchaseOrder[0].status__c = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
            lstPurchaseOrder[1].status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            lstPurchaseOrder[2].status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVERED;
            lstPurchaseOrder[3].status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;

            lstSalesOrder[0].status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
            lstSalesOrder[1].status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
            lstSalesOrder[2].status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
            lstSalesOrder[3].status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;

            lstPurchaseOrder[1].Reason__c = ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS;
            lstPurchaseOrder[1].AutoValidate_PO__c =false;
            
            System.debug('@@start of update');

            update lstSalesOrder;
            update lstPurchaseOrder;
           
            System.debug('@@ end of update');

            string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Distributors":{"Distributor_ScTest1":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

            Test.startTest();

                System.debug('@@mockcallout start');

                Test.setMock(HttpCalloutMock.class, new JsonMessageresponseMock(200,'OK',jsonResponse));
                REST_OrderConfirmation.sendConfirmation(lstPurchaseOrder[2].Id,lstPurchaseOrder[2].Name);
                
                System.debug('@@mockcallout stop');
            Test.stopTest();
            PurchaseOrder__c Pos =[SELECT status__c FROM PurchaseOrder__c WHERE ID =:lstPurchaseOrder[2].Id];

            System.assertEquals('CLOSEDOK', Pos.status__c);

           
                      
        }
    }
    static testmethod void testcallOutError(){
        lstPurchaseOrder[1].status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
        lstSalesOrder[1].status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
        lstPurchaseOrder[1].Reason__c = ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS;
        lstPurchaseOrder[1].AutoValidate_PO__c =false;
            
            System.debug('@@start of update');

            update lstSalesOrder;
            update lstPurchaseOrder;
           
            System.debug('@@ end of update');

        
        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Distributors":{"Distributor_ScTest1":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';
        
        Test.startTest();

            System.debug('@@mockcallout start');

            Test.setMock(HttpCalloutMock.class, new JsonMessageresponseMock(500,'failed',jsonResponse));
            REST_OrderConfirmation.sendConfirmation(lstPurchaseOrder[1].Id,lstPurchaseOrder[1].Name);
                
            System.debug('@@mockcallout stop');
        Test.stopTest();

        PurchaseOrder__c Pos =[SELECT status__c FROM PurchaseOrder__c WHERE ID =:lstPurchaseOrder[2].Id];

        system.debug('@@POs check: ' +Pos);

        // System.assertEquals('CLOSEDKO', Pos.status__c);

    }
    
}