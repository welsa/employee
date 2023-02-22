/*************************************************************************************
Class Name - AP37AssessmentAgencyModeQueueable_TEST
Version - 1.0
Created Date - 15 MAY 2017
Function - TestClass for AP37AssessmentAgencyModeQueueable

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      15/05/2017  Original Version
*************************************************************************************/
@isTest
private class AP37AssessmentAgencyModeQueueable_TEST {
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;

    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();
        
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'DE');
            bs1.ContactUser__c = l_users[0].Id;
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'DE';
            //l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'DE');
            bs2.ContactUser__c = l_users[0].Id;
            bs2.CarBrandsSuppliedAgency__c = 'MERCEDES;PORSCHE;';
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'DE');
            dist1.CarBrandsSuppliedAgency__c = 'MERCEDES;PORSCHE;';
            l_Accounts.add(dist1);
            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            ass1.AssessmentID__c = '0912';
            ass1.Manufacturer__c = 'MERCEDES';
            ass1.TECH_EntityCountryCode__c = 'DE';
            l_Assessments.add(ass1);            
            insert l_Assessments;
            // Create several Purchase Orders. 
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, (new PrerequisiteOrder__c()), bs2, dist1, '');
            l_purchaseOrders.add(po1_1);
            

            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DE',defaultHours.id);
            countryCode1.CarBrandsSuppliedAgency__c = 'MERCEDES';
            l_cs_CountryCodeIngformation.add(countryCode1);
            insert l_cs_CountryCodeIngformation;
        }
    }

    static testMethod void AP37AssessmentAgencyModeQueueableTest() {    
       system.runas(l_users[0]){ 
            test.startTest();
                insert l_purchaseOrders;
            test.stopTest();

            system.assert(true, [select Id , AgencyMode__c from Assessment__c where id =: l_Assessments[0].Id].AgencyMode__c);
        }
    }
}