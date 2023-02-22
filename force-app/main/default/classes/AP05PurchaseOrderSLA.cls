/*************************************************************************************
Class Name - AP05PurchaseOrderSLA
Version - 1.0
Created Date - 30 MAR 2015
Function - Class to manage the SLA on Purchase Order.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      30/03/2015  Original Version
* Nivedita(SC)  29/06/2015  Updated query on master rules to restrict on sObject
*                           and on SLA rule set
* Dourga        21/01/2016  Updated for case 1386
* Ashutosh B    26/09/2016  Case C-001480 - Commented the unused funtion calculateEstimatedDeliveryDateOnOrderLines
* Vaynee S      28/11/2017  C-002008 Replaced instances of addBusinessHour by Businesshours.add()  
* Abdool M      05/01/2017  Case C-002161 - Changing API name from MaximumDeliveryDuration__c to MaxDeliveryDuration__c                         
*************************************************************************************/
public class AP05PurchaseOrderSLA {
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public Static String COUNTRYCODEDEFAULT = 'ALL';
    public Static String OBJECTCODE = '-PO';
    public Static String DEFAULTCONFIG = '-DEFAULT';
    public Static String PROCESSQUOTATION = '-QUOTATION';
    public Static String PROCESSACCEPTANCE = '-QUOTATION';
    public Static String PROCESSORDERED = '-QUOTATION';
    public Static String PROCESSDELIVERY = '-QUOTATION';
    public Static String PROCESSDELIVEREDCONFIRMED = '-QUOTATION';
    public Static String PROCESSCLOSED = '-QUOTATION';

    // * days   * hours * minutes   * seconds
    //  * 24     * 60    * 60        * 1000L
    public Static LONG DURATIONINHOURS = 60 * 60 * 1000L;
    public Static LONG DURATIONINMINUTES = 60 * 1000L;
    public Static LONG ELAPSEDDURATIONINHOURS = 60 / 60 / 1000L;
    public Static LONG ELAPSEDDURATIONINMINUTES = 60 / 1000L;

    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/

    /*
    Added by yudish - 19/06/15 (SLA using rule engine)
    Calculate the date when the different levels of SLA using rule engine
    */
    /*
     * The Purchase Order is created :
     *  - STore the current date inside the process entry date.
     *  - Calculate the date when the different levels of SLA should fired.
     ***/
    public static void initiateSLAProcess_QuotationUsingRuleEngine(list<PurchaseOrder__c> poList, set<string> assEntityRules,string process){
        system.debug('###Start of method initiateSLAProcess_QuotationUsingRuleEngine:');

        CountryCodeInformationsMapping__c configCountryCodeInfo;
        map<string,list<DetailRule__c>> entityDetRulesMap = new map<string,list<DetailRule__c>>();
        entityDetRulesMap = Utils_SLARulesEngine.getRules(process,assEntityRules,'PurchaseOrder__c');

        Map<String, Schema.SObjectField> poSobjectApiNameMap = Schema.SObjectType.PurchaseOrder__c.fields.getMap();
        //system.debug('poSobjectApiNameMap'+poSobjectApiNameMap);

        //(Dourga 21/01/2016 case 1386)
        //Map<String, CountryCodeInformationsMapping__c> countryCodeCSMap  = CountryCodeInformationsMapping__c.getAll();
        //Map<String, Utils_BusinessDays> countryCodeBDMap = new Map<String, Utils_BusinessDays>();
        Map<String, BusinessHours> countryCodeBDMap = new Map<String, BusinessHours>();
        
        //Set<Id> businessHourIdsSet = new Set<Id>();
        //Map<Id,BusinessHours> businessHoursMap = new Map<Id,BusinessHours>();
        ///BusinessHours defaultBH = new BusinessHours();

        /*for(CountryCodeInformationsMapping__c configCountryCodeInfos : countryCodeCSMap.values()){
            businessHourIdsSet.add((Id)configCountryCodeInfos.BusinessHoursID__c);
        }
        system.debug('*********************************** IT IS ME: AP05PurchaseOrderSLA ');
        for(BusinessHours bh : [SELECT Id, IsDefault,MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE Id in: businessHourIdsSet OR IsDefault=true]){
            if(!bh.IsDefault){
                if(!businessHoursMap.containsKey(bh.Id)){
                    businessHoursMap.put(bh.Id,bh);
                }
            }else{
                defaultBH = bh;
            }
        }

        for(Id bhId : businessHourIdsSet){
            if(!businessHoursMap.containsKey(bhId)){
                businessHoursMap.put(bhId,defaultBH);
            }
        }

        List<Holiday> holidays = new List<Holiday>();
        holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday LIMIT 100]; // WARNING: Need further information to determine if Holidays will be used, and if so, by how many country.

        List<Holidays_Setting__mdt> holidays = new List<Holidays_Setting__mdt>();
        holidays = [SELECT Id, ActivityDate__c, RecurrenceDayOfMonth__c, RecurrenceDayOfWeekMask__c, Description__c, RecurrenceEndDateOnly__c, EndTimeInMinutes__c, EntityCountryCode__c, RecurrenceInstance__c, RecurrenceInterval__c, IsAllDay__c,
                            IsRecurrence__c, RecurrenceMonthOfYear__c, RecurrenceStartDate__c, StartTimeInMinutes__c,RecurrenceType__c
                    from Holidays_Setting__mdt
                    LIMIT 100];

        for(CountryCodeInformationsMapping__c configCountryCodeInfos : countryCodeCSMap.values()){
            if(businessHoursMap.containsKey((Id)configCountryCodeInfos.BusinessHoursID__c)){
                Utils_BusinessDays businessDays = new Utils_BusinessDays(businessHoursMap.get((Id)configCountryCodeInfos.BusinessHoursID__c),holidays);
                countryCodeBDMap.put(configCountryCodeInfos.Name,businessDays);
            }
        }*/

        //(Dourga 14/12/2015 case 1386)
        Set <String> setcountryCode = new Set <String>();
        for(PurchaseOrder__c po:poList){
            //System.debug('## countryCode'+po.TECH_AssessmentCountryCode__c);
            setcountryCode.add(po.TECH_AssessmentCountryCode__c);
        }

        for(String counCode : setcountryCode){
            //System.debug('## countryCode'+counCode);
            BusinessHours businessDays = ASPISConstants.getBusinessHours(counCode);
            countryCodeBDMap.put(counCode,businessDays);
        }

        //loop in po to calculate level1,level2 and level3
        for(PurchaseOrder__c po:poList){
            system.debug('##AP05');

            /*// Get Informations based on the Country Code
            if(CountryCodeInformationsMapping__c.getall().containsKey(po.TECH_DistributorCountryCode__c))
                configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(po.TECH_DistributorCountryCode__c);
            else
                configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');
            */

            //system.debug('TECH_AssessmentEntityRules__c:'+po.TECH_AssessmentEntityRules__c);
            //system.debug('TECH_AssessmentCountryCode__c:'+po.TECH_AssessmentCountryCode__c);

            // Store the Entry Date in the new Status
            if(po.SLAQuotationEntryDate__c == null)
                po.SLAQuotationEntryDate__c = Datetime.now();

            //Utils_SLARulesEngine.calSLALevelsUsingRulesEngine(po,po.TECH_AssessmentEntityRules__c,po.SLAQuotationEntryDate__c,po.TECH_AssessmentCountryCode__c,entityDetRulesMap,configCountryCodeInfo,DURATIONINHOURS,DURATIONINMINUTES);
            //Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(po,po.TECH_AssessmentEntityRules__c,'purchaseOrder','SLAQuotationEntryDate__c',po.TECH_AssessmentCountryCode__c,entityDetRulesMap,configCountryCodeInfo,DURATIONINHOURS,DURATIONINMINUTES,countryCodeBDMap.get(po.TECH_AssessmentCountryCode__c));
            //Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(po,po.TECH_AssessmentEntityRules__c,'purchaseOrder','SLAQuotationEntryDate__c',po.TECH_AssessmentCountryCode__c,entityDetRulesMap,DURATIONINHOURS,DURATIONINMINUTES,countryCodeBDMap.get(po.TECH_AssessmentCountryCode__c));
            Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(po,po.TECH_AssessmentEntityRules__c,'purchaseOrder','SLAQuotationEntryDate__c',po.TECH_AssessmentCountryCode__c,entityDetRulesMap,DURATIONINHOURS,countryCodeBDMap.get(po.TECH_AssessmentCountryCode__c));

            /*
            //loop in det rules
            if(entityDetRulesMap != null && entityDetRulesMap.containsKey(po.TECH_AssessmentEntityRules__c)){
                for(DetailRule__c detRule1:entityDetRulesMap.get(po.TECH_AssessmentEntityRules__c)){
                    // Calculate the levels when the SLA should be executed.
                    if(detRule1.ValueFrom__c == 'D'){
                        Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
                        if(detRule1.Value__c!=null)
                            po.put(detRule1.FieldsAPI__c,businessDays.getEndOfBusinessDayFromDate(Date.valueOf(po.SLAQuotationEntryDate__c), integer.valueOf(detRule1.Value__c)));
                    }
                    // Add hours to the Date
                    if(detRule1.ValueFrom__c == 'H'){
                        if(detRule1.Value__c!=null)
                            po.put(detRule1.FieldsAPI__c,BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, integer.valueOf(detRule1.Value__c) * DURATIONINHOURS));
                    }
                    // Add minutes to the Date
                    if(detRule1.ValueFrom__c == 'M'){
                        if(detRule1.Value__c!=null)
                            po.put(detRule1.FieldsAPI__c, BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, integer.valueOf(detRule1.Value__c) * DURATIONINMINUTES));
                    }
                }
            }*/
        }//end loop
    }

    /*
     * The Purchase Order is created :
     *  - STore the current date inside the process entry date.
     *  - Calculate the date when the different levels of SLA should fired.
     ***/
     /* NJO 20150629 : Commented as no longer called, using initiateSLAProcess_QuotationUsingRuleEngine
    public static void initiateSLAProcess_Quotation(PurchaseOrder__c po, String countryCode, String entity){
        String configId = COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSQUOTATION+DEFAULTCONFIG;
        if(entity != '')
            configId = countryCode+OBJECTCODE+PROCESSQUOTATION+entity;

        System.debug('####### configId '+configId+' default: '+COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSQUOTATION+DEFAULTCONFIG);

        // Get SLA Configuration
        SLAConfiguration__c config;
        if(SLAConfiguration__c.getall().containsKey(configId))
            config = SLAConfiguration__c.getall().get(configId);
        else
            config = SLAConfiguration__c.getall().get(COUNTRYCODEDEFAULT+OBJECTCODE+PROCESSQUOTATION+DEFAULTCONFIG);

        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        po.SLAQuotationEntryDate__c = Datetime.now();
        system.debug('####### config '+config);

        if (config != NULL && configCountryCodeInfo != null) {
            // Calculate the levels when the SLA should be executed.
            if(config.LevelsDurationUnity__c == 'D'){
                Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
                if(config.SLALevel1Minute__c != null)
                    po.SLAQuotationLevel1__c = businessDays.getEndOfBusinessDayFromDate(Date.valueOf(po.SLAQuotationEntryDate__c), (Integer)config.SLALevel1Minute__c);
                if(config.SLALevel2Minute__c != null)
                    po.SLAQuotationLevel2__c = businessDays.getEndOfBusinessDayFromDate(Date.valueOf(po.SLAQuotationEntryDate__c), (Integer)config.SLALevel2Minute__c);
                if(config.SLALevel3Minute__c != null)
                    po.SLAQuotationLevel3__c = businessDays.getEndOfBusinessDayFromDate(Date.valueOf(po.SLAQuotationEntryDate__c), (Integer)config.SLALevel3Minute__c);
            }
            // Add hours to the Date
            if(config.LevelsDurationUnity__c == 'H'){
                if(config.SLALevel1Minute__c != null)
                    po.SLAQuotationLevel1__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel1Minute__c * DURATIONINHOURS);
                if(config.SLALevel2Minute__c != null)
                    po.SLAQuotationLevel2__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel2Minute__c * DURATIONINHOURS);
                if(config.SLALevel3Minute__c != null)
                    po.SLAQuotationLevel3__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel3Minute__c * DURATIONINHOURS);
            }
            // Add minutes to the Date
            if(config.LevelsDurationUnity__c == 'M'){
                if(config.SLALevel1Minute__c != null)
                    po.SLAQuotationLevel1__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel1Minute__c * DURATIONINMINUTES);
                if(config.SLALevel2Minute__c != null)
                    po.SLAQuotationLevel2__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel2Minute__c * DURATIONINMINUTES);
                if(config.SLALevel3Minute__c != null)
                    po.SLAQuotationLevel3__c = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, po.SLAQuotationEntryDate__c, (Integer)config.SLALevel3Minute__c * DURATIONINMINUTES);
            }
        }
        system.debug('####### po '+po.SLAQuotationLevel1__c + ' - ' + po.SLAQuotationLevel2__c+ ' - ' + po.SLAQuotationLevel3__c);
    }*/

    /*
     * Status = Responded or Issued :
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     ***/
    /*public static void runSLAOnStatus_Acceptance(PurchaseOrder__c po, String countryCode, String entity){

        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(po.SLAAcceptanceEntryDate__c == null)
            po.SLAAcceptanceEntryDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            // Calculate the duration passed in the previous step
            if(po.SLAQuotationEntryDate__c != null){
                Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
                po.SLAQuotationDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAQuotationEntryDate__c, po.SLAAcceptanceEntryDate__c);
            }

             system.debug('####### SLAQuotationDurationA: '+po.SLAQuotationDuration__c);
        }
    }*/

    // public static void runSLAOnStatus_Acceptance(PurchaseOrder__c po, Utils_BusinessDays businessDays, String entity){

    //  // Get Informations based on the Country Code
    //  /*CountryCodeInformationsMapping__c configCountryCodeInfo;
    //  if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
    //      configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
    //  else
    //      configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');*/

    //  // Store the Entry Date in the new Status
    //  if(po.SLAAcceptanceEntryDate__c == null)
    //      po.SLAAcceptanceEntryDate__c = Datetime.now();

    //  if (businessDays != null) {
    //      // Calculate the duration passed in the previous step
    //      if(po.SLAQuotationEntryDate__c != null){
    //          //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
    //          po.SLAQuotationDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAQuotationEntryDate__c, po.SLAAcceptanceEntryDate__c);
    //      }
    //      system.debug('####### SLAQuotationDurationA: '+po.SLAQuotationDuration__c);
    //  }
    // }

    /*
     * Status = Ordered :
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     ***/
    /*public static void runSLAOnStatus_Ordered(PurchaseOrder__c po, String countryCode, String entity){

        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(po.SLAOrderedEntryDate__c == null)
            po.SLAOrderedEntryDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            // Calculate the duration passed in the previous step
            if(po.SLAAcceptanceEntryDate__c != null){
                Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
                po.SLAAcceptanceDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAAcceptanceEntryDate__c, po.SLAOrderedEntryDate__c);
            }
        }
        system.debug('####### SLAAcceptanceDurationO: '+po.SLAAcceptanceDuration__c);
    }*/

    // public static void runSLAOnStatus_Ordered(PurchaseOrder__c po, Utils_BusinessDays businessDays, String entity){

    //  /*// Get Informations based on the Country Code
    //  CountryCodeInformationsMapping__c configCountryCodeInfo;
    //  if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
    //      configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
    //  else
    //      configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');*/

    //  // Store the Entry Date in the new Status
    //  if(po.SLAOrderedEntryDate__c == null)
    //      po.SLAOrderedEntryDate__c = Datetime.now();

    //  if (businessDays != null) {
    //      // Calculate the duration passed in the previous step
    //      if(po.SLAAcceptanceEntryDate__c != null){
    //          //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
    //          po.SLAAcceptanceDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAAcceptanceEntryDate__c, po.SLAOrderedEntryDate__c);
    //      }
    //  }
    //  //system.debug('####### SLAAcceptanceDurationO: '+po.SLAAcceptanceDuration__c);
    // }

    /*
     * Status = In Delivery :
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     *  - Calculate the estimated delivery date on Purchase Order and related Order Lines.
     ***/
//    public static void runSLAOnStatus_Delivery(PurchaseOrder__c po, String countryCode, String entity, List<OrderLine__c> l_ols){
    /*public static void runSLAOnStatus_Delivery(PurchaseOrder__c po, String countryCode, String entity){
        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(po.SLADeliveryEntryDate__c == null)
            po.SLADeliveryEntryDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
          // Calculate the estimated delivery date on each related Order Lines of this Purchase order.
            //if(l_ols != null && l_ols.size() != 0)
                //calculateEstimatedDeliveryDateOnOrderLines(l_ols, businessDays, po.SLADeliveryEntryDate__c);

            // Calculate the estimated delivery date on Purchase order.
            if(po.MaximumDeliveryDuration__c != null){
                po.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(po.SLADeliveryEntryDate__c), (Integer)po.MaximumDeliveryDuration__c);
            }
            // Calculate the duration passed in the previous step
            if(po.SLAOrderedEntryDate__c != null){
                po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLADeliveryEntryDate__c);
            }
        }
        system.debug('####### SLAOrderedDurationI: '+po.SLAOrderedDuration__c);
    }*/

    // public static void runSLAOnStatus_Delivery(PurchaseOrder__c po, Utils_BusinessDays businessDays, String entity){
    //  // Get Informations based on the Country Code


    //  // Store the Entry Date in the new Status
    //  if(po.SLADeliveryEntryDate__c == null)
    //      po.SLADeliveryEntryDate__c = Datetime.now();

    //  if (businessDays != null) {
    //      //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
    //    // Calculate the estimated delivery date on each related Order Lines of this Purchase order.
    //      //if(l_ols != null && l_ols.size() != 0)
    //          //calculateEstimatedDeliveryDateOnOrderLines(l_ols, businessDays, po.SLADeliveryEntryDate__c);

    //      // Calculate the estimated delivery date on Purchase order.
    //      if(po.MaximumDeliveryDuration__c != null){
    //          po.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(po.SLADeliveryEntryDate__c), (Integer)po.MaximumDeliveryDuration__c);
    //      }
    //      // Calculate the duration passed in the previous step
    //      if(po.SLAOrderedEntryDate__c != null){
    //          po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLADeliveryEntryDate__c);
    //      }
    //  }
    //  //system.debug('####### SLAOrderedDurationI: '+po.SLAOrderedDuration__c);
    // }

    /*
     * Status = Delivery Confirmed :
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     ***/
    /*public static void runSLAOnStatus_DeliveredConfirmed(PurchaseOrder__c po, String countryCode, String entity){

        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(po.SLADeliveryConfirmedEntryDate__c == null)
            po.SLADeliveryConfirmedEntryDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);

            // If the Delivery Entry Date is null (eg: the Distributor has not responded about the delivery), update the Ordered Duration
            if(po.SLADeliveryEntryDate__c == null){
                if(po.SLAOrderedEntryDate__c != null)
                po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLADeliveryConfirmedEntryDate__c);
            } else {
                // Calculate the duration passed in the previous step
                po.SLADeliveryDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLADeliveryEntryDate__c, po.SLADeliveryConfirmedEntryDate__c);
            }
        }
    }*/

    // public static void runSLAOnStatus_DeliveredConfirmed(PurchaseOrder__c po, Utils_BusinessDays businessDays, String entity){



    //  // Store the Entry Date in the new Status
    //  if(po.SLADeliveryConfirmedEntryDate__c == null)
    //      po.SLADeliveryConfirmedEntryDate__c = Datetime.now();

    //  if (businessDays != null) {
    //      //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);

    //      // If the Delivery Entry Date is null (eg: the Distributor has not responded about the delivery), update the Ordered Duration
    //      if(po.SLADeliveryEntryDate__c == null){
    //          if(po.SLAOrderedEntryDate__c != null)
    //          po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLADeliveryConfirmedEntryDate__c);
    //      } else {
    //          // Calculate the duration passed in the previous step
    //          po.SLADeliveryDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLADeliveryEntryDate__c, po.SLADeliveryConfirmedEntryDate__c);
    //      }
    //  }
    // }

    /*
     * Status = Closed :
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     ***/
    /*public static void runSLAOnStatus_Closed(PurchaseOrder__c po, String countryCode, String entity){
        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(po.SLAClosedEntryDate__c == null)
            po.SLAClosedEntryDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
            // Calculate the duration passed in the previous step
            // / 24 / 60 / 60 / 1000
            // Days/Hours/Min/second
            if(po.SLAQuotationDuration__c == null && po.SLAQuotationEntryDate__c != null){
                po.SLAQuotationDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAQuotationEntryDate__c, po.SLAClosedEntryDate__c);
            }
            if(po.SLAAcceptanceDuration__c == null && po.SLAAcceptanceEntryDate__c != null){
                po.SLAAcceptanceDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAAcceptanceEntryDate__c, po.SLAClosedEntryDate__c);
            }
            if(po.SLAOrderedDuration__c == null && po.SLAOrderedEntryDate__c != null){
                po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLAClosedEntryDate__c);
            }
            if(po.SLADeliveryDuration__c == null && po.SLADeliveryEntryDate__c != null){
                po.SLADeliveryDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLADeliveryEntryDate__c, po.SLAClosedEntryDate__c);
            }
        }
    }*/

    // public static void runSLAOnStatus_Closed(PurchaseOrder__c po, Utils_BusinessDays businessDays, String entity){
    //  // Get Informations based on the Country Code


    //  // Store the Entry Date in the new Status
    //  if(po.SLAClosedEntryDate__c == null)
    //      po.SLAClosedEntryDate__c = Datetime.now();

    //  if (businessDays != null) {
    //      //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
    //      // Calculate the duration passed in the previous step
    //      // / 24 / 60 / 60 / 1000
    //      // Days/Hours/Min/second
    //      if(po.SLAQuotationDuration__c == null && po.SLAQuotationEntryDate__c != null){
    //          po.SLAQuotationDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAQuotationEntryDate__c, po.SLAClosedEntryDate__c);
    //      }
    //      if(po.SLAAcceptanceDuration__c == null && po.SLAAcceptanceEntryDate__c != null){
    //          po.SLAAcceptanceDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAAcceptanceEntryDate__c, po.SLAClosedEntryDate__c);
    //      }
    //      if(po.SLAOrderedDuration__c == null && po.SLAOrderedEntryDate__c != null){
    //          po.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLAOrderedEntryDate__c, po.SLAClosedEntryDate__c);
    //      }
    //      if(po.SLADeliveryDuration__c == null && po.SLADeliveryEntryDate__c != null){
    //          po.SLADeliveryDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(po.SLADeliveryEntryDate__c, po.SLAClosedEntryDate__c);
    //      }
    //  }
    // }

    /*
     * Calculate the estimated delivery date based on Business Days
     ***/
    // ABT - 26-SEP-2016 - C-001480 - Commented as this function is not referenced. Line 350 and 376 was already commented

    //public static void calculateEstimatedDeliveryDateOnOrderLines(List<OrderLine__c> l_ols, Utils_BusinessDays businessDays, Datetime deliveryEntryDate){
    //  for(OrderLine__c ol: l_ols){
    //      //system.debug('######## CLA calculate estimated delivery date : status '+ol.DeliveryStatus__c);
    //      if(ol.ExpectedDeliveryDuration__c != null){
    //          ol.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(deliveryEntryDate), Integer.valueOf(ol.ExpectedDeliveryDuration__c));
    //      }
    //  }
    //}

    /*
     * Status = Responded or Issued:
     * - clear all Quotation SLA fields
     ***/
    public static void finishSLAProcess_Quotation(PurchaseOrder__c po){
        po.SLAQuotationLevel1__c = null;
        po.SLAQuotationLevel2__c = null;
        po.SLAQuotationLevel3__c = null;
    }



    // ----------------------------------- FOR NEW VERSION -----------------------------
     /*public static void runSLAOnStatus_Acceptance(PurchaseOrder__c purchaseOrder, Utils_BusinessDays businessDays)
     {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAAcceptanceEntryDate__c == null)
        {
            purchaseOrder.SLAAcceptanceEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAQuotationEntryDate__c != null)
            {
                purchaseOrder.SLAQuotationDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAQuotationEntryDate__c, purchaseOrder.SLAAcceptanceEntryDate__c);
            }
        }
    }commented vsu*/ 

     public static void runSLAOnStatus_Acceptance(PurchaseOrder__c purchaseOrder, BusinessHours businessDays)
     {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAAcceptanceEntryDate__c == null)
        {
            purchaseOrder.SLAAcceptanceEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAQuotationEntryDate__c != null)
            {
                purchaseOrder.SLAQuotationDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAQuotationEntryDate__c, purchaseOrder.SLAAcceptanceEntryDate__c,businessDays);
            
            }
        }
    }


    /*public static void runSLAOnStatus_Ordered(PurchaseOrder__c purchaseOrder, Utils_BusinessDays businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAOrderedEntryDate__c == null)
        {
            purchaseOrder.SLAOrderedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAAcceptanceEntryDate__c != null)
            {
                purchaseOrder.SLAAcceptanceDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAAcceptanceEntryDate__c, purchaseOrder.SLAOrderedEntryDate__c);
            }
        }
    }vsu commented*/

    public static void runSLAOnStatus_Ordered(PurchaseOrder__c purchaseOrder, BusinessHours businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAOrderedEntryDate__c == null)
        {
            purchaseOrder.SLAOrderedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAAcceptanceEntryDate__c != null)
            {
                purchaseOrder.SLAAcceptanceDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAAcceptanceEntryDate__c, purchaseOrder.SLAOrderedEntryDate__c,businessDays);
            
            }
        }
    }

    /*public static void runSLAOnStatus_Delivery(PurchaseOrder__c purchaseOrder, Utils_BusinessDays businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLADeliveryEntryDate__c == null)
        {
            purchaseOrder.SLADeliveryEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the estimated delivery date on Purchase order.
            if(purchaseOrder.MaximumDeliveryDuration__c != null)
            {
                //purchaseOrder.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(purchaseOrder.SLADeliveryEntryDate__c), (Integer) purchaseOrder.MaximumDeliveryDuration__c);
                purchaseOrder.EstimatedDeliveryDate__c = Date.valueOf(BusinessHours.add(businessDays.currBusinessHours.id,purchaseOrder.SLADeliveryEntryDate__c,(Integer) purchaseOrder.MaximumDeliveryDuration__c *24*60*60*1000L));

            }

            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAOrderedEntryDate__c != null)
            {
                purchaseOrder.SLAOrderedDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLADeliveryEntryDate__c);
            }
        }
    }vsu commented*/

    public static void runSLAOnStatus_Delivery(PurchaseOrder__c purchaseOrder, BusinessHours businessDays)
    {
        Datetime estimatedDeliveryDatetime;
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLADeliveryEntryDate__c == null)
        {
            purchaseOrder.SLADeliveryEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the estimated delivery date on Purchase order.
            //AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
            if(purchaseOrder.MaxDeliveryDuration__c != null)
            {
                //AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
                estimatedDeliveryDatetime = BusinessHours.add(businessDays.id,purchaseOrder.SLADeliveryEntryDate__c,(Integer) purchaseOrder.MaxDeliveryDuration__c *10*60*60*1000L);
                purchaseOrder.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());

            }

            // Calculate the duration passed in the previous step
            if(purchaseOrder.SLAOrderedEntryDate__c != null)
            {
                purchaseOrder.SLAOrderedDuration__c =  ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLADeliveryEntryDate__c,businessDays);
            }
        }
    }

    ///////////////////////////////////////////////////////////////////
    

    /*public static void runSLAOnStatus_DeliveredConfirmed(PurchaseOrder__c purchaseOrder, Utils_BusinessDays businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLADeliveryConfirmedEntryDate__c == null)
        {
            purchaseOrder.SLADeliveryConfirmedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // If the Delivery Entry Date is null (eg: the Distributor has not responded about the delivery), update the Ordered Duration
            if(purchaseOrder.SLADeliveryEntryDate__c == null)
            {
                if(purchaseOrder.SLAOrderedEntryDate__c != null)
                {
                    purchaseOrder.SLAOrderedDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLADeliveryConfirmedEntryDate__c);
                }
            } 
            else 
            {
                // Calculate the duration passed in the previous step
                purchaseOrder.SLADeliveryDuration__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLADeliveryEntryDate__c, purchaseOrder.SLADeliveryConfirmedEntryDate__c);
            }
        }
    }vsu commented*/

    public static void runSLAOnStatus_DeliveredConfirmed(PurchaseOrder__c purchaseOrder, BusinessHours businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLADeliveryConfirmedEntryDate__c == null)
        {
            purchaseOrder.SLADeliveryConfirmedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // If the Delivery Entry Date is null (eg: the Distributor has not responded about the delivery), update the Ordered Duration
            if(purchaseOrder.SLADeliveryEntryDate__c == null)
            {
                if(purchaseOrder.SLAOrderedEntryDate__c != null)
                {
                    purchaseOrder.SLAOrderedDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLADeliveryConfirmedEntryDate__c,businessDays);
                }
            } 
            else 
            {
                // Calculate the duration passed in the previous step
                purchaseOrder.SLADeliveryDuration__c =  ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLADeliveryEntryDate__c, purchaseOrder.SLADeliveryConfirmedEntryDate__c,businessDays);
            
            }
        }
    }

    /*public static void runSLAOnStatus_Closed(PurchaseOrder__c purchaseOrder, Utils_BusinessDays businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAClosedEntryDate__c == null)
        {
            purchaseOrder.SLAClosedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            // / 24 / 60 / 60 / 1000
            // Days/Hours/Min/second

            if(purchaseOrder.SLAQuotationDuration__c == null && purchaseOrder.SLAQuotationEntryDate__c != null)
            {
                purchaseOrder.SLAQuotationDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAQuotationEntryDate__c, purchaseOrder.SLAClosedEntryDate__c);
            }
            
            if(purchaseOrder.SLAAcceptanceDuration__c == null && purchaseOrder.SLAAcceptanceEntryDate__c != null)
            {
                purchaseOrder.SLAAcceptanceDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAAcceptanceEntryDate__c, purchaseOrder.SLAClosedEntryDate__c);
            }
            
            if(purchaseOrder.SLAOrderedDuration__c == null && purchaseOrder.SLAOrderedEntryDate__c != null)
            {
                purchaseOrder.SLAOrderedDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLAClosedEntryDate__c);
            }
            
            if(purchaseOrder.SLADeliveryDuration__c == null && purchaseOrder.SLADeliveryEntryDate__c != null)
            {
                purchaseOrder.SLADeliveryDuration__c = businessDays.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLADeliveryEntryDate__c, purchaseOrder.SLAClosedEntryDate__c);
            }
        }
    }vsu commented*/

    public static void runSLAOnStatus_Closed(PurchaseOrder__c purchaseOrder, BusinessHours businessDays)
    {
        // Store the Entry Date in the new Status
        if(purchaseOrder.SLAClosedEntryDate__c == null)
        {
            purchaseOrder.SLAClosedEntryDate__c = System.now();
        }

        if (businessDays != null)
        {
            // Calculate the duration passed in the previous step
            // / 24 / 60 / 60 / 1000
            // Days/Hours/Min/second

            if(purchaseOrder.SLAQuotationDuration__c == null && purchaseOrder.SLAQuotationEntryDate__c != null)
            {
                purchaseOrder.SLAQuotationDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAQuotationEntryDate__c, purchaseOrder.SLAClosedEntryDate__c,businessDays);
            }
            
            if(purchaseOrder.SLAAcceptanceDuration__c == null && purchaseOrder.SLAAcceptanceEntryDate__c != null)
            {
                purchaseOrder.SLAAcceptanceDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAAcceptanceEntryDate__c, purchaseOrder.SLAClosedEntryDate__c,businessDays);
            }
            
            if(purchaseOrder.SLAOrderedDuration__c == null && purchaseOrder.SLAOrderedEntryDate__c != null)
            {
                purchaseOrder.SLAOrderedDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLAOrderedEntryDate__c, purchaseOrder.SLAClosedEntryDate__c,businessDays);
            }
            
            if(purchaseOrder.SLADeliveryDuration__c == null && purchaseOrder.SLADeliveryEntryDate__c != null)
            {
                purchaseOrder.SLADeliveryDuration__c = ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(purchaseOrder.SLADeliveryEntryDate__c, purchaseOrder.SLAClosedEntryDate__c,businessDays);
            }
        }
    }
}