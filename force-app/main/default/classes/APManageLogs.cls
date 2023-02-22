public with sharing class APManageLogs {
/*************************************************************************************
Class Name - APManageLogs
Version - 1.0
Created Date - 27 MAR 2018

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ruksaar L             27/03/2018  Case-2177: Corrections/evolutions sur les logs
* Neha  P               14/04/2022  C-004505 Create a log related list in assessment Object
* RRJ                   03/11/2022  C-004835 Optimisation RestUpsertV2
*************************************************************************************/

    //serialise the wrapper using JSON.serialize(wrapperLog) to send it to future methods
    @future
    public static void createWsLogFuture (String wrapperLogString, String operationType){

        LogsWrapper wrapperLog = null;

        wrapperLog = (LogsWrapper) JSON.deserialize(wrapperLogString, LogsWrapper.class);

        Log__c logdummy = createWsLog(wrapperLog, operationType);
    }


    public static Log__c createWsLog(LogsWrapper wrapperLog, String operationType){

        System.debug('@@ entered create LOG' + wrapperLog);
        
        Log__c log      = new Log__c();
        
        log.DateLog__c  = System.now();

        if (String.isNotBlank( wrapperLog.assessmentid)){
            log.AssessmentID__c   = wrapperLog.assessmentid;   
        }

        if (String.isNotBlank( wrapperLog.calltype)){
            log.CallType__c   = wrapperLog.calltype;   
        }

        if (String.isNotBlank( wrapperLog.className)){
            log.Class__c   = wrapperLog.className;   
        }

        if (String.isNotBlank( wrapperLog.errorcode)){
            log.ErrorCode__c   = wrapperLog.errorcode;   
        }

        if (String.isNotBlank( wrapperLog.errordescription)){
            log.ErrorDescription__c   = wrapperLog.errordescription;   
        }

        if (String.isNotBlank( wrapperLog.etl_data_name)){
            log.ETL_DATA_NAME__c   = wrapperLog.etl_data_name;   
        }

        if (String.isNotBlank( wrapperLog.etl_interface_name)){
            log.ETL_INTERFACE_NAME__c   = wrapperLog.etl_interface_name;   
        }

        if (String.isNotBlank( wrapperLog.inout)){     
            log.InOut__c = wrapperLog.inout;
        }        

        if (String.isNotBlank( wrapperLog.logId)){
            log.Id   = wrapperLog.logId;   
        }

        if (String.isNotBlank( wrapperLog.objectreference)){     
            log.ObjectReference__c = wrapperLog.objectreference;
        }

        if (String.isNotBlank( wrapperLog.sobjectName)){     
            log.sObject__c = wrapperLog.sobjectName;
        }

        if (String.isNotBlank( wrapperLog.sobjectid)){     
            log.sObjectId__c = wrapperLog.sobjectid;

            //NPE 14/04/2022 C-004505 Create a log related list in assessment Object
            if(wrapperLog.sobjectName =='Assessment__c'){
                log.Assessment__c= wrapperLog.sobjectid;
            }
        }

        if (String.isNotBlank( wrapperLog.process)){     
            log.Process__c = wrapperLog.process;
        }

        if (String.isNotBlank( wrapperLog.stacktrace)){     
            log.StackTrace__c = wrapperLog.stacktrace;
        }

        if (String.isNotBlank( wrapperLog.status)){     
            log.Status__c = wrapperLog.status;
        }

        if (String.isNotBlank( wrapperLog.systemcalling)){     
            log.SystemCalling__c = wrapperLog.systemcalling;
        }

        if ( wrapperLog.tech_createddate != null){         
            log.Tech_CreatedDate__c = wrapperLog.tech_createddate;
        }

        if ( wrapperLog.wsdate != null){         
            log.wsDate__c = wrapperLog.wsdate;
        }
        
        if (String.isNotBlank( wrapperLog.wserrormessage)){         
            log.wsErrorMessage__c = wrapperLog.wserrormessage;
        }

        if (String.isNotBlank( wrapperLog.status)){     
            log.Status__c = wrapperLog.status;
        }

        if (String.isNotBlank( wrapperLog.wsRequest)){  
            if (wrapperLog.wsRequest.length() < 30000) {      
                log.WsRequest__c = wrapperLog.wsRequest;
            }
            else{
                wrapperLog.attachmentWSRequestbody = wrapperLog.wsRequest;
                //createAttachment(log, wrapperLog.wsRequest, 'WSRequest');
            }
        }

        if (String.isNotBlank( wrapperLog.wSResponse)){              
            if (wrapperLog.wSResponse.length() < 30000) {      
                log.WSResponse__c = wrapperLog.wSResponse;
            }
            else{
                wrapperLog.attachmentWSResponsebody = wrapperLog.wSResponse;
                //createAttachment(log, wrapperLog.wSResponse, 'WSResponse'); 
            }
        }

        if (String.isNotBlank( wrapperLog.jsonmessage)){        
            if (wrapperLog.jsonmessage.length() < 30000) {      
                log.JSONMessage__c = wrapperLog.jsonmessage;
            }
            else{
                wrapperLog.attachmentRequestbody = wrapperLog.jsonmessage;
            }

        }

        if (String.isNotBlank( wrapperLog.jsonResponse)){     
            if (wrapperLog.jsonResponse.length() < 30000) {      
                log.JSONResponse__c = wrapperLog.jsonResponse;
            }
            else{
                wrapperLog.attachmentResponsebody = wrapperLog.jsonResponse;
            }
        }

        //RLA 12/01/1010 C-004140: Time tracing of processes on restupsert
        if (wrapperLog.T1 != null){
            log.T1__c = wrapperLog.T1;
        }

        if (wrapperLog.T2 != null){
            log.T2__c = wrapperLog.T2;
        }

        if (wrapperLog.T3 != null){
            log.T3__c = wrapperLog.T3;
        }

        if (wrapperLog.T4 != null){
            log.T4__c = wrapperLog.T4;
        }

        if (wrapperLog.T5 != null){
            log.T5__c = wrapperLog.T5;
        }

        if (wrapperLog.T6 != null){
            log.T6__c = wrapperLog.T6;
        }

        if (wrapperLog.T7 != null){
            log.T7__c = wrapperLog.T7;
        }

        if (wrapperLog.T8 != null){
            log.T8__c = wrapperLog.T8;
        }

        if (wrapperLog.T9 != null){
            log.T9__c = wrapperLog.T9;
        }

        if (wrapperLog.T10 != null){
            log.T10__c = wrapperLog.T10;
        }
        //RRJ C-004835 Optimisation REst Upsert 03/11/2022
        if (wrapperLog.T11 != null){
            log.T11__c = wrapperLog.T11;
        }

        if (wrapperLog.T12 != null){
            log.T12__c = wrapperLog.T12;
        }

        if (wrapperLog.T13 != null){
            log.T13__c = wrapperLog.T13;
        }

        if (wrapperLog.T14 != null){
            log.T14__c = wrapperLog.T14;
        }

        if (wrapperLog.T15 != null){
            log.T15__c = wrapperLog.T15;
        }
        if (wrapperLog.executionTime != null){
            log.ExecutionTime__c = wrapperLog.executionTime;
        }

        if (String.isNotBlank(wrapperLog.TraceVariablesNena)){
            log.TraceVariablesNena__c = wrapperLog.TraceVariablesNena;
        }

        Request reqInfo = Request.getCurrent();
        String currentRequestId = reqInfo.getRequestId();
        log.Request_ID__c = currentRequestId;
        System.debug('Shane currentRequestId' + currentRequestId);
        System.debug('Shane log.Request_ID__c' + log.Request_ID__c);


        log.Quiddity_Value__c = reqInfo.getQuiddity().name();
        //log.Quiddity_Value__c = JSON.stringify(currentType);
        //System.debug('Shane Quiddity' + currentType);
        System.debug('Shane log.Quiddity_Value__c' + log.Quiddity_Value__c);


        system.debug('@@ ASPISConstants Log: ' + log);

        if (operationType == 'insert'){
            insert log; 
        }

        if (operationType == 'update' && String.isNotBlank(wrapperLog.logId)){
            update log; 
        }

        if (String.isNotBlank(wrapperLog.attachmentRequestbody) ){
            createAttachment(log, wrapperLog.attachmentRequestbody, 'Request');           
        }

        if (String.isNotBlank(wrapperLog.attachmentResponsebody)){
            createAttachment(log, wrapperLog.attachmentResponsebody, 'Response');           
        }

        if (String.isNotBlank(wrapperLog.attachmentWSRequestbody) ){
            createAttachment(log, wrapperLog.attachmentWSRequestbody, 'WSRequest');           
        }

        if (String.isNotBlank(wrapperLog.attachmentWSResponsebody)){
            createAttachment(log, wrapperLog.attachmentWSResponsebody, 'WSResponse');           
        }

        return log;

    }
   

    public static void createAttachment(Log__c log, String body,String name){
        System.debug('@@ entered createAttachmentReq');
        //if(log.JSONMessage__c.length() > 30000){
            APCreateAttachments.createAttachment(name, body, log);
        //}

    }

    // public static void createAttachmentRes(Log__c log, String body){
    //    System.debug('@@ entered createAttachmentRes');        
    //    //if(log.JSONResponse__c.length() > 30000){
    //        APCreateAttachments.createAttachment('Response', body, log);
    //    //}

    //}

    public class LogsWrapper{
        public String  assessmentid;
        public String  calltype;
        public String   cancellationreason ;
        public String   className;
        public Datetime    datelog;
        public String  errorcode;
        public String     errordescription;
        public String   etl_data_name;
        public String etl_interface_name;
        public String  inout;
        public String  jsonmessage;
        public String   jsonresponse;
        public String  objectreference;
        public String   process;
        public String   sobjectName;
        public String   sobjectid;
        public String stacktrace;
        public String   status;
        public String systemcalling;
        public Datetime   tech_createddate;
        public Datetime   wsdate;
        public String wserrormessage;
        public String attachmentRequestbody;
        public String attachmentResponsebody;
        public String attachmentWSRequestbody;
        public String attachmentWSResponsebody;
        public String logId;
        public String wsRequest;
        public String wSResponse;
        public Decimal executionTime;
        public String TraceVariablesNena;
		public Decimal T1;
        public Decimal T2;
        public Decimal T3;
        public Decimal T4;
        public Decimal T5;
        public Decimal T6;
        public Decimal T7;
        public Decimal T8;
        public Decimal T9;
        public Decimal T10;
        //RRJ C-004835 03/11/2022
        public Decimal T11;
        public Decimal T12;
        public Decimal T13;
        public Decimal T14;
        public Decimal T15;


        
    }
}