@isTest
/*
----------------------------------------------------------------------
-- - Name          : APManageLogs_TEST
-- - Author        : RLA
-- - Description   : Test class for APManageLogs
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-MAY-2018  RLA     1.0    Initial version
----------------------------------------------------------------------
**********************************************************************
*/
private class APManageLogs_TEST
{
	@isTest
	static void normal()
	{
		APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
		wrapperLog.assessmentid = '1234';
		wrapperLog.calltype ='Inbound';
		wrapperLog.cancellationreason = 'none';
		wrapperLog.className = 'RESTPostInvoice_TEST';
		wrapperLog.errorcode = '200';
		wrapperLog.errordescription = 'error';
		wrapperLog.etl_data_name = 'data';
		wrapperLog.etl_interface_name ='sidexa';
		wrapperLog.inout = 'Outbound';
		wrapperLog.jsonmessage = 'hello';
		wrapperLog.jsonresponse = 'good';
		wrapperLog.objectreference = 'test';
		wrapperLog.process = 'test';
		wrapperLog.sobjectName = 'Account';
		wrapperLog.sobjectid = 'test';
		wrapperLog.stacktrace ='200';
		wrapperLog.status = 'Passed';
		wrapperLog.systemcalling = 'Sidexa';
		wrapperLog.wserrormessage = 'hello';
		wrapperLog.attachmentRequestbody = 'req';
		wrapperLog.attachmentResponsebody = 'body';
		wrapperLog.wsRequest = 'hello';
		wrapperLog.wSResponse = 'hello';
		wrapperLog.tech_createddate = datetime.now();
		wrapperLog.wsdate  = datetime.now();
		wrapperLog.datelog =  datetime.now();
		APManageLogs.createWsLog(wrapperLog, 'insert');

	}

	@isTest
	static void atfuture()
	{
		APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
		wrapperLog.assessmentid = '1234';
		wrapperLog.calltype ='Inbound';
		wrapperLog.cancellationreason = 'none';
		wrapperLog.className = 'RESTPostInvoice_TEST';
		wrapperLog.errorcode = '200';
		wrapperLog.errordescription = 'error';
		wrapperLog.etl_data_name = 'data';
		wrapperLog.etl_interface_name ='sidexa';
		wrapperLog.inout = 'Outbound';
		wrapperLog.jsonmessage = 'hello';
		wrapperLog.jsonresponse = 'good';
		wrapperLog.objectreference = 'test';
		wrapperLog.process = 'test';
		wrapperLog.sobjectName = 'Account';
		wrapperLog.sobjectid = 'test';
		wrapperLog.stacktrace ='200';
		wrapperLog.status = 'Passed';
		wrapperLog.systemcalling = 'Sidexa';
		wrapperLog.wserrormessage = 'hello';
		wrapperLog.attachmentRequestbody = 'req';
		wrapperLog.attachmentResponsebody = 'body';
		wrapperLog.wsRequest = 'hello';
		wrapperLog.wSResponse = 'hello';
		wrapperLog.tech_createddate = datetime.now();
		wrapperLog.wsdate  = datetime.now();
		wrapperLog.datelog =  datetime.now();
		APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');

	}
}