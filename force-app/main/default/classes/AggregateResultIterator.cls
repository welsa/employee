/*
  ----------------------------------------------------------------------
  -- - Name          : AggregateResultIterator
  -- - Author        : VSU
  -- - Description   : 
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  --01-JUN-2018    VSU     1.0     Initial version
  
  **********************************************************************
*/
global class AggregateResultIterator Implements Iterator<AggregateResult>{ 

    AggregateResult [] results {get;set;} 
    Integer index {get;set;} 
    
    global AggregateResultIterator(String query){ 
        //String query = 'SELECT assessment__c ,partnumber__c,originalpart__c,count(id) countDup from Partlist__c where originalpart__c != null and partnumber__c like \'ASCR%\' and assessment__r.recordtype.developername = \'Claim\' and createddate >= 2017-09-28T00:00:00.000Z group by assessment__c ,partnumber__c,originalpart__c having count(id) > 1'; 
        index = 0;
        try{
          results = Database.query(query); 
          system.debug('#Query: '+ results.size());
        }
        catch(exception e){
          system.debug('#Error: '+e.getMessage());
        }
    } 
    
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 
    
    global AggregateResult next(){ 
        return results[index++]; 
    } 
}