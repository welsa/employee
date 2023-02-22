/***
* @author      Telesio Consultant
* @date        08/02/2022 
* @description Test class for b2g_RepaircenterSelection_CTL 
* @group       B2G 
* @see         
***/
@isTest
public with sharing class b2g_RepaircenterSelection_CTL_TST {
    static user userAdmin;

    static{
        userAdmin = TestFactory.createUser('adminUser');
        insert userAdmin;

        System.runAs(userAdmin){
            //Insert parent Glacier
            Account accMPBParent = new Account(
                Name = 'MPB - Parent',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('b2g_RepairCenter').getRecordTypeId(),
                b2g_BrandCodeId__c = 'MPB',
                b2g_ProximityPoints__c = 10, 
                b2g_BrandPoints__c = 10,
                b2g_ProximityRange__c = 5,
                ReferenceNumber__c = 'MPBPARENT000'
            );
            insert accMPBParent;

            //Insert child Glacier
            Account accMPB = new Account(
                Name = 'MPB',
                ParentId = accMPBParent.Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('b2g_RepairCenter').getRecordTypeId(),
                b2g_branchId__c = '00991122',
                BillingCountry = 'France',
                BillingCity = 'PARIS',
                BillingStreet = '133, rue Amelot',
                BillingPostalCode = '75011',
                BillingLatitude = 48.86444,
                BillingLongitude = 2.36662,
                ReferenceNumber__c = 'MPB0001'
            );
            insert accMPB;

            //Insert child Glacier
            Account accMPB2 = new Account(
                Name = 'MPB',
                ParentId = accMPBParent.Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('b2g_RepairCenter').getRecordTypeId(),
                b2g_branchId__c = '00991122',
                BillingCountry = 'France',
                BillingCity = 'PARIS',
                BillingStreet = '133, rue Amelot',
                BillingPostalCode = '75011',
                BillingLatitude = 48.86444,
                BillingLongitude = 2.36662,
                ReferenceNumber__c = 'MPB0002'
            );
            insert accMPB2;

            //Insert B2G Permission Set Assignment for admin
            PermissionSet psB2G = [SELECT Id FROM PermissionSet WHERE Name = 'B2G'];
            insert new PermissionSetAssignment(AssigneeId = userAdmin.id, PermissionSetId = psB2G.Id);
        }
    }

	@isTest 
    static void TestGetRepaircenters(){
        System.debug('TestGetRepaircenters START 0');
		System.runAs(userAdmin){
            System.debug('TestGetRepaircenters START');
            Test.startTest();
			List<Account> accs = b2g_RepaircenterSelection_CTL.getRepaircenters(48.86444, 2.36662, 100, 100);
            System.assert(accs.size() > 0);
            Test.stopTest();
            System.debug('TestGetRepaircenters END');
		}
	}
}