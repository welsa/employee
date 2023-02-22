/*************************************************************************************
Class Name - OrderChooseAssessment_TEST
Version - 1.0
Created Date - 06 FEBRUARY 2017
Function - TestClass to OrderChooseAssessment

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      05/02/2017  Original Version
*************************************************************************************/
@isTest(seeAllData = false)
private class OrderChooseAssessment_TEST {
    static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PartList__c> partLists;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;

    static {
        // initialising variables
        accounts = new list <Account>();
        assessments = new list <Assessment__c>();
        partLists = new list <PartList__c>();
        masterRuleList = new list <MasterRules__c>();
        detailRuleList = new list <DetailRule__c>();
        l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = 'FR2589741363';//WCH 23/12/2020 C-004120
        insert userAdmin;

        System.runAs(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.ReferenceNumber__c = 'FR2589741363';//WCH 23/12/2020 C-004120
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            accounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Categories__c = 'A';
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist1.Categories__c = 'A;B';
            accounts.add(dist2);  

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist1.Categories__c = 'A';
            accounts.add(dist3);    

            insert accounts;
            system.debug('## accounts : ' + accounts);

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            ass2.Entity__c = 'AXA Direct1';
            ass2.EntityRules__c = 'AXA Direct1';
            ass2.EntityCode__c = '213';
            ass2.BuildDate__c = date.today()+1;
            ass2.TECH_EntityCountryCode__c = 'FR';
            ass2.CrossReferences__c = 'njgnjrgnnn';
            ass2.PlateNumber2__c = '123';
            ass2.Status__c = 'SOURCED';
            ass2.AssessmentNumber__c = 'Num001';
            ass2.AssessmentID__c = 'Num002-2';
            assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            ass3.Entity__c = 'AXA Direct2';
            ass3.EntityRules__c = 'AXA Direct2';
            ass3.TECH_EntityCountryCode__c = 'FR';
            ass3.EntityCode__c = '2999';
            ass3.Status__c = 'SOURCED';
            ass3.AssessmentNumber__c = 'Num001';
            ass3.AssessmentID__c = 'Num003-3';
            ass3.VINNumber__c = '444425';
            ass3.PlateNumber2__c = '1235552';
            ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass3);  

            Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs2);
            ass4.Entity__c = '299';
            ass4.EntityRules__c = '299';
            ass4.TECH_EntityCountryCode__c = 'FR';
            ass4.EntityCode__c = '299';
            ass4.VINNumber__c = '444';
            ass4.Manufacturer__c = 'TOYOTA';
            ass4.ModelV2__c = 'PRIUS T4';
            ass4.PlateNumber2__c = '123';
            ass4.Status__c = 'NEW';
            ass4.AssessmentNumber__c = 'Num004';
            ass4.AssessmentID__c = 'Num004';
            ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass4);

            Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs2);
            ass5.Entity__c = 'NON AXA';
            ass5.EntityRules__c = 'FRNONAXA';
            ass5.TECH_EntityCountryCode__c = 'FR';
            ass5.EntityCode__c = 'NONAXA';
            ass5.VINNumber__c = '4445';
            ass5.Manufacturer__c = 'TOYOTA';
            ass5.ModelV2__c = 'PRIUS T54';
            ass5.PlateNumber2__c = '123785';
            ass5.Status__c = 'NEW';
            ass5.AssessmentNumber__c = 'Num0054';
            ass5.AssessmentID__c = 'Num0045';
            ass5.Feature__c='PilotDirectSourcing;Virtual A\';Order Part E';
            ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass5);

            insert assessments;

            PartList__c pl1 = TestFactory.createPartList(assessments[0]);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(assessments[0]);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartList(assessments[2]);
            pl3.SelectedByBS__c = true;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-2-Numpl1-balbal';
            pl3.Quantity__c = 5;
            partLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(assessments[1]);
            pl4.SelectedByBS__c = true;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-1-Numpl1-balbal';
            pl4.Quantity__c = 5;    
            partLists.add(pl4);

            PartList__c pl5 = TestFactory.createPartList(assessments[1]);
            pl5.SelectedByBS__c = true;
            pl5.TECH_OriginalPart__c = 'blabla-Num001-1-Numpl2-balbal';
            pl5.Quantity__c = 10;    
            partLists.add(pl5);

            PartList__c pl6 = TestFactory.createPartList(assessments[2]);
            pl6.SelectedByBS__c = true;
            pl6.TECH_OriginalPart__c = 'blabla-Num001-2-Numpl2-balbal';
            pl6.Quantity__c = 5;
            partLists.add(pl6);

            PartList__c pl7 = TestFactory.createPartList(assessments[0]);
            pl7.SelectedByBS__c = true;
            pl7.TECH_OriginalPart__c = 'blabla-Num001-Numpl3-balbal';
            partLists.add(pl7);

            PartList__c pl8 = TestFactory.createPartList(assessments[0]);
            pl8.SelectedByBS__c = true;
            pl8.TECH_OriginalPart__c = 'blabla-Num001-Numpl4-balbal';
            partLists.add(pl8);

            PartList__c pl9 = TestFactory.createPartList(assessments[3]);
            pl9.SelectedByBS__c = true;
            pl9.TECH_OriginalPart__c = 'blabla-Num005-Numpl5-balbal';
            partLists.add(pl9);

            PartList__c pl10 = TestFactory.createPartList(assessments[3]);
            pl10.SelectedByBS__c = true;
            pl10.TECH_OriginalPart__c = 'blabla-Num006-Numpl6-balbal';
            partLists.add(pl10);

            PartList__c pl11 = TestFactory.createPartList(assessments[4]);
            pl11.SelectedByBS__c = true;
            pl11.RecommendedByAS__c = true;
            pl11.Quantity__c =1;
            pl11.TECH_OriginalPart__c = 'blabla-Num006-Numpl66-balbala';
            pl11.Alpha_Scale_MRID__C ='OEM-nonAxaPart-001';
            partLists.add(pl11);

            PartList__c pl12 = TestFactory.createPartList(assessments[4]);
            pl11.SelectedByBS__c = true;
            pl11.RecommendedByAS__c = true;
            pl11.Quantity__c =1;
            pl11.TECH_OriginalPart__c = 'blabla-Num006-Numpl66-balbala';
            pl11.Alpha_Scale_MRID__C ='ASP-nonAxaPart-002';
            partLists.add(pl12);

            insert partLists;

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            l_cs_CountryCodeIngformation.add(countryCode1);

            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);  
            countryCode2.EligibleOrder__c = true;
            countryCode2.EligibleQuotation__c = true;
            l_cs_CountryCodeIngformation.add(countryCode2);
       
            insert l_cs_CountryCodeIngformation; 

            MasterRules__c mr1 = TestFactory.createMasterRule('FR299', 'Eligibility', 'Assessment__c');
            mr1.FilterLogic__c = '(1 AND 2 AND 3)';
            mr1.RuleStatus__c = 'Active';
            masterRuleList.add(mr1);
            
            MasterRules__c mr2 = TestFactory.createMasterRule('FR299', 'Sourcing', 'Assessment__c');
            mr2.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            mr2.RuleStatus__c = 'Active';
            masterRuleList.add(mr2);

            MasterRules__c mr3 = TestFactory.createMasterRule('FRNONAXA', 'Sourcing', 'Assessment__c');
            mr3.FilterLogic__c = '(1 AND 2 AND 3)';
            mr3.RuleStatus__c = 'Active';
            masterRuleList.add(mr3);
            
            MasterRules__c mr4 = TestFactory.createMasterRule('FRNONAXA', 'Sourcing', 'Assessment__c');
            mr4.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            mr4.RuleStatus__c = 'Active';
            masterRuleList.add(mr4);

            insert masterRuleList;

            DetailRule__c dr1 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'EntityCode__c', 'EQUALS', '299', 'Filter Condition', 'Assessment__c', 1);
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'TotalNumberOfParts__c', 'NOT_EQUALS', '0', 'Filter Condition', 'Assessment__c', 2);
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'VINNumber__c', 'NOT_EQUALS', '', 'Filter Condition', 'Assessment__c', 3);
            detailRuleList.add(dr3);

            DetailRule__c dr4 = TestFactory.createDetailRule('Sourcing', masterRuleList[1], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1);
            dr4.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr4);

            DetailRule__c dr5 = TestFactory.createDetailRule('Sourcing', masterRuleList[1], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2);
            dr5.ValueFrom__c = 'Criteria sObject';
            detailRuleList.add(dr5);

            DetailRule__c dr6 = TestFactory.createDetailRule('Sourcing', masterRuleList[1], 'Categories__c', 'IN', 'PartTypes__c', 'Filter Condition', 'Account', 3);
            dr6.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr6);
            
            DetailRule__c dr7 = TestFactory.createDetailRule('Sourcing', masterRuleList[1], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4);
            dr7.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr7);

            insert detailRuleList;
            
        }
    }

    static testmethod void testOrderChooseAssessmentStandard(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('Order', '1');

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(1, assessment.Purchaseorders__r.size());
        }
    }



    static testmethod void testOrderChooseAssessmentStandard2(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);
            assessments[0].MREligibility__c = true;
            assessments[0].MRSourcing__c = accounts[2].Id + ';' + accounts[3].Id;
            assessments[0].AgencyDistributors__c = accounts[2].Id;
            update assessments[0];

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id, distributor__c
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(2, assessment.Purchaseorders__r.size());
        }
    }

    static testmethod void testOrderChooseAssessmentWithCrossRef(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            CrossReference__c crossRef = TestFactory.createCrossReference();
            insert crossRef;

            partLists[0].CrossReferenceId__c = crossRef.Id;
            update partLists[0];

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
                //controller.assessmentCanQuote();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(1, assessment.Purchaseorders__r.size());

        }
    }

    static testmethod void testOrderChooseAssessmentExpert(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[3].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Expert';
                controller.createClaimOrderAssessment();
                //controller.assessmentCanQuote();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num004-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(1, assessment.Purchaseorders__r.size());

        }
    }

    static testmethod void testOrderChooseAssessmentVinNull(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[1].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

        }
    }

    static testmethod void testcanQuoteAssessment(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Expert';
                controller.assessmentCanQuote();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

        }
    }

    static testmethod void testHasOngoingAssessment(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            list<Assessment__c> childAssessments = new list<Assessment__c>();

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accounts[0]);
            ass1.ParentAssessment__c = assessments[0].Id;
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'SOURCED';
            ass1.AssessmentNumber__c = 'Num001-1';
            ass1.OrderStatus__c = 'INDELIVERY';
            ass1.AssessmentID__c = 'Num001-1';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass1);

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0001', accounts[0]);
            ass2.ParentAssessment__c = assessments[0].Id;
            ass2.Entity__c = '299';
            ass2.EntityRules__c = '299';
            ass2.EntityCode__c = '299';
            ass2.VINNumber__c = '444';
            ass2.PlateNumber2__c = '123';
            ass2.Manufacturer__c = 'TOYOTA';
            ass2.BuildDate__c = date.today();
            ass2.TECH_EntityCountryCode__c = 'FR';
            ass2.ModelV2__c = 'PRIUS T4';
            ass2.Status__c = 'NEW';
            ass2.AssessmentNumber__c = 'Num001-2';
            ass2.OrderStatus__c = 'INDELIVERY';
            ass2.AssessmentID__c = 'Num001-2';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass2);

            insert childAssessments;

            list<PrerequisiteOrder__c> listSalesOrders = new list<PrerequisiteOrder__c>();

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, accounts[0], '');
            so1.BodyShopOrderNumber__c = '1274';
            listSalesOrders.add(so1); 

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, accounts[0], '');
            so2.BodyShopOrderNumber__c = '2584';
            listSalesOrders.add(so2);    

            insert listSalesOrders;

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
                // controller.assessmentCanQuote();
            Test.stopTest();

            list<Assessment__c> listassessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where ParentAssessment__c =: assessments[0].Id];

            System.assertEquals(3, listassessment.size());

        }
    }

    static testmethod void testAssessmentAlreadyExist(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            list<Assessment__c> childAssessments = new list<Assessment__c>();
            list<PartList__c> childpartLists = new list<PartList__c>();
            list<PurchaseOrder__c> listpurchaseOrders = new list<PurchaseOrder__c>();
            list<OrderLine__c> listOrderLines =  new list<OrderLine__c>();
            list<PrerequisiteOrder__c> listSalesOrders = new list<PrerequisiteOrder__c>();
            list<Offer__c> listOffers = new list<Offer__c>();

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accounts[0]);
            ass1.ParentAssessment__c = assessments[0].Id;
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'SOURCED';
            ass1.AssessmentNumber__c = 'Num001-1';
            ass1.OrderStatus__c = 'PREACCEPTANCE';
            ass1.AssessmentID__c = 'Num001-1';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass1);

            insert childAssessments;

            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.OriginalPart__c = partLists[0].Id;
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl1.Quantity__c = 15;
            childpartLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass1);
            pl1.OriginalPart__c = partLists[1].Id;
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(pl2);
            insert childpartLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, accounts[0], '');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            listSalesOrders.add(so1);   

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, accounts[0], accounts[2], '');
            listpurchaseOrders.add(po1_1);
            insert listpurchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            listOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.PartNumber__c = '1234';
            listOrderLines.add(ol2);
            insert listOrderLines;


            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            listOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INPROCESS');
            off2.Type__c = 'QUICK';
            listOffers.add(off2);
            insert listOffers;

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(1, assessment.Purchaseorders__r.size());

        }
    }

    static testmethod void testOrderChooseAssessmentCatchException(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf('2555')));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                // controller.bsType = 'Expert';
                // controller.createClaimOrderAssessment();
                // controller.assessmentCanQuote();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

        }
    }

    static testmethod void testOrderChooseAssessmentFailure(){
        System.runAs(userAdmin){
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[2].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
                controller.assessmentCanQuote();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

        }
    }

    static testmethod void testOrderChooseAssessmentNONAXA(){
        System.runAs(userAdmin){
            accounts[1].Non_AXA_Authorised__c = true;
            update accounts[1];
            partLists[10].TECHDistList__c = accounts[2].Id+';'+accounts[3].Id+';'+accounts[4].Id;
            partLists[11].TECH_OriginalPart__c =  partLists[10].Id;
            partLists[11].TECHDistList__c = accounts[2].Id+';'+accounts[3].Id+';'+accounts[4].Id;
			update partLists;
            assessments[4].MRSourcing__c=accounts[2].Id+';'+accounts[3].Id+';'+accounts[4].Id;
            assessments[4].MREligibility__c=true;
            update assessments[4];
            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[4].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Expert';
                controller.receivedAssessmentWrapper.vinNumber = '4445';
                controller.receivedAssessmentWrapper.plateNumber = '123785';
             	controller.assessmentCanQuote();
                controller.createClaimOrderAssessment();
                controller.selectToOrder();
                controller.redirectPage();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,
                                        (select Id
                                         from Purchaseorders__r)
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num0045-1'];

            System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(3, assessment.Purchaseorders__r.size());
        }
    }
    static testmethod void testOrderChooseAssessmentNONAXANullValues(){
        System.runAs(userAdmin){
            accounts[0].Non_AXA_Authorised__c = true;
            update accounts[0];

            assessments[0].VINNumber__c = null;
            assessments[0].PlateNumber2__c = null;
            update assessments[0];

            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                controller.createClaimOrderAssessment();
                controller.assessmentCanQuote();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
        }
    }
    
      static testmethod void testOrderChooseAssessmentorderPartE(){
        System.runAs(userAdmin){
            accounts[0].Non_AXA_Authorised__c = true;
            update accounts[0];

            assessments[0].VINNumber__c = null;
            assessments[0].PlateNumber2__c = null;
            update assessments[0];

            Test.setCurrentPage(Page.OrderChooseAssessment);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));

            Test.startTest();
                OrderChooseAssessment controller = new OrderChooseAssessment();
                controller.bsType = 'Standard';
                //controller.createClaimOrderAssessment();
                controller.orderPartsE();
            Test.stopTest();

           
        }
    }
}