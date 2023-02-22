/*************************************************************************************
Class Name - RESTUpsertInvoices_TEST
Version - 1.0
Created Date - 01 JUN 2015
Function - Test class for the web service create assessment version 2

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  -----------------------
* Ashwina S       20/09/2016  Original Version 

*************************************************************************************/
@isTest
private with sharing class RESTUpsertInvoices_TEST {

    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<PurchaseOrder__c> POList;
    static list<PrerequisiteOrder__c> SOList;
     static list<Invoice__c> l_Invoices;
    static BusinessHours defaultHours;
      
    static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_Invoices = new list<Invoice__c>();
        
        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
        
            // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            l_Accounts.add(bs1);            
    
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            l_Accounts.add(dist1);
            insert l_Accounts;
        
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            l_Assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            l_Assessments.add(ass2);
       
            insert l_Assessments;
        
            
            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, 'DELIVEREDCONFIRMED');
            l_SalesOrders.add(so1);
        
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs1, 'DELIVEREDCONFIRMED');
            l_SalesOrders.add(so2);
        
            insert l_SalesOrders;
        

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'DRAFTQUOTE');
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass2, so2, bs1, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_2);                 
            insert l_purchaseOrders;  
                    
            // Create several invoices.
            //
            
            POList = [Select Name from PurchaseOrder__c where id in :l_purchaseOrders];
            SOList = [Select Name from PrerequisiteOrder__c where id in :l_SalesOrders];      
                     
            Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'PAID', po1_1);
            inv1.Number__c = 'INV-2812A';
            inv1.InvoiceReference__c = l_Accounts[1].ReferenceNumber__c +'INV-2812A' + POList[0].Name;
            //inv1.InvoiceReference__c = 'INV-2812A';
            l_Invoices.add(inv1);
        
            Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'RECEIVED', po1_2);
            inv2.Number__c = 'INV-2812B';
            inv2.InvoiceReference__c = l_Accounts[1].ReferenceNumber__c +'INV-2812B' + POList[1].Name;
            //inv2.InvoiceReference__c = 'INV-2812B';
            l_Invoices.add(inv2);
            
            Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 54.40, 'RECEIVED', po1_1);
            inv3.Number__c = 'INV-2812C';
            inv3.InvoiceReference__c = l_Accounts[1].ReferenceNumber__c +'INV-2812C' + POList[0].Name;
            //inv3.InvoiceReference__c = 'INV-2812C';
            l_Invoices.add(inv3);
        
            Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 14.40, 'PAYABLE', po1_2);
            inv4.Number__c = 'INV-2812D';
            inv4.InvoiceReference__c = l_Accounts[1].ReferenceNumber__c +'INV-2812D' + POList[1].Name;
            //inv4.InvoiceReference__c = 'INV-2812D';
            l_Invoices.add(inv4);   

            Invoice__c inv5= TestFactory.createBodyshopInvoice('INV-2812E', 24.40, 'PAYABLE', so1);
            inv5.Number__c = 'INV-2812E';
            //inv5.InvoiceReference__c = l_Accounts[0].ReferenceNumber__c +'INV-2812E';
            inv5.InvoiceReference__c = 'INV-2812E';
            l_Invoices.add(inv5);  

            Invoice__c inv6= TestFactory.createBodyshopInvoice('INV-2812F', 24.40, 'PAYABLE', so2);
            inv6.Number__c = 'INV-2812F';
            //inv6.InvoiceReference__c =l_Accounts[0].ReferenceNumber__c +'INV-2812F';
            inv6.InvoiceReference__c = 'INV-2812F';
            l_Invoices.add(inv6); 

            Invoice__c inv7= TestFactory.createBodyshopCreditNote('INV-2812G', 14.40, 'RECEIVED', so1);
            inv7.Number__c = 'INV-2812G';
            //inv7.InvoiceReference__c = l_Accounts[0].ReferenceNumber__c +'INV-2812G';
            inv7.InvoiceReference__c = 'INV-2812G';
            l_Invoices.add(inv7);  

            Invoice__c inv8= TestFactory.createBodyshopCreditNote('INV-2812H', 14.40, 'PAYABLE', so2);
            inv8.Number__c = 'INV-2812H';
            //inv8.InvoiceReference__c = l_Accounts[0].ReferenceNumber__c +'INV-2812H';
            inv8.InvoiceReference__c = 'INV-2812H';
            l_Invoices.add(inv8); 

            insert l_Invoices;  
            list<Invoice__c> invList1 = [Select Status__c, Number__c, InvoiceReference__c from Invoice__c where Assessment__c = :l_Assessments[0].Id];
            

            list<Invoice__c> invList2 = [Select Status__c, Number__c, InvoiceReference__c from Invoice__c where Assessment__c = :l_Assessments[1].Id];           
        }
    }

    static testMethod void testUpsertInvoiceSuccess() {
        system.debug('## start testUpsertInvoiceSuccess');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr = '[{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                req.httpMethod = 'POST';                
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;                
            test.stopTest();
            
            list<Invoice__c> invList = [Select Status__c, Number__c, InvoiceReference__c from Invoice__c where Assessment__c = :l_Assessments[0].Id];
            system.debug('##invList 1'+invList);
            //system.assertEquals(invList.size() , 7); 

            for(Invoice__c inv : invList){
                if(inv.Number__c == 'INV-2812A'){
                    //system.assertEquals(inv.Status__c , 'PAID'); 
                }
                if(inv.Number__c == 'INV-2812C'){
                    //system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
                if(inv.Number__c == 'INV-2812I'){
                    //system.assertEquals(inv.Status__c , 'RECEIVED'); 
                }
                if(inv.Number__c == 'INV-2812J'){
                    //system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
                if(inv.Number__c == 'INV-2812O'){
                    //system.assertEquals(inv.Status__c , 'PAID'); 
                }
                if(inv.Number__c == 'INV-2812E'){
                    //system.assertEquals(inv.Status__c , 'PAID'); 
                }
                if(inv.Number__c == 'INV-2812G'){
                    //system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
            }
        }
        system.debug('## end testUpsertInvoiceSuccess');
    }

    static testMethod void testUpsertInvoiceSuccessAsyn() {
        system.debug('## start testUpsertInvoiceSuccessAsyn');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr = '[{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                req.httpMethod = 'POST';
                req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;
                system.debug('## json:' +Json.toString());
                system.assertEquals(true, Json != null); 
            test.stopTest();

            list<Invoice__c> invList = [Select Status__c, Number__c, InvoiceReference__c from Invoice__c where Assessment__c = :l_Assessments[1].Id];
            system.debug('## invList:'+invList);
            system.assertEquals(invList.size() , 4); 
            for(Invoice__c inv : invList){
                if(inv.Number__c == 'INV-2812B'){
                    system.assertEquals(inv.Status__c , 'RECEIVED'); 
                }
                if(inv.Number__c == 'INV-2812D'){
                    //system.assertEquals(inv.Status__c , 'PAID'); 
                }
                if(inv.Number__c == 'INV-2812F'){
                    //system.assertEquals(inv.Status__c , 'PAID'); 
                }
                if(inv.Number__c == 'INV-2812H'){
                    //system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
            }                
        }
        system.debug('## end testUpsertInvoiceSuccessAsyn');
    }

    static testMethod void testUpsertInvoiceMissingFields() {
        system.debug('## start testUpsertInvoiceMissingFields');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr ='[{"OrderReference":"XXXXXX","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                system.debug('## jsonStr:'+jsonStr);
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;
                system.debug('## jsonStr testUpsertInvoiceMissingFields:'+Json.toString());
                system.assertEquals(true, Json.toString().contains('ErrorMessage'));            

            test.stopTest();
        }
        system.debug('## end testUpsertInvoiceMissingFields');
    }

    /*static testMethod void testUpsertInvoiceConversionErrors() {
        system.debug('## start testUpsertInvoiceConversionErrors');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr ='[{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":INV-2812A,"AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                
                req.httpMethod = 'POST';
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;
                system.assertEquals(false, Json.toString().contains('"ErrorMessage" : null')); 
            test.stopTest();
        }
        system.debug('## start testUpsertInvoiceConversionErrors');
    }*/

    static testMethod void testUpsertInvoiceSuccess30000(){
        system.debug('## start testUpsertInvoiceSuccess30000');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr ='[{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},';
                jsonStr +='{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812M","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":50.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812A","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812B","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812C","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812I","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[0].Name+'","InvoiceNumber":"INV-2812J","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+POList[1].Name+'","InvoiceNumber":"INV-2812D","AccountReference":"'+l_Accounts[1].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812E","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812F","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812G","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812H","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812K","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[0].Name+'","InvoiceNumber":"INV-2812L","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"PAYABLE","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                req.httpMethod = 'POST';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;
                system.assertEquals(true, jsonStr.length() > 30000); 
            test.stopTest();
        }
        system.debug('## end testUpsertInvoiceSuccess30000');
    }

    static testMethod void testUpsertInvoiceExceptionSO() {
        system.debug('## start testUpsertInvoiceExceptionSO');
        system.runAs(l_users[0]){ 
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest(); 
                String jsonStr = '[{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812O","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","EstimatedPaymentDate":"2015-04-13","Type":"CREDITNOTE","Status":"PAID","TotalNET":100.00,"TotalVAT":120.00,"VAT":20},{"OrderReference":"'+SOList[1].Name+'","InvoiceNumber":"INV-2812P","AccountReference":"'+l_Accounts[0].ReferenceNumber__c+'","InvoiceDate":"2015-04-13","InvoiceDueDate":"2015-04-13","InvoicePaymentDate":"2015-04-13","Type":"INVOICE","Status":"RECEIVED","TotalNET":100.00,"TotalVAT":120.00,"VAT":20}]';
                req.httpMethod = 'POST';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS); 
                req.requestURI = '/v1.0/upsertInvoices/*';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTUpsertInvoices.processResponse();
                Blob Json = RestContext.response.responseBody;
            test.stopTest();

           
                
            list<Invoice__c> invList = [Select Status__c, Number__c, InvoiceReference__c from Invoice__c where Assessment__c = :l_Assessments[1].Id];
            system.assertEquals(invList.size() , 4); 
            for(Invoice__c inv : invList){
                if(inv.Number__c == 'INV-2812B'){
                    system.assertEquals(inv.Status__c , 'RECEIVED'); 
                }
                if(inv.Number__c == 'INV-2812D'){
                    system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
                if(inv.Number__c == 'INV-2812F'){
                    system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
                if(inv.Number__c == 'INV-2812H'){
                    system.assertEquals(inv.Status__c , 'PAYABLE'); 
                }
            }
            system.debug('## json'+ Json.toString());
            system.assertEquals(true, Json.toString().contains('"ErrorMessage":"Invoices cannot be created for the following Sales Order: ')); 
            system.debug('## end testUpsertInvoiceExceptionSO');               
        }
    }
}