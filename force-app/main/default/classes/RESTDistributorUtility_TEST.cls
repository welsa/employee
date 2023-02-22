@isTest
/*
----------------------------------------------------------------------
-- - Name          : RESTDistributorUtility_TEST
-- - Author        : AMI
-- - Description   : Test class for RESTDistributorUtility
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-NOV-2017  AMI   1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
private class RESTDistributorUtility_TEST{ 
    static User adminUser;
    static List<Account> bodyshopList;
    static List<Account> distributorList;
    static List<Assessment__c> assessmentList;
    static List<CrossReference__c> crossReferenceList;
    static list<PartList__c> partLists;
    static map<Id,PartList__c> partMap;
    static Id newAssessmentRecordTypeId;
    static Id recordTypeIdMaterial;
    static BusinessHours defaultHours;
    static list<CountryCodeInformationsMapping__c> countryMappingList;


    static List<Account> accountList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;

    static List<Account> lstAccount;
    static List<PurchaseOrder__c> lstPurchaseOrder ;
    static List<Assessment__c> lstAssessment;
    static List<OrderLine__c> lstOrdrLine;
    static List<PrerequisiteOrder__c> lstSalesOrder;
    static List<Offer__c> lstOffer;
    static List<PartList__c> lstPartList;
    static map<String,String> mapOrderConfirmation;
    static  map<String, Object> mapOutParamsCloseAssess;

    static{
        adminUser = TestFactory.createUser('adminUser');

        System.runAs(adminUser){

            // access Business Hours 
            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
            };
            
            countryMappingList[0].Validity_Duration_Purchase_Order__c = 50;
            
            insert countryMappingList;

            //initialise new assessment recordtypec (R3)
            newAssessmentRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            //initialise material recordtype
            recordTypeIdMaterial = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
            
            //creating bodyshop
            bodyshopList = new list <Account>{
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'FR')};

            bodyshopList[0].Name = 'BodyShop_1';
            bodyshopList[1].Name = 'BodyShop_2';

            insert bodyshopList;

            //creating distributor
            distributorList = new list <Account>{
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_2', 'FR')};

            distributorList[0].Name = 'Distributor_1';
            distributorList[0].Type_of_Substitutes__c = 'Connected Substitute';
            distributorList[0].Tech_Distributor__c = 'Distributor_1';
            distributorList[0].Categories__c = 'A;B';
            distributorList[0].PartTypeRegionDelayMatrix__c = 'A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_72';

            distributorList[1].Name = 'Distributor_2';
            distributorList[1].Tech_Distributor__c = 'Distributor_2';
            distributorList[1].Type_of_Substitutes__c = 'Connected Substitute';
            distributorList[1].Categories__c = '';

            insert distributorList;

            //creating assessment
            assessmentList = new list <Assessment__c>{
                TestFactory.createAssessment('Assessment_1', bodyshopList[0]),
                TestFactory.createAssessment('Assessment_2', bodyshopList[1])};

            assessmentList[0].RecordTypeId = newAssessmentRecordTypeId;
            assessmentList[0].Manufacturer__c = 'VW';
            assessmentList[0].PlateNumber2__c = '23NVMR17';
            assessmentList[0].VinNumber__c = 'V23NVMR17';
            assessmentList[0].ModelV2__c = 'Passat';
            assessmentList[0].ClaimReference__c = 'ClaimRefAss1';
            assessmentList[0].InsuranceBroker__c = 'IG';

            assessmentList[1].RecordTypeId = newAssessmentRecordTypeId;
            assessmentList[1].Manufacturer__c = 'AUDI';
            assessmentList[1].PlateNumber2__c = '24NVMR17';
            assessmentList[1].VinNumber__c = 'V24NVMR17';
            assessmentList[1].ModelV2__c = 'A8';
            assessmentList[1].ClaimReference__c = 'ClaimRefAss2';

            insert assessmentList;

            //creating crossref
            crossReferenceList = new list <CrossReference__c>{
                TestFactory.createCrossReference('fr','1234','VW',50.8,true),
                TestFactory.createCrossReference('fr','5678','AUDI',100.8,true)};

            crossReferenceList[0].IAMPartNumber__c ='3434hcv';
            crossReferenceList[0].IAMManufacturer__c ='Axa manufacturer';
            crossReferenceList[1].IAMPartNumber__c ='3434hcv';
            crossReferenceList[1].IAMManufacturer__c ='Axa manufacturer';

            insert crossReferenceList;
                                                            
            //creating partlist
            partLists = new list <PartList__c>{
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),

                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1])};

            partLists[0].TECH_OriginalPart__c = 'Ass1Part1';
            partLists[0].ProducerName__c = 'VW';
            partLists[0].Quantity__c = 15;
            partLists[0].RecordtypeId = recordTypeIdMaterial;
            partLists[0].PartNumber__c = '76TYGD90anJWXs';
            partLists[0].TechCheckForSubstitute__c = true;

            partLists[1].TECH_OriginalPart__c = 'Ass1Part2';
            partLists[1].ProducerName__c = 'VW';
            partLists[1].Quantity__c = 15;
            partLists[1].RecordtypeId = recordTypeIdMaterial;
            partLists[1].TechCheckForSubstitute__c = false;


            partLists[2].TECH_OriginalPart__c = 'Ass1Part3';
            partLists[2].ProducerName__c = 'VW';
            partLists[2].CrossReferenceId__c = crossReferenceList[0].Id;
            partLists[2].Quantity__c = 15;
            partLists[2].RecordtypeId = recordTypeIdMaterial;
            partLists[2].PartNumber__c = '1234';
            partLists[2].TechCheckForSubstitute__c = false;


            partLists[3].TECH_OriginalPart__c = 'Ass2Part1';
            partLists[3].ProducerName__c = 'AUDI';
            partLists[3].Quantity__c = 15;
            partLists[3].RecordtypeId = recordTypeIdMaterial;
            partLists[3].PartNumber__c = '76TYGq9t11dcJv';
            partLists[3].TechCheckForSubstitute__c = false;


            partLists[4].TECH_OriginalPart__c = 'Ass2Part2';
            partLists[4].ProducerName__c = 'AUDI';
            partLists[4].Quantity__c = 15;
            partLists[4].RecordtypeId = recordTypeIdMaterial;
            partLists[4].PartNumber__c = '75TYGD9t11dcJv';

            partLists[5].TECH_OriginalPart__c = 'Ass2Part3';
            partLists[5].ProducerName__c = 'AUDI';
            partLists[5].CrossReferenceId__c = crossReferenceList[1].Id;
            partLists[5].Quantity__c = 15;
            partLists[5].RecordtypeId = recordTypeIdMaterial;
            partLists[5].PartNumber__c = '5678';

            insert partLists; 

            lstAccount= new List<Account>
            {
                TestFactory.createAccountBodyshop('BS_1', 'DE'),
                TestFactory.createAccountDistributor('Distributor_1', 'DE'),
                
                TestFactory.createAccountBodyshop('BS_2', 'DE'),
                TestFactory.createAccountDistributor('Distributor_2', 'DE'),

                TestFactory.createAccountBodyshop('BS_3', 'DE'),
                TestFactory.createAccountDistributor('Distributor_3', 'DE'),
                
                TestFactory.createAccountBodyshop('BS_4', 'DE'),
				TestFactory.createAccountDistributor('Distributor_4', 'DE')

				
            };
            

            insert lstAccount;

            // recordType
			Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id newAssessmentRecordTypeId	= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();	

            //Creating Assessment

            lstAssessment =new List<Assessment__c> 

            {
                TestFactory.createAssessment('Assessment_DE01', lstAccount[0]),
                TestFactory.createAssessment('Assessment_DE02', lstAccount[2]),
                TestFactory.createAssessment('Assessment_DE03', lstAccount[4]),
                TestFactory.createAssessment('Assessment_DE04', lstAccount[6])
                
            
            };

            //countrycode
            lstAssessment[0].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[1].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[2].TECH_EntityCountryCode__c = 'DE';
            lstAssessment[3].TECH_EntityCountryCode__c = 'DE';

            //entitycode

            lstAssessment[0].EntityCode__c ='IG';
            lstAssessment[1].EntityCode__c ='IG';
            lstAssessment[2].EntityCode__c ='5515';
            lstAssessment[3].EntityCode__c ='IG';

            //entityrules

            lstAssessment[0].EntityRules__c='DEIG';
            lstAssessment[1].EntityRules__c='DEIG';
            lstAssessment[2].EntityRules__c='DE5515';
            lstAssessment[3].EntityRules__c='DEIG';

            //orderorigin

            lstAssessment[1].OrderOrigin__c='Order';
            lstAssessment[2].OrderOrigin__c='Order';
            


            //PlateNumber
            lstAssessment[0].PlateNumber2__c = 'AR777';
            lstAssessment[1].PlateNumber2__c = '0101MR2020';
            lstAssessment[2].PlateNumber2__c = '8702MR2020';
            lstAssessment[3].PlateNumber2__c = '4503MR2020';

            //insurancebroker
            lstAssessment[1].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[2].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[3].InsuranceBroker__c= system.label.InsBrokerName;
            lstAssessment[0].InsuranceBroker__c= system.label.InsBrokerName;



            lstAssessment[0].RecordTypeId 		= claimRecordTypeId;
			lstAssessment[1].RecordTypeId 		= claimOrderRecordTypeId;
			lstAssessment[2].RecordTypeId 		= claimOrderRecordTypeId;
			lstAssessment[3].RecordTypeId 		= newAssessmentRecordTypeId;

            insert lstAssessment;

            lstAssessment[0].ParentAssessment__c = lstAssessment[1].Id;
            lstAssessment[0].ParentAssessment__c = lstAssessment[2].Id;// cannot be linked to claim

            update lstAssessment;

            // // create partList
            // lstPartList =new List<PartList__c>
            // {
            //     TestFactory.createPartList(lstAssessment[0]),
            //     TestFactory.createPartList(lstAssessment[1]),
            //     TestFactory.createPartList(lstAssessment[2]),
            //     TestFactory.createPartList(lstAssessment[3])

            // };

            // insert lstPartList;
            

            //create SalesOrder
            lstSalesOrder =new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(lstAssessment[1], lstAccount[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[1], lstAccount[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[2], lstAccount[4], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(lstAssessment[3], lstAccount[6], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),

                TestFactory.createSalesOrder(lstAssessment[2], lstAccount[4], 'Eliminated'),
                TestFactory.createSalesOrder(lstAssessment[3], lstAccount[6], 'InDelivery')

            };

            insert lstSalesOrder;


            //create purchaseOrder
           lstPurchaseOrder = new List<PurchaseOrder__c>
            {

                TestFactory.createPurchaseOrder( lstAssessment[0],lstSalesOrder[0], lstAccount[0], lstAccount[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
                ,TestFactory.createPurchaseOrder( lstAssessment[1],lstSalesOrder[0], lstAccount[2], lstAccount[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder( lstAssessment[2],lstSalesOrder[2], lstAccount[4], lstAccount[5], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder( lstAssessment[3],lstSalesOrder[3], lstAccount[6], lstAccount[7], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)

                
            };
            lstPurchaseOrder[0].Tech_ExternalId__c = 'qwertyu';
            

            insert lstPurchaseOrder;

            //create Orderline

            lstOrdrLine = new List<OrderLine__c>
            {
                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
                ,
                TestFactory.createOrderLineFinalWithPartList(400, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(450, lstPurchaseOrder[0], partLists[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(550, lstPurchaseOrder[0], partLists[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[1], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(600, lstPurchaseOrder[1], partLists[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(700, lstPurchaseOrder[1], partLists[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(200, lstPurchaseOrder[1], partLists[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[2], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(670, lstPurchaseOrder[2], partLists[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(230, lstPurchaseOrder[2], partLists[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(550, lstPurchaseOrder[2], partLists[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[3], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(560, lstPurchaseOrder[3], partLists[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(570, lstPurchaseOrder[3], partLists[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinalWithPartList(800, lstPurchaseOrder[3], partLists[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS)

            };

            lstOrdrLine[0].PartNUmber__c='7464';
            
            lstOrdrLine[0].Description__c= 'good';
            lstOrdrLine[2].PartNUmber__c='7465';
            lstOrdrLine[2].Description__c= 'good';
            lstOrdrLine[3].PartNUmber__c='7466';
            lstOrdrLine[3].Description__c= 'good';

            insert lstOrdrLine;
            lstOrdrLine[0].OriginalItem__c=lstOrdrLine[1].id;
            update lstOrdrLine;
            //  create Offer

            lstOffer= new List<Offer__c>
            {
                TestFactory.createOfferLine(lstOrdrLine[0], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS)
                ,
                TestFactory.createOfferLine(lstOrdrLine[1], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[2], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[3], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[4], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[5], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[6], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[7], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[8], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[9], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[10], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[11], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(lstOrdrLine[12], lstSalesOrder[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[13], lstSalesOrder[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[14], lstSalesOrder[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(lstOrdrLine[15], lstSalesOrder[3], ASPISConstants.OFFER_STATUS_INPROCESS)


            };

            insert lstOffer;
            
        }//end system.runAs
    }//end static

    static testMethod void constructorTest(){
        system.debug('## Start constructorTest');
        
        //populating partMap
        partMap = new map <Id,PartList__c>{
            partLists[0].id => partLists[0],
            partLists[1].id => partLists[1],
            partLists[2].id => partLists[2]};

        system.runAs(adminUser){
            Test.startTest();
                RESTDistributorUtility controller = new RESTDistributorUtility(assessmentList[0],new list <Account>{distributorList[0]},partMap,true, true);
            Test.stopTest();
        }

        system.debug('## End constructorTest');
    }

    static testMethod void testNoDistributorConnected(){
        system.debug('## Start testNoDistributorConnected');
        
        //populating partMap
        partMap = new map <Id,PartList__c>{
            partLists[0].id => partLists[0],
            partLists[1].id => partLists[1],
            partLists[2].id => partLists[2]};

        system.runAs(adminUser){
            Test.startTest();
                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();

            system.assertEquals(true,RESTDistributorUtility.doNotRunWS);
        }

        system.debug('## End testNoDistributorConnected');
    }

    static testMethod void testDistributorConnectedWithSpecificCategory(){
        system.debug('## Start testDistributorConnectedWithSpecificCategory');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');  

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[1].Id + '","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testDistributorConnectedWithSpecificCategory');
    }

    static testMethod void testDistributorConnectedWithoutSpecificCategory(){
        system.debug('## Start testDistributorConnectedWithoutSpecificCategory');
        
        system.runAs(adminUser){
            assessmentList[0].InsuranceBroker__c = 'IG';
            //update connected boolean on distruibutor
            distributorList[1].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[1];

            //update part type
            partLists[3].Type__c = 'A';
            partLists[4].Type__c = 'A';
            partLists[5].Type__c = 'A';
            partLists[5].OriginalPart__c = partLists[4].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[3].id => partLists[3],
                partLists[4].id => partLists[4],
                partLists[5].id => partLists[5]};

            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss2","Request":"Draft","Success":"true","Distributors":{"Distributor_2":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[3].id +'","Quantity":15,"PartNumber":"76TYGq9t11dcJv","Type":"A","Manufacturer":"AUDI","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"' + partLists[4].id + '","Quantity":15,"PartNumber":"ASCR-75TYGD9t11dcJv","Type":"A","Manufacturer":"AUDI","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[5].id + '","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AUDI","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[1],
                    new list <Account>{distributorList[1]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testDistributorConnectedWithoutSpecificCategory');
    }

    static testMethod void testDistributorCallOutWithoutProperResp(){
        system.debug('## Start testDistributorCallOutWithoutProperResp');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected'); 

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};
        
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(401,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"},"Message":"Service temporarily Down"}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testDistributorCallOutWithoutProperResp');
    }

    static testMethod void testDistributorConnectedWithAlternative(){
        system.debug('## Start testDistributorConnectedWithAlternative');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');  

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[0].TechCheckForSubstitute__c = true;
            partLists[1].Type__c = 'A';
            partLists[1].TechCheckForSubstitute__c = true;
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testDistributorConnectedWithAlternative');
    }

    static testMethod void testDistributorConnectedWithBundles(){
        system.debug('## Start testDistributorConnectedWithBundles');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":201.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":true,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":204.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""},{"Quantity":15,"PartNumber":"76TZ","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 
Map<string,PurchaseOrder__c> mapPurchaseOrder = new Map<String, PurchaseOrder__c>();
                mapPurchaseOrder.put(lstPurchaseOrder[0].Tech_ExternalId__c, lstPurchaseOrder[0]);
                mapPurchaseOrder.put(lstPurchaseOrder[1].Tech_ExternalId__c, lstPurchaseOrder[1]);
                mapPurchaseOrder.put(lstPurchaseOrder[2].Tech_ExternalId__c, lstPurchaseOrder[2]);

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    false,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testDistributorConnectedWithBundles');
    }

    static testMethod void testCreatePOOrderLines(){
        system.debug('## Start testCreatePOOrderLines');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');  

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[0].TechCheckForSubstitute__c = true;
            partLists[1].Type__c = 'A';
            partLists[1].TechCheckForSubstitute__c = true;
            partLists[2].Type__c = 'B';
            partLists[2].TechCheckForSubstitute__c = true;
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

            List<Orderline__c> lstOrdrLineNew = new List<OrderLine__c>
                {
                    TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
                    ,TestFactory.createOrderLineFinalWithPartList(400, lstPurchaseOrder[0], partLists[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
                    ,TestFactory.createOrderLineFinalWithPartList(450, lstPurchaseOrder[0], partLists[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
                    ,TestFactory.createOrderLineFinalWithPartList(550, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
                };

            insert lstOrdrLineNew;

            system.debug('@@ tyu 1:'+[select PartList__c, Id, OriginalItem__c, OrderType__c,TechOLType__c,PartNumber__c,
            ExpectedDeliveryDuration__c, PurchaseOrder__c, SASStatus__c, CataloguePrice__c, Rebate__c, BodyShopDiscount__c, AXADiscount__c, TechExternalId__c,
            Suppliable__c, AcceptedCheck__c, AlphaScaleMRID__c, AssessmentPrice__c, Type__c, Description__c, Manufacturer__c, Quantity__c, VAT__c,
            ASBodyshopNetPrice__c, ASBodyshopPrice__c
              from OrderLine__c where PartList__c in: partMap.keyset() and PurchaseOrder__c =:  lstPurchaseOrder[0].id]);

            system.debug('@@ tyu 2:'+[select PartList__c, Id, OriginalItem__c, OrderType__c,TechOLType__c,PartNumber__c,
            ExpectedDeliveryDuration__c, PurchaseOrder__c, SASStatus__c, CataloguePrice__c, Rebate__c, BodyShopDiscount__c, AXADiscount__c, TechExternalId__c,
            Suppliable__c, AcceptedCheck__c, AlphaScaleMRID__c, AssessmentPrice__c, Type__c, Description__c, Manufacturer__c, Quantity__c, VAT__c,
            ASBodyshopNetPrice__c, ASBodyshopPrice__c
              from OrderLine__c where PartList__c in: partMap.keyset() ]);

            system.debug('@@ tyu 3:'+[select PartList__c, Id, OriginalItem__c, OrderType__c,TechOLType__c,PartNumber__c,
              ExpectedDeliveryDuration__c, PurchaseOrder__c, SASStatus__c, CataloguePrice__c, Rebate__c, BodyShopDiscount__c, AXADiscount__c, TechExternalId__c,
              Suppliable__c, AcceptedCheck__c, AlphaScaleMRID__c, AssessmentPrice__c, Type__c, Description__c, Manufacturer__c, Quantity__c, VAT__c,
              ASBodyshopNetPrice__c, ASBodyshopPrice__c
                from OrderLine__c where PurchaseOrder__c =:  lstPurchaseOrder[0].id]);

            Test.startTest();
            // orderLineList[0].partList__c = partLists[0];
            // update orderLineList[0];
            // Account acc1 = TestFactory.createAccountBodyshop('BodyShop_FR', 'FR');
            // Account acc2 = TestFactory.createAccountDistributor('Distributor_1', 'DE');
            // insert acc1;
            // insert acc2;

            // Assessment__c assessment1 = TestFactory.createAssessment('Assessment_1', acc1);
            // insert assessment1;


            // PartList__c pl1 = TestFactory.createPartList(assessment1);
            // pl1.TECH_OriginalPart__c = 'Ass1Part1';
            // pl1.ProducerName__c = 'VW';
            // pl1.Quantity__c = 15;
            // pl1.RecordtypeId = recordTypeIdMaterial;
            // pl1.PartNumber__c = '76TYGD90anJWXs';
            // pl1.TechCheckForSubstitute__c = true;
            // insert pl1;

            // PrerequisiteOrder__c salesOrder = TestFactory.createSalesOrder(assessment1, acc1, ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE);
            // insert salesOrder;

            // PurchaseOrder__c po = TestFactory.createPurchaseOrder(assessment1,salesOrder, acc1, acc2, ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE);
            // insert po;
            Map<string,PurchaseOrder__c> mapPurchaseOrder = new Map<String, PurchaseOrder__c>();
            mapPurchaseOrder.put(lstPurchaseOrder[0].Tech_ExternalId__c, lstPurchaseOrder[0]);
            mapPurchaseOrder.put(lstPurchaseOrder[1].Tech_ExternalId__c, lstPurchaseOrder[1]);
            mapPurchaseOrder.put(lstPurchaseOrder[2].Tech_ExternalId__c, lstPurchaseOrder[2]);

            // List<OrderLine__c> lstOl = new List<OrderLine__c>{
            //     TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
            //     ,
            //     TestFactory.createOrderLineFinalWithPartList(500, lstPurchaseOrder[0], partLists[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
            // };
            // insert lstOl;

            

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[3].Id +'","Quantity":15,"PartNumber":"'+system.label.AdditionalPartNumber+'","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    distributorList,
                    partMap,
                    true,
                    false, //send true next time
                    mapPurchaseOrder,
                    'qwertyu');
            Test.stopTest();
        }

        system.debug('## End testCreatePOOrderLines');
    }

    static testMethod void testProcessResponseStatusNot200(){
        System.debug('## START testProcessResponseStatusNot200');
               system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected'); 

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

                
            Map<string,PurchaseOrder__c> mapPurchaseOrder = new Map<String, PurchaseOrder__c>();
            mapPurchaseOrder.put(lstPurchaseOrder[0].Tech_ExternalId__c, lstPurchaseOrder[0]);
            System.debug('mapPurchaseOrder'+mapPurchaseOrder);
            // orderLineList[0].partList__c = partLists[0];
            // update orderLineList[0];

            Test.startTest();
            

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(500,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[3].Id +'","Quantity":15,"PartNumber":"'+system.label.AdditionalPartNumber+'","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 



                
                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    distributorList,
                    partMap,
                    false,
                    false,
                    mapPurchaseOrder,
                    '');
            Test.stopTest();
            
        }
        System.debug('## END testProcessResponseStatusNot200');
    }

    static testMethod void testProcessResponseStatusX(){
        System.debug('## START testProcessResponseStatusX');
               system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');  

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

                
            Map<string,PurchaseOrder__c> mapPurchaseOrder = new Map<String, PurchaseOrder__c>();
            // mapPurchaseOrder.put(lstPurchaseOrder[0].Tech_ExternalId__c, lstPurchaseOrder[0]);
            System.debug('mapPurchaseOrder'+mapPurchaseOrder);
            // orderLineList[0].partList__c = partLists[0];
            // update orderLineList[0];

            Test.startTest();
            
                RESTDistributorUtility.doNotRunWS = true;
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(500,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":true,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[3].Id +'","Quantity":15,"PartNumber":"'+system.label.AdditionalPartNumber+'","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true","AgencyMode":"false"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 


                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    distributorList,
                    partMap,
                    false,
                    true,
                    mapPurchaseOrder,
                    'test');
            Test.stopTest();
            
        }
        System.debug('## END testProcessResponseStatusX');
    }
    static testMethod void testProcessResponseStatusNotX(){
        System.debug('## START testProcessResponseStatusX');
               system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

                
            Map<string,PurchaseOrder__c> mapPurchaseOrder = new Map<String, PurchaseOrder__c>();
            mapPurchaseOrder.put(lstPurchaseOrder[0].Tech_ExternalId__c, lstPurchaseOrder[0]);
            System.debug('mapPurchaseOrder'+mapPurchaseOrder);
            // orderLineList[0].partList__c = partLists[0];
            // update orderLineList[0];

            Test.startTest();
            
                RESTDistributorUtility.doNotRunWS = true;
                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id +'","Quantity":15,"PartNumber":"76TYGD90anJWXs","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":true,"Parts":[{"Quantity":15,"PartNumber":"76TY","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":""}]},{"ID":"'+ partLists[1].Id +'","Quantity":15,"PartNumber":"76TYGD9011dcJv","Type":"A","Manufacturer":"VW","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[2].Id +'","Quantity":15,"PartNumber":"3434hcv","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false},{"ID":"'+ partLists[3].Id +'","Quantity":15,"PartNumber":"'+system.label.AdditionalPartNumber+'","Type":"B","Manufacturer":"AXA MANUFACTURER","Description":"FEUILLE D ETANCHEITE DE PORTE AV G","CatalogPrice":65.44,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"NOTFOUND","StatusMessage":"","Bundle":false}],"Success":"true","AgencyMode":"false"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 


                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    distributorList,
                    partMap,
                    false,
                    true,
                    mapPurchaseOrder,
                    'test');
            Test.stopTest();
            
        }
        System.debug('## END testProcessResponseStatusX');
    }
    
    // static testMethod void testCreateIGO(){
    //     System.debug('## START testCreateIGO');
    //            system.runAs(adminUser){
    //         Test.startTest();
    //         map <string,object> inputParamForIGO = new map <string,object>();

    //         inputParamForIGO.put('line',ln);
    //         inputParamForIGO.put('mapTechOriginalPartKeyCorrespondingPart',mapTechOriginalPartKeyCorrespondingPart);
    //         inputParamForIGO.put('mapEligiblePONameELigiblePO',mapEligiblePONameELigiblePO);
    //         inputParamForIGO.put('isIG',isIG);
    //         inputParamForIGO.put('receivedStatus',receivedStatus);
    //         inputParamForIGO.put('distName',distName);
    //         inputParamForIGO.put('assessId',assessId);
    //         inputParamForIGO.put('insuranceBroker',insuranceBroker);

    //         getIGO = RestDistributorUtility.createIGO(inputParamForIGO);
    //         System.debug('@@@ getIGO:'+getIGO);
    //         Test.stopTest();
            
    //     }
    //     System.debug('## END testCreateIGO');
    // }
    
    // static testMethod void testInitialiseWSCallOutCatch(){
    //     System.debug('## START testInitialiseWSCallOutCatch');
    //            system.runAs(adminUser){
    //         Test.startTest();
    //             Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(500,'OK','{}')); 

    //             RESTDistributorUtility.initialiseWSCallOut(
    //                                                         new Assessment__c(),
    //                                                         new List<Account>{},
    //                                                         new Map<Id, PartList__c>{},
    //                                                         false,
    //                                                         false,
    //                                                         new Map<String, PurchaseOrder__c>{},
    //                                                         '');
    //         Test.stopTest();
            
    //     }
    //     System.debug('## END testInitialiseWSCallOutCatch');
    // }
    static testMethod void testProcessErrorPartOL(){
        system.debug('## Start testProcessErrorPartOL');
        
        system.runAs(adminUser){
            //update connected boolean on distruibutor
            distributorList[0].Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');

            update distributorList[0];

            //update part type
            partLists[0].Type__c = 'A';
            partLists[1].Type__c = 'A';
            partLists[2].Type__c = 'B';
            partLists[2].OriginalPart__c = partLists[1].Id;

            update partLists;

            //populating partMap
            partMap = new map <Id,PartList__c>{
                partLists[0].id => partLists[0],
                partLists[1].id => partLists[1],
                partLists[2].id => partLists[2]};

            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new RestUtilityHttpCalloutMock(200,'OK','{"ClaimReference":"ClaimRefAss1","Request":"Draft","Success":"true","Distributors":{"Distributor_1":{"ExternalOrderReference":"","Lines":[{"ID":"'+ partLists[0].Id  +'","Quantity":15,"PartNumber":"","Type":"A","Manufacturer":"VW","Description":"PROJECTEUR G","CatalogPrice":206.16,"AlphaScaleDiscount":50,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":50,"Status":"CONFIRMED","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FRAB123456789","Name":"BodyShop_1","ExternalReference":"12345678901234"},"Vehicle":{"VinNumber":"V23NVMR17","PlateNumber":"23NVMR17","Model":"Passat","FirstRegistrationDate":"","Brand":"VW"}}')); 

                RESTDistributorUtility.initialiseWSCallOut(
                    assessmentList[0],
                    new list <Account>{distributorList[0]},
                    partMap,
                    true,
                    new map<string,PurchaseOrder__c>(),
                    '');
            Test.stopTest();
        }

        system.debug('## End testProcessErrorPartOL');
    }
}