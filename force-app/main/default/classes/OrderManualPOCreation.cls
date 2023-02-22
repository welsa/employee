/*
----------------------------------------------------------------------
-- - Name          : OrderManualPOCreation
-- - Author        : VSU
-- - Description   : case 001966: Controller extension for page OrderManualPOCreation,
           which displays all partlists for an assessment to be selected for manual PO creation
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 14-JUN-2017  VSU     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class OrderManualPOCreation
{
    public list <PartList__c> partLists{get;set;}

    public Boolean hasErrors {get; set;}

    public Boolean isToastError {get; set;}

    public Boolean manualSourcing {get;set;}

    public decimal noOfParts {get;set;}

    public Assessment__c assessmentDE;

    public Boolean redirectionInErrorModal {get; set;}

    public OrderManualPOCreation()
    {
        String assessmentId       = ApexPages.currentPage().getParameters().get('Id');

        manualSourcing = true;
        redirectionInErrorModal = false;
        
        assessmentDE = [Select TECH_EntityCountryCode__c,bodyshop__r.isEligibleSourcing__c,Status__c,EntityRules__c,
                            (Select id,PartNumber__c,Description__c,SelectedByBS__c,Type__c FROM PartsLists__r WHERE Assessment__c =: assessmentId)
                        FROM Assessment__c 
                        WHERE id =: assessmentId];

        partLists = assessmentDE.PartsLists__r;

        for(PartList__c pl: partLists){
            pl.SelectedByBS__c = false;
        } 

        if(!verifyPermission(assessmentDE)){
            redirectionInErrorModal = true;
            manualSourcing = false;
        }

        noOfParts = partLists.size();     
    }
    public PageReference back()
    {
        hasErrors = false;
        isToastError = false;

        return new PageReference('/'+assessmentDE.id);
    }

    public PageReference validate(){
        hasErrors    = false;
        isToastError = false;     

        assessmentDE.Status__c = 'CHECKED';

        ASPISConstants.manualSourcingPO = true;
        system.debug('## ASPISConstants.manualSourcingPO' + ASPISConstants.manualSourcingPO);

        if(partLists.size() > 0){
            try{
                update partLists;
            }
            catch(Exception e){
                hasErrors = true;
                isToastError = false;
                Utils_ManageLogs.createLogFromException('OrderManualPOCreation', 'PartList__c', e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }

            try{
                update assessmentDE;

            }
            catch(Exception e){
                hasErrors = true;
                isToastError = false;
                Utils_ManageLogs.createLogFromException('OrderManualPOCreation', 'Assessment__c', e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }                        
        }

        return new PageReference('/'+assessmentDE.id);
    }

    /**
     * Function to verify the permission of the user to the assessment
     * @param  currentClaimAssessment The assessment on which the permissions needs to be checked
     * @return                        Whether the user has access to the assessment
     */
    private Boolean verifyPermission(Assessment__c assessment)
    {
        List<UserRecordAccess> userRecordAccessList = [ SELECT  RecordId
                                                        FROM    UserRecordAccess
                                                        WHERE   RecordId =: assessment.id
                                                        AND     UserId =: UserInfo.getUserId()
                                                        AND     HasReadAccess = true];

        return (userRecordAccessList != null && userRecordAccessList.size() > 0 
            && assessment.Status__c == 'READY' && assessment.TECH_EntityCountryCode__c == 'DE' 
            && assessment.bodyshop__r.isEligibleSourcing__c == false);
    }
}