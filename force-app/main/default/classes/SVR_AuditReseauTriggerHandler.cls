/**
 * @description       : Il s'agit d'un Trigger Handler qui appellera les méthodes appropriées à partir des classes pour l'objet d'audit reseau lors des insert, update et delete.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 08-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   05/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AuditReseauTriggerHandler {

    Map<Id, SVR_AuditReseau__c> mapAuditRSWithSecteurNew = new Map<Id, SVR_AuditReseau__c>();
    Set<Id> mapAuditQltToUpdate = new Set<Id>();
    Set<Id> mapAuditQltToUpdateAU = new Set<Id>();
    Set<Id> userIdNew = new Set<Id>();
    Set<Id> userIdOld = new Set<Id>();

    public void OnAfterInsert(List<SVR_AuditReseau__c> newListAuditReseau){

        List<SVR_AuditReseau__c> listAuditQltToUpdateContact = new List<SVR_AuditReseau__c>();

        for(SVR_AuditReseau__c audit : [SELECT id, SVR_ResponsableSecteur__c, SVR_NomAuditeur__c, SVR_AuditReseauParent__c,recordtypeId, CreatedById, SVR_Bodyshop__c, SVR_StatutReseau__c
                                        FROM SVR_AuditReseau__c WHERE id IN: newListAuditReseau]){
            if(audit.SVR_ResponsableSecteur__c!=null){
            
                if(audit.SVR_ResponsableSecteur__c != audit.SVR_NomAuditeur__c && audit.SVR_ResponsableSecteur__c !=audit.CreatedById && audit.SVR_NomAuditeur__c!=null){
                    if(!mapAuditRSWithSecteurNew.containsKey(audit.id)){
                        mapAuditRSWithSecteurNew.put(audit.id, audit);
                        if(audit.SVR_ResponsableSecteur__c!=audit.CreatedById)
                            userIdNew.add(audit.SVR_ResponsableSecteur__c);
                        if(audit.SVR_NomAuditeur__c!=audit.CreatedById)
                            userIdNew.add(audit.SVR_NomAuditeur__c);
                    }
                }else if(audit.SVR_ResponsableSecteur__c != null && audit.SVR_ResponsableSecteur__c!=audit.CreatedById){
                    if(!mapAuditRSWithSecteurNew.containsKey(audit.id)){
                        mapAuditRSWithSecteurNew.put(audit.id, audit);
                        userIdNew.add(audit.SVR_ResponsableSecteur__c);
                    }
                }else if(audit.SVR_NomAuditeur__c != null && audit.SVR_NomAuditeur__c!=audit.CreatedById){
                    if(!mapAuditRSWithSecteurNew.containsKey(audit.id)){
                        mapAuditRSWithSecteurNew.put(audit.id, audit);
                        userIdNew.add(audit.SVR_NomAuditeur__c);
                    }
                }     
                
            }
            //WCH 12/08/2021 RSIW-10591
            if(audit.SVR_AuditReseauParent__c!=null && audit.recordtypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId()){
                mapAuditQltToUpdate.add(audit.SVR_AuditReseauParent__c);
            }
            //RLA 30/08/2021 RSIW 10577
            if(audit.recordtypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId() && audit.SVR_StatutReseau__c == 'Audit Cloturé'){
                listAuditQltToUpdateContact.add(audit);
            }

        }

        if(mapAuditRSWithSecteurNew.size()!=0)
            SVR_AP104_AuditReseauSharing.auditReseauSharing(mapAuditRSWithSecteurNew, userIdNew, null);

        //WCH 12/08/2021 RSIW-10591
        if(mapAuditQltToUpdate.size()>0)
            SVR_AP102_NouveauPointEtapes.updateParentAuditProchainPtDetape(mapAuditQltToUpdate);

        //RLA 13/08/2021 RSIW 10577
        if (listAuditQltToUpdateContact.size() > 0){
            SVR_AP106_UpdateAuditQualite.searchContactDirigeant(listAuditQltToUpdateContact);
        }

    }
    //RLA 13/08/2021 RSIW-10757
    public void onBeforeUpdate(List<SVR_AuditReseau__c> newListAuditReseau){

        for(SVR_AuditReseau__c audit : newListAuditReseau){
            //RLA 30/08/2021 RSIW-10757
            if(audit.recordtypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId() && audit.SVR_StatutReseau__c == 'Audit Cloturé'){
                audit.SVR_Audit_en_cours__c = 'Clôturé';
            }

        }   
    }

    public void OnAfterUpdate(Map<Id, SVR_AuditReseau__c> oldMapAuditReseau, Map<Id, SVR_AuditReseau__c> newMapAuditReseau){

        List<SVR_AuditReseau__c> listAuditQltToUpdateContact = new List<SVR_AuditReseau__c>();

        for(id key : newMapAuditReseau.keyset()){
            if(newMapAuditReseau.get(key).SVR_ResponsableSecteur__c!=null){
                mapAuditRSWithSecteurNew.put(newMapAuditReseau.get(key).id, newMapAuditReseau.get(key));

                if(newMapAuditReseau.get(key).SVR_ResponsableSecteur__c!=oldMapAuditReseau.get(key).SVR_ResponsableSecteur__c ){
                    if(newMapAuditReseau.get(key).SVR_ResponsableSecteur__c != newMapAuditReseau.get(key).CreatedById)
                        userIdNew.add(newMapAuditReseau.get(key).SVR_ResponsableSecteur__c);
                    if(oldMapAuditReseau.get(key).SVR_ResponsableSecteur__c != newMapAuditReseau.get(key).CreatedById )
                        userIdOld.add(oldMapAuditReseau.get(key).SVR_ResponsableSecteur__c);
                }
            }

            if(newMapAuditReseau.get(key).SVR_NomAuditeur__c!=null){
                mapAuditRSWithSecteurNew.put(newMapAuditReseau.get(key).id, newMapAuditReseau.get(key));

                if(newMapAuditReseau.get(key).SVR_NomAuditeur__c!=oldMapAuditReseau.get(key).SVR_NomAuditeur__c ){
                    if(newMapAuditReseau.get(key).SVR_NomAuditeur__c != newMapAuditReseau.get(key).CreatedById)
                        userIdNew.add(newMapAuditReseau.get(key).SVR_NomAuditeur__c);
                    if(oldMapAuditReseau.get(key).SVR_NomAuditeur__c != newMapAuditReseau.get(key).CreatedById )
                        userIdOld.add(oldMapAuditReseau.get(key).SVR_NomAuditeur__c);
                }
            }
            //WCH 12/08/2021 RSIW-10591
            if(newMapAuditReseau.get(key).SVR_AuditReseauParent__c!=null && newMapAuditReseau.get(key).recordtypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId()){
                mapAuditQltToUpdateAU.add(newMapAuditReseau.get(key).SVR_AuditReseauParent__c);
            }

            //RLA 30/08/2021 RSIW 10577
            if(newMapAuditReseau.get(key).recordtypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId() && oldMapAuditReseau.get(key).SVR_StatutReseau__c != newMapAuditReseau.get(key).SVR_StatutReseau__c && newMapAuditReseau.get(key).SVR_StatutReseau__c == 'Audit Cloturé'){
                listAuditQltToUpdateContact.add(newMapAuditReseau.get(key));
            }
        }
        
        if(mapAuditRSWithSecteurNew.size()!=0)
            SVR_AP104_AuditReseauSharing.auditReseauSharing(mapAuditRSWithSecteurNew, userIdNew, userIdOld);
        //WCH 12/08/2021 RSIW-10591
        if(mapAuditQltToUpdateAU.size()>0)
            SVR_AP102_NouveauPointEtapes.updateParentAuditProchainPtDetape(mapAuditQltToUpdateAU);

        //RLA 13/08/2021 RSIW 10577
        if (listAuditQltToUpdateContact.size() > 0){
            SVR_AP106_UpdateAuditQualite.searchContactDirigeant(listAuditQltToUpdateContact);
        }

    }
}