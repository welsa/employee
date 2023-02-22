public with sharing class ASPISServiceEligibility {
/*************************************************************************************
Class Name - ASPISServiceEligibility
Version - 1.0
Created Date - 07 AUG 2017
Function - Class to Process Eligibility check on Assessment
 
Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Abdool M              07/08/2017  Initial Version (Modulating methods so that they 
*                                   can be called individually anywhere
* Abdool M              13/10/2017  getDescribeOptimisation    
* Abdool M              27/10/2017  C-002041 - Distributor V2 - correcting isEligibleCheckBox 
* Dourga U              29/01/2018  C-002174 - Avoid running again Eligibility and sourcing   
* Ruksaar L             04/04/2018  C-2370 - Run eligiblility before sourcing in rest Upsert v2
* Ashwina S             27/09/2018  C-002808 - totalLoss: cater for the case when no totalLoss is sent
* Hootesh R             22/11/2021     C-004530: Substitution pour italy par rapport a l'age et la marque
*************************************************************************************/
    public static isEligibleWrapper processObjForEligibility(Assessment__c assess,boolean isTrigger){
        system.debug('## Start processObassessjForEligibility' + assess);

        isEligibleWrapper wrap = new isEligibleWrapper(false,assess);

        Boolean isEligible = true;

        Boolean isDistributorV2 = false;

        String sourceEligibilityFailure = '';
        String naturalLanguage;
        String rulesExpression = '';

        integer counter = 0;

        //RLA 05/03/18
        if(assess.PreviousStatus__c == 'DoNotExecuteWF' ){    

            //set calling system boolean
            isDistributorV2 = true;
        }
        

        system.debug('@@@ assess.EntityRules__c ' + assess.EntityRules__c);
        
        //Retrieve all rules with filtering on Entity, status and Process
        list<MasterRules__c> rules = [SELECT id, Entity__c, Process__c, RuleStatus__c, sObject__c, FilterLogic__c, version__c,Name,
                                            (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, ValueFrom__c, Number__c,
                                                recordtypeId, recordtype.DeveloperName
                                                FROM DetailRules__r 
                                                WHERE recordtype.DeveloperName =: system.Label.RECORDTYPEDETAILRULENAME
                                                ORDER BY sObject__c ASC)
                                            FROM MasterRules__c
                                            WHERE Process__c    =: system.Label.PROCESSELIGIBILITYLABEL
                                            AND Entity__c       =: assess.EntityRules__c
                                            AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];
        if(rules.size()>0){
            system.debug('JSA ' + rules);
            Map<Decimal,Boolean> rulesMap = new Map<Decimal,Boolean>();
            Map<String,List<ASPISTools.filterCriteria>> subQueryCriteriaMap = new Map<String,List<ASPISTools.filterCriteria>>();
            List<String> FLogic = new List<String>();
            List<ASPISTools.filterCriteria> criteriaList = new List<ASPISTools.filterCriteria>();
            List<sObject> queryResultList = new List<sObject>();
            List<ASPISTools.filterCriteria> subObjCriteriaList = new List<ASPISTools.filterCriteria>();
            String query ='';
            
            for(MasterRules__c rul:rules){
                if(rul.FilterLogic__c!=null){
                    FLogic.addAll(rul.FilterLogic__c.replace('(','( ').replace(')',' )').split(' '));
                }
                Integer index=0;

                naturalLanguage = rul.Process__c+' - ' + rul.version__c +' - ' +rul.Name+ '\n';
                naturalLanguage += 'Rule IsEligible'+ '\n';
                
                //SMO Case C-001466 
                sourceEligibilityFailure = '';
                
                for(DetailRule__c det:rul.DetailRules__r){
                    if(det.sObject__c == 'Assessment__c'){
                        criteriaList.add(new ASPISTools.filterCriteria(ASPISTools.schemaMap.get(det.sObject__c).newSObject(),det.FieldsAPI__c, det.Operator__c, det.Value__c,null));
                        
                        if(det.ValueFrom__c == 'Master sObject'){
                            criteriaList.add(new ASPISTools.filterCriteria(ASPISTools.schemaMap.get(det.sObject__c).newSObject(), det.Value__c, '', '',null));
                        }
                    }else{                   
                        if(det.sObject__c!=null){
                            subObjCriteriaList.add(new ASPISTools.filterCriteria(ASPISTools.schemaMap.get(det.sObject__c).newSObject(),det.FieldsAPI__c, det.Operator__c, det.Value__c,null));
                        }
                        
                        if((index+1) == rul.DetailRules__r.size()){
                            subQueryCriteriaMap.put(det.sObject__c,subObjCriteriaList);
                            subObjCriteriaList = new List<ASPISTools.filterCriteria>();
                        }
                    }
                    index++;
                }
                if (!isDistributorV2){
                    criteriaList.add(new ASPISTools.filterCriteria(assess,'id','=',assess.id,null));
                    query = ASPISTools.getQueryString(rul.sObject__c, criteriaList,subQueryCriteriaMap, true);
                    queryResultList = Database.query(query);
                }
                else{

                    queryResultList.add(assess);    
                }

                

                
                counter = counter+1;
            }//end looping in master rules

            //AMI 13/10/17 : getDescribeOptimisation
            //map used so that getDescribe is run only one time for fieldlabel
            map <string,string> mapFieldLabel = new map <string,string>();
            
            //set used to know which sobject does not exist
            set <string> setSOjectNotSupported = new set <string>();

            //set used to know which field does not exist
            set <string> setFieldNotSupported = new set <string>();

            if(queryResultList.size()>0){
                for(sObject s:queryResultList){
                    for(MasterRules__c r:rules){
                        for(DetailRule__c rDet:r.DetailRules__r){
                            
                            //AMI 13/10/17 : getDescribeOptimisation
                            //if(rDet.sObject__c == s.getSObjectType().getDescribe().getName()){
                            //sObject ass =     assess;
                            //ass.[ClaimNumberRight2__c] = '73';
                            //ass.put('ClaimNumberRight2__c', '73');
                                if(rDet.sObject__c == string.valueOf(s.getSObjectType())){
                                rulesMap.put(rDet.Number__c,ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria( assess, 
                                                                                                                        rDet.FieldsAPI__c, 
                                                                                                                        rDet.Operator__c, 
                                                                                                                        getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), 
                                                                                                                        null)));
                                /*//natural language
                                if(Schema.getGlobalDescribe().get(rDet.sObject__c)!=null && Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c)!=null){
                                    if(Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel()!=null){
                                        

                                        if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(assess, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                        }
                                        else{
                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                            //SMO Case C-001466 
                                            //DUN Case C-001557 replace , by ;
                                            sourceEligibilityFailure += Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + '; ';
                                        }
                                    }                               
                                }*/

                                //AMI 13/10/17 : getDescribeOptimisation
                                //natural language
                                if(!setSOjectNotSupported.contains(rDet.sObject__c.toUpperCase())  && !setFieldNotSupported.contains(rDet.FieldsAPI__c.toUpperCase())){
                                    if(mapFieldLabel.containsKey(rDet.FieldsAPI__c.toUpperCase())){
                                        if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(assess, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+ mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                        }
                                        else{
                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                            //SMO Case C-001466 
                                            //DUN Case C-001557 replace , by ;
                                            sourceEligibilityFailure += mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + '; ';
                                        }
                                    }else{
                                        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(rDet.sObject__c);

                                        if(sObjType != null){

                                            Schema.SobjectField sObjField = sObjType.getDescribe().fields.getMap().get(rDet.FieldsAPI__c);

                                            if(sObjField != null){

                                                string label = sObjField.getDescribe().getLabel();

                                                //populate map
                                                mapFieldLabel.put(rDet.FieldsAPI__c.toUpperCase(),label);

                                                if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(assess, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                                    naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+ label + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                                }
                                                else{
                                                    naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  label + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                                    //SMO Case C-001466 
                                                    //DUN Case C-001557 replace , by ;
                                                    sourceEligibilityFailure += label + '; ';
                                                }
                                            }else{
                                                setFieldNotSupported.add(rDet.FieldsAPI__c.toUpperCase());
                                            }
                                        }else{
                                            setSOjectNotSupported.add(rDet.sObject__c.toUpperCase());
                                        }
                                    }
                                }
                            }
                            else{
                                for(Schema.ChildRelationship child:s.getSObjectType().getDescribe().getChildRelationships()){
                                    

                                    if((child.getChildSObject().getDescribe().getName() == rDet.sObject__c) && 
                                       (s.getSObjects(child.getRelationshipName()) != null)){
                                        
                                        List<sObject> childObjects = s.getSObjects(child.getRelationshipName());

                                        if(childObjects.size()>0){
                                            
                                            for(sObject o:childObjects){
                                                rulesMap.put(rDet.Number__c,ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria( o, 
                                                                                                                                        rDet.FieldsAPI__c, 
                                                                                                                                        rDet.Operator__c, 
                                                                                                                                        getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), 
                                                                                                                                        null)));
                                                /*
                                                //natural language
                                                if(Schema.getGlobalDescribe().get(rDet.sObject__c)!=null && Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c)!=null){
                                                    if(Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel()!=null){
                                                        if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(o, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                                        }
                                                        else{
                                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                                            //SMO Case C-001466
                                                            sourceEligibilityFailure += Schema.getGlobalDescribe().get(rDet.sObject__c).getDescribe().fields.getMap().get(rDet.FieldsAPI__c).getDescribe().getLabel() + '; ';
                                                        }
                                                    }                                               
                                                }*/

                                                //AMI 13/10/17 : getDescribeOptimisation
                                                //natural language
                                                if(!setSOjectNotSupported.contains(rDet.sObject__c.toUpperCase())  && !setFieldNotSupported.contains(rDet.FieldsAPI__c.toUpperCase())){
                                                    if(mapFieldLabel.containsKey(rDet.FieldsAPI__c.toUpperCase())){
                                                        if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(o, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+ mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                                        }
                                                        else{
                                                            naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                                            //SMO Case C-001466 
                                                            //DUN Case C-001557 replace , by ;
                                                            sourceEligibilityFailure += mapFieldLabel.get(rDet.FieldsAPI__c.toUpperCase()) + '; ';
                                                        }
                                                    }else{
                                                        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(rDet.sObject__c);

                                                        if(sObjType != null){

                                                            Schema.SobjectField sObjField = sObjType.getDescribe().fields.getMap().get(rDet.FieldsAPI__c);

                                                            if(sObjField != null){

                                                                string label = sObjField.getDescribe().getLabel();

                                                                //populate map
                                                                mapFieldLabel.put(rDet.FieldsAPI__c.toUpperCase(),label);

                                                                if(ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria(o, rDet.FieldsAPI__c, rDet.Operator__c, getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s), null)) == true){
                                                                    naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+ label + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + ' \t [T] '+'\n';
                                                                }
                                                                else{
                                                                    naturalLanguage += '[' + rDet.Number__c + ']'+ ' '+  label + ' '+rDet.Operator__c+ ' '+getValueFromRuleCriteriaWithCheckforField(rDet.Value__c, rDet.valueFrom__c, s) + '  \t [F] '+'\n';
                                                                    //SMO Case C-001466 
                                                                    sourceEligibilityFailure += label + '; ';
                                                                }
                                                            }else{
                                                                setFieldNotSupported.add(rDet.FieldsAPI__c.toUpperCase());
                                                            }
                                                        }else{
                                                            setSOjectNotSupported.add(rDet.sObject__c.toUpperCase());
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }//end else
                        }
                    }
                }
            }
            //Check the object against the rule
            if(rulesMap.size()>0){
                Boolean boolResult = null;

                for(Integer i=0;i<FLogic.size();i++){
                    if(!FLogic[i].isNumeric() && FLogic[i] == system.Label.OPERATORAND){
                        rulesExpression +=' &&';
                        if(boolResult!=null){
                            if (rulesMap.get(Decimal.valueOf(FLogic[i+1])) != null){
                                boolResult &= rulesMap.get(Decimal.valueOf(FLogic[i+1]));
                            }
                        }
                    }else if(!FLogic[i].isNumeric() && FLogic[i] == system.Label.OPERATOROR){
                        rulesExpression +=' ||';
                        if(boolResult!=null)
                            if (rulesMap.get(Decimal.valueOf(FLogic[i+1])) != null){
                                boolResult |= rulesMap.get(Decimal.valueOf(FLogic[i+1]));
                            }
                    }else if(FLogic[i].isNumeric()){
                        rulesExpression += rulesMap.get(Decimal.valueOf(FLogic[i]));
                        if(boolResult==null)
                            boolResult = rulesMap.get(Decimal.valueOf(FLogic[i]));
                    }
                    rulesExpression +=' '+FLogic[i];
                }
                
                if(boolResult!=null){
                    isEligible = (boolResult && queryResultList.size()>0 );
                }
            }
            naturalLanguage += 'RESULT '+ isEligible ;

            if(isTrigger){
                assess.TECHRulesAppliedDescription__c = naturalLanguage;
            }else{
                wrap.ass.TECHRulesAppliedDescription__c = naturalLanguage;
            }
        }//end if(rules.size()>0){
        else{
            //AMI 27/10/17 - C-002041 - Distributor V2 - correcting isEligibleCheckBox
            isEligible = false;

            if(isTrigger){
                assess.ReasonFailure__c = 'EligibilityFailure';
                assess.Status__c = 'REJECTED';
            }else{
                wrap.ass.ReasonFailure__c = 'EligibilityFailure';
                wrap.ass.Status__c = 'REJECTED';
            }

        }

        if(!isEligible){
            if(isTrigger){
                assess.ReasonFailure__c = 'EligibilityFailure';
                sourceEligibilityFailure = sourceEligibilityFailure.removeEnd('; ');

                assess.SourceFailure__c = sourceEligibilityFailure;
                assess.Status__c = 'REJECTED'; 
            }else{
                wrap.ass.ReasonFailure__c = 'EligibilityFailure';
                sourceEligibilityFailure = sourceEligibilityFailure.removeEnd('; ');

                wrap.ass.SourceFailure__c = sourceEligibilityFailure;
                wrap.ass.Status__c = 'REJECTED'; 
            }
        }
        
        
        //DUN 29/01/2018 C-002174 - set boolean MREligibility__c on claim assessment
        if(isEligible && assess.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()){
            if(isTrigger){
                assess.MREligibility__c = true;
            }
            else{
                wrap.ass.MREligibility__c = true;
            }
        }
        //set boolean 
        wrap.isEligible = isEligible;

        system.debug('## End processObjForEligibility');
        return wrap;
    }

    public class isEligibleWrapper{
        public boolean isEligible;
        public Assessment__c ass;
        public isEligibleWrapper(boolean isEligible,Assessment__c ass){
            this.isEligible = isEligible;
            this.ass = ass;
        }
    }

    // New method to put the value of the field defined in the rule field "Value__c" if the rule field ValueFrom__c is not null
    public static String getValueFromRuleCriteriaWithCheckforField(String critValue, String valueFrom, sObject currRecord){
        List<String> splitSObjectFields = new list <String>();
        String value = '';
        //System.debug('@@@ critValue: ' + critValue);
        //System.debug('@@@ valueFrom: ' + valueFrom);
        //System.debug('@@@ currRecord: ' + currRecord);
        
        // Check if the rule value contains a field name
        if(valueFrom == 'Master sObject'){
            // Check if the value is a field from a parent object of the current record (for example: Bodyshop__r.Name)
            if(critValue.contains('.')){
                Integer matches = critValue.countMatches('.');
                splitSObjectFields = critValue.split('\\.',0);
                if(matches == 1){
                    if(currRecord.getSobject(splitSObjectFields[0])!=null){
                        value = String.valueOf(currRecord.getSobject(splitSObjectFields[0]).get(splitSObjectFields[1]));
                        if(value == null){
                            value = '';
                        }
                    }
                }
            }
            // Or directly a field from the current record (for example: Name)
            else {
                value = String.valueOf(currRecord.get(critValue));
                if(value == null){
                    value = '';
                }
            }
        }
        // Or a primitive value
        else if(valueFrom == 'Criteria sObject' || valueFrom == null){
            value = critValue;
        }
       // System.debug('@@@ value: ' + value);
        
        return value;
    }
    //HRM 22/11/2021 C-004530 
    //Broke createAssessmentforEligibility into 2 Methods
    //createAssessmentforEligibilityOnly: Return Assessment__c
    //createAssessmentforEligibility: Return isEligibleWrapper of Assessment__c
    public static Assessment__c createAssessmentforEligibilityOnly(
        Map<String, Map<String, Object>> validAssessMap,
        Map<Id, Account> bsRefAccountMap,
        Map<String, AccountRef__c> assessAccountRefMap,
        Map<String, String> assessCarMap
        ){

        Assessment__c assUpdated;
        Set<String> setFakeReferences = new set<String>();


        for(String assessmentID: validAssessMap.keySet()){
            boolean isdirect = false;
            boolean alreadyOrdered = false;
            boolean totalLossRule = false;
            Map<String, Object> receivedAssessMap               = validAssessMap.get(assessmentID);
            List<Object> lstParts = (List<Object>) receivedAssessMap.get('Parts');
            Integer countMaterialParts = 0;

            //RLA 29/03/2022 C-004405 : No Ordering on Fake References
            setFakeReferences = RESTUpsertAssessmentV2.getFakeReferences(assessmentID.left(2));

            //map<String, Object> mapParts = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(lstParts));

            for (Object part: lstParts){
                Map<String, Object> receivedPartMap = (Map<String, Object>) part;
                if (receivedPartMap.containsKey('RecordType') && receivedPartMap.containsKey('PartNumber')){
                    if (receivedPartMap.get('RecordType') == 'Material' && !(setFakeReferences.contains((String) receivedPartMap.get('PartNumber'))) ){
                        countMaterialParts++;
                        break;  
                    }                   
                }
            }

            // build currentClaimMap
            Map<String, Object> currentClaimMap;
            if(receivedAssessMap.get('currentClaim') != null){
                currentClaimMap = (Map<String, Object>) receivedAssessMap.get('currentClaim');
            }
            Map<String, Object> currentAssetMap;
            if(receivedAssessMap.get('currentAsset') != null){
                currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');
            }

             list<String> assessCarMapList=  assessCarMap.get(assessmentID).split(';');
            
            Assessment__c newAssessment = new Assessment__c( callerSystem__c            = String.valueOf(receivedAssessMap.get('callerSystem'))
                                                        ,Entity__c                  = String.valueOf(receivedAssessMap.get('Entity'))
                                                        ,EntityCode__c              = (receivedAssessMap.get('EntityCode') != null && receivedAssessMap.get('EntityCode') != '') ? String.valueOf(receivedAssessMap.get('EntityCode')) : system.label.EntityCodeDefaultValue
                                                        ,MissionNumber__c           = String.valueOf(receivedAssessMap.get('MissionNumber'))
                                                        ,VINCheck__c                = Integer.valueOf(receivedAssessMap.get('VINCheck'))
                                                        ,Status__c                  = 'NEW'
                                                        ,TECH_EntityCountryCode__c  = assessmentID.left(2)
                                                        ,RecordTypeId               = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()
                                                       // ,IsShoppingList__c          = isShoppingList 
                                                        ,OrderOrigin__c             = 'Upsert'   
                                                        ,PreviousStatus__c          = 'DoNotExecuteWF'   
                                                        //,HasBeenSubstituted__c      = (OEMIAMMap.size() > 0) ? true : false
                                                        ,SourceFailure__c = ''
                                                        ,ReasonFailure__c = '' 
                                                        ,CrossReferences__c = 'None'   
                                                        ,Manufacturer__c   = assessCarMapList[1] != 'null' ? assessCarMapList[1]: assessCarMapList[0]
                                                        ,assessmentID__c = assessmentID

                                                    );

            if(currentAssetMap != null){
                if( currentAssetMap.get('FirstRegistrationDate') != null && 
                    !String.isBlank(String.valueOf(currentAssetMap.get('FirstRegistrationDate')))){
                    newAssessment.FirstRegistrationDate__c = (Date) JSON.deserialize('"' + currentAssetMap.get('FirstRegistrationDate') + '"', Date.class);
                }
                newAssessment.VINNumber__c      = String.valueOf(currentAssetMap.get('VINNumber'));
            }
            
            //RLA 20/02/2018 case 2370 BE Issues
            if( newAssessment.TECH_EntityCountryCode__c == 'BE'
                && newAssessment.EntityCode__c != 'NONAXA'){
                newAssessment.EntityRules__c =  'BEAXA';                
            }
            else{
                //set entity code
                newAssessment.EntityRules__c = newAssessment.TECH_EntityCountryCode__c + newAssessment.EntityCode__c;
            }

            if( (assessAccountRefMap != null
                && assessAccountRefMap.containskey(assessmentID)
                && assessAccountRefMap.get(assessmentID) != null) || RESTUpsertAssessmentV2.bodyshopToReplace != null  ){   
                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                newAssessment.BodyShop__c   = RESTUpsertAssessmentV2.bodyshopToReplace != null ? RESTUpsertAssessmentV2.bodyshopToReplace.Id : assessAccountRefMap.get(assessmentID).InternalReference__c;
                system.debug('@@ newAssessment.BodyShop__c: '+newAssessment.BodyShop__c);
            }

            map<String, Object> mapAssess = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(newAssessment));
            if ( bsRefAccountMap.containskey(newAssessment.BodyShop__c)
                && bsRefAccountMap.get(newAssessment.BodyShop__c).DirectOrderingProcess__c
                && newAssessment.RecordtypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId()){
                isdirect = true;
                alreadyOrdered = true;
            }
            //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
            if (bsRefAccountMap.containskey(newAssessment.BodyShop__c)
                || RESTUpsertAssessmentV2.bodyshopToReplace != null){                
                mapAssess.put('Bodyshop_is_Eligible_Non_AXA__c',(RESTUpsertAssessmentV2.bodyshopToReplace != null ? RESTUpsertAssessmentV2.bodyshopToReplace.Non_AXA_Authorised__c : bsRefAccountMap.get(newAssessment.BodyShop__c).Non_AXA_Authorised__c ) );   
                mapAssess.put('BodyShopIsEligible__c',(RESTUpsertAssessmentV2.bodyshopToReplace != null ? RESTUpsertAssessmentV2.bodyshopToReplace.isEligible__c : bsRefAccountMap.get(newAssessment.BodyShop__c).isEligible__c ) );

                //RLA 28/02/2022 C-004565: Garages du Groupe Ferron - Marques Exclues sur du NON Partenaire
                if (RESTUpsertAssessmentV2.bodyshopToReplace != null && String.isnotBlank(RESTUpsertAssessmentV2.bodyshopToReplace.Brand_Rejected_on_Non_Partner__c) ){
                    mapAssess.put('Brand_Rejected_on_Non_Partner__c',RESTUpsertAssessmentV2.bodyshopToReplace.Brand_Rejected_on_Non_Partner__c);
                    system.debug('@@ mapAssess 1:'+mapAssess);


                }
                else if (bsRefAccountMap.get(newAssessment.BodyShop__c) != null && String.isnotBlank(bsRefAccountMap.get(newAssessment.BodyShop__c).Brand_Rejected_on_Non_Partner__c)){
                    mapAssess.put('Brand_Rejected_on_Non_Partner__c',bsRefAccountMap.get(newAssessment.BodyShop__c).Brand_Rejected_on_Non_Partner__c );
                    system.debug('@@ mapAssess 2:'+mapAssess);
                }
            }

            if (currentClaimMap.size() > 0){
                mapAssess.put('ClaimReference__c', currentClaimMap.containsKey(('ClaimReference')) ? String.valueOf(currentClaimMap.get('ClaimReference')) : null) ; 
                
                mapAssess.put('RepairsAuthorised__c', (currentClaimMap.get('RepairsAuthorised') != null) ? Boolean.valueOf(currentClaimMap.get('RepairsAuthorised')) : false);
               
               //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                if (currentClaimMap.get('TotalLoss') != null) {
                    if( (Boolean.valueOf(currentClaimMap.get('TotalLoss')) == true && (bsRefAccountMap.containskey(newAssessment.BodyShop__c) && bsRefAccountMap.get(newAssessment.BodyShop__c).TotalLoss__c == true) || (RESTUpsertAssessmentV2.bodyshopToReplace != null  && RESTUpsertAssessmentV2.bodyshopToReplace.TotalLoss__c == true) )
                        || (Boolean.valueOf(currentClaimMap.get('TotalLoss')) == false ) 
                    )
                        {
                        totalLossRule = true;    
                    }
                }
                else{
                    //27/09/2018  C-002808 - totalLoss: cater for the case when no totalLoss is sent
                    totalLossRule = true;   
                }                
            }            

            mapAssess.put('TotalNumberOfParts__c', countMaterialParts); 
            mapAssess.put('TotalLossRule__c', totalLossRule);  
            mapAssess.put('DirectOrderingProcess__c', isdirect);
            mapAssess.put('AlreadyOrdered__c', alreadyOrdered);

            String assessString = JSON.serialize(mapAssess);            
            assUpdated = (Assessment__c)JSON.deserialize(assessString, Assessment__c.class); 
            assUpdated.recalculateFormulas();

        }

        return assUpdated;


    }


    //RLA 04/04/2018 Case-2370
    // Create assessment before sending for eligibility
    public static isEligibleWrapper createAssessmentforEligibility(
        Map<String, Map<String, Object>> validAssessMap,
        Map<Id, Account> bsRefAccountMap,
        Map<String, AccountRef__c> assessAccountRefMap,
        Map<String, String> assessCarMap){

        isEligibleWrapper eligibleWrap;

        Assessment__c assUpdated = createAssessmentforEligibilityOnly(validAssessMap,bsRefAccountMap, assessAccountRefMap, assessCarMap);  

        eligibleWrap =  ASPISServiceEligibility.processObjForEligibility(assUpdated, false);
        
       

       return eligibleWrap;


    }
}