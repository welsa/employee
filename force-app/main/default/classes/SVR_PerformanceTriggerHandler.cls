/**
 * @description       : This is a trigger handler which will call the appropriate class when an action is performed on a performance
 * @author            : JPI
 * @group             : 
 * @last modified on  : 26/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   JPI   Initial Version
**/
public with sharing class SVR_PerformanceTriggerHandler {
    
    Map<Id, SVR_Performance__c> mapPerfWithNomDuGestionnaire = new Map<Id, SVR_Performance__c>();
    Map<Id, SVR_Performance__c> mapPerfWithResponsableSecteur = new Map<Id, SVR_Performance__c>();
    Set<Id> userIdRSNew = new Set<Id>();
    Set<Id> userIdRSOld = new Set<Id>();
    Set<Id> userIdOPNew = new Set<Id>();
    Set<Id> userIdOPOld = new Set<Id>();

    public void OnAfterInsert(List<SVR_Performance__c> newListPerf){

        for(SVR_Performance__c perf : [SELECT id, SVR_NomGestionnaire__c, CreatedById,
                                        SVR_ResponsableSecteur__c 
                                        FROM SVR_Performance__c 
                                        WHERE id IN: newListPerf ]){
            if(perf.SVR_NomGestionnaire__c!=null){

                if(perf.SVR_NomGestionnaire__c !=perf.CreatedById){
                    if(!mapPerfWithNomDuGestionnaire.containsKey(perf.id)){
                        mapPerfWithNomDuGestionnaire.put(perf.id, perf);
                        userIdOPNew.add(perf.SVR_NomGestionnaire__c);
                    }
                }
            }

            if(perf.SVR_ResponsableSecteur__c!=null){

                if(perf.SVR_ResponsableSecteur__c !=perf.CreatedById){
                    if(!mapPerfWithResponsableSecteur.containsKey(perf.id)){
                        mapPerfWithResponsableSecteur.put(perf.id, perf);
                        userIdRSNew.add(perf.SVR_ResponsableSecteur__c);
                    }
                }
            }
        }

        if(mapPerfWithNomDuGestionnaire.size()!=0)
            SVR_AP104_PerformanceSharing.performanceSharing(mapPerfWithNomDuGestionnaire, userIdOPNew, null);
        if(mapPerfWithResponsableSecteur.size()!=0)
            SVR_AP104_PerformanceSharing.performanceSharing(mapPerfWithResponsableSecteur, userIdRSNew, null);
    }

    public void OnAfterUpdate(Map<Id, SVR_Performance__c> oldMapPA, Map<Id, SVR_Performance__c> newMapPA){

        for(id key : newMapPA.keyset()){
            if(newMapPA.get(key).SVR_NomGestionnaire__c!=null && newMapPA.get(key).SVR_NomGestionnaire__c!=oldMapPA.get(key).SVR_NomGestionnaire__c){
                mapPerfWithNomDuGestionnaire.put(newMapPA.get(key).id, newMapPA.get(key));
                if(newMapPA.get(key).SVR_NomGestionnaire__c != newMapPA.get(key).CreatedById)
                    userIdOPNew.add(newMapPA.get(key).SVR_NomGestionnaire__c);
                if(oldMapPA.get(key).SVR_NomGestionnaire__c != newMapPA.get(key).CreatedById)
                    userIdOPOld.add(oldMapPA.get(key).SVR_NomGestionnaire__c);
            }

            if(newMapPA.get(key).SVR_ResponsableSecteur__c!=null && newMapPA.get(key).SVR_ResponsableSecteur__c!=oldMapPA.get(key).SVR_ResponsableSecteur__c){
                mapPerfWithResponsableSecteur.put(newMapPA.get(key).id, newMapPA.get(key));
                if(newMapPA.get(key).SVR_ResponsableSecteur__c != newMapPA.get(key).CreatedById)
                    userIdRSNew.add(newMapPA.get(key).SVR_ResponsableSecteur__c);
                if(oldMapPA.get(key).SVR_ResponsableSecteur__c != newMapPA.get(key).CreatedById)
                    userIdRSOld.add(oldMapPA.get(key).SVR_ResponsableSecteur__c);
            }
        }
        
        if(mapPerfWithNomDuGestionnaire.size()!=0)
            SVR_AP104_PerformanceSharing.performanceSharing(mapPerfWithNomDuGestionnaire, userIdOPNew, userIdOPOld);
        if(mapPerfWithResponsableSecteur.size()!=0)
            SVR_AP104_PerformanceSharing.performanceSharing(mapPerfWithResponsableSecteur, userIdRSNew, userIdRSOld);
    }
}