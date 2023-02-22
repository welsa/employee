@isTest
private class AlphaStore_TEST{
/*************************************************************************************
Class Name - AlphaStore_TEST
Version - 1.0
Created Date - 26 November 2018
Function - TestClass to AlphaStore

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Abdool M      26/11/2018  Initial Version (VfC09 copy --> due to css 
*												 issues to adapt in r4)
*************************************************************************************/
    static User userAdmin;
    static list<UserRole> l_userRole;
    static BusinessHours defaultHours;
    static list<Account> l_Accounts;
    static list <GlobalVariables__c> cs_GlobalVariables;
    static MasterRules__c ruleSet;
    static list <MasterRules__c> l_masterRule;
    static list <DetailRule__c> l_detailRule;
    static list <DirectOrder__c> l_directOrder;
    static list <Distributor_reference__c> l_DistributorReference; 
    static list <Manufacturer_reference__c> l_ManufacturerReference;
    static CountryCodeInformationsMapping__c cs;

    static{
        l_Accounts = new list<Account>();
        cs_GlobalVariables = new list <GlobalVariables__c>();
        l_masterRule = new list <MasterRules__c>();
        l_detailRule = new list <DetailRule__c>();
        l_directOrder = new list <DirectOrder__c>();
        l_DistributorReference = new list <Distributor_reference__c>(); 
        l_ManufacturerReference = new list <Manufacturer_reference__c>(); 
        l_Accounts = new list<Account>();
        l_userRole = new list<UserRole>();
        cs = new CountryCodeInformationsMapping__c ();

        UserRole userRole1 = new UserRole(Name = 'BodyShop-Spain', DeveloperName = 'BodyShopTwo');
        l_userRole.add(userRole1);
        UserRole userRole2 = new UserRole(Name = 'Distributor-Spain', DeveloperName = 'DistributorTwo');
        l_userRole.add(userRole2);
        insert l_userRole;

        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.LastName = 'KurryJack';
        userAdmin.FirstName = '';
        userAdmin.BodyShopId__c = '1245';
        insert userAdmin;

        system.runas(userAdmin){
            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            cs = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            insert cs;
            
            Account bs1 = TestFactory.createAccountBodyshop('KurryJack', 'ES');
            bs1.ReferenceNumber__c = '1245';
            bs1.Name = 'KurryJack';
            bs1.VAT__c = 21;
            bs1.isEligible__c = true;    
            l_Accounts.add(bs1);

            Account bs2 = TestFactory.createAccountBodyshop('JeanBalack', 'ES');
            bs2.ReferenceNumber__c = '1246';
            bs2.VAT__c = 21;
            l_Accounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            dist1.ReferenceNumber__c = '12745';
            dist1.Name = 'Distributor_ScTest1';
            dist1.VAT__c = 21;
            dist1.Categories__c = 'P';
            l_Accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            dist2.ReferenceNumber__c = '12945';
            dist2.VAT__c = 21;
            l_Accounts.add(dist2);

            insert l_Accounts;

            GlobalVariables__c gb1 = TestFactory.createGlobalVariable('Assessment__c', '1.1', 'Process', 'Eligibility', 'READY');
            cs_GlobalVariables.add(gb1);

            GlobalVariables__c gb2 = TestFactory.createGlobalVariable('Assessment__c', '2.0', 'Process', 'Sourcing', 'CHECKED');
            cs_GlobalVariables.add(gb2);

            GlobalVariables__c gb3 = TestFactory.createGlobalVariable('Assessment__c', '3.0', 'Process', 'Offering', 'OFFERING');
            cs_GlobalVariables.add(gb3);

            GlobalVariables__c gb4 = TestFactory.createGlobalVariable('PrerequisiteOrder__c', '3.2', 'Process', 'PrerequisiteOrder', 'RESPONDED');
            cs_GlobalVariables.add(gb4);

            insert cs_GlobalVariables;

            ruleSet = TestFactory.createMasterRule('ES05', 'PAINTING', 'ES05');
            ruleSet.AutomaticProcess__c = True;
            ruleSet.RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Rule Set').getRecordTypeId();
            insert ruleSet;

            MasterRules__c mr1 = TestFactory.createMasterRule('ES05', 'ELIGIBILITY', 'Assessment__c');
            mr1.FilterLogic__c = '(1 AND 2)';
            mr1.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr1);

            MasterRules__c mr2 = TestFactory.createMasterRule('ES05', 'Sourcing', 'Assessment__c');
            mr2.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            mr2.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr2);

            MasterRules__c mr3 = TestFactory.createMasterRule('ES05', 'Offering', 'Assessment__c');
            mr3.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr3);

            insert l_masterRule;

            DetailRule__c dr1 = TestFactory.createDetailRule('Eligibility', l_masterRule[0], 'BodyShopIsEligible__c', 'EQUALS', 'TRUE', 'Filter Condition', 'Assessment__c', 1);
            l_detailRule.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Eligibility', l_masterRule[0], 'RepairsAuthorised__c', 'EQUALS', 'FALSE', 'Filter Condition', 'Assessment__c', 2);
            l_detailRule.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1);
            dr3.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2);
            dr4.ValueFrom__c = 'Criteria sObject';
            l_detailRule.add(dr4);
            
            DetailRule__c dr5 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'Categories__c', 'IN', 'PartTypes__c', 'Filter Condition', 'Account', 3);
            dr5.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr5);
            
            DetailRule__c dr6 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4);
            dr6.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr6);
            
            DetailRule__c dr7 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'PartList__c', 'GROUPBY', ' 0.1', 'Group By Criteria', 'OrderLine__c', 1);
            l_detailRule.add(dr7);
            
            DetailRule__c dr8 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'TECH_SLARulesFR__c', 'AGMAX', ' 0.1', 'Aggregate Criteria', 'OrderLine__c', 2);
            dr8.Alias__c = 'MAXEDD';
            l_detailRule.add(dr8);
            
            DetailRule__c dr9 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'ASMarginDiscount__c', 'AGMAX', '1', 'Aggregate Criteria', 'OrderLine__c', 3);
            dr9.Alias__c = 'AVGMAR';
            l_detailRule.add(dr9);
            
            DetailRule__c dr10 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'MAXEDD', 'EQUALS', '1', 'Criteria', 'OrderLine__c', 4);
            l_detailRule.add(dr10);
            
            DetailRule__c dr11 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'AVGMAR', 'NOT_EQUALS', '1', 'Criteria', 'OrderLine__c', 5);
            l_detailRule.add(dr11);
            
            DetailRule__c dr12 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'id', 'GROUPBY', '1', 'Group By Criteria', 'OrderLine__c', 6);
            l_detailRule.add(dr12);

            insert l_detailRule;

            DirectOrder__c dO1 = TestFactory.createDirectOrder(bs1.Id, dist1.Id);
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Painting').getRecordTypeId();
            l_directOrder.add(dO1);

            //insert l_directOrder;

            Manufacturer_reference__c manuRef1 =TestFactory.createManufacturerReference('AUDI', 'Color', 'Red', 2, 'L');
            l_ManufacturerReference.add(manuRef1);

            Manufacturer_reference__c manuRef2 =TestFactory.createManufacturerReference('AUDI', 'Color', 'Blue', 2, 'L');
            l_ManufacturerReference.add(manuRef2);

            insert l_ManufacturerReference;


            Distributor_reference__c disRef1 = TestFactory.createDistributorReference(manuRef1.Id, dist1.Id, 100, 10, 10);
            l_DistributorReference.add(disRef1);

            Distributor_reference__c disRef2 = TestFactory.createDistributorReference(manuRef1.Id, dist1.Id, 200, 10, 10);
            l_DistributorReference.add(disRef2);

            Distributor_reference__c disRef3 = TestFactory.createDistributorReference(manuRef2.Id, dist1.Id, 100, 10, 10);
            l_DistributorReference.add(disRef3);

            Distributor_reference__c disRef4 = TestFactory.createDistributorReference(manuRef2.Id, dist1.Id, 200, 10, 10);
            l_DistributorReference.add(disRef4);

            Distributor_reference__c disRef5 = TestFactory.createDistributorReference(manuRef2.Id, dist1.Id, 300, 10, 10);
            l_DistributorReference.add(disRef5);

            insert l_DistributorReference;      
        }
    }

    @isTest static void test_InsertAssessment() {
        system.debug('#### Start of test_InsertAssessment');
        userAdmin.UserRoleId = l_userRole[0].Id;
        update userAdmin;

        system.runAs(userAdmin){    
            insert l_directOrder;

            list <Distributor_reference__c> l_DistributorReferenceSelected = [select Id, AS_public_price__c,BSPrice__c, Discount__c, Distributor_public_price__c,ASDiscount__c,BSDiscount__c,
                                                                                Distributor__r.Name, Manufacturer_reference__r.Unit__c, Manufacturer_reference__r.ClaimNumber__c,
                                                                                Manufacturer_reference__r.Type__c, Manufacturer_reference__r.Description__c,
                                                                                Manufacturer_reference__r.Family__c, Manufacturer_reference__r.Manufacturer_ID__c,
                                                                                Manufacturer_reference__r.Brand__c, Manufacturer_reference__r.Name, 
                                                                                Manufacturer_reference__r.Minimum_quantity__c, Manufacturer_reference__r.Recordtype.DeveloperName,
                                                                                Active_country__c
                                                                            from Distributor_reference__c
                                                                            where Id <> null];
            Map <Id, Distributor_reference__c> mapIdDiSRef = new Map <Id, Distributor_reference__c>();
            mapIdDiSRef.put(l_DistributorReferenceSelected[0].Id,l_DistributorReferenceSelected[0]);
            mapIdDiSRef.put(l_DistributorReferenceSelected[3].Id,l_DistributorReferenceSelected[3]);

            Map <Id,Integer> mapIdQuantity = new Map <Id,Integer>();
            mapIdQuantity.put(l_DistributorReferenceSelected[0].Id,10);
            mapIdQuantity.put(l_DistributorReferenceSelected[3].Id,13);

            test.starttest();

                AlphaStore controller = new AlphaStore();

                controller.manufacturer = 'AUDI';
                controller.family = 'Color';
                controller.distributor = 'AUDI';
                controller.bodyshop = l_Accounts[1].Name;
                controller.rtType = 'Painting';

                controller.getFamilyOptions();
                controller.getBrandOptions();
                controller.getDistributorOptions();
                controller.getBodyShopOptions();
                controller.brandFamilyResults();
                controller.getFamilyOptions();
                controller.getBrandOptions();
                controller.getRecordTypeOptions();
                controller.typeResults();

                AlphaStore.partListDisplay('','','','Painting');

                AlphaStore.saveAssPL(mapIdDiSRef, mapIdQuantity, '1245', '2646','12745','');


            test.stoptest();
            System.assertEquals([select Id from Assessment__c where id <> null].size() , 1);
            System.assertEquals([select Id,Assessment__c from PartList__c where id <> null].size() , 2);
        }
    }

    @isTest static void test_InsertAssessmentDis() {
        system.debug('#### Start of test_InsertAssessment');
        User userAdmin2 = TestFactory.createUser('ScUserTest');
        userAdmin2.LastName = 'JeanBalack';
        userAdmin2.FirstName = '';
        userAdmin2.DistributorId__c = '12745';
        userAdmin2.UserRoleId = l_userRole[1].Id;
        insert userAdmin2;

        system.runAs(userAdmin2){    
            insert l_directOrder;

            list <Distributor_reference__c> l_DistributorReferenceSelected = [select Id, AS_public_price__c,BSPrice__c, Discount__c, Distributor_public_price__c,ASDiscount__c,BSDiscount__c,
                                                                                Distributor__r.Name, Manufacturer_reference__r.Unit__c,  Manufacturer_reference__r.ClaimNumber__c,
                                                                                Manufacturer_reference__r.Type__c, Manufacturer_reference__r.Description__c,
                                                                                Manufacturer_reference__r.Family__c, Manufacturer_reference__r.Manufacturer_ID__c,
                                                                                Manufacturer_reference__r.Brand__c, Manufacturer_reference__r.Name, 
                                                                                Manufacturer_reference__r.Minimum_quantity__c, Manufacturer_reference__r.Recordtype.DeveloperName,
                                                                                Active_country__c
                                                                            from Distributor_reference__c
                                                                            where Id <> null];
            Map <Id, Distributor_reference__c> mapIdDiSRef = new Map <Id, Distributor_reference__c>();
            mapIdDiSRef.put(l_DistributorReferenceSelected[0].Id,l_DistributorReferenceSelected[0]);
            mapIdDiSRef.put(l_DistributorReferenceSelected[3].Id,l_DistributorReferenceSelected[3]);

            Map <Id,Integer> mapIdQuantity = new Map <Id,Integer>();
            mapIdQuantity.put(l_DistributorReferenceSelected[0].Id,10);
            mapIdQuantity.put(l_DistributorReferenceSelected[3].Id,13);

            test.starttest();

                AlphaStore controller = new AlphaStore();

                controller.manufacturer = 'AUDI';
                controller.family = 'Color';
                controller.distributor = '12745';
                controller.bodyshop = l_Accounts[1].Name;

                controller.getFamilyOptions();
                controller.getBrandOptions();
                controller.getDistributorOptions();
                controller.getBodyShopOptions();
                controller.brandFamilyResults();
                controller.getFamilyOptions();
                controller.getBrandOptions();

                AlphaStore.partListDisplay('','','','');

                AlphaStore.saveAssPL(mapIdDiSRef, mapIdQuantity, '1245', '2646','12745','');

            test.stoptest();
            System.assertEquals([select Id from Assessment__c where id <> null].size() , 1);
            System.assertEquals([select Id,Assessment__c from PartList__c where id <> null].size() , 2);
        }
    }

    @isTest static void test_InsertAssessmentBS() {
        system.debug('#### Start of test_InsertAssessment2');

        system.runAs(userAdmin){  

            DirectOrder__c dO2 = TestFactory.createDirectOrder(l_Accounts[0].Id, l_Accounts[3].Id);
            dO2.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Painting').getRecordTypeId();

            l_directOrder.add(dO2);

            DirectOrder__c dO3 = TestFactory.createDirectOrder(l_Accounts[1].Id, l_Accounts[2].Id);
            dO3.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Painting').getRecordTypeId();

            l_directOrder.add(dO3);

            DirectOrder__c dO4 = TestFactory.createDirectOrder(l_Accounts[1].Id, l_Accounts[3].Id);
            dO4.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Painting').getRecordTypeId();

            l_directOrder.add(dO4);

            insert l_directOrder;

            list <Distributor_reference__c> l_DistributorReferenceSelected = [select Id, AS_public_price__c,BSPrice__c, Discount__c, Distributor_public_price__c,ASDiscount__c,BSDiscount__c,
                                                                                Distributor__r.Name, Manufacturer_reference__r.Unit__c,  Manufacturer_reference__r.ClaimNumber__c,
                                                                                Manufacturer_reference__r.Type__c, Manufacturer_reference__r.Description__c,
                                                                                Manufacturer_reference__r.Family__c, Manufacturer_reference__r.Manufacturer_ID__c,
                                                                                Manufacturer_reference__r.Brand__c, Manufacturer_reference__r.Name, 
                                                                                Manufacturer_reference__r.Minimum_quantity__c, Manufacturer_reference__r.Recordtype.DeveloperName,
                                                                                Active_country__c
                                                                            from Distributor_reference__c
                                                                            where Id <> null];
            Map <Id, Distributor_reference__c> mapIdDiSRef = new Map <Id, Distributor_reference__c>();
            mapIdDiSRef.put(l_DistributorReferenceSelected[0].Id,l_DistributorReferenceSelected[0]);
            mapIdDiSRef.put(l_DistributorReferenceSelected[3].Id,l_DistributorReferenceSelected[3]);

            Map <Id,Integer> mapIdQuantity = new Map <Id,Integer>();
            mapIdQuantity.put(l_DistributorReferenceSelected[0].Id,10);
            mapIdQuantity.put(l_DistributorReferenceSelected[3].Id,13);

            test.starttest();

                AlphaStore controller = new AlphaStore();

                controller.brandFamilyResults();
                controller.getFamilyOptions();
                controller.getBrandOptions();
                controller.getDistributorOptions();
                controller.getBodyShopOptions();

                controller.manufacturer = 'AUDI';
                controller.family = 'Color';
                controller.distributor = l_Accounts[0].Id;
                controller.bodyshop = l_Accounts[1].Id;

                AlphaStore.partListDisplay('','','','');

                AlphaStore.saveAssPL(mapIdDiSRef, mapIdQuantity, '1245', '2646','12745','');

            test.stoptest();
            System.assertEquals([select Id from Assessment__c where id <> null].size() , 1);
        }
    }

    @isTest static void test_InsertAssessmentNoBS() {
        system.debug('#### Start of test_InsertAssessmentNoBS');

        system.runAs(userAdmin){  

            insert l_directOrder;

            list <Distributor_reference__c> l_DistributorReferenceSelected = [select Id, AS_public_price__c,BSPrice__c, Discount__c, Distributor_public_price__c,ASDiscount__c,BSDiscount__c,
                                                                                Distributor__r.Name, Manufacturer_reference__r.Unit__c,  Manufacturer_reference__r.ClaimNumber__c,
                                                                                Manufacturer_reference__r.Type__c, Manufacturer_reference__r.Description__c,
                                                                                Manufacturer_reference__r.Family__c, Manufacturer_reference__r.Manufacturer_ID__c,
                                                                                Manufacturer_reference__r.Brand__c, Manufacturer_reference__r.Name, 
                                                                                Manufacturer_reference__r.Minimum_quantity__c, Manufacturer_reference__r.Recordtype.DeveloperName,
                                                                                Active_country__c
                                                                            from Distributor_reference__c
                                                                            where Id <> null];
            Map <Id, Distributor_reference__c> mapIdDiSRef = new Map <Id, Distributor_reference__c>();
            mapIdDiSRef.put(l_DistributorReferenceSelected[0].Id,l_DistributorReferenceSelected[0]);
            mapIdDiSRef.put(l_DistributorReferenceSelected[3].Id,l_DistributorReferenceSelected[3]);

            Map <Id,Integer> mapIdQuantity = new Map <Id,Integer>();
            mapIdQuantity.put(l_DistributorReferenceSelected[0].Id,10);
            mapIdQuantity.put(l_DistributorReferenceSelected[3].Id,13);

            test.starttest();

                AlphaStore controller = new AlphaStore();

                controller.manufacturer = 'AUDI';
                controller.family = 'Color';
                controller.distributor = l_Accounts[1].ReferenceNumber__c;
                controller.bodyshop = l_Accounts[0].ReferenceNumber__c;

                controller.getFamilyOptions();
                controller.getBrandOptions();
                controller.getDistributorOptions();
                controller.getBodyShopOptions();
                controller.brandFamilyResults();

                AlphaStore.partListDisplay('','','','');

                AlphaStore.saveAssPL(mapIdDiSRef, mapIdQuantity, '1245', '2646','12745','');

            test.stoptest();
            System.assertEquals([select Id from Assessment__c where id <> null].size() , 1);
        }
    }
}