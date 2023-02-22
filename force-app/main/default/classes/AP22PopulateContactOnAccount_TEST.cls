/*************************************************************************************
Class Name - AP22PopulateContactOnAccount_TEST
Version - 1.0
Created Date - 26 FEB 2016
Function - TestClass to AP22PopulateContactOnAccount

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Cecile L      26/02/2016  Original Version
*************************************************************************************/
@isTest
private class AP22PopulateContactOnAccount_TEST {
	static User userAdmin;
    static List<User> l_users = new List<User>();
    static List<Account> l_accounts;
    static Assessment__c testAss;
    static PrerequisiteOrder__c testSO;
    static PurchaseOrder__c testPO;
    
    static{
        // Create admin user.
        userAdmin = TestFactory.createUser('userAdmin');       
        
        system.runas(userAdmin){
            // Create several Bodyshop and Distributor users
            for(Integer i = 0; i <=5; i++){
                User userDis = TestFactory.createUserDistributor('userDistributor'+i);
                userDis.DistributorID__c = 'FR000000001'+i;
                l_users.add(userDis);
            } 
            
            for(Integer i = 0; i <=5; i++){
                User userBS = TestFactory.createUserBodyshop('userBS'+i);
                userBS.BodyShopID__c = 'FR000000000'+i;
                l_users.add(userBS);
            } 
            insert l_users;
        }
    }
            
    /**
    * @author Cecile L
    * @date 26/02/2016
    * @description Test : Check that the Contact User is automatically populated on Account based on the BodyshopId or DistributorId. 
    * @param List of Bodyshops and Distributors
    * @return ContactUser__c != null
    */
    static testMethod void myUnitTest() {
        l_accounts = new List<Account>();
        
        system.runas(userAdmin){
            Test.startTest();
            // Create several Bodyshops and Distributors.
            for(Integer i = 0; i <=5; i++){
                Account testBS = TestFactory.createAccountBodyshop('testBodyshop'+i, 'FR');
                testBS.ReferenceNumber__c = 'FR000000000'+i;//WCH 23/12/2020 C-004120
                l_accounts.add(testBS);
            }
            
            for(Integer i = 0; i <=5; i++){
                Account testDIS = TestFactory.createAccountBodyshop('testDistributor'+i, 'FR');
                testDIS.ReferenceNumber__c = 'FR000000001'+i;//WCH 23/12/2020 C-004120
                l_accounts.add(testDIS);
            }
            
            insert l_accounts;
            
            // Check results
            List<Account> results = [Select Id,ContactUser__c from Account where id in :l_accounts];
            
            for (Account a : [Select Id,ContactUser__c from Account where id in :l_accounts])
            {
                system.assertEquals(true, a.ContactUser__c != null);
            }
            Test.stopTest();
        }
    }
}