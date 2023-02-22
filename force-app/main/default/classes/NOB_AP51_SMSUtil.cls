public class NOB_AP51_SMSUtil {
    
    public static String getMessage(String labelName,NOB_SmsLog__c log, Case ca, WorkOrder wo, NOB_SMSLogConfig__c config){
        String rawLabel = '';
        System.debug('Executing getMessage');
        //HMO -- 07-07-2021 -- commenting soql
        // Id caseId = log.NOB_Case__c;
        // Case ca = [SELECT Id, NOB_BusinessProvider__r.Name, NOB_BusinessProvider__r.NOB_SiretHeadquarters__c, NOB_TECH_DispoId__c, NOB_TECH_DispoId__r.NOB_StartDate__c, NOB_TECH_DispoId__r.NOB_EndDate__c, NOB_BodyShop__r.Name, NOB_BodyShop__r.Phone FROM Case WHERE Id=:caseId];

        System.debug('The Case:::' + ca);
        if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_1){
            rawLabel = config.Etape1AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape1DA__c;
            }

            //HMO -- 07-07-2021 replace ca.is by ca
            rawLabel = replaceEtapeOne(ca,rawLabel);
            System.debug('rawLabel::::' + rawLabel);
            //return Label.NOB_SMS_Etape_1;
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_2){
            rawLabel = config.Etape2AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape2DA__c;
            }
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_3){
            rawLabel = config.Etape3AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape3DA__c;
            }


            //HMO -- 07-07-2021 replacing log.workOrder by wo
            rawLabel = replaceEtapeThree(ca,rawLabel,wo,log);
            System.debug('##Etape 3 '+ rawLabel);
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_4){
            rawLabel = config.Etape4AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape4DA__c;
            }

            //HMO replacing log.workOrder__c by wo -- 07-07-2021
            rawLabel = replaceEtapeFour(wo, rawLabel);
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5){
            rawLabel = config.Etape5AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape5DA__c;
            }
            rawLabel = replaceEtapeFour(wo, rawLabel);
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_5B){
            rawLabel = config.Etape5bAXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape5bDA__c;
            }
            rawLabel = replaceEtapeFour(wo, rawLabel);
        }else if(labelName == NOB_AP00_Constants.SMS_LOG_LABEL_SMS_ETAPE_6){
            rawLabel = config.Etape6AXA__c;
            if(!isAxa(ca)){
                rawLabel = config.Etape6DA__c;
            }
            rawLabel = replaceEtapeFour(wo, rawLabel);
        }
        
        return rawLabel;
    }
    
    //HMO -- replacing workOrderId by WorkOrder
    public static String replaceEtapeFour(WorkOrder wo, String msg){
        
        
        String value = msg;
        
        //HMO -- 07-07-2021 commenting soql
        //WorkOrder wo = [SELECT Id, NOB_VehiculeReturnDate__c FROM WorkOrder WHERE Id=:workorderId];
        if (wo.NOB_VehiculeReturnDate__c != null) {
            Datetime retdt = NOBTools.convertTimeToOtherTimeZone(wo.NOB_VehiculeReturnDate__c, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());//WCH 05/10/2021 RSIW-11001
            String fmt = retdt.format('dd-MM-yyyy \'à\' HH:mm ' );
            List<String> parameters = new List<String>();
            parameters.add(fmt);
            value = String.format(value, parameters);
        }else{
            throw new AuraException('Impossible de récupérer les informations ');
        }

        return value;
    }
    
    //HMO -- replacing woId by wo
    private static String replaceEtapeThree(Case ca, String msg, Workorder wo, NOB_SmsLog__c log){
        List<String> parameters = new List<String>();
        String value = msg;
        if(ca.NOB_TECH_DispoId__r != null && wo == null){
            Datetime startDate = ca.NOB_TECH_DispoId__r.NOB_StartDate__c;
            Datetime endDate = ca.NOB_TECH_DispoId__r.NOB_EndDate__c;
            value = returnStringValue(startDate, endDate, msg);
              
        }
        else if(wo != null){
            //GBH   24.08.2021  RSIW-10600  Refonte Requête Json/Tech_DispoId et SMS
            if (wo.NOB_TECHDateRendezVousPrisEnCharge__c != null) {
				Datetime startDate = wo.NOB_TECHDateRendezVousPrisEnCharge__c;
                Datetime endDate = startDate.addHours(1);
                value = returnStringValue(startDate, endDate, value);
                
            }else if (ca.NOB_TECH_DispoId__r != null) {
                Datetime startDate = ca.NOB_TECH_DispoId__r.NOB_StartDate__c;
                Datetime endDate = ca.NOB_TECH_DispoId__r.NOB_EndDate__c;
                value = returnStringValue(startDate, endDate, msg);
            }else if (log.NOB_TECH_Planning__r != null) {
                Datetime startDate = log.NOB_TECH_Planning__r.NOB_StartDate__c;
                Datetime endDate = log.NOB_TECH_Planning__r.NOB_EndDate__c;
                value = returnStringValue(startDate, endDate, msg);
            }else{
                throw new AuraException('Impossible de récupérer les informations de rendez-vous');
            }
            
        }
        else{
            throw new AuraException('Impossible de récupérer les informations de rendez-vous');
        }
        
        if(wo != null){
            
            //HMO -- 07-07-2021 -- commenting soql
            //WorkOrder wo = [SELECT Id, NOB_Reparateur__c, NOB_Reparateur__r.Phone FROM WorkOrder WHERE Id =:woId];

            if(wo.NOB_Reparateur__r != null && wo.NOB_Reparateur__r.Phone != null){
                value =  value.replace('{3}', wo.NOB_Reparateur__r.Phone);
                parameters.add('-');
                value = String.format(value, parameters);    
            }else{
                throw new AuraException('Le reparateur n\'est pas present');
            }
            
        }else if(ca.NOB_BodyShop__r != null){
            //String repairer = ca.NOB_BodyShop__r.Name;
            //if(repairer != null)
            // msg =msg.replace('{3}', repairer);
            //parameters.add(repairer);
            //value = String.format(value, parameters);
            String phone = ca.NOB_BodyShop__r.Phone;
            if(phone != null){
                // msg = msg.replace('{4}', phone);
                parameters.add(phone);
                value =  value.replace('{3}', phone);//String.format(value, parameters);
            }
        } 
        
        
        return value;
        
    }
    
    public static String returnStringValue(DateTime startDate, DateTime endDate, String returnValue){
        startDate = NOB_AP00_Constants.addEuropeParisOffset(startDate);
        endDate = NOB_AP00_Constants.addEuropeParisOffset(endDate);
        List<String> parameters = new List<String>();
        // String returnValue = '';
        if(startDate != null && endDate != null){    
            String dt = to2num(startDate.day()) + '/' + to2num((startDate.month() )) + '/' + startDate.year();
            String sfrom = to2num(startDate.hour()) + ':' + to2num(startDate.minute());
            String to = to2num(endDate.hour()) + ':' + to2num(endDate.minute());
            parameters.add(dt);
            parameters.add(sfrom);
            parameters.add(to);
            returnValue = String.format(returnValue, parameters);
        }
        return returnValue;
    }
    
    private static String to2num(Integer num){
        if(num < 10){
            return '0' + num;
        }else{
            return num + '';
        }
    }
    
    private static boolean isAxa(Case ca){
        System.debug('Label.PFR_SiretAXA:'+Label.PFR_SiretAXA);
        System.debug('ca.NOB_BusinessPro:' + ca.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c);
        if(ca.NOB_BusinessProvider__r != null && ca.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c != null && ca.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c.toLowerCase().contains(Label.PFR_SiretAXA)){
            
            System.debug('Axaaaaaaaaaaaaaaaaaaaaa');
            return true;
        }
        return false;
    }

    //HMO -- 07-07-2021 replace caseId by ca
    //GBH 30/11/2020 RSIW-4839
    public static String replaceEtapeOne(Case ca, String msg){
        String value = msg;
        
        
        if(ca != null){

            //HMO -- 07-07-2021 -- commenting soql
            //Case ca = [SELECT Id, PFR_CalculatedCallPreferedStartTime__c, PFR_CalculatedCallPreferedEndTime__c FROM Case WHERE Id=:caseId];
            
            
            Datetime startDate = ca.PFR_CalculatedCallPreferedStartTime__c;
            Datetime endDate = ca.PFR_CalculatedCallPreferedEndTime__c;
            
            if(startDate != null && endDate != null){
                //WCH 05/10/2021 RSIW-11001
                String starttime = NOBTools.convertTimeToOtherTimeZone(startDate, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString()).format('HH:mm');
	            String endtime = NOBTools.convertTimeToOtherTimeZone(endDate, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString()).format('HH:mm');
                
                List<String> parameters = new List<String>();
                parameters.add(starttime);
                parameters.add(endtime);
                
                value = String.format(msg, parameters);
            }
        }
        System.debug('valueeee:' + value);
        return value; 
    }
    
}