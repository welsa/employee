/*************************************************************************************
Class Name - AP30ShippingLineCreation
Version - 1.0
Created Date - 08 November 2016
Function - Class to create an order line of type shipping cost

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        	Description
* ----------    ----------  	-----------------------
* Dourga        08/11/2016  	Original Version (case 1669)
* Abdool M      05/01/2017  Case C-002161 - Changing API name from MaximumDeliveryDuration__c to MaxDeliveryDuration__c    
*************************************************************************************/
public without sharing class AP30ShippingLineCreation {
	//boolean to prevent class from running more than once
	public static boolean hasrun = false;
	//method to create Shipping line
	//public static void createShippingLine(set<Id> setPOId, set<Id> setPOdistId){
	//	System.debug('-------------------------- START METHOD AP30ShippingLineCreation - createShippingLine --------------------------');
	//	//map <BSId-DistId,DirectOrder>
	//	map<String,DirectOrder__c> mapBSDisDirectOrder = new map<String,DirectOrder__c>(); 
	//	//list<Offers>
	//	list<Offer__c> listOfferToInsert = new list<Offer__c>();
	//	//list <OderLines>
	//	list<OrderLine__c> listOLToInsert = new list<OrderLine__c>();
	//	//has run once
	//	hasrun = true;
	//	Integer maximumDeliveryDuration = 0;

	//	//looping through selected DirectOrders to build mapBSDisDirectOrder 
	//	for(DirectOrder__c dorder : [select ActiveShipping__c, BodyShop__c, Distributor__c, ShippingCostAmount__c 
	//							   from DirectOrder__c
	//							   where Distributor__c in: setPOdistId
	//							   and RecordType.DeveloperName = 'Shipping']){
	//		if(!mapBSDisDirectOrder.containsKey(dorder.BodyShop__c+ '-' +dorder.Distributor__c)){
	//			mapBSDisDirectOrder.put(dorder.BodyShop__c+ '-' +dorder.Distributor__c,dorder);
	//		}
	//	}

	//	//looping through selected Purchase Orders 
	//	for(PurchaseOrder__c po : [select Name, Distributor__r.ShippingThresholdValue__c, Assessment__r.BodyShop__c, Distributor__c, 
	//									  TotalBSAmountDelivered__c, PrerequisiteOrder__c, PrerequisiteOrder__r.OfferType__c, 
	//									  MaximumDeliveryDuration__c, PrerequisiteOrder__r.ExpectedDeliveryDateMaximum__c,
	//									  (select Id, ExpectedDeliveryDuration__c 
	//									   from OrderLines__r
	//									   where Suppliable__c = 'YES')
	//							   from PurchaseOrder__c
	//							   where Id in: setPOId]){
	//		//if BS and distributor have active shipping --> create orderline
	//		if(mapBSDisDirectOrder.containsKey(po.Assessment__r.BodyShop__c+'-'+po.Distributor__c) && 
	//		   mapBSDisDirectOrder.get(po.Assessment__r.BodyShop__c+'-'+po.Distributor__c).ActiveShipping__c){
	//		   	if(po.OrderLines__r.size() > 0){
	//		   		maximumDeliveryDuration = 0;
	//		   		for(OrderLine__c ol : po.OrderLines__r){
	//		   			if(Integer.valueOf(ol.ExpectedDeliveryDuration__c) > maximumDeliveryDuration){
	//		   				maximumDeliveryDuration = Integer.valueOf(ol.ExpectedDeliveryDuration__c);
	//		   			}
	//		   		}
	//		   	}
	//		   	OrderLine__c ol = new OrderLine__c(
 //                   partNumber__c = System.Label.ShippingCost, 
 //                   description__c = System.Label.AlphaScaleShippingCost,
 //                   purchaseOrder__c = po.id,
 //                   quantity__c = 1,
 //                   OrderType__c = 'SHIPPING COST',
 //                   ExpectedDeliveryDuration__c = String.valueOf(maximumDeliveryDuration),
 //                   EstimatedDeliveryDate__c = po.PrerequisiteOrder__r.ExpectedDeliveryDateMaximum__c,
 //                   Suppliable__c = 'YES',
 //                   AcceptedCheck__c  = true,
 //                   DeliveryStatus__c = 'INDELIVERY',
	//				TechExternalId__c = po.Name + '-' + System.Label.ShippingCost + '-' + System.Label.AlphaScaleShippingCost
 //               );
 //               //if total amout of OLs < shipping threshold --> Ol price = Shipping cost
 //               system.debug('##TotalBSAmountDelivered__c ' + po.TotalBSAmountDelivered__c);
 //               system.debug('##po.Distributor__r.ShippingThresholdValue__c ' + po.Distributor__r.ShippingThresholdValue__c);
	//			if(po.TotalBSAmountDelivered__c < po.Distributor__r.ShippingThresholdValue__c){
 //                   ol.AssessmentPrice__c = mapBSDisDirectOrder.get(po.Assessment__r.BodyShop__c+'-'+po.Distributor__c).ShippingCostAmount__c;
 //                   ol.CataloguePrice__c = mapBSDisDirectOrder.get(po.Assessment__r.BodyShop__c+'-'+po.Distributor__c).ShippingCostAmount__c;
	//			}
	//			else{				
 //                   ol.AssessmentPrice__c = 0;
 //                   ol.CataloguePrice__c = 0;
	//			}
	//			listOLToInsert.add(ol);
	//			//create offer related to the above OL
 //               listOfferToInsert.add(
 //               	new Offer__c(
	//                	PrerequisiteOrder__c = po.PrerequisiteOrder__c,
	//                	OrderLine__r = new OrderLine__c(TechExternalId__c = po.Name + '-' + System.Label.ShippingCost + '-' + System.Label.AlphaScaleShippingCost),
	//                	Type__c=po.PrerequisiteOrder__r.OfferType__c,
	//                	Accepted__c = 'YES',
	//                	Suppliable__c = true,
	//                	DeliveryStatus__c = 'INDELIVERY'
	//                )
	//            );

	//		}
	//	}

	//	if(listOLToInsert.size() > 0){
	//		insert listOLToInsert;
	//	}
	//	if(listOfferToInsert.size() > 0){
	//		insert listOfferToInsert;
	//	}
	//	System.debug('-------------------------- END METHOD AP30ShippingLineCreation - createShippingLine --------------------------');
	//}

	//method to create Shipping line V2
	public static void createShippingLine(set<Id> setSOId){
		System.debug('-------------------------- START METHOD AP30ShippingLineCreation - createShippingLine --------------------------');

		map<Id,Offer__c> mapSOIdOfferToInsert = new map<Id,Offer__c>();
		//list <OderLines>
		map<Id,OrderLine__c> mapSOIdOLToInsert = new map<Id,OrderLine__c>();

		map<String,Double> mapSOIdTotalPrice = new map<String,Double>();

		set<String> setShippingCostAccountId = new set<String>();

		map<String,CountryCodeInformationsMapping__c> mapCountryCodeInfos = CountryCodeInformationsMapping__c.getall();

		map<String,Account> mapCountryCodeShippingAccount = new map<String,Account>();

		String key = '';

		String shippingPartName;

		Account shippingAcc = new Account();

		//AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
		list<PrerequisiteOrder__c> listSalesOrders = [select Id, Assessment__r.Bodyshop__r.isEligibleShippingCost__c, Assessment__r.Bodyshop__r.ShippingPostalCodeLeft2__c, 
															 ExpectedDeliveryDateMaximum__c, OfferType__c, Assessment__r.Bodyshop__r.ContactUser__r.LanguageLocaleKey,
															 Assessment__r.Bodyshop__r.ShippingCountryCode, 
															 (select Id, Accepted__c, BSTotalPrice__c , OrderLine__r.PurchaseOrder__c
															  from Offers__r
															  where Accepted__c = 'YES'
															  and Suppliable__c = true
															  and DeliveryStatus__c = 'INDELIVERY'),
															 (select Id, Name, Distributor__r.ShippingCostRegionClassic__c, Distributor__r.ShippingCostRegionOther__c, 
															 		 Distributor__r.ShippingCostStepClassic__c, Distributor__r.ShippingCostStepOther__c, 
															 		 Distributor__r.ShippingCostValueClassic__c, Distributor__r.ShippingCostValueOther__c, 
															 		 MaxDeliveryDuration__c, Status__c
															  from PurchaseOrders__r
															  where Status__c = 'INDELIVERY')
													  from PrerequisiteOrder__c
													  where Id in: setSOId];

		for(PrerequisiteOrder__c so : listSalesOrders){
			if(mapCountryCodeInfos.containsKey(so.Assessment__r.Bodyshop__r.ShippingCountryCode) && 
			   mapCountryCodeInfos.get(so.Assessment__r.Bodyshop__r.ShippingCountryCode).AlphaScaleEntity__c != null){
				setShippingCostAccountId.add(CountryCodeInformationsMapping__c.getall().get(so.Assessment__r.Bodyshop__r.ShippingCountryCode).AlphaScaleEntity__c);
			}
			for(Offer__c off : so.Offers__r){
				if(!mapSOIdTotalPrice.containsKey(String.valueOf(so.Id))){
					mapSOIdTotalPrice.put(String.valueOf(so.Id), off.BSTotalPrice__c);
				}
				else{
					mapSOIdTotalPrice.put(String.valueOf(so.Id), mapSOIdTotalPrice.get(String.valueOf(so.Id)) + Double.valueOf(off.BSTotalPrice__c));
				}
			}
		}
		System.debug('## mapSOIdTotalPrice ' + mapSOIdTotalPrice);
		System.debug('## setShippingCostAccountId ' + setShippingCostAccountId);

		list<Account> listShippingCostAccount = [select id, ShippingCostRegionClassic__c, ShippingCostRegionOther__c, ShippingCostStepClassic__c, ShippingCostStepOther__c, 
														ShippingCostValueClassic__c, ShippingCostValueOther__c 
												 from Account
												 where id in: setShippingCostAccountId];
		System.debug('## listShippingCostAccount ' + listShippingCostAccount);

		for(Account acc : listShippingCostAccount){
			for(String couCode : mapCountryCodeInfos.keySet()){
				if(mapCountryCodeInfos.get(couCode).AlphaScaleEntity__c != null && 
				   String.valueOf(acc.Id).contains(mapCountryCodeInfos.get(couCode).AlphaScaleEntity__c) &&
				   !mapCountryCodeShippingAccount.containsKey(couCode)){
					mapCountryCodeShippingAccount.put(couCode,acc);
				}
			}
		}
		System.debug('## mapCountryCodeShippingAccount ' + mapCountryCodeShippingAccount);

		for(PrerequisiteOrder__c so : listSalesOrders){
			if(so.Assessment__r.Bodyshop__r.isEligibleShippingCost__c &&
			   mapCountryCodeShippingAccount.containsKey(so.Assessment__r.Bodyshop__r.ShippingCountryCode) &&
			   so.PurchaseOrders__r.size() > 0){
				System.debug('## so.PurchaseOrders__r ' + so.PurchaseOrders__r);
			   	shippingAcc = mapCountryCodeShippingAccount.get(so.Assessment__r.Bodyshop__r.ShippingCountryCode);
			   	shippingPartName = (so.Assessment__r.Bodyshop__r.ContactUser__r.LanguageLocaleKey == 'fr' ? 'Frais de port' : 'Shipping Cost');
				if(shippingAcc.ShippingCostRegionClassic__c != null && 
				   shippingAcc.ShippingCostRegionClassic__c.contains(so.Assessment__r.Bodyshop__r.ShippingPostalCodeLeft2__c) && 
				   mapSOIdTotalPrice.get(String.valueOf(so.Id)) < shippingAcc.ShippingCostStepClassic__c){
				   	if(!mapSOIdOLToInsert.containsKey(so.Id)){
				   		mapSOIdOLToInsert.put(so.Id, new OrderLine__c(
													                    partNumber__c = shippingPartName, 
													                    description__c = shippingPartName,
													                    purchaseOrder__c = so.PurchaseOrders__r[0].id,
													                    quantity__c = 1,
													                    OrderType__c = 'SHIPPING COST',

													                    //AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
													                    ExpectedDeliveryDuration__c = String.valueOf(so.PurchaseOrders__r[0].MaxDeliveryDuration__c),
													                    EstimatedDeliveryDate__c = so.ExpectedDeliveryDateMaximum__c,
													                    Suppliable__c = 'YES',
													                    AcceptedCheck__c  = true,
    																	AssessmentPrice__c = shippingAcc.ShippingCostValueClassic__c,
    																	CataloguePrice__c = shippingAcc.ShippingCostValueClassic__c,
													                    DeliveryStatus__c = 'INDELIVERY',
																		TechExternalId__c = so.PurchaseOrders__r[0].Name + '-' + shippingPartName
													                ));
					}
					if(!mapSOIdOfferToInsert.containsKey(so.Id)){
						mapSOIdOfferToInsert.put(so.Id, new Offer__c(
													                	PrerequisiteOrder__c = so.Id,
													                	OrderLine__r = new OrderLine__c(TechExternalId__c = so.PurchaseOrders__r[0].Name + '-' + shippingPartName),
													                	Type__c=so.OfferType__c,
													                	Accepted__c = 'YES',
													                	Suppliable__c = true,
													                	DeliveryStatus__c = 'INDELIVERY'
	                												));
					}
				}
				else if(shippingAcc.ShippingCostRegionOther__c != null && 
						shippingAcc.ShippingCostRegionOther__c.contains(so.Assessment__r.Bodyshop__r.ShippingPostalCodeLeft2__c) && 
						mapSOIdTotalPrice.get(String.valueOf(so.Id)) < shippingAcc.ShippingCostStepOther__c){

				   	if(!mapSOIdOLToInsert.containsKey(so.Id)){
				   		mapSOIdOLToInsert.put(so.Id, new OrderLine__c(
													                    partNumber__c = shippingPartName, 
													                    description__c = shippingPartName,
													                    purchaseOrder__c = so.PurchaseOrders__r[0].id,
													                    quantity__c = 1,
													                    OrderType__c = 'SHIPPING COST',

													                    //AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
													                    ExpectedDeliveryDuration__c = String.valueOf(so.PurchaseOrders__r[0].MaxDeliveryDuration__c),
													                    EstimatedDeliveryDate__c = so.ExpectedDeliveryDateMaximum__c,
													                    Suppliable__c = 'YES',
													                    AcceptedCheck__c  = true,
    																	AssessmentPrice__c = shippingAcc.ShippingCostValueOther__c,
    																	CataloguePrice__c = shippingAcc.ShippingCostValueOther__c,
													                    DeliveryStatus__c = 'INDELIVERY',
																		TechExternalId__c = so.PurchaseOrders__r[0].Name + '-' + shippingPartName
													                ));
					}
					if(!mapSOIdOfferToInsert.containsKey(so.Id)){
						mapSOIdOfferToInsert.put(so.Id, new Offer__c(
													                	PrerequisiteOrder__c = so.Id,
													                	OrderLine__r = new OrderLine__c(TechExternalId__c = so.PurchaseOrders__r[0].Name + '-' + shippingPartName),
													                	Type__c=so.OfferType__c,
													                	Accepted__c = 'YES',
													                	Suppliable__c = true,
													                	DeliveryStatus__c = 'INDELIVERY'
	                												));
					}
				}
			}
		}
		System.debug('## mapSOIdOLToInsert ' + mapSOIdOLToInsert);
		System.debug('## mapSOIdOfferToInsert ' + mapSOIdOfferToInsert);

		if(mapSOIdOLToInsert.size() > 0){
			insert mapSOIdOLToInsert.values();
		}
		if(mapSOIdOfferToInsert.size() > 0){
			insert mapSOIdOfferToInsert.values();
		}
		System.debug('-------------------------- END METHOD AP30ShippingLineCreation - createShippingLine --------------------------');
	}

	public static void updateDeliveredShippingLine(set<Id> setSOId){
		list<Offer__c> listShippingCostOffersToUpdate = new list<Offer__c>();

		for(Offer__c off : [ SELECT Id, DeliveryStatus__c, OrderType__c
							FROM	Offer__c
							WHERE	PrerequisiteOrder__c in: setSOId
							AND     OrderType__c = 'SHIPPING COST']){
			off.DeliveryStatus__c = 'DELIVERED';
        	listShippingCostOffersToUpdate.add(off);
		}

		if(listShippingCostOffersToUpdate.size() > 0){
			update listShippingCostOffersToUpdate;
		}
	}
}