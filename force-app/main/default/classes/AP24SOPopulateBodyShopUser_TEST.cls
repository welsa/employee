/*************************************************************************************
Class Name - TestAP23PPOPopulateDistributorUser
Version - 1.0
Created Date - 16 DEC 2015
Function - Test class for AP23PPOPopulateDistributorUser

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* Brayan Nunhuck 16/12/2015  Original Version
*************************************************************************************/
@isTest
private class AP24SOPopulateBodyShopUser_TEST { 
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static date myDate;
    static datetime myDateTime;
    static testMethod void myUnitTest() {

        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();

        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){
            myDateTime = datetime.newInstance(2015, 2, 17);
            myDate = date.newInstance(2015, 2, 17);

            // Create several Bodyshops and Distributors.
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            dist1.ContactUser__c = l_users[0].Id;
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            l_Accounts.add(dist2);
            dist2.ContactUser__c = l_users[0].Id;            
            insert l_Accounts;

            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            l_Assessments.add(ass3);            
            insert l_Assessments;

            Test.startTest();
            // Create severals Sales Orders
            MAP<Id, PrerequisiteOrder__c> m_ID2SalesOrder = new MAP<Id, PrerequisiteOrder__c>();
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so2);
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs1, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so3);            
            insert l_SalesOrders;
            Test.stopTest();

            for (PrerequisiteOrder__c soTest : [Select Id, BodyShopContact__c from PrerequisiteOrder__c where Id In :l_SalesOrders])
            {
                System.assertEquals(true, soTest.BodyShopContact__c != null);
            }
        }
    }
}