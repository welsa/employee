/*************************************************************************************
Class Name - TestCaseTriggerHandler
Version - 1.0
Created Date - 15 July 2015
Function - TestClass to CaseTriggerHandler

Modification Log :
------------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Salo, Immo   15/07/2015   Original Version
* Cecile L     02/09/2015  Add the uncheck of the Purchase Order field ASMarginTooLowCaseCreated__c when case is closed.
* Dourga U     19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
*************************************************************************************/
@isTest
private class TestCaseTriggerHandler {
    /*static User userAdmin;
    static List<Assessment__c> assessments;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Case__c> cases;
    static list<Account> accounts;
    static BusinessHours defaultHours;
    static list<CountryCodeInformationsMapping__c> cs_CountryCodeIngformation;

    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();
    
    static {

         accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
         proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
         
        // Create test users userAdmin and userAdmin2
        userAdmin = new User(Username = 'jk@test.com',
                         LastName = 'Jack',
                         FirstName = 'Kurry',
                         Email = 'KurryJack@test.com',
                         Alias = 'KJac',
                         LanguageLocaleKey = 'fr',
                         TimeZoneSidKey = 'Europe/Dublin',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         General_Agreement__c = false,
                         ProfileId = ASPISConstants.getProfileAdminId()
        );     
        //insert userAdmin;  
        ASPISTestUtils.generateTestUser(userAdmin); 



      // insert accounts
      accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest122'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '9123'
                    ,ContactEmail__c = 'bt122@gmail.com'
                    ,ShippingCountryCode = 'FR'
                    ,VAT__c  =10
                ),
                new Account(Name='BodyShop_ScTest222'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '91234'
                    ,ContactEmail__c = 'bt222@gmail.com'
                    ,ShippingCountryCode = 'FR'
                    ,VAT__c  =10
                ),
                new Account(Name='Distributor_ScTest122'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '912345'
                    ,ContactEmail__c = 'dt1@gmail.com'
                    ,ShippingCountryCode = 'FR'
                    ,VAT__c  =10
                ),
                new Account(Name='Distributor_ScTest222'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '9123456'
                    ,ContactEmail__c = 'dt1@gmail.com'
                    ,ShippingCountryCode = 'FR'
                    ,VAT__c  =10
                )
      };
            
      insert accounts;      


        //insert assessments
        assessments = new list<Assessment__c>{
            new Assessment__c(Name='ASSESS_TEST-0001'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0001'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct'
                    ,EntityCode__c = 'AXA Direct'
                    ,TECH_EntityCountryCode__c = 'FR'
                    ,MissionNumber__c = '01'
                    ,PortfolioAgentCode__c = '355'
                    ,AssessmentID__c = '0912'
                    ,TechExternalId__c = '233'
                    ,EntityRules__c = 'AXA Direct'
                    ,Manufacturer__c = 'RENAULT'
                ),
                
                new Assessment__c(Name='ASSESS_TEST-0002'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0002'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct1'
                    ,TECH_EntityCountryCode__c = 'FR'
                    ,EntityCode__c = 'AXA Direct1'
                    ,MissionNumber__c = '02'
                    ,PortfolioAgentCode__c = '3545'
                    ,AssessmentID__c = '5912'
                    ,EntityRules__c = 'AXA Direct1'
                )
            };
      insert assessments;
            
      //insert prerequisiteorders aka Sales Orders
      prerequisiteOrders= new list<PrerequisiteOrder__c>{
              new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ,HasSomeDeliveryIssuedCaseCreated__c = TRUE
              ),
              
              new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                ,Assessment__c = assessments[0].Id
                ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
              )
       };
       insert prerequisiteOrders;          

       purchaseOrders = new list<PurchaseOrder__c>{
                new PurchaseOrder__c(
                    Distributor__c= accounts[2].Id
                    ,Manual_Creation__c = true
                    ,Assessment__c = assessments[0].Id
                    ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,DelayedCaseCreated__c = TRUE

                ),
                new PurchaseOrder__c(
                    Distributor__c= accounts[3].Id
                    ,Assessment__c = assessments[1].Id
                    ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,ASMarginTooLowCaseCreated__c = TRUE

                ),
                new PurchaseOrder__c(
                    Distributor__c= accounts[2].Id
                    ,Assessment__c = assessments[1].Id
                    ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,ASMarginTooLowCaseCreated__c = TRUE

                )
        };
       //System.debug('##purchaseOrders'+purchaseOrders);
       insert purchaseOrders;

       // insert cases
       cases = new list<Case__c>{
                new Case__c(
                    Subject__c = 'Test',
                    Assesment__c = assessments[0].Id
                ),
                new Case__c(
                    Subject__c = 'TestPurchaseOrder',
                    Purchase_order__c = purchaseOrders[0].Id
                ),
                new Case__c(
                    Subject__c = 'TestPrerequisiteOrder',
                    Sales_order__c = prerequisiteOrders[0].Id
                ),
                new Case__c(
                    Subject__c = 'country code test',
                    CountryCode__c = 'FR',
                    Case_Reason__c = 'DEFAULT',
                    SubmittedBy__c = userAdmin.Id
                ),
                new Case__c(
                    Subject__c = 'Test2',
                    Status__c = 'NEW',
                    OwnerId = userAdmin.Id,
                    Assesment__c = assessments[0].Id
                ),
                new Case__c(
                    Subject__c = 'TestPurchaseOrder2',
                    Purchase_order__c = purchaseOrders[1].Id
                ),
                new Case__c(
                    Subject__c = 'TestPurchaseOrder2',
            SLAAssignationDate__c = system.now().addDays(-2),
            SLAResolutionDate__c = system.now()
                ),
                new Case__c(
                    Subject__c = 'TestPurchaseOrder3',
                    Purchase_order__c = purchaseOrders[2].Id
                )
         };
//       insert cases;
       
        
             
    }//end method
  
    static testMethod void test_insert() {
        
        system.runAs(userAdmin){  
          test.starttest();
              ASPISTestUtils.generateCase(cases);
          test.stoptest();

          List< Case__c > CasesResult = new List<Case__c >([SELECT Id,CountryCode__c FROM Case__c where ID IN :cases ]);
          List< Account > AccountsResult = new List<Account >([SELECT Id,ShippingCountryCode FROM Account where ID IN :accounts ]);
          system.assertEquals( CasesResult[0].CountryCode__c , AccountsResult[0].ShippingCountryCode );
        }//end runAs
    }//end method

    static testMethod void test_ipdate() {
          
          system.runAs(userAdmin){ 
            purchaseOrders[0].InvoiceStatusNotValidated__c = true;
            purchaseOrders[1].DistributorPriceHigger__c = true;
            update purchaseOrders;
            ASPISTestUtils.generateCase(cases);
            cases[1].Status__c = 'CLOSED';
            cases[1].TECH_AutomaticCreationFromProcess__c = '-PO-NotValidated';
            cases[5].Status__c = 'CLOSED';
            cases[5].TECH_AutomaticCreationFromProcess__c = '-PO-DistributorPriceHigh';
            test.starttest();                
                update cases;                
            test.stoptest();
              
            List<PurchaseOrder__c> POResults = [SELECT Id,DistributorPriceHigger__c,InvoiceStatusNotValidated__c, Name FROM PurchaseOrder__c WHERE Id IN :purchaseOrders ];
            for(PurchaseOrder__c po: POResults){
                system.assertEquals(FALSE, po.InvoiceStatusNotValidated__c);
                system.assertEquals(FALSE, po.DistributorPriceHigger__c);
            }

          }//end runAs
      }//end method

    static testMethod void test_update2() {
        
    defaultHours = [select Id,TimeZoneSidKey from BusinessHours where IsDefault=true];
        
            //create CountryCodeInformationsMapping__c
            cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>{
                                            new CountryCodeInformationsMapping__c(
                                                name = 'DEFAULT',
                                                BusinessHoursID__c = defaultHours.id 
                                            ),
                                            new CountryCodeInformationsMapping__c(
                                                name = 'FR',
                                                BusinessHoursID__c = defaultHours.id,
                                                URLInvoiceDistributor__c = 'xxxxx',
                                                LoginInvoiceDistributor__c = 'login',
                                                PasswordInvoiceDistributor__c = 'pwd'
                                            )
                                        };
        insert cs_CountryCodeIngformation;
          
          system.runAs(userAdmin){ 
            ASPISTestUtils.generateCase(cases);
            List< Case__c > CasesResultbefore = new List<Case__c >([SELECT Id,Status__c,SLAAssignationDate__c,SLAResolutionDate__c FROM Case__c where ID IN :cases ]);  
            cases[3].CountryCode__c = 'Fi';
            cases[3].Status__c = 'CLOSED';
            cases[1].Status__c = 'CLOSED';
            cases[1].TECH_AutomaticCreationFromProcess__c = '-PO-Delayed';
            cases[2].Status__c = 'CLOSED';
            cases[2].TECH_AutomaticCreationFromProcess__c = '-SO-DeliveryProblem';
            cases[0].Status__c = 'ASSIGNED';
            cases[4].Subject__c = 'Test2.1';
            cases[5].Status__c = 'CLOSED';
            cases[5].TECH_AutomaticCreationFromProcess__c = '-PO-ASMarginTooLow';
                cases[6].Status__c = 'CLOSED'; 
                cases[6].CountryCode__c = 'FR';
            cases[7].Status__c = 'CLOSED';
            cases[7].TECH_AutomaticCreationFromProcess__c = '-PO-NotDelivered';
            test.starttest();                
                update cases;                
            test.stoptest();
            List< Case__c > CasesResult = new List<Case__c >([SELECT Id,Status__c,SLAAssignationDate__c,SLAResolutionDate__c FROM Case__c where ID IN :cases ]);
            system.assertEquals(CasesResult[1].Status__c, 'Closed');
            system.assertEquals(CasesResult[6].SLAResolutionDate__c, CasesResult[6].SLAResolutionDate__c);
              
              List<PrerequisiteOrder__c> SOResults = [SELECT Id,HasSomeDeliveryIssuedCaseCreated__c, Name FROM PrerequisiteOrder__c WHERE Id IN :prerequisiteOrders ];
              for(PrerequisiteOrder__c so: SOResults)
                  system.assertEquals(FALSE, so.HasSomeDeliveryIssuedCaseCreated__c);
              
              List<PurchaseOrder__c> POResults = [SELECT Id,DelayedCaseCreated__c,ASMarginTooLowCaseCreated__c, Name FROM PurchaseOrder__c WHERE Id IN :purchaseOrders ];
              for(PurchaseOrder__c po: POResults){
                  system.assertEquals(FALSE, po.DelayedCaseCreated__c);
                  //system.assertEquals(FALSE, po.ASMarginTooLowCaseCreated__c);
              }

          }//end runAs
      }

/*
    static testMethod void testCaseTriggerHandler() {
        
        system.runAs(userAdmin){  
          test.starttest();
            
              insert cases;

              Case__c testCase =  [SELECT Id FROM Case__c where Subject__c='country code test'];
              testCase.CountryCode__c = 'Fi';
              testCase.Status__c = 'CLOSED';
              update testCase;
              delete testCase;
              Case__c testCaseDeleted =  [SELECT Id FROM Case__c where Subject__c='country code test' ALL ROWS];
              undelete testCaseDeleted;
              
              Case__c testCase1 =  [SELECT Id FROM Case__c where Subject__c='TestPurchaseOrder'];
              testCase1.Status__c = 'CLOSED';
              testCase1.TECH_AutomaticCreationFromProcess__c = '-PO-Delayed';
              update testCase1;
              system.assertEquals(testcase1.Status__c, 'CLOSED');
              
              Case__c testCase2 =  [SELECT Id FROM Case__c where Subject__c='TestPrerequisiteOrder'];
              testCase2.Status__c = 'CLOSED';
              testCase2.TECH_AutomaticCreationFromProcess__c = '-SO-DeliveryProblem';
              update testCase2;
              
              Case__c testCase3 =  [SELECT Id FROM Case__c where Subject__c='Test'];
              testCase3.Status__c = 'ASSIGNED';
              update testCase3;
            
              Case__c testCase4 =  [SELECT Id FROM Case__c where Subject__c='Test2'];
              testCase4.Subject__c = 'Test2.1';
              update testCase4;
              
          test.stoptest();

        }//end runAs
    }//end method
    */
}