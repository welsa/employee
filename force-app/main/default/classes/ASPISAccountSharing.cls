/*************************************************************************************
Class Name - ASPISAccountSharing
Version - 1.0
Created Date - 02 DEC 2015
Function - 
-- Applicable for Spain only
-- Accounts need to be shared with parents, and children of their parents.
-- parent hierarchy upto 3 levels have been considered.

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S      18/03/2016     Original version: case 1435. Create account sharing
* Ashwina S      29/03/2016     used by class ASPISBatchAccountSharing
*************************************************************************************/
public without sharing class ASPISAccountSharing {

    public static void accountSharingDefinition(List<Account> accountSharingList, map<Id, String> parentIdRefMap ){
        system.debug('######## START accountSharingDefinition:'+accountSharingList);
        map<Id, Account> childParentAccountMap = new map<Id, Account>();    
        map<Id, list<Account>> parentHasChildrenMap = new map<Id, list<Account>> ();
        map<String, set<Id>> accToShareWithAccMap = new map<String, set<Id>>(); 
        map<Id, String> accRefMap = new map<Id, String>(); 
        set<String> referenceSet =  new set<String>(); 
        map<String, Id> groupMap = new map<String, Id>();
        list<AccountShare> accountShareList =  new list<AccountShare>();

        // set<Parents to be shared with account>
        set <Id> allParentIdSet= new set<Id>(); 

        // map<account, toBeSharedWithParentAccounts>
        map<Id, set<Id>> childParentIdMap = new map<Id, set<Id>>(); 
        // set<parents and children Id>
        set<Id> parentChildrenSet = new set<Id>();

        // map<account, toBeSharedWithParentChildrenAccounts>
        map<Id, set<Id>> childParentChildrenMap = new map<Id, set<Id>>(); 


        // split TECHParentAccount__c to know with which accounts to share and build set
        for(Account acc: accountSharingList){
            Id[] parentIdList = acc.TECHParentAccount__c.split(';');
            Set<Id> parentIdSet = new Set<Id>(parentIdList);

            childParentIdMap.put(acc.id, parentIdSet);

            // set containing all accounts that need to b shared
            allParentIdSet.addAll(parentIdSet); 
        }
        //system.debug('###### childParentIdMap:'+childParentIdMap);
        
        // retreive all children related to each parent from and save in map parentHasChildrenMap
        for(Account childAcc: [select Id
                                     ,ReferenceNumber__c
                                     ,ParentId
                               from Account 
                               where ParentId IN :allParentIdSet  
                               order by ParentId]){
            // build map of parentHasChildrenMap
            if(!parentHasChildrenMap.containsKey(childAcc.ParentId)){
                parentHasChildrenMap.put(childAcc.ParentId, new list<Account>{childAcc});
            }
            else{
                parentHasChildrenMap.get(childAcc.ParentId).add(childAcc);
            }
        }
        //system.debug('###### parentHasChildrenMap:'+parentHasChildrenMap);

        // loop in list of accounts again to determine which account needs to be shared with which parent and children account
        for(Account sharedAcc: accountSharingList){
            if(childParentIdMap.containsKey(sharedAcc.Id)){
                // loop in childParentIdMap to get set of parents associated to this account
                for(Id parentId: childParentIdMap.get(sharedAcc.Id)){
                    parentChildrenSet.add(parentId);
                    if(parentHasChildrenMap.containsKey(parentId)){
                        for(Account childAcc: parentHasChildrenMap.get(parentId)){
                            parentChildrenSet.add(childAcc.id);
                        }
                    }               
                }
            }
            childParentChildrenMap.put(sharedAcc.id, parentChildrenSet);
        }

        //Get group Name for sharing
        for(Group g:[select Id,Name from Group where Name IN: parentIdRefMap.values()]){
            groupMap.put(g.Name,g.Id);
        }
        //system.debug('######### groupMap:'+groupMap);

        // share the account
        for(Id accId: parentIdRefMap.keySet()){
            Id groupRefId = groupMap.get(parentIdRefMap.get(accId));
            for(Id sharedAccId: childParentChildrenMap.get(accId)){
                AccountShare accShare = new AccountShare (accountid = sharedAccId, UserOrGroupId=groupRefId,AccountAccessLevel = 'Edit',OpportunityAccessLevel = 'None',CaseAccessLevel = 'None');
                accountShareList.add(accShare);     
            }
        }

        //system.debug('######### accountShareList:'+accountShareList);
        if(accountShareList.size()>0){
            insert accountShareList;
        }
        system.debug('######## END accountSharingDefinition:'+accountSharingList);
        
    }
}