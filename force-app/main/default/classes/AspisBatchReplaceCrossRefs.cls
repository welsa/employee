global class AspisBatchReplaceCrossRefs implements Database.Batchable<sObject> , Database.Stateful {
/*
----------------------------------------------------------------------
-- - Name          : AspisBatchReplaceCrossRefs
-- - Author        : RLA
-- - Description   : Class to replace deactivated crossrefs
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 24-JAN-20109  RLA   1.0      Initial version
Date startDeactivationDateXref = date.newInstance(2018, 08, 13);
Date endDeactivationDateXref = date.newInstance(2019, 01, 25);
Datetime createdDateXref = Datetime.newInstance(2019, 01, 25, 9, 0, 0);
Datetime startCreatedDatePartlist = Datetime.newInstance(2018, 01, 25, 9, 0, 0);
Datetime endCreatedDatePartlist = Datetime.newInstance(2019, 01, 25, 9, 0, 0);

Database.executeBatch(new AspisBatchReplaceCrossRefs(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist), 200);
----------------------------------------------------------------------*/ 	
	String query;
	String sTrStartDeactivationDateXref;
	String sTrEndDeactivationDateXref;
	Datetime strCreatedDateXref;
	Datetime strStartCreatedDatePartlist;
	Datetime strEndCreatedDatePartlist;        
	private List<String> lstErroredPartList = new list<String>();
	Boolean hasFailures;

	
	global AspisBatchReplaceCrossRefs(Date startDeactivationDateXref,
	                                 Date endDeactivationDateXref,
	                                 Datetime createdDateXref,
	                                 Datetime startCreatedDatePartlist,
	                                 Datetime endCreatedDatePartlist
	                                 ) {

        sTrStartDeactivationDateXref = String.valueOf(startDeactivationDateXref);
        sTrEndDeactivationDateXref = String.valueOf(endDeactivationDateXref);
        strCreatedDateXref = createdDateXref;
        strStartCreatedDatePartlist = startCreatedDatePartlist;
        strEndCreatedDatePartlist = endCreatedDatePartlist;

		query = 'SELECT CountryCode__c,CrossReferenceExtID__c,DeactivationDate__c,DeactivationReason__c, '+
				' IAMCleanPartNumber__c,IAMManufacturer__c,Id,LanguageCode__c,Name,OEMCleanPartNumber__c, '+
                ' OEMManufacturer__c,ProductSubSubCategory__c FROM CrossReference__c '+ 
                ' WHERE ActiveForSubstitution__c = false AND '+
                ' (DeactivationDate__c >= ' + sTrStartDeactivationDateXref + ' AND DeactivationDate__c <= '+sTrEndDeactivationDateXref +') '+
                ' AND CountryCode__c = \'FR\' AND LanguageCode__c = \'fr\' ';

         system.debug('@@ query: '+query);
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<CrossReference__c> scope) {
        system.debug('@@ scope: '+scope.size());

   		
   		set<id> setIdCrossrefsDeac = new set<Id>();
   		set<id> setIdCrossrefsAct = new set<Id>();
		set<String> setKeysDeac = new set<String>();
		Map<String,Id> mapCrossRefdeac = new map<String,Id>();
		map<String,Id> mapCrossRefac = new map<String,Id>();
		map<String,Id> mapDistPriceac = new map<String,Id>();
        List <Database.Saveresult> lstResultsPartListUpdate;


		map<Id,PartList__c> mapPartlistUpdate = new map<Id,PartList__c>();
		for (CrossReference__c cf: scope){
			string key = cf.CountryCode__c+cf.LanguageCode__c+cf.OEMCleanPartNumber__c+cf.IAMCleanPartNumber__c+cf.OEMManufacturer__c+cf.IAMManufacturer__c;                            
			mapCrossRefdeac.put(key, cf.Id);
			setIdCrossrefsDeac.add(cf.Id);
			setKeysDeac.add(key+'%');
		}
		system.debug('@@@ mapCrossRefdeac:'+mapCrossRefdeac);
		system.debug('@@@ strCreatedDateXref:'+strCreatedDateXref);
		system.debug('@@@ setKeysDeac:'+setKeysDeac);


		for (CrossReference__c cf: [SELECT Id,OEMCleanPartNumber__c,
									IAMCleanPartNumber__c,IAMManufacturer__c,
									OEMManufacturer__c,CountryCode__c, 
									CrossReferenceExtID__c,LanguageCode__c 
									FROM CrossReference__c where CountryCode__c = 'FR' 
									AND LanguageCode__c = 'fr' 
									AND ActiveForSubstitution__c=true 
									AND CreatedDate >= :strCreatedDateXref 
									AND CrossReferenceExtID__c LIKE :setKeysDeac
		                             ]){
		    string key = cf.CountryCode__c+cf.LanguageCode__c+cf.OEMCleanPartNumber__c+cf.IAMCleanPartNumber__c+cf.OEMManufacturer__c+cf.IAMManufacturer__c;       
			mapCrossRefac.put(key, cf.Id);
			setIdCrossrefsAct.add(cf.Id);
			//mapDistPriceac.put(key, dp.Id);
		}	
		system.debug('@@@ mapCrossRefac:'+mapCrossRefac);

		for (DistributorPrice__c dp: [SELECT Id,CrossReference__c, CrossReference__r.OEMCleanPartNumber__c,
									CrossReference__r.IAMCleanPartNumber__c,CrossReference__r.IAMManufacturer__c,
									CrossReference__r.OEMManufacturer__c,CrossReference__r.CountryCode__c, 
									CrossReference__r.CrossReferenceExtID__c,CrossReference__r.LanguageCode__c 
									FROM DistributorPrice__c where CrossReference__c IN:setIdCrossrefsAct
									AND Active__c = true AND isDeleted__c = false
									
		                             ]){
		    string key = dp.CrossReference__r.CountryCode__c+dp.CrossReference__r.LanguageCode__c+dp.CrossReference__r.OEMCleanPartNumber__c+dp.CrossReference__r.IAMCleanPartNumber__c+dp.CrossReference__r.OEMManufacturer__c+dp.CrossReference__r.IAMManufacturer__c;       
			//mapCrossRefac.put(key, dp.CrossReference__r.Id);
			mapDistPriceac.put(key, dp.Id);
		}
		system.debug('@@@ mapDistPriceac:'+mapDistPriceac);

		for(PartList__c part: [SELECT Id,CrossReferenceId__c,CrossReferenceId__r.CountryCode__c, CrossReferenceId__r.LanguageCode__c, 
								CrossReferenceId__r.OEMCleanPartNumber__c,CrossReferenceId__r.IAMCleanPartNumber__c,
		                       	CrossReferenceId__r.IAMManufacturer__c,CrossReferenceId__r.OEMManufacturer__c,DistributorPriceId__c,
		                       	CrossReferenceId__r.CrossReferenceExtID__c 
		                       	FROM PartList__c 
		                       	where PartNumber__c like 'ASCR-%' AND Type__c in ('A','E') 
		                       	AND CrossReferenceId__r.CountryCode__c = 'FR' 
		                       	AND CrossReferenceId__r.LanguageCode__c = 'fr' 
		                       	AND CrossReferenceId__r.ActiveForSubstitution__c=false 
		                       	AND CreatedDate>= :strStartCreatedDatePartlist AND CreatedDate<= :strEndCreatedDatePartlist
		                       	AND Assessment__r.RecordType.Name='Claim' AND CrossReferenceId__c IN: setIdCrossrefsDeac]){
		                           
			string key = part.CrossReferenceId__r.CountryCode__c+part.CrossReferenceId__r.LanguageCode__c+part.CrossReferenceId__r.OEMCleanPartNumber__c+
			    		part.CrossReferenceId__r.IAMCleanPartNumber__c+part.CrossReferenceId__r.OEMManufacturer__c+part.CrossReferenceId__r.IAMManufacturer__c;

			//system.debug('@@ CrossReferenceId__c: '+part.CrossReferenceId__c) ;  
			if (mapCrossRefdeac.containskey(key)){
				//system.debug('@@ got in 1: '+mapCrossRefdeac.get(key)) ;  

			//system.debug('@@ mapCrossRefdeac    : '+mapCrossRefdeac.get(key).Id) ;    
			    if (mapCrossRefdeac.get(key) == part.CrossReferenceId__c){
					//system.debug('@@ got in intermediate: ') ;  

			        if (mapCrossRefac.containskey(key)){
						//system.debug('@@ got in 2: '+mapDistPriceac.get(key)) ;  

			        	part.CrossReferenceId__c = mapCrossRefac.get(key);
			        	if (mapDistPriceac.containskey(key)){
			        		part.DistributorPriceId__c = mapDistPriceac.get(key);
			        	}
			        	
			        	mapPartlistUpdate.put(part.Id,part);
			        }
			    }
			}  
		}
		system.debug('@@@ mapPartlistUpdate:'+mapPartlistUpdate);

		if (mapPartlistUpdate.size() > 0){
			hasFailures = false;
            lstResultsPartListUpdate = Database.update(mapPartlistUpdate.values(), false);
            //error management
            for(Database.SaveResult sr : lstResultsPartListUpdate){
                if(!sr.isSuccess()){
                    //raise error
                    Database.Error error = sr.getErrors().get(0);
                    String errorMsg = error.getMessage();
					//system.debug('@@@ errorMsg:'+errorMsg);
					hasFailures = true;

                    lstErroredPartList.add(sr.getId() + ',KO,'+errorMsg+'\n');
                }
                else{
                	lstErroredPartList.add(sr.getId() + ',OK,'+'No Error'+'\n');	
                }
            }//end looping in result list
			//system.debug('@@@ lstErroredPartList:'+lstErroredPartList);


    //        Log__c log = new log__c();
    //        log.Class__c = 'AspisBatchReplaceCrossRefs';
    //        log.sObject__c = 'PartList__c';
    //        log.DateLog__c = Datetime.now();      

    //        if (lstErroredPartList.size() > 0){
				//String header = 'PartListID, Status, Error Message';
				//String csvStr = createCSV(header,lstErroredPartList );
    //        	attachment	= new Attachment(Body= Blob.valueOf(csvStr),
				//							 Name= 'Results.csv'
				//							);

    //        }
    //        if(hasFailures){
    //            log.Status__c = Label.STATUSFAILED;	
    //        }
    //        else{
    //            log.Status__c = Label.STATUSPASSED;
    //        } 

    //        insert log;
    //        attachment.ParentId = log.Id;

    //       insert attachment;
		}
	
	}
	
	global void finish(Database.BatchableContext BC) {	
		//system.debug('@@@ lstErroredPartList:'+lstErroredPartList);


        if (lstErroredPartList.size() > 0){
        	Attachment attachment;

        	Log__c log = new log__c();
	        log.Class__c = 'AspisBatchReplaceCrossRefs';
	        log.sObject__c = 'PartList__c';
	        log.DateLog__c = Datetime.now();     

			String header = 'PartListID, Status, Error Message';
			String csvStr = createCSV(header,lstErroredPartList );
        	attachment	= new Attachment(Body= Blob.valueOf(csvStr),
										 Name= 'Results.csv'
										);

        	if(hasFailures){
	            log.Status__c = Label.STATUSFAILED;	
	        }
	        else{
	            log.Status__c = Label.STATUSPASSED;
	        } 

	        insert log;
	        attachment.ParentId = log.Id;

	       insert attachment;

	    }
        
		
	}
	
	public String createCSV(string header,
							List<String> lstPartlist){

        //build status
        String finalstr = header + ' \n';

        for(string str : lstPartlist){
            finalstr += str;                         
        }

        finalstr = finalstr.removeEnd('\n');

        return finalstr;
	}
}