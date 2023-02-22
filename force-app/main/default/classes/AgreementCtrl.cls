/***************************************************************************************************************
Class Name - AgreementCtrl
Version - 2.0
Created Date - unknown
Function - Class to manage business hours/days methods and new cache feature

Modification Log :
------------------------------------------------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  --------------------------------------------------------------------------------------
* Immo S		08/07/2015	Original Version.
* Cécile L      13/05/2016 	Optimisations
******************************************************************************************************************/
public without sharing class AgreementCtrl {
    //###########################
    //#   A.T.T.R.I.B.U.T.E.S	#
    //###########################    
    public User CurrentUser;
    public String MyUrl;
    
    public static CS_Agreement__c defaultConfig;
    public CS_Agreement__c MyAgreement {get; set;}
    
    public boolean AgreementNeeded {get; set;}
    public string AgreementName {get; set;}
    public string AgreementBody {get; set;}
    
    //###########################
    //#   	M.E.T.H.O.D.S		#
    //###########################    
    //*
    // @author Cecile L
    // @date 13/05/2016
    // @description Find the configuration to use based on the connected user language, then display the agreement document.
    //***/ 
    public void Init(){  
        // Get the custom setting used by default
        List<CS_Agreement__c> l_AllConfigs = CS_Agreement__c.getAll().values();
        for(CS_Agreement__c ag : l_AllConfigs){
            if(ag.General__c)
                defaultConfig = ag;
        }
        
        MyUrl = ApexPages.currentPage().getHeaders().get('referer');
        AgreementNeeded = false;
        
        // Get the name of config defined as URL parameter, if exist.
        AgreementName = ApexPages.CurrentPage().getParameters().get('name');
        
        // We already decided which configuration use, so we just load the config and use the settings defined inside
        if(AgreementName != null && AgreementName != ''){
            AgreementNeeded = true;
            
            // Get the selected configuration stored in the Custom Settings.
            MyAgreement = CS_Agreement__c.getInstance(AgreementName);
            
            if(MyAgreement != null && MyAgreement.Active__c){
                // Query the fields defined in the configuration
                CurrentUser = Database.query('select ' + MyAgreement.User_Field__c + ',Id from User where Id = \'' + UserInfo.getUserId() +'\'');
                
                // Get the Document by using the document name stored in the custom settings.
                List<Document> d = [select id, body from Document where DeveloperName = :MyAgreement.Agreement_Document__c limit 1];
                if (!d.isEmpty()) {
                    AgreementBody = d.get(0).body.toString();
                } else {
                    //if we don't find the document in the right language, display the default document...
                    d = [select id, body from Document where DeveloperName = :defaultConfig.Agreement_Document__c limit 1];
                    if (!d.isEmpty()) {
                        AgreementBody = d.get(0).body.toString();
                    } else {
                        // If even the default document don't exist, create a log.
                        Utils_ManageLogs.createLogManually('AgreementCtrl', 'Agreement Document', 'Document Missing', 'Unable to find the default agreement document', '');
                    }
                    
                    //... but create a log to alert the administrators.
                    Utils_ManageLogs.createLogManually('AgreementCtrl', 'Agreement Document', 'Document Missing', 'Unable to find the agreement document for this configuration '+MyAgreement.Name, '');
                }
            }
        }
        // We didn't decide yet which configuration used. We will determine it by using the user language.
        else{
            // Get user language to define which configuration should be used.
            String userLanguage = (UserInfo.getLanguage() == 'nl_BE' || UserInfo.getLanguage() == 'fr_BE')?
            UserInfo.getLanguage().right(5) :UserInfo.getLanguage().left(2).toUpperCase();
            system.debug('######## userLanguage '+userLanguage);
            if(CS_Agreement__c.getall().containsKey(userLanguage)){
                MyAgreement = CS_Agreement__c.getInstance(userLanguage);
            }else{
                // If we don't find any configuration for the language, we use the default configuration.
                MyAgreement = defaultConfig;
                // And we create a log to alert the administrators.
                Utils_ManageLogs.createLogManually('AgreementCtrl', 'Agreement Configuration', 'Configuration Missing', 'Unable to find the agreement configuration for this country '+userLanguage, '');
                
            }
            
            if(MyAgreement != null && MyAgreement.Active__c){
                // Query the fields defined in the configuration
                CurrentUser = Database.query('select ' + MyAgreement.User_Field__c + ',Id from User where Id = \'' + UserInfo.getUserId() +'\'');
                if(CurrentUser.get(MyAgreement.User_Field__c) == false /* && (MyAgreement.General__c || MyUrl.contains(''+MyAgreement.Url_Context__c))*/){
                    AgreementNeeded = true;
                    AgreementName = MyAgreement.Name;
                }
            } else{
                //Create a log to alert the administrators that the configuration is not set.
                Utils_ManageLogs.createLogManually('AgreementCtrl', 'Agreement Configuration', 'Configuration Missing', 'Unable to find any agreement configuration', '');
                Redirect();
            }
        }

    }
    
    //*
    // @author Cecile L
    // @date 13/05/2016
    // @description Update the agreement on the User page then redirect him to the home page.
    //***/ 
    public PageReference Agree(){
        CurrentUser.put(MyAgreement.User_Field__c, true);
        update CurrentUser;
        
        Pagereference Pageref = new PageReference('' + MyAgreement.Url_Context__c); 
        return Pageref;
    }
    
    //*
    // @author Cecile L
    // @date 13/05/2016
    // @description If the agreement is signed, redirect to the home page. If not, log out the user.
    //***/ 
    public PageReference Redirect(){
        Pagereference HomePage;
        
        if(MyAgreement != null && MyAgreement.Active__c == true){
            HomePage = new PageReference('/secur/logout.jsp');
        }
        else{
            HomePage = new PageReference('/home/home.jsp');
        }
        return HomePage;    
    
    }
    
}