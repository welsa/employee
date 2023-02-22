global with sharing class VFC_PostAssessmentPostSO {
/*************************************************************************************
Class Name - VFC_PostAssessmentPostSO  
Function   - Relaunch whole process for postAssessment and postSalesOrder

--------------------------------------------------------------------------------------
* Developer         Date         Description 
* ----------     	----------   -----------------------------------------------------
* Abdool M          04/10/2017   Initial Version
* Abdool M          13/11/2017   Adding "ICE SO - OK" to return type os that latter 
* 								 can be displayed in madal during relaunch
* Abdool M          26/02/2018   Bulkifying Update On SO (adding new param to RESTPostSalesOrder.buildJSON method)
*************************************************************************************/ 
	global VFC_PostAssessmentPostSO(ApexPages.StandardController sc){ 
		system.debug('## Start constructor');

		
		system.debug('## End constructor');
	}

	@RemoteAction
	global static string launchPostAssessmentCallOut(string SOId){
		system.debug('## Start launchPostAssessmentCallOut');

		Set<String> igEntitySet                                         = String.isBlank(Label.ASFRIGEntity) ? new Set<String>() : new Set<String>(Label.ASFRIGEntity.split(';'));

		//assessment related to SO
		string assId 													= '';

		//check if so is valid for post assessment callout
		boolean isValidForPostAss 										= false;

		//this set will be used as input parameter to PostAssessment
		set <id> assIdList												= new set <id>();

		//query assessment related to SO
		if(string.isNotBlank(SOId)){
			for(PrerequisiteOrder__c so : [select id,Status__c,Assessment__c,TECH_AssessmentEntityRules__c
											from PrerequisiteOrder__c
											where id = :SOId]){
				if(so.Assessment__c != null){
					assId 												= so.Assessment__c;
				}

				if(so.Assessment__c != null && 
                    igEntitySet.contains(so.TECH_AssessmentEntityRules__c)){
						isValidForPostAss 								= true;
				}
			}
		}//end string.isNotBlank(SOId)

		//launch ws callout
		if(string.isNotBlank(assId) && isValidForPostAss){
			assIdList.add(assId);

			//launch post assessment
			RESTPostAssessment.callOutStatus resultPostAss 				= RESTPostAssessment.buildJSON(assIdList);

			if(resultPostAss.isSuccessful){
				return 'OK;';
			}else{
				return 'KO;' + resultPostAss.statusMessage;
			}
		}else{
			return 'KO;' +  system.label.SOWSNotValid;
		}

		system.debug('## End launchPostAssessmentCallOut');
		return '';
	}

	@RemoteAction
	global static string launchPostSalesOrderCallOut(string SOId){
		system.debug('## Start launchPostSalesOrderCallOut');

		//this set will be used as input parameter to PostSalesOrder
		set <id> soIdList 												= new set <id>();

		if(string.isNotBlank(SOId)){
			soIdList.add(SOId);

			//AMI 26/02/18 : Bulkifying Update On SO (adding new param to RESTPostSalesOrder.buildJSON method)
			//launch post SO
			RESTPostAssessment.callOutStatus resultPostSO 				= RESTPostSalesOrder.buildJSON(soIdList,true);

			if(resultPostSO.isSuccessful){
				return 'OK;ICE SO - OK';
			}else{
				return 'KO;' + resultPostSO.statusMessage;
			}
		}//end if string.isNotBlank(SOId)

		system.debug('## End launchPostSalesOrderCallOut');
		return '';
	}
}