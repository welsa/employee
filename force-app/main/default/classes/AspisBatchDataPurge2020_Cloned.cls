global class AspisBatchDataPurge2020_Cloned implements schedulable,Database.Batchable<sObject>, Database.Stateful{
/*
----------------------------------------------------------------------
-- - Name          : AspisBatchDataPurge2020_Cloned
-- - Author        : WCH
-- - Description   : Class to delete data after interval
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 03-FEB-2020  WCH   1.0      Initial version
-- 31-AUG-2020  WCH   1.1      C-003913 - NOB - DEVS l'impact si on cr?e un nouveau recordtype pour les experts
  Database.executeBatch(new AspisBatchDataPurge2020_Cloned(), 200);
----------------------------------------------------------------------*/  
  String query;
  Set<String> countryCodesToPurge;
  private static String nowtime;
  global AspisBatchDataPurge2020_Cloned() {

    countryCodesToPurge = new Set<String>();
    Boolean isEnvSandbox = [select id,isSandbox from organization].isSandbox;
        
    List<AspisBatchDataPurge2020_Configs__mdt> getProperConfigs = [select id,MasterLabel,DateLiteral__c,EndDate__c,StartDate__c,UseDateLiteral__c,CountryCodeToPurge__c from AspisBatchDataPurge2020_Configs__mdt where DeveloperName=:(Test.isRunningTest()?'TEST':(isEnvSandbox ? UserInfo.getUserName().substringAfterLast('.').toUpperCase() : 'PROD'))];

    nowtime = system.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    query = 'SELECT Id,RecordType.Name, Status__c,Assessment_to_be_deleted__c,RecordTypeId,bodyshop__r.type,bodyshop__r.recordtype.developername FROM Assessment__c'+ ' where Assessment_to_be_deleted__c=true ';//WCH 01/09/2020 C-003913
            //commented because of change in requirement 14/04/2020 
            /* ' WHERE (RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Crash).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId() + '\')' ;
            //' and id = \'a005800000ODAf1\'';
            if(getProperConfigs!= null && !getProperConfigs.isEmpty()){
                if(getProperConfigs.get(0).UseDateLiteral__c){
                    query+=' and Createddate='+getProperConfigs.get(0).DateLiteral__c;
                }else{
                    String startdatetime = getProperConfigs.get(0).startdate__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    String enddatetime = getProperConfigs.get(0).EndDate__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    query+=' and Createddate>='+startdatetime+' and Createddate<'+enddatetime;
                }
                if(String.isNotBlank(getProperConfigs.get(0).CountryCodeToPurge__c)){
                  countryCodesToPurge.addAll(getProperConfigs.get(0).CountryCodeToPurge__c.split(';'));
                  countryCodesToPurge.remove(null);
                  query+=' and TECH_EntityCountryCode__c in : countryCodesToPurge ';
                }
            }else{
              query+=' and Createddate=null';
            } */
        system.debug('### query' + query);
        system.debug('### nowtime' + nowtime);
    
  }
  global void execute(SchedulableContext sc) {
            Database.executeBatch(new AspisBatchDataPurge2020_Cloned(), 200);
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {

      Map<Id, List<Assessment__c>> mapAssAndChild = new Map<Id, List<Assessment__c>>();
      Map<Id, Assessment__c> mapAssessmentToDel = new Map<Id,Assessment__c> ();
      set<Id> setParentClaim = new set<Id>();
      set<Id> setParentClaimExpert = new set<Id>();
      set<Id> setNoChildClaim = new set<Id>();
      set<Id> setParentClaimFound = new set<Id>();
      Map<Id, Assessment__c> setNewAss =  new Map<Id,Assessment__c> ();
      map<Id, integer> mapAssQtyAllClaimOrders = new map <Id, integer>();
      map<Id, integer> mapAssQtyGoodClaimOrders = new map <Id, integer>();
      List<String> listValidStatus = new List<String>();
      List<String> listValidStatusForClaim = new List<String>();

      List<String> listPOStatusToDelForNewAss = new List<String>();
      List<String> listSOStatusToDelForNewAss = new List<String>();
      List<String> listINVStatusToDelForNewAss = new List<String>();

      listValidStatus = (system.label.Purge2020ValidNewAssessmentStatus).toUpperCase().split(';');      
      listValidStatusForClaim = (system.label.Purge2020ValidClaimOrderStatus).toUpperCase().split(';');      

      listPOStatusToDelForNewAss = (system.label.Purge2020ValidPOStatus).toUpperCase().split(';');      
      listSOStatusToDelForNewAss = (system.label.Purge2020ValidSOStatus).toUpperCase().split(';');      
      listINVStatusToDelForNewAss = (system.label.Purge2020ValidINVStatus).toUpperCase().split(';');      

      system.debug('### scope' + scope);
      system.debug('### listValidStatus' + listValidStatus);

      //mapAssessmentToDel.putAll(scope);
      for (Assessment__c asmnt: scope){

        if (asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId() || asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Crash).getRecordTypeId()){
          mapAssessmentToDel.put(asmnt.Id, asmnt);
        }else if (asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() && asmnt.bodyshop__c!=null && asmnt.bodyshop__r.recordtype.DeveloperName==ASPISConstants.ACCOUNT_RT_DeveloperName_Expert){//WCH 31/08/2020 C-003913
          mapAssessmentToDel.put(asmnt.Id, asmnt);
          setParentClaimExpert.add(asmnt.Id);
        }else if (asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()){
          setParentClaim.add(asmnt.Id);
        }
        else if (/* commented because of change in requirement 14/04/2020 
        listValidStatus.contains(asmnt.Status__c) && */ asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()){
          setNewAss.put(asmnt.Id, asmnt);  
        }
      }      
      system.debug('setParentClaim>>'+setParentClaim);
      //fetch all new assessment SOs
      /* commented because of change in requirement 14/04/2020 
      For (PrerequisiteOrder__c theSO: [SELECT Id, Assessment__c 
                                   FROM   PrerequisiteOrder__c   
                                   where Assessment__c IN: setNewAss.keyset() And Status__c NOT IN:listSOStatusToDelForNewAss]){
          setNewAss.remove(theSO.Assessment__c);
      }
      //fetch all new assessment POs
      For (PurchaseOrder__c thePO: [SELECT Id, Assessment__c 
                                   FROM   PurchaseOrder__c   
                                   where Assessment__c IN: setNewAss.keyset() And Status__c NOT IN:listPOStatusToDelForNewAss]){
          setNewAss.remove(thePO.Assessment__c);
      }
      //fetch all new assessment INVs
      For (Invoice__c theINV: [SELECT Id, Assessment__c
                                   FROM   Invoice__c   
                                   where Assessment__c IN: setNewAss.keyset() And Status__c NOT IN:listINVStatusToDelForNewAss]){
          setNewAss.remove(theINV.Assessment__c);
      } */
      //add all assessment of type new assessment to mapAssessmentToDel
      mapAssessmentToDel.putAll(setNewAss);
      //add claim experts to setParentClaim as some claim experts have CO
      setParentClaim.addAll(setParentClaimExpert);
      //fetch all claim orders
      For (Assessment__c childAss: [SELECT Id, RecordType.Name, RecordTypeId ,ParentAssessment__c,LongTermDeletionDate__c,
                         ParentAssessment__r.ParentAssessment__c,ParentAssessment__r.LongTermDeletionDate__c,Status__c,ParentAssessment__r.bodyshop__r.type 
                                   FROM   Assessment__c   
                                   where ParentAssessment__c IN: setParentClaim And ParentAssessment__c != null
                                   Order By ParentAssessment__c ASC] ){

        system.debug('@@ childAssL'+childAss.Status__c);

        setParentClaimFound.add(childAss.ParentAssessment__c);
         
        if (childAss.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId() || childAss.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId()){  

          if (mapAssAndChild.containsKey(childAss.ParentAssessment__c)){                    
            mapAssAndChild.get(childAss.ParentAssessment__c).add(childAss);  
          }else{                    
            mapAssAndChild.put(childAss.ParentAssessment__c, new list<Assessment__c> {childAss});
          } 

          if (mapAssQtyAllClaimOrders.containsKey(childAss.ParentAssessment__c)){               
            mapAssQtyAllClaimOrders.put(childAss.ParentAssessment__c, mapAssQtyAllClaimOrders.get(childAss.ParentAssessment__c) + 1);
          }else{
            mapAssQtyAllClaimOrders.put(childAss.ParentAssessment__c, 1);
          }

          if (/*commented because of change in requirement 14/04/2020  listValidStatusForClaim.contains((childAss.Status__c).toUpperCase()) */ true){
            system.debug('@@ go tin');
            if (mapAssQtyGoodClaimOrders.containsKey(childAss.ParentAssessment__c)){               
              mapAssQtyGoodClaimOrders.put(childAss.ParentAssessment__c, mapAssQtyGoodClaimOrders.get(childAss.ParentAssessment__c) + 1);
            }
            else{
              mapAssQtyGoodClaimOrders.put(childAss.ParentAssessment__c, 1);
            }
          }
        }
      } 

      system.debug('## setParentClaimFound:'+setParentClaimFound);
      if(setParentClaimFound.size() == 0){
          setNoChildClaim = setParentClaim;
      }
      if(setParentClaimFound.size() != setParentClaim.size()){
        for(Id parentId : setParentClaim){
          if(!setParentClaimFound.contains(parentId)){
              setNoChildClaim.add(parentId);
          }
        }
      }
      
      system.debug('## setNoChildClaim:'+setNoChildClaim);

      For (Id parentId: mapAssAndChild.keyset()){
        //commented because of change in requirement 14/04/2020
        //if (mapAssQtyAllClaimOrders.get(parentId) == mapAssQtyGoodClaimOrders.get(parentId)){
          mapAssessmentToDel.putAll(mapAssAndChild.get(parentId));
          mapAssessmentToDel.put(parentId, new Assessment__c(Id = parentId)); 
        //}
      }

      if(setNoChildClaim.size() > 0){
        for(Id parentId : setNoChildClaim){
          if(!mapAssessmentToDel.containsKey(parentId)){
            mapAssessmentToDel.put(parentId, new Assessment__c(Id = parentId)); 
          }          
        }
      }
        
    system.debug('@@ mapAssQtyGoodClaimOrders:'+mapAssQtyGoodClaimOrders);
    system.debug('@@ mapAssQtyAllClaimOrders:'+mapAssQtyAllClaimOrders);
    system.debug('@@ mapAssAndChild:'+mapAssAndChild);
    system.debug('@@ mapAssessmentToDel:'+mapAssessmentToDel);

    if (mapAssessmentToDel.size() > 0){
      /* retrieveAndDelSoPoInv(mapAssessmentToDel.values());      
      Delete mapAssessmentToDel.values(); */
      for(Id theAssessmentId : mapAssessmentToDel.keyset()){
        mapAssessmentToDel.get(theAssessmentId).Tech_PurgeVerification2020__c=true;
      }
      Database.SaveResult[] srList = Database.update(mapAssessmentToDel.values(), false);
    }
      

    
  }
  global void finish(Database.BatchableContext BC) {
    
  }

  /* private static void retrieveAndDelSoPoInv (List<Assessment__c> lstAssesment){
    List<Invoice__c> lstInvoicesToDel = new List<Invoice__c>();
    List<PrerequisiteOrder__c> lstPrerequisiteOrderToDel = new List<PrerequisiteOrder__c>();
    List<PurchaseOrder__c> lstPurchaseOrderToDel = new List<PurchaseOrder__c>();
    List<Case__c> lstCasesToDel = new List<Case__c>();
    if (lstAssesment.size() > 0){
          lstInvoicesToDel = [Select Id from Invoice__c where Assessment__c  In :lstAssesment];  
          lstPrerequisiteOrderToDel = [Select Id from PrerequisiteOrder__c where Assessment__c  In :lstAssesment];  
          lstPurchaseOrderToDel = [Select Id from PurchaseOrder__c where Assessment__c  In :lstAssesment];  
          lstCasesToDel = [Select Id from Case__c where Assesment__c  In :lstAssesment]; 
        }

         system.debug('### lstInvoicesToDel' + lstInvoicesToDel +lstInvoicesToDel.size()); 
        system.debug('### lstPrerequisiteOrderToDel' + lstPrerequisiteOrderToDel + lstPrerequisiteOrderToDel.size()); 
        system.debug('### lstPurchaseOrderToDel' + lstPurchaseOrderToDel + lstPurchaseOrderToDel.size()); 


        if (lstInvoicesToDel.size() > 0){
          Delete lstInvoicesToDel;
        }
        if (lstPrerequisiteOrderToDel.size() > 0){
          Delete lstPrerequisiteOrderToDel;
        }
        if (lstPurchaseOrderToDel.size() > 0){
          Delete lstPurchaseOrderToDel;
        }     
        if (lstCasesToDel.size() > 0){
          Delete lstCasesToDel;
        } 
       
   } */

  
}