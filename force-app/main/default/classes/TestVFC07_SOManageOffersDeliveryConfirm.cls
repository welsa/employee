// TO BE DELETED
/*************************************************************************************
Class Name - TestVFC07_SOManageOffersDeliveryConfirm
Version - 1.0
Created Date - 09 JUN 2015
Function - test class for VFC07_SOManageOffersDeliveryConfirmed

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Bhavish (sc)			09/06/2015	Original Version
************************************************************************************/
@isTest
private class TestVFC07_SOManageOffersDeliveryConfirm {
//	static list<user> users;
//	static list<Offer__c> offersList;
//	static list<OrderLine__c> orderLinesList;
//	static list<Prerequisiteorder__c> prerequisiteOrdersList;
//    static list<Invoice__c> invoicesList;
//	static list<Account> accountsList;
//    static list <Group> groups;
//    static list<QueuesObject> queues;
//    static list<CountryQueueMapping__c> cs_CountryQueues;
//    static list<CaseDetailsProcessMapping__c> cs_CaseDetails;
//    
//	static {
//		users = new list<User>{ new User(Username = 'testclass@test.com',
//			                            LastName = 'testuser',
//			                            LanguageLocaleKey = 'en_US',
//			                            FirstName = 'test',
//			                            Email = 'test@test.com',
//			                            Alias = 'test',
//			                            TimeZoneSidKey = 'Europe/Dublin',
//			                            LocaleSidKey = 'en_US',
//			                            EmailEncodingKey = 'UTF-8',
//			                            ProfileId = ASPISConstants.getProfileAdminId())
//	  	}; 
//	  	ASPISTestUtils.generateTestUsers(users);
//	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true,BypassTrigger__c = 'AP05;AP07');
//	  	system.runas(users[0]){
//			ASPISTestUtils.generateBasicTestData();
//            
//            groups = new list<Group>{
//                new Group(Name='scDefault', type='Queue')
//                ,new Group(Name='scDelivery', type='Queue')
//                ,new Group(Name='scInvoice', type='Queue')
//            };
//            insert groups;
//
//            queues = new list<QueuesObject>{
//               new QueueSObject(QueueID = groups[0].id, SobjectType = 'Case__c')
//               ,new QueueSObject(QueueID = groups[1].id, SobjectType = 'Case__c')
//               ,new QueueSObject(QueueID = groups[2].id, SobjectType = 'Case__c')
//            };
//
//            insert queues;
//
//
//            cs_CountryQueues = new list<CountryQueueMapping__c>{
//                new CountryQueueMapping__c(
//                     Name='FR-DEFAULT'
//                     ,Queue_ID__c = queues[0].QueueID
//                     ,Support_Type__c =  'DEFAULT'
//                ),
//                new CountryQueueMapping__c(
//                     Name='FR-DELIVERY'
//                     ,Queue_ID__c = queues[1].QueueID
//                     ,Support_Type__c =  'DELIVERY'
//                )
//            };
//            insert cs_CountryQueues;
//
//            cs_CaseDetails = new list<CaseDetailsProcessMapping__c>{
//                new CaseDetailsProcessMapping__c(
//                    Name='FR-SO-DeliveryProblem	'
//                    ,Origin__c = 'APPLICATION'
//                    ,Type__c = 'PROBLEM'
//                    ,Priority__c = 'CRITICAL'
//                    ,Reason__c ='DELIVERY'
//                    ,Subject__c = 'Probleme lors de la livraison'
//                    ,Description__c = 'Le Bodyshop a indiqué avoir eu des problèmes de livraison avec sa commande.'
//                    ,Internal_Comments__c = 'Veuillez prendre contact avec lui et faire le necessaire.'
//                    ,Due_Date_Duration__c = 1
//                    ,Due_Date_Unity__c = 'D'
//                    ,Short_Description__c = 'Test1'
//                ),
//                new CaseDetailsProcessMapping__c(
//                    Name='FR-PO-Canceled'
//                    ,Origin__c = 'APPLICATION'
//                    ,Type__c = 'PROBLEM'
//                    ,Priority__c = 'CRITICAL'
//                    ,Reason__c ='DELIVERY'
//                    ,Subject__c = 'Action requise : Commande annulée après la création des offres'
//                    ,Description__c = 'Cette commande a été annulée par le Distributeur après la génération et la soumission des offres correspondantes au Bodyshop.'
//                    ,Internal_Comments__c = 'Prenez contact au plus vite avec le Bodyshop pour etudier une solution de secours.'
//                    ,Due_Date_Duration__c = 1
//                    ,Due_Date_Unity__c = 'D'
//                    ,Short_Description__c = 'Test1'
//                )
//            };
//
//            insert cs_CaseDetails;
//            
//			accountsList = new List<Account>{
//				new Account(Name='Payment_ScTest1',
//		        			 ReferenceNumber__c = '1234567',
//		        			 ContactEmail__c = 'bt3@gmail.com',
//		        			 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
//		        			 ShippingCountryCode = 'FR'
//		        			 ,VAT__c = 10)
//			};
//			insert accountsList;
//
//			ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
//			update ASPISTestUtils.accounts;
//
//
//			prerequisiteOrdersList = new List<Prerequisiteorder__c>{
//				new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
//										Assessment__c = ASPISTestUtils.assessments[0].Id,
//										RecordTypeId = ASPISTestUtils.proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
//                ,new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
//										Assessment__c = ASPISTestUtils.assessments[0].Id,
//										RecordTypeId = ASPISTestUtils.proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
//			};
//			insert prerequisiteOrdersList;
//
//	  		orderLinesList = new List<OrderLine__c>{
//				new OrderLine__c(Type__c = 'A',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = 'Original 1',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BodyShopDiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
//								Suppliable__c = 'YES',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'B',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = 'Final 1',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'YES',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'B',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'A',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'B',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = 'Final 1',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'YES',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'B',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'B',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'A',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'A',
//							 	OrderType__c = 'FINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//				,new OrderLine__c(Type__c = 'A',
//							 	OrderType__c = 'ORIGINAL',
//								PartList__c = ASPISTestUtils.partLists[0].id,
//								OriginalItem__c = null,
//								PartNumber__c = 'Part1234',
//								ExpectedDeliveryDuration__c = '1',
//								Description__c = '',
//								PartFamily__c = 'Family1234',
//								Manufacturer__c = 'Manufacturer1',
//								CataloguePrice__c = 1000,
//								Quantity__c = 10,
//								AXADiscount__c = 10,
//								BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
//								BodyShopDiscount__c = 10,
//								Suppliable__c = 'NO',
//								PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
//							 	AcceptedCheck__c=true)
//			};
//			insert orderLinesList;
//
//			orderLinesList[0].OriginalItem__c = orderLinesList[9].id;
//			orderLinesList[7].OriginalItem__c = orderLinesList[0].id;
//			orderLinesList[8].OriginalItem__c = orderLinesList[0].id;
//			orderLinesList[7].OrderType__c = 'BUNDLEITEM';
//			orderLinesList[8].OrderType__c = 'BUNDLEITEM';
//			update orderLinesList;
//
//			offersList =  new list<Offer__c>{
//				new Offer__c(Type__c = 'QUICK',
//						OrderLine__c = orderLinesList[0].Id,
//					 	Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//	 					OrderLine__c = orderLinesList[1].Id,
//		 				Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[2].Id,
//		 				Prerequisiteorder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[3].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[0].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[4].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[1].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[5].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[1].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[6].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[1].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[7].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[0].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
//
//				new Offer__c(Type__c = 'QUICK',
//		 				OrderLine__c = orderLinesList[8].Id,
//		 				Prerequisiteorder__c = prerequisiteOrdersList[0].Id,
//						ExpectedDeliveryDate__c = System.today(),
//					 	Accepted__c = 'YES',
//					 	DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY)
//			};
//			insert offersList;
//            
//            offersList[7].ParentOffer__c = offersList[0].Id;
//			offersList[8].ParentOffer__c = offersList[0].Id;
//			update offersList;
//
//			ASPISTestUtils.purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id;
//			update ASPISTestUtils.purchaseOrders[0];
//
//            invoicesList = new List<Invoice__c>{
//                new Invoice__c(
//                    Assessment__c = prerequisiteOrdersList[1].Assessment__c,
//                    BodyShop__c = prerequisiteOrdersList[1].BodyShop__c,
//                    //PreOrderNumber__c = prerequisiteOrdersList[1].name,
//                    Status__c = 'SENT',
//                    Prerequisiteorder__c = prerequisiteOrdersList[1].id,
//                    PaymentTo__c = accountsList[0].id, 
//                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
//                    Paymentterms__c = prerequisiteOrdersList[1].PaymentTerms__c
//                )
//                ,new Invoice__c(
//                    Assessment__c = prerequisiteOrdersList[1].Assessment__c,
//                    BodyShop__c = prerequisiteOrdersList[1].BodyShop__c,
//                    //PreOrderNumber__c = prerequisiteOrdersList[1].name,
//                    Status__c = 'SENT',
//                    Prerequisiteorder__c = prerequisiteOrdersList[1].id,
//                    PaymentTo__c = accountsList[0].id, 
//                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
//                    Paymentterms__c = prerequisiteOrdersList[1].PaymentTerms__c
//                )
//            };
//            insert invoicesList;
//  		}
//	}
//
//	static testMethod void testVFC07_SOManageOffersDeliveryConfirm1(){
//		system.runAs(users[0]){
//			test.starttest();
//				VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			test.stoptest();
//			System.assertEquals(1, ctrl.l_OfferTypeOptions.size());
//			System.assertEquals('QUICK', ctrl.l_OfferTypeOptions[0].getValue());
//			System.assertEquals('QUICK', ctrl.l_OfferTypeOptions[0].getLabel());
//			System.assertEquals(3, ctrl.m_OfferType2ListItems.size());
//			System.assertEquals(3, ctrl.m_OfferType2ListItems.get('QUICK').size());
//			System.assertEquals(0, ctrl.m_OfferType2ListItems.get('NOTSELECTEDQUICK').size());
//			System.assertEquals(0, ctrl.m_OfferType2ListItems.get('UNSUPPLIEABLEQUICK').size());
//			System.assertEquals(1, ctrl.m_OfferType2ListTable.size());
//			System.assertEquals(1, ctrl.m_OfferType2ListTable.get('QUICK').size());
//			System.assertEquals('QUICK', ctrl.m_OfferType2ListTable.get('QUICK')[0]);
//			System.assertEquals(1, ctrl.m_OfferType2LabelSection.size());
//			System.assertEquals(System.Label.SuppliedBy, ctrl.m_OfferType2LabelSection.get('QUICK'));
//			System.assertEquals(3, ctrl.m_OfferId2HasSomeAlternatives.size());
//			System.assertEquals(3, ctrl.m_OfferType2NbItems.size());
//			System.assertEquals(3, ctrl.m_OfferType2NbItems.get('QUICK'));
//			System.assertEquals(0, ctrl.m_OfferType2NbItems.get('NOTSELECTEDQUICK'));
//			System.assertEquals(0, ctrl.m_OfferType2NbItems.get('UNSUPPLIEABLEQUICK'));
//			System.assertEquals(0, ctrl.m_OfferId2ListBundleItems.size());
//		}
//	}
//
//	static testMethod void testVFC07_SOManageOffersDeliveryConfirm2(){
//		system.runAs(users[0]){
//			test.starttest();
//				VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[1]));
//			test.stoptest();
//			System.assertEquals(1, ctrl.l_OfferTypeOptions.size());
//			System.assertEquals('', ctrl.l_OfferTypeOptions[0].getValue());
//			System.assertEquals('--None--', ctrl.l_OfferTypeOptions[0].getLabel());
//		}
//	}
//
//	static testMethod void testVFC07_SOManageOffersDeliveryConfirm3(){
//		system.runAs(users[0]){
//			test.starttest();
//				VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(prerequisiteOrdersList[0]));
//			test.stoptest();
//			System.assertEquals(1, ctrl.l_OfferTypeOptions.size());
//			System.assertEquals('QUICK', ctrl.l_OfferTypeOptions[0].getValue());
//			System.assertEquals('QUICK', ctrl.l_OfferTypeOptions[0].getLabel());
//			System.assertEquals(3, ctrl.m_OfferType2ListItems.size());
//			System.assertEquals(1, ctrl.m_OfferType2ListItems.get('QUICK').size());
//			System.assertEquals(0, ctrl.m_OfferType2ListItems.get('NOTSELECTEDQUICK').size());
//			System.assertEquals(0, ctrl.m_OfferType2ListItems.get('UNSUPPLIEABLEQUICK').size());
//			System.assertEquals(1, ctrl.m_OfferType2ListTable.size());
//			System.assertEquals(1, ctrl.m_OfferType2ListTable.get('QUICK').size());
//			System.assertEquals('QUICK', ctrl.m_OfferType2ListTable.get('QUICK')[0]);
//			System.assertEquals(1, ctrl.m_OfferType2LabelSection.size());
//			System.assertEquals(System.Label.SuppliedBy, ctrl.m_OfferType2LabelSection.get('QUICK'));
//			System.assertEquals(2, ctrl.m_OfferId2HasSomeAlternatives.size());
//			System.assertEquals(3, ctrl.m_OfferType2NbItems.size());
//			System.assertEquals(1, ctrl.m_OfferType2NbItems.get('QUICK'));
//			System.assertEquals(0, ctrl.m_OfferType2NbItems.get('NOTSELECTEDQUICK'));
//			System.assertEquals(0, ctrl.m_OfferType2NbItems.get('UNSUPPLIEABLEQUICK'));
//			System.assertEquals(1, ctrl.m_OfferId2ListBundleItems.size());
//			/*System.debug('zz currSalesOrder :'+ctrl.currSalesOrder);
//			System.debug('zz l_OfferTypeOptions :'+ctrl.l_OfferTypeOptions);
//			System.debug('zz m_OfferType2ListItems :'+ctrl.m_OfferType2ListItems);
//			System.debug('zz m_OfferType2ListTable :'+ctrl.m_OfferType2ListTable);
//			System.debug('zz m_OfferType2LabelSection :'+ctrl.m_OfferType2LabelSection);
//			System.debug('zz m_OfferId2HasSomeAlternatives :'+ctrl.m_OfferId2HasSomeAlternatives);
//			System.debug('zz m_OfferType2NbItems :'+ctrl.m_OfferType2NbItems);
//			System.debug('zz m_OfferId2ListBundleItems :'+ctrl.m_OfferId2ListBundleItems);*/
//		}
//	}
//
//	static testMethod void testCurrentLineNeedUpdate(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			ctrl.selectedOrderItem = offersList[0].id;
//			test.starttest();
//				ctrl.setDeliveredStatus();
//				ctrl.currentLineNeedUpdate();
//			test.stoptest();
//			System.assert(ctrl.hasSomeChangesNotSaved);
//			System.assertEquals(3, ctrl.s_OffersToUpdate.size());
//		}
//	}
//
//	static testMethod void testGoToEditMode(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			test.starttest();
//				Pagereference pf = ctrl.goToEditMode();
//			test.stoptest();
//			System.assert(ctrl.isEditMode);
//			System.assertEquals(null, pf);
//		}
//	}
//
//	static testMethod void testSaveAllChanges1(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				Pagereference pf = ctrl.saveAllChanges();
//			test.stoptest();
//			Offer__c offer = [Select DeliveryStatus__c from Offer__c where id =: offersList[0].id];
//			System.assertEquals(ASPISConstants.OFFER_STATUS_DELIVERED, offer.DeliveryStatus__c);
//			OrderLine__c orderLine = [Select DeliveryStatus__c from OrderLine__c where id=: orderLinesList[0].id];
//			System.assertEquals(ASPISConstants.ORD_LINE_STATUS_DELIVERED, orderLine.DeliveryStatus__c);
//			System.assert(!ctrl.hasSomeChangesNotSaved);
//			System.assert(ctrl.isSaveSuccessful);
//		}
//	}
//
//	static testMethod void testSaveAllChanges2(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DAMAGED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				Pagereference pf = ctrl.saveAllChanges();
//			test.stoptest();
//			Offer__c offer = [Select DeliveryStatus__c from Offer__c where id =: offersList[0].id];
//			System.assertEquals(ASPISConstants.OFFER_STATUS_DAMAGED, offer.DeliveryStatus__c);
//			OrderLine__c orderLine = [Select DeliveryStatus__c from OrderLine__c where id=: orderLinesList[0].id];
//			System.assertEquals(ASPISConstants.ORD_LINE_STATUS_ISSUE, orderLine.DeliveryStatus__c);
//			Prerequisiteorder__c prOrder = [Select HasSomeDeliveryIssuedCaseCreated__c from Prerequisiteorder__c where id =: ASPISTestUtils.prerequisiteOrders[0].id];
//			System.assert(prOrder.HasSomeDeliveryIssuedCaseCreated__c);
//			System.assert(!ctrl.hasSomeChangesNotSaved);
//			System.assert(ctrl.isSaveSuccessful);
//		}
//	}
//
//	static testMethod void testSaveAllChangesFail1(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DAMAGED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.currSalesOrder.id = null;
//			test.starttest();
//				Pagereference pf = ctrl.saveAllChanges();
//			test.stoptest();
//          	System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//          	System.assertEquals(null, pf);
//		}
//	}
//
//
//
//	static testMethod void testSaveAllChangesFail2(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DAMAGED;
//			ctrl.m_Id2Offer.get(offersList[0].id).id = null;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				Pagereference pf = ctrl.saveAllChanges();
//			test.stoptest();
//          	System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//          	System.assertEquals(null, pf);
//		}
//	}
//
//	/*static testMethod void testGenerateInvoices1(){
//		system.runAs(users[0]){
//		 	Prerequisiteorder__c currSalesOrder = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, Status__c, OfferType__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id=:ASPISTestUtils.prerequisiteOrders[0].id];
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(currSalesOrder));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[1].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[1].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[2].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[2].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				ctrl.generateInvoices();
//			test.stoptest();
//
//			List<Invoice__c> invoices = new List<Invoice__c>([Select Assessment__c, BodyShop__c, Status__c, PaymentTo__c, RecordTypeId, PaymentTerms__c, TotalNet__c, ItemsNumber__c, TotalPieces__c from Invoice__c where Prerequisiteorder__c =:currSalesOrder.id]);
//			System.assertEquals(1, invoices.size());
//			System.assertEquals(currSalesOrder.Assessment__c, invoices[0].Assessment__c);
//			System.assertEquals(currSalesOrder.BodyShop__c, invoices[0].BodyShop__c);
//			//System.assertEquals(currSalesOrder.name, invoices[0].PreOrderNumber__c );
//			System.assertEquals('SENT', invoices[0].Status__c );
//			System.assertEquals(accountsList[0].id, invoices[0].PaymentTo__c);
//			System.assertEquals(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(), invoices[0].RecordTypeID );
//			System.assertEquals(27000, invoices[0].TotalNet__c);
//			System.assertEquals(3, invoices[0].ItemsNumber__c );
//			System.assertEquals(30, invoices[0].TotalPieces__c );
//			for(Offer__c offer : [Select CreditNote__c, DeliveryStatus__c from Offer__c where Id =:offersList[0].id or Id =:offersList[1].id or Id =:offersList[2].id]){
//				System.assertEquals(null, offer.CreditNote__c);
//				System.assertEquals(ASPISConstants.OFFER_STATUS_DELIVERED, offer.DeliveryStatus__c);
//			}
//		}
//	}
//
//	static testMethod void testGenerateInvoices2(){
//		system.runAs(users[0]){
//		 	Prerequisiteorder__c currSalesOrder = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, Status__c, OfferType__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id=:ASPISTestUtils.prerequisiteOrders[0].id];
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(currSalesOrder));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_CANCELED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[1].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_CANCELED;
//			ctrl.selectedOrderItem = offersList[1].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[2].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_CANCELED;
//			ctrl.selectedOrderItem = offersList[2].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				ctrl.generateInvoices();
//			test.stoptest();
//            List<Invoice__c> invoices = new List<Invoice__c>([Select Assessment__c, BodyShop__c, Status__c, PaymentTo__c, RecordTypeId, PaymentTerms__c, TotalNet__c, ItemsNumber__c, TotalPieces__c from Invoice__c where Prerequisiteorder__c =:currSalesOrder.id]);
//			System.assertEquals(1, invoices.size());
//			System.assertEquals(currSalesOrder.Assessment__c, invoices[0].Assessment__c);
//			System.assertEquals(currSalesOrder.BodyShop__c, invoices[0].BodyShop__c);
//			//System.assertEquals(currSalesOrder.name, invoices[0].PreOrderNumber__c );
//			System.assertEquals('SENT', invoices[0].Status__c );
//			System.assertEquals(accountsList[0].id, invoices[0].PaymentTo__c);
//			System.assertEquals(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), invoices[0].RecordTypeID );
//			System.assertEquals(27000, invoices[0].TotalNet__c);
//			System.assertEquals(3, invoices[0].ItemsNumber__c );
//			System.assertEquals(30, invoices[0].TotalPieces__c );
//			for(Offer__c offer : [Select CreditNote__c, DeliveryStatus__c from Offer__c where Id =:offersList[0].id or Id =:offersList[1].id or Id =:offersList[2].id]){
//				System.assertEquals(invoices[0].id, offer.CreditNote__c);
//				System.assertEquals(ASPISConstants.OFFER_STATUS_CANCELED, offer.DeliveryStatus__c);
//			}
//		}
//	}
//    
//    static testMethod void testGenerateInvoices3(){
//		system.runAs(users[0]){
//		 	Prerequisiteorder__c currSalesOrder = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, Status__c, OfferType__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id=:prerequisiteOrdersList[1].id];
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(currSalesOrder));
//			ctrl.m_Id2Offer.get(offersList[4].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[4].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[5].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
//			ctrl.selectedOrderItem = offersList[5].id;
//			ctrl.currentLineNeedUpdate();
//			ctrl.m_Id2Offer.get(offersList[6].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_CANCELED;
//			ctrl.selectedOrderItem = offersList[6].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				ctrl.generateInvoices();
//			test.stoptest();
//            Map<Id, Invoice__c> invoices = new Map<Id, Invoice__c>([Select Id, TotalNet__c, ItemsNumber__c, TotalPieces__c from Invoice__c where Id=:invoicesList[0].id or Id=:invoicesList[1].id]);
//            System.assertEquals(9000, invoices.get(invoicesList[0].id).TotalNet__c);
//            System.assertEquals(1, invoices.get(invoicesList[0].id).ItemsNumber__c);
//            System.assertEquals(10, invoices.get(invoicesList[0].id).TotalPieces__c);
//            System.assertEquals(27000, invoices.get(invoicesList[1].id).TotalNet__c);
//            System.assertEquals(3, invoices.get(invoicesList[1].id).ItemsNumber__c);
//            System.assertEquals(30, invoices.get(invoicesList[1].id).TotalPieces__c);
//            for(Offer__c offer : [Select CreditNote__c, DeliveryStatus__c from Offer__c where Id =:offersList[4].id or Id =:offersList[5].id]){
//				System.assertEquals(null, offer.CreditNote__c);
//				System.assertEquals(ASPISConstants.OFFER_STATUS_DELIVERED, offer.DeliveryStatus__c);
//			}
//            Offer__c offer2 = [Select CreditNote__c, DeliveryStatus__c from Offer__c where Id =:offersList[6].id limit 1];
//			System.assertEquals(invoicesList[0].id, offer2.CreditNote__c);
//			System.assertEquals(ASPISConstants.OFFER_STATUS_CANCELED, offer2.DeliveryStatus__c);
//		}
//	}
//    
//    static testMethod void testGenerateInvoicesFail(){
//		system.runAs(users[0]){
//		 	Prerequisiteorder__c currSalesOrder = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, Status__c, OfferType__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id=:ASPISTestUtils.prerequisiteOrders[0].id];
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(currSalesOrder));
//			ctrl.m_Id2Offer.get(offersList[0].id).DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DAMAGED;
//			ctrl.selectedOrderItem = offersList[0].id;
//			ctrl.currentLineNeedUpdate();
//			test.starttest();
//				ctrl.generateInvoices();
//			test.stoptest();
//          	System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
//		}
//	}*/
//
//	static testMethod void testGetters(){
//		system.runAs(users[0]){
//			VFC07_SOManageOffersDeliveryConfirmed_V2 ctrl = new VFC07_SOManageOffersDeliveryConfirmed_V2(new ApexPages.StandardController(ASPISTestUtils.prerequisiteOrders[0]));
//			test.starttest();
//				ctrl.selectedAltItem = 1;
//				ctrl.selectedOfferType = 'QUICK';
//				ctrl.typeByDefault = 'QUICK';
//				ctrl.noData = true;
//			test.stoptest();
//			System.assertEquals(1, ctrl.selectedAltItem);
//			System.assertEquals('QUICK', ctrl.selectedOfferType);
//			System.assertEquals('QUICK', ctrl.typeByDefault);
//			System.assert(ctrl.noData);
//			System.assertEquals(3, ctrl.l_Offers.size());
//			System.assertEquals(3, ctrl.l_OffersType .size());
//		}
//	}
}