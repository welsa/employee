/*************************************************************************************
Class Name - ASPISBatchSetPOStatus
Version - 1.0
Created Date - 25 Nov 2015
Function -  select all purchase Orders having invoices to be processed.
2. set POTotalExpectedAmount in the selected POs
3. update invoice status in PO
4. Set PO to payable if all related invoices are payable
5. set InvoiceTotalAmount__c in the selected POs

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             25/05/2015  Original Version
* Ashwina S             22/12/15    Reuse trigger
* Ashwina S             18/01/2016  Replace field TechToBeProcessed__c instead of TECH_InvoiceSentToExponens__c
* Dourga U              12/02/2016  case C-001529 : added field NotDeliveredCaseCreated__c to avoid duplicate of case creation
* Shamina M             15/02/2016  case C-001405 : Nouveau statut "payé" (moved from trigger to batch solution)
* Shamina M             16/02/2016  case C-001518 : Removed unnecessary debug logs
* Ashwina S             18/02/2016  restrict scope to PO which do not have 'PAID' as status
* Dourga U              21/04/2016  case C-001608 : ASPISBatchSetPOStatus force recalculation of TotalExpectedAmount__c
* Dourga U              23/05/2016  case C-001638 : Update the query of the batch setPOStatus not to be based on "Techtobeprocessed"
*                                                   but on all PO in status "Delivered Confirmed"...
* Ashwina S             27/05/2016  case C-001633 -  Add logical delete boolean on invoices – In progress
* Ashwina S             18/01/2017  C-001860: only DELIVEREDCONFIRMED, CANCELEDINVOICE PO are queried. 
                                    -  Cases need not to be created
* Vaynee  S             19/04/2018  C-002489 - Total Expected Amount recalculated
* Welsa C               12/08/2019  case C-003353 : automated change of status if expected amount is less 50 €
* Ruksaar L             17-JAN-2019 C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
* Welsa C               29/06/2020  C-003835 : PO changes from CLOSEDKO to Payable
* Welsa C               08/07/2020  C-003851 - PO-809271 in Agency Mode but set to PAYABLE
*************************************************************************************/
global without sharing class ASPISBatchSetPOStatus implements schedulable, Database.Batchable <SObject>, Database.Stateful{

    // map<error string, error string>
    Map<String, String> mapInvErrorsCreation = new Map<String, String>();       
    Map<String, String> mapPOErrorsCreation = new Map<String, String>();          
        

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
    }

    //define Query to return a list of purchase orders whose TechToBeProcessed__c = true
    //DUN 11/03/2016 added recordtype distributor invoice and distributor credit note
    //public String query = 'Select Name,TotalExpectedAmount__c,TECH_BodyshopCountryCode__c,Distributor__c,Assessment__c,Status__c,PrerequisiteOrder__c,TECH_AssessmentCountryCode__c,NotDeliveredCaseCreated__c,(select Id, AXATotalPrice__c, AcceptedCheck__c from OrderLines__r where AcceptedCheck__c = true and DeliveryStatus__c = \'DELIVERED\' AND OrderType__c = \'FINAL\'),(Select Number__c, TotalNet__c, Status__c, RecordTypeId From Invoices__r where RecordType.DeveloperName  = \'DISTRIBUTORINVOICE\' or RecordType.DeveloperName  = \'DISTRIBUTORCREDITNOTE\') from PurchaseOrder__c Where TechToBeProcessed__c = true and Status__c!= \'PAID\'';

    //DUN 23/05/2016 Changed query (case C-001638)
    //ASE 18/01/2017 scope of PO is taken only on status  DELIVEREDCONFIRMED, CANCELEDINVOICE
    /*public String query = 'Select Id, Name,TotalExpectedAmount__c,TECH_BodyshopCountryCode__c,Distributor__c,Assessment__c,Status__c,PrerequisiteOrder__c,TECH_AssessmentCountryCode__c,NotDeliveredCaseCreated__c,'+
                            ' (select Id, AXATotalPrice__c, AcceptedCheck__c from OrderLines__r where AcceptedCheck__c = true and DeliveryStatus__c = \'DELIVERED\' AND OrderType__c = \'FINAL\') , '+
                            ' (Select Number__c, TotalNet__c, Status__c, Delete__c,RecordTypeId From Invoices__r where RecordType.DeveloperName  = \'DISTRIBUTORINVOICE\' or RecordType.DeveloperName  = \'DISTRIBUTORCREDITNOTE\') '+
                          ' from PurchaseOrder__c '+
                          ' Where Status__c = \'DELIVEREDCONFIRMED\' ' +
                          //' OR Status__c = \'INDELIVERY\' '+
                        //   ' OR Status__c = \'PAYABLE\' ' +
                          ' OR Status__c = \'CANCELEDINVOICE\'';*/
                          
    //VSU 19/04/18 Case C-002489
    public String query = 'Select Id, Name,TotalExpectedAmount__c,TECH_BodyshopCountryCode__c,Distributor__c,Assessment__c,Status__c,PrerequisiteOrder__c,TECH_AssessmentCountryCode__c,NotDeliveredCaseCreated__c,'+
                            ' Recalculate_total_expected_amount__c,TotalInvoicesAmount__c,'+ //WCH 12/08/2019 C-003353
                            ' (select Id, AXATotalPrice__c, AcceptedCheck__c from OrderLines__r where AcceptedCheck__c = true AND   DeliveryStatus__c = \'DELIVERED\' AND OrderType__c != \'SHIPPING COST\' AND TechGeneratedFinal__c = false AND OrderType__c != \'ORIGINAL\') , '+
                            ' (Select Number__c, TotalNet__c, Status__c, Delete__c,RecordTypeId From Invoices__r where RecordType.DeveloperName  = \'DISTRIBUTORINVOICE\' or RecordType.DeveloperName  = \'DISTRIBUTORCREDITNOTE\') '+
                          ' from PurchaseOrder__c '+
                          ' Where Status__c = \'DELIVEREDCONFIRMED\' ' +
                          //' OR Status__c = \'INDELIVERY\' '+
                        //   ' OR Status__c = \'PAYABLE\' ' +
                          ' OR Status__c = \'CANCELEDINVOICE\'' +
                          ' OR (Recalculate_total_expected_amount__c = true and AgencyMode__c=false) ';//17-01/2020 RLA C-003507 08/07/2020 WCH C-003851


    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('####ASPISBatchSetPOStatus#### Batch Started = ' + DateTime.now());
        // Query all PurchaseOrder__c with TechToBeProcessed__c checked
        System.debug('####ASPISBatchSetPOStatus end:'+query);
        mapInvErrorsCreation = new Map<String, String>();       
        mapPOErrorsCreation = new Map<String, String>();    
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<PurchaseOrder__c> scope) {
        System.debug('############# start execute');

        // variables required to create case
        //String OBJECTCODE = '-PO';
        //String PROCESSNOTDELIVERED = '-NotDelivered';
        // list keeping case list to be inserted if PO status is not DELIVEREDCONFIRMED
        //List<Case__c> newCaseList = new List<Case__c>();

        //map to save purchaseOrder id and TECH_AssessCountryCode in order to access invMarginMap custom settings
        //Map<Id, String> POIdTECH_AssessCountryCodeMap = new Map<Id, String>();
        Map<String, InvoiceMargin__c> invMarginMap = InvoiceMargin__c.getAll();

        // ABT -- Moved inside loop
        // variables to save total invoice amount related to a PO
        // Decimal totalInvoice;
        // Decimal invtotalNetPrice;
        // Decimal totalCreditNote;

        // POInvMap to keep purchaseOrder id and all related invoices
        // Map<Id,Set<Id>> POInvMap = new Map<Id,Set<Id>>();
        // POInvTotalAmountMap Map to keep purchaseOrder id and total amount of all related invoices
        //Map<Id,Decimal> POInvTotalAmountMap = new Map<Id,Decimal>();

        // mapPOOrderLine to keep purchaseOrder id and all related orderlines
        //Map<Id,List<OrderLine__c>> mapPOOrderLine = new Map<Id,List<OrderLine__c>>();
        // variable to save total expected amount related to a PO
        Decimal totalASPrice;

        //Shamina case 1405
        //Integer countInv = 0;

        // list keep updated invoices
        //List<Invoice__c> payableInvList = new List<Invoice__c>();
        Map<Id, list<Invoice__c>> payableInvMap = new Map<Id, list<Invoice__c>>();
        // list keep updated purchase orders
        //List<PurchaseOrder__c> purchaseOrderToUpdateList = new List<PurchaseOrder__c>();
        Map<Id, PurchaseOrder__c> purchaseOrderToUpdateMap = new Map<Id, PurchaseOrder__c>();

        for(PurchaseOrder__c PO1: scope){
            // ABT moved variables inside loop
            Decimal totalInvoice;
            Decimal invtotalNetPrice;
            Decimal totalCreditNote;

            Integer countInv = 0;
            // ASE: 27/05/16 :  case 1633
            Set<Id> validInvoiceSet = new Set<Id>();
            Set<Id> invSet = new Set<Id>();
            totalASPrice = 0;
            //POIdTECH_AssessCountryCodeMap.put(PO1.Id,PO1.TECH_AssessmentCountryCode__c);
            //PurchaseOrder__c updatedPO = new PurchaseOrder__c(Id=PO1.Id, TechToBeProcessed__c= false);
            // ABT 19-OCT-2016 - C-001677 - TechToBeProcessed__c no more used so removed it 
            PurchaseOrder__c updatedPO = new PurchaseOrder__c(Id=PO1.Id);

            //DUN 23/05/2016 case 1638 No Longer calculated -- 29/06/2016 removed comment due to bug in prod
            //DUN 21/04/2016 case 1608
            if(PO1.OrderLines__r.size()>0){
                for(OrderLine__c ol : PO1.OrderLines__r){
                    totalASPrice += ol.AXATotalPrice__c;
                }
            }

            updatedPO.TotalExpectedAmount__c = totalASPrice;
            updatedPO.Recalculate_total_expected_amount__c = false; //17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
            // ASE: 18/01/17 : not required
            /*//create case if PO status is not DELIVEREDCONFIRMED
            if( PO1.Status__c != 'DELIVEREDCONFIRMED' && 
                PO1.Status__c != 'PAYABLE' && 
                PO1.Status__c != 'CANCELEDINVOICE' && 
                PO1.NotDeliveredCaseCreated__c == false)
            {
                system.debug('## OBJECTCODE:'+OBJECTCODE);
                system.debug('## PO1.TECH_BodyshopCountryCode__c:'+PO1.TECH_BodyshopCountryCode__c);
                system.debug('## PO1.Assessment__c:'+PO1.Assessment__c);
                system.debug('## PO1.Distributor__c:'+PO1.Distributor__c);
                system.debug('## PO1.Status__c:'+PO1.Status__c);
                system.debug('## PO1.PrerequisiteOrder__c:'+PO1.PrerequisiteOrder__c);

                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, PO1.TECH_BodyshopCountryCode__c, PO1.Distributor__c, PO1.Assessment__c, PO1.Id, PO1.PrerequisiteOrder__c, null, UserInfo.getUserId(), PROCESSNOTDELIVERED);
                system.debug('#### newCase:'+newCase);
                if(newCase != null)
                {
                    newCaseList.add(newCase);
                    updatedPO.NotDeliveredCaseCreated__c = true;
                }
            }*/

            if( (PO1.Status__c == 'DELIVEREDCONFIRMED' || 
                // PO1.Status__c == 'PAYABLE' || 
                PO1.Status__c == 'CANCELEDINVOICE')
                || PO1.Recalculate_total_expected_amount__c )//17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
            {
                // calculating totalNetPrice of invoices related to PO
                totalInvoice        = 0;
                invtotalNetPrice    = 0;
                totalCreditNote     = 0;

                system.debug('## POId: '+PO1.Id);
                if(PO1.Invoices__r.size() > 0)
                {
                    // looping in PO's related list of invoices to calculate total invoice amount
                    for(Invoice__c inv: PO1.Invoices__r)
                    {
                        // ASE: 27/05/16 :  case 1633
                        if(!inv.Delete__c)
                        {
                            validInvoiceSet.add(inv.id);

                            if(inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId())
                            {
                                totalInvoice += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
                            }
                            else if(inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId())
                            {
                                totalCreditNote += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
                            }
                            //invSet.add(inv.id);

                            //Shamina M case 1405
                            if(inv.Status__c == 'PAID' || inv.Status__c == 'CLOSED')
                            {
                                countInv++;
                            }
                            else
                            {
                                invSet.add(inv.id);
                            }
                        }
                    }
                    // keeping purchaseOrder id and all related invoices
                    // POInvMap.put(PO1.Id, invSet);
                    //  total amount = total invoice amount - total credit note amount
                    system.debug('## totalInvoice:'+totalInvoice + ' '+totalCreditNote);
                    invtotalNetPrice = (totalInvoice - totalCreditNote).setScale(2);

                    // keep purchaseOrder id and total amount of all related invoices
                    //POInvTotalAmountMap.put(PO1.Id,invtotalNetPrice);
                }

                updatedPO.TotalInvoicesAmount__c = invtotalNetPrice;

                system.debug('## totalASPrice:'+totalASPrice + ' '+invtotalNetPrice);

                // check if PO1.TotalExpectedAmount__c equals to totalNetPrice,
                if( (PO1.Status__c != 'CANCELEDINVOICE' && totalASPrice == invtotalNetPrice) || 
                    (PO1.Status__c == 'CANCELEDINVOICE' && invtotalNetPrice == 0)){

                    //set PO status to Payable
                    //DUN 23/05/2016 case 1638 PO status is set to payable only if Invoice Status is validated
                    //updatedPO.Status__c = 'PAYABLE';

                    //set all invoices to Payable
                    for(Id invId: invSet)
                    {
                        // ABT 02-DEC-2016 - C-001625 - Removed TechToBeProcessed__c
                        Invoice__c payableInv = new Invoice__c(Status__c = 'PAYABLE', Id = invId, purchaseOrder__c = PO1.Id/*, TechToBeProcessed__c=true*/);
                        //payableInvList.add(payableInv);
                        if(!payableInvMap.containsKey(PO1.Id)){
                            List<Invoice__c> payableInvList = new List<Invoice__c>();
                            payableInvList.add(payableInv);
                            payableInvMap.put(PO1.Id, payableInvList);
                        }
                        else{
                            payableInvMap.get(PO1.Id).add(payableInv);
                        }               
                    }
                }
                //WCH 29/06/2020 C-003835
                List<String> setOfUnChangeablePOStatus = (system.label.ListOfUnchangeablePOStatus).Split( ';' );

                // Set InvoiceStatus__c on PO
                if(invMarginMap.containsKey(PO1.TECH_AssessmentCountryCode__c))
                {
                    Double validationMargin = invMarginMap.get(PO1.TECH_AssessmentCountryCode__c).ValidationMargin__c;
                    if( /* PO1.Status__c != 'CANCELEDINVOICE' && */
                        String.isNotBlank(PO1.Status__c) && !setOfUnChangeablePOStatus.contains(PO1.Status__c) && /* WCH 29/06/2020 C-003835 */
                        (totalASPrice <= invtotalNetPrice + validationMargin
                        && totalASPrice >= invtotalNetPrice - validationMargin)
                        && (PO1.TECH_AssessmentCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeDE) ? !(PO1.TotalInvoicesAmount__c==null || PO1.TotalInvoicesAmount__c==0):true)//WCH 12/08/2019 C-003353
                      )
                    {
                        updatedPO.InvoiceStatus__c = 'VALIDATED';
                        updatedPO.Status__c = 'PAYABLE';
                    }
                    // C-001677
                    else if(/* PO1.Status__c == 'CANCELEDINVOICE' && */
                            String.isNotBlank(PO1.Status__c) && setOfUnChangeablePOStatus.contains(PO1.Status__c) && /* WCH 29/06/2020 C-003835 */
                            (0 <= invtotalNetPrice + validationMargin &&
                             0 >= invtotalNetPrice - validationMargin))
                    {
                        updatedPO.InvoiceStatus__c = 'VALIDATED';
                        // for canceled invoice, we don't update the purchase order
                    }
                    else
                    {
                        updatedPO.InvoiceStatus__c = 'NOTVALIDATED';
                        updatedPO.InvoiceStatusNotValidated__c = true;
                    }
                }
                else 
                {
                    system.debug('## here9');
                    if( /* PO1.Status__c != 'CANCELEDINVOICE' &&  */
                        String.isNotBlank(PO1.Status__c) && !setOfUnChangeablePOStatus.contains(PO1.Status__c) && /* WCH 29/06/2020 C-003835 */
                        totalASPrice == invtotalNetPrice)
                    {
                        updatedPO.InvoiceStatus__c = 'VALIDATED';
                        updatedPO.Status__c = 'PAYABLE';
                    }
                    // C-001677
                    else if(/* PO1.Status__c == 'CANCELEDINVOICE' && */ 
                            String.isNotBlank(PO1.Status__c) && setOfUnChangeablePOStatus.contains(PO1.Status__c) && /* WCH 29/06/2020 C-003835 */
                            invtotalNetPrice == 0)
                    {
                        updatedPO.InvoiceStatus__c = 'VALIDATED';
                    }
                    else
                    {
                        updatedPO.InvoiceStatus__c = 'NOTVALIDATED';
                        updatedPO.InvoiceStatusNotValidated__c = true;
                    }
                }

            }


            //Shamina M case 1405 - if all invoices of PO are PAID, set PO status to PAID
            //// ASE: 27/05/16 :  case 1633
            //if(PO1.Invoices__r.size() >0 && PO1.Invoices__r.size() == countInv && countInv > 0 )
            // ABT - So as it does not conflict with the ASPISBatchInvoice
            // if(  validInvoiceSet.size() > 0 && 
            //  validInvoiceSet.size() == countInv && 
            //  countInv > 0)
            // {
            //  updatedPO.Status__c = 'PAID';
            // }

            //purchaseOrderToUpdateList.add(updatedPO);
            purchaseOrderToUpdateMap.put(PO1.Id, updatedPO);
        }
        // commented by ASE on 22/12/15 and reuse trigger
        /*
        //loop in orderline to get determine total AS price and assign to related PO
        for (OrderLine__c ord : [select Id, AXATotalPrice__c, AcceptedCheck__c, PurchaseOrder__c,AdditionnalDiscount__c, (Select Id from AlternativeItem__r)
                                 from OrderLine__c
                                 where AcceptedCheck__c = true
                                 and PurchaseOrder__c in:POIdTECH_AssessCountryCodeMap.keyset()
                                 and DeliveryStatus__c = 'DELIVERED'
                                 and TechGeneratedFinal__c = false]){
            // build map of purchaseOrderId and related orderline list
            if (ord.AlternativeItem__r.size() == 0){
                if (mapPOOrderLine.containsKey(ord.PurchaseOrder__c)){
                    mapPOOrderLine.get(ord.PurchaseOrder__c).add(ord);
                }
                else{
                    List<OrderLine__c> oList = new List<OrderLine__c>();
                    oList.add(ord);
                    mapPOOrderLine.put(ord.PurchaseOrder__c,oList);
                }
            }
        }
        System.debug('###### mapPOOrderLine:'+mapPOOrderLine);

        // loop in mapPOOrderLine to calculate totalASPrice of PO
        for(Id POId: mapPOOrderLine.keyset()){
            /*totalASPrice = 0;
            // calculate totalASPrice
            for(OrderLine__c orderLine1:mapPOOrderLine.get(POId)){
                totalASPrice += orderLine1.AXATotalPrice__c;
            }
            System.debug('###### totalASPrice:'+POId+' : '+totalASPrice);
            // assign totalASPrice to TotalExpectedAmount__c in PO
            //PurchaseOrder__c updatedPO = new PurchaseOrder__c(Id=POId,TotalExpectedAmount__c=totalASPrice.setScale(2), TechToBeProcessed__c= false, TotalInvoicesAmount__c = POInvTotalAmountMap.get(POId));
            PurchaseOrder__c updatedPO = new PurchaseOrder__c(Id=POId, TechToBeProcessed__c= false, TotalInvoicesAmount__c = POInvTotalAmountMap.get(POId));

            // check if totalASPrice equals to totalNetPrice,
            if(totalASPrice == POInvTotalAmountMap.get(POId)){
                //set PO status to Payable
                updatedPO.Status__c = 'PAYABLE';

                //set all invoices to Payable
                for(Id invId: POInvMap.get(POId)){
                    Invoice__c payableInv = new Invoice__c(Status__c = 'PAYABLE', Id = invId,TechToBeProcessed__c=true);
                    payableInvList.add(payableInv);
                }
            }

            // Set InvoiceStatus__c on PO
            if(invMarginMap.get(POIdTECH_AssessCountryCodeMap.get(POId)) != null){
                if(totalASPrice <= POInvTotalAmountMap.get(POId) + invMarginMap.get(POIdTECH_AssessCountryCodeMap.get(POId)).ValidationMargin__c
                  && totalASPrice >= POInvTotalAmountMap.get(POId) - invMarginMap.get(POIdTECH_AssessCountryCodeMap.get(POId)).ValidationMargin__c){
                    updatedPO.InvoiceStatus__c = 'VALIDATED';
                }else{
                    updatedPO.InvoiceStatus__c = 'NOTVALIDATED';
                    updatedPO.InvoiceStatusNotValidated__c = true;
                }
            }
            else {
                if(totalASPrice == POInvTotalAmountMap.get(POId)){
                    updatedPO.InvoiceStatus__c = 'VALIDATED';
                }
                else{
                    updatedPO.InvoiceStatus__c = 'NOTVALIDATED';
                    updatedPO.InvoiceStatusNotValidated__c = true;
                }
            }
            purchaseOrderToUpdateList.add(updatedPO);
        }*/

        //////////////////////
        /* ASE: 27/04/17 bug in prod
        // updating Purchase orders
        if(purchaseOrderToUpdateList.size()>0){
            update purchaseOrderToUpdateList;
        }
        // ASE : 18/01/17
        // creating cases
        //if(newCaseList.size()>0){
            //insert newCaseList;
        //}

        // updating invoices
        if(payableInvList.size()>0){
            update payableInvList;
        }*/
        //////////////////////////////

        
        if(payableInvMap.size() > 0){
            list<Invoice__c> invList = new list<Invoice__c>();
            for(String key : payableInvMap.keyset()){
                //system.debug('## here14');
                invList.addAll(payableInvMap.get(key));
            }

            if(invList.size() > 0){
                //upsert assessments
                List<Database.SaveResult> uResults = Database.update(invList, false);
                for(Integer idx = 0; idx < uResults.size(); idx++) {
                    if(!uResults[idx].isSuccess()) { 
                        for(Database.Error err : uResults[idx].getErrors()){
                            mapInvErrorsCreation.put(invList[idx].Id, Label.Error + ': ' + err.getMessage());
                            if(purchaseOrderToUpdateMap.containsKey(invList[idx].PurchaseOrder__c)){
                                purchaseOrderToUpdateMap.remove(invList[idx].PurchaseOrder__c);
                            }                                          
                        }
                    }
                }
            }
        }


        if(purchaseOrderToUpdateMap.size() > 0){
            list<PurchaseOrder__c> POList = new list<PurchaseOrder__c>();
            for(String key : purchaseOrderToUpdateMap.keyset()){
                POList.add(purchaseOrderToUpdateMap.get(key));
            }
            List<Database.SaveResult> POResults = Database.update(POList, false);
            for(Integer idx = 0; idx < POResults.size(); idx++) {
                if(!POResults[idx].isSuccess()) {  
                    //generate the json that will be used for errors as reponse
                    for(Database.Error err : POResults[idx].getErrors()){
                        mapPOErrorsCreation.put(POResults[idx].Id, Label.Error + ': ' + err.getMessage());
                    }
                }
            }
        }   
    }

    private static List<Messaging.SingleEmailMessage> outErrorEmails = null;
    global void finish(Database.BatchableContext context) {
        sendErrorEmail(mapInvErrorsCreation, mapPOErrorsCreation);

    }

    @TestVisible
    private  void sendErrorEmail(Map<String, String> mapInvErrorsCreation, Map<String, String> mapPOErrorsCreation)
    {
        system.debug('## mapInvErrorsCreation:'+mapInvErrorsCreation);
        system.debug('## mapPOErrorsCreation:'+mapPOErrorsCreation);


        String errorMsg = ''; 
        if(mapInvErrorsCreation.size() > 0) { 
            errorMsg = 'The processing of the following invoices has failed while during ASPISBatchSetPOStatus: '
                        + '<br/><br/><table border="1"><tr><td><b>Invoice Id</b></td><td><b>Error Message:</b></td></tr>'; 

            String invErrList = '';  
            for(String invoiceId : mapInvErrorsCreation.keyset()){
                invErrList  = invErrList +  
                            + '<tr><td>' + invoiceId + '</td>'
                            + '<td>' + mapInvErrorsCreation.get(invoiceId) + '</td></tr>';
            }                         
            
            errorMsg = errorMsg + invErrList +'</table><br/><br/>';
        }
        
        if(mapPOErrorsCreation.size() > 0) { 
            errorMsg += 'The processing of the following Purchase Orders has failed while during ASPISBatchSetPOStatus: '
                        + '<br/><br/><table border="1"><tr><td><b>Purchase Order Id</b></td><td><b>Error Message:</b></td></tr>'; 

            String POList = '';  
            for(String POId : mapPOErrorsCreation.keyset()){
                POList  = POList +  
                        + '<tr><td>' + POId + '</td>'
                        + '<td>' + mapPOErrorsCreation.get(POId) + '</td></tr>';
            }                         
            
            errorMsg = errorMsg + POList +'</table><br/><br/>';
        }

        if(errorMsg!= ''){
        
            String emailBody = 'Hello, <br/><br/> ' + errorMsg + '<br/><br/>Regards, <br/> ASPIS Back Office Team';
                            
            outErrorEmails                          = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage l_objMail  = new Messaging.SingleEmailMessage();

            List<String> emailAddList = getMailAddresses(); 
            emailAddList.add('ashwina.seetaram@sc-mauritius.com');
            emailAddList.add('ashutosh.betchoo@sc-mauritius.com');  
            emailAddList.add('dourga.unmole@sc-mauritius.com');  
            l_objMail.setToAddresses(emailAddList);
            l_objMail.setSubject('ASPIS - ASPISBatchSetPOStatus failed in the Organisation ' + UserInfo.getOrganizationId());
            
            l_objMail.setHtmlBody(emailBody);
            outErrorEmails.add(l_objMail);
            
            if (outErrorEmails.size() > 0) {
                Messaging.sendEmail(outErrorEmails);
            }
        }
    }
    
    public List<String> getMailAddresses(){
        List<String> mailList       = new List<String>();
        List<String> mailAddresses  = new List<String>(); 

        for (GroupMember gm : [ SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'SystemAdmins']){
            mailList.add(gm.UserOrGroupId);
        }
    
        if(mailList.size() > 0){
            for(User usr :[ SELECT  Email FROM User WHERE Id IN : mailList]){
                mailAddresses.add(usr.Email);
            }
        }      
        return mailAddresses;
    }
}