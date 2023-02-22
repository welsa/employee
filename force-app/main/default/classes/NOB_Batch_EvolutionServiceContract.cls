/*************************************************************************************
Class Name - NOB_Batch_EvolutionServiceContract
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 13-12-2021
Function - Batch to update accounts
#Ticket  - RSIW : 5686

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           13-12-2021    Initial version
* HMO           30-01-2022    RSIW : 9416
*************************************************************************************/

public with sharing class NOB_Batch_EvolutionServiceContract  implements Schedulable, Database.Batchable<sObject>{

    //Set<Id> setAcctsIdGlo;
    public NOB_Batch_EvolutionServiceContract(/*Set<Id> setAcctsId*/) {
        /*system.debug('@@ setAcctsId: '+setAcctsId);
        setAcctsIdGlo = new set<Id>();
        if (setAcctsId != null){
            for (Id id: setAcctsId){
                setAcctsIdGlo.add(id);
            }   
        }*/
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();

        string query = '';
        query += 'SELECT Id, Name, NOB_techCContractType__c,NOB_NetworkType__c,NOB_SkillSet__c, NOB_SubscriptionStartDate__c, NOB_SubscriptionEndDate__c, NOB_TrainingDate__c, (SELECT Id, Status, NOB_ContractsType__c, NOB_DateDeFormation__c, startDate, endDate, NOB_endDate__c, NOB_Tech_TacitePremium__c, NOB_ContractTacitRenewal__c FROM ServiceContracts WHERE RecordTypeId = \''+recordTypeId+'\' ORDER BY CreatedDate ASC)';
        query += 'FROM Account WHERE NOB_isPrefikar__c = TRUE ';

        /*if (setAcctsIdGlo.size() > 0){
            query += 'AND Id IN: setAcctsIdGlo';

        }*/

        system.debug('£ query : '+ query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        if (!scope.isEmpty()){
            Map<Id, Account> mapAccsToUpdate = new Map<Id, Account>();
            Set<Id> setReparmutsAcc = new Set<Id>();
            Map<Id, ServiceContract> mapScToInactivate = new Map<Id, ServiceContract>();

            //RSIW 9416 - HMO - 30-01-2022
            Map<Id, ServiceContract> mapScTacite;
            Map<Id, ServiceContract> mapScDesactivate;
            
            for (Account acc : scope){

                if (!acc.serviceContracts.isEmpty()){

                    Map<String,ServiceContract> mapCheckReconduction = checkReconduction(acc.serviceContracts);
                    Boolean hasActive = mapCheckReconduction != null && checkMapNotNull(mapCheckReconduction, 'contractActive');

                    //RSIW 9416
                    Boolean isTacite = mapCheckReconduction != null && checkMapNotNull(mapCheckReconduction, 'scTacite');
				
                    //RSIW 9416 - HMO -30-01-2022
                    if (isTacite){
                        
                        
                        mapScTacite = new Map<Id, ServiceContract>();
                        ServiceContract taciteSc = setExpiryDate(mapCheckReconduction.get('scTacite'));
                       

                        mapScTacite.put(taciteSc.Id, taciteSc);
                    }
    
                    if (hasActive && (acc.NOB_techCContractType__c == mapCheckReconduction.get('contractActive').NOB_ContractsType__c || acc.NOB_NetworkType__c == null) && acc.serviceContracts.size() == 1){
                        Account acctx = assignFields(mapCheckReconduction.get('contractActive'), acc, true);
                        mapAccsToUpdate.put(acctx.Id, acctx);
                    }

                    else{
            
                        //proxi -privilege
                        if (hasActive){
                            if(checkStatusChange(mapCheckReconduction.get('contractActive'), acc)){
                                
                                Account acct = assignFields(mapCheckReconduction.get('contractActive'), acc, false);
                                mapAccsToUpdate.put(acct.Id, acct);
    
                            }
                        }
    
                        //Inactivate Other active service contracts
                        if (acc.serviceContracts.size() > 1 && hasActive){
                            for (ServiceContract sc : acc.ServiceContracts){
                                if (sc.status == 'Active'){
                                    mapScToInactivate.put(sc.Id, sc);
                    
                                }
                            }
    						
         
                            if (!mapScToInactivate.isEmpty() && mapScToInactivate.size() > 1 && mapScToInactivate.containsKey(mapCheckReconduction.get('contractActive').Id)){
                                mapScToInactivate.remove(mapCheckReconduction.get('contractActive').Id);
                            

                                //RSIW 9416 - HMO - 31-01-2022
                                mapScDesactivate = new Map<Id, ServiceContract>(mapScToInactivate);
          
    
                                if (mapScDesactivate != null){
                                    for (Id scId : mapScDesactivate.keySet()){
                                        if (mapScDesactivate.containsKey(scId)){
        
                                            if (mapScDesactivate.get(scId).startDate < Date.today()){
										
                                                

                                                mapScDesactivate.get(scId).NOB_endDate__c = mapCheckReconduction.get('contractActive').startDate.addDays(-1);
                                            }else{
                                    
                                                mapScDesactivate.get(scId).NOB_endDate__c = mapCheckReconduction.get('contractActive').startDate;
                                            
                                            }

                                            //rsiw 9416 
                                            if (mapScDesactivate.get(scId).startDate == Date.today() && mapScDesactivate.get(scId).NOB_endDate__c == Date.today()){
                
                                                mapScDesactivate.get(scId).EndDate = mapScDesactivate.get(scId).NOB_endDate__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //RSIW 9416 - HMO - 30-01-2022
            if (mapScTacite != null && !mapScTacite.isEmpty()){
  
                updateRecords(mapScTacite);
                
            }
                

            if (mapScDesactivate != null && !mapScDesactivate.isEmpty()){

                updateRecords(mapScDesactivate);
            }

            if (!mapAccsToUpdate.isEmpty()){
                updateRecords(mapAccsToUpdate);

                for (Id id : mapAccsToUpdate.keySet()){
                    if (mapAccsToUpdate.containsKey(id)){
                        if (mapAccsToUpdate.get(id).NOB_NetworkType__c == NOB_AP00_Constants.CONTRAT_PROXIMITER){
                            setReparmutsAcc.add(id);
                        }
                    }
                }
            }

            

            if (!setReparmutsAcc.isEmpty() && !setReparmutsAcc.contains(null)){
                if ( reparmutOff(setReparmutsAcc) != null){
                   
                    updateRecords(reparmutOff(setReparmutsAcc));
                }
            }

        }
    }


    public Boolean checkMapNotNull(Map<String, ServiceContract> mapServices, String key){
        ServiceContract sc = mapServices.containsKey(key) ? mapServices.get(key) : null;
        return (sc != null) ? true : false;
    }

    public static map<String, ServiceContract> checkReconduction(List<ServiceContract> lstServices){
        Map<String, ServiceContract> mapServiceContract = new Map<String, ServiceContract>();
        ServiceContract lastActiveSC;

        //RSIW - 9416
        ServiceContract scTacite;

        for (Integer i = 0; i< lstServices.size(); i++){
            if (lstServices[i].status == 'Active' && lstServices[i].startDate == Date.today()){
                system.debug('£ lstServices[i]' + lstServices[i]);
                lastActiveSC = lstServices[i];
            }

            //Date dateYearPassed = Date.newInstance(2023, 02, 04);
            if(lstServices[i].status == 'Active' && lstServices[i].endDate == Date.today() /*dateYearPassed*/ && lstServices[i].NOB_ContractTacitRenewal__c){
                scTacite = lstServices[i];
            }


        }

        mapServiceContract.put('contractActive', lastActiveSC);

        //RSIW 9416
        mapServiceContract.put('scTacite', scTacite);
        return mapServiceContract;
    }

    public Boolean checkStatusChange(ServiceContract sc, Account acct){
        return (sc.NOB_ContractsType__c != acct.NOB_techCContractType__c);
    }

    public static Account assignFields(ServiceContract sc, Account acct, Boolean firstTime){

        Boolean typeContratSC = sc.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PRIVILEGE || sc.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PARTINUM;

        Boolean typeContratAcc = (acct.NOB_NetworkType__c == NOB_AP00_Constants.CONTRAT_PROXIMITER);

        if ((firstTime && typeContratSC) || (typeContratSC && typeContratAcc)){
            System.debug('£ proxi vers privilege');
           if (String.isNotBlank(acct.NOB_SkillSet__c) && checkCompetence(acct) == false){
             
               acct.NOB_SkillSet__c = setCompetences(acct);
           }
           else if (String.isBlank(acct.NOB_SkillSet__c)){
            
                acct.NOB_SkillSet__c = setCompetences(acct);
           }

           acct.NOB_SubscriptionStartDate__c = sc.startDate;
           acct.NOB_TrainingDate__c = sc.NOB_DateDeFormation__c;
        }

        if (sc.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PROXIMITE){
            System.debug('£ privilege vers proxi ');
            if (checkCompetence(acct)){
                acct.NOB_SkillSet__c = removeCompetences(acct);
            }
           
            acct.NOB_NetworkType__c = NOB_AP00_Constants.CONTRAT_PROXIMITER;

            if(!firstTime){
                acct.NOB_SubscriptionEndDate__c = sc.startDate;
            }
        }

        if (sc.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PRIVILEGE){
            if (acct.NOB_NetworkType__c != NOB_AP00_Constants.CONTRAT_PRIVILEGER){
                system.debug('£ assignation privilege');
                acct.NOB_NetworkType__c = NOB_AP00_Constants.CONTRAT_PRIVILEGER;
            }
        }

        if (sc.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PARTINUM){

            if (acct.NOB_NetworkType__c != NOB_AP00_Constants.CONTRAT_PARTINUMR){
                system.debug('£ assignation partinum');
                acct.NOB_NetworkType__c = NOB_AP00_Constants.CONTRAT_PARTINUMR;
            }
        }

        if (firstTime){
            acct.NOB_TrainingDate__c = sc.NOB_DateDeFormation__c;
        }

        System.debug('££ assignField acct : '+ acct);
        return acct;
    }


    public static Boolean checkCompetence(Account acc){

       if (String.isNotBlank(acc.NOB_SkillSet__c)){

           if (acc.NOB_SkillSet__c.contains(String.valueOf(30))){

                return true;
           }
       }

       return false;
    }


    public static String setCompetences(Account acc){
        String values = acc.NOB_SkillSet__c;

        if (String.isNotBlank(values)){
            acc.NOB_SkillSet__c = values + ';' + string.valueOf(30);
        }else{
            acc.NOB_SkillSet__c = string.valueOf(30);
        }
        return acc.NOB_SkillSet__c;
    }


    public static String removeCompetences(Account acc){
        List<String> values = acc.NOB_SkillSet__c.split(';');
        acc.NOB_SkillSet__c = values.remove(values.indexOf(String.valueOf(30)));
        acc.NOB_SkillSet__c = String.join(values, ';');
        return acc.NOB_SkillSet__c;
    }


    public Map<Id,NOB_AccountRelationship__c> reparmutOff(set<Id> setReparateurs){
        List<String> lstReparmut = String.isNotBlank(System.Label.NOB_RelationsREPARMUT) ? System.Label.NOB_RelationsREPARMUT.split(',') : new List<String>();
        Map<Id, NOB_AccountRelationship__c> mapRelations;
        System.debug('£ lstReparmut '+ lstReparmut);

        List<NOB_AccountRelationship__c> lstRelations = new List<NOB_AccountRelationship__c>();
        for (Account acc : [SELECT Id, Name, NumeroClient__c, (SELECT NOB_Compte__c, PFR_inactive__c from Assureur__r where NOB_Bodyshop__c IN: setReparateurs AND PFR_inactive__c = false) from Account WHERE NumeroClient__c IN: lstReparmut]){

            
            if (acc.Assureur__r.size() > 0){
                lstRelations.add(acc.Assureur__r);
            }
        }

        system.debug('£ lstRelation ' + lstRelations);
        if (lstRelations != null && !lstRelations.isEmpty()){
            mapRelations = new Map<Id, NOB_AccountRelationship__c>();
            for (NOB_AccountRelationship__c rc : lstRelations){
                if (!rc.PFR_inactive__c){
                    rc.PFR_inactive__c = true;
                    mapRelations.put(rc.Id, rc);
                }
            }
        }
        return mapRelations;
    }

    //RSIW 9416 - HMO - 30-01-2022
    public static ServiceContract setExpiryDate(ServiceContract contrat){
        ServiceContract service;
        if ((contrat.NOB_ContractsType__c == /*NOB_AP00_Constants.CONTRAT_PARTINUM || contrat.NOB_ContractsType__c ==*/ NOB_AP00_Constants.CONTRAT_PRIVILEGE) && !contrat.NOB_Tech_TacitePremium__c){
            service = new ServiceContract(Id = contrat.Id, NOB_Tech_TacitePremium__c = true, EndDate = contrat.EndDate.addYears(1));
        }
        if (contrat.NOB_ContractsType__c == NOB_AP00_Constants.CONTRAT_PROXIMITE){
            service = new ServiceContract(Id = contrat.Id, EndDate = contrat.EndDate.addYears(1));
        }
      


        return (service != null) ? service : new ServiceContract();
    }


    public static void updateRecords(Map<Id, SObject> objs){

        if (!objs.isEmpty() && !objs.containskey(null)){
            try{
                system.debug('£ objs :'+ objs);
                update objs.values();
            }catch(DmlException dmle){
                system.debug(LoggingLevel.ERROR, 'Error : '+ dmle.getMessage() + 'at' + dmle.getStackTraceString());
            }
        }
    }
    
    public void execute(System.SchedulableContext sm){

    }

    public void finish(Database.BatchableContext BC){

    }
}