/*************************************************************************************
Class Name - RESTSalesOrdersOffersUpdate_V1_Test
Version - 1.0
Created Date - 23 JUNE 2015
Function - Test class for the web service RESTSalesOrdersOffersUpdate_V1

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Brayan        23/06/2015  Original Version 
* Shamina M     20/01/2016  code review/updates to increase coverage 
* Ashwina S     15/03/2015  C-001428: Gestion des pièces "à retourner" depuis ICE-
* Dourga U      04/10/2016  increase coverage
* Ashwina S     06/12/2016  C-001829: updateSalesOrdersOffers -> migrate values
*************************************************************************************/
@isTest
private class RESTSalesOrdersOffersUpdate_V1_TEST {
    static BusinessHours defaultHours;
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Offer__c> l_Offers;
    static list <Group> groups;
    static list<QueuesObject> queues;
    static list<CountryQueueMapping__c> cs_CountryQueues;
    static list<CaseDetailsProcessMapping__c> cs_CaseDetails;
    static list<Offer__c> selectedOffersList;
    static list<Prerequisiteorder__c> selectedPrerequisiteOrdersList;
    static CountryCodeInformationsMapping__c countryCode; 

    static { 
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Offers = new list<Offer__c>();
        groups = new list <Group>();
        queues = new list<QueuesObject> ();
        cs_CountryQueues = new list<CountryQueueMapping__c> ();
        cs_CaseDetails = new list<CaseDetailsProcessMapping__c>();
        selectedOffersList = new list<Offer__c>();
        selectedPrerequisiteOrdersList = new list<Prerequisiteorder__c>();

        User user1 = TestFactory.createUser('ScUserTest');
        user1.BypassValidationRules__c= true;
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ContactUser__c = l_users[0].Id;
            //bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            Account bs4 = TestFactory.createAccountBodyshop('BodyShop_ScTest3', 'FR');
            l_Accounts.add(bs4);
            insert l_Accounts;
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            ass2.TECH_EntityCountryCode__c = 'FR';
            l_Assessments.add(ass2);

            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);         
            Assessment__c ass4= TestFactory.createAssessment('ASSESS_TEST-0004', bs4);
            l_Assessments.add(ass4);     
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'INDELIVERY');
            l_SalesOrders.add(so2);
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so3);   
            PrerequisiteOrder__c so4= TestFactory.createSalesOrder(ass4, bs4, 'INDELIVERY');
            l_SalesOrders.add(so4);    
            PrerequisiteOrder__c so5= TestFactory.createSalesOrder(ass4, bs4, 'CANCELED');
            l_SalesOrders.add(so5);         
            insert l_SalesOrders;

            selectedPrerequisiteOrdersList = [Select Id,Name from PrerequisiteOrder__c where Id in:l_SalesOrders];

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_1);
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_2);
            PurchaseOrder__c po2_1 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po2_1);
            PurchaseOrder__c po2_2 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po2_2);
            PurchaseOrder__c po3 = TestFactory.createPurchaseOrder(ass2, so3, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po3);          
            insert l_purchaseOrders;

            l_OrderLines = new List<OrderLine__c>{
                new OrderLine__c(Type__c = 'A',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Original 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BodyShopDiscount__c = 10,
                                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = '',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'NO',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'A',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = '',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'NO',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = 'Final 1',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'YES',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'A',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = '',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'NO',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
                ,new OrderLine__c(Type__c = 'B',
                                OrderType__c = 'FINAL',
                                OriginalItem__c = null,
                                PartNumber__c = 'Part1234',
                                ExpectedDeliveryDuration__c = '1',
                                Description__c = '',
                                PartFamily__c = 'Family1234',
                                Manufacturer__c = 'Manufacturer1',
                                CataloguePrice__c = 1000,
                                Quantity__c = 10,
                                AXADiscount__c = 10,
                                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
                                BodyShopDiscount__c = 10,
                                Suppliable__c = 'NO',
                                PurchaseOrder__c = l_purchaseOrders[0].Id,
                                AcceptedCheck__c=true)
            };
            insert l_OrderLines;

            l_Offers =  new list<Offer__c>{
                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[0].Id,
                        Prerequisiteorder__c = l_SalesOrders[0].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY,
                        OfferReference__c = '1234',
                        Comment__c = 'No Comments'),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[1].Id,
                        Prerequisiteorder__c = l_SalesOrders[0].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[2].Id,
                        Prerequisiteorder__c = l_SalesOrders[0].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[3].Id,
                        Prerequisiteorder__c = l_SalesOrders[0].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY,
                        Comment__c = 'No Comments'),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[4].Id,
                        Prerequisiteorder__c = l_SalesOrders[1].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[5].Id,
                        Prerequisiteorder__c = l_SalesOrders[1].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

                new Offer__c(Type__c = 'QUICK',
                        OrderLine__c = l_OrderLines[6].Id,
                        Prerequisiteorder__c = l_SalesOrders[1].Id,
                        Accepted__c = 'YES',
                        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY)
            };
            insert l_Offers;

            l_Offers[3].ParentOffer__c = l_Offers[0].Id;
            l_Offers[4].ParentOffer__c = l_Offers[0].Id;
            update l_Offers;
            
            selectedOffersList = [Select Id,Name from Offer__c where Id in:l_Offers];

            cs_CaseDetails = TestFactory.createCaseDetailsProcessMapping();
            insert cs_CaseDetails;
        }
    }
    
    
     @isTest static void Test_UpdateOffer() {
        system.runas(l_users[0]){
            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[0].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"PREORDERCONFIRMED","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            test.stopTest();

            list<Offer__c> updatedOfferList = [Select id, DeliveryStatus__c from Offer__c where PrerequisiteOrder__c =:l_SalesOrders[0].Id];
            system.assertEquals(updatedOfferList[0].DeliveryStatus__c, 'DELIVERED');
        }
    }
    
        
    @isTest static void Test_UpdateOfferCancelled() {
        system.debug(' ## START Test_UpdateOfferCancelled');
        system.runas(l_users[0]){
            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[4].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"INACCEPTANCE","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":false,"AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21","Comment":"cmt1"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"RADIATOR SHROUD","OriginalPartNumber":"16711 37040","OriginalPartManufacturer":null,"Quantity":2,"CatalogPrice":92,"CatalogTotalPrice":184,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":82.8,"BodyShopTotalPrice":165.6,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"R/ELECTRIC FAN","OriginalPartNumber":"16361 28360","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":114,"CatalogTotalPrice":114,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":5,"BodyShopPrice":86.64,"BodyShopTotalPrice":86.64,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            system.assertEquals(true, Json.toString().contains('This sales order cannot be updated as its status is CANCELED'));  
            test.stopTest(); 
            system.debug(' ## END Test_UpdateOfferCancelled');
        }
    }    


    @isTest static void Test_UpdateOfferWithErrors() {
        system.debug(' ## START Test_UpdateOfferWithErrors');
        system.runas(l_users[0]){
            selectedPrerequisiteOrdersList[0].Status__c = 'INACCEPTANCE';
            selectedPrerequisiteOrdersList[1].Status__c = 'INACCEPTANCE';
            update selectedPrerequisiteOrdersList;

            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"test","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"PREORDERCONFIRMED","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"selectedOffersList[0].Name","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"selectedOffersList[1].Name","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"selectedOffersList[2].Name","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"RADIATOR SHROUD","OriginalPartNumber":"16711 37040","OriginalPartManufacturer":null,"Quantity":2,"CatalogPrice":92,"CatalogTotalPrice":184,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":82.8,"BodyShopTotalPrice":165.6,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"selectedOffersList[3].Name","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"R/ELECTRIC FAN","OriginalPartNumber":"16361 28360","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":114,"CatalogTotalPrice":114,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":5,"BodyShopPrice":86.64,"BodyShopTotalPrice":86.64,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            system.assertEquals(true, Json.toString().contains('Warning":"No update was done in this operation.'));  
            test.stopTest(); 
            system.debug(' ## END Test_UpdateOfferWithErrors');
        }
    }

    @isTest static void Test_UpdateOfferAsync() {
        system.debug(' ## START Test_UpdateOfferAsync');
        system.runAs(l_users[0]){  
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
              
            test.starttest();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[0].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"PREORDERCONFIRMED","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"RADIATOR SHROUD","OriginalPartNumber":"16711 37040","OriginalPartManufacturer":null,"Quantity":2,"CatalogPrice":92,"CatalogTotalPrice":184,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":82.8,"BodyShopTotalPrice":165.6,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"R/ELECTRIC FAN","OriginalPartNumber":"16361 28360","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":114,"CatalogTotalPrice":114,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":5,"BodyShopPrice":86.64,"BodyShopTotalPrice":86.64,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            system.assertEquals(true, Json != null); 
            test.stopTest();
        }
        system.debug(' ## END Test_UpdateOfferAsync');
    }

    @isTest static void Test_UpdateOfferIndelivery() {
        system.debug(' ## START Test_UpdateOfferIndelivery');
        system.runAs(l_users[0]){  
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
              
            test.starttest();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[1].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"PREORDERCONFIRMED","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[4].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[5].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[6].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"RADIATOR SHROUD","OriginalPartNumber":"16711 37040","OriginalPartManufacturer":null,"Quantity":2,"CatalogPrice":92,"CatalogTotalPrice":184,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":82.8,"BodyShopTotalPrice":165.6,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            
            system.assertEquals(true, Json != null); 
            test.stopTest();     
            list<Offer__c> updatedOfferList = [Select id, DeliveryStatus__c from Offer__c where PrerequisiteOrder__c =:l_SalesOrders[1].Id];
            // system.assertEquals(updatedOfferList[0].DeliveryStatus__c, 'DELIVERED');
        }
        system.debug(' ## END Test_UpdateOfferIndelivery');
    }

    static testMethod void Test_CatchException() {
        system.debug(' ## START Test_CatchException');
        system.runAs(l_users[0]){  
            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            //Shamina M: 20160120 - dummy json string to test for catch exception section
            String jsonStr;
            for(integer i=0; i<3000; i++){
                jsonStr += '******INVALID_JSON';
            } 
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            jsonStr = Json.toString();
            //system.debug('>>> Json<<< : '+  jsonStr);
            system.assertEquals(true, jsonStr.contains('Exceptions')); 
            test.stopTest();
        }
      system.debug(' ## END Test_CatchException');
    }

    
    @isTest static void Test_UpdateOfferSync() {
        system.debug(' ## START Test_UpdateOfferSync');
        system.runas(l_users[0]){
            selectedPrerequisiteOrdersList[0].Status__c = 'INACCEPTANCE';
            selectedPrerequisiteOrdersList[1].Status__c = 'INACCEPTANCE';
            update selectedPrerequisiteOrdersList;

            test.startTest();
                Restrequest req = new Restrequest();
                Restresponse res = new Restresponse();
                //Shamina M: 20160120 - AcceptedByBS is set to false for all, to increase coverage
                String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[0].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"PREORDERCONFIRMED","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":false,"AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/updateSalesOrdersOffers/';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
                Blob Json = RestContext.response.responseBody;
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));  
            test.stopTest(); 
            list<Offer__c> updatedOfferList = [Select id, Name, Accepted__c from Offer__c where PrerequisiteOrder__c =:l_SalesOrders[0].Id];
            system.assertEquals(updatedOfferList[0].Accepted__c, 'NO');
            system.assertEquals(updatedOfferList[1].Accepted__c, 'NO');
            system.debug(' ## END Test_UpdateOfferSync');
        }
    
    }

    // //ASE:15/03/2015 :C-001428


    @isTest static void Test_UpdateOfferReturned() {
        system.debug(' ## START Test_UpdateOfferReturned');
        system.runas(l_users[0]){
            // access Business Hours 
            selectedPrerequisiteOrdersList[0].Status__c = 'INDELIVERY';
            update selectedPrerequisiteOrdersList[0];

            defaultHours = [select Id from BusinessHours where IsDefault=true];
            countryCode = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);
            countryCode.PartReturnedProcessing__c = true;
            insert countryCode;     

            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[1].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"INDELIVERY","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[4].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"RETURNED","BodyShopDeliveryDate":"2015-07-21","Comment":"Comment1"},{"OfferItemName":"'+selectedOffersList[5].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"RETURNED","BodyShopDeliveryDate":"2015-07-21","Comment":"Comment1"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;

            system.assertNotEquals(0,[select Id from Case__c where TECH_AutomaticCreationFromProcess__c = '-SO-OfferReturned'].size());
            test.stopTest();
        }
        system.debug(' ## END Test_UpdateOfferReturned');
    }

    @isTest static void Test_UpdateOfferError() {
        system.debug(' ## START Test_UpdateOfferError');

        system.runas(l_users[0]){
            selectedPrerequisiteOrdersList[0].Status__c = 'INDELIVERY';
            update selectedPrerequisiteOrdersList[0];

            test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '{"SalesOrders":[{"SalesOrderId":"'+selectedPrerequisiteOrdersList[0].Name+'","BodyShopId":"BS1Vis","AssessmentReference":"TEST JSA 003ID01","Entity":"AXA Direct","MissionNumber":"0000012","PlateNumber":"245CZE","Status":"INDELIVERY","Offers":[{"offerType":"QUICK","isSelected":true,"MaximumValidityDate":"2015-07-21","Orders":[{"OfferItemName":"'+selectedOffersList[0].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR 2","OriginalPartNumber":"G9010 47030","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":false,"AcceptedByBS":false,"BodyShopDeliveryStatus":"MISSING","BodyShopDeliveryDate":"2015-07-21","Comment":"cmt1"},{"OfferItemName":"'+selectedOffersList[1].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"AUX WATER RADIATOR","OriginalPartNumber":"G9010 47031","OriginalPartManufacturer":null,"Quantity":1,"CatalogPrice":177,"CatalogTotalPrice":177,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":159.3,"BodyShopTotalPrice":159.3,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"DAMAGED","BodyShopDeliveryDate":"2015-07-21"},{"OfferItemName":"'+selectedOffersList[2].Name+'","VAT":0.2,"OriginalPartType":"A","OriginalPartDescription":"RADIATOR SHROUD","OriginalPartNumber":"16711 37040","OriginalPartManufacturer":null,"Quantity":2,"CatalogPrice":92,"CatalogTotalPrice":184,"EstimatedDeliveryDate":"2015-07-22","BodyShopDiscount":10,"BodyShopPrice":82.8,"BodyShopTotalPrice":165.6,"Suppliable":true,"AcceptedByBS":true,"BodyShopDeliveryStatus":"INCOMPATIBLE","BodyShopDeliveryDate":"2015-07-21"}]}]}],"OperationType":"Get","Success":true,"Warning":null,"ErrorMessage":null}';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/updateSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTSalesOrdersOffersUpdate_V1.updateSalesOrdersOffers();
            Blob Json = RestContext.response.responseBody;
            system.assertEquals(true, Json != null); 
            system.assertEquals(true, Json.toString().contains('TechnicalId'));  
            test.stopTest(); 
            system.debug(' ## END Test_UpdateOfferError');
            list<Offer__c> updatedOfferList = [Select id, Name, DeliveryStatusReason__c, DeliveryStatus__c from Offer__c where PrerequisiteOrder__c =:l_SalesOrders[0].Id];
            system.assertEquals(updatedOfferList[0].DeliveryStatus__c, 'ERROR');
            system.assertEquals(updatedOfferList[0].DeliveryStatusReason__c, 'MISSING');
            system.assertEquals(updatedOfferList[1].DeliveryStatusReason__c, 'DAMAGED');
            system.assertEquals(updatedOfferList[2].DeliveryStatusReason__c, 'INCOMPATIBLE');
        }
    }
}