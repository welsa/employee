/*************************************************************************************
Class Name - VFC11_OrderRunSourcing
Version - 1.0
Created Date - 24 January 2017
Function - Controller extension for page OrderRunSourcing
    
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       24/01/2017  Original Version (case 1822 : ASPIS 2.0 : Order Process - OrderRunSourcing)
* Dourga       29/01/2018  C-002174 - Avoid running again Eligibility and sourcing   
* Vaynee       03/04/2018  C-002315 - Cross Scripting   
* Ruksaar L    27/11/2018  C-002782   CJP A'
* Welsa C      17/04/2019  C-003192   For Quotation direct sourcing is not applied
* Ruksaar L    29/04/2019  C-003142 Cross Ref Sourcing R4 for Spain
* Welsa C      09/08/2019  C-003370 Request for Quotation displays Labour parts
**************************************************************************************/
public without sharing class OrderRunSourcing {

    public Assessment__c assessmentToDisplay{get;set;}
    public String encryptedText {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public User userConnected {get;set;}
    public Account bodyShopConnected{get;set;}
    public Group userConnectedGroup{get;set;}
    public String encryptedSourceAssessmentId{get;set;}
    public String comment {get; set;}

    /*********************************/
    //AMI 26/06/18 : Community Rollout 
    //             : string to hold license name if user is a community user
    //             : check will be done later on this string together with connectedUserLicenseName to ensure no apex sharing is created if user 
    //             : has a community license
    string licenseName = '';
    string formattedLicenseName = '';

    //             : this string will be used to hold connected user license name
    string connectedUserLicenseName = '';

    //             : this string will be used to hold connected user id
    string connectedUsrId = '';

    //WCH 17/04/2019 C-003192   For Quotation direct sourcing is not applied
    private static set<String> setPartTypes = new set<string>();
    
    private static map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();

    //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
    private static set<String> setPartTypesDirectSourcing = new set<string>();
    private static set<String> setPartTypesClassicSourcing = new set<string>();
    private static set<String> setDist = new set<String>();

    public OrderRunSourcing() {
        hasErrors    = false;
        isToastError = false;
        //VSU 28/03/2018 C-002315         

        try
        {
            /*********************************/
            //AMI 26/06/18 : Community Rollout 
            //             : QUerying connected user license name
            /*for(User us : [Select id,Profile.UserLicense.Name 
                            from User 
                            where Id=: UserInfo.getUserId()]){
                connectedUsrId = us.id;
                connectedUserLicenseName = us.Profile.UserLicense.Name.toLowerCase();
            }*/
            
            connectedUsrId = UserInfo.getUserId();
            connectedUserLicenseName = UserInfo.getUserType().toLowerCase();

            licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
            formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

            encryptedText = ApexPages.currentPage().getParameters().get('AssessmentId');
            String assessmentId = decryptBase64(encryptedText);

            Id idAss = assessmentId != null? assessmentId : null;

            if(ApexPages.currentPage().getParameters().get('SourceAssessmentId') != null){
                encryptedSourceAssessmentId = ApexPages.currentPage().getParameters().get('SourceAssessmentId');
                
                Id idSrc = encryptedSourceAssessmentId != null? decryptBase64(encryptedSourceAssessmentId) : null;
            }

            userConnected = [select BodyShopID__c from User where id= :UserInfo.getUserId()];

            if(userConnected.BodyShopID__c != null){
                bodyShopConnected = [select ReferenceNumber__c, SepaValid__c, Type
                                            , Feature__c,ShippingPostalCodeLeft2__c,CarBrandsSuppliedAgency__c/*WCH 17/04/2019 C-003192*/ 
                                            from Account where ReferenceNumber__c =: userConnected.BodyShopID__c];
                userConnectedGroup = [ SELECT  Id, Name FROM Group WHERE Name =: userConnected.BodyShopID__c];
            }
            //VSU 02/04/18 C-002315
            
            /*********************************/
            //AMI 26/06/18 : Community Rollout 
            //             : Querying claim assessment owner
            assessmentToDisplay = [select Id,Status__c,  ParentAssessment__c,  Name,  BodyShop__c, Entity__c, AssessmentNumber__c, MREligibility__c,   
                                        SpecialAgreement__c,  SpecialRenting__c,  VINCheck__c,  Fleet__c, TotalLoss__c, LastModifiedDate, MRSourcing__c, 
                                        SupposedOfFraud__c,  DateOfIncident__c,  FirstRegistrationDate__c,  EntityCode__c, CreatedDate,
                                        ModelV2__c,  MissionNumber__c,  ClaimReference__c,  Manufacturer__c, EntityRules__c, ASReference__c, TechDistAndDirectOrder__c, Tech_DirectOrders__c,
                                        PlateNumber2__c,  TECH_EntityCountryCode__c,  VINNumber__c,  AssessmentID__c,  BodyShop__r.Type, CrossReferences__c, Comment__c,OwnerId,/*RLA 29/04/2019 C-003142*/BodyShop__r.Feature__c,BodyShop__r.ShippingPostalCodeLeft2__c,BodyShop__r.CarBrandsSuppliedAgency__c, 
                                        (select Id, Name, VAT__c, Quantity__c, PartNumber__c, Price__c, Type__c, OriginalPart__c,
                                                Original__c, Description__c, ProducerName__c, QuantityOrdered__c, TECH_OrderedCounter__c,
                                                SelectedByBS__c, CrossReferenceId__c, IsSourced__c, Assessment__c, TECH_OriginalPart__c, CrossReferenceId__r.Name,CrossReferenceId__r.UseClassicSourcing__c,RecordType.DeveloperName, Assessment__r.bodyShop__r.Feature__c,/*RLA 29/04/2019 C-003142*/
                                                Alpha_Scale_MRID__c, DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c //VSU 15/06/18 C-002278 
                                                ,DiscountRecord__c,DiscountRecord__r.Rebate__c
                                                ,Distributors__c,NextDistributors__c /*WCH 17/04/2019 C-003192*/
                                        from PartsLists__r
                                        where SelectedByBS__c = true   
                                        and isDeleted__c = false
                                        and RecordType.DeveloperName !=: ASPISConstants.PARTLIST_RT_DeveloperName_Labour/*WCH 09/08/2019 C-003370*/)
                                    from Assessment__c
                                    where Id =: assessmentId];

            if(assessmentToDisplay != null)
            {
                comment = assessmentToDisplay.Comment__c;
            }
        }
        catch (Exception e)
        {
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
            else{
                hasErrors    = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.NoAssessmentFound));
            }
        }
    }

    public String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();

        return decryptedText;
    }

    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    //Method used to create claim Order assessment, Pre-Draft Quote Purchase Order and Pre-Acceptance Sales Order
    public PageReference createClaimOrderAssessment()
    {
        hasErrors = false;
        isToastError = false;

        //Assessemnt claim order which is created
        Assessment__c newClaimOrderAssessment = new Assessment__c();
        list<Assessment__Share> assShareExistList;
        list<Account> listDistributors = new list<Account>();

        // Creating a savepoint
        SavePoint beforeDML = Database.setSavepoint();
        
        try
        {
            if(assessmentToDisplay != null){
                // Locking the parent
                Assessment__c lockParentAssessment = [  SELECT  Id
                                                        FROM    Assessment__c
                                                        WHERE   Id =: assessmentToDisplay.Id FOR UPDATE];

                Assessment__c claimAssessment = assessmentToDisplay;
                // counting on the locking to prevent the same prefix in the claim order assessment
                newClaimOrderAssessment = populateNewClaimOrderAssessment(claimAssessment);
                
                // Setting the comment
                newClaimOrderAssessment.Comment__c = comment;
                
                insert newClaimOrderAssessment;

                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : Bypassing programatic sharing
                if((string.isBlank(formattedLicenseName) || 
                   (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains(connectedUserLicenseName)))){
                    if(userConnectedGroup != null){
                        assShareExistList = [SELECT UserOrGroupId, ParentId
                                                FROM Assessment__Share
                                                WHERE UserOrGroupId =: userConnectedGroup.Id
                                                AND ParentId =: claimAssessment.Id];
                    }

                    if(userConnectedGroup != null && claimAssessment.BodyShop__r.Type == 'Expert' && assShareExistList.IsEmpty()){
                        insert new Assessment__Share(   UserOrGroupId   = userConnectedGroup.Id,
                                                        ParentId        = claimAssessment.Id,
                                                        AccessLevel     = 'Read');
                    }
                }
                System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);

                List<PartList__c> partsToInsertList = copyPartsToClaimOrder(claimAssessment, newClaimOrderAssessment);

                System.debug('## setPartTypesDirectSourcing' + setPartTypesDirectSourcing);
                System.debug('## setPartTypesClassicSourcing' + setPartTypesClassicSourcing);
                
                String allFirstDistributorsIds = '';
                set<String> setClassicSourcingDist = new set<String>();
                set<String> setDirectSourcingDist = new set<String>();

                //WCH 17/04/2019 C-003192   For Quotation direct sourcing is not applied
                if( assessmentToDisplay.bodyShop__c !=null && assessmentToDisplay.bodyShop__r.Feature__c != null && assessmentToDisplay.bodyShop__r.Feature__c.contains('PilotDirectSourcing')
                    && setPartTypesDirectSourcing.size() > 0)//RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                {
                    System.debug('## got in direct sourcing' + assessmentToDisplay.bodyShop__r.Feature__c);

                    String alldirectOrderIds = '';

                   
                    if (setPartTypesDirectSourcing.size() > 0){
                        setPartTypes = new set<string>();
                        setPartTypes.addAll(setPartTypesDirectSourcing);
                    }

                    
                    String allAgencyDistributorsIds = '';
                    String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 
                    mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(newClaimOrderAssessment.TECH_EntityCountryCode__c,newClaimOrderAssessment.BodyShop__c,newClaimOrderAssessment.Manufacturer__c ,assessmentToDisplay.bodyShop__r.ShippingPostalCodeLeft2__c, assessmentToDisplay.bodyShop__r.CarBrandsSuppliedAgency__c, setPartTypes);

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
                            
                            

                            System.debug('## newClaimOrderAssessment.MRSourcing__c' + newClaimOrderAssessment.MRSourcing__c);
                            System.debug('## allFirstDistributorsIds' + allFirstDistributorsIds);
                            System.debug('## setDist' + setDist);
                            //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                            if (setDist.size() > 0){

                                //set<String> setDist = new set<String>();
                                //for(String dis : claimAssessment.MRSourcing__c.split(';')){
                                //    setDist.add(dis);
                                //}
                                setClassicSourcingDist.addAll(setDist);
                                for(String dis : allFirstDistributorsIds.split(';')){
                                    if (setClassicSourcingDist.contains(dis)){
                                        setClassicSourcingDist.remove(dis);
                                    }
                                    setDist.add(dis);
                                    setDirectSourcingDist.add(dis);
                                }    
                                newClaimOrderAssessment.MRSourcing__c = string.join(new List<String>(setDist),';');
                                System.debug('## newClaimOrderAssessment.MRSourcing__c' + newClaimOrderAssessment.MRSourcing__c);
                            }
                            else{
                                newClaimOrderAssessment.MRSourcing__c = allFirstDistributorsIds.removeEnd(';');
                                setDirectSourcingDist.addAll(new set <string>(new list<string>(newClaimOrderAssessment.MRSourcing__c.split(';'))));
                            }

                            newClaimOrderAssessment.AgencyDistributors__c = allAgencyDistributorsIds;

                        }
                        System.debug('setDirectSourcingDist' + setDirectSourcingDist);
                        System.debug('setClassicSourcingDist' + setClassicSourcingDist);

                        if(alldirectOrderIds != ''){
                            alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                        }
                        //newAssessment.Status__c = 'NEW';
                        newClaimOrderAssessment.TECHRulesAppliedDescription__c += 'Results: Number of Purchase orders: ' + allFirstDistributorsIds.split(';').size();



                        newClaimOrderAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                        //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                        newClaimOrderAssessment.Tech_DirectOrders__c=alldirectOrderIds;
                         //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                        newClaimOrderAssessment.TechDistAndDirectOrder__c=allDistributorsDirOrders;
                        newClaimOrderAssessment.Feature__c = assessmentToDisplay.bodyShop__r.Feature__c;

                        System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);
                        System.debug('## mapPartTypeDistributorsWrap' + mapPartTypeDistributorsWrap);
                        


                    }
                    else{
                        newClaimOrderAssessment.MRSourcing__c = 'false';
                    }
                }
                //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                if (newClaimOrderAssessment.bodyShop__r.Feature__c != null
                        && newClaimOrderAssessment.bodyShop__r.Feature__c.contains('PilotDirectSourcing')){
                    for (PartList__c p: partsToInsertList){
                        if(p.RecordType.DeveloperName != ASPISConstants.PARTLIST_RT_DeveloperName_Labour
                            && String.isNotBlank(p.CrossReferenceId__c)){
                            if (!p.CrossReferenceId__r.UseClassicSourcing__c
                                && !mapPartTypeDistributorsWrap.isEmpty()){
                                System.debug('## p.Description__c' + p.Description__c);

                                p.Distributor__c = mapPartTypeDistributorsWrap.containsKey(p.Type__c) ? mapPartTypeDistributorsWrap.get(p.Type__c).FirstDistributor : p.Distributor__c;

                                p.Distributors__c = mapPartTypeDistributorsWrap.containsKey(p.Type__c) ? mapPartTypeDistributorsWrap.get(p.Type__c).FirstDistributor : p.Distributors__c;
                                p.NextDistributors__c = mapPartTypeDistributorsWrap.containsKey(p.Type__c) ? mapPartTypeDistributorsWrap.get(p.Type__c).NextDistributors : p.NextDistributors__c;
                                p.TECHDistList__c = p.Distributors__c;
                            }
                            else{
                                p.Distributors__c = null;
                                p.NextDistributors__c = null;
                                p.TECHDistList__c = p.Distributor__c;    
                            }
                        }
                    }
                }

                if(partsToInsertList.size() > 0)
                {
                    
                    system.debug('@@@ partsToInsertList: '+partsToInsertList);

                    //insert partsToInsertList;
                    upsert partsToInsertList TECH_OriginalPart__c; //RLA C-002690 Spain audatex assessments in r4 
                } 

                List<Assessment__c> assessmentToUpdateList = new List<Assessment__c>();

                //DUN 29/01/2018 C-002174 - if MREligibility__c and MRSourcing__c, use list of distributor Id to create PO instead of triggering eligiblity and sourcing
                if(claimAssessment.MREligibility__c && claimAssessment.MRSourcing__c != null 
                    && (!(!String.isBlank(assessmentToDisplay.bodyShop__r.Feature__c) && /*WCH 17/04/2019 C-003192*/assessmentToDisplay.bodyShop__r.Feature__c.contains('PilotDirectSourcing')))
                        || (String.isNotBlank(assessmentToDisplay.bodyShop__r.Feature__c) && assessmentToDisplay.bodyShop__r.Feature__c.contains('PilotDirectSourcing')
                            && (setPartTypesClassicSourcing.size() > 0 || setDirectSourcingDist.size() > 0))//RLA 29/04/2019 C-003142
                       ){
                    system.debug('ass is status sourced');
                    system.debug('ass is status sourced, setDirectSourcingDist>>'+setDirectSourcingDist);
                    //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                    if (setDirectSourcingDist.size() > 0 ){
                        list<Account> listDistributorsDirect = new list<Account>();
                        list<Account> listDistributorsNormal = new list<Account>();

                        for(String dis : setDirectSourcingDist){
                            listDistributorsDirect.add(new Account(Id=dis));
                        }
                        for(String dis : setClassicSourcingDist){
                            listDistributorsNormal.add(new Account(Id=dis));
                        }
                        System.debug('listDistributorsNormal' + listDistributorsNormal);

                        System.debug('listDistributorsDirect' + listDistributorsDirect);

                        if(listDistributorsNormal.size() > 0){
                            ASPISPurchaseOrder.createOrders(newClaimOrderAssessment,listDistributorsNormal,'',null,new set <id>(),new map <id,Account>());                            
                        }
                        if(listDistributorsDirect.size() > 0){
                            set <Id> agencydistributorsId = new set <Id>();

                            if(newClaimOrderAssessment.AgencyDistributors__c != null && newClaimOrderAssessment.AgencyDistributors__c != ''){
                                for(String adisId : newClaimOrderAssessment.AgencyDistributors__c.split(';')){
                                    agencydistributorsId.add(adisId);
                                }
                            }
                            Set<Id> directOrdersSet = new Set<Id>();
                            if(!String.isBlank(newClaimOrderAssessment.Tech_DirectOrders__c)){
                                for(String dOId : newClaimOrderAssessment.Tech_DirectOrders__c.split(';')){
                                    directOrdersSet.add(dOId);
                                }
                            }
                            System.debug('@@ do direct sourcing ' + partsToInsertList);

                            ASPISDirectSourcing.createPurchaseOrders(newClaimOrderAssessment, listDistributorsDirect, null, null, null, null,'P0', agencydistributorsId,directOrdersSet);
                        }
                        //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                        newClaimOrderAssessment.Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED;
                        assessmentToUpdateList.add(newClaimOrderAssessment);
                        System.debug('@@ newClaimOrderAssessment.Status__c>> ' + newClaimOrderAssessment.Status__c);
                    }
                    else{
                        
                        for(String dis : setDist){
                            listDistributors.add(new Account(Id=dis));
                        }
                        
                        if(listDistributors.size() > 0){
                            ASPISPurchaseOrder.createOrders(newClaimOrderAssessment,listDistributors,'',null,new set <id>(),new map <id,Account>());
                            
                            //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                            //newClaimOrderAssessment.Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED;
                            //assessmentToUpdateList.add(newClaimOrderAssessment);
                             assessmentToUpdateList.add(new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                                                     Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED));
                        }

                    }
                    
                }  
                else{
                    system.debug('ass is status ready');
                    // Passing the assessment to Ready to generate the PO and OLs
                    
                    //WCH 17/04/2019 C-003192   For Quotation direct sourcing is not applied
                    //newClaimOrderAssessment.Status__c  = ASPISConstants.ASSESS_STATUS_READY;
                    //assessmentToUpdateList.add(newClaimOrderAssessment);
                    assessmentToUpdateList.add(new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                                                     Status__c  = ASPISConstants.ASSESS_STATUS_READY));
                
                } 
                // ABT - 04-MAY-2017 - C-001660 - Clearing the parent short term deletion
                assessmentToUpdateList.add(new Assessment__c(Id                         = claimAssessment.Id,
                                                             ShortTermDeletionDate__c   = null,
                                                             //,LongTermDeletionDate__c    = null  //RLA C-2002 Commented by RLA to remove later
                                                             AlreadyQuoted__c = true));

                update assessmentToUpdateList;

                //select PO and its OL to update suppliable orderlines 
                // List<PurchaseOrder__c> listPO = [SELECT  Assessment__c, status__c, Distributor__r.ReferenceNumber__c, Distributor__r.DistributorConnected__c, Assessment__r.ClaimReference__c, Name, DistributorPOReference__c, BodyShopOrderNumber__c,
                //                                     (SELECT Id, PartNumber__c, Description__c, Type__c, Quantity__c, Manufacturer__c, Suppliable__c from OrderLines__r),
                //                                     Assessment__r.BodyShop__r.Name, Assessment__r.BodyShop__r.ReferenceNumber__c, Assessment__r.BodyShop__r.VATNumber__c,
                //                                     Brand__c, AssetModel__c, AssetRegistrationDate__c, PlateNumber__c, VINNumber__c,  ReleaseDate__c 
                //                                 FROM PurchaseOrder__c 
                //                                 WHERE Assessment__c =: newClaimOrderAssessment.Id and Distributor__r.DistributorConnected__c = true];

                // make WS call
                //RESTGetSASAvailability.callFutureSAS(json.serialize(listPO));  

                String assId = encryptBase64(newClaimOrderAssessment.Id);

                return new PageReference('/apex/OrderConfirmation?AssessmentId=' + (((encryptedSourceAssessmentId != null) && (encryptedText != encryptedSourceAssessmentId)) ? (assId + '&SourceAssessmentId=' + encryptedSourceAssessmentId) : assId)); 
            }
        }
        catch (DMLException e)
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
        }
        catch(Exception e)
        {
            hasErrors = true;

            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));

            // Rollback to prevent inconsistency of data
            Database.rollback(beforeDML);
        }

        return null;
    }

    /**
     * The suffix number in string format
     * @param  claimAssessment The parent assessment (Claim)
     * @return                 The suffix number in string format
     */
    private String getAssessmentNumberSuffix(Assessment__c claimAssessment)
    {
        // String assessmentNumberSuffix = '1';

        // List<Assessment__c> childClaimOrderList = [ SELECT  Id, AssessmentNumber__c
        //                                             FROM    Assessment__c
        //                                             WHERE   ParentAssessment__c =: claimAssessment.Id
        //                                             AND     RecordType.DeveloperName = 'ClaimOrder'
        //                                             Order By CreatedDate DESC];

        // if(childClaimOrderList.size() > 0)
        // {
        //     // Taking the first one as it is order by created date in descending order
        //     assessmentNumberSuffix = String.valueOf(Integer.valueOf(childClaimOrderList[0].AssessmentNumber__c.substringAfterLast('-')) + 1);
        // }
        
        Integer assessmentNumberSuffix = 1;
        // Looping the claim orders as in test class the correct value is not being taken due to the same time on created date
        for(Assessment__c existingClaimOrder : [SELECT  Id, AssessmentNumber__c
                                                FROM    Assessment__c
                                                WHERE   ParentAssessment__c =: claimAssessment.Id
                                                AND     RecordType.DeveloperName = 'ClaimOrder'])
        {
            if(assessmentNumberSuffix <= Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')))
            {
                assessmentNumberSuffix = Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')) + 1;
            }
        }
    

        return String.valueOf(assessmentNumberSuffix);
    }

    /**
     * Function to clone the claim assessment and build the claim order assessment
     * @param  claimAssessment The claim assessment to clone
     * @return                 Claim Order Assessment with the claim assessment as its parent
     */
    private Assessment__c populateNewClaimOrderAssessment(Assessment__c claimAssessment)
    {
        // Cloning the parent assessement
        Assessment__c currentClaimOrder         = claimAssessment.clone(false, true);
        currentClaimOrder.ParentAssessment__c   = claimAssessment.Id;
        currentClaimOrder.OrderOrigin__c        = 'Quotation';
        currentClaimOrder.OrderStatus__c        = 'QUOTATION SENT';
        currentClaimOrder.RecordTypeId          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
        //DUN trello no210 24/05/2017 check only for quotation
        currentClaimOrder.customBI1__c     = true;

        if(bodyShopConnected != null && claimAssessment.BodyShop__r.Type == 'Expert')
        {
            currentClaimOrder.BodyShop__c = bodyShopConnected.Id;
        }

        if( claimAssessment.CrossReferences__c != null &&
            claimAssessment.CrossReferences__c != 'NONE')
        {
            // Loop in the parts and populate the cross ref name
            String crossRefNames = '';

            for(PartList__c currentPart : claimAssessment.PartsLists__r)
            {
                if(currentPart.CrossReferenceId__c != null)
                {
                    crossRefNames += currentPart.CrossReferenceId__r.Name + ';';
                }
            }

            currentClaimOrder.CrossReferences__c = (crossRefNames != '') ? crossRefNames.removeEnd(';') : 'NONE';
        }

        // Calling the query to set the suffix of the AssessmentNumber__c and AssessmentID__c
        String assessmentNumberSuffix           = getAssessmentNumberSuffix(claimAssessment);
        currentClaimOrder.AssessmentNumber__c   = claimAssessment.AssessmentNumber__c.left(78) + '-' + assessmentNumberSuffix;
        currentClaimOrder.AssessmentID__c       = claimAssessment.AssessmentID__c.left(78) + '-' + assessmentNumberSuffix;

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license        
        if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains(connectedUserLicenseName)){
             currentClaimOrder.OwnerId = claimAssessment.OwnerId;
        }else{
            currentClaimOrder.OwnerId = connectedUsrId;
        }

        return currentClaimOrder;
    }

    /**
     * Function to clone the parts of the claim assessment to the claim order assessment
     * @param  claimAssessment      The parent assessment from which the parts must be retrieved to be cloned
     * @param  claimOrderAssessment The child assessment to which the parts needs to be attached
     * @return                      List of parts that need to be created for the claimOrderAssessment
     */
    private List<PartList__c> copyPartsToClaimOrder(Assessment__c claimAssessment, Assessment__c claimOrderAssessment)
    {
        List<PartList__c> newPartList = new List<PartList__c>();

        // Loop in the parts of the claim Assessment
        for(PartList__c currentPart : claimAssessment.PartsLists__r)
        {

            PartList__c clonedPart = currentPart.clone(false, true);
            clonedPart.Assessment__c = claimOrderAssessment.Id;
            clonedPart.OriginalPart__c = currentPart.Id;
            clonedPart.TECH_OriginalPart__c = currentPart.TECH_OriginalPart__c + '-' + claimOrderAssessment.Id + '-' + claimOrderAssessment.AssessmentID__c.substringAfterLast('-');

            newPartList.add(clonedPart);

            //WCH 17/04/2019 C-003192   For Quotation direct sourcing is not applied
            //setPartTypes.add(currentPart.Type__c);

            //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
            //if (String.isNotBlank(currentPart.CrossReferenceId__c)
            //    &&  currentPart.CrossReferenceId__r.UseDirectSourcing__c){
            //    setPartTypesDirectSourcing.add(currentPart.Type__c);
            //}
            //if ((String.isBlank(currentPart.CrossReferenceId__c)
            //    || (String.isNotBlank(currentPart.CrossReferenceId__c)
            //        &&  currentPart.CrossReferenceId__r.UseDirectSourcing__c == false))
            //    && currentPart.SelectedByBS__c){
            //    setDist.add(currentPart.TECHDistList__c);
            //}

            if (currentPart.Assessment__r.bodyShop__r.Feature__c != null
                && currentPart.Assessment__r.bodyShop__r.Feature__c.contains('PilotDirectSourcing')){

                if (String.isNotBlank(currentPart.CrossReferenceId__c)
                    &&  currentPart.CrossReferenceId__r.UseClassicSourcing__c){
                    setPartTypesClassicSourcing.add(currentPart.Type__c);
                    setDist.add(currentPart.TECHDistList__c);
                }
                else{
                    setPartTypesDirectSourcing.add(currentPart.Type__c);
                }
            }

        }

        return newPartList;
    }

}