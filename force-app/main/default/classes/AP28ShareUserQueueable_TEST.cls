/*************************************************************************************
Class Name - AP28ShareUserQueueable_TEST
Version - 1.0
Created Date - 11 APR 2016

Function - 
-- Test class for AP28ShareUserQueueable

Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S 	 11/04/2016		Original version: C-001496: Use the Reference Number in Public Group for 
								sharing to BS and Dist
*********************************************************************************************************/

@isTest
private class AP28ShareUserQueueable_TEST {

	/*static User user1;
	static list<Account> l_Accounts;
    static list<User> l_users; 
    static list<string> refIdList;
    static string ref0;
    static string ref1;
    static string ref2;
    static string ref3;
    static string ref4;
    

    static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_users = new list<user>();
       
        ref0 = TestFactory.randomizeString('12345');
        ref1 = TestFactory.randomizeString('12345');
		ref2 = TestFactory.randomizeString('12345');
		ref3 = TestFactory.randomizeString('12345');
		ref4 = TestFactory.randomizeString('12345');
        

        // creating user
        user1 = TestFactory.createUser('ScUserTest');
        user1.BodyShopID__c =ref0;
        insert user1;      
        
        system.runas(user1){
           	User userBS = TestFactory.createUserBodyshop('ASEBSES');
            userBS.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ES - BodyShop Technical' LIMIT 1].Id;
            userBS.BodyShopID__c =ref1;
            userBS.UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleSpain'].Id;
            l_users.add(userBS);   

            User userBS_FR = TestFactory.createUserBodyshop('ASEBSFR');
           	userBS_FR.BodyShopID__c = ref2;
            userBS_FR.UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleFrance'].Id;
            l_users.add(userBS_FR);          

            User userDist = TestFactory.createUserDistributor('ASEDistES');
            userDist.DistributorID__c = ref3;
            userDist.UserRoleId = [SELECT Id from UserRole where DeveloperName='DistributorSpain'].Id;
            l_users.add(userDist);    
            
            User userDistFR = TestFactory.createUserDistributor('ASEDistFR');
            userDistFR.DistributorID__c = ref4;
            userDistFR.UserRoleId = [SELECT Id from UserRole where DeveloperName='DistributorFrance'].Id;
            l_users.add(userDistFR);    

        	insert l_users;

            // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ReferenceNumber__c = ref1;
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs1.ReferenceNumber__c = ref2;
            l_Accounts.add(bs2); 

            Account dist1 = TestFactory.createAccountDistributor('Dist_ScTest3', 'ES');
            bs1.ReferenceNumber__c = ref3;
            l_Accounts.add(dist1);               

            Account dist2 = TestFactory.createAccountDistributor('Dist_ScTest4', 'FR');
            dist2.ReferenceNumber__c = ref4;
            l_Accounts.add(dist2); 

            insert l_Accounts; 
        }
    }


	static testMethod void AP28ShareUserQueueable_DeleteMember_TEST() {
        system.debug('###### start AP28ShareUserQueueable_DeleteMember_TEST');
		map<String, Id> refGroupMap= new map<String, Id>();
		map<String, Id> refGroupMemberMap= new map<String, Id>();
		Map<String, List<User>> mapReferenceNumberListOfUser = new Map<String, List<User>>();

        l_users[0].BodyShopID__c = ref2;
		l_users[1].BodyShopID__c = ref1;
		l_users[3].DistributorID__c =ref3;	 
        
        mapReferenceNumberListOfUser.put(ref2, new List<User>{l_users[0]});
		mapReferenceNumberListOfUser.put(ref1, new List<User>{l_users[1]});
		mapReferenceNumberListOfUser.put(ref3, new List<User>{l_users[3]});

		system.runas(user1){
            test.startTest();
            update l_users;
            System.enqueueJob(new AP28ShareUserQueueable(mapReferenceNumberListOfUser));  
            test.stopTest();
        }

        system.assertNotEquals([Select Id from user where BodyShopID__c = :ref2].Id, [Select UserOrGroupId from GroupMember where GroupId = :[Select Id from Group where name = :ref2].Id].UserOrGroupId);
    }*/
}