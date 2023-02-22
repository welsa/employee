/***
* @description Lightning controller to provide details about existing FieldSets.
* @author      P-E GROS
* @date        Oct. 2020
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegGetFieldSet_CTL {

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a configured field set.
* @param       fieldSet             Dev Name of the Field Set 
* @return      Map<String,Object>   Map containing 2 entries:
*                                   'label' with the label of the field set,
*                                   'fields' with the label, name and type of each accessible field
* @exception   none really specific.
***/
@AuraEnabled(cacheable=true)
public static Map<String,Object> getFieldSetDesc(final String name) {
    System.debug('getFieldSetDesc: START with field set name ' + name);

    String[] fsParts = name.split('\\.');
    System.debug('getFieldSetDesc: fsParts extracted ' + fsParts);
    if (fsParts.size()<> 2) throw new AuraHandledException(
        'Bad field set name format for ' + name + '\n Should be "object.fsName".');

    String objName = fsParts[0];
    System.debug('getFieldSetDesc: objName extracted ' + objName);
    String fsName  = fsParts[1];
    System.debug('getFieldSetDesc: fsName extracted ' + fsName);

    Schema.SObjectType objDesc = Schema.getGlobalDescribe().get(objName);
    if (objDesc == null) throw new AuraHandledException(
        'Unknown Object Name for field set ' + name + ' !');
    System.debug('getFieldSetDesc: object descriptor found ');

    Schema.FieldSet fsDesc = objDesc.getDescribe().fieldSets.getMap().get(fsName);
    if (fsDesc == null) throw new AuraHandledException(
        'Unknown Field Set Name for field set ' + name + ' !');
    System.debug('getFieldSet: field set descriptor found ');

    Map<String,Object> descResult = new Map<String,Object>();
    descResult.put('label',fsDesc.getLabel());
    System.debug('getFieldSet: field set Label set ' + fsDesc.getLabel());

    List<Map<String,Object>> fieldDescs = new List<Map<String,Object>>();
    descResult.put('fields',fieldDescs);
    for (Schema.FieldSetMember fieldIter : fsDesc.getFields()) {
        System.debug('getFieldSet: processing field ' + fieldIter.getSObjectField());

        Schema.DescribeFieldResult fieldDesc = fieldIter.getSObjectField().getDescribe();
        System.debug('getFieldSet: fieldDesc fetched ' + fieldDesc);

        if (fieldDesc.isAccessible()) {
            System.debug('getFieldSet: adding accessible field ' + fieldIter.getSObjectField());
            Map<String,Object> fieldMap = new Map<String,Object> {
                'label' => fieldDesc.getLabel(),
                'name' => fieldDesc.getName(),
                'type' => '' + fieldDesc.getType(),
                'required' => fieldIter.getRequired()
            };
            fieldDescs.add(fieldMap);
        }
        else {
            System.debug('getFieldSet: field not accessible ' + fieldIter.getSObjectField());
        }
    }

    System.debug('getFieldSet: fieldDescs prepared ' + fieldDescs);
    System.debug('getFieldSet: descResult finalised ' + descResult);

    System.debug('getFieldSet: END for fieldDescs with size ' + fieldDescs.size());
    return descResult;
}

/***
* @description Simple method to fetch the list of fields allowed for the user included in
*              a list of configured field sets. THis method iterates over the list by 
*              calling the unitary getFieldSetDesc method and agregates the resuts.
* @param       fieldSets            List of Field Set's Dev Names  
* @return      Map<String,Object>   Map of maps containing the fieldSet description
*                                   retrieved for each fieldset name.
* @exception   None really specific.
***/
@AuraEnabled(cacheable=true)
public static Map<String,Object> getFieldSetDescs(final list<String> names) {
    System.debug('getFieldSetDescs: START with ' + names.size() + ' elements');
    Map<String,Object> nameDescs = new Map<String,Object>();

    for (String iterName : names) {
        System.debug('getFieldSetDescs: processing field set ' + iterName);
        nameDescs.put(iterName, getFieldSetDesc(iterName));
    }

    System.debug('getFieldSetDescs: END with nameDescs ' + nameDescs);
    return nameDescs;
}

}