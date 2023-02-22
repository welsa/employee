/*************************************************************************************
Class Name - NOB_Batch_UpdateRankingServiceContract
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 29-07-2021
Function - Batch to update Ranking fields on service contracts
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           29/07/2021   Initial version
*************************************************************************************/
public class NOB_Batch_UpdateRankingServiceContracts implements Schedulable, Database.Batchable<SObject>{

    private Boolean majHistorique = false;
    //HMO -- 17-09-2021 -- commented jan
    private Boolean clearRanking = false;
    public NOB_Batch_UpdateRankingServiceContracts(Boolean parametreMajHistorique, Boolean clearRanking) {
        this.majHistorique = parametreMajHistorique;
        this.clearRanking = clearRanking;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();
        String query = '';

        query = 'SELECT Id, Name, NOB_Ranking__c, NOB_TrainingDate__c, (SELECT Id, Status, NOB_RankingRep_Q1__c, NOB_RankingRep_Q2__c, NOB_RankingRep_Q3__c, NOB_RankingRep_Q4__c, NOB_TechToProcess__c, NOB_RankingRep_Q1N1__c, NOB_RankingRep_Q2N1__c, NOB_RankingRep_Q3N1__c, NOB_RankingRep_Q4N1__c FROM ServiceContracts WHERE Status = \''+NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE+'\' AND RecordTypeId = \''+recordTypeId+'\')';

        query += ' FROM Account WHERE NOB_isPrefikar__c = TRUE';

        System.debug('££££ queryString '+ query);
        System.debug('## end method start in NOB_Batch_UpdateMissionsServiceContrat');
        return Database.getQueryLocator(query);
    }

    public void execute (SchedulableContext sc){
        NOB_Batch_UpdateRankingServiceContracts batchRanking = new NOB_Batch_UpdateRankingServiceContracts(majHistorique, clearRanking);
        ID batchprocessid = Database.executeBatch(batchRanking);   
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('## start of execute method NOB_Batch_UpdateRankingServiceContracts');
        System.debug('££££ scope' + scope);
        Map<Id, Account> mapAccsServiceContracts = new Map<Id, Account>();

        for (Account acc : scope){
            mapAccsServiceContracts.put(acc.Id, acc);
        }

        System.debug('££££ mapAccsServiceContracts' + mapAccsServiceContracts);

        if (mapAccsServiceContracts != null){
           NOB_AP61_UpdateRankingQuarter.setRankingVal(mapAccsServiceContracts, null, majHistorique, clearRanking);
        }

        System.debug('££££ updated ');
        System.debug('## end of execute method NOB_Batch_UpdateRankingServiceContracts');
    }

    public void finish(Database.BatchableContext BC){
        System.debug('## finish method NOB_Batch_UpdateRankingServiceContracts');
    }
}