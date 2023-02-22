global class AssignPermCC {

    //Method that can is called from the Visual Force page action attribute
    webservice static string assign(Id permId,Id usrid) {
        try{
            
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permId, AssigneeId = usrId);
            User usr = new User(id=usrId,Activation_Date__c=System.today());
            
            //WCH 06/06/2019 C-002781 Spain R4
            List<PermissionSetAssignment> userHasPermissionSet = [select Id from PermissionSetAssignment where PermissionSetId=:permId and AssigneeId=:usrId];
            if(userHasPermissionSet.isEmpty()){
                insert psa; 
            }
             
            update usr;

            //WCH 06/06/2019 C-002781 Spain R4
            map <string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = new map <string,CountryCodeInformationsMapping__c>();
            allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();
            if(permId.equals(System.label.PermissionSetIdR4)){
                NetworkMember currentMember = [SELECT Id,PreferencesDisableAllFeedsEmail,Member.CountryCode FROM NetworkMember WHERE MemberId=:usrid order by createddate desc limit 1];
                if( allConfigCountryCodeInfo.containsKey(currentMember.Member.CountryCode.toUpperCase()) && allConfigCountryCodeInfo.get(currentMember.Member.CountryCode.toUpperCase()).EnableChatterFeed__c){
                        currentMember.PreferencesDisableAllFeedsEmail=true;
                        update currentMember;
                }
                
            }

        }catch(Exception e){
            return (String) e.getMessage();
        }
        return '1';
    }
}