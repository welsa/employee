/*************************************************************************************
Class Name - SVR_AP106_DossierTriggerHandler
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 12-08-2021
Function - Class to manage SVR_Dossier__c
#Ticket  - RSIW : 10584

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           12-08-2021   Initial version
*************************************************************************************/
public class SVR_DossierTriggerHandler {
    
    public void NOBOnAfterInsert(List<SVR_Dossier__c> lstNewDossiers){
        Set<Id> setAuditIds = new Set<Id>();
        
        if (lstNewDossiers.size () > 0){
            for (SVR_Dossier__c dossier : lstNewDossiers){
                
                //section reparation
                //HMO -- 03-09-2021 - commented for deployement
                 if ((dossier.SVR_OrdreDeReparationSigne__c != null
                      || dossier.SVR_CompletudeDuBonVRAller__c != null
                      || dossier.SVR_SADPhotosLaRestitutionVR__c != null
                      || dossier.SVR_PhotosLaRestitutionVR__c != null
                      || dossier.SVR_MiseDispositionVRDebutDesTravaux__c != null
                      || dossier.SVR_ProcesVerbalDeRestitution__c!= null
                      || dossier.SVR_PhotosLaRestitutionVhAssure__c != null
                      || dossier.SVR_CompletudeDuBonVRRetour__c != null
                      || dossier.SVR_SADRealiseLieuLheurePrevuAller__c != null
                      || dossier.SVR_SADProcesVerbalDeRestitution__c != null
                      || dossier.SVR_SADRestitutionConforme__c != null
                      || dossier.SVR_SADPhotosLaRestitutionVhAssure__c != null
                      || dossier.SVR_RespectDesAccordsTarifairesNegocies__c != null
                      || dossier.SVR_TransmissionFactureClient__c != null
                      || dossier.SVR_PresentationsDejustificatifsDachats__c!= null
                      || dossier.SVR_ReceptionRapporDefinitifExpert__c != null 
                      || dossier.SVR_ConformeDerniersChiffrageDeLexpert__c != null
                      || dossier.SVR_FactDesPiecesAchteesConforEurope__c!=null) && dossier.SVR_AuditRS__c != null){
                            setAuditIds.add(dossier.SVR_AuditRS__c);
                }
                
            }

            if (setAuditIds.size() > 0){
                SVR_AP106_UpdateAuditQualite.getDossiers(setAuditIds);
            }
        }
    }
    
    public void NOBOnAfterUpdate(List<SVR_Dossier__c> lstDossierUpdated, Map<Id, SVR_Dossier__c> mapOldDossiers){
            Set<Id> setAuditIdsUpdate = new Set<Id>();
            for (SVR_Dossier__c dossier : lstDossierUpdated) {
                if ((dossier.SVR_OrdreDeReparationSigne__c != mapOldDossiers.get(dossier.Id).SVR_OrdreDeReparationSigne__c)
                || (dossier.SVR_CompletudeDuBonVRAller__c != mapOldDossiers.get(dossier.Id).SVR_CompletudeDuBonVRAller__c)
                    || (dossier.SVR_CompletudeDuBonVRRetour__c != mapOldDossiers.get(dossier.Id).SVR_CompletudeDuBonVRRetour__c)
                    || (dossier.SVR_PhotosLaRestitutionVR__c != mapOldDossiers.get(dossier.Id).SVR_PhotosLaRestitutionVR__c)
                    || (dossier.SVR_MiseDispositionVRDebutDesTravaux__c != mapOldDossiers.get(dossier.Id).SVR_MiseDispositionVRDebutDesTravaux__c)
                    || (dossier.SVR_ProcesVerbalDeRestitution__c != mapOldDossiers.get(dossier.Id).SVR_ProcesVerbalDeRestitution__c)
                    || (dossier.SVR_SADScriptExplicationTravauxLassure__c != mapOldDossiers.get(dossier.Id).SVR_SADScriptExplicationTravauxLassure__c)
                    || (dossier.SVR_PhotosLaRestitutionVhAssure__c != mapOldDossiers.get(dossier.Id).SVR_SADPhotosLaRestitutionVhAssure__c)
                    || (dossier.SVR_SADRealiseLieuLheurePrevuAller__c != mapOldDossiers.get(dossier.Id).SVR_SADRealiseLieuLheurePrevuAller__c)
                    || (dossier.SVR_SADRestitutionConforme__c != mapOldDossiers.get(dossier.Id).SVR_SADRestitutionConforme__c)
                    || (dossier.SVR_SADCompletudeBonAller__c != mapOldDossiers.get(dossier.Id).SVR_SADCompletudeBonAller__c)
                    || (dossier.SVR_SADCompletudeBonRetour__c != mapOldDossiers.get(dossier.Id).SVR_SADCompletudeBonRetour__c)
                    || (dossier.SVR_SADCompletudeBonVRAller__c != mapOldDossiers.get(dossier.Id).SVR_SADCompletudeBonVRAller__c)
                    || (dossier.SVR_SADCompletudeBonVRRetour__c != mapOldDossiers.get(dossier.Id).SVR_SADCompletudeBonVRRetour__c)
                    || (dossier.SVR_SADProcesVerbalDeRestitution__c != mapOldDossiers.get(dossier.Id).SVR_SADProcesVerbalDeRestitution__c)
                    || (dossier.SVR_SADResumeEtapesReparation__c != mapOldDossiers.get(dossier.Id).SVR_SADResumeEtapesReparation__c)
                    || (dossier.SVR_SADPhotosLaRestitutionVhAssure__c != mapOldDossiers.get(dossier.Id).SVR_SADPhotosLaRestitutionVhAssure__c)
                    || (dossier.SVR_SADPhotosLaRestitutionVR__c != mapOldDossiers.get(dossier.Id).SVR_SADPhotosLaRestitutionVR__c)
                    || (dossier.SVR_SADScriptExplicationTravauxLassure__c != mapOldDossiers.get(dossier.Id).SVR_SADScriptExplicationTravauxLassure__c)
                    || (dossier.SVR_RespectDesAccordsTarifairesNegocies__c != mapOldDossiers.get(dossier.Id).SVR_RespectDesAccordsTarifairesNegocies__c)
                    || (dossier.SVR_TransmissionFactureClient__c != mapOldDossiers.get(dossier.Id).SVR_TransmissionFactureClient__c)
                    || (dossier.SVR_PresentationsDejustificatifsDachats__c != mapOldDossiers.get(dossier.Id).SVR_PresentationsDejustificatifsDachats__c)
                    || (dossier.SVR_ReceptionRapporDefinitifExpert__c != mapOldDossiers.get(dossier.Id).SVR_ReceptionRapporDefinitifExpert__c)
                    || (dossier.SVR_ConformeDerniersChiffrageDeLexpert__c != mapOldDossiers.get(dossier.Id).SVR_ConformeDerniersChiffrageDeLexpert__c)
                    || (dossier.SVR_FactDesPiecesAchteesConforEurope__c != mapOldDossiers.get(dossier.Id).SVR_FactDesPiecesAchteesConforEurope__c)){
                            setAuditIdsUpdate.add(dossier.SVR_AuditRS__c);
                }
           }

           if (setAuditIdsUpdate.size() > 0){
            SVR_AP106_UpdateAuditQualite.getDossiers(setAuditIdsUpdate);
        }
      }       
}