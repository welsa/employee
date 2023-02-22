/*************************************************************************************
Class Name - AP21AssessmentSharing
Version - 1.0
Created Date - 02 DEC 2015
Function - 
-- ES BodyShop is allowed to change BS by a BS he has access to on Assessment.
-- once the change is made, this assessment is shared with new BS group, and the BS on the corresponding SO is changed
-- Note: It's possible only if the status of the SalesOrder is "inAcceptance" or "inDelivery". a message error is raised if status is higher than "Delivered Confirmed".


Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Brayan Nunhuck 02/12/2015     Original Version
* Ashwina S      29/03/2015     Updated version: case 1435. Add assessment to body shop's group
* Abdool M       28/06/2018     Force.com to Community License Migration  
* Ruksaar L      24/10/2018     C-002776 : Optimisation of RestUpsertAssessmentV2
* Welsa C        11/01/2019     C-002991 : Developer script exception from Alpha Scale : 'AP21AssessmentSharing' for job id '7071i00000CWGnW' : Delete failed.
*************************************************************************************/
public without sharing class AP21AssessmentSharing {  
    
    //WCH 11/01/2019 C-002991 Developer script exception from Alpha Scale : 'AP21AssessmentSharing' for job id '7071i00000CWGnW' : Delete failed.
    private static boolean afterUpdateFirstRun = true;

    public static void createSharingAssessment(List<Assessment__c> assessmentList, set<Id> BSIdSet, set<Id> OldBSIdSet){
        system.debug('########## AP21AssessmentSharing createSharingAssessment START');
        //map<BS id, group Id>
        map<Id, Id> accGroupMap = new map<Id, Id>();    
        //map<BS ReferenceNumber,BSId>
        map<String, Id> BSIdRefMap = new map<String, Id>(); 
        list<Assessment__Share> assessShareList = new list<Assessment__Share>();
        list<Assessment__Share> aShareToBeDelList = new list<Assessment__Share>();
        //map <assessmentId, newBodyShopId>
        map<Id, Id> assessBSMap = new map<Id, Id>();
        list<PrerequisiteOrder__c> updatedSOList= new list<PrerequisiteOrder__c>();
        set<Id> groupIdSet = new set<Id>();
        set<Id> assSet = new set<Id>(); 


        //AMI 28/06/18 : Force.com to Community License Migration
        //             : Prevent programatic dml on sharing rule if user has community license
        Boolean doNotExecuteSharing = false;

        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
        string userType = UserInfo.getUserType();
        system.debug('## userType ' + userType);
        //             : get connected user info
        //User uObj = [Select id,Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()];

        if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains((userType).toLowerCase())){
            doNotExecuteSharing = true;     
        }
        
        // select reference from BodyShop
        for(Account BS:  [select ReferenceNumber__c from Account where id in: BSIdSet or id in:OldBSIdSet]){
            BSIdRefMap.put(BS.ReferenceNumber__c, BS.Id);
        }
        
        //AMI 28/06/18 : Force.com to Community License Migration
        //             : Prevent programatic dml on sharing rule if user has community license
        if(!doNotExecuteSharing){
            // get public group of accounts
            for(Group g:[select Id,Name from Group where Name IN: BSIdRefMap.keyset()]){
                accGroupMap.put(BSIdRefMap.get(g.Name),g.Id);
                // if id is found in:OldBSIdSet then sharing should be deleted
                if(OldBSIdSet.size()>0){            
                    if(OldBSIdSet.contains(BSIdRefMap.get(g.Name))){
                        groupIdSet.add(g.Id);
                    }
                }
            }
        }
        
        //loop in assessmentList to create manual sharing and add in BS group
        for(Assessment__c assessToBeShared: assessmentList){
            // build map <assessmentId, newBodyShopId>
            assessBSMap.put(assessToBeShared.Id, assessToBeShared.BodyShop__c);
            if (accGroupMap.get(assessToBeShared.BodyShop__c) != null){
                //Create manual sharing on Assessment
                Assessment__Share aShare = new Assessment__Share (UserOrGroupId = accGroupMap.get(assessToBeShared.BodyShop__c),ParentId=assessToBeShared.Id,AccessLevel='Edit');
                assessShareList.add(aShare);
            }    
            assSet.add(assessToBeShared.Id);        
                
        }      
         
        // updating bodyshop on assessment's SO
        for (PrerequisiteOrder__c so : [Select Id,Assessment__c,BodyShop__c from PrerequisiteOrder__c where Assessment__c in :assessmentList]){
            PrerequisiteOrder__c updatedSO = new PrerequisiteOrder__c(id= so.Id, BodyShop__c=assessBSMap.get(so.Assessment__c));
            updatedSOList.add(updatedSO);
        }

        //system.debug('###### assessShareList:'+assessShareList);
        if(assessShareList.size()>0){
            insert assessShareList;

            //system.debug('###### updatedSOList:'+updatedSOList);
            if(updatedSOList.size()>0){
                update updatedSOList;
            }
            
            //system.debug('###### updatedSOList:'+updatedSOList);
        }
        
        system.debug('###### assSet:'+assSet);
        system.debug('###### groupIdSet:'+groupIdSet);
        
        //RLA 24/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
        if (assSet.size() > 0 &&
            groupIdSet.size() > 0){
            deleteSharing(assSet, groupIdSet);
        }
        //// delete sharing
        // for(Assessment__Share aDel :[Select id from Assessment__Share where ParentId in :assessmentList and UserOrGroupId in: groupIdSet]){
        //     aDelSet.add(aDel.Id); 
        // }
        // if(aDelSet.size()>0){         
        //     deleteSharing(aDelSet); 
        // }
         
       system.debug('########## AP21AssessmentSharing createSharingAssessment END');
    }
    

    //RLA 24/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
    @future
    public static void deleteSharing(set<Id> assessmentset, set<Id> groupIdSet ){
        set<Id>aDelSet = new set<Id>();
        // delete sharing
         for(Assessment__Share aDel :[Select id from Assessment__Share where ParentId in :assessmentset and UserOrGroupId in: groupIdSet]){
             aDelSet.add(aDel.Id); 
         }
        if(aDelSet.size()>0){         
            delete [Select id from Assessment__Share where id in: aDelSet];
        }


    }
    //WCH 11/01/2019 C-002991 Developer script exception from Alpha Scale : 'AP21AssessmentSharing' for job id '7071i00000CWGnW' : Delete failed.
    public static boolean isFirstAfterUpdateRun(){
        if(afterUpdateFirstRun){
          afterUpdateFirstRun = false;
          return true;
        }else{
            return afterUpdateFirstRun;
        }
    }
}