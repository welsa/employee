/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUsPDF
-- - Author        : ABT
-- - Description   : Controller for ASPISJoinUsPDF
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 04-JAN-2016	ABT		1.0			Initial version
-- 24-AUG-2020	WCH		1.1			C-003838 - Nob - Migrate Billing information to new fields
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISJoinUsPDF 
{
	public Account currentAccount {get; set;}
	public Contact currentContact {get; set;}
	public String language {get; set;}
	public String sepaCreditorIdentifier {get; set;}

	public ASPISJoinUsPDF() 
	{
		language 			= String.isBlank(ApexPages.currentPage().getParameters().get('lang')) ? 'en_US' : ApexPages.currentPage().getParameters().get('lang');
		String accountId 	= ApexPages.currentPage().getParameters().get('AccountId');
		String contactId 	= ApexPages.currentPage().getParameters().get('ContactId');

		String country		= String.isBlank(ApexPages.currentPage().getParameters().get('country')) ? 'FR' : ApexPages.currentPage().getParameters().get('country').toUpperCase();
		
		// Getting the country default VAT__c from the custom setting
        CountryCodeInformationsMapping__c currentCountryInfo    = CountryCodeInformationsMapping__c.getInstance(country);
        currentCountryInfo                                      = (currentCountryInfo != null) ? currentCountryInfo : CountryCodeInformationsMapping__c.getInstance('DEFAULT');

		sepaCreditorIdentifier = (currentCountryInfo != null) ? currentCountryInfo.SEPACreditorIdentifier__c : '';

		// To load page as a download file
		String fileName = 'AlphaScale_Register_' + System.now().format('dd_MM_YYYY_HH_mm_ss') + '.pdf';
		ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);

		currentAccount		= new Account();
		currentContact		= new Contact();

		if(accountId != null && contactId != null)
		{
			//WCH 24/08/2020 C-003838
			currentAccount = [	SELECT 	Id, Name, BillingStreet__c, BillingCity__c, BillingState__c, BillingPostalCode__c, BillingCountry__c, 
										ShippingStreet, ShippingPostalCode, ShippingCity,
										Phone, Fax, LocalReferenceNumber__c, VATNumber__c, ContactEmail__c
								FROM	Account
								WHERE	Id =: accountId];

			currentContact = [	SELECT	Id, Salutation, LastName, FirstName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
										Phone, Fax, MobilePhone, OtherPhone
								FROM	Contact
								WHERE	Id =: contactId];

		}
	}
}