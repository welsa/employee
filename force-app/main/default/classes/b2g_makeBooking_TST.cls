/***
* @author      Telesio Consultant
* @date        07/02/2022
* @description Test class for b2g_makeBooking
* @group       Account
* @see         B2G
***/
@isTest
public class b2g_makeBooking_TST{
    static user userAdmin;

    static{
        //Insert Admin User
        userAdmin = TestFactory.createUser('adminUser');
        insert userAdmin;

        //Insert WsCredential custom settings
        insert new PFR_WsCredential__c(
            name = 'b2g',
            NOB_ClientId__c = 'test',
            NOB_ClientSecret__c = 'test',
            NOB_Endpoint__c = 'https://www.google.com/'
        );
    }

    @isTest 
    static void TestMakeBooking_SAD(){
        System.runAs(userAdmin){
            System.debug('TestMakeBooking_SAD START');

            //HTTP Mock
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            //Create ObjectContext for Invocable Action
            b2g_makeBooking.ObjectContext obj = new b2g_makeBooking.ObjectContext();
            obj.brandCode = '000xxx22';
            obj.workshopBrand = 'MPB';
            obj.slotId = 'xxx';
            obj.isMobileService = true;
            obj.postalCode = '7115';
            obj.city = 'Paris';
            obj.address = '123, Rue du test, Paris, France';
            obj.recommendedOperationType = 'R';
            obj.isadas = false;
            obj.selectedCarParts = getCarparts();
            obj.type = 'I';
            obj.isInViewField = false;
            obj.isInEdge = false;
            obj.NumOfImpacts = '3';
            obj.vrn = '999BB88';
            obj.insuranceName = 'AXA';
            obj.insuranceCode = 'XXX';
            obj.policyNumber = 'XXX';
            obj.folderRef='XXX';
            obj.lastname = 'XXX';
            obj.firstname = 'XXX';
            obj.email = 'AA@test.com';
            obj.phoneNumber = '123';

            Test.startTest();
            List<b2g_makeBooking.Result> results = b2g_makeBooking.bookAppointment(new List<b2g_makeBooking.ObjectContext>{obj});
            System.debug('results: ' + results);
            System.assert(results != null);
            Test.stopTest();
            System.debug('TestMakeBooking_SAD END');
        }
    }

    @isTest 
    static void TestMakeBooking_Site(){
        System.runAs(userAdmin){
            System.debug('TestMakeBooking_Site START');

            //HTTP Mock
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            //Create ObjectContext for Invocable Action
            b2g_makeBooking.ObjectContext obj = new b2g_makeBooking.ObjectContext();
            obj.brandCode = '000xxx22';
            obj.workshopBrand = 'MPB';
            obj.slotId = 'xxx';
            obj.isMobileService = false;
            obj.recommendedOperationType = 'R';
            obj.isadas = false;
            obj.selectedCarParts = getCarparts();
            obj.type = 'I';
            obj.isInViewField = false;
            obj.isInEdge = false;
            obj.NumOfImpacts = '3';
            obj.vrn = '999BB88';
            obj.insuranceName = 'AXA';
            obj.insuranceCode = 'XXX';
            obj.policyNumber = 'XXX';
            obj.folderRef='XXX';
            obj.lastname = 'XXX';
            obj.firstname = 'XXX';
            obj.email = 'AA@test.com';
            obj.phoneNumber = '123';

            Test.startTest();
            List<b2g_makeBooking.Result> results = b2g_makeBooking.bookAppointment(new List<b2g_makeBooking.ObjectContext>{obj});
            System.debug('results: ' + results);
            System.assert(results != null);
            Test.stopTest();
            System.debug('TestMakeBooking_Site END');
        }
    }

    public static List<b2g_CarParts__mdt> getCarparts(){
        b2g_CarParts__mdt carpart = new b2g_CarParts__mdt();
        carpart.DeveloperName = 'Sidewindow';
        carpart.code__c = 'SW';
        return new List<b2g_CarParts__mdt>{carpart};
    }
}