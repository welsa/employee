/*************************************************************************************
Class Name - TestPurchaseOrderTriggerHandler
Version - 1.0
Created Date - 30 APR 2015
Function - TestClass to PurchaseOrderTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      30/04/2015  Original Version
* Cecile L      02/09/2015  Create Case when ASMarginTooLowCaseCreated__c is checked.
* Ashwina S     13/10/15	C-001272
* Dourga U     	19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
*************************************************************************************/
@isTest
private class TestPurchaseOrderTriggerHandler {
// ABT 23-NOV-2016 - Commented
//     static User userAdmin;
//     static list<Account> accounts;
//     static map <String,Id> accRecordTypeMap = new map <String,Id>();
//     static map <String,Id> mastrerRuleRecordTypeMap = new map <String,Id>();
//     static map <String,Id> detailRuleRecordTypeMap = new map <String,Id>();
//     static list<PurchaseOrder__c> purchaseOrders;
//     static list<Assessment__c> assessments;
//     static list<PrerequisiteOrder__c> prerequisiteOrders;
//     static BusinessHours defaultHours;
//     static list<SLAConfiguration__c> slaRecords;
//     static list <Group> groups;
//     static list<QueuesObject> queues;
//     static list<CountryQueueMapping__c> cs_CountryQueues;
//     static list<CaseDetailsProcessMapping__c> cs_CaseDetails;
//     static list <GlobalVariables__c> cs_GlobalVariables;
//     static list <PartList__c> partlists;

//     static list <MasterRules__c> masterRules;
//     static list <DetailRule__c> detailRules;
//     static list <CountryCodeInformationsMapping__c> countryCodeInfos;
//     static list <OrderLine__c> orderlines;
//     static list <Invoice__c> invoices;
    
//     static{
//         accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
//         mastrerRuleRecordTypeMap= ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
//         detailRuleRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
        
//         userAdmin = new User(Username = 'jean.paul@test.com'
//                     ,LastName = 'paul'
//                     ,LanguageLocaleKey = 'en_US'
//                     ,FirstName = 'jean'
//                     ,Email = 'jean@test.com'
//                     ,Alias = 'jpa'
//                     ,TimeZoneSidKey = 'Europe/Dublin'
//                     ,LocaleSidKey = 'en_US'
//                     ,EmailEncodingKey = 'UTF-8'
//                     ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
//         //insert userAdmin;
//         ASPISTestUtils.generateTestUser(userAdmin);
		
		
//         InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
//         insert newCSInvoiceMagin;

//         //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
//         //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestPurchaseOrderTriggerHandler',userAdmin.Id);
//         system.runas(userAdmin){
//             // insert accounts
//             accounts = new list<Account>{
//                 new Account(Name='BodyShop_ScTest1'
//                     ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
//                     ,ReferenceNumber__c = '123'
//                     ,ContactEmail__c = 'bt1@gmail.com'
//                 ),
//                 new Account(Name='BodyShop_ScTest2'
//                     ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
//                     ,ReferenceNumber__c = '1234'
//                     ,ContactEmail__c = 'bt2@gmail.com'
//                 ),
//                 new Account(Name='Distributor_ScTest1'
//                     ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
//                     ,ReferenceNumber__c = '12345'
//                     ,ContactEmail__c = 'dt1@gmail.com'
//                     ,Categories__c = 'A; B; C'
//                 ),
//                 new Account(Name='Distributor_ScTest2'
//                     ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
//                     ,ReferenceNumber__c = '123456'
//                     ,ContactEmail__c = 'dt1@gmail.com'
//                      ,Categories__c = 'A; B; C'
//                 )
//             };
//             ASPISTestUtils.generateAccount (accounts);
//             accounts[0].ShippingCountryCode = 'FR';
//             accounts[1].ShippingCountryCode = 'FR';
//             update accounts;

//             //insert rule set
//             MasterRules__c ruleSet = new MasterRules__c (
//                                             Process__c='SLA'
//                                             ,Entity__c = 'FR295'
//                                     		,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
//                                             ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET)
//             );
//             insert ruleSet;

//             //insert master rule
//             masterRules = new list <MasterRules__c>{
//                 new MasterRules__c(Process__c = 'QUOTATION' 
//                                     ,RuleSet__c = ruleSet.Id
//                                     ,Entity__c = 'FR244'
//                                     ,Version__c = 1
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)'
//                                     ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
//                                     ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
//                 ),
//                 new MasterRules__c(Process__c = 'QUOTATION' 
//                                     ,RuleSet__c = ruleSet.Id
//                                     ,Entity__c = 'FR295'
//                                     ,Version__c = 2
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)'
//                                     ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
//                                     ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
//                 ),
//                  new MasterRules__c(Process__c = 'QUOTATION' 
//                                     ,RuleSet__c = ruleSet.Id
//                                     ,Entity__c = 'FR261'
//                                     ,Version__c = 3
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)'
//                                     ,RuleStatus__c = system.Label.RULESTATUSACTIVELABEL
//                                     ,RecordTypeId=mastrerRuleRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
//                 )

//             };

//             //Insert masterRules;
//             ASPISTestUtils.generateMasterRules(masterRules);

//             //insert detailrule

//             detailRules = new list <DetailRule__c>{
//                 //master rule 0
//                 new DetailRule__c(MasterRule__c = masterRules[0].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel1__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'M'
//                                     ,Value__c = '15'
//                                     ,Number__c=1
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[0].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel2__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'M'
//                                     ,Value__c = '25'
//                                     ,Number__c=2
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[0].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel3__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'M'
//                                     ,Value__c = '60'
//                                     ,Number__c=3
//                 ),

//                 //master rule 1

//                 new DetailRule__c(MasterRule__c = masterRules[1].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel1__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'H'
//                                     ,Value__c = '1'
//                                     ,Number__c=1
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[1].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel2__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'H'
//                                     ,Value__c = '2'
//                                     ,Number__c=2
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[1].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel3__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'H'
//                                     ,Value__c = '4'
//                                     ,Number__c=3
//                 ),

//                 //master rule 2
//                 new DetailRule__c(MasterRule__c = masterRules[2].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel1__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'D'
//                                     ,Value__c = '1'
//                                     ,Number__c=1
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[2].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel2__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'D'
//                                     ,Value__c = '2'
//                                     ,Number__c=2
//                 ),
//                 new DetailRule__c(MasterRule__c = masterRules[2].Id
//                                     ,RecordTypeId = detailRuleRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_Parameters)
//                                     ,sObject__c = 'PurchaseOrder__c'
//                                     ,FieldsAPI__c = 'SLAQuotationLevel3__c'
//                                     ,Operator__c = 'EQUALS'
//                                     ,ValueFrom__c = 'D'
//                                     ,Value__c = '4'
//                                     ,Number__c=3
//                 )
//             };
//             //insert detailRules;
//             ASPISTestUtils.generateDetailRule(detailRules);

//             //assessments
//             assessments = new list<Assessment__c>{
//                 new Assessment__c(BodyShop__c = accounts[0].Id,EntityCode__c='244',AssessmentNumber__c='assNb1',VINNumber__c='vinNb1',PlateNumber2__c='plateNb1',Manufacturer__c='brand1',TECH_EntityCountryCode__c = 'FR'),
//                 new Assessment__c(BodyShop__c = accounts[0].Id,EntityCode__c='295',AssessmentNumber__c='assNb2',VINNumber__c='vinNb2',PlateNumber2__c='plateNb2',Manufacturer__c='brand2',TECH_EntityCountryCode__c = 'FR'),
//                 new Assessment__c(BodyShop__c = accounts[0].Id,EntityCode__c='261',AssessmentNumber__c='assNb3',VINNumber__c='vinNb3',PlateNumber2__c='plateNb3',Manufacturer__c='brand3',TECH_EntityCountryCode__c = 'FR')
//             };
            
//             ASPISTestUtils.generateAssessment (assessments);


//             //partlist
//             partlists = new list<PartList__c>{
//                 new PartList__c(
//                     Name = 'R/ELEC'
//                     ,Partnumber__c = '16361'
//                     ,Description__c='R/ELECTRI'
//                     ,Quantity__c=1
//                     ,Type__c='A'
//                     ,Price__c = 123
//                     ,VAT__c =10
//                     ,ProducerName__c='Yudish'
//                     ,ProducerNameOptimized__c='Yudish1'
//                     ,assessment__c = assessments[0].Id
//                     ,SelectedByBS__c = True
//                 ),
//                 new PartList__c(
//                     Name = 'RADIATOR'
//                     ,Partnumber__c = '1632361'
//                     ,Description__c='RADIATOR'
//                     ,Quantity__c=4
//                     ,Type__c='A'
//                     ,Price__c = 100
//                     ,VAT__c =10
//                     ,ProducerName__c='Brayan'
//                     ,ProducerNameOptimized__c='Brayan1'
//                     ,assessment__c = assessments[0].Id
//                     ,SelectedByBS__c = True
//                 ),
//                 new PartList__c(
//                     Name = 'RADIATOR'
//                     ,Partnumber__c = '16323617'
//                     ,Description__c='RADIATOR'
//                     ,Quantity__c=4
//                     ,Type__c='B'
//                     ,Price__c = 54
//                     ,VAT__c =9
//                     ,ProducerName__c='Dourga'
//                     ,ProducerNameOptimized__c='Dourga1'
//                     ,assessment__c = assessments[1].Id                    
//                     ,SelectedByBS__c = True
//                 )
//             };

//             //insert partlists;
//             ASPISTestUtils.generatePartList(partlists);

//             //Get the default business hours (we might need it)
//             defaultHours = [select Id from BusinessHours where IsDefault=true];

//             // custom settings - CountryCodeInfo
//             countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
//                 new CountryCodeInformationsMapping__c(
//                     Name='FR'
//                     ,BusinessHoursID__c = defaultHours.Id
//                 )
//             };
//             insert countryCodeInfos;
  
//             prerequisiteOrders= new list<PrerequisiteOrder__c>{
//                 new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
//                                         Assessment__c = assessments[0].Id,
//                                         OfferType__c = 'BASIC')
//             };
//             insert prerequisiteOrders;

//             purchaseOrders = new list<PurchaseOrder__c>{
//                 new PurchaseOrder__c(
//                     Distributor__c= accounts[2].Id
//                     ,Manual_Creation__c = true
//                     ,Assessment__c = assessments[0].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1230'

//                 ),
//                 new PurchaseOrder__c(
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[1].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1239'

//                 ),
//                 new PurchaseOrder__c(
//                     //BodyShop__c = accounts[1].Id
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[2].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1238'
//                 ),
//                 new PurchaseOrder__c(
//                     //BodyShop__c = accounts[1].Id
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[2].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1237'
//                 ),
//                 new PurchaseOrder__c(
//                     //BodyShop__c = accounts[1].Id
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[1].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1236'
//                 ),
//                 new PurchaseOrder__c(
//                     //BodyShop__c = accounts[1].Id
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[1].Id
//                     ,PrerequisiteOrder__c = prerequisiteOrders[0].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED
//                     ,BodyShopOrderNumber__c = '1235'
//                 ),
//                 new PurchaseOrder__c(
//                     Distributor__c= accounts[3].Id
//                     ,Assessment__c = assessments[1].Id
//                     ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                     ,BodyShopOrderNumber__c = '1234'
//                     ,SLADeliveryEntryDate__c = datetime.now()

//                 )
//             };

//             cs_CaseDetails = new list<CaseDetailsProcessMapping__c>{
//                 new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-Delayed',
//                     Short_Description__c = 'Case created when the Distributor indicates the delivery of some parts will be delayed.',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'DELIVERY',
//                     Subject__c = 'Action requise : Livraison retardée',
//                     Description__c = 'La livraison de certains éléments de cette commande est retardée. Cela peut poser problème.',
//                     Due_Date_Duration__c=2,
//                     Due_Date_Unity__c = 'H'
//                 ),
//                 new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-Canceled',
//                     Short_Description__c = 'Case created when the Distributor cancels a Purchase Offer after the Offering process.',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'DELIVERY',
//                     Subject__c = 'Action requise : Commande annulée après la création des offres',
//                     Description__c = 'Cette commande a été annulée par le Distributeur après la génération et la soumission des offres correspondantes au Bodyshop.',
//                     Due_Date_Duration__c=2,
//                     Due_Date_Unity__c = 'H'
//                 ),
//                 new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-Unsupplied',
//                     Short_Description__c = 'The distributor is not able to provide any parts',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'DELIVERY',
//                     Subject__c = 'Action requise : Aucune pièce disponible',
//                     Description__c = 'Le Disributeur a indiquer ne pouvoir livré aucune pièce de la commande.',
//                     Due_Date_Duration__c=2,
//                     Due_Date_Unity__c = 'H'
//                 ),
//                 new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-QuotationSLA2',
//                     Short_Description__c = 'Case created when the Purchase Order reaches the level 2 of the SLA Quotation.',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'DELIVERY',
//                     Subject__c = 'Achat Distributeur en attente de réponse',
//                     Description__c = 'LAchat Distributeur est en attente de réponse du distributeur. ',
//                     Due_Date_Duration__c=2,
//                     Due_Date_Unity__c = 'H'
//                 ),
//                  new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-NotValidated',
//                     Short_Description__c = 'Le montant du Purchase order est different du sales order.',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'INVOICING',
//                     Subject__c = 'Le montant est different.',
//                     Description__c = 'Le montant du Purchase order est different du sales order. ',
//                     Due_Date_Duration__c=2,
//                     Due_Date_Unity__c = 'H'
//                 ),
//                  new CaseDetailsProcessMapping__c(
//                      Name = 'FR-PO-ASMarginTooLow',
//                     Short_Description__c = 'Case created when at less one Order line of the Purchase Order has an AS Margin too low.',
//                     Origin__c = 'APPLICATION',
//                     Type__c = 'PROBLEM',
//                     Priority__c = 'MEDIUM',
//                     Reason__c = 'INVOICING',
//                     Subject__c = 'Prix ou remise inappropriée',
//                     Description__c = 'Au moins une des pieces de cette commande a un prix ou une remise inappropriée.',
//                     Due_Date_Duration__c=1,
//                     Due_Date_Unity__c = 'D'
//                 )
//             };

//             insert cs_CaseDetails;
//         }//end runAs
//     }//end method

//     /**/
//      static testMethod void purchaseOrdersOnBeforeAfterInsert_Test() {
//         system.debug('#### Start of method purchaseOrdersOnBeforeInsert_Test');

//         system.runAs(userAdmin){    



//             //purchase order
//             test.starttest();   
//                 //insert purchaseOrders;
//                 ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
//             test.stoptest();

//             //Before Insert
//             List<PurchaseOrder__c> purchaseOrdersAsserList = new List<PurchaseOrder__c>([select assessment__c
//                                                                                     ,SLAQuotationLevel1__c
//                                                                                     ,SLAQuotationLevel2__c
//                                                                                     ,SLAQuotationLevel3__c
//                                                                                     ,status__c
//                                                                                     ,distributor__c
//                                                                                     ,recordTypeId
//                                                                                     ,AssessmentName2__c
//                                                                                     ,AssessmentNumber__c
//                                                                                     ,VINNumber__c
//                                                                                     ,Brand__c   
//                                                                                     ,PlateNumber__c                                                                                        
//                                                                             from PurchaseOrder__c 
//                                                                             where Id IN: purchaseOrders and status__c=:ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//                                                                             order by Name]);
            
//             //system.debug('####purchaseOrdersAsserList'+purchaseOrdersAsserList);

//             //System.assertEquals(string.valueOf(datetime.now().addMinutes(15)).substringBeforeLast(':'), string.valueOf(purchaseOrdersAsserList[0].SLAQuotationLevel1__c).substringBeforeLast(':'));
//             //System.assertEquals(string.valueOf(datetime.now().addMinutes(25)).substringBeforeLast(':'), string.valueOf(purchaseOrdersAsserList[0].SLAQuotationLevel2__c).substringBeforeLast(':'));
//             //System.assertEquals(string.valueOf(datetime.now().addMinutes(60)).substringBeforeLast(':'), string.valueOf(purchaseOrdersAsserList[0].SLAQuotationLevel3__c).substringBeforeLast(':'));

//             System.assertNotEquals(null, purchaseOrdersAsserList[0].SLAQuotationLevel1__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[0].SLAQuotationLevel2__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[0].SLAQuotationLevel3__c);

//             System.assertNotEquals(null, purchaseOrdersAsserList[1].SLAQuotationLevel1__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[1].SLAQuotationLevel2__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[1].SLAQuotationLevel3__c);

//             System.assertNotEquals(null, purchaseOrdersAsserList[2].SLAQuotationLevel1__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[2].SLAQuotationLevel2__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[2].SLAQuotationLevel3__c);

//             system.assertEquals('SOURCED',[select Id,Status__c from Assessment__c where Id =:assessments[0].Id].Status__c);
            
//             // Check autopopulated fields on Purchase Orders            
//             Map<Id, Assessment__c> m_Ass = new Map<Id,Assessment__c>([SELECT id,Name,AssessmentNumber__c,VINNumber__c,PlateNumber2__c,Manufacturer__c FROM Assessment__c]);
//             for(PurchaseOrder__c po : purchaseOrdersAsserList){
//                 System.assertEquals(m_Ass.get(po.assessment__c).Name, po.AssessmentName2__c);
//                 System.assertEquals(m_Ass.get(po.assessment__c).AssessmentNumber__c, po.AssessmentNumber__c);
//                 System.assertEquals(m_Ass.get(po.assessment__c).VINNumber__c, po.VINNumber__c);
//                 System.assertEquals(m_Ass.get(po.assessment__c).Manufacturer__c, po.Brand__c);
//                 System.assertEquals(m_Ass.get(po.assessment__c).PlateNumber2__c, po.PlateNumber__c);
//             }

//             //After Insert

//             List<OrderLine__c> orderLineAsserList = new List<OrderLine__c>([select Id
//                                                                             from OrderLine__c 
//                                                                             where purchaseOrder__c IN: purchaseOrders]);
            
//             //system.debug('####orderLineAsserList'+orderLineAsserList);
//             System.assertEquals(6, orderLineAsserList.size());
//         }
//     }

   
//    static testMethod void purchaseOrdersOnBeforeUpdate_Test() {
//         system.debug('#### Start of method purchaseOrdersOnBeforeUpdate_Test');

//          system.runAs(userAdmin){    
//             //purchase order
//              insert purchaseOrders;

//             test.starttest();   
//                 purchaseOrders[0].status__c= ASPISConstants.PUR_ORDER_STATUS_ISSUED;
//                 purchaseOrders[0].SLAClosedEntryDate__c = datetime.Now()+4;
                
//                 purchaseOrders[1].status__c= ASPISConstants.PUR_ORDER_STATUS_ORDERED;
//                 purchaseOrders[1].SLAClosedEntryDate__c = datetime.Now()+3;
//                 purchaseOrders[1].SLAAcceptanceEntryDate__c = datetime.Now()+5;
                
//                 purchaseOrders[2].status__c= ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
//                 purchaseOrders[2].SLAClosedEntryDate__c = datetime.Now()+7;
//                 purchaseOrders[2].SLAOrderedEntryDate__c =  datetime.Now()+2;

//                 purchaseOrders[3].status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
//                 purchaseOrders[3].SLAClosedEntryDate__c = datetime.Now()+4;
//                 purchaseOrders[3].SLADeliveryEntryDate__c =  datetime.Now()+1;

//                 purchaseOrders[4].status__c = 'CANCELED' ;
//                 purchaseOrders[4].SLAQuotationEntryDate__c = datetime.Now()+4;
//                 purchaseOrders[4].SLAAcceptanceEntryDate__c = datetime.Now()+1;
//                 purchaseOrders[4].SLAOrderedEntryDate__c = datetime.Now()+2;
//                 purchaseOrders[4].SLADeliveryEntryDate__c = datetime.Now()+3;
                
//                 update purchaseOrders;
//             test.stoptest();


//             List<PurchaseOrder__c> purchaseOrdersAsserList = new List<PurchaseOrder__c>([select assessment__c
//                                                                                     ,SLAQuotationDuration__c
//                                                                                     ,SLAAcceptanceDuration__c
//                                                                                     ,SLAOrderedDuration__c
//                                                                                     ,SLADeliveryDuration__c
//                                                                                     ,SLAQuotationLevel1__c
//                                                                                     ,SLAQuotationLevel2__c
//                                                                                     ,SLAQuotationLevel3__c
//                                                                                     ,status__c
//                                                                                     ,distributor__c
//                                                                                     ,recordTypeId
//                                                                             from PurchaseOrder__c 
//                                                                             where Id IN: purchaseOrders
//                                                                             order by Name]);
            
//             //po[0]
//             System.assertNotEquals(null, purchaseOrdersAsserList[0].SLAQuotationDuration__c);
//             System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId(), purchaseOrdersAsserList[0].recordTypeId);
//             //po[1]
//             System.assertNotEquals(null, purchaseOrdersAsserList[1].SLAAcceptanceDuration__c);
//             System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Ordered').getRecordTypeId(), purchaseOrdersAsserList[1].recordTypeId);
//             //po[2]
//             System.assertNotEquals(null, purchaseOrdersAsserList[2].SLAOrderedDuration__c);
//             //po[3]
//             System.assertNotEquals(null, purchaseOrdersAsserList[3].SLADeliveryDuration__c);
//             //po[4]
//             System.assertNotEquals(null, purchaseOrdersAsserList[4].SLAQuotationDuration__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[4].SLAAcceptanceDuration__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[4].SLAOrderedDuration__c);
//             System.assertNotEquals(null, purchaseOrdersAsserList[4].SLADeliveryDuration__c);
        
//         }
//     }


//     static testMethod void purchaseOrdersOnAfterUpdate_Test() {
//         system.debug('#### Start of method purchaseOrdersOnAfterUpdate_Test');
//         insert purchaseOrders;

//         orderlines = new list<OrderLine__c>{
//             new OrderLine__c(
//                 PurchaseOrder__c= purchaseOrders[6].Id
//                 ,AcceptedCheck__c=true
//                 ,Quantity__c=5
//                 ,ExpectedDeliveryDuration__c = '1'
//             )
//         };
//         //insert orderlines;
//         ASPISTestUtils.generateOrderLine(orderlines);

//         invoices = new list<Invoice__c>{
//             new Invoice__c(PurchaseOrder__c=purchaseOrders[6].Id,
//                            RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
//                            Distributor__c = purchaseOrders[6].Distributor__c)
//         };
//         //insert invoices;
//         ASPISTestUtils.generateInvoice(invoices);

//         system.runAs(userAdmin){
//             test.starttest();   
//                 purchaseOrders[0].DelayedCaseCreated__c = true;
//                 purchaseOrders[0].PrerequisiteOrder__c = prerequisiteOrders[0].Id;
//                 purchaseOrders[1].ASMarginTooLowCaseCreated__c = true;
//                 purchaseOrders[1].PrerequisiteOrder__c = prerequisiteOrders[0].Id;
//                 purchaseOrders[5].status__c = 'CANCELED';
//                 ////****** ASE 13/10/15: C-001272*******purchaseOrders[4].status__c = 'UNSUPPLIEDQUOTE';
// 				purchaseOrders[4].status__c = 'REJECTED';
// 				purchaseOrders[4].reason__c = 'UNSUPPLIEDQUOTE';
//                 purchaseOrders[4].PrerequisiteOrder__c = prerequisiteOrders[0].Id;
//                 purchaseOrders[3].TECHSLAQuotationIsLevel2__c = true;
//                 purchaseOrders[2].InvoiceStatus__c = 'NOTVALIDATED';
//                 purchaseOrders[6].Status__c = 'INDELIVERY';
//                 purchaseOrders[6].InvoiceStatus__c = 'VALIDATED';

//                 update purchaseOrders;
//             test.stoptest();
           
//             List<Case__c> caseAssertList = new list<Case__c>([Select Id,Name 
//                                                         from Case__c 
//                                                         where Purchase_order__c IN:purchaseOrders]);

//             //system.debug('caseAssertList:'+caseAssertList.Size());
            
//             list<OrderLine__c>orderLineAssertList = new list<OrderLine__c>([select Id,DeliveryStatus__c 
//                                                                             from OrderLine__c 
//                                                                             where Id =: orderlines[0].Id ]);

//             //system.debug('orderLineAssertList:'+orderLineAssertList);

//             list<Invoice__c>invoiceAssertList = new list<Invoice__c>([select Id,Status__c 
//                                                                             from Invoice__c 
//                                                                             where Id =: invoices[0].Id ]);

//             //system.debug('invoiceAssertList:'+invoiceAssertList);
            
//             System.assertEquals('INDELIVERY', orderLineAssertList[0].DeliveryStatus__c);
//             System.assertEquals('PAYABLE', invoiceAssertList[0].Status__c);

//         }
//     }

}