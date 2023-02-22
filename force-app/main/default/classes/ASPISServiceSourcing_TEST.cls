/*************************************************************************************
Class Name - ASPISServiceSourcing_TEST
Version - 1.0
Created Date - 25 FEB 2016
Function - TestClass for ASPISServiceEligibility

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date           Description
* ----------    ----------     -----------------------
* Dourga        01/03/2016     Reworked Version
* AMI           12/02/2018     Updating param for processObjForSourcing method (distv2 integration)
*************************************************************************************/
@isTest
private class ASPISServiceSourcing_TEST {
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list <MasterRules__c> masterRuleList;
    static list <DetailRule__c> detailRuleList;
    static BusinessHours defaultHours;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;
    static list<CaseDetailsProcessMapping__c> caseDetailsProcessMapping;
    static SLAConfiguration__c slaRecord;

    static {
        // initialising variables
        accounts = new list <Account>();
        assessments = new list <Assessment__c>();
        masterRuleList = new list <MasterRules__c>();
        detailRuleList = new list <DetailRule__c>();
        countryCodeInfos = new list <CountryCodeInformationsMapping__c>();
        caseDetailsProcessMapping = new list<CaseDetailsProcessMapping__c> ();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            slaRecord = TestFactory.createSLAConfiguration(defaultHours);
            insert slaRecord;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', '');   
            bs1.ReferenceNumber__c = 'FR0000000002';
            accounts.add(bs1);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Categories__c='';
            accounts.add(dist1);
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist2.Categories__c='';
            accounts.add(dist2);

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist3.Categories__c='';
            accounts.add(dist3);
            
            Account dist4 = TestFactory.createAccountDistributor('Distributor_ScTest4', 'FR');
            dist4.Categories__c='';
            accounts.add(dist4);

            insert accounts;
            
            MasterRules__c mr1 = TestFactory.createMasterRule('AXA Direct', 'Sourcing', 'Assessment__c');
            mr1.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            masterRuleList.add(mr1);

            insert masterRuleList;

            DetailRule__c dr1 = TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1);
            dr1.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2);
            dr2.ValueFrom__c = 'Criteria sObject';
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'Categories__c', 'IN', 'PartTypes__c', 'Filter Condition', 'Account', 3);
            dr3.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4);
            dr4.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr4);

            insert detailRuleList;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.PartA__c  = 1;
            ass1.PartB__c  = 1;
            ass1.PartC__c  = 1;
            ass1.VINNumber__c = '444';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.TECH_EntityCountryCode__c = 'FR';
            assessments.add(ass1);

            insert assessments;

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            countryCodeInfos.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);    
            countryCodeInfos.add(countryCode2);

            insert countryCodeInfos;

            caseDetailsProcessMapping = TestFactory.createCaseDetailsProcessMapping();

        }
    }   

    static testMethod void sourcingCreateCaseTest() {
        System.Debug('>>> Start sourcingCreateCaseTest');
        System.runAs(userAdmin){
            assessments[0].TECH_EntityCountryCode__c = 'FR';
            assessments[0].PartA__c  = 0;
            assessments[0].PartB__c  = 0;
            assessments[0].PartC__c  = 0;
            update assessments[0];

            test.starttest();  
                //AMI 12/02/18 - Updating param for processObjForSourcing method (distv2 integration)
                ASPISServiceSourcing.sourcingWrapper sourWrapp = ASPISServiceSourcing.processObjForSourcing(assessments[0], true,new map <id, Account>(),new map <string,string>());
            test.stoptest(); 
            system.assertEquals(0,sourWrapp.distributorLst.size());
        }//end system.runas
        System.Debug('>>> End sourcingCreateCaseTest'); 
    }

    static testMethod void sourcingCreateCaseTriggerTest() {
        System.Debug('>>> Start sourcingCreateCaseTest');
        System.runAs(userAdmin){
            assessments[0].TECH_EntityCountryCode__c = 'FR';
            assessments[0].PartA__c  = 0;
            assessments[0].PartB__c  = 0;
            assessments[0].PartC__c  = 0;
            update assessments[0];

            test.starttest();  
                //AMI 12/02/18 - Updating param for processObjForSourcing method (distv2 integration)
                ASPISServiceSourcing.sourcingWrapper sourWrapp = ASPISServiceSourcing.processObjForSourcing(assessments[0], true,new map <id, Account>(),new map <string,string>());
            test.stoptest(); 
            system.assertEquals(0,sourWrapp.distributorLst.size());
        }//end system.runas
        System.Debug('>>> End sourcingCreateCaseTest'); 
    }


    static testMethod void sourcingTest() {
        System.Debug('>>> Start sourcingTest');
        System.runAs(userAdmin){
            accounts[0].ShippingCountryCode = 'FR';
            update accounts;
            system.debug('##q1'+database.query('SELECT Id , DistributorRegionsCovered__c, Categories__c, RecordType.Name, ShippingCountry FROM Account WHERE (ShippingCountry = \'France\' AND RecordType.Name = \'DISTRIBUTOR\' AND Categories__c includes (\'\') AND DistributorRegionsCovered__c includes (\'\'))'));
            system.debug('##q2'+database.query('SELECT Id , DistributorRegionsCovered__c, Categories__c, RecordType.Name, ShippingCountry FROM Account WHERE Id <> null'));
            test.starttest();  
                //AMI 12/02/18 - Updating param for processObjForSourcing method (distv2 integration)
                ASPISServiceSourcing.sourcingWrapper sourWrapp = ASPISServiceSourcing.processObjForSourcing(assessments[0], true,new map <id, Account>(),new map <string,string>());
            test.stoptest();  

            system.assertEquals(4,sourWrapp.distributorLst.size());
        }//end system.runas
        System.Debug('>>> End sourcingTest');
    }  


    static testMethod void sourcingClaimTriggerTest() {
        System.Debug('>>> Start sourcingTest');
        System.runAs(userAdmin){
            accounts[0].ShippingCountryCode = 'FR';
            update accounts;

            assessments[0].RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            update assessments[0];

            test.starttest();  
                //AMI 12/02/18 - Updating param for processObjForSourcing method (distv2 integration)
                ASPISServiceSourcing.sourcingWrapper sourWrapp = ASPISServiceSourcing.processObjForSourcing(assessments[0], true,new map <id, Account>(),new map <string,string>());
            test.stoptest();  

            system.assertEquals(4,sourWrapp.distributorLst.size());
        }//end system.runas
        System.Debug('>>> End sourcingTest');
    }  


    static testMethod void sourcingClaimTest() {
        System.Debug('>>> Start sourcingTest');
        System.runAs(userAdmin){
            accounts[0].ShippingCountryCode = 'FR';
            update accounts;

            assessments[0].RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments[0].MRSourcing__c = accounts[0].Id + ';' + accounts[1].Id ;
            assessments[0].TECHRulesAppliedDescription__c = 'Eligibility';
            update assessments[0];

            test.starttest();  
                //AMI 12/02/18 - Updating param for processObjForSourcing method (distv2 integration)
                ASPISServiceSourcing.sourcingWrapper sourWrapp = ASPISServiceSourcing.processObjForSourcing(assessments[0], true,new map <id, Account>(),new map <string,string>());
            test.stoptest();  

            system.assertEquals(5,sourWrapp.distributorLst.size());
        }//end system.runas
        System.Debug('>>> End sourcingTest');
    }         
}