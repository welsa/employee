/*************************************************************************************
Class Name - AP04AssessmentsAllQuoted
Version - 1.0
Created Date - 19/05/2015
Function - Class to move Assessment to offering if all purchase orders are responded

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* Joao Dias				19/05/2015  Adding Scheduling Action for ordering
* Cécile Lartaud		17/08/2015  Add the calcul of MinimumValidityDate
* Cecile Lartaud        28/08/2015  Adding support of NOTSELECTED status in allIssued, to not block the offering process
* Dourga Unmole         19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Dourga Unmole         12/02/2016  C-001522: Clarifications sur les rejets et annulations des commandes
* Dourga Unmole         08/03/2017  C-001823: Order : issue on the status after the validation by the distributor(trello no26)
* Dourga Unmole 		04/05/2018  C-002488 : Added OrderOrigin = ASPIS in condition
* Dourga Unmole 		18/09/2018  C-001895 : Spare Part Recovery 
*************************************************************************************/

public with sharing class AP04AssessmentsAllQuoted {

	private final Static String OBJECTCODE = '-ASS';
	private final Static String PROCESSDELIVERYPROBLEM = '-NotResponded';
	
	public static void assessmentsQuoted(List<PurchaseOrder__c> listPO, Map<id,PurchaseOrder__c> mapPO){
		list<Case__c> l_casesToInsert = new list<Case__c>();
		Set<ID> setParentAssIDs = new Set<ID>();
		//DUN 08/03/2017 case 1823
		map<Id,PrerequisiteOrder__c> mapSOToUpdate = new map<Id,PrerequisiteOrder__c>();
		List<PurchaseOrder__c> listPurchaseOrderToUpdate = new List<PurchaseOrder__c>();
		List<OrderLine__c> listOrderLineToUpdate = new List<OrderLine__c>();
		List<Offer__c> listOfferToUpdate = new List<Offer__c>();

		//DUN 18/09/2018 Case C-001895 : Spare Part Recovery
		map<String,CountryCodeInformationsMapping__c> mapCountryCodeInformationMapping = CountryCodeInformationsMapping__c.getall();
		set<Id> setAssIdForSpareParts = new set<Id>();

		for(PurchaseOrder__c po:listPO){
			//system.debug('#PO#'+po.name+'#'+po.status__c);
		//Creates a Set with all parent Assessments that are Issued
			//****** ASE 13/10/15: C-001272******* if((po.status__c == 'QUOTETIMEOUT' || po.status__c == 'RESPONDED' || po.status__c == 'ISSUED' || po.status__c == 'UNSUPPLIEDQUOTE' || po.status__c == 'CANCELED') && mapPO.get(po.id).status__c=='DRAFTQUOTE'){
				//DUN case 1522 changed PO status rejected to canceled
            if(((po.status__c == 'CANCELED' && po.reason__c == 'QUOTETIMEOUT') || po.status__c == 'RESPONDED' || po.status__c == 'ISSUED' || (po.status__c == 'CANCELED' && po.reason__c == 'UNSUPPLIEDQUOTE') || po.status__c == 'CANCELED') && mapPO.get(po.id).status__c=='DRAFTQUOTE'){
            	setParentAssIDs.add(po.Assessment__c);
				//system.debug('#setPaentsIDS#'+setParentAssIDs);
			}
		}
		//system.debug('#setPaentsIDS2#'+setParentAssIDs);
		List<ID> parentAssIds = new  List<ID>();
		parentAssIds.addAll(setParentAssIDs);
		//system.debug('#listparentsIDS2#'+parentAssIDs);
		//Check if all Purchase Orders of parent Assessment (apart of this PO) are Issued
        List<Assessment__c> parentAss = ASPISWithoutSharingExceptions.getAssessmentsPOChildren(setParentAssIds);
        List<Assessment__c> parentAss2Update = new List<Assessment__c>();
        //system.debug('#ParentAss#'+parentAss);
        for(Assessment__c ass: parentAss){
	        Boolean allIssued = true;
	        Boolean allTimeout = true;
	        Boolean hasPOInProgress = false;
            
            ass.MaximumValidityDate__c = null;
            ass.MinimumValidityDate__c = null;
            
	        for(PurchaseOrder__c p:ass.PurchaseOrders__r){

	        	//system.debug('#POincycleOUT#'+p.name+'#'+p.status__c);
                //****** ASE 13/10/15: C-001272******* if((p.Status__c != 'RESPONDED')&&(p.Status__c != 'ISSUED')&&(p.status__c != 'UNSUPPLIEDQUOTE')&&(p.status__c != 'CANCELED') && p.status__c != 'QUOTETIMEOUT' && p.status__c != 'NOTSELECTED' ){
                if((p.Status__c != 'RESPONDED')&&(p.Status__c != 'ISSUED')&&(p.status__c != 'REJECTED')&&(p.status__c != 'CANCELED') &&
					(p.status__c != ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE) &&
					(p.status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)){
                	//system.debug('#POincycleIN#'+p.name+'#'+p.status__c);
	        		allIssued = false;
	        		break;
	        	}
                // Find the maximum validity date of all purchase orders in ISSUED or RESPONDED status.
                if((p.Status__c == 'RESPONDED'  || p.Status__c == 'ISSUED') && (ass.MaximumValidityDate__c == null || ass.MaximumValidityDate__c < p.ValidityDate__c)){
                    ass.MaximumValidityDate__c = p.ValidityDate__c;
                }    
                // Find the minimum validity date of all purchase orders in ISSUED or RESPONDED status.
                if((p.Status__c == 'RESPONDED'  || p.Status__c == 'ISSUED') && (ass.MinimumValidityDate__c == null || ass.MinimumValidityDate__c > p.ValidityDate__c)){
                    ass.MinimumValidityDate__c = p.ValidityDate__c;
                }   
                if((p.Status__c == 'RESPONDED') || (p.Status__c == 'ISSUED')) {
                	hasPOInProgress = true;
                }     
	    	}

	    	for(PurchaseOrder__c p:ass.PurchaseOrders__r){

	        	//system.debug('#POincycleOUT#'+p.name+'#'+p.status__c);

	        	//****** ASE 13/10/15: C-001272******* if(p.status__c != 'QUOTETIMEOUT'){
	        	//DUN case 1522 changed PO status rejected to canceled
				if(!(p.status__c == 'CANCELED' && p.reason__c == 'QUOTETIMEOUT')){
                	allTimeout = false;
                	break;
                }   

            }

            if(hasPOInProgress && !allIssued && (ass.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId())){
            	ass.OrderStatus__c = 'QUOTATION IN PROGRESS';
		    	parentAss2Update.add(ass);
            }
		    system.debug('## allIssued : ' + allIssued);

		    //DUN 18/09/2018 Case C-001895 : Spare Part Recovery Added if condition 
		    if(allIssued && 
		       mapCountryCodeInformationMapping.containsKey(ass.TECH_EntityCountryCode__c) && 
		       mapCountryCodeInformationMapping.get(ass.TECH_EntityCountryCode__c).UseSparePartsRecovery__c){
    			setAssIdForSpareParts.add(ass.Id);
    		}

	    	if(!allTimeout){
		    	if(allIssued && 
		    	   (!mapCountryCodeInformationMapping.containsKey(ass.TECH_EntityCountryCode__c) ||
		    	   	(mapCountryCodeInformationMapping.containsKey(ass.TECH_EntityCountryCode__c) && 
		       		 !mapCountryCodeInformationMapping.get(ass.TECH_EntityCountryCode__c).UseSparePartsRecovery__c))){

	    			ass.Status__c = 'OFFERING';
		    		parentAss2Update.add(ass);
		    		//DUN 08/03/2017 case 1823
		    		// DUN 04/05/2018 case 2488 : Added OrderOrigin = ASPIS in condition
		    		if(ass.OrderOrigin__c == 'Order' || ass.OrderOrigin__c == 'ASPIS'){
			    		for(PurchaseOrder__c p:ass.PurchaseOrders__r){
			    			if(p.PrerequisiteOrder__c != null && (p.status__c != 'CANCELED') && (p.Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)){
			    				if(!mapSOToUpdate.containsKey(p.PrerequisiteOrder__c)){
			    					mapSOToUpdate.put(p.PrerequisiteOrder__c,new PrerequisiteOrder__c(Id = p.PrerequisiteOrder__c, Status__c = 'RESPONDED'));
			    				}
			    				// listPurchaseOrderToUpdate.add(new PurchaseOrder__c(Id=p.Id, Status__c = 'INDELIVERY'));
			    			}
			    		}   
		    	}
		    	}
	    	}else{
	    		ass.Status__c = 'NOTRESPONDED';
		    	parentAss2Update.add(ass);

		    	Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, ass.TECH_EntityCountryCode__c, ass.BodyShop__c, ass.Id, null, null, null, UserInfo.getUserId(), PROCESSDELIVERYPROBLEM);

				//System.Debug('#newCase:'+newCase);
				if(newCase!=null){
					l_casesToInsert.add(newCase);
				}
	    	}
        }

        //DUN 18/09/2018 Case C-001895 : Spare Part Recovery
        system.debug('## setAssIdForSpareParts : ' + setAssIdForSpareParts);
        if(!setAssIdForSpareParts.isEmpty()){
        	system.debug('## enter if : ' );
        	map<Id,Boolean> mapAssIdBoolLaunchOffering = AP45SparePartsRecovery.partsRecovery(setAssIdForSpareParts);
        	if(mapAssIdBoolLaunchOffering.size() > 0){
        		for(Assessment__c ass: parentAss){
	        		if(mapAssIdBoolLaunchOffering.containsKey(ass.Id) && mapAssIdBoolLaunchOffering.get(ass.Id)){
	        			ass.Status__c = 'OFFERING';
			    		parentAss2Update.add(ass);
	        		}
	        	}
        	}
        }
        
        //DUN 08/03/2017 case 1823
        // for(PrerequisiteOrder__c so : ASPISWithoutSharingExceptions.getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(new List<Id>(mapSOToUpdate.KeySet()))){
        // 	for(Offer__c off : so.Offers__r){
        //         if(off.Accepted__c == 'YES' && off.OrderLine__r.Suppliable__c == 'YES' && (off.OrderLine__r.PurchaseOrder__r.Status__c != 'CANCELED') && (off.OrderLine__r.PurchaseOrder__r.Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)){
        //             listOfferToUpdate.add(new Offer__c(Id=off.Id, DeliveryStatus__c = 'INDELIVERY'));  
        //             listOrderLineToUpdate.add(new OrderLine__c(Id=off.OrderLine__c, DeliveryStatus__c = 'INDELIVERY', AcceptedCheck__c = true));
        //         }
        //         else if(off.OrderLine__r.Suppliable__c == 'NO'){
        //             listOfferToUpdate.add(new Offer__c(Id=off.Id, /*DeliveryStatus__c = 'INPROCESS',*/ Accepted__c = 'NO', Suppliable__c = false));  
        //             listOrderLineToUpdate.add(new OrderLine__c(Id=off.OrderLine__c, /*DeliveryStatus__c = 'INPROCESS',*/ AcceptedCheck__c = false));
        //         }
        // 	}
        // }
        //Updates parent Assessments to Offering
        //system.debug('#listtoInsert#'+parentAss2Update);
        //update parentAss2Update;
        ASPISWithoutSharingExceptions.updateAssessmentList(parentAss2Update);


        //DUN 08/03/2017 case 1823
		if(listOfferToUpdate.size() > 0){
			ASPISWithoutSharingExceptions.updateOfferLineList(listOfferToUpdate);
		}

        if(mapSOToUpdate.size() > 0){
        	ASPISWithoutSharingExceptions.updatePrerequisiteOrderList(mapSOToUpdate.values());
        }

		if(listOrderLineToUpdate.size() > 0){
			update listOrderLineToUpdate;
		}

		// if(listPurchaseOrderToUpdate.size() > 0){
		// 	update listPurchaseOrderToUpdate;
		// }

        if(l_casesToInsert.size()>0){
			insert l_casesToInsert;
		}	
	}
}