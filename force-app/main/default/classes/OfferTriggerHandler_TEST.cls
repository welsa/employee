/*************************************************************************************
Class Name - OfferTriggerHandler_TEST
Version - 1.0
Created Date - 27 APRIL 2016
Function - Test Class fer class OfferTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      28/04/2016  Reworked Version
*************************************************************************************/
@isTest
private class OfferTriggerHandler_TEST {
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Offer__c> l_Offers;
    static list<Invoice__c> l_Invoices;
    static list<Assessment__c> childAssessments;
    static list<PartList__c> partLists;
    static list<PartList__c> childpartLists;

    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        childAssessments = new list<Assessment__c>();
        childpartLists = new list<PartList__c>();
        partLists = new list <PartList__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Offers = new list<Offer__c>();
        l_Invoices = new list<Invoice__c>();
        
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            Account bs1 = TestFactory.createAccountPayment('BodyShop_ScTest1', 'FR');
            bs1.ContactUser__c = l_users[0].Id;
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            l_Accounts.add(dist1);
            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);            
            insert l_Assessments;

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
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
            childAssessments.add(ass2);

            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
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
            pl2.Quantity__c = 15;
            pl2.TECH_OrderedCounter__c = 2;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);
            insert partLists;


            PartList__c pl3 = TestFactory.createPartList(ass2);
            pl3.OriginalPart__c = partLists[0].Id;
            pl3.SelectedByBS__c = true;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal-1';
            pl3.Quantity__c = 15;
            childpartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(ass2);
            pl4.OriginalPart__c = partLists[1].Id;
            pl4.SelectedByBS__c = true;
            pl4.Quantity__c = 15;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal-1';
            childpartLists.add(pl4);
            insert childpartLists;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass2, bs2, '');
            l_SalesOrders.add(so1);            
            insert l_SalesOrders;

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass2, so1, bs2, dist1, '');
            l_purchaseOrders.add(po1_1);
            insert l_purchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INDELIVERY');
            ol1.PartList__c = childpartLists[0].Id;
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'CANCELED');
            ol2.PartList__c = childpartLists[1].Id;
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
            insert l_OrderLines;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INDELIVERY');
            off1.Type__c = 'QUICK';
            off1.Accepted__c = 'YES';
            off1.Suppliable__c = true;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INDELIVERY');
            off2.Type__c = 'QUICK';
            l_Offers.add(off2);
            insert l_Offers;
        }
    }
    static testMethod void test_UpdateOffer() {
    system.debug('-------------------- Start test_UpdateOffer ---------------------');
        system.runas(l_users[0]){
            l_Offers[0].DeliveryStatus__c = 'CANCELED';
            //l_Offers[1].DeliveryStatus__c = 'DAMAGED';
            l_Offers[1].DeliveryStatus__c = 'ERROR';
            Test.startTest();
                update l_Offers;
            Test.stopTest();

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);

            System.assertEquals( l_Offers[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            System.assertEquals( 'ISSUE' , listResultOrder[1].DeliveryStatus__c );

        }//end runas

        system.debug('-------------------- End test_UpdateOffer ---------------------');
    }

    static testMethod void test_UpdateOfferMissing() {
        system.debug('-------------------- Start test_UpdateOfferMissing ---------------------');
        system.runas(l_users[0]){

            // Create several invoices.
            Invoice__c inv1 = TestFactory.createBodyshopCreditNote('INV-2812A', 14.40, 'PAID', l_SalesOrders[0]);
            l_Invoices.add(inv1);
            
            Invoice__c inv2 = TestFactory.createBodyshopInvoice('INV-2812C', 54.40, 'PAID', l_SalesOrders[0]);
            l_Invoices.add(inv2);
            insert l_Invoices;

            l_Offers[0].DeliveryStatus__c = 'CANCELED';
            //l_Offers[1].DeliveryStatus__c = 'MISSING';
            l_Offers[1].DeliveryStatus__c = 'ERROR';
            l_Offers[1].Invoice__c = l_Invoices[1].Id;
            l_Offers[1].CreditNote__c = l_Invoices[0].Id;
            Test.startTest();
                update l_Offers;
            Test.stopTest();

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);

            System.assertEquals( l_Offers[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            System.assertEquals( 'ISSUE' , listResultOrder[1].DeliveryStatus__c );


        }//end runas
        system.debug('-------------------- End test_UpdateOfferMissing ---------------------');
    }

    static testMethod void test_UpdateOffer2Cancelled() {
        system.debug('-------------------- Start test_UpdateOffer2Cancelled ---------------------');
        system.runas(l_users[0]){
            l_Offers[0].DeliveryStatus__c = 'CANCELED';
            l_Offers[1].DeliveryStatus__c = 'CANCELED';
            Test.startTest();
                update l_Offers;
            Test.stopTest();

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);

            System.assertEquals( l_Offers[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            System.assertEquals( l_Offers[1].DeliveryStatus__c , listResultOrder[1].DeliveryStatus__c );


        }//end runas            
        system.debug('-------------------- End test_UpdateOffer2Cancelled ---------------------');
    }//end of test_InsertOffer

    static testMethod void test_UpdateOfferFlagOffer() {
        system.debug('-------------------- Start test_UpdateOfferFlagOffer ---------------------');
        system.runas(l_users[0]){
            l_Offers[0].DeliveryStatus__c = 'DELIVERED';
            l_Offers[1].DeliveryStatus__c = 'DELIVERED';
            update l_Offers;
            l_Offers[0].DeliveryStatus__c = 'CANCELED';
            l_Offers[1].DeliveryStatus__c = 'RETURNED';
            Test.startTest();
                update l_Offers;
            Test.stopTest();

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT TECH_ToBeProcessed__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);
            // ABT - 20-JAN-2017 - C-001856 -> TECH_ToBeProcessed__c will be set to false
            // System.assertEquals( true , listResultOrder[0].TECH_ToBeProcessed__c );
            // System.assertEquals( true , listResultOrder[1].TECH_ToBeProcessed__c );
            System.assertEquals( false , listResultOrder[0].TECH_ToBeProcessed__c );
            System.assertEquals( false , listResultOrder[1].TECH_ToBeProcessed__c );
            
        }//end runas
        system.debug('-------------------- End test_UpdateOfferFlagOffer ---------------------');
    }//end of test_InsertOffer

    static testMethod void test_UpdateOfferChild() {
        system.debug('-------------------- Start test_UpdateOfferChild ---------------------');
        system.runas(l_users[0]){

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'INDELIVERY');
            ol1.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'CANCELED');
            ol2.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol2);
            insert l_OrderLines[2];
            insert l_OrderLines[3];

            Offer__c off1 = TestFactory.createOfferLine(l_OrderLines[2], l_SalesOrders[0], 'INDELIVERY');
            off1.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(l_OrderLines[3], l_SalesOrders[0], 'INDELIVERY');
            off2.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off2);
            insert l_Offers[2];
            insert l_Offers[3];
            l_Offers[0].DeliveryStatus__c = 'DELIVERED';
            l_Offers[1].DeliveryStatus__c = 'DELIVERED';
            l_Offers[2].DeliveryStatus__c = 'DELIVERED';
            l_Offers[3].DeliveryStatus__c = 'DELIVERED';
            //update l_Offers;
            Test.startTest();
                update l_Offers;
            

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);
            Test.stopTest();
            System.assertEquals( l_Offers[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            System.assertEquals( l_Offers[1].DeliveryStatus__c , listResultOrder[1].DeliveryStatus__c );
            System.assertEquals( l_Offers[2].DeliveryStatus__c , listResultOrder[2].DeliveryStatus__c );
            System.assertEquals( l_Offers[3].DeliveryStatus__c , listResultOrder[3].DeliveryStatus__c );
            
        }//end runas
        system.debug('-------------------- End test_UpdateOfferChild ---------------------');
    }//end of test_InsertOffer

    static testMethod void test_UpdateOfferChangeAccepted() {
         system.debug('-------------------- Start test_UpdateOfferChangeAccepted ---------------------');
        system.runas(l_users[0]){

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'INDELIVERY');
            ol1.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'CANCELED');
            ol2.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol2);
            insert l_OrderLines[2];
            insert l_OrderLines[3];

            Offer__c off1 = TestFactory.createOfferLine(l_OrderLines[2], l_SalesOrders[0], 'INDELIVERY');
            off1.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(l_OrderLines[3], l_SalesOrders[0], 'INDELIVERY');
            off2.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off2);
            insert l_Offers[2];
            insert l_Offers[3];

            l_Offers[0].Accepted__c = 'NO';
            l_Offers[1].Accepted__c = 'NO';
            l_Offers[2].Accepted__c = 'NO';
            l_Offers[3].Accepted__c = 'NO';
            Test.startTest();
                update l_Offers;
            Test.stopTest();

            list <Offer__c> listResultOffer = new list<Offer__c>([SELECT Accepted__c FROM Offer__c WHERE Id IN :l_Offers]);

            System.assertEquals('NO' , listResultOffer[0].Accepted__c );
            System.assertEquals('NO' , listResultOffer[1].Accepted__c );
            

        }//end runas
        system.debug('-------------------- End test_UpdateOfferChangeAccepted ---------------------');
    }

    static testMethod void test_UpdateOfferChildParentNotInList() {
        system.debug('-------------------- Start test_UpdateOfferChildParentNotInList ---------------------');
        system.runas(l_users[0]){

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'INDELIVERY');
            ol1.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,l_purchaseOrders[0], 'CANCELED');
            ol2.OriginalItem__c = l_OrderLines[1].Id;
            l_OrderLines.add(ol2);
            insert l_OrderLines[2];
            insert l_OrderLines[3];

            Offer__c off1 = TestFactory.createOfferLine(l_OrderLines[2], l_SalesOrders[0], 'INDELIVERY');
            off1.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(l_OrderLines[3], l_SalesOrders[0], 'INDELIVERY');
            off2.ParentOffer__c = l_Offers[1].Id;
            l_Offers.add(off2);
            insert l_Offers[2];
            insert l_Offers[3];
            l_Offers[0].DeliveryStatus__c = 'DELIVERED';
            l_Offers[2].DeliveryStatus__c = 'DELIVERED';
            l_Offers[3].DeliveryStatus__c = 'DELIVERED';
            //update l_Offers;
            Test.startTest();
                update l_Offers;
            

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :l_OrderLines]);
            Test.stopTest();
            System.assertEquals( l_Offers[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            System.assertEquals( l_Offers[2].DeliveryStatus__c , listResultOrder[2].DeliveryStatus__c );
            System.assertEquals( l_Offers[3].DeliveryStatus__c , listResultOrder[3].DeliveryStatus__c );
            
        }//end runas
        system.debug('-------------------- End test_UpdateOfferChildParentNotInList ---------------------');
    }//end of test_InsertOffer

    static testMethod void test_updateOrderedCounterPartListParent() {
    system.debug('-------------------- Start test_updateOrderedCounterPartListParent ---------------------');
        system.runas(l_users[0]){
            l_Offers[0].Accepted__c = 'NO';

            Test.startTest();
                update l_Offers;
            Test.stopTest();

            PartList__c plOrdered = [SELECT TECH_OrderedCounter__c  FROM PartList__c WHERE Id =: partLists[0].Id ];

            System.assertEquals( 0 , plOrdered.TECH_OrderedCounter__c );

        }//end runas

        system.debug('-------------------- End test_updateOrderedCounterPartListParent ---------------------');
    }
}