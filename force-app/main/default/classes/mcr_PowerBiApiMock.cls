@isTest
global class mcr_PowerBiApiMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;

    global mcr_PowerBiApiMock(Integer code, String status, String body){
        this.code = code;
        this.status = status;
        this.body = body;
    }

    global HTTPResponse respond(HTTPRequest request) {
       
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatus(status);
        response.setStatusCode(code);
        
        return response; 
    }
}