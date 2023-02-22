public without sharing class mcr_CommunityController {

    @AuraEnabled(cacheable=true)
    public static List<MCR_PowerBiAccess__c> getPowerBiAccess (Id userId){ 
        
        if(userId == null){
            return null;
        }
        // Get ContactId linked to Salesforce Community User
        User user = [   SELECT ContactId 
                        FROM User 
                        WHERE Id =: userId 
                        WITH SECURITY_ENFORCED];        
       
        if(user == null){
            return null;
        }

        // Get Authorized Power Bi Items for the given user
        List<MCR_PowerBiAccess__c> userAccesses = [ SELECT  Id,
                                                            MCR_IsDefault__c,
                                                            MCR_PowerBiItemId__r.Name,
                                                            MCR_PowerBiItemId__r.MCR_TECH_ExternalId__c,
                                                            MCR_PowerBiItemId__r.MCR_TECH_ExternalWorkspaceId__c,
                                                            MCR_IsFilterPaneVisible__c,
                                                            MCR_IsFilterPaneExpanded__c,
                                                            MCR_IsPageNavigationVisible__c,
                                                            MCR_DefaultReportPage__c,
                                                            MCR_PageNavPos__c
                                                    FROM  MCR_PowerBiAccess__c
                                                    WHERE MCR_ContactId__c =: user.ContactId
                                                    WITH SECURITY_ENFORCED];
        
       
        if(userAccesses == null || userAccesses.size() == 0){
            return null;
        }
        
        return userAccesses;
    } 

    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getPowerBiReport(string workspaceId, string reportId, string userContext){

        if(workspaceId == null || reportId == null || userContext == null){
            return null;
        }
       
        // Initiate Power Bi Service API
        mcr_IPowerBiApi service = new mcr_PowerBiApi();

        // Callout to REST API Power BI : Get Report Data
        mcr_PowerBiResponses.ReportData reportData = new mcr_PowerBiResponses.ReportData();
        reportData = service.getReport(workspaceId, reportId);
       
        if(reportData == null){
            // throw Exception
        }

        // Callout to REST API Power BI : Get Embedded Token
        mcr_PowerBiRequests.EmbedTokenPostData postData = new mcr_PowerBiRequests.EmbedTokenPostData();
        List<mcr_PowerBiRequests.Identities> identities = new List<mcr_PowerBiRequests.Identities>();
        
        mcr_PowerBiRequests.Identities identity = new mcr_PowerBiRequests.Identities();      
        identity.customData = userContext;
        identity.datasets = New List<String>{reportData.datasetId};
        identities.add(identity);
        
        postData.accessLevel = 'View';
        postData.identities = identities;

        mcr_PowerBiResponses.EmbedToken embedToken = new mcr_PowerBiResponses.EmbedToken();
        embedToken = service.getEmbedToken(workspaceId, reportId, postData);

        if (embedToken == null){
            // throw exception
        }

        PowerBiReportData data = new PowerBiReportData();

        data.workspaceId = WorkspaceId;
        data.reportId = ReportId;
        data.name = reportData.name;
        data.embedUrl = reportData.embedUrl;
        data.embedToken = embedToken.token;
        data.embedTokenExpires = embedToken.expiration;

        return data;

     }

     public class PowerBiReportData    {
    	@AuraEnabled
        public String workspaceId { get; set; } 
    	@AuraEnabled
        public String reportId { get; set; } 
    	@AuraEnabled
        public String name { get; set; } 
    	@AuraEnabled
        public String embedUrl { get; set; } 
    	@AuraEnabled
        public String embedToken { get; set; } 
    	@AuraEnabled
        public DateTime embedTokenExpires { get; set; } 
        @AuraEnabled
        public String error { get; set; } 
     }
}