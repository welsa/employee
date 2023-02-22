@isTest
global class PdfHttpCalloutMock implements HttpCalloutMock{
    public String resBody;
    public String contentType ;
    public Integer status;
    //public String acceptDataType;


    global HTTPResponse respond(HTTPRequest req){
        HTTPResponse response = new HTTPResponse();
        //response.setHeader('Content-Type', 'application/pdf');
        //response.setBody('MDAwMDAgbg0KMjQgMQ0KMDAwMDAzMjk1NCAwMDAwMCBuDQoyNSAxDQowMDAwMDMzMTYxIDAwMDAw');
        //response.setStatusCode(200);
        response.setHeader('Content-Type', contentType);
        response.setBody(resBody);
        response.setStatusCode(status);
        //response.setHeader('Accept',acceptDataType);

        return response;
    }
    
}