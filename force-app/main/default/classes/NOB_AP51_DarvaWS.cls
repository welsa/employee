/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 02-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0                      	Initial Version
 * 1.1    19-01-2021        	rsiw - 7629
 * 1.1    09-06-2021        	RSIW-9897
 * 1.2    09-06-2021	GBH		RSIW-9641 - Special Char
 * 1.3    20-07-2021	GBH		RSIW-9967 - Build JSON from WO on darva msg log
 * 1.4    22-07-2021	WCH		RSIW-10426 : Darva Outbound : Special chars Š
 * 1.5    14-12-2021	GBH		RSIW-11375: Ordonnancement d'envoi des messages SD40 avant SD32
 * 1.6    14-12-2021	GBH		RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
**/ 
public class NOB_AP51_DarvaWS {
    
    public static NOB_DarvaWSConfig__c getConfig(){
        List<NOB_DarvaWSConfig__c> configs = [SELECT NOB_ClientId__c, NOB_ClientSecret__c, NOB_Endpoint__c FROM NOB_DarvaWSConfig__c LIMIT 1];
        if(configs.size() > 0){
            return configs.get(0);
        }else{
            return null;
        }
        //return config;
    }
    
    @future(callout=true)
    public static void doSendMessage(Id dLogId, Id woId, Id caseId){
        System.debug('Sending Message DARVA:' + dLogId);
        List<NOB_DarvaMessageLog__c> lstLog = [SELECT Id,
                                            NOB_JsonResponse__c, 
                                            NOB_MessageSubType__c, 
                                            NOB_Case__c, 
                                            NOB_MessageType__c, 
                                            NOB_JsonRequest__c, 
                                            NOB_Status__c, 
                                            Tech_TaskID__c,
                                            Nob_WorkOrder__c,
                                            /////////////////////////
                                            Nob_WorkOrder__r.caseId,
                                            Nob_WorkOrder__r.Case.PFR_Coverage__c,
                                            Nob_WorkOrder__r.NOB_ScenarioCode__c,
                                            Nob_WorkOrder__r.Case.NOB_SD32Comment__c,
                                            Nob_WorkOrder__r.NOB_InsurerClaimNumber__c,
                                            Nob_WorkOrder__r.PFR_TECH_EngineerClaimNR__c,
                                            Nob_WorkOrder__r.NOB_Pricebook__r.Name,
                                            Nob_WorkOrder__r.Contact.Title,
                                            Nob_WorkOrder__r.Case.Contact.Name,
                                            Nob_WorkOrder__r.Case.Contact.MailingStreet,
                                            Nob_WorkOrder__r.Case.Contact.MailingPostalCode,
                                            Nob_WorkOrder__r.Case.Contact.MailingCity,
                                            Nob_WorkOrder__r.Case.Contact.MailingCountry,
                                            Nob_WorkOrder__r.Case.Contact.MailingCountryCode,
                                            Nob_WorkOrder__r.Case.Contact.NOB_InsuredtTVASubject__c,
                                            Nob_WorkOrder__r.Case.Contact.Email,
                                            Nob_WorkOrder__r.Case.Contact.Fax,
                                            Nob_WorkOrder__r.Case.Contact.MobilePhone,
                                            Nob_WorkOrder__r.Case.Contact.Phone,
                                            Nob_WorkOrder__r.Case.NOB_TECH_DispoId__c,
                                            Nob_WorkOrder__r.Case.NOB_TECH_DispoId__r.NOB_StartDate__c,
                                            NOB_WorkOrder__r.NOB_TECH_CourtesyCarNeedeForInsurer__c,
                                            
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_DSP__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T1__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T2__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T3__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TauxMecanique__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI1__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI2__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI3__c,
                                            NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TP__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.Name,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.Phone,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.NOB_EmailAddress__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.NOB_DarvaIdentifier__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.BillingStreet,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.BillingCity,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountry,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkType__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkCategory__c,
                                            Nob_WorkOrder__r.NOB_Reparateur__r.NOB_Statut__c,
                                            Nob_WorkOrder__r.NOB_BusinessProvider__r.NOB_DarvaIdentifier__c,
                                            // rsiw - 6018 	-- HMO - 2020-12-09
                                            Nob_WorkOrder__r.Case.Expert__c,
                                            Nob_WorkOrder__r.Case.Expert__r.Name,
                                            Nob_WorkOrder__r.Case.Expert__r.Phone,
                                            Nob_WorkOrder__r.Case.Expert__r.NOB_EmailAddress__c,
                                            Nob_WorkOrder__r.Case.Expert__r.NOB_DarvaIdentifier__c,
                                            Nob_WorkOrder__r.Case.Expert__r.BillingStreet,
                                            Nob_WorkOrder__r.Case.Expert__r.BillingPostalCode,
                                            Nob_WorkOrder__r.Case.Expert__r.BillingCity,
                                            Nob_WorkOrder__r.Case.Expert__r.BillingCountryCode,
                                            Nob_WorkOrder__r.Case.Expert__r.BillingCountry,
                                            Nob_WorkOrder__r.Case.Expert__r.NOB_NetworkType__c,
                                            Nob_WorkOrder__r.Case.Expert__r.NOB_NetworkCategory__c,
                                            Nob_WorkOrder__r.Case.Expert__r.NOB_Statut__c,
                                            //GBH   RSIW-10652  08.09.2021  SD36/37 integration - Add Invoice to JSON request.
                                            Document_Financier__c,
                                            Document_Financier__r.recordType.DeveloperName,
                                            Document_Financier__r.PFR_RepairInvoiceNumber__c,
                                            Document_Financier__r.PFR_CreditNumber__c,
                                            Document_Financier__r.PFR_FinDocDateOfIssue__c,
                                            toLabel(Document_Financier__r.PFR_StatusReason__c)
                                            // 
                                    FROM NOB_DarvaMessageLog__c 
                                    WHERE Id =: dLogId];
        
        
        NOB_DarvaMessageLog__c log = new NOB_DarvaMessageLog__c();
        for (NOB_DarvaMessageLog__c currentLog : lstLog){
            if (currentLog.Id == dLogId) log = currentLog;
        }
        List<NOB_DarvaMessageLog__c> lstLogUpdt = new List<NOB_DarvaMessageLog__c>();
        try{
            
            System.debug('LOGDATA:' + log);
            Id requestId = log.NOB_Case__c;
            String messageType = log.NOB_MessageType__c;
            String messageSubType = log.NOB_MessageSubType__c;
            Map<String,Object> req = new Map<String, Object>();

            HttpRequest request = new HttpRequest();
            NOB_DarvaWSConfig__c config = getConfig();
            String endpoint = config.NOB_Endpoint__c;
            request.settimeout(120000); // LMU RSIW-9620
            String clientId = config.NOB_ClientId__c;
            String clientSecret = config.NOB_ClientSecret__c;
            request.setEndpoint(endpoint + '/messages/' + messageType);
            System.debug('Endpont:' + endpoint + '/messages/' + messageType);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', clientId);
            request.setHeader('client_secret', clientSecret);
            req = buildRequest(requestId,messageSubType, log);
            if(messageType == 'SD22'){
                System.debug('Building buildDocumentFinanciers');
                req.put('DocumentFinanciers', buildDocumentFinanciers(requestId));
            }
            
            
            String body = JSON.serialize(req); 
            System.debug('Body:' + body);
            log.NOB_JsonRequest__c = body;
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);
            Map<String,String> success = new Map<String,String>();
            String result = response.getBody();
            System.debug('Response:::' + result);
            if(result.indexOf('errors') > 0){ // RSIW-9178 : error devient errors pour ne pas détecter errorwarning
                success.put('status', 'error');    
                log.NOB_Status__c = 'Error';
            }else{
                success.put('status', 'success');
                log.NOB_Status__c = 'Sent';
            }
            success.put('message', result);
            
            log.NOB_JsonResponse__c  = JSON.serialize(success);
            lstLogUpdt.add(log);
            System.debug('log:'+ log);
        }catch(Exception e){
            Map<String,String> error = new Map<String,String>();
            error.put('error', e.getStackTraceString() +';' +  e.getMessage());
            error.put('status', 'error');
            log.NOB_JsonResponse__c = JSON.serialize(error); 
            log.NOB_Status__c = 'Error';
            lstLogUpdt.add(log);
        }
        update lstLogUpdt;
        // return response;
        
        
    }
    
    public static String getComment(Case ca){
        
	 return ca.NOB_SD32Comment__c;        

    }

    public static Account getPreviousBodyshop(Id caseId, Id curWorkOrderId,string curcaseEngineerClaimNR){
        List<WorkOrder> wos = [SELECT Id, 
                               NOB_Reparateur__c,
                               NOB_Reparateur__r.Name,
                               NOB_Reparateur__r.Phone,
                               NOB_Reparateur__r.NOB_EmailAddress__c,
                               NOB_Reparateur__r.NOB_DarvaIdentifier__c,
                               NOB_Reparateur__r.BillingStreet,
                               NOB_Reparateur__r.BillingPostalCode,
                               NOB_Reparateur__r.BillingCity,
                               NOB_Reparateur__r.BillingCountryCode,
                               NOB_Reparateur__r.BillingCountry ,
                               NOB_Reparateur__r.NOB_NetworkCategory__c,
                               NOB_Reparateur__r.NOB_NetworkType__c,
                               
                               CaseId FROM WorkOrder WHERE CaseId =: caseId AND Id !=:curWorkOrderId
                               AND PFR_TECH_EngineerClaimNR__c = :curcaseEngineerClaimNR
                               ORDER BY CreatedDate DESC];
        if(wos.size() > 0){
            return wos.get(0).NOB_Reparateur__r;
        }else{
            return null;
        }
    }
    
    public static Map<String,Object> buildRequest(Id caseId, String messageSubType, NOB_DarvaMessageLog__c log){
        Boolean hasWO = log.Nob_WorkOrder__c == null ? false : true;

        Case ca = [SELECT Id, 
                    PFR_Coverage__c, 
                    NOB_ScenarioCode__c, 
                    NOB_SD32Comment__c, 
                    NOB_InsurerClaimNumber__c, 
                    PFR_TECH_EngineerClaimNR__c, 
                    NOB_Pricebook__r.Name,
                   Contact.Title,
                   Contact.Name, 
                   Contact.MailingStreet, 
                   Contact.MailingPostalCode, 
                   Contact.MailingCity,
                   Contact.MailingCountry,
                   Contact.MailingCountryCode,
                   Contact.NOB_InsuredtTVASubject__c,  
                   Contact.Email, 
                   Contact.Fax, 
                   Contact.MobilePhone, 
                   Contact.Phone,
                   NOB_TECH_DispoId__c, 
                   NOB_TECH_DispoId__r.NOB_StartDate__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_TECH_CourtesyCarNeedeForInsurer__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__c,
                   //negorate

                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Name,
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Phone,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.NOB_EmailAddress__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.NOB_DarvaIdentifier__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry ,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkCategory__c,
                   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkType__c,

				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_DSP__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T1__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T2__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T3__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TauxMecanique__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI1__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI2__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI3__c, 
				   NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TP__c,
					NOB_BodyShop__c,
                   NOB_BodyShop__r.Name,
                   NOB_BodyShop__r.Phone,
                   NOB_BodyShop__r.NOB_EmailAddress__c,
                   NOB_BodyShop__r.NOB_DarvaIdentifier__c,
                   NOB_BodyShop__r.BillingStreet,
                   NOB_BodyShop__r.BillingPostalCode,
                   NOB_BodyShop__r.BillingCity,
                   NOB_BodyShop__r.BillingCountryCode,
                   NOB_BodyShop__r.BillingCountry ,
                   NOB_BodyShop__r.NOB_NetworkType__c,
                   NOB_BodyShop__r.NOB_NetworkCategory__c,
                   NOB_BodyShop__r.NOB_Statut__c,
                   NOB_BusinessProvider__r.NOB_DarvaIdentifier__c,
                   
                   //rsiw - 6018 -- HMO - 2020-12-09
                   Expert__c,
                   Expert__r.Name,
                   Expert__r.Phone,
                   Expert__r.NOB_EmailAddress__c,
                   Expert__r.NOB_DarvaIdentifier__c,
                   Expert__r.BillingStreet,
                   Expert__r.BillingPostalCode,
                   Expert__r.BillingCity,
                   Expert__r.BillingCountryCode,
                   Expert__r.BillingCountry ,
                   Expert__r.NOB_NetworkType__c,
                   Expert__r.NOB_NetworkCategory__c,
                   Expert__r.NOB_Statut__c
                   

                   FROM Case WHERE Id=:caseId                   
                  ];
        //GBH   15/12/2021      RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
        Map <String,String> mapCasePhone = new Map <String,String>();
        mapCasePhone.put('Contact.MobilePhone',ca.Contact.MobilePhone);
        mapCasePhone.put('Contact.Phone',ca.Contact.Phone);
        mapCasePhone.put('NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Phone',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Phone);
        mapCasePhone.put('NOB_BodyShop__r.Phone',ca.NOB_BodyShop__r.Phone);
        mapCasePhone.put('Expert__r.Phone',ca.Expert__r.Phone);

        Map<String,String> mapCaseFilteredPhone = NOBTools.removeNonNumeric(mapCasePhone);

        //GBH   07/06/2021
        Map <String,String> mapCaseStr = new Map <String,String>();
        if (hasWO) {
            mapCaseStr.put('ContactMailingStreet',log.Nob_WorkOrder__r.Case.Contact.MailingStreet);
            mapCaseStr.put('ContactMailingPostalCode',log.Nob_WorkOrder__r.Case.Contact.MailingPostalCode);
            mapCaseStr.put('ContactMailingCity',log.Nob_WorkOrder__r.Case.Contact.MailingCity);
            mapCaseStr.put('ContactMailingCountry',log.Nob_WorkOrder__r.Case.Contact.MailingCountry);
            mapCaseStr.put('ContactMailingCountryCode',log.Nob_WorkOrder__r.Case.Contact.MailingCountryCode);
            mapCaseStr.put('BSBillingStreet',log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingStreet);
            mapCaseStr.put('BSBillingPostalCode',log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode);
            mapCaseStr.put('BSBillingCity',log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCity);
            mapCaseStr.put('BSBillingCountryCode',log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode);
            mapCaseStr.put('BSBillingCountry',log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountry);
           
            mapCaseStr.put('ExpBillingStreet', log.Nob_WorkOrder__r.Case.Expert__r.BillingStreet);
            mapCaseStr.put('ExpBillingPostalCode',log.Nob_WorkOrder__r.Case.Expert__r.BillingPostalCode);
            mapCaseStr.put('ExpBillingCity',log.Nob_WorkOrder__r.Case.Expert__r.BillingCity);
            mapCaseStr.put('ExpBillingCountryCode',log.Nob_WorkOrder__r.Case.Expert__r.BillingCountryCode);
            mapCaseStr.put('ExpBillingCountry',log.Nob_WorkOrder__r.Case.Expert__r.BillingCountry);
        } else {
            mapCaseStr.put('ContactMailingStreet',ca.Contact.MailingStreet);
            mapCaseStr.put('ContactMailingPostalCode',ca.Contact.MailingPostalCode);
            mapCaseStr.put('ContactMailingCity',ca.Contact.MailingCity);
            mapCaseStr.put('ContactMailingCountry',ca.Contact.MailingCountry);
            mapCaseStr.put('ContactMailingCountryCode',ca.Contact.MailingCountryCode);
            mapCaseStr.put('BSBillingStreet',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet);
            mapCaseStr.put('BSBillingPostalCode',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode);
            mapCaseStr.put('BSBillingCity',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity);
            mapCaseStr.put('BSBillingCountryCode',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode);
            mapCaseStr.put('BSBillingCountry',ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry);
            mapCaseStr.put('BS1BillingStreet',ca.NOB_BodyShop__r.BillingStreet);
            mapCaseStr.put('BS1BillingPostalCode',ca.NOB_BodyShop__r.BillingPostalCode);
            mapCaseStr.put('BS1BillingCity',ca.NOB_BodyShop__r.BillingCity);
            mapCaseStr.put('BS1BillingCountryCode',ca.NOB_BodyShop__r.BillingCountryCode);
            mapCaseStr.put('BS1BillingCountry',ca.NOB_BodyShop__r.BillingCountry); 
            mapCaseStr.put('ExpBillingStreet',ca.Expert__r.BillingStreet);
            mapCaseStr.put('ExpBillingPostalCode',ca.Expert__r.BillingPostalCode);
            mapCaseStr.put('ExpBillingCity',ca.Expert__r.BillingCity);
            mapCaseStr.put('ExpBillingCountryCode',ca.Expert__r.BillingCountryCode);
            mapCaseStr.put('ExpBillingCountry',ca.Expert__r.BillingCountry);
        }
        

        Map<String,String> mapCaseFilteredStr = NOBTools.removeSpecialChar(mapCaseStr);

        if(ca.Contact!=null){
            ca.Contact.MailingStreet = mapCaseFilteredStr.get('ContactMailingStreet');
            ca.Contact.MailingPostalCode = mapCaseFilteredStr.get('ContactMailingPostalCode');
            ca.Contact.MailingCity = mapCaseFilteredStr.get('ContactMailingCity');
            ca.Contact.MailingCountry = mapCaseFilteredStr.get('ContactMailingCountry');
            ca.Contact.MailingCountryCode = mapCaseFilteredStr.get('ContactMailingCountryCode');

            //GBH   15/12/2021      RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
            ca.Contact.MobilePhone = mapCaseFilteredPhone.get('Contact.MobilePhone');
            ca.Contact.Phone = mapCaseFilteredPhone.get('Contact.Phone');
        }
        if(ca.NOB_TECH_DispoId__c!=null && ca.NOB_TECH_DispoId__r.NOB_WorkOrder__c!=null && ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__c!=null){
            if(hasWO){
                if (log.Nob_WorkOrder__c != null && log.Nob_WorkOrder__r.NOB_Reparateur__c != null){
                    log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingStreet = mapCaseFilteredStr.get('BSBillingStreet');
                    log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode = mapCaseFilteredStr.get('BSBillingPostalCode');
                    log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCity = mapCaseFilteredStr.get('BSBillingCity');
                    log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode = mapCaseFilteredStr.get('BSBillingCountryCode');
                    log.Nob_WorkOrder__r.NOB_Reparateur__r.BillingCountry = mapCaseFilteredStr.get('BSBillingCountry');
                }
            } else {
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet = mapCaseFilteredStr.get('BSBillingStreet');
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode = mapCaseFilteredStr.get('BSBillingPostalCode');
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity = mapCaseFilteredStr.get('BSBillingCity');
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode = mapCaseFilteredStr.get('BSBillingCountryCode');
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry = mapCaseFilteredStr.get('BSBillingCountry');

                //GBH   15/12/2021      RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
                ca.NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Phone = mapCaseFilteredPhone.get('NOB_TECH_DispoId__r.NOB_WorkOrder__r.NOB_Reparateur__r.Phone');
            }
        }
        if(ca.NOB_BodyShop__c!=null){
            ca.NOB_BodyShop__r.BillingStreet = mapCaseFilteredStr.get('BS1BillingStreet');
            ca.NOB_BodyShop__r.BillingPostalCode = mapCaseFilteredStr.get('BS1BillingPostalCode');
            ca.NOB_BodyShop__r.BillingCity = mapCaseFilteredStr.get('BS1BillingCity');
            ca.NOB_BodyShop__r.BillingCountryCode = mapCaseFilteredStr.get('BS1BillingCountryCode');
            ca.NOB_BodyShop__r.BillingCountry  = mapCaseFilteredStr.get('BS1BillingCountry');

            //GBH   15/12/2021      RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
            ca.NOB_BodyShop__r.Phone = mapCaseFilteredPhone.get('NOB_BodyShop__r.Phone');
        }
        if(ca.Expert__c!=null){
            
            if(hasWO){
                log.Nob_WorkOrder__r.Case.Expert__r.BillingStreet = mapCaseFilteredStr.get('ExpBillingStreet');
                log.Nob_WorkOrder__r.Case.Expert__r.BillingPostalCode = mapCaseFilteredStr.get('ExpBillingPostalCode');
                log.Nob_WorkOrder__r.Case.Expert__r.BillingCity = mapCaseFilteredStr.get('ExpBillingCity');
                log.Nob_WorkOrder__r.Case.Expert__r.BillingCountryCode = mapCaseFilteredStr.get('ExpBillingCountryCode');
                log.Nob_WorkOrder__r.Case.Expert__r.BillingCountry = mapCaseFilteredStr.get('ExpBillingCountry');
            } else {
                ca.Expert__r.BillingStreet = mapCaseFilteredStr.get('ExpBillingStreet');
                ca.Expert__r.BillingPostalCode = mapCaseFilteredStr.get('ExpBillingPostalCode');
                ca.Expert__r.BillingCity = mapCaseFilteredStr.get('ExpBillingCity');
                ca.Expert__r.BillingCountryCode = mapCaseFilteredStr.get('ExpBillingCountryCode');
                ca.Expert__r.BillingCountry = mapCaseFilteredStr.get('ExpBillingCountry');

                //GBH   15/12/2021      RSIW-11277: Prendre en compte les espaces à la fin d'un numéro téléphonique
                ca.Expert__r.Phone = mapCaseFilteredPhone.get('Expert__r.Phone');
            }
        }
        
        //////////////////////////////////


        //NOB_Planning__c planning = ca.NOB_TECH_DispoId__r;
        NOB_Planning__c planning=null;
        
        //rsiw - 7629
        WorkOrder workorder = log.NOB_WorkOrder__r;
        WorkOrder wo;
        if(!hasWO){
            List<WorkOrder> wos  = [SELECT Id, CaseId, NOB_TECH_CourtesyCarNeedeForInsurer__c, 
                                    
                                    
                                    NOB_Reparateur__r.Name,
                                    NOB_Reparateur__r.Phone,
                                    NOB_Reparateur__r.NOB_EmailAddress__c,
                                    NOB_Reparateur__r.NOB_DarvaIdentifier__c,
                                    NOB_Reparateur__r.BillingStreet,
                                    NOB_Reparateur__r.BillingPostalCode,
                                    NOB_Reparateur__r.BillingCity,
                                    NOB_Reparateur__r.BillingCountryCode,
                                    NOB_Reparateur__r.BillingCountry ,
                                    NOB_Reparateur__r.NOB_NetworkCategory__c,
                                    NOB_Reparateur__r.NOB_NetworkType__c,
                                    
                                    NOB_NegoRate__r.NOB_DSP__c, 
                                    NOB_NegoRate__r.NOB_T1__c, 
                                    NOB_NegoRate__r.NOB_T2__c, 
                                    NOB_NegoRate__r.NOB_T3__c, 
                                    NOB_NegoRate__r.NOB_TauxMecanique__c, 
                                    NOB_NegoRate__r.NOB_TI1__c, 
                                    NOB_NegoRate__r.NOB_TI2__c, 
                                    NOB_NegoRate__r.NOB_TI3__c, 
                                    NOB_NegoRate__r.NOB_TP__c
                                    
                                    FROM WorkOrder WHERE CaseId =: caseId ORDER BY CreatedDate DESC];
            if(wos.size() >0){
                wo = wos.get(0);
            } 
        } 
        
        NOB_Planning__c tmp=null;
        if (!hasWO) {
            workorder = wo;
        } else{
            workorder = log.NOB_WorkOrder__r;
            system.debug('else' + workorder);
        }
        tmp = workorder!=null ? getPlanning(workorder.Id) : null;
        if(tmp != null){
            planning = tmp;
        }
        
        
        if(workorder == null){
            if(planning != null){
                workorder = planning.NOB_WorkOrder__r;
            }
        }
        system.debug('out' + workorder);

        //GBH   07/06/2021
        if(planning != null){
            Map <String,String> mapPlanningStr = new Map <String,String>();
            

            mapPlanningStr.put('WOBSBillingStreet',planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet);
            mapPlanningStr.put('WOBSBillingCity',planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity);
            mapPlanningStr.put('WOBSBillingCountry',planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry);

            
            Map <String,String> lstPlanningFilteredStr = NOBTools.removeSpecialChar(mapPlanningStr);
            if(planning.NOB_WorkOrder__c!=null && planning.NOB_WorkOrder__r.NOB_Reparateur__c!=null){
                planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet =lstPlanningFilteredStr.get('WOBSBillingStreet');
                planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity  =lstPlanningFilteredStr.get('WOBSBillingCity');
                planning.NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry   =lstPlanningFilteredStr.get('WOBSBillingCountry');
            }
        }
        
        if(workorder!=null && workorder.NOB_Reparateur__c!=null){
            Map <String,String> mapWOStr = new Map <String,String>();
            mapWOStr.put('REPBillingStreet',workorder.NOB_Reparateur__r.BillingStreet);
            mapWOStr.put('REPBillingPostalCode',workorder.NOB_Reparateur__r.BillingPostalCode);
            mapWOStr.put('REPBillingCity',workorder.NOB_Reparateur__r.BillingCity);
            mapWOStr.put('REPBillingCountryCode',workorder.NOB_Reparateur__r.BillingCountryCode);
            mapWOStr.put('REPBillingCountry',workorder.NOB_Reparateur__r.BillingCountry);
            
            Map <String,String> lstWOFilteredStr = NOBTools.removeSpecialChar(mapWOStr);
            workorder.NOB_Reparateur__r.BillingStreet = lstWOFilteredStr.get('REPBillingStreet');
            workorder.NOB_Reparateur__r.BillingPostalCode = lstWOFilteredStr.get('REPBillingPostalCode');
            workorder.NOB_Reparateur__r.BillingCity = lstWOFilteredStr.get('REPBillingCity');
            workorder.NOB_Reparateur__r.BillingCountryCode = lstWOFilteredStr.get('REPBillingCountryCode');
            workorder.NOB_Reparateur__r.BillingCountry = lstWOFilteredStr.get('REPBillingCountry');
        }
        
        //////////////////////


        Map<String,Object> mapCase = new Map<String,Object>();
        
        mapCase.put('Id', ca.Id);
        if (hasWO) {
            mapCase.put('NOB_ScenarioCode__c', checkNull(log.Nob_WorkOrder__r.NOB_ScenarioCode__c));
            mapCase.put('NOB_InsurerClaimNumber__c',checkNull(log.Nob_WorkOrder__r.NOB_InsurerClaimNumber__c));
            mapCase.put('TECH_EngineerClaimNR__c', checkNull(log.Nob_WorkOrder__r.PFR_TECH_EngineerClaimNR__c));
            mapCase.put('Contact', buildContact(ca.Contact));
            mapCase.put('WorkOrder', buildWorkOrder(workorder));
            mapCase.put('NOB_BodyShop__r', buildAccount(((log.Nob_WorkOrder__c!=null && workorder.NOB_Reparateur__c!=null)? log.Nob_WorkOrder__r.NOB_Reparateur__r : ca.NOB_BodyShop__r)));
            mapCase.put('NOB_Expert__r', buildAccount(ca.Expert__r));
            if(planning != null)
        	    mapCase.put('NOB_TECH_DispoId__r', buildDispo(planning));
            mapCase.put('NOB_BusinessProvider__r', buildBusinessProvider(log.Nob_WorkOrder__r.NOB_BusinessProvider__r));
        } else {
            mapCase.put('NOB_ScenarioCode__c', checkNull(ca.NOB_ScenarioCode__c));
            mapCase.put('NOB_InsurerClaimNumber__c',checkNull( ca.NOB_InsurerClaimNumber__c));
            mapCase.put('TECH_EngineerClaimNR__c', checkNull(ca.PFR_TECH_EngineerClaimNR__c));
            mapCase.put('Contact', buildContact(ca.Contact));
            if(workorder != null)
        	    mapCase.put('WorkOrder', buildWorkOrder(workorder));
            mapCase.put('NOB_BodyShop__r', buildAccount(((ca.NOB_BodyShop__c==null && workorder!=null && workorder.NOB_Reparateur__c!=null)? workorder.NOB_Reparateur__r : ca.NOB_BodyShop__r)));//WCH 09/06/2021 RSIW-9897
            mapCase.put('NOB_Expert__r', buildAccount(ca.Expert__r));
            if(planning != null)
        	    mapCase.put('NOB_TECH_DispoId__r', buildDispo(planning));
            mapCase.put('NOB_BusinessProvider__r', buildBusinessProvider(ca.NOB_BusinessProvider__r));
        }

        mapCase.put('Comment', getComment(ca));
        mapCase.put('NetworkCategory', getNetworkCategory(ca));
        if(workorder != null)
			mapCase.put('NOB_TauxNeg__r', buildNegRates(workorder.NOB_NegoRate__r));
        mapCase.put('NOB_MessageSubType__c', messageSubType);
		mapCase.put('PFR_Coverage__c',checkNull( ca.PFR_Coverage__c));

        
        if(workorder != null){
            Id currentWOId =  workorder.Id;//planning.NOB_WorkOrder__c;
            Account previousBodyShop = getPreviousBodyshop(ca.Id, currentWOId,ca.PFR_TECH_EngineerClaimNR__c);
            if(previousBodyShop != null && previousBodyShop.Id != ca.NOB_BodyShop__c){
                mapCase.put('PreviousBodyshop', buildAccount(previousBodyShop));
            }
        }

        List<NOB_DARVA_Tag__c> tags = [SELECT Id, NOB_Valeur__c, NOB_TAGLVL2__c,NOB_TAGLVL1__c ,NOB_CaseID__c,PFR_ParentTagOccurence__c, 
                                       PFR_ParentTag__c, NOB_Occurrence_number__c FROM NOB_DARVA_Tag__c WHERE NOB_CaseID__c=: ca.Id  ];

        List<Map<String,Object>> rtags = new List<Map<String,Object>>();
        for(NOB_DARVA_Tag__c tag : tags){
            rtags.add(buildTag(tag));
        }
        
        mapCase.put('TagTable', rtags);

        //GBH   RSIW-10652  08.09.2021  SD36/37 integration - Add Invoice to JSON request.
        if ((log.NOB_MessageType__c == 'SD36' || log.NOB_MessageType__c == 'SD37') && log.Document_Financier__c != null) {
            PFR_FinancialDocument__c docFin = log.Document_Financier__r;
            mapCase.put('Invoice', docFin != null? buildInvoice(docFin, log) : null);
        }
        //

        return mapCase;
        
    }
    
    
    private static NOB_Planning__c getPlanning(Id workorderId){
        List<NOB_Planning__c> plannings =  [SELECT Id, 
                   NOB_StartDate__c,
                   NOB_WorkOrder__c,
                   NOB_WorkOrder__r.NOB_TECH_CourtesyCarNeedeForInsurer__c,
                   NOB_WorkOrder__r.NOB_Reparateur__c,
                   //negorate

                   NOB_WorkOrder__r.NOB_Reparateur__r.Name,
				   NOB_WorkOrder__r.NOB_Reparateur__r.Phone,
                   NOB_WorkOrder__r.NOB_Reparateur__r.NOB_EmailAddress__c,
                   NOB_WorkOrder__r.NOB_Reparateur__r.NOB_DarvaIdentifier__c,
                   NOB_WorkOrder__r.NOB_Reparateur__r.BillingStreet,
                   NOB_WorkOrder__r.NOB_Reparateur__r.BillingPostalCode,
                   NOB_WorkOrder__r.NOB_Reparateur__r.BillingCity,
                   NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountryCode,
                   NOB_WorkOrder__r.NOB_Reparateur__r.BillingCountry ,
                   NOB_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkCategory__c,
                   NOB_WorkOrder__r.NOB_Reparateur__r.NOB_NetworkType__c,

				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_DSP__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T1__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T2__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_T3__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TauxMecanique__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI1__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI2__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TI3__c, 
				   NOB_WorkOrder__r.NOB_NegoRate__r.NOB_TP__c 
                                            FROM NOB_Planning__c WHERE NOB_WorkOrder__c =:workorderId];
        
        if(plannings.size() > 0){
            return plannings.get(0);
        }
        return null;
    }
    
    
    public static Map<String,Object> buildTag(NOB_DARVA_Tag__c tag){
        Map<String,Object> rs = new Map<String,Object>();
        if(tag != null){
            rs.put('NOB_Valeur__c', checkNull(tag.NOB_Valeur__c));
            rs.put('NOB_TAGLVL2__c', checkNull(tag.NOB_TAGLVL2__c));
            rs.put('NOB_TAGLVL1__c', checkNull(tag.NOB_TAGLVL1__c));
            rs.put('NOB_CaseID__c', tag.NOB_CaseID__c);
            rs.put('PFR_ParentTagOccurence__c', checkNull(tag.PFR_ParentTagOccurence__c));
            rs.put('PFR_ParentTag__c', checkNull(tag.PFR_ParentTag__c));
            rs.put('NOB_Occurrence_number__c', checkNull(tag.NOB_Occurrence_number__c));
        }
        return rs;
    }
    
    public static Map<String,Object> buildDispo(NOB_Planning__c planning){
        
        Map<String,Object> result = new Map<String,Object>();
        if(planning != null){
            result.put('NOB_StartDate__c', planning.NOB_StartDate__c);
        }
        return result;
    }
    
    private static Map<String,Object> buildBusinessProvider(Account keyaccount){
        
        Map<String,Object> result = new Map<String,Object>();
        if(keyaccount != null){
            result.put('NOB_DarvaIdentifier__c', keyaccount.NOB_DarvaIdentifier__c);
        }
        return result;
    }    
    
    private static Map<String,Object> buildContact(Contact cont){
        //WCH 22/07/2021 RSIW-10426
        Map <String,String> mapContactStr = new Map <String,String>();
        Map<String,String> mapContactFilteredStr = new Map <String,String>();
        if(cont!=null && !String.isBlank(cont.Name)) mapContactStr.put('ContactName',cont.Name);
        if(!mapContactStr.isEmpty()) mapContactFilteredStr=NOBTools.removeSpecialChar(mapContactStr);

        Map<String,Object> mapCont = new Map<String,Object>();
        
        if(cont != null){
            mapCont.put('TITLE', checkNull(cont.Title));
            mapCont.put('NAME', mapContactFilteredStr.containsKey('ContactName')?mapContactFilteredStr.get('ContactName'):checkNull(cont.Name));
            mapCont.put('OtherStreet', checkNull(cont.MailingStreet));
            mapCont.put('OtherPostalcode', checkNull(cont.MailingPostalCode));
            mapCont.put('OtherCity', checkNull(cont.MailingCity));
            mapCont.put('OtherCountry', checkNull(cont.MailingCountry));
            mapCont.put('OtherCountryCode', checkNull(cont.MailingCountryCode));
            mapCont.put('NOB_InsuredTVAEligible__c', cont.NOB_InsuredtTVASubject__c);
            mapCont.put('OtherPhone', checkNull(cont.Phone));
            mapCont.put('Email', checkNull(cont.Email));
            mapCont.put('FAX', '');
            mapCont.put('MobilePhone', checkNull(cont.MobilePhone));
            mapCont.put('Phone',checkNull( cont.Phone));
        }
        return mapCont;
    }

    private static String checkNull(String s){
        if(s == null){
            return '';
        }
        return s;
    }
    
    private static decimal checkNull(decimal d){
        if(d == null){
            return 0;
        }
        return d;
    }
    
    public static String getNetworkCategory(Case ca){
        //NOB_BodyShop__r.NOB_NetworkType__c,
                   //NOB_BodyShop__r.NOB_Statut__c
        if(ca.NOB_BodyShop__r != null){
            return ca.NOB_BodyShop__r.NOB_NetworkCategory__c;
            /*if(ca.NOB_BodyShop__r.NOB_NetworkType__c != 'Hors réseau' && ca.NOB_BodyShop__r.NOB_Statut__c== 'Actif'){
                return 'PRE';
            }*/
        }
        return '';
    }
    
    public static Map<String,Object> buildWorkOrder(WorkOrder wo){
        
        Map<String,Object> mapCont = new Map<String,Object>();
        if(wo != null){
            mapCont.put('NOB_TECH_CourtesyCarNeedeForInsurer__c', wo.NOB_TECH_CourtesyCarNeedeForInsurer__c);
            mapCont.put('NOB_Reparateur__c', buildAccount(wo.NOB_Reparateur__r));
        }
        return mapCont;
    }
    
    public static Map<String,Object> buildDocumentFinanciers(Id CaseId){
        
        List<PFR_FinancialDocument__c> docs = [SELECT Id, 
                                               PFR_ExclVATTotalAmount__c,
                                               PFR_VATAmount__c,
                                               PFR_InclVATTotalAmount__c,
                                               PFR_DSPExclVATTotalAmount__c,
                                               PFR_PaintExclVATTotalAmount__c,
                                               PFR_T1LowLabourExclVATTotalAmount__c,
                                               PFR_T2MiddleLabourExclVATTotalAmount__c,
                                               PFR_T3HighLabourExclVATTotalAmount__c,
                                               PFR_PartsExclVATSubTotalAmount__c,
                                               PFR_SuppliesExclVATSubTotalAmount__c,
                                               PFR_SGCExclVATSubTotalAmount__c
                                               FROM PFR_FinancialDocument__c WHERE PFR_Case__c=: caseId AND RecordType.DeveloperName ='CH' ORDER BY CreatedDate DESC];
        
        
        if(docs.size() > 0){
            PFR_FinancialDocument__c doc = docs.get(0);
            Map<String,Object> mp = buildDocumentFinancier(doc);
            return mp;
        }
        return new Map<String,Object>();
        //return result;
    }
    
    public static Map<String,Object> buildDocumentFinancier(PFR_FinancialDocument__c doc){
        Map<String,Object> result = new Map<String,Object>();
        
        Integer varVATrate = 0;
        if  (doc.PFR_ExclVATTotalAmount__c != 0){
        	varVATrate = math.round(doc.PFR_VATAmount__c/doc.PFR_ExclVATTotalAmount__c*10000);
        }
        
        result.put('PFR_ExclVATTotalAmount__c', doc.PFR_ExclVATTotalAmount__c);
        result.put('PFR_VATAmount__c',doc.PFR_VATAmount__c);
        result.put('PFR_VATRate__c',varVATrate);
        result.put('PFR_InclVATTotalAmount__c', doc.PFR_InclVATTotalAmount__c);
        result.put('PFR_DSPExclVATTotalAmount__c', doc.PFR_DSPExclVATTotalAmount__c);
        result.put('PFR_PaintExclVATTotalAmount__c', doc.PFR_PaintExclVATTotalAmount__c);
        result.put('PFR_T1LowLabourExclVATTotalAmount__c', doc.PFR_T1LowLabourExclVATTotalAmount__c);
        result.put('PFR_T2MiddleLabourExclVATTotalAmount__c', doc.PFR_T2MiddleLabourExclVATTotalAmount__c);
        result.put('PFR_T3HighLabourExclVATTotalAmount__c', doc.PFR_T3HighLabourExclVATTotalAmount__c);
        result.put('PFR_PartsExclVATSubTotalAmount__c', doc.PFR_PartsExclVATSubTotalAmount__c);
        result.put('PFR_SuppliesExclVATSubTotalAmount__c', doc.PFR_SuppliesExclVATSubTotalAmount__c);
        result.put('PFR_SGCExclVATSubTotalAmount__c', doc.PFR_SGCExclVATSubTotalAmount__c);
        return result;
    }
    
    private static Map<String,Object> buildAccount(Account acc){
        //WCH 22/07/2021 RSIW-10426
        Map <String,String> mapAccStr = new Map <String,String>();
        Map<String,String> mapAccFilteredStr = new Map <String,String>();
        if(acc!=null && !String.isBlank(acc.Name)) mapAccStr.put('AccountName',acc.Name);
        if(!mapAccStr.isEmpty()) mapAccFilteredStr=NOBTools.removeSpecialChar(mapAccStr);

        Map<String,Object> mapCont = new Map<String,Object>();
        if(acc != null){
            mapCont.put('Name', mapAccFilteredStr.containsKey('AccountName')?mapAccFilteredStr.get('AccountName'):checkNull(acc.Name));
            mapCont.put('PHONE',checkNull(acc.Phone));
            mapCont.put('FAX','');
            mapCont.put('NOB_EmailAddress__c',checkNull(acc.NOB_EmailAddress__c));
            mapCont.put('NOB_DarvaIdentifier__c',checkNull(acc.NOB_DarvaIdentifier__c));
            mapCont.put('ShippingStreet',checkNull(acc.BillingStreet));
            mapCont.put('ShippingPostalcode',checkNull(acc.BillingPostalCode));
            mapCont.put('ShippingCity',checkNull(acc.BillingCity));
            mapCont.put('ShippingCountryCode',checkNull(acc.BillingCountryCode));
            mapCont.put('ShippingCountry',checkNull(acc.BillingCountry));
        }
        return mapCont;
    }

    public static Map<String,Object> buildNegRates(NOB_TauxNeg__c negrates){
		Map<String,Object> mapRate = new Map<String,Object>();
		if(negrates != null){
			mapRate.put('NOB_DSP__c',negrates.NOB_DSP__c);
			mapRate.put('NOB_T1__c',negrates.NOB_T1__c);
			mapRate.put('NOB_T2__c',negrates.NOB_T2__c);
			mapRate.put('NOB_T3__c',negrates.NOB_T3__c);
			mapRate.put('NOB_TauxMecanique__c',negrates.NOB_TauxMecanique__c);
			mapRate.put('NOB_TI1__c',negrates.NOB_TI1__c);
			mapRate.put('NOB_TI2__c',negrates.NOB_TI2__c);
			mapRate.put('NOB_TI3__c',negrates.NOB_TI3__c);
			mapRate.put('NOB_TP__c',negrates.NOB_TP__c);
		}
		return mapRate;
	}

    //GBH   RSIW-10652  02/08/2021
    private static Map<String,Object> buildInvoice(PFR_FinancialDocument__c docFin, NOB_DarvaMessageLog__c log){
        Map <String, Object> mapInvoice = new Map <String, Object>();

        String invType = '';
        String invNumber = '';
        if (docFin.recordType.DeveloperName == 'FR') {
            invType = '1';
            invNumber = docFin.PFR_RepairInvoiceNumber__c;
        } else if (docFin.recordType.DeveloperName == 'AV') {
            invType = '2';
            invNumber = docFin.PFR_CreditNumber__c;
        }
        if (docFin != null) {
            if (log.NOB_MessageType__c == 'SD37') {
                mapInvoice.put('InvoiceRejectReason', docFin.PFR_StatusReason__c);
            }
            mapInvoice.put('InvoiceSentTime', '12:00:00');
            mapInvoice.put('InvoiceSentDt', docFin.PFR_FinDocDateOfIssue__c);
            mapInvoice.put('InvoiceNumber', invNumber);
            mapInvoice.put('InvoiceType', invType);
        }

        return mapInvoice;
    }
    
}