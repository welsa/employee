/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_AP56_DocumentFinancierSharing_TEST
  -- - Author        : ABT
  -- - Description   : Test class for NOB_AP56_DocumentFinancierSharing
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 14-JUL-2021  SRA    1.0     Initial Version
  -- 30-MAY-2022  KEM    1.1     Increase coverage 
  ----------------------------------------------------------------------
 **********************************************************************
*/

@isTest
public with sharing class NOB_AP56_DocumentFinancierSharing_TEST {
    static User userAdmin;
    static list<Account> lstReparateur;
    static list<Account> lstAssureur;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static list<NOB_AccountRelationship__c> lstRelationCompteBis;
    static list<Contact> lstContact;
    static list<User> lstUsers;
    static  List<PFR_FinancialDocument__c>  lstdocFin;
    static Account bs1;
    static Case requete;
    static Case requete2;
    static Contact assureCon;
    static Account gesReseaureparateur;
    
    static {

    UserRole portalRole1 = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
    userAdmin = TestFactory.createPrefikarUser('ScUserTest');
    userAdmin.UserRoleId = portalRole1.Id;
    insert userAdmin;
    system.runas(userAdmin){
        
        String AccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Assureur').getRecordTypeId();    
        lstReparateur = new List<Account>{
            TestFactory.createPrefikarBodyAccount('Garage PFK', 'Réseau Premium', '44057565200035','Actif'),
            TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif')
        };

        lstReparateur[0].NOB_Ranking__c = 'Gold';
        lstReparateur[0].ContactEmail__c = 'test@test.com';
        lstReparateur[0].VATNumber__c = 'vat245686';
        lstReparateur[0].ReferenceNumber__c = 'FR0123456789';
        lstReparateur[0].ASEntity__c = 'ASFR1';
        lstReparateur[0].ExpertSubstitutionMethod__c = 'Forced';
        lstReparateur[0].OwnerId = userAdmin.Id;

        lstReparateur[1].NOB_Ranking__c = 'Gold';
        lstReparateur[1].ContactEmail__c = 'tsest@test.com';
        lstReparateur[1].VATNumber__c = 'vat245486';
        lstReparateur[1].ReferenceNumber__c = 'FR0123656787';
        lstReparateur[1].ASEntity__c = 'ASFR1';
        lstReparateur[1].ExpertSubstitutionMethod__c = 'Forced';
        lstReparateur[1].OwnerId = userAdmin.Id;

        insert lstReparateur;

        lstAssureur = new List<Account>{
            TestFactory.createInsurerAccount('AXA RM','Nord'),
            TestFactory.createInsurerAccount('AXA assurance 2','Bourgogne')
        };

        lstAssureur[0].ReferenceNumber__c = 'FR0121237464';
        lstAssureur[0].NOB_ClamentureSinistreFacturation__c = '^\\d{14}73$';
        lstAssureur[0].NOB_SiretHeadquarters__c = '31049995900891';
        lstAssureur[0].NOB_NobilasCommission__c = 5.0;

        lstAssureur[1].ReferenceNumber__c = 'FR0121237424';
        lstAssureur[1].NOB_ClamentureSinistreFacturation__c = '^\\d{14}73$';
        lstAssureur[1].NOB_SiretHeadquarters__c = '31049995900891';
        lstAssureur[1].NOB_NobilasCommission__c = 5.0;
        insert lstAssureur;

        lstContact = new List<Contact>{
            new Contact(),
            new Contact(),
            new Contact()
        };

        lstContact[0].FirstName = 'contact 1';
        lstContact[0].Lastname = 'McTesty 1';
        lstContact[0].Email = 'contact.test1@nobilastest.com';
        lstContact[0].AccountId = lstReparateur[0].id;
        lstContact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
        
        lstContact[1].FirstName = 'contact 2';
        lstContact[1].Lastname = 'McTesty 2';
        lstContact[1].Email = 'contact.test1@nobilastest.com';
        lstContact[1].AccountId = lstReparateur[1].id;
        lstContact[1].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
        
        lstContact[2].FirstName = 'contact 3';
        lstContact[2].Lastname = 'McTesty 3';
        lstContact[2].Email = 'contact.test3@nobilastest.com';
        lstContact[2].AccountId = lstReparateur[1].id;
        lstContact[2].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
        insert lstContact;

        Profile profileBS = [Select Id from Profile where name = 'CCP Bodyshop'];

        lstRelationCompte = new List<NOB_AccountRelationship__c>{
            TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[1].Id, 'Réparateur - Assureur')
        };
            
         lstRelationCompteBis = new List<NOB_AccountRelationship__c>{
            TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
            TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[1].Id, 'Réparateur - Assureur')
        };
            
            insert lstRelationCompteBis;
        
           assureCon = TestFactory.createInsuredContact('contact', 'Assuree', lstAssureur[0].Id,'Nord');
           insert assureCon;
               
           requete = TestFactory.createCaseStandard('Nouvelle', assureCon.Id, lstAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
           System.today().month()-1, 
           System.today().day() + 1, 17, 00, 0),'AR1234','Body','Réparation');
           requete.PFR_TECH_HasASInvoice__c = true;
           insert requete;
        
           requete2 = TestFactory.createCaseStandard('Nouvelle', assureCon.Id, lstAssureur[0].Id, 'KIA', 'Eltrix','67856xyz','test1',Datetime.newInstance(System.today().year(),
           System.today().month()-1, 
           System.today().day() + 1, 17, 00, 0),'AR1234','Body','Réparation');
           requete2.PFR_TECH_HasASInvoice__c = true;
           insert requete2;
        
           gesReseaureparateur = TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035');
           gesReseaureparateur.ReferenceNumber__c = 'FR0121456789';
           insert gesReseaureparateur;

        String docfinRT_FR = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByDeveloperName().get('FR').getRecordTypeId();
        String docfinRT = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByDeveloperName().get('CH').getRecordTypeId();
        bs1 =TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif');
        bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Expert').getRecordTypeId();
        bs1.NOB_isPrefikar__c = false;
        insert bs1;
        lstdocFin = new List<PFR_FinancialDocument__c>{
            new PFR_FinancialDocument__c(recordTypeId= docfinRT ,PFR_FinancialDocumentFrom__c=bs1.Id,PFR_ExclVATTotalAmount__c=18, 
                                            PFR_DocumentStatus__c='VL', PFR_RepairInvoiceNumber__c='76543',
                                            PFR_VATAmount__c =10,PFR_InclVATTotalAmount__c = 10, PFR_BilledPartyAccount__c = lstReparateur[0].Id,
                                         	PFR_FinDocDateOfIssue__c = System.today(),
                                         	PFR_Case__c = requete.Id
                                            
                                        ),
                new PFR_FinancialDocument__c(recordTypeId= docfinRT_FR ,PFR_FinancialDocumentFrom__c=lstReparateur[0].Id,PFR_ExclVATTotalAmount__c=2, 
                                            PFR_DocumentStatus__c='NU', PFR_RepairInvoiceNumber__c='767437' /*PFR_InsurerCaseNumber__c='1234524316726573'*/,
                                            PFR_VATAmount__c =2,PFR_InclVATTotalAmount__c = 2, PFR_BilledPartyAccount__c = lstReparateur[0].Id,
                                         	PFR_FinDocDateOfIssue__c = System.today(),PFR_CaseBusinessProvider__c=lstAssureur[0].Id,
                                         	PFR_Case__c = requete.Id
                                           
                                    
                                        )
                };
        insert lstdocFin;
        
        lstUsers = new List<User>{
            TestFactory.createUser('testUser1'),
            TestFactory.createUser('testUser2'),
            TestFactory.createUser('testUser2')
        };
        lstUsers[0].ContactId = lstContact[0].id;
        lstUsers[0].NOB_isPrefikar__c = true;
        lstUsers[0].ProfileId = profileBS.id;

        lstUsers[1].ContactId = lstContact[1].id;
        lstUsers[1].NOB_isPrefikar__c = true;
        lstUsers[1].ProfileId = profileBS.id;
        
        lstUsers[2].ContactId = lstContact[2].id;
        lstUsers[2].NOB_isPrefikar__c = true;
        lstUsers[2].ProfileId = profileBS.id;
        // insert lstUsers;     
        // 
    }
}

    @isTest
    public static void onAfterUpdateDocFinValidate(){
        System.runAs(userAdmin){
            Test.startTest();
                insert lstUsers;
            
            Test.stopTest();
            
            Set<PFR_FinancialDocument__Share> setDocFinShare = new Set<PFR_FinancialDocument__Share>([SELECT Id FROM PFR_FinancialDocument__Share where UserOrGroupId IN :lstUsers]);
            
            System.assertEquals(6, setDocFinShare.size());
        }
    }

    @isTest
    public static void testDocumentFinancierSharing(){
    System.runAs(userAdmin){
        Set <Id> setAccountId = new Set <Id>();
        setAccountId.add(lstContact[0].AccountId);
        Test.startTest();
            NOB_AP56_DocumentFinancierSharing.documentFinancierSharing(lstdocFin, setAccountId);
        Test.stopTest();
        System.assertEquals(2, [SELECT id FROM PFR_FinancialDocument__Share].size());
    }
}

//KEM 30/05/2022 RSIW-11049  create test method to increase coverage  

@isTest
public static void testcheckValidationFR(){
    System.runAs(UserAdmin){

        Test.startTest();
        lstdocFin[1].PFR_VATAmount__c = 3;
        lstdocFin[1].PFR_InclVATTotalAmount__c = 1;
        lstdocFin[1].PFR_InsurerCaseNumber__c='1234524316726573';
        update lstdocFin;
        
        Test.stopTest();
        
        String DocStatus = [SELECT  PFR_DocumentStatus__c FROM PFR_FinancialDocument__c WHERE Id =: lstdocFin[1].Id]?.PFR_DocumentStatus__c;

        System.assertEquals( DocStatus, 'PY');
    }

}

@isTest
public static void testcheckValidationFRAfterUpdate(){
    System.runAs(UserAdmin){
        Test.startTest();

        lstdocFin[1].PFR_InsurerCaseNumber__c = '1234546376827373';
        lstdocFin[1].PFR_InclVATTotalAmount__c = 19;       
        update lstdocFin;
        
        Test.stopTest();

        String DocStatus = [SELECT  PFR_DocumentStatus__c FROM PFR_FinancialDocument__c WHERE Id =: lstdocFin[1].Id]?.PFR_DocumentStatus__c;
        System.assertEquals( DocStatus, 'PY');

    }

}
    
    @isTest
public static void testcheckValidationInsert(){
    System.runAs(UserAdmin){
        Test.startTest();
				        String docfinRT_FR = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByDeveloperName().get('FR').getRecordTypeId();
               PFR_FinancialDocument__c docFin =     new PFR_FinancialDocument__c(recordTypeId= docfinRT_FR ,PFR_FinancialDocumentFrom__c=lstReparateur[0].Id,PFR_ExclVATTotalAmount__c=2, 
                                            PFR_DocumentStatus__c='NU', PFR_RepairInvoiceNumber__c='8434382', PFR_InsurerCaseNumber__c='1234567890123473',
                                            PFR_VATAmount__c =2,PFR_InclVATTotalAmount__c = 2, PFR_BilledPartyAccount__c = lstReparateur[0].Id,
                                         	PFR_FinDocDateOfIssue__c = System.today(),PFR_CaseBusinessProvider__c=lstAssureur[0].Id,
                                         	PFR_Case__c = requete2.Id
                                           
                                    
                                        )   ;
        insert docFin;
        
        Test.stopTest();

        String DocStatus = [SELECT  PFR_DocumentStatus__c FROM PFR_FinancialDocument__c WHERE Id =: docFin.Id]?.PFR_DocumentStatus__c;
        System.assertEquals( DocStatus, 'PY');

    }

}
}