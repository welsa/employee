/**
 * @description       : When a user creates a new audit operationnel record with the field 'Nom de gestionnaire' specified. The user specified in the field 'Nom de Gestionnaire' will be able to view the record as read only
 * @author            : JPI
 * @group             : 
 * @last modified on  : 22/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP104_AuditOperationnelSharing {
    
    public static void auditOperationnelSharing(Map<Id, SVR_AuditOperationnel__c> mapAuditOP, Set<Id> userId, Set<Id> userIdOld){

        List<SVR_AuditOperationnel__Share> lstAuditOperationnelShare = new List<SVR_AuditOperationnel__Share> ();
        
        // Get the user (Nom du Gestionnaire)
        Map <Id, User> mapUsers = new Map <Id, User> ([SELECT id, accountid 
                                                        FROM User 
                                                        WHERE id IN :userId]);
       
        // Create share instance with current audit operationnel id as parent id ==> #
        for (SVR_AuditOperationnel__c auditOp : mapAuditOP.values()) {
            
            if (mapUsers.containsKey(auditOp.Nom_du_gestionnaire__c)) {
                System.debug('#####JPI Nom du Gestionaire: ' + auditOp.Nom_du_gestionnaire__c);
                User currentUsers = mapUsers.get(auditOp.Nom_du_gestionnaire__c);

                SVR_AuditOperationnel__Share auditOperationnelShare = new SVR_AuditOperationnel__Share();
                auditOperationnelShare.ParentId = auditOp.id;
                auditOperationnelShare.UserOrGroupId = currentUsers.Id;
                auditOperationnelShare.AccessLevel = 'Read';
                lstAuditOperationnelShare.add(auditOperationnelShare);
            }
        }

        if (lstAuditOperationnelShare.size()>0) {
            insert lstAuditOperationnelShare;
        }

        // Will delete the old sharing when field 'Nom du gestionnaire' is update and create new as shown above at #
        if(userIdOld!=null && userIdOld.size()!=0){
            List<SVR_AuditOperationnel__Share> listAuditToDelete = [SELECT id
                                                                FROM SVR_AuditOperationnel__Share
                                                                WHERE UserOrGroupId IN :userIdOld AND ParentId IN :mapAuditOP.keySet()];

            System.debug('#####JPI listAuditToDelete: ' + listAuditToDelete);
            if(listAuditToDelete.size()!=0){
                delete listAuditToDelete;
            }   
        }

    }
}