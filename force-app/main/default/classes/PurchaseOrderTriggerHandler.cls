/*
----------------------------------------------------------------------
-- - Name          : PurchaseOrderTriggerHandler
-- - Author        : ABT
-- - Description   : Handler for the trigger PurchaseOrderTrigger
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-OCT-2016  ABT     1.0    Initial version
-- 08-NOV-2016  DUN     1.1    case 1669 
-- 26-APR-2017  DUN     1.2    case 1904
-- 21-JUN-2017  DUN     1.3    trello no: 207 - SLA for distributors
---------------------------------------------------------------------- 
-- Flow of PurchaseOrderTriggerHandler:
-- PURCHASE ORDER
--  
-- - BEFORE INSERT
-- 
--  -> Capture the assessment ids of the Purchase Order -> update the purchase order fields with their coresponding values in their Assessment
--  -> Check if the Distributor__c is not null -> Populate the DistributorContact__c
--  -> if Purchase Order inserted is in DRAFTQUOTE -> set the SLAQuotationEntryDate__c using the master rule
--  -> if the checkbox Manual_Creation__c is checked -> set the assessment to SOURCED
-- 
-- 
-- - AFTER INSERT
-- 
--  -> Group Purchase Order according to their Assessment -> Create the order lines for the Purchase Orders
--  -> if status is (CANCELED OR REJECTED) AND Reason__c is not "CanceledByBS" -> Update the assessment to CANCELED with Reason "NoPurchaseOrderAvailable" if the assessment does not contain any other status than CANCELED or REJECTED
--  -> if PrerequisiteOrder__c is not null and BodyShopOrderNumber__c != null -> Update the Sales Order BodyshopOrderNumber__c with all the Purchase Order BodyShopOrderNumber__c concatenated with ;
-- 
-- 
-- - BEFORE UPDATE
-- 
--  -> if distributor__c has changed and the distributor__c is not null -> populate the DistributorContact__c
--  -> if status has changed    -> if status is RESPONDED or ISSUED -- runSLAOnStatus_Acceptance and finishSLAProcess_Quotation
--                              -> if status is ORDERED -- runSLAOnStatus_Ordered
--                              -> if status is INDELIVERY -- runSLAOnStatus_Delivery
--                              -> if status is DELIVEREDCONFIRMED -- runSLAOnStatus_DeliveredConfirmed
--                                                                 -- Capture the PurchaseOrder to calculate the TotalExpectedAmount__c
--                              -> if status is CANCELED or REJECTED -- runSLAOnStatus_Closed
--                              -> Capture the PreviousStatus__c
--                              -> if status is DRAFTQUOTE or ISSUED or RESPONDED -- Set recordtype DRAFTQUOTE
--                              -> if status is ORDERED -- Set recordtype Ordered
--                              -> if status is CANCELED or REJECTED -- Set recordtype Eliminated
--                              -> for remaining status -- Set recordtype INDELIVERY
--                              
--                      
-- - AFTER UPDATE
-- 
--  -> if status has changed -> if status is DELIVEREDCONFIRMED and PrerequisiteOrder__c != null -- Capture the PrerequisiteOrder__c to executeServiceOrderDeliveryConfirmed
--                           -> if new status is CANCELED and old status is ISSUED -- Create Case
--                           -> if new status is CANCELED and Reason__c is UNSUPPLIEDQUOTE -- Create Case
--                           -> if status is CANCELED   -- if previous status was DRAFTQUOTE set all order lines to CANCELED
--                                                      -- else if previous status was ISSUED set Order Lines with Suppliable = 'YES' to CANCELED
--                                                      -- else set Order Lines with Suppliable = 'YES' and AcceptedCheck__c = true to CANCELED
--                           -> if status is INDELIVERY -- if Order Line is AcceptedCheck__c = true -- Set OrderLine DeliveryStatus to INDELIVERY
--                                                      -- if purchase order SLADeliveryEntryDate__c is not null and order line ExpectedDeliveryDuration__c is not null -- Update the EstimatedDeliveryDate__c
--                           -> if status is (REJECTED or CANCELED) AND Reason__c is not CanceledByBS -- Update the assessment to CANCELED with Reason "NoPurchaseOrderAvailable" if the assessment does not contain any other status than CANCELED or REJECTED
--  -> if DelayedCaseCreated__c has changed and DelayedCaseCreated__c is true -> Create Case
--  -> if InvoiceStatusNotValidated__c has changed and InvoiceStatusNotValidated__c is true and Status is DELIVEREDCONFIRMED -> Create Case
--  -> if ASMarginTooLowCaseCreated__c has changed and ASMarginTooLowCaseCreated__c is true -> Create Case
--  -> if ASDiscountLowCaseCreated__c has changed and ASDiscountLowCaseCreated__c is true -> Create Case
--  -> if DistributorPriceHigger__c has changed and DistributorPriceHigger__c is true -> Create Case
--  -> if TECHSLAQuotationIsLevel2__c has changed and TECHSLAQuotationIsLevel2__c is true -> Create Case
--  -> if InvoiceStatus__c has changed and InvoiceStatus__c = 'VALIDATED' -- Set the invoices of the PurchaseOrder to PAYABLE
--  -> if InternalComment__c has changed and PrerequisiteOrder__c is not null -- Capture the PO to sync the internal comment
--  -> if PrerequisiteOrder__c or BodyShopOrderNumber__c has changed and PrerequisiteOrder__c is not null and BodyShopOrderNumber__c != null  -> Update the Sales Order BodyshopOrderNumber__c with all the Purchase Order BodyShopOrderNumber__c concatenated with ;
----------------------------------------------------------------------
-- Previous Class History
----------------------------------------------------------------------
-- Developer    Date        Description
-- ----------   ----------  -----------------------
-- Joao Dias    30/03/2015  Original Version
-- Yudish R     28/04/2015  OnAfterInsert: share parent Account(Distributor) with respective
--                          Distributor Group
-- Cecile L     30/04/2015  OnAfterInsert: Autofollow the record for the local ASPIS admin, identified by his role belongs to the country
-- Yudish R     18/05/2015  Remove codes (Change ApexSharing from Offering and Sourcing processes to Account creation)
-- Joao Dias    22/05/2015  Adding Canceled status supplementar information for timeline purposes
-- Dourga U     11/06/2015  Adding code for creation of orderline in after insert
-- Cecile L     15/06/2015  Globalize the creation of the Case in a separate class
-- Cecile L     22/06/2015  Adding the update of Record Type when pass to the In Delivery status.
-- Cecile L     23/06/2015  Modify the field CountryCode, as we have to used the field on Assessment instead of using the field on Purchase Order.
-- Cecile L     25/06/2015  Adding the update of Record Type b00sed on status.
-- Dourga U     15/06/2015  Added creation of case when status is UNSUPPLIEDQUOTE
-- Cecile L     16/07/2015  Added update of the status on all related Invoices if the invoice status on PO is validated.
-- Cecile L     17/07/2015  Added creation of case if the invoice status on PO is not validated.
-- Cecile L     20/07/2015  Added status NOTSELECTED for the automatic update of the record type Eliminated.
-- Cecile L     19/08/2015  Autopopulate 5 fields(VIN Number, Plate Number, Brand, Assessment Name, Assessment Number)from assessment on before insert.
-- Dourga U     20/08/2015  Added code to create log in catch part
-- Cecile L     02/09/2015  Create Case when ASMarginTooLowCaseCreated__c is checked.
-- Cecile L     15/09/2015  Added check that the old status is different than the new one, before executing the ASPISServiceBroker on status "DELIVERYCONFIRMED", to avoid "Too Many SOQL" error.
-- Dourga U     01/09/2015  Added fields when creating orderlines
-- Dourga U     10/09/2015  case C-001241
-- Ashwina S    13/10/2015  C-001272
-- CÃ©cile L     16/10/2015  C-001345: Add a filter in the PartList query to skip the recordType Labour.
-- Ashwina S    16/10/2015  C-001275
-- Dourga U     19/10/2015  C-001305: Created case when BSLowCaseCreated__c is checked
-- Dourga U     17/11/2015  C-001392: Duplicate case created when amount is not correct
-- Immo S       17/11/2015  Changed the logic for getting business hours and holidays to avoid SOQL queries governor limit
-- Dourga U     19/11/2015  C-001385: Created case when DistributorPriceHigger__c is checked
-- Shamina M    10/02/2016  Case C-001479 sync field InternalComment__c between SO and PO
-- Dourga U     12/02/2016  C-001522: Clarifications sur les rejets et annulations des commandes
-- Shamina M    16/02/2016  C-001518: Removed unnecessary debug logs
-- Dourga U     04/03/2016  C-001548: Add Bodyshop Order Number on SO and update Webservices
-- Ashwina S    15/03/2015  insert orderlines with quantity 0 was failing whole list. used Database.insert for partial success.
-- Dourga U     12/05/2016  C-001615: New VF: Display possible substitutions for selection(added field SelectedByBS__c to partlist selection in method insertOrderLines)
-- Dourga U     23/05/2016  C-001566: Batch status on Invoices only for Distributor
-- Dourga U     29/06/2016  C-001651: Bulkify ASPISServiceOrderDeliveryConfirmed
-- Abdool M     11/07/2017  Set DE PO/SO to CLOSEDOK for Agency Mode
-- Abdool M     14/08/2017  Bypassing Orderlines Creation during restcreateassessement
-- Dourga U     13/12/2017  C-001998 : Agency Mode
-- Dourga U     04/01/2018  C-002135 : Agency Mode V2
-- Vaynee S     28/11/2017  C-002008: Businesshours optimisation
-- Vaynee S     14/12/2017  C-001977: Email R4 DE
-- Dourga U     20/03/2018  C-002301 : Estimated Delivery Date Wrong February
-- Ashwina S    18/04/2018  C-002477: ASP- Prefix
-- Dourga U     02/05/2018  C-002488 - Fill field EncodedId__c and added check not to create Orderlines 
-- Ashwina S    08/05/2018  C-002278 - FR - New Distributor PSA 
-- Vaynee S     24/05/2018  C-002214 : Invoices are not duplicate in some cases in Spain 
-- Dourga       14/06/2018  C-002580 : Distributor V2 Price/Marging/Discount (when null, consider as 0 instead ) 
-- Ashwina S    09/07/2018  C-002659 : Prices & Part Type to be sent to Coler
-- Dourga       08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
-- Dourga       08/08/2018  C-001851 - Communication between Supplier vs B/S
-- Dourga       18/09/2018  C-001895 : Spare Part Recovery 
-- Abdool       05/10/2018  C-001837 : Added condition so that classic sourcing is based on supppliable category whereas
                                       direct order soucing is based on type
-- Abdool       01/11/2018  C-002781 : Migrate Spain to R4
--                                   : New Distributor Notification Email Template for ES in R4
   Welsa C      16/11/2018  C-002895 : Numéro de commande dupliqué
   Welsa C      03/12/2018  C-002877 : Erreur Validation Rule sur Champ Suppliable de Orderline
   Welsa C      02/05/2019  C-003214 : PO Belge pas bien assigné aux distributeur Dummy pour la multisourcing
-- Ruksaar L    06/02/2020  C-003536 : New Billing Process for SPAIN
   Welsa C      13/04/2020  C-003707 : When call CreateAssessment service to generate the POs on the R4 Assessment PDF empty
   Welsa C      08/06/2020  C-003744 : Cancelation of one of two POs in an order also momentarily canceled the second PO and created 
                                       several invoices and Credit notes in SO
   Ruksaar L    22/06/2020  C-003699 : IG - SLAs and Emails
-- Ruksaar L    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS 
-- Welsa C      19/05/2021  C-004160 Create two new Family and Brand fields in Order Lines
-- Neha P       04/05/2022  C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned
**********************************************************************
*/
public without sharing class PurchaseOrderTriggerHandler 
{
    // Map Storing th country and its Business Days
    //VSU Commented 29/11/17 Map<String, BusinessHours> mapCountryCodeBusinessDays;
    //Map<String, Utils_BusinessDays> mapCountryCodeBusinessDays;
    // Map Storing country code
    Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMappings;

    //public static list<PurchaseOrder__c> updatedPOList = new list<PurchaseOrder__c>();

    public PurchaseOrderTriggerHandler()
    {
        mapCountryCodeMappings = CountryCodeInformationsMapping__c.getAll();
        //mapCountryCodeBusinessDays = new Map<String, Utils_BusinessDays>();
        // vsu commented 29/11/2017 mapCountryCodeBusinessDays = new Map<String, BusinessHours>();

        /*vsu commented 29/11/2017 if(mapCountryCodeMappings != null && mapCountryCodeMappings.size() > 0)
        {
            // Loop in all Country Code Mapping
            for(CountryCodeInformationsMapping__c currentCountryCodeMapping : mapCountryCodeMappings.values())
            {
                 //Utils_BusinessDays currentCountryBusinessDays = new Utils_BusinessDays(currentCountryCodeMapping.Name);
                BusinessHours currentCountryBusinessDays = ASPISConstants.getBusinessHours(currentCountryCodeMapping.Name);

                mapCountryCodeBusinessDays.put(currentCountryCodeMapping.Name, currentCountryBusinessDays);
            }
        }*/
    }

    public void onBeforeInsert(List<PurchaseOrder__c> newPurchaseOrderList)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - onBeforeInsert --------------------------');

        // Set of assessment id that needs to be queried to poupulate fields on purchase orders
        Set<Id> assessmentIdSet                                 = new Set<Id>();
        // List of purchase order that has an assessment and needs to have their fields updated
        List<PurchaseOrder__c> purchaseOrderWithAssessmentList  = new List<PurchaseOrder__c>();
        // List of purchase order that need to have their DistributorContact__c and Rebate populated
        List<PurchaseOrder__c> ap32PurchaseOrderList            = new List<PurchaseOrder__c>();
        // Set of distributor account that needs to be retrieved in AP32
        Set<Id> ap32AccountIdSet                                = new Set<Id>();
        // List of draftquote purchase order that need to have their sla initiated
        List<PurchaseOrder__c> ap05PurchaseOrderList            = new List<PurchaseOrder__c>();
        // Set of entity rules that needs to be fetched for the master rule in the process of instantation of SLA
        Set<String> ap05EntityRulesSet                          = new Set<String>();
        // List of draftquote purchase order that need to have their sla initiated
        List<PurchaseOrder__c> ap05OrderPurchaseOrderList            = new List<PurchaseOrder__c>();
        // Set of entity rules that needs to be fetched for the master rule in the process of instantation of SLA
        Set<String> ap05OrderEntityRulesSet                          = new Set<String>();
        // Map of assessments that need to be updated
        Map<Id, Assessment__c> mapAssessmentToUpdate            = new Map<Id, Assessment__c>();

        //DUN 04/01/2018  C-002135 agency Mode V2
        Set<Id> distAgencyIdSet                                               = new Set<Id>();
        map<Id,List<PurchaseOrder__c>> mapAssIdlistAgencyModePurchaseOrders   = new map<Id,List<PurchaseOrder__c>>();

        // Loop to capture all the information required from the purchase orders
        for(PurchaseOrder__c newPurchaseOrder : newPurchaseOrderList)
        {
            // check if assessment is not null
            if(newPurchaseOrder.Assessment__c != null)
            {
                // We need to collect all the assessment id of the Purchase Order in order to retrive the fields of those assessment
                assessmentIdSet.add(newPurchaseOrder.Assessment__c);
                purchaseOrderWithAssessmentList.add(newPurchaseOrder);

                // check if the checkbox Manual_Creation__c of the purchase order is checked
                if( newPurchaseOrder.Manual_Creation__c == true)
                {
                    // sets the assessment to SOURCED to launch the offering process
                    mapAssessmentToUpdate.put(newPurchaseOrder.Assessment__c, new Assessment__c(Id          = newPurchaseOrder.Assessment__c,
                                                                                                Status__c   = ASPISConstants.ASSESS_STATUS_SOURCED));
                }
            }

            // check if the field Distributor__c is not null
            if(newPurchaseOrder.Distributor__c != null)
            {
                ap32PurchaseOrderList.add(newPurchaseOrder);
                ap32AccountIdSet.add(newPurchaseOrder.Distributor__c);
            }

            //DUN 04/01/2018  C-002135 agency Mode V2
            if(newPurchaseOrder.Assessment__c != null && 
               newPurchaseOrder.Distributor__c != null)
            {
                if(!mapAssIdlistAgencyModePurchaseOrders.containsKey(newPurchaseOrder.Assessment__c)){
                    mapAssIdlistAgencyModePurchaseOrders.put(newPurchaseOrder.Assessment__c,new list<PurchaseOrder__c>{newPurchaseOrder});
                }
                else{
                    mapAssIdlistAgencyModePurchaseOrders.get(newPurchaseOrder.Assessment__c).add(newPurchaseOrder);
                }
                distAgencyIdSet.add(newPurchaseOrder.Distributor__c);
            }

            //DUN 21/06/2017 commented code trello 207
            // Check if the Purchase Order is in DRAFTQUOTE
            //if(newPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            //{
            //    ap05PurchaseOrderList.add(newPurchaseOrder);

            //    if(newPurchaseOrder.TECH_AssessmentEntityRules__c != null)
            //    {
            //        ap05EntityRulesSet.add(newPurchaseOrder.TECH_AssessmentEntityRules__c);
            //    }
            //}
        }

        if(assessmentIdSet.size() > 0)
        {
            // Retrieving the assessments
            Map<Id, Assessment__c> mapAssessmentQueried = new Map<Id, Assessment__c>([  SELECT  Id, Name, AssessmentNumber__c, VINNumber__c, Manufacturer__c, OrderOrigin__c, PlateNumber2__c, RecordType.DeveloperName
                                                                                        FROM    Assessment__c
                                                                                        WHERE   Id IN: assessmentIdSet]);

            // Loop in the newPurchaseOrdersWithAssessmentList to populate the fields
            for(PurchaseOrder__c currentPurchaseOrder : purchaseOrderWithAssessmentList)
            {
                if(mapAssessmentQueried.containsKey(currentPurchaseOrder.Assessment__c))
                {
                    Assessment__c currentAssessment = mapAssessmentQueried.get(currentPurchaseOrder.Assessment__c);

                    // Setting the assessment values in the Purchase Order
                    currentPurchaseOrder.AssessmentName2__c     = currentAssessment.Name;
                    currentPurchaseOrder.AssessmentNumber__c    = currentAssessment.AssessmentNumber__c;
                    currentPurchaseOrder.VINNumber__c           = currentAssessment.VINNumber__c;
                    currentPurchaseOrder.Brand__c               = currentAssessment.Manufacturer__c;
                    currentPurchaseOrder.PlateNumber__c         = currentAssessment.PlateNumber2__c;

                    if (currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
                    {
                        currentPurchaseOrder.POProcessVersion__c = 'Direct PO';
                    }
                    else if (currentAssessment.RecordType.DeveloperName == 'NewAssessment')
                    {
                        currentPurchaseOrder.POProcessVersion__c = 'Legacy PO';
                    }
                    //DUN 21/06/2017 move code here trello 207
                    // Check if the Purchase Order is in DRAFTQUOTE
                     if((currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE || currentPurchaseOrder.Status__c == 'PREDRAFTQUOTE')
                         && Utils_SLARulesEngine.isSLaAllowed(currentPurchaseOrder.TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                    {
                        
                        if(currentAssessment.OrderOrigin__c == 'Order' && currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
                        {
                            ap05OrderPurchaseOrderList.add(currentPurchaseOrder);

                            if(currentPurchaseOrder.TECH_AssessmentEntityRules__c != null)
                            {
                                ap05OrderEntityRulesSet.add(currentPurchaseOrder.TECH_AssessmentEntityRules__c);
                            }
                        }
                        else{
                            ap05PurchaseOrderList.add(currentPurchaseOrder);

                            if(currentPurchaseOrder.TECH_AssessmentEntityRules__c != null)
                            {
                                ap05EntityRulesSet.add(currentPurchaseOrder.TECH_AssessmentEntityRules__c);
                            }
                        }
                    }
                }
            }
        }

        //DUN 04/01/2018  C-002135 agency Mode V2
        if(mapAssIdlistAgencyModePurchaseOrders.size() > 0){
            AP37AssessmentAgencyModeQueueable.setPOAgencyMode(mapAssIdlistAgencyModePurchaseOrders, distAgencyIdSet);
        } 

        // run the initiateSLAProcess_QuotationUsingRuleEngine
        if(ap05PurchaseOrderList.size() > 0)
        {
            AP05PurchaseOrderSLA.initiateSLAProcess_QuotationUsingRuleEngine(ap05PurchaseOrderList, ap05EntityRulesSet, 'QUOTATION');
        }

        // run the initiateSLAProcess_QuotationUsingRuleEngine
        if(ap05OrderPurchaseOrderList.size() > 0)
        {
            AP05PurchaseOrderSLA.initiateSLAProcess_QuotationUsingRuleEngine(ap05OrderPurchaseOrderList, ap05OrderEntityRulesSet, 'ORDERQUOTATION');
        }

        // Populate the distributor contact
        if(ap32PurchaseOrderList.size() > 0)
        {
            // AP23POPopulateDistributorUser.populateDistributorContact(ap32PurchaseOrderList, ap32AccountIdSet);
            AP32PopulatePurchaseOrderFromAccount.populatePurchaseOrder(ap32PurchaseOrderList, ap32AccountIdSet);
        }
        // Update the assessments
        if(mapAssessmentToUpdate.size() > 0)
        {
            update mapAssessmentToUpdate.values();
        }

        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - onBeforeInsert --------------------------');
    }

    public void onAfterInsert(List<PurchaseOrder__c> newPurchaseOrderList)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - onAfterInsert --------------------------');

        // Map Assessment and List of purchase order that will be used to generate the order lines of the purchase orders
        Map<Id, List<PurchaseOrder__c>> mapAssessmentPurchaseOrderList        = new Map<Id, List<PurchaseOrder__c>>();
        
        //DUN 04/01/2018  C-002135 agency Mode V2
        // Map Assessment and List of purchase order
        //Map<Id, List<PurchaseOrder__c>> mapAgencyAssessmentPurchaseOrderList  = new Map<Id, List<PurchaseOrder__c>>();

        // Set of distributors id that is needs to create the order lines
        Set<Id> distributorsIdSet                                             = new Set<Id>();
        Set<Id> distAgencyIdSet                                               = new Set<Id>();
        // Set of assessment id that has purchase order rejected or canceled and the reason is not canceled by bs
        Set<Id> ap18AssessmentSet                                             = new Set<Id>();
        // Set of sales orders id that needs to have it updated using the bodyshop order number of the purchase order
        Set<Id> salesOrderIdToSyncBodyShopNumberSet                           = new Set<Id>();

        // ABT - 06-APR-2017
        Set<Id> draftQuotePurchaseOrderIdSet                                = new Set<Id>();
        
        /*Set<Id> draftQuoteDEPurchaseOrderIdSet                                = new Set<Id>();*/

        //DUN 02/05/2018  C-002488 - Fill field EncodedId__c
        list<PurchaseOrder__c> listPOEncodedIdToUpdate = new list<PurchaseOrder__c>();

        // Loop in the newPurchaseOrderList to capture the info
        for(PurchaseOrder__c newPurchaseOrder : newPurchaseOrderList)
        {
            // check if assessment is not null as all the process inside it requires that assessment is filled in
            //DUN 18/09/2018 Case C-001895 : Spare Part Recovery Added SparePartsRecovery__c in if condition
            if(newPurchaseOrder.Assessment__c != null && !newPurchaseOrder.SparePartsRecovery__c)
            {
                // Grouping the inserted PurchaseOrder according to its Assessment
                if(!mapAssessmentPurchaseOrderList.containsKey(newPurchaseOrder.Assessment__c))
                {
                    mapAssessmentPurchaseOrderList.put(newPurchaseOrder.Assessment__c, new List<PurchaseOrder__c>{newPurchaseOrder});
                }
                else
                {
                    mapAssessmentPurchaseOrderList.get(newPurchaseOrder.Assessment__c).add(newPurchaseOrder);
                }

                // Also captuing the distributors of the purchase orders. Distributors cannot be null as it is a master detail relationship
                distributorsIdSet.add(newPurchaseOrder.Distributor__c);

                //DUN 26/04/2017 case 1904
                ////DUN 04/01/2018  C-002135 agency Mode V2
                //if(newPurchaseOrder.TECH_AssessmentCountryCode__c != null && 
                //   mapCountryCodeMappings.containsKey(newPurchaseOrder.TECH_AssessmentCountryCode__c) &&
                //   mapCountryCodeMappings.get(newPurchaseOrder.TECH_AssessmentCountryCode__c).CarBrandsSuppliedAgency__c != null &&
                //   mapCountryCodeMappings.get(newPurchaseOrder.TECH_AssessmentCountryCode__c).CarBrandsSuppliedAgency__c.contains(newPurchaseOrder.Brand__c))
                //{
                //    //DUN 04/01/2018  C-002135 agency Mode V2
                //    //if(!mapAgencyAssessmentPurchaseOrderList.containsKey(newPurchaseOrder.Assessment__c))
                //    //{
                //    //    mapAgencyAssessmentPurchaseOrderList.put(newPurchaseOrder.Assessment__c, new List<PurchaseOrder__c>{newPurchaseOrder});
                //    //}
                //    //else
                //    //{
                //    //    mapAgencyAssessmentPurchaseOrderList.get(newPurchaseOrder.Assessment__c).add(newPurchaseOrder);
                //    //}
                //    distAgencyIdSet.add(newPurchaseOrder.Distributor__c);
                //    listAgencyModePurchaseOrders.add(newPurchaseOrder);
                //}

                // Check if the status of the purchase order is (REJECTED or CANCELED) and the cancel reason is not CanceledByBS
                if( (newPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_REJECTED ||
                     newPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED) &&
                     newPurchaseOrder.Reason__c != ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS)
                {
                    ap18AssessmentSet.add(newPurchaseOrder.Assessment__c);
                }

                // ABT - 06-APR-2017
                //AMI 01/11/2018  C-002781 : Migrate Spain to R4
                //                         : New Distributor Notification Email Template for ES in R4
                if( newPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
                {
                     system.debug('##1');
                    if(newPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR' || newPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE'
                        || newPurchaseOrder.TECH_AssessmentCountryCode__c == 'BE'
                        || (newPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES' &&
                        newPurchaseOrder.Tech_BSCommunityPopulationType__c == 'R4')){
                        system.debug('##1');
                        draftQuotePurchaseOrderIdSet.add(newPurchaseOrder.Id);
                    }
                }
            }

            // check id the PrerequisiteOrder is not null and the bodyshop order number is not null
            if( newPurchaseOrder.PrerequisiteOrder__c != null &&
                newPurchaseOrder.BodyShopOrderNumber__c != null)
            {
                salesOrderIdToSyncBodyShopNumberSet.add(newPurchaseOrder.PrerequisiteOrder__c);
            }
            //DUN 02/05/2018  C-002488 - Fill field EncodedId__c
            listPOEncodedIdToUpdate.add(new PurchaseOrder__c(Id = newPurchaseOrder.Id,
                                                             EncodedId__c = encryptBase64(newPurchaseOrder.Id)));
        }

        //DUN 02/05/2018  C-002488 - Fill field EncodedId__c
        if(listPOEncodedIdToUpdate.size() > 0)
        {
            update listPOEncodedIdToUpdate;
        }

        // check if the mapAssessmentPurchaseOrderList is not blank
        //AMI 14/08/17 : Bypassing Orderlines Creation during restcreateassessement
        if(mapAssessmentPurchaseOrderList.size() > 0 && !System.isQueueable())
        {
            createOrderLines(mapAssessmentPurchaseOrderList, distributorsIdSet);
        }

        // Update the assessment if all of its PO is rejected or canceled
        if(ap18AssessmentSet.size() > 0)
        {
            if(System.isBatch() || System.isFuture())
            {
                AP18SetAssessmentStatus.updateAssessment(ap18AssessmentSet);
            }
            else
            {
                AP18SetAssessmentStatus.updateAssessmentAsync(ap18AssessmentSet);
            }
        }

        // Update the sales order BodyShopOrderNumber__c
        if(salesOrderIdToSyncBodyShopNumberSet.size() > 0)
        {
            updateSalesOrderBodyShopNumber(salesOrderIdToSyncBodyShopNumberSet);
        }

        // ABT - 06-APR-2017
         if(draftQuotePurchaseOrderIdSet.size() > 0)

        {
            Set<Id> quotationEmailIdSet         = new Set<Id>();

            for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, Assessment__c, Assessment__r.OrderOrigin__c
                                                         FROM   PurchaseOrder__c
                                                         WHERE  Id =: draftQuotePurchaseOrderIdSet
                                                         ])
            {
                if (currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Quotation')
                {
                    quotationEmailIdSet.add(currentPurchaseOrder.Id);
                }
            }

            if (quotationEmailIdSet.size() > 0)
            {   //DUN 12/09/2017 case 2020
                if(System.isBatch())
                {
                    AP35R4SendPurchaseOrderEmail.sendEmail(new Set<Id>(), quotationEmailIdSet, new Set<Id>());
                }else if(System.isFuture()){//WCH 13/04/2020 C-003707
                    //do nothing
                    system.debug('do not send email to distributor');
                }
                else
                {
                    AP35R4SendPurchaseOrderEmail.sendEmailASync(new Set<Id>(), quotationEmailIdSet, new Set<Id>());
                }
            }
        }
        //DUN 04/01/2018  C-002135 agency Mode V2
        //if(listAgencyModePurchaseOrders.size() > 0){
        //    AP37AssessmentAgencyModeQueueable.setPOAgencyMode(listAgencyModePurchaseOrders, distAgencyIdSet);
        //    //System.enqueueJob(new AP37AssessmentAgencyModeQueueable(mapAgencyAssessmentPurchaseOrderList,distAgencyIdSet));
        //} 
        
        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - onAfterInsert --------------------------');
    }

    public void onBeforeUpdate(List<PurchaseOrder__c> newPurchaseOrderList, List<PurchaseOrder__c> oldPurchaseOrderList, Map<Id, PurchaseOrder__c> mapOldPurchaseOrder)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - onBeforeUpdate --------------------------');

        // List of purchase order that need to have their DistributorContact__c populated
        List<PurchaseOrder__c> ap32PurchaseOrderList            = new List<PurchaseOrder__c>();
        // Set of distributor account that needs to be retrieved in AP32
        Set<Id> ap32AccountIdSet                                = new Set<Id>();
        // List of purchase order that need to have the total expected amount calculated
        List<PurchaseOrder__c> ap15PurchaseOrderList            = new List<PurchaseOrder__c>();

        //RLA 22/01/2020 C-003536: New Billing Process for SPAIN
        List<PurchaseOrder__c> purchaseOrderListERPLock            = new List<PurchaseOrder__c>();


        // Loop in the new purchase orders
        for(Integer i = 0; i < newPurchaseOrderList.size(); i++)
        {
            // check if the field Distributor__c has changed and it is not null
            if( newPurchaseOrderList[i].Distributor__c != oldPurchaseOrderList[i].Distributor__c && 
                newPurchaseOrderList[i].Distributor__c != null)
            {
                ap32PurchaseOrderList.add(newPurchaseOrderList[i]);
                ap32AccountIdSet.add(newPurchaseOrderList[i].Distributor__c);
            }

            // check if there has been a changed in the status of the purchase order
            if(newPurchaseOrderList[i].Status__c != oldPurchaseOrderList[i].Status__c)
            {
                // Update the previous status of the purchase order
                // do not update PreviousStatus__c when Purchase order status is set to canceled invoice
                if( newPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE &&
                    newPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO &&
                    ((!newPurchaseOrderList[i].AgencyMode__c && newPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK) ||
                     (newPurchaseOrderList[i].AgencyMode__c && (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK || (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED && newPurchaseOrderList[i].TECH_AssessmentCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE)/*WCH 02/04/2019 C-003214*/)))) &&
                    oldPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE &&
                    oldPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO &&
                    oldPurchaseOrderList[i].Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK)
                {
                    newPurchaseOrderList[i].PreviousStatus__c = oldPurchaseOrderList[i].Status__c;
                }

                // Check if the status is RESPONDED or ISSUED
                if( (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_RESPONDED ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_ISSUED)
                     && Utils_SLARulesEngine.isSLaAllowed(newPurchaseOrderList[i].TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                {
                    /*vsu commented if(mapCountryCodeBusinessDays.containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c))
                    {
                        AP05PurchaseOrderSLA.runSLAOnStatus_Acceptance(newPurchaseOrderList[i], mapCountryCodeBusinessDays.get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                    }*/
                    AP05PurchaseOrderSLA.runSLAOnStatus_Acceptance(newPurchaseOrderList[i], ASPISConstants.getBusinessHours(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                   

                    AP05PurchaseOrderSLA.finishSLAProcess_Quotation(newPurchaseOrderList[i]);
                }

                // check if the status is ORDERED
                if((newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_ORDERED)
                     && Utils_SLARulesEngine.isSLaAllowed(newPurchaseOrderList[i].TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                {
                    /*vsu commented if(mapCountryCodeBusinessDays.containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c))
                    {
                        AP05PurchaseOrderSLA.runSLAOnStatus_Ordered(newPurchaseOrderList[i], mapCountryCodeBusinessDays.get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                    }*/
                    AP05PurchaseOrderSLA.runSLAOnStatus_Ordered(newPurchaseOrderList[i], ASPISConstants.getBusinessHours(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));

                }

                // check if the status is INDELIVERY
                if((newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)
                     && Utils_SLARulesEngine.isSLaAllowed(newPurchaseOrderList[i].TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                {
                    /*if(mapCountryCodeBusinessDays.containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c))
                    {
                        AP05PurchaseOrderSLA.runSLAOnStatus_Delivery(newPurchaseOrderList[i], mapCountryCodeBusinessDays.get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                    }*/
                    AP05PurchaseOrderSLA.runSLAOnStatus_Delivery(newPurchaseOrderList[i], ASPISConstants.getBusinessHours(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));

                }

                // check if the status is DELIVEREDCONFIRMED
                if((newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
                     && Utils_SLARulesEngine.isSLaAllowed(newPurchaseOrderList[i].TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                {
                    // Add the purchase order to the list to calculate the total expected amount
                    ap15PurchaseOrderList.add(newPurchaseOrderList[i]);

                    /*if(mapCountryCodeBusinessDays.containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c))
                    {
                        AP05PurchaseOrderSLA.runSLAOnStatus_DeliveredConfirmed(newPurchaseOrderList[i], mapCountryCodeBusinessDays.get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                    }*/
                    AP05PurchaseOrderSLA.runSLAOnStatus_DeliveredConfirmed(newPurchaseOrderList[i], ASPISConstants.getBusinessHours(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));

                }

                // check if the status is CANCELED or REJECTED
                if( (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_REJECTED)
                     && Utils_SLARulesEngine.isSLaAllowed(newPurchaseOrderList[i].TechInsuranceBroker__c))//RLA 22/06/2020 C-003699: IG - SLAs and Emails
                {
                    /*if(mapCountryCodeBusinessDays.containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c))
                    {
                        AP05PurchaseOrderSLA.runSLAOnStatus_Closed(newPurchaseOrderList[i], mapCountryCodeBusinessDays.get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));
                    }*/
                    AP05PurchaseOrderSLA.runSLAOnStatus_Closed(newPurchaseOrderList[i], ASPISConstants.getBusinessHours(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c));

                }
                //DUN 20/12/2016 case 1821 Added temporary status predraftquote
                // Check if the status is DRAFTQUOTE or ISSUED or RESPONDED
                if( newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_ISSUED ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_RESPONDED ||
                    newPurchaseOrderList[i].Status__c == 'PREDRAFTQUOTE' )
                {
                    newPurchaseOrderList[i].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PURCHASEORDER_RT_Name_DraftQuote).getRecordTypeId();
                }
                // check if the status is ORDERED
                else if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_ORDERED)
                {
                    newPurchaseOrderList[i].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PURCHASEORDER_RT_Name_Ordered).getRecordTypeId();
                }
                // check if the status is CANCELED or REJECTED
                else if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED ||
                        newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_REJECTED)
                {
                    newPurchaseOrderList[i].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PURCHASEORDER_RT_Name_Eliminated).getRecordTypeId();
                }
                // All remaining status is set to InDelivery RecordType
                else
                {
                    newPurchaseOrderList[i].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PURCHASEORDER_RT_Name_InDelivery).getRecordTypeId();
                }
            }

            // 05/10/2017 DUN ticket 403
            if((newPurchaseOrderList[i].Status__c != oldPurchaseOrderList[i].Status__c ||
            newPurchaseOrderList[i].wsDate__c != oldPurchaseOrderList[i].wsDate__c) &&
            newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE &&
            newPurchaseOrderList[i].wsDate__c != null && 
            newPurchaseOrderList[i].wsErrorMessage__c != null &&
            newPurchaseOrderList[i].wsErrorMessage__c.contains(system.label.R4POClientNonTrouve) &&
            newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'FR'){
                newPurchaseOrderList[i].BsNotFoundCaseCreated__c = true;  
            }
        }

        // Populating the distributors contact
        if(ap32PurchaseOrderList.size() > 0)
        {
            // AP23POPopulateDistributorUser.populateDistributorContact(ap23PurchaseOrderList, ap23AccountIdSet);
            AP32PopulatePurchaseOrderFromAccount.populatePurchaseOrder(ap32PurchaseOrderList, ap32AccountIdSet);
        }

        // calculating the total expected amount
        if(ap15PurchaseOrderList.size() > 0)
        {
            AP15CalculateTotalExpAmtPurchaseOrder.updatePurchaseOrder(ap15PurchaseOrderList);
        }
        
        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - onBeforeUpdate --------------------------');
    }
 
    public void onAfterUpdate(List<PurchaseOrder__c> newPurchaseOrderList, List<PurchaseOrder__c> oldPurchaseOrderList, Map<Id, PurchaseOrder__c> mapOldPurchaseOrder)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - onAfterUpdate --------------------------');

        // Set of sales order id that will execute the executeServiceOrderDeliveryConfirmed
        Set<Id> salesOrderIdSet                         = new Set<Id>();
        // Set of purchase order id that needs to have thier invoice set to payable
        Set<Id> purchaseOrderIdToUpdateInvoiceSet       = new Set<Id>();
        // Set of assessment id that has purchase order rejected or canceled and the reason is not canceled by bs
        Set<Id> ap18AssessmentSet                       = new Set<Id>();
        // List of purchase orders that need to have their sales order internal comment sync
        // List<PurchaseOrder__c> ap27PurchaseOrderList    = new List<PurchaseOrder__c>();
        // Set of sales orders id that needs to have it updated using the bodyshop order number of the purchase order
        Set<Id> salesOrderIdToSyncBodyShopNumberSet     = new Set<Id>();
        // Set of canceled purchase orders id
        Set<Id> canceledPurchaseOrderIdSet              = new Set<Id>();
        // Set of indelivery purchase orders id
        Set<Id> indeliveryPurchaseOrderIdSet            = new Set<Id>();
        // List of order line that needs to be updated
        List<OrderLine__c> orderLineToUpdateList        = new List<OrderLine__c>();
        // List of cases to insert
        List<Case__c> casesToInsertList                 = new List<Case__c>();
        // List of invoices to updtae
        List<Invoice__c> invoicedToUpdateList           = new List<Invoice__c>();
        // List of purchase order to update (for canceled Purchase order and PAID)
        List<PurchaseOrder__c> purchaseOrderToUpdate    = new List<PurchaseOrder__c>();
        // Set of assessment id that need to have their status updated when purchase order is reopended/closed
        Set<Id> assessmentIdSet                         = new Set<Id>();
        // Set of purchase order Id that has been set to responded...will be used for AP34BundleGeneration
        Set<Id> respondedPurchaseOrderIdSet                = new Set<Id>();
        Set <Id> soIdOfCanceledPos = new Set <Id> ();//vsu 21/02/18

        //DUN 09/11/2016 case 1669
        //Set of assessment id that need to have their status updated when purchase order is reopended/closed
        //Set<Id> setPOId                                = new Set<Id>();
        //Set of assessment id that need to have their status updated when purchase order is reopended/closed
        Set<Id> setPOdistId                            = new Set<Id>();
        
        Set<Id> draftQuotePurchaseOrderIdSet           = new Set<Id>();
        Set<Id> inDeliveryEmailPurchaseOrderIdSet           = new Set<Id>();


        //DUN 10/10/2017 case 2040 ticket 415
        Set<Id> draftquoteR4OrderFRPurchaseOrderIdSet    = new Set<Id>();

        map<Id,list<PurchaseOrder__c>> mapAssIdlistPurchaseOrderSLA2 = new map<Id,list<PurchaseOrder__c>>();
        list<Id> listPurchaseOrderSLA2 = new list<Id>();

        //AMI 11/07/2017 - Set DE PO/SO to CLOSEDOK for Agency Mode
        set <id> ap39DeliveredPurchaseOrderSet = new set <id>();

        //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
        map<Id,list<PurchaseOrder__c>> mapSOIdPO = new map<Id,list<PurchaseOrder__c>>();
        set<Id> setDistributorIds = new set<Id>();
        map<Id,Account> mapDistributors = new map<Id,Account>();

        //RLA 22/01/2020 C-003536: New Billing Process for SPAIN
        map<Id,PurchaseOrder__c> mapPurchaseOrderToUpdate = new map<Id, PurchaseOrder__c>();

        //RLA 18/06/2020 C-003700: IG - orderConfirmation
        map<String,String> mapOrderConfirmationFuture = new map<String,String>();
        map<String,String> mapOrderConfirmation = new map<String,String>();


        // Loop in the new purchase orders
        for(Integer i = 0; i < newPurchaseOrderList.size(); i++)
        {
            // check if there has been a changed in the status of the purchase order
            system.debug('### PO new status:'+newPurchaseOrderList[i].Status__c + newPurchaseOrderList[i].Reason__c);
            system.debug('### PO old status:'+oldPurchaseOrderList[i].Status__c);
            if(newPurchaseOrderList[i].Status__c != oldPurchaseOrderList[i].Status__c)
            {
                // ABT - 05-APR-2017
                if( newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE )
                {
                     if(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'FR' 
                        || newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'DE'
                        || newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'BE'){
                        draftQuotePurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
                    }

                }

                if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_RESPONDED)
                {
                    // Capture the issued puchase order id
                    respondedPurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
                }

                //AMI 19/12//2018 Case C-002045 - Advance case management
                //                              - Prevent update to delivery confirmed if advance case mgt is enabled
                //                              - was causing unexpected behaviour on other processes
                // check is status is delivered confirmed and PrerequisiteOrder__c != null
                if( newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED &&
                    newPurchaseOrderList[i].PrerequisiteOrder__c != null)
                {
                    if(!(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c != null &&
                    CountryCodeInformationsMapping__c.getall().containsKey(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c) &&
                       CountryCodeInformationsMapping__c.getall().get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c).AdvancedCaseManagement__c)){
                        salesOrderIdSet.add(newPurchaseOrderList[i].PrerequisiteOrder__c);
                    }
                }



                // check if the status is canceled
                if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED)
                {
                    if(newPurchaseOrderList[i].PrerequisiteOrder__c != null){
                        soIdOfCanceledPos.add(newPurchaseOrderList[i].PrerequisiteOrder__c);//vsu 21/02/18
                    }
                    // check if the old status was ISSUED
                    if(oldPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_ISSUED)
                    {
                        // Generate the case if the distributor canceled the purchase order
                        Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-Canceled');
                
                        // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                        if(newCase != null)
                        {
                            casesToInsertList.add(newCase);
                        }
                    }

                    // Check if the reason is UNSUPPLIABLEQUOTE
                    if(newPurchaseOrderList[i].Reason__c == ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE)
                    {
                        // Generate the case if the reason is unsuppliable quote
                        Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-Unsupplied');
                
                        // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                        if(newCase != null)
                        {
                            casesToInsertList.add(newCase);
                        }
                    }

                    // capture the canceled purchase orders to update the Order Lines
                    canceledPurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
                }

                // Check if the purchase order is (rejected or canceled) and the reason is not CanceledByBS

                if( (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_REJECTED ||
                     newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED) &&
                     newPurchaseOrderList[i].Reason__c != ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS
                     && newPurchaseOrderList[i].Assessment__c != null)//vsu 28/02/18
                {
                    ap18AssessmentSet.add(newPurchaseOrderList[i].Assessment__c);
                }
                
                // check if the status is indelivery
                if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)
                {
                    // Capture the indelivery puchase order id
                    indeliveryPurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);

                    // ABT - 05-APR-2017
                    //AMI 01/11/2018  C-002781 : Migrate Spain to R4
                    //                         : New Distributor Notification Email Template for ES in R4
                    if( newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'FR'
                        ||newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'DE'
                        ||newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'BE'
                        ||(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'ES' &&
                        newPurchaseOrderList[i].Tech_BSCommunityPopulationType__c == 'R4')){
                        inDeliveryEmailPurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
                    }

                }

                // check if the new status of the purchase order is PAID (set by batch when the invoices are set to PAID)
                if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_PAID)
                {
                    // therefore the Status__c of the purchase order should be updated to CLOSEDOK or CLOSEDKO
                    // check if the old Status__c of the purchase order is CANCELEDINVOICED
                    if(oldPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE)
                    {
                        // set the purchase order to CLOSEDKO
                        // purchaseOrderToUpdate.add(new PurchaseOrder__c( Id          = newPurchaseOrderList[i].Id,
                                                                        // Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO));
                        
                        if (mapPurchaseOrderToUpdate.containsKey(newPurchaseOrderList[i].Id)){
                            mapPurchaseOrderToUpdate.get(newPurchaseOrderList[i].Id).Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
                        }
                        else{
                            mapPurchaseOrderToUpdate.put(newPurchaseOrderList[i].Id, new PurchaseOrder__c( Id = newPurchaseOrderList[i].Id,
                                                                                                           Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO));
                        }
                    }
                    else
                    {
                        // the purchase order was not canceled, its status should be updated to CLOSEDOK
                        // purchaseOrderToUpdate.add(new PurchaseOrder__c( Id          = newPurchaseOrderList[i].Id,
                                                                        // Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK));


                        if (mapPurchaseOrderToUpdate.containsKey(newPurchaseOrderList[i].Id)){
                            mapPurchaseOrderToUpdate.get(newPurchaseOrderList[i].Id).Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
                        }
                        else{
                            mapPurchaseOrderToUpdate.put(newPurchaseOrderList[i].Id, new PurchaseOrder__c( Id = newPurchaseOrderList[i].Id,
                                                                                                           Status__c   = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK));
                        }
                    }
                }
                



                // when closing or reopening the purchase order
                // update the assessment 
                if( (newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK ||
                    newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE ||
                    oldPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO ||
                    oldPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK)
                    // RLA C-002002 : assessments status is processed in batch except for those SO not having any invoice , or countryCode =ES
                    //&& newPurchaseOrderList[i].TECH_AssessmentCountryCode__c =='ES' && !newPurchaseOrderList[i].TechProcessedByBatchInvoice__c
                )
                {
                   
                    assessmentIdSet.add(newPurchaseOrderList[i].Assessment__c);
                }

                //DUN 09/11/2016 case 1669
                 //if(newPurchaseOrderList[i].PrerequisiteOrder__c != null &&
                 //   newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_INDELIVERY){  
                 //   setPOId.add(newPurchaseOrderList[i].Id);
                 //   setPOdistId.add(newPurchaseOrderList[i].Distributor__c);
                 //}

                //AMI 11/07/2017 - populate ap39DeliveredPurchaseOrderSet
                // DUN 13/12/2017 case 1998 Modify condition, removed CountryCode 
                // DUN 04/01/2018 case 1998 change field TechAgencyMode__c to AgencyMode__c
                if(newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED &&
                    newPurchaseOrderList[i].AgencyMode__c == true )
                {  
                    ap39DeliveredPurchaseOrderSet.add(newPurchaseOrderList[i].Id); 
                } 

                //RLA 18/06/2020 C-003700: IG - orderConfirmation
                if(((newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO && (newPurchaseOrderList[i].Reason__c == ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS || newPurchaseOrderList[i].Reason__c == ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE || newPurchaseOrderList[i].Reason__c == ASPISConstants.PUR_ORDER_REASON_NOTSELECTED)) 
                    || newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)
                    && String.isNotBlank(newPurchaseOrderList[i].TechInsuranceBroker__c) 
                    && system.label.InsBrokerName.contains(newPurchaseOrderList[i].TechInsuranceBroker__c)
                    // && !newPurchaseOrderList[i].AutoValidate_PO__c //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS 
                )
                {
                    // setPOIdsOrderConfirmation.add(newPurchaseOrderList[i].Id);
                    // setPONamesOrderConfirmation.add(newPurchaseOrderList[i].Name);
                    if (newPurchaseOrderList[i].AutoValidate_PO__c){
                        mapOrderConfirmation.put(newPurchaseOrderList[i].Id,newPurchaseOrderList[i].Name);
                    }
                    else{
                        mapOrderConfirmationFuture.put(newPurchaseOrderList[i].Id,newPurchaseOrderList[i].Name);
                    }

                }
            }


            //NPE 04/05/2022  C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned
            if(newPurchaseOrderList[i].AgencyMode__c && newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'ES' && newPurchaseOrderList[i].Status__c !=ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO && (newPurchaseOrderList[i].Status__c ==ASPISConstants.PUR_ORDER_STATUS_CANCELED || newPurchaseOrderList[i].Status__c ==ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK)){
                AP39AgencyMode.getOLofPO(newPurchaseOrderList[i].id);
            }



            //RLA 22/01/2020 C-003536: New Billing Process for SPAIN
                if( newPurchaseOrderList[i].TotalExpectedAmount__c !=  oldPurchaseOrderList[i].TotalExpectedAmount__c
                    && !newPurchaseOrderList[i].AgencyMode__c
                    && newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'ES' )               
            {
                // newPurchaseOrderList[i].SendtoERP__c = true; 
                // purchaseOrderListERPLock.add(new PurchaseOrder__c(Id = newPurchaseOrderList[i].Id,SendtoERP__c = true ));

                if (mapPurchaseOrderToUpdate.containsKey(newPurchaseOrderList[i].Id)){
                    mapPurchaseOrderToUpdate.get(newPurchaseOrderList[i].Id).SendtoERP__c = true;
                }
                else{
                    mapPurchaseOrderToUpdate.put(newPurchaseOrderList[i].Id, new PurchaseOrder__c( Id = newPurchaseOrderList[i].Id,
                                                                                                    SendtoERP__c = true));
                }
            }
            //DUN 12/09/2017 case 2020
            if( (newPurchaseOrderList[i].Status__c != oldPurchaseOrderList[i].Status__c ||
                newPurchaseOrderList[i].wsDate__c != oldPurchaseOrderList[i].wsDate__c) &&
                newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE &&
                newPurchaseOrderList[i].wsDate__c != null && 
                newPurchaseOrderList[i].wsErrorMessage__c != null &&
                !newPurchaseOrderList[i].wsErrorMessage__c.contains(system.label.R4POOrderOrderSuccessfullySent) &&
                !newPurchaseOrderList[i].wsErrorMessage__c.contains(system.label.R4POClientNonTrouve) &&
                newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'FR'){
                draftQuotePurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
            }
            
            //DUN 10/10/2017 case 2040 ticket 415
            if( (newPurchaseOrderList[i].Status__c != oldPurchaseOrderList[i].Status__c ||
                 newPurchaseOrderList[i].wsDate__c != oldPurchaseOrderList[i].wsDate__c) &&
                newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE &&
                newPurchaseOrderList[i].wsDate__c != null && 
                newPurchaseOrderList[i].wsErrorMessage__c != null &&
                newPurchaseOrderList[i].wsErrorMessage__c.contains(system.label.R4POOrderOrderSuccessfullySent) &&
                newPurchaseOrderList[i].TECH_AssessmentCountryCode__c == 'FR'){
                draftquoteR4OrderFRPurchaseOrderIdSet.add(newPurchaseOrderList[i].Id);
            }
            
            system.debug('## newPurchaseOrderList[i].wsErrorMessage__c ' + newPurchaseOrderList[i].wsErrorMessage__c);

            //DUN 04/10/2017 ticket 403
            if( newPurchaseOrderList[i].BsNotFoundCaseCreated__c != oldPurchaseOrderList[i].BsNotFoundCaseCreated__c &&
                newPurchaseOrderList[i].BsNotFoundCaseCreated__c){

                // Create a case when the bodyshop is not found by the connected supplier.
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-ASS', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-BsNotFound');
                system.debug('## newCase connected supplier' + newCase);
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);   
                }
            }
            // check if InvoiceStatus has changed and the status is validated
            if( newPurchaseOrderList[i].InvoiceStatus__c != oldPurchaseOrderList[i].InvoiceStatus__c &&
                newPurchaseOrderList[i].InvoiceStatus__c == ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED)
            {
                purchaseOrderIdToUpdateInvoiceSet.add(newPurchaseOrderList[i].Id);
            }

            // check if internal comment has changed
            // if( newPurchaseOrderList[i].InternalComment__c != oldPurchaseOrderList[i].InternalComment__c &&
            //     newPurchaseOrderList[i].PrerequisiteOrder__c != null)
            // {
            //     ap27PurchaseOrderList.add(newPurchaseOrderList[i]);
            // }

            // check if there is a change in (PrerequisiteOrder__c or BodyShop__c) and PrerequisiteOrder__c is not null and BodyShop__c is not null
            if( (newPurchaseOrderList[i].PrerequisiteOrder__c != oldPurchaseOrderList[i].PrerequisiteOrder__c ||
                 newPurchaseOrderList[i].BodyShopOrderNumber__c != oldPurchaseOrderList[i].BodyShopOrderNumber__c) &&
                 newPurchaseOrderList[i].PrerequisiteOrder__c != null &&
                 newPurchaseOrderList[i].BodyShopOrderNumber__c != null)
            {
                salesOrderIdToSyncBodyShopNumberSet.add(newPurchaseOrderList[i].PrerequisiteOrder__c);
            }

            // check if DelayedCaseCreated__c has changed and DelayedCaseCreated__c is true
            if( newPurchaseOrderList[i].DelayedCaseCreated__c != oldPurchaseOrderList[i].DelayedCaseCreated__c &&
                newPurchaseOrderList[i].DelayedCaseCreated__c == true )
            {
                // Generate the case if the reason is unsuppliable quote
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-Delayed');
                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);
                }  
            }

            // check if InvoiceStatusNotValidated__c has changed and InvoiceStatusNotValidated__c is true and status is DELIVEREDCONFIRMED
            if( newPurchaseOrderList[i].InvoiceStatusNotValidated__c != oldPurchaseOrderList[i].InvoiceStatusNotValidated__c &&
                newPurchaseOrderList[i].InvoiceStatusNotValidated__c == true &&
                newPurchaseOrderList[i].Status__c == ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
            {
                // Generate the case if the reason is unsuppliable quote
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-NotValidated');

                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);
                }
            }

            // check if ASMarginTooLowCaseCreated__c has changed and ASMarginTooLowCaseCreated__c is true
            if( newPurchaseOrderList[i].ASMarginTooLowCaseCreated__c != oldPurchaseOrderList[i].ASMarginTooLowCaseCreated__c &&
                newPurchaseOrderList[i].ASMarginTooLowCaseCreated__c == true)
            {
                // Generate the case if the reason is unsuppliable quote
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-ASMarginTooLow');

                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);
                }
            }

            // check if ASDiscountLowCaseCreated__c has changed and ASDiscountLowCaseCreated__c is true
            if( newPurchaseOrderList[i].ASDiscountLowCaseCreated__c != oldPurchaseOrderList[i].ASDiscountLowCaseCreated__c &&
                newPurchaseOrderList[i].ASDiscountLowCaseCreated__c == true)
            {
                // Generate the case if the reason is unsuppliable quote
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-ASDiscountTooLow');

                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);
                }
            }

            // check if DistributorPriceHigger__c has changed and DistributorPriceHigger__c is true
            if( newPurchaseOrderList[i].DistributorPriceHigger__c != oldPurchaseOrderList[i].DistributorPriceHigger__c &&
                newPurchaseOrderList[i].DistributorPriceHigger__c == true)
            {
                // Generate the case if the reason is unsuppliable quote
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-DistributorPriceHigh');

                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);  
                }
            }

            // check if TECHSLAQuotationIsLevel2__c has changed and TECHSLAQuotationIsLevel2__c is true
            if( newPurchaseOrderList[i].TECHSLAQuotationIsLevel2__c != oldPurchaseOrderList[i].TECHSLAQuotationIsLevel2__c &&
                newPurchaseOrderList[i].TECHSLAQuotationIsLevel2__c == true)
            {   
                //DUN 29/06/2017 commented code (trello 207) - case should be created only for po having assessment with orderType = Order
                // Generate the case if the reason is unsuppliable quote
                //Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', newPurchaseOrderList[i].TECH_AssessmentCountryCode__c, newPurchaseOrderList[i].Distributor__c, newPurchaseOrderList[i].Assessment__c, newPurchaseOrderList[i].Id, newPurchaseOrderList[i].PrerequisiteOrder__c, newPurchaseOrderList[i].Comment__c, UserInfo.getUserId(), '-QuotationSLA2');
                
                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                //if(newCase != null)
                //{
                //    casesToInsertList.add(newCase);
                //}
                
                //DUN 11/10/2017 case 2040 trello ticket 416
                //if(!mapAssIdlistPurchaseOrderSLA2.containsKey(newPurchaseOrderList[i].Assessment__c)){
                //    mapAssIdlistPurchaseOrderSLA2.put(newPurchaseOrderList[i].Assessment__c, new list<PurchaseOrder__c>{newPurchaseOrderList[i]});
                //}
                //else{
                //    mapAssIdlistPurchaseOrderSLA2.get(newPurchaseOrderList[i].Assessment__c).add(newPurchaseOrderList[i]);
                //}
                
                listPurchaseOrderSLA2.add(newPurchaseOrderList[i].Id);
            }

            //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
            //AMI 31/10/2018  C-002045 - Advance case management - Replacing TECH_BodyshopCountryCode__c with TECH_AssessmentCountryCode__c
            if( newPurchaseOrderList[i].OrderDiscussionCase__c != oldPurchaseOrderList[i].OrderDiscussionCase__c &&
                newPurchaseOrderList[i].OrderDiscussionCase__c == true && 
                CountryCodeInformationsMapping__c.getall().get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c) != null &&
                CountryCodeInformationsMapping__c.getall().get(newPurchaseOrderList[i].TECH_AssessmentCountryCode__c).AdvancedCaseManagement__c){
                if(!mapSOIdPO.containsKey(newPurchaseOrderList[i].PrerequisiteOrder__c)){
                    mapSOIdPO.put(newPurchaseOrderList[i].PrerequisiteOrder__c, new list<PurchaseOrder__c>{newPurchaseOrderList[i]});
                }
                else{
                    mapSOIdPO.get(newPurchaseOrderList[i].PrerequisiteOrder__c).add(newPurchaseOrderList[i]);
                }
                setDistributorIds.add(newPurchaseOrderList[i].Distributor__c);
            }
            system.debug('## mapSOIdPO ' + mapSOIdPO);
        }

        //DUN 29/06/2017 move case creation code here (trello 207)
        //DUN 11/10/2017 case 2040 trello ticket 416
        //for(Assessment__c currentAssessment : [Select Id, OrderOrigin__c, RecordType.DeveloperName 
        //                                       from Assessment__c
        //                                       where Id in: mapAssIdlistPurchaseOrderSLA2.keySet()]){
        //    if(currentAssessment.OrderOrigin__c == 'Order' && 
        //       currentAssessment.RecordType.DeveloperName == 'ClaimOrder' && 
        //       mapAssIdlistPurchaseOrderSLA2.containsKey(currentAssessment.Id)){
        //        for(PurchaseOrder__c currentPO : mapAssIdlistPurchaseOrderSLA2.get(currentAssessment.Id)){
        //           Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', currentPO.TECH_AssessmentCountryCode__c, currentPO.Distributor__c, currentPO.Assessment__c, currentPO.Id, currentPO.PrerequisiteOrder__c, currentPO.Comment__c, UserInfo.getUserId(), '-QuotationSLA2');
                
        //            // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
        //            if(newCase != null)
        //            {
        //                casesToInsertList.add(newCase);
        //            } 
        //        }
        //    }
        //}
        
        system.debug('##soIdOfCanceledPos: '+soIdOfCanceledPos);
        if(soIdOfCanceledPos.size() > 0){
            updateSOToCanceled(soIdOfCanceledPos);//vsu 21/02/18
        }
        
        //DUN 11/10/2017 case 2040 trello ticket 416  
        List<PurchaseOrder__c> listPOSLA2 = [Select Id, Assessment__c, TECH_AssessmentCountryCode__c , Distributor__c, 
                                                    Distributor__r.DistributorConnected__c, Distributor__r.Type_of_Substitutes__c, Comment__c, PrerequisiteOrder__c, 
                                                    Assessment__r.OrderOrigin__c, Assessment__r.RecordType.DeveloperName,
                                                    Assessment__r.BodyShop__r.DistributorConnected__c 
                                               from PurchaseOrder__c
                                               where Id in: listPurchaseOrderSLA2];

        //DUN 04/12/2017 PILOT BS Added || (po.Distributor__r.DistributorConnected__c && !po.Assessment__r.BodyShop__r.DistributorConnected__c)
        for(PurchaseOrder__c  po : listPOSLA2){
            if((po.Assessment__r.OrderOrigin__c == 'Order' && 
               po.Assessment__r.RecordType.DeveloperName == 'ClaimOrder' && 
            //    (!po.Distributor__r.DistributorConnected__c || 
                // (po.Distributor__r.DistributorConnected__c && !po.Assessment__r.BodyShop__r.DistributorConnected__c))) 
                (!RestDistributorUtility.isConnectedDist(po.Distributor__r.Type_of_Substitutes__c) || 
                (RestDistributorUtility.isConnectedDist(po.Distributor__r.Type_of_Substitutes__c) && !po.Assessment__r.BodyShop__r.DistributorConnected__c))) 
                 || (po.TECH_AssessmentCountryCode__c == 'DE')//VSU C-002566
               )
            {

                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', po.TECH_AssessmentCountryCode__c, po.Distributor__c, po.Assessment__c, po.Id, po.PrerequisiteOrder__c, po.Comment__c, UserInfo.getUserId(), '-QuotationSLA2');
                
                // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                if(newCase != null)
                {
                    casesToInsertList.add(newCase);
                } 
                system.debug('## newCase ' + newCase);
            }
        }


        Set<Id> purchaseOrderOrderLinesToQuerySet = new Set<Id>();
        purchaseOrderOrderLinesToQuerySet.addAll(canceledPurchaseOrderIdSet);
        purchaseOrderOrderLinesToQuerySet.addAll(indeliveryPurchaseOrderIdSet);
        //DUN 10/10/2017 case 2040 trello 415 
        purchaseOrderOrderLinesToQuerySet.addAll(draftquoteR4OrderFRPurchaseOrderIdSet);

        // check if there is a need to query the order lines
        if(purchaseOrderOrderLinesToQuerySet.size() > 0)
        {
            // Loop in the order lines having purchase order id in purchaseOrderOrderLinesToQuerySet
            for(OrderLine__c currentOrderLine : [SELECT Id, Name, AcceptedCheck__c, DeliveryStatus__c, Suppliable__c, PurchaseOrder__c, EstimatedDeliveryDate__c, ExpectedDeliveryDuration__c, PurchaseOrder__r.SLAQuotationEntryDate__c, PurchaseOrder__r.SLADeliveryEntryDate__c, PurchaseOrder__r.TECH_AssessmentCountryCode__c
                                                 FROM   OrderLine__c
                                                 WHERE  PurchaseOrder__c IN: purchaseOrderOrderLinesToQuerySet
                                                 // ABT 06-DEC-2016 - C-001677 - Added the two status to optimise the query and also not to change returned lines to canceled
                                                 AND    DeliveryStatus__c !=: ASPISConstants.ORD_LINE_STATUS_RETURNED
                                                 AND    DeliveryStatus__c !=: ASPISConstants.ORD_LINE_STATUS_CANCELED])
            {
                // check if the order line purchase order is canceled using the set canceledPurchaseOrderIdSet
                if(canceledPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c))
                {
                    // Check if the old status of the purchase order is DRAFTQUOTE
                    if(mapOldPurchaseOrder.get(currentOrderLine.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
                    {
                        currentOrderLine.DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_CANCELED;
                        orderLineToUpdateList.add(currentOrderLine);
                    }
                    // Check if the old status of the purchase order is ISSUED
                    else if(mapOldPurchaseOrder.get(currentOrderLine.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_ISSUED)
                    {
                        // Update only the order lines with suppliable yes
                        if(currentOrderLine.Suppliable__c == 'YES')
                        {
                            currentOrderLine.DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_CANCELED;
                            orderLineToUpdateList.add(currentOrderLine);
                        }
                    }
                    // otherwise for any other status
                    else
                    {
                        // update the order line with suppliable yes and acceptedcheck is true
                        if( currentOrderLine.Suppliable__c == 'YES' &&
                            currentOrderLine.AcceptedCheck__c == true)
                        {
                            currentOrderLine.DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_CANCELED;
                            orderLineToUpdateList.add(currentOrderLine);
                        }
                    }
                    //WCH 03/12/2018 C-002877: Erreur Validation Rule sur Champ Suppliable de Orderline
                    if(String.isBlank(currentOrderLine.Suppliable__c)){
                        currentOrderLine.Suppliable__c='NO';
                    }
                }
                Datetime estimatedDeliveryDatetime;
                // check if the order line purchase order is indelivery and acceptedCheck is true
                // DUN 10/10/2017 case 2040 added draftquoteR4OrderFRPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c) trello ticket 415
                if( (indeliveryPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c) || draftquoteR4OrderFRPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c)) &&
                    currentOrderLine.Suppliable__c == 'YES' &&
                    currentOrderLine.AcceptedCheck__c == true)
                {
                     //Utils_BusinessDays businessDays = (mapCountryCodeBusinessDays.containsKey(currentOrderLine.PurchaseOrder__r.TECH_AssessmentCountryCode__c)) ? mapCountryCodeBusinessDays.get(currentOrderLine.PurchaseOrder__r.TECH_AssessmentCountryCode__c) : mapCountryCodeBusinessDays.get('DEFAULT');
                    //BusinessHours businessDays = (mapCountryCodeBusinessDays.containsKey(currentOrderLine.PurchaseOrder__r.TECH_AssessmentCountryCode__c)) ? mapCountryCodeBusinessDays.get(currentOrderLine.PurchaseOrder__r.TECH_AssessmentCountryCode__c) : mapCountryCodeBusinessDays.get('DEFAULT');
                    BusinessHours businessDays = ASPISConstants.getBusinessHours(currentOrderLine.PurchaseOrder__r.TECH_AssessmentCountryCode__c); 

                    if(indeliveryPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c)){
                        currentOrderLine.DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
                    }

                    // check if purchase order SLADeliveryEntryDate__c is not null and order line ExpectedDeliveryDuration__c is not null
                    if( currentOrderLine.PurchaseOrder__r.SLADeliveryEntryDate__c != null && 
                        currentOrderLine.ExpectedDeliveryDuration__c != null && 
                        indeliveryPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c))
                    {
                        //DUN 20/03/2018 C-002301
                        Datetime slaDate = currentOrderLine.PurchaseOrder__r.SLADeliveryEntryDate__c;
                        Integer offset = UserInfo.getTimezone().getOffset(slaDate);
                        Datetime slaDateDelivery = slaDate.addSeconds(offset/1000);

                        //currentOrderLine.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(currentOrderLine.PurchaseOrder__r.SLADeliveryEntryDate__c), Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c));
                        //estimatedDeliveryDatetime = BusinessHours.add(BusinessDays.id,Datetime.valueOf(currentOrderLine.PurchaseOrder__r.SLADeliveryEntryDate__c),Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                        estimatedDeliveryDatetime = BusinessHours.add(BusinessDays.id,slaDateDelivery,Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                        currentOrderLine.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());
                    }
                    else if(currentOrderLine.PurchaseOrder__r.SLAQuotationEntryDate__c != null && 
                        currentOrderLine.ExpectedDeliveryDuration__c != null &&
                        draftquoteR4OrderFRPurchaseOrderIdSet.contains(currentOrderLine.PurchaseOrder__c))
                    {
                        //DUN 20/03/2018 C-002301
                        Datetime slaDate = currentOrderLine.PurchaseOrder__r.SLAQuotationEntryDate__c;
                        Integer offset = UserInfo.getTimezone().getOffset(slaDate);
                        Datetime slaDateQuotation = slaDate.addSeconds(offset/1000);

                         //currentOrderLine.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(currentOrderLine.PurchaseOrder__r.SLAQuotationEntryDate__c), Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c));
                        //estimatedDeliveryDatetime = BusinessHours.add(BusinessDays.id,Datetime.valueOf(currentOrderLine.PurchaseOrder__r.SLAQuotationEntryDate__c),Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                        estimatedDeliveryDatetime = BusinessHours.add(BusinessDays.id,slaDateQuotation,Integer.valueOf(currentOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                        currentOrderLine.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());

                    }
                    orderLineToUpdateList.add(currentOrderLine);
                }
            }
        }

        // Check id there are invoices to query
        if(purchaseOrderIdToUpdateInvoiceSet.size() > 0)
        {
            for(Invoice__c currentInvoice : [SELECT Id
                                             FROM   Invoice__c
                                             WHERE  PurchaseOrder__c IN: purchaseOrderIdToUpdateInvoiceSet
                                             AND    Delete__c = false
                                             AND    (   RecordType.DeveloperName =: ASPISConstants.INVOICE_RT_DeveloperName_DISTRIBUTORINVOICE
                                                    OR  RecordType.DeveloperName =: ASPISConstants.INVOICE_RT_DeveloperName_DISTRIBUTORCREDITNOTE)
                                             // Added ABT 17-OCT-2016 due to all invoices even paid ones were set to payable
                                             AND    Status__c !=: ASPISConstants.INV_STATUS_PAID
                                             AND    Status__c != 'CLOSED'])
            {
                currentInvoice.Status__c = ASPISConstants.INV_STATUS_PAYABLE;
                invoicedToUpdateList.add(currentInvoice);
            }
        }

        // -----------------------------------------------------------------------------------------------------------------
        
        // ABT - 25-JAN-2017 - Optimisation
        if(canceledPurchaseOrderIdSet.size() > 0)
        {
            for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id,
                                                                (SELECT Id
                                                                FROM   Invoices__r
                                                                WHERE  (   RecordType.DeveloperName =: ASPISConstants.INVOICE_RT_DeveloperName_DISTRIBUTORINVOICE
                                                                        OR  RecordType.DeveloperName =: ASPISConstants.INVOICE_RT_DeveloperName_DISTRIBUTORCREDITNOTE))
                                                        FROM   PurchaseOrder__c
                                                        WHERE  Id IN: canceledPurchaseOrderIdSet])
            {
                // check if the canceled purchase order has at least an invoice
                if( currentPurchaseOrder.Invoices__r != null && 
                    currentPurchaseOrder.Invoices__r.size() > 0)
                {
                    currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
                }
                else
                {
                    currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
                }

                system.debug('@@@ mapPurchaseOrderToUpdate'+mapPurchaseOrderToUpdate);
                if (mapPurchaseOrderToUpdate.containsKey(currentPurchaseOrder.Id)){
                    mapPurchaseOrderToUpdate.get(currentPurchaseOrder.Id).Status__c   = currentPurchaseOrder.Status__c;
                }
                else{
                    mapPurchaseOrderToUpdate.put(currentPurchaseOrder.Id, new PurchaseOrder__c( Id = currentPurchaseOrder.Id,
                                                                                                    Status__c   = currentPurchaseOrder.Status__c));
                }

                // purchaseOrderToUpdate.add(currentPurchaseOrder);
                // there is no else part as purchase order is not set to ClosedKO until the offering process, therefore it remains in the CANCELED status
            }
        }

        //AMI 13/11/2018  C-001851 - Communication between Supplier vs B/S  
        //                         - Adding Check On User Type, so that tech bs account on case can be filled
        //                         - when a local admin passes a part to error
        //                         - query user type and accout if
        //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
        if(mapSOIdPO.size() > 0){
            mapDistributors = new map<Id,Account>([select Id, ContactUser__c from Account where Id in: setDistributorIds]);
            for(PrerequisiteOrder__c so : [select Id, HasSomeDeliveryIssuedCaseCreated__c , TECH_BodyshopCountryCode__c, BodyShop__c, Assessment__c, BodyShop__r.ContactUser__c,
                                                BodyShop__r.ContactUser__r.UserType,BodyShop__r.ContactUser__r.AccountId
                                           from PrerequisiteOrder__c 
                                           where Id in: mapSOIdPO.keySet()
                                           and HasSomeDeliveryIssuedCaseCreated__c = true]){
                if(mapSOIdPO.containsKey(so.Id)){
                    for(PurchaseOrder__c po : mapSOIdPO.get(so.Id)){
                        Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-SO', so.TECH_BodyshopCountryCode__c, po.Distributor__c, so.Assessment__c, po.Id, so.Id, null, so.BodyShop__r.ContactUser__c, '-DeliveryProblem');
                        if(newCase != null){
                            newCase.OwnerId = mapDistributors.get(po.Distributor__c).ContactUser__c;

                            //AMI 13/11/2018  C-001851 - Communication between Supplier vs B/S  
                            //                         - Adding Check On User Type, so that tech bs account on case can be filled
                            //                         - when a local admin passes a part to error
                            //                         - updating tech bs account on case
                            if(string.isNotBlank(system.label.CommunityLicenseName) && 
                                string.isNotBlank(so.BodyShop__r.ContactUser__r.UserType) &&
                                (system.label.CommunityLicenseName.toLowercase()).contains(so.BodyShop__r.ContactUser__r.UserType.toLowerCase()) &&
                                so.BodyShop__r.ContactUser__r.AccountId != null){
                                    newCase.Tech_BSAccount__c = so.BodyShop__r.ContactUser__r.AccountId;
                            }

                            casesToInsertList.add(newCase);
                            system.debug('## newCase ' + newCase);
                        }
                    }
                }
            }

        }
        system.debug('## casesToInsertList ' + casesToInsertList);
        // -----------------------------------------------------------------------------------------------------------------

        // check if there are nay cases to insert
        if(casesToInsertList.size() > 0)
        {
            insert casesToInsertList;
        }

        // check if there are any order lines to update
        if(orderLineToUpdateList.size() > 0)
        {
            update orderLineToUpdateList;
        }

        // check if there are invoices to update
        if(invoicedToUpdateList.size() > 0)
        {
            update invoicedToUpdateList;
        }

        // ABT 30-MAR-2017 - C-001823
        // Launching the bundle generation before passing the purchase order to indelivery
        if(respondedPurchaseOrderIdSet.size() > 0)
        {
            AP34BundleGeneration.generateBundlesOffers(respondedPurchaseOrderIdSet);
        }
        system.debug('## newPurchaseOrderList.size()' + newPurchaseOrderList.size());
        system.debug('## mapOldPurchaseOrder.size()' + mapOldPurchaseOrder.size());

        // checks if parent Assessment has all purchase orders issued or responded and if so trigger it to Offering
        AP04AssessmentsAllQuoted.assessmentsQuoted(newPurchaseOrderList, mapOldPurchaseOrder);

        // Update the assessment if all of its PO is rejected or canceled
        system.debug('## ap18AssessmentSet Update 1' + ap18AssessmentSet);
        if(ap18AssessmentSet.size() > 0)
        {
            if(System.isBatch() || System.isFuture())
            {
                AP18SetAssessmentStatus.updateAssessment(ap18AssessmentSet);
            }
            else
            {
                AP18SetAssessmentStatus.updateAssessmentAsync(ap18AssessmentSet);
            }
        }

        // if(ap27PurchaseOrderList.size() > 0 && AP27SyncPOSOInternalComment.isFirstRun())
        // {
        //     AP27SyncPOSOInternalComment.updateSOAndRelatedPOInternalComment(ap27PurchaseOrderList);
        // }

        // Update the sales order BodyShopOrderNumber__c
        if(salesOrderIdToSyncBodyShopNumberSet.size() > 0)
        {
            updateSalesOrderBodyShopNumber(salesOrderIdToSyncBodyShopNumberSet);
        }

        if(salesOrderIdSet.size() > 0)
        {
            ASPISServiceOrderDeliveryConfirmed.executeServiceOrderDeliveryConfirmed(salesOrderIdSet);
        }

        // -------------------------------------------------------------------------------------------------------
        system.debug('##  Update mapPurchaseOrderToUpdate' + mapPurchaseOrderToUpdate);

        if(mapPurchaseOrderToUpdate.size() > 0)
        {
            update mapPurchaseOrderToUpdate.values();
        }  

        system.debug('## ap18AssessmentSet Update 2' + assessmentIdSet);
        if(assessmentIdSet.size() > 0)
        {
            if(System.isBatch() || System.isFuture())
            {
                AP18SetAssessmentStatus.updateAssessmentStatus(assessmentIdSet);
            }
            else
            {
                AP18SetAssessmentStatus.updateAssessmentStatusAsync(assessmentIdSet);
            }
        }

        //DUN 09/11/2016 case 1669  
         //if(setPOId.size() > 0 && !AP30ShippingLineCreation.hasrun)
         //{  
         //   system.debug('## calling AP30');
         //   AP30ShippingLineCreation.createShippingLine(setPOId,setPOdistId);
         //}

        // -------------------------------------------------------------------------------------------------------

        // ABT - 05-APR-2017
        if(draftQuotePurchaseOrderIdSet.size() > 0 || inDeliveryEmailPurchaseOrderIdSet.size() > 0 )
        {
            Set<Id> emailPOIdSet = new Set<Id>();
            emailPOIdSet.addAll(draftQuotePurchaseOrderIdSet);
            emailPOIdSet.addAll(inDeliveryEmailPurchaseOrderIdSet);



            Set<Id> orderEmailIdSet             = new Set<Id>();
            // Set<Id> quotationEmailIdSet         = new Set<Id>();
            Set<Id> quotationOrderEmailIdSet    = new Set<Id>();
            
            for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, Assessment__c, Assessment__r.OrderOrigin__c
                                                         FROM   PurchaseOrder__c
                                                         WHERE  Id =: emailPOIdSet])
            {
                if(currentPurchaseOrder.Assessment__c != null)
                {
                     if (draftQuotePurchaseOrderIdSet.contains(currentPurchaseOrder.Id) && currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Order')

                    {
                        // if (currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Order')
                        // {
                            orderEmailIdSet.add(currentPurchaseOrder.Id);
                        // }
                        // else if (currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Quotation')
                        // {
                        //     quotationEmailIdSet.add(currentPurchaseOrder.Id);
                        // }
                    }
                    else if (inDeliveryEmailPurchaseOrderIdSet.contains(currentPurchaseOrder.Id) && currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Quotation')
                    {
                        quotationOrderEmailIdSet.add(currentPurchaseOrder.Id);
                    }
                }
            }

            system.debug('## orderEmailIdSet ' + orderEmailIdSet);
            system.debug('## quotationOrderEmailIdSet ' + quotationOrderEmailIdSet);
            if( orderEmailIdSet.size() > 0 ||
                /*quotationEmailIdSet.size() > 0 ||*/
                quotationOrderEmailIdSet.size() > 0)
            {
                //DUN 12/09/2017 case 2020
                if(System.isBatch())
                {
                    AP35R4SendPurchaseOrderEmail.sendEmail(orderEmailIdSet, /*quotationEmailIdSet*/ new Set<Id>(), quotationOrderEmailIdSet);
                }else if(System.isFuture()){//WCH 13/04/2020 C-003707
                    //do nothing
                    system.debug('do not send email to distributor');
                }
                else
                {
                    AP35R4SendPurchaseOrderEmail.sendEmailASync(orderEmailIdSet, /*quotationEmailIdSet*/ new Set<Id>(), quotationOrderEmailIdSet);
                }
                
            }
        }

        //AMI 11/07/2017 - Set DE PO/SO to CLOSEDOK for Agency Mode
        if(ap39DeliveredPurchaseOrderSet.size() > 0){
            AP39AgencyMode.closedPODEAgencyMode(ap39DeliveredPurchaseOrderSet);  
        }

        //RLA 18/06/2020 C-003700: IG - orderConfirmation
        if (mapOrderConfirmationFuture.size() > 0 || mapOrderConfirmation.size() > 0 ){
            REST_OrderConfirmation.sendConfirmationBulk(mapOrderConfirmationFuture, mapOrderConfirmation);
        }
        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - onAfterUpdate --------------------------');
    }

    public void createOrderLines(Map<Id, List<PurchaseOrder__c>> mapAssessmentPurchaseOrders, Set<Id> distributorIdSet)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - createOrderLines --------------------------');

        // List of order lines to be inserted
        List<OrderLine__c> orderLinesToInsertList = new List<OrderLine__c>();
        set<String> substituteSet = new set<String>();
        set<String> substituteSetAll = new set<String>();
        map<String, DistributorPrice__c> substituteMap = new map<String, DistributorPrice__c>();
        map<String, DistributorPrice__c> substituteMapNONAXA = new map<String, DistributorPrice__c>();

        //RLA 07/10/2020 IGO no rebate
        String insuranceBroker;


        // Map of the distributors of the set passed as parameter
        Map<Id, Account> mapDistributors = new Map<Id, Account>([SELECT Id, Categories__c, DistributorCarBrandSupplied__c, CarBrandsSuppliedAgency__c, /*ASE: 08/05/18: C-002278*/ Feature__c
                                                                 FROM   Account
                                                                 WHERE  Id IN: distributorIdSet
                                                                 AND    RecordType.DeveloperName =: ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor]);
        System.debug('mapDistributors=' + mapDistributors);
        
        // Retrieve the part list of the assessments from the keyset of mapAssessmentPurchaseOrders and loop in it
       //DUN 02/05/2018  C-002488 added check not to create Orderlines
        // DUN 08/06/2018  C-001837 : Added field Distributors__c
        list<Partlist__c> plList = [    SELECT  Id, PartNumber__c, Description__c, Type__c, Quantity__c, Price__c, VAT__c, ProducerName__c, Assessment__c, Assessment__r.CrossReferences__c,
                                                SelectedByBS__c, Assessment__r.Manufacturer__c, /* ASE 18/04/2018  C-002477:*/Alpha_Scale_MRID__c, Assessment__r.OrderOrigin__c, 
                                                /*ASE: 08/05/18: C-002278*/ DistributorPriceId__c, Distributor__c, Assessment__r.Feature__c, ASNetPrice__c , Distributors__c
                                                ,DiscountRecord__c,  /*ASE: 23/01/19: C-003030*/ CrossReferenceId__c, CrossReferenceId__r.Name,
                                                DiscountRecord__r.Rebate__c, DiscountRecord__r.AS_Discount__c, DiscountRecord__r.BSdiscount__c,OriginalPart__c,  OriginalPart__r.Price__c, OriginalPart__r.OriginalPart__r.Price__c,//RLA 20/11/2018 C-002782 CJP A'
                                                CrossReferenceId__r.UseClassicSourcing__c, CrossReferenceId__r.IAMPartNumber__c//RLA 02/05/2019 C-003142
                                                ,ForTechSubsNumber__c, //RLA IGP 
                                                Assessment__r.insuranceBroker__c,TechCatalog_Price_Dist_Connected__c                                        
                                        FROM    PartList__c
                                        WHERE   Assessment__c IN: mapAssessmentPurchaseOrders.keySet()
                                        AND     RecordType.DeveloperName !=: ASPISConstants.PARTLIST_RT_DeveloperName_Labour
                                        AND     IsSourced__c = false
                                        AND     Assessment__r.OrderOrigin__c != 'ASPIS'];
        if(plList.size() > 0){

            // [A' part type] need to group Cross References to get their Distributor Price
            for (PartList__c currentPart : plList) {
                
                /*if(currentPart.PartNumber__c.left(5) == 'ASCR-' || currentPart.PartNumber__c.left(5) == 'ASFR-'){
                    substituteSet.add(currentPart.PartNumber__c);
                } */

                 if (String.isNotBlank(currentPart.Assessment__r.insuranceBroker__c)) {
                    insuranceBroker = currentPart.Assessment__r.insuranceBroker__c;

                }

                if (String.isNotBlank(currentPart.Assessment__r.CrossReferences__c) && substituteSet.isEmpty()) {
                    for (String crossRef : currentPart.Assessment__r.CrossReferences__c.split(';')) {
                        substituteSet.add(crossRef);
                    }
                }
                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                if (currentPart.CrossReferenceId__c != null){
                    substituteSetAll.add(currentPart.CrossReferenceId__r.Name);
                }
                

               
            }
            // ASE : 12/10/2017 : added 'DistributorPrice__c.Active__c = true
            system.debug('## substituteSet: '+substituteSet);

            if (!substituteSetAll.isEmpty()) {               
                for (DistributorPrice__c dp : [Select DistributorID__c, DistributorPublicPrice__c, DistributorPartClass__c, DistributorDiscount__c, DistributorPartNumber__c,
                                                CrossReference__r.Name, CrossReference__r.ASNetPrice__c, CrossReference__r.ASPublicPrice__c, CrossReference__r.IAMPartNumber__c, CrossReference__r.IAMManufacturer__c
                                                , CrossReference__r.NONAXA_AS_Public_Price__c, CrossReference__r.NONAXA_AS_Net_Price__c //RLA 19/05/2021 C-004337:
                                              from DistributorPrice__c 
                                              where CrossReference__r.Name in :substituteSetAll AND DistributorID__c IN :distributorIdSet AND DistributorPrice__c.Active__c = true AND DistributorPrice__c.isDeleted__c = false]) {                   
                    if(!substituteMap.containsKey(dp.DistributorID__c + '-' + dp.CrossReference__r.Name ) && substituteSet.contains(dp.CrossReference__r.Name)){
                       substituteMap.put(dp.DistributorID__c + '-' + dp.CrossReference__r.Name , dp);
                    }

                     if(!substituteMapNONAXA.containsKey(dp.DistributorID__c + '-' + dp.CrossReference__r.Name )){
                        substituteMapNONAXA.put(dp.DistributorID__c + '-' + dp.CrossReference__r.Name , dp);
                    }

                }
            }
            system.debug('## substituteMap: '+substituteMap);

            String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);


            for(PartList__c currentPart : plList){
                // no need to check if the currentPart's assessment is in the map as we are quering it using the map
                // Loop in the purchase orders and create the order lines
                for(PurchaseOrder__c currentPurchaseOrder : mapAssessmentPurchaseOrders.get(currentPart.Assessment__c)){
                    // check if the cuurent purchase order is a manual creation
                    String substituteMapKey = currentPurchaseOrder.Distributor__c + '-' + /*ASE: 23/01/19: C-003030 currentPart.PartNumber__c */currentPart.CrossReferenceId__r.Name;
                    //String substituteMapKey = currentPurchaseOrder.Distributor__c + '-' + currentPart.PartNumber__c ;
                    //Decimal cataloguePrice; 
                    //String partType;    
                    //Decimal ASPercent;  
                    system.debug('## currentPurchaseOrder: '+currentPurchaseOrder);
                    system.debug('## currentPart.PartNumber__c: '+currentPart.PartNumber__c);
                    system.debug('## currentPart: '+currentPart );
                    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                    Boolean isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => currentPurchaseOrder.TECH_AssessmentCountryCode__c, 'entity' => currentPurchaseOrder.TECH_AssessmentEntityRules__c, 'fromProcess' => 'Order'});
 
                    DistributorPrice__c distPrice;
                    if (isNonAxa){
                        if(substituteMapNONAXA.containsKey(substituteMapKey)){
                            distPrice = substituteMapNONAXA.get(substituteMapKey);
                            //cataloguePrice = distPrice.DistributorPublicPrice__c;  
                            //partType = distPrice.DistributorPartClass__c;  
                            //ASPercent = distPrice.DistributorDiscount__c;  
                        }
                    }
                    else{
                    if(substituteMap.containsKey(substituteMapKey)){
                        distPrice = substituteMap.get(substituteMapKey);
                        //cataloguePrice = distPrice.DistributorPublicPrice__c;  
                        //partType = distPrice.DistributorPartClass__c;  
                        //ASPercent = distPrice.DistributorDiscount__c;  
                    }
                    }
                    
                    system.debug('## distPrice: '+distPrice);
                    /*else{
                        cataloguePrice = currentPart.Price__c;  
                        partType = currentPart.Type__c; 
                        ASPercent = 0;  
                    }*/    

                    Boolean insertOrderLine = false;
                    if(currentPurchaseOrder.Manual_Creation__c == true || distPrice != null) {
                        insertOrderLine = true;
                    }
                    // else if the part type exists in the distributors categories, create the order line
                    //DUN 04/01/2018  C-002135 agency Mode V2 Added field CarBrandsSuppliedAgency__c
                    //AMI 05/10/2018  C-001837 : Added condition so that classic sourcing is based on supppliable category whereas
                    //                direct order soucing is based on type 
                    else if(String.isNotBlank(currentPart.Type__c) && 
                            mapDistributors.containsKey(currentPurchaseOrder.Distributor__c) && 
                            currentPart.Assessment__r.Manufacturer__c != null &&
                            (string.isBlank(currentPurchaseOrder.TECHRulesAppliedDescription__c)
                                //RLA 29/04/2019 C-003142 Cross Ref Sourcing R4 for Spain
                            || (string.isNotBlank(currentPurchaseOrder.TECHRulesAppliedDescription__c)
                               && currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES'
                               && currentPart.Distributors__c == null
                                   ) ) &&
                            mapDistributors.get(currentPurchaseOrder.Distributor__c).Categories__c != null &&
                            mapDistributors.get(currentPurchaseOrder.Distributor__c).Categories__c.contains(currentPart.Type__c) &&
                            ((mapDistributors.get(currentPurchaseOrder.Distributor__c).DistributorCarBrandSupplied__c != null &&
                            mapDistributors.get(currentPurchaseOrder.Distributor__c).DistributorCarBrandSupplied__c.contains(currentPart.Assessment__r.Manufacturer__c)) || 
                            (mapDistributors.get(currentPurchaseOrder.Distributor__c).CarBrandsSuppliedAgency__c != null &&
                            mapDistributors.get(currentPurchaseOrder.Distributor__c).CarBrandsSuppliedAgency__c.contains(currentPart.Assessment__r.Manufacturer__c))))
                    {
                        insertOrderLine = true;
                    }
                    //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                    else if(currentPart.Distributors__c != null && currentPart.Distributors__c.contains(currentPurchaseOrder.Distributor__c)){
                        insertOrderLine = true;
                    }
                    
                    //14-JUL-2017  DUN case 001966: prevent Creation of parts which are not selected By BS
                    if(ASPISConstants.manualSourcingPO == true && !currentPart.SelectedByBS__c){
                        insertOrderLine = false;
                    }
                    /* ASE 18/04/2018  C-002477:*/
                    String partNumber = (distPrice != null ? distPrice.DistributorPartNumber__c : currentPart.PartNumber__c); //(distPrice != null ? distPrice.CrossReference__r.IAMPartNumber__c : currentPart.PartNumber__c),
                    system.debug('@@ insertOrderLine: '+insertOrderLine);
                    if (insertOrderLine) {
                        //ASE: 08/05/2018 : C-002278
                        if(currentPart.Distributor__c != null){
                            if(currentPart.Distributor__c == currentPurchaseOrder.Distributor__c){
                                system.debug('## has distributor');   
                                orderLinesToInsertList.add(createOL(currentPart, distPrice, currentPurchaseOrder,prefixPartNumberIGO));
                            }    
                        }    
                        //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                        else if(currentPart.Distributors__c != null && currentPart.Distributors__c.contains(currentPurchaseOrder.Distributor__c)){
                            system.debug('## has distributors' + currentPart.Distributors__c);   
                            orderLinesToInsertList.add(createOL(currentPart, distPrice, currentPurchaseOrder,prefixPartNumberIGO));
                        } 
                        else{
                            if(currentPart.Assessment__r.Feature__c != null){
                                if(mapDistributors.containsKey(currentPurchaseOrder.Distributor__c) && mapDistributors.get(currentPurchaseOrder.Distributor__c).Feature__c != null && mapDistributors.get(currentPurchaseOrder.Distributor__c).Feature__c == currentPart.Assessment__r.Feature__c){
                                    system.debug('## has feature');
                                    orderLinesToInsertList.add(createOL(currentPart, distPrice, currentPurchaseOrder,prefixPartNumberIGO));                                
                                }
                            }                            
                            else{
                                system.debug('## normal process');
                                orderLinesToInsertList.add(createOL(currentPart, distPrice, currentPurchaseOrder,prefixPartNumberIGO));
                            }                         
                        } 
                        //String partNumber = distPrice != null ? distPrice.DistributorPartNumber__c: currentPart.PartNumber__c;
                        //orderLinesToInsertList.add(new OrderLine__c(
                        //                        PartNumber__c       = (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber,//(distPrice != null ? distPrice.CrossReference__r.IAMPartNumber__c : currentPart.PartNumber__c), 
                        //                        Description__c      = currentPart.Description__c,
                        //                        Type__c             = (distPrice != null ? distPrice.DistributorPartClass__c : currentPart.Type__c),
                        //                        Quantity__c         = currentPart.Quantity__c,
                        //                        AssessmentPrice__c  = currentPart.Price__c,
                        //                        CataloguePrice__c   = (distPrice != null ? distPrice.DistributorPublicPrice__c : currentPart.Price__c),
                        //                        VAT__c              = currentPart.VAT__c,
                        //                        Manufacturer__c     = currentPart.ProducerName__c,//(distPrice != null ? distPrice.CrossReference__r.IAMManufacturer__c: currentPart.ProducerName__c), 
                        //                        PartList__c         = currentPart.Id,
                        //                        PurchaseOrder__c    = currentPurchaseOrder.Id,
                        //                        // ABT - 13-JAN-2016 - C-001856
                        //                        Rebate__c           = currentPurchaseOrder.Rebate__c,
                        //                        AXADiscount__c      = (distPrice != null ? distPrice.DistributorDiscount__c : 0),
                        //                        DistributorPrice__c = (distPrice != null ? distPrice.Id : null),
                        //                        ASBodyshopPrice__c  = (distPrice != null ? distPrice.CrossReference__r.ASPublicPrice__c : null),
                        //                        ASBodyshopNetPrice__c = (distPrice != null ? distPrice.CrossReference__r.ASNetPrice__c  : null),
                        //                        /* ASE 18/04/2018  C-002477:*/
                        //                        AlphaScaleMRID__c   = currentPart.Alpha_Scale_MRID__c,
                        //                        TechExternalId__c   = currentPurchaseOrder.Name + '-' + currentPart.Id));

                    }
                }
            }
        }
        // using database.insert to allow partial insert.
        // In case quantity is 0, it fails --- Comments from previous class
        if(orderLinesToInsertList.size() > 0)
        {
            System.debug('orderLinesToInsertList.size()=' + orderLinesToInsertList.size());
            System.debug('orderLinesToInsertList' + orderLinesToInsertList);
            List<Database.SaveResult> resultList = Database.insert(orderLinesToInsertList, false);

            // show errors
            for (Database.SaveResult result : resultList) {
                if (!result.isSuccess()) {
                    System.debug('ERROR Database.SaveResult=' + result);                
                }
            }
        }

        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - createOrderLines --------------------------');
    }

    public void updateSOToCanceled(Set<Id> soIdOfCanceledPos){
        system.debug('##Canceling so');
        map<Id,list<PurchaseOrder__c>> mapSoListPos = new map<Id,list<PurchaseOrder__c>> ();
        list<PrerequisiteOrder__c> listSoToCancel = new list <PrerequisiteOrder__c>();

        for(PurchaseOrder__c childPo : [Select id,PrerequisiteOrder__c,PrerequisiteOrder__r.Status__c,Status__c,AgencyMode__c  
                                        from PurchaseOrder__c 
                                        where PrerequisiteOrder__c IN: soIdOfCanceledPos
                                        And PrerequisiteOrder__r.Status__c !=: ASPISConstants.PRE_ORDER_STATUS_CANCELED 
                                        And PrerequisiteOrder__r.Status__c !=: ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO
                                        And PrerequisiteOrder__r.Status__c !=: ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK]){
            if(childPo.PrerequisiteOrder__c != null){
                if(mapSoListPos.containsKey(childPo.PrerequisiteOrder__c)){
                    mapSoListPos.get(childPo.PrerequisiteOrder__c).add(childPo);
                }else{
                    mapSoListPos.put(childPo.PrerequisiteOrder__c,new list <PurchaseOrder__c>{childPo});
                }
            }
        }
        system.debug('##mapSoListPos: '+mapSoListPos);
        Integer counterCanceledPos = 0;
        for(String soKey: mapSoListPos.keySet()){
            counterCanceledPos = 0;
            for(PurchaseOrder__c poToCheckCanceled: mapSoListPos.get(soKey)){
                //VSU C-002214 Added condition on agency mode
                if(poToCheckCanceled.AgencyMode__c == false && (poToCheckCanceled.Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED
                    /* ||poToCheckCanceled.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK  WCH 08/06/2020 C-003744*/
                    ||poToCheckCanceled.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)){
                    counterCanceledPos ++;
                }
            }
            system.debug('##counterCanceledPos: '+counterCanceledPos);
            if(counterCanceledPos == mapSoListPos.get(soKey).size()){
                PrerequisiteOrder__c soToSetToCanceled = new PrerequisiteOrder__c(id=soKey,Status__c=ASPISConstants.PRE_ORDER_STATUS_CANCELED);
                listSoToCancel.add(soToSetToCanceled);
            }
        }
        system.debug('##listSoToCancel: '+listSoToCancel);
        if(listSoToCancel.size() > 0){
            update listSoToCancel;
        }
    }
    
    public void updateSalesOrderBodyShopNumber(Set<Id> salesOrderIdSet)
    {
        System.debug('-------------------------- START METHOD PurchaseOrderTriggerHandler - updateSalesOrderBodyShopNumber --------------------------');

        // Map sales order Id and the BodyShopOrderNumbers contatenated by ;
        Map<Id, String> mapSalesOrderIdBodyShopOrderNumber  = new Map<Id, String>();
        // List of sales order to update
        List<PrerequisiteOrder__c> salesOrderToUpdateList   = new List<PrerequisiteOrder__c>();

        // Retrieving all the purchase order of thoses sales orders and looping in them
        for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, PrerequisiteOrder__c, BodyShopOrderNumber__c
                                                     FROM   PurchaseOrder__c
                                                     WHERE  PrerequisiteOrder__c IN: salesOrderIdSet
                                                     AND    BodyShopOrderNumber__c != null])
        {
            // Check if the sales order id already exists
            if(!mapSalesOrderIdBodyShopOrderNumber.containsKey(currentPurchaseOrder.PrerequisiteOrder__c))
            {
                mapSalesOrderIdBodyShopOrderNumber.put(currentPurchaseOrder.PrerequisiteOrder__c, currentPurchaseOrder.BodyShopOrderNumber__c + ';');
            }
            // if it already exists concatenated the bodyshopordernumber to it
            else
            {
                String currentValue = mapSalesOrderIdBodyShopOrderNumber.get(currentPurchaseOrder.PrerequisiteOrder__c);
                mapSalesOrderIdBodyShopOrderNumber.put(currentPurchaseOrder.PrerequisiteOrder__c, currentValue + currentPurchaseOrder.BodyShopOrderNumber__c + ';');
            }
        }
        
        // loop in the map mapSalesOrderIdBodyShopOrderNumber and generate the sales order object to update
        for(Id salesOrderId : mapSalesOrderIdBodyShopOrderNumber.keySet())
        {   //WCH 16/11/2018: C-002895, remove all duplicate PO.BodyShopOrderNumber__c for concatenation
            Set<String> uniquePOBodyShopOderNumber = new Set<String>(mapSalesOrderIdBodyShopOrderNumber.get(salesOrderId).split(';'));
            uniquePOBodyShopOderNumber.remove(null);uniquePOBodyShopOderNumber.remove('');
            salesOrderToUpdateList.add(new PrerequisiteOrder__c(Id                      = salesOrderId,
                                                                BodyshopOrderNumber__c  = String.join(new List<String>(uniquePOBodyShopOderNumber),';')));
        }

        if(salesOrderToUpdateList.size() > 0)
        {
            update salesOrderToUpdateList;
        }
        System.debug('-------------------------- END METHOD PurchaseOrderTriggerHandler - updateSalesOrderBodyShopNumber --------------------------');
    }     

    //DUN 02/05/2018  C-002488 - Fill field EncodedId__c 
    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }
    // ASE: 08/05/2018  C-002278 - FR - New Distributor PSA 
    public static OrderLine__c createOL(PartList__c currentPart , DistributorPrice__c distPrice, PurchaseOrder__c currentPurchaseOrder, string prefixPartNumberIGO){

        map<String,Manufacturer_reference__c> mapMRFromAlphastore = AlphaStore.mapPartNumberToMR.size() > 0 ? AlphaStore.mapPartNumberToMR : (VFC09_PartListSelection.mapPartNumberToMR.size() > 0?VFC09_PartListSelection.mapPartNumberToMR : new map<String,Manufacturer_reference__c>());//KEM 06/12/2022 C-004824
                
        system.debug('## Start create OL');
        system.debug('## currentPart'+currentPart);
        string partNumber = '';
        if (distPrice != null ){
            partNumber = distPrice.DistributorPartNumber__c;
        }
        else if (currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES'
            && String.isNotBlank(currentPart.CrossReferenceId__c)
            && (currentPart.PartNumber__c).startsWith('ASCR-')
            && !currentPart.CrossReferenceId__r.UseClassicSourcing__c ){
            partNumber = currentPart.CrossReferenceId__r.IAMPartNumber__c; 

        }
        else{
            partNumber = currentPart.ForTechSubsNumber__c ;
        }

        //String partNumber = distPrice != null ? distPrice.DistributorPartNumber__c: currentPart.PartNumber__c;
        system.debug('## distPrice'+distPrice);
        system.debug('## partNumber'+partNumber);
        //WCH 19/05/2021 C-004160
        CountryCodeInformationsMapping__c countryCodeMapping = CountryCodeInformationsMapping__c.getall().containsKey((String.isBlank(currentPurchaseOrder.TECH_AssessmentCountryCode__c)?':-(':currentPurchaseOrder.TECH_AssessmentCountryCode__c))?CountryCodeInformationsMapping__c.getall().get(currentPurchaseOrder.TECH_AssessmentCountryCode__c):CountryCodeInformationsMapping__c.getall().get('DEFAULT');
        Boolean activateFamilyBrand=countryCodeMapping!=null && countryCodeMapping.activateOLFamilyBrand__c && !partNumber.startsWith('ASP-') && !(currentPart.PartNumber__c).startsWith('ASCR-');
        
        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
        Boolean isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => currentPurchaseOrder.TECH_AssessmentCountryCode__c, 'entity' => currentPurchaseOrder.TECH_AssessmentEntityRules__c, 'fromProcess' => 'Order'});
        
        
        Decimal Rebate;
        Decimal CataloguePrice;
        //RLA 27/11/2018 C-002782 CJP A'
        if ( (currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE' && !(currentPart.ForTechSubsNumber__c).startsWith('ASP-') && distPrice == null)
            ||  (currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE' && String.isNotBlank(currentPart.Alpha_Scale_MRID__c) && string.isNotBlank(prefixPartNumberIGO) 
                    && currentPart.Alpha_Scale_MRID__c.startsWith(prefixPartNumberIGO) )){
            Rebate = 0;  
            system.debug('## rebate here');

        }
        else if (currentPart.DiscountRecord__c != null ){
            Rebate = currentPart.DiscountRecord__r.Rebate__c;
        }
        else{
            Rebate = currentPurchaseOrder.Rebate__c;
        }

        if (distPrice != null ){
            CataloguePrice  = distPrice.DistributorPublicPrice__c;
        }
        else if (currentPart.OriginalPart__c != null 
                && currentPart.OriginalPart__r.OriginalPart__r != null
                && currentPart.DiscountRecord__c != null
                && (currentPart.ForTechSubsNumber__c).startsWith('ASP-')){
            system.debug('## currentPart.OriginalPart__c'+currentPart.OriginalPart__r.Price__c);
            system.debug('## currentPart.OriginalPart__c'+currentPart.OriginalPart__r.OriginalPart__r.Price__c);

            CataloguePrice = currentPart.OriginalPart__r.OriginalPart__r.Price__c;
        }
        else{
            system.debug('## currentPart.Price__c'+currentPart.Price__c);

            CataloguePrice   = currentPart.Price__c;
        } 

        system.debug('## End create OL');
       

        return new OrderLine__c(PartNumber__c       = (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber,//(distPrice != null ? distPrice.CrossReference__r.IAMPartNumber__c : currentPart.PartNumber__c), 
                                Description__c      = currentPart.Description__c,
                                Type__c             = (distPrice != null ? distPrice.DistributorPartClass__c : currentPart.Type__c),
                                Quantity__c         = currentPart.Quantity__c,
                                AssessmentPrice__c  = currentPart.Price__c,
                                CataloguePrice__c   = CataloguePrice,
                                VAT__c              = currentPart.VAT__c,
                                Manufacturer__c     = currentPart.ProducerName__c,//(distPrice != null ? distPrice.CrossReference__r.IAMManufacturer__c: currentPart.ProducerName__c), 
                                //BrandOfSparePart__c = activateFamilyBrand?(String.isBlank(currentPart.ProducerName__c)?currentPurchaseOrder.Brand__c:currentPart.ProducerName__c):'',//WCH 19/05/2021 C-004160
                                BrandOfSparePart__c = mapMRFromAlphastore.size() > 0  &&  mapMRFromAlphastore.containsKey(partNumber)?mapMRFromAlphastore.get(partNumber).Brand__c :(activateFamilyBrand?(String.isBlank(currentPart.ProducerName__c)?currentPurchaseOrder.Brand__c:currentPart.ProducerName__c):''),//KEM 06/12/2022 C-004824
                                FamilyOfSparePart__c = mapMRFromAlphastore.size() > 0  &&  mapMRFromAlphastore.containsKey(partNumber)?mapMRFromAlphastore.get(partNumber).Sub_family__c :'',//KEM 06/12/2022 C-004824
                                PartList__c         = currentPart.Id,
                                PurchaseOrder__c    = currentPurchaseOrder.Id,
                                // ABT - 13-JAN-2016 - C-001856
                                // ASE 09/07/2018 C-002659 : Prices & Part Type to be sent to Coler          
                                //Rebate__c           = currentPurchaseOrder.Rebate__c,
                                //Rebate__c           = (currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE' && !(currentPart.PartNumber__c).startsWith('ASP-') && distPrice == null) ? 0 : currentPurchaseOrder.Rebate__c,
                                Rebate__c = Rebate,//RLA 27/11/2018 C-002782 CJP A'
                                AXADiscount__c      = (distPrice != null ? distPrice.DistributorDiscount__c : currentPart.DiscountRecord__c != null  ? currentPart.DiscountRecord__r.AS_Discount__c : 0),//RLA 27/11/2018 C-002782 CJP A'
                                DistributorPrice__c = (distPrice != null ? distPrice.Id : null),
                                //DUN 14.06.2018 case 2580 when null, consider as 0 instead
                                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                                ASBodyshopPrice__c  = (distPrice != null ? (isNONAXA && (distPrice.CrossReference__r.NONAXA_AS_Public_Price__c != 0 || distPrice.CrossReference__r.NONAXA_AS_Public_Price__c != null ) ?  distPrice.CrossReference__r.NONAXA_AS_Public_Price__c : distPrice.CrossReference__r.ASPublicPrice__c) : ((partNumber.startsWith('ASP-')) ? ((isNONAXA && currentPart.TechCatalog_Price_Dist_Connected__c != null ) ? currentPart.TechCatalog_Price_Dist_Connected__c: currentPart.Price__c) : 0)),

                                ASBodyshopNetPrice__c = (distPrice != null ? ( isNONAXA && (distPrice.CrossReference__r.ASNetPrice__c != 0 || distPrice.CrossReference__r.ASNetPrice__c != null) ?  distPrice.CrossReference__r.NONAXA_AS_Net_Price__c : distPrice.CrossReference__r.ASNetPrice__c)  : (partNumber.startsWith('ASP-') ? currentPart.ASNetPrice__c : 0)),
                                /* ASE 18/04/2018  C-002477:*/
                                AlphaScaleMRID__c   = currentPart.Alpha_Scale_MRID__c,
                                TechExternalId__c   = currentPurchaseOrder.Name + '-' + currentPart.Id,
                                //RLA 27/11/2018 C-002782 CJP A'
                                BodyShopDiscount__c = (currentPart.DiscountRecord__c != null  ? currentPart.DiscountRecord__r.BSdiscount__c : 0),
                                //RLA 12/10/2020 IG
                                TechSubstituteType__c = RestDistributorUtility.typeOfSubstitute(currentPart.Alpha_Scale_MRID__c,prefixPartNumberIGO )
                                );
    }
}