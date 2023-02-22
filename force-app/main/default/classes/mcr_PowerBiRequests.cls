public class mcr_PowerBiRequests{ 

    public class EmbedTokenPostData {
        
        public String accessLevel;        
        public List<Identities> identities;
    }

    public class Identities {
        public String username;
        public String customData;
        public List<String> roles;
        public List<String> datasets;
    }  
}