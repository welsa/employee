/**
 * @description       : When a user creates a new plan d'action record with the field 'Nom de gestionnaire' and 'Responsable de secteur' specified. The user specified in the field 'Nom de Gestionnaire' will be able to view the record as read only. The user specified in the field 'Responsable de secteur' will be able to view the record as read/write
 * @author            : JPI
 * @group             : 
 * @last modified on  : 03-30-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP104_PlanActionSharing {

    public static void planActionSharing(Map<Id, Audit_Plan_Action__c> mapPANew, Set<Id> userId, Set<Id> userIdOld){

        List<Audit_Plan_Action__Share> lstPlanActionShare = new List<Audit_Plan_Action__Share> ();
        
        // Get the user (Nom du Gestionnaire)
        Map <Id, User> mapUsers = new Map <Id, User> ([SELECT id, accountid 
                                                        FROM User 
                                                        WHERE id IN :userId]);
       
        // Create share instance with current plan d'action id as parent id ==> #                                               
        for (Audit_Plan_Action__c pa : mapPANew.values()) {
            if (mapUsers.containsKey(pa.SVR_NomGestionnaire__c)) {
                System.debug('#####JPI Nom du Gestionaire: ' + pa.SVR_NomGestionnaire__c);
                User currentUsers = mapUsers.get(pa.SVR_NomGestionnaire__c);

                Audit_Plan_Action__Share planActionShare = new Audit_Plan_Action__Share();
                planActionShare.ParentId = pa.id;
                planActionShare.UserOrGroupId = currentUsers.Id;
                planActionShare.AccessLevel = 'Edit';
                lstPlanActionShare.add(planActionShare);
            }

            if (mapUsers.containsKey(pa.SVR_ResponsableSecteur__c)) {
                System.debug('#####JPI Responsable du secteur: ' + pa.SVR_ResponsableSecteur__c);
                User currentUsers = mapUsers.get(pa.SVR_ResponsableSecteur__c);

                Audit_Plan_Action__Share planActionShare = new Audit_Plan_Action__Share();
                planActionShare.ParentId = pa.id;
                planActionShare.UserOrGroupId = currentUsers.Id;
                planActionShare.AccessLevel = 'Edit';
                lstPlanActionShare.add(planActionShare);
            }
        }

        if (lstPlanActionShare.size()>0) {
            insert lstPlanActionShare;
        }

        // Will delete the old sharing when field 'Nom du gestionnaire' is update and create new as shown above at #
        if(userIdOld!=null && userIdOld.size()!=0){
            List<Audit_Plan_Action__Share> listPAToDelete = [SELECT id
                                                                FROM Audit_Plan_Action__Share
                                                                WHERE UserOrGroupId IN :userIdOld AND ParentId IN :mapPANew.keySet()];

            System.debug('#####JPI listPlan d\'action ToDelete: ' + listPAToDelete);
            if(listPAToDelete.size()!=0){
                delete listPAToDelete;
            }   
        }
    }
}