/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 01/12/2020
 * @last modified by  : JPI
 * Modifications Log 
 ==============================================================================
  Ver         Date            Author      Modification
 ==============================================================================
 * 1.0       11-19-2020        GBH        Initial Version
 * 1.1       01-15-2021        KPA
 * 1.2       05-07-2021        HMO        RSIW - 9883 (KPI des Disponibilites)
**/
@isTest
public with sharing class NOB_LC47_PriseDeRendezVousTEST {
    static User userAdmin;
    static list<Account> lstReparateur;
    static list<Account> lstAssureur;
    static List<Case> lstCase;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static List<Account> lstInsurerAccount;
    static List<NOB_Planning__c> lstPlanning;
    static List<Contact> lstInsuredContact;

    //RSIW - 9883
    static Case newCase;
    static List<Contact> lstContact;
    static List<Account> gesReseaureparateur;
    static WorkOrder wo;

    static {

        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){
          lstPlanning = new List<NOB_Planning__c>();

            lstInsurerAccount = new List<Account>{
                TestFactory.createInsurerAccount('AXA Assurance','FR')
            };
                lstInsurerAccount[0].NOB_SiretHeadquarters__c='Siret123';
            insert lstInsurerAccount;
            lstInsuredContact = new List<Contact>{
                TestFactory.createInsuredContact('John', 'Doe', lstInsurerAccount[0].Id, 'Alsace Lorraine')
            };
            insert lstInsuredContact;
            lstReparateur = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage PFK', 'Réseau Premium','siret124','Actif'),
                TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium','siret125','Actif'),
                TestFactory.createPrefikarBodyAccount('Garage PFK3', 'Réseau Premium','siret126','Actif')
            };
            lstReparateur[0].NOB_Ranking__c = 'Gold';
            lstReparateur[0].NOB_NetworkType__c = 'Hors réseau';
            lstReparateur[0].NOB_DarvaIdentifier__c = '53434554';
            //RSIW - 9883
            lstReparateur[0].ShippingCountry = 'France';
            lstReparateur[0].ShippingCountryCode = 'FR';
            lstReparateur[0].ShippingLatitude = 49.12739;
            lstReparateur[0].ShippingLongitude = 2.17758;
            lstReparateur[0].ShippingStreet = '9 rue de la fontaine d’ascot';
            lstReparateur[0].ShippingCity = 'Clery en Vexin';
            lstReparateur[0].ShippingPostalCode = '95420';
            lstReparateur[0].NOB_Ranking__c = 'Silver';
            lstReparateur[0].NOB_DateDebutPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            lstReparateur[0].NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            lstReparateur[0].NOB_Priorite__c = 'Priorise';
            lstReparateur[0].NOB_EngagementRate__c = 2;
            lstReparateur[0].NOB_Statut__c = 'Actif';
            lstReparateur[0].NOB_NetworkType__c = 'Réseau Platinium';
            lstReparateur[0].NOB_SkillSet__c = 'Electrique';
            lstReparateur[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            lstReparateur[0].NOB_TechZoneIntervention__c = '95420;';

            lstReparateur[1].NOB_NetworkType__c = 'Hors réseau';
            lstReparateur[2].NOB_NetworkType__c = 'Hors réseau';
            insert lstReparateur;


            //create Gestionnaire de réseau de réparateur
            gesReseaureparateur = new List<Account>{
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
            };
            gesReseaureparateur[0].ReferenceNumber__c = 'FR0121456789';
            insert gesReseaureparateur;


            lstAssureur = new List<Account>{
                TestFactory.createInsurerAccount('AXA assurance','FR'),
                TestFactory.createInsurerAccount('AXA assurance 2','FR')
            };
                 lstAssureur[0].NOB_SiretHeadquarters__c='Siret123';
lstAssureur[0].NOB_GTACode__c = '34032';
lstAssureur[0].VATNumber__c = '32223';

 lstAssureur[1].NOB_SiretHeadquarters__c='Siret123';
 lstAssureur[1].NOB_GTACode__c = '98322';
 lstAssureur[1].VATNumber__c = '83320';
            insert lstAssureur;

            //RSIW - 9883
            Id ContactRecTypeIdRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            Id ContactRecTypeIdAssure = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Fiche_Assure').getRecordTypeId();

            lstContact = new List<Contact>{
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '9 rue de la fontaine d’ascot',
                MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstReparateur[0].Id, RecordTypeId = ContactRecTypeIdRep, MailingLatitude = 49.12739, MailingLongitude =2.17758),
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '9 rue de la fontaine d’ascot',
                MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstInsurerAccount[0].Id, RecordTypeId = ContactRecTypeIdAssure, MailingLatitude = 49.12739, MailingLongitude = 1.84254)
            };
            insert lstContact;


            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur')
            };
            insert lstRelationCompte;



            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstReparateur[0].Id),
                TestFactory.createPlanning(lstReparateur[0].Id),
                TestFactory.createPlanning(lstReparateur[0].Id)
            };

            lstPlanning[0].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 16, 00, 0);
            lstPlanning[0].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+1, 17, 00, 0);
            lstPlanning[0].NOB_Status__c = 'Disponible';
            lstPlanning[0].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            
            lstPlanning[1].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 12, 00, 0);
            lstPlanning[1].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 13, 00, 0);
            lstPlanning[1].NOB_Status__c = 'Disponible';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();

            lstPlanning[2].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 17, 00, 0);
            lstPlanning[2].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 18, 00, 0);
            lstPlanning[2].NOB_Status__c = 'Disponible';
            lstPlanning[2].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();

            System.debug('££££ lstPlanning testClass '+ lstPlanning);

            insert lstPlanning;


			Date dt = Date.today().toStartOfMonth();
            lstCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', lstInsuredContact[0].Id, lstInsurerAccount[0].Id, 'AUDI', 'A3', '34343', 'Darva', dt,'756453','typeD','Réparation')
                    
                  
            };
            
            lstCase[0].NOB_BodyShop__c = lstReparateur[0].Id;
            lstCase[0].Status = 'Suivi_reparation';
            lstCase[0].Origin = 'Darva';
            lstCase[0].NOB_InsurerClaimNumber__c = '123456789zxx';
            lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(System.today().year(), System.today().month()-1,System.today().day()+1, 17, 00, 0);
            lstCase[0].NOB_DamageType__c = 'test';
            lstCase[0].NOB_VehicleRegistrationNumber__c = 'test';
            lstCase[0].NOB_VehicleBrand__c = 'PORS';
            lstCase[0].NOB_VehicleModel__c = '911';
            lstCase[0].NOB_SkillSet__c  = 'Electrique';
            insert lstCase;
            
                        Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month()-1, System.today().day(), 17, 00, 0);
            newCase = TestFactory.createCaseStandard('Nouvelle', lstContact[1].Id, lstInsurerAccount[0].Id, 'NISS', 'GTR','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture');
            insert newCase;

            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstReparateur[0].id),
                TestFactory.createPlanning(lstReparateur[0].id),
                TestFactory.createPlanning(lstReparateur[1].id)
            };

            for(integer i = 0; i <= 2; i++){
                lstPlanning[i].NOB_Status__c = 'Disponible';
                lstPlanning[i].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+(i+1), 16, 00, 0);
                lstPlanning[i].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+(i+1), 17, 00, 0);
            }
            insert lstPlanning;
        }
    }

    @isTest
    public static void generateDisposTEST(){
        System.runAs(userAdmin){

            Test.startTest();
            NOB_LC47_PriseDeRendezVous.generateDispos(lstReparateur[0].Id,1);
            Test.stopTest();
        }
    }
    
     @isTest
    public static void generateGenruleEngineCOm(){
        System.runAs(userAdmin){

            Test.startTest();
            NOB_LC47_PriseDeRendezVous.getRuleEngineCompetences(lstCase[0].Id, new Map<String,List<String>>());
            Test.stopTest();
        }
    }

    @isTest
    public static void createOtherDispossssTEST(){
        System.runAs(userAdmin){
           // String startDate = System.today().year() + '-'+ System.today().month() + '-' + (System.today().day()+1) + 'T16:00:44.268Z';
           // String endDate = System.today().year() + '-'+ System.today().month() + '-' + (System.today().day()+1) + 'T17:00:44.268Z';

            Test.startTest();
            //NOB_Planning__c p = NOB_LC47_PriseDeRendezVous.createOtherDispossss(lstReparateur[0].Id, lstCase[0].Id, startDate, endDate);
             newCase.Status = 'Affectation';
                update newCase;

                String startDate = System.today().year() + '-'+ System.today().month() + '-' + (System.today().day()+1) + 'T16:00:00.000Z';
                String endDate = System.today().year() + '-'+ System.today().month() + '-' + (System.today().day()+1) + 'T17:00:00.000Z';
                NOB_LC47_PriseDeRendezVous.lstRepTest = lstReparateur;

                Map<String, Object> mapPlanning = NOB_LC47_PriseDeRendezVous.createOtherDispossss(lstReparateur[0].Id, newCase.Id, startDate, endDate);

                Map<String, String> mapWO = new Map<String, String>();
                mapWO.put('CaseId', String.valueOf(newCase.Id));
                mapWO.put('BodyshopId', String.valueOf(lstPlanning[0].NOB_BodyShop__c));
                mapWO.put('dispoId', String.valueOf(lstPlanning[0].Id));
                NOB_LC47_PriseDeRendezVous.updateWOrkOrderFlags(mapWO, true);
            Test.stopTest();

            for(WorkOrder work : [SELECT Id, workOrderNumber, NOB_Dispo10Jsur3PremiersReparateurs__c, NOB_Dispo10Jsur10PremiersReparateurs__c,NOB_Dispo10JensembleReparateur__c, NOB_AffectationManuelle__c, NOB_CanalDaffectation__c, NOB_Reparateur__c, CaseId from WorkOrder WHERE NOB_Reparateur__c =: lstReparateur[0].Id and CaseId =: newCase.Id ORDER BY workOrderNumber DESC Limit 1]){
            	System.assertEquals(work.NOB_Dispo10Jsur3PremiersReparateurs__c, true);
            	System.assertEquals(work.NOB_Dispo10Jsur10PremiersReparateurs__c, true);
            	System.assertEquals(work.NOB_Dispo10JensembleReparateur__c, true);
            	System.assertEquals(work.NOB_AffectationManuelle__c, true);
            	System.assertEquals(work.NOB_CanalDaffectation__c, 'MyPrefikar');
            }
        }
    }
    @isTest
    public static void createWorkOrderHorsResTEST(){
        System.runAs(userAdmin){

            Test.startTest();
            Map<String, Object> mapCase = NOB_LC47_PriseDeRendezVous.createWorkOrderHorsRes(lstReparateur[0].Id, lstCase[0].Id);
            Test.stopTest();
            Case ca = [SELECT Id, NOB_TECH_DispoId__c FROM Case WHERE Id=: lstCase[0].Id];
            System.assertEquals(null, ca.NOB_TECH_DispoId__c);
        }
    }
    @isTest
    public static void getDisponibilitiesTEST(){
        System.runAs(userAdmin){

            Test.startTest();
            Map<String,Object> mapDispo = NOB_LC47_PriseDeRendezVous.getDisponibilities(lstCase[0].Id);
            Test.stopTest();
        
        }
    }

    @isTest
    public static void getDisponibilyForReparateurTEST(){
        System.runAs(userAdmin){

            Test.startTest();
            Map<String,Object> mapDispo = NOB_LC47_PriseDeRendezVous.getDisponibilyForReparateur(lstCase[0].Id, 'Garage');
            Test.stopTest();
   
        }
    }
    @isTest
    public static void createWorkOrderTEST(){
        System.runAs(userAdmin){
            long t = lstPlanning[0].NOB_StartDate__c.getTime();
            Test.startTest();
            Map<String,Object>  mapWO = NOB_LC47_PriseDeRendezVous.createWorkOrder(lstPlanning[0].Id, lstCase[0].Id, String.valueOf(t));
            Map<String,Object>  mapWO2 = NOB_LC47_PriseDeRendezVous.createWorkOrder(lstPlanning[0].Id, lstCase[0].Id, null);
            Test.stopTest();
           
        }
    }
    @isTest
    public static void searchDBTEST(){
        System.runAs(userAdmin){
            long t = lstPlanning[0].NOB_StartDate__c.getTime();
            Test.startTest();
            String lstRet = NOB_LC47_PriseDeRendezVous.searchDB('Account','Name','Id',10,'Name','garage');
            String lstRet2 = NOB_LC47_PriseDeRendezVous.searchDB('Competences','Name','Id',10,'Name','garage');
            Test.stopTest();

        }
    }
    
   @isTest
    public static void getRuleEngineCompetencesTEST(){
        System.runAs(userAdmin){
            
            Test.startTest();
            //Map<String,Object> newAcc = NOB_LC47_PriseDeRendezVous.getRuleEngineCompetences(lstCase[0].id, new Map<String, List<String>>{});
            
             //Map<String,Object> rs = new  Map<String,Object>([select id from account]);
            //System.assertNotEquals(0, lstAcc.size());

            Test.stopTest();
        }
    }
    
    @isTest
    public static void createReparateurTEST(){
        System.runAs(userAdmin){
            
            Test.startTest();
            Account newAcc = NOB_LC47_PriseDeRendezVous.createReparateur('name', '354585424', '10 Rue de la Fontaine d’Ascot', '95420', 'Cléry-en-Vexin', 'Allier', 'France');
            
			List<account> lstAcc= new List<account>([select id from account]);
            System.assertNotEquals(0, lstAcc.size());             

            Test.stopTest();
        }
    }
    @isTest
    public static void doGenDispoTEST(){
        System.runAs(userAdmin){
            
            Test.startTest();
            String s = lstReparateur[0].id;
			List<NOB_Planning__c> lstPlanning=NOB_LC47_PriseDeRendezVous.doGenDispo(2,s);
                         

            Test.stopTest();
        }
    }
}