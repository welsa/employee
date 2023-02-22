/*************************************************************************************
Class Name - ASPISTools
Version - 1.0
Created Date - 27 MAR 2015
Function - Class handling Dynamic SOQL query

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Andry Ramarijaona     27/03/2015  Original Version
* Cécile Lartaud		    15/10/2015  Added handle of fields in the criteria "Value" field.
* Dourga Unmole         24/11/2015  Case C-001210
* Shamina M             17/02/2016  C-001518: Removed unnecessary debug logs
* Dourga Unmole         08/03/2016  C-001553: Verify all triggers check the bypass before execution
* Abdool Miskin         04/03/2018  Updating bypass so that query from user record is not performed for test class
*                                   Query from userrecord prevented applying bypass from test classes
* Welsa Chan            22/09/2020  C-003923: NOB - Sharing Rules Management
* Welsa Chan            26/03/2021  C-004292 : Bodyshop Credit Note not generated after distributor returns a spare part
*************************************************************************************/
public class ASPISTools {
    //case 1553
    //AMI 04/03/18 - Updating bypass so that query from user record is not performed for test class
    //             - Changing string from final to static only so that latter can be set directly in test classes
    public static string bypassTrigger = '';
    public static boolean checkIfAlphaScaleUser = false;
    public static User currentUserInfo = new User();
    static{
        //AMI 04/03/18 - Updating bypass so that query from user record is not performed for test class
        //             - Preventing query from user record for test classes
        if(!test.isRunningTest()){
            User user = [Select BypassTrigger__c,isAspis__c,UserRoleId,UserRole.name,ProfileId,Profile.Name,Name from User where Id =:UserInfo.getUserId() limit 1];
            bypassTrigger = ';' + user.BypassTrigger__c + ';';
            checkIfAlphaScaleUser = user.isAspis__c;
            currentUserInfo = user;
        } 
    }
    public static boolean canTrigger(string ApexName){ 
        return(bypassTrigger.indexOf(';'+ApexName+';')==-1);
    }
    public static boolean isAlphaScaleUser(){ 
        return(checkIfAlphaScaleUser);
    }
    //WCH 26/03/2021 C-004292
    public static User getCurrentUserInfo(){ 
        return(currentUserInfo);
    }

    public class filterCriteria{
        sObject sObjectName;
        String fieldName;
        String operator;
        String value;
        String valueTo;

        public filterCriteria(sObject o, String field, String op, String val, String valTo){
            this.sObjectName = o;
            this.fieldName = field;
            this.operator = op;
            this.value = val;
            this.valueTo = valTo;
        }
    }

    public static Map<String, Schema.SObjectType> schemaMap;

    static{
        schemaMap = Schema.getGlobalDescribe(); 
    }

    //----------------------------------------------------------------------------
    // Static method fmtIN
    // Description: process string in of type a,b,c,d and returns 'a','b','c','d'
    //-----------------------------------------------------------------------------
    public static String fmtIN(String sValue){
    	String values='';
    	list<String> valFromLst = new list<String>();
        valFromLst = (sValue.trim()).split(',',sValue.length());
        for(String s: valFromLst){
        	////system.debug('-----------------------------------s='+s);
        	values += '\''+s+'\', ';
    		//system.debug('-----------------------------------values='+values);
    	}
    	values = '('+ values.substring(0,values.length()-2)+')';
    	//system.debug('------------------------------------------------>fmtIN Values='+values);
    	return values;
    }

    public static String transformOperator(String op){
    string xOp ='';
    if(op!=null){
      if (op.toUpperCase() == system.Label.OPERATOREQUALS || op == '='){
         xOp = '=';
      } else if(op.toUpperCase() == system.Label.OPERATORNOTEQUALS || op == '<>' || op == '!='){
         xOp = '<>';
      } else if(op.toUpperCase() == system.Label.OPERATORIN || op == 'in' ||op.toUpperCase() == system.Label.OPERATORCONTAINS || op=='contains'){
         xOp = ' in ';
      }else if(op.toUpperCase() == system.Label.OPERATORNOTIN || op == 'not in'){
         xOp = ' not in ';
      }else if(op.toUpperCase() == system.Label.OPERATORINCLUDES || op == 'includes'){
         xOp = ' includes ';
      }else if(op.toUpperCase() == system.Label.OPERATOREXCLUDES || op == 'excludes'){
         xOp = ' excludes ';
      } else if(op.toUpperCase() == system.Label.OPERATORBETWEEN || op == 'between' ){
         xOp = ' between ';
      }else if( op.toUpperCase() == system.Label.OPERATORGREATER ){
         xOp = '>';
      }else if( op.toUpperCase() == system.Label.OPERATORLESS){
         xOp = '<';
      }else if( op.toUpperCase() == system.Label.OPERATORGREATEREQUALS){
         xOp = '>=';
      }else if( op.toUpperCase() == system.Label.OPERATORLESSEQUALS){
         xOp = '<=';
      }
    }
     return xOp;
    }

    /****************************************************************************
    *               BUILD THE WHERE CLAUSE OF THE SOQL query                    *
    *****************************************************************************/
    public static String getFieldValueWhereClause(String sObjName, Schema.DescribeFieldResult f, String op, String value, String valueto){
        string opBetween = 'between';
        string opContains = 'contains';
        string opIn = 'in';
        string opEquals = 'equals';
        string opNotEquals = 'not equals';
        string operator = ASPISTools.transformOperator(op);
        string escapeFieldName = String.escapeSingleQuotes(f.getName());
      
        if (f.getType() == Schema.DisplayType.Boolean){
              return escapeFieldName+operator+String.escapeSingleQuotes(value)+' ';
        }else if (  (f.getType() == Schema.DisplayType.Double )
                  ||(f.getType() == Schema.DisplayType.Percent )
                  ||(f.getType() == Schema.DisplayType.Currency )
                  ||(f.getType() == Schema.DisplayType.Integer )
                  ||(f.getType() == Schema.DisplayType.Date )
                  ) {
            if (operator == system.Label.OPERATORIN){
              return escapeFieldName+operator+'('+String.escapeSingleQuotes(value)+')';              
            }
			else if (operator == system.Label.OPERATORNOTIN){
              return escapeFieldName+operator+'('+String.escapeSingleQuotes(value)+')';              
            }
			else if (operator == system.Label.OPERATORINCLUDES){
              return escapeFieldName+operator+'('+String.escapeSingleQuotes(value)+')';              
            }
			else if (operator == system.Label.OPERATOREXCLUDES){
              return escapeFieldName+operator+'('+String.escapeSingleQuotes(value)+')';              
            } 
			else if (operator == system.Label.OPERATORBETWEEN ){
              return escapeFieldName+' >= '+String.escapeSingleQuotes(value)+' AND '+escapeFieldName+' <= '+String.escapeSingleQuotes(valueto)+' ';              
            }
            else{
              return escapeFieldName+operator+String.escapeSingleQuotes(value)+' ';              
            }
        }else if (  (f.getType() == Schema.DisplayType.String ) 
                  ||(f.getType() == Schema.DisplayType.Picklist )
                  ||(f.getType() == Schema.DisplayType.TextArea )
                  ||(f.getType() == Schema.DisplayType.Time )
                  ||(f.getType() == Schema.DisplayType.URL )
                  ||(f.getType() == Schema.DisplayType.Email )
                  ||(f.getType() == Schema.DisplayType.EncryptedString )
                  ||(f.getType() == Schema.DisplayType.ID )
                  ||(f.getType() == Schema.DisplayType.MultiPicklist )
                  ||(f.getType() == Schema.DisplayType.Phone )
                  ||(f.getType() == Schema.DisplayType.Combobox )
                  ||(f.getType() == Schema.DisplayType.DateTime ) ) {
            if (operator == system.Label.OPERATORIN){
              if (f.getType() == Schema.DisplayType.MultiPicklist ){
                return escapeFieldName+' INCLUDES '+fmtIN(String.escapeSingleQuotes(value));
              }else{
                return escapeFieldName+operator+fmtIN(String.escapeSingleQuotes(value));
              }
            }
			else if (operator == system.Label.OPERATORNOTIN){
              if (f.getType() == Schema.DisplayType.MultiPicklist ){
                return escapeFieldName+' EXCLUDES '+fmtIN(String.escapeSingleQuotes(value));
              }else{
                return escapeFieldName+operator+fmtIN(String.escapeSingleQuotes(value));
              }             
            }
			else if (operator == system.Label.OPERATORINCLUDES){
              if (f.getType() == Schema.DisplayType.MultiPicklist ){
                return escapeFieldName+' INCLUDES '+fmtIN(String.escapeSingleQuotes(value));
              }else{
                return escapeFieldName+operator+fmtIN(String.escapeSingleQuotes(value));
              }             
            }
			else if (operator == system.Label.OPERATOREXCLUDES){
              if (f.getType() == Schema.DisplayType.MultiPicklist ){
                return escapeFieldName+' EXCLUDES '+fmtIN(String.escapeSingleQuotes(value));
              }else{
                return escapeFieldName+operator+fmtIN(String.escapeSingleQuotes(value));
              }            
            } 
			else if  (operator == ASPISConstants.OPERATOR_BETWEEN ){
              return escapeFieldName+operator+' >= \''+String.escapeSingleQuotes(value)+'\' '+' AND '+escapeFieldName+'<= \''+String.escapeSingleQuotes(valueto)+'\' ';
            } else{
              return escapeFieldName+operator+' \''+String.escapeSingleQuotes(value)+'\' ';
            }

        }else{
            return escapeFieldName+operator+' \''+String.escapeSingleQuotes(value)+'\' ';              
        }
        return null;
    }//end of method

    /****************************************************************************
    *                           BUILD THE SOQL query                            *
    *****************************************************************************/
    public static String getQueryString(String sObjName, List<filterCriteria> criteriaList,Map<String,List<filterCriteria>> subQueryCriteriaMap, Boolean isQueryRule) {

        String queryFields = 'SELECT ';
        String queryFromClause = '';
        String queryWhereClause = '';

        Schema.SObjectType ObjSchema = schemaMap.get(sObjName);
        //system.debug('## getQueryString - sObjName:'+sObjName);
        //system.debug('## getQueryString - ObjSchema:'+ObjSchema);
        Schema.DescribeSObjectResult s =  objschema.getdescribe();
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        List<Schema.DescribeFieldResult> parentFieldRelationship = new List<Schema.DescribeFieldResult>();
        List<Schema.DescribeFieldResult> childFieldRelationship = new List<Schema.DescribeFieldResult>();

        queryFromClause = ' FROM '+(String)ObjSchema.getDescribe().getName();

        for(String f:fieldMap.keySet()){
          Schema.DescribeFieldResult flRes = fieldMap.get(f).getDescribe();

          if(flRes.isAccessible())
            queryFields += flRes.getName() + ', ';

          //if(fieldMap.get(f).getDescribe().getReferenceTo()[0] == obj.getSobjectType())
            //queryWhereClause += fieldMap.get(f).getDescribe().getName()+' = '+(String)obj.get('id');
        }

        if(subQueryCriteriaMap.size()>0){
            for(String subObj:subQueryCriteriaMap.keySet()){
                queryFields += '( ' + ASPISTools.getSubQueryString(s,subQueryCriteriaMap.get(subObj),true) + ' )';
            }
        }

        if(criteriaList!=null && criteriaList.size()>0){
            queryWhereClause = ' WHERE ';

            for(filterCriteria crit:criteriaList){
                // Query the field of filterCriteria without operator, to get the Master SObject fields.
                //system.debug('##### crit '+crit.fieldName+crit.operator);
                if(crit.operator == null || crit.operator == ''){
                    if(!queryFields.contains(crit.fieldName))
                        queryFields += crit.fieldName + ', ';                    
                }
                if(!isQueryRule){
                    if(crit.fieldName.contains('.')){

                      queryFields += crit.fieldName + ', ';

                      if(queryWhereClause.endsWith(' WHERE '))
                        queryWhereClause += crit.fieldName + transformOperator(crit.operator) + ' \'' + crit.value + '\' ';
                      else
                        queryWhereClause += ' AND '+crit.fieldName + transformOperator(crit.operator) + ' \'' + crit.value + '\' ';

                    }else{
                      Schema.DescribeFieldResult f = fieldMap.get(crit.fieldName).getDescribe();
                      if(queryWhereClause.endsWith(' WHERE '))
                        queryWhereClause += getFieldValueWhereClause(sObjName, f, crit.operator, crit.value, crit.valueto);
                      else
                        queryWhereClause += ' AND '+ASPISTools.getFieldValueWhereClause(sObjName, f, crit.operator, crit.value, crit.valueto);
                    }
                }else{
                    if(crit.fieldName=='id'){
                        Schema.DescribeFieldResult f = fieldMap.get(crit.fieldName).getDescribe();
                        if(queryWhereClause.endsWith(' WHERE '))
                            queryWhereClause += ASPISTools.getFieldValueWhereClause(sObjName, f, crit.operator, crit.value, crit.valueto);
                        else
                            queryWhereClause += ' AND '+ASPISTools.getFieldValueWhereClause(sObjName, f, crit.operator, crit.value, crit.valueto);
                    }
                }
            }
        }
        //system.debug('####### queryFields '+queryFields);
        //system.debug('####### Query String: ' + queryFields.removeEnd(', ') + queryFromClause + queryWhereClause);
        return queryFields.removeEnd(', ') + queryFromClause + queryWhereClause;
    }

    /******************************************************************
    *               BUILD THE SUBQUERY OF THE SOQL (CHILD OBJECT)     *
    *******************************************************************/
    public static String getSubQueryString(Schema.DescribeSObjectResult sObjParent, List<filterCriteria> subQueryCriteriaList, Boolean isQueryRule){
        
        //system.debug('##### ANR subQueryCriteriaList '+subQueryCriteriaList);

        String queryFields = 'SELECT ';
        String queryFromClause = '';
        String queryWhereClause = '';

        //Map<String, Schema.SObjectField> fieldMap = sObjParent.fields.getMap();
        Map<String, Schema.SObjectField> childfieldMap = subQueryCriteriaList[0].sObjectName.getSobjectType().getDescribe().fields.getMap();

        //system.debug('##### ANR childfieldMap '+childfieldMap);

        for(filterCriteria f:subQueryCriteriaList){
            for(Schema.ChildRelationship c:sObjParent.getChildRelationships()){
                if(c.getChildSObject() == f.sObjectName.getSobjectType()){
                    queryFromClause = ' FROM '+ c.getRelationshipName();
                    break;
                }
            }
            
        }

        for(String f:childfieldMap.keySet()){
          Schema.DescribeFieldResult flRes = childfieldMap.get(f).getDescribe();

          if(flRes.isAccessible())
            queryFields += flRes.getName() + ', ';

          //if(flRes.getType() == Schema.DisplayType.REFERENCE && flRes.getRelationshipOrder() == 1)
            //childFieldRelationship.put(flRes.getReferenceTo()[0].getDescribe().getName(),flRes);
        }//end for

        if(!isQueryRule){
            if(subQueryCriteriaList!=null && subQueryCriteriaList.size()>0){
              queryWhereClause = ' WHERE ';

              for(filterCriteria crit:subQueryCriteriaList){

                if(queryWhereClause.endsWith(' WHERE '))
                  queryWhereClause += crit.fieldName + transformOperator(crit.operator) + ' \'' + crit.value + '\' ';
                else
                  queryWhereClause += ' AND '+crit.fieldName + transformOperator(crit.operator) + ' \'' + crit.value + '\' ';
                
              }//end for loop
            }//end if
        }//end if

        //system.debug('####### SubQuery String: ' + queryFields.removeEnd(', ') + queryFromClause + queryWhereClause);
        return queryFields.removeEnd(', ') + queryFromClause + queryWhereClause;    
    }

    /*****************************************************************************************
    *               APPLY THE RULE FROM THE RULES ENGINE ON THE CURRENT OBJECT               *
    ******************************************************************************************/
    public static Boolean applyRuleOnObject(filterCriteria crit){

        Boolean result;
        
        if(crit.operator!=null && crit.fieldName!=null){
        
          //system.debug('######## rules criteria: ' + crit);
          string xOp = ASPISTools.transformOperator(crit.operator);
          string escapeFieldName = String.escapeSingleQuotes(crit.fieldName);
          
          Map<String, Schema.SObjectField> fieldMap = crit.sObjectName.getSobjectType().getDescribe().fields.getMap();
          Schema.DescribeFieldResult f = fieldMap.get(crit.fieldName).getDescribe();

          

          if(crit.operator == system.Label.OPERATOREQUALS){
             //system.debug('######## crit.sObjectName.get(crit.fieldName): ' + crit.sObjectName.get(crit.fieldName));
                if(crit.value != null)
                    result = ((String.valueof(crit.sObjectName.get(crit.fieldName))) == String.valueof(crit.value));
                else
                    result = ((String)crit.sObjectName.get(crit.fieldName) == '');


          }else if(crit.operator == system.Label.OPERATORNOTEQUALS){

              if(crit.value != null && crit.sObjectName.get(crit.fieldName) != null)
                  result = ((String.valueof(crit.sObjectName.get(crit.fieldName))).toUpperCase() != String.valueof(crit.value));
              else
                  result = ((String.valueof(crit.sObjectName.get(crit.fieldName))) != '' && (String.valueof(crit.sObjectName.get(crit.fieldName))) != null);

          }else if(crit.operator == system.Label.OPERATORCONTAINS){
              result = ((String)crit.sObjectName.get(crit.fieldName)).containsIgnoreCase(crit.value);

          }else if(crit.operator == system.Label.OPERATORIN){
              List<String> tmpValues = new List<String>();
              tmpValues = crit.value.split(ASPISConstants.STRING_SEPARATOR);
              result = false;
              Set<String> possibleValues = new Set<String> ();
              possibleValues.addAll(tmpValues);
              result = possibleValues.contains((String)crit.sObjectName.get(crit.fieldName));

          }else if(crit.operator == system.Label.OPERATORNOTIN){
              List<String> tmpValues = new List<String>();
              tmpValues = crit.value.split(ASPISConstants.STRING_SEPARATOR);
              result = false;
              Set<String> possibleValues = new Set<String> ();
              possibleValues.addAll(tmpValues);
              result = (!possibleValues.contains((String)crit.sObjectName.get(crit.fieldName)));

          }else if(crit.operator == system.Label.OPERATORINCLUDES){
              List<String> tmpValues = new List<String>();
              tmpValues = crit.value.split(ASPISConstants.STRING_SEPARATOR);
              result = false;
              Set<String> possibleValues = new Set<String> ();
              possibleValues.addAll(tmpValues);
              result = possibleValues.contains((String)crit.sObjectName.get(crit.fieldName));
			
			//RLA 28/02/2022 C-004565: Garages du Groupe Ferron - Marques Exclues sur du NON Partenaire
          }else if(crit.operator == 'EXCLUDESNEW'){
              List<String> tmpValues = new List<String>();
              system.debug('@@ crit.value'+crit.value);
              system.debug('@@ crit.sObjectName'+crit.sObjectName);
              String fieldValue =(String)crit.sObjectName.get(crit.value);
              tmpValues = String.IsNotBlank(fieldValue) ? fieldValue.split(ASPISConstants.STRING_SEPARATOR) : new List<String>();
              result = false;
              Set<String> possibleValues = new Set<String> ();
              possibleValues.addAll(tmpValues);
              String assessmentValue =(String)crit.sObjectName.get(crit.fieldName);
              result = (!possibleValues.contains(assessmentValue.toUpperCase()));

          }else if(crit.operator == system.Label.OPERATOREXCLUDES){
              List<String> tmpValues = new List<String>();
              tmpValues = crit.value.split(ASPISConstants.STRING_SEPARATOR);
              result = false;
              Set<String> possibleValues = new Set<String> ();
              possibleValues.addAll(tmpValues);
              result = (!possibleValues.contains((String)crit.sObjectName.get(crit.fieldName)));

          }else if(crit.operator == system.Label.OPERATORGREATER){
              if(f.getType() == Schema.DisplayType.Date){
                  List<String> tempDate = crit.value.split('/');
                  result = ((Date)crit.sObjectName.get(crit.fieldName) > Date.newinstance(Integer.valueOf(tempDate[2]),Integer.valueOf(tempDate[1]),Integer.valueOf(tempDate[0])));
              }
              else
                  result = ((Decimal)crit.sObjectName.get(crit.fieldName) > Decimal.valueOf(crit.value));

          }else if(crit.operator == system.Label.OPERATORGREATEREQUALS){
             if(f.getType() == Schema.DisplayType.Date){
                  List<String> tempDate = crit.value.split('/');
                  result = ((Date)crit.sObjectName.get(crit.fieldName) > Date.newinstance(Integer.valueOf(tempDate[2]),Integer.valueOf(tempDate[1]),Integer.valueOf(tempDate[0])));
              }
              else
                  result = ((Decimal)crit.sObjectName.get(crit.fieldName) >= Decimal.valueOf(crit.value));

          }else if(crit.operator == system.Label.OPERATORLESS){

              if(f.getType() == Schema.DisplayType.Date){
                  List<String> tempDate = crit.value.split('/');
                  result = ((Date)crit.sObjectName.get(crit.fieldName) > Date.newinstance(Integer.valueOf(tempDate[2]),Integer.valueOf(tempDate[1]),Integer.valueOf(tempDate[0])));
              }
              else
                  result = ((Decimal)crit.sObjectName.get(crit.fieldName) < Decimal.valueOf(crit.value));

          }else if(crit.operator == system.Label.OPERATORLESSEQUALS){
              if(f.getType() == Schema.DisplayType.Date){
                  List<String> tempDate = crit.value.split('/');
                  result = ((Date)crit.sObjectName.get(crit.fieldName) > Date.newinstance(Integer.valueOf(tempDate[2]),Integer.valueOf(tempDate[1]),Integer.valueOf(tempDate[0])));
              }
              else
                  result = ((Decimal)crit.sObjectName.get(crit.fieldName) <= Decimal.valueOf(crit.value));

          }

        }

        return result;
    }
    public static String[] picklist_values(String object_name, String field_name) {
      String[] values = new String[]{};
      String[] types = new String[]{object_name};
      Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
      for(Schema.DescribeSobjectResult res : results) {
         for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
            if (entry.isActive()) {values.add(entry.getValue());}
         }
      }
      return values;
   }
    
    /*public static String getSLABasedOnBusinessHour(String BHName, Datetime startDate, Datetime endDate, Decimal referenceDuration){
        
        String returnCode;
        Decimal duration;
        Decimal lowThresold = (referenceDuration - (referenceDuration * 0.1));
        Decimal highThresold= (referenceDuration + (referenceDuration * 0.1));

        BusinessHours BH = new BusinessHours();
        BH = [SELECT Id FROM BusinessHours WHERE Name=: BHName AND IsActive=true];

        duration = BusinessHours.diff(BH.Id,startDate,endDate);

        if(BH != null){
            System.debug('>># duration:'+duration);
            System.debug('>># lowThresold:'+lowThresold);
            System.debug('>># highThresold:'+highThresold);
            if(duration < lowThresold)
                returnCode = system.Label.SLAHIGHPERFORMANCE;
            else if ((lowThresold <= duration) && (duration <= highThresold))
                returnCode = system.Label.SLAMEDIUMPERFORMANCE;
            else
                returnCode = system.Label.SLALOWPERFORMANCE;
        }else{
            //DUN - delete class 
            //throw new ASPISException(system.Label.SLABUSINESSHOURISSUE +' - '+ system.Label.SLABUSINESSHOURERRORMESSAGE);
            system.debug('## Exception: ' + system.Label.SLABUSINESSHOURISSUE +' - '+ system.Label.SLABUSINESSHOURERRORMESSAGE);
        }
        
        return returnCode;
    }*/
}