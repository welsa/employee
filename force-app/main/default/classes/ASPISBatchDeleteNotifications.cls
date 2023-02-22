/*************************************************************************************
Class Name - ASPISBatchDeleteNotifications
Version - 1.0
Created Date - 04 AUG 2015
Function - Batch to delete Notifications

Modification Log :
-----------------------------------------------------------------------------
* Developer  	 Date       	Description
* ---------- 	 ----------  -----------------------
* Brayan Nunhuck 04/08/2015 	Original Version
* Shamina M     16/02/2016  	C-001518: Removed unnecessary debug logs
*************************************************************************************/
global class ASPISBatchDeleteNotifications implements Database.Batchable<sObject> {
	
	String query;
	global map<String,DelayForDeletion__c> mapDelay;
	
	global ASPISBatchDeleteNotifications() {
		mapDelay = DelayForDeletion__c.getAll();
		//system.debug('//// mapDelay: ' + mapDelay);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		query = 'Select Id,Tech_FormulaCreatedDate__c from Notification__c';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Notification__c> scope) {
   		//system.debug('/// scope.size(): ' + scope.size());
   		//system.debug('/// scope: ' + scope);
   		Decimal delay = 0;
   		list<Notification__c> notificationListToDelete = new list<Notification__c>();
		if(mapDelay.containsKey('DELETE-FROM')){
			if(mapDelay.get('DELETE-FROM').PurgePeriodNotificationsDays__c != null){
				delay = mapDelay.get('DELETE-FROM').PurgePeriodNotificationsDays__c;
			}
		}
		//system.debug('//// delay: ' + delay);

		if(delay > 0){
			Date todayDT = Date.today().addDays(-(integer.valueOf(delay)));
			//system.debug('//// todayDT: ' + todayDT);
			DateTime dtEnd = datetime.newInstance(todayDT.year(),todayDT.month(), todayDT.day());
			//system.debug('//// dtEnd: ' + dtEnd);

			if(scope.size() > 0){
				for(Notification__c noti : scope){
					//system.debug('//// noti.Tech_FormulaCreatedDate__c: ' + noti.Tech_FormulaCreatedDate__c);
					if(noti.Tech_FormulaCreatedDate__c < dtEnd){
						notificationListToDelete.add(noti);
					}
				}
			}

			//system.debug('//// notificationListToDelete: ' + notificationListToDelete);
			if(notificationListToDelete.size() > 0){
				delete notificationListToDelete;
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}