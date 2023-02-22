/*************************************************************************************
Class Name - NOB_AP60_DispoEntreesCal
Version - 1.0
Created Date - 08/01/2021
Function - Class to calculate NOB_Dispo_entrees_annee__c and NOB_Dispo_entrees_semaine__c on ServiceContract
Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA           08/01/2021  Initial version
* HMO           30-09-2021  RSIW 9655 --  ORDER BY CreatedDate DESC Limit 1
*************************************************************************************/
public with sharing class NOB_AP60_DispoEntreesCal {
    public static void updateDispo(set<Id> setReparateurId){
        system.debug('## Start NOB_AP60_DispoEntreesCal.updateDispo');
        
        list<ServiceContract> lstContractToUpdate = new list<ServiceContract>();
        Integer countDispoHebdo,countDispoAnnuel = 0;
        
        Map<Id,Account> mapAccountWeek= new Map<Id,Account> ([ Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_TauxEngagement__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE
                                                               ORDER BY CreatedDate DESC Limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_WEEK
                                                               and IsDelete__c = FALSE
                                                               and NOB_Status__c != :NOB_AP00_Constants.PLANNING_STATUS_ANNULE
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId]);
        
        Map<Id,Account> mapAccountYear= new Map<Id,Account> ([ Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_Dispo_entrees_annee__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE
                                                               ORDER BY CreatedDate DESC Limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_YEAR
                                                               and IsDelete__c = FALSE
                                                               and NOB_Status__c != :NOB_AP00_Constants.PLANNING_STATUS_ANNULE
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId]);
        
        for(Id accId : mapAccountYear.KeySet()){
            countDispoHebdo = 0;
            countDispoAnnuel = 0; 
            if(mapAccountYear.get(accId).Disponibilite__r.size() > 0 && mapAccountYear.get(accId).ServiceContracts.size() > 0){
                countDispoAnnuel = mapAccountYear.get(accId).Disponibilite__r.size();
            }
            if(mapAccountWeek.get(accId).Disponibilite__r.size() > 0 && mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                countDispoHebdo = mapAccountWeek.get(accId).Disponibilite__r.size();
            }
            if(mapAccountYear.get(accId).ServiceContracts.size() > 0 || mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                lstContractToUpdate.add(new ServiceContract(Id = mapAccountYear.get(accId).ServiceContracts[0].Id,
                                                            NOB_Dispo_entrees_annee__c = countDispoAnnuel,
                                                            NOB_Dispo_entrees_semaine__c = countDispoHebdo));
            }
        }
        
        system.debug('## lstContractToUpdate '+ lstContractToUpdate);
        if(lstContractToUpdate.size() > 0){
            
            //HMO -- 30-09-2021 --RSIW 9655
            NOB_PrefikarWithoutSharingExceptions.updateServContracts(lstContractToUpdate);
        }
        
        system.debug('## END NOB_AP60_DispoEntreesCal.updateDispo');
        
    }
}