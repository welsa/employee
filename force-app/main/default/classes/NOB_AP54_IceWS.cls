/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 05-03-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-26-2020   ARA      RSIW-4182
 * 1.1   05-07-2021   LMU      RSIW-9663
 * 1.2   10-06-2021   GBH      RSIW-9793	WorkOrder on Darva MSG Log
 * 1.3   24-01-2022   SRA      RSIW 11242	replace field NOB_ClientId__c by NumeroClient__c
**/
public with sharing class NOB_AP54_IceWS {

    @future(callout=true)
    public static void doSendMessage(Id logId){
        System.debug('Sending Message ICE:' + logId);
        NOB_DarvaMessageLog__c log = [SELECT Id,NOB_JsonResponse__c, NOB_MessageSubType__c, NOB_Case__c, NOB_MessageType__c, NOB_JsonRequest__c, NOB_Status__c, Tech_TaskID__c FROM NOB_DarvaMessageLog__c WHERE Id =: logId];
        //GBH   10-06-2021      RSIW-9793	WorkOrder on Darva MSG Log
        List<Case> c = [SELECT id, NOB_lastMission__c, PFR_ActiveWorkOrder__c FROM Case WHERE id = :log.NOB_Case__c];
 
        if (c != null && c.size()>0 ) {
            if(c[0].NOB_lastMission__c == null){
                List<WorkOrder> wo = [SELECT Id, CaseId, LastModifiedDate FROM WorkOrder WHERE CaseId = :c[0].Id ORDER BY LastModifiedDate DESC LIMIT 1];
                if (wo != null && wo.size()>0) { 
                    log.Nob_WorkOrder__c  = wo[0].Id;
                }
            } else {
                log.Nob_WorkOrder__c  = c[0].NOB_lastMission__c;
            }
        }
        ///////////////////
        try{
            
            System.debug('LOGDATA:' + log);
            Id requestId = log.NOB_Case__c;
            String messageType = log.NOB_MessageType__c;
            Map<String,Object> req = new Map<String, Object>();

            HttpRequest request = new HttpRequest();
            
            /**build connection**/

            PFR_WsCredential__c cred = PFR_WsCredential__c.getInstance('ICE');
            String endpoint = cred.NOB_Endpoint__c;
            String clientId = cred.NOB_ClientId__c;
            String clientSecret = cred.NOB_ClientSecret__c;
            
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', clientId);
            request.setHeader('client_secret', clientSecret);
            // req = buildRequest_ICE(log);

            /**build request**/
            req = buildRequest_ICE(log);
            
            if(log.NOB_MessageSubType__c  == 'setMission'){
                request.setMethod('POST');
                String body = JSON.serialize(req); 
            	System.debug('Body:' + body);
            	log.NOB_JsonRequest__c = body;
            	request.setBody(body);
            }
            else {
                String idFournisseur = (String)req.get('cch_id_fournisseur');
                
                if(idFournisseur != null && idFournisseur.trim() != ''){
                	endpoint = endpoint + '/' + req.get('cch_id_fournisseur') + '/claims/' + req.get('enterprise_id');
                	request.setMethod('DELETE');
                }else{
                    throw new AuraException('Le champ cch_id_fournisseur est vide pour le reparateur ' + req.get('info_reparateur'));
                }
            }
            System.debug('Endpoint:' + endpoint);
            request.setEndpoint(endpoint);
            request.settimeout(120000);
            Http http = new Http();
            HttpResponse response = http.send(request);
            Map<String,String> success = new Map<String,String>();
            String result = response.getBody();
            System.debug('Response:::' + result);
            if(result.indexOf('ERROR') > 0){ // LMU looking pour upper case instead of lower case RSIW-9663
                success.put('status', 'error');    
                log.NOB_Status__c = 'Error';
            }else{
                success.put('status', 'success');
                log.NOB_Status__c = 'Sent';
            }
            success.put('message', result);
            
            log.NOB_JsonResponse__c  = JSON.serialize(success);
            System.debug('log:'+ log);
        }catch(Exception e){
            Map<String,String> error = new Map<String,String>();
            error.put('error', e.getStackTraceString() +';' +  e.getMessage());
            error.put('status', 'error');
            log.NOB_JsonResponse__c = JSON.serialize(error); 
            log.NOB_Status__c = 'Error';
        }
        update log;
        // return response;
        
    }

    public static Map<String,Object> buildRequest_ICE( NOB_DarvaMessageLog__c darvaLog){
        System.debug('## start of buildRequest_ICE ##');
        Case ca = [SELECT Id,
                   NOB_BodyShop__c,
                   NOB_ExternalId__c,
                   CreatedBy.Name,
                   NOB_BodyShop__r.NumeroClient__c,
                   NOB_BodyShop__r.Name,
                   NOB_InsurerClaimNumber__c,
                   NOB_IncidentDateandTime__c,
                   tolabel(NOB_NatureOfTheEvent__c) NOB_NatureOfTheEvent__c,
                   NOB_Franchise__c,
                   NOB_VariableMax__c,
                   NOB_VariableMin__c,
                   NOB_Variable__c, 
                   NOB_notRunningVehicle__c,
                   NOB_CourtesyCarNeedeForInsurer__c,
                   NOB_VehicleRegistrationNumber__c,
                   tolabel(NOB_VehicleBrand__c) NOB_VehicleBrand__c,
                   NOB_VehicleModel__c,
                   NOB_Pricebook__r.Name,
                   Contact.MailingStreet,Contact.MailingPostalCode, Contact.MailingCity,Contact.MailingCountryCode,Contact.OtherCity,
                   Contact.MobilePhone,Contact.Phone,Contact.OtherPhone,
                   Contact.FirstName,Contact.LastName,
                   NOB_TECH_DispoId__r.NOB_StartDate__c,
                   NOB_BodyShop__r.NOB_ExternalId__c,
                   Expert__r.Name,
                   Expert__r.Phone,
                   NOB_BusinessProvider__r.Name,
                   NOB_Tech_BS_ClientId__c
                   FROM Case WHERE Id=:darvaLog.NOB_Case__c
                   
                  ];
        
        
        
        Map<String,Object> mapCase = new Map<String,Object>();
        Account bodyshop = ca.NOB_BodyShop__r;
        if(ca.NOB_BodyShop__c == null){
            List<WorkOrder> wos = [SELECT Id, CaseId, NOB_Reparateur__c, NOB_Reparateur__r.NumeroClient__c FROM WorkOrder ORDER BY CreatedDate DESC LIMIT 1];
            if(wos.size() > 0){
                bodyshop = wos.get(0).NOB_Reparateur__r;
            }
        }
        String BSClientId = ca.NOB_Tech_BS_ClientId__c;//WCH 03/05/21 RSIW-9589
        system.debug('BSClientId>>'+BSClientId);
        if(bodyshop != null || String.isNotBlank(BSClientId))
        	mapCase.put('cch_id_fournisseur', (String.isNotBlank(BSClientId)? BSClientId : NOBTools.checkNull(bodyshop.NumeroClient__c)));//WCH 03/05/21 RSIW-9589
        else
            mapCase.put('cch_id_fournisseur', '');
        
        
        String createdBy = ca.CreatedBy.Name;
        
        String dataMigration = Label.NOB_UserMigration;
        
        if(dataMigration.equalsIgnoreCase(createdBy)){
            if(ca.NOB_ExternalId__c == null || ca.NOB_ExternalId__c == ''){
              mapCase.put('enterprise_id', NOBTools.checkNull(ca.Id));
            }else{
            	mapCase.put('enterprise_id', NOBTools.checkNull(ca.NOB_ExternalId__c));
            }
        }else{
        	mapCase.put('enterprise_id', NOBTools.checkNull(ca.Id));
        }
        // string mis_raison = (darvaLOg.NOB_MessageSubType__c  == 'setMission') ? null : NOB_AP00_Constants.PLANNING_STATUS_ANNULE;
        // mapCase.put('mis_raison',mis_raison);
        // string mis_statut = (darvaLOg.NOB_MessageSubType__c  == 'setMission') ? null : NOB_AP00_Constants.PLANNING_STATUS_ANNULE;
        // mapCase.put('mis_statut', mis_statut);
        
        if(darvaLog.NOB_MessageSubType__c  == 'setMission'){
            
            mapCase.put('cli_adresse', NOBTools.checkNull(ca.Contact.MailingStreet));
            mapCase.put('cli_code_postal', NOBTools.checkNull( ca.Contact.MailingPostalCode));
            mapCase.put('cli_gsm', NOBTools.checkNull(ca.Contact.Phone));
            mapCase.put('cli_nom', NOBTools.checkNull(ca.Contact.LastName));      
            mapCase.put('cli_pay', NOBTools.checkNull(ca.Contact.MailingCountryCode));
            mapCase.put('cli_prenom', NOBTools.checkNull(ca.Contact.FirstName));
            mapCase.put('cli_tel', NOBTools.checkNull(ca.Contact.MobilePhone));
            mapCase.put('cli_tel1', NOBTools.checkNull(ca.Contact.OtherPhone));
            mapCase.put('cli_ville', NOBTools.checkNull(ca.Contact.MailingCity));
            mapCase.put('cli_ville2', NOBTools.checkNull(ca.Contact.OtherCity));
            mapCase.put('exp_cabinet', NOBTools.checkNull(ca.Expert__r.Name));
            mapCase.put('exp_tel', NOBTools.checkNull(ca.Expert__r.Phone));
            mapCase.put('mis_dt_sinistre', NOBTools.checkNull(ca.NOB_IncidentDateandTime__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE));
            mapCase.put('mis_emetteur', NOBTools.checkNull(ca.NOB_BusinessProvider__r.Name));
            mapCase.put('mis_num_sinistre', NOBTools.checkNull(ca.NOB_InsurerClaimNumber__c));
            mapCase.put('orr_cause',NOBTools.checkNull(ca.NOB_NatureOfTheEvent__c));
            Decimal franchise = (ca.NOB_Franchise__c == null) ? 0 : ca.NOB_Franchise__c ;
            mapCase.put('orr_franchise_fixe', franchise);
            Decimal variableMax = (ca.NOB_VariableMax__c == null) ? 0 : ca.NOB_VariableMax__c ;
            mapCase.put('orr_franchise_max', variableMax);
            Decimal variableMin = (ca.NOB_VariableMin__c == null) ? 0 : ca.NOB_VariableMin__c ;
            mapCase.put('orr_franchise_min', variableMin);
            Decimal variable = (ca.NOB_Variable__c == null) ? 0 : ca.NOB_Variable__c ;
            mapCase.put('orr_franchise_variable', variable);

            Integer runningVehicle = (ca.NOB_notRunningVehicle__c == true) ? 0 : 1;
            mapCase.put('orr_roulant', runningVehicle);

            mapCase.put('orr_vrp_id', ca.NOB_CourtesyCarNeedeForInsurer__c);
            mapCase.put('voi_immat', NOBTools.checkNull(ca.NOB_VehicleRegistrationNumber__c));
            mapCase.put('voi_marque', NOBTools.checkNull(ca.NOB_VehicleBrand__c));
            mapCase.put('voi_modele', NOBTools.checkNull(ca.NOB_VehicleModel__c));
            if(ca.NOB_TECH_DispoId__r != null && ca.NOB_TECH_DispoId__r.NOB_StartDate__c != null){
            	//mapCase.put('vrp_date_debut', NOBTools.checkNull(ca.NOB_TECH_DispoId__r.NOB_StartDate__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE));
            	mapCase.put('vrp_date_debut', ca.NOB_TECH_DispoId__r.NOB_StartDate__c);
            }else{
                List<NOB_Planning__c> plannings =  [SELECT Id, NOB_StartDate__c, NOB_Status__c, CreatedDate FROM NOB_Planning__c WHERE NOB_WorkOrder__r.CaseId =: ca.Id ORDER BY CreatedDate DESC];
                //system.debug('buildRequest_ICE - NOB_StartDate__c:'+plannings.get(0).NOB_StartDate__c+', CreatedDate:'+plannings.get(0).CreatedDate);
                if(plannings.size() > 0){
                    NOB_Planning__c planning = plannings.get(0);
                    system.debug('buildRequest_ICE - planning.NOB_StartDate__c:'+planning.NOB_StartDate__c+', NOBTools.checkNull(NOB_StartDate__c):'+NOBTools.checkNull(planning.NOB_StartDate__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE));
                    //mapCase.put('vrp_date_debut', NOBTools.checkNull(planning.NOB_StartDate__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE));
                	mapCase.put('vrp_date_debut', planning.NOB_StartDate__c);
                }	
            }
            mapCase.put('vrp_mode_transfert', NOBTools.checkNull(ca.NOB_Pricebook__r.Name));

        }
        else{
            mapCase.put('mis_raison', NOB_AP00_Constants.PLANNING_STATUS_ANNULE);
            mapCase.put('mis_statut', NOB_AP00_Constants.PLANNING_STATUS_ANNULE);
            mapCase.put('info_reparateur', ca.NOB_BodyShop__r.Name + ';'+ ca.NOB_BodyShop__c);
        }

        System.debug('## End of buildRequest_ICE ##');
        
        return mapCase;
        
    }
}