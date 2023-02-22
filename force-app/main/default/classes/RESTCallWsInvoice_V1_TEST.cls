@isTest
/*************************************************************************************
Class Name - RESTCallWsInvoice_V1_TEST
Version - 1.0
Created Date - 27 OCT 2015
Function - Test class for RESTCallWsInvoice_V1 and VFC_RESTCallWsInvoice_V1
Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------        ----------  -----------------------
* Brayan N          27/10/2015    original Version
* Shamina M         19/01/2016    review and updates to increase coverage + case 1386
* Dourga U          27/09/2016    increase coverage
* Welsa C           24/08/2020    C-003838 Nob - Migrate Billing information to new fields
*************************************************************************************/

private class RESTCallWsInvoice_V1_TEST {
    static List<Assessment__c> l_Assessments;
    static list<Account> l_Accounts;
    static list<user> l_users;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    static list<Offer__c> l_Offers;
    static list<Prerequisiteorder__c> l_SalesOrders;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PartList__c> l_partList;
    static Prerequisiteorder__c pr;
    static CountryCodeInformationsMapping__c ccim;
    static BusinessHours defaultHours;
   
    static{
        
        defaultHours = [select Id,TimeZoneSidKey from BusinessHours where IsDefault=true];
        
        ccim = new CountryCodeInformationsMapping__c(Name = 'FR',LoginInvoiceBodyShop__c = 'Test',
                                                     PasswordInvoiceBodyShop__c = 'Test',URLInvoiceBodyShop__c = 'Test',
                                                     BusinessHoursID__c = defaultHours.Id);
        insert ccim;

        l_Accounts = new list<Account>();
        l_users = new list<user>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Invoices = new list<Invoice__c>();
        l_Offers = new list<Offer__c>();
        l_SalesOrders = new list<Prerequisiteorder__c>();
        l_purchaseOrders =  new list<PurchaseOrder__c>();
        l_Assessments = new List<Assessment__c> ();
        l_partList = new list<PartList__c>();

        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            bs1.ContactUser__c = l_users[0].Id;
            //bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            bs2.BillingStreet__c = '117 Rue du Soleil - Jaune';
            bs2.BillingPostalCode__c = '11111';
            bs2.BillingCity__c = 'Paris';
            bs2.VATNumber__c = 'FRXX123456789';
            bs2.ContactEmail__c = 'bst@gmail.com';
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            l_Accounts[0].vat__c=20;
            l_Accounts[1].vat__c=21;
            l_Accounts[2].vat__c=21;

            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.ModelV2__c = 'PRIUS';
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            ass2.Manufacturer__c = 'TOYOTA';
            ass2.ModelV2__c = 'PRIUS';
            ass2.ClaimReference__c = '94647'; 
            ass2.PlateNumber2__c = '464'; 
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);            
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
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

            //create partlist 
            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.Description__c = 'desscpl1';
            l_partList.add(pl1);
            insert l_partList;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVEREDCONFIRMED');
            ol1.PartList__c = pl1.Id;
            ol1.PartNumber__c = '4449446';
            ol1.Description__c = 'desctest1';
            ol1.AdditionnalDiscount__c = null;
            ol1.Discount__c = null;
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVEREDCONFIRMED');
            ol2.PartList__c = pl1.Id;
            ol2.PartNumber__c = '4449447';
            ol2.Description__c = 'desctest2';
            l_OrderLines.add(ol2);
            insert l_OrderLines;

            Invoice__c inv1 = TestFactory.createBodyshopInvoice('test1', 10, 'SENT', l_SalesOrders[1]);
            inv1.PaymentTerms__c = 'NET7';
            inv1.Date__c = System.today();
            l_Invoices.add(inv1);
            Invoice__c cn1 = TestFactory.createBodyshopCreditNote('test1', 10, 'SENT', l_SalesOrders[1]);
            cn1.PaymentTerms__c = 'NET7';
            cn1.Date__c = System.today();
            l_Invoices.add(cn1);
            insert l_Invoices;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off1.Invoice__c = inv1.Id;
            off1.RealDeliveryDate__c = System.today();
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off2.CreditNote__c = cn1.Id;
            off2.RealDeliveryDate__c = System.today();
            l_Offers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol2, so1, 'DELIVERED');
            off3.Invoice__c = inv1.Id;
            off3.RealDeliveryDate__c = System.today().addDays(2);
            l_Offers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol2, so1, 'DELIVERED');
            off4.CreditNote__c = cn1.Id;
            off4.RealDeliveryDate__c = System.today().addDays(2);
            l_Offers.add(off4);
            insert l_Offers;    

        }
    }
    
    
    @isTest static void Test_NoInvoices() {

        // Implement test code
        set<Id> invoiceId;
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            RESTCallWsInvoice_V1.callWsInvoice_V1(invoiceId);
            //RESTCallWsInvoice_V1.invokeWebService(new HttpRequest());
        test.stopTest();  
        
        list<Log__c> lTest = [Select Id,name,JSONMessage__c,JSONResponse__c from Log__c];
        System.assertEquals(1,lTest.size());

        system.debug('#####lTest details= ' + lTest);
        
    }

    @isTest static void Test_Null() {

        // Implement test code
        set<Id> invoiceId; 
        delete ccim;
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            RESTCallWsInvoice_V1.callWsInvoice_V1(invoiceId);
            //RESTCallWsInvoice_V1.invokeWebService(new HttpRequest());
        test.stopTest();  
        
        list<Log__c> lTest = [Select Id,name,JSONMessage__c,JSONResponse__c from Log__c];

        system.debug('#####lTest Test_Null= '+ lTest);

        System.assertEquals('No invoices',lTest[0].JSONMessage__c);      
        
    }
        
    @isTest static void Test_BuildWSRequestFromRestClass() {
        
        system.runas(l_users[0]){
            
            set<Id> invoiceId = new Set<Id>();
            list<Invoice__c> invoiceList = new list<Invoice__c>();
            for(Invoice__c i : l_Invoices){  
                invoiceId.add(i.Id);
            }        
            
            test.startTest();            
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                RESTCallWsInvoice_V1.buildWebServiceRequest(invoiceId,invoiceList);
            test.stopTest(); 
            
            list<Log__c> lTest = [Select Id from Log__c];
            System.assertEquals(0,lTest.size());
            
        }//end runas
    }
        
    @isTest static void Test_BuildWSRequestFromRestClass2() {
        
        system.runas(l_users[0]){

            l_Accounts[1].BillingStreet__c = '117 Rue du Soleil';
            l_Accounts[1].ContactUser__c = null;
            update l_Accounts[1];

            l_Offers[0].RealDeliveryDate__c = null;
            l_Offers[1].RealDeliveryDate__c = null;
            l_Offers[2].RealDeliveryDate__c = null;
            l_Offers[3].RealDeliveryDate__c = null;
            update l_Offers;
            set<Id> invoiceId = new Set<Id>();
            list<Invoice__c> invoiceList = new list<Invoice__c>();
            for(Invoice__c i : l_Invoices){
                invoiceId.add(i.Id);
            }        
            test.startTest();            
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                RESTCallWsInvoice_V1.buildWebServiceRequest(invoiceId,invoiceList);
            test.stopTest(); 
            
            list<Log__c> lTest = [Select Id from Log__c];
            System.assertEquals(0,lTest.size());
            
        }//end runas
    }
        
    @isTest static void Test_BuildWSRequestFromRestClassV2() {
        
        system.runas(l_users[0]){
            
            test.startTest();            
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                RESTCallWsInvoice_V1.makeCallWsInvoice_V2(l_Invoices);
            test.stopTest(); 
            
            list<Log__c> lTest = [Select Id from Log__c];
            System.assertEquals(1,lTest.size());
            
        }//end runas
    }
    
    
    /*@isTest static void Test_CalloutFromVFC() {
        l_Accounts = new list<Account>();
        l_users = new list<user>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Invoices = new list<Invoice__c>();
        l_Offers = new list<Offer__c>();
        l_SalesOrders = new list<Prerequisiteorder__c>();
        l_purchaseOrders =  new list<PurchaseOrder__c>();
        l_Assessments = new List<Assessment__c> ();

        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){            
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            l_Accounts.add(bs2);
            insert l_Accounts;
            
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            l_Assessments.add(ass1);
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);                      
            insert l_SalesOrders;

            Invoice__c inv1 = TestFactory.createBodyshopInvoice('test1', 10, 'SENT', l_SalesOrders[0]);
            l_Invoices.add(inv1);
            Invoice__c cn1 = TestFactory.createBodyshopCreditNote('test1', 10, 'SENT', l_SalesOrders[0]);
            l_Invoices.add(cn1);
            insert l_Invoices;

            system.debug('country code:'+ [select TechCountryCode__c, RecordTypeId from Invoice__c where id in: l_Invoices]);
            
            test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());       
                //Shamina M:20160119 - replaced so1 by so2 to obtain more coverage for VFC_RESTCallWsInvoice_V1   
                system.debug('country code:'+ [select TechCountryCode__c, RecordTypeId from Invoice__c where id =: l_Invoices[0].id]);
            
            
                ApexPages.StandardController sc1 = new ApexPages.StandardController(l_Invoices[0]);
                VFC_RESTCallWsInvoice_V1 controller = new VFC_RESTCallWsInvoice_V1(sc1);
                controller.callWsInvoice_V1();
            test.stopTest(); 
            
            list<Log__c> lTest = [Select Id from Log__c];
            System.assertEquals(1,lTest.size());
            
        }//end runas 
    }*/
    
    
}