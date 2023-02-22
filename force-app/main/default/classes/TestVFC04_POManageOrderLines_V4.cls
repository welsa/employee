// TO BE DELETED
/*************************************************************************************
Class Name - TestVFC04_POManageOrderLines
Version - 1.0
Created Date - 04 June 2015
Function - test class for VFC04_POManageOrderLines

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description 
* ----------            ----------  -----------------------
* Bhavish (sc)          04/06/2015  Original Version
* Dourga (sc)           17/07/2015  Updated for V3
* Dourga (sc)           09/09/2015  Updated for V4
************************************************************************************/
@isTest
private class TestVFC04_POManageOrderLines_V4 {
/*
    static list<User> users;
    static list<OrderLine__c> orderLineList;
    static list<Discount__c> discountList;

    static{
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
        //insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();
            orderLineList = new List<OrderLine__c>{
                new OrderLine__c(Type__c = 'A',
                                OrderType__c = 'ORIGINAL',
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
                                Suppliable__c = 'NO',
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
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'ORIGINAL',
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
                                Description__c = 'Original 2',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
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
                                Description__c = 'Original 2',
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
                                OrderType__c = 'ORIGINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Original 2',
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
                                OrderType__c = 'ORIGINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Original 2',
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
                                OrderType__c = 'ORIGINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Original 2',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
            };
            ASPISTestUtils.generateOrderLine(orderLineList);
            orderLineList[1].OriginalItem__c = orderLineList[0].id;
            orderLineList[2].OrderType__c = 'BUNDLEITEM';
            orderLineList[2].OriginalItem__c = orderLineList[1].id;
            orderLineList[6].OrderType__c = 'BUNDLEITEM';
            orderLineList[6].OriginalItem__c = orderLineList[5].id;
            orderLineList[7].OrderType__c = 'BUNDLEITEM';
            orderLineList[7].OriginalItem__c = orderLineList[5].id;
            update orderLineList;

            discountList = new list<Discount__c>{new Discount__c(BeginingDate__c = System.today(), 
                                                                 ASHighLimit__c = 7, 
                                                                 EndDate__c = Date.newInstance(2017, 2, 17), 
                                                                 DistributorCode__c = 'disC1',
                                                                 Distributor__c = ASPISTestUtils.accounts[2].Id, 
                                                                 PartType__c = 'A',
                                                                 TECH_VerifyUnicityActiveDiscount__c = '1test1',
                                                                 RecordTypeId = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Distributor Discount').getRecordTypeId())

            };
            insert discountList;
        }
    }
    
    static testMethod void testVFC04_POManageOrderLinesNotAlwaysReadOnly(){ 
        system.runas(users[0]){
            test.starttest();
                VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            test.stoptest();
            System.assert(!ctrl.isAlwaysReadOnly);
            System.assertEquals(8, ctrl.m_Id2OrderLine.size());
            System.assertEquals(5, ctrl.m_OriginalId2Wrapper.size());
        }
    }

    static testMethod void testCurrOrderItemIsSuppliable(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[4].id;
            test.starttest();
                ctrl.currOrderItemIsSuppliable();
            test.stoptest();
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.Suppliable__c, 'YES');
            System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
        }
    }

    static testMethod void testCurrOrderItemIsNotSuppliable(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[4].id;
            test.starttest();
                ctrl.currOrderItemIsNotSuppliable();
            test.stoptest();
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.Suppliable__c, 'NO');
            System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
        }
    }

    static testMethod void testAddNewAlternative1(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[4].id;
            test.starttest();
                ctrl.addNewAlternative();
            test.stoptest();
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.OriginalItem__c, orderLineList[4].id);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.PartList__c, orderLineList[4].PartList__c);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.PurchaseOrder__c, ASPISTestUtils.purchaseOrders[0].id);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).bundleItem.OrderType__c, 'FINAL');
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.AXADiscount__c, 10.00);
            System.assertEquals(ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).originalItem.BodyShopDiscount__c,10.00);
            System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[4].id));
        }
    }
    
    static testMethod void testAddNewAlternative2(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            test.starttest();
                ctrl.addNewAlternative();
            test.stoptest();
            System.assert(ctrl.hasSomeChangesNotSaved);
            OrderLine__c orderLine = ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).m_index2AlternativeWrappers.get(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).nbAlternatives-1).alternative;
            System.assertEquals(orderLine.OriginalItem__c, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).bundleItem.Id);
            System.assertEquals(orderLine.OrderType__c, 'BUNDLEITEM');
            System.assertEquals(orderLine.PurchaseOrder__c, ASPISTestUtils.purchaseOrders[0].id);
            
        }
    }

    static testMethod void testAddNewAlternativeFail(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = ASPISTestUtils.purchaseOrders[0].id;
            test.starttest();
                ctrl.addNewAlternative();
            test.stoptest();
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
        }
    }

    static testMethod void testadddisCodeExtraAs(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.OriId = orderLineList[0].id;
            ctrl.typeOrderLine = 'Bundle';
            test.starttest();
                ctrl.addDisCode();
                ctrl.addAs();
            test.stoptest();
            System.assertEquals(ctrl.selectedOrderItem, orderLineList[0].id);
        }
    }

    static testMethod void testadddisCodeExtraAs2(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.OriId = orderLineList[0].id;
            ctrl.typeOrderLine = 'Original';
            test.starttest();
                ctrl.addDisCode();
                ctrl.addAs();
            test.stoptest();
            System.assertEquals(ctrl.selectedOrderItem, orderLineList[0].id);
        }
    }

    static testMethod void testadddisCodeExtraAs3(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.OriId = orderLineList[1].id;
            test.starttest();
                ctrl.addDisCode();
                ctrl.addAs();
            test.stoptest();
            System.assertEquals(ctrl.selectedOrderItem, orderLineList[1].id);
        }
    }

    static testMethod void testCurrentLineNeedUpdate(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            test.starttest();
                ctrl.currentLineNeedUpdate();
            test.stoptest();
        }
    }

    static testMethod void testRemoveAlternative(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            ctrl.selectedAltItem = 0;
            test.starttest();
                pagereference pf = ctrl.removeAlternative();
            test.stoptest();
            System.assertEquals(null, pf);
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assertEquals(1, ctrl.l_AltItemsToDelete.size());
            System.assertEquals(0, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).m_index2AlternativeWrappers.size());
        }
    }

    static testMethod void testRemoveBundle(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            test.starttest();
                pagereference pf = ctrl.removeBundle();
            test.stoptest();
            System.assertEquals(null, pf);
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assertEquals(0, ctrl.l_AltItemsToDelete.size());
        }
    }

    static testMethod void testGoToEditMode(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            test.starttest();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }

    static testMethod void testSaveAllChangesDelete(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            ctrl.selectedAltItem = 0;
            ctrl.removeAlternative();
            test.starttest();
                pagereference pf = ctrl.saveAllChanges();
            test.stoptest();
            List<OrderLine__c> orderLines = new List<OrderLine__c>([select Id 
                                                                    from OrderLine__c
                                                                    where Id =: orderLineList[2].id]);
            System.assertEquals(0, orderLines.size());
        }
    }
    
    static testMethod void testaddSuppliableAndDelivery1(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            test.starttest();
				ctrl.addSuppliableAndDelivery();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }
    
    static testMethod void testaddSuppliableAndDelivery2(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[3].id;
            test.starttest();
				ctrl.addSuppliableAndDelivery();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }
    
    static testMethod void testaddSuppliableAndDelivery3(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[5].id;
            test.starttest();
				ctrl.addSuppliableAndDelivery();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }
    
    static testMethod void testaddSuppliableAndDelivery4(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[1].id;
            test.starttest();
				ctrl.addSuppliableAndDelivery();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }

    static testMethod void testcurrOrderItemIsUnSuppliable(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItemUnSupplied = orderLineList[0].id;
            test.starttest();
				ctrl.currOrderItemIsUnSuppliable();
                pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
        }
    }
	
	static testMethod void testSaveAllChangesExistingCase1(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[3].id;
            ctrl.currOrderItemIsSuppliable();
            test.starttest();
                pagereference pf = ctrl.saveAllChanges();
            test.stoptest();
            OrderLine__c orderLine = [select Suppliable__c
                                            ,OrderType__c
                                        from OrderLine__c
                                        where Id =: orderLineList[3].id
                                        limit 1];
            System.assertEquals('YES', orderLine.Suppliable__c);
            System.assertEquals('FINAL', orderLine.OrderType__c);
        }
    }

    static testMethod void testSaveAllChangesExistingCase2(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[4].id;
            ctrl.addNewAlternative();
            ctrl.addNewAlternative();
            test.starttest();
                pagereference pf = ctrl.saveAllChanges();
            test.stoptest();
            List<OrderLine__c> orderLines = new List<OrderLine__c>([select Suppliable__c
                                                                        ,PartList__c
                                                                        ,ExpectedDeliveryDuration__c
                                                                        ,Quantity__c
                                                                        ,AXADiscount__c
                                                                        ,BodyShopDiscount__c
                                                                        ,BundleItemsDescription__c
                                                                    from OrderLine__c
                                                                    where OriginalItem__c =: orderLineList[4].id
                                                                    or OriginalItem__r.OriginalItem__c =: orderLineList[4].id]);
            System.assertEquals(3, orderLines.size());
        }
    }

    static testMethod void testSaveAllChangesExistingCase3(){
        system.runAs(users[0]){
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            ctrl.addNewAlternative();
            test.starttest();
                pagereference pf = ctrl.saveAllChanges();
            test.stoptest();
            List<OrderLine__c> orderLines = new List<OrderLine__c>([select Suppliable__c
                                                                        ,PartList__c
                                                                        ,ExpectedDeliveryDuration__c
                                                                        ,Quantity__c
                                                                        ,AXADiscount__c
                                                                        ,BodyShopDiscount__c
                                                                        ,BundleItemsDescription__c
                                                                    from OrderLine__c
                                                                    where OriginalItem__c =: orderLineList[1].id
                                                                    and OriginalItem__r.OriginalItem__c =: orderLineList[0].id]);
            System.assertEquals(0, orderLines.size());
        }
    }

    static testMethod void testGetters(){
        system.runAs(users[0]){
            test.starttest();
            VFC04_POManageOrderLines_V4 ctrl = new VFC04_POManageOrderLines_V4(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.refreshPage = true;
            test.stoptest();
            System.assertEquals(10000, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemTotalNetPrice);
            System.assertEquals(10000, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemTotalNetPrice);
            System.assertEquals(9000, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemAXATotalNetPrice);
            System.assertEquals(9000, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXATotalNetPrice);
            System.assertEquals(900, ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).ItemAXAPrice);
            System.assertEquals(900, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXAPrice);
            System.assert(!ctrl.m_OriginalId2Wrapper.get(orderLineList[4].id).hasAlternatives);
            System.assert(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).hasAlternatives);
            System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Eliminated').getRecordTypeId(), ctrl.recordTypeEliminatedId);
            System.assertEquals(3, ctrl.l_OriginalWrappers .size());
            System.assert(ctrl.refreshPage);
        }
    }*/
}