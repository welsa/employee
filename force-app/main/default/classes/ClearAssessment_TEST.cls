/*************************************************************************************
Class Name - ClearAssessment_TEST 
Version - 1.0
Created Date - 16 OCT 2020
Function - TestClass to ClearAssessment

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA           16/10/2020  Original Version
* 
*************************************************************************************/
@isTest
public class ClearAssessment_TEST {
    
    static List<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static List<User> l_users;
    static List<PurchaseOrder__c> l_purchaseOrders;
    static List<PrerequisiteOrder__c> l_SalesOrders;
    static List<Invoice__c> l_Invoices;
    static BusinessHours defaultHours;
    static List<OrderLine__c> orderLineList;
    static List<PartList__c> lstPartList;
    static List<CrossReference__c>lstCrossRef;
    static List<DistributorPrice__c>lstDistPrice;
    static List<DirectOrder__c>lstDirectOrder;
    
    static {
        // initialising variables
        l_Accounts = new List<Account>();
        l_Assessments = new List<Assessment__c>();
        l_users = new List<user>();
        l_purchaseOrders = new List<PurchaseOrder__c>();
        l_SalesOrders = new List<PrerequisiteOrder__c>();
        l_Invoices = new List<Invoice__c>();
        lstPartList = new List<PartList__c>();
        lstCrossRef=new List<CrossReference__c>();
        lstDistPrice= new List<DistributorPrice__c>();
        lstDirectOrder = new List<DirectOrder__c>();
        
        
        
        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;
        
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
            
            // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');//WCH 23/12/2020 C-004120
            bs1.ContactUser__c = l_users[0].Id;
            //bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ContactUser__c = l_users[0].Id;
            bs2.Feature__c='PilotDirectSourcing';
            bs2.ShippingPostalCode='6600';
            l_Accounts.add(bs2);
            
            
            Account bs4= TestFactory.createAccountBodyshop('BodyShop_ScTest4', 'FR');
            bs4.Feature__c='PilotDirectSourcing';
            bs4.Type = 'Expert';
            bs4.ShippingPostalCode='60000';
            l_Accounts.add(bs4);
            
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            dist1.Categories__c='A';
            l_Accounts.add(dist1);
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist2.Categories__c='A';
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
            
            
            
            //Create CrossReference
            CrossReference__c CR1= TestFactory.createCrossReference('FR', 'ASCR1234', 'TOYOTA', 50.0, true);
            lstCrossRef.add(CR1);
            insert lstCrossRef;
            
            // DistributorPrice__c createDistributorPrice(Id accId, Id crossRef);
            DistributorPrice__c DP1 = TestFactory.createDistributorPrice(dist2.id, CR1.id);
            lstDistPrice.add(DP1);
            insert lstDistPrice;
            
            // PartList__c createPartListASCR(Assessment__c assessment, CrossReference__c crossRef, DistributorPrice__c distPrice);
            PartList__c pl1= TestFactory.createPartListASCR(ass1, CR1,DP1);
            
            //(Record TypeEQUALSMaterial) AND (SelectedEQUALSTrue)
            
            pl1.RecordTypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
            pl1.SelectedByBS__c=true;
            lstPartList.add(pl1);
            insert lstPartList;
            
            
            //Create Direct Order
            
            DirectOrder__c dO1 = TestFactory.createDirectOrder(null, dist2.Id);
            dO1.State__c = '01;02;03;04;04;05;06;07;66';
            dO1.Part_Type__c = 'A';
            dO1.Priority__c = 'P0';
            dO1.Agency_mode__c = false;
            dO1.Active__c = true;
            dO1.Country__c = 'FR';
            dO1.Type__c = 'General';
            dO1.Brands__c = 'TOYOTA;AUDI;NISSAN;';
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            lstDirectOrder.add(dO1);
            insert lstDirectOrder;
            
            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'DELIVEREDCONFIRMED');
            l_SalesOrders.add(so1);
            
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'DELIVEREDCONFIRMED');
            l_SalesOrders.add(so2);
            
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'DELIVEREDCONFIRMED');
            l_SalesOrders.add(so3);
            insert l_SalesOrders;
            
            
            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DRAFTQUOTE');
            l_purchaseOrders.add(po1_1);
            
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_2);
            
            
            PurchaseOrder__c po1_3 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO);
            l_purchaseOrders.add(po1_3);
            
            PurchaseOrder__c po1_4 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK);
            l_purchaseOrders.add(po1_4);
            
            insert l_purchaseOrders;
            
            orderLineList = new List<OrderLine__c>{
                TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                    TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                    TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
                    };
                        
                        
                        // Create several invoices.
                        Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'PAID', po1_1);
            l_Invoices.add(inv1);
            
            Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'PAID', po1_2);
            l_Invoices.add(inv2);
            
            Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 54.40, 'PAID', po1_1);
            l_Invoices.add(inv3);
            
            Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 14.40, 'PAID', po1_2);
            l_Invoices.add(inv4);
            
            Invoice__c inv5= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'PAID', so1);
            l_Invoices.add(inv5);
            
            Invoice__c inv6= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'PAID', so2);
            l_Invoices.add(inv6);
            
            
            Invoice__c inv7 = TestFactory.createDistributorCreditNote('INV-2812G', 14.40, ASPISConstants.INV_STATUS_SENT, po1_3);
            l_Invoices.add(inv7);
            
            Invoice__c inv8 = TestFactory.createDistributorCreditNote('INV-2812H', 4.40, ASPISConstants.INV_STATUS_SENT, po1_4);
            l_Invoices.add(inv8);
            
            Invoice__c inv9 = TestFactory.createDistributorInvoice('INV-2812I', 54.40, ASPISConstants.INV_STATUS_SENT, po1_3);
            l_Invoices.add(inv9);
            
            Invoice__c inv10 = TestFactory.createDistributorInvoice('INV-2812K', 14.40, ASPISConstants.INV_STATUS_SENT, po1_4);
            l_Invoices.add(inv10);
        }
        
    }    
    
    @isTest
    static void clearData_Test(){
        system.runas(l_users[0]){
            
            
            
            
            String idz= String.valueof(lstDirectOrder[0].id);
            
            list<DirectOrder__c> lstDirectOrderSelected =[SELECT Name,Distributor__c, Part_Type__c, Priority__c, BodyShop__c, Agency_mode__c, Type__c,State__c,RecordType.Name,Distributor__r.ShippingCountryCode FROM DirectOrder__c WHERE Id=:idz];
            System.debug('~~~~ lstDirectOrderSelected '+lstDirectOrderSelected);
            
            Test.startTest();
            ClearAssessment.clearData(l_Assessments[0].id);
            Test.stopTest();
        
            
            
            
            
        }
    }
    
    
}