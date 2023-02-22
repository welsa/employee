/*
----------------------------------------------------------------------
-- - Name          : AP43LinkBSExpertQueueable
-- - Author        : DUN
-- - Description   : Class queueable to link Standard BS with expert BS
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-OCT-2017  DUN   1.0      case 1994 - Initial version 
----------------------------------------------------------------------*/
public without sharing class AP43LinkBSExpertQueueable implements Queueable {
	public map<String,Assessment__c> mapAssToUpdate;
	public map<Id,Account> mapAccToUpdate;

	public AP43LinkBSExpertQueueable(map<String,Assessment__c> mapAssessmentToUpdate, map<Id,Account> mapAccountToUpdate){
		system.debug('###### AP43LinkBSExpertQueueable Constructor Start');
		mapAssToUpdate = mapAssessmentToUpdate;
		mapAccToUpdate = mapAccountToUpdate;
		system.debug('###### AP43LinkBSExpertQueueable Constructor End');
	}

	public void execute(QueueableContext context) {
		system.debug('###### AP43LinkBSExpertQueueable execute Start');
		AP43LinkBSExpert.updateAssBS(mapAssToUpdate,mapAccToUpdate);
		system.debug('###### AP43LinkBSExpertQueueable execute End');
		
	}
}