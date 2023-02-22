/*
----------------------------------------------------------------------
-- - Name          : ASPISWelcomeDetect
-- - Author        : ABT
-- - Description   : Controller for ASPISWelcomeDetect
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 19-DEC-2016	ABT		1.0    Initial version  
-- 27-FEB-2018  DUN     1.1    C-002186 - Bypass the orderchooseAssessment screen        
-- 14-MAR-2018  DUN     1.2    C-002339 - Put a link in order confirmation email with delivery note redirecting to ASPISSalesOrder         
-- 03-APR-2018  VSU     1.3    C-002315 - Cross Scripting
-- 10-APR-2018  DUN     1.4    C-002417 - Enlever la redirection sur la page d'inscription en français  
-- 23-NOV-2018  AMI     1.5    C-002931 : Germany R4 : Language FR instead of DE on ASPIS login page
-- 06-DEC-2018  AMI     1.6    C-002781 : Migrate Spain to R4
--                              	    : Adding ES In Default Browser Language
-- 21-DEC-2018  AMI     1.7    C-002989 : Updating language algorithm in the event we have a , in the param
----------------------------------------------------------------------
**********************************************************************
*/
global class ASPISWelcomeDetect 
{
	global String encryptedText {get; set;}
	global String encryptedChildIdText {get; set;}
	global String language {get; set;}
	global Boolean isConnected {get; set;}
	global Boolean isUsingDomain {get; set;}
	global Boolean isValidLink {get; set;}
	global String currentInstance {get; set;}
	public Assessment__c currentAssessment;
	public Boolean hasErrors {get; set;}
  	public Boolean isToastError {get; set;}

	//DUN 27/02/2018  C-002186 - Bypass the orderchooseAssessment screen
	global String order {get; set;}

	//DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
	global String encryptedSOId{get;set;}
	global PrerequisiteOrder__c currentSalesOrder{get;set;}
	//RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
	global String flag {get;set;}

	global ASPISWelcomeDetect() 
	{
		isConnected 			= false;
		isUsingDomain			= false;
		isValidLink 			= true;
		encryptedText			= ApexPages.currentPage().getParameters().get('AssessmentId');
		encryptedChildIdText	= ApexPages.currentPage().getParameters().get('ChildId');
		//RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
		if(ApexPages.currentPage().getParameters().get('flag') != null){  
				flag = ApexPages.currentPage().getParameters().get('flag'); 
		}
		//DUN 14/03/2018 C-002339  - Redirect to  ASPISSalesOrder
		encryptedSOId       	= ApexPages.currentPage().getParameters().get('Id');
		// language		= String.isBlank(ApexPages.currentPage().getParameters().get('lang')) ? 'en_US' : ApexPages.currentPage().getParameters().get('lang');
		hasErrors      = false;
    	isToastError    = false;
		String acceptLanguage 	= ApexPages.currentPage().getHeaders().get('Accept-Language');
		system.debug('## acceptLanguage ' + acceptLanguage);

		String browserPreferedLanguage = 'fr';
		
        //AMI 23/11/18 - C-002931 : Germany R4 : Language FR instead of DE on ASPIS login page
        //                        : Retrieving only first 5 characters received on browser Accept-Language
        if(String.isNotBlank(acceptLanguage)){
            browserPreferedLanguage = acceptLanguage.LEFT(5);
        }

		if(ApexPages.currentPage().getParameters().get('Order') != null){
			order = ApexPages.currentPage().getParameters().get('Order');
		}

		//AMI 06/12/18 - C-002781 : Migrate Spain to R4
		//                   	  : Adding ES In Default Browser Language
		// Getting the language
		language				= !String.isBlank(ApexPages.currentPage().getParameters().get('lang'))
								  ? ApexPages.currentPage().getParameters().get('lang')/*.toLowerCase()*/ : browserPreferedLanguage;

		//AMI 21/12/2018 : C-002989 - Updating language algorithm in the event we have a , in the param
        if(language.contains(',')){
            language = language.substringBefore(',');
        }
        
		language = language.tolowercase().replaceAll('-','_');
        if(language.startsWith('fr_') && language <> 'fr_BE')
            language = 'fr';
        else if(language=='nl')
            language = 'nl_be';
        else if(language.startsWith('de'))
            language = 'de';
        else if(language.startsWith('it'))
            language = 'it';  
        else if(language.startsWith('es'))
            language = 'es';      
        if(! 'fr_it_de_nl_es'.contains(language.substring(0,2)))
            language = 'fr';

		system.debug('##lang: '+ApexPages.currentPage().getParameters().get('lang'));
		
		// Querying in order to obtain the correct instance of the env
		Organization currentOrg = [	SELECT 	InstanceName 
									FROM 	Organization];

		currentInstance = currentOrg.InstanceName;

		Boolean isEncryptedTextBlank = String.isBlank(encryptedText);
		//DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
		Boolean isEncryptedSOBlank = String.isBlank(encryptedSOId);

		try
		{
			if(encryptedChildIdText != null){
				Id TestForId = decryptBase64(encryptedChildIdText);
			}
			if(encryptedText != null){
				String assessmentId = decryptBase64(encryptedText);
				//VSU 02/04/18 C-002315
				Id anId = assessmentId;

				currentAssessment = [	SELECT 	Id, BodyShop__c, BodyShop__r.Type, BodyShop__r.isEligible__c
											FROM	Assessment__c
											WHERE 	Id =: assessmentId];
			}
		}
		catch(Exception e)
		{
			if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
				hasErrors = true;
		        isToastError = true;
		        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
		    }
			system.debug('## Exception' + e.getMessage());
		}

		//DUN 14/03/2018 C-002339 - Redirect to  ASPISSalesOrder
		try
		{
			if(encryptedSOId != null){
				String salesOrderId =decryptBase64(encryptedSOId);
				Id anId = salesOrderId;
				//VSU 02/04/18 C-002315 
				currentSalesOrder = [	SELECT 	Id
										FROM	PrerequisiteOrder__c
										WHERE 	Id =: salesOrderId];
			}
		}
		catch(Exception e)
		{
			if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
				hasErrors = true;
		        isToastError = true;
		        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
		    }
			system.debug('## Exception' + e.getMessage());
		}

		System.debug('## currentAssessment ' + currentAssessment);
		System.debug('## currentSalesOrder ' + currentSalesOrder);
		System.debug('## isEncryptedTextBlank ' + isEncryptedTextBlank);
		// checking if there is an assessment of that id
		//DUN 14/03/2018 C-002339 - Added currentSalesOrder == null && !isEncryptedSOBlank
		if((currentAssessment == null && !isEncryptedTextBlank) || (currentSalesOrder == null && !isEncryptedSOBlank))
		{
			isValidLink = false;
			// stops the execution
			return;
		}
	}

	global String decryptBase64(String encryptedText)
	{
		Blob decryptedData 		= EncodingUtil.base64Decode(encryptedText);
		String decryptedText 	= decryptedData.toString();
		System.debug('Decrypted Text ' + decryptedText);

		return decryptedText;
	}

	global PageReference redirectPage()
	{
		PageReference pageRef;
		//DUN 14/03/2018 C-002339 Added && String.isBlank(encryptedSOId)
		if(String.isBlank(encryptedChildIdText) && String.isBlank(encryptedSOId))
		{
			if(currentAssessment != null)
			{
				// checking if the bodyshop of the assessment is active
				if(	currentAssessment.BodyShop__c != null 
					// commented as it is useless
					/*&& 
					(
						currentAssessment.BodyShop__r.isEligible__c ||
						!currentAssessment.BodyShop__r.isEligible__c ||
						currentAssessment.BodyShop__r.Type == 'Expert'
					)*/
				)
				{
					// bodyshop is not null and is eligible or is expert
					if(!isConnected)
					{
						// redirects to ASPISConnect
						pageRef = Page.ASPISConnect;
					}
					else
					{
						if(isUsingDomain)
						{
							pageRef = new PageReference(Label.AlphaScaleDomain + '/apex/OrderChooseAssessment');
						}
						else
						{
							pageRef = new PageReference('https://' + currentInstance + '.salesforce.com/apex/OrderChooseAssessment');
						}
					}
				}
				else
				{
					// redirects to ASPISJoinUs
					
					//10-APR-2018  DUN     1.4    C-002417 - Enlever la redirection sur la page d'inscription en français  
					//19-APR-2018  DUN     1.4    AXE : laisser que la france pour la redirection
                   if(language == 'fr'){
                       pageRef = Page.ASPISJoinUs;
                   }
                   else{
                       pageRef = Page.ASPISConnect;
                   }
				}

				setParameters(pageRef);
			}
			else
			{
				if(!isConnected)
				{
					// redirects to ASPISConnect
					pageRef = Page.ASPISConnect;
				}
				else
				{
					if(isUsingDomain)
					{
						pageRef = new PageReference(Label.AlphaScaleDomain + '/apex/Search');
					}
					else
					{
						pageRef = new PageReference('https://' + currentInstance + '.salesforce.com/apex/Search');
					}
				}
			}
		}
		//DUN 14/03/2018 C-002339 Added else if part
		else if(!String.isBlank(encryptedSOId)){
			if(!isConnected)
			{
				pageRef = Page.ASPISConnect;
			}
			else
			{
				if(isUsingDomain)
				{
					pageRef = new PageReference(Label.AlphaScaleDomain + '/apex/ASPISSalesOrder');
				}
				else
				{
					pageRef = new PageReference('https://' + currentInstance + '.salesforce.com/apex/ASPISSalesOrder');
				}
			}
			pageRef.getParameters().put('Id', encryptedSOId);
			pageRef.getParameters().put('lang', language);
			//RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
			if (String.isNotBlank(flag)){
				pageRef.getParameters().put('flag', flag);
			}
		}
		else
		{
			if(!isConnected)
			{
				pageRef = Page.ASPISConnect;
			}
			else
			{
				if(isUsingDomain)
				{
					pageRef = new PageReference(Label.AlphaScaleDomain + '/apex/OrderMakeSelection');
				}
				else
				{
					pageRef = new PageReference('https://' + currentInstance + '.salesforce.com/apex/OrderMakeSelection');
				}
			}

			setParametersFromEmail(pageRef, isConnected);
		}

		
		pageRef.setRedirect(true);
		return pageRef;
	}

	public void setParameters(PageReference currentPageRef)
	{
		currentPageRef.getParameters().put('AssessmentId', encryptedText);
		currentPageRef.getParameters().put('lang', language);
		//RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
		if (String.isNotBlank(flag)){
			currentPageRef.getParameters().put('flag', flag);
		}

		//DUN 27/02/2018  C-002186 - Bypass the orderchooseAssessment screen
		if(order != null){
			currentPageRef.getParameters().put('Order', order);
		}
	}

	public void setParametersFromEmail(PageReference currentPageRef, Boolean isUserConnected)
	{
		if(!isUserConnected)
		{
			currentPageRef.getParameters().put('AssessmentId', encryptedText);
		}
		else
		{
			currentPageRef.getParameters().put('Id', encryptedText);
		}
		
		currentPageRef.getParameters().put('ChildId', encryptedChildIdText);
		currentPageRef.getParameters().put('lang', language);
	}
}