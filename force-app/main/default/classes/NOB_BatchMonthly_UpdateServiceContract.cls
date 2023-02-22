/*************************************************************************************
Class Name - NOB_BatchMonthly_UpdateServiceContract
Version - 1.0
Created Date - 11-01-2021
Function - Class to set fields to 0 on a Monthly basis in service contract object
#Ticket  - RSIW : 7183

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           11-01-2021   Initial version
*************************************************************************************/
public class NOB_BatchMonthly_UpdateServiceContract implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
    //Schedules for every 1st january
    public static String scheduleDate = '0 0 0 1 1 ? *';
    public NOB_BatchMonthly_UpdateServiceContract() {

    }

    public void execute(SchedulableContext SC){
        NOB_BatchMonthly_UpdateServiceContract batchSC = new NOB_BatchMonthly_UpdateServiceContract();
        ID batchprocessid = Database.executeBatch(batchSC);   
    }

    public static String scheduleClassInDB(){
        NOB_BatchMonthly_UpdateServiceContract batchSC = new NOB_BatchMonthly_UpdateServiceContract();
        return System.schedule('Prefikar serviceContract monthly batch', scheduleDate, batchSC);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## Start NOB_BatchMonthly_UpdateServiceContract.start');
        String query = '';
        query = 'SELECT NOB_Dispo_entrees_annee__c, NOB_NombreRendezvousAnnuel__c, AccountId ';
        query += 'FROM ServiceContract ';
        query += 'WHERE Status = \'Active\'';
        query += 'AND Account.NOB_isPrefikar__c = TRUE ';
        System.debug('£££ query '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ServiceContract> scope){
        System.debug('## Start NOB_BatchMonthly_UpdateServiceContract.execute');
        Integer countReserveAnnuel = 0, countDispoAnnuel = 0;
        List<ServiceContract> lstServiceContractToUpdate = new List<ServiceContract>();
       //HMO-- 14-01-2021
       List<Id> lstReparateurs = new List<Id>();
       for (ServiceContract serviceContract : scope){
           lstReparateurs.add(serviceContract.AccountId);
       }

       Map<Id, Account>mapAccYear = new Map<Id, Account>([Select Id, Name, (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                           from Disponibilite__r
                                                           where NOB_StartDate__c = THIS_YEAR
                                                           and IsDelete__c = FALSE
                                                           and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                           from Account
                                                           where Id in: lstReparateurs]);
                                           
       for (ServiceContract serviceContract : scope){
            countDispoAnnuel = 0;
            countReserveAnnuel = 0;
           if(mapAccYear.containsKey(serviceContract.AccountId)){  
               if (mapAccYear.get(serviceContract.AccountId).Disponibilite__r.size() > 0){
                countDispoAnnuel = mapAccYear.get(serviceContract.AccountId).Disponibilite__r.size();

               for(NOB_Planning__c dispo : mapAccYear.get(serviceContract.AccountId).Disponibilite__r){
                   if(dispo.NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE){
                    countReserveAnnuel++;
                   }
               }
             }
               
             lstServiceContractToUpdate.add(new ServiceContract(Id = serviceContract.Id,
                                                                  NOB_NombreRendezvousAnnuel__c = countReserveAnnuel,
                                                                  NOB_Dispo_entrees_annee__c = countDispoAnnuel));
           }
       }
		System.debug('## Start lstServiceContractToUpdate' + lstServiceContractToUpdate);
       if (lstServiceContractToUpdate.size() > 0){
           Database.SaveResult[] scList = Database.update(lstServiceContractToUpdate, false);
       }
    }

    public void finish(Database.BatchableContext BC){
          System.debug('## Start NOB_BatchMonthly_UpdateServiceContract.finish');
    }
}