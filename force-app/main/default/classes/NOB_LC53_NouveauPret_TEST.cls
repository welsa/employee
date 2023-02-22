/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC53_NouveauPret_TEST
  -- - Author        : HMO
  -- - Description   : Test class for class NOB_LC53_NouveauPret
  -- - #Ticket       : RSIW : 1869
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 11-01-2022      HMO     1.0     Initial version
  **********************************************************************
*/

@isTest
public without sharing class NOB_LC53_NouveauPret_TEST {

    public NOB_LC53_NouveauPret_TEST() {

    }

    static User userAdmin;
    static List<Asset> lstAssetToInsert;
    static Account accRep;
    static Account apportaire;
    static Case cases;
    static List<Account> gesReseaureparateur;
    static Contact assure;
    static NOB_planning__c planning;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static List<WorkOrder> lstWorkOrder;
    static String error = '';

    static{

        lstWorkOrder = new List<WorkOrder>();

        userAdmin = TestFactory.createPrefikarUser('AssetUser');
        userAdmin.Username = 'utilisateur@spoonTest.za';
        insert userAdmin;
        
        accRep = TestFactory.createPrefikarBodyAccount('ReparateurSPOON ', 'Réseau Premium');
        accRep.ContactEmail__c = 'spoonltdzzz@gmail.com';
        accRep.VATNumber__c = 'vat12349';
        accRep.ReferenceNumber__c = 'FR0000888888';
        accRep.ASEntity__c = 'ASFR1';
        accRep.ExpertSubstitutionMethod__c='FORCED';
        accRep.NOB_Ranking__c = NOB_AP00_Constants.ACCOUNT_RANKING_GOLD;
        accRep.NOB_SiretHeadquarters__c = '31049995900891';
        accRep.BillingCity = 'Paris';
        accRep.BillingCountry = 'France';
        accRep.BillingStreet = 'Chemin endans';
        accRep.BillingPostalCode = '3070';
        accRep.NOB_NetworkType__c = 'Réseau Platinium';
        insert accRep;

        apportaire = TestFactory.createInsurerAccount('accAssureur','Nord');
        apportaire.Nob_CTICampaignNumber__c = 'Test';
        apportaire.ReferenceNumber__c = 'FR0121237464';
        insert apportaire;

        assure = TestFactory.createInsuredContact('contact', 'Assuree', apportaire.Id,'Nord');
        insert assure;

        //create Gestionnaire de réseau de réparateur
        gesReseaureparateur = new List<Account>{
        TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
        };
        gesReseaureparateur[0].ReferenceNumber__c = 'FR0121456789';
        insert gesReseaureparateur;


        cases = TestFactory.createCaseStandard('Nouvelle', assure.Id, apportaire.Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
        System.today().month()-1, 
        System.today().day(), 17, 00, 0),'AR1234','Body','Réparation');
        insert cases;

        String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByDeveloperName().get('NOB_WorkOrder').getRecordTypeId();
        for (integer i = 0; i < 2; i++){ //Apex cpu limit if 201
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', cases.Id));
            lstWorkOrder[i].recordTypeId = recordTypeWo;
            lstWorkOrder[i].PFR_ExcludeFG__c = false;
            lstWorkOrder[i].NOB_Reparateur__c =accRep.Id;
            lstWorkOrder[i].NOB_VehiculeReturnDate__c = Datetime.newInstance(System.today().year(),
            System.today().month(), System.today().day()+1, 14, 30, 0);
        }
        insert lstWorkOrder;

        planning = TestFactory.createPlanning(accRep.Id);
        planning.NOB_WorkOrder__c = lstWorkOrder[0].Id;
        planning.NOB_StartDate__c = Datetime.newInstance(System.today().year(),
        System.today().month(), System.today().day()+1, 14, 30, 0);
        planning.NOB_EndDate__c = Datetime.newInstance(System.today().year(),
        System.today().month(), System.today().day()+1, 15, 30, 0);
        insert planning;



        lstRelationCompte = new List<NOB_AccountRelationship__c>{
            TestFactory.createRelationCompte(accRep.Id, apportaire.Id, 'Réparateur - Assureur')
        };
        insert lstRelationCompte;
        
        lstAssetToInsert = new List<Asset>();
        for (integer i = 0; i < 200; i++){
            Asset asset = new Asset(Name = 'VR'+i, AccountId = accRep.Id);
            lstAssetToInsert.add(asset);
        }
    }

    @isTest
    public static void testObsolete(){
        Boolean isObsolete = false;
        lstAssetToInsert[0].NOB_CirculationDate__c = system.today();
        lstAssetToInsert[0].NOB_Mileage__c = 160000000;

        Test.startTest();
            insert lstAssetToInsert;
            isObsolete = NOB_LC53_NouveauPret.checkVR(lstAssetToInsert[0].Id);
        Test.stopTest();

        System.assertEquals(isObsolete, true);
    }

    @isTest
    public static void getWorkOrder(){
        Test.startTest();

            userAdmin.NOB_isMigrationUser__c = false;
            update userAdmin;
            
            cases.NOB_TECH_DispoId__c = planning.Id;
            planning.NOB_Status__c = 'Réservé';
            update cases;
            update planning;

            lstWorkOrder[0].PFR_ExcludeFG__c = true;
            update lstWorkOrder;

            WorkOrder woTest = NOB_LC53_NouveauPret.getWorkOrderFields(lstWorkOrder[0].Id);
        Test.stopTest();

        System.assertEquals(woTest.NOB_VehiculeReturnDate__c, lstWorkOrder[0].NOB_VehiculeReturnDate__c);
        //System.assertEquals(woTest.NOB_TECHDateRendezVousPrisEnCharge__c, planning.NOB_StartDate__c);
        WorkOrder workOr = [SELECT workOrderNumber FROM WorkOrder WHERE Id = :lstWorkOrder[0].Id LIMIT 1];
        System.assertEquals(woTest.workOrderNumber, workOr.workOrderNumber);
    }
}