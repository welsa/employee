global class AspisBatchDataPurgeLong implements Database.Batchable<sObject>, Database.Stateful{
/*
----------------------------------------------------------------------
-- - Name          : AspisBatchDataPurgeLong
-- - Author        : RLA
-- - Description   : Class to delete data after interval
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-MAY-2017  RLA   1.0      Initial version
  Database.executeBatch(new AspisBatchDataPurgeLong(), 200);
----------------------------------------------------------------------*/  
  String query;
  private static String nowtime;
  global AspisBatchDataPurgeLong() {

    

    nowtime = system.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        query = 'SELECT Id,RecordType.Name,LongTermDeletionDate__c, Status__c FROM Assessment__c'+ 
            ' WHERE LongTermDeletionDate__c != null AND LongTermDeletionDate__c <= ' + nowtime +
            ' And (RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() + '\'' +
            ' Or RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId() + '\')' ;
            //' and id = \'a005800000ODAf1\'';
        system.debug('### query' + query);
        system.debug('### nowtime' + nowtime);
    
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {

      Map<Id, List<Assessment__c>> mapAssAndChild = new Map<Id, List<Assessment__c>>();
      Map<Id, Assessment__c> mapAssessmentToDel = new Map<Id,Assessment__c> ();
      set<Id> setParentClaim = new set<Id>();
      set<Id> setNoChildClaim = new set<Id>();
      set<Id> setParentClaimFound = new set<Id>();
      map<Id, integer> mapAssQtyAllClaimOrders = new map <Id, integer>();
      map<Id, integer> mapAssQtyGoodClaimOrders = new map <Id, integer>();
      List<String> listValidStatus = new List<String>();

      listValidStatus = (system.label.PurgeLongValidStatus).split(';');      

      system.debug('### scope' + scope);
      
      For (String status: listValidStatus){
        status = status.toUpperCase();
      }
      system.debug('### listValidStatus' + listValidStatus);

      //mapAssessmentToDel.putAll(scope);
      for (Assessment__c asmnt: scope){

        if (asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
          mapAssessmentToDel.put(asmnt.Id, asmnt);
        }
        else if (asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()){
          setParentClaim.add(asmnt.Id);
        }
        else if (listValidStatus.contains(asmnt.Status__c) && asmnt.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()){
          mapAssessmentToDel.put(asmnt.Id, asmnt);  
            
        }
        
      }      
      

      //fetch all claim orders
      For (Assessment__c childAss: [SELECT Id, RecordType.Name, RecordTypeId ,ParentAssessment__c,LongTermDeletionDate__c,
                         ParentAssessment__r.ParentAssessment__c,ParentAssessment__r.LongTermDeletionDate__c,Status__c 
                                   FROM   Assessment__c   
                                   where ParentAssessment__c IN: setParentClaim And ParentAssessment__c != null
                                   Order By ParentAssessment__c ASC] ){

        system.debug('@@ childAssL'+childAss.Status__c);

        setParentClaimFound.add(childAss.ParentAssessment__c);
         
        if (childAss.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()  
          || childAss.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId()              
            ){  

          if (mapAssAndChild.containsKey(childAss.ParentAssessment__c)){                    
            mapAssAndChild.get(childAss.ParentAssessment__c).add(childAss);  
          }
          else{                    
            mapAssAndChild.put(childAss.ParentAssessment__c, new list<Assessment__c> {childAss});
          } 

          if (mapAssQtyAllClaimOrders.containsKey(childAss.ParentAssessment__c)){               
            mapAssQtyAllClaimOrders.put(childAss.ParentAssessment__c, mapAssQtyAllClaimOrders.get(childAss.ParentAssessment__c) + 1);
          }
          else{
            mapAssQtyAllClaimOrders.put(childAss.ParentAssessment__c, 1);
          }

          if (listValidStatus.contains((childAss.Status__c).toUpperCase())){
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
        if (mapAssQtyAllClaimOrders.get(parentId) == mapAssQtyGoodClaimOrders.get(parentId)){
          mapAssessmentToDel.putAll(mapAssAndChild.get(parentId));
          mapAssessmentToDel.put(parentId, new Assessment__c(Id = parentId)); 
        }
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
      retrieveAndDelSoPoInv(mapAssessmentToDel.values());      
      Delete mapAssessmentToDel.values();
    }
      

    
  }
  global void finish(Database.BatchableContext BC) {
    
  }

  private static void retrieveAndDelSoPoInv (List<Assessment__c> lstAssesment){
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
       
   }

  
}