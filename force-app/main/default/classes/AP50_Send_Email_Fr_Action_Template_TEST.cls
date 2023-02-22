@istest
public class AP50_Send_Email_Fr_Action_Template_TEST {
    static list<Action__c> lstAct ;
    static Action__c act;
    static Task tsk;
    static{
        lstAct = new list<Action__c>();
        act = testFactory.createActionTemplate('test');
        lstAct.add(act);
        insert lstAct;
        
        tsk.Name__c = 'Nouveau';
        tsk.Recordtype.Name = 'New BS - Select Assessments Tool';
        tsk.Status = 'Open';
        tsk.AssessmentsTools__c = 'DIVA';
        
        insert tsk;
    }
    static testMethod void SendEmailTest(){
        test.startTest();
        	AP50_Send_Email_From_Action_Template classsend = new AP50_Send_Email_From_Action_Template();
        	classsend.SendEmail(lstAct, tsk);
        test.stopTest();
    }
}