/*
 @File Name          : NOB_VFC49_EtatDeLieux_Test
 @Description        : visualforce pdf EtatDesLieux test class
 @Author             : HMO
 @Group              : 
 @Last Modified By   : HMO
 @Last Modified On   : 16/11/2020, 12.00
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    11/11/2020, 17.00     HMO      1.0
*/

@isTest
public without sharing class NOB_VFC49_EtatDeLieux_TEST {
    static User userAdmin;
    static List<Account> lstAccountAssure;
    static List<Contact> lstContact;
    static List<Case> lstCase;
    static List<WorkOrder> lstWorkOrder;
    static List<Account> lstAccountBodyshop;
    static List<Asset> lstVR;
    static NOB_Planning__c planning;
    static NOB_Rent__c rent;

    static{
      userAdmin = TestFactory.createPrefikarUser('adminUser');
      userAdmin.BypassValidationRules__c = true;
      userAdmin.BypassWorkflows__c = true;
      insert userAdmin;
      
      lstAccountAssure = new List<Account>();
      lstContact = new List<Contact>();
      lstCase = new List<Case>();
      lstWorkOrder = new List<WorkOrder>();
      lstAccountBodyshop = new List<Account>();
      lstVR = new List<Asset>();
      planning = new NOB_Planning__c();
      rent = new NOB_Rent__c();

      System.runAs(userAdmin){
        Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day()-5, 17, 00, 0);

        lstAccountAssure.add(TestFactory.createInsurerAccount('testAccAssure', '49492059811'));
        lstContact.add(TestFactory.createInsuredContact('test', 'contactAssure', lstAccountAssure[0].Id, 'Alsace Lorraine'));
        lstCase.add(TestFactory.createCaseStandard('Nouvelle', lstContact[0].Id, lstAccountAssure[0].Id, 'Audi', 'Quattro','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture'));
        lstAccountBodyshop.add(TestFactory.createPrefikarBodyAccount('testAccBodyshop', '', '49492059811','actif'));
        
        insert lstAccountAssure;
        insert lstContact;
        insert lstCase;
        insert lstAccountBodyshop;

        for(integer i = 0; i < 5; i++){
          lstVR.add(TestFactory.createVehiculeRemplacement(lstAccountBodyshop[0].Id));
          lstWorkOrder.add(TestFactory.createWorkOrder('Nouveau', lstCase[0].Id));
          lstWorkOrder[i].NOB_VehiculeReturnDate__c = Datetime.newInstance(System.today().year(),System.today().month(),System.today().day()+1, 17, 00, 00 );
        }
        insert lstVR;
        insert lstWorkOrder;

        planning = TestFactory.createPlanning(lstAccountBodyshop[0].Id);
        planning.NOB_WorkOrder__c = lstWorkOrder[0].Id;
        insert planning;

        rent = TestFactory.createPret(lstWorkOrder[0].Id, lstVR[0].Id);
        rent.NOB_VehiculeRentalDate__c = Datetime.newInstance(System.today().year(),System.today().month(),System.today().day(), 17, 00, 00 );
        insert rent;
    }
  }

  @isTest
  public static void testEtatDesLieuxDocument(){
    System.runAs(userAdmin){
      Test.startTest();
        NOB_VFC49_EtatDeLieux controller = new NOB_VFC49_EtatDeLieux(new ApexPages.StandardController(lstWorkOrder[0]));
      Test.stopTest();
    }
  }
}