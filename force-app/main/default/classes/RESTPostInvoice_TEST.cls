@isTest
/*
----------------------------------------------------------------------
-- - Name          : RESTPostInvoice_TEST
-- - Author        : VSU
-- - Description   : Test class for RESTPostInvoice
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 09-SEP-2017  VSU     1.0    Initial version
-- 19-JUN-2018  VSU     1.1    Case C-002578 use another method from Cegedim that will send back only 1 Iddoc
----------------------------------------------------------------------
**********************************************************************
*/
public class RESTPostInvoice_TEST{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static list<Invoice__c> invoiceList;
    static list<Invoice__c> invoiceMassList;
    static list <CountryCodeInformationsMapping__c> csList;
    static BusinessHours defaultHours;

    static
    {
        adminUser = TestFactory.createUser('adminUser');
        
        insert adminUser;

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

            accountList[0].contactuser__c = adminUser.id;
            accountList[2].contactuser__c = adminUser.id;
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

            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[2].TECH_EntityCountryCode__c = 'ES';
            assessmentList[3].TECH_EntityCountryCode__c = 'DE';
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
                TestFactory.createBodyshopInvoice('VE2016001697',10.50,'SENT',salesOrderList[0]),
                TestFactory.createBodyshopInvoice('VEv908876432',10.50,'SENT',salesOrderList[1]),
                TestFactory.createBodyshopInvoice('VEvgv7867859',10.50,'SENT',salesOrderList[1])
            };      

            invoiceList[0].date__c = date.newInstance(2017, 3, 17);
            invoiceList[1].date__c = date.newInstance(2017, 3, 21);
            invoiceList[2].date__c = date.newInstance(2017, 3, 25);
            invoiceList[2].TECH_Number__c = 'ce22a8c50a19935215c9a4e1012dc77b';

            system.debug('debug line 126 '+invoiceList[0].bodyshop__r.contactuser__c);
            insert invoiceList;

            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            csList = new list<CountryCodeInformationsMapping__c>{new CountryCodeInformationsMapping__c(Name='DE',pdfCode__c='FR0000121760_002',BusinessHoursId__c=defaultHours.id),
                     new CountryCodeInformationsMapping__c(Name='FR',pdfCode__c='FR0000121760_001',BusinessHoursId__c=defaultHours.id),
                     new CountryCodeInformationsMapping__c(Name='IT',pdfCode__c='FR0000121760_003',BusinessHoursId__c=defaultHours.id)
            };
            insert csList;
        }

    }

    @isTest static void testRetrievePdf() {
        // Set mock callout class 
        PdfHttpCalloutMock mock = new PdfHttpCalloutMock();
        mock.resBody='MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw';
        mock.status=200;
        mock.contentType= 'application/pdf';
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String pdfResponse = RESTPostInvoice.retrievePdfBody('ce22a8c50a19935215c9a4e1012dc77b',invoiceList[2].id);
        // Verify that the response received contains fake values
        system.debug('##pdfResponse '+pdfResponse);
        System.assert(pdfResponse!=null);
        System.assertEquals(pdfResponse,'MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw');

        Test.stopTest();
    }

    @isTest static void testRetrievePdfError() {
        // Set mock callout class 
        PdfHttpCalloutMock mock = new PdfHttpCalloutMock();
        mock.resBody='Error';
        mock.status=400;
        mock.contentType= 'application/xml';
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String pdfResponse = RESTPostInvoice.retrievePdfBody('a413d4350a1993520e8fc3038f3c1c64',invoiceList[0].id);
        // Verify that the response received contains fake values
        system.debug('##pdfResponse '+pdfResponse);
        System.assert(pdfResponse.contains('Error'));

        Test.stopTest();
    }

    @isTest static void testSendRequestPdf() {
        // Set mock callout class 
        PdfHttpCalloutMock mock = new PdfHttpCalloutMock();
        mock.resBody='MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw';
        mock.status=200;
        mock.contentType= 'application/pdf';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String pdfResponse = RESTPostInvoice.sendRequestForPdf(invoiceList[2].Number__c,invoiceList[2].id,'ce22a8c50a19935215c9a4e1012dc77b','DE');
        // Verify that the response received contains fake values
        //ystem.assert(pdfResponse!=null);
        //System.assertEquals(pdfResponse,'MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw');

        Test.stopTest();
    }

    @isTest static void testSendRequestIdentifier() {

        Test.startTest();

        PdfHttpCalloutMock mockCalloutIdentifier = new PdfHttpCalloutMock();
        mockCalloutIdentifier.resBody='<?xml version="1.0" encoding="ISO-8859-1"?><GETLSTDF><ENTETE><LOGIN>aspis.integration</LOGIN><PASSWORD>*</PASSWORD></ENTETE><CRITERIA><SENS>EM</SENS><CURDATORI_INF>2016-01-01</CURDATORI_INF><NUMFAC>VE2016001697</NUMFAC><ESPARCHI><IDCTRCPT>FR0000121760_001</IDCTRCPT></ESPARCHI></CRITERIA><VO><IDDOC>a413d4350a1993520e8fc3038f3c1c64</IDDOC><ESPARCHI>FR0000121760_001</ESPARCHI><IDPARTNER>FR0ALPHA760_020</IDPARTNER><SENS>EM</SENS><MSGTYP>DOCUMENT</MSGTYP><DATORI>2018-05-28 19:41:22.0</DATORI><CURDATORI>2018-05-28</CURDATORI><DATFAC>2018-05-28 00:00:00.0</DATFAC><CURDATFAC>2018-05-28</CURDATFAC><NUMFAC>VE2016001697</NUMFAC></VO><PAGE><ID>1</ID><IDMAX>1</IDMAX><MAX_ROW>1</MAX_ROW></PAGE><CODRET>200</CODRET></GETLSTDF>';
        
        mockCalloutIdentifier.status=200;
        mockCalloutIdentifier.contentType= 'application/xml';

        Test.setMock(HttpCalloutMock.class, mockCalloutIdentifier);



        String pdfResponse = RESTPostInvoice.sendRequestForPdf(invoiceList[0].Number__c,invoiceList[0].id,'',invoiceList[0].TechCountryCode__c);
        // 
        
        Test.stopTest();
        /*PdfHttpCalloutMock mock = new PdfHttpCalloutMock();
        mock.resBody='MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw';
        mock.status=200;
        mock.contentType= 'application/pdf';

        Test.setMock(HttpCalloutMock.class, mock); 

        system.debug('##pdfResponse '+pdfResponse);
        System.assert(pdfResponse!=null);
        System.assertEquals(pdfResponse,'MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw');*/

        
    }

    @isTest static void testSendRequestIdentifierNull() {

        Test.startTest();
        CustomControllerBase customCon;
        RESTPostInvoice controller = new RESTPostInvoice(customCon);

        PdfHttpCalloutMock mockCalloutIdentifier = new PdfHttpCalloutMock();
        mockCalloutIdentifier.resBody='<?xml version="1.0" encoding="ISO-8859-1"?><GETLSTDF><ENTETE><LOGIN>aspis.integration</LOGIN><PASSWORD>*</PASSWORD></ENTETE><CRITERIA><SENS>EM</SENS><CURDATORI_INF>2016-01-01</CURDATORI_INF><NUMFAC>VE2016001697</NUMFAC><ESPARCHI><IDCTRCPT>FR0000121760_001</IDCTRCPT></ESPARCHI></CRITERIA><VO><IDDOC></IDDOC><ESPARCHI>FR0000121760_001</ESPARCHI><IDPARTNER>FR0ALPHA760_020</IDPARTNER><SENS>EM</SENS><MSGTYP>DOCUMENT</MSGTYP><DATORI>2018-05-28 19:41:22.0</DATORI><CURDATORI>2018-05-28</CURDATORI><DATFAC>2018-05-28 00:00:00.0</DATFAC><CURDATFAC>2018-05-28</CURDATFAC><NUMFAC>VE2016001697</NUMFAC></VO><PAGE><ID>1</ID><IDMAX>1</IDMAX><MAX_ROW>1</MAX_ROW></PAGE><CODRET>200</CODRET></GETLSTDF>';
        mockCalloutIdentifier.status=200;
        mockCalloutIdentifier.contentType= 'application/xml';

        Test.setMock(HttpCalloutMock.class, mockCalloutIdentifier);

        String pdfResponse = RESTPostInvoice.sendRequestForPdf(invoiceList[0].Number__c,invoiceList[0].id,'',invoiceList[0].TechCountryCode__c);
        // 
        
        Test.stopTest();
    }
     
}