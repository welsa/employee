/*
----------------------------------------------------------------------
-- - Name          : AP34BundleGeneration_TEST
-- - Author        : ABT
-- - Description   : Test class for AP34BundleGeneration
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 11-APR-2017  ABT     1.0         Initial version
-- 18-SEP-2020  KPA     1.1         C-003930 : Test Classes IG
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class AP35R4SendPurchaseOrderEmail_TEST
{
	static User adminUser;
	static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
	
	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES'),
                    
                TestFactory.createAccountBodyshop('BodyShop_3', 'DE'),
				TestFactory.createAccountDistributor('Distributor_3', 'DE')
			};

			accountList[0].ContactUser__c = adminUser.Id;
			accountList[1].ContactUser__c = adminUser.Id;

			accountList[4].ContactUser__c = adminUser.Id;
			accountList[5].ContactUser__c = adminUser.Id;
            
            
			accountList[1].DistributorConnected__c=True; 
            
            
			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR_Quotation', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_Order', accountList[0]),
                TestFactory.createAssessment('Assessment_FR_Order1', accountList[0])
			};

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

			assessmentList[0].OrderOrigin__c = 'Quotation';
             assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            
			assessmentList[1].OrderOrigin__c = 'Order';

			assessmentList[0].RecordTypeId = claimOrderId;
			assessmentList[1].RecordTypeId = claimOrderId;

            assessmentList[1].InsuranceBroker__c = 'IG';
            
            assessmentList[2].TECH_EntityCountryCode__c = 'DE';

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			salesOrderList[0].OfferType__c = null;
			salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				// Quotation
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_RESPONDED),
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_RESPONDED),

				// Order
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
                    
                TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[0], accountList[4], accountList[5], 'PREDRAFTQUOTE')
                    
			};

			insert purchaseOrderList;


			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

			/********************* PO1 **************************************/
			// final original
			orderLineList[0].OrderType__c					= 'FINAL';
			orderLineList[0].PartNumber__c					= '00000001';
			orderLineList[0].ExpectedDeliveryDuration__c	= '1';
			orderLineList[0].Suppliable__c					= 'YES';

			// final original
			orderLineList[1].OrderType__c					= 'FINAL';
			orderLineList[1].PartNumber__c					= '00000002';
			orderLineList[1].ExpectedDeliveryDuration__c	= '1';
			orderLineList[1].Suppliable__c					= 'YES';

			/********************* PO2 **************************************/
			// final original
			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].Manufacturer__c				= 'test manufacturer';
			orderLineList[2].ExpectedDeliveryDuration__c	= '1';

			// final original
			orderLineList[3].OrderType__c					= 'FINAL';
			orderLineList[3].PartNumber__c					= '00000004';
			orderLineList[3].Manufacturer__c				= 'test manufacturer';
			orderLineList[3].ExpectedDeliveryDuration__c	= '1';

			/********************* PO3 **************************************/
			// final original
			orderLineList[4].OrderType__c					= 'FINAL';
			orderLineList[4].PartNumber__c					= '00000005';
			orderLineList[4].Manufacturer__c				= 'test manufacturer';
			orderLineList[4].ExpectedDeliveryDuration__c	= '1';

			// final original
			orderLineList[5].OrderType__c					= 'FINAL';
			orderLineList[5].PartNumber__c					= '00000006';
			orderLineList[5].Manufacturer__c				= 'test manufacturer';
			orderLineList[5].ExpectedDeliveryDuration__c	= '1';

			/********************* PO4 **************************************/
			// final original
			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].Manufacturer__c				= 'test manufacturer';
			orderLineList[6].ExpectedDeliveryDuration__c	= '1';

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].Manufacturer__c				= 'test manufacturer';
			orderLineList[7].ExpectedDeliveryDuration__c	= '1';

			insert orderLineList;
		}
	}

	@isTest static void insertQuotationPO()
	{
		System.runAs(adminUser)
		{
			List<PurchaseOrder__c> quotationPOToInsertList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			Test.startTest();
				insert quotationPOToInsertList;
			Test.stopTest();

			System.assertNotEquals(null, AP35R4SendPurchaseOrderEmail.emailResultList);
			System.assertEquals(2, AP35R4SendPurchaseOrderEmail.emailResultList.size());
		}
	}

	@isTest static void updateQuotationPOToInDelivery()
	{
		System.runAs(adminUser)
		{
			List<PurchaseOrder__c> quotationPOToUpdateList = new List<PurchaseOrder__c>
			{
				purchaseOrderList[0],
				purchaseOrderList[1]
			};

			quotationPOToUpdateList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
			quotationPOToUpdateList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;

			Test.startTest();
				update quotationPOToUpdateList;
			Test.stopTest();

			System.assertNotEquals(null, AP35R4SendPurchaseOrderEmail.emailResultList);
			System.assertEquals(2, AP35R4SendPurchaseOrderEmail.emailResultList.size());
		}
	}

	@isTest static void updateOrderPOToDraftQuote()
	{
		System.runAs(adminUser)
		{
			List<PurchaseOrder__c> quotationPOToUpdateList = new List<PurchaseOrder__c>
			{
				purchaseOrderList[2],
				purchaseOrderList[3]
			};

			quotationPOToUpdateList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
			quotationPOToUpdateList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;

			Test.startTest();
				update quotationPOToUpdateList;
			Test.stopTest();

			System.assertNotEquals(null, AP35R4SendPurchaseOrderEmail.emailResultList);
			System.assertEquals(2, AP35R4SendPurchaseOrderEmail.emailResultList.size());
		}
	}
    
    //KPA 17/09/2020 C-003930
    @isTest static void Test123(){
        System.runAs(adminUser){
            List<PurchaseOrder__c> lstPO = new List<PurchaseOrder__c> {
                 purchaseOrderList[2]
				 
                 
                };
               
               lstPO[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
               lstPO[0].DistributorConnected__c=True;
              
               lstPO[0].wsErrorMessage__c='xyz';
        
               
                
             Test.startTest();
            update lstPO;
            Test.stopTest();
    
            System.assertNotEquals(null, AP35R4SendPurchaseOrderEmail.emailResultList);
			System.assertEquals(1, AP35R4SendPurchaseOrderEmail.emailResultList.size());
        }
    }
    //KPA 18/09/2020 C-003930
      @isTest static void TestCountryDE(){
        System.runAs(adminUser){

            
            assessmentList[2].insuranceBroker__c = 'IGTest123';
            assessmentList[2].OrderOrigin__c = 'Order';
            
            update assessmentList;
            PurchaseOrder__c PO = purchaseOrderList[4];  
               
                         
		   PO.Status__c= ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
		  // PO.DistributorConnected__c=True;
           
                     
            Test.startTest();
            	system.debug('@@ start TestCountryDE');
            	update purchaseOrderList;
            
            Test.stopTest();
            
        
            System.debug('~~~~~~~~~ Ass TECH '+assessmentList[2].TECH_EntityCountryCode__c);
            
        
            System.debug('~~~~~~~~~ PO ID'+purchaseOrderList[4].Id);
        }
	}

	//KPA 18/09/2020 C-003930
	@isTest static void TestCountryFR(){
        System.runAs(adminUser){
			
			accountList[5].DistributorConnected__c=False;
			update accountList;
            
            assessmentList[2].insuranceBroker__c = 'IGTest123';
			assessmentList[2].OrderOrigin__c = 'Order';
			assessmentList[2].TECH_EntityCountryCode__c = 'FR';
            
            update assessmentList;
            PurchaseOrder__c PO = purchaseOrderList[4];  
               
                         
		   PO.Status__c= ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
		   PO.DistributorConnected__c=False;
           
                     
            Test.startTest();
            	
            	update purchaseOrderList;
            
            Test.stopTest();
            
        
            System.debug('~~~~~~~~~ Ass TECH '+assessmentList[2].TECH_EntityCountryCode__c);
            
        
           
        }
	}
                   
    //KPA 18/09/2020 C-003930
	@isTest static void TestCountryBE(){
        System.runAs(adminUser){
                 
			adminUser.LanguageLocaleKey='fr_BE';
			update adminUser;
                     
			accountList[5].DistributorConnected__c=False;
			update accountList;
                  
            assessmentList[2].insuranceBroker__c = 'IGTest123';
			assessmentList[2].OrderOrigin__c = 'Order';
			assessmentList[2].TECH_EntityCountryCode__c = 'BE';
                    
            update assessmentList;
            PurchaseOrder__c PO = purchaseOrderList[4];  
             
             
		   PO.Status__c= ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
		   PO.DistributorConnected__c=False;
             
                
             Test.startTest();
            	
            	update purchaseOrderList;
            
            Test.stopTest();
            
        
			System.debug('~~~~~~~~~ Ass TECH '+assessmentList[2].TECH_EntityCountryCode__c);
			System.debug('~~~~~~~~~~~~~~~User.LanguageLocaleKey '+adminUser.LanguageLocaleKey);
			System.debug('~~~~~~~~~~~~~~~currentPurchaseOrder.DistributorContact__r.LanguageLocaleKey '+PO.DistributorContact__r.LanguageLocaleKey);
            
        
           
        }
    }
	



//Order error reported

//KPA 18/09/2020 C-003930
@isTest static void TestOrderErrorReport(){
	System.runAs(adminUser){

		
		
		accountList[5].DistributorConnected__c=True;
		update accountList;
		
		assessmentList[2].insuranceBroker__c = 'IGTest123';
		assessmentList[2].OrderOrigin__c = 'Order';
		assessmentList[2].TECH_EntityCountryCode__c = 'FR';
		
		update assessmentList;
		PurchaseOrder__c PO = purchaseOrderList[4];  
		   
					 
	   PO.Status__c= ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
	   PO.DistributorConnected__c=True;
	   PO.wsErrorMessage__c='Order error reported';
	   
				 
		Test.startTest();
			
			update purchaseOrderList;
		
		Test.stopTest();
		
	
		
	
	   
	}
}

   


}