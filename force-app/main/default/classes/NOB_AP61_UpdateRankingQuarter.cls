/*************************************************************************************
Class Name - NOB_AP61_UpdateRankingQuarter
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 26-07-2021
Function - Class to update ranking fields on Accounts
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           26-07-2021   Initial version
*************************************************************************************/
public without sharing class NOB_AP61_UpdateRankingQuarter {

    //HMO -- 25-09-2021
    public static Date testDate;
    public static final Date DATE_TODAY = System.today();
    public NOB_AP61_UpdateRankingQuarter() {

    }

    public static void getServiceContracts(Set<Id> setAccIds, String context){
        System.debug('££££ getServiceContracts method in NOB_AP61_UpdateRankingQuarter');
        System.debug('££££ getServiceContracts method - setAccIds '+ setAccIds);

        Map<Id, Account> mapAccsServiceContracts = new Map<Id, Account>();
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();

        if (setAccIds.size() > 0){
            for (Account acc : [SELECT Id, NOB_Ranking__c, NOB_TrainingDate__c, NOB_isPrefikar__c, (SELECT Id, Status, NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_RankingRep_Q4__c, NOB_TechToProcess__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_RankingRep_Q4N1__c, NOB_ContexteEngagement__c FROM ServiceContracts WHERE Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE AND RecordTypeId =: recordTypeId) FROM Account WHERE Id IN: setAccIds AND NOB_isPrefikar__c = TRUE])
            {
                mapAccsServiceContracts.put(acc.Id, acc);
            }
        }
        System.debug('££££ mapAccsServiceContracts '+ mapAccsServiceContracts);
        setRankingVal(mapAccsServiceContracts, context, null, null);
    }

    public static void setRankingVal(Map<Id, Account> mapServiceContract, String context, Boolean majHistorique, Boolean clearRanking){
        System.debug('££££ START setRankingVal method in NOB_AP61_UpdateRankingQuarter');
        System.debug('££££ mapServiceContract '+ mapServiceContract);

        List<ServiceContract> lstSC = new List<ServiceContract>();
        if (mapServiceContract != null && mapServiceContract.size() > 0){
            for (Id accId : mapServiceContract.keySet()){
                if (mapServiceContract.containsKey(accId)){
                    String ranking = mapServiceContract.get(accId).NOB_Ranking__c;
                    for (ServiceContract sc : mapServiceContract.get(accId).ServiceContracts){
                        lstSC.add(scUtility(DATE_TODAY, sc, ranking, context, majHistorique, clearRanking));
                    }
                }
            }
            
            if (lstSC.size() > 0){
                System.debug('££££ lstSC'+ lstSC);
                Savepoint spoint = Database.setSavepoint();
                try{
                    System.debug('££££ setRankingVal into update !!');
                    update lstSC;
                }catch(DmlException e){
                    System.debug('Error exception : '+ e.getMessage());
                    Database.rollback(spoint);
                }
            }
        }
    }
  

    public static ServiceContract scUtility(Date dateToday, ServiceContract sc, String ranking, String context, Boolean majHistorique, Boolean clearRanking){
        System.debug('££££ start of scUtility in NOB_AP61_UpdateRankingQuarter');
        System.debug('££££ dateToday '+ dateToday);
        System.debug('££££ sc '+ sc);
        System.debug('££££ ranking '+ ranking);
        

       
        //Integer month = dateToday.month();

        //HMO -- 25-09-2021 -- test classes
        Integer month = (!Test.isRunningTest()) ? dateToday.month() : testDate.month();
        System.debug('££££ month '+ month);

        ServiceContract serviceCon = new ServiceContract();
 
        //Batch to update historique very quarter
        if (!System.Trigger.isExecuting){

            //HMO -- 17-09-2021
            ServiceContract contractClone = sc.clone(false, false, false, false);
            if (clearRanking){

                sc.NOB_RankingRep_Q1__c = null;
                sc.NOB_RankingRep_Q2__c = null;
                sc.NOB_RankingRep_Q3__c = null;
            }

            if (majHistorique){
        
                sc.NOB_RankingRep_Q1N1__c = contractClone.NOB_RankingRep_Q1__c;
                sc.NOB_RankingRep_Q2N1__c = contractClone.NOB_RankingRep_Q2__c;
                sc.NOB_RankingRep_Q3N1__c = contractClone.NOB_RankingRep_Q3__c;
            }
            
            serviceCon = assignFields(sc, ranking, month, true, context);

            System.debug('££££ in batch '+ serviceCon);
        }


        //Trigger
        else if (System.Trigger.isExecuting){

            if (sc.NOB_TechToProcess__c == false){
                sc.NOB_TechToProcess__c = true;
            }
            serviceCon = assignFields(sc, ranking, month, false, context);

        }
        System.debug('££££ serviceCon '+ serviceCon);

        return serviceCon;
    }


    public static ServiceContract assignFields(ServiceContract serviceCon, String ranking, Integer month, Boolean isBatch, String context){

        Boolean isTrigger = System.Trigger.isExecuting;


        if (month > 0 && month <= 3){
            if (isTrigger || (isBatch && serviceCon.NOB_RankingRep_Q4N1__c == null)){
                serviceCon.NOB_RankingRep_Q4N1__c = ranking;
                System.debug('££££ IN Q4N-1');
            }
        }

        else if (month > 3 && month <= 6){
            if (isTrigger || (isBatch && serviceCon.NOB_RankingRep_Q1__c == null)){
                serviceCon.NOB_RankingRep_Q1__c = ranking;
                System.debug('££££ IN Q1');
            }
        }

        else if (month > 6 && month <= 9){
            if (isTrigger || (isBatch && serviceCon.NOB_RankingRep_Q2__c == null)){
                serviceCon.NOB_RankingRep_Q2__c = ranking;
                System.debug('££££ IN Q2');
            }
        }

        else{
            if (isTrigger || (isBatch && serviceCon.NOB_RankingRep_Q3__c == null)){ 
                serviceCon.NOB_RankingRep_Q3__c = ranking;
                System.debug('££££ IN Q3');
            }
        }

        //HMO -- 05-09-2021
        serviceCon.NOB_ContexteEngagement__c = context;
        return serviceCon;
    }

}