/**
 * @File Name          : NOB_PlanningTriggerHandler.apxc
 * @Description        : NOB_PlanningTrigger's Handler
 * @Author             : Spoon
 * @Group              : 
 * @Last Modified By   : GBH
 * @Last Modified On   : 10-08-2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      Modification
 *==============================================================================
 * 1.0    30-JUL-2020                   Spoon      Initial Version
 * 1.1    28-OCT-2020                   HMO        Replacing static values from NOB_AP00_Constants and custom labels
 * 1.2    12-DEC-2020                   ARA        RSIW-5859
 * 1.3    08-JAN-2021                   KPA        RSIW-7209 - A la modification du ranking ou du taux annuel si gold le taux d'engagement doit être recalculé 
 * 1.4    23-APR-2021                   GBH        RSIW-9495 - Do not execute DoHandleIceandSMS if user is a Migration user
 * 1.5    10-JUN-2021                   GBH        RSIW-9793 - WorkOrder on Darva MSG Log
 * 1.6    30-JUL-2021                   GBH        RSIW-10410 - Block 'Email de confirmation' for direct planning - Send emails for 'SAD classique' only
 * 1.7    11 OCT 2021                   HMO        RSIW-10330 - RSIW - 10330 : Optimisation Code / Configuration suite aux limitations SF 100 querY
 * 1.8    02 MAR 2022                   HMO        RSIW - 10922
**/
public class NOB_PlanningTriggerHandler {
    private boolean bIsExecuting = false;
    private integer iBatchSize = 0;
    private static boolean hasRun = false;
    private String userProfileName = NOBTools.ProfileName();

    //HMO -- 11-10-2021 -- RSIW : 10330
    private static Boolean userTypeMigration = NOBTools.isMigrationUser();
    private static Boolean userTypeInterface = NOBTools.isInterfaceUser();
    
    public NOB_PlanningTriggerHandler (boolean isExecuting, integer size){
        bIsExecuting = isExecuting;
        iBatchSize = size;
    }
    
    public void onBeforeInsert(List<NOB_Planning__c> lstnewDispo){
        List<NOB_Planning__c> lstSemaineType = new List<NOB_Planning__c>();
        for(NOB_Planning__c newDispo : lstnewDispo){

            
            
            if(newDispo.NOB_StartDate__c !=null && newDispo.NOB_OriginalStartDate__c == null ){
                System.debug('check start date: ' + newDispo.NOB_StartDate__c);
                        newDispo.NOB_OriginalStartDate__c = newDispo.NOB_StartDate__c;
            }

            
            if(newDispo.NOB_EndDate__c !=null && newDispo.NOB_OriginalEndDate__c == null){
                newDispo.NOB_OriginalEndDate__c = newDispo.NOB_EndDate__c;
                System.debug(' check end date: ' + newDispo.NOB_EndDate__c);
            }
            
            
            if(newDispo.NOB_StartDate__c ==null || newDispo.NOB_EndDate__c ==null || !isTimeAllowed(newDispo.NOB_StartDate__c, newDispo.NOB_EndDate__c) ){
                newDispo.addError(System.label.NOB_Planning_Error_NoCreationEventBetween_21_to_6);
            }

            
             
            else{
                System.debug('Arrived 4:');
                if(newDispo.NOB_StartDate__c == newDispo.NOB_EndDate__c){
                    newDispo.addError(System.label.NOB_Planning_Error_SelectValidDateTime);
                }
                else if(newDispo.NOB_StartDate__c >= newDispo.NOB_EndDate__c){
                    newDispo.addError(System.label.NOB_Planning_Error_SelectValidDateTime);
                }else{
                    System.debug('Arrived 5:');
                    if(newDispo.NOB_IntegrerEnSemaineType__c){
                        System.debug('Arrived 6:');
                        System.debug('newDispo:' + newDispo);
                        if(newDispo.NOB_Status__c == 'Disponible' || newDispo.NOB_Status__c == 'Absence'){
                        	lstSemaineType.add(newDispo);
                        }else if(newDispo.NOB_Status__c == null){
                            newDispo.NOB_Status__c = 'Disponible';
                            lstSemaineType.add(newDispo);
                        }
                    }
                }
                
            }

        }
        
        System.debug('lstSemaineType:' + lstSemaineType);
        handleSemaineType(lstSemaineType);


    }
    
    //GBH 16.10.2020 - RSIW-1951
    public void onAfterInsert(List<NOB_Planning__c> lstnewDispo){
        System.debug('##### Start NOB_PlanningTriggerHandler.onAfterInsert ####');
        //BBH 18/12/2020 - RSIW 5859 - status reservé should increment mission affectées
        set<Id> setReparateurId = new set<Id>();
        set<Id> setReparateurId2 = new set<Id>();
		 List<NOB_Planning__c> reservedPlan = new List<NOB_Planning__c>();
         map<Id,NOB_Planning__c> mapWOIdPlanning = new map<Id,NOB_Planning__c>();
        for(Integer i=0; i< lstnewDispo.size(); i++){
            if(lstnewDispo[i].NOB_BodyShop__c != null && 
               lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()){
          
           		setReparateurId.add(lstnewDispo[i].NOB_BodyShop__c);
            }

            if(lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE &&
                    lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()){
                setReparateurId2.add(lstnewDispo[i].NOB_BodyShop__c);
              	reservedPlan.add(lstnewDispo[i]);
                        If(lstnewDispo[i].NOB_WorkOrder__c != null){
                            mapWOIdPlanning.put(lstnewDispo[i].NOB_WorkOrder__c,lstnewDispo[i]);
					}
                
            }
            
        }
               
        if(setReparateurId.size() > 0){
        //KPA 08/01/2021 - RSIW-7209
           NOB_AP60_DispoEntreesCal.updateDispo(setReparateurId);
        }
        if(setReparateurId2.size() > 0){
       //KPA 08/01/2021 - RSIW-7209
            NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve(setReparateurId);
        }
        
        doHandleICEAndSMS(reservedPlan);
        system.debug('## hasRun ' + hasRun);
        /*if(!hasRun){
        	EnvoieMailDeConfirmation(mapWOIdPlanning); 
        }*/
		System.debug('##### End NOB_PlanningTriggerHandler.onAfterInsert ####');            
    }
               
    public void onBeforeUpdate(List<NOB_Planning__c> lstnewDispo, List<NOB_Planning__c> lstOldDispo){

        Integer index = 0;
        List<NOB_Planning__c> lstSemaineType = new List<NOB_Planning__c>();
        for(NOB_Planning__c newDispo : lstnewDispo){
            if(!isTimeAllowed(newDispo.NOB_StartDate__c, newDispo.NOB_EndDate__c)){
                newDispo.addError(System.label.NOB_Planning_Error_NoCreationEventBetween_21_to_6);
            }
            else{
                if(newDispo.NOB_StartDate__c == newDispo.NOB_EndDate__c){
                    newDispo.addError(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin);
                }
                else if(newDispo.NOB_StartDate__c >= newDispo.NOB_EndDate__c){
                    newDispo.addError(System.label.NOB_Planning_Error_DateDebut_GreaterThan_DateFin);
                }else{
                    NOB_Planning__c oldDispo = lstOldDispo.get(index);
                    if(oldDispo.NOB_Status__c == 'Disponible' && newDispo.NOB_Status__c == 'Réservé'){
                        newDispo.NOB_OriginalStartDate__c = oldDispo.NOB_StartDate__c;
                        newDispo.NOB_OriginalEndDate__c = oldDispo.NOB_EndDate__c;
                    }
                    
                    
                    if(newDispo.NOB_IntegrerEnSemaineType__c && !oldDispo.NOB_IntegrerEnSemaineType__c && !newDispo.NOB_DeSemaineType__c){
                        System.debug('Arrived 6:');
                        System.debug('newDispo:' + newDispo);
                        
                        if(newDispo.NOB_Status__c == 'Disponible' || newDispo.NOB_Status__c == 'Absence'){
                        	lstSemaineType.add(newDispo);
                        }else if(newDispo.NOB_Status__c == null){
                            newDispo.NOB_Status__c = 'Disponible';
                            lstSemaineType.add(newDispo);
                        }
                    }
                }
                
                
                
                
            }
            index++;
        }
        
        if(lstSemaineType.size() > 0){
         	System.debug('lstSemaineType:' + lstSemaineType);
        	handleSemaineType(lstSemaineType);
        }
      
    }

    public void onAfterUpdate(List<NOB_Planning__c> lstoldDispo, List<NOB_Planning__c> lstnewDispo, Map<Id,NOB_Planning__c> mapOld){
        System.debug('##### Start NOB_PlanningTriggerHandler.onAfterUpdate ####');
         
        set<Id> setReparateurId = new set<Id>();
        list<Id> listWoId = new list<Id>();

        //BBH 18/12/2020 - RSIW 5859 - change on bodyshop detected on update also
        set<Id> setReparateurId2 = new set<Id>();
        List<NOB_Planning__c> reservedPlan = new List<NOB_Planning__c>();
        map<Id,NOB_Planning__c> mapWOIdPlanning = new map<Id,NOB_Planning__c>();
        for(Integer i=0; i< lstnewDispo.size(); i++){
            System.debug('lstOldDispo'+ lstoldDispo);
            System.debug('lstNewDispo'+ lstnewDispo);
            if(lstoldDispo[i].NOB_Status__c != lstnewDispo[i].NOB_Status__c &&
               (lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE ||
                lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_ANNULE) &&
                lstnewDispo[i].NOB_BodyShop__c != null &&
                lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()){
                setReparateurId.add(lstoldDispo[i].NOB_BodyShop__c);
            }

            if(((lstnewDispo[i].NOB_BodyShop__c != null && lstoldDispo[i].NOB_BodyShop__c != lstnewDispo[i].NOB_BodyShop__c) ||
                (lstnewDispo[i].IsDelete__c == true && lstoldDispo[i].IsDelete__c != lstnewDispo[i].IsDelete__c)) &&
                lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()){
                setReparateurId2.add(lstnewDispo[i].NOB_BodyShop__c);
            }
            
            if(
                ((lstoldDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE || lstoldDispo[i].NOB_Status__c == null)  ||
                (lstoldDispo[i].NOB_WorkOrder__c == null && lstnewDispo[i].NOB_WorkOrder__c != null))  &&
                lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE &&
                lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()
            ){
                System.debug('entered here0000000000>>>>>');
                reservedPlan.add(lstnewDispo[i]);
                
                If(lstnewDispo[i].NOB_WorkOrder__c != null){
                            mapWOIdPlanning.put(lstnewDispo[i].NOB_WorkOrder__c,lstnewDispo[i]);
					}
            }
            
/* RSIW-009304, pas de traitement particulier en cas de changement de WO et pour éviter les doublons on garde uniquement le test précedent
            if(lstoldDispo[i].NOB_WorkOrder__c != lstnewDispo[i].NOB_WorkOrder__c &&
              	lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE &&
               lstnewDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()
              ){
                  reservedPlan.add(lstnewDispo[i]);
              }
*/
            //DUN 06/04/2020 RSIW 9176
            if(
                lstoldDispo[i].NOB_Status__c != lstnewDispo[i].NOB_Status__c &&
                lstnewDispo[i].NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE &&
                lstoldDispo[i].NOB_WorkOrder__c != null &&
                /*!NOBTools.isMigrationUser*/ !userTypeMigration
            ){
                System.debug('## planning reserve');
                listWoId.add(lstoldDispo[i].NOB_WorkOrder__c);
            }
        }
        System.debug('£££ lstReparateurReserve'+ setReparateurId);
        if(setReparateurId.size() > 0){
       //KPA 08/01/2021 - RSIW-7209
            NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve(setReparateurId);
        }
        System.debug('£££ lstReparateurDispo'+ setReparateurId2);
        if(setReparateurId2.size() > 0){
        //KPA 08/01/2021 - RSIW-7209
            NOB_AP60_DispoEntreesCal.updateDispo(setReparateurId2);
        }
        
        doHandleICEAndSMS(reservedPlan);
        
        system.debug('## hasRun ' + hasRun);
        /*if(!hasRun){
         EnvoieMailDeConfirmation(mapWOIdPlanning); 
        }*/
        
        if(listWoId.size() > 0){
            createSMSLog(listWoId);
        }
        System.debug('##### End NOB_PlanningTriggerHandler.onAfterUpdate ####');
    }
    
    public void createSMSLog(List<Id> ListWoId){
        /*List<NOB_SMSLog__c> smsLogs = new List<NOB_SMSLog__c>();
        for(WorkOrder wo : [SELECT Id, CaseId, Case.NOB_TECH_IsAXAorDA__c, Case.ContactId FROM WorkOrder WHERE Id IN: ListWoId]){
            NOB_SMSLog__c sms = new NOB_SMSLog__c();
            sms.NOB_Case__c = wo.CaseId;
            sms.NOB_Contact__c =  wo.Case.ContactId;
            sms.NOB_Statut__c = 'To be send';
            sms.NOB_Subject__c = 'Etape_3';
            smsLogs.add(sms);
        }
        
        system.debug('## smsLogs: '+smsLogs);
        if(smsLogs.size()>0) {
            insert smsLogs;
        }*/
    }

    public static void EnvoieMailDeConfirmation(map<Id,NOB_Planning__c> mapWOIdPlanning){
        system.debug('## Start EnvoieMailDeConfirmation');
        
        List<WorkOrder> ListWO = [select Id,
                                        /*RSIW 10922 -- NOB_Tech_BodyshopBillingAddress__c,*/ 
                                        PFR_TECH_Planning_StartDate__c,
                                        PFR_TECH_Planning_EndDate__c,
                                        NOB_TECH_AssureMailingAddress__c,
                                        NOB_BusinessProvider__r.Name,
                                        NOB_Reparateur__r.Name,
                                        NOB_Reparateur__r.Phone, 
                                        NOB_ContactPickup__c, 
                                        Case.NOB_ContactPickup__c,
                                        NOB_BusinessProvider__r.NOB_SiretHeadquarters__c,
                                        Case.NOB_ContactPickup__r.Email,
                                        NOB_TECH_ConducteurMailingAddress__c 
                                    FROM WorkOrder 
                                    WHERE Id IN: mapWOIdPlanning.keySet()];
        system.debug('## ListWO '+ListWO);
        try {
            System.debug('##try: ');   
            if(ListWO.size() > 0){

                //HMO -- 24-02-22 -- RSIW 10922
                String devName = 'NOB_refonteMailAffectation';
                EmailTemplate et = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName(devName);
                /*EmailTemplate et=[SELECT Subject, Body, HtmlValue, Markup, TemplateType FROM EmailTemplate where DeveloperName='NOB_refonteMailAffectation'];*/
                    
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'SAD'];
                for(WorkOrder WO: listWO){ 
                    system.debug('## mapWOIdPlanning.get(WO.Id) '+mapWOIdPlanning.get(WO.Id));
                    if(mapWOIdPlanning.containsKey(WO.Id) && 
                       mapWOIdPlanning.get(WO.Id).NOB_StartDate__c != null && 
                       mapWOIdPlanning.get(WO.Id).NOB_EndDate__c != null && 
                       WO.Case.NOB_ContactPickup__c != null &&
                       WO.Case.NOB_ContactPickup__r.Email != null){
                       
                        String htmlBody = et.Markup;
                        
                        String WOId= WO.Id;
                        String GarageName= WO.NOB_Reparateur__r.Name;
                        
                        String StartDate = mapWOIdPlanning.get(WO.Id).NOB_StartDate__c.format('dd/MM/yyyy');
                        System.debug('## StartDate: '+StartDate);
                        
                        String startTimeCal= mapWOIdPlanning.get(WO.Id).NOB_StartDate__c.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                        String EndTimeCal = mapWOIdPlanning.get(WO.Id).NOB_EndDate__c.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
                        
                        //WCH 05/10/2021 RSIW-11001
                        DateTime StTime= NOBTools.convertTimeToOtherTimeZone(mapWOIdPlanning.get(WO.Id).NOB_StartDate__c, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());
                        DateTime EndTimez= NOBTools.convertTimeToOtherTimeZone(mapWOIdPlanning.get(WO.Id).NOB_EndDate__c, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());
                        
                        String StartTime = dateTimeToString(StTime);
                        
                        String EndTime = dateTimeToString(EndTimez);
                        System.debug('## EndTime: '+EndTime);
                        
                        
                        
                        htmlBody = htmlBody.replace('<apex:outputText value=\"{0, date,d/MM/yyyy}\"><apex:param value=\"{!relatedTo.PFR_TECH_Planning_StartDate__c}\" /></apex:outputText>', StartDate);
                        htmlBody = htmlBody.replace('<apex:outputText value=\"{0, date,HH\'H\'mm}\"><apex:param value=\"{!relatedTo.PFR_TECH_Planning_StartDate__c}\" /></apex:outputText>',StartTime);
                        htmlBody = htmlBody.replace('<apex:outputText value=\"{0, date,HH\'H\'mm}\"><apex:param value=\"{!relatedTo.PFR_TECH_Planning_EndDate__c}\"/></apex:outputText>', EndTime);
                        htmlBody = htmlBody.replace('{!relatedTo.NOB_TECH_AssureMailingAddress__c}', WO.NOB_TECH_ConducteurMailingAddress__c);
                        htmlBody=  htmlBody.replace('{!relatedTo.NOB_Reparateur__r.Name}',WO.NOB_Reparateur__r.Name);
                        htmlBody=  htmlBody.replace('{!relatedTo.NOB_Reparateur__r.Phone}',WO.NOB_Reparateur__r.Phone);

                        //HMO -- 24-02-2022 -- RSIW 10922
                        //htmlBody=  htmlBody.replace('{!relatedTo.NOB_Tech_BodyshopBillingAddress__c}',WO.NOB_Tech_BodyshopBillingAddress__c);
                           
                        System.debug('##WO.NOB_BusinessProvider__r.Name: '+WO.NOB_BusinessProvider__r.Name);                   
                        if(WO.NOB_BusinessProvider__r.Name != null && WO.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c.Contains(System.Label.PFR_SiretAXA)){
                            htmlBody=htmlBody.replace('<apex:outputtext rendered=\"{!IF(CONTAINS(relatedTo.NOB_BusinessProvider__r.Name, \"AXA\"), true, false)}\"> {!$Label.NOB_AXAPhone} </apex:outputtext><apex:outputtext rendered=\"{!IF(CONTAINS(relatedTo.NOB_BusinessProvider__r.Name, \"Direct Assurance\"), true, false)}\"> {!$Label.NOB_ADFPhone} </apex:outputtext>',System.Label.NOB_AXAPhone);
                        }
                        else if(WO.NOB_BusinessProvider__r.Name != null && WO.NOB_BusinessProvider__r.NOB_SiretHeadquarters__c.Contains(System.Label.PFR_SiretDirectAssurance)){
                            htmlBody=htmlBody.replace('<apex:outputtext rendered=\"{!IF(CONTAINS(relatedTo.NOB_BusinessProvider__r.Name, \"AXA\"), true, false)}\"> {!$Label.NOB_AXAPhone} </apex:outputtext><apex:outputtext rendered=\"{!IF(CONTAINS(relatedTo.NOB_BusinessProvider__r.Name, \"Direct Assurance\"), true, false)}\"> {!$Label.NOB_ADFPhone} </apex:outputtext>',System.Label.NOB_ADFPhone);
                        }
                        
                        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(WO.Case.NOB_ContactPickup__c);
                        //mail.setSenderDisplayName('SAD');
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        mail.setSubject('Confirmation de votre RDV de réparation');
                        mail.setSaveAsActivity(true);
                        mail.setHtmlBody(htmlBody);
                        
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment(); 
                        attach.filename = 'votrerdvserviceautoadomicile.ics'; 
                        attach.ContentType = 'text/calendar; charset=utf-8; method=PUBLISH';
                        attach.inline = true; 
                        attach.body = invite(WOId, startTimeCal, EndTimeCal,GarageName); 
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                        
                        mails.add(mail);
                        
                        
                        if(mails.size() > 0 ) {
                            Messaging.sendEmail(mails, true);
                        } 
                    }
                }
            }
        
        } catch (EmailException e) { 
            Utils_ManageLogs.NOBCreateLogFromException('NOB_PlanningTriggerHandler', 'Work Order', e, (ListWO.size()>0?ListWO[0].Id:null));   
        }
        
    }
    
    public static Blob invite(String WOId , String startTime, String EndTime ,String GarageName){

	String txtInvite='';
	
	txtInvite +=  'BEGIN:VCALENDAR\n'; 
	txtInvite +=  'PRODID:-//INNOVATION//GROUP//FR\n';
	txtInvite += 'VERSION:2.0\n';
	txtInvite += 'BEGIN:VEVENT\n';
	txtInvite += 'UID:'+WOId+'\n';
	txtInvite += 'DTSTART:'+startTime+'\n';
	txtInvite += 'DTEND:'+EndTime+'\n';
    //HMO -- 24-02-2022
    txtInvite += 'LOCATION:9 Av. des Andes, 91940 Les Ulis, France\n';
    //txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
	txtInvite += 'SUMMARY:RDV de réparation auto\n';
	txtInvite += 'DESCRIPTION:Votre RDV Service Auto à Domicile avec '+GarageName.toUppercase()+'\n';
	txtInvite += 'ORGANIZER;CN="VotreServiceAutoaDomicile":mailto:VotreServiceAutoaDomicile@innovation.group\n';
	txtInvite += 'BEGIN:VALARM\n';
	txtInvite += 'ACTION:DISPLAY\n';
	txtInvite += 'DESCRIPTION:REMINDER\n';
	txtInvite += 'TRIGGER:-PT2H\n';
	txtInvite += 'END:VALARM\n';
	txtInvite += 'END:VEVENT\n';
	txtInvite += 'END:VCALENDAR\n';
	return Blob.valueOf(txtInvite);
}

private static String dateTimeToString(DateTime dt){
        String year = dt.year() + '';
        String month = dt.month() < 10? '0' + dt.month(): dt.month() + '';
        String day = dt.day()< 10? '0' + dt.day(): dt.day() + '';
        String hour = dt.hour() < 10? '0' + dt.hour(): dt.hour() + '';
        String minute = dt.minute() < 10? '0' + dt.minute(): dt.minute() + '';
        String second = '00.000+0000';
        return hour + 'H' + minute;
}
    
    public void doHandleICEAndSMS(List<NOB_Planning__c> plannings){
        //GBH 23.04.2021    RSIW-9495
        if (/*!NOBTools.isMigrationUser*/ !userTypeMigration) {
            
            
            System.debug('doHandleICE------------>');
            List<Id> workOrderIds = new List<Id>();
            map<Id,NOB_Planning__c> mapWOIdPlanning = new map<Id,NOB_Planning__c>();
            map<Id,NOB_Planning__c> mapWOIdPlanningAXADA = new map<Id,NOB_Planning__c>();
            
            if(plannings.size() == 0){
                return;
            }
            
            for(NOB_Planning__c planning : plannings){
                System.debug('planning.NOB_WorkOrder__c:' + planning.NOB_WorkOrder__c);
                if(!workOrderIds.contains(planning.NOB_WorkOrder__c)){
                    workOrderIds.add(planning.NOB_WorkOrder__c);
                }
                if(!mapWOIdPlanning.containsKey(planning.NOB_WorkOrder__c)){
                    mapWOIdPlanning.put(planning.NOB_WorkOrder__c, planning);
                }
            }
            System.debug('workOrderIds--->' + workOrderIds);
            
            List<WorkOrder> wos = [SELECT 
                                        Id, 
                                        CaseId, 
                                        Case.ContactId,
                                        Case.NOB_TECH_IsAXAorDA__c, 
                                        Case.NOB_Pricebook__r.NOB_Pricebook__r.NOB_Offer__c,
                                        Case.Origin,
                                        Case.NOB_ScenarioCode__c,
                                        Case.PFR_TECH_EngineerClaimNR__c,
                                        //GBH   10/11/2021  RSIW-11220: Les SMS ne sont pas envoyés au conducteur si celui-ci est différent de l'assuré, mais à l'assuré
                                        Case.NOB_ContactPickup__c
                                    FROM WorkOrder 
                                    WHERE Id IN : workOrderIds];

            System.debug('wos:' + wos);
            
            List<Id> caseIds = new List<Id>();
            List<NOB_SMSLog__c> smsLogs = new List<NOB_SMSLog__c>();
            for(WorkOrder wo : wos){
                if(!caseIds.contains(wo.CaseId)){
                    caseIds.add(wo.CaseId);
                }
                if(wo.Case.NOB_TECH_IsAXAorDA__c){
                    NOB_SMSLog__c sms = new NOB_SMSLog__c();
                    sms.NOB_Case__c = wo.CaseId;
                    //GBH   10/11/2021  RSIW-11220: Les SMS ne sont pas envoyés au conducteur si celui-ci est différent de l'assuré, mais à l'assuré
                    sms.NOB_Contact__c = (wo.Case.ContactId != wo.Case.NOB_ContactPickup__c && wo.Case.NOB_ContactPickup__c != null)? wo.Case.NOB_ContactPickup__c : wo.Case.ContactId;
                    sms.NOB_Statut__c = 'To be send';
                    sms.NOB_Subject__c = 'Etape_3';
                    sms.NOB_WorkOrder__c = wo.Id;
                    sms.NOB_TECH_Planning__c = mapWOIdPlanning.get(wo.Id).Id;
                    smsLogs.add(sms);
                }
               
                if(wo.Case.NOB_TECH_IsAXAorDA__c && 
                    (wo.Case.NOB_Pricebook__r.NOB_Pricebook__r.NOB_Offer__c == 'SAD' || wo.Case.NOB_Pricebook__r.NOB_Pricebook__r.NOB_Offer__c == 'SAD + Remorquage') && 
                    mapWOIdPlanning.containsKey(wo.Id) &&
                    !(wo.Case.Origin == 'Web service' && userProfileName == 'PRE_Integration' && wo.Case.NOB_ScenarioCode__c == null && wo.Case.PFR_TECH_EngineerClaimNR__c==null)
                ){
                    mapWOIdPlanningAXADA.put(wo.Id,mapWOIdPlanning.get(wo.Id));
                }
            }
            System.debug('## mapWOIdPlanningAXADA' + mapWOIdPlanningAXADA);
            if(mapWOIdPlanningAXADA.size() > 0){
                try {
                    EnvoieMailDeConfirmation(mapWOIdPlanningAXADA);
                } catch (Exception e) {

                    Utils_ManageLogs.NOBCreateLogFromException('NOB_PlanningTriggerHandler', 'Work Order', e, (new list<Id>(mapWOIdPlanningAXADA.keySet()))[0]);   
                }
                
            }
            System.debug('caseIds::' + caseIds);
            
            if(smsLogs.size() > 0){
                insert smsLogs;
            }
        }
    }
               
    //ARA 14/12/2020 -RSIW-5859
    public void onAfterDelete(List<NOB_Planning__c> lstoldDispo){
        System.debug('##### Start NOB_PlanningTriggerHandler.onAfterDelete ####');
        set<Id> setReparateurId = new set<Id>();
        for(Integer i=0; i< lstoldDispo.size(); i++){
            if(lstoldDispo[i].NOB_BodyShop__c != null && 
               lstoldDispo[i].RecordTypeId == Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS).getRecordTypeId()){
          
           		setReparateurId.add(lstoldDispo[i].NOB_BodyShop__c);
            }
        }
               
        if(setReparateurId.size() > 0){
      //KPA 08/01/2021 - RSIW-7209
            NOB_AP60_DispoEntreesCal.updateDispo(setReparateurId);
        }
        System.debug('##### End NOB_PlanningTriggerHandler.onAfterDelete ####');
    }
    
    static boolean isTimeAllowed(Datetime StartDate, Datetime EndDate){
        if (/*!NOBTools.isInterfaceUser() && !NOBTools.isMigrationUser()*/ !userTypeMigration &&!userTypeInterface) {
            Time StartTime = (NOBTools.convertTimeToOtherTimeZone(StartDate, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString())).time();//startDate.time();//WCH 05/10/2021 RSIW-11001
            Time EndTime = (NOBTools.convertTimeToOtherTimeZone(EndDate, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString())).time();//EndDate.time();//WCH 05/10/2021 RSIW-11001
            Time MinAllowedTime = Time.newInstance(6, 0, 0, 0);
            Time MaxAllowedTime = Time.newInstance(21, 0, 0, 0);
            if(StartTime< MinAllowedTime || StartTime> MaxAllowedTime || EndTime< MinAllowedTime || EndTime> MaxAllowedTime ){
                return false;
            }
        }
        return true;
    }
    
    public static void handleSemaineType(List<NOB_Planning__c> plannings){
        if(plannings.size() > 0){
            System.debug('######Start handling addInSemaineType');
        	NOB_LC50_SemaineType.addInSemaineType(plannings);
            System.debug('######End handling addInSemaineType');
        }
    }
    

    /*public static void updateTauxEngagement(set<Id> setReparateurId){
        system.debug('## Start NOB_PlanningTriggerHandler.updateTauxEngagement');
        
        list<ServiceContract> lstContractToUpdate = new list<ServiceContract>();
        Integer countDispoHebdo,countDispoAnnuel,countReserveAnnuel, countReserveHebdo = 0;
        Double tauxEngagementPourcent = 0;
        
        Map<Id,Account> mapAccountWeek= new Map<Id,Account> ([ Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_TauxEngagement__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE
                                                               limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_WEEK
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId]);
        
        Map<Id,Account> mapAccountYear= new Map<Id,Account> ([ Select Id, NOB_Ranking__c,
                                                              (Select Id, NOB_NombreRendezvousAnnuel__c, NOB_Dispo_entrees_semaine__c,NOB_Dispo_entrees_annee__c
                                                               from ServiceContracts
                                                               where Status =: NOB_AP00_Constants.SERVICE_CONTRAT_STATUS_ACTIVE
                                                               limit 1), 
                                                              (Select Id, NOB_StartDate__c ,NOB_Status__c
                                                               from Disponibilite__r
                                                               where NOB_StartDate__c = THIS_YEAR
                                                               and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS) 
                                                              from Account
                                                              where Id in: setReparateurId]);

        for(Id accId : mapAccountYear.KeySet()){
            countDispoHebdo = 0;
            countDispoAnnuel = 0; 
            countReserveAnnuel = 0;
            countReserveHebdo = 0;
            tauxEngagementPourcent = 0.0;
            if(mapAccountYear.get(accId).Disponibilite__r.size() > 0 && mapAccountYear.get(accId).ServiceContracts.size() > 0){
                for(NOB_Planning__c dispo : mapAccountYear.get(accId).Disponibilite__r){
                    if(dispo.NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE){
                        countReserveAnnuel++;
                    }
                }
                countDispoAnnuel = mapAccountYear.get(accId).Disponibilite__r.size();
            }
            if(mapAccountWeek.get(accId).Disponibilite__r.size() > 0 && mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                for(NOB_Planning__c dispo : mapAccountWeek.get(accId).Disponibilite__r){
                    if(dispo.NOB_Status__c == NOB_AP00_Constants.PLANNING_STATUS_RESERVE){
                        countReserveHebdo++;
                    }
                }
                countDispoHebdo = mapAccountWeek.get(accId).Disponibilite__r.size();
            }
            tauxEngagementPourcent = ((double)countReserveHebdo/(double)countDispoHebdo)*100;
            system.debug('## val ' + countDispoHebdo + ' ' + countDispoAnnuel + ' ' + countReserveAnnuel + ' ' + countReserveHebdo + ' ' + tauxEngagementPourcent + ' ' + lstContractToUpdate);
        
            if(mapAccountYear.get(accId).ServiceContracts.size() > 0 || mapAccountWeek.get(accId).ServiceContracts.size() > 0){
                lstContractToUpdate.add(new ServiceContract(Id = mapAccountYear.get(accId).ServiceContracts[0].Id,
                                                            NOB_Dispo_entrees_annee__c = countDispoAnnuel,
                                                            NOB_Dispo_entrees_semaine__c = countDispoHebdo,
                                                            NOB_TauxEngagement__c = countReserveHebdo,
                                                            NOB_NombreRendezvousAnnuel__c = countReserveAnnuel,
                                                            NOB_TauxEngagementPourcent__c = tauxEngagementPourcent));
            }
        }
        
        system.debug('## lstContractToUpdate '+ lstContractToUpdate);
        if(lstContractToUpdate.size() > 0){
            update lstContractToUpdate;
        }

        system.debug('## END NOB_PlanningTriggerHandler.updateTauxEngagement');

    }*/
}