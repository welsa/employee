/*************************************************************************************
Class Name - TestOfferTriggerHandler
Version - 1.0
Created Date - 14 JUL 2015
Function - test class for fferTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Hirikesh (sc)         14/07/2015  Original Version
************************************************************************************/
@isTest
private class TestToBeRemoved_Offers {
// ABT 06-MAY-2016 - Commented
/*
    static list<Account> accountsList;
    static list<user> users;
    static list<OrderLine__c> orderLines;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Offer__c> offerList;
    static list<Invoice__c> invoicesList;
    static {
        users = new list<User>{ new User(Username = 'testclass@test.com',
                                        LastName = 'testuser',
                                        LanguageLocaleKey = 'en_US',
                                        FirstName = 'test',
                                        Email = 'test@test.com',
                                        Alias = 'test',
                                        TimeZoneSidKey = 'Europe/Dublin',
                                        LocaleSidKey = 'en_US',
                                        EmailEncodingKey = 'UTF-8',
                                        ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        //insert users;
        ASPISTestUtils.generateTestUsers(users);
        //insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();

            accountsList = new List<Account>{
                new Account(Name='Payment_ScTest1',
                             ReferenceNumber__c = '1234567',
                             ContactEmail__c = 'bt3@gmail.com',
                             RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
                             ShippingCountryCode = 'FR',
                             VAT__c = 10)
            };
            insert accountsList;

            purchaseOrders = new list<PurchaseOrder__c>{
                ASPISTestUtils.purchaseOrders[0]
                ,ASPISTestUtils.purchaseOrders[1]
            };
            purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;
            update purchaseOrders;

            orderLines = new list<OrderLine__c>{
                new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[0].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2)
                ,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2)
            };
            ASPISTestUtils.generateOrderLine(orderLines);

            Prerequisiteorder__c pr = [Select Id, Assessment__c, BodyShop__c, Name, PaymentTerms__c from Prerequisiteorder__c where Id =:ASPISTestUtils.prerequisiteOrders[0].id limit 1];
            invoicesList = new List<Invoice__c>{
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = pr.id,
                    PaymentTo__c = accountsList[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                )
            };
            insert invoicesList;

            offerList = new List<Offer__c>{
                new Offer__c(OrderLine__c = orderLines[0].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'BASIC'
                            ,Invoice__c = invoicesList[0].id
                            ,Accepted__c = 'NO'
                            ,DeliveryStatus__c = 'INPROCESS')
                ,new Offer__c(OrderLine__c = orderLines[1].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'UNSUPPLIEABLEBASIC'
                            , Accepted__c = 'NO'
                            ,DeliveryStatus__c = 'INPROCESS')
            };
            ASPISTestUtils.generateOffer(offerList);
        }//end runas
    }//end of static

    @isTest 
    static void test_UpdateOffer() {
        system.runas(users[0]){
            offerList[0].DeliveryStatus__c = 'INDELIVERY';
            offerList[0].Accepted__c = 'YES';
            offerList[1].DeliveryStatus__c = 'INDELIVERY';
            offerList[1].Accepted__c = 'YES';
            Test.startTest();
                update offerList;
            Test.stopTest();

            list <OrderLine__c> listResultOrder = new list<OrderLine__c>([SELECT DeliveryStatus__c FROM OrderLine__c WHERE Id IN :orderLines]);

            //System.assertEquals( offerList[0].DeliveryStatus__c , listResultOrder[0].DeliveryStatus__c );
            //System.assertEquals( 'ISSUE' , listResultOrder[1].DeliveryStatus__c );


        }//end runas
    }//end of test_InsertOffer
    */
}