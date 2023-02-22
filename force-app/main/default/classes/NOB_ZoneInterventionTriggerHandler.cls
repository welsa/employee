/*************************************************************************************
Class Name - NOB_ZoneInterventionTriggerHandler
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 22-11-2021
Function - trigger zone intervention handler class
#Ticket  - RSIW : 11198

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           22-11-2021   Initial version
*/

public with sharing class NOB_ZoneInterventionTriggerHandler {

    private boolean bIsExecuting = false;
	private integer iBatchSize = 0;
    public static String[] lstZonePrefixIDF = System.Label.NOB_ZoneInterventionIDF.split(';');
    
    public NOB_ZoneInterventionTriggerHandler(Boolean executing, Integer size) {
        this.bIsExecuting = executing;
        this.iBatchSize = size;
    }

    public void NOBonAfterInsert(List<NOB_InterventionZone__c> lstNew, Map<Id, NOB_InterventionZone__c> mapOld){
        Set<Id>setAccid = new Set<Id>();
        Map<NOB_InterventionZone__c, String> mapZones = new Map<NOB_InterventionZone__c, String>();
        for(NOB_InterventionZone__c zone : lstNew){
            setAccid.add(zone.NOB_Account__c);
        }

        if(!setAccid.isEmpty()){
            NOB_AP66_ZoneInterventionUtility.queryZonesfromAcc(setAccid);
        } 
    }

    public void NOBonAfterUpdate(List<NOB_InterventionZone__c> lstNew, Map<Id, NOB_InterventionZone__c> mapOld){
        Set<Id>setAccid = new Set<Id>();
        Map<NOB_InterventionZone__c, String> mapZones = new Map<NOB_InterventionZone__c, String>();
        for(NOB_InterventionZone__c zone : lstNew){
            if (String.IsNotBlank(zone.NOB_PostalCode__c) && zone.NOB_PostalCode__c.substring(0,2) != mapOld.get(zone.Id).NOB_PostalCode__c.substring(0,2)){

                setAccid.add(zone.NOB_Account__c);
            }
        }

        if(!setAccid.isEmpty()){
            NOB_AP66_ZoneInterventionUtility.queryZonesfromAcc(setAccid);
        } 
       
    }

    public void NOBonAfterDelete(List<NOB_InterventionZone__c> lstNew, Map<Id, NOB_InterventionZone__c> mapOld){
          Set<Id>setAccid = new Set<Id>();
        Map<NOB_InterventionZone__c, String> mapZones = new Map<NOB_InterventionZone__c, String>();

        for (NOB_InterventionZone__c zone : mapOld.values()){
            setAccid.add(zone.NOB_Account__c);

        }


        if(!setAccid.isEmpty()){
            NOB_AP66_ZoneInterventionUtility.queryZonesfromAcc(setAccid);
        } 
    }
}