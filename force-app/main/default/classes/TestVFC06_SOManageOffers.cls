// TO BE DELETED
/*************************************************************************************
Class Name - TestVFC06_SOManageOffers
Version - 1.0
Created Date - 08 June 2015
Function - test class for VFC06_SOManageOffers

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga (sc)	     	08/06/2015  Original Version
************************************************************************************/
@isTest
private class TestVFC06_SOManageOffers {
/*
	static list<user> users;
	static list<OrderLine__c> orderLineList;
	static list<PrerequisiteOrder__c> prerequisiteOrders;
	static list<Offer__c> offerList;
	static list<Offer__c> offerBundleList;


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
	  	//ASPISTestUtils.setupBypassCustomSetting(true,true,'AP05;AP07','TestVFC06_SOManageOffers',users[0].Id);
	  	system.runas(users[0]){
	  		ASPISTestUtils.generateBasicTestData();
			orderLineList = new List<OrderLine__c>{
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
								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
								Suppliable__c = 'YES',
								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
							 	AcceptedCheck__c=true)
				,new OrderLine__c(Type__c = 'B',
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
								Description__c = 'Bundle Item 1',
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
								PartList__c = ASPISTestUtils.partLists[0].id,
								OriginalItem__c = null,
								PartNumber__c = 'Part1234',
								ExpectedDeliveryDuration__c = '1',
								Description__c = 'Bundle Item 1',
								PartFamily__c = 'Family1234',
								Manufacturer__c = 'Manufacturer1',
								CataloguePrice__c = 1000,
								Quantity__c = 10,
								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
								AXADiscount__c = 10,
								BodyShopDiscount__c = 10,
								Suppliable__c = 'YES',
								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
							 	AcceptedCheck__c=true)
				,new OrderLine__c(Type__c = 'A',
								PartList__c = ASPISTestUtils.partLists[0].id,
								OriginalItem__c = null,
								PartNumber__c = 'Part1234',
								ExpectedDeliveryDuration__c = '1',
								Description__c = 'Bundle Item 2',
								PartFamily__c = 'Family1234',
								Manufacturer__c = 'Manufacturer1',
								CataloguePrice__c = 1000,
								Quantity__c = 10,
								AXADiscount__c = 10,
								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
								BodyShopDiscount__c = 10,
								Suppliable__c = 'YES',
								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
							 	AcceptedCheck__c=true)
			};
			ASPISTestUtils.generateOrderLine(orderLineList);

			orderLineList[3].OriginalItem__c = orderLineList[0].id;
			orderLineList[4].OriginalItem__c = orderLineList[0].id;
			orderLineList[3].OrderType__c = 'BUNDLEITEM';
			orderLineList[4].OrderType__c = 'BUNDLEITEM';
			update orderLineList;

			offerList =  new list<Offer__c>{new Offer__c(Type__c = 'QUICK',
														 OrderLine__c = orderLineList[0].Id,
														 BundleItemsDescription__c = 'QUICK',
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id),

											new Offer__c(Type__c = 'NOTSELECTED',
														 OrderLine__c = orderLineList[1].Id,
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id),

											new Offer__c(Type__c = 'UNSUPPLIEABLEQUICK',
														 OrderLine__c = orderLineList[2].Id,
														 DisplayPriority__c = 1.0,
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id)

											
			};
			insert offerList;

			offerBundleList =  new list<Offer__c>{new Offer__c(Type__c = 'QUICK',
														 OrderLine__c = orderLineList[3].Id,
														 DisplayPriority__c = 1.0,
														 BundleItemsDescription__c = 'Desc1',
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
														 ParentOffer__c = offerList[0].Id),

											new Offer__c(Type__c = 'QUICK',
														 OrderLine__c = orderLineList[4].Id,
														 DisplayPriority__c = 1.0,
														 BundleItemsDescription__c = 'Desc2',
														 Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
														 ParentOffer__c = offerList[0].Id)
			};
			insert offerBundleList;
		}
	}
	
	static testMethod void testchangeOfferTypeSelected(){
		System.Debug('>>> Start testchangeOfferTypeSelected');	
		system.runas(users[0]){
			//System.debug('##prerequisiteOrders'+[select Id, OfferType__c from PrerequisiteOrder__c where id <> null]);
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				ctrl.previousSelectedOfferType = 'QUICK';
				ctrl.selectedOrderItem = String.valueOf(offerList[1].Id);
				Set<String> setId = new Set<String>();
				setId.add('BASIC');
				ctrl.s_OfferTypesToUpdate = setId;
				ctrl.changeOfferTypeSelected();
			test.stoptest();
			System.assert(ctrl.hasSomeChangesNotSaved);
		}
		System.Debug('>>> End testchangeOfferTypeSelected');
	}

	static testMethod void testGoToEditMode(){
		System.Debug('>>> Start testGoToEditMode');
		system.runAs(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[1]));
				ctrl.isAlwaysReadOnly = False;
				ctrl.selectedAltItem = 1;
				ctrl.typeByDefault = 'QUICK';
				ctrl.noData = false;
				ctrl.selectedOfferType = String.valueOf(offerList[1].Id);
				ctrl.m_OfferType2DisplayPriority.clear();
				Pagereference pf = ctrl.goToEditMode();
			test.stoptest();
			System.assertEquals(null, pf);
			System.assert(ctrl.isEditMode);
		}
		System.Debug('>>> End testGoToEditMode');
	}

	static testMethod void testsaveAllChangesFail(){
		System.Debug('>>> Start testsaveAllChangesFail');
		system.runAs(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				Set<String> setId = new Set<String>();
				setId.add('QUICK');
				setId.add('NOTSELECTED');
				setId.add('UNSUPPLIEABLEQUICK');
				ctrl.s_OfferTypesToUpdate = setId;
				ctrl.m_OfferType2ListItems.get('QUICK')[0].Id = null;
				Pagereference pf = ctrl.saveAllChanges();
			test.stoptest();
			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
		}
		System.Debug('>>> End testsaveAllChangesFail');
	}

		static testMethod void testsaveAllChanges(){
		System.Debug('>>> Start testsaveAllChanges');
		system.runAs(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				Set<String> setId = new Set<String>();
				setId.add('QUICK');
				setId.add('NOTSELECTED');
				setId.add('UNSUPPLIEABLEQUICK');
				ctrl.s_OfferTypesToUpdate = setId;
				Pagereference pf = ctrl.saveAllChanges();
			test.stoptest();
			System.assert(!ctrl.hasSomeChangesNotSaved);
		}
		System.Debug('>>> End testsaveAllChanges');
	}
	
	static testMethod void testcurrentLineNeedUpdate(){
		System.Debug('>>> Start testcurrentLineNeedUpdate');	
		system.runas(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				Set<String> setId = new Set<String>();
				setId.add('QUICK');
				setId.add('NOTSELECTED');
				setId.add('UNSUPPLIEABLEQUICK');
				ctrl.s_OfferTypesToUpdate = setId;
				ctrl.selectedOrderItem = String.valueOf(offerList[0].Id);
				ctrl.currentLineNeedUpdate();
			test.stoptest();
			System.assert(ctrl.hasSomeChangesNotSaved);
		}
		System.Debug('>>> End testcurrentLineNeedUpdate');
	}
	
	static testMethod void testcurrOfferIsAcceptedByBS(){
		System.Debug('>>> Start testcurrOfferIsAcceptedByBS');	
		system.runas(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				Set<String> setId = new Set<String>();
				setId.add('QUICK');
				setId.add('NOTSELECTED');
				setId.add('UNSUPPLIEABLEQUICK');
				ctrl.s_OfferTypesToUpdate = setId;
				ctrl.selectedOrderItem = String.valueOf(offerList[0].Id);
				ctrl.currOfferIsAcceptedByBS();
			test.stoptest();
			System.assert(ctrl.hasSomeChangesNotSaved);
		}
		System.Debug('>>> End testcurrOfferIsAcceptedByBS');
	}
	
	static testMethod void testcurrOfferIsNotAcceptedByBS(){
		System.Debug('>>> Start testcurrOfferIsNotAcceptedByBS');	
		system.runas(users[0]){
			test.starttest();
				VFC06_SOManageOffers_V2 ctrl = new VFC06_SOManageOffers_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
				Set<String> setId = new Set<String>();
				setId.add('QUICK');
				setId.add('NOTSELECTED');
				setId.add('UNSUPPLIEABLEQUICK');
				ctrl.s_OfferTypesToUpdate = setId;
				ctrl.selectedOrderItem = String.valueOf(offerList[0].Id);
				ctrl.currOfferIsNotAcceptedByBS();
			test.stoptest();
			System.assert(ctrl.hasSomeChangesNotSaved);
		}
		System.Debug('>>> End testcurrOfferIsNotAcceptedByBS');
	}*/
}