public without sharing class VFC28LoginHistory {
    
    public list<LoginHistory> historyList {get; set;}
    public string sourceIp {get;set;}
    public string loginTime {get;set;}
    public string loginType {get;set;}
    public string status {get;set;}
    public string application {get;set;}
    public string loginurl {get;set;}

    public VFC28LoginHistory(ApexPages.StandardController controller){
        Id iduser = controller.getId();
        
        system.debug('@@id:'+iduser);
        
         if( iduser != null){
             historyList = [select Application,LoginGeoId,LoginTime,LoginType,LoginUrl,SourceIp,Status,Id 
                            from LoginHistory where userId =:iduser order by LoginTime desc limit 10];
         }
        else{
            historyList = [select Application,LoginGeoId,LoginTime,LoginType,LoginUrl,SourceIp,Status,Id from LoginHistory order by LoginTime desc limit 10];
         
        }
        
       //Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(LoginHistory);
        //Schema.SobjectField sObjField = sObjType.getDescribe().fields.getMap().get(LoginType);

        sourceIp = Schema.sObjectType.LoginHistory.fields.SourceIp.getSObjectField().getDescribe().getLabel();
        loginTime = Schema.sObjectType.LoginHistory.fields.loginTime.getSObjectField().getDescribe().getLabel();
        loginType = Schema.sObjectType.LoginHistory.fields.loginType.getSObjectField().getDescribe().getLabel();
        status = Schema.sObjectType.LoginHistory.fields.status.getSObjectField().getDescribe().getLabel();
        application = Schema.sObjectType.LoginHistory.fields.application.getSObjectField().getDescribe().getLabel();
        loginurl = Schema.sObjectType.LoginHistory.fields.loginurl.getSObjectField().getDescribe().getLabel();
        
        
    
    }

}