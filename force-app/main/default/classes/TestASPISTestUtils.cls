/*************************************************************************************
Class Name - TestASPISTestUtils 
Version - 1.0
Created Date - 18 MAY 2015
Function - Test Class for ASPISTestUtils

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Dourga(SC)   18/05/2015   Original Version
*************************************************************************************/
@isTest
private class TestASPISTestUtils {
// ABT 02-DEC-2016 - C-001625
/*
    static User userAdmin;
    static list <User> users;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;
    static list <Account> accounts;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Assessment__c> assessments;
    static list<OrderLine__c> orderLines;
    static list<PartList__c> partLists;
    static list<Offer__c> offers;
    static list<Invoice__c> invoices;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();
    static BusinessHours defaultHours;
    static SLAConfiguration__c slaRecord;
    static date myDate;
    static datetime myDateTime;


    static{

        userAdmin = new User(Username = 'jk@test.com',
                             LastName = 'Jack',
                             FirstName = 'Kurry',
                             Email = 'KurryJack@test.com',
                             Alias = 'KJac',
                             LanguageLocaleKey = 'en_US',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = ASPISConstants.getProfileAdminId()); 
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        users = new list<User>{ new User(Username = 'jb@test22t.com',
                                           FirstName = 'Jean',
                                           LastName = 'Ballack',
                                           Email = 'j.best22t@test.com',
                                           Alias = 'fdss',
                                           LanguageLocaleKey = 'en_US',
                                           TimeZoneSidKey = 'Europe/Dublin',
                                           LocaleSidKey = 'en_US',
                                           EmailEncodingKey = 'UTF-8',
                                           ProfileId = ASPISConstants.getProfileAdminId()),
                                new User(Username = 'Stest44pot.com',
                                           FirstName = 'Tusse',
                                           LastName = 'Sally',
                                           Email = 'St.est44pot@test.com',
                                           Alias = 'stgg',
                                           LanguageLocaleKey = 'en_US',
                                           TimeZoneSidKey = 'Europe/Dublin',
                                           LocaleSidKey = 'en_US',
                                           EmailEncodingKey = 'UTF-8',
                                           ProfileId = ASPISConstants.getProfileAdminId())
        }; 

        masterRuleList = new list <MasterRules__c>{new MasterRules__c(//Process__c = 'Offering' , 
                                                                        Country__c = 'SPAIN',
                                                                        Entity__c = 'AXA Direct'),

                                                   new MasterRules__c(//Process__c = 'Orders' , 
                                                                      Entity__c = 'AXA Direct',
                                                                      Version__c = 1)
        };
        

        defaultHours = [select Id from BusinessHours where IsDefault=true];

        myDateTime = datetime.newInstance(2015, 2, 17);
        myDate = date.newInstance(2015, 2, 17);


        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);   

        accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                         RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                         ReferenceNumber__c = '123',
                                                         ContactEmail__c = 'bt1@gmail.com',
												         LowKeepDiscountforAParts__c = 10
                                 ,VAT__c = 15),

                                        new Account(Name='BodyShop_ScTest2',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                        ReferenceNumber__c = '1234',
                                                        ContactEmail__c = 'bt2@gmail.com'
                                                        ,VAT__c = 15),

                                        new Account(Name='Distributor_ScTest1',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                        ReferenceNumber__c = '123457',
                                                        ContactEmail__c = 'dt1@gmail.com'
                                                        ,VAT__c = 15),

                                        new Account(Name='Distributor_ScTest2',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                        ReferenceNumber__c = '123456',
                                                        ContactEmail__c = 'dt1@gmail.com'
                                                        ,VAT__c = 15)
        };


        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001', 
                                                               AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                               BodyShop__c = accounts[0].Id,
                                                               Entity__c = 'AXA Direct',
                                                               MissionNumber__c = '01',
                                                               PortfolioAgentCode__c = '355',
                                                               AssessmentID__c = '0912',
                                                               TechExternalId__c = '233'),
                                                
                                               new Assessment__c(Name='ASSESS_TEST-0002',
                                                                 AssessmentNumber__c = 'ASSESS_TEST-0002',
                                                                 BodyShop__c = accounts[0].Id,
                                                                 Entity__c = 'AXA Direct1',
                                                                 MissionNumber__c = '02',
                                                                 PortfolioAgentCode__c = '3545',
                                                                 AssessmentID__c = '5912')
                
        };
             

    }

    static testMethod void TestCreateAssessmentByWebservice(){
        system.Debug('>>> Start TestCreateAssessmentByWebservice');
        system.runAs(userAdmin){    
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                String jsonStr = '[{"AssessmentNumber":"JSA TEST V 2","TransactionID":"ID01","Entity":"AXA Direct","MissionNumber":"0000012","Name":"JSA TEST V 2","PortfolioAgentCode":"Code123","Status":"New","Parts":[{"Description":"R/ELECTRIC FAN","GuideNo":7794,"HeldDate":"2015-04-13","Name":"R/ELECTRIC FAN","PartNumber":"16361 28360","PartNumberOptimized":"None","Price":114,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"RADIATOR SHROUD","GuideNo":7767,"HeldDate":"2015-04-13","Name":"RADIATOR SHROUD","PartNumber":"16711 37040","PartNumberOptimized":"None","Price":92,"PriceOptimized":0,"Quantity":2,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47031","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 2","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"Travel","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"TOYOTA","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Name":"Asset mock001","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None"},"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"MIDAS Levallois","OrderEmail":"test@test.com","ReferenceNumber":"Auto-MIDAS-001","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"},"currentClaim":{"AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Authorised","ClaimReference":"2064150","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","Name":"Claim 2064150","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial"}}]';
                ASPISTestUtils.createAssessmentViaWebServiceV2(jsonStr);
            test.stoptest();
            system.assertEquals([select AssessmentNumber__c from Assessment__c where AssessmentNumber__c = 'JSA TEST V 2'].size(),1);
        }
        system.Debug('>>> End TestCreateAssessmentByWebservice');
    }

    static testMethod void TestgenerateBasicTestData() {
        System.Debug('>>> Start TestgenerateBasicTestData');

        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateBasicTestData();
            test.stoptest(); 
        }
        system.assertEquals([select Entity__c from MasterRules__c where Entity__c = 'AXA Direct'].size(),2);
        System.Debug('>>> End TestgenerateBasicTestData');
    }
    
    // static testMethod void TestgenerateTestUsers() {
    //     System.Debug('>>> Start TestgenerateTestUsers');

    //     system.runAs(userAdmin){    
    //         test.starttest();
    //             insert users;
    //         test.stoptest(); 
    //     }
    //     system.assert([select ProfileId from User where ProfileId =: ASPISConstants.getProfileAdminId()].size() > 0);
    //     System.Debug('>>> End TestgenerateTestUsers');
    // }

    static testMethod void TestgenerateTestUser() {
        System.Debug('>>> Start TestgenerateTestUser');

        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateTestUser(users[0]);
            test.stoptest(); 
        }
        system.assertEquals([select FirstName from User where FirstName = 'Jean'].size(),1);
        System.Debug('>>> End TestgenerateTestUser');
    }

    static testMethod void TestgenerateAccount() {
        System.Debug('>>> Start TestgenerateAccount');

        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateAccount(accounts);
            test.stoptest(); 
        }
        system.assertEquals([select Id from Account where Id != null].size(),4);
        System.Debug('>>> End TestgenerateAccount');
    }

    static testMethod void TestgenerateMasterRules() {
        System.Debug('>>> Start TestgenerateMasterRules');

        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateMasterRules(masterRuleList);
            test.stoptest(); 
        }
        system.assertEquals([select Entity__c from MasterRules__c where Entity__c = 'AXA Direct'].size(),2);
        System.Debug('>>> End TestgenerateMasterRules');
    }

    static testMethod void TestgenerateDetailRule() {
        System.Debug('>>> Start TestgenerateDetailRule');

        system.runAs(userAdmin){
            insert masterRuleList;
            detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 1 ,sObject__c = 'OrderLine__c', FieldsAPI__c = 'BodyShopPrice__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 2 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Description__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 3 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Type__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'PurchaseOrder__c', Operator__c = 'GREATER_EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[1].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Suppliable__c', Operator__c = 'CONTAINS')
            };
            //ASPISTestUtils.generateMasterRules(masterRuleList);   
            test.starttest();
                ASPISTestUtils.generateDetailRule(detailRuleList);
            test.stoptest(); 
        }
        system.assertEquals([select Process__c from DetailRule__c where Process__c = 'Offering'].size(),6);
        System.Debug('>>> End TestgenerateDetailRule');
    }


    static testMethod void TestgeneratePurchaseOrder() {
        System.Debug('>>> Start TestgeneratePurchaseOrder');
        Account acc = new Account(Name='Distributor_ScTest1',
                                    RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                    ReferenceNumber__c = '12345',
                                    ContactEmail__c = 'dt1@gmail.com'
                                    ,VAT__c = 15);
        insert acc;
        slaRecord= new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id ,
                                              Name='QuotationAXADirect' ,
                                              SLALevel1Minute__c=30 ,
                                              SLALevel2Minute__c=60 ,
                                              SLALevel3Minute__c=90 ,
                                              Entity__c= 'AXA Direct' ,
                                              Object__c = 'Purchase Order');
        insert slaRecord;
        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = acc.Id,
                                                                          ValidityDate__c=date.today(), 
                                                                          Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                          
                                                                          SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                          SLAQuotationLevel2__c = myDateTime,
                                                                          SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                          TECHSLAQuotationIsLevel1__c = false,
                                                                          TECHSLAQuotationIsLevel2__c = false,
                                                                          TECHSLAQuotationIsLevel3__c = false),

                                                new PurchaseOrder__c(Distributor__c = acc.Id,
                                                                     ValidityDate__c=date.today(),
                                                                     Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED,
                                                                    
                                                                     SLAQuotationLevel1__c = (datetime.now()).addDays(2),
                                                                     SLAQuotationLevel2__c = (datetime.now()).addDays(3),
                                                                     SLAQuotationLevel3__c = (datetime.now()).addDays(5),
                                                                     TECHSLAQuotationIsLevel1__c = false,
                                                                     TECHSLAQuotationIsLevel2__c = false,
                                                                     TECHSLAQuotationIsLevel3__c = false)
        };
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
            test.stoptest(); 
        }
        system.assertEquals([select Distributor__c from PurchaseOrder__c where Distributor__c =: acc.Id].size(),2);
        System.Debug('>>> End TestgeneratePurchaseOrder');
    }

    static testMethod void TestgeneratePrerequisiteOrder() {
        System.Debug('>>> Start TestgeneratePrerequisiteOrder');

        Account acc = new Account(Name='BodyShop_ScTest1',
                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                 ReferenceNumber__c = '123',
                                 ContactEmail__c = 'bt1@gmail.com'
                                 ,VAT__c = 15);
        insert acc;
        
        Assessment__c assessment = new Assessment__c(Name='ASSESS_TEST-0001',
                                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                       BodyShop__c = acc.Id,
                                                       Entity__c = 'AXA Direct',
                                                       MissionNumber__c = '01',
                                                       PortfolioAgentCode__c = '355',
                                                       AssessmentID__c = '0912',
                                                       TechExternalId__c = '233');
        insert assessment;
        prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = acc.Id,
                                                                                    Assessment__c = assessment.Id,
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)),
                                                    
                                                           new PrerequisiteOrder__c(BodyShop__c = acc.Id,
                                                                                    Assessment__c = assessment.Id,
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
        };
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generatePrerequisiteOrder(prerequisiteOrders);
            test.stoptest(); 
        }
        system.assertEquals([select BodyShop__c from PrerequisiteOrder__c where BodyShop__c =: acc.Id].size(),2);
        System.Debug('>>> End TestgeneratePrerequisiteOrder');
    }

    static testMethod void TestgenerateAssessment() {
        System.Debug('>>> Start TestgenerateAssessment');

        Account acc = new Account(Name='BodyShop_ScTest1',
                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                 ReferenceNumber__c = '123',
                                 ContactEmail__c = 'bt1@gmail.com'
                                 ,VAT__c= 10);
        insert acc;
        
        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
                                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                       BodyShop__c = acc.Id,
                                                       Entity__c = 'AXA Direct',
                                                       MissionNumber__c = '01',
                                                       PortfolioAgentCode__c = '355',
                                                       AssessmentID__c = '0912',
                                                       TechExternalId__c = '233')};
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateAssessment(assessments);
            test.stoptest(); 
        }
        system.assertEquals([select Name from Assessment__c where Name='ASSESS_TEST-0001'].size(),0);
        System.Debug('>>> End TestAssessment');
    }

    static testMethod void TestgenerateOrderLine() {
        System.Debug('>>> Start TestgenerateOrderLine');
        Account acc = new Account(Name='Distributor_ScTest1',
                                    RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                    ReferenceNumber__c = '12345',
                                    ContactEmail__c = 'dt1@gmail.com',
								    ReferentialASforAParts__c = 25
                    ,VAT__c = 15);
		
        insert acc;
		
		accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                         RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                         ReferenceNumber__c = '123',
                                                         ContactEmail__c = 'bt1@gmail.com',
												         LowKeepDiscountforAParts__c = 10
                                 ,VAT__c = 15),

                                        new Account(Name='BodyShop_ScTest2',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                        ReferenceNumber__c = '1234',
                                                        ContactEmail__c = 'bt2@gmail.com'
                                                        ,VAT__c = 15),

                                        new Account(Name='Distributor_ScTest1',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                        ReferenceNumber__c = '123457',
                                                        ContactEmail__c = 'dt1@gmail.com'
                                                        ,VAT__c = 15),

                                        new Account(Name='Distributor_ScTest2',
                                                        RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                        ReferenceNumber__c = '123456',
                                                        ContactEmail__c = 'dt1@gmail.com'
                                                        ,VAT__c = 15)
        };

		insert accounts;

        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001', 
                                                               AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                               BodyShop__c = accounts[0].Id,
                                                               Entity__c = 'AXA Direct',
                                                               MissionNumber__c = '01',
                                                               PortfolioAgentCode__c = '355',
                                                               AssessmentID__c = '0912',
                                                               TechExternalId__c = '233'),
                                                
                                               new Assessment__c(Name='ASSESS_TEST-0002',
                                                                 AssessmentNumber__c = 'ASSESS_TEST-0002',
                                                                 BodyShop__c = accounts[0].Id,
                                                                 Entity__c = 'AXA Direct1',
                                                                 MissionNumber__c = '02',
                                                                 PortfolioAgentCode__c = '3545',
                                                                 AssessmentID__c = '5912')
                
        };
		
		
		insert assessments;
		
		accounts[0].LowKeepDiscountforAParts__c = 10;
		update accounts[0];
		
        slaRecord= new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id ,
                                              Name='QuotationAXADirect' ,
                                              SLALevel1Minute__c=30 ,
                                              SLALevel2Minute__c=60 ,
                                              SLALevel3Minute__c=90 ,
                                              Entity__c= 'AXA Direct' ,
                                              Object__c = 'Purchase Order');
        insert slaRecord;
        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = acc.Id,
                                                                          ValidityDate__c=date.today(), 
                                                                          Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                          Assessment__c = assessments[0].id,
                                                                          SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                          SLAQuotationLevel2__c = myDateTime,
                                                                          SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                          TECHSLAQuotationIsLevel1__c = false,
                                                                          TECHSLAQuotationIsLevel2__c = false,
                                                                          BodyShopOrderNumber__c = '4846',
                                                                          TECHSLAQuotationIsLevel3__c = false),

                                                new PurchaseOrder__c(Distributor__c = acc.Id,
                                                                     ValidityDate__c=date.today(),
                                                                     Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED,
                                                                     Assessment__c = assessments[0].id,
																	 SLAQuotationLevel1__c = (datetime.now()).addDays(2),
                                                                     SLAQuotationLevel2__c = (datetime.now()).addDays(3),
                                                                     SLAQuotationLevel3__c = (datetime.now()).addDays(5),
                                                                     TECHSLAQuotationIsLevel1__c = false,
                                                                     TECHSLAQuotationIsLevel2__c = false,
                                                                     BodyShopOrderNumber__c = '4846',
                                                                     TECHSLAQuotationIsLevel3__c = false)
        };
        insert purchaseOrders;
        orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id)};
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateOrderLine(orderLines);
            test.stoptest(); 
        }
        system.assertEquals([select PurchaseOrder__c from OrderLine__c where PurchaseOrder__c =: purchaseOrders[0].Id].size(),1);
        System.Debug('>>> End TestgenerateOrderLine');
    }

    static testMethod void TestgenerateOffer() {
        System.Debug('>>> Start TestgenerateOffer');

        
        Account acc = new Account(Name='BodyShop_ScTest1',
                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                 ReferenceNumber__c = '123',
                                 ContactEmail__c = 'bt1@gmail.com'
                                 ,VAT__c = 15);
        insert acc;
        
        Assessment__c assessment = new Assessment__c(Name='ASSESS_TEST-0001',
                                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                       BodyShop__c = acc.Id,
                                                       Entity__c = 'AXA Direct',
                                                       MissionNumber__c = '01',
                                                       PortfolioAgentCode__c = '355',
                                                       AssessmentID__c = '0912',
                                                       TechExternalId__c = '233');
        insert assessment;
        prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = acc.Id,
                                                                                    Assessment__c = assessment.Id,
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)),
                                                    
                                                           new PrerequisiteOrder__c(BodyShop__c = acc.Id,
                                                                                    Assessment__c = assessment.Id,
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
        };
        insert prerequisiteOrders;

        offers = new list<Offer__c>{new Offer__c(Prerequisiteorder__c = prerequisiteOrders[0].Id)};
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateOffer(offers);
            test.stoptest(); 
        }
        system.assertEquals([select Prerequisiteorder__c from Offer__c where Prerequisiteorder__c =: prerequisiteOrders[0].Id].size(),1);
        System.Debug('>>> End TestgenerateOffer');
    }
    static testMethod void TestgeneratePartList() {
        System.Debug('>>> Start TestgeneratePartList');

        Account acc = new Account(Name='BodyShop_ScTest1',
                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                 ReferenceNumber__c = '123',
                                 ContactEmail__c = 'bt1@gmail.com'
                                 ,VAT__c = 15);
        insert acc;
        
        Assessment__c assessment = new Assessment__c(Name='ASSESS_TEST-0001', 
                                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                       BodyShop__c = acc.Id,
                                                       Entity__c = 'AXA Direct',
                                                       MissionNumber__c = '01',
                                                       PortfolioAgentCode__c = '355',
                                                       AssessmentID__c = '0912',
                                                       TechExternalId__c = '233');
        insert assessment;
        partLists = new list<PartList__c>{new PartList__c(Assessment__c = assessment.Id,
                                                          Name = 'FRONT LWR AIR GRILLE',
                                                          PartNumber__c = '53102 47020',
                                                          HeldDate__c = myDate,
                                                          Price__c = 68,
                                                          Quantity__c = 1)};
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generatePartList(partLists);
            test.stoptest(); 
        }
        system.assertEquals([select Assessment__c from PartList__c where Assessment__c =: assessment.Id].size(),1);
        System.Debug('>>> End TestgeneratePartList');
    }
    static testMethod void TestgenerateInvoice() {
        System.Debug('>>> Start TestgenerateInvoice');

        
        Account acc = new Account(Name='BodyShop_ScTest1',
                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                 ReferenceNumber__c = '123',
                                 ContactEmail__c = 'bt1@gmail.com'
                                 ,VAT__c = 15);
        insert acc;
        
        Assessment__c assessment = new Assessment__c(Name='ASSESS_TEST-0001',
                                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                       BodyShop__c = acc.Id,
                                                       Entity__c = 'AXA Direct',
                                                       MissionNumber__c = '01',
                                                       PortfolioAgentCode__c = '355',
                                                       AssessmentID__c = '0912',
                                                       TechExternalId__c = '233');
        insert assessment;
        

        PrerequisiteOrder__c salesOrder1 = new PrerequisiteOrder__c(BodyShop__c = acc.Id,
                                                Assessment__c = assessment.Id,
                                                RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance));
        insert salesOrder1;
        
        invoices = new list<Invoice__c>{new Invoice__c(Assessment__c = assessment.Id,
                                                        BodyShop__c = acc.Id,
                                                        PrerequisiteOrder__c = salesOrder1.Id,
                                                        Date__c = system.today())
        };
        system.runAs(userAdmin){    
            test.starttest();
                ASPISTestUtils.generateInvoice(invoices);
            test.stoptest(); 
        }
        system.assertEquals([select Assessment__c from Invoice__c where Assessment__c =: assessment.Id].size(),1);
        System.Debug('>>> End TestgenerateInvoice');
    }*/
}