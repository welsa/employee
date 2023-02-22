@isTest
public with sharing class PRE_SchedulablePrefikarMonitoringTEST {
    static User userAdmin;

    static {
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

        }
    }
    @isTest
    public static void PrefikarMonitoringEqualTEST(){
        System.runAs(userAdmin){
            Test.startTest();
            PRE_SchedulablePrefikarMonitoring s = new PRE_SchedulablePrefikarMonitoring('TESTCLASS_Equal_SD32_SD40_Outbound_Sent');
            s.execute(null);
            Test.stopTest();

            // System.assertEquals(,);
        }
    }
    @isTest
    public static void PrefikarMonitoringLessOrEqualTEST(){
        System.runAs(userAdmin){
            Test.startTest();
            PRE_SchedulablePrefikarMonitoring s = new PRE_SchedulablePrefikarMonitoring('TESTCLASS_LessOrEqual_SD32_SD40');
            s.execute(null);
            Test.stopTest();

            // System.assertEquals(,);
        }
    }
    @isTest
    public static void PrefikarMonitoringGreaterOrEqualTEST(){
        System.runAs(userAdmin){
            Test.startTest();
            PRE_SchedulablePrefikarMonitoring s = new PRE_SchedulablePrefikarMonitoring('TESTCLASS_GreaterOrEqual_SD32_SD40');
            s.execute(null);
            Test.stopTest();

            // System.assertEquals(,);
        }
    }
}