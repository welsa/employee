@isTest

private with sharing class mcr_CommunityController_TEST {

    static string workspaceId = 'workspaceId';
    static string reportId = 'reportId';
    static string powerBiEnv = Label.MCR_PowerBiEnv;

    @TestSetup static void setup(){

        // Create Power BI Item
        MCR_PowerBiItem__c item = (MCR_PowerBiItem__c)mcr_UnitTestData.generateRecord(
            new MCR_PowerBiItem__c(),
            true
        );   

        // Create MCR Clients
        Account McrClient = (Account)mcr_UnitTestData.generateRecord(new Account(Name = 'Client MCR'), true);
        
        // Create MCR Contact
        Contact McrContact = (Contact)mcr_UnitTestData.generateRecord( new Contact(LastName = 'LastName', FirstName = 'FirstName', AccountId = McrClient.Id),true );
        Contact McrContactNoAccess = (Contact)mcr_UnitTestData.generateRecord( new Contact(LastName = 'LastNameNA', FirstName = 'FirstNameNA', AccountId = McrClient.Id),true );

        // Create Standard Portal Users
        User portalUser = (User)mcr_UnitTestData.generateRecord( new User(Alias = 'alias', CommunityNickname = 'cNickName', ContactId = McrContact.Id, Email = 'test@test.fr', FirstName = 'John', LastName = 'Doe', profileId =  getProfileIdByDeveloperName('CC MyCarReport'), UserName = 'username@test.fr'), true);
        User portalUserNA = (User)mcr_UnitTestData.generateRecord( new User(Alias = 'aliasNA', CommunityNickname = 'cNickNameNA', ContactId = McrContactNoAccess.Id, Email = 'testNA@testNA.fr', FirstName = 'John', LastName = 'Doe', profileId =  getProfileIdByDeveloperName('CC MyCarReport'), UserName = 'usernameNA@test.fr'), true);
        
        // Add access to Power Bi Items
        MCR_PowerBiAccess__c access = (MCR_PowerBiAccess__c)mcr_UnitTestData.generateRecord( new MCR_PowerBiAccess__c( MCR_PowerBiItemId__c = item.Id,  MCR_ContactId__c = McrContact.Id), true );
    }

    @isTest static void getPowerBiAccess_OK(){
        
        // Get Connected Portal User    
         User u = getUserByUsername('username@test.fr');

         // Run As CC My Car Report
         System.runAs(u){

            // Check Portal User Power BI Accesses
            List<MCR_PowerBiAccess__c> accesses =  mcr_CommunityController.getPowerBiAccess(u.Id);            
            System.assertEquals(1, accesses.size(), 'The number of access returned is not correct');           
            
        }
    }

    @isTest static void getPowerBiAcces_KO_No_User_Found(){

        // Get Connected Portal User    
        User u = getUserByUsername('username@test.fr');

        // Run As CC My Car Report
        System.runAs(u){

           // Check Portal User Power BI Accesses
           List<MCR_PowerBiAccess__c> accesses =  mcr_CommunityController.getPowerBiAccess(null);            
           System.assertEquals(null, accesses, 'User should not have been access');      
           
       }
    }

    @isTest static void getPowerBiAcces_KO_No_Access(){

        // Get Connected Portal User    
        User u = getUserByUsername('usernameNA@test.fr');

        // Run As CC My Car Report
        System.runAs(u){

           // Check Portal User Power BI Accesses
           List<MCR_PowerBiAccess__c> accesses =  mcr_CommunityController.getPowerBiAccess(u.Id);            
           System.assertEquals(null, accesses, 'User should not have been access');       
           
       }
    }

    @isTest static void getReportData_OK(){

        // Generate Fake REST API responses
        mcr_PowerBiApiMock aadtokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}');
        mcr_PowerBiApiMock pbiReportMock = new mcr_PowerBiApiMock(200, 'OK', '{"id":"ItemId","reportType":"PowerBIReport","name":"Report Name","webUrl":"webUrl","embedUrl":"embedUrl","isFromPbix":true,"isOwnedByMe":true,"datasetId":"datasetId"}');
        mcr_PowerBiApiMock pbiEmbeddedTokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token":"embedToken","tokenId":"idToken","expiration":"2022-05-27T14:34:43Z"}');

        // Generate endpoints
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);
        string aadTokenEndpoint = String.format(keys.AADTokenEndpoint__c,new List<String>{keys.TenantId__c});
        String getReportEndpoint = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId});
        String getEmbeddedTokenEndpoint = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId}) +'/GenerateToken';

        Map<String, HttpCalloutMock> endpointsMock = new Map<String,HttpCalloutMock>();
        endpointsMock.put(aadTokenEndpoint,aadtokenMock);
        endpointsMock.put(getReportEndpoint,pbiReportMock);
        endpointsMock.put(getEmbeddedTokenEndpoint,pbiEmbeddedTokenMock);

        HttpCalloutMock multiCalloutMock = new mcr_MultiRequestMock(endpointsMock);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        mcr_CommunityController.PowerBiReportData data = mcr_CommunityController.getPowerBiReport(workspaceId, reportId, 'username@test.fr');
        Test.stopTest();

    }

    @isTest static void getReportData_NOK_Null_Parameters(){

         mcr_CommunityController.PowerBiReportData data = mcr_CommunityController.getPowerBiReport(null, null, null);
        System.assertEquals(null, data, 'Data should be null');

    }

      
    /**************************************************************
     * Unit tests - HELPERS
     **************************************************************/

    private static Id getProfileIdByDeveloperName(String name){
        return [SELECT Id 
                FROM Profile 
                WHERE Name =:name 
                WITH SECURITY_ENFORCED 
                LIMIT 1].Id;
    }

    private static User getUserByUsername(string userName){
        return [SELECT Id, ContactId
                FROM User
                WHERE Username =:userName 
                WITH SECURITY_ENFORCED 
                LIMIT 1];
    }

}