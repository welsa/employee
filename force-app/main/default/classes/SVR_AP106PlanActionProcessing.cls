public class SVR_AP106PlanActionProcessing {
    /*************************************************************************************
Class Name - SVR_AP106PlanActionProcessing
Version - 1.0
Created Date - 10 June 2021
Function - class to initalise Plan actin

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L        15/10/2020  RSIW-9913: Original Version
* Hansraj M        17-09-2021  RSIW - 10478

*************************************************************************************/


    public static void initialiseThePA (map<Id, Audit_Plan_Action__c> mapPACM){

        System.debug('>> SVR_AP106PlanActionProcessing starts');


        map<Id, List<Audit_Plan_Action__c>> mapGarageLstPA = new map<Id, List<Audit_Plan_Action__c>>();
        map<Id, Audit_Plan_Action__c> mapPAToUpdate = new map<Id, Audit_Plan_Action__c>();
        map<Id, SVR_AuditReseau__c> mapPAIdLatestAuditReseau = new map<Id, SVR_AuditReseau__c>(); 
        

        for (Audit_Plan_Action__c PA: [Select id,SVR_AuditReseau__r.SVR_Bodyshop__c From Audit_Plan_Action__c 
                                                where Id IN: mapPACM.keyset() ]){

            if (mapGarageLstPA.containsKey(PA.SVR_AuditReseau__r.SVR_Bodyshop__c)){
                mapGarageLstPA.get(PA.SVR_AuditReseau__r.SVR_Bodyshop__c).add(PA);
            }
            else{
                mapGarageLstPA.put(PA.SVR_AuditReseau__r.SVR_Bodyshop__c, new list<Audit_Plan_Action__c>{PA});
            }

        }

        system.debug('@@@ mapGarageLstPA'+mapGarageLstPA);

        for (SVR_Performance__c perf: [select Id,SVR_NomGarage__c,SVR_MOBC__c,SVR_TrancheA_pourcentageMO__c,SVR_TrancheB_pourcentageMO__c,
                                                SVR_TrancheC_pourcentageMO__c,SVR_TrancheE_pourcentageMO__c,SVR_ASFSubstitutionA__c,
                                                SVR_ASFSubstitutionB__c,SVR_ASFSubstitutionC__c,SVR_ASFSubstitutionE__c,SVR_CMTrancheA__c,
                                                SVR_CMTrancheB__c,SVR_CMTrancheC__c,SVR_CMTrancheD__c,SVR_CMTrancheE__c
                                        From SVR_Performance__c                                            
                                        Where recordType.DeveloperName =: SVR_AP100_Constant.recordTypePerfReseauCM
                                                And SVR_NomGarage__c in: mapGarageLstPA.keyset()
                                                And SVR_Periode__c = '3MG'
                                                ORDER BY CreatedDate DESC NULLS FIRST]){
            system.debug('@@@ perf'+perf.SVR_NomGarage__c);
            
            if (mapGarageLstPA.containsKey(perf.SVR_NomGarage__c)) {
                
                system.debug('@@@ garage contains');

                for (Audit_Plan_Action__c PAToUpdateWithPerf:mapGarageLstPA.get(perf.SVR_NomGarage__c) ){

                    decimal TA = 0.0;                    

                    if (perf.SVR_ASFSubstitutionA__c != null){
                        TA = TA + perf.SVR_ASFSubstitutionA__c;
                    }
                    if (perf.SVR_ASFSubstitutionB__c != null){
                        TA = TA + perf.SVR_ASFSubstitutionB__c;
                    }
                    if (perf.SVR_ASFSubstitutionC__c != null){
                        TA = TA + perf.SVR_ASFSubstitutionC__c;
                    }
                    if (perf.SVR_ASFSubstitutionE__c != null){
                        TA = TA + perf.SVR_ASFSubstitutionE__c;
                    }

                    
                    system.debug('@@@ TA: '+TA);

                    // if (TA != null && TA != 0.0){
                    //     TA =TA/100;
                    // }

                    decimal CM = 0.0;                    

                    if (perf.SVR_CMTrancheA__c != null){
                        CM = CM + perf.SVR_CMTrancheA__c;
                    }
                    if (perf.SVR_CMTrancheB__c != null){
                        CM = CM + perf.SVR_CMTrancheB__c;
                    }
                    if (perf.SVR_CMTrancheC__c != null){
                        CM = CM + perf.SVR_CMTrancheC__c;
                    }
                    if (perf.SVR_CMTrancheD__c != null){
                        CM = CM + perf.SVR_CMTrancheD__c;
                    }
                    if (perf.SVR_CMTrancheE__c != null){
                        CM = CM + perf.SVR_CMTrancheE__c;
                    }

                    if (CM > 0){
                        CM = CM * 100;
                    }

                    
                    system.debug('@@@ CM: '+CM);
                    // system.debug('@@@ CM: '+perf.SVR_CMGlobal__c);

                    
                   
                    mapPAToUpdate.put(PAToUpdateWithPerf.Id, new Audit_Plan_Action__c(Id = PAToUpdateWithPerf.Id,  
                                                                                    SVR_Performance__c = perf.Id,
                                                                                    SVR_MOCMTranchesBC1__c = perf.SVR_MOBC__c,
                                                                                    SVR_UtilisationSubstitutionA1__c = perf.SVR_TrancheA_pourcentageMO__c,
                                                                                    SVR_UtilisationSubstitutionB1__c = perf.SVR_TrancheB_pourcentageMO__c,
                                                                                    SVR_UtilisationSubstitutionC1__c = perf.SVR_TrancheC_pourcentageMO__c,
                                                                                    SVR_UtilisationSubstitutionE1__c = perf.SVR_TrancheE_pourcentageMO__c,
                                                                                    SVR_UtilistionASFTauxCommande1__c = TA ,

                                                                                    SVR_CMGlobal1__c = CM
                                                                                ));                    
                }

            }                                           

        }

        system.debug('@@@ mapPAToUpdate with perf'+mapPAToUpdate);

        set<Id> setAuditsAlreadyTreated = new set<Id>();

        for (SVR_AuditReseau__c  auditReseau: [SELECT Id,Name,Nb_de_plan_d_action__c,SVR_Bodyshop__r.name, createdDate, (select name, createdDate from Plans_action_reseau__r where Id NOT IN: mapPACM.keyset() ORDER BY CreatedDate DESC NULLS LAST limit 1)  FROM SVR_AuditReseau__c WHERE SVR_Bodyshop__c in :mapGarageLstPA.keyset() AND RecordType.DeveloperName =: SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen and Nb_de_plan_d_action__c >= 1 ORDER BY CreatedDate ASC NULLS FIRST]){
            
            system.debug('@@@ auditReseau'+auditReseau);


            if (mapGarageLstPA.containsKey(auditReseau.SVR_Bodyshop__c) && !setAuditsAlreadyTreated.contains(auditReseau.Id) && auditReseau.Plans_action_reseau__r.size() > 0) {

                for (Audit_Plan_Action__c PAWithLatestAudit:mapGarageLstPA.get(auditReseau.SVR_Bodyshop__c) ){
                    
                    system.debug('@@@ PAWithLatestAudit'+PAWithLatestAudit);


                    if (mapPAToUpdate.containsKey(PAWithLatestAudit.Id)){
                        mapPAToUpdate.get(PAWithLatestAudit.Id).Latest_Plan_d_actions__c = auditReseau.Plans_action_reseau__r[0].Id;
                    }
                    else{
                        mapPAToUpdate.put(PAWithLatestAudit.Id, new Audit_Plan_Action__c(Id = PAWithLatestAudit.Id,  Latest_Plan_d_actions__c = auditReseau.Plans_action_reseau__r[0].Id));
                    }


                }
                setAuditsAlreadyTreated.add(auditReseau.Id);
                system.debug('@@@ setAuditsAlreadyTreated'+setAuditsAlreadyTreated);


            }


        }
        system.debug('@@@ mapPAToUpdate with dernier TA'+mapPAToUpdate);

        if (mapPAToUpdate.size() > 0){
            update mapPAToUpdate.values();
        }

        System.debug('>> SVR_AP106PlanActionProcessing ENDS');




        
// SVR_NomGarage__c = {!$Record.SVR_AuditReseau__r.SVR_Bodyshop__r.Id}

    }

    //HMO -- 17-08-2021 -- RSIW-10743
    public static void sendEmailRepairer(List <Audit_Plan_Action__c> lstNewPlanAction){
        map<Id,String> mapPlanAuditBS = new map<Id,String>();
        if (lstNewPlanAction.size() > 0){
          
            List<String> emailTemplateDevNamesList = (String.isNotBlank(Label.SVRSendEmailPlanDaction)) ? Label.SVRSendEmailPlanDaction.split(';') : new List<String>();
            EmailTemplate emailTemplate =new EmailTemplate();
            List<Messaging.SendEmailResult> emailResultList = new List<Messaging.SendEmailResult>();

            for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                        FROM    EmailTemplate
                                                        WHERE   DeveloperName IN: emailTemplateDevNamesList])
            {
            emailTemplate = currentEmailTemplate;
            }
            
            List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
            
            for (Audit_Plan_Action__c pa : [select Id, SVR_AuditReseau__r.SVR_RepairerUser__r.email from Audit_Plan_Action__c where id IN :lstNewPlanAction]){

                mapPlanAuditBS.put(pa.Id, pa.SVR_AuditReseau__r.SVR_RepairerUser__r.email);
            }
            System.debug('££££ mapPlan '+ mapPlanAuditBS);

            if (mapPlanAuditBS != null && mapPlanAuditBS.size() > 0){
                for (Id paId : mapPlanAuditBS.keySet()){
                    List<String> toAddressList = new list<string>();
                    toAddressList.add(mapPlanAuditBS.get(paId));

                    Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null ,paId);

                    currentEmail.toAddresses = (toAddressList);
                    currentEmail.setSubject(currentEmail.getSubject());
                    currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                    currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                    emailListToSend.add(currentEmail);
                }

                if(emailListToSend.size() > 0)
                {
                    System.debug('email to send '+ emailListToSend);
                    emailResultList = Messaging.sendEmail(emailListToSend);
                }
            }

        }
    }
}