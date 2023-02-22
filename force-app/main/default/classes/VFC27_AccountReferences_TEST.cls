/*************************************************************************************
Class Name - VFC27_AccountReferences_TEST
Version - 1.0
Created Date - 01 SEPT 2020
Function - TestClass to VFC27_AccountReferences

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA      01/09/2020  Original Version
* 
*************************************************************************************/
@isTest
public class VFC27_AccountReferences_TEST {
    static User userAdmin;
    static Account testBodyshop;
    static AccountRef__c AccRef;
    
    static{
        
        //Create a User
        userAdmin = TestFactory.createUser('Admin1');
        
        System.runAs(userAdmin){
            //Create a BodyShop Account
            testBodyshop = TestFactory.createAccountBodyshop('testBS', 'FR');
            insert testBodyshop;
            
            //Create an Account Reference
            AccRef = TestFactory.createAccountRef('38483828', testBodyshop.Id , 'ASD_FT');
            insert AccRef;   
        }
    }
    
    @isTest static void test_AccountReferences() {
        System.runAs(userAdmin){
            Test.startTest();
            Test.setCurrentPage(Page.VFP27_AccountReferences);
            VFC27_AccountReferences VFC27 = new VFC27_AccountReferences(new ApexPages.StandardController(testBodyShop));
        }
    }
}