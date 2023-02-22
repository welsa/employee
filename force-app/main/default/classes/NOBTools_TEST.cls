/*
  ----------------------------------------------------------------------
  -- - Name          : NOBTools_TEST
  -- - Author        : KRO
  -- - Description   : Test class for NOBTools_TEST
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 11-FEB-2021	KRO		1.0    	Initial version
  -- 14-DEC-2021    NPE     1.1     Increase Coverage
  ----------------------------------------------------------------------
  **********************************************************************
*/

@isTest
public class NOBTools_TEST {
    static User userAdmin;

    static Account accBodyshop;

    static User userFO;
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


    static {

        userFO = new User();
        userAdmin = new User();
        accBodyshop = new Account();
        lstCases = new List<Case>();
        lstWorkOrder = new List<WorkOrder>();
        listContactAssure = new List<Contact>();
        Datetime dt = DateTime.now();

        userFO = TestFactory.createPrefikarUser('ScUserTest');
        userFO.ProfileId = [SELECT Id,Name FROM Profile WHERE Name LIKE 'PRE_Front Office' LIMIT 1].Id;
        userFO.NOB_isPrefikar__c = true;
        insert userFO;

        userAdmin = TestFactory.createPrefikarUser('ScUserTest2');
        userAdmin.ProfileId = [SELECT Id,Name FROM Profile WHERE Name ='PRE_System Administrator' LIMIT 1].Id;
        userAdmin.NOB_isPrefikar__c = true;
        insert userAdmin;
        System.runAs(userAdmin){

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

            // String docfinRT = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByName().get('Chiffrage').getRecordTypeId();
            // docFin = new List<PFR_FinancialDocument__c>{
            //    new PFR_FinancialDocument__c(recordTypeId= docfinRT ,PFR_FinancialDocumentFrom__c=listAccAssureur[1].Id,PFR_ExclVATTotalAmount__c=10, 
            //                                 PFR_DocumentStatus__c='VL', PFR_Case__c = lstCases[0].id,
            //                                 PFR_VATAmount__c =10,PFR_InclVATTotalAmount__c = 10, PFR_FinDocDateOfIssue__c = system.today())
            // };
             
            // insert docFin;
            
            
            lstDarvaTag = new List<NOB_DARVA_Tag__c>{
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '123', NOB_TAGLVL2__c = '123', NOB_TAGLVL1__c = '123', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 123, PFR_ParentTag__c = 'parent', NOB_Occurrence_number__c = 123),
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '456', NOB_TAGLVL2__c = '456', NOB_TAGLVL1__c = '456', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 456, PFR_ParentTag__c = 'parent2', NOB_Occurrence_number__c = 456)
            };//to create

            insert lstDarvaTag;
            RelatioCompte =  new List <NOB_AccountRelationship__c>{
                new NOB_AccountRelationship__c(NOB_Compte__c =listAccount[0].Id , NOB_Type__c = 'Réparateur - Assureur')

            };
            insert RelatioCompte;
            
            TauxNeg = new list<NOB_TauxNeg__c>{
                new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id, NOB_StartDate__c = System.today())
            };
                TauxNeg[0].NOB_DSP__c=3;
            TauxNeg[0].NOB_T1__c=3;
            TauxNeg[0].NOB_T2__c=3;
            TauxNeg[0].NOB_T3__c=3;
            TauxNeg[0].NOB_TauxMecanique__c=3;
            TauxNeg[0].NOB_TI1__c=3;
            TauxNeg[0].NOB_TI2__c=3;
            TauxNeg[0].NOB_TI3__c=3;
            TauxNeg[0].NOB_TP__c=3;
			 insert TauxNeg;
        }
    }

    @isTest
    public static void testEverything() {
        System.runAs(userAdmin) {
        Test.startTest();

        String[] x = new List<String>{
            NOB_AP00_Constants.PLANNING_STATUS_RESERVE,
            NOB_AP00_Constants.PLANNING_STATUS_ANNULE,
            NOB_AP00_Constants.PLANNING_STATUS_CONFIRME,
            NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE,
            NOB_AP00_Constants.PLANNING_STATUS_ABSENCE,
            NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS,
            NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie,
            NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE,
            NOB_AP00_Constants.ACCOUNT_RANKING_GOLD,
            NOB_AP00_Constants.ACCOUNT_RANKING_SILVER,
            NOB_AP00_Constants.ACCOUNT_RANKING_BRONZE,
            NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP,
            NOB_AP00_Constants.ACCOUNT_NETWORKTYPE_HORSRESEAU,
            NOB_AP00_Constants.ACCOUNT_EXPERT_SUBSTITUTION_METHOD_FORCED,
            NOB_AP00_Constants.ACCOUNT_ASENTITY_ASBE1,
            NOB_AP00_Constants.DETAILRULE_RECORDTYPE_FILTERCONDITION,
            NOB_AP00_Constants.DETAILRULE_RECORDTYPE_PRIMARY_FIELDS_NEEDED,
            NOB_AP00_Constants.DETAILRULE_RECORDTYPE_QUERYLIMIT,
            NOB_AP00_Constants.DETAILRULE_RECORDTYPE_CRITERIA,
            NOB_AP00_Constants.DETAILRULE_VALUE_FROM_MASTERsOBJECT,
            NOB_AP00_Constants.DETAILRULE_VALUE_FROM_CRITERIAsOBJECT,
            NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_DATE,
            NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_TIME,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_1,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_2,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_3,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_4,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5B,
            NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_6,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_CREATETASK,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_UPDATETASK,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,
            NOB_AP00_Constants.PRICEBOOK_OFFRE_SAD,
            NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR
        };

        Integer a = NOB_AP00_Constants.TimeZoneHours;
        String B = NOB_AP00_Constants.checkNull(System.NOW(), 'ICE');
        B = NOB_AP00_Constants.checkNull(System.NOW(), 'Genesys');

        Datetime now = DateTime.now();
        String format1 = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String format2 = now.format('dd/MM/yyyy HH:mm:ss');
        System.assertEquals(
            format1,
            NOBTools.checkNull(
            now,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE
            )
        );
        System.assertEquals(
            format2,
            NOBTools.checkNull(
            now,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS
            )
        );
        System.assertEquals('', NOBTools.checkNull(now, 'test'));
        System.assertEquals(
            '',
            NOBTools.checkNull(
            null,
            NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS
            )
        );
        System.assertEquals('', NOBTools.checkNull(null));
        System.assertEquals('test', NOBTools.checkNull('test'));
        System.assert(NOBTools.isPrefikarUser());
        NOBTools.isMigrationUser();

        //17 createtime
        DateTime dt = DateTime.now();
        Time t = dt.time();
        //plus 2hrs 19
        DateTime dt1 = dt.addHours(2);
        Time t1 = dt1.time();

        //plus 4hrs 21
        DateTime dt2 = dt1.addHours(2);
        Time t2 = dt2.time();

        //minus 2hrs 15
        DateTime dt3 = dt.addHours(-2);
        Time t3 = dt3.time();

        NOBTools.suggestPossibleStartEndDates(t, t1, t2);
        NOBTools.suggestPossibleStartEndDates(t3, t, t2);
        NOBTools.suggestPossibleStartEndDates(t2, t3, t3);
        NOBTools.calculatePrefDates(dt, dt1, t, t1, t2);
        NOBTools.calculatePrefDates(dt, dt1, t3, t, t2);

        DateTime sunday = DateTime.newInstance(Date.newInstance(2021, 1, 3), t1);
        DateTime sunday1 = DateTime.newInstance(Date.newInstance(2021, 0, 3), t1);

        NOBTools.calculatePrefDates(sunday, dt1, t3, t, t2);
        NOBTools.calculatePrefDates(sunday1, dt1, t3, t, t2);

        DateTime dCreateTime = DateTime.now();
        Time createTime = dCreateTime.time();

        DateTime dmorningStart = DateTime.now().addHours(-4);
        Time morningStart = dmorningStart.time();

        DateTime dmorningEnd = DateTime.now().addHours(2);
        Time morningEnd = dmorningEnd.time();

        DateTime deveningEnd = DateTime.now().addHours(4);
        Time eveningEnd = deveningEnd.time();

        NOBTools.suggestPossibleStartEndDates(
            morningStart,
            morningStart,
            morningStart
        );
        Test.stopTest();
        }

    }

    //NPE 14/12/2021 Increase Coverage
    @isTest 
    public static void sendEmailTest(){
        Test.startTest();
        System.runAs(userAdmin){
            insert lstWorkOrder;

            lstWorkOrder[0].ownerId  = userFO.id;
            lstWorkOrder[1].ownerId  = userFO.id;
            
            update lstWorkOrder;
        }
        Test.stopTest();
        List<WorkOrder> lstWOUpdated = [SELECT Id,Status FROM WorkOrder WHERE Id =:lstWorkOrder[1].Id];
        System.assertEquals('Nouvelle', lstWOUpdated[0].Status);
    }

    //NPE 14/12/2021 Increase Coverage
    @isTest 
    public static void removeCharTest(){
        System.runAs(userAdmin){
            Test.startTest();
            lstWorkOrder[1].NOB_Reparateur__c = accBodyshop.Id;
            insert lstWorkOrder;

            insert listMessageLog;
            
            
            listPlanning[2].nob_workOrder__c= lstWorkOrder[1].id;
            update listPlanning;

            lstCases[0].NOB_TECH_DispoId__c = null;
            update lstCases;
            NOB_AP51_DarvaWS.doSendMessage(listMessageLog[3].id,listMessageLog[3].Nob_WorkOrder__c, listMessageLog[3].NOB_Case__c);
            String s = NOB_AP51_DarvaWS.getComment(lstCases[0]);
            
			listPlanning[0].NOB_WorkOrder__c = lstWorkOrder[0].id;
            update listPlanning;
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c];
            listNOB_DarvaMessageLog[0].nob_workorder__c = lstWorkOrder[0].id;
            listNOB_DarvaMessageLog[3].nob_workorder__c = null;
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLogToUpdate = new List<NOB_DarvaMessageLog__c>();
            for(NOB_DarvaMessageLog__c dl : listNOB_DarvaMessageLog){ 
                dl.NOB_Status__c = 'New';
                listNOB_DarvaMessageLogToUpdate.add(dl);
            }
            
            update listNOB_DarvaMessageLogToUpdate; 
            

            if(lstWorkOrder[1] !=null && lstWorkOrder[1].NOB_Reparateur__c!=null){
                Map <String,String> mapWOStr = new Map <String,String>();
                mapWOStr.put('REPBillingStreet',lstWorkOrder[1].NOB_Reparateur__r.BillingStreet);
                mapWOStr.put('REPBillingPostalCode',lstWorkOrder[1].NOB_Reparateur__r.BillingPostalCode);
                mapWOStr.put('REPBillingCity',lstWorkOrder[1].NOB_Reparateur__r.BillingCity);
                mapWOStr.put('REPBillingCountryCode',lstWorkOrder[1].NOB_Reparateur__r.BillingCountryCode);
                mapWOStr.put('REPBillingCountry',lstWorkOrder[1].NOB_Reparateur__r.BillingCountry);
                
                Map <String,String> lstWOFilteredStr = NOBTools.removeSpecialChar(mapWOStr);
            }

            Test.stopTest();   
        }
    }
    
    @isTest 
    public static void removeNonNumericTest(){
        
        System.runAs(userAdmin){
            Test.startTest();
            
            Map<String,String> fieldMapString = new Map<String,String> ();
            String str = '7838493uuu99 93434';
            fieldMapString.put('key01', str);
            fieldMapString.put('key02', null);
            Map<String,String> fieldMapStringClean = NOBTools.removeNonNumeric(fieldMapString);
            System.assertEquals('78384939993434', fieldMapStringClean.get('key01'));
            System.assertEquals('', fieldMapStringClean.get('key02'));
            
            Test.stopTest();
            
        }
        
        
    }
}