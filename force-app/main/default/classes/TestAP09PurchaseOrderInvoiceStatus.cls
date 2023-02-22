/*************************************************************************************
Class Name - TestAP09PurchaseOrderInvoiceStatus 
Version - 1.0
Created Date - 14 JUL 2015
Function - Test Class for AP09PurchaseOrderInvoiceStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Dourga(SC)   14/07/2015   Original Version
*************************************************************************************/
@isTest
private class TestAP09PurchaseOrderInvoiceStatus {/*
    static list<Account> accountsList;
    static list<user> users;
    static list<OrderLine__c> orderLines;
    static list<Offer__c> offers;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<PurchaseOrder__c> purchaseOrderSelected;
    static list<Invoice__c> invoicesList;
	static list<InvoiceMargin__c> invoiceMarginList;

    static{
        ASPISTestUtils.generateBasicTestData();
        system.runas(ASPISTestUtils.users[0]){

            //insert new Bypass__c(SetupOwnerId =ASPISTestUtils.users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
            //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestAP09PurchaseOrderInvoiceStatus',ASPISTestUtils.users[0].Id);
            
            accountsList = new List<Account>{
                    new Account(Name='Payment_ScTest1',
                                 ReferenceNumber__c = '1234567',
                                 ContactEmail__c = 'bt3@gmail.com',
                                 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
                                 ShippingCountryCode = 'FR')
            };
            insert accountsList;

            ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
            update ASPISTestUtils.accounts;

            ASPISTestUtils.prerequisiteOrders[0].TotalASPrice__c = 500;
            ASPISTestUtils.prerequisiteOrders[1].TotalASPrice__c = 700;
            update ASPISTestUtils.prerequisiteOrders;

            ASPISTestUtils.purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
            ASPISTestUtils.purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;
            update ASPISTestUtils.purchaseOrders;

            Prerequisiteorder__c pr = [Select Id, Assessment__c, BodyShop__c, Name, PaymentTerms__c from Prerequisiteorder__c where Id =:ASPISTestUtils.prerequisiteOrders[1].id limit 1];
            invoicesList = new List<Invoice__c>{
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    TotalNet__c  = 500,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = pr.id,
                    PaymentTo__c = accountsList[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    TotalNet__c  = 100,
                    Status__c = 'SENT',
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    PaymentTo__c = accountsList[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                ),
                new Invoice__c(
                    Assessment__c = pr.Assessment__c,
                    BodyShop__c = pr.BodyShop__c,
                    TotalNet__c  = 600,
                    Status__c = 'SENT',
                    PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].id,
                    Distributor__c = ASPISTestUtils.purchaseOrders[0].Distributor__c,
                    PaymentTo__c = accountsList[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = pr.PaymentTerms__c
                )
            };
            //insert invoicesList;

            CaseDetailsProcessMapping__c caseMap = new CaseDetailsProcessMapping__c(Name = 'FR-PO-NotValidated' ,Description__c = 'Le montant du Purchase order est different du sales order.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'HIGH', Reason__c = 'INVOICING' ,Short_Description__c = 'Le montant du Purchase order est different du sales order.', Subject__c = 'Le montant est different.', Type__c = 'PROBLEM');
            insert caseMap;

            purchaseOrderSelected = [select InvoiceStatus__c, TotalCreditNoteAmount__c, TotalInvoicesAmount__c, TECH_BodyshopCountryCode__c, PrerequisiteOrder__c from PurchaseOrder__c where Id in: ASPISTestUtils.purchaseOrders limit 1];
        }
    }

    static testMethod void TestupdateInvoiceStatus() {
        System.Debug('>>> Start TestupdateInvoiceStatus');

        system.runAs(ASPISTestUtils.users[0]){  
            test.starttest();
				insert invoicesList;
                //AP09PurchaseOrderInvoiceStatus.updateInvoiceStatus(purchaseOrderSelected);
            test.stoptest(); 
        }
        system.assertNotEquals([select InvoiceStatus__c from PurchaseOrder__c where Id =: ASPISTestUtils.purchaseOrders[0].Id].InvoiceStatus__c,'VALIDATED');
        System.Debug('>>> End TestupdateInvoiceStatus');
    }

    static testMethod void TestupdateInvoiceStatus2() {
        System.Debug('>>> Start TestupdateInvoiceStatus');
		
		InvoiceMargin__c invMargin = [select Id, Name from InvoiceMargin__c where Name = 'FR'];
		invoiceMarginList = new list <InvoiceMargin__c>{ new InvoiceMargin__c (Id = invMargin.Id , ValidationMargin__c = -1.00)};
		update invoiceMarginList;
		
        system.runAs(ASPISTestUtils.users[0]){  
            test.starttest();
				insert invoicesList;
            test.stoptest(); 
        }
        system.assertEquals([select InvoiceStatus__c from PurchaseOrder__c where Id =: ASPISTestUtils.purchaseOrders[0].Id].InvoiceStatus__c,'NOTVALIDATED');
        System.Debug('>>> End TestupdateInvoiceStatus');
    }*/
}