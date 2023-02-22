/*************************************************************************************
Class Name - TestASPISServiceBodyShopGenerateInvoice
Version - 1.0
Created Date - 22 May 2015
Function - test class for ASPISServiceBodyShopGenerateInvoice

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)            22/05/2015  Original Version
* Bhavish (sc)          28/05/2015  Increased coverage to 100%, Added Assert
* Dourga Unmole         24/07/2015  case C-001234
************************************************************************************/
@isTest
private class TestASPISServiceBodyShopGenerateInvoice {
    /*
    static list<Account> accountsList;
    static list<user> users;
    static list<OrderLine__c> orderLines;
    static list<Offer__c> offers;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Invoice__c> invoicesList;

    static{
        users = new list<User>{ new User(Username = 'test8class@test.com',
                                        LastName = 'test8user',
                                        LanguageLocaleKey = 'en_US',
                                        FirstName = 'te8st',
                                        Email = 'test8@test.com',
                                        Alias = 'test8',
                                        TimeZoneSidKey = 'Europe/Dublin',
                                        LocaleSidKey = 'en_US',
                                        EmailEncodingKey = 'UTF-8',
                                        ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        ASPISTestUtils.generateTestUsers(users);
        //insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        system.runas(users[0]){
            ASPISTestUtils.generateBasicTestData();
            
            accountsList = new List<Account>{
                new Account( Name					='Payment_ScTest1',
                             ReferenceNumber__c		= '1234567',
                             ContactEmail__c		= 'bt3@gmail.com',
                             RecordTypeId			= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
                             ShippingCountryCode	= 'FR',
                             VAT__c					= 10)
            };
            insert accountsList;

            ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
            update ASPISTestUtils.accounts;

            purchaseOrders = new list<PurchaseOrder__c>{
				ASPISTestUtils.purchaseOrders[0]
				,ASPISTestUtils.purchaseOrders[1]
            };
            purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;
            update purchaseOrders;

            orderLines = new list<OrderLine__c>{
				new OrderLine__c(AcceptedCheck__c = true, 
								 PurchaseOrder__c = purchaseOrders[0].id, 
								 CataloguePrice__c = 10, 
								 AXADiscount__c = 11, 
								 BodyShopDiscount__c = 10, 
								 Quantity__c = 2, 
								 AdditionnalDiscount__c = 5)
                ,new OrderLine__c(AcceptedCheck__c = true, 
								  PurchaseOrder__c = purchaseOrders[0].id, 
								  CataloguePrice__c = 10, 
								  AXADiscount__c = 11, 
								  BodyShopDiscount__c = 10,
								   Quantity__c = 2)
                ,new OrderLine__c(AcceptedCheck__c = true, 
								  PurchaseOrder__c = purchaseOrders[1].id, 
								  CataloguePrice__c = 10, 
								  AXADiscount__c = 11, 
								  BodyShopDiscount__c = 10, 
								  Quantity__c = 2)
                ,new OrderLine__c(AcceptedCheck__c = true, 
								  PurchaseOrder__c = purchaseOrders[1].id, 
								  CataloguePrice__c = 10, 
								  AXADiscount__c = 11, 
								  BodyShopDiscount__c = 10, 
								  Quantity__c = 2)
            };
            ASPISTestUtils.generateOrderLine(orderLines);

            Prerequisiteorder__c pr = [Select Id, Assessment__c, BodyShop__c, Name, PaymentTerms__c from Prerequisiteorder__c where Id =:ASPISTestUtils.prerequisiteOrders[1].id limit 1];
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
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    //PreOrderNumber__c = pr.name,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = pr.id,
                    PaymentTo__c = accountsList[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                )
            };
            //insert invoicesList;
            
            offers = new list<Offer__c>{
                new Offer__c(Prerequisiteorder__c=ASPISTestUtils.prerequisiteOrders[0].id, DeliveryStatus__c='DELIVERED', OrderLine__c = orderLines[0].id, Accepted__c = 'YES')
                ,new Offer__c(Prerequisiteorder__c=ASPISTestUtils.prerequisiteOrders[0].id, DeliveryStatus__c='CANCELED', OrderLine__c = orderLines[0].id, Accepted__c = 'YES')
                ,new Offer__c(Prerequisiteorder__c=ASPISTestUtils.prerequisiteOrders[1].id, DeliveryStatus__c='DELIVERED', OrderLine__c = orderLines[1].id, Invoice__c = invoicesList[0].id, Accepted__c = 'YES')
                ,new Offer__c(Prerequisiteorder__c=ASPISTestUtils.prerequisiteOrders[1].id, DeliveryStatus__c='CANCELED', OrderLine__c = orderLines[1].id, Invoice__c = invoicesList[1].id, Accepted__c = 'YES')
            };
            ASPISTestUtils.generateOffer(offers);

            GlobalVariables__c gVariable = new GlobalVariables__c(name='BatchOffering', Object__c='Assessment__c', Type__c='Constant', Value__c='2');
            insert gVariable;
        }//end runas
    }

    static testMethod void testGenerateInvoice1(){
        system.runas(users[0]){
            ASPISServiceBodyShopGenerateInvoice inv = new ASPISServiceBodyShopGenerateInvoice();
            Prerequisiteorder__c prOrd = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id =: ASPISTestUtils.prerequisiteOrders[0].id limit 1];
            test.starttest();
                inv.executeProcess(prOrd);
            test.stoptest();
            List<Invoice__c> invoices = new List<Invoice__c>([select Assessment__c
                                                                    ,BodyShop__c
                                                                    ,Status__c
                                                                    ,Prerequisiteorder__c
                                                                    ,PaymentTo__c
                                                                    ,RecordTypeID
                                                                    ,Paymentterms__c
                                                                    ,TotalNet__c
                                                                    ,ItemsNumber__c
                                                                    ,TotalPieces__c
                                                                from Invoice__c
                                                                where Prerequisiteorder__c=:ASPISTestUtils.prerequisiteOrders[0].id]);
            System.assertEquals(2, invoices.size());
            
        }
    }
	
    static testMethod void testGenerateInvoice2(){
        system.runas(users[0]){
            insert invoicesList;
            ASPISServiceBodyShopGenerateInvoice inv = new ASPISServiceBodyShopGenerateInvoice();
            Prerequisiteorder__c prOrd = [Select Id, Assessment__c, BodyShop__c, name, PaymentTerms__c, TECH_BodyshopCountryCode__c from Prerequisiteorder__c where Id =: ASPISTestUtils.prerequisiteOrders[1].id limit 1];
            test.starttest();
                inv.executeProcess(prOrd);
            test.stoptest();
            List<Invoice__c> invoices = new List<Invoice__c>([select Assessment__c
                                                                    ,BodyShop__c
                                                                    ,Status__c
                                                                    ,Prerequisiteorder__c
                                                                    ,PaymentTo__c
                                                                    ,RecordTypeID
                                                                    ,Paymentterms__c
                                                                    ,TotalNet__c
                                                                    ,ItemsNumber__c
                                                                    ,TotalPieces__c
                                                                from Invoice__c
                                                                where Prerequisiteorder__c=:ASPISTestUtils.prerequisiteOrders[1].id]);
            System.debug('zz :'+invoices);
            System.assertEquals(2, invoices.size());
            System.assertEquals(prOrd.Assessment__c, invoices[0].Assessment__c);
            System.assertEquals(prOrd.BodyShop__c, invoices[0].BodyShop__c);
            //System.assertEquals(prOrd.name, invoices[0].PreOrderNumber__c);
            System.assertEquals('SENT', invoices[0].Status__c);
            System.assertEquals(accountsList[0].id, invoices[0].PaymentTo__c);
            System.assertEquals(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(), invoices[0].RecordTypeID);
            System.assertEquals(prOrd.PaymentTerms__c, invoices[0].Paymentterms__c);

            Prerequisiteorder__c preOrder = [select Id, Invoice__c from Prerequisiteorder__c where id=:ASPISTestUtils.prerequisiteOrders[1].id limit 1];
            //System.assertEquals(invoices[0].id, preOrder.Invoice__c);

            System.assertEquals(18, invoices[0].TotalNet__c);
            System.assertEquals(1, invoices[0].ItemsNumber__c);
            System.assertEquals(2, invoices[0].TotalPieces__c);

            List<Offer__c> listOffers = new List<Offer__c>([select invoice__c
                                                            from Offer__c 
                                                            where DeliveryStatus__c = 'DELIVERED' 
                                                            and PrerequisiteOrder__c = :ASPISTestUtils.prerequisiteOrders[1].id]);
            System.assertEquals(invoices[0].id, listOffers[0].invoice__c);
            List<OrderLine__c> listOrderLines = new List<OrderLine__c>([Select DeliveryStatus__c
                                                                    from OrderLine__c
                                                                    where id=:orderLines[1].id]);
            System.assertEquals('INPROCESS',listOrderLines[0].DeliveryStatus__c);
        }
    }*/
    
}