/*
----------------------------------------------------------------------
-- - Name          : ASPISForgotPassword
-- - Author        : ABT
-- - Description   : Controller for ASPISForgotPassword
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 20-DEC-2016  ABT     1.0         Initial version
-- 17-JAN-2018  WCH     1.1         C-003021 : Users in R4 can not reset their password (Issue with community ?)
-- 17-OCT-2019  WCH     1.2         C-002781 : Spain R4
----------------------------------------------------------------------
**********************************************************************
*/
global class ASPISForgotPassword
{
    global String username {get; set;}
    global String language {get; set;}

    global ASPISForgotPassword()
    {
        // Getting the language
        // language = String.isBlank(ApexPages.currentPage().getParameters().get('lang')) ? 'en' : ApexPages.currentPage().getParameters().get('lang');

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
        //DUN 22/03/2018 changed parameter from lang to locale
        //DUN 09/04/2018 Changed local to language
        language =  String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) ? ApexPages.currentPage().getParameters().get('lang').toLowerCase() : browserPreferedLanguage;
        
        
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
    
        system.debug('##lang: '+ApexPages.currentPage().getParameters().get('lang'));
        
        

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('un')))
        {
            username = ApexPages.currentPage().getParameters().get('un');
        }
    }

    global PageReference resetPassword(){
        /*********************************/
        //AMI 15/06/18 : Community Rollout  
        string userType = '';
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

        //query connected username to set correct domain
        if(string.isNotBlank(username)){
            for(User us : [select id,Name,Profile.UserLicense.Name,Profile.Name
                            from User
                            where Username = :username]){
                if(string.isBlank(formattedLicenseName) || (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase()))){
                    userType = 'std';
                }else if(string.isNotBlank(formattedLicenseName) && 
                         formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase()) &&
                         ((us.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() ||
                         (us.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase())
                         ){
                    userType = 'R4';
                }else if(string.isNotBlank(formattedLicenseName) && 
                         formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase()) &&
                         ((us.Profile.Name).toLowerCase() == (system.label.R3BSProfileNameCommunity).toLowerCase() ||
                         (us.Profile.Name).toLowerCase() == (system.label.R3BSProfileNameCommunityLogin).toLowerCase())
                         ){
                    userType = 'R3';
                }
            }
        }//end user query

        if(userType == 'R4'){
            PageReference pr = new PageReference('https://' + system.label.CommunityDomain + '/secur/forgotpassword.jsp');
            pr.getParameters().put('un', username);
            //DUN 22/03/2018 language.left(2) not accepted with language having 5 characters e.g nl_be
            //DUN 09/04/2018 Changed local to language
            pr.getParameters().put('lang', language/*.left(2)*/);
            //WCH 17/10/2019 C-002781 : Spain R4
            pr.getParameters().put('locale', language);
            pr.setRedirect(true);

            return pr;
        }else if(userType == 'std'){
            PageReference pr = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
            pr.getParameters().put('un', username);
            //DUN 22/03/2018 language.left(2) not accepted with language having 5 characters e.g nl_be
            //DUN 09/04/2018 Changed local to language
            pr.getParameters().put('lang', language/*.left(2)*/);
            pr.setRedirect(true);

            return pr;
        }else if(userType == 'R3'){
            PageReference pr = new PageReference(Label.EmailLinkForCommunity + 'secur/forgotpassword.jsp');
            pr.getParameters().put('un', username);
            //DUN 22/03/2018 language.left(2) not accepted with language having 5 characters e.g nl_be
            //DUN 09/04/2018 Changed local to language
            pr.getParameters().put('lang', language/*.left(2)*/);
            pr.setRedirect(true);

            return pr;
        }
        //WCH 17/01/2019, C-003021 : Users in R4 can not reset their password (Issue with community ?)
        else{
            PageReference pr = new PageReference('https://' + system.label.CommunityDomain + '/secur/forgotpassword.jsp');
            pr.getParameters().put('lang', language);
            pr.getParameters().put('un', username);
            //WCH 17/10/2019 C-002781 : Spain R4
            pr.getParameters().put('locale', language);
            return pr;
        }

        return null;  
    }
}