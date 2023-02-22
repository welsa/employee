/*************************************************************************************
Class Name - NOB_ZoneInterventionTriggerHandler_TEST
Version - 1.0
Created Date - 13-01-2022
Function - Test class for NOB_ZoneInterventionTriggerHandler
#Ticket  - RSIW : 11265

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* SRA           13-01-2022   Initial version
*************************************************************************************/
@IsTest
public class NOB_ZoneInterventionTriggerHandler_TEST {
	private static User userAdmin;
    private static List<Account> lstAcc;
    private static List<NOB_InterventionZone__c> lstZoneInt;
    
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
            insert lstAcc;
            lstZoneInt = new List<NOB_InterventionZone__c>{
                TestFactory.createZoneIntervention(lstAcc.get(0).Id, 'test1'),
                TestFactory.createZoneIntervention(lstAcc.get(0).Id, 'test2')
            };
        }
    }
    
    @IsTest
    public static void testInsert(){
        Test.startTest();
        	insert lstZoneInt;
        Test.stopTest();
        Account acc = [SELECT NOB_eligiblerevalorisationsSAD_IDF__c, NOB_eligibleRevalorisationsSAD_CORSE__c FROM Account WHERE Id = :lstAcc.get(0).Id LIMIT 1];
        System.equals(acc.NOB_eligiblerevalorisationsSAD_IDF__c, true);
        System.equals(acc.NOB_eligibleRevalorisationsSAD_CORSE__c, false);
    }
    
    @IsTest
    public static void testUpdatePostalCode(){
        Test.startTest();
        	insert lstZoneInt;
        	lstZoneInt.get(0).NOB_PostalCode__c = '20345';
        	lstZoneInt.get(1).NOB_PostalCode__c = '75348';
        	update lstZoneInt;
        Test.stopTest();
        Account acc = [SELECT NOB_eligiblerevalorisationsSAD_IDF__c, NOB_eligibleRevalorisationsSAD_CORSE__c FROM Account WHERE Id = :lstAcc.get(0).Id LIMIT 1];
        System.equals(acc.NOB_eligiblerevalorisationsSAD_IDF__c, true);
        System.equals(acc.NOB_eligibleRevalorisationsSAD_CORSE__c, true);
    }
    
    @IsTest
    public static void testDelete(){
        Test.startTest();
        	insert lstZoneInt;
        	delete lstZoneInt;
        Test.stopTest();
        Account acc = [SELECT NOB_eligiblerevalorisationsSAD_IDF__c, NOB_eligibleRevalorisationsSAD_CORSE__c FROM Account WHERE Id = :lstAcc.get(0).Id LIMIT 1];
        System.equals(acc.NOB_eligiblerevalorisationsSAD_IDF__c, false);
        System.equals(acc.NOB_eligibleRevalorisationsSAD_CORSE__c, false);
    }

}