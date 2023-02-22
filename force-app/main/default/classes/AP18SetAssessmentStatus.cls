/*************************************************************************************
Class Name - AP18SetAssessmentStatus
Version - 1.0
Created Date - 15 OCT 2015
Function - Si aucun PO n'est disponible pour l'offering, le Chiffrage passe à REJECTED

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date            Description
* ----------            ----------      -----------------------
* Ashwina Seetaram      15/10/2015      C-001275: Original Version
* Dourga Unmole         11/02/2016      C-001522: Clarifications sur les rejets
                                        et annulations des commandes
* Shamina M             16/02/2016      C-001518: Removed unnecessary debug logs
* Ashutosh Betchoo      04/11/2016      C-001677: Added method updateAssessmentStatus
* Dourga U              09/03/2017      C-001818: Defect : Quotation a distributor cannot cancel a part (trello no34)
                                        added @future to method updateAssessment and method updateAssessmentStatus
* Dourga U              19/05/2017      Added update of assessment reason failure when all PO related are canceled by distributor(trello no35)
* Vaynee S              11/01/2018      Ticket 89 Email R4 BE
* Ruksaar L             27/04/2018      Case-2002 Data purge Long
* Welsa C               16/06/2020      C-003744 Cancelation of one of two POs in an order also momentarily canceled the second PO and created several invoices and Credit notes in SO
*Ruksaar L              03/07/3030      C-003773: IG - New Custom Setting: CustomerInformationMapping

*************************************************************************************/
public without sharing class AP18SetAssessmentStatus
{
    private static Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMappings;
    //when PO is canceled
    @future
    public static void updateAssessmentAsync(set<Id> assessIdSet)
    {
        updateAssessment(assessIdSet);
    }

    public static void updateAssessment(set<Id> AssessIdSet){
        Map<String, Set<String>> rejectedCanceledPOMap = new Map<String, Set<String>>();
        List<Assessment__c> updatedAssessList = new List<Assessment__c>();
        //System.debug('#########  AssessIdSet:'+AssessIdSet);
        // build a map of AssessId and a list of its related PO' status
        for(AggregateResult ar: [select count(id) poSize, Assessment__c,Status__c from PurchaseOrder__c where Assessment__c IN:AssessIdSet GROUP BY Assessment__c, Status__c ORDER BY Assessment__c]){
            if(!rejectedCanceledPOMap.containsKey((String)ar.get('Assessment__c'))){
                Set<String> statusSet= new Set<String>();
                statusSet.add((String) ar.get('Status__c'));
                rejectedCanceledPOMap.put((String) ar.get('Assessment__c'), statusSet);
            }
            else{
                rejectedCanceledPOMap.get((String) ar.get('Assessment__c')).add((String) ar.get('Status__c'));
            }
        }
        //System.debug('########### rejectedCanceledPOMap:'+rejectedCanceledPOMap);
        //looping in map rejectedCanceledPOMap to update status of Assessment which has all its PO's status set to REJECTED OR CANCELLED
        for(String AssessId:rejectedCanceledPOMap.keySet()){
            if((rejectedCanceledPOMap.get(AssessId).size()==2 && (rejectedCanceledPOMap.get(AssessId).contains('REJECTED') && rejectedCanceledPOMap.get(AssessId).contains('CANCELED')))
               || (rejectedCanceledPOMap.get(AssessId).size()==1 && rejectedCanceledPOMap.get(AssessId).contains('REJECTED'))
               || (rejectedCanceledPOMap.get(AssessId).size()==1 && rejectedCanceledPOMap.get(AssessId).contains('CANCELED'))
            ){
                //case 1522
                //Assessment__c updatedAssess = new Assessment__c(status__c='REJECTED', Id =AssessId, ReasonFailure__c='NoPurchaseOrderAvailable');
                Assessment__c updatedAssess = new Assessment__c(status__c='CANCELED', Id =AssessId, ReasonFailure__c='NoPurchaseOrderAvailable');
                updatedAssessList.add(updatedAssess);
            }
        }
        //System.debug('########### updatedAssessList:'+updatedAssessList);
        //updating updatedAssessList
        if(updatedAssessList.size()>0){
            ASPISWithoutSharingExceptions.updateAssessmentList(updatedAssessList);
        }
    }
    
    @future
    public static void updateAssessmentStatusAsync(Set<Id> assessmentIdSet)
    {
        updateAssessmentStatus(assessmentIdSet);
    }

    public static void updateAssessmentStatus(Set<Id> assessmentIdSet)
    {
        Map<Id, Assessment__c> mapAssessmentToUpdate = new Map<Id, Assessment__c>();

        for(Assessment__c currentAssessment : [ SELECT  Id, RecordType.DeveloperName,
                                                        (SELECT Id, Status__c
                                                         FROM   PrerequisiteOrders__r),
                                                        (SELECT Id, Status__c, Reason__c
                                                         FROM   PurchaseOrders__r)
                                                FROM    Assessment__c
                                                WHERE   Id IN: assessmentIdSet])
        {
            // Loop in Purchase Order first to get the information required
            System.debug('@@@ currentAssessment: ' + currentAssessment);
            // Variables to count the number of purchase orders in CLOSEDOK
            Integer noPurchaseOrderClosedOK         = 0;
            // Variables to count the number of purchase orders in CLOSEDKO
            Integer noPurchaseOrderClosedKO         = 0;
            // Variables to count the number of purchase orders in CANCELEDINVOICE
            Integer noPurchaseOrderCanceledInvoice  = 0;
            // Variables to count the number of purchase orders having reason failure UNSUPPLIEDQUOTE(Canceled by Distributor)
            Integer noPurchaseOrderUnsuppliedQuote  = 0;
            // Number of Purchase Order for that assessment
            Integer noOfPurchaseOrder               = currentAssessment.PurchaseOrders__r.size();

            // loop in the purchase orders
            for(PurchaseOrder__c currentPurchaseOrder : currentAssessment.PurchaseOrders__r)
            {
                if( currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK)
                {
                    noPurchaseOrderClosedOK++;
                }
                else if(currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)
                {
                    noPurchaseOrderClosedKO++;
                }
                else if(currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE)
                {
                    noPurchaseOrderCanceledInvoice++;
                }
                if( currentPurchaseOrder.Reason__c == ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE)
                {
                    noPurchaseOrderUnsuppliedQuote++;
                }
            }


            // check the assessment sales order first
            if(currentAssessment.PrerequisiteOrders__r.size() > 0)
            {
                // loop in the sales order even there is 1
                for(PrerequisiteOrder__c currentSalesOrder : currentAssessment.PrerequisiteOrders__r)
                {
                    if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_INVOICED)
                    {
                        mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                            Status__c   = ASPISConstants.ASSESS_STATUS_INVOICED));
                    }
                    else if (currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE)
                    {
                        mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                            Status__c   = ASPISConstants.ASSESS_STATUS_CANCELED));
                    }
                    else if (currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
                    {
                        // Update assessment only if all purchase orders are closed
                        if(noPurchaseOrderClosedKO == noOfPurchaseOrder)
                        {
                            mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                                Status__c   = ASPISConstants.ASSESS_STATUS_CLOSEDKO));
                        }
                        else if(noPurchaseOrderCanceledInvoice > 0)
                        {
                            // assessment is set to CANCELED
                            mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                                Status__c   = ASPISConstants.ASSESS_STATUS_CANCELED));
                        }
                    }
                    else if (currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK)
                    {
                        // check if all purchase orders are closed...whether it is CLOSEDKO or CLOSEDOK
                        if(((noOfPurchaseOrder - (noPurchaseOrderClosedOK + noPurchaseOrderClosedKO)) == 0) || (((noOfPurchaseOrder - (noPurchaseOrderClosedOK + noPurchaseOrderClosedKO + noPurchaseOrderCanceledInvoice)) == 0) /* WCH 16/06/2020 C-003744 */))
                        {
                            mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                                Status__c   = ASPISConstants.ASSESS_STATUS_CLOSEDOK));
                        }
                        // ABT 08-JUN-2017 - C-001660 - To have the Assessment Reopened when PO is reopened
                        else
                        {
                            mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                                Status__c   = ASPISConstants.ASSESS_STATUS_INVOICED));
                        }
                    }
                    //In case rejected by distributor 
                    else if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELED)
                    {
                        if(noPurchaseOrderUnsuppliedQuote > 0 && currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
                        {
                            mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id               = currentAssessment.Id,
                                                                                                Status__c        = ASPISConstants.ASSESS_STATUS_CLOSEDKO,
                                                                                                ReasonFailure__c = 'CanceledByDistributor'));
                        }
                    }
                }
            }
            else
            {
                // there is no SalesOrder for that assessment
                // therefore the assessment status will be based on the status of the purchase orders
                // Cannot have CLOSEDOK for an assessment not having a sales order

                // Check if all puchase orders are CLOSEDKO
                if(noPurchaseOrderClosedKO == noOfPurchaseOrder)
                {
                    Assessment__c newAss =  new Assessment__c(  Id          = currentAssessment.Id,
                                                                Status__c   = ASPISConstants.ASSESS_STATUS_CLOSEDKO);
                    if(noPurchaseOrderUnsuppliedQuote == noOfPurchaseOrder){
                        newAss.ReasonFailure__c = 'CanceledByDistributor';
                    }
                    mapAssessmentToUpdate.put(currentAssessment.Id,newAss);
                }
                // check if there is at least 1 canceled invoice
                else if(noPurchaseOrderCanceledInvoice > 0)
                {
                    // assessment is set to CANCELED
                    mapAssessmentToUpdate.put(currentAssessment.Id, new Assessment__c(  Id          = currentAssessment.Id,
                                                                                        Status__c   = ASPISConstants.ASSESS_STATUS_CANCELED));
                }
            }
        }

        if(mapAssessmentToUpdate.size() > 0)
        {            
            system.debug('### mapAssessmentToUpdate: ' + mapAssessmentToUpdate);          
            update mapAssessmentToUpdate.values();
        }
    }

    /**
     * update Assessment Reason Failure and status
     * @param listAssessment list of assessment to update
     */
    public static void updateAssessmentReasonFailure(list<Assessment__c> listAssessment)
    {
        map<Id,list<PurchaseOrder__c>> mapAssIdListPO = new map<Id,list<PurchaseOrder__c>>();
        Integer countPOClosedKO;
        Boolean hasOLRjected;

        list <PurchaseOrder__c> listPurchaseOrders = [SELECT Id, Status__c, Assessment__c, 
                                                             (SELECT Id, AcceptedCheck__c, PreselectedForOrder__c, Suppliable__c
                                                              FROM OrderLines__r 
                                                              WHERE AcceptedCheck__c = false
                                                              AND PreselectedForOrder__c = true
                                                              AND Suppliable__c = 'NO')
                                                      FROM PurchaseOrder__c
                                                      WHERE Assessment__c in: listAssessment];

        for(PurchaseOrder__c po : listPurchaseOrders){
            if(!mapAssIdListPO.containsKey(po.Assessment__c)){
                mapAssIdListPO.put(po.Assessment__c,new list <PurchaseOrder__c>{po});
            }
            else{
                mapAssIdListPO.get(po.Assessment__c).add(po);
            }
        }

        for(Assessment__c ass : listAssessment){
            if(mapAssIdListPO.containsKey(ass.Id)){
                countPOClosedKO = 0;
                hasOLRjected = false;
                for(PurchaseOrder__c po : mapAssIdListPO.get(ass.Id)){
                    if(po.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO){
                        countPOClosedKO++;
                    }
                    if(po.OrderLines__r.size() > 0){
                        hasOLRjected = true;
                    }
                }
                if(countPOClosedKO == mapAssIdListPO.get(ass.Id).size() && hasOLRjected){
                    ass.ReasonFailure__c = 'CanceledByDistributor';
                    ass.Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
                }
            }
        }
    }

    
    @future
    public static void sendEmailToBodyShopAsync(Set<Id> setAssessmentId)
    {
        sendEmailToBodyShop(setAssessmentId);
    }

    @TestVisible
    private static List<Messaging.SendEmailResult> emailResultList;

    //@future(callout=true)
    public static void sendEmailToBodyShop(Set<Id> setAssessmentId)
    {
        // Retrieving the required data
        List<Assessment__c> assessmentList = [SELECT Id, Name, TECH_EntityCountryCode__c, BodyShop__r.ContactUser__c, BodyShop__r.ContactUser__r.LanguageLocaleKey,InsuranceBroker__c
                                                     FROM   Assessment__c
                                                     WHERE  Id IN: setAssessmentId 
                                                     AND    BodyShop__r.ContactUser__c != null];
        
        List<String> emailTemplateDevNamesList = (String.isNotBlank(Label.SendCanceledByDistributorEmailTemplateDevName)) ? Label.SendCanceledByDistributorEmailTemplateDevName.split(';') : new List<String>();

        Map<String, EmailTemplate> mapLanguageCodeEmailTemplate = new Map<String, EmailTemplate>();

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNamesList])
        {
            String languageCode = currentEmailTemplate.DeveloperName.substringAfter('_'); //VSU 10-01-17 replaced tech_countrycode
            mapLanguageCodeEmailTemplate.put(languageCode, currentEmailTemplate);
        }
        
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();

        // if(currentEmailTemplate != null)
        if(mapLanguageCodeEmailTemplate.size() > 0)
        {
            for(Assessment__c currentAssessment : assessmentList)
            {
                //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                CustomerInformationsMapping__mdt customerInformationsMapping;
                Boolean allowEmails = true;
                if (String.isnotblank(currentAssessment.InsuranceBroker__c)){
                    customerInformationsMapping = RestDistributorUtility.getcustomerMapping(currentAssessment.InsuranceBroker__c);
                }
                if (customerInformationsMapping != null && !customerInformationsMapping.AllowBodyshopEmails__c ){
                    allowEmails = false;
                }
                

                // checking if the email template for that country is found in the map
                // else skip it
                if(!mapLanguageCodeEmailTemplate.containsKey(currentAssessment.BodyShop__r.ContactUser__r.LanguageLocaleKey))
                {
                    continue;
                }
                //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                if (allowEmails){
                Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(mapLanguageCodeEmailTemplate.get(currentAssessment.BodyShop__r.ContactUser__r.LanguageLocaleKey).Id, currentAssessment.BodyShop__r.ContactUser__c, currentAssessment.Id);
                currentEmail.setTargetObjectId(currentAssessment.BodyShop__r.ContactUser__c);
                currentEmail.setSubject(currentEmail.getSubject());
                currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                currentEmail.setSaveAsActivity(false);
                currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                emailListToSend.add(currentEmail);
                }
            }

            if(emailListToSend.size() > 0)
            {
                emailResultList = Messaging.sendEmail(emailListToSend);
            }
        }
    }

  
}