/*************************************************************************************
Class Name - NOB_VFC50_FicheIdentification_TEST
Version - 1.0
Created Date - 12-01-2022
Function - Test class for NOB_VFC50_FicheIdentification

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SRA           12-01-2022   Initial version
*************************************************************************************/
@IsTest
public with sharing class NOB_VFC50_FicheIdentification_TEST {
    static User userAdmin;
    static List<Account> lstAcc;
    static List<Contact> lstCon;
    static List<Asset> lstAss;
    static ContentVersion conVers;

    static {
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;
        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('testAcc', 'US')
            };
            lstAcc.get(0).NOB_isPrefikar__c = true;
            lstAcc.get(0).NOB_Statut__c = 'Actif';
            lstAcc.get(0).NOB_BodyShop__c = 'Acoat;Autneo';
            lstAcc.get(0).NOB_Renter__c = 'Alamo;Autoescape';
            lstAcc.get(0).NOB_Bodyshop_Brand__c = 'ALFA;AUDI';
            insert lstAcc;
            conVers = TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test', 'pdf');
            lstCon = new List<Contact>{
                TestFactory.createBodyshopContact('test', 'test', lstAcc.get(0).Id)
            };
            lstCon.get(0).AccountId = lstAcc.get(0).Id;
            lstCon.get(0).email = 'test@test.com';
            lstCon.get(0).NOB_FunctionServices__c = 'Dirigeant';
            lstCon.get(0).NOB_Status__c = 'Actif';
            insert lstCon;
            lstAss = new List<Asset>{
                TestFactory.createVehiculeRemplacement(lstAcc.get(0).Id)
            };
            lstAss.get(0).NOB_Make__c = 'DUTI';
            insert lstAss;
        }
    }

    @IsTest
    public static void testNOB_VFC50_FicheIdentification(){
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(lstAcc.get(0));
            NOB_VFC50_FicheIdentification ficheId = new NOB_VFC50_FicheIdentification(sc);
        Test.stopTest();
        System.assertEquals(ficheId.vrMakeSize, 1);
        System.assertEquals(ficheId.vrAutoSize, 1);
        System.assertEquals(ficheId.vrSize, 1);
        System.assertEquals(ficheId.files.size() <= 8, true);
    }

    @IsTest
    public static void testNOB_VFC50_FicheIdentificationError(){
        Test.startTest();
            NOB_VFC50_FicheIdentification ficheId = new NOB_VFC50_FicheIdentification(null);
        Test.stopTest();
        System.assertEquals(ficheId.vrMakeSize, null);
        System.assertEquals(ficheId.vrAutoSize, null);
        System.assertEquals(ficheId.vrSize, null);
    }
}