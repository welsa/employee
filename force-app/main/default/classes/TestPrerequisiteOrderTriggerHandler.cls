/*************************************************************************************
Class Name - TestPrerequisiteOrderTriggerHandler
Version - 1.0
Created Date - 30 APR 2015
Function - TestClass to PrerequisiteOrderTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      30/04/2015  Original Version
* Dourga U      14/07/2015  Corrected according to updates
* Yudish R      20/07/2015  Coverage for Ap07
* Dourga        11/02/2016  C-001522: Clarifications sur les rejets et annulations des commandes
*************************************************************************************/
@isTest
private class TestPrerequisiteOrderTriggerHandler {
    
    /*static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
    static list<PurchaseOrder__c> purchaseOrders;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();
    static list<Offer__c> offersList;
    static list<Group> groupList;
    static list<OrderLine__c> orderLinesList;
    
    static list <MasterRules__c> masterRules;
    static map <String,Id> mastrerRuleRecordTypeMap = new map <String,Id>();
    static list <DetailRule__c> detailRules;
    static map <String,Id> detailRuleRecordTypeMap = new map <String,Id>();
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;
    static BusinessHours defaultHours;

    static{
        
        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
        mastrerRuleRecordTypeMap= ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
        detailRuleRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);

        ASPISTestUtils.generateBasicTestData();
        
       userAdmin = new User(Username = 'jean.paul-testingNewName@test.com'  // checking for UNABLE_TO_LOCK_ROW error in running test parallel
            ,LastName = 'paul'
            ,LanguageLocaleKey = 'en_US'
            ,FirstName = 'jean'
            ,Email = 'jean@test.com'
            ,Alias = 'jpa'
            ,TimeZoneSidKey = 'Europe/Dublin'
            ,LocaleSidKey = 'en_US'
            ,EmailEncodingKey = 'UTF-8'
            ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        system.runas(userAdmin){
            // insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest122'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '9123'
                    ,ContactEmail__c = 'bt122@gmail.com'
                    ,VAT__c = 10

                ),
                new Account(Name='BodyShop_ScTest222'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '91234'
                    ,ContactEmail__c = 'bt222@gmail.com'
                    ,VAT__c = 10
                ),
                new Account(Name='Distributor_ScTest122'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '912345'
                    ,ContactEmail__c = 'dt1@gmail.com'
                    ,VAT__c = 10
                ),
                new Account(Name='Distributor_ScTest222'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '9123456'
                    ,ContactEmail__c = 'dt1@gmail.com'
                    ,VAT__c = 10
                )
            };
            
            insert accounts;


            groupList = new List<Group>
            {
                new Group( Name = '9123')
            };

            insert groupList;

            //insert rule set
            MasterRules__c ruleSet = new MasterRules__c (
                                            Process__c='SLA'
                                            ,Entity__c = '43'
                                            ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
                                            ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)
            );
            insert ruleSet;

            //insert master rule
            masterRules = new list <MasterRules__c>{
                new MasterRules__c(Process__c = 'DELIVERYCONFIRMATION' 
                                    ,RuleSet__c = ruleSet.Id
                                    ,Entity__c = '241'
                                    ,Version__c = 0
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)'
                                    ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
                                    ,Country__c = 'SPAIN'
                                    ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
                ),
                new MasterRules__c(Process__c = 'DELIVERYCONFIRMATION2' 
                                    ,RuleSet__c = ruleSet.Id
                                    ,Entity__c = '297'
                                    ,Version__c = 1
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)'
                                    ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
                                    ,Country__c = 'FRANCE'
                                    ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
                )

            };
            system.debug('##masterRules '+masterRules);

            Insert masterRules;

            //insert details rule
            detailRules = new list <DetailRule__c>{
                //master rule 0
                new DetailRule__c(MasterRule__c = masterRules[0].Id
                                    ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FieldsAPI__c = 'SLAInDeliveryLevel1__c'
                                    ,Operator__c = 'EQUALS'
                                    ,ValueFrom__c = 'M'
                                    ,Active__c =true
                                    ,Value__c = '15'
                                    ,Number__c=1
                ),
                new DetailRule__c(MasterRule__c = masterRules[0].Id
                                    ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FieldsAPI__c = 'SLAInDeliveryLevel2__c'
                                    ,Operator__c = 'EQUALS'
                                    ,ValueFrom__c = 'M'
                                    ,Active__c =true
                                    ,Value__c = '25'
                                    ,Number__c=2
                ),
                //master rule 1
                new DetailRule__c(MasterRule__c = masterRules[1].Id
                                    ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FieldsAPI__c = 'SLAInDeliveryLevel1__c'
                                    ,Operator__c = 'EQUALS'
                                    ,ValueFrom__c = 'H'
                                    ,Active__c =true
                                    ,Value__c = '2'
                                    ,Number__c=1
                ),
                new DetailRule__c(MasterRule__c = masterRules[1].Id
                                    ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
                                    ,sObject__c = 'PrerequisiteOrder__c'
                                    ,FieldsAPI__c = 'SLAInDeliveryLevel2__c'
                                    ,Operator__c = 'EQUALS'
                                    ,ValueFrom__c = 'D'
                                    ,Active__c =true
                                    ,Value__c = '4'
                                    ,Number__c=2
                )
                
            };
            insert detailRules;


            //Get the default business hours (we might need it)
            defaultHours = [select Id from BusinessHours where IsDefault=true];

            // custom settings - CountryCodeInfo
            countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
                new CountryCodeInformationsMapping__c(
                    Name='FR'
                    ,BusinessHoursID__c = defaultHours.Id
                ),
                new CountryCodeInformationsMapping__c(
                    Name='DEFAULT'
                    ,BusinessHoursID__c = defaultHours.Id
                )
            };
            insert countryCodeInfos;
            //system.debug('countryCodeInfos:'+countryCodeInfos);
           

            //assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(Name='ASSESS_TEST-000101'
                    ,AssessmentNumber__c = 'ASSESS_TEST-000101'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct'
                    ,MissionNumber__c = '011'
                    ,PortfolioAgentCode__c = '3551'
                    ,AssessmentID__c = '09121'
                    ,TechExternalId__c = '2331'
                    ,EntityRules__c = '241' 
                ),
                
                new Assessment__c(Name='ASSESS_TEST-000201'
                    ,AssessmentNumber__c = 'ASSESS_TEST-000201'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct'
                    ,MissionNumber__c = '022'
                    ,PortfolioAgentCode__c = '35452'
                    ,AssessmentID__c = '59122'
                    ,EntityRules__c = '297' 
                )
                
            };
            
            insert assessments ;
           
        }
    }
    
    static testMethod void prerequisiteOrdersOnUpdate_V1_Test() {
       system.debug('#### Start of method prerequisiteOrdersOnUpdate_V1_Test');
       
        //system.debug('countryCodeInfosv1:'+countryCodeInfos);

       //PrerequisiteOrder
        prerequisiteOrders= new list<PrerequisiteOrder__c>{
           new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ,Status__c = 'INACCEPTANCE'
                ,Comment__c='test1'
                ,ReferenceNumber__c ='9123'
            ),
            
            new PrerequisiteOrder__c(BodyShop__c = accounts[1].Id
                ,Assessment__c = assessments[1].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ,Status__c = 'INACCEPTANCE'
                ,Comment__c='test2'
            )
        };
        insert prerequisiteOrders;

        offersList =  new list<Offer__c>{
            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[0].Id,
                    Prerequisiteorder__c = prerequisiteOrders[0].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+1,
                    DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[1].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+2,
                    DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

              new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[1].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+3,
                    DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),

            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[2].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'NO',
                    ExpectedDeliveryDate__c = date.today()+4,
                    DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY)
        };


        //prerequisiteOrders[0].Status__c = 'CANCELED';
        //system.debug('##prerequisiteOrders'+[select Id, Status__c from PrerequisiteOrder__c where Id=:prerequisiteOrders[0].Id]);
        //prerequisiteOrders[0].Status__c = 'INDELIVERY';  
        system.runAs(userAdmin){    
        test.starttest(); 
            //update prerequisiteOrders; 
            insert offersList;

            List<PrerequisiteOrder__c> prerequisiteOrderAsserList = new List<PrerequisiteOrder__c>([select Id,Status__c
                                                                                    , SLAInDeliveryLevel1__c
                                                                                    , SLAInDeliveryLevel2__c
                                                                            from PrerequisiteOrder__c 
                                                                            where Id IN: prerequisiteOrders
                                                                            order by Name]);
            
        //system.debug('####prerequisiteOrderAsserList'+prerequisiteOrderAsserList);

        system.assertEquals('INDELIVERY' , prerequisiteOrderAsserList[0].Status__c);
			test.stoptest();
        }//end runAs
    }//end method
    
    static testMethod void prerequisiteOrdersOnUpdate_V2_Test() {
       system.debug('#### Start of method prerequisiteOrdersOnUpdate_V2_Test');
       
        //system.debug('countryCodeInfosv2:'+countryCodeInfos);
       //PrerequisiteOrder
        prerequisiteOrders= new list<PrerequisiteOrder__c>{
            new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ,Status__c = 'INACCEPTANCE' 
            ),
            
            new PrerequisiteOrder__c(BodyShop__c = accounts[1].Id
                ,Assessment__c = assessments[1].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ,Status__c = 'PREORDERCLOSED'
            )
        };

        insert prerequisiteOrders;
        orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = 'Final 1',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'YES',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = 'Final 1',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'YES',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'FINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
            //,new OrderLine__c(Type__c = 'A',
            //                OrderType__c = 'ORIGINAL',
            //                PartList__c = ASPISTestUtils.partLists[0].id,
            //                OriginalItem__c = null,
            //                PartNumber__c = 'Part1234',
            //                ExpectedDeliveryDuration__c = '1',
            //                Description__c = '',
            //                PartFamily__c = 'Family1234',
            //                Manufacturer__c = 'Manufacturer1',
            //                CataloguePrice__c = 1000,
            //                Quantity__c = 10,
            //                AXADiscount__c = 10,
            //                BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;',
            //                BodyShopDiscount__c = 10,
            //                Suppliable__c = 'NO',
            //                PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
            //                AcceptedCheck__c=true)
        };
        insert orderLinesList;

		//orderLinesList[0].OriginalItem__c = orderLinesList[9].id;
        //orderLinesList[7].OriginalItem__c = orderLinesList[0].id;
        //orderLinesList[8].OriginalItem__c = orderLinesList[0].id;
        //orderLinesList[7].OrderType__c = 'BUNDLEITEM';
        //orderLinesList[8].OrderType__c = 'BUNDLEITEM';
        //update orderLinesList;

        offersList =  new list<Offer__c>{
            new Offer__c(Type__c = 'QUICK',
                    OrderLine__c = orderLinesList[0].Id,
                    Prerequisiteorder__c = prerequisiteOrders[0].Id,
                    Accepted__c = 'YES',
                    DeliveryStatus__c = '')
					//,

            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[1].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[0].Id,
            //        Accepted__c = 'YES',
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[2].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[0].Id,
            //        Accepted__c = 'NO',
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[3].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[0].Id,
            //        Accepted__c = null,
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[4].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[1].Id,
            //        Accepted__c = null,
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[5].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[1].Id,
            //        Accepted__c = null,
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[6].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[1].Id,
            //        Accepted__c = 'NO',
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[7].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[1].Id,
            //        Accepted__c = 'YES',
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY),
			//
            //new Offer__c(Type__c = 'QUICK',
            //        OrderLine__c = orderLinesList[8].Id,
            //        Prerequisiteorder__c = prerequisiteOrders[1].Id,
            //        Accepted__c = 'YES',
            //        DeliveryStatus__c = ASPISConstants.OFFER_STATUS_INDELIVERY)
        };
        insert offersList;
        
        //offersList[7].ParentOffer__c = offersList[0].Id;
        //offersList[8].ParentOffer__c = offersList[0].Id;
        //update offersList;

        ASPISTestUtils.purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id;
        update ASPISTestUtils.purchaseOrders[0];
        prerequisiteOrders[0].Status__c = 'RESPONDED';
        prerequisiteOrders[1].Status__c = 'CANCELED'; 
        system.runAs(userAdmin){    
        test.starttest();   
            update prerequisiteOrders; 
		
			List<PrerequisiteOrder__c> prerequisiteOrderAsserList = new List<PrerequisiteOrder__c>([select Id,Status__c
                                                                                    , SLAInDeliveryLevel1__c
                                                                                    , SLAInDeliveryLevel2__c
                                                                                    ,SLARespondedEntryDate__c
                                                                            from PrerequisiteOrder__c 
                                                                            where Id =: prerequisiteOrders[0].Id
                                                                            order by Name limit 1]);
            
	        //system.debug('####prerequisiteOrderAsserList'+prerequisiteOrderAsserList);

	        
	        system.assertEquals('RESPONDED' , prerequisiteOrderAsserList[0].Status__c);
	        system.assertNotEquals(null , prerequisiteOrderAsserList[0].SLARespondedEntryDate__c);

	        //system.assertEquals('RESPONDED' , [select Status__c from PrerequisiteOrder__c where Id =: prerequisiteOrders[0].Id].Status__c);
	        system.assertEquals('CANCELED' , [select Status__c from PrerequisiteOrder__c where Id =: prerequisiteOrders[1].Id].Status__c);
        test.stoptest();

         
            
        }//end runAs
    }//end method

    static testMethod void prerequisiteOrdersOnUpdate_V3_Test() {
       system.debug('#### Start of method prerequisiteOrdersOnUpdate_V3_Test');
       
       //PrerequisiteOrder
        prerequisiteOrders= new list<PrerequisiteOrder__c>{
            new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ,Status__c = 'INACCEPTANCE' 
            ),
            
            new PrerequisiteOrder__c(BodyShop__c = accounts[1].Id
                ,Assessment__c = assessments[1].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ,Status__c = 'INACCEPTANCE'
            )
        };
        insert prerequisiteOrders;

        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                        ValidityDate__c=date.today(),
                                                                        Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                        Assessment__c=assessments[0].id,
                                                                        PrerequisiteOrder__c = prerequisiteOrders[0].Id
                                                                        ),

                                                    new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                        ValidityDate__c=date.today(),
                                                                        Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED,
                                                                        Assessment__c=assessments[0].id,
                                                                        PrerequisiteOrder__c = prerequisiteOrders[0].Id
                                                                        )
        };
        insert purchaseOrders;

        prerequisiteOrders[0].Status__c = 'RESPONDED';
        prerequisiteOrders[0].HasSomeDeliveryIssuedCaseCreated__c = true;
        prerequisiteOrders[1].Status__c = 'PREORDERCONFIRMED'; 
        system.runAs(userAdmin){    
        test.starttest();   
            update prerequisiteOrders; 
        test.stoptest();

        List<PrerequisiteOrder__c> prerequisiteOrderAsserList = new List<PrerequisiteOrder__c>([select Id,Status__c
                                                                                    , SLAInDeliveryLevel1__c
                                                                                    , SLAInDeliveryLevel2__c
                                                                                    ,SLADeliveryConfirmedEntryDate__c
                                                                            from PrerequisiteOrder__c 
                                                                            where Id =: prerequisiteOrders[1].Id
                                                                            order by Name]);
            
        //system.debug('####prerequisiteOrderAsserList'+prerequisiteOrderAsserList);

        system.assertEquals('RESPONDED' , [select Status__c from PrerequisiteOrder__c where Id =: prerequisiteOrders[0].Id].Status__c);
        //system.assertEquals('PREORDERCONFIRMED' , [select Status__c from PrerequisiteOrder__c where Id =: prerequisiteOrders[1].Id].Status__c);
        system.assertEquals('PREORDERCONFIRMED' , prerequisiteOrderAsserList[0].Status__c);
        system.assertNotEquals(null , prerequisiteOrderAsserList[0].SLADeliveryConfirmedEntryDate__c);
        system.assertEquals(null , prerequisiteOrderAsserList[0].SLAInDeliveryLevel1__c);
        system.assertEquals(null , prerequisiteOrderAsserList[0].SLAInDeliveryLevel2__c);
        }//end runAs
    }//end method

    static testMethod void prerequisiteOrdersOnUpdate_V4_Test() {
       system.debug('#### Start of method prerequisiteOrdersOnUpdate_V2_Test');
       
        
        system.runAs(userAdmin){ 

        //system.debug('countryCodeInfosv2:'+countryCodeInfos);
       //PrerequisiteOrder
        prerequisiteOrders= new list<PrerequisiteOrder__c>{
            new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ,Status__c = 'INACCEPTANCE' 
            )
        };

        insert prerequisiteOrders;
        orderLinesList = new List<OrderLine__c>{
            new OrderLine__c(Type__c = 'A',
                            OrderType__c = 'FINAL',
                            PartList__c = ASPISTestUtils.partLists[0].id,
                            OriginalItem__c = null,
                            PartNumber__c = 'Part1234',
                            ExpectedDeliveryDuration__c = '1',
                            Description__c = 'Original 1',
                            PartFamily__c = 'Family1234',
                            Manufacturer__c = 'Manufacturer1',
                            CataloguePrice__c = 1000,
                            Quantity__c = 10,
                            AXADiscount__c = 10,
                            BodyShopDiscount__c = 10,
                            BundleItemsDescription__c = 'Desc1;Desc1;Desc1;Desc1;Desc1;|Desc1;Desc1;Desc1;Desc1;Desc1;',
                            Suppliable__c = 'YES',
                            PurchaseOrder__c = ASPISTestUtils.purchaseOrders[0].Id,
                            AcceptedCheck__c=true)
            
        };
        insert orderLinesList;

        offersList =  new list<Offer__c>{
            new Offer__c(Type__c = 'QUICK',
                    OrderLine__c = orderLinesList[0].Id,
                    Prerequisiteorder__c = prerequisiteOrders[0].Id,
                    Accepted__c = 'NO')
        };
        insert offersList;

        ASPISTestUtils.purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id;
        update ASPISTestUtils.purchaseOrders[0];
        prerequisiteOrders[0].Status__c = 'CANCELED';
           
        test.starttest();   
            update prerequisiteOrders; 
        
            List<PrerequisiteOrder__c> prerequisiteOrderAsserList = new List<PrerequisiteOrder__c>([select Id,Status__c
                                                                                                    from PrerequisiteOrder__c 
                                                                                                    where Id =: prerequisiteOrders[0].Id
                                                                                                    order by Name limit 1]);
            
            system.assertEquals('CANCELED' , [select Status__c from PrerequisiteOrder__c where Id =: prerequisiteOrders[0].Id].Status__c);
        test.stoptest();

         
            
        }//end runAs
    }//end method

    static testMethod void prerequisiteOrdersOnUpdate_V5_Test() {
       system.debug('#### Start of method prerequisiteOrdersOnUpdate_V1_Test');
       
        //system.debug('countryCodeInfosv1:'+countryCodeInfos);

       //PrerequisiteOrder
        prerequisiteOrders= new list<PrerequisiteOrder__c>{
           new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ,Status__c = 'PREORDERCONFIRMED'
                ,Comment__c='test1'
                ,ReferenceNumber__c ='9123'
            ),
            
            new PrerequisiteOrder__c(BodyShop__c = accounts[1].Id
                ,Assessment__c = assessments[1].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ,Status__c = 'PREORDERCONFIRMED'
                ,Comment__c='test2'
            )
        };
        insert prerequisiteOrders;

        offersList =  new list<Offer__c>{
            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[0].Id,
                    Prerequisiteorder__c = prerequisiteOrders[0].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+1,
                    DeliveryStatus__c = 'DELIVERED'),

            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[1].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+2,
                    DeliveryStatus__c = 'DELIVERED'),

              new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[1].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'YES',
                    ExpectedDeliveryDate__c = date.today()+3,
                    DeliveryStatus__c = 'DELIVERED'),

            new Offer__c(Type__c = 'QUICK',
                    //OrderLine__c = orderLinesList[2].Id,
                    Prerequisiteorder__c = prerequisiteOrders[1].Id,
                    Accepted__c = 'NO',
                    ExpectedDeliveryDate__c = date.today()+4,
                    DeliveryStatus__c = 'DELIVERED')
        };

        insert offersList;

        prerequisiteOrders[1].Status__c = 'INVOICED';
        prerequisiteOrders[0].Status__c = 'INVOICED'; 
        system.runAs(userAdmin){    
        test.starttest(); 
            update prerequisiteOrders; 

            List<PrerequisiteOrder__c> prerequisiteOrderAsserList = new List<PrerequisiteOrder__c>([select Id,Sum_of_Total_Price_Net__c
                                                                            from PrerequisiteOrder__c 
                                                                            where Id IN: prerequisiteOrders
                                                                            order by Name]);
            
        //system.debug('####prerequisiteOrderAsserList'+prerequisiteOrderAsserList);

        system.assertEquals(0.00 , prerequisiteOrderAsserList[0].Sum_of_Total_Price_Net__c);
            test.stoptest();
        }//end runAs
    }*/
}