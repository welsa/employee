@istest
public class AP51_Create_Or_Modify_Object_TEST {
	static list<Action__c> lstAct ;
	static list<Action__c> lstActAll ;
    static Action__c act;
    static Action__c act2;
    static Task tsk;
    static Action__c actionTrigger;
    static Action__c actionmainObj;
    static{
        tsk = new Task();
        tsk.Name__c = 'Nouveau';
        tsk.RecordtypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New BS - Select Assessments Tool').getRecordTypeId();
        tsk.Status = 'Open';
        tsk.AssessmentsTools__c = 'DIVA';
        
        insert tsk;
        
        lstAct = new list<Action__c>();
        lstActAll = new list<Action__c>();
        actionTrigger = testFactory.createActionTemplate('test RT Trigger');
        actionTrigger.Object__c = 'task';
        actionTrigger.RecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get('Trigger').getRecordTypeId();
        actionTrigger.Filter_Logic__c = '1 AND 2';
        lstAct.add(actionTrigger);
        insert lstAct;
        act = testFactory.createActionTemplate('test');
        act.Object__c = 'task';
        act.RecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get('Field Mapping').getRecordTypeId();
        act.MainObject__c = lstAct[0].Id;
        act.Field__c = 'Name__c';
        act.Number__c = 1;
        act.Field_Value__c = 'Nouveau';
        lstActAll.add(act);
        
        act2 = testFactory.createActionTemplate('test2');
        act2.Object__c = 'task';
        act2.ObjectToUpdate__c = tsk.Id;
        act2.RecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get('Field Mapping').getRecordTypeId();
        act2.MainObject__c = lstAct[0].Id;
        act2.Field__c = 'Recordtype.Name';
        act2.Number__c = 2;
        act2.Field_Value__c = 'New BS - Select Assessments Tool';
        lstActAll.add(act2);
        
        insert lstActAll;
        
        
    }
    static testMethod void InsertTaskTest(){
        test.startTest();
        	AP51_Create_Or_Modify_Object classInsert = new AP51_Create_Or_Modify_Object();
        	classInsert.InsertObject(lstAct, tsk);
        test.stopTest();
    }
    static testMethod void UpdateTaskTest(){
        test.startTest();
        	AP51_Create_Or_Modify_Object classInsert = new AP51_Create_Or_Modify_Object();
        	classInsert.UpdateObject(lstAct, tsk);
        test.stopTest();
    }
}