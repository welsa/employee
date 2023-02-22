/*************************************************************************************
Class Name - PartListRejectAssessmentChildren_TEST
Version - 1.0
Created Date - 02 MAY 2016
Function - Test Class for class PartListRejectAssessmentChildren

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      02/05/2016  Reworked Version
*************************************************************************************/
@isTest
private class PartListRejectAssessmentChildren_TEST {
	
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PartList__c> partLists;

    static {
	    // initialising variables
	    accounts = new list <Account>();
	    assessments = new list <Assessment__c>();
        partLists = new list <PartList__c>();

        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

        	Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.isEligible__c = true;
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            accounts.add(bs2);    

            insert accounts;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';
            assessments.add(ass1);

            insert assessments;


            PartList__c pl1 = TestFactory.createPartList(assessments[0]);
            partLists.add(pl1);

            insert partLists;
        }
    }

    static testmethod void testInvoke(){
    	System.runAs(userAdmin){
	    	test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
				PartListRejectAssessmentChildren.invoke(new list<ID>{assessments[0].id});
			test.stoptest();
			List<PartList__c> listPartLists = new List<PartList__c>([select id
																	from PartList__c
																	where Assessment__c=:assessments[0].Id]);
			System.assertEquals(0, listPartLists.size());
		}
    }
}