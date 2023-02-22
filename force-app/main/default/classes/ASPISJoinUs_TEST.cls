/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUs_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISJoinUs
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 25-JAN-2017  ABT     1.0    Initial version
-- 24-AUG-2020  WCH     1.1    C-003838 Nob - Migrate Billing information to new fields
-- 20-OCT-2020  WCH     1.2    C-003958 - NOB - review all test classes for impacts nobilas
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISJoinUs_TEST
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static BusinessHours defaultHours;
    static List<CountryCodeInformationsMapping__c> countryMappingList;

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

                TestFactory.createAccountBodyshop('BodyShop_3', 'DE'),
                TestFactory.createAccountDistributor('Distributor_3', 'DE')
            };

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_DE', accountList[4]),
                TestFactory.createAssessment('Assessment_FR_Without_BS', new Account())             
            };

            assessmentList[1].TECH_EntityCountryCode__c = 'ES';
            assessmentList[2].TECH_EntityCountryCode__c = 'DE';
            insert assessmentList;

            // access Business Hours 
            defaultHours = [SELECT  Id
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('DE', defaultHours.Id)
            };

            countryMappingList[0].CountryVAT__c = 21;
            countryMappingList[1].CountryVAT__c = 21;
            
            insert countryMappingList;
        }
    }

    public class ReCaptchaResponse implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HTTPResponse response = new HTTPResponse();
            response.setBody('{"success":true}');
            response.setStatusCode(200);
            response.setStatus('OK');

            return response;
        }
    }

    @isTest static void constructorWithoutAnyParameters_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            Test.startTest();
                ASPISJoinUs controller = new ASPISJoinUs();
            Test.stopTest();

            System.assertEquals('fr', controller.language);
            System.assertEquals('FR', controller.country);
            System.assertNotEquals(null, controller.currentAccount);
            System.assertNotEquals(null, controller.currentContact);
            System.assertEquals(21, controller.currentAccount.VAT__c);          
        }
    }

    @isTest static void constructorWithLanguageOnly_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('lang', 'fr');

            Test.startTest();
                ASPISJoinUs controller = new ASPISJoinUs();
            Test.stopTest();

            System.assertEquals('fr', controller.language);
            System.assertEquals('FR', controller.country);
            System.assertNotEquals(null, controller.currentAccount);
            System.assertNotEquals(null, controller.currentContact);
            System.assertEquals(21, controller.currentAccount.VAT__c);          
        }
    }

    @isTest static void constructorWithCountryOnly_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('country', 'ES');

            Test.startTest();
                ASPISJoinUs controller = new ASPISJoinUs();
            Test.stopTest();

            System.assertEquals('fr', controller.language);
            System.assertEquals('ES', controller.country);
            System.assertNotEquals(null, controller.currentAccount);
            System.assertNotEquals(null, controller.currentContact);
            System.assertEquals(21, controller.currentAccount.VAT__c);          
        }
    }

    @isTest static void constructorWithAssessment_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            Test.startTest();
                ASPISJoinUs controller = new ASPISJoinUs();
            Test.stopTest();

            System.assertEquals('fr', controller.language);
            System.assertEquals('DE', controller.country);
            System.assertNotEquals(null, controller.currentAccount);
            System.assertNotEquals(null, controller.currentContact);
            System.assertEquals(21, controller.currentAccount.VAT__c);          
        }
    }

    @isTest static void changeLanguageWithAssessment_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));
            ApexPages.currentPage().getParameters().put('language', 'DE');

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.language = 'es';
            
            Test.startTest();
                PageReference currentPageRef = controller.changeLanguage();
            Test.stopTest();

            System.assertEquals('es', controller.language);
            System.assertEquals('DE', controller.country);

            PageReference expectedPageRef = Page.ASPISJoinUs;
            expectedPageRef.getParameters().put('lang', 'es');
            expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
        }
    }

    @isTest static void changeLanguageWithCountry_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('country', 'es');

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.language = 'es';
            
            Test.startTest();
                PageReference currentPageRef = controller.changeLanguage();
            Test.stopTest();

            System.assertEquals('es', controller.language);
            System.assertEquals('ES', controller.country);

            PageReference expectedPageRef = Page.ASPISJoinUs;
            expectedPageRef.getParameters().put('lang', 'es');
            expectedPageRef.getParameters().put('country', 'ES');

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
        }
    }

    @isTest static void submitFormWithAssessmentWithNoResponse_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '123456 8789 $$';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertEquals(true, controller.hasErrors);
            System.assertEquals(null, currentPageRef);
        }
    }

    @isTest static void submitFormWithAssessmentWithNoMock_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '123456 8789 $$';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');
            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertEquals(true, controller.hasErrors);
            System.assertEquals(null, currentPageRef);
        }
    }

    @isTest static void submitFormWithAssessment_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);
            Test.setMock(HttpCalloutMock.class, new ReCaptchaResponse());

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.Name              = 'Test Account';
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '123456 8789 $$';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');

            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertNotEquals(null, controller.currentAccount.Id);
            System.assertNotEquals(null, controller.currentContact.Id);
            

            PageReference expectedPageRef = Page.ASPISJoinUsConfirmation;
            expectedPageRef.getParameters().put('lang', 'fr');
            expectedPageRef.getParameters().put('country', assessmentList[2].TECH_EntityCountryCode__c);
            expectedPageRef.getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentAccount.Id)));
            expectedPageRef.getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentContact.Id)));

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
            System.assertEquals(false, controller.hasErrors);
            System.assertEquals('1234568789', controller.currentAccount.LocalReferenceNumber__c);
        }
    }

    @isTest static void submitFormWithCountry_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);
            Test.setMock(HttpCalloutMock.class, new ReCaptchaResponse());

            ApexPages.currentPage().getParameters().put('country', 'FR');
            ApexPages.currentPage().getParameters().put('lang', 'fr');

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.Name              = 'Test Account';
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '1234568789';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');

            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertNotEquals(null, controller.currentAccount.Id);
            System.assertNotEquals(null, controller.currentContact.Id);
            

            PageReference expectedPageRef = Page.ASPISJoinUsConfirmation;
            expectedPageRef.getParameters().put('lang', 'fr');
            expectedPageRef.getParameters().put('country', 'FR');
            expectedPageRef.getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentAccount.Id)));
            expectedPageRef.getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentContact.Id)));

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
        }
    }

    @isTest static void submitFormWithError_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);
            Test.setMock(HttpCalloutMock.class, new ReCaptchaResponse());

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '1234568789';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');

            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertEquals(null, controller.currentAccount.Id);
            System.assertEquals(null, controller.currentContact.Id);
            System.assertEquals(true, ApexPages.hasMessages());
            System.assertEquals(null, currentPageRef);
        }
    }

    @isTest static void submitFormWithoutOverwritingBodyShop_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);
            Test.setMock(HttpCalloutMock.class, new ReCaptchaResponse());

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[2].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.Name              = 'Test Account';
            controller.currentAccount.BillingStreet__c     = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '1234568789';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');

            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertNotEquals(null, controller.currentAccount.Id);
            System.assertNotEquals(null, controller.currentContact.Id);

            PageReference expectedPageRef = Page.ASPISJoinUsConfirmation;
            expectedPageRef.getParameters().put('lang', 'fr');
            expectedPageRef.getParameters().put('country', assessmentList[2].TECH_EntityCountryCode__c);
            expectedPageRef.getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentAccount.Id)));
            expectedPageRef.getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentContact.Id)));

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());

            Assessment__c currentAssessment = [ SELECT Id, BodyShop__c
                                                FROM Assessment__c 
                                                WHERE Id =: assessmentList[2].Id];
                                                
            System.assertEquals(accountList[4].Id, currentAssessment.BodyShop__c);
        }
    }

    @isTest static void submitFormWithAssessmentNotHavingBodyShop_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.ASPISJoinUs);
            Test.setMock(HttpCalloutMock.class, new ReCaptchaResponse());

            ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(Blob.valueOf(assessmentList[3].Id)));

            ASPISJoinUs controller = new ASPISJoinUs();
            controller.currentAccount.Name              = 'Test Account';
            controller.currentAccount.BillingStreet__c    = 'Colonia Allee 10 – 20';
            controller.currentAccount.BillingCity__c       = 'Köln';
            controller.currentAccount.BillingPostalCode__c = '51067';

            controller.currentAccount.Phone             = '123456789';
            controller.currentAccount.Fax               = '123456789';
            controller.currentAccount.LocalReferenceNumber__c = '1234568789';

            controller.currentContact.Salutation        = 'Mr';
            controller.currentContact.LastName          = 'Scale';
            controller.currentContact.FirstName         = 'Alpha';
            List<String> checkLanguage = controller.setLanguageCodeLanguage;
            
            ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'testResponse');

            Test.startTest();
                PageReference currentPageRef = controller.submitForm();
            Test.stopTest();

            System.assertNotEquals(null, controller.currentAccount.Id);
            System.assertNotEquals(null, controller.currentContact.Id);

            PageReference expectedPageRef = Page.ASPISJoinUsConfirmation;
            expectedPageRef.getParameters().put('lang', 'fr');
            expectedPageRef.getParameters().put('country', assessmentList[3].TECH_EntityCountryCode__c);
            expectedPageRef.getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentAccount.Id)));
            expectedPageRef.getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(controller.currentContact.Id)));

            System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());

            Assessment__c currentAssessment = [ SELECT Id, BodyShop__c
                                                FROM Assessment__c 
                                                WHERE Id =: assessmentList[3].Id];
                                                
            System.assertNotEquals(null, currentAssessment.BodyShop__c);
            System.assertEquals(controller.currentAccount.Id, currentAssessment.BodyShop__c);
        }
    }
}