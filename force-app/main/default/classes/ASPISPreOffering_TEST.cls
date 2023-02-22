/*************************************************************************************
Class Name - ASPISPreOffering_TEST
Version - 1.0
Created Date - 13 APRIL 2017
Function - TestClass to ASPISPreOffering

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      13/04/2017  Original Version
* Welsa C       15/02/2019  C-002958: MultiSourcing Belgium - Large choice of distributors for Bodyshops
*************************************************************************************/
@isTest
private class ASPISPreOffering_TEST {
	

	static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> childAssessments;
    static list<PartList__c> partLists;
    static list<PartList__c> childpartLists;
    static list<PurchaseOrder__c> listpurchaseOrders;
    static list<OrderLine__c> listOrderLines;
    static list<PrerequisiteOrder__c> listSalesOrders;
    static list<Offer__c> listOffers;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;

    static {
        // initialising variables
        accounts = new list<Account>();
        childAssessments = new list<Assessment__c>();
        childpartLists = new list<PartList__c>();
        partLists = new list <PartList__c>();
        listpurchaseOrders = new list<PurchaseOrder__c>();
        listOrderLines =  new list<OrderLine__c>();
        listSalesOrders = new list<PrerequisiteOrder__c>();
        listOffers = new list<Offer__c>();
        masterRuleList = new list <MasterRules__c>();
        detailRuleList = new list <DetailRule__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
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

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001-1';
            ass1.OrderStatus__c = 'PREACCEPTANCE';
            ass1.AssessmentID__c = 'Num001-1';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass1);
            insert childAssessments;

            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass1);
            pl2.SelectedByBS__c = true;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);
            insert partLists;


            PartList__c pl3 = TestFactory.createPartList(ass1);
            pl3.OriginalPart__c = partLists[0].Id;
            pl3.SelectedByBS__c = true;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl3.Quantity__c = 15;
            childpartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(ass1);
            pl4.OriginalPart__c = partLists[1].Id;
            pl4.SelectedByBS__c = true;
            pl4.Quantity__c = 15;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(pl4);
            insert childpartLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, '');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            listSalesOrders.add(so1);   

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, '');
            listpurchaseOrders.add(po1_1);
            insert listpurchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            listOrderLines.add(ol1);

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.PartNumber__c = '1234';
            listOrderLines.add(ol2);

			OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol3.PartList__c = childpartLists[0].Id;  
            ol3.Description__c = 'desc1';          
            ol3.PartNumber__c = '123456';
            listOrderLines.add(ol3);

            OrderLine__c ol4 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol4.PartList__c = childpartLists[1].Id;
            ol4.Description__c = 'desc12';
            ol4.PartNumber__c = '1234';
            listOrderLines.add(ol4);
            insert listOrderLines;


            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            listOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INPROCESS');
            off2.Type__c = 'QUICK';
            listOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, so1, 'INPROCESS');
            off3.Type__c = 'QUICK';
            listOffers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol4, so1, 'INPROCESS');
            off4.Type__c = 'QUICK';
            listOffers.add(off4);
            insert listOffers;

            MasterRules__c mr1 = TestFactory.createMasterRule('FR299', 'PREOFFERING', 'Offer__c');
            mr1.FilterLogic__c = '1';
            mr1.RuleStatus__c = 'Active';
            masterRuleList.add(mr1);

            insert masterRuleList;

            DetailRule__c dr1 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c', 'EQUALS', '0', 'Filter Condition', 'Offer__c', 1);
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'OrderLine__r.Description__c', 'GROUPBY', '', 'Group By Criteria', 'Offer__c', 2);
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'OrderLine__r.ExpectedDeliveryDuration__c', 'AGMIN', '', 'Aggregate Criteria', 'Offer__c', 3);
            dr3.Alias__c = 'MINEDD';
            detailRuleList.add(dr3);

            DetailRule__c dr4 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'MINEDD', 'MIN', '', 'Criteria', 'Offer__c', 4);
            detailRuleList.add(dr4);

            DetailRule__c dr5 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'PreselectedForOrder__c', 'EQUALS', 'true', 'Update Field', 'Offer__c', 5);
            detailRuleList.add(dr5);

            DetailRule__c dr6 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id', 'GROUPBY', '', 'Group By Criteria', 'Offer__c', 6);
            detailRuleList.add(dr6);
            
            //DetailRule__c dr7 = TestFactory.createDetailRule('Offering', masterRuleList[0], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Offer__c', 7);
            //detailRuleList.add(dr7);

            insert detailRuleList;

        }
    }

	static testmethod void testPreOffering(){
        system.runas(userAdmin){
        	Test.startTest();
                ASPISPreOffering.executePreOffering(listOffers,'FR299','PREOFFERING');//WCH 15/02/2019 C-002958 MultiSourcing Belgium - Large choice of distributors for Bodyshops
            Test.stopTest();
        	
        }
    }
}