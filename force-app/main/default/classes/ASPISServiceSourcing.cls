public without sharing class ASPISServiceSourcing{
/*************************************************************************************
Class Name - ASPISServiceSourcing
Version - 1.0
Created Date - 07 AUG 2017
Function - Class to Process Sourcing

Modification Log :
-------------------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------                    
* Abdool M              04/08/2017  Initial Version (Modulating methods so that 
*                                   they can be called individually anywhere
* Abdool M              07/09/2017  Added new methods param to createOrders 
  --                                (due to distributor intgegration)
* Abdool M              13/10/2017  getDescribeOptimisation 
* Abdool M              27/10/2017  C-002041 - Distributor V2 - prevent soql 
  --                                         - due to dml exception in upsertAss
* Abdool M              07/11/2017  Sourcing error during validate
* Dourga                09/01/2018  C-002135 : Agency Mode V2
* Dourga U              29/01/2018  C-002174 - Avoid running again Eligibility and sourcing  
* Ruksaar L             10/04/2018  C-002447 - Upsert takes into account Postal Code field
* Ashwina S             08/05/2018  C-002278 - FR - New Distributor PSA 
* Dourga                28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode
* Ruksaar L             03/08/2018  C-002701 - Apex error lors de la modification d'un chiffrage
* Welsa C               13/03/2020  C-003665 - MRSourcing field is not populated on R3 assessment when Clear Assessment button is used
*************************************************************************************/    
    public static sourcingWrapper processObjForSourcing(Assessment__c assRecord,boolean isTrigger,map <id, Account> bsRefAccountMap,map <string,string> mapAssessIdFinalPartType){
        system.debug('## processObjForSourcing executeProcess method');

        map <String, String> querySourcingMap = new Map<String, String>();
        String naturalLanguage='';

        //DUN 09/01/2018  C-002135 : Agency Mode V2
        //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode -> commented line below
        //Integer numNotAgencyMode = 0;

        //AMI 04/08/17
        LanguageAndQueryWrapper langQuery; 

        sourcingWrapper wrap = new sourcingWrapper(new list <Account>(),assRecord);

        system.debug('## ASPISConstants.manualSourcingPO' + ASPISConstants.manualSourcingPO);
        if(ASPISConstants.manualSourcingPO == true){
            assRecord.EntityRules__c += '(2)';
        }

        if(assRecord!=null && (assRecord.TECHRulesAppliedDescription__c!=null)){
            naturalLanguage = assRecord.TECHRulesAppliedDescription__c + '\n\n';
        }

        string removeSourcingLines= naturalLanguage.substringBefore('SOURCING');
        naturalLanguage = removeSourcingLines;

        //AMI 27/10/17 : C-002041 - Distributor V2 - adding new param to method LanguageAndQueryWrapper
        //                                         - this new param will enable us to get info based on BS since we
        //                                         - will no longer query assessment
        //AMI 04/08/17
        langQuery = returnNatLanAndQuery(naturalLanguage,assRecord,bsRefAccountMap,mapAssessIdFinalPartType,isTrigger);

        naturalLanguage = langQuery.natLanguage;
        querySourcingMap = langQuery.mapQuerySourcing;

        if(ASPISConstants.manualSourcingPO == true &&  assRecord.EntityRules__c.endsWith('(2)')){
            assRecord.EntityRules__c = assRecord.EntityRules__c.removeEnd('(2)');
        }

        List<Account> listAccountFiltered = getAccountFiltered(querySourcingMap); 

        system.debug('## listAccountFiltered before: '+listAccountFiltered);

        //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode -> move map outside of if condition
        //map<id, Account> AccountFilteredMap = new map<id, Account>(listAccountFiltered); //commented by RLA
        map<id, Account> AccountFilteredMap = new map<id, Account>(); 

        //RLA 03/08/2018  C-002701 - Apex error lors de la modification d'un chiffrage
        for (account acc : listAccountFiltered){
            AccountFilteredMap.put(acc.Id, acc);
        }
        system.debug('## AccountFilteredMap before: '+AccountFilteredMap);

        // ASE: 08/05/18: C-002278   
        // ASE: 05/10/18 : C-002822- added assRecord.MRSourcing__c != 'false'            
        if(assRecord.MRSourcing__c != null && assRecord.MRSourcing__c != '' && assRecord.MRSourcing__c != 'false'){
            list<String> distList = (assRecord.MRSourcing__c).split(';');
            for(String dist: distList){
                if(!AccountFilteredMap.containsKey(Id.valueOf(dist))){
                    listAccountFiltered.add(new Account(Id = Id.valueOf(dist)));
                }
            }
        }
        system.debug('## listAccountFiltered: '+listAccountFiltered);
       // AccountFilteredMap = new map<id, Account>(listAccountFiltered);//commented by RLA

        //RLA 03/08/2018  C-002701 - Apex error lors de la modification d'un chiffrage
        for (account acc : listAccountFiltered){
            AccountFilteredMap.put(acc.Id, acc);
        }

        
        //DUN 09/01/2018  C-002135 : Agency Mode V2 -- to calculate number of Distributors not in agency
        //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode 
        //if(!listAccountFiltered.isEmpty()){
        //    numNotAgencyMode = countCanceledAgencyAssessment(assRecord, listAccountFiltered);
        //}
        if(!AccountFilteredMap.isEmpty()){
            listAccountFiltered = countCanceledAgencyAssessment(assRecord, AccountFilteredMap);
        }
        wrap.distributorLst = listAccountFiltered; 

        system.debug('## listAccountFiltered.size(): '+listAccountFiltered.size());
        //system.debug('## numNotAgencyMode: '+numNotAgencyMode);

        //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode -> removed  && listAccountFiltered.size() > numNotAgencyMode
        if(!listAccountFiltered.isEmpty()){
            if(assRecord.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()){
                if(isTrigger){
                    assRecord.Status__c = 'NEW';
                }else{
                    wrap.ass.Status__c = 'NEW';
                }
            }
            else{
                if(isTrigger){
                    assRecord.Status__c = system.Label.ASSESSMENTSTATUSSOURCEDLABEL;
                    //AMI 07/09/17 - Added new methods param (due to distributor intgegration)
                    ASPISPurchaseOrder.createOrders(assRecord, listAccountFiltered,'',null,new set <id>(),new map <id,Account>()); 
                }else{
                    wrap.ass.Status__c = system.Label.ASSESSMENTSTATUSSOURCEDLABEL;
                }
            }

            naturalLanguage += 'Results: Number of Purchase orders: '+ listAccountFiltered.size() +'\n';

            if(isTrigger){
                assRecord.TECHRulesAppliedDescription__c = naturalLanguage; 
            }else{
                wrap.ass.TECHRulesAppliedDescription__c = naturalLanguage; 
            }
        }
        //else if(!listAccountFiltered.isEmpty() && listAccountFiltered.size() == numNotAgencyMode){
        //    if(isTrigger){
        //        assRecord.Status__c = 'CANCELED';
        //        assRecord.ReasonFailure__c = 'NotAgency';
        //    }else{
        //        wrap.ass.Status__c = 'CANCELED';
        //        wrap.ass.ReasonFailure__c = 'NotAgency';
        //    }
        //}
 
        else if (listAccountFiltered.isEmpty()){
            naturalLanguage += 'Results: Number of Purchase orders: 0 \n';
            if(isTrigger){
                assRecord.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                //if(assRecord.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()){
                //    assRecord.Status__c = 'NEW';
                //}
                //else{
                    assRecord.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                     
                     assRecord.TECHRulesAppliedDescription__c = naturalLanguage; 
                //}
            }else{
                wrap.ass.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                //if(assRecord.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()){
                //    wrap.ass.Status__c = 'NEW';
                //}
                //else{
                    wrap.ass.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                    wrap.ass.TECHRulesAppliedDescription__c = naturalLanguage; 
                //}
            }
        }

        //DUN 29/01/2018 C-002174 - set boolean MRSourcing__c on claim assessment
        if(!listAccountFiltered.isEmpty() && (assRecord.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() 
        || assRecord.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() /* WCH 13/03/2020 C-003665 */ )){
            String listDistributors = '';
            for(Account acc : listAccountFiltered){
                listDistributors += acc.Id + ';' ;
            }
            listDistributors = listDistributors.removeEnd(';');
            if(isTrigger){
                assRecord.MRSourcing__c = listDistributors;
            }
            else{
                wrap.ass.MRSourcing__c = listDistributors;
            }
        }
        
        
        return wrap;
    }

    //AMI 04/08/17 : wrapper to store natural language and querySourcingMap
    public class LanguageAndQueryWrapper{
        public string natLanguage;
        public map <string,string> mapQuerySourcing;

        public LanguageAndQueryWrapper(string natLanguage,map <string,string> mapQuerySourcing){
            this.natLanguage = (string.isNotBlank(natLanguage)) ? natLanguage : '';
            this.mapQuerySourcing = (mapQuerySourcing.size()>0) ? mapQuerySourcing : new map <string,string>();
        }
    }

    //AMI 07/08/17 : wrapper to return distributors and updated assessement
    public class sourcingWrapper{
        public List<Account> distributorLst;
        public Assessment__c ass;
        public sourcingWrapper(List<Account> distributorLst,Assessment__c ass){
            this.distributorLst = distributorLst;
            this.ass = ass;
        }
    }

    // get sOBject from Filter Condition
    // List<MasterRules__> must have the same Master Object
    public static sObject getSOBjectFromFilterCondition(List<MasterRules__c> mRules, Id objId) {
        sObject objToQuery;
    
        Set<String> fieldSet = new Set<String> {'Id'};
        for(MasterRules__c masRule : mRules){
            if(masRule.DetailRules__r != null){
                for(DetailRule__c detRule : masRule.DetailRules__r){
                    if(detRule.RecordType.DeveloperName == 'FILTERCONDITION'){
                        if(detRule.ValueFrom__c == 'Master sObject'){
                            fieldSet.add(detRule.Value__c);
                        }
                    }
                }
            }
        }
       
        String queryFilter;
        if (!fieldSet.isEmpty()) {
            List<String> listStrings = new List<String>(fieldSet);
             System.debug('LIST FIELDSET : ' + listStrings);
            queryFilter = 'SELECT ' + String.join(listStrings, ', ') + ' FROM ' + objId.getSobjectType().getDescribe().getName() + ' WHERE Id =: objId' ;
        }

        if(queryFilter != ''){
            objToQuery = Database.query(queryFilter);
        }

        return objToQuery;
    }

    // get Accounts matching Master Rules for Sourcing
    public static List<Account> getAccountFiltered(Map<String, String> querySourcingMap) {
        Set<Account> accountFilteredSet = new Set<Account>();

        String distribPriceApiName = DistributorPrice__c.getSobjectType().getDescribe().getName();
        String accountApiname = Account.getSobjectType().getDescribe().getName();

        for (String query : querySourcingMap.keySet()) {
            String objFromQuery = querySourcingMap.get(query);

            System.debug('query='+  query);
            // soql query in loop: not recommanded but acceptable (we should not several queries)
            for (sObject sObj : Database.query(query)) {
                if (distribPriceApiName.equalsIgnoreCase(objFromQuery)) {
                    DistributorPrice__c dp = (DistributorPrice__c) sObj;
                    accountFilteredSet.add(new Account(Id = dp.DistributorID__c, Categories__c = dp.DistributorID__r.DistributorRegionsCovered__c));
                    // TODO TEMP 'SAS Blois' FR distributor must be set instead of SAS FR Distributor
                    /* if (String.isNotBlank(dp.DistributorBisID__c)) {
                        //accountFilteredSet.add(new Account(Id = dp.DistributorBisID__c));                        
                    } else {
                        accountFilteredSet.add(new Account(Id = dp.DistributorID__c));
                    }*/
                } else if (accountApiname.equalsIgnoreCase(objFromQuery)) {
                    Account acc = (Account) sObj;
                    accountFilteredSet.add(new Account(Id = acc.Id, Categories__c = acc.Categories__c));
                }
            }
        }

        return new List<Account>(accountFilteredSet);
    }

    //DUN 09/01/2018  C-002135 : Agency Mode V2
    //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode -> returning a list of Accounts instead of a count 
    //public static Integer countCanceledAgencyAssessment(Assessment__c assessment, list<Account> listSelecteddistributors){
    public static List<Account> countCanceledAgencyAssessment(Assessment__c assessment, map<Id,Account> mapSelecteddistributors){
        system.debug('## Start countCanceledAgencyAssessment');
        Integer countCanceledAss = 0;

        map<Id,Account> mapaccounts =  new Map<Id, Account>([select Id, DistributorCarBrandSupplied__c,CarBrandsSuppliedAgency__c from Account where Id =: assessment.BodyShop__c or id in: mapSelecteddistributors.keySet()]);
        
        for(Account dis : mapSelecteddistributors.values())
        {
            if(mapaccounts.containsKey(dis.Id) && 
               mapaccounts.containsKey(assessment.BodyShop__c) &&
               assessment.Manufacturer__c != null &&
               (mapaccounts.get(dis.Id).DistributorCarBrandSupplied__c == null ||
                (mapaccounts.get(dis.Id).DistributorCarBrandSupplied__c != null && 
                 !mapaccounts.get(dis.Id).DistributorCarBrandSupplied__c.contains(assessment.Manufacturer__c)
                )
               ) &&
               mapaccounts.get(dis.Id).CarBrandsSuppliedAgency__c != null && 
               mapaccounts.get(dis.Id).CarBrandsSuppliedAgency__c.contains(assessment.Manufacturer__c) &&
               (mapaccounts.get(assessment.BodyShop__c).CarBrandsSuppliedAgency__c == null ||
                (mapaccounts.get(assessment.BodyShop__c).CarBrandsSuppliedAgency__c != null && 
                 !mapaccounts.get(assessment.BodyShop__c).CarBrandsSuppliedAgency__c.contains(assessment.Manufacturer__c)
                )
               )
              )
            {
                //DUN 28/06/2018  C-002621 - Agency Mode Spain + Issue on Agrency mode -> returning a list of Accounts instead of a count 
                //countCanceledAss ++;
                mapSelecteddistributors.remove(dis.Id);
            }
        }
        system.debug('## End mapSelecteddistributors' + mapSelecteddistributors);
        return mapSelecteddistributors.values();
    }

    //AMI 27/10/17 : C-002041 - Distributor V2 - adding new param to method LanguageAndQueryWrapper
    //                                         - this new param will enable us to get info based on BS since we
    //                                         - will no longer query assessment
    //AMI 04/08/17 : build method to return natural language and querySourcingMap
    public static LanguageAndQueryWrapper returnNatLanAndQuery(string naturalLanguage,Assessment__c assRecord,map <id, Account> bsRefAccountMap,map <string,string> mapAssessIdFinalPartType, boolean isTrigger){
        system.debug('## Start LanguageAndQueryWrapper');

        LanguageAndQueryWrapper wrap = new LanguageAndQueryWrapper(naturalLanguage,new map <string,string>());
        
        string querySourcing = '',fields = '',objectToQuery = '',filter = '',filterLine = '',value = '',objId = assRecord.Id;
        
        map <String,String> mapNumFilter = new map <String,String>();
        map <String,String> queryMap = new map <String,String>();
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe();    

        //objectType is the object type
        Schema.SObjectType objectType = gloDesc.get('Assessment__c');

        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMap = objectType.getDescribe().fields.getMap();

        //ASE 22/11/2017
        //objectType is the object type
        Schema.SObjectType objectTypeDistributor = gloDesc.get('DistributorPrice__c');
        Map<String, Schema.SobjectField> fieldDistributorAPIMap = objectTypeDistributor.getDescribe().fields.getMap();
        map <string,Schema.DisplayType> mapDistributorFieldType = new map <string,Schema.DisplayType>();
        Schema.DisplayType currentFieldAPIDisplayType;

        //currentFieldDisplayType to represent field type
        Schema.DisplayType currentFieldDisplayType;

        list <String> splitVlaues = new list <String>();

                //AMI 27/10/17 : C-002041 - Distributor V2 - check if calling system is from distributor V2
        //                                         - if yes, add EntityRules__c to assessment provided as method param
        //                                         - since this info is populated though WF
        //Boolean to determine calling system
        Boolean isDistributorV2 = false;

        if(assRecord.PreviousStatus__c == 'DoNotExecuteWF' && !isTrigger  ){
            //set entity code
             //RLA 20/02/2018 case 2370 BE Issues
            if( assRecord.TECH_EntityCountryCode__c == 'BE'
                && assRecord.EntityCode__c != 'NONAXA'){
                assRecord.EntityRules__c =  'BEAXA';                
            }
            else{
                //set entity code
                assRecord.EntityRules__c = assRecord.TECH_EntityCountryCode__c + assRecord.EntityCode__c;
            }
            
            //set calling system boolean
            isDistributorV2 = true;
        }

        system.debug('## assRecord ' + assRecord);
        system.debug('## assRecord ' + assRecord.CrossReferences__c);
        list<MasterRules__c> mRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                            sObject__c, FilterLogic__c,version__c,Name,
                                        (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                            OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c
                                            FROM DetailRules__r 
                                            ORDER BY Number__c DESC)
                                        FROM MasterRules__c
                                        WHERE Process__c    =: system.Label.PROCESSSOURCINGLABEL
                                        AND Entity__c       =: assRecord.EntityRules__c
                                        AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];

        //AMI 13/10/17 : getDescribeOptimisation
        //map used so that getDescribe is run only one time for fieldtype
        map <string,Schema.DisplayType> mapFieldType = new map <string,Schema.DisplayType>();

        //map used so that getDescribe is run only one time for fieldlabel
        map <string,string> mapFieldLabel = new map <string,string>();
        
        //set used to know which sobject does not exist
        set <string> setSOjectNotSupported = new set <string>();

        //set used to know which field does not exist
        set <string> setFieldNotSupported = new set <string>();

        //set used to know which field label does not exist
        set <string> setLabelNotSupported = new set <string>();

        sObject objToQuery = null;

        //AMI 27/10/17 : C-002041 - Distributor V2 - check if calling system is from distributor V2
        //                                         - if yes, do not query assessment (work directly with assessment)
        //                                         - else query assessment together with BS info
        if(isDistributorV2){
            objToQuery = assRecord;
        }else{
            // get SOQL result to retrieve Assessment
            objToQuery = getSOBjectFromFilterCondition(mRules, objId); 
            system.debug('## objToQuery:'+objToQuery);         
          
            // force CrossReferences__c value            
            Boolean fieldExist = (objToQuery.getPopulatedFieldsAsMap()).containsKey('CrossReferences__c');           

            if(fieldExist && objToQuery.getSobjectType() == Schema.Assessment__c.getSObjectType() && objToQuery.get('CrossReferences__c') != null && objToQuery.get('CrossReferences__c') == 'None' && assRecord.CrossReferences__c != 'None'
                && assRecord.CrossReferences__c != '' //RLA
                ){
                objToQuery.put('CrossReferences__c', assRecord.CrossReferences__c);
            }
            system.debug('## objToQuery:'+objToQuery);
        }

        for(MasterRules__c masRule : mRules){
            if(masRule.DetailRules__r != null){
                fields = 'Id, Name ';
                filter = masRule.FilterLogic__c;
                
                wrap.natLanguage += masRule.Process__c+' - ' + masRule.version__c +' - ' +masRule.Name+ '\n';
                wrap.natLanguage += 'Rule Sourcing'+ '\n';

                for(DetailRule__c detRule : masRule.DetailRules__r){

                    value = '';
                    if(detRule.RecordType.DeveloperName == 'FILTERCONDITION'){
                        objectToQuery = detRule.sObject__c;
                        if(!fields.contains(detRule.FieldsAPI__c)){
                            fields += ', ' + detRule.FieldsAPI__c;
                        }

                        //ASE 22/11/2017
                        if(!detRule.FieldsAPI__c.contains('.') && detRule.sObject__c.contains('DistributorPrice__c')){
                            if(mapDistributorFieldType.containsKey(detRule.FieldsAPI__c.toUpperCase())){
                                currentFieldAPIDisplayType = mapDistributorFieldType.get(detRule.FieldsAPI__c.toUpperCase());
                            }else{
                                if(fieldDistributorAPIMap.containsKey(detRule.FieldsAPI__c)){
                                    mapDistributorFieldType.put(detRule.FieldsAPI__c.toUpperCase(),fieldDistributorAPIMap.get(detRule.FieldsAPI__c).getDescribe().getType());
                                    currentFieldAPIDisplayType = mapDistributorFieldType.get(detRule.FieldsAPI__c.toUpperCase());
                                }
                            } 
                        }
                        else{

                        }
                        
                        //AMI 27/10/17 : C-002041 - Distributor V2 - check if calling system is from distributor V2
                        //                                         - if yes,get BS info from bsRefAccountMap since this assessment 
                        //                                         - is not queried
                        if(detRule.ValueFrom__c == 'Master sObject'){
                            if(detRule.Value__c.contains('.')){
                                //AMI 27/10/17 : C-002041 - Distributor V2 - get BS info from bsRefAccountMap if calling system is from distributor V2
                                if(isDistributorV2){
                                    if(bsRefAccountMap.containsKey(assRecord.BodyShop__c)){
                                        //RLA 10/04/2018 C-002447 - Upsert takes into account Postal Code field
                                        string fieldToQuery = detRule.Value__c.split('\\.',0)[1];
                                        value = (string)bsRefAccountMap.get(assRecord.BodyShop__c).get(fieldToQuery);
                                        if(value == null){
                                            value = '';
                                        }
                                    }else{
                                        value = '';
                                    }
                                }

                                //continue with normal logic (assessment is queried in this case)
                                else{
                                    Integer matches = detRule.Value__c.countMatches('.');
                                    splitVlaues = detRule.Value__c.split('\\.',0);
                                    if(matches == 1){
                                        if(objToQuery.getSobject(splitVlaues[0])!=null){
                                            value = (string)objToQuery.getSobject(splitVlaues[0]).get(splitVlaues[1]);
                                            if(value == null){
                                                value = '';
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            else if(!detRule.Value__c.contains('.')){
                                //AMI 27/10/17 : C-002041 - Distributor V2 - check if calling system is from distributor V2
                                //                                         - if yes,partTypes from map since this info is 
                                //                                         - available by rollup summary 
                                if(isDistributorV2 && detRule.FieldsAPI__c == 'Categories__c'){                                    

                                    if(mapAssessIdFinalPartType.containsKey(assRecord.AssessmentID__c)){
                                        value = mapAssessIdFinalPartType.get(assRecord.AssessmentID__c);
                                        if(value == null){
                                            value = '';
                                        }
                                    }else{
                                        value = '';
                                    }
                                }else{
                                    value = string.valueOf(objToQuery.get(detRule.Value__c));
                                    if(value == null){
                                        value = '';
                                    }
                                }  
                                //currentFieldDisplayType = fieldMap.get(detRule.Value__c).getDescribe().getType();

                                //AMI 13/10/17 : getDescribeOptimisation
                                if(mapFieldType.containsKey(detRule.Value__c.toUpperCase())){
                                    currentFieldDisplayType = mapFieldType.get(detRule.Value__c.toUpperCase());
                                }else{
                                    if(fieldMap.containsKey(detRule.Value__c)){
                                        mapFieldType.put(detRule.Value__c.toUpperCase(),fieldMap.get(detRule.Value__c).getDescribe().getType());
                                        currentFieldDisplayType = mapFieldType.get(detRule.Value__c.toUpperCase());
                                    }
                                } 
                            }
                            if(value.contains(';')){
                                value = value.replaceAll(';','\',\'');
                            }

                            if(detRule.Operator__c == 'EQUALS'){
                                if(currentFieldDisplayType == Schema.DisplayType.Boolean){
                                    filterLine = detRule.FieldsAPI__c + ' = ' + value ;
                                }
                                else{
                                    filterLine = detRule.FieldsAPI__c + ' = \'' + value +'\'';
                                }
                            }
                            // Anthony: IN and CONTAINS clauses should not generate 'includes' (multipicklist should be CONTAINS -> includes / string field should be IN -> in
                            else if(detRule.Operator__c == 'CONTAINS'){
                                filterLine = detRule.FieldsAPI__c + ' INCLUDES (\'' + value +'\')';
                            }  else if(detRule.Operator__c == 'IN') {
                                filterLine = detRule.FieldsAPI__c + ' IN (\'' + value +'\')';
                            }  else if(detRule.Operator__c == 'NOT_EQUALS') {
                                filterLine = detRule.FieldsAPI__c + ' != \'' + value +'\'';
                            } else if(detRule.Operator__c == 'INCLUDES') {
                                filterLine = detRule.FieldsAPI__c + ' INCLUDES (\'' + value +'\')';
                            }else if(detRule.Operator__c == 'EXCLUDES') {
                                filterLine = detRule.FieldsAPI__c + ' EXCLUDES (\'' + value +'\')';
                            }
                        }
                        //add equals
                        else if(detRule.ValueFrom__c == 'Criteria sObject'){
                            
                            value = detRule.Value__c;
                            /*if(detRule.Operator__c == 'EQUALS'){
                                filterLine = detRule.FieldsAPI__c + ' = \'' + value +'\'';
                            }*/

                            
                            if((detRule.Operator__c).toUpperCase() == 'EQUALS'){
                                //ASE 22/11/2017
                                if(detRule.sObject__c.contains('DistributorPrice__c')){
                                    if(currentFieldAPIDisplayType == Schema.DisplayType.String){
                                        filterLine = detRule.FieldsAPI__c + ' = \'' + value +'\'';
                                    }
                                    else{                                
                                        filterLine = detRule.FieldsAPI__c + ' = ' + value ;
                                    }
                                }
                                else{
                                    filterLine = detRule.FieldsAPI__c + ' = \'' + value +'\'';    
                                }
                            }
                        }
                        mapNumFilter.put(String.valueOf(detRule.Number__c),filterLine);
                    }
                    /*
                    if(Schema.getGlobalDescribe().get(detRule.sObject__c)!=null && Schema.getGlobalDescribe().get(detRule.sObject__c).getDescribe().fields.getMap().get(detRule.FieldsAPI__c)!=null){
                        system.debug('# detRule.FieldsAPI__c ' + detRule.FieldsAPI__c);
                        system.debug('# xxxxxx ' + Schema.getGlobalDescribe().get(detRule.sObject__c).getDescribe().fields.getMap().get(detRule.FieldsAPI__c).getDescribe().getLabel());
                        if(Schema.getGlobalDescribe().get(detRule.sObject__c).getDescribe().fields.getMap().get(detRule.FieldsAPI__c).getDescribe().getLabel()!=null){
                            system.debug('# detRule.FieldsAPI__c if' + detRule.FieldsAPI__c);
                            wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  Schema.getGlobalDescribe().get(detRule.sObject__c).getDescribe().fields.getMap().get(detRule.FieldsAPI__c).getDescribe().getLabel() + ' '+detRule.Operator__c+ ' '+value+ '\n';
                        }
                        else{
                            system.debug('# detRule.FieldsAPI__c else' + detRule.FieldsAPI__c);
                            wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  detRule.FieldsAPI__c + ' '+detRule.Operator__c+ ' '+value + '\n';
                        }
                    }*/
                    
                    //AMI 13/10/17 : getDescribeOptimisation
                    if(!setSOjectNotSupported.contains(detRule.sObject__c.trim().toUpperCase()) && !setFieldNotSupported.contains(detRule.FieldsAPI__c.trim().toUpperCase())){
                        if(mapFieldLabel.containsKey(detRule.FieldsAPI__c.trim().toUpperCase())){
                            
                            wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  mapFieldLabel.get(detRule.FieldsAPI__c.trim().toUpperCase()) + ' '+ detRule.Operator__c+ ' '+value+ '\n';
                        
                        }else if(setLabelNotSupported.contains(detRule.FieldsAPI__c.trim().toUpperCase())){
                            
                            wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  detRule.FieldsAPI__c + ' '+detRule.Operator__c+ ' '+value + '\n';
                        
                        }else{
                            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(detRule.sObject__c);

                            if(sObjType != null){
                               
                                Schema.SobjectField sObjField = sObjType.getDescribe().fields.getMap().get(detRule.FieldsAPI__c);

                                if(sObjField != null){

                                    string label = sObjField.getDescribe().getLabel();

                                    if(string.isNotBlank(label)){
                                        mapFieldLabel.put(detRule.FieldsAPI__c.trim().toUpperCase(),label);
                                        wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  label + ' '+ detRule.Operator__c+ ' '+value+ '\n';
                                    }else{
                                        setLabelNotSupported.add(detRule.FieldsAPI__c.trim().toUpperCase());
                                        wrap.natLanguage += '[' + detRule.Number__c + ']'+ ' '+  detRule.FieldsAPI__c + ' '+detRule.Operator__c+ ' '+value + '\n';
                                    }
                                }else{
                                    setFieldNotSupported.add(detRule.FieldsAPI__c.trim().toUpperCase());
                                }
                            }else{
                                setSOjectNotSupported.add(detRule.sObject__c.trim().toUpperCase());
                            }
                        }
                    }//end if !setSOjectNotSupported.contains(detRule.sObject__c.toUpperCase()
                }
                system.debug('## filter before modif' + mapNumFilter);
                if(mapNumFilter.size() > 0){
                    for(String Num : mapNumFilter.keySet()){
                        //AMI 07/11/17 - Sourcing error during validate
                        //add regex to replace exact match
                        filter = filter.replaceFirst(('\\b' + Num + '\\b'), mapNumFilter.get(Num));
                    }
                }
                system.debug('## filter ' + filter);

                querySourcing = 'SELECT ' + fields + ' FROM ' + objectToQuery + ' WHERE ' + filter;

                wrap.mapQuerySourcing.put(querySourcing, objectToQuery);
            }
        }//end looping in master rule

        system.debug('## End LanguageAndQueryWrapper');
        system.debug('## wrap ' + wrap);
        return wrap;
    }
}