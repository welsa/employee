/*************************************************************************************
Class Name - TestAspisBatch_UpdateContactUser
Version - 1.0
Created Date - 20 AUG 2018
Function - TestClass to AspisBatch_SOMigration

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* LGO           29/08/2018  Original Version
* WCH           19/02/2020  Salesforce Summer �19 Release: restricts the use of standard external profiles 
                            for self-registration, login, and assignment to users
*************************************************************************************/



@isTest
private class TestAspisBatch_UpdateContactUser {

    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static User userAdmin;
    static list<Account> accounts;
 

    static User adminUser;
    static User user1;
    static User user2;
    static List<Account> lstAccount;
    static List<Contact> lstContact;
    static list<String> lstUser;

    static
    {   //WCH 19/02/2020
    	//Id p = [SELECT Id FROM Profile WHERE Name LIKE '%Customer Community User%' LIMIT 1].Id;
    	Id p = [SELECT Id FROM Profile WHERE Name LIKE '%CC Bodyshop Order%' LIMIT 1].Id;
    	Id UsroleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleFrance'].Id;
        adminUser = TestFactory.createUser('adminUser');
        adminUser.UserRoleId= UsroleId;
        insert adminUser;


        user1 = TestFactory.createUser('user1');
        user1.ProfileId = p;
        

        user2 = TestFactory.createUser('user2');
        user2.ProfileId = p;
        

        System.runAs(adminUser)
        {

            lstAccount = new List<Account>();
            
            Account tmp = TestFactory.createAccountBodyshop('BodyShop_1', 'FR');
                      tmp.Communities_Batch_1_BS_to_Migrate__c = true;
                      tmp.ArchivedContactUser__c=user1.id;
            lstAccount.add(tmp);

            tmp = TestFactory.createAccountBodyshop('BodyShop_2', 'FR');
                        tmp.Communities_Batch_1_BS_to_Migrate__c = true;
                        tmp.ArchivedContactUser__c=user2.id;
            lstAccount.add(tmp);

            insert lstAccount;

            //Create contact
            lstContact = new List<Contact>{new Contact(firstName = lstAccount[0].Name,
                                                lastName = lstAccount[0].Name,
                                                //Email = lstAccount[0].Email,
                                                AccountID = lstAccount[0].id),

                                           new Contact(firstName = lstAccount[1].Name,
                                                lastName = lstAccount[1].Name,
                                               // Email = lstAccount[1].Email,
                                                AccountID = lstAccount[1].id)
                                           };

            insert lstContact;

            //add contacts to User
            user1.contactid = lstContact[0].Id;
            user2.contactid = lstContact[1].Id;

            insert user1;
            insert user2;

            lstUser= new list<String>();
            lstUser.add(user1.id);
            lstUser.add(user2.id);

        }


}



     @isTest static void updateUserContact_TEST(){
        System.runAs(adminUser)
        {


            AspisBatch_UpdateContactUser batch = new AspisBatch_UpdateContactUser(lstUser);


            Test.startTest();
                Id processId = Database.executeBatch(batch);
            Test.stopTest();

           System.assertEquals(2, [select count() from Account where lastmodifieddate >= TODAY ]);
        }
    }
    


}