/**
* @description       : callout to Genesys
* @author            : USA
* @group             :
* @last modified on  : 06-25-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log
* Ver   Date         Author   Modification
* 1.0   11-26-2020   USA      Initial Version (RSIW-3915)
* 1.1   01-12-2021   ASE      Initial Version (RSIW-7023)
* 1.2   19-01-2021   HMO      Initial version (RSIW-7613)
* 1.3   09-04-2021   KPA      RSIW-9198 
* 1.4   30-04-2021   KPA      RSIW-9445 Timeout
* 1.5   10-06-2021   GBH      RSIW-9793	WorkOrder on Darva MSG Log
* 1.6   16-06-2021   WCH      RSIW-9812	CTI : envoyer le numéro de sinistre dans les campagnes
* 1.7   25-06-2021   WCH      RSIW-10035 : Les contacts conducteurs ne sont pas envoyés dans les campagnes lorsqu'ils ont été intégrés avec l'AS
* 1.8   27-10-2021   WCH      RSIW-11141 : Clients contactés rappelés par l'automate des campagnes d'appels
**/
public with sharing class NOB_AP53_GenesysWS {
    @future(callout=true)
    public static void doSendMessage(Id logId){
        NOB_DarvaMessageLog__c log = [SELECT Id,NOB_JsonResponse__c, NOB_MessageSubType__c, NOB_Case__c, /*RSIW-7023*/NOB_Case__r.NOB_Integration__c, NOB_MessageType__c, NOB_JsonRequest__c, NOB_Status__c, Tech_TaskID__c FROM NOB_DarvaMessageLog__c WHERE Id =: logId];
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
        /*RSIW-7023*/
        //RSIW-7023 when callerSystem changes NOB_Integration__c  to Finalisé by WS OR when case is created by an agent, the NOB_Integration__c = null
        if(log.NOB_Case__r.NOB_Integration__c != 'Échec' ) {
            try {
                HttpRequest request = new HttpRequest();
                PFR_WsCredential__c cred = PFR_WsCredential__c.getInstance('Genesys'); 
                String endpoint = cred.NOB_Endpoint__c;
                String clientId = cred.NOB_ClientId__c;
                String clientSecret = cred.NOB_ClientSecret__c;
                request.setTimeout(120000); // KPA RSIW-9445
                String suffix = '';
                if (log.NOB_MessageSubType__c == 'UpdateTask'){
                    suffix = 'updateTask';
                }
                else if (log.NOB_MessageSubType__c == 'CreateTask'){
                    suffix = 'createTask';
                }
                
                
                // Blob headerValue = Blob.valueOf(clientId + ':' + clientSecret);
                //  Blob headerValue = Blob.valueOf('clt-prefikar-salesforce' + ':' + 'MLwn9!HK.CIL-92f-n\'f');
                // Base 64 Encode the blob and prepend "Basic "
                //  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                //System.debug(authorizationHeader);
                // Add the basic auth string to the Request Header
                //  request.setHeader('Authorization', authorizationHeader);
                
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Accept', 'application/json, text/plain, */*');
                if(!Test.isRunningTest()){
                    request.setClientCertificateName(clientId);
                }
                //request.setClientCertificateName('sfdc_int_prefikar_com');
                
                
                request.setEndpoint(endpoint + '/' + suffix);
                System.debug('Endpoint:' + endpoint);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                // request.setHeader('client_id', clientId);
                // request.setHeader('client_secret', clientSecret);
                
                System.debug('LOGDATA:' + log);
                Map<String, Object> req = new Map<String, Object>();
                
                req = buildRequest_Genesys(log);
                
                if (req.keyset().contains('ErrorContact')) {
                    
                    //Integer errContactId = (Integer)req.get('ErrorContact');
                    log.NOB_JsonResponse__c = System.Label.NOB_ErorContact;
                    //log.NOB_JsonResponse__c = 'Error contact';
                    log.NOB_Status__c = 'Error';
                    system.debug('##pch ContactId' + log.NOB_JsonResponse__c);
                }
                
                
                else if (req.keyset().contains('ErrorPhone')) {
                    //req.NOB_JsonResponse__c = JSON.serialize(error);
                    //Integer errContactPhone = (Integer)req.get('ErrorPhone');
                    //log.NOB_JsonResponse__c = 'Error Phone';
                    log.NOB_JsonResponse__c = System.Label.NOB_ErrorPhone;
                    //log.NOB_JsonResponse__c = 'Error Phone';
                    log.NOB_Status__c = 'Error';
                    system.debug('##pch ContactId' + log.NOB_JsonResponse__c);
                    
                } else {
                    String body = JSON.serialize(req);
                    System.debug('Body:' + body);
                    log.NOB_JsonRequest__c = body;
                    request.setBody(body);
                    Http http = new Http();
                    HttpResponse response = http.send(request);
                    Map<String, String> success = new Map<String, String>();
                    String result = response.getBody();
                    System.debug('Response:::' + result);
                    // if(result.contains(''))
                    if (result.toLowerCase().indexOf('error') > 0) {
                        success.put('status', 'error');
                        log.NOB_Status__c = 'Error';
                    } else {
                        success.put('status', 'success');
                        log.NOB_Status__c = 'Sent';
                    }
                    success.put('message', result);
                    
                    log.NOB_JsonResponse__c = JSON.serialize(success);
                    System.debug('log:' + log);
                }
                
            } catch (Exception e) {
                Map<String, String> error = new Map<String, String>();
                error.put('error', e.getStackTraceString() + ';' + e.getMessage());
                error.put('status', 'error');
                log.NOB_JsonResponse__c = JSON.serialize(error);
                log.NOB_Status__c = 'Error';
                //req = JSON.serialize(error);
            }
        }
        else{
            Map<String, String> error = new Map<String, String>();
            error.put('error', 'Le statut de l\'intégration est à Echec');
            error.put('status', 'error');
            log.NOB_JsonResponse__c = JSON.serialize(error);
            log.NOB_Status__c = 'Error';
        }
        update log;
        // return response;
        
    }
    
    /* private static void processResponse(String result, Map<String,String> success, NOB_DarvaMessageLog__c log){
try{
Map<String,Object> respon = (Map<String,Object>)JSON.deserializeUntyped(result);
if(respon.containsKey('status')){
String status = (String)respon.get('status');
if(status != null && status.toLowerCase().equals('sucess')){
success.put('status', 'success');
log.NOB_Status__c = 'Sent';
}else if(status == null || status.toLowerCase().contains('error')){
success.put('status', 'error');
log.NOB_Status__c = 'Error';
}

if(respon.containsKey('message')){

}
}
}catch(Exception e){

if(result.indexOf('error') > 0){
success.put('status', 'error');
log.NOB_Status__c = 'Error';
}else{
success.put('status', 'success');
log.NOB_Status__c = 'Sent';
}

}
}*/
    
    public static Map<String,Object> buildRequest_Genesys (NOB_DarvaMessageLog__c msgLog){
        system.debug('@@start build Genesys' +msgLog);
        Map<String,Object> mapTaskRequest = new Map<String,Object>();
        DateTime vpreferedendtime;
        String vPhoneNumToCallBack = '';
        
        List<Case> lstCases = [SELECT Id, PFR_CallPreferedStartTime__c, PFR_CallPreferedEndTime__c,
                               /* contactId, contact.LastName, contact.FirstName, contact.Phone,Contact.MobilePhone,Contact.OtherPhone,Contact.HomePhone,Contact.NOB_PhonePro__c, */
                               NOB_ContactPickup__c,NOB_ContactPickup__r.LastName,NOB_ContactPickup__r.FirstName, NOB_ContactPickup__r.Phone,NOB_ContactPickup__r.MobilePhone,NOB_ContactPickup__r.OtherPhone,NOB_ContactPickup__r.HomePhone,NOB_ContactPickup__r.NOB_PhonePro__c,
                               NOB_BusinessProvider__r.Nob_CTICampaignNumber__c, NOB_InsurerClaimNumber__c
                               FROM Case
                               WHERE Id = :msgLog.NOB_Case__c];
        
        List<Task> lstTasks = [SELECT Id, WhatId, PFR_CallStatus__c,PFR_CallPreferedStartTime__c,PFR_CallPreferedEndTime__c
                               FROM Task
                               WHERE Id = :msgLog.Tech_TaskID__c];
        
        if (lstCases.size() > 0 && lstTasks.size() > 0){
            Case caseCurrent = lstCases[0];
            Task taskCurrent = lstTasks[0];
            
            system.debug('##caseCurrent : ' + caseCurrent);
            /* system.debug('##NOB_ContactPickup__r.Phone : ' + NOB_ContactPickup__r.Phone + ' ' + NOB_ContactPickup__r.MobilePhone + ' ' + NOB_ContactPickup__r.OtherPhone);
            system.debug('##NOB_ContactPickup__r.NOB_PhonePro__c :'+NOB_ContactPickup__r.NOB_PhonePro__c); */
            
            vPhoneNumToCallBack= buildPhones(caseCurrent.NOB_ContactPickup__r);
            
            if( caseCurrent.NOB_ContactPickup__c == null){
                mapTaskRequest.put('ErrorContact',1);
            }
            else if (vPhoneNumToCallBack == null || vPhoneNumToCallBack == '' ){
                mapTaskRequest.put('ErrorPhone',2);
            }
            
            else{
                
                if (taskCurrent.PFR_CallPreferedEndTime__c <= taskCurrent.PFR_CallPreferedStartTime__c) {
                    vpreferedendtime = taskCurrent.PFR_CallPreferedStartTime__c.addhours(1);
                }
                else { 
                    vpreferedendtime = taskCurrent.PFR_CallPreferedEndTime__c;
                }// +1heure
                if(taskCurrent.PFR_CallPreferedStartTime__c != null){ 
                    mapTaskRequest.put('WhentoCallBack', taskCurrent.PFR_CallPreferedStartTime__c);
                }
                //mapTaskRequest.put('Hfin', NOB_AP00_Constants.checkNull(vpreferedendtime,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS));
                //mapTaskRequest.put('Hdeb', NOB_AP00_Constants.checkNull(taskCurrent.PFR_CallPreferedStartTime__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS));
                if(vpreferedendtime != null){ 
                    mapTaskRequest.put('Hfin', vpreferedendtime);
                }
                if(taskCurrent.PFR_CallPreferedStartTime__c != null){ 
                    mapTaskRequest.put('Hdeb', taskCurrent.PFR_CallPreferedStartTime__c);
                }                
                
                if(msgLog.NOB_MessageSubType__c == NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_CREATETASK){
                    system.debug('@@test' +msgLog.NOB_MessageSubType__c);
                    mapTaskRequest.put('TaskSource', 'Web');
                    mapTaskRequest.put('Surname', caseCurrent.NOB_InsurerClaimNumber__c);
                    mapTaskRequest.put('Reason', '');
                    mapTaskRequest.put('ProfileKey', NOB_AP00_Constants.checkNull(caseCurrent.NOB_BusinessProvider__r.Nob_CTICampaignNumber__c));
                    mapTaskRequest.put('Priority', '0');
                    //HMO -- rsiw (7613)
                    mapTaskRequest.put('PhoneNumToCallBack', vPhoneNumToCallBack);
                    mapTaskRequest.put('Name', (NOB_AP00_Constants.checkNull(caseCurrent.NOB_ContactPickup__r.FirstName)+' '+NOB_AP00_Constants.checkNull(caseCurrent.NOB_ContactPickup__r.LastName)).trim());
                    mapTaskRequest.put('Init', '0');
                    mapTaskRequest.put('Importfield', '0');
                    mapTaskRequest.put('idPhone', '0');
                    mapTaskRequest.put('Genesys', FALSE);
                    mapTaskRequest.put('CtStatus', 'AAppeler');
                    mapTaskRequest.put('Context', buildContext(caseCurrent));
                    mapTaskRequest.put('CliCRM', msgLog.Tech_TaskID__c);
                    mapTaskRequest.put('AgentID', '0');
                    mapTaskRequest.put('AgendaKey', 'cpg_pfk');
                }
                else if(msgLog.NOB_MessageSubType__c == NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_UPDATETASK){
                    system.debug('@@test2' +msgLog.NOB_MessageSubType__c);
                    String strNewActName = '';
                    if (lstTasks[0].PFR_CallStatus__c == 'Déjà appelé' ||
                        lstTasks[0].PFR_CallStatus__c == 'Échec' ||
                        lstTasks[0].PFR_CallStatus__c == 'Pas de numéro' ||
                        lstTasks[0].PFR_CallStatus__c == 'Rendez-vous pris' ||
                        lstTasks[0].PFR_CallStatus__c == 'Ne souhaite pas donner suite'/*WCH 27/10/2021 RSIW-11141*/){
                            strNewActName = 'Done';
                        }
                    String newState = String.isBlank(lstTasks[0].PFR_CallStatus__c)?NOB_AP00_Constants.checkNull(lstTasks[0].PFR_CallStatus__c):(lstTasks[0].PFR_CallStatus__c.equals('Ne souhaite pas donner suite')?'Déjà appelé':lstTasks[0].PFR_CallStatus__c);
                    //mapTaskRequest.put('WhentoCallBack', NOB_AP00_Constants.checkNull(taskCurrent.PFR_CallPreferedStartTime__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS));
                    mapTaskRequest.put('newActName', strNewActName);
                    mapTaskRequest.put('newState', newState);
                    //mapTaskRequest.put('newState', lstTasks[0].PFR_CallStatus__c);
                    //mapTaskRequest.put('Hfin', NOB_AP00_Constants.checkNull(vpreferedendtime,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS));
                    //mapTaskRequest.put('Hdeb', NOB_AP00_Constants.checkNull(taskCurrent.PFR_CallPreferedStartTime__c,NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS));
                    mapTaskRequest.put('id_CRM', msgLog.Tech_TaskID__c);
                    mapTaskRequest.put('Segmentation', 'PFK');
                }
            }
        }
        system.debug('##mapTaskRequest : ' + mapTaskRequest);
        return mapTaskRequest;
    }
    
    //ARA 02/12/2020
    // private static String buildPhoneNumbers(Contact c){
    //     String result = '';
    //     String tel = '';
    //     String mainPhone = '';
    
    //     if(c.MobilePhone != null){
    //         result = c.MobilePhone;
    //     }
    //     if(c.Phone != null){
    //         if(result != ''){
    //             result = result + ';' ;
    //         }
    //         result= result + c.Phone;
    //     }
    //     if(c.OtherPhone != null){
    //         if(result != ''){
    //             result = result + ';' ;
    //         }
    //         result= result + c.OtherPhone;
    //     }
    //     /*if(c.HomePhone != null){
    //         if(result != ''){
    //             result = result + ';' ;
    //         }
    //         result= result + c.HomePhone;
    //     }*/
    //     //HMO -- rsiw 7613
    //     // mainPhone = buildPhones(c);
    //     // if (result.contains(mainPhone)){
    //     //     mainPhone = mainPhone + ';';
    //     //     tel = result.remove(mainPhone);
    //     // }
    //     //return result;
    //     //return tel;
    // }
    
    public static String buildPhones(Contact c) {
        String result = '';
        if (c.MobilePhone != null) {
            result = c.MobilePhone;
        } 
        else if (c.Phone != null) {
            result = c.Phone;
        }
        else if (c.OtherPhone != null) {
            result = c.OtherPhone;
        }
        else if (c.NOB_PhonePro__c != null) {
            result = c.NOB_PhonePro__c;
        }        
        return result;
    }
    
    public static String buildContext(Case caseCurrent){
        Contact c = caseCurrent.NOB_ContactPickup__r;
        String result = '';
        if(c.MobilePhone != null){
            result = ',TELS,' + c.MobilePhone;
        }
        if(c.Phone != null){
            if(result != ''){
                result = result + ';' ;
            }
            else {
                result = ',TELS,';
            }
            result= result + c.Phone;
        }
        
        if(c.OtherPhone != null){
            if(result != ''){
                result = result + ';' ;
            }
            else {
                result = ',TELS,';
            }
            result= result + c.OtherPhone;
        }
        
        if(c.NOB_PhonePro__c != null){
            if(result != ''){
                result = result + ';' ;
            }
            else {
                result = ',TELS,';
            }
            result= result + c.NOB_PhonePro__c;
        }
        
        String root = 'url,'+System.URL.getOrgDomainUrl().toExternalForm()+'&'+ caseCurrent.Id;
        
        return root + result;
    }
}