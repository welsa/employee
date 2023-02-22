/*************************************************************************************
Class Name - ASPISPreOffering
Version - 1.0
Created Date - 21 FEBRUARY 2017
Function - Class for preOffering using rules engine

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole         21/02/2015  Original Version
* Abdool M              16/10/2017  getDescribeOptimisation 
* Ashwina S             17/12/2018  C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops 
*************************************************************************************/
public without sharing class ASPISPreOffering {
    //ASE 17/12/2018  C-002958 - add parameter process
	public static void executePreOffering(list<Offer__c> offerList, String entityRule, String process){
        system.debug('## offerList '+offerList);
        map <String,map <Id,AggregateResult>> mapPartNumbmapOffIdAggResult = new map <String,map <Id,AggregateResult>>();
        list <String> aliasFields = new list <String>();
        list <DetailRule__c> listCriteria = new list <DetailRule__c>();
        list <DetailRule__c> listUpdateFieldsCriteria = new list <DetailRule__c>();
        list<AggregateResult> aggRList = new list<AggregateResult>();
        list <Offer__c> listOfferToUpdate = new list <Offer__c>();
        map <Id,AggregateResult> mapOfferFilterResult = new map <Id,AggregateResult>();
        map<String,String> mapNumCondition = new map<String,String>();
        list <Offer__c> listBestOffers = new list <Offer__c>();
        list <Id>listId = new list<Id>();
        String filterLogic, operator;
        string queryOffer = '', aggFields = '', objectToQuery = '', groupBy = '', groupBy1 = '', groupBy2 = '';
        Integer countgroupby = 1;

        //AMI 16/10/17 : getDescribeOptimisation
        /***update field global describe variable***/
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDescribe = Schema.getGlobalDescribe();  
        
        //objectType is the object type
        Schema.SObjectType objectTypeUpdateF = gloDescribe.get('Offer__c');
        
        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMapUpdateF = objectTypeUpdateF.getDescribe().fields.getMap();

        //this set is used to know if field was already described
        set <string> setDescribedUpdateF = new set <string>();

        //map used so that getDescribe is run only one time for fieldtype for best match method
        map <string,Schema.DisplayType> mapUpdateFFieldType = new map <string,Schema.DisplayType>();

		for(MasterRules__c masRule :[SELECT Id, Entity__c, Process__c, RuleStatus__c, DisplayPriority__c, IsPrimary__c, 
                                            FilterLogic__c, sObject__c, 
                                            (SELECT Id, Name, RecordType.DeveloperName, Number__c, sObject__c, 
                                            MasterRule__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Alias__c
                                            FROM DetailRules__r
                                            ORDER BY Number__c ASC)
                                    FROM MasterRules__c
                                    WHERE Process__c    =: process
                                    AND Entity__c       =: entityRule
                                    AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL]){
			if(masRule.DetailRules__r != null){
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
                        aggFields += detRule.FieldsAPI__c.contains('.') ? (detRule.FieldsAPI__c + ' ' + detRule.FieldsAPI__c.split('\\.')[1] + ',') : detRule.FieldsAPI__c + ',';
                        if(countgroupby == 1){
                            groupBy = detRule.FieldsAPI__c;
                            groupBy1 = detRule.FieldsAPI__c.contains('.') ? (detRule.FieldsAPI__c.split('\\.')[1]) : detRule.FieldsAPI__c;
                            countgroupby ++; 
                        }
                        else{
                            groupBy = groupBy + ',' +detRule.FieldsAPI__c;
                            groupBy2 = detRule.FieldsAPI__c.contains('.') ? (detRule.FieldsAPI__c.split('\\.')[1]) : detRule.FieldsAPI__c;
                        }
                        objectToQuery = detRule.sObject__c;
                    }
                    else if(detRule.RecordType.DeveloperName == 'CRITERIA'){
                        listCriteria.add(detRule);
                    }
                    else if(detRule.RecordType.DeveloperName == 'UpdateField'){
						listUpdateFieldsCriteria.add(detRule);
					}
                    else if(detRule.RecordType.DeveloperName == 'FILTERCONDITION'){
                        if(detRule.Operator__c == 'EQUALS'){
                            operator = ' = ';
                        }
                        else if(detRule.Operator__c == 'NOT_EQUALS'){
                            operator = ' != ';
                        }
                        else if(detRule.Operator__c == 'LESS'){
                            operator = ' < ';
                        }
                        else if(detRule.Operator__c == 'LESS_EQUALS'){
                            operator = ' <= ';
                        }
                        else if(detRule.Operator__c == 'GREATER'){
                            operator = ' > ';
                        }
                        else if(detRule.Operator__c == 'GREATER_EQUALS'){
                            operator = ' >= ';
                        }
                        mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator + detRule.Value__c );
                    }
				}
                if(mapNumCondition.size() > 0 && masRule.FilterLogic__c != null){
                    for(String Num : mapNumCondition.keySet()){
                        filterLogic = masRule.FilterLogic__c.replaceFirst(Num, mapNumCondition.get(Num));
                    }
                }
			}
		}

		if(aggFields.length() > 0){
            queryOffer = 'SELECT ' + aggFields.substring(0,aggFields.length()-1) + ' FROM ' +  objectToQuery + ' WHERE Id in: offerList ' + (filterLogic != null ? ' AND ' + filterLogic : '') + ' GROUP BY ' + groupBy;
            system.debug('## queryOffer'+ queryOffer);
            aggRList = Database.query(queryOffer); 
        }
        system.debug('## aggRList'+ aggRList);
        if(groupBy.contains(',')){
        	for (AggregateResult offerAR : aggRList){
                if((String)offerAR.get(groupBy1) != null){
                    if(mapPartNumbmapOffIdAggResult.containsKey((String)offerAR.get(groupBy1)))
                        mapPartNumbmapOffIdAggResult.get((String)offerAR.get(groupBy1)).put((Id)offerAR.get(groupBy2),offerAR);
                    else{
                        mapPartNumbmapOffIdAggResult.put((String)offerAR.get(groupBy1),new map <Id,AggregateResult>{(Id)offerAR.get(groupBy2) => offerAR});
                    }
                }  
            }
            //system.debug('## mapPartNumbmapOffIdAggResult '+ mapPartNumbmapOffIdAggResult );

            for(String partNum : mapPartNumbmapOffIdAggResult.keySet()){
                listId = new list<Id>();
                if(mapPartNumbmapOffIdAggResult.get(partNum).size() == 1)
                    mapOfferFilterResult = mapPartNumbmapOffIdAggResult.get(partNum);
                else if(listCriteria.size() > 0 && mapPartNumbmapOffIdAggResult.get(partNum).size() >= 2){
                    for(integer i=0; i<listCriteria.size(); i++){
                        if(i == 0){
                            mapOfferFilterResult = ASPISOfferGeneration.filtering(mapPartNumbmapOffIdAggResult.get(partNum),listCriteria[0],aliasFields);
                        }
                        else{
                            if(mapOfferFilterResult.size() == 1){
                                break;
                            }
                            else if(mapOfferFilterResult.size() != null && mapOfferFilterResult.size() > 1){
                                map <Id,AggregateResult> mapOfferFilterResultNext = mapOfferFilterResult;
                                mapOfferFilterResult = ASPISOfferGeneration.filtering(mapOfferFilterResultNext,listCriteria[i],aliasFields);
                            }
                        }
                    }                
                }
                listId = new list<Id>(mapOfferFilterResult.keySet());
                if(listId.size()>0){
                    listBestOffers.add(new Offer__c(Id = listId[0]));
                }
            }

            if(listUpdateFieldsCriteria.size() > 0){
                //AMI 16/10/17 : getDescribeOptimisation
                listOfferToUpdate = ASPISServiceSubstitution.updateField(
                    listBestOffers, 
                    'Offer__c', 
                    listUpdateFieldsCriteria,
                    fieldMapUpdateF,
                    setDescribedUpdateF, 
                    mapUpdateFFieldType);

                if(listOfferToUpdate.size() > 0){
                    update listOfferToUpdate;
                }
            }
        }
	}
}