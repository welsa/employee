/*
----------------------------------------------------------------------
-- - Name          : VFC23_CreateCaseDistributor
-- - Author        : DUN
-- - Description   : Controller of VFP23_CreateCaseDistributor
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ----------------------------------
-- 10-AUG-2018  DUN     1.0         Initial version
-- 26-OCT-2018  AMI     1.1         Reworked
-- 03-DEC-2018  AMI     1.2         Display Error Message For Btn Access
--                                  When Ad Casd Mgt is not enabled
----------------------------------------------------------------------
**********************************************************************
*/
global without sharing class VFC23_CreateCaseDistributor {

    public boolean displayErrorMsg {get;set;}

    public VFC23_CreateCaseDistributor(){
        //initialise boolean
        displayErrorMsg = false;

        //get current page id
        string purchaseOrderId = Apexpages.currentPage().getParameters().get('Id'); 

        //custom setting
        map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        //check if button is eligible
        //current PO :
        PurchaseOrder__c po =  [select TECH_AssessmentCountryCode__c
                                from PurchaseOrder__c 
                                where Id =: purchaseOrderId];
            
        if(!(string.isNotBlank(po.TECH_AssessmentCountryCode__c) && 
            allConfigCountryCodeInfo.containsKey(po.TECH_AssessmentCountryCode__c) && 
            allConfigCountryCodeInfo.get(po.TECH_AssessmentCountryCode__c).AdvancedCaseManagement__c)){
            displayErrorMsg = true;
        }
    }

    @RemoteAction
    global static map<string,string> createDiscussionCase(string poId,string msg){
        system.debug('## Start createDiscussionCase');

        map<string,string> errorObj = new map <string,string>();

        string aspisSystemUserId = '';

        PurchaseOrder__c currentPO = new PurchaseOrder__c();
        Case__c newCase = new Case__c();

        List <Database.Saveresult> lstResultsCaseCreate;

        //custom setting
        map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        //get aspis system id
        if(string.isNotBlank(system.label.UserAspisSystemName)){
            for(User us : [Select id,Profile.UserLicense.Name 
                            from User 
                            where Name = :system.label.UserAspisSystemName]){
                aspisSystemUserId = us.Id;
            }
        }

        //querying current PO
        system.debug('## poId ' + poId);
        for(PurchaseOrder__c po : [select TECH_AssessmentCountryCode__c, Assessment__r.BodyShop__c, 
                                        Assessment__r.BodyShop__r.ContactUser__c, Assessment__c, Id, PrerequisiteOrder__c, 
                                        Distributor__r.ContactUser__c 
                                    from PurchaseOrder__c 
                                    where Id =: poId]){
            currentPO = po;
        }
        system.debug('## currentPO ' + currentPO);

        //check if eligible advance case mgt
        if(currentPO != null &&
           string.isNotBlank(currentPO.TECH_AssessmentCountryCode__c) && 
           allConfigCountryCodeInfo.containsKey(currentPO.TECH_AssessmentCountryCode__c) && 
           allConfigCountryCodeInfo.get(currentPO.TECH_AssessmentCountryCode__c).AdvancedCaseManagement__c){
            if( string.isNotBlank(currentPO.Assessment__r.BodyShop__c) &&
                string.isNotBlank(currentPO.Assessment__c) &&
                string.isNotBlank(currentPO.Id) &&
                //string.isNotBlank(currentPO.PrerequisiteOrder__c) &&
                string.isNotBlank(currentPO.Distributor__r.ContactUser__c)){

                //new case creation
                newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', 
                                                                                            currentPO.TECH_AssessmentCountryCode__c, 
                                                                                            currentPO.Assessment__r.BodyShop__c, 
                                                                                            currentPO.Assessment__c, 
                                                                                            currentPO.Id, 
                                                                                            currentPO.PrerequisiteOrder__c, 
                                                                                            string.isNotBlank(msg) ? String.escapeSingleQuotes(msg) : null, 
                                                                                            currentPO.Distributor__r.ContactUser__c, 
                                                                                            '-DeliveryProblem');
                system.debug('## newCase part 1 ' + newCase);
                //assigning owner
                if(newCase != null){
                    if(aspisSystemUserId != null){
                        newCase.OwnerId = aspisSystemUserId;
                        newCase.Tech_BSAccount__c = currentPO.Assessment__r.BodyShop__c;
                    }
                    else{
                        newCase.OwnerId = currentPO.Assessment__r.BodyShop__r.ContactUser__c;
                    }
                    system.debug('## newCase part 2' + newCase);

                    //inserting case
                    lstResultsCaseCreate = Database.insert(new list <Case__c>{newCase}, false);

                    for (Database.SaveResult sr : lstResultsCaseCreate) {
                        if (sr.isSuccess()) {
                            return new map <string,string>{'OK'=> sr.getId()}; 
                        }
                        else {
                            // Operation failed, so get all errors   
                            return new map <string,string>{'KO'=> sr.getErrors()[0].getMessage()};
                        }
                    }//end looping in database.save result
                }//end if newCase != null
            }else{
                return new map <string,string>{'KO'=> system.label.AdvanceMgtErrMsg1};
            }
        }else{
            return new map <string,string>{'KO'=> system.label.AdvanceMgtErrMsg2};
        }

        system.debug('## End createDiscussionCase');
        return new map <string,string>{'KO'=> system.label.AdvanceMgtErrMsg1};
    }  
}