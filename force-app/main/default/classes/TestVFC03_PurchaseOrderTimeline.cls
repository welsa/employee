/*************************************************************************************
Class Name - TestVFC03_PurchaseOrderTimeline
Version - 1.0
Created Date - 13 MAY 2015
Function - TestClass to VFC03_PurchaseOrderTimeline

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      15/05/2015  Original Version
* Dourga U      05/08/2015  Updated version
*************************************************************************************/
@isTest
private class TestVFC03_PurchaseOrderTimeline {
  /*  static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
    static list<Invoice__c> invoices;
    static BusinessHours defaultHours;
    static List<Offer__c> Offers;
    static list<OrderLine__c> OrderLines;
    static list<PartList__c> PartList;


    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();

    static{

        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);

         //Get the default business hours (we might need it)
        defaultHours = [select Id,TimeZoneSidKey from BusinessHours where IsDefault=true];

        userAdmin = new User(Username = 'jean.paul@test.com'
                    ,LastName = 'paul'
                    ,LanguageLocaleKey = 'en_US'
                    ,FirstName = 'jean'
                    ,Email = 'jean@test.com'
                    ,Alias = 'jpa'
                    ,TimeZoneSidKey = 'Europe/Paris'
                    ,LocaleSidKey = 'en_US'
                    ,EmailEncodingKey = 'UTF-8'
                    ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);
        
        // insert InvoiceMargin__c
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

        system.runas(userAdmin){
            // insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ShippingCountryCode = 'FR'
                ),
                new Account(Name='Distributor_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ShippingCountryCode = 'FR'
                )
            };

            ASPISTestUtils.generateAccount (accounts);
            accounts[0].ShippingCountryCode = 'FR';
            accounts[1].ShippingCountryCode = 'FR';
            update accounts;

            //assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(BodyShop__c = accounts[0].Id) 
            };
            ASPISTestUtils.generateAssessment (assessments);


            //PrerequisiteOrder
            prerequisiteOrders= new list<PrerequisiteOrder__c>{
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                    , Status__c = 'INACCEPTANCE'
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)                    
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                )
            };
            ASPISTestUtils.generatePrerequisiteOrder (prerequisiteOrders);


            datetime myDate = datetime.newInstance(2015, 2, 17);
            
            // invoices
            invoices = new list<Invoice__c>{
                new Invoice__c(BodyShop__c=accounts[0].Id
                    ,Status__c = ASPISConstants.INV_STATUS_SENT
                    ,Assessment__c =  assessments[0].Id
                    ,PrerequisiteOrder__c = prerequisiteOrders[2].id
                )
            };
            ASPISTestUtils.generateInvoice(invoices);

            //insert purchase orders
            purchaseOrders = new list<PurchaseOrder__c>{
                new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    //,QuotationTimestampStart__c = Datetime.now()
                    ,SLAQuotationLevel1__c = mydate.addDays(2)
                    ,SLAQuotationLevel2__c = mydate
                    ,SLAQuotationLevel3__c = mydate.addDays(5)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false                    
                ),
                new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_ISSUED
                    //,QuotationTimestampStart__c = Datetime.now()
                    ,SLAQuotationEntryDate__c = datetime.now()
                    ,SLAQuotationLevel1__c = (datetime.now()).addDays(1)
                    ,SLAQuotationLevel2__c = (datetime.now()).addDays(2)
                    ,SLAQuotationLevel3__c = (datetime.now()).addDays(3)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
                    
                )
            };
            insert purchaseOrders;
            
        
        }
    }
    @isTest static void test_purchaseOrderTimeLineDraftQuote () {
        system.debug('#### Start of method test_purchaseOrderTimeLineDraftQuote');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[0]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);

                system.assertEquals(1,pOrder.stepNumber);
            test.stoptest();
        }
    }
    
     
    @isTest static void test_purchaseOrderTimeLineIssued() {
        system.debug('#### Start of method test_purchaseOrderTimeLineIssued');

        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[1]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                
                system.assertEquals(2,pOrder.stepNumber);
            test.stoptest();
        }
    }

    // PO Ordered 
    @isTest static void test_purchaseOrderTimeLineOrdered() {
        system.debug('#### Start of method test_purchaseOrderTimeLineOrdered');

        system.runAs(userAdmin){
            test.starttest();
                
                PurchaseOrder__c PO = New PurchaseOrder__c(Distributor__c =  accounts[1].Id,Assessment__c = assessments[0].Id,Status__c = 'ORDERED', RecordTypeID = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Ordered').getRecordTypeId());
                insert PO;      


                ApexPages.StandardController sc = new ApexPages.StandardController(PO);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                system.debug('####### pOrder.stepNumber:'+pOrder.stepNumber);           
                system.assertEquals(3,pOrder.stepNumber);
            test.stoptest();
        }
    }   

    // PO InDelivery    
    @isTest static void test_purchaseOrderTimeLineInDelivery() {
        system.debug('#### Start of method test_purchaseOrderTimeLineInDelivery');

        system.runAs(userAdmin){
            test.starttest();

                purchaseOrders[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
                update purchaseOrders;

                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[1]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                
                system.assertEquals(4,pOrder.stepNumber);
            test.stoptest();
        }
    }
    
    // Delivered
    @isTest static void test_purchaseOrderTimeLineDelivered() {
        system.debug('#### Start of method test_purchaseOrderTimeLineDelivered');

        system.runAs(userAdmin){
            test.starttest();

                purchaseOrders[1].Status__c = System.label.DELSTATUSDELIVERED;
                update purchaseOrders;

                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[1]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                
                system.assertEquals(5,pOrder.stepNumber);
            test.stoptest();
        }
    }

    @isTest static void test_purchaseOrderTimeLineDeliveredConfirmed() {
        system.debug('#### Start of method test_purchaseOrderTimeLineDeliveredConfirmed');

        system.runAs(userAdmin){
            test.starttest();

                purchaseOrders[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
                update purchaseOrders;

                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[1]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                
                system.assertEquals(6,pOrder.stepNumber);
            test.stoptest();
        }
    }   
    
    // Payable
    @isTest static void test_purchaseOrderTimeLinePayable() {
        system.debug('#### Start of method test_purchaseOrderTimeLinePayable');

        system.runAs(userAdmin){
            test.starttest();

                purchaseOrders[1].Status__c = system.label.InvoicePayable;
                update purchaseOrders;

                PageReference pageRef = Page.VFP03_PurchaseOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrders[1]);
                VFC03_PurchaseOrderTimeline pOrder = new VFC03_PurchaseOrderTimeline(sc);
                
                system.assertEquals(7,pOrder.stepNumber);
            test.stoptest();
        }
    }*/
}