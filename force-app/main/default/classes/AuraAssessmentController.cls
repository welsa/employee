/*************************************************************************************
Class Name - AuraAssessmentController
Version - 1.0
Created Date - unknown
Function - AuraAssessmentController

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Shamina M     17/02/2016  C-001518: Removed unnecessary debug logs
*************************************************************************************/
public with sharing class AuraAssessmentController {
// ABT - Commented - 19-SEP-2016
/*
	@AuraEnabled
	public static List<Assessment__c> getAssessments() {
		return [SELECT Id, Name, CreatedDate  FROM Assessment__c ORDER BY CreatedDate Desc];
	}
    
    @AuraEnabled
    public static List<Offer__c> getOffersINACCEPTANCE(String OfferType) {     
        //return [SELECT Id, Name, Type__c, PartNUmber__c, Description__c, OfferReference__c, VAT__c, BSTotalPrice__c, Distributor__c, Prerequisiteorder__r.Name, Prerequisiteorder__r.Status__c FROM Offer__c WHERE Prerequisiteorder__r.Status__c = 'INACCEPTANCE' AND Type__c =:OfferType ORDER BY Prerequisiteorder__r.Name];
		//return [SELECT Id, Name, Type__c, PartNUmber__c, Description__c, OfferReference__c, VAT__c, BSTotalPrice__c, Distributor__c, Prerequisiteorder__r.Name, Prerequisiteorder__r.Status__c FROM Offer__c WHERE Prerequisiteorder__r.Status__c = 'INACCEPTANCE' ORDER BY Prerequisiteorder__r.Name];
        return [SELECT Id, Name, Type__c, PartNUmber__c, Description__c, OfferReference__c, VAT__c, Distributor__c, Manufacturer__c, Total__c, TotalPriceNet__c, Discount__c, BSTotalPrice__c, Price__c, Quantity__c,Prerequisiteorder__r.Name, Prerequisiteorder__r.Status__c FROM Offer__c WHERE Prerequisiteorder__r.Status__c = 'INACCEPTANCE' ORDER BY Distributor__c, Prerequisiteorder__r.Name];
    }
 
    @AuraEnabled
    public static List<Offer__c> getOffersINDELIVERY() {     
        return [SELECT Id, Name, PartNUmber__c, DeliveryStatus__c, RealDeliveryDate__c, Description__c, OfferReference__c, VAT__c, Prerequisiteorder__r.Name, Prerequisiteorder__r.Status__c FROM Offer__c WHERE Prerequisiteorder__r.Status__c IN ('INDELIVERY','DELIVERED') AND Accepted__c = 'Yes' ORDER BY Prerequisiteorder__r.Name];
    }

    @AuraEnabled
    public static String updateOfferDeliveryStatus(String OfferIdString, String SelectString, String DeliveryDateString) {
		// JS Array handler 1
        List<String> OfferIdStringList = new List<String>();
		Object[] values1 = (Object[])System.JSON.deserializeUntyped(OfferIdString);
		if(values1.size()>0){         
     		for (Object a : values1) {
         		OfferIdStringList.add(string.valueof(a) );
     		}		
 		}
		// JS Array handler 2        
        List<String> SelectStringList = new List<String>();
		Object[] values2 = (Object[])System.JSON.deserializeUntyped(SelectString);
		if(values2.size()>0){         
     		for (Object a : values2) {
         		SelectStringList.add(string.valueof(a) );
     		}		
 		}
		// JS Array handler 3        
        List<String> DeliveryDateStringList = new List<String>();
		Object[] values3 = (Object[])System.JSON.deserializeUntyped(DeliveryDateString);
		if(values3.size()>0){         
     		for (Object a : values3) {
         		DeliveryDateStringList.add(string.valueof(a) );
     		}		
 		}
        
        List<Id> OfferIdList = new List<Id>();

        //system.debug('OfferIdStringList.size() --> '+OfferIdStringList.size()); 
        
        for(integer i=0;i<OfferIdStringList.size();i++){
	        OfferIdList.add(Id.valueOf(OfferIdStringList.get(i))); //Id OfferId = Id.valueOf(OfferIdStringList.get(0));
        }
        
        List<Offer__c> updatebleOffer = [SELECT DeliveryStatus__c, RealDeliveryDate__c, PrerequisiteOrder__c FROM Offer__c WHERE Id IN:OfferIdList];
        
        for(Integer i=0;i<OfferIdStringList.size();i++) {
            updatebleOffer.get(i).DeliveryStatus__c = SelectStringList.get(i);
            if(SelectStringList.get(i)=='DELIVERED'){
                // date stored in database uses '-' and in visualforce date we're using '/' as separator...
                if(DeliveryDateStringList.get(i).contains('-')){String foo = 'bar';}
                else {
					updatebleOffer.get(i).RealDeliveryDate__c = date.parse(DeliveryDateStringList.get(i));
                }
            }
        }
        try {
            update updatebleOffer;
        }        
        catch(Exception e)
        {
            return 'Some ERROR occured!!';
        }
        
        // Sales Order updating starts
        //PrerequisiteOrder__c offersSO = [select Id, OfferType__c, Status__c from PrerequisiteOrder__c where Id=:updatebleOffer[0].PrerequisiteOrder__c LIMIT 1];
        //offersSO.Status__c = 'RESPONDED';
        //update offersSO;   
        // Sales Order updating ends
        
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String updateOffer(String OfferIdString, String CheckboxString) {

        // there is a problem of using JS Arrays with Apex, therefore this
        List<String> OfferIdStringList = new List<String>();
		Object[] values1 = (Object[])System.JSON.deserializeUntyped(OfferIdString);
		if(values1.size()>0){         
     		for (Object a : values1) {
         		OfferIdStringList.add(string.valueof(a) );
     		}		
 		}

        List<String> CheckboxStringList = new List<String>();
		Object[] values3 = (Object[])System.JSON.deserializeUntyped(CheckboxString);
		if(values3.size()>0){         
     		for (Object a : values3) {
         		CheckboxStringList.add(string.valueof(a) );
     		}		
 		}        
        List<Id> OfferIdList = new List<Id>();

        
        //system.debug('OfferIdStringList.size() --> '+OfferIdStringList.size()); 
        
        for(integer i=0;i<OfferIdStringList.size();i++){
	        OfferIdList.add(Id.valueOf(OfferIdStringList.get(i))); //Id OfferId = Id.valueOf(OfferIdStringList.get(0));
        }
        
        List<Offer__c> updatebleOffer = [SELECT Accepted__c, PrerequisiteOrder__c FROM Offer__c WHERE Id IN:OfferIdList];
        
        for(Integer i=0;i<OfferIdStringList.size();i++) {
            updatebleOffer.get(i).Accepted__c = CheckboxStringList.get(i);            
        }
        try {
            update updatebleOffer;
        }        
        catch(Exception e)
        {
            return 'Some ERROR occured!!';
        }
        
        // Sales Order updating starts
        PrerequisiteOrder__c offersSO = [select Id, OfferType__c, Status__c from PrerequisiteOrder__c where Id=:updatebleOffer[0].PrerequisiteOrder__c LIMIT 1];
        offersSO.Status__c = 'RESPONDED';
        update offersSO;   
        // Sales Order updating ends
        
        return 'SUCCESS';
    }      
    
    @AuraEnabled
    public static List<PrerequisiteOrder__c> getSalesorders() {     
        return [SELECT Id, Name FROM PrerequisiteOrder__c];
    }
    @AuraEnabled
	public static String saveAssessment(Assessment__c assessment) {
		
        try {
            upsert assessment;
        }
        //catch (Exception e) {
        //    return 'ERROR, oh no!!';
        catch(Exception e)
        {
            String errMsg = e.getMessage();
            if(errMsg.contains('duplicate value found: AssessmentID__c'))
            {
                return 'Assessment ID is not unique!';
            }

            return 'Some ERROR occured!!';
        }
		//return 'Grande SUCCESS!';
		return  String.valueOf(assessment.Id); 
	}

    @AuraEnabled
	public static String savePart(PartList__c part) {
		
        try {
            upsert part;
        }
        //catch (Exception e) {
        //    return 'ERROR, oh no!!';
        catch(Exception e)
        {

            return 'Some ERROR occured!!';
        }
		return 'Grande PARTLIST SUCCESS!';
	}

    @AuraEnabled
    public static String getAjaxTest() {     
 		return 'This is AJAX!!';        
    }
    
	*/
}