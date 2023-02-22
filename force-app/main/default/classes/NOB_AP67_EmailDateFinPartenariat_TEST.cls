/*************************************************************************************
Class Name - NOB_AP67_EmailDateFinPartenariat_TEST
Version - 1.0
Created Date - 13-01-2022
Function - Test class for NOB_AP67_EmailDateFinPartenariat
#Ticket  - RSIW : 9311

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SRA           13-01-2022   Initial version
*************************************************************************************/
@IsTest
public class NOB_AP67_EmailDateFinPartenariat_TEST {
	private static User userAdmin;
    private static List<Account> lstAcc;
    
    static{
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;
        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createAccountBodyshop('compteReparateur', 'US')                
            };
            lstAcc.get(0).NOB_isPrefikar__c = true;
            lstAcc.get(0).NOB_Statut__c = 'Actif';
            lstAcc.get(0).NOB_DateFinPartenariat__c = Date.today();
            lstAcc.get(0).NOB_StatusReason__c = 'Suspendu';
            lstAcc.get(0).NOB_TechRaisondeStatut__c = 'Candidat';
            insert lstAcc;
        }
    }
    
    @isTest
    public static void testGetRecordId(){
        Test.startTest();
        	NOB_AP67_EmailDateFinPartenariat.getRecordId(lstAcc);
        Test.stopTest();
        System.assertEquals([SELECT id FROM EmailMessage].size(), 0);
    }

    @isTest
    public static void testSendEmailFromBatch(){
        Test.startTest();
            Database.executeBatch(new NOB_BatchDateFinPartenariat());
        Test.stopTest();
        Account acc = [SELECT NOB_StatusReason__c, NOB_Statut__c FROM Account WHERE Id = :lstAcc.get(0).Id LIMIT 1];
        System.assertEquals(acc.NOB_Statut__c, 'Inactif');
        System.assertEquals(acc.NOB_StatusReason__c, lstAcc.get(0).NOB_TechRaisondeStatut__c);
    }
    
    @isTest
    public static void testClearRaisonAccount(){
        Test.startTest();
        	lstAcc.get(0).NOB_DateFinPartenariat__c = null;
        	update lstAcc;
        Test.stopTest();
        Account acc = [SELECT NOB_StatusReason__c FROM Account WHERE Id = :lstAcc.get(0).Id LIMIT 1];
        System.assertEquals(acc.NOB_StatusReason__c, null);
    }
    
    @isTest
    public static void testSendEmailError(){
        Test.startTest();
        	/*lstAcc.get(0).NOB_TechRaisondeStatut__c = 'test';
        	update lstAcc;
        	Database.executeBatch(new NOB_BatchDateFinPartenariat(new Set<Id>{lstAcc.get(0).Id}));*/
        	NOB_AP67_EmailDateFinPartenariat.sendEmailError('error message');
        Test.stopTest();
        System.assertEquals([SELECT id FROM EmailMessage].size(), 1);
        //System.assertEquals([SELECT NOB_StatusReason__c FROM Account WHERE id = :lstAcc.get(0).Id LIMIT 1].NOB_StatusReason__c, 'test');
    }
}