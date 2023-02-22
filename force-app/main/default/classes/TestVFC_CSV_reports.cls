/*************************************************************************************
Class Name - TestVFC_CSV_reports
Version - 1.0
Created Date - 30 Nov 2015
Function - test class for VFC_CSV_reports

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Immo S                30/11/2015  Original Version
* Dourga U              07/10/2016  No longer in use
************************************************************************************/
@isTest
public class TestVFC_CSV_reports{

    /*static list<Account> accountsList;
    static list<user> users;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Invoice__c> invoicesList;
    static list<Invoice__c> invoicesList2;
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
                             DistributorInvoicePeriod__c = '1' ,
                             VAT__c = 10) 
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
                                 , DeliveryStatus__c = 'DELIVERED'
                                 ,PartNumber__c = '1234')
                ,new OrderLine__c(AcceptedCheck__c = true, 
                                 PurchaseOrder__c = ASPISTestUtils.purchaseOrders[1].id, 
                                 CataloguePrice__c = 10, 
                                 AXADiscount__c = 11, 
                                 BodyShopDiscount__c = 10, 
                                 Quantity__c = 2
                                  , DeliveryStatus__c = 'DELIVERED'
                                  ,PartNumber__c = '1235')
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
            date mydate = date.parse('11/30/2014');

    List<Id> RecordTypes = New List<Id>();
    List<String> Types = New List<String>();        
    List<String> Statuses = New List<String>();
    Id BodyshopCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId();
    Id BodyshopInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
    Id DistributorCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId();
    Id DistributorInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId();    
    RecordTypes.add(BodyshopCreditnoteID);
    Types.add('CREDITNOTE');
    Statuses.add('SENT');
    RecordTypes.add(BodyshopInvoiceID);
    Types.add('INVOICE');
    Statuses.add('SENT');
    RecordTypes.add(DistributorCreditnoteID);
    Types.add('CREDITNOTE');
    Statuses.add('RECEIVED');
    RecordTypes.add(DistributorInvoiceID);
    Types.add('INVOICE');
    Statuses.add('RECEIVED');
            
            
            Account bsacc = [select Id, VAT__c from Account where Id =:pr.BodyShop__c];
            bsacc.VAT__c = 20;
            update bsacc;
            
            for(Integer i=0;i<4;i++){
                Invoice__c invoiceToAdd = new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    Status__c = Statuses[i],
                    Type__c = Types[i],
                    TotalNet__c =  15,
                    Date__c = mydate,
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    PrerequisiteOrder__c = pr.Id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = RecordTypes[i],
                    Paymentterms__c = pr.PaymentTerms__c
                );
                invoicesList.add(invoiceToAdd);
            }
            
            
             invoicesList2 = new List<Invoice__c>{
	        	new Invoice__c(
	                Assessment__c = pr.Assessment__c,
	                BodyShop__c = pr.BodyShop__c,
                    Date__c = mydate,
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
                    Date__c = mydate,
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
                    Date__c = mydate,
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
                    Date__c = mydate,
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
	                //
	                Status__c = 'SENT',
                    Date__c = mydate,
	             //   Prerequisiteorder__c = pr.id,
	                TotalNet__c =  14,
	               // PaymentTo__c = accountsList[0].id,
	                PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id,
	                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
	                Paymentterms__c = pr.PaymentTerms__c
            	),
            	new Invoice__c(
	                Assessment__c = pr.Assessment__c,
	                BodyShop__c = pr.BodyShop__c,
                    Date__c = mydate,
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
                    Date__c = mydate,
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
                    Date__c = mydate,
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
	                Assessment__c = pr.Assessment__c,
	                BodyShop__c = pr.BodyShop__c,
                    Date__c = mydate,
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
                    Date__c = mydate,
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
    static void testPage() {
        Test.startTest();
        
            // insert list
            insert invoicesList;
        	insert invoicesList2;
            PageReference pageRef = Page.CSV_reports;
            Test.setCurrentPage(pageRef);
            VFC_CSV_reports sc = new VFC_CSV_reports();
            sc.inputEmail = 'immo.salo@gmail.com';
            PageReference S = sc.sendAsCSV();
            
        Test.stopTest();

        


    }//end of test_process*/
 

    
}