/*
----------------------------------------------------------------------
-- - Name          : Search
-- - Author        : ABT
-- - Description   : Controller for Search
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 13-MAR-2017  ABT     1.0         Initial version
-- 20-AUG-2017  VSU     1.1
-- 14-MAY-2018  DUN     1.2         Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
-- 25-OCT-2018  AMI     1.3         C-002781 : Migrate Spain to R4
--                                           : Do not display invoice info for Spain
-- 23-NOV-2018  AMI     1.4         C-002781 : Migrate Spain to R4
--                                           : Display Cases
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class Search extends CustomControllerBase
{
    public String inputTerm {get; set;}
    // public List<Assessment__c> assessmentList {get; set;}
    public List<AssessmentWrapper> assessmentWrapperList {get; set;}
    public String profilePicture {get; set;}
    public Boolean isShowingSearchResult {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public String encodedUserId {get;set;}

    //AMI 25/10/2018  C-002781 : Migrate Spain to R4
    //                         : Do not display invoice info for Spain
    //                         : new boolean to determine if query should be done on invoice 
    //                         : and also if invoice should be displayed in page layout
    public boolean isSpain {get;set;}

    //AMI 23/11/2018  C-002781 : Migrate Spain to R4
    //                         : Display Cases
    //                         : wrapper containing case to display
    public list <CaseWrapper> lstCaseWrapper {get;set;}

    // public Boolean isAssessmentListEmpty
    // {
    //  get
    //  {
    //      return !(assessmentList != null && assessmentList.size() > 0);
    //  }
    // }

    public Boolean isAssessmentWrapperListEmpty
    {
        get
        {
            return !(assessmentWrapperList != null && assessmentWrapperList.size() > 0);
        }
    }

    public Boolean isListInvoicesEmpty
    {
        get
        {
            return !(listInvoices != null && listInvoices.size() > 0);
        }
    }

    //AMI 23/11/2018  C-002781 : Migrate Spain to R4
    //                         : Display Cases
    //                         : calculate wrapper size
    public Boolean isListCaseEmpty{
        get{
            return !(lstCaseWrapper != null && lstCaseWrapper.size() > 0);
        }
    }

    public User currentUser {get; set;}

    public Boolean showWelcomeModal {get; set;}

    private Id claimRecordTypeId;
    private Id newAssessmentRecordTypeId;
    public Boolean isEligibleQuotation {get; set;}

    //14/05/2018 DUN Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
    private Id bsInvRecordTypeId;
    private Id bsCNRecordTypeId;
    public set<Id> setInvoicesId;
    public list<Invoice__c> listInvoices {get;set;}

    //14/05/2018 DUN Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
    public List<Id> recordTypeIdInvoiceSet {get;set;}
    public Boolean displayGotopButton {get;set;}

    public Search()
    {

        // Initialising the variables
        inputTerm                   = ApexPages.currentPage().getParameters().get('inputTerm')!=null? ApexPages.currentPage().getParameters().get('inputTerm'):'';
        // assessmentList           = new List<Assessment__c>();
        assessmentWrapperList       = new List<AssessmentWrapper>();
        isShowingSearchResult       = false;
        hasErrors                   = false;
        isToastError                = false;
        showWelcomeModal            = false;
        claimRecordTypeId           = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        newAssessmentRecordTypeId   = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

        //14/05/2018 DUN Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
        bsInvRecordTypeId           = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId();
        bsCNRecordTypeId            = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
        listInvoices                = new list<Invoice__c>();
        setInvoicesId               = new set<Id>();
        recordTypeIdInvoiceSet      = new List<Id>{bsInvRecordTypeId, bsCNRecordTypeId};
        displayGotopButton          = false;

        //AMI 23/11/2018  C-002781 : Migrate Spain to R4
        //                         : Display Cases
        //                         : Query AccountId
        // Retrieving the profile pic url of the 
        currentUser             = [ SELECT  SmallPhotoUrl, HideSiteWelcomePopup__c, UserRoleId, UserRole.Name, CountryCode, AccountId
                                    FROM    User 
                                    WHERE   User.Id =: UserInfo.getUserId()];
        system.debug('## currentUser' + currentUser);

        //AMI 25/10/2018  C-002781 : Migrate Spain to R4
        //                         : Do not display invoice info for Spain
        //                         : new boolean to determine if query should be done on invoice 
        //                         : and also if invoice should be displayed in search layout
        if(string.isNotBlank(currentUser.CountryCode) &&
           currentUser.CountryCode.toLowerCase() == ASPISConstants.userCountryCodeES.toLowercase()){
            isSpain = true;
        }else{
            isSpain = false;
        }
        
        //AMI 23/11/2018  C-002781 : Migrate Spain to R4
        //                         : Display Cases
        //                         : initialising wrapper containing case to display
        lstCaseWrapper = new list <CaseWrapper>();

        try{
            encodedUserId = encryptBase64(currentUser.id);
        }
        catch(Exception e){
            system.debug('##e.getMessage()'+e.getMessage());
        }

        profilePicture          = currentUser.SmallPhotoUrl;
        //DUN 23/02/2018 commented UserRoleId check - now for all countries in R4
        if(!currentUser.HideSiteWelcomePopup__c /*&& currentUser.UserRoleId != null && currentUser.UserRole.Name == 'FR - BodyShop'*/)
        {
            showWelcomeModal = true;
        }

        if(inputTerm != null && inputTerm != ''){
            searchData();
        }else{
            getRecentList();
        }

        Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();

        isEligibleQuotation = eligibleQuotation(mapCountryCodeMapping);

        if((assessmentWrapperList.size() > 6 && listInvoices.size() > 0) || (assessmentWrapperList.size() > 6 && listInvoices.size() == 0)){
            displayGotopButton = true;
        }

        system.debug('##inputTerm '+inputTerm);
    }
   
    // function to make the search in the different sObjects
    public void searchData()
    {
        hasErrors       = false;
        isToastError    = false;
        List<List<sObject>> searchResultList;
        try
        {
            List<Id> recordTypeIdSet = new List<Id>{claimRecordTypeId, newAssessmentRecordTypeId};

            //AMI 25/10/2018  C-002781 : Migrate Spain to R4
            //                         : Do not display invoice info for Spain
            //                         : query for invoice should not be performed in case of spain
            if(!isSpain){
                searchResultList = [FIND        :inputTerm 
                                    IN          ALL FIELDS 
                                    RETURNING   Assessment__c       (Id, ASReference__c, PlateNumber2__c, VINNumber__c, ClaimReference__c, MissionNumber__c
                                                                    WHERE   RecordTypeId IN: recordTypeIdSet), 
                                                PrerequisiteOrder__c(Name, BodyShopOrderNumber__c, Assessment__c, Assessment__r.ParentAssessment__c
                                                                     WHERE  Assessment__r.RecordTypeId =: newAssessmentRecordTypeId 
                                                                     OR     Assessment__r.ParentAssessment__r.RecordTypeId =: claimRecordTypeId),
                                                Invoice__c          (Id, Assessment__r.ParentAssessment__c, Assessment__c
                                                                     WHERE RecordTypeId =: recordTypeIdInvoiceSet)];
            }else{
                //AMI 23/11/2018  C-002781 : Migrate Spain to R4
                //                         : Display Cases
                //                         : Query Cases
                if(string.isNotBlank(currentUser.AccountId)){
                    searchResultList = [FIND        :inputTerm 
                                        IN          ALL FIELDS 
                                        RETURNING   Assessment__c       (Id, ASReference__c, PlateNumber2__c, VINNumber__c, ClaimReference__c, MissionNumber__c
                                                                        WHERE   RecordTypeId IN: recordTypeIdSet), 
                                                    PrerequisiteOrder__c(Name, BodyShopOrderNumber__c, Assessment__c, Assessment__r.ParentAssessment__c
                                                                         WHERE  Assessment__r.RecordTypeId =: newAssessmentRecordTypeId 
                                                                         OR     Assessment__r.ParentAssessment__r.RecordTypeId =: claimRecordTypeId),
                                                    Case__c             (Id,Assesment__c,Assesment__r.ParentAssessment__c
                                                                         WHERE Tech_BSAccount__c =: currentUser.AccountId)];
                }else{
                    searchResultList = [FIND        :inputTerm 
                                        IN          ALL FIELDS 
                                        RETURNING   Assessment__c       (Id, ASReference__c, PlateNumber2__c, VINNumber__c, ClaimReference__c, MissionNumber__c
                                                                        WHERE   RecordTypeId IN: recordTypeIdSet), 
                                                    PrerequisiteOrder__c(Name, BodyShopOrderNumber__c, Assessment__c, Assessment__r.ParentAssessment__c
                                                                         WHERE  Assessment__r.RecordTypeId =: newAssessmentRecordTypeId 
                                                                         OR     Assessment__r.ParentAssessment__r.RecordTypeId =: claimRecordTypeId)];
                }
                
            }
            system.debug('##searchResultList '+searchResultList);
        }
        catch (SearchException e)
        {
            hasErrors       = true;
            isToastError    = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.SearchInputError));
            return;
        }
        catch (Exception e)
        {
            hasErrors       = true;
            isToastError    = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            return;
        }

        isShowingSearchResult = true;

        // Clearing the list of assessment
        // assessmentList = new List<Assessment__c>();
        assessmentWrapperList = new List<AssessmentWrapper>();

        // Looping in the list of search results so as to get the data
        // remember that the list comes in a list of sObject
        if(searchResultList != null && searchResultList.size() > 0)
        {
            // Set of Assessment Id found in the search
            Set<Id> assessmentIdSet = new Set<Id>();

            for(List<sObject> currentSObjectList : searchResultList)
            {
                if(currentSObjectList.getSObjectType() == Assessment__c.sObjectType)
                {
                    List<Assessment__c> assessmentRetrievedList = (List<Assessment__c>) currentSObjectList;
                    for(Assessment__c currentAssessment : assessmentRetrievedList)
                    {
                        // Capturing the Id of the Assessment
                        assessmentIdSet.add(currentAssessment.Id);
                    }
                }
                else if(currentSObjectList.getSObjectType() == PrerequisiteOrder__c.sObjectType)
                {
                    List<PrerequisiteOrder__c> salesOrderList = (List<PrerequisiteOrder__c>) currentSObjectList;
                    for(PrerequisiteOrder__c currentSalesOrder : salesOrderList)
                    {
                        if(currentSalesOrder.Assessment__c != null && currentSalesOrder.Assessment__r.ParentAssessment__c != null)
                        {
                            // Capturing the Id of the Assessment
                            assessmentIdSet.add(currentSalesOrder.Assessment__r.ParentAssessment__c);
                        }
                        // For the code to come here it should be a new Assessment
                        else if (currentSalesOrder.Assessment__c != null && currentSalesOrder.Assessment__r.ParentAssessment__c == null)
                        {
                            assessmentIdSet.add(currentSalesOrder.Assessment__c);
                        }
                    }
                }
                //14/05/2018 DUN Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
                else if(currentSObjectList.getSObjectType() == Invoice__c.sObjectType)
                {
                    List<Invoice__c> InvoiceRetrievedList = (List<Invoice__c>) currentSObjectList;
                    for(Invoice__c currentInvoice : InvoiceRetrievedList)
                    {
                        if(currentInvoice.Assessment__c != null && currentInvoice.Assessment__r.ParentAssessment__c != null)
                        {
                            // Capturing the Id of the Assessment
                            assessmentIdSet.add(currentInvoice.Assessment__r.ParentAssessment__c);
                        }
                        // For the code to come here it should be a new Assessment
                        else if (currentInvoice.Assessment__c != null && currentInvoice.Assessment__r.ParentAssessment__c == null)
                        {
                            assessmentIdSet.add(currentInvoice.Assessment__c);
                        }
                    }
                }
                //AMI 23/11/2018  C-002781 : Migrate Spain to R4
                //                         : Display Cases
                //                         : Get All Cases Returned via SOSL
                else if(currentSObjectList.getSObjectType() == Case__c.sObjectType){
                    
                    list <Case__c> caseRetrievedList = (list <Case__c>) currentSObjectList;
                    
                    for(Case__c currentCase : caseRetrievedList){
                        if(currentCase.Assesment__c != null && currentCase.Assesment__r.ParentAssessment__c != null){
                            // Capturing the Id of the Assessment
                            assessmentIdSet.add(currentCase.Assesment__r.ParentAssessment__c);
                        }
                        else if (currentCase.Assesment__c != null){
                            assessmentIdSet.add(currentCase.Assesment__c);
                        }
                    }
                }
            }

            // checking if the set of assessment id is > 0
            if(assessmentIdSet.size() > 0)
            {
                retrieveAssessmentData(assessmentIdSet); 
                system.debug('##searchdata'+assessmentIdSet.size());
            }
        }
    }

    // function to retrieve the assessment in descending order and also to retrieve fields that should not be searchable
    public void retrieveAssessmentData(Set<Id> assessmentIdSet)
    {

        List<Assessment__c> assessmentList = [SELECT    Id, Manufacturer__c, ModelV2__c, PlateNumber2__c, ClaimReference__c, CreatedDate, ASReference__c, LastModifiedDate, EncodedId__c, BodyShop__c, BodyShop__r.Type,MissionNumber__c,
                                                            RecordType.DeveloperName, TECH_EntityCountryCode__c, 
                                                            (SELECT Id FROM PrerequisiteOrders__r)
                                                FROM        Assessment__c
                                                WHERE       Id IN: assessmentIdSet
                                                AND     Status__c !=: ASPISConstants.ASSESS_STATUS_SUBSTITUTION
                                                AND     (isShoppingList__c = false OR (isShoppingList__c = true AND (ShortTermDeletionDate__c >=: System.now() OR ShortTermDeletionDate__c = null )))
                                                ORDER BY    CreatedDate DESC];

        for(Assessment__c currentAssessment : assessmentList)
        {
            // skipping the new assessment with no prerequisite order
            if(currentAssessment.RecordTypeId == newAssessmentRecordTypeId && currentAssessment.PrerequisiteOrders__r.size() == 0)
            {
                continue;
            }

            assessmentWrapperList.add(new AssessmentWrapper(currentAssessment));

            if(currentAssessment.Invoices__r.size() > 0){
                listInvoices.addAll(currentAssessment.Invoices__r);
            }
        }

        System.debug('## assessmentList: ' + assessmentList);

        if(assessmentList.size() > 0){

            //AMI 25/10/2018  C-002781 : Migrate Spain to R4
            //                         : Do not display invoice info for Spain
            //                         : query for invoice should not be performed in case of spain
            if(!isSpain){
                retrieveinvoiceData(assessmentList);
            }else {
                //AMI 23/11/2018  C-002781 : Migrate Spain to R4
                //                         : Display Cases
                //                         : Retrieve Cases
                retrieveCaseData(assessmentList);
            }

            system.debug('##searchdata'+listInvoices.size());
        }
        System.debug('## listInvoices: ' + listInvoices);
    }

     //14/05/2018 DUN Case C-002235 : Customer Site : Search bar should retrieve other results than assessments
     //function to retrieve the invoice in descending order and also to retrieve fields that should not be searchable
    public void retrieveinvoiceData(list<Assessment__c> assessmentList)
    {
        listInvoices = [SELECT  Id, Assessment__r.Manufacturer__c, Assessment__r.ModelV2__c, PlateNumber__c, Number__c, Type__c, CreatedDate, InvoicePaidDate__c, Date__c, TotalNet__c,
                                TECH_Number__c, TechCountryCode__c
                        FROM        Invoice__c
                        WHERE       (Assessment__r.ParentAssessment__c in: assessmentList
                        OR          Assessment__c in: assessmentList)
                        AND         Number__c != null
                        AND         RecordTypeId =: recordTypeIdInvoiceSet
                        ORDER BY    CreatedDate DESC];

        System.debug('## listInvoices: ' + listInvoices);
    }

    //AMI 23/11/2018  C-002781 : Migrate Spain to R4
    //                         : Display Cases
    //                         : Retrieved Cases Queried
    public void retrieveCaseData(list<Assessment__c> assessmentList){
        System.debug('## Start retrieveCaseData');

        CaseWrapper csWrap = new CaseWrapper();

        for(Case__c cs : [select Id,Name,Sales_order__c,Sales_order__r.Name,Type__c,Case_Reason__c,
                             Subject__c,Description__c,Comment__c,SubmittedBy__r.Name,Status__c,Purchase_order__c,
                             Purchase_order__r.Distributor__r.Name,CreatedDate,LastModifiedDate
                             from Case__c
                             WHERE (Assesment__r.ParentAssessment__c in: assessmentList
                             OR Assesment__c in: assessmentList)
                             ORDER BY CreatedDate DESC]){
            csWrap = new CaseWrapper();
            csWrap.cse = cs;
            csWrap.cseEncodedId = encryptBase64(cs.Id);
            lstCaseWrapper.add(csWrap);
        }
        system.debug('## lstCaseWrapper ' + lstCaseWrapper);

        System.debug('## End retrieveCaseData');
    }

    public void getRecentList()
    {
        isShowingSearchResult = false;
        List<Id> assessmentIdList = new List<Id>();
        for(RecentlyViewed currentRecentItem : [SELECT      Id, Name, RecordTypeId, Type
                                                FROM        RecentlyViewed
                                                WHERE       Type = 'Assessment__c'
                                                /*AND           RecordTypeId =: Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()*/
                                                AND         LastViewedDate != null
                                                ORDER BY    LastViewedDate DESC
                                                LIMIT       20])
        {
            assessmentIdList.add(currentRecentItem.Id);
        }

        System.debug('## assessmentIdList : ' + assessmentIdList.size());
        System.debug('## isShowingSearchResult : ' + isShowingSearchResult);

        if(assessmentIdList.size() > 0)
        {
            retrieveRecentlyViewed(assessmentIdList);
        }
    }

    public void retrieveRecentlyViewed(List<Id> assessmentIdList)
    {
        // Pushing the data in a map so as to get a sorted list according to the assessmentIdList
        Map<Id, Assessment__c> mapAssessment = new Map<Id, Assessment__c>([ SELECT  Id, Manufacturer__c, ModelV2__c, PlateNumber2__c, ClaimReference__c, CreatedDate, ASReference__c, LastModifiedDate, EncodedId__c, BodyShop__c, BodyShop__r.Type,MissionNumber__c,
                                                                                    RecordType.DeveloperName, TECH_EntityCountryCode__c, (SELECT Id FROM PrerequisiteOrders__r)
                                                                            FROM    Assessment__c
                                                                            WHERE   Id IN: assessmentIdList
                                                                            AND     (RecordType.DeveloperName = 'Claim' OR RecordType.DeveloperName = 'NewAssessment')
                                                                            AND     (isShoppingList__c = false OR (isShoppingList__c = true AND ShortTermDeletionDate__c >=: System.now()))]);
        // ensuring that the list empty                                                                 
        // assessmentList = new List<Assessment__c>();
        assessmentWrapperList = new List<AssessmentWrapper>();

        for(Id currentAssessmentId : assessmentIdList)
        {
            if(mapAssessment.containsKey(currentAssessmentId))
            {
                Assessment__c currentAssessment = mapAssessment.get(currentAssessmentId);
                // assessmentList.add(mapAssessment.get(currentAssessmentId));
                if(currentAssessment.RecordType.DeveloperName == 'Claim')
                {
                    assessmentWrapperList.add(new AssessmentWrapper(currentAssessment));
                }
                // for the code to come here it should be a NewAssessment, therefore should only display those with sales order
                else if(currentAssessment.PrerequisiteOrders__r.size() > 0)
                {
                    assessmentWrapperList.add(new AssessmentWrapper(currentAssessment));
                }
            }
        }
        system.debug('##assessmentWrapperList '+assessmentWrapperList);
    }

    public void checkHideSiteWelcomePopup()
    {
        if(currentUser.HideSiteWelcomePopup__c)
        {
            update new User(Id                      = currentUser.Id,
                            HideSiteWelcomePopup__c = true);
        }

        showWelcomeModal = false;
    }

    public class AssessmentWrapper
    {
        public Assessment__c currentAssessment {get; set;}
        public PrerequisiteOrder__c currentSalesOrder {get; set;}
        public String salesOrderEncodedId {get; set;}

        public Boolean redirectToSO {get; set;}

        public AssessmentWrapper(Assessment__c incomingAssessment)
        {
            currentAssessment = incomingAssessment;
            redirectToSO      = false;

            if(currentAssessment.RecordType.DeveloperName == 'NewAssessment' && currentAssessment.PrerequisiteOrders__r.size() > 0)
            {
                currentSalesOrder   = currentAssessment.PrerequisiteOrders__r[0];
                salesOrderEncodedId = encryptBase64(currentSalesOrder.Id);
                redirectToSO        = true;
            }
        }
    }

    public static String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    public boolean eligibleQuotation(Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping)
    {

      CountryCodeInformationsMapping__c currentCountryInfo = (mapCountryCodeMapping.containsKey(currentUser.CountryCode) ? mapCountryCodeMapping.get(currentUser.CountryCode) : mapCountryCodeMapping.get('DEFAULT'));

      if(currentCountryInfo != null)
      {
        isEligibleQuotation = currentCountryInfo.EligibleQuotation__c;
      }
      return isEligibleQuotation;
    }

    //AMI 23/11/18  C-002781 : Migrate Spain to R4
    //                       : Display Cases 
    //                       : wrapper containing case to display
    public class CaseWrapper{
        public Case__c cse {get;set;}
        public String cseEncodedId {get;set;}

        public CaseWrapper(){
            cse = new Case__c();
            cseEncodedId = '';
        } 
    }
}