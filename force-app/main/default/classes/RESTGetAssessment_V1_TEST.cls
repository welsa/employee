/*************************************************************************************
Class Name - RESTGetAssessment_V1_Test
Version - 1.0
Created Date - 23 JUNE 2015
Function - Get assessment web service test class

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* Brayan Nunhuck 23/06/2015     Original Version
* Shamina M      27/01/2016     review and updates to increase coverage + case 1386
*************************************************************************************/
@isTest
private class RESTGetAssessment_V1_TEST {
    static list<Account> l_Accounts;
    static list<user> l_users;   
    static List<Assessment__c> l_Assessments;
    static List<Assessment__c> listAssRef; 

    static{
        
        l_Accounts = new list<Account>();
        l_users = new list<user>();
        l_Assessments = new list<Assessment__c>();

        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){
            // Create several Bodyshops and Distributors.
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            bs1.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            dist1.ReferenceNumber__c = '123433';
            l_Accounts.add(dist1);
            dist1.ContactUser__c = l_users[0].Id;
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            l_Accounts.add(dist2);
            dist2.ContactUser__c = l_users[0].Id;            
            insert l_Accounts;
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', l_Accounts[0]);
            ass1.TECHRulesAppliedDescription__c  = 'TEST';
            l_Assessments.add(ass1);
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', l_Accounts[0]);
            l_Assessments.add(ass2);
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', l_Accounts[0]);
            l_Assessments.add(ass3);            
            insert l_Assessments;
            
            //Shamina M: 20160127 quering assessment to get new name since it is reset to random string in TestFactory
            listAssRef = [select AssessmentID__c from Assessment__c where Id IN:l_Assessments];
        }
    }

    @isTest static void Test_AssessmentFound() {
        system.runAs(l_users[0]){            
            Test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '[{"AssessmentReference":"'+listAssRef[0].AssessmentID__c+'"}'+
                                ',{"AssessmentReference":"'+listAssRef[1].AssessmentID__c+'"}'+
                                ',{"AssessmentReference":"'+listAssRef[2].AssessmentID__c+'"}]';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/getAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTGetAssessment_V1.getAssessment();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            system.assertEquals(true, Json != null); 
            Test.stopTest();
        }
    }

    @isTest static void Test_NoAssessment() {
        system.runAs(l_users[0]){
            Test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            String jsonStr = '[{"AssessmentReference":"BNU TEST 00111"}]';
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/getAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTGetAssessment_V1.getAssessment();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            jsonStr = Json.toString();
            system.assertEquals(true, Json != null); 
            system.assertEquals(true, jsonStr.contains('No Assessment.')); 
            Test.stopTest();
        }
    }

    static testMethod void Test_CatchException() {
      system.runAs(l_users[0]){  

        test.startTest();
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            //Shamina M: 20160127 - dummy json string to test for catch exception section        
            String jsonStr;
            for(integer i=0; i<3000; i++){
                jsonStr += '*****INVALID_JSON';
            } 
            req.httpMethod = 'POST';
            req.requestURI = '/v1.0/getAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTGetAssessment_V1.getAssessment();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());           
            jsonStr = Json.toString();
            system.assertEquals(true, Json != null);
            system.assertEquals(true, jsonStr.contains('ErrorMessage')); 
        test.stopTest();
      }
    }

    
    
}