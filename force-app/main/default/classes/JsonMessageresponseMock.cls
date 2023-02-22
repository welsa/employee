/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 09-14-2020
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   09-14-2020   ARA   Initial Version
**/
@isTest
global class JsonMessageresponseMock implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;

    global JsonMessageresponseMock(Integer code, String status, String body) {
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