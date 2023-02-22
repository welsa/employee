/*
  ----------------------------------------------------------------------
  -- - Name          : PRE_SchedulableMonthlyDeleteRecords_TEST
  -- - Author        : NPE
  -- - Description   : TEST class for PRE_SchedulableMonthlyDeleteRecords
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 05-JAN-2022	NPE		1.0    	Initial version
  -- 04-APR-2022    NPE     1.1     Increased coverage 
  ----------------------------------------------------------------------
  **********************************************************************
*/

@isTest
public with sharing class PRE_SchedulableMonthlyDeleteRecords_TEST {
    public PRE_SchedulableMonthlyDeleteRecords_TEST() {

    }
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;


    static Account accBodyshop;

    static List<Account> gesReseaureparateur;
    static List<Account> listAccAssureur;
    static List<Case> lstCases;
    static List<WorkOrder> lstWorkOrder;
    static List<Contact> listContactAssure;
    static List<NOB_Planning__c> listPlanning;
    static List<NOB_DarvaMessageLog__c> listMessageLog;
    static List<PFR_FinancialDocument__c> docFin = new List<PFR_FinancialDocument__c>();
    static List<NOB_DARVA_Tag__c> lstDarvaTag;
	 static List<NOB_TauxNeg__c> TauxNeg;
     static List<NOB_AccountRelationship__c> RelatioCompte =  new List<NOB_AccountRelationship__c>();
     static List<Account> listAccount;

    // ABT 21-APR-2016
    static List<CaseDetailsProcessMapping__c> caseMappingList;

    static {
        // initialising variables
        accounts = new list <Account>();
        assessments = new list <Assessment__c>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.callersystem__c = 'FR_NEVADA';
        userAdmin.CreateToUpsert__c = true;

        insert userAdmin;

        accBodyshop = new Account();
        lstCases = new List<Case>();
        lstWorkOrder = new List<WorkOrder>();
        listContactAssure = new List<Contact>();
        Datetime dt = DateTime.now();

        system.runas(userAdmin){


            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.isEligible__c = true;
   

            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            accounts.add(bs2);    

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            accounts.add(dist1);
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            accounts.add(dist2);

            insert accounts;

            ///DARVA TAG

            listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','Nord'),TestFactory.createInsurerAccount('accAssureur1','Bourgogne')};
            listAccAssureur[0].Nob_CTICampaignNumber__c = 'Test';
            listAccAssureur[1].Nob_CTICampaignNumber__c = 'Test1';
			listAccAssureur[0].ReferenceNumber__c = 'FR0121237264';
            listAccAssureur[1].ReferenceNumber__c = 'FR0121237464';
            insert listAccAssureur;

            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createPrefikarBodyAccount('Test 3', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '4463565200035')
            };

            listAccount[0].ReferenceNumber__c = 'FR0000000123';//WCH 23/12/2020 C-004120
			listAccount[1].ReferenceNumber__c = 'FR0000001234';//WCH 23/12/2020 C-004120
			listAccount[2].ReferenceNumber__c = 'FR0000012345';//WCH 23/12/2020 C-004120

			listAccount[0].ContactEmail__c = 'spoonltdzzz@gmail.com';
			listAccount[0].VATNumber__c = 'vat12349';
			listAccount[0].ASEntity__c = 'ASFR1';
			listAccount[0].ExpertSubstitutionMethod__c='FORCED';

			listAccount[1].ContactEmail__c = 'spoonltdzzz@gmail.com';
			listAccount[1].VATNumber__c = 'vat12349';
			listAccount[1].ASEntity__c = 'ASFR1';
			listAccount[1].ExpertSubstitutionMethod__c='FORCED';

			listAccount[2].ContactEmail__c = 'spoonltdzzz@gmail.com';
			listAccount[2].VATNumber__c = 'vat12349';
			listAccount[2].ASEntity__c = 'ASFR1';
			listAccount[2].ExpertSubstitutionMethod__c='FORCED';

            insert listAccount;

            accBodyshop = TestFactory.createPrefikarBodyAccount('accReparateur', 'Hors réseau','Test','Actif'); 
            accBodyshop.NOB_SiretHeadquarters__c = '31049995900891';
            accBodyshop.BillingCity = 'Paris';
            accBodyshop.BillingCountry = 'France';
            accBodyshop.BillingStreet = 'Chemin endans';
            accBodyshop.BillingPostalCode = '3070';
            accBodyshop.NOB_NetworkType__c = 'Réseau Platinium';
            accBodyshop.ContactEmail__c = 'test@test.com';
            accBodyshop.VATNumber__c = 'vat245686';
            accBodyshop.ReferenceNumber__c = 'FR0123456789';
            accBodyshop.ASEntity__c = 'ASFR1';
            accBodyshop.ExpertSubstitutionMethod__c = 'Forced';
            insert accBodyshop;

            listPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(listAccAssureur[0].Id),
                TestFactory.createPlanning(listAccAssureur[1].Id),
                TestFactory.createPlanning(listAccAssureur[0].Id)
            };
            
            insert listPlanning;

            gesReseaureparateur = new List<Account>{
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
            };
            gesReseaureparateur[0].ReferenceNumber__c = 'FR0121456789';
            insert gesReseaureparateur;

            listContactAssure.add(TestFactory.createInsuredContact('contact', 'Assuree', listAccAssureur[0].Id,'Nord'));
            listContactAssure.add(TestFactory.createInsuredContact('contact1', 'Assuree1', listAccAssureur[1].Id,'Bourgogne'));
            insert listContactAssure;

            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[0].Id, listAccAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[1].Id, listAccAssureur[1].Id, 'BMW', 'X6','128765sdd','test2',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR16534','Body','Réparation'));
            lstCases[0].NOB_ScenarioCode__c = '36';
            lstCases[0].PFR_TECH_EngineerClaimNR__c = 'testing';
            insert lstCases;

            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[1].Id));
            lstWorkOrder[0].recordTypeId = recordTypeWo;
            lstWorkOrder[0].NOB_TECHDateRendezVousPrisEnCharge__c = dt;
            lstWorkOrder[0].PFR_ExcludeFG__c = false;
            lstWorkOrder[0].NOB_Reparateur__c =accBodyshop.Id;
            lstWorkOrder[1].recordTypeId = recordTypeWo;
            lstWorkOrder[1].PFR_ExcludeFG__c = false;
            lstWorkOrder[1].NOB_TECHDateRendezVousPrisEnCharge__c = dt;

             // Message Log
            listMessageLog = new List<NOB_DarvaMessageLog__c>{ 
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='New',NOB_Case__c = lstCases[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'Genesys',NOB_MessageSubType__c ='CreateTask' , NOB_Status__c = 'New',NOB_Case__c = lstCases[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='New' ,NOB_Case__c=lstCases[0].Id, NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' , NOB_Status__c='New',NOB_Case__c = lstCases[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'Genesys',NOB_MessageSubType__c ='CreateTask' , NOB_Status__c = 'New',NOB_Case__c = lstCases[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='New' ,NOB_Case__c=lstCases[0].Id, NOB_ActionType__c= 'New')
                    
            };
            
            
            lstDarvaTag = new List<NOB_DARVA_Tag__c>{
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '123', NOB_TAGLVL2__c = '123', NOB_TAGLVL1__c = '123', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 123, PFR_ParentTag__c = 'parent', NOB_Occurrence_number__c = 123),
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '456', NOB_TAGLVL2__c = '456', NOB_TAGLVL1__c = '456', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 456, PFR_ParentTag__c = 'parent2', NOB_Occurrence_number__c = 456)
            };//to create

            insert lstDarvaTag;
            RelatioCompte =  new List <NOB_AccountRelationship__c>{
                new NOB_AccountRelationship__c(NOB_Compte__c =listAccount[0].Id , NOB_Type__c = 'Réparateur - Assureur')

            };
            insert RelatioCompte;

            ///END DARVA TAg

            //--------------------------------------
            //START TEST CLASS FOR r3 Assessment

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';

            ass1.R3_Assessment__c = 'a007a0000093nqGAAQ';
            ass1.R3AssessmentToBeDeleted__c = true;

            assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            ass2.Entity__c = 'AXA Direct1';
            ass2.EntityRules__c = 'AXA Direct1';
            ass2.EntityCode__c = '213';
            ass2.BuildDate__c = date.today()+1;

            ass2.R3_Assessment__c = 'a007a0000093nqYAAQ';
            ass2.R3AssessmentToBeDeleted__c = true;

            assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            ass3.Entity__c = 'AXA Direct2';
            ass3.EntityRules__c = 'AXA Direct2';
            ass3.EntityCode__c = '299';
            ass3.ShortTermDeletionDate__c = System.today();

            ass3.R3_Assessment__c = 'a007a0000093nqSAAQ';
            ass3.R3AssessmentToBeDeleted__c = true;
            ass3.RecordTypeID = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            assessments.add(ass3);  

            Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs1);
            ass4.Entity__c = 'AXA Direct3';
            ass4.EntityRules__c = 'AXA Direct3';
            ass4.EntityCode__c = '296';
            ass4.ShortTermDeletionDate__c = System.today();
            //ass4.R3_Assessment__c = 'a007a0000093nqSAAQ';
            ass4.R3AssessmentToBeDeleted__c = true;
            ass4.RecordTypeID = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            assessments.add(ass4);

            insert assessments;

            Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs1);
            ass5.Entity__c = 'AXA Direct4';
            ass5.EntityRules__c = 'AXA Direct4';
            ass5.EntityCode__c = '297';
            ass5.ShortTermDeletionDate__c = System.today();
            ass5.R3_Assessment__c = ass4.Id;
            ass5.RecordTypeID = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            ass5.R3AssessmentToBeDeleted__c = true;

            insert ass5;

            

            system.debug('NPE assessment list ' +assessments );

            for (Assessment__c ass :assessments ){
                Id assId = null;
                if (ass.Entity__c == 'AXA Direct'){
                    assId = ass.id;
                    ass.R3_Assessment__c = assId;
                }
                else if (ass.Entity__c == 'AXA Direct1'){
                    assId = ass.id;
                    ass.R3_Assessment__c = assId;

                }
                else if (ass.Entity__c == 'AXA Direct2'){
                    assId = ass.id;
                    ass.R3_Assessment__c = assId;
                    
                }

            }
            update assessments;

            //END TEST CLASS FOR r3 Assessment
        }
    }


    @isTest
    public static void executeTESTDarvaTag(){
        
        System.runAs(userAdmin){
            Test.startTest();
            //List<Assessment__c> lstBefore = new List<Assessment__c>([SELECT R3_Assessment__c FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true]);

            PRE_SchedulableMonthlyDeleteRecords s = new PRE_SchedulableMonthlyDeleteRecords();
            s.execute(null);

            // PRE_BatchDeleteRecords cb = new PRE_BatchDeleteRecords('SELECT R3_Assessment__c FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true', true);
            //  Database.executeBatch(cb);
            //  Database.QueryLocator ql = cb.start(null);
            //  cb.execute(null,assessments);
            //  cb.Finish(null);

            PRE_BatchDeleteRecords cb = new PRE_BatchDeleteRecords('SELECT id FROM NOB_DARVA_Tag__c WHERE NOB_CaseID__r.ClosedDate !=LAST_N_MONTHS:6 AND NOB_CaseID__r.status = \'Closed\'', false);
             Database.executeBatch(cb);
             Database.QueryLocator ql = cb.start(null);
             cb.execute(null,lstDarvaTag);
             cb.Finish(null);

            Test.stopTest();
            //List<Assessment__c> lstAfter = new List<Assessment__c>([SELECT R3_Assessment__c FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true]);
        }
    }

    @isTest
    public static void executeTESTR3Assessment(){
        System.runAs(userAdmin){
            Test.startTest();
            List<Assessment__c> lstBefore = new List<Assessment__c>([SELECT R3_Assessment__c FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true]);

            PRE_SchedulableMonthlyDeleteRecords s = new PRE_SchedulableMonthlyDeleteRecords();
            s.execute(null);

            PRE_BatchDeleteRecords cb = new PRE_BatchDeleteRecords('SELECT R3_Assessment__c, RecordTypeId FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true', true);
             Database.executeBatch(cb);
             Database.QueryLocator ql = cb.start(null);
             cb.execute(null,assessments);
             cb.Finish(null);

            Test.stopTest();
            List<Assessment__c> lstAfter = new List<Assessment__c>([SELECT R3_Assessment__c FROM Assessment__c WHERE CreatedDate !=LAST_N_MONTHS:1 AND R3AssessmentToBeDeleted__c = true]);
        }
    }
            
}