/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 09-18-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   09-18-2020   GBH   Initial Version
**/
@isTest
public with sharing class AP40CallDistributorQueueable_TEST {
    static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    
    static map <string,object> mapinputParameters = new map<String,Object>();

    static {
        adminUser = TestFactory.createUser('adminUser');

        insert adminUser;

        System.runAs(adminUser)
        {
            accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
				TestFactory.createAccountDistributor('Distributor_FR', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0])
			};

			assessmentList[0].EntityRules__c	= 'FR299';
			assessmentList[0].EntityCode__c		= '299';

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

            insert orderLineList;
            
        }

    }

    @isTest
    public static void AP40CallDistributorQueueable(){
        System.runAs(adminUser){
            Test.startTest();
            AP40CallDistributorQueueable DQ = new AP40CallDistributorQueueable('', new Set<Id>{purchaseOrderList[0].id}, new set<Id>{orderLineList[0].id});
            System.enqueueJob(DQ);
            Test.stopTest();
        }
    }

    @isTest
    public static void AP40CallDistributorQueueableMap(){
        System.runAs(adminUser){
            
            mapinputParameters.put('finalOrderReq', '');
            mapinputParameters.put('setPOToUpdate', new Set<Id>{purchaseOrderList[0].id});
            mapinputParameters.put('sentOlIdSet', new set<Id>{orderLineList[0].id});  

            Test.startTest();
            AP40CallDistributorQueueable DQ = new AP40CallDistributorQueueable(mapinputParameters);
            System.enqueueJob(DQ);
            Test.stopTest();
        }
    }
}