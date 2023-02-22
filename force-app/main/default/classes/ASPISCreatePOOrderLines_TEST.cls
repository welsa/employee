/**
 * @description       : Test class for ASPISCreatePOOrderLines
 * @author            : GBH
 * @group             : 
 * @last modified on  : 09-18-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   09-18-2020   GBH   Initial Version
**/
@isTest
public with sharing class ASPISCreatePOOrderLines_TEST {
    static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static list <PartList__c> partLists;

    static {
        adminUser = TestFactory.createUser('adminUser');
        insert adminUser;

        System.runAs(adminUser){
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
			
			partLists = new list <PartList__c>{
				TestFactory.createPartList(assessmentList[0])
			};
               

			partLists[0].TECH_OriginalPart__c = 'Ass1Part1';
			partLists[0].ProducerName__c = 'VW';
			partLists[0].Quantity__c = 15;
			partLists[0].RecordtypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
			partLists[0].PartNumber__c = '76TYGD90anJWXs';
			partLists[0].TechCheckForSubstitute__c = true;
			insert partlists;
        }
    }

    @isTest
    public static void testCalculateEstimationDurationConfirmed(){
        System.runAs(adminUser){
            Test.startTest();
			Map<String,String> TypeDelayMap = ASPISCreatePOOrderLines.getTypeDelayMap('A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48');
			String resultDuration = ASPISCreatePOOrderLines.calculateEstimationDuration('A', 'CONFIRMED', TypeDelayMap);
            Test.stopTest();

			System.assertEquals('1', resultDuration);
        }
	}
	@isTest
    public static void testCalculateEstimationDurationCONFIRMEDWITHDELAY(){
        System.runAs(adminUser){
            Test.startTest();
			Map<String,String> TypeDelayMap = ASPISCreatePOOrderLines.getTypeDelayMap('A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72');
			String resultDuration = ASPISCreatePOOrderLines.calculateEstimationDuration('A', 'CONFIRMEDWITHDELAY', TypeDelayMap);
            Test.stopTest();
			System.debug('resultDuration delay' + resultDuration);
			//System.assertEquals(1, resultDuration);
        }
	}
	@isTest
    public static void testCalculateEstimationDurationPARTIAL(){
        System.runAs(adminUser){
            Test.startTest();
			Map<String,String> TypeDelayMap = ASPISCreatePOOrderLines.getTypeDelayMap('A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72');
			String resultDuration = ASPISCreatePOOrderLines.calculateEstimationDuration('A', 'PARTIAL', TypeDelayMap);
            Test.stopTest();
			System.debug('resultDuration partial' + resultDuration);
			//System.assertEquals(1, resultDuration);
        }
	}
	@isTest
    public static void testCalculateTotalPrice(){
        System.runAs(adminUser){
            Test.startTest();
			Double totalPrice = ASPISCreatePOOrderLines.calculateTotalPrice(orderLineList[0]);
            Test.stopTest();
			// System.debug('## totalPrice ##' + totalPrice);
			System.assertEquals(1000, totalPrice);
        }
	}
	@isTest
    public static void testCalculateAXATotalPrice(){
        System.runAs(adminUser){
            Test.startTest();
			Double axaTotalPrice = ASPISCreatePOOrderLines.calculateAXATotalPrice(orderLineList[0]);
            Test.stopTest();
			// System.debug('## axaTotalPrice ##' + axaTotalPrice);
			System.assertEquals(800, axaTotalPrice);
        }
	}
	@isTest
    public static void testCalculateBodyShopTotalPrice(){
        System.runAs(adminUser){
            Test.startTest();
			Double bodyShopTotalPrice = ASPISCreatePOOrderLines.calculateBodyShopTotalPrice(orderLineList[0]);
            Test.stopTest();
			// System.debug('## bodyShopTotalPrice ##' + bodyShopTotalPrice);
			System.assertEquals(900, bodyShopTotalPrice);
        }
	}
	@isTest
    public static void testUpdateFinalOL(){
        System.runAs(adminUser){
            Test.startTest();
			OrderLine__c finalOrderLine = ASPISCreatePOOrderLines.updateFinalOL('',orderLineList[0], 1000,800,900,20,'','');
            Test.stopTest();
			System.debug('## finalOrderLine ##' + finalOrderLine);
			// System.assertEquals(900, bodyShopTotalPrice);
        }
	}

	@isTest
    public static void testprocessErrorPartOLUpdate(){
        System.runAs(adminUser){
			Test.startTest();
			// RestDistributorUtility.Lines ln = new RestDistributorUtility.Lines ( 1.0,'12345', '1234', 'Final', 'Audi', 'test' , 12.0, 2.0, 2.0, 3.0, 4.0, 'Ok', 'OK', false, new List<RestDistributorUtility.Parts>() , new List<RestDistributorUtility.Alternatives>());
			
			// OrderLine__c finalOrderLine = ASPISCreatePOOrderLines.processErrorPartOL(true, ,ln,'test',purchaseOrderList[0].Id, map<String,String> {'A' => '01'} );
            Test.stopTest();
			// System.debug('## finalOrderLine ##' + finalOrderLine);
			// System.assertEquals(900, bodyShopTotalPrice);
        }
	}
	
	// @isTest
    // public static void testProcessErrorPartOL(){
    //     System.runAs(adminUser){
	// 		// map <string,RestDistributorUtility.dist> deserialiseDist;
	// 		// deserialiseDist  = RestDistributorUtility.deserialiseRespIntoDistributors('[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}]');
	// 		List<RestDistributorUtility.Lines> lstLines =  (List<RestDistributorUtility.Lines>)JSON.deserializeUntyped('[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]}]');

	// 		System.debug('## lstLines ##' + lstLines);
	// 		Map<String,String> mapTypeDelay = ASPISCreatePOOrderLines.getTypeDelayMap('A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48');

	// 		Test.startTest();
			
	// 		// OrderLine__c newOL = ASPISCreatePOOrderLines.ProcessErrorPartOL(true, 
	// 		// 																	new RestDistributorUtility.Lines(PartNumber='xxxx', Type= 'A', DeliveryDays = 1), 
	// 		// 																	'',
	// 		// 																	purchaseOrderList[0].id,
	// 		// 																	mapTypeDelay);
    //         Test.stopTest();
	// 		// System.debug('## newOL ##' + newOL);
			
	// 		// System.assertEquals(900, bodyShopTotalPrice);
    //     }
	// }
	// @isTest
	// public static void testCreateOrderlineGeneric(){
	// 	System.runAs(adminUser){
	// 		map <Id,PartList__c> partMap = new map <Id,PartList__c>{
	// 			partLists[0].id => partLists[0]};
	

	// 		map<String, Object> mapInputParams = new map <String,Object> ();
			
	// 		//mapInputParams.put('OL',orderLineList[0]);
	// 		mapInputParams.put('POId',purchaseOrderList[0].Id);
	// 		mapInputParams.put('POKey',purchaseOrderList[0].Name);

	// 		Map<String,String> mapTypeDelay = ASPISCreatePOOrderLines.getTypeDelayMap('A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48');

	// 		mapInputParams.put('mapTypeDelay',mapTypeDelay);
	// 		mapInputParams.put('partMap', partMap);
	// 		mapInputParams.put('isUpdate',false);
	// 		//mapInputParams.put('POStatus',POStatus);
	// 		//mapInputParams.put('originalIdTechIdMap',originalIdTechIdMap);
	// 		//mapInputParams.put('mapPartlistOL',mapPartlistOL);
	// 		mapInputParams.put('isReplacament',true);
	// 		mapInputParams.put('originalTechExtId',(purchaseOrderList[0].Name)
	// 		+ '-' + orderLineList[0].ID);
	// 		mapInputParams.put('alternativeExtId',(purchaseOrderList[0].Name)
	// 		+ '-' + orderLineList[0].ID);
	// 		// mapInputParams.put('setAddPartToNotSuppliable',setAddPartToNotSuppliable);
	// 		// mapInputParams.put('allIdTechIdMap',allIdTechIdMap);
	// 		// mapInputParams.put('OrderRequest',OrderRequest);                             
	// 		// mapInputParams.put('isRepManual',isRepManual);                             
	// 		// mapInputParams.put('RebateReceived',rebate);      

	// 		OrderLine__c alterna = ASPISCreatePOOrderLines.createOrderlineGeneric(mapInputParams);
	// 	}
	// }
}