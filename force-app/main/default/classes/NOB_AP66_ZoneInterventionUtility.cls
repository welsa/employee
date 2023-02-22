/*************************************************************************************
Class Name - NOB_AP66_ZoneInterventionUtility
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 22-11-2021
Function - utility class to manage zone intervention DML's
#Ticket  - RSIW : 11198

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           22-11-2021   Initial version
*/
public with sharing class NOB_AP66_ZoneInterventionUtility {
   
    public NOB_AP66_ZoneInterventionUtility() {

    }

    public static void queryZonesfromAcc(Set<Id> setAccs){
        String[] lstZonePrefixIDF = System.Label.NOB_ZoneInterventionIDF.split(';');
        String zoneInterventionCORSE = System.Label.NOB_ZoneInterventionCORSE;
        Set<String> allZones = new Set<String> ();
        allZones.addAll(lstZonePrefixIDF);
        allZones.add(zoneInterventionCORSE);


        List<Account> lstAccToUpdate = new List<Account>();
            for (Account acc : [SELECT Id, NOB_eligibleRevalorisationsSAD_CORSE__c, NOB_eligiblerevalorisationsSAD_IDF__c, (SELECT Id, NOB_Account__c, TechLeftTwoCodePostal__c, NOB_PostalCode__c from Zones_d_intervention__r where TechLeftTwoCodePostal__c IN: allZones) from Account WHERE Id IN: setAccs]){

               

                Boolean idf = false;
                Boolean corse = false;

                if (acc.Zones_d_intervention__r.size() > 0){
                for (NOB_InterventionZone__c zone :acc.Zones_d_intervention__r){

                    if (String.IsNotBlank(zone.NOB_PostalCode__c) && lstZonePrefixIDF.contains(zone.NOB_PostalCode__c.substring(0,2))){
                        idf = true;
                    }
                    
                    if (String.IsNotBlank(zone.NOB_PostalCode__c) && zone.NOB_PostalCode__c.substring(0,2) == System.Label.NOB_ZoneInterventionCORSE){
                        corse = true;
                    }
    
                    if (idf && corse){
                        break;
                    }
                }
            }
            Account accToUpdate = new Account(Id = acc.Id, NOB_eligiblerevalorisationsSAD_IDF__c = idf,  NOB_eligibleRevalorisationsSAD_CORSE__c = corse);

            lstAccToUpdate.add(accToUpdate);
        }

        if(lstAccToUpdate.size() > 0){
            update lstAccToUpdate;
        }
    }

}