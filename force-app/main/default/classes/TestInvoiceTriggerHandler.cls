/*************************************************************************************
Class Name - TestInvoiceTriggerHandler 
Version - 1.0
Created Date - 15 JUL 2015
Function - Test Class for InvoiceTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date         Description
* ----------    ----------  -----------------------
* Hirikesh(SC)  15/07/2015  Original Version
* Dourga U      24/09/2015  Added code for update of Total Expected Amount on purchase order in after create and after update (case C-001235)
* Dourga U      24/09/2015  Added code for update of Total Expected Amount on sales order in after create and after update (case C-001234)
* Dourga U      27/10/2015  Added test method for after delete
* Dourga U      11/02/2016  Modified code for case 1525
*************************************************************************************/
@isTest
private class TestInvoiceTriggerHandler {
/*
    static list<Account> accountsList;
    static list<user> users;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Invoice__c> invoicesList;
    static list<OrderLine__c> orderLines;
    static list<Offer__c> offerList;

    static{
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
        ASPISTestUtils.generateTestUsers(users);
        //insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        // @CLA To avoid the error with the class AP09
     //   InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='ZZ', CountryCode__c = 'FR', ValidationMargin__c = 1);
     //   insert newCSInvoiceMagin;
        
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','InvoiceTriggerHandler',users[0].Id);
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
                             DistributorInvoicePeriod__c = '1'
                             ,VAT__c= 10)
            };
            insert accountsList;

            ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
            update ASPISTestUtils.accounts;

            purchaseOrders = new list<PurchaseOrder__c>{
                ASPISTestUtils.purchaseOrders[0]
                ,ASPISTestUtils.purchaseOrders[1]
            };
            purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            purchaseOrders[0].status__c = 'DELIVEREDCONFIRMED';
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
            invoicesList = new List<Invoice__c>{
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  15,
                   // PaymentTo__c = accountsList[0].id,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  14,
                   // PaymentTo__c = accountsList[0].id,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                //    Prerequisiteorder__c = pr.id,
                    TotalNet__c =  13,
                   // PaymentTo__c = accountsList[0].id,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[1].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[1].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  0,
                   // PaymentTo__c = accountsList[0].id,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  14,
                   // PaymentTo__c = accountsList[0].id,
                    PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    //Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  0,
                   // PaymentTo__c = accountsList[0].id,
                    Type__c = 'CREDITNOTE',
                    IsBodyShop__c = true,
                    PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id,
                    //RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  0,
                   // PaymentTo__c = accountsList[0].id,
                    Type__c = 'INVOICE',
                    IsBodyShop__c = true,
                    PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id,
                    //RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                //    Prerequisiteorder__c = pr.id,
                    TotalNet__c =  13,
                   // PaymentTo__c = accountsList[0].id,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[1].id,
                    Type__c = 'CREDITNOTE',
                    Distributor__c = ASPISTestUtils.purchaseOrders[1].Distributor__c,
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    //Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  0,
                   // PaymentTo__c = accountsList[0].id,
                    Type__c = 'INVOICE',
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'DRAFT',
                 //   Prerequisiteorder__c = pr.id,
                    TotalNet__c =  0,
                   // PaymentTo__c = accountsList[0].id,
                    Type__c = 'INVOICE',
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    Paymentterms__c = pr.PaymentTerms__c
                )
                
            };
         
        }//end runas
    }//end of static
    
    @isTest 
    static void test_insert() {
        Test.startTest();
            insert invoicesList;

            List<PurchaseOrder__c> listResultPurchaseOrder = new List<PurchaseOrder__c>([select TotalExpectedAmount__c
                                                                                   from PurchaseOrder__c 
                                                                                   where Id = :purchaseOrders]);
            List<PrerequisiteOrder__c> listResultSalesOrder = new List<PrerequisiteOrder__c>([select TotalExpectedAmount__c
                                                                                               from PrerequisiteOrder__c 
                                                                                               where Id = :ASPISTestUtils.prerequisiteOrders[0].id]);
            //System.assertEquals(17.80 , listResultPurchaseOrder[0].TotalExpectedAmount__c );
            //System.assertEquals(35.60 , listResultPurchaseOrder[1].TotalExpectedAmount__c );
            //System.assertEquals(36.00 , listResultSalesOrder[0].TotalExpectedAmount__c );
        Test.stopTest();

        


    }//end of test_process
    

    // ABT 27-APR-2016 - Commented to reduce query rows (after failure in prod)
    // @isTest 
    // static void test_update() {
    //     
    //     Test.startTest();
    //         insert invoicesList;
    //     
    //         invoicesList[0].Status__c = 'PAID';
    //         invoicesList[4].Status__c = 'PAID';
    //         invoicesList[5].Status__c = 'SENT';
    //         update invoicesList;
    // 
    //         List<PurchaseOrder__c> listResultPurchaseOrder = new List<PurchaseOrder__c>([select TotalExpectedAmount__c
    //                                                                                from PurchaseOrder__c 
    //                                                                                where Id = :purchaseOrders[0].id]);
    //         List<PrerequisiteOrder__c> listResultSalesOrder = new List<PrerequisiteOrder__c>([select TotalExpectedAmount__c
    //                                                                                            from PrerequisiteOrder__c 
    //                                                                                        where Id = :ASPISTestUtils.prerequisiteOrders[0].id]);
    //        // System.assertEquals(17.80 , listResultPurchaseOrder[0].TotalExpectedAmount__c );
    //         System.assertEquals(36.00 , listResultSalesOrder[0].TotalExpectedAmount__c );
    //     Test.stopTest();
    // 
    //     
    // 
    // 
    // }//end of test_process
    // 
    // @isTest 
    // static void test_delete1() {
    //     
    //     
    //     Test.startTest();
    //         insert invoicesList;
    //         delete invoicesList[0];
    // 
    //         List<PurchaseOrder__c> listResultPurchaseOrder = new List<PurchaseOrder__c>([select TotalExpectedAmount__c
    //                                                                                from PurchaseOrder__c 
    //                                                                                where Id = :purchaseOrders[0].id]);
    //         List<PrerequisiteOrder__c> listResultSalesOrder = new List<PrerequisiteOrder__c>([select TotalExpectedAmount__c
    //                                                                                            from PrerequisiteOrder__c 
    //                                                                                            where Id = :ASPISTestUtils.prerequisiteOrders[0].id]);
    //         //System.assertEquals(17.80 , listResultPurchaseOrder[0].TotalExpectedAmount__c );
    //         System.assertEquals(36.00 , listResultSalesOrder[0].TotalExpectedAmount__c );
    //     Test.stopTest();
    // 
    // }//end of test_process
    */
}