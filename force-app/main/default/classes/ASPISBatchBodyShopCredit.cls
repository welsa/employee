/*************************************************************************************
Class Name - ASPISBatchBodyShopCredit
Version - 1.0
Created Date - 06 Jul 2015
Function - calculate the total amount of unpaid invoices by the body shop (status not paid ) - Credit Note Total

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Yudish R     			06/07/2015  Original Version
* Dourga U              20/08/2015  Added code to create log in catch part
* Shamina M     		16/02/2016  C-001518: Removed unnecessary debug logs
*************************************************************************************/
global class ASPISBatchBodyShopCredit implements Database.Batchable<AggregateResult> {
 
	global Iterable<AggregateResult> start(Database.batchableContext info){
		// just instantiate the new iterable here and return
		return new ASPISAggregateResultIterable();
	}

	global void execute(Database.BatchableContext BC, List<Sobject> scope){
		//System.debug('##SCOPE:' + scope);

		String invBodyShopRtId='',creditNoteBodyShopRtId='',bodyShopId;
		map<string,list<AggregateResult>> bodyShopAggrResultMap = new map<string,list<AggregateResult>>();
		double invTotalAmt = 0, creditNoteTotalAmt = 0;
		list<Account> bodyShopListToUpdate = new list<Account>();

		invBodyShopRtId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
		
		creditNoteBodyShopRtId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

		for(SObject obj:scope){
			AggregateResult ar = (AggregateResult)obj;
		
			bodyShopId = (string) ar.get('BodyShop__c');
			if(bodyShopAggrResultMap.containsKey(bodyShopId)){
				bodyShopAggrResultMap.get(bodyShopId).add(ar);
			}
			else{
				bodyShopAggrResultMap.put(bodyShopId, new list<AggregateResult>{ar});
			}
		}
		
		//loop in list to get credit amt (Total invoice- Total credit note)
		for(Id accId: bodyShopAggrResultMap.keySet()){
			invTotalAmt = 0;
			creditNoteTotalAmt = 0;
			for(AggregateResult ar1:bodyShopAggrResultMap.get(accId)){
	
				if(ar1.get('RecordTypeId') == invBodyShopRtId){
					invTotalAmt = (double) ar1.get('expr0');
				}
				else{
					creditNoteTotalAmt = (double) ar1.get('expr0');
				}
			}
			bodyShopListToUpdate.add(
				new Account(Id=accId, Credit__c = invTotalAmt - creditNoteTotalAmt)
			);
		}

		if(bodyShopListToUpdate.size()>0){
			try{
				update bodyShopListToUpdate;
			}
			catch(Exception ex){
                Utils_ManageLogs.createLogFromException('ASPISBatchBodyShopCredit', 'Account', ex);
			}
		}
	}

	global void finish(Database.BatchableContext BC){

	}  
}