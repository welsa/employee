/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_Batch_AttachedSharePDFOnDocFin_TEST
  -- - Author        : SRA
  -- - Description   : Test class for NOB_Batch_AttachedSharePDFOnDocFin
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 04-SETP-2021  SRA    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class NOB_Batch_AttachedSharePDFOnDocFin_TEST {
    static User adminUser; 
    static PFR_Transaction__c trans;
    static PFR_FinancialDocument__c docFin;
    static List<Account> lstEmetteur;
    static ContentVersion docFinConv;
    static ContentVersion conv;
    static Account acc;
    static List<ContentVersion> lstCV = new List<ContentVersion> ();
    public static List<PFR_FinancialDocument__c> lstDocFin = new List<PFR_FinancialDocument__c> ();
    static Contact cont;
    static{
        adminUser = TestFactory.createUser('adminUser');
        insert adminUser;
        System.runAs(adminUser){

        //Create contentversion with contentDocumentLink
            //conv = TestFactory.createContentVersion('FactureReparation', 'pdf');
            //insert conv;
            //System.debug('££££ conv '+ conv);
            
            acc =TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif');
            acc.ContactUser__c = adminUser.Id;
            acc.isEligibleSubstitution__c = true;
            acc.ExpertSubstitutionMethod__c = 'FORCED';
            acc.SubstitutionMethod2__c = 'PROPOSED';
            acc.ContactEmail__c = 'test@test.com';
            acc.ReferenceNumber__c = 'FR2763223905';
            acc.Type = 'Standard';
            acc.Type = 'Expert';
            acc.ExpertSubstitutionMethod__c = 'FORCED';
            acc.SubstitutionMethod2__c = 'PROPOSED';
            insert acc;

            lstEmetteur = new List<Account>();
            String AccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Assureur').getRecordTypeId();    
            lstEmetteur.add(TestFactory.createAccountBodyshop('compteEmetteur', 'FR'));
            lstEmetteur[0].NOB_Statut__c = 'Actif';
            lstEmetteur[0].RecordTypeId = AccountRT;
            lstEmetteur[0].OwnerId = adminUser.Id;
            lstEmetteur[0].NOB_isPrefikar__c = true; 
            lstEmetteur[0].NOB_SiretHeadquarters__c = System.Label.PFR_prefikarSiret;
           // lstEmetteur[0].PFR_AccountRecordTypeTech__c = 'PFR_BodyshopNetworkManager';
            insert lstEmetteur;

            cont = new Contact(AccountId = acc.id,LastName='BsContact');
            cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            insert cont;

            System.debug('££££ cont '+ cont);

            String docfinRT = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByName().get('Facture de réparation').getRecordTypeId();
            String docfinRTCOm = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByName().get('Facture de commission').getRecordTypeId();
            lstDocFin = new List<PFR_FinancialDocument__c>{
                new PFR_FinancialDocument__c(recordTypeId= docfinRT ,PFR_FinDocDateOfIssue__c = System.today(), PFR_FinancialDocumentFrom__c=acc.Id,PFR_ExclVATTotalAmount__c=10, PFR_CaseBusinessProvider__c = lstEmetteur[0].Id,
                                             PFR_DocumentStatus__c='NU', PFR_RepairInvoiceNumber__c='7654399',
                                             PFR_VATAmount__c =10,PFR_InclVATTotalAmount__c = 10, PFR_IsPDFAttachedAndShare__c = false, PFR_BilledPartyAccount__c = lstEmetteur[0].Id), //, OwnerId=userBackOffice.Id)
                new PFR_FinancialDocument__c(recordTypeId= docfinRTCOm ,PFR_FinDocDateOfIssue__c = System.today(), PFR_FinancialDocumentFrom__c=lstEmetteur[0].Id,PFR_ExclVATTotalAmount__c=100, PFR_CaseBusinessProvider__c = lstEmetteur[0].Id,
                                            PFR_DocumentStatus__c='NU', PFR_RepairInvoiceNumber__c='111111',
                                            PFR_VATAmount__c =100,PFR_InclVATTotalAmount__c = 100, PFR_IsPDFAttachedAndShare__c = false, PFR_BilledPartyAccount__c = lstEmetteur[0].Id)
                    };
            insert lstDocFin;

            trans = TestFactory.createTransaction(lstDocFin[0].Id);
            trans.PFR_CommInvoiceNumber__c = '4FTC0001235';
            trans.PFR_legalentityid__c = '3301';
            insert trans;


            trans.PFR_TECH_D365externalkey__c = '3301|4FTC0001235';
            trans.PFR_ReferenceFinDoc__c = lstDocFin[0].Id;
            update trans;

            
        }
    }
    @isTest static void testBatch(){
        Test.startTest();
        //Create contentversion with contentDocumentLink
        docFinConv = TestFactory.createContentVersionWithLink(lstDocFin[1].Id, 'FactureReparation', 'pdf');
        System.debug('££££ docFinConv '+ docFinConv);
        docFinConv.PFR_KeyD365Contentversion__c = '3301|4FTC0001235';
        update docFinConv;
        NOB_Batch_AttachedSharePDFOnDocFin.executeBatchMethod();
        Test.stopTest();
    }

    @isTest
    public static void testScheduleBatch() {        
         Test.starttest();
         NOB_Batch_AttachedSharePDFOnDocFin myClass = new NOB_Batch_AttachedSharePDFOnDocFin ();   
         String chron = '0 0 23 * * ?';        
         System.schedule('Test Sched', chron, myClass);
         Test.stopTest();
    }

}