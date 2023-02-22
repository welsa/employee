/*************************************************************************************
Class Name - MasterRuleTriggerHandler
Version - 1.0
Created Date - 16 APR 2015
Function - Class to Manage MasterRuleTrigger

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Dourga Unmole     16/04/2015  Original Version
* Hirikesh Dussoye	20/04/2015	Desactivate previous rule version when cloning
* Dourga Unmole     27/05/2015  Review of code to add rule set part in afer insert and update
* Dourga Unmole     17/08/2015  Added code for case 1162 (Only 1 rule in a Rule Set can be 
                                indicated as Primary.)
* Shamina M         17/02/2016  C-001518: Removed unnecessary debug logs                                
*******************************************************************************************/
public with sharing class MasterRuleTriggerHandler {
    Bypass__c userBypass = Bypass__c.getInstance(UserInfo.getUserId());

    public void onBeforeInsert(MasterRules__c[] newMasterRules){

    	/*map<id,MasterRules__c> mpMasterRulesId = new map<id,MasterRules__c>();
    	map<String,MasterRules__c> mpMasterRulesRS = new map<String,MasterRules__c>();
    	set<String> process = new set <String>();
    	set<String> entity = new set <String>();
    	
    	for(integer i=0;i<newMasterRules.size();i++){
            if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP01')){
        		if(newMasterRules[i].TECH_MasterClone__c == null){
        			//Check of TECH_MasterClone__c done so as not to do the verification on clone
        			//as logics could be present while detail rules not yet inserted
        			mpMasterRulesId.put(newMasterRules[i].id,newMasterRules[i]);
        		}
    		
        		if(newMasterRules[i].RuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE){
        			mpMasterRulesRS.put(newMasterRules[i].Entity__c+'-'+newMasterRules[i].Process__c,newMasterRules[i]);
        			entity.add(newMasterRules[i].Entity__c);
        			process.add(newMasterRules[i].Process__c);
        		}
            }
    	}
    	
    	if(mpMasterRulesId.size() > 0)
    		checkFilterLogicValidity(mpMasterRulesId);*/

        map<Id,list<MasterRules__c>> mpRuleSetIdMasterRules = new map<Id,list<MasterRules__c>>();
        map <String,Id> mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);

        for(integer i=0;i<newMasterRules.size();i++){
            if(newMasterRules[i].IsPrimary__c && newMasterRules[i].RuleSet__c != null && newMasterRules[i].RecordTypeId != mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)){
                if(mpRuleSetIdMasterRules.containsKey(newMasterRules[i].RuleSet__c))
                    mpRuleSetIdMasterRules.get(newMasterRules[i].RuleSet__c).add(newMasterRules[i]);
                else
                    mpRuleSetIdMasterRules.put(newMasterRules[i].RuleSet__c,new list <MasterRules__c>{newMasterRules[i]});
            }
        }
        if(mpRuleSetIdMasterRules.size() > 0){}
            checkPrimary(mpRuleSetIdMasterRules);
    }
    
    public void onBeforeUpdate(MasterRules__c[] newMasterRules, MasterRules__c[] oldMasterRules){
    	map<id,MasterRules__c> mpMasterRulesId = new map<id,MasterRules__c>();
        map<Id,list<MasterRules__c>> mpRuleSetIdMasterRules = new map<Id,list<MasterRules__c>>();
        map <String,Id> mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
    	
    	for(integer i=0;i<newMasterRules.size();i++){
            if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP02')){
        		if(newMasterRules[i].NumberOfRuleDetails__c == oldMasterRules[i].NumberOfRuleDetails__c)
        			mpMasterRulesId.put(newMasterRules[i].id,newMasterRules[i]);
            }
            if(newMasterRules[i].IsPrimary__c && oldMasterRules[i].IsPrimary__c == false && newMasterRules[i].RuleSet__c != null && newMasterRules[i].RecordTypeId != mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)){
                if(mpRuleSetIdMasterRules.containsKey(newMasterRules[i].RuleSet__c))
                    mpRuleSetIdMasterRules.get(newMasterRules[i].RuleSet__c).add(newMasterRules[i]);
                else
                    mpRuleSetIdMasterRules.put(newMasterRules[i].RuleSet__c,new list <MasterRules__c>{newMasterRules[i]});
            }

    	}
    	
    	if(mpMasterRulesId.size() > 0)
    		checkFilterLogicValidity(mpMasterRulesId);

        if(mpRuleSetIdMasterRules.size() > 0){}
            checkPrimary(mpRuleSetIdMasterRules);
    }
        
    public void onAfterInsert(MasterRules__c[] newMasterRules){
        map <String,Id> mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
    	map<string,id> mpMasterRulesId = new map<string,id>();
    	set<String> setEntity = new set<String>();
    	set<String> setProcess = new set<String>();
        set<Id> setRuleSet = new set<Id>(); 
    	for(integer i=0;i<newMasterRules.size();i++){
            if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP03')){
        		if(newMasterRules[i].RuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE  ) 
        			mpMasterRulesId.put(newMasterRules[i].Entity__c+'*-*'+newMasterRules[i].Process__c+'*-*'+newMasterRules[i].RecordTypeId,newMasterRules[i].Id );
    			if (!setEntity.contains(newMasterRules[i].Entity__c)){
    				setEntity.add(newMasterRules[i].Entity__c);
    			}
    			if (!setProcess.contains(newMasterRules[i].Process__c)){
    				setProcess.add(newMasterRules[i].Process__c);
    			}
                if(newMasterRules[i].RuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE && 
                    newMasterRules[i].RecordTypeId == mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)){
                    setRuleSet.add(newMasterRules[i].Id);
                }
            }
    	}
    	
    	if(mpMasterRulesId.size() > 0 && setEntity.size()>0 && setProcess.size()>0){
    		desactivatePreviousVersion(mpMasterRulesId,setEntity,setProcess);
    	}

        if(setRuleSet.size() > 0){
            activateMasterRule(setRuleSet);
        }
    }
    
    public void onAfterUpdate(MasterRules__c[] newMasterRules,MasterRules__c[] oldMasterRules){
        map <String,Id> mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
    	map<string,id> mpMasterRulesId = new map<string,id>();
    	set<String> setEntity = new set<String>();
    	set<String> setProcess = new set<String>();
        set<Id> setRuleSet = new set<Id>(); 
    	for(integer i=0;i<newMasterRules.size();i++){
            if(userBypass.BypassTrigger__c == null || !userBypass.BypassTrigger__c.contains('AP04')){
        		if(	newMasterRules[i].RuleStatus__c != oldMasterRules[i].RuleStatus__c &&
        			newMasterRules[i].RuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE  ) 
        		{
        			mpMasterRulesId.put(newMasterRules[i].Entity__c+'*-*'+newMasterRules[i].Process__c+'*-*'+newMasterRules[i].RecordTypeId,newMasterRules[i].Id );
        			if (!setEntity.contains(newMasterRules[i].Entity__c)){
        				setEntity.add(newMasterRules[i].Entity__c);
        			}
        			if (!setProcess.contains(newMasterRules[i].Process__c)){
        				setProcess.add(newMasterRules[i].Process__c);
        			}
                    if(newMasterRules[i].RuleStatus__c == ASPISConstants.MASTER_RULE_STATUS_ACTIVE && 
                        newMasterRules[i].RecordTypeId == mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)){
                        setRuleSet.add(newMasterRules[i].Id);
                    }
    		    }//end fo check status
            }
    	}//end of loop
    	
    	if(mpMasterRulesId.size() > 0 && setEntity.size()>0 && setProcess.size()>0){
    		desactivatePreviousVersion(mpMasterRulesId,setEntity,setProcess);
    	}
        if(setRuleSet.size() > 0){
            activateMasterRule(setRuleSet);
        }
    }
    
    private static void activateMasterRule(set<Id> setRuleSetId){
        system.debug('## Start activateMasterRule method');
        list<MasterRules__c>listRuleForActive = new list<MasterRules__c>();
        for( MasterRules__c rule : [    SELECT  id,RuleStatus__c
                                        FROM    MasterRules__c
                                        WHERE   RuleSet__c IN :setRuleSetId]){                
            rule.RuleStatus__c = ASPISConstants.MASTER_RULE_STATUS_ACTIVE;
            listRuleForActive.add(rule);                                           
            
        }//end of loop
        
        if(listRuleForActive.size() > 0 ){
            update listRuleForActive;
        }
        system.debug('## End activateMasterRule method');
    }

    private static void desactivatePreviousVersion(map<string,id> mpMasterRulesId,set<String> setEntity,set<String> setProcess){
        system.debug('## Start desactivatePreviousVersion method');
    	list<MasterRules__c>listRuleForArchived = new list<MasterRules__c>();
    	for( MasterRules__c rule : [	SELECT 	id,Entity__c,Process__c,RecordTypeId
    									FROM 	MasterRules__c
    									WHERE	Entity__c IN :setEntity
    									AND		Process__c IN :setProcess]){
			if( mpMasterRulesId.containsKey(rule.Entity__c+'*-*'+rule.Process__c+'*-*'+rule.RecordTypeId ) &&  
				mpMasterRulesId.get(rule.Entity__c+'*-*'+rule.Process__c+'*-*'+rule.RecordTypeId ) != rule.id ){
				
				rule.RuleStatus__c = ASPISConstants.MASTER_RULE_STATUS_ARCHIVED;
				listRuleForArchived.add(rule);
			}//end of check if previous rule    										
    		
    	}//end of loop
    	
    	if(listRuleForArchived.size() > 0 ){
    		update listRuleForArchived;
    	}
        system.debug('## End desactivatePreviousVersion method');
    
    }//end of private method desactivatePreviousVersion

    private static void checkFilterLogicValidity(map<Id,MasterRules__c> mpMasterRulesId){
        system.debug('## Start checkFilterLogicValidity method');
    
        map<id,list<DetailRule__c>> mpMasterDetails = new map<id,list<DetailRule__c>>();
        map<String,list<DetailRule__c>> mpRTNameDetailRule = new map<String,list<DetailRule__c>>();
        map<Id,map<String,list<DetailRule__c>>> mpMasterRulesIdListDetailRule = new map<Id,map<String,list<DetailRule__c>>>();
        map<String,String> mpFilter = new map<String,String>{'DETAILRULE' => 'FilterLogic__c' ,
                                                             'FILTERINPUT' => 'InputLogic__c' ,
                                                             'FILTERCONDITION' => 'ConditionLogic__c'};
        
        //Query on detail rules
        for(DetailRule__c detailRule :[Select MasterRule__c , Number__c , RecordType.DeveloperName
        									From DetailRule__c
        									Where MasterRule__c In :mpMasterRulesId.keySet()
                                            and RecordType.DeveloperName != 'ACTION']){
            if(mpMasterRulesIdListDetailRule.containsKey(detailRule.MasterRule__c)){
                if(mpMasterRulesIdListDetailRule.get(detailRule.MasterRule__c).containsKey(detailRule.RecordType.DeveloperName))
                    mpMasterRulesIdListDetailRule.get(detailRule.MasterRule__c).get(detailRule.RecordType.DeveloperName).add(detailRule);
                else
                    mpMasterRulesIdListDetailRule.get(detailRule.MasterRule__c).put(detailRule.RecordType.DeveloperName,new list<DetailRule__c>{detailRule});
            }
            else{
                mpMasterRulesIdListDetailRule.put(detailRule.MasterRule__c,new map<String,list<DetailRule__c>>{detailRule.RecordType.DeveloperName => new list<DetailRule__c>{detailRule}});
            }
        }
        //system.debug('## mpMasterRulesIdListDetailRule '+mpMasterRulesIdListDetailRule);

        for(Id masRuleId : mpMasterRulesId.keySet()){

                String str = '';
                MasterRules__c masRule = mpMasterRulesId.get(masRuleId);
                Sobject s = masRule;
                //system.debug('## filter logic value ' + s.get('FilterLogic__c'));

           /* for(String con : mpFilter.keySet()){

                String fieldName = mpFilter.get(con);

                if(s.get(fieldName) == null && mpMasterRulesIdListDetailRule.get(masRuleId) != null && mpMasterRulesIdListDetailRule.get(masRuleId).get(con) != null){
                    system.debug('## case 1 - Details rules present, but no logic');
                    masRule.addError('Logic should be indicated');
                
                if(s.get(fieldName) != null){
                    if(mpMasterRulesIdListDetailRule.get(masRuleId).get(con) == null){
                        system.debug('## case 2 - Details rules not present, but logic present');
                        masRule.addError('Logic should not be indicated if there are no detail rules');
                    }
                    if(mpMasterRulesIdListDetailRule.get(masRuleId).get(con) != null){
                        system.debug('## case 3 - checking logic order / if all logic are present');
                        for(integer i=0 ; i <mpMasterRulesIdListDetailRule.get(masRuleId).get(con).size();i++){
                            if(!masRule.filterLogic__c.contains(String.valueOf(mpMasterRulesIdListDetailRule.get(masRuleId).get(con)[i].Number__c))){
                                if(str != '')
                                    str += ',';
                                str += mpMasterRulesIdListDetailRule.get(masRuleId).get(con)[i].Number__c;
                            }
                        }
                        if(str != '')
                            masRule.addError('These details rules are missing from the logic : ' + str);
                    }
                    if(mpMasterRulesIdListDetailRule.get(masRuleId).get(con) != null && mpMasterRulesIdListDetailRule.get(masRuleId).get(con).size() > 1){
                        system.debug('## case 4 - when more then two criterias and OR & AND conditions, check if () also present');
                        if(!String.valueOf(s.get(fieldName)).contains('AND') && !String.valueOf(s.get(fieldName)).contains('OR')){
                            masRule.addError('Please indicate logic with AND/OR conditions');
                        }
                        
                        if(String.valueOf(s.get(fieldName)).contains('AND') && String.valueOf(s.get(fieldName)).contains('OR') && (!String.valueOf(s.get(fieldName)).contains('(') || !String.valueOf(s.get(fieldName)).contains(')'))){
                            masRule.addError('Please use brackets to group logic');
                        }

                        if(String.valueOf(s.get(fieldName)).countMatches('(') < String.valueOf(s.get(fieldName)).countMatches(')')){
                            masRule.addError('( missing from syntax');
                        }
                        else if(String.valueOf(s.get(fieldName)).countMatches('(') > String.valueOf(s.get(fieldName)).countMatches(')')){
                            masRule.addError(') missing from syntax');
                        }
                    }
                }
            }*/
        }
        system.debug('## End checkFilterLogicValidity method');
    }
    
    private static void checkPrimary(map<Id,list<MasterRules__c>> mpRuleSetIdMasterRules){
        system.debug('## Start checkPrimary method');
        map<Id,list<MasterRules__c>> mapRuleSetIdMasterRulesExisting = new map<Id,list<MasterRules__c>>();
        boolean hasPrimary = false;

        for(MasterRules__c mr : [select Id, RuleSet__c, IsPrimary__c from MasterRules__c where RuleSet__c in: mpRuleSetIdMasterRules.keySet()]){
            if(mapRuleSetIdMasterRulesExisting.containsKey(mr.RuleSet__c))
                mapRuleSetIdMasterRulesExisting.get(mr.RuleSet__c).add(mr);
            else
                mapRuleSetIdMasterRulesExisting.put(mr.RuleSet__c,new list <MasterRules__c>{mr});
        }

        for(Id rsId: mpRuleSetIdMasterRules.keySet()){
            if(mapRuleSetIdMasterRulesExisting.containsKey(rsId)){
                for(MasterRules__c masRule : mapRuleSetIdMasterRulesExisting.get(rsId)){
                    if(masRule.IsPrimary__c)
                        hasPrimary = true;
                }
            }
            if(hasPrimary){

                for(MasterRules__c masRule : mpRuleSetIdMasterRules.get(rsId)){
                    masRule.addError(System.Label.MASTERRULES);
                }
            }
        }
        system.debug('## End checkPrimary method');
    }
}