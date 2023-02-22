/*************************************************************************************
Class Name - OrderConfirmation_TEST
Version - 1.0
Created Date - 12 APRIL 2017
Function - TestClass to OrderConfirmation

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      12/04/2017  Original Version
*************************************************************************************/
@isTest
private class OrderConfirmation_TEST {

	static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> childAssessments;
    static list<PartList__c> childpartLists;
    static list<PurchaseOrder__c> listpurchaseOrders;
    static list<OrderLine__c> listOrderLines;
    static list<PrerequisiteOrder__c> listSalesOrders;
    static list<Offer__c> listOffers;
    static list<Log__c> listLogs;
    static list<CrossReference__c> listCrossRefs;
    static list<DistributorPrice__c> listDistPrices;
    static list<AccountRef__c> listAccountRef;

    static {
        // initialising variables
        accounts = new list<Account>();
        childAssessments = new list<Assessment__c>();
        childpartLists = new list<PartList__c>();
        listpurchaseOrders = new list<PurchaseOrder__c>();
        listOrderLines =  new list<OrderLine__c>();
        listSalesOrders = new list<PrerequisiteOrder__c>();
        listOffers = new list<Offer__c>();
        listLogs = new List<Log__c>();
        listCrossRefs = new List<CrossReference__c>();
        listDistPrices = new List<DistributorPrice__c>();
        listAccountRef = new List<AccountRef__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
            bs1.Tech_Distributor__c = '';
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            accounts.add(bs2);

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest3', 'FR');
            bs3.Type = 'Standard';
            bs3.Tech_Distributor__c = '';
            bs3.Feature__c = 'NONAXASubstitution;Order Part E';
            bs3.ReferenceNumber__c= 'FR1215727904';
            accounts.add(bs3);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Categories__c = 'A';
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist2.Categories__c = 'A;B';
            accounts.add(dist2);  

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist3.Categories__c = 'A';
            accounts.add(dist3);    

            Account dist4 = TestFactory.createAccountDistributor('Distributor_ScTest4', 'FR');
            dist4.Tech_Distributor__c='OPISTO';
            dist4.Categories__c = '';
            dist4.DistributorConnected__c = true;
            dist4.Remove_A_from_Partnumber__c = false;
            accounts.add(dist4);    

            Account dist5 = TestFactory.createAccountDistributor('Distributor_ScTest4', 'FR');
            dist5.Tech_Distributor__c='FBS';
            dist5.Categories__c = '';
            dist4.Remove_A_from_Partnumber__c = false;
            accounts.add(dist5);    

            insert accounts;

            AccountRef__c accRef1 = TestFactory.createAccountRef('FR1215727904', bs3.Id, 'OPISTO');
            accRef1.ExternalReference__c='2722835';
            listAccountRef.add(accRef1);
            insert listAccountRef;
            

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

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', accounts[2]);
            ass2.Entity__c = 'AXA';
            ass2.EntityRules__c = 'FR299';
            ass2.EntityCode__c = '299';
            ass2.VINNumber__c = '444';
            ass2.PlateNumber2__c = '123';
            ass2.Manufacturer__c = 'RENAULT';
            ass2.BuildDate__c = date.today();
            ass2.TECH_EntityCountryCode__c = 'FR';
            ass2.ModelV2__c = 'CAPTUR';
            ass2.Status__c = 'NEW';
            ass2.AssessmentNumber__c = 'Num001-2';
            ass2.OrderStatus__c = '';
            ass2.AssessmentID__c = 'Num001-2';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            ass2.SelectedByBSPartTypes__c = 'A;E;B';
            ass2.callerSystem__c='FR_DIVA';
            childAssessments.add(ass2);

            insert childAssessments;

            CrossReference__c crossRef1 = TestFactory.createCrossReference();
            crossRef1.OEMCleanPartNumber__c='396003780R';

            listCrossRefs.add(crossRef1);
            insert listCrossRefs;

            DistributorPrice__c distPrice1 = TestFactory.createDistributorPrice(dist4.Id, crossRef1.Id);
            listDistPrices.add(distPrice1);
            insert listDistPrices;

            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl1.Quantity__c = 15;
            childpartLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass1);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartListASCR(ass2,crossRef1,distPrice1);
            pl3.SelectedByBS__c = true;
            pl3.TECH_OrderedCounter__c = 1;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl3-balbal-1';
            pl3.Type__c = 'E';
            pl3.ProducerName__c = 'FBS';
            pl3.Quantity__c = 15;
            childpartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartListASCR(ass2,crossRef1,distPrice1);
            pl4.SelectedByBS__c = true;
            pl4.TECH_OrderedCounter__c = 1;
            pl4.Quantity__c = 15;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl4-balbal-1';
            pl4.Type__c = 'E';
            pl4.ProducerName__c = 'OPISTO';
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

            Log__c log1 = new Log__c();
            log1.ETL_DATA_NAME__c='ySO1zqQLoEmLGOoiWNFHBQ==';
            log1.ETL_INTERFACE_NAME__c='OPISTO';
            log1.DateLog__c = system.now().addDays(1);
            listLogs.add(log1);

            Log__c log2 = new Log__c();
            log1.ETL_DATA_NAME__c='ySO1zqQLoEmLGOoiWNFHBQ==';
            log1.ETL_INTERFACE_NAME__c='OPISTO';
            log1.DateLog__c = system.now().addDays(-2);
            listLogs.add(log2);

            insert listLogs;

        }
    }

	static testmethod void testAssessmentAlreadyExist(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.OrderConfirmation);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderConfirmation controller = new OrderConfirmation();
            Test.stopTest();

            system.assertEquals(true,controller.hasSO);
        }
    }

    @isTest static void downloadQuote_TEST(){
        System.runAs(userAdmin)
        {
            Test.setCurrentPage(Page.OrderConfirmation);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            OrderConfirmation controller = new OrderConfirmation();
            
            Test.startTest();
                PageReference currentPage = controller.downloadPDFQuote();
            Test.stopTest();

            System.assertNotEquals(null, currentPage);
        }
    }

    @isTest static void downloadOrder_TEST(){
        System.runAs(userAdmin)
        {
            Test.setCurrentPage(Page.OrderConfirmation);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            OrderConfirmation controller = new OrderConfirmation();
            
            Test.startTest();
                PageReference currentPage = controller.downloadPDFOrder();
            Test.stopTest();

            System.assertNotEquals(null, currentPage);
        }
    }
    //HRM 11/11/2021
    @isTest static void distCallout_TEST(){
        Test.setMock(HttpCalloutMock.class, new DistributorMockCallout());
        System.runAs(userAdmin)
        {
            
            Test.setCurrentPage(Page.OrderConfirmation);
            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[1].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[1].Id)));
            OrderConfirmation controller = new OrderConfirmation();
            Test.startTest();
                System.debug('HRM account: '+[select ReferenceNumber__c,Tech_Distributor__c,Remove_A_from_Partnumber__c
                        from account where Tech_Distributor__c ='OPISTO']);
                OrderConfirmation.callDistributor(childpartLists[3].Id,accounts[6].Tech_Distributor__c);
            Test.stopTest();

        }
    }
    @isTest static void authenticateRem_TEST(){
        Test.startTest();
                OrderConfirmation.authenticateRem('OPISTO;FBS');
            Test.stopTest();
    }
    @isTest static void authenticateRem_TEST2(){
        Test.startTest();
                OrderConfirmation.authenticateRem('OPISTO');
            Test.stopTest();
    }
    @isTest static void authenticateRem_TEST3(){
        Test.startTest();
                OrderConfirmation.authenticateRem('FBS');
            Test.stopTest();
    }
    @isTest static void authenticateRem_TEST4(){
        Test.startTest();
                OrderConfirmation.authenticateRem('');
            Test.stopTest();
    }
    //HRM 11/11/2021 END
}