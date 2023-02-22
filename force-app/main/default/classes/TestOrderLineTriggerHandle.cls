/*************************************************************************************
Class Name - TestOrderLineTriggerHandle
Version - 1.0
Created Date - 13 JUL 2015
Function - test class for OrderLineTriggerHandle

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Hirikesh (sc)         13/07/2015  Original Version
************************************************************************************/
@isTest
private class TestOrderLineTriggerHandle {
/*
	static list<Account> accountsList;
    static list<user> users;
    static list<OrderLine__c> orderLines;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Offer__c> offerList;
    static list<Discount__c> discountList;

    static {
        users = new list<User>{ new User(Username = 'testclass@test.com',
                                        LastName = 'testuser',
                                        LanguageLocaleKey = 'en_US',
                                        FirstName = 'test',
                                        Email = 'test@test.com',
                                        Alias = 'test',
                                        TimeZoneSidKey = 'Europe/Dublin',
                                        LocaleSidKey = 'en_US',
                                        EmailEncodingKey = 'UTF-8',
                                        ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        //insert users;
        ASPISTestUtils.generateTestUsers(users);

        //insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();
			
            accountsList = new List<Account>{
                new Account(Name='Payment_ScTest1',
                             ReferenceNumber__c = '1234567',
                             ContactEmail__c = 'bt3@gmail.com',
                             RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
                             ShippingCountryCode = 'FR',
                             VAT__c = 10)
            };
            insert accountsList;

            ASPISTestUtils.prerequisiteOrders[0].Status__c = 'INDELIVERY';
            update ASPISTestUtils.prerequisiteOrders[0];

            purchaseOrders = new list<PurchaseOrder__c>{
                ASPISTestUtils.purchaseOrders[0]
                ,ASPISTestUtils.purchaseOrders[1]
            };
            purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;
            update purchaseOrders;

            orderLines = new list<OrderLine__c>{
                new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[0].id, CataloguePrice__c = 10, BodyShopDiscount__c = 10, TECH_ExtraAS__c = 25, Quantity__c = 2, Type__c = 'A')
                ,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, AXADiscount__c = 11, Quantity__c = 2, Type__c = 'B')
                ,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, TECH_ExtraAS__c = -10, Quantity__c = 2, Type__c = 'B')
                ,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, TECH_ExtraAS__c = -10, Quantity__c = 2, Type__c = 'A')
            };
            ASPISTestUtils.generateOrderLine(orderLines);

            offerList = new List<Offer__c>{
                new Offer__c(OrderLine__c = orderLines[0].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'BASIC'
                            , Accepted__c = 'YES')
                ,new Offer__c(OrderLine__c = orderLines[0].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'UNSUPPLIEABLEBASIC'
                            , Accepted__c = 'YES')
            };
            ASPISTestUtils.generateOffer(offerList);
            
            discountList = new list<Discount__c>{new Discount__c(BeginingDate__c = System.today(), 
                                                                 Brand__c = 'AUDI',
                                                                 ASLowLevel__c = 2, 
                                                                 EndDate__c = Date.newInstance(2017, 2, 17), 
                                                                 PartType__c = 'A',
                                                                 Distributor__c = ASPISTestUtils.accounts[2].Id, 
                                                                 TECH_VerifyUnicityActiveDiscount__c = '2test2',
                                                                 RecordTypeId = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Distributor Discount').getRecordTypeId()),
												new Discount__c(BeginingDate__c = System.today(), 
                                                                 Brand__c = 'NISSAN',
                                                                 PartType__c = 'A',
                                                                 Distributor__c = ASPISTestUtils.accounts[2].Id, 
                                                                 TECH_VerifyUnicityActiveDiscount__c = '2test34',
																 LowKeepDiscount__c = 10,
																 HighKeepDiscount__c = 15,
                                                                 RecordTypeId = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Bodyshop Discount').getRecordTypeId()),
												new Discount__c(BeginingDate__c = System.today(), 
                                                                 Brand__c = 'CITROEN',
                                                                 PartType__c = 'B;C',
																 LowKeepDiscount__c = 20,
																 HighKeepDiscount__c = 25,
                                                                 Distributor__c = ASPISTestUtils.accounts[2].Id, 
                                                                 TECH_VerifyUnicityActiveDiscount__c = '2test98',
                                                                 RecordTypeId = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Bodyshop Discount').getRecordTypeId())

            };
            insert discountList;
        }//end runas
    }//end of static
	
    static testMethod void testProcess(){
        System.runAs(users[0]){
            orderLines[0].DeliveryStatus__c = 'DELAYED' ;
            test.starttest();
                update orderLines;
            test.stoptest();

            list <Offer__c> listResultOffer = new list<Offer__c>([SELECT DeliveryStatus__c FROM Offer__c WHERE Id IN :offerList]);

            System.assertEquals( orderLines[0].DeliveryStatus__c , listResultOffer[0].DeliveryStatus__c );
            System.assertEquals( orderLines[0].DeliveryStatus__c , listResultOffer[0].DeliveryStatus__c );
        }
    }

    static testMethod void testProcessExpectedDeliveryDate(){
        System.runAs(users[0]){
            orderLines[0].EstimatedDeliveryDate__c = System.now().addDays(5).date() ;
            test.starttest();
                update orderLines;
            test.stoptest();

            list <Offer__c> listResultOffer = new list<Offer__c>([SELECT ExpectedDeliveryDate__c FROM Offer__c WHERE Id IN :offerList]);

            System.assertEquals( orderLines[0].EstimatedDeliveryDate__c , listResultOffer[0].ExpectedDeliveryDate__c );
            System.assertEquals( orderLines[0].EstimatedDeliveryDate__c , listResultOffer[0].ExpectedDeliveryDate__c );
        }
    }
	
    static testMethod void testDistibutorPrice(){
        System.runAs(users[0]){
            orderLines[0].CataloguePrice__c = 100 ;
            orderLines[0].AssessmentPrice__c = 50 ;
            test.starttest();
                update orderLines;
            test.stoptest();
			
			System.assertEquals([select Id, DistributorPriceHigger__c from PurchaseOrder__c where Id =: orderLines[0].PurchaseOrder__c].DistributorPriceHigger__c , true);
        }
    }
	
	static testMethod void testUpdateBSCreditNote(){
		 System.runAs(users[0]){
            orderLines[0].AdditionnalDiscount__c = 10; 
            test.starttest();
                update orderLines;
            test.stoptest();
			
			System.assertEquals([Select Id,TECH_ToBeProcessed__c from OrderLine__c where TECH_ToBeProcessed__c = true].size() , 1);
        }
	}*/
}