public without sharing class AP51_Create_Or_Modify_Object {
    public void InsertObject(list<Action__c> lstActionTemplateToInsert, Sobject record) {
        set<Id> IdActiontemplIns = new set<Id> ();
        map<string,Action__c> mapFieldsIns = new map<string,Action__c>();
        //costruire l'object
        //String sObjName = objId.getSObjectType().getDescribe().getName();
        //SObject record = Database.query('Select Id, Name__c, Case__c, Case__r.Name, Case__r.CaseURL__c, Case__r.Status__c From ' + sObjName + ' Where Id = \''+objId+'\'');

        if(lstActionTemplateToInsert[0].Object__c != null){
            string myString = lstActionTemplateToInsert[0].Object__c;
            SObjectType objToken = Schema.getGlobalDescribe().get(myString); 
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();
            SObject sObjType = (SObject) Type.forName(myString).newInstance();
            list<SObject> lstOjbToInsert = new list<SObject>();
            if(lstActionTemplateToInsert.size()>0){
                for(Action__c item : lstActionTemplateToInsert){
                    IdActiontemplIns.Add(item.Id);
                }
                for(list<Action__c> act : [SELECT Id, Name, Field__c, Field_Value__c, ObjectToUpdate__c, ValueFromType__c, Description__c, recordType.Name, MainObject__c FROM Action__c WHERE recordType.Name = 'Field Mapping' AND MainObject__c IN: IdActiontemplIns]){
                    lstOjbToInsert.add(CreateListObjectToInsert(act, fields, sObjType, record));
                }
            }
            if(lstOjbToInsert.size()>0){
                system.debug('FII>> '+lstOjbToInsert);
                insert lstOjbToInsert;
            }
        }
        
    }
    public void UpdateObject(list<Action__c> lstActionTemplateToInsertToUpdate, Sobject record) { //sobject
        set<Id> IdActiontemplUpd = new set<Id> ();
        map<string,Action__c> mapFieldsUpd = new map<string,Action__c>();
        List<Action__c> listActionTempUpd = new List<Action__c>();
        //costruire l'object
        //String sObjName = objId.getSObjectType().getDescribe().getName();
        //SObject record = Database.query('Select Id, Name__c, Case__c, Case__r.Name, Case__r.CaseURL__c, Case__r.Status__c From ' + sObjName + ' Where Id = \''+objId+'\'');
        if(lstActionTemplateToInsertToUpdate[0].Object__c != null){
            string myString = lstActionTemplateToInsertToUpdate[0].Object__c;
            SObjectType objToken = Schema.getGlobalDescribe().get(myString); 
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();
            system.debug('FFII = '+fields);
            SObject sObjType = (SObject) Type.forName(myString).newInstance();
            list<SObject> lstOjbToUpdate = new list<SObject>();
            if(lstActionTemplateToInsertToUpdate.size()>0){
                for(Action__c item : lstActionTemplateToInsertToUpdate){
                    IdActiontemplUpd.Add(item.Id);
                }
                for(list<Action__c> act : [SELECT Id, Name, Field__c, Field_Value__c, ObjectToUpdate__c, ValueFromType__c, Description__c, recordType.Name, MainObject__c FROM Action__c WHERE recordType.Name = 'Field Mapping' AND MainObject__c IN: IdActiontemplUpd]){
                    lstOjbToUpdate.add(CreateListObjectToUpdate(act, fields, sObjType, record));
                }
            }
            if(lstOjbToUpdate.size()>0){
                system.debug('FII>> '+lstOjbToUpdate);
                update lstOjbToUpdate;
            }
        }
    }
    public sobject CreateListObjectToInsert (List<Action__c> lstActionTempIns, Map<String, SObjectField> fields , SObject sObjType , SObject record){
        system.debug('>>>>>>>>'+lstActionTempIns);
        if(lstActionTempIns.size()>0){
            for(Action__c act : lstActionTempIns){
                if(fields.size()>0){
                    for(string val : fields.keyset()){
                        if(val == act.Field__c){
                            if(act.ValueFromType__c == 'Dynamic'){
                                Object referencedValue = null;
                                string fldVal = act.Field_Value__c;
                                system.debug('>>> fldVal ='+fldVal);
                                list<string> lstStr = fldVal.split('\\.');
                                system.debug('>>> '+lstStr);
                                if(lstStr.size()== 2){
                                    referencedValue = record.getSobject(lstStr[0]).get(lstStr[1]);
                                }
                                if(lstStr.size()== 3){
                                    referencedValue = record.getSobject(lstStr[0]).getSobject(lstStr[1]).get(lstStr[2]);
                                }
                                system.debug('FII-> '+referencedValue);
                                string fld = act.Field__c;
                                sObjType.put(fld, referencedValue);
                            }
                            else{
                                string fld = act.Field__c;
                                sObjType.put(fld, act.Field_Value__c);
                            }
                        }
                    }
                }
            }
        }
        System.debug('>> Sobject >>'+sObjType);
        return sObjType;
    }
    public sobject CreateListObjectToUpdate (List<Action__c> lstActionTempUpd, Map<String, SObjectField> fields , SObject sObjType , SObject record){
        system.debug('>>>>>>>>'+lstActionTempUpd);
        string idtoUpd;
        if(lstActionTempUpd.size()>0){
            for(Action__c act : lstActionTempUpd){
                idtoUpd = act.ObjectToUpdate__c;
                if(fields.size()>0){
                    for(string val : fields.keyset()){
                        if(val == act.Field__c){
                            if(act.ValueFromType__c == 'Dynamic'){
                                Object referencedValue = null;
                                string fldVal = act.Field_Value__c;
                                system.debug('fields => '+fldVal);
                                string[] lstStr = fldVal.split('\\.');
                                system.debug('Size => '+lstStr.Size());
                                system.debug('fields => '+lstStr);
                                if(lstStr.size()== 2){
                                    referencedValue = record.getSobject(lstStr[0]).get(lstStr[1]);
                                }
                                if(lstStr.size()== 3){
                                    referencedValue = record.getSobject(lstStr[0]).getSobject(lstStr[1]).get(lstStr[2]);
                                }
                                system.debug('FII-> '+referencedValue);
                                string fld = act.Field__c;
                                sObjType.put(fld, referencedValue);
                            }
                            else{
                                string fld = act.Field__c;
                                sObjType.put(fld, act.Field_Value__c);
                            }
                        }
                    }
                }
            }
        }
        System.debug('>> Sobject >>'+sObjType);
        sObjType.put('Id', idtoUpd);
        return sObjType;
    }
}