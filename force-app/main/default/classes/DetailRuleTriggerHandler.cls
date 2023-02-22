/*************************************************************************************
Trigger Name - DetailRuleTrigger
Version - 1.0
Created Date - 16 APR 2015
Function - Class to manage processes on Detail Rule object

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* SC(NJO)   	16/04/2015 	Original Version(Check field validity relative to sObject)
* SC(DUN)       21/04/2015  Added Automatic Increment of number field   
* Shamina M     17/02/2016  C-001518: Removed unnecessary debug logs                        
*************************************************************************************/
public without sharing class DetailRuleTriggerHandler {

	Bypass__c userBypass = Bypass__c.getInstance(UserInfo.getUserId());
	public void OnBeforeInsert(DetailRule__c[] newDetailRules){	
		map	<Id,list<DetailRule__c>> mapMasterIdDetailRule = new map <Id,list<DetailRule__c>>();
		map <String,Id> dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
		//system.debug('## dRRecordTypeMap'+dRRecordTypeMap);
		for(integer i=0;i<newDetailRules.size();i++){
			//system.debug('## RecordTypeId'+newDetailRules[i].RecordTypeId);
			if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP05')){
				// ABT 18-AUG-2016 - C-001673 - Added PrimaryFieldsNeeded and KeyField
				if(	newDetailRules[i].sObject__c != null && 
					newDetailRules[i].FieldsAPI__c != null && 
					newDetailRules[i].RecordTypeId != dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA) &&
					newDetailRules[i].RecordTypeId != dRRecordTypeMap.get('PrimaryFieldsNeeded') &&
					newDetailRules[i].RecordTypeId != dRRecordTypeMap.get('KeyField') ){
					if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 1){
						//system.debug('## here');
						newDetailRules[i].addError(System.Label.DETAILRULEINVALIDFIELD);	
					}
					/*else if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 2){
						newDetailRules[i].addError(System.Label.DETAILRULEFIELDNOTFILTERABLE);
					}
					else if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 3){
						newDetailRules[i].addError(System.Label.DETAILRULEFIELDOPERATOR);
					}*/
				}
			}
			if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP06')){
				if(mapMasterIdDetailRule.containsKey(newDetailRules[i].MasterRule__c))
	        		mapMasterIdDetailRule.get(newDetailRules[i].MasterRule__c).add(newDetailRules[i]);
	        	else
	        		mapMasterIdDetailRule.put(newDetailRules[i].MasterRule__c,new list<DetailRule__c>{newDetailRules[i]});
	        }
		}
		//system.debug('## mapMasterIdDetailRule' + mapMasterIdDetailRule);
		if(mapMasterIdDetailRule.size() > 0){
			incrementFieldNumber(mapMasterIdDetailRule);
		}
	}
	
	public void OnBeforeUpdate(DetailRule__c[] oldDetailRules, DetailRule__c[] newDetailRules){	
		map	<Id,list<DetailRule__c>> mapMasterIdDetailRule = new map <Id,list<DetailRule__c>>();
		 map <String,Id> dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);	

		for(integer i=0;i<newDetailRules.size();i++){
			if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP07')){
				if(newDetailRules[i].sObject__c != null && newDetailRules[i].FieldsAPI__c != null && newDetailRules[i].RecordTypeId != dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA) &&
					(newDetailRules[i].sObject__c != oldDetailRules[i].sObject__c || newDetailRules[i].FieldsAPI__c != oldDetailRules[i].FieldsAPI__c || newDetailRules[i].Operator__c != oldDetailRules[i].Operator__c || newDetailRules[i].Operator__c != null)){
					if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 1){
						newDetailRules[i].addError(System.Label.DETAILRULEINVALIDFIELD);	
					}
					/*else if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 2){
						newDetailRules[i].addError(System.Label.DETAILRULEFIELDNOTFILTERABLE);
					}
					else if(checkSObjectField(newDetailRules[i].sObject__c,newDetailRules[i].FieldsAPI__c,newDetailRules[i].Operator__c) == 3){
						newDetailRules[i].addError(System.Label.DETAILRULEFIELDOPERATOR);
					}*/
				}
			}
			if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP08')){
	        	if(oldDetailRules[i].TECH_MasterRuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE){
	        		newDetailRules[i].addError(System.Label.DETAILRULENOTUPDATE);
	        	}
	        }
		}
	}

	public void OnBeforeDelete(DetailRule__c[] oldDetailRule){
		for(integer i=0;i<oldDetailRule.size();i++){
			if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP08')){
	        	if(oldDetailRule[i].TECH_MasterRuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE){
	        		//system.debug('##' + oldDetailRule[i].TECH_MasterRuleStatus__c );
	        		oldDetailRule[i].addError(System.Label.DETAILRULENOTDELETE);
	        	}
	        }
		}
	}
 	
	public Integer checkSObjectField(String sObjectName, string fieldName , string operator){
		system.debug('## Start checkSObjectField method');
		SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
		Map<String,Schema.SObjectField> mpObjectFields = objectType.getDescribe().fields.getMap();
		if(fieldName.contains('.')){
			try{
				String queryToSelect = 'SELECT ' + fieldName + ' FROM ' + sObjectName + ' limit 1';
				//system.debug('## queryToSelect ' + queryToSelect);
				list <sObject> obj = new list <sObject> (Database.query(queryToSelect));
				//system.debug('## try');
				return 0;
			}
			catch(Exception e){
				//system.debug('## catch'+e);
				return 1;
			}
		}
		else{
			//system.debug('## mpObjectFields'+mpObjectFields);
			//system.debug('## fieldName'+fieldName);
			if(mpObjectFields.containsKey(fieldName)){
				Schema.DescribeFieldResult dfr = mpObjectFields.get(fieldName).getDescribe();
				//system.debug('## dfr=' + dfr);

				Schema.DisplayType fieldType = dfr.getType();
				//system.debug('## fieldType=' + fieldType);
				return 0;
				/*if(dfr.isFilterable()){
					system.debug('## fieldType '+fieldType);
					system.debug('## operator '+operator);
					if(String.valueOf(fieldType) == 'Boolean' && !(operator == 'EQUALS' || operator == 'NOT_EQUALS'))
						return 3;
					else if((String.valueOf(fieldType) == 'String' || String.valueOf(fieldType) == 'TextArea' || String.valueOf(fieldType) == 'URL' 
							  || String.valueOf(fieldType) == 'Picklist' || String.valueOf(fieldType) == 'Phone' || String.valueOf(fieldType) == 'ID' 
							  || String.valueOf(fieldType) == 'EncryptedString' || String.valueOf(fieldType) == 'Combobox'
							  || String.valueOf(fieldType) == 'Email' || String.valueOf(fieldType) == 'Reference') 
							&& !(operator == 'EQUALS' || operator == 'NOT_EQUALS' || operator == 'IN' || operator == 'CONTAINS'))
						return 3;
					else if((String.valueOf(fieldType) == 'Currency' || String.valueOf(fieldType) == 'Date' || String.valueOf(fieldType) == 'DateTime' 
							  || String.valueOf(fieldType) == 'Double' || String.valueOf(fieldType) == 'Integer' || String.valueOf(fieldType) == 'Percent') 
							&& (operator == 'CONTAINS' || operator == 'IN'))
						return 3;
					else 
						return 0;
				}
				else
						return 2;*/
			}
			else
				return 1;
		}
	}

	private void incrementFieldNumber(map <Id,list<DetailRule__c>> mapMasterIdDetailRule){
		system.debug('## Start incrementFieldNumber method');
		//system.debug('## mapMasterIdDetailRule ' +mapMasterIdDetailRule);
		//system.debug('## mapMasterIdDetailRule key ' +mapMasterIdDetailRule.KeySet());
		map <String,Integer> mapIdNumber = new map <String,Integer>();

		
		//system.debug('## aggrequery'+[select MAX(Number__c)maxNumber, MasterRule__c 
		//					  from DetailRule__c 
		//					  where MasterRule__c in: mapMasterIdDetailRule.KeySet()
		//					  group by MasterRule__c]);
		
		for (aggregateResult aggrRe : [select MAX(Number__c)maxNumber, MasterRule__c 
							  from DetailRule__c 
							  where MasterRule__c in: mapMasterIdDetailRule.KeySet()
							  group by MasterRule__c]){
			//system.debug('## maxNumber '+aggrRe.get('maxNumber'));
			//system.debug('## aggrRe.Id '+aggrRe.get('MasterRule__c'));

			If(aggrRe.get('maxNumber') != null){
				mapIdNumber.put(string.valueOf(aggrRe.get('MasterRule__c')),Integer.valueOf(aggrRe.get('maxNumber')));
			}
			/*else{
				mapIdNumber.put(string.valueOf(aggrRe.get('MasterRule__c')),0);
			}*/
		}
		//system.debug('## mapIdNumber '+mapIdNumber);
		for (Id listdrId : mapMasterIdDetailRule.KeySet()){
			//system.debug('## listdrId '+listdrId);
			Integer count = 1;
			for(DetailRule__c dr : mapMasterIdDetailRule.get(listdrId)){
				//system.debug('## dr.Number__c  '+dr.Number__c );
				if(mapIdNumber.containsKey(dr.MasterRule__c)){
					dr.Number__c = mapIdNumber.get(dr.MasterRule__c)+count;
				}
				else{
					dr.Number__c = count;
				}
				
				count ++;
			}
		}

		//system.debug('## End incrementFieldNumber method');
	}
}