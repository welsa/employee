/*************************************************************************************
Class Name - AP29OfferingAutomaticOrderQueueable
Version - 1.0
Created Date - 15 APR 2016

Function - 
-- This class is used by method ASPISOfferGeneration.updateOffers and execute it asynchronously

Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Dourga     	 15/04/2016		Original version
*********************************************************************************************************/
public with sharing class AP29OfferingAutomaticOrderQueueable implements Queueable {
	public map <Decimal,String> mapdisplayPriorityOfferType;
	public Id assessId;

	public AP29OfferingAutomaticOrderQueueable(map <Decimal,String> displayPriorityOfferType,Id assId){
		system.debug('###### AP29OfferingAutomaticOrderQueueable Constructor Start');
		mapdisplayPriorityOfferType = displayPriorityOfferType;
		assessId = assId;
		system.debug('###### AP29OfferingAutomaticOrderQueueable Constructor End');
	}

	public void execute(QueueableContext context) {
		system.debug('###### AP29OfferingAutomaticOrderQueueable execute Start');
		ASPISOfferGeneration.updateOffers(mapdisplayPriorityOfferType,assessId);
		system.debug('###### AP29OfferingAutomaticOrderQueueable execute End');
		
	}

}