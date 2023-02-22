/**
 * @description       : This class will take the current audit where the button has been clicked and search for the most recent audit of the ultimate parent of the current audit and clone that audit.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 08-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   12/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP102_NouveauPointEtapes {
    public static List<SVR_AuditReseau__c> listAudit = new List<SVR_AuditReseau__c>();
    public static String ultimateAuditParent = '';
    public static List<Audit_Plan_Action__c> checkPlanActionLst = new List<Audit_Plan_Action__c>();
    public static List<Audit_Plan_Action__c> listPlanAction = new List<Audit_Plan_Action__c>();
    public static List<SVR_AuditReseau__c> listRecentAuditEnfant = new  List<SVR_AuditReseau__c>();
    public static List<SVR_AuditReseau__c> listRecentAuditParent = new  List<SVR_AuditReseau__c>();
    public static SVR_AuditReseau__c auditPointEtape = new SVR_AuditReseau__c();
    public static SVR_AuditReseau__c auditParent = new SVR_AuditReseau__c();
    public static boolean toUpdate = false;
    public static map<Id, SVR_AuditReseau__c> mapARToUpdate = new map<Id, SVR_AuditReseau__c>();//WCH 12/08/2021 RSIW-10591


    @AuraEnabled
    public static AuditListWrapper cloneAuditParent(String auditId, String type){
        system.debug('##  SVR_AP102_NouveauPointEtapes.cloneAuditParent start');
        // select all fields from current audit record

        listAudit = [SELECT SVR_Accessibilite__c,SVR_AccueilPresentation__c,SVR_Acier__c,SVR_AcquisCMASF__c, Name,
                    SVR_AcquisSujetsTransverses__c,SVR_AdministratifConvoyeur__c,SVR_AnimationTauxRetourQualite__c,
                    SVR_AuditReseauParent__c,SVR_AuditReseauUltimate__c,SVR_Audit_en_cours__c,SVR_AutreControleurReparations__c,
                    SVR_AutreCritereDerive__c,SVR_AutrePersonneRealisantSAD__c,SVR_BenchmarkPieces__c,SVR_Bodyshop__c,
                    SVR_Cloture__c,SVR_Collaborator__c,SVR_Commentaire_Interne_Prefikar__c,SVR_Commentaire__c,SVR_Competence__c,
                    SVR_ConditionCommercialeASFSatisfaisante__c,SVR_ConnaissanceSD__c,SVR_ConnaissanceStrategieAchatEntreprise__c,
                    SVR_ControleurReparations__c,SVR_ControleVehiculeFinCycle__c,SVR_Convoyeur__c,SVR_CriteresDerives__c,
                    SVR_DateAudit__c,SVR_DateVisite__c,SVR_Departement__c,SVR_DMS__c,SVR_DureeVieDRRecuDARVA__c,
                    SVR_DureeVieUnDRRecuParDARVA__c,SVR_EquipeKitReparationPlastique__c,SVR_EtatGeneralChocsAnterieursProprete__c,
                    SVR_FormeSAD__c,SVR_HistoriquePlanAction__c,SVR_MaitriseUtilisationOutilChiffrage__c,SVR_MarquePeinture__c,
                    SVR_MiseSousTutelle__c,SVR_MoinsDe3ansEt6000Kms__c,SVR_NbAcquisCMGlobal__c,SVR_NbAcquisQualite__c,
                    SVR_NbConformeDernierChiffrageExpert__c,SVR_NbFacturationPiecesAchetees__c,SVR_NbFacturesAchatPiecesDetachees__c,
                    SVR_NbMiseDispoVRDebutTravaux__c,SVR_NbOrdreReparationSign__c,SVR_NbPhotosRestitutionVhAssure__c,
                    SVR_NbPhotosRestitutionVR__c,SVR_NbProcesVerbalRestitution__c,SVR_NbReceptionRapportDefinitifExpert__c,
                    SVR_NbRespectAccordsTarifairesNegocies__c,SVR_NbrVRDefautRestitution__c,SVR_NbSADMisDispositionConforme__c,
                    SVR_NbSADPhotosRestitutionVhAssur__c,SVR_NbSADPhotosRestitutionVR__c,SVR_NbSADProcesVerbalRestitution__c,
                    SVR_NbSADRestitutioConforme__c,SVR_NbTransmissionFactureClient__c,SVR_NomAuditeur__c,
                    SVR_NombreDisponibleSuffisante__c,SVR_NombreDossier__c,SVR_ObjectifVisite__c,SVR_OutilDeChiffrage__c,
                    SVR_PartageImpactFinancier__c,SVR_PartageResultats__c,SVR_PercentAcquisCMASF__c,SVR_PercentAcquisCMGlobal__c,
                    SVR_PercentAcquisQualite__c,SVR_PercentAcquisSujetsTransverses__c,SVR_PersonneRealisantSad__c,SVR_Plastique__c,
                    SVR_PriseMainRapideASF__c,SVR_Process_Information_de_l_Assur__c,SVR_Productif__c,SVR_Proprete__c,
                    SVR_PVRestitutionUtilise__c,SVR_QuiUtiliseASF__c,SVR_ResponsableSecteur__c,SVR_ScoreCompletudeBonVRAller__c,
                    SVR_ScoreCompletudeBonVRRetour__c,SVR_ScoreSADCompletudeBonRetour__c,SVR_ScoreSADCompletudeBonVRAller__c,
                    SVR_ScoreSADCompletudeBonVRRetour__c,SVR_ScoreSADExplicationTravauxAssure__c,SVR_ScoreSADResumeEtapeReparation__c,
                    SVR_Secteur__c,SVR_StatutReseau__c,SVR_TECHCloture__c,SVR_TECHMiseSousTutelle__c,SVR_TotalCompletudeBonVRAller__c,
                    SVR_TotalCompletudeduBonVRRetour__c,SVR_TotalExplicationTravauxAssur__c,SVR_TotalSADCompletudeBetouronR__c,
                    SVR_TotalSADCompletudeBonVRAller__c,SVR_TotalSADCompletudeBonVRRetour__c,SVR_TotalSADExplicationTravauxAssure__c,
                    SVR_TotalSADResumeEtapeReparation__c,SVR_Type_daudit__c,SVR_UtilisationSubstitutionA__c,SVR_UtilisationSubstitutionB__c,
                    SVR_UtilisationSubstitutionC__c,SVR_UtilisationSubstitutionE__c,SVR_UtilisationSubstitutionGlobal__c, recordTypeId, 
                    SVR_AutresFormesAuSAD__c, SVR_NbConvoyeursRealisantSAD__c, SVR_TECH_ContientPointEtape__c
                    FROM SVR_AuditReseau__c
                    WHERE Id =:auditId LIMIT 1];

        // check if this record is an audit
        if(listAudit[0].SVR_AuditReseauUltimate__c == null){
            // check there is a point d'étape
            if(listAudit[0].SVR_TECH_ContientPointEtape__c){
                return new AuditListWrapper(null, null, 'HasPE');
            }else{
                System.debug('####JPI else in 1');

                // check if there is a plan d'action
                if(checkPlanDaction(listAudit[0].Id)){
                    return new AuditListWrapper(null, null, 'NoPA');
                }else{
                    System.debug('####JPI in 1');
                    // clone audit
                    auditPointEtape = cloneAudit(listAudit[0], listAudit[0].Id);
                
                    // update auditParent
                    auditParent = new SVR_AuditReseau__c (Id = listAudit[0].Id,  isPointEtape__c =null, SVR_StatutReseau__c = 'Point d\'étape en cours', SVR_TECH_ContientPointEtape__c = true);          
                }
            }
        }
        else{ // this is a PE

            if(listAudit[0].SVR_StatutReseau__c=='Audit Cloturé' && listAudit[0].SVR_TECH_ContientPointEtape__c){
                return new AuditListWrapper(null, null, 'Closed');
            }else{
                System.debug('####JPI else in 2');
                // check if there is a plan d'action
                if(checkPlanDaction(listAudit[0].Id)){
                    return new AuditListWrapper(null, null, 'NoPA');
                }else{
                    System.debug('####JPI in 2');
                    // clone audit
                    auditPointEtape = cloneAudit(listAudit[0],  listAudit[0].SVR_AuditReseauUltimate__c);
                
                    // update auditParent
                    auditParent = new SVR_AuditReseau__c (Id = listAudit[0].Id, isPointEtape__c =null, SVR_StatutReseau__c = 'Audit Cloturé', SVR_TECH_ContientPointEtape__c = true);          
                }
            }
        }
        
        if(auditParent!=null && type!='TEST'){
            update auditParent;
        }

        if(auditPointEtape!=null && type!='TEST'){
            insert auditPointEtape;
            return new AuditListWrapper(auditPointEtape.Id, auditPointEtape.Name, 'NONE');
        }

        system.debug('##  SVR_AP102_NouveauPointEtapes.cloneAuditParent end');
        return new AuditListWrapper(null, null, 'NONE');
    }

    public static String checkRecordType(Id Id){
        if(Id == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get('SVR_ReseauCoutMoyen').getRecordTypeId() || Id == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get('SVR_ReseauCoutMoyenChild').getRecordTypeId()){
            return 'SVR_ReseauCoutMoyenChild';
        }

        if(Id == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get('SVR_ReseauQualite').getRecordTypeId() || Id == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get('SVR_ReseauQualiteChild').getRecordTypeId()){
            return 'SVR_ReseauQualiteChild';
        }

        return null;
    }

    public static boolean checkPlanDaction(Id idAudit){
        checkPlanActionLst = [SELECT id, recordTypeId, Name
                                FROM Audit_Plan_Action__c
                                WHERE SVR_AuditReseau__c =: idAudit  ORDER BY CreatedDate DESC LIMIT 1];
        if(checkPlanActionLst.size()==0){
            return true;
        }
        else {
            return false;
        }
    }


    public static SVR_AuditReseau__c cloneAudit(SVR_AuditReseau__c audit, Id ultimateParentId) {
        SVR_AuditReseau__c auditCopy= new SVR_AuditReseau__c();
        auditCopy = audit.clone(false, true, false, false);
        auditCopy.recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(checkRecordType(audit.recordTypeId)).getRecordTypeId();
        auditCopy.SVR_AuditReseauParent__c = audit.Id;
        auditCopy.SVR_AuditReseauUltimate__c = audit.Id;
        auditCopy.SVR_StatutReseau__c = null;
        auditCopy.SVR_DateVisite__c = null;
        auditCopy.isPointEtape__c = ultimateParentId;
        auditCopy.SVR_TECH_ContientPointEtape__c = false;
        return auditCopy;
    }

    //WCH 12/08/2021 RSIW-10591
    public static void updateParentAuditProchainPtDetape(Set<Id> mapAuditQltToUpdate){
        for (SVR_AuditReseau__c  auditReseau: [select Id,(select id,SVR_DateVisite__c from AuditsReseau__r where recordtype.developername='SVR_ReseauQualiteChild' order by SVR_DateVisite__c DESC limit 1) FROM SVR_AuditReseau__c WHERE Id=:mapAuditQltToUpdate ]){
            system.debug('auditReseau>>'+auditReseau);
            if(auditReseau.AuditsReseau__r.size() > 0 && auditReseau.AuditsReseau__r[0].SVR_DateVisite__c!=null){
                mapARToUpdate.put(auditReseau.Id,new SVR_AuditReseau__c(id=auditReseau.Id,SVR_Date_du_prochain_point_detape__c=auditReseau.AuditsReseau__r[0].SVR_DateVisite__c));
            }
        }
        if(!mapARToUpdate.isEmpty())
            update mapARToUpdate.values();
    }

    public class AuditListWrapper{

        @AuraEnabled public Id id;
        @AuraEnabled public String Name;
        @AuraEnabled public String errorType;

        public AuditListWrapper(Id idV, String nameV, String errorTypeV){

            id = idV;
            name = nameV;
            errorType = errorTypeV;
        }
    }
}