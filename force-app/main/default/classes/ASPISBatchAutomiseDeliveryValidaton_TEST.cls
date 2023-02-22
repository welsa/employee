/*************************************************************************************
Class Name - ASPISBatchAutomiseDeliveryValidaton_TEST
Version - 1.0
Created Date - 26 Feb 2016
Function -  test class for batch ASPISBatchAutomiseDeliveryValidaton

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga U             	29/02/2016  Original Version
* Ashutosh B           	23/01/2017  Reworked test class to have alternatives and bundles
* Welsa C             	14/04/2021  add for ASPISBatchAutomiseDeliveryValidaton_C
*************************************************************************************/
@isTest
private class ASPISBatchAutomiseDeliveryValidaton_TEST
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

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
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};
			accountList[0].BillingCity='Nimes';
			accountList[0].BillingCountry='France';
			accountList[0].BillingStreet='st martin de chez yvone';
			accountList[0].BillingPostalCode='12345';

			accountList[2].BillingCity='Nimes';
			accountList[2].BillingCountry='France';
			accountList[2].BillingStreet='st martin 2de chez yvone';
			accountList[2].BillingPostalCode='12345';
			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], 'INDELIVERY'),
				TestFactory.createSalesOrder(assessmentList[1], accountList[2], 'INDELIVERY')
			};

			salesOrderList[0].SLAInDeliveryLevel3__c = System.today();
			salesOrderList[1].SLAInDeliveryLevel3__c = System.today();

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], 'INDELIVERY'),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], 'INDELIVERY')
			};

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY')
			};

			// Setting the new order line orderType as original
			// Only original
			orderLineList[0].OrderType__c					= 'ORIGINAL';
			orderLineList[0].PartNumber__c					= '00000001';
			orderLineList[0].Suppliable__c					= 'NO';

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';
			orderLineList[1].Suppliable__c					= 'YES';

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].Suppliable__c					= 'YES';

			// original + bundle
			orderLineList[3].OrderType__c					= 'ORIGINAL';
			orderLineList[3].PartNumber__c					= '00000004';
			orderLineList[3].Suppliable__c					= 'YES';

			orderLineList[4].OrderType__c					= 'BUNDLEITEM';
			orderLineList[4].PartNumber__c					= '00000005';
			orderLineList[4].Suppliable__c					= 'YES';

			orderLineList[5].OrderType__c					= 'BUNDLEITEM';
			orderLineList[5].PartNumber__c					= '00000006';
			orderLineList[5].Suppliable__c					= 'YES';

			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].Suppliable__c					= 'YES';

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].Suppliable__c					= 'NO';

			/********************* PO2 **************************************/
			// Only original
			orderLineList[8].OrderType__c					= 'ORIGINAL';
			orderLineList[8].PartNumber__c					= '00000001';
			orderLineList[8].Manufacturer__c				= 'test manufacturer';
			orderLineList[8].Suppliable__c					= 'NO';

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].Manufacturer__c				= 'test manufacturer';

			// original + bundle
			orderLineList[12].OrderType__c					= 'ORIGINAL';
			orderLineList[12].PartNumber__c					= '00000004';
			orderLineList[12].Manufacturer__c				= 'test manufacturer';

			orderLineList[11].OrderType__c					= 'BUNDLEITEM';
			orderLineList[11].PartNumber__c					= '00000005';
			orderLineList[11].Manufacturer__c				= 'test manufacturer';

			orderLineList[13].OrderType__c					= 'BUNDLEITEM';
			orderLineList[13].PartNumber__c					= '00000006';
			orderLineList[13].Manufacturer__c				= 'test manufacturer';

			orderLineList[14].OrderType__c					= 'FINAL';
			orderLineList[14].PartNumber__c					= '00000007';
			orderLineList[14].Manufacturer__c				= 'test manufacturer';

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].Suppliable__c					= 'NO';


			insert orderLineList;

			// Changing order line to bundles
			orderLineList[2].OriginalItem__c	= orderLineList[1].Id;
            orderLineList[4].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[5].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[6].OriginalItem__c	= orderLineList[3].Id;

			// Changing order line to bundles
			orderLineList[9].OriginalItem__c	= orderLineList[10].Id;
            orderLineList[11].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[13].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[14].OriginalItem__c	= orderLineList[12].Id;

			update orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], 'INDELIVERY'),

				TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], 'INDELIVERY')
			};


			offerList[0].Suppliable__c		= true;
			offerList[0].Accepted__c		= 'YES';
			offerList[0].Type__c			= 'QUICK';
			offerList[1].Suppliable__c		= true;
			offerList[1].Accepted__c		= 'YES';
			offerList[1].Type__c			= 'QUICK';
			offerList[2].Suppliable__c		= true;
			offerList[2].Accepted__c		= 'YES';
			offerList[2].Type__c			= 'QUICK';
			offerList[3].Suppliable__c		= true;
			offerList[3].Accepted__c		= 'YES';
			offerList[3].Type__c			= 'QUICK';

			offerList[4].Suppliable__c		= true;
			offerList[4].Accepted__c		= 'YES';
			offerList[4].Type__c			= 'QUICK';
			offerList[5].Suppliable__c		= true;
			offerList[5].Accepted__c		= 'YES';
			offerList[5].Type__c			= 'QUICK';
			offerList[6].Suppliable__c		= true;
			offerList[6].Accepted__c		= 'YES';
			offerList[6].Type__c			= 'QUICK';
			offerList[7].Suppliable__c		= true;
			offerList[7].Accepted__c		= 'YES';
			offerList[7].Type__c			= 'QUICK';

			insert offerList;

			// bundle item offers should be linked to its parent
			offerList[1].ParentOffer__c		= offerList[3].Id;
			offerList[2].ParentOffer__c		= offerList[3].Id;

			offerList[5].ParentOffer__c		= offerList[7].Id;
			offerList[6].ParentOffer__c		= offerList[7].Id;

			update offerList;


			// access Business Hours
            defaultHours = [SELECT	Id
							FROM	BusinessHours
							WHERE	IsDefault = true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			insert countryMappingList;
		}
	}

    @isTest static void ASPISBatchAutomiseDeliveryValidationTest()
	{
		System.runAs(adminUser)
		{
			try{
				Test.startTest();
					Database.executeBatch(new ASPISBatchAutomiseDeliveryValidation(), 200);
				Test.stopTest();

				List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
																	FROM 	PrerequisiteOrder__c
																	WHERE	Id IN: salesOrderList];
				
				for(PrerequisiteOrder__c currentSalesOrder: updatedSalesOrderList)
				{
					System.assertEquals('INVOICED', currentSalesOrder.Status__c);
				}

				List<OrderLine__c> updatedOrderLineList = [	SELECT 	Id, DeliveryStatus__c
															FROM	OrderLine__c
															WHERE	Id IN: orderLineList
															AND		Suppliable__c = 'YES'];
				
				for(OrderLine__c currentOrderLine: updatedOrderLineList)
				{
					System.assertEquals('DELIVERED', currentOrderLine.DeliveryStatus__c);
				}
			}
			catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
				System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
					'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage());
			}
		}
    }

    @isTest static void ASPISBatchAutomiseDeliveryValidationSCHTest() 
	{
       System.runas(adminUser)
	   {
           for(CronTrigger c : [SELECT 	Id 
		   						FROM 	CronTrigger 
								WHERE 	CronJobDetailId IN (SELECT 	Id 
															FROM 	CronJobDetail 
															WHERE 	Name = 'TestAutomiseDeliveryValidation' 
															AND 	JobType = '7')]){
               System.abortJob(c.id);
           }

           ASPISBatchAutomiseDeliveryValidation testAutomiseDeliveryValidation = new ASPISBatchAutomiseDeliveryValidation();
           String sch = '0 0 0 * * ?';

           Test.startTest();
		   system.debug('adminUser>>'+adminUser);
           	System.schedule('TestAutomiseDeliveryValidation', sch, testAutomiseDeliveryValidation);
           Test.stopTest();

           CronTrigger ct = [	SELECT Id, CronExpression, TimesTriggered, NextFireTime 
		   					 	FROM CronTrigger 
								WHERE CronJobDetailId IN (	SELECT 	Id 
															FROM 	CronJobDetail 
															WHERE 	Name = 'TestAutomiseDeliveryValidation' 
															AND 	JobType = '7')];
           
		   System.assertEquals('0 0 0 * * ?', ct.CronExpression);
       }
    }
	@isTest static void ASPISBatchAutomiseDeliveryValidationTest_c()
	{
		System.runAs(adminUser)
		{
			try{
				Test.startTest();
					Database.executeBatch(new ASPISBatchAutomiseDeliveryValidation_c(), 200);
				Test.stopTest();

				List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
																	FROM 	PrerequisiteOrder__c
																	WHERE	Id IN: salesOrderList];
				
				for(PrerequisiteOrder__c currentSalesOrder: updatedSalesOrderList)
				{
					System.assertEquals('INVOICED', currentSalesOrder.Status__c);
				}

				List<OrderLine__c> updatedOrderLineList = [	SELECT 	Id, DeliveryStatus__c
															FROM	OrderLine__c
															WHERE	Id IN: orderLineList
															AND		Suppliable__c = 'YES'];
				
				for(OrderLine__c currentOrderLine: updatedOrderLineList)
				{
					System.assertEquals('DELIVERED', currentOrderLine.DeliveryStatus__c);
				}
			}
			catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
				System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
					'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage());
			}
		}
    }

    @isTest static void ASPISBatchAutomiseDeliveryValidationSCHTest_c() 
	{
       System.runas(adminUser)
	   {
           for(CronTrigger c : [SELECT 	Id 
		   						FROM 	CronTrigger 
								WHERE 	CronJobDetailId IN (SELECT 	Id 
															FROM 	CronJobDetail 
															WHERE 	Name = 'TestAutomiseDeliveryValidation' 
															AND 	JobType = '7')]){
               System.abortJob(c.id);
           }

           ASPISBatchAutomiseDeliveryValidation_c testAutomiseDeliveryValidation = new ASPISBatchAutomiseDeliveryValidation_c();
           String sch = '0 0 0 * * ?';

           Test.startTest();
		   system.debug('adminUser>>'+adminUser);
           	System.schedule('TestAutomiseDeliveryValidation', sch, testAutomiseDeliveryValidation);
           Test.stopTest();

           CronTrigger ct = [	SELECT Id, CronExpression, TimesTriggered, NextFireTime 
		   					 	FROM CronTrigger 
								WHERE CronJobDetailId IN (	SELECT 	Id 
															FROM 	CronJobDetail 
															WHERE 	Name = 'TestAutomiseDeliveryValidation' 
															AND 	JobType = '7')];
           
		   System.assertEquals('0 0 0 * * ?', ct.CronExpression);
       }
    }
}