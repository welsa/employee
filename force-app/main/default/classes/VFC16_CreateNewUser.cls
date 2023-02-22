/*
----------------------------------------------------------------------
-- - Name          : VFC16_CreateNewUser
-- - Author        : DUN
-- - Description   : Controller for VFP16_CreateNewUser
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 05-JUN-2017  DUN     1.0         Initial version (case 1933)
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class VFC16_CreateNewUser {
    
    public Account currentAccount {get;set;}
    public String accJSON {get;set;}
    public User newRelatedUser{get;set;}
    public Id accountId{get;set;}
    public AccountRef__c newRelatedAccountRef{get;set;}
    public String newUserPassword{get;set;}
    public String newExternalReference{get;set;}
    public String newSystemCalling{get;set;}
    //Boolean whether there are errors
    public Boolean hasErrors {get; set;}
    //Boolean whether there are errors to be displayed in a toast
    public Boolean isToastError {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public List<String> listSystemCalling {get;set;}
    public List<SelectOption> systemCallingOptionsList {get;set;}

    /**
     * controller method; retrives account using id in url and builds systemCallingOptionsList
     * @return no return value
     */
    public VFC16_CreateNewUser() {
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;

        newRelatedUser = new User();
        newRelatedAccountRef = new AccountRef__c();
        systemCallingOptionsList = new List<SelectOption>();

        accountId = ApexPages.currentPage().getParameters().get('Id');

        listSystemCalling = (String.isNotBlank(Label.SystemCallingList)) ? Label.SystemCallingList.split(';') : new List<String>();

        currentAccount = [select Id, Name, RecordType.Name, BillingCity, ContactEmail__c, BillingCountry, ReferenceNumber__c, 
                                 BillingStreet, BillingPostalCode, BillingCountryCode, isEligibleSubstitution__c
                          from Account 
                          where Id =: accountId];
        accJSON = JSON.serialize(currentAccount);
        system.debug('## accJSON' + accJSON);

        newRelatedUser.UserName = (currentAccount.Name+'@alpha-scale.fr').deleteWhitespace();
        newRelatedUser.Email = (currentAccount.ContactEmail__c != null ? currentAccount.ContactEmail__c : '');

        for (String sysOption : listSystemCalling){
            systemCallingOptionsList.add(new SelectOption(sysOption, sysOption));
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
    public static Id createNewUserRelated(String accJSONValue,String uName, String uEmail, String uFName, String uLName,Boolean isUserActive, String userPassword){
        system.debug('## start createNewUser ');
 
        Account acc = (Account)JSON.deserialize(accJSONValue, Sobject.class);
        system.debug('## acc :'+acc);

        User newUser = new User();
        newUser.UserName = uName;
        newUser.Email = uEmail;
        newUser.LastName = uLName;
        newUser.FirstName = uFName;
        newUser.IsActive = isUserActive;

        if(acc.RecordType.Name == 'BodyShop'){
            newUser.UserRoleId = [SELECT Id from UserRole where DeveloperName = 'BodyShopFrance'].Id;
            newUser.ProfileId = [SELECT Id from Profile where Name  = 'Bodyshop Order'].Id;
            newUser.BodyShopID__c = acc.ReferenceNumber__c;
        }
        else if(acc.RecordType.Name == 'Distributor'){
            newUser.UserRoleId = [SELECT Id from UserRole where DeveloperName = 'DistributorFrance'].Id;
            newUser.ProfileId = [SELECT Id from Profile where Name  = 'FR - Distributor'].Id;
            newUser.DistributorID__c = acc.ReferenceNumber__c;
        }
        newUser.City = acc.BillingCity;
        newUser.Street = acc.BillingStreet;
        newUser.PostalCode = acc.BillingPostalCode;
        newUser.CountryCode = acc.BillingCountryCode;
        newUser.Country = acc.BillingCountry;
        //newUser.UserName += '@alpha-scale.fr';
        newUser.LanguageLocaleKey = 'fr';
        newUser.LocaleSidKey = UserInfo.getLocale();
        newUser.TimeZoneSidKey = UserInfo.getTimeZone().getId();
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.Alias = (newUser.FirstName.length() > 2 ? newUser.FirstName.substring(0,1) : newUser.FirstName) + (newUser.LastName.length() > 5 ? newUser.LastName.substring(0,4) : newUser.LastName); 

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = false;
        dlo.EmailHeader.triggerAutoResponseEmail= false;
        newUser.setOptions(dlo);

        insert newUser; 

        if(isUserActive){

            system.setPassword(newUser.id, userPassword);
        }

        system.debug('## end createNewUser ' + newUser);
        return newUser.Id;
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
    public static Id createAccRefUpdateAcc(String sysCalling, String extRef , Id accId,Boolean isActiveUser, Id newUser){

        system.debug('## start createAccRefUpdateAcc ');
        update (new Account(Id = accId, ContactUser__c = newUser,Assessment_Tool__c = (sysCalling == 'SIDEXA'? 'FR_'+sysCalling.toUpperCase() : sysCalling.toUpperCase()))); 

        if(isActiveUser){

            AccountRef__c newAccRef = new AccountRef__c();

            newAccRef.Name = sysCalling.toUpperCase() + '-' + extRef.toUpperCase();
            newAccRef.systemCalling__c = sysCalling;
            newAccRef.ExternalReference__c = extRef;
            newAccRef.SendingAccepted__c = true;
            newAccRef.InternalReference__c = accId;

            insert newAccRef;

            system.debug('## end newAccRef ' + newAccRef);
        }

        system.debug('## end createAccRefUpdateAcc ');

        return accId;
    }

    /**
     * Method to generate user password with 12 characters(mix alphabets and numbers)
     * @return password 
     */
    public static string passwordGeneration(){
        String alphaForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String numForRandom = '0123456789';
        String randStr = '~';
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
     * Method to redirect model
     * @return null
     */
    public PageReference redirectPage(){
        redirectionInErrorModal = true;

        return null;
    }
}