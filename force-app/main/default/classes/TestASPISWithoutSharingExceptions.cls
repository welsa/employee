/*************************************************************************************
Class Name - TestPrerequisiteOrderTriggerHandler
Version - 1.0
Created Date - 15 JUL 2015
Function - TestClass to PrerequisiteOrderTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      15/07/2015  Original Version
*************************************************************************************/
@isTest
private class TestASPISWithoutSharingExceptions {
	/*static list<user> users;
	static list<OrderLine__c> orderLineList;
	static list<PrerequisiteOrder__c> prerequisiteOrders;


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
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = false,BypassTrigger__c = 'AP05;AP07');
	  	//ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestPrerequisiteOrderTriggerHandler',users[0].Id);
        system.runas(users[0]){
	  		ASPISTestUtils.generateBasicTestData();
		}
	}

	static testMethod void testupdateAssessmentList(){
		System.Debug('>>> Start testupdateAssessmentList');	
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.updateAssessmentList(ASPISTestUtils.assessments);
			test.stoptest();
		}
		system.assertEquals(2 , [select Id from Assessment__c where Id in: ASPISTestUtils.assessments].size());
		System.Debug('>>> End testupdateAssessmentList');
	}

	static testMethod void testgetAssessmentsPOChildren(){
		System.Debug('>>> Start testgetAssessmentsPOChildren');	
		set <Id> assId = new set<Id>();
		List<Assessment__c> assList = new List<Assessment__c>();
		for (Assessment__c asmt : ASPISTestUtils.assessments){
			assId.add(asmt.Id);
		}
		system.runas(users[0]){
			test.starttest();
				assList = ASPISWithoutSharingExceptions.getAssessmentsPOChildren(assId);
			test.stoptest();
		}
		system.assertEquals(2 , assList.size());
		System.Debug('>>> End testgetAssessmentsPOChildren');
	}

	static testMethod void testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder(){
		System.Debug('>>> Start testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder');	
		List<PurchaseOrder__c> poList = new List<PurchaseOrder__c>();
		system.runas(users[0]){
			test.starttest();
				poList = ASPISWithoutSharingExceptions.getPurchaseOrderAndOrderLinesRegardingThisSalesOrder(ASPISTestUtils.prerequisiteOrders[0].Id);
			test.stoptest();
		}
		system.assertEquals(0 ,poList.size());
		System.Debug('>>> End testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder');
	}

	static testMethod void testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders(){
		System.Debug('>>> Start testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders');	
		Map<Id,List<PurchaseOrder__c>> m_SalesOrderId2ListPurchaseOrders = new Map<Id,List<PurchaseOrder__c>>();
		List<Id> listSalesOrdersID = new List<Id>();
		insert new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id, ValidityDate__c=date.today(), Status__c = 'ISSUED', Assessment__c=ASPISTestUtils.assessments[0].id, PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].Id);
		ASPISTestUtils.purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id;
		ASPISTestUtils.purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].Id;
		ASPISTestUtils.purchaseOrders[0].Status__c = 'ISSUED';
		ASPISTestUtils.purchaseOrders[1].Status__c = 'ISSUED';
        update ASPISTestUtils.purchaseOrders;
		for (PrerequisiteOrder__c so : ASPISTestUtils.prerequisiteOrders){
			listSalesOrdersID.add(so.Id);
		}
		system.runas(users[0]){
			test.starttest();
				m_SalesOrderId2ListPurchaseOrders = ASPISWithoutSharingExceptions.getPurchaseOrderAndOrderLinesRegardingListOfSalesOrders(listSalesOrdersID);
			test.stoptest();
		}
		system.assertEquals(2 , m_SalesOrderId2ListPurchaseOrders.size());
		System.Debug('>>> End testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders');
	}

	static testMethod void getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(){
		System.Debug('>>> Start getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders');	
		List<PrerequisiteOrder__c> salesOrderList = new List<PrerequisiteOrder__c>();
		List<Id> listSalesOrdersID = new List<Id>();
		for (PrerequisiteOrder__c so : ASPISTestUtils.prerequisiteOrders){
			listSalesOrdersID.add(so.Id);
		}
		system.runas(users[0]){
			test.starttest();
				salesOrderList = ASPISWithoutSharingExceptions.getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(listSalesOrdersID);
			test.stoptest();
		}
		system.assertEquals(2 , salesOrderList.size());
		System.Debug('>>> End getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders');
	}

	static testMethod void testupdatePurchaseOrderList(){
		System.Debug('>>> Start testupdatePurchaseOrderList');	
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.updatePurchaseOrderList(ASPISTestUtils.purchaseOrders);
			test.stoptest();
		}
		system.assertEquals(2 ,ASPISTestUtils.purchaseOrders.size());
		System.Debug('>>> End testupdatePurchaseOrderList');
	}
	
	static testMethod void testupdateOrderLineList(){
		System.Debug('>>> Start testupdateOrderLineList');	
		List<OrderLine__c> orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'ORIGINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
        };
        insert orderLinesList;
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.updateOrderLineList(orderLinesList);
			test.stoptest();
		}
		system.assertEquals(10 ,orderLinesList.size());
		System.Debug('>>> End testupdateOrderLineList');
	}
	
	static testMethod void testgetOrderLinesInfo(){
		System.Debug('>>> Start testgetOrderLinesInfo');	
		List<Id> olIdList = new List<Id>();
		List<OrderLine__c> olList = new List<OrderLine__c>();
		List<OrderLine__c> orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'ORIGINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
        };
        insert orderLinesList;
        for (OrderLine__c ol : orderLinesList){
			olIdList.add(ol.Id);
		}
		system.runas(users[0]){
			test.starttest();
				olList = ASPISWithoutSharingExceptions.getOrderLinesInfo(olIdList);
			test.stoptest();
		}
		system.assertEquals(10 ,olList.size());
		System.Debug('>>> End testgetOrderLinesInfo');
	}
	
	static testMethod void testinsertInvoice(){
		System.Debug('>>> Start testinsertInvoice');	
		Invoice__c inv = new Invoice__c(Assessment__c = ASPISTestUtils.assessments[0].Id, BodyShop__c = ASPISTestUtils.accounts[0].Id, Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id, RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(), Date__c = system.today());
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.insertInvoice(inv);
			test.stoptest();
		}
		system.assertEquals(1 ,[select Id from Invoice__c where Id =: inv.Id].size());
		System.Debug('>>> End testinsertInvoice');
	}
	
	static testMethod void testinsertInvoices(){
		System.Debug('>>> Start testinsertInvoices');	
        list<Invoice__c> invoices = new list<Invoice__c>{
            new Invoice__c(Assessment__c = ASPISTestUtils.assessments[0].Id,
                           BodyShop__c = ASPISTestUtils.accounts[0].Id,
                           Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
                           RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                           Date__c = system.today()),
                new Invoice__c(Assessment__c = ASPISTestUtils.assessments[0].Id,
                               BodyShop__c = ASPISTestUtils.accounts[0].Id,
                               Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
                               RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                               Date__c = system.today())
                };
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.insertInvoices(invoices);
			test.stoptest();
		}
		system.assertEquals(2 ,[select Id from Invoice__c where Id in: invoices].size());
		System.Debug('>>> End testinsertInvoices');
	}

	static testMethod void testinsertListOrderLines(){
		System.Debug('>>> Start testinsertListOrderLines');	
		List<OrderLine__c> orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'ORIGINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
        };
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.insertListOrderLines(orderLinesList);
			test.stoptest();
		}
		system.assertEquals(10 ,[select Id from OrderLine__c where Id in: orderLinesList].size());
		System.Debug('>>> End testinsertListOrderLines');
	}

	static testMethod void testupsertListOrderLines(){
		System.Debug('>>> Start testupsertListOrderLines');	
		List<OrderLine__c> orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'ORIGINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
        };
        insert orderLinesList[0];
        insert orderLinesList[2];
        insert orderLinesList[4];
        insert orderLinesList[6];
        //system.debug('##Before Insert '+ orderLinesList);
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.upsertListOrderLines(orderLinesList);
			test.stoptest();
		}
        //system.debug('##After Insert '+ [select Id from OrderLine__c where Id in: orderLinesList]);
		system.assertEquals(7 ,[select Id from OrderLine__c where Id in: orderLinesList].size());
		System.Debug('>>> End testupsertListOrderLines');
	}

	static testMethod void testupdateOfferLineList(){
		System.Debug('>>> Start testupdateOfferLineList');	
		List<OrderLine__c> orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Final 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            ,new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = '',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                            BodyShopDiscount__c = 10,
                            Suppliable__c = 'NO',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
        };
        insert orderLinesList;

		list<Offer__c> offerList =  new list<Offer__c>{new Offer__c(Type__c = 'QUICK',
														 OrderLine__c = orderLinesList[0].Id,
														 BundleItemsDescription__c = 'QUICK',
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id),

											new Offer__c(Type__c = 'NOTSELECTED',
														 OrderLine__c = orderLinesList[1].Id,
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id),

											new Offer__c(Type__c = 'UNSUPPLIEABLEQUICK',
														 OrderLine__c = orderLinesList[2].Id,
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id)

											
		};
		insert offerList;
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.updateOfferLineList(offerList);
			test.stoptest();
		}
		system.assertEquals(3 ,[select Id from Offer__c where Id in: offerList].size());
		System.Debug('>>> End testupdateOfferLineList');
	}

	static testMethod void testinsertListCases(){
		System.Debug('>>> Start testinsertListCases');
		list<Case__c> cases = new list<Case__c>{new Case__c(Assesment__c = ASPISTestUtils.assessments[0].Id,
				                                                        Subject__c = 'sub1',
				                                                        Due_Date__c = system.today(),
                                                                        Effort_in_man_days__c = 1),
														new Case__c(Assesment__c = ASPISTestUtils.assessments[0].Id,
				                                                        Subject__c = 'sub2',
				                                                        Due_Date__c = system.today(),
                                                                        Effort_in_man_days__c = 1)
        };	
		system.runas(users[0]){
			test.starttest();
				ASPISWithoutSharingExceptions.insertListCases(cases);
			test.stoptest();
		}
		system.assertEquals(2 ,[select Id from Case__c where Id in: cases].size());
		System.Debug('>>> End testinsertListCases');
	}*/
}