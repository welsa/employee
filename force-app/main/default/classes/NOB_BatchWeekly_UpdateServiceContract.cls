/*************************************************************************************
Class Name - NOB_BatchWeekly_UpdateServiceContract
Version - 1.0
Created Date - 08-01-2021
Function - Class to set fields to 0 on a weekly basis
#Ticket  - RSIW : 7183

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           08-01-2021   Initial version
*************************************************************************************/

public class NOB_BatchWeekly_UpdateServiceContract implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    public static String scheduleDate = '0 0 5 ? * MON';
    public NOB_BatchWeekly_UpdateServiceContract() {

    }

    public static String scheduleClassInDB(){
        NOB_BatchWeekly_UpdateServiceContract batchSC = new NOB_BatchWeekly_UpdateServiceContract();
        return System.schedule('Prefikar serviceContract weekly batch', scheduleDate, batchSC);
    }

    public void execute (SchedulableContext sc){
        NOB_BatchWeekly_UpdateServiceContract batchSC = new NOB_BatchWeekly_UpdateServiceContract();
        ID batchprocessid = Database.executeBatch(batchSC);   
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## Start NOB_BatchWeekly_UpdateServiceContract.start');
        String query = '';
        query = 'SELECT NOB_Dispo_entrees_semaine__c, NOB_TauxEngagement__c, Account.NOB_TauxEngagement__c, NOB_TauxEngagementPourcent__c ';
        query += 'FROM ServiceContract ';
        query += 'WHERE Status = \'Active\' ';
        query += 'AND Account.NOB_isPrefikar__c = TRUE ';
        System.debug('£££ query '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ServiceContract> scope){
        System.debug('## Start NOB_BatchWeekly_UpdateServiceContract.execute');
        Integer countReserveHebdo = 0, countDispoHebdo = 0;
        Double tauxEngagementPourcent = 0.0;
        List<ServiceContract> lstServiceContractToUpdate = new List<ServiceContract>();
        Set<Id> setAcc = new Set<Id>();
        map<Id,Account> mapAccountToUpdate = new map<Id,Account>();
   
        //HMO-- 14-01-2021
        List<Id> lstReparateurs = new List<Id>();
        for (ServiceContract serviceContract : scope){
            lstReparateurs.add(serviceContract.AccountId);
        }

        Map<Id, Account>mapAccWeek = new Map<Id, Account>([Select Id, Name, (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                            from Disponibilite__r
                                                            where NOB_StartDate__c = THIS_WEEK
                                                            and IsDelete__c = FALSE
                                                            and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                            from Account
                                                            where Id in: lstReparateurs]);
                                            
        for (ServiceContract serviceContract : scope){
            countDispoHebdo = 0;
            countReserveHebdo = 0;
            tauxEngagementPourcent = 0;
            if(mapAccweek.containsKey(serviceContract.AccountId)){                
                if(mapAccweek.get(serviceContract.AccountId).Disponibilite__r.size() > 0){
                    
                    countDispoHebdo = mapAccweek.get(serviceContract.AccountId).Disponibilite__r.size();
                    
                    for(NOB_Planning__c dispo : mapAccweek.get(serviceContract.AccountId).Disponibilite__r){
                        if(dispo.NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE){
                            countReserveHebdo++; 
                        }
                    }
                }
                if (countReserveHebdo > 0 && countDispoHebdo > 0){
                    tauxEngagementPourcent = ((double)countReserveHebdo/(double)countDispoHebdo)*100;
                }
            
                lstServiceContractToUpdate.add(new ServiceContract(Id = serviceContract.Id,
                                                                   NOB_TauxEngagement__c = countReserveHebdo, 
                                                                   NOB_TauxEngagementPourcent__c = tauxEngagementPourcent,
                                                                   NOB_Dispo_entrees_semaine__c = countDispoHebdo));
                
                if(!mapAccountToUpdate.containsKey(serviceContract.AccountId)){
                	mapAccountToUpdate.put(serviceContract.AccountId,(new Account(Id = serviceContract.AccountId ,NOB_TauxEngagement__c = tauxEngagementPourcent)));
                }
            }
        }
		System.debug('## Start lstServiceContractToUpdate' + lstServiceContractToUpdate);
		System.debug('## Start mapAccountToUpdate' + mapAccountToUpdate);
        if (lstServiceContractToUpdate.size() > 0){
            Database.SaveResult[] scList = Database.update(lstServiceContractToUpdate, false);
        }
        if (mapAccountToUpdate.size() > 0){
            Database.SaveResult[] accList = Database.update(mapAccountToUpdate.values(), false);
        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('## Start NOB_BatchWeekly_UpdateServiceContract.finish');
    }
}