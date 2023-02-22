/*************************************************************************************
Class Name - ASPISAggregateResultIterator
Version - 1.0
Created Date - unknown
Function - ....

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Shamina M     16/02/2016  C-001518: Removed unnecessary debug logs
*************************************************************************************/
global class ASPISAggregateResultIterator implements Iterator<AggregateResult> {
    AggregateResult [] results {get;set;}
    Integer index {get; set;} 

    global ASPISAggregateResultIterator() {
        index = 0;
        
		String query,invBodyShopRtId='',creditNoteBodyShopRtId='';
		string statusPaid = ASPISConstants.INV_STATUS_PAID; 

		invBodyShopRtId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
		//system.debug('##invBodyShopRtId:'+invBodyShopRtId);
		
		creditNoteBodyShopRtId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();
		//system.debug('##creditNoteBodyShopRtId:'+creditNoteBodyShopRtId);

        query = ' SELECT SUM(TotalNet__c),BodyShop__c,RecordTypeId';
		query += ' FROM Invoice__c ';
		query += ' WHERE Status__c !=:statusPaid ';
        query += ' AND BodyShop__c !=null ';
		query += ' AND (RecordTypeId =:invBodyShopRtId OR RecordTypeId =:creditNoteBodyShopRtId) ';
		query += ' Group BY BodyShop__c, RecordTypeId ';

		//System.debug('#query =' + query);	

        results = Database.query(query);  
        //System.debug('#results =' + results);          
    } 

    global boolean hasNext(){ 
       return results != null && !results.isEmpty() && index < results.size(); 
    }    

    global AggregateResult next(){ 
        return results[index++];            
    }       
}