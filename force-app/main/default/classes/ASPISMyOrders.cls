/*************************************************************************************
Class Name - MyOrders 
Version - 1.0
Created Date - 27 July 2017
Function - Controller for page MyOrders

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       27/07/2017  Original Version (case C-001953 : ASPIS Order 2.0 : ASPISMyOrders)
* Vaynee       28/03/2018  Case C-002321 searchByDate soql injection prevention
* Vaynee       30/03/2018  Case C-002315 Penetration Test Report : Cross Site scripting
* Abdool M     25/10/2018  C-002781 : Migrate Spain to R4
                                    : Do not display invoice info for Spain
* Welsa C      25/11/2020  C-004023 : NOB - Contact Management 2.0
**************************************************************************************/
public without sharing class ASPISMyOrders {

    //String encripted assessment id
    public String encryptedText {get; set;}
    //Map<BodyShop Type,assessment>
    public list<Assessment__c> claimOrderAssessmentList{get;set;}
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
    public ASPISMyOrders() 
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

        mapOriginalTranslated = new map<String,String>();
        for (Schema.PicklistEntry pe: Assessment__c.OrderStatus__c.getDescribe().getPicklistValues()) {
            mapOriginalTranslated.put(pe.getValue(),pe.getLabel());
        }
        system.debug('##constructor map'+mapOriginalTranslated);
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
    
    //AMI 25/10/2018  C-002781 : Migrate Spain to R4
    //                         : Do not display invoice info for Spain
    public class OnGoingAssessment{
        public Assessment__c currentAssessment {get; set;}
        public PrerequisiteOrder__c currentSalesOrder {get; set;}
        public String salesOrderEncodedId {get; set;}
        public String bodyShopOrderNumber {get; set;}
        public Boolean hasReadPermission {get; set;}
        public Boolean hasInvoices {get; set;}

        //AMI 25/10/2018  C-002781 : Migrate Spain to R4
        //                         : Do not display invoice info for Spain
        //                         : boolean used to hide column invoice in display page
        public boolean doNotDisplayInvoice {get;set;}

        public OnGoingAssessment(Assessment__c currentOnGoingAssessment){
            currentAssessment   = currentOnGoingAssessment;
            bodyShopOrderNumber = '';
            salesOrderEncodedId = '';
            hasReadPermission   = false;
            currentSalesOrder = new PrerequisiteOrder__c();

            //AMI 25/10/2018  C-002781 : Migrate Spain to R4
            //                         : Do not display invoice info for Spain
            //                         : boolean initialisation
            doNotDisplayInvoice = false;

            //AMI 25/10/2018  C-002781 : Migrate Spain to R4
            //                         : Do not display invoice info for Spain
            //                         : set boolean based on entity code
            if(string.isNotBlank(currentOnGoingAssessment.TECH_EntityCountryCode__c) && 
               currentOnGoingAssessment.TECH_EntityCountryCode__c.toLowerCase() == ASPISConstants.assTECH_EntityCountryCodeES.toLowerCase()){
                doNotDisplayInvoice = true;
            }

            if(currentOnGoingAssessment.PrerequisiteOrders__r.size() > 0){
                // As there is only one take the first one
                currentSalesOrder = currentOnGoingAssessment.PrerequisiteOrders__r[0];

                if(currentSalesOrder != null){
                    Blob encryptedBlob = Blob.valueOf(currentSalesOrder.Id);
                    salesOrderEncodedId = EncodingUtil.base64Encode(encryptedBlob);

                    if(currentSalesOrder.BodyShopOrderNumber__c != null){
                        Set<String> setBodyShopOrderNumber = new Set<String>(currentSalesOrder.BodyShopOrderNumber__c.split(';'));

                        for(String currentBodyShopOrderNumber : setBodyShopOrderNumber){
                            bodyShopOrderNumber += currentBodyShopOrderNumber + ';';
                        }

                        bodyShopOrderNumber = bodyShopOrderNumber.removeEnd(';');
                    }
                }
            }
            if(currentOnGoingAssessment.Invoices__r.size() > 0){
                for(Invoice__c inv: currentOnGoingAssessment.Invoices__r){
                    if(inv.Number__c != null){
                        hasInvoices = true;
                        break;
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
        //WCH 25/11/2020 C-004023
        String bsAccountId = decryptedBSId;
        List<User> currentUser = [Select Id,ContactId,Contact.AccountId from User where id=:decryptedBSId];
        if(currentUser.size()>0 && currentUser[0].ContactId!=null && currentUser[0].Contact.AccountId!=null){
            bsAccountId=currentUser[0].Contact.AccountId;
        }

        String query = 'SELECT  Id, VINNumber__c ,PlateNumber2__c, Manufacturer__c, BodyShop__r.Type, AssessmentID__c, ModelV2__c, ' +
                                'EntityRules__c, Bodyshop_is_Eligible_Non_AXA__c, BodyShop__c, CreatedDate, Status__c, ' + 
                                'ParentAssessment__c, ParentAssessment__r.ReasonFailure__c, OrderOrigin__c, IsCareOrder__c, MissionNumber__c, ' +
                                'tolabel(OrderStatus__c), AssessmentNumber__c, BodyShop__r.SepaValid__c,TECH_EntityCountryCode__c,  ClaimReference__c, ' +
                                '(SELECT Id, BodyShopOrderNumber__c, Name, Status__c ' +
                                'FROM PrerequisiteOrders__r ' +
                                'WHERE Status__c != \'PREACCEPTANCE\'), '+
                                '(SELECT Id,Number__c ' +
                                'FROM Invoices__r ' +
                                'WHERE RecordType.DeveloperName = \'CreditNote\' '+
                                'OR RecordType.DeveloperName = \'Draft\' ) '+
                        'FROM    Assessment__c ' +
                        //'WHERE   BodyShop__r.ContactUser__c  =: decryptedBSId '+
                        'WHERE   BodyShop__c  =:bsAccountId '+
                        'AND     RecordType.DeveloperName IN (\'ClaimOrder\',\'NewAssessment\' )'+
                        'AND     OrderStatus__c in (\'INDELIVERY\', \'PREORDERCONFIRMED\', \'PENDING DISTRIBUTOR (CARE)\' , \'RESPONDED\', \'DELIVERED\', \'INVOICED\', \'CLOSEDKO\', \'CLOSEDOK\', \'PAID\') ';

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
        Set<Id> recordWithReadPermission = ASPISMyOrders.verifyPermission(recordsToVerifyPermission);
        
        for(OnGoingAssessment currentOnGoingAssessment : onGoingAssessmentList){
            if(recordWithReadPermission.contains(currentOnGoingAssessment.currentAssessment.Id)){
                currentOnGoingAssessment.hasReadPermission = true;
            }
        }
        system.debug('## onGoingAssessmentList ' + onGoingAssessmentList);
        return onGoingAssessmentList;
    }
}