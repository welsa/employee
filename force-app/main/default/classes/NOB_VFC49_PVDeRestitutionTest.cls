/**
 * @description       : 
 * @author            : KPA
 * @group             : 
 * @last modified on  : 08-20-2020
 * @last modified by  : KPA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-19-2020   KPA   Initial Version
 * 1.1   18-11-2020   HMO   Modified version
**/

@isTest
public with sharing class NOB_VFC49_PVDeRestitutionTest {
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
                        TestFactory.createPrefikarBodyAccount('testAccBodyshop', '', '49492059811','actif')
                };
                insert lstBodyshopAccount;

                lstInsuredContact = new List<Contact>{
                        TestFactory.createInsuredContact('John', 'Doe', lstInsurerAccount[0].Id, 'Alsace Lorraine')
                };
                insert lstInsuredContact;

                lstPlannings = new List<NOB_Planning__c>{
                        TestFactory.createPlanning(lstBodyshopAccount[0].Id)
                };
                insert lstPlannings;
                
                Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()-5, 17, 00, 0);

                lstCase = new List<Case>{
                        TestFactory.createCaseStandard('Nouvelle', lstInsuredContact[0].Id, lstInsurerAccount[0].Id, 'Audi', 'Quattro','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture')
                };
                insert lstCase;

                lstCase[0].NOB_BodyShop__c = lstBodyshopAccount[0].Id;
                lstCase[0].NOB_TECH_DispoId__c = lstPlannings[0].Id;
                lstCase[0].Status = 'Suivi_reparation';
                update lstCase;

                //HMO -- 18-11-2020
                //lstWorkOrder = new List<WorkOrder>([Select Id from WorkOrder where CaseId = :lstCase[0].Id]);

                lstWorkOrder = new List<WorkOrder>();
                lstWorkOrder.add(
                        TestFactory.createWorkOrder('Nouvelle', lstCase[0].Id)
                );
                lstWorkOrder[0].NOB_VehiculeReturnDate__c = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()+1);
                insert lstWorkOrder;

                lstAsset = new List<Asset>{
                        TestFactory.createVehiculeRemplacement(lstBodyshopAccount[0].Id)
                };
                insert lstAsset;

                lstRent = new List<NOB_Rent__c>{
                        TestFactory.createPret(lstWorkOrder[0].Id, lstAsset[0].Id)
                };
                insert lstRent;
            }
        }

        @isTest static void test_controller() {
            System.runAs(userAdmin) {
                Test.startTest();
                NOB_VFC49_PVDeRestitution controller = new NOB_VFC49_PVDeRestitution(new ApexPages.StandardController(lstWorkOrder[0]));
                Test.stopTest();
            }
        }
}