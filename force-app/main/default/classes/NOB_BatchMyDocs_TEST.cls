/*************************************************************************************
Class Name - NOB_BatchMyDocs_TEST
Version - 1.0
Created Date - 12-01-2022
Function - Test class for NOB_BatchMyDocs
#Ticket  - RSIW : 5798

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SRA           12-01-2022   Initial version
*************************************************************************************/
@IsTest
public with sharing class NOB_BatchMyDocs_TEST {
    private static User userAdmin;
    private static List<Account> lstAcc;
    private static List<Contact> lstCon;
    private static list<Nob_MesDocuments__c> lstMesDoc;

    static {
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;
        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US'),
                TestFactory.createAccountBodyshop('cmptRep', 'US')
            };
            for(Account acc: lstAcc){
                acc.NOB_isPrefikar__c = true;
                acc.NOB_Statut__c = 'Actif';
            }
            insert lstAcc;
            lstCon = new List<Contact>{
                TestFactory.createBodyshopContact('test', 'test', lstAcc.get(0).Id),
                TestFactory.createBodyshopContact('test2', 'test2', lstAcc.get(1).Id)
            };
            lstCon.get(0).AccountId = lstAcc.get(0).Id;
            lstCon.get(1).AccountId = lstAcc.get(1).Id;
            for(Integer i = 0; i < lstCon.size(); i++){
                lstCon.get(i).email = 'test'+ i +'@test.com';
                lstCon.get(i).NOB_FunctionServices__c = 'Dirigeant';
                lstCon.get(i).NOB_Status__c = 'Actif';
            }
            insert lstCon;
            lstMesDoc = new List<Nob_MesDocuments__c>{
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(0).Id, lstAcc.get(0).Id),
                TestFactory.createAttestationAssurance(lstCon.get(1).Id, lstAcc.get(1).Id),
                TestFactory.createAttestationAssurance(lstCon.get(1).Id, lstAcc.get(1).Id)
            };
            lstMesDoc.get(1).NOB_Status__c = 'Active';
            lstMesDoc.get(1).NOB_DateFin__c = NOB_BatchMyDocs.getDatesAfter();
            lstMesDoc.get(2).NOB_Status__c = 'Expired';
            lstMesDoc.get(2).NOB_DateDebut__c = Date.today().addDays(-7);
            lstMesDoc.get(3).NOB_DateFin__c = Date.today();
            lstMesDoc.get(3).NOB_Status__c = 'Active';
            lstMesDoc.get(4).NOB_Status__c = 'Expired';
            lstMesDoc.get(4).NOB_DateDebut__c = Date.today().addDays(-7);
            lstMesDoc.get(4).NOB_DateFin__c = Date.today();
            lstMesDoc.get(4).NOB_LastSentEmail__c = NOB_BatchMyDocs.getDatesBefore();
            insert lstMesDoc;
        }
    }

    @IsTest
    public static void testBatchMyDocs() {
        Test.startTest();
            Database.executeBatch(new NOB_BatchMyDocs());
        Test.stopTest();
        Nob_MesDocuments__c mesDoc = [SELECT NOB_Status__c FROM Nob_MesDocuments__c WHERE Id = :lstMesDoc.get(0).Id LIMIT 1];
        system.assertEquals(mesDoc.NOB_Status__c, 'Active');        
    }


    @IsTest
    public static void testBatchMyDocsAttestIsExpired(){
        Test.startTest();
            Database.executeBatch(new NOB_BatchMyDocs());
        Test.stopTest();  
        Nob_MesDocuments__c mesDoc = [SELECT NOB_LastSentEmail__c FROM Nob_MesDocuments__c WHERE Id = :lstMesDoc.get(3).Id LIMIT 1];
        system.assertEquals(mesDoc.NOB_LastSentEmail__c, Date.today());
    }

    @IsTest
    public static void testConvertTimeZone(){
        Test.startTest();
            DateTime dt = NOB_BatchMyDocs.convertTimeZone(Date.newInstance(System.today().year(), System.today().month(), System.today().day()));
        Test.stopTest();
        DateTime dtTest = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        System.equals(dt, NOBTools.convertTimeToOtherTimeZone(dtTest, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString()));
    }
}