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
public class NOB_ActivationDateReparateurs_TEMP_TEST {
	private static User userAdmin;
    private static List<Account> lstAcc;
    private static List<ServiceContract> lstServCon;
    private static String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName().get('NOB_BodyshopContract').getRecordTypeId();
    
    static {
        userAdmin = new User();
        userAdmin = TestFactory.createPrefikarUser('utilisateurDuLot');
        userAdmin.Username = 'utilisateur@spoonTest.eu';
        insert userAdmin;
        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createPrefikarBodyAccount('ReparateurSPOON ', 'Réseau Premium')
            };
            for(Account acc: lstAcc){
                acc.NOB_isPrefikar__c = true;
                acc.NOB_Statut__c = 'Actif';
                acc.NOB_DateDebutPartenariat__c = null;
                acc.ContactEmail__c = 'spoonltdzzz@gmail.com';
                acc.VATNumber__c = 'vat12349';
                acc.ReferenceNumber__c = 'FR0000888888';
                acc.ASEntity__c = 'ASFR1';
                acc.ExpertSubstitutionMethod__c='FORCED';
            }
            insert lstAcc;
            system.debug('£ lstAccs : ' + lstAcc);

            lstServCon = new List<ServiceContract>{
                TestFactory.createServCon( lstAcc.get(0).id  ,  'servConName1' , 'Partinium' , '8776545' , date.newInstance(2020, 8, 18) , date.newInstance(2021, 8, 17)),
                TestFactory.createServCon( lstAcc.get(0).id  ,  'servConName2' , 'Partinium' , '8776545' , date.newInstance(2020, 8, 18) , date.newInstance(2021, 8, 17))
            };
            for(ServiceContract sc: lstServCon){
                sc.RecordTypeId = recordTypeId;
                sc.ActivationDate = sc.startDate;
                sc.NOB_DateDeFormation__c = sc.startDate.addDays(-1);
            }
            insert lstServCon;
        }
    }
    
    @isTest
    public static void testActivationDateReparateurs(){
        Test.startTest();
        	Database.executeBatch(new NOB_ActivationDateReparateurs_TEMP());
        Test.stopTest();
        List<Account> lstAccs = [SELECT NOB_DateDebutPartenariat__c, NOB_TECH_FirstSCDateFilled__c FROM Account where Id =: lstServCon[0].AccountId];
        for(Account acc: lstAccs){
            Date dateAct = Date.newInstance(lstServCon[0].ActivationDate.year(), lstServCon[0].ActivationDate.month(), lstServCon[0].ActivationDate.day());
         	System.assertEquals(acc.NOB_DateDebutPartenariat__c, dateAct);
            System.assertEquals(acc.NOB_TECH_FirstSCDateFilled__c, true);
        }
    }
    
    @isTest 
    public static void testActivationDateReparateursError(){
        Test.startTest();
        	NOB_ActivationDateReparateurs_TEMP obj = new NOB_ActivationDateReparateurs_TEMP();
        	obj.start(null);
        	obj.execute(Null, lstAcc);
        	obj.finish(Null);
        	NOB_ActivationDateReparateurs_TEMP.sendEmailError('error message');
        Test.stopTest();
        List<EmailMessage> em = [SELECT id FROM EmailMessage];
        System.assertEquals(em.size(), 1);
    }
}