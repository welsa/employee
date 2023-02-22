/*************************************************************************************
Class Name - NOB_TauxNegTriggerHandler
Version - 1.0
Created Date - 23/12/2020
Function - Class to Manage Taux negociés Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* USA           23/12/2020  Initial version
* USA           28/12/2020  RSIW-7115
*************************************************************************************/
public with sharing class NOB_TauxNegTriggerHandler {
    public static void onBeforeInsert(List<NOB_TauxNeg__c> lstNewTauxNeg) {
        map<Id,NOB_TauxNeg__c> mapTauxNegChkDates= new map<Id,NOB_TauxNeg__c>();
        Set<Id> setIdRelCompte = new Set<Id>();

        for (NOB_TauxNeg__c tauxNeg :lstNewTauxNeg){
//            // //RSIW-6861 : no check on overlapping dates if end date is empty
//            if (tauxNeg.NOB_EndDate__c != null){
//                mapTauxNegChkDates.put(tauxNeg.Id,tauxNeg);
//                setIdRelCompte.add(tauxNeg.NOB_RelationCompte__c);
//            }
            mapTauxNegChkDates.put(tauxNeg.Id,tauxNeg);
            setIdRelCompte.add(tauxNeg.NOB_RelationCompte__c);
        }
        if (mapTauxNegChkDates.size()>0){
            NOB_AP57_TauxNegOverlappingDates.checkOverlappingDates(mapTauxNegChkDates,setIdRelCompte);
        }
    }

    public static void onBeforeUpdate(map<Id,NOB_TauxNeg__c> mapNewTauxNeg, map<Id,NOB_TauxNeg__c> mapOldTauxNeg) {
        map<Id,NOB_TauxNeg__c> mapTauxNegChkDates= new map<Id,NOB_TauxNeg__c>();
        Set<Id> setIdRelCompte = new Set<Id>();

        for (NOB_TauxNeg__c tauxNeg :mapNewTauxNeg.values()){
            // //RSIW-6861 : no check on overlapping dates if end date is empty
//            if ((tauxNeg.NOB_StartDate__c != mapOldTauxNeg.get(tauxNeg.Id).NOB_StartDate__c) ||
//                    (tauxNeg.NOB_EndDate__c != mapOldTauxNeg.get(tauxNeg.Id).NOB_EndDate__c) && tauxNeg.NOB_EndDate__c != null){
//                mapTauxNegChkDates.put(tauxNeg.Id,tauxNeg);
//                setIdRelCompte.add(tauxNeg.NOB_RelationCompte__c);
//            }
            if ((tauxNeg.NOB_StartDate__c != mapOldTauxNeg.get(tauxNeg.Id).NOB_StartDate__c) ||
                    (tauxNeg.NOB_EndDate__c != mapOldTauxNeg.get(tauxNeg.Id).NOB_EndDate__c)){
                mapTauxNegChkDates.put(tauxNeg.Id,tauxNeg);
                setIdRelCompte.add(tauxNeg.NOB_RelationCompte__c);
            }
        }
        if (mapTauxNegChkDates.size()>0){
            NOB_AP57_TauxNegOverlappingDates.checkOverlappingDates(mapTauxNegChkDates,setIdRelCompte);
        }
    }
}