public without sharing class ASPISPurchaseOrder {
/*************************************************************************************
Class Name - ASPISPurchaseOrder
Version - 1.0
Created Date - 09 AUG 2017
Function - Class to provide operation on PurchaseOrder__c object 

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias             02/04/2015  Original Version
* Cecile LARTAUD        18/05/2015  Remove the obsolete Record Type "Line Ordered"
* Dourga Unmole         11/06/2015  Commented Line 48-73 as moved logic in trigger
* Yudish Ramdowar       24/07/2015  Add 10 days to validity Date using business days
* Immo Salo             03/12/2015  Added private sharing logic
* Dourga Unmole         19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c 
                                    to add new field TECH_EntityCountryCode__c)
* Shamina M             16/02/2016  C-001518: Removed unnecessary debug logs    
* Dourga Unmole         24/02/2016  Case C-001496 - Use the Reference Number in Public Group 
                                    for sharing to BS and Dist 
* Abdool M              09/08/2017  Updating method so as to include error message generated 
*                                   from SAS + partial refactor 
* Vaynee S              28/11/2017  C-002008 Replaced instances of addBusinessHour by Businesshours.add()   
* Abdool M              28/05/2018  Force.com to Community License Migration                           
* Welsa C               21/05/2020  C-003735: Remove Code that shares BS Account with Distributor
**************************************************************************************/
    public static Map<String,Schema.RecordTypeInfo> purchaseOrderRTByName;

    static{
        purchaseOrderRTByName   = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName();
    }

    //distributorMap ==> this map contains all connected distributors
    public static map <string,PurchaseOrder__c> createOrders(Assessment__c ass, 
                                                                list <Account> distributors,
                                                                string errorReported,
                                                                datetime lastCallMade,
                                                                set <id> setDistIdWithSASInfo,
                                                                map <id,Account> distributorMap){
        system.debug('## Start createOrders');
        system.debug('## ass ' + ass);
        system.debug('## distributors ' + distributors);
        system.debug('## errorReported ' + errorReported);
        system.debug('## lastCallMade ' + lastCallMade);
        system.debug('## setDistIdWithSASInfo ' + setDistIdWithSASInfo);
        system.debug('## distributorMap ' + distributorMap);

        set<string> distributorNames = new set <string>();
        
        //Map<Id,String> distAccountsMap = New Map<Id,String>();WCH 21/05/2020 C-003735
        Map<String, Id> distNameIdMap = new Map<String, Id>();
        map<string,Id> groupMap = new map <string,Id>();
        //AMI 09/08/17 - returned results
        map <string,PurchaseOrder__c> mapSuccessfullPOUpsertKeyPO = new map <string,PurchaseOrder__c>();

        //list<AccountShare> accountShareToBeInserted = new list<AccountShare>();WCH 21/05/2020 C-003735
        List<PurchaseOrder__c> listOrdersToInsert = new List<PurchaseOrder__c>();

        //AMI 09/08/17 - upsert PO
        Schema.SObjectField POExternalId = PurchaseOrder__c.Fields.Tech_ExternalId__c;
        List<Database.upsertResult> uResults;

        // 24/02/2016 DUN case 1496 - replace account name by account reference number
        for(Account dis : [select Id,Name, ReferenceNumber__c 
                            from Account 
                            where Id in :distributors]){
            if(dis.ReferenceNumber__c != null){
                distributorNames.add(dis.ReferenceNumber__c);
                //distAccountsMap.put(dis.Id,dis.ReferenceNumber__c); WCH 21/05/2020 C-003735
                distNameIdMap.put(dis.Name, dis.Id);
            }
        }
        
        for(Group g:[select Id,Name 
                        from Group 
                        where Name IN: distributorNames]){
            groupMap.put(g.Name,g.Id);
        }
        
        string countryCode = '';
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        //Utils_BusinessDays businessDays;
        BusinessHours businessDays;

        countryCode = [select Id, TECH_EntityCountryCode__c from Assessment__c where Id =: ass.Id].TECH_EntityCountryCode__c;

        // Get Informations based on the Country Code
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        if(countryCode!=null && countryCode!= ''){
            //businessDays = new Utils_BusinessDays(countryCode);
            businessDays = ASPISConstants.getBusinessHours(countryCode);
        }

        system.debug('## distributors:'+distributors);
        for(Account dis:distributors){
            PurchaseOrder__c newOrder = new PurchaseOrder__c(
                assessment__c   = ass.id,
                //validityDate__c = businessDays.addBusinessDays(date.today(), integer.valueof(system.Label.ValidityDays)),
                validityDate__c = Date.valueOf(Businesshours.add(businessDays.id,datetime.now(),configCountryCodeInfo.Validity_Duration_Purchase_Order__c!=null?Integer.valueOf(configCountryCodeInfo.Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),               
                //status__c = (ass.recordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId() && ass.OrderOrigin__c =='Order')?'PREDRAFTQUOTE':system.Label.PURCHASEORDERDRAFTQUOTESTATUS,
                status__c = system.Label.PURCHASEORDERDRAFTQUOTESTATUS,
                distributor__c = dis.id,
                recordTypeId = purchaseOrderRTByName.get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(),
                SLAQuotationEntryDate__c = datetime.now(),
                Tech_ExternalId__c = String.valueOf(ass.id) + String.valueOf(dis.id)
            );
            system.debug('## newOrder:'+newOrder);

            //AMI 09/08/17 - PO creation through SAS
            if(setDistIdWithSASInfo.contains(dis.id) && lastCallMade != null){
                newOrder.wsDate__c = system.now();
                newOrder.wsErrorMessage__c = '';
            }//end if setDistIdWithSASInfo.contains(dis.id)
            else if(lastCallMade != null && distributorMap.containsKey(dis.id)){
                newOrder.wsDate__c = system.now();
                newOrder.wsErrorMessage__c = string.isNotBlank(errorReported) ? ((errorReported.length() > 1000) ? system.label.DistributorWSNoInfo : errorReported)  : system.label.DistributorWSNoInfo; 
            }
            
            listOrdersToInsert.add(newOrder);
            system.debug('## listOrdersToInsert:'+listOrdersToInsert);
            //WCH 21/05/2020 C-003735
            /* //NEW DEV 01/12/2015 PRIVATE SHARING
            if(distAccountsMap.containsKey(dis.Id) && groupMap.containsKey(distAccountsMap.get(dis.Id))){
                accountShareToBeInserted.add(
                    new AccountShare (UserOrGroupId = groupMap.get(distAccountsMap.get(dis.Id)),AccountId=ass.bodyShop__c,AccountAccessLevel='Read',OpportunityAccessLevel='Read')
                );
            } */
        }

        //AMI 09/08/17 - this set will help to query inserted po to get po name (autonumber)
        set <id> setQueriedPOId = new set <id>();
        
        //AMI 09/08/17 - upserting results instead of insert
        if(!listOrdersToInsert.isEmpty()){
            //upsert results
            uResults = Database.upsert(listOrdersToInsert, POExternalId, false);

            //loop in results to get successfull upserted PO
            for(Integer i = 0; i < uResults.size(); i++) {
                if(uResults[i].isSuccess()) {

                    //build setQueriedPOId
                    setQueriedPOId.add(uResults[i].getId());
                }
            }

            system.debug('## setQueriedPOId ' + setQueriedPOId);
            if(setQueriedPOId.size() > 0){
                //query po and build mapSuccessfullPOUpsertKeyPO
                //WCH 22/10/2018 : C-002829 - Apex class PurchaseOrderTriggerHandler modified, test class RESTDistributorUtility_TEST failing. Add TECHRulesAppliedDescription__c
                for(PurchaseOrder__c PO : [select id,Name,Tech_ExternalId__c,Status__c,Distributor__c,Assessment__c,
                                            wsDate__c,wsErrorMessage__c,Manual_Creation__c,Rebate__c,TECHRulesAppliedDescription__c, Assessment__r.InsuranceBroker__c, Brand__c
                                            ,Assessment__r.substitutiontype__c,TECH_AssessmentCountryCode__c,TECH_AssessmentEntityRules__c //RLA 16/10/2020 IG remplacements
                                            from PurchaseOrder__c
                                            where Id IN :setQueriedPOId]){
                    mapSuccessfullPOUpsertKeyPO.put(PO.Tech_ExternalId__c,PO);
                }
            }//end if setQueriedPOId.size() > 0
        }

        //WCH 21/05/2020 C-003735 commented section
        /* //AMI 28/05/18 : Force.com to Community License Migration
        //             : Prevent programatic dml on sharing rule if user has community license
        //             : get connected user info
        //User uObj = [Select id,Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()];
        string userType = UserInfo.getUserType().toLowerCase();

        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

        if((string.isBlank(formattedLicenseName) ||
           (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((userType).toLowerCase()))) &&
           accountShareToBeInserted.size()>0
        ){
            //NEW DEV 01/12/2015 PRIVATE SHARING
            insert accountShareToBeInserted;
        } */
        
        //AMI 09/08/17 - return successful PO information
        return mapSuccessfullPOUpsertKeyPO;
    }
}