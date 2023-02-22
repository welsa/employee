public interface mcr_IPowerBiApi {

    mcr_PowerBiResponses.ReportData getReport(string workspaceId, string reportId);

    mcr_PowerBiResponses.EmbedToken getEmbedToken (string workspaceId, string reportId, mcr_PowerBiRequests.EmbedTokenPostData requestBody);

  // String getApiToken();
}