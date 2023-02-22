/*
----------------------------------------------------------------------
-- - Name          : InvoicingLineCreation
-- - Author        : DUN
-- - Description   : Controller for InvoicingLineCreation
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 12-DEC-2017  DUN     1.0         Initial version (case 2001)
-- 12-FEB-2019  WCH     1.1         C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
-- 03-Nov-2021  NPE     1.2         C-004532 - Spanish Bodyshop Invoices and Credit Notes created via the Invoicing Adjustment button are not being assigned to a PO
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class InvoicingLineCreation{

	public Offer__c newOffer{get;set;}
	public Invoice__c newInvoice{get;set;}
	public Prerequisiteorder__c salesOrder{get;set;}
    public Boolean redirectionInErrorModal {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public list<Account> listPaymentAccount {get;set;}
    public string BSCreditNote {get;set;}
    public string BSInvoice {get;set;}    
    public Decimal totalInvoicesAmount{get;set;}
    //WCH 12/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
    public Set<Id> allOffersInSO {get;set;}
	//NPE C-004532 - Spanish Invoices and Credit Notes created via the Invoicing Adjustment button are not being assigned to a PO
	public PurchaseOrder__c purchaseOrder{get;set;}

	public InvoicingLineCreation(){
		system.debug('#### Start InvoicingLineCreation');   

        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false; 
        Decimal totalInvoice = 0;
        Decimal totalCreditNote = 0;
        totalInvoicesAmount = 0;
        BSCreditNote = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId();
		BSInvoice = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
		allOffersInSO=new Set<Id>();//WCH 12/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note

		String salesOrderId = ApexPages.currentPage().getParameters().get('Id');

		salesOrder = [select Id, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c, Status__c,
					  		(Select Id, TotalNet__c, RecordTypeID
					  		 from Invoices__r
					  		 where (RecordTypeID =: BSCreditNote
					  		 or RecordTypeID =: BSInvoice)
					  		 and PurchaseOrder__c = null)  
					  		 ,(select Id from Offers__r) //WCH 12/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
					  from Prerequisiteorder__c 
					  where Id =: salesOrderId];
		
		//NPE C-004532 - Spanish Invoices and Credit Notes created via the Invoicing Adjustment button are not being assigned to a PO
		purchaseOrder = [select Id, Name from PurchaseOrder__c where PrerequisiteOrder__c =:salesOrderId LIMIT 1];

		if(salesOrder != null){
			listPaymentAccount = [Select Id, Name, ShippingCountryCode 
							  from Account 
							  where RecordTypeID =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(ASPISConstants.ACCOUNT_RT_LABEL_PAYMENT).getRecordTypeId()
							  and ShippingCountryCode =: salesOrder.TECH_BodyshopCountryCode__c
							  limit 1];

			if(salesOrder.Invoices__r.size() > 0){
				for(Invoice__c inv : salesOrder.Invoices__r){
	                if(inv.RecordTypeId == BSInvoice){
	                    totalInvoice += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
	                }else if(inv.RecordTypeId == BSCreditNote){
	                    totalCreditNote += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
	                }
	            }
	            totalInvoicesAmount = totalInvoice - totalCreditNote;
	        }

	        //WCH 12/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
	        if(salesOrder.Offers__r.size() > 0){
				for(Offer__c theOffer : salesOrder.Offers__r){
					allOffersInSO.add(theOffer.Id);
	            }
	        }

			newOffer = new Offer__c(PrerequisiteOrder__c = salesOrder.Id,
									 Suppliable__c = TRUE, 
									 OfferReference__c = String.ValueOf(System.now())+String.ValueOf(math.random()) ,
									 Type__c= 'Invoicing',
									 Accepted__c = 'YES',
									 DeliveryStatus__c = 'DELIVERED');  

			newInvoice = new Invoice__c(Assessment__c = salesOrder.Assessment__c,
										BodyShop__c = salesOrder.BodyShop__c,
										Status__c = 'SENT',
										Prerequisiteorder__c = salesOrder.Id,
										PaymentTo__c = (listPaymentAccount.size() > 0 ? listPaymentAccount[0].Id : null),     
										IsBodyShop__c = true,
										PaymentTerms__c = salesOrder.PaymentTerms__c
										, TechOfferIds__c = String.join((Iterable<String>)allOffersInSO , '-') //WCH 12/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
										);
		}
		else{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'ERROR'));
		}   

		system.debug('#### End InvoicingLineCreation');
	}

	public list<SelectOption> getRecordTypes(){
		system.debug('#### Start getRecordTypes');
	    list<SelectOption> options = new list<SelectOption>();

	    for(RecordType sRecordType : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Invoice__c']){
	        if(sRecordType.Name == 'BodyShop Credit Note'){
	        	options.add(new SelectOption(sRecordType.Id, 'Credit Note'));
	        }
	        else if(sRecordType.Name == 'BodyShop Invoice'){
	        	options.add(new SelectOption(sRecordType.Id, 'Invoice'));
	        }
	    }
		system.debug('#### End getRecordTypes');
	    return options;
	}

	public PageReference createInvAndOffer(){
		system.debug('#### Start createInvAndOffer');

		if(newInvoice != null){

			newInvoice.TotalGrossAmount__c = newOffer.AdjustmentAmount__c;
			newInvoice.TotalNet__c = newOffer.AdjustmentAmount__c;
			newInvoice.ItemsNumber__c = 1;
			newInvoice.TotalPieces__c = 1;
			newInvoice.TECH_InvoiceParent__c  = String.ValueOf(System.now())+String.ValueOf(math.random());

			insert newInvoice;

			if(CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c) != null &&
				CountryCodeInformationsMapping__c.getInstance(salesOrder.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c){

				Invoice__c childInvoice = newInvoice.clone(false, true);
				childInvoice.ParentInvoice__c = newInvoice.Id;
                childInvoice.TECH_Number__c = null;//RLA 15/06/2018 case 2617 - Duplicate TechNumber
				childInvoice.TECH_InvoiceParent__c  = String.ValueOf(System.now())+String.ValueOf(math.random());

				//NPE C-004532 - Spanish Invoices and Credit Notes created via the Invoicing Adjustment button are not being assigned to a PO
				if (purchaseOrder != null && salesOrder.TECH_BodyshopCountryCode__c == 'ES'){
					childInvoice.PurchaseOrder__c= purchaseOrder.Id;
				}

				insert childInvoice;
				
				if(childInvoice.RecordTypeID == BSInvoice){
					newOffer.Invoice__c = childInvoice.Id;  
				}
				else{
					newOffer.CreditNote__c = childInvoice.Id;
				}
			}
			else{
				if(newInvoice.RecordTypeID == BSInvoice){
					newOffer.Invoice__c = newInvoice.Id;  
				}
				else{
					newOffer.CreditNote__c = newInvoice.Id;
				} 
			}

			insert newOffer;  

			//WCH 14/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
			newInvoice.TechOfferIds__c+=('-'+newOffer.Id);
			update newInvoice;

			return new PageReference('/'+newInvoice.Id);
		}
		else{
			return null;        
		}    
	}

    /**      
     * Method to redirect model
     * @return null
     */
    public PageReference redirectPage(){
        redirectionInErrorModal = true;

        return null;
    }  
}