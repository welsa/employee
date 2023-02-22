/***
* @author      Telesio Consultant
* @date        07/02/2022
* @description Test class for b2g_getTimezones
* @group       Account
* @see         B2G
***/
@isTest
public class b2g_getTimezones_TST{
    static user userAdmin;

    static{
        //Insert Admin User
        userAdmin = TestFactory.createUser('adminUser');
        insert userAdmin;
    }

	@isTest 
    static void TestGetTimezones(){
		System.runAs(userAdmin){
            System.debug('TestGetTimezones START');
            Test.startTest();
			List<String> timezones = b2g_getTimezones.getTimezones();
            System.debug('timezones: ' + timezones);
            Test.stopTest();
            System.debug('TestGetTimezones END');
		}
    }
}