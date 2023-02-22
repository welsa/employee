/***
* @author      Telesio Consultant
* @date        07/02/2022
* @description Test class for b2g_getAvailableSlots
* @group       Account
* @see         B2G
***/
@isTest
public class b2g_getAvailableSlots_TST{
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
    static void TestGetAvailSlotsActions_SAD(){
		System.runAs(userAdmin){
            System.debug('TestGetAvailSlotsActions START');

            //HTTP Mock
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            //Create ObjectContext for Invocable Action
            b2g_getAvailableSlots.ObjectContext obj = new b2g_getAvailableSlots.ObjectContext();
            obj.brandCode = 'MPB';
            obj.isMobileService = true;
            obj.postalCode = '7115';
            obj.city = 'Paris';
            obj.address = '123, Rue du test, Paris, France';
            obj.partnerBranchId = 'xxx0011';
            obj.recommendedOperationType = 'R';
            obj.isadas = false;
            obj.share = 1;
            obj.selectedCarParts = getCarparts();
            obj.type = 'I';
            obj.size = 'B';
            obj.isInViewField = false;
            obj.isInEdge = false;
            obj.NumOfImpacts = '3';

            Test.startTest();
			List<b2g_getAvailableSlots.Result> results = b2g_getAvailableSlots.getAvailSlotsActions(new List<b2g_getAvailableSlots.ObjectContext>{obj});
            System.assert(results != null);
            System.debug('results: ' + results);
            Test.stopTest();
            System.debug('TestGetAvailSlotsActions END');
		}
    }

    @isTest 
    static void TestGetAvailSlotsActions_Site(){
        System.runAs(userAdmin){
            System.debug('TestGetAvailSlotsActions START');

            //HTTP Mock
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            //Create ObjectContext for Invocable Action
            b2g_getAvailableSlots.ObjectContext obj = new b2g_getAvailableSlots.ObjectContext();
            obj.brandCode = 'MPB';
            obj.isMobileService = false;
            obj.partnerBranchId = 'xxx0011';
            obj.recommendedOperationType = 'R';
            obj.isadas = false;
            obj.share = 1;
            obj.selectedCarParts = getCarparts();
            obj.type = 'I';
            obj.size = 'B';
            obj.isInViewField = false;
            obj.isInEdge = false;
            obj.NumOfImpacts = '3';

            Test.startTest();
            List<b2g_getAvailableSlots.Result> results = b2g_getAvailableSlots.getAvailSlotsActions(new List<b2g_getAvailableSlots.ObjectContext>{obj});
            System.assert(results != null);
            System.debug('results: ' + results);
            Test.stopTest();
            System.debug('TestGetAvailSlotsActions END');
        }
    }

    public static List<b2g_CarParts__mdt> getCarparts(){
        b2g_CarParts__mdt carpart = new b2g_CarParts__mdt();
        carpart.DeveloperName = 'Sidewindow';
        carpart.code__c = 'SW';
        return new List<b2g_CarParts__mdt>{carpart};
    }
}