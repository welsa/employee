/*************************************************************************************
Class Name - ASPISServiceSubstitution
Version - 1.0
Created Date - 16 MAY 2016
Function - Class to get substituted parts of an original part 
for POC

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S      16/05/2016     Original Version - for POC
* Dourga U       14/07/2016     MasterRule Substitution
* Dourga U       12/09/2016     Update on master rule
* Ashwina S      07/04/2017     C-001908 : Substitution set Categories for Bodyshop (Part Type)
* Abdool M       16/10/2017     getDescribeOptimisation 
* Ashwina S      27/09/2018     C-002692: Substitution on BE assessments
* Welsa C        30/08/2018     C-002754: add TECHDistList__c field
* Ashwina S      27/09/2018     C-002600: Define bodyshop / expert granular level substitution rules
* Ruksaar L      06/06/2019     C-003143 : Preseletion de la pièce E pour la France 
* Ruksaar L      29/04/2019     C-003142 Cross Ref Sourcing R4 for Spain
* Ruksaar L      29/04/2019     C-003180:  Preselection de l'ASCR pour la Substitution belge
* Ruksaar L      14/08/2019     C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
* Ruksaar L      05/02/2019     C-003524 : Change Recommended part in France 
* Ruksaar L      20/03/2020     C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
* Hootesh R      22/11/2021     C-004530: Substitution pour italy par rapport a l'age et la marque

*************************************************************************************/
public with sharing class ASPISServiceSubstitution {
 
    // variables
    //map of operators
    static map<String,String> operatorMap = new map<String,String>{ 'EQUALS' => '='
                                                                   ,'NOT_EQUALS' => ' !='
                                                                   ,'IN' => ' IN'
                                                                   ,'Min (Aggregate)' => 'MIN'
                                                                  };

    static map <String,Id> criteriaRecordTypeMap = ASPISConstants.getDeveloperIdMap('DetailRule__c');

    static list<DetailRule__c> listCriterias;
    static Map<String, Schema.SobjectField> fieldMapBMatch;
    static set<string> setDescribedBMatchFields;
    static map<string,Schema.DisplayType> mapBMatchFieldType;
    //RLA 28/01/2020 C-003524 : Change Recommended part in France  
    static map<String,Integer> mapPartTypePriority = new map<String,Integer>();
    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
    static Boolean isNonAxa = false;
    
    //wrapper class SubstiteWrapper
    public class SubstituteWrapper{
        //a map of Assessment and a map of OEM key and a list of IAM parts to sustitute
        public map<String,map<String,list<CrossReference__c>>> mapAssmapOEMKeylistIAM;
        //a map of Assessment and a map of OEM key and a substituted IAM part
        public map<String,map<String,CrossReference__c>> mapAssessmentIAMfinal;
        //list of fields to update 
        public list<DetailRule__c> listUpdateFieldsCriteria;
        //list of validation rules 
        public list<DetailRule__c> listValidationCriteria;
        
        //DUN 13/10/17 : Case 1994 Validation logic string
        public String validationLogicValue;

        //RLA 28/01/2020 C-003524 : Change Recommended part in France  
        public map<String,Integer> mapPartTypePriority;

        public SubstituteWrapper(map<String,map<String,list<CrossReference__c>>> mapAssOEMlistIAM, map<String,map<String,CrossReference__c>> mapAssIAMfinal, list<DetailRule__c> listUpdateFields, list<DetailRule__c> listValidation, String validationLogicVal, map<String,Integer> mapPartTypePrio){
            mapAssmapOEMKeylistIAM = mapAssOEMlistIAM;
            mapAssessmentIAMfinal = mapAssIAMfinal;
            listUpdateFieldsCriteria = listUpdateFields;
            listValidationCriteria = listValidation;
            //DUN 13/10/17 : Case 1994 Validation logic string
            validationLogicValue = validationLogicVal;
            //RLA 28/01/2020 C-003524 : Change Recommended part in France  
            mapPartTypePriority = mapPartTypePrio;
        }
    }
    //WCH 0410/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
    public static SubstituteWrapper runSubstitution(map<String,list<Object>> mapAsslistParts, String entityCode,  map<String, set<String>> assessBSCategoriesMap){
        return ASPISServiceSubstitution.runSubstitution(mapAsslistParts,entityCode,assessBSCategoriesMap, false,false, 'noneABC', '','', false,false,false);
    }
    //method to run rules engine sustitution for an entity , mapAsslistParts contains AssId-AssBrand-CountryCode-categories as Key and a list of parts
    public static SubstituteWrapper runSubstitution(map<String,list<Object>> mapAsslistParts, String entityCode,  map<String, set<String>> assessBSCategoriesMap, Boolean isAPrefixAllowed, Boolean isBsOrExpertLinkedAss, String callerSystem, String substitutionType, String preferredType, Boolean isNONAXAval, Boolean isPiloteBDG,Boolean isAlbax){
        system.debug('#### ASPISServiceSubstitution.runSubstitution START:'+entityCode);
        //map of entity and map of OEM and substituted IAM
        map<String,map<String,CrossReference__c>> mapAssessmentIAMfinal = new map<String,map<String,CrossReference__c>>();
        //map of assessment and map of OEM and list IAM
        map<String,map<String,list<CrossReference__c>>> mapAssmapOEMKeylistIAM = new map<String,map<String,list<CrossReference__c>>>();
        //list of criterias to choose best iam
        /*list<DetailRule__c>*/ listCriterias = new list<DetailRule__c>();
        //list of criterias for update on fields
        list<DetailRule__c> listUpdateFieldsCriteria = new list<DetailRule__c>();
        //list of criterias for validation
        list<DetailRule__c> listValidationCriteria = new list<DetailRule__c>();
        //String query to select required crossRefernce
        String crossRefQuery = 'Select ';
        //Boolean canQuery true if query is valid
        Boolean canQuery = false;
        //map of OEM key and list of IAM
        map<String,list<CrossReference__c>> mapOEMKeylistIAM = new map<String,list<CrossReference__c>>();
        map<String, map<String, list<CrossReference__c>>> mapAssOEMKeylistIAM = new map<String, map<String, list<CrossReference__c>>>();
        //list of field values to build as keys
        list <String> listFieldValues = new list <String>();
        //list of assessment values to use in select
        list <String> listAssValues = new list <String>();
        //map of PartNumber-Brand and list of assessment
        map<String,Set<String>> mapPartNumBrandlistAss = new map<String,Set<String>>();
        //map of number and its condition
        map<String,String> mapNumCondition = new map<String,String>();
        //String filter logic value
        String filterLogic = '';
        //String operator
        String operator;
        //String key value for map mapOEMKeylistIAM
        String keyValue = '';
        //map of OEM and substituted IAM
        map<String,CrossReference__c> mapIAMfinal = new map<String,CrossReference__c>();
        //Set of strings (OEMkey) used in query to select crossReference
        set<String> setOEMKey = new set<String>();
        //list of filtered IAM
        list<CrossReference__c> listIAMFiltered = new list<CrossReference__c>();
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        //Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe();    
        //objectType is the object type
        Schema.SObjectType objectType;
        //get map of fields for the object above
        //Map<String, Schema.SobjectField> fieldMap;
        //currentFieldDisplayType to represent field type
        Schema.DisplayType currentFieldDisplayType;
        //String validation Logic
        String valLogic;

        //AMI 16/10/17 : getDescribeOptimisation
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDescribe = Schema.getGlobalDescribe();    

        //get map of fields for the object above
        map <String, Schema.SobjectField> fieldMap = new map <String, Schema.SobjectField>();

        //this set will contain objects that have already been described        
        set <string> setObjectsDescribeAlreadyRun = new set <string>();

        //this set will contain fields that have already been described        
        set <string> setFieldsDescribeAlreadyRun = new set <string>();

        //map used so that getDescribe is run only one time for fieldtype
        map <string,Schema.DisplayType> mapFieldType = new map <string,Schema.DisplayType>();

        /***best match global describe variable***/
        
        //objectType is the object type
        Schema.SObjectType objectTypeBMatch = gloDescribe.get('CrossReference__c');
        
        //get map of fields for the object above
        /*Map<String, Schema.SobjectField>*/ fieldMapBMatch = objectTypeBMatch.getDescribe().fields.getMap();

        //this set is used to know if field was already described
        /*set <string>*/ setDescribedBMatchFields = new set <string>();

        //map used so that getDescribe is run only one time for fieldtype for best match method
        /*map <string,Schema.DisplayType>*/ mapBMatchFieldType = new map <string,Schema.DisplayType>();
        //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
        set<String> setoriginalOEMKey = new set<String>();
		//RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
        //map of number and its condition
        map<String,String> mapNumConditionXrefCriterias = new map<String,String>();

        //RLA 28/01/2020 C-003513: C-003524 : Change Recommended part in France  
        //map of number and its condition
        map<String,String> mapNumConditionPartPriorities = new map<String,String>();
        
        //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
        map<String,Set<String>> mapAssmntToolIamManu = new map<String,Set<String>>();
        // if (true){
            mapAssmntToolIamManu = createMapAssmntIamManu(system.label.CS_XrefExceptions);
        // }
        system.debug('@@2 mapAssmntToolIamManuL '+mapAssmntToolIamManu);
        system.debug('@@2 isPiloteBDG '+isPiloteBDG);
        

        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
        isNonAxa = isNONAXAval;

        //list of masterules and its detail rules
        //DUN 13/10/17 : Case 1994 Validation logic string
        list<MasterRules__c> listMasterRule =  [Select  Id, Entity__c, RuleStatus__c,FilterLogic__c,sObject__c,ValidationLogic__c,
        /*C-003513*/Xref_Criterias_Logic__c,/*C-003524*/Priority_Queue_Logic__c,Priority_Queue_Logic_BDG__c,Filter_Logic_BDG__c,ConditionLogicAlbax__c,ConditionLogic__c,//add fields
                                                    (Select Id, Name, RecordType.DeveloperName, Number__c, sObject__c,MasterRule__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Alias__c 
                                                    from DetailRules__r)
                                                from MasterRules__c 
                                                where Entity__c =: entityCode 
                                                and RuleStatus__c = 'Active'
                                                and Process__c = 'SUBSTITUTION'];

        if(!listMasterRule.isEmpty()){
            for(MasterRules__c mR : listMasterRule){
                
                //objectType is the object type
                //objectType = gloDesc.get(mR.sObject__c);
                //get map of fields for the object above
                //fieldMap = objectType.getDescribe().fields.getMap();
                
                //AMI 16/10/17 : getDescribeOptimisation
                //run getDescribe if and only if getDescribe have never been runned
                if(!setObjectsDescribeAlreadyRun.contains(mR.sObject__c.toUpperCase())){
                    //add to list to know that describe has already been runned
                    setObjectsDescribeAlreadyRun.add(mR.sObject__c.toUpperCase());

                    objectType = gloDescribe.get(mR.sObject__c);

                    //get map of fields for the object above
                    fieldMap.putAll(objectType.getDescribe().fields.getMap());
                }

                //DUN 13/10/17 : Case 1994 Validation logic string : filling validation logic
                valLogic = mR.ValidationLogic__c;
                String criteriaLogic = isAlbax ? mR.ConditionLogicAlbax__c : mR.ConditionLogic__c ;
                system.debug('@@@ criteriaLogic applied ' +criteriaLogic );
                
                //check if there are detail rules for this master rule
                if(mR.DetailRules__r.size() > 0){
                    //looping through a list of detail rules
                    for(DetailRule__c detRule : mR.DetailRules__r){
                        //PrimaryFieldNeeded
                        if(detRule.RecordType.DeveloperName == 'PrimaryFieldsNeeded'){
                            crossRefQuery += detRule.FieldsAPI__c + ' From ' + detRule.sObject__c + ' where ' ;
                        }
                        //Criteria
                        else if(detRule.RecordType.DeveloperName == 'CRITERIA'){
                            if (String.isNotBlank(criteriaLogic) && criteriaLogic.contains(String.valueOf(detRule.Number__c))){
                                system.debug('@@ i contained criteria');
                            listCriterias.add(detRule);
                        }
                           
                        }
                        //Update field
                        else if(detRule.RecordType.DeveloperName == 'UpdateField'){
                            listUpdateFieldsCriteria.add(detRule);
                        }
                        //validation
                        else if(detRule.RecordType.DeveloperName == 'Validation'){
                            listValidationCriteria.add(detRule);
                        }
                        //groupby key
                        else if(detRule.RecordType.DeveloperName == 'KeyField'){
                            if(detRule.FieldsAPI__c.contains('-')){
                                listFieldValues = detRule.FieldsAPI__c.split('-');
                            }
                            else{
                                listFieldValues.add(detRule.FieldsAPI__c);
                            }
                        }
                     
                       

                        //filter condition
                        else if(detRule.RecordType.DeveloperName == 'FILTERCONDITION'){
                            if(detRule.Operator__c == 'EQUALS'){
                                operator = ' = ';
                            }
                            else if(detRule.Operator__c == 'NOT_EQUALS'){
                                operator = ' != ';
                            }
                            else if(detRule.Operator__c == 'IN'){
                                operator = ' IN ';
                            }
                            else if(detRule.Operator__c == 'NOT_IN'){
                                operator = ' NOT IN ';
                            }
                            
                            //currentFieldDisplayType = fieldMap.get(detRule.FieldsAPI__c).getDescribe().getType();

                            //AMI 16/10/17 : getDescribeOptimisation
                            //run getDescribe if and only if getDescribe have never been runned
                            if(!setFieldsDescribeAlreadyRun.contains(detRule.FieldsAPI__c.toUpperCase())){
                                //add to list to know that describe has already been runned
                                setFieldsDescribeAlreadyRun.add(detRule.FieldsAPI__c.toUpperCase());

                                //perfrom getDescribe to get type
                                currentFieldDisplayType = fieldMap.get(detRule.FieldsAPI__c.toLowerCase()).getDescribe().getType();

                                //add to global map 
                                mapFieldType.put(detRule.FieldsAPI__c.toUpperCase(),currentFieldDisplayType);
                            }else{
                                if(mapFieldType.containsKey(detRule.FieldsAPI__c.toUpperCase())){
                                    currentFieldDisplayType = mapFieldType.get(detRule.FieldsAPI__c.toUpperCase());
                                }else{
                                    currentFieldDisplayType = null;
                                }
                            }

                            if( currentFieldDisplayType == Schema.DisplayType.Id ||
                                currentFieldDisplayType == Schema.DisplayType.String ||
                                currentFieldDisplayType == Schema.DisplayType.Picklist ||
                                currentFieldDisplayType == Schema.DisplayType.TextArea ||
                                currentFieldDisplayType == Schema.DisplayType.Address ||
                                currentFieldDisplayType == Schema.DisplayType.Phone ||
                                currentFieldDisplayType == Schema.DisplayType.URL ||
                                currentFieldDisplayType == Schema.DisplayType.EncryptedString ||
                                currentFieldDisplayType == Schema.DisplayType.Email ||
                                currentFieldDisplayType == Schema.DisplayType.MultiPicklist){
                                mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Currency ||
                                    currentFieldDisplayType == Schema.DisplayType.Integer ||
                                    currentFieldDisplayType == Schema.DisplayType.Double ||
                                    currentFieldDisplayType == Schema.DisplayType.Percent){
                                mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator + detRule.Value__c);
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Date){
                                mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.DateTime){
                                mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Boolean){
                                mapNumCondition.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator + detRule.Value__c );
                            }
                            
                        }
                        //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
                        else if (detRule.RecordType.DeveloperName == 'Xref_Criterias'){
                            //listXrefsCriteria.add(detRule);
                            //  if(detRule.FieldsAPI__c.contains('-')){
                            //     listXrefsCriteria = detRule.FieldsAPI__c.split('-');
                            // }
                            // else{
                            //     listXrefsCriteria.add(detRule.FieldsAPI__c);
                            // }

                            if(detRule.Operator__c == 'EQUALS'){
                                operator = ' = ';
                            }
                            else if(detRule.Operator__c == 'NOT_EQUALS'){
                                operator = ' != ';
                            }
                            else if(detRule.Operator__c == 'IN'){
                                operator = ' IN ';
                            }
                            else if(detRule.Operator__c == 'NOT_IN'){
                                operator = ' NOT IN ';
                            }
                            else if(detRule.Operator__c == 'GREATER'){
                                operator = ' > ';
                            }


                            if(!setFieldsDescribeAlreadyRun.contains(detRule.FieldsAPI__c.toUpperCase())){
                                //add to list to know that describe has already been runned
                                setFieldsDescribeAlreadyRun.add(detRule.FieldsAPI__c.toUpperCase());

                                //perfrom getDescribe to get type
                                currentFieldDisplayType = fieldMap.get(detRule.FieldsAPI__c.toLowerCase()).getDescribe().getType();

                                //add to global map 
                                mapFieldType.put(detRule.FieldsAPI__c.toUpperCase(),currentFieldDisplayType);
                            }else{
                                if(mapFieldType.containsKey(detRule.FieldsAPI__c.toUpperCase())){
                                    currentFieldDisplayType = mapFieldType.get(detRule.FieldsAPI__c.toUpperCase());
                                }else{
                                    currentFieldDisplayType = null;
                                }
                            }

                            if( currentFieldDisplayType == Schema.DisplayType.Id ||
                                currentFieldDisplayType == Schema.DisplayType.String ||
                                currentFieldDisplayType == Schema.DisplayType.Picklist ||
                                currentFieldDisplayType == Schema.DisplayType.TextArea ||
                                currentFieldDisplayType == Schema.DisplayType.Address ||
                                currentFieldDisplayType == Schema.DisplayType.Phone ||
                                currentFieldDisplayType == Schema.DisplayType.URL ||
                                currentFieldDisplayType == Schema.DisplayType.EncryptedString ||
                                currentFieldDisplayType == Schema.DisplayType.Email ||
                                currentFieldDisplayType == Schema.DisplayType.MultiPicklist){
                                mapNumConditionXrefCriterias.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Currency ||
                                    currentFieldDisplayType == Schema.DisplayType.Integer ||
                                    currentFieldDisplayType == Schema.DisplayType.Double ||
                                    currentFieldDisplayType == Schema.DisplayType.Percent){
                                mapNumConditionXrefCriterias.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator + detRule.Value__c);
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Date){
                                mapNumConditionXrefCriterias.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.DateTime){
                                mapNumConditionXrefCriterias.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'');
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Boolean){
                                mapNumConditionXrefCriterias.put(String.valueOf(detRule.Number__c),detRule.FieldsAPI__c + operator + detRule.Value__c );
                            }
                            
                        }
                         //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
                        else if (detRule.RecordType.DeveloperName == 'Priority_Part_Type'){
                             if(detRule.Operator__c == 'PRIORITY'){
                                operator = ' PRIORITY ';
                            }

                            if(!setFieldsDescribeAlreadyRun.contains(detRule.FieldsAPI__c.toUpperCase())){
                                //add to list to know that describe has already been runned
                                setFieldsDescribeAlreadyRun.add(detRule.FieldsAPI__c.toUpperCase());

                                //perfrom getDescribe to get type
                                currentFieldDisplayType = fieldMap.get(detRule.FieldsAPI__c.toLowerCase()).getDescribe().getType();

                                //add to global map 
                                mapFieldType.put(detRule.FieldsAPI__c.toUpperCase(),currentFieldDisplayType);
                            }else{
                                if(mapFieldType.containsKey(detRule.FieldsAPI__c.toUpperCase())){
                                    currentFieldDisplayType = mapFieldType.get(detRule.FieldsAPI__c.toUpperCase());
                                }else{
                                    currentFieldDisplayType = null;
                                }
                            }

                            if( currentFieldDisplayType == Schema.DisplayType.Id ||
                                currentFieldDisplayType == Schema.DisplayType.String ||
                                currentFieldDisplayType == Schema.DisplayType.Picklist ||
                                currentFieldDisplayType == Schema.DisplayType.TextArea ||
                                currentFieldDisplayType == Schema.DisplayType.Address ||
                                currentFieldDisplayType == Schema.DisplayType.Phone ||
                                currentFieldDisplayType == Schema.DisplayType.URL ||
                                currentFieldDisplayType == Schema.DisplayType.EncryptedString ||
                                currentFieldDisplayType == Schema.DisplayType.Email ||
                                currentFieldDisplayType == Schema.DisplayType.MultiPicklist){
                                mapNumConditionPartPriorities.put(String.valueOf(detRule.Number__c), detRule.Value__c);
                            }
                            else if(currentFieldDisplayType == Schema.DisplayType.Currency ||
                                    currentFieldDisplayType == Schema.DisplayType.Integer ||
                                    currentFieldDisplayType == Schema.DisplayType.Double ||
                                    currentFieldDisplayType == Schema.DisplayType.Percent){
                                mapNumConditionPartPriorities.put(String.valueOf(detRule.Number__c), detRule.Value__c);
                            }
                         

                        }
                    }
                    system.debug('## mapNumConditionPartPriorities ' + mapNumConditionPartPriorities);
                    // system.debug('## mR.FilterLogic__c ' + mR.FilterLogic__c);
                    if(mapNumCondition.size() > 0 && mR.Filter_Logic_BDG__c != null && isPiloteBDG && !isNonAxa){
                        filterLogic = mR.Filter_Logic_BDG__c;
                        for(String Num : mapNumCondition.keySet()){
                            if(mR.Filter_Logic_BDG__c.contains(Num)){
                                filterLogic = filterLogic.replaceFirst(Num, mapNumCondition.get(Num));
                                system.debug('## filterLogic ' + filterLogic);
                            }
                        }
                        crossRefQuery += filterLogic + ' and ';
                        System.Debug('@@ crossRefQuery:'+crossRefQuery);
                    }
                    else if(mapNumCondition.size() > 0 && mR.FilterLogic__c != null){
                        filterLogic = mR.FilterLogic__c;
                        for(String Num : mapNumCondition.keySet()){
                            if(mR.FilterLogic__c.contains(Num)){
                                filterLogic = filterLogic.replaceFirst(Num, mapNumCondition.get(Num));
                                system.debug('## filterLogic ' + filterLogic);
                            }
                        }
                        crossRefQuery += filterLogic + ' and ';
                        System.Debug('@@ crossRefQuery:'+crossRefQuery);
                    }
                    
                    //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
                    if((isBsOrExpertLinkedAss && mapNumConditionXrefCriterias.size() > 0 && mR.Xref_Criterias_Logic__c != null)
                       || String.isNotBlank(substitutionType)){

                        String filterLogicXref = mR.Xref_Criterias_Logic__c;
                        for(String Num : mapNumConditionXrefCriterias.keySet()){
                            if(mR.Xref_Criterias_Logic__c.contains(Num)){
                                filterLogicXref = filterLogicXref.replaceFirst(Num, mapNumConditionXrefCriterias.get(Num));
                            }
                        }

                        //RLA 09/04/2020 C-003693: IG - Substitution
                        if (String.isNotBlank(substitutionType)){
                            List<String> lstSubstitutionType = substitutionType.split(';');
                            set<String> setSubsType = new set<String>(lstSubstitutionType);

                            if (setSubsType.size() > 0){
                                if (String.isBlank(filterLogicXref)){
                                    filterLogicXref = '';    
                                }
                                filterLogicXref += ' IAMPartClass__c IN :setSubsType  ' ;    
                            }
                            
                        }

                        crossRefQuery += filterLogicXref + ' and ';
                        System.Debug('@@ crossRefQuery Xref Criterias:'+crossRefQuery);

                    }
                    //RLA 28/01/2020 C-003524 : Change Recommended part in France
                    if (mapNumConditionPartPriorities.size() > 0){
                        
                        
                        String priorityToUse = '';
                        if (String.isNotBlank(mr.Priority_Queue_Logic_BDG__c) && isPiloteBDG){
                            priorityToUse = mr.Priority_Queue_Logic_BDG__c;
                        }
                        else if(String.isNotBlank(mr.Priority_Queue_Logic__c)){
                            priorityToUse = mr.Priority_Queue_Logic__c;
                        }
                         System.Debug('@@ priorityToUse:'+priorityToUse);
                        if (string.IsNotBlank(priorityToUse)){
                         for(String Num : mapNumConditionPartPriorities.keySet()){
                                
                                if(priorityToUse.contains(Num)){
                               
                              
                                List<String> lstPartTypePriority = (mapNumConditionPartPriorities.get(num)).split('=');
                                if (lstPartTypePriority.size() >= 2){
                                    mapPartTypePriority.put(lstPartTypePriority[0],Integer.valueOf(lstPartTypePriority[1]));
                                }

                                
                            }
                        }
                        }
                            
                        system.debug('## mapPartTypePriority ' + mapPartTypePriority);
                    }


                }
            }

            //Action to perform for update field??

            
            //build where condition
            for(String assKey : mapAsslistParts.keySet()){
                //listAssValues = assKey.split('-');
                String lang = assKey.substringAfterLast('-');
                // ASE: C-002692 : 27/09/2018
                String countryCode  = assKey.substringBeforeLast('-').substringAfterLast('-');
                //lang = (lang == null) ? countryCode : lang;
                String brand        = assKey.substringBeforeLast('-').substringBeforeLast('-').substringAfterLast('-');
                String assessmentId = (assKey.substringBeforeLast('-').substringBeforeLast('-')).substringBeforeLast('-');


                for(Object parts : mapAsslistParts.get(assKey)){
                    map<String,Object> mapparts = (map<String,Object>)parts;
                    String alphaScaleCRID = mapparts.get('AlphaScaleMRID')!=null?String.valueOf(mapparts.get('AlphaScaleMRID')):'';
                    Boolean isSelected = mapparts.get('IsSelected')!=null?Boolean.valueOf(mapparts.get('IsSelected')):false;
                    String partNumber = cleanseReference(String.valueOf(mapparts.get('PartNumber')));
                    system.debug('partNumber>>'+partNumber);
                    // if part doesn't contain alphaScaleMRID and isSelected = false, look for substitutes  
                    //if(alphaScaleCRID=='' && isSelected== false){
                    if(alphaScaleCRID==''){
                        //crossRefQuery += ' ( CountryCode__c = \'' + countryCode + '\' and LanguageCode__c = \'' + countryCode + '\' and OEMPartNumber__c= \''+ cleanseReference(String.valueOf(mapparts.get('PartNumber'))) +'\' and OEMManufacturer__c = \'' + brand + '\'  and ActiveForSubstitution__c = true) or';
                        // ASE: C-002692 : 27/09/2018
                        //setOEMKey.add((countryCode+countryCode+cleanseReference(String.valueOf(mapparts.get('PartNumber')))+brand).toUpperCase());
                            setOEMKey.add((countryCode+lang+cleanseReference(String.valueOf(mapparts.get('PartNumber')))+brand).toUpperCase()); 
//RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                        if (isAPrefixAllowed)   {
                            String partNumPrefix = checkPrefixOnPartNumber(cleanseReference(String.valueOf(mapparts.get('PartNumber')))); 
                            setoriginalOEMKey.add((countryCode+lang+cleanseReference(String.valueOf(mapparts.get('PartNumber')))+brand).toUpperCase()); 
                            setOEMKey.add((countryCode+lang+partNumPrefix+brand).toUpperCase());
                        }
                        canQuery = true;
                        if(mapPartNumBrandlistAss.containsKey(partNumber+'-'+brand)){
                            mapPartNumBrandlistAss.get(partNumber+'-'+brand).add(assessmentId);
                        }
                        else{
                            mapPartNumBrandlistAss.put(partNumber+'-'+brand,new Set <String> {assessmentId});
                        }
                    }
                }
            }

            if(canQuery){
                //removing 'or' part from query
                //crossRefQuery = crossRefQuery.left(crossRefQuery.length()-2);
                // ASE: 07/04/2017 : C-001908
                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                if (isNONAXA){
                    crossRefQuery += ' OEMKey__c in: setOEMKey and ActiveForSubstitution__c = true and  IAMPartClass__c !=null ORDER BY Price_to_CompareNONAXA__c  ASC NULLS LAST ';
                }
                else{
                crossRefQuery += ' OEMKey__c in: setOEMKey and ActiveForSubstitution__c = true and  IAMPartClass__c !=null ORDER BY Price_to_Compare__c  ASC NULLS LAST ';
                }
               
                system.debug('##setOEMKey'+setOEMKey);
                system.debug('##crossRefQuery'+crossRefQuery);
                //looping in list of selected cross references
                for(CrossReference__c crossRef : database.query(crossRefQuery)){
                    keyValue = '';
                    //looping through list of fields
                    for(String fval : listFieldValues){
                        //concatenating using cross reference values as a key for mapOEMKeylistIAM
                        keyValue += crossRef.get(fval) + '-';
                    }
                    keyValue = keyValue.left(keyValue.length()-1);
                    system.debug('##keyValue'+keyValue);
                    
                    //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
                    Boolean allowXref = true;
                    
                    if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank(crossRef.IAMManufacturer__c))){

                        if (mapAssmntToolIamManu.containskey(callerSystem)){

                            if ((mapAssmntToolIamManu.get(callerSystem)).contains(crossRef.IAMManufacturer__c)){
                            	allowXref = false;    
                            }
                        }
                    }
					system.debug('@@@ allowXref: '+allowXref);
                    //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
                    if (allowXref){
                        //build map of OEM key and list of IAM
                        if(mapOEMKeylistIAM.containsKey(keyValue)){
                            mapOEMKeylistIAM.get(keyValue).add(crossRef);
                        }
                        else{
                            mapOEMKeylistIAM.put(keyValue,new list<CrossReference__c>{crossRef});
                        }
    
                        
                    }
                }
    
            }
                
            system.debug('mapPartNumBrandlistAss>>'+mapPartNumBrandlistAss);
            system.debug('mapOEMKeylistIAM>>'+mapOEMKeylistIAM);
            // categgory Set
            // for(String OEMKey : mapOEMKeylistIAM.keySet()){
            for(String partNumBrandSent : mapPartNumBrandlistAss.keySet()){
                // if(mapPartNumBrandlistAss.containsKey(OEMKey)){
                if(mapOEMKeylistIAM.containsKey(partNumBrandSent)){
                    // String assNum = mapPartNumBrandlistAss.get(partNumBrandSent);
                    string OEMKey = partNumBrandSent;

                    for(String assNum : mapPartNumBrandlistAss.get(OEMKey)){
                    
                         
                        if(assessBSCategoriesMap != null && assessBSCategoriesMap.containsKey(assNum) && assessBSCategoriesMap.get(assNum)!= null){
                            //if(assessBSCategoriesMap.get(assNum)!= null){
                            for(CrossReference__c cr : mapOEMKeylistIAM.get(OEMKey)){                           
                                if(assessBSCategoriesMap.get(assNum).contains(CR.IAMPartClass__c)){ 

                                    // build map<AsessmentId, mapOEMKeylistIAM>
                                    if(!mapAssOEMKeylistIAM.containsKey(assNum)){
                                        mapAssOEMKeylistIAM.put(assNum,new map<String, list<CrossReference__c>>{OEMKey => new list<CrossReference__c>{cr}});
                                    }
                                    else{
                                        if(!mapAssOEMKeylistIAM.get(assNum).containsKey(OEMKey)){

                                            mapAssOEMKeylistIAM.get(assNum).put(OEMKey, new list<CrossReference__c>{cr});
                                        }                                       
                                        else{
                                            mapAssOEMKeylistIAM.get(assNum).get(OEMKey).add(cr);
                                        }                                   
                                    }
                                    

                                }
                            }
                        }
                        else{
                            // build map<AsessmentId, mapOEMKeylistIAM> with all crossRef
                            if(!mapAssOEMKeylistIAM.containsKey(assNum)){
                                mapAssOEMKeylistIAM.put(assNum, new map<String, list<CrossReference__c>>{OEMKey => mapOEMKeylistIAM.get(OEMKey)});
                            }
                            else{
                                mapAssOEMKeylistIAM.get(assNum).put(OEMKey, mapOEMKeylistIAM.get(OEMKey));                          
                            }
                        }                                           
                        
                    }
                }
                //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                //sent 415 500 01 02
                //in system A 415 500 01 02
                // else if (!OEMKey.startsWith('A') && isAPrefixAllowed){
                else if (!partNumBrandSent.startsWith('A') && isAPrefixAllowed){
                    
                    string OEMKey = 'A' + partNumBrandSent;
                    if(mapOEMKeylistIAM.containsKey(OEMKey)){
                    
                    // if (!setoriginalOEMKey.contains(newOEMKey)
                    //     ){
                        for(String assNum : mapPartNumBrandlistAss.get(partNumBrandSent)){
                           
                            
                            
                            if(!mapAssOEMKeylistIAM.containsKey(assNum)){
                                mapAssOEMKeylistIAM.put(assNum, new map<String, list<CrossReference__c>>{partNumBrandSent => mapOEMKeylistIAM.get(OEMKey)});
                            }
                            else if (mapAssOEMKeylistIAM.containsKey(assNum)
                                    && !((mapAssOEMKeylistIAM.get(assNum)).containskey(partNumBrandSent))){
                                
                                mapAssOEMKeylistIAM.get(assNum).put(partNumBrandSent, mapOEMKeylistIAM.get(OEMKey));                          
                            }
                        }

                    }
                }
                //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                //sent A415 500 01 02
                //in system 415 500 01 02
                // else if (!OEMKey.startsWith('A') && isAPrefixAllowed){
                //     for(String assNum : mapPartNumBrandlistAss.get('A' + OEMKey)){
                //         string newOEMKey = 'A' + OEMKey;

                //         if(!mapAssOEMKeylistIAM.containsKey(assNum)){
                //             mapAssOEMKeylistIAM.put(assNum, new map<String, list<CrossReference__c>>{newOEMKey => mapOEMKeylistIAM.get(OEMKey)});
                //         }
                //         else{
                //             mapAssOEMKeylistIAM.get(assNum).put(newOEMKey, mapOEMKeylistIAM.get(OEMKey));                          
                //         }
                //     }

                // }

            }
            system.debug('## mapAssOEMKeylistIAM:'+mapAssOEMKeylistIAM);


            processAllCRMap(mapAssOEMKeylistIAM, mapAssmapOEMKeylistIAM, mapAssessmentIAMfinal,preferredType,false);

            ////looping through OEM
            //for(String assNum : mapAssOEMKeylistIAM.keyset()){
            //  //for(String OEMKey : mapOEMKeylistIAM.keySet()){
            //  for(String OEMKey : mapAssOEMKeylistIAM.get(assNum).keyset()){
            //      //mapIAMfinal = new map<String,CrossReference__c>();
            //      listIAMFiltered = new list<CrossReference__c>();
            //      //looping throgh list of criterias to get best IAM
            //      for(integer i=0; i < listCriterias.size(); i++){
            //          //if 1st criteria
            //          if(i == 0){
            //              /*listIAMFiltered = findBestMatch('CrossReference__c',mapAssOEMKeylistIAM.get(assNum).get(OEMKey),listCriterias[0]);*/

            //              //AMI 16/10/17 : getDescribeOptimisation
            //              listIAMFiltered = findBestMatch('CrossReference__c', 
            //                                                  mapAssOEMKeylistIAM.get(assNum).get(OEMKey),
            //                                                  listCriterias[0],
            //                                                  fieldMapBMatch,
            //                                                  setDescribedBMatchFields,
            //                                                  mapBMatchFieldType);

            //          }
            //          //else (not first criteria)
            //          else{
            //              //if list filtered is equal to 1
            //              if(listIAMFiltered.size() == 1){  
            //                  break;
            //              }  
            //              //else if list filtered is equal to 0  
            //              else if(listIAMFiltered.size() == 0){

            //              }
            //              //else continue filtering
            //              else{
            //                  /*listIAMFiltered = findBestMatch('CrossReference__c', listIAMFiltered, listCriterias[i]);*/

            //                  //AMI 16/10/17 : getDescribeOptimisation
            //                  listIAMFiltered = findBestMatch('CrossReference__c', 
            //                                                      listIAMFiltered,
            //                                                      listCriterias[i],
            //                                                      fieldMapBMatch,
            //                                                      setDescribedBMatchFields,
            //                                                      mapBMatchFieldType);
            //              }
            //          }
            //      }
            //      system.debug('## listIAMFiltered:'+listIAMFiltered);
            //      //putting the OEM and its substitute(IAM) in a map
            //      if(listIAMFiltered.size() > 0){
            //          mapIAMfinal.put(OEMKey,listIAMFiltered[0]);
            //      }
            //      system.debug('## mapIAMfinal:'+mapIAMfinal);
            //  }

            //  //build map of entity and map of OEM and list of IAM to substituted

            //  if(!mapAssmapOEMKeylistIAM.containsKey(assNum)){
            //      mapAssmapOEMKeylistIAM.put(assNum, mapAssOEMKeylistIAM.get(assNum));
            //  }
    
            //  //build map of entity and map of OEM and substituted IAM
            //  if(!mapAssessmentIAMfinal.containsKey(assNum)){
            //      mapAssessmentIAMfinal.put(assNum, mapIAMfinal);
            //  }
            //}


            /*for(String OEMKey : mapOEMKeylistIAM.keySet()){
                if(mapPartNumBrandlistAss.containsKey(OEMKey)){
                    for(String assNum : mapPartNumBrandlistAss.get(OEMKey)){
                        //build map of entity and map of OEM and list of IAM to substituted
                        if(mapAssmapOEMKeylistIAM.containsKey(assNum)){
                            mapAssmapOEMKeylistIAM.get(assNum).put(OEMKey,mapOEMKeylistIAM.get(OEMKey));
                        }
                        else{
                            mapAssmapOEMKeylistIAM.put(assNum, new map<String,list<CrossReference__c>>{OEMKey => mapOEMKeylistIAM.get(OEMKey)});
                        }
                        //build map of entity and map of OEM and substituted IAM
                        if(mapAssessmentIAMfinal.containsKey(assNum)){
                            mapAssessmentIAMfinal.get(assNum).put(OEMKey,mapIAMfinal.get(OEMKey));
                        }
                        else{
                            mapAssessmentIAMfinal.put(assNum, new map<String,CrossReference__c>{OEMKey => mapIAMfinal.get(OEMKey)});
                        }
                    }
                    system.debug('## mapAssessmentIAMfinal:'+mapAssessmentIAMfinal);
                }
            }*/
        }

        system.debug('#### ASPISServiceSubstitution.runSubstitution END');
        System.debug('<<<<<mapAssmapOEMKeylistIAM>>>>>' + mapAssmapOEMKeylistIAM);
        System.debug('<<<<<mapAssessmentIAMfinal>>>>>' + mapAssessmentIAMfinal);
        System.debug('<<<<<listUpdateFieldsCriteria>>>>>' + listUpdateFieldsCriteria);
        System.debug('<<<<<listValidationCriteria>>>>>' + listValidationCriteria);
        System.debug('<<<<<valLogic>>>>>' + valLogic);
        System.debug('<<<<<mapPartTypePriority>>>>>' + mapPartTypePriority);

        List<CrossReference__c> LstXRef = new List<CrossReference__c>();

       /*  for(String key : mapAssmapOEMKeylistIAM.keyset()){
            System.debug('key: ' + key + '  Value: ' + mapAssmapOEMKeylistIAM.get(key));
            Map<String, List<CrossReference__c>> MapCrossRef = mapAssmapOEMKeylistIAM.get(key);
            
            for(String key2 : MapCrossRef.keyset()){
                System.debug('key2: ' + key2 + '  Value2: ' + MapCrossRef.get(key2));

                for(CrossReference__c crossRef : MapCrossRef.get(key2)){
                    LstXRef.add(crossRef);
                }

                System.debug('<<<LstXRef>>>: ' + LstXRef);
            }
        }

        
        for(CrossReference__c key3 : LstXRef){
            System.debug('<<<key3>>>: ' + key3.Id);
            System.debug('<<<key3>>>: ' + key3.Ocurrences__r);
            List<Occurence__c> LstOccurence  = key3.Ocurrences__r;
            System.debug('<<<LstOccurence>>>: ' + LstOccurence);

            for(Occurence__c key4 : LstOccurence){
                String LstDisID  = key4.Distributor__c;
                System.debug('<<<LstDisID>>>: ' + LstDisID);
            }
        } */

        //RLA 28/01/2020 C-003524 : Change Recommended part in France  
        return (new SubstituteWrapper(mapAssmapOEMKeylistIAM,mapAssessmentIAMfinal,listUpdateFieldsCriteria,listValidationCriteria,valLogic,mapPartTypePriority));

    }

    public static void processAllCRMap(map<String, map<String, list<CrossReference__c>>> mapAssOEMKeylistIAM, map<String, map<String,list<CrossReference__c>>> mapAssmapOEMKeylistIAM, map<String,map<String,CrossReference__c>> mapAssessmentIAMfinal, String preferredType,boolean checkPreferred){
    system.debug('#### preferredType'+preferredType);

    //looping through OEM
    map<String,CrossReference__c> mapIAMfinal = new map<String,CrossReference__c>();
        for(String assNum : mapAssOEMKeylistIAM.keyset()){
            System.debug('mapAssOEMKeylistIAM.keyset()' + mapAssOEMKeylistIAM.keyset());
            //for(String OEMKey : mapOEMKeylistIAM.keySet()){
            for(String OEMKey : mapAssOEMKeylistIAM.get(assNum).keyset()){
                System.debug('mapAssOEMKeylistIAM.get(assNum).keyset()' + mapAssOEMKeylistIAM.get(assNum).keyset());
                //mapIAMfinal = new map<String,CrossReference__c>();
                list<CrossReference__c> listIAMFiltered = new list<CrossReference__c>();
                list<CrossReference__c> listfilteredXrefs = new list<CrossReference__c>();
                 //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
                map<String,CrossReference__c> mapOEMPrefType = new map<String,CrossReference__c>();
                // system.debug('#### mapAssOEMKeylistIAM'+(mapAssOEMKeylistIAM.get(assNum).get(OEMKey)));

                //RLA 28/01/2020 C-003524 : Change Recommended part in France 
                if (mapPartTypePriority.size() > 0){
                    system.debug('rankingOfCrossRefs(mapAssOEMKeylistIAM.get(assNum).get(OEMKey))>>'+rankingOfCrossRefs(mapAssOEMKeylistIAM.get(assNum).get(OEMKey)));
                    Map<Integer,list <CrossReference__c>> mapPriotisedXrefs = rankingOfCrossRefs(mapAssOEMKeylistIAM.get(assNum).get(OEMKey));
                    System.debug('<<<mapPriotisedXrefs>>>>' + mapPriotisedXrefs);
                    Integer priorityHighest = 0;
                    for (integer i:mapPriotisedXrefs.keyset()){

                        priorityHighest ++;    
                        if (mapPriotisedXrefs.containskey(priorityHighest)
                            && (mapPriotisedXrefs.get(priorityHighest)) != null
                            && (mapPriotisedXrefs.get(priorityHighest)).size() > 0){
                            listfilteredXrefs.addAll(mapPriotisedXrefs.get(priorityHighest));
                            break;
                        }
                    System.debug('mapPriotisedXrefs.keyset()' +mapPriotisedXrefs.keyset());

                    }
                }
                else{
                    listfilteredXrefs.addAll(mapAssOEMKeylistIAM.get(assNum).get(OEMKey));

                }
                //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
                if (String.isNotBlank(preferredType)){
                    CrossReference__c lowestPricedCrossref = getlowestPricedCrossref(mapAssOEMKeylistIAM.get(assNum).get(OEMKey), preferredType);
                    system.debug('@@@ lowestPricedCrossref: '+lowestPricedCrossref);

                    if (lowestPricedCrossref != null){
                        mapOEMPrefType.put(OEMKey,lowestPricedCrossref);    
                    } 
                }

                system.debug(listfilteredXrefs);

                //looping throgh list of criterias to get best IAM
                for(integer i=0; i < listCriterias.size(); i++){
                    //if 1st criteria
                    if(i == 0){
                        /*listIAMFiltered = findBestMatch('CrossReference__c',mapAssOEMKeylistIAM.get(assNum).get(OEMKey),listCriterias[0]);*/

                        //AMI 16/10/17 : getDescribeOptimisation
                        /*listIAMFiltered = findBestMatch('CrossReference__c', 
                                                            mapAssOEMKeylistIAM.get(assNum).get(OEMKey),
                                                            listCriterias[0],
                                                            fieldMapBMatch,
                                                            setDescribedBMatchFields,
                                                            mapBMatchFieldType);*/
                        listIAMFiltered = findBestMatch('CrossReference__c', 
                                                            listfilteredXrefs,
                                                            listCriterias[0]
                                                            );

                    }
                    //else (not first criteria)
                    else{

                        //if list filtered is equal to 1
                        // if(listIAMFiltered.size() == 1){  
                        //     break;
                        // }  
                        //else if list filtered is equal to 0  
                        // else 
                        if(listIAMFiltered.size() == 0){

                        }
                        //else continue filtering
                        else{
                            /*listIAMFiltered = findBestMatch('CrossReference__c', listIAMFiltered, listCriterias[i]);*/

                            //AMI 16/10/17 : getDescribeOptimisation
                            listIAMFiltered = findBestMatch('CrossReference__c', 
                                                                listIAMFiltered,
                                                                listCriterias[i]/*,
                                                                fieldMapBMatch,
                                                                setDescribedBMatchFields,
                                                                mapBMatchFieldType*/);
                        }
                    }
                }
                
                //putting the OEM and its substitute(IAM) in a map
                if(listIAMFiltered.size() > 0
                    || mapOEMPrefType.size() > 0){
                    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                    if (mapOEMPrefType.containskey(OEMKey)
                        && checkPreferred && (listIAMFiltered.size() == 0 ||
                            ( (!isNONAXA && listIAMFiltered.size() > 0 && listIAMFiltered[0].Price_to_Compare__c > mapOEMPrefType.get(OEMKey).Price_to_Compare__c) 
                                || (isNONAXA && listIAMFiltered.size() > 0 && listIAMFiltered[0].Price_to_CompareNONAXA__c > mapOEMPrefType.get(OEMKey).Price_to_CompareNONAXA__c))
                     ) ){
                        mapIAMfinal.put(OEMKey,mapOEMPrefType.get(OEMKey));
                    }
                    else if(listIAMFiltered.size() > 0){
                        mapIAMfinal.put(OEMKey,listIAMFiltered[0]);
                    }
                }
        
            
            }

            //build map of entity and map of OEM and list of IAM to substituted
            
            if(!mapAssmapOEMKeylistIAM.containsKey(assNum)){
                mapAssmapOEMKeylistIAM.put(assNum, mapAssOEMKeylistIAM.get(assNum));
            }

            //build map of entity and map of OEM and substituted IAM
            if(!mapAssessmentIAMfinal.containsKey(assNum)){
                mapAssessmentIAMfinal.put(assNum, mapIAMfinal);
            }
        }
    }

    //method to find a list of best Match (e.g Best list IAM-crossReference)
    //AMI 16/10/17 : getDescribeOptimisation
    //public static list<SObject> findBestMatch(String objectName, list<SObject> sObjectList,DetailRule__c criteria){
    /*public static list<SObject> findBestMatch(
        String objectName, 
        list<SObject> sObjectList,
        DetailRule__c criteria,
        Map<String, Schema.SobjectField> fieldMapBMatch,
        set <string> setDescribedBMatchFields,
        map <string,Schema.DisplayType> mapBMatchFieldType){*/
    public static list<SObject> findBestMatch(
        String objectName, 
        list<SObject> sObjectList,
        DetailRule__c criteria/*,
        Map<String, Schema.SobjectField> fieldMapBMatch,
        set <string> setDescribedBMatchFields,
        map <string,Schema.DisplayType> mapBMatchFieldType*/){

        system.debug('#### ASPISServiceSubstitution.findBestMatch START');
        
        //String type to represent field type
        String type = '';
        //list of values after filtering
        list <SObject> listBestMatch = new list <SObject>();
        //A double to assigh the temporary value to compare
        Double tempValue = 0.00;
        
        /*//A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe();    
        //objectType is the object type
        Schema.SObjectType objectType = gloDesc.get(objectName);
        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMap = objectType.getDescribe().fields.getMap();*/

        // check if list of objects to filter is not empty
        if(!sObjectList.isEmpty()){ 
            
            //getting the type of the field using getDescribe()
            //type = String.valueOF(fieldMap.get(criteria.FieldsAPI__c).getDescribe().getType());

            //AMI 16/10/17 : getDescribeOptimisation
            if(!setDescribedBMatchFields.contains(criteria.FieldsAPI__c.toUpperCase())){
                setDescribedBMatchFields.add(criteria.FieldsAPI__c.toUpperCase());

                Schema.DisplayType tempType = fieldMapBMatch.get(criteria.FieldsAPI__c.toLowerCase()).getDescribe().getType();

                mapBMatchFieldType.put(criteria.FieldsAPI__c.toUpperCase(),tempType);

                type = string.valueOf(tempType);
            }else{
                if(mapBMatchFieldType.containsKey(criteria.FieldsAPI__c.toUpperCase())){
                    type = string.valueOf(mapBMatchFieldType.get(criteria.FieldsAPI__c.toUpperCase()));
                }else{
                    type = '';
                }
            }

            //if field type is currency or number
            if(type == 'CURRENCY' || type == 'NUMBER'){
                //temporary value use to compare
                tempValue = Double.valueOf(sObjectList[0].get(criteria.FieldsAPI__c));
                //looping through list of object to filter
                for(SObject cf : sObjectList){
                    //if opreator is minimum
                    if(criteria.Operator__c == 'MIN'){
                        //compare value, if less than temp value, clear list and add new value
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) < tempValue){
                            listBestMatch.clear();
                            listBestMatch.add(cf);
                            tempValue = Double.valueOf(cf.get(criteria.FieldsAPI__c));
                        }
                        //else if equal add in list
                        else if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) == tempValue){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is maximum
                    else if(criteria.Operator__c == 'MAX'){
                        //compare value, if greater than temp value, clear list and add new value
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) > tempValue){
                            listBestMatch.clear();
                            listBestMatch.add(cf);
                            tempValue = Double.valueOf(cf.get(criteria.FieldsAPI__c));
                        }
                        //else if equal add in list
                        else if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) == tempValue){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is equals 
                    else if(criteria.Operator__c == 'EQUALS'){
                        //if current object field value equals criteria value, add in list
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) == Double.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is greater than
                    else if(criteria.Operator__c == 'GREATER'){
                        //if current object field value is greater than criteria value, add in list
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) > Double.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is greater than or equals to
                    else if(criteria.Operator__c == 'GREATER_EQUALS'){
                        //if current object field value is greater than or equals to criteria value, add in list
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) >= Double.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is less than
                    else if(criteria.Operator__c == 'LESS'){
                        //if current object field value is less than criteria value, add in list
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) < Double.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                    //else if opreator is less than or equals to
                    else if(criteria.Operator__c == 'LESS_EQUALS'){
                        //if current object field value is less than or equals to criteria value, add in list
                        if(Double.valueOf(cf.get(criteria.FieldsAPI__c)) <= Double.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                }
            }
            else if (type == 'PICKLIST'){
                //temporary value use to compare
                String tempValueStr = String.valueOf(sObjectList[0].get(criteria.FieldsAPI__c));
                //looping through list of object to filter
                for(SObject cf : sObjectList){
                    //else if opreator is equals 
                    if(criteria.Operator__c == 'EQUALS'){
                        //if current object field value equals criteria value, add in list
                        if(String.valueOf(cf.get(criteria.FieldsAPI__c)) == String.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                    else if(criteria.Operator__c == 'NOT_EQUALS'){
                        //if current object field value equals criteria value, add in list
                        if(String.valueOf(cf.get(criteria.FieldsAPI__c)) != String.valueOf(criteria.Value__c)){
                            listBestMatch.add(cf);
                        }
                    }
                }
                System.debug('<<<<<listBestMatch>>>>>' + listBestMatch);
            }
        }
        system.debug('#### ASPISServiceSubstitution.findBestMatch END');
        //return a list of best match obtained
        return listBestMatch;
    }

    //method to run Validation for an entity , a set of parts tech id
    //DUN 13/10/17 : Case 1994 Validation logic string
    public static map<String,PartList__c> runValidation(list<DetailRule__c> listValidationCriteria, list<DetailRule__c> listUpdateFieldsCriteria ,set<String> setPartListTechId, String entityCode, String validationConditionLine){
        system.debug('#### ASPISServiceSubstitution.runValidation START:');
        //list of partlist to update
        list<PartList__c> listPartListtoUpdate = new list<PartList__c>();
        //map of partlist to update
        map<String,PartList__c> mapTechIdPartListtoUpdate = new map<String,PartList__c>();
        //String query to select required partlist
        String partlistQuery = 'Select ';
        //String query to select required partlist
        //* Ruksaar L    29/04/2019  C-003142 Cross Ref Sourcing R4 for Spain
        String partlistQueryFields = 'Id, TECH_OriginalPart__c,TECHDistList__c, Assessment__c  ';//WCH 30/08/2018 C-002754: add TECHDistList__c field        //String query to select required partlist
        //String query to select required partlist
        String partlistQueryCondition =  ' where TECH_OriginalPart__c in: setPartListTechId ';
        //String operator value use for query
        String operator;
        //String sObject value use for query
        String objectName;
        //Boolean canQuery true if query is valid
        Boolean canQuery = false;
        //map of number and its condition
        map<String,String> mapNumCondition = new map<String,String>();

        //AMI 16/10/17 : getDescribeOptimisation
        /***update field global describe variable***/
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDescribe = Schema.getGlobalDescribe();  
        
        //objectType is the object type
        Schema.SObjectType objectTypeUpdateF = gloDescribe.get('PartList__c');
        
        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMapUpdateF = objectTypeUpdateF.getDescribe().fields.getMap();

        //this set is used to know if field was already described
        set <string> setDescribedUpdateF = new set <string>();

        //map used so that getDescribe is run only one time for fieldtype for best match method
        map <string,Schema.DisplayType> mapUpdateFFieldType = new map <string,Schema.DisplayType>();

        //check if there are validation detail rules 
        if(listValidationCriteria.size() > 0){
            //looping through a list of detail rules
            for(DetailRule__c detRule : listValidationCriteria){
                canQuery = true;
                if(detRule.Operator__c == 'EQUALS'){
                    operator = ' = ';
                }
                else if(detRule.Operator__c == 'NOT_EQUALS'){
                    operator = ' != ';
                }
                else if(detRule.Operator__c == 'GREATER'){
                    operator = ' > ';
                }
                else if(detRule.Operator__c == 'GREATER_EQUALS'){
                    operator = ' >= ';
                }
                else if(detRule.Operator__c == 'LESS'){
                    operator = ' < ';
                }
                else if(detRule.Operator__c == 'LESS_EQUALS'){
                    operator = ' <= ';
                }
                else if(detRule.Operator__c == 'LIKE'){
                    operator = ' like ';
                }
                //add more operators
                if(!partlistQueryFields.contains(detRule.FieldsAPI__c) && !detRule.FieldsAPI__c.contains('NOT')){
                    partlistQueryFields += ' , ' + detRule.FieldsAPI__c;
                }
                
                //DUN 13/10/2017 case 1994 
                //partlistQueryCondition += 'and ' + detRule.FieldsAPI__c + operator + '\'' + detRule.Value__c +'\'' ;
                // ASE: 21/05/18: C-002600 
                String detailLineValue = detRule.FieldsAPI__c + operator +' \'' + detRule.Value__c +'\'';
                if(detRule.Value__c == 'TRUE' || detRule.Value__c == 'FALSE'){
                    detailLineValue = detRule.FieldsAPI__c + operator +' ' + detRule.Value__c +' ';
                }
                mapNumCondition.put(String.valueOf(detRule.Number__c), detailLineValue);

                objectName = detRule.sObject__c;

            }
            system.debug('## mapNumCondition' + mapNumCondition);

            //DUN 13/10/17 : Case 1994 Validation logic string
            if(mapNumCondition.size() > 0 && validationConditionLine != null){
                for(String Num : mapNumCondition.keySet()){
                    validationConditionLine = validationConditionLine.replace(Num, mapNumCondition.get(Num));
                    system.debug('## validationConditionLine' + validationConditionLine);
                }
                partlistQueryCondition += ' and ' + validationConditionLine ;
            }
            
            partlistQuery += partlistQueryFields + ' from ' + objectName + partlistQueryCondition; 
        }
        if(canQuery){
            system.debug('## partlistQuery '+partlistQuery);            
            for(PartList__c pl : database.query(partlistQuery)){
                if(setPartListTechId.contains(pl.TECH_OriginalPart__c)){
                    listPartListtoUpdate.add(pl);
                }
            }
        }

        /*
        for(PartList__c pl:(list<PartList__c>)updateField(listPartListtoUpdate,'PartList__c',listUpdateFieldsCriteria)){
            mapTechIdPartListtoUpdate.put(pl.TECH_OriginalPart__c,pl);
        }*/
        

        //AMI 16/10/17 : getDescribeOptimisation
        for(PartList__c pl:(list<PartList__c>)updateField(listPartListtoUpdate,
                                                            'PartList__c',
                                                            listUpdateFieldsCriteria,
                                                            fieldMapUpdateF,
                                                            setDescribedUpdateF,
                                                            mapUpdateFFieldType)){
            mapTechIdPartListtoUpdate.put(pl.TECH_OriginalPart__c,pl);
        }
        
        system.debug('#### ASPISServiceSubstitution.runValidation END');

        return mapTechIdPartListtoUpdate;
    }

    //method to update fields for a list of object
    //AMI 16/10/17 : getDescribeOptimisation
    //public static list<SObject> updateField(list<SObject> listsObjectFieldsToUpdate, String sObjectName, list<DetailRule__c> listFieldUpdatesDetailRules){
    public static list<SObject> updateField(
        list<SObject> listsObjectFieldsToUpdate, 
        String sObjectName, 
        list<DetailRule__c> listFieldUpdatesDetailRules,
        Map<String, Schema.SobjectField> fieldMapUpdateF,
        set <string> setDescribedUpdateF,
        map <string,Schema.DisplayType> mapUpdateFFieldType){   
        system.debug('#### ASPISServiceSubstitution.updateField START');
        
        /*//A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe();    
        //objectType is the object type
        Schema.SObjectType objectType = gloDesc.get(sObjectName);
        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMap = objectType.getDescribe().fields.getMap();*/

        //currentFieldDisplayType to represent field type
        Schema.DisplayType currentFieldDisplayType;

        //list of sObjects to apply field update
        list<SObject> listsObjectFieldsUpdated = new list<SObject>();

        //looping through list of sObject
        for(SObject sObj : listsObjectFieldsToUpdate){
            //looping through detail rules to put value in field
            for(DetailRule__c updateField : listFieldUpdatesDetailRules){

                //currentFieldDisplayType = fieldMap.get(updateField.FieldsAPI__c).getDescribe().getType();

                //AMI 16/10/17 : getDescribeOptimisation
                if(!setDescribedUpdateF.contains(updateField.FieldsAPI__c.toUpperCase())){
                    setDescribedUpdateF.add(updateField.FieldsAPI__c.toUpperCase());

                    Schema.DisplayType tempType = fieldMapUpdateF.get(updateField.FieldsAPI__c.toLowerCase()).getDescribe().getType();

                    mapUpdateFFieldType.put(updateField.FieldsAPI__c.toUpperCase(),tempType);

                    currentFieldDisplayType = tempType;
                }else{
                    if(mapUpdateFFieldType.containsKey(updateField.FieldsAPI__c.toUpperCase())){
                        currentFieldDisplayType = mapUpdateFFieldType.get(updateField.FieldsAPI__c.toUpperCase());
                    }else{
                        currentFieldDisplayType = null;
                    }
                }

                if( currentFieldDisplayType == Schema.DisplayType.Id ||
                    currentFieldDisplayType == Schema.DisplayType.String ||
                    currentFieldDisplayType == Schema.DisplayType.Picklist ||
                    currentFieldDisplayType == Schema.DisplayType.TextArea ||
                    currentFieldDisplayType == Schema.DisplayType.Address ||
                    currentFieldDisplayType == Schema.DisplayType.Phone ||
                    currentFieldDisplayType == Schema.DisplayType.URL ||
                    currentFieldDisplayType == Schema.DisplayType.EncryptedString ||
                    currentFieldDisplayType == Schema.DisplayType.Email ||
                    currentFieldDisplayType == Schema.DisplayType.MultiPicklist){
                    sObj.put(updateField.FieldsAPI__c,String.valueOf(updateField.Value__c));
                }
                else if(currentFieldDisplayType == Schema.DisplayType.Currency ||
                        currentFieldDisplayType == Schema.DisplayType.Integer ||
                        currentFieldDisplayType == Schema.DisplayType.Double ||
                        currentFieldDisplayType == Schema.DisplayType.Percent){
                    sObj.put(updateField.FieldsAPI__c,Double.valueOf(updateField.Value__c));
                }
                else if(currentFieldDisplayType == Schema.DisplayType.Date){
                    sObj.put(updateField.FieldsAPI__c,Date.valueOf(updateField.Value__c));
                }
                else if(currentFieldDisplayType == Schema.DisplayType.DateTime){
                    sObj.put(updateField.FieldsAPI__c,DateTime.valueOf(updateField.Value__c));
                }
                else if(currentFieldDisplayType == Schema.DisplayType.Boolean){
                    sObj.put(updateField.FieldsAPI__c,Boolean.valueOf(updateField.Value__c));
                }
            }
            listsObjectFieldsUpdated.add(sObj);
        }
        system.debug('#### ASPISServiceSubstitution.updateField END');

        return listsObjectFieldsUpdated;
    }

    // ABT - 26-AUG-2016 - C-001710
    public static String cleanseReference(String referenceToCleanse)
    {
            return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
        }
//RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
    public static String checkPrefixOnPartNumber(String partNumber){
        // if (partNumber.startsWith('A')){
        //     return partNumber.right(partNumber.length() - 1);
        // }
        // else{
            return 'A' + partNumber;
        // }
    }

    //RLA 28/01/2020 C-003524 : Change Recommended part in France  
    public static map<Integer,list <CrossReference__c>> rankingOfCrossRefs(List<CrossReference__c> lstXrefs){
        //map which contains the partType and its priority derived from masterRule
        // map<String,Integer> mapPartTypePriority = new map<String,Integer>{'A'=> 1, 'B'=> 1,'C'=> 3,'E'=> 2,'D' => 3};
        //map which contains prioritised partlists
        System.debug('<<<<<lstXrefs>>>>>' + lstXrefs);

        map<Integer,list <CrossReference__c>> mapPriotisedXrefs  = new map<Integer, list<CrossReference__c>>();
        for (integer i=0; i<20; i++){
            mapPriotisedXrefs.put(i, new list<CrossReference__c>()); 
        }

        //loop in partlists
        FOR (CrossReference__c xrefs: lstXrefs ){
            System.debug('<<<<<xrefs>>>>>' + xrefs.Ocurrences__r);
            
            if (mapPartTypePriority.containskey(xrefs.IAMPartClass__c )){
                //Add partType to map according to its priority
                if (mapPriotisedXrefs.containskey(mapPartTypePriority.get(xrefs.IAMPartClass__c))){
                    mapPriotisedXrefs.get(mapPartTypePriority.get(xrefs.IAMPartClass__c)).add(xrefs);
                }
                else{
                    mapPriotisedXrefs.put(mapPartTypePriority.get(xrefs.IAMPartClass__c), new list<CrossReference__c>{xrefs});
                }            
            }
        }//endfor

        system.debug('@@ mapPriotisedXrefs: '+mapPriotisedXrefs);
        return mapPriotisedXrefs;
    }
    
    public static map<String, set<String>> createMapAssmntIamManu (String customLabel){
        // String s = system.label.CS_XrefExceptions;
		// system.debug(s);
		map<String, set<String>> mapAssmntToolIamManu = new map<String, set<string>>();

		List<String> lstAssmntToolIamMan = customLabel.split(';');
        for (string assmntToolIamMan: lstAssmntToolIamMan ){
        
            if (assmntToolIamMan.contains(':')){
                 String assmntTool = (assmntToolIamMan.split(':'))[0];
                 String iamManu =  (assmntToolIamMan.split(':'))[1];
                if (String.isNotBlank(iamManu)){
                    // iamManu = iamManu.toUpperCase();
                    set<string> setIamManu = new set<String>();
                    if (iamManu.contains(',')){
                        setIamManu.addAll(iamManu.split(',')); 
                    }
                    else{
                        setIamManu.add(iamManu);
                    }
                    system.debug(iamManu );
                    system.debug(assmntTool );
                    mapAssmntToolIamManu.put(assmntTool , setIamManu );
                }
            
            }
        
        }
        
        system.debug(mapAssmntToolIamManu);
        
        return mapAssmntToolIamManu;
    }

      //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop 
    public static CrossReference__c getlowestPricedCrossref(List<CrossReference__c> lstXrefs, String preferredType){

        CrossReference__c lowestPricedXref;
        
        Decimal lowestPrice;
        //loop in CrossReference__c
        For (CrossReference__c xrefs: lstXrefs ){
            system.debug('@@ preferredType: '+preferredType);
            system.debug('@@ xrefs.IAMPartClass__c: '+xrefs.IAMPartClass__c);
            
            if (preferredType == xrefs.IAMPartClass__c ){
                system.debug('@@ Parttype is preferredType: '+xrefs.Price_to_Compare__c);

                if (lowestPrice == null){
                    
                    lowestPrice = isnonAxa ? xrefs.Price_to_CompareNONAXA__c :  xrefs.Price_to_Compare__c;
                    lowestPricedXref = xrefs;
                }                
                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                if ( (!isnonAxa && xrefs.Price_to_Compare__c < lowestPrice) || (isnonAxa && xrefs.Price_to_CompareNONAXA__c < lowestPrice )) {
                    lowestPrice = isnonAxa ? xrefs.Price_to_CompareNONAXA__c : xrefs.Price_to_Compare__c;
                    lowestPricedXref = xrefs;
                }         
            }
        }//endfor

        system.debug('@@ lowestPricedXref: '+lowestPricedXref);
        return lowestPricedXref;
    }
    //HRM 19/11/21 Italy substitution
    public static map<String, Object> canBeSubstitutedOrNot(Map<String,Object>mapInputParams){
        system.debug('HRM Inside canBeSubstitutedOrNot '+mapInputParams);
        Map<String,Object> mapOutputParams = new map<String,Object>();
        Boolean issubstitutable = false;
        if(mapInputParams.containsKey('Assessment')){
            issubstitutable=processObjForCanBeSubstituted((Assessment__c)mapInputParams.get('Assessment'));
        }
        mapOutputParams.put('issubstitutable',issubstitutable);
        return mapOutputParams;
    }
    public static boolean  processObjForCanBeSubstituted(Assessment__c assess){
        system.debug('HRM assess.EntityCode__c: '+assess.EntityRules__c);
        Boolean isValid = false;
        String substituionFailure = '';
        String naturalLanguage;
        String rulesExpression = '';

        list<MasterRules__c> rules = [SELECT id, Entity__c, Process__c, RuleStatus__c, sObject__c, FilterLogic__c, version__c,Name,LogicSubstitutionCriteria__c,Filter_Logic_BDG__c,
                                            (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, ValueFrom__c, Number__c,
                                                recordtypeId, recordtype.DeveloperName
                                                FROM DetailRules__r 
                                                WHERE recordtype.DeveloperName =: system.Label.RECORDTYPESUBSTITUTIONCRITERIARULENAME
                                                ORDER BY sObject__c ASC)
                                            FROM MasterRules__c
                                            WHERE Process__c    =: system.Label.PROCESSSUBSTITUTIONLABEL
                                            AND Entity__c       =: assess.EntityRules__c
                                            AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL
                                            AND LogicSubstitutionCriteria__c   != null];
                                            
        if(rules.size()>0){
            system.debug('HRM Substitution criteria Rules:  ' + rules);
            Map<Decimal,Boolean> rulesMap = new Map<Decimal,Boolean>();
            Map<Decimal,String> rulesMapDebug = new Map<Decimal,String>();
            List<String> SLogic = new List<String>();
            
            for(MasterRules__c rul:rules){
                if(rul.LogicSubstitutionCriteria__c!=null){
                    SLogic.addAll(rul.LogicSubstitutionCriteria__c.replace('(','( ').replace(')',' )').split(' '));
                }
                // naturalLanguage = rul.Process__c+' - ' + rul.version__c +' - ' +rul.Name+ '\n';
                // naturalLanguage += 'Rule IsSubstitutionAllowed'+ '\n';
                
                // sourceEligibilityFailure = '';
                
                if(rul.DetailRules__r.size()>0){
                    for(DetailRule__c det:rul.DetailRules__r){
                        if(det.sObject__c == string.valueOf(assess.getSObjectType())){
                            det.Value__c = det.Value__c.toUpperCase();
                            rulesMap.put(det.Number__c,ASPISTools.applyRuleOnObject(new ASPISTools.filterCriteria( assess,det.FieldsAPI__c,det.Operator__c,det.Value__c,null)));
                        }                       
                    }
                }
            }
            if(rulesMap.size()>0 && SLogic.size()>0){
                Boolean boolResult = null;

                for(Integer i=0;i<SLogic.size();i++){
                    if(!SLogic[i].isNumeric() && SLogic[i] == system.Label.OPERATORAND){
                        rulesExpression +=' &&';
                        if(boolResult!=null){
                            if (rulesMap.get(Decimal.valueOf(SLogic[i+1])) != null){
                                boolResult &= rulesMap.get(Decimal.valueOf(SLogic[i+1]));
                            }
                        }
                    }else if(!SLogic[i].isNumeric() && SLogic[i] == system.Label.OPERATOROR){
                        rulesExpression +=' ||';
                        if(boolResult!=null)
                            if (rulesMap.get(Decimal.valueOf(SLogic[i+1])) != null){
                                boolResult |= rulesMap.get(Decimal.valueOf(SLogic[i+1]));
                            }
                    }else if(SLogic[i].isNumeric()){
                        rulesExpression += rulesMap.get(Decimal.valueOf(SLogic[i]));
                        if(boolResult==null)
                            boolResult = rulesMap.get(Decimal.valueOf(SLogic[i]));
                    }else{
                        rulesExpression +=' '+SLogic[i];
                    }
                }
                system.debug('HRM rulesExpression: '+rulesExpression);
                if(boolResult!=null){
                    isValid = (!boolResult);
                }
            }
            else{
                isValid = true;
            }
        }
        else{
            isValid = true;
        }
    
        return isValid;
    }
    
}