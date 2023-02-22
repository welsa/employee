/*************************************************************************************
Class Name - RESTGetAssessment_V1
Version - 1.0
Created Date - 25 May 2015
Function - Web service to get Assessment

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  -----------------------
* Brayan Nunhuck    25/05/2015  Original Version 
* Shamina M         18/02/2016  C-001518: Removed unnecessary debug logs
* Ashutosh B		22/09/2016  C-001728: Added the new function of create attachment
*************************************************************************************/
@RestResource(urlMapping='/v1.0/getAssessment/*')
global with sharing class RESTGetAssessment_V1 {
    /*@HttpGet    
    global static void getAssessment1() {
        map<String,String> mapHeaders = new map<String,String>();
        list<Assessment__c> assessmentList = new list<Assessment__c>();
        String AssessmentReferenceValue = null;
        String results = null;
        JSONGenerator genResults;
        set<String> assessSet = new set<String>();
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;
        system.debug('////mapHeaders: '+mapHeaders);
        
        try{
            //determine criteria of select on offer
            for(String header : mapHeaders.keySet()){
                if(header == system.label.ASSESSMENTREFERENCE){
                    AssessmentReferenceValue = mapHeaders.get(header);
                }
            }

            if(AssessmentReferenceValue != null){
                if(AssessmentReferenceValue.contains(';')){
                    for(String s : AssessmentReferenceValue.split(';')){
                        assessSet.add(s);
                    }
                }else{
                    assessSet.add(AssessmentReferenceValue);
                }
            }

            String query = 'select Id,AssessmentID__c,Status__c,TECHRulesAppliedDescription__c,LastModifiedBy.Name,LastModifiedDate';
            query += ' from Assessment__c';
            
            if(null != AssessmentReferenceValue && '' != AssessmentReferenceValue){
                if(query.contains('where')){
                    query += ' and AssessmentID__c in: assessSet'; 
                }else{
                    query += ' where AssessmentID__c in: assessSet';
                }
            }

            query += '  limit 10000';

            if(query != null){
                assessmentList = Database.query(query);
                system.debug('/// assessmentList : ' + assessmentList);
                if(assessmentList.size() >0){
                    genResults = JSON.createGenerator(false);
                    genResults.writeStartObject();
                    genResults.writeFieldName('Assessments');
                    genResults.writeStartArray();

                    for(Assessment__c a : assessmentList){
                        genResults.writeStartObject();
                            genResults.writeStringField('AssessmentReference', a.AssessmentID__c);

                            if(a.Status__c == null)
                            genResults.writeNullField('Status');  
                            else
                            genResults.writeStringField('Status', a.Status__c);

                            if(a.TECHRulesAppliedDescription__c == null)
                            genResults.writeNullField('RulesDescription');  
                            else
                            genResults.writeStringField('RulesDescription', a.TECHRulesAppliedDescription__c);

                            if(a.LastModifiedBy.Name == null)
                            genResults.writeNullField('LastModifiedBy');  
                            else
                            genResults.writeStringField('LastModifiedBy', a.LastModifiedBy.Name);

                            
                            genResults.writeDateTimeField('LastModifiedDate', a.LastModifiedDate);
                        genResults.writeEndObject();
                    }
                    
                    genResults.writeEndArray();

                    genResults.writeStringField('OperationType', 'getAssessment');
                    genResults.writeBooleanField('Success', true);
                    genResults.writeNullField('Warning');
                    genResults.writeNullField('ErrorMessage');

                    genResults.writeEndObject();

                }else{
                    genResults = JSON.createGenerator(false);
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'getAssessment');
                        genResults.writeBooleanField('Success', false);
                        genResults.writeNullField('Warning');
                        genResults.writeStringField('ErrorMessage', 'No Assessment.');
                    genResults.writeEndObject();
                }
                results = genResults.getAsString();
            }

            system.debug('// res: '+results);
        }catch(Exception ex){
            genResults = JSON.createGenerator(false);
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'getAssessment');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                genResults.writeStringField('ErrorMessage', ex.getMessage());
            genResults.writeEndObject();
            results = genResults.getAsString();
        }

        RestContext.response.responseBody = Blob.valueOf(results);

        //return results;
    }*/

	@HttpPost
	global static void getAssessment() {
		list<AssessmentIDWrapper> assessIdsSet = new list<AssessmentIDWrapper>();
		Set<String> assessmentIdSet = new Set<String>();
		String body = RestContext.request.requestBody.toString();
		JSONGenerator genResults;
		String results = '';

		Log__c log = new Log__c();
		log.DateLog__c = system.now();

		// ABT - C-001728 - 22-SEP-2016
		log.Class__c   = 'RESTGetAssessment_V1';

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

		try 
		{
			//create json parser
			JSONParser parser = JSON.createParser(body);
            
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					while (parser.nextToken() != null) {
						if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
							//parse block of Assessment into helper class Assessment
							AssessmentIDWrapper a = (AssessmentIDWrapper)parser.readValueAs(AssessmentIDWrapper.class);
							parser.skipChildren();
							//system.debug(' // assessmet parser: ' + a);
							assessIdsSet.add(a);
						}
					}
				}
			}
			//system.debug('////assessIdsSet: '+assessIdsSet);

			if (assessIdsSet.size() > 0){
				for (AssessmentIDWrapper aiw : assessIdsSet)
				{
					assessmentIdSet.add(aiw.AssessmentReference);
				}

			
				//System.debug('/// assessmentIdSet : ' +  assessmentIdSet);
				if(assessmentIdSet.size() >0){
					List<Assessment__c> assessmentList = new List<Assessment__c>();
					assessmentList = [select Id,AssessmentID__c,Status__c,TECHRulesAppliedDescription__c,LastModifiedBy.Name,LastModifiedDate
											from Assessment__c 
											where AssessmentID__c in :assessmentIdSet];
					if (assessmentList.size() >0)
					{
						genResults = JSON.createGenerator(false);
						genResults.writeStartObject();
						genResults.writeFieldName('Assessments');
						genResults.writeStartArray();
						for(Assessment__c a : assessmentList){
							genResults.writeStartObject();
								genResults.writeStringField('AssessmentReference', a.AssessmentID__c);

								if(a.Status__c != null)
								genResults.writeStringField('Status', a.Status__c);

								if(a.TECHRulesAppliedDescription__c != null)
								genResults.writeStringField('RulesDescription', a.TECHRulesAppliedDescription__c);

								if(a.LastModifiedBy.Name != null)
								genResults.writeStringField('LastModifiedBy', a.LastModifiedBy.Name);
                            
								genResults.writeDateTimeField('LastModifiedDate', a.LastModifiedDate);
							genResults.writeEndObject();
						}
                    
						genResults.writeEndArray();

						genResults.writeStringField('OperationType', 'getAssessment');
						genResults.writeBooleanField('Success', true);
						genResults.writeNullField('Warning');
						genResults.writeNullField('ErrorMessage');

						genResults.writeEndObject();
					}else{
						genResults = JSON.createGenerator(false);
						genResults.writeStartObject();
							genResults.writeStringField('OperationType', 'getAssessment');
							genResults.writeBooleanField('Success', false);
							genResults.writeNullField('Warning');
							genResults.writeStringField('ErrorMessage', 'No Assessment.');
						genResults.writeEndObject();
					}
				}
			}

			results = genResults.getAsString();
			//system.debug('// res: '+results);
		}catch(Exception ex){
			genResults = JSON.createGenerator(false);
			genResults.writeStartObject();
				genResults.writeStringField('OperationType', 'getAssessment');
				genResults.writeBooleanField('Success', false);
				genResults.writeNullField('Warning');
				genResults.writeStringField('ErrorMessage', ex.getMessage());
			genResults.writeEndObject();
			results = genResults.getAsString();
		}

		if (results.length() <= 30000)
		{
			log.JSONResponse__c = String.valueOf(Blob.valueOf(results));
			update log;
		}else{
			// ABT - C-001728 - 22-SEP-2016
			//APCreateAttachments.createAttachment(results,log);
			APCreateAttachments.createAttachment('Response', results, log);
		}

		RestContext.response.responseBody = Blob.valueOf(results);
	}

	public class AssessmentIDWrapper{
		public String AssessmentReference;
	}
}