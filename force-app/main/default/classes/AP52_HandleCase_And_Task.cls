public without sharing class AP52_HandleCase_And_Task {
    public void HandleIsUpdate (list<Action__c> lstActionTemplate, Sobject record){
        list<Action__c> lstActTemp = new list<Action__c> ();
        map<Id, list<Action__c>> mapActionTempOriginWithTrigger = new map<Id, list<Action__c>>();
        map<Id, string> mapActionTempOriginCriteria = new map<Id, string>();
        map<Id, string> mapGetQueryToActionTrigger = new map<Id, string>();
        map<Id, string> mapGetQueryToAction = new map<Id, string>();
        map<Id, string> mapComptVal = new map<Id, string>();
        map<Id, string> mapFilterLogic = new map<Id, string>();
        map<string, boolean> maptestLogic = new map<string, boolean>();
        map<String, string> mapActionTemp = new map<string, string>();
        map<String, string> mapOperator = new map<string, string>();
        list<list<Action__c>> lstActs = new list<list<Action__c>>();
        map<id, list<string>> lstFields = new map<Id, list<string>> ();
        map<id, list<string>> lstFieldsval = new map<Id, list<string>> ();
        list<Action__c> lstActionTempToDoInsert = new list<Action__c>();
        list<Action__c> lstActionTempToDoUpdate = new list<Action__c>();
        list<Action__c> lstActionTempToDoSendMail = new list<Action__c>();
        set<Id> LstIdActionTemp = new set<Id> ();
        string queryString = 'SELECT Id';
        list<string> lstStr = new list<string>();
        list<string> lstStrVal = new list<string>();
        if(lstActionTemplate.size()>0){
            for(Action__c item: lstActionTemplate){
                LstIdActionTemp.add(item.Id);
                mapFilterLogic.put(item.Id, item.Filter_Logic__c);
                mapGetQueryToActionTrigger.put(item.Id, 'SELECT Id, Name, RecordType.Name, Trigger__c, Recipient__c, Number__c, Email_Alert__c, Object__c, Field__c, MainObject__c, Operator__c, Field_Value__c FROM Action__c Where Trigger__c  = \''+ item.Id+'\'');
                mapGetQueryToAction.put(item.Id, 'SELECT Id, Name, RecordType.Name, Field__c, MainObject__c, Number__c, Operator__c, Field_Value__c FROM Action__c Where RecordType.Name = \'Criteria\' AND MainObject__c = \''+ item.Id+'\'');
            }
            for(Id IdActionTempOrigin : LstIdActionTemp){
                mapActionTempOriginWithTrigger.put(IdActionTempOrigin, Database.query(mapGetQueryToActionTrigger.get(IdActionTempOrigin)));
                // for(list<Action__c> lstActWithTrigger : [SELECT Id, Name, RecordType.Name, Trigger__c, Recipient__c, Number__c, Email_Alert__c, Object__c, Field__c, MainObject__c, Operator__c, Field_Value__c FROM Action__c Where Trigger__c  = IdActionTempOrigin]){
                //     mapActionTempOriginWithTrigger.put(lstActWithTrigger[0].Trigger__c, lstActWithTrigger);
                // }
                for(list<Action__c> lstAct : Database.query(mapGetQueryToAction.get(IdActionTempOrigin))){
                    integer compt = 0;
                    string st = '';
                    list<string> lstNumberAndBoolean = new list<string>();
                    system.debug('## lstAct=> '+lstAct);
                    system.debug('## lstAct.size => '+lstAct.Size());
                    if(lstAct.size()>0){
                        for(Action__c item : lstAct){
                            system.debug('## item=> '+item);
                            boolean check = false;
                            switch on item.Operator__c {
                                when 'EQUALS' {
                                    system.debug('Val = '+item.Field__c);
                                    string[] lstStg = item.Field__c.split('\\.');
                                    if(lstStg.size()== 2){
                                        system.debug('## record = ' +record.getSobject(lstStg[0]).get(lstStg[1]));
                                        system.debug('## map = ' +item.Field_Value__c);
                                        if(item.Field_Value__c == record.getSobject(lstStg[0]).get(lstStg[1])){
                                            system.debug('## 1');
                                            check = true;
                                        }
                                    }
                                    else{
                                        if(item.Field_Value__c == record.get(item.Field__c)){
                                            system.debug('## 2');
                                            check = true;
                                        }
                                    }
                                }
                                when 'NOT EQUALS' {
                                    system.debug('Val = '+item.Field__c);
                                    string[] lstStg = item.Field__c.split('\\.');
                                    if(lstStg.size()== 2){
                                        system.debug('## record = ' +record.getSobject(lstStg[0]).get(lstStg[1]));
                                        system.debug('## map = ' +item.Field_Value__c);
                                        if(item.Field_Value__c != record.getSobject(lstStg[0]).get(lstStg[1])){
                                            system.debug('## 1');
                                            check = true;
                                        }
                                    }
                                    else{
                                        if(item.Field_Value__c != record.get(item.Field__c)){
                                            system.debug('## 2');
                                            check = true;
                                        }
                                    }
                                }
                                when else {
                                    system.debug('## Erreur');
                                }
                            }
                            st += string.valueof(item.Number__c)+';'+string.valueof(check)+';';
                            system.debug('## st=> '+st);
                        }
                        mapActionTempOriginCriteria.put(lstAct[0].MainObject__c, st.removeEnd(';'));
                    } 
                }
            }
            
            
            for(Id currentId : LstIdActionTemp){
                list<string> lstSt = new list<string>();
                string s = mapFilterLogic.get(currentId);
                lstSt = mapActionTempOriginCriteria.get(currentId).split(';');
                system.debug('## lstSt=> '+lstSt);
                if(lstSt.size()>0){
                    for(Integer i = 0; i < lstSt.size(); i = i +2){
                        s = s.replace(lstSt[i],lstSt[i+1]);
                    }
                    system.debug('## s=> '+s);
                    boolean validate = BooleanEvaluate.evaluateExpression(s);
                    system.debug('## validate=> '+validate);
                    if(mapActionTempOriginWithTrigger.get(currentId) != null){
                        if(validate){
                            for(Action__c act : mapActionTempOriginWithTrigger.get(currentId)){
                                if(act.RecordType.Name == 'Send Email'){
                                    lstActionTempToDoSendMail.Add(act);
                                }
                                if(act.RecordType.Name == 'Insert Object'){
                                    lstActionTempToDoInsert.Add(act);
                                }
                                if(act.RecordType.Name == 'Update Object'){
                                    lstActionTempToDoUpdate.Add(act);
                                }
                            }
                            system.debug('## lstActionTempToDoSendMail = '+lstActionTempToDoSendMail);
                            system.debug('## lstActionTempToDoInsert = '+lstActionTempToDoInsert);
                            system.debug('## lstActionTempToDoUpdate = '+lstActionTempToDoUpdate);
                            
                        }
                    } 
                }
            }
            if(lstActionTempToDoSendMail.size()>0){
                try{
                    AP50_Send_Email_From_Action_Template ClassSendMail = new AP50_Send_Email_From_Action_Template();
                    ClassSendMail.SendEmail(lstActionTempToDoSendMail, record);
                }
                catch(DmlException e){
                    if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
                    }
                }
            }
            if(lstActionTempToDoInsert.size()>0){
                try{
                    AP51_Create_Or_Modify_Object classInsertObject = new AP51_Create_Or_Modify_Object();
                    classInsertObject.InsertObject(lstActionTempToDoInsert, record);
                }
                catch(DmlException e){
                    if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
                    }
                }
            }
            if(lstActionTempToDoUpdate.size()>0){
                try{
                    AP51_Create_Or_Modify_Object classUpdateObject = new AP51_Create_Or_Modify_Object();
                    classUpdateObject.UpdateObject(lstActionTempToDoUpdate, record);
                }
                catch(DmlException e){
                    if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
                    }
                }
            }
        }
        
    }
    //En entrée un action template et une SObject 
    /*public void HandleIsUpdate (Action__c ActionTemplateToUpd, Id obj){
        list<Action__c> lstActTemp = new list<Action__c> ();
        list<Action__c> lstActTempToAddTrigger = new list<Action__c> ();
        map<String, string> mapActionTemp = new map<string, string>();
        map<String, string> mapOperator = new map<string, string>();
        integer compt = 0;
        id actionId = ActionTemplateToUpd.Id;
        map<id, list<string>> lstFields = new map<Id, list<string>> ();
        map<string, string> lstFieldsAndVal = new map<string, string> ();
        set<Id> LstIdActionTemp = new set<Id> ();
        string queryString = 'SELECT Id';
        list<string> lstStr = new list<string>();
        list<string> lstStrVal = new list<string>();
        lstActTemp = [SELECT Id, Name, RecordType.Name, Field__c, Email_Alert__c, Recipient__c, MainObject__c, Operator__c, Field_Value__c FROM Action__c Where RecordType.Name = 'Criteria' AND MainObject__c =: actionId]; // AND MainObject__c = ActionTemplateToUpd.Id
        for(Action__c item : lstActTemp){
            mapActionTemp.put(item.Field__c, item.Field_Value__c);
            mapOperator.put(item.Field__c, item.Operator__c);
            queryString+= ', '+item.Field__c;
        }
        String sObjName = obj.getSObjectType().getDescribe().getName();
        queryString+=' FROM '+sObjName+ ' WHERE Id= \''+obj+ '\'';
        system.debug('queryString =>'+queryString);
        SObject record = Database.query(queryString);
        for(string val :mapActionTemp.keyset()){
            system.debug('Val = '+val);
            string[] lstStg = val.split('\\.');
            if(lstStg.size()== 2){
                system.debug('## record = ' +record.getSobject(lstStg[0]).get(lstStg[1]));
                system.debug('## map = ' +mapActionTemp.get(val));
                if(mapActionTemp.get(val) == record.getSobject(lstStg[0]).get(lstStg[1])){
                    system.debug('## 1');
                    compt++;
                }
            }
            else{
                if(mapActionTemp.get(val) == record.get(val)){
                    system.debug('## 2');
                    compt++;
                }
            }
        }
        system.debug('compt = '+compt);
        system.debug('mapActionTemp = '+mapActionTemp.size());
        if(mapActionTemp.size() == compt){
            lstActTempToAddTrigger = [SELECT Id, Name, RecordType.Name, Trigger__c, Recipient__c, Email_Alert__c, Object__c, Field__c, MainObject__c, Operator__c, Field_Value__c FROM Action__c Where Trigger__c =:actionId]; 
            system.debug('## lstActTempToAddTrigger = '+lstActTempToAddTrigger);
            list<Action__c> lstActionTempToDoInsert = new list<Action__c>();
            list<Action__c> lstActionTempToDoUpdate = new list<Action__c>();
            list<Action__c> lstActionTempToDoSendMail = new list<Action__c>();
            for(Action__c act : lstActTempToAddTrigger){
                if(act.RecordType.Name == 'Send Email'){
                    lstActionTempToDoSendMail.Add(act);
                }
                if(act.RecordType.Name == 'Insert Object'){
                    lstActionTempToDoInsert.Add(act);
                }
                if(act.RecordType.Name == 'Update Object'){
                    lstActionTempToDoUpdate.Add(act);
                }
            }
            system.debug('## lstActionTempToDoSendMail = '+lstActionTempToDoSendMail);
            system.debug('## lstActionTempToDoInsert = '+lstActionTempToDoInsert);
            system.debug('## lstActionTempToDoUpdate = '+lstActionTempToDoUpdate);
            if(lstActionTempToDoSendMail.size()>0){
                AP50_Send_Email_From_Action_Template ClassSendMail = new AP50_Send_Email_From_Action_Template();
                ClassSendMail.SendEmail(lstActionTempToDoSendMail, obj);
            }
            if(lstActionTempToDoInsert.size()>0){
                AP51_Create_Or_Modify_Object classInsertObject = new AP51_Create_Or_Modify_Object();
                classInsertObject.InsertObject(lstActionTempToDoInsert, obj);
            }
            if(lstActionTempToDoUpdate.size()>0){
                AP51_Create_Or_Modify_Object classUpdateObject = new AP51_Create_Or_Modify_Object();
                classUpdateObject.UpdateObject(lstActionTempToDoUpdate, obj);
            }
        }
    }*/


        /*for(Action__c item: lstActionTemplate){
            string query = 'SELECT Id, Name, RecordType.Name, Field__c, MainObject__c, Operator__c, FieldValue__c FROM Action__c Where RecordType.Name = \'Criteria\' AND MainObject__c =: \''+item.Id+ '\'';
            for(list<Action__c> records : Database.query(query)){
                mapActionTemp.put(item.Id, records);
            }
        }
        for(Id item: mapActionTemp.keyset()){
            for(Action__c act : mapActionTemp.get(item)){
                lstStr.add(act.Field__c);
                lstStrVal.add(act.FieldValue__c);
            }
            lstFields.put(item, lstStr);
            lstFieldsVal.put(item, lstStrVal);
        }
        for(Id idAct : lstFields.keyset()){
            for(string : str lstFields.get(idAct)){
                queryString+=', '+str;
            }
            queryString+= 'WHERE id = \''+obj.Id+'\'';
        }*/
        
    
}