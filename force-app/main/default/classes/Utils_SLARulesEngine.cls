/*************************************************************************************
Class Name - Utils_SLARulesEngine
Version - 1.0
Created Date - 29 JUN 2015
Function - Class to manage the rules for SLA calculation.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description 
* ----------    ----------  -----------------------
* Nivedita(SC)  29/06/2015  Original Version
* Yudish(SC)    20/07/2015  updated version - calSLALevelsUsingRulesEngineV2 to be used for SO and PO
* Shamina M     04/02/2016  case 1386 - updates for business hours
* Shamina M     16/02/2016  C-001518: Removed unnecessary debug logs
* Dourga U      26/02/2016  C-001521: New SLA action: Automatic validation of Delivery after delay
* Vaynee S      28/11/2017  C-002008: Businesshours optimisation
*Ruksaar L      22/06/2020  C-003699: IG - SLAs and Emails

*************************************************************************************/
public with sharing class Utils_SLARulesEngine {

	/*
	 * Method to query rules engine to retrieve rules for SLA caculation
	 ***/
	// public static map<string,list<DetailRule__c>> getRules(String process, set<string> assEntityRules, String sObjectName){
	// 	map<string,list<DetailRule__c>> entityDetRulesMap = new map<string,list<DetailRule__c>>();
	// 	string rtparametersId = Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Parameters').getRecordTypeId();
	// 	system.debug('####### run Utils_SLARulesEngine.getRules ');
	// 	//NJO 20150629 : As requested, added filtering on sObject and master rule to cater for the fact
	// 	//that there could be the same process name for SLA but on another object

	// 	for(MasterRules__c masRule :[SELECT Id, Entity__c, Process__c, RuleStatus__c, DisplayPriority__c,Country__c,
	// 										(SELECT Id, Name, RecordType.DeveloperName, Number__c, sObject__c, ValueFrom__c,
	// 										MasterRule__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Alias__c, Active__c
	// 										FROM DetailRules__r
	// 										WHERE RecordTypeId =:rtparametersId
	// 										ORDER BY Number__c)
	// 								FROM MasterRules__c
	// 								WHERE Process__c    = :process
	// 								AND Entity__c       IN :assEntityRules
	// 								AND RuleStatus__c   = :system.Label.RULESTATUSACTIVELABEL
	// 								AND sObject__c = :sObjectName
	// 								AND RuleSet__r.Process__c = 'SLA']){
	// 		for(DetailRule__c detRule: masRule.DetailRules__r){
	// 			//system.debug('####### detRule '+detRule);
	// 			if(entityDetRulesMap.containsKey(masRule.Entity__c)){
	// 				entityDetRulesMap.get(masRule.Entity__c).add(detRule);
	// 			}
	// 			else{
	// 				entityDetRulesMap.put(masRule.Entity__c, new list<DetailRule__c>{detRule});
	// 			}
	// 		}//end loop detrules
	// 	}//end loop masterrules
	// 	return entityDetRulesMap;
	// }
	/*
	 * Method to calculate the date when the different levels of SLA
	 ***/
	/*public static void calSLALevelsUsingRulesEngine(sObject s, string assEntityRules,datetime d, string countryCode, map<string,list<DetailRule__c>> entityDetRulesMap,CountryCodeInformationsMapping__c configCountryCodeInfo,LONG DURATIONINHOURS,LONG DURATIONINMINUTES){
		system.debug('###Start method calSLALevelsUsingRulesEngine');


			// Get Informations based on the Country Code
			if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
				configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
			else
				configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

			system.debug('datetime:'+d);
			//loop in det rules
			if(entityDetRulesMap != null && entityDetRulesMap.containsKey(assEntityRules) && d != null){
				for(DetailRule__c detRule1:entityDetRulesMap.get(assEntityRules)){
					// Calculate the levels when the SLA should be executed.
					if(detRule1.ValueFrom__c == 'D'){
						Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
						if(detRule1.Value__c!=null)
							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(d), integer.valueOf(detRule1.Value__c)));
					}
					// Add hours to the Date
					if(detRule1.ValueFrom__c == 'H'){
						if(detRule1.Value__c!=null)
							s.put(detRule1.FieldsAPI__c,BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, d, integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
					}
					// Add minutes to the Date
					if(detRule1.ValueFrom__c == 'M'){
						if(detRule1.Value__c!=null)
							s.put(detRule1.FieldsAPI__c, BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, d, integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
					}
				}
			}
	}*/

	//vsu commented -> new mtd with businesshours.add used
	//public static void calSLALevelsUsingRulesEngineV2(sObject s, string assEntityRules,string objCode, string f, string countryCode, map<string,list<DetailRule__c>> entityDetRulesMap,CountryCodeInformationsMapping__c configCountryCodeInfo,LONG DURATIONINHOURS,LONG DURATIONINMINUTES,Utils_BusinessDays businessDays){
	//	system.debug('###Start method calSLALevelsUsingRulesEngine');

	//		 //system.debug('###countryCode'+countryCode);
	//		// Get Informations based on the Country Code
	//		if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
	//			configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
	//		else
	//			configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

	//		//loop in det rules
	//		if(entityDetRulesMap != null && entityDetRulesMap.containsKey(assEntityRules) && s.get(f) != null){
	//			//Shamina M-case 1386 - to determine if field is datetime or date
	//			Schema.SObjectType sobjType= Schema.getGlobalDescribe().get(String.valueof(s.getSObjectType()));
	//			Schema.DescribeSObjectResult sObjRes = sobjType.getDescribe();

	//			for(DetailRule__c detRule1:entityDetRulesMap.get(assEntityRules)){
	//				// Calculate the levels when the SLA should be executed.
	//				if(detRule1.ValueFrom__c == 'D'){
	//					//Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
	//					if(detRule1.Value__c!=null){
	//						//Shamina M- case 1386
	//						Schema.DescribeFieldResult fldRes = sObjRes.fields.getMap().get(f).getDescribe();

	//						//DUN 26/02/2016 added detRule1.Active__c
	//						if(objCode=='salesOrder' && detRule1.Active__c){
	//							if(fldRes.getType() == Schema.DisplayType.Datetime)
	//								s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//							else if (fldRes.getType() == Schema.DisplayType.Date)
	//								s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//						}
	//						else if(objCode=='purchaseOrder'){
	//							if(fldRes.getType() == Schema.DisplayType.Datetime)
	//								s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//							else if (fldRes.getType() == Schema.DisplayType.Date)
	//								s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//						}
	//						//s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays((datetime)s.get(f), integer.valueOf(detRule1.Value__c)));
	//						//s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//					}

	//					/*if(objCode=='salesOrder'){
	//						Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
	//						if(detRule1.Value__c!=null){
	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//						}
	//					}
	//					else if(objCode=='purchaseOrder'){
	//						Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
	//						if(detRule1.Value__c!=null){
	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), integer.valueOf(detRule1.Value__c)));
	//						}
	//					}*/
	//				}
	//				// Add hours to the Date
	//				if(detRule1.ValueFrom__c == 'H'){
	//					if(detRule1.Value__c!=null){
	//						//DUN 26/02/2016 added detRule1.Active__c
	//						if(objCode=='salesOrder' && detRule1.Active__c){
	//							datetime dt = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, (date)s.get(f), integer.valueOf(detRule1.Value__c) * DURATIONINHOURS);
	//							s.put(detRule1.FieldsAPI__c,date.newInstance(dt.year(), dt.month(), dt.day()));
	//						}
	//						else if(objCode=='purchaseOrder'){
	//							s.put(detRule1.FieldsAPI__c,BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, (datetime)s.get(f), integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
	//						}
	//					}
	//				}
	//				// Add minutes to the Date
	//				if(detRule1.ValueFrom__c == 'M'){
	//					if(detRule1.Value__c!=null){
	//						//DUN 26/02/2016 added detRule1.Active__c
	//						if(objCode=='salesOrder' && detRule1.Active__c){
	//							datetime dt = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, (date)s.get(f), integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES);
	//							s.put(detRule1.FieldsAPI__c, date.newInstance(dt.year(), dt.month(), dt.day()));
	//						}
	//						else if(objCode=='purchaseOrder'){
	//							s.put(detRule1.FieldsAPI__c, BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, (datetime)s.get(f), integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
	//						}
	//					}
	//				}
	//			}
	//		}
	//}

	// ABT 14-NOV-2016 - C-001576 - Removed configCountryCodeInfo from the Parameters
	//VSU Commented - new mtd with Businesshours.add used
	//public static void calSLALevelsUsingRulesEngineV2(sObject s, String assEntityRules, String objCode, String f, String countryCode, map<String, List<DetailRule__c>> entityDetRulesMap, LONG DURATIONINHOURS, LONG DURATIONINMINUTES, Utils_BusinessDays businessDays)
	//{
	//	CountryCodeInformationsMapping__c configCountryCodeInfo;

	//	if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
	//	{
	//		configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
	//	}
	//	else
	//	{
	//		configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');
	//	}

	//	//loop in det rules
	//	if(	entityDetRulesMap != null && 
	//		entityDetRulesMap.containsKey(assEntityRules) && 
	//		s.get(f) != null)
	//	{
	//		//Shamina M-case 1386 - to determine if field is datetime or date
	//		Schema.SObjectType sobjType 			= Schema.getGlobalDescribe().get(String.valueof(s.getSObjectType()));
	//		Schema.DescribeSObjectResult sObjRes 	= sobjType.getDescribe();

	//		for(DetailRule__c detRule1:entityDetRulesMap.get(assEntityRules))
	//		{
	//			system.debug('##detRule1.ValueFrom__c: '+detRule1.ValueFrom__c);
	//			// Calculate the levels when the SLA should be executed.
	//			if(detRule1.ValueFrom__c == 'D')
	//			{
	//				if(detRule1.Value__c!=null)
	//				{
	//					//Shamina M- case 1386
	//					Schema.DescribeFieldResult fldRes = sObjRes.fields.getMap().get(f).getDescribe();

	//					//DUN 26/02/2016 added detRule1.Active__c
	//					if(	objCode == 'salesOrder' && 
	//						detRule1.Active__c)
	//					{
	//						if(fldRes.getType() == Schema.DisplayType.Datetime)
	//						{							
	//							system.debug('##dt so D: '+businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));

	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));
	//						}
	//						else if (fldRes.getType() == Schema.DisplayType.Date)
	//						{
	//							system.debug('##dt so D2: '+businessDays.addBusinessDays(Date.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));

	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));
	//						}

	//					}
	//					else if(objCode == 'purchaseOrder')
	//					{
	//						if(fldRes.getType() == Schema.DisplayType.Datetime)
	//						{
	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));
	//						}
	//						else if (fldRes.getType() == Schema.DisplayType.Date)
	//						{
	//							s.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));
	//						}
	//						system.debug('##dt po D: '+businessDays.addBusinessDays(Datetime.valueOf(s.get(f)), Integer.valueOf(detRule1.Value__c)));
	//					}
	//				}
	//			}

	//			// Add hours to the Date
	//			if(detRule1.ValueFrom__c == 'H')
	//			{
	//				if(detRule1.Value__c != null)
	//				{
	//					//DUN 26/02/2016 added detRule1.Active__c
	//					if(	objCode == 'salesOrder' && 
	//						detRule1.Active__c)
	//					{
	//						DateTime dt = BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (Date)s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS);
	//						s.put(detRule1.FieldsAPI__c, date.newInstance(dt.year(), dt.month(), dt.day()));
	//						system.debug('##dt so H: '+BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (Date)s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
	//					}
	//					else if(objCode == 'purchaseOrder')
	//					{
	//						s.put(detRule1.FieldsAPI__c,BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
	//						system.debug('##dt po H: '+BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
	//					}
	//				}
	//			}
	//			// Add minutes to the Date
	//			if(detRule1.ValueFrom__c == 'M')
	//			{
	//				if(detRule1.Value__c != null)
	//				{
	//					//DUN 26/02/2016 added detRule1.Active__c
	//					if(	objCode == 'salesOrder' && 
	//						detRule1.Active__c)
	//					{
	//						DateTime dt = BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (date) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES);
	//						s.put(detRule1.FieldsAPI__c, date.newInstance(dt.year(), dt.month(), dt.day()));
	//						system.debug('##dt so M: '+dt);
	//					}
	//					else if(objCode == 'purchaseOrder')
	//					{
	//						s.put(detRule1.FieldsAPI__c, BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
	//						system.debug('##dt po M: '+BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
	//					}
	//				}
	//			}
	//			system.debug('##s: '+detRule1.FieldsAPI__c);

	//		}
	//	}
 //   }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///VSU new method to eliminate addBusinessHours/////////////
public static void calSLALevelsUsingRulesEngineV2(sObject s, String assEntityRules, String objCode, String f, String countryCode, map < String, List < DetailRule__c >> entityDetRulesMap, Long DURATIONINHOURS, BusinessHours businessDays) {
    CountryCodeInformationsMapping__c configCountryCodeInfo;

    if (CountryCodeInformationsMapping__c.getall().containsKey(countryCode)) {
        configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
    } else {
        configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');
    }

    //loop in det rules
    if (entityDetRulesMap != null &&
        entityDetRulesMap.containsKey(assEntityRules) &&
        s.get(f) != null) {
        //Shamina M-case 1386 - to determine if field is datetime or date
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(String.valueof(s.getSObjectType()));
        Schema.DescribeSObjectResult sObjRes = sobjType.getDescribe();

        for (DetailRule__c detRule1: entityDetRulesMap.get(assEntityRules)) {
            // Calculate the levels when the SLA should be executed.
            //if(detRule1.ValueFrom__c == 'D')
            //{
            //time will be provided in hours
            if (detRule1.Value__c != null) {
                //Shamina M- case 1386
                Schema.DescribeFieldResult fldRes = sObjRes.fields.getMap().get(f).getDescribe();

                //DUN 26/02/2016 added detRule1.Active__c
                if (detRule1.Value__c != null) {
                    //DUN 26/02/2016 added detRule1.Active__c
                    if (objCode == 'salesOrder' && detRule1.Active__c) {
                        DateTime dt = BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (Datetime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS);
                        system.debug('##so dt: ' + detRule1.FieldsAPI__c + ' ' + BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (Datetime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));

                        s.put(detRule1.FieldsAPI__c, date.newInstance(dt.year(), dt.month(), dt.day()));
                    } else if (objCode == 'purchaseOrder') {
                    	system.debug('##f: ' + s.get(f));
                    	system.debug('##detRule1.FieldsAPI__c: '+detRule1.FieldsAPI__c);
                        system.debug('##po dt: ' + detRule1.FieldsAPI__c + ' ' + BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
                        
                        s.put(detRule1.FieldsAPI__c, BusinessHours.add((Id) configCountryCodeInfo.BusinessHoursID__c, (DateTime) s.get(f), Integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
                        
                    }
                }
            }

        }
    }
}

	// ABT 14-NOV-2016 - Made the function smarted by using a static variable to prevent the query to run when called in a loop
	public static Map<String, List<DetailRule__c>> mapObjectProcessEntityDetailRules;
	public static Map<String, List<DetailRule__c>> getRules(String process, Set<String> entityRulesSet, String sObjectName)
	{
		//NJO 20150629 : As requested, added filtering on sObject and master rule to cater for the fact
		//that there could be the same process name for SLA but on another object

		Map<String, List<DetailRule__c>> mapToReturn = new Map<String, List<DetailRule__c>>();

		Set<String> entityCodeToQuery = new Set<String>();

		if(mapObjectProcessEntityDetailRules != null)
		{
			for(String entityCode : entityRulesSet)
			{
				if(mapObjectProcessEntityDetailRules.containsKey(sObjectName + '-' + process + '-' + entityCode))
				{
					mapToReturn.put(entityCode, mapObjectProcessEntityDetailRules.get(sObjectName + '-' + process + '-' + entityCode));
				}
				else
				{
					entityCodeToQuery.add(entityCode);
				}
			}
		}
		else
		{
			mapObjectProcessEntityDetailRules = new Map<String, List<DetailRule__c>>();
			entityCodeToQuery.addAll(entityRulesSet);
		}

		if(entityCodeToQuery.size() > 0)
		{
			for(MasterRules__c masRule :[SELECT Id, Entity__c, Process__c, RuleStatus__c, DisplayPriority__c,Country__c,
												(SELECT 	Id, Name, RecordType.DeveloperName, Number__c, sObject__c, ValueFrom__c,
															MasterRule__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Alias__c, Active__c
												FROM 		DetailRules__r
												WHERE 		RecordTypeId =: Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Parameters').getRecordTypeId()
												ORDER BY 	Number__c)
										FROM 	MasterRules__c
										WHERE 	Process__c				=: process
										AND 	Entity__c				IN: entityCodeToQuery
										AND 	RuleStatus__c			=: Label.RULESTATUSACTIVELABEL
										AND 	sObject__c				=: sObjectName
										AND 	RuleSet__r.Process__c 	= 'SLA'])
			{
				mapObjectProcessEntityDetailRules.put(sObjectName + '-' + process + '-' + masRule.Entity__c, masRule.DetailRules__r);
				mapToReturn.put(masRule.Entity__c, masRule.DetailRules__r);
			}
		}

		return mapToReturn;
	}

	//RLA 22/06/2020 C-003699: IG - SLAs and Emails
	public static boolean isSLaAllowed(String insuranceBroker){
		system.debug('@@@ insuranceBroker: '+insuranceBroker);
		list<CustomerInformationsMapping__mdt> listCustomerInformationsMapping = new list<CustomerInformationsMapping__mdt>();
       
        if (String.isNotBlank(insuranceBroker)){
            For (CustomerInformationsMapping__mdt customerMapping: [SELECT AllowBodyshopEmails__c,AllowDistributorEmails__c,DeveloperName,Customer_ID__c,isSLAallowed__c, Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM CustomerInformationsMapping__mdt
                                                                    where MasterLabel = :insuranceBroker  ] ){
                listCustomerInformationsMapping.add(customerMapping);
            }

            if (listCustomerInformationsMapping.size() > 0){
                if (listCustomerInformationsMapping[0].isSLAallowed__c == true){
					return true;
				}
				else{
					return false;
				}
            }
            else{
                return true;
            }
        }
        else{
            return true;
        }
	}
}