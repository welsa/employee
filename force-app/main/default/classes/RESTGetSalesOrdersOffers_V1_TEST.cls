/*************************************************************************************
Class Name - RESTGetSalesOrdersOffers_V1_Test
Version - 1.0
Created Date - 18 MAY 2015
Function - Test class for the web service get offers

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Brayan        18/05/2015  Original Version 
* Shamina M     20/01/2016  added new test methods to increase coverage/ Case 1480
* Dourga U      03/10/2016  increase coverage
*************************************************************************************/
@isTest
private class RESTGetSalesOrdersOffers_V1_TEST {

    /*static list<user> users;
    static list<Offer__c> offersList;
    static list<OrderLine__c> orderLinesList;
    static list<Prerequisiteorder__c> prerequisiteOrdersList;
    static list<Account> accounts;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static list<Assessment__c> assessments;
    static map <String,Id> proRecordTypeMap = new map <String,Id>();
    //static map<Assessment__c, Assessment__c> mapAss ;*/

    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Offer__c> l_Offers;

    
    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Offers = new list<Offer__c>();
        
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            bs1.ContactUser__c = l_users[0].Id;
            //bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            ass1.Entity__c = null;
            ass1.MissionNumber__c = null;
            ass1.MinimumValidityDate__c = System.today();
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            ass2.AssessmentID__c = '0913';
            ass2.PlateNumber2__c = '237857';
            ass2.Status__c = null;
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            ass2.AssessmentID__c = '0914';
            l_Assessments.add(ass3);            
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
            so2.RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            l_SalesOrders.add(so2);
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so3);            
            insert l_SalesOrders;

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

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVEREDCONFIRMED');
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVEREDCONFIRMED');
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVEREDCONFIRMED');
            ol3.CataloguePrice__c = null;
            ol3.AssessmentPrice__c = null;
            ol3.Quantity__c = 1;
            ol3.OrderType__c = 'FINAL';
            ol3.AXADiscount__c = null;
            ol3.BodyShopDiscount__c = null;
            //ol3.AdditionnalDiscount__c = null;
            ol3.VAT__c = null;
            ol3.AcceptedCheck__c = TRUE;
            ol3.DeliveryStatus__c = null;
            ol3.Type__c = null;
            ol3.Description__c = 'description1234';
            ol3.PartNUmber__c = '2575272';
            ol3.Manufacturer__c = 'TOYOTA';
            l_OrderLines.add(ol3);
            insert l_OrderLines;

            ol1.OriginalItem__c = ol2.Id;
            update ol1;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off1.Type__c = 'QUICK';
            //off1.RealDeliveryDate__c = system.today();
            off1.ExpectedDeliveryDate__c = system.today();
            off1.Comment__c = 'comment';
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off2.Type__c = 'QUICK';
            l_Offers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, so1, 'DELIVERED');
            off3.Type__c = 'QUICK';
            //off3.RealDeliveryDate__c = system.today();
            off3.ExpectedDeliveryDate__c = system.today();
            off3.Comment__c = 'comment';
            l_Offers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off4.Type__c = 'BASIC';
            off4.RealDeliveryDate__c = system.today();
            off4.ExpectedDeliveryDate__c = system.today();
            off4.Comment__c = 'comment';
            l_Offers.add(off4);
            Offer__c off5 = TestFactory.createOfferLine(ol3, so1, 'DELIVERED');
            off5.Type__c = 'OPPORTUNITY';
            off5.RealDeliveryDate__c = system.today();
            off5.ExpectedDeliveryDate__c = system.today();
            off5.Comment__c = 'comment';
            l_Offers.add(off5);
            Offer__c off6 = TestFactory.createOfferLine(ol3, so1, 'DELIVERED');
            off6.Type__c = 'OPPORTUNITY';
            l_Offers.add(off6);
            Offer__c off7 = TestFactory.createOfferLine(ol1, so2, 'DELIVERED');
            off7.Type__c = 'BASIC';
            off7.RealDeliveryDate__c = system.today();
            off7.ExpectedDeliveryDate__c = system.today();
            l_Offers.add(off7);
            Offer__c off8 = TestFactory.createOfferLine(ol1, so2, null);
            off8.Type__c = 'BASIC';
            off8.RealDeliveryDate__c = system.today();
            off8.ExpectedDeliveryDate__c = system.today();
            l_Offers.add(off8);
            Offer__c off9 = TestFactory.createOfferLine(ol1, so3, null);
            off9.Type__c = 'QUICK';
            off9.RealDeliveryDate__c = system.today();
            l_Offers.add(off9);
            Offer__c off10 = TestFactory.createOfferLine(ol1, so2, null);
            off10.Type__c = 'QUICK';
            l_Offers.add(off10);

            insert l_Offers;

            off1.ParentOffer__c = off2.Id;
            off3.ParentOffer__c = off2.Id;
            off8.ParentOffer__c = off7.Id;
            update off1;
            update off3;
            update off8;
        }
    }
    
    static testMethod void Test_GetSalesOrdersOffers() {
        system.runAs(l_users[0]){
            test.starttest();
                l_SalesOrders[0].BodyShopOrderNumber__c = null;
                update l_SalesOrders[0];
                Restrequest req = new Restrequest();
                Restresponse res = new Restresponse();
                String jsonStr = '[{"AssessmentReference":"0912"},{"AssessmentReference":"0913"},{"AssessmentReference":"0914"}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/getSalesOrdersOffers/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTGetSalesOrdersOffers_V1.getOffers();
                Blob Json = RestContext.response.responseBody;
                system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null);
            test.stoptest();
        }
    }
    
    static testMethod void Test_GetSalesOrdersOffersDifferentData() {
        system.runAs(l_users[0]){
            test.starttest();

                l_SalesOrders[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
                l_SalesOrders[0].BodyShopOrderNumber__c = null;
                update l_SalesOrders[0];

                l_OrderLines[0].CataloguePrice__c = null;
                l_OrderLines[0].AssessmentPrice__c = null;
                l_OrderLines[0].Quantity__c = 1;
                l_OrderLines[0].OrderType__c = 'FINAL';
                l_OrderLines[0].AXADiscount__c = null;
                l_OrderLines[0].BodyShopDiscount__c = null;
                //l_OrderLines[0].AdditionnalDiscount__c = null;
                l_OrderLines[0].VAT__c = null;
                l_OrderLines[0].AcceptedCheck__c = TRUE;
                l_OrderLines[0].DeliveryStatus__c = null;
                l_OrderLines[0].Type__c = null;
                l_OrderLines[0].Description__c = 'description1234';
                l_OrderLines[0].PartNUmber__c = '2575272';
                l_OrderLines[0].Manufacturer__c = 'TOYOTA';
                update l_OrderLines[0];

                l_Offers[0].Type__c = 'BASIC';
                l_Offers[1].Type__c = 'BASIC';
                l_Offers[2].Type__c = 'BASIC';
                l_Offers[3].Type__c = 'BASIC';
                l_Offers[4].Type__c = 'BASIC';
                l_Offers[5].Type__c = 'BASIC';
                l_Offers[6].Type__c = 'BASIC';
                l_Offers[7].Type__c = 'BASIC';
                l_Offers[8].Type__c = 'BASIC';
                l_Offers[9].Type__c = 'BASIC';

                update l_Offers;

                Restrequest req = new Restrequest();
                Restresponse res = new Restresponse();
                String jsonStr = '[{"AssessmentReference":"0912"},{"AssessmentReference":"0913"},{"AssessmentReference":"0914"}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/getSalesOrdersOffers/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTGetSalesOrdersOffers_V1.getOffers();
                Blob Json = RestContext.response.responseBody;
                system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null);
            test.stoptest();
        }
    }

    static testMethod void Test_NoOffers() {
        system.runAs(l_users[0]){
            test.starttest();
                Restrequest req = new Restrequest();
                Restresponse res = new Restresponse();
                String jsonStr = '[{"AssessmentReference":"xx"}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/getSalesOrdersOffers/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTGetSalesOrdersOffers_V1.getOffers();
                Blob Json = RestContext.response.responseBody;
                system.debug('>>> Json<<< : '+  Json.toString());
                jsonStr =  Json.toString();
                system.assertEquals(true, Json != null);
                system.assertEquals(true, jsonStr.contains('No Offers.'));
            test.stoptest();
        }
    }

    static testMethod void Test_CatchException() {
      system.runAs(l_users[0]){  

        test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            //Shamina M: 20160120 - dummy json string to test for catch exception section        
            String jsonStr;
            for(integer i=0;i<3000;i++){
                jsonStr += '*****INVALID_JSON';
            }
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/getSalesOrdersOffers/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTGetSalesOrdersOffers_V1.getOffers();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            jsonStr = Json.toString();
            system.assertEquals(true, Json != null);
            system.assertEquals(true, jsonStr.contains('ErrorMessage')); 
        test.stopTest();
      }
    }

    
}