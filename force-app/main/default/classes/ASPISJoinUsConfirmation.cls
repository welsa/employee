/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUsConfirmation
-- - Author        : ABT
-- - Description   : Controller for ASPISJoinUsConfirmation
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 24-JAN-2017	ABT		1.0			Initial version
-- 30-MAR-2018  VSU     1.1         C-002315 Cross Scripting
----------------------------------------------------------------------
**********************************************************************
*/
global class ASPISJoinUsConfirmation
{
	global String language {get; set;}
	global String country {get; set;}
	global Boolean isValidLink {get; set;}
	private String accountId;
	private String contactId;
	public Boolean hasErrors {get; set;}
	public static Boolean isToastError {get; set;}

	global ASPISJoinUsConfirmation()
	{
		isValidLink 				= false;
		language 					= String.isBlank(ApexPages.currentPage().getParameters().get('lang')) ? 'en' : ApexPages.currentPage().getParameters().get('lang');
		// Getting the country (Can be override by assessment)
		country						= String.isBlank(ApexPages.currentPage().getParameters().get('country')) ? 'FR' : ApexPages.currentPage().getParameters().get('country').toUpperCase();
		hasErrors = false;
        isToastError = false;

		String encryptedAccountId 	= ApexPages.currentPage().getParameters().get('AccountId');
		String encryptedContactId 	= ApexPages.currentPage().getParameters().get('ContactId');

		//VSU 28/03/2018 C-002315 

		try
		{
			if(!String.isBlank(encryptedAccountId) && !String.isBlank(encryptedContactId))
			{
				accountId = decryptBase64Text(encryptedAccountId);
				contactId = decryptBase64Text(encryptedContactId);
				
				//VSU 30/03/18 C-002315
				Id anAccId = accountId;
				Id aConId = contactId;

				isValidLink = true;
				system.debug('##in if');
						
			}
		}
		catch(Exception e){
			hasErrors = true;
            isToastError = true;
		}
	}

	global PageReference downloadPDF()
	{
		PageReference downloadPage 	= Page.ASPISJoinUsPDF;


		if(!String.isBlank(accountId) && !String.isBlank(contactId))
		{
			downloadPage.getParameters().put('AccountId', accountId);
			downloadPage.getParameters().put('ContactId', contactId);
		}

		downloadPage.getParameters().put('lang', language);
		downloadPage.getParameters().put('country', country);
		downloadPage.setRedirect(false);
		
		return downloadPage;

	}

	global String decryptBase64Text(String encryptedText)
	{
		Blob decryptedData 		= EncodingUtil.base64Decode(encryptedText);
		String decryptedText 	= decryptedData.toString();

		return decryptedText;
	}
}