global class UpdateSOToDeliveryConfirmed_Schedulable implements Schedulable {
/* 
--------------------------------------------------------------------------------------
-- - Name          : UpdateSOToDeliveryConfirmed_Schedulable
-- - Author        : AMI 
-- - Description   : Scedulable for AspisBatch_UpdateSOToDeliveryConfirmed
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 10-OCT-2018  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/	
	global void execute(SchedulableContext sc) {
		AspisBatch_UpdateSOToDeliveryConfirmed bat = new AspisBatch_UpdateSOToDeliveryConfirmed(); 

		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
   			database.executeBatch(bat);
		}
	}
}