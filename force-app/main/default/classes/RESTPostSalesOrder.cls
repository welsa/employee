/*
----------------------------------------------------------------------
-- - Name          : RESTPostSalesOrder
-- - Author        : ABT
-- - Description   :
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 27-JAN-2017	ABT		1.0			Initial version
-- 04-APR-2017	ASE		1.1			Filtering assessments of type Claim Order and NewAssessment
-- 13-JUN-2017	ASE		1.2			C-001936 : add long text field on Assessment and SalesOrder to store the result of the call web services
-- 13-JUN-2017  VSU     1.3         C-001936 : add method to update field WSResult and WSStatus on SalesOrder
-- 04-OCT-2017  AMI     1.4         C-002019 : PostSalesOrders set status on SO
-- 06-OCT-2017  AMI     1.5         C-002027 : POSTSalesOrder / POSTAssessment Defects
-- 13-NOV-2017  AMI     1.6         Returning result string when no error has been reported during ice call out
									(Correcting attempt to dereference a null object issue since result was null)
-- 11-JAN-2018  AMI     1.7         Changing class modifier to "Without Sharing" since certain users were not able to launch the callout
-- 26-FEB-2018  AMI     1.8         Bulkifying Update On SO
-- 30-JUL-2020  WCH     1.9         C-003886 - RESTPostSalesOrder error
-- 07-JAN-2021  WCH     2.0         C-003915 - arreter les flux RestPostAssessment et RestPostSalesOrder
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class RESTPostSalesOrder
{
	@future(callout = true)
	public static void buildJSONAsync(Set<Id> salesOrderIdSet)
	{
		buildJSON(salesOrderIdSet,false);
	}

	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : this map will be used to get SOId to update since response provide so name only
	public static map <string,string> mapSoNameSoId = new map <string,string>();

	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : this map will be used to get error message in case SO failed to integrate
	public static map <string,string> mapSoNameErrorMessage = new map <string,string>();

	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : adding launch button boolean so that in case class is called from button, 
	//			   : return an error message (boolean + error message + so name) else there is a boolean return
	public static RESTPostAssessment.callOutStatus buildJSON(Set<Id> salesOrderIdSet,boolean launchButton)
	{
		System.debug('## START RESTPostSalesOrder.buildJSON');

		//AMI 04/10/17 :  set status on SO (initialise wrapper)
		RESTPostAssessment.callOutStatus callOutWrap = new RESTPostAssessment.callOutStatus();
		
		Set<String> igEntitySet = String.isNotBlank(Label.ASFRIGEntity) ? new Set<String>(Label.ASFRIGEntity.split(';')) : new Set<String>();

		list <PrerequisiteOrder__c> salesOrderList = new list <PrerequisiteOrder__c>();

		//AMI 26/02/18 : Bulkifying Update On SO
	    //			   : build mapSoNameSoId
	    //AMI 06/10/17 : C-002027 (AssessmentID is mandatory if the field is empty send Assessment Number )
		for(PrerequisiteOrder__c so : [SELECT Id, Name, BodyShop__c, BodyshopOrderNumber__c, PlateNumber__c, Status__c, OfferType__c, MaximumValidityDate__c, Assessment__c,
												Assessment__r.AssessmentID__c, Assessment__r.Entity__c, Assessment__r.MissionNumber__c, Assessment__r.RecordType.DeveloperName,
												Assessment__r.ParentAssessment__r.AssessmentID__c, Assessment__r.ParentAssessment__r.Entity__c, Assessment__r.ParentAssessment__r.MissionNumber__c, 
												Assessment__r.ParentAssessment__r.RecordType.DeveloperName,Assessment__r.AssessmentNumber__c,
												(SELECT	Id, Type__c, ParentOffer__c, Name, VAT__c, OriginalType__c, FinalType__c, OriginalDescription__c,
														Description__c, OriginalPartNumber__c, PartNUmber__c, OriginalManufacturer__c, Manufacturer__c,
														Quantity__c, CataloguePrice__c, Total__c, ExpectedDeliveryDate__c, Discount__c, Price__c, BSTotalPrice__c, OrderLine__r.Suppliable__c,
														Accepted__c, DeliveryStatus__c, RealDeliveryDate__c, Comment__c
												FROM	Offers__r)
										 FROM	PrerequisiteOrder__c
										 WHERE	Id IN: salesOrderIdSet
										 AND	BodyShop__r.AXAPartner__c	= true
										 AND	TECH_AssessmentEntityRules__c IN: igEntitySet
										 AND	(
													(
														//Assessment__r.ParentAssessment__r.isShoppingList__c 		= false
										 				//AND	Assessment__r.RecordType.DeveloperName 	= 'ClaimOrder'
										 				Assessment__r.RecordType.DeveloperName 	= 'ClaimOrder'
													) 
													OR
													(
														Assessment__r.RecordType.DeveloperName  = 'NewAssessment'
													)
										 		)]){
			salesOrderList.add(so);

			mapSoNameSoId.put(so.Name,so.Id);
		}
		system.debug('## salesOrderList ' + salesOrderList);
		system.debug('## mapSoNameSoId ' + mapSoNameSoId);

		if(salesOrderList.size() > 0)
		{		
			PostSalesOrdersOffersInformation wrapper = new PostSalesOrdersOffersInformation(salesOrderList);

			//AMI 26/02/18 : Bulkifying Update On SO
	        //			   : removing salesorder id as param so that bulk update can be done
	        //AMI 26/02/18 : Bulkifying Update On SO
			//			   : adding launch button boolean so that in case class is called from button, 
			//			   : return an error message (boolean + error message + so name) else there is a boolean return
			//AMI 04/10/17 : set status on SO (build wrapper)
			callOutWrap = sendRequest(JSON.serialize(wrapper),launchButton);		
		}else{
			callOutWrap.isSuccessful = false;
			callOutWrap.statusMessage = system.label.SOWSAdminMessage;
		}

		return callOutWrap;
	}

	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : removing salesorder id as param so that bulk update can be done
	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : adding launch button boolean so that in case class is called from button, 
	//			   : return an error message (boolean + error message + so name) else there is a boolean return
	public static RESTPostAssessment.callOutStatus sendRequest(String requestBody,boolean launchButton)
	{
		//AMI 04/10/17 :  set status on SO (initialise wrapper)
		RESTPostAssessment.callOutStatus callOutWrap = new RESTPostAssessment.callOutStatus();

		// Building Request
		HTTPRequest request = new HTTPRequest();
		request.setEndpoint('callout:FR_ICE/PostSalesOrdersOffersInformation');
		request.setHeader('Content-Type','application/json; charset=UTF-8');
		request.setHeader('Accept','application/json');
		request.setBody(requestBody);
		request.setMethod('POST');
		request.setTimeout(120000);
 
		// Variables needed
		String responseBody = '';
		Boolean isSuccessful = true;

		//AMI 04/10/17 :  set status on SO (capturing result)
		string result = '';
		//WCH 07/01/2021 C-003915
		List<ConfigurationFlux__mdt> getProperRESTPostSalesOrderConfigs = [select id,Runnable__c from ConfigurationFlux__mdt where DeveloperName='RESTPostSalesOrder'];

		if((getProperRESTPostSalesOrderConfigs.size()>0 && getProperRESTPostSalesOrderConfigs[0].Runnable__c) || Test.isRunningTest()){
			// Sending request
			HTTP httpCall = new HTTP();

			try{
				HTTPResponse response	= httpCall.send(request);
				System.debug('## request: ' + request);
				System.debug('## response: ' + response);
				
				responseBody = response.getBody();
				System.debug('## body: ' + responseBody);

				//AMI 26/02/18 : Bulkifying Update On SO
				//			   : adding launch button boolean so that in case class is called from button, 
				//			   : return an error message (boolean + error message + so name) else there is a boolean return
				result = launchButton == true ? processResponse(responseBody,true) : processResponse(responseBody,false);
				system.debug('## result ' + result);

				if(launchButton){
					if(result.split(';')[0] == 'true'){
						isSuccessful  = true;
					}else{
						isSuccessful = false;
					}
				}else{
					isSuccessful = boolean.valueOf(result);
				}
			}
			catch(Exception e)
			{
				system.debug('## exception e ' + e);
				responseBody = 'Error Message:'+e.getMessage()+'\n'+e.getStackTraceString();//WCH 30/07/2020 C-003886
				isSuccessful = false;
			}

			// Creating the log
			//AMI 04/10/17 : set status on SO (passing new parameters)
			createLog(requestBody, responseBody, isSuccessful, 'ICE', 'RESTPostSalesOrder', 'PrerequisiteOrder__c');
		}

		callOutWrap.isSuccessful = isSuccessful;

		if(launchButton){
			callOutWrap.statusMessage = result.split(';')[0] != 'true' ? result.split(';')[1] : '';
		}
		
		system.debug('## callOutWrap ' + callOutWrap);
		return callOutWrap;
	}

	//AMI 26/02/18 : Bulkifying Update On SO
	//			   : adding launch button boolean so that in case class is called from button, 
	//			   : return an error message (boolean + error message + so name) else there is a boolean return
	//AMI 04/10/17 : set status on SO (changing return value so that error can be captured) and reworked
	public static string processResponse(String response,boolean launchButton){

		JSONResult responseWrapper = (JSONResult) JSON.deserialize(response, JSONResult.class);

		String resultString = '';
		Boolean isSuccess = true;
		
		system.debug('## responseWrapper ' + responseWrapper);
		if(responseWrapper != null && responseWrapper.Result != null){
			//C-001936 : ASE 13/06/17
			// loop in the list of SalesOrderResponse
			for(SalesOrderResponse currentSalesOrderResponse : responseWrapper.Result){
				if(!currentSalesOrderResponse.Success){
					resultString = false + ';' + currentSalesOrderResponse.errorMessage;
					isSuccess = false;

					//AMI 26/02/18 : Bulkifying Update On SO
					//			   : build mapSoNameErrorMessage
				    mapSoNameErrorMessage.put(currentSalesOrderResponse.SaleOrderId,currentSalesOrderResponse.errorMessage);
				}
			}
		}
		else{
			resultString = false + ';' + 'Response is null';
			isSuccess = false;
		}

		if(string.isBlank(resultString)){
			resultString = true + ';';
			isSuccess = true;
		}

		//AMI 26/02/18 : Bulkifying Update On SO
		//			   : return message if and and only if class is called from button
		if(launchButton){
			return resultString;
		}else{
			return string.valueOf(isSuccess);
		}

		return '';	
	}    
	
	//AMI 04/10/17 : set status on SO (passing new parameters)
	public static void createLog(
		String request, 
		String response, 
		Boolean isSuccessful, 
		String systemCalling, 
		String classUsed, 
		String obj){

		//AMI 04/10/17 : set status on SO
		//list use to update SO in case of error during callout
		list <PrerequisiteOrder__c> soToUpdate = new list <PrerequisiteOrder__c> ();
	
		Log__c currentLog = new Log__c(	DateLog__c 	= System.now(),
										Class__c	= classUsed,
										sObject__c  = obj,
										Status__c	= (isSuccessful) ? 'Passed' : 'Failed',
										SystemCalling__c = systemCalling);
		

		// Check if the length of the request is less or equal to 32768 -> add request in JSONMessage__c
		if(request.length() <= 32768)
		{
			currentLog.JSONMessage__c = request;
		}

		// Check if the length of the response is less or equal to 32768 -> add request in JSONResponse__c
		if(response.length() <= 32768)
		{
			currentLog.JSONResponse__c = response;
		}

		// insert the log
		system.debug('## currentLog ' + currentLog);
		insert currentLog;

		// In case the request was too big create an attachment for it
		system.debug('## request.length() ' + request.length());
		system.debug('## request ' + request);
		if(request.length() > 32768)
		{
			APCreateAttachments.createAttachment('Request', request, currentLog);
		}

		// In case the response was too big create an attachment for it
		system.debug('## response.length() ' + response.length());
		system.debug('## response ' + response);
		if(response.length() > 32768)
		{
			APCreateAttachments.createAttachment('Response', response, currentLog);
		}

		//AMI 26/02/18 : Bulkifying Update On SO
		//			   : update each SO send based on return status
		//mapSoNameSoId
		for(string soName : mapSoNameSoId.keySet()){
			//error message generated
			if(mapSoNameErrorMessage.containsKey(soName)){
				soToUpdate.add(new PrerequisiteOrder__c(id = mapSoNameSoId.get(soName),
														WSResult__c = mapSoNameErrorMessage.get(soName),
														WSStatus__c = 'ICE SO - KO'));
			}else{
				soToUpdate.add(new PrerequisiteOrder__c(id = mapSoNameSoId.get(soName),
														WSResult__c = '',
														WSStatus__c = 'ICE SO - OK'));
			}
		}

		system.debug('## soToUpdate ' + soToUpdate);
		if(!soToUpdate.isEmpty()){
			update soToUpdate;
		}
	}

	public class PostSalesOrdersOffersInformation
	{
		public CredentialsDTO Credentials;
		public List<SalesOrderDTO> ListSalesOrders;

		public PostSalesOrdersOffersInformation(List<PrerequisiteOrder__c> salesOrderList)
		{
			Credentials 	= new CredentialsDTO();
			ListSalesOrders = new List<SalesOrderDTO>();

			for(PrerequisiteOrder__c currentSalesOrder: salesOrderList)
			{
				ListSalesOrders.add(new SalesOrderDTO(currentSalesOrder));
			}
		}
	}

	public class CredentialsDTO
	{
		public String User;
		public String Password;

		// Using Named Credentials
		public CredentialsDTO()
		{
			User		= '{!$Credential.UserName}';
			Password	= '{!$Credential.Password}';
		}
	}

	public class SalesOrderDTO
	{
		public String SalesOrderId;
		public String BodyShopId;
		public String AssessmentReference;
		public String BodyShopOrderNumber;
		public String Entity;
		public String MissionNumber;
		public String PlateNumber;
		public String Status;
		public List<OfferDTO> Offers;

		public SalesOrderDTO(PrerequisiteOrder__c currentSalesOrder)
		{
			SalesOrderId 			= currentSalesOrder.Name;
			BodyShopId				= currentSalesOrder.BodyShop__c;
			BodyShopOrderNumber		= currentSalesOrder.BodyshopOrderNumber__c;
			PlateNumber				= currentSalesOrder.PlateNumber__c;
			Status					= currentSalesOrder.Status__c;

			//if(currentSalesOrder.Assessment__c != null && currentSalesOrder.Assessment__r.RecordType.DeveloperName == 'NewAssessment'){
			//	AssessmentReference		= currentSalesOrder.Assessment__r.AssessmentID__c;
			//	Entity					= currentSalesOrder.Assessment__r.Entity__c;
			//	MissionNumber			= currentSalesOrder.Assessment__r.MissionNumber__c;
			//}
			//if(	currentSalesOrder.Assessment__c != null && 
			//	currentSalesOrder.Assessment__r.ParentAssessment__c != null && 
			//	currentSalesOrder.Assessment__r.ParentAssessment__r.RecordType.DeveloperName == 'Claim')
			//{
				// it has a claim assessment as parent
				
				//AMI 06/10/17 : C-002027 (AssessmentID is mandatory if the field is empty send Assessment Number )
				AssessmentReference		= string.isNotBlank(currentSalesOrder.Assessment__r.AssessmentID__c) ?
											currentSalesOrder.Assessment__r.AssessmentID__c :
											currentSalesOrder.Assessment__r.AssessmentNumber__c;
				
				Entity					= currentSalesOrder.Assessment__r.Entity__c;
				MissionNumber			= currentSalesOrder.Assessment__r.MissionNumber__c;
			//}


			// Map Offer Type -> Map Parent Offer -> Wrapper
			Map<String, Map<Id, OfferWrapper>> mapTypeOfferWrapper = new Map<String, Map<Id, OfferWrapper>>();

			// Seperating the offers according to its Type
			for(Offer__c currentOffer: currentSalesOrder.Offers__r)
			{
				// This code should always be above
				if(!mapTypeOfferWrapper.containsKey(currentOffer.Type__c))
				{
					// Add an entry for that Type
					mapTypeOfferWrapper.put(currentOffer.Type__c, new Map<Id, OfferWrapper>());
				}

				Map<Id, OfferWrapper> currentTypeMapOfferWrapper = mapTypeOfferWrapper.get(currentOffer.Type__c);

				if (currentOffer.ParentOffer__c != null)
				{
					// is a child offer

					// Checks if a wrapper of that id already exists
					if (currentTypeMapOfferWrapper.containsKey(currentOffer.ParentOffer__c))
					{
						// add the child offer to the existing wrapper
						currentTypeMapOfferWrapper.get(currentOffer.ParentOffer__c).addChildOffer(currentOffer);
					}
					else
					{
						// put a new wrapper in the map
						currentTypeMapOfferWrapper.put(currentOffer.ParentOffer__c, new OfferWrapper(currentOffer));
					}
				}
				else
				{
					// is the parent offer

					// Checks if a wrapper of that id already exists
					if (currentTypeMapOfferWrapper.containsKey(currentOffer.Id))
					{
						// add the parent offer to the existing wrapper
						currentTypeMapOfferWrapper.get(currentOffer.Id).setParentOffer(currentOffer);
					}
					else
					{
						// put a new wrapper in the map
						currentTypeMapOfferWrapper.put(currentOffer.Id, new OfferWrapper(currentOffer));
					}
				}
			}

			// Checking if there is an entry in the map. If not the Offers will be null
			if(mapTypeOfferWrapper.size() > 0)
			{
				Offers	= new List<OfferDTO>();

				for(String offerType: mapTypeOfferWrapper.keySet())
				{
					Boolean isSelected = (offerType == currentSalesOrder.OfferType__c);
					OfferDTO currentOfferDTO = new OfferDTO(offerType, isSelected, currentSalesOrder.MaximumValidityDate__c, mapTypeOfferWrapper.get(offerType));
					Offers.add(currentOfferDTO);
				}
			}
		}
	}

	public class OfferDTO
	{
		public String OfferType;
		public Boolean isSelected;
		public String MaximumValidityDate;
		public List<OrderDTO> Orders;

		public OfferDTO(String type, Boolean isSelectedOfferType, Date validityDate, Map<Id, OfferWrapper> mapParentOfferWrapper)
		{
			OfferType = type;
			isSelected = isSelectedOfferType;
			MaximumValidityDate = String.valueOf(validityDate);

			if(	mapParentOfferWrapper != null &&
				mapParentOfferWrapper.size() > 0)
			{
				Orders = new List<OrderDTO>();

				for(OfferWrapper currentOfferWrapper: mapParentOfferWrapper.values())
				{
					OrderDTO currentOrderDTO = new OrderDTO(currentOfferWrapper.parentOffer, currentOfferWrapper.childOfferList);
					Orders.add(currentOrderDTO);
				}
			}
		}
	}

	public class OrderDTO
	{
		public String OfferItemName;
		public Decimal VAT;
		public String OriginalPartType;
		public String OriginalPartDescription;
		public String OriginalPartNumber;
		public String OriginalPartManufacturer;
		public Integer Quantity;
		public Decimal CatalogPrice;
		public Decimal CatalogTotalPrice;
		public String EstimatedDeliveryDate;
		public Decimal BodyShopDiscount;
		public Decimal BodyShopPrice;
		public Decimal BodyShopTotalPrice;
		public Boolean Suppliable;
		public Boolean AcceptedByBS;
		public String BodyShopDeliveryStatus;
		public String BodyShopDeliveryDate;
		public String Comment;
		public List<AlternativeDTO> Alternatives;

		public OrderDTO(Offer__c parentOffer, List<Offer__c> childOfferList)
		{
			OfferItemName				= parentOffer.Name;
			VAT							= parentOffer.VAT__c;
			OriginalPartType			= ((parentOffer.OriginalType__c != null) ? parentOffer.OriginalType__c : parentOffer.FinalType__c);
			OriginalPartDescription		= ((parentOffer.OriginalDescription__c != null) ? parentOffer.OriginalDescription__c : parentOffer.Description__c);
			OriginalPartNumber			= ((parentOffer.OriginalPartNumber__c != null) ? parentOffer.OriginalPartNumber__c : parentOffer.PartNUmber__c);
			OriginalPartManufacturer	= ((parentOffer.OriginalManufacturer__c != null) ? parentOffer.OriginalManufacturer__c : parentOffer.Manufacturer__c);
			Quantity					= Integer.valueOf(parentOffer.Quantity__c);
			CatalogPrice				= parentOffer.CataloguePrice__c;
			CatalogTotalPrice			= parentOffer.Total__c;
			EstimatedDeliveryDate		= String.valueOf(parentOffer.ExpectedDeliveryDate__c);
			BodyShopDiscount			= parentOffer.Discount__c;
			BodyShopPrice				= parentOffer.Price__c;
			BodyShopTotalPrice			= parentOffer.BSTotalPrice__c;
			Suppliable					= ((parentOffer.OrderLine__r.Suppliable__c == 'YES') ? true : false);
			AcceptedByBS				= ((parentOffer.Accepted__c == 'YES') ? true : false);
			BodyShopDeliveryStatus		= parentOffer.DeliveryStatus__c;
			BodyShopDeliveryDate		= String.valueOf(parentOffer.RealDeliveryDate__c);
			Comment						= parentOffer.Comment__c;

			if(	childOfferList != null &&
				childOfferList.size() > 0)
			{
				Alternatives = new List<AlternativeDTO>();

				for(Offer__c currentChildOffer: childOfferList)
				{
					Alternatives.add(new AlternativeDTO(currentChildOffer));
				}
			}
		}
	}

	public class AlternativeDTO
	{
		public String OfferItemName;
		public String PartType;
		public String PartDescription;
		public String PartNumber;
		public String PartManufacturer;
		public Integer Quantity;
		public Decimal CatalogPrice;
		public Decimal CatalogTotalPrice;
		public String EstimatedDeliveryDate;
		public Decimal BodyShopDiscount;
		public Decimal BodyShopPrice;
		public Decimal BodyShopTotalPrice;
		public Boolean Suppliable;
		public Boolean AcceptedByBS;
		public String BodyShopDeliveryStatus;
		public String BodyShopDeliveryDate;
		public String Comment;

		public AlternativeDTO(Offer__c currentOffer)
		{
			OfferItemName				= currentOffer.Name;
			PartType					= currentOffer.FinalType__c;
			PartDescription				= currentOffer.Description__c;
			PartNumber					= currentOffer.PartNUmber__c;
			PartManufacturer			= currentOffer.Manufacturer__c;
			Quantity					= Integer.valueOf(currentOffer.Quantity__c);
			CatalogPrice				= currentOffer.CataloguePrice__c;
			CatalogTotalPrice			= currentOffer.Total__c;
			EstimatedDeliveryDate		= String.valueOf(currentOffer.ExpectedDeliveryDate__c);
			BodyShopDiscount			= currentOffer.Discount__c;
			BodyShopPrice				= currentOffer.Price__c;
			BodyShopTotalPrice			= currentOffer.BSTotalPrice__c;
			Suppliable					= ((currentOffer.OrderLine__r.Suppliable__c == 'YES') ? true : false);
			AcceptedByBS				= ((currentOffer.Accepted__c == 'YES') ? true : false);
			BodyShopDeliveryStatus		= currentOffer.DeliveryStatus__c;
			BodyShopDeliveryDate		= String.valueOf(currentOffer.RealDeliveryDate__c);
			Comment						= currentOffer.Comment__c;
		}
	}

	public class SalesOrderResponse
	{
		public String SaleOrderId;
		public Boolean Success;
		public String ErrorMessage;
	}

	public class JSONResult
	{
		public List<SalesOrderResponse> Result;
	}

	// Wrapper for internal processing only
	public class OfferWrapper
	{
		public Offer__c parentOffer {get; set;}
		public List<Offer__c> childOfferList {get; set;}

		public OfferWrapper(Offer__c off)
		{
			childOfferList = new List<Offer__c>();

			if (off.ParentOffer__c != null)
			{
				// the offer is a child offer
				childOfferList.add(off);
			}
			else
			{
				// the offer is a parent offer
				parentOffer = off;
			}
		}

		public void setParentOffer(Offer__c offer)
		{
			if (parentOffer == null)
			{
				parentOffer = offer;
			}
		}

		public void addChildOffer(Offer__c offer)
		{
			childOfferList.add(offer);
		}
	}
}