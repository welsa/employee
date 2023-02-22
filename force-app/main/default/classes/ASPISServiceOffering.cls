/*************************************************************************************
Class Name - ASPISServiceOffering
Version - 1.0
Created Date - 09 APR 2015
Function - Class to Trigger actions when all children orderlines are delivered

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* João Dias			 	10/04/2015 	Original Version
*************************************************************************************/
public class ASPISServiceOffering implements ASPISService{

	public void executeProcess(sObject obj){
		
		system.debug('#EXECUTING OFFERING SERVICE#');
		
		Assessment__c ass = (Assessment__c) obj;
		ASPISOfferGeneration offerObj = new ASPISOfferGeneration();
		offerObj.executeProcess(obj);
	}
}