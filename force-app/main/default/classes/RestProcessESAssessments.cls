public with sharing class RestProcessESAssessments {
/*
  ----------------------------------------------------------------------
  -- - Name          : RestProcessESAssessments
  -- - Author        : RLA
  -- - Description   : Class to create claim order and Purchase Order
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 28-09-2018  RLA   1.0     Initial version
  -- 13-04-2019  WCH   1.1     C-003707 - When call CreateAssessment service to generate the POs on the R4 Assessment PDF empty
  ----------------------------------------------------------------------
  **********************************************************************/   

    private static boolean assessmentAlreadyQuoted = false;
    private static boolean canAssessBeCreated = false;

    //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
    private static set<String> setPartTypesDirectSourcing = new set<string>();
    private static set<String> setPartTypesClassicSourcing = new set<string>();
    private static set<String> setDist = new set<String>();
    private static set<String> setPartTypes = new set<string>();
    private static map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();
    private static SavePoint beforeDML;

    private static String COCreated = ''; //WCH 13/04/2020 C-003707



    @future(callout=true) //WCH 13/04/2020 C-003707
    public static void queryClaim (String newAssessmentId, String assExtId, Decimal versionToQuote){

        System.debug('######### start RestProcessESAssessments queryClaim ');
        Assessment__c claimToOrder;
        Assessment__c claimVersionDeltaPartlist;
        String claimVersionDeltaPartlistExtId;
        Decimal mostRecentVersion;
        Assessment__c newAssessment;
        Map<Id, Assessment__c> mapAssUpdateES = new map<Id, Assessment__c>();
        Map<String, map<String, PartList__c>> mapAssPartlist = new map<String, map<String, PartList__c>>();
        string result;
        Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;

        for(Assessment__c a : [select Id,Status__c,  ParentAssessment__c,  Name,  BodyShop__c, Entity__c,AssessmentExtIdCallerSystem__c,
                                AssessmentNumber__c, MREligibility__c,Recordtype.Name,  OrderAuthorised__c,AssessmentVersion__c,
                                SpecialAgreement__c,  SpecialRenting__c,  VINCheck__c,  Fleet__c, TotalLoss__c, LastModifiedDate,  
                                SupposedOfFraud__c,  DateOfIncident__c,  FirstRegistrationDate__c,  EntityCode__c, CreatedDate,
                                ModelV2__c,  MissionNumber__c,  ClaimReference__c,  Manufacturer__c, EntityRules__c, ASReference__c, 
                                PlateNumber2__c,  TECH_EntityCountryCode__c,  VINNumber__c,  AssessmentID__c,  
                                CrossReferences__c, Comment__c,OwnerId, BodyShop__r.OrderFromAT__c,MRSourcing__c,
                                BodyShop__r.Type, BodyShop__r.Feature__c,BodyShop__r.ShippingPostalCodeLeft2__c,BodyShop__r.CarBrandsSuppliedAgency__c,TECHRulesAppliedDescription__c, 
                                (select id from Assessments__r)                                
                                FROM     Assessment__c
                                WHERE    (AssessmentExternalId__c = :assExtId 
                                            AND Recordtype.Name = :ASPISConstants.ASSESS_RT_DeveloperName_Claim)
                                        OR (Id =:  newAssessmentId)
                                ORDER BY AssessmentVersion__c DESC      
                                ])  {

            if (a.Recordtype.Name == ASPISConstants.ASSESS_RT_DeveloperName_Claim){

                if (a.AssessmentVersion__c == versionToQuote){
                    claimToOrder = a;   
                }
                else if (a.Assessments__r.size() > 0){
                    if (mostRecentVersion == null){
                        mostRecentVersion = a.AssessmentVersion__c;
                        claimVersionDeltaPartlist = a;
                    }
                    else if (a.AssessmentVersion__c >  mostRecentVersion){
                        mostRecentVersion = a.AssessmentVersion__c;
                        claimVersionDeltaPartlist = a;
                    }               

                }
            }
            else if (a.Recordtype.Name == ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment)
            {             
                newAssessment = a; 
            }
        }
        claimVersionDeltaPartlistExtId = claimVersionDeltaPartlist != null? claimVersionDeltaPartlist.AssessmentExtIdCallerSystem__c : null;
        System.debug('@@ mostRecentVersion: '+mostRecentVersion);
        System.debug('@@ claimVersionDeltaPartlist: '+claimVersionDeltaPartlist);
        System.debug('@@ claimToOrder: '+claimToOrder);

        try{

            String query = 'select Id, Name, VAT__c, Quantity__c, PartNumber__c, Price__c, Type__c, OriginalPart__c, '+
                            'Original__c, Description__c, ProducerName__c, QuantityOrdered__c, TECH_OrderedCounter__c, '+
                            'SelectedByBS__c, CrossReferenceId__c, IsSourced__c, Assessment__c, TECH_OriginalPart__c, '+
                            'CrossReferenceId__r.Name,Alpha_Scale_MRID__c, DistributorPriceId__c, Distributor__c,Assessment__r.bodyShop__r.Feature__c, '+
                            'TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c, Assessment__r.AssessmentExtIdCallerSystem__c, CrossReferenceId__r.UseClassicSourcing__c, '+
                            'RecordType.DeveloperName,DiscountRecord__c,DiscountRecord__r.Rebate__c, Distributors__c,NextDistributors__c  '+
                            'from PartList__c '+
                            'where SelectedByBS__c = true and isDeleted__c = false  '  +
                            'and (Assessment__c = \'' + claimToOrder.Id + '\'';

            if (claimVersionDeltaPartlist != null){
                query+=' OR Assessment__c =\'' + claimVersionDeltaPartlist.Id + '\' )' ;
            }
            else{
                query+= ')' ;
            }
            //query = claimVersionDeltaPartlist != null ? : query+= ')' ;

            System.debug('@@ query: '+query);

            list<PartList__c> listPartList = Database.query(query);

            for (PartList__c part :listPartList){
                String partExternalId = createPartExternalId(part, part.Assessment__r.AssessmentExtIdCallerSystem__c);
                system.debug('@@ partExternalId: '+ partExternalId);
                
                if (mapAssPartlist.containskey(part.Assessment__r.AssessmentExtIdCallerSystem__c)) {
                    mapAssPartlist.get(part.Assessment__r.AssessmentExtIdCallerSystem__c).put(partExternalId, part);
                }
                else{
                    mapAssPartlist.put(part.Assessment__r.AssessmentExtIdCallerSystem__c, new map <String, partlist__c> {partExternalId => part});    
                }

            }

            if(claimToOrder.BodyShop__r.OrderFromAT__c == true ){
               claimToOrder.OrderAuthorised__c = true;
               mapAssUpdateES.put(claimToOrder.Id, claimToOrder);
            }
            
            if (claimToOrder.BodyShop__r.OrderFromAT__c == false){
                result = createClaimOrderAssessment(claimToOrder,claimVersionDeltaPartlistExtId,mapAssPartlist);
                //WCH 13/04/2020 C-003707
                if(String.isNotBlank(result) && result=='Successful' && String.isNotBlank(COCreated)){
                    Map<Id, PurchaseOrder__c> POCreatedMap = new Map<Id, PurchaseOrder__c>([select Id from PurchaseOrder__c where Assessment__c=:COCreated]);
                    system.debug('POCreated>>'+POCreatedMap);
                    if(POCreatedMap.keySet().size()>0){
                        System.enqueueJob(new AP35R4SendPurchaseOrderEmailQueueable(new Set<Id>(), new Set<Id>(), POCreatedMap.keySet()));
                    }
                }
                //system.debug('@@ result: '+result);
            }  
        }
        catch(exception e){
            system.debug('@@ here 3: '+e.getMessage() + e.getStackTraceString());
            if (beforeDML != null){
                Database.rollback(beforeDML); 
            }

            result = 'error';    
        }
        if (result != null && result != 'Successful'){
            newAssessment.Status__c = 'Ready';
            mapAssUpdateES.put(newAssessment.Id, newAssessment);

        }

        system.debug('@@ result: '+result);
        system.debug('@@ mapAssUpdateES: '+mapAssUpdateES);

        if (mapAssUpdateES.size() > 0){
            List<Database.upsertResult> uResultsES = Database.upsert(mapAssUpdateES.values(), assessExtId, false);    
        }

        System.debug('######### End RestProcessESAssessments queryClaim ');



    }

     //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
    //Method used to create claim Order assessment, Pre-Draft Quote Purchase Order and Pre-Acceptance Sales Order
    public static String createClaimOrderAssessment(Assessment__c assessmentToDisplay, String assExtIdDelta, Map<String, map<String, PartList__c>> mapAssPartlist){
        

        //Assessemnt claim order which is created
        Assessment__c newClaimOrderAssessment = new Assessment__c();
        list<Assessment__Share> assShareExistList;
        list<Account> listDistributors = new list<Account>();
        Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;
        Database.upsertResult uResultsES;

        // Creating a savepoint
        beforeDML = Database.setSavepoint();
        
        try
        {
            if(assessmentToDisplay != null){
                // Locking the parent
                Assessment__c lockParentAssessment = [  SELECT  Id
                                                        FROM    Assessment__c
                                                        WHERE   Id =: assessmentToDisplay.Id FOR UPDATE];

                Assessment__c claimAssessment = assessmentToDisplay;
                // counting on the locking to prevent the same prefix in the claim order assessment
                newClaimOrderAssessment = populateNewClaimOrderAssessment(claimAssessment,mapAssPartlist);
                //mapAssToUpsert.put(newClaimOrderAssessment.AssessmentNumber__c, newClaimOrderAssessment);
                
                // Setting the comment
                //newClaimOrderAssessment.Comment__c = comment; required??
                if (newClaimOrderAssessment != null){
                    uResultsES = Database.upsert(newClaimOrderAssessment, assessExtId, false);
                     system.debug('@@ uResultsES: '+uResultsES);   
                     COCreated=newClaimOrderAssessment.Id; //WCH 13/04/2020 C-003707
                }
                system.debug('@@ assessmentToDisplay: '+assessmentToDisplay);
               
                //system.debug('@@ mapAssToUpsert: '+mapAssToUpsert.get(assessmentToDisplay.Id));

                //insert newClaimOrderAssessment;
                system.debug('@@ newClaimOrderAssessment: '+newClaimOrderAssessment);
                system.debug('@@ newClaimOrderAssessment: '+newClaimOrderAssessment.Id);
                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : Bypassing programatic sharing
                //if((string.isBlank(formattedLicenseName) || 
                //   (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains(connectedUserLicenseName)))){
                //    if(userConnectedGroup != null){
                //        assShareExistList = [SELECT UserOrGroupId, ParentId
                //                                FROM Assessment__Share
                //                                WHERE UserOrGroupId =: userConnectedGroup.Id
                //                                AND ParentId =: claimAssessment.Id];
                //    }

                //    if(userConnectedGroup != null && claimAssessment.BodyShop__r.Type == 'Expert' && assShareExistList.IsEmpty()){
                //        insert new Assessment__Share(   UserOrGroupId   = userConnectedGroup.Id,
                //                                        ParentId        = claimAssessment.Id,
                //                                        AccessLevel     = 'Read');
                //    }
                //}
                System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);

                List<PartList__c> partsToInsertList = copyPartsToClaimOrder(newClaimOrderAssessment, assExtIdDelta,mapAssPartlist);
                System.debug('## partsToInsertList' + partsToInsertList);
                System.debug('## setPartTypesDirectSourcing' + setPartTypesDirectSourcing);
                System.debug('## setPartTypesClassicSourcing' + setPartTypesClassicSourcing);
                String allFirstDistributorsIds = '';
                set<String> setClassicSourcingDist = new set<String>();
                set<String> setDirectSourcingDist = new set<String>();

                //WCH 17/04/2019 C-003192   For Quotation direct sourcing is not applied
                if( (setPartTypes.size() > 0  && newClaimOrderAssessment.BodyShop__r != null && newClaimOrderAssessment.BodyShop__r.Feature__c != null && newClaimOrderAssessment.BodyShop__r.Feature__c.contains('PilotDirectSourcing')
                    && setPartTypes.size() != setPartTypesClassicSourcing.size())
                    )
                {
                    System.debug('## got in direct sourcing' + newClaimOrderAssessment.BodyShop__r.Feature__c);

                    String alldirectOrderIds = '';
                    if (setPartTypesDirectSourcing.size() > 0){
                        setPartTypes = new set<string>();
                        setPartTypes.addAll(setPartTypesDirectSourcing);
                    }
                    System.debug('## setPartTypes' + setPartTypes);
                    
                    
                    String allAgencyDistributorsIds = '';
                    String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 
                    mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(newClaimOrderAssessment.TECH_EntityCountryCode__c,newClaimOrderAssessment.BodyShop__c,newClaimOrderAssessment.Manufacturer__c ,newClaimOrderAssessment.BodyShop__r.ShippingPostalCodeLeft2__c, newClaimOrderAssessment.BodyShop__r.CarBrandsSuppliedAgency__c, setPartTypes);

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
                        newClaimOrderAssessment.Feature__c = newClaimOrderAssessment.BodyShop__r.Feature__c;

                        System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);
                        

                    }
                    else{
                        newClaimOrderAssessment.MRSourcing__c = 'false';
                    }
                }
                //if(!mapPartTypeDistributorsWrap.isEmpty()){
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
                        //}

                if (uResultsES.isSuccess() == true){
                    if(partsToInsertList.size() > 0)
                    {
                        upsert partsToInsertList TECH_OriginalPart__c;

                        // ASPISWithoutSharingExceptions.insertPartLists(partsToInsertList);
                    } 
                    else{
                        System.debug('### no delta partlist');
                        // Rollback to prevent inconsistency of data
                        Database.rollback(beforeDML);  
                        return 'error';
                    }

                    List<Assessment__c> assessmentToUpdateList = new List<Assessment__c>();

                    //DUN 29/01/2018 C-002174 - if MREligibility__c and MRSourcing__c, use list of distributor Id to create PO instead of triggering eligiblity and sourcing
                   if(claimAssessment.MREligibility__c && claimAssessment.MRSourcing__c != null 
                    && (!(!String.isBlank(assessmentToDisplay.bodyShop__r.Feature__c) && /*WCH 17/04/2019 C-003192*/assessmentToDisplay.bodyShop__r.Feature__c.contains('PilotDirectSourcing')))
                        || (String.isNotBlank(assessmentToDisplay.bodyShop__r.Feature__c) && assessmentToDisplay.bodyShop__r.Feature__c.contains('PilotDirectSourcing')
                            && (setPartTypesClassicSourcing.size() > 0 || setDirectSourcingDist.size() > 0))//RLA 29/04/2019 C-003142
                       ){
                        system.debug('ass is status sourced');
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
                        }
                        else{
                            
                            for(String dis : claimAssessment.MRSourcing__c.split(';')){
                                listDistributors.add(new Account(Id=dis));
                            }
                            
                            if(listDistributors.size() > 0){
                                ASPISPurchaseOrder.createOrders(newClaimOrderAssessment,listDistributors,'',null,new set <id>(),new map <id,Account>());
                                
                                //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                                assessmentToUpdateList.add(new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                                                     Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED));
                            }

                        }
                        
                    }  
                    else{
                        system.debug('ass is status ready');
                        // Passing the assessment to Ready to generate the PO and OLs
                        assessmentToUpdateList.add(new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                                                     Status__c  = ASPISConstants.ASSESS_STATUS_READY));
                    
                    } 
                    // ABT - 04-MAY-2017 - C-001660 - Clearing the parent short term deletion
                    assessmentToUpdateList.add(new Assessment__c(Id                         = claimAssessment.Id,
                                                                 ShortTermDeletionDate__c   = null
                                                                 //,LongTermDeletionDate__c    = null  //RLA C-2002 Commented by RLA to remove later
                                                                 //AlreadyQuoted__c = assessmentAlreadyQuoted
                                                                 ));

                    update assessmentToUpdateList ;

                    
                    System.debug('@@ assessmentToUpdateList' + assessmentToUpdateList);

                    String assId = encryptBase64(newClaimOrderAssessment.Id);

                    return 'Successful';
                }
                else{
                    // Rollback to prevent inconsistency of data
                    Database.rollback(beforeDML);  
                    System.debug('@@ catch here' );

                    return 'error'; 
                }
            }
        }
        catch (DMLException e)
        {
            System.debug('@@ catch here 2' );
            
            Database.rollback(beforeDML);
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                return e.getDmlMessage(0);
            }
            else
            {
                return (e.getMessage() + ' : ' + e.getStackTraceString());
            }

            // Rollback to prevent inconsistency of data
            
        }

        return null;
    }

     /**
     * Function to clone the claim assessment and build the claim order assessment
     * @param  claimAssessment The claim assessment to clone
     * @return                 Claim Order Assessment with the claim assessment as its parent
     */
    public static Assessment__c populateNewClaimOrderAssessment(Assessment__c claimAssessment,Map<String, map<String, PartList__c>> mapAssPartlist)
    {
        System.debug('@@ claimAssessment' + claimAssessment);

        // Cloning the parent assessement
        Assessment__c currentClaimOrder         = claimAssessment.clone(false, true);
        currentClaimOrder.ParentAssessment__c   = claimAssessment.Id;
        currentClaimOrder.OrderOrigin__c        = 'Quotation';
        currentClaimOrder.OrderStatus__c        = 'QUOTATION SENT';
        currentClaimOrder.RecordTypeId          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
        //DUN trello no210 24/05/2017 check only for quotation
        currentClaimOrder.customBI1__c     = true;
        

        if( claimAssessment.CrossReferences__c != null &&
            claimAssessment.CrossReferences__c != 'NONE')
        {
            // Loop in the parts and populate the cross ref name
            String crossRefNames = '';
            String assToOrderExtdId = claimAssessment.AssessmentExtIdCallerSystem__c;

            Map<String, PartList__c> mapPartlistToOrder = mapAssPartlist.containsKey(assToOrderExtdId) ? mapAssPartlist.get(assToOrderExtdId) : null;

            for(String key : mapPartlistToOrder.keySet())
            {
                PartList__c currentPart = mapPartlistToOrder.get(key);
                System.debug('@@ currentPart.CrossReferenceId__c'+currentPart.CrossReferenceId__c);
                System.debug('@@ currentPart'+currentPart);
                if(currentPart.CrossReferenceId__c != null)
                {
                    crossRefNames += currentPart.CrossReferenceId__r.Name + ';';
                }
            }
            System.debug('@@ crossRefNames'+crossRefNames);


            currentClaimOrder.CrossReferences__c = (crossRefNames != '') ? crossRefNames.removeEnd(';') : 'NONE';
        }

        // Calling the query to set the suffix of the AssessmentNumber__c and AssessmentID__c
        String assessmentNumberSuffix           = getAssessmentNumberSuffix(claimAssessment);
        currentClaimOrder.AssessmentNumber__c   = claimAssessment.AssessmentNumber__c.left(78) + '-' + assessmentNumberSuffix;
        currentClaimOrder.AssessmentID__c       = claimAssessment.AssessmentID__c.left(78) + '-' + assessmentNumberSuffix;

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license      
        string formattedLicenseName = '';
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
        string connectedUserLicenseName = '';
        string connectedUsrId = UserInfo.getUserId();
        connectedUserLicenseName = UserInfo.getUserType().toLowerCase();
        if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains(connectedUserLicenseName)){
             currentClaimOrder.OwnerId = claimAssessment.OwnerId;
        }else{
            currentClaimOrder.OwnerId = connectedUsrId;
        }
        System.debug('@@ currentClaimOrder' + currentClaimOrder);

        return currentClaimOrder;
    }


    private static List<PartList__c> copyPartsToClaimOrder(Assessment__c assessmentToDisplay, String assExtIdDelta, Map<String, map<String, PartList__c>> mapAssPartlist )
    {
        List<PartList__c> newPartList = new List<PartList__c>();
        String assToOrderExtdId = assessmentToDisplay.AssessmentExtIdCallerSystem__c;
        Map<String, PartList__c> mapPartlistToOrder = mapAssPartlist.containsKey(assToOrderExtdId) ? mapAssPartlist.get(assToOrderExtdId) : null;
        Map<String, PartList__c> mapPartlistDelta = mapAssPartlist.containsKey(assExtIdDelta) ? mapAssPartlist.get(assExtIdDelta) :  null;
        System.debug('@@ assToOrderExtdId' + assToOrderExtdId);
        System.debug('@@ mapPartlistToOrder' + mapPartlistToOrder);
        System.debug('@@ mapPartlistDelta' + mapPartlistDelta);
    
        if (mapPartlistToOrder != null){
            // Loop in the parts of the claim Assessment
        
            for(String extId : mapPartlistToOrder.keySet())
            {   
                PartList__c currentPart = mapPartlistToOrder.get(extId);
                String partExternalIdToQuote = createPartExternalId(currentPart, assToOrderExtdId);
                String partExternalIdDelta = createPartExternalId(currentPart, assExtIdDelta);
                Decimal quantity = 0;
                System.debug('@@ partExternalIdToQuote:' + partExternalIdToQuote);
                System.debug('@@ partExternalIdDelta:' + partExternalIdDelta);

                if (mapPartlistDelta != null
                    && mapPartlistDelta.containsKey(partExternalIdDelta)){
                    quantity = currentPart.Quantity__c -mapPartlistDelta.get(partExternalIdDelta).Quantity__c ;   
                    System.debug('@@ quantity' + quantity);             
                }else{
                    quantity = currentPart.Quantity__c;
                    System.debug('@@ quantity' + quantity);
                } 
                System.debug('@@ quantity' + quantity); 
                if (quantity > 0){
                    System.debug('@@ got in' + quantity);

                    PartList__c clonedPart = currentPart.clone(false, true);
                    clonedPart.Assessment__c = assessmentToDisplay.Id;
                    clonedPart.OriginalPart__c = currentPart.Id;
                    clonedPart.Quantity__c = quantity ;
                    clonedPart.TECH_OriginalPart__c = currentPart.TECH_OriginalPart__c + '-' + assessmentToDisplay.Id + '-' + assessmentToDisplay.AssessmentID__c.substringAfterLast('-');                     
                    System.debug('@@ clonedPart' + clonedPart);
                    System.debug('@@ currentPart.Type__c' + currentPart.Type__c);

                    newPartList.add(clonedPart);
                    setPartTypes.add(currentPart.Type__c);
                    //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
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
            }
        }

        System.debug('@@ newPartList' + newPartList);
        return newPartList;
    }

    public static String getAssessmentNumberSuffix(Assessment__c claimAssessment)
    {
        
        
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

    public static String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    public static string createPartExternalId (PartList__c part, string assessmentEXternalId ){

        string externalId;

        externalId = assessmentEXternalId + '-'
                   + part.partNumber__c.replaceAll('\\s+', '') + '-'
                   + part.Description__c.replaceAll('\\s+', '') ;

        return externalId;
    }



}