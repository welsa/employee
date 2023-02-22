/*************************************************************************************
Class Name - AP39AgencyMode_TEST
Version - 1.0
Created Date - 19 JAN 2018
Function - TestClass for AP39AgencyMode

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date          Description
* ----------    ----------    -----------------------
* Dourga U      19/01/2018    Original Version
* Neha P 		22/04/2022	  Increase Coverage
*************************************************************************************/
@isTest
private class AP39AgencyMode_TEST{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<Offer__c> offerList;
	static BusinessHours defaultHours;
	static set<id> setIdpo; //NPE 22/04/2022


	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			// access Business Hours
			defaultHours = [SELECT 	Id 
							FROM 	BusinessHours 
							WHERE 	IsDefault = true];

			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
				TestFactory.createAccountDistributor('Distributor_FR', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
				TestFactory.createAccountDistributor('Distributor_ES', 'ES')
			};

			accountList[2].ContactUser__c = adminUser.Id;

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			assessmentList[2].EntityRules__c 			= 'FR299';
			assessmentList[2].EntityCode__c 			= '299';
			assessmentList[3].EntityRules__c 			= 'FR299';
			assessmentList[3].EntityCode__c 			= '299';
			assessmentList[4].EntityRules__c 			= 'FR299';
			assessmentList[4].EntityCode__c 			= '299';
			assessmentList[5].EntityRules__c 			= 'ES299';
			assessmentList[5].EntityCode__c 			= '299';
			assessmentList[5].TECH_EntityCountryCode__c = 'ES';

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[2], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[3], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[4], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[5], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[2], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[3], salesOrderList[3], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[4], salesOrderList[4], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;

			//NPE 22/04/2022 Increase coverage
			if (purchaseOrderList != null){
				setIdpo = new set<id>();
				for(PurchaseOrder__c po:purchaseOrderList ){
					
					setIdpo.add(po.id);
				}
			}


			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(10, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(10, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

			orderLineList[2].OrderType__c = 'ORIGINAL';
			orderLineList[3].OrderType__c = 'FINAL';

			insert orderLineList;

			orderLineList[3].OriginalItem__c = orderLineList[2].Id;

			update orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[3], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[3], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[4], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[5], ASPISConstants.OFFER_STATUS_INPROCESS)
			};

			offerList[0].ExpectedDeliveryDate__c 	= System.today();
			offerList[0].Accepted__c 				= 'YES';
			offerList[0].DeliveryStatus__c 			= ASPISConstants.OFFER_STATUS_DELIVERED;
			offerList[1].ExpectedDeliveryDate__c 	= System.today();
			offerList[2].ExpectedDeliveryDate__c 	= System.today();
			offerList[3].ExpectedDeliveryDate__c 	= System.today();
			offerList[3].Accepted__c 				= 'YES';
			offerList[3].DeliveryStatus__c 			= ASPISConstants.OFFER_STATUS_DELIVERED;
			offerList[4].ExpectedDeliveryDate__c 	= System.today();
			offerList[4].Accepted__c				= null;
			offerList[5].ExpectedDeliveryDate__c 	= System.today();
			offerList[5].Accepted__c 				= 'YES';
			offerList[5].DeliveryStatus__c 			= ASPISConstants.OFFER_STATUS_DELIVERED;

			insert offerList;
		}
	}

    static testMethod void testClosedPODEAgencyModeCLOSEDKO() {    
		system.debug('## Start testClosedPODEAgencyModeCLOSEDKO');
       	system.runas(adminUser){
       		purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            purchaseOrderList[0].AgencyMode__c = true;
            
            test.startTest();
                update purchaseOrderList[0];
            test.stopTest();

            system.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, [select Id , Status__c from PurchaseOrder__c where id =: purchaseOrderList[0].Id].Status__c);
            system.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, [select Id , Status__c from PrerequisiteOrder__c where id =: salesOrderList[0].Id].Status__c);
        }		
        system.debug('## End testClosedPODEAgencyModeCLOSEDKO');
    }

    static testMethod void testClosedPODEAgencyModeCLOSEDOK() {    
		system.debug('## Start testClosedPODEAgencyModeCLOSEDOK');
       	system.runas(adminUser){

			orderLineList[0].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
			orderLineList[0].Suppliable__c = 'YES';
			orderLineList[0].AcceptedCheck__c = true;
			update orderLineList[0];

       		purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
       		update purchaseOrderList[0];

       		purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            purchaseOrderList[0].AgencyMode__c = true;
            
            test.startTest();
                update purchaseOrderList[0];
            test.stopTest();

            system.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, [select Id , Status__c from PurchaseOrder__c where id =: purchaseOrderList[0].Id].Status__c);
            system.assertEquals(ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED, [select Id , Status__c from PrerequisiteOrder__c where id =: salesOrderList[0].Id].Status__c);
        }		
        system.debug('## End testClosedPODEAgencyModeCLOSEDOK');
    }

	static testmethod void testclosedPOAgencyModeWithAllOLReturned(){
		system.runas(adminUser){
			if (setIdpo!= null){
				AP39AgencyMode.closedPOAgencyModeWithAllOLReturned(setIdPO);
			}
		}
	}

    static testMethod void testClosedSODEAgencyMode() {    
		system.debug('## Start testClosedPODEAgencyModeCLOSEDOK');
       	system.runas(adminUser){

			orderLineList[0].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
			orderLineList[0].Suppliable__c = 'YES';
			orderLineList[0].AcceptedCheck__c = true;
			update orderLineList[0];

       		offerList[0].Suppliable__c = true;
       		update offerList[0];

            purchaseOrderList[0].AgencyMode__c = true;
       		update purchaseOrderList[0];

       		salesOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            
            test.startTest();
                update salesOrderList[0];
            test.stopTest();

            system.assertEquals(ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED, [select Id , Status__c from PrerequisiteOrder__c where id =: salesOrderList[0].Id].Status__c);
        }		
        system.debug('## End testClosedPODEAgencyModeCLOSEDOK');
    }
}