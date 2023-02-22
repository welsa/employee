/*
----------------------------------------------------------------------
-- - Name          : RESTPostAssessment
-- - Author        : ABT
-- - Description   : Class used to send data to ICE for sync of data
--
-- Maintenance History:
--ate
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 03-FEB-2017	ABT		1.0			Initial version
-- 04-APR-2017	ASE		1.1			Filtering assessments IsShoppingList = false
-- 04-OCT-2017  AMI     1.2         C-002019 : PostAssessment set status on SO
-- 06-OCT-2017  AMI     1.3         C-002027 : POSTSalesOrder / POSTAssessment Defects
-- 13-NOV-2017  AMI     1.4         Add none to required fields
									- system required a null value (dummy data) to be 
									- sent in case sf returns null
-- 11-JAN-2018  AMI     1.5         Changing class modifier to "Without Sharing" since certain users were not able to launch the callout
-- 28-Mar-2018  RLA     1.6     	C-002177: Corrections/evolutions sur les logs
-- 02-MAY-2018  RLA     1.7     	C-002443: Status of ICE on Assessment
-- 07-JAN-2021  WCH     1.8     	C-003915 - arreter les flux RestPostAssessment et RestPostSalesOrder
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class RESTPostAssessment
{

	private static String objReference = '';
    private static List<AssessmentResponse> lstResultAssResponse = new List<AssessmentResponse>();
    private static List<Assessment__c> listAssessmentstoUpdate = new list<Assessment__c>();
    private static boolean isComingFromRestUpsert = false;
    private static boolean toSendReqOrNot = false;

	@future(callout = true)
	public static void buildJSONAsync(Set<Id> assessmentIdSet)
	{
		buildJSON(assessmentIdSet);
	}

	@future(callout = true)
	public static void buildJSONAsyncForRestUpsert(Set<Id> assessmentIdSet, boolean isRestUpsert)
	{
		system.debug('## START isRestUpsert'+ isRestUpsert);
		isComingFromRestUpsert = isRestUpsert;
		buildJSON(assessmentIdSet);
	}

	//AMI 04/10/17 : set status on SO (adding return type to method so that same can be used in relaunch button) 
	public static callOutStatus buildJSON(Set<Id> assessmentIdSet)
	{
		system.debug('## START RESTPostAssessment.buildJSON');

		//AMI 04/10/17 :  set status on SO (initialise wrapper)
		callOutStatus callOutWrap = new callOutStatus();

		//AMI 06/10/17 : C-002027 (Claim Number / plate Number are mandatory don't call post Assessment if the data is missing)
		List<Assessment__c> assessmentList = [	SELECT 	Id, TransactionId__c, AssessmentNumber__c, AssessmentID__c, BodyShopCreationDate__c, 
														Entity__c, EntityCode__c, ExpertValidationDate__c, MissionNumber__c, Name, PortfolioAgentCode__c, 
														Status__c, Manufacturer__c, ModelV2__c, PlateNumber2__c, FirstRegistrationDate__c, VINNumber__c, 
														TotalLoss__c, ClaimReference__c, CompanyName__c, DateOfIncident__c, RepairsAuthorised__c, SupposedOfFraud__c, 
														Fleet__c, SpecialRenting__c, SpecialAgreement__c, ExcessAmount__c,
														BodyShop__r.ReferenceNumber__c, BodyShop__r.ContactUser__c, BodyShop__r.ContactUser__r.Email, 
														BodyShop__r.ContactEmail__c,WSStatus__c, //C-002443: Status of ICE on Assessment
														(SELECT Id, Compliance__c, Description__c, GuideNo__c, HeldDate__c, Name, PartNumber__c, 
																PartNumberOptimized__c, Price__c, PriceOptimized__c, ProducerName__c, ProducerNameOptimized__c, 
																Quantity__c, RecordType.Name, Status__c, Type__c, VAT__c
														 FROM	PartsLists__r)
												FROM	Assessment__c
												WHERE	Id IN: assessmentIdSet
												AND		BodyShop__r.AXAPartner__c = true 
												AND 	IsShoppingList__c = false
												AND     PlateNumber2__c != null
												AND 	ClaimReference__c != null];

		if(assessmentList.size() > 0)
		{
			if (isComingFromRestUpsert){
				toSendReqOrNot = true;	
			}
			else{
				if (assessmentList[0].WSStatus__c != ASPISConstants.PRE_ORDER_WSSTATUS_ICEOK){
					toSendReqOrNot = true;							
				}
			}
			PostAssessmentInformation wrapper = new PostAssessmentInformation(assessmentList);
			System.debug('## JSON: ' + JSON.serialize(wrapper));

			//AMI 04/10/17 :  set status on SO (build wrapper)
			callOutWrap = sendRequest(JSON.serialize(wrapper),assessmentList[0].id);
		}else{
			callOutWrap.isSuccessful = false;
			callOutWrap.statusMessage = system.label.SOWSAdminMessage;
		}
		system.debug('## END RESTPostAssessment.buildJSON');

		return callOutWrap;
	}

	//AMI 04/10/17 : set status on SO (adding return type to method so that same can be used in relaunch button) 
	public static callOutStatus sendRequest(String requestBody,String assessmentId)
	{
		//AMI 04/10/17 :  set status on SO (initialise wrapper)
		callOutStatus callOutWrap = new callOutStatus();

		// Building Request
		HTTPRequest request = new HTTPRequest();
		request.setEndpoint('callout:FR_ICE/PostAssessmentInformation');
		request.setHeader('Content-Type','application/json; charset=UTF-8');
		request.setHeader('Accept','application/json');
		request.setBody(requestBody);
		request.setMethod('POST');
		request.setTimeout(120000);

		// Variables needed
		String responseBody = '';
		Boolean isSuccessful = true;
		String [] resultStringArr = new list <String> ();

		//WCH 07/01/2021 C-003915
		List<ConfigurationFlux__mdt> getProperRESTPostAssessmentConfigs = [select id,Runnable__c from ConfigurationFlux__mdt where DeveloperName='RESTPostAssessment'];

		if ((toSendReqOrNot && (getProperRESTPostAssessmentConfigs.size()>0 && getProperRESTPostAssessmentConfigs[0].Runnable__c)) || Test.isRunningTest()){ 	
			// Sending request
			HTTP httpCall 			= new HTTP();
			try
			{
				HTTPResponse response	= httpCall.send(request);
				
				System.debug('## response: ' + response);
				System.debug('## body: ' + response.getBody());
				
				responseBody			= response.getBody();
				resultStringArr 		= processResponse(responseBody).split(';');
				isSuccessful 			= Boolean.valueOf(resultStringArr[0]);
			}
			catch(Exception e)
			{
				responseBody = e.getStackTraceString();
				isSuccessful = false;
				system.debug('##String.valueOf(isSuccessful) '+String.valueOf(isSuccessful));
				resultStringArr.add(String.valueOf(isSuccessful));
				resultStringArr.add(e.getMessage());
				resultStringArr.add(assessmentId);
				system.debug('##resultStringArr '+resultStringArr);
			}
		
			// Creating the log
			//AMI 04/10/17 : set status on SO (passing new parameters)
			createLog(requestBody, responseBody, isSuccessful,'ICE', 'RESTPostAssessment', 'Assessment__c', resultStringArr,assessmentId);
		}
		callOutWrap.isSuccessful = isSuccessful;
		callOutWrap.statusMessage = (resultStringArr.size() > 0) ? resultStringArr[1] : '';
		return callOutWrap;
	}

	public static String processResponse(String response)
	{
		JSONResult responseWrapper = (JSONResult) JSON.deserialize(response, JSONResult.class);
		String resultString;
		System.debug('##responseWrapper : ' + responseWrapper);

		Boolean isSuccessful = true;

		if(responseWrapper != null && responseWrapper.Result != null)
		{
			// loop in the list of AssessmentResponse
			for(AssessmentResponse currentAssessmentResponse : responseWrapper.Result)
			{
				if(!currentAssessmentResponse.Success)
				{
					isSuccessful = false;
					resultString =  isSuccessful + ';' + currentAssessmentResponse.errorMessage + ';' + currentAssessmentResponse.TechnicalId;
					break;
				}
				else{
					resultString =  isSuccessful + ';' + currentAssessmentResponse.errorMessage + ';'+ currentAssessmentResponse.TechnicalId;
				}
			}
			
		}
		else
		{
			// success if false
			isSuccessful = false;
			resultString =  isSuccessful + ';' + 'Response is null' + ';' + responseWrapper.Result[0].TechnicalId;
		}

		system.debug('##resultString '+ resultString);
		return resultString;
	}

	//AMI 04/10/17 : set status on SO (passing new parameters)
	public static void createLog(
		String request, 
		String response, 
		Boolean isSuccessful, 
		String systemCalling, 
		String classUsed, 
		String obj , 
		String [] resultStringArr,
		string assessmentId){

		System.debug('@@ isSuccessful:'+isSuccessful);
		Assessment__c assToUpdate;
		//list use to update SO in case of error during callout
		list <PrerequisiteOrder__c> soToUpdate = new list <PrerequisiteOrder__c> ();
		//AMI 04/10/17 : set status on SO
		//query associated SO from assessmentToUpdate
		list <PrerequisiteOrder__c> SOAssociatedWithAssessment = new list <PrerequisiteOrder__c>([select id
																									from PrerequisiteOrder__c
																									where Assessment__c = :assessmentId]);

		//AMI 04/10/17 : set status on SO
		//update SO based on status of callout
		if(!SOAssociatedWithAssessment.isEmpty()){
			objReference = SOAssociatedWithAssessment[0].Id; 
			if(isSuccessful){
				//no error reported
				soToUpdate.add(new PrerequisiteOrder__c(id = SOAssociatedWithAssessment[0].Id,
														WSResult__c = '',
														WSStatus__c = 'ICE Assessment - OK'));
			}else{
				//error reported
				soToUpdate.add(new PrerequisiteOrder__c(id = SOAssociatedWithAssessment[0].Id,
														WSResult__c = resultStringArr[1],
														WSStatus__c = 'ICE Assessment - KO'));
			}
		}
		
		system.debug('## soToUpdate ' + soToUpdate);
		if(!soToUpdate.isEmpty()){
			update soToUpdate;
		}		

		
		if (toSendReqOrNot){
			//RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
	        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
	        wrapperLog.assessmentId = assessmentId;
	        wrapperLog.sobjectid = assessmentId;
	        wrapperLog.className = classUsed;
	        //wrapperLog.objectreference = objReference; 
	        wrapperLog.sobjectName = obj;            
	        wrapperLog.inout = 'Outbound';
	        
	        wrapperLog.systemCalling = systemCalling;
	        wrapperLog.status = (isSuccessful) ? 'Passed' : 'Failed';
			
			if(resultStringArr.size()>0){
				wrapperLog.errorDescription =  resultStringArr[1];
				wrapperLog.sObjectId =  resultStringArr[2];
			}

			// Check if the length of the request is less or equal to 32768 -> add request in JSONMessage__c
			if(request.length() <= 32768)
			{
				 wrapperLog.jsonmessage = request;
			}

			// Check if the length of the response is less or equal to 32768 -> add request in JSONResponse__c
			if(response.length() <= 32768)
			{
				wrapperLog.jsonResponse = response;
			}

			// In case the request was too big create an attachment for it
			if(request.length() > 32768)
			{
				wrapperLog.attachmentRequestbody = request;
			}

			// In case the response was too big create an attachment for it
			if(response.length() > 32768)
			{
				wrapperLog.attachmentResponsebody = response;
			}

			wrapperLog.objectreference = objReference;
			APManageLogs.createWsLog(wrapperLog, 'insert');
			assToUpdate = new Assessment__c(Id = assessmentId);
			assToUpdate.WSStatus__c = (isSuccessful) ? ASPISConstants.PRE_ORDER_WSSTATUS_ICEOK : ASPISConstants.PRE_ORDER_WSSTATUS_ICEKO; 

			system.debug('## assToUpdate ' + assToUpdate);
			if (assToUpdate != null){
				update assToUpdate;
			}

		}


		
	}

	public class PostAssessmentInformation
	{
		public CredentialsDTO Credentials;
		public List<AssessmentDTO> ListAssessments;

		public PostAssessmentInformation(List<Assessment__c> assessmentList)
		{
			Credentials = new CredentialsDTO();
			ListAssessments = new List<AssessmentDTO>();

			for(Assessment__c currentAssessment: assessmentList)
			{
				ListAssessments.add(new AssessmentDTO(currentAssessment));
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
	
	public class AssessmentDTO
	{
		public String TransactionID;
		public String AssessmentNumber;
		public String FunctionalId;
		public String TechnicalId;
		// public String BodyShopCreationDate;
		public String Entity;
		public String EntityCode;
		// public String ExpertValidationDate;
		public String MissionNumber;
		public String Name;
		public String PortfolioAgentCode;
		public String Status;
		public List<PartDTO> Parts;
		public CurrentAssetDTO CurrentAsset;
		public CurrentBodyShopDTO CurrentBodyShop;
		public CurrentClaimDTO CurrentClaim;

		public AssessmentDTO(Assessment__c currentAssessment)
		{
			//if(!mapAssNameId.containsKey(currentAssessment.Name)){
			//	mapAssNameId.put(currentAssessment.Name, currentAssessment.Id);
			//}
			TransactionID 			= currentAssessment.TransactionId__c;
			AssessmentNumber 		= currentAssessment.AssessmentNumber__c;

			//AMI 06/10/17 : C-002027 (AssessmentID is mandatory if the field is empty send Assessment Number )
			FunctionalId 			= string.isNotBlank(currentAssessment.AssessmentID__c) ? 
										currentAssessment.AssessmentID__c : 
										currentAssessment.AssessmentNumber__c;

			TechnicalId 			= currentAssessment.Id;
			// BodyShopCreationDate 	= String.valueOf(currentAssessment.BodyShopCreationDate__c);
			Entity 					= currentAssessment.Entity__c;
			EntityCode 				= currentAssessment.EntityCode__c;
			// ExpertValidationDate 	= String.valueOf(currentAssessment.ExpertValidationDate__c);
			MissionNumber 			= currentAssessment.MissionNumber__c;
			Name 					= currentAssessment.Name;
			PortfolioAgentCode 		= currentAssessment.PortfolioAgentCode__c;
			Status 					= currentAssessment.Status__c;

			if(currentAssessment.PartsLists__r != null &&
				currentAssessment.PartsLists__r.size() > 0)
			{
				Parts = new List<PartDTO>();

				for(PartList__c currentPart: currentAssessment.PartsLists__r)
				{
					Parts.add(new PartDTO(currentPart));
				}
			}

			CurrentAsset 			= new CurrentAssetDTO(currentAssessment);
			CurrentBodyShop 		= new CurrentBodyShopDTO(currentAssessment.BodyShop__r);
			CurrentClaim 			= new CurrentClaimDTO(currentAssessment);
		}
	}

	public class PartDTO
	{
		public Boolean Compliance;
		public String Description;
		// public Integer GuideNo;
		// public DateTime HeldDate;
		public String Name;
		public String PartNumber;
		// public String PartNumberOptimized;
		public Decimal Price;
		// public Decimal PriceOptimized;
		public String ProducerName;
		// public String ProducerNameOptimized;
		public Integer Quantity;
		public String RecordType;
		public String Status;
		public String Type;
		public Decimal VAT;

		public PartDTO(PartList__c currentPartList)
		{
			Compliance 				= currentPartList.Compliance__c;
			Description 			= currentPartList.Description__c;
			// GuideNo 				= Integer.valueOf(currentPartList.GuideNo__c);
			// HeldDate 				= currentPartList.HeldDate__c;
			Name 					= currentPartList.Name;
			PartNumber 				= currentPartList.PartNumber__c;
			// PartNumberOptimized 	= currentPartList.PartNumberOptimized__c;
			Price 					= currentPartList.Price__c;
			// PriceOptimized 			= currentPartList.PriceOptimized__c;
			ProducerName 			= currentPartList.ProducerName__c;
			// ProducerNameOptimized 	= currentPartList.ProducerNameOptimized__c;
			Quantity 				= Integer.valueOf(currentPartList.Quantity__c);
			RecordType 				= currentPartList.RecordType.Name;
			Status 					= currentPartList.Status__c;
			Type 					= currentPartList.Type__c;
			VAT 					= currentPartList.VAT__c;
		}
	}

	public class CurrentAssetDTO
	{
		//public String BrakesPedalTravel;
		//public String BuildDate;
		//public String Colour;
		//public String DamageAreas;
		//public String DirectionImpact;
		//public String Engine;
		public String Manufacturer;
		public String Model;
		//public String ModelSheetNumber;
		//public String ModelSpecs;
		//public String Odometer;
		//public String PaintCode;
		//public String PlaceOfInspection;
		public String PlateNumber;
		//public String PreAccidentCondition;
		//public String PreAccidentDamage;
		public String FirstRegistrationDate;
		//public String RegistrationMonth;
		//public String RegistrationNumber;
		//public Integer RegistrationYear;
		//public String SelectionType;
		//public String SeverityOfImpact;
		//public String SteeringRimPly;
		//public String TreadDepthLHF; // Before -> Double
		//public String TreadDepthLHR; // Before -> Double
		//public String TreadDepthRHF; // Before -> Double
		//public String TreadDepthRHR; // Before -> Double
		public String VINNumber;
		//public String VehicleStatusInspection;
		//public Integer KMS;
		//public String PaintingType;
		//public String Energy;
		//public DateTime PickupDate;
		//public String VDSCode;

		public CurrentAssetDTO(Assessment__c currentAssessment)
		{
			// BrakesPedalTravel 		= currentAssessment.BrakesPedalTravel__c;
			// BuildDate 				= String.valueOf(currentAssessment.BuildDate__c);
			// Colour 					= currentAssessment.Colour__c;
			// DamageAreas 			= currentAssessment.DamageAreas__c;
			// DirectionImpact 		= currentAssessment.DirectionImpact__c;
			// Engine 					= currentAssessment.Engine__c;    

			//AMI 13/11/17 :  Add none to required fields
			Manufacturer 			= string.isNotBlank(currentAssessment.Manufacturer__c) ? currentAssessment.Manufacturer__c : 'None';
			
			//AMI 13/11/17 :  Add none to required fields
			Model 					= string.isNotBlank(currentAssessment.ModelV2__c) ? currentAssessment.ModelV2__c : 'None';
			
			// ModelSheetNumber 		= currentAssessment.ModelSheetNumber__c;
			// ModelSpecs 				= currentAssessment.ModelSpecs__c;
			// Odometer 				= currentAssessment.Odometer__c;
			// PaintCode 				= currentAssessment.PaintCode__c;
			// PlaceOfInspection 		= currentAssessment.PlaceOfInspection__c;
			PlateNumber 			= currentAssessment.PlateNumber2__c;
			// PreAccidentCondition 	= currentAssessment.PreAccidentCondition__c;
			// PreAccidentDamage 		= currentAssessment.PreAccidentDamage__c;
			
			//AMI 13/11/17 :  Add none to required fields
			if(currentAssessment.FirstRegistrationDate__c != null){
				FirstRegistrationDate 	= String.valueOf(currentAssessment.FirstRegistrationDate__c);
			}else{
				FirstRegistrationDate   = 'None';
			}

			// RegistrationMonth 		= currentAssessment.RegistrationMonth__c;
			// RegistrationNumber 		= currentAssessment.RegistrationNumber__c;
			// RegistrationYear 		= Integer.valueOf(currentAssessment.RegistrationYear__c);
			// SelectionType 			= currentAssessment.SelectionType__c;
			// SeverityOfImpact 		= currentAssessment.SeverityOfImpact__c;
			// SteeringRimPly 			= currentAssessment.SteeringRimPly__c;
			// TreadDepthLHF 			= currentAssessment.TreadDepthLHF__c;
			// TreadDepthLHR 			= currentAssessment.TreadDepthLHR__c;
			// TreadDepthRHF 			= currentAssessment.TreadDepthRHF__c;
			// TreadDepthRHR 			= currentAssessment.TreadDepthRHR__c;
			
			//AMI 13/11/17 :  Add none to required fields
			VINNumber 				= string.isNotBlank(currentAssessment.VINNumber__c) ? currentAssessment.VINNumber__c : 'None';
			
			// VehicleStatusInspection = currentAssessment.VehicleStatusInspection__c;
			// KMS 					= Integer.valueOf(currentAssessment.KMS__c);
			// PaintingType 			= currentAssessment.PaintingType__c;
			// Energy 					= currentAssessment.Energy__c;
			// PickupDate 				= currentAssessment.PickupDate__c;
			// VDSCode 				= currentAssessment.VDSCode__c;
		}
	}

	public class CurrentBodyShopDTO
	{
		// public String BillingCity;
		// public String BillingStreet;
		// public String BillingZipCode;
		// public String ClientScoring;
		// public String InvoicePeriod;
		// public String Name;
		// public String OrderEmail;
		public String ReferenceNumber;
		// public String ShippingCity;
		// public String ShippingStreet;
		// public String ShippingZipCode;
		public String BodyShopEmail;

		public CurrentBodyShopDTO(Account currentAccount)
		{
			// BillingCity = currentAccount.BillingCity;
			// BillingStreet = currentAccount.BillingStreet;
			// BillingZipCode = currentAccount.BillingPostalCode;
			// ClientScoring = currentAccount.ClientScoring__c;
			// InvoicePeriod = currentAccount.;
			// Name = currentAccount.Name;
			// OrderEmail = currentAccount.ContactEmail__c;
			ReferenceNumber = currentAccount.ReferenceNumber__c;
			// ShippingCity = currentAccount.ShippingCity;
			// ShippingStreet = currentAccount.ShippingStreet;
			// ShippingZipCode = currentAccount.ShippingPostalCode;
			BodyShopEmail 	= (currentAccount.ContactUser__c != null) ? currentAccount.ContactUser__r.Email : currentAccount.ContactEmail__c;
			
		}
	}

	public class CurrentClaimDTO
	{
		public Boolean TotalLoss;
		// public Boolean AbleToAuthoriseRepairs; // Before -> String
		// public String AuthorisationStatus;
		public String ClaimReference;
		public String CompanyName;
		public Date DateOfIncident; // Before -> DateTime
		// public Integer EstimatedRepairTime;
		// public String IncidentReference;
		// public String OtherReference;
		// public String PolicyNumber;
		public Boolean RepairsAuthorised;
		// public Decimal VATPortionPayable;
		// public String WorkProvider;
		// public Decimal QuotationAmountExlVAT;
		// public Decimal QuotationAmountInclVAT;
		// public Decimal TotalAmtLabourPainting;
		// public Decimal TotalAmtLabour;
		// public Decimal TotalAmtParts;
		// public Decimal TotalAmtPainting;
		// public Decimal TotalAmtExlVAT;
		// public Decimal TotalVAT;
		// public Decimal TotalAmtInclVAT;
		// public Decimal NBHoursLabour;
		// public Decimal NBHoursLabourLevel1;
		// public Decimal NBHoursLabourLevel2;
		// public Decimal NBHoursLabourLevel3;
		// public Decimal TotalAmtLabourExlPainting;
		// public Decimal TotalAmtPaintingInclLabour;
		// public Decimal AmtOthers;
		public Boolean Fraud;
		public Boolean Fleet;
		public Boolean Rental;
		public Boolean SpecialAgreement;
		public Decimal ExcessAmount;

		public CurrentClaimDTO(Assessment__c currentAssessment)
		{
			TotalLoss					= currentAssessment.TotalLoss__c;
			// AbleToAuthoriseRepairs		= currentAssessment.AbleToAuthoriseRepairs__c;
			// AuthorisationStatus			= currentAssessment.AuthorisationStatus__c;
			ClaimReference				= currentAssessment.ClaimReference__c;
			CompanyName					= (currentAssessment.CompanyName__c != null) ? currentAssessment.CompanyName__c : currentAssessment.Entity__c;
			DateOfIncident				= (currentAssessment.DateOfIncident__c != null) ? currentAssessment.DateOfIncident__c : date.newinstance(1901, 1, 1);
			// EstimatedRepairTime			= Integer.valueOf(currentAssessment.EstimatedRepairTime__c);
			// IncidentReference			= currentAssessment.IncidentReference__c;
			// OtherReference				= currentAssessment.OtherReference__c;
			// PolicyNumber				= currentAssessment.PolicyNumber__c;
			RepairsAuthorised			= currentAssessment.RepairsAuthorised__c;
			// VATPortionPayable			= currentAssessment.VATPortionPayable__c;
			// WorkProvider				= currentAssessment.WorkProvider__c;
			// QuotationAmountExlVAT		= currentAssessment.QuotationAmtExlVAT__c;
			// QuotationAmountInclVAT		= currentAssessment.QuotationAmountInclVAT__c;
			// TotalAmtLabourPainting		= currentAssessment.TotalAmtLabourPainting__c;
			// TotalAmtLabour				= currentAssessment.TotalAmtLabour__c;
			// TotalAmtParts				= currentAssessment.TotalAmtParts__c;
			// TotalAmtPainting			= currentAssessment.TotalAmtPainting__c;
			// TotalAmtExlVAT				= currentAssessment.TotalAmtExlVAT__c;
			// TotalVAT					= currentAssessment.TotalVAT__c;
			// TotalAmtInclVAT				= currentAssessment.TotalAmtInclVAT__c;
			// NBHoursLabour				= currentAssessment.NBHoursLabour__c;
			// NBHoursLabourLevel1			= currentAssessment.NBHoursLabourLevel1__c;
			// NBHoursLabourLevel2			= currentAssessment.NBHoursLabourLevel2__c;
			// NBHoursLabourLevel3			= currentAssessment.NBHoursLabourLevel3__c;
			// TotalAmtLabourExlPainting	= currentAssessment.TotalAmtLabourExlPainting__c;
			// TotalAmtPaintingInclLabour	= currentAssessment.TotalAmtPaintingInclLabour__c;
			// AmtOthers					= currentAssessment.AmtOthers__c;

			Fraud						= currentAssessment.SupposedOfFraud__c;
			Fleet						= currentAssessment.Fleet__c;
			Rental						= currentAssessment.SpecialRenting__c;
			SpecialAgreement			= currentAssessment.SpecialAgreement__c;
			ExcessAmount				= currentAssessment.ExcessAmount__c;
		}
	}

	public class AssessmentResponse 
	{
		public String TechnicalId;
		public String FunctionalId;
		public Boolean Success;
		public String ErrorMessage;
	}

	public class ErrorResponse
	{
		public String ErrorDescription;
		public String isSuccessful;

	}

	public class JSONResult
	{
		public List<AssessmentResponse> Result;
	}

	//AMI 04/10/17 : set status on SO (new wrapper class to hold success status and msg - to be used for relaunch button)
	public class callOutStatus{
		public boolean isSuccessful;
		public string statusMessage;

		public callOutStatus(){
			isSuccessful = true;
			statusMessage = '';
		}
	}
}