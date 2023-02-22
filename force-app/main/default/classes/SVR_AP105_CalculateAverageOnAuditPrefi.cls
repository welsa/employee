/**
 * @description       : Class which will be called to calculate the average scores
 * @author            : ASE
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   ASE   Initial Version*/

public with sharing class SVR_AP105_CalculateAverageOnAuditPrefi {

    public static void calculateAverage(list<SVR_DossierPreficontrol__c> lstDossierPreficontrol, set<id> auditPreficontrolSet){
        System.debug('@@@ StartcalculateAverage @@@');
        list<SVR_AuditPreficontrol__c> AuditPreficontrolList =  new list<SVR_AuditPreficontrol__c>();
        map<Id, SVR_AuditPreficontrol__c> AuditPreficontrolMap = new map<Id, SVR_AuditPreficontrol__c>();
            System.debug('##### JPI Dossier');
            For (AggregateResult ar : [SELECT COUNT(Id) Id, SVR_AuditPreficontrol__c, AVG(SVR_ChiffrageInitialHTGarage__c) SVR_ChiffrageInitialHTGarage,
                                            AVG(SVR_T1GarageCal__c) SVR_T1Garage,
                                            AVG(SVR_T2GarageCal__c) SVR_T2Garage,
                                            AVG(SVR_T3GarageCal__c) SVR_T3Garage,
                                            AVG(SVR_DelaisTraitementDossier__c) SVR_DelaisTraitementDossier,
                                            AVG(SVR_TPIngGarageCal__c) SVR_TPIngGarage,
                                            AVG(SVR_MontantPiecesHTGarage__c) SVR_MontantPiecesHTGarage,
                                            AVG(SVR_T1Preficontrol__c) SVR_T1Preficontrol,
                                            AVG(SVR_T2Preficontrol__c) SVR_T2Preficontrol,
                                            AVG(SVR_T3Preficontrol__c) SVR_T3Preficontrol,
                                            AVG(SVR_TPIngPreficontrol__c) SVR_TPIngPreficontrol,
                                            AVG(SVR_MontantPiecesPreficontrol__c) SVR_MontantPiecesPreficontrol,
                                            AVG(SVR_EADConformeAvecValeurConforme__c) SVR_EADConformeAvecValeurConforme,
                                            AVG(SVR_AlphascaleAvecValeurOui__c) SVR_AlphascaleAvecValeurOui,
                                            AVG(SVR_PositionTechniqueAvecValeurOui__c) SVR_PositionTechniqueAvecValeurOui,
                                            AVG(SVR_ChiffrageConformeGarageValeurOui__c) SVR_ChiffrageConformeGarageValeurOui
                                    from SVR_DossierPreficontrol__c
                                     where SVR_AuditPreficontrol__c IN: auditPreficontrolSet
                                        and SVR_ChiffrageModifiParPreficontrol__c = true
                                        GROUP BY SVR_AuditPreficontrol__c]){
                system.debug('moyenne 0: '+ ar);
                system.debug('#### JPI cOUNT 0: '+ ar.Id);
                Id auditId = (Id)(ar.get('SVR_AuditPreficontrol__c'));
                AuditPreficontrolMap.put(auditId, new SVR_AuditPreficontrol__c(
                    Id = auditId,
                    SVR_MoyenneChiffrageInitialHTGarageCal__c = ((ar.get('SVR_ChiffrageInitialHTGarage')) != null ) ? (Double)(ar.get('SVR_ChiffrageInitialHTGarage')) : 0,
                    SVR_DelaisMoyenTraitementDossierCal__c = ((ar.get('SVR_DelaisTraitementDossier')) != null ) ? (Double)(ar.get('SVR_DelaisTraitementDossier')) : 0,
                    SVR_MoyenneT1GarageCal__c = ((ar.get('SVR_T1Garage')) != null ) ? (Double)(ar.get('SVR_T1Garage')) : 0,
                    SVR_MoyenneT2GarageCal__c = ((ar.get('SVR_T2Garage')) != null ) ? (Double)(ar.get('SVR_T2Garage')) : 0,
                    SVR_MoyenneT3GarageCal__c = ((ar.get('SVR_T3Garage')) != null ) ? (Double)(ar.get('SVR_T3Garage')) : 0,
                    SVR_MoyenneTPIngGarageCal__c = ((ar.get('SVR_TPIngGarage')) != null ) ? (Double)(ar.get('SVR_TPIngGarage')) : 0,
                    SVR_MontantMoyenPiecesHTGarageCal__c = ((ar.get('SVR_MontantPiecesHTGarage')) != null ) ? (Double)(ar.get('SVR_MontantPiecesHTGarage')) : 0,
                    SVR_MoyenneT1PreficontrolCal__c = ((ar.get('SVR_T1Preficontrol')) != null ) ? (Double)(ar.get('SVR_T1Preficontrol')) : 0,
                    SVR_MoyenneT2PreficontrolCal__c = ((ar.get('SVR_T2Preficontrol')) != null ) ? (Double)(ar.get('SVR_T2Preficontrol')) : 0,
                    SVR_MoyenneT3PreficontrolCal__c = ((ar.get('SVR_T3Preficontrol')) != null ) ? (Double)(ar.get('SVR_T3Preficontrol')) : 0,
                    SVR_MoyenneTPIngPreficontrolCal__c = ((ar.get('SVR_TPIngPreficontrol')) != null ) ? (Double)(ar.get('SVR_TPIngPreficontrol')) : 0,
                    SVR_MontantMoyenPiecesHTPrefiCal__c = ((ar.get('SVR_MontantPiecesPreficontrol')) != null ) ? (Double)(ar.get('SVR_MontantPiecesPreficontrol')) : 0,
                    SVR_TauxEADConformeCal__c = ((ar.get('SVR_EADConformeAvecValeurConforme')) != null ) ? (Double)(ar.get('SVR_EADConformeAvecValeurConforme')) : 0,
                    SVR_TauxMoyenAlphascaleCal__c = ((ar.get('SVR_AlphascaleAvecValeurOui')) != null ) ? (Double)(ar.get('SVR_AlphascaleAvecValeurOui')) : 0,
                    SVR_TauxPositionTechniqueReparateurCal__c = ((ar.get('SVR_PositionTechniqueAvecValeurOui')) != null ) ? (Double)(ar.get('SVR_PositionTechniqueAvecValeurOui')) : 0,
                    SVR_ChiffrageConformeGarageCal__c = ((ar.get('SVR_ChiffrageConformeGarageValeurOui')) != null ) ? (Double)(ar.get('SVR_ChiffrageConformeGarageValeurOui')) : 0
            ));
            

        }

        For (AggregateResult ar : [SELECT SVR_AuditPreficontrol__c, AVG(SVR_ChiffrageInitialHTGarage__c) SVR_ChiffrageInitialHTGarage,
                                        AVG(SVR_T1Expert__c) SVR_T1Expert,
                                        AVG(SVR_T2Expert__c) SVR_T2Expert,
                                        AVG(SVR_T3Expert__c) SVR_T3Expert,
                                        AVG(SVR_TPIngExpert__c) SVR_TPIngExpert,
                                        AVG(SVR_MontantPiecesExpert__c) SVR_MontantPiecesExpert
                                from SVR_DossierPreficontrol__c
                                where SVR_AuditPreficontrol__c IN: auditPreficontrolSet
                                and SVR_ChiffrageModifiParExpert__c = true
                                GROUP BY SVR_AuditPreficontrol__c]){
            system.debug('moyenne 1: '+ ar);
            Id auditId = (Id)(ar.get('SVR_AuditPreficontrol__c'));
            if(AuditPreficontrolMap.containsKey(auditId)){
                SVR_AuditPreficontrol__c updatedAudit = AuditPreficontrolMap.get(auditId);
                updatedAudit.SVR_MoyenneT1ExpertCal__c = (Double)(ar.get('SVR_T1Expert'));
                updatedAudit.SVR_MoyenneT2ExpertCal__c = (Double)(ar.get('SVR_T2Expert'));
                updatedAudit.SVR_MoyenneT3ExpertCal__c = (Double)(ar.get('SVR_T3Expert'));
                updatedAudit.SVR_MoyenneTPIngExpertCal__c = (Double)(ar.get('SVR_TPIngExpert'));
                updatedAudit.SVR_MontantMoyenPiecesExpertCal__c = (Double)(ar.get('SVR_MontantPiecesExpert'));
            }
            else{
                AuditPreficontrolMap.put(auditId, new SVR_AuditPreficontrol__c(
                        Id = auditId,
                        SVR_MoyenneT1ExpertCal__c = (((ar.get('SVR_T1Expert')) != null ) ? (Double)(ar.get('SVR_T1Expert')) : 0),
                        SVR_MoyenneT2ExpertCal__c = (((ar.get('SVR_T2Expert')) != null ) ? (Double)(ar.get('SVR_T2Expert')) : 0),
                        SVR_MoyenneT3ExpertCal__c = (((ar.get('SVR_T3Expert')) != null ) ? (Double)(ar.get('SVR_T3Expert')) : 0),
                        SVR_MoyenneTPIngExpertCal__c = (((ar.get('SVR_TPIngExpert')) != null ) ? (Double)(ar.get('SVR_TPIngExpert')) : 0),
                        SVR_MontantMoyenPiecesExpertCal__c = (((ar.get('SVR_MontantPiecesExpert')) != null ) ? (Double)(ar.get('SVR_MontantPiecesExpert')) : 0)
                ));
            }
        }

        For (AggregateResult ar : [SELECT  SVR_AuditPreficontrol__c, AVG(SVR_T1Preficontrol__c) SVR_T1Preficontrol,
                                            AVG(SVR_T2Preficontrol__c) SVR_T2Preficontrol,
                                            AVG(SVR_T3Preficontrol__c) SVR_T3Preficontrol,
                                            AVG(SVR_TPIngPreficontrol__c) SVR_TPIngPreficontrol,
                                            AVG(SVR_MontantPiecesPreficontrol__c) SVR_MontantPiecesPreficontrol,
                                            AVG(SVR_T1Expert__c) SVR_T1Expert,
                                            AVG(SVR_T2Expert__c) SVR_T2Expert,
                                            AVG(SVR_T3Expert__c) SVR_T3Expert,
                                            AVG(SVR_TPIngExpert__c) SVR_TPIngExpert,
                                            AVG(SVR_MontantPiecesExpert__c) SVR_MontantPiecesExpert
                                    from SVR_DossierPreficontrol__c
                                    where SVR_AuditPreficontrol__c IN: auditPreficontrolSet
                                    and SVR_ChiffrageModifiParPreficontrol__c = true and SVR_ChiffrageModifiParExpert__c = true
                                    GROUP BY SVR_AuditPreficontrol__c]){
            Id auditId = (Id)(ar.get('SVR_AuditPreficontrol__c'));
            if(AuditPreficontrolMap.containsKey(auditId)) {
                SVR_AuditPreficontrol__c updatedAudit = AuditPreficontrolMap.get(auditId);
                updatedAudit.SVR_EcartMoyenT1ExppPefi1Cal__c = (((ar.get('SVR_T1Expert')) != null ) ? (Double)(ar.get('SVR_T1Expert')) : 0) - (((ar.get('SVR_T1Preficontrol')) != null ) ? (Double)(ar.get('SVR_T1Preficontrol')) : 0);
                updatedAudit.SVR_EcartMoyenT2ExpPrefi1Cal__c = (((ar.get('SVR_T2Expert')) != null ) ? (Double)(ar.get('SVR_T2Expert')) : 0) - (((ar.get('SVR_T2Preficontrol')) != null ) ? (Double)(ar.get('SVR_T2Preficontrol')) : 0);
                updatedAudit.SVR_EcartMoyenT3ExpPrefi1Cal__c = (((ar.get('SVR_T3Expert')) != null ) ? (Double)(ar.get('SVR_T3Expert')) : 0) - (((ar.get('SVR_T3Preficontrol')) != null ) ? (Double)(ar.get('SVR_T3Preficontrol')) : 0);
                updatedAudit.SVR_EcartMoyenTPIngExpVsPrefi1Cal__c = (((ar.get('SVR_TPIngExpert')) != null ) ? (Double)(ar.get('SVR_TPIngExpert')) : 0) - (((ar.get('SVR_TPIngPreficontrol')) != null ) ? (Double)(ar.get('SVR_TPIngPreficontrol')) : 0);
                updatedAudit.SVR_EcartMoyenPiecesExpPrefi1Cal__c = (((ar.get('SVR_MontantPiecesExpert')) != null ) ? (Double)(ar.get('SVR_MontantPiecesExpert')) : 0) - (((ar.get('SVR_MontantPiecesPreficontrol')) != null ) ? (Double)(ar.get('SVR_MontantPiecesPreficontrol')) : 0);
            }
          /*  else {
                AuditPreficontrolMap.put(auditId, new SVR_AuditPreficontrol__c(
                        Id = auditId,
                        SVR_EcartMoyenT1ExppPefi1Cal__c = (Double) (ar.get('SVR_T1Expert')) - (Double) (ar.get('SVR_T1Preficontrol')),
                        SVR_EcartMoyenT2ExpPrefi1Cal__c = (Double) (ar.get('SVR_T2Expert')) - (Double) (ar.get('SVR_T2Preficontrol')),
                        SVR_EcartMoyenT3ExpPrefi1Cal__c = (Double) (ar.get('SVR_T3Expert')) - (Double) (ar.get('SVR_T3Preficontrol')),
                        SVR_EcartMoyenTPIngExpVsPrefi1Cal__c = (Double) (ar.get('SVR_TPIngExpert')) - (Double) (ar.get('SVR_TPIngPreficontrol')),
                        SVR_EcartMoyenPiecesExpPrefi1Cal__c = (Double) (ar.get('SVR_MontantPiecesExpert')) - (Double) (ar.get('SVR_MontantPiecesPreficontrol'))
                ));
            } */
        }

        For (AggregateResult ar : [SELECT  SVR_AuditPreficontrol__c, AVG(SVR_T1Preficontrol__c) SVR_T1Preficontrol,
                                            AVG(SVR_T2Preficontrol__c) SVR_T2Preficontrol,
                                            AVG(SVR_T3Preficontrol__c) SVR_T3Preficontrol,
                                            AVG(SVR_TPIngPreficontrol__c) SVR_TPIngPreficontrol,
                                            AVG(SVR_MontantPiecesPreficontrol__c) SVR_MontantPiecesPreficontrol,
                                            AVG(SVR_T1Expert__c) SVR_T1Expert,
                                            AVG(SVR_T2Expert__c) SVR_T2Expert,
                                            AVG(SVR_T3Expert__c) SVR_T3Expert,
                                            AVG(SVR_TPIngExpert__c) SVR_TPIngExpert,
                                            AVG(SVR_MontantPiecesExpert__c) SVR_MontantPiecesExpert
                                    from SVR_DossierPreficontrol__c
                                    where SVR_AuditPreficontrol__c IN: auditPreficontrolSet
                                    and SVR_ChiffrageModifiParPreficontrol__c = false and SVR_ChiffrageModifiParExpert__c = true
                                    GROUP BY SVR_AuditPreficontrol__c]){
            Id auditId = (Id)(ar.get('SVR_AuditPreficontrol__c'));
            if(AuditPreficontrolMap.containsKey(auditId)) {
                SVR_AuditPreficontrol__c updatedAudit = AuditPreficontrolMap.get(auditId);
                updatedAudit.SVR_EcartMoyenT1ExpVsPrefi2Cal__c = ((ar.get('SVR_T1Expert'))!= null ? (Double)(ar.get('SVR_T1Expert')) : 0) - ((ar.get('SVR_T1Preficontrol'))!= null ? (Double)(ar.get('SVR_T1Preficontrol')) : 0);
                updatedAudit.SVR_EcartMoyenT2ExpVsPrefiCal__c = ((ar.get('SVR_T2Expert'))!= null ? (Double)(ar.get('SVR_T2Expert')) :0) - ((ar.get('SVR_T2Preficontrol'))!= null ? (Double)(ar.get('SVR_T2Preficontrol')) :0);
                updatedAudit.SVR_EcartMoyenT3ExpVsPrefi2Cal__c = ((ar.get('SVR_T3Expert')) != null ? (Double)(ar.get('SVR_T3Expert')) : 0) - ((ar.get('SVR_T3Preficontrol')) != null?(Double)(ar.get('SVR_T3Preficontrol')) : 0 );
                updatedAudit.SVR_EcartMoyenTPIngExpVsPrefi2Cal__c = ((ar.get('SVR_TPIngExpert')) != null ? (Double)(ar.get('SVR_TPIngExpert')) :0) - ((ar.get('SVR_TPIngPreficontrol')) != null? (Double)(ar.get('SVR_TPIngPreficontrol')) : 0 );
                updatedAudit.SVR_EcarMoyenPiecesExpVsPrefi2Cal__c = ((ar.get('SVR_MontantPiecesExpert')) != null ? (Double)(ar.get('SVR_MontantPiecesExpert')) :0) - ((ar.get('SVR_MontantPiecesPreficontrol'))!= null ? (Double)(ar.get('SVR_MontantPiecesPreficontrol')) : 0);
            
            }
           /* else{
                AuditPreficontrolMap.put(auditId, new SVR_AuditPreficontrol__c(
                    Id = auditId,
                    SVR_EcartMoyenT1ExpVsPrefi2Cal__c = (Double)(ar.get('SVR_T1Expert')) - (Double)(ar.get('SVR_T1Preficontrol')),
                    SVR_EcartMoyenT2ExpVsPrefiCal__c = (Double)(ar.get('SVR_T2Expert')) - (Double)(ar.get('SVR_T2Preficontrol')),
                    SVR_EcartMoyenT3ExpVsPrefi2Cal__c = (Double)(ar.get('SVR_T3Expert')) -(Double)(ar.get('SVR_T3Preficontrol')),
                    SVR_EcartMoyenTPIngExpVsPrefi2Cal__c = (Double)(ar.get('SVR_TPIngExpert')) - (Double)(ar.get('SVR_TPIngPreficontrol')),
                    SVR_EcarMoyenPiecesExpVsPrefi2Cal__c = (Double)(ar.get('SVR_MontantPiecesExpert')) - (Double)(ar.get('SVR_MontantPiecesPreficontrol'))
                ));
            } */
        }
         System.debug('@@AuditPreficontrolMap' +AuditPreficontrolMap);
        if(AuditPreficontrolMap != null){
            update AuditPreficontrolMap.values();
        }
        System.debug('@@@ StopcalculateAverage @@@');
    }
}