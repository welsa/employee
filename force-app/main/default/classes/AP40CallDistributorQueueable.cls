/*************************************************************************************
Class Name - AP28ShareUserQueueable
Version - 1.0
Created Date - 21 SEP 2017


Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* DUN        	 21/09/2017		Original version
* Abdool M       12/12/2017     Creating LOG for distributor callout (EIP Request and Response)
*RLA			24/08/2020      C-003882 IG - Order Quality Check outside ASPIS
*********************************************************************************************************/
public without sharing class AP40CallDistributorQueueable implements Queueable, Database.AllowsCallouts {

	public string finalOrderRequest;
	public set <id> setPOIdToUpdate;
	public set <id> sentOlSet;
	//RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
	public map <string,object> mapinputParameters = new map<String,Object>();

	//AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
    //                Declare Log Object
	public Log__c log;

	public AP40CallDistributorQueueable(string finalOrderReq,set <id> setPOToUpdate, set <id> sentOlIdSet){
		system.debug('###### AP40CallDistributorQueueable Constructor Start');
		finalOrderRequest = finalOrderReq;
		setPOIdToUpdate = setPOToUpdate;
		sentOlSet = sentOlIdSet;

		mapinputParameters.put('finalOrderReq', finalOrderReq);
		mapinputParameters.put('setPOToUpdate', setPOToUpdate);
		mapinputParameters.put('sentOlIdSet', sentOlIdSet);

		system.debug('###### mapinputParameters' + mapinputParameters);

		//AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
	    //                assign Log Object
		this.log = log;
		system.debug('###### AP40CallDistributorQueueable Constructor End');
	}

	public AP40CallDistributorQueueable(map <string,object> mapinputParam){
		system.debug('###### AP40CallDistributorQueueable Constructor 2 Start');

		mapinputParameters = mapinputParam;

		// finalOrderRequest = finalOrderReq;
		// setPOIdToUpdate = setPOToUpdate;
		// sentOlSet = sentOlIdSet;

		//AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
	    //                assign Log Object
		this.log = log;
		system.debug('###### AP40CallDistributorQueueable Constructor 2 End');
	}

	public void execute(QueueableContext context) {
		system.debug('###### AP40CallDistributorQueueable execute Start');

		//AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
	    //                pass Log Object as paramter
		OrderMakeSelection.callDistributor(mapinputParameters);  
		system.debug('###### AP40CallDistributorQueueable execute End');
	}	
}