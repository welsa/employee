/*************************************************************************************
Class Name - ASPISAccountSharing_TEST
Version - 1.0
Created Date - 31 Mar 2016
Function - Test Class for ASPISAccountSharing

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             31/03/2016  Original Version
*************************************************************************************/
@isTest

private class ASPISAccountSharing_TEST{
    static list<Account> l_Accounts;
    static list<Account> updatedAccountsList;
    static list<user> l_users;
    static string refId;
    static string refId2;
    static string refId3;
    static List<Assessment__c> l_Assessments;    
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static User userBS;
    static User userBS2;
    static User userDist;
    static User userINTES;
    static list<AccountShare> accShareList;
    static map<String, String> grpNameMap;
    static map<String, String> refMap;
    static User user1;
    static User thisUser;

    static{
        
    
        // initialising variables
        l_Accounts = new list<Account>();
        l_users = new list<user>();
        refId= TestFactory.randomizeString('12345');
        refId2= TestFactory.randomizeString('123456');
        refId3= TestFactory.randomizeString('123456');
        updatedAccountsList= new list<Account>();  
        accShareList =  new list<AccountShare>();     
        
        
        l_Assessments = new list<Assessment__c>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        grpNameMap= new map<String, String>();
        refMap= new map<String, String>();

            
        // creating user
        thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runas(thisUser){
            user1 = TestFactory.createUser('ScUserTest');
            user1.BodyShopID__c = refId;
            l_users.add(user1);
            insert l_users;
        }
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            userBS = TestFactory.createUserBodyshop('ASE');
            userBS.ProfileId = [SELECT Id FROM Profile WHERE Name = 'BodyShop' LIMIT 1].Id;
            userBS.BodyShopID__c = refId2;
            userBS.UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleSpain'].Id;
            insert userBS;

            userDist = TestFactory.createUserDistributor('ASEDist');
            userDist.DistributorID__c = TestFactory.randomizeString('123456');
            insert userDist;
            
        
             // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ReferenceNumber__c = refId;
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ReferenceNumber__c = refId2;
            l_Accounts.add(bs2);   

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest3', 'ES');
            bs3.ReferenceNumber__c = refId3;
            l_Accounts.add(bs3); 

            Account bs4 = TestFactory.createAccountBodyshop('BodyShop_ScTest4', 'ES');
            l_Accounts.add(bs4); 

            Account bs5 = TestFactory.createAccountBodyshop('BodyShop_ScTest5', 'ES');
            l_Accounts.add(bs5); 

            Account dist1 = TestFactory.createAccountDistributor('Dist_ScTest5', 'ES');
            l_Accounts.add(dist1); 

            insert l_Accounts;  

            userBS2 = TestFactory.createUserBodyshop('ASE');
            userBS2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'BodyShop' LIMIT 1].Id;
            userBS2.BodyShopID__c = refId3;
            userBS2.UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleSpain'].Id;
            insert userBS2;

            updatedAccountsList= new list<Account>{new Account(Id = bs2.Id, ParentId = bs1.id),
                                                   new Account(Id = bs3.Id, ParentId = bs2.id),
                                                   new Account(Id = bs4.Id, ParentId = bs3.id),
                                                   new Account(Id = bs5.Id, ParentId = bs1.id)
                                                   
            };
            update updatedAccountsList;

            userINTES = TestFactory.createUserIntegration('ASEINT');
            insert userINTES;
        }

        system.runas(userINTES){
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', l_Accounts[1]);
            ass1.TECH_EntityCountryCode__c= 'ES';
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
            insert l_Assessments;
        }

        system.runas(l_users[0]){
            // sharing with role 
            Id groupId= [SELECT Id from Group where Type= 'Role' and RelatedId = :[Select Id from UserRole where DeveloperName='AlphaScaleSpain'].Id].Id;
            Assessment__Share aShare = new Assessment__Share (UserOrGroupId = groupId,ParentId=l_Assessments[0].Id,AccessLevel='Edit');
            insert aShare;
        
            // Create SO
            PrerequisiteOrder__c so4 = TestFactory.createSalesOrder(l_Assessments[0], l_Accounts[1], 'INDELIVERY');
            l_SalesOrders.add(so4);       
            insert l_SalesOrders;                       
        }
    }


    static testMethod void ASPISBatchAccountSharingTest() {    
       try{ 
            system.runas(l_users[0]){
                Test.startTest();

                Database.executeBatch(new ASPISBatchAccountSharing(), 200); 
                
                Test.stopTest(); 
            }
            
           /*  set<String> x = new set<String>(); 
            for(account acc: [Select ReferenceNumber__c from Account where id = : l_Accounts]){
                x.add(acc.ReferenceNumber__c);
            }
*/            
            system.runas(userBS){
                Assessment__c updAssessment = new Assessment__c(id= l_Assessments[0].Id,BodyShop__c = l_Accounts[0].Id);
                update updAssessment;
            }
            
            System.assertEquals(l_Accounts[0].Id,[Select BodyShop__c from PrerequisiteOrder__c where id = : l_SalesOrders[0].Id].BodyShop__c);    
        }
        catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage()); 
        } 
    }
}