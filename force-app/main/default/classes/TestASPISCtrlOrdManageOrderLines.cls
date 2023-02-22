/*************************************************************************************
Class Name - TestASPISCtrlOrdManageOrderLines
Version - 1.0
Created Date -01 JUNE 2015
Function - Test class for ASPISCtrlOrdManageOrderLines

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Bhavish (sc)          01/06/2015  Original Version
*************************************************************************************/
@isTest
private class TestASPISCtrlOrdManageOrderLines {
/*
    static list<user> users;
    static list<OrderLine__c> orderLines ; 
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
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                                                 AXADiscount__c = 10,
                                                                 PartNumber__c = 'Part1234',
                                                                 Description__c = 'OrderLine1',
                                                                 CataloguePrice__c = 100,
                                                                 BodyShopDiscount__c = 10,
                                                                 DeliveryStatus__c = 'INDELIVERY',
                                                                 AcceptedCheck__c=true),
                                                new OrderLine__c(PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                                                                 AXADiscount__c = 10,
                                                                 PartNumber__c = 'Part1234',
                                                                 Description__c = 'OrderLine2',
                                                                 CataloguePrice__c = 100,
                                                                 BodyShopDiscount__c = 10,
                                                                 DeliveryStatus__c = 'INDELIVERY',
                                                                 AcceptedCheck__c=false)
            };
            ASPISTestUtils.generateOrderLine(orderLines);
        }
    }

    static testMethod void testGetListOrderedLines() {
        system.runas(users[0]){
            ASPISCtrlOrdManageOrderLines ctrl = new ASPISCtrlOrdManageOrderLines(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            List<OrderLine__c> listOrderLines;
            test.startTest();
                listOrderLines = ctrl.getListOrderedLines();
            test.stoptest();
            System.assertEquals(1, listOrderLines.size());
            System.assertEquals(orderLines[0].id, listOrderLines[0].id);
            System.assertEquals(orderLines[0].PartNumber__c, listOrderLines[0].PartNumber__c);
            System.assertEquals(orderLines[0].Description__c, listOrderLines[0].Description__c);
            System.assertEquals(orderLines[0].DeliveryStatus__c, listOrderLines[0].DeliveryStatus__c);
        }
    }

    static testMethod void testUpdateConfirmedLines(){
        system.runas(users[0]){
            ASPISCtrlOrdManageOrderLines ctrl = new ASPISCtrlOrdManageOrderLines(new ApexPages.StandardController(ASPISTestUtils.purchaseOrders[0]));
            List<OrderLine__c> listOrderLines = ctrl.getListOrderedLines();
            listOrderLines[0].AcceptedCheck__c = false;
            test.startTest();
                ctrl.updateConfirmedLines();
            test.stoptest();
            OrderLine__c orderLine = [Select AcceptedCheck__c
                                        from OrderLine__c
                                        where Id =: orderLines[0].id
                                        limit 1];
            System.assertEquals(false, orderLine.AcceptedCheck__c);
        }
    }
	*/
}