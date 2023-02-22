/*************************************************************************************
Class Name - NOB_Batch_UpdateMissionsServiceContrat
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 19-07-2021
Function - Class to update missions envoyees on service contracts
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           19-07-2021   Initial version
* HMO           02-09-2021    
*************************************************************************************/
public class NOB_Batch_UpdateMissionsServiceContrat implements Schedulable, Database.Batchable<SObject>{
    //public final Date DATE_JAN = Date.newInstance(System.today().year(), 01, 01);
    private Boolean majHistorique = false;
    public static String scheduleDate = '0 0 12,15,19 ? * MON-FRI';
    public static Date testDate;

    public NOB_Batch_UpdateMissionsServiceContrat(Boolean parametreMajHistorique) {
        this.majHistorique = parametreMajHistorique;
    }
    
     //HMO -- 16-09-2021
    public static String scheduleClassInDB(){
        NOB_Batch_UpdateMissionsServiceContrat bat_mission = new NOB_Batch_UpdateMissionsServiceContrat(false);
        return System.schedule('9655 batch mission', scheduleDate, bat_mission);
    }

    
    public void execute (SchedulableContext sc){
        NOB_Batch_UpdateMissionsServiceContrat batchMissions= new NOB_Batch_UpdateMissionsServiceContrat(majHistorique);
        ID batchprocessid = Database.executeBatch(batchMissions);   
    }


    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## start method in NOB_Batch_UpdateMissionsServiceContrat');
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();
        String query = '';
        query = 'SELECT Id, NOB_MissionsEnvoyeeReparateurQ1__c, NOB_MissionsEnvoyeeReparateurQ1N1__c, NOB_MissionsEnvoyeeReparateurQ2__c, NOB_MissionsEnvoyeeReparateurQ2N1__c, NOB_MissionsEnvoyeeReparateurQ3__c, NOB_MissionsEnvoyeeReparateurQ3N1__c, NOB_MissionsEnvoyeeReparateurQ4__c, NOB_MissionsEnvoyeeReparateurQ4N1__c, NOB_MissionsEnvoyeeReparateurQ1Globale__c, NOB_MissionsEnvoyeeReparateurQ1N1Globale__c,NOB_MissionsEnvoyeeReparateurQ2Globale__c, NOB_MissionsEnvoyeeReparateurQ2N1Globale__c,NOB_MissionsEnvoyeeReparateurQ3Globale__c, NOB_MissionsEnvoyeeReparateurQ3N1Globale__c,NOB_MissionsEnvoyeeReparateurQ4Globale__c, NOB_MissionsEnvoyeeReparateurQ4N1Globale__c, AccountId, Status ';
        query += 'FROM ServiceContract ';
        query += 'WHERE Status = \'Active\' AND RecordTypeId = \''+recordTypeId+'\' AND Account.NOB_isPrefikar__c = TRUE';
        System.debug('££££ queryString '+ query);
        System.debug('## end method start in NOB_Batch_UpdateMissionsServiceContrat');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ServiceContract> scope){
        System.debug('## start method execute in NOB_Batch_UpdateMissionsServiceContrat');
        Set<Id> setReps = new Set<Id>();
        List<ServiceContract> lstScToUpdate = new List<ServiceContract>();

        for (ServiceContract sc : scope){
            setReps.add(sc.AccountId);
        }

        lstScToUpdate = getPlanningsCases(setReps, scope);
        System.debug('££££ in execute lstSCToUpdate '+ lstScToUpdate);
        System.debug('## end method execute in NOB_Batch_UpdateMissionsServiceContrat');
        if (lstSCtoUpdate.size() > 0){
            System.debug('££££ into update !!!!!');
            Database.SaveResult[] scList = Database.update(lstSCtoUpdate, false);
            System.debug('££££ updated !!!!!!!!!!!!!!!');
        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('## start of finish method in NOB_Batch_UpdateMissionsServiceContrat');
    }

    public List<ServiceContract> getPlanningsCases(Set<Id> setReps, List<ServiceContract> scope){
        System.debug('## start method getPlanningsCases execute in NOB_Batch_UpdateMissionsServiceContrat');
        Map<Id, Account> mapReps= new Map<Id, Account>();
        Map<Id, Case> mapCases = new Map<Id, Case>();
        List<Case> lstCases = new List<Case>();
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();

        Id planningNobRT = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId();

        if (setReps.size() > 0){
            for (Account acc : [SELECT Id, Name, (SELECT Id, Name, NOB_Status__c from Disponibilite__r where (NOB_Status__c =:NOB_AP00_Constants.PLANNING_STATUS_RESERVE OR NOB_Status__c =:NOB_AP00_Constants.PLANNING_STATUS_ANNULE OR NOB_Status__c =:NOB_AP00_Constants.PLANNING_STATUS_CONFIRME) AND (NOB_startDate__c >= THIS_QUARTER AND NOB_endDate__c <= THIS_QUARTER) AND RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS AND IsDelete__c = FALSE) FROM Account WHERE Id IN: setReps]){

                if (!mapReps.containsKey(acc.Id)){
                    mapReps.put(acc.Id, acc);
                }
            }

            //DR - DR PLUS -- HMO 02/09/2021
            for (Case ca : [SELECT Id, NOB_BodyShop__c, (SELECT Id FROM WorkOrders WHERE PFR_TECH_Planning_StartDate__c = null AND PFR_TECH_Planning_EndDate__c = null) FROM Case WHERE (NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DR OR NOB_Pricebook__r.NOB_Offer__c =:NOB_AP00_Constants.PRICEBOOK_OFFRE_DRPLUS) AND Status =:NOB_AP00_Constants.CASE_STATUT_FACTURATION AND LastModifiedDate = THIS_QUARTER AND NOB_BodyShop__c IN:setReps]){

                lstCases.add(ca);
            }
        }

        System.debug('££££ mapReps '+ mapReps);
        System.debug('## end method getPlanningsCases getPlanningsCases execute in NOB_Batch_UpdateMissionsServiceContrat');
        
        lstServiceContract  =  calculateMissions(mapReps, lstCases, scope);
        System.debug('£££ lstServiceContract '+ lstServiceContract);

        return lstServiceContract;
    }

    public List<ServiceContract> calculateMissions(Map<Id, Account> mapReps, List<Case> lstCases,List<ServiceContract> scope){
        System.debug('££££ start calculate mission method in NOB_Batch_UpdateMissionsServiceContrat');

        //HMO -- 26-09-2021 -- test var
        Integer runMonth;

        Integer numMission = 0;
        Integer numMissionDR = 0;

        List<ServiceContract> lstSCToUpdate = new List<ServiceContract>();

        for (ServiceContract sc: scope){

            if (mapReps.containsKey(sc.AccountId)){
                if (mapReps.get(sc.AccountId).Disponibilite__r != null && mapReps.get(sc.AccountId).Disponibilite__r.size() > 0){

                    numMission += mapReps.get(sc.AccountId).Disponibilite__r.size();
                    System.debug('££££ numDispo for sc '+ numMission);
                }
            }

            //HMO -- 02-09-2021
            if (lstCases != null) {
                    for (Case ca : lstCases){
                    System.debug('cases' + ca.WorkOrders);
                    if (ca.NOB_Bodyshop__c == sc.AccountId){
                        if (ca.WorkOrders != null && ca.WorkOrders.size() > 0){
                            System.debug('££££ case.workOrders '+ ca.WorkOrders.size());
                            numMissionDR += ca.WorkOrders.size();
                        }
                    }
                }
            }

            System.debug('££££ numMission '+ numMission);
            System.debug('££££ numMissionDR '+ numMissionDR);

            //HMO -- 26-09-2021
            runMonth = (!Test.isRunningTest()) ? System.today().month() : testDate.month();
           
            lstSCToUpdate.add(setMissionVal(runMonth, numMission, numMissionDR, sc));
            numMission = 0;
            numMissionDR = 0;
        }
        return lstSCToUpdate;
    }

    public ServiceContract setMissionVal(Integer month, Integer numMission, Integer numMissionDR, ServiceContract sc){
        System.debug('££££ start setMissionVal in NOB_Batch_UpdateMissionsServiceContrat');
        System.debug('££££ month '+ month);
        System.debug('££££ numMission '+ numMission);
        System.debug('££££ sc '+ sc);

        ServiceContract serviceCon = new ServiceContract(Id = sc.Id);

        if (majHistorique){
            ServiceContract Sclone = sc.clone(false, false, false, false);
            serviceCon.NOB_MissionsEnvoyeeReparateurQ1N1__c = sClone.NOB_MissionsEnvoyeeReparateurQ1__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ2N1__c = sClone.NOB_MissionsEnvoyeeReparateurQ2__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ3N1__c = sClone.NOB_MissionsEnvoyeeReparateurQ3__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ4N1__c = sClone.NOB_MissionsEnvoyeeReparateurQ4__c;

            //Historique -- HMO --02-09-2021
            serviceCon.NOB_MissionsEnvoyeeReparateurQ1N1Globale__c = sClone.NOB_MissionsEnvoyeeReparateurQ1Globale__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ2N1Globale__c = sClone.NOB_MissionsEnvoyeeReparateurQ2Globale__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ3N1Globale__c = sClone.NOB_MissionsEnvoyeeReparateurQ3Globale__c;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ4N1Globale__c = sClone.NOB_MissionsEnvoyeeReparateurQ4Globale__c;

            //serviceCon.NOB_Tech_HistoriqueMission__c = DATE_JAN;
        }

        if (month > 0 && month <= 3){
            serviceCon.NOB_MissionsEnvoyeeReparateurQ1__c = numMission;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ1Globale__c = (numMission + numMissionDR);
        }

        else if (month > 3 && month <= 6){
            serviceCon.NOB_MissionsEnvoyeeReparateurQ2__c = numMission;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ2Globale__c = (numMission + numMissionDR);
        }

        else if (month > 6 && month <= 9){
            serviceCon.NOB_MissionsEnvoyeeReparateurQ3__c = numMission;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ3Globale__c = (numMission + numMissionDR);
        }

        else {
            serviceCon.NOB_MissionsEnvoyeeReparateurQ4__c = numMission;
            serviceCon.NOB_MissionsEnvoyeeReparateurQ4Globale__c = (numMission + numMissionDR);
        }
        System.debug('££££ serviceCon '+ serviceCon);
        return serviceCon;
    }
}