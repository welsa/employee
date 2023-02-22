/** 
@author      : Ludovic Sabin
@date        : May-2022 
@description : Power BI Rest API Callout implementation
@resources   : https://docs.microsoft.com/en-us/rest/api/power-bi/ 
@exception   : Throw mcr_Exception with message returned by the API
**/

public class mcr_PowerBiApi implements mcr_IPowerBiApi {

    private String apiToken;
    private static string powerBiEnv = Label.MCR_PowerBiEnv;

    /**
     * @description : Get Report Data information from Power BI
     * @param       : workspaceId - Id of the workspace in which the report belongs to.
     * @param       : reportId - Id of the report
     * @return      : ReportData - Json To Apex object representing API response.
     */

    public mcr_PowerBiResponses.ReportData getReport (string workspaceId, string reportId){

        if (workspaceId == null || reportId == null){
            return null;
        }
        if(apiToken == null){
            apiToken = getApiToken();
        }

        // Get Auth Settings from Custom Metadata Type record
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);

        String urlGetReport = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId});

        HttpRequest getReportReq = new HttpRequest();
        getReportReq.setMethod('GET');
        getReportReq.setHeader('Authorization', 'Bearer ' + apiToken); 
        getReportReq.setEndpoint(urlGetReport);

        HttpResponse response = new Http().send(getReportReq);

        if(response.getStatusCode() != 200){
            throw new mcr_Exception('Get Report Data Failed : ' + response.getStatusCode() + ' : ' + response.getBody());
        }

        return mcr_PowerBiResponses.parseReportData(response.getBody());
    }

    
    /**
     * @description : Get an embedded token for the specified reportId in order to access report data (Data Analysisa)
     * @param       : workspaceId - Id of the workspace in which the report belongs to.
     * @param       : reportId - Id of the report
     * @param       : EmbedTokenPostData : Apex Object for modelling json body expecting by API
     * @return      : EmbedToken - Json To Apex object representing API response.
     */

    public mcr_PowerBiResponses.EmbedToken getEmbedToken (string workspaceId, string reportId, mcr_PowerBiRequests.EmbedTokenPostData requestBody){

        if(apiToken == null){
            apiToken = getApiToken();
        }

        if(workspaceId == null || reportId == null || requestBody == null){
            return null;
        }

        // Get Auth Settings from Custom Metadata Type record
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);
        String urlGenToken = String.format(keys.ReportRouteBase__c, new List<String>{workspaceId,reportId}) +'/GenerateToken';

        // // Hack : Populate RequestBody technical fields 
        for(mcr_PowerBiRequests.Identities i : requestBody.identities){
            i.username = keys.AppId__c;
            i.roles = New List<String>{'user', 'UserPBIEmbedded'};
        }
  
        // Create HttpRequest
        HttpRequest genEmbeddedTokenReq = new HttpRequest();
        genEmbeddedTokenReq.setMethod('POST');
        genEmbeddedTokenReq.setHeader('Authorization', 'Bearer ' + apiToken);
        genEmbeddedTokenReq.setHeader('Content-Type', 'application/json');     
        genEmbeddedTokenReq.setEndpoint(urlGenToken);
        genEmbeddedTokenReq.setBody(JSON.Serialize(requestBody));

        // Send Request
        HttpResponse response = new http().send(genEmbeddedTokenReq);

        if (response.getStatusCode() != 200){
            throw new mcr_Exception('Get Embed Token Failed : ' + response.getStatusCode() + ' : ' + response.getBody());
        }

        return mcr_PowerBiResponses.parseEmbedToken(response.getBody());
    }

     /**
     * @description : Get a token provided by Azure AD for initiate API Callouts. Each callout have to provide this token.
     *              : Credentials are stored in Custom Metadata Type 'PowerBiAuthSetting'
     * 
     * @return      : Azure AD Token.
     */
    
    @TestVisible private String getApiToken(){

        // Get Auth Settings from Custom Metadata Type record
        MCR_PowerBiSetting__mdt keys = MCR_PowerBiSetting__mdt.getInstance(powerBiEnv);

        // Get azure AD token endpoint URL       
        string aadTokenEndpoint = String.format(keys.AADTokenEndpoint__c,new List<String>{keys.TenantId__c});
      
        // Generate post body data for client credentials flow
        string bodyData = String.format('grant_type={0}&client_id={1}&client_info={2}&client_secret={3}&scope={4}',
            new List<String>{
                'client_credentials',
                keys.ClientId__c,
                '1',
                keys.ClientSecret__c,
                'https://analysis.windows.net/powerbi/api/.default'
            });
       
        // Generate API Request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(aadTokenEndpoint);
        req.setBody(bodyData);

     
        // Send Http Request
        HttpResponse response = new Http().send(req);  

        if(response.getStatusCode() != 200){
            throw new mcr_Exception('Get Azure AD Token Failed : ' + response.getStatusCode() + ' : ' + response.getBody());
        } 

        return mcr_PowerBiResponses.parseApiToken(response.getBody()).access_token;
    }   
}