/*************************************************************************************
Class Name - NOB_AssetTriggerHandler_TEST
Version - 1.0
Created Date - 28-10-2021


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     28-10-2021  RSIW - 9164 : BESOIN DE LA VUE DE LISTE DU DETAIL DES VR SAISIS DANS LE PORTAIL REP DANS LE PORTAIL MY PREFIKAR
* Hansraj M     15/12/2021  RSIW - 11173 : Gestion du parc VR hors prefikar/ Prefikar -- commenting methods
*************************************************************************************/
@isTest
private class NOB_AssetTriggerHandler_TEST {
	/*static User userAdmin;
    static List<Asset> lstAssetToInsert;
    static Account accRep;
    
    static {
        userAdmin = TestFactory.createPrefikarUser('AssetUser');
        userAdmin.Username = 'utilisateur@spoonTest.za';
        insert userAdmin;
        
        accRep = TestFactory.createPrefikarBodyAccount('ReparateurSPOON ', 'Réseau Premium');
        accRep.ContactEmail__c = 'spoonltdzzz@gmail.com';
        accRep.VATNumber__c = 'vat12349';
        accRep.ReferenceNumber__c = 'FR0000888888';
        accRep.ASEntity__c = 'ASFR1';
        accRep.ExpertSubstitutionMethod__c='FORCED';
        accRep.NOB_Ranking__c = NOB_AP00_Constants.ACCOUNT_RANKING_GOLD;
        insert accRep;
        
        lstAssetToInsert = new List<Asset>();
        for (integer i = 0; i < 200; i++){
            Asset asset = new Asset(Name = 'VR'+i, AccountId = accRep.Id);
            lstAssetToInsert.add(asset);
        }
        lstAssetToInsert[0].NOB_vehiculePrefikar__c = TRUE;
       
    }
    
    @isTest
    public static void testInsert(){
        System.runAs(userAdmin){
            Test.startTest();
				insert lstAssetToInsert;            
            Test.stopTest();
            
            List<Asset> lstResult = [SELECT Id, Name, NOB_VRPrefikar__c from Asset where NOB_VRPrefikar__c != null AND NOB_vehiculePrefikar__c = true];
            System.assertEquals(1, lstResult.size());
        }
    }
    
     @isTest
    public static void testUpdate(){
        System.runAs(userAdmin){
            Test.startTest();
				insert lstAssetToInsert;    
            
            for (Asset asset : lstAssetToInsert ){
                asset.NOB_vehiculePrefikar__c = TRUE;
            }
            update lstAssetToInsert;
            
            Test.stopTest();
            
            List<Asset> lstResult = [SELECT Id, Name, NOB_VRPrefikar__c from Asset where NOB_VRPrefikar__c != null AND NOB_vehiculePrefikar__c = true];
            System.assertEquals(200, lstResult.size());
        }
    }
    
    @isTest
    public static void testUpdateNULL(){
        System.runAs(userAdmin){
            Test.startTest();
				insert lstAssetToInsert;    
            
            for (Asset asset : lstAssetToInsert ){
                asset.NOB_vehiculePrefikar__c = TRUE;
            }
            update lstAssetToInsert;
            
           	lstAssetToInsert[0].NOB_vehiculePrefikar__c = false;
            update lstAssetToInsert;
            
            Test.stopTest();
            
            List<Asset> lstResult = [SELECT Id, Name, NOB_VRPrefikar__c from Asset where Id =: lstAssetToInsert[0].Id];
            System.assertEquals(null, lstResult[0].NOB_VRPrefikar__c);
        }
    }*/
    
}