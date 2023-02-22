/*************************************************************************************
Class Name - ASPISBatchSendInvoiceCegedim_TEST
Version - 1.0
Created Date - 26 Feb 2015
Function - Test Class Class sending invoices with TECHToBeProcessedCegedim__c checked and  record type Distributor to Cegedim


Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             26/02/2016  Original Version
* Dourga U              27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/
@isTest
private class ASPISBatchSendInvoiceCegedim_TEST{
    /*static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    static list<Offer__c> l_Offers;
    static BusinessHours defaultHours;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;   
    
    
    static{
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
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ContactUser__c = l_users[0].Id;
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
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
            l_OrderLines.add(ol2);
            insert l_OrderLines; 

            Invoice__c inv1 = TestFactory.createBodyshopInvoice('test1', 10, 'SENT', l_SalesOrders[1]);
            inv1.TECHToBeProcessedCegedim__c= true;
            l_Invoices.add(inv1);
            Invoice__c cn1 = TestFactory.createBodyshopCreditNote('test1', 10, 'SENT', l_SalesOrders[1]);
           	cn1.TECHToBeProcessedCegedim__c= true;
            l_Invoices.add(cn1);
            insert l_Invoices; 
            
           Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off1.Invoice__c = inv1.Id;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            off2.CreditNote__c = cn1.Id;
            l_Offers.add(off2);
            insert l_Offers;
        }
    }

    @isTest static void TestSendInvoiceCegedim() {  
        system.runas(l_users[0]){  
            try{ 
	            Test.startTest(); 
	            Database.executeBatch(new ASPISBatchSendInvoiceCegedim(), 200);         
	            Test.stopTest(); 
	            System.assertEquals(false, [Select TECHToBeProcessedCegedim__c from Invoice__c where id =:l_Invoices[0].id].TECHToBeProcessedCegedim__c); 
        	}
	        catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
	            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
	                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage()); 
	        }            
        }//end runas 
    }

    @isTest static void testSchDeleteLog() {
		system.runas(l_users[0]){ 
			test.startTest();
				for(CronTrigger c : [Select Id From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'TestSCHSendInvoiceCegedim' and JobType = '7')]){ 
					System.abortJob(c.id);
				}	
				
				ASPISBatchSendInvoiceCegedimSCH  TestSCHSendInvoiceCegedim = new ASPISBatchSendInvoiceCegedimSCH();
				String sch = '0 0 0 * * ?';
				system.schedule('TestSCHSendInvoiceCegedim', sch, TestSCHSendInvoiceCegedim); 
				
				CronTrigger ct =[Select Id,CronExpression, TimesTriggered, NextFireTime From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'TestSCHSendInvoiceCegedim' and JobType = '7')];
				System.assertEquals('0 0 0 * * ?', ct.CronExpression);    
       			System.assertEquals(0, ct.TimesTriggered);
			test.stopTest();
		}
	}*/
}