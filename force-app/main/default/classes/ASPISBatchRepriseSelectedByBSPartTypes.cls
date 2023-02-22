/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchRepriseSelectedByBSPartTypes 
  -- - Author        : WCH
  -- - Description   : Class populating Assessment__c.SelectedByBSPartTypes__c so that extraction by to BI can correctly extract this field.
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-JUL-2020  WCH    1.0     C-003846 - Selected by BS Part Types field is not updated if Part List field "selected" is updated
  -- 20-AUG-2020  KPA    1.1     C-003898 - The field Selected by BS Part Type in the Assessement object should not take parts with no reference or N/A (currently labeled as A parts) into account
  -- 10-SEP-2020  KPA    1.2     C-003933 - Batch that updates Selected by BS Part Type field does not take into account assessments with just one part
  -- 21-SEP-2020  KPA    1.3     C-003947 - Exclude Part List part type values from Selected by BS Part Type field
  -----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class ASPISBatchRepriseSelectedByBSPartTypes implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    String errorMsg;

    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new ASPISBatchRepriseSelectedByBSPartTypes(), 200);  
    }
    public Database.QueryLocator start(Database.BatchableContext bc)
	{
        String query = 'select Id '+
                    ' From Assessment__c ' +
                    ' Where recordtype.name IN '+System.label.BI_OnDemandExtraction_AssessmentRT+' and TECH_EntityCountryCode__c IN ' + (Test.isRunningTest() ? '(\'FR\',\'IT\',\'DE\',\'ES\')' : System.label.BI_OnDemandExtraction_CountryCodeList) + ' AND CALENDAR_YEAR(createddate) IN '+(Test.isRunningTest() ? ('('+Date.Today().Year()+')') : System.label.BI_OnDemandExtraction_YearList);
        return Database.getQueryLocator(query);
    } 

    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {

        System.debug('---------------------------------- START ASPISBatchRepriseSelectedByBSPartTypes - execute ----------------------------------');
        System.debug('ASPISBatchRepriseSelectedByBSPartTypes scope>>'+scope.size());
        List<Assessment__c> listAssessmentToUpdate = new List<Assessment__c>();
        Set<Id> setAssIds = new Set<Id>();
        Map<Id,Set<String>> mapAssIdPartTypes = new Map<Id,Set<String>>();
        
        for(Assessment__c currentAss : scope){
            setAssIds.add(currentAss.Id);
        }
        String queryPartLists = 'select count(Id), Type__c,Assessment__c From PartList__c Where SelectedByBS__c=true and isDeleted__c=false and Type__c!=null and Type__c!=\'\' and  RecordType.name<>\'Labour\' and Price__c >0 and Quantity__c>0 and PartNumber__c NOT IN('+System.Label.FakeReferences+') and Assessment__c IN : setAssIds group by Assessment__c,Type__c order by Assessment__c '; 
        //KPA C-003898  20/08/2020
        //KPA C-003947  21/09/2020
        for(AggregateResult currentAggRslt : Database.query(queryPartLists)){
            if((Integer)currentAggRslt.get('expr0')>0){
                if(!mapAssIdPartTypes.containsKey((ID)currentAggRslt.get('Assessment__c'))){
                    mapAssIdPartTypes.put((ID)currentAggRslt.get('Assessment__c'),new Set<String>{(String)currentAggRslt.get('Type__c')});
                }else{
                    mapAssIdPartTypes.get((ID)currentAggRslt.get('Assessment__c')).add((String)currentAggRslt.get('Type__c'));
                }
            }
        }

        for (Id currentAssessmentId : mapAssIdPartTypes.keySet()){
            listAssessmentToUpdate.add(new Assessment__c(Id=currentAssessmentId,SelectedByBSPartTypes__c=(String.join((Iterable<String>)mapAssIdPartTypes.get(currentAssessmentId), ';'))));
        }
        
        //~~ KPA 3933 10/09/2020
          setAssIds.removeAll(mapAssIdPartTypes.keySet());  
        
        for (Id currentAssessmentId : setAssIds){
            listAssessmentToUpdate.add(new Assessment__c(Id=currentAssessmentId,SelectedByBSPartTypes__c=''));
        }
        
       //~~ 
        System.debug('ASPISBatchRepriseSelectedByBSPartTypes mapAssIdPartTypes>>'+mapAssIdPartTypes);
        System.debug('ASPISBatchRepriseSelectedByBSPartTypes listAssessmentToUpdate>>'+listAssessmentToUpdate);
        if(listAssessmentToUpdate.size() > 0){
            Database.SaveResult[] srList = Database.update(listAssessmentToUpdate, false);Integer i=0;
            for(Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg+=(listAssessmentToUpdate.get(i).Id+';'+err.getStatusCode() + ': ' + err.getMessage()+'.Fields that affected this error:'+err.getFields()+'\n');
                    }
                }/* else{
                    errorMsg+=(listAssessmentToUpdate.get(i).Id+';Success'+'\n');
                } */
                i++;
            }
        }
        
        System.debug('---------------------------------- END ASPISBatchRepriseSelectedByBSPartTypes - execute ----------------------------------');
        
    }

    global void finish(Database.BatchableContext context) {
        Document d = new Document();
        d.Name = 'ASPISBatchRepriseSelectedByBSPartTypes_'+(System.today().format());
        String myContent = String.isBlank(errorMsg)?'NO DATA':errorMsg;
        d.folderId='00l24000000n9pq';
        d.Body = Blob.valueOf(myContent);
        d.ContentType = 'text/plain';
        d.Type = 'txt';insert d;
    }

}