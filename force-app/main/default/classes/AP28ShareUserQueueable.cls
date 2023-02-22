/*************************************************************************************
Class Name - AP28ShareUserQueueable
Version - 1.0
Created Date - 06 APR 2016

Function - 
-- This class is used by method AP28UserAccountSharing.updateGroupMember and execute
-- shareUser method asynchronously

Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S 	 06/04/2016		Original version: C-001496: Use the Reference Number in Public Group for 
								sharing to BS and Dist
*********************************************************************************************************/


public with sharing class AP28ShareUserQueueable implements Queueable {

	public Map<String, List<User>> refUserListMap;

	public AP28ShareUserQueueable(Map<String, List<User>> mapReferenceNumberListOfUser){
		system.debug('###### AP28ShareUserQueueable Constructor Start');
		refUserListMap = mapReferenceNumberListOfUser;
		system.debug('###### AP28ShareUserQueueable Constructor End');
	}

	public void execute(QueueableContext context) {
		system.debug('###### AP28ShareUserQueueable execute Start');
		AP28UserAccountGroupSharing.shareUser(refUserListMap);
		system.debug('###### AP28ShareUserQueueable execute End');
		
	}
}