/**
*/
/*
----------------------------------------------------------------------
-- - Name          : NOB_AP51_SMSSender
-- - Author        : -
-- - Description   : 
-- - #Ticket       : 
-- Maintenance History:
--
-- Date           Name  Version   Remarks
-- -----------    ----  -------   ---------------------------------------
-- -----------    -     1.0     Initial version
-- 28-OCT-2020    HMO   1.1     Replacing static values from NOB_AP00_Constants
-- 12-JAN-2021    ASE   1.2     Initial Version (RSIW-7023)
-- 07-JUL-2021    HMO   1.3     RSIW 10319
**********************************************************************
*/

public class NOB_AP51_SMSSender {
    
    //HMO -- RSIW 10319 -- merging query
    public static void sendSMS(Set<Id> setSmsLogIds){
        System.debug('££££ in sendSms Method start '+ setSmsLogIds);
        List<Contact> lstCons = new List<Contact>();
        List<WorkOrder> lstWO = new List<WorkOrder>();
        List<NOB_SMSLog__c> lstSmsLogs = new List<NOB_SMSLog__c>();
        List<NOB_Planning__c> lstPlanning = new List<NOB_Planning__c>();
        List<Case> lstCase = new List<Case>();

        Map<Id, NOB_SMSLog__c> mapLogs = new Map<Id, NOB_SMSLog__c>([SELECT Id,
                                                                        NOB_Subject__c,
                                                                        NOB_Case__c,
                                                                        NOB_Case__r.NOB_Integration__c, 
                                                                        NOB_WorkOrder__c,
                                                                     	NOB_TECH_Planning__c,
                                                                        NOB_TECH_Planning__r.NOB_StartDate__c,
                                                                        NOB_TECH_Planning__r.NOB_EndDate__c,
                                                                        NOB_Case__r.NOB_BusinessProvider__c, 
                                                                        NOB_Case__r.NOB_BusinessProvider__r.Name, 
                                                                        NOB_Case__r.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c, 
                                                                        NOB_Case__r.NOB_TECH_DispoId__c, 
                                                                        NOB_Case__r.NOB_TECH_DispoId__r.NOB_StartDate__c, 
                                                                        NOB_Case__r.NOB_TECH_DispoId__r.NOB_EndDate__c, 
                                                                        NOB_Case__r.NOB_BodyShop__r.Name, 
                                                                        NOB_Case__r.NOB_BodyShop__r.Phone, 
                                                                        NOB_Case__r.PFR_CalculatedCallPreferedStartTime__c, 
                                                                        NOB_Case__r.PFR_CalculatedCallPreferedEndTime__c,
                                                                        NOB_WorkOrder__r.NOB_VehiculeReturnDate__c,
                                                                        NOB_WorkOrder__r.NOB_Reparateur__c, 
                                                                        NOB_WorkOrder__r.NOB_Reparateur__r.Phone,
                                                                        NOB_WorkOrder__r.NOB_TECHDateRendezVousPrisEnCharge__c,
                                                                        NOB_Contact__c,NOB_JsonResponse__c,
                                                                        NOB_JsonRequest__c, 
                                                                        NOB_Statut__c,
                                                                        NOB_Contact__r.Id, 
                                                                        NOB_Contact__r.Name, 
                                                                        NOB_Contact__r.Phone, 
                                                                        NOB_Contact__r.MobilePhone,  
                                                                        NOB_Contact__r.NOB_PhonePro__c, 
                                                                        NOB_Contact__r.OtherPhone, 
                                                                        NOB_Contact__r.HomePhone, 
                                                                        NOB_Contact__r.AssistantPhone
                                                                    FROM NOB_SMSLog__c 
                                                                    WHERE Id IN: setSmsLogIds]);



        System.debug('££££ mapLogs '+ mapLogs);
        for (Id logId : mapLogs.keySet()){
            if (mapLogs.containsKey(logId)){
                if (mapLogs.get(logId).NOB_Contact__c != null){
                    Contact contact = new Contact();

                    contact.Id = (mapLogs.get(logId).NOB_Contact__c != null) ? mapLogs.get(logId).NOB_Contact__r.Id: null;
                    contact.LastName = (mapLogs.get(logId).NOB_Contact__r.Name != null) ? mapLogs.get(logId).NOB_Contact__r.Name : null;

                    contact.Phone =  (mapLogs.get(logId).NOB_Contact__r.Phone != null) ? mapLogs.get(logId).NOB_Contact__r.Phone : null;

                    contact.OtherPhone = (mapLogs.get(logId).NOB_Contact__r.OtherPhone != null) ? mapLogs.get(logId).NOB_Contact__r.OtherPhone : null;

                    contact.HomePhone = (mapLogs.get(logId).NOB_Contact__r.HomePhone != null) ? mapLogs.get(logId).NOB_Contact__r.HomePhone : null;

                    contact.AssistantPhone = (mapLogs.get(logId).NOB_Contact__r.AssistantPhone !=null) ? mapLogs.get(logId).NOB_Contact__r.AssistantPhone : null;
                    //GBH   02.08.2021  Missing phone fields added - correction of invalid phone error 
                    contact.MobilePhone =  (mapLogs.get(logId).NOB_Contact__r.MobilePhone != null) ? mapLogs.get(logId).NOB_Contact__r.MobilePhone : null;

                    contact.NOB_PhonePro__c =  (mapLogs.get(logId).NOB_Contact__r.NOB_PhonePro__c != null) ? mapLogs.get(logId).NOB_Contact__r.NOB_PhonePro__c : null;
                    /////
                    lstCons.add(contact);
                    System.debug('£££ lstCons '+ lstCons);
                } else {
                    //GBH   RSIW-11220  24.11.2021
                    Contact contact = new Contact();
                    lstCons.add(contact);
                }

                if (mapLogs.get(logId).NOB_WorkOrder__c != null){
                    WorkOrder wo = new WorkOrder();
                    
                    wo.Id = (mapLogs.get(logId).NOB_WorkOrder__c != null) ? mapLogs.get(logId).NOB_WorkOrder__c : null;
                    wo.NOB_Reparateur__r = (mapLogs.get(logId).NOB_WorkOrder__r.NOB_Reparateur__r != null) ? mapLogs.get(logId).NOB_WorkOrder__r.NOB_Reparateur__r : null;

                    wo.NOB_VehiculeReturnDate__c = (mapLogs.get(logId).NOB_WorkOrder__r.NOB_VehiculeReturnDate__c != null) ? mapLogs.get(logId).NOB_WorkOrder__r.NOB_VehiculeReturnDate__c : null;
                    
                    wo.NOB_TECHDateRendezVousPrisEnCharge__c = (mapLogs.get(logId).NOB_WorkOrder__r.NOB_TECHDateRendezVousPrisEnCharge__c != null) ? mapLogs.get(logId).NOB_WorkOrder__r.NOB_TECHDateRendezVousPrisEnCharge__c : null;
                    
                    lstWO.add(wo);
                } else {
                    //GBH   RSIW-11220  24.11.2021
                    WorkOrder wo = new WorkOrder();
                    lstWO.add(wo);
                }

                if (mapLogs.get(logId) != null){
                    NOB_SMSLog__c log = new NOB_SmsLog__c(Id = logId);
                    
                    log.NOB_Case__r = (mapLogs.get(logId).NOB_Case__r != null) ? mapLogs.get(logId).NOB_Case__r : null;
                    log.NOB_WorkOrder__r = (mapLogs.get(logId).NOB_WorkOrder__r != null) ? mapLogs.get(logId).NOB_WorkOrder__r : null;
                    log.NOB_Subject__c = (mapLogs.get(logId).NOB_Subject__c != null) ? mapLogs.get(logId).NOB_Subject__c : null ;
                    log.NOB_Statut__c = (mapLogs.get(logId).NOB_Statut__c != null) ? mapLogs.get(logId).NOB_Statut__c : null;
                    log.NOB_Contact__c = (mapLogs.get(logId).NOB_Contact__c != null) ? mapLogs.get(logId).NOB_Contact__c : null;
                    log.NOB_JsonResponse__c = (mapLogs.get(logId).NOB_JsonResponse__c != null) ? mapLogs.get(logId).NOB_JsonResponse__c : null;
                    log.NOB_JsonRequest__c = (mapLogs.get(logId).NOB_JsonRequest__c != null) ? mapLogs.get(logId).NOB_JsonRequest__c : null;
                    log.NOB_TECH_Planning__r = (mapLogs.get(logId).NOB_TECH_Planning__r != null) ? mapLogs.get(logId).NOB_TECH_Planning__r : null;
                    lstSmsLogs.add(log);
                }
				
                if (mapLogs.get(logId).NOB_Case__c != null ){
                    Case ca = new Case();
                    ca.Id = (mapLogs.get(logId).NOB_Case__c != null) ? mapLogs.get(logId).NOB_Case__c : null;

            
                    ca.NOB_BusinessProvider__r = (mapLogs.get(logId).NOB_Case__r.NOB_BusinessProvider__r != null) ? mapLogs.get(logId).NOB_Case__r.NOB_BusinessProvider__r : null;

                    ca.NOB_TECH_DispoId__r = (mapLogs.get(logId).NOB_Case__r.NOB_TECH_DispoId__r != null) ? mapLogs.get(logId).NOB_Case__r.NOB_TECH_DispoId__r : null;

                    ca.NOB_BodyShop__r = (mapLogs.get(logId).NOB_Case__r.NOB_BodyShop__r != null) ? mapLogs.get(logId).NOB_Case__r.NOB_BodyShop__r : null;

                    ca.PFR_CalculatedCallPreferedStartTime__c = (mapLogs.get(logId).NOB_Case__r.PFR_CalculatedCallPreferedStartTime__c != null) ? mapLogs.get(logId).NOB_Case__r.PFR_CalculatedCallPreferedStartTime__c : null;

                    ca.PFR_CalculatedCallPreferedEndTime__c = (mapLogs.get(logId).NOB_Case__r.PFR_CalculatedCallPreferedEndTime__c != null) ? mapLogs.get(logId).NOB_Case__r.PFR_CalculatedCallPreferedEndTime__c : null;
                    lstCase.add(ca);

                } else {
                    //GBH   RSIW-11220  24.11.2021
                    Case ca = new Case();
                    lstCase.add(ca);
                }
            }
        }

        List<Contact> dests = new List<Contact>();
        dests.addAll(lstCons);

        Map<Id,String> mpContactPhones = new Map<Id,String>();
        for(Contact dest : dests){
            if(isValidMobile(dest.MobilePhone)){
                mpContactPhones.put(dest.Id, dest.MobilePhone);
            }else if(isValidMobile(dest.Phone)){
                mpContactPhones.put(dest.Id, dest.Phone);
            }else if(isValidMobile(dest.OtherPhone)){
                mpContactPhones.put(dest.Id, dest.OtherPhone);
            }else if(isValidMobile(dest.NOB_PhonePro__c)){//GBH   02.08.2021  Missing phone fields added - correction of invalid phone error 
                mpContactPhones.put(dest.Id, dest.NOB_PhonePro__c);
            }else if(isValidMobile(dest.HomePhone)){
                mpContactPhones.put(dest.Id, dest.HomePhone);
            }else if(isValidMobile(dest.AssistantPhone)){
                mpContactPhones.put(dest.Id, dest.AssistantPhone);
            }else{
                mpContactPhones.put(dest.Id, 'Invalid Phone');
            }
        }
        
        List<WorkOrder> workOrders = new List<WorkOrder>();
        workOrders.addAll(lstWO);
        
        Map<Id,DateTime> mapWORetDate = new Map<Id,DateTime>();
        
        for(WorkOrder wo : workOrders){
            mapWORetDate.put(wo.Id, wo.NOB_VehiculeReturnDate__c);
        }
        
        
        Boolean requireSave = false;
        
        List<NOB_SMSLog__c> logs = new List<NOB_SMSLog__c>();
        logs.addAll(lstSmsLogs);

        NOB_SMSLogConfig__c config = getConfig();
        for(integer i = 0; i < lstSmsLogs.size(); i ++){
            NOB_SMSLog__c log = lstSmsLogs[i];
            
            Case ca = lstCase[i];
            //GBH   RSIW-10620  17/08/2021
            WorkOrder wo = (lstWO.size()>=i)? lstWO[i] : new WorkOrder();

            //RSIW-7023 when callerSystem changes NOB_Integration__c  to Finalisé by WS OR when case is created by an agent, the NOB_Integration__c = null
            if(log.NOB_Case__r.NOB_Integration__c != 'Échec' ) {
                if (log.NOB_Statut__c == 'To be send') {
                    try{
                        String etape = log.NOB_Subject__c;
                        String customLabel = 'NOB_SMS_' + etape;
                        String content = NOB_AP51_SMSUtil.getMessage(customLabel, log, ca, wo, config); //getLabelString(customLabel);
                        Id contactId = log.NOB_Contact__c;
                        String phone = mpContactPhones.get(contactId);
                        if (phone != 'Invalid Phone') {
                            setSMS(content, phone, log.Id);
                            //String body = response.getBody();
                            //log.NOB_JsonResponse__c = body;
                            //log.NOB_Statut__c
                        } else {
                            Map<String, String> error = new Map<String, String>();
                            error.put('error', 'invalid phone');
                            error.put('status', 'error');
                            log.NOB_Statut__c = 'Error';
                            log.NOB_JsonResponse__c = JSON.serialize(error);
                            requireSave = true;
                        }
                    }catch(Exception e){
                        Map<String,String> error = new Map<String,String>();
                        error.put('error', e.getMessage());
                        error.put('status', 'error');
                        log.NOB_Statut__c  = 'Error';
                        log.NOB_JsonResponse__c = JSON.serialize(error);
                        requireSave = true;
                    }
                }
            }
            else{
                Map<String,String> error = new Map<String,String>();
                error.put('error', 'Le statut de l\'intégration de la requête est à Echec');
                error.put('status', 'error');
                log.NOB_Statut__c  = 'Error';
                log.NOB_JsonResponse__c = JSON.serialize(error);
                requireSave = true;
            }
        }
        if(requireSave)
            update logs;
        
    }
    
    
    /*public static String replaceEtapeFour(Id workorderId, String msg){
        WorkOrder wo = [SELECT Id, NOB_VehiculeReturnDate__c FROM WorkOrder WHERE Id=:workorderId];
        Datetime retdt = wo.NOB_VehiculeReturnDate__c;
        String fmt = retdt.format('dd-MM-yyyy \'à\' HH:mm ' );
        return msg.replace('{0}', fmt);
    }
    
    public static String replaceEtapeThree(Id caseId, String msg){
        
        if(caseId != null){
            Case ca = [SELECT Id, NOB_TECH_DispoId__c, NOB_TECH_DispoId__r.NOB_StartDate__c, NOB_TECH_DispoId__r.NOB_EndDate__c, NOB_BodyShop__r.Name, NOB_BodyShop__r.Phone FROM Case WHERE Id=:caseId];
            
            if(ca.NOB_TECH_DispoId__r != null ){
                Datetime startDate = ca.NOB_TECH_DispoId__r.NOB_StartDate__c;
                Datetime endDate = ca.NOB_TECH_DispoId__r.NOB_EndDate__c;
                if(startDate != null && endDate != null){    
                    String dt = to2num(startDate.day()) + '/' + to2num((startDate.month() +1)) + '/' + startDate.year();
                    String sfrom = to2num(startDate.hour()) + ':' + to2num(startDate.minute());
                    String to = to2num(endDate.hour()) + ':' + to2num(endDate.minute());
                    msg = msg.replace('{0}', dt);
                    msg = msg.replace('{1}', sfrom);
                    msg = msg.replace('{2}', to);
                }
                //msg = msg.replace(target, replacement)
            }
            
            if(ca.NOB_BodyShop__r != null){
                String repairer = ca.NOB_BodyShop__r.Name;
                if(repairer != null)
                    msg =msg.replace('{3}', repairer);
                String phone = ca.NOB_BodyShop__r.Phone;
                if(phone != null)
                    msg = msg.replace('{4}', phone);
            }
        }
        
        return msg;
        
    }
    
    private static String to2num(Integer num){
        if(num < 10){
            return '0' + num;
        }else{
            return num + '';
        }
    }
    
    public static String getLabelString(String labelName ){
        if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_1){
            return Label.NOB_SMS_Etape_1;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_2){
            return Label.NOB_SMS_Etape_2;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_3){
            return Label.NOB_SMS_Etape_3;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_4){
            return Label.NOB_SMS_Etape_4;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5){
            return Label.NOB_SMS_Etape_5;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5B){
            return Label.NOB_SMS_Etape_5b;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_6){
            return Label.NOB_SMS_Etape_6;
        }else{
            return null;
        }
        //Component.Apex.OutputText output = new Component.Apex.OutputText();
        //output.expressions.value = '{!$Label.' + labelName + '}';
        //return String.valueOf(output.value);
    }*/
    
    
    public static NOB_SMSLogConfig__c getConfig(){
        List<NOB_SMSLogConfig__c> configs = [SELECT NOB_ClientId__c, NOB_ClientSecret__c, NOB_Endpoint__c, 
                                             Etape1AXA__c,
                                             Etape1DA__c,
                                             Etape2AXA__c,
                                             Etape2DA__c,
                                             Etape3AXA__c,
                                             Etape3DA__c,
                                             Etape4AXA__c,
                                             Etape4DA__c,
                                             Etape5AXA__c,
                                             Etape5bAXA__c,
                                             Etape5bDA__c,
                                             Etape5DA__c,
                                             Etape6AXA__c,
                                             Etape6DA__c
                                             FROM NOB_SMSLogConfig__c LIMIT 1];
        if(configs.size() > 0){
            return configs.get(0);
        }else{
            return null;
        }
        
        //return config;
    }
    


    //HMO -- 07-07-2021 -- commenting soql -- RSIW - 10319
    @future(callout=true)
    public static void setSMS(String msg, String phone, Id logId){
        //NOB_SMSLog__c log = [SELECT Id, NOB_Case__c, NOB_Subject__c,NOB_Contact__c, NOB_WorkOrder__c, NOB_JsonResponse__c,NOB_JsonRequest__c, NOB_Statut__c FROM NOB_SMSLog__c WHERE Id =: logId];

        NOB_SmsLog__c log = new NOB_SmsLog__c(Id = logId);
       /* if(log.NOB_Subject__c != null && log.NOB_Subject__c.equals('Etape_3')){
            msg =replaceEtapeThree(log.NOB_Case__c, msg);
        }
        if(log.NOB_Subject__c != null && (log.NOB_Subject__c.equals('Etape_4') || log.NOB_Subject__c.equals('Etape_5') || log.NOB_Subject__c.equals('Etape_5b')) ){
            msg =replaceEtapeFour(log.NOB_WorkOrder__c, msg);
        }*/
        try{
            
            NOB_SMSLogConfig__c config = getConfig();
            HttpRequest request = new HttpRequest();
            String endpoint = config.NOB_Endpoint__c;
            String clientId = config.NOB_ClientId__c;
            String clientSecret = config.NOB_ClientSecret__c;
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', clientId);
            request.setHeader('client_secret', clientSecret);
            Map<String,String> req = new Map<String,String>();
           // if(msg.length() > 160){
             //   msg = msg.substring(0, 160);
            //}
            String testNumber = System.Label.NOB_SMSTestNumber;
            Boolean isTestMode = 'yes'.equals( Label.NOB_SMSTestMode);
            if(isTestMode){
                phone = testNumber;
            }
            req.put('telephone', phone);
            req.put('message', msg);
            String body = JSON.serialize(req); //'{telephone: \''+phone+'\',message: \''+msg+'\'}';
            log.NOB_JsonRequest__c = body;
            request.setBody(body);
            System.debug('$$$$ request: ' + request);
            Http http = new Http();
            HttpResponse response = http.send(request);
            Map<String,String> success = new Map<String,String>();
            String result = response.getBody();
            if(result.indexOf('error') > 0){
                success.put('status', 'error');    
                log.NOB_Statut__c = 'Error';
            }else{
                success.put('status', 'success');
                log.NOB_Statut__c = 'Sent';
            }
            success.put('message', result);
            
            log.NOB_JsonResponse__c  = JSON.serialize(success);
            
        }catch(Exception e){
            Map<String,String> error = new Map<String,String>();
            error.put('error', e.getStackTraceString() +';' +  e.getMessage());
            System.debug('$$$$ Error: ' + e.getMessage());
            error.put('status', 'error');
            log.NOB_JsonResponse__c = JSON.serialize(error); 
            log.NOB_Statut__c = 'Error';
        }
        update log;
        // return response;
        
    }
    
    
    private static boolean isValidMobile(String phone){
        if(phone == null || phone.trim().length() < 5){
            return false;
        }
        phone = phone.trim();
        if(phone.startsWith('07') || phone.startsWith('06')){
            return true;
        }
        if(phone.startsWith('+')){
            //+337898....
            phone = phone.substring(3);
            //RSIW-10682
            return isValidMobile('0'+phone);
        }
        
        if(phone.startsWith('00')){
            //00 33 06767567...
            phone = phone.substring(2);
            return isValidMobile('+' + phone.trim());
        }
        
        return false;
    }
    
}