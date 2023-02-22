/*************************************************************************************
Class Name - ASPISBatchSendInvoiceExponens_TEST
Version - 1.0
Created Date - 01 Dec 2015
Function - Test Class sending invoices with status Payable and  record type Distributor to Exponens every night

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             01/12/2015  Original Version
* Ashwina S             18/01/2016  Replace field TechToBeProcessed__c instead of TECH_InvoiceSentToExponens__c
* Shamina M             22/01/2016  case 1386 - business hours
* Dourga U              27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/
@isTest
private class ASPISBatchSendInvoiceExponens_TEST{
    /*static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    //Shamina M:case 1386 - reverted back to std business hours
    static BusinessHours defaultHours;
    //static BusinessHoursSetting__mdt bhs;    
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;
    
    
    static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Invoices = new list<Invoice__c>();
		l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();
        
        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
        
            // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ContactUser__c = l_users[0].Id;
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);    
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);  
        
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            l_Accounts.add(dist2);
            insert l_Accounts;
        
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
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
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'PAYABLE');
            po1_1.TechToBeProcessed__c = true;
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'PAYABLE');
            po1_2.TechToBeProcessed__c = true;            
            l_purchaseOrders.add(po1_2);                 
            insert l_purchaseOrders;
        
        
            // Create several orderlines.
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(50,po1_1, 'DELIVERED');
            l_OrderLines.add(ol1);
        
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(60,po1_1, 'DELIVERED');
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
        
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');           
            l_OrderLines.add(ol3);
        
            OrderLine__c ol4 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');           
            l_OrderLines.add(ol4);
            insert l_OrderLines;
        
            // Create several invoices.
            Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 4.40, 'PAYABLE', po1_1);
            inv1.TechToBeProcessed__c = true;
            l_Invoices.add(inv1);
        
            Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'PAYABLE', po1_2);
            inv2.TechToBeProcessed__c = true;
            l_Invoices.add(inv2);
            
            Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 4.40, 'PAYABLE', po1_1);
            inv3.TechToBeProcessed__c = true;
            l_Invoices.add(inv3);
        
            Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 4.40, 'PAYABLE', po1_2);
            inv4.TechToBeProcessed__c = true;
            l_Invoices.add(inv4);
            insert l_Invoices;
        
            // access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];
            //bhs = [select Id from BusinessHoursSetting__mdt where DeveloperName='DEFAULT'];

        
            // create countryCode
			CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
			l_cs_CountryCodeIngformation.add(countryCode1);
			CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);			
			countryCode2.URLInvoiceDistributor__c= 'xxxxx';
            countryCode2.LoginInvoiceDistributor__c = 'login';
            countryCode2.PasswordInvoiceDistributor__c = 'pwd';
			l_cs_CountryCodeIngformation.add(countryCode2);
            insert l_cs_CountryCodeIngformation; 
        }
    }
    
    public class WS_SendInvoices implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String responseHttp;
            //responseHttp = '[Endpoint=http://labo.vitemescomptes.fr:5000/applications/exponens/v1.0/updateDistributorInvoiceStatus, Method=POST]';
            responseHttp = '[{"User":"aspis","Password":"aspisVMC2423","Number":"51122","PO":"PO-63452","Status":"PAYABLE"},{"User":"aspis","Password":"aspisVMC2423","Number":"51122","PO":"PO-63452","Status":"PAYABLE"},{"User":"aspis","Password":"aspisVMC2423","Number":"51242","PO":"PO-63452","Status":"PAYABLE"}]';
            //responseHttp = '[{"diagnosis":{"id":1,"diagnosisDescKey":"diag.prospecting.mobility","subCategoryDescKey":"sub_category_full","version":"0.0.1"},"questionList":[{"id":961,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.repartition","relevanceLevel":0,"answerTypeId":1,"minValue":0,"maxValue":10000000},{"id":962,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice1","relevanceLevel":2,"answerTypeId":113}, {"id":1210,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice4","relevanceLevel":2,"answerTypeId":117}]}]';

            HttpResponse res = new HttpResponse();
            res.setBody(responseHttp);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    static testMethod void ASPISBatchSendInvoiceExponensTest() {    
        Test.setMock(HttpCalloutMock.class, new WS_SendInvoices()); 
        try{ 
            Test.startTest();
            Database.executeBatch(new ASPISBatchSendInvoiceExponens(), 200);         
            Test.stopTest(); 
            System.assertEquals(false, [Select TechToBeProcessed__c from Invoice__c where id =:l_Invoices[0].id].TechToBeProcessed__c); 
        }
        catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage()); 
        }       
    }*/
}