global class ASPISBatchRestPostSO implements Database.Batchable<sObject>,Database.AllowsCallouts {
/*************************************************************************************
Class Name - ASPISBatchRestPostSO
Function   - Batch call to execute callout for SO (RESTPostSalesOrder) after ASPISBatchAutomiseDeliveryValidation
		   - finishes execution

Modification Log :
-----------------------------------------------------------------------------
* Developer		Date		Description
* ----------	----------	-----------------------
* Abdool M		27/02/2017	Initial Version
*************************************************************************************/

/************************************************************************************
Execute batch on execute Anonymous:
Database.executeBatch(new ASPISBatchAutomiseDeliveryValidation(), 200);
*************************************************************************************/
	
	set <id> setSOToQuery = new set <id>();
	set <String> igEntitySet;
	
	global ASPISBatchRestPostSO(set <id> setSOId) {
		system.debug('## Start constructor');

		//get list SO to be processed from ASPISBatchAutomiseDeliveryValidation
		setSOToQuery.addAll(setSOId);

		//update igEntitySet
		igEntitySet = String.isNotBlank(Label.ASFRIGEntity) ? new set <String>(Label.ASFRIGEntity.split(';')) : new set <String>();

		system.debug('## End constructor');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, Name, BodyShop__c, BodyshopOrderNumber__c, PlateNumber__c, Status__c, OfferType__c, MaximumValidityDate__c, Assessment__c,
												Assessment__r.AssessmentID__c, Assessment__r.Entity__c, Assessment__r.MissionNumber__c, Assessment__r.RecordType.DeveloperName,
												Assessment__r.ParentAssessment__r.AssessmentID__c, Assessment__r.ParentAssessment__r.Entity__c, Assessment__r.ParentAssessment__r.MissionNumber__c, 
												Assessment__r.ParentAssessment__r.RecordType.DeveloperName,Assessment__r.AssessmentNumber__c,
												(SELECT	Id, Type__c, ParentOffer__c, Name, VAT__c, OriginalType__c, FinalType__c, OriginalDescription__c,
														Description__c, OriginalPartNumber__c, PartNUmber__c, OriginalManufacturer__c, Manufacturer__c,
														Quantity__c, CataloguePrice__c, Total__c, ExpectedDeliveryDate__c, Discount__c, Price__c, BSTotalPrice__c, OrderLine__r.Suppliable__c,
														Accepted__c, DeliveryStatus__c, RealDeliveryDate__c, Comment__c
												FROM	Offers__r)
										 FROM	PrerequisiteOrder__c
										 WHERE	Id IN: setSOToQuery
										 AND	BodyShop__r.AXAPartner__c	= true
										 AND	TECH_AssessmentEntityRules__c IN: igEntitySet
										 AND	(
													(
														Assessment__r.ParentAssessment__r.isShoppingList__c 		= false
										 				AND	Assessment__r.RecordType.DeveloperName 	= 'ClaimOrder'
													) 
													OR
													(
														Assessment__r.RecordType.DeveloperName  = 'NewAssessment'
													)
										 		)]);
	}

   	global void execute(Database.BatchableContext BC, List<PrerequisiteOrder__c> scope) {
		system.debug('## Start execute');

		//build mapSoNameSoId.put(so.Name,so.Id)
		map <string,string> mapSoNameSoId = new map <string,string>();

		for(PrerequisiteOrder__c so : scope){
			mapSoNameSoId.put(so.Name,so.Id);
		}

		//set static varible on RESTPostSalesOrder since query from latter is not performed (performed now in query locator) 
		RESTPostSalesOrder.mapSoNameSoId = mapSoNameSoId;

		//launch callout
		RESTPostSalesOrder.PostSalesOrdersOffersInformation wrapper = new RESTPostSalesOrder.PostSalesOrdersOffersInformation(scope);

		system.debug('## wrapper ' + wrapper);

		RESTPostSalesOrder.sendRequest(JSON.serialize(wrapper),false);

		system.debug('## End execute');
	}
	
	global void finish(Database.BatchableContext BC) {}
}