/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_TransactionTriggerHandler_TEST
  -- - Author        : NPE
  -- - Description   : Test class for NOB_TransactionTriggerHandler
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 14-Dec-2021	NPE		1.0    	Initial version
  ----------------------------------------------------------------------
  **********************************************************************
*/
@isTest
public class NOB_TransactionTriggerHandler_TEST {

    static User userAdmin;
    static List<Account> lstEmetteur;
    static List<RecordType> lstRecordTypeDocFin;
    static Map<string, string> mapDocFinRecType;
    static List<PFR_FinancialDocument__c> lstDocNew;
    static PFR_Transaction__c trans;
    static User userBodyShop;
    static user userBackOffice;
    static Profile profil1;
    static Profile profilBO;
    static Account acc;
    static Contact cont;
    static UserRole role;
    static Account bs1;
    static  List<PFR_FinancialDocument__c>  lstdocFin;

    static{
        userAdmin = new User();

        userAdmin = TestFactory.createPrefikarUser('ScUserTest2');
        userAdmin.ProfileId = [SELECT Id,Name FROM Profile WHERE Name ='PRE_System Administrator' LIMIT 1].Id;
        userAdmin.NOB_isPrefikar__c = true;
        insert userAdmin;
        NOBTools.ProfileName='PRE_Back office/Credit management';

        System.runAs(userAdmin){

            acc =TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif');
            acc.ContactUser__c = userAdmin.Id;
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
            lstEmetteur[0].OwnerId = userAdmin.Id;
            lstEmetteur[0].NOB_isPrefikar__c = true;
            //HMO -- 30-03-2022
            lstEmetteur[0].NOB_SiretHeadquarters__c = System.Label.PFR_prefikarSiret;
            insert lstEmetteur;

            bs1 =TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif');
            insert bs1;

            userBackOffice = TestFactory.createUser('UserBO');
            profilBO=[SELECT Id FROM Profile WHERE Name='PRE_Back office/Credit management'];
            userBackOffice.ProfileId=profilBO.Id;
            userBackOffice.NOB_isPrefikar__c=true;
            userBackOffice.isAspis__c=false;
            insert userBackOffice;
            
            
        }
    }

    @isTest static void TransactionTest(){
        System.runAs(userAdmin){
            Test.StartTest();

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
            trans.PFR_ReferenceFinDoc__c = lstDocFin[1].Id;
            trans.PRE_canUpdateDocFin__c = false;

            update trans;


            Test.StopTest();

        }
    }
}