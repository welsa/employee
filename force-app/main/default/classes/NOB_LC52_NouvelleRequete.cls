/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC52_NouvelleRequete
  -- - Author        : HMO
  -- - Description   : 
  -- - #Ticket       : RSIW : 1675
                       RSIW : 3726 [5354]
                       RSIW : 3734
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- -               HMO     1.0     Initial version
  --  25/02/2021     HMO     1.1     RSIW - 3734
  **********************************************************************
*/
public without sharing class NOB_LC52_NouvelleRequete {
    public NOB_LC52_NouvelleRequete() {

    }

/***********************************************************************
    * @description      : Get list of accounts and choix de l'offres
    * @param objectName : -
    * @param fieldName  : -
    * @return           :  Map<String, Object> mapResult containing accounts and catalogue comptes
    */
    @AuraEnabled
    public static map<String, Object> getApporteurAffaire(){
        List<List<String>> lstSplitName = new List<List<String>>();
        List<String> groupName = new List<String>();
        List<String> lstBusinessProvider = new List<String>();
        List<String> lstchoix = new List<String>();
        //Get Logged-in user RSIW-7113 - set user account as Apporteur d'affaire
        Id userId = UserInfo.getUserId();
        User connectedUser = [SELECT Id, Name, AccountId, Account.Name FROM User WHERE Id=: userId];

        List<Account> lstAccount = new List<Account>{new Account(Id = connectedUser.AccountId, Name = connectedUser.Account.Name)};
        List<NOB_AccountPricebook__c> lstpriceBook = new List<NOB_AccountPricebook__c>([SELECT Id, Name, NOB_Account__c FROM NOB_AccountPricebook__c WHERE NOB_Account__c = :connectedUser.AccountId and NOB_Pricebook__r.NOB_Offer__c = :NOB_AP00_Constants.PRICEBOOK_OFFRE_SAD]);

        Map<String, Object> mapResult = new Map<String, Object>{
            'accounts' => lstAccount,
            'choixdoffre' => lstpriceBook 
        };
        return mapResult;
    }


//HMO -- RSIW 3734 -- 25/02/2021
/***********************************************************************
    * @description      : Function used for creation of contact
    * @param objectName : -
    * @param fieldName  : -
    * @return           :  Map<String, Object> mapResult containing user, recordtype and map of countries
    */
    @AuraEnabled
    public static Map<String, Object> getUserandRecId(String recordTypeLabel){
         Id userId = UserInfo.getUserId();
         User connectedUser = [SELECT Id, Name, AccountId, Account.Name FROM User WHERE Id=: userId];
         List<RecordType> lstRecordType = new List<RecordType>([SELECT ID, RecordType.Name FROM RecordType WHERE DeveloperName =: recordTypeLabel]);
         //
         Map<String, String> mapValues = getCountries();
         //
         Map<String, Object> mapResult = new Map<String, Object>{
            'user' => connectedUser,
            'recordType' => lstRecordType,
            'mapValues' => mapValues
        };
         return mapResult;
    }

//HMO -- RSIW 3734 -- 25/02/2021
/***********************************************************************
    * @description      : Get picklist values of countries
    * @param objectName : -
    * @param fieldName  : -
    * @return           :  Map<String, String> mapValues containing countryNames and MailingCountryCode as Key
    */
    @AuraEnabled
    public static Map<String, String> getCountries(){
        String objectName = 'Contact';
        String fieldName ='MailingCountryCode';
        Map<String, String> mapValues = new Map<String, String>();

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            mapValues.put(pickListVal.getLabel(), pickListVal.getValue());
        }   
        return mapValues;
    }

}