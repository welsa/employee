/**
 * @description       : Test class for NOB_VFC49_OrdreMissionController
 * @author            : GBH
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-12-2020   GBH   Initial Version
**/
@isTest
public with sharing class NOB_VFC49_OrdreMissionControllerTEST {
    static User userAdmin;
    static List<Account> lstInsurerAccount;
    static List<Account> lstBodyshopAccount;
    static List<Contact> lstInsuredContact;
    static List<Case> lstCase;
    static List<WorkOrder> lstWorkOrder;
    static List<NOB_Planning__c> lstPlannings;
    static List<Asset> lstAsset;
    static List<NOB_Rent__c> lstRent;

    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        userAdmin.BypassValidationRules__c = true;
        userAdmin.BypassWorkflows__c = true;
        insert userAdmin;


        System.runAs(userAdmin) {
                

            lstInsurerAccount = new List<Account>{
                    TestFactory.createInsurerAccount('AXA Assurance', '49492059811')
            };
            insert lstInsurerAccount;

            lstBodyshopAccount = new List<Account>{
                    TestFactory.createPrefikarBodyAccount('Garage Test', 'Hors réseau', '49492059811','actif')
            };
            insert lstBodyshopAccount;

            lstInsuredContact = new List<Contact>{
                    TestFactory.createInsuredContact('John', 'Doe', lstInsurerAccount[0].Id, 'Alsace Lorraine')
            };
            insert lstInsuredContact;

            lstPlannings = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstBodyshopAccount[0].Id)
            };
            
            lstPlannings[0].NOB_Status__c = 'Réservé';
            lstPlannings[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                            System.today().month(), 
                                                            System.today().day()+1, 16, 00, 0);
            lstPlannings[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                            System.today().month(), 
                                                            System.today().day()+1, 17, 00, 0);
                                                            
            insert lstPlannings;

            Date dt = Date.today().toStartOfMonth();
            Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 17, 00, 0);

            //dt = dt.addDay(-5);
            lstCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', lstInsuredContact[0].Id, lstInsurerAccount[0].Id, 'Audi', 'Quattro','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture')
        };
            
            lstCase[0].NOB_BodyShop__c = lstBodyshopAccount[0].Id;
            lstCase[0].NOB_TECH_DispoId__c = lstPlannings[0].Id;
            lstCase[0].Status = 'Suivi_reparation';
            lstCase[0].Origin = 'Darva';
            lstCase[0].NOB_InsurerClaimNumber__c = '123456789zxx';
            lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(System.today().year(), System.today().month()-1,System.today().day()+1, 17, 00, 0);
            lstCase[0].NOB_DamageType__c = 'test';
            lstCase[0].NOB_VehicleRegistrationNumber__c = 'test';
            lstCase[0].NOB_VehicleBrand__c = 'PORS';
            lstCase[0].NOB_VehicleModel__c = '911';
            insert lstCase;

            lstWorkOrder = new List<WorkOrder>{
                    TestFactory.createWorkOrder('Nouveau', lstCase[0].id)
            };
            insert lstWorkOrder;

            lstAsset = new List<Asset>{
                    TestFactory.createVehiculeRemplacement(lstBodyshopAccount[0].Id)
            };
            insert lstAsset;

            lstRent = new List<NOB_Rent__c>{
                    TestFactory.createPret(lstWorkOrder[0].Id, lstAsset[0].Id)
            };
            insert lstRent;


                
			lstPlannings[0].NOB_WorkOrder__c = lstWorkOrder[0].id;
			
			update lstPlannings;
        }
    }

    @isTest 
    public static void testController() {
        System.runAs(userAdmin) {
            Test.startTest();
            NOB_VFC49_OrdreMissionController controller = new NOB_VFC49_OrdreMissionController(new ApexPages.StandardController(lstWorkOrder[0]));
            Test.stopTest();
        }
    }
}