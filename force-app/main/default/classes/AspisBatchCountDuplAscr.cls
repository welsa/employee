/*
  ----------------------------------------------------------------------
  -- - Name          : AspisBatchCountDuplAscr
  -- - Author        : VSU
  -- - Description   : Batch to count number of ASCRs on impacted assessments
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  --01-JUN-2018    VSU     1.0     Initial version
  
  **********************************************************************
*/
global class AspisBatchCountDuplAscr implements Database.Batchable<AggregateResult> {

    global Iterable<AggregateResult> start(Database.BatchableContext BC){ 
      System.debug('####AspisBatchCountDuplAscr#### QueryLocator Started');
      String query = 'SELECT assessment__c ,partnumber__c,originalpart__c,count(id) countDup from Partlist__c where originalpart__c != null and partnumber__c like \'ASCR%\' and assessment__r.recordtype.developername = \'Claim\' and createddate >= 2017-09-28T00:00:00.000Z group by assessment__c ,partnumber__c,originalpart__c having count(id) > 1'; 

      return new AggregateResultIterable(query); 
    } 

    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
      System.debug('####AspisBatchCountDuplAscr#### execute Started');

      map <String,Integer> mapAssIdCountDup = new map <String,Integer> ();
      list <Assessment__c> assListToUpdate = new list <Assessment__c> (); 

      for(sObject s : scope){ 
          AggregateResult aggr = (AggregateResult) s;

          system.debug('##count: '+aggr.get('countDup'));
          system.debug('##assId: '+aggr.get('assessment__c'));
          mapAssIdCountDup.put(String.valueOf(aggr.get('assessment__c')),Integer.valueOf(aggr.get('countDup')));
      }  

      system.debug('££mapAssIdCountDup: '+mapAssIdCountDup.keyset().size());

      for(Id assId :mapAssIdCountDup.keyset()){
        Assessment__c ass = new Assessment__c(id= assId, Tech_CountDuplASCR__c = mapAssIdCountDup.get(assId));
        assListToUpdate.add(ass);
      }

      if(assListToUpdate.size() > 0){
        update assListToUpdate;
      }
       
      System.debug('####AspisBatchCountDuplAscr#### execute Ended');    
    } 

    
    global void finish(Database.BatchableContext context) {   
        System.debug('---------------------------------- START ASPISBatchSendInvoice - finish ----------------------------------');
        List<String> emailAddList = new list<String> ();

        AsyncApexJob batchJob = [   SELECT Id, TotalJobItems, CreatedBy.Email, CreatedBy.Name, ApexClass.Name 
                                    FROM AsyncApexJob
                                    WHERE Id =: context.getJobId()];

        emailAddList.add('vaynee.sungeelee@sc-mauritius.com');
                  
        sendErrorEmail(batchJob, 'AspisBatchCountDuplAscr', emailAddList);
        System.debug('---------------------------------- END ASPISBatchSendInvoice - finish ----------------------------------');
    }

    private static List<Messaging.SingleEmailMessage> outErrorEmails = null;
    public static void sendErrorEmail(AsyncApexJob a, String subject,List<String> emailAddressList){
        String emailSubject = 'AspisBatchCountDuplAscr';
        String emailBody = 'Batch info';        
                        
        outErrorEmails                          = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage l_objMail  = new Messaging.SingleEmailMessage();

        l_objMail.setToAddresses(emailAddressList);
        l_objMail.setSubject(emailSubject);
        
        l_objMail.setHtmlBody(emailBody);
        outErrorEmails.add(l_objMail);
        
        if (outErrorEmails.size() > 0) {
            Messaging.sendEmail(outErrorEmails);
        }
    }
  }