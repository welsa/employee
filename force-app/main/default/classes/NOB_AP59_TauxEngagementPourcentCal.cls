/*************************************************************************************
Class Name - NOB_AP59_TauxEngagementPourcentCal
Version - 1.0
Created Date - 08/01/2021
Function - Class to calculate NOB_TauxEngagementPourcent__c on ServiceContract
Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA           08/01/2021  Initial version
* HMO           02/08/2021  Mise ? jour des engagements Pr?fikar / R?parateur
*************************************************************************************/
public without sharing class NOB_AP59_TauxEngagementPourcentCal {
     public static void updateMissionReserve(set<Id> setReparateurId){
        system.debug('## Start NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve');
        
        list<ServiceContract> lstContractToUpdate = new list<ServiceContract>();
        list<Account> lstReparateurToUpdate = new list<Account>();
        Integer countReserveAnnuel, countReserveHebdo, missionHedbo, missionAnnuel = 0;
        Double tauxEngagementPourcent = 0;

        List<Case> lstCasesYear = new List<Case>();
        List<Case> lstCasesWeek = new List<Case>();
        

        //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 02/08/2021 --add case query
        /*Map<String,Object> mapCaseWeek = new Map<String,Object>();
        Map<String,Object> mapCaseYear = new Map<String,Object>();
       
        List<NOB_Planning__c> lstDispoAnnuel = new List<NOB_Planning__c>();

        if (mapQueryAccs != null){
            for (Id accId : mapQueryAccs.keySet()){
                if (mapQueryAccs.containsKey(accId)){
                    if (mapQueryAccs.get(accId).Disponibilite__r.size() > 0){
                        for (NOB_Planning__c planning : mapQueryAccs.get(accId).Disponibilite__r){
                            if (checkThisWeek(planning.NOB_StartDate__c)){
                                lstDispoHebdo.add(planning);
                            }
                            lstDispoAnnuel.add(planning);
                        }
                    }
                    
                    acc.Disponibilite__r = lstDispoHebdo;
                    mapAccountWeek.put(accId, acc);
                }
            }
        }*/

        Map<Id,Account> mapAccountWeek= new Map<Id,Account> ([Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_TauxEngagement__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE ORDER BY CreatedDate DESC Limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_WEEK
                                                               and (NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_RESERVE OR NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_ANNULE OR NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_CONFIRME)
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId]);
      
        
        Map<Id,Account> mapAccountYear= new Map<Id,Account> ([ Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_Dispo_entrees_annee__c, NOB_NombreMissionHebdo__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE
                                                               ORDER BY CreatedDate DESC Limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_YEAR
                                                               and (NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_RESERVE OR NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_ANNULE OR NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_CONFIRME)
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId
                                                              OR NOB_BodyShop__c IN :setReparateurId
                                                              ]);

     
        for (Case ca : [SELECT Id, NOB_BodyShop__c, (SELECT Id FROM WorkOrders WHERE PFR_TECH_Planning_StartDate__c = null AND PFR_TECH_Planning_EndDate__c = null) FROM Case WHERE (NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DRPLUS OR NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DR) AND Status =:NOB_AP00_Constants.CASE_STATUT_FACTURATION  AND LastModifiedDate = THIS_WEEK AND NOB_BodyShop__c IN: setReparateurId]){
            //mapCaseWeek.put(ca.NOB_Bodyshop__c, ca);
            lstCasesYear.add(ca);
        }

  
        for (Case ca : [SELECT Id, NOB_BodyShop__c, (SELECT Id FROM WorkOrders WHERE PFR_TECH_Planning_StartDate__c = null AND PFR_TECH_Planning_EndDate__c = null) FROM Case WHERE (NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DRPLUS OR NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DR) AND Status =:NOB_AP00_Constants.CASE_STATUT_FACTURATION AND LastModifiedDate = THIS_YEAR AND NOB_BodyShop__c IN: setReparateurId]){
            //mapCaseYear.put(ca.NOB_BodyShop__c, ca);
            lstCasesWeek.add(ca);
        }

        for(Id accId : mapAccountYear.KeySet()){
            countReserveAnnuel = 0;
            countReserveHebdo = 0;
            tauxEngagementPourcent = 0.0;


            //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 02/08/2021 --add 2 variables mission
            missionHedbo = 0;
            missionAnnuel = 0;

            if(mapAccountYear.get(accId).Disponibilite__r.size() > 0 && mapAccountYear.get(accId).ServiceContracts.size() > 0){
                countReserveAnnuel = mapAccountYear.get(accId).Disponibilite__r.size();
            }
            if(mapAccountWeek.get(accId).Disponibilite__r.size() > 0 && mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                countReserveHebdo = mapAccountWeek.get(accId).Disponibilite__r.size();
            }

            //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 02/08/2021
            if (lstCasesYear != null) {
                    for (Case ca : lstCasesYear){
                    System.debug('cases' + ca.WorkOrders);
                    if (ca.NOB_Bodyshop__c == accId){
                        if (ca.WorkOrders != null && ca.WorkOrders.size() > 0){
       
                            missionAnnuel += ca.WorkOrders.size();
                        }
                    }
                }
            }

             //HMO -- 02-09-2021
            if (lstCasesWeek != null) {
                    for (Case ca : lstCasesWeek){
                    System.debug('cases' + ca.WorkOrders);
                    if (ca.NOB_Bodyshop__c == accId){
                        if (ca.WorkOrders != null && ca.WorkOrders.size() > 0){
                            
                            missionHedbo += ca.WorkOrders.size();
                        }
                    }
                }
            }

            tauxEngagementPourcent = 0;

            //HMO -- 07-09-2021 -- RSIW 9655
            if(mapAccountYear.get(accId).ServiceContracts.size() >0){
                if(mapAccountYear.get(accId).ServiceContracts[0].NOB_NombreMissionHebdo__c != null && mapAccountYear.get(accId).ServiceContracts[0].NOB_NombreMissionHebdo__c != 0) {
                    tauxEngagementPourcent = ((countReserveHebdo)/ mapAccountYear.get(accId).ServiceContracts[0].NOB_NombreMissionHebdo__c) * 100;
                }
            }

            if(mapAccountYear.get(accId).ServiceContracts.size() > 0 || mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                    lstContractToUpdate.add(new ServiceContract(Id = mapAccountYear.get(accId).ServiceContracts[0].Id,
                                                                NOB_TauxEngagement__c = countReserveHebdo,
                                                                NOB_NombreRendezvousAnnuel__c = countReserveAnnuel,
                                                                NOB_TauxEngagementPourcent__c = tauxEngagementPourcent,
                                                                NOB_MissionsAffecteesAnnuel__c = (missionAnnuel + countReserveAnnuel),
                                                                NOB_MissionsAffecteesHebdomadaire__c = (missionHedbo + countReserveHebdo)
                                                            ));
                
                  lstReparateurToUpdate.add(new Account(Id = accId,
                                                      NOB_TauxEngagement__c = tauxEngagementPourcent));
             }
                
        }
        
        system.debug('## lstContractToUpdate '+ lstContractToUpdate);
        if(lstContractToUpdate.size() > 0){
            
            //HMO -- 30-09-2021 --RSIW 9655
            NOB_PrefikarWithoutSharingExceptions.updateServContracts(lstContractToUpdate);
        }
    if(lstReparateurToUpdate.size() > 0){
            update lstReparateurToUpdate;
        }
        system.debug('## END NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve');
    }
}