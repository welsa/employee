/*************************************************************************************
Class Name - ASPISServiceOrderDeliveryConfirmed_TEST
Version - 29 JUNE 2016
Function - TestClass for ASPISServiceOrderDeliveryConfirmed

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga        29/06/2016  Reworked Version
*************************************************************************************/
@isTest
public class ASPISServiceOrderDeliveryConfirmed_TEST {
	static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static BusinessHours defaultHours;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;
    
    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        countryCodeInfos = new list <CountryCodeInformationsMapping__c>();
        
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            countryCodeInfos.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);    
            countryCodeInfos.add(countryCode2);

            insert countryCodeInfos;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            bs1.ReferenceNumber__c = 'FR9124912421';//WCH 23/12/2020 C-004120
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ReferenceNumber__c = 'FR9123912391';//WCH 23/12/2020 C-004120
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            l_Accounts.add(dist1);
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            l_Accounts.add(dist2);
            insert l_Accounts;

            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            ass1.EntityCode__c = '241';
            l_Assessments.add(ass1);  

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            ass2.AssessmentID__c = '0913';
            ass2.EntityCode__c = '297';
            l_Assessments.add(ass2);            
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, '');
            so1.Status__c = 'INACCEPTANCE';
            l_SalesOrders.add(so1);

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, '');
            so2.Status__c = 'INACCEPTANCE';
            l_SalesOrders.add(so2);            
            insert l_SalesOrders;

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_1);

            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so2, bs2, dist2, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_2);

            PurchaseOrder__c po1_3 = TestFactory.createPurchaseOrder(ass1, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_3);

            PurchaseOrder__c po1_4 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
            l_purchaseOrders.add(po1_4);
            insert l_purchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVERED');
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'DELIVERED');
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
            insert l_OrderLines;

        }
    }

	static testMethod void testAllDelivered(){
		system.runas(l_users[0]){
			test.startTest();
				ASPISServiceOrderDeliveryConfirmed.executeServiceOrderDeliveryConfirmed(new set<Id>{l_SalesOrders[0].Id,l_SalesOrders[1].Id});
			test.stoptest();
		}

		list <PrerequisiteOrder__c> listSO = [select Id, Status__c from PrerequisiteOrder__c where id in: l_SalesOrders order by id asc];
		system.assertNotEquals('RESPONDED',listSO[1].Status__c);
		system.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO,listSO[0].Status__c);

	}
}