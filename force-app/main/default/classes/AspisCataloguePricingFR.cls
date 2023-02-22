/**
 * @File Name          : AspisCataloguePricingFR.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 30/07/2019, 17:39:06
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    18/07/2019, 10:27:11   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class AspisCataloguePricingFR {
/*************************************************************************************
Class Name - AspisBatchCataloguePricing for FR
Version - 1.0
Created Date - 22 FEB 2019
Function - Class to Manage AspisCataloguePricing

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L         22/02/2019  Original Version (Case-3076)
* Ruksaar L         05/03/2019  C-003037: FR - Algo for A' pricing
* Ruksaar L         05/03/2019  C-003036: France - Algo for catalog pricing for E parts
*************************************************************************************/ 


	public static String activateDistPrice (Map<Id,CrossReference__c> mapXref, string countryCode){
    	system.debug('######### start AspisCataloguePricingFR activateDistPrice');

		//Variables for FR
		map<Id, DistributorPrice__c> mapDistributorPriceFRtoUpdate = new map<Id, DistributorPrice__c>();
		String strErroredCrossRefs = '';
		map<Id,String> mapManipulatedBy = new Map<Id,String>();

		Pricing_Engine__mdt pe = AspisCataloguePricingCommon.getPricingEngine(countryCode);
		map<String, Integer> mapDistPriority = AspisCataloguePricingCommon.createPriorityMap(pe.PriorityofDistributors__c);

		set<Id> setCrossRefs = mapXref.keyset();

		Map<Id, List<DistributorPrice__c>> mapXrefDistPriceFR = new map <Id, List<DistributorPrice__c>>();

		for (DistributorPrice__c dp: [Select id, DistributorPartClass__c, DistributorPublicPrice__c, DistributorPartNumber__c, DistributorID__c,
									DistributorID__r.Name,Active__c,DIstributorPriceExtID__c, DistributorCertifyingOrganization__c ,
									CrossReference__c,DistributorDealerNetPrice__c, LastModifiedDate
									from DistributorPrice__c where isDeleted__c = false
										AND CrossReference__c IN: setCrossRefs]){
			if (dp.DIstributorPriceExtID__c != null
				&& !((dp.DIstributorPriceExtID__c).toUpperCase()).contains('DELETED')){
				if(mapXrefDistPriceFR.containskey(dp.CrossReference__c)){
					mapXrefDistPriceFR.get(dp.CrossReference__c).add(dp);		
				}
				else{
					mapXrefDistPriceFR.put(dp.CrossReference__c, new list<DistributorPrice__c>{dp});
				}
			}

		}

		for (CrossReference__c cf: mapXref.values()){

			map<String, List<DistributorPrice__c>> mapdistDistributorPrice = new map<String, List<DistributorPrice__c>>();
			map<Id,DistributorPrice__c> mapDistPriceEqPartNumber = new map<Id,DistributorPrice__c>();
			set<String> setDistributors = new set<String>();
			DistributorPrice__c mostRecentDP = null;
			//map<String, List<DistributorPrice__c>> mapDistDistributorPriceFR = new map<String, List<DistributorPrice__c>>();
			system.debug('####### cross ref: '+ cf.Id);
			if (mapXrefDistPriceFR.containskey(cf.Id)){
				
				for (DistributorPrice__c dp: mapXrefDistPriceFR.get(cf.Id)){

										
					if (dp.DistributorPartClass__c == 'E' 
						//&& dp.DistributorID__r.Name == System.Label.DistributorNameIndra
						){
						dp.Active__c = false;
						mapDistributorPriceFRtoUpdate.put(dp.Id,dp);
					}
					else if (String.isNotBlank(dp.DistributorID__c)){

						if ((mapXrefDistPriceFR.get(cf.Id)).size() > 1){
							//build map to define priority of distributors
							if (mapDistPriority.containskey(AspisCataloguePricingCommon.convertId(dp.DistributorID__c))){
								//mapDistDistributorPriceFR.put(AspisCataloguePricingCommon.convertId(dp.DistributorID__c), dp);
								setDistributors.add(AspisCataloguePricingCommon.convertId(dp.DistributorID__c));
							}

							//Define most recent Distributor Price
							if (mostRecentDP == null){
								mostRecentDP = dp;
							}
							else if (mostRecentDP != null
									&& dp.LastModifiedDate > mostRecentDP.LastModifiedDate ){
								mostRecentDP = dp;
							}

							//build map of all SAS distributor prices
							//if (AspisCataloguePricingCommon.convertId(dp.DistributorID__c) == System.Label.sas_Id){
							if (mapdistDistributorPrice.containskey(AspisCataloguePricingCommon.convertId(dp.DistributorID__c))){
								mapdistDistributorPrice.get(AspisCataloguePricingCommon.convertId(dp.DistributorID__c)).add(dp);
							}
							else{
								mapdistDistributorPrice.put(AspisCataloguePricingCommon.convertId(dp.DistributorID__c), new list<DistributorPrice__c>{dp});
							}
							//}	
						}
						else if ((mapXrefDistPriceFR.get(cf.Id)).size() == 1){
							// System.debug('@@@ got in one dist: '+dp.Name);
							dp.Active__c = True;
							System.debug('@@@ Activate 1 dp: '+dp.Id);
							mapDistributorPriceFRtoUpdate.put(dp.Id,dp);	
						}					
					}
				}//endfor distributorPrices
			}
			System.debug('@@@ setDistributors: '+setDistributors);
			System.debug('@@@ mostRecentDP: '+mostRecentDP);
			System.debug('@@@ mapdistDistributorPrice: '+mapdistDistributorPrice);

			integer highestPriority = 1000000;
			Id highestPriorityDistributor;
			if(setDistributors.size() > 0){
				for(String dist: setDistributors){
					if (mapDistPriority.containskey(dist)){
						// System.debug('@@@ mapDistPriority.get(dist): '+mapDistPriority.get(dist));
						//DistributorPrice__c distP = mapDistDistributorPriceFR.get(dist);
						//distP.Active__c = false;
						if (mapDistPriority.get(dist) <=  highestPriority){
							highestPriority = mapDistPriority.get(dist);
							highestPriorityDistributor = 	dist;
							//highestPriorityDistPrice.Active__c = True;
							System.debug('@@@ highestPriority: '+highestPriority);
							System.debug('@@@ highestPriorityDistributor: '+highestPriorityDistributor);
						}	
						
					}
				}	
			}
			System.debug('@@@ highestPriorityDistributor chosen: '+highestPriorityDistributor);

			if(mapdistDistributorPrice.size() > 0){
				For (String dist: mapdistDistributorPrice.keyset()){
					For (DistributorPrice__c dp: mapdistDistributorPrice.get(dist)){

						dp.Active__c = false;	
						System.debug('@@@ deactivate DP:'+ dp.Id);

						if (AspisCataloguePricingCommon.convertId(dist) == AspisCataloguePricingCommon.convertId(highestPriorityDistributor) )	{				
							System.debug('@@@ dp.DistributorPartNumber__c:'+dp.DistributorPartNumber__c);
							System.debug('@@@ cf.IAMPartNumber__c:'+cf.IAMPartNumber__c);
							System.debug('@@@ cf.IAMCleanPartNumber__c:'+cf.IAMCleanPartNumber__c);
							System.debug('@@@ dp.DistributorID__r.Name:'+dp.DistributorID__r.Name);

							if ((mapdistDistributorPrice.get(dist)).size() > 1){
								if((dp.DistributorID__r != null
									&& dp.DistributorID__r.Name == 'Saint Amand Service France'
									&&  (dp.DistributorPartNumber__c == cf.IAMPartNumber__c
										|| dp.DistributorPartNumber__c == cf.IAMCleanPartNumber__c))
									|| ( dp.DistributorID__r.Name != 'Saint Amand Service France' && mostRecentDP != null && dp.Id == mostRecentDP.Id	)								
									){
									dp.Active__c = true;
									System.debug('@@@ activate here 3:');

								}
							}
							else{
								dp.Active__c = true;	
								System.debug('@@@ activate here 4:');

							}
						}						
						mapDistributorPriceFRtoUpdate.put(dp.Id,dp);
					}
				}
			}
			

		}//endfor cross refs

		system.debug('@@ mapDistributorPriceFRtoUpdate: '+mapDistributorPriceFRtoUpdate);		
		if (mapDistributorPriceFRtoUpdate.size() > 0){
			List<DistributorPrice__c> lstdpsUpdate = mapDistributorPriceFRtoUpdate.values();
			List<Database.SaveResult> lstresult = Database.update(lstdpsUpdate, false);	
			integer count = 0;
			for(Database.SaveResult sr : lstresult){
				if(!sr.isSuccess()){
					// system.debug('@@ got in: '+sr);		

					//raise error
					Database.Error error = sr.getErrors().get(0);
					String errorMsg = error.getMessage();
					//system.debug('@@@ errorMsg:'+errorMsg);

					strErroredCrossRefs += (countryCode + ',' +'FR' + ',' + lstdpsUpdate[count].Id + ','+ errorMsg+'\n');
				}
				count++;
				
			}//end looping in result list
		}	

    	system.debug('######### End AspisCataloguePricingFR activateDistPrice');

		return strErroredCrossRefs;

	}

	public static String activateCrossRef (Map<Id,CrossReference__c> mapXref, String countryCode){
    	system.debug('######### start AspisCataloguePricingFR activateCrossRef');

    	Pricing_Engine__mdt pe = AspisCataloguePricingCommon.getPricingEngine(countryCode);
    	map<Id, CrossReference__c> mapCrossRefsToupdate = new map<Id, CrossReference__c>();
		String strErroredCrossRefs = '';

    	if (String.isNotBlank(pe.BatchtoActivate__c)){
    		List<String> lstBatchesActivated = AspisCataloguePricingCommon.splitConcatenated(pe.BatchtoActivate__c);
			List<String> lstActivatedParts = new list<String>();
			if(String.isNotBlank(pe.TypetoActivate__c)){
				lstActivatedParts = AspisCataloguePricingCommon.splitConcatenated(pe.TypetoActivate__c);	
			}
			set<Id> setCrossRefs = mapXref.keyset();

			Map<Id, List<DistributorPrice__c>> mapXrefDistPriceFR= new map <Id, List<DistributorPrice__c>>();

			for (DistributorPrice__c dp: [Select id, DistributorPartClass__c, DistributorPublicPrice__c, DistributorPartNumber__c, DistributorID__c,
										DistributorID__r.Name,Active__c,DistributorCertifyingOrganization__c ,
										CrossReference__c,DistributorDealerNetPrice__c
				 						from DistributorPrice__c where isDeleted__c = false
										 AND CrossReference__c IN: setCrossRefs]){
				if(mapXrefDistPriceFR.containskey(dp.CrossReference__c)){
					mapXrefDistPriceFR.get(dp.CrossReference__c).add(dp);		
				}
				else{
					mapXrefDistPriceFR.put(dp.CrossReference__c, new list<DistributorPrice__c>{dp});
				}

			}

	    	for (CrossReference__c cf: mapXref.values()){
	    		DistributorPrice__c dpToUse;

				if(mapXrefDistPriceFR.containskey(cf.Id)){
					for (DistributorPrice__c dp: mapXrefDistPriceFR.get(cf.Id)){
						//C-003037: FR - Algo for A' pricing
						if (lstBatchesActivated.contains('\'FR-APrime\'')
							&& dp.Active__c == true
							&& dp.DistributorPartClass__c == 'A'){
							dpToUse = dp;
							Break;	
						}
						
					}
				}
				
				if (dpToUse != null){
					//C-003037: FR - Algo for A' pricing
					if (lstBatchesActivated.contains('\'FR-APrime\'')
						&& dpToUse.DistributorPartClass__c == 'A'){
						System.debug('@@@ RtrocessionA__c: '+pe.RtrocessionA__c);
						System.debug('@@@ dpToUse: '+dpToUse);
						if(cf.IAMManufacturer__c == 'VW_Audi'){
							cf.ASPublicPrice__c = dpToUse.DistributorPublicPrice__c - (dpToUse.DistributorDealerNetPrice__c * (pe.RtrocessionAVW__c/100));
							cf.ASNetPrice__c = dpToUse.DistributorDealerNetPrice__c * (1- (pe.RtrocessionAVW__c/100));
						}
						else{
							cf.ASPublicPrice__c = dpToUse.DistributorPublicPrice__c - (dpToUse.DistributorDealerNetPrice__c * (pe.RtrocessionA__c/100));
							cf.ASNetPrice__c = dpToUse.DistributorDealerNetPrice__c * (1- (pe.RtrocessionA__c/100));							
						}
						cf.IAMPartClass__c = dpToUse.DistributorPartClass__c;  
						cf.IAMCertifyingOrganization__c = dpToUse.DistributorCertifyingOrganization__c;
						cf.OEMStandardDiscount__c = (1- dpToUse.DistributorDealerNetPrice__c/dpToUse.DistributorPublicPrice__c)*100;
						cf.OEMStandardDiscount__c = cf.OEMStandardDiscount__c.setScale(0, RoundingMode.HALF_UP);
						cf.OEMStandardMargin__c = cf.ASPublicPrice__c - cf.ASNetPrice__c;
						// cf.OEMStandardMargin__c = cf.OEMStandardMargin__c.setScale(0, RoundingMode.HALF_UP);
						
						if(lstActivatedParts.size() > 0
							&& lstActivatedParts.contains('A')){
							cf.ActiveForSubstitution__c = true;
							//cf.Activated_by_batch__c = 'FR-APrime';
						}
						else{
							cf.ActiveForSubstitution__c = false;
						}
						cf.ToPrice__c = false;
						cf.Manipulated_by_Batch__c = 'FR-APrime';
						
						mapCrossRefsToupdate.put(cf.Id, cf);
					}					
				}//endif use DP
				//C-003036: France - Algo for catalog pricing for E parts
				else if(lstBatchesActivated.contains('\'FR-E\'')
					// && cf.IAMPartClass__c == 'E'
					){
					cf.ASPublicPrice__c = cf.OEMPublicPrice__c * (pe.RtrocessionE__c/100);
					cf.ASNetPrice__c = cf.ASPublicPrice__c;
					cf.IAMPartClass__c = 'E';
					cf.IAMCertifyingOrganization__c = 'Réemploi';
					cf.OEMStandardMargin__c = 0;
					cf.OEMStandardDiscount__c = 0;
					if(lstActivatedParts.size() > 0
						&& lstActivatedParts.contains('E')){
						cf.ActiveForSubstitution__c = true;
						//cf.Activated_by_batch__c = 'FR-E';
					}
					else{
						cf.ActiveForSubstitution__c = false;
					}
					cf.ToPrice__c = false;
					cf.Manipulated_by_Batch__c = 'FR-E';

											
					mapCrossRefsToupdate.put(cf.Id, cf);						
				}
			}
		}
		system.debug('@@ mapCrossRefsToupdate: '+mapCrossRefsToupdate);		
		if (mapCrossRefsToupdate.size() > 0){
			List<CrossReference__c> lstCrossRefsUpdate = mapCrossRefsToupdate.values();
			List<Database.SaveResult> lstresult = Database.update(lstCrossRefsUpdate, false);
			integer count = 0;
			system.debug('@@ lstresult: '+lstresult);		

			for(Database.SaveResult sr : lstresult){
                if(!sr.isSuccess()){
					// system.debug('@@ got in: '+sr);		

                    //raise error
                    Database.Error error = sr.getErrors().get(0);
                    String errorMsg = error.getMessage();
					//system.debug('@@@ errorMsg:'+errorMsg);
					strErroredCrossRefs += (countryCode + ',' +lstCrossRefsUpdate[count].Manipulated_by_Batch__c + ',' + lstCrossRefsUpdate[count].Id + ','+ errorMsg+'\n');

                }
				count++;
                
            }//end looping in result list	
		}	
		system.debug('@@ strErroredCrossRefs: '+strErroredCrossRefs);		

    	system.debug('######### End AspisCataloguePricingFR activateCrossRef');

		return strErroredCrossRefs;

    }

	public static String scopeCrossRef (Map<Id,CrossReference__c> mapXref, string countryCode){
    	system.debug('######### start AspisCataloguePricingFR scopeCrossRef');
    	Pricing_Engine__mdt pe = AspisCataloguePricingCommon.getPricingEngine(countryCode);
		map<Id,String> mapManipulatedBy = new Map<Id,String>();
		String strErroredCrossRefs = '';
    	if (String.isNotBlank(pe.BatchtoActivate__c)){
    		List<String> lstBatchesActivated = AspisCataloguePricingCommon.splitConcatenated(pe.BatchtoActivate__c);
			system.debug('@@ lstBatchesActivated: '+lstBatchesActivated);		
			List<String> lstAllowedIamManufacturer = AspisCataloguePricingCommon.splitConcatenated(pe.IAMManufacturer_for_Scoping__c);
			system.debug('@@ lstAllowedIamManufacturer: '+lstAllowedIamManufacturer);
			List<String> lstRestrictedEBrands = AspisCataloguePricingCommon.splitConcatenated(pe.Restricted_E_Brands__c);
			system.debug('@@ lstRestrictedEBrands: '+lstRestrictedEBrands);		
			List<String> lstRestrictedABrands = AspisCataloguePricingCommon.splitConcatenated(pe.Restricted_A_Brands__c);
			system.debug('@@ lstRestrictedABrands: '+lstRestrictedABrands);	
			set<Id> setCrossRefs = mapXref.keyset();

			Map<Id, List<DistributorPrice__c>> mapXrefDistPriceFR = new map <Id, List<DistributorPrice__c>>();

			for (DistributorPrice__c dp: [Select id, DistributorPartClass__c, DistributorPublicPrice__c, DistributorPartNumber__c, DistributorID__c,
										DistributorID__r.Name,Active__c,DistributorCertifyingOrganization__c ,
										CrossReference__c,DistributorDealerNetPrice__c
				 						from DistributorPrice__c where isDeleted__c = false
										 AND CrossReference__c IN: setCrossRefs]){
				if(mapXrefDistPriceFR.containskey(dp.CrossReference__c)){
					mapXrefDistPriceFR.get(dp.CrossReference__c).add(dp);		
				}
				else{
					mapXrefDistPriceFR.put(dp.CrossReference__c, new list<DistributorPrice__c>{dp});
				}

			}

			map<Id, CrossReference__c> mapCrossRefsToupdate = new map<Id, CrossReference__c>();
			for (CrossReference__c cf: mapXref.values()){
				Boolean xRefScoped = false;
				Boolean useDistributorPrice = false;
				if (mapXrefDistPriceFR.containskey(cf.Id)){
					if (!lstRestrictedABrands.contains(cf.OEMManufacturer__c)){

						for (DistributorPrice__c dp: mapXrefDistPriceFR.get(cf.Id)){
							system.debug('@@ dp.DistributorPartClass__c: '+dp.DistributorPartClass__c);	

							//C-003037: FR - Algo for A' pricing
							if (dp.DistributorPartClass__c == 'A' && dp.Active__c == true ){
								useDistributorPrice = true;								
								break;	
							}						
						}
					}
				}
				system.debug('@@ useDistributorPrice: '+useDistributorPrice);	

				if (useDistributorPrice && cf.OEMPublicPrice__c != null){
					cf.ToPrice__c = true;
					xRefScoped = true;
					// cf.Manipulated_by_Batch__c = null;
					if (lstBatchesActivated.contains('\'FR-APrime\'')){
						mapCrossRefsToupdate.put(cf.Id, cf);
						mapManipulatedBy.put(cf.Id,'FR-APrime' );
					}

				}	
				else{
					if (lstAllowedIamManufacturer.contains(cf.IAMManufacturer__c)
						&& (!lstRestrictedEBrands.contains(cf.OEMManufacturer__c))
						&& cf.OEMPublicPrice__c != null){
							cf.ToPrice__c = true;
							xRefScoped = true;
							// cf.Manipulated_by_Batch__c = null;
							// cf.Manipulated_by_Batch__c = 'test';
							if (lstBatchesActivated.contains('\'FR-E\'')){
								mapCrossRefsToupdate.put(cf.Id, cf);
								mapManipulatedBy.put(cf.Id,'FR-E' );
							}
					}
					
				}
				system.debug('@@ xRefScoped: '+xRefScoped);						
				if (!xRefScoped && String.isNotBlank(cf.Manipulated_by_Batch__c)){
					cf.ActiveForSubstitution__c = false;
					// cf.Manipulated_by_Batch__c = null;
					mapCrossRefsToupdate.put(cf.Id, cf);
					mapManipulatedBy.put(cf.Id,'Not in Scope' );

				}
			}
			system.debug('@@ mapCrossRefsToupdate: '+mapCrossRefsToupdate);		
			
			if (mapCrossRefsToupdate.size() > 0){
				List<CrossReference__c> lstCrossRefsUpdate = mapCrossRefsToupdate.values();
				List<Database.SaveResult> lstresult = Database.update(lstCrossRefsUpdate, false);	
			
				integer count = 0;
				for(Database.SaveResult sr : lstresult){
					if(!sr.isSuccess()){
						// system.debug('@@ got in: '+sr);		

						//raise error
						Database.Error error = sr.getErrors().get(0);
						String errorMsg = error.getMessage();
						//system.debug('@@@ errorMsg:'+errorMsg);
						String maniBy = mapManipulatedBy.containsKey(lstCrossRefsUpdate[count].Id) ? mapManipulatedBy.get(lstCrossRefsUpdate[count].Id) : '';

						strErroredCrossRefs += (countryCode + ',' + maniBy + ',' + lstCrossRefsUpdate[count].Id + ','+ errorMsg+'\n');

					}
					count++;
					
				}//end looping in result list
			}	
		}
    	system.debug('######### start AspisCataloguePricingFR scopeCrossRef');

		return strErroredCrossRefs;


	}

	
}