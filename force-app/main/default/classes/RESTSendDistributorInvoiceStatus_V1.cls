public class RESTSendDistributorInvoiceStatus_V1 {/* 
    @future(callout=true)
    public static void sendInvoiceStatus(set<Id> invoicesToSend) {
        HttpRequest req = buildWebServiceRequest(invoicesToSend);
		
		if (req != null)
		{
			HttpResponse res = invokeWebService(req);
		}
        
    }

    public static HttpRequest buildWebServiceRequest(set<Id> invoicesToSend){
		String endPointExponens = null;
		String passExponens = null;
		String userExponens = null;
		CountryCodeInformationsMapping__c cs = new CountryCodeInformationsMapping__c();
		Map<String, CountryCodeInformationsMapping__c> mcs = CountryCodeInformationsMapping__c.getAll();

		if (mcs.containsKey('FR'))
		{
			cs = mcs.get('FR');

			if (cs.URLInvoiceDistributor__c != null)
			{
				endPointExponens = cs.URLInvoiceDistributor__c;
			}

			if (cs.LoginInvoiceDistributor__c != null)
			{
				userExponens = cs.LoginInvoiceDistributor__c;
			}

			if (cs.PasswordInvoiceDistributor__c != null)
			{
				passExponens = cs.PasswordInvoiceDistributor__c;
			}
		}
	
		if (endPointExponens != null && userExponens != null && passExponens != null){
			List<Invoice__c> invList = new list<Invoice__c>();
			String JsonResp = '';
			for(Invoice__c inv : [Select Id,Number__c,PurchaseOrder__c,PurchaseOrder__r.Name,Status__c
									from Invoice__c 
										where Id in:invoicesToSend])
			{
				invList.add(inv);
			}

			if (invList.size() > 0)
			{   
				JSONGenerator genResults = JSON.createGenerator(false);
				genResults.writeStartArray();
				for (Invoice__c inv : invList){
					genResults.writeStartObject();
						genResults.writeStringField('User','aspis');//UserInfo.getName()

						genResults.writeStringField('Password','aspisVMC2423');

						if (inv.Number__c != null)
						genResults.writeStringField('Number',inv.Number__c);

						if (inv.PurchaseOrder__r.Name != null)
						genResults.writeStringField('PO',inv.PurchaseOrder__r.Name);

						if (inv.Status__c != null)
						genResults.writeStringField('Status',inv.Status__c);

					genResults.writeEndObject();
				}
				genResults.writeEndArray();

				JsonResp = genResults.getAsString();
				system.debug('///// JsonResp: ' + JsonResp);
			}else{
				JsonResp = 'No invoices';
			}

			HttpRequest reqAccess = new HttpRequest();
			reqAccess.setMethod('POST');
			// to update end point custom label on PRODUCTION
			reqAccess.setEndpoint(endPointExponens);
            
			//client keyinvokeWebService
			String username = userExponens;
            
			//client secret
			String password = passExponens;
            
			Blob headerValue = Blob.valueOf(username + ':' + password);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
               
			system.debug('//// authorizationHeader: ' + authorizationHeader);
			reqAccess.setHeader('Authorization', authorizationHeader);
			reqAccess.setHeader('Content-Type','application/json;charset=UTF-8');
			reqAccess.setBody(JsonResp);
			return reqAccess;
		}else{
			return null;
		}
    }

    public static HttpResponse invokeWebService(HttpRequest req){
        Http httpCall = new Http();
        HTTPResponse res = httpCall.send(req); 
        return res;
    }*/

}