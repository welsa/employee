public without sharing class RestUpsertAssessmentPricingAlgo {
/****************************************************************************
Class Name - RestUpsertAssessmentPricingAlgo
Function   - Dynamically apply different pricing algo for different entity
		   - (C-002041 - Distributor V2)

Modification Log :
-----------------------------------------------------------------------------  
* Developer      Date           Description
* -------------- ----------     -----------------------
* Abdool M       20/02/2018     Initial Version
* Ashwina S      28/05/2018 	changes in calculations
* Ruksaar L      28/04/2020     Case 3695: Subject	IG - IGP Substitution part
*****************************************************************************/
	public static map <string,object> returnUpdatedPrices(map <string,object> inputParamForPriceCalc){
		system.debug('## Start returnUpdatedPrices');

		//map <string,object> definition :
		//---------------values perternaing to ASP---------------//
		//entity 				--> hold country where specific algo should be applied
		//discount				--> contains values based on either rebate (from distributor) or AlphaScaleDiscountAdditional (from ws response)
		//CatalogPrice			--> catalogue price transmitted during ws reponse
		//AlphaScaleDiscount 	--> AlphaScaleDiscount transmitted during ws reponse
		//ASNETPRICE			--> ASNETPRICE calculated
		//price 				--> price calculated
		
		//---------------values perternaing to OEM Parts (original info if need to be updated)---------------//
		//oemStdDiscount		--> hold calculated discount for OEM parts
		//oemStdMargin			--> hold calculated margin for OEM parts

		//object containing updated price
		map <string,object> response = new map <string,object>();
		// system.debug('## inputParamForPriceCalc:'+inputParamForPriceCalc);

		//get entity info
		string country = inputParamForPriceCalc.containsKey('entity') ? (string)inputParamForPriceCalc.get('entity') : '';
    	//RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
		Boolean isIG = inputParamForPriceCalc.containsKey('isIG') ? (Boolean)inputParamForPriceCalc.get('isIG') :false;
		// system.debug('@@ isIG'+isIG);

		//---------------Start Pricing Algo For France---------------//
		
		if(country == 'fr'){
			//get discount info
			decimal discount = inputParamForPriceCalc.containsKey('discount') ? (decimal)inputParamForPriceCalc.get('discount') : 0.0;

			//get CatalogPrice
			decimal CatalogPrice = inputParamForPriceCalc.containsKey('CatalogPrice') ? (decimal)inputParamForPriceCalc.get('CatalogPrice') : 0.0;

			//get alpha scale discount
			decimal AlphaScaleDiscount = inputParamForPriceCalc.containsKey('AlphaScaleDiscount') ? (decimal)inputParamForPriceCalc.get('AlphaScaleDiscount') : 0.0;

			//RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
			decimal keepAXAorNONAXA = inputParamForPriceCalc.containsKey('keepAXAorNONAXA') ? (decimal)inputParamForPriceCalc.get('keepAXAorNONAXA') : 0.0;

			if(CatalogPrice > 0){
				decimal oemStdDiscount;
				decimal oemStdMargin ;
				decimal asPublicPrice;
				decimal ASNETPRICE;
				decimal aspStdDiscount;
				decimal aspStdMargin; 

    			//RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part				
				if (isIG){
					// system.debug('@@ isIG');

					oemStdDiscount = AlphaScaleDiscount;  

					oemStdMargin = CatalogPrice * (AlphaScaleDiscount/100);

					asPublicPrice = CatalogPrice - (CatalogPrice * discount);

					ASNETPRICE = asPublicPrice - (asPublicPrice * (AlphaScaleDiscount/100));					

					aspStdMargin =  asPublicPrice - ASNETPRICE; 

					aspStdDiscount = (aspStdMargin/asPublicPrice)*100;

				}
				else{
				//calc asnet price for ASP
					if (keepAXAorNONAXA != 0.0){
						ASNETPRICE = CatalogPrice  * (1 - (AlphaScaleDiscount/100))  * (1- (discount * (1-keepAXAorNONAXA)));
						asPublicPrice = CatalogPrice - (CatalogPrice  * (1 - (AlphaScaleDiscount/100))  * (discount * (1-KeepAXAOrNonAXA)));
					}
					else{
					ASNETPRICE = CatalogPrice  * (1 - (AlphaScaleDiscount/100))  * (1- (discount));
						asPublicPrice = CatalogPrice - (CatalogPrice  * (1 - (AlphaScaleDiscount/100))  * discount);
					}
					
					// system.debug('## ASNETPRICE ' + ASNETPRICE);
				//calc price for ASP
				/*********ASE : 28/05/2018 : changes in calculations*/
				//decimal price = CatalogPrice - ASNETPRICE * (discount);
					
					// system.debug('## previous asPublicPrice * (discount): ' + (CatalogPrice - ASNETPRICE * (discount)));
					// system.debug('## asPublicPrice ' + asPublicPrice);			
				

				//Update std discount and margin for OEM parts
                //decimal oemStdDiscount = (1 - (ASNETPRICE/price)) * 100;  
                //decimal oemStdMargin = price - ASNETPRICE;

					oemStdDiscount = AlphaScaleDiscount;  
					oemStdMargin = CatalogPrice * (AlphaScaleDiscount/100);
                
                //Update std discount and margin for ASP parts
					aspStdDiscount =(1 - (ASNETPRICE / asPublicPrice))*100;
					aspStdMargin =  asPublicPrice - ASNETPRICE; 
				}
				

                /*********/
                //add to response
                response.put('ASNETPRICE',ASNETPRICE); 
                response.put('asPublicPrice', asPublicPrice);
                response.put('oemStdDiscount', oemStdDiscount);
                response.put('oemStdMargin', oemStdMargin);
                response.put('aspStdDiscount', aspStdDiscount);
                response.put('aspStdMargin',aspStdMargin);
			}//end if CatalogPrice > 0 && AlphaScaleDiscount > 0
		}//end country == 'fr'
		// system.debug('## response RestUpsertAssessmentPricingAlgo' + response);
		

		//---------------End Pricing Algo For France---------------//					

		system.debug('## End returnUpdatedPrices');
		return response;
	}

     //RLA 09/07/2020 C-003857: IG - Creation IGO 
	public static map <string,object> returnUpdatedPricesOEMConnected(map <string,object> inputParamForPriceCalc){
		system.debug('## Start returnUpdatedPricesOEMConnected');

		//map <string,object> definition :
		//---------------values perternaing to ASP---------------//
		//entity 				--> hold country where specific algo should be applied
		//discount				--> contains values based on either rebate (from distributor) or AlphaScaleDiscountAdditional (from ws response)
		//CatalogPrice			--> catalogue price transmitted during ws reponse
		//AlphaScaleDiscount 	--> AlphaScaleDiscount transmitted during ws reponse
		//ASNETPRICE			--> ASNETPRICE calculated
		//price 				--> price calculated
		

		//object containing updated price
		map <string,object> response = new map <string,object>();
		system.debug('## inputParamForPriceCalc:'+inputParamForPriceCalc);

		//get entity info
		string country = inputParamForPriceCalc.containsKey('entity') ? (string)inputParamForPriceCalc.get('entity') : '';
    	//RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
		Boolean isIG = inputParamForPriceCalc.containsKey('isIG') ? (Boolean)inputParamForPriceCalc.get('isIG') :false;
		// system.debug('@@ isIG'+isIG);

		//---------------Start Pricing Algo For France---------------//
		
		
		
		//get CatalogPrice
		decimal CatalogPrice = inputParamForPriceCalc.containsKey('CatalogPrice') ? (decimal)inputParamForPriceCalc.get('CatalogPrice') : 0.0;

		//get alpha scale discount
		decimal AlphaScaleDiscount = inputParamForPriceCalc.containsKey('AlphaScaleDiscount') ? (decimal)inputParamForPriceCalc.get('AlphaScaleDiscount') : 0.0;

		if(CatalogPrice > 0){
			decimal oemStdDiscount;
			decimal oemStdMargin ;
			decimal asPublicPrice;
			decimal ASNETPRICE;
			decimal aspStdDiscount;
			decimal aspStdMargin; 

			//RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part				
			if (isIG){
				// system.debug('@@ isIG');

				asPublicPrice = CatalogPrice;

				ASNETPRICE = asPublicPrice - (asPublicPrice * (AlphaScaleDiscount/100));					

				aspStdMargin =  (asPublicPrice * (AlphaScaleDiscount/100)); 

				aspStdDiscount = AlphaScaleDiscount;

			}
			
			

			/*********/
			//add to response
			response.put('ASNETPRICE',ASNETPRICE); 
			response.put('asPublicPrice', asPublicPrice);
			response.put('aspStdDiscount', aspStdDiscount);
			response.put('aspStdMargin',aspStdMargin);
		}//end if CatalogPrice > 0 && AlphaScaleDiscount > 0
	
		system.debug('## response RestUpsertAssessmentPricingAlgo' + response);
		

		//---------------End Pricing Algo For France---------------//					

		system.debug('## End returnUpdatedPrices');
		return response;
	}
}