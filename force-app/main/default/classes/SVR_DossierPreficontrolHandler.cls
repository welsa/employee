/**
 * @description       : Triggerhandler which will be called when a dossier Preficontrol is inserted ,updated or deleted.
 * @author            : ASE
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   ASE   Initial Version*/

public with sharing class SVR_DossierPreficontrolHandler {
    
    Map<Id, SVR_Performance__c> mapPerfWithNomDuGestionnaire = new Map<Id, SVR_Performance__c>();
    Map<Id, SVR_Performance__c> mapPerfWithResponsableSecteur = new Map<Id, SVR_Performance__c>();
    Set<Id> userIdRSNew = new Set<Id>();
    Set<Id> userIdRSOld = new Set<Id>();
    Set<Id> userIdOPNew = new Set<Id>();
    Set<Id> userIdOPOld = new Set<Id>();

    list<SVR_DossierPreficontrol__c> newListCMDossierPrefi = new list<SVR_DossierPreficontrol__c>();
    set<id> auditPreficontrolSet = new set<id>();

    public void OnAfterInsert(List<SVR_DossierPreficontrol__c> lstDossierPrefi){
        System.debug('@@@Start OnAfterInsert @@');
        for(SVR_DossierPreficontrol__c newDossierPrefi : lstDossierPrefi){
            if(Schema.getGlobalDescribe().get('SVR_DossierPreficontrol__c').getDescribe().getRecordTypeInfosById().get(newDossierPrefi.recordTypeId).getDeveloperName() == 'CM'){ // newDossierPrefi.RecordType.DeveloperName
                newListCMDossierPrefi.add(newDossierPrefi);
                auditPreficontrolSet.add(newDossierPrefi.SVR_AuditPreficontrol__c);
            }
            if(newListCMDossierPrefi !=null){
                SVR_AP105_CalculateAverageOnAuditPrefi.calculateAverage(newListCMDossierPrefi, auditPreficontrolSet);
            }
        }
        System.debug('@@@Stop OnAfterInsert @@');
   }

    public void OnAfterUpdate(List<SVR_DossierPreficontrol__c> oldListDossierPreficontrol, List<SVR_DossierPreficontrol__c> newListDossierPreficontrol){
        System.debug('@@@Start OnAfterUpdate @@');
        for(Integer i = 0; i < newListDossierPreficontrol.size(); i++){

            SVR_DossierPreficontrol__c newDossier = newListDossierPreficontrol[i];
            SVR_DossierPreficontrol__c oldDossier = oldListDossierPreficontrol[i];

            if(Schema.getGlobalDescribe().get('SVR_DossierPreficontrol__c').getDescribe().getRecordTypeInfosById().get(newDossier.recordTypeId).getDeveloperName() == 'CM' && (
                    oldDossier.SVR_ChiffrageInitialHTGarage__c != newDossier.SVR_ChiffrageInitialHTGarage__c
                    ||oldDossier.SVR_T1GarageCal__c != newDossier.SVR_T1GarageCal__c
                    || oldDossier.SVR_T2GarageCal__c != newDossier.SVR_T2GarageCal__c
                    || oldDossier.SVR_T3GarageCal__c != newDossier.SVR_T3GarageCal__c
                    || oldDossier.SVR_TPIngGarageCal__c != newDossier.SVR_TPIngGarageCal__c
                    || oldDossier.SVR_MontantPiecesHTGarage__c != newDossier.SVR_MontantPiecesHTGarage__c
                    || oldDossier.SVR_T1Preficontrol__c != newDossier.SVR_T1Preficontrol__c
                    || oldDossier.SVR_T2Preficontrol__c != newDossier.SVR_T2Preficontrol__c
                    || oldDossier.SVR_T3Preficontrol__c != newDossier.SVR_T3Preficontrol__c
                    || oldDossier.SVR_TPIngPreficontrol__c != newDossier.SVR_TPIngPreficontrol__c
                    || oldDossier.SVR_MontantPiecesPreficontrol__c != newDossier.SVR_MontantPiecesPreficontrol__c
                    || oldDossier.SVR_T2Preficontrol__c != newDossier.SVR_T2Preficontrol__c
                    || oldDossier.SVR_T3Preficontrol__c != newDossier.SVR_T3Preficontrol__c
                    || oldDossier.SVR_TPIngPreficontrol__c != newDossier.SVR_TPIngPreficontrol__c
                    || oldDossier.SVR_MontantPiecesPreficontrol__c != newDossier.SVR_MontantPiecesPreficontrol__c
                    || oldDossier.SVR_EADConforme__c != newDossier.SVR_EADConforme__c
                    || oldDossier.SVR_Alphascale__c != newDossier.SVR_Alphascale__c
                    || oldDossier.SVR_PositionTechniqueSuiviParLeReparate__c != newDossier.SVR_PositionTechniqueSuiviParLeReparate__c
                    || oldDossier.SVR_ChiffrageGarage__c != newDossier.SVR_ChiffrageGarage__c
                    || oldDossier.SVR_T1Expert__c != newDossier.SVR_T1Expert__c
                    || oldDossier.SVR_T2Expert__c != newDossier.SVR_T2Expert__c
                    || oldDossier.SVR_T3Expert__c != newDossier.SVR_T3Expert__c
                    || oldDossier.SVR_TPIngExpert__c != newDossier.SVR_TPIngExpert__c
                    || oldDossier.SVR_MontantPiecesExpert__c != newDossier.SVR_MontantPiecesExpert__c
                    || oldDossier.SVR_ChiffrageModifiParPreficontrol__c != newDossier.SVR_ChiffrageModifiParPreficontrol__c
                    || oldDossier.SVR_ChiffrageModifiParExpert__c != newDossier.SVR_ChiffrageModifiParExpert__c)){
                newListCMDossierPrefi.add(newDossier);
                auditPreficontrolSet.add(newDossier.SVR_AuditPreficontrol__c);
            }

            if(newListCMDossierPrefi !=null){
                SVR_AP105_CalculateAverageOnAuditPrefi.calculateAverage(newListCMDossierPrefi, auditPreficontrolSet);
            }
        }
        System.debug('@@@STop OnAfterUpdate @@');
    }



    public void OnAfterDelete(list<SVR_DossierPreficontrol__c> oldDossierPreficonLst){
        System.debug('@@@Start OnAfterDelete @@');
        for(SVR_DossierPreficontrol__c oldDossierPrefi : oldDossierPreficonLst){
            if(Schema.getGlobalDescribe().get('SVR_DossierPreficontrol__c').getDescribe().getRecordTypeInfosById().get(oldDossierPrefi.recordTypeId).getDeveloperName() == 'CM'){
                newListCMDossierPrefi.add(oldDossierPrefi);
                auditPreficontrolSet.add(oldDossierPrefi.SVR_AuditPreficontrol__c);
            }

            if(newListCMDossierPrefi !=null){
                SVR_AP105_CalculateAverageOnAuditPrefi.calculateAverage(newListCMDossierPrefi, auditPreficontrolSet);
            }
        }
        System.debug('@@@Stop OnAfterDelete @@');
    }
}