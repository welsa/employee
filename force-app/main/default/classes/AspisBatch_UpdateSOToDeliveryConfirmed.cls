global class AspisBatch_UpdateSOToDeliveryConfirmed implements Database.Batchable<sObject>,Database.Stateful{ 
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_UpdateSOToDeliveryConfirmed
-- - Author        : AMI 
-- - Description   : Update SO to delivery confirmed if status has remained in Managed 
-- -               : for more than X days (X defined in custom label AdvanceCaseMgtSLA)
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 10-OCT-2018  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/  
    /*//set updated SO so that latter is not updated twice
    global set <id> alreadyUpdatedSO                                             = new set <id>();*/

    //dml status list for offers updated
    global list <string> offerStatusUpdate                                       = new list <string>();

    /*//dml status list for contact created
    global list <string> SOStatusUpdate                                          = new list <string>();*/

    //boolean to detect any issues during batch processing to determine email subject
    global boolean err                                                           = false;

    //business hour id
    global string busHoursId                                                     = '';

    //sla defined in custom label for advance case mgt
    global long slaDelayInMilliSec                                               = null;

    //filter criteria to limit number of records returned in select
    global integer lastNDays                                                     = 20;

    global AspisBatch_UpdateSOToDeliveryConfirmed(){
        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Constructor - Start');

        //query business hour id
        for(BusinessHours bs : [select Id
                                    from BusinessHours
                                    where Name = :ASPISConstants.spainBusinessHour
                                    and IsActive = true]){
            busHoursId                                                          = bs.Id;
        }

        //set sla and last n days filter criteria
        if(string.isNotBlank(system.label.AdvanceCaseMgtSLA)){
            slaDelayInMilliSec                                                   = integer.valueOf(system.label.AdvanceCaseMgtSLA) * 10 * 60 * 60 * 1000;
        
            lastNDays = integer.valueOf(system.label.AdvanceCaseMgtSLA) + 5;
        }
                                                                         
        system.debug('## End AspisBatch_UpdateSOToDeliveryConfirmed Constructor - Start');
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Start - Start');

        string query =  'select id,DeliveryStatus__c,Prerequisiteorder__c,Prerequisiteorder__r.Status__c, ' 
                     +  '         Prerequisiteorder__r.SLAManagedEntryDate__c '
                     +  ' from Offer__c '
                     +  ' where DeliveryStatus__c = \'' + ASPISConstants.OFFER_STATUS_MANAGED + '\'' 
                     +  ' and Prerequisiteorder__r.Status__c = \'' +  ASPISConstants.PRE_ORDER_STATUS_MANAGED + '\'' 
                     +  ' and Prerequisiteorder__r.SLAManagedEntryDate__c = LAST_N_DAYS:' + lastNDays 
                     +  ' and Prerequisiteorder__r.SLAInDeliveryLevel3__c <= TODAY ';

        system.debug('@@ query: '+query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Offer__c> scope) {
        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Execute - Start');

        if(string.isNotBlank(system.label.AdvanceCaseMgtSLA) && string.isNotBlank(busHoursId)){
            /*//this list will be used to update all corresponding sales orders
            list <Prerequisiteorder__c> lstSOToUpdate                                = new list <Prerequisiteorder__c>();*/

            //this list will be used to update all offers to delivered confirmed
            list <Offer__c> lstOffersToUpdate                                        = new list <Offer__c>();

            //dml list for offers update
            List <Database.Saveresult> lstResultsOffUpdate;

            /*//dml list for SO update
            List <Database.Saveresult> lstResultsSOUpdate;*/

            //looping in scope
            for(Offer__c off : scope){

                DateTime tempConditionDate                                           = BusinessHours.add(busHoursId,off.Prerequisiteorder__r.SLAManagedEntryDate__c,slaDelayInMilliSec);

                if(tempConditionDate <= system.now()){
                    //updating offers
                    lstOffersToUpdate.add(new Offer__c(id                            = off.id,
                                                        DeliveryStatus__c            = ASPISConstants.OFFER_STATUS_DELIVERED,
                                                        RealDeliveryDate__c          = date.today()));

                    /*//update corresponding SO
                    if(!alreadyUpdatedSO.contains(off.Prerequisiteorder__c)){

                        //updated SO
                        alreadyUpdatedSO.add(off.Prerequisiteorder__c);

                        lstSOToUpdate.add(new Prerequisiteorder__c(id                = off.Prerequisiteorder__c,
                                                                    Status__c        = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED));
                    }*/
                }//end if tempConditionDate <= system.today()  
            }//end looping in scope
            system.debug('## lstOffersToUpdate ' + lstOffersToUpdate);
            /*system.debug('## lstSOToUpdate ' + lstSOToUpdate);*/

            //updating offers
            if(!lstOffersToUpdate.isEmpty()){
                lstResultsOffUpdate                                                  = Database.update(lstOffersToUpdate, false);

                //error management
                integer index                                                        = 0;
                string errorMsg                                                      = '';
                string successMsg                                                    = '';
                
                for(Database.SaveResult lROU : lstResultsOffUpdate){
                    errorMsg                                                         = '';
                    successMsg                                                       = '';

                    if(!lROU.isSuccess()){
                        //raise error
                        errorMsg                                                     = lstOffersToUpdate[index].id + ',KO,' + lROU.getErrors()[0].getMessage() + '\n';
                        offerStatusUpdate.add(errorMsg);
                        err                                                          = true;
                    }else{
                        //no error
                        successMsg                                                   = lROU.getId() + ',OK,' + '\n';
                        offerStatusUpdate.add(successMsg);
                    }

                    index++;
                }//end looping in result list
            }//end if !lstOffersToUpdate.isEmpty()

            /*//updating SO
            if(!lstSOToUpdate.isEmpty()){
                lstResultsSOUpdate                                                   = Database.update(lstSOToUpdate, false);

                //error management
                integer indexP                                                       = 0;
                string errorMsgP                                                     = '';
                string successMsgP                                                   = '';
                
                for(Database.SaveResult lRSU : lstResultsSOUpdate){
                    errorMsgP                                                        = '';
                    successMsgP                                                      = '';

                    if(!lRSU.isSuccess()){
                        //raise error
                        errorMsgP                                                    = lstSOToUpdate[indexP].id + ',KO,' + lRSU.getErrors()[0].getMessage() + '\n';
                        SOStatusUpdate.add(errorMsgP);
                        err                                                          = true;
                    }else{
                        //no error
                        successMsgP                                                  = lRSU.getId() + ',OK,' + '\n';
                        SOStatusUpdate.add(successMsgP);
                    }

                    indexP++;
                }//end looping in result list
            }//end if !lstSOToUpdate.isEmpty()*/
        }

        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Execute - End');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Finish - Start');

        String emailSubject                                                     = '';
        String batchJobName                                                     = '';
        String csvHeader                                                        = '';

        if(err == true){
             emailSubject                                                       = '*Offers Status Update for Advance Case Mgt';
        }
        else{
             emailSubject                                                       = 'Offers Status Update for Advance Case Mgt';
        }

        if(!offerStatusUpdate.isEmpty()){
            batchJobName                                                        = 'AspisBatch_UpdateSOToDeliveryConfirmed';
            csvHeader                                                           = 'Record ID,Status,Error Message';

            sendStatusEmail(batchJobName, 
                            emailSubject, 
                            csvHeader, 
                            'Offers Update Status', 
                            offerStatusUpdate,
                            '', 
                            new list <string>());
        }else{
            sendStatusEmail(batchJobName, 
                            '*Offers Status Update for Advance Case Mgt', 
                            csvHeader, 
                            'Offers Update Status', 
                            new list <string>{',,KO,No records were processed'},
                            '', 
                            new list <string>());
        }

        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed Finish - End');
    }

    public static void sendStatusEmail(string batchName, 
                                          string emailSubject,
                                          string header,
                                          string attName,
                                          list <string> lstResults,
                                          string attName2,
                                          list <string> lstResults2){
        system.debug('## Start AspisBatch_UpdateSOToDeliveryConfirmed - sendStatusEmail');

        string body                                               = 'Your batch job ' + batchName +' has finished. \n' 
                                                                  + 'Please find the status lists attached to this mail.';
        // Creating the CSV file
        string finalstr,finalstr2                                 = '';

        // Define the email
        Messaging.SingleEmailMessage email                        = new Messaging.SingleEmailMessage(); 

        // Define email attachments
        list <Messaging.EmailFileAttachment> emailAtts            = new list <Messaging.EmailFileAttachment>();
        
        // Create the email attachments  
        Messaging.EmailFileAttachment efa                         = new Messaging.EmailFileAttachment();
        if(!lstResults.isEmpty()){
            efa.setFileName(attName +'.csv');

            //build status
            finalstr                                              = header + ' \n';

            for(string str : lstResults){
                finalstr                                          += str;                         
            }

            finalstr                                              = finalstr.removeEnd('\n');

            efa.setBody(Blob.valueOf(finalstr));

            //add to list attachments
            emailAtts.add(efa);
        }//end if !lstResults.isEmpty()

        // Create the email attachments 2  
        Messaging.EmailFileAttachment efa2                        = new Messaging.EmailFileAttachment();
        if(!lstResults2.isEmpty()){
            efa2.setFileName(attName2 +'.csv');

            //build status
            finalstr2                                             = header + ' \n';

            for(string str : lstResults2){
                finalstr2                                         += str;                         
            }

            finalstr2                                             = finalstr2.removeEnd('\n');

            efa2.setBody(Blob.valueOf(finalstr2));

            //add to list attachments
            emailAtts.add(efa2);
        }//end if !lstResults2.isEmpty()

        String[] toAddresses = System.label.BAT01_emailAddress.split(';');

        // Sets the paramaters of the email
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(body);
        email.setFileAttachments(emailAtts);

        // Sends the email
        Messaging.SendEmailResult [] r= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 

        system.debug('## End AspisBatch_UpdateSOToDeliveryConfirmed - sendStatusEmail');
    }
}