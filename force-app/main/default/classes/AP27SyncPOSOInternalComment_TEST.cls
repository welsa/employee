/*************************************************************************************
Class Name - AP27SyncPOSOInternalComment_TEST
Version - 1.0
Created Date - 18 MAY 2015
Function - Test class AP27SyncPOSOInternalComment

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Shamina M     10/02/2016  Initial version
*************************************************************************************/
@isTest
private class AP27SyncPOSOInternalComment_TEST {
/*
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Offer__c> l_Offers;
    static User adminUser;

    
    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Offers = new list<Offer__c>();
        
        adminUser = TestFactory.createUser('adminUser');
        l_users.add(adminUser);
        insert adminUser;

        system.runas(adminUser){

            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);            
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            so1.TotalAmount__c  = 1000;
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
            so2.TotalAmount__c  = 2000;
            l_SalesOrders.add(so2);
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'PREORDERCONFIRMED');
            so3.TotalAmount__c  = 3000;
            l_SalesOrders.add(so3);            
            insert l_SalesOrders;

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            po1_1.TotalExpectedAmount__c = 1000;
            l_purchaseOrders.add(po1_1);
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            po1_2.TotalExpectedAmount__c = 2000;
            l_purchaseOrders.add(po1_2);
            PurchaseOrder__c po2_1 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            po2_1.TotalExpectedAmount__c = 3000;
            l_purchaseOrders.add(po2_1);
            PurchaseOrder__c po2_2 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            po2_2.TotalExpectedAmount__c = 4000;
            l_purchaseOrders.add(po2_2);
            PurchaseOrder__c po3 = TestFactory.createPurchaseOrder(ass2, so3, bs2, dist1, 'DELIVEREDCONFIRMED');
            po3.TotalExpectedAmount__c = 5000;
            l_purchaseOrders.add(po3);          
            insert l_purchaseOrders;          
        }
    }

    @isTest static void Test_updatePOInternalComment() {
        // Test update on SO, comment replicated on PO
        system.runAs(adminUser){  
            test.starttest();
                l_SalesOrders[0].InternalComment__c = 'test111';
                l_SalesOrders[1].InternalComment__c = 'test222';
                update l_SalesOrders;                           
            test.stoptest();

            List<PurchaseOrder__c> lstPOAssert = [select InternalComment__c from PurchaseOrder__c 
                                                    where ID in: l_purchaseOrders
                                                    order by TotalExpectedAmount__c ASC];
            // Check results
            system.assertEquals('test111',lstPOAssert[0].InternalComment__c);
            system.assertEquals('test111',lstPOAssert[1].InternalComment__c);
            system.assertEquals('test222',lstPOAssert[2].InternalComment__c);
            system.assertEquals('test222',lstPOAssert[3].InternalComment__c);
            system.assertEquals(null,lstPOAssert[4].InternalComment__c);
        }
    }

    @isTest static void Test_updateSOPOInternalComment() {
        // Test update on PO, replicated on SO and other related PO
        system.runAs(adminUser){  
            test.starttest();
                l_purchaseOrders[0].InternalComment__c = 'test111';
                l_purchaseOrders[1].InternalComment__c = 'test222';
                l_purchaseOrders[2].InternalComment__c = 'test333';
                update l_purchaseOrders;            
            test.stoptest();

            // Check results
            List<PurchaseOrder__c> lstPOAssert = [select InternalComment__c from PurchaseOrder__c 
                                                    where ID in: l_purchaseOrders
                                                    order by TotalExpectedAmount__c ASC];
            List<PrerequisiteOrder__c> lstSOAssert  = [select InternalComment__c from PrerequisiteOrder__c 
                                                        where ID in: l_SalesOrders
                                                        order by TotalAmount__c ASC];
            system.assertEquals('test222',lstSOAssert[0].InternalComment__c);
            system.assertEquals('test222',lstPOAssert[1].InternalComment__c);
            system.assertEquals('test333',lstSOAssert[1].InternalComment__c);
            system.assertEquals('test333',lstPOAssert[3].InternalComment__c);
            system.assertEquals(null,lstPOAssert[4].InternalComment__c);
        }
    }

    */
}