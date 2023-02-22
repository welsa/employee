/*************************************************************************************
Class Name - TestUserTriggerHandler
Version - 1.0
Created Date - 29 APR 2015
Function - TestClass to UserTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      29/10/2015  Original Version
*************************************************************************************/
@isTest
private class TestUserTriggerHandler {
	// ABT - 26-SEP-2016 - C-001625 - Commented
    //static User userAdmin;
    //static list <User> users;
    //static list<Account> accounts;
    //static map <String,Id> accRecordTypeMap = new map <String,Id>();
    //
    //static{
    //    accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
    //    
    //    userAdmin = new User(Username = 'jean.paul@test.com'
    //                ,LastName = 'paul'
    //                ,LanguageLocaleKey = 'en_US'
    //                ,FirstName = 'jean'
    //                ,Email = 'jean@test.com'
    //                ,Alias = 'jpa'
    //                ,TimeZoneSidKey = 'Europe/Dublin'
    //                ,LocaleSidKey = 'en_US'
    //                ,EmailEncodingKey = 'UTF-8'
    //                ,ProfileId = ASPISConstants.getProfileAdminId()); 
    //                    
    //    //insert userAdmin;
    //    ASPISTestUtils.generateTestUser(userAdmin);
    //    
    //    system.runas(userAdmin){
    //        // insert accounts
    //        accounts = new list<Account>{
    //            new Account(Name='BodyShop_ScTest1'
    //                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
    //                ,ReferenceNumber__c = '123'
    //                ,ContactEmail__c = 'bt1@gmail.com'
    //                ,VAT__c= 10
    //            ),
    //            new Account(Name='BodyShop_ScTest2'
    //                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
    //                ,ReferenceNumber__c = '1234'
    //                ,ContactEmail__c = 'bt2@gmail.com'
    //                ,VAT__c= 10
    //            ),
    //            new Account(Name='Distributor_ScTest1'
    //                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
    //                ,ReferenceNumber__c = '12345'
    //                ,ContactEmail__c = 'dt1@gmail.com'
    //                ,VAT__c= 10
    //            ),
    //            new Account(Name='Distributor_ScTest2'
    //                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
    //                ,ReferenceNumber__c = '123456'
    //                ,ContactEmail__c = 'dt1@gmail.com'
    //                ,VAT__c= 10
    //            )
    //        };
    //        insert accounts;
    //        
    //        // users
    //        users = new list<User>{
    //            new User(Username = 'pep.guar@test.com'
    //                ,LastName = 'guardiola'
    //                ,LanguageLocaleKey = 'en_US'
    //                ,FirstName = 'pep'
    //                ,Email = 'pep@test.com'
    //                ,Alias = 'pgu'
    //                ,TimeZoneSidKey = 'Europe/Dublin'
    //                ,LocaleSidKey = 'en_US'
    //                ,EmailEncodingKey = 'UTF-8'
    //                ,ProfileId = ASPISConstants.getProfileAdminId()
    //            ),
    //            new User(Username = 'carlo.ance@test.com'
    //                ,LastName = 'anceloti'
    //                ,LanguageLocaleKey = 'en_US'
    //                ,FirstName = 'carlo'
    //                ,Email = 'v@test.com'
    //                ,Alias = 'can'
    //                ,TimeZoneSidKey = 'Europe/Dublin'
    //                ,LocaleSidKey = 'en_US'
    //                ,EmailEncodingKey = 'UTF-8'
    //                ,ProfileId = ASPISConstants.getProfileAdminId()
    //            )
    //            
    //        };
    //    }//end runAs
    //}//end static
    //
    //static testMethod void bodyShopOnInsertTest() {
    //    system.debug('#### Start of method bodyShopOnInsertTest');
    //    
    //    system.runAs(userAdmin){
    //        users[0].BodyShopID__c = accounts[0].ReferenceNumber__c;
    //        users[1].BodyShopID__c = accounts[0].ReferenceNumber__c;
    //            
    //        test.starttest();   
    //            insert users;
    //        test.stoptest();
    //        
    //        list<GroupMember> groupMemberAssertList = [select UserOrGroupId, Id, GroupId, Group.Name 
    //                                                    from GroupMember 
    //                                                    where UserOrGroupId IN:users order by Group.Name];
    //                                                    
    //        //system.debug('//groupMemberAssertList1: ' + groupMemberAssertList.size());
    //        
    //        system.assertEquals(2,groupMemberAssertList.size());
    //        
    //        /*system.assertEquals(users[0].Id,groupMemberAssertList[0].UserOrGroupId);
    //        system.assertEquals(accounts[0].Name,groupMemberAssertList[0].Group.Name);
    //        system.assertEquals(users[1].Id,groupMemberAssertList[1].UserOrGroupId);
    //        system.assertEquals(accounts[0].Name,groupMemberAssertList[1].Group.Name);*/
    //        
    //    }//end runAs
    //}//end method
    //
    //
    //static testMethod void distributorOnInsertTest() {
    //    system.debug('#### Start of method distributorOnInsertTest');
    //    
    //    system.runAs(userAdmin){
    //        users[0].DistributorID__c = accounts[2].ReferenceNumber__c;
    //        users[1].DistributorID__c = accounts[3].ReferenceNumber__c;
    //            
    //        test.starttest();   
    //            insert users;
    //        test.stoptest();
    //        
    //        list<GroupMember> groupMemberAssertList = [select UserOrGroupId, Id, GroupId, Group.Name 
    //                                                    from GroupMember 
    //                                                    where UserOrGroupId IN:users order by Group.Name];
    //                                                    
    //        //system.debug('//groupMemberAssertList2: ' + groupMemberAssertList.size());
    //        
    //        system.assertEquals(2,groupMemberAssertList.size());
    //        
    //       /* system.assertEquals(users[0].Id,groupMemberAssertList[0].UserOrGroupId);
    //        system.assertEquals(accounts[2].Name,groupMemberAssertList[0].Group.Name);
    //        system.assertEquals(users[1].Id,groupMemberAssertList[1].UserOrGroupId);
    //        system.assertEquals(accounts[3].Name,groupMemberAssertList[1].Group.Name);*/
   	//
    //    }//end runAs
    //}//end method
    
    /*static testMethod void bodyShop_Distributor_V1_OnUpdateTest() {
        system.debug('#### Start of method bodyShop_Distributor_V1_OnUpdateTest');
        
        system.runAs(userAdmin){
                insert users;
            test.starttest();   
                //from null to not null
                Account acc1 = [SELECT ReferenceNumber__c FROM Account where Name='BodyShop_ScTest1'];
                Account acc2 = [SELECT ReferenceNumber__c FROM Account where Name='BodyShop_ScTest2'];
                users[0].BodyShopID__c = acc1.ReferenceNumber__c;
                users[1].BodyShopID__c = acc2.ReferenceNumber__c;
                
                update users;
            test.stoptest();
            
            list<GroupMember> groupMemberAssertList = [select UserOrGroupId, Id, GroupId, Group.Name 
                                                        from GroupMember 
                                                        where UserOrGroupId IN:users order by Group.Name];
                                                        
            //system.debug('//groupMemberAssertList3: ' + groupMemberAssertList);
            
            system.assertEquals(2,groupMemberAssertList.size());
            
           system.assertEquals(users[0].Id,groupMemberAssertList[0].UserOrGroupId);
            system.assertEquals(accounts[0].Name,groupMemberAssertList[0].Group.Name);
            system.assertEquals(users[1].Id,groupMemberAssertList[1].UserOrGroupId);
            system.assertEquals(accounts[1].Name,groupMemberAssertList[1].Group.Name);
        }//end runAs
    }//end method
    
    
    static testMethod void bodyShop_Distributor_V2_OnUpdateTest() {
        system.debug('#### Start of method bodyShop_Distributor_V2_OnUpdateTest');
        
        system.runAs(userAdmin){
                users[0].BodyShopID__c = accounts[0].ReferenceNumber__c;
                users[1].BodyShopID__c = accounts[1].ReferenceNumber__c;
                insert users;
            test.starttest();   
                users[0].BodyShopID__c = null;
                users[1].BodyShopID__c = accounts[0].ReferenceNumber__c;
                update users;
            test.stoptest();
            
            list<GroupMember> groupMemberAssertList = [select UserOrGroupId, Id, GroupId, Group.Name 
                                                        from GroupMember 
                                                        where UserOrGroupId IN:users order by Group.Name];
                                                        
            //system.debug('//groupMemberAssertList4: ' + groupMemberAssertList);
            
            system.assertEquals(2,groupMemberAssertList.size());
            
            system.assertEquals(users[1].Id,groupMemberAssertList[0].UserOrGroupId);
            system.assertEquals(accounts[0].Name,groupMemberAssertList[0].Group.Name);
            
        }//end runAs
    }//end method
    
    
    static testMethod void bodyShop_Distributor_V3_OnUpdateTest() {
        system.debug('#### Start of method bodyShop_Distributor_V3_OnUpdateTest');
        
        users[0].BodyShopID__c = accounts[0].ReferenceNumber__c;
        users[1].DistributorID__c = accounts[2].ReferenceNumber__c;
        insert users;
        
        system.runAs(userAdmin){

            test.starttest();   
                users[0].BodyShopID__c = accounts[1].ReferenceNumber__c;
                users[1].DistributorID__c = accounts[3].ReferenceNumber__c;
                update users;
            test.stoptest();
            
            list<GroupMember> groupMemberAssertList = [select UserOrGroupId, Id, GroupId, Group.Name 
                                                        from GroupMember 
                                                        where UserOrGroupId IN:users order by Group.Name];
                                                        
            //system.debug('//groupMemberAssertList5: ' + groupMemberAssertList);
            
            system.assertEquals(2,groupMemberAssertList.size());
            
            system.assertEquals(users[0].Id,groupMemberAssertList[0].UserOrGroupId);
            system.assertEquals(accounts[1].Name,groupMemberAssertList[0].Group.Name);
            
            system.assertEquals(users[1].Id,groupMemberAssertList[1].UserOrGroupId);
            system.assertEquals(accounts[3].Name,groupMemberAssertList[1].Group.Name);
            
        }//end runAs
    }//end method
    */
}