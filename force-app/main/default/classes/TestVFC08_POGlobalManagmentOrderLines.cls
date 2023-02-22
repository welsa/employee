// TO BE DELETED
/*************************************************************************************
Class Name - TestVFC08_POGlobalManagmentOrderLines
Version - 1.0
Created Date - 22 OCT 2015
Function - test class for TestVFC08_POGlobalManagmentOrderLines

Modification Log :
-----------------------------------------------------------------------------
* Developer        Date        Description
* ----------   	----------  -----------------------
* Cécile L		09/06/2015	Original Version
* Dourga U     	19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
************************************************************************************/
@isTest
private class TestVFC08_POGlobalManagmentOrderLines {
    /*
    static list<User> users;
    static list<OrderLine__c> orderLineList;
    static List<PurchaseOrder__c> purchaseOrders;
    
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
        
        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();
            
            // 2 Bodyshops, 1 ES and 1 FR.
            Account BodyshopES = ASPISTestUtils.accounts[0];
            Account BodyshopFR = ASPISTestUtils.accounts[1];
            BodyshopES.ShippingCountryCode = 'ES';
            BodyshopFR.ShippingCountryCode = 'FR';
            update ASPISTestUtils.accounts;
            
            // Assessment with Bodyshop FR
            ASPISTestUtils.assessments[0].BodyShop__c = BodyshopFR.Id;
			ASPISTestUtils.assessments[0].TECH_EntityCountryCode__c = 'FR';
            // Assessment with Bodyshop ES
            ASPISTestUtils.assessments[1].BodyShop__c = BodyshopES.Id;
			ASPISTestUtils.assessments[1].TECH_EntityCountryCode__c = 'ES';
            update ASPISTestUtils.assessments;
            
            purchaseOrders = new list<PurchaseOrder__c> {
                // Purchase Order with Bodyshop ES
                new PurchaseOrder__c (
                    Distributor__c = ASPISTestUtils.accounts[2].Id,
                    ValidityDate__c=date.today(),
                    Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                    Assessment__c=ASPISTestUtils.assessments[1].id
                ),
				// Purchase Order with Bodyshop FR
				new PurchaseOrder__c(
                    Distributor__c = ASPISTestUtils.accounts[2].Id,
                    ValidityDate__c=date.today(),
                    Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                    Assessment__c=ASPISTestUtils.assessments[0].id
                )
			};
            insert purchaseOrders;
            
            purchaseOrders = [SELECT Id, Assessment__c, TECH_AssessmentCountryCode__c FROM PurchaseOrder__c WHERE Id IN :purchaseOrders];
            
            List<CountryCodeInformationsMapping__c> configs = new List<CountryCodeInformationsMapping__c> {
                new CountryCodeInformationsMapping__c(
                    Name = 'ES',
                    BusinessHoursID__c = ASPISTestUtils.defaultHours.Id,
                    UseAdvancedDiscountManagement__c = TRUE
                ),
                    new CountryCodeInformationsMapping__c(
                        Name = 'FR',
                        BusinessHoursID__c = ASPISTestUtils.defaultHours.Id,
                        UseAdvancedDiscountManagement__c = FALSE
                    )
                    };
                        insert configs;
        }
    }
    
    static testMethod void testVFC08_POGlobalManagmentOrderLines(){
        system.runAs(users[0]){
            test.starttest();
            VFC08_POGlobalManagmentOrderLines ctrl1 = new VFC08_POGlobalManagmentOrderLines(new ApexPages.StandardController(purchaseOrders[0]));
            VFC08_POGlobalManagmentOrderLines ctrl2 = new VFC08_POGlobalManagmentOrderLines(new ApexPages.StandardController(purchaseOrders[1]));
            
            System.debug('######## PO1 '+purchaseOrders[0].TECH_AssessmentCountryCode__c);
            System.debug('######## PO2 '+purchaseOrders[1].TECH_AssessmentCountryCode__c);
            test.stoptest();
            System.assertEquals(TRUE, ctrl1.useDiscountManagement);
            System.assertEquals(FALSE, ctrl2.useDiscountManagement);
        }
    }
    */
}