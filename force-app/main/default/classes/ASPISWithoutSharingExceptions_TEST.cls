/*************************************************************************************
Class Name - ASPISWithoutSharingExceptions_TEST
Version - 1.0
Created Date - 02 MARCH 2015
Function - TestClass to ASPISWithoutSharingExceptions

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      02/03/2016  Reworked Version
* Abdool M      30/10/2018  Case C-002045 - Advance case management
*************************************************************************************/
@isTest
private class ASPISWithoutSharingExceptions_TEST {
    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    static list<Offer__c> l_Offers;
    static BusinessHours defaultHours;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;
    static List<CaseDetailsProcessMapping__c> caseMappingList;
    static list<PartList__c> lstPartList;
    
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
        defaultHours =[select Id,Name from BusinessHours where IsDefault=true];
        
        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        user1.BypassValidationRules__c = true;
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){
            caseMappingList = TestFactory.createCaseDetailsProcessMapping();

            caseMappingList.add(new CaseDetailsProcessMapping__c(Name='ES-PO-DeliveryProblem',
                                                                Description__c='test desc', 
                                                                Due_Date_Duration__c=1, 
                                                                Due_Date_Unity__c='D', 
                                                                Origin__c='APPLICATION', 
                                                                Priority__c='HIGH', 
                                                                Reason__c='DELIVERY', 
                                                                Short_Description__c='test short desc', 
                                                                Subject__c='incidencia en pieza', 
                                                                Type__c='PROBLEM',
                                                                Active__c=true));
            
            insert caseMappingList;

            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
        
             // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            l_Accounts.add(bs2);   

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', '');
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
            insert l_Assessments;
        
            
            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(l_Assessments[0], bs1, 'INDELIVERY');
            so1.SLAInDeliveryLevel3__c = System.today();
            so1.Status__c = ASPISConstants.PRE_ORDER_STATUS_MANAGED;

            l_SalesOrders.add(so1);
        
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'INDELIVERY');
            so2.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so2);
            
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass1, bs1, 'DELIVERED');
            so3.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so3);

            PrerequisiteOrder__c so4 = TestFactory.createSalesOrder(ass1, bs3, 'DELIVERED');
            so4.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so4);
       
            insert l_SalesOrders;
        

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'ISSUED');
            po1_1.BodyShopOrderNumber__c = '2812';
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'ISSUED');
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
            insert l_purchaseOrders;
        
        
            
            // Create several orderlines.
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(50,po1_1, 'INDELIVERY');
            ol1.TECH_ToBeProcessed__c = true;
            ol1.AdditionalDiscountAmount__c = 5;
            insert ol1;
            //l_OrderLines.add(ol1);      
        
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(60,po1_1, 'INDELIVERY');
            ol2.TECH_ToBeProcessed__c = true;
            ol2.AdditionalDiscountAmount__c = -2;            
            l_OrderLines.add(ol2);
        
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(70,po1_2, 'INDELIVERY');   
            ol3.TECH_ToBeProcessed__c = true; 
            ol3.AdditionalDiscountAmount__c = -10;                    
            l_OrderLines.add(ol3);   
        
            OrderLine__c ol4 = TestFactory.createOrderLineFinal(70,po1_2, 'INDELIVERY');     
            ol4.TECH_ToBeProcessed__c = true;    
            ol4.AdditionalDiscountAmount__c = 5;              
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
            //insert l_OrderLines;

            //create offers
            Offer__c offer1 = TestFactory.createOfferLine(ol1, so1, 'INDELIVERY');
            l_Offers.add(offer1);

            Offer__c offer2 = TestFactory.createOfferLine(ol2, so1, 'INDELIVERY');
            l_Offers.add(offer2);

            Offer__c offer3 = TestFactory.createOfferLine(ol3, so1, 'INDELIVERY');
            l_Offers.add(offer3);

            Offer__c offer4= TestFactory.createOfferLine(ol4, so1, 'INDELIVERY');
            l_Offers.add(offer4);

            Offer__c offer5 = TestFactory.createOfferLine(ol5, so2, 'INDELIVERY');
            l_Offers.add(offer5);

            Offer__c offer6 = TestFactory.createOfferLine(ol6, so2, 'INDELIVERY');
            l_Offers.add(offer6);

            Offer__c offer7 = TestFactory.createOfferLine(ol7, so2, 'INDELIVERY');
            l_Offers.add(offer7);

            Offer__c offer8= TestFactory.createOfferLine(ol8, so2, 'INDELIVERY');
            l_Offers.add(offer8);
            
            Offer__c offer11 = TestFactory.createOfferLine(ol1, so1, 'INDELIVERY');
            l_Offers.add(offer11);

            Offer__c offer12 = TestFactory.createOfferLine(ol2, so1, 'INDELIVERY');
            l_Offers.add(offer12);

            Offer__c offer13 = TestFactory.createOfferLine(ol3, so1, 'INDELIVERY');
            l_Offers.add(offer13);

            Offer__c offer14= TestFactory.createOfferLine(ol14, so3, 'INDELIVERY');
            l_Offers.add(offer14);

            Offer__c offer15 = TestFactory.createOfferLine(ol5, so4, 'INDELIVERY');
            l_Offers.add(offer15);

            Offer__c offer16 = TestFactory.createOfferLine(ol6, so4, 'INDELIVERY');
            l_Offers.add(offer16);

            Offer__c offer17 = TestFactory.createOfferLine(ol7, so3, 'INDELIVERY');
            l_Offers.add(offer17);

            Offer__c offer18= TestFactory.createOfferLine(ol8, so3, 'INDELIVERY');
            l_Offers.add(offer18);
            //insert l_Offers;

            lstPartList = new list <PartList__c>{
				TestFactory.createPartList(l_Assessments[0])
			};
               

			lstPartList[0].TECH_OriginalPart__c = 'Ass1Part1';
			lstPartList[0].ProducerName__c = 'VW';
			lstPartList[0].Quantity__c = 15;
			lstPartList[0].RecordtypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
			lstPartList[0].PartNumber__c = '76TYGD90anJWXs';
			lstPartList[0].TechCheckForSubstitute__c = true;
			insert lstPartList;
        }
    }

    static testMethod void testupdateAssessmentList(){
        System.Debug('>>> Start testupdateAssessmentList');

        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.updateAssessmentList(l_Assessments);
            test.stoptest();
        }
        system.assertEquals(3 , [select Id from Assessment__c where Id in: l_Assessments].size());
        System.Debug('>>> End testupdateAssessmentList');
    }

    static testMethod void testgetAssessmentsPOChildren(){
        System.Debug('>>> Start testgetAssessmentsPOChildren'); 
        set <Id> assId = new set<Id>();
        List<Assessment__c> assList = new List<Assessment__c>();
        for (Assessment__c asmt : l_Assessments){
            assId.add(asmt.Id);
        }
        system.runas(l_users[0]){
            test.starttest();
                assList = ASPISWithoutSharingExceptions.getAssessmentsPOChildren(assId);
            test.stoptest();
        }
        system.assertEquals(3 , assList.size());
        System.Debug('>>> End testgetAssessmentsPOChildren');
    }

    static testMethod void testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder(){
        System.Debug('>>> Start testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder'); 
        List<PurchaseOrder__c> poList = new List<PurchaseOrder__c>();
        system.runas(l_users[0]){
            test.starttest();
                poList = ASPISWithoutSharingExceptions.getPurchaseOrderAndOrderLinesRegardingThisSalesOrder(l_SalesOrders[1].Id);
            test.stoptest();
        }
        system.assertEquals(2 ,poList.size());
        System.Debug('>>> End testgetPurchaseOrderAndOrderLinesRegardingThisSalesOrder');
    }

    static testMethod void testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders(){
        System.Debug('>>> Start testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders');  
        Map<Id,List<PurchaseOrder__c>> m_SalesOrderId2ListPurchaseOrders = new Map<Id,List<PurchaseOrder__c>>();
        List<Id> listSalesOrdersID = new List<Id>();
        for (PrerequisiteOrder__c so : l_SalesOrders){
            listSalesOrdersID.add(so.Id);
        }
        system.runas(l_users[0]){
            test.starttest();
                m_SalesOrderId2ListPurchaseOrders = ASPISWithoutSharingExceptions.getPurchaseOrderAndOrderLinesRegardingListOfSalesOrders(listSalesOrdersID);
            test.stoptest();
        }
        system.assertEquals(1 , m_SalesOrderId2ListPurchaseOrders.size());
        System.Debug('>>> End testgetPurchaseOrderAndOrderLinesRegardingListOfSalesOrders');
    }

    static testMethod void getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(){
        System.Debug('>>> Start getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders');  
        List<PrerequisiteOrder__c> salesOrderList = new List<PrerequisiteOrder__c>();
        List<Id> listSalesOrdersID = new List<Id>();
        for (PrerequisiteOrder__c so : l_SalesOrders){
            listSalesOrdersID.add(so.Id);
        }
        system.runas(l_users[0]){
            test.starttest();
                salesOrderList = ASPISWithoutSharingExceptions.getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(listSalesOrdersID);
            test.stoptest();
        }
        system.assertEquals(4 , salesOrderList.size());
        System.Debug('>>> End getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders');
    }

    static testMethod void testupdatePurchaseOrderList(){
        System.Debug('>>> Start testupdatePurchaseOrderList');  
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.updatePurchaseOrderList(l_purchaseOrders);
            test.stoptest();
        }
        system.assertEquals(6 ,l_purchaseOrders.size());
        System.Debug('>>> End testupdatePurchaseOrderList');
    }

    static testMethod void testupdatePrerequisiteOrderList(){
        System.Debug('>>> Start testupdatePrerequisiteOrderList');  
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.updatePrerequisiteOrderList(l_SalesOrders);
            test.stoptest();
        }
        system.assertEquals(4 ,l_SalesOrders.size());
        System.Debug('>>> End testupdatePrerequisiteOrderList');
    }

    static testMethod void testupdateOrderLineList(){
        System.Debug('>>> Start testupdateOrderLineList');  
        insert l_OrderLines;
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.updateOrderLineList(l_OrderLines);
            test.stoptest();
        }
        system.assertEquals(15 ,l_OrderLines.size());
        System.Debug('>>> End testupdateOrderLineList');
    }

    static testMethod void testgetOrderLinesInfo(){
        System.Debug('>>> Start testgetOrderLinesInfo');    
        List<Id> olIdList = new List<Id>();
        List<OrderLine__c> olList = new List<OrderLine__c>();
        insert l_OrderLines;
        for (OrderLine__c ol : l_OrderLines){
            olIdList.add(ol.Id);
        }
        system.runas(l_users[0]){
            test.starttest();
                olList = ASPISWithoutSharingExceptions.getOrderLinesInfo(olIdList);
            test.stoptest();
        }
        system.assertEquals(15 ,olList.size());
        System.Debug('>>> End testgetOrderLinesInfo');
    }
    
    static testMethod void testinsertInvoice(){
        System.Debug('>>> Start testinsertInvoice');    
        l_Invoices.add(TestFactory.createBodyshopInvoice('546',200, 'SENT', l_SalesOrders[0]));
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.insertInvoice(l_Invoices[0]);
            test.stoptest();
        }
        system.assertEquals(1 ,[select Id from Invoice__c where Id in: l_Invoices].size());
        System.Debug('>>> End testinsertInvoice');
    }
    
    static testMethod void testinsertInvoices(){
        System.Debug('>>> Start testinsertInvoices');   
        l_Invoices.add(TestFactory.createBodyshopInvoice('546',200, 'SENT', l_SalesOrders[0]));
        l_Invoices.add(TestFactory.createBodyshopInvoice('545',200, 'SENT', l_SalesOrders[1]));
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.insertInvoices(l_Invoices);
            test.stoptest();
        }
        system.assertEquals(2 ,[select Id from Invoice__c where Id in: l_Invoices].size());
        System.Debug('>>> End testinsertInvoices');
    }
    

    static testMethod void testinsertListOrderLines(){
        System.Debug('>>> Start testinsertListOrderLines'); 
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.insertListOrderLines(l_OrderLines);
            test.stoptest();
        }
        system.assertEquals(15 ,[select Id from OrderLine__c where Id in: l_OrderLines].size());
        System.Debug('>>> End testinsertListOrderLines');
    }

    static testMethod void testupsertListOrderLines(){
        System.Debug('>>> Start testupsertListOrderLines');
        insert l_OrderLines[0];
        insert l_OrderLines[2];
        insert l_OrderLines[4];
        insert l_OrderLines[6];

        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.upsertListOrderLines(l_OrderLines);
            test.stoptest();
        }

        system.assertEquals(15 ,[select Id from OrderLine__c where Id in: l_OrderLines].size());
        System.Debug('>>> End testupsertListOrderLines');
    }   

    static testMethod void testupdateOfferLineList(){
        System.Debug('>>> Start testupdateOfferLineList');
        system.runas(l_users[0]){
            insert l_OrderLines;
            insert l_Offers;
            test.starttest();
                ASPISWithoutSharingExceptions.updateOfferLineList(l_Offers);
            test.stoptest();
        }
        system.assertEquals(16,[select Id from Offer__c where Id in: l_Offers].size());
        System.Debug('>>> End testupdateOfferLineList');
    }

    static testMethod void testinsertListCases(){
        System.Debug('>>> Start testinsertListCases');
        list<Case__c> cases = new list<Case__c>();
        Case__c ca1 = TestFactory.createCase('testcase',3, l_users[0]);
        cases.add(ca1);
        Case__c ca2 = TestFactory.createCase('testcase2',4, l_users[0]);
        cases.add(ca2);

        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.insertListCases(cases);
            test.stoptest();
        }
        system.assertEquals(2 ,[select Id from Case__c where Id in: cases].size());
        System.Debug('>>> End testinsertListCases');
    }


    static testMethod void testinsertLog(){
        System.Debug('>>> Start testinsertLog');
 
        system.runas(l_users[0]){
            test.starttest();
                ASPISWithoutSharingExceptions.insertLog(new Log__c(Name='testlog'));
            test.stoptest();
        }
        system.assertEquals(1 ,[select Id from Log__c where Id != null].size());
        System.Debug('>>> End testinsertLog');
    }

    //AMI 30/10/2018  Case C-002045 - Advance case management
    static testMethod void testDiscussionCase(){
        System.Debug('>>> Start testDiscussionCase');
 
        system.runas(l_users[0]){
            Case__c c1 = TestFactory.createCase('test',4,l_users[0]);
            c1.Purchase_order__c = l_purchaseOrders[0].id;
            c1.Sales_order__c = l_SalesOrders[0].id;
            c1.Status__c = ASPISConstants.caseTypeQUESTION;
            c1.Account_Name__c = l_Accounts[0].id;

            insert c1;

            CountryCodeInformationsMapping__c cs = TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            cs.AdvancedCaseManagement__c  = true;

            l_cs_CountryCodeIngformation.add(cs);

            insert l_cs_CountryCodeIngformation;
            insert l_OrderLines;
            insert l_Offers;

            test.starttest();
                ASPISWithoutSharingExceptions.updatePurchaseOrderDiscussionCase(new set <id>{l_OrderLines[0].Id},new set <id>{l_Offers[0].id});
            test.stoptest();
        }
        system.assertEquals(1 ,[select Id from PurchaseOrder__c where OrderDiscussionCase__c = true].size());

        System.Debug('>>> End testDiscussionCase');
    }

    //AMI 30/10/2018  Case C-002045 - Advance case management
    static testMethod void testStatusSO(){
        System.Debug('>>> Start testStatusSO');
 
        system.runas(l_users[0]){

            CountryCodeInformationsMapping__c cs = TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            cs.AdvancedCaseManagement__c  = true;

            l_cs_CountryCodeIngformation.add(cs);

            insert l_cs_CountryCodeIngformation;
            insert l_OrderLines;

            test.starttest();
                l_Offers[0].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_MANAGED;
                insert l_Offers[0];

                ASPISWithoutSharingExceptions.updateSOToManage(new set <id>{l_SalesOrders[0].id});
            test.stoptest();
        }
        system.assertEquals(ASPISConstants.OFFER_STATUS_MANAGED ,[select id,Status__c from PrerequisiteOrder__c where id = :l_SalesOrders[0].id].Status__c);
        System.Debug('>>> End testStatusSO');
    }

    //GBH 22.09.2020
    static testMethod void testInsertPartLists(){
        
        system.runas(l_users[0]){

            List<PartList__c> lstPartListToinsert = new list <PartList__c>{
				TestFactory.createPartList(l_Assessments[0])
			};
               

			lstPartListToinsert[0].TECH_OriginalPart__c = 'Ass1Part1';
			lstPartListToinsert[0].ProducerName__c = 'VW';
			lstPartListToinsert[0].Quantity__c = 15;
			lstPartListToinsert[0].RecordtypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
			lstPartListToinsert[0].PartNumber__c = '76TYGD90anJWXs';
			lstPartListToinsert[0].TechCheckForSubstitute__c = true;
			
            test.starttest();

                ASPISWithoutSharingExceptions.insertPartLists(lstPartListToinsert);
            test.stoptest();
        }
        system.assertEquals(2 ,[select Id from PartList__c].size());

    }

    static testMethod void testInsertOffers(){
        
        system.runas(l_users[0]){

            List<Offer__c> lstOfferToinsert = new list <Offer__c>{
				TestFactory.createOfferLine(l_OrderLines[0], l_SalesOrders[0], 'ISSUED')
			};
			
            test.starttest();

                ASPISWithoutSharingExceptions.insertOffers(lstOfferToinsert);
            test.stoptest();
        }
        system.assertEquals(1 ,[select Id from Offer__c WHERE DeliveryStatus__c = 'ISSUED'].size());

    }

    static testMethod void testGetAssessmentsInfo(){
        
        system.runas(l_users[0]){

            test.starttest();

                List<Assessment__c> lstAssessmentInfo = ASPISWithoutSharingExceptions.getAssessmentsInfo(new List<Id>{l_Assessments[0].id});
            test.stoptest();
        
        system.assertEquals(l_Assessments[0].id  ,lstAssessmentInfo[0].id);
        }
    }

    static testMethod void testGetOfferList(){
        system.runas(l_users[0]){
            // List <Account> lstAcc = new List<Account> ();
            // Account acc1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            // Account acc2 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            // lstAcc.add(acc1);
            // lstAcc.add(acc2);
            // insert lstAcc;

            // List <Assessment__c> lstAss = new List<Assessment__c> ();
            // Assessment__c assParent = TestFactory.createAssessment('ASSESS_TEST-0002', acc1);
            // Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', acc2);
            // lstAss.add(assParent);
            // lstAss.add(ass2);
            // insert lstAss;

            // lstAss[1].ParentAssessment__c = lstAss[0].id;
            // update lstAss;

            // PrerequisiteOrder__c so = TestFactory.createSalesOrder(l_Assessments[0], bs1, 'INDELIVERY');
            // so1.SLAInDeliveryLevel3__c = System.today();
            // l_SalesOrders.add(so1);

            
            // Offer__c offer1 = TestFactory.createOfferLine(l_OrderLines[0], l_purchaseOrders[0], 'INDELIVERY');
            // insert offer1;
            System.debug('l_Assessments[0].id' +l_Assessments[0].id);
            System.debug('l_Assessments[1].id' +l_Assessments[1]);
            System.debug('l_Assessments[1].parent' +l_Assessments[1].parentassessment__c);
            System.debug('l_Offers[0]'+ l_Offers[0].Prerequisiteorder__r.Assessment__r.ParentAssessment__c);
            test.starttest();
                List<Offer__c> lstOffer = ASPISWithoutSharingExceptions.getOfferList(l_Assessments[0].id);
            test.stoptest();
            //Offer__c offer = [SELECT id FROM Offer__c WHERE Prerequisiteorder__r.Assessment__r.ParentAssessment__c = :l_Assessments[0].id];

            // System.debug('## offer' + offer.id);
        // system.assertEquals(l_Offers[0].id  ,lstOffer[0].id);
        }
    }
    static testMethod void testGetPOList(){
        system.runas(l_users[0]){

            test.starttest();
                List<PurchaseOrder__c> lstPo = ASPISWithoutSharingExceptions.getPOList(l_Assessments[0].id);
            test.stoptest();
        
        system.assertEquals(l_purchaseOrders[0].id, lstPo[0].id);
        }
    }

    // static testMethod void testGetPOList(){
    //     system.runas(l_users[0]){

    //         test.starttest();
    //             List<PurchaseOrder__c> lstPo = ASPISWithoutSharingExceptions.getPOList(l_Assessments[0].id);
    //         test.stoptest();
        
    //     system.assertEquals(l_purchaseOrders[0].id, lstPo[0].id);
    //     }
    // }
}