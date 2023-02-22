/**
 * Created by Hansraj Mohiputlall on 20/10/2020.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC52_NouvelleRequete_TEST
  -- - Author        : HMO
  -- - Description   : Test class for lightning component LC_52
  -- - #Ticket       : RSIW : 1675
                       RSIW : 3726 [5354]
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 09-NOV-2020    HMO     1.0     Initial version
  -- 03-DEC-2020    HMO     1.1     Modified version
  **********************************************************************
*/

@isTest
public without sharing class NOB_LC52_NouvelleRequete_TEST {
    static User userAdmin;
    static List<Group> lstGroup;
    static Group newgroup;
    static GroupMember groupMember;
    static NOB_OffreApporteurAffaire__mdt objMdt;
    static List<Account> lstAccounts;
    static NOB_AccountPricebook__c priceBook;
    static String error = '';
    static Contact newCon;

    static{
        userAdmin = TestFactory.createUser('userAdmin');
        insert userAdmin;

        System.runAs(userAdmin){            
            newgroup = new Group();
            newgroup.name = 'NOB_GroupAssureur_Areas';
            newgroup.type = 'regular';
            insert newgroup;

            groupMember = new GroupMember();
            groupMember.UserOrGroupId = userAdmin.Id;
            groupMember.GroupId = newgroup.Id;
            insert groupMember;
            

            lstAccounts = new List<Account>();
            for(integer i =0; i< 5; i++){
                lstAccounts.add(TestFactory.createInsurerAccount('accTest0'+i,'siret34'));
              
            }
            
                  lstAccounts[0].ContactEmail__c = 'tsest@test.com';
            lstAccounts[0].VATNumber__c = 'vat245486';
            lstAccounts[0].ReferenceNumber__c = 'FR0123656787';
            lstAccounts[0].ASEntity__c = 'ASFR1';
            lstAccounts[0].ExpertSubstitutionMethod__c = 'Forced';
            
                  lstAccounts[1].ContactEmail__c = 'tsest1@test.com';
            lstAccounts[1].VATNumber__c = 'vat245486';
            lstAccounts[1].ReferenceNumber__c = 'FR0123666787';
            lstAccounts[1].ASEntity__c = 'ASFR1';
            lstAccounts[1].ExpertSubstitutionMethod__c = 'Forced';
            
                      lstAccounts[2].ContactEmail__c = 'tsest2@test.com';
            lstAccounts[2].VATNumber__c = 'vat245487';
            lstAccounts[2].ReferenceNumber__c = 'FR0423666787';
            lstAccounts[2].ASEntity__c = 'ASFR1';
            lstAccounts[2].ExpertSubstitutionMethod__c = 'Forced';
            
                          lstAccounts[3].ContactEmail__c = 'tsest3@test.com';
            lstAccounts[3].VATNumber__c = 'vat2454878';
            lstAccounts[3].ReferenceNumber__c = 'FR0423666767';
            lstAccounts[3].ASEntity__c = 'ASFR1';
            lstAccounts[3].ExpertSubstitutionMethod__c = 'Forced';
            
                lstAccounts[4].ContactEmail__c = 'tsest4@test.com';
            lstAccounts[4].VATNumber__c = 'vat2454898';
            lstAccounts[4].ReferenceNumber__c = 'FR0423666567';
            lstAccounts[4].ASEntity__c = 'ASFR1';
            lstAccounts[4].ExpertSubstitutionMethod__c = 'Forced';
            
            
            insert lstAccounts;

            priceBook = new NOB_AccountPricebook__c();
            priceBook.Name = 'priceBookTest0';
            priceBook.NOB_Account__c = lstAccounts[0].Id;
            insert priceBook;

            objMdt = new NOB_OffreApporteurAffaire__mdt();
            objMdt.MasterLabel = 'Areas';
            objMdt.DeveloperName ='customMetadataRecordName' ;
            objMdt.NOB_BusinessProvider__c = lstAccounts[0].Id ;
            objMdt.NOB_Pricebook__c = priceBook.Name;

        }
    }

    @isTest
    public static void getApporteurAffaireTest(){
        System.runAs(userAdmin){
            Test.startTest();
                Map<String, Object> mapResult = NOB_LC52_NouvelleRequete.getApporteurAffaire();
            Test.stopTest();
        System.assert(mapResult.size()>0);
        }
    }

  
    @isTest
    public static void getUserandRecIdTest(){
        System.runAs(userAdmin){
               Test.startTest();
                Map<String, Object> mapResult = NOB_LC52_NouvelleRequete.getUserandRecId('recordTypeLabel');
            Test.stopTest();
        System.assert(mapResult.size()>0);
		}
	}
    

/*    
    @isTest
    public static void TestRecordTypeIdInValid(){
        System.runAs(userAdmin){
            String recordTypeName = 'Pas de type d\'enregistrement';
            Test.startTest();
            try{
                String recTypeId = NOB_LC52_NouvelleRequete.getRecordId(recordTypeName);
            }catch(Exception e){
                error = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals(error, 'Attempt to de-reference a null object');
        }
    }
*/
    
/*
    @isTest
    public static void testReturnContactId(){
        System.runAs(userAdmin){
            newCon = new Contact(LastName = 'TestHMO', Phone = '12345678');
            insert newCon;
            Test.startTest();
                String connId = NOB_LC52_NouvelleRequete.newContactId();
            Test.stopTest();
            List<Contact> lstCreatedCon = [SELECT Id FROM Contact WHERE Id =: newCon.Id];
            System.assertEquals(lstCreatedCon[0].Id, newCon.Id);

        }
    }
*/
    
  /*
    @isTest
    public static void testReturnNoContact(){
        System.runAs(userAdmin){
            Test.startTest();
                String connId = NOB_LC52_NouvelleRequete.newContactId();
            Test.stopTest();
            System.assertEquals(connId, 'No contact to pull !');
        }
    }

*/


}