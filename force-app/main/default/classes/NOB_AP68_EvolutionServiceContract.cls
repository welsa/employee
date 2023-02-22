/*************************************************************************************
Class Name - NOB_AP68_EvolutionServiceContract
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 13-12-2021
Function - class utility for RSIW 5658
#Ticket  - RSIW : 5686

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           13-12-2021   Initial version
*/
public with sharing class NOB_AP68_EvolutionServiceContract {
    public NOB_AP68_EvolutionServiceContract() {

    }

    public static void assignStartDate(set<Id> setReparateur){
        Map<Id, Account> mapAccsToUpdate = new Map<Id, Account>();
        for (Account acc : [SELECT ID, NOB_DateDebutPartenariat__c, NOB_TECH_FirstSCDateFilled__c, (Select Id, startDate from serviceContracts ORDER BY createdDate ASC) from Account where NOB_TECH_FirstSCDateFilled__c = FALSE AND Id IN: setReparateur]){
            if (acc.serviceContracts.size() > 0){

                if (acc.NOB_DateDebutPartenariat__c != acc.serviceContracts[0].startDate){
                    Account acct = new Account(Id = acc.Id, NOB_DateDebutPartenariat__c = acc.serviceContracts[0].startDate, NOB_TECH_FirstSCDateFilled__c = true);

                    if (!mapAccsToUpdate.containsKey(acct.Id)){
                        mapAccsToUpdate.put(acct.Id, acct);
                    }
                }
            }
        }
        updateRecords(mapAccsToUpdate);
    }


    //HMO - 24-12-2021
    public static void updateEndDate(List<ServiceContract> lstServices){
       Map<Id, ServiceContract> mapServices = new Map<Id, ServiceContract>();
        for (ServiceContract sc : lstServices){
            ServiceContract contrat = new ServiceContract(Id = sc.Id, endDate = sc.NOB_endDate__c);
            mapServices.put(contrat.Id, contrat);
        }

        updateRecords(mapServices);
    }

    //HMO - 24-12-2021
    public static void clearEndDate(List<ServiceContract> lstServices){
        Map<Id, ServiceContract> mapServices = new Map<Id, ServiceContract>();
         for (ServiceContract sc : lstServices){
             ServiceContract contrat = new ServiceContract(Id = sc.Id, endDate = null);
             mapServices.put(contrat.Id, contrat);
         }
 
         updateRecords(mapServices);
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
}