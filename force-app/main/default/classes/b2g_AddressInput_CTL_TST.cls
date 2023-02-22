/***
* @author      Telesio Consultant
* @date        08/02/2022 
* @description Test class for b2g_AddressInput_CTL 
* @group       B2G 
* @see         
***/
@isTest
public with sharing class b2g_AddressInput_CTL_TST {
    static user userAdmin;

    static{
        userAdmin = TestFactory.createUser('adminUser');
        insert userAdmin;
    }

	@isTest 
    static void TestGetSuggestions(){
		System.runAs(userAdmin){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
            try{ 
                Test.startTest();
                String resp = b2g_AddressInput_CTL.getSuggestions('test', 'test', 'test', 'test');
                Test.stopTest(); 
            }
            catch (System.UnexpectedException theException){
            }  
		}
	}

    @isTest 
    static void TestGetPlaceDetails(){
		System.runAs(userAdmin){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
            try{ 
                Test.startTest();
                String resp = b2g_AddressInput_CTL.getPlaceDetails('test', 'test', 'test');
                Test.stopTest(); 
            }
            catch (System.UnexpectedException theException){
            }  
		}
	}
}