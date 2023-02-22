/***
* @author      Telesio Consultant
* @date        11/02/202
* @description Test class for b2g_DeleteLogs_QUE
* @group       B2G 
* @see         
***/
@isTest
public with sharing class b2g_DeleteLogs_QUE_TST {
    static user userAdmin;

    static{
        //Insert Admin User
        userAdmin = TestFactory.createUser('adminUser');
        insert userAdmin;
    }

    @isTest 
    static void TestDeleteLogs(){
        System.runAs(userAdmin){
            System.debug('TestDeleteLogs START');

            //Insert 2000+ bookings object
            List<b2g_Booking__c> bookings = new List<b2g_Booking__c>();
            for(integer i =0; i<2500; i++){
                bookings.add(new b2g_Booking__c(b2g_Email__c ='test@test.com'));
            }
            insert bookings;

            for(integer i =0; i<bookings.size(); i++){
                Test.setCreatedDate(bookings[i].Id, Datetime.now().addDays(-31)); 
            }
            
            Test.startTest();
            System.enqueueJob(new b2g_DeleteLogs_QUE());
            Test.stopTest();
            System.debug('TestDeleteLogs END');
        }
    }



    @isTest 
    static void TestDeleteLogs_Schedulable(){
        System.runAs(userAdmin){
            System.debug('TestDeleteLogs START');

            //Insert 2000+ bookings object
            List<b2g_Booking__c> bookings = new List<b2g_Booking__c>();
            for(integer i =0; i<2500; i++){
                bookings.add(new b2g_Booking__c());
            }
            insert bookings;

            for(integer i =0; i<bookings.size(); i++){
                Test.setCreatedDate(bookings[i].Id, Datetime.now().addDays(-31)); 
            }
            
            Test.startTest();
                SchedulableContext sc = null;
                b2g_ScheduleDeleteLogs tsc = new b2g_ScheduleDeleteLogs();
                tsc.execute(sc);            
            Test.stopTest();
            System.debug('TestDeleteLogs END');
        }
    }
}