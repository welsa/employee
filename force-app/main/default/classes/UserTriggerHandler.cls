/*************************************************************************************
Class Name - UserTriggerHandler
Version - 1.0
Created Date - 28 APR 2015
Function - Class to Manage UserTrigger

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Yudish R          28/04/2015  Original Version
* Shamina M         11/02/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
* Ashutosh B        06/04/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
* Welsa C           22/09/2020  C-003923: NOB - Sharing Rules Management
* Welsa C           19/11/2020  C-004032: NOB - Contact Management 2.0
* Welsa C           27/11/2020  C-003986: NOB - User Management
* Welsa C           04/12/2021  C-004177: batch AspisBatch_NewBSContactCreation error
* Welsa C           04/12/2021  C-004179: Local admin BE cannot see Community Login User
* Hansraj M         19/02/2021  RSIW 8386 - Create account sharing for Prefikar users func() : createAccountSharing
*************************************************************************************/
public without sharing class UserTriggerHandler {
    //Bypass__c userBypass = Bypass__c.getInstance(UserInfo.getUserId());
    public void onBeforeInsert(User[] newUsers){
        system.debug('######### START onBeforeInsert trigger handler');
        
        //WCH 22/09/2020 C-003923
        boolean isAlphaScaleUser = ASPISTools.isAlphaScaleUser();
        boolean connectedUserSystemAdmin = ASPISConstants.getProfileAdminId().equals(Userinfo.getProfileId());
        
        // Loop in the newUsers list
		for(Integer i=0; i < newUsers.size(); i++)
		{
            //WCH 22/09/2020 C-003923
            if(isAlphaScaleUser && !connectedUserSystemAdmin){
                newUsers[i].isAspis__c=true;
            }

        }
        system.debug('######### END onBeforeInsert trigger handler');
    }
    public void onAfterInsert(User[] newUsers){
        system.debug('######### START onAfterInsert trigger handler');

		// ABT 06-APR-2016 C-1496
		// Map to store the reference number and its user
		// Using List of user in case 2 user has the same reference number
		Map<String, List<User>> mapReferenceNumberListOfUser = new Map<String, List<User>>();
        List<Id> lstUserIds = new List<Id>();//WCH 19/11/2020 C-004032

		// Loop in the newUsers list
		for(Integer i=0; i < newUsers.size(); i++)
		{
			if (newUsers[i].IsActive)
			{
				if (newUsers[i].BodyShopID__c != null)
				{
					if (mapReferenceNumberListOfUser.containsKey(newUsers[i].BodyShopID__c))
					{
						mapReferenceNumberListOfUser.get(newUsers[i].BodyShopID__c).add(newUsers[i]);
					}
					else
					{
						mapReferenceNumberListOfUser.put(newUsers[i].BodyShopID__c, new List<User>{newUsers[i]});
					}
				}

				if (newUsers[i].DistributorID__c != null)
				{
					if (mapReferenceNumberListOfUser.containsKey(newUsers[i].DistributorID__c))
					{
						mapReferenceNumberListOfUser.get(newUsers[i].DistributorID__c).add(newUsers[i]);
					}
					else
					{
						mapReferenceNumberListOfUser.put(newUsers[i].DistributorID__c, new List<User>{newUsers[i]});
					}
				}
			}

            //WCH 19/11/2020 C-004032
            if(newUsers[i].ContactId!=null){
                lstUserIds.add(newUsers[i].Id);
            }
        }


		try
		{
            if(mapReferenceNumberListOfUser.size() > 0)
			{
				AP28UserAccountGroupSharing.shareUser(mapReferenceNumberListOfUser);
			}
        } 
		catch(Exception ex)
		{

            Utils_ManageLogs.createLogFromException('UserTriggerHandler', 'GroupMember', ex);
        }
        //WCH 19/11/2020 C-004032
        if(lstUserIds.size()>0){
            if(!(System.isBatch() || System.isFuture())){

                setContactAlphaScaleOrPrefikarCommunityUser(lstUserIds);
                createManualSharingForCommunityUser(lstUserIds);
            }
        }


        
        // //set<Id>bodyShopIds = new set<id>();
        // //set<Id>distributorIds = new set<id>();
        // set<string>bodyShopIds = new set<string>();
        // set<string>distributorIds = new set<string>();
		// 
        // list<User> users = new list<User>();
        // map<string,string> accountMap = new map<string,string>();
        // map<string,Id> groupMap = new map <string,Id>();
        // //set<string>accountNames = new set<string>();
        // list<GroupMember> groupMemberToBeInserted = new list<GroupMember>();
        // 
        // //add bodyShopId and distributorId in set
        // for(integer i=0;i<newUsers.size();i++){
        //     if(newUsers[i].BodyShopID__c!=null){
        //         bodyShopIds.add(newUsers[i].BodyShopID__c);
        //     }//end if
        //     
        //     if(newUsers[i].DistributorID__c!=null){
        //         distributorIds.add(newUsers[i].DistributorID__c);
        //     }//end if
        //     
        //     if(newUsers[i].BodyShopID__c!=null || newUsers[i].DistributorID__c!=null){
        //         users.add(newUsers[i]);
        //     }
        // }//end loop
        //  system.debug('////bodyShopIds: '+bodyShopIds);
        // 
        // //build map accountName and accountId
        // // new development --> ReferenceNumber__c added, replacing id
        // for(Account a: [select ReferenceNumber__c,id,Name,RecordType.DeveloperName 
        //                     from account where (ReferenceNumber__c IN: bodyShopIds 
        //                         OR ReferenceNumber__c IN:distributorIds)]){
        //     if(a.RecordType.DeveloperName == ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor 
        //             || a.RecordType.DeveloperName == ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop){
        //         accountMap.put(a.ReferenceNumber__c,a.Name);
        //         //accountNames.add(a.Name);
        //     }//end if
        // }//end loop
        // 
        // system.debug('////accountMap: '+accountMap);
        // 
        // //Shamina M: case 1496
        // //build map groupName and groupId
        // for(Group g:[select Id,Name from Group where Name IN: accountMap.keySet()]){
        //     groupMap.put(g.Name,g.Id);
        // }//end loop
        // system.debug('////groupMap: '+groupMap);
        // //Shamina M-case 1496
        // for(User u:users){
        //     if(u.isActive){
        //         if(u.BodyShopID__c!=null){
        //             if(groupMap.containsKey(u.BodyShopID__c)){
        //                 groupMemberToBeInserted.add(
        //                     new GroupMember(GroupId = groupMap.get(u.BodyShopID__c),UserOrGroupId = u.Id)
        //                 );
        //             }//end if
        //             /*
        //             if(accountMap.containsKey(u.BodyShopID__c)){
        //                 if(groupMap.containsKey(accountMap.get(u.BodyShopID__c))){
        //                     groupMemberToBeInserted.add(
        //                         new GroupMember(GroupId = groupMap.get(accountMap.get(u.BodyShopID__c)),UserOrGroupId = u.Id)
        //                     );
        //                 }//end if
        //             }//end if
        //             */
        //         }//end if
        //         else if(u.DistributorID__c!=null){
        //             if(groupMap.containsKey(u.DistributorID__c)){
        //                 groupMemberToBeInserted.add(
        //                     new GroupMember(GroupId = groupMap.get(u.DistributorID__c),UserOrGroupId = u.Id)
        //                 );
        //             }//end if
        //             /*
        //             if(accountMap.containsKey(u.DistributorID__c)){
        //                 if(groupMap.containsKey(accountMap.get(u.DistributorID__c))){
        //                     groupMemberToBeInserted.add(
        //                         new GroupMember(GroupId = groupMap.get(accountMap.get(u.DistributorID__c)),UserOrGroupId = u.Id)
        //                     );
        //                 }//end if
        //             }//end if
        //             */
        //         }//end elseif
        //     }//end if
        // }//end loop
		// 
        // //Shamina M- case 1496 - managed exception by creating logs
        // try{
        //     if(groupMemberToBeInserted.size() > 0)
        //         insert groupMemberToBeInserted;
        //          system.debug('######### groupMemberToBeInserted:'+groupMemberToBeInserted);
        // } catch(Exception ex){
        //     Utils_ManageLogs.createLogFromException('UserTriggerHandler', 'GroupMember', ex);
        // }
        // 
        // /*
        // system.debug('////groupMemberToBeInserted: '+groupMemberToBeInserted);
        // if(groupMemberToBeInserted.size()>0){
        //     insert groupMemberToBeInserted;
        // }//end if
        // */
        system.debug('######### END onAfterInsert trigger handler');
    }
    
	    //HMO -- 19/02/2021 -- RSIW 8386
    public void NOBOnAfterInsert(User[] newUsers){
        system.debug('######### START NOBOnAfterInsert method in UserTriggerHandler');
        Set<Id> setUserIds = new Set<Id>();
        Set<Id> setUserIdsDocFin = new Set<Id>();
        Set<Id> setDebtOrCreditThirdPartyAccountId = new Set<Id>();
        List<Profile> lstProfiles = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'CCP Bodyshop' LIMIT 1]);
        if(lstProfiles.size() > 0){
            for(User u : newUsers){
                if(u.AccountId != null && u.ProfileId == lstProfiles[0].Id){
                    setUserIds.add(u.Id);
                }
                if(u.AccountId != null && u.IsActive ){
                    setUserIdsDocFin.add(u.Id);
                    setDebtOrCreditThirdPartyAccountId.add(u.AccountId);
                }
                
            }
            if(setUserIds.size() > 0) {
                NOB_AP55_AccountSharing.userAccountSharing(setUserIds);
            }
            if(setUserIdsDocFin.size() > 0) {
                NOB_AP56_DocumentFinancierSharing.userShareDocFinSharing(setUserIdsDocFin, setDebtOrCreditThirdPartyAccountId);
            }
        }
        system.debug('######### END NOBOnAfterInsert method in UserTriggerHandler');
    }
    //HMO end

    /**
     * @Description Trigger handler for User After Update RSIW-8386
     * @param lstNew Trigger.new list
     * @param lstNew Trigger.old list
     * @return void
     * @author BBH
     * @date 23/02/2021
    */
    public void NOBOnAfterUpdate(List<User> lstNew, List<User> lstOld){
        system.debug('######### START NOBOnAfterUpdate method in UserTriggerHandler');
        Set<Id> setUserIds = new Set<Id>();
        Set<Id> setUserIdsDocFin = new Set<Id>();
        Set<Id> setDebtOrCreditThirdPartyAccountId = new Set<Id>();
        List<Profile> lstProfiles = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'CCP Bodyshop' LIMIT 1]);
        if(lstProfiles.size() > 0){
            for(Integer i = 0; i<lstNew.size(); i++){
                if(lstNew[i].IsActive && lstNew[i].IsActive != lstOld[i].IsActive && lstNew[i].AccountId != null && lstNew[i].ProfileId == lstProfiles[0].Id){
                    setUserIds.add(lstNew[i].Id);
                }

                if(lstNew[i].IsActive != lstOld[i].IsActive &&  lstNew[i].AccountId != null && lstNew[i].IsActive ){
                    setUserIdsDocFin.add(lstNew[i].Id);
                    setDebtOrCreditThirdPartyAccountId.add(lstNew[i].AccountId);
                }
            }
            if(setUserIds.size() > 0) {
                NOB_AP55_AccountSharing.userAccountSharing(setUserIds);
            }
            if(setUserIdsDocFin.size() > 0) {
                NOB_AP56_DocumentFinancierSharing.userShareDocFinSharing(setUserIdsDocFin, setDebtOrCreditThirdPartyAccountId);
            }
        }
        system.debug('######### END NOBOnAfterUpdate method in UserTriggerHandler');
    }
	
    public void onAfterUpdate(User[] newUsers,User[] oldUsers){
        
        //bodyshop
        //set<Id>newBodyShopIds = new set<Id>();
        //set<Id>oldBodyShopIds = new set<Id>();

        // set<refNUmber>
        set<String>newBodyShopIds = new set<String>();
        set<String>oldBodyShopIds = new set<String>();       
        set<String>newDistributorIds = new set<String>();
        set<String>oldDistributorIds = new set<String>();
        list<User> users = new list<User>();
        Map<Id,User> mapContactIdUser = new Map<Id,User>();//WCH 19/11/2020 C-004032

        // ASE 06/04/2016 C-1496
        // Map<reference number, list<user>>       
        Map<String, List<User>> mapReferenceNumberListOfUser = new Map<String, List<User>>();
        list<GroupMember> groupMemberToBeDeleted =new list<GroupMember>();

        //map<Id,string> newAccountMap = new map<Id,string>();
        /*ASE: 06/04/2016
        map<string,string> newAccountMap = new map<string,string>();
        map<string,string> oldAccountMap = new map<string,string>();
        map<string,Id> groupMap = new map <string,Id>();
        //set<string>newAccountNames = new set<string>();
        
        //distributor
        //set<Id>newDistributorIds = new set<Id>();
        //set<Id>oldDistributorIds = new set<Id>();
        
        
        
        list<GroupMember> groupMemberToBeInserted = new list<GroupMember>();*/
        
        //Shamina M-case 1496 added condition to check for change in active flag
        for(integer i=0;i<newUsers.size();i++){
            if((newUsers[i].BodyShopID__c != oldUsers[i].BodyShopID__c) 
                || (newUsers[i].DistributorID__c != oldUsers[i].DistributorID__c)
                || (newUsers[i].isActive != oldUsers[i].isActive)){
                //bodyShop
                if(newUsers[i].BodyShopID__c!=null){
                    //newBodyShopIds.add(newUsers[i].BodyShopID__c);
                   //ASE: 06/04/2016: build map<refNumber, list<bodyshopUsers>>
                    if (mapReferenceNumberListOfUser.containsKey(newUsers[i].BodyShopID__c)){
                        mapReferenceNumberListOfUser.get(newUsers[i].BodyShopID__c).add(newUsers[i]);
                    }
                    else{
                        mapReferenceNumberListOfUser.put(newUsers[i].BodyShopID__c, new List<User>{newUsers[i]});
                    }

                }
                if(oldUsers[i].BodyShopID__c!=null){
                    oldBodyShopIds.add(oldUsers[i].BodyShopID__c);
                }
                
                //distributor
                if(newUsers[i].DistributorID__c!=null){
                    //newDistributorIds.add(newUsers[i].DistributorID__c);
                    //ASE: 06/04/2016: build map<refNumber, listDistributorUsers>>
                    if (mapReferenceNumberListOfUser.containsKey(newUsers[i].DistributorID__c)){
                        mapReferenceNumberListOfUser.get(newUsers[i].DistributorID__c).add(newUsers[i]);
                    }
                    else{
                        mapReferenceNumberListOfUser.put(newUsers[i].DistributorID__c, new List<User>{newUsers[i]});
                    }
                }
                if(oldUsers[i].DistributorID__c!=null){
                    oldDistributorIds.add(oldUsers[i].DistributorID__c);
                }
                
                users.add(newUsers[i]);
            }//end if      
            //WCH 19/11/2020 C-004032
            if(newUsers[i].IsPortalEnabled && newUsers[i].ContactId!=null){
                mapContactIdUser.put(newUsers[i].ContactId,newUsers[i]);
            }     
        }//end loop
        try{
            if(users.size()>0){
                // call method updateGroupMember
                AP28UserAccountGroupSharing.updateGroupMember(oldDistributorIds, oldBodyShopIds, users, mapReferenceNumberListOfUser);
            }
        }        
        catch(Exception ex){
            Utils_ManageLogs.createLogFromException('UserTriggerHandler', 'GroupMember', ex);
        }
        //WCH 19/11/2020 C-004032
        if(mapContactIdUser.size()>0){
            setContactAlphaScaleOrPrefikarCommunityUser(mapContactIdUser);
        }
        /*ASE: 06/04/2016///////////////////////////////
        //build map new account - to create group Member in group
        //build map old account - to delete group Member in group
        
        // new development --> ReferenceNumber__c added, replacing id
        for(Account a: [select ReferenceNumber__c,id,Name,RecordType.DeveloperName 
                from account where (ReferenceNumber__c IN: newBodyShopIds OR ReferenceNumber__c IN: oldBodyShopIds OR ReferenceNumber__c IN:newDistributorIds OR ReferenceNumber__c IN:oldDistributorIds)]){
            if(a.RecordType.DeveloperName == ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor || a.RecordType.DeveloperName == ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop){
                if(newBodyShopIds.contains(a.ReferenceNumber__c) || newDistributorIds.contains(a.ReferenceNumber__c) ){
                    newAccountMap.put(a.ReferenceNumber__c,a.Name);
                    //newAccountNames.add(a.Name);
                }//end if
                
                if(oldBodyShopIds.contains(a.ReferenceNumber__c) || oldDistributorIds.contains(a.ReferenceNumber__c)){
                    //Shamina M: case 1496
                    oldAccountMap.put(a.ReferenceNumber__c,a.Name);
                    //oldAccountMap.put(a.Name,a.ReferenceNumber__c);
                }//end if
            }//end if
        }//end loop
        
        //system.debug('////newAccountMap: '+newAccountMap);
        //system.debug('////oldAccountMap: '+oldAccountMap);
        
        //find group member for the old acc
        for(GroupMember gM: [select UserOrGroupId, Id, GroupId, Group.Name From GroupMember where UserOrGroupId IN:users]){
            //check old account name
            if(oldAccountMap.containsKey(gM.Group.Name)){
                groupMemberToBeDeleted.add(gM);
            }//end if
        }//end loop

        //Shamina M-case 1496
        //build map groupName and groupId
        for(Group g:[select Id,Name from Group where Name IN: newAccountMap.keySet()]){
            groupMap.put(g.Name,g.Id);
        }//end loop
        //system.debug('////groupMap: '+groupMap);
        
        //Shamina M-case 1496
        for(User u:users){
            if(u.isActive){
                if(u.BodyShopID__c!=null){
                    if(groupMap.containsKey(u.BodyShopID__c)){
                            groupMemberToBeInserted.add(
                                new GroupMember(GroupId = groupMap.get(u.BodyShopID__c),UserOrGroupId = u.Id)
                            );
                        }//end if
                    /*
                    if(newAccountMap.containsKey(u.BodyShopID__c)){
                        system.debug('////containskey1 ');
                        if(groupMap.containsKey(newAccountMap.get(u.BodyShopID__c))){
                            system.debug('////containskey2 ');
                            groupMemberToBeInserted.add(
                                new GroupMember(GroupId = groupMap.get(newAccountMap.get(u.BodyShopID__c)),UserOrGroupId = u.Id)
                            );
                        }//end if
                    }//end if
                    */
                /*ASE/////////////////////////////////////    
                }//end if
                else if(u.DistributorID__c!=null){
                    if(groupMap.containsKey(u.DistributorID__c)){
                        groupMemberToBeInserted.add(
                            new GroupMember(GroupId = groupMap.get(u.DistributorID__c),UserOrGroupId = u.Id)
                        );
                    }//end if
                    /*
                    if(newAccountMap.containsKey(u.DistributorID__c)){
                        if(groupMap.containsKey(newAccountMap.get(u.DistributorID__c))){
                            groupMemberToBeInserted.add(
                                new GroupMember(GroupId = groupMap.get(newAccountMap.get(u.DistributorID__c)),UserOrGroupId = u.Id)
                            );
                        }//end if
                    }//end if
                    */
                /*ASE/////////////////////////////////////  
                }//end elseif
            }//end if
        }//end loop
        /*ASE/////////////////////////////////////    
        //Shamina M- case 1496 - managed exception by creating logs
        try{
            if(groupMemberToBeDeleted.size()>0){
                delete groupMemberToBeDeleted;
            }

            if(groupMemberToBeInserted.size()>0){
                insert groupMemberToBeInserted;
            }
        } catch(Exception ex){
            Utils_ManageLogs.createLogFromException('UserTriggerHandler', 'GroupMember', ex);
        }
        
        /*
        system.debug('////groupMemberToBeDeleted: '+groupMemberToBeDeleted);
        if(groupMemberToBeDeleted.size()>0){
            delete groupMemberToBeDeleted;
        }
        
        system.debug('////groupMemberToBeInserted: '+groupMemberToBeInserted);
        if(groupMemberToBeInserted.size()>0){
            insert groupMemberToBeInserted;
        }
        */
    }//end method
    //WCH 19/11/2020 C-004032
    @future
    public static void setContactAlphaScaleOrPrefikarCommunityUser(List<Id> userIds){
        Map<Id,User> mapContactIdToUserObj1=new Map<Id,User>();
        for(User cu : [Select Id,ContactId from User where Id in:userIds]){
            mapContactIdToUserObj1.put(cu.ContactId,cu);
        }
        setContactAlphaScaleOrPrefikarCommunityUser(mapContactIdToUserObj1);
    }
    public static void setContactAlphaScaleOrPrefikarCommunityUser(Map<Id,User> mapContactIdToUserObj){

        List<Contact> lstContactToUpdate = new List<Contact>();
        List <Database.Saveresult> lstResultsContactUpdate;
        String err;
        for(Id currentContactId : mapContactIdToUserObj.keySet()){
            Contact currentContact= new Contact(Id=currentContactId,RelatedUser__c=mapContactIdToUserObj.get(currentContactId).Id);
            lstContactToUpdate.add(currentContact);
        }

        if(lstContactToUpdate.size()>0){
            integer index= 0;
            lstResultsContactUpdate=Database.update(lstContactToUpdate,false);
            for(Database.SaveResult lRUC : lstResultsContactUpdate){
                if(!lRUC.isSuccess()){
                    err+=(lstContactToUpdate[index].id +':'+lRUC.getErrors()[0].getMessage()+'\n');
                }
                index++;
            }
        }

   }
   //WCH 27/11/2020 C-003986
   @future
    public static void createManualSharingForCommunityUser(List<Id> userIds){
        createManualSharingForCommunityUserNow(userIds);
    }
   public static void createManualSharingForCommunityUserNow(List<Id> userIds){
        List<UserShare> userSharingToCreate = new List<UserShare>();
        Map<String,Id> mapGroupNameToId = new Map<String,Id>();
        List <Database.Saveresult> lstResultsUserShareInsert;
        String err;
        for(Group cg : [Select Id,developername from Group where developername like 'AlphaScale_%_LocalAdmin']){
            mapGroupNameToId.put(cg.developername,cg.Id);
        }
        for(User cu : [Select Id,Profile.UserLicense.Name,Country from User where Id in:userIds]){
      
            if((system.label.CustomerCommunityLicense).contains(cu.Profile.UserLicense.Name) && String.isNotBlank(cu.Country) && mapGroupNameToId.containsKey('AlphaScale_'+cu.Country+'_LocalAdmin')){
                userSharingToCreate.add(new UserShare(RowCause='Manual',UserId=cu.Id,UserAccessLevel='Edit',UserOrGroupId=mapGroupNameToId.get('AlphaScale_'+cu.Country+'_LocalAdmin')));
            }
        }
    
        if(userSharingToCreate.size()>0){
            integer index= 0;
            lstResultsUserShareInsert=Database.insert(userSharingToCreate,false);
            for(Database.SaveResult lRUC : lstResultsUserShareInsert){
                if(!lRUC.isSuccess()){
                    err+=(userSharingToCreate[index].id +':'+lRUC.getErrors()[0].getMessage()+'\n');
                }
                index++;
            }
        }

    }
}