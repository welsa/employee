/**
 * @description       : 
 * @author            : HRM
 * @group             : 
 * @last modified on  : 11-11-2021
 * @last modified by  : HRM
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-10-2021   HRM   Initial Version
**/
global class DistributorMockCallout implements HttpCalloutMock {
    // public Integer errorCode;   
    // public String message;
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('callout:OpistoStockCallout') && req.getMethod() == 'GET') { 
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": {"searchUrl": "https://master-alphascale.opisto.pro/SignUp/Auth?token=bba35b559485f539a1056693ae28d94723203407a3b100501e86c3862b868c0c&returnUrl=/Search?manufacturerReference=12345&page=1&sort=NO","elapsedTime": 1412,"total": 0,"availablePages": 0},"errorCode": 0}');
            res.setStatusCode(200);
                
        } else if (req.getEndpoint().contains('callout:OpistoAuthenticate') && req.getMethod() == 'POST') {
            Datetime dt = Datetime.now().addDays(14);
            Long dateTimeEpoch = dt.getTime()/1000;
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": {"accessToken":"ySO1zqQLoEmLGOoiWNFHBQ==","expiration":"'+dateTimeEpoch+'","apiUserId":"123456"},"errorCode": 0,"message":null}');
            res.setStatusCode(200);

        }
        // res.setHeader('Content-Type', 'application/json');
        // String body = '{"data": {"accessToken":"ySO1zqQLoEmLGOoiWNFHBQ==","expiration":"'+system.now().addDays(2)+'"},"errorCode": 0,"message":""}';
        // res.setBody(body);
        // res.setStatusCode(200);
        return res;
    }
}