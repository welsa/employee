@isTest
private class TestASPISBatchSetPOStatus {
/*************************************************************************************
Class Name - TestASPISBatchSetPOStatus
Version - 1.0
Created Date - 01 Dec 2015
Function - Test Class Batch SetPOStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             01/12/2015  Original Version
* Dourga U              12/02/2016  case C-001529 : added field NotDeliveredCaseCreated__c to avoid duplicate of case creation
*************************************************************************************/
    
    
    /*// create test data
    static list<Account> accounts;
    static list<user> users;
    static list<Group> groups;
    public static list<PrerequisiteOrder__c> prerequisiteOrders;
    public static list<PurchaseOrder__c> purchaseOrders;
    public static list<Assessment__c> assessments;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    public static map <String,Id> proRecordTypeMap = new map <String,Id>();
    public static List<Invoice__c> invoicesList; 
    public static list<OrderLine__c> orderLines;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;
    static BusinessHours defaultHours;

    static{
        // create users
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
        ASPISTestUtils.generateTestUsers(users);
        
        //create InvoiceMargin__c custom settings
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

       system.runas(users[0]){
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);

            //Get the default business hours (we might need it)
            defaultHours = [select Id from BusinessHours where IsDefault=true];

            CaseDetailsProcessMapping__c caseMap = new CaseDetailsProcessMapping__c(Name = 'FR-PO-NotDelivered' ,Description__c = 'Le montant du Purchase order est different du sales order.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'HIGH', Reason__c = 'INVOICING' ,Short_Description__c = 'Le montant du Purchase order est different du sales order.', Subject__c = 'Le montant est different.', Type__c = 'PROBLEM', Active__c = true);              
            insert caseMap;

            // custom settings - CountryCodeInfo
            countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
                new CountryCodeInformationsMapping__c(
                    Name='FR'
                    ,BusinessHoursID__c = defaultHours.Id
                )
            };
            
            // create accounts
            accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
            accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                     ReferenceNumber__c = '123',
                                                     ContactEmail__c = 'bt1@gmail.com',
                                                     ShippingCountryCode = 'FR'),

                                         new Account(Name='BodyShop_ScTest2',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                     ReferenceNumber__c = '1234',
                                                     ContactEmail__c = 'bt2@gmail.com',
                                                     ShippingCountryCode = 'FR'),

                                         new Account(Name='Distributor_ScTest1',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                     ReferenceNumber__c = '12345',
                                                     ContactEmail__c = 'dt1@gmail.com', 
                                                     DistributorNextInvoiceDate__c = date.today(),
                                                     DistributorInvoicePeriod__c = '15',
                                                     Categories__c='A',
                                                     ShippingCountryCode = 'FR'),

                                         new Account(Name='Distributor_ScTest2',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                     ReferenceNumber__c = '123456',
                                                     ContactEmail__c = 'dt1@gmail.com', 
                                                     DistributorNextInvoiceDate__c = date.today(),
                                                     DistributorInvoicePeriod__c = '15',
                                                     Categories__c='A',
                                                     ShippingCountryCode = 'FR')
            };
            ASPISTestUtils.generateAccount(accounts);

    
            // create assessment
            assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
                                                                   AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                                   BodyShop__c = accounts[0].Id,
                                                                   Entity__c = 'AXA Direct',
                                                                   EntityRules__c = 'AXA Direct',
                                                                   MissionNumber__c = '01',
                                                                   PortfolioAgentCode__c = '355',
                                                                   AssessmentID__c = '0912',
                                                                   TechExternalId__c = '233')
            };
            ASPISTestUtils.generateAssessment(assessments);
            
            // create PO
            purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
                                                                             Assessment__c=assessments[0].id,
                                                                             TechToBeProcessed__c = true
                                                                            ),
                                                        new PurchaseOrder__c(Distributor__c = accounts[3].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='DELIVEREDCONFIRMED',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
                                                                             Assessment__c=assessments[0].id,
                                                                             TechToBeProcessed__c = true
                                                                            ),
                                                        new PurchaseOrder__c(Distributor__c = accounts[3].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='DELIVEREDCONFIRMED',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
                                                                             Assessment__c=assessments[0].id,
                                                                             TechToBeProcessed__c = true
                                                                            )
            };
            ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
            
            orderLines = new list<OrderLine__c>{new OrderLine__c(AcceptedCheck__c = true, 
                                                                PurchaseOrder__c = purchaseOrders[0].id, 
                                                                CataloguePrice__c = 10, 
                                                                AXADiscount__c = 11, 
                                                                BodyShopDiscount__c = 10, 
                                                                Quantity__c = 2,
                                                                DeliveryStatus__c = 'DELIVERED'),
                                                new OrderLine__c(AcceptedCheck__c = true, 
                                                                 PurchaseOrder__c =purchaseOrders[0].id, 
                                                                 CataloguePrice__c = 10, 
                                                                 AXADiscount__c = 11, 
                                                                 BodyShopDiscount__c = 10, 
                                                                 Quantity__c = 2,
                                                                 DeliveryStatus__c = 'DELIVERED'),
                                                new OrderLine__c(AcceptedCheck__c = true, 
                                                                PurchaseOrder__c = purchaseOrders[1].id, 
                                                                CataloguePrice__c = 10, 
                                                                AXADiscount__c = 11, 
                                                                BodyShopDiscount__c = 10, 
                                                                Quantity__c = 2,
                                                                DeliveryStatus__c = 'DELIVERED'),
                                                new OrderLine__c(AcceptedCheck__c = true, 
                                                                 PurchaseOrder__c =purchaseOrders[1].id, 
                                                                 CataloguePrice__c = 10, 
                                                                 AXADiscount__c = 11, 
                                                                 BodyShopDiscount__c = 10, 
                                                                 Quantity__c = 2,
                                                                 DeliveryStatus__c = 'DELIVERED')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            
            //purchaseOrders[0].Status__c ='DELIVEREDCONFIRMED';
            //update purchaseOrders[0];
        
            // creating invoice data
            invoicesList = new List<Invoice__c>{new Invoice__c( Assessment__c = assessments[0].Id,
                                                                Distributor__c =  accounts[2].id,
                                                                TotalNet__c  =40,
                                                                Status__c = 'RECEIVED',
                                                                PurchaseOrder__c = purchaseOrders[0].id,
                                                                PaymentTo__c = accounts[2].id,
                                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()
                                                            ),
                                                new Invoice__c( Assessment__c = assessments[0].Id,
                                                                Distributor__c =  accounts[2].id,
                                                                TotalNet__c  = 4.40,
                                                                Status__c = 'RECEIVED',
                                                                PurchaseOrder__c = purchaseOrders[0].id,
                                                                PaymentTo__c = accounts[2].id,
                                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
                                                                IsBodyShop__c = false
                                                            ),
                                                new Invoice__c( Assessment__c = assessments[0].Id,
                                                                Distributor__c =  accounts[3].id,
                                                                TotalNet__c  =50,
                                                                Status__c = 'RECEIVED',
                                                                PurchaseOrder__c = purchaseOrders[1].id,
                                                                PaymentTo__c = accounts[2].id,
                                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()
                                                            ),
                                                new Invoice__c( Assessment__c = assessments[0].Id,
                                                                Distributor__c =  accounts[3].id,
                                                                TotalNet__c  = 14.40,
                                                                Status__c = 'RECEIVED',
                                                                PurchaseOrder__c = purchaseOrders[1].id,
                                                                PaymentTo__c = accounts[2].id,
                                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
                                                                IsBodyShop__c = false
                                                            )
            };          
            insert invoicesList;
        }
    }
    

    static testMethod void TestASPISBatchSetPOStatus() { 
        Test.startTest();
            purchaseOrders[0].Status__c = 'DELIVEREDCONFIRMED';
            update purchaseOrders;
        
            Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
        Test.stopTest();
        
        PurchaseOrder__c po = [Select Status__c, TechToBeProcessed__c,InvoiceStatus__c,TotalInvoicesAmount__c, TotalExpectedAmount__c from PurchaseOrder__c where id =: purchaseOrders[0].id];
        System.assertEquals(po.Status__c, 'PAYABLE');
        System.assertEquals(po.TechToBeProcessed__c, false);
        System.assertEquals(po.TotalInvoicesAmount__c, 35.60);
        System.assertEquals(po.TotalExpectedAmount__c, 35.60);
        System.assertEquals(po.InvoiceStatus__c, 'VALIDATED');
    } 

    static testMethod void TestASPISBatchSetPOStatusCreateCase() { 
        Test.startTest();
            purchaseOrders[0].Status__c = 'INDELIVERY';
            purchaseOrders[0].TechToBeProcessed__c = true;
            purchaseOrders[0].NotDeliveredCaseCreated__c = false;
            update purchaseOrders;
        
            Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
        Test.stopTest();
        
        System.assertEquals([Select Id, Purchase_order__c  from Case__c where Purchase_order__c =: purchaseOrders[0].id].size(), 1);
    }

    static testMethod void TestASPISBatchSetPOStatusPOPaid() { 
        Test.startTest();
            invoicesList[0].Status__c = 'PAID';
            invoicesList[1].Status__c = 'PAID';
            purchaseOrders[0].TechToBeProcessed__c = true;
            update invoicesList;
            update purchaseOrders;
        
            Database.executeBatch(new ASPISBatchSetPOStatus(), 200);  
        Test.stopTest();
        
        System.assertEquals([Select Status__c from PurchaseOrder__c where id =: purchaseOrders[0].id].Status__c, 'PAID');
    }*/

}