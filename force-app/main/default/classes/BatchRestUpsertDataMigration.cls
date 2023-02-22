global class BatchRestUpsertDataMigration implements Database.Batchable<sObject>,Database.Stateful{ 
/*************************************************************************************
Class Name - BatchRestUpsertDataMigration
Function   - Batch to level up data for key construction for restupsertAssessment
           - (cleaning up crash code in key,migrating crash code from crash assessment
              to claim assessment, plus level up all key used for upsert)

Modification Log :
-------------------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  ---------------------------------------------------------
* Abdool M      03/10/2017  Initial Version (C-001969)
*************************************************************************************/
    /*global Map<Id, String> errorMap {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}

    global BatchRestUpsertDataMigration(){
        errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,ParentAssessment__c from Assessment__c where recordtype.developername = 'Crash' and ParentAssessment__c != null]);
    }

    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {
        system.debug('##BatchRestUpsertDataMigration - Start execute');
        
        //list used to update claim assessment assessmentid
        list <Assessment__c> lstAssessmentToUpdate                                          = new list <Assessment__c>();
        
        //set to get claim record
        set <id> setClaimId                                                                 = new set <id>();

        //build setClaimId
        for(Assessment__c ass : [select id,ParentAssessment__c
                                    from Assessment__c
                                    where id IN :scope]){
            setClaimId.add(ass.ParentAssessment__c);
        }
        system.debug('## setClaimId ' + setClaimId);

        //update claim assessment
        for(Assessment__c ass : [select id,name,AssessmentID__c
                                    from Assessment__c
                                    where id IN :setClaimId
                                    and AssessmentID__c != null
                                    and TECH_DataFixDone__c = false]){
            //add null to claim AssessmentID__c since null will be added to it as there won't be any crashcode sent on assessment
            string reworkedAssId                                                            = ass.AssessmentID__c + 'NULL';

            lstAssessmentToUpdate.add(new Assessment__c(id = ass.id,
                                                        Name = ass.name,
                                                        AssessmentID__c =reworkedAssId,
                                                        TECH_DataFixDone__c = true));                                                           
        }

        system.debug('## lstAssessmentToUpdate ' + lstAssessmentToUpdate);
        if(!lstAssessmentToUpdate.isEmpty()){
            list <Database.SaveResult> dsrs                                                 = Database.Update(lstAssessmentToUpdate, false);
            
            integer index                                                                   = 0;
            
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    string errMsg = dsr.getErrors()[0].getMessage();
                    errorMap.put(lstAssessmentToUpdate[index].Id, errMsg);
                    IdToSObjectMap.put(lstAssessmentToUpdate[index].Id, lstAssessmentToUpdate[index]);
                }
                index++;
            }
        }

        system.debug('##BatchRestUpsertDataMigration - End execute');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('##BatchRestUpsertDataMigration - Start finish');
        if(!errorMap.isEmpty()){
            string body                                                                     = 'Your batch job BatchRestUpsertDataMigration has finished. \n' 
                                                                                            + 'There were ' + errorMap.size() + ' errors. Please find the error list attached to this mail.';
            // Creating the CSV file
            string finalstr                                                                 = 'Id, Name, Error \n';
            string subject                                                                  = 'Data Fix - Apex Batch Error List';
            string attName                                                                  = 'Data Fix Errors.csv';
            
            for(Id id  : errorMap.keySet()){
                string err                                                                  = errorMap.get(id);
                Assessment__c ass                                                           = (Assessment__c) IdToSObjectMap.get(id);
                string recordString                                                         = '"' + id + '","' + ass.Name + '","' + err + '"\n';
                finalstr                                                                    = finalstr + recordString;
            } 

            // Define the email
            Messaging.SingleEmailMessage email                                              = new Messaging.SingleEmailMessage(); 

            // Create the email attachment    
            Messaging.EmailFileAttachment efa                                               = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));

            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new string[] {system.label.DataFixAdmin} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

            // Sends the email
            Messaging.SendEmailResult [] r                                                  = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }
        system.debug('##BatchRestUpsertDataMigration - End finish');
    }*/

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([select id, BodyShop__r.Type, ExpertSubstitutionMethod__c,
                                                (Select RecommendedByAS__c, Alpha_Scale_MRID__c, Price__c, OriginalPart__c, OriginalPart__r.RecommendedByAS__c, Assessment__c, Assessment__r.BodyShop__r.Type, Assessment__r.ExpertSubstitutionMethod__c from PartsLists__r)
                                         from Assessment__c 
                                         where RecordTypeId =: Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() and CreatedDate >= 2018-03-05T00:00:00Z and CreatedDate <= 2018-03-23T00:00:00Z  ]);
                                        // where CreatedDate = :system.today()
                                        //where Id in ('a007E000007IYDr', 'a007E000007IYDX', 'a007E000007IYDc')     ]);
    }

    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {
        system.debug('## Start BatchRestUpsertDataMigration.execute');

        map<String, Partlist__c> originalMap = new map<String, Partlist__c>();
        //map<originalId, list<substitutes>>;
        map<String, list<Partlist__c>> oriSubstitutesMap = new map<String, list<Partlist__c>>();
        list<Partlist__c> toUpdatePlList = new list<Partlist__c>();
        for(Assessment__c ass: scope){
        	system.debug('## ass:'+ass);
            if(ass.PartsLists__r.size() > 0){
                for(Partlist__c pl : ass.PartsLists__r){
                    if(pl.OriginalPart__c != null){
                        // choose best price of ascr
                        if(!oriSubstitutesMap.containsKey(pl.OriginalPart__c)){
                            oriSubstitutesMap.put(pl.OriginalPart__c, new List<Partlist__c>{pl});
                        }
                        else{
                            oriSubstitutesMap.get(pl.OriginalPart__c).add(pl);
                        }                       
                    }
                    else{
                        originalMap.put(pl.Id, pl);
                    }
                }
                system.debug('## originalMap:'+originalMap);
                system.debug('## oriSubstitutesMap:'+oriSubstitutesMap);

                set<Id> processedOriginalSet = new set<Id>();
                for(Partlist__c pl : ass.PartsLists__r){
                    if(pl.RecommendedByAS__c == false){
                        Id idtoProcess = (pl.OriginalPart__c != null) ? Id.valueOf(pl.OriginalPart__c) : pl.Id;
                        if(!processedOriginalSet.contains(idtoProcess)){
                            if(requiresCheck(idtoProcess, oriSubstitutesMap, originalMap)){
                                // when Expert AND Proposed, original should be checked
                                system.debug('## ase:'+pl.Assessment__r.BodyShop__r.Type + ' '+ pl.Assessment__r.ExpertSubstitutionMethod__c + ' '+ pl.OriginalPart__c);
                                if((pl.Assessment__r.BodyShop__r.Type == 'Expert' && (pl.Assessment__r.ExpertSubstitutionMethod__c == 'PROPOSED'|| pl.Assessment__r.ExpertSubstitutionMethod__c == 'NONE'))){
                                   //toUpdatePlList.add(new Partlist__c(id= pl.Id , RecommendedByAS__c = true));
                                    toUpdatePlList.add(new Partlist__c(id= idtoProcess , RecommendedByAS__c = true));
                                }
                                if(pl.Assessment__r.BodyShop__r.Type == 'Standard' || pl.Assessment__r.ExpertSubstitutionMethod__c == 'FORCED'){
                                    toUpdatePlList.add(new Partlist__c(id= getBestPriceSubstitute(idtoProcess, oriSubstitutesMap) , RecommendedByAS__c = true));
                                }

                            }
                            processedOriginalSet.add(idtoProcess);                      
                        }
                    }
                }               
            }
        }
        if(toUpdatePlList.size() > 0){
            system.debug('## toUpdatePlList:'+toUpdatePlList);
            update toUpdatePlList;
        }
        system.debug('## End BatchRestUpsertDataMigration.execute');
    }

    global void finish(Database.BatchableContext BC) {
    }

    global static Boolean requiresCheck(Id idtoProcess, map<String, list<Partlist__c>> oriSubstitutesMap, map<String, Partlist__c> originalMap){
        system.debug('## start requiresCheck ');
        Boolean requiresCheck = true;
        if(originalMap.containsKey(idtoProcess) && originalMap.get(idtoProcess).RecommendedByAS__c == true){
            requiresCheck = false;
        }
        else{
            if(oriSubstitutesMap.containsKey(idtoProcess)){
                for(Partlist__c pl : oriSubstitutesMap.get(idtoProcess)){
                    if(pl.RecommendedByAS__c == true){
                        requiresCheck = false;      
                        break;                                      
                    }
                }
            }
        }
        system.debug('## end requiresCheck: '+requiresCheck);
        return requiresCheck;
    }

    global static Id getBestPriceSubstitute(Id idtoProcess, map<String, list<Partlist__c>> oriSubstitutesMap){
        system.debug('## start getBestPriceSubstitute');
        decimal lowestPrice = 0; 
        Id lowestPriceSub = null;
        if(oriSubstitutesMap.containsKey(idtoProcess)){
            if((oriSubstitutesMap.get(idtoProcess)).size() == 1){
                lowestPriceSub = oriSubstitutesMap.get(idtoProcess)[0].Id;
            }
            else{                
                for(Partlist__c pl : oriSubstitutesMap.get(idtoProcess)){
                    if(lowestPrice == 0){
                        lowestPrice = pl.Price__c;
                        lowestPriceSub = pl.Id;
                    }
                    else if(lowestPrice > pl.Price__c){
                        lowestPrice = pl.Price__c;
                        lowestPriceSub = pl.Id;
                    }
                    else{
                        lowestPrice = lowestPrice;
                        lowestPriceSub = lowestPriceSub;
                    }
                }
            }
        }
        else{
            lowestPriceSub = idtoProcess;
        }
        system.debug('## end getBestPriceSubstitute: '+lowestPriceSub);
        return lowestPriceSub;          
    }
}