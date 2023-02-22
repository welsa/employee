/**
 * @description       : Cette classe sera appelée par le handler SVR_AuditTriggerHandler lorsqu'un audit est inséré pour obtenir l'historique des plans d'action créé
 * @author            : JPI
 * @group             : AP01
 * @last modified on  : 08/06/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   27/11/2020   JPI   Initial Version
**/
public with sharing class SVR_AP100_AuditAvoirPlanDactionNonAcquis {

    static String valuePLNonAcquis = SVR_AP100_Constant.auditStatutNonAcquis;
    static List<Id> recordTypeList = new List<Id>();
    static Set<Id> nomGestionnaireList = new Set<Id>();
    static List<SVR_AuditOperationnel__c> listAuditUpdateOP = new List<SVR_AuditOperationnel__c>();
    static List<SVR_AuditOperationnel__c> listAuditNewOP = new List<SVR_AuditOperationnel__c>();
    static List<Audit_Plan_Action__c> listPlanAction = new List<Audit_Plan_Action__c>();
    static List<Audit_Plan_Action__c> listPlanActionLoop = new List<Audit_Plan_Action__c>();
    static Map<String,List<Audit_Plan_Action__c>> mapRecordTypePlanAction = new Map<String,List<Audit_Plan_Action__c>>();

    /**
    * @description Cette méthode permettra d'obtenir tous les plans d'action où les statut améliorations 1, 2 et 3 sont «non acquis» liées à le meme recordType de l'audit.
    * @author JPI | 30/11/2020 
    * @param List<SVR_AuditOperationnel__c> newListAudit 
    **/
    public static void asigneRichTextToNonAcquisPlanActionOP(List<SVR_AuditOperationnel__c> newListAudit) {

        for(SVR_AuditOperationnel__c ad: newListAudit){
            recordTypeList.add(ad.RecordTypeId);
            nomGestionnaireList.add(ad.Nom_du_gestionnaire__c);

        }
        System.debug('$$$$ List of recordtype: ' +  recordTypeList);
        System.debug('$$$$ List of nomGestionnaireList: ' +  nomGestionnaireList);

        // Avoir les plans d'action d'ou les statuts sont 'non acquis' et le record des audit sont le même que le record de l'audit insérées.
        listPlanAction = [SELECT Name, AxeAmelioration1__c, AxeAmelioration2__c, AxeAmelioration3__c, SVR_AuditOperationnel__r.RecordTypeId,
                        SVR_AmelItem1__c, SVR_AmelItem2__c, SVR_AmelItem3__c,
                        SVR_AmelCommentaire1__c, SVR_AmelCommentaire2__c, SVR_AmelCommentaire3__c, SVR_AuditOperationnel__r.Nom_du_gestionnaire__c ,
                        SVR_StatutAmelioration1__c, SVR_StatutAmelioration2__c, SVR_StatutAmelioration3__c, SVR_AxesAmeliorationAdditionnels__c
                        FROM Audit_Plan_Action__c 
                        WHERE (SVR_StatutAmelioration1__c=:valuePLNonAcquis OR SVR_StatutAmelioration2__c=:valuePLNonAcquis OR SVR_StatutAmelioration3__c=:valuePLNonAcquis) 
                        AND SVR_AuditOperationnel__r.RecordTypeId in : recordTypeList
                        AND SVR_AuditOperationnel__r.Nom_du_gestionnaire__c in : nomGestionnaireList];

        System.debug('$$$$ List of Plan Action: ' +  listPlanAction);
        System.debug('$$$$ List of Plan Action size: ' +  listPlanAction.size());

        // Si la liste des plans d'action sont vide on ne fait rien.
        if(listPlanAction.size()!=0){

            // Crée une map de recordtype:key et liste Plan d'action: value 
            for(Audit_Plan_Action__c pa : listPlanAction){
                if(mapRecordTypePlanAction.containsKey(String.valueOf(pa.SVR_AuditOperationnel__r.RecordTypeId)+String.valueOf(pa.SVR_AuditOperationnel__r.Nom_du_gestionnaire__c))){
                    mapRecordTypePlanAction.get(String.valueOf(pa.SVR_AuditOperationnel__r.RecordTypeId)+String.valueOf(pa.SVR_AuditOperationnel__r.Nom_du_gestionnaire__c)).add(pa);
                }else{
                    List<Audit_Plan_Action__c> listPa =  new List<Audit_Plan_Action__c>();
                    listPa.add(pa);
                    mapRecordTypePlanAction.put(String.valueOf(pa.SVR_AuditOperationnel__r.RecordTypeId)+String.valueOf(pa.SVR_AuditOperationnel__r.Nom_du_gestionnaire__c),listPa);
                }
            }

             
            System.debug('$$$$ map of Plan Action: ' +  mapRecordTypePlanAction);
            listAuditNewOP = [SELECT RecordTypeId, SVR_HistoriquePlanAction__c, Nom_du_gestionnaire__c
                            FROM SVR_AuditOperationnel__c
                            WHERE Id in : newListAudit];

            // Boucle qui va construire un string de l'historique pour les plans d'action non acquis avec 
            // les audits qui ont le même recordtype que l'audit insérée.
            for(SVR_AuditOperationnel__c audit: listAuditNewOP){

                System.debug('$$$$ Record Type of Audit: ' +  audit.RecordTypeId);
                if(mapRecordTypePlanAction.containsKey(String.valueOf(audit.RecordTypeId)+String.valueOf(audit.Nom_du_gestionnaire__c)) && mapRecordTypePlanAction.get(String.valueOf(audit.RecordTypeId)+String.valueOf(audit.Nom_du_gestionnaire__c)).size()!=0){
                    listPlanActionLoop = mapRecordTypePlanAction.get(String.valueOf(audit.RecordTypeId)+String.valueOf(audit.Nom_du_gestionnaire__c));
                    String historique = '';
                    for(Audit_Plan_Action__c pa: listPlanActionLoop){
                        if(pa.SVR_StatutAmelioration1__c==valuePLNonAcquis || pa.SVR_StatutAmelioration2__c==valuePLNonAcquis || pa.SVR_StatutAmelioration3__c==valuePLNonAcquis){
                            
                            historique += '<b style="margin:0px;padding: 0px;"><h3>' + pa.Name + ': <h3></b><ol >' ;
                            if(pa.SVR_StatutAmelioration1__c==valuePLNonAcquis){
                                historique += '<li style="padding-bottom: 10px;">' +
                                                    '<div><b> - Axe d\'amelioration 1: </b>' + pa.AxeAmelioration1__c + '</div>' +
                                                    '<div><b> - Item 1: </b>' + pa.SVR_AmelItem1__c +'</div>';

                                if(pa.SVR_AmelCommentaire1__c==null)              
                                    historique += '<div><b> - Commentaire 1: </b>#N/A</div>' ;
                                else             
                                    historique += '<div><b> - Commentaire 1: </b>' + pa.SVR_AmelCommentaire1__c +'</div>' ;    
                                
                                historique += '<div><b> - Statut 1: </b>' + valuePLNonAcquis +'</div></li>' ;  
                            }
                            if(pa.SVR_StatutAmelioration2__c==valuePLNonAcquis){
                                historique += '<li style="padding-bottom: 10px;">' +
                                                    '<div><b> - Axe d\'amelioration 2: </b>' + pa.AxeAmelioration2__c + '</div>' +
                                                    '<div><b> - Item 2: </b>' + pa.SVR_AmelItem2__c +'</div>';

                                if(pa.SVR_AmelCommentaire2__c==null)              
                                    historique += '<div><b> - Commentaire 2: </b>#N/A</div>' ;
                                else                            
                                    historique += '<div><b> - Commentaire 2: </b>' + pa.SVR_AmelCommentaire2__c +'</div>';
                                
                                historique += '<div><b> - Statut 2: </b>' + valuePLNonAcquis +'</div></li>';  
                            }
                            if(pa.SVR_StatutAmelioration3__c==valuePLNonAcquis){
                                historique += '<li style="padding-bottom: 10px;">' +
                                                    '<div><b> - Axe d\'amelioration 3: </b>' + pa.AxeAmelioration3__c + '</div>' +
                                                    '<div><b> - Item 3: </b>' + pa.SVR_AmelItem3__c +'</div>' ;
                                if(pa.SVR_AmelCommentaire3__c==null)              
                                    historique += '<div><b> - Commentaire 3: </b>#N/A</div>' ; 
                                else 
                                    historique += '<div><b> - Commentaire 3: </b>' + pa.SVR_AmelCommentaire3__c +'</div>';
                                
                                historique += '<div><b> - Statut 3: </b>' + valuePLNonAcquis +'</div></li>' ;  
                            }  

                            if(pa.SVR_AxesAmeliorationAdditionnels__c!=null){
                                historique += '<li style="padding-bottom: 10px;">Axe d\'amelioration Additionnel: ' + pa.SVR_AxesAmeliorationAdditionnels__c.replaceAll('\\<.*?\\>', '') + '</li>' ;  
                            } 
                        }
                        
                        historique +='</ol><br></br>';
                    }
                    audit.SVR_HistoriquePlanAction__c = historique;
                    listAuditUpdateOP.add(audit);
                }
            }

            if(listAuditUpdateOP.size()!=0)
                update listAuditUpdateOP;
        }      
    }
}