/*************************************************************************************
Class Name - TestUtils_ManageCaseCustom
Version - 1.0
Created Date - 15 JUL 2015
Function - TestClass to Utils_ManageCaseCustom

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Hirikesh (SC) 15/07/2015  Original Version
* Cecile L      19/10/2015  C-001349: Add handle of new field Active on CustomSettings. If Active is FALSE, don't create the case.
* Shamina M     02/08/2016  C-001386 - business hours updates 
*************************************************************************************/
@isTest
private class TestUtils_ManageCaseCustom {
// ABT Commented 20-SEP-2016
//    
//    static User userAdmin;
//    static Account acc;
//    static Assessment__c ass;
//    static PurchaseOrder__c purchaseOrder;
//    static PrerequisiteOrder__c salesOrder;
//    static list<CaseDetailsProcessMapping__c> cs_CaseDetails;
//    static list<CountryCodeInformationsMapping__c> cs_CountryCodeIngformation;
//    static map <String,Id> accRecordTypeMap = new map <String,Id>();
//    static BusinessHours defaultHours;
//    static{
//        
//        userAdmin = new User(Username = 'jean.paul@test.com'
//                    ,LastName = 'paul'
//                    ,LanguageLocaleKey = 'en_US'
//                    ,FirstName = 'jean'
//                    ,Email = 'jean@test.com'
//                    ,Alias = 'jpa'
//                    ,TimeZoneSidKey = 'Europe/Dublin'
//                    ,LocaleSidKey = 'en_US'
//                    ,EmailEncodingKey = 'UTF-8'
//                    ,ProfileId = ASPISConstants.getProfileAdminId()); 
//                        
//        //insert userAdmin;
//        ASPISTestUtils.generateTestUser(userAdmin);
//
//        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
//        
//        system.runas(userAdmin){
//            accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
//            
//            acc = new Account(Name='BodyShop_ScTest1'
//                        ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
//                        ,ReferenceNumber__c = '123'
//                        ,ContactEmail__c = 'bt1@gmail.com'
//                        ,VAT__c =10
//                    );
//            insert acc;
//
//            ass = new Assessment__c(Name='ASSESS_TEST-0001'
//                    ,AssessmentNumber__c = 'ASSESS_TEST-0001'
//                    //,BodyShop__c = acc.Id
//                    ,Entity__c = 'AXA Direct'
//                    ,MissionNumber__c = '01'
//                    ,PortfolioAgentCode__c = '355'
//                    ,AssessmentID__c = '0912'
//                    ,TechExternalId__c = '233'
//                );
//            insert ass;
//
//            purchaseOrder = new PurchaseOrder__c(
//                    Distributor__c= acc.Id
//                    ,Assessment__c = ass.Id
//                    ,status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
//
//                );
//            insert purchaseOrder;
//            
//            salesOrder = new PrerequisiteOrder__c(BodyShop__c = acc.Id
//                         ,Assessment__c = ass.Id
//                         //,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
//                     );
//            insert salesOrder;
//
//            cs_CaseDetails = new list<CaseDetailsProcessMapping__c>{
//                new CaseDetailsProcessMapping__c(
//                    Name='FR-PO-Delayed'
//                    ,Active__c = True
//                    ,Origin__c = 'APPLICATION'
//                    ,Type__c = 'PROBLEM'
//                    ,Priority__c = 'CRITICAL'
//                    ,Reason__c ='DELIVERY'
//                    ,Subject__c = 'Action requise : Livraison retardée'
//                    ,Description__c = 'La livraison de certains éléments de cette commande est retardée.Cela peut poser problème.'
//                    ,Internal_Comments__c = 'Veuillez contacter le Bodyshop pour étudier les alternatives possibles.'
//                    ,Due_Date_Duration__c = 1
//                    ,Due_Date_Unity__c = 'D'
//                    ,Short_Description__c = 'sd'
//                ),
//                new CaseDetailsProcessMapping__c(
//                    Name='FR-PO-Canceled2'
//                    ,Active__c = True
//                    ,Origin__c = 'APPLICATION'
//                    ,Type__c = 'PROBLEM'
//                    ,Priority__c = 'CRITICAL'
//                    ,Reason__c ='DELIVERY'
//                    ,Subject__c = 'Action requise : Commande annulée après la création des offres'
//                    ,Description__c = 'Cette commande a été annulée par le Distributeur après la génération et la soumission des offres correspondantes au Bodyshop.'
//                    ,Internal_Comments__c = 'Prenez contact au plus vite avec le Bodyshop pour etudier une solution de secours.'
//                    ,Due_Date_Duration__c = 1
//                    ,Due_Date_Unity__c = 'H'
//                    ,Short_Description__c = 'sd'
//                ),
//                new CaseDetailsProcessMapping__c(
//                    Name='FR-PO-Canceled1'
//                    ,Active__c = True
//                    ,Origin__c = 'APPLICATION'
//                    ,Type__c = 'PROBLEM'
//                    ,Priority__c = 'CRITICAL'
//                    ,Reason__c ='DELIVERY'
//                    ,Subject__c = 'Action requise : Commande annulée après la création des offres'
//                    ,Description__c = 'Cette commande a été annulée par le Distributeur après la génération et la soumission des offres correspondantes au Bodyshop.'
//                    ,Internal_Comments__c = 'Prenez contact au plus vite avec le Bodyshop pour etudier une solution de secours.'
//                    ,Due_Date_Duration__c = 1
//                    ,Due_Date_Unity__c = 'M'
//                    ,Short_Description__c = 'sd'
//                )
//            };
//
//            insert cs_CaseDetails;
//
//            defaultHours = [select Id from BusinessHours where IsDefault=true];
//
//            cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>{
//                                            new CountryCodeInformationsMapping__c(
//                                                name = 'DEFAULT',
//                                                BusinessHoursID__c = defaultHours.id 
//                                            ),
//                                            new CountryCodeInformationsMapping__c(
//                                                name = 'FR',
//                                                BusinessHoursID__c = defaultHours.id 
//                                            )
//                                        };
//            insert  cs_CountryCodeIngformation;                     
//        }//end runAs
//    }//end method
//    @isTest static void test_calculateDueDate() {
//        system.runas(userAdmin){
//            DateTime result;
//            Test.startTest();
//                result = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(cs_CaseDetails[0], null,null);
//                result = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(cs_CaseDetails[0], cs_CountryCodeIngformation[0], 'FR');
//                result = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(cs_CaseDetails[1], cs_CountryCodeIngformation[0], 'DEFAULT');
//                result = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(cs_CaseDetails[2], cs_CountryCodeIngformation[0], 'DEFAULT');
//            Test.stopTest();
//
//            System.assertEquals(BusinessHours.add(defaultHours.id, Datetime.now(), (1 * 60 * 1000L)) , result);                 
//        }//end runAs
//
//    }//end of test_calculateDueDate
//    
//    @isTest static void test_SLAOnStatusAssigned() {
//		DateTime nowTime = System.now(); 
//		//System.debug('##### DateTime d:'+nowTime);
//        system.runas(userAdmin){
//            Case__C cas = new Case__c (
//                            Subject__c = 'sub',
//                            CountryCode__c = 'RO',
//                            //SLAAssignationDate__c = System.now().addDays(1)
//							SLAAssignationDate__c = nowTime.addDays(1)
//                        );
//            insert cas;
//			//system.debug('##### case inserted:'+[SELECT SLAAssignationDurationMinutes__c, SLAResolutionDate__c,SLAAssignationDate__c FROM Case__C WHERE Id = :cas.Id ]);
//            cas.Status__c = 'ASSIGNED';
//            Test.startTest();
//                //Shamina M: case 1386
//                Utils_ManageCaseCustom.runSLAOnStatus_Assigned(cas, 'FR'); 
//                //DateTime nowTime = system.now();
//                update cas;
//				//system.debug('##### case updated:'+[SELECT SLAAssignationDurationMinutes__c, SLAResolutionDate__c,SLAAssignationDate__c FROM Case__C WHERE Id = :cas.Id ]);
//            Test.stopTest();        
//            //Shamina M: case 1386
//            Utils_BusinessDays businessDays = new Utils_BusinessDays();
//            //Utils_BusinessDays businessDays = new Utils_BusinessDays(defaultHours.id );
//            List<Case__C> listCaseResult = new list<Case__C>([  SELECT SLAAssignationDurationMinutes__c FROM Case__C WHERE Id = :cas.Id ]);
//            
//            System.assertEquals(businessDays.calculateDifferenceBetweenBusinessDateInMinutes(nowTime.addDays(1), nowTime) , listCaseResult[0].SLAAssignationDurationMinutes__c ); 
//        }//end runAs
//    }// End of  test_SLAOnStatusAssigned
//
//    @isTest static void test_SLAOnStatusClosed() {
//        system.runas(userAdmin){
//            Case__C cas = new Case__c (
//                            Subject__c = 'sub',
//                            CountryCode__c = 'RO',
//                            SLAResolutionDate__c = System.now().addDays(1)
//                        );
//            insert cas;
//
//            cas.Status__c = 'CLOSED';
//            Test.startTest();
//                //Shamina M: case 1386
//                Utils_ManageCaseCustom.runSLAOnStatus_Closed(cas, 'FR');
//                update cas;
//            Test.stopTest();        
//            //Shamina M: case 1386
//            Utils_BusinessDays businessDays = new Utils_BusinessDays();
//            //Utils_BusinessDays businessDays = new Utils_BusinessDays(defaultHours.id );
//            List<Case__C> listCaseResult = new list<Case__C>([  SELECT SLAResolutionDurationMinutes__c FROM Case__C WHERE Id = :cas.Id ]);
//
//            // commented out temporarily, causes problems on Prod, sometimes -599, expecting -600, Immo Salo 28/07/2015
//            //System.assertEquals(businessDays.calculateDifferenceBetweenBusinessDateInMinutes(System.now().addDays(1), System.now()) , listCaseResult[0].SLAResolutionDurationMinutes__c );  
//        }//end runAs
//    }// End of  test_SLAOnStatusAssigned
//
//    @isTest static void test_prepopulatedInformations() {
//        system.runas(userAdmin){
//            String objCode = '-PO';
//            String countryCode = 'FR';
//            Id accountId = acc.id;
//            Id assessmentId = ass.id;
//            Id poId = purchaseOrder.id;
//            Id soId = salesOrder.id;
//            String comment = 'comment';
//            Id userId = userAdmin.id;
//            String csProcessName = '-Canceled1';
//
//            Case__C caseResult;
//
//            Test.startTest();
//                caseResult = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations( objCode, null, accountId, assessmentId, poId, soId, comment, userId, csProcessName);
//                caseResult = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations( objCode, countryCode, accountId, assessmentId, poId, soId, comment, userId, csProcessName);
//            Test.stopTest(); 
//              
//            System.assertEquals('DELIVERY' , caseResult.Case_Reason__c );   
//        }//end runAs
//    }// End of  test_SLAOnStatusAssigned
}//end of test class