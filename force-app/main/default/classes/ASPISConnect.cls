/*
----------------------------------------------------------------------
-- - Name          : ASPISConnect
-- - Author        : ABT
-- - Description   : Controller for ASPISConnect
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 20-DEC-2016  ABT     1.0         Initial version
-- 12-JAN-2018  VSU     1.1         Ticket 62 - modify the login - registration page (dependant picklist btw country and language)
-- 14-MAR-2018  DUN     1.2         C-002339 - Put a link in order confirmation email with delivery note redirecting to ASPISSalesOrder   
-- 05-APR-2018  VSU     1.3         C-002315 - Cross Site Scripting
-- 23-NOV-2018  AMI     1.4         C-002931 : Germany R4 : Language FR instead of DE on ASPIS login page
-- 21-DEC-2018  AMI     1.5         C-002989 : Updating language algorithm in the event we have a , in the param
-- 02-OCT-2019  WCH     1.6         C-003338 : Pen Test Vulnerability : T002 - Vulnerability 2019_ASPIS_T002: Username Oracle
-- 24-FEB-2020  WCH     1.7         C-003613 - Email to BS on R4 does not contain correct link for SO
-- 25-SEP-2020  WCH     1.7         C-003938 : NOB - Creation of Alpha-Scale Bodyshop Permission Set
-- 13-JAN-2022  NPE     1.8         C-004566 : Review Spring ’22 releases - Disable Users from Logging Into an Org or Experience Cloud Site with Login Credentials as URL Query String Parameters
----------------------------------------------------------------------
**********************************************************************
*/
global class ASPISConnect
{
    /*********************************/
    //AMI 15/06/18 : Community Rollout 
    //             : Remove leading and trailing white space when username is entered
    global String username {get; set{username = value.trim();}}

    global String password {get; set;}
    global String startURL {get; set;}
    global String language {get; set;}
    global String encryptedText {get; set;}
    global String encryptedChildIdText {get; set;}
    global String currentPageParameters {get; set;}
    global Boolean hasErrors {get; set;}
    // Variable to state whether to display the error message in the toast
    global Boolean isToastError {get; set;}
    global Boolean rememberMe {get; set;}
    global Boolean unauthorizedId {get;set;}

    //DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
    global String encryptedSOId{get;set;}
    global PrerequisiteOrder__c currentSalesOrder{get;set;}
    global Boolean isEncryptedSOBlank{get;set;}

    global Map<String, String> mapLanguageCodeLanguage {
        get 
        { 
            return new Map<String, String>
            {
                'de'    => 'Deutschland - Deutsch',
                'fr'    => 'France - Français',
                'fr_be'  => 'Belgique - Français',
                'nl_be'  => 'België - Nederlands',
                'it'    => 'Italia - Italiano',
                'es'    => 'España - Español'
            };
        }
    }

    global List<String> setLanguageCodeLanguage {
        get 
        { 
            return new List<String>
            {
                
                'fr',
                'fr_be',
                'nl_be',
                'de',
                'it',
                'es'
            };
        }
    }

    private Boolean isEncryptedTextBlank;
    private Assessment__c currentAssessment;
    global Boolean showCreateAccountButton {get; set;}

    private static final String cryptoKey = 'eIT6G4c3L/6wDN+yDsxyHO7Z1MWufsrHyOEEvAlplvw=';

    /*********************************/
    //AMI 15/06/18 : Community Rollout 
    //             : New Variable Assignement
    global boolean showUserNameOnly {get;set;}
    global boolean showPwdOnly {get;set;}
    global boolean doNotShowStdLoginError {get;set;}
    global boolean showStdLoginError {get;set;}
    global string userType {get;set;}

    private string unameTransmitted = '';
    private string headerdata = '';
    private string urlvalue = '';
    private string currentUrl = '';
    private string isStartPresent = '';
    private string realUrl = '';
    private string decodedPageParam = '';

    global ASPISConnect()
    {
        /*********************************/
        //AMI 15/06/18 : Community Rollout  
        showUserNameOnly = false;
        showPwdOnly = false;
        userType = '';

        userType = String.isNotBlank(ApexPages.currentPage().getParameters().get('ut')) ? 
                   ApexPages.currentPage().getParameters().get('ut') : '';

        unameTransmitted = String.isNotBlank(ApexPages.currentPage().getParameters().get('ret')) ? 
                           ApexPages.currentPage().getParameters().get('ret') : '';
        system.debug('## unameTransmitted ' + unameTransmitted);

        headerdata = ApexPages.currentPage().getHeaders().get('Host');
        urlvalue = Apexpages.currentPage().getUrl();
        currentUrl = headerdata+ urlvalue;
        system.debug('## currentUrl ' + currentUrl);

        isStartPresent = String.isNotBlank(ApexPages.currentPage().getParameters().get('startURL'))? 
                         ApexPages.currentPage().getParameters().get('startURL') : '';
        system.debug('## isStartPresent ' + isStartPresent);

        doNotShowStdLoginError = true;
        showStdLoginError = false;

        // Initialising error variable
        hasErrors               = false;
        isToastError            = false;
        unauthorizedID          = false;

        String acceptLanguage   = ApexPages.currentPage().getHeaders().get('Accept-Language');
        system.debug('## acceptLanguage ' + acceptLanguage);
        
        String browserPreferedLanguage = 'fr';
        
        //AMI 23/11/18 - C-002931 : Germany R4 : Language FR instead of DE on ASPIS login page
        //                        : Retrieving only first 5 characters received on browser Accept-Language
        if(String.isNotBlank(acceptLanguage)){
            browserPreferedLanguage = acceptLanguage.LEFT(5);
        }

        // Getting the language
        /*********************************/
        //AMI 15/06/18 : Community Rollout  
        if(string.isNotBlank(isStartPresent)){
            string decodedStartUrl = EncodingUtil.urlDecode(isStartPresent,'UTF-8');
            string decodedLanguage = decodedStartUrl.substringBetween('lang=','&');
            language               = String.isNotBlank(decodedLanguage) && mapLanguageCodeLanguage.containsKey(decodedLanguage) ? decodedLanguage : browserPreferedLanguage;

        }else{
            language               = String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) && 
                                     mapLanguageCodeLanguage.containsKey(ApexPages.currentPage().getParameters().get('lang')) ? 
                                     ApexPages.currentPage().getParameters().get('lang') :browserPreferedLanguage;
        }
        system.debug('##Language: '+language);

        //AMI 21/12/2018 : C-002989 - Updating language algorithm in the event we have a , in the param
        if(language.contains(',')){
            language = language.substringBefore(',');
        }

        language = language.tolowercase().replaceAll('-','_');
        if(language.startsWith('fr_') && language <> 'fr_BE')
            language = 'fr';
        else if(language=='nl')
            language = 'nl_be';
        else if(language.startsWith('de'))
            language = 'de';
        else if(language.startsWith('it'))
            language = 'it';
        else if(language.startsWith('es'))
            language = 'es';
        
        if(! 'fr_it_de_nl_es'.contains(language.substring(0,2)))
            language = 'fr';

        system.debug('##Language: '+language);

        showCreateAccountButton = false;//(language == 'fr') ? false : true;

        /*********************************/
        //AMI 15/06/18 : Community Rollout  
        if(string.isBlank(username) && string.isNotBlank(getCookieUsername())){
            username = getCookieUsername();
        }

        rememberMe = true;

        // Capturing the assessment id received
        encryptedText           = ApexPages.currentPage().getParameters().get('AssessmentId');
        encryptedChildIdText    = ApexPages.currentPage().getParameters().get('ChildId');
        //DUN 14/03/2018 C-002339  - Redirect to  ASPISSalesOrder
        encryptedSOId           = ApexPages.currentPage().getParameters().get('Id');

        isEncryptedTextBlank    = String.isBlank(encryptedText);
        //DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
        isEncryptedSOBlank = String.isBlank(encryptedSOId);

        // Capturing all the parameters passed to the page and push it as startURL in the login page
        currentPageParameters   = URL.getCurrentRequestUrl().getQuery();
        
        /*********************************/
        //AMI 15/06/18 : Community Rollout  
        if(string.isNotBlank(currentPageParameters)){
            decodedPageParam = EncodingUtil.urlDecode(currentPageParameters,'UTF-8');
        }

        if(string.isNotBlank(isStartPresent)){
            unameTransmitted = decodedPageParam.substringBetween('ret=','&');
            system.debug('## unameTransmitted ' + unameTransmitted);
            //replace %3D with = so that no error is generated wgen decoding =
            //= is converted into %3D when transmitted through url
            if(string.isNotBlank(unameTransmitted)){
                unameTransmitted = unameTransmitted.replaceAll('%3D','=');
            }
            //WCH 24/02/2020 C-003613
            if(string.isNotBlank(unameTransmitted)){
                username = decryptBase64(unameTransmitted);
                showPwdOnly = true;
                showUserNameOnly = false;
            }else{
                showPwdOnly = false;
                showUserNameOnly = true;
            }
            
            
        }else{
            showUserNameOnly = true;
            showPwdOnly = false;
        }

        system.debug('## currentPageParameters: ' + currentPageParameters);
        system.debug('## decodedPageParam: ' + decodedPageParam);
        if(string.isNotBlank(isStartPresent)){
            startURL            = decodedPageParam.replace('startURL=','');
        }else{
            if(String.isBlank(encryptedChildIdText) && String.isBlank(encryptedSOId)){
                startURL            = '/apex/OrderChooseAssessment?' + (currentPageParameters != null ? currentPageParameters : '');
            }else if(!String.isBlank(encryptedSOId)){
                startURL            = '/apex/ASPISSalesOrder?Id=' + encryptedSOId;
            }else{
                startURL            = '/apex/OrderMakeSelection?Id=' + encryptedText + '&ChildId=' + encryptedChildIdText;
            }
        }

        try
        {
            
            if(encryptedText != null){
                String assessmentId = decryptBase64(encryptedText);

                //VSU 05/04/18 C-002315 
                Id anId = assessmentId;
                unauthorizedId = false;

                currentAssessment = [   SELECT  Id, TECH_EntityCountryCode__c
                                        FROM    Assessment__c
                                        WHERE   Id =: assessmentId];
            }

            if(currentAssessment != null && showCreateAccountButton) //&& currentAssessment.TECH_EntityCountryCode__c == 'FR' )
            {
                showCreateAccountButton = false;
            }

            
        }
        catch(Exception e)
        {
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){//VSU 05/04/18 C-002315
                hasErrors = true;
                isToastError = true;
                unauthorizedId = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
        }

        //DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
        try
        {           
            if(encryptedSOId != null){
                String salesOrderId = decryptBase64(encryptedSOId);
                //VSU 05/04/18 C-002315 
                Id anId = salesOrderId;
                unauthorizedId = false;

                currentSalesOrder = [   SELECT  Id
                                    FROM    PrerequisiteOrder__c
                                    WHERE   Id =: salesOrderId];
            }

            if(currentSalesOrder != null && showCreateAccountButton)
            {
                showCreateAccountButton = false;
            }
        }
        catch(Exception e)
        {
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){//VSU 05/04/18 C-002315
                hasErrors = true;
                isToastError = true;
                unauthorizedId = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
        }
    }

    /*********************************/
    //AMI 15/06/18 : Community Rollout  
    global PageReference redirectToCorrectDomain(){
        system.debug('## Start redirectToCorrectDomain');

        string encryptedUserName = string.isNotBlank(username) && string.isBlank(unameTransmitted) ?  encryptBase64(username.trim()) : '';
        system.debug('##encryptedUserName: '+ encryptedUserName);

        PageReference redirectPage;

        hasErrors = false;
        isToastError = false;

        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
        system.debug('username>>'+username);
        //query connected username to set correct domain
        if(string.isNotBlank(username) && string.isBlank(unameTransmitted)){
            List <User> usList = [select id,Name,Profile.UserLicense.Name,Profile.Name
                                    from User
                                    where Username = :username];
            system.debug('usList>>'+usList);
            if(usList.isEmpty()){
                //WCH 02/10/2019 C-003338 : comment code
                userType = 'R4';
                /* WCH 02/10/2019 C-003338 : comment code
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, system.label.IncorrectUsername)); */
            }else{
                if(string.isBlank(formattedLicenseName) || (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((usList[0].Profile.UserLicense.Name).toLowerCase()))){
                    userType = 'std';
                }else if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains((usList[0].Profile.UserLicense.Name).toLowerCase()) && ((usList[0].Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() || (usList[0].Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase() ||
                         (usList[0].Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityPrefikar).toLowerCase()/* WCH 25/09/2020 C-003938 */) ){
                    userType = 'R4';
                }else if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains((usList[0].Profile.UserLicense.Name).toLowerCase()) && ((usList[0].Profile.Name).toLowerCase() == (system.label.R3BSProfileNameCommunity).toLowerCase() || (usList[0].Profile.Name).toLowerCase() == (system.label.R3BSProfileNameCommunityLogin).toLowerCase()) ){
                    userType = 'R3';
                }
            }
        }//end user query

        system.debug('##Language: '+language);
        system.debug('## currentPageParameters: ' + currentPageParameters);
        system.debug('## currentUrl ' + currentUrl);
        system.debug('## userType ' + userType);
        if(userType == 'R4'){
            string retUrl = startURL;

            if(isEncryptedTextBlank && isEncryptedSOBlank){
                retUrl = '/apex/Search';
            }

            //redirect only if domain is not correct
            if(currentUrl.contains(system.label.CommunityDomain)){
                showPwdOnly = true;
                showUserNameOnly = false;
            }else{
                //add username + type
                if(retUrl == '/apex/Search'){
                    //adding start ? parameter in case no start query param is present
                    retUrl = retUrl + '?ret=' + encryptBase64(username) + '&ut=' + userType;
                }else{
                    retUrl = retUrl + '&ret=' + encryptBase64(username) + '&ut=' + userType;
                }
                system.debug('## retUrl ' + retUrl);
                redirectPage = new PageReference('https://' + system.label.CommunityDomain + retUrl);
                redirectPage.setRedirect(true);
                setCookieUsername();
                return redirectPage;
            } 
        }else if(userType == 'std'){
            showPwdOnly = true;
            showUserNameOnly = false;
            setCookieUsername();
            unameTransmitted = username;
            userType = 'std';

            return null;
        }else if(userType == 'R3'){
            showPwdOnly = true;
            showUserNameOnly = false;
        }

        return null;
    }//end redirectToCorrectDomain  

    /*********************************/
    //AMI 15/06/18 : Community Rollout  
    global PageReference systemLogin(){
        system.debug('## Start systemLogin');

        PageReference redirectPage;

        system.debug('## username ' + username);
        system.debug('## password ' + password);
        system.debug('## startURL ' + startURL);
        if(string.isNotBlank(username) && string.isNotBlank(password)){   
            //redirect based on parameters
            if(startURL.contains('ut=R4')){
                string retUrl = startURL;
                redirectPage = Site.login(username,password,retUrl);
                system.debug('## redirectPage ' + redirectPage);
                if(redirectPage == null){
                    //raise error
                    hasErrors = true;
                    isToastError = true;
                    doNotShowStdLoginError = false;
                    showStdLoginError = true;
                }else{
                    return redirectPage;
                }               
            }
            //login after logout or after langauage change
            else if(userType == 'R4' && 
                    (string.isBlank(currentPageParameters) ||
                    (string.isNotBlank(currentPageParameters) && 
                    currentPageParameters.contains('lang')))){

                redirectPage = Site.login(username,password,'/apex/Search');

                if(redirectPage == null){
                    //raise error
                    hasErrors = true;
                    isToastError = true;
                    
                    doNotShowStdLoginError = false;
                    showStdLoginError = true;
                }else{
                    return redirectPage;
                }
            }else if(userType == 'std'){
                redirectPage = new PageReference(Label.AlphaScaleDomain);
                
                if(isEncryptedTextBlank && isEncryptedSOBlank){ 
                    redirectPage.getParameters().put('startURL', '/apex/Search');
                }else{
                    redirectPage.getParameters().put('startURL', startURL);
                }

                redirectPage.getParameters().put('un', username);
                redirectPage.getParameters().put('pw', password);
                redirectPage.getParameters().put('lang', language);
                redirectPage.setRedirect(true);
                system.debug('## redirectPage '+ redirectPage);
                return redirectPage;
            }else if(userType == 'R3'){
                 // string communityUrl = Label.EmailLinkForCommunity;
                // communityUrl += 'login?un=' + username;
                // communityUrl += '&pw=' + password;

                // redirectPage = new PageReference(communityUrl);
                // redirectPage.setRedirect(true);
                // system.debug('## redirectPage '+ redirectPage);
                // return redirectPage;

                //NPE 13/01/2022- C-004566- Review Spring ’22 releases 
                redirectPage = new PageReference(Label.EmailLinkForCommunity);
                
                if(isEncryptedTextBlank && isEncryptedSOBlank){ 
                    redirectPage.getParameters().put('startURL', '/apex/Search');
                }else{
                    redirectPage.getParameters().put('startURL', startURL);
                }

                redirectPage.getParameters().put('un', username);
                redirectPage.getParameters().put('pw', password);
                redirectPage.getParameters().put('lang', language);
                redirectPage.setRedirect(true);
                system.debug('## redirectPage '+ redirectPage);
                return redirectPage;
            }
            /* WCH 24/02/2020 C-003613 */
            else if(userType == 'R4'){
                string retUrl = startURL;
                redirectPage = Site.login(username,password,retUrl);
                system.debug('## redirectPage ' + redirectPage);
                if(redirectPage == null){
                    //raise error
                    hasErrors = true;
                    isToastError = true;
                    doNotShowStdLoginError = false;
                    showStdLoginError = true;
                }else{
                    return redirectPage;
                }               
            }
        }//end if(string.isNotBlank(username) && string.isNotBlank(password)){

        return null;
    }//end systemLogin

    global PageReference changeLanguage()
    {
        PageReference currentPageRef = Page.ASPISConnect;
        currentPageRef.getParameters().put('lang', language);

        if(string.isNotBlank(userType)){
            currentPageRef.getParameters().put('ut', userType);
        }

        if(!isEncryptedTextBlank)
        {
            currentPageRef.getParameters().put('AssessmentId', encryptedText);
        }

        currentPageRef.setRedirect(true);

        return currentPageRef;
    }

    global String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    global String decryptBase64(String encryptedText)
    {
        Blob decryptedData      = EncodingUtil.base64Decode(encryptedText);
        String decryptedText    = decryptedData.toString();

        return decryptedText;
    }

    global void setCookieUsername()
    {
        String dataToStore = '';
        
        if(rememberMe)
        {
            Blob cryptoKeyBlob = EncodingUtil.base64Decode(cryptoKey);

            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKeyBlob, Blob.valueOf(username));

            dataToStore = EncodingUtil.base64Encode(encryptedData);
        }

        Cookie usernameCookie = new Cookie('username', dataToStore, null, 7889400, true);

        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie});
    }

    global String getCookieUsername()
    {
        Cookie usernameCookie = ApexPages.currentPage().getCookies().get('username');
        
        try
        {
            if(usernameCookie != null)
            {
                Blob usernameBlob  = EncodingUtil.base64Decode(usernameCookie.getValue());
                Blob cryptoKeyBlob = EncodingUtil.base64Decode(cryptoKey);
                Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKeyBlob, usernameBlob);

                return decryptedData.toString();
            }
        }
        catch(Exception e){}
        
        return '';
    }

    global PageReference forgotPassword()
    {
        PageReference pageRef = Page.ASPISForgotPassword;

        if(String.isNotBlank(username))
        {
            pageRef.getParameters().put('un', username);
            setCookieUsername();
        }

        //DUN 22/03/2018 language.left(2) not accepted with language having 5 characters e.g nl_be
        //DUN 09/04/2018 Changed local to language
        pageRef.getParameters().put('lang', language/*.left(2)*/);
        
        pageRef.setRedirect(true);
        return pageRef;
    }
}