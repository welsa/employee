/*
----------------------------------------------------------------------
-- - Name          : ASPISMyCases
-- - Author        : AMI
-- - Description   : Controller for page ASPISMyCases
--
-- Maintenance History:
--
-- Date         Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 12-NOV-2018  AMI    1.0      Initial version
-- 18-JUL-2019  WCH    1.1      C-003340 - In R4, Add additional columns on 2 pages
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISMyCases {
	public String locale {get; set;}
	public Boolean hasErrors {get; set;}  
    public Boolean isToastError {get; set;}
	public String encryptedText {get; set;}
	public String decryptedBSId {get; set;}
	public String fromDateStr {get;set;}
    public String toDateStr {get;set;}
    public string problem {get;set;}
    public string question {get;set;}

	public ASPISMyCases(){
		system.debug('## Start ASPISMyCases Constructor');

		locale                                              = UserInfo.getLocale();
		hasErrors                                           = false;
        isToastError                                        = false;
        problem                                             = ASPISConstants.caseTypePROBLEM;
        question                                            = ASPISConstants.caseTypeQUESTION;

		try{
            if(ApexPages.currentPage().getParameters().get('Id') != null){
                encryptedText                               = ApexPages.currentPage().getParameters().get('Id');
         
                decryptedBSId                               = decryptBase64(encryptedText); 
            }
            
            fromDateStr                                     = (System.Today().addDays(-30)).format();
            toDateStr                                       = (System.today()).format();
        }catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                hasErrors                                   = true;
                isToastError                                = true;
                decryptedBSId                               = '';
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedId));
            }else{
                hasErrors                                   = true;
                isToastError                                = true;
                decryptedBSId                               = '';
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,system.label.MyCasesErrMsg1));
            }       
        }

		system.debug('## End ASPISMyCases Constructor');
	}

	@RemoteAction
    public static globalWraper searchCases(String fromDateStr,String toDateStr,boolean all,boolean isClosed){
		system.debug('## Start caseWrapper');

		list <caseWrapper> lstCsWrapper                     = new list <caseWrapper>();
        globalWraper globalWrap                             = new globalWraper();
        string userAccId                                    = '';
        set <id> setRecentlyViewedCases                     = new set <id>();

        //query connected user account id
        for(User us : [select id,AccountId
                        from User
                        where id = :UserInfo.getUserId()]){
            if(us.AccountId != null){
                userAccId                                   = string.valueOf(us.AccountId);
            }
        }

        //query recently viewed cases
        for(RecentlyViewed currentRecentItem : [SELECT      Id
                                                FROM        RecentlyViewed
                                                WHERE       Type = 'Case__c'
                                                AND         LastViewedDate != null
                                                ORDER BY    LastViewedDate DESC]){
            setRecentlyViewedCases.add(currentRecentItem.Id);
        }
        system.debug('##setRecentlyViewedCases.size() ' + setRecentlyViewedCases.size());

        string query                                        = ' select Id,Name,Sales_order__c,Sales_order__r.Name,toLabel(Type__c),Case_Reason__c, ';
        query                                               += ' Subject__c,Description__c,Comment__c,SubmittedBy__r.Name,Status__c,Purchase_order__c, ';
        query                                               += ' Purchase_order__r.Distributor__r.Name,CreatedDate, ';
        query                                               += ' Purchase_order__r.PlateNumber__c,CountryCode__c ';//WCH 18/07/2019 C-003340 In R4, Add additional columns on 2 pages
        query                                               += ' from Case__c where id != null ';

        if(string.isNotBlank(userAccId)){
            query                                           += ' and Tech_BSAccount__c = :userAccId ';

            if(isClosed == true && all == false){
                query                                       += ' and Status__c = \'' +  ASPISConstants.caseStatusClosed  +  '\'';
            }else if(isClosed == false && all == false){
                query                                       += ' and Status__c != \'' +  ASPISConstants.caseStatusClosed +  '\'';
            }
        
            if(fromDateStr !=null && fromDateStr != ''){
                Date dt1                                    = Date.parse(fromDateStr);
                query                                       += ' and DAY_ONLY(CreatedDate) >=: dt1 ';
            } 

            if(toDateStr !=null && toDateStr != ''){
                Date dt2                                    = Date.parse(toDateStr);
                query                                       += ' and DAY_ONLY(CreatedDate) <=: dt2 ';
            }  

            query                                           += ' ORDER BY CreatedDate DESC ';

            //describing case status to get translated label
            Schema.DescribeSObjectResult objSchema          = Case__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap       = objSchema.fields.getmap();
            map <string,string> mapTranslatedStatus         = new map <string,string>();

            for(Schema.Picklistentry pk : fieldMap.get('Status__c').getDescribe().getpicklistValues()){
                mapTranslatedStatus.put(pk.getValue().toLowerCase(),pk.getLabel());
            }
            
            //query Case
            system.debug('##query ' + query);
            try{
                for(Case__c c : dataBase.query(query)){
                    caseWrapper csWrap                      = new caseWrapper();
                    
                    csWrap.cse                              = c;
                    csWrap.caseEncodedId                    = encryptBase64(string.valueOf(c.Id));

                    if(c.Sales_order__c != null){
                        csWrap.soEncodedId                  = encryptBase64(string.valueOf(c.Sales_order__c));
                    }

                    if(mapTranslatedStatus.containsKey(c.Status__c.toLowerCase())){
                        csWrap.caseStatus                   = mapTranslatedStatus.get(c.Status__c.toLowerCase());
                    }
                    //WCH 18/07/2019 C-003340 In R4, Add additional columns on 2 pages
                    csWrap.plateNumber=c.Purchase_order__r.PlateNumber__c;

                    lstCsWrapper.add(csWrap);
                }

                if(!lstCsWrapper.isEmpty()){
                    globalWrap.errorMsg                     = '';
                    globalWrap.lstCaseWrapper               = lstCsWrapper;
                }
            }Catch(QueryException e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }//end string.isNotBlank(userAccId)
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,system.label.MyCasesErrMsg1));
        }

        //update hasViewed on wrapper
        if(string.isBlank(globalWrap.errorMsg) && globalWrap.lstCaseWrapper.size() > 0){
            //get wrapper
            for(caseWrapper csWrapper : globalWrap.lstCaseWrapper){
                //check if present in setRecentlyViewedCases
                if(setRecentlyViewedCases.contains(csWrapper.cse.Id)){
                    csWrapper.hasViewed                     = true;
                }
            }
        }

		system.debug('## End caseWrapper');
        system.debug('## globalWrap ' + globalWrap);
		return globalWrap;
    }

	public static String decryptBase64(String encryptedText){
        Blob decryptedData                                  = EncodingUtil.base64Decode(encryptedText);
        String decryptedText                                = decryptedData.toString();

        return decryptedText;
    }

    public static String encryptBase64(String text){
        Blob encryptedBlob                                  = Blob.valueOf(text);
        String encryptedData                                = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    public PageReference redirectPage(){
        PageReference pageRef                               = Page.Search;
        pageRef.setRedirect(true);
        return pageRef;
    }

    public class globalWraper{
        public string errorMsg {get;set;}
        public list <caseWrapper> lstCaseWrapper {get;set;}

        public globalWraper(){
            errorMsg                                        = '';
            lstCaseWrapper                                  = new list <caseWrapper>();
        }
    }

    public class caseWrapper{
    	public Case__c cse {get;set;}
    	public string soEncodedId {get;set;}
        public string caseEncodedId {get;set;}
        public boolean hasViewed {get;set;}
        public string caseStatus {get;set;}
        public string plateNumber {get;set;}//WCH 18/07/2019 C-003340 In R4, Add additional columns on 2 pages

        public caseWrapper(){
            this.cse                                        = new Case__c();
            this.soEncodedId                                = '';
            this.caseEncodedId                              = '';
            this.hasViewed                                  = false;
            this.caseStatus                                 = '';
            this.plateNumber                                 = '';//WCH 18/07/2019 C-003340 In R4, Add additional columns on 2 pages
        }

    	public caseWrapper(Case__c cse,string soEncodedId,string caseEncodedId,boolean hasViewed,string caseStatus){
	    	this.cse                                        = cse != null ? cse : new Case__c();
	    	this.soEncodedId                                = string.isNotBlank(soEncodedId) ? soEncodedId : '';
            this.caseEncodedId                              = string.isNotBlank(caseEncodedId) ? caseEncodedId : '';
            this.hasViewed                                  = hasViewed;
            this.caseStatus                                 = caseStatus;
    	}
    }
}