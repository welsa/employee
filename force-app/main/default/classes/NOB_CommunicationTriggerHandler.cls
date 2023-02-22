/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_ExpeditionTriggerHandler
  -- - Author        : HMO
  -- - Description   : 
  -- - #Ticket       : RSIW : 12130
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 19-04-22        HMO     1.0     Initial version
  **********************************************************************
*/public with sharing class NOB_CommunicationTriggerHandler {
    String profileName;


    public NOB_CommunicationTriggerHandler() {
       profileName = NOBTools.ProfileName();
    }

    public void onBeforeDelete(Map<Id,NOB_Communication__c> mapOldComms){

      set<String> setProfilesAllowed = new Set<String>(Label.ProfilesForDeleteExpeditions.split(';'));

      if (String.IsNotBlank(profileName) && !setProfilesAllowed.contains(profileName)){

        NOB_LC54_ConteurComm.preventDeleteComm(mapOldComms);

      }

    }

}