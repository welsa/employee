/*
----------------------------------------------------------------------
-- - Name          : VFC21_CreateAssessment
-- - Author        : VSU
-- - Description   : Controller Class 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-JUL-2018  RLA   1.0      C-002640 : Facilitate assessment creation from scratch
-- 24-AUG-2018  WCH   1.1      C-002640 : Facilitate assessment creation from scratch(Correction retours)
-- 23-NOV-2018  ASE   1.2      Added VAT on parts
-- 02-APR-2019  RLa   1.2      C-003133 : Direct Sourcing not done when creating assessment from scratch & for R4 ASP not taken into consideration 
-- 07-AUG-2019  WCH   1.3      C-003359 : R4 - Create assessement from Scratch should work for Spain (Quotation Process)
-- 21-AUG-2019  WCH   1.4      C-003376 : Create assessment from scratch for Germany uses classic sourcing instead of direct soucing when no DO found
-- 24-AUG-2020  WCH   1.3      C-003838 - Nob - Migrate Billing information to new fields
-- 28-OCT-2020  WCH   1.5      C-004037 : Creation de chiffrage a partir du bouton Create Assessment sur BS fonctionne pas comme il faut
----------------------------------------------------------------------*/
public without sharing class VFC21_CreateAssessment {
    public Assessment__c assessment {get;set;}

    private final sObject mysObject;
    public String dateFromJs {get;set;}
    public String locale {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean apexError {get; set;}
    public String apexErrorMsg {get; set;}
    public static Boolean isToastError {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public List<PartList__c> listNewPartList{get;set;}
    public String bodyshopName {get;set;}
    public String accountId {get;set;}
    public Account bodyshop {get;set;}
    public String typeAss {get;set;}
    public Boolean CorrectPermission {get;set;}
    public string selectedEntity{get;set;}
    public string helptext {get;set;}

    //RLA 02/04/2019 C-003133 : Direct Sourcing not done when creating assessment from scratch & for R4 ASP not taken into consideration 
    private static set<String> setPartTypes = new set<string>();
    private static map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public VFC21_CreateAssessment() {
        assessment = new Assessment__c ();
        locale = UserInfo.getLocale()=='nl_BE'?'nl-BE':UserInfo.getLocale();
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;
        listNewPartList = new List<PartList__c>();
        bodyshopName = '';
        apexErrorMsg = '';
        accountId = ApexPages.currentPage().getParameters().get('id');
        system.debug('## accountId'+accountId);
        
        //system.debug('## isNewAssess'+isNewAssess);       

        List<PermissionSetAssignment> lstcurrentUserPerSet = [ SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId()
                                                                      AND PermissionSet.Name = 'Create_Assessment_From_scratch'];
        System.debug('@@ lstcurrentUserPerSet: '+lstcurrentUserPerSet);                                                               
        if (lstcurrentUserPerSet.size() > 0){
            CorrectPermission = true;
            if (String.isNotBlank(accountId)){
                //WCH 24/08/2020 C-003838 changed BillingCountry to custom field
                List<Account> lstAccs = [Select Id, Name,ReferenceNumber__c, BillingCountry__c, ShippingCountry,
                                               ContactUser__r.profile.Name,ContactUser__r.Name,ContactUser__r.ProfileId,
                                               ContactUser__r.Tech_LicenceName__c, /*RLA 02/04/2019 C-003133*/Feature__c, ShippingPostalCodeLeft2__c, CarBrandsSuppliedAgency__c  
                                               from Account WHERE Id =:accountId]; 
                    System.debug('@@ lstAccs: '+lstAccs);                                                               
                    
                    if (lstAccs.size() > 0) {
                        bodyshop = lstAccs[0];
                        bodyshopName = bodyshop.Name;   
                        System.debug('@@ bodyshop.ContactUser__r.Profile.Name: '+bodyshop.ContactUser__r.Profile.Name); 

                        string profileName = (bodyshop.ContactUser__r.Profile.Name) ;

                        if (profileName != null){                                                            

                            profileName = (profileName).toUpperCase();
                            System.debug('@@ profileName: '+profileName);                                                               


                            if (profileName.contains('BODYSHOP') && profileName.contains('ORDER')|| profileName.contains(Label.R4BSProfileNameCommunityPrefikar.toUpperCase())){//WCH 28/10/2020 C-004037
                                typeAss = 'Claim';
                            }
                            else if (profileName.contains('BODYSHOP') && !profileName.contains('ORDER')){
                                system.debug('new assessment');
                                typeAss = 'NewAssessment';
                                
                            }
                             


                            if (typeAss == null){
                                apexError = true;   
                                CorrectPermission = false;
                                 ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please select a bodyshop with the correct profile'));
                                apexErrorMsg = 'Please select a bodyshop with the correct profile';     
                            }
                        }
                        else{
                            apexError = true;   
                            CorrectPermission = false;
                            apexErrorMsg = 'The profile could not be checked';   
                        }

                    }
                    else{
                        apexError = true;   
                        CorrectPermission = false;
                        apexErrorMsg = 'No Account was found';    
                    }
            }   
        }
        else{
            apexError = true;
            CorrectPermission = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'You cannot access this page'));
            apexErrorMsg = 'You cannot access this page';    
        }

        helptext =Assessment__c.TotalLoss__c.getDescribe().getInlineHelpText();
        system.debug('@@ helptext: '+helptext);
        system.debug('@@ typeAss: '+typeAss);
        

        //this.mysObject = (sObject)stdController.getRecord();
    }

    //public String getRecordName() {
    //    return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    //}

    public List<String> getManufacturerOptions(){
        system.debug('## START getManufacturerOptions');       

        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Assessment__c.Manufacturer__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     

        system.debug('## END getManufacturerOptions'); 

        return pickListValuesList; 

    }


    //@RemoteAction
    //public static Result[] lookup(String searchString, String sObjectAPIName, String searchConditions) {
    //    String objSearchString = String.isNotBlank(searchString) ? String.escapeSingleQuotes(searchString): '';
    //    //String objSearchConditions = String.isNotBlank(searchConditions) ?  String.escapeSingleQuotes(searchConditions): ''
    //    String objSearchConditions = searchConditions;
    //    String objSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
    //    List<Result> results = new List<Result>();
    //    if(String.isNotBlank(objSearchString) && objSearchString.length() > 1){
    //        String searchQuery = 'FIND \'*' + objSearchString + '*\' IN Name FIELDS RETURNING ' + objSObjectAPIName + ' (Id, Name ';
    //        searchQuery += String.isNotBlank(objSearchConditions) ? ' WHERE ' + objSearchConditions : '';
    //        searchQuery += ' ORDER BY LastViewedDate ASC) Limit 5 '; 
    //        //System.debug('### searchQuery: '+searchQuery);
    //        List<List<SObject>> searchList = system.search.query(searchQuery);

    //        for (SObject so : searchList[0]) {
    //            results.add(new Result((String)so.get('Name'), so.Id));
    //        }
    //    }else {
    //        String strQuery = 'SELECT Id, Name FROM '+sObjectAPIName ;
    //        strQuery += String.isNotBlank(searchString) ? ' WHERE Name like \'%' + searchString  + '%\''  : '';
    //        if(String.isNotBlank(objSearchConditions)){
    //            if(String.isNotBlank(searchString)){
    //                strQuery += ' AND ' + objSearchConditions;
    //            }else{
    //                strQuery += ' WHERE ' + objSearchConditions;
    //            }
    //        }
    //        strQuery += ' order by LastViewedDate ASC LIMIT 5 ';
    //        //System.debug('#### strQuery:'+strQuery);
    //        for (SObject so : Database.query(strQuery)) {
    //            results.add(new Result((String)so.get('Name'), so.Id));
    //        }
    //    }
    //    //System.debug('#### results: '+results);
    //    return results;
    //}

    //public class Result {
    //    public String SObjectLabel {get; set;}
    //    public Id SObjectId {get; set;}
        
    //    public Result(String sObjectLabel, Id sObjectId) 
    //    {
    //        this.SObjectLabel = sObjectLabel;
    //        this.SObjectId = sObjectId;
    //    }
    //}

    public PageReference redirectPage()
    {
        return null;
    }

    public PageReference createNewAssPartsSave(){
        return createNewAssParts('Save');
    } 

    public PageReference createNewAssPartsSaveVal(){
        return createNewAssParts('Save and validate');
    }

    public PageReference createNewAssParts(string typeOperation){

        system.debug('@@ dateFromJs: '+dateFromJs);
         Boolean isSuccessful = false;
         Assessment__c newAssessment;
        try{
            
            system.debug('@@ bodyshop: '+bodyshop);


            User intUser = [select UserRole.NAme from User where id =: UserInfo.getUserId()];
            string userRolePrefix =  (intUser.UserRole != null  && intUser.UserRole.Name != null) ? intUser.UserRole.Name.left(2) : '';

            // ASE 23/11/18 : added VAT
            CountryCodeInformationsMapping__c configCountryCodeInfo = null;

            system.debug('@@ intUser:'+intUser);
            system.debug('@@ typeAss:'+typeAss);
            system.debug('@@ typeOperation:'+typeOperation);

            newAssessment = assessment;
            newAssessment.Bodyshop__c = bodyshop.Id;
            if (!Test.isRunningTest()){
                newAssessment.FirstRegistrationDate__c = Date.parse(dateFromJs);
            }
            else{
                newAssessment.FirstRegistrationDate__c = Date.today();
            }
            newAssessment.OrderOrigin__c = 'ManualCreation';
            newAssessment.EntityRules__c = selectedEntity;
            if (selectedEntity != null){
                newAssessment.TECH_EntityCountryCode__c = selectedEntity.left(2);
                newAssessment.EntityCode__c = selectedEntity.remove( newAssessment.TECH_EntityCountryCode__c);
                // ASE 23/11/18 : added VAT
                configCountryCodeInfo = CountryCodeInformationsMapping__c.getValues(selectedEntity.left(2));
            }
           
            String claimRef = String.isNotBlank(newAssessment.ClaimReference__c) ? newAssessment.ClaimReference__c : 'NULL';
            String accRefNumber = bodyshop != null ?  bodyshop.ReferenceNumber__c : null;
            String plateNum = newAssessment.PlateNumber2__c;
            String assessCode = (plateNum != null) ? plateNum : newAssessment.VINNumber__c;
            string newAssessCode = (newAssessment.MissionNumber__c != null) ? newAssessment.MissionNumber__c : claimRef;

           
            
            if (typeAss == 'NewAssessment'){
                /*WCH 13/03/2019 
                if (typeOperation == 'save'){
                    newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_NEW;
                }
                else{
                    newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_READY;    
                }*/
                newAssessment.AssessmentID__c = ('Manual' + newAssessCode + assessCode + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')).toUpperCase();
                newAssessment.AssessmentNumber__c =  (newAssessCode + assessCode + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')).toUpperCase(); 
                newAssessment.Name = newAssessment.AssessmentNumber__c.toUpperCase();
                newAssessment.RecordTypeId =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId();
            }
            else if (typeAss == 'Claim'){
                //String callerSystem = newAssessment.CallerSystem__c;
                //String cleanseCallerSystem = callerSystem != null && (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;      
                newAssessment.RecordTypeId =  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId();
                newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_NEW;
                //newAssessment.AssessmentID__c = ('Manual' + claimRef + accRefNumber + assessCode + null).toUpperCase() ;
                //newAssessment.AssessmentNumber__c =  (claimRef + accRefNumber + assessCode).toUpperCase(); 
                newAssessment.AssessmentID__c = ('Manual' + claimRef + accRefNumber + assessCode + null+ datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')).toUpperCase() ;
                newAssessment.AssessmentNumber__c =  (claimRef + accRefNumber + assessCode + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')).toUpperCase(); 
                newAssessment.Name = newAssessment.AssessmentNumber__c.toUpperCase();
                
                //WCH 07/08/2019 C-003359
                if(String.isNotBlank(newAssessment.TECH_EntityCountryCode__c) && newAssessment.TECH_EntityCountryCode__c.equals(ASPISConstants.assTECH_EntityCountryCodeES)){
                    newAssessment.OrderAuthorised__c=true;
                }

            }
            system.debug('@@ assessment: '+assessment);

            list<Integer> listPositionToRemove = new list<Integer>();
            system.debug('## listNewPartList ' + listNewPartList);

            for(integer i=0; i < listNewPartList.size(); i++){
                //RLA 02/04/2019 C-003133
                setPartTypes.add(listNewPartList[i].Type__c);
                if(!listNewPartList[i].SelectedByBS__c){
                    listPositionToRemove.add(i);
                }
            }
            for(integer i=listPositionToRemove.size()-1; i >= 0 ; i--){
                listNewPartList.remove(listPositionToRemove[i]);
            }


            
            system.debug('@@ listNewPartList: '+listNewPartList);


            //RLA 02/04/2019 C-003133
            if(setPartTypes.size() > 0 
                && bodyshop.Feature__c != null
                && bodyshop.Feature__c.contains('PilotDirectSourcing')){
                String alldirectOrderIds = '';
                String allFirstDistributorsIds = '';
                String allAgencyDistributorsIds = '';
                String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 
                mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(selectedEntity.left(2),newAssessment.BodyShop__c,newAssessment.Manufacturer__c ,bodyshop.ShippingPostalCodeLeft2__c, bodyshop.CarBrandsSuppliedAgency__c, setPartTypes);

                if(!mapPartTypeDistributorsWrap.isEmpty()){
                    for(String ptype : mapPartTypeDistributorsWrap.keySet()){
                        for(Id directOrderIds : mapPartTypeDistributorsWrap.get(ptype).DirectOrderIds){
                            if(!alldirectOrderIds.contains(directOrderIds))
                                alldirectOrderIds += directOrderIds + ';' ;
                        }
                        for(String disId : mapPartTypeDistributorsWrap.get(ptype).FirstDistributor.split(';')){
                            if(disId.contains('-true')){
                               disId = disId.remove('-true');
                            }
                            if(!allFirstDistributorsIds.contains(disId)){
                                allFirstDistributorsIds += disId + ';';
                            }
                        } 
                        if(mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != null && mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != '' ){
                            for(String agencydisId : mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors.split(';')){
                                if(!allAgencyDistributorsIds.contains(agencydisId)){
                                    allAgencyDistributorsIds += agencydisId + ';';
                                }
                            }
                        }
                        //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                        if (String.isNotBlank(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders) ){
                            //WCH 20/11/2018: C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
                            if (!allDistributorsDirOrders.contains(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders)){
                                allDistributorsDirOrders +=','+ mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders;
                            }
                        }
                    }   
                    if(allFirstDistributorsIds != ''){
                        newAssessment.MRSourcing__c = allFirstDistributorsIds.removeEnd(';');
                        newAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                    }
                    if(alldirectOrderIds != ''){
                        alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                    }
                    //newAssessment.Status__c = 'NEW';
                    newAssessment.TECHRulesAppliedDescription__c += 'Results: Number of Purchase orders: ' + allFirstDistributorsIds.split(';').size();
                    //newAssessment.MRSourcing__c = allFirstDistributorsIds; 

                    newAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                    //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                    newAssessment.Tech_DirectOrders__c=alldirectOrderIds;
                     //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                    newAssessment.TechDistAndDirectOrder__c=allDistributorsDirOrders;
                    newAssessment.Feature__c = bodyshop.Feature__c;
                }
                else{
                    newAssessment.MRSourcing__c = 'false';
                    newAssessment.Feature__c = bodyshop.Feature__c;//WCH 21/08/2019 C-003376
                }
            }
            insert newAssessment;
            isSuccessful = true;
            system.debug('## isSuccessful ' + isSuccessful);
            
            if(listNewPartList.size() > 0){
                
                for(PartList__c pl : listNewPartList){
                    pl.Assessment__c = newAssessment.Id;
                                 
                    string Description = String.isNotBlank(pl.Description__c) ? pl.Description__c.replaceAll('\\s+', '') + '-' : 'NULL-';
                    pl.TECH_OriginalPart__c  = (null + '-' 
                                                + pl.PartNumber__c + '-' 
                                                + Description
                                                + newAssessment.Manufacturer__c + '-' 
                                                + newAssessment.AssessmentID__c + '-' 
                                                + null).toUpperCase();
                    pl.RecordTypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
                    // ASE 23/11/18 : added VAT
                    pl.VAT__c = configCountryCodeInfo != null ? configCountryCodeInfo.CountryVAT__c: null;
                    ///RLA 02/04/2019 C-003133
                    if(!mapPartTypeDistributorsWrap.isEmpty()){
                        //not required because all parts are of material type
                        //if(pl.RecordTypeId != Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Labour')){
                            pl.Distributors__c = mapPartTypeDistributorsWrap.containsKey(pl.Type__c) ? mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor : null;
                            pl.NextDistributors__c = mapPartTypeDistributorsWrap.containsKey(pl.Type__c) ? mapPartTypeDistributorsWrap.get(pl.Type__c).NextDistributors : null;
                            pl.TECHDistList__c = mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor;
                        //}
                    }
                }
                system.debug('@@ listNewPartList: '+listNewPartList);
                insert listNewPartList;   
                //WCH 13/03/2019 
                if (typeAss == 'NewAssessment'){
                    if (typeOperation == 'save' ){
                        newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_NEW;
                    }
                    else{
                        newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_READY;    
                    }
                    update newAssessment;    
                }

                if (typeOperation == 'save' || typeAss == 'NewAssessment'){
                    return new PageReference('/'+newAssessment.Id);
                }else{
                    string encodedId = EncodingUtil.base64Encode(Blob.valueOf(newAssessment.Id));
                    return new PageReference(Label.SiteOrder+'?assessmentid='+encodedId+'&lang=fr');
                }
            }
            else{
                apexError = true;
                IF (isSuccessful && newAssessment.id != null){
                    system.debug('@@ here delete');
                    delete newAssessment;
                    assessment.Id = null;
                }
                //isToastError = true;
                redirectionInErrorModal = true;
                system.debug('@@ here');
                listNewPartList.add(new PartList__c(Manual_Creation__c = true, Type__c = 'A', Quantity__c = 1, SelectedByBS__c = true,Price__c=0));
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.AtLeastOnePart));
                apexErrorMsg = Label.AtLeastOnePart;
                system.debug('@@ apexErrorMsg'+apexErrorMsg);


            }
        }
        catch (DMLException e)
        {
            apexError = true;
            system.debug('@@ here2 delete'+isSuccessful + newAssessment.id);

             IF (isSuccessful && newAssessment.id != null){
                system.debug('@@ here2 delete');

                delete newAssessment;
                assessment.Id = null;
                
            }

            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                system.debug('@@ here1');
                // error is caused by validation error
                //isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                apexErrorMsg = (e.getDmlMessage(0)).escapeEcmaScript();
                system.debug('@@ apexErrorMsg'+apexErrorMsg);

            }
            else
            {
                system.debug('@@ here2'+e.getMessage() + ' : ' + e.getStackTraceString());
                //isToastError = true;
                apexError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
                apexErrorMsg =( e.getMessage() + ' : ' + e.getStackTraceString()).escapeEcmaScript();
                system.debug('@@ apexErrorMsg'+apexErrorMsg);

            }
        }
        catch(Exception e)
        {
            apexError = true;
             IF (isSuccessful && newAssessment.id != null){
                system.debug('@@ here2 delete');

                delete newAssessment;
                assessment.Id = null;                
            }
            system.debug('@@ here3');
            system.debug('@@ here delete3');


            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            apexErrorMsg = ( e.getMessage() + ' : ' + e.getStackTraceString()).escapeEcmaScript();
            system.debug('@@ apexErrorMsg'+apexErrorMsg);

        }

        return null;
    }

    public PageReference back(){
        listNewPartList.clear();
        apexError = false;
        isToastError = false;

        return new PageReference('/'+accountId);
    }

    public void addNewPL(){
        apexError = false;
        isToastError = false;
        listNewPartList.add(new PartList__c(Manual_Creation__c = true, Type__c = 'A', Quantity__c = 1, SelectedByBS__c = true,Price__c=0));
    }

    //public List<SelectOption> getPartTypeOptions(){
    //    system.debug('## START getPartTypeOptions');
    //    List<SelectOption> optns = new List<Selectoption>();
    //    optns.add(new selectOption('A', 'A'));
    //    system.debug('## END getPartTypeOptions');   
    //    return optns;       
    //}

    public List<Selectoption> getentityCodes(){
        List<Selectoption> lstentityCode = new List<selectoption>();
        lstentityCode.add(new selectOption('', '- None -'));
        set<String> setEntity = new set<String>();

        if (bodyshop != null){
            for(MasterRules__c mr :[SELECT id,Entity__c FROM MasterRules__c  where Country__c  = :bodyshop.ShippingCountry]){
                //mapEntity.put(mr.id,mr.Entity__c);
                if(mr.Entity__c.right(3) == '(2)'){
                    mr.Entity__c = mr.Entity__c.left(mr.Entity__c.length() - 3);
                }
                setEntity.add(mr.Entity__c);
            }
            for (String ent: setEntity){
                lstentityCode.add(new selectoption(ent,ent));    
            }
        }
        system.debug('@@ lstentityCode: '+lstentityCode);
        return lstentityCode; 
    }
}