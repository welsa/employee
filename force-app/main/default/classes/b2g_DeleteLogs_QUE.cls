/***
* @author      Telesio Consultant
* @date        11/02/202
* @description Queuable APEX to delete b2g logs older than N days
* @group       B2G 
* @see         
***/
public class b2g_DeleteLogs_QUE implements Queueable{

    private Integer lastNDays = 30;
    private Integer size = 2000;


    public b2g_DeleteLogs_QUE() {
        this(30);
    }

    public b2g_DeleteLogs_QUE(Integer lastNDays) {
        this.lastNDays  = lastNDays;
    }

    /***
    * @description EXECUTE method of Queue
    * @param       QueueableContext context
    * @return      void 
    * @exception   none special.
    * @author      Telesio Consultant
    * @date       11/02/2022
    ***/ 
    public void execute(QueueableContext context){
        System.debug('b2g_DeleteLogs_QUE START');

        //Query List of DSS where Statut is not sent with a created date within one week
        List<b2g_Booking__c> bookingLogs = Database.query(
            'SELECT Id, b2g_bookingReq__c, b2g_AdditionalInformation__c, b2g_Email__c, b2g_FirstName__c, b2g_Immatriculation__c, b2g_LastName__c, b2g_PhoneNumber__c ' +
            'FROM B2g_Booking__c ' +
            'WHERE   CreatedDate != LAST_N_DAYS: ' + lastNDays +
            ' AND (b2g_Email__c != Null OR b2g_FirstName__c != NULL OR b2g_Immatriculation__c != null OR  b2g_LastName__c != null OR b2g_PhoneNumber__c != null) ' +
            ' LIMIT ' + size
        );

        
        if(!bookingLogs.isEmpty()){                            
            try{
                //Empty sensitive information
                System.debug('b2g_DeleteLogs_QUE records to update: ' + bookingLogs.size());
                for(b2g_booking__c b : bookingLogs){
                    b.b2g_bookingReq__c = null;
                    b.b2g_AdditionalInformation__c = null;
                    b.b2g_Email__c = null;
                    b.b2g_FirstName__c = null;
                    b.b2g_Immatriculation__c = null;
                    b.b2g_LastName__c = null;
                    b.b2g_PhoneNumber__c = null;
                }
                update bookingLogs;

                if(bookingLogs.size() == size && !Test.isRunningTest()){
                    //Re-initialize Job
                    System.debug('b2g_DeleteLogs_QUE Enqueue New job ');
                    Id JobId = System.enqueueJob(new b2g_DeleteLogs_QUE());
                }else{
                    System.debug('b2g_DeleteLogs_QUE FINISH');
                }
            }catch(Exception e){
                System.debug('EXCEPTION Encountered: '  + e.getMessage());
            }
        }else{
            System.debug('b2g_DeleteLogs_QUE : No logs to delete found');
        }
    }
}