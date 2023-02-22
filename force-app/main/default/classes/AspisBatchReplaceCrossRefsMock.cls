global class AspisBatchReplaceCrossRefsMock implements Database.Batchable<sObject>, Database.Stateful {
/*
----------------------------------------------------------------------
-- - Name          : AspisBatchReplaceCrossRefsMock
-- - Author        : RLA
-- - Description   : Class to create csv of deactivated crossrefs to be replaced
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

Database.executeBatch(new AspisBatchReplaceCrossRefsMock(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist), 200);
----------------------------------------------------------------------*/    
    String query;
    String sTrStartDeactivationDateXref;
    String sTrEndDeactivationDateXref;
    Datetime strCreatedDateXref;
    Datetime strStartCreatedDatePartlist;
    Datetime strEndCreatedDatePartlist; 
    private List<String> lstStringPartList = new list<String>();
    
    global AspisBatchReplaceCrossRefsMock(Date startDeactivationDateXref,
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
        Map<String,CrossReference__c> mapCrossRefdeac = new map<String,CrossReference__c>();
        map<String,CrossReference__c> mapCrossRefac = new map<String,CrossReference__c>();
        map<String,DistributorPrice__c> mapDistPriceac = new map<String,DistributorPrice__c>();
        

        for (CrossReference__c cf: scope){
            string key = cf.CountryCode__c+cf.LanguageCode__c+cf.OEMCleanPartNumber__c+cf.IAMCleanPartNumber__c+cf.OEMManufacturer__c+cf.IAMManufacturer__c;                            
            mapCrossRefdeac.put(key, cf);
            setIdCrossrefsDeac.add(cf.Id);
            setKeysDeac.add(key+'%');
        }
        system.debug('@@@ mapCrossRefdeac:'+mapCrossRefdeac);


        for (CrossReference__c cf: [SELECT Id,OEMCleanPartNumber__c,Name,
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
            mapCrossRefac.put(key, cf);
            setIdCrossrefsAct.add(cf.Id);
            //mapDistPriceac.put(key, dp.Id);
        }   
        system.debug('@@@ mapCrossRefac:'+mapCrossRefac);

        for (DistributorPrice__c dp: [SELECT Id,CrossReference__c, CrossReference__r.OEMCleanPartNumber__c,Name,
                                    CrossReference__r.IAMCleanPartNumber__c,CrossReference__r.IAMManufacturer__c,
                                    CrossReference__r.OEMManufacturer__c,CrossReference__r.CountryCode__c, 
                                    CrossReference__r.CrossReferenceExtID__c,CrossReference__r.LanguageCode__c 
                                    FROM DistributorPrice__c where CrossReference__c IN:setIdCrossrefsAct
                                    AND Active__c = true AND isDeleted__c = false
                                    
                                     ]){
            string key = dp.CrossReference__r.CountryCode__c+dp.CrossReference__r.LanguageCode__c+dp.CrossReference__r.OEMCleanPartNumber__c+dp.CrossReference__r.IAMCleanPartNumber__c+dp.CrossReference__r.OEMManufacturer__c+dp.CrossReference__r.IAMManufacturer__c;       
            //mapCrossRefac.put(key, dp.CrossReference__r.Id);
            mapDistPriceac.put(key, dp);
        }
        system.debug('@@@ mapDistPriceac:'+mapDistPriceac);


        integer count = 0;

        for(PartList__c part: [SELECT Id,CrossReferenceId__c,CrossReferenceId__r.CountryCode__c, CrossReferenceId__r.LanguageCode__c, 
                                CrossReferenceId__r.OEMCleanPartNumber__c,CrossReferenceId__r.IAMCleanPartNumber__c,
                                Assessment__c, CrossReferenceId__r.Name, DistributorPriceId__r.Name,
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

            system.debug('@@ CrossReferenceId__c: '+part.CrossReferenceId__c) ;  
            if (mapCrossRefdeac.containskey(key)){

            //system.debug('@@ mapCrossRefdeac    : '+mapCrossRefdeac.get(key).Id) ;    
                if (mapCrossRefdeac.get(key).Id == part.CrossReferenceId__c){
                    String oldCrossrefId = part.CrossReferenceId__c;
                    String oldCrossrefName = part.CrossReferenceId__r.Name;
                    String oldDisPriceId = part.DistributorPriceId__c;
                    String oldDisPriceName =  part.DistributorPriceId__r.Name;
                    String newDisPriceName =  null;

                    if (mapCrossRefac.containskey(key)){
                        part.CrossReferenceId__c = mapCrossRefac.get(key).Id;
                        if (mapDistPriceac.containskey(key)){
                            part.DistributorPriceId__c = mapDistPriceac.get(key).Id;
                            newDisPriceName = mapDistPriceac.get(key).Name;
                        }


                        lstStringPartList.add(part.Assessment__c + ',' + part.Id + ',' + oldCrossrefId + ',' + oldCrossrefName + ',' + part.CrossReferenceId__c + ','+ mapCrossRefac.get(key).Name + ',' +oldDisPriceId + ','+ oldDisPriceName + ',' + part.DistributorPriceId__c + ',' +  newDisPriceName + '\n' );
                    }
                }
            }  
        }
        system.debug('@@@ lstStringPartList:'+lstStringPartList);

            
            

   //     if (lstStringPartList.size() > 0){
            ////String header = 'PartListID, Old CrossReference, New CrossReference, Old DistributorPrice, New DistributorPrice';
            //String header =  'AssessmentId, PartListID, Old CrossReferenceID, Old CrossReferenceName, New CrossReferenceId, New CrossReferenceName, Old DistributorPriceId, Old DistributorPriceName, New DistributorPriceId, New DistributorPriceName';
            //String csvStr = createCSV(header,lstStringPartList );
   //       attachment  = new Attachment(Body= Blob.valueOf(csvStr),
            //                           Name= 'Results.csv'
            //                          );
   //       log.Status__c = Label.STATUSPASSED;
          

      //      insert log;
      //      attachment.ParentId = log.Id;

      //     insert attachment;
   //     }
        
    
    }
    
    global void finish(Database.BatchableContext BC) {

        if (lstStringPartList.size() > 0){

            Log__c log = new log__c();
            log.Class__c = 'AspisBatchReplaceCrossRefsMock';
            log.sObject__c = 'PartList__c';
            log.DateLog__c = Datetime.now();  
            //String header = 'PartListID, Old CrossReference, New CrossReference, Old DistributorPrice, New DistributorPrice';
            String header =  'AssessmentId, PartListID, Old CrossReferenceID, Old CrossReferenceName, New CrossReferenceId, New CrossReferenceName, Old DistributorPriceId, Old DistributorPriceName, New DistributorPriceId, New DistributorPriceName';
            String csvStr = createCSV(header,lstStringPartList );
            Attachment attachment   = new Attachment(Body= Blob.valueOf(csvStr),
                                                     Name= 'Results.csv'
                                                    );
            log.Status__c = Label.STATUSPASSED;
          

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