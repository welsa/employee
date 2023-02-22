// TO BE DELETED
/*************************************************************************************
Class Name - TestVFC05_POManageOrderLinesDelivery_V3
Version - 1.0
Created Date - 05 June 2015
Function - test class for VFC05_POManageOrderLinesDelivery

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Bhavish (sc)          05/06/2015  Original Version
* Dourga (sc)           17/07/2015  Updated for V2
* Dourga (sc)           18/08/2015  Updated for Not Selected part
* Dourga (sc)           17/09/2015  Updated for V3
************************************************************************************/
@isTest
private class TestVFC05_POManageOrderLinesDelivery_V3 {
/*
    static list<User> users;
    static list<OrderLine__c> orderLineList;
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
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
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'A',
                                OrderType__c = 'FINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Original 2',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'ORIGINAL',
                                PartList__c = ASPISTestUtils.partLists[0].id,
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 200,
                                Quantity__c = 10,
                                AXADiscount__c = 20,
                                BodyShopDiscount__c = 20,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                AcceptedCheck__c=false)

            };
            ASPISTestUtils.generateOrderLine(orderLineList);
            orderLineList[1].OriginalItem__c = orderLineList[0].id;
            orderLineList[2].OrderType__c = 'BUNDLEITEM';
            orderLineList[2].OriginalItem__c = orderLineList[1].id;
            orderLineList[7].OrderType__c = 'BUNDLEITEM';
            orderLineList[7].OriginalItem__c = orderLineList[5].id;
            orderLineList[9].OrderType__c = 'BUNDLEITEM';
            orderLineList[9].OriginalItem__c = orderLineList[5].id;
            orderLineList[8].OriginalItem__c = orderLineList[4].id;
            orderLineList[10].OriginalItem__c = orderLineList[4].id;
            update orderLineList;
        }
    }

    static testMethod void testVFC05_POManageOrderLinesDeliveryNotAlwaysReadOnly(){ 
        system.runas(users[0]){
            test.starttest();
                VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            test.stoptest();
            System.assert(!ctrl.isAlwaysReadOnly);
            System.assertEquals(12, ctrl.m_Id2OrderLine.size());
            System.assertEquals(3, ctrl.m_OriginalId2Wrapper.size());
        }
    }

    static testMethod void testCurrentLineNeedUpdate(){
        system.runAs(users[0]){
            VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.selectedOrderItem = orderLineList[0].id;
            test.starttest();
                ctrl.currentLineNeedUpdate();
            test.stoptest();
            System.assert(ctrl.hasSomeChangesNotSaved);
            System.assert(ctrl.s_OriginalItemsIdToUpsert.contains(orderLineList[0].id));
        }
    }

    static testMethod void testGoToEditMode(){
        system.runAs(users[0]){
            VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            test.starttest();
                Pagereference pf = ctrl.goToEditMode();
            test.stoptest();
            System.assertEquals(null, pf);
            System.assert(ctrl.isEditMode);
        }
    }

    static testMethod void testSaveAllChangesInDelivery(){
        system.runAs(users[0]){
            VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).originalItem.DeliveryStatus__c = 'DELAYED';
            ctrl.selectedOrderItem = orderLineList[0].id;
            ctrl.currentLineNeedUpdate();
            test.starttest();
                Pagereference pf = ctrl.saveAllChanges();
            test.stoptest();
            for(OrderLine__c orderLine : [select DeliveryStatus__c
                                            from OrderLine__c
                                            where Id =:orderLineList[0].id
                                            or Id =:orderLineList[1].id
                                            or Id =:orderLineList[2].id]){
                System.assertEquals('DELAYED', orderLine.DeliveryStatus__c);
            }
            PurchaseOrder__c purchaseOrder = [select delayedCaseCreated__c
                                                from PurchaseOrder__c
                                                where Id =:ASPISTestUtils.purchaseOrders[0].id];
            System.assert(purchaseOrder.delayedCaseCreated__c);
            System.assert(!ctrl.isEditMode);
            System.assert(!ctrl.hasSomeChangesNotSaved);
        }
    }

    static testMethod void testSaveAllChangesFail(){
        VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).originalItem.DeliveryStatus__c = 'DELAYED';
            ctrl.selectedOrderItem = orderLineList[0].id;
            ctrl.currentLineNeedUpdate();
            ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).originalItem.id = null;
            ctrl.m_OriginalId2WrapperNotSelected.get(orderLineList[11].id).originalItem.id = null;
            test.starttest();
                ctrl.saveAllChanges();
            test.stoptest();
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    static testMethod void testGetters(){
        system.runAs(users[0]){
            test.starttest();
                VFC05_POManageOrderLinesDelivery_V3 ctrl = new VFC05_POManageOrderLinesDelivery_V3(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
                ctrl.selectedAltItem = 1;
            test.stoptest();
            System.assertEquals(2000, ctrl.m_OriginalId2Wrapper.get(orderLineList[3].id).ItemTotalNetPrice);
            System.assertEquals(2000, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemTotalNetPrice);
            System.assertEquals(1600, ctrl.m_OriginalId2Wrapper.get(orderLineList[3].id).ItemAXATotalNetPrice);
            System.assertEquals(1600, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXATotalNetPrice);
            System.assertEquals(160, ctrl.m_OriginalId2Wrapper.get(orderLineList[3].id).ItemAXAPrice);
            System.assertEquals(160, ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).ItemAXAPrice);
            System.assert(!ctrl.m_OriginalId2Wrapper.get(orderLineList[3].id).hasAlternatives);
            System.assert(ctrl.m_OriginalId2Wrapper.get(orderLineList[0].id).hasAlternatives);
            System.assertEquals(3, ctrl.l_OriginalWrappers .size());
            System.assertEquals(1, ctrl.selectedAltItem);
        }
    }*/
}