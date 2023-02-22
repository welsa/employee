/*
----------------------------------------------------------------------
-- - Name          : NOB_AP65_WorkOrderUtils_TEST
-- - Author        : NPE
-- - Description   : Test class for NOB_AP65_WorkOrderUtils
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 09-DEC-2021	NPE		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/

@isTest
public with sharing class NOB_AP65_WorkOrderUtils_TEST {
    static User userFO;
    static User userAdmin;
    static Account accBodyshop;
    static List<Account> gesReseaureparateur;
    static List<Account> listAccAssureur;
    static List<Case> lstCases;
    static List<WorkOrder> lstWorkOrder;
    static List<Contact> listContactAssure;

    static{
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
        }
    }

    @isTest
    public static void AP65_WorkOrder_Test(){
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
}