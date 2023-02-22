/*************************************************************************************
Class Name - ASPISMyQuotations 
Version - 1.0
Created Date - 14 August 2017
Function - Controller for page ASPISMyQuotations

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       14/08/2017  Original Version (case C-001960 : ASPIS Order 2.0 : ASPISMyQuotations)
* Vaynee       28/03/2018  Case C-002321 searchByDate soql injection prevention
* Vaynee       30/03/2018  Case C-002315 Penetration Test Report : Cross Site scripting
* Welsa        18/07/2019  C-003340 - In R4, Add additional columns on 2 pages
**************************************************************************************/
public with sharing class ASPISMyQuotations {

    //String encripted assessment id
    public String encryptedText {get; set;}
    //Boolean whether there are ongoing sales orders
    public boolean hasOngoingAssessment{get;set;}
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
    public map <String,String> mapOriginalTranslated {get;set;}
    public String mapOriginalTranslatedJson {get{return JSON.serialize(mapOriginalTranslated);}}

    

    public ASPISMyQuotations() 
    {
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;
        hasOngoingAssessment = false;
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedId));
            }else{
                hasAssessment = false;
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                system.debug('## Exception ' + e.getMessage());
                system.debug('## Exception ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.NoAssessmentFound));
            }            
        }

        mapOriginalTranslated = new map<String,String>();
        for (Schema.PicklistEntry pe: Assessment__c.OrderStatus__c.getDescribe().getPicklistValues()) {
            mapOriginalTranslated.put(pe.getValue(),pe.getLabel());
        }
        system.debug('##constructor map'+mapOriginalTranslated);
    }

    public static String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public static String encryptBase64(String text)
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

        return null;
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

    public class OnGoingAssessment{
        public Assessment__c currentAssessment {get; set;}
        public PrerequisiteOrder__c currentSalesOrder {get; set;}
        public String salesOrderEncodedId {get; set;}
        public String assClaimEncodedId {get; set;}
        public String assClaimOrderEncodedId {get; set;}
        public String bodyShopOrderNumber {get; set;}
        public Boolean hasReadPermission {get; set;}
        public String soName {get; set;}//WCH 18/07/2019 C-003340 - In R4, Add additional columns on 2 pages

        public OnGoingAssessment(Assessment__c currentOnGoingAssessment){
            currentAssessment   = currentOnGoingAssessment;
            bodyShopOrderNumber = '';
            soName='';//WCH 18/07/2019 C-003340 - In R4, Add additional columns on 2 pages
            salesOrderEncodedId = '';
            assClaimEncodedId = ASPISMyQuotations.encryptBase64(String.valueOf(currentAssessment.ParentAssessment__c));
            assClaimOrderEncodedId = ASPISMyQuotations.encryptBase64(String.valueOf(currentAssessment.Id));
            hasReadPermission   = false;
            currentSalesOrder = new PrerequisiteOrder__c();

            if(currentOnGoingAssessment.PrerequisiteOrders__r.size() > 0){
                // As there is only one take the first one
                currentSalesOrder = currentOnGoingAssessment.PrerequisiteOrders__r[0];

                if(currentSalesOrder != null){
                    salesOrderEncodedId = ASPISMyQuotations.encryptBase64(String.valueOf(currentSalesOrder.Id));
                    soName=currentSalesOrder.Name;//WCH 18/07/2019 C-003340 - In R4, Add additional columns on 2 pages
                    if(currentSalesOrder.BodyShopOrderNumber__c != null){
                        Set<String> setBodyShopOrderNumber = new Set<String>(currentSalesOrder.BodyShopOrderNumber__c.split(';'));

                        for(String currentBodyShopOrderNumber : setBodyShopOrderNumber){
                            bodyShopOrderNumber += currentBodyShopOrderNumber + ';';
                        }

                        bodyShopOrderNumber = bodyShopOrderNumber.removeEnd(';');
                    }
                }
            }
        }
    }
     @RemoteAction
    public static list<OnGoingAssessment> assessmentDisplay(String dateStart, String dateEnd, String decryptedBSId){
        list<OnGoingAssessment> onGoingAssessmentList = new List<OnGoingAssessment>();
        list<Assessment__c> claimOrderAssessmentList = new list<Assessment__c>();
        decryptedBSId = Id.valueOf(decryptedBSId);
        String query = 'SELECT  Id, VINNumber__c ,PlateNumber2__c, Manufacturer__c, BodyShop__r.Type, AssessmentID__c, ModelV2__c, ' +
                                'EntityRules__c, Bodyshop_is_Eligible_Non_AXA__c, BodyShop__c, CreatedDate, Status__c, ' + 
                                'ParentAssessment__c, ParentAssessment__r.ReasonFailure__c, OrderOrigin__c, IsCareOrder__c, ' +
                                'tolabel(OrderStatus__c), AssessmentNumber__c, BodyShop__r.SepaValid__c,TECH_EntityCountryCode__c, ClaimReference__c, ' +
                                '(SELECT Id, BodyShopOrderNumber__c, Name, Status__c ' +
                                'FROM PrerequisiteOrders__r ' +
                                'WHERE Status__c != \'PREACCEPTANCE\'), '+
                                '(SELECT Id ' +
                                'FROM Invoices__r ' +
                                'WHERE RecordType.DeveloperName = \'CreditNote\' '+
                                'OR RecordType.DeveloperName = \'Draft\' ) '+
                        'FROM    Assessment__c ' +
                        'WHERE   BodyShop__r.ContactUser__c  =: decryptedBSId '+
                        'AND     RecordType.DeveloperName = \'ClaimOrder\' '+
                        'AND     OrderStatus__c in  (\'QUOTATION SENT\', \'QUOTATION IN PROGRESS\', \'INACCEPTANCE\') ';

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

        query += ' ORDER BY CreatedDate DESC ';
            
        system.debug('##Query '+query);

        Set<Id> recordsToVerifyPermission = new Set<Id>();

        claimOrderAssessmentList = Database.query(query);

        for(Assessment__c claimOrderAssessment : claimOrderAssessmentList){
            onGoingAssessmentList.add(new OnGoingAssessment(claimOrderAssessment));
            //hasOngoingAssessment = true;

            recordsToVerifyPermission.add(claimOrderAssessment.Id);
        }

        // Checking the permission of the assessment
        Set<Id> recordWithReadPermission = ASPISMyQuotations.verifyPermission(recordsToVerifyPermission);
        
        for(OnGoingAssessment currentOnGoingAssessment : onGoingAssessmentList){
            if(recordWithReadPermission.contains(currentOnGoingAssessment.currentAssessment.Id)){
                currentOnGoingAssessment.hasReadPermission = true;
            }
        }
        system.debug('## onGoingAssessmentList ' + onGoingAssessmentList);
        return onGoingAssessmentList;
    }
}