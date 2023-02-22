@isTest
global class RestUtilityHttpCalloutMock implements HttpCalloutMock{
/*
----------------------------------------------------------------------
-- - Name          : RestUtilityHttpCalloutMock
-- - Author        : VSU/AMI
-- - Description   : Mock class for callout
--
-- Maintenance History:
--
-- Date         Name        Version  Remarks
-- -----------  -------     -------  ---------------------------------------
-- 09-SEP-2017  VSU/AMI     1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    protected Integer code;
    protected String status;
    protected String body;

    global RestUtilityHttpCalloutMock(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.body = body;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.body);
        response.setStatusCode(this.code);
        response.setStatus(this.status);
        return response;
    } 
}