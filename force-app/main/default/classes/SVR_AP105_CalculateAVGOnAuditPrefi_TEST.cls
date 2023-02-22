/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 03-29-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-29-2021   ARA   Initial Version
**/
@isTest
public with sharing class SVR_AP105_CalculateAVGOnAuditPrefi_TEST {
    static List<User> listUser;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static List<SVR_AuditPreficontrol__c> listAuditPreficontrol;
    static List<SVR_DossierPreficontrol__c> listDossierPreficontrol;
    static List<SVR_AuditReseau__c> listAuditReseau;
    static List<User> listPrefitoolUser;
    static List<NOB_AccountRelationship__c> listAccountRelationship;
    static list<Account> lstAssureur;
    static list<NOB_TauxNeg__c> lstTauxNeg;


    static{
        //Create User 'System admin'
        listUser = new List<User>{
            TestFactory.createPrefikarUser('userAdmin')
        };
        insert listUser;
        listAccountRelationship = new List<NOB_AccountRelationship__c>();


        System.runAs(listUser[0]){
            
            //Create users
            listPrefitoolUser = new List<User>{
                TestFactory.createPrefitoolUser('ResponsableSector'),
                TestFactory.createPrefitoolUser('NomDeLauditeur')
            };
            insert listPrefitoolUser;

            //Create Account
            listAccount = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage Prefitool Spoon', 'Réseau Platinium')
            };
            listAccount[0].SVR_AreaManager__c = listPrefitoolUser[0].Id;
            insert listAccount;
            lstAssureur = new List<Account>{
                TestFactory.createInsurerAccount('AXA assurance','Nord'),
                TestFactory.createInsurerAccount('AXA assurance 2','Bourgogne')
            };
            lstAssureur[0].ReferenceNumber__c = 'FR0121237464';
            // lstAssureur[0].NOB_Type__c = 'Réparateur - Assureur';
            lstAssureur[1].ReferenceNumber__c = 'FR0121237424';
            lstAssureur[1].Name = 'AXA RM';
            insert lstAssureur;

            listAccountRelationship.add(TestFactory.createRelationCompte(listAccount[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'));
            listAccountRelationship[0].NOB_Type__c = 'Réparateur - Assureur';
            insert listAccountRelationship;

            lstTauxNeg = new List <NOB_TauxNeg__c>{
                TestFactory.createTauxNeg(listAccountRelationship[0].Id, Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()), Date.newInstance(System.today().year(), System.today().month()+2, System.today().day()))
            };
            insert lstTauxNeg;

            //create Audit Reseau
            listAuditReseau = new List<SVR_AuditReseau__c>{
                TestFactory.createAuditRS(listPrefitoolUser[0],listAccount[0]),
                TestFactory.createAuditRS(listPrefitoolUser[0],listAccount[0])
            };
            listAuditReseau[0].SVR_NomAuditeur__c = listPrefitoolUser[1].id;
            listAuditReseau[0].SVR_ResponsableSecteur__c = listPrefitoolUser[0].Id;
            listAuditReseau[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId();
            listAuditReseau[1].SVR_NomAuditeur__c = listPrefitoolUser[1].id;
            listAuditReseau[1].SVR_ResponsableSecteur__c = listPrefitoolUser[0].Id;
            listAuditReseau[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId();

            insert listAuditReseau;

            //create Audit preficontrol 
            listAuditPreficontrol = new List<SVR_AuditPreficontrol__c>{
                TestFactory.createAuditpreficontrol(listAuditReseau[0]),
                TestFactory.createAuditpreficontrol(listAuditReseau[0])
            };
            listAuditPreficontrol[0].recordTypeId = Schema.SObjectType.SVR_AuditPreficontrol__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAPCM).getRecordTypeId();
            listAuditPreficontrol[1].recordTypeId = Schema.SObjectType.SVR_AuditPreficontrol__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAPCM).getRecordTypeId();
            insert listAuditPreficontrol;

            //create Dossier preficontrol
            listDossierPreficontrol = new List<SVR_DossierPreficontrol__c>{
                TestFactory.createDossierPreficontrol(listAuditPreficontrol[0],10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10),
                TestFactory.createDossierPreficontrol(listAuditPreficontrol[1],11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11)
            };
            listDossierPreficontrol[0].SVR_ChiffrageInitialHTGarage__c = 10;
            listDossierPreficontrol[0].SVR_ChiffrageFinalHTPreficontrol__c = 9;
            listDossierPreficontrol[0].SVR_ChiffrageInitialHTGarage__c = 10;
            listDossierPreficontrol[0].SVR_ChiffrageExpertHT__c = 9;
            listDossierPreficontrol[0].recordTypeId = Schema.SObjectType.SVR_DossierPreficontrol__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeDPCM).getRecordTypeId();
            listDossierPreficontrol[1].SVR_ChiffrageInitialHTGarage__c = 10;
            listDossierPreficontrol[1].SVR_ChiffrageExpertHT__c = 9;
            listDossierPreficontrol[0].SVR_ChiffrageInitialHTGarage__c = 10;
            listDossierPreficontrol[0].SVR_ChiffrageFinalHTPreficontrol__c = 10;
            listDossierPreficontrol[1].recordTypeId = Schema.SObjectType.SVR_DossierPreficontrol__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeDPCM).getRecordTypeId();
        
        
        }
    }
    @isTest
    public static void onAfterInsert(){
        System.runAs(listUser[0]){
            Test.startTest();
            insert listDossierPreficontrol;
            Test.stopTest();
        }
    }
    @isTest
    public static void onAfterUpdate(){
        System.runAs(listUser[0]){
            insert listDossierPreficontrol;
            Test.startTest();
            List<SVR_DossierPreficontrol__c> lstDPInseted =[SELECT SVR_T1GarageCal__c,SVR_MontantPiecesExpert__c FROM SVR_DossierPreficontrol__c WHERE id IN : listDossierPreficontrol];
            lstDPInseted[0].SVR_T1GarageCal__c = 20.00;
            lstDPInseted[0].SVR_MontantPiecesExpert__c = 30.00;
            update lstDPInseted ;
            Test.stopTest();
        }
    }
    @isTest
    public static void onAfterDelete(){
        System.runAs(listUser[0]){
            insert listDossierPreficontrol;
            Test.startTest();
            delete listDossierPreficontrol[0];
            Test.stopTest();
        }
    }
}