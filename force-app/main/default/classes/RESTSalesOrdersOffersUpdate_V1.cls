/*************************************************************************************
Class Name -  
Version - 1.0
Created Date - 12 MAY 2015
Function - Class REST for update sales order offers selected

Modification Log :
-----------------------------------------------------------------------------
* Developer  		Date       	Description
* -------------- 	----------  -----------------------
* Brayan N    		12/05/2015 	version 1
* Ashwina S  		14/03/2015  C-001428: Gestion des pièces "à retourner" depuis ICE
* Ashutosh B		22/09/2016	C-001728: Added the new function of create attachment
* Dourga U          13/10/2016  C-001757: Update sales order web service
* Ashwina S         06/12/2016  C-001829: updateSalesOrdersOffers -> migrate values
*************************************************************************************/
@RestResource(urlMapping='/v1.0/updateSalesOrdersOffers/*')
global with sharing class RESTSalesOrdersOffersUpdate_V1 {
	@HttpPost	
	global static void updateSalesOrdersOffers() {
		map<String,String> mapHeaders = new map<String,String>();
		string results = '';
		//retrieve the headers that are received by the request. Synchronous / Asynchronous
		RestRequest req = RestContext.request;
		mapHeaders = req.headers;
		//system.debug('////mapHeaders: '+mapHeaders);

		
		//to be commented////////////////////////////////////////////////////
		//mapHeaders.put(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
		//////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////
		
		//convert the requestbody into a string3
		String body = RestContext.request.requestBody.toString();
		
		Log__c log = new Log__c();
		log.DateLog__c = system.now();

		// ABT - C-001728 - 22-SEP-2016
		log.Class__c   = 'RESTSalesOrdersOffersUpdate_V1';

		//System.debug('/// Json Message : '+body);
		if (body.length() <= 30000){
			log.JSONMessage__c = body;
			
		}
		insert log;

		if (body.length() > 30000)
		{
			// ABT - C-001728 - 22-SEP-2016
			//APCreateAttachments.createAttachment(body,log);
			APCreateAttachments.createAttachment('Request', body, log);
		}
		
		/*system.debug('/// system.label.CALLTYPE: ' + system.label.CALLTYPE);
		system.debug('/// mapHeaders: ' + mapHeaders);
		system.debug('/// mapHeaders.containsKey(system.label.CALLTYPE): ' + mapHeaders.containsKey(system.label.CALLTYPE));*/
		if(mapHeaders.containsKey(system.label.CALLTYPE)){
			String cType = mapHeaders.get(system.label.CALLTYPE);
			
			if(system.label.ASYNCHRONOUS == cType){
				log.CallType__c = system.label.ASYNCHRONOUS;
				// call @future method
				updateSOAsync(log.Id,body);
				results = system.label.MSGASYNCTREATMENT +' '+log.Id;
			}else if(system.label.SYNCHRONOUS == cType){
				log.CallType__c = system.label.SYNCHRONOUS;
				//call synchronous method 
				results = updateSOSync(log.Id,body);
			}
		}else{
			log.CallType__c = system.label.SYNCHRONOUS; 	
			//if no callType in header, by default call synchronous method
			results = updateSOSync(log.Id,body);
		}

		if(!results.contains(system.label.MSGASYNCTREATMENT)){ 
			if(results.contains('Exceptions')){
				log.Status__c = system.label.STATUSFAILED;
			}else{
				log.Status__c = system.label.STATUSPASSED;
			}
		}else{
			log.Status__c = system.label.STATUSPASSED;
		}

		update log;

		RestContext.response.responseBody = Blob.valueOf(results);
	}

	// call if calltype is async
	@future
	public static void updateSOAsync(Id logId,String body){
		list<Log__c> logToUpdate = new list<Log__c>();
		//call method that will process json that contains assessments
		string jResp = updateSO(body);
		//get log id to update
		for(Log__c l : [Select Id, JSONResponse__c from Log__c where Id =:logId]){
			if (jResp.length() > 30000){
				// ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(jResp,l);
				APCreateAttachments.createAttachment('Response', jResp, l);
			}else{
				l.JSONResponse__c = jResp;
			}
			logToUpdate.add(l);
		}
		
		//update log
		if(logToUpdate.size()  > 0){
			update logToUpdate;
		}
	}
	
	// call if calltype is sync
	public static string updateSOSync(Id logId,String body){
		list<Log__c> logToUpdate = new list<Log__c>();
		//call method that will process json that contains assessments
		string jResp = updateSO(body);
		//get log id to update
		for(Log__c l : [Select Id, JSONResponse__c from Log__c where Id =:logId]){
			if (jResp.length() > 30000){
				// ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(jResp,l);
				APCreateAttachments.createAttachment('Response', jResp, l);
			}else{
				l.JSONResponse__c = jResp;
			}
			logToUpdate.add(l);
		}
		
		//update log
		if(logToUpdate.size()  > 0){
			update logToUpdate;
		}
		return jResp;
	}

	public static string updateSO(string body){
		//convert the requestbody into a string
		String results = '';
		list<PrerequisiteOrder__c> soListToUpdate = new list<PrerequisiteOrder__c>();
		list<PreOrder> preOrderList = new list<PreOrder>();
		list<Offer__c> offerToUpdate = new list<Offer__c>();
		map<String,String> successUpdateMap = new map<String,String>();
		map<String,String> errorUpdateMap = new map<String,String>();
		map<String,PrerequisiteOrder__c> mapSalesOrder = new map<String,PrerequisiteOrder__c>();
		map<Id,List<Offer__c>> mapSOIDNListOffer = new map<Id,List<Offer__c>>();
		set<String> offerRefSet = new set<String>();
		set<String> soSet = new set<STring>();
		map<String,OrderLine> mapOfferLineW = new map<String,OrderLine>();
		map<String,Alternative> mapAlternativeW = new map<String,Alternative>();
		JSONGenerator genResults;
		Boolean IsOfferUpdating = false;		
		Boolean noUpdate = false;		
		Id integrationUserId; 
		map<String, Case__c> SOCaseMap = new map<String, Case__c>();
		list<Prerequisiteorder__c> listSONotToUpdate = new list<Prerequisiteorder__c>();

		map<String,CountryCodeInformationsMapping__c> configCountryCodeInfoMap = CountryCodeInformationsMapping__c.getall();
				        

		try{
			JSONParser parser = JSON.createParser(body);
			  	
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					while (parser.nextToken() != null) {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							PreOrder p = (PreOrder)parser.readValueAs(PreOrder.class);
							parser.skipChildren();
							preOrderList.add(p);
						}
					}
				}
			}
			//system.debug('//// preOrderList: '+ preOrderList);

			if(preOrderList.size() > 0){
				for(PreOrder soW : preOrderList){
					if(soW.SalesOrderId != null){
						soSet.add(soW.SalesOrderId);
					}

					if(soW.Offers.size() > 0){
						//system.debug('////soW.Offers: ' + soW.Offers);
						for(Offer off : soW.Offers){
							if(off.Orders.size() > 0){
								//system.debug('////off.Orders: ' + off.Orders);
								for(OrderLine olW : off.Orders){
									mapOfferLineW.put(olW.OfferItemName,olW);
								}
							}
						}
					}
				}
			}
			//system.debug('////mapOfferLineW: ' + mapOfferLineW);

			for(PrerequisiteOrder__c so : [Select Id,Status__c,BodyShopOrderNumber__c, ReferenceNumber__c,Name 
											from PrerequisiteOrder__c 
												where Name in:soSet])
			{
				mapSalesOrder.put(so.Name,so);
			}

			// ASE: 14/03/2015:C-001428  
			for(Offer__c o : [Select Id,Name,DeliveryStatus__c,RealDeliveryDate__c,Prerequisiteorder__c,PurchaseOrder__c,
									 Accepted__c,Comment__c,Prerequisiteorder__r.TECH_BodyshopCountryCode__c,Prerequisiteorder__r.PartReturnedCaseCreated__c,Prerequisiteorder__r.Assessment__c,Distributor__c,
								(Select Id,Name,DeliveryStatus__c,RealDeliveryDate__c,Prerequisiteorder__c,PurchaseOrder__c,
									 Accepted__c,Comment__c,Prerequisiteorder__r.TECH_BodyshopCountryCode__c,Prerequisiteorder__r.Assessment__c,Distributor__c from Offers__r) 
								from Offer__c 
								where Name in:mapOfferLineW.keySet()])
			{
				if(mapSOIDNListOffer.containsKey(o.Prerequisiteorder__c)){
					mapSOIDNListOffer.get(o.Prerequisiteorder__c).add(o);
				}else{
					list<Offer__c> oList = new list<Offer__c>();
					oList.add(o);
					mapSOIDNListOffer.put(o.Prerequisiteorder__c,oList);
				}
			}
			//system.debug('////mapSOIDNListOffer: ' + mapSOIDNListOffer);
			// get integrationUserId to create case
			//integrationUserId = [Select id from user where user.profile.name = 'ASPIS Integration'].Id;
			integrationUserId = UserInfo.getUserId();							
			for(PreOrder soW : preOrderList){
				if(mapSalesOrder.containsKey(soW.SalesOrderId)){
					PrerequisiteOrder__c actSO = mapSalesOrder.get(soW.SalesOrderId);
					//system.debug('////actSO.Status__c : ' + actSO.Status__c);
					if(actSO.Status__c == 'INACCEPTANCE'){
						boolean rejected = true;
						if(mapSOIDNListOffer.containsKey(actSO.Id)){
							//system.debug('////mapSOIDNListOffer.containsKey(actSO.Id)');
							
							for(Offer__c o : mapSOIDNListOffer.get(actSO.Id)){

								if(mapOfferLineW.containsKey(o.Name)){
									OrderLine oLW = mapOfferLineW.get(o.Name);
									//system.debug('/// oLW : '+ oLW);

									//system.debug('/// oLW.AcceptedByBS'+ oLW.AcceptedByBS);
									if(oLW.AcceptedByBS){
										o.Accepted__c = 'YES';
										rejected = false;

										if(o.Comment__c != null){
											o.Comment__c = o.Comment__c +''+oLW.Comment;
										}else{
											o.Comment__c = oLW.Comment;
										}

										if(o.Offers__r.size()  > 0){
											for(Offer__c bundle : o.Offers__r){
												bundle.Accepted__c = 'YES';

												if(bundle.Comment__c != null){
													bundle.Comment__c = bundle.Comment__c +''+oLW.Comment;
												}else{
													bundle.Comment__c = oLW.Comment;
												}

												offerToUpdate.add(bundle);
											}
										}
									}else{
										o.Accepted__c = 'NO';

										if(o.Comment__c != null){
											o.Comment__c = o.Comment__c +''+oLW.Comment;
										}else{
											o.Comment__c = oLW.Comment;
										}

										if(o.Offers__r.size()  > 0){
											for(Offer__c bundle : o.Offers__r){
												bundle.Accepted__c = 'NO';

												if(bundle.Comment__c != null){
													bundle.Comment__c = bundle.Comment__c +''+oLW.Comment;
												}else{
													bundle.Comment__c = oLW.Comment;
												}

												offerToUpdate.add(bundle);
											}
										}
									}
									offerToUpdate.add(o);
								}
							}
						}
						if(rejected == false){
							actSO.Status__c = 'RESPONDED'; 
						}else{
							actSO.Status__c ='CANCELED';
							actSO.Comment__c = 'Rejected by bodyshop'; 
						}
						soListToUpdate.add(actSO);
					}
					else if(actSO.Status__c == 'INDELIVERY' || actSO.Status__c == 'DELIVERED' ){						
						//Partially Delivered && In delivery
						//System.debug('/// mapSOIDNListOffer: ' + mapSOIDNListOffer);
						if(mapSOIDNListOffer.containsKey(actSO.Id)){
							//System.debug('/// mapSOIDNListOffer.containsKey(actSO.Id): ');
							for(Offer__c o : mapSOIDNListOffer.get(actSO.Id)){
								if(mapOfferLineW.containsKey(o.Name)){
									//System.debug('/// mapOfferLineW.containsKey(o.Name): ');
									OrderLine oLW = mapOfferLineW.get(o.Name);

									//System.debug('///oLW: ' + oLW);

									if(o.Comment__c != null){
										o.Comment__c = o.Comment__c +''+oLW.Comment;
									}else{
										o.Comment__c = oLW.Comment;
									}
									// ASE : 06/12/2016: C-001829
									if( oLW.BodyShopDeliveryStatus == 'INCOMPATIBLE' || oLW.BodyShopDeliveryStatus ==  'CANCELED' 
										|| oLW.BodyShopDeliveryStatus ==  'ERROR' || oLW.BodyShopDeliveryStatus ==  'MISSING' 
										|| oLW.BodyShopDeliveryStatus ==  'DAMAGED' ){
										o.DeliveryStatus__c = 'ERROR';
										o.DeliveryStatusReason__c = oLW.BodyShopDeliveryStatus;
									}
									else{
										o.DeliveryStatus__c = oLW.BodyShopDeliveryStatus;
									}
									// ASE: 14/03/2015:C-001428	

									if(oLW.BodyShopDeliveryStatus == 'RETURNED' &&  !o.Prerequisiteorder__r.PartReturnedCaseCreated__c){
										//getting Country Code Informations from the custom setting according to o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c
								        if(configCountryCodeInfoMap.get(o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c)!=null){
								        //If country requires processing
									        if(configCountryCodeInfoMap.get(o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c).PartReturnedProcessing__c){ 
									        	if(!SOCaseMap.containsKey(o.Prerequisiteorder__c)){
													Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-SO', o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c, null, o.Prerequisiteorder__r.Assessment__c, null, o.Prerequisiteorder__c, '', integrationUserId, '-OfferReturned');
													if(newCase!=null){
														actSO.PartReturnedCaseCreated__c = true;
														soListToUpdate.add(actSO);	
														SOCaseMap.put(o.Prerequisiteorder__c,newCase);
													}		
												}												
											}
										}
									}
									o.RealDeliveryDate__c = oLW.BodyShopDeliveryDate;

									if(o.Offers__r.size()  > 0){
										for(Offer__c bundle : o.Offers__r){
											// ASE : 06/12/2016: C-001829
											if( oLW.BodyShopDeliveryStatus == 'INCOMPATIBLE' || oLW.BodyShopDeliveryStatus ==  'CANCELED' 
												|| oLW.BodyShopDeliveryStatus ==  'ERROR' || oLW.BodyShopDeliveryStatus ==  'MISSING' 
												|| oLW.BodyShopDeliveryStatus ==  'DAMAGED' ){
												bundle.DeliveryStatus__c = 'ERROR';
												bundle.DeliveryStatusReason__c = oLW.BodyShopDeliveryStatus;
											}
											else{
												bundle.DeliveryStatus__c = oLW.BodyShopDeliveryStatus;
											}
											bundle.DeliveryStatus__c = oLW.BodyShopDeliveryStatus;
											// ASE: 14/03/2015:C-001428
											if(oLW.BodyShopDeliveryStatus == 'RETURNED' &&  !o.Prerequisiteorder__r.PartReturnedCaseCreated__c){
												//getting Country Code Informations from the custom setting according to o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c
										        if(configCountryCodeInfoMap.get(o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c)!=null){
										        //If country requires processing
											        if(configCountryCodeInfoMap.get(o.Prerequisiteorder__r.TECH_BodyshopCountryCode__c).PartReturnedProcessing__c){ 
														if(!SOCaseMap.containsKey(bundle.Prerequisiteorder__c)){
															Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-SO', bundle.Prerequisiteorder__r.TECH_BodyshopCountryCode__c, null, bundle.Prerequisiteorder__r.Assessment__c, null, bundle.Prerequisiteorder__c, '', integrationUserId, '-OfferReturned');
															if(newCase!=null){
																actSO.PartReturnedCaseCreated__c = true;
																soListToUpdate.add(actSO);																												
																SOCaseMap.put(bundle.Prerequisiteorder__c,newCase);
															}
														}																												
													}
												}
											}
											bundle.RealDeliveryDate__c = oLW.BodyShopDeliveryDate;											

											if(bundle.Comment__c != null){
												bundle.Comment__c = bundle.Comment__c +''+oLW.Comment;
											}else{
												bundle.Comment__c = oLW.Comment;
											}

											offerToUpdate.add(bundle);
										}
									}
									offerToUpdate.add(o);
								}
							}
						}
						//soListToUpdate.add(actSO);
					}
					//DUN 13/10/2016 case 1757
					else if(actSO.Status__c == 'CANCELED' || actSO.Status__c == 'PAID'){
						noUpdate = true;
						listSONotToUpdate.add(actSO);
					}
				}
			}

			// insert caseList
			if(SOCaseMap.values().size()>0){
				insert SOCaseMap.values();
			}
			if(offerToUpdate.size() > 0){
				//list<Database.SaveResult> uResults = database.update(offerToUpdate,Schema.Offer__c.OfferReference__c);
				//System.debug('/// update offer ');
				update offerToUpdate;

				IsOfferUpdating = true;
			}

			system.debug('## soListToUpdate:'+soListToUpdate);
			if(soListToUpdate.size() > 0){
				List<Database.SaveResult> uResults = database.update(soListToUpdate,Schema.PrerequisiteOrder__c.ReferenceNumber__c);

				for(Integer idx = 0; idx < uResults.size(); idx++) {
					if(uResults[idx].isSuccess()) {
						successUpdateMap.put(soListToUpdate[idx].Name, 'Success Update');
					}/*else{
						for(Database.Error err : uResults[idx].getErrors()){
							if(errorUpdateMap.containsKey(soListToUpdate[idx].Name)){
								string existingErr = errorUpdateMap.get(soListToUpdate[idx].Name);
								errorUpdateMap.put(soListToUpdate[idx].Name,existingErr +'-'+err.getMessage());
							}else{
								errorUpdateMap.put(soListToUpdate[idx].Name,err.getMessage());
							}
						}
					}*/
				}
			}

			genResults = JSON.createGenerator(false);

			genResults.writeStartArray();
				if(successUpdateMap.size() > 0){
					for(String suc : successUpdateMap.keySet()){
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Update');
							genResults.writeStringField('TechnicalId', mapSalesOrder.get(suc).Id);
							genResults.writeStringField('FunctionalId', suc);
							genResults.writeBooleanField('Success', true);
							genResults.writeNullField('Warning');
							genResults.writeNullField('ErrorMessage');
						genResults.writeEndObject();
					}
				}else{
					if (IsOfferUpdating)
					{
						for (Offer__c o : offerToUpdate)
						{
							genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Update');
							genResults.writeStringField('TechnicalId', o.Id);
							genResults.writeNullField('FunctionalId');
							genResults.writeBooleanField('Success', true);
							genResults.writeNullField('Warning');
							genResults.writeNullField('ErrorMessage');
							genResults.writeEndObject();
						}
						
					}else if(!noUpdate){
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Update');
							genResults.writeNullField('TechnicalId');
							genResults.writeNullField('FunctionalId');
							genResults.writeBooleanField('Success', false);
							genResults.writeStringField('Warning','No update was done in this operation.');
							genResults.writeNullField('ErrorMessage');
						genResults.writeEndObject();
					}
				}
				//DUN 13/10/2016 case 1757
				if(listSONotToUpdate.size() > 0 && noUpdate){
					for(Prerequisiteorder__c so : listSONotToUpdate){
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Update');
							genResults.writeStringField('TechnicalId',so.Id);
							genResults.writeStringField('FunctionalId',so.Name);
							genResults.writeBooleanField('Success', false);
							genResults.writeStringField('Warning','No update was done in this operation.');
							genResults.writeStringField('ErrorMessage','This sales order cannot be updated as its status is '+so.Status__c);
						genResults.writeEndObject();
					}
				}
			genResults.writeEndArray();

	        results = genResults.getAsString();
    	}catch(Exception ex){
    		genResults = JSON.createGenerator(false);
    		genResults.writeStartObject();
				genResults.writeStringField('OperationType', 'Update');
				genResults.writeNullField('TechnicalId');
				genResults.writeNullField('FunctionalId');
				genResults.writeBooleanField('Success', false);
				genResults.writeNullField('Warning');
				genResults.writeStringField('ErrorMessage','Exceptions : '+ex.getMessage());
			genResults.writeEndObject();

			results = genResults.getAsString();
    	}

		return results;
	}
	
	class PreOrder {
		public string SalesOrderId;
		public string BodyShopOrderNumber;
		public string BodyShopId; 
		public string AssessmentReference;
		public string Entity;
		public string MissionNumber;
		public string PlateNumber; 
		public string Status;
		
		public List<Offer> Offers;
	}
	
	class Offer {
		public String offerType;
		public Boolean isSelected;
		public list<OrderLine> Orders;
	}
	
	class OrderLine {
		public String OfferItemName;
		public Decimal VAT;
		public String OriginalPartType;
		public String OriginalPartDescription;
		public String OriginalPartNumber;
		public String OriginalPartManufacturer;
		public Decimal Quantity;
		public Decimal CatalogPrice;
		public Date EstimatedDeliveryDate;
		public Decimal BodyShopDiscount;
		public Decimal BodyShopPrice;
		public Decimal BodyShopTotalPrice;
		public Boolean Suppliable;
		public Boolean AcceptedByBS;
		public String BodyShopDeliveryStatus;
		public Date BodyShopDeliveryDate;
		public String Comment;

		public list<Alternative> Alternatives;
	}

	class Alternative{
		public String OfferItemName;
        public String PartType;
        public String PartDescription;
        public String PartNumber;
        public String PartManufacturer;
        public Decimal Quantity;
        public Decimal CatalogPrice;
        public Decimal CatalogTotalPrice;
        public Date EstimatedDeliveryDate;
        public Decimal BodyShopDiscount;
        public Decimal BodyShopPrice;
        public Decimal BodyShopTotalPrice;
        public Boolean Suppliable;
        public Boolean AcceptedByBS;
        public String BodyShopDeliveryStatus;
        public Date BodyShopDeliveryDate;
	}	
}