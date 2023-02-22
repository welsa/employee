public without sharing class VFC24_CreateNewCommunityUser{
/*
----------------------------------------------------------------------
-- - Name          : VFC24_CreateNewCommunityUser
-- - Author        : WCH
-- - Description   : Controller for VFP24_CreateNewCommunityUser
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 25-SEP-2017  WCH     1.0         Initial version (case C-002856)
-- 27-MAR-2019  WCH     3.0         C-003137 - Issue With Button Creation of User
-- 17-MAY-2019  WCH     1.1         C-003221 - SIDEXA account reference number is created without an "FR"
-- 24-AUG-2020  WCH     1.2         C-003838 - Nob - Migrate Billing information to new fields
-- 14-OCT-2020  WCH     1.3         C-003965 - NOB - Welcome Email
-- 25-NOV-2020  WCH     1.4         C-004032 - NOB - Contact Management 2.0
----------------------------------------------------------------------
**********************************************************************
*/
    
    public Account currentAccount {get;set;}
    public Contact currentContact {get;set;}
    public String accJSON {get;set;}
    public String conJSON {get;set;}
    public User newRelatedUser{get;set;}
    public Id accountId{get;set;}
    public Id contactId{get;set;}
    public AccountRef__c newRelatedAccountRef{get;set;}
    public String newUserPassword{get;set;}
    public String newExternalReference{get;set;}
    public String newSystemCalling{get;set;}
    public Boolean sendEmail {get; set;}
    //Boolean whether there are errors
    public Boolean hasErrors {get; set;}
    //Boolean whether there are errors to be displayed in a toast
    public Boolean isToastError {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public Boolean displayPrivacyNotice {get; set;}
    public List<String> listSystemCalling {get;set;}
    public List<SelectOption> systemCallingOptionsList {get;set;}
    public List<SelectOption> languageOptionsList {get;set;}
    //WCH 14/10/2020 C-003965
    public Boolean contactIsPrefikar {get; set;}
    public Boolean prefikarContactHasUser {get; set;}
    public List<User> lstCommunityUser{get;set;}
    /**
     * controller method; retrives account using id in url and builds systemCallingOptionsList
     * @return no return value
     */
    public VFC24_CreateNewCommunityUser() {
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;
        this.sendEmail=false;
        
        newRelatedAccountRef = new AccountRef__c();
        systemCallingOptionsList = new List<SelectOption>();
        languageOptionsList = new List<SelectOption>();
        lstCommunityUser= new List<User>();
        contactIsPrefikar=false;
        prefikarContactHasUser=false;

        //set current user country 
        //String userRoleName=[Select UserRole.Name from User where Id=:UserInfo.getUserId()].UserRole.Name .split('-')[0];
        //String userCountry = userRoleName.contains('BE') ? 'BE' : 'FR';
        String userCountry=[Select CountryCode from User where Id=:UserInfo.getUserId()].CountryCode;userCountry = String.isBlank(userCountry)?'FR':userCountry;
        contactId = ApexPages.currentPage().getParameters().get('Id');
        contactIsPrefikar = String.isBlank(ApexPages.currentPage().getParameters().get('isP')) ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('isP'));//WCH 14/10/2020 C-003965

        currentContact = [select Id, Name, AccountId,FirstName,LastName,Email
                          from Contact 
                          where Id =: contactId];

        accountId = currentContact.AccountId;

        listSystemCalling = (String.isNotBlank(Label.SystemCallingList)) ? Label.SystemCallingList.split(';') : new List<String>();

        //WCH 24/08/2020 C-003838
        currentAccount = [select Id, Name, RecordType.Name, BillingCity__c, ContactEmail__c, BillingCountry__c, ReferenceNumber__c, 
                                 BillingStreet__c, BillingPostalCode__c, BillingCountryCode__c, isEligibleSubstitution__c,Permission_Sets__c 
                          from Account 
                          where Id =: accountId];

        //check this if needed 
        accJSON = JSON.serialize(currentAccount);
        system.debug('## accJSON' + accJSON);
        
        conJSON = JSON.serialize(currentContact);
        system.debug('## conJSON' + conJSON);

        //WCH 14/10/2020 C-003965
        lstCommunityUser = [select Id,name from User where ContactId =: contactId and Isportalenabled=true limit 1];
        if(contactIsPrefikar && !lstCommunityUser.isEmpty()){
          newRelatedUser = lstCommunityUser[0];
          newRelatedUser.IsActive=true;
          prefikarContactHasUser=true;
        }else{
          newRelatedUser = setValuesForRelatedUser(new User(),currentAccount,currentContact);
        }
        setLanguage(userCountry);
        Map<ID,SystemCallingSetting__mdt> systemCallingList = new Map<ID,SystemCallingSetting__mdt>([SELECT ID,DeveloperName FROM SystemCallingSetting__mdt where CountryCode__c=: userCountry]);

        /*newRelatedUser.UserName = (currentAccount.Name+'@alpha-scale.fr').deleteWhitespace();
        newRelatedUser.Email = (currentAccount.ContactEmail__c != null ? currentAccount.ContactEmail__c : '');*/

        for (SystemCallingSetting__mdt sysOption : systemCallingList.values()){
            systemCallingOptionsList.add(new SelectOption(sysOption.DeveloperName, sysOption.DeveloperName));
        }

        newUserPassword = passwordGeneration();
    }
    /**
     * Method to create new user
     * @param  accJSONValue currentAccount serialised
     * @param  uName        username of new user to be created
     * @param  uEmail       email of new user to be created
     * @param  uFName       firstname of new user to be created
     * @param  uLName       lastname of new user to be created
     * @param  isUserActive if new user is active
     * @param  userPassword password of new user(used only if user is active)
     * @return user id if successful
     */
    @RemoteAction
    public static Id createNewUserRelated(String accJSONValue,String conJSONValue,String uName, String uEmail, String uFName, String uLName,Boolean isUserActive, String userPassword,String selectedLanguage,boolean sendMail,boolean isContactPrekifar){
        system.debug('## start createNewUser >>'+sendMail);
        map <string,string> mapLocaleTimeZoneSidKey = new map <string,string>{'nl_BE' => 'Europe/Brussels',
                                                                              'fr_BE' => 'Europe/Brussels',
                                                                              'fr' => 'Europe/Paris',
                                                                              'de' => 'Europe/Berlin',
                                                                              'es' => 'Europe/Paris'};

        map <string,string> mapLocaldLocaleSidKey   = new map <string,string>{'nl_BE' => 'nl_BE',
                                                                              'fr_BE' => 'fr_BE',
                                                                              'fr' => 'fr_FR',
                                                                              'de' => 'de_DE',
                                                                              'es' => 'es_ES'};
 
        Account acc = (Account)JSON.deserialize(accJSONValue, Sobject.class);
        system.debug('## acc :'+acc);
        Contact con = (Contact)JSON.deserialize(conJSONValue, Sobject.class);
        system.debug('## con :'+con);

        User newUser = new User();
        newUser.UserName = uName;
        newUser.Email = uEmail;
        newUser.LastName = uLName;
        newUser.FirstName = uFName;
        newUser.IsActive = true;//isUserActive;
        newUser.ContactId = con.id;

        newUser.Alias = (newUser.FirstName.length() > 2 ? newUser.FirstName.substring(0,1) : newUser.FirstName) + (newUser.LastName.length() > 5 ? newUser.LastName.substring(0,4) : newUser.LastName); 
        newUser.CommunityNickname = ((String.isBlank(newUser.FirstName)?'':newUser.FirstName.substring(0,1)+'_')+(String.isBlank(newUser.LastName)?'':newUser.LastName.left(25))).replaceAll(' ','')+'_'+randomDigitsGenerator(13);

        newUser.ProfileId = (isContactPrekifar || Label.CountryCodesAllowedForCCPBodyshopProfile.contains(String.isNotBlank(acc.BillingCountryCode__c)?acc.BillingCountryCode__c:'XX') || Label.CountryCodesAllowedForCCPBodyshopProfile.contains(String.isNotBlank(acc.BillingCountryCode)?acc.BillingCountryCode:'XX'))?([SELECT Id from Profile where Name  =:Label.R4BSProfileNameCommunityPrefikar].Id):([SELECT Id from Profile where Name  = 'CC Bodyshop Order'].Id);
        newUser.BodyShopID__c = acc.ReferenceNumber__c;

        newUser.Phone = acc.Phone;
        newUser.Fax = acc.Fax;
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey = selectedLanguage;
        newUser.TimeZoneSidKey = mapLocaleTimeZoneSidKey.containsKey(selectedLanguage) ? mapLocaleTimeZoneSidKey.get(selectedLanguage) : 'Europe/Paris';
        newUser.LocaleSidKey = mapLocaldLocaleSidKey.containsKey(selectedLanguage) ? mapLocaldLocaleSidKey.get(selectedLanguage) : 'fr_FR';
        newUser.CurrencyIsoCode = 'EUR';
        
        //WCH 24/08/2020 C-003838
        newUser.City = acc.BillingCity__c;
        newUser.Street = acc.BillingStreet__c;
        newUser.PostalCode = acc.BillingPostalCode__c;
        newUser.CountryCode = acc.BillingCountryCode__c;
        newUser.Country = acc.BillingCountry__c;

        newUser.isAspis__c=true;

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = (sendMail?true:false);
        //dlo.EmailHeader.triggerAutoResponseEmail= false;
        newUser.setOptions(dlo);

        List <Database.Saveresult> lstResultsUserCreate = Database.insert(new List<User>{newUser}, false);
        if(lstResultsUserCreate[0].isSuccess()){
          //if user successfully inserted and user active then create permission sets
          insertPermissionSets(acc,newUser,sendMail);
          //WCH 27/03/2019 C-003137 - Issue With Button Creation of User. If sendMail is not checked, no password generation for user
          if(isUserActive && sendMail){
              system.setPassword(newUser.id, userPassword);
          }
          return newUser.Id;
          
        }else{
          system.debug('error creating user>>'+lstResultsUserCreate[0].getErrors()[0].getMessage());
          return ('ERROR:'+lstResultsUserCreate[0].getErrors()[0].getMessage());
        }
    }
    /**
     * Method to update user
     * @param  accJSONValue currentAccount serialised
     * @param  prefikarUserId portal user of prefikar contact
     * @return user id if successful
     */
    @RemoteAction
    public static Id updateUserRelated(String accJSONValue,String prefikarUserId,boolean sendMail){
      Account acc = (Account)JSON.deserialize(accJSONValue, Sobject.class);
      User newUser = new User(Id=prefikarUserId,isAspis__c=true,BodyShopID__c = acc.ReferenceNumber__c);
      Database.DMLOptions dlo = new Database.DMLOptions();
      dlo.EmailHeader.triggerUserEmail = (sendMail?true:false);
      newUser.setOptions(dlo);
      List <Database.Saveresult> lstResultsUserCreate = Database.update(new List<User>{newUser}, false);
        if(lstResultsUserCreate[0].isSuccess()){
          //if user successfully inserted and user active then create permission sets
          insertPermissionSets(acc.Id,newUser.Id,true);
          system.debug('## end createNewUser ' + newUser);
          system.debug('## end createNewUser.Id ' + newUser.Id);
          return newUser.Id;
          
        }else{
          system.debug('error creating user>>'+lstResultsUserCreate[0].getErrors()[0].getMessage());
          return ('ERROR:'+lstResultsUserCreate[0].getErrors()[0].getMessage());
        }
    }
    /**
     * Method to update contact user on account and create new account ref
     * @param  sysCalling   system calling of new account ref
     * @param  extRef       external reference of new account ref
     * @param  accId        account id of current account
     * @param  isActiveUser boolean to determine if new user is active, if yes new account ref is created
     * @param  newUser      id of new user created 
     * @return account id if successful 
     */
    @RemoteAction
    public static Id createAccRefUpdateAcc(String sysCalling, String extRef , Id accId,Boolean isActiveUser,Boolean isDisplayPrivacyNotice, Id newUser){

        system.debug('## start createAccRefUpdateAcc : extRef>>'+extRef);
        //WCH 25/11/2020 C-004032
        List<Account> currentAcc=[select Id,ContactUser__c from Account where Id=:accId limit 1];
        if(currentAcc.size()>0){
          if(currentAcc[0].ContactUser__c!=null){
            update (new Account(Id = accId, Assessment_Tool__c = (sysCalling == 'SIDEXA'? 'FR_'+sysCalling.toUpperCase() : sysCalling.toUpperCase()))); 
          }else{
            update (new Account(Id = accId, ContactUser__c = newUser,Assessment_Tool__c = (sysCalling == 'SIDEXA'? 'FR_'+sysCalling.toUpperCase() : sysCalling.toUpperCase()))); 
          }
        }
        
        Set<String> countryCodes = new Set<String>{'FR','BE'};//list of countries for which page is available

        //check external reference
        extRef = sysCalling.equals('SIDEXA')?(extRef.left(2).equals('FR')?extRef:('FR'+extRef)) : ((countryCodes.contains(extRef.left(2)))?extRef.removeStart(extRef.left(2)):extRef);//WCH 17/05/2019 C-003221

        if(isActiveUser){

            AccountRef__c newAccRef = new AccountRef__c();

            newAccRef.Name = sysCalling.toUpperCase() + '-' + extRef.toUpperCase();
            newAccRef.systemCalling__c = sysCalling;
            newAccRef.ExternalReference__c = extRef;
            newAccRef.SendingAccepted__c=isDisplayPrivacyNotice;
            newAccRef.InternalReference__c = accId;

            insert newAccRef;

            system.debug('## end newAccRef ' + newAccRef);
        }

        system.debug('## end createAccRefUpdateAcc ');

        return accId;
    }
    /**
     * Method preset values for user
     * @param  theRelaterUser   system calling of new account ref
     * @param  theAccount       external reference of new account ref
     * @param  theContact        account id of current account
     * @return account id if successful 
     */
    private User setValuesForRelatedUser(User theRelaterUser,Account theAccount,Contact theContact){

        system.debug('## start setValuesForRelatedUser ');
        theRelaterUser.FirstName=theContact.FirstName;
        theRelaterUser.LastName=theContact.LastName;
        theRelaterUser.Email = theContact.Email;
        system.debug('## end setValuesForRelatedUser ');
        return theRelaterUser;
    }
    /**
     * Method to set related user language
     * @return none 
     */
    private void setLanguage(String theCountryCode){
        Map<String,List<String>> countryCodeMapLanguages = new Map<String,List<String>>{'BE'=>new List<String>{'fr_BE','nl_BE'},'FR'=>new List<String>{'fr'}};

        for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()){
          if(countryCodeMapLanguages.get(theCountryCode).contains(value.getValue())){
            languageOptionsList.add(new SelectOption(value.getValue(),value.getLabel()));
          }
        }

        if(theCountryCode.equals('BE')){
          newRelatedUser.LanguageLocalekey='fr_BE';
          //par défaut coché pour la France et décoché pour la belgique
          displayPrivacyNotice=false;
        }else{
          newRelatedUser.LanguageLocalekey='fr';
          //par défaut coché pour la France et décoché pour la belgique
          displayPrivacyNotice=true;
        }
    }
    @future
    public static void insertPermissionSets(Id currentAccount,Id newRelatedUser,boolean sendMail){
      system.debug('## start future insertPermissionSets sendMail>>'+sendMail);
      List<Account> lstAccs = [select Id,Permission_Sets__c from account where Id=:currentAccount];
      User currentUser = new User(Id=newRelatedUser);
      if(lstAccs.size()>0){
        insertPermissionSets(lstAccs[0],currentUser,sendMail);
      }
    }
    public static void insertPermissionSets(Account currentAccount,User newRelatedUser,boolean sendMail){
        system.debug('## start insertPermissionSets sendMail>>'+sendMail);
        
        //list to hold new permssion set assigned
        list <PermissionSetAssignment> permSetToInsertList=new list <PermissionSetAssignment>();
        if(currentAccount.Permission_Sets__c != null){
          for(string permid : currentAccount.Permission_Sets__c.split(';')){
              permSetToInsertList.add(new PermissionSetAssignment(AssigneeId = newRelatedUser.Id,PermissionSetId = permid));
          }
        }
        if(sendMail){
          List<PermissionSet> CR4_PS = [SELECT Id,Name FROM PermissionSet WHERE Name='Community_R4'];
          permSetToInsertList.add(new PermissionSetAssignment(AssigneeId = newRelatedUser.Id,PermissionSetId = CR4_PS[0].Id));
        }
        
        if(!permSetToInsertList.isEmpty()){
          List <Database.Saveresult> lstResultsPermSetCreate = Database.insert(permSetToInsertList, false);
          for(Database.Saveresult currentResult : lstResultsPermSetCreate){
            if(!currentResult.isSuccess()){
              system.debug('error creating PermissionSet>>'+currentResult.getErrors()[0].getMessage());
              //create log here?
            }
          }
        }
    }
    /**
     * Method to generate user password with 12 characters(mix alphabets and numbers)
     * @return password 
     */
    public static string passwordGeneration(){
        String alphaForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String numForRandom = '0123456789';
        String randStr = '';
        while (randStr.length() < 12) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), alphaForRandom.length());
            Integer idx1 = Math.mod(Math.abs(Crypto.getRandomInteger()), alphaForRandom.length());
            Integer idx2 = Math.mod(Math.abs(Crypto.getRandomInteger()), numForRandom.length());
            randStr += alphaForRandom.substring(idx, idx+1) + alphaForRandom.substring(idx1, idx1+1) + numForRandom.substring(idx2, idx2+1);
        }
        System.debug('## randStr' + randStr);
        return randStr;
    }
    /**
     * Method to generate 5 digits to be appended to community nickname
     * @return digits 
     */
    public static string randomDigitsGenerator(Integer theLength){
        DateTime currentTime = System.now(); 
        Long timeInMiliSec = currentTime.getTime(); 
        String theDigits = theLength>(String.valueOf(timeInMiliSec)).length() ? (String.valueOf(timeInMiliSec)) : ((String.valueOf(timeInMiliSec)).right(theLength));
        System.debug('## randDigit' + theDigits);
        return theDigits;
    }

    /**
     * Method to redirect model
     * @return null
     */
    public PageReference redirectPage(){
        redirectionInErrorModal = true;

        return null;
    }
}