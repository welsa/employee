/*************************************************************************************
Class Name - TestAP15CalcTotalExpAmtPurchaseOrder
Version - 1.0
Created Date - 07 OCT 2015
Function - test class for AP15

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------        ----------  -----------------------
* Brayan N          07/10/2015    Original Version
*************************************************************************************/
@isTest
private class TestAP15CalcTotalExpAmtPurchaseOrder { 
/*
static list<Account> accounts;
    static list<user> users;
    static list<Group> groups;
    public static list<PrerequisiteOrder__c> prerequisiteOrders;
    public static list<PurchaseOrder__c> purchaseOrders;
    public static list<Assessment__c> assessments;
    public static List<Invoice__c> invoicesList; 
    public static list<OrderLine__c> orderLines;

    static{

        users = new list<User>{ new User(Username = 'jb@test.com',
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
        ASPISTestUtils.generateTestUsers(users);
        
        // @CLA  To avoid the error with the class AP09
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

        system.runas(users[0]){
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                     RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
                                                     ReferenceNumber__c = '123',
                                                     ContactEmail__c = 'bt1@gmail.com',
                                                     ShippingCountryCode = 'FR',
                                                     ReferentialASforAParts__c = 20,
                                                     ReferentialASforBCParts__c = 25,
                                                     LowKeepDiscountforAParts__c = 10),

                                        new Account(Name='BodyShop_ScTest2',
                                                    RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
                                                    ReferenceNumber__c = '1234',
                                                    ContactEmail__c = 'bt2@gmail.com',
                                                    ShippingCountryCode = 'FR',
                                                    LowKeepDiscountforAParts__c = 10),

                                        new Account(Name='Distributor_ScTest1',
                                                    RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),
                                                    ReferenceNumber__c = '12345',
                                                    ContactEmail__c = 'dt1@gmail.com', 
                                                    DistributorNextInvoiceDate__c = date.today(),
                                                    DistributorInvoicePeriod__c = '15',
                                                    Categories__c='A',
                                                    ReferentialASforAParts__c = 20,
                                                    ShippingCountryCode = 'FR'),

                                        new Account(Name='Distributor_ScTest2',
                                                    RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),
                                                    ReferenceNumber__c = '123456',
                                                    ContactEmail__c = 'dt1@gmail.com', 
                                                    DistributorNextInvoiceDate__c = date.today(),
                                                    DistributorInvoicePeriod__c = '15',
                                                    Categories__c='A',
                                                    ReferentialASforAParts__c = 20,
                                                    ShippingCountryCode = 'FR')
            };
            //insert accounts;
            ASPISTestUtils.generateAccount(accounts);

            List<Account> insertedAccounts = [Select Name from Account where Id in:accounts order by RecordTypeId];

            if(insertedAccounts.size() > 2){
                groups = new list<Group>{
                    new Group(Name=insertedAccounts[0].Name, Type='Regular'),
                    new Group(Name=insertedAccounts[2].Name, Type='Regular')
                  };
                  insert groups;
             }

            assessments = new list<Assessment__c>{new Assessment__c( Name='ASSESS_TEST-0001',
                                                                     AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                                     BodyShop__c = accounts[0].Id,
                                                                     Entity__c = 'AXA Direct',
                                                                     EntityRules__c = 'AXA Direct',
                                                                     MissionNumber__c = '01',
                                                                     PortfolioAgentCode__c = '355',
                                                                     AssessmentID__c = '0912',
                                                                     TechExternalId__c = '233'),                                                      
                                                    new Assessment__c( Name='ASSESS_TEST-0002',
                                                                       AssessmentNumber__c = 'ASSESS_TEST-0002',
                                                                       BodyShop__c = accounts[0].Id,
                                                                       Entity__c = 'AXA Direct1',
                                                                       EntityRules__c = 'AXA Direct1',
                                                                       MissionNumber__c = '02',
                                                                       PortfolioAgentCode__c = '3545',
                                                                       AssessmentID__c = '5912')
                      
            };
            //insert assessments ;
            ASPISTestUtils.generateAssessment(assessments);          

            purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                              ValidityDate__c=date.today(),
                                                                              Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                              //QuotationTimestampStart__c = Datetime.now(),
                                                                              SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                              SLAQuotationLevel2__c = myDateTime,
                                                                              SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                              TECHSLAQuotationIsLevel1__c = false,
                                                                              TECHSLAQuotationIsLevel2__c = false,
                                                                              TECHSLAQuotationIsLevel3__c = false,
                                                                              Assessment__c=assessments[0].id
                                                                            //, BodyShop__c=accounts[0].id
                                                                            )
            };
            //insert purchaseOrders;
            ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
          
            orderLines = new list<OrderLine__c>{
                new OrderLine__c(DeliveryStatus__c = 'DELIVERED', AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[0].id, CataloguePrice__c = 10, BodyShopDiscount__c = 10, TECH_ExtraAS__c = 25, Quantity__c = 2, Type__c = 'A')
                
            };
            ASPISTestUtils.generateOrderLine(orderLines);
        }
    }
  
    
    //static testMethod void myUnitTest() {
    //    system.runas(users[0]){
    //        // creating invoice data
    //        invoicesList = new List<Invoice__c>{
    //            new Invoice__c(
    //                Assessment__c = assessments[0].id,
    //                TotalNet__c  = 100,
    //                Status__c = 'SENT',
    //                PurchaseOrder__c = purchaseOrders[0].id,
    //                PaymentTo__c = accounts[0].id,
    //                Distributor__c = purchaseOrders[0].Distributor__c,
    //                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
    //                Paymentterms__c = 'Test'
    //            ),
    //            new Invoice__c(
    //                Assessment__c = assessments[0].id,
    //                TotalNet__c  = 600,
    //                Status__c = 'SENT',
    //                PurchaseOrder__c = purchaseOrders[0].id,
    //                Distributor__c = purchaseOrders[0].Distributor__c,
    //                PaymentTo__c = accounts[0].id,
    //                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
    //                Paymentterms__c = 'Test'
    //            )
    //        };
	//
    //        Test.startTest();
    //        insert invoicesList;
    //        Test.stopTest();
    //    }
    //}

    static testMethod void myUnitTest2() {
        system.runas(users[0]){
            

            Test.startTest();
            purchaseOrders[0].Status__c = 'DELIVEREDCONFIRMED';
            update purchaseOrders;
            Test.stopTest();
        }
    }
    
    static testMethod void myUnitTest3() {
        system.runas(users[0]){
            Set <Id> setPoId = new Set <Id>();
            for(PurchaseOrder__c po : purchaseOrders){
                setPoId.add(po.Id);
            }
            Test.startTest();
            purchaseOrders[0].Status__c = 'DELIVEREDCONFIRMED';
            update purchaseOrders;
            AP15CalculateTotalExpAmtPurchaseOrder.purchaseOrderToUpdate(setPoId,purchaseOrders);
            Test.stopTest();
        }
    }*/
}