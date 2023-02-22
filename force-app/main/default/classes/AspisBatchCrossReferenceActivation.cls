/**
 * @File Name          : AspisBatchCrossReferenceActivation.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 18/07/2019, 16:55:41
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    28/06/2019, 18:18:16   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class AspisBatchCrossReferenceActivation implements Database.Batchable<sObject>, Database.stateful {
/*************************************************************************************
Class Name - AspisBatchCrossReferenceActivation
Version - 1.0
Created Date - 22 FEB 2019
Function - Class to Activate Cross References

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L         22/02/2019  Original Version (Case-3076)
* Ruksaar L         05/03/2019  C-003037: FR - Algo for A' pricing
* Ruksaar L         05/03/2019  C-003036: France - Algo for catalog pricing for E parts
*************************************************************************************/ 	

	String query;
	String countryCode;
	Set<Id> setXrefs;	
	String languageCode;
	String errorMessages = '';
	datetime qryStart;
	String strErroredCrossRefs ='';
	String logId;
	String header = 'Country, Batch activated, Cross Reference ID, Error Message';

	global AspisBatchCrossReferenceActivation(String countryCodestr, String languageCodestr, set<Id> setCrossRefs) {
		setXrefs = setCrossRefs;
		countryCode = countryCodestr;	
		languageCode = languageCodestr;		


		query = 'Select Id, CountryCode__c, LanguageCode__c, Blacklisted__c, isDeleted__c,IAMManufacturer__c,IAMPublicPrice__c, ' +
				' IAMPartClass__c, ASPublicPrice__c, OEMPublicPrice__c, IAMPartNumber__c,OEMStandardMargin__c, OEMManufacturer__c, '+
				' OEMPartNumber__c, ProductCategory__c, ProductSubCategory__c, ProductSubSubCategory__c  ' +
				// ' (Select id, DistributorPartClass__c, DistributorPublicPrice__c, DistributorPartNumber__c, ' +
				// ' DistributorID__c,DistributorID__r.Name,Active__c, DistributorDealerNetPrice__c, DistributorCertifyingOrganization__c '+
				// ' from Distributors__r where isDeleted__c = false)'+
				' From CrossReference__c'+
				' Where isDeleted__c = false AND Blacklisted__c = false AND ToPrice__c = true  ';

		if (setXrefs != null 
			&& setXrefs.size() > 0){
			query += ' AND  Id IN: setXrefs ';
		}
		if (String.isNotBlank(countryCode)){
			query += ' AND   CountryCode__c = \'' + countryCode + '\'';
		}
		if (String.isNotBlank(languageCode)){
			query += ' AND LanguageCode__c = \'' + languageCode + '\'';
		}
		system.debug('@@ query: '+query);
		strErroredCrossRefs =  header +  ' \n' ;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<CrossReference__c> scope) {

   		system.debug('######### START AspisBatchCrossReferenceActivation execute');

   		Map<Id, CrossReference__c> mapXrefDistPriceFR = new map<Id, CrossReference__c>();
		Map<Id, CrossReference__c> mapXrefDistPriceES = new map<Id, CrossReference__c>();
		set<String> setIamManu = new set<String> ();
		set<String> setDistributorMargins = new set<String> ();

		try {
			for (CrossReference__c cf: scope){

				if (cf.CountryCode__c == 'FR' && cf.LanguageCode__c == 'fr'){

					mapXrefDistPriceFR.put(cf.Id,cf);
					setDistributorMargins.add(cf.OEMManufacturer__c + cf.OEMPartNumber__c);		
					setDistributorMargins.add(cf.OEMManufacturer__c + cf.ProductCategory__c + cf.ProductSubCategory__c + cf.ProductSubSubCategory__c);		
				}
				// else if (cf.CountryCode__c == 'ES' && cf.LanguageCode__c == 'es'){
					
				// 	mapXrefDistPriceES.put(cf.Id, cf);	
				// 	setIamManu.add(cf.IAMManufacturer__c);
							
				// }
			}

			system.debug('@@ mapXrefDistPriceFR: '+mapXrefDistPriceFR);
			system.debug('@@ mapXrefDistPriceES: '+mapXrefDistPriceES);

			
			Integer heapsize = Limits.getLimitHeapSize() - 4000000;
			system.debug('@@ heapsize: '+heapsize);				
			system.debug('@@ Limits.getHeapSize() middle: '+Limits.getHeapSize());

			if (Limits.getHeapSize() > heapsize
				|| (test.isRunningTest())){
				// logId = AspisCataloguePricingCommon.insertLog(countryCode, languageCode,errorMessages,strErroredCrossRefs,'AspisBatchCrossReferenceActivation',logId  );
				Log__c logReturned = new Log__c();	

				logReturned.ErrorDescription__c = errorMessages != null && errorMessages.length() <= 30000 ? errorMessages : '';

				if(String.isNotBlank(errorMessages) && (errorMessages.contains('Exceptions') || (errorMessages.contains('Error') && !errorMessages.contains('"ErrorMessage":null'))) || strErroredCrossRefs.length() > 65 ) {

					logReturned.Status__c = Label.STATUSFAILED;
				}
				else{
					logReturned.Status__c = Label.STATUSPASSED;
				}  
				system.debug('@@ logid: '+logid);	

				if (logid == null){
					logReturned.Class__c = 'AspisBatchCrossReferenceActivation';
					logReturned.JSONMessage__c = 'Country Code: '+CountryCode + '; Language Code: ' + languageCode; 
					logReturned.sObject__c = 'CrossRefence__c';		
					logReturned.DateLog__c  = System.now();

					insert logReturned;	
					// logReturned = APManageLogs.createWsLog(wrapperLog, 'insert');
				}
				else{	
					logReturned.Id = logId;					
					update logReturned;	

				}

				logId = logReturned.Id;
				if(String.isNotBlank(strErroredCrossRefs)){
					String datetoday = String.valueof(date.today());
					datetoday = datetoday.remove('-');
					Attachment attachment	= new Attachment(
												Body		= Blob.valueOf(strErroredCrossRefs),
												Name		= 'Errors'+datetoday+'.csv',
												ParentId	= logId
											);
					insert attachment;

				}

				strErroredCrossRefs = '';
			}
			if (mapXrefDistPriceFR.size() > 0){
				strErroredCrossRefs += AspisCataloguePricingFR.activateCrossRef(mapXrefDistPriceFR, 'FR');	
			}
			// if (mapXrefDistPriceES.size() > 0){
			// 	strErroredCrossRefs += AspisCataloguePricingES.activateCrossRef(mapXrefDistPriceES, 'ES',setIamManu);	

			// }

			system.debug('@@ strErroredCrossRefs: '+strErroredCrossRefs.length());
			system.debug('@@ Limits.getHeapSize(): '+Limits.getHeapSize());
			system.debug('@@ Limits.getLimitHeapSize(): '+Limits.getLimitHeapSize());

			
		}
		catch(exception e){
			errorMessages += 'Error: ' + e.getMessage() + ' Trace String: ' + e.getStackTraceString();
			system.debug('@@ errorMessages: '+errorMessages);


		}
	}
	
	global void finish(Database.BatchableContext BC) {

		if (String.isBlank(logId)){
			// AspisCataloguePricingCommon.insertLog(countryCode, languageCode,errorMessages,strErroredCrossRefs,'AspisBatchCrossRefsScoping',null  );
			Log__c logReturned = new Log__c();	

			logReturned.ErrorDescription__c = errorMessages != null ? errorMessages.left(32000) : '';

			if(String.isNotBlank(errorMessages) && (errorMessages.contains('Exceptions') || (errorMessages.contains('Error') && !errorMessages.contains('"ErrorMessage":null'))) || strErroredCrossRefs.length() > 65 ) {

				logReturned.Status__c = Label.STATUSFAILED;
			}
			else{
				logReturned.Status__c = Label.STATUSPASSED;
			}  
			system.debug('@@ logid: '+logid);	

			if (logid == null){
				logReturned.Class__c = 'AspisBatchCrossReferenceActivation';
				logReturned.JSONMessage__c = 'Country Code: '+CountryCode + '; Language Code: ' + languageCode; 
				logReturned.sObject__c = 'CrossRefence__c';		
				logReturned.DateLog__c  = System.now();

				insert logReturned;	
				// logReturned = APManageLogs.createWsLog(wrapperLog, 'insert');
			}
			else{	
				logReturned.Id = logId;					
				update logReturned;	

			}

			logId = logReturned.Id;
			if(String.isNotBlank(strErroredCrossRefs)){
				String datetoday = String.valueof(date.today());
				datetoday = datetoday.remove('-');
				Attachment attachment	= new Attachment(
											Body		= Blob.valueOf(strErroredCrossRefs),
											Name		= 'Errors'+datetoday+'.csv',
											ParentId	= logId
										);
				insert attachment;

			}

			strErroredCrossRefs = '';
					

				
		}


		
		
	}
	
}