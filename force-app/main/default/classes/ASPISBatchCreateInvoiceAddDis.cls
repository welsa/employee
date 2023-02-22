/*************************************************************************************
Class Name - ASPISBatchCreateInvoiceAddDis
Version - 1.0
Created Date - 29 Jan 2016
Function -  C-1502,C-1503,C-1390

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga U              27/01/2016  Original Version
* Ashwina S             28/01/2016  Update
* Shamina M             16/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S             22/02/2016  Call Batch class
* Ashutosh B            17/01/2017  C-001620 - Changed AdditionalDiscount to AdditionalDiscountAmount
* Dourga Unmole         04/05/2017  C-001904: No invoice/credit note needs to be generated for assessment in agency mode
* Dourga Unmole         08/01/2018  C-002135: Agency Mode V2 
* Dourga Unmole         21/03/2018  C-002400: Global invoices bug(Added AND Prerequisiteorder__r.TechIsInvoiced__c = true in query) 
* Vaynee Sungeelee      26/03/2018  C-002407: Invoices are not assigned to the BS or Distributor
*************************************************************************************/

/************************************************************************************
Execute batch on execute Anon ymous:
Database.executeBatch(new ASPISBatchCreateInvoiceAddDis(), 200);
*************************************************************************************/
global class ASPISBatchCreateInvoiceAddDis implements Database.Batchable<sObject>,Database.AllowsCallouts {
    /*********************************/
    //AMI 26/06/18 : Community Rollout 
    //             : Initialising aspis system and querying id
    public static id aspisSystemUserId = null;

    static{
        if(string.isNotBlank(system.label.UserAspisSystemName)){
            aspisSystemUserId = [select id,Name from User where Name = :system.label.UserAspisSystemName].Id;
        }
    }

    // wrapper containg credit note/invoice for each SO
    public class allInvoiceDetail{
        public Invoice__c creditNote;
        public Invoice__c invoice;

         public allInvoiceDetail(Invoice__c c, Invoice__c i){
            creditNote = c;
            invoice = i;
         }
    }

    /*********************************/
    //AMI 26/06/18 : Community Rollout 
    //             : adding formula field in query to be able to get tech_licence name
   //define Query to return a list of offer( select information of SO, PO, Inv, InvChild where Ol toBeProcessed)
   // public String query = 'select id,TotalASPrice__c,BSCreditNotePrice__c,AdditionnalDiscount__c,PartNumber__c,Price__c,Quantity__c,Orderline__c,orderline__r.PurchaseOrder__c, Orderline__r.PurchaseOrder__r.Status__c, orderline__r.PurchaseOrder__r.HasCaseForAdditionalDiscount__c, orderline__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c, orderline__r.PurchaseOrder__r.Assessment__c ,orderline__r.TECH_ToBeProcessed__c,orderline__r.AdditionnalDiscount__c, orderline__r.PreviousAdditionnalDiscount__c,Prerequisiteorder__c,Prerequisiteorder__r.TECH_BodyshopCountryCode__c,Prerequisiteorder__r.Assessment__c,Prerequisiteorder__r.BodyShop__c,Prerequisiteorder__r.PaymentTerms__c, Prerequisiteorder__r.Status__c, Total__c,Discount__c, TotalPriceNet__c, DeliveryStatus__c from Offer__c where orderline__r.TECH_ToBeProcessed__c = true and Accepted__c = \'YES\' Order By Prerequisiteorder__c';
   //DUN 04/05/2017  C-001904: added condition if assessment not in agency mode
    //DUN 08/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
	public String query = 'SELECT Id, TotalASPrice__c, BSCreditNotePrice__c, AdditionalDiscountAmount__c, PartNumber__c, Price__c, Quantity__c, BSTotalPrice__c, '
								+ 'Orderline__c, Orderline__r.PurchaseOrder__c, Orderline__r.PurchaseOrder__r.Status__c, Orderline__r.PurchaseOrder__r.HasCaseForAdditionalDiscount__c, '
								+ 'Orderline__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c, Orderline__r.PurchaseOrder__r.Assessment__c, Orderline__r.TECH_ToBeProcessed__c, '
								+ 'Orderline__r.AdditionalDiscountAmount__c, Orderline__r.PreviousAdditionalDiscountAmount__c, Prerequisiteorder__c, Prerequisiteorder__r.TECH_BodyshopCountryCode__c, '
								+ 'Prerequisiteorder__r.Assessment__c, Prerequisiteorder__r.BodyShop__c, Prerequisiteorder__r.PaymentTerms__c, Prerequisiteorder__r.Status__c, '
								+ 'Total__c, Discount__c, TotalPriceNet__c, DeliveryStatus__c, AgencyMode__c, Prerequisiteorder__r.BodyShop__r.contactUser__c , Prerequisiteorder__r.BodyShop__r.Tech_ContactUserLicenceName__c '
						+ 'FROM Offer__c '
						+ 'WHERE Orderline__r.TECH_ToBeProcessed__c = true '
						+ 'AND Accepted__c = \'YES\' '
                        + 'AND AgencyMode__c = false '
                        + 'AND Prerequisiteorder__r.TechIsInvoiced__c = true'; 
						//+ 'Order By Prerequisiteorder__c';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('####ASPISBatchCreateInvoiceAddDis#### Batch Started = ' + DateTime.now());
        // Query all invoices with TECHToBeProcessedCegedim__c checked
        System.debug('####ASPISBatchCreateInvoiceAddDis end:'+query);
        return Database.getQueryLocator(query);
    }

    //Processing
    global void execute(Database.BatchableContext BC, List <Offer__c> scope) {
        System.debug('############ START execute METHOD');
        // variables

        // map that contains payment terms details and shipping countryCode
        map<String, String> ShippingCodePaymentMap = new map<String, String>();

        // map<S0Id, wrapper containing invoices and credit note>
        map<Id,allInvoiceDetail> SOInvoicesMap = new map<Id,allInvoiceDetail>();

        //list containing all invoices in allInvoiceDetail from SOInvoicesMap
        list<Invoice__c> invoicesToBeInserted = new list<Invoice__c>();

        //list containing all invoices children in allInvoiceDetail from SOInvoicesMap
        list<Invoice__c> childInvoicesToBeInserted = new list<Invoice__c>();

        //set containing orderlines whose TECH_ToBeProcessed__c need to be cleared
        set<Id> OLSet = new set<Id>();

        //list containing orderlines whose TECH_ToBeProcessed__c need to be cleared
        List<Orderline__c> OLlist = new List<Orderline__c>();

        // map<SOId, map<PO, list<offers>>>. To be populated if invoice hierarchy is required??
        // map<Id,map<Id, list<Offer__c>>> SOPOOffersMap = new map<Id,map<Id, list<Offer__c>>>();

        // map<Id,map<Id, allInvoiceDetail>> SOPOInvoiceMap = new map<Id,map<Id, allInvoiceDetail>>();
        map<Id, allInvoiceDetail> POInvoicesMap = new map<Id, allInvoiceDetail>();

		// ABT 31-MAR-2016 C-001581
		List<PurchaseOrder__c> purchaseOrderListToBeFlagged = new List<PurchaseOrder__c>();
		List<Case__c> caseListToBeInserted					= new List<Case__c>();

        // retrieve NeedInvoiceDetail field from CountryCodeInformationsMapping Custom Setting
        map<String, CountryCodeInformationsMapping__c> countryCodeMap = CountryCodeInformationsMapping__c.getall();

        //retrieve acc payment
        string rtacc_PaymenttId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();

        list<Offer__c> updatedOfferList= new list<Offer__c>();
        //map<Id, Offer__c> updatedOfferMap = new map<Id, Offer__c>();
        String creditNoteId = null;
        String invoiceId = null;

        // build a map of shipping code and payment ID
        for(Account acc : [Select Id,Name, ShippingCountryCode from Account WHERE RecordTypeID=:rtacc_PaymenttId]){
            if(!ShippingCodePaymentMap.containsKey(acc.ShippingCountryCode)){
                ShippingCodePaymentMap.put(acc.ShippingCountryCode, acc.Id);
            }

        }

        // ABT 30-JUN-2017 C-001938
        Map<Id, PrerequisiteOrder__c> mapOldSalesOrder = new Map<Id, PrerequisiteOrder__c>();

        // loop in offers and group all offers having additional discount for the day by SO
        // create new invoice if addtitonal discount is negative per SO
        // create new credit note if addtitonal discount is positive per SO

        for(Offer__c offer : scope){
            Invoice__c creditNote;
            Invoice__c invoice;
            Invoice__c creditNoteChild;
            Invoice__c invoiceChild;
            Id paymentToId;
            String externalNumber;
            //DUN 15/02/2016
            creditNoteId = null;
            invoiceId = null;
            system.debug('##### offer TECH:'+offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c);

            /*if(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c!=null){
                paymentToId = ShippingCodePaymentMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c)!=null?ShippingCodePaymentMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c):null;
            }
            else{
                paymentToId = null;
            }*/

            paymentToId = offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c!=null?(ShippingCodePaymentMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c)!=null?ShippingCodePaymentMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c):null):null;

            if(!SOInvoicesMap.containsKey(offer.Prerequisiteorder__c)){
                externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());

				// ABT 13-APR-2016 - C-001592
				// PREORDERCONFIRMED -> Delivery Confirmed
                // ASE: 15/04/16; case 1592
				// ABT 18-APR-2016 - C-001592 - Corrected the if condition
                if(offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED || offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED){
				        creditNote = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumber,paymentToId, true);
                }
                else{
                    if(	(	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
							(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0
						) ||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c > 0))
					{
                        // call method createInvoice to create creditNote
                        creditNote = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumber,paymentToId, false);
                    }
                    else if((	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
								(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0
							) ||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c < 0))
					{
                        // call method createInvoice to create Invoice
                        invoice = createInvoice(offer,  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(), 'INVOICE',externalNumber,paymentToId, false);
                    }
                }
                allInvoiceDetail allInv = new allInvoiceDetail(creditNote!=null? creditNote: null , invoice!=null? invoice: null);
                SOInvoicesMap.put(offer.Prerequisiteorder__c,allInv);

                // ABT - 30-JUN-2017 - C-001938
                // Capturing the so of the offer for later use
                mapOldSalesOrder.put(offer.Prerequisiteorder__c, offer.Prerequisiteorder__r);
            }
            else{
				// ABT 13-APR-2016 - C-001592
				// ABT 18-APR-2016 - C-001592 - Corrected the if condition
                if(offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED || offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED){
                    // ASE 15/04/16: case 1592; add for cancel
                    // if credit note already exists for this SO, update TotalNet__c, ItemsNumber__c, TotalPieces__c, TechOfferIds__c
                    if(SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote!=null){
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalGrossAmount__c += offer.Total__c;
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotaldiscountAmount__c += (offer.Total__c*offer.Discount__c)/100;
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalNet__c += offer.BSTotalPrice__c;
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.ItemsNumber__c += 1 ;
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalPieces__c += offer.Quantity__c.intValue();
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TechOfferIds__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TechOfferIds__c +'-'+offer.Id;
                    }
                    else{
                        externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());
                        // call method createInvoice to create creditNote
                        creditNote = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumber,paymentToId, true);
                        SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote = creditNote;
                    }
                }
                else{
                    if(		(	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
								(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0
							)
					   ||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c > 0)
					   ){
                        // if credit note already exists for this SO, update TotalNet__c, ItemsNumber__c, TotalPieces__c, TechOfferIds__c
                        if(SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote!=null){
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalGrossAmount__c += offer.Total__c;
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotaldiscountAmount__c += (offer.Total__c*offer.Discount__c)/100;
                            // ASE 15/04/16: case 1592
                            //SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalNet__c += offer.BSCreditNotePrice__c;
                            // SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalNet__c += MATH.ABS(offer.TotalPriceNet__c - (((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - (offer.orderline__r.PreviousAdditionalDiscountAmount__c!=null?offer.orderline__r.PreviousAdditionalDiscountAmount__c:0))/*/100*/);
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalNet__c += MATH.ABS(   ((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - 
                                                                                                                ((offer.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? offer.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.ItemsNumber__c += 1 ;
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalPieces__c += offer.Quantity__c.intValue();
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TechOfferIds__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TechOfferIds__c +'-'+offer.Id;
                        }
                        else{
                            externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());
                            // call method createInvoice to create creditNote
                            creditNote = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumber,paymentToId, false);
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote = creditNote;
                        }
                    }
    				// ABT 13-APR-2016 - Commented to correct the else part
                    // else{
                    else if(	(	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
									(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0
								)
							||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c < 0)){
                        // if invoice already exists for this SO, update TotalNet__c, ItemsNumber__c, TotalPieces__c, TechOfferIds__c
                        if(SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice!=null){
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotalGrossAmount__c += offer.Total__c;
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotaldiscountAmount__c += (offer.Total__c*offer.Discount__c)/100;
                            // ASE 15/04/16: case 1592
                            //SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotalNet__c += (offer.BSCreditNotePrice__c*(-1));
							// ABT 18-APR-2016 - Corrected
                            //SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TotalNet__c += MATH.ABS(offer.TotalPriceNet__c * (offer.AdditionnalDiscount__c - offer.orderline__r.PreviousAdditionnalDiscount__c)/100);
                            // SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotalNet__c += MATH.ABS(offer.TotalPriceNet__c - (((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - (offer.orderline__r.PreviousAdditionalDiscountAmount__c!=null?offer.orderline__r.PreviousAdditionalDiscountAmount__c:0))/*/100*/);
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotalNet__c += MATH.ABS(  ((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - 
                                                                                                            ((offer.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? offer.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.ItemsNumber__c += 1 ;
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TotalPieces__c += offer.Quantity__c.intValue();
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TechOfferIds__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TechOfferIds__c+'-'+offer.Id;
                        }
                        else{
                            externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());
                            // call method createInvoice to create Invoice
                            invoice = createInvoice(offer,  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(), 'INVOICE',externalNumber,paymentToId, false);
                            SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice = invoice;
                        }
                    }
                }
            }

            // add orderlineId in OLSet
            OLSet.add(offer.orderline__c);

            // check if invoice hierarchy is required
            if(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c !=null){
                system.debug('##### needinvoice: '+offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c);
                system.debug('##### needinvoice: '+countryCodeMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c);
                if(countryCodeMap.get(offer.Prerequisiteorder__r.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c){
                    //String externalNumberChild = String.ValueOf(System.now())+String.ValueOf(math.random());
                    String externalNumberChild = null;

                    //populate POInvoicesMap with POId --> Offers
                    if(!POInvoicesMap.containsKey(offer.orderline__r.PurchaseOrder__c))
					{
						// ABT 19-APR-2016
						if(	offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
							offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
						{
							creditNoteChild = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumberChild,paymentToId, true);
							creditNoteChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
                            creditNoteChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c);
						}
						else
						{
							// ABT 18-APR-2016 - C-001592
							if((	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
									(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0
								)
								||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c > 0))
							{
								// call method createInvoice to create creditNote
								creditNoteChild = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumberChild,paymentToId, false);
								creditNoteChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
								creditNoteChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c);
							}
							else if((	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
										(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0
									)
									||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c < 0))
							{
								// call method createInvoice to create Invoice
								invoiceChild = createInvoice(offer,  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(), 'INVOICE',externalNumberChild,paymentToId,false);
								invoiceChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
								invoiceChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TECH_InvoiceParent__c);
							}
						}

                        allInvoiceDetail allInv2 = new allInvoiceDetail(creditNoteChild!=null? creditNoteChild: null , invoiceChild!=null? invoiceChild: null);
                        POInvoicesMap.put(offer.orderline__r.PurchaseOrder__c,allInv2);

						// ABT 31-MAR-2016 C-001581
						// Create case for the purchase order if the status of the purchase order is Delivered confirmed or Payable
						// And Purchase Order does not already have a case
						// Flag the purchase order
						// Case is created only once as this part is run only once (So no duplicate ids)

						if(	(offer.orderline__r.PurchaseOrder__r.Status__c == ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED ||
							 offer.orderline__r.PurchaseOrder__r.Status__c == ASPISConstants.PUR_ORDER_STATUS_PAYABLE)
							&&
							!offer.orderline__r.PurchaseOrder__r.HasCaseForAdditionalDiscount__c
						  )
						{
							Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', offer.orderline__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c, null, offer.orderline__r.PurchaseOrder__r.Assessment__c, offer.orderline__r.PurchaseOrder__c, null, '', UserInfo.getUserId(), '-AdditionalDiscount');
							caseListToBeInserted.add(newCase);
							purchaseOrderListToBeFlagged.add( new PurchaseOrder__c(	Id = offer.orderline__r.PurchaseOrder__c,
																					HasCaseForAdditionalDiscount__c = true));
						}
                    }
                    else
					{
						// ABT 19-APR-2016
						if(	offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
							offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
						{
							if(POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote != null)
							{
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalGrossAmount__c		+= offer.Total__c;
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotaldiscountAmount__c	+= (offer.Total__c*offer.Discount__c)/100;
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalNet__c				+= offer.BSTotalPrice__c;
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.ItemsNumber__c			+= 1 ;
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalPieces__c			+= offer.Quantity__c.intValue();
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TechOfferIds__c			= POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TechOfferIds__c +'-'+offer.Id;
							}
							else
							{
								// call method createInvoice to create creditNote
								creditNoteChild = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumberChild,paymentToId, false);
								creditNoteChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
								creditNoteChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c);
								POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote = creditNoteChild;
							}
						}
						else
						{

							if((	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
									(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0
								)
								||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c > 0))
							{
								// if credit note already exists for this PO, update TotalNet__c, ItemsNumber__c, TotalPieces__c, TechOfferIds__c
								if(POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote!=null)
								{
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalGrossAmount__c += offer.Total__c;
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotaldiscountAmount__c += (offer.Total__c*offer.Discount__c)/100;
									// POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalNet__c += MATH.ABS(offer.TotalPriceNet__c - (((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - (offer.orderline__r.PreviousAdditionalDiscountAmount__c!=null?offer.orderline__r.PreviousAdditionalDiscountAmount__c:0))/*/100*/);
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalNet__c += MATH.ABS(  ((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - 
                                                                                                                                ((offer.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? offer.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.ItemsNumber__c += 1;
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TotalPieces__c += offer.Quantity__c.intValue();
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TechOfferIds__c = POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote.TechOfferIds__c +'-'+offer.Id;
								}
								else
								{
									// call method createInvoice to create creditNote
									creditNoteChild = createInvoice(offer, Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(), 'CREDITNOTE',externalNumberChild,paymentToId, false);
									creditNoteChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
									creditNoteChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c);
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).creditNote = creditNoteChild;
								}
							}
							// ABT 18-APR-2016 - commented the else
							//else{
							else if (	(	offer.Orderline__r.PreviousAdditionalDiscountAmount__c != null &&
											(((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - offer.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0
										)
										||	(offer.Orderline__r.PreviousAdditionalDiscountAmount__c == null &&
							 offer.AdditionalDiscountAmount__c < 0))
							{
								// if invoice already exists for this SO, update TotalNet__c, ItemsNumber__c, TotalPieces__c, TechOfferIds__c
								if(POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice!=null)
								{
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TotalGrossAmount__c += offer.Total__c;
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TotaldiscountAmount__c += (offer.Total__c*offer.Discount__c)/100;
									// POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TotalNet__c += MATH.ABS(offer.TotalPriceNet__c - (((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - (offer.orderline__r.PreviousAdditionalDiscountAmount__c!=null?offer.orderline__r.PreviousAdditionalDiscountAmount__c:0))/*/100*/);
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TotalNet__c += MATH.ABS( ((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - 
                                                                                                                            ((offer.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? offer.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.ItemsNumber__c += 1 ;
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TotalPieces__c += offer.Quantity__c.intValue();
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TechOfferIds__c = POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice.TechOfferIds__c+'-'+offer.Id;
								}
								else
								{
									// call method createInvoice to create Invoice
									invoiceChild = createInvoice(offer,  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(), 'INVOICE',externalNumberChild,paymentToId,false);
									invoiceChild.PurchaseOrder__c = offer.orderline__r.PurchaseOrder__c;
									invoiceChild.ParentInvoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TECH_InvoiceParent__c);
									POInvoicesMap.get(offer.orderline__r.PurchaseOrder__c).invoice = invoiceChild;
								}
							}
						}
                    }
                }
            }

            // assign credit note and invoice number tyo offer
            //updatedOfferList.add(new Offer__c(id = offer.id,CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c) , Invoice__r = new Invoice__c(TECH_InvoiceParent__c = SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TECH_InvoiceParent__c)));

            //DUN 15/02/2016 added offer.AdditionnalDiscount__c >/< 0
            if(SOInvoicesMap.get(offer.Prerequisiteorder__c)!=null){
                if(SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote!=null && (offer.AdditionalDiscountAmount__c > 0 || (offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED || offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED))){
                    if(SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c!=null){
                        creditNoteId = SOInvoicesMap.get(offer.Prerequisiteorder__c).creditNote.TECH_InvoiceParent__c;
                    }
                }
                if(SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice!=null && offer.AdditionalDiscountAmount__c < 0){
                    if(SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TECH_InvoiceParent__c!=null){
                        invoiceId = SOInvoicesMap.get(offer.Prerequisiteorder__c).invoice.TECH_InvoiceParent__c;
                    }
                }
            }
            //system.debug('######### creditNoteId:+' +creditNoteId);
            //system.debug('######### invoiceId:+' +invoiceId);

            // assign credit note/ invoice to offer
            /*if(!updatedOfferMap.containsKey(offer.id)){
                Offer__c off =  new Offer__c();
                off.id = offer.id;
                if(creditNoteId!=null){
                    off.CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = creditNoteId);
                }
                if(invoiceId!=null){
                    off.Invoice__r = new Invoice__c(TECH_InvoiceParent__c = invoiceId);
                }
                updatedOfferMap.put(offer.id,off);
            }
            else{
                if(updatedOfferMap.get(offer.id).CreditNote__c==null){
                    if(creditNoteId!=null){
                        updatedOfferMap.get(offer.id).CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = creditNoteId);
                    }
                }
                if(updatedOfferMap.get(offer.id).Invoice__c==null){
                    if(invoiceId!=null){
                        updatedOfferMap.get(offer.id).Invoice__r = new Invoice__c(TECH_InvoiceParent__c = invoiceId);
                    }
                }
            }*/
        	Offer__c off =  new Offer__c();
            off.id = offer.id;
            if(creditNoteId!=null){
                off.CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = creditNoteId);
            }
            if(invoiceId!=null){
                off.Invoice__r = new Invoice__c(TECH_InvoiceParent__c = invoiceId);
            }
        	updatedOfferList.add(off);
            //system.debug('######### creditNoteId:' +updatedOfferMap.get(offer.id).CreditNote__r);
            //system.debug('######### invoiceId:'+updatedOfferMap.get(offer.id).Invoice__r);
        }// end for
        system.debug('########## SOInvoicesMap:'+SOInvoicesMap);
        system.debug('########## POInvoicesMap:'+POInvoicesMap);
        system.debug('########## OLSet:'+OLSet);

        // looping in SOInvoicesMap.allInvoiceDetail values to build list of invoices to be inserted
        for(allInvoiceDetail invDet: SOInvoicesMap.values()){
            if(invDet.creditNote!=null){
                invoicesToBeInserted.add(invDet.creditNote);

            }
            if(invDet.invoice!=null){
                invoicesToBeInserted.add(invDet.invoice);
            }
        }
        //system.debug('######### invoicesToBeInserted:'+invoicesToBeInserted);

        // looping in SOInvoicesMap.allInvoiceDetail values to build list of invoices to be inserted
        for(allInvoiceDetail invDet: POInvoicesMap.values()){
            if(invDet.creditNote!=null){
                childInvoicesToBeInserted.add(invDet.creditNote);
            }
            if(invDet.invoice!=null){
                childInvoicesToBeInserted.add(invDet.invoice);
            }
        }
        system.debug('######### childInvoicesToBeInserted:'+childInvoicesToBeInserted);

        // loop in OLset to set TECH_ToBeProcessed__c to false
        for(Id OLId: OLSet){
            Orderline__c updatedOL = new Orderline__c(id= OLId, TECH_ToBeProcessed__c = false);
            OLLIst.add(updatedOL);
        }
        system.debug('######### OLLIst:'+OLLIst);


        //insert invoices
        if(invoicesToBeInserted.size()> 0){
            insert invoicesToBeInserted;

           	/*if(updatedOfferMap.size()> 0){
               update updatedOfferMap.values();
            }*/

            if(updatedOfferList.size()>0){
            	update updatedOfferList;
            }

            if(childInvoicesToBeInserted.size()> 0){
                insert childInvoicesToBeInserted;
            }

            //update all OL field TECH_ToBeProcessed__c to false
            if(OLLIst.size()>0){
                update OLLIst;
            }

			// ABT 01-APR-2016 C-001581
			if (caseListToBeInserted.size() > 0)
			{
				insert caseListToBeInserted;
			}

			// C-001581
			if (purchaseOrderListToBeFlagged.size() > 0)
			{
				update purchaseOrderListToBeFlagged;
			}
        }

        // update SO Total Expected amount
        // if(SOInvoicesMap.KeySet().size() > 0){
        //     AP16CalcTotalExpAmtSalesOrder.updateSalesOrder(SOInvoicesMap.KeySet());
        // }

        // ABT - 30-JUN-2017 - C-001938
        // Calculate the total expected amount and check whether the SO should be updated to Invoiced or CanceledInvoiced
        if(SOInvoicesMap.size() > 0)
        {
            List<PrerequisiteOrder__c> salesOrderToUpdateList = AP16CalcTotalExpAmtSalesOrder.updateSalesOrder(SOInvoicesMap.keySet());

            for(PrerequisiteOrder__c currentSalesOrder : salesOrderToUpdateList)
            {
                if(mapOldSalesOrder.containsKey(currentSalesOrder.Id))
                {
                    PrerequisiteOrder__c oldSalesOrder = mapOldSalesOrder.get(currentSalesOrder.Id);

                    if(oldSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
                    {
                        // Reopen the sales order to canceled invoice
                        currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
                    }
                    else
                    {
                        // for other status set them to INVOICED even it was in closedOK
                        currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
                    }
                }
            }

            update salesOrderToUpdateList;
        }
        

        System.debug('############ END execute METHOD');
    }

    global void finish(Database.BatchableContext BC) {

    }

    public Invoice__c createInvoice(Offer__c offer, Id invRecordTypeId, string type, String externalId, Id paymentToId, Boolean isCancelled){
        Invoice__c newInvoice = new Invoice__c();
        newInvoice.Assessment__c = offer.Prerequisiteorder__r.Assessment__c;
        newInvoice.BodyShop__c = offer.Prerequisiteorder__r.BodyShop__c;
        newInvoice.Status__c = 'SENT';
        newInvoice.Prerequisiteorder__c = offer.Prerequisiteorder__c;
        newInvoice.RecordTypeID = invRecordTypeId;
        newInvoice.Type__c = type;
        newInvoice.IsBodyShop__c = true;
        newInvoice.TECH_IsAdditionalDiscount__c = true;
        newInvoice.Paymentterms__c = offer.Prerequisiteorder__r.PaymentTerms__c;
        newInvoice.ItemsNumber__c = 1;
        newInvoice.TotalPieces__c = offer.Quantity__c.intValue();
        newInvoice.TechOfferIds__c = offer.Id;
        newInvoice.TECH_InvoiceParent__c = externalId;
        newInvoice.PaymentTo__c = paymentToId;

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating Owner to aspis system if and only if bodyshop user has comm licence
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
        string contactuserlicence = string.isNotBlank(offer.Prerequisiteorder__r.BodyShop__r.Tech_ContactUserLicenceName__c) ?
                                    offer.Prerequisiteorder__r.BodyShop__r.Tech_ContactUserLicenceName__c : 'fakelicence';

        if (offer.Prerequisiteorder__r.BodyShop__r.contactUser__c != null){
            if(string.isBlank(formattedLicenseName) ||
               (string.isNotBlank(formattedLicenseName) && 
               !formattedLicenseName.contains(contactuserlicence))){
                newInvoice.ownerid = offer.Prerequisiteorder__r.BodyShop__r.contactUser__c;
            }else if(formattedLicenseName.contains(contactuserlicence) &&
                     aspisSystemUserId != null){
                newInvoice.ownerid = aspisSystemUserId;
            }
        }
        // ABT 02-DEC-2016 - C-001625 - Commented
        // newInvoice.TECHToBeProcessedCegedim__c  = true;
        
        // ASE: 15/04/16 : case 1592
        //newInvoice.TotalNet__c = (offer.BSCreditNotePrice__c*(i));
        system.debug('#### offer.BSTotalPrice__c:'+offer.BSTotalPrice__c);
        system.debug('#### offer.TotalPriceNet__c:'+offer.TotalPriceNet__c);
        system.debug('#### offer.AdditionalDiscountAmount__c:'+offer.AdditionalDiscountAmount__c);
        system.debug('#### offer.PreviousAdditionalDiscountAmount__c:'+offer.orderline__r.PreviousAdditionalDiscountAmount__c);

        if(isCancelled){
            newInvoice.TotalNet__c = offer.BSTotalPrice__c;
        }
        else{
        //    newInvoice.TotalNet__c = MATH.ABS(offer.TotalPriceNet__c - (((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - (offer.orderline__r.PreviousAdditionalDiscountAmount__c!=null?offer.orderline__r.PreviousAdditionalDiscountAmount__c:0))/*/100*/);
           newInvoice.TotalNet__c = MATH.ABS( ((offer.AdditionalDiscountAmount__c != null) ? offer.AdditionalDiscountAmount__c : 0) - 
                                              ((offer.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? offer.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
        }

        newInvoice.TotalGrossAmount__c = offer.Total__c;
        newInvoice.TotaldiscountAmount__c = (offer.Total__c*offer.Discount__c)/100;

        return newInvoice;
    }
}