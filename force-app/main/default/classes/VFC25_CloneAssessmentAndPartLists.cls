/*
----------------------------------------------------------------------
-- - Name          : VFC25_CloneAssessmentAndPartLists
-- - Author        : WCH
-- - Description   : Controller Class 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 05-MAR-2019  WCH   1.0      Original Version (C-003590 : Remove Clear Assessment button and implement a new button that allows Local Admins to create a duplicate assessment)
-- 24-AUG-2020  WCH   1.1      C-003838 - Nob - Migrate Billing information to new fields
* Hootesh R       10/01/2022    C-004405 : No Ordering on Fake References
----------------------------------------------------------------------*/
public without sharing class VFC25_CloneAssessmentAndPartLists {
    public Assessment__c newAssessment {get;set;}

    private final sObject mysObject;
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
    public String parentAssessmentId {get;set;}
    public CountryCodeInformationsMapping__c configCountryCodeInfo {get;set;}
    private static set<String> setPartTypes = new set<string>();
    private static map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();

    public VFC25_CloneAssessmentAndPartLists() {
        locale = UserInfo.getLocale()=='nl_BE'?'nl-BE':UserInfo.getLocale();
        hasErrors = apexError = false;
        isToastError = false;
        redirectionInErrorModal = false;
        listNewPartList = new List<PartList__c>();
        bodyshopName = '';
        apexErrorMsg = '';
        integer NumberOfClonedAss = 0;
        accountId = ApexPages.currentPage().getParameters().get('id');
        parentAssessmentId = ApexPages.currentPage().getParameters().get('parentAssessmentId');

        system.debug('## accountId'+accountId);
        system.debug('## parentAssessmentId'+parentAssessmentId);
        
        //checking current user has correct profiles
        List<User> lstCurrentUser = [ SELECT Id, Profile.name FROM User WHERE Id = :Userinfo.getUserId()];
        CorrectPermission = true;

        System.debug('@@ lstCurrentUser: '+lstCurrentUser);

        //initialising the assessment and partlist from the assessment it is cloned from
        //WCH 24/08/2020 C-003838 changed BillingCountry to custom field
        List<Account> lstAcc = [Select Id, Name,ReferenceNumber__c, BillingCountry__c,ShippingCountry, ContactUser__r.profile.Name,ContactUser__r.Name,ContactUser__r.ProfileId, ContactUser__r.Tech_LicenceName__c,Feature__c, ShippingPostalCodeLeft2__c, CarBrandsSuppliedAgency__c from Account WHERE Id =:accountId];
        if(lstAcc.size()<1){
            apexError = true;CorrectPermission=false;
            apexErrorMsg = 'No BS found';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, apexErrorMsg));
            return;
        }
        bodyshop = lstAcc[0];
        bodyshopName = bodyshop.Name; 
        //HRM C-004405 : No Ordering on Fake References - added NotForOrder__c to query on partlist
        List<Assessment__c> lstAss = [SELECT Id,Status__c,isShoppingList__c, ParentAssessment__c, Name, BodyShop__c, Entity__c, AssessmentNumber__c, CreatedDate, LastModifiedDate, SpecialAgreement__c, SpecialRenting__c, VINCheck__c, Fleet__c, TotalLoss__c, BuildDate__c, CrossReferences__c, SupposedOfFraud__c, DateOfIncident__c, FirstRegistrationDate__c, EntityCode__c, Compensated__c ,ModelV2__c, MissionNumber__c, ClaimReference__c, Manufacturer__c, EntityRules__c, ASReference__c, Bodyshop_is_Eligible_Non_AXA__c, PlateNumber2__c, TECH_EntityCountryCode__c, VINNumber__c, AssessmentID__c, BodyShop__r.Type, BodyShop__r.SepaValid__c, MRSourcing__c,OwnerId,  OrderAuthorised__c,BodyShop__r.OrderFromAT__c , RecordType.DeveloperName, RecordTypeId,Tech_ClonedFrom__c,TransactionId__c, TECHRulesAppliedDescription__c, (SELECT Id, Name, VAT__c, Quantity__c, PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, Description__c, NextDistributors__c, SelectedByBS__c, CrossReferenceId__c, IsSourced__c, Assessment__c, TECH_OriginalPart__c,ProducerName__c, Distributors__c, QuantityOrdered__c, CrossReferenceId__r.Name, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c,  DiscountRecord__c,DiscountRecord__r.Rebate__c,ExternalId__c,Manual_Creation__c,RecordTypeId,RecordType.Name,CrossReferenceId__r.UseClassicSourcing__c FROM PartsLists__r WHERE SelectedByBS__c = true AND isDeleted__c = false AND NotForOrder__c =false) FROM Assessment__c WHERE (RecordType.DeveloperName =: ASPISConstants.ASSESS_RT_DeveloperName_Claim or RecordType.DeveloperName =:ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment) and ID =:parentAssessmentId];
        if(lstAss.size()<1){
            apexError = true;CorrectPermission=false;
            apexErrorMsg = 'No Assessment found';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, apexErrorMsg));
            return;
        }

        newAssessment = lstAss[0].clone(false, true);
        newAssessment.AssessmentID__c=newAssessment.Name+'COPY'+datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'').toUpperCase();
        newAssessment.Tech_ClonedFrom__c=lstAss[0].Id;
        newAssessment.Assessment_duplicated_from__c=lstAss[0].Id;
        newAssessment.MRSourcing__c=null;
        newAssessment.Feature__c=(bodyshop.Feature__c != null && bodyshop.Feature__c.contains('PilotDirectSourcing')) ? 'PilotDirectSourcing' : '';
        newAssessment.TECHRulesAppliedDescription__c='';
        NumberOfClonedAss=database.countQuery('select count() from Assessment__c where Tech_ClonedFrom__c=\''+lstAss[0].Id+'\'');
        newAssessment.Name=lstAss[0].Name+'-bis'+(NumberOfClonedAss<=0 ? '1' : String.valueOf(NumberOfClonedAss+1));

        if(typeAss == 'Claim'){
            newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_NEW;
        }
        typeAss = lstAss[0].RecordType.DeveloperName;
        selectedEntity = newAssessment.EntityRules__c; 
        configCountryCodeInfo = CountryCodeInformationsMapping__c.getValues(lstAss[0].TECH_EntityCountryCode__c);

        system.debug('lstAss[0].PartsLists__r>>'+lstAss[0].PartsLists__r.size());
        for(PartList__c currentPart : lstAss[0].PartsLists__r)
        {
            PartList__c clonedPart = currentPart.clone(false, true);
            clonedPart.OriginalPart__c = currentPart.Id;
            addExistingPL(clonedPart);
            system.debug('clonedPart.ExternalId__c>>'+clonedPart.ExternalId__c);
        }
    }

    /* public PageReference createNewAssPartsSave(){
        return createNewAssParts('Save');
    }  */

    public PageReference createNewAssPartsSaveVal(){
        return createNewAssParts('Save and validate');
    }

    public PageReference createNewAssParts(string typeOperation){

         Boolean isSuccessful = false;

        try{
            
            system.debug('@@ newAssessment: '+newAssessment);

            list<Integer> listPositionToRemove = new list<Integer>();
            system.debug('## listNewPartList ' + listNewPartList);

            for(integer i=0; i < listNewPartList.size(); i++){
                if((listNewPartList[i].Manual_Creation__c==true || (listNewPartList[i].Manual_Creation__c!=true && listNewPartList[i].RecordTypeId == Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId())) && listNewPartList[i].SelectedByBS__c){
                    setPartTypes.add(listNewPartList[i].Type__c);
                }
                
                if(!listNewPartList[i].SelectedByBS__c){
                    listPositionToRemove.add(i);
                }
            }
            for(integer i=listPositionToRemove.size()-1; i >= 0 ; i--){
                listNewPartList.remove(listPositionToRemove[i]);
            }


            
            system.debug('@@ listNewPartList: '+listNewPartList);
            system.debug('@@ setPartTypes: '+setPartTypes);
            system.debug('@@ newAssessment.BodyShop__c: '+newAssessment.BodyShop__c);
            system.debug('@@ newAssessment.Manufacturer__c: '+newAssessment.Manufacturer__c);
            system.debug('@@ bodyshop.ShippingPostalCodeLeft2__c: '+bodyshop.ShippingPostalCodeLeft2__c);
            system.debug('@@ bodyshop.CarBrandsSuppliedAgency__c: '+bodyshop.CarBrandsSuppliedAgency__c);
            system.debug('@@ selectedEntity: '+selectedEntity);
            system.debug('@@ selectedEntity: '+selectedEntity.left(2));

            if(setPartTypes.size() > 0 
                && bodyshop.Feature__c != null
                && bodyshop.Feature__c.contains('PilotDirectSourcing')){
                String alldirectOrderIds = '';
                String allFirstDistributorsIds = '';
                String allAgencyDistributorsIds = '';
                String allDistributorsDirOrders = '';
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
                        if (String.isNotBlank(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders) ){
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
                    newAssessment.TECHRulesAppliedDescription__c += 'Results: Number of Purchase orders: ' + allFirstDistributorsIds.split(';').size();
                    newAssessment.MRSourcing__c = allFirstDistributorsIds; 

                    newAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                    newAssessment.Tech_DirectOrders__c=alldirectOrderIds;
                    newAssessment.TechDistAndDirectOrder__c=allDistributorsDirOrders;
                    newAssessment.Feature__c = bodyshop.Feature__c;
                }
                else{
                    newAssessment.MRSourcing__c = 'false';
                    newAssessment.Feature__c = bodyshop.Feature__c;
                }
            }
            insert newAssessment;
            isSuccessful = true;
            system.debug('## isSuccessful ' + isSuccessful);
            system.debug('listNewPartList after>>'+listNewPartList);
            system.debug('mapPartTypeDistributorsWrap>>'+mapPartTypeDistributorsWrap);
            if(listNewPartList.size() > 0){
                
                for(PartList__c pl : listNewPartList){
                    //update partlist with assessmen ID
                    pl.Assessment__c = newAssessment.Id;
                    pl.Assessment__r = newAssessment;
                    string Description = String.isNotBlank(pl.Description__c) ? pl.Description__c.replaceAll('\\s+', '') + '-' : 'NULL-';
                    String techOriginalPart = (null + '-' 
                                                    + pl.PartNumber__c + '-' 
                                                    + Description
                                                    + newAssessment.Manufacturer__c + '-' 
                                                    + newAssessment.AssessmentID__c + '-' 
                                                    + null).toUpperCase();
                    //if manual part
                    if(pl.Manual_Creation__c){
                        pl.TECH_OriginalPart__c  =techOriginalPart;
                        pl.RecordTypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
                        // add VAT
                        pl.VAT__c = configCountryCodeInfo != null ? configCountryCodeInfo.CountryVAT__c: null;
                    }else{//else existing part list
                        //update TECH_OriginalPart__c
                        pl.TECH_OriginalPart__c = typeAss.equals(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment) ? null : (String.isNotBlank(pl.ExternalId__c)?(newAssessment.AssessmentID__c+'-'+pl.ExternalId__c):techOriginalPart);
                    }
                    
                    system.debug('mapPartTypeDistributorsWrap type>>'+pl.Type__c);
                    //Fill in the required fields for direct sourcing

                    if(!mapPartTypeDistributorsWrap.isEmpty() && pl.RecordTypeId == Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId()){
                            pl.Distributors__c = mapPartTypeDistributorsWrap.containsKey(pl.Type__c) ? mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor : null;
                            pl.NextDistributors__c = mapPartTypeDistributorsWrap.containsKey(pl.Type__c) ? mapPartTypeDistributorsWrap.get(pl.Type__c).NextDistributors : null;
                            pl.TECHDistList__c = mapPartTypeDistributorsWrap.containsKey(pl.Type__c) ? mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor : null;
                    }
                }
                system.debug('@@ listNewPartList: '+listNewPartList);
                insert listNewPartList;   

                if (typeAss == 'NewAssessment'){
                    newAssessment.Status__c = ASPISConstants.ASSESS_STATUS_READY;
                    update newAssessment;    
                }
                return new PageReference('/'+newAssessment.Id);
            }
            else{
                apexError = true;
                IF (isSuccessful && newAssessment.id != null){
                    system.debug('@@ here delete');
                    delete newAssessment;
                    newAssessment.Id = null;
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
                newAssessment.Id = null;
                
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
                newAssessment.Id = null;                
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

        return new PageReference('/'+parentAssessmentId);
    }

    public void addNewPL(){
        apexError = false;
        isToastError = false;
        listNewPartList.add(new PartList__c(Manual_Creation__c = true, Type__c = 'A', Quantity__c = 1, SelectedByBS__c = true,Price__c=0));
    }
    public void addExistingPL(PartList__c existingPL){
        listNewPartList.add(existingPL);
    }
}