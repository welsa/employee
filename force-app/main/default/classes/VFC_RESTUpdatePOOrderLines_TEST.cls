@isTest
private class VFC_RESTUpdatePOOrderLines_TEST
/*
----------------------------------------------------------------------
-- - Name          : VFC_RESTUpdatePOOrderLines_TEST
-- - Author        : AMI
-- - Description   : Test class for VFC_RESTUpdatePOOrderLines
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-NOV-2017  AMI   1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
{
    static User adminUser;
    static User adminUserDE;
    static List<Account> bodyshopList;
    static List<Account> distributorList;
    static List<Assessment__c> assessmentList;
    static List<CrossReference__c> crossReferenceList;
    static list<PartList__c> partLists;
    static List<PrerequisiteOrder__c> salesOrderList;
    static list <PurchaseOrder__c> purchaseOrderList;
    static Id newAssessmentRecordTypeId;
    static Id recordTypeIdMaterial;

    static{

        UserRole alphaUserRoleDE = new UserRole(Name = 'DE - AlphaScale');
        insert alphaUserRoleDE;


        adminUser = TestFactory.createUser('adminUser');

        adminUserDE = TestFactory.createUser('adminUserDE');
        adminUserDE.UserRoleId = alphaUserRoleDE.Id;

        insert adminUser;
        insert adminUserDE;


        System.runAs(adminUser){
            //initialise new assessment recordtypec (R3)
            newAssessmentRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            //initialise material recordtype
            recordTypeIdMaterial = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
            
            //creating bodyshop
            bodyshopList = new list <Account>{
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'DE')};

            bodyshopList[0].Name = 'BodyShop_1';
            bodyshopList[0].DistributorConnected__c = true;
            bodyshopList[1].DistributorConnected__c = true;
            
            insert bodyshopList;

            //creating distributor
            distributorList = new list <Account>{
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_2', 'DE')};

            distributorList[0].Name = 'Distributor_1';
            distributorList[0].Tech_Distributor__c = 'COLER';
            distributorList[0].Categories__c = 'A;B';

            distributorList[1].DistributorConnected__c = true;
            distributorList[1].Tech_Distributor__c = 'Distributor_1';
            distributorList[1].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');
            distributorList[1].Tech_Distributor__c = 'COLER';
            distributorList[1].Rebate__c = 5;

            distributorList[1].PartTypeRegionDelayMatrix__c = 'A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48';


     

            insert distributorList;

            //creating assessment
            assessmentList = new list <Assessment__c>{
                TestFactory.createAssessment('Assessment_1', bodyshopList[0]),
                TestFactory.createAssessment('Assessment_2', bodyshopList[1])
            };

            assessmentList[0].RecordTypeId = newAssessmentRecordTypeId;
            assessmentList[0].Manufacturer__c = 'VW';
            assessmentList[0].PlateNumber2__c = '23NVMR17';
            assessmentList[0].VinNumber__c = 'V23NVMR17';
            assessmentList[0].ModelV2__c = 'Passat';
            assessmentList[0].ClaimReference__c = 'ClaimRefAss1';

            assessmentList[1].RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();


            insert assessmentList[0];
        }

        System.runAs(adminUserDE){

            insert assessmentList[1];

        }

        System.runAs(adminUser){

            //creating crossref
            crossReferenceList = new list <CrossReference__c>{
                TestFactory.createCrossReference('fr','1234','VW',50.8,true)};

            crossReferenceList[0].IAMPartNumber__c ='3434hcv';
            crossReferenceList[0].IAMManufacturer__c ='Axa manufacturer';

            insert crossReferenceList;
                                                            
            //creating partlist
            partLists = new list <PartList__c>{
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1])
            };

            partLists[0].TECH_OriginalPart__c = 'Ass1Part1'; 
            partLists[0].ProducerName__c = 'VW';
            partLists[0].Quantity__c = 15;
            partLists[0].RecordtypeId = recordTypeIdMaterial;
            partLists[0].PartNumber__c = '76TYGD90anJWXs';

            partLists[1].TECH_OriginalPart__c = 'Ass1Part2';
            partLists[1].ProducerName__c = 'VW';
            partLists[1].Quantity__c = 15;
            partLists[1].RecordtypeId = recordTypeIdMaterial;
            partLists[1].PartNumber__c = '76TYGD9011dcJv';

            partLists[2].TECH_OriginalPart__c = 'Ass1Part3';
            partLists[2].ProducerName__c = 'VW';
            partLists[2].CrossReferenceId__c = crossReferenceList[0].Id;
            partLists[2].Quantity__c = 15;
            partLists[2].RecordtypeId = recordTypeIdMaterial;
            partLists[2].PartNumber__c = '1234';

            partLists[3].TECH_OriginalPart__c = 'Ass2Part1'; 
            partLists[3].ProducerName__c = 'VW';
            partLists[3].Quantity__c = 15;
            partLists[3].RecordtypeId = recordTypeIdMaterial;
            partLists[3].PartNumber__c = '76TYGD90anJWXsx';

            partLists[4].TECH_OriginalPart__c = 'Ass2Part2';
            partLists[4].ProducerName__c = 'VW';
            partLists[4].Quantity__c = 15;
            partLists[4].RecordtypeId = recordTypeIdMaterial;
            partLists[4].PartNumber__c = '76TYGD9011dcJvx';

            partLists[5].TECH_OriginalPart__c = 'Ass2Part3';
            partLists[5].ProducerName__c = 'VW';
            partLists[5].CrossReferenceId__c = crossReferenceList[0].Id;
            partLists[5].Quantity__c = 15;
            partLists[5].RecordtypeId = recordTypeIdMaterial;
            partLists[5].PartNumber__c = '1234x';

            insert partLists; 

            //creating SO
            salesOrderList = new list <PrerequisiteOrder__c>{
                TestFactory.createSalesOrder(assessmentList[0], bodyshopList[0], ''),
                TestFactory.createSalesOrder(assessmentList[1], bodyshopList[1], '')
            };
            
            salesOrderList[0].BodyShopOrderNumber__c = '1234';
            salesOrderList[0].Status__c = 'PREACCEPTANCE';

            salesOrderList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE;


            insert salesOrderList; 
         
            //creating PO
            purchaseOrderList = new list <PurchaseOrder__c>{
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], bodyshopList[0], distributorList[0], ''),
                TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], bodyshopList[1], distributorList[1], '')
            
            };

            purchaseOrderList[0].Status__c = 'DRAFTQUOTE';
            purchaseOrderList[0].Tech_ExternalId__c = String.valueOf(assessmentList[0].id)+ String.valueOf(distributorList[0].Id);
            System.debug('###purchaseOrderList[0].Tech_ExternalId__c###' + purchaseOrderList[0].Tech_ExternalId__c);

            purchaseOrderList[1].Status__c = 'DRAFTQUOTE';
            purchaseOrderList[1].Tech_ExternalId__c = String.valueOf(assessmentList[1].id)+ String.valueOf(distributorList[1].Id);
            insert purchaseOrderList;     
        }//end system.runAs
    }//end static

    static testMethod void constructorTest(){
        system.debug('## Start constructorTest');

        system.runAs(adminUser){
            Test.startTest();
                ApexPages.StandardController sc = new ApexPages.standardController(purchaseOrderList[0]);
                VFC_RESTUpdatePOOrderLines extention = new VFC_RESTUpdatePOOrderLines(sc);
            Test.stopTest();
        }

        system.debug('## End constructorTest');
    }

    static testMethod void launchDistributorCallOutSuccessTest(){
        system.debug('## Start launchDistributorCallOutSuccessTest');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected'); 

            update distributorList[0];

            //update connected boolean on body shop
            bodyshopList[0].DistributorConnected__c = true; 

            update bodyshopList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('## End launchDistributorCallOutSuccessTest');
    }

    static testMethod void launchDistributorCallOutFailTestV0(){
        system.debug('## Start launchDistributorCallOutFailTestV0');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(400,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"false","Distributors":{},"Vehicle":{},"Message":"Service could not be found"}')); 
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('## End launchDistributorCallOutFailTestV0');
    }

    static testMethod void launchDistributorCallOutFailTestV1(){
        system.debug('## Start launchDistributorCallOutFailTestV1');

        system.runAs(adminUser){
            Test.startTest();
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('## End launchDistributorCallOutFailTestV1');
    }
    
    @isTest
    static  void launchDistributorCallOutSuccessTest_IG(){
        system.debug(' ~~~~ Start launchDistributorCallOutSuccessTestIG');
        
        system.runAs(adminUser){
            
             assessmentList[0].InsuranceBroker__c = 'IG';
            update assessmentList[0];
            
            
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update connected boolean on body shop
            bodyshopList[0].DistributorConnected__c = true; 

            update bodyshopList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('~~~~End launchDistributorCallOutSuccessTestIG');
    }

    @isTest
    static  void launchDistributorCallOutSuccessTestXYZ(){
        system.debug(' ~~~~ Start launchDistributorCallOutxyz');
        
        system.runAs(adminUser){
            
            
            //update connected boolean on distruibutor
            distributorList[0].DistributorConnected__c = false;  

            update distributorList[0];

            //update connected boolean on body shop
            bodyshopList[0].DistributorConnected__c = true; 

            update bodyshopList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('~~~~End launchDistributorCallOutxyz');
    }

    
     @isTest
    static  void launchDistributorCallOutSuccessTestFalse(){
        system.debug(' ~~~~ Start launchDistributorCallOutFalse');
        
        system.runAs(adminUser){
            
             
            
            
            //update connected boolean on distruibutor
            distributorList[0].DistributorConnected__c = false;  

            update distributorList[0];

            //update connected boolean on body shop
            bodyshopList[0].DistributorConnected__c = false; 

            update bodyshopList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('~~~~End launchDistributorCallOutFalse');
    }
    static testMethod void launchDisTest(){
        system.debug('## Start launchDisTest');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update connected boolean on body shop
            bodyshopList[0].DistributorConnected__c = true; 
            bodyshopList[0].ShippingCountryCode = 'DE';
            bodyshopList[0].ShippingCountry = 'Germany';
            bodyshopList[0].ShippingCity = 'Nürnberg';
            bodyshopList[0].ShippingStreet = 'Hans Bunte Straße 47';
            bodyshopList[0].ShippingPostalCode = '90431';
            update bodyshopList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;
            purchaseOrderList[0].Status__c = 'DRAFTQUOTE';
            update purchaseOrderList;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"","Request":"DRAFT","Distributors":{"COLER":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":65.87,"AlphaScaleDiscount":10.0,"BodyShopDiscount":10.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"'+ partLists[1].Id  +'","Quantity":1,"PartNumber":"6438E4","Type":"A","Manufacturer":"Peugeot","Description":"Satz Kappe","CatalogPrice":106.54,"AlphaScaleDiscount":10.0,"BodyShopDiscount":10.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"'+ partLists[2].Id  +'","Quantity":1,"PartNumber":"6999G9","Type":"A","Manufacturer":"Peugeot","Description":"Bef Schild Vo","CatalogPrice":17.28,"AlphaScaleDiscount":10.0,"BodyShopDiscount":10.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"'+ partLists[3].Id  +'","Quantity":1,"PartNumber":"6204S9","Type":"A","Manufacturer":"Peugeot","Description":"Scheinwerfer","CatalogPrice":253.94,"AlphaScaleDiscount":10.0,"BodyShopDiscount":10.0,"Status":"CONFIRMEDWITHDELAY","Bundle":true,"DeliveryDays":"2"}],"Success":"true","AgencyMode":"false"}},"BodyShop":{"VATNumber":"DE253475183","Name":"Car Top Zentrum Stuttgart","ExternalReference":"DE22628"},"Vehicle":{"VinNumber":"VF32D9HZA44782784","PlateNumber":"OGSW7404","Model":"206 CC (2D) Cabrio ab 09/00-04/07 [11]","FirstRegistrationDate":"2005-08-01","Brand":"Peugeot"}}')); 
                // String rs = VFC_RESTUpdatePOOrderLines.launchDis(purchaseOrderList[0].Id);
            Test.stopTest();
        }

        system.debug('## End launchDisTest');
    }

    @isTest
    static  void launchDistributorCallOutIGSubs(){
        system.debug(' ~~~~ Start launchDistributorCallOutSuccessTestIG');
        
        system.runAs(adminUser){
            
             assessmentList[1].InsuranceBroker__c = 'IG';
            update assessmentList[1];
            
            
            //update connected boolean on distruibutor
            // distributorList[0].DistributorConnected__c = true;  

            // update distributorList[0];

            //update connected boolean on body shop
            // bodyshopList[0].DistributorConnected__c = true; 

            // update bodyshopList[0];

            //update part type
            partLists[3].Type__c = 'A';
            partLists[4].Type__c = 'A';
            partLists[4].TechCheckForSubstitute__c = true;
            partLists[5].Type__c = 'B';
            partLists[5].OriginalPart__c = partLists[4].Id;

            update partLists;

            


            List<orderline__c> lstOL = new list<orderline__c>();
            for (orderline__c ol: [select id,AcceptedCheck__c from orderline__c
                                    Where PurchaseOrder__c =: purchaseOrderList[1].Id ]){
                
                ol.AcceptedCheck__c = true;
                ol.Suppliable__c = 'YES';
                ol.OrderType__c = 'Final';
                ol.ExpectedDeliveryDuration__c  = '2';
                lstOL.add(ol);
            }
            List<Offer__c> lstOffers = new list<Offer__c>{
                TestFactory.createOfferLine(lstOL[0], salesOrderList[0],'INDELIVERY')
            };
            lstOffers[0].Accepted__c = lstOL[0].Suppliable__c;
            insert lstOffers;

            OrderLine__c olrep = TestFactory.createOrderLineFinalWithPartList(13, purchaseOrderList[1],partLists[3] ,'IN PROCESS');
            olrep.TechOLType__c = 'replacement';
            olrep.OriginalItem__c = lstOL[1].Id;
            olrep.AcceptedCheck__c = true;
            olrep.Suppliable__c = 'YES';
            insert olrep;

            lstOL[1].OrderType__c = 'Original';
            update lstOL;

            

            Test.startTest();
                system.debug(' ~~~~ Start launchDistributorCallOutSuccessTestIG 2');

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"COLER":{"ExternalOrderReference":"","Success":"true","Lines":[{"ID":"'+ partLists[3].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"NOTFOUND","StatusMessage":"","Bundle":false},{"ID":"' + partLists[4].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[5].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"PARTIAL","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[5].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false}]}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
                ASPISCreatePOOrderLines.orRequest = 'OrderPO';
                VFC_RESTUpdatePOOrderLines.launchDistributorCallOut(purchaseOrderList[1].Id);
            Test.stopTest();
        }

        system.debug('~~~~End launchDistributorCallOutSuccessTestIG');
    }


    
}