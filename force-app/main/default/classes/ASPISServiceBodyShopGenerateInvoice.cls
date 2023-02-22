/*************************************************************************************
Class Name - ASPISServiceBodyShopGenerateInvoice
Version - 1.0
/*************************************************************************************
Class Name - ASPISServiceBodyShopGenerateInvoice
Version - 1.0
Created Date - 09 APR 2015
Function - Class to Trigger actions when all children orderlines are delivered

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* João Dias             10/04/2015  Original Version
* João Dias             30/04/2015  Update Distributor Delivery Status
* João Dias             30/04/2015  Move detail lines from Orderline__c to Offer__c (visibility issues)
* João Dias             19/06/2015  Bug: Delivered on All PO (even not selected)
* Dourga Unmole         26/06/2015  Corrected code to create invoice only when all offerlines are delivered 
* Dourga Unmole         20/07/2015  Modified code (remove use of close sales order button)
* Dourga Unmole         24/07/2015  Comment code for the creation of credit note - case C-001234
* Dourga Unmole  		01/12/2015  Added code for case C-001434
* Dourga Unmole         26/01/2016  Added code for case C-001503
* Dourga Unmole         28/01/2016  Added code for case C-001390
* Shamina M     		16/02/2016  C-001518: Removed unnecessary debug logs
* Dourga Unmole 		01/06/2016  C-001647: Automatic validation failed in Production (bulkify class)
* Dourga Unmole         04/05/2017  C-001904: No invoice/credit note needs to be generated for assessment in agency mode
* Dourga Unmole         08/01/2018  C-002135: Agency Mode V2 
*************************************************************************************/
public without sharing class ASPISServiceBodyShopGenerateInvoice/* implements ASPISService*/{
	
	//method to excute the process for the generation of invoice and credit note
	//DUN 01/06/2016 C-001647 Taking as parameter a map of Sales Orders instead of one
    //public void executeProcess(sObject obj){

	public static Boolean isGenerateAgainProcess = false;

    public void executeProcess(map<Id,PrerequisiteOrder__c> mapIdSalesOrder){
    	system.debug('##Start ASPISServiceBodyShopGenerateInvoice executeProcess');
//		
//		//Varaible Declaration
//        integer acceptedCount = 0;
//        integer deliveredCount = 0;
//        list<Invoice__c> l_invoicesToBeInserted =new list<Invoice__c>();
//        list<Invoice__c> l_invoicesChildToBeInserted =new list<Invoice__c>();
//        list<Invoice__c> l_invoicesToBeUpdated =new list<Invoice__c>();
//        map<Id,Offer__c> m_OfferToBeUpdated= new map<Id,Offer__c>();
//        list<Offer__c> l_OfferList= new list<Offer__c>();
//        map<Id,Invoice__c> rtIdInvoiceMap = new map <Id,Invoice__c>();
//        //DUN C-001503
//        map<Id,map<Id,List<Offer__c>>> mapInvIdPOIdOffersList = new map<Id,map<Id,List<Offer__c>>>();
//        map<Id,List<Offer__c>> mapInvIdOffersList = new map <Id,List<Offer__c>>();
//        PrerequisiteOrder__c preOrd = (PrerequisiteOrder__c) obj; 
//        Invoice__c newInvoice = new Invoice__c();
//        Decimal AStotalNet = 0;
//        Decimal totalNet = 0;
//        Integer numberOfParts = 0;
//        Integer numberOfPieces = 0;
//		String OffDelIds = null;
//		String OffCanIds = null;
//		String OffRetIds = null;
//		String OffAddDisIdsPos = null;
//		String OffAddDisIdsNeg = null;
//
//        Boolean checkCanceledStatus = false;
//        Boolean checkDeliveredStatus = false;
//		Boolean checkReturnedStatus = false;
//		Boolean hasAdditionalDisPos = false;
//		Boolean hasAdditionalDisNeg = false;
//        
//        Boolean checkInvDraftCreated = false;
//        Boolean checkInvCreditNoteCreated = false;
//
//        Decimal canceledtotalNet = 0;
//        Integer cancelednumberOfParts = 0;
//        Integer cancelednumberOfPieces = 0;
//
//		Decimal returnedtotalNet = 0;
//        Integer returnednumberOfParts = 0;
//        Integer returnednumberOfPieces = 0;
//
//		Decimal addDistotalNetPos = 0;
//        Integer addDisnumberOfPartsPos = 0;
//        Integer addDisnumberOfPiecesPos = 0;
//        Decimal addDistotalNetNeg = 0;
//        Integer addDisnumberOfPartsNeg = 0;
//        Integer addDisnumberOfPiecesNeg = 0;
//		Decimal TotalGrossAmount = 0;
//		Decimal TotalNetChild = 0;
//		Decimal TotaldiscountAmount = 0;
//
//        //system.debug('###ASPISServiceBodyShopGenerateInvoice###');
//        //system.debug('###ASPISServiceBodyShopGenerateInvoice###'+preOrd);
//
//        string rtDraftId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
//        //system.debug('###rtDraftId###'+rtDraftId);
//
//		//Selecting invoices if already exist
//        Invoice__c[] invoices =[Select Id,RecordTypeID,PrerequisiteOrder__c From Invoice__c where PrerequisiteOrder__c =:preOrd.Id];
//
//		//Selecting a list of offers 
//        List<Offer__c> listOffers = [select id,PriceWithoutAddDiscount__c,TotalASPrice__c,BSCreditNotePrice__c, BSTotalPrice__c,
//									AdditionnalDiscount__c,PartNumber__c,DeliveryStatus__c,OrderType__c,quantity__c,
//									Accepted__c,Price__c, orderline__c, orderline__r.purchaseOrder__c,Total__c,Discount__c,
//									(Select Id from Offers__r) 
//									from Offer__c where 
//									(DeliveryStatus__c   = 'DELIVERED'  
//									or DeliveryStatus__c   = 'CANCELED'
//									or DeliveryStatus__c = 'RETURNED') and
//									Accepted__c = 'YES' and
//									PrerequisiteOrder__c = :preOrd.id
//        ];
//
//		//retrieve acc payment
//		string rtacc_PaymenttId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
//
//		string paymentToId = null;
//		Account[] acc_Payments = [Select Id,Name from Account WHERE RecordTypeID=:rtacc_PaymenttId and ShippingCountryCode=:preOrd.TECH_BodyshopCountryCode__c];
//		if (acc_Payments.size() > 0){
//			paymentToId= acc_Payments[0].Id;
//		}
//
//		if (listOffers.size() > 0)
//		{
//			for(Offer__c off: listOffers){
//            
//				if(off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED || off.DeliveryStatus__c=='RETURNED' || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED){
//					
//					//system.debug('//// checkReturnedDeliver or RETURNED');
//					checkDeliveredStatus = true;
//					l_OfferList.add(off);
//					 //calculate discount price for invoice
//					totalNet +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
//					++numberOfParts;
//					numberOfPieces += off.Quantity__c.intValue();
//					OffDelIds = OffDelIds +'-'+off.Id;
//				}
//				if(off.DeliveryStatus__c=='RETURNED' || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED){
//					//system.debug('//// RETURNED');
//					checkReturnedStatus = true;
//
//					returnedtotalNet +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
//					++returnednumberOfParts;
//					returnednumberOfPieces += off.Quantity__c.intValue();
//					OffRetIds = OffRetIds +'-'+off.Id;
//				}
//				if (off.AdditionnalDiscount__c != null && off.AdditionnalDiscount__c != 0 && off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED)
//				{
//					//Case 1390
//					if(off.AdditionnalDiscount__c > 0){
//						//system.debug('//// off.AdditionnalDiscount__c != null && off.AdditionnalDiscount__c != 0');
//						hasAdditionalDisPos = true;
//						
//						addDistotalNetPos += off.BSCreditNotePrice__c;
//						//system.debug('//// addDistotalNet: ' + addDistotalNet);
//						
//						++addDisnumberOfPartsPos;
//						//system.debug('//// addDisnumberOfParts: ' + addDisnumberOfParts);
//						addDisnumberOfPiecesPos += off.Quantity__c.intValue();
//						//system.debug('//// addDisnumberOfPieces: ' + addDisnumberOfPieces);
//						OffAddDisIdsPos = OffAddDisIdsPos +'-'+off.Id;
//						//system.debug('//// OffAddDisIds: ' + OffAddDisIds);
//					}
//					else if(off.AdditionnalDiscount__c < 0){
//						
//						hasAdditionalDisNeg = true;
//
//						addDistotalNetNeg += (off.BSCreditNotePrice__c*(-1));
//						//system.debug('//// addDistotalNet: ' + addDistotalNet);
//						
//						++addDisnumberOfPartsNeg;
//						//system.debug('//// addDisnumberOfParts: ' + addDisnumberOfParts);
//						addDisnumberOfPiecesNeg += off.Quantity__c.intValue();
//						//system.debug('//// addDisnumberOfPieces: ' + addDisnumberOfPieces);
//						OffAddDisIdsNeg = OffAddDisIdsNeg +'-'+off.Id;
//						//system.debug('//// OffAddDisIds: ' + OffAddDisIds);
//					}
//				}
//
//			}
//			
//			// invoice for Delivered, Cancelled and Returned
//			if (checkDeliveredStatus)
//			{
//				//system.debug('//// checkDeliveredStatus');
//				Invoice__c newDraftInvoice = new Invoice__c(
//                    Assessment__c = preOrd.Assessment__c,
//                    BodyShop__c = preOrd.BodyShop__c,
//                    Status__c = 'SENT',
//                    Prerequisiteorder__c = preOrd.id,
//                    PaymentTo__c = paymentToId, 
//                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
//                    Type__c = 'INVOICE',
//                    IsBodyShop__c = true,
//                    Paymentterms__c = preOrd.PaymentTerms__c,
//                    TotalNet__c = totalNet,
//                    ItemsNumber__c = numberOfParts,
//                    TotalPieces__c = numberOfPieces,
//					TechOfferIds__c = OffDelIds
//                );
//                l_invoicesToBeInserted.add(newDraftInvoice);
//			}
//
//			//Credit note for Cancelled and Returned
//			if (checkReturnedStatus)
//			{
//				//system.debug('//// checkReturnedStatus');
//				Invoice__c newCreditNoteInvoice = new Invoice__c(
//					Assessment__c = preOrd.Assessment__c,
//					BodyShop__c = preOrd.BodyShop__c,
//					Status__c = 'SENT',
//					Prerequisiteorder__c = preOrd.id,
//					PaymentTo__c = paymentToId, 
//					RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
//					Type__c = 'CREDITNOTE',
//					IsBodyShop__c = true,
//					Paymentterms__c = preOrd.PaymentTerms__c,
//					TotalNet__c = returnedtotalNet,
//					ItemsNumber__c = returnednumberOfParts,
//					TotalPieces__c = returnednumberOfPieces,
//					TechOfferIds__c = OffRetIds
//				);
//				l_invoicesToBeInserted.add(newCreditNoteInvoice);
//			}
//
//			//Invoice for additional discount
//			if (hasAdditionalDisNeg)
//			{
//				//system.debug('//// checkDeliveredStatus');
//				Invoice__c newDraftInvoice = new Invoice__c(
//                    Assessment__c = preOrd.Assessment__c,
//                    BodyShop__c = preOrd.BodyShop__c,
//                    Status__c = 'SENT',
//                    Prerequisiteorder__c = preOrd.id,
//                    PaymentTo__c = paymentToId, 
//                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
//                    Type__c = 'INVOICE',
//                    IsBodyShop__c = true,
//					TECH_IsAdditionalDiscount__c = true,
//                    Paymentterms__c = preOrd.PaymentTerms__c,
//					TotalNet__c = addDistotalNetNeg,
//					ItemsNumber__c = addDisnumberOfPartsNeg,
//					TotalPieces__c = addDisnumberOfPiecesNeg,
//					TechOfferIds__c = OffAddDisIdsNeg
//                );
//                l_invoicesToBeInserted.add(newDraftInvoice);
//			}
//
//			// Credit note for additional discount
//			if (hasAdditionalDisPos){
//				//system.debug('//// hasAdditionalDis');
//				Invoice__c newCreditNoteInvoice = new Invoice__c(
//					Assessment__c = preOrd.Assessment__c,
//					BodyShop__c = preOrd.BodyShop__c,
//					Status__c = 'SENT',
//					Prerequisiteorder__c = preOrd.id,
//					PaymentTo__c = paymentToId, 
//					RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
//					Type__c = 'CREDITNOTE',
//					IsBodyShop__c = true,
//					TECH_IsAdditionalDiscount__c = true,
//					Paymentterms__c = preOrd.PaymentTerms__c,
//					TotalNet__c = addDistotalNetPos,
//					ItemsNumber__c = addDisnumberOfPartsPos,
//					TotalPieces__c = addDisnumberOfPiecesPos,
//					TechOfferIds__c = OffAddDisIdsPos
//				);
//				l_invoicesToBeInserted.add(newCreditNoteInvoice);
//			}
//
//			//system.debug('//// l_invoicesToBeInserted: '+ l_invoicesToBeInserted.size());
//			if(l_invoicesToBeInserted.size()>0){
//				//Inserting invoice and credit note
//				ASPISWithoutSharingExceptions.insertInvoices(l_invoicesToBeInserted);
//				
//				//Updating sales order 
//				PrerequisiteOrder__c so = new PrerequisiteOrder__c(Id = preOrd.id);
//				so.TechIsInvoiced__c = true;
//				update so;
//
//				Map<String, List<Invoice__c>> m_Invoice = new Map<String, List<Invoice__c>>();
//				map<Id,Invoice__c> mapInvoice = new map<Id,Invoice__c>([Select Id,TECH_IsAdditionalDiscount__c, TechOfferIds__c,RecordTypeID,TechCountryCode__c from Invoice__c where Id in :l_invoicesToBeInserted]);
//				
//				
//				//*****************************************************************************
//				// ASE: 2016/02/03: cloning invoices
//				// cloning invoices to copy all fields
//
//				String invSOQL =getCreatableFieldsSOQL('Invoice__c', 'id in :l_invoicesToBeInserted');
//				map<Id,Invoice__c> mapClonedInvoice = new map <Id,Invoice__c>((list<Invoice__c>)Database.query(invSOQL));
//				//system.debug(mapClonedInvoice);
//				//******************************************************************************
//
//
//				//system.debug('## mapInvoice ' + mapInvoice);
//				for (Invoice__c inv : mapInvoice.values())
//				{
//					//system.debug('//// inv.TechOfferIds__c: '+ inv.TechOfferIds__c);
//					if (inv.TechOfferIds__c.contains('-'))
//					{
//						for (String idsOff : inv.TechOfferIds__c.split('-'))
//						{
//							if (idsOff != 'null')
//							{
//								if (m_Invoice.containsKey(idsOff))
//								{
//									m_Invoice.get(idsOff).add(inv);
//								}else{
//									List<Invoice__c> invList = new List<Invoice__c>();
//									invList.add(inv);
//									m_Invoice.put(idsOff,invList);
//								}
//								//m_Invoice.put(idsOff, inv);
//							}
//						}
//					}else{
//						if (inv.TechOfferIds__c != null && inv.TechOfferIds__c != 'null')
//						{
//							if (m_Invoice.containsKey(inv.TechOfferIds__c))
//							{
//								m_Invoice.get(inv.TechOfferIds__c).add(inv);
//							}else{
//								List<Invoice__c> invList = new List<Invoice__c>();
//								invList.add(inv);
//								m_Invoice.put(inv.TechOfferIds__c,invList);
//							}
//							//m_Invoice.put(inv.TechOfferIds__c, inv);
//						}
//					}
//				}
//				//system.debug('//// m_Invoice: '+ m_Invoice);
//
//				for(Offer__c off1: listOffers){
//					//system.debug('//// off1.Id: '+ off1.Id);
//					if (m_Invoice.containsKey(off1.Id))
//					{
//						for(Invoice__c inv : m_Invoice.get(off1.Id)){
//							TotalGrossAmount = 0;
//							if (inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())
//							{
//								off1.CreditNote__c = inv.Id;
//								if(!mapInvIdOffersList.containsKey(inv.Id)){
//									mapInvIdOffersList.put(inv.Id,new list <Offer__c>{off1});
//								}
//								else{
//									mapInvIdOffersList.get(inv.Id).add(off1);
//								}
//							}
//
//							if (inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()){
//								off1.Invoice__c = inv.Id;
//								if(!mapInvIdOffersList.containsKey(inv.Id)){
//									mapInvIdOffersList.put(inv.Id,new list <Offer__c>{off1});
//								}
//								else{
//									mapInvIdOffersList.get(inv.Id).add(off1);
//								}
//							}
//						}
//						m_OfferToBeUpdated.put(off1.Id,off1);
//					}
//				}
//				
//				//system.debug('## mapInvIdOffersList ' + mapInvIdOffersList);
//				for(Id invId : mapInvIdOffersList.keySet()){
//					TotalGrossAmount = 0;
//					TotaldiscountAmount = 0;
//					if(mapInvIdOffersList.get(invId).size() > 0){
//						for(Offer__c offer : mapInvIdOffersList.get(invId)){
//							TotalGrossAmount += offer.Total__c;
//							TotaldiscountAmount += (offer.Total__c*offer.Discount__c)/100;
//						}
//					}
//					l_invoicesToBeUpdated.add(new Invoice__c(Id = invId, TotalGrossAmount__c = TotalGrossAmount, TotaldiscountAmount__c = TotaldiscountAmount));
//				}
//
//				//DUN C-001503
//				for(Invoice__c inv :mapInvoice.values()){
//					if(CountryCodeInformationsMapping__c.getall().containsKey(inv.TechCountryCode__c) && CountryCodeInformationsMapping__c.getall().get(inv.TechCountryCode__c).NeedInvoiceDetail__c == true){
//						//system.debug('##Contains');
//						map<Id,List<Offer__c>> mapPoIdListOffer = new map <Id,List<Offer__c>>();
//						for(Offer__c offer : mapInvIdOffersList.get(inv.Id)){
//							if(!mapPoIdListOffer.containsKey(offer.orderline__r.purchaseOrder__c)){
//								mapPoIdListOffer.put(offer.orderline__r.purchaseOrder__c,new list <Offer__c>{offer});
//							}
//							else{
//								mapPoIdListOffer.get(offer.orderline__r.purchaseOrder__c).add(offer);
//							}
//						}
//						mapInvIdPOIdOffersList.put(inv.Id,mapPoIdListOffer);
//					}
//				}
//
//				//system.debug('## mapInvIdPOIdOffersList ' + mapInvIdPOIdOffersList);
//				for(Id invId : mapInvIdPOIdOffersList.keySet()){
//					for(Id poId : mapInvIdPOIdOffersList.get(invId).keySet()){
//						//String externalNumber = String.ValueOf(System.now())+String.ValueOf(math.random());
//						//Invoice__c invChild = new Invoice__c(ParentInvoice__c = invId, Number__c = externalNumber,TECH_IsAdditionalDiscount__c = mapInvoice.get(invId).TECH_IsAdditionalDiscount__c,RecordTypeID = mapInvoice.get(invId).RecordTypeID, PurchaseOrder__c = poId, Prerequisiteorder__c = preOrd.id, Status__c = 'SENT'); 
//						Invoice__c invChild = mapClonedInvoice.get(invId).clone(false, true);
//						invChild.ParentInvoice__c = invId;
//						//invChild.Number__c = externalNumber;
//						invChild.PurchaseOrder__c = poId;
//						invChild.TotalASPrice__c = null;
//						invChild.TotalTTCDistributor__c = null;
//						TotalGrossAmount = 0;
//						TotaldiscountAmount = 0;
//						TotalNetChild = 0;
//						//numberOfPieces = 0;
//						//OffDelIds = '';
//						for(Offer__c off : mapInvIdPOIdOffersList.get(invId).get(poId)){
//
//							if(m_OfferToBeUpdated.containsKey(off.Id)){
//								// ASE: Association of offers to child invoice is not required
//								//m_OfferToBeUpdated.get(off.Id).InvoiceChild__r = new Invoice__c(Number__c = externalNumber);
//								//system.debug('## m_OfferToBeUpdated'+ m_OfferToBeUpdated);
//								if(off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
//								   off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
//								{
//									TotalNetChild += off.BSTotalPrice__c;
//								}
//								else
//								{
//									if(off.AdditionnalDiscount__c > 0)
//									{
//										//TotalNetChild += off.BSCreditNotePrice__c;
//										TotalNetChild += off.BSTotalPrice__c;
//									}
//									else if(off.AdditionnalDiscount__c < 0)
//									{
//										//TotalNetChild += (off.BSCreditNotePrice__c*(-1));
//										TotalNetChild += off.BSTotalPrice__c;
//									}
//									else
//									{
//										TotalNetChild +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
//									}
//								}
//								//TotalNetChild +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
//								TotalGrossAmount += off.Total__c;
//								TotaldiscountAmount += (off.Total__c*off.Discount__c)/100;
//								//numberOfPieces += off.Quantity__c.intValue();
//								//OffDelIds = OffDelIds +'-'+off.Id;
//							}
//						}
//						invChild.TotalGrossAmount__c = TotalGrossAmount;
//						invChild.TotalNet__c = TotalNetChild;
//						invChild.TotaldiscountAmount__c = TotaldiscountAmount;
//						invChild.TotalPieces__c = numberOfPieces;
//						invChild.TechOfferIds__c = OffDelIds;
//						l_invoicesChildToBeInserted.add(invChild);
//					}
//				}
//				if(l_invoicesChildToBeInserted.size()>0){
//					insert l_invoicesChildToBeInserted;
//				}
//
//				//system.debug('//// l_OfferToBeUpdated: '+ l_OfferToBeUpdated);
//				if(m_OfferToBeUpdated.size()>0){
//					update m_OfferToBeUpdated.values(); 
//				}
//				
//				if(l_invoicesToBeUpdated.size()>0){
//					update l_invoicesToBeUpdated;
//				}
//			}
//		}

        /*for(Offer__c off: listOffers){
            
            AStotalNet +=  off.TotalASPrice__c;
            system.debug('## TotalASPrice__c '+off.TotalASPrice__c);
            
            if(off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED){
                checkDeliveredStatus = true;
                l_OfferList.add(off);
                 //calculate discount price for invoice
                totalNet +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
                ++numberOfParts;
                numberOfPieces += off.Quantity__c.intValue();
                
            }

            // case C-001234
            if(off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED || off.DeliveryStatus__c=='RETURNED'){
                checkCanceledStatus = true;
                l_OfferList.add(off);

                //draft should contain canceled 
                totalNet +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
                ++numberOfParts;
                numberOfPieces += off.Quantity__c.intValue();

                canceledtotalNet += off.BSCreditNotePrice__c;
                ++cancelednumberOfParts;
                cancelednumberOfPieces += off.Quantity__c.intValue();
                system.debug('## BSCreditNotePrice__c' + off.BSCreditNotePrice__c);     
                system.debug('## canceledtotalNet' + canceledtotalNet);                 
            }

        }

        if(invoices.size()>0){
            for(Invoice__c inv:invoices){

                // Calculate total AS price
                
                
                //check if credit note invoice exists
                // case C-001234
                if(inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()){
                    checkInvCreditNoteCreated = true;

                    inv.TotalNet__c = canceledtotalNet;
                    inv.ItemsNumber__c = cancelednumberOfParts;
                    inv.TotalPieces__c = cancelednumberOfPieces;
                }
                //check if draft invoice exists
                else if(inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()){
                    checkInvDraftCreated = true;
                    inv.TotalASPrice__c = AStotalNet;
                    inv.TotalNet__c = totalNet;
                    inv.ItemsNumber__c = numberOfParts;
                    inv.TotalPieces__c = numberOfPieces;
                }

                rtIdInvoiceMap.put(inv.RecordTypeID,inv);
                l_invoicesToBeUpdated.add(inv);
            }
            //newInvoice = invoices[0];
        }
        else{

            //retrieve acc payment
            string rtacc_PaymenttId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();

            string paymentToId = null;
            Account[] acc_Payments = [Select Id,Name from Account WHERE RecordTypeID=:rtacc_PaymenttId and ShippingCountryCode=:preOrd.TECH_BodyshopCountryCode__c];
            if (acc_Payments.size() > 0){
                paymentToId= acc_Payments[0].Id;
            }

            system.debug('##paymentToId ' + paymentToId);
            system.debug('##RecordtypeId ' + Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId());
            
            //create draft invoice
            if(checkDeliveredStatus && checkInvDraftCreated ==false){
                Invoice__c newDraftInvoice = new Invoice__c(
                    Assessment__c = preOrd.Assessment__c,
                    BodyShop__c = preOrd.BodyShop__c,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = preOrd.id,
                    PaymentTo__c = paymentToId, 
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
                    Type__c = 'INVOICE',
                    IsBodyShop__c = true,
                    Paymentterms__c = preOrd.PaymentTerms__c,
                    TotalNet__c = totalNet,
                    ItemsNumber__c = numberOfParts,
                    TotalPieces__c = numberOfPieces
                );
                l_invoicesToBeInserted.add(newDraftInvoice);
            }

            //create credit note invoice

            // case C-001234
            system.debug('## inv RT:'+Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote));
            if(checkCanceledStatus && checkInvCreditNoteCreated==false){
                Invoice__c newCreditNoteInvoice = new Invoice__c(
                    Assessment__c = preOrd.Assessment__c,
                    BodyShop__c = preOrd.BodyShop__c,
                    //PreOrderNumber__c = preOrd.name,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = preOrd.id,
                    PaymentTo__c = paymentToId, 
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
                    Type__c = 'CREDITNOTE',
                    IsBodyShop__c = true,
                    Paymentterms__c = preOrd.PaymentTerms__c,
                    TotalNet__c = canceledtotalNet,
                    ItemsNumber__c = cancelednumberOfParts,
                    TotalPieces__c = cancelednumberOfPieces
                );
                l_invoicesToBeInserted.add(newCreditNoteInvoice); 
            }

            
        }
        if(l_invoicesToBeInserted.size()>0){
            ASPISWithoutSharingExceptions.insertInvoices(l_invoicesToBeInserted);
            system.debug('l_invoicesToBeInserted:'+l_invoicesToBeInserted); 

            map<Id,Invoice__c> rtIdInvMap = new map <Id,Invoice__c>();

            //build map rectypeId, and invoice
            for(Invoice__c inv1: l_invoicesToBeInserted){
                rtIdInvMap.put(inv1.RecordTypeID,inv1);
            }

            //update offers with invoice
            for(Offer__c off1: listOffers){
                system.debug('///// off1.OrderType__c: ' + off1.OrderType__c);
                system.debug('///// off1.Offers__r.size(): ' + off1.Offers__r.size());
                if(!(off1.OrderType__c == 'FINAL' && off1.Offers__r.size() > 0)){

                    // case C-001234
                    if(off1.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED){
                        if(rtIdInvMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())){
                            off1.CreditNote__c = rtIdInvMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()).Id;
                        }
                        
                        if(rtIdInvMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId())){
                            off1.Invoice__c = rtIdInvMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                        }
                    }
                    else if(off1.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED){
                        if(rtIdInvMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId())){
                            off1.Invoice__c = rtIdInvMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                        }
                        
                    }
                    l_OfferToBeUpdated.add(off1);
                    system.debug('## off1'+off1);
                }
            }

            system.debug('////// l_OfferToBeUpdated: ' + l_OfferToBeUpdated);
            if(l_OfferToBeUpdated.size()>0){
                update l_OfferToBeUpdated;
            }
        }//end if
        else{
            //update invoice and update offers
            system.debug('Invoices exist');

            for(Offer__c off1: listOffers){
                system.debug('///// 2 off1.OrderType__c: ' + off1.OrderType__c);
                system.debug('///// 2 off1.Offers__r.size(): ' + off1.Offers__r.size());
                 if(!(off1.OrderType__c == 'FINAL' && off1.Offers__r.size() > 0)){
                    // case C-001234
                    if(off1.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED){
                        if(rtIdInvoiceMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())){
                            off1.CreditNote__c=rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()).Id;
                        }
                        //off1.CreditNote__c = rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()).Id;
                        if(rtIdInvoiceMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId())){
                            off1.Invoice__c = rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                        }
                        //off1.Invoice__c = rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                    }
                    else if(off1.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED){
                        if(rtIdInvoiceMap.containsKey(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId())){
                            off1.Invoice__c = rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                        }
                        //off1.Invoice__c = rtIdInvoiceMap.get(Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()).Id;
                        
                        off1.CreditNote__c = null;
                    }
                    l_OfferToBeUpdated.add(off1);
                }
            }
            system.debug('////// 2 l_OfferToBeUpdated: ' + l_OfferToBeUpdated);
            if(l_OfferToBeUpdated.size()>0){
                update l_OfferToBeUpdated;
            }

            if(l_invoicesToBeUpdated.size()>0){
                update l_invoicesToBeUpdated;
            }

        }*/
               
             

        //@CLA Bug Delivered on All PO (even not selected)   ASPISWithoutSharingExceptions.updatePurchaseOrderList(listPO2Update);
        //@CLA Bug Delivered on All PO (even not selected)   ASPISWithoutSharingExceptions.updateOrderLineList(listOL2Update); 


        //DUN 01/06/2016 C-001647 commented code as now a map of Sales Orders is being used instead of one Sales Order
		// ABT 20-APR-2016
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Getting the sales order first by casting the sobject to PrerequisiteOrder__c
		//PrerequisiteOrder__c salesOrder = (PrerequisiteOrder__c) obj;

		//List<Invoice__c> invoiceToBeInsertedList = new List<Invoice__c>();
		//List<Invoice__c> invoiceChildToBeInsertedList = new List<Invoice__c>();

		//// Retrieving account payment
		//List<Account> paymentAccountList = [SELECT	Id, Name
		//								    FROM	Account
		//								    WHERE	RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(ASPISConstants.ACCOUNT_RT_LABEL_PAYMENT).getRecordTypeId()
		//								    AND		ShippingCountryCode =: salesOrder.TECH_BodyshopCountryCode__c];
		//String paymentToId = null;

		//if (paymentAccountList.size() > 0)
		//{
		//	paymentToId = paymentAccountList[0].Id;
		//}

		//// Main Invoice (1st Invoice)
		//Invoice__c mainInvoice = new Invoice__c(
		//										Assessment__c			= salesOrder.Assessment__c,
		//										BodyShop__c				= salesOrder.BodyShop__c,
		//										Status__c				= 'SENT',
		//										Prerequisiteorder__c	= salesOrder.Id,
		//										PaymentTo__c			= paymentToId, 
		//										RecordTypeId			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
		//										Type__c					= 'INVOICE',
		//										IsBodyShop__c			= true,
		//										PaymentTerms__c			= salesOrder.PaymentTerms__c,
		//										TotalGrossAmount__c		= 0,
		//										TotaldiscountAmount__c	= 0,
		//										TotalNet__c				= 0,
		//										ItemsNumber__c			= 0,
		//										TotalPieces__c			= 0,
		//										TechOfferIds__c			= null
		//									);

		//Invoice__c parentCreditNote = new Invoice__c(
		//												Assessment__c			= salesOrder.Assessment__c,
		//												BodyShop__c				= salesOrder.BodyShop__c,
		//												Status__c				= 'SENT',
		//												Prerequisiteorder__c	= salesOrder.Id,
		//												PaymentTo__c			= paymentToId, 
		//												RecordTypeID			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
		//												Type__c					= 'CREDITNOTE',
		//												IsBodyShop__c			= true,
		//												Paymentterms__c			= salesOrder.PaymentTerms__c,
		//												TotalGrossAmount__c		= 0,
		//												TotaldiscountAmount__c	= 0,
		//												TotalNet__c				= 0,
		//												ItemsNumber__c			= 0,
		//												TotalPieces__c			= 0,
		//												TechOfferIds__c			= null
		//											);

		//Invoice__c parentInvoice	= new Invoice__c(
		//												Assessment__c			= salesOrder.Assessment__c,
		//												BodyShop__c				= salesOrder.BodyShop__c,
		//												Status__c				= 'SENT',
		//												Prerequisiteorder__c	= salesOrder.Id,
		//												PaymentTo__c			= paymentToId, 
		//												RecordTypeID			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
		//												Type__c					= 'INVOICE',
		//												IsBodyShop__c			= true,
		//												Paymentterms__c			= salesOrder.PaymentTerms__c,
		//												TotalGrossAmount__c		= 0,
		//												TotaldiscountAmount__c	= 0,
		//												TotalNet__c				= 0,
		//												ItemsNumber__c			= 0,
		//												TotalPieces__c			= 0,
		//												TechOfferIds__c			= null
		//											);

		//Map<Id, Offer__c> mapOffer = new Map<Id, Offer__c>([ SELECT Id, DeliveryStatus__c, Total__c, TotalPriceNet__c, Discount__c, AdditionnalDiscount__c, OrderLine__c, OrderLine__r.PurchaseOrder__c,
		//															Quantity__c
		//													 FROM	Offer__c
		//													 WHERE	PrerequisiteOrder__c =: salesOrder.Id
		//													 AND	(	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_DELIVERED
		//															OR	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_CANCELED
		//															OR	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_RETURNED
		//															)
		//													 AND	Accepted__c = 'YES']);

		//// Getting the offers that is delivered/canceled/returned for that sales order
		//for (Offer__c off : mapOffer.values())
		//{
		//	// Whatever the status we have to create a general(main) invoice
		//	// This invoice will contain the Total Price with normal discount not additional discount for the sales order
		//	// So we increment the main invoice data
		//	mainInvoice.TotalGrossAmount__c		+= off.Total__c;
		//	mainInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//	mainInvoice.TotalNet__c				+= off.TotalPriceNet__c;
		//	mainInvoice.ItemsNumber__c			+= 1;
		//	mainInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
		//	// checking if it is the first offer
		//	// to avoid null in TechOfferIds__c
		//	if(mainInvoice.ItemsNumber__c == 1)
		//	{
		//		mainInvoice.TechOfferIds__c		= off.Id; 
		//	}
		//	else
		//	{
		//		mainInvoice.TechOfferIds__c		+= '-' + off.Id; 
		//	}
			

		//	// Check if the offer has been canceled or returned
		//	if (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
		//		off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
		//	{
		//		// Increment the credit note
		//		parentCreditNote.TotalGrossAmount__c	+= off.Total__c;
		//		parentCreditNote.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//		parentCreditNote.TotalNet__c			+= off.TotalPriceNet__c;
		//		parentCreditNote.ItemsNumber__c			+= 1;
		//		parentCreditNote.TotalPieces__c			+= off.Quantity__c.intValue();
		//		// checking if it is the first offer
		//		// to avoid null in TechOfferIds__c
		//		if(parentCreditNote.ItemsNumber__c == 1)
		//		{
		//			parentCreditNote.TechOfferIds__c	= off.Id; 
		//		}
		//		else
		//		{
		//			parentCreditNote.TechOfferIds__c	+= '-' + off.Id; 
		//		}
		//	}
		//	else
		//	{
		//		// Offer is delivered
		//		if (off.AdditionnalDiscount__c > 0)
		//		{
		//			// should go to a credit note
		//			// Increment the credit note
		//			parentCreditNote.TotalGrossAmount__c	+= off.Total__c;
		//			parentCreditNote.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//			parentCreditNote.TotalNet__c			+= (off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100;
		//			parentCreditNote.ItemsNumber__c			+= 1;
		//			parentCreditNote.TotalPieces__c			+= off.Quantity__c.intValue();
		//			// checking if it is the first offer
		//			// to avoid null in TechOfferIds__c
		//			if(parentCreditNote.ItemsNumber__c == 1)
		//			{
		//				parentCreditNote.TechOfferIds__c	= off.Id; 
		//			}
		//			else
		//			{
		//				parentCreditNote.TechOfferIds__c	+= '-' + off.Id; 
		//			}

		//			parentCreditNote.TECH_IsAdditionalDiscount__c = true;
		//		}
		//		else if (off.AdditionnalDiscount__c < 0)
		//		{
		//			// should be and invoice
		//			parentInvoice.TotalGrossAmount__c		+= off.Total__c;
		//			parentInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//			parentInvoice.TotalNet__c				+= Math.abs((off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100);
		//			parentInvoice.ItemsNumber__c			+= 1;
		//			// checking if it is the first offer
		//			// to avoid null in TechOfferIds__c
		//			if(parentInvoice.ItemsNumber__c == 1)
		//			{
		//				parentInvoice.TechOfferIds__c		= off.Id; 
		//			}
		//			else
		//			{
		//				parentInvoice.TechOfferIds__c		+= '-' + off.Id; 
		//			}

		//			parentInvoice.TECH_IsAdditionalDiscount__c = true;
		//		}
		//	}
		//}

		//if (mainInvoice.ItemsNumber__c > 0)
		//{
		//	invoiceToBeInsertedList.add(mainInvoice);
		//}

		//if (parentCreditNote.ItemsNumber__c > 0)
		//{
		//	invoiceToBeInsertedList.add(parentCreditNote);
		//}

		//if (parentInvoice.ItemsNumber__c > 0)
		//{
		//	invoiceToBeInsertedList.add(parentInvoice);
		//}

		//if (invoiceToBeInsertedList.size() > 0)
		//{
		//	// inserting the invoices
		//	ASPISWithoutSharingExceptions.insertInvoices(invoiceToBeInsertedList);

		//	// Updating the sales order
		//	PrerequisiteOrder__c so = new PrerequisiteOrder__c(Id				 = salesOrder.Id,
		//													   TechIsInvoiced__c = true);
		//	update so;
			
		//	//******************************************************************************
		//	// Creating a map with the invoices inserted
		//	Map<Id, Invoice__c> mapIdInvoice = new Map<Id, Invoice__c>(invoiceToBeInsertedList);
		//	//******************************************************************************

		//	Map<Id, Offer__c> mapIdOfferToUpdate = new Map<Id, Offer__c>();
		//	// Setting the offers last invoice/credit note
		//	for(Offer__c off : mapOffer.values())
		//	{
		//		for(Invoice__c inv : mapIdInvoice.values())
		//		{
		//			if(inv.TechOfferIds__c.contains(off.Id))
		//			{
		//				if (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())
		//				{
		//					off.CreditNote__c = inv.Id;
		//				}
						
		//				if (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId())
		//				{
		//					off.Invoice__c = inv.Id;
							
		//				}

		//				mapIdOfferToUpdate.put(off.Id, off);
		//			}
		//		}
		//	}

		//	// Check if the sales order needs invoice details
		//	if (CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c) != null &&
		//		CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c)
		//	{
		//		// therefore should create child invoice

		//		// Map Of Invoice with its different PO and the PO offers
		//		Map<Id, Map<Id, List<Offer__c>>> mapInvoicePOOffers = new Map<Id, Map<Id, List<Offer__c>>>();
		//		for(Invoice__c inv : invoiceToBeInsertedList)
		//		{
		//			// Get the offer ids affecting that invoice
		//			if(inv.TechOfferIds__c != null)
		//			{
		//				// creating a temp map that will containg the offers of 1 invoice (current invoice)
		//				Map<Id, List<Offer__c>> tempMapPOListOfOffer = new Map<Id, List<Offer__c>>();
						
		//				// loop in each offer id of that invoice
		//				for(String offerId : inv.TechOfferIds__c.split('-'))
		//				{
		//					// get the offer
		//					Offer__c currentOffer = mapOffer.get(offerId);
		//					// check if its PO already exists
		//					// put in the temp map
		//					if(!tempMapPOListOfOffer.containsKey(currentOffer.OrderLine__r.PurchaseOrder__c))
		//					{
		//						// does not contain that PO
		//						// create a new list for that PO
		//						tempMapPOListOfOffer.put(currentOffer.OrderLine__r.PurchaseOrder__c, new List<Offer__c> {currentOffer});
		//					}
		//					else
		//					{
		//						// Contains that PO
		//						// add the offer
		//						tempMapPOListOfOffer.get(currentOffer.OrderLine__r.PurchaseOrder__c).add(currentOffer);
		//					}
		//				}

		//				// put temp map with its invoice id as key
		//				mapInvoicePOOffers.put(inv.Id, tempMapPOListOfOffer);
		//			}
		//		}

		//		for (Id invId : mapInvoicePOOffers.keySet())
		//		{
		//			for(Id poId : mapInvoicePOOffers.get(invId).keySet())
		//			{
		//				// Cloning the parent Invoice (Invoice/ Credit Note)
		//				Invoice__c childInvoice = mapIdInvoice.get(invId).clone(false, true);
		//				// Setting the parent of the child invoice and its purchase id
		//				childInvoice.ParentInvoice__c		= invId;
		//				childInvoice.PurchaseOrder__c		= poId;
		//				// clearing the values
		//				childInvoice.TotalGrossAmount__c	= 0;
		//				childInvoice.TotaldiscountAmount__c = 0;
		//				childInvoice.TotalNet__c			= 0;
		//				childInvoice.ItemsNumber__c			= 0;
		//				childInvoice.TotalPieces__c			= 0;
		//				childInvoice.TechOfferIds__c		= null;

		//				// Loop in the offers of that purchase order
		//				for(Offer__c off : mapInvoicePOOffers.get(invId).get(poId))
		//				{
		//					// Must check if the current invoice id is the main invoice
		//					// For main invoice whatever the status it should be calculated the same
		//					if(mainInvoice.Id == invId)
		//					{
		//						// Creation of child invoice for the main invoice
		//						childInvoice.TotalGrossAmount__c		+= off.Total__c;
		//						childInvoice.TotaldiscountAmount__c		+= (off.Total__c * off.Discount__c) / 100;
		//						childInvoice.TotalNet__c				+= off.TotalPriceNet__c;
		//						childInvoice.ItemsNumber__c				+= 1;
		//						childInvoice.TotalPieces__c				+= off.Quantity__c.intValue();
		//						// checking if it is the first offer
		//						// to avoid null in TechOfferIds__c
		//						if(childInvoice.ItemsNumber__c == 1)
		//						{
		//							childInvoice.TechOfferIds__c		= off.Id; 
		//						}
		//						else
		//						{
		//							childInvoice.TechOfferIds__c		+= '-' + off.Id; 
		//						}
		//					}
		//					else
		//					{
		//						// not the main invoice
		//						// should check if the status is canceled/ returned or has additional discount
		//						if (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
		//							off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
		//						{
		//							// Increment the credit note
		//							childInvoice.TotalGrossAmount__c	+= off.Total__c;
		//							childInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//							childInvoice.TotalNet__c			+= off.TotalPriceNet__c;
		//							childInvoice.ItemsNumber__c			+= 1;
		//							childInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
		//							// checking if it is the first offer
		//							// to avoid null in TechOfferIds__c
		//							if(childInvoice.ItemsNumber__c == 1)
		//							{
		//								childInvoice.TechOfferIds__c	= off.Id; 
		//							}
		//							else
		//							{
		//								childInvoice.TechOfferIds__c	+= '-' + off.Id; 
		//							}
		//						}
		//						else
		//						{
		//							// Offer is delivered
		//							if (off.AdditionnalDiscount__c > 0)
		//							{
		//								// should go to a credit note
		//								// Increment the credit note
		//								childInvoice.TotalGrossAmount__c	+= off.Total__c;
		//								childInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
		//								childInvoice.TotalNet__c			+= (off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100;
		//								childInvoice.ItemsNumber__c			+= 1;
		//								childInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
		//								// checking if it is the first offer
		//								// to avoid null in TechOfferIds__c
		//								if(childInvoice.ItemsNumber__c == 1)
		//								{
		//									childInvoice.TechOfferIds__c	= off.Id; 
		//								}
		//								else
		//								{
		//									childInvoice.TechOfferIds__c	+= '-' + off.Id; 
		//								}

		//								childInvoice.TECH_IsAdditionalDiscount__c = true;
		//							}
		//							else if (off.AdditionnalDiscount__c < 0)
		//							{
		//								// should be and invoice
		//								childInvoice.TotalGrossAmount__c		+= off.Total__c;
		//								childInvoice.TotaldiscountAmount__c		+= (off.Total__c * off.Discount__c) / 100;
		//								childInvoice.TotalNet__c				+= Math.abs((off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100);
		//								childInvoice.ItemsNumber__c				+= 1;
		//								// checking if it is the first offer
		//								// to avoid null in TechOfferIds__c
		//								if(childInvoice.ItemsNumber__c == 1)
		//								{
		//									childInvoice.TechOfferIds__c		= off.Id; 
		//								}
		//								else
		//								{
		//									childInvoice.TechOfferIds__c		+= '-' + off.Id; 
		//								}

		//								childInvoice.TECH_IsAdditionalDiscount__c = true;
		//							}
		//						}
		//					}
		//				}

		//				invoiceChildToBeInsertedList.add(childInvoice);
		//			}
		//		}
		//	}

		//	if(invoiceChildToBeInsertedList.size() > 0)
		//	{	
		//		insert invoiceChildToBeInsertedList;
		//	}

		//	if(mapIdOfferToUpdate.size() > 0)
		//	{
		//		update mapIdOfferToUpdate.values();
		//	}
		//}
		//
		//AMI 26/06/18 : Community Rollout 
	    string aspisSystemUserId = '';
	    string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
	    string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

	    if(string.isNotBlank(system.label.UserAspisSystemName)){
	    	for(User us : [Select id,Profile.UserLicense.Name 
	    					from User 
	    					where Name = :system.label.UserAspisSystemName]){
	    		aspisSystemUserId = us.Id;
	    	}
	    }

		//DUN 01/06/2016 C-001647
        // map that contains payment terms details and shipping countryCode
        map<String, String> ShippingCodePaymentMap = new map<String, String>(); 

        // map that contains SalesorderId and a map of Offers
        map<Id,map<Id,Offer__c>> SOIdOffIdOfferMap = new map<Id,map<Id,Offer__c>>();

        map<Id,list<Invoice__c>> SOIdlistInvoiceInsertedMap = new map<Id,list<Invoice__c>>();

		//list of invoice To Be Inserted
    	List<Invoice__c> invoiceToBeInsertedList = new List<Invoice__c>();

    	List<PrerequisiteOrder__c> SOToUpdate = new List<PrerequisiteOrder__c>();

		//list of invoice To Be Inserted
    	List<Invoice__c> invoiceChildToBeInsertedList = new List<Invoice__c>();
        //Payment account
        String paymentToId = null;

        String externalNumber = '';

		// ABT - 07-FEB-2017 - C-001620
		Map<Id, OrderLine__c> mapOrderLinesToUpdate = new Map<Id, OrderLine__c>();

		// build a map of shipping code and payment ID
        for(Account acc : [Select Id,Name, ShippingCountryCode from Account WHERE RecordTypeID=:Schema.SObjectType.Account.getRecordTypeInfosByName().get(ASPISConstants.ACCOUNT_RT_LABEL_PAYMENT).getRecordTypeId()]){
            if(!ShippingCodePaymentMap.containsKey(acc.ShippingCountryCode)){
                ShippingCodePaymentMap.put(acc.ShippingCountryCode, acc.Id);
            }
            
        }

        //DUN 04/05/2017  C-001904: added condition if assessment not in agency mode
        //DUN 08/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
        for(Offer__c off : [ SELECT Id, DeliveryStatus__c, Total__c, TotalPriceNet__c, Discount__c, AdditionalDiscountAmount__c, OrderLine__c, 
									OrderLine__r.PurchaseOrder__c, Quantity__c, PrerequisiteOrder__c, OrderLine__r.TECH_ToBeProcessed__c,
									OrderLine__r.PreviousAdditionalDiscountAmount__c, AgencyMode__c
							FROM	Offer__c
							WHERE	PrerequisiteOrder__c in: mapIdSalesOrder.KeySet()
							AND		(	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_DELIVERED
									OR	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_CANCELED
									OR	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_RETURNED
									)
							AND		Accepted__c = 'YES'
							AND     AgencyMode__c = false]){
        	if(SOIdOffIdOfferMap.containsKey(off.PrerequisiteOrder__c)){
        		SOIdOffIdOfferMap.get(off.PrerequisiteOrder__c).put(off.Id,off);
        	}
        	else{
        		SOIdOffIdOfferMap.put(off.PrerequisiteOrder__c,new map<Id,Offer__c>{off.Id => off});
        	}
        }

        //AMI 26/06/18 : Community Rollout 
        //             : Querying tech licence name on bodyshop
        for(PrerequisiteOrder__c salesOrder : [Select Id,TECH_BodyshopCountryCode__c,Assessment__c,BodyShop__c,
        												BodyShop__r.Tech_ContactUserLicenceName__c,BodyShop__r.ContactUser__c,
        												PaymentTerms__c
              									from PrerequisiteOrder__c 
              									where id IN :mapIdSalesOrder.keySet()]){
        	//Getting the offers that is delivered/canceled/returned for that sales order
			if(!SOIdOffIdOfferMap.isEmpty() && SOIdOffIdOfferMap.containsKey(salesOrder.Id) && SOIdOffIdOfferMap.get(salesOrder.Id).size() > 0){

	        	if(ShippingCodePaymentMap.containsKey(salesOrder.TECH_BodyshopCountryCode__c)){
	        		paymentToId = ShippingCodePaymentMap.get(salesOrder.TECH_BodyshopCountryCode__c);
	        	}
	        	SOToUpdate.add(new PrerequisiteOrder__c(Id = salesOrder.Id, TechIsInvoiced__c = true, Status__c = 'INVOICED'));

	        	//Main Invoice (1st Invoice)
				Invoice__c mainInvoice = new Invoice__c(
														Assessment__c			= salesOrder.Assessment__c,
														BodyShop__c				= salesOrder.BodyShop__c,
														Status__c				= 'SENT',
														Prerequisiteorder__c	= salesOrder.Id,
														PaymentTo__c			= paymentToId, 
														RecordTypeId			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
														Type__c					= 'INVOICE',
														IsBodyShop__c			= true,
														PaymentTerms__c			= salesOrder.PaymentTerms__c,
														TECH_InvoiceParent__c   = String.ValueOf(System.now())+String.ValueOf(math.random()),
														TotalGrossAmount__c		= 0,
														TotaldiscountAmount__c	= 0,
														TotalNet__c				= 0,
														ItemsNumber__c			= 0,
														TotalPieces__c			= 0,
														TechOfferIds__c			= null
													);

				//AMI 26/06/18 : Community Rollout 
			    //             : Updating Owner
                if(string.isNotBlank(formattedLicenseName) && 
                   string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   string.isNotBlank(aspisSystemUserId)){
                     mainInvoice.OwnerId = aspisSystemUserId;
                }else if(
                	    (
                	   	string.isBlank(formattedLicenseName) ||
	                	(
	                	 string.isNotBlank(formattedLicenseName) && 
	                	 (string.isBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) ||
	                	 (string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
	                	!formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c)))
	                	)
	                	) &&
	                	salesOrder.BodyShop__r.ContactUser__c != null
	                	){
                	mainInvoice.OwnerId = salesOrder.BodyShop__r.ContactUser__c;
                }

				Invoice__c parentCreditNote = new Invoice__c(
																Assessment__c			= salesOrder.Assessment__c,
																BodyShop__c				= salesOrder.BodyShop__c,
																Status__c				= 'SENT',
																Prerequisiteorder__c	= salesOrder.Id,
																PaymentTo__c			= paymentToId, 
																RecordTypeID			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
																Type__c					= 'CREDITNOTE',
																IsBodyShop__c			= true,
																Paymentterms__c			= salesOrder.PaymentTerms__c,
																TECH_InvoiceParent__c   = String.ValueOf(System.now())+String.ValueOf(math.random()),
																TotalGrossAmount__c		= 0,
																TotaldiscountAmount__c	= 0,
																TotalNet__c				= 0,
																ItemsNumber__c			= 0,
																TotalPieces__c			= 0,
																TechOfferIds__c			= null
															);

				//AMI 26/06/18 : Community Rollout 
			    //             : Updating Owner
                if(string.isNotBlank(formattedLicenseName) && 
                   string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   string.isNotBlank(aspisSystemUserId)){
                     parentCreditNote.OwnerId = aspisSystemUserId;
                }else if(
                	    (
                	   	string.isBlank(formattedLicenseName) ||
	                	(
	                	 string.isNotBlank(formattedLicenseName) && 
	                	 (string.isBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) ||
	                	 (string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
	                	!formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c)))
	                	)
	                	) &&
	                	salesOrder.BodyShop__r.ContactUser__c != null
	                	){
                	parentCreditNote.OwnerId = salesOrder.BodyShop__r.ContactUser__c;
                }

				Invoice__c parentInvoice	= new Invoice__c(
																Assessment__c			= salesOrder.Assessment__c,
																BodyShop__c				= salesOrder.BodyShop__c,
																Status__c				= 'SENT',
																Prerequisiteorder__c	= salesOrder.Id,
																PaymentTo__c			= paymentToId, 
																RecordTypeID			= Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
																Type__c					= 'INVOICE',
																IsBodyShop__c			= true,
																Paymentterms__c			= salesOrder.PaymentTerms__c,
																TECH_InvoiceParent__c   = String.ValueOf(System.now())+String.ValueOf(math.random()),
																TotalGrossAmount__c		= 0,
																TotaldiscountAmount__c	= 0,
																TotalNet__c				= 0,
																ItemsNumber__c			= 0,
																TotalPieces__c			= 0,
																TechOfferIds__c			= null
															);	

				//AMI 26/06/18 : Community Rollout 
			    //             : Updating Owner
                if(string.isNotBlank(formattedLicenseName) && 
                   string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
                   string.isNotBlank(aspisSystemUserId)){
                     parentInvoice.OwnerId = aspisSystemUserId;
                }else if(
                	    (
                	   	string.isBlank(formattedLicenseName) ||
	                	(
	                	 string.isNotBlank(formattedLicenseName) && 
	                	 (string.isBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) ||
	                	 (string.isNotBlank(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c) &&
	                	!formattedLicenseName.contains(salesOrder.BodyShop__r.Tech_ContactUserLicenceName__c)))
	                	)
	                	) &&
	                	salesOrder.BodyShop__r.ContactUser__c != null
	                	){
                	parentInvoice.OwnerId = salesOrder.BodyShop__r.ContactUser__c;
                }			

				for (Offer__c off : SOIdOffIdOfferMap.get(salesOrder.Id).values()){
					//Whatever the status we have to create a general(main) invoice
					//This invoice will contain the Total Price with normal discount not additional discount for the sales order
					//So we increment the main invoice data
					mainInvoice.TotalGrossAmount__c		+= off.Total__c;
					mainInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
					mainInvoice.TotalNet__c				+= off.TotalPriceNet__c;
					mainInvoice.ItemsNumber__c			+= 1;
					mainInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
					// checking if it is the first offer
					// to avoid null in TechOfferIds__c
					if(mainInvoice.ItemsNumber__c == 1){
						mainInvoice.TechOfferIds__c		= off.Id; 
					}
					else{
						mainInvoice.TechOfferIds__c		+= '-' + off.Id; 
					}
					

					// Check if the offer has been canceled or returned
					if (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
						off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED){
						// Increment the credit note
						parentCreditNote.TotalGrossAmount__c	+= off.Total__c;
						parentCreditNote.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
						parentCreditNote.TotalNet__c			+= off.TotalPriceNet__c;
						parentCreditNote.ItemsNumber__c			+= 1;
						parentCreditNote.TotalPieces__c			+= off.Quantity__c.intValue();
						// checking if it is the first offer
						// to avoid null in TechOfferIds__c
						if(parentCreditNote.ItemsNumber__c == 1){
							parentCreditNote.TechOfferIds__c	= off.Id; 
						}
						else{
							parentCreditNote.TechOfferIds__c	+= '-' + off.Id; 
						}
					}
					// ABT - 21-FEB-2017 - Changed else to the condition below
					else if (!isGenerateAgainProcess &&
							 off.OrderLine__c != null &&
							 off.OrderLine__r.TECH_ToBeProcessed__c)
					{
						// Offer is delivered
						if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0) ||
							(off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c > 0))
						{
							// should go to a credit note
							// Increment the credit note
							parentCreditNote.TotalGrossAmount__c	+= off.Total__c;
							parentCreditNote.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
							// ABT - 18-JAN-2017 - C-001620 - Changed the calculation
							// parentCreditNote.TotalNet__c			+= (off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100;
							// parentCreditNote.TotalNet__c			+= off.AdditionalDiscountAmount__c;
							parentCreditNote.TotalNet__c			+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																				((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
							parentCreditNote.ItemsNumber__c			+= 1;
							parentCreditNote.TotalPieces__c			+= off.Quantity__c.intValue();
							// checking if it is the first offer
							// to avoid null in TechOfferIds__c
							if(parentCreditNote.ItemsNumber__c == 1){
								parentCreditNote.TechOfferIds__c	= off.Id; 
							}
							else{  
								parentCreditNote.TechOfferIds__c	+= '-' + off.Id; 
							}  

							parentCreditNote.TECH_IsAdditionalDiscount__c = true;   
						}
						else if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0) ||
								 (off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c < 0)){
							// should be and invoice
							parentInvoice.TotalGrossAmount__c		+= off.Total__c;
							parentInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
							// ABT - 18-JAN-2017 - C-001620 - Changed the calculation
							// parentInvoice.TotalNet__c				+= Math.abs((off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100);
							// parentInvoice.TotalNet__c				+= Math.abs(off.AdditionalDiscountAmount__c);
							parentInvoice.TotalNet__c				+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																				((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
							parentInvoice.ItemsNumber__c			+= 1;
							// checking if it is the first offer
							// to avoid null in TechOfferIds__c
							if(parentInvoice.ItemsNumber__c == 1){
								parentInvoice.TechOfferIds__c		= off.Id; 
							}
							else{
								parentInvoice.TechOfferIds__c		+= '-' + off.Id; 
							}

							parentInvoice.TECH_IsAdditionalDiscount__c = true;
						}
					}
					// Section Only when the process is triggered from VFC10_GenerateInvoiceProcess
					else if (isGenerateAgainProcess)
					{
						if (off.AdditionalDiscountAmount__c > 0)
						{
							parentCreditNote.TotalGrossAmount__c	+= off.Total__c;
							parentCreditNote.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
							parentCreditNote.TotalNet__c			+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0));
							parentCreditNote.ItemsNumber__c			+= 1;
							parentCreditNote.TotalPieces__c			+= off.Quantity__c.intValue();
							
							// checking if it is the first offer to avoid null in TechOfferIds__c
							if(parentCreditNote.ItemsNumber__c == 1){
								parentCreditNote.TechOfferIds__c	= off.Id; 
							}
							else{
								parentCreditNote.TechOfferIds__c	+= '-' + off.Id; 
							}

							parentCreditNote.TECH_IsAdditionalDiscount__c = true;
						}
						else if (off.AdditionalDiscountAmount__c < 0){
							// should be and invoice
							parentInvoice.TotalGrossAmount__c		+= off.Total__c;
							parentInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
							parentInvoice.TotalNet__c				+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0));
							parentInvoice.ItemsNumber__c			+= 1;
							
							// checking if it is the first offer to avoid null in TechOfferIds__c
							if(parentInvoice.ItemsNumber__c == 1){
								parentInvoice.TechOfferIds__c		= off.Id; 
							}
							else{
								parentInvoice.TechOfferIds__c		+= '-' + off.Id; 
							}

							parentInvoice.TECH_IsAdditionalDiscount__c = true;
						}
					}

					// ABT - 07-FEB-2017 - C-001620 - Capturing the order lines having TECH_ToBeProcessed__c to true
					if(	off.OrderLine__c != null &&
						off.OrderLine__r.TECH_ToBeProcessed__c)
					{
						mapOrderLinesToUpdate.put(off.OrderLine__c, new OrderLine__c(Id = off.OrderLine__c,
																					 TECH_ToBeProcessed__c = false));
					}
				}
				if (mainInvoice.ItemsNumber__c > 0){
					invoiceToBeInsertedList.add(mainInvoice);
					SOIdlistInvoiceInsertedMap.put(salesOrder.Id,new list<Invoice__c>{mainInvoice});
				}

				if (parentCreditNote.ItemsNumber__c > 0){
					invoiceToBeInsertedList.add(parentCreditNote);
					SOIdlistInvoiceInsertedMap.get(salesOrder.Id).add(parentCreditNote);
				}

				if (parentInvoice.ItemsNumber__c > 0){
					invoiceToBeInsertedList.add(parentInvoice);				
					SOIdlistInvoiceInsertedMap.get(salesOrder.Id).add(parentInvoice);
				}
			}
        }

        /*if(invoiceToBeInsertedList.size() > 0){
        	//inserting the invoices
        	insert invoiceToBeInsertedList;

        	//Updating the sales order
        	update mapIdSalesOrder.values();
        }*/

		//Creating a map with the invoices inserted
		//Map<Id, Invoice__c> mapIdInvoice = new Map<Id, Invoice__c>(invoiceToBeInsertedList);

		Map<Id, Offer__c> mapIdOfferToUpdate = new Map<Id, Offer__c>();
		//Setting the offers last invoice/credit note
		for(PrerequisiteOrder__c salesOrder : mapIdSalesOrder.values()){
			if(!SOIdOffIdOfferMap.isEmpty() && SOIdOffIdOfferMap.containsKey(salesOrder.Id)){
				for(Offer__c off : SOIdOffIdOfferMap.get(salesOrder.Id).values()){
					if(SOIdlistInvoiceInsertedMap.containsKey(salesOrder.Id)){
						for(Invoice__c inv : SOIdlistInvoiceInsertedMap.get(salesOrder.Id)){
							if(inv.TechOfferIds__c.contains(off.Id)){
								if (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()){
									//off.CreditNote__c = inv.Id;
									off.CreditNote__r = new Invoice__c(TECH_InvoiceParent__c = inv.TECH_InvoiceParent__c);
								}
								
								if (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()){
									//off.Invoice__c = inv.Id;
									off.Invoice__r = new Invoice__c(TECH_InvoiceParent__c = inv.TECH_InvoiceParent__c);
								}

								mapIdOfferToUpdate.put(off.Id, off);
							}
						}
					}
				}
			}
			// Check if the sales order needs invoice details
			if (CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c) != null &&
				CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c){
				system.debug('## Child invoice');
				// therefore should create child invoice
				// Map Of Invoice with its different PO and the PO offers
				Map<String, Map<Id, List<Offer__c>>> mapInvoicePOOffers = new Map<String, Map<Id, List<Offer__c>>>();
				if(SOIdlistInvoiceInsertedMap.containsKey(salesOrder.Id)){
					for(Invoice__c inv : SOIdlistInvoiceInsertedMap.get(salesOrder.Id)){
						// Get the offer ids affecting that invoice
						if(inv.TechOfferIds__c != null){
							// creating a temp map that will containg the offers of 1 invoice (current invoice)
							Map<Id, List<Offer__c>> tempMapPOListOfOffer = new Map<Id, List<Offer__c>>();
							
							// loop in each offer id of that invoice
							for(String offerId : inv.TechOfferIds__c.split('-')){
								// get the offer
								Offer__c currentOffer = SOIdOffIdOfferMap.get(salesOrder.Id).get(offerId);
								// check if its PO already exists
								// put in the temp map
								if(!tempMapPOListOfOffer.containsKey(currentOffer.OrderLine__r.PurchaseOrder__c)){
									// does not contain that PO
									// create a new list for that PO
									tempMapPOListOfOffer.put(currentOffer.OrderLine__r.PurchaseOrder__c, new List<Offer__c> {currentOffer});
								}
								else{
									// Contains that PO
									// add the offer
									tempMapPOListOfOffer.get(currentOffer.OrderLine__r.PurchaseOrder__c).add(currentOffer);
								}
							}

							// put temp map with its invoice id as key
							mapInvoicePOOffers.put(inv.TECH_InvoiceParent__c, tempMapPOListOfOffer);
						}
					}
				}
				if(SOIdlistInvoiceInsertedMap.containsKey(salesOrder.Id)){
					for (Invoice__c inv : SOIdlistInvoiceInsertedMap.get(salesOrder.Id)){
						for(Id poId : mapInvoicePOOffers.get(inv.TECH_InvoiceParent__c).keySet()){
							// Cloning the parent Invoice (Invoice/ Credit Note)
							Invoice__c childInvoice = inv.clone(false, true);
							// Setting the parent of the child invoice and its purchase id
							//childInvoice.ParentInvoice__c		= invId;
							childInvoice.ParentInvoice__r       = new Invoice__c(TECH_InvoiceParent__c = inv.TECH_InvoiceParent__c); 
							childInvoice.PurchaseOrder__c		= poId;
							// clearing the values
							childInvoice.TotalGrossAmount__c	= 0;
							childInvoice.TotaldiscountAmount__c = 0;
							childInvoice.TotalNet__c			= 0;
							childInvoice.ItemsNumber__c			= 0;
							childInvoice.TotalPieces__c			= 0;
							childInvoice.TechOfferIds__c		= null;
							childInvoice.TECH_Number__c = null;//RLA 15/06/2018 case 2617 - Duplicate TechNumber
							childInvoice.TECH_InvoiceParent__c  = String.ValueOf(System.now())+String.ValueOf(math.random());

							// Loop in the offers of that purchase order
							for(Offer__c off : mapInvoicePOOffers.get(inv.TECH_InvoiceParent__c).get(poId)){
								// Must check if the current invoice id is the main invoice
								// For main invoice whatever the status it should be calculated the same
								if(SOIdlistInvoiceInsertedMap.get(salesOrder.Id)[0].TECH_InvoiceParent__c == inv.TECH_InvoiceParent__c){
									// Creation of child invoice for the main invoice
									childInvoice.TotalGrossAmount__c		+= off.Total__c;
									childInvoice.TotaldiscountAmount__c		+= (off.Total__c * off.Discount__c) / 100;
									childInvoice.TotalNet__c				+= off.TotalPriceNet__c;
									childInvoice.ItemsNumber__c				+= 1;
									childInvoice.TotalPieces__c				+= off.Quantity__c.intValue();
									// checking if it is the first offer
									// to avoid null in TechOfferIds__c
									if(childInvoice.ItemsNumber__c == 1){
										childInvoice.TechOfferIds__c		= off.Id; 
									}
									else{
										childInvoice.TechOfferIds__c		+= '-' + off.Id; 
									}
								}
								else
								{
									// not the main invoice
									// should check if the status is canceled/ returned or has additional discount
									if (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
										off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
									{
										// Increment the credit note
										childInvoice.TotalGrossAmount__c	+= off.Total__c;
										childInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
										childInvoice.TotalNet__c			+= off.TotalPriceNet__c;
										childInvoice.ItemsNumber__c			+= 1;
										childInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
										// checking if it is the first offer
										// to avoid null in TechOfferIds__c
										if(childInvoice.ItemsNumber__c == 1)
										{
											childInvoice.TechOfferIds__c	= off.Id; 
										}
										else
										{
											childInvoice.TechOfferIds__c	+= '-' + off.Id; 
										}
									}
									// ABT - 21-FEB-2017 - Changed else to the condition below
									else if (!isGenerateAgainProcess &&
											 off.OrderLine__c != null &&
											 off.OrderLine__r.TECH_ToBeProcessed__c)
									{
										// Offer is delivered
										if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0) ||
											(off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c > 0))
										{
											// should go to a credit note
											// Increment the credit note
											childInvoice.TotalGrossAmount__c	+= off.Total__c;
											childInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
											// ABT - 18-JAN-2017 - C-001620 - Changed the calculation
											// childInvoice.TotalNet__c			+= (off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100;
											childInvoice.TotalNet__c			+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																							((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
											childInvoice.ItemsNumber__c			+= 1;
											childInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
											// checking if it is the first offer
											// to avoid null in TechOfferIds__c
											if(childInvoice.ItemsNumber__c == 1)
											{
												childInvoice.TechOfferIds__c	= off.Id; 
											}
											else
											{
												childInvoice.TechOfferIds__c	+= '-' + off.Id; 
											}

											childInvoice.TECH_IsAdditionalDiscount__c = true;
										}
										else if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0) ||
											 	 (off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c < 0))
										{
											// should be an invoice
											childInvoice.TotalGrossAmount__c		+= off.Total__c;
											childInvoice.TotaldiscountAmount__c		+= (off.Total__c * off.Discount__c) / 100;
											// ABT - 18-JAN-2017 - C-001620 - Changed the calculation
											// childInvoice.TotalNet__c				+= Math.abs((off.TotalPriceNet__c * off.AdditionnalDiscount__c) / 100);
											childInvoice.TotalNet__c				+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																					((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
											childInvoice.ItemsNumber__c				+= 1;
											// checking if it is the first offer
											// to avoid null in TechOfferIds__c
											if(childInvoice.ItemsNumber__c == 1)
											{
												childInvoice.TechOfferIds__c		= off.Id; 
											}
											else
											{
												childInvoice.TechOfferIds__c		+= '-' + off.Id; 
											}

											childInvoice.TECH_IsAdditionalDiscount__c = true;
										}
									}
									else if (isGenerateAgainProcess)
									{
										if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) > 0) ||
											(off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c > 0))
										{
											// should go to a credit note
											// Increment the credit note
											childInvoice.TotalGrossAmount__c	+= off.Total__c;
											childInvoice.TotaldiscountAmount__c	+= (off.Total__c * off.Discount__c) / 100;
											childInvoice.TotalNet__c			+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																							((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
											childInvoice.ItemsNumber__c			+= 1;
											childInvoice.TotalPieces__c			+= off.Quantity__c.intValue();
											// checking if it is the first offer to avoid null in TechOfferIds__c
											if(childInvoice.ItemsNumber__c == 1)
											{
												childInvoice.TechOfferIds__c	= off.Id; 
											}
											else
											{
												childInvoice.TechOfferIds__c	+= '-' + off.Id; 
											}

											childInvoice.TECH_IsAdditionalDiscount__c = true;
										}
										else if ((off.Orderline__r.PreviousAdditionalDiscountAmount__c != null && (off.AdditionalDiscountAmount__c - off.Orderline__r.PreviousAdditionalDiscountAmount__c) < 0) ||
											 	 (off.Orderline__r.PreviousAdditionalDiscountAmount__c == null && off.AdditionalDiscountAmount__c < 0))
										{
											// should be an invoice
											childInvoice.TotalGrossAmount__c		+= off.Total__c;
											childInvoice.TotaldiscountAmount__c		+= (off.Total__c * off.Discount__c) / 100;
											childInvoice.TotalNet__c				+= MATH.ABS(((off.AdditionalDiscountAmount__c != null) ? off.AdditionalDiscountAmount__c : 0) - 
																								((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ? off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
											childInvoice.ItemsNumber__c				+= 1;
											// checking if it is the first offer to avoid null in TechOfferIds__c
											if(childInvoice.ItemsNumber__c == 1)
											{
												childInvoice.TechOfferIds__c		= off.Id; 
											}
											else
											{
												childInvoice.TechOfferIds__c		+= '-' + off.Id; 
											}

											childInvoice.TECH_IsAdditionalDiscount__c = true;
										}
									}
								}
							}

							//AMI 26/06/18 : Community Rollout 
						    //             : Updating Owner
						    if(inv.OwnerId != null){
			                     childInvoice.OwnerId = inv.OwnerId;
			                }

							invoiceChildToBeInsertedList.add(childInvoice);
						}
					}
				}
			}
		}
		if(invoiceToBeInsertedList.size() > 0){	
			insert invoiceToBeInsertedList;
		}

		if(invoiceChildToBeInsertedList.size() > 0){	
			insert invoiceChildToBeInsertedList;
		}

		if(mapIdOfferToUpdate.size() > 0){
			update mapIdOfferToUpdate.values();
		}

		// ABT - 07-FEB-2017 - C-001620
		if(mapOrderLinesToUpdate.size() > 0)
		{
			update mapOrderLinesToUpdate.values();
		}
		
		if(SOToUpdate.size() > 0){
			update SOToUpdate;
		}

    	system.debug('##End ASPISServiceBodyShopGenerateInvoice executeProcess');
    }
}