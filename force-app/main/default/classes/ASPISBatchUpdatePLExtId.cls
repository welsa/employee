/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchUpdatePLExtId
  -- - Author        : ABT
  -- - Description   : Batch to update externalId of partList
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 07-SEP-2017    ASE     1.0     Initial version
  ----------------------------------------------------------------------
  Execution Code:
  Database.executeBatch(new ASPISBatchInvoice(), 200);
  **********************************************************************
*/
public class ASPISBatchUpdatePLExtId implements Database.Batchable<sObject>, Schedulable
{
    public void execute(SchedulableContext sc){
        ASPISBatchUpdatePLExtId batch = new ASPISBatchUpdatePLExtId();
        Database.executeBatch(batch, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('---------------------------------- START ASPISBatchUpdatePLExtId - start ----------------------------------');

        list<String> dates = system.label.MigrationBatchDateRange.split(':');
        Date SD = Date.parse(dates[0]);
        Datetime startDate = Datetime.newInstanceGMT(SD.year(), SD.month(),SD.day(),0,0,0);

        Date ED = Date.parse(dates[1]);
        Datetime endDate = Datetime.newInstanceGMT(ED.year(), ED.month(),ED.day(),0,0,0);

        system.debug('## startDate: '+startDate);
        system.debug('## endDate: '+endDate);
        String query =  'SELECT TECH_OriginalPart__c, Id FROM PartList__c WHERE assessment__r.CreatedDate > :startDate and Assessment__r.CreatedDate < :endDate and Assessment__r.RecordType.Name != \'NewAssessment\' and Assessment__r.RecordType.Name != \'Claim Order\' and assessment__r.TECH_EntityCountryCode__c=\'FR\' and TECH_OriginalPart__c != null';


        System.debug('---------------------------------- END ASPISBatchUpdatePLExtId - start ----------------------------------');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<PartList__c> scope){
        System.debug('---------------------------------- START ASPISBatchUpdatePLExtId - execute ----------------------------------');

        list <PartList__c> updatedPLList = new list <PartList__c>();

        for (PartList__c pl :  scope){
            updatedPLList.add(new PartList__c(Id = pl.Id, TECH_OriginalPart__c = (pl.TECH_OriginalPart__c).toUpperCase()));
        }
        system.debug('## updatedPLList:'+updatedPLList);
        update updatedPLList;

        System.debug('---------------------------------- END ASPISBatchUpdatePLExtId - execute ----------------------------------');
    }

    public void finish(Database.BatchableContext bc){
        System.debug('---------------------------------- START ASPISBatchUpdatePLExtId - finish ----------------------------------');

        System.debug('---------------------------------- END ASPISBatchUpdatePLExtId - finish ----------------------------------');
    }
}