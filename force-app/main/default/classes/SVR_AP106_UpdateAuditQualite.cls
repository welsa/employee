/*************************************************************************************
Class Name - SVR_AP106_UpdateAuditQualite
Version - 1.0
Created Date - 12/08/2021


Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Hansraj M     29-07-2021  RSIW : 10584
*************************************************************************************/

public class SVR_AP106_UpdateAuditQualite {
    
    public static void getDossiers(set<Id> setAudits){
        Map<Id, List<SVR_Dossier__c>> mapDossiers = new Map<Id,List<SVR_Dossier__c>>();
        if (setAudits.size() > 0){

            String recordTypeDossier = Schema.SObjectType.SVR_Dossier__c.getRecordTypeInfosByDeveloperName()
            .get('SVR_Dossier').getRecordTypeId();

            String recordTypeAudit = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName()
            .get('SVR_ReseauQualite').getRecordTypeId();

            for (SVR_AuditReseau__c audit : [SELECT Id, SVR_RRD_NbOui__c,
                                            SVR_RRD_NbNon__c,
                                            SVR_RRD_pourcentageOui__c,
                                            SVR_RRD_PourcentageNon__c,
                                            
                                            SVR_SAD_NbOui__c,
                                            SVR_SAD_NbNon__c,
                                            SVR_SAD_pourcentageOui__c,
                                            SVR_SAD_pourcentageNon__c,
                                            
                                            
                                            SVR_Facturation_NbOui__c,
                                            SVR_Facturation_NbNon__c,
                                            SVR_Facturation_pourcentageOui__c,
                                            SVR_Facturation_pourcentageNon__c,

                                            (select Id , SVR_OrdreDeReparationSigne__c,
                                            //SVR_ExplicationTravauxAssure__c,
                                            SVR_CompletudeDuBonVRAller__c,
                                            SVR_PhotosLaRestitutionVR__c,
                                            SVR_SADPhotosLaRestitutionVR__c,
                                            SVR_MiseDispositionVRDebutDesTravaux__c,
                                            SVR_ProcesVerbalDeRestitution__c,
                                            SVR_PhotosLaRestitutionVhAssure__c,
                                            SVR_CompletudeDuBonVRRetour__c,
                                            SVR_SADRealiseLieuLheurePrevuAller__c,
                                            SVR_SADProcesVerbalDeRestitution__c,
                                            SVR_SADRestitutionConforme__c,
                                            SVR_SADPhotosLaRestitutionVhAssure__c,
                                            SVR_ExplicationTravauxAssure__c,
                                            SVR_RespectDesAccordsTarifairesNegocies__c,
                                            SVR_TransmissionFactureClient__c,
                                            SVR_PresentationsDejustificatifsDachats__c,
                                            SVR_ReceptionRapporDefinitifExpert__c,
                                            SVR_ConformeDerniersChiffrageDeLexpert__c,
                                            SVR_FactDesPiecesAchteesConforEurope__c,
                                            SVR_SADScriptExplicationTravauxLassure__c ,
                                            SVR_SADCompletudeBonAller__c ,
                                            SVR_SADCompletudeBonRetour__c ,
                                            SVR_SADCompletudeBonVRAller__c ,
                                            SVR_SADCompletudeBonVRRetour__c ,
                                            SVR_SADResumeEtapesReparation__c ,
                                            SVR_AuditRS__c FROM Dossiers__r WHERE RecordTypeId =: recordTypeDossier) 
                                            FROM SVR_AuditReseau__c WHERE RecordTypeId =: recordTypeAudit AND Id IN : setAudits]){
                                            
                                                mapDossiers.put(audit.Id, audit.Dossiers__r);

                                            }
        }

        if (mapDossiers != null && mapDossiers.size()> 0){
            List<SVR_AuditReseau__c> toUpdate = new List<SVR_AuditReseau__c>();
            System.debug('££££ mapDossiers '+ mapDossiers);
            toUpdate = calculateNums(mapDossiers);

            System.debug('££££ toUpdate '+ toUpdate);

            if (toUpdate.size() > 0){
                try{
                    System.debug('£££ £into update ');
                    update toUpdate;
                }
                catch(Exception e){
                    System.debug('Error : '+ e.getMessage());
                }
            }
        }
    }

    public static List<SVR_AuditReseau__c> calculateNums(Map<Id,List<SVR_Dossier__c>> mapDossier){
        List<SVR_Dossier__c> lstDossiers;
        List<SVR_AuditReseau__c> lstAuditToUpdate = new List<SVR_AuditReseau__c>();
        String[] arrReparation; String[] arrFacturation; String[] arrSad;
        Map<String, Decimal> mapRep;
        Map<String, Decimal> mapSad;
        Map<String, Decimal> mapFac;
        Decimal totalRepOui = 0;
        Decimal totalRepNon = 0;  
        Decimal totalSadOui = 0;
        Decimal totalSadNon = 0; 
        Decimal totalFacOui = 0;
        Decimal totalFacNon = 0;

        Map<String, Object> mapAudit;

        if (mapDossier.size() > 0){
            for (Id auditId : mapDossier.keySet()){
                lstDossiers = mapDossier.get(auditId);

                if (lstDossiers.size() > 0){
                    for (SVR_Dossier__c dossier : lstDossiers){
                        arrReparation = new String[]{dossier.SVR_OrdreDeReparationSigne__c, 
                                                    dossier.SVR_CompletudeDuBonVRAller__c,
                                                    dossier.SVR_CompletudeDuBonVRRetour__c,
                                                    dossier.SVR_PhotosLaRestitutionVR__c,
                                                    dossier.SVR_MiseDispositionVRDebutDesTravaux__c,
                                                    dossier.SVR_ProcesVerbalDeRestitution__c,
                                                    dossier.SVR_ExplicationTravauxAssure__c,
                        dossier.SVR_PhotosLaRestitutionVhAssure__c
                        };


                        arrSad = new String[]{dossier.SVR_SADRealiseLieuLheurePrevuAller__c,
                                            dossier.SVR_SADRestitutionConforme__c,
                                            dossier.SVR_SADCompletudeBonAller__c,
                                            dossier.SVR_SADCompletudeBonRetour__c,
                                            dossier.SVR_SADCompletudeBonVRAller__c,
                                            dossier.SVR_SADCompletudeBonVRRetour__c,
                                            dossier.SVR_SADProcesVerbalDeRestitution__c,
                                            dossier.SVR_SADResumeEtapesReparation__c,
                                            dossier.SVR_SADPhotosLaRestitutionVhAssure__c,
                                            dossier.SVR_SADPhotosLaRestitutionVR__c,
                                            dossier.SVR_SADScriptExplicationTravauxLassure__c
                                            // dossier.SVR_SADCompletudeBonVRAller__c,
                                            
                                            
                                            };


                        arrFacturation = new String[]{dossier.SVR_RespectDesAccordsTarifairesNegocies__c,
                                                    dossier.SVR_TransmissionFactureClient__c,
                                                    dossier.SVR_PresentationsDejustificatifsDachats__c,
                                                    dossier.SVR_ReceptionRapporDefinitifExpert__c,
                                                    dossier.SVR_ConformeDerniersChiffrageDeLexpert__c,
                                                    dossier.SVR_FactDesPiecesAchteesConforEurope__c};
                        
                        System.debug('££££ arrFacturation '+ arrFacturation.size());
                        System.debug('££££ arrSad '+ arrSad.size());
                        System.debug('££££ arrReparation '+ arrReparation.size());
                        
                        System.debug('££££ arrReparation '+ arrReparation);
                        System.debug('££££ arrFacturation '+ arrFacturation);
                        System.debug('££££ arrSad '+ arrSad);


                                          
                        mapRep = checkYes(arrReparation);
                        mapFac = checkYes(arrFacturation);
                        mapSad = checkYes(arrSad);
                            
                        System.debug('££££ mapRep '+ mapRep);
                        System.debug('££££ mapSad '+ mapSad);
                        System.debug('££££ mapFacturationn '+ mapFac);

                        if (mapRep != null && mapRep.size() > 0){
                            totalRepOui += mapRep.get('Oui');
                            totalRepNon += mapRep.get('Non');
                        }


                        if (mapSad != null && mapSad.size() > 0){
                            totalSadOui += mapSad.get('Oui');
                            totalSadNon += mapSad.get('Non');
                        }

                        if (mapFac != null && mapFac.size() > 0){
                         totalFacOui += mapFac.get('Oui');
                         totalFacNon += mapFac.get('Non');
                        }
                    }

                }

                System.debug('££££ totalRepOui '+ totalRepOui);
                System.debug('££££ totalRepNon '+ totalRepNon);

                System.debug('££££ totalSadOui '+ totalSadOui);
                System.debug('££££ totalSadNon '+ totalSadNon);

                System.debug('££££ totalFacOui '+ totalFacOui);
                System.debug('££££ totalFacNon '+ totalFacNon);

                
                System.debug('££££ (arrReparation.size()* lstDossiers.size()) '+ (arrReparation.size()* lstDossiers.size()));
   

                System.debug('££££ (arrSad.size()* lstDossiers.size()) '+ (arrSad.size()* lstDossiers.size()));

                
                System.debug('££££ totalFacOui '+ (arrFacturation.size()* lstDossiers.size()));

                SVR_AuditReseau__c auditReseau = new SVR_AuditReseau__c(Id = auditId);

                auditReseau.SVR_RRD_NbOui__c = totalRepOui;
                auditReseau.SVR_RRD_NbNon__c = totalRepNon;
              

                auditReseau.SVR_RRD_pourcentageOui__c =  (totalRepOui/(arrReparation.size()* lstDossiers.size())) * 100;
                auditReseau.SVR_RRD_PourcentageNon__c =(totalRepNon/(arrReparation.size()* lstDossiers.size())) * 100;
        
                
                auditReseau.SVR_SAD_NbOui__c = totalSadOui;
                auditReseau.SVR_SAD_NbNon__c = totalSadNon;
                auditReseau.SVR_SAD_pourcentageOui__c =  (totalSadOui/(arrSad.size()* lstDossiers.size())) * 100;
                auditReseau.SVR_SAD_pourcentageNon__c =  (totalSadNon/(arrSad.size()* lstDossiers.size())) * 100;
            
                
                auditReseau.SVR_Facturation_NbOui__c = totalFacOui;
                auditReseau.SVR_Facturation_NbNon__c = totalFacNon;
                auditReseau.SVR_Facturation_pourcentageOui__c = (totalFacOui/(arrFacturation.size()* lstDossiers.size())) * 100;
                auditReseau.SVR_Facturation_pourcentageNon__c = (totalFacNon/(arrFacturation.size()* lstDossiers.size())) * 100;

                System.debug('££££ auditttttt '+ auditReseau);
                lstAuditToUpdate.add(auditReseau);
            }

        }

        return lstAuditToUpdate;
    }

    public static Map<String, Decimal> checkYes(String[] fields){
        Decimal oui = 0;
        Decimal non = 0;

        for (String value : fields ){
            if (value == 'Oui' || value == '5'){
                oui += 1;
            }

            if (value == 'Non' || value == '0'){
                non+=1;
            }
        }

        return new Map<String, Decimal>{'Oui' => oui, 'Non' => non};
    }
    //RLA 13/08/2021 RSIW 10577
    public static void searchContactDirigeant(List<SVR_AuditReseau__c> listAuditQltToUpdateContact){

        map<Id,Id> mapAuditBS = new map<Id,Id>();
        map<Id,set<Id>> mapBSSetAudits = new map<Id,set<Id>>();
        map<Id,SVR_AuditReseau__c> mapAllAudit = new map<Id,SVR_AuditReseau__c>();
        map<Id,Contact> mapBSEmailDirigeant = new map<Id,Contact>();
        map<Id,SVR_AuditReseau__c> mapAuditWithEmailDiToUpdate = new map<Id, SVR_AuditReseau__c>();

        List<String> emailTemplateDevNamesList = (String.isNotBlank(Label.SVRSendEmailCloture)) ? Label.SVRSendEmailCloture.split(';') : new List<String>();

        EmailTemplate emailTemplate =new EmailTemplate();

        List<Messaging.SendEmailResult> emailResultList;

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNamesList])
        {
           emailTemplate = currentEmailTemplate;
        }
        
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();



       if (true){
            for (SVR_AuditReseau__c AR: listAuditQltToUpdateContact){
                mapAuditBS.put(AR.Id, AR.SVR_Bodyshop__c);
                mapAllAudit.put(AR.Id, AR);
                
                if (mapBSSetAudits.containsKey(AR.SVR_Bodyshop__c)){
                    mapBSSetAudits.get(AR.SVR_Bodyshop__c).add(AR.Id);

                }
                else{
                    mapBSSetAudits.put(AR.SVR_Bodyshop__c, new set<Id>{AR.Id});
                }
            }
            for (Contact contact: [select id,NOB_FunctionServices__c,AccountId, Email from contact where AccountId IN :mapAuditBS.values() and NOB_FunctionServices__c includes ('Dirigeant') and Email != null]){
                mapBSEmailDirigeant.put(contact.AccountId, contact);
            }
            System.debug('££££ mapBSEmailDirigeant '+ mapBSEmailDirigeant);

            for (Id bsId: mapBSEmailDirigeant.keyset()){

                for (Id auditId:mapBSSetAudits.get(bsId) ){

                    List<String> toAddressList = new list<string>();
                    toAddressList.add(mapBSEmailDirigeant.get(bsId).Email);
                    //HMO -- 08-09-2021
                    toAddressList.add('suivi.contractuel@prefikar.com');
                    //
                    SVR_AuditReseau__c audit = mapAllAudit.get(auditId);
                    // mapAuditWithEmailDiToUpdate.put(audit.Id, audit);

                    Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null ,audit.Id);
                    // currentEmail.setTemplateID(emailTemplate.Id); 
                    // message.setWhatId(audit.Id);
                    currentEmail.toAddresses = (toAddressList);
                    currentEmail.setSubject(currentEmail.getSubject());
                    currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                    currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                    emailListToSend.add(currentEmail);

                }

            }
            System.debug('££££ emailListToSend '+ emailListToSend);

            if(emailListToSend.size() > 0)
            {
                emailResultList = Messaging.sendEmail(emailListToSend);
            }
        }
        
        System.debug('££££ mapBSSetAudits '+ mapBSSetAudits);

        
        // System.debug('££££ mapAuditWithEmailDiToUpdate '+ mapAuditWithEmailDiToUpdate);

        // if (mapAuditWithEmailDiToUpdate.size() >0){
        //     update mapAuditWithEmailDiToUpdate.values();
        // }

    }
}