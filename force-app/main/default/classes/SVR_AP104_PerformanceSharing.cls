/**
 * @description       : When a user creates a new performance record with the field 'Nom de gestionnaire' and 'Responsable de secteur' specified. The user specified in the field 'Nom de Gestionnaire' will be able to view the record as read only
 * @author            : JPI
 * @group             : 
 * @last modified on  : 25/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP104_PerformanceSharing {

    public static void performanceSharing(Map<Id, SVR_Performance__c> mapPerfNew, Set<Id> userId, Set<Id> userIdOld){
        
        List<SVR_Performance__Share> lstPerformanceShare = new List<SVR_Performance__Share> ();
    
        // Get the user (Nom du Gestionnaire et Responsable du secteur)
        Map <Id, User> mapUsers = new Map <Id, User> ([SELECT id, accountid 
                                                        FROM User 
                                                        WHERE id IN :userId]);

        // Create share instance with current plan d'action id as parent id ==> #                                               
        for (SVR_Performance__c pa : mapPerfNew.values()) {
            if (mapUsers.containsKey(pa.SVR_NomGestionnaire__c)) {
                System.debug('#####JPI Nom du Gestionaire: ' + pa.SVR_NomGestionnaire__c);
                User currentUsers = mapUsers.get(pa.SVR_NomGestionnaire__c);

                SVR_Performance__Share performanceShare = new SVR_Performance__Share();
                performanceShare.ParentId = pa.id;
                performanceShare.UserOrGroupId = currentUsers.Id;
                performanceShare.AccessLevel = 'Edit';
                lstPerformanceShare.add(performanceShare);
            }

            /*if (mapUsers.containsKey(pa.SVR_ResponsableSecteur__c)) {
                System.debug('#####JPI Responsable du secteur: ' + pa.SVR_ResponsableSecteur__c);
                User currentUsers = mapUsers.get(pa.SVR_ResponsableSecteur__c);

                SVR_Performance__Share performanceShare = new SVR_Performance__Share();
                performanceShare.ParentId = pa.id;
                performanceShare.UserOrGroupId = currentUsers.Id;
                performanceShare.AccessLevel = 'Read';
                lstPerformanceShare.add(performanceShare);
            }*/
        }

        if (lstPerformanceShare.size()>0) {
            insert lstPerformanceShare;
        }

        // Will delete the old sharing when field 'Nom du gestionnaire' is update and create new as shown above at #
        if(userIdOld!=null && userIdOld.size()!=0){
            List<SVR_Performance__Share> listPerfToDelete = [SELECT id
                                                                FROM SVR_Performance__Share
                                                                WHERE UserOrGroupId IN :userIdOld AND ParentId IN :mapPerfNew.keySet()];

            System.debug('#####JPI listPerformanceToDelete: ' + listPerfToDelete);
            if(listPerfToDelete.size()!=0){
                delete listPerfToDelete;
            }   
        }
    }
}