/*
  ----------------------------------------------------------------------
  -- - Name          : RESTUpdateCases_V1
  -- - Author        : Unknown
  -- - Description   : 
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- -----------  ----   1.0     Initial Version
  -- 22-SEP-2016  ABT    1.1     C-001728: Added the new function of create attachment
  ----------------------------------------------------------------------
 **********************************************************************
*/
@RestResource(urlMapping='/v1.0/updateCases/*')
global with sharing class RESTUpdateCases_V1 {
	private final Static String OBJECTCODE = '-CAS';
	private final Static String PROCESSDELIVERYPROBLEM = '-WS';
	@HttpPost	
	global static void treatCase() {
		map<String,String> mapHeaders = new map<String,String>();
		string results = '';
		//retrieve the headers that are received by the request. Synchronous / Asynchronous
		RestRequest req = RestContext.request;
		mapHeaders = req.headers;
		//system.debug('////mapHeaders: '+mapHeaders);
		
		//to be commented////////////////////////////////////////////////////
		//mapHeaders.put(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
		//////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////
		
		//convert the requestbody into a string
		String body = RestContext.request.requestBody.toString();
		
		Log__c log = new Log__c();
        log.DateLog__c = system.now();

		// ABT - C-001728 - 22-SEP-2016
		log.Class__c   = 'RESTUpdateCases_V1';

		//System.debug('/// Json Message : '+body);
		if (body.length() <= 30000){
			log.JSONMessage__c = body;
			
		}
        insert log;

		if (body.length() > 30000)
		{
			// ABT - C-001728 - 22-SEP-2016
			//APCreateAttachments.createAttachment(body,log);
			APCreateAttachments.createAttachment('Request', body, log);
		}
		
		if(mapHeaders.containsKey(system.label.CALLTYPE)){
			String cType = mapHeaders.get(system.label.CALLTYPE);
			
			if(system.label.ASYNCHRONOUS == cType){
				log.CallType__c = system.label.ASYNCHRONOUS;
				// call @future method
				upsertCasesAsync(log.Id,body);
				results = system.label.MSGASYNCTREATMENT +' '+log.Id;
			}else if(system.label.SYNCHRONOUS == cType){
				log.CallType__c = system.label.SYNCHRONOUS;
				//call synchronous method
				results = upsertCasesSync(log.Id,body);
			}
		}else{
			log.CallType__c = system.label.SYNCHRONOUS;
			//if no callType in header, by default call synchronous method
			results = upsertCasesSync(log.Id,body);
		}
		if(results.contains('Exceptions')){
			log.Status__c = system.label.STATUSFAILED;
		}else{
			log.Status__c = system.label.STATUSPASSED;
		}
		update log;
		RestContext.response.responseBody = Blob.valueOf(results);          
		
	}

	public class CasesW{
		public String BodyShopID;
		public String AssessmentId;
		public String CaseReason;
		public String Comment;
		public String Description;
		public DateTime DueDate;
		public String InternalComments;
		public String InvoiceNumber;
		public String Origin;
		public String Priority;
		public String SalesOrderId;
		public String Status;
		public String Subject;
		public String SubmittedBy;
		public String Type;
		public String CaseName;
	}

	@future
	public static void upsertCasesAsync(Id logId,String body){
		list<Log__c> logToUpdate = new list<Log__c>();
		//call method that will process json that contains assessments
		string jResp = upsertCase(body);
		//get log id to update
		for(Log__c l : [Select Id, JSONResponse__c from Log__c where Id =:logId]){
			if (jResp.length() > 30000){
				// ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(jResp,l);
				APCreateAttachments.createAttachment('Response', jResp, l);
			}else{
				l.JSONResponse__c = jResp;
			}

			logToUpdate.add(l);
		}
		
		//update log
		if(logToUpdate.size()  > 0){
			update logToUpdate;
		}
	}

	// call if calltype is sync
	public static string upsertCasesSync(Id logId,String body){
		list<Log__c> logToUpdate = new list<Log__c>();
		//call method that will process json that contains assessments
		string jResp = upsertCase(body);
		//get log id to update
		for(Log__c l : [Select Id, JSONResponse__c from Log__c where Id =:logId]){
			if (jResp.length() > 30000){
				// ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(jResp,l);
				APCreateAttachments.createAttachment('Response', jResp, l);
			}else{
				l.JSONResponse__c = jResp;
			}

			logToUpdate.add(l);
		}
		
		//update log
		if(logToUpdate.size()  > 0){
			update logToUpdate;
		}
		return jResp;
	}

	//create objects in Salesforce
	public static string upsertCase(string body){
		map<String,CasesW> mapCasesW = new map<String,CasesW>();
		map<String,Case__c> mapCase = new map<String,Case__c>();
		list<CasesW> caseWList = new list<CasesW>();
		list<Case__c> caseListToUpdate = new list<Case__c>();
		list<Case__c> caseListToInsert = new list<Case__c>();
		map<String,String> successUpdateMap = new map<String,String>();
		map<String,String> errorUpdateMap = new map<String,String>();
		map<String,String> successInsertMap = new map<String,String>();
		map<String,String> errorInsertMap = new map<String,String>();
		map<String,String> salesOrderMap = new map<String,String>();
		map<String,String> assessmentMap = new map<String,String>();
		map<String,String> bodyShopMap = new map<String,String>();
		map<String,String> invoiceMap = new map<String,String>();
		set<String> salesOrderSet = new set<String>();
		set<String> assessmentSet = new set<String>();
		set<String> bodyShopSet = new set<String>();
		set<String> invoiceSet = new set<String>();
		string results = null;
		String conversionErrors = null;
		JSONGenerator genResults;

		try{
			//create json parser
			JSONParser parser = JSON.createParser(body);
			
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					while (parser.nextToken() != null) {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							try{
								CasesW c = (CasesW)parser.readValueAs(CasesW.class);
								parser.skipChildren();
								//system.debug(' // case parser: ' + c);
								caseWList.add(c);
							}catch(Exception ex){
								if(conversionErrors == null){
									conversionErrors = ex.getMessage();
								}else{
									conversionErrors += '-'+ex.getMessage();
								}
							}
						}
					}
				}
			}
			//system.debug('/// caseWList: ' + caseWList);

			for(CasesW c : caseWList){
				mapCasesW.put(c.CaseName,c);
				salesOrderSet.add(c.SalesOrderId);
				assessmentSet.add(c.AssessmentId);
				bodyShopSet.add(c.BodyShopID);
				invoiceSet.add(c.InvoiceNumber);
			}

			for(PrerequisiteOrder__c so : [Select Id,ReferenceNumber__c from PrerequisiteOrder__c where ReferenceNumber__c in:salesOrderSet]){
				salesOrderMap.put(so.ReferenceNumber__c , so.Id);
			}

			for(Assessment__c a : [Select Id, AssessmentID__c from Assessment__c where AssessmentID__c in:assessmentSet]){
				assessmentMap.put(a.AssessmentID__c,a.Id);
			}

			for(Account a : [Select Id, ReferenceNumber__c from Account where ReferenceNumber__c in:bodyShopSet  ]){
				bodyShopMap.put(a.ReferenceNumber__c,a.Id);
			}

			for(Invoice__c inv : [Select Id,Number__c from Invoice__c where Number__c in:invoiceSet  ]){
				invoiceMap.put(inv.Number__c,inv.Id);
			}

			set<String> setCaseNameFound = new set<String>();
			for(Case__c c : [Select Id,Name,Account_Name__c,Assesment__c,Case_Reason__c,
							 Comment__c,Description__c,Internal_Comments__c,
							 Invoice__c,Origin__c,Priority__c,Sales_order__c,Status__c,
							 Subject__c,SubmittedBy__c,Type__c
							 From Case__c
							 Where Name in:mapCasesW.keySet()])
			{
				mapCase.put(c.Name,c);
			}

			for(CasesW c : caseWList){
				if(mapCase.containsKey(c.CaseName)){
					Case__c existingCase = mapCase.get(c.CaseName);
					existingCase.Case_Reason__c = c.CaseReason;
					existingCase.Comment__c = c.Comment;
					existingCase.Description__c = c.Description;
					existingCase.Internal_Comments__c = c.InternalComments;
					existingCase.Origin__c = c.Origin;
					existingCase.Priority__c = c.Priority;
					existingCase.Status__c = c.Status;
					existingCase.Subject__c = c.Subject;
					existingCase.Type__c = c.Type;
					caseListToUpdate.add(existingCase);
				}else{
					Case__c newCase = new Case__c();
					newCase.Case_Reason__c = c.CaseReason;
					newCase.Comment__c = c.Comment;
					newCase.Description__c = c.Description;
					newCase.Internal_Comments__c = c.InternalComments;
					newCase.Origin__c = c.Origin;
					newCase.Priority__c = c.Priority;
					newCase.Status__c = c.Status;
					newCase.Subject__c = c.Subject;
					newCase.Type__c = c.Type;
					newCase.Sales_order__c = salesOrderMap.get(c.SalesOrderId);
					newCase.Assesment__c = assessmentMap.get(c.AssessmentId);
					newCase.Account_Name__c = bodyShopMap.get(c.BodyShopID);
					newCase.Invoice__c = invoiceMap.get(c.InvoiceNumber);
					caseListToInsert.add(newCase);
				}
			}

			if(caseListToInsert.size() > 0){
				List<Database.saveResult> uResults = Database.insert(caseListToInsert,false);

				for(Integer idx = 0; idx < uResults.size(); idx++) {
					if(uResults[idx].isSuccess()) {
						successInsertMap.put(uResults[idx].getId(), 'Success Insert');
					}/*else{
						for(Database.Error err : uResults[idx].getErrors()){
							system.debug('//// err.getMessage(): ' + err.getMessage());
							if(errorInsertMap.containsKey(caseListToInsert[idx].Sales_order__c)){
								string existingErr = errorInsertMap.get(caseListToInsert[idx].Sales_order__c);
								errorInsertMap.put(caseListToInsert[idx].Sales_order__c,existingErr +'-'+err.getMessage());
							}else{
								errorInsertMap.put(caseListToInsert[idx].Sales_order__c,err.getMessage());
							}
						}
					}*/
				}
			}

			if(caseListToUpdate.size() > 0){
				List<Database.saveResult> uResults = Database.update(caseListToUpdate,false);

				for(Integer idx = 0; idx < uResults.size(); idx++) {
					if(uResults[idx].isSuccess()) {
						successUpdateMap.put(caseListToUpdate[idx].Name, 'Success Update');
					}/*else{
						for(Database.Error err : uResults[idx].getErrors()){
							if(errorUpdateMap.containsKey(caseListToUpdate[idx].Name)){
								string existingErr = errorUpdateMap.get(caseListToUpdate[idx].Name);
								errorUpdateMap.put(caseListToUpdate[idx].Name,existingErr +'-'+err.getMessage());
							}else{
								errorUpdateMap.put(caseListToUpdate[idx].Name,err.getMessage());
							}
						}
					}*/
				}
			}

			genResults = JSON.createGenerator(false);

			genResults.writeStartArray();
				if(successInsertMap.size() > 0){
					for(String suc : successInsertMap.keySet()){
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Insert');
							genResults.writeStringField('CaseId', suc);
							genResults.writeBooleanField('Success', true);
							genResults.writeNullField('Warning');
							genResults.writeNullField('ErrorMessage');
						genResults.writeEndObject();
					}
				}

				if(conversionErrors != null){
					genResults.writeStartObject();
						genResults.writeStringField('OperationType', 'Insert');
						genResults.writeNullField('CaseId');
						genResults.writeBooleanField('Success', false);
						genResults.writeNullField('Warning');
						genResults.writeStringField('ErrorMessage','Exceptions: ' + conversionErrors);
					genResults.writeEndObject();
				}

				if(successUpdateMap.size() > 0){
					for(String suc : successUpdateMap.keySet()){
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'Update');
							genResults.writeStringField('CaseId', suc);
							genResults.writeBooleanField('Success', true);
							genResults.writeNullField('Warning');
							genResults.writeNullField('ErrorMessage');
						genResults.writeEndObject();
					}
				}
			genResults.writeEndArray();

			

	        results = genResults.getAsString();
	    }catch(Exception ex){
	        genResults = JSON.createGenerator(false);
	        genResults.writeStartObject();
				genResults.writeStringField('OperationType', 'Update');
				genResults.writeNullField('CaseId');
				genResults.writeBooleanField('Success', false);
				genResults.writeNullField('Warning');
				genResults.writeStringField('ErrorMessage','Exceptions: ' + ex.getMessage());
			genResults.writeEndObject();

			results = genResults.getAsString();
	    }

		return results;
	}
}