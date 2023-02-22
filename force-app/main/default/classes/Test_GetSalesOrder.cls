/*************************************************************************************
Class Name - RESTGetSalesOrdersOffers_V1
Version - 1.0
Created Date - 06 MAY 2015
Function - Class REST to get offers

Modification Log :
-----------------------------------------------------------------------------
* Developer  	 Date       	Description
* ---------- 	 ----------  -----------------------
* Brayan Nunhuck 06/05/2015 	Original Version
* Brayan Nunhuck 22/05/2015 	V2 - Query by assessment not by offer
*************************************************************************************/
@RestResource(urlMapping='/v1.0/getSalesOrdersOffersBis/*')
global with sharing class Test_GetSalesOrder {
// ABT 10-MAY-2016 - Commented
/*
	@HttpPost
	global static void getOffers() {
		map<String,String> mapHeaders = new map<String,String>();
		map<String, list<Offer__c>> mapTypeOffer = new map<String, list<Offer__c>>();
		map<ID,map<String, list<Offer__c>>> mapSOIdMapOffer = new map<ID,map<String, list<Offer__c>>>();
		map<Id,PrerequisiteOrder__c> mapSalesOrder = new map<Id,PrerequisiteOrder__c>();
		List<Offer__c> offList = new List<Offer__c>();
		set<Id> salesOrderIdSet = new set<Id>();
		set<Id> AssessmentIdSet = new set<Id>();
		set<String> salesOrderSet = new set<String>();
		set<String> bodyShopSet = new set<String>();
		set<String> assessSet = new set<String>();
		set<String> claimSet = new set<String>();
		set<String> originalPartSet = new set<String>();
		String SalesOrderIDValue = null;
		String BodyShopReferenceValue = null;
		String AssessmentReferenceValue = null;
		String DateBeginValue = null;
		String DateEndValue = null;
		String MaxNumberOfRecordsValue = null;
		String NbRecordBeginValue = null;
		String NbRecordEndValue = null;
		String query = null;
		String results = null;
		String typeFinal = system.label.ORDERTYPEFINAL;
		JSONGenerator genResults;
		BusinessHours currBusinessHours = new BusinessHours();
		List<AllParamWrapper> paramList =  new List<AllParamWrapper>();

		try 
		{	        
			currBusinessHours = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE IsDefault=true];
			String body = RestContext.request.requestBody.toString();
			JSONParser parser = JSON.createParser(body);
            
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					while (parser.nextToken() != null) {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							//parse block of Assessment into helper class Assessment
							AllParamWrapper a = (AllParamWrapper)parser.readValueAs(AllParamWrapper.class);
							parser.skipChildren();
							//system.debug(' //params parser: ' + a);
							paramList.add(a);
						}
					}
				}
			}

			//System.debug('/// paramList: ' + paramList);

			if (paramList.size()>0){
				for (AllParamWrapper apw: paramList)
				{
					DateBeginValue = apw.DateBeginValue;
					DateEndValue = apw.DateEndValue;
					MaxNumberOfRecordsValue = apw.MaxNumberOfRecordsValue;
					NbRecordBeginValue = apw.NbRecordBeginValue;
					NbRecordEndValue = apw.NbRecordEndValue;

					if (apw.paramList.size() > 0){
						for (ParameterWrapper pw : apw.paramList)
						{
							if (pw.AssessmentReference != null && pw.AssessmentReference != '')
							{
								assessSet.add(pw.AssessmentReference);
							}

							if (pw.BodyShopReference != null && pw.BodyShopReference != '')
							{
								bodyShopSet.add(pw.BodyShopReference);

							}
						}
					}
				}
			}

			for(PrerequisiteOrder__c salesOrder : [Select Id,Assessment__c,Name,BodyShop__r.ReferenceNumber__c,
													Assessment__r.AssessmentID__c,Assessment__r.Entity__c,
													Assessment__r.MissionNumber__c,Assessment__r.PlateNumber2__c,
													Assessment__r.Status__c,MaximumValidityDate__c,MinimumValidityDate__c,Status__c,
													RecordType.DeveloperName
												   from PrerequisiteOrder__c 
												   where Assessment__r.AssessmentID__c in:assessSet])
			{
				salesOrderIdSet.add(salesOrder.Id);
				mapSalesOrder.put(salesOrder.Id,salesOrder);
			}
			
			query = 'select Id,TechOrder__c,Prerequisiteorder__c,Prerequisiteorder__r.Name, Prerequisiteorder__r.ReferenceNumber__c,Prerequisiteorder__r.BodyShop__r.ReferenceNumber__c,';
			query += 'Prerequisiteorder__r.Assessment__r.AssessmentID__c,Prerequisiteorder__r.Assessment__r.Entity__c,Prerequisiteorder__r.MaximumValidityDate__c,Prerequisiteorder__r.MinimumValidityDate__c,'; 
			query += 'Prerequisiteorder__r.Assessment__r.MissionNumber__c,Prerequisiteorder__r.Assessment__r.PlateNumber2__c,Prerequisiteorder__r.Assessment__r.Status__c,Prerequisiteorder__r.RecordType.DeveloperName,'; 
			//offer object
			query += 'Type__c,PurchaseOrder__c,Name,Accepted__c,DeliveryStatus__c,';
			query += 'Description__c,Manufacturer__c,Quantity__c,BSTotalPrice__c,OrderLine__r.ExpectedDeliveryDuration__c,';
			query += 'Total__c,ExpectedDeliveryDate__c,FinalType__c,RecordType.DeveloperName,';
			query += 'CataloguePrice__c,Discount__c,Price__c,VAT__c,OriginalType__c,OrderType__c,PartNUmber__c,';
			query += 'OriginalDescription__c,OriginalManufacturer__c,OriginalPartNumber__c,RealDeliveryDate__c,';

			//order line
			query += 'OrderLine__r.Suppliable__c,LastModifiedDate,Comment__c,';

			//bundle
			query += '(Select Id,Name,Comment__c,RealDeliveryDate__c,OrderType__c,Description__c, OriginalDescription__c, FinalType__c, CataloguePrice__c,Quantity__c,Manufacturer__c, OriginalManufacturer__c, Total__c,ExpectedDeliveryDate__c,Discount__c,Price__c,BSTotalPrice__c,OrderLine__r.Suppliable__c,Accepted__c,DeliveryStatus__c, VAT__c, Type__c, PartNUmber__c, OriginalPartNumber__c,RecordType.DeveloperName,OrderLine__r.ExpectedDeliveryDuration__c from Offers__r)';

			//from
	        query += ' from Offer__c where Prerequisiteorder__c in: salesOrderIdSet and ParentOffer__c = null'; //and OrderType__c=:typeFinal';
	        
	        if(null != BodyShopReferenceValue && '' != BodyShopReferenceValue){
	            query += ' and Prerequisiteorder__r.Assessment__r.BodyShop__c in: bodyShopSet'; 
	        }

	        if(null != DateBeginValue){
				Integer y;
				Integer m;
				Integer d;
				if(DateBeginValue.contains('-')){
					List<String> da = DateBeginValue.split('-');

					if(da.size() > 2){
						y = integer.valueOf(da[0]);
						m = integer.valueOf(da[1]);
						d = integer.valueOf(da[2]);

					}
				}

				if(y != null && m !=null && d!=null){
					datetime dtBeg = datetime.newInstance(y, m, d);
	        		query += ' and LastModifiedDate >=:dtBeg'; 
	        	}
	        }

	        if(null != DateEndValue){
	        	Integer y;
				Integer m;
				Integer d;
				if(DateEndValue.contains('-')){
					List<String> da = DateEndValue.split('-');

					if(da.size() > 2){
						y = integer.valueOf(da[0]);
						m = integer.valueOf(da[1]);
						d = integer.valueOf(da[2]);

					}
				}

				if(y != null && m !=null && d!=null){
					datetime dtEnd = datetime.newInstance(y, m, d);
	        		query += ' and LastModifiedDate <=:dtEnd ';
	        	} 
	        }
	        
	        query += ' order by Id desc limit 10000';
	        
	        if(query != null){
	        	offList = Database.query(query);
				//System.debug('/// offList: ' + offList);
	        }
	        
	        list<Offer__c> offerToBeTreatedList = new list<Offer__c>();
	        for(integer i=0; i<offList.size();i++){
				//System.debug('/// NbRecordBeginValue: ' + );
	        	if(NbRecordBeginValue != null && NbRecordBeginValue != '' && NbRecordEndValue != null && NbRecordEndValue != ''){
	        		if(i >= (integer.valueOf(NbRecordBeginValue)-1) && i <= (integer.valueOf(NbRecordEndValue)-1)){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}else if(MaxNumberOfRecordsValue != null && MaxNumberOfRecordsValue != ''){
	        		if(i <= (integer.valueOf(MaxNumberOfRecordsValue)-1)){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}else{
	        		if(i <= 100){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}
	        }

	       

	        if(offerToBeTreatedList.size() > 0){
	        	for(Offer__c off : offerToBeTreatedList){
	        		
	        		if(mapSOIdMapOffer.containsKey(off.Prerequisiteorder__c)){
	        			if(off.Type__c.contains('QUICK')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('OPPORTUNITY').add(off);
	        			}
	        		}else{

	        			map<String, list<Offer__c>> mapOfferL = new map<String, list<Offer__c>>();
				        mapOfferL.put('QUICK', new list<Offer__c>());
				        mapOfferL.put('BASIC', new list<Offer__c>());
				        mapOfferL.put('OPPORTUNITY', new list<Offer__c>());

	        			if(off.Type__c.contains('QUICK')){
	        				mapOfferL.get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapOfferL.get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapOfferL.get('OPPORTUNITY').add(off);
	        			}

	        			mapSOIdMapOffer.put(off.Prerequisiteorder__c,mapOfferL);
	        		}
	        	}
	    	}

			
	        if(offerToBeTreatedList.size() > 0){
	        	for(Offer__c off : offerToBeTreatedList){
	        		
	        		if(mapSOIdMapOffer.containsKey(off.Prerequisiteorder__c)){
	        			if(off.Type__c.contains('QUICK')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('OPPORTUNITY').add(off);
	        			}
	        		}else{

	        			map<String, list<Offer__c>> mapOfferL = new map<String, list<Offer__c>>();
				        mapOfferL.put('QUICK', new list<Offer__c>());
				        mapOfferL.put('BASIC', new list<Offer__c>());
				        mapOfferL.put('OPPORTUNITY', new list<Offer__c>());

	        			if(off.Type__c.contains('QUICK')){
	        				mapOfferL.get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapOfferL.get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapOfferL.get('OPPORTUNITY').add(off);
	        			}

	        			mapSOIdMapOffer.put(off.Prerequisiteorder__c,mapOfferL);
	        		}
	        	}
	    	}

	        

	        if(offerToBeTreatedList.size() > 0){
	        	genResults = JSON.createGenerator(false);
	        	genResults.writeStartObject();
	        	genResults.writeFieldName('SalesOrders');
	        	genResults.writeStartArray();
	        		for(Id SalesOrderId : mapSOIdMapOffer.keySet()){
		        		genResults.writeStartObject();

		        			PrerequisiteOrder__c actualSO = mapSalesOrder.get(SalesOrderId);

			                genResults.writeStringField('SalesOrderId', actualSO.Name);
			                
			                if(actualSO.BodyShop__r.ReferenceNumber__c == null)
			                genResults.writeNullField('BodyShopId');  
			                else
			                genResults.writeStringField('BodyShopId', actualSO.BodyShop__r.ReferenceNumber__c);
			                
			                if(actualSO.Assessment__r.AssessmentID__c == null)
			                genResults.writeNullField('AssessmentReference');  
			                else
			                genResults.writeStringField('AssessmentReference', actualSO.Assessment__r.AssessmentID__c);
			                
			                if(actualSO.Assessment__r.Entity__c == null)
			                genResults.writeNullField('Entity');  
			                else
			                genResults.writeStringField('Entity', actualSO.Assessment__r.Entity__c);
			                
			                if(actualSO.Assessment__r.MissionNumber__c == null)
			                genResults.writeNullField('MissionNumber');  
			                else
			                genResults.writeStringField('MissionNumber', actualSO.Assessment__r.MissionNumber__c);
			                
			                if(actualSO.Assessment__r.PlateNumber2__c == null)
			                genResults.writeNullField('PlateNumber');  
			                else
			                genResults.writeStringField('PlateNumber', actualSO.Assessment__r.PlateNumber2__c);
			                
			                if(actualSO.Assessment__r.Status__c == null)
			                genResults.writeNullField('Status');  
			                else
			                genResults.writeStringField('Status', actualSO.Status__c);
			                

			                If(mapSOIdMapOffer.get(SalesOrderId).size() > 0){
			                	genResults.writeFieldName('Offers');
					        	genResults.writeStartArray();
			                	for(String offerType : mapSOIdMapOffer.get(SalesOrderId).keySet()){

			                		if(mapSOIdMapOffer.get(SalesOrderId).get(offerType).size() > 0){

					        			genResults.writeStartObject();

						        			genResults.writeStringField('offerType', offerType);

						        			if(mapSOIdMapOffer.get(SalesOrderId).get(offerType)[0].Accepted__c == 'YES'){
							        			genResults.writeBooleanField('isSelected', true);
							        		}else{
							        			genResults.writeBooleanField('isSelected', false);
							        		}

						        			if(actualSO.MinimumValidityDate__c == null)
							                genResults.writeNullField('MaximumValidityDate');  
							                else
							                genResults.writeDateField('MaximumValidityDate', actualSO.MinimumValidityDate__c);

						                    
						                    //suppliable order
						                    genResults.writeFieldName('Orders');
						                    
						        			genResults.writeStartArray();
						                    for(Offer__c off : mapSOIdMapOffer.get(SalesOrderId).get(offerType)){
							                    genResults.writeStartObject();
					        						
								                    genResults.writeStringField('OfferItemName', off.Name);

								                    if(off.VAT__c == null)
								                    genResults.writeNullField('VAT');  
								                    else
								                    genResults.writeNumberField('VAT', off.VAT__c);

								                    if(off.FinalType__c == null)
								                    genResults.writeNullField('OriginalPartType');   
								                    else
								                    genResults.writeStringField('OriginalPartType', (off.OriginalType__c == null ? off.FinalType__c : off.OriginalType__c));

								                    if(off.Description__c == null)
								                    genResults.writeNullField('OriginalPartDescription');  
								                    else
								                    genResults.writeStringField('OriginalPartDescription', (off.OriginalDescription__c == null ? off.Description__c : off.OriginalDescription__c));

								                    //OriginalPartNumber__c
								                    if(off.PartNUmber__c == null)
								                    genResults.writeNullField('OriginalPartNumber');  
								                    else
								                    genResults.writeStringField('OriginalPartNumber', (off.OriginalPartNumber__c == null ? off.PartNUmber__c : off.OriginalPartNumber__c));
								                    if(off.OriginalPartNumber__c != null){
								                    	originalPartSet.add(off.OriginalPartNumber__c);
								                    }

								                    //OriginalManufacturer__c
								                    if(off.Manufacturer__c == null)
								                    genResults.writeNullField('OriginalPartManufacturer');  
								                    else
								                    genResults.writeStringField('OriginalPartManufacturer', (off.OriginalManufacturer__c == null ? off.Manufacturer__c : off.OriginalManufacturer__c));

								                    if(off.Quantity__c == null)
								                    genResults.writeNullField('Quantity');  
								                    else
								                    genResults.writeNumberField('Quantity', off.Quantity__c);

								                    if(off.CataloguePrice__c == null)
								                    genResults.writeNullField('CatalogPrice');  
								                    else
								                    genResults.writeNumberField('CatalogPrice', off.CataloguePrice__c);

								                    if(off.Total__c == null)
								                    genResults.writeNullField('CatalogTotalPrice');  
								                    else
								                    genResults.writeNumberField('CatalogTotalPrice', off.Total__c);
													
													if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
														
														if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
															Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
															if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																genResults.writeDateField('EstimatedDeliveryDate', targetDate);
															}else{
																
																Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																Date newBusinessD = Date.valueOf(newBusinessHourDate);
																genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
															}
														}
														
													}else{
														if(off.ExpectedDeliveryDate__c == null)
									                    genResults.writeNullField('EstimatedDeliveryDate');  
									                    else
									                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
								                	}
								                    	
								                    if(off.Discount__c == null)
								                    genResults.writeNullField('BodyShopDiscount');  
								                    else
								                    genResults.writeNumberField('BodyShopDiscount', off.Discount__c);

								                    if(off.Price__c == null)
								                    genResults.writeNullField('BodyShopPrice');  
								                    else
								                    genResults.writeNumberField('BodyShopPrice', off.Price__c);

								                    if(off.BSTotalPrice__c == null)
								                    genResults.writeNullField('BodyShopTotalPrice');  
								                    else
								                    genResults.writeNumberField('BodyShopTotalPrice', off.BSTotalPrice__c);

													
													if(off.OrderLine__r.Suppliable__c== 'YES'){
									        			genResults.writeBooleanField('Suppliable', true);
									        		}else{
									        			genResults.writeBooleanField('Suppliable', false);
									        		}
									        		
								                    if(off.Accepted__c == 'YES'){
									        			genResults.writeBooleanField('AcceptedByBS', true);
									        		}else{
									        			genResults.writeBooleanField('AcceptedByBS', false);
									        		}

									        		//DeliveryStatus__c
									        		if(off.DeliveryStatus__c == null)
								                    genResults.writeNullField('BodyShopDeliveryStatus');  
								                    else
								                    genResults.writeStringField('BodyShopDeliveryStatus', off.DeliveryStatus__c);

								                    //RealDeliveryDate__c
								                    if(off.RealDeliveryDate__c == null)
								                    genResults.writeNullField('BodyShopDeliveryDate');  
								                    else
								                    genResults.writeDateField('BodyShopDeliveryDate', off.RealDeliveryDate__c);

								                    if(off.Comment__c == null)
								                    genResults.writeNullField('Comment');  
								                    else
								                    genResults.writeStringField('Comment', off.Comment__c);

													//System.debug('/// off.Offers__r.size(): ' + off.Offers__r.size());
													//System.debug('/// off.OriginalPartNumber__c: ' + off.OriginalPartNumber__c);
								                    if(off.Offers__r.size() > 0 || off.OriginalPartNumber__c != null){
								                    	genResults.writeFieldName('Alternatives');
				        								genResults.writeStartArray();
				        									if(off.OriginalPartNumber__c != null && !originalPartSet.contains(off.PartNUmber__c)){
				        										genResults.writeStartObject();
				        											
												                    genResults.writeStringField('OfferItemName', off.Name);

												                    if(off.FinalType__c == null)
												                    genResults.writeNullField('FinalType');  
												                    else
												                    genResults.writeStringField('PartType', off.FinalType__c);

												                    if(off.Description__c == null)
												                    genResults.writeNullField('PartDescription');  
												                    else
												                    genResults.writeStringField('PartDescription', off.Description__c);

												                    if(off.PartNUmber__c == null)
												                    genResults.writeNullField('PartNumber');  
												                    else
												                    genResults.writeStringField('PartNumber', off.PartNUmber__c);

												                    if(off.Manufacturer__c == null)
												                    genResults.writeNullField('PartManufacturer');  
												                    else
												                    genResults.writeStringField('PartManufacturer', off.Manufacturer__c);

												                    if(off.Quantity__c == null)
												                    genResults.writeNullField('Quantity');  
												                    else
												                    genResults.writeNumberField('Quantity', off.Quantity__c);

												                    if(off.CataloguePrice__c == null)
												                    genResults.writeNullField('CatalogPrice');  
												                    else
												                    genResults.writeNumberField('CatalogPrice', off.CataloguePrice__c);

												                    if(off.Total__c == null)
												                    genResults.writeNullField('CatalogTotalPrice');  
												                    else
												                    genResults.writeNumberField('CatalogTotalPrice', off.Total__c);
				                                                    
				                                                    if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
																		//genResults.writeDateField('EstimatedDeliveryDate', Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c)));
																		if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
																			Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
																			if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																				genResults.writeDateField('EstimatedDeliveryDate', targetDate);
																			}else{
																				
																				Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																				Date newBusinessD = Date.valueOf(newBusinessHourDate);
																				genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
																			}
																		}
																	}else{
																		if(off.ExpectedDeliveryDate__c == null)
													                    genResults.writeNullField('EstimatedDeliveryDate');  
													                    else
													                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
												                	}
								                    
												                    if(off.Discount__c == null)
												                    genResults.writeNullField('BodyShopDiscount');  
												                    else
												                    genResults.writeNumberField('BodyShopDiscount', off.Discount__c);

												                    if(off.Price__c == null)
												                    genResults.writeNullField('BodyShopPrice');  
												                    else
												                    genResults.writeNumberField('BodyShopPrice', off.Price__c);

												                    if(off.BSTotalPrice__c == null)
												                    genResults.writeNullField('BodyShopTotalPrice');  
												                    else
												                    genResults.writeNumberField('BodyShopTotalPrice', off.BSTotalPrice__c);

												                    if(off.OrderLine__r.Suppliable__c== 'YES'){
									        							genResults.writeBooleanField('Suppliable', true);
									        						}else{
									        							genResults.writeBooleanField('Suppliable', false);
									        						}

												                    if(off.Accepted__c == 'YES'){
													        			genResults.writeBooleanField('AcceptedByBS', true);
													        		}else{
													        			genResults.writeBooleanField('AcceptedByBS', false);
													        		}

													        		//DeliveryStatus__c
													        		if(off.DeliveryStatus__c == null)
												                    genResults.writeNullField('BodyShopDeliveryStatus');  
												                    else
												                    genResults.writeStringField('BodyShopDeliveryStatus', off.DeliveryStatus__c);
				        										
												                     //RealDeliveryDate__c
												                    if(off.RealDeliveryDate__c == null)
												                    genResults.writeNullField('BodyShopDeliveryDate');  
												                    else
												                    genResults.writeDateField('BodyShopDeliveryDate', off.RealDeliveryDate__c);

												                    if(off.Comment__c == null)
												                    genResults.writeNullField('Comment');  
												                    else
												                    genResults.writeStringField('Comment', off.Comment__c);
				        										genResults.writeEndObject();
				        									}
				        									if(off.Offers__r.size() > 0){
					        									for(Offer__c offerBundle : off.Offers__r){
					        										genResults.writeStartObject();
					        											
													                    genResults.writeStringField('OfferItemName', offerBundle.Name);

													                    if(offerBundle.FinalType__c == null)
													                    genResults.writeNullField('FinalType');  
													                    else
													                    genResults.writeStringField('PartType', offerBundle.FinalType__c);

													                    if(offerBundle.Description__c == null)
													                    genResults.writeNullField('PartDescription');  
													                    else
													                    genResults.writeStringField('PartDescription', offerBundle.Description__c);

													                    if(offerBundle.PartNUmber__c == null)
													                    genResults.writeNullField('PartNumber');  
													                    else
													                    genResults.writeStringField('PartNumber', offerBundle.PartNUmber__c);

													                    if(offerBundle.Manufacturer__c == null)
													                    genResults.writeNullField('PartManufacturer');  
													                    else
													                    genResults.writeStringField('PartManufacturer', offerBundle.Manufacturer__c);

													                    if(offerBundle.Quantity__c == null)
													                    genResults.writeNullField('Quantity');  
													                    else
													                    genResults.writeNumberField('Quantity', offerBundle.Quantity__c);

													                    if(offerBundle.CataloguePrice__c == null)
													                    genResults.writeNullField('CatalogPrice');  
													                    else
													                    genResults.writeNumberField('CatalogPrice', offerBundle.CataloguePrice__c);

													                    if(offerBundle.Total__c == null)
													                    genResults.writeNullField('CatalogTotalPrice');  
													                    else
													                    genResults.writeNumberField('CatalogTotalPrice', offerBundle.Total__c);
					                                                    
					                                                    if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
					                                                    	if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
																				Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
																				if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																					genResults.writeDateField('EstimatedDeliveryDate', targetDate);
																				}else{
																					
																					Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																					Date newBusinessD = Date.valueOf(newBusinessHourDate);
																					genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
																				}
																			}
																		}else{
																			if(off.ExpectedDeliveryDate__c == null)
														                    genResults.writeNullField('EstimatedDeliveryDate');  
														                    else
														                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
													                	}
									                    
													                    if(offerBundle.Discount__c == null)
													                    genResults.writeNullField('BodyShopDiscount');  
													                    else
													                    genResults.writeNumberField('BodyShopDiscount', offerBundle.Discount__c);

													                    if(offerBundle.Price__c == null)
													                    genResults.writeNullField('BodyShopPrice');  
													                    else
													                    genResults.writeNumberField('BodyShopPrice', offerBundle.Price__c);

													                    if(offerBundle.BSTotalPrice__c == null)
													                    genResults.writeNullField('BodyShopTotalPrice');  
													                    else
													                    genResults.writeNumberField('BodyShopTotalPrice', offerBundle.BSTotalPrice__c);

													                    if(off.OrderLine__r.Suppliable__c== 'YES'){
										        							genResults.writeBooleanField('Suppliable', true);
										        						}else{
										        							genResults.writeBooleanField('Suppliable', false);
										        						}

													                    if(offerBundle.Accepted__c == 'YES'){
														        			genResults.writeBooleanField('AcceptedByBS', true);
														        		}else{
														        			genResults.writeBooleanField('AcceptedByBS', false);
														        		}

														        		//DeliveryStatus__c
														        		if(offerBundle.DeliveryStatus__c == null)
													                    genResults.writeNullField('BodyShopDeliveryStatus');  
													                    else
													                    genResults.writeStringField('BodyShopDeliveryStatus', offerBundle.DeliveryStatus__c);
					        										
													                     //RealDeliveryDate__c
													                    if(offerBundle.RealDeliveryDate__c == null)
													                    genResults.writeNullField('BodyShopDeliveryDate');  
													                    else
													                    genResults.writeDateField('BodyShopDeliveryDate', offerBundle.RealDeliveryDate__c);
					        										
													                    if(offerBundle.Comment__c == null)
													                    genResults.writeNullField('Comment');  
													                    else
													                    genResults.writeStringField('Comment', offerBundle.Comment__c);
					        										genResults.writeEndObject();
					        									}
				        									}
				        								genResults.writeEndArray();
								                    }
					        					genResults.writeEndObject();
						        			}
						        			genResults.writeEndArray();
				                		genResults.writeEndObject();
					                }
			                	}//////
			                	genResults.writeEndArray();
			                }////end if mapSOIdMapOffer.get(SalesOrderId).size() > 0

		        		genResults.writeEndObject();
	        		}
	        	genResults.writeEndArray();

	        	genResults.writeStringField('OperationType', 'Get');
				genResults.writeBooleanField('Success', true);
				genResults.writeNullField('Warning');
				genResults.writeNullField('ErrorMessage');

				genResults.writeEndObject();
	        }else{
	        	genResults = JSON.createGenerator(false);
	    		genResults.writeStartObject();
					genResults.writeStringField('OperationType', 'Get');
					genResults.writeBooleanField('Success', false);
					genResults.writeNullField('Warning');
					genResults.writeStringField('ErrorMessage', 'No Offers.');
				genResults.writeEndObject();
	        }
	       
	        results = genResults.getAsString();

	        //system.debug('/// genResults: ' + results);

		}
		catch (exception ex)
		{
			//system.debug(ex.getMessage());
    		genResults = JSON.createGenerator(false);
    		genResults.writeStartObject();
				genResults.writeStringField('OperationType', 'Get');
				genResults.writeBooleanField('Success', false); 
				genResults.writeNullField('Warning');
				genResults.writeStringField('ErrorMessage', ex.getMessage());
			genResults.writeEndObject();

			results = genResults.getAsString();
		}
		RestContext.response.responseBody = Blob.valueOf(results);
	}

	public class AllParamWrapper{
		public String DateBeginValue;
		public String DateEndValue;
		public String MaxNumberOfRecordsValue;
		public String NbRecordBeginValue;
		public String NbRecordEndValue;

		public List<ParameterWrapper> paramList;
	}

	public class ParameterWrapper{
		public String AssessmentReference;
		public String BodyShopReference;
	}
	*/
	/*@HttpGet	
	global static void getOffers() {
		map<String,String> mapHeaders = new map<String,String>();
		map<String, list<Offer__c>> mapTypeOffer = new map<String, list<Offer__c>>();
		map<ID,map<String, list<Offer__c>>> mapSOIdMapOffer = new map<ID,map<String, list<Offer__c>>>();
		map<Id,PrerequisiteOrder__c> mapSalesOrder = new map<Id,PrerequisiteOrder__c>();
		List<Offer__c> offList = new List<Offer__c>();
		set<Id> salesOrderIdSet = new set<Id>();
		set<Id> AssessmentIdSet = new set<Id>();
		set<String> salesOrderSet = new set<String>();
		set<String> bodyShopSet = new set<String>();
		set<String> assessSet = new set<String>();
		set<String> claimSet = new set<String>();
		set<String> originalPartSet = new set<String>();
		String SalesOrderIDValue = null;
		String BodyShopReferenceValue = null;
		String AssessmentReferenceValue = null;
		String DateBeginValue = null;
		String DateEndValue = null;
		String MaxNumberOfRecordsValue = null;
		String NbRecordBeginValue = null;
		String NbRecordEndValue = null;
		String query = null;
		String results = null;
		String typeFinal = system.label.ORDERTYPEFINAL;
		JSONGenerator genResults;
		BusinessHours currBusinessHours = new BusinessHours();
		

		try{
			currBusinessHours = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE IsDefault=true];
			
			RestRequest req = RestContext.request;
			mapHeaders = req.headers;
			system.debug('////mapHeaders: '+mapHeaders);
			
			//determine criteria of select on offer
			for(String header : mapHeaders.keySet()){
				
				if(header == system.label.SALESORDERID){
					SalesOrderIDValue = mapHeaders.get(header);
				}
				
				if(header == system.label.BODYSHOPREFERENCE){
					BodyShopReferenceValue = mapHeaders.get(header);
				}
				
				if(header == system.label.ASSESSMENTREFERENCE){
					AssessmentReferenceValue = mapHeaders.get(header);
				}
				
				if(header == system.label.DATEBEGIN){
					DateBeginValue = mapHeaders.get(header);
				}
				
				if(header == system.label.DATEEND){
					DateEndValue = mapHeaders.get(header);
				}
				
				if(header == system.label.MAXNUMBEROFRECORDS){
					MaxNumberOfRecordsValue = mapHeaders.get(header);
				}
				
				if(header == system.label.NBRECORDBEGIN){
					NbRecordBeginValue = mapHeaders.get(header);
				}
				
				if(header == system.label.NBRECORDEND){
					NbRecordEndValue = mapHeaders.get(header);
				}
			}
			system.debug('////// AssessmentReferenceValue: ' + AssessmentReferenceValue);

			if(SalesOrderIDValue != null){
				if(SalesOrderIDValue.contains(';')){
					for(String s : SalesOrderIDValue.split(';')){
						salesOrderSet.add(s);
					}
				}else{
					salesOrderSet.add(SalesOrderIDValue);
				}
			}

			if(BodyShopReferenceValue != null){
				if(BodyShopReferenceValue.contains(';')){
					for(String s : BodyShopReferenceValue.split(';')){
						bodyShopSet.add(s);
					}
				}else{
					bodyShopSet.add(BodyShopReferenceValue);
				}
			}

			if(AssessmentReferenceValue != null){
				if(AssessmentReferenceValue.contains(';')){
					for(String s : AssessmentReferenceValue.split(';')){
						assessSet.add(s);
					}
				}else{
					assessSet.add(AssessmentReferenceValue);
				}
			}
			system.debug('//// assessSet: ' + assessSet);


			for(PrerequisiteOrder__c salesOrder : [Select Id,Assessment__c,Name,BodyShop__r.ReferenceNumber__c,
													Assessment__r.AssessmentID__c,Assessment__r.Entity__c,
													Assessment__r.MissionNumber__c,Assessment__r.PlateNumber2__c,
													Assessment__r.Status__c,MaximumValidityDate__c,MinimumValidityDate__c,Status__c,
													RecordType.DeveloperName
												   from PrerequisiteOrder__c 
												   where Assessment__r.AssessmentID__c in:assessSet])
			{
				salesOrderIdSet.add(salesOrder.Id);
				mapSalesOrder.put(salesOrder.Id,salesOrder);
			}
			
			query = 'select Id,TechOrder__c,Prerequisiteorder__c,Prerequisiteorder__r.Name, Prerequisiteorder__r.ReferenceNumber__c,Prerequisiteorder__r.BodyShop__r.ReferenceNumber__c,';
			query += 'Prerequisiteorder__r.Assessment__r.AssessmentID__c,Prerequisiteorder__r.Assessment__r.Entity__c,Prerequisiteorder__r.MaximumValidityDate__c,Prerequisiteorder__r.MinimumValidityDate__c,'; 
			query += 'Prerequisiteorder__r.Assessment__r.MissionNumber__c,Prerequisiteorder__r.Assessment__r.PlateNumber2__c,Prerequisiteorder__r.Assessment__r.Status__c,Prerequisiteorder__r.RecordType.DeveloperName,'; 
			//offer object
			query += 'Type__c,PurchaseOrder__c,Name,Accepted__c,DeliveryStatus__c,';
			query += 'Description__c,Manufacturer__c,Quantity__c,BSTotalPrice__c,OrderLine__r.ExpectedDeliveryDuration__c,';
			query += 'Total__c,ExpectedDeliveryDate__c,FinalType__c,RecordType.DeveloperName,';
			query += 'CataloguePrice__c,Discount__c,Price__c,VAT__c,OriginalType__c,OrderType__c,PartNUmber__c,';
			query += 'OriginalDescription__c,OriginalManufacturer__c,OriginalPartNumber__c,RealDeliveryDate__c,';

			//order line
			query += 'OrderLine__r.Suppliable__c,LastModifiedDate,Comment__c,';

			//bundle
			query += '(Select Id,Name,Comment__c,RealDeliveryDate__c,OrderType__c,Description__c, OriginalDescription__c, FinalType__c, CataloguePrice__c,Quantity__c,Manufacturer__c, OriginalManufacturer__c, Total__c,ExpectedDeliveryDate__c,Discount__c,Price__c,BSTotalPrice__c,OrderLine__r.Suppliable__c,Accepted__c,DeliveryStatus__c, VAT__c, Type__c, PartNUmber__c, OriginalPartNumber__c,RecordType.DeveloperName,OrderLine__r.ExpectedDeliveryDuration__c from Offers__r)';

			//from
	        query += ' from Offer__c where Prerequisiteorder__c in: salesOrderIdSet and ParentOffer__c = null'; //and OrderType__c=:typeFinal';
	        
	        if(null != BodyShopReferenceValue && '' != BodyShopReferenceValue){
	            query += ' and Prerequisiteorder__r.Assessment__r.BodyShop__c in: bodyShopSet'; 
	        }

	        if(null != DateBeginValue){
				Integer y;
				Integer m;
				Integer d;
				if(DateBeginValue.contains('-')){
					List<String> da = DateBeginValue.split('-');

					if(da.size() > 2){
						y = integer.valueOf(da[0]);
						m = integer.valueOf(da[1]);
						d = integer.valueOf(da[2]);

					}
				}

				if(y != null && m !=null && d!=null){
					datetime dtBeg = datetime.newInstance(y, m, d);
	        		query += ' and LastModifiedDate >=:dtBeg'; 
	        	}
	        }

	        if(null != DateEndValue){
	        	Integer y;
				Integer m;
				Integer d;
				if(DateEndValue.contains('-')){
					List<String> da = DateEndValue.split('-');

					if(da.size() > 2){
						y = integer.valueOf(da[0]);
						m = integer.valueOf(da[1]);
						d = integer.valueOf(da[2]);

					}
				}

				if(y != null && m !=null && d!=null){
					datetime dtEnd = datetime.newInstance(y, m, d);
	        		query += ' and LastModifiedDate <=:dtEnd ';
	        	} 
	        }
	        
	        query += ' order by Id desc limit 10000';
	        
	        if(query != null){
	        	offList = Database.query(query);
				System.debug('/// offList: ' + offList);
	        }
	        
	        list<Offer__c> offerToBeTreatedList = new list<Offer__c>();
	        for(integer i=0; i<offList.size();i++){
				//System.debug('/// NbRecordBeginValue: ' + );
	        	if(NbRecordBeginValue != null && NbRecordEndValue != null){
	        		if(i >= (integer.valueOf(NbRecordBeginValue)-1) && i <= (integer.valueOf(NbRecordEndValue)-1)){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}else if(MaxNumberOfRecordsValue != null){
	        		if(i <= (integer.valueOf(MaxNumberOfRecordsValue)-1)){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}else{
	        		if(i <= 100){
	        			offerToBeTreatedList.add(offList[i]);
	        		}
	        	}
	        }

	       

	        if(offerToBeTreatedList.size() > 0){
	        	for(Offer__c off : offerToBeTreatedList){
	        		
	        		if(mapSOIdMapOffer.containsKey(off.Prerequisiteorder__c)){
	        			if(off.Type__c.contains('QUICK')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapSOIdMapOffer.get(off.Prerequisiteorder__c).get('OPPORTUNITY').add(off);
	        			}
	        		}else{

	        			map<String, list<Offer__c>> mapOfferL = new map<String, list<Offer__c>>();
				        mapOfferL.put('QUICK', new list<Offer__c>());
				        mapOfferL.put('BASIC', new list<Offer__c>());
				        mapOfferL.put('OPPORTUNITY', new list<Offer__c>());

	        			if(off.Type__c.contains('QUICK')){
	        				mapOfferL.get('QUICK').add(off);
	        			}

	        			if(off.Type__c.contains('BASIC')){
	        				mapOfferL.get('BASIC').add(off);
	        			}

	        			if(off.Type__c.contains('OPPORTUNITY')){
	        				mapOfferL.get('OPPORTUNITY').add(off);
	        			}

	        			mapSOIdMapOffer.put(off.Prerequisiteorder__c,mapOfferL);
	        		}
	        	}
	    	}

	        

	        if(offerToBeTreatedList.size() > 0){
	        	genResults = JSON.createGenerator(false);
	        	genResults.writeStartObject();
	        	genResults.writeFieldName('SalesOrders');
	        	genResults.writeStartArray();
	        		for(Id SalesOrderId : mapSOIdMapOffer.keySet()){
		        		genResults.writeStartObject();

		        			PrerequisiteOrder__c actualSO = mapSalesOrder.get(SalesOrderId);

			                genResults.writeStringField('SalesOrderId', actualSO.Name);
			                
			                if(actualSO.BodyShop__r.ReferenceNumber__c == null)
			                genResults.writeNullField('BodyShopId');  
			                else
			                genResults.writeStringField('BodyShopId', actualSO.BodyShop__r.ReferenceNumber__c);
			                
			                if(actualSO.Assessment__r.AssessmentID__c == null)
			                genResults.writeNullField('AssessmentReference');  
			                else
			                genResults.writeStringField('AssessmentReference', actualSO.Assessment__r.AssessmentID__c);
			                
			                if(actualSO.Assessment__r.Entity__c == null)
			                genResults.writeNullField('Entity');  
			                else
			                genResults.writeStringField('Entity', actualSO.Assessment__r.Entity__c);
			                
			                if(actualSO.Assessment__r.MissionNumber__c == null)
			                genResults.writeNullField('MissionNumber');  
			                else
			                genResults.writeStringField('MissionNumber', actualSO.Assessment__r.MissionNumber__c);
			                
			                if(actualSO.Assessment__r.PlateNumber2__c == null)
			                genResults.writeNullField('PlateNumber');  
			                else
			                genResults.writeStringField('PlateNumber', actualSO.Assessment__r.PlateNumber2__c);
			                
			                if(actualSO.Assessment__r.Status__c == null)
			                genResults.writeNullField('Status');  
			                else
			                genResults.writeStringField('Status', actualSO.Status__c);
			                

			                If(mapSOIdMapOffer.get(SalesOrderId).size() > 0){
			                	genResults.writeFieldName('Offers');
					        	genResults.writeStartArray();
			                	for(String offerType : mapSOIdMapOffer.get(SalesOrderId).keySet()){

			                		if(mapSOIdMapOffer.get(SalesOrderId).get(offerType).size() > 0){

					        			genResults.writeStartObject();

						        			genResults.writeStringField('offerType', offerType);

						        			if(mapSOIdMapOffer.get(SalesOrderId).get(offerType)[0].Accepted__c == 'YES'){
							        			genResults.writeBooleanField('isSelected', true);
							        		}else{
							        			genResults.writeBooleanField('isSelected', false);
							        		}

						        			if(actualSO.MinimumValidityDate__c == null)
							                genResults.writeNullField('MaximumValidityDate');  
							                else
							                genResults.writeDateField('MaximumValidityDate', actualSO.MinimumValidityDate__c);

						                    
						                    //suppliable order
						                    genResults.writeFieldName('Orders');
						                    
						        			genResults.writeStartArray();
						                    for(Offer__c off : mapSOIdMapOffer.get(SalesOrderId).get(offerType)){
							                    genResults.writeStartObject();
					        						
								                    genResults.writeStringField('OfferItemName', off.Name);

								                    if(off.VAT__c == null)
								                    genResults.writeNullField('VAT');  
								                    else
								                    genResults.writeNumberField('VAT', off.VAT__c);

								                    if(off.FinalType__c == null)
								                    genResults.writeNullField('OriginalPartType');   
								                    else
								                    genResults.writeStringField('OriginalPartType', (off.OriginalType__c == null ? off.FinalType__c : off.OriginalType__c));

								                    if(off.Description__c == null)
								                    genResults.writeNullField('OriginalPartDescription');  
								                    else
								                    genResults.writeStringField('OriginalPartDescription', (off.OriginalDescription__c == null ? off.Description__c : off.OriginalDescription__c));

								                    //OriginalPartNumber__c
								                    if(off.PartNUmber__c == null)
								                    genResults.writeNullField('OriginalPartNumber');  
								                    else
								                    genResults.writeStringField('OriginalPartNumber', (off.OriginalPartNumber__c == null ? off.PartNUmber__c : off.OriginalPartNumber__c));
								                    if(off.OriginalPartNumber__c != null){
								                    	originalPartSet.add(off.OriginalPartNumber__c);
								                    }

								                    //OriginalManufacturer__c
								                    if(off.Manufacturer__c == null)
								                    genResults.writeNullField('OriginalPartManufacturer');  
								                    else
								                    genResults.writeStringField('OriginalPartManufacturer', (off.OriginalManufacturer__c == null ? off.Manufacturer__c : off.OriginalManufacturer__c));

								                    if(off.Quantity__c == null)
								                    genResults.writeNullField('Quantity');  
								                    else
								                    genResults.writeNumberField('Quantity', off.Quantity__c);

								                    if(off.CataloguePrice__c == null)
								                    genResults.writeNullField('CatalogPrice');  
								                    else
								                    genResults.writeNumberField('CatalogPrice', off.CataloguePrice__c);

								                    if(off.Total__c == null)
								                    genResults.writeNullField('CatalogTotalPrice');  
								                    else
								                    genResults.writeNumberField('CatalogTotalPrice', off.Total__c);
													
													if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
														
														if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
															Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
															if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																genResults.writeDateField('EstimatedDeliveryDate', targetDate);
															}else{
																
																Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																Date newBusinessD = Date.valueOf(newBusinessHourDate);
																genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
															}
														}
														
													}else{
														if(off.ExpectedDeliveryDate__c == null)
									                    genResults.writeNullField('EstimatedDeliveryDate');  
									                    else
									                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
								                	}
								                    	
								                    if(off.Discount__c == null)
								                    genResults.writeNullField('BodyShopDiscount');  
								                    else
								                    genResults.writeNumberField('BodyShopDiscount', off.Discount__c);

								                    if(off.Price__c == null)
								                    genResults.writeNullField('BodyShopPrice');  
								                    else
								                    genResults.writeNumberField('BodyShopPrice', off.Price__c);

								                    if(off.BSTotalPrice__c == null)
								                    genResults.writeNullField('BodyShopTotalPrice');  
								                    else
								                    genResults.writeNumberField('BodyShopTotalPrice', off.BSTotalPrice__c);

													
													if(off.OrderLine__r.Suppliable__c== 'YES'){
									        			genResults.writeBooleanField('Suppliable', true);
									        		}else{
									        			genResults.writeBooleanField('Suppliable', false);
									        		}
									        		
								                    if(off.Accepted__c == 'YES'){
									        			genResults.writeBooleanField('AcceptedByBS', true);
									        		}else{
									        			genResults.writeBooleanField('AcceptedByBS', false);
									        		}

									        		//DeliveryStatus__c
									        		if(off.DeliveryStatus__c == null)
								                    genResults.writeNullField('BodyShopDeliveryStatus');  
								                    else
								                    genResults.writeStringField('BodyShopDeliveryStatus', off.DeliveryStatus__c);

								                    //RealDeliveryDate__c
								                    if(off.RealDeliveryDate__c == null)
								                    genResults.writeNullField('BodyShopDeliveryDate');  
								                    else
								                    genResults.writeDateField('BodyShopDeliveryDate', off.RealDeliveryDate__c);

								                    if(off.Comment__c == null)
								                    genResults.writeNullField('Comment');  
								                    else
								                    genResults.writeStringField('Comment', off.Comment__c);

													System.debug('/// off.Offers__r.size(): ' + off.Offers__r.size());
													System.debug('/// off.OriginalPartNumber__c: ' + off.OriginalPartNumber__c);
								                    if(off.Offers__r.size() > 0 || off.OriginalPartNumber__c != null){
								                    	genResults.writeFieldName('Alternatives');
				        								genResults.writeStartArray();
				        									if(off.OriginalPartNumber__c != null && !originalPartSet.contains(off.PartNUmber__c)){
				        										genResults.writeStartObject();
				        											
												                    genResults.writeStringField('OfferItemName', off.Name);

												                    if(off.FinalType__c == null)
												                    genResults.writeNullField('FinalType');  
												                    else
												                    genResults.writeStringField('PartType', off.FinalType__c);

												                    if(off.Description__c == null)
												                    genResults.writeNullField('PartDescription');  
												                    else
												                    genResults.writeStringField('PartDescription', off.Description__c);

												                    if(off.PartNUmber__c == null)
												                    genResults.writeNullField('PartNumber');  
												                    else
												                    genResults.writeStringField('PartNumber', off.PartNUmber__c);

												                    if(off.Manufacturer__c == null)
												                    genResults.writeNullField('PartManufacturer');  
												                    else
												                    genResults.writeStringField('PartManufacturer', off.Manufacturer__c);

												                    if(off.Quantity__c == null)
												                    genResults.writeNullField('Quantity');  
												                    else
												                    genResults.writeNumberField('Quantity', off.Quantity__c);

												                    if(off.CataloguePrice__c == null)
												                    genResults.writeNullField('CatalogPrice');  
												                    else
												                    genResults.writeNumberField('CatalogPrice', off.CataloguePrice__c);

												                    if(off.Total__c == null)
												                    genResults.writeNullField('CatalogTotalPrice');  
												                    else
												                    genResults.writeNumberField('CatalogTotalPrice', off.Total__c);
				                                                    
				                                                    if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
																		//genResults.writeDateField('EstimatedDeliveryDate', Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c)));
																		if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
																			Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
																			if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																				genResults.writeDateField('EstimatedDeliveryDate', targetDate);
																			}else{
																				
																				Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																				Date newBusinessD = Date.valueOf(newBusinessHourDate);
																				genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
																			}
																		}
																	}else{
																		if(off.ExpectedDeliveryDate__c == null)
													                    genResults.writeNullField('EstimatedDeliveryDate');  
													                    else
													                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
												                	}
								                    
												                    if(off.Discount__c == null)
												                    genResults.writeNullField('BodyShopDiscount');  
												                    else
												                    genResults.writeNumberField('BodyShopDiscount', off.Discount__c);

												                    if(off.Price__c == null)
												                    genResults.writeNullField('BodyShopPrice');  
												                    else
												                    genResults.writeNumberField('BodyShopPrice', off.Price__c);

												                    if(off.BSTotalPrice__c == null)
												                    genResults.writeNullField('BodyShopTotalPrice');  
												                    else
												                    genResults.writeNumberField('BodyShopTotalPrice', off.BSTotalPrice__c);

												                    if(off.OrderLine__r.Suppliable__c== 'YES'){
									        							genResults.writeBooleanField('Suppliable', true);
									        						}else{
									        							genResults.writeBooleanField('Suppliable', false);
									        						}

												                    if(off.Accepted__c == 'YES'){
													        			genResults.writeBooleanField('AcceptedByBS', true);
													        		}else{
													        			genResults.writeBooleanField('AcceptedByBS', false);
													        		}

													        		//DeliveryStatus__c
													        		if(off.DeliveryStatus__c == null)
												                    genResults.writeNullField('BodyShopDeliveryStatus');  
												                    else
												                    genResults.writeStringField('BodyShopDeliveryStatus', off.DeliveryStatus__c);
				        										
												                     //RealDeliveryDate__c
												                    if(off.RealDeliveryDate__c == null)
												                    genResults.writeNullField('BodyShopDeliveryDate');  
												                    else
												                    genResults.writeDateField('BodyShopDeliveryDate', off.RealDeliveryDate__c);

												                    if(off.Comment__c == null)
												                    genResults.writeNullField('Comment');  
												                    else
												                    genResults.writeStringField('Comment', off.Comment__c);
				        										genResults.writeEndObject();
				        									}
				        									if(off.Offers__r.size() > 0){
					        									for(Offer__c offerBundle : off.Offers__r){
					        										genResults.writeStartObject();
					        											
													                    genResults.writeStringField('OfferItemName', offerBundle.Name);

													                    if(offerBundle.FinalType__c == null)
													                    genResults.writeNullField('FinalType');  
													                    else
													                    genResults.writeStringField('PartType', offerBundle.FinalType__c);

													                    if(offerBundle.Description__c == null)
													                    genResults.writeNullField('PartDescription');  
													                    else
													                    genResults.writeStringField('PartDescription', offerBundle.Description__c);

													                    if(offerBundle.PartNUmber__c == null)
													                    genResults.writeNullField('PartNumber');  
													                    else
													                    genResults.writeStringField('PartNumber', offerBundle.PartNUmber__c);

													                    if(offerBundle.Manufacturer__c == null)
													                    genResults.writeNullField('PartManufacturer');  
													                    else
													                    genResults.writeStringField('PartManufacturer', offerBundle.Manufacturer__c);

													                    if(offerBundle.Quantity__c == null)
													                    genResults.writeNullField('Quantity');  
													                    else
													                    genResults.writeNumberField('Quantity', offerBundle.Quantity__c);

													                    if(offerBundle.CataloguePrice__c == null)
													                    genResults.writeNullField('CatalogPrice');  
													                    else
													                    genResults.writeNumberField('CatalogPrice', offerBundle.CataloguePrice__c);

													                    if(offerBundle.Total__c == null)
													                    genResults.writeNullField('CatalogTotalPrice');  
													                    else
													                    genResults.writeNumberField('CatalogTotalPrice', offerBundle.Total__c);
					                                                    
					                                                    if(actualSO.RecordType.DeveloperName == 'InAcceptance'){
					                                                    	if(off.OrderLine__r.ExpectedDeliveryDuration__c != null){
																				Date targetDate = Date.Today().addDays(integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c));
																				if(BusinessHours.isWithin(currBusinessHours.Id, targetDate)){
																					genResults.writeDateField('EstimatedDeliveryDate', targetDate);
																				}else{
																					
																					Datetime newBusinessHourDate = BusinessHours.nextStartDate(currBusinessHours.Id, targetDate);
																					Date newBusinessD = Date.valueOf(newBusinessHourDate);
																					genResults.writeDateField('EstimatedDeliveryDate', newBusinessD);
																				}
																			}
																		}else{
																			if(off.ExpectedDeliveryDate__c == null)
														                    genResults.writeNullField('EstimatedDeliveryDate');  
														                    else
														                    genResults.writeDateField('EstimatedDeliveryDate', off.ExpectedDeliveryDate__c);
													                	}
									                    
													                    if(offerBundle.Discount__c == null)
													                    genResults.writeNullField('BodyShopDiscount');  
													                    else
													                    genResults.writeNumberField('BodyShopDiscount', offerBundle.Discount__c);

													                    if(offerBundle.Price__c == null)
													                    genResults.writeNullField('BodyShopPrice');  
													                    else
													                    genResults.writeNumberField('BodyShopPrice', offerBundle.Price__c);

													                    if(offerBundle.BSTotalPrice__c == null)
													                    genResults.writeNullField('BodyShopTotalPrice');  
													                    else
													                    genResults.writeNumberField('BodyShopTotalPrice', offerBundle.BSTotalPrice__c);

													                    if(off.OrderLine__r.Suppliable__c== 'YES'){
										        							genResults.writeBooleanField('Suppliable', true);
										        						}else{
										        							genResults.writeBooleanField('Suppliable', false);
										        						}

													                    if(offerBundle.Accepted__c == 'YES'){
														        			genResults.writeBooleanField('AcceptedByBS', true);
														        		}else{
														        			genResults.writeBooleanField('AcceptedByBS', false);
														        		}

														        		//DeliveryStatus__c
														        		if(offerBundle.DeliveryStatus__c == null)
													                    genResults.writeNullField('BodyShopDeliveryStatus');  
													                    else
													                    genResults.writeStringField('BodyShopDeliveryStatus', offerBundle.DeliveryStatus__c);
					        										
													                     //RealDeliveryDate__c
													                    if(offerBundle.RealDeliveryDate__c == null)
													                    genResults.writeNullField('BodyShopDeliveryDate');  
													                    else
													                    genResults.writeDateField('BodyShopDeliveryDate', offerBundle.RealDeliveryDate__c);
					        										
													                    if(offerBundle.Comment__c == null)
													                    genResults.writeNullField('Comment');  
													                    else
													                    genResults.writeStringField('Comment', offerBundle.Comment__c);
					        										genResults.writeEndObject();
					        									}
				        									}
				        								genResults.writeEndArray();
								                    }
					        					genResults.writeEndObject();
						        			}
						        			genResults.writeEndArray();
				                		genResults.writeEndObject();
					                }
			                	}//////
			                	genResults.writeEndArray();
			                }////end if mapSOIdMapOffer.get(SalesOrderId).size() > 0

		        		genResults.writeEndObject();
	        		}
	        	genResults.writeEndArray();

	        	genResults.writeStringField('OperationType', 'Get');
				genResults.writeBooleanField('Success', true);
				genResults.writeNullField('Warning');
				genResults.writeNullField('ErrorMessage');

				genResults.writeEndObject();
	        }else{
	        	genResults = JSON.createGenerator(false);
	    		genResults.writeStartObject();
					genResults.writeStringField('OperationType', 'Get');
					genResults.writeBooleanField('Success', false);
					genResults.writeNullField('Warning');
					genResults.writeStringField('ErrorMessage', 'No Offers.');
				genResults.writeEndObject();
	        }
	       
	        results = genResults.getAsString();

	        system.debug('/// genResults: ' + results);
	        
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		genResults = JSON.createGenerator(false);
    		genResults.writeStartObject();
				genResults.writeStringField('OperationType', 'Get');
				genResults.writeBooleanField('Success', false); 
				genResults.writeNullField('Warning');
				genResults.writeStringField('ErrorMessage', ex.getMessage());
			genResults.writeEndObject();

			results = genResults.getAsString();
    	}

    	RestContext.response.responseBody = Blob.valueOf(results);
	}*/

	

}