/*************************************************************************************
Class Name - Utils_ManageLogs
Version - 1.0
Created Date - 03 FEB 2016
Function - Class to manage creation of Logs to alert admininstrator when somethings go wrong.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      02/02/2016  Original Version
* Welsa C       08/05/2021  add log
**************************************************************************************************************************************/
public class Utils_ManageLogs {
    /*################################################################################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##################################################################################################################################*/    
    private final Static String RECORDTYPEDEVELOPMENT = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Development').getRecordTypeId(); 
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/
    
    /**
    * @author Cecile L
    * @date 02/02/2016
    * @description Create a log with information from the caught exception.
    * @param contextClass The class executed when the exception fired.
    * @param contextObject The SObject for which the exception occured.
    * @param except The salesforce exception
     ***/ 
    public static void createLogFromException(String contextClass, String contextObject, Exception except){   
        Log__c logToInsert = new Log__c(
            Class__c = contextClass,
            DateLog__c = System.now(), 
            ErrorDescription__c = except.getMessage(), 
            ErrorCode__c = except.getTypeName(),
            Status__c = 'Failed' , 
            sObject__c = contextObject,
            RecordTypeId = RECORDTYPEDEVELOPMENT,
            StackTrace__c = except.getStackTraceString()
        );
        ASPISWithoutSharingExceptions.insertLog(logToInsert);
    }
    /**
    * @author Cecile L
    * @date 02/02/2016
    * @description Create a log manually, to warn the administrators for problems which don't create exception.
    * @param contextClass The class executed during the event to alert on. 
    * @param contextObject The SObject for which we need to warn the administrator
    * @param errorCode A quick resume of the alert message
    * @param errorDescription The description of the alert message
    * @param errorStackTrace A description of actions to reproduce the error
     ***/ 
    public static void createLogManually(String contextClass, String contextObject, String errorCode, String errorDescription, String errorStackTrace){   
        Log__c logToInsert = new Log__c(
            Class__c = contextClass,
            DateLog__c = System.now(), 
            ErrorDescription__c = errorDescription, 
            ErrorCode__c = errorCode,
            Status__c = 'Failed' , 
            sObject__c = contextObject,
            RecordTypeId = RECORDTYPEDEVELOPMENT,
            StackTrace__c = errorStackTrace
        );
        ASPISWithoutSharingExceptions.insertLog(logToInsert);
    }
    /**
    * @author GBH
    * @date 02/07/2021
    * @description Create a log with information from the caught exception.
    * @param contextClass The class executed when the exception fired.
    * @param contextObject The SObject for which the exception occured.
    * @param except The salesforce exception
     ***/ 
    public static void NOBCreateLogFromException(String contextClass, String contextObject, Exception except, Id sObjectId){
        String stackTrace = except.getStackTraceString().Length()>255? except.getStackTraceString().substring(0, 255) : except.getStackTraceString();
  
        Log__c logToInsert = new Log__c(
            Class__c = contextClass,
            DateLog__c = System.now(), 
            ErrorDescription__c = except.getMessage(), 
            ErrorCode__c = except.getTypeName(),
            Status__c = 'Failed' , 
            sObject__c = contextObject,
            sObjectId__c = sObjectId,
            RecordTypeId = RECORDTYPEDEVELOPMENT,
            StackTrace__c = stackTrace,
            Nob_StackTraceLong__c = except.getStackTraceString()
        );

        ASPISWithoutSharingExceptions.insertLog(logToInsert);
    }
    /**
    * @author WCH
    * @date 31/08/2021
    * @description Create a log cegedim
    * @param contextClass The class executed when the exception fired.
    * @param contextObject The SObject for which the exception occured.
    * @param Invoices json string of invoices
     ***/ 
    public static void createCegedimLog(String contextClass, String contextObject, String Invoices){   
        Log__c logToInsert = new Log__c(
            Class__c = contextClass,
            DateLog__c = System.now(), 
            JSONMessage__c = Invoices != null && Invoices.length() <= 30000 ? Invoices : '',
            Status__c = 'Passed' , 
            sObject__c = contextObject,
            RecordTypeId = RECORDTYPEDEVELOPMENT
        );
        ASPISWithoutSharingExceptions.insertLog(logToInsert);

        if(String.isNotBlank(Invoices)){
            String datetoday = String.valueof(date.today());
            datetoday = datetoday.remove('-');
            Attachment attachment	= new Attachment(
                                        Body		= Blob.valueOf(Invoices),
                                        Name		= 'Invoices'+datetoday+'.txt',
                                        ParentId	= logToInsert.Id
                                    );
            insert attachment;

        }
    }
}