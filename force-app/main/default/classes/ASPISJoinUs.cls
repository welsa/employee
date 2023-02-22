/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUs
-- - Author        : ABT
-- - Description   : Controller for ASPISJoinUs
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 04-JAN-2017  ABT     1.0         Initial version
-- 30-MAR-2018  VSU     1.1         C-002315 Cross Scripting
-- 24-AUG-2020  WCH     1.2         C-003838 - Nob - Migrate Billing information to new fields
----------------------------------------------------------------------
**********************************************************************
*/
global class ASPISJoinUs
{
    private final String secret = Label.CaptchaSecretKey;

    global Account currentAccount {get; set;}
    global Contact currentContact {get; set;}
    global String language {get; set;}
    global String country {get; set;}
    global String encryptedText {get; set;}
    global Boolean hasErrors {get; set;}
    // Variable to state whether to display the error message in the toast
    global Boolean isToastError {get; set;}
    global Boolean showWelcomeMessage {get; set;}
    global Boolean unauthorizedId {get;set;}
    global Map<String, String> mapLanguageCodeLanguage {
        get 
        { 
            return new Map<String, String>
            {
                
                'fr'    => 'France - Français',
                'it'    => 'Italia - Italiano'/*,
                'de'    => 'Deutschland - Deutsch',
                'fr_BE'  => 'Belgique - Français',
                'nl_BE'  => 'België - Nederlands',
                'es'    => 'Español',
                 */
            };
        }
    }
    
    global List<String> setLanguageCodeLanguage {
        get 
        { 
            return new List<String>
            {
                
                'fr',
                'it'
            };
        }
    }

    private Assessment__c currentAssessment;

    global ASPISJoinUs()
    {
        // Initialising variable
        hasErrors           = false;
        isToastError        = false;
        unauthorizedId = false;
        
        showWelcomeMessage = true;

        String acceptLanguage   = ApexPages.currentPage().getHeaders().get('Accept-Language');

        String browserPreferedLanguage = 'fr';
        
        if(String.isNotBlank(acceptLanguage))
        {
            if(acceptLanguage.length()==2)
                browserPreferedLanguage = acceptLanguage.substring(0, 2);
            else if(acceptLanguage.length()==5)
                browserPreferedLanguage = acceptLanguage.substring(0, 5);
        }

        // Getting the language
        language                = !String.isBlank(ApexPages.currentPage().getParameters().get('lang')) && 
                                    mapLanguageCodeLanguage.containsKey(ApexPages.currentPage().getParameters().get('lang').toLowerCase()) 
                                  ? 
                                    ApexPages.currentPage().getParameters().get('lang').toLowerCase() : browserPreferedLanguage;


        if(language.startsWith('it'))
            language = 'it';
        else if(language.startsWith('fr'))
            language = 'fr';
        
        if(! 'fr_it'.contains(language.substring(0,2)))
            language = 'fr';
            
            
        // Getting the country (Can be override by assessment)
        country             = String.isBlank(ApexPages.currentPage().getParameters().get('country')) ? 'FR' : ApexPages.currentPage().getParameters().get('country').toUpperCase();

        // Capturing the assessment id received
        encryptedText       = ApexPages.currentPage().getParameters().get('AssessmentId');

        // checking if there is the assessment
        try
        {
            String assessmentId = decryptBase64AssessmentId(encryptedText);

            //VSU 30/03/18 
            if(assessmentId != null){
                system.debug('##assessmentId '+ assessmentId);
                
                Id anId = assessmentId;

                currentAssessment   = [ SELECT  Id, BodyShop__c, TECH_EntityCountryCode__c
                                        FROM    Assessment__c
                                        WHERE   Id =: assessmentId];
                unauthorizedId = false;

                if( currentAssessment != null &&
                    currentAssessment.TECH_EntityCountryCode__c != null)
                {
                    country = currentAssessment.TECH_EntityCountryCode__c.toUpperCase();
                }

                System.debug('## Assessment : ' + currentAssessment);
            }
        } 
        catch(Exception e) {
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                hasErrors = true;
                isToastError = true;
                unauthorizedId = true;        
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
        }

        initialiseSObject();
    }

    private void initialiseSObject()
    {
        // Getting the country default VAT__c from the custom setting
        CountryCodeInformationsMapping__c currentCountryInfo    = CountryCodeInformationsMapping__c.getInstance(country);
        currentCountryInfo                                      = (currentCountryInfo != null) ? currentCountryInfo : CountryCodeInformationsMapping__c.getInstance('DEFAULT');

        // Initialising the Account and Contact
        currentAccount = new Account(   VAT__c              = ((currentCountryInfo != null && currentCountryInfo.CountryVAT__c != null) ? currentCountryInfo.CountryVAT__c : 21),
                                        BillingCountryCode__c  = country, BillingCountry__c = currentCountryInfo.Country_Name__c ,//WCH C-003838 24/08/2020
                                        RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lead').getRecordTypeId());

        currentContact = new Contact(Title = 'CEO');
    }

    global PageReference changeLanguage()
    {
        showWelcomeMessage = true;

        PageReference currentPageRef = Page.ASPISJoinUs;
        currentPageRef.getParameters().put('lang', language);

        if(!String.isBlank(encryptedText))
        {
            currentPageRef.getParameters().put('AssessmentId', encryptedText);
        }
        else if (!String.isBlank(country))
        {
            currentPageRef.getParameters().put('country', country);
        }

        currentPageRef.setRedirect(true);

        return currentPageRef;
    }

    global String decryptBase64AssessmentId(String encryptedText)
    {
        Blob decryptedData      = EncodingUtil.base64Decode(encryptedText);
        String decryptedText    = decryptedData.toString();

        return decryptedText;
    }

    global PageReference submitForm()
    {
        // Setting hasErrors to false (to make the error message disappear after correcting the error)
        hasErrors = false;
        isToastError = false;
        showWelcomeMessage = false;

        // Creating a savepoint
        SavePoint beforeDML;

        try
        {
            // moving this code inside try catch in case deserialise of the JSON goes wrong
            if(!verfiyReCaptcha())
            {
                hasErrors = true;
                isToastError = true;

                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid reCaptcha'));
                return null;
            }

            beforeDML = Database.setSavepoint();

            // Save the Account
            // Copy the billing address to shipping address
            //WCH 24/08/2020 C-003838
            currentAccount.ShippingStreet       = currentAccount.BillingStreet__c;
            currentAccount.ShippingCity         = currentAccount.BillingCity__c;
            currentAccount.ShippingState        = currentAccount.BillingState__c;
            currentAccount.ShippingPostalCode   = currentAccount.BillingPostalCode__c;
            currentAccount.ShippingCountryCode  = currentAccount.BillingCountryCode__c;
            currentAccount.BillingCountryCode__c = currentAccount.BillingCountryCode;
            currentAccount.BillingCountryCode=null;

            if(currentAccount.LocalReferenceNumber__c != null)
            {
                currentAccount.LocalReferenceNumber__c = currentAccount.LocalReferenceNumber__c.replaceAll('[^A-Za-z0-9]', '');
            }

            insert currentAccount;

            // Save the Contact
            // Attach the contact to the account
            currentContact.AccountId            = currentAccount.Id;

            // Copy the address of the account to the address of the contact
            //WCH 24/08/2020 C-003838
            currentContact.MailingStreet        = currentAccount.BillingStreet__c;
            currentContact.MailingCity          = currentAccount.BillingCity__c;
            currentContact.MailingState         = currentAccount.BillingState__c;
            currentContact.MailingPostalCode    = currentAccount.BillingPostalCode__c;
            currentContact.MailingCountryCode   = currentAccount.BillingCountryCode__c;

            // Copy the phone and fax from the account
            currentContact.Phone                = currentAccount.Phone;
            currentContact.Fax                  = currentAccount.Fax;

            insert currentContact;


            // Attaching the Account to the assessment in case the assessment does not have a bodyshop attached to it
            System.debug('## Assessment : ' + currentAssessment);
            if(currentAssessment != null && currentAssessment.BodyShop__c == null)
            {
                Assessment__c assessmentToUpdate = new Assessment__c(Id          = currentAssessment.Id,
                                                                     BodyShop__c = currentAccount.Id);

                update assessmentToUpdate;
            }

            PageReference confirmationPage  = Page.ASPISJoinUsConfirmation;
            confirmationPage.getParameters().put('lang', language);
            confirmationPage.getParameters().put('country', country);

            if(currentAccount.Id != null && currentContact.Id != null)
            {
                confirmationPage.getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(currentAccount.Id)));
                confirmationPage.getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(currentContact.Id)));
            }

            confirmationPage.setRedirect(false);

            return confirmationPage;

            // setting the boolean isSuccessful to true so as to tigger the download of the PDF
            // isSuccessful = true;
        }
        catch(DmlException e)
        {
            hasErrors = true;
            
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }

            // Rollback to prevent inconsistency of data
            Database.rollback(beforeDML);

            // clearing the Ids
            currentAccount.Id = null;
            currentContact.Id = null;
        }
        catch(Exception e)
        {
            hasErrors = true;

            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
        }
        
        return null;
    }

    global Boolean verfiyReCaptcha()
    {
        //String reCaptchaVerifyURL   = 'https://www.google.com/recaptcha/api/siteverify';
        String reCaptchaVerifyBody  = 'secret=' + secret;
        String reCaptchaResponse    = ApexPages.currentPage().getParameters().get('g-recaptcha-response');

        // Normally the check is done in javascript on the page
        // But added the check to ensure that the class gets it
        if(String.isBlank(reCaptchaResponse))
        {
            return false;
        }

        reCaptchaVerifyBody             += '&response=' + reCaptchaResponse;
        //String jsonResponse             = sendRequest(reCaptchaVerifyURL, reCaptchaVerifyBody);
        String jsonResponse             = sendRequest(reCaptchaVerifyBody);
        Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Boolean isSuccessful            = Boolean.valueOf(mapResponse.get('success'));

        System.debug('## reCaptchaVerifyBody: ' + reCaptchaVerifyBody);
        System.debug('## jsonResponse: ' + jsonResponse);
        System.debug('## mapResponse: ' + mapResponse);
        System.debug('## isSuccessful: ' + isSuccessful);

        return isSuccessful;
    }

    private String sendRequest(String body)
    {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        //request.setEndpoint(url);
        request.setEndpoint('callout:reCaptcha');
        request.setBody(body);

        try
        {
            Http httpCall           = new Http();
            HttpResponse response   = httpCall.send(request);
            return response.getBody();
        }
        catch (Exception e)
        {
            System.debug('## Exception: ' + e);
        }

        return '{"success":false}';
    }
}