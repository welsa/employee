/***********************************************************************************************************
Trigger Name - TESTASPISBatchGenerateCSVBodyshopInvoice
Version - 1.0
Created Date - 18 NOV 2015
Function - Test Class for ASPISBatchGenerateCSVBodyshopInvoices

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Brayan  		30/11/2015 	Original Version
* Dourga    	19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
************************************************************************************************************/
@isTest
private class TESTASPISBatchGenerateCSVBodyshopInvoice {
/*
	static list<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_orderLines;
    static list<Offer__c> l_offers;
    static list<Invoice__c> l_invoices;
	static date myDate;
    static datetime myDateTime;
	
    
    static testMethod void myUnitTest() {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_orderLines = new list<OrderLine__c>();
        l_offers = new list<Offer__c>();
        l_invoices = new list<Invoice__c>();
        
		l_users = new list<User>{ new User(Username = 'jb@test.com',
                                         LastName = 'Ballack',
                                         FirstName = 'Jean',
                                         Email = 'Jean@test.com',
                                         Alias = 'JBAL',
                                         LanguageLocaleKey = 'en_US',
                                         TimeZoneSidKey = 'Europe/Dublin',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
                                         ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        //insert users;
        ASPISTestUtils.generateTestUsers(l_users);

			myDateTime = datetime.newInstance(2015, 2, 17);
			myDate = date.newInstance(2015, 2, 17);

            // Create several Bodyshops and Distributors.
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            l_Accounts.add(dist2);            
			ASPISTestUtils.generateAccount(l_Accounts);

            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
			ass1.TECH_EntityCountryCode__c = 'ES';
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
			ass2.TECH_EntityCountryCode__c = 'ES';
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
			ass3.TECH_EntityCountryCode__c = 'ES';
            l_Assessments.add(ass3);            
            ASPISTestUtils.generateAssessment(l_Assessments);

            // Create severals Sales Orders
            MAP<Id, PrerequisiteOrder__c> m_ID2SalesOrder = new MAP<Id, PrerequisiteOrder__c>();
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so2);
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs1, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so3);            
            ASPISTestUtils.generatePrerequisiteOrder(l_SalesOrders);
            for(PrerequisiteOrder__c so : l_SalesOrders){
                m_ID2SalesOrder.put(so.Id, so);
            }

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_1);
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_2);
            PurchaseOrder__c po2_1 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po2_1);
            PurchaseOrder__c po2_2 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po2_2);
            PurchaseOrder__c po3 = TestFactory.createPurchaseOrder(ass2, so3, bs1, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po3);			
			ASPISTestUtils.generatePurchaseOrder(l_purchaseOrders);
            
            // Create Several Order Lines for each Purchase Orders
            MAP<PurchaseOrder__c, List<OrderLine__c>> m_PO2ListOrderlines = new MAP<PurchaseOrder__c, List<OrderLine__c>>();
            for(PurchaseOrder__c po : l_purchaseOrders){
                OrderLine__c ol1 = TestFactory.createOrderLineFinal(100, po, 'DELIVERED');
                OrderLine__c ol2 = TestFactory.createOrderLineFinal(120, po, 'DELIVERED');
                
                if(!m_PO2ListOrderlines.containsKey(po)){
                    m_PO2ListOrderlines.put(po, new List<OrderLine__c>{ol1, ol2});
                }
                
                l_orderLines.add(ol1);
                l_orderLines.add(ol2);
            }
            ASPISTestUtils.generateOrderLine(l_orderLines);
             
            // Create several offers for each sales order.
            for(PurchaseOrder__c po : l_purchaseOrders){
                for(OrderLine__c ol : m_PO2ListOrderlines.get(po)){
                    Offer__c off = TestFactory.createOfferLine(ol, m_ID2SalesOrder.get(po.PrerequisiteOrder__c), 'DELIVERED');
                    l_offers.add(off);                    
                }
            }
            ASPISTestUtils.generateOffer(l_offers);
            
            // Create several invoices for each sales order            
            List<PrerequisiteOrder__c> l_SOwithListOffers = [SELECT Id, TECH_BodyshopCountryCode__c, Assessment__c, BodyShop__c, (SELECT Id, BSTotalPrice__c FROM Offers__r) FROM PrerequisiteOrder__c WHERE Id in :l_SalesOrders];
            for(PrerequisiteOrder__c so : l_SOwithListOffers){
                Decimal invTotalNet = 0;
                for(Offer__c off : so.Offers__r){
                    invTotalNet += off.BSTotalPrice__c;
                }
                Invoice__c inv = TestFactory.createBodyshopInvoice('INV1212', invTotalNet, 'SENT', so);
                Invoice__c creditnote = TestFactory.createBodyshopCreditNote('CRED1212', 20, 'SENT', so);
                
                
                l_invoices.add(inv);
                l_invoices.add(creditnote);
            } 
            ASPISTestUtils.generateInvoice(l_invoices);
        
		Test.startTest();
        //system.debug('#####CLACLA '+l_SOwithListOffers);
        ASPISBatchGenerateCSVBodyshopInvoices bc = new ASPISBatchGenerateCSVBodyshopInvoices();
        bc.query += ' LIMIT 200';  
        List<invoice__c> results = Database.query(bc.query);
        //system.debug('#####CLACLA '+results);
        Database.executeBatch(bc, 200);
        Test.stopTest();
        
		List<ContentVersion> l_contentVersionResults = [SELECT Id FROM ContentVersion];
		System.assertEquals(1,l_contentVersionResults.size());
	}*/
}