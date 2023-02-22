public class mcr_PowerBiResponses{

	public class ApiToken {

		public string token_type;
		public string expires_in;
		public string ext_expires_in;
		public string access_token;	
		   
	}

	public class ReportData {

		public String id { get; set; } 
        public String reportType { get; set; } 
        public String name { get; set; } 
        public String webUrl { get; set; } 
        public String embedUrl { get; set; } 
        public boolean isFromPbix { get; set; } 
        public boolean isOwnedByMe { get; set; } 
        public String datasetId { get; set; } 		
		    
	}

	public class EmbedToken {
		public String token;
		public String tokenId;
		public DateTime expiration;
	}

	public static ApiToken parseApiToken(String json) {
		return (ApiToken) System.JSON.deserialize(json, ApiToken.class);
	}

	public static ReportData parseReportData(String json) {
		return (ReportData) System.JSON.deserialize(json, ReportData.class);
	}

	public static EmbedToken parseEmbedToken(String json) {
		return (EmbedToken) System.JSON.deserialize(json, EmbedToken.class);
	}
	
}