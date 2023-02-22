/*************************************************************************************
Class Name - ASPISMyAssessments_TEST
Version - 1.0
Created Date - 04 JULY 2018
Function - TestClass to ASPISMyAssessments

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Welsa C      04/07/2018  Original Version
*************************************************************************************/
@isTest
private class ASPISMyAssessments_TEST {
    static User userAdmin;
    static User userAdmin2;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<Assessment__c> childAssessments;
    static list<PartList__c> partLists;
    static list<PartList__c> childpartLists;
    static list<PurchaseOrder__c> listpurchaseOrders;
    static list<OrderLine__c> listOrderLines;
    static list<PrerequisiteOrder__c> listSalesOrders;
    static list<Offer__c> listOffers;
    static list<Invoice__c> listInvoices;

    static {
        // initialising variables
        accounts = new list<Account>();
        assessments = new list <Assessment__c>();
        childAssessments = new list<Assessment__c>();
        childpartLists = new list<PartList__c>();
        partLists = new list <PartList__c>();
        listpurchaseOrders = new list<PurchaseOrder__c>();
        listOrderLines =  new list<OrderLine__c>();
        listSalesOrders = new list<PrerequisiteOrder__c>();
        listOffers = new list<Offer__c>();
        listInvoices = new list<Invoice__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        insert userAdmin;
        // creating user
        userAdmin2 = TestFactory.createUser('ScUserTest2');
        userAdmin.BodyShopID__c = '25897413622';
        insert userAdmin2;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
            bs1.ContactUser__c = userAdmin.Id;
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            bs2.ContactUser__c = userAdmin.Id;
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

            Assessment__c ass1 = TestFactory.createAssessment(System.label.Painting.toUpperCase()+'ASSESS_TEST-0001', bs1);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.VINCheck__c = 2;
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
            insert assessments;

            Assessment__c ass2 = TestFactory.createAssessment(System.label.Painting.toUpperCase()+'ASSESS_TEST-0001', bs1);
            ass2.ParentAssessment__c = ass1.Id;
            ass2.Entity__c = '299';
            ass2.EntityRules__c = '299';
            ass2.EntityCode__c = '299';
            ass2.VINNumber__c = '444';
            ass2.PlateNumber2__c = '123';
            ass2.Manufacturer__c = 'TOYOTA';
            ass2.BuildDate__c = date.today();
            ass2.TECH_EntityCountryCode__c = 'FR';
            ass2.VINCheck__c = 2;
            ass2.ModelV2__c = 'PRIUS T4';
            ass2.Status__c = 'NEW';
            ass2.AssessmentNumber__c = 'Num001-1';
            ass2.OrderStatus__c = 'INDELIVERY';
            ass2.AssessmentID__c = 'Num001-1';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass2);

            Assessment__c ass3 = TestFactory.createAssessment(System.label.Painting.toUpperCase()+'ASSESS_TEST-0002', bs1);
            ass3.ParentAssessment__c = ass1.Id;
            ass3.Entity__c = '299';
            ass3.EntityRules__c = '299';
            ass3.EntityCode__c = '299';
            ass3.VINNumber__c = '444';
            ass3.PlateNumber2__c = '123';
            ass3.Manufacturer__c = 'TOYOTA';
            ass3.BuildDate__c = date.today();
            ass3.TECH_EntityCountryCode__c = 'FR';
            ass3.VINCheck__c = 1;
            ass3.ModelV2__c = 'PRIUS T4';
            ass3.Status__c = 'NEW';
            ass3.AssessmentNumber__c = 'Num001-2';
            ass3.OrderStatus__c = 'INDELIVERY';
            ass3.AssessmentID__c = 'Num001-2';
            ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            childAssessments.add(ass3);
            insert childAssessments;

            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass1);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);
            insert partLists;


            PartList__c pl3 = TestFactory.createPartList(ass2);
            pl3.OriginalPart__c = partLists[0].Id;
            pl3.SelectedByBS__c = true;
            pl3.TECH_OrderedCounter__c = 1;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl3.Quantity__c = 15;
            childpartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(ass2);
            pl4.OriginalPart__c = partLists[1].Id;
            pl4.SelectedByBS__c = true;
            pl4.TECH_OrderedCounter__c = 1;
            pl4.Quantity__c = 15;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(pl4);
            insert childpartLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs1, '');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            listSalesOrders.add(so1);  

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass3, bs1, '');
            so2.BodyShopOrderNumber__c = '12743';
            so2.Status__c = 'INDELIVERY';
            listSalesOrders.add(so2);   

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass2, so1, bs1, dist1, '');
            po1_1.Status__c = 'PREDRAFTQOUTE';
            listpurchaseOrders.add(po1_1);
            insert listpurchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            listOrderLines.add(ol1);

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.OrderType__c = 'FINAL';
            ol2.PartNumber__c = '1234';
            ol2.Suppliable__c = 'YES';
            listOrderLines.add(ol2);

            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol3.PartList__c = childpartLists[0].Id;  
            ol3.OrderType__c = 'FINAL';
            ol3.Description__c = 'desc1';          
            ol3.PartNumber__c = '123456';
            ol3.Suppliable__c = 'YES';
            listOrderLines.add(ol3);

            OrderLine__c ol4 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol4.PartList__c = childpartLists[1].Id;            
            ol4.OrderType__c = 'FINAL';
            ol4.Description__c = 'desc12';
            ol4.PartNumber__c = '1234';
            ol4.Suppliable__c = 'YES';
            listOrderLines.add(ol4);
            insert listOrderLines;


            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            listOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INPROCESS');
            off2.Type__c = 'QUICK';
            listOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, so1, 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.PreselectedForOrder__c = true;
            off3.Accepted__c = 'YES';
            listOffers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol4, so1, 'INPROCESS');
            off4.Type__c = 'QUICK';
            listOffers.add(off4);
            Offer__c off5 = TestFactory.createOfferLine(ol3, so2, 'INPROCESS');
            off5.Type__c = 'BASIC';
            off5.PreselectedForOrder__c = true;
            off5.Accepted__c = 'YES';
            listOffers.add(off5);
            Offer__c off6 = TestFactory.createOfferLine(ol4, so2, 'INPROCESS');
            off6.Type__c = 'BASIC';
            listOffers.add(off6);
            insert listOffers;

            Invoice__c inv1= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'PAID', so1);
            listInvoices.add(inv1);
            Invoice__c inv2= TestFactory.createBodyshopInvoice('INV-2813E', 14.40, 'PAID', so2);
            listInvoices.add(inv2);
            insert listInvoices;

        }
    }

    static testmethod void testMyAssessments(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPISMyAssessments);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userAdmin.Id)));

            Test.startTest();
                ASPISMyAssessments controller = new ASPISMyAssessments();
                controller.encryptBase64('ssds');
                list<ASPISMyAssessments.OnGoingAssessment> listOfAssessment = ASPISMyAssessments.assessmentDisplay(system.today().addDays(-1).format(), system.today().format(), String.valueOf(userAdmin.Id));  
                controller.redirectPage();
            Test.stopTest();
            System.assertEquals(listOfAssessment.size(), 1);
        }
    }

    static testmethod void testMyOrdersException(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPISMyAssessments);
            ApexPages.currentPage().getParameters().put('Id', 'fake sf id');
            Test.startTest();
                ASPISMyAssessments controller = new ASPISMyAssessments();  
            Test.stopTest();
            //System.assertEquals(listOfAssessment.size(), 0);
        }
    }
    static testmethod void testMyOrdersException2(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPISMyAssessments);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf('a0K5800000hDntcEAC')));
            Test.startTest();
                ASPISMyAssessments controller = new ASPISMyAssessments();  
            Test.stopTest();
            //System.assertEquals(listOfAssessment.size(), 0);
        }
    }
}