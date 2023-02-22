/*************************************************************************************
Trigger Name - SVR_AP101PlanActionLinked
Version - 1.0
Created Date - 21 DEC 2020
Function - Trigger to determine whether or not an action plan is linked to an audit reseau

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Shagoofah G	21/12/2020 	Initial Version
*************************************************************************************/

public with sharing class SVR_AP101PlanActionLinked{

    public static void determineIfLinkedActionPlan(Map<ID, List<Audit_Plan_Action__c>> mapAuditReseauIdPlanActions){
        System.debug('>> SVR_AP101PlanActionLinked starts');
        List<SVR_AuditReseau__c> lstAuditReseauToUpd = new List<SVR_AuditReseau__c>();
        // Get all plan d'action lié à un audit reseau
        for (SVR_AuditReseau__c auditReseau : [SELECT Id, Nb_de_plan_d_action__c, (SELECT Id FROM Plans_action_reseau__r ) FROM SVR_AuditReseau__c WHERE Id IN :mapAuditReseauIdPlanActions.keySet()]){
            if (mapAuditReseauIdPlanActions.get(auditReseau.Id) != null){
                
                System.debug('>> SVR_AP101PlanActionLinked, setting to '+auditReseau.Plans_action_reseau__r.size());
                auditReseau.Nb_de_plan_d_action__c = auditReseau.Plans_action_reseau__r.size();
            }
            else{
                System.debug('>> SVR_AP101PlanActionLinked, setting to zero');
                auditReseau.Nb_de_plan_d_action__c = 0;
            }

            lstAuditReseauToUpd.add(auditReseau);
        }

        if(lstAuditReseauToUpd.size() > 0){
            try{
                update lstAuditReseauToUpd;
                System.debug('>> SVR_AP101PlanActionLinked ends');
            }
            catch(Exception ex){
                System.debug('>> SVR_AP101PlanActionLinked, the following exception occurred: '+ ex.getMessage());
            }
        }
    }
}