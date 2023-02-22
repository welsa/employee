/*************************************************************************************
Class Name - NonAxaOrdering_TEST
Version - 1.0
Created Date - 06-JUL-2021
Function - TestClass to NonAxaOrdering

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------
* HMO           06/07/2021  Original Version
*************************************************************************************/

@isTest
public class NonAxaOrdering_TEST {
    
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

    static Attachment attachment;
    static UserRecordAccess recordAccess;
    
    //HMO
    static NonAxaOrdering__mdt nonAxaOrderingMDT;
    static Account nonAxaBS;
    static crossReference__c crossRef;
    static account expert;
    static OrderLine__c orderLinexx;
    
    
     static {
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

        attachment = new Attachment();
        recordAccess = new UserRecordAccess();

        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = '258974136';
        insert userAdmin;
         
        //HMO
        nonAxaBS = new Account();
        crossRef = new crossReference__c();
        expert = new Account();
       

        system.runas(userAdmin){
            
            nonAxaBs = TestFactory.createAccountBodyshop('BodyShop_ScTestNonAxa', 'FR');            
            nonAxaBs.IsEligible__c = true;
            nonAxaBs.isEligibleShippingCost__c = true;
            nonAxaBs.DistributorConnected__c = true;
            nonAxaBs.ReferenceNumber__c = 'FR2878789868';
            nonAxaBs.ShippingCostRegionClassic__c='00';
            nonAxaBs.ShippingCostRegionOther__c='00';
            nonAxaBs.ShippingCostValueOther__c= 10.2;
            nonAxaBs.ShippingCostStepOther__c= 10.2;
            nonAxaBs.ShippingPostalCode='0000';
            nonAxaBs.ShippingCountryCode='FR';
            nonAxaBs.priority__c=1;
            nonAxaBs.Type = 'Expert';
            nonAxaBs.Non_Axa_Sorting_for_Order__c = 'OEM Only'; // add cheapest
            nonAxaBs.feature__c = 'NONAXASubstitution';
      nonAxaBs.KeepNonAXA__c = 10;
            nonAxaBs.Non_AXA_Authorised__c = true;
            nonAxaBs.BillingCity = 'NIMES';
            nonAxaBs.BillingCountry = 'France';
            nonAxaBs.BillingCountryCode = 'FR';
            nonAxaBs.BillingStreet = '257 Chemin du Mas de Cheylon';
            nonAxaBs.BillingState = 'Gard';
            nonAxaBs.BillingPostalCode = '30900';

             insert nonAxaBs;
            
            crossRef = TestFactory.createCrossReference('33', '76931643423', 'Magneti Marelli', 25.7, true);
            crossRef.NONAXA_AS_Public_Price__c = 22.5;
            crossRef.NONAXA_AS_Net_Price__c = 24.5;
            insert crossRef;
            
            //MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
            cs = TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            //RBE 05/12/2022
            cs.ActivateCatalogOEM__c = true;

            insert cs;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.isEligibleShippingCost__c = true;
            bs1.DistributorConnected__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';
            bs1.ShippingCostRegionClassic__c='00';
            //bs1.ShippingPostalCode='0000';
            bs1.ShippingCountryCode='FR';
      bs1.ShippingCity = 'Paris';
      bs1.ShippingStreet = '5 RUE EMILE LEPEU';
      bs1.ShippingPostalCode = '75011';

            bs1.BillingCity = 'NIMES';
            bs1.BillingCountry = 'France';
            bs1.BillingCountryCode = 'FR';
            bs1.BillingStreet = '257 Chemin du Mas de Cheylon';
            bs1.BillingState = 'Gard';
            bs1.BillingPostalCode = '30900';

            bs1.priority__c=1;
            bs1.NOB_NetworkType__c  = 'Réseau Premium';
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            accounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Name = 'Distributor_ScTest1';
            dist1.Tech_Distributor__c = 'Distributor_ScTest1';
            dist1.Categories__c = 'A';
            dist1.DistributorConnected__c= true;
            dist1.Type_of_Substitutes__c = 'Connected Substitute;Connected OEM;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            dist1.Tech_Distributor__c = 'SAS';            
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            dist1.OrderRequest__c='OrderR4';
            dist1.Agency_V3__c = true;
            accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('SAS;ANIEL', 'FR');
            dist1.Name = 'SAS;ANIEL';
            dist1.Tech_Distributor__c = 'SAS;ANIEL';
            dist2.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            dist2.Categories__c = 'A;B';
            dist2.Tech_Distributor__c = 'SAS';
            dist2.ContactEmail__c = 'turismo@italy.it';
            accounts.add(dist2);  

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist1.Categories__c = 'A';
            dist2.Tech_Distributor__c = 'SAS';
            dist2.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';


            accounts.add(dist3);    

            insert accounts;

            //HMO -- cs.AlphaScaleEntity__c = accounts[0].Id;
            cs.AlphaScaleEntity__c = nonAxaBs.Id;
            update cs;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', nonAxaBs);
            ass1.Entity__c = 'NON AXA';
            ass1.EntityRules__c = 'FRNONAXA';
            ass1.EntityCode__c = 'NONAXA';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.VINCheck__c = 2;
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'ninjaaaaaa';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.DisableUpdateStockInfo__c = false;
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass1);
            insert assessments;

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0001', nonAxaBs);
            ass2.ParentAssessment__c = ass1.Id;
            ass2.Entity__c = 'NON AXA';
            ass2.EntityRules__c = 'FRNONAXA';
            ass2.EntityCode__c = 'NONAXA';
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
            ass2.Comment__c='test comment for claim order';
            childAssessments.add(ass2);

            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0002', nonAxaBs);
            ass3.ParentAssessment__c = ass1.Id;
            ass3.Entity__c = 'NON AXA';
            ass3.EntityRules__c = 'FRNONAXA';
            ass3.EntityCode__c = 'NONAXA';
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

            Id recordType = Schema.SObjectType.PartList__c.getRecordTypeInfosByDeveloperName().get('Material').getRecordTypeId();
            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'FRDIVA - 2021-08-04T12:50:29.052Z-1&#124;20c32207d2e8619ff49054f94e0553b8-ASCR-0027789133-a007a000008t5mVAAQ-7';
            pl1.Quantity__c = 15;
            pl1.recordTypeId = recordType;
            pl1.CurrencyIsoCode = 'EUR';
            pl1.SelectedByBS__c = false;
            pl1.CrossReferenceId__c = crossRef.Id;
            pl1.ProducerName__c = 'Magneti Marelli';
            pl1.type__c = 'B';

            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass1);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            pl2.type__c = 'B';
            pl2.CrossReferenceId__c = crossRef.Id;
            partLists.add(pl2);
            insert partLists;


            PartList__c pl3 = TestFactory.createPartList(ass2);
            pl3.OriginalPart__c = partLists[0].Id;
            pl3.SelectedByBS__c = true;
            pl3.TECH_OrderedCounter__c = 1;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl3.Quantity__c = 15;
            //HMO -- 17-11-2021
            pl3.NonAxa_Original_Part__c = partLists[1].Id;
            pl3.type__c = 'C';
            pl3.CrossReferenceId__c = crossRef.Id;
            childpartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(ass2);
            pl4.OriginalPart__c = partLists[0].Id;
            pl4.SelectedByBS__c = true;
            pl4.TECH_OrderedCounter__c = 1;
            pl4.Quantity__c = 15;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            pl4.NonAxa_Original_Part__c = partLists[1].Id;
            pl4.type__c = 'B';
            pl4.CrossReferenceId__c = crossRef.Id;
            childpartLists.add(pl4);
            insert childpartLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs1, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            listSalesOrders.add(so1);  

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass3, bs1, 'PREACCEPTANCE');
            so2.BodyShopOrderNumber__c = '12743';
            so2.Status__c = 'INDELIVERY';
            listSalesOrders.add(so2);   

            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs1, 'PREACCEPTANCE');
            so2.BodyShopOrderNumber__c = '12743';
            //so2.Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE ;
            listSalesOrders.add(so3);   

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass2, so1, bs1, dist1, '');
            po1_1.Status__c = 'PREDRAFTQOUTE';
            po1_1.AgencyMode__c = false;
            po1_1.wsDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 09, 30, 00);
            po1_1.wsErrorMessage__c = 'err';
            listpurchaseOrders.add(po1_1);
            insert listpurchaseOrders;


            orderLinexx = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            orderLinexx.PartList__c = childpartLists[0].Id;
            orderLinexx.Description__c = 'FEU AR GG - Magneti Marelli (716766500123) - équipementier';
            orderLinexx.OrderType__c = 'FINAL';
            orderLinexx.PartNumber__c = 'RN7455E';//123456
            orderLinexx.Suppliable__c = 'YES';
            orderLinexx.SASStatus__c='CONFIRMED';
            orderLinexx.CurrencyIsoCode = 'EUR';
            insert orderLinexx;

            
            //HMO -- Orderline = confirmed
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = childpartLists[0].Id;
            ol1.Description__c = 'FEU AR G - Magneti Marelli (716766500123) - équipementier';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = 'RN7455E';//123456
            ol1.Suppliable__c = 'YES';
            ol1.SASStatus__c='CONFIRMED';
            ol1.CurrencyIsoCode = 'EUR';
            ol1.OriginalItem__c = orderLinexx.Id;

            listOrderLines.add(ol1);

       

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.OrderType__c = 'FINAL';
            ol2.PartNumber__c = '1234';
            ol2.Suppliable__c = 'YES';
            ol2.SASStatus__c='CONFIRMEDWITHDELAY';
            listOrderLines.add(ol2);

            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol3.PartList__c = childpartLists[0].Id;  
            ol3.OrderType__c = 'FINAL';
            ol3.Description__c = 'desc123';          
            ol3.PartNumber__c = '123456';
            ol3.Suppliable__c = 'YES';
            ol3.SASStatus__c='PARTIAL';
            listOrderLines.add(ol3);

            OrderLine__c ol4 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol4.PartList__c = childpartLists[1].Id;            
            ol4.OrderType__c = 'FINAL';
            ol4.Description__c = 'desc1234';
            ol4.PartNumber__c = '1234';
            ol4.Suppliable__c = 'YES';
            ol4.SASStatus__c='NOTFOUND';
            listOrderLines.add(ol4);
            
            OrderLine__c ol5 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol5.PartList__c = childpartLists[1].Id;            
            ol5.OrderType__c = 'FINAL';
            ol5.Description__c = 'desc1234';
            ol5.PartNumber__c = '1234';
            ol5.Suppliable__c = 'YES';
            ol5.SASStatus__c='OTHER';
            listOrderLines.add(ol5);
            
            insert listOrderLines;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'FR30601848200068';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            off1.PreferredDistributor__c=true;//false
            off1.CurrencyIsoCode='EUR';
            listOffers.add(off1);
            
            Offer__c off2 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off2.Type__c = 'FR30601848200068';
            off2.PreselectedForOrder__c = true;
            off2.Accepted__c = 'YES';
            off2.PreferredDistributor__c=true;//false
            off2.CurrencyIsoCode='EUR';
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

            Blob b = Blob.valueOf('Test Data');
            attachment.ParentId = accounts[2].Id;
            attachment.Name = 'TermsAndCondition-SAS';
            attachment.ContentType = 'application/pdf';
            attachment.Body = b;
            
            insert attachment;


            String recordTypeExpert =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Expert').getRecordTypeId();
            expert.Name = 'expertAxa';
            expert.recordTypeId = recordTypeExpert;
            expert.IsEligible__c = true;
            expert.isEligibleShippingCost__c = true;
            expert.DistributorConnected__c = true;
            expert.ReferenceNumber__c = 'FR2234796636';
            expert.ShippingCostRegionClassic__c='01';
            //bs1.ShippingPostalCode='0000';
            expert.ShippingCountryCode='FR';
      expert.ShippingCity = 'Paris';
      expert.ShippingStreet = '5 RUE EMILE LEPEU';
      expert.ShippingPostalCode = '75011';

            expert.BillingCity = 'NIMES';
            expert.BillingCountry = 'France';
            expert.BillingCountryCode = 'FR';
            expert.BillingStreet = '257 Chemin du Mas de Cheylon';
            expert.BillingState = 'Gard';
            expert.BillingPostalCode = '30906';
            expert.priority__c=1;
            expert.NOB_NetworkType__c  = 'Réseau Premium';
            expert.ContactEmail__c = 'testVenize@Italy.it';
            expert.ASEntity__c = 'ASBE1';
            expert.ExpertSubstitutionMethod__c = 'FORCED';
            expert.phone = '111111111';
            expert.VATNumber__c = '20';
            expert.SubstitutionMethod2__c = 'PROPOSED';
            expert.NOB_Statut__c = 'Actif';
            insert expert;
        }  
    }
    
    @isTest public static void testBSExpertOEM(){
        MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));
          Test.setCurrentPage(Page.NONPartenaireOrdering);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            listOffers[1].ParentOffer__c = listOffers[0].Id;
            childpartLists[0].TECH_OrderedCounter__c =0;
            childpartLists[0].OriginalPart__c = null;
            childpartLists[1].OriginalPart__c = null;
            listOrderLines[0].Suppliable__c = 'NO';
            listSalesOrders[0].Status__c = 'PREACCEPTANCE';

            Test.startTest();
                update listOffers;
                update childpartLists;
                update listOrderLines;
                update listSalesOrders;

                NonAxaOrdering controller = new NonAxaOrdering();
                controller.queryRecords();
                for(NonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(NonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(NonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = false;
                            currentOfferWrapper.addChildOffer(listOffers[1]);
                        }
                    }
                }
                controller.order();

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

            //System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
     }

     //RBE 05/12/2022 Increase test coverage
     @isTest public static void testVerifyPermission(){
        nonAxaBS.Type = 'Other';
        User testUser = TestFactory.createUserASPISLocal('UserNoUserRecordAccess');
        
        MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));
        Test.setCurrentPage(Page.NONPartenaireOrdering);
        ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
        ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
        ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

        Test.startTest();
            insert testUser;
            update nonAxaBS;
            NonAxaOrdering controller = new NonAxaOrdering();
            system.runAs(testUser){
                controller.queryRecords();
            }              
        Test.stopTest();
     }
   
    @isTest
    public static void testBSOtherCheapest2(){
        nonAxaBs.Type = 'Other';
        nonAxaBs.Non_Axa_Sorting_for_Order__c = 'Cheapest';
       
        nonAxaBS.ParentId = expert.Id;


        listSalesOrders[0].Status__c = 'INACCEPTANCE';
        listOrderLines[0].AlphaScaleMRID__c = 'ASCR-0027789133';//DSP-3333
        listSalesOrders[0].Status__c = 'INDELIVERY';

        listOffers[1].ParentOffer__c = listOffers[0].Id;
        childpartLists[0].TECH_OrderedCounter__c =0;
        childpartLists[0].OriginalPart__c = null;
        childpartLists[1].OriginalPart__c = null;
        listOrderLines[0].Suppliable__c = 'NO';


         MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));
          Test.setCurrentPage(Page.NONPartenaireOrdering);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            System.runAs(userAdmin){
            Test.startTest();
            update nonAxaBs;
                update listOffers;
                update childpartLists;
                update listOrderLines;
                update listSalesOrders;
            //update listSalesOrders[0];
            //update listOrderLines[0];
       
                Map<String, String> mapPartTypeDelayMatrix = new Map<String, String>();
                NonAxaOrdering controller = new NonAxaOrdering();
                controller.queryRecords();
                system.debug('****FT**'+controller.mapPartWrapper.keyset());
                for(NonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    system.debug('****FT****'+currentPartWrapper.mapDistributorWrapper.keyset());
                    for(NonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        system.debug('****FT****'+currentDistributorWrapper.mapOfferWrapper.keyset());
                        for(NonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            system.debug('****FT****'+currentOfferWrapper);
                            currentOfferWrapper.setParentOffer(listOffers[1], mapPartTypeDelayMatrix);
                            currentOfferWrapper.addChildOffer(listOffers[0]);
                            currentOfferWrapper.isAccepted = false;
                        }
                    }
                    system.debug('****RJ****'+currentPartWrapper);
                    for ( NonAxaOrdering.PartWrapper currentSubsWrapper: currentPartWrapper.partSubstitutes){
                        system.debug('****RJ****'+currentSubsWrapper);
                        for(NonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentSubsWrapper.mapDistributorWrapper.values())
                        {
                            system.debug('****RJ****'+currentDistributorWrapper);
                            for(NonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                                system.debug('****RJ****'+currentOfferWrapper);
                                
                                currentOfferWrapper.setParentOffer(listOffers[1], mapPartTypeDelayMatrix);
                                currentOfferWrapper.parentOffer.OrderLine__r=listOrderLines[0];
                                system.debug('TestParent'+currentOfferWrapper.parentOffer);
                                system.debug('TestParent'+currentOfferWrapper.isAccepted);
                                currentOfferWrapper.addChildOffer(listOffers[0]);
                                currentOfferWrapper.isAccepted = false;
                            }
                        }
                    }
                }
               
                System.debug('&&&&&&&'+controller.mapPartWrapper.values().get(0).mapDistributorWrapper.values().get(0).mapOfferWrapper.values().get(0).isAccepted);
                controller.order();
                System.debug('&&&&&&&'+controller.mapPartWrapper.values().get(0).mapDistributorWrapper.values().get(0).mapOfferWrapper.values().get(0).isAccepted);
               
                try{
       
                    String theColor = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].deliveryColor;
                    Boolean isESEligible = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isEligleES;
                    Integer theRowSpan = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].rowSpan;
                    Boolean isItOriginal = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferOriginal;
                    Boolean isItOfferAlternative = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferAlternative;
                    Boolean isItBundle = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isBundle;
                    Boolean isZeroPrice = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isPriceZero;
                }
                catch(exception e){
                   
                }
            Test.stopTest();
            }

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('INDELIVERY', assessment.OrderStatus__c);
    }
    @isTest
    public static void testBSOtherCheapest(){
        nonAxaBs.Type = 'Other';
        nonAxaBs.Non_Axa_Sorting_for_Order__c = 'Cheapest';
        
        nonAxaBS.ParentId = expert.Id;


        listSalesOrders[0].Status__c = 'INACCEPTANCE';
        listOrderLines[0].AlphaScaleMRID__c = 'ASCR-0027789133';//DSP-3333
        listSalesOrders[0].Status__c = 'INDELIVERY';

        listOffers[1].ParentOffer__c = listOffers[0].Id;
        childpartLists[0].TECH_OrderedCounter__c =0;
        childpartLists[0].OriginalPart__c = null;
        childpartLists[1].OriginalPart__c = null;
        listOrderLines[0].Suppliable__c = 'NO';


         MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));
          Test.setCurrentPage(Page.NONPartenaireOrdering);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            System.runAs(userAdmin){
            Test.startTest();
            update nonAxaBs;
                update listOffers;
                update childpartLists;
                update listOrderLines;
                update listSalesOrders;
            //update listSalesOrders[0];
            //update listOrderLines[0];
        
                Map<String, String> mapPartTypeDelayMatrix = new Map<String, String>();
                NonAxaOrdering controller = new NonAxaOrdering();
                controller.queryRecords();
                for(NonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(NonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(NonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.setParentOffer(listOffers[0], mapPartTypeDelayMatrix);
                            currentOfferWrapper.addChildOffer(listOffers[1]);
                        }
                    }
                }
                controller.order();
                
                try{
        
                    String theColor = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].deliveryColor;
                    Boolean isESEligible = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isEligleES;
                    Integer theRowSpan = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].rowSpan;
                    Boolean isItOriginal = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferOriginal;
                    Boolean isItOfferAlternative = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isOfferAlternative;
                    Boolean isItBundle = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isBundle;
                    Boolean isZeroPrice = controller.mapPartWrapper.values()[0].mapDistributorWrapper.values()[0].mapOfferWrapper.values()[0].isPriceZero;
                }
                catch(exception e){
                    
                }
            Test.stopTest();
            }

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('INDELIVERY', assessment.OrderStatus__c);
    }
    
  //HRM 12/10/2021
    @isTest
    public static void testBack(){
        Assessment__c assessment = new Assessment__c();
        MockCustomMetaData_TEST.setMetaData('SELECT Active__c FROM NonAxaOrdering__mdt WHERE DeveloperName = \'FR\'', (List<NonAxaOrdering__mdt>) JSON.deserialize('[{"Active__c": "true"}]', List<NonAxaOrdering__mdt>.class));
        Test.setCurrentPage(Page.NONPartenaireOrdering);
        ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
        ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
        ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

        Test.startTest();
        NonAxaOrdering controller = new NonAxaOrdering();
        try{
            controller.queryRecords();
            controller.order();
            controller.back();
            Test.stopTest();
        }
        catch(exception e){
            
        }
    }

    
    static testmethod void coverageWrapper(){
        System.runAs(userAdmin){
            Test.startTest();
            Account bsxx = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bsxx.CarBrandExcluded__c = 'AUDI';
            bsxx.Type = 'Expert';
            insert bsxx;
    
            Assessment__c assxx = TestFactory.createAssessment('ASSESS_TEST-00012', bsxx);
            //ass2.ParentAssessment__c = ass1.Id;
            assxx.Entity__c = '299';
            assxx.EntityRules__c = '299';
            assxx.EntityCode__c = '299';
            assxx.VINNumber__c = '444';
            assxx.PlateNumber2__c = '123';
            assxx.Manufacturer__c = 'TOYOTA';
            assxx.BuildDate__c = date.today();
            assxx.TECH_EntityCountryCode__c = 'FR';
            assxx.VINCheck__c = 2;
            assxx.ModelV2__c = 'PRIUS T4';
            assxx.Status__c = 'NEW';
            assxx.AssessmentNumber__c = 'Num001-12';
            assxx.OrderStatus__c = 'PREACCEPTANCE';
            assxx.AssessmentID__c = 'Num001-12';
            assxx.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            insert assxx;
    
            PrerequisiteOrder__c soxx = TestFactory.createSalesOrder(assxx, bsxx, 'PREACCEPTANCE');
            soxx.BodyShopOrderNumber__c = '1274';
            soxx.Status__c = 'PREACCEPTANCE';
            insert soxx;
    
    
            list<OrderLine__c> listBundleOrderLines = new list<OrderLine__c>();
            OrderLine__c olxx = TestFactory.createOrderLineFinal(10,listpurchaseOrders[0], 'INPROCESS');
            olxx.OriginalItem__c = listOrderLines[0].Id;
            olxx.OrderType__c = 'BUNDLEITEM';
            olxx.Description__c = 'desc1';
            olxx.PartNumber__c = '123456';
            olxx.Suppliable__c = 'YES';
            olxx.SASStatus__c = 'CONFIRMED';
            insert olxx;
    
            Offer__c offxx = TestFactory.createOfferLine(olxx, soxx, 'INPROCESS');
            offxx.Type__c = 'QUICK';
            offxx.PreselectedForOrder__c = true;
            offxx.Accepted__c = 'YES';
            insert offxx;       
    
            
            Offer__c offChild = TestFactory.createOfferLine(olxx, listSalesOrders[0], 'INPROCESS');
            offChild.Type__c = 'QUICK';
            offChild.PreselectedForOrder__c = true;
            offChild.Accepted__c = 'YES';
            offChild.ParentOffer__c = offxx.Id;
            insert offChild;
     
            Map<String, String> mapPartTypeDelayMatrix = new Map<String, String>();
            system.debug('@@ start here');
            NonAxaOrdering.OfferWrapper currentOfferWrapper = new NonAxaOrdering.OfferWrapper(offxx, mapPartTypeDelayMatrix  );
            currentOfferWrapper.parentOffer =  offxx;
            Test.stopTest();
        }
        
    }


   
    static testmethod void TestIsPriceZero(){
        System.runAs(userAdmin){
            Test.startTest();
            NonAxaOrdering.BundleItemWrapper currentBundleItemWrapper = new NonAxaOrdering.BundleItemWrapper(listOffers[0]);
            Boolean isPriceZero = currentBundleItemWrapper.isPriceZero;
            Test.stopTest();
        }
    }

    
    static testmethod void TestSetAlreadyOrdered(){
        System.runAs(userAdmin){
            Test.startTest();
            nonAxaOrdering.PartWrapper currentPartWrapper = new nonAxaOrdering.PartWrapper(listOffers[0]);
            currentPartWrapper.SetAlreadyOrdered();
            Test.stopTest();
        }
    }



    //1
    static testmethod void testDistributorCallOutSuccess(){
        system.debug('## Start testDistributorCallOutSuccess');
        
        string jsonResponse = '{"ClaimReference":"test","Request":"Draft","Success":"true","Distributors":{"Distributor_ScTest1":{"ExternalOrderReference":"","Lines":[{"ID":"xxx","Quantity":1,"PartNumber":"76TYGD90pHhOB8","Type":"A","Manufacturer":"TOYOTAI","Description":"test one)","CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"yyy","Quantity":0,"PartNumber":"76TYGD90ZKYs6d","Type":"A","Manufacturer":"TOYOTA","CatalogPrice":320.6,"AlphaScaleDiscount":24,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":24,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_ScTest1FJ87m5","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"444","PlateNumber":"123","Model":"PRIUS T4","FirstRegistrationDate":"","Brand":"TOYOTA"}}';

        system.runas(userAdmin){
            //update distributor connected checkbox
            accounts[0].DistributorConnected__c = true;

            update accounts[0];

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK',jsonResponse)); 
                string result = NonAxaOrdering.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
               // system.assertEquals(true,result.contains('test'));
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
                string result = NonAxaOrdering.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
               // system.assertEquals(true,result.contains('Message'));
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
                string result = NonAxaOrdering.updateStockInfo(EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
               // system.assertEquals(false,string.isBlank(result));    
            Test.stopTest();
        }//end system.runAs

        system.debug('## End testDistributorCallOutFailure');
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
            NonAxaOrdering.OfferWrapper currentOfferWrapper = new NonAxaOrdering.OfferWrapper(off1, mapPartTypeDelayMatrix  );

            currentOfferWrapper.parentOffer = null;
            currentOfferWrapper.setParentOffer(new Offer__c(), mapPartTypeDelayMatrix);
            Test.stopTest();
        }
    }

    static testmethod void testnonAxaOrderingCatchException(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.NONPartenaireOrdering);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf('2555')));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf('2555')));

            Test.startTest();
            NonAxaOrdering controller = new NonAxaOrdering();
                controller.back();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }

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
            
            Test.setCurrentPage(Page.NONPartenaireOrdering);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));
            boolean firstElement =true;
            Test.startTest();

                NonAxaOrdering controller = new NonAxaOrdering();
                
                controller.queryRecords();
                system.debug('##currentPartWrapper '+controller.mapPartWrapper);
                for(NonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(NonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(NonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                            currentOfferWrapper.addChildOffer(listBundleOffers[0]);
                            currentOfferWrapper.parentOffer=listBundleOffers[2];
                        }
                    }
                }
                controller.order();
            Test.stopTest();
        }
    }




    @isTest
    public static void testBodyshopNOTExpert(){
        System.runAs(userAdmin){
            Test.startTest();
                nonAxaBs.Type = 'Standard';
                update nonAxaBs;
            Test.stopTest();
        }

        String type = [select Type from Account WHERE Id=: nonAxaBS.Id]?.Type;
        System.assertEquals(type, 'Standard');
    }

    static testmethod void testRedirectPage(){
        system.runas(userAdmin){
            Test.startTest();
                NonAxaOrdering controller = new NonAxaOrdering();
                controller.redirectPage();
                
                System.assertEquals(new PageReference('/apex/search').getUrl(), controller.redirectPage().getUrl());
            Test.stopTest();
        }
    }

    @isTest
    public static void testParentAccount(){
        System.runAs(userAdmin){
            Test.startTest();
                nonAxaBS.ParentId = accounts[0].Id;
                update nonAxaBS;
            Test.stopTest();
        }
        String parentId = [select ParentId from Account WHERE Id=: nonAxaBS.Id]?.ParentId;
        System.assertEquals(parentId, accounts[0].Id);
    }

    static testmethod void testOrderCallout(){
        system.debug('## Start testOrderCallout');
        
        system.runas(userAdmin){
            Test.setCurrentPage(Page.NONPartenaireOrdering);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            //update ol status to be able to launch callout
            listOrderLines[0].SASStatus__c = 'CONFIRMED';
            listOrderLines[1].SASStatus__c = 'CONFIRMED';
            update listOrderLines;

            Test.startTest();
            nonAxaOrdering controller = new nonAxaOrdering();
                controller.queryRecords();
                for(nonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(nonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(nonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                        }
                    }
                }
                controller.order();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }

        system.debug('## End testOrderCallout');
    }

    static testmethod void testencryptBase64(){
        system.debug('## Start encryptBase64');
        
        system.runas(userAdmin){
            Test.startTest();
                NonAxaOrdering.encryptBase64('test');
            Test.stopTest();
        }//end system.runAs

        system.debug('## End encryptBase64');
    }

    @isTest
    public static void testtoggleIsAcceptedForCheapest(){
        System.runAs(userAdmin){
            Test.startTest();
            NonAxaOrdering controller = new NonAxaOrdering();
            controller.toggleIsAcceptedForCheapest();
            Test.stopTest();
        }
    }

    static testmethod void testOrderError(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.NONPartenaireOrdering);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            //update ol status to be able to launch callout
            listOrderLines[0].SASStatus__c = 'CONFIRMED';
            listSalesOrders[0].Status__c = 'RESPONDED';
            listOrderLines[1].SASStatus__c = 'CONFIRMEDWITHDELAY';
            listSalesOrders[1].Status__c = 'INACCEPTANCE';

            listpurchaseOrders[0].AgencyMode__c = true;
            listpurchaseOrders[0].wsDate__c = System.today();
            listpurchaseOrders[0].wsErrorMessage__c = null;
            update listOrderLines;
            update listpurchaseOrders;

            Test.startTest();
            nonAxaOrdering controller = new nonAxaOrdering();
                controller.queryRecords();
                for(nonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(nonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(nonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                        }
                    }
                }
                controller.order();
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }

    static testmethod void testOrderOTHER(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.NONPartenaireOrdering);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('SourceAssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessments[0].Id)));
            ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(Blob.valueOf(childAssessments[0].Id)));

            //update ol status to be able to launch callout
            listOrderLines[0].SASStatus__c = 'CONFIRMED';
            listSalesOrders[0].Status__c = 'RESPONDED';
            listOrderLines[1].SASStatus__c = 'OTHER';
            listSalesOrders[1].Status__c = 'INACCEPTANCE';

            listpurchaseOrders[0].AgencyMode__c = true;
            listpurchaseOrders[0].wsDate__c = System.today();
            listpurchaseOrders[0].wsErrorMessage__c = null;
            update listOrderLines;
            update listpurchaseOrders;

            Test.startTest();
            nonAxaOrdering controller = new nonAxaOrdering();
                controller.queryRecords();
                for(nonAxaOrdering.PartWrapper currentPartWrapper : controller.mapPartWrapper.values()){
                    for(nonAxaOrdering.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values()){
                        for(nonAxaOrdering.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values()){
                            currentOfferWrapper.isAccepted = true;
                        }
                    }
                }
                controller.order();

                childAssessments[0].ParentAssessment__c = null;
                update childAssessments;
                
            Test.stopTest();

            Assessment__c assessment = [select OrderStatus__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001-1'];

            System.assertEquals('PREACCEPTANCE', assessment.OrderStatus__c);
        }
    }
    
}