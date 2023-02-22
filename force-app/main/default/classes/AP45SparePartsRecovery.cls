/*
---------------------------------------------------------------------------------
-- - Name          : AP45SparePartsRecovery
-- - Author        : DUN
-- - Description   : Class for spare parts recovery
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------------------
-- 02-AUG-2018  DUN   1.0      C-001895 : Spare Part Recovery (Initial version)
-- 24-OCT-2018  RLA   1.2      C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing 
                                rule priority 1 is displayed in addition of the rule priority 0
-- 21-NOV-2018  WCH   1.3      C-002868 - rules applied description not filled properly for PO
-- 04-DEC-2019  RLA   1.3      C-002953 : Distributor is not able to validate PO
-- 06-FEB-2019  WCH   1.4      C-002950 - In the PO, the field "Rules Applied Description" is not displayed correctly
-- 16-JUL-2019  ASE   1.5      C-003347 : ES PO generated without OL after recovery test
---------------------------------------------------------------------------------*/
public without sharing class AP45SparePartsRecovery {

    public static map<Id,Boolean> partsRecovery(set <Id> setAssessmentId){
        system.debug('## Start AP45SparePartsRecovery.partsRecovery : ' + setAssessmentId);

        //String containing next priority that the PO should be created
        String nextPriority = '';
        //Distributor Id stored on each partlist
        String distId = '';
        //New Updated Value of nextDistributors field on partist
        String plNextDistList = '';
        //Current list of distributors on a partlist e.g dist1;dist2...
        String plCurrentDistList = '';
        //String containing partnumber of partlist or distributor price
        String partNumber;
        //distPrice stores Distributor price related to partlist
        DistributorPrice__c distPrice;
        //Set of country codes 
        Set<String> setCountryCode = new set<String>();
        //Set of cross references ids
        Set<String> substituteSet = new set<String>();
        //Set of distributor ids
        Set<Id> distributorIdSet = new Set<Id>();
        //Set of direct Orders
        Set<Id> setDirectOrders = new Set<Id>();
        //List of Priority and its corresponding distributors
        list<String> listDistPriorityArray = new list<String>();
        //List of priority
        list<String> listPriority = new list<String>();
        //List of distributors ids
        list<String> listdist = new list<String>();
        //List of purchase orders to insert
        list<PurchaseOrder__c> listPurchaseOrderToInsert = new list<PurchaseOrder__c>();
        //List of orderlines to insert
        list<OrderLine__c> listOrderLinesToInsert = new list<OrderLine__c>();
        //map of Assessment id and boolean to launch offering or not
        map<Id,Boolean> mapAssIdBoolLaunchOffering = new map<Id,Boolean>();
        //map of distributor id and purchase order inserted
        //map<Id,PurchaseOrder__c> mapDistIdPurchaseOrderInserted = new map<Id,PurchaseOrder__c>();  
        map<String, PurchaseOrder__c> mapDistIdPurchaseOrderInserted = new map<String, PurchaseOrder__c>();  
        //map of partlist to update
        map<Id,PartList__c> mapPartListToUpdate = new map<Id,PartList__c>();
        //map <distributor id+'-'+directOrderId, and its corresponding direct order>
        map<String,DirectOrder__c> mapDistIdDirectOrder = new Map<String,DirectOrder__c>();
        //map of assessment id and a set of agency distributors
        map<Id,set<Id>> mapAssIdSetAgencyDist = new map<Id,set<Id>>();
        //map of <distributorPrice.DistributorID__c-distributorPrice.CrossReference__r.Name, its corresponding distributor price>
        map<String, DistributorPrice__c> substituteMap = new map<String, DistributorPrice__c>();
        //map of country code and its correcsponding business hours
        map<String,BusinessHours> mapCountryCodeBusinessHours = new map<String,BusinessHours>();
        //map of country code and CountryCodeInformationsMapping__c
        map<String,CountryCodeInformationsMapping__c> mapCountryCodeInfo = CountryCodeInformationsMapping__c.getall();
        //map <Assessment Id,map<Distributor Id, Priority of distributor>>
        map<Id,map<Id,String>> mapAssIdDistIdPriority = new map<Id,map<Id,String>>();
        //map <Assessment,map<distributorId,list<PartList>>>
        map<Assessment__c,map<Id,set<PartList__c>>> mapAssIdmapDistIdListPartList = new map<Assessment__c,map<Id,set<PartList__c>>>();        //map of Distributors-Directorders and Priority of DirectOrders RLA   C-002868
         Map<String, String> mapDistributorsPriority = new map<String,String>();


        //WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly
        map<Id,set<String>> distIDMapPartList = new map<Id,set<String>>();

        //Quering Purchase Orders and its OrderLines for a set of assessment id
        map<Id,PurchaseOrder__c> mapPurchaseOrder = new map<Id,PurchaseOrder__c>([select Id, Status__c, Current_Priority__c, Assessment__c,
                                                                                 Assessment__r.AlreadyQuoted__c, Assessment__r.Status__c, Assessment__r.isShoppingList__c, Assessment__r.ParentAssessment__c, 
                                                                                 Assessment__r.Name, Assessment__r.BodyShop__c, Assessment__r.Entity__c, Assessment__r.AssessmentNumber__c, Assessment__r.CreatedDate, 
                                                                                 Assessment__r.LastModifiedDate, Assessment__r.SpecialAgreement__c, Assessment__r.SpecialRenting__c, Assessment__r.VINCheck__c, 
                                                                                 Assessment__r.Fleet__c, Assessment__r.TotalLoss__c, Assessment__r.BuildDate__c, Assessment__r.CrossReferences__c, Assessment__r.AgencyDistributors__c, 
                                                                                 Assessment__r.SupposedOfFraud__c, Assessment__r.DateOfIncident__c, Assessment__r.FirstRegistrationDate__c, Assessment__r.EntityCode__c, 
                                                                                 Assessment__r.ReasonFailure__c, Assessment__r.Compensated__c, Assessment__r.Feature__c, Assessment__r.ModelV2__c, Assessment__r.MissionNumber__c, 
                                                                                 Assessment__r.ClaimReference__c, Assessment__r.Manufacturer__c, Assessment__r.EntityRules__c, Assessment__r.ASReference__c, Assessment__r.Tech_DirectOrders__c,
                                                                                 Assessment__r.Bodyshop_is_Eligible_Non_AXA__c, Assessment__r.PlateNumber2__c, Assessment__r.TECH_EntityCountryCode__c, Assessment__r.VINNumber__c, 
                                                                                 Assessment__r.AssessmentID__c, Assessment__r.BodyShop__r.Type, Assessment__r.BodyShop__r.SepaValid__c, Assessment__r.MREligibility__c, Assessment__r.MRSourcing__c,
                                                                                 Assessment__r.TechDistAndDirectOrder__c//RLA C-002868
                                                                                 //(select Id, DeliveryStatus__c, PurchaseOrder__c, Suppliable__c, PartList__c, 
                                                                                 //           PartList__r.NextDistributors__c, PartList__r.Name, PartList__r.VAT__c, PartList__r.Quantity__c, PartList__r.PartNumber__c, PartList__r.Price__c, 
                                                                                 //           PartList__r.Type__c, PartList__r.OriginalPart__c, PartList__r.Original__c, PartList__r.Description__c, PartList__r.TECH_OrderedCounter__c,
                                                                                 //           PartList__r.SelectedByBS__c, PartList__r.CrossReferenceId__c, PartList__r.IsSourced__c, PartList__r.Assessment__c, PartList__r.TECH_OriginalPart__c,
                                                                                 //           PartList__r.ProducerName__c, PartList__r.Distributors__c, PartList__r.QuantityOrdered__c, PartList__r.CrossReferenceId__r.Name,
                                                                                 //           PartList__r.Alpha_Scale_MRID__c, PartList__r.DistributorPriceId__c, PartList__r.Distributor__c, PartList__r.TECHDistList__c, PartList__r.ASNetPrice__c, 
                                                                                 //           PartList__r.StandardMargin__c, PartList__r.StandardDiscount__c, PartList__r.Suppliable__c
                                                                                 // from OrderLines__r) Commented by RLA 04/12/2018 C-002953 : Distributor is not able to validate PO
                                                                          from PurchaseOrder__c
                                                                          where Assessment__c in: setAssessmentId]);
        system.debug('## mapPurchaseOrder : ' + mapPurchaseOrder);
        //RLA 04/12/2018
        Map<Id,List<OrderLine__c>> mapPOOrderlines = new map<Id,List<OrderLine__c>>();
        For (OrderLine__c ol: [select Id, DeliveryStatus__c, PurchaseOrder__c, Suppliable__c, PartList__c, 
                                        PartList__r.NextDistributors__c, PartList__r.Name, PartList__r.VAT__c, PartList__r.Quantity__c, PartList__r.PartNumber__c, PartList__r.Price__c, 
                                        PartList__r.Type__c, PartList__r.OriginalPart__c, PartList__r.Original__c, PartList__r.Description__c, PartList__r.TECH_OrderedCounter__c,
                                        PartList__r.SelectedByBS__c, PartList__r.CrossReferenceId__c, PartList__r.IsSourced__c, PartList__r.Assessment__c, PartList__r.TECH_OriginalPart__c,
                                        PartList__r.ProducerName__c, PartList__r.Distributors__c, PartList__r.QuantityOrdered__c, PartList__r.CrossReferenceId__r.Name,
                                        PartList__r.Alpha_Scale_MRID__c, PartList__r.DistributorPriceId__c, PartList__r.Distributor__c, PartList__r.TECHDistList__c, PartList__r.ASNetPrice__c, 
                                        PartList__r.StandardMargin__c, PartList__r.StandardDiscount__c, PartList__r.Suppliable__c, PartList__r.CrossReferenceId__r.UseClassicSourcing__c, PartList__r.CrossReferenceId__r.IAMPartNumber__c /*RLA 3142*/
                              from OrderLine__c
                              Where PurchaseOrder__c IN: mapPurchaseOrder.keySet()]){
            if (mapPOOrderlines.containsKey(ol.PurchaseOrder__c)){
                mapPOOrderlines.get(ol.PurchaseOrder__c).add(ol);  
            }
            else{
                mapPOOrderlines.put(ol.PurchaseOrder__c,new list<OrderLine__c>{ol});      
            }

        }

        //Looping through map of purchase order queried
        for(PurchaseOrder__c po : mapPurchaseOrder.values()){
            nextPriority = '';
            //Getting the next priority to search for distributors
            Integer nextPriorityNumber = po.Current_Priority__c != null ? (Integer.valueOf((po.Current_Priority__c.split('P')[1])) + 1) : 0;
            system.debug('## nextPriorityNumber : ' + nextPriorityNumber);
            //Checking if inner set of Orderlines is not null and its size is greater than zero
            //if(po.OrderLines__r != null && po.OrderLines__r.size() > 0){ commented by RLA 04/12/2018 C-002953 : Distributor is not able to validate PO
            if (mapPOOrderlines.containsKey(po.Id)){ //RLA 04/12/2018 C-002953 : Distributor is not able to validate PO
                system.debug('## got in : ' );

                //system.debug('## po.OrderLines__r : ' + po.OrderLines__r);
                //Looping through orderlines of its correcsponding purchase order 
                for(OrderLine__c ol : mapPOOrderlines.get(po.Id)){//RLA 04/12/2018 C-002953 : Distributor is not able to validate PO
                    system.debug('## ol : ' + ol);
                    //Intialising String varaibles
                    distId = plCurrentDistList = plNextDistList = '';
                    //Checking if an Orderline is Canceled, its suppliable is no or null and its related Partlist is not already supplied
                    if((ol.DeliveryStatus__c == 'Canceled' || ol.Suppliable__c == null || ol.Suppliable__c == 'NO') && !ol.PartList__r.Suppliable__c && ol.PartList__r.NextDistributors__c != null){
                        system.debug('## po.Current_Priority__c : ' + po.Current_Priority__c);
                        //Assigning the next priority
                        nextPriority = 'P'+ nextPriorityNumber;
                        system.debug('## nextPriority : ' + nextPriority);
                        //Check if the partlist related to that OL has any distributor with the new priority
                        if(ol.PartList__r.NextDistributors__c != null && ol.PartList__r.NextDistributors__c.contains(nextPriority)){
                            system.debug('## nextPriority : ' + nextPriority);
                            listDistPriorityArray = ol.PartList__r.NextDistributors__c.split(nextPriority+':');
                            system.debug('## listDistPriorityArray : ' + listDistPriorityArray);
                            listPriority = listDistPriorityArray[1].split('}');
                            system.debug('## listPriority : ' + listPriority);
                            listdist = listPriority[0].split(';');
                            system.debug('## listdist : ' + listdist);
                            plCurrentDistList = listDistPriorityArray[0] + nextPriority + ':' + listPriority[0] + '}';
                            system.debug('## plCurrentDistList : ' + plCurrentDistList);
                            plNextDistList = listPriority.size() > 1 ? listPriority[(listPriority.size() - 1)].removeStart(',') + '}' : '';
                            system.debug('## plNextDistList : ' + plNextDistList);
                            mapPartListToUpdate.put(ol.PartList__c, new PartList__c(Id = ol.PartList__c, NextDistributors__c = plNextDistList));
                            //looping through list of distributors
                            for(String distLine : listdist){
                                //Checking if distributor contains "-true" value which is agencyMode = true
                                distId = distLine.contains('-true') ? distId = distLine.split('-true')[0] : distLine;
                                if(distId != null){
                                    //Adding assessment country code to setCountryCode 
                                    setCountryCode.add(po.Assessment__r.TECH_EntityCountryCode__c);
                                    //Adding distributor ids to distributorIdSet 
                                    distributorIdSet.add((Id)distId);
                                    //building map <Assessment,map<Distributor id, list <partlist>>>
                                    if(!mapAssIdmapDistIdListPartList.containsKey(po.Assessment__r)){
                                        mapAssIdmapDistIdListPartList.put(po.Assessment__r, new map<Id,set<PartList__c>>{(Id)distId => new set<PartList__c>{ol.PartList__r}});

                                        //WCH 06/02/2019 C-002950 - In the PO, the field "Rules Applied Description" is not displayed correctly
                                        distIDMapPartList.put((Id)distId,new set<String>{ol.PartList__r.Type__c});
                                    }
                                    else{
                                        if(!mapAssIdmapDistIdListPartList.get(po.Assessment__r).containsKey((Id)distId)){
                                            mapAssIdmapDistIdListPartList.get(po.Assessment__r).put((Id)distId, new set<PartList__c>{ol.PartList__r});

                                            //WCH 06/02/2019 C-002950 - In the PO, the field "Rules Applied Description" is not displayed correctly
                                            distIDMapPartList.put((Id)distId, new set<String>{ol.PartList__r.Type__c});
                                        }
                                        else{
                                            mapAssIdmapDistIdListPartList.get(po.Assessment__r).get((Id)distId).add(ol.PartList__r);

                                            //WCH 06/02/2019 C-002950 - In the PO, the field "Rules Applied Description" is not displayed correctly
                                            distIDMapPartList.get((Id)distId).add(ol.PartList__r.Type__c);
                                        }
                                    }
                                    //building map<Assessment, set<Agency distributor ids>>
                                    if(distLine.contains('-true')){
                                        if(!mapAssIdSetAgencyDist.containsKey(po.Assessment__c)){
                                            mapAssIdSetAgencyDist.put(po.Assessment__c,new set <Id>{distId});
                                        }
                                        else{
                                            mapAssIdSetAgencyDist.get(po.Assessment__c).add(distId);
                                        }
                                    }
                                    //building map<Assessment Id, map<Distributor id, Next Priority
                                    if(!mapAssIdDistIdPriority.containsKey(po.Assessment__c)){
                                        mapAssIdDistIdPriority.put(po.Assessment__c, new map<Id,String>{(Id)distId => nextPriority});
                                    }
                                    else if(!mapAssIdDistIdPriority.get(po.Assessment__c).containsKey(distId)){
                                        mapAssIdDistIdPriority.get(po.Assessment__c).put((Id)distId,nextPriority);
                                    }
                                }
                            }
                            //building set of substitutes ids in substituteSet
                            for (String crossRef : po.Assessment__r.CrossReferences__c.split(';')) {
                                substituteSet.add(crossRef);
                            }
                            //building set of direct order ids in setDirectOrders
                            if(po.Assessment__r.Tech_DirectOrders__c != null){
                                for(String dirtOrd : po.Assessment__r.Tech_DirectOrders__c.split(';')){
                                    setDirectOrders.add(dirtOrd);
                                }
                            }
                            if(po.Assessment__r.TechDistAndDirectOrder__c != null){

                                mapDistributorsPriority = ASPISDirectSourcing.buildMapDisPrio(po.Assessment__r.TechDistAndDirectOrder__c);
                            }
                        }
                    }
                }
            }

        }
        
        //Looping through list of selected direct orders to build map<Distributor Id, Direct Order>
        //WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly. Add Field Part_Type__c
        for(DirectOrder__c DOs :[select Id,name,Type__c,Priority__c,Distributor__c,Part_Type__c from DirectOrder__c where Id in : setDirectOrders]){
            system.debug('## DOs : '+ DOs);
            mapDistIdDirectOrder.put(DOs.Distributor__c+'-'+DOs.Id,DOs);
        }
        system.debug('## mapDistIdDirectOrder : '+ mapDistIdDirectOrder);

        //checking if mapAssIdmapDistIdListPartList size is greater than zero
        if(mapAssIdmapDistIdListPartList.size() > 0){

            //looping through set of country codes to build map <country code,business hours>
            for(String couCode : setCountryCode){
                mapCountryCodeBusinessHours.put(couCode,ASPISConstants.getBusinessHours(couCode));
            }

            //looping through selected list of distributor price to build map<Distributor Id,distributor price>
            for (DistributorPrice__c dp : [Select DistributorID__c, DistributorPublicPrice__c, DistributorPartClass__c, DistributorDiscount__c, DistributorPartNumber__c,
                                            CrossReference__r.Name, CrossReference__r.ASNetPrice__c, CrossReference__r.ASPublicPrice__c, CrossReference__r.IAMPartNumber__c, CrossReference__r.IAMManufacturer__c
                                          from DistributorPrice__c 
                                          where CrossReference__r.Name in :substituteSet AND DistributorID__c IN :distributorIdSet AND DistributorPrice__c.Active__c = true AND DistributorPrice__c.isDeleted__c = false]) {                   
                system.debug('## dp: '+ dp);                    
                if(!substituteMap.containsKey(dp.DistributorID__c + '-' + dp.CrossReference__r.Name )){
                   substituteMap.put(dp.DistributorID__c + '-' + dp.CrossReference__r.Name , dp);
                }
            }
            system.debug('## distIDMapPartList '+ distIDMapPartList);   
            system.debug('## mapDistributorsPriority '+ mapDistributorsPriority);   
            system.debug('## mapAssIdDistIdPriority '+ mapAssIdDistIdPriority);   
            //looping through Assessments
            for(Assessment__c ass : mapAssIdmapDistIdListPartList.keySet()){
                //looping through mapAssIdmapDistIdListPartList.get(assessment).values to create a purchase order for each distributor
                for(Id disId : mapAssIdmapDistIdListPartList.get(ass).keySet()){
                    String rulesAppliedDescription = '';
                    PurchaseOrder__c newPO = new PurchaseOrder__c ( assessment__c = ass.Id,
                                                                    SparePartsRecovery__c = true,
                                                                    validityDate__c = Date.valueOf(Businesshours.add(mapCountryCodeBusinessHours.get(ass.TECH_EntityCountryCode__c).id,datetime.now(),mapCountryCodeInfo.get(ass.TECH_EntityCountryCode__c).Validity_Duration_Purchase_Order__c!=null?Integer.valueOf(mapCountryCodeInfo.get(ass.TECH_EntityCountryCode__c).Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),               
                                                                    status__c = system.Label.PURCHASEORDERDRAFTQUOTESTATUS,
                                                                    distributor__c = disId,
                                                                    recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId(),
                                                                    SLAQuotationEntryDate__c = datetime.now(),
                                                                    Tech_ExternalId__c = String.valueOf(ass.Id) + String.valueOf(disId),
                                                                    Current_Priority__c = mapAssIdDistIdPriority.get(ass.Id).get(disId),
                                                                    AgencyMode__c = (mapAssIdSetAgencyDist.containsKey(ass.Id) && mapAssIdSetAgencyDist.get(ass.Id).contains(disId)));

                    for(String distIdDOId : mapDistIdDirectOrder.keySet()){
                        system.debug('## distIdDOId '+ distIdDOId);      
                        if(distIdDOId.contains(disId) && ass.Tech_DirectOrders__c.contains(distIdDOId.split('-')[1])){
                            system.debug('## disId '+ disId);    
                            //WCH 20181121 : C-002868 : additional check on PO to be created priority value
                            if (mapDistributorsPriority.containskey(distIdDOId)
                                && distIDMapPartList.get(disId).removeAll(new Set<String>(mapDistIdDirectOrder.get(distIdDOId).Part_Type__c.split(';'))) //WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly 
                                && mapDistributorsPriority.get(distIdDOId) == mapDistIdDirectOrder.get(distIdDOId).Priority__c && mapDistributorsPriority.get(distIdDOId)==mapAssIdDistIdPriority.get(ass.Id).get(disId)){ //RLA  C-002868 :
                                rulesAppliedDescription += 'Name of record:' + mapDistIdDirectOrder.get(distIdDOId).Name +
                                                        '\nType de sourcing:' + mapDistIdDirectOrder.get(distIdDOId).Type__c +
                                                        '\nPriority:' + mapDistIdDirectOrder.get(distIdDOId).Priority__c + '\n';
                            }                        }
                    }
                    newPO.TECHRulesAppliedDescription__c = rulesAppliedDescription;
                    listPurchaseOrderToInsert.add(newPO);
                }
                //Building a map of assessment id and a boolean -> launch offering or not
                mapAssIdBoolLaunchOffering.put(ass.Id,false);
            }
            system.debug('## listPurchaseOrderToInsert : '+ listPurchaseOrderToInsert);

            //Checking if size of list of purchase orders to insert is greater than zero
            if(listPurchaseOrderToInsert.size() > 0){

                //inserting new purchase orders
                insert listPurchaseOrderToInsert;

                //looping through list of selected purchase orders to build a map<Dist Id, Purchase Order>
                // ASE :16/07/19: C-003347 :
                for(PurchaseOrder__c po : [Select Id, Name, Rebate__c,  Assessment__c, Distributor__c, TECH_AssessmentCountryCode__c /*RLA 3142*/ from PurchaseOrder__c where Id in: listPurchaseOrderToInsert]){
                     if(!mapDistIdPurchaseOrderInserted.containsKey(po.Distributor__c + '-' + po.Assessment__c)){
                        mapDistIdPurchaseOrderInserted.put(po.Distributor__c + '-' + po.Assessment__c , po);
                    }   
                }
                system.debug('## mapDistIdPurchaseOrderInserted : '+ mapDistIdPurchaseOrderInserted);
                system.debug('## mapAssIdmapDistIdListPartList : '+ mapAssIdmapDistIdListPartList);

                //looping through mapAssIdmapDistIdListPartList to create orderlines
                for(Assessment__c ass : mapAssIdmapDistIdListPartList.keySet()){
                            Integer count = 0;
                    system.debug('## ass : '+ ass);
                    for(Id disId : mapAssIdmapDistIdListPartList.get(ass).keySet()){
                        system.debug('## disId : '+ disId);
                        // ASE :16/07/19: C-003347 :
                        String mapKey = disId + '-' + ass.Id;
                        //looping through a list of partlist to create orderlines
                        for(PartList__c pl : mapAssIdmapDistIdListPartList.get(ass).get(disId)){
                            count ++;
                            system.debug('## pl : '+ pl);
                            distPrice = substituteMap.containsKey(disId + '-' + pl.PartNumber__c) ? substituteMap.get(disId + '-' + pl.PartNumber__c) : null;
                            system.debug('## distPrice : '+ distPrice);
                            //partNumber = distPrice != null ? distPrice.DistributorPartNumber__c: pl.PartNumber__c;
                            //* Ruksaar L    14/05/2019  C-003142 Cross Ref Sourcing R4 for Spain
                            if (distPrice != null ){
                                partNumber = distPrice.DistributorPartNumber__c;
                            }
                            // ASE :16/07/19: C-003347 :use mapKey instead of disId as key for mapDistIdPurchaseOrderInserted
                            else if (mapDistIdPurchaseOrderInserted.get(mapKey).TECH_AssessmentCountryCode__c == 'ES'
                                && String.isNotBlank(pl.CrossReferenceId__c)
                                && (pl.PartNumber__c).startsWith('ASCR-')
                                && !pl.CrossReferenceId__r.UseClassicSourcing__c ){
                                partNumber = pl.CrossReferenceId__r.IAMPartNumber__c; 

                            }
                            else{
                                partNumber = pl.PartNumber__c ;
                            }
                            system.debug('## partNumber1 : '+ partNumber);
                            listOrderLinesToInsert.add(new OrderLine__c(PartNumber__c = (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber, 
                                                                        Ordertype__c = 'ORIGINAL',
                                                                        Description__c = pl.Description__c,
                                                                        Type__c = (distPrice != null ? distPrice.DistributorPartClass__c : pl.Type__c),
                                                                        Quantity__c = pl.Quantity__c,
                                                                        AssessmentPrice__c = pl.Price__c,
                                                                        CataloguePrice__c = (distPrice != null ? distPrice.DistributorPublicPrice__c : pl.Price__c),
                                                                        VAT__c = pl.VAT__c,
                                                                        Manufacturer__c = pl.ProducerName__c, 
                                                                        PartList__c = pl.Id,
                                                                        PurchaseOrder__c = mapDistIdPurchaseOrderInserted.get(mapKey).Id,
                                                                        Rebate__c = (ass.TECH_EntityCountryCode__c == 'DE' && !(pl.PartNumber__c).startsWith('ASP-') && distPrice == null) ? 0 : mapDistIdPurchaseOrderInserted.get(mapKey).Rebate__c,
                                                                        AXADiscount__c = (distPrice != null ? distPrice.DistributorDiscount__c : 0),
                                                                        DistributorPrice__c = (distPrice != null ? distPrice.Id : null),
                                                                        ASBodyshopPrice__c = (distPrice != null ? distPrice.CrossReference__r.ASPublicPrice__c : ((partNumber.startsWith('ASP-')) ? pl.Price__c : 0)),
                                                                        ASBodyshopNetPrice__c = (distPrice != null ? distPrice.CrossReference__r.ASNetPrice__c  : ((partNumber.startsWith('ASP-')) ? pl.ASNetPrice__c : 0)),
                                                                        AlphaScaleMRID__c = pl.Alpha_Scale_MRID__c,
                                                                        TechExternalId__c = mapDistIdPurchaseOrderInserted.get(mapKey).Name + '-' + pl.Id
                                                                       ));  
                        }
                    }
                }
                system.debug('## listOrderLinesToInsert : '+ listOrderLinesToInsert);
                //inserting orderlines
                if(listOrderLinesToInsert.size() > 0){
                    insert listOrderLinesToInsert;
                }
            }

            system.debug('## mapPartListToUpdate : '+ mapPartListToUpdate);
            //updating partlists
            if(mapPartListToUpdate.size() > 0){
                update mapPartListToUpdate.values();
            }

            system.debug('## setAssessmentId : '+ setAssessmentId);
            //Building a map of assessment id and a boolean -> launch offering or not
            for(Id assId : setAssessmentId){
                system.debug('## assId : '+ assId);
                if(!mapAssIdBoolLaunchOffering.containsKey(assId)){
                    mapAssIdBoolLaunchOffering.put(assId,true);
                }
            }
        }
        else{
            //Building a map of assessment id and a boolean -> launch offering or not
            for(Id assId : setAssessmentId){
                system.debug('## assId else part: '+ assId);
                mapAssIdBoolLaunchOffering.put(assId,true);
            }
        }

        system.debug('## End AP45SparePartsRecovery.partsRecovery : ' + mapAssIdBoolLaunchOffering);

        return mapAssIdBoolLaunchOffering;

    }
}