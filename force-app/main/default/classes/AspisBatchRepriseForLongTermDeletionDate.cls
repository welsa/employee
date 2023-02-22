global class AspisBatchRepriseForLongTermDeletionDate implements Database.Batchable<sObject> {
/*
  ----------------------------------------------------------------------
  -- - Name          : AspisBatchRepriseForLongTermDeletionDate
  -- - Author        : RLA
  -- - Description   : Batch to calculate long term deletion date for assessments
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 20-May2018  RLA   1.0     Initial version
  ----------------------------------------------------------------------
  Execution Code:
  Date startDate = date.newInstance(2012, 1, 1);
  Date endDate = date.newInstance(2018, 4, 1);
  Set<Id> setassessmentId = new set<Id> {'a000E000004NHB2QAO'};
  Database.executeBatch(new AspisBatchRepriseForLongTermDeletionDate(startDate,endDate, assessmentId), 200);
  **********************************************************************/   	
	String query;
  	public set<Id> setParentAsmnt = new set<Id>();
  	public set<Id> setAsmnt = new set<Id>();
    private static Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMappings;
	
	global AspisBatchRepriseForLongTermDeletionDate(date startDate, date endDate, set<Id> setassessment) {   
        
    string startDateLiteral = startDate  != null ? (DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0))).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') : null;
    string endDateLiteral = endDate != null ? (DateTime.newInstance(endDate, Time.newInstance(23, 59, 0, 0))).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') : null;

    query = 'SELECT  Id, RecordType.Name, RecordTypeId, TECH_EntityCountryCode__c, LastModifiedDate, Status__c,ParentAssessment__c ' +    
          	' FROM    Assessment__c  where LongTermDeletionDate__c = null ' +
          	' And (RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() + '\'' +
          	' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId() + '\')';
            //' limit 100';

        
      	if (setassessment != null && setassessment.size() > 0){
	        setAsmnt.addAll(setassessment);
	        query += ' and Id IN : setAsmnt'  ;   
      	}

      	if (startDateLiteral != null){
      		query += ' and LastModifiedDate >=' + startDateLiteral;
      	}

      	if (endDateLiteral != null){
      		query += ' and LastModifiedDate <=' + endDateLiteral;
      	}

      	

      	system.debug('### query1' + query);
      	system.debug('### setAsmnt' + setAsmnt);

    
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {

   		Map<Id, Assessment__c> mapAssessmentToUpdate = new Map<Id, Assessment__c>();
   		AP36AssessmentPurge.populateCountryCodeMappings();
   		for (Assessment__c asmnt: scope){

        if ( asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
          || asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() 
          || asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()
          ){        
          
     			if (asmnt.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED){
            asmnt.LongTermDeletionDate__c = AP36AssessmentPurge.setNonEligibleAsmntDeletionDate(asmnt.LastModifiedDate, asmnt.TECH_EntityCountryCode__c );
          }
          else{
            asmnt.LongTermDeletionDate__c = AP36AssessmentPurge.setEligibleAsmntDeletionDate(asmnt.LastModifiedDate, asmnt.TECH_EntityCountryCode__c);
          }
     			system.debug('@@asmnt batch'+asmnt.RecordType.Name+' ; '+asmnt.LongTermDeletionDate__c);
     			mapAssessmentToUpdate.put(asmnt.Id, asmnt);
        }

   		}

   		system.debug('## mapAssessmentToUpdate:'+mapAssessmentToUpdate);
   		if (mapAssessmentToUpdate.size() > 0){
   			update mapAssessmentToUpdate.values();
        
        
   		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}


	
	
}