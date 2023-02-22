/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchInvoice
  -- - Author        : ABT
  -- - Description   : Batch to process all the Paid Invoices and update the status of PO and SO
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 13-JUN-2017	ABT		1.0    	Initial version
  -- 09-FEB-2017    DUN     1.2     Case C-002137 : Issue with status on PO from Payable to Paid
  ----------------------------------------------------------------------
  Execution Code:
  Database.executeBatch(new ASPISBatchInvoice(), 200);
  **********************************************************************
*/
public class ASPISBatchInvoice implements Database.Batchable<sObject>, Schedulable, Database.Stateful
{
	private static Id distributorInvoiceId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_DISTRIBUTORINVOICE).getRecordTypeId();
    private static Id distributorCreditNoteId   = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_DISTRIBUTORCREDITNOTE).getRecordTypeId();
    private static Id bodyshopInvoiceId         = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
    private static Id bodyshopCreditNoteId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

	@TestVisible
	private Map<Id, String> mapInvoiceError = new Map<Id, String>();

	public void execute(SchedulableContext sc)
	{
		ASPISBatchInvoice batch = new ASPISBatchInvoice();
		Database.executeBatch(batch, 200);
	}

	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		System.debug('---------------------------------- START ASPISBatchInvoice - start ----------------------------------');

		String query = 	'SELECT	Id, RecordTypeId, PurchaseOrder__c, PrerequisiteOrder__c ' +
						'FROM 	Invoice__c '+
						'WHERE	Status__c = \'PAID\' ' +
						'AND	(((RecordTypeId =: distributorInvoiceId OR RecordTypeId =: distributorCreditNoteId) AND PurchaseOrder__c != null) ' +
								'OR	((RecordTypeId =: bodyshopInvoiceId OR RecordTypeId =: bodyshopCreditNoteId) AND PrerequisiteOrder__c != null)) ';

		System.debug('---------------------------------- END ASPISBatchInvoice - start ----------------------------------');
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext bc, List<Invoice__c> scope)
	{
		System.debug('---------------------------------- START ASPISBatchInvoice - execute ----------------------------------');

		Set<Id> purchaseOrderIdSet 	= new Set<Id>();
		Set<Id> salesOrderIdSet		= new Set<Id>();
		System.debug('## scope: ' + scope.size() + scope);
		for(Invoice__c currentInvoice : scope)
		{
			if(	currentInvoice.RecordTypeId == bodyshopInvoiceId ||
				currentInvoice.RecordTypeId == bodyshopCreditNoteId)
			{
				salesOrderIdSet.add(currentInvoice.PrerequisiteOrder__c);
			}
			else if(currentInvoice.RecordTypeId == distributorInvoiceId ||
					currentInvoice.RecordTypeId == distributorCreditNoteId)
			{
				purchaseOrderIdSet.add(currentInvoice.PurchaseOrder__c);
			}
		}
		

		Map<Id, PrerequisiteOrder__c> mapSalesOrderToUpdate = new Map<Id, PrerequisiteOrder__c>();
		Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate = new Map<Id, PurchaseOrder__c>();
		Map<Id, Invoice__c> mapInvoiceToUpdate = new Map<Id, Invoice__c>();

		processBodyShopInvoices(salesOrderIdSet, mapSalesOrderToUpdate, mapInvoiceToUpdate);
		processDistributorInvoices(purchaseOrderIdSet, mapPurchaseOrderToUpdate, mapInvoiceToUpdate);

		
		
		commitChanges(mapInvoiceToUpdate, mapSalesOrderToUpdate, mapPurchaseOrderToUpdate);

		System.debug('---------------------------------- END ASPISBatchInvoice - execute ----------------------------------');
	}

	public void finish(Database.BatchableContext bc)
	{
		System.debug('---------------------------------- START ASPISBatchInvoice - finish ----------------------------------');

		if(mapInvoiceError.size() > 0)
		{
			sendEmail();
		}

		System.debug('---------------------------------- END ASPISBatchInvoice - finish ----------------------------------');
	}

	/**
	 * Function to check if all the invoices of a purchase order is Paid/Closed
	 * @param  purchaseOrderIdSet The set of purchase order that needs to be checked
	 * @param  mapIdPurchaseOrder The map which will contain all the purchase orders that need to be updated
	 * @param  mapInvoiceToUpdate The map which will contain all the invoices that need to be updated
	 */
	private void processDistributorInvoices(Set<Id> purchaseOrderIdSet, Map<Id, PurchaseOrder__c> mapIdPurchaseOrder, Map<Id, Invoice__c> mapInvoiceToUpdate)
	{
		for(PurchaseOrder__c currentPurchaseOrder : [	SELECT 	Id, TECH_AssessmentCountryCode__c, TotalExpectedAmount__c,
																(SELECT Id, Status__c, ParentInvoice__c, RecordTypeId, TotalNet__c
																 FROM	Invoices__r
																 WHERE	RecordTypeId =: distributorCreditNoteId
																 OR		RecordTypeId =: distributorInvoiceId)
														FROM 	PurchaseOrder__c
														WHERE	Id IN: purchaseOrderIdSet
														AND		InvoiceStatus__c = 'VALIDATED'])
		{
			// For purchase orders' invoices, for all country check parent invoices
			if(checkPurchaseOrderInvoices(currentPurchaseOrder))
			{

				mapIdPurchaseOrder.put(currentPurchaseOrder.Id, new PurchaseOrder__c(Id = currentPurchaseOrder.Id,
																					Status__c = 'PAID'
																					));

				mapInvoiceToUpdate.putAll(setInvoiceToClosed(currentPurchaseOrder.Invoices__r));
			}
		}
	}

	 /**
	  * Function to check if all the invoices of a sales order is Paid
	  * @param  salesOrderIdSet    The set of sales order that needs to be checked
	  * @param  mapIdSalesOrder    The map which will contain all the sales orders that need to be updated
	  * @param  mapInvoiceToUpdate The map which will contain all the invoices that need to be updated
	  */
	private void processBodyShopInvoices(Set<Id> salesOrderIdSet, Map<Id, PrerequisiteOrder__c> mapIdSalesOrder, Map<Id, Invoice__c> mapInvoiceToUpdate)
	{
		for(PrerequisiteOrder__c currentSalesOrder : [	SELECT 	Id, TECH_BodyshopCountryCode__c,
		 														(SELECT Id, Status__c, ParentInvoice__c
																 FROM	Invoices__r
																 WHERE	RecordTypeId =: bodyshopCreditNoteId
																 OR		RecordTypeId =: bodyshopInvoiceId)
														FROM 	PrerequisiteOrder__c
														WHERE	Id IN: salesOrderIdSet])
		{
			if(canSalesOrderBeClosed(currentSalesOrder.TECH_BodyshopCountryCode__c, currentSalesOrder.Invoices__r))
			{
				mapIdSalesOrder.put(currentSalesOrder.Id, new PrerequisiteOrder__c(Id = currentSalesOrder.Id,
																					Status__c = 'PAID'
																					));

				mapInvoiceToUpdate.putAll(setInvoiceToClosed(currentSalesOrder.Invoices__r));

			}
		}
	}

	/**
	 * Function to check if the Sales Order can be set to paid or not
	 * @param  countryCode The country code of the object being iterated
	 * @param  invoiceList The list of invoices for a specific sales order
	 * @return             Returns whether the sales order can be set to Paid and eventually closed
	 */
	private Boolean canSalesOrderBeClosed(String countryCode, List<Invoice__c> invoiceList)
	{
		if(countryCode == 'ES')
		{
			return checkChildrenInvoices(invoiceList);
		}
		else
		{
			return checkParentInvoices(invoiceList);
		}
	}

	/**
	 * Function to check if all the parent invoices are set to PAID/CLOSED
	 * @param  invoiceList The list of invoices that needs to be checked
	 * @return             Returns true if all the parent invoices are PAID/CLOSED
	 */
	private Boolean checkParentInvoices(List<Invoice__c> invoiceList)
	{
		Boolean hasParentInvoice = false;

		for(Invoice__c currentInvoice : invoiceList)
		{
			if(currentInvoice.ParentInvoice__c ==  null)
			{
				hasParentInvoice = true;

				if(isInvoiceOpen(currentInvoice))
				{
					return false;
				}
			}
		}

		return hasParentInvoice;
	}

	/**
	 * Function to check if all the children invoices are set to PAID/CLOSED
	 * @param  invoiceList Thes list of invoices that needs to be checked
	 * @return             Returns true if all the children invoices are PAID/CLOSED
	 */
	private Boolean checkChildrenInvoices(List<Invoice__c> invoiceList)
	{
		Boolean hasChildInvoice = false;

		for(Invoice__c currentInvoice : invoiceList)
		{
			if(currentInvoice.ParentInvoice__c !=  null)
			{
				hasChildInvoice = true;

				if(isInvoiceOpen(currentInvoice))
				{
					return false;
				}
			}
		}

		return hasChildInvoice;
	}

	private Boolean checkPurchaseOrderInvoices(PurchaseOrder__c currentPurchaseOrder)
	{
		Boolean hasParentInvoice = false;

		Decimal totalNet = 0;

		for(Invoice__c currentInvoice : currentPurchaseOrder.Invoices__r)
		{
			if(currentInvoice.ParentInvoice__c == null)
			{
				hasParentInvoice = true;

				if(isInvoiceOpen(currentInvoice))
				{
					return false;
				}

				
				// 09/02/2017 DUN Case C-002137 : Commented conditions as same are already applied when PO status is set to payable 
				//if(currentInvoice.RecordTypeId == distributorInvoiceId)
				//{
				//	totalNet += currentInvoice.TotalNet__c;
				//}
				//else if(currentInvoice.RecordTypeId == distributorCreditNoteId)
				//{
				//	totalNet -= currentInvoice.TotalNet__c;
				//}
			}
		}
		system.debug('## totalNet:'+totalNet);
		system.debug('## hasParentInvoice:'+hasParentInvoice);

		// 09/02/2017 DUN Case C-002137 : Commented conditions as same are already applied when PO status is set to payable 
		if(hasParentInvoice /*&& isInMargin(currentPurchaseOrder, totalNet)*/)
		{
			return true;
		}

		return false;
	}

	private static Map<String, InvoiceMargin__c> mapInvoiceMargin;
	private void populateInvoiceMargin()
	{
		if(mapInvoiceMargin == null)
		{
			mapInvoiceMargin = InvoiceMargin__c.getAll();
		}
	}

	// 09/02/2017 DUN Case C-002137 : Commented conditions as same are already applied when PO status is set to payable 
	//private Boolean isInMargin(PurchaseOrder__c currentPurchaseOrder, Decimal totalNet)
	//{
	//	populateInvoiceMargin();

	//	if(mapInvoiceMargin.containsKey(currentPurchaseOrder.TECH_AssessmentCountryCode__c))
	//	{
	//		system.debug('## containsMargin');
	//		InvoiceMargin__c currentMargin = mapInvoiceMargin.get(currentPurchaseOrder.TECH_AssessmentCountryCode__c);

	//		Double validMargin = currentMargin.ValidationMargin__c;

	//		if((currentPurchaseOrder.TotalExpectedAmount__c >= (totalNet - validMargin)) &&
	//			(currentPurchaseOrder.TotalExpectedAmount__c <= (totalNet + validMargin)))
	//		{
	//			return true;
	//		}
	//		else
	//		{
	//			return false;
	//		}
	//	}
	//	else
	//	{
	//		system.debug('## does not contain Margin');
	//		return currentPurchaseOrder.TotalExpectedAmount__c == totalNet;
	//	}
	//}

	/**
	 * Function to check if an invoice is not closed
	 * @param  currentInvoice The current invoice that needs to be checked
	 * @return                Returns true if the invoice status is neither PAID nor CLOSED
	 */
	private Boolean isInvoiceOpen(Invoice__c currentInvoice)
	{
		return currentInvoice.Status__c != ASPISConstants.INV_STATUS_PAID && currentInvoice.Status__c != 'CLOSED';
	}

	/**
	 * Function to set the invoices to CLOSED
	 * @param  invoiceToUpdate The list of invoices that needs to be set to CLOSED
	 * @return                 Map of the updated invoices
	 */
	private Map<Id, Invoice__c> setInvoiceToClosed(List<Invoice__c> invoiceToUpdate)
	{
		Map<Id, Invoice__c> mapInvoice = new Map<Id, Invoice__c>();

		for(Invoice__c currentInvoice : invoiceToUpdate)
		{
			currentInvoice.Status__c = 'CLOSED';
			mapInvoice.put(currentInvoice.Id, currentInvoice);
		}

		return mapInvoice;
	}

	/**
	 * Function to commit all the invoices, purchase orders and sales orders that needs to be updated
	 * @param  mapInvoiceToUpdate       The map of invoices that needs to be updated
	 * @param  mapSalesOrderToUpdate    The map of sales order that needs to be updated
	 * @param  mapPurchaseOrderToUpdate The map of purchase order that needs to be updated
	 */
	private void commitChanges(Map<Id, Invoice__c> mapInvoiceToUpdate, Map<Id, PrerequisiteOrder__c> mapSalesOrderToUpdate, Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate)
	{
		List<Invoice__c> invoiceToUpdateList = mapInvoiceToUpdate.values();
		List<Database.SaveResult> invoiceResultList = Database.update(invoiceToUpdateList, false);

		for(Integer i = 0; i < invoiceResultList.size(); i++)
		{
			if(!invoiceResultList[i].isSuccess())
			{
				Invoice__c currentInvoice = invoiceToUpdateList[i];
				
				for(Database.Error currentError : invoiceResultList[i].getErrors())
				{
					mapInvoiceError.put(currentInvoice.Id, Label.Error + ' : ' + currentError.getMessage());
				}

				if(currentInvoice.PrerequisiteOrder__c != null)
				{
					mapSalesOrderToUpdate.remove(currentInvoice.PrerequisiteOrder__c);
				}

				if(currentInvoice.PurchaseOrder__c != null)
				{
					mapPurchaseOrderToUpdate.remove(currentInvoice.PurchaseOrder__c);
				}
			}
		}

		update mapSalesOrderToUpdate.values();

		update mapPurchaseOrderToUpdate.values();
	}

	/**
	 * Function to send email in case of any error
	 */
	private void sendEmail()
	{
		String errorMsg = 'Hello, <br/><br/> ' + buildEmailBody() + '<br/><br/>Regards, <br/> ASPIS Back Office Team';

		Messaging.SingleEmailMessage currentEmail = new Messaging.SingleEmailMessage();
		currentEmail.setSubject('ASPIS - ASPISBatchInvoice failed in the Organisation ' + UserInfo.getOrganizationId());
		currentEmail.setHtmlBody(errorMsg);

		List<String> emailAddressList = getMailAddresses();
		emailAddressList.add('ashwina.seetaram@sc-mauritius.com');
		emailAddressList.add('dourga.unmole@sc-mauritius.com');

		currentEmail.setToAddresses(emailAddressList);

		List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>{currentEmail};

		if(emailToSendList.size() > 0)
		{
			Messaging.sendEmail(emailToSendList);
		}
	}

	/**
	 * Function to build the body of the email according to the error map
	 * @return   The body of the email
	 */
	private String buildEmailBody()
	{
		String errorTable = 'The processing of the following invoices has failed : <br/><br/>' +
							'<table border="1">' +
							'<tbody>' + 
							'<tr>' + 
							'<td><b>Invoice Id</b></td>' + 
							'<td><b>Error Message:</b></td>' + 
							'</tr>';
		
		if(mapInvoiceError.size() > 0)
		{
			for(Id invoiceId : mapInvoiceError.keySet())
			{
				errorTable += 	'<tr><td>' + invoiceId + '</td>' + 
								'<td>' + mapInvoiceError.get(invoiceId) + '</td></tr>';
			}
		}

		errorTable += '</tbody></table>';

		return errorTable;
	}

	/**
	 * Function to retrieve the email addresses of the users in the group SystemAdmins
	 * @return   List of email addresses that needs to receive the email being sent
	 */
	private List<String> getMailAddresses()
	{
        List<String> mailList = new List<String>();

        for (GroupMember gm : [ SELECT UserOrGroupId
								FROM GroupMember
								WHERE Group.DeveloperName = 'SystemAdmins'])
		{
            mailList.add(gm.UserOrGroupId);
        }

        List<String> mailAddresses  = new List<String>();

        if(mailList.size() > 0)
		{
            for(User usr :[ SELECT Email
							FROM User
							WHERE Id IN : mailList])
			{
                mailAddresses.add(usr.Email);
            }
        }

		return mailAddresses;
    }
}