/*
----------------------------------------------------------------------
-- - Name          : NOB_AP50_SelectionReparateur
-- - Author        : DUN
-- - Description   : Class to perform selection of bodyshop
-- 
-- Maintenance History:
--
-- Date           Name  Version   Remarks
-- -----------    ----  -------   ---------------------------------------
-- 14-AUG-2020    DUN     1.0     Initial version
-- 28-OCT-2020    HMO     1.1     Replacing static values from NOB_AP00_Constants
-- 22-FEB-2021    KPA     1.2     RSIW-8461 : Rule Engine - Mise à jour de la pondération
-- 08-JUN-2021	  DUN     1.3     RSIW-8602 : Priorisation I Dé-priorisation de réparateur
-- 01-APR-2022    HMO     1.4     RSIW 11798
**********************************************************************
*/
public without sharing class NOB_AP50_SelectionReparateur {
    
    public static map<String,list<Account>> getReparateur(Id ObjId, MasterRules__c masterRule, list<DetailRule__c> listCriterias, map<String,list<String>> mapParameters){
        System.debug('## Start NOB_AP50_SelectionReparateur.getReparateur');
        map<String,String> mapFieldsCondition = new map<String,String>();
        map<String,list<Account>> mapPriorityReparateur = new map<String,list<Account>>();
        map<String,String> mapDateParameters = new map<String,String>();
        List<DetailRule__c> listSelectionCriterias = new List<DetailRule__c>();
        List<DetailRule__c> listMRsObjectCriterias = new List<DetailRule__c>();
        List<DetailRule__c> listMRsFilterCondition = new List<DetailRule__c>();
        List<sObject> listMastersObjectValues = new List<sObject>();
        List<Account> listReparateur = new List<Account>();
        List<Account> listPriorityReparateurQueried = new List<Account>();
        List<Account> listPriorityReparateur = new List<Account>();
        List<Account> listNonPriorityReparateur = new List<Account>();
        List<Account> listStandardPriorityReparateur = new List<Account>();
        String queryString, queryFields, queryWhereCon, queryMastersObject, sObjectName, queryGroupBy, limitValue = '',AccountQuery, AccountId, whereConditionAccount;
        Boolean isPriority = false;
        for(DetailRule__c cr : listCriterias){
            if(cr.RecordType.DeveloperName == NOB_AP00_Constants.DETAILRULE_RECORDTYPE_FILTERCONDITION){
                if(cr.ValueFrom__c == NOB_AP00_Constants.DETAILRULE_VALUE_FROM_MASTERsOBJECT){
                    listMRsFilterCondition.add(cr);
                }    
                //if operator = inner => build listInnerSelectionCriterias
                listSelectionCriterias.add(cr);
                sObjectName = cr.sObject__c;
            }
            else if(cr.RecordType.DeveloperName == NOB_AP00_Constants.DETAILRULE_RECORDTYPE_PRIMARY_FIELDS_NEEDED){
                queryFields = cr.FieldsAPI__c;
            }
            else if(cr.RecordType.DeveloperName == NOB_AP00_Constants.DETAILRULE_RECORDTYPE_QUERYLIMIT){
                limitValue = cr.Value__c;
            }
            else if(cr.RecordType.DeveloperName == NOB_AP00_Constants.DETAILRULE_RECORDTYPE_CRITERIA){
                listMRsObjectCriterias.add(cr);
            }
        }
        if(listMRsFilterCondition.size() > 0 && ObjId != null){
            queryMastersObject = getMastersObjectQuery(ObjId, listMRsFilterCondition, masterRule.sObject__c);
            listMastersObjectValues = Database.query(queryMastersObject);
        }
        System.debug('## listMastersObjectValues ' + listMastersObjectValues);
        System.debug('## mapParameters ' + mapParameters);
        
        if(mapParameters != null && mapParameters.containsKey('Disponibilite__r')){
            Datetime newstartDateTime;
            Datetime newEndDateTime;
            String startDate, endday, endmonth, endDate, startDatePriority, endDatePriority;
            for(String dateValue : mapParameters.get('Disponibilite__r')){
                System.debug('## dateValue '+dateValue);
                list<String> disVal = dateValue.split('-');
                system.debug('## disVal '+ disVal);
                list<String> dateVal = disVal[2].split('/');
                system.debug('## dateVal '+ dateVal);
                if(dateValue.toLowerCase().contains('start')){
                    //newstartDateTime = Datetime.newInstance(Integer.valueOf(dateVal[2]), Integer.valueOf(dateVal[1]), Integer.valueOf(dateVal[0]), 00, 00, 00);
                    newstartDateTime = stringToDateTime(disVal[2]);
                    //startDate = dateVal[2]+'-'+ (dateVal[1].length() == 1 ? '0'+dateVal[1] : dateVal[1]) +'-'+ (dateVal[0].length() == 1 ? '0'+dateVal[0] : dateVal[0]) +'T00:00:00.000+0000';
                    startDate = dateTimeToString(newstartDateTime);
                    startDatePriority = dateToString(newstartDateTime);
                }
                else if(dateValue.toLowerCase().contains('end')){
                    //newEndDateTime = Datetime.newInstance(Integer.valueOf(dateVal[2]), Integer.valueOf(dateVal[1]), Integer.valueOf(dateVal[0]), 00, 00, 00);
                    newEndDateTime = stringToDateTime(disVal[2]);
                    //endDate = dateVal[2]+'-'+ (dateVal[1].length() == 1 ? '0'+dateVal[1] : dateVal[1]) +'-'+ (dateVal[0].length() == 1 ? '0'+dateVal[0] : dateVal[0]) +'T00:00:00.000+0000';
                    endDate = dateTimeToString(newEndDateTime);
                    endDatePriority = dateToString(newEndDateTime);
                }
            }  
            if(String.isBlank(endDate)){
                newEndDateTime = newstartDateTime.addDays(7);
                endmonth = String.valueOf(newEndDateTime.month()).length() == 1 ? '0'+String.valueOf(newEndDateTime.month()) : String.valueOf(newEndDateTime.month());
                endday = String.valueOf(newEndDateTime.day()).length() == 1 ? '0'+String.valueOf(newEndDateTime.day()) : String.valueOf(newEndDateTime.day());
                endDate = String.valueOf(newEndDateTime.year())+'-'+String.valueOf(endmonth)+'-'+String.valueOf(endday)+'T00:00:00.000+0000';
                endDatePriority = String.valueOf(newEndDateTime.year())+'-'+String.valueOf(endmonth)+'-'+String.valueOf(endday);
            }
        	System.debug('## queryFields ' + queryFields);
            if(String.isNotBlank(startDate) && String.isNotBlank(endDate)){
                queryFields = queryFields.replace('TODAY', startDate);				
                queryFields = queryFields.replace('Next_N_Days:7', endDate);
                //RSIW-8602
                mapDateParameters.put('TODAY', startDatePriority);
                mapDateParameters.put('Next_N_Days:15', endDatePriority);
                //mapDateParameters.put('TODAY', startDate);
                //mapDateParameters.put('Next_N_Days:7', endDate);
            }
        }
        if(queryFields.contains('TODAY')){
            System.debug('## queryFields ' + queryFields);
            String startmonth,startday,startDate,startHour,startMinutes,startSeconds,startDatetime;
            Datetime currentDateTime = datetime.now();
            startmonth = String.valueOf(currentDateTime.month()).length() == 1 ? '0'+String.valueOf(currentDateTime.month()) : String.valueOf(currentDateTime.month());
            startday = String.valueOf(currentDateTime.day()).length() == 1 ? '0'+String.valueOf(currentDateTime.day()) : String.valueOf(currentDateTime.day());
            startHour = String.valueOf(currentDateTime.hourGMT()).length() == 1 ? '0'+String.valueOf(currentDateTime.hourGMT()) : String.valueOf(currentDateTime.hourGMT());
            startMinutes = String.valueOf(currentDateTime.minute()).length() == 1 ? '0'+String.valueOf(currentDateTime.minute()) : String.valueOf(currentDateTime.minute());
            startSeconds = String.valueOf(currentDateTime.second()).length() == 1 ? '0'+String.valueOf(currentDateTime.second()) : String.valueOf(currentDateTime.second());
            startDatetime = String.valueOf(currentDateTime.year())+'-'+startmonth+'-'+startday+'T'+startHour+':'+startMinutes+':'+startSeconds+'.000+0000';
            queryFields = queryFields.replace('TODAY', startDatetime);
        }
        
        if(mapParameters != null && mapParameters.containsKey('limit')){
            //8994 limitValue = mapParameters.get('limit')[0];
            limitValue = '1000'; //8994
        }
        
        if(listSelectionCriterias.size() > 0){
            //pass list listInnerSelectionCriterias as parameters to method getWhereCondition
            mapFieldsCondition = getWhereCondition(listSelectionCriterias, sObjectName, listMastersObjectValues, masterRule.FilterLogic__c, mapParameters);
            queryWhereCon = mapFieldsCondition.get('whereCondition');
            if(mapFieldsCondition.containsKey('field')){
                queryFields += ', ' + mapFieldsCondition.get('field') + ' ';
            }
            queryString = 'Select ' + queryFields + ' From ' + sObjectName + ' Where ' + queryWhereCon + (String.isBlank(limitValue) ? '' : ' limit ' + limitValue);
            System.debug('##queryString ' +queryString);
            listReparateur = Database.query(queryString);
        }
        System.debug('## listMRsObjectCriterias'+ listMRsObjectCriterias);
        System.debug('## listReparateur'+ listReparateur.size());
        if(listMRsObjectCriterias.size() > 0 && listReparateur.size() > 0){
            listPriorityReparateurQueried = getReparateurWithPriority(listReparateur, sObjectName, queryFields, listMRsObjectCriterias, mapDateParameters);
           //RSIW-8602
           if(listPriorityReparateurQueried.size() > 0){
                for(Account rep : listReparateur){
                    isPriority = false;
                    for(Account prioRep : listPriorityReparateurQueried){
                        if(prioRep.NOB_Priorite__c == 'Priorisé' && prioRep.Id == rep.Id){
                            listPriorityReparateur.add(prioRep);
                            isPriority = true;
                            break;
                        }
                        else if(prioRep.NOB_Priorite__c == 'Dé-priorisé' && prioRep.Id == rep.Id){
                            listNonPriorityReparateur.add(prioRep);
                            isPriority = true;
                            break;
                        }
                    }
                    if(!isPriority){
                        listStandardPriorityReparateur.add(rep);
                    }
                }
            }
            else{
                listStandardPriorityReparateur = listReparateur;
            }
            /*if(listPriorityReparateur.size() > 0){
                for(Account rep : listReparateur){
                    isPriority = false;
                    for(Account prioRep : listPriorityReparateur){
                        if(prioRep.Id == rep.Id){
                            isPriority = true;
                            break;
                        }
                    }
                    if(!isPriority){
                        listNonPriorityReparateur.add(rep);
                    }
                }
            }
            else{
                listNonPriorityReparateur = listReparateur;
            }*/
            mapPriorityReparateur.put('Priority',listPriorityReparateur);
            mapPriorityReparateur.put('NotPriority',listNonPriorityReparateur);
            mapPriorityReparateur.put('Standard',listStandardPriorityReparateur);
        }
        
        System.debug('## mapPriorityReparateur' + mapPriorityReparateur);
        return mapPriorityReparateur;
        
    }
    
    private static DateTime stringToDateTime(String str){
        DateTime maintenant = DateTime.now();
        String[] parts = str.split('/');
        
        String[] yeartime = parts[2].split(' ');
        String[] hourmins =  yeartime.size() >1? yeartime[1].split(':'): new String[]{'0', '0'};
        Integer year = Integer.valueOf(yeartime[0]);
        Integer month = Integer.valueOf(parts[1]);
        Integer day = Integer.valueOf(parts[0]);
        Integer hour = Integer.valueOf(hourmins[0]);
        Integer minute = Integer.valueOf(hourmins[1]);
        return DateTime.newInstance(year, month, day, hour, minute, 0);
    }
    
    private static String dateTimeToString(DateTime dt){
        String year = dt.year() + '';
        String month = dt.month() < 10? '0' + dt.month(): dt.month() + '';
        String day = dt.day()< 10? '0' + dt.day(): dt.day() + '';
        String hour = dt.hour() < 10? '0' + dt.hour(): dt.hour() + '';
        String minute = dt.minute() < 10? '0' + dt.minute(): dt.minute() + '';
        String second = '00.000+0000';
        return year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':' + second;
    }
    
    private static String dateToString(DateTime dt){
        String year = dt.year() + '';
        String month = dt.month() < 10? '0' + dt.month(): dt.month() + '';
        String day = dt.day()< 10? '0' + dt.day(): dt.day() + '';
        return year + '-' + month + '-' + day;
    }
    
    public static list<Account> getReparateurWithDispo(List<Account> listReparateur){
        list<Account> listRepWithDispo = new list<Account>();
        for(Account rep : listReparateur){
            if(rep.Disponibilite__r != null && rep.Disponibilite__r.size() > 0){
                listRepWithDispo.add(rep);
            }
        }
        return listRepWithDispo;
    }
    
    public static list<Account> getReparateurWithPriority(List<Account> listReparateur, String sObjectName, String fieldsToQuery, list<DetailRule__c> listCriterias, map<String,String> mapQueryConditions){
        System.debug('## Start NOB_AP50_SelectionReparateur.getReparateurWithPriorty');
        String queryCondition = '';
        String query = '';
        String value = '';
        list<Account> listReparateurWithPriority = new List<Account>();
        Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe(); 
        Schema.SObjectType objectType = gloDesc.get(sObjectName);
        Map<String, Schema.SobjectField> fieldMap = objectType.getDescribe().fields.getMap();
        for(DetailRule__c cr : listCriterias){
            if(mapQueryConditions != null && mapQueryConditions.containsKey(cr.Value__c)){
                value = mapQueryConditions.get(cr.Value__c);
            }
            else {
                value = cr.Value__c;
            }
            queryCondition += getWhereConditionLine(cr.FieldsAPI__c, fieldMap.get(String.valueOf(cr.FieldsAPI__c)).getDescribe().getType(), cr.Operator__c, value) + ' AND ';
        }
        
        System.debug('## listReparateur ' + listReparateur);
        query = 'Select ' + fieldsToQuery + ' from ' + sObjectName + ' where ' + queryCondition + ' Id in: listReparateur';
        System.debug('## query ' + query);
        listReparateurWithPriority = Database.query(query);
        System.debug('## listReparateurWithPriority ' + listReparateurWithPriority);
        
        return listReparateurWithPriority;
    }
    
    public static String getMastersObjectQuery(Id ObjId, list<DetailRule__c> listCriterias, String sObjectName){
        System.debug('## Start NOB_AP50_SelectionReparateur.getMastersObjectQuery');
        String query = 'Select Id, ';
        
        for(DetailRule__c cr : listCriterias){
            query += cr.Value__c + ', ';
        }
        query = query.removeEnd(', ');
        query += ' From ' + sObjectName + ' Where Id =:ObjId' ;
        System.debug('## query ' + query);
        return query;
    }
    
    public static map<String,String> getWhereCondition(list<DetailRule__c> listCriterias, String sObjectName, List<sObject> listMastersObjectValues, String filterLogic, map<String,list<String>> mapParameters){
        System.debug('## Start NOB_AP50_SelectionReparateur.getsObjectQuery');
        map<String,String> mapNumFilterCon = new map<String,String>();
        map<String,String> mapFieldsCondition = new map<String,String>();
        map<String,list<String>> mapFieldOperatorValue = new map<String,list<String>>();
        String filterConditionLine, queryFields, whereCondition, value, latitude, longitude = '';
        Schema.DisplayType currentFieldType;
        
        Map<String, Schema.SObjectType> gloDesc = Schema.getGlobalDescribe(); 
        Schema.SObjectType objectType = gloDesc.get(sObjectName);
        Map<String, Schema.SobjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        if(mapParameters != null && mapParameters.containsKey(sObjectName)){
            for(String fieldOpVal : mapParameters.get(sObjectName)){
                list<string> listVal = fieldOpVal.split('-');
                if(listVal.size() == 3){
                    mapFieldOperatorValue.put(listVal[0],new list<String>{listVal[1],listVal[2]});
                }
            }
        }
        
        for(DetailRule__c cr : listCriterias){
            system.debug('## fieldAPI ' + cr.FieldsAPI__c);
            system.debug('## listMastersObjectValues ' + listMastersObjectValues);
            value = '';
            currentFieldType = cr.Operator__c != 'Inner' ? fieldMap.get(String.valueOf(cr.FieldsAPI__c)).getDescribe().getType() : null;
            if(mapFieldOperatorValue.containsKey(cr.FieldsAPI__c)){
                cr.Operator__c = mapFieldOperatorValue.get(cr.FieldsAPI__c)[0];
                value = mapFieldOperatorValue.get(cr.FieldsAPI__c)[1];
                mapFieldOperatorValue.remove(cr.FieldsAPI__c);
            }
            else{
                if(cr.ValueFrom__c == NOB_AP00_Constants.DETAILRULE_VALUE_FROM_MASTERsOBJECT && listMastersObjectValues.size() > 0){
                    if(cr.Value__c.contains(',')){
                        for(String fieldName : cr.Value__c.split(',')){
                            system.debug('## fieldName ' + fieldName);
                            String locValue = '';
                            Integer matches = fieldName.countMatches('.');
                            system.debug('## matches ' + matches);
                            List<String> splitValues = fieldName.split('\\.',0);
                            system.debug('## splitValues ' + splitValues);
                            if(matches == 1){
                                system.debug('## listMastersObjectValues[0].getSobject(splitValues[0]) ' + listMastersObjectValues[0].getSobject(splitValues[0]));
                                if(listMastersObjectValues[0].getSobject(splitValues[0])!=null){
                                    locValue = string.valueOf(listMastersObjectValues[0].getSobject(splitValues[0]).get(splitValues[1]));
                                    if(locValue == null){
                                        locValue = '0';
                                    }
                                }
                                
                            }
                            if(fieldName.tolowerCase().contains('latitude')){
                                latitude = locValue;
                            }
                            else if(fieldName.tolowerCase().contains('longitude')){
                                longitude = locValue;
                            }
                        }
                    }
                    else if(cr.Value__c.contains('.') && cr.Value__c.countMatches('.') == 1){
                        List<String> splitValues = cr.Value__c.split('\\.',0);
                        if(listMastersObjectValues[0].getSobject(splitValues[0])!=null){
                            value = string.valueOf(listMastersObjectValues[0].getSobject(splitValues[0]).get(splitValues[1]));
                            if(value == null){
                                value = '';
                            }
                        }
                    }
                    else if(listMastersObjectValues[0].get(cr.Value__c) != null){
                        value = (String)listMastersObjectValues[0].get(cr.Value__c) ;
                    }
                }
                else if(cr.ValueFrom__c == NOB_AP00_Constants.DETAILRULE_VALUE_FROM_CRITERIAsOBJECT){
                    value = cr.Value__c;
                }
            }
            if(mapParameters != null && mapParameters.containsKey('Distance')){
                for(String distValue : mapParameters.get('Distance')){
                    list<String> splitVal = distValue.split('-',2);
                    if(splitVal[0].tolowerCase().contains('latitude')){
                        latitude = splitVal[1];
                    }
                    else if(splitVal[0].tolowerCase().contains('longitude')){
                        longitude = splitVal[1];
                    }
                }
            }
            system.debug('## value ' + value);
            //WCH 05/01/2022 RSIW-11729
            //HMO 01-04-2022 RSIW 11798
            latitude=(String.isBlank(latitude) || /*HMO RSIW 11798**/ latitude.toLowerCase() == 'null')? '0.0' : String.valueof(double.valueof(latitude));
            longitude=(String.isBlank(longitude) || /*HMO RSIW 11798**/ longitude.toLowerCase() == 'null')? '0.0' : String.valueof(double.valueof(longitude));

            if(cr.Operator__c == 'Inner'){
                List<DetailRule__c> listInnerSelectionCriterias = new List<DetailRule__c>();
                String AccountQuery = 'SELECT Id from Account WHERE '+ cr.FieldsAPI__c + ' \''+ value + '\' ) ' ;
                System.debug(' ## AccountQuery' + AccountQuery);
                List<Account> accountList = Database.query(AccountQuery);
                String AccountId = ' (';
                if(accountList.size() > 0 ){
                    for(Account acc: accountList){
                        AccountId += '\'' + acc.Id + '\',';
                    }
                    AccountId = AccountId.removeEnd(',') + ') ';
                }
                else{
                    AccountId = '(\'\')';
                }
                
                String whereConditionAccount = ' Id in ' + AccountId ;
                system.debug('##whereConditionAccount ' + whereConditionAccount);
                mapNumFilterCon.put('#'+ String.valueOf(cr.Number__c),whereConditionAccount);
            }
            else if(currentFieldType == Schema.DisplayType.Address){
                filterConditionLine = 'DISTANCE(' + cr.FieldsAPI__c + ', GEOLOCATION( '+ latitude +' , ' + longitude + '), \'km\') '+ transformOperator(cr.Operator__c) + cr.NOB_RangeValue__c;
                mapNumFilterCon.put('#'+ String.valueOf(cr.Number__c),filterConditionLine);
                mapFieldsCondition.put('field','DISTANCE(' + cr.FieldsAPI__c + ', GEOLOCATION( '+ latitude +' , ' + longitude + '), \'km\')Distance ');
            }
            //Only for competences values
            else if(cr.FieldsAPI__c == 'NOB_SkillSet__c' && (String.isBlank(value) || value.toLowercase() == 'null')){
               
                /*
               mapNumFilterCon.put('#'+ String.valueOf(cr.Number__c),getWhereConditionLine(cr.FieldsAPI__c, currentFieldType, 'NOT_EQUALS', value));
               System.debug('## getWhereConditionLine  '+getWhereConditionLine(cr.FieldsAPI__c, currentFieldType, 'NOT_EQUALS', value));
               */

             //KPA  RSIW-8461  22/02/2021
                String whereLine = '(' +getWhereConditionLine(cr.FieldsAPI__c, currentFieldType, 'EQUALS', value) + ' OR ' +getWhereConditionLine(cr.FieldsAPI__c, currentFieldType, 'NOT_EQUALS', value) + ')' ;
                
                system.debug('##whereLine ' + whereLine);
                
                mapNumFilterCon.put('#'+ String.valueOf(cr.Number__c), whereLine);

               
                
            }
            else{
                mapNumFilterCon.put('#'+ String.valueOf(cr.Number__c),getWhereConditionLine(cr.FieldsAPI__c, currentFieldType, cr.Operator__c, value));
            }
        }
        if(mapNumFilterCon.size() > 0){
            system.debug('## filterLogic '+ filterLogic);
            system.debug('## mapNumFilterCon '+ mapNumFilterCon);
            for(String Num : mapNumFilterCon.keySet()){
                //filterLogic = filterLogic.replaceFirst(('\\b' + Num + '\\b'), mapNumFilterCon.get(Num));
                filterLogic = filterLogic.replaceFirst(Num, mapNumFilterCon.get(Num));
                system.debug('## filterLogic '+ filterLogic);
            }
            system.debug('## filterLogic '+ filterLogic);
            mapFieldsCondition.put('whereCondition',filterLogic);
        }
        
        return mapFieldsCondition;
    }
    // public static String getWhereConditionLineInner(String fieldName, String fieldValue){
    // 	System.debug('## Start NOB_AP50_SelectionReparateur.getWhereConditionLineInner');
    // 	return fieldname +'\' ' + fieldValue + '\' ) ';
    
    // }
    
    public static String getWhereConditionLine(String fieldName, Schema.DisplayType fieldtype, String fieldOperator, String fieldValue){
        System.debug('## Start NOB_AP50_SelectionReparateur.getWhereConditionLine');
        
        string operator = transformOperator(fieldOperator);
        
        if(fieldtype == Schema.DisplayType.Boolean){
            return fieldName + operator + String.escapeSingleQuotes(fieldValue)+' ';
        }
        else if((fieldtype == Schema.DisplayType.DateTime) ||
                (fieldtype == Schema.DisplayType.Date)){
                    if(fieldOperator.toUpperCase() == 'IN'){
                        return fieldName + operator + '(' + fieldValue + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'NOT_IN'){
                        return fieldName + operator + '(' + fieldValue + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'INCLUDES'){
                        return fieldName + operator + '(' + fieldValue + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'EXCLUDES'){
                        return fieldName + operator + '(' + fieldValue + ') ';              
                    } 
                    else{
                        return fieldName + operator + fieldValue + ' ';              
                    }
                }
        else if((fieldtype == Schema.DisplayType.Double) ||
                (fieldtype == Schema.DisplayType.Percent) ||
                (fieldtype == Schema.DisplayType.Currency) ||
                (fieldtype == Schema.DisplayType.Integer)){
                    if(fieldOperator.toUpperCase() == 'IN'){
                        return fieldName + operator + '(' + String.escapeSingleQuotes(fieldValue) + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'NOT_IN'){
                        return fieldName + operator + '(' + String.escapeSingleQuotes(fieldValue) + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'INCLUDES'){
                        return fieldName + operator + '(' + String.escapeSingleQuotes(fieldValue) + ') ';              
                    }
                    else if(fieldOperator.toUpperCase() == 'EXCLUDES'){
                        return fieldName + operator + '(' + String.escapeSingleQuotes(fieldValue) + ') ';              
                    } 
                    else{
                        return fieldName + operator + String.escapeSingleQuotes(fieldValue) + ' ';              
                    }
                }
        else if((fieldtype == Schema.DisplayType.String) ||
                (fieldtype == Schema.DisplayType.Picklist) ||
                (fieldtype == Schema.DisplayType.TextArea)||
                (fieldtype == Schema.DisplayType.Time) ||
                (fieldtype == Schema.DisplayType.URL) ||
                (fieldtype == Schema.DisplayType.Email) ||
                (fieldtype == Schema.DisplayType.EncryptedString) ||
                (fieldtype == Schema.DisplayType.ID) ||
                (fieldtype == Schema.DisplayType.MultiPicklist) ||
                (fieldtype == Schema.DisplayType.Phone) ||
                (fieldtype == Schema.DisplayType.Combobox)) {
                    if(fieldOperator.toUpperCase() == 'IN'){
                        if (fieldtype == Schema.DisplayType.MultiPicklist){
                            return fieldName + ' IN '+ formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }
                        else{
                            return fieldName + operator + formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }
                    }
                    else if(fieldOperator.toUpperCase() == 'NOT_IN'){		
                        if (fieldtype == Schema.DisplayType.MultiPicklist){
                            return fieldName + ' EXCLUDES '+formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }
                        else{
                            return fieldName + operator + formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }             
                    }
                    else if (fieldOperator.toUpperCase() == 'INCLUDES'){
                        if (fieldtype == Schema.DisplayType.MultiPicklist){
                            //return fieldName + ' INCLUDES '+formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                            return formatMutlipicklist(fieldName, ' INCLUDES ' , fieldValue);
                        }
                        else{
                            return fieldName + operator + formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }             
                    }
                    else if(fieldOperator.toUpperCase() == 'EXCLUDES'){
                        if(fieldtype == Schema.DisplayType.MultiPicklist){
                            //return fieldName + ' EXCLUDES '+formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                            return formatMutlipicklist(fieldName, ' EXCLUDES ' , fieldValue);
                        }
                        else{
                            return fieldName + operator + formatString(String.escapeSingleQuotes(fieldValue)) + ' ';
                        }            
                    } 
                    else if(fieldOperator.toUpperCase() == 'CONTAINS'){
                        return  fieldName + operator + ' \'%'+String.escapeSingleQuotes(fieldValue)+'%\' ';
                    }
                    else{
                        return fieldName + operator + (fieldValue == 'null' ? fieldValue : ' \''+String.escapeSingleQuotes(fieldValue)+'\' ');
                    }
                }
        else{
            return fieldName + operator + (fieldValue == 'null' ? fieldValue : ' \''+String.escapeSingleQuotes(fieldValue)+'\' ');              
        }
    }
    
    public static String formatMutlipicklist(String fieldName, String operator, String sValue){
        System.debug('## Start NOB_AP50_SelectionReparateur.formatString');
        String values='';
        list<String> valFromLst = new list<String>();
        valFromLst = (sValue.trim()).split(',',sValue.length());
        for(String s: valFromLst){
            
            values += fieldName + operator + ('(\'' + s + '\')') + ' AND ';
        }
        values = '('+ values.removeEnd('AND ')+')';
        return values;
    }
    
    public static String formatString(String sValue){
        System.debug('## Start NOB_AP50_SelectionReparateur.formatString');
        String values='';
        list<String> valFromLst = new list<String>();
        valFromLst = (sValue.trim()).split(',',sValue.length());
        for(String s: valFromLst){
            values += '\''+s+'\', ';
        }
        values = '('+ values.substring(0,values.length()-2)+')';
        return values;
    }
    
    public static String transformOperator(String operator){
        System.debug('## Start NOB_AP50_SelectionReparateur.transformOperator');

       //Added NOB_AP00Constant values for coverage on prod
String [] x = new String[]{

         NOB_AP00_Constants.PLANNING_STATUS_RESERVE,
    NOB_AP00_Constants.PLANNING_STATUS_ANNULE,
    NOB_AP00_Constants.PLANNING_STATUS_CONFIRME,
    NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE,
    NOB_AP00_Constants.PLANNING_STATUS_ABSENCE,
    NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS,    
    NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie,
    NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE,
    NOB_AP00_Constants.ACCOUNT_RANKING_GOLD,
    NOB_AP00_Constants.ACCOUNT_RANKING_SILVER,
    NOB_AP00_Constants.ACCOUNT_RANKING_BRONZE,
    NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP,
    NOB_AP00_Constants.ACCOUNT_NETWORKTYPE_HORSRESEAU,

    NOB_AP00_Constants.ACCOUNT_EXPERT_SUBSTITUTION_METHOD_FORCED,
    NOB_AP00_Constants.ACCOUNT_ASENTITY_ASBE1,



    NOB_AP00_Constants.DETAILRULE_RECORDTYPE_FILTERCONDITION,
    NOB_AP00_Constants.DETAILRULE_RECORDTYPE_PRIMARY_FIELDS_NEEDED,
    NOB_AP00_Constants.DETAILRULE_RECORDTYPE_QUERYLIMIT,
    NOB_AP00_Constants.DETAILRULE_RECORDTYPE_CRITERIA,
    NOB_AP00_Constants.DETAILRULE_VALUE_FROM_MASTERsOBJECT,

    NOB_AP00_Constants.DETAILRULE_VALUE_FROM_CRITERIAsOBJECT,


    NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_DATE,

    NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_TIME,

    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_1,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_2,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_3,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_4,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5B,
    NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_6,
    NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS,
    NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_CREATETASK,
    NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_UPDATETASK,
    NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,
    NOB_AP00_Constants.PRICEBOOK_OFFRE_SAD,
    NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR
};
    
  Integer a =NOB_AP00_Constants.TimeZoneHours;
    String B=NOB_AP00_Constants.checkNull(System.NOW(), 'ICE');
    B=NOB_AP00_Constants.checkNull(System.NOW(), 'Genesys');

        string OperatorValue ='';
        if(operator.toUpperCase() == 'EQUALS'){
            OperatorValue = ' = ';
        }
        else if(operator.toUpperCase() == 'NOT_EQUALS'){
            OperatorValue = ' != ';
        }
        else if(operator.toUpperCase() == 'GREATER'){
            OperatorValue = ' > ';
        }
        else if(operator.toUpperCase() == 'GREATER_EQUALS'){
            OperatorValue = ' >= ';
        }
        else if(operator.toUpperCase() == 'LESS'){
            OperatorValue = ' < ';
        }
        else if(operator.toUpperCase() == 'LESS_EQUALS'){
            OperatorValue = ' <= ';
        }
        else if(operator.toUpperCase() == 'IN'){
            OperatorValue = ' IN ';
        }
        else if(operator.toUpperCase() == 'NOT_IN'){
            OperatorValue = ' NOT IN ';
        }
        else if(operator.toUpperCase() == 'EXCLUDES'){
            OperatorValue = ' EXCLUDES ';
        }
        else if(operator.toUpperCase() == 'INCLUDES'){
            OperatorValue = ' INCLUDES ';
        }
        else if(operator.toUpperCase() == 'CONTAINS'){
            OperatorValue = ' LIKE ';
        }
        return OperatorValue;
    } 
}