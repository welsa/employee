@isTest
private class ASPISUpdatePOOrderLines_TEST
/*
----------------------------------------------------------------------
-- - Name          : ASPISUpdatePOOrderLines_TEST
-- - Author        : AMI
-- - Description   : Test class for ASPISUpdatePOOrderLines
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 23-NOV-2017  AMI   1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
{
	static User adminUser;
    static List<Account> bodyshopList;
    static List<Account> distributorList;
    static List<Assessment__c> assessmentList;
    static List<CrossReference__c> crossReferenceList;
    static list<PartList__c> partLists;
    static List<PrerequisiteOrder__c> salesOrderList;
    static list <PurchaseOrder__c> purchaseOrderList;
    static list<OrderLine__c> listOrderLines;
    static Id newAssessmentRecordTypeId;
    static Id recordTypeIdMaterial;
    static string POName = '';

    static{
    	adminUser = TestFactory.createUser('adminUser');

    	System.runAs(adminUser){
    		//initialise new assessment recordtypec (R3)
    		newAssessmentRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

    		//initialise material recordtype
    		recordTypeIdMaterial = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
    		
    		//creating bodyshop
    		bodyshopList = new list <Account>{
    			TestFactory.createAccountBodyshop('BodyShop_1', 'FR')};

			bodyshopList[0].Name = 'BodyShop_1';

			insert bodyshopList;

			//creating distributor
    		distributorList = new list <Account>{
    			TestFactory.createAccountDistributor('Distributor_1', 'FR')};

			distributorList[0].Name = 'Distributor_1';
			distributorList[0].Categories__c = 'A;B';

			insert distributorList;

			//creating assessment
    		assessmentList = new list <Assessment__c>{
    			TestFactory.createAssessment('Assessment_1', bodyshopList[0])};

			assessmentList[0].RecordTypeId = newAssessmentRecordTypeId;
			assessmentList[0].Manufacturer__c = 'VW';
			assessmentList[0].PlateNumber2__c = '23NVMR17';
			assessmentList[0].VinNumber__c = 'V23NVMR17';
            assessmentList[0].ModelV2__c = 'Passat';
            assessmentList[0].ClaimReference__c = 'ClaimRefAss1';

			insert assessmentList;

			//creating crossref
			crossReferenceList = new list <CrossReference__c>{
				TestFactory.createCrossReference('fr','76TYGD9t11dcJv','VW',50.8,true)};

			crossReferenceList[0].IAMPartNumber__c ='3434hcv';
            crossReferenceList[0].IAMManufacturer__c ='Axa manufacturer';

            insert crossReferenceList;
															
			//creating partlist
    		partLists = new list <PartList__c>{
    			TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])};

			partLists[0].TECH_OriginalPart__c = 'Ass1Part1';
			partLists[0].ProducerName__c = 'VW';
			partLists[0].Quantity__c = 15;
			partLists[0].RecordtypeId = recordTypeIdMaterial;
			partLists[0].PartNumber__c = '76TYGD90anJWXs';

			partLists[1].TECH_OriginalPart__c = 'Ass1Part2';
			partLists[1].ProducerName__c = 'VW';
			partLists[1].Quantity__c = 15;
			partLists[1].RecordtypeId = recordTypeIdMaterial;
			partLists[1].PartNumber__c = '76TYGD9011dcJv';

			partLists[2].TECH_OriginalPart__c = 'Ass1Part3';
			partLists[2].ProducerName__c = 'VW';
			partLists[2].CrossReferenceId__c = crossReferenceList[0].Id;
			partLists[2].Quantity__c = 15;
			partLists[2].RecordtypeId = recordTypeIdMaterial;
			partLists[2].PartNumber__c = '76TYGD9t11dcJv';

			insert partLists; 

			//creating SO
			salesOrderList = new list <PrerequisiteOrder__c>{
				TestFactory.createSalesOrder(assessmentList[0], bodyshopList[0], '')};
			
			salesOrderList[0].BodyShopOrderNumber__c = '1234';
			salesOrderList[0].Status__c = 'PREACCEPTANCE';

			insert salesOrderList; 
		 
		 	//creating PO
		 	purchaseOrderList = new list <PurchaseOrder__c>{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], bodyshopList[0], distributorList[0], '')};

			purchaseOrderList[0].Status__c = 'DRAFTQUOTE';
			purchaseOrderList[0].Tech_ExternalId__c = 'TechPOExt';

			insert purchaseOrderList; 

			//fetch PO Name
			POName = [select Name from PurchaseOrder__c where id IN :purchaseOrderList].Name;    

			//creating OL
			listOrderLines = new list <OrderLine__c>{
				TestFactory.createOrderLineFinal(10,purchaseOrderList[0],'INPROCESS'),
				TestFactory.createOrderLineFinal(10,purchaseOrderList[0],'INPROCESS'),
				TestFactory.createOrderLineFinal(10,purchaseOrderList[0],'INPROCESS')
			};

			listOrderLines[0].PartList__c = partLists[0].Id;
			listOrderLines[0].OrderType__c = 'ORIGINAL';
			listOrderLines[0].PartNumber__c = '76TYGD90anJWXs';

			listOrderLines[1].PartList__c = partLists[1].Id;
			listOrderLines[1].OrderType__c = 'ORIGINAL';
			listOrderLines[1].PartNumber__c = '76TYGD9011dcJv';

			listOrderLines[2].PartList__c = partLists[2].Id;
			listOrderLines[2].OrderType__c = 'ORIGINAL';
			listOrderLines[2].PartNumber__c = '3434hcv';

			insert listOrderLines;
    	}//end system.runAs
    }//end static

    @isTest static void testUpdatePOWithALternative(){
        system.debug('## Start testUpdatePOWithALternative');

        system.runAs(adminUser){
            String requestJSONString = '{"PurchaseOrders":[{"ClaimReference":"ClaimRefAss1","OrderReference":"'+ POName +'","BodyShopOrderReference":"123/PO-216645","DistributorOrderReference":"C47599","Status":"INDELIVERY","Lines":[{"ID":"' + listOrderLines[0].Id + '","PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","Quantity":15,"CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Bundle":false,"Status":"CONFIRMED","StatusMessage":"","Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ listOrderLines[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ listOrderLines[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}]}]}';

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.requestURI = '/v2.0/updatePurchaseOrder/*';
            request.requestBody = Blob.valueOf(requestJSONString);

            RestContext.request = request;
            RestContext.response = new RestResponse();

            Test.startTest();
                ASPISUpdatePOOrderLines.execute();
            Test.stopTest();

        }//end system.runAs 

        system.debug('## End testUpdatePOWithALternative');
    }

    @isTest static void testUpdatePOWithBundles(){
        system.debug('## Start testUpdatePOWithBundles');

        system.runAs(adminUser){
            String requestJSONString = '{"PurchaseOrders":[{"ClaimReference":"ClaimRefAss1","OrderReference":"'+ POName +'","BodyShopOrderReference":"123/PO-216645","DistributorOrderReference":"C47599","Status":"INDELIVERY","Lines":[{"ID":"' + listOrderLines[0].Id + '","PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","Quantity":15,"CatalogPrice":0,"AlphaScaleDiscount":0,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":0,"Bundle":true,"Status":"CONFIRMED","StatusMessage":"","Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":204.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""},{"Quantity":15,"PartNumber":"76TZ","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ listOrderLines[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ listOrderLines[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}]}]}';

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.requestURI = '/v2.0/updatePurchaseOrder/*';
            request.requestBody = Blob.valueOf(requestJSONString);

            RestContext.request = request;
            RestContext.response = new RestResponse();

            Test.startTest();
                ASPISUpdatePOOrderLines.execute();
            Test.stopTest();

        }//end system.runAs

        system.debug('## End testUpdatePOWithBundles');
    }
}