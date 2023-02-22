/***
* @author      Telesio Consultant
* @date        29/12/2021
* @description Utility class to prepare HttpRequest & Response
* @group       B2G 
* @see         
***/
public class b2g_CalloutManager {

    /***
    * @description	Method to build http requests to perform the callout
    * @param		endpoint, endpoint of the request
    * @param		method, POST or GET
    * @param		timeout timeout (Ms) of the request
    * @param		timeout Body of post request if any
    * @param		header of the request
    * @returns		HttpResponse HttpResponse of Request
    * @exception	None special
    ***/ 
	public static HttpResponse getResponse(String endpoint, String method, Integer timeout, String body, Map<String, String> header){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		req.setMethod(method);
		req.setEndpoint(endpoint);
		req.setTimeout(timeout != null ? timeout : 120000);

        if(header != null){
            for(String key : header.keySet()){
                req.setHeader(key,header.get(key));
            }
        }

        if (method == 'POST'){
            req.setBody(body);
        }

        System.debug(LoggingLevel.DEBUG, 'Request: ' + req);
		res = h.send(req); 
        return res;
	}
}