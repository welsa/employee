/*************************************************************************************
Class Name - AssessmentTriggerHandler
Version - 1.0
Created Date - 27 MAR 2015
Function - Class to Manage Assessment Status Changes on Assessment LifeCycle

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Joao Dias     27/10/2015  Original Version
* Shamina M     17/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S     23/03/2016  C-001435: Changing the Bodyshop on the assessment
* Ashwina S     13/04/2016  C-001546: Chiffrages et vÃ©hicules VEI
* Dourga U      30/06/2016  C-001652: Remove ServiceBroker + Bulkify ASPISService...
* Dourga U      23/08/2016  Rules Engine 2.0
* Ashwina S     05/04/2016  Moving PostAssessment logic in REstUpsert
* Dourga U      19/05/2017  Added update of assessment reason failure when all PO related are canceled by distributor(trello no35)
* Abdool M      16/08/2017  New Eligibility/Sourcing
* Dourga U      16/10/2017  case 1994 
* Abdool M      27/10/2017  C-002041 - Distributor V2 - updating method param for ASPISServiceSourcing
* Ashwina       06/12/2017  C-002061 - France compensation with IG - Notify exponens on any changes of payment type
* Ashwina S     01/03/2018  C-002311 - Substitution expert - lien expert
* Dourga        04/05/2018  C-002488 : Added OrderOrigin = ASPIS in condition
* Ruksaar       30/05/2018  C-002002 : Data Purge Long
* Dourga        08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
* Vaynee        21/06/2018  C-002294 : Confirmation of order (email ordering process)
* Ruksaar L     07/08/2018  C-002294 : Confirmation of order (email ordering process) V2
* Welsa C       21/08/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors(point 1 et 3)
* Ashwina S     13/11/18    C-002903 : Substitution Chiffrage Expert - add claim ref '56'
* Welsa C       19/11/2018  C-002917 : Claim Assessment status changes to checked when clearing assessment
* Welsa C       11/01/2019  C-002991 : Developer script exception from Alpha Scale : 'AP21AssessmentSharing' for job id '7071i00000CWGnW' : Delete failed.
* Ruksaar L     17/06/2020  C-003699 : IG - SLAs and Emails
* Welsa C       20/08/2020  C-003578 - Expert Assessment KO when claim reference does not meet required conditions
* Welsa C       22/10/2020  C-004015 - NOB - Assessment Sales Order Invoice Visibility Management
* Welsa C       09/11/2020  C-003980 - NOB - Compensated Invoices
* Welsa C       09/11/2020  C-004311 - NOB -New Compensated process should not be activated for Claims in old compensation process
* Neha P        15/12/2021  C-004540 - Delete records of R3 Assessments and Part Lists created for BS's in Direct Ordering Process
* Neha P        15/03/2022  C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
*************************************************************************************/
public without sharing class AssessmentTriggerHandler {

    private boolean bIsExecuting = false;
    private integer iBatchSize = 0;
    public static boolean bFirstRun = true;
    
    public AssessmentTriggerHandler(boolean isExecuting, integer size){
        bIsExecuting = isExecuting;
        iBatchSize = size;
    }

    public void OnBeforeInsert(List<Assessment__c> newAssessmentList)
    {
        System.debug('## AssessmentTriggerHandler - OnBeforeInsert START');

        Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
        Id claimId      = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        Id crashId      = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId();
        //DUN 16/10/2017 case 1994 
        map <String,Assessment__c> mapClaimpPlateAssessmentClaim = new map <String,Assessment__c>();
        set<String> setClaim = new set<String>();
        set<String> setPlate = new set<String>();
        set<Id> BSIdSet = new set<Id>();
        map <Assessment__c,Id> mapAssBSId = new map <Assessment__c,Id> ();
        //list <Assessment__c> listAssToSetUser = new list<Assessment__c>();
        //set <Id> setBodyshop = new set <Id> ();
        Map<string,object> mapInputParams = new Map<string,object>(); //WCH 17/08/2020 C-003578
        Map<string,object> mapOutputParams = new Map<string,object>();//WCH 17/08/2020 C-003578
        Map<string,Assessment__c> mapClaimNumberAssessmentClaim = new Map<string,Assessment__c>();//WCH 09/11/2020 C-003980
        Map<String,CountryCodeInformationsMapping__c> countryCodeMapping = CountryCodeInformationsMapping__c.getall();//WCH 09/11/2020 C-003980
        set<Id> setBodyshopsForClaimAss = new set<Id>();//WCH 09/11/2020 C-003980

        // RLA 30/05/2018 C-2002 Data purge LONG 
        List<Assessment__c> lstAssessmentLtd = new List<Assessment__c>();

        // Check if the order origin of the assessment is Order and the RecordTypeId = Claim Order
        for(Assessment__c currentAssessment : newAssessmentList)
        {
            //VSU C-002294 20/06/18
            //if(currentAssessment.BodyShop__c != null){
            //    system.debug('££currentAssessment.BodyShop__c '+currentAssessment.BodyShop__c);
            //    listAssToSetUser.add(currentAssessment);
            //    setBodyshop.add(currentAssessment.BodyShop__c);
            //}

            // setting the short term deletion date for shopping list
            if( (currentAssessment.RecordTypeId == claimId || currentAssessment.RecordTypeId == crashId) &&
                currentAssessment.isShoppingList__c)
            {
                AP36AssessmentPurge.setShoppingListDeletionDate(currentAssessment);
            }

            //NPE 09/03/2022 C-004633: Uncheck the checkbox "R3AssessmentToBeDeleted__c" as soon as the R3 Assessment is deleted
            if ( currentAssessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() && currentAssessment.R3_Assessment__c != null && currentAssessment.isFromR3__c == true){
                currentAssessment.R3AssessmentToBeDeleted__c = true;   
            }

            // Setting the short term deletion date for claim orders
            if(currentAssessment.RecordTypeId == claimOrderId &&
                currentAssessment.OrderOrigin__c == 'Order')
            {
                AP36AssessmentPurge.setClaimOrderDeletionDate(currentAssessment);
            }
            //WCH 17/08/2020 C-003578
            mapInputParams.put('ExpertAssessment',currentAssessment);
            mapOutputParams = RestDistributorUtility.isExpertAssessmentCorrect(mapInputParams);
            if(mapOutputParams.containsKey('isExpertAssessmentCorrect') && (boolean)mapOutputParams.get('isExpertAssessmentCorrect')){
                system.debug(currentAssessment.PlateNumber2__c);
                system.debug(currentAssessment.BodyShop__c);
                system.debug('expert ass OK');
                mapClaimpPlateAssessmentClaim.put(currentAssessment.PlateNumber2__c, currentAssessment);
                // ASE: 01/03/2018 - C-002311
                //setClaim.add(currentAssessment.ClaimReference__c);
                //setPlate.add(currentAssessment.PlateNumber2__c);
                BSIdSet.add(currentAssessment.BodyShop__c);
            }
             // RLA 30/05/2018 C-2002 Data purge LONG
            if (currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() 
                //&& (Userinfo.getProfileId() == System.label.InterfaceProfileID
                    //|| Userinfo.getProfileId() == System.label.AdminProfileID//Please note that this Or condition must be removed when deploying to prod only
                   // ))
                || currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()
                || currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()                 
                )
            {
                lstAssessmentLtd.add(currentAssessment);
            }
            //WCH 22/10/2020 C-004015
            if(currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId() && String.isNotBlank(currentAssessment.TECH_EntityCountryCode__c) && currentAssessment.TECH_EntityCountryCode__c == 'FR' && String.isNotBlank(currentAssessment.EntityCode__c) && (system.label.ASFRPrefikarEntity.contains(currentAssessment.EntityCode__c) || currentAssessment.isShoppingList__c)){
                currentAssessment.VisibleByPrefikar__c = true;
            }

            //WCH 09/11/2020 C-003980,08/04/2021 C-004311
            if((currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() || (currentAssessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId() && currentAssessment.ParentAssessment__c!=null && currentAssessment.ParentAssessment__r.NewCompensatedProcess__c)) && String.isNotBlank(currentAssessment.ClaimReference__c) && String.isNotBlank(currentAssessment.TECH_EntityCountryCode__c) && countryCodeMapping.containsKey(currentAssessment.TECH_EntityCountryCode__c) && countryCodeMapping.get(currentAssessment.TECH_EntityCountryCode__c).New_Compensation_Activate__c && currentAssessment.BodyShop__c!=null && String.isNotBlank(currentAssessment.EntityCode__c) && system.label.ASFRPrefikarEntity.contains(currentAssessment.EntityCode__c) && !currentAssessment.isShoppingList__c){
                system.debug('new compensation process');
                currentAssessment.NewCompensatedProcess__c = true;
                mapClaimNumberAssessmentClaim.put(currentAssessment.ClaimReference__c,currentAssessment);
                setBodyshopsForClaimAss.add(currentAssessment.BodyShop__c);
            }

            system.debug('## mapClaimpPlateAssessmentClaim:'+mapClaimpPlateAssessmentClaim);
            system.debug('## mapClaimpPlateAssessmentClaim:'+mapClaimpPlateAssessmentClaim.size());
        }

        //VSU C-002294 20/06/18
        //if(listAssToSetUser.size() > 0 && setBodyshop.size() > 0){
        //    AP44PopulateContactOnAssessment.populateContact(listAssToSetUser,setBodyshop);
        //}

        if(mapClaimpPlateAssessmentClaim.size() > 0){
            // ASE: 01/03/2018 - C-002311
            //AP43LinkBSExpert.linkBSExpert(mapClaimpPlateAssessmentClaim,setClaim,setPlate,BSIdSet);
            AP43LinkBSExpert.linkBSExpert(mapClaimpPlateAssessmentClaim, BSIdSet);
        }

         system.debug('## lstAssessmentLtd:'+lstAssessmentLtd);
        // RLA 30/05/2018 C-2002 Data purge LONG 
        if(lstAssessmentLtd.size() > 0)
        {
            AP36AssessmentPurge.checkAsmntStatus(lstAssessmentLtd);
        }

        //WCH 09/11/2020 C-003980
        if(mapClaimNumberAssessmentClaim.size()>0){
            setIsCompensated(mapClaimNumberAssessmentClaim,setBodyshopsForClaimAss);
        }
        System.debug('## AssessmentTriggerHandler - OnBeforeInsert END');
    }

    public void OnAfterInsert(Assessment__c[] newAssessments){
        System.debug('## here'+newAssessments);
        
        //ap21
        List<Assessment__c> l_Assessment = new List<Assessment__c>();
        Set<Id> s_BodyShop = new Set<Id>();
        // ase: 2016/03/23: map containing assessmentIds and it's bodyshop
        Set<Id> s_OldbodyShop= new Set<Id>();

        // ASE:13/04/2016: C-001546
        List<Case__c> caseList = new List<Case__c>();

        // ABT - 22-FEB-2017 - Adding EncodedId
        List<Assessment__c> assessmentListToUpdate = new List<Assessment__c>();

        for(Assessment__c assessment: newAssessments){
            System.debug('## here'+ assessment.Status__c);
            System.debug('## here'+ assessment.TECH_EntityCountryCode__c);
            System.debug('## here'+ assessment.RecordTypeId);
            
            // building set and list for ap21
            if (assessment.BodyShop__c != null){
                l_Assessment.add(assessment);
                s_BodyShop.add(assessment.BodyShop__c);
                //s_OldbodyShop.add(AssessmentMap.get(assessment.id).BodyShop__c);
            }

           /* // ASE:13/04/2016: C-001546
            if(assessment.TotalLoss__c == true){
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-ASS', assessment.TECH_EntityCountryCode__c, assessment.BodyShop__c, assessment.Id, null, null, '',  UserInfo.getUserId(), '-TotalLoss');
                if(newCase!=null){
                    caseList.add(newCase);
                }
            }*/
           
            // ABT - 22-FEB-2017 - Adding EncodedId
            assessmentListToUpdate.add(new Assessment__c(Id = assessment.Id,
                                                         EncodedId__c = encryptBase64(assessment.Id)));
        }

        //System.debug('/// l_Assessment: ' + l_Assessment.size());
        if (l_Assessment.size() > 0){
            // ase: 2016/03/23:
            AP21AssessmentSharing.createSharingAssessment(l_Assessment,s_BodyShop,s_OldbodyShop);
        }

        /*// ASE:13/04/2016: C-001546
        // insert case list
        if(caseList.size()>0){
            insert caseList;
        }*/

        // ABT - 22-FEB-2017 - Adding EncodedId
        if(assessmentListToUpdate.size() > 0)
        {
            update assessmentListToUpdate;
        }

    }

    public void OnBeforeUpdate(Assessment__c[] oldAssessment, Assessment__c[] updatedAssessment, Map<ID, Assessment__c> AssessmentMap){

        //System.debug(updatedAssessment);
        //DUN 30/06/2016  C-001652 commented the line below
        //List<Assessment__c> updatedStatusAssessment = new List<Assessment__c>();
        set<Id> assessmentIdSet=  new set<Id>();
        set<Id> updatedBSAssessmentSet =  new set<Id>();
        map<Id, Assessment__c> updatedBSAssessmentMap = new map<Id, Assessment__c>();

        //DUN 19/05/2017 trello no35
        list<Assessment__c> listCanceledAssessment = new list<Assessment__c>();

        // ASE:13/04/2016: C-001546
        List<Case__c> caseList = new List<Case__c>();

        //DUN 23/08/2016 RulesEngine 2.0
        //map of entity and map of assessment for eligibilty process
        map<String,map<Id,Assessment__c>> mapEntityMapIdAssessmentEligibilty = new map<String,map<Id,Assessment__c>>();
        //map of entity and map of assessment for sourcing process
        map<String,map<Id,Assessment__c>> mapEntityMapIdAssessmentSourcing = new map<String,map<Id,Assessment__c>>();

         // RLA 30/05/2018 C-2002 Data purge LONG 
        List<Assessment__c> lstAssessmentLtd = new List<Assessment__c>();
        //VSU C-002294
        //list <Assessment__c> listAssToSetUser = new list<Assessment__c>();
        //set <Id> setBodyshop = new set <Id> ();

        for(Assessment__c assessment: updatedAssessment){

            // JSA : update LastUpdateDate__c with last updated date of the Assessment
            system.debug('JSA ' + Userinfo.getProfileId() + 'JSA2 '  + System.label.InterfaceProfileID);
            if ( assessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() && Userinfo.getProfileId() == System.label.InterfaceProfileID ){
                assessment.LastUpdateDate__c = Datetime.now(); 
            }
            //System.debug(AssessmentMap.get(assessment.id).Status__c);
            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c && assessment.Status__c != 'NEW' &&
                assessment.Status__c != ASPISConstants.ASSESS_STATUS_CLOSEDKO &&
                AssessmentMap.get(assessment.id).Status__c != ASPISConstants.ASSESS_STATUS_CLOSEDOK &&
                AssessmentMap.get(assessment.id).Status__c != ASPISConstants.ASSESS_STATUS_CLOSEDKO &&
                AssessmentMap.get(assessment.id).Status__c != ASPISConstants.ASSESS_STATUS_CANCELED &&
                AssessmentMap.get(assessment.id).Status__c != ASPISConstants.ASSESS_STATUS_REJECTED){
                //DUN 30/06/2016  C-001652 commented the line below
                //updatedStatusAssessment.add(assessment);
                assessment.PreviousStatus__c = AssessmentMap.get(assessment.id).Status__c;
            }

            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c && assessment.Status__c != 'NEW' &&
                (assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDKO ||
                assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDOK ||
                assessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED ||
                assessment.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED)){
                //DUN 30/06/2016  C-001652 commented the line below
                //updatedStatusAssessment.add(assessment);
                assessment.OrderStatus__c = assessment.Status__c;
            }

            // //NPE 15/12/2021 C-004540 
            // if ( assessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() && assessment.R3_Assessment__c != null && assessment.isFromR3__c == true){
            //     assessment.R3AssessmentToBeDeleted__c = true;   
            // }

            if(assessment.BodyShop__c != AssessmentMap.get(assessment.id).BodyShop__c && assessment.BodyShop__c != null){
                assessmentIdSet.add(AssessmentMap.get(assessment.id).Id);
                //listAssToSetUser.add(assessment);//VSU C-002294 20/06/18
                //setBodyshop.add(assessment.BodyShop__c);

            }

            // ASE:13/04/2016: C-001546
            if(assessment.TotalLoss__c == true && (assessment.Status__c != AssessmentMap.get(assessment.id).Status__c && assessment.Status__c== 'READY')){

                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-ASS', assessment.TECH_EntityCountryCode__c, assessment.BodyShop__c, assessment.Id, null, null, '',  UserInfo.getUserId(), '-TotalLoss');
                if(newCase!=null){
                    caseList.add(newCase);
                }
            }

            //DUN 30/06/2016  C-001652 calling class ASPISServiceEligibility when status = 'READY'
            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c && assessment.Status__c == 'READY'){
                //DUN 23/08/2016 RulesEngine 2.0
                if(System.label.RulesEngineVersion == '2'){
                    if(mapEntityMapIdAssessmentEligibilty.containsKey(assessment.EntityRules__c)){
                        mapEntityMapIdAssessmentEligibilty.get(assessment.EntityRules__c).put(assessment.Id,assessment);
                    }
                    else{
                        mapEntityMapIdAssessmentEligibilty.put(assessment.EntityRules__c,new map<Id,Assessment__c>{assessment.Id => assessment});
                    }
                }
                else{
                    //AMI 16/08/17 - New Eligibility
                    ASPISServiceEligibility.processObjForEligibility(assessment,true);
                }
            }

            //DUN 30/06/2016  C-001652 calling class ASPISServiceSourcing when status = 'CHECKED'
            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c && assessment.Status__c == 'CHECKED'){
                //DUN 23/08/2016 RulesEngine 2.0
                system.debug('## assessment.MRSourcing__c ' + assessment.MRSourcing__c);
                system.debug('## assessment.RecordTypeId ' + assessment.RecordTypeId);
                if(System.label.RulesEngineVersion == '2'){
                    if(mapEntityMapIdAssessmentSourcing.containsKey(assessment.EntityRules__c)){
                        mapEntityMapIdAssessmentSourcing.get(assessment.EntityRules__c).put(assessment.Id,assessment);
                    }
                    else{
                        mapEntityMapIdAssessmentSourcing.put(assessment.EntityRules__c,new map<Id,Assessment__c>{assessment.Id => assessment});
                    }
                }
                //DUN 08/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                else if(assessment.MRSourcing__c != null && assessment.RecordTypeId != Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()){
                    if(assessment.MRSourcing__c != 'false'){
                        list <Account> distributors = new list <Account>();
                        set <Id> agencydistributorsId = new set <Id>();
                        for(String disId : assessment.MRSourcing__c.split(';')){
                            System.debug('@@ disId'+disId);
                            //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                            if (String.isNotBlank(disId)){
                                distributors.add(new Account(Id = disId));
                            }
                        }
                        if(assessment.AgencyDistributors__c != null && assessment.AgencyDistributors__c != ''){
                            for(String adisId : assessment.AgencyDistributors__c.split(';')){
                                agencydistributorsId.add(adisId);
                            }
                        }
                        Set<Id> directOrdersSet = new Set<Id>();
                        if(!String.isBlank(assessment.Tech_DirectOrders__c))
                            for(String dOId : assessment.Tech_DirectOrders__c.split(';')){
                                directOrdersSet.add(dOId);
                            }
                        ASPISDirectSourcing.createPurchaseOrders(assessment, distributors, null, null, null, null,'P0', agencydistributorsId,directOrdersSet);
                        assessment.TECHRulesAppliedDescription__c += ' \n Results: Number of Purchase orders: ' + distributors.size();
                        assessment.Status__c = system.Label.ASSESSMENTSTATUSSOURCEDLABEL;
                    }
                    else{
                        assessment.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                        assessment.TECHRulesAppliedDescription__c += ' \n No direct orders found';
                        assessment.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                    }
                }
                else if(assessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() && 
                        assessment.Feature__c !=null && 
                        assessment.Feature__c.contains('PilotDirectSourcing')){
                        //WCH 19/11/2018 : C-002917 - Claim Assessment status changes to checked when clearing assessment
                        if(assessment.MRSourcing__c == 'false'){
                            assessment.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                            assessment.TECHRulesAppliedDescription__c += ' \n No direct orders found';
                            assessment.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                        }else{
                            assessment.Status__c = ASPISConstants.ASSESS_STATUS_NEW;
                            if(!String.isBlank(assessment.MRSourcing__c)){
                                assessment.TECHRulesAppliedDescription__c += ' \n Results: Number of Purchase orders: ' + (assessment.MRSourcing__c).removeEnd(';').split(';').size();
                            }
                            
                        }
                }
                else{
                    //AMI 27/10/17 - C-002041 - Distributor V2 - updating method param for ASPISServiceSourcing
                    //AMI 16/08/17 - New Sourcing
                    if(assessment.Feature__c == null || (assessment.Feature__c !=null && !assessment.Feature__c.contains('PilotDirectSourcing'))){
                        ASPISServiceSourcing.processObjForSourcing(assessment,true,null,null);
                    }
                }
            }

            //KEM 07/11/2022 C-004540: check the checkbox "R3AssessmentToBeDeleted__c" R3 Assessment to be deleted
            if ( assessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId() && assessment.Status__c == 'rejected' && assessment.TECH_EntityCountryCode__c == 'FR'){
                assessment.R3AssessmentToBeDeleted__c = true;
                System.debug('## shane assessment' + assessment);
            }

            //DUN 30/06/2016  C-001652 calling class ASPISServiceOffering when status = 'OFFERING'
            // DUN 04/05/2018 case 2488 : Added OrderOrigin = ASPIS in condition
            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c
               && assessment.Status__c == 'OFFERING'
               && assessment.OrderOrigin__c != 'Order'
               && assessment.OrderOrigin__c != 'ASPIS'){
                ASPISOfferGeneration offeringProcess = new ASPISOfferGeneration();
                offeringProcess.executeProcess(assessment);
            }

            //DUN 19/05/2017 trello no35
            if(assessment.Status__c != AssessmentMap.get(assessment.id).Status__c
               && assessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED
               && assessment.OrderOrigin__c == 'Order'
               && assessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()){
                listCanceledAssessment.add(assessment);
            }

            // RLA 30/05/2018 C-2002 Data purge LONG 
            if  ((assessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()                
                && Userinfo.getProfileId() == System.label.InterfaceProfileID
                    //|| Userinfo.getProfileId() == System.label.AdminProfileID// to be removed when deploying to prod 
                 )
                && !system.isBatch()             
                )
            {
                lstAssessmentLtd.add(assessment);
            }

            // ABT 07-JUN-2017 - C-001660
            // Populating the short term deletion of the assessment being updated only. Not setting the long term deletion date on their parent
           //RLA C-2002 Commented by RLA to remove later
            //if(assessment.Status__c != assessmentMap.get(assessment.Id).Status__c)
            //{
            //  if(assessment.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED)
            //  {
            //      // Assessment is rejected and is not eligible
            //      AP36AssessmentPurge.setNonEligibleAssessmentDeletionDate(assessment);
            //  }
              //RLA C-2002 Commented by RLA to remove later
            //if( (assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSED ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDOK ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDKO)
            //      && assessment.RecordTypeId != Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()
            //      && !System.isBatch() //RLA Added case-2002 //Added by RLA
            //      )
            //  {
            //      // Assessment was an eligible assessment and is being closed
            //     // AP36AssessmentPurge.setEligibleAssessmentDeletionDate(assessment);
            //     //RLA Moved to Batch AspisBatchSetAsmntStatus
            //  }
              //RLA C-2002 Commented by RLA to remove later
              //if(assessment.LongTermDeletionDate__c != null && 
              //    assessment.TECH_EntityCountryCode__c !='ES' &&
              //    assessment.Status__c != ASPISConstants.ASSESS_STATUS_INVOICED &&
              //    //RLA Added tech ES condition
              //    !(assessment.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED || 
              //    assessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED ||
              //    assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSED ||
              //    assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDOK ||
              //    assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDKO))
              //{
              //    assessment.LongTermDeletionDate__c = null;
              //}
            

            
        }

        //VSU C-002294 20/06/18
        //if(listAssToSetUser.size() > 0 && setBodyshop.size() > 0){
        //    AP44PopulateContactOnAssessment.populateContact(listAssToSetUser,setBodyshop);
        //}

        for(PrerequisiteOrder__c SO: [Select Status__c, Assessment__c from PrerequisiteOrder__c where Assessment__c in: assessmentIdSet]){
            //DUN 22/11/2017 added responded case 2071
            if(!(SO.Status__c == 'INACCEPTANCE'|| SO.Status__c == 'INDELIVERY' ||  SO.Status__c == 'RESPONDED')){
                //updatedBSAssessmentMap.get(SO.Assessment__c).addError(System.label.ErrorChangingBS);
                updatedBSAssessmentSet.add(SO.Assessment__c);
            }
        }
        system.debug('## updatedBSAssessmentSet' + updatedBSAssessmentSet);

        //DUN 30/06/2016  C-001652 commented the line below
        //AssessmentBroker(updatedStatusAssessment);
        //checkChangeValidity(updatedBSAssessmentMap);

        for(Assessment__c assessment: updatedAssessment){
            if(updatedBSAssessmentSet.contains(assessment.id)){
                 assessment.addError(System.label.ErrorChangingBS);
            }
        }

        // ASE:13/04/2016: C-001546
        if(caseList.size()>0){
            insert caseList;
        }

        //DUN 23/08/2016 RulesEngine 2.0
        /*if(mapEntityMapIdAssessmentEligibilty.size() > 0){
           RulesEngine_Eligibility rulesEngineEligibility = new RulesEngine_Eligibility();
           rulesEngineEligibility.executeEligibility(mapEntityMapIdAssessmentEligibilty);
        }

        //DUN 23/08/2016 RulesEngine 2.0
        if(mapEntityMapIdAssessmentSourcing.size() > 0){
           RulesEngine_Sourcing rulesEngineSourcing = new RulesEngine_Sourcing();
           rulesEngineSourcing.executeSourcing(mapEntityMapIdAssessmentSourcing);
        }
        */
        //DUN 19/05/2017 trello no35
        if(listCanceledAssessment.size()> 0){
            AP18SetAssessmentStatus.updateAssessmentReasonFailure(listCanceledAssessment);
        }

        // RLA 30/05/2018 C-2002 Data purge LONG 
        if(lstAssessmentLtd.size() > 0)
        {
            AP36AssessmentPurge.checkAsmntStatus(lstAssessmentLtd);
        }   
    }

    public void OnAfterUpdate(Assessment__c[] oldAssessment, Assessment__c[] updatedAssessment, Map<ID, Assessment__c> AssessmentMap){
        //ap21
        List<Assessment__c> l_assessment = new List<Assessment__c>();
        Set<Id> s_bodyShop = new Set<Id>();
        Set<Id> s_OldbodyShop= new Set<Id>();
        //ap18 DUN 19/05/2017  send email when assessment is canceled by distributor(trello no35)
        Set<Id> setAssessmentIdToSendEmail = new Set<Id>();
        //C-002061
        Set<Id> setCompensatedAssess = new Set<Id>();

        Id claimId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        // STDD -> Short Term Deletion Date
        Set<Id> claimShoppingListWithSTDDCleared = new Set<Id>();
        // LTDD -> Long Term Deletion Date
        //Set<Id> parentAssessmentToSetLTDD = new Set<Id>();
        //Set<Id> parentAssessmentToClearLTDD = new Set<Id>();

        //RLA C-002294 07/08/2018
        list <Assessment__c> listAssToSetUser = new list<Assessment__c>();
        set <Id> setBodyshop = new set <Id> ();

        for(Assessment__c assessment: updatedAssessment){

            //System.debug(assessment.BodyShop__c);
            //System.debug(AssessmentMap.get(assessment.id).BodyShop__c);
            if(assessment.BodyShop__c != AssessmentMap.get(assessment.id).BodyShop__c && assessment.BodyShop__c != null){
                l_assessment.add(assessment);
                s_bodyShop.add(assessment.BodyShop__c);
                s_OldbodyShop.add(AssessmentMap.get(assessment.id).BodyShop__c);
            }

            // ABT - 04-MAY-2017 - C-001660
            // Checking if the claim shopping list assessment is having its Short Term Deletion Date being cleared
            if( assessment.RecordTypeId == claimId &&
                assessment.isShoppingList__c  &&
                assessment.ShortTermDeletionDate__c != AssessmentMap.get(assessment.Id).ShortTermDeletionDate__c &&
                assessment.ShortTermDeletionDate__c == null)
            {
                // Therefore the crash of the shopping list assessment needs to be cleared
                claimShoppingListWithSTDDCleared.add(assessment.Id);
            }

            //if(   assessment.Status__c != assessmentMap.get(assessment.Id).Status__c &&
            //  assessment.ParentAssessment__c != null)
            //{
            //  if( assessment.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSED ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDOK ||
            //      assessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDKO)
            //  {
            //      parentAssessmentToSetLTDD.add(assessment.ParentAssessment__c);
            //  }
            //  // Therefore it is not being canceled/closed so it is being opened
            //  else if(assessment.LongTermDeletionDate__c != assessmentMap.get(assessment.Id).LongTermDeletionDate__c &&
            //          assessment.LongTermDeletionDate__c == null)
            //  {
            //      parentAssessmentToClearLTDD.add(assessment.ParentAssessment__c);
            //  }
            //}

            //ap18 DUN 19/05/2017  send email when assessment is canceled by distributor(trello no35)
            if(assessment.ReasonFailure__c != AssessmentMap.get(assessment.id).ReasonFailure__c && assessment.ReasonFailure__c == 'CanceledByDistributor'){
                setAssessmentIdToSendEmail.add(assessment.Id);
            }
            //C-002061 : capture assessment if  Compensated__c is changed
            if(assessment.Compensated__c != AssessmentMap.get(assessment.id).Compensated__c && assessment.Compensated__c != null){
                setCompensatedAssess.add(assessment.Id);
            }

            //RLA C-002294 07/08/2018
            if (assessment.TECH_EntityCountryCode__c == 'DE'
                && ( String.isBlank(assessment.InsuranceBroker__c) ||  (String.isnotblank(assessment.InsuranceBroker__c) && !(system.label.InsBrokerName.contains(assessment.InsuranceBroker__c))))//RLA 17/06/2020 C-003699:IG - SLAs and Emails
                && assessment.Status__c == 'SOURCED'
                && assessment.BodyshopEligibleSourcing__c == FALSE
                && (    (assessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId()
                        && assessment.OrderStatus__c == 'PENDING DISTRIBUTOR (CARE)'
                        && assessment.OrderStatus__c != AssessmentMap.get(assessment.id).OrderStatus__c)
                    ||  (assessment.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()
                        && assessment.Status__c != AssessmentMap.get(assessment.id).Status__c)                    
                    )){
                listAssToSetUser.add(assessment);
                setBodyshop.add(assessment.BodyShop__c);


            }

           
        }
        
        //WCH 11/01/2019 C-002991 Developer script exception from Alpha Scale : 'AP21AssessmentSharing' for job id '7071i00000CWGnW' : Delete failed.
        if (l_Assessment.size() > 0  && AP21AssessmentSharing.isFirstAfterUpdateRun())
        {
            AP21AssessmentSharing.createSharingAssessment(l_Assessment,s_BodyShop,s_OldbodyShop);
        }

        // ABT - 04-MAY-2017 - C-001660
        if(claimShoppingListWithSTDDCleared.size() > 0)
        {
            if(System.isBatch() || System.isFuture())
            {
                AP36AssessmentPurge.clearCrashShortTermDeletionDate(claimShoppingListWithSTDDCleared);
            }
            else
            {
                AP36AssessmentPurge.clearCrashShortTermDeletionDateAsync(claimShoppingListWithSTDDCleared);
            }
        }

        //if(parentAssessmentToSetLTDD.size() > 0)
        //{
        //  if(System.isBatch() || System.isFuture())
  //          {
  //              AP36AssessmentPurge.setParentAssessmentDeletionDate(parentAssessmentToSetLTDD);
  //          }
  //          else
  //          {
  //              AP36AssessmentPurge.setParentAssessmentDeletionDateAsync(parentAssessmentToSetLTDD);
  //          }
        //}

        //if(parentAssessmentToClearLTDD.size() > 0)
        //{
        //  if(System.isBatch() || System.isFuture())
  //          {
  //              AP36AssessmentPurge.clearParentAssessmentLTDD(parentAssessmentToClearLTDD);
  //          }
  //          else
  //          {
  //              AP36AssessmentPurge.clearParentAssessmentLTDDAsync(parentAssessmentToClearLTDD);
  //          }
        //}

        //ap18 DUN 19/05/2017  send email when assessment is canceled by distributor(trello no35)
        if(setAssessmentIdToSendEmail.size() > 0)
        {
            AP18SetAssessmentStatus.sendEmailToBodyShop(setAssessmentIdToSendEmail);
        }

        system.debug('## listAssToSetUser:'+listAssToSetUser);
         //RLA C-002294 07/08/18
        if(listAssToSetUser.size() > 0 && setBodyshop.size() > 0){
            AP44PopulateContactOnAssessment.sendEmail(listAssToSetUser,setBodyshop);
        }
        
        // 06/12/17 C-002061 
        system.debug('## setCompensatedAssess:'+setCompensatedAssess);
        
        if(setCompensatedAssess.size() > 0){
            list<Assessment__c> assessList = new list<Assessment__c>();
            for(Id assessId: setCompensatedAssess){
                assessList.add(new Assessment__c(TechCompensatedIsChanged__c = true, Id = assessId));
            }

            if(assessList.size() > 0){
                update assessList;
            }
        }  
        
    }

    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }
    //WCH 09/11/2020 C-003980
    public void setIsCompensated(Map<string,Assessment__c> mapClaimNumberAssessmentClaim,Set<Id> setBodyshopsForClaimAss)
    {   system.debug('mapClaimNumberAssessmentClaim>>'+mapClaimNumberAssessmentClaim);
        Map<Id,assessment__c> mapClaimToUpdate = new Map<Id,assessment__c>();
        Map<Id,Account> theBodyshops = new Map<Id,Account>([Select Id,IceInvTransmit__c,AXAPartner__c from Account where Id in : setBodyshopsForClaimAss]);
        for(Case currentCase : [Select Id,PFR_TECH_STDClaimNr__c,PFR_ASCompDecisionFinal__c,PFR_ASCompDecisionEstim__c from Case where PFR_TECH_STDClaimNr__c in : mapClaimNumberAssessmentClaim.keyset()]){
            system.debug('currentCase>>'+currentCase);
            if(mapClaimNumberAssessmentClaim.containsKey(currentCase.PFR_TECH_STDClaimNr__c) && theBodyshops.get(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).BodyShop__c).IceInvTransmit__c && theBodyshops.get(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).BodyShop__c).AXAPartner__c){
                if(!String.isBlank(currentCase.PFR_ASCompDecisionFinal__c) && currentCase.PFR_ASCompDecisionFinal__c.equals(ASPISConstants.PFR_ASCompDecisionFinalOui)){
                    mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).Compensated__c=true;
                    if(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c!=null){
                        mapClaimToUpdate.put(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c,new assessment__c(Id=(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c),compensated__c=true));
                    }
                }else if(String.isBlank(currentCase.PFR_ASCompDecisionFinal__c)){
                    mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).Compensated__c=currentCase.PFR_ASCompDecisionEstim__c;
                    if(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c!=null){
                        mapClaimToUpdate.put(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c,new assessment__c(Id=(mapClaimNumberAssessmentClaim.get(currentCase.PFR_TECH_STDClaimNr__c).ParentAssessment__c),compensated__c=currentCase.PFR_ASCompDecisionEstim__c));
                    }
                }
            }
        }
        system.debug('mapClaimToUpdate>>'+mapClaimToUpdate.values());
        if(!mapClaimToUpdate.isEmpty()){
            Database.update(mapClaimToUpdate.values(),false);
        }
    }
}//end class