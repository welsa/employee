/*************************************************************************************
Class Name - Utils_ManageCase
Version - 1.0
Created Date - 15 JUN 2015
Function - Class to manage the Case__c.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      15/06/2015  Original Version
* Cecile L      19/10/2015  C-001349: Add handle of new field Active on CustomSettings. If Active is FALSE, don't create the case.
* Ashwina S     20/01/2016  C-001452: Problème logique case "appropriation" vs "résolution
* Ashwina S     25/01/2016  C-001453: Nouveaux cases pour la gestion des factures distributeurs
* Dourga/Shamina 14/12/2015 C-001386 - new business hours mgt
* Dourga U       29/08/2016 C-001712 - Error un Production using ASPISCreateCase flow
* Vaynee S      28/11/2017  C-002008 - Businesshours optimisation
**************************************************************************************************************************************/
public class Utils_ManageCaseCustom {
    /*################################################################################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##################################################################################################################################*/
    private final static String STATUSCREATION = 'NEW';
    private final Static String COUNTRYCODEDEFAULT = 'ALL';
    private final Static String DEFAULTCONFIG = '-DEFAULT';

    // * days	* hours	* minutes	* seconds
    // 	* 24 	 * 60 	 * 60 		 * 1000L
    private final Static LONG DURATIONINHOURS = 60 * 60 * 1000L;
    private final Static LONG DURATIONINMINUTES = 60 * 1000L;

    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/

    /*
     * Get the type of Case we have to create on the COuntry Code in parameters. (The Queue is set in the trigger Case Before Insert)
     ***/
    public static CaseDetailsProcessMapping__c getConfigurationDataForCase(String objCode, String countryCode, String csProcessName){
        CaseDetailsProcessMapping__c configCaseDetails;
        //SYstem.debug('###### CLA '+countryCode + objCode + csProcessName);
        if(countryCode != null && CaseDetailsProcessMapping__c.getAll().containsKey(countryCode + objCode + csProcessName))
            configCaseDetails = CaseDetailsProcessMapping__c.getAll().get(countryCode + objCode + csProcessName);
        else
            configCaseDetails = CaseDetailsProcessMapping__c.getAll().get(COUNTRYCODEDEFAULT + objCode + csProcessName);

        return configCaseDetails;
    }

    /*
     * Create a new Case with informations from the Custom Setting "CaseDetailsProcessMapping__c".
     ***/
    public static Case__c createNewCaseWithPrepopulatedInformations(String objCode, String countryCode, Id accountId, Id assessmentId, Id poId, Id soId, String comment, Id userId, String csProcessName){
        Case__c newCase;


        CaseDetailsProcessMapping__c configCaseDetails = getConfigurationDataForCase(objCode, countryCode, csProcessName);
		//System.Debug('///// #configCaseDetails: '+configCaseDetails);

        // Find specific informations based on the country code
		//System.Debug('/// #countryCode: '+countryCode);
		//System.Debug('/// #CountryCodeInformationsMapping__c.getAll(): '+CountryCodeInformationsMapping__c.getAll());
        CountryCodeInformationsMapping__c configCountryCodeInfo = CountryCodeInformationsMapping__c.getAll().get(countryCode);
        //System.Debug('#UconfigCountryCodeInfo:'+configCountryCodeInfo);

        // If we find the config and the field Active is checked, create the Case
        if(configCaseDetails != null && configCaseDetails.Active__c){
            newCase = new Case__c(
                Account_Name__c = accountId,
                Assesment__c = assessmentId,
                Purchase_order__c = poId,
                Sales_order__c = soId,
                SubmittedBy__c = userId,
                Comment__c = comment,
                Case_Reason__c = configCaseDetails.Reason__c,
                Description__c = configCaseDetails.Description__c,
                CountryCode__c = countryCode,
                Origin__c = configCaseDetails.Origin__c,
                Internal_Comments__c = configCaseDetails.Internal_Comments__c,
                //    OwnerId = configQueue.Queue_ID__c,
                Due_Date__c = calculateDueDateBasedOnCustomSettings(configCaseDetails, configCountryCodeInfo, countryCode),
                Priority__c = configCaseDetails.Priority__c,
                Status__c = STATUSCREATION,
                Subject__c = configCaseDetails.Subject__c,
                Type__c = configCaseDetails.Type__c,
                TECH_AutomaticCreationFromProcess__c = objCode + csProcessName
            );
        }

        return newCase;
    }

    /*
	* VSU commneted: Calculate the Due Date based on configuration of Case and Business Hours.
	***/
    /*public static DateTime calculateDueDateBasedOnCustomSettings(CaseDetailsProcessMapping__c configCase, CountryCodeInformationsMapping__c configCountryCodeInfo, String countryCode){
        Datetime dueDate;
        // Update Due_Date with business hours
        if(configCountryCodeInfo != null){
            // Add Business days to the date
            if(configCase.Due_Date_Unity__c == 'D'){
				//(Dourga 14/12/2015 case 1386)
                //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
				Utils_BusinessDays businessDays = new Utils_BusinessDays(configCountryCodeInfo.name);
                dueDate = businessDays.getEndOfBusinessDayFromDate(Date.today(), (Integer)configCase.Due_Date_Duration__c);
            }
            // Add hours to the Date
            if(configCase.Due_Date_Unity__c == 'H'){
                dueDate = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, Datetime.now(), (Integer)configCase.Due_Date_Duration__c * DURATIONINHOURS);
            }
            // Add minutes to the Date
            if(configCase.Due_Date_Unity__c == 'M'){
                dueDate = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, Datetime.now(), (Integer)configCase.Due_Date_Duration__c * DURATIONINMINUTES);
            }
        } else{
            dueDate = DateTime.now() + (Integer)configCase.Due_Date_Duration__c;
        }
        return dueDate;
    }*/
    //vsu removed check for days and minutes
    public static DateTime calculateDueDateBasedOnCustomSettings(CaseDetailsProcessMapping__c configCase, CountryCodeInformationsMapping__c configCountryCodeInfo, String countryCode){
        Datetime dueDate;
        // Update Due_Date with business hours
        if(configCountryCodeInfo != null){           
            // Add Due_Date_Duration__c in hours to the Date given 
            dueDate = BusinessHours.add((Id)configCountryCodeInfo.BusinessHoursID__c, Datetime.now(), (Integer)configCase.Due_Date_Duration__c * DURATIONINHOURS);
           
        } else{
            dueDate = DateTime.now() + (Integer)configCase.Due_Date_Duration__c;
        }
        return dueDate;
    }

    /*
     * Status = Assigned : Entering into the Resolution process.
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     *  - Calculate the SLA by using the Rules Engines.
     ***/
    public static void runSLAOnStatus_Assigned(Case__c currCase, String countryCode){
        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(currCase.SLAResolutionDate__c == null)
            currCase.SLAResolutionDate__c = Datetime.now();

        if (configCountryCodeInfo != null) {
            // Calculate the duration passed in the previous step
            if(currCase.SLAAssignationDate__c != null){
                //Shamina M: case 1386
                Businesshours businessDays = ASPISConstants.getBusinessHours(configCountryCodeInfo.Name);

                //vsu commentedUtils_BusinessDays businessDays = new Utils_BusinessDays(configCountryCodeInfo.Name);
                //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
                currCase.SLAAssignationDurationMinutes__c =  ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(currCase.SLAAssignationDate__c, currCase.SLAResolutionDate__c ,businessDays);
            }
        }
    }

    /*
     * Status = Closed : End of process.
     *  - STore the current date inside the process entry date.
     *  - Calculate the duration of the previous process.
     ***/
    public static void runSLAOnStatus_Closed(Case__c currCase, String countryCode){
        // Get Informations based on the Country Code
        CountryCodeInformationsMapping__c configCountryCodeInfo;
        if(CountryCodeInformationsMapping__c.getall().containsKey(countryCode))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        // Store the Entry Date in the new Status
        if(currCase.SLAClosedEntryDate__c == null)
            currCase.SLAClosedEntryDate__c = Datetime.now();

		if (configCountryCodeInfo != null) {
            // Calculate the duration passed in the previous step
			// ASE: 20160120: Case C-001452 Problème logique case "appropriation" vs "résolution"
            if(currCase.SLAResolutionDate__c == null){
				currCase.SLAResolutionDate__c = currCase.SLAAssignationDate__c;
			}
            //Shamina M: case 1386
            BusinessHours businessDays = ASPISConstants.getBusinessHours(configCountryCodeInfo.Name);
            //vsu commented Utils_BusinessDays businessDays = new Utils_BusinessDays(configCountryCodeInfo.Name);
            //Utils_BusinessDays businessDays = new Utils_BusinessDays((Id)configCountryCodeInfo.BusinessHoursID__c);
            //vsu commented currCase.SLAResolutionDurationMinutes__c =  businessDays.calculateDifferenceBetweenBusinessDateInMinutes(currCase.SLAResolutionDate__c, currCase.SLAClosedEntryDate__c);
            currCase.SLAResolutionDurationMinutes__c =  ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(currCase.SLAResolutionDate__c, currCase.SLAClosedEntryDate__c, businessDays);
        }
    }

    // ASE: 25/01/2016 - C-001453
    @InvocableMethod
    public static void createNewCase(List<ASPISProcessBuilderGlobalVariables.variableWrapper> variableList){
        System.debug('########### START of createNewCase');
        List<Case__c> caseList = new List<Case__c>();

        for(ASPISProcessBuilderGlobalVariables.variableWrapper vw : variableList)
        {
            CaseDetailsProcessMapping__c configCaseDetails = getConfigurationDataForCase(vw.objCode, vw.countryCode, vw.csProcessName);

            // Find specific informations based on the country code
            CountryCodeInformationsMapping__c configCountryCodeInfo = CountryCodeInformationsMapping__c.getAll().get(vw.countryCode);

            // If we find the config and the field Active is checked, create the Case
            if(configCaseDetails != null && configCaseDetails.Active__c){
                Case__c newCase = new Case__c(
                    Account_Name__c = vw.accountId,
                    Assesment__c = vw.assessmentId,
                    Purchase_order__c = vw.poId,
                    Sales_order__c = vw.soId,
                    SubmittedBy__c = vw.userId,
                    Comment__c = vw.comment,
                    Case_Reason__c = configCaseDetails.Reason__c,
                    Description__c = configCaseDetails.Description__c,
                    CountryCode__c = vw.countryCode,
                    Origin__c = configCaseDetails.Origin__c,
                    Internal_Comments__c = configCaseDetails.Internal_Comments__c,
                    //    OwnerId = configQueue.Queue_ID__c,
                    Due_Date__c = calculateDueDateBasedOnCustomSettings(configCaseDetails, configCountryCodeInfo, vw.countryCode),
                    Priority__c = configCaseDetails.Priority__c,
                    Status__c = STATUSCREATION,
                    Subject__c = configCaseDetails.Subject__c,
                    Type__c = configCaseDetails.Type__c,
                    TECH_AutomaticCreationFromProcess__c = vw.objCode + vw.csProcessName
                );

                caseList.add(newCase);
            }
        }

        if(caseList.size() > 0){
            insert caseList;
        }

        System.debug('########### END of createNewCase');
    }

    // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded)
    @future
    public static void createNewCaseAsync(Set<Id> invoiceIdSet)
    {
        createNewCase(invoiceIdSet);
    }

    public static void createNewCase(Set<Id> invoiceIdSet) {
        List<ASPISProcessBuilderGlobalVariables.variableWrapper> wrapperList = new List<ASPISProcessBuilderGlobalVariables.variableWrapper>();

        // convert Invoice__c to ASPISProcessBuilderGlobalVariables.variableWrapper (to reuse the existing method)
        //if (invoiceList != null) {
        ASPISProcessBuilderGlobalVariables.variableWrapper wrapper;
        for (Invoice__c invoice : [SELECT Assessment__c, PurchaseOrder__c, PurchaseOrder__r.Distributor__c, TechCountryCode__c FROM Invoice__c WHERE id IN :invoiceIdSet]) {
            wrapper = new ASPISProcessBuilderGlobalVariables.variableWrapper();
            wrapper.assessmentId = invoice.Assessment__c;
            wrapper.accountId = invoice.PurchaseOrder__r.Distributor__c;
            wrapper.countryCode = invoice.TechCountryCode__c;
            wrapper.csProcessName = '-OrderNotPaid';
            wrapper.objCode = '-INV';
            wrapper.poId = invoice.PurchaseOrder__c;
            wrapper.userId = UserInfo.getUserId();

            wrapperList.add(wrapper);
        }
        //}

        createNewCase(wrapperList);
    }
}