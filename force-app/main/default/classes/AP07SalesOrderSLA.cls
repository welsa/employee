/*************************************************************************************
Class Name - AP07SalesOrderSLA
Version - 1.0
Created Date -
Function - Sales Order SLA

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Dourga            21/01/2016  Updated for case 1386
*************************************************************************************/
public class AP07SalesOrderSLA {
	public Static String COUNTRYCODEDEFAULT = 'ALL';
	public Static String OBJECTCODE = '-SO';
	public Static String DEFAULTCONFIG = '-DEFAULT';
	public Static String PROCESSONRESPONDED = '-DELIVERYCONFIRMATION';
	public Static String PROCESSONDELIVERY = '-DELIVERY';
	public Static String PROCESSONDELIVEREDCONFIRMED = '-DELIVERYCONFIRMATION';

	// * days   * hours * minutes   * seconds
	//  * 24     * 60    * 60        * 1000L
	public Static LONG DURATIONINHOURS = 60 * 60 * 1000L; 
	public Static LONG DURATIONINMINUTES = 60 * 1000L;

	// public static void runSLAOnStatus_Responded(PrerequisiteOrder__c so, String countryCode, String entity){
	// 	// Store the Entry Date in the new Status
	// 	if(so.SLARespondedEntryDate__c == null)
	// 		so.SLARespondedEntryDate__c = Datetime.now();
	// }

	// public static void runSLAOnStatus_DeliveryWithRulesEngine(PrerequisiteOrder__c so, String countryCode, String entity){
	// 	//System.debug('#Here 1');
	// 	//System.debug('#Here 1'+so.Status__c);
	// 	/*String configId = COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSONRESPONDED+DEFAULTCONFIG;
	// 	if(entity != '')
	// 		configId = countryCode+OBJECTCODE+PROCESSONRESPONDED+entity;
	// 		System.debug('#configId:'+configId);*/
	// 	// Get Informations based on the Country Code
	// 	CountryCodeInformationsMapping__c configCountryCodeInfo;
	// 	/*
	// 	if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
	// 		configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
	// 	else
	// 		configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');
	// 	*/
	// 	//System.debug('#TECH_AssessmentEntityRules__c:'+so.TECH_AssessmentEntityRules__c);
	// 	map<string,list<DetailRule__c>> entityDetRulesMap = new map<string,list<DetailRule__c>>();
	// 	entityDetRulesMap = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION',new Set<String>{so.TECH_AssessmentEntityRules__c},'PrerequisiteOrder__c');

	// 	//added by bnu
	// 	Map<String, CountryCodeInformationsMapping__c> countryCodeCSMap  = CountryCodeInformationsMapping__c.getAll();
	// 	Map<String, Utils_BusinessDays> countryCodeBDMap = new Map<String, Utils_BusinessDays>();
	// 	//(Dourga 21/01/2016 case 1386)
	// 	//Set<Id> businessHourIdsSet = new Set<Id>();
	// 	//Map<Id,BusinessHours> businessHoursMap = new Map<Id,BusinessHours>();
	// 	//BusinessHours defaultBH = new BusinessHours();

	// 	//(Dourga 21/01/2016 case 1386)
	// 	/*for(CountryCodeInformationsMapping__c configCountryCodeInfos : countryCodeCSMap.values()){
	// 		businessHourIdsSet.add(configCountryCodeInfos.Name);
	// 	}
	// 	system.debug('*********************************** IT IS ME: AP07SalesOrderSLA ');
	// 	for(BusinessHours bh : [SELECT Id, IsDefault,MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE Id in: businessHourIdsSet OR IsDefault=true]){
	// 		if(!bh.IsDefault){
	// 			if(!businessHoursMap.containsKey(bh.Id)){
	// 				businessHoursMap.put(bh.Id,bh);
	// 			}
	// 		}else{
	// 			defaultBH = bh;
	// 		}
	// 	}

	// 	for(Id bhId : businessHourIdsSet){
	// 		if(!businessHoursMap.containsKey(bhId)){
	// 			businessHoursMap.put(bhId,defaultBH);
	// 		}
	// 	}

	// 	List<Holidays_Setting__mdt> holidays = new List<Holidays_Setting__mdt>();
	// 	holidays = [SELECT Id, ActivityDate__c, RecurrenceDayOfMonth__c, RecurrenceDayOfWeekMask__c, Description__c, RecurrenceEndDateOnly__c, EndTimeInMinutes__c, EntityCountryCode__c, RecurrenceInstance__c, RecurrenceInterval__c, IsAllDay__c,
	// 						IsRecurrence__c, RecurrenceMonthOfYear__c, RecurrenceStartDate__c, StartTimeInMinutes__c,RecurrenceType__c
	// 				from Holidays_Setting__mdt
	// 				LIMIT 100]; // WARNING: Need further information to determine if Holidays will be used, and if so, by how many country.

	// 	for(CountryCodeInformationsMapping__c configCountryCodeInfos : countryCodeCSMap.values()){
	// 		if(businessHoursMap.containsKey((Id)configCountryCodeInfos.BusinessHoursID__c)){
	// 			Utils_BusinessDays businessDays = new Utils_BusinessDays(businessHoursMap.get((Id)configCountryCodeInfos.BusinessHoursID__c),holidays);
	// 			countryCodeBDMap.put(configCountryCodeInfos.Name,businessDays);
	// 		}
	// 	}*/

	// 	for(String businessCountry : countryCodeCSMap.KeySet()){
	// 		Utils_BusinessDays businessDays = new Utils_BusinessDays(businessCountry);
	// 		countryCodeBDMap.put(businessCountry,businessDays);
	// 	}

	// 	// Store the Entry Date in the new Status
	// 	if(so.SLAInDeliveryEntryDate__c == null)
	// 		so.SLAInDeliveryEntryDate__c = Datetime.now();

	// 	//System.debug('#SLAInDeliveryEntryDate__c:'+so.SLAInDeliveryEntryDate__c);

	// 	//System.debug('#ExpectedDeliveryDateMaximum__c:'+so.ExpectedDeliveryDateMaximum__c);

	// 	//Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(so,so.TECH_AssessmentEntityRules__c,'salesOrder', 'ExpectedDeliveryDateMaximum__c', countryCode,entityDetRulesMap,configCountryCodeInfo,DURATIONINHOURS,DURATIONINMINUTES,countryCodeBDMap.get(countryCode));
	// 	Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(so,so.TECH_AssessmentEntityRules__c,'salesOrder', 'ExpectedDeliveryDateMaximum__c', countryCode,entityDetRulesMap,DURATIONINHOURS,DURATIONINMINUTES,countryCodeBDMap.get(countryCode));

	// 	//Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(so,so.TECH_AssessmentEntityRules__c,so.ExpectedDeliveryDateMaximum__c, countryCode,entityDetRulesMap,configCountryCodeInfo,DURATIONINHOURS,DURATIONINMINUTES);

	// 	/*
	// 	//loop in det rules
	// 	if(entityDetRulesMap != null && entityDetRulesMap.containsKey(so.TECH_AssessmentEntityRules__c) && so.ExpectedDeliveryDateMaximum__c != null){
	// 		System.debug('#Here 2');
	// 		for(DetailRule__c detRule1:entityDetRulesMap.get(so.TECH_AssessmentEntityRules__c)){
	// 			// Calculate the levels when the SLA should be executed.
	// 			if(detRule1.ValueFrom__c == 'D'){
	// 				Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
	// 				if(detRule1.Value__c!=null)
	// 					so.put(detRule1.FieldsAPI__c,businessDays.addBusinessDays(Date.valueOf(so.ExpectedDeliveryDateMaximum__c), integer.valueOf(detRule1.Value__c)));
	// 			}
	// 			// Add hours to the Date
	// 			if(detRule1.ValueFrom__c == 'H'){
	// 				if(detRule1.Value__c!=null)
	// 					so.put(detRule1.FieldsAPI__c,BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, so.ExpectedDeliveryDateMaximum__c, integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
	// 			}
	// 			// Add minutes to the Date
	// 			if(detRule1.ValueFrom__c == 'M'){
	// 				if(detRule1.Value__c!=null)
	// 					so.put(detRule1.FieldsAPI__c, BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, so.ExpectedDeliveryDateMaximum__c, integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
	// 			}
	// 		}
	// 	} */
	// }
		/*
	public static void runSLAOnStatus_Delivery(PrerequisiteOrder__c so, String countryCode, String entity){
		String configId = COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSONRESPONDED+DEFAULTCONFIG;
		if(entity != '')
			configId = countryCode+OBJECTCODE+PROCESSONRESPONDED+entity;

		// Get Informations based on the Country Code
		CountryCodeInformationsMapping__c configCountryCodeInfo;
		if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
			configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
		else
			configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

		SLAConfiguration__c config;
		if(SLAConfiguration__c.getall().containsKey(configId))
			config = SLAConfiguration__c.getall().get(configId);
		else
			config = SLAConfiguration__c.getall().get(COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSONRESPONDED+DEFAULTCONFIG);

		// Store the Entry Date in the new Status
		if(so.SLAInDeliveryEntryDate__c == null)
			so.SLAInDeliveryEntryDate__c = Datetime.now();

		if (config != NULL && so.ExpectedDeliveryDateMaximum__c != null) {
			// Calculate the levels when the SLA should be executed.
			if(config.LevelsDurationUnity__c == 'D'){
				Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
				so.SLAInDeliveryLevel1__c = businessDays.addBusinessDays(Date.valueOf(so.ExpectedDeliveryDateMaximum__c), (Integer)config.SLALevel1Minute__c);
				so.SLAInDeliveryLevel2__c = businessDays.addBusinessDays(Date.valueOf(so.ExpectedDeliveryDateMaximum__c), (Integer)config.SLALevel2Minute__c);
			}
			// Add hours to the Date
			if(config.LevelsDurationUnity__c == 'H'){
				so.SLAInDeliveryLevel1__c = (Date)BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c,so.ExpectedDeliveryDateMaximum__c, (Integer)config.SLALevel1Minute__c * DURATIONINHOURS);
				so.SLAInDeliveryLevel2__c = (Date)BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c,so.ExpectedDeliveryDateMaximum__c, (Integer)config.SLALevel2Minute__c * DURATIONINHOURS);
			}
			// Add minutes to the Date
			if(config.LevelsDurationUnity__c == 'M'){
				so.SLAInDeliveryLevel1__c = (Date)BusinessHours.add((Id)config.BusinessHoursID__c,so.ExpectedDeliveryDateMaximum__c, (Integer)config.SLALevel1Minute__c * DURATIONINMINUTES);
				so.SLAInDeliveryLevel2__c = (Date)BusinessHours.add((Id)config.BusinessHoursID__c,so.ExpectedDeliveryDateMaximum__c, (Integer)config.SLALevel2Minute__c * DURATIONINMINUTES);
			}
		}
	}*/

	// public static void runSLAOnStatus_DeliveryConfirmed(PrerequisiteOrder__c so, String countryCode, String entity){
	// 	// Store the Entry Date in the new Status
	// 	if(so.SLADeliveryConfirmedEntryDate__c == null)
	// 		so.SLADeliveryConfirmedEntryDate__c = Datetime.now();

	// 	// Clear the fields that execute the time-dependent workflow.
	// 	so.SLAInDeliveryLevel1__c = null;
	// 	so.SLAInDeliveryLevel2__c = null;
	// }
	//private void


	// ----------------------------------- FOR NEW VERSION -----------------------------
	public static void runSLAOnStatus_Responded(PrerequisiteOrder__c salesOrder)
	{
		// Store the Entry Date in the new Status
		if(salesOrder.SLARespondedEntryDate__c == null)
		{
			salesOrder.SLARespondedEntryDate__c = Datetime.now();
		}
	}

	public static void runSLAOnStatus_DeliveryWithRulesEngine(PrerequisiteOrder__c salesOrder)
	{
		Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION', new Set<String>{salesOrder.TECH_AssessmentEntityRules__c}, 'PrerequisiteOrder__c');

		Map<String, CountryCodeInformationsMapping__c> countryCodeCSMap  = CountryCodeInformationsMapping__c.getAll();
		//Map<String, Utils_BusinessDays> countryCodeBDMap = new Map<String, Utils_BusinessDays>();
		Map<String, BusinessHours> countryCodeBDMap = new Map<String,BusinessHours>();

		for(String businessCountry : countryCodeCSMap.KeySet()){
			//Utils_BusinessDays businessDays = new Utils_BusinessDays(businessCountry);
			BusinessHours businessDays = ASPISConstants.getBusinessHours(businessCountry);
			countryCodeBDMap.put(businessCountry,businessDays);
		}

		// Store the Entry Date in the new Status
		if(salesOrder.SLAInDeliveryEntryDate__c == null)
		{
			salesOrder.SLAInDeliveryEntryDate__c = System.now();
		}
		/*Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(salesOrder, salesOrder.TECH_AssessmentEntityRules__c, 'salesOrder',
															'ExpectedDeliveryDateMaximum__c', salesOrder.TECH_BodyshopCountryCode__c, mapEntityDetailRules,
															DURATIONINHOURS, DURATIONINMINUTES, countryCodeBDMap.get(salesOrder.TECH_BodyshopCountryCode__c));*/

		Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(salesOrder, salesOrder.TECH_AssessmentEntityRules__c, 'salesOrder',
															'ExpectedDeliveryDateMaximum__c', salesOrder.TECH_BodyshopCountryCode__c, mapEntityDetailRules,
															DURATIONINHOURS, countryCodeBDMap.get(salesOrder.TECH_BodyshopCountryCode__c));
		//set ExpectedDeliveryDateMaximum__c and SLAInDeliveryEntryDate__c
	}

	public static void runSLAOnStatus_DeliveryConfirmed(PrerequisiteOrder__c salesOrder)
	{
		// Store the Entry Date in the new Status
		if(salesOrder.SLADeliveryConfirmedEntryDate__c == null)
		{
			salesOrder.SLADeliveryConfirmedEntryDate__c = System.now();
		}

		// Clear the fields that execute the time-dependent workflow.
		salesOrder.SLAInDeliveryLevel1__c = null;
		salesOrder.SLAInDeliveryLevel2__c = null;
	}
}