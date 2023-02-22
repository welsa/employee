/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchCataloguePurge
  -- - Author        : ABT
  -- - Description   : Batch to delete the cross references that are marked as isDeleted and are not referenced in part list
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 07-JUN-2017    ABT     1.0     Initial version
  ----------------------------------------------------------------------
  Execution Code:
  Database.executeBatch(new ASPISBatchCataloguePurge(), 200);
  **********************************************************************
*/
public class ASPISBatchCataloguePurge implements Database.Batchable<sObject>, Schedulable
{
    public void execute(SchedulableContext sc)
    {
        ASPISBatchCataloguePurge batch = new ASPISBatchCataloguePurge();
        Database.executeBatch(batch, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('---------------------------------- START ASPISBatchCataloguePurge - start ----------------------------------');
        
        String query =  'SELECT Id ' + 
        // String query =   'SELECT Id, ' + 
        //                  '(SELECT Id ' +
        //                  'FROM Parts_Lists__r ' + 
        //                  'LIMIT 1) ' +
                        'FROM CrossReference__c ' + 
                        'WHERE isDeleted__c = true ';

        System.debug('---------------------------------- END ASPISBatchCataloguePurge - start ----------------------------------');

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<CrossReference__c> scope)
    {
        System.debug('---------------------------------- START ASPISBatchCataloguePurge - execute ----------------------------------');

        List<CrossReference__c> crossReferenceToDeleteList = new List<CrossReference__c>();

        for(CrossReference__c currentCrossRef : [SELECT Id, 
                                                        (SELECT Id
                                                        FROM Parts_Lists__r 
                                                        LIMIT 1)
                                                 FROM   CrossReference__c 
                                                 WHERE  Id IN: scope])
        {
            // checking that there are no parts attached to the cross ref and add it to the list to delete
            if(currentCrossRef.Parts_Lists__r.isEmpty())
            {
                crossReferenceToDeleteList.add(currentCrossRef);
            }
        }

        if(crossReferenceToDeleteList.size() > 0)
        {
            delete crossReferenceToDeleteList;
        }

        System.debug('---------------------------------- END ASPISBatchCataloguePurge - execute ----------------------------------');
    }

    public void finish(Database.BatchableContext bc)
    {
        System.debug('---------------------------------- START ASPISBatchCataloguePurge - finish ----------------------------------');
        System.debug('---------------------------------- END ASPISBatchCataloguePurge - finish ----------------------------------');
    }
}