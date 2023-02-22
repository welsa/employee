/*************************************************************************************
Class Name - OrderMakeSelection_TEST
Version - 1.0
Created Date - 14 APRIL 2017
Function - TestClass to OrderMakeSelection

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------
* Dourga U      14/04/2017  Original Version
* Abdool M      26/09/2017  Added SAS Method
* Ruksaar L     05/06/2018  Increasing class coverage
* Welsa C       15/01/2019  Increase class coverage for all devs
*************************************************************************************/

@isTest
private class OrderMakeSelection_TEST { 
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
    static list<Occurence__c> lstOcc;
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
        lstOcc = new List<Occurence__c>();
        cs = new  CountryCodeInformationsMapping__c();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = '258974136';
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
            cs = TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            //RBE 02/12/2022
            cs.ActivateCatalogOEM__c = true;

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
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            accounts.add(bs2);

            //AMI 26/09/17 : setting distributor to connected
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Name = 'Distributor_ScTest1';
            dist1.Tech_Distributor__c = 'Distributor_ScTest1';
            dist1.Categories__c = 'A';
            dist1.Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');
            dist1.Tech_Distributor__c = 'SAS';            
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            //WCH 15/01/2019 : increase code coverage
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
            
            //RBE
            Account distPRE = TestFactory.createAccountDistributor('PRE By AlphaScale', 'FR');
            distPRE.Name = 'PRE By AlphaScale';
            distPRE.Tech_Distributor__c = 'PRE By AlphaScale';
            distPRE.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            accounts.add(distPRE);
            
            Account distGPA = TestFactory.createAccountDistributor('GPA', 'FR');
            distGPA.Name = 'GPA';
            distGPA.Tech_Distributor__c = 'GPA';
            distGPA.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            accounts.add(distGPA);

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

            //RBE
            PartList__c plPRE = TestFactory.createPartList(ass2);
            pl4.OriginalPart__c = partLists[1].Id;
            pl4.SelectedByBS__c = true;
            pl4.TECH_OrderedCounter__c = 1;
            pl4.Quantity__c = 1;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(plPRE);

            insert childpartLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs1, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
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
            po1_1.Status__c = 'PREDRAFTQOUTE';
            po1_1.AgencyMode__c = true;
            listpurchaseOrders.add(po1_1);

            //RBE
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass2, so1, bs1, distPRE, '');
            po1_2.Status__c = 'PREDRAFTQOUTE';
            po1_2.AgencyMode__c = false;
            listpurchaseOrders.add(po1_2);
            insert listpurchaseOrders;
            

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listOrderLines.add(ol1);

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.OrderType__c = 'FINAL';
            ol2.PartNumber__c = '1234';
            ol2.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listOrderLines.add(ol2);

            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol3.PartList__c = childpartLists[0].Id;  
            ol3.OrderType__c = 'FINAL';
            ol3.Description__c = 'desc123';          
            ol3.PartNumber__c = '123456';
            ol3.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listOrderLines.add(ol3);

            OrderLine__c ol4 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol4.PartList__c = childpartLists[1].Id;            
            ol4.OrderType__c = 'FINAL';
            ol4.Description__c = 'desc1234';
            ol4.PartNumber__c = '1234';
            ol4.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listOrderLines.add(ol4);

            //RBE
            OrderLine__c ol5 = TestFactory.createOrderLineFinal(10,po1_2, 'INPROCESS');
            ol5.PartList__c = plPRE.Id;            
            ol5.OrderType__c = 'FINAL';
            ol5.Description__c = 'desc1234';
            ol5.PartNumber__c = '1234';
            ol5.Suppliable__c = 'YES';
            ol5.SASStatus__c='CONFIRMED';
            listOrderLines.add(ol5);
            insert listOrderLines;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            //WCH 15/01/2019 : increase code coverage
            off1.PreferredDistributor__c=true;
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
            //RBE
            Offer__c off7 = TestFactory.createOfferLine(ol5, so1, 'INPROCESS');
            off7.Type__c = 'BASIC';
            listOffers.add(off7);

            insert listOffers;


            //RBE 08/02/2023
            Occurence__c occ1 = new Occurence__c( Distributor__c = distGpa.Id, 
                                                 DistributorReference__c = 'AR1465',
                                                 CrossReference__c = 'a0U26000007DCU3EAO',
                                                 Quality__c = 'Q1',
                                                 Delay__c = 24,
                                                 CutOff__c = '1',
                                                 Color__c = 'Red',
                                                 Status__c = 'Active',
                                                 ASSellingNetPrice__c = 90,
                                                 AdditionalMargin__c = 20,
                                                 PhotoURL__c = 'https://www.gpa26.com/4749998-large_default/peugeot-106-ph2-left-front-door-9002h9-3309433.jpg;https://www.gpa26.com/4749999-large_default/peugeot-106-ph2-left-front-door-9002h9-3309433.jpg;https://www.gpa26.com/4750000-large_default/peugeot-106-ph2-left-front-door-9002h9-3309433.jpg;https://www.gpa26.com/4750001-large_default/peugeot-106-ph2-left-front-door-9002h9-3309433.jpg;https://www.gpa26.com/4750002-large_default/peugeot-106-ph2-left-front-door-9002h9-3309433.jpg',
                                                 AdditionalInformation__c = 'Modele_208 1 PHASE 1 1.0I 12V|Kilometrage_0117739|Carrosserie_3 Portes|Année_12/12/2012|Carburant_Essence|Type Boite_20CR14|Couleur_Rouge Noir');
        
            lstOcc.add(occ1);
            insert lstOcc;
        }  
    }

    //RBE 
    static testmethod void testBuilImageList(){
        Test.startTest();
            OrderMakeSelection.OccurenceWrapper occWrap = new OrderMakeSelection.OccurenceWrapper(lstOcc[0]);
            System.assert(occWrap.occ == lstOcc[0]);
            System.assert(occWrap.lstImages.size() > 0);
            System.assert(occWrap.mainImage == occWrap.lstImages[0]);
        Test.stopTest();
    }

    static testmethod void testBuildMapAdditionalInfo(){
        Test.startTest();
            OrderMakeSelection.OccurenceWrapper occWrap = new OrderMakeSelection.OccurenceWrapper(lstOcc[0]);
            occWrap.buildMapAdditionalInfo();
            System.assert(occWrap.mapAdditionalInfo.size() == 7);
            System.assert(occWrap.lstInfoKeys.size() == 7);
        Test.stopTest();
    }
    
    static testmethod void testOrderYES(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.addChildOffer(listOffers[0]);
                        }
                    }
                }
                controller.order();
                //WCH 15/01/2019 : increase code coverage
                String theColor = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].deliveryColor;
                Boolean isESEligible = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isEligleES;
                Integer theRowSpan = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].rowSpan;
                Boolean isItOriginal = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferOriginal;
                Boolean isItOfferAlternative = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferAlternative;
                Boolean isItBundle = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isBundle;
                Boolean isZeroPrice = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isPriceZero;

            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
    //WCH 15/01/2019 : increase code coverage
    static testmethod void testOrderWithParentOffersYES(){
        system.runas(userAdmin){

            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol2.OriginalItem__c = listOrderLines[0].Id;
            ol2.OrderType__c = 'BUNDLEITEM';
            ol2.Description__c = 'desc2';
            ol2.PartNumber__c = '123455';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol2);
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol3.OriginalItem__c = listOrderLines[0].Id;
            ol3.OrderType__c = 'BUNDLEITEM';
            ol3.Description__c = 'desc2';
            ol3.PartNumber__c = '123455';
            ol3.Suppliable__c = 'YES';
            ol3.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol3);
            insert listBundleOrderLines;

            list<Offer__c> listBundleOffers = new list<Offer__c>();
            Offer__c off1 = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, listSalesOrders[0], 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            off2.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, listSalesOrders[0], 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.PreselectedForOrder__c = true;
            off3.Accepted__c = 'YES';
            listBundleOffers.add(off3);
            insert listBundleOffers;
            
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            boolean firstElement =true;
            Test.startTest();

                OrderMakeSelection controller = new OrderMakeSelection();
                
                controller.queryRecords();
                system.debug('##currentPartWrapper '+controller.mapPartWrapper);
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.parentOffer=listBundleOffers[2];
                        }
                    }
                }
                controller.order();
                controller.respond();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
    static testmethod void testOrderBundleYES(){
        system.runas(userAdmin){

            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol2.OriginalItem__c = listOrderLines[0].Id;
            ol2.OrderType__c = 'BUNDLEITEM';
            ol2.Description__c = 'desc2';
            ol2.PartNumber__c = '123455';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol2);
            insert listBundleOrderLines;

            list<Offer__c> listBundleOffers = new list<Offer__c>();
            Offer__c off1 = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, listSalesOrders[0], 'INPROCESS');
            off2.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off2.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off2);
            insert listBundleOffers;
            
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                system.debug('##currentPartWrapper '+controller.mapPartWrapper);
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                        }
                    }
                }
                controller.order();
                controller.respond();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
    //WCH 15/01/2019 : increase code coverage
    static testmethod void testOrderInvalidId(){
        system.runas(userAdmin){
    
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id+'notAnId')));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
            Test.stopTest();

            System.assertEquals(true, controller.hasErrors);
        }
    }
    //WCH 15/01/2019 : increase code coverage
    static testmethod void testOrderSOResponded(){
        system.runas(userAdmin){
    
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                /*controller.currentClaimOrderAssessment = assessments[0];*/

                listSalesOrders[0].Status__c=ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE;
                update listSalesOrders[0];

                controller.order();
            Test.stopTest();

            System.assertEquals(true, controller.hasErrors);
        }
    }
    static testmethod void testOrderNO(){
        system.runas(userAdmin){

            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol2.OriginalItem__c = listOrderLines[0].Id;
            ol2.OrderType__c = 'BUNDLEITEM';
            ol2.Description__c = 'desc2';
            ol2.PartNumber__c = '123455';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol2);
            insert listBundleOrderLines;

            list<Offer__c> listBundleOffers = new list<Offer__c>();
            Offer__c off1 = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, listSalesOrders[0], 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            off2.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol1, listSalesOrders[1], 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.PreselectedForOrder__c = true;
            off3.Accepted__c = 'YES';
            off3.ParentOffer__c = listOffers[4].Id;
            listBundleOffers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol2, listSalesOrders[1], 'INPROCESS');
            off4.Type__c = 'QUICK';
            off4.PreselectedForOrder__c = true;
            off4.Accepted__c = 'YES';
            off4.ParentOffer__c = listOffers[4].Id;
            listBundleOffers.add(off4);
            insert listBundleOffers;
            
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                controller.currentClaimOrderAssessment = assessments[0];
                controller.order();
                controller.respond();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }

    static testmethod void testrespond(){
        system.runas(userAdmin){
            listSalesOrders[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE;
            listSalesOrders[0].Assessment__c = assessments[0].id;
            update listSalesOrders[0];

            accounts[0].Type = 'Expert';
            update accounts[0];

            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[1].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
            for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                    for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                        currentOfferWrapper.isAccepted = true;
                        currentOfferWrapper.addChildOffer(listOffers[0]);
                    }
                }
            }
                controller.respond();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            //AMI 26/09/17: to verify
            //System.assertEquals('INDELIVERY', assessment.OrderStatus__c);
        }
    }

    static testmethod void testBack(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                controller.back();
            Test.stopTest();

            Assessment__c assessment = [select Status__c, OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001'];

            System.assertEquals('REJECTED', assessment.Status__c);
        }
    }

    static testmethod void testOrderMakeSelectionCatchException(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf('2555')));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf('2555')));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.back();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

        }
    }

    static testmethod void testTermsAndCondition(){
        system.runas(userAdmin){
            //creating attachment
            Blob b = Blob.valueOf('Test Data');
        
            Attachment attachment = new Attachment();
            attachment.ParentId = accounts[0].Id;
            attachment.Name = 'TermsAndCondition-SAS';
            attachment.ContentType = 'application/pdf';
            attachment.Body = b;
            
            insert attachment;

            Test.startTest();
                String attachPdf = OrderMakeSelection.getTermsAndCondtions(accounts[0].Id);
            Test.stopTest();

            system.assertNotEquals(null,attachPdf);
        }
    }

    //AMI 26/09/17 : test method for query method
    static testmethod void testQueryInitialisation(){
        system.debug('## Start testQueryInitialisation');
        
        system.runas(userAdmin){
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                controller.queryRecords();

                system.assertEquals('444',controller.currentClaimOrderAssessment.VINNumber__c);
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testQueryInitialisation');
    }

    //AMI 26/09/17 : test method for distributor call success
    static testmethod void testDistributorCallOutSuccess(){
        system.debug('## Start testDistributorCallOutSuccess');
        
        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Distributors":{"Distributor_ScTest1":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

        system.runas(userAdmin){
            //update distributor connected checkbox
            accounts[0].DistributorConnected__c = true;

            update accounts[0];

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK',jsonResponse)); 
                string result = OrderMakeSelection.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
                system.assertEquals(true,result.contains('test'));
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testDistributorCallOutSuccess');
    }
    
    //AMI 26/09/17 : test method for distributor call failure with distribitor not found (message value returned in response)
    static testmethod void testDistributorCallOutFailureWithMessageReturned(){
        system.debug('## Start testDistributorCallOutFailureWithMessageReturned');
        
        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Message":"Client non trouver","Distributors":{"Distributor_ScTest1LcssLP":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

        system.runas(userAdmin){
            //update distributor connected checkbox
            accounts[0].DistributorConnected__c = true;

            update accounts[0];

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK',jsonResponse)); 
                string result = OrderMakeSelection.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
                system.assertEquals(true,result.contains('Message'));
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testDistributorCallOutFailureWithMessageReturned');
    }
    
    //AMI 26/09/17 : test method for distributor call failure (error during execution)
    static testmethod void testDistributorCallOutFailure(){
        system.debug('## Start testDistributorCallOutFailure');
        
        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Message":"Client non trouver","Distributors":{"Distributor_ScTest1LcssLP":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

        system.runas(userAdmin){
            Test.startTest();

                //simulate error
                update accounts;

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK',jsonResponse)); 
                string result = OrderMakeSelection.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
                system.assertEquals(false,string.isBlank(result));    
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testDistributorCallOutFailure');
    }

    //AMI 26/09/17 : test method for ordering with callout
    static testmethod void testOrderCallout(){
        system.debug('## Start testOrderCallout');
        
        system.runas(userAdmin){
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            //update ol status to be able to launch callout
            listOrderLines[0].SASStatus__c = 'CONFIRMED';
            listOrderLines[1].SASStatus__c = 'CONFIRMED';
            update listOrderLines;

            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.queryRecords();
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                        }
                    }
                }
                controller.order();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PENDING DISTRIBUTOR (CARE)', assessment.OrderStatus__c);
        }

        system.debug('## End testOrderCallout');
    }

    //AMI 26/09/17 : test method for distributor call during ordering success
    static testmethod void testOrderCallOutSuccess(){
        system.debug('## Start testOrderCallOutSuccess');

        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Distributors":{"Distributor_ScTest1":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

        system.runas(userAdmin){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK',jsonResponse)); 
                OrderMakeSelection.callDistributor(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)),new set <id>{listpurchaseOrders[0].Id},new set <id>());
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testOrderCallOutSuccess');
    }

    //AMI 26/09/17 : test method for distributor call during ordering failure
    static testmethod void testOrderCallOutFailure(){
        system.debug('## Start testOrderCallOutFailure');
        
        system.runas(userAdmin){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(400,'KO','')); 
                OrderMakeSelection.callDistributor(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)),new set <id>{listpurchaseOrders[0].Id},new set <id>());
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testOrderCallOutFailure');
    }

    //AMI 26/09/17 : test method for encryptBase64 method
    static testmethod void testencryptBase64(){
        system.debug('## Start encryptBase64');
        
        system.runas(userAdmin){
            Test.startTest();
                OrderMakeSelection.encryptBase64('test');
            Test.stopTest();
        }//end system.runAs

        system.debug('## End encryptBase64');
    }

    //AMI 26/09/17 : test method for redirectPage method
    static testmethod void testRedirectPage(){
        system.debug('## Start testRedirectPage');
        
        system.runas(userAdmin){
            Test.startTest();
                OrderMakeSelection controller = new OrderMakeSelection();
                controller.redirectPage();
                
                System.assertEquals(new PageReference('/apex/search').getUrl(), controller.redirectPage().getUrl());
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testRedirectPage');
    }

    //RLA
    static testmethod void coverageWrapper(){
        System.runAs(userAdmin){
            Test.startTest();
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            insert bs2;
    
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-00012', bs2);
            //ass2.ParentAssessment__c = ass1.Id;
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
            ass2.AssessmentNumber__c = 'Num001-12';
            ass2.OrderStatus__c = 'PREACCEPTANCE';
            ass2.AssessmentID__c = 'Num001-12';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            insert ass2;
    
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs2, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            insert so1;
    
    
            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c = 'CONFIRMED';
            insert ol1;
    
            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            insert off1;       
    
            
            Offer__c offChild = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            offChild.Type__c = 'QUICK';
            offChild.PreselectedForOrder__c = true;
            offChild.Accepted__c = 'YES';
            offChild.ParentOffer__c = off1.Id;
            insert offChild;
     
            Map<String, String> mapPartTypeDelayMatrix = new Map<String, String>();
            system.debug('@@ start here');
            OrderMakeSelection.OfferWrapper currentOfferWrapper = new OrderMakeSelection.OfferWrapper(off1, mapPartTypeDelayMatrix  );
            currentOfferWrapper.parentOffer =  off1;
            Test.stopTest();
        }
    }

     //RLA
    static testmethod void RecoverySAS(){

        System.runAs(userAdmin){
        
            Test.startTest();
            List<PurchaseOrder__c> lstPO = [select id from PurchaseOrder__c where assessment__c =: childAssessments[0].Id];
            system.debug('@@ lstPO: '+lstPO);
            
            delete lstPO;

            childpartLists[0].NextDistributors__c = '{P0:'+ accounts[4].Id + '}';
            childpartLists[1].NextDistributors__c = '{P0:'+ accounts[4].Id + '}';
            update childpartLists;
            system.debug('@@ childpartLists: '+childpartLists);

            PrerequisiteOrder__c so = TestFactory.createSalesOrder(childAssessments[0], accounts[0], 'PREACCEPTANCE');
            so.BodyShopOrderNumber__c = '1274';
            so.Status__c = 'PREACCEPTANCE';
            insert so;


            PurchaseOrder__c po = TestFactory.createPurchaseOrder(childAssessments[0], so, accounts[0], accounts[3], '');
            po.Status__c = 'PREDRAFTQOUTE';        
            insert PO;

            List<OrderLine__c> listOrderLinesIns = new List<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMEDWITHDELAY';
            listOrderLinesIns.add(ol1);

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.OrderType__c = 'ORIGINAL';
            ol2.PartNumber__c = '1234';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='NOTFOUND';
            listOrderLinesIns.add(ol2);
            insert listOrderLinesIns;

            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po, 'INPROCESS');
            ol3.PartList__c = childpartLists[1].Id;
            ol3.Description__c = 'desc123';
            ol3.OrderType__c = 'FINAL';
            ol3.PartNumber__c = '1234';
            ol3.Suppliable__c = 'YES';
            ol3.SASStatus__c='NOTFOUND';
            ol3.OriginalItem__c = listOrderLinesIns[1].Id;
            //ol3.SelectedByBS__c = true;
            
            insert ol3;

            List<Offer__c> listOffersIns = new List<Offer__c>();

            Offer__c off1 = TestFactory.createOfferLine(listOrderLinesIns[0], so, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            listOffersIns.add(off1);      

            Offer__c off2 = TestFactory.createOfferLine(listOrderLinesIns[1], so, 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            listOffersIns.add(off2); 
            

            
            Offer__c offChild = TestFactory.createOfferLine(ol3, so, 'INPROCESS');
            offChild.Type__c = 'QUICK';
            offChild.PreselectedForOrder__c = true;
            offChild.Accepted__c = 'YES';
            listOffersIns.add(offChild);        
            insert listOffersIns;

            
            map <Id, PartList__c> allPartsMap = new map <Id, PartList__c>();
            for(PartList__c pt : [select id,CrossReferenceId__c,CrossReferenceId__r.IAMPartNumber__c,
                                        PartNumber__c,Price__c,Type__c,ProducerName__c,Description__c,Quantity__c,Alpha_Scale_MRID__c, Assessment__r.TECH_EntityCountryCode__c,
                                        Assessment__r.Feature__c, NextDistributors__c,OriginalPart__c,OriginalPart__r.NextDistributors__c/*RLA 3145*/
                                    from PartList__c
                                    where Assessment__c =:childAssessments[0].Id ]){//RLA 16/05/2019 Case 003145 Spare part Recovery SAS France
                allPartsMap.put(pt.Id,pt);
            }
            system.debug('@@ allPartsMap'+allPartsMap);

            
                system.debug('@@ start here');

                OrderMakeSelection.recoverySAS(childAssessments[0].Id,allPartsMap );
            Test.stopTest();
        }

    }

    
    static testmethod void TestSetParentOffer(){
        System.runAs(userAdmin){
            Test.startTest();
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            insert bs2;
    
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-00012', bs2);
            //ass2.ParentAssessment__c = ass1.Id;
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
            ass2.AssessmentNumber__c = 'Num001-12';
            ass2.OrderStatus__c = 'PREACCEPTANCE';
            ass2.AssessmentID__c = 'Num001-12';
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            insert ass2;
    
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs2, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            insert so1;
    
    
            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c = 'CONFIRMED';
            insert ol1;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            insert off1;       
    
            
            Offer__c offChild = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            offChild.Type__c = 'QUICK';
            offChild.PreselectedForOrder__c = true;
            offChild.Accepted__c = 'YES';
            offChild.ParentOffer__c = off1.Id;
            insert offChild;

            Map<String, String> mapPartTypeDelayMatrix = new Map<String, String>();
            OrderMakeSelection.OfferWrapper currentOfferWrapper = new OrderMakeSelection.OfferWrapper(off1, mapPartTypeDelayMatrix  );

            currentOfferWrapper.parentOffer = null;
            currentOfferWrapper.setParentOffer(new Offer__c(), mapPartTypeDelayMatrix);
            Test.stopTest();
        }
    }
    static testmethod void TestGetTargetSO(){
        System.runAs(userAdmin){
            Test.startTest();
            OrderMakeSelection o = new OrderMakeSelection();
            o.getTargetedSO();
            Test.stopTest();
        }
    }
    static testmethod void TestCancelCurrentSO(){
        System.runAs(userAdmin){
            Test.startTest();
            OrderMakeSelection o = new OrderMakeSelection();
            o.cancelCurrentSO();
            Test.stopTest();
        }
    }
    static testmethod void TestToggleIsAcceptedForAllParts(){
        system.runas(userAdmin){

            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol2.OriginalItem__c = listOrderLines[0].Id;
            ol2.OrderType__c = 'BUNDLEITEM';
            ol2.Description__c = 'desc2';
            ol2.PartNumber__c = '123455';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol2);
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol3.OriginalItem__c = listOrderLines[0].Id;
            ol3.OrderType__c = 'BUNDLEITEM';
            ol3.Description__c = 'desc2';
            ol3.PartNumber__c = '123455';
            ol3.Suppliable__c = 'YES';
            ol3.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol3);
            insert listBundleOrderLines;

            list<Offer__c> listBundleOffers = new list<Offer__c>();
            Offer__c off1 = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, listSalesOrders[0], 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            off2.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, listSalesOrders[0], 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.PreselectedForOrder__c = true;
            off3.Accepted__c = 'YES';
            listBundleOffers.add(off3);
            insert listBundleOffers;
            
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            boolean firstElement =true;
            Test.startTest();

                OrderMakeSelection controller = new OrderMakeSelection();
                
                controller.queryRecords();
                system.debug('##currentPartWrapper '+controller.mapPartWrapper);
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.parentOffer=listBundleOffers[2];
                        }
                    }
                }
                controller.toggleIsAcceptedForAllParts();
            Test.stopTest();

            // Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
            //                             from Assessment__c 
            //                             where AssessmentID__c = 'Num001-1'];

            // System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
    static testmethod void TestIsPriceZero(){
        System.runAs(userAdmin){
            Test.startTest();
            OrderMakeSelection.BundleItemWrapper currentBundleItemWrapper = new OrderMakeSelection.BundleItemWrapper(listOffers[0]);
            Boolean isPriceZero = currentBundleItemWrapper.isPriceZero;
            Test.stopTest();
        }
    }
    static testmethod void TestSetAlreadyOrdered(){
        System.runAs(userAdmin){
            Test.startTest();
            OrderMakeSelection.PartWrapper currentPartWrapper = new OrderMakeSelection.PartWrapper(listOffers[0]);
            currentPartWrapper.SetAlreadyOrdered();
            Test.stopTest();
        }
    }
    static testmethod void TestOrder_1(){
        system.runas(userAdmin){

            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol1.OriginalItem__c = listOrderLines[0].Id;
            ol1.OrderType__c = 'BUNDLEITEM';
            ol1.Description__c = 'desc1';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol2.OriginalItem__c = listOrderLines[0].Id;
            ol2.OrderType__c = 'BUNDLEITEM';
            ol2.Description__c = 'desc2';
            ol2.PartNumber__c = '123455';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol2);
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            ol3.OriginalItem__c = listOrderLines[0].Id;
            ol3.OrderType__c = 'BUNDLEITEM';
            ol3.Description__c = 'desc2';
            ol3.PartNumber__c = '123455';
            ol3.Suppliable__c = 'YES';
            ol3.SASStatus__c='CONFIRMED';
            listBundleOrderLines.add(ol3);
            insert listBundleOrderLines;

            list<Offer__c> listBundleOffers = new list<Offer__c>();
            Offer__c off1 = TestFactory.createOfferLine(ol1, listSalesOrders[0], 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, listSalesOrders[0], 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            off2.ParentOffer__c = listOffers[0].Id;
            listBundleOffers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, listSalesOrders[0], 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.PreselectedForOrder__c = true;
            off3.Accepted__c = 'YES';
            listBundleOffers.add(off3);
            insert listBundleOffers;
            
            Test.setCurrentPage(Page.OrderMakeSelection);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            boolean firstElement =true;
            Test.startTest();

                OrderMakeSelection controller = new OrderMakeSelection();
                
                controller.queryRecords();
                system.debug('##currentPartWrapper '+controller.mapPartWrapper);
                for(OrderMakeSelection.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.addChildOffer(listBundleOffers[0]);
                            currentOfferWrapper.parentOffer=listBundleOffers[2];
                        }
                    }
                }
                controller.order();
            Test.stopTest();

            // Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
            //                             from Assessment__c 
            //                             where AssessmentID__c = 'Num001-1'];

            // System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
}