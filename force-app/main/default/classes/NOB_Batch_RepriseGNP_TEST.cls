/*************************************************************************************
Class Name - NOB_Batch_RepriseGNP_TEST
Version - 1.0
Created Date - 30-03-2022
Function - Test class for NOB_Batch_RepriseGNP_V2
#Ticket  - RSIW : 11035

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           30-03-2022   Initial version
*************************************************************************************/
@isTest(SeeAllData=true)
private with sharing class NOB_Batch_RepriseGNP_TEST {
    private NOB_Batch_RepriseGNP_TEST() {

    }
    static User userAdmin;
    static List<Account> lstBodyShop;
    static List<Case> lstCases;
    static List<WorkOrder> lstWorkOrder;
    static Pricebook2 pricebook;
    static NOB_AccountPricebook__c catalogueCompte;
    static List<Contact> listContactAssure;
    static List<Account> listAccAssureur;

    static {
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){
            lstBodyShop = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Premium', '44057565200035','Prospect'),
                TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Premium', '44057565200035','Inactif')  
            };

            lstBodyShop[0].NOB_Ranking__c = 'Gold';
            lstBodyShop[0].NOB_SiretHeadquarters__c ='Test';
            lstBodyShop[0].BillingCity = 'Paris';
            lstBodyShop[0].BillingCountry = 'France';
            lstBodyShop[0].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[0].BillingPostalCode = '75011';
            lstBodyShop[0].ContactEmail__c = 'test32@gmail.com';
            lstBodyShop[0].VATNumber__c='544';
            lstBodyShop[0].ReferenceNumber__c = 'FR0123656787';
            lstBodyShop[0].ASEntity__c = 'ASFR1';
            lstBodyShop[0].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[0].Phone = '0123456789';
            
            lstBodyShop[1].NOB_Ranking__c = 'Silver';
            lstBodyShop[1].NOB_SiretHeadquarters__c ='Test1';
            lstBodyShop[1].BillingCity = 'Paris';
            lstBodyShop[1].BillingCountry = 'France';
            lstBodyShop[1].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[1].BillingPostalCode = '75011';
            lstBodyShop[1].ContactEmail__c = 'test324@gmail.com';
            lstBodyShop[1].VATNumber__c='5445';
            lstBodyShop[1].ReferenceNumber__c = 'FR0123656887';
            lstBodyShop[1].ASEntity__c = 'ASFR1';
            lstBodyShop[1].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[1].Phone = '0123456789';
            
            lstBodyShop[2].NOB_SiretHeadquarters__c ='Test2';
            lstBodyShop[2].BillingCity = 'Paris';
            lstBodyShop[2].BillingCountry = 'France';
            lstBodyShop[2].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[2].BillingPostalCode = '75011';
            lstBodyShop[2].ContactEmail__c = 'test32443@gmail.com';
            lstBodyShop[2].VATNumber__c='54453';
            lstBodyShop[2].ReferenceNumber__c = 'FR0123636887';
            lstBodyShop[2].ASEntity__c = 'ASFR1';
            lstBodyShop[2].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[2].Phone = '0123456789';
            lstBodyShop[2].NOB_Ranking__c = 'Bronze';
            lstBodyShop[2].NOB_StatusReason__c = 'Rétractation';
            insert lstBodyShop;

            listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','Nord'),TestFactory.createInsurerAccount('accAssureur1','Bourgogne'),TestFactory.createInsurerAccount('accAssureurAxa','31049995900891')};
            listAccAssureur[0].Nob_CTICampaignNumber__c = 'Test';
            listAccAssureur[0].ReferenceNumber__c = 'FR0121237264';
			listAccAssureur[0].Phone = '0123456789';
            listAccAssureur[1].ReferenceNumber__c = 'FR0121237464';
            listAccAssureur[1].Nob_CTICampaignNumber__c = 'Test1';
            insert listAccAssureur;
			
            listContactAssure = new List<Contact>();
			listContactAssure.add(TestFactory.createInsuredContact('contact', 'Assuree', listAccAssureur[0].Id,'Nord'));
            listContactAssure.add(TestFactory.createInsuredContact('contact1', 'Assuree1', listAccAssureur[1].Id,'Bourgogne'));
            listContactAssure.add(TestFactory.createInsuredContact('contact2', 'Assuree2', listAccAssureur[2].Id,'Bourgogne'));
            listContactAssure[2].Email='conAssure2@gmail.com';
            insert listContactAssure;
            
            pricebook = new Pricebook2(Name='AXA-SAD',NOB_Offer__c='SAD',IsActive=true);
            insert pricebook;
            
            catalogueCompte = new NOB_AccountPricebook__c(Name='AXA Offre SAD',NOB_Account__c=listAccAssureur[2].Id,NOB_Pricebook__c=pricebook.Id); 
            insert catalogueCompte;

            lstCases = new List<Case>();
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[0].Id, listAccAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
            System.today().month()-4, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[1].Id, listAccAssureur[1].Id, 'BMW', 'X6','128765sdd','test2',Datetime.newInstance(System.today().year(),
            System.today().month()-4, 
            System.today().day(), 17, 00, 0),'AR16534','Body','Réparation'));
            lstCases[0].NOB_ScenarioCode__c = '36';
            lstCases[0].PFR_TECH_EngineerClaimNR__c = 'testing';
            lstCases[0].NOB_ContactPickup__c = listContactAssure[0].Id;
    
            
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[2].Id, listAccAssureur[2].Id, 'BMW', 'X1','128765sddz','test3',Datetime.newInstance(System.today().year(),
            System.today().month()-4, 
            System.today().day(), 17, 00, 0),'AR145678','Body','Réparation'));
            lstCases[2].NOB_Pricebook__c=catalogueCompte.Id;
            lstCases[2].NOB_ContactPickup__c= listContactAssure[2].Id;
            lstCases[2].NOB_ScenarioCode__c = '36';
            lstCases[2].PFR_TECH_EngineerClaimNR__c = 'testing';
            lstCases[2].NOB_ContactPickup__c = listContactAssure[2].Id;
            lstCases[2].Origin = 'Email';
       
            insert lstCases;

            lstWorkOrder = new List<WorkOrder>();
            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[1].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[2].Id));
            lstWorkOrder[0].recordTypeId = recordTypeWo;
            lstWorkOrder[0].PFR_ExcludeFG__c = false;
            lstWorkOrder[1].recordTypeId = recordTypeWo;
            lstWorkOrder[1].PFR_ExcludeFG__c = false;
            lstWorkOrder[2].recordTypeId = recordTypeWo;
            lstWorkOrder[2].PFR_ExcludeFG__c = false;
            lstWorkOrder[2].NOB_BusinessProvider__c = listAccAssureur[2].Id;
            lstWorkOrder[2].NOB_Reparateur__c=lstBodyShop[0].Id;
            insert lstWorkOrder;

            for (integer i = 0; i < lstCases.size(); i++){
                lstCases[i].NOB_lastMission__c = lstWorkOrder[i].Id;
                lstCases[i].NOB_ProcessGNP__c = false;
                lstCases[i].NOB_GNP_Processed__c = true;
                
            }
            update lstCases;
        }

    }

    @isTest
    public static void testGNP(){
        System.runAs(userAdmin){
            Test.startTest();
                NOB_Batch_RepriseGNP_V2 bat = new NOB_Batch_RepriseGNP_V2(false);
                Database.executeBatch(bat, 2000);
            Test.stopTest();
        }
    }

}