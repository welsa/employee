global class ClearAssessment
{
    webservice static void clearData(Id AssessId) // remove POs, SOs, Invoices, Cases related to the assessment
    { 
         // C-001837 :
         map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();

         Id labourRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType =: Label.SOBJECTPARTLIST and DeveloperName = 'Labour'].Id;

         List<PurchaseOrder__c> purchaseOrderToDeleteList = [SELECT  Id 
                                                             FROM    PurchaseOrder__c 
                                                             WHERE   Assessment__c = :AssessId
                                                             OR      Assessment__r.ParentAssessment__c =: AssessId];
         delete purchaseOrderToDeleteList;

         List<PrerequisiteOrder__c> salesOrderToDeleteList = [  SELECT  Id 
                                                                FROM    PrerequisiteOrder__c 
                                                                WHERE   Assessment__c = :AssessId
                                                                OR      Assessment__r.ParentAssessment__c =: AssessId];
         delete salesOrderToDeleteList;

         List<Invoice__c> invoicesToDeleteList = [  SELECT  Id 
                                                    FROM    Invoice__c 
                                                    WHERE   Assessment__c = :AssessId
                                                    OR      Assessment__r.ParentAssessment__c =: AssessId];
         delete invoicesToDeleteList;

         List<Case__c> casesToDeleteList = [SELECT  Id 
                                            FROM    Case__c 
                                            WHERE Assesment__c = :AssessId
                                            OR      Assesment__r.ParentAssessment__c =: AssessId];
         delete casesToDeleteList;
         
         List<Assessment__c> assessmentListToDeleteList = new List<Assessment__c>();
         List<PartList__c> partListToUpdate = new List<PartList__c>();

         Assessment__c currentAssessment = [SELECT Id, Status__c, TECHRulesAppliedDescription__c,RecordType.Name,  PartTypes__c,
                                                   TECH_EntityCountryCode__c, BodyShop__r.isEligibleSourcing__c, MREligibility__c, MRSourcing__c,
                                                   // C-001827
                                                    TotalNumberOfParts__c, BodyShop__r.Feature__c, Manufacturer__c, BodyShop__r.ShippingPostalCodeLeft2__c, BodyShop__r.CarBrandsSuppliedAgency__c, AgencyDistributors__c, Tech_DirectOrders__c, EntityCode__c, VINNumber__c, BodyShop__c, SelectedByBSPartTypes__c,
                                                    (SELECT Id
                                                     FROM   Assessments__r),
                                                     // ASE: 08/05/18: C-002278
                                                    (SELECT Id, SelectedByBS__c, DistributorPriceId__c, DistributorPriceId__r.DistributorID__c, Distributors__c, Type__c 
                                                    FROM    PartsLists__r)
                                            FROM Assessment__c 
                                            WHERE Id = :AssessId];
         // ASE: 08/05/18: C-002278      
         set<String> DistributorIdSet = new set<String>();                             
         for(PartList__c pl : currentAssessment.PartsLists__r ){
            if(pl.DistributorPriceId__c != null && pl.DistributorPriceId__r.DistributorID__c != null){
                DistributorIdSet.add(pl.DistributorPriceId__r.DistributorID__c); 
            }
            //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
            else if(pl.Distributors__c != null && currentAssessment.BodyShop__r.Feature__c != null && currentAssessment.BodyShop__r.Feature__c.contains('PilotDirectSourcing')){
                for(String disId : pl.Distributors__c.split(';')){
                    DistributorIdSet.add(disId);
                }
            }
         }

         currentAssessment.Status__c                        = 'New';
         currentAssessment.TECHRulesAppliedDescription__c   = '';  
         currentAssessment.PreviousStatus__c                = null;
         currentAssessment.ReasonFailure__c                 = null;
         //DUN 25/01/2018  C-002230 currentAssessment.OrderOrigin__c = null;
         currentAssessment.AgencyMode__c                    = false;
         currentAssessment.SelectedByBSPartTypes__c         = null;
         currentAssessment.AlreadyQuoted__c                 = false;//vsu 04/12/17
         // ASE: 08/05/18: C-002278
         currentAssessment.MREligibility__c = false;
         currentAssessment.Feature__c = currentAssessment.BodyShop__r.Feature__c;
         system.debug('## currentAssessment ' + currentAssessment);

         // C-001837 :
         String alldirectOrderIds = '';
         set<String> setPartTypes = new set<string>();

         if(currentAssessment.TotalNumberOfParts__c != 0){
            if(currentAssessment.BodyShop__r.Feature__c != null && currentAssessment.BodyShop__r.Feature__c.contains('PilotDirectSourcing')){
                for(String partType : currentAssessment.PartTypes__c.split(';')){
                    setPartTypes.add(partType);    
                }
                mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(currentAssessment.TECH_EntityCountryCode__c, currentAssessment.BodyShop__c, currentAssessment.Manufacturer__c, currentAssessment.bodyshop__r.ShippingPostalCodeLeft2__c, currentAssessment.bodyshop__r.CarBrandsSuppliedAgency__c, setPartTypes);
                String allFirstDistributorsIds = '';
                String allAgencyDistributorsIds = '';
                String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 :

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
                            //allDistributorsDirOrders += ','+mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders;
                            if (!allDistributorsDirOrders.contains(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders)){
                                allDistributorsDirOrders += ','+mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders;
                            }
                        }
                    }   
                    if(allFirstDistributorsIds != ''){
                        currentAssessment.MRSourcing__c = allFirstDistributorsIds.removeEnd(';');
                        currentAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                    }
                    if(alldirectOrderIds != ''){
                        alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                    }   
                    currentAssessment.Tech_DirectOrders__c=alldirectOrderIds;
                    //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                    currentAssessment.TechDistAndDirectOrder__c=allDistributorsDirOrders;

                    system.debug('## allFirstDistributorsIds:'+allFirstDistributorsIds);
                    system.debug('## allAgencyDistributorsIds:'+allAgencyDistributorsIds);
                }
                
                else{
                    currentAssessment.MRSourcing__c = 'false';
                }
            }
            else{
                currentAssessment.MRSourcing__c = String.join(new List<String>(DistributorIdSet), ';');
            }
            system.debug('## alldirectOrderIds:'+alldirectOrderIds);            
        }       

 
        system.debug('## mapPartTypeDistributorsWrap' + mapPartTypeDistributorsWrap);
         
         //Shamina M- case C-001466, reset SourceFailure field
         currentAssessment.SourceFailure__c = null;

         assessmentListToDeleteList = currentAssessment.Assessments__r;

         for(PartList__c currentPart : currentAssessment.PartsLists__r){
            PartList__c p = new PartList__c(Id = currentPart.Id,
                                             TECH_OrderedCounter__c = 0,
                                             QuantityOrdered__c = null,
                                             Suppliable__c = false,
                                             SelectedByBS__c = ((currentAssessment.TECH_EntityCountryCode__c  == 'DE' && !currentAssessment.BodyShop__r.isEligibleSourcing__c && currentAssessment.RecordType.Name == 'NewAssessment') ? false : currentPart.SelectedByBS__c));

            if(!mapPartTypeDistributorsWrap.isEmpty()){
                if(p.RecordTypeId != labourRecordTypeId){                                    
                    p.Distributors__c = mapPartTypeDistributorsWrap.containsKey(currentPart.Type__c) ? mapPartTypeDistributorsWrap.get(currentPart.Type__c).FirstDistributor : null;
                    p.NextDistributors__c = mapPartTypeDistributorsWrap.containsKey(currentPart.Type__c) ? mapPartTypeDistributorsWrap.get(currentPart.Type__c).NextDistributors : null;
                }
            }
            system.debug('## p:'+p);
            if(p != null){
                partListToUpdate.add(p);
            }            
         }

         update currentAssessment;
         

         if(assessmentListToDeleteList.size() > 0)
         {
            delete assessmentListToDeleteList;
         }

         update partListToUpdate;
    }
}