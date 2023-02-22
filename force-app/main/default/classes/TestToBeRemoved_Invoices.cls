@isTest
public class TestToBeRemoved_Invoices {
// ABT 06-MAY-2016
/*
    static list<Account> accountsList;
    static list<user> users;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Invoice__c> invoicesList;
    static list<OrderLine__c> orderLines;
    static list<Offer__c> offerList;

    static{
        users = new list<User>{ new User(Username = 'InvoiceTest@InvoiceTest.com',
                                        LastName = 'InvoiceTest',
                                        LanguageLocaleKey = 'en_US',
                                        FirstName = 'InvoiceTest',
                                        Email = 'InvoiceTest@InvoiceTest.com',
                                        Alias = 'testInv',
                                        TimeZoneSidKey = 'Europe/Dublin',
                                        LocaleSidKey = 'en_US',
                                        EmailEncodingKey = 'UTF-8',
                                        ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        ASPISTestUtils.generateTestUsers(users);

        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();
            
            accountsList = new List<Account>{
                new Account(Name='Payment_ScTest1',
                             ReferenceNumber__c = '1234567',
                             ContactEmail__c = 'bt3@gmail.com',
                             RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),
                             ShippingCountryCode = 'FR',
                             OwnerId = users[0].id,
                             DistributorNextInvoiceDate__c = System.now().addDays(3).date(),
                             DistributorInvoicePeriod__c = '1',
                             VAT__c =10 )
            };
            insert accountsList;

            ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
            update ASPISTestUtils.accounts;

            purchaseOrders = new list<PurchaseOrder__c>{
                ASPISTestUtils.purchaseOrders[0]
                ,ASPISTestUtils.purchaseOrders[1]
            };
            purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            purchaseOrders[0].status__c = 'PAYABLE';
            purchaseOrders[0].Distributor__c = accountsList[0].id;
            purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;

            update purchaseOrders;

            orderLines = new list<OrderLine__c>{
                new OrderLine__c(AcceptedCheck__c = true, 
                                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id, 
                                CataloguePrice__c = 10, 
                                AXADiscount__c = 11, 
                                BodyShopDiscount__c = 10, 
                                Quantity__c = 2
                                 , DeliveryStatus__c = 'DELIVERED')
                ,new OrderLine__c(AcceptedCheck__c = true, 
                                 PurchaseOrder__c = ASPISTestUtils.purchaseOrders[1].id, 
                                 CataloguePrice__c = 10, 
                                 AXADiscount__c = 11, 
                                 BodyShopDiscount__c = 10, 
                                 Quantity__c = 2
                                  , DeliveryStatus__c = 'DELIVERED')
            };
            ASPISTestUtils.generateOrderLine(orderLines);

            offerList = new List<Offer__c>{
                new Offer__c(OrderLine__c = orderLines[0].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'BASIC'
                            , Accepted__c = 'YES'
                            , DeliveryStatus__c = 'DELIVERED')
                ,new Offer__c(OrderLine__c = orderLines[0].id
                            ,PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id
                            ,Type__c = 'UNSUPPLIEABLEBASIC'
                            , Accepted__c = 'YES'
                            , DeliveryStatus__c = 'DELIVERED')
            };
            ASPISTestUtils.generateOffer(offerList);
 
            Prerequisiteorder__c pr = [Select Id, Assessment__c, BodyShop__c, Name, PaymentTerms__c from Prerequisiteorder__c where Id =:ASPISTestUtils.prerequisiteOrders[1].id limit 1];
            invoicesList = new List<Invoice__c>();
            
            date mydate1 = date.parse('10/20/2015');
            date mydate2 = date.parse('12/20/2015');
            
            for(Integer i=1;i<1000;i++){
                Invoice__c invoiceToAdd = new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    Status__c = 'RECEIVED', // oli SENT
                    Type__c = 'INVOICE',
                    Date__c = mydate1,
                    DueDateDistributor__c = mydate2,
                    TotalNet__c =  15,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                );
                invoicesList.add(invoiceToAdd);
            }
         
        }//end runas
    }//end of static
    
    @isTest 
    static void test_insert_and_update() {
        Test.startTest();
        
            // insert list
            insert invoicesList;
        
        
            for(Invoice__c i:invoicesList){
                i.TotalNet__c =  101;
            }
            // update list
            update invoicesList;

     
    
        system.debug('XX3 TEST ENDS HERE --> 1 insert and 2 updates of all invoices created');
        Test.stopTest();

        


    }//end of test_process
 
    */
}