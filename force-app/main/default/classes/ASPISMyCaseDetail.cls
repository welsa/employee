/*
----------------------------------------------------------------------
-- - Name          : ASPISMyCaseDetail
-- - Author        : AMI
-- - Description   : Controller for page ASPISMyCaseDetail
--
-- Maintenance History:
--
-- Date         Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 15-NOV-2018  AMI    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISMyCaseDetail {
	public Case__c caseObj {get;set;}
    public boolean errorGenerated {get;set;}
    public String locale {get; set;}
    public String encryptedText {get; set;}
    public String decryptedCaseId {get; set;}
    public String encryptedSOId {get;set;}
    public boolean showFeed {get;set;}

	public ASPISMyCaseDetail() {
		system.debug('## Start ASPISMyCaseDetail Constructor');

		caseObj 											= new Case__c();
        errorGenerated                                      = false;
        locale                                              = UserInfo.getLocale();
        showFeed                                            = false;

		try{
            if(ApexPages.currentPage().getParameters().get('Id') != null){
                encryptedText                               = ApexPages.currentPage().getParameters().get('Id');
                decryptedCaseId                             = decryptBase64(encryptedText); 

                if(string.isNotBlank(decryptedCaseId)){
                	//query case
                	for(Case__c cs : [select Id,Name,Sales_order__c,Sales_order__r.Name,Purchase_order__c,Purchase_order__r.Distributor__r.Name,
                						Type__c,Case_Reason__c,Subject__c,Description__c,Comment__c,SLAIcon__c,Status__c,SLAAssignationDate__c,
                                        SLAClosedEntryDate__c,SLAResolutionDurationTEXT__c,Assesment__c,CountryCode__c
                    					from Case__c
                    					where id = :decryptedCaseId
                                        FOR VIEW]){
                		caseObj 							= cs;
                	}

                    if(caseObj.Assesment__c != null){
                        //Display related assessment in recently viewed when a case is views
                        Assessment__c currentAssessment = [ SELECT   Id
                                                              FROM  Assessment__c
                                                              WHERE  Id =: caseObj.Assesment__c
                                                              FOR VIEW];
                    }//end if caseObj.Assesment__c != null

                    if(caseObj.Sales_order__c != null){
                        encryptedSOId = encryptBase64(string.valueOf(caseObj.Sales_order__c));
                    }

                    Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();

                    if(string.isNotBlank(caseObj.CountryCode__c) && mapCountryCodeMapping.containsKey((caseObj.CountryCode__c).toUpperCase())){
                        showFeed = mapCountryCodeMapping.get((caseObj.CountryCode__c).toUpperCase()).EnableChatterFeed__c;
                    }
                }
            }
        }catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                decryptedCaseId                               = '';
                errorGenerated                                = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedId));
            }else{
                decryptedCaseId                               = '';
                errorGenerated                                = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,system.label.MyCaseDetailMsg19));
            }       
        }

		system.debug('## End ASPISMyCaseDetail Constructor');
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

    @RemoteAction
    public static string updateCase(list <Case__c> cseListToUpdate){
        system.debug('## Start updateCase');

        string errorMsg                                     = '';
        Case__c cseToUpdate                                 = new Case__c();
        Database.SaveResult updateResults;

        system.debug('## cseListToUpdate ' + cseListToUpdate);
        if(!cseListToUpdate.isEmpty()){
            //escaping characters
            cseToUpdate                                     = cseListToUpdate[0];

            if(string.isNotBlank(cseListToUpdate[0].Subject__c)){
                cseToUpdate.Subject__c                      = string.escapeSingleQuotes(cseListToUpdate[0].Subject__c);
            }

            if(string.isNotBlank(cseListToUpdate[0].Comment__c)){
                cseToUpdate.Comment__c                      = string.escapeSingleQuotes(cseListToUpdate[0].Comment__c);
            }

            //updating the case obj
            updateResults                                   = Database.update(cseToUpdate,false);

            //check for errors
            if(!updateResults.isSuccess()){
                errorMsg                                    = updateResults.getErrors()[0].getMessage();
            }
        }//end if !cseListToUpdate.isEmpty()
        else{
            errorMsg                                        = string.valueOf(system.label.MyCaseDetailMsg19);
        }

        system.debug('## End updateCase');
        return errorMsg;
    }

    @RemoteAction
    public static list <Attachment> retrieveAtt(string caseId){
        system.debug('## Start retrieveAtt');

        list <Attachment> lstExistingAttachment              = [select id,Name,LastModifiedDate ,CreatedBy.Name
                                                                from Attachment
                                                                where parentid = :caseId];

        system.debug('## End retrieveAtt');
        return lstExistingAttachment;
    }

    @RemoteAction
    public static void deleteAtt(string attId){
        system.debug('## Start deleteAtt');

        delete(new Attachment(id = attId));

        system.debug('## End deleteAtt');
    }
}