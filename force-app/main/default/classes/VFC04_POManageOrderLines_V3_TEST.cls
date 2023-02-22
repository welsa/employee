// TO BE DELETED
/*
  ----------------------------------------------------------------------
  -- - Name          : VFC04_POManageOrderLines_V3_TEST 
  -- - Author        : ABT 
  -- - Description   : VFC04_POManageOrderLines_V3_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 04-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class VFC04_POManageOrderLines_V3_TEST 
{
//	static List<User> users;
//	static List<Account> accList;
//	static List<Assessment__c> assessmentList;
//	static List<PrerequisiteOrder__c> salesOrderList;
//	static List<PurchaseOrder__c> purchaseOrderList;
//	static List<OrderLine__c> orderLineList;
//	static BusinessHours defaultHours;
//	static List<CountryCodeInformationsMapping__c> countryMappingList;
//
//	static
//	{
//		users = new List<User>();
//		users.add( TestFactory.createUser('adminUser'));
//		users.add( TestFactory.createUserASPISLocal('aspisLocal'));
//
//		insert users;
//
//		System.runAs(users[0])
//		{
//			// Generating the account
//			accList = new List<Account>
//			{
//				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
//				TestFactory.createAccountDistributor('Distributor_1', 'FR')/*,
//				TestFactory.createAccountBodyshop('BodyShop_2', 'FR'),
//				TestFactory.createAccountDistributor('Distributor_2', 'FR')*/
//			};
//
//			insert accList;
//
//			// Generating the assessments
//			assessmentList = new List<Assessment__c>
//			{
//				TestFactory.createAssessment('Assessment_1', accList[0])
//			};
//
//			insert assessmentList;
//
//			// Generating the salesOrder
//			salesOrderList = new List<PrerequisiteOrder__c>
//			{
//				TestFactory.createSalesOrder(assessmentList[0], accList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
//			};
//
//			insert salesOrderList;
//
//			// Generating Purchase Order
//			purchaseOrderList = new List<PurchaseOrder__c>
//			{
//				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accList[0], accList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
//			};
//
//			insert purchaseOrderList;
//
//			// Generating Order Line
//			orderLineList = new List<OrderLine__c>
//			{
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
//			};
//
//			// Setting the new order line orderType as original
//			orderLineList[0].OrderType__c		= 'ORIGINAL';
//			orderLineList[0].Suppliable__c		= 'NO';
//			// orderLineList[1] is final and suppliable
//			orderLineList[2].OrderType__c		= 'ORIGINAL';
//			orderLineList[3].Suppliable__c		= 'NO';
//			// orderLineList[3] is final and not suppliable
//			orderLineList[4].OrderType__c		= 'ORIGINAL';
//			orderLineList[5].OrderType__c		= 'ORIGINAL';
//			orderLineList[6].OrderType__c		= 'ORIGINAL';
//			orderLineList[7].OrderType__c		= 'ORIGINAL';
//
//			insert orderLineList;
//
//			// Changing order line to bundles
//			orderLineList[1].OriginalItem__c	= orderLineList[0].Id;
//            orderLineList[2].OrderType__c		= 'BUNDLEITEM';
//            orderLineList[2].OriginalItem__c	= orderLineList[1].Id;
//            orderLineList[6].OrderType__c		= 'BUNDLEITEM';
//            orderLineList[6].OriginalItem__c	= orderLineList[5].Id;
//            orderLineList[7].OrderType__c		= 'BUNDLEITEM';
//            orderLineList[7].OriginalItem__c	= orderLineList[5].Id;
//            orderLineList[5].OrderType__c		= 'FINAL';
//
//			update orderLineList;
//
//			// access Business Hours 
//            defaultHours = [select Id from BusinessHours where IsDefault=true];
//
//			countryMappingList = new List<CountryCodeInformationsMapping__c>
//			{
//				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id)
//			};
//			countryMappingList[0].MinDiscountAS__c = 1;
//			countryMappingList[0].MinDiscountBS__c = 1;
//			
//			insert countryMappingList;
//		}
//	}
//
//	@isTest static void VFC04_POManageOrderLinesNotAlwaysReadOnly_TEST()
//	{
//		System.runAs(users[0])
//		{
//			Test.startTest();
//				VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			Test.stopTest();
//	
//			System.assertEquals(false,	ctrl.isAlwaysReadOnly);
//			System.assertEquals(8,		ctrl.m_Id2OrderLine.size());
//			System.assertEquals(5,		ctrl.m_OriginalId2Wrapper.size());
//		}
//	}
//	
//	@isTest static void currOrderItemIsSuppliable_TEST()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[4].id;
//	
//			Test.startTest();
//				ctrl.currOrderItemIsSuppliable();
//			Test.stopTest();
//	
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals('YES', ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.Suppliable__c);
//			System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
//		}
//	}
//	
//	@isTest static void currOrderItemIsNotSuppliable_TEST()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[4].id;
//	
//			Test.startTest();
//				ctrl.currOrderItemIsNotSuppliable();
//			Test.stopTest();
//			
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals('NO', ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.Suppliable__c);
//			System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
//		}
//	}
//	
//	@isTest static void testAddNewAlternative1()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[4].id;
//			ctrl.TypeOrderLine	   = 'Original';
//	
//			Test.startTest();
//				//ctrl.addBSValue();
//				ctrl.addNewAlternative();
//			Test.stopTest();
//	
//			System.assertEquals(true, ctrl.hasSomeChangesNotSaved);
//			System.assertEquals(orderLineList[4].Id,			ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.OriginalItem__c);
//			System.assertEquals(orderLineList[4].PartList__c,	ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.PartList__c);
//			System.assertEquals(purchaseOrderList[0].Id,		ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.PurchaseOrder__c);
//			System.assertEquals('FINAL',						ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.OrderType__c);
//			System.assertEquals(20.00,							ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.AXADiscount__c);
//			System.assertEquals(10.00,							ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.BodyShopDiscount__c);
//			System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
//		}
//	}
//	
//	@isTest static void testAddNewAlternative2()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[0].id;
//	
//			Test.startTest();
//				//ctrl.addBSValue();
//				ctrl.addNewAlternative();
//			Test.stopTest();
//	
//			System.assert(ctrl.hasSomeChangesNotSaved);
//	
//			OrderLine__c orderLine = ctrl.m_OriginalId2Wrapper.get(orderLineList[0].Id).m_index2AlternativeWrappers.get(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].Id).nbAlternatives-1).alternative;
//	
//			System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].Id).bundleItem.Id,		orderLine.OriginalItem__c);
//			System.assertEquals('BUNDLEITEM',															orderLine.OrderType__c);
//			System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].Id).bundleItem.Type__c,	orderLine.Type__c);
//			System.assertEquals(purchaseOrderList[0].Id,												orderLine.PurchaseOrder__c);
//			
//		}
//	}
//	
//	@isTest static void testAddNewAlternativeFail()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = purchaseOrderList[0].id;
//	
//			Test.startTest();
//				ctrl.addNewAlternative();
//			Test.stopTest();
//	
//			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//		}
//	}
//	
//	@isTest static void testCurrentLineNeedUpdate()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[0].id;
//	
//			Test.startTest();
//				ctrl.currentLineNeedUpdate();
//			Test.stopTest();
//	
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[0].Id));
//		}
//	}
//	
//	@isTest static void testRemoveAlternative()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[0].id;
//			ctrl.selectedAltItem = 0;
//	
//			Test.startTest();
//				PageReference pf = ctrl.removeAlternative();
//			Test.stopTest();
//	
//			System.assertEquals(null, pf);
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals(1, ctrl.l_AltItemsToDelete.size());
//			System.assertEquals(0, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).m_index2AlternativeWrappers.size());
//		}
//	}
//	
//	@isTest static void testRemoveBundle()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[0].id;
//	
//			Test.startTest();
//				PageReference pf = ctrl.removeBundle();
//			Test.stopTest();
//	
//			System.assertEquals(null, pf);
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals(0, ctrl.l_AltItemsToDelete.size());
//		}
//	}
//	
//	@isTest static void testRemoveBundle1()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[4].id;
//			ctrl.addNewAlternative();
//			ctrl.saveAllChanges();
//	
//	
//			Test.startTest();
//				PageReference pf = ctrl.removeBundle();
//			Test.stopTest();
//	
//			System.assertEquals(null, pf);
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals(1, ctrl.l_AltItemsToDelete.size());
//		}
//	}
//	
//	@isTest static void testGoToEditMode()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	
//			Test.startTest();
//				PageReference pf = ctrl.goToEditMode();
//			Test.stopTest();
//	
//			System.assertEquals(null, pf);
//		}
//	}
//	
//	@isTest static void testSaveAllChangesDelete()
//	{
//		System.runAs(users[0])
//		{
//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			ctrl.selectedOrderItem = orderLineList[0].Id;
//			ctrl.selectedAltItem = 0;
//			ctrl.removeAlternative();
//	
//			Test.startTest();
//				PageReference pf = ctrl.saveAllChanges();
//			Test.stopTest();
//	
//			List<OrderLine__c> orderLines = new List<OrderLine__c>([select Id 
//																	from OrderLine__c
//																	where Id =: orderLineList[2].id]);
//			System.assertEquals(0, orderLines.size());
//		}
//	}
//    
//    @isTest static void testcurrOrderItemIsUnSuppliable()
//	{
//        System.runAs(users[0])
//		{
//            VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//            ctrl.selectedOrderItemUnSupplied = orderLineList[0].Id;
//	
//            Test.startTest();
//				ctrl.currOrderItemIsUnSuppliable();
//                PageReference pf = ctrl.goToEditMode();
//            Test.stopTest();
//	
//            System.assertEquals(null, pf);
//        }
//    }
//    
//    @isTest static void testaddBSValue1()
//	{
//        System.runAs(users[0])
//		{
//            VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//            ctrl.selectedOrderItem = orderLineList[0].Id;
//			ctrl.TypeOrderLine = 'Original';
//	
//            Test.startTest();
//				ctrl.addBSValue();
//                PageReference pf = ctrl.goToEditMode();
//            Test.stopTest();
//	
//            System.assertEquals(null, pf);
//        }
//    }
//    
//    @isTest static void testaddBSValue2()
//	{
//        System.runAs(users[0])
//		{
//            VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//            ctrl.selectedOrderItem = orderLineList[0].Id;
//			ctrl.TypeOrderLine = 'Bundle';
//	
//            Test.startTest();
//				ctrl.addBSValue();
//                PageReference pf = ctrl.goToEditMode();
//            Test.stopTest();
//	
//            System.assertEquals(null, pf);
//        }
//    }
//    
//    @isTest static void testaddBSValue3()
//	{
//        System.runAs(users[0])
//		{
//            VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//            //ctrl.selectedOrderItem = orderLineList[5].Id;
//			ctrl.selectedOrderItem = orderLineList[0].Id;
//			ctrl.TypeOrderLine = 'Alternative';
//			ctrl.rowIndex = 1;
//	
//            Test.startTest();
//				ctrl.addBSValue();
//                PageReference pf = ctrl.goToEditMode();
//            Test.stopTest();
//	
//            System.assertEquals(null, pf);
//        }
//    }
//
//    //	@isTest static void testaddSuppliableAndDelivery1()
//	//	{
//    //	    System.runAs(users[0])
//	//		{
//    //	        VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//    //	        ctrl.selectedOrderItem = orderLineList[0].Id;
//	//	
//    //	        Test.startTest();
//	//				ctrl.addSuppliableAndDelivery();
//    //	            PageReference pf = ctrl.goToEditMode();
//    //	        Test.stopTest();
//	//	
//    //	        System.assertEquals(null, pf);
//    //	    }
//    //	}
//    //	
//    //	@isTest static void testaddSuppliableAndDelivery2()
//	//	{
//    //	    System.runAs(users[0])
//	//		{
//    //	        VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//    //	        ctrl.selectedOrderItem = orderLineList[3].Id;
//	//	
//    //	        Test.startTest();
//	//				ctrl.addSuppliableAndDelivery();
//    //	            PageReference pf = ctrl.goToEditMode();
//    //	        Test.stopTest();
//	//	
//    //	        System.assertEquals(null, pf);
//    //	    }
//    //	}
//    //	
//    //	@isTest static void testaddSuppliableAndDelivery3()
//	//	{
//    //	    System.runAs(users[0])
//	//		{
//    //	        VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//    //	        ctrl.selectedOrderItem = orderLineList[5].Id;
//	//			//ctrl.removeBundle();
//	//			//ctrl.addNewAlternative();
//	//	
//    //	        Test.startTest();
//	//				ctrl.addSuppliableAndDelivery();
//    //	            PageReference pf = ctrl.goToEditMode();
//    //	        Test.stopTest();
//	//	
//    //	        System.assertEquals(null, pf);
//    //	    }
//    //	}
//    //	
//    //	//@isTest static void testaddSuppliableAndDelivery4()
//	//	//{
//    //	//    System.runAs(users[0])
//	//	//	{
//    //	//        VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//    //	//        ctrl.selectedOrderItem = orderLineList[7].id;
//	//	//
//    //	//        Test.startTest();
//	//	//			ctrl.addSuppliableAndDelivery();
//    //	//            PageReference pf = ctrl.goToEditMode();
//    //	//        Test.stopTest();
//	//	//
//    //	//        System.assertEquals(null, pf);
//    //	//    }
//    //	//}
//	//	
//	//	@isTest static void testSaveAllChangesExistingCase1()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	//			ctrl.selectedOrderItem = orderLineList[3].id;
//	//			ctrl.currOrderItemIsSuppliable();
//	//	
//	//			Test.startTest();
//	//				PageReference pf = ctrl.saveAllChanges();
//	//			Test.stopTest();
//	//	
//	//			OrderLine__c orderLine = [SELECT Suppliable__c
//	//											,OrderType__c
//	//										FROM OrderLine__c
//	//										WHERE Id =: orderLineList[3].id
//	//										LIMIT 1];
//	//	
//	//			System.assertEquals('YES', orderLine.Suppliable__c);
//	//			System.assertEquals('FINAL', orderLine.OrderType__c);
//	//		}
//	//	}
//	//	
//	//	@isTest static void testSaveAllChangesExistingCase2()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	//			ctrl.selectedOrderItem = orderLineList[4].id;
//	//			ctrl.addNewAlternative();
//	//			ctrl.addNewAlternative();
//	//	
//	//			Test.startTest();
//	//				PageReference pf = ctrl.saveAllChanges();
//	//			Test.stopTest();
//	//	
//	//			List<OrderLine__c> orderLines = new List<OrderLine__c>([select Suppliable__c
//	//																		,PartList__c
//	//																		,ExpectedDeliveryDuration__c
//	//																		,Quantity__c
//	//																		,AXADiscount__c
//	//																		,BodyShopDiscount__c
//	//																		,BundleItemsDescription__c
//	//																	from OrderLine__c
//	//																	where OriginalItem__c =: orderLineList[4].id
//	//																	or OriginalItem__r.OriginalItem__c =: orderLineList[4].id]);
//	//			System.assertEquals(3, orderLines.size());
//	//		}
//	//	}
//	//	
//	//	@isTest static void testSaveAllChangesExistingCase3()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	//			ctrl.selectedOrderItem = orderLineList[0].id;
//	//			ctrl.addNewAlternative();
//	//	
//	//			Test.startTest();
//	//				PageReference pf = ctrl.saveAllChanges();
//	//			Test.stopTest();
//	//	
//	//			List<OrderLine__c> orderLines = new List<OrderLine__c>([select Suppliable__c
//	//																		,PartList__c
//	//																		,ExpectedDeliveryDuration__c
//	//																		,Quantity__c
//	//																		,AXADiscount__c
//	//																		,BodyShopDiscount__c
//	//																		,BundleItemsDescription__c
//	//																	from OrderLine__c
//	//																	where OriginalItem__c =: orderLineList[1].id
//	//																	and OriginalItem__r.OriginalItem__c =: orderLineList[0].id]);
//	//			System.assertEquals(0, orderLines.size());
//	//		}
//	//	}
//	//	
//	@isTest static void testGetters()
//	{
//		System.runAs(users[0])
//		{
//			Test.startTest();
//				VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//				ctrl.refreshPage = true;
//			Test.stopTest();
//	
//			System.assertEquals(1000, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemTotalNetPrice);
//			System.assertEquals(1000, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemTotalNetPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemAXATotalNetPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXATotalNetPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemAXAPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXAPrice);
//			System.assert(!ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).hasAlternatives);
//			System.assert(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).hasAlternatives);
//			System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Eliminated').getRecordTypeId(), ctrl.recordTypeEliminatedId);
//			System.assertEquals(3, ctrl.l_OriginalWrappers.size());
//			System.assert(ctrl.refreshPage);
//	
//			System.assertEquals(1000, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).l_AlternativeWrappers[0].ItemTotalNetPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).l_AlternativeWrappers[0].ItemAXATotalNetPrice);
//			System.assertEquals(800, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).l_AlternativeWrappers[0].ItemAXAPrice);
//	
//			System.assertEquals(2, ctrl.l_OriginalWrappersUnSupp.size());
//	
//		}
//	}
//	
//	@isTest static void testNoCountryMappingFRFound()
//	{
//		System.runAs(users[0])
//		{
//			// deleting the fr custom settings to get the error message on the constructor
//			delete countryMappingList;
//	
//			Test.startTest();
//				VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			Test.stopTest();
//	
//			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//		}
//	}
//	
//	//	@isTest static void testASDiscountErrorMessage()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	//			ctrl.selectedOrderItem = orderLineList[4].id;
//	//			ctrl.goToEditMode();
//	//			ctrl.m_Id2OrderLine.get(orderLineList[4].Id).AXADiscount__c = -70.00;
//	//		
//	//			Test.startTest();
//	//				ctrl.addNewAlternative();
//	//				System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//	//	
//	//				ctrl.m_Id2OrderLine.get(orderLineList[4].Id).AXADiscount__c = 20.00;
//	//				ctrl.addNewAlternative();
//	//	
//	//				ctrl.m_OriginalId2Wrapper.get(orderLineList[4].Id).originalItem.AXADiscount__c = -70.00;
//	//				ctrl.saveAllChanges();
//	//				System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//	//	
//	//			Test.stopTest();
//	//		}
//	//	}
//	//	
//	//	@isTest static void testBSDiscountErrorMessage()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//	//			ctrl.selectedOrderItem = orderLineList[4].id;
//	//			ctrl.goToEditMode();
//	//			ctrl.m_Id2OrderLine.get(orderLineList[4].Id).BodyShopDiscount__c = -70.00;
//	//		
//	//			Test.startTest();
//	//				ctrl.addNewAlternative();
//	//				System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//	//			
//	//				ctrl.m_Id2OrderLine.get(orderLineList[4].Id).BodyShopDiscount__c = 20.00;
//	//				ctrl.addNewAlternative();
//	//	
//	//				ctrl.m_OriginalId2Wrapper.get(orderLineList[4].Id).originalItem.BodyShopDiscount__c = -70.00;
//	//				ctrl.saveAllChanges();
//	//				System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//	//			Test.stopTest();
//	//		}
//	//	}
//	//	
//	@isTest static void testAdminConstructor()
//	{
//		System.runAs(users[0])
//		{
//			// Creating order line to make count1 != count2
//			List<OrderLine__c> nonSuppliableOrderLine = new List<OrderLine__c>
//			{
//				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
//			};
//	
//			nonSuppliableOrderLine[0].OrderType__c	= 'ORIGINAL';
//			// Setting the suppliable__c a value other than NO and YES
//			nonSuppliableOrderLine[0].Suppliable__c = 'NON';
//	
//			insert nonSuppliableOrderLine;
//	
//			Test.setCurrentPage(Page.VFP04_POManageOrderLines_V3);
//			ApexPages.currentPage().getParameters().put('KeepEdit', 'true');
//	
//			Test.startTest();
//				VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[0]));
//			Test.stopTest();
//	
//			System.assertEquals(true, ctrl.isEditMode);
//			System.assertEquals('true', ctrl.isDisabled);
//		}
//	}
//	//	
//	//	/*
//	//	@isTest static void testLocalASPISUserIsAlwaysReadOnly()
//	//	{
//	//		System.runAs(users[1])
//	//		{
//	//			Test.startTest();
//	//				VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[1]));
//	//			Test.stopTest();
//	//			
//	//			System.assertEquals(true, ctrl.isAlwaysReadOnly);
//	//		}
//	//	}*/
//	//	
//	//	@isTest static void testSaveAllChangesExistingCase4()
//	//	{
//	//		System.runAs(users[0])
//	//		{
//	//			VFC04_POManageOrderLines_V3 ctrl = new VFC04_POManageOrderLines_V3(new ApexPages.StandardController(purchaseOrderList[1]));
//	//			ctrl.selectedOrderItem = orderLineList[8].id;
//	//			ctrl.currOrderItemIsSuppliable();
//	//	
//	//			Test.startTest();
//	//				PageReference pf = ctrl.saveAllChanges();
//	//			Test.stopTest();
//	//	
//	//			OrderLine__c orderLine = [SELECT Suppliable__c
//	//											,OrderType__c
//	//										FROM OrderLine__c
//	//										WHERE Id =: orderLineList[8].id
//	//										LIMIT 1];
//	//	
//	//			System.assertEquals('YES', orderLine.Suppliable__c);
//	//			System.assertEquals('BUNDLEITEM', orderLine.OrderType__c);
//	//		}
//	//	}
//
}