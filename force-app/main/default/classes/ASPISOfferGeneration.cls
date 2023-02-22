/*************************************************************************************
Class Name - ASPISOfferGeneration
Version - 1.0
Created Date - 04 MAY 2015
Function - Class for Offer Generation using rules engine

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole         04/05/2015  Original Version
* yudish Ramdowar       10/06/2015  creation of case
* yudish Ramdowar       16/06/2015  Globalize the creation of the Case in a separate class
* Dourga Unmole         19/06/2015  Modification of opportunity type
* Dourga Unmole         12/08/2015  updating for opportunity type
* Brayan Nunhuck        07/01/2016  mapping SHipping BS on SalesOrder C-001435
* Dourga Unmole         19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Dourga Unmole         12/02/2016  C-001522: Clarifications sur les rejets et annulations des commandes
* Dourga Unmole         19/02/2016  C-001520: Automatic validation of SO
* Dourga Unmole         18/03/2016  C-001570: Unsuppliable parts on SO
* ABT                   17/06/2016  C-001629: Removed label.OFFERUNSUPPLIEABLEITEM in the type of the offers (line 511,564,585)
* ABT                   08/07/2016  C-001629: Added check if orderline of offer is suppliable before setting accepted check to true (line 673)
* Dourga Unmole         22/02/2017  C-001823: OrderMakeSelection  
* Dourga Unmole         22/02/2017  C-001914: run preselection after the quotation (ticket 186)  
* Ashwina Seetaram      12/07/2019  C-003320: conflict b/w preOffering and BEMultisourcing because TECH_OrderedCounter__c is incremented and 
                                              and OrderMakeSelection page, the prechecked offers are unchecked. Commenting line where 
                                              TECH_OrderedCounter__c = 1.
* Welsa Chan            29/11/2019  C-003491: Cancelation reason in the SO should be displayed in native langue for users in each country  
* Welsa Chan            18/05/2020  C-003728 - AlphaStore for FR Covid-19  
*************************************************************************************/
public without sharing class ASPISOfferGeneration {
   
    // * days   * hours * minutes   * seconds
    //  * 24     * 60    * 60        * 1000L
    //Global Varaible Declaration
    private Static LONG DURATIONINHOURS = 60 * 60 * 1000L;
    private Static LONG DURATIONINMINUTES = 60 * 1000L;

    private final Static String OBJECTCODE = '-ASS';
    private final Static String PROCESSDELIVERYPROBLEM = '-Offering';
    
    //method to excute the offering process
    public void executeProcess(sObject obj){

        //Varaible Declaration
        map <Id,AggregateResult> mapPOAggResult = new map <Id,AggregateResult>();
        map <Id,map <Id,AggregateResult>> mapPLmapOLAggResult = new map <Id,map <Id,AggregateResult>>();
        map <Id,AggregateResult> mapPOFiltered = new map <Id,AggregateResult>();
        map <Id,AggregateResult> mapPOFilterResult = new map <Id,AggregateResult>();
        map <String,list<Id>> mapProcessPOResultPL = new map <String,list<Id>>();
        map <String,Id> mapProcessPOResult = new map <String,Id>();
        map <Id,list<OrderLine__c>> mapPOOL = new map <Id,list<OrderLine__c>>();
        map <Id,PurchaseOrder__c> mapIdPO = new map <Id,PurchaseOrder__c>();
        map <Id,list<OrderLine__c>> mapPOOLFiltered = new map <Id,list<OrderLine__c>>();
        map <String,Double> mapProcessDisplay = new map <String,Double>();
        list <DetailRule__c> listCriteria = new list <DetailRule__c>();
        list <Offer__c> listOffers2Insert = new List<Offer__c>();
        list <Offer__c> listOffersBundle2Insert = new List<Offer__c>();
        list <Id> listPOFiltered = new list <Id>();
        list <String> aliasFields = new list <String>();
        list <Id> listMRuleId = new list <Id>(); 
        list <Id> listId = new list <Id>(); 
        list <Id> listOlId = new list <Id>();
        set <Id> setPoIdDraftQuote = new set <Id>();
        list <PrerequisiteOrder__c> listPreOrder= new list <PrerequisiteOrder__c>();
        list <PurchaseOrder__c> listPO= new list <PurchaseOrder__c>();
        list <PurchaseOrder__c> listPONoSO= new list <PurchaseOrder__c>();
        //list <PurchaseOrder__c> listPOUpdate= new list <PurchaseOrder__c>();
        string queryOffer = '', aggFields = '', objectToQuery = '', groupBy = '', typeOffer = '', aId = '', issuedPo = '', respondedPo = '' , groupBy1 = '', groupBy2 = '';
        Id pOIdToQuery; 
        Integer countOffer = 0, countgroupby = 1;
        List<Case__c> l_casesToInsert = new List<Case__c>();
        list<AggregateResult> aggRList = new list<AggregateResult>();
        boolean suppliable = false;
        //DUN 12/08
        map <String,list<OrderLine__c>> mapProcessOfferList = new map <String,list<OrderLine__c>>();
        map <String,Double> mapProcessThresholdValue = new map <String,Double>();
        boolean usePartlist = false;
        boolean thresholdComparison = false;
        Double thresholdDifference = 0;
        Double thresholdValue = 0;
        String thresholdsProcess = '';
        String thresholdsObject = '';
        String thresholdField = '';
        String thresholdFieldQuery = '';
        String thresholdFieldExpression = '';
        String thresholdAggregateFunction = '';
        String thresholdQuery = '';
        //case 1520 
        map <Decimal,String> displayPriorityOfferType = new map <Decimal,String>();
        //C-001570
        map<Id,OrderLine__c> mapPartIdUnsuppOL = new map<Id,OrderLine__c>();
        map<String,map<Id,OrderLine__c>> mapProcessPartIdSuppOL = new map<String,map<Id,OrderLine__c>>();

        //ASE: 12/07/19 : C-003320
        /*//DUN 22/02/2017  C-001914 map of partlist parent with tech_OrderedCounter to update 
        map<Id,PartList__c> mapPLParentToUpdate = new map<Id,PartList__c>();*/

        Assessment__c ass = (Assessment__c) obj;
        aId =(string)ass.Id;
        issuedPo = 'ISSUED';        
        respondedPo = 'RESPONDED';      // CLA : older value = ISSUED. has to modified because at the first passage, the PO is still in RESPONDED status. but when the PO become ISSUED, the Assessment status has already change to OFFERING and don't pass in this method from the trigger (because its status has not change from the previous one).
        //system.debug('## ass'+ ass);
        //system.debug('## assBodyShopCountryCode'+ ass.TECH_EntityCountryCode__c);
        //system.debug('## assEntityRules__c'+ ass.EntityRules__c);
        //system.debug('## countgroupby ' + countgroupby);

        //Query order lines for opportunity offer
        // ABT - 16-FEB-2017 - C-001816 - Added CancelReason__c in the select -> to be used to sync the orderline with unsuppliable offers
        Map<Id, OrderLine__c> mapIdOL = new Map<Id, OrderLine__c>([ SELECT  Id, Name, TECHIsSuppliable__c, PartList__c
                                                                    , toLabel(CancelReason__c)//WCH 29/11/2019  C-003491
                                                                    FROM    OrderLine__c 
                                                                    WHERE   PurchaseOrder__r.Assessment__c =: ass.Id]);

        //loop through master rules to find master rule with process offering and entity of assessment
        //DUN 12/08 added fields in select
        for(MasterRules__c masRule :[SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                            DifferenceThreshold__c, NeedThresholdComparison__c, sObject__c, 
                                            FieldComparison__c, AggregateFunctionComparison__c,
                                            (SELECT Id, Entity__c, Process__c, RuleStatus__c
                                             FROM MasterRules__r )
                                    FROM MasterRules__c
                                    WHERE Process__c    =: 'Offering'
                                    AND Entity__c       =: ass.EntityRules__c
                                    AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL ]){
            //system.debug('## masRule.RecordType.DeveloperName'+ masRule.RecordType.DeveloperName);
            //DUN 12/08
            thresholdComparison = masRule.NeedThresholdComparison__c;
            thresholdDifference = masRule.DifferenceThreshold__c;
            thresholdsObject = masRule.sObject__c;
            thresholdField = masRule.FieldComparison__c;
            thresholdAggregateFunction = masRule.AggregateFunctionComparison__c;
            if(masRule.RecordType.DeveloperName == 'RULESET' && masRule.MasterRules__r != null && masRule.MasterRules__r.size() > 0){
                for(MasterRules__c mr : masRule.MasterRules__r){
                    listMRuleId.add(mr.Id);
                }
            }
            else{
                listMRuleId.add(masRule.Id);
            }
        }

        //Looping through types of offering process (quick, basic, ...) and build the criterias
        for(MasterRules__c masRule :[SELECT Id, Entity__c, Process__c, RuleStatus__c, DisplayPriority__c, IsPrimary__c, 
                                            (SELECT Id, Name, RecordType.DeveloperName, Number__c, sObject__c, 
                                            MasterRule__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Alias__c
                                            FROM DetailRules__r
                                            ORDER BY Number__c)
                                    FROM MasterRules__c
                                    WHERE Id IN: listMRuleId
                                    AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL]){
            aggFields = '';
            system.debug('## masRule' +masRule);
            if(masRule.DetailRules__r != null){
                displayPriorityOfferType.put(masRule.DisplayPriority__c,masRule.Process__c);
                mapProcessDisplay.put(masRule.Process__c ,masRule.DisplayPriority__c);
                listCriteria = new list <DetailRule__c>();
                mapPOAggResult = new map <Id,AggregateResult>();
                mapPOFilterResult = new map <Id,AggregateResult>();
                aliasFields = new list <String>();
                listId = new list <Id>();
                countgroupby = 1;
                //DUN 12/08
                usePartlist = false;
                thresholdValue = 0;
                for(DetailRule__c detRule : masRule.DetailRules__r){
                    if(detRule.RecordType.DeveloperName == 'AggregateCriteria'){
                        aliasFields.add(detRule.Alias__c);
                        if(detRule.Operator__c == 'AGMAX')
                            aggFields += 'MAX('+detRule.FieldsAPI__c+')'+detRule.Alias__c+',';
                        else if(detRule.Operator__c == 'AGAVG')
                            aggFields += 'AVG('+detRule.FieldsAPI__c+')'+detRule.Alias__c+',';
                        else if(detRule.Operator__c == 'AGSUM')
                            aggFields += 'SUM('+detRule.FieldsAPI__c+')'+detRule.Alias__c+',';
                        else if(detRule.Operator__c == 'AGCOUNT')
                            aggFields += 'COUNT('+detRule.FieldsAPI__c+')'+detRule.Alias__c+',';
                        else if(detRule.Operator__c == 'AGMIN')
                            aggFields += 'MIN('+detRule.FieldsAPI__c+')'+detRule.Alias__c+',';
                            
                    }
                    else if(detRule.RecordType.DeveloperName == 'GroupByCriteria'){
                        if(countgroupby == 1){
                            groupBy = detRule.FieldsAPI__c;
                            groupBy1 = detRule.FieldsAPI__c;
                            countgroupby ++; 
                        }
                        else
                            groupBy = groupBy + ',' +detRule.FieldsAPI__c;
                            groupBy2 = detRule.FieldsAPI__c;
                        objectToQuery = detRule.sObject__c;
                    }
                    else if(detRule.RecordType.DeveloperName == 'CRITERIA'){
                        //system.debug('## listCriteria'+ listCriteria);
                        //system.debug('## detRule'+ detRule);
                        listCriteria.add(detRule);
                    }
                    typeOffer = masRule.Process__c;
                }
                //system.debug('## groupBy ' + groupBy);
                //system.debug('## countgroupby ' + countgroupby);
                //Aggregate query
                if(aggFields.length() > 0){
                    queryOffer = 'SELECT ' + groupBy +', '+ aggFields.substring(0,aggFields.length()-1) + ' FROM ' +  objectToQuery + ' WHERE OrderLine__c.PurchaseOrder__r.Assessment__c =:aId AND (Orderline__c.PurchaseOrder__r.status__c =: issuedPo OR Orderline__c.PurchaseOrder__r.status__c =: respondedPo) AND OrderLine__c.PurchaseOrder__r.SuppliableLines__c > 0  AND  OrderType__c = \'FINAL\' GROUP BY ' + groupBy;
                    system.debug('## queryOffer'+ queryOffer);

                    //added by yudish
                    aggRList = Database.query(queryOffer); 
                }

                if(!groupBy.contains(',')){
                    for (AggregateResult orderLineAR : aggRList){
                        //system.debug('zzz'+orderLineAR);
                            if((Id)orderLineAR.get(groupBy) != null){
                                mapPOAggResult.put((Id)orderLineAR.get(groupBy),orderLineAR);
                                setPoIdDraftQuote.add((Id)orderLineAR.get(groupBy));
                            }  
                    }
                    //system.debug('## listCriteria'+ listCriteria);
                    //system.debug('## mapPOAggResult'+mapPOAggResult);


                    if(mapPOAggResult.size() == 1){
                        system.debug('## if');
                        mapPOFilterResult = mapPOAggResult;
                    }
                    //filtering purchase orders if size of result > 1#
                    else if(listCriteria.size() > 0 && mapPOAggResult.size() >= 2){
                        system.debug('## else');
                        //system.debug('## listCriteria ' + listCriteria ); 
                        for(integer i=0; i<listCriteria.size(); i++){
                            //system.debug('##Criteria '+ i + listCriteria[i] );
                            if(i == 0){
                                mapPOFilterResult = filtering(mapPOAggResult,listCriteria[0],aliasFields);
                                //system.debug('##mapPOFilterResult '+ i + mapPOFilterResult);
                            }
                            else{
                                if(mapPOFilterResult.size() == 1){
                                    break;
                                }
                                else if(mapPOFilterResult.size() != null && mapPOFilterResult.size() > 1){
                                    map <Id,AggregateResult> mapPOFilterResultNext = mapPOFilterResult;
                                    mapPOFilterResult = filtering(mapPOFilterResultNext,listCriteria[i],aliasFields);
                                    //system.debug('##mapPOFilterResult '+ i + mapPOFilterResult);
                                }
                            }
                        }
                    }
                    //system.debug('##listId Before'+listId);
                    listId = new list<Id>(mapPOFilterResult.keySet());
                    //system.debug('##listId After'+listId);
                    if(listId.size()>0){
                        mapProcessPOResult.put(masRule.Process__c,listId[0]);
                    }
                }
                else{
                    usePartlist = true;
                    for (AggregateResult orderLineAR : aggRList){
                        //system.debug('zzz'+orderLineAR);
                        if((Id)orderLineAR.get(groupBy1) != null){
                            //mapPOAggResult.put((Id)orderLineAR.get(groupBy2),orderLineAR);
                            if(mapPLmapOLAggResult.containsKey((Id)orderLineAR.get(groupBy1)))
                                mapPLmapOLAggResult.get((Id)orderLineAR.get(groupBy1)).put((Id)orderLineAR.get(groupBy2),orderLineAR);
                            else{
                                map <Id,AggregateResult> newMapIdAgg = new map <Id,AggregateResult>();
                                newMapIdAgg.put((Id)orderLineAR.get(groupBy2),orderLineAR);
                                mapPLmapOLAggResult.put((Id)orderLineAR.get(groupBy1),newMapIdAgg);
                            }
                        }  
                    }
                    //system.debug('## listCriteria'+ listCriteria);
                    //system.debug('## mapPLmapOLAggResult' + mapPLmapOLAggResult);

                    for(Id pLId : mapPLmapOLAggResult.keySet()){
                        if(mapPLmapOLAggResult.get(pLId).size() == 1)
                            mapPOFilterResult = mapPLmapOLAggResult.get(pLId);
                        else if(listCriteria.size() > 0 && mapPLmapOLAggResult.get(pLId).size() >= 2){
                            suppliable = false;
                            mapPOAggResult = new map <Id,AggregateResult>();
                            for(Id olId : mapPLmapOLAggResult.get(pLId).KeySet()){
                                if(mapIdOL.get(olId).TECHIsSuppliable__c == 1){
                                    suppliable = true;
                                    mapPOAggResult.put(olId,mapPLmapOLAggResult.get(pLId).get(olId));
                                }
                            }
                            //system.debug('## suppliable' + suppliable);
                            //system.debug('## mapPOAggResult' + mapPOAggResult);
                            if(suppliable == false){
                                //system.debug('##SppliableFalse');
                                mapPOFilterResult = mapPLmapOLAggResult.get(pLId);
                            }
                            else{
                                for(integer i=0; i<listCriteria.size(); i++){
                                    //system.debug('##Criteria '+ i + listCriteria[i] );
                                    if(i == 0){
                                        mapPOFilterResult = filtering(mapPOAggResult,listCriteria[0],aliasFields);
                                        //system.debug('##mapPOFilterResult '+ i + mapPOFilterResult);
                                    }
                                    else{
                                        if(mapPOFilterResult.size() == 1){
                                            break;
                                        }
                                        else if(mapPOFilterResult.size() != null && mapPOFilterResult.size() > 1){
                                            map <Id,AggregateResult> mapPOFilterResultNext = mapPOFilterResult;
                                            mapPOFilterResult = filtering(mapPOFilterResultNext,listCriteria[i],aliasFields);
                                            //system.debug('##mapPOFilterResult '+ i + mapPOFilterResult);
                                        }
                                    }
                                }
                            }
                        }
                        //system.debug('##listId Before'+listId);
                        listId = new list<Id>(mapPOFilterResult.keySet());
                        //system.debug('##listId After'+listId);
                        if(listId.size()>0){
                            listOlId.add(listId[0]);
                        }
                    }
                    if(listOlId.size()>0){
                        mapProcessPOResultPL.put(masRule.Process__c,listOlId);
                    }
                }
            }
            //DUN 12/08 only one field 
            if(thresholdComparison){
                if(masRule.IsPrimary__c){
                    thresholdsProcess = masRule.Process__c;
                }
                thresholdFieldExpression = thresholdField + 'Expr';
                if(thresholdAggregateFunction == 'SUM')
                    thresholdFieldQuery = 'SUM(' + thresholdField + ')'+ thresholdFieldExpression;
                else if(thresholdAggregateFunction == 'MIN')
                    thresholdFieldQuery = 'MIN(' + thresholdField + ')'+ thresholdFieldExpression;
                else if(thresholdAggregateFunction == 'MAX')
                    thresholdFieldQuery = 'MAX(' + thresholdField + ')'+ thresholdFieldExpression;
                else if(thresholdAggregateFunction == 'COUNT')
                    thresholdFieldQuery = 'COUNT(' + thresholdField + ')'+ thresholdFieldExpression;

                if(usePartlist){
                    if(listOlId.size()>0){
                        thresholdQuery = 'SELECT ' + thresholdFieldQuery + ' FROM ' + thresholdsObject + ' WHERE Id IN: listOlId GROUP BY Id' ;
                        //system.debug('##thresholdQuery '+thresholdQuery);
                        for (AggregateResult orderLineAR : Database.query(thresholdQuery)){
                            //system.debug('## orderLineAR'+orderLineAR);
                            if((Double)orderLineAR.get(thresholdFieldExpression) >= 0){
                                if(thresholdAggregateFunction == 'SUM' || thresholdAggregateFunction == 'COUNT')
                                    thresholdValue += (Double)orderLineAR.get(thresholdFieldExpression);
                                else if(thresholdAggregateFunction == 'MIN'){
                                    if((Double)orderLineAR.get(thresholdFieldExpression) < thresholdValue)
                                        thresholdValue += (Double)orderLineAR.get(thresholdFieldExpression);
                                }
                                else if(thresholdAggregateFunction == 'MAX'){
                                    if((Double)orderLineAR.get(thresholdFieldExpression) > thresholdValue)
                                        thresholdValue += (Double)orderLineAR.get(thresholdFieldExpression);
                                }
                            }  
                        }
                    }
                }
                else{
                    if(listId.size() > 0){
                        Id queryId = listId[0];
                        thresholdQuery = 'SELECT ' + thresholdFieldQuery + ' FROM ' + thresholdsObject + ' WHERE OrderLine__c.PurchaseOrder__r.Id =: queryId GROUP BY OrderLine__c.PurchaseOrder__r.Id';
                        //system.debug('##thresholdQuery '+thresholdQuery);
                        for (AggregateResult orderLineAR : Database.query(thresholdQuery)){
                            //system.debug('## orderLineAR'+orderLineAR);
                            if((Double)orderLineAR.get(thresholdFieldExpression) >= 0){
                                thresholdValue = (Double)orderLineAR.get(thresholdFieldExpression);
                            }  
                        }
                    }
                }
                mapProcessThresholdValue.put(masRule.Process__c,thresholdValue);
            }
        }

        //system.debug('## aggRList'+ aggRList.size());
        //system.debug('## mapProcessPOResult'+ mapProcessPOResult);
        //system.debug('## mapProcessPOResultPL'+ mapProcessPOResultPL);
        //system.debug('## mapProcessThresholdValue'+ mapProcessThresholdValue);
        //added by yudish
        if(aggRList.size()==0){
            
            Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, ass.TECH_EntityCountryCode__c, ass.BodyShop__c, ass.Id, null, null, null, UserInfo.getUserId(), PROCESSDELIVERYPROBLEM);

            if(newCase!=null){
                l_casesToInsert.add(newCase);
            }
            
            if(l_casesToInsert.size()>0){
                insert l_casesToInsert;
            }
            //system.debug('## l_casesToInsert'+ l_casesToInsert);
        }

        //C-001570
        for(OrderLine__c ol:mapIdOL.values()){
            if(!mapPartIdUnsuppOL.containsKey(ol.PartList__c) && ol.TECHIsSuppliable__c == 0){
                mapPartIdUnsuppOL.put(ol.PartList__c,ol);
            }
        }

        //system.debug('## setPoIdDraftQuote'+ setPoIdDraftQuote);
        //system.debug('## mapPOFilterResult'+ mapPOFilterResult);
        //system.debug('## mapProcessPOResult'+ mapProcessPOResult);

        //selecting purchase orders with status DRAFTQUOTE 
        for(PurchaseOrder__c po: [SELECT Id, PrerequisiteOrder__c, Status__c, Reason__c
                                 FROM PurchaseOrder__c
                                 WHERE Assessment__c =:ass.Id
                                 AND Status__c = 'DRAFTQUOTE']){
            //system.debug('## po.Status__c'+ po.Status__c);
            //****** ASE 13/10/15: C-001272******* po.Status__c = 'QUOTETIMEOUT';
            //po.Status__c = 'REJECTED';
            //po.Reason__c = 'QUOTETIMEOUT';

            //DUN 12/02/2016  C-001522 commented the above three lines and added the code below
            po.Status__c = 'CANCELED';
            po.Reason__c = 'QUOTETIMEOUT';

            //listPOUpdate.add(po);
            mapIdPO.put(po.Id,po);
            //system.debug('## po'+po);
            
        }
        //DUN 12/08 
        for(String process : mapProcessThresholdValue.keySet()){
            if(process != thresholdsProcess){
                //system.debug('## mapProcessThresholdValue'+mapProcessThresholdValue);
                //system.debug('## process'+process);
                //system.debug('## thresholdsProcess'+thresholdsProcess);
                //system.debug('## thresholdDifference'+ thresholdDifference);
                if(mapProcessPOResult.containsKey(process)){
                    if(math.abs((mapProcessThresholdValue.get(process)))-math.abs((mapProcessThresholdValue.get(thresholdsProcess))) < 
                    (math.abs(mapProcessThresholdValue.get(thresholdsProcess))*(thresholdDifference/100))){
                        mapProcessPOResult.remove(process);
                    }
                    else if((mapProcessThresholdValue.get(process)) == 0 && (mapProcessThresholdValue.get(thresholdsProcess)) == 0){
                        mapProcessPOResult.remove(process);
                    }
                }
                else if(mapProcessPOResultPL.containsKey(process)){
                    if(math.abs((mapProcessThresholdValue.get(process)))-math.abs((mapProcessThresholdValue.get(thresholdsProcess))) < 
                    (math.abs(mapProcessThresholdValue.get(thresholdsProcess))*(thresholdDifference/100))){
                        mapProcessPOResultPL.remove(process);
                    }
                    else if((mapProcessThresholdValue.get(process)) == 0 && (mapProcessThresholdValue.get(thresholdsProcess)) == 0){
                        mapProcessPOResultPL.remove(process);
                    }
                }
            }
        }
        //selecting all orderlines which are obtained after filtering
        // ABT - 16-FEB-2017 - C-001816 - Added CancelReason__c in the select -> to be used to sync the orderline with unsuppliable offers
        for(OrderLine__c ol : [ SELECT  Id , Suppliable__c , PurchaseOrder__c, OrderType__c, PartList__c
                                        , toLabel(CancelReason__c)/* WCH 29/11/2019  C-003491 */,
                                        PartList__r.OriginalPart__c, PartList__r.OriginalPart__r.TECH_OrderedCounter__c ,
                                        (SELECT Id , Suppliable__c , OrderType__c
                                        FROM AlternativeItem__r)
                                FROM    OrderLine__c
                                WHERE   PurchaseOrder__c in: mapProcessPOResult.values()
                                AND     OrderType__c = 'FINAL']){
            //system.debug('## ol' + ol);
            if(mapPOOLFiltered.containsKey(ol.PurchaseOrder__c))
                mapPOOLFiltered.get(ol.PurchaseOrder__c).add(ol);
            else
                mapPOOLFiltered.put(ol.PurchaseOrder__c,new list<OrderLine__c>{ol});
        } 
        //system.debug('## mapPOOLFiltered'+ mapPOOLFiltered);

        if(mapPOOLFiltered.size() > 0){
            countOffer = mapPOOLFiltered.size();
        }
        else if(mapProcessPOResultPL.size() > 0){
            countOffer = mapProcessPOResultPL.size();
        }
        //system.debug('## countOffer'+ countOffer);

        if(countOffer > 0){
            //creating sales order if does not already exist
            //listPreOrder = [SELECT Id, Assessment__c, Bodyshop__c FROM PrerequisiteOrder__c WHERE Assessment__c =:ass.Id and ];
            //if(listPreOrder.size() == 0){
                listPreOrder.add(new PrerequisiteOrder__c(assessment__c = ass.id, 
                                                          bodyshop__c = ass.bodyshop__c,
                                                        //  ShippingBS__c = ass.ShippingBS__c,
                                                          status__c = system.Label.PREORDERINACCEPTANCESTATUS, 
                                                          RecordTypeID = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId()));
            //system.debug('####### CLA listPreOrder '+listPreOrder);
                insert listPreOrder;
                obj.put('OrderStatus__c',system.Label.PREORDERINACCEPTANCESTATUS);

            //}
            //system.debug('## listPreOrder'+ listPreOrder);

            for(Id po : mapPOOLFiltered.KeySet()){
                PurchaseOrder__c poNew = new PurchaseOrder__c(Id=po, PrerequisiteOrder__c = listPreOrder[0].id);
                //system.debug('## poNew '+poNew);
                /*if(mapIdPO.containsKey(po)){
                    system.debug('## poStatus '+ po);
                    poNew.Status__c = mapIdPO.get(po).Status__c;
                }*/
                mapIdPO.put(po,poNew);

                //listPOUpdate.add(poNew);
                for(OrderLine__c ol : mapPOOLFiltered.get(po)){
                    if(mapPOOL.containsKey(ol.PurchaseOrder__c))
                        mapPOOL.get(ol.PurchaseOrder__c).add(ol);
                    else
                        mapPOOL.put(ol.PurchaseOrder__c,new list<OrderLine__c>{ol});
                }
            }
            //system.debug('## mapIdPO ' + mapIdPO);
            
            //system.debug('## mapPOOL '+mapPOOL);
            //system.debug('## mapProcessPOResult '+mapProcessPOResult);
            //system.debug('## mapProcessPOResult '+mapProcessPOResult.keySet());

            //creating offers  
            for(String process : mapProcessPOResult.keySet()){
                if(mapPOOL.containsKey(mapProcessPOResult.get(process))){
                    //system.debug('## pOId ' +mapProcessPOResult.get(process));
                    for(OrderLine__c ol :mapPOOL.get(mapProcessPOResult.get(process))){
                        //system.debug('## ol ' +ol);
                        //system.debug('## ol.Suppliable__c ' +ol.Suppliable__c);
                        if(ol.Suppliable__c == 'YES'){
                            //system.debug('## Suppliable__c YES');
                            Offer__c parentOffer = new Offer__c(PrerequisiteOrder__c = listPreOrder[0].id,OrderLine__c= ol.id,Suppliable__c = TRUE, OfferReference__c = String.ValueOf(System.now())+String.ValueOf(math.random()) ,Type__c=process,DisplayPriority__c=mapProcessDisplay.get(process));
                            //DUN 12/05/2017 case 1914 run preselection after the quotation(ticket 186)
                            if(ol.PartList__r.OriginalPart__c != null && ol.PartList__r.OriginalPart__r.TECH_OrderedCounter__c == 0 && ass.OrderOrigin__c == 'Quotation' && ass.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()){
                                parentOffer.Accepted__c = 'YES';
                                //ASE: 12/07/19 : C-003320
                                /*if(!mapPLParentToUpdate.containsKey(ol.PartList__r.OriginalPart__c)){
                                    mapPLParentToUpdate.put(ol.PartList__r.OriginalPart__c,new PartList__c(Id = ol.PartList__r.OriginalPart__c, TECH_OrderedCounter__c = 1));
                                }*/
                            }
                            listOffers2Insert.add(parentOffer);
                            Offer__c parentOfferExt = new Offer__c(OfferReference__c = parentOffer.OfferReference__c);
                            if(ol.AlternativeItem__r != null || ol.AlternativeItem__r.size() > 0){
                                for(OrderLine__c olChild : ol.AlternativeItem__r){
                                    listOffersBundle2Insert.add( new Offer__c(ParentOffer__r = parentOfferExt, Accepted__c = (parentOffer.Accepted__c == 'YES' ? 'YES' : null), PrerequisiteOrder__c = listPreOrder[0].id,OrderLine__c= olChild.id,Suppliable__c = TRUE, Type__c=process,DisplayPriority__c=mapProcessDisplay.get(process)));
                                }
                            }
                        }
                        else if(ol.Suppliable__c == 'NO' || ol.Suppliable__c == null){
                            //system.debug('## Suppliable__c NO');
                            // ABT - 16-FEB-2017 - C-001816 - Added the CancelReason__c for the unsuppliable lines
                            Offer__c parentOffer = new Offer__c(PrerequisiteOrder__c    = listPreOrder[0].Id,
                                                                OrderLine__c            = ol.Id,
                                                                OfferReference__c       = String.ValueOf(System.now()) + String.ValueOf(math.random()),
                                                                Type__c                 = process,
                                                                DisplayPriority__c      = mapProcessDisplay.get(process),
                                                                CancelReason__c         = ol.CancelReason__c);
                            listOffers2Insert.add(parentOffer);
                            // Offer__c parentOfferExt = new Offer__c(OfferReference__c = parentOffer.OfferReference__c);
                            //As bundle is not applicable for unsuppliable lines.
                            /*if(ol.AlternativeItem__r != null || ol.AlternativeItem__r.size() > 0){
                                for(OrderLine__c olChild : ol.AlternativeItem__r){
                                    listOffersBundle2Insert.add( new Offer__c(ParentOffer__r = parentOfferExt, PrerequisiteOrder__c = listPreOrder[0].id,OrderLine__c= olChild.id,Type__c='UNSUPPLIEABLE'+process,DisplayPriority__c=mapProcessDisplay.get(process)));
                                }
                            }*/
                        }
                        //case C-001570
                        if(mapProcessPartIdSuppOL.containsKey(process)){
                            if(!mapProcessPartIdSuppOL.get(process).containsKey(ol.PartList__c)){
                                mapProcessPartIdSuppOL.get(process).put(ol.PartList__c,ol);
                            }
                        }
                        else{
                            map <Id,OrderLine__c> mapIdOrdLine = new map <Id,OrderLine__c>();
                            mapIdOrdLine.put(ol.PartList__c,ol);
                            mapProcessPartIdSuppOL.put(process,mapIdOrdLine);
                        }
                    }
                }
            }
            ////DUN 12/08
            //system.debug('listOlId'+listOlId);
            //opportunity offer creation
            if(mapProcessPOResultPL.size() != null && mapProcessPOResultPL.size() != 0){
                // ABT - 16-FEB-2017 - C-001816 - Added CancelReason__c in the select -> to be used to sync the orderline with unsuppliable offers
                for(OrderLine__c ol : [ SELECT  Id , Suppliable__c , PurchaseOrder__c, OrderType__c, PartList__c
                                        , toLabel(CancelReason__c)/* WCH 29/11/2019  C-003491 */,
                                                PartList__r.OriginalPart__c, PartList__r.OriginalPart__r.TECH_OrderedCounter__c ,
                                                (SELECT Id, Suppliable__c, OrderType__c
                                                 FROM AlternativeItem__r)
                                        FROM    OrderLine__c
                                        WHERE   Id in: listOlId
                                        AND     OrderType__c = 'FINAL']){
                    //system.debug('## ol' + ol);
                    PurchaseOrder__c poNew = new PurchaseOrder__c(Id=ol.PurchaseOrder__c, PrerequisiteOrder__c = listPreOrder[0].id);
                    //system.debug('## poNew '+poNew);
                    if(!mapIdPO.containsKey(ol.PurchaseOrder__c))
                        mapIdPO.put(ol.PurchaseOrder__c,poNew);
                    for(String process : mapProcessPOResultPL.keySet()){
                        if(ol.Suppliable__c == 'YES'){
                            //system.debug('## Suppliable__c YES');
                            Offer__c parentOffer = new Offer__c(PrerequisiteOrder__c = listPreOrder[0].id,OrderLine__c= ol.id,Suppliable__c = TRUE, OfferReference__c = String.ValueOf(System.now())+String.ValueOf(math.random()) ,Type__c=process,DisplayPriority__c=mapProcessDisplay.get(process));
                            //DUN 12/05/2017 case 1914 run preselection after the quotation(ticket 186)
                            if(ol.PartList__r.OriginalPart__c != null && ol.PartList__r.OriginalPart__r.TECH_OrderedCounter__c == 0 && ass.OrderOrigin__c == 'Quotation' && ass.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()){
                                parentOffer.Accepted__c = 'YES';
                                //ASE: 12/07/19 : C-003320
                                /*if(!mapPLParentToUpdate.containsKey(ol.PartList__r.OriginalPart__c)){
                                    mapPLParentToUpdate.put(ol.PartList__r.OriginalPart__c,new PartList__c(Id = ol.PartList__r.OriginalPart__c, TECH_OrderedCounter__c = 1));
                                }*/
                            }
                            listOffers2Insert.add(parentOffer);
                            Offer__c parentOfferExt = new Offer__c(OfferReference__c = parentOffer.OfferReference__c);
                            if(ol.AlternativeItem__r != null || ol.AlternativeItem__r.size() > 0){
                                for(OrderLine__c olChild : ol.AlternativeItem__r){
                                    listOffersBundle2Insert.add( new Offer__c(ParentOffer__r = parentOfferExt, Accepted__c = (parentOffer.Accepted__c == 'YES' ? 'YES' : null), PrerequisiteOrder__c = listPreOrder[0].id,OrderLine__c= olChild.id,Suppliable__c = TRUE, Type__c=process,DisplayPriority__c=mapProcessDisplay.get(process)));
                                }
                            }
                        }
                        else if(ol.Suppliable__c == 'NO' || ol.Suppliable__c == null){
                            //system.debug('## Suppliable__c NO');
                            // ABT - 16-FEB-2017 - C-001816 - Added the CancelReason__c for the unsuppliable lines
                            Offer__c parentOffer = new Offer__c(PrerequisiteOrder__c    = listPreOrder[0].Id,
                                                                OrderLine__c            = ol.Id,
                                                                OfferReference__c       = String.ValueOf(System.now()) + String.ValueOf(math.random()),
                                                                Type__c                 = process,
                                                                DisplayPriority__c      = mapProcessDisplay.get(process),
                                                                CancelReason__c         = ol.CancelReason__c);
                            listOffers2Insert.add(parentOffer);
                        }                
                        //case C-001570
                        if(mapProcessPartIdSuppOL.containsKey(process)){
                            if(!mapProcessPartIdSuppOL.get(process).containsKey(ol.PartList__c)){
                                mapProcessPartIdSuppOL.get(process).put(ol.PartList__c,ol);
                            }
                        }
                        else{
                            map <Id,OrderLine__c> mapIdOrdLine = new map <Id,OrderLine__c>();
                            mapIdOrdLine.put(ol.PartList__c,ol);
                            mapProcessPartIdSuppOL.put(process,mapIdOrdLine);
                        }
                    }    
                } 
            }
            //case C-001570  
            for(String processType : mapProcessPartIdSuppOL.keySet()){
                for(Id partId : mapPartIdUnsuppOL.keySet()){
                    if(!mapProcessPartIdSuppOL.get(processType).containsKey(partId)){
                        // ABT - 16-FEB-2017 - C-001816 - Added the CancelReason__c for the unsuppliable lines
                        Offer__c parentOffer = new Offer__c(PrerequisiteOrder__c    = listPreOrder[0].Id,
                                                            OrderLine__c            = mapPartIdUnsuppOL.get(partId).Id,
                                                            OfferReference__c       = String.ValueOf(System.now()) + String.ValueOf(math.random()),
                                                            Type__c                 = processType,
                                                            DisplayPriority__c      = mapProcessDisplay.get(processType),
                                                            CancelReason__c         = mapPartIdUnsuppOL.get(partId).CancelReason__c);
                        listOffers2Insert.add(parentOffer);
                    }
                }
            }     
        }
        //system.debug('## listOffers2Insert'+listOffers2Insert);
        //system.debug('## listOffersBundle2Insert'+listOffersBundle2Insert);
        //system.debug('## mapIdPO '+mapIdPO);
        ////system.debug('## listPOUpdate '+listPOUpdate);

        //update purchase order
        if(mapIdPO.size()>0){
            //update listPOUpdate;
            update mapIdPO.values();
            
        }
        
        //selecting purchase order which do not contain salesorders
        for(PurchaseOrder__c po: [SELECT Id, PrerequisiteOrder__c, Status__c
                                 FROM PurchaseOrder__c
                                 WHERE Assessment__c =:ass.Id
                                 AND (Status__c = 'ISSUED'
                                     OR Status__c = 'RESPONDED')
                                 AND SuppliableLines__c > 0 
                                 AND PrerequisiteOrder__c = null]){
            //DUN 12/02/2016  C-001522 change status value from rejected to canceled
            PurchaseOrder__c poNew = new PurchaseOrder__c(Id=po.Id, Status__c = 'CANCELED',Reason__c = 'NOTSELECTED');
            listPONoSO.add(poNew);
            //system.debug('## poNew'+poNew);
            
        }
        //ASE: 12/07/19 : C-003320
        //Updating list of partlist with tech_OrderedCounter
        /*if(mapPLParentToUpdate.size()>0){
            update mapPLParentToUpdate.values();
        }*/
        
        //updating purchase orders which are rejected
        if(listPONoSO.size()>0){
            update listPONoSO;
        }
        //inserting offers which are final
        if(listOffers2Insert.size()>0){
            insert listOffers2Insert;
        }
        //inserting offers which are bundles
        if(listOffersBundle2Insert.size()>0){
            insert listOffersBundle2Insert;
        }

        Account assBodyshop = [Select isEligibleSourcing__c FROM Account where id =: ass.bodyshop__c];

        system.debug('##Automatic so' + displayPriorityOfferType.size()); 
        system.debug('##Automatic so' + assBodyshop.isEligibleSourcing__c);
        system.debug('##Automatic so' + assBodyshop);
        //case 1520 -- Automatic validation of SO
        //getting Country Code Informations from the custom setting according to the entity code of the assessment
        CountryCodeInformationsMapping__c configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(ass.TECH_EntityCountryCode__c);
        //WCH 05/05/2020 C-003728
        boolean isAlphaStore=false;
        boolean isFR=false;
        if(String.isNotBlank(ass.TECH_EntityCountryCode__c) && ass.TECH_EntityCountryCode__c=='FR') isFR=true;
        if(String.isNotBlank(ass.name) && String.isNotBlank(System.label.Refinish) && String.isNotBlank(System.label.Painting) && (ass.name.contains(System.label.Refinish.toUpperCase()) || ass.name.contains(System.label.Painting.toUpperCase()))) isAlphaStore=true;

        //If country must have automatic order
        //system.debug('##Automatic so' + configCountryCodeInfo.AutomaticOrder__c);
        if(((configCountryCodeInfo != null && configCountryCodeInfo.AutomaticOrder__c == true) || (ass.TECH_EntityCountryCode__c == 'DE' && assBodyshop != null && assBodyshop.isEligibleSourcing__c == false)) && !(isAlphaStore && isFR)/*WCH 05/05/2020 C-003728*/ ){ 
            if(displayPriorityOfferType.size()>0 && ass.Id != null && ass.RecordTypeId != Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()){
                System.enqueueJob(new AP29OfferingAutomaticOrderQueueable(displayPriorityOfferType,ass.Id));
                //AP28ShareUserQueueable.shareUser(mapReferenceNumberListOfUser);                    
            }
            
        }
    }

    //@future
    public static void updateOffers(map <Decimal,String> displayPriorityOfferType,Id assId){
        list<Offer__c> offerListToUpdate = new list <Offer__c>();
        list<Offer__c> offerListToUpdate2 = new list <Offer__c>();
        list<PurchaseOrder__c> listPOToUpdate = new list<PurchaseOrder__c>();
        set<Id> offersetToUpdate = new set <Id>();
        set<Id> posetToUpdate = new set <Id>();
        PrerequisiteOrder__c soToUpdate;
        Decimal highestPriority;
        //set <String> setOfferIdExpectedDeliveryDateValue = new set <String>();
        //looping in the map of display priority and offer type to get the highest priority offer to select
        if(displayPriorityOfferType.size() > 0){
            highestPriority = displayPriorityOfferType.size();
            for(Decimal num : displayPriorityOfferType.keySet()){
                if(num < highestPriority){
                    highestPriority = num;
                }
            }
        }
        //looping through the sales order and its offers
        for(PrerequisiteOrder__c so : [select Id, Status__c, 
                                            (select Id, Accepted__c, Type__c , Orderline__r.PurchaseOrder__c, OrderLine__r.Suppliable__c
                                            from Offers__r )
                                      from PrerequisiteOrder__c 
                                      where Assessment__c =: assId]){
            //updating the status of the salesorder to 
            soToUpdate = new PrerequisiteOrder__c(Id = so.Id, Status__c = 'RESPONDED', OfferType__c = displayPriorityOfferType.get(highestPriority));
            if(so.Offers__r != null){
                for(Offer__c off : so.Offers__r){
                    // ABT 08-JUL-2016 - Added check if suppliable is YES
                    if(off.Type__c == displayPriorityOfferType.get(highestPriority) && off.OrderLine__r.Suppliable__c == 'YES'){
                        offerListToUpdate.add(new Offer__c(Id = off.Id, Accepted__c = 'YES'));
                        offersetToUpdate.add(off.Id);
                        posetToUpdate.add(off.Orderline__r.PurchaseOrder__c);
                    }
                    else{
                        offerListToUpdate.add(new Offer__c(Id = off.Id, Accepted__c = 'NO'));
                    }
                }
            }
        }
        if(offerListToUpdate.size() > 0){
            update offerListToUpdate;
        }
        if(soToUpdate != null){
            update soToUpdate;
        }

        for(Id orlId : posetToUpdate){
            listPOToUpdate.add(new PurchaseOrder__c(Id = orlId, Status__c = 'INDELIVERY'));
        }

        if(listPOToUpdate.size() > 0){
            update listPOToUpdate;
        }
        for(Id offId : offersetToUpdate){
            offerListToUpdate2.add(new Offer__c(Id = offId, DeliveryStatus__c = 'INDELIVERY'));
        }
        if(offerListToUpdate2.size() > 0){
            update offerListToUpdate2;
        }
    }

    public static map<Id,AggregateResult> filtering(map <Id,AggregateResult> mapPOAggResult, DetailRule__c criteria, list <String> aliasFields ){
        map <Id,AggregateResult> mapPOFiltered = new map <Id,AggregateResult>();
        list <Id> listPOFiltered = new list <Id>();
        ASPISParser parser = new ASPISParser ();
        string ifCondition = '' , compareCondition = '';
        double ifValue = 0 , compareValue = 0;
        //system.debug('##mapPOAggResult Initial ' +mapPOAggResult);
        for(Id POId :mapPOAggResult.keySet()){
            ifCondition = criteria.FieldsAPI__c;
            compareCondition = criteria.FieldsAPI__c;
            //system.debug('##ifCondition' + ifCondition);
            //system.debug('##compareCondition' + compareCondition);
            if(ifCondition.contains('/') || ifCondition.contains('*') || ifCondition.contains('+') || ifCondition.contains('-') || ifCondition.contains(')') || ifCondition.contains('(')){
                for(integer j=0; j<aliasFields.size(); j++){
                    //system.debug('## aliasFields ' + aliasFields[j]);   
                    if(criteria.FieldsAPI__c.contains(aliasFields[j])){
                        ifCondition = ifCondition.replace(aliasFields[j], String.valueOf(mapPOAggResult.get(POId).get(aliasFields[j])));
                        //system.debug('## ifCondition ' + ifCondition);
                        if(listPOFiltered.size() > 0){
                            compareCondition = compareCondition.replace(aliasFields[j], String.valueOf(mapPOAggResult.get(listPOFiltered[0]).get(aliasFields[j])));
                            //system.debug('## compareCondition ' + compareCondition);
                        }
                    }
                }
                ifValue = parser.evalDouble(ifCondition);
                if(listPOFiltered.size() > 0){
                    compareValue = parser.evalDouble(compareCondition);
                }
            }
            else{
                ifValue = Double.valueOf(mapPOAggResult.get(POId).get(criteria.FieldsAPI__c));
                if(listPOFiltered.size() > 0){
                    compareValue = Double.valueOf(mapPOAggResult.get(listPOFiltered[0]).get(criteria.FieldsAPI__c));
                }
            }
            //system.debug('## ifValue ' + ifValue);
            //system.debug('## compareValue ' + compareValue);
            //system.debug('## criteria.Operator__c ' + criteria.Operator__c);            
            if(criteria.Operator__c == 'MIN'){
                if(listPOFiltered.size() > 0){
                    if(ifValue < compareValue){
                        listPOFiltered.clear();
                        listPOFiltered.add(POId);
                    }
                    else if(ifValue == compareValue){
                        listPOFiltered.add(POId);
                    }
                }
                else{
                    listPOFiltered.add(POId);
                }
            }
            else if(criteria.Operator__c == 'MAX'){
                if(listPOFiltered.size() > 0){
                    if(ifValue > compareValue){
                        listPOFiltered.clear();
                        listPOFiltered.add(POId);
                    }
                    else if(ifValue == compareValue){
                        listPOFiltered.add(POId);
                    }
                }
                else{
                    listPOFiltered.add(POId);
                }
            }
            else if(criteria.Operator__c == 'EQUALS'){
                //if(listPOFiltered.size() > 0){
                    if(ifValue == Double.valueOf(criteria.Value__c)){
                        listPOFiltered.add(POId);
                    }
               // }
                /*else{
                    listPOFiltered.add(POId);
                }*/
            }
            else if(criteria.Operator__c == 'GREATER'){
                //if(listPOFiltered.size() > 0){
                    if(ifValue > Double.valueOf(criteria.Value__c)){
                 /*       if(ifValue > compareValue){
                            listPOFiltered.clear();
                            listPOFiltered.add(POId);
                        }
                        else{ */
                            listPOFiltered.add(POId);
                       // }
                    }
                //}
                /*else{
                    listPOFiltered.add(POId);
                }*/
            }
            else if(criteria.Operator__c == 'GREATER_EQUALS'){
                //system.debug('####### CLA Double.valueOf(criteria.Value__c) '+Double.valueOf(criteria.Value__c));
                //if(listPOFiltered.size() > 0){
                    if(ifValue >= Double.valueOf(criteria.Value__c)){
                   /*     if(ifValue >= compareValue){
                            listPOFiltered.clear();
                            listPOFiltered.add(POId);
                        }
                        else{ */
                            listPOFiltered.add(POId);
                        //}
                    }
                //}
                /*else{
                    listPOFiltered.add(POId);
                }*/
            }
            else if(criteria.Operator__c == 'LESS'){
                //if(listPOFiltered.size() > 0){
                    if(ifValue < Double.valueOf(criteria.Value__c)){
                    /*    if(ifValue < compareValue){
                            listPOFiltered.clear();
                            listPOFiltered.add(POId);
                        }
                        else{ */
                            listPOFiltered.add(POId);
                       // }
                    }
                /*}
                else{
                    listPOFiltered.add(POId);
                }*/
            }
            else if(criteria.Operator__c == 'LESS_EQUALS'){
                //if(listPOFiltered.size() > 0){
                    if(ifValue <= Double.valueOf(criteria.Value__c)){
                    /*    if(ifValue <= compareValue){
                            listPOFiltered.clear();
                            listPOFiltered.add(POId);
                        }
                        else{ */
                            listPOFiltered.add(POId);
                      //  }
                    }
                /*}
                else{
                    listPOFiltered.add(POId);
                }*/
            }
        }
        for(integer k=0; k<listPOFiltered.size(); k++){
            if(mapPOAggResult.containsKey(listPOFiltered[k])){
                mapPOFiltered.put(listPOFiltered[k],mapPOAggResult.get(listPOFiltered[k]));
            }
        }
        //system.debug('##mapPOFiltered' + mapPOFiltered);
        return mapPOFiltered;
    }
}