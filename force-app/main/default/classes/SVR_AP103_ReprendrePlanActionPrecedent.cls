/**
 * @description       : This class will look for recent audit before the most recent audit of the current audit where the button is click and use the recent plan d'action of the recent audit to create a new 'Plan 'daction' for the most recent audit
 * @author            : JPI
 * @group             : 
 * @last modified on  : 08/02/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   05/01/2021   JPI   Initial Version
**/public with sharing class SVR_AP103_ReprendrePlanActionPrecedent {
    public static List<SVR_AuditReseau__c> listAuditReseau = new List<SVR_AuditReseau__c>();
    public static List<Audit_Plan_Action__c> listPlanAction = new List<Audit_Plan_Action__c>();
    public static Map<Id, SVR_AuditReseau__c> mapRecentAudit = new Map<Id, SVR_AuditReseau__c>();
    public static List<SVR_AuditReseau__c> listRecentAudit = new List<SVR_AuditReseau__c>();

    @AuraEnabled
    public static PlanActionListWrapper reprendrePlanAction(String Id) {

        System.debug('############# start SVR_AuditReseauTrigger.createPlanAction ##########');
        
        // Get Audit created
        listAuditReseau = [SELECT id, SVR_AuditReseauParent__c, SVR_AuditReseauUltimate__c 
                            FROM SVR_AuditReseau__c 
                            WHERE id =: Id
                            ORDER BY CreatedDate DESC LIMIT 1];

        if(listAuditReseau[0].SVR_AuditReseauParent__c!=null && listAuditReseau[0].SVR_AuditReseauUltimate__c!=null){          
            
            //Store all Ultimate Audit Id
            Id ultimateId = listAuditReseau[0].SVR_AuditReseauUltimate__c;
            Id parentId = listAuditReseau[0].SVR_AuditReseauParent__c;

            // Use the ultimate Ids to get the most recent most recent AUDIT
            List<SVR_AuditReseau__c> listRecentAudit = [SELECT id, SVR_AuditReseauParent__c, SVR_AuditReseauUltimate__c 
                                                            FROM SVR_AuditReseau__c 
                                                            WHERE SVR_AuditReseauUltimate__c =: ultimateId
                                                            ORDER BY CreatedDate DESC];
            
            // Store the Ultimate audit Id in a map as key with their child audit as values in DESC Order
            // Where most recent audit is first
            Id recentAuditId = null;
            SVR_AuditReseau__c recentAuditRS = new SVR_AuditReseau__c();
            if(listRecentAudit.size()==1){
                recentAuditId = parentId;
            }else{
                recentAuditRS = mapRecentAudit.get(listRecentAudit[1].id);
                recentAuditId = listRecentAudit[1].id;
            }
            
            System.debug('############# listRecentAudit: ' + listRecentAudit + ' : Size ' + listRecentAudit.size());         
                
            listPlanAction = [SELECT id, recordTypeId, Name, 
                            SVR_CMStatut1__c, SVR_CMStatut2__c, SVR_CMStatut3__c, SVR_CMStatut4__c, SVR_CMStatut5__c, SVR_CMStatut6__c, SVR_CMStatut7__c,
                            SVR_QUAStatut1__c, SVR_QUAStatut2__c, SVR_QUAStatut3__c, SVR_QUAStatut4__c, SVR_QUAStatut5__c, SVR_QUAStatut6__c, SVR_QUAStatut7__c,
                            SVR_ActionIdentifie1__c, SVR_ActionIdentifie2__c, SVR_ActionIdentifie3__c, SVR_ActionIdentifie4__c, SVR_ActionIdentifie5__c, SVR_ActionIdentifie6__c, SVR_ActionIdentifie7__c, 
                            SVR_AICommentaire1__c, SVR_AICommentaire2__c, SVR_AICommentaire3__c, SVR_AICommentaire4__c, SVR_AICommentaire5__c, SVR_AICommentaire6__c, SVR_AICommentaire7__c, 
                            SVR_AuditReseau__r.SVR_AuditReseauUltimate__c, SVR_AuditReseau__r.SVR_AuditReseauParent__c
                            FROM Audit_Plan_Action__c 
                            WHERE SVR_AuditReseau__c =: recentAuditId 
                            ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('############# listPlanAction: ' + listPlanAction); 
            if(listPlanAction.size() > 0){
                Audit_Plan_Action__c clone = new  Audit_Plan_Action__c();
                clone.SVR_AuditReseau__c = listRecentAudit[0].Id;
                clone.recordTypeId = listPlanAction[0].recordTypeId;
                assignStatus(clone, listPlanAction[0]);
                insert clone;
                System.debug('############# listPlanAction ==> IN. '); 
                return new PlanActionListWrapper(clone.Id, clone.Name,'NONE');
            }else{
                return new PlanActionListWrapper(null, null, 'NoPA');
            }

            
        }
        System.debug('############# end SVR_AuditReseauTrigger.createPlanAction ##########');

        return new PlanActionListWrapper(null, null, 'NONE');
    }

    public static void assignStatus(Audit_Plan_Action__c planActionClone, Audit_Plan_Action__c planAction){
        
        List<String> planActionActionIdentife = new List<String>();
        List<String> planActionStatut = new List<String>();
        List<String> planActionCommentaire = new List<String>();
        
        if(planAction.recordTypeId == Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get('SVR_PACM').getRecordTypeId()){
            if((planAction.SVR_ActionIdentifie1__c!=null || planAction.SVR_CMStatut1__c!=null || planAction.SVR_AICommentaire1__c!=null) && (planAction.SVR_CMStatut1__c=='Non-réalisé' || planAction.SVR_CMStatut1__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie1__c);
                planActionStatut.add(planAction.SVR_CMStatut1__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire1__c);
            }
            
            if((planAction.SVR_ActionIdentifie2__c!=null || planAction.SVR_CMStatut2__c!=null || planAction.SVR_AICommentaire2__c!=null) && (planAction.SVR_CMStatut2__c=='Non-réalisé' || planAction.SVR_CMStatut2__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie2__c);
                planActionStatut.add(planAction.SVR_CMStatut2__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire2__c);
            }

            if((planAction.SVR_ActionIdentifie3__c!=null || planAction.SVR_CMStatut3__c!=null || planAction.SVR_AICommentaire3__c!=null)  && (planAction.SVR_CMStatut3__c=='Non-réalisé' || planAction.SVR_CMStatut3__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie3__c);
                planActionStatut.add(planAction.SVR_CMStatut3__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire3__c);
            }

            if((planAction.SVR_ActionIdentifie4__c!=null || planAction.SVR_CMStatut4__c!=null || planAction.SVR_AICommentaire4__c!=null) && (planAction.SVR_CMStatut4__c=='Non-réalisé' || planAction.SVR_CMStatut4__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie4__c);
                planActionStatut.add(planAction.SVR_CMStatut4__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire4__c);
            }

            if((planAction.SVR_ActionIdentifie5__c!=null || planAction.SVR_CMStatut5__c!=null || planAction.SVR_AICommentaire5__c!=null) && (planAction.SVR_CMStatut5__c=='Non-réalisé' || planAction.SVR_CMStatut5__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie5__c);
                planActionStatut.add(planAction.SVR_CMStatut5__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire5__c);
            }

            if((planAction.SVR_ActionIdentifie6__c!=null || planAction.SVR_CMStatut6__c!=null || planAction.SVR_AICommentaire6__c!=null) && (planAction.SVR_CMStatut6__c=='Non-réalisé' || planAction.SVR_CMStatut6__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie6__c);
                planActionStatut.add(planAction.SVR_CMStatut6__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire6__c);
            }

            if((planAction.SVR_ActionIdentifie7__c!=null || planAction.SVR_CMStatut7__c!=null || planAction.SVR_AICommentaire7__c!=null)  && (planAction.SVR_CMStatut7__c=='Non-réalisé' || planAction.SVR_CMStatut7__c=='A faire')){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie7__c);
                planActionStatut.add(planAction.SVR_CMStatut7__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire7__c);
            }

            //Assign to clone
            if(planActionActionIdentife.size()>0){
                planActionClone.SVR_ActionIdentifie1__c = planActionActionIdentife[0];
                planActionClone.SVR_CMStatut1__c = planActionStatut[0];
                planActionClone.SVR_AICommentaire1__c = planActionCommentaire[0];
            }
            if(planActionActionIdentife.size()>=2){
                planActionClone.SVR_ActionIdentifie2__c = planActionActionIdentife[1];
                planActionClone.SVR_CMStatut2__c = planActionStatut[1];
                planActionClone.SVR_AICommentaire2__c = planActionCommentaire[1];
            }
            if(planActionActionIdentife.size()>=3){
                planActionClone.SVR_ActionIdentifie3__c = planActionActionIdentife[2];
                planActionClone.SVR_CMStatut3__c = planActionStatut[2];
                planActionClone.SVR_AICommentaire3__c = planActionCommentaire[2];
            }
            if(planActionActionIdentife.size()>=4){
                planActionClone.SVR_ActionIdentifie4__c = planActionActionIdentife[3];
                planActionClone.SVR_CMStatut4__c = planActionStatut[3];
                planActionClone.SVR_AICommentaire4__c = planActionCommentaire[3];
            }
            if(planActionActionIdentife.size()>=5){
                planActionClone.SVR_ActionIdentifie5__c = planActionActionIdentife[4];
                planActionClone.SVR_CMStatut5__c = planActionStatut[4];
                planActionClone.SVR_AICommentaire5__c = planActionCommentaire[4];
            }
            if(planActionActionIdentife.size()>=6){
                planActionClone.SVR_ActionIdentifie6__c = planActionActionIdentife[5];
                planActionClone.SVR_CMStatut6__c = planActionStatut[5];
                planActionClone.SVR_AICommentaire6__c = planActionCommentaire[5];
            }
            if(planActionActionIdentife.size()>=7){
                planActionClone.SVR_ActionIdentifie7__c = planActionActionIdentife[6];
                planActionClone.SVR_CMStatut7__c = planActionStatut[6];
                planActionClone.SVR_AICommentaire7__c = planActionCommentaire[6];
            }


        }else if(planAction.recordTypeId == Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get('SVR_PAQualite').getRecordTypeId()){

            if((planAction.SVR_ActionIdentifie1__c!=null || planAction.SVR_QUAStatut1__c!=null || planAction.SVR_AICommentaire1__c!=null) && planAction.SVR_QUAStatut1__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie1__c);
                planActionStatut.add(planAction.SVR_QUAStatut1__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire1__c);
            }
            
            if((planAction.SVR_ActionIdentifie2__c!=null || planAction.SVR_QUAStatut2__c!=null || planAction.SVR_AICommentaire2__c!=null) && planAction.SVR_QUAStatut2__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie2__c);
                planActionStatut.add(planAction.SVR_QUAStatut2__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire2__c);
            }

            if((planAction.SVR_ActionIdentifie3__c!=null || planAction.SVR_QUAStatut3__c!=null || planAction.SVR_AICommentaire3__c!=null) && planAction.SVR_QUAStatut3__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie3__c);
                planActionStatut.add(planAction.SVR_QUAStatut3__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire3__c);
            }

            if((planAction.SVR_ActionIdentifie4__c!=null || planAction.SVR_QUAStatut4__c!=null || planAction.SVR_AICommentaire4__c!=null) && planAction.SVR_QUAStatut4__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie4__c);
                planActionStatut.add(planAction.SVR_QUAStatut4__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire4__c);
            }

            if((planAction.SVR_ActionIdentifie5__c!=null || planAction.SVR_QUAStatut5__c!=null || planAction.SVR_AICommentaire5__c!=null) && planAction.SVR_QUAStatut5__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie5__c);
                planActionStatut.add(planAction.SVR_QUAStatut5__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire5__c);
            }

            if((planAction.SVR_ActionIdentifie6__c!=null || planAction.SVR_QUAStatut6__c!=null || planAction.SVR_AICommentaire6__c!=null) && planAction.SVR_QUAStatut6__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie6__c);
                planActionStatut.add(planAction.SVR_QUAStatut6__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire6__c);
            }

            if((planAction.SVR_ActionIdentifie7__c!=null || planAction.SVR_QUAStatut7__c!=null || planAction.SVR_AICommentaire7__c!=null) && planAction.SVR_QUAStatut7__c=='Non acquis'){
                planActionActionIdentife.add(planAction.SVR_ActionIdentifie7__c);
                planActionStatut.add(planAction.SVR_QUAStatut7__c);
                planActionCommentaire.add(planAction.SVR_AICommentaire7__c);
            }

            //Assign to clone
            if(planActionActionIdentife.size()>0){
                planActionClone.SVR_ActionIdentifie1__c = planActionActionIdentife[0];
                planActionClone.SVR_QUAStatut1__c = planActionStatut[0];
                planActionClone.SVR_AICommentaire1__c = planActionCommentaire[0];
            }
            if(planActionActionIdentife.size()>=2){
                planActionClone.SVR_ActionIdentifie2__c = planActionActionIdentife[1];
                planActionClone.SVR_QUAStatut2__c = planActionStatut[1];
                planActionClone.SVR_AICommentaire2__c = planActionCommentaire[1];
            }
            if(planActionActionIdentife.size()>=3){
                planActionClone.SVR_ActionIdentifie3__c = planActionActionIdentife[2];
                planActionClone.SVR_QUAStatut3__c = planActionStatut[2];
                planActionClone.SVR_AICommentaire3__c = planActionCommentaire[2];
            }
            if(planActionActionIdentife.size()>=4){
                planActionClone.SVR_ActionIdentifie4__c = planActionActionIdentife[3];
                planActionClone.SVR_QUAStatut4__c = planActionStatut[3];
                planActionClone.SVR_AICommentaire4__c = planActionCommentaire[3];
            }
            if(planActionActionIdentife.size()>=5){
                planActionClone.SVR_ActionIdentifie5__c = planActionActionIdentife[4];
                planActionClone.SVR_QUAStatut5__c = planActionStatut[4];
                planActionClone.SVR_AICommentaire5__c = planActionCommentaire[4];
            }
            if(planActionActionIdentife.size()>=6){
                planActionClone.SVR_ActionIdentifie6__c = planActionActionIdentife[5];
                planActionClone.SVR_QUAStatut6__c = planActionStatut[5];
                planActionClone.SVR_AICommentaire6__c = planActionCommentaire[5];
            }
            if(planActionActionIdentife.size()>=7){
                planActionClone.SVR_ActionIdentifie7__c = planActionActionIdentife[6];
                planActionClone.SVR_QUAStatut7__c = planActionStatut[6];
                planActionClone.SVR_AICommentaire7__c = planActionCommentaire[6];
            }
        }
    }

    public class PlanActionListWrapper{
        
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String errorType;

        public PlanActionListWrapper(Id idV, String nameV, String errorTypeV){
            
            id = idV;
            name = nameV;
            errorType = errorTypeV;
        }
    }
}