/**
 * @description       : 
 * @author            : HRM
 * @group             : 
 * @last modified on  : 02-15-2022
 * @last modified by  : HRM
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   02-10-2022   HRM   Initial Version
**/
@isTest(seeAllData = false)
private class VFC28_PlafondCommande_TEST {
    static User userAdmin;
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
    static CountryCodeInformationsMapping__c cs;
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
        cs = new  CountryCodeInformationsMapping__c();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = '258974136';
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
            cs = TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            cs.AllowPlafondCommande__c=true;
            cs.FinanceAndSupportEmail__c='hootesh.rambarassah@spoonconsulting.com';

            insert cs;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.isEligibleShippingCost__c = true;
            bs1.DistributorConnected__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
            //WCH 15/01/2019 : increase code coverage
            bs1.ShippingCostRegionClassic__c='00';
            bs1.ShippingPostalCode='0000';
            bs1.ShippingCountryCode='FR';
            bs1.priority__c=1;
            bs1.Name='testBs';
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            accounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Name = 'Distributor_ScTest1';
            dist1.Tech_Distributor__c = 'Distributor_ScTest1';
            dist1.Categories__c = 'A';
            dist1.DistributorConnected__c = true;
            dist1.Tech_Distributor__c = 'SAS';            
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
           
            dist1.OrderRequest__c='OrderR4';
            dist1.Agency_V3__c = true;
            accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist1.Name = 'Distributor_ScTest2';
            dist1.Tech_Distributor__c = 'Distributor_ScTest2';
            dist2.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            dist2.Categories__c = 'A;B';
            dist2.Tech_Distributor__c = 'SAS';
            accounts.add(dist2);  

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist1.Categories__c = 'A';
            dist2.Tech_Distributor__c = 'SAS';
            dist2.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';


            accounts.add(dist3);      

            insert accounts;

            //WCH 15/01/2019 : increase code coverage
            cs.AlphaScaleEntity__c = accounts[0].Id;
            update cs;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
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

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
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
            ass2.OrderStatus__c = 'PREACCEPTANCE';
            ass2.AssessmentID__c = 'Num001-1';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            ass2.AgencyMode__c =false;
            //WCH 15/01/2019 : increase code coverage
            ass2.Comment__c='test comment for claim order';
            childAssessments.add(ass2);

            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
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
            ass2.AgencyMode__c =false;
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

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs1, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'FINAL';
           
            listSalesOrders.add(so1);  

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass3, bs1, '');
            so2.BodyShopOrderNumber__c = '12743';
            so2.Status__c = 'INDELIVERY';
            listSalesOrders.add(so2);   

            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs1, '');
            so2.BodyShopOrderNumber__c = '12743';
            so2.Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE ;
            listSalesOrders.add(so3);   

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass2, so1, bs1, dist1, '');
            po1_1.Status__c = 'ORDERED';
            po1_1.AgencyMode__c = false;
            listpurchaseOrders.add(po1_1);
            insert listpurchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(1000,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            // ol1.CataloguePrice__c=1000;
            // ol1.ASBodyshopNetPrice__c=1000;
            // ol1.DistributorPrice__c=1000;
            // ol1.BodyshopTotalPrice__c=1000;
            listOrderLines.add(ol1);

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off1.Type__c = 'FINAL';
            
            //off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
           // off1.PreferredDistributor__c=true;
            off1.AdjustmentDescription__c ='test';
            off1.AdjustmentAmount__c=(Decimal)60.00;
            listOffers.add(off1);
            insert listOffers;
        }  
    }
     static testmethod void testGetSumTotalPriceOrdered(){
            listOffers[0].AdjustmentAmount__c = 1000.00;
            update listOffers[0]; 
            VFC28_PlafondCommande.getSumTotalPriceOrdered(accounts[1].Id);
     }
     static testmethod void testGetMaxOrderAmount(){
            Plafond_Commande__c plafond = new Plafond_Commande__c(Bodyshop__c= accounts[0].Id,
            Amount__c=1000,
            Active__c=true,
            EndDate__c=System.today().addDays(2));
            
            insert plafond;
            Decimal maxAmount;

            Test.startTest();
                maxAmount= VFC28_PlafondCommande.getMaxOrderAmount(accounts[0].Id);
            Test.stopTest();
            //System.assertEquals(1000,maxAmount);
           
     }
     static testmethod void testisPlafondReached(){

            Test.startTest();
                VFC28_PlafondCommande.isPlafondReached(assessments[0].Id);
            Test.stopTest();           
     }
     static testmethod void testReportError(){
        Assessment__c assessment = [Select Id,BodyShop__c,BodyShop__r.Name FROM Assessment__c where Id=:assessments[0].Id];
            Test.startTest();
                VFC28_PlafondCommande.ReportError(assessment,'hootesh.rambarassah@spoonconsuting.com',true);
            Test.stopTest();
           
     }
     static testmethod void testViewComponent(){
         system.runas(userAdmin){
            Test.StartTest(); 
                ApexPages.StandardController sc = new ApexPages.StandardController(accounts[0]);
                

                PageReference pageRef = Page.VFP28_PlafondCommande;
                Test.setCurrentPage(pageRef);

                VFC28_PlafondCommande testAccPlan = new VFC28_PlafondCommande(sc);
            Test.StopTest();
         }  
     }

}