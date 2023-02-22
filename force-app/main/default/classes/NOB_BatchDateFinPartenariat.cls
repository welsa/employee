/*************************************************************************************
Class Name - NOB_BatchDateFinPartenariat
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 06-12-2021
Function - Class to update account when date de fin is today
#Ticket  - RSIW : 9311

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           06-12-2021    Initial version
*************************************************************************************/
public with sharing class NOB_BatchDateFinPartenariat implements Schedulable, Database.Batchable<sObject>{

    //Set<Id> setIdsBodyshop;
    public NOB_BatchDateFinPartenariat(/*set<Id> setParamsId*/) {
        /*setIdsBodyshop = new set<Id>();
        if (setParamsId != null){
            for (Id id: setParamsId){
                setIdsBodyshop.add(id);
            }   
        }*/
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('BODYSHOP').getRecordTypeId();
        String today = String.valueOf(system.today()); 
        String query = 'SELECT Id, Name, NOB_TechRaisondeStatut__c, NOB_StatusReason__c,NumeroClient__c, NOB_Statut__c, BillingStreet, BillingCity, BillingCountry, BillingPostalCode from Account where NOB_Statut__c = \'Actif\' AND RecordTypeId = \''+recordTypeId+'\' and NOB_isPrefikar__c = true and NOB_DateFinPartenariat__c =' + today;

        /*if (setIdsBodyshop.size() > 0){
            query += ' AND Id IN: setIdsBodyshop';
        }*/
        
        system.debug('£££ query : '+ query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        if (!scope.isEmpty()){ 
            NOB_AP67_EmailDateFinPartenariat.sendEmail(scope);
        }
    }

    public void execute(System.SchedulableContext sm){

    }

    public void finish(Database.BatchableContext BC){
 
    }
}