/**
 * @File Name          : AspisCataloguePricingCommon.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 17/07/2019, 14:46:34
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    17/07/2019, 13:50:43   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/

public with sharing class AspisCataloguePricingCommon {
/*************************************************************************************
Class Name - AspisCataloguePricingCommon
Version - 1.0
Created Date - 22 FEB 2019
Function - Class for common methods AspisCataloguePricing

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L         22/02/2019  Original Version 
*************************************************************************************/ 

	public static Pricing_Engine__mdt getPricingEngine(String countryCode){
		if (countryCode != null){
			Pricing_Engine__mdt pe = [SELECT Applicabilitmargeconstante__c,BatchtoActivate__c,DeveloperName,
											EcartmargeGolda__c,Extradiscountmargeconstante__c,Id,IAMManufacturer_for_Scoping__c,
											MasterLabel,RestrictedBBrands__c,RtrocessionAVW__c,RtrocessionA__c,
											RtrocessionB__c,RtrocessionE__c,TypetoActivate__c,PriorityofDistributors__c ,
											Restricted_E_Brands__c,Restricted_A_Brands__c, Certified_by_CZ__c,
											Information_from_supplier__c, B_supplier_for_ES__c  
									 FROM Pricing_Engine__mdt
									 WHERE MasterLabel =: countryCode
											 ];
			return pe;
		}
		else{
			return null;
		}
	}

	public static list<String> splitConcatenated(String batches){
		if (String.isNotBlank(batches)){
			list<String> lstBatches = batches.split(';');
			return lstBatches;

		}
		else{
			return new list<String>();
		}
		//set<String> setBatches = new set<String>();
		//For (string str: lstBatches){
		//	system.debug(str);
		//	setBatches.add(str.substringBetween('\' \''));
		//}
		//boolean a = lstTemp.contains('hey');
	}




	public static map<String, Integer> createPriorityMap(String strOfDis){
		map<String, Integer> distributorsPriorityMap = new map<String, Integer>();
		if (String.isNotBlank(strOfDis)){
			List<String> lstDistWithPrio =strOfDis.split(';');
			for (String str: lstDistWithPrio){
				List<String> lstStr = str.split('-');
				distributorsPriorityMap.put(lstStr[1], Integer.valueOf(lstStr[0]));
			} 

		}
		system.debug('@@ distributorsPriorityMap: '+distributorsPriorityMap);


		return distributorsPriorityMap;
	}

	public static string convertId (Id idtoConvert){
		try{
			return (String.valueOf(idtoConvert)).left(15);

		}
		catch(exception e){
			return '';
		}
	}

	// public static map<String,Supplier__c> getSuppliersMap (set<String> setIamManu){
	// 	setIamManu.add('CZ');
	// 	map<String,Supplier__c> mapSuppliers = new map<String,Supplier__c>();
	// 	for (Supplier__c supp: [SELECT Certifying_Organization__c,Part_Class__c, Clean_Part_Number__c,Name,Public_Price__c FROM Supplier__c where Name IN: setIamManu]){
	// 		mapSuppliers.put(supp.Name, supp);
	// 	}

	// 	return mapSuppliers;

	// }


	public static String insertLog(String CountryCode,
								 String languageCode,
								 String errorMessages,
								 String strErroredPartList,
								 String classname,
								 String logid){
		System.debug('@@ insertLog: ');
		system.debug('@@ Limits.getHeapSize(): '+Limits.getHeapSize());
		APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
		Log__c logReturned;	

		wrapperLog.jsonresponse = errorMessages != null && errorMessages.length() <= 30000 ? errorMessages : '';
		if(String.isNotBlank(errorMessages) && (errorMessages.contains('Exceptions') || (errorMessages.contains('Error') && !errorMessages.contains('"ErrorMessage":null'))) || strErroredPartList.length() > 0 ) {
			wrapperLog.status = Label.STATUSFAILED;
		}
		else{
			wrapperLog.status = Label.STATUSPASSED;
		}  

		Attachment attachment;
		String header = 'Country, Batch activated, Cross Reference ID, Error Message';
		if (strErroredPartList.length() > 0){
			strErroredPartList =  header + ' \n' + 	strErroredPartList;
			strErroredPartList = strErroredPartList.removeEnd('\n');

			if(String.isNotBlank(strErroredPartList)){
				wrapperLog.attachmentRequestbody = strErroredPartList;
			}
		}

		if (logid == null){
			wrapperLog.className = classname;
			wrapperLog.jsonmessage = 'Country Code: '+CountryCode + '; Language Code: ' + languageCode; 
			wrapperLog.sobjectName = 'CrossRefence__c';			
			logReturned = APManageLogs.createWsLog(wrapperLog, 'insert');
		}
		else{
			wrapperLog.logId = logid;
			logReturned = APManageLogs.createWsLog(wrapperLog, 'update');
		}
		system.debug('@@ log returned: '+logReturned);
		// system.debug('@@ csvStr: '+csvStr);
		return logReturned.Id;
	}

	// public static String createCSV(string header,
	// 						String strPartlist){

    //     //build status
    //     String finalstr = header + ' \n';

    //     for(string str : lstPartlist){
    //         finalstr += str;                         
    //     }

    //     finalstr = finalstr.removeEnd('\n');

    //     return finalstr;
	// }
}