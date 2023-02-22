/**
 * @description       : This is a trigger handler which will call the appropriate class when an action is performed on a plan d'action
 * @author            : JPI
 * @group             : 
 * @last modified on  : 25/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/01/2021   JPI   Initial Version
 * 1.1   17-09-2021   HMO   RSIW - 10478
**/
public with sharing class SVR_PlanActionTriggerHandler {
    
    Map<Id, Audit_Plan_Action__c> mapPAWithNomDuGestionnaire = new Map<Id, Audit_Plan_Action__c>();
    Map<Id, Audit_Plan_Action__c> mapPAWithResponsableSecteur = new Map<Id, Audit_Plan_Action__c>();
    Set<Id> userIdRSNew = new Set<Id>();
    Set<Id> userIdRSOld = new Set<Id>();
    Set<Id> userIdOPNew = new Set<Id>();
    Set<Id> userIdOPOld = new Set<Id>();

    //RLA 10/06/2021 RSIW-9913 [MyPrefitool] Rework des champs
    Map<Id, Audit_Plan_Action__c> mapPACM = new Map<Id, Audit_Plan_Action__c>();

    //HMO -- 20/09/2021 -- RSIW-10743
    List<Audit_Plan_Action__c> lstPlanToUpdate = new List<Audit_Plan_Action__c>();

    


    public void OnAfterInsert(List<Audit_Plan_Action__c> lstNewPlanAction){
        List<Audit_Plan_Action__c> lstPlans = new List<Audit_Plan_Action__c>();
        Map<ID, List<Audit_Plan_Action__c>> mapAuditReseauIdPlanActions = new Map<ID, List<Audit_Plan_Action__c>>();
        for(Audit_Plan_Action__c pa : lstNewPlanAction){
            if(mapAuditReseauIdPlanActions.containsKey(pa.SVR_AuditReseau__c)){
                mapAuditReseauIdPlanActions.get(pa.SVR_AuditReseau__c).add(pa);
            }
            else{
                mapAuditReseauIdPlanActions.put(pa.SVR_AuditReseau__c,new List<Audit_Plan_Action__c>{pa});
            }

            if(pa.SVR_NomGestionnaire__c!=null){
                if(pa.SVR_NomGestionnaire__c !=pa.CreatedById){
                    if(!mapPAWithNomDuGestionnaire.containsKey(pa.id)){
                        mapPAWithNomDuGestionnaire.put(pa.id, pa);
                        userIdOPNew.add(pa.SVR_NomGestionnaire__c);
                    }
                }
            }

            if(pa.SVR_ResponsableSecteur__c!=null){
                if(pa.SVR_ResponsableSecteur__c !=pa.CreatedById){
                    if(!mapPAWithResponsableSecteur.containsKey(pa.id)){
                        mapPAWithResponsableSecteur.put(pa.id, pa);
                        userIdRSNew.add(pa.SVR_ResponsableSecteur__c);
                    }
                }
            }
           
            //RLA 10/06/2021 RSIW-9913 [MyPrefitool] Rework des champs
            if (NOBTools.isPrefikarUser() && pa.recordtypeId == Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauCM).getRecordTypeId()){
                mapPACM.put(pa.Id,pa);

            }

            //HMO -- 20-09-2021 -- RSIW-10743
            lstPlans.add(pa);

        }

        if(mapAuditReseauIdPlanActions.size() > 0){
            SVR_AP101PlanActionLinked.determineIfLinkedActionPlan(mapAuditReseauIdPlanActions);
        }

        if(mapPAWithNomDuGestionnaire.size()!=0){
            SVR_AP104_planActionSharing.planActionSharing(mapPAWithNomDuGestionnaire, userIdOPNew, null);
        }
        if(mapPAWithResponsableSecteur.size()!=0){
            SVR_AP104_planActionSharing.planActionSharing(mapPAWithResponsableSecteur, userIdRSNew, null);
        }
        system.debug('@@@ mapPACM: '+mapPACM);
        //RLA 10/06/2021 RSIW-9913 [MyPrefitool] Rework des champs
        if (mapPACM.size() > 0){
            SVR_AP106PlanActionProcessing.initialiseThePA(mapPACM);
        }

        //HMO -- 17-09-2021 -- RSIW - 10478
        if (lstPlans != null && lstPlans.size() > 0){
           SVR_AP106PlanActionProcessing.sendEmailRepairer(lstPlans);
        }
    }

    public void OnAfterUpdate(Map<Id, Audit_Plan_Action__c> oldMapPA, Map<Id, Audit_Plan_Action__c> newMapPA){

        for(id key : newMapPA.keyset()){

            if(newMapPA.get(key).SVR_NomGestionnaire__c!=null && newMapPA.get(key).SVR_NomGestionnaire__c!=oldMapPA.get(key).SVR_NomGestionnaire__c){
                mapPAWithNomDuGestionnaire.put(newMapPA.get(key).id, newMapPA.get(key));
                if(newMapPA.get(key).SVR_NomGestionnaire__c != newMapPA.get(key).CreatedById)
                    userIdOPNew.add(newMapPA.get(key).SVR_NomGestionnaire__c);
                if(oldMapPA.get(key).SVR_NomGestionnaire__c != newMapPA.get(key).CreatedById)
                    userIdOPOld.add(oldMapPA.get(key).SVR_NomGestionnaire__c);
            }

            if(newMapPA.get(key).SVR_ResponsableSecteur__c!=null && newMapPA.get(key).SVR_ResponsableSecteur__c!=oldMapPA.get(key).SVR_ResponsableSecteur__c){
                mapPAWithResponsableSecteur.put(newMapPA.get(key).id, newMapPA.get(key));
                if(newMapPA.get(key).SVR_ResponsableSecteur__c != newMapPA.get(key).CreatedById)
                    userIdRSNew.add(newMapPA.get(key).SVR_ResponsableSecteur__c);
                if(oldMapPA.get(key).SVR_ResponsableSecteur__c != newMapPA.get(key).CreatedById)
                    userIdRSOld.add(oldMapPA.get(key).SVR_ResponsableSecteur__c);
            }

            //HMO -- 20-09-2021 -- RSIW-10743
            if (newMapPA.get(key).SVR_DateDuProchainPoint__c !=null && newMapPA.get(key).SVR_DateDuProchainPoint__c !=oldMapPA.get(key).SVR_DateDuProchainPoint__c){
                lstPlanToUpdate.add(newMapPA.get(key));
            }
        }
        
        if(mapPAWithNomDuGestionnaire.size()!=0)
            SVR_AP104_planActionSharing.planActionSharing(mapPAWithNomDuGestionnaire, userIdOPNew, userIdOPOld);
        if(mapPAWithResponsableSecteur.size()!=0)
            SVR_AP104_planActionSharing.planActionSharing(mapPAWithResponsableSecteur, userIdRSNew, userIdRSOld);

        //HMO -- 20-09-2021 -- RSIW-10743
        if (lstPlanToUpdate.size() > 0){
            SVR_AP106PlanActionProcessing.sendEmailRepairer(lstPlanToUpdate);
        }
    }

    public void onAfterDelete(List<Audit_Plan_Action__c> lstOldPlanAction){
        Map<ID, List<Audit_Plan_Action__c>> mapAuditReseauIdPlanActions = new Map<ID, List<Audit_Plan_Action__c>>();
        for(Audit_Plan_Action__c planAction : lstOldPlanAction){
            if(mapAuditReseauIdPlanActions.containsKey(planAction.SVR_AuditReseau__c)){
                mapAuditReseauIdPlanActions.get(planAction.SVR_AuditReseau__c).add(planAction);
            }
            else{
                mapAuditReseauIdPlanActions.put(planAction.SVR_AuditReseau__c,new List<Audit_Plan_Action__c>{planAction});
            }
        }

        if(mapAuditReseauIdPlanActions.size() > 0){
            SVR_AP101PlanActionLinked.determineIfLinkedActionPlan(mapAuditReseauIdPlanActions);
        }
    }
}