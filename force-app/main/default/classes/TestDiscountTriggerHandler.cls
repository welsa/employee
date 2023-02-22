/***********************************************************************************************************
Trigger Name - TestDiscountTriggerHandler
Version - 1.0
Created Date - 07 DEC 2015
Function - Test Class for DiscountTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Cecile L 		07/12/2015 	Original Version
************************************************************************************************************/
@isTest
private class TestDiscountTriggerHandler {
    /*static list<Account> l_Accounts;
        
    static testMethod void myUnitTest() {
        l_Accounts = new list<Account>();
        
        // Create several Bodyshops and Distributors.
        Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
        l_Accounts.add(bs1);
        Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
        l_Accounts.add(dist1);        
        ASPISTestUtils.generateAccount(l_Accounts);
        
        // Create a Distributor discount
        Discount__c distDiscount = TestFactory.createDistributorDiscount(dist1, 30, 'A', 'ALPHA ROMEO; CITROEN');
        insert distDiscount;
        
        // Create a Bodyshop discount
        Discount__c bsDiscount = TestFactory.createBodyshopDiscount(bs1, 20, 'A', 'RENAULT; TOYOTA');
        insert bsDiscount;
        
        // Check the results
		List<Discount__c> l_distDiscounts = [SELECT Id, TECH_BrandsText__c, brand__c FROM Discount__c];
        for(Discount__c disc : l_distDiscounts){
            System.assertEquals(disc.brand__c, disc.TECH_BrandsText__c);
        }
    }*/
}