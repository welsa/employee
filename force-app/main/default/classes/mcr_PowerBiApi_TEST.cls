@isTest
private with sharing class mcr_PowerBiApi_TEST{

    static string workspaceId = 'workspaceId';
    static string reportId = 'reportId';
    static string powerBiEnv = Label.MCR_PowerBiEnv;

    @isTest static void getApiToken_OK(){

        Test.setMock(HttpCalloutMock.class, new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}'));
        mcr_PowerBiApi service = new mcr_PowerBiApi();
        string tokenResponse = service.getApiToken();             
        System.assertEquals('token', tokenResponse, 'Token is not as expected' );
    }

    @isTest static void getApiToken_NOK(){

        Test.setMock(HttpCalloutMock.class, new mcr_PowerBiApiMock(400, 'KO', '{"error":"unauthorized_client"}'));
        
        try{
            mcr_PowerBiApi service = new mcr_PowerBiApi();
            string tokenResponse = service.getApiToken();
        }catch (mcr_Exception ex) {

            System.assertEquals('Get Azure AD Token Failed : 400 : {"error":"unauthorized_client"}', ex.getMessage(), 'Exception is not as expected');            
        }        
    }

    @isTest static void getReport_OK(){

        //Fake Callout Response
        Test.setMock(HttpCalloutMock.class, new mcr_PowerBiApiMock(200, 'OK', '{"id":"ItemId","reportType":"PowerBIReport","name":"Report Name","webUrl":"webUrl","embedUrl":"embedUrl","isFromPbix":true,"isOwnedByMe":true,"datasetId":"datasetId"}'));
        
        mcr_IPowerBiApi service  = new mcr_PowerBiApi();
        mcr_PowerBiResponses.ReportData data = service.getReport('workspaceId', 'reportId');
        
        System.assertEquals('ItemId', data.id, 'Id is not as expected');
        System.assertEquals('PowerBIReport', data.reportType, 'reportType is not as expected');
        System.assertEquals('Report Name', data.name, 'Name is not as expected');
        System.assertEquals('webUrl', data.webUrl, 'webUrl is not as expected');
        System.assertEquals('embedUrl', data.embedUrl, 'embedUrl is not as expected');
        System.assertEquals('Report Name', data.name, 'Name is not as expected');
        System.assertEquals(true, data.isFromPbix, 'isFromPbix is not as expected');
        System.assertEquals(true, data.isOwnedByMe, 'isOwnedByMe is not as expected');
        System.assertEquals('datasetId', data.datasetId, 'datasetId is not as expected');
    }

    @isTest static void getReport_NOK(){

        // Generate Fake REST API responses
        mcr_PowerBiApiMock aadtokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}');
        mcr_PowerBiApiMock pbiReportMock = new mcr_PowerBiApiMock(400, 'KO', '{"error":"error"}');

        // Generate endpoints
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(Label.MCR_PowerBiEnv);
        string aadTokenEndpoint = String.format(keys.AADTokenEndpoint__c,new List<String>{keys.TenantId__c});
        String getReportEndpoint = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId});
       
        Map<String, HttpCalloutMock> endpointsMock = new Map<String,HttpCalloutMock>();
        endpointsMock.put(aadTokenEndpoint,aadtokenMock);
        endpointsMock.put(getReportEndpoint,pbiReportMock);

        HttpCalloutMock multiCalloutMock = new mcr_MultiRequestMock(endpointsMock);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);      
        
            try{
            mcr_IPowerBiApi service  = new mcr_PowerBiApi();
            mcr_PowerBiResponses.ReportData data = service.getReport('workspaceId', 'reportId');
            
        }catch (mcr_Exception ex) {

            System.assertEquals('Get Report Data Failed : 400 : {"error":"error"}', ex.getMessage(), 'Exception is not as expected');            
        }        
    }

    @isTest static void getReport_NOK_Null_Parameters(){

        //Fake Callout Response
        Test.setMock(HttpCalloutMock.class, new mcr_PowerBiApiMock(200, 'OK', '{"id":"ItemId","reportType":"PowerBIReport","name":"Report Name","webUrl":"webUrl","embedUrl":"embedUrl","isFromPbix":true,"isOwnedByMe":true,"datasetId":"datasetId"}'));
        
        mcr_IPowerBiApi service  = new mcr_PowerBiApi();
        mcr_PowerBiResponses.ReportData AllParametersNull = service.getReport(null, null);
        System.assertEquals(null, AllParametersNull, 'AllParametersNull should be null');

        mcr_PowerBiResponses.ReportData workspaceParamNull = service.getReport(null, 'reportId');
        System.assertEquals(null, workspaceParamNull, 'workspaceParamNull returned by service should be null');

        mcr_PowerBiResponses.ReportData reportParamNull = service.getReport('workspaceId', null);
        System.assertEquals(null, reportParamNull, 'reportParamNull returned by service should be null');
    }

    @isTest static void getEmbeddedToken_OK(){

        // Generate Fake REST API responses
        mcr_PowerBiApiMock aadtokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}');
        mcr_PowerBiApiMock embedTokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token":"embedToken","tokenId":"idToken","expiration":"2022-05-27T14:34:43Z"}');

        // Generate endpoints
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);
        string aadTokenEndpoint = String.format(keys.AADTokenEndpoint__c,new List<String>{keys.TenantId__c});
        String getEmbeddedTokenEndpoint = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId}) +'/GenerateToken';

        Map<String, HttpCalloutMock> endpointsMock = new Map<String,HttpCalloutMock>();
        endpointsMock.put(aadTokenEndpoint,aadtokenMock);
        endpointsMock.put(getEmbeddedTokenEndpoint,embedTokenMock);

        HttpCalloutMock multiCalloutMock = new mcr_MultiRequestMock(endpointsMock);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);      
        
        mcr_IPowerBiApi service  = new mcr_PowerBiApi();      
        mcr_PowerBiRequests.EmbedTokenPostData postData = new mcr_PowerBiRequests.EmbedTokenPostData();
        List<mcr_PowerBiRequests.Identities> identities = new List<mcr_PowerBiRequests.Identities>();
        
        mcr_PowerBiRequests.Identities identity = new mcr_PowerBiRequests.Identities();      
        identity.customData = 'test@test.fr';
        identity.datasets = New List<String>{'datasetId'};
        identities.add(identity);
        
        postData.accessLevel = 'View';
        postData.identities = identities;
        mcr_PowerBiResponses.EmbedToken data = service.getEmbedToken(workspaceId, reportId, postData);

        System.debug(LoggingLevel.INFO, 'Data => ' + data);

        System.assertEquals('embedToken', data.token, 'token is not as expected');
    }

    @isTest static void getEmbeddedToken_NOK(){

        // Generate Fake REST API responses
        mcr_PowerBiApiMock aadtokenMock = new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}');
        mcr_PowerBiApiMock embedTokenMock = new mcr_PowerBiApiMock(400, 'KO', '{"error":"error"}');

        // Generate endpoints
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);
        string aadTokenEndpoint = String.format(keys.AADTokenEndpoint__c,new List<String>{keys.TenantId__c});
        String getEmbeddedTokenEndpoint = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId}) +'/GenerateToken';

        Map<String, HttpCalloutMock> endpointsMock = new Map<String,HttpCalloutMock>();
        endpointsMock.put(aadTokenEndpoint,aadtokenMock);
        endpointsMock.put(getEmbeddedTokenEndpoint,embedTokenMock);

        HttpCalloutMock multiCalloutMock = new mcr_MultiRequestMock(endpointsMock);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        try{

            mcr_IPowerBiApi service  = new mcr_PowerBiApi();      
            mcr_PowerBiRequests.EmbedTokenPostData postData = new mcr_PowerBiRequests.EmbedTokenPostData();
            List<mcr_PowerBiRequests.Identities> identities = new List<mcr_PowerBiRequests.Identities>();
            
            mcr_PowerBiRequests.Identities identity = new mcr_PowerBiRequests.Identities();      
            identity.customData = 'test@test.fr';
            identity.datasets = New List<String>{'datasetId'};
            identities.add(identity);
            
            postData.accessLevel = 'View';
            postData.identities = identities;
            mcr_PowerBiResponses.EmbedToken data = service.getEmbedToken(workspaceId, reportId, postData);

        }catch (Exception ex){

            System.assertEquals('Get Embed Token Failed : 400 : {"error":"error"}', ex.getMessage(), 'Exception is not as expected');  

        }

    }

    
    @isTest static void getEmbeddedToken_NOK_Null_Parameters(){

        //Fake Callout Response
        Test.setMock(HttpCalloutMock.class, new mcr_PowerBiApiMock(200, 'OK', '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"token"}'));

        //Create a fake postData    
        mcr_PowerBiRequests.EmbedTokenPostData postData = new mcr_PowerBiRequests.EmbedTokenPostData();
        List<mcr_PowerBiRequests.Identities> identities = new List<mcr_PowerBiRequests.Identities>();
        
        mcr_PowerBiRequests.Identities identity = new mcr_PowerBiRequests.Identities();      
        identity.customData = 'test@test.fr';
        identity.datasets = New List<String>{'datasetId'};
        identities.add(identity);
        
        postData.accessLevel = 'View';
        postData.identities = identities; 

        // Starting test        
        mcr_IPowerBiApi service  = new mcr_PowerBiApi();
        mcr_PowerBiResponses.EmbedToken AllParametersNull = service.getEmbedToken(null, null,null) ;
        System.assertEquals(null, AllParametersNull, 'AllParametersNull should be null');

        mcr_PowerBiResponses.EmbedToken workspaceParamNull = service.getEmbedToken(null, reportId, postData);
        System.assertEquals(null, workspaceParamNull, 'workspaceParamNull returned by service should be null');

        mcr_PowerBiResponses.EmbedToken reportParamNull = service.getEmbedToken(workspaceId, null , postData);
        System.assertEquals(null, reportParamNull, 'reportParamNull returned by service should be null');
        
        mcr_PowerBiResponses.EmbedToken postDataParamNull = service.getEmbedToken(workspaceId, reportId, null);
        System.assertEquals(null, postDataParamNull, 'postDataParamNull returned by service should be null');

    }


}