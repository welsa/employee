/*************************************************************************************
Class Name - ASPISTestUtils 
Version - 1.0   
Created Date - 14 MAY 2015
Function - Class for test data 

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole         14/05/2015  Original Version
* Shamina M             17/02/2016  C-001518: Removed unnecessary debug logs
*************************************************************************************/
public without sharing class ASPISTestUtils {
    // ABT 02-DEC-2016 - C-001625
/*
    public static list <User> users;
    public static list <DetailRule__c> detailRuleList;
    public static list <MasterRules__c> masterRuleList;
    public static list <Account> accounts;
    public static list<PurchaseOrder__c> purchaseOrders;
    public static list<Assessment__c> assessments;
    public static list<PartList__c> partLists;
    public static list<Invoice__c> invoices;
    public static list<PrerequisiteOrder__c> prerequisiteOrders;
    public static map <String,Id> accRecordTypeMap = new map <String,Id>();
    public static map <String,Id> proRecordTypeMap = new map <String,Id>();
    public static BusinessHours defaultHours;
    public static SLAConfiguration__c slaRecord;
    public static date myDate;
    public static datetime myDateTime;

    //version2
    //String jsonStr = '[{"AssessmentNumber":"scAssessment","TransactionID":"TransactionID1","Entity":"AXA Direct","MissionNumber":"0000012","Name":"AI360505","PortfolioAgentCode":"Code123","ExpertValidationDate":"2015-04-13","Status":"New","BrakesPedalTravel":"Asset 001","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"Toyota","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None","AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Authorised","ClaimReference":"240288","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial","Parts":[{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"2402","PartNumberOptimized":"None","Price":68,"PriceOptimized":0,"Quantity":10,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"2403","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20},{"Description":"DescNew","GuideNo":2531,"HeldDate":"2015-04-15","Name":"FRONT LWR AIR GRILLE1","PartNumber":"2404","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20},{"Description":"DescNew1","GuideNo":25311,"HeldDate":"2015-04-17","Name":"FRONT LWR AIR GRILLE11","PartNumber":"2405","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20}],"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"MIDAS Levallois","OrderEmail":"test@test.com","ReferenceNumber":"scBodyShop","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"}}]';
    public static void createAssessmentViaWebServiceV2(String jsonStub){
        Restrequest req = new Restrequest();
        Restresponse res = new Restresponse();
        req.httpMethod = 'POST';
        req.requestURI = '/v2.0/createAssessment/'; 
        req.requestBody = blob.valueOf(jsonStub); 
        RestContext.request = req;
        RestContext.response = res;
        RESTCreateAssessment_V2.createNewAssessment();
        //String responseOut = RESTCreateAssessment_V2.createNewAssessment();
    }

    public static void generateTestUser(User u){
        //system.debug('## create user as ' + userInfo.getName());
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        if(String.isBlank(u.email)) u.email = u.FirstName + '.' + u.LastName + '@axa.dev';
        if(String.isBlank(u.profileid)) u.ProfileId = UserInfo.getProfileId();
        u.UserName = uniqueName + '@test' + orgId + '.org';
        if(String.isBlank(u.Alias)) u.Alias = 'TST1';
        if(String.isBlank(u.TimeZoneSidKey)) u.TimeZoneSidKey = 'Europe/Dublin';
        if(String.isBlank(u.EmailEncodingKey)) u.EmailEncodingKey = 'UTF-8';
        if(String.isBlank(u.LocaleSidKey)) u.LocaleSidKey = 'en_US';
        if(String.isBlank(u.LanguageLocaleKey)) u.LanguageLocaleKey = 'en_US';
                                  
        insert u;
    }
    
    public static void generateTestUsers(List<User> usersList){
        //system.debug('## create users as ' + userInfo.getName());
        for(integer i=0;i<usersList.size();i++){
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;                
            if(String.isBlank(usersList[i].email)) usersList[i].email = i + usersList[i].FirstName + '.' + usersList[i].LastName + '@axa.dev';
            if(String.isBlank(usersList[i].profileid)) usersList[i].ProfileId = UserInfo.getProfileId();
            usersList[i].UserName = i + uniqueName + '@test' + orgId + '.org';
            if(String.isBlank(usersList[i].Alias)) usersList[i].Alias = i + 'TST1';
            if(String.isBlank(usersList[i].TimeZoneSidKey)) usersList[i].TimeZoneSidKey = 'Europe/Dublin';
            if(String.isBlank(usersList[i].EmailEncodingKey)) usersList[i].EmailEncodingKey = 'UTF-8';
            if(String.isBlank(usersList[i].LocaleSidKey)) usersList[i].LocaleSidKey = 'en_US';
            if(String.isBlank(usersList[i].LanguageLocaleKey)) usersList[i].LanguageLocaleKey = 'en_US';     
        }//
        insert usersList;
    }
    
    public static void generateAccount(list<Account> listAcc){
          //system.debug('## create Account ' + userInfo.getName());
          
          for(integer i=0;i<listAcc.size();i++){
              String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
              String randStr = '';
              while (randStr.length() < 6) {
                 Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
                 randStr += charsForRandom.substring(idx, idx+1);
              }

              if(String.isBlank(listAcc[i].Name)) listAcc[i].Name = 'Name' + i;
              listAcc[i].ReferenceNumber__c = i + '96' + randStr;
              listAcc[i].VAT__c = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
              if(String.isBlank(listAcc[i].ContactEmail__c)) listAcc[i].ContactEmail__c =  i + listAcc[i].Name + '@axa.dev';
              //if(String.isBlank(listAcc[i].ShippingCountryCode)) listAcc[i].ShippingCountryCode = 'FR';
          }
          insert  listAcc;
    } 
    
    public static void generateMasterRules(list<MasterRules__c> listMasterRules){
          //system.debug('## create MasterRules ' + userInfo.getName());
          
          for(integer i=0;i<listMasterRules.size();i++){
              String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
              String randStr = '';
              while (randStr.length() < 6) {
                 Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
                 randStr += charsForRandom.substring(idx, idx+1);
              }
              listMasterRules[i].RuleUnicityHandler__c = randStr+i;
              listMasterRules[i].ExternalID__c = randStr + i;
              if(String.isBlank(listMasterRules[i].Process__c)) listMasterRules[i].Process__c = 'Process' + i;
              if(String.isBlank(listMasterRules[i].Entity__c)) listMasterRules[i].Entity__c = 'AXA Direct';
          }
          insert  listMasterRules; 
    } 
    
    public static void generateDetailRule(list<DetailRule__c> listDetailRule){
          //system.debug('## create DetailRules ' + userInfo.getName());
          
          for(integer i=0;i<listDetailRule.size();i++){
              if(String.isBlank(listDetailRule[i].Process__c)) listDetailRule[i].Process__c = 'Process';
          }
          insert  listDetailRule;
    } 

    public static void generateAssessment(list<Assessment__c> listAssessment){
          //system.debug('## create Assessment ' + userInfo.getName()); 

          for(integer i=0;i<listAssessment.size();i++){
              String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
              String randStr = '';
              while (randStr.length() < 6) {
                 Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
                 randStr += charsForRandom.substring(idx, idx+1);
              }
              listAssessment[i].Name = 'ASSESS_TEST-0001' + randStr + i;
              listAssessment[i].AssessmentNumber__c = randStr +'ASSESS-0001' + i;
              listAssessment[i].Entity__c = 'AXA Direct';
              listAssessment[i].MissionNumber__c = randStr +'01' + i;
              listAssessment[i].PortfolioAgentCode__c = randStr +'35' + i;
              listAssessment[i].AssessmentID__c = '159' + i + randStr;
              listAssessment[i].TechExternalId__c = i +'233'+ randStr + i;
          }
          insert  listAssessment;
    }
    
    public static void generatePurchaseOrder(list<PurchaseOrder__c> listPurchaseOrder){
          //system.debug('## create PurchaseOrder ' + userInfo.getName());
          
          for(integer i=0;i<listPurchaseOrder.size();i++){
              listPurchaseOrder[i].BodyShopOrderNumber__c = '3';
          }
          insert  listPurchaseOrder; 
    } 
    
    public static void generatePrerequisiteOrder(list<PrerequisiteOrder__c> listPrerequisiteOrder){
          //system.debug('## create PrerequisiteOrder ' + userInfo.getName());
          
          for(integer i=0;i<listPrerequisiteOrder.size();i++){
              //if there are rules add them here
          }
          insert  listPrerequisiteOrder;
    } 
    
    public static void generateOrderLine(list<OrderLine__c> listOrderLine){
          //system.debug('## create OrderLine ' + userInfo.getName());
          
          for(integer i=0;i<listOrderLine.size();i++){
              //if there are rules add them here
              if((listOrderLine[i].Quantity__c) == null || (listOrderLine[i].Quantity__c) == 0) listOrderLine[i].Quantity__c =  i+1;
              if(String.isBlank(listOrderLine[i].PartNumber__c)) listOrderLine[i].PartNumber__c = '53102 470' + i;
          }
          insert  listOrderLine;
    } 
    
    public static void generateOffer(list<Offer__c> listOffer){
          //system.debug('## create Offer ' + userInfo.getName());
          
          for(integer i=0;i<listOffer.size();i++){
              //if there are rules add them here
          }
          insert  listOffer;
    } 
    
    public static void generatePartList(list<PartList__c> listPartList){
         // system.debug('## create PartList ' + userInfo.getName());
          
          for(integer i=0;i<listPartList.size();i++){
              if(String.isBlank(listPartList[i].Name)) listPartList[i].Name = 'FRONT LWR AIR GRILLE' + i;
              if(String.isBlank(listPartList[i].PartNumber__c)) listPartList[i].PartNumber__c = '53102 470' + i;
              if((listPartList[i].HeldDate__c) == null) listPartList[i].HeldDate__c = System.today();
              if((listPartList[i].Price__c) == null) listPartList[i].Price__c =  i;
              if((listPartList[i].Quantity__c) == null) listPartList[i].Quantity__c = i;
          }
          insert  listPartList;
    } 
    
    public static void generateInvoice(list<Invoice__c> listInvoice){
         // system.debug('## create Invoice ' + userInfo.getName());
          
          for(integer i=0;i<listInvoice.size();i++){
              if((listInvoice[i].Date__c) == null) listInvoice[i].Date__c = System.today();
          }
          insert  listInvoice;
    } 

    public static void generateCase(list<Case__c> listCases){
          //system.debug('## create Case ' + userInfo.getName());
          
          for(integer i=0;i<listCases.size();i++){
              if((listCases[i].Effort_in_man_days__c) == null) listCases[i].Effort_in_man_days__c = 2;
              if((listCases[i].Subject__c) == null) listCases[i].Subject__c = 'subTest' + i;
          }
          insert  listCases;
    }
    public static void generateBasicTestData(){
        users = new list<User>{ new User(Username = 'jb@test.com',
                                         LastName = 'Ballack',
                                         FirstName = 'Jean',
                                         Email = 'Jean@test.com',
                                         Alias = 'JBAL',
                                         LanguageLocaleKey = 'en_US',
                                         TimeZoneSidKey = 'Europe/Dublin',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
                                         ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        //insert users; 
        generateTestUsers(users);
        masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Offering' , 
                                                                      Entity__c = 'AXA Direct'),

                                                 new MasterRules__c(Process__c = 'Orders' , 
                                                                    Entity__c = 'AXA Direct',
                                                                    Version__c = 1)
        };
        //Insert masterRuleList;  
        generateMasterRules(masterRuleList);

        detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                    Process__c = 'Offering', 
                                                                    sObject__c = 'OrderLine__c', 
                                                                    FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                    Operator__c = 'EQUALS'),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                    Process__c = 'Offering', 
                                                                    sObject__c = 'OrderLine__c', 
                                                                    FieldsAPI__c = 'Name', 
                                                                    Operator__c = 'EQUALS'),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                    Process__c = 'Offering', 
                                                                    sObject__c = 'OrderLine__c', 
                                                                    FieldsAPI__c = 'AXAPrice__c', 
                                                                    Operator__c = 'EQUALS'),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                    Process__c = 'Offering', 
                                                                    sObject__c = 'OrderLine__c', 
                                                                    FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                    Operator__c = 'EQUALS'),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                    Process__c = 'Offering', 
                                                                    sObject__c = 'OrderLine__c', 
                                                                    FieldsAPI__c = 'Id', 
                                                                    Operator__c = 'EQUALS')
        };
        // insert detailRuleList; 
        generateDetailRule(detailRuleList);

        defaultHours = [select Id from BusinessHours where IsDefault=true];

        myDateTime = datetime.newInstance(2015, 2, 17);
        myDate = date.newInstance(2015, 2, 17);

        slaRecord= new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id ,
                                            Name='QuotationAXADirect' ,
                                            SLALevel1Minute__c=30 ,
                                            SLALevel2Minute__c=60 ,
                                            SLALevel3Minute__c=90 ,
                                            Entity__c= 'AXA Direct' ,
                                            Object__c = 'Purchase Order');
        insert slaRecord;

        GlobalVariables__c gVariable = new GlobalVariables__c(name='BatchOffering', Object__c='Assessment__c', Type__c='Constant', Value__c='2');
        insert gVariable;

        InvoiceMargin__c inv = new InvoiceMargin__c(Name='FR', CountryCode__c='FR', ValidationMargin__c=1);
        insert inv;

          accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

          
        // add some random string to account names to avoid UNABLE_TO_LOCK_ROW problem, I Salo
        String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 6) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
           randStr += charsForRandom.substring(idx, idx+1);
        }



        
        accounts = new list<Account>{new Account(Name='BodyShop_ScTest'+randStr+'1',
                                                 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                 ReferenceNumber__c = '123',
                                                 ContactEmail__c = 'bt1@gmail.com',
                                                 ShippingCountryCode = 'FR',
                                                 ReferentialASforAParts__c = 20,
                                                 ReferentialASforBCParts__c = 25,
                                                 LowKeepDiscountforAParts__c = 10,
                                                 VAT__c= 10),

                                    new Account(Name='BodyShop_ScTest'+randStr+'2',
                                                RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                ReferenceNumber__c = '1234',
                                                ContactEmail__c = 'bt2@gmail.com',
                                                ShippingCountryCode = 'FR',
                                                LowKeepDiscountforAParts__c = 10,
                                                VAT__c= 10),

                                    new Account(Name='Distributor_ScTest'+randStr+'1',
                                                RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                ReferenceNumber__c = '12345',
                                                ContactEmail__c = 'dt1@gmail.com', 
                                                DistributorNextInvoiceDate__c = date.today(),
                                                DistributorInvoicePeriod__c = '15',
                                                Categories__c='A',
                                                ReferentialASforAParts__c = 20,
                                                ShippingCountryCode = 'FR',
                                                VAT__c= 10),

                                    new Account(Name='Distributor_ScTest'+randStr+'2',
                                                RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                ReferenceNumber__c = '123456',
                                                ContactEmail__c = 'dt1@gmail.com', 
                                                DistributorNextInvoiceDate__c = date.today(),
                                                DistributorInvoicePeriod__c = '15',
                                                Categories__c='A',
                                                ReferentialASforAParts__c = 20,
                                                ShippingCountryCode = 'FR',
                                                VAT__c= 10)
        };
        //insert accounts;
        generateAccount(accounts);
       
        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
                                                               AssessmentNumber__c = 'ASSESS_TEST-0001',
                                                               BodyShop__c = accounts[0].Id,
                                                               Entity__c = 'AXA Direct',
                                                               EntityRules__c = 'AXA Direct',
                                                               MissionNumber__c = '01',
                                                               PortfolioAgentCode__c = '355',
															   TECH_EntityCountryCode__c = 'FR',
                                                               AssessmentID__c = '0912',
                                                               TechExternalId__c = '233'),
                                                
                                               new Assessment__c(Name='ASSESS_TEST-0002',
                                                                 AssessmentNumber__c = 'ASSESS_TEST-0002',
                                                                 BodyShop__c = accounts[0].Id,
                                                                 Entity__c = 'AXA Direct1',
                                                                 EntityRules__c = 'AXA Direct1',
																 TECH_EntityCountryCode__c = 'FR',
                                                                 MissionNumber__c = '02',
                                                                 PortfolioAgentCode__c = '3545',
                                                                 AssessmentID__c = '5912')
                
        };
            
        //insert assessments ;
        generateAssessment(assessments);


        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                          ValidityDate__c=date.today(),
                                                                          Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                          //QuotationTimestampStart__c = Datetime.now(),
                                                                          SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                          SLAQuotationLevel2__c = myDateTime,
                                                                          SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                          TECHSLAQuotationIsLevel1__c = false,
                                                                          TECHSLAQuotationIsLevel2__c = false,
                                                                          TECHSLAQuotationIsLevel3__c = false,
                                                                          Assessment__c=assessments[0].id,
                                                                          BodyShopOrderNumber__c = '2'
                                                                        //, BodyShop__c=accounts[0].id
                                                                        ),

                                                    new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                         ValidityDate__c=date.today(),
                                                                         Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED,
                                                                         //QuotationTimestampStart__c = Datetime.now(),
                                                                         SLAQuotationLevel1__c = (datetime.now()).addDays(2),
                                                                         SLAQuotationLevel2__c = (datetime.now()).addDays(3),
                                                                         SLAQuotationLevel3__c = (datetime.now()).addDays(5),
                                                                         TECHSLAQuotationIsLevel1__c = false,
                                                                         TECHSLAQuotationIsLevel2__c = false,
                                                                         TECHSLAQuotationIsLevel3__c = false,
                                                                          Assessment__c=assessments[0].id,
                                                                          BodyShopOrderNumber__c = '3'
                                                                        //,BodyShop__c=accounts[0].id
                                                                        )
        };
        //insert purchaseOrders;
        generatePurchaseOrder(purchaseOrders);

        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);    

        prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
                                                                                    Assessment__c = assessments[0].Id,
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)),
                                                    
                                                           new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
                                                                                    Assessment__c = assessments[0].Id,
                                                                                    OfferType__c = 'BASIC',
                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
        };
        //insert prerequisiteOrders;
        generatePrerequisiteOrder(prerequisiteOrders);

        
        // note: these need to be 'bulkified' --> instead of one record, use list of records
        partLists = new list<PartList__c>{new PartList__c(Assessment__c = assessments[0].Id,
                                                          Name = 'FRONT LWR AIR GRILLE',
                                                          PartNumber__c = '53102 47020',
                                                          HeldDate__c = myDate,
                                                          Price__c = 68,
                                                          Quantity__c = 1)
          };
        //insert partLists;
        generatePartList(partLists);

        // invoices not generated by this class
        // invoices = new list<Invoice__c>{new Invoice__c(Assessment__c = assessments[0].Id,
        //                                                 BodyShop__c = accounts[0].Id,
        //                                                 PrerequisiteOrder__c = prerequisiteOrders[0].Id,
        //                                                 Date__c = system.today())
        // };

        //
        // 
        // insert invoices;
        // generateInvoice(invoices);
        // 
        //

    }

    //
    // Unnecessary method below, to be removed?
    //
    // public static void setupBypassCustomSetting(Boolean BypassValidationRules,Boolean BypassWorkflows,String BypassTrigger, String name, String userId) {
    //     try { 
    //         Bypass__c customSetting = [
    //             SELECT
    //                 BypassValidationRules__c,BypassWorkflows__c,BypassTrigger__c
    //             FROM Bypass__c
    //             WHERE SetupOwnerId = :userId
    //         ];

    //         customSetting.BypassValidationRules__c = BypassValidationRules;
    //         customSetting.BypassWorkflows__c = BypassWorkflows;
    //         if(BypassTrigger != null && BypassTrigger != ''){
    //             customSetting.BypassTrigger__c = BypassTrigger;
    //         }
    //         update customSetting;
    //     } catch (QueryException ex) {
    //         Bypass__c customSetting = new Bypass__c(
    //             Name = name,
    //             SetupOwnerId = userId,
    //             BypassValidationRules__c = BypassValidationRules,
    //             BypassWorkflows__c = BypassWorkflows,
    //             BypassTrigger__c = BypassTrigger
    //         );

    //         Database.upsert(customSetting, Bypass__c.Name.getDescribe().getSObjectField(), false);
    //     }
    // }
    */
}