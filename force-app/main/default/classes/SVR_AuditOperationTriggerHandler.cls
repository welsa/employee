/**
 * @description       : Il s'agit d'un Trigger Handler qui appellera les méthodes appropriées à partir des classes pour l'objet d'audit operationnel lors des insert, update et delete.
 * @author            : JPI
 * @group             : AP01
 * @last modified on  : 22/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   27/11/2020   JPI      Initial Version
**/
public with sharing class SVR_AuditOperationTriggerHandler {

    Map<Id, SVR_AuditOperationnel__c> mapAuditOPWithNomDuGestionnaireNew = new Map<Id, SVR_AuditOperationnel__c>();
    Set<Id> userIdNew = new Set<Id>();
    Set<Id> userIdOld = new Set<Id>();

    public void OnAfterInsert(List<SVR_AuditOperationnel__c> newListAudit){

        for(SVR_AuditOperationnel__c op : [SELECT id, Nom_du_gestionnaire__c,CreatedById FROM SVR_AuditOperationnel__c WHERE id IN: newListAudit]){
            if(op.Nom_du_gestionnaire__c!=null){
                if(op.Nom_du_gestionnaire__c !=op.CreatedById){
                    if(!mapAuditOPWithNomDuGestionnaireNew.containsKey(op.id)){
                        mapAuditOPWithNomDuGestionnaireNew.put(op.id, op);
                        userIdNew.add(op.Nom_du_gestionnaire__c);
                    }
                }
            }
        }

        if(newListAudit.size()!=0)
            SVR_AP100_AuditAvoirPlanDactionNonAcquis.asigneRichTextToNonAcquisPlanActionOP(newListAudit);
        if(mapAuditOPWithNomDuGestionnaireNew.size()!=0)
            SVR_AP104_AuditOperationnelSharing.auditOperationnelSharing(mapAuditOPWithNomDuGestionnaireNew, userIdNew, null);
    }

    public void OnAfterUpdate(Map<Id, SVR_AuditOperationnel__c> oldMapAudit, Map<Id, SVR_AuditOperationnel__c> newMapAudit){

        for(id key : newMapAudit.keyset()){
            if(newMapAudit.get(key).Nom_du_gestionnaire__c!=null && newMapAudit.get(key).Nom_du_gestionnaire__c!=oldMapAudit.get(key).Nom_du_gestionnaire__c){
                mapAuditOPWithNomDuGestionnaireNew.put(newMapAudit.get(key).id, newMapAudit.get(key));
                userIdNew.add(newMapAudit.get(key).Nom_du_gestionnaire__c);
                if(oldMapAudit.get(key).Nom_du_gestionnaire__c != newMapAudit.get(key).CreatedById)
                    userIdOld.add(oldMapAudit.get(key).Nom_du_gestionnaire__c);
            }
        }

        if(mapAuditOPWithNomDuGestionnaireNew.size()!=0)
            SVR_AP104_AuditOperationnelSharing.auditOperationnelSharing(mapAuditOPWithNomDuGestionnaireNew, userIdNew, userIdOld);
    }

}