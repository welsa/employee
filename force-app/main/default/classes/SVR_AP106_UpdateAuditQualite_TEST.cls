/**
 * @description       : This class will test the insertion and deletion of dossier for each audit reseau
 * @author            : KEM
 * @group             : 
 * @last modified on  : 06/06/2022
 * @last modified by  : KEM
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   06/06/2022   KEM   Initial Version
**/
@isTest

public class SVR_AP106_UpdateAuditQualite_TEST {

    static List<User> listUsers;
    static List<Account> listAccount;
    static List<SVR_AuditReseau__c> listAuditRS;
    static List<Audit_Plan_Action__c> listPlanAction;
    static List<NOB_AccountRelationship__c> listAccountRelationship;
    static list<Account> lstAssureur;
    static list<NOB_TauxNeg__c> lstTauxNeg;
    static list<SVR_Dossier__c> lstDossier;
    static list<Contact> lstContact;
    static list<SVR_AuditReseau__c> lstAuditNotInserted;

    

    Static{

        listUsers = new List<User>();
        listAccount = new List<Account>();
        listAuditRS = new List<SVR_AuditReseau__c>();
        listPlanAction = new List<Audit_Plan_Action__c>();
        listAccountRelationship = new List<NOB_AccountRelationship__c>();
        lstDossier = new List<SVR_Dossier__c>();
        lstContact = new List<Contact>();
        lstAuditNotInserted = new List<SVR_AuditReseau__c>();

        listUsers.add(SVR_TestFactory.createUser('ScUserTest'));
        listUsers[0].NOB_isPrefikar__c = true;
        insert listUsers;

        


        System.runAs(listUsers[0]){

            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
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
            System.debug('@@@ testclassshane1' + listAuditRS);

            lstTauxNeg = new List <NOB_TauxNeg__c>{
                TestFactory.createTauxNeg(listAccountRelationship[0].Id, Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()), Date.newInstance(System.today().year(), System.today().month()+2, System.today().day()))
            };
            insert lstTauxNeg;

            lstContact.add(SVR_TestFactory.createContact('Test1'));
            lstContact.add(SVR_TestFactory.createContact('Test2'));
            lstContact[0].AccountId = listAccount[0].Id;
            lstContact[1].AccountId = listAccount[0].Id;
            lstContact[0].Email = 'Test@gmail.com';
            lstContact[1].Email = 'Test@gmail.com';
            lstContact[0].NOB_FunctionServices__c = 'Dirigeant';
            lstContact[1].NOB_FunctionServices__c = 'Dirigeant';

            insert lstContact;

            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            for (integer i = 0; i < 3; i++) {
    
                listAuditRS[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();
                listAuditRS[0].SVR_ResponsableSecteur__c = listUsers[0].Id;
                listAuditRS[0].SVR_NomAuditeur__c = listUsers[0].Id;
                listAuditRS[0].SVR_RepairerUser__c = listUsers[0].Id;
               
            }
            insert listAuditRS;

            

            System.debug('@@@ testclassshane1' + listAuditRS);




            lstDossier.add(SVR_TestFactory.createDossier('Test 1'));
            lstDossier[0].RecordTypeId = Schema.SObjectType.SVR_Dossier__c.getRecordTypeInfosByDeveloperName().get('SVR_Dossier').getRecordTypeId();
            lstDossier[0].SVR_AuditRS__c = listAuditRS[0].Id;
            // lstDossier[0].SVR_FactDesPiecesAchteesConforEurope__c    = 'Oui';
            // lstDossier[0].SVR_OrdreDeReparationSigne__c              = 'Oui';
            // lstDossier[0].SVR_CompletudeDuBonVRAller__c              = 'Oui';
            // lstDossier[0].SVR_SADPhotosLaRestitutionVR__c            = 'Oui';
            // lstDossier[0].SVR_PhotosLaRestitutionVR__c               = 'Oui';
            // lstDossier[0].SVR_MiseDispositionVRDebutDesTravaux__c    = 'Oui';
            // lstDossier[0].SVR_ProcesVerbalDeRestitution__c           = 'Oui';
            // lstDossier[0].SVR_PhotosLaRestitutionVhAssure__c         = 'Oui';
            // lstDossier[0].SVR_CompletudeDuBonVRRetour__c             = 'Oui';          
            // lstDossier[0].SVR_SADRealiseLieuLheurePrevuAller__c      = 'Oui';
            // lstDossier[0].SVR_SADProcesVerbalDeRestitution__c        = 'Oui';
            // lstDossier[0].SVR_SADRestitutionConforme__c              = 'Oui';
            // lstDossier[0].SVR_SADPhotosLaRestitutionVhAssure__c      = 'Oui';
            // lstDossier[0].SVR_RespectDesAccordsTarifairesNegocies__c = 'Oui';
            // lstDossier[0].SVR_TransmissionFactureClient__c           = 'Oui';
            // lstDossier[0].SVR_PresentationsDejustificatifsDachats__c = 'Oui';
            lstDossier[0].SVR_ReceptionRapporDefinitifExpert__c      = 'Oui';
            lstDossier[0].SVR_ConformeDerniersChiffrageDeLexpert__c  = 'Oui';

            System.debug('@@@ testclassshane2' + lstDossier);
            
        }
    }

    // @isTest
    // public static void getDossiers_Test(){
    //     System.runAs(listUsers[0]){
    //         insert lstDossier; 
    //         Set<Id> setAudits = new Set<Id>();   

    //         for(SVR_AuditReseau__c Auditrs : listAuditRS){
    //             setAudits.add(Auditrs.id);
    //         }

    //         Test.startTest();
    //         SVR_AP106_UpdateAuditQualite.getDossiers(setAudits);
    //         Test.stopTest();
    //     }
    // }

    @isTest
    public static void afterInsert_SVR_Dossier(){
        System.runAs(listUsers[0]){
            Test.startTest();
                insert lstDossier; 
            Test.stopTest();
        }
    }

    @isTest
    public static void afterUpdate_SVR_Dossier(){
        System.runAs(listUsers[0]){
            insert lstDossier; 
            Test.startTest();
            lstDossier[0].SVR_FactDesPiecesAchteesConforEurope__c = 'Non';
            update lstDossier; 
            Test.stopTest();
        }
    }

    // @isTest
    // public static void searchContactDirigeant_Test(){
    //     System.runAs(listUsers[0]){

    //         Test.startTest();
    //         SVR_AP106_UpdateAuditQualite.searchContactDirigeant(listAuditRS);
    //         Test.stopTest();
    //     }
    // }

    @isTest
    public static void afterInsert_AuditRS(){
        System.runAs(listUsers[0]){

            lstAuditNotInserted.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            lstAuditNotInserted[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();
            lstAuditNotInserted[0].SVR_ResponsableSecteur__c = listUsers[0].Id;
            lstAuditNotInserted[0].SVR_NomAuditeur__c = listUsers[0].Id;
            lstAuditNotInserted[0].SVR_RepairerUser__c = listUsers[0].Id;
            lstAuditNotInserted[0].SVR_StatutReseau__c = 'Audit Cloturé';
            System.debug('Test shane 10' + lstAuditNotInserted[0]);


            Test.startTest();
                insert lstAuditNotInserted; 
            Test.stopTest();
        }
    }
}