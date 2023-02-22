/**
 * @description       : When a user creates a new audit reseau record with the field 'Responsable de Secteur' specified. The user specified in the field 'Responsable de Secteur' should be able to view and edit the record
 * @author            : JPI
 * @group             : 
 * @last modified on  : 22/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP104_AuditReseauSharing {
    public static void auditReseauSharing(Map<Id, SVR_AuditReseau__c> mapAuditRSNew, Set<Id> userId, Set<Id> userIdOld){

        List<SVR_AuditReseau__Share> lstAuditReseauShare = new List<SVR_AuditReseau__Share> ();
        
        // Get the user (Nom du Gestionnaire)
        Map <Id, User> mapUsers = new Map <Id, User> ([SELECT id, accountid 
                                                        FROM User 
                                                        WHERE id IN :userId]);
       
        // Create share instance with current plan d'action id as parent id ==> #                                               
        for (SVR_AuditReseau__c audit : mapAuditRSNew.values()) {

            if( audit.SVR_ResponsableSecteur__c != audit.SVR_NomAuditeur__c && audit.SVR_ResponsableSecteur__c != audit.CreatedById ){
                if (mapUsers.containsKey(audit.SVR_ResponsableSecteur__c)) {
                    System.debug('#####JPI Nom du Gestionaire: ' + audit.SVR_ResponsableSecteur__c);
                    User currentUsers = mapUsers.get(audit.SVR_ResponsableSecteur__c);

                    SVR_AuditReseau__Share auditRSShare = new SVR_AuditReseau__Share();
                    auditRSShare.ParentId = audit.id;
                    auditRSShare.UserOrGroupId = currentUsers.Id;
                    auditRSShare.AccessLevel = 'Edit';
                    lstAuditReseauShare.add(auditRSShare);
                }

                if (mapUsers.containsKey(audit.SVR_NomAuditeur__c)) {
                    System.debug('#####JPI Nom du Gestionaire: ' + audit.SVR_NomAuditeur__c);
                    User currentUsers = mapUsers.get(audit.SVR_NomAuditeur__c);

                    SVR_AuditReseau__Share auditRSShare = new SVR_AuditReseau__Share();
                    auditRSShare.ParentId = audit.id;
                    auditRSShare.UserOrGroupId = currentUsers.Id;
                    auditRSShare.AccessLevel = 'Edit';
                    lstAuditReseauShare.add(auditRSShare);
                }
            }
            
        }

        if (lstAuditReseauShare.size()>0) {
            insert lstAuditReseauShare;
        }

        // Will delete the old sharing when field 'Nom du gestionnaire' is update and create new as shown above at #
        if(userIdOld!=null && userIdOld.size()!=0){
            List<SVR_AuditReseau__Share> listAuditRSToDelete = [SELECT id
                                                            FROM SVR_AuditReseau__Share
                                                            WHERE UserOrGroupId IN :userIdOld AND ParentId IN :mapAuditRSNew.keySet()];

            System.debug('#####JPI listAuditToDelete: ' + listAuditRSToDelete);
            if(listAuditRSToDelete.size()!=0){
                delete listAuditRSToDelete;
            }   
        }
    }
}