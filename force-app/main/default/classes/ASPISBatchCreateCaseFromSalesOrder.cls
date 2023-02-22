/*************************************************************************************
Class Name - ASPISBatchCreateCaseFromSalesOrder
Version - 1.0
Created Date - 15 June 2015
Function - Batch to create case if on sales order 
1. la date du jour = SLA In Delivery Level 1 sur le Sales Order
2. la date du jour = SLA In Delivery Level 2 sur le Sales Order

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Brayan Nunhuck    	15/06/2015  Original Version
* Cecile L      		19/06/2015  Globalize the creation of the Case in a separate class
* Dourga Unmole			25/08/2015  Case 1195
* Shamina M             16/02/2016  C-001518: Removed unnecessary debug logs
*************************************************************************************/
global class ASPISBatchCreateCaseFromSalesOrder implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	Date dtToday;
    
    // Constant used by the automatic creation of Case
    private final Static String COUNTRYCODEDEFAULT = 'ALL'; 
    private final Static String OBJECTCODE = '-SO'; 
    private final Static String DEFAULTCONFIG = '-DEFAULT';
    private final Static String PROCESSSLA1 = '-DELIVERYCONFIRMEDSLA1';
    private final Static String PROCESSSLA2 = '-DELIVERYCONFIRMEDSLA2';
    private List <String> listStatusNotValid = new List <String>();
	
	global ASPISBatchCreateCaseFromSalesOrder() {
		dtToday =  Date.today();
		listStatusNotValid = system.Label.StatusNotValid.split(';', -2);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT SLAInDeliveryLevel1__c,SLAInDeliveryLevel2__c,TECH_BodyshopCountryCode__c,Assessment__c,BodyShop__c FROM PrerequisiteOrder__c';
		query += ' WHERE (SLAInDeliveryLevel1__c =:dtToday OR SLAInDeliveryLevel2__c=:dtToday)';
		query += 'AND Status__c NOT IN: listStatusNotValid';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<PrerequisiteOrder__c> scope) {
        //System.debug('###### CLA scope '+scope.size());
   		list<Case__c> caseListToInsert = new list<Case__c>();
        Map<String, CaseDetailsProcessMapping__c> mapCSCaseDetails = CaseDetailsProcessMapping__c.getAll();
        for(PrerequisiteOrder__c salesOrder : scope){   
			//System.debug('######### salesOrder:'+salesOrder);
            CaseDetailsProcessMapping__c cDetails;
            if(Date.Today() == salesOrder.SLAInDeliveryLevel1__c){
                //System.debug('###### CLA SLA1 ');
                Case__c caseToInsert = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, salesOrder.TECH_BodyshopCountryCode__c, salesOrder.BodyShop__c, salesOrder.Assessment__c, null, salesOrder.Id, null, UserInfo.getUserId(), PROCESSSLA1);
                if(caseToInsert!=null){
					caseListToInsert.add(caseToInsert);
				}
				
            }else if(Date.Today() == salesOrder.SLAInDeliveryLevel2__c){
               // System.debug('###### CLA SLA2 ');
                Case__c caseToInsert = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, salesOrder.TECH_BodyshopCountryCode__c, salesOrder.BodyShop__c, salesOrder.Assessment__c, null, salesOrder.Id, null, UserInfo.getUserId(), PROCESSSLA2);
                if(caseToInsert!=null){
					caseListToInsert.add(caseToInsert);
				}
            }			
		}

		if(caseListToInsert.size() > 0){
			//System.debug('########## caseListToInsert:'+caseListToInsert);
			insert caseListToInsert;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}