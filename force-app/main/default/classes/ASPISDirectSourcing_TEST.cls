/*************************************************************************************
Class Name - ASPISDirectSourcing_TEST
Version - 1.0
Created Date - 23 MAY 2018
Function - Test class for ASPISDirectSourcing

Modification Log :
-------------------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------   -----------------------                    
* Dourga       19/07/2018   Original version
*************************************************************************************/   
@isTest
private class ASPISDirectSourcing_TEST {
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PartList__c> partLists;
    static BusinessHours defaultHours;
    static SLAConfiguration__c slaRecord;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;   
    static list <DirectOrder__c> directOrderList;

    static {
        // initialising variables
        accounts = new list <Account>();
        assessments = new list <Assessment__c>();
        partLists = new list<PartList__c>();
        countryCodeInfos = new list <CountryCodeInformationsMapping__c>();
        directOrderList = new list <DirectOrder__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            slaRecord = TestFactory.createSLAConfiguration(defaultHours);
            insert slaRecord;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');   
            bs1.ShippingPostalCode = '04008';
            accounts.add(bs1);

            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');   
            bs1.ShippingPostalCode = '04008';
            accounts.add(bs2);

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');   
            bs1.ShippingPostalCode = '08840';
            accounts.add(bs3);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            accounts.add(dist1);
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            accounts.add(dist2);

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'ES');
            accounts.add(dist3);
            
            Account dist4 = TestFactory.createAccountDistributor('Distributor_ScTest4', 'ES');
            accounts.add(dist4);

            insert accounts;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'ES';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
            ass1.TechDistAndDirectOrder__c = '{P0:0015800000e3wFfAAI-a0P25000006oKFOEA2;P0:0015800000e3wFfAAI-a0P25000006oKFOEA9},{P1:0015800000rv9FqAAI-a0P25000006oKFTEA2},{P2:00125000019WTkuAAG-a0P25000006oKFYEA2}';
            ass1.CapturedDistributors__c= 'P0-0015800000e3wFfAAI;P1-0015800000rv9FqAAI;P2-00125000019WTkuAAG;';
            assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            ass2.Entity__c = 'AXA Direct1';
            ass2.EntityRules__c = 'AXA Direct1';
            ass2.EntityCode__c = '213';
            ass2.BuildDate__c = date.today()+1;
            ass2.TECH_EntityCountryCode__c = 'ES';
            ass2.CrossReferences__c = 'njgnjrgnnn';
            ass2.PlateNumber2__c = '123';
            ass2.Status__c = 'SOURCED';
            ass2.AssessmentNumber__c = 'Num001';
            ass2.AssessmentID__c = 'Num002-2';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
            assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            ass3.Entity__c = 'AXA Direct2';
            ass3.EntityRules__c = 'AXA Direct2';
            ass3.TECH_EntityCountryCode__c = 'ES';
            ass3.EntityCode__c = '2999';
            ass3.Status__c = 'SOURCED';
            ass3.AssessmentNumber__c = 'Num001';
            ass3.AssessmentID__c = 'Num003-3';
            ass3.VINNumber__c = '444425';
            ass3.PlateNumber2__c = '1235552';
            ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
            assessments.add(ass3);  

            Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs2);
            ass4.Entity__c = '299';
            ass4.EntityRules__c = '299';
            ass4.TECH_EntityCountryCode__c = 'ES';
            ass4.EntityCode__c = '299';
            ass4.VINNumber__c = '444';
            ass4.Manufacturer__c = 'TOYOTA';
            ass4.ModelV2__c = 'PRIUS T4';
            ass4.PlateNumber2__c = '123';
            ass4.Status__c = 'NEW';
            ass4.AssessmentNumber__c = 'Num004';
            ass4.AssessmentID__c = 'Num004';
            ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
            assessments.add(ass4);

            insert assessments;

            PartList__c pl1 = TestFactory.createPartList(assessments[0]);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.Type__c = 'A';
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(assessments[0]);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Type__c = 'B';
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartList(assessments[0]);
            pl3.SelectedByBS__c = true;
            pl3.Type__c = 'A';
            pl3.TECH_OriginalPart__c = 'blabla-Num001-2-Numpl1-balbal';
            pl3.Quantity__c = 5;
            partLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(assessments[1]);
            pl4.SelectedByBS__c = true;
            pl4.Type__c = 'A';
            pl4.TECH_OriginalPart__c = 'blabla-Num001-1-Numpl1-balbal';
            pl4.Quantity__c = 5;    
            partLists.add(pl4);

            PartList__c pl5 = TestFactory.createPartList(assessments[1]);
            pl5.SelectedByBS__c = true;
            pl5.Type__c = 'A';
            pl5.TECH_OriginalPart__c = 'blabla-Num001-1-Numpl2-balbal';
            pl5.Quantity__c = 10;    
            partLists.add(pl5);

            PartList__c pl6 = TestFactory.createPartList(assessments[2]);
            pl6.SelectedByBS__c = true;
            pl6.Type__c = 'A';
            pl6.TECH_OriginalPart__c = 'blabla-Num001-2-Numpl2-balbal';
            pl6.Quantity__c = 5;
            partLists.add(pl6);

            PartList__c pl7 = TestFactory.createPartList(assessments[2]);
            pl7.SelectedByBS__c = true;
            pl7.Type__c = 'A';
            pl7.TECH_OriginalPart__c = 'blabla-Num001-Numpl3-balbal';
            partLists.add(pl7);

            PartList__c pl8 = TestFactory.createPartList(assessments[3]);
            pl8.SelectedByBS__c = true;
            pl8.Type__c = 'B';
            pl8.TECH_OriginalPart__c = 'blabla-Num001-Numpl4-balbal';
            partLists.add(pl8);

            PartList__c pl9 = TestFactory.createPartList(assessments[3]);
            pl9.SelectedByBS__c = true;
            pl9.Type__c = 'C';
            pl9.TECH_OriginalPart__c = 'blabla-Num005-Numpl5-balbal';
            partLists.add(pl9);

            PartList__c pl10 = TestFactory.createPartList(assessments[3]);
            pl10.SelectedByBS__c = true;
            pl10.Type__c = 'A';
            pl10.TECH_OriginalPart__c = 'blabla-Num006-Numpl6-balbal';
            partLists.add(pl10);

            insert partLists;

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            countryCodeInfos.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('ES',defaultHours.id);    
            countryCodeInfos.add(countryCode2);

            insert countryCodeInfos;

            DirectOrder__c dO1 = TestFactory.createDirectOrder(null, dist1.Id);
            dO1.State__c = '01;02;03;04;04;05;06;07';
            dO1.Part_Type__c = 'A';
            dO1.Priority__c = 'P0';
            dO1.Agency_mode__c = true;
            dO1.Active__c = true;
            dO1.Country__c = 'ES';
            dO1.Type__c = 'General';
            dO1.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO1);

            DirectOrder__c dO2 = TestFactory.createDirectOrder(bs1.Id, dist1.Id);
            dO2.State__c = '01;02;03;04;04;05;06;07';
            dO2.Part_Type__c = 'A';
            dO2.Priority__c = 'P0';
            dO2.Agency_mode__c = true;
            dO2.Active__c = true;
            dO2.Country__c = 'ES';
            dO2.Type__c = 'Exception';
            dO2.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO2.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO2);
            
            DirectOrder__c dO3 = TestFactory.createDirectOrder(bs2.Id, dist2.Id);
            dO3.State__c = '01;02;03;04;04;05;06;07';
            dO3.Part_Type__c = 'A;B';
            dO3.Priority__c = 'P0';
            dO3.Agency_mode__c = true;
            dO3.Active__c = true;
            dO3.Country__c = 'ES';
            dO3.Type__c = 'Exception';
            dO3.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO3.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO3);  

            DirectOrder__c dO4 = TestFactory.createDirectOrder(null, dist3.Id);
            dO4.State__c = '01;02;03;04;04;05;06;07';
            dO4.Part_Type__c = 'A;B';
            dO4.Priority__c = 'P0';
            dO4.Agency_mode__c = true;
            dO4.Active__c = true;
            dO4.Country__c = 'ES';
            dO4.Type__c = 'General';
            dO4.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO4.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO4);       

            DirectOrder__c dO5 = TestFactory.createDirectOrder(null, dist4.Id);  
            dO5.State__c = '01;02;03;04;04;05;06;07';
            dO5.Part_Type__c = 'A;B;C';
            dO5.Priority__c = 'P0';
            dO5.Agency_mode__c = true;
            dO5.Active__c = true;
            dO5.Country__c = 'ES';
            dO5.Type__c = 'General';
            dO5.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO5.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO5);

            DirectOrder__c dO6 = TestFactory.createDirectOrder(bs1.Id, dist2.Id);
            dO6.State__c = '01;02;03;04;04;05;06;07';
            dO6.Part_Type__c = 'A';
            dO6.Priority__c = 'P1';
            dO6.Agency_mode__c = true;
            dO6.Active__c = true;
            dO6.Country__c = 'ES';
            dO6.Type__c = 'Exception';
            dO6.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO6.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO6);

            DirectOrder__c dO7 = TestFactory.createDirectOrder(bs1.Id, dist3.Id);
            dO7.State__c = '01;02;03;04;04;05;06;07';
            dO7.Part_Type__c = 'A';
            dO7.Priority__c = 'P2';
            dO7.Agency_mode__c = true;
            dO7.Active__c = true;  
            dO7.Country__c = 'ES';
            dO7.Type__c = 'Exception';
            dO7.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO7.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO7);

            insert directOrderList;
            system.debug('## directOrderList' + directOrderList);
        }
    }   

    static testMethod void directSourcingTest() {
        System.Debug('>>> Start directSourcingTest');
        map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();
        System.runAs(userAdmin){
            test.starttest();     
                mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(assessments[0].TECH_EntityCountryCode__c,accounts[0].Id,assessments[0].Manufacturer__c ,'01', 'TOYOTA', new set<String>{'A'});
            test.stoptest();  

        }//end system.runas
        system.assertEquals(1, mapPartTypeDistributorsWrap.size());
        System.Debug('>>> End directSourcingTest');
    }  

    static testMethod void createPOTest() {
        System.Debug('>>> Start createPOTest');
        map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();
        System.runAs(userAdmin){
            test.starttest();  
                ASPISDirectSourcing.createPurchaseOrders(assessments[0], new list<Account>{accounts[3],accounts[4],accounts[5],accounts[6]}, null, null, null, null,'P0', new set<Id>{accounts[3].Id,accounts[4].Id,accounts[5].Id,accounts[6].Id},new Set<Id> {directOrderList[0].Id});
            test.stoptest();  

        }//end system.runas
        System.Debug('>>> End createPOTest');
    }  

    static testMethod void buildMapDisPrio() {

        system.runAs(userAdmin){
            test.starttest();  
                map<String,String> mapResult = ASPISDirectSourcing.buildMapDisPrio(',{P0:0012400000QkJcFAAV-a0P1i000000oLynEAE},{P1:0015800000jev9FAAQ-a0P1i000000oOfNEAU},,{P0:00158000004LZV3AAO-a0P1i000000oLyrEAE},');
            test.stoptest();  

        }//end system

    }

    static testMethod void removebrackedTest() {

        system.runAs(userAdmin){
            test.starttest();  
                ASPISDirectSourcing.removeBracket('{hello}');
            test.stoptest();  

        }//end system

    }
}