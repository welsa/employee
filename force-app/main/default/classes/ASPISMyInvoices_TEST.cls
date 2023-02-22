/*
----------------------------------------------------------------------
-- - Name          : ASPISMyInvoices_TEST
-- - Author        : VSU
-- - Description   : Test class for ASPISMyInvoices
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-SEP-2017  VSU     1.0    Initial version
-- 13-DEC-2019  WCH     1.1    C-003521 Extraction Factures // R4
-- 02-DEC-2020  WCH     1.2    increase code coverage
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISMyInvoices_TEST
{
    static list <User> userList;
    static list <User> userList2;
    static list <Contact> contactList;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static list<Invoice__c> invoiceList;
    static list<Invoice__c> invoiceMassList;

    static
    {
        userList = new list <user> ();
        contactList = new list<Contact>();
        userList2 = new list <user> ();
        User adminUser = TestFactory.createUser('adminUser');
        adminUser.userroleId=[select Id from UserRole where name='FR - AlphaScale' limit 1].Id;
        User contact1 = TestFactory.createUserBodyshop('Carrosserie56');
        User contact2 = TestFactory.createUserBodyshop('Carrosserie58');
        User contact3 = TestFactory.createUserBodyshop('Carrosserie59');

        userList.add(adminUser);
        

        insert userList;

        System.runAs(adminUser)
        {
            // Generating the account
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
                TestFactory.createAccountDistributor('Distributor_2', 'ES'),

                TestFactory.createAccountBodyshop('BodyShop_3', 'IT'),
                TestFactory.createAccountDistributor('Distributor_3', 'IT'),

                TestFactory.createAccountBodyshop('BodyShop_4', 'DE'),
                TestFactory.createAccountDistributor('Distributor_4', 'DE')

            };
            accountList[2].vat__c = 21;
            accountList[3].vat__c = 21;
            accountList[4].vat__c = 22;
            accountList[5].vat__c = 22;
            accountList[6].vat__c = 19;
            accountList[7].vat__c = 19;

            accountList[0].contactuser__c = contact1.id;
            accountList[2].contactuser__c = contact1.id;
            accountList[4].contactuser__c = adminUser.id;

            insert accountList;

            Id claimRecordTypeId            = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            Id claimOrderRecordTypeId       = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            Id newAssessmentRecordTypeId    = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR_Child', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES_Child', accountList[2]),
                TestFactory.createAssessment('Assessment_IT', accountList[4]),
                TestFactory.createAssessment('Assessment_IT_Child', accountList[4]),
                TestFactory.createAssessment('Assessment_DE', accountList[6]),
                TestFactory.createAssessment('Assessment_DE_Child', accountList[6]),
                TestFactory.createAssessment('Assessment_New', accountList[0])
            };

            assessmentList[2].TECH_EntityCountryCode__c = 'ES';
            assessmentList[3].TECH_EntityCountryCode__c = 'ES';
            assessmentList[4].TECH_EntityCountryCode__c = 'IT';
            assessmentList[5].TECH_EntityCountryCode__c = 'IT';
            assessmentList[6].TECH_EntityCountryCode__c = 'DE';
            assessmentList[7].TECH_EntityCountryCode__c = 'DE';

            assessmentList[0].PlateNumber2__c           = '123MR17';
            assessmentList[1].PlateNumber2__c           = '123MR17';
            assessmentList[2].PlateNumber2__c           = '798MR17';
            assessmentList[3].PlateNumber2__c           = '798MR17';
            assessmentList[4].PlateNumber2__c           = '123JU17';
            assessmentList[5].PlateNumber2__c           = '146JU17';
            assessmentList[6].PlateNumber2__c           = '189JU17';
            assessmentList[7].PlateNumber2__c           = '142JU17';

            assessmentList[0].RecordTypeId              = claimRecordTypeId;
            assessmentList[1].RecordTypeId              = claimOrderRecordTypeId;
            assessmentList[2].RecordTypeId              = claimRecordTypeId;
            assessmentList[3].RecordTypeId              = claimOrderRecordTypeId;
            assessmentList[4].RecordTypeId              = claimRecordTypeId;
            assessmentList[5].RecordTypeId              = claimOrderRecordTypeId;
            assessmentList[6].RecordTypeId              = claimRecordTypeId;
            assessmentList[7].RecordTypeId              = claimOrderRecordTypeId;
            assessmentList[8].RecordTypeId              = newAssessmentRecordTypeId;

            insert assessmentList;

            assessmentList[1].ParentAssessment__c       = assessmentList[0].Id;
            assessmentList[3].ParentAssessment__c       = assessmentList[2].Id;
            assessmentList[5].ParentAssessment__c       = assessmentList[4].Id;
            assessmentList[7].ParentAssessment__c       = assessmentList[6].Id;

            update assessmentList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INVOICED),
                TestFactory.createSalesOrder(assessmentList[3], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INVOICED),
                TestFactory.createSalesOrder(assessmentList[4], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INVOICED),
                TestFactory.createSalesOrder(assessmentList[6], accountList[6], ASPISConstants.PRE_ORDER_STATUS_INVOICED)
            };

            insert salesOrderList;

            invoiceList = new list<Invoice__c>{
                TestFactory.createBodyshopInvoice('VE678gyfvtyft',10.50,'SENT',salesOrderList[0]),
                TestFactory.createBodyshopInvoice('VEvgvytcfcchj',10.50,'SENT',salesOrderList[1])
            };      

            invoiceList[0].date__c = date.newInstance(2001, 3, 17);
            invoiceList[1].date__c = date.newInstance(2001, 3, 21);

            system.debug('debug line 126 '+invoiceList[0].bodyshop__r.contactuser__c);
            insert invoiceList;

            invoiceMassList = new list <Invoice__c>();
            for(integer i=0 ; i<200 ; i++){
                invoiceMassList.add(TestFactory.createBodyshopInvoice('VFgeftgtfbh'+i, 10.50 , 'SENT', salesOrderList[2]));
            }

            insert invoiceMassList;

            list <Invoice__c> retrievedInvoices = [select id from Invoice__c where id IN:invoiceMassList];  
            system.debug('##retrievedInvoices.size() '+retrievedInvoices);

            //create contact
            Contact con1 = new Contact (AccountId = accountList[2].Id, LastName = 'testcontact');
            contactList.add(con1);
            Contact con2 = new Contact (AccountId = accountList[1].Id, LastName = 'testcontact2');
            contactList.add(con2);
            Contact con3 = new Contact (AccountId = accountList[4].Id, LastName = 'testcontact3');
            contactList.add(con3);
            insert contactList;

        }
        contact1.ContactId=contactList[0].Id;
        contact1.IsActive =true;
        contact1.ProfileId=[select Id from Profile where name='CC Bodyshop Order'].Id;
        userList2.add(contact1);
        contact2.ContactId=contactList[1].Id;
        contact2.IsActive =true;
        contact2.ProfileId=[select Id from Profile where name='CC Bodyshop Order'].Id;
        userList2.add(contact2);
        contact3.ContactId=contactList[2].Id;
        contact3.IsActive =true;
        contact3.ProfileId=[select Id from Profile where name='CC Bodyshop Order'].Id;
        userList2.add(contact3);
        insert userList2;
        userList.addAll(userList2);
    }

    @isTest static void searchByDate_TEST()
    {
        System.runAs(userList[1])
        {
            Test.setCurrentPage(Page.ASPISMyInvoices);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userList[1].Id)));
            ASPISMyInvoices controller  = new ASPISMyInvoices();
          
            
            Test.startTest();
                /*Date todatestr = date.parse('03/17/2001');
                Date fromdatestr = date.parse('03/22/2001');*/

                list <ASPISMyInvoices.invoiceWrapper> searchResults = ASPISMyInvoices.searchByDate(userList[1].id,'03/17/2001','03/22/2001',false);
            
            Test.stopTest();

            //list <Invoice__c>retrievedInvoices = [select id,date__c from Invoice__c where date__c >=:fromdatestr and date__c <=:todatestr ];
            system.debug('##searchResults '+searchResults);
            System.assertEquals(searchResults.size(),1);
        }
    }

    @isTest static void dateException_TEST()
    {
        System.runAs(userList[1])
        {
            Test.setCurrentPage(Page.ASPISMyInvoices);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userList[1].Id)));
            ASPISMyInvoices controller  = new ASPISMyInvoices();
            
            Test.startTest();
                try{
                    list <ASPISMyInvoices.invoiceWrapper> searchResults = ASPISMyInvoices.searchByDate(userList[1].id,'17/03/2001','18/22/2001',false);
                }
                catch(exception e){
                    system.debug('##e.getMessage test'+e.getMessage());         
                    System.assert(e.getMessage().contains('Invalid date'));
                }
            
            Test.stopTest();

        }
    }

    @isTest static void tooManyRows_TEST()
    {
        System.runAs(userList[3])
        {
            Test.setCurrentPage(Page.ASPISMyInvoices);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userList[3].Id)));
            ASPISMyInvoices controller  = new ASPISMyInvoices();
            controller.encryptBase64('test');

            controller.dateFromJs = '';
            controller.dateToJs= '' ;
                Test.startTest();

                    Pagereference exportXls = controller.downloadInvoiceXls();

                Test.stopTest();

                system.assertEquals(ASPISMyInvoices.invoiceWrapperList.size(),200);

                //System.assert(messageFound);                
        }
    }

    @isTest static void downloadInvoice_TEST()
    {
        System.runAs(userList[1])
        {
            Test.setCurrentPage(Page.ASPISMyInvoices);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userList[1].Id)));
            ASPISMyInvoices controller  = new ASPISMyInvoices();
            controller.dateFromJs = '3/17/2001/';
            controller.dateToJs= '3/22/2001' ;
            Test.startTest();
                Pagereference exportXls = controller.downloadInvoiceXls();          
            Test.stopTest();

            system.assertEquals(Page.ExportInvoiceXls.getURL(),exportXls.getURL());
        }
    }
    @isTest static void queryException_TEST()
    {
        System.runAs(userList[1])
        {
            Test.setCurrentPage(Page.ASPISMyInvoices);
            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf(userList[1].Id)));
            ASPISMyInvoices controller  = new ASPISMyInvoices();
            
            Test.startTest();
                try{
                    list <ASPISMyInvoices.invoiceWrapper> searchResults = ASPISMyInvoices.searchByDate('thodchdjkhjk','17/03/2001','18/22/2001',false);
                }
                catch(exception e){
                    system.debug('##e.getMessage test'+e.getMessage());         
                    System.assert(e.getMessage()!=null);
                }
            
            Test.stopTest();

        }
    }

    @isTest static void rowsExceedTwoHundred(){
        system.runAs(userList[1]){
            Test.setCurrentPage(Page.ASPISMyInvoices);

         }

    }

}