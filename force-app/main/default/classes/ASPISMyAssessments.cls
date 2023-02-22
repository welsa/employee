/*
----------------------------------------------------------------------
-- - Name          : ASPISMyAssessments
-- - Author        : WCH
-- - Description   : Controller for page ASPISMyAssessments
--
-- Maintenance History:
--
-- Date      Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 14-JUN-2019  WCH    1.0      Initial version C-003316 : Spain R4 Nice to have
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISMyAssessments {

    //String encripted assessment id
    public String encryptedText {get; set;}
    //Map<BodyShop Type,assessment>
    public list<Assessment__c> claimOrderAssessmentList{get;set;}
    //Boolean whether there are any assessment
    public boolean hasAssessment{get;set;}
    //public List<Assessment__c> listOngoingAssessments{get;set;}
    public List<OnGoingAssessment> onGoingAssessmentList {get; set;}
    //Boolean whether there are errors
    public Boolean hasErrors {get; set;}
    //Boolean whether there are errors to be displayed in a toast    
    public Boolean isToastError {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public String fromDateStr {get;set;}
    public String toDateStr {get;set;}
    public String locale {get; set;}
    public String decryptedBSId {get; set;}
    public ASPISMyAssessments() 
    {
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;
        onGoingAssessmentList = new List<OnGoingAssessment>();
        locale = UserInfo.getLocale()=='nl_BE'?'nl-BE':UserInfo.getLocale();

        try
        {
            if(ApexPages.currentPage().getParameters().get('Id') != null){
                encryptedText = ApexPages.currentPage().getParameters().get('Id');                

                decryptedBSId = decryptBase64(encryptedText);

                Id anId = decryptedBSId;
            }        
                
            fromDateStr = (System.Today().addDays(-30)).format();
            toDateStr = (System.today()).format();

            system.debug('##dt1 '+fromDateStr);
            system.debug('##dt2 '+ toDateStr);           

        }
        catch(Exception e)
        {
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                hasErrors = true;
                isToastError = true;
                decryptedBSId = '';
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
            else{
                hasAssessment = false;
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                //system.debug('## Exception ' + e.getMessage());
                //system.debug('## Exception ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.NoAssessmentFound));             
            }         
        }
    }

    public String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);
        System.debug('Encrypted Text ' + encryptedData);

        return encryptedData;
    }

    public PageReference redirectPage()
    {

        PageReference pageRef = Page.Search;
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
     * Function to verify the permission of the user to the assessment
     * @param  currentClaimAssessment The assessment on which the permissions needs to be checked
     * @return                        Whether the user has access to the assessment
     */
    private static Set<Id> verifyPermission(Set<Id> recordIdSet)
    {
        Set<Id> userRecordAccessSet = new Set<Id>();
        for(UserRecordAccess currentRecordAccess : [SELECT  RecordId
                                                    FROM    UserRecordAccess
                                                    WHERE   RecordId IN: recordIdSet
                                                    AND     UserId =: UserInfo.getUserId()
                                                    AND     HasReadAccess = true])
        {
            userRecordAccessSet.add(currentRecordAccess.RecordId);
        }

        return userRecordAccessSet;
    }
    
    //AMI 25/10/2018  C-002781 : Migrate Spain to R4
    //                         : Do not display invoice info for Spain
    public class OnGoingAssessment{
        public Assessment__c currentAssessment {get; set;}
        public Boolean hasReadPermission {get; set;}

        public OnGoingAssessment(Assessment__c currentOnGoingAssessment){
            currentAssessment   = currentOnGoingAssessment;
            hasReadPermission   = false;
        }
    }

     @RemoteAction
    public static list<OnGoingAssessment> assessmentDisplay(String dateStart, String dateEnd, String decryptedBSId){
        list<OnGoingAssessment> onGoingAssessmentList = new List<OnGoingAssessment>();
        list<Assessment__c> claimOrderAssessmentList = new list<Assessment__c>();
        decryptedBSId = Id.valueOf(decryptedBSId);

        String query = 'SELECT  Id,Name,AssessmentNumber__c,TransactionId__c,BodyShop__r.Name,Entity__c,ClaimReference__c,PlateNumber2__c,tolabel(Status__c),RecordType.Name,CreatedDate,VINNumber__c,EntityRules__c '+
                        'FROM    Assessment__c ' +
                        'WHERE   BodyShop__r.ContactUser__c  =: decryptedBSId '+
                        'AND     ((RecordType.DeveloperName = \'Claim\' ) OR (RecordType.DeveloperName = \'NewAssessment\' AND (Name like \''+System.label.Painting.toUpperCase()+'%\' or Name like \''+System.label.Refinish.toUpperCase()+'%\'))) ';
                        

        system.debug('##fromDateStr' + dateStart);
        system.debug('##toDateStr' + dateEnd);

        if(dateStart!=null && dateStart != '')
        {
            Date dt1 = Date.parse(dateStart);
            query += ' AND DAY_ONLY(CreatedDate) >=: dt1 ';
            system.debug('##dt1 '+dt1);
        } 

        if(dateEnd!=null && dateEnd != ''){
            Date dt2 = Date.parse(dateEnd);
            query += ' AND DAY_ONLY(CreatedDate) <=: dt2 ';
            system.debug('##dt2 '+dt2);
        }  

        query += ' ORDER BY CreatedDate DESC limit 200 ';
            
        system.debug('##Query '+query);

        Set<Id> recordsToVerifyPermission = new Set<Id>();

        claimOrderAssessmentList = Database.query(query);

        for(Assessment__c claimOrderAssessment : claimOrderAssessmentList){
            onGoingAssessmentList.add(new OnGoingAssessment(claimOrderAssessment));
            recordsToVerifyPermission.add(claimOrderAssessment.Id);
        }

        // Checking the permission of the assessment
        Set<Id> recordWithReadPermission = ASPISMyAssessments.verifyPermission(recordsToVerifyPermission);
        
        for(OnGoingAssessment currentOnGoingAssessment : onGoingAssessmentList){
            //if(recordWithReadPermission.contains(currentOnGoingAssessment.currentAssessment.Id)){
                currentOnGoingAssessment.hasReadPermission = true;
            //}
        }
        system.debug('## onGoingAssessmentList ' + onGoingAssessmentList);
        return onGoingAssessmentList;
    }
}