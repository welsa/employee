/*************************************************************************************
Class Name - ASPISDirectSourcing
Version - 1.0
Created Date - 23 MAY 2018
Function - Class for direct sourcing

Modification Log :
-------------------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------   -----------------------                    
* Dourga       23/05/2018   Initial Version (C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors)
* Welsa        21/08/2018   C-001837 :Il faut qu’on puisse savoir quel règle de sourcing a été utilisé lors du sourcing comme ce qui est fait aujourd’hui avec les master rules.
*                           le faire sur la PO pour pouvoir tracer les créations par spare recovery aussi.
* Ruksaar      24/10/2018   C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing 
                            rule priority 1 is displayed in addition of the rule priority 0
* Welsa        31/10/2018   C-002883 - The PO with Priority 1 is not created when ProService cancels a part or the whole PO     
* Ruksaar      01/11/2018   C-002883 - The PO with Priority 1 is not created when ProService cancels a part or the whole PO  
* Welsa        19/11/2018   C-002883 - rules applied description not filled for PO , DO agency mode
* Welsa        21/11/2018   C-002868 - rules applied description not filled properly for PO
* Welsa        07/02/2019   C-002950 - In the PO, the field "Rules Applied Description" is not displayed correctly
* Ruksaar L    29/04/2019   C-003142 Cross Ref Sourcing R4 for Spain
* Welsa C      21/08/2019   C-003376 : Create assessment from scratch for Germany uses classic sourcing instead of direct soucing when no DO found
* Welsa C      21/05/2020   C-003735 :Remove Code that shares BS Account with Distributor
*************************************************************************************/   
public without sharing class ASPISDirectSourcing {

    public static map<String,List<String>> mapDistributorsPriorities = new map<String,List<String>>();

    public class DistributorsListWrapper
    {
        public String FirstDistributor;
        public String NextDistributors;
        public String AgencyDistributors;
        public set<Id> DirectOrderIds; 
        public String DistributorsDirOrders;

        public DistributorsListWrapper(String fDis, String nDis, String aDis, set<Id> dOIds, string disDir)
        {
            FirstDistributor = fDis;
            NextDistributors = nDis;
            AgencyDistributors = aDis;
            DirectOrderIds = dOIds;
            DistributorsDirOrders = disDir;

        }
    }

    public static map<String,DistributorsListWrapper> getmaptypeDistributors(String assCountryCode, Id bodyShopId, String assBrand, String assState, String bodyShopCarBrandsSuppliedAgency, set <String> types){
        //build map <partType, DistributorsListWrapper> getmaptypeDistributors
        system.debug('## getmaptypeDistributors start');
        map<String,DistributorsListWrapper> mapPartTypeListdistributors = new map<String,DistributorsListWrapper>();
        map<String,list<DirectOrder__c>> mapTypeDistributor = new map<String,list<DirectOrder__c>>();
        set<Id> directOrdersIds = new set<Id>();
        String priority0Distributors, priority1Distributors, priority2Distributors, allAgencyDistributors;
        String allTypes = '';
        Boolean BSisAgency = String.isBlank(bodyShopCarBrandsSuppliedAgency)? false : bodyShopCarBrandsSuppliedAgency.contains(assBrand);

        if(types.size() > 0){
            for(String t : types){
                allTypes += '\'' + t + '\',';
            }
            allTypes = allTypes.removeEnd(',');
        }

        system.debug('## allTypes' + allTypes);

        String query = ' SELECT Name,Distributor__c, Part_Type__c, Priority__c, BodyShop__c, Agency_mode__c, Type__c  ' +
                        ' FROM DirectOrder__c  ' +
                        ' WHERE RecordType.DeveloperName = \'Direct_Sourcing\' ' +
                        ' AND Part_Type__c INCLUDES ( ' + allTypes + ' ) '  +
                        ' AND Active__c = true ' +
                        ' AND Distributor__r.ShippingCountryCode = \''+ assCountryCode + '\' '+
                        ' AND ((BodyShop__c = \'' + bodyShopId + '\' AND Type__c = \'Exception\' ) ' +
                        ' OR (BodyShop__c = null AND Type__c = \'General\' )) ' +
                        ' AND Brands__c INCLUDES (\'' + assBrand + '\') ' +
                        ' AND State__c INCLUDES (\'' + assState + '\') ' +
                        ' AND Distributor__c!=null ' ;

        //if BS supply brand in non agency, then select only non agency
        query = (!BSisAgency ? query+=' and Agency_mode__c=false ' : query);

        //add sorting
        query+=' Order by Type__c desc,Priority__c asc';

        system.debug('## query' + query);

        list<DirectOrder__c> listDistributors = Database.query(query);

        system.debug('## listDistributors' + listDistributors);

        Map<String,Map<String,List<DirectOrder__c>>> partTypeMapPriorityMapDO = new Map<String,Map<String,List<DirectOrder__c>>>();
        Map<String,Map<String,List<DirectOrder__c>>> partTypeMapPriorityMapDOAgency = new Map<String,Map<String,List<DirectOrder__c>>>();
        Set<String> partTypeHavingExceptions = new Set<String>();

        //populate values part type per priority per direct orders
        for(DirectOrder__c dOdis : listDistributors){
            for(String ptype : dOdis.Part_Type__c.split(';')){
                //populate values
                if(types.contains(ptype)){
                    if(dOdis.Type__c.equals('Exception')){
                        partTypeHavingExceptions.add(ptype);
                    }
                    if(dOdis.Agency_mode__c){
                        if(!partTypeMapPriorityMapDOAgency.containsKey(ptype)){
                            partTypeMapPriorityMapDOAgency.put(ptype,new Map<String,List<DirectOrder__c>>{dOdis.Type__c+'_'+dOdis.Priority__c=>new List<DirectOrder__c>{dOdis}});
                        }else{
                            if(!partTypeMapPriorityMapDOAgency.get(ptype).containsKey(dOdis.Type__c+'_'+dOdis.Priority__c)){
                                partTypeMapPriorityMapDOAgency.get(ptype).put(dOdis.Type__c+'_'+dOdis.Priority__c,new List<DirectOrder__c>{dOdis});
                            }else{
                                partTypeMapPriorityMapDOAgency.get(ptype).get(dOdis.Type__c+'_'+dOdis.Priority__c).add(dOdis);
                            }
                        }
                    }
                    if(!partTypeMapPriorityMapDO.containsKey(ptype)){
                        partTypeMapPriorityMapDO.put(ptype,new Map<String,List<DirectOrder__c>>{dOdis.Type__c+'_'+dOdis.Priority__c=>new List<DirectOrder__c>{dOdis}});
                    }else{
                        if(!partTypeMapPriorityMapDO.get(ptype).containsKey(dOdis.Type__c+'_'+dOdis.Priority__c)){
                            partTypeMapPriorityMapDO.get(ptype).put(dOdis.Type__c+'_'+dOdis.Priority__c,new List<DirectOrder__c>{dOdis});
                        }else{
                            partTypeMapPriorityMapDO.get(ptype).get(dOdis.Type__c+'_'+dOdis.Priority__c).add(dOdis);
                        }
                    }
                }
            }
        }
        system.debug('## partTypeMapPriorityMapDO>>' + partTypeMapPriorityMapDO);
        //check if contains exceptions, if contains exceptions, discard generals
        for(String thePartType : partTypeMapPriorityMapDO.KeySet()){
            String selectedType = partTypeHavingExceptions.contains(thePartType)? 'Exception' : 'General';
            String FirstDistributor,NextDistributors,AgencyDistributors;
            FirstDistributor=NextDistributors=AgencyDistributors='';
            String prio0Distributors = '';
            String prio1Distributors = '';
            String prio2Distributors = '';
            String distributorsDirOrders0 = '';
            String distributorsDirOrders1 = '';
            String distributorsDirOrders2 = '';
            String allDistributorsDirOrders = '';
            set<Id> DirectOrderIds= new set<Id>();
            Boolean currentPartTypeHasAgencyDist = partTypeMapPriorityMapDOAgency.containsKey(thePartType);
            //system.debug('@@ 1: '+partTypeMapPriorityMapDOAgency.get(thePartType));
            if(BSisAgency){
                system.debug('@@ agency: ');

                //BS is Agency               
                for(String thePriority : partTypeMapPriorityMapDO.get(thePartType).KeySet()){
                    //select DO according to type =exception or general
                    if(thePriority.contains(selectedType)){
                        //check if current priority has distributors available in agency mode
                        boolean currentPriorityHasDOAgency = currentPartTypeHasAgencyDist?partTypeMapPriorityMapDOAgency.get(thePartType).containsKey(thePriority):false;
                        if(currentPriorityHasDOAgency){
                            system.debug('@@ currentPriorityHasDOAgency: ');

                            if(partTypeMapPriorityMapDOAgency.get(thePartType).containsKey(thePriority)){
                                //RLA 05/11/2018 C-002883 
                                for (DirectOrder__c dirorder: partTypeMapPriorityMapDOAgency.get(thePartType).get(thePriority)){
                                
                                    if (thePriority.contains('P0')){
                                        prio0Distributors += (prio0Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');   
                                        distributorsDirOrders0 +=  (distributorsDirOrders0.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';'); 
                                    }
                                    else if (thePriority.contains('P1')){
                                        prio1Distributors += (prio1Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c + (dirorder.Agency_mode__c ? '-true' : '') + ';'); 
                                        distributorsDirOrders1 +=  (distributorsDirOrders1.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');    
                                        
                                    }
                                    else if (thePriority.contains('P2')){
                                        prio2Distributors += (prio2Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+ (dirorder.Agency_mode__c ? '-true' : '') + ';');
                                        distributorsDirOrders2 +=  (distributorsDirOrders2.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');                               

                                    }
                                    AgencyDistributors+= dirorder.Distributor__c+';';
                                    DirectOrderIds.add(dirorder.Id);
                                }

                            }
                        }else{
                            // system.debug('@@ currentPriorityHas no DOAgency: ');

                            if (partTypeMapPriorityMapDO.get(thePartType).containsKey(thePriority)){
                                //RLA 05/11/2018 C-002883 
                                for (DirectOrder__c dirorder: partTypeMapPriorityMapDO.get(thePartType).get(thePriority)){
                                    if (thePriority.contains('P0')){
                                        prio0Distributors += (prio0Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');  
                                        distributorsDirOrders0 +=  (distributorsDirOrders0.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';'); 
                                    }
                                    else if (thePriority.contains('P1')){
                                        prio1Distributors += (prio1Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');
                                        distributorsDirOrders1 +=  (distributorsDirOrders1.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');    
                                    }
                                    else if (thePriority.contains('P2')){
                                        prio2Distributors += (prio2Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');  
                                        distributorsDirOrders2 +=  (distributorsDirOrders2.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');                               
                                    }  

                                    DirectOrderIds.add(dirorder.Id);
                                }
                            }
                        }
                    }
                }
            }else{
                system.debug('@@ non agency: ');
                //not agency
                
                for(String thePriority : partTypeMapPriorityMapDO.get(thePartType).KeySet()){
                    //select DO according to type =exception or general
                    if(thePriority.contains(selectedType)
                        && partTypeMapPriorityMapDO.get(thePartType).containsKey(thePriority)){
                        //if more than 1 DO for a given priority, ignore > correct behaviour?
                        For (DirectOrder__c dirorder: partTypeMapPriorityMapDO.get(thePartType).get(thePriority)){
                            //RLA 05/11/2018 C-002883                            

                            if (thePriority.contains('P0')){
                                prio0Distributors += (prio0Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');   
                                distributorsDirOrders0 +=  (distributorsDirOrders0.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';'); 

                            }
                            else if (thePriority.contains('P1')){
                                prio1Distributors += (prio1Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');   
                                distributorsDirOrders1 +=  (distributorsDirOrders1.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');    

                            }
                            else if (thePriority.contains('P2')){
                                prio2Distributors += (prio2Distributors.contains(dirorder.Distributor__c) ? '' : dirorder.Distributor__c+';');    
                                distributorsDirOrders2 +=  (distributorsDirOrders2.contains(dirorder.Distributor__c + '-' + dirorder.Id) ? '' : dirorder.Distributor__c + '-' + dirorder.Id+';');
                            }
                            

                            if(dirorder.Agency_mode__c){
                                AgencyDistributors+=dirorder.Distributor__c+';';
                            }
                            DirectOrderIds.add(dirorder.Id);
                        }
                       
                    }
                }                

            }

            if(prio0Distributors == ''){
                prio0Distributors = prio1Distributors;
                prio1Distributors = '';
            }
            //WCH 21/08/2019 C-003376 commented code change from else if to if
            /* else if(prio0Distributors == '' && prio1Distributors == ''){ */
            if(prio0Distributors == '' && prio1Distributors == ''){
                prio0Distributors = prio2Distributors;
                prio2Distributors = ''; 
            }

            prio1Distributors = prio1Distributors != '' ? '{P1:'+prio1Distributors.removeEnd(';')+'}' : '';
            prio2Distributors = prio2Distributors != '' ? '{P2:'+prio2Distributors.removeEnd(';')+'}' : '';



            if (String.isNotBlank(distributorsDirOrders0)){
                allDistributorsDirOrders += '{P0:'+ distributorsDirOrders0.removeEnd(';')+'},';  
            }
            if (String.isNotBlank(distributorsDirOrders1)){
                allDistributorsDirOrders += '{P1:'+ distributorsDirOrders1.removeEnd(';')+'},';  
            }
            if (String.isNotBlank(distributorsDirOrders2)){
                allDistributorsDirOrders += '{P2:'+ distributorsDirOrders2.removeEnd(';')+'}';  
            }

            system.debug('@@ allDistributorsDirOrders rla: '+allDistributorsDirOrders);
            



            mapPartTypeListdistributors.put(thePartType, new DistributorsListWrapper(
                                                        prio0Distributors != '' ? prio0Distributors.removeEnd(';') :'',
                                                        (prio1Distributors != '' && prio2Distributors != '') ? prio1Distributors + ',' + prio2Distributors : prio1Distributors + prio2Distributors,
                                                        AgencyDistributors,
                                                        DirectOrderIds,
                                                        allDistributorsDirOrders));//RLA Case-2868
        }

        system.debug('## mapPartTypeListdistributors' + mapPartTypeListdistributors);

        return mapPartTypeListdistributors;
    }

    public static map <string,PurchaseOrder__c> createPurchaseOrders(Assessment__c ass, 
                                                                list <Account> distributors,
                                                                string errorReported,
                                                                datetime lastCallMade,
                                                                set <id> setDistIdWithSASInfo,
                                                                map <id,Account> distributorMap, 
                                                                String priorityValue,
                                                                set<id> AgencyDistributorIds,
                                                                Set<Id> DirectOrders){
        system.debug('## Start createOrders');
        system.debug('## ass ' + ass);
        system.debug('## distributors ' + distributors);
        system.debug('## errorReported ' + errorReported);
        system.debug('## lastCallMade ' + lastCallMade);
        system.debug('## setDistIdWithSASInfo ' + setDistIdWithSASInfo);
        system.debug('## distributorMap ' + distributorMap);

        Map<String,Schema.RecordTypeInfo> purchaseOrderRTByName = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName();
        set<string> distributorNames = new set <string>();
        
        //Map<Id,String> distAccountsMap = New Map<Id,String>();WCH 21/05/2020 C-003735 commented this section
        Map<String, Id> distNameIdMap = new Map<String, Id>();
        map<string,Id> groupMap = new map <string,Id>();
        //AMI 09/08/17 - returned results
        map <string,PurchaseOrder__c> mapSuccessfullPOUpsertKeyPO = new map <string,PurchaseOrder__c>();

        //list<AccountShare> accountShareToBeInserted = new list<AccountShare>();WCH 21/05/2020 C-003735 commented this section
        List<PurchaseOrder__c> listOrdersToInsert = new List<PurchaseOrder__c>();

        //WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly
        map<String,set<String>> distIDMapPartList = new map<String,set<String>>();
        for(PartList__c thePT :[select Id,Type__c,Distributors__c from PartList__c where Assessment__c =: ass.Id]){
            system.debug('thePT>>'+thePT);
            if(!String.isBlank(thePT.Distributors__c)){
                if(!distIDMapPartList.containskey(thePT.Distributors__c)){
                    distIDMapPartList.put(thePT.Distributors__c,new Set<String>{thePT.Type__c});
                }else{
                    distIDMapPartList.get(thePT.Distributors__c).add(thePT.Type__c);
                    
                }
            }
        }
        
        //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
        map<String,DirectOrder__c> DistributorMapDO=new map<String,DirectOrder__c>();
        //WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly. add field Part_Type__c
        for(DirectOrder__c DOs :[select Id,name,Type__c,Priority__c,Distributor__c,Part_Type__c from DirectOrder__c where Id in : DirectOrders]){
            DistributorMapDO.put(DOs.Distributor__c+'-'+DOs.Id,DOs);
        }

        //AMI 09/08/17 - upsert PO
        Schema.SObjectField POExternalId = PurchaseOrder__c.Fields.Tech_ExternalId__c;
        List<Database.upsertResult> uResults;

        // 24/02/2016 DUN case 1496 - replace account name by account reference number
        for(Account dis : [select Id,Name, ReferenceNumber__c,Categories__c
                            from Account 
                            where Id in :distributors]){
            if(dis.ReferenceNumber__c != null){
                distributorNames.add(dis.ReferenceNumber__c);
                /* distAccountsMap.put(dis.Id,dis.ReferenceNumber__c); *///WCH 21/05/2020 C-003735 commented this section
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
        //RLA  C-002868
        Assessment__c assess = [select Id, TECH_EntityCountryCode__c,TechDistAndDirectOrder__c from Assessment__c where Id =: ass.Id];
        countryCode = assess.TECH_EntityCountryCode__c;
        //Map<String, String> mapDistributorsPriority = buildMapDisPrio(assess.TECH_EntityCountryCode__c);
        Map<string, string> mapDistributorsPrioritysorted = new map<String, String>();
        //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
        Map<String, String> mapDistributorsPriority = buildMapDisPrio(ass.TechDistAndDirectOrder__c);

        system.debug('### mapDistributorsPriority>>'+mapDistributorsPriority);
        //system.debug('### setDistributorsPriorities>>'+setDistributorsPriorities);
        if (mapDistributorsPriorities.size() > 0){
            for (string dis: mapDistributorsPriorities.keyset()){

                List<string> lstSorted = mapDistributorsPriorities.get(dis);
                lstSorted.sort();

                system.debug(lstsorted);
                mapDistributorsPrioritysorted.put(dis,lstSorted[0]);
            }

        }
        system.debug('### mapDistributorsPrioritysorted>>'+mapDistributorsPrioritysorted);


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
        system.debug('## DistributorMapDO:'+DistributorMapDO);
        system.debug('## distIDMapPartList:'+distIDMapPartList);
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
                Tech_ExternalId__c = String.valueOf(ass.id) + String.valueOf(dis.id),
                //DUN 1837 02/07/2018
                Current_Priority__c = priorityValue, 
                AgencyMode__c = AgencyDistributorIds.contains(dis.Id)
            );

            //AMI 09/08/17 - PO creation through SAS
            if(setDistIdWithSASInfo != null && setDistIdWithSASInfo.contains(dis.id) && lastCallMade != null){
                newOrder.wsDate__c = system.now();
                newOrder.wsErrorMessage__c = '';
            }//end if setDistIdWithSASInfo.contains(dis.id)
            else if(lastCallMade != null && distributorMap.containsKey(dis.id)){
                newOrder.wsDate__c = system.now();
                newOrder.wsErrorMessage__c = string.isNotBlank(errorReported) ? ((errorReported.length() > 1000) ? system.label.DistributorWSNoInfo : errorReported)  : system.label.DistributorWSNoInfo; 
            }
            //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
            String rulesAppliedDescription = '';

            //RLA 09/11/2018 
            String newPriority = '';
            system.debug('## dis.Id:'+dis.Id);
            for(String distIdDOId : DistributorMapDO.keySet()){
                if(distIdDOId.contains(dis.Id)){
                    //system.debug('## distIDMapPartList.get((String)dis.Id):'+distIDMapPartList.get((String)dis.Id));
                    //system.debug('## DistributorMapDO.get(distIdDOId):'+DistributorMapDO.get(distIdDOId));
                    //system.debug('## mapDistributorsPriority.get(distIdDOId):'+mapDistributorsPriority.get(distIdDOId));
                    system.debug('## priorityValue:'+priorityValue);
                    
                    //WCH 20181121 : C-002868 : additional check on PO to be created priority value
                    if (distIDMapPartList.containskey((String)dis.Id) && distIDMapPartList.get((String)dis.Id).removeAll(new Set<String>(DistributorMapDO.get(distIdDOId).Part_Type__c.split(';'))) &&//WCH 06/02/2019 C-002950 In the PO, the field "Rules Applied Description" is not displayed correctly && mapDistributorsPriority.containskey(distIdDOId)
                        mapDistributorsPriority.get(distIdDOId) == DistributorMapDO.get(distIdDOId).Priority__c 
                        /*&& mapDistributorsPriority.get(distIdDOId)==priorityValue WCH 06/02/2019 C-002950 commented code*/){ //RLA  C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                        rulesAppliedDescription += 'Name of record:' + DistributorMapDO.get(distIdDOId).Name +
                                                    '\nType de sourcing:' + DistributorMapDO.get(distIdDOId).Type__c +
                                                    '\nPriority:' + DistributorMapDO.get(distIdDOId).Priority__c + '\n';
                        newPriority = mapDistributorsPriority.get(distIdDOId);//RLA 09/11/2018
                    }
                }
            }
            system.debug('## newPriority:'+newPriority);
            system.debug('## rulesAppliedDescription:'+rulesAppliedDescription);

            newOrder.TECHRulesAppliedDescription__c = rulesAppliedDescription;
            //RLA 09/11/2018
            newOrder.Current_Priority__c = newPriority != '' ? newPriority : newOrder.Current_Priority__c;
            listOrdersToInsert.add(newOrder);
            system.debug('## listOrdersToInsert:'+listOrdersToInsert);
            //WCH 21/05/2020 C-003735 commented this section
            /*//NEW DEV 01/12/2015 PRIVATE SHARING
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

            // system.debug('## setQueriedPOId ' + setQueriedPOId);
            if(setQueriedPOId.size() > 0){
                //query po and build mapSuccessfullPOUpsertKeyPO
                for(PurchaseOrder__c PO : [select id,Name,Tech_ExternalId__c,Status__c,Distributor__c,Assessment__c,
                                            wsDate__c,wsErrorMessage__c,Manual_Creation__c,Rebate__c
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
        
        system.debug('## accountShareToBeInserted ' + accountShareToBeInserted);

        if((string.isBlank(formattedLicenseName) ||
           (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((userType).toLowerCase()))) &&
           accountShareToBeInserted.size()>0
        ){
            //NEW DEV 01/12/2015 PRIVATE SHARING
            insert accountShareToBeInserted;
        } */

        system.debug('## mapSuccessfullPOUpsertKeyPO ' + mapSuccessfullPOUpsertKeyPO);
        //AMI 09/08/17 - return successful PO information
        return mapSuccessfullPOUpsertKeyPO;
    }

    //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
    public static map<String,String> buildMapDisPrio (String disDirectOrders){
        system.debug('START buildMapDisPrio>>>'+disDirectOrders);
        map<String,String> mapDisPrio = new map<String,String>();
        if (String.isNotBlank(disDirectOrders)){
            List<String> listIndidisDirectOrders = disDirectOrders.split(',');
            for (string s :listIndidisDirectOrders){
                List<String> lst2 = s.split(':');
                string prio = '';
                for (integer i = 0; i< lst2.size(); i++){
                    if (math.mod(i,2) == 0){
                        prio = lst2[i];
                        prio = removeBracket(prio);
                    }
                    else{
                        if(lst2[i].contains(';')){
                            list<String> lst3 = (lst2[i]).split(';');
                            for (string disandDO : lst3){
                                disandDO = removeBracket(disandDO);
                                mapDisPrio.put(disandDO,prio); 
                                if (mapDistributorsPriorities.containskey(disandDO.split('-')[0])){
                                    mapDistributorsPriorities.get(disandDO.split('-')[0]).add(prio);

                                }
                                else{
                                    mapDistributorsPriorities.put(prio+'-'+disandDO.split('-')[0], new list<String> {prio});                                    
                                }
                            }
                        }else{
                            //list<String> lst4 = (lst2[i]).split('-');
                            mapDisPrio.put(removeBracket(lst2[i]),prio);
                            //system.debug('## dis2: '+(lst2[i]).split('-')[0] );
                            if (mapDistributorsPriorities.containskey(lst2[i].split('-')[0])){
                                mapDistributorsPriorities.get(lst2[i].split('-')[0]).add(prio);

                            }
                            else{
                                mapDistributorsPriorities.put(lst2[i].split('-')[0], new list<String> {prio});                                    
                            }
                        }
                    }
                }

            }
        }

        system.debug('## mapDisPrio: '+mapDisPrio);
        system.debug('END buildMapDisPrio');
        return mapDisPrio;
    }

    public static string removeBracket (string stringToRemove){
        string returnString = stringToRemove;

        if (returnString.contains('{')){
            returnString =  returnString.remove('{');
        }
        if (returnString.contains('}')){
            returnString = returnString.remove('}');
        }
        return returnString;
    }

    public static map<String, String> buildmapDistPrio (String capturedDistibutors){
        system.debug('START BuildmapDistPrio>>>'+capturedDistibutors);

         map<String,String> mapDistPrio = new map<String,String>();
        if (String.isNotBlank(capturedDistibutors)){
            List<String> listdisprio = capturedDistibutors.split(';');
            for (String disPrio : listdisprio){
                mapDistPrio.put(((disPrio.split('-'))[0]), ((disPrio.split('-'))[1]));
            }
        }



        system.debug('End BuildmapDistPrio>>>'+mapDistPrio);
        return mapDistPrio;


    }

}