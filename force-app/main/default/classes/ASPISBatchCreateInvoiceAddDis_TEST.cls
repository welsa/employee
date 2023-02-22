/*************************************************************************************
Class Name - ASPISBatchCreateInvoiceAddDis_TEST
Version - 1.0
Created Date - 23 Feb 2016
Function - Test Class for ASPISBatchCreateInvoiceAddDis

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------            ----------   -----------------------  
* Ashwina S             23/02/2016   Original Version
* ABT					21-APR-2016	 Completed code coverage
* ABT					17-JAN-2017	 Changed AdditionnalDiscount__c to AdditionalDiscountAmount__c
*************************************************************************************/
@isTest
private class ASPISBatchCreateInvoiceAddDis_TEST{
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    static list<Offer__c> l_Offers;
    //Shamina M:case 1386 - reverted back to std business hours
    static BusinessHours defaultHours;
    //static BusinessHoursSetting__mdt bhs;    
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;

	// ABT 01-APR-2016 C-001581
	static List<CaseDetailsProcessMapping__c> caseMappingList = TestFactory.createCaseDetailsProcessMapping();
    
    static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Offers = new list<Offer__c>();
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
            bs1.BillingCity='Nimes';
			bs1.BillingCountry='France';
			bs1.BillingStreet='st martin de chez yvone';
			bs1.BillingPostalCode='12345';
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.BillingCity='Nimes';
			bs2.BillingCountry='France';
			bs2.BillingStreet='st martin de chez yvone';
			bs2.BillingPostalCode='12345';
            l_Accounts.add(bs2);   

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs3.BillingCity='Nimes';
			bs3.BillingCountry='France';
			bs3.BillingStreet='st martin de chez yvone';
			bs3.BillingPostalCode='12345';
            l_Accounts.add(bs3);    
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);  
        
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            l_Accounts.add(dist2);
            insert l_Accounts;        
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.TECH_EntityCountryCode__c= 'ES';
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            l_Assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);   

            Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs3);
            l_Assessments.add(ass4);    
			
			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs3);
            l_Assessments.add(ass5);     
            insert l_Assessments;
        
            
            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, 'INDELIVERY');
            so1.TechIsInvoiced__c = true;
            l_SalesOrders.add(so1);
        
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'INDELIVERY');
            so2.TechIsInvoiced__c = true;
            l_SalesOrders.add(so2);
            
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass1, bs1, 'PREORDERCONFIRMED');
            so3.TechIsInvoiced__c = true;
            l_SalesOrders.add(so3);

            PrerequisiteOrder__c so4 = TestFactory.createSalesOrder(ass1, bs3, 'INDELIVERY');
            so4.TechIsInvoiced__c = true;
            l_SalesOrders.add(so4);

            PrerequisiteOrder__c so5 = TestFactory.createSalesOrder(ass4, bs3, 'PREORDERCONFIRMED');
            so5.TechIsInvoiced__c = true;
            l_SalesOrders.add(so5);

            PrerequisiteOrder__c so6 = TestFactory.createSalesOrder(ass4, bs3, 'PREORDERCONFIRMED');
            so6.TechIsInvoiced__c = true;
            l_SalesOrders.add(so6);

			PrerequisiteOrder__c so7 = TestFactory.createSalesOrder(ass5, bs3, 'PREORDERCONFIRMED');
            so7.TechIsInvoiced__c = true;
            l_SalesOrders.add(so7);
       
            insert l_SalesOrders;
        

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'INDELIVERY');
            po1_1.BodyShopOrderNumber__c = '2812';
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'INDELIVERY');
            po1_2.BodyShopOrderNumber__c = '2813';           
            l_purchaseOrders.add(po1_2); 

            PurchaseOrder__c po1_3 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist2, 'INDELIVERY');
            po1_3.BodyShopOrderNumber__c = '2814';
            l_purchaseOrders.add(po1_3);
        
            PurchaseOrder__c po1_4 = TestFactory.createPurchaseOrder(ass2, so2, bs3, dist2, 'INDELIVERY');
            po1_4.BodyShopOrderNumber__c = '2815';             
            l_purchaseOrders.add(po1_4);  
            
            PurchaseOrder__c po1_5 = TestFactory.createPurchaseOrder(ass2, so3, bs2, dist2, 'INDELIVERY');
            po1_5.BodyShopOrderNumber__c = '2816';             
            l_purchaseOrders.add(po1_5);  

            PurchaseOrder__c po1_6 = TestFactory.createPurchaseOrder(ass2, so4, bs2, dist2, 'INDELIVERY');
            po1_6.BodyShopOrderNumber__c = '2817';             
            l_purchaseOrders.add(po1_6);  
			
			// ABT 01-APR-2016 C-001581
			PurchaseOrder__c po1_7 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED);
            po1_7.BodyShopOrderNumber__c = '2818';
            l_purchaseOrders.add(po1_7);

			PurchaseOrder__c po1_8 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, ASPISConstants.PUR_ORDER_STATUS_PAYABLE);
            po1_8.BodyShopOrderNumber__c			= '2819';
            po1_8.HasCaseForAdditionalDiscount__c	= true;
            l_purchaseOrders.add(po1_8);
			
			// Checking for france that it does not create the case
			PurchaseOrder__c po1_9 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist2, ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED);
            po1_9.BodyShopOrderNumber__c = '2820';
            l_purchaseOrders.add(po1_9);

            PurchaseOrder__c po1_10 = TestFactory.createPurchaseOrder(ass4, so5, bs3, dist2, 'INDELIVERY');
            po1_10.BodyShopOrderNumber__c = '2821';             
            l_purchaseOrders.add(po1_10);  

            PurchaseOrder__c po1_11 = TestFactory.createPurchaseOrder(ass4, so6, bs3, dist2, 'INDELIVERY');
            po1_11.BodyShopOrderNumber__c = '2822';             
            l_purchaseOrders.add(po1_11); 

            PurchaseOrder__c po1_12 = TestFactory.createPurchaseOrder(ass1, so3, bs1, dist1, 'INDELIVERY');
            po1_12.BodyShopOrderNumber__c = '2823';             
            l_purchaseOrders.add(po1_12);  

			PurchaseOrder__c po1_13 = TestFactory.createPurchaseOrder(ass5, so7, bs3, dist1, 'INDELIVERY');
            po1_12.BodyShopOrderNumber__c = '2824';             
            l_purchaseOrders.add(po1_13);  

            insert l_purchaseOrders;
        
        
            
            // Create several orderlines.
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(50,po1_1, 'INDELIVERY');
            ol1.TECH_ToBeProcessed__c = true;
            ol1.AdditionalDiscountAmount__c = 5;
            ol1.PreviousAdditionalDiscountAmount__c = 5;
            l_OrderLines.add(ol1);      
        
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(60,po1_1, 'INDELIVERY');
            ol2.TECH_ToBeProcessed__c = true;
            ol2.AdditionalDiscountAmount__c = -2;    
            ol2.PreviousAdditionalDiscountAmount__c = 5;        
            l_OrderLines.add(ol2);
        
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(70,po1_2, 'INDELIVERY');   
            ol3.TECH_ToBeProcessed__c = true; 
            ol3.AdditionalDiscountAmount__c = -10; 
            ol3.PreviousAdditionalDiscountAmount__c = -5;                   
            l_OrderLines.add(ol3);   
        
            OrderLine__c ol4 = TestFactory.createOrderLineFinal(70,po1_2, 'INDELIVERY');     
            ol4.TECH_ToBeProcessed__c = true;    
            ol4.AdditionalDiscountAmount__c = 5;  
            ol4.PreviousAdditionalDiscountAmount__c = 2;            
            l_OrderLines.add(ol4);

            OrderLine__c ol5 = TestFactory.createOrderLineFinal(50,po1_3, 'INDELIVERY');
            ol5.TECH_ToBeProcessed__c = true;
            ol5.AdditionalDiscountAmount__c = -5;
            l_OrderLines.add(ol5);
        
            OrderLine__c ol6 = TestFactory.createOrderLineFinal(60,po1_3, 'INDELIVERY');
            ol6.TECH_ToBeProcessed__c = true;
            ol6.AdditionalDiscountAmount__c = -2;            
            l_OrderLines.add(ol6);
        
            OrderLine__c ol7 = TestFactory.createOrderLineFinal(70,po1_4, 'INDELIVERY');   
            ol7.TECH_ToBeProcessed__c = true; 
            ol7.AdditionalDiscountAmount__c = 10;                   
            l_OrderLines.add(ol7);
        
            OrderLine__c ol8 = TestFactory.createOrderLineFinal(70,po1_4, 'INDELIVERY');     
            ol8.TECH_ToBeProcessed__c = true;    
            ol8.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol8);
            
            OrderLine__c ol11 = TestFactory.createOrderLineFinal(50,po1_5, 'INDELIVERY');
            ol11.TECH_ToBeProcessed__c = true;
            ol11.AdditionalDiscountAmount__c = 5;
            l_OrderLines.add(ol11);      
        
            OrderLine__c ol12 = TestFactory.createOrderLineFinal(60,po1_5, 'INDELIVERY');
            ol12.TECH_ToBeProcessed__c = true;
            ol12.AdditionalDiscountAmount__c = -2;            
            l_OrderLines.add(ol12);
        
            OrderLine__c ol13 = TestFactory.createOrderLineFinal(70,po1_5, 'INDELIVERY');   
            ol13.TECH_ToBeProcessed__c = true; 
            ol13.AdditionalDiscountAmount__c = -10;                    
            l_OrderLines.add(ol13);   
        
            OrderLine__c ol14 = TestFactory.createOrderLineFinal(70,po1_6, 'INDELIVERY');     
            ol14.TECH_ToBeProcessed__c = true;    
            ol14.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol14);

            OrderLine__c ol15 = TestFactory.createOrderLineFinal(50,po1_6, 'INDELIVERY');
            ol15.TECH_ToBeProcessed__c = true;
            ol15.AdditionalDiscountAmount__c = -5;
            l_OrderLines.add(ol15);
        
            OrderLine__c ol16 = TestFactory.createOrderLineFinal(60,po1_3, 'INDELIVERY');
            ol16.TECH_ToBeProcessed__c = true;
            ol16.AdditionalDiscountAmount__c = -2;            
            l_OrderLines.add(ol16);
        
            OrderLine__c ol17 = TestFactory.createOrderLineFinal(70,po1_4, 'INDELIVERY');   
            ol17.TECH_ToBeProcessed__c = true; 
            ol17.AdditionalDiscountAmount__c = 10;                   
            l_OrderLines.add(ol17);
        
            OrderLine__c ol18 = TestFactory.createOrderLineFinal(70,po1_2, 'INDELIVERY');     
            ol18.TECH_ToBeProcessed__c = true;    
            ol18.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol18);

			// ABT 01-APR-2016 C-001581
			OrderLine__c ol19 = TestFactory.createOrderLineFinal(70, po1_7, 'INDELIVERY');     
            ol19.TECH_ToBeProcessed__c = true;    
            ol19.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol19);

			OrderLine__c ol20 = TestFactory.createOrderLineFinal(70, po1_8, 'INDELIVERY');     
            ol20.TECH_ToBeProcessed__c = true;    
            ol20.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol20);

			OrderLine__c ol21 = TestFactory.createOrderLineFinal(70, po1_9, 'INDELIVERY');     
            ol21.TECH_ToBeProcessed__c = true;    
            ol21.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol21);

            OrderLine__c ol22 = TestFactory.createOrderLineFinal(70, po1_10, 'INDELIVERY');     
            ol22.TECH_ToBeProcessed__c = true;    
            l_OrderLines.add(ol22);

            OrderLine__c ol23 = TestFactory.createOrderLineFinal(70, po1_10, 'INDELIVERY');     
            ol23.TECH_ToBeProcessed__c = true;  
            ol23.PreviousAdditionalDiscountAmount__c = 10;     
            ol23.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol23);

            OrderLine__c ol24 = TestFactory.createOrderLineFinal(70, po1_10, 'INDELIVERY');     
            ol24.TECH_ToBeProcessed__c = true;
            ol24.PreviousAdditionalDiscountAmount__c = 2;  
            ol24.AdditionalDiscountAmount__c = 5;              
            l_OrderLines.add(ol24);


            OrderLine__c ol25 = TestFactory.createOrderLineFinal(70, po1_11, 'INDELIVERY');     
            ol25.TECH_ToBeProcessed__c = true;  
            ol25.PreviousAdditionalDiscountAmount__c = 10;     
            ol25.AdditionalDiscountAmount__c = 15;              
            l_OrderLines.add(ol25);

            OrderLine__c ol26 = TestFactory.createOrderLineFinal(70, po1_11, 'INDELIVERY');     
            ol26.TECH_ToBeProcessed__c = true;    
            l_OrderLines.add(ol26);

            OrderLine__c ol27 = TestFactory.createOrderLineFinal(50,po1_12, 'INDELIVERY');
            ol27.TECH_ToBeProcessed__c = true;
            ol27.AdditionalDiscountAmount__c = -5;
            ol27.PreviousAdditionalDiscountAmount__c = 8;
            l_OrderLines.add(ol27);      
        
            OrderLine__c ol28 = TestFactory.createOrderLineFinal(60,po1_12, 'INDELIVERY');
            ol28.TECH_ToBeProcessed__c = true;
        /*    ol28.AdditionalDiscountAmount__c = 5;    
            ol28.PreviousAdditionalDiscountAmount__c = 8; */       
            l_OrderLines.add(ol28);
        

            OrderLine__c ol29 = TestFactory.createOrderLineFinal(60,po1_12, 'INDELIVERY');
            ol29.TECH_ToBeProcessed__c = true;
        /*    ol28.AdditionalDiscountAmount__c = 5;    
            ol28.PreviousAdditionalDiscountAmount__c = 8; */       
            l_OrderLines.add(ol29);

			OrderLine__c ol30 = TestFactory.createOrderLineFinal(60, po1_13, 'INDELIVERY');
            ol30.TECH_ToBeProcessed__c = true;    
            l_OrderLines.add(ol30);

			OrderLine__c ol31 = TestFactory.createOrderLineFinal(60, po1_13, 'INDELIVERY');
            ol31.TECH_ToBeProcessed__c = true;    
            l_OrderLines.add(ol31);
         

            insert l_OrderLines;

            Invoice__c inv1 = TestFactory.createBodyshopInvoice('test1', 10, 'SENT', so1);
            l_Invoices.add(inv1);
            Invoice__c cn1 = TestFactory.createBodyshopCreditNote('test1', 10, 'SENT', so1);
            l_Invoices.add(cn1);
            insert l_Invoices; 

            //create offers
            Offer__c offer1 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            offer1.CreditNote__c= l_Invoices[1].id;
            l_Offers.add(offer1);

            Offer__c offer2 = TestFactory.createOfferLine(ol2, so1, 'DELIVERED');
            offer2.Invoice__c= l_Invoices[0].id;
            l_Offers.add(offer2);

            Offer__c offer3 = TestFactory.createOfferLine(ol3, so1, 'DELIVERED');
            l_Offers.add(offer3);

            Offer__c offer4= TestFactory.createOfferLine(ol4, so1, 'DELIVERED');
            l_Offers.add(offer4);

            Offer__c offer5 = TestFactory.createOfferLine(ol5, so2, 'DELIVERED');
            l_Offers.add(offer5);

            Offer__c offer6 = TestFactory.createOfferLine(ol6, so2, 'DELIVERED');
            l_Offers.add(offer6);

            Offer__c offer7 = TestFactory.createOfferLine(ol7, so2, 'DELIVERED');
            l_Offers.add(offer7);

            Offer__c offer8= TestFactory.createOfferLine(ol8, so2, 'DELIVERED');
            l_Offers.add(offer8);
            
            Offer__c offer11 = TestFactory.createOfferLine(ol1, so1, 'DELIVERED');
            l_Offers.add(offer11);

            Offer__c offer12 = TestFactory.createOfferLine(ol2, so1, 'DELIVERED');
            l_Offers.add(offer12);

            Offer__c offer13 = TestFactory.createOfferLine(ol3, so1, 'DELIVERED');
            l_Offers.add(offer13);

            Offer__c offer14= TestFactory.createOfferLine(ol14, so3, 'DELIVERED');
            l_Offers.add(offer14);

            Offer__c offer15 = TestFactory.createOfferLine(ol5, so4, 'DELIVERED');
            l_Offers.add(offer15);

            Offer__c offer16 = TestFactory.createOfferLine(ol6, so4, 'DELIVERED');
            l_Offers.add(offer16);

            Offer__c offer17 = TestFactory.createOfferLine(ol7, so3, 'DELIVERED');
            l_Offers.add(offer17);

            Offer__c offer18= TestFactory.createOfferLine(ol8, so3, 'DELIVERED');
            l_Offers.add(offer18);

			// ABT 01-APR-2016 C-001581
			Offer__c offer19= TestFactory.createOfferLine(ol19, so1, 'INDELIVERY');
            l_Offers.add(offer19);

			Offer__c offer20= TestFactory.createOfferLine(ol20, so1, 'INDELIVERY');
            l_Offers.add(offer20);

			Offer__c offer21= TestFactory.createOfferLine(ol21, so2, 'INDELIVERY');
            l_Offers.add(offer21);

            Offer__c offer22= TestFactory.createOfferLine(ol22, so5, 'CANCELED');
            l_Offers.add(offer22);

            Offer__c offer23= TestFactory.createOfferLine(ol23, so5, 'DELIVERED');
            l_Offers.add(offer23);

            Offer__c offer24= TestFactory.createOfferLine(ol24, so5, 'DELIVERED');
            l_Offers.add(offer24);

            Offer__c offer25= TestFactory.createOfferLine(ol25, so6, 'DELIVERED');
            l_Offers.add(offer25);

            Offer__c offer26= TestFactory.createOfferLine(ol26, so6, 'CANCELED');
            l_Offers.add(offer26);

            Offer__c offer27= TestFactory.createOfferLine(ol27, so3, 'DELIVERED');
            l_Offers.add(offer27);

            Offer__c offer28= TestFactory.createOfferLine(ol28, so3, 'CANCELED');
            l_Offers.add(offer28);

            Offer__c offer29= TestFactory.createOfferLine(ol29, so3, 'CANCELED');
            l_Offers.add(offer29);

			Offer__c offer30 = TestFactory.createOfferLine(ol30, so7, 'DELIVERED');
            l_Offers.add(offer30);

			Offer__c offer31 = TestFactory.createOfferLine(ol31, so7, 'CANCELED');
            l_Offers.add(offer31);

            insert l_Offers;
        
      
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

            CountryCodeInformationsMapping__c countryCode3 = TestFactory.createCountryCodeInformationsMapping('ES',defaultHours.id);            
            countryCode3.URLInvoiceDistributor__c= 'xxxxx';
            countryCode3.LoginInvoiceDistributor__c = 'login';
            countryCode3.PasswordInvoiceDistributor__c = 'pwd';
            countryCode3.NeedInvoiceDetail__c=true;
            l_cs_CountryCodeIngformation.add(countryCode3);
            
            insert l_cs_CountryCodeIngformation; 

			// ABT 01-APR-2016 C-001581
			insert caseMappingList;
        }
    }
    
    static testMethod void ASPISBatchCreateInvoiceAddDisTest() {    
       try{ 
            Test.startTest();
            Account paymentAcc = TestFactory.createAccountPayment('Payment', 'FR');
            insert paymentAcc;   

            l_Offers[17].DeliveryStatus__c = 'CANCELED';
            update l_Offers[17];       
            
            Database.executeBatch(new ASPISBatchCreateInvoiceAddDis(), 200);         
            Test.stopTest(); 
            System.assertEquals(false, [Select TECH_ToBeProcessed__c from OrderLine__c where id =:l_OrderLines[0].id].TECH_ToBeProcessed__c); 
            //system.debug('###### Inv:'+[Select id from Invoice__c where PurchaseOrder__c =:l_purchaseOrders[0].id]); 
            //System.assertEquals(2, [Select id from Invoice__c where PurchaseOrder__c =:l_purchaseOrders[0].id].size()); 

			// ABT 01-APR-2016 C-001581
			List<PurchaseOrder__c> purchaseOrderTriggeringCaseGeneration = new List<PurchaseOrder__c>
			{
				// ES Case generating case
				l_purchaseOrders[6],
				// ES Case that does not generate case due to its flag
				l_purchaseOrders[7],
				// FR Case should not generate case
				l_purchaseOrders[8]
			};
            System.assertEquals(1, [Select Id from Case__c WHERE Purchase_order__c IN: purchaseOrderTriggeringCaseGeneration].size()); 
        }
        catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage()); 
        } 
    }
    
    static testMethod void ASPISBatchCreateInvoiceAddDisSCHTest() {    
       system.runas(l_users[0]){ 
            test.startTest();
                for(CronTrigger c : [Select Id From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'TestCreateInvoiceAddDis' and JobType = '7')]){ 
                    System.abortJob(c.id);
                }   
                
                ASPISBatchCreateInvoiceAddDisSCH TestCreateInvoiceAddDis = new ASPISBatchCreateInvoiceAddDisSCH();
                String sch = '0 0 0 * * ?';
                system.schedule('TestCreateInvoiceAddDis', sch, TestCreateInvoiceAddDis); 
                
                CronTrigger ct =[Select Id,CronExpression, TimesTriggered, NextFireTime From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'TestCreateInvoiceAddDis' and JobType = '7')];
                System.assertEquals('0 0 0 * * ?', ct.CronExpression);    
                System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
        }     
    }
}