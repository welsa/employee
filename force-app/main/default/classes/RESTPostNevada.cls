/*
----------------------------------------------------------------------
-- - Name          : RESTPostNevada
-- - Author        : VSU
-- - Description   : Class used to send data to ICE for sync of data
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 21-JUL-2017  VSU     1.0         Initial version
-- 18-AUG-2020  WCH     1.1         C-003864 - 2020 Connectivity changes for EIP
-- 19-OCT-2020  KPA     1.2         C-003996 - RestPostNevada Log status Incorrect
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class RESTPostNevada{
    @future(callout = true)
    public static void sendRequest(String requestBodyNevada)
    {
        System.debug('---------------------------------- START RESTPostNevada ----------------------------------');
        //WCH 07/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'NEVADA_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

        // Building Request
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint((String)responseEIPEndpoint.get('NEVADA_EndPoint'));//WCH 18/08/2020 C-003864
        request.setHeader('Content-Type','application/json; charset=UTF-8');
        request.setHeader('Accept','application/json');
        request.setBody(requestBodyNevada);
        request.setMethod('POST');
        request.setTimeout(120000);

        // Variables needed
        String responseBody = '';
        Boolean isSuccessful = true;
        String callerSystem = '';
        String errorDescription = '';

        // Sending request
        HTTP httpCall           = new HTTP();
        try
        {
            HTTPResponse response   = httpCall.send(request);
            
            System.debug('## response: ' + response);
            System.debug('## body: ' + response.getBody());
            
            responseBody            = response.getBody();
        }
        catch(Exception e)
        {

            responseBody = e.getStackTraceString();
            isSuccessful = false;
            errorDescription = e.getMessage();
            system.debug('##String.valueOf(isSuccessful) '+String.valueOf(isSuccessful));
        }
        
        //KPA C-003996
        if(responseBody.contains('Erreur') || responseBody.contains('Error')){
            isSuccessful = false;
        }
        else{
            isSuccessful = true;
        }

        System.debug('Request Body : ' + requestBodyNevada);
        JSONRequest requestWrapper = (JSONRequest) JSON.deserialize(requestBodyNevada, JSONRequest.class);

        if(requestWrapper.Assessments.size() == 1)
        {
            callerSystem = requestWrapper.Assessments[0].callerSystem;
        }

        // Creating the log
        createLog(requestBodyNevada, responseBody, isSuccessful, callerSystem, 'RESTPostNevada', 'Assessment__c', errorDescription);

        System.debug('---------------------------------- END RESTPostNevada ----------------------------------');

    }

    public static void createLog(String request, String response, Boolean isSuccessful, String systemCalling, String classUsed, String obj ,String errorDescription)
    {
        Log__c currentLog = new Log__c( DateLog__c  = System.now(),
                                        Class__c    = classUsed,
                                        sObject__c  = obj,
                                        Status__c   = (isSuccessful) ? 'Passed' : 'Failed',
                                        SystemCalling__c = systemCalling);

        
        
        currentLog.ErrorDescription__c =  errorDescription;

        system.debug('##currentLog '+ currentLog);
        // Check if the length of the request is less or equal to 32768 -> add request in JSONMessage__c
        if(request.length() <= 32768)
        {
            currentLog.JSONMessage__c = request;
        }

        // Check if the length of the response is less or equal to 32768 -> add request in JSONResponse__c
        if(response.length() <= 32768)
        {
            currentLog.JSONResponse__c = response;
        }

        // insert the log
        insert currentLog;

        // In case the request was too big create an attachment for it
        if(request.length() > 32768)
        {
            APCreateAttachments.createAttachment('Request', request, currentLog);
        }

        // In case the response was too big create an attachment for it
        if(response.length() > 32768)
        {
            APCreateAttachments.createAttachment('Response', response, currentLog);
        }
    }

    public class JSONRequest
    {
        public List<AssessmentRequest> Assessments;
    }

    public class AssessmentRequest
    {
        public String callerSystem;
    }

}