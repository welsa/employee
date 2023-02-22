/*************************************************************************************
Class Name - NOB_BatchRepriseGNP_V2
#Ticket  - RSIW-12067

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO          q5-03-2022   Initial version
*************************************************************************************/
global class NOB_Batch_RepriseGNP_V2 implements Schedulable, Database.Batchable<SObject>, Database.Stateful{

    global string woRecords = '';
    global string caseRecords = '';
    global decimal heapThreshold = Decimal.valueOf(String.isNotBlank(System.Label.NOB_HeapThreshold) ? System.Label.NOB_HeapThreshold : '0.95');
    global Integer caseSize = 0;
    global Integer woSize = 0;
    Boolean processed;


    public NOB_Batch_RepriseGNP_V2(Boolean i){
        if (i == false){
            processed = false;
        }
        if (i == true){
            processed = true;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'select id, NOB_BodyShop__c, NOB_lastMission__c,(SELECT id, caseId, createdDate, NOB_Reparateur__c, WorkOrderNumber, NOB_Pricebook__c,NOB_ScenarioCode__c, toLabel(NOB_SkillSet__c),Status, NOB_BusinessProvider__c,  NOB_TECHDateRendezVousPrisEnCharge__c FROM WorkOrders where caseId != null) from case';

        String query = 'select id, NOB_BodyShop__c, NOB_lastMission__c,(SELECT id, caseId, createdDate, WorkOrderNumber, NOB_Pricebook__c, NOB_BusinessProvider__r.Name, CreatedBy.Name,Status, NOB_Pricebook__r.NOB_Account__r.RecordType.Name FROM WorkOrders where caseId != null) from case where NOB_GNP_Processed__c = TRUE';

        if (processed != null){
            query += ' AND NOB_ProcessGNP__c = '+processed+'';
        }

        if (Test.isRunningTest()){
            query += ' Limit 200';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope){ 
        if (!scope.isEmpty()){

            set<Id> setRep = new Set<Id>();
            for(Case ca : scope){
                if(!setRep.contains(ca.NOB_BodyShop__c)){
                    setRep.add(ca.NOB_BodyShop__c);
                }
            }
            System.debug('£ setRep : '+ setRep);

            if (!setRep.isEmpty()){
                Map<Id, List<AccountHistory>> mapAH_Status = new Map<Id, List<AccountHistory>>();
                Map<Id, List<AccountHistory>> mapAH_StatusReason = new Map<Id, List<AccountHistory>>();
                set<Id> setBSinactif = new Set<Id>();

                for (AccountHistory AH : [SELECT AccountId,CreatedDate,Field,Id,NewValue,OldValue FROM AccountHistory where (Field = 'NOB_Statut__c') and AccountId IN: setRep ORDER BY CreatedDate ASC]){
                    if(mapAH_Status.containsKey(AH.AccountId)) {
                        mapAH_Status.get(AH.AccountId).add(AH);
                    } else {
                        mapAH_Status.put(AH.AccountId, new List<AccountHistory>{AH});
                    }

                    if (AH.NewValue == 'Inactif'){
                        setBSinactif.add(AH.AccountId);
                    }
                }

                System.debug('£ mapAH_Status : '+ mapAH_Status);
                System.debug('£ setBSinactif : '+ setBSinactif);
                
                //Get historique of account statusReason in order of creation whose status =  inactif
                for (AccountHistory AHH : [SELECT AccountId,CreatedDate,Field,Id,NewValue,OldValue FROM AccountHistory where (Field = 'NOB_StatusReason__c') and AccountId IN :setBSinactif ORDER BY CreatedDate ASC ]){
                    if(mapAH_StatusReason.containsKey(AHH.AccountId)) {
                        mapAH_StatusReason.get(AHH.AccountId).add(AHH);
                    } else {
                        mapAH_StatusReason.put(AHH.AccountId, new List<AccountHistory>{AHH});
                    }
                }

                System.debug('£ mapAH_StatusReason : '+ mapAH_StatusReason);

                //Loop in workOrder to get last mission on case
                Map<Id, List<WorkOrder>> mapLastWO = new Map<Id, List<WorkOrder>>();
                for (Case ca : scope){
                    for (WorkOrder wo : ca.WorkOrders){
                        if(mapLastWO.containsKey(ca.NOB_BodyShop__c)) {
                            mapLastWO.get(ca.NOB_BodyShop__c).add(wo);
                        } else {
                            mapLastWO.put(ca.NOB_BodyShop__c, new List<WorkOrder>{wo});
                        }
                    }
                }

                List<WorkOrder> lstWoToUpdateProspet = new List<WorkOrder>();
                for (Id id : mapAH_Status.keySet()){
                        List<AccountHistory> lstAHProspect = mapAH_Status.get(id);
                        for(Integer i = 0; i < lstAHProspect.size(); i++){
                            Transient DateTime start = null;
                            Transient DateTime endTime = null;
                            if (lstAHProspect[i].newValue == 'Prospect'){
                                //system.debug('£ step2');
                                start = lstAHProspect[i].createdDate;
                                //system.debug('£ start '+ start);
                            }

                            if (i < lstAHProspect.size() - 2){
                               
                                if(lstAHProspect[i+1].newValue != 'Prospect'){
                                    //system.debug('£ step4');
                                    endTime = mapAH_Status.get(id)[i+1].createdDate;
                                    //system.debug('£ endTime '+ endTime);
                                }
                            }

                            if (mapLastWO.containsKey(id)){
                                for (WorkOrder wo : mapLastWO.get(id)){
                                    if ((start != null && endTime != null && wo.createdDate >= start && wo.createdDate <= endTime ) || (start != null && endTime == null && wo.createdDate >= start)){
                                        if (!lstWoToUpdateProspet.contains(wo)){
                                            //system.debug('£ step 7');
                                            lstWoToUpdateProspet.add(wo);
                                        }
                                    }
                                }
                            }
                        }
                }
                System.debug('£ lstWoToUpdateProspet : '+ lstWoToUpdateProspet);

                List<WorkOrder> lstWoToUpdateInactif = new List<WorkOrder>();
                for (Id id : mapAH_StatusReason.keySet()){
                    DateTime start = null;
                    DateTime endTime = null;
                    List<AccountHistory> lstAHInactif = mapAH_StatusReason.get(id);
                        for(Integer i = 0; i < lstAHInactif.size(); i++){
                            if (lstAHInactif[i].newValue != 'En préavis de sortie' || lstAHInactif[i].newValue != 'Suspendu'){
                                start = lstAHInactif[i].createdDate;
                                //system.debug('£ start inactif' + start);
                            }

                            if (i < lstAHInactif.size()-2){
                                if(lstAHInactif[i+1].newValue == 'En préavis de sortie' || lstAHInactif[i+1].newValue == 'Suspendu'){
                                    endTime = lstAHInactif[i+1].createdDate;
                                    //system.debug('£ end inactif' + endTime);
                                }
                            }

                            if (mapLastWO.containsKey(id)){
                                for (WorkOrder wo : mapLastWO.get(id)){
                                    if ((start != null && endTime != null && wo.createdDate >= start && wo.createdDate <= endTime ) || (start != null && endTime == null && wo.createdDate >= start)){
                                        if (!lstWoToUpdateInactif.contains(wo)){
                                            //system.debug('£ step 7 inactif');
                                            lstWoToUpdateInactif.add(wo);
                                        }
                                    }
                                }
                            }
                        }
                }
                System.debug('£ lstWoToUpdateInactif : '+ lstWoToUpdateInactif);

                //Flatten list to get all workOrders to update to GNP
                List<WorkOrder> lstWorkOrder = new List<WorkOrder>();
                lstWorkOrder.addAll(lstWoToUpdateProspet);
                lstWorkOrder.addAll(lstWoToUpdateInactif);

                //Assignation GNP
                List<Case> lstCaseToUpdate = new List<Case>();
                Set<Id> woIds = new Set<Id>();
        
                woSize = woSize += lstWorkOrder.size();
                System.debug('wo size'+ woSize);

                for (workOrder wo : lstWorkOrder){
                    woIds.add(wo.Id);

                    if (!(Limits.getHeapSize() > heapThreshold*Limits.getLimitHeapSize()) || (test.isRunningTest())){

                        //woRecords += wo.Id + ',' + wo.WorkOrderNumber + ','+ wo.CaseId+ ','+ wo.NOB_Pricebook__c+ ','+ wo.createdDate+','+wo.NOB_Reparateur__c+','+wo.NOB_ScenarioCode__c+','+wo.NOB_SkillSet__c+','+wo.Status+','+wo.NOB_BusinessProvider__c+','+wo.NOB_TECHDateRendezVousPrisEnCharge__c+'\n';
                        if (wo.NOB_Pricebook__r.NOB_Account__r.RecordType.Name == 'Assureur/ Apporteur d\'affaires'){
                        	woRecords += wo.Id + ',' + wo.WorkOrderNumber + ','+ wo.CaseId+ ','+ wo.NOB_Pricebook__c+ ','+ wo.createdDate+','+wo.NOB_BusinessProvider__r.Name+','+wo.CreatedBy.Name+','+wo.Status+'\n';
                    	}
                    }
                    else{
                        this.callFinishWorkOrder();
                    }
                }
                List<Case> lstCases = new List<Case>();
                for(Case ca : [select id, Status, NOB_BodyShop__c, NOB_lastMission__c, caseNumber,NOB_Pricebook__c, NOB_BusinessProvider__c, NOB_BusinessProvider__r.Name, CreatedBy.Name from Case where NOB_lastMission__c IN: woIds]){

                    lstCases.add(ca);
                    if (!(Limits.getHeapSize() > heapThreshold*Limits.getLimitHeapSize()) || (test.isRunningTest())){

                        caseRecords += ca.Id + ',' + ca.CaseNumber + ',' + ca.NOB_Pricebook__c + ','+ ca.NOB_lastMission__c+','+ ca.NOB_BusinessProvider__r.Name+','+ca.CreatedBy.Name+','+ca.status+/*ca.NOB_ScenarioCode__c+','+ ca.NOB_SkillSet__c+','+ ca.Status+','+ ca.NOB_BusinessProvider__c+','+ ca.NOB_TECH_DispoId__c+','+ ca.PFR_TECH_STDClaimNr__c+*/'\n';
                    }
                    else{
                        this.callFinishCase();
                    }
                }
                caseSize = caseSize += lstCases.size();
                system.debug('£ caseSize :'+ caseSize);
            }
        }
    }

    global void execute (SchedulableContext sc){}

    global void finish(Database.BatchableContext BC){
        this.callFinishWorkOrder();
        this.callFinishCase();
    }

    private void sendEmailRecords(String records, String header, String csvName, List<String> toAddresses, String subject, String body, String LogId){
        header += records;
        Messaging.EmailFileAttachment csvAttchment = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(header);
        csvAttchment.setFileName(csvName);
        csvAttchment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(body);
        email.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttchment});

        if (String.isNotBlank(LogId)){
            Attachment attachment	= new Attachment(
                Body		= csvBlob,
                Name		= csvName,
                ParentId	= LogId
            );

            system.debug('£ csvBlob' + csvBlob.size());
            //system.debug('£ header '+ header);
            //insert attachment;
        }
        system.debug('£ email sent');
        Messaging.SendEmailResult [] resultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        header = '';
    }

    private void callFinishWorkOrder(){

        //string headerWO = 'Id,WorkOrderNumber,CaseId,NOB_Pricebook__c,CreatedDate,NOB_Reparateur__c,NOB_ScenarioCode__c,NOB_SkillSet__c,Status,NOB_BusinessProvider__c,NOB_TECHDateRendezVousPrisEnCharge__c\n';

        string headerWO = 'Id,WorkOrderNumber,CaseId,NOB_Pricebook__c,CreatedDate,Apportaire Name,CreatedBy.Name,Status\n';

        string csvNameWO = 'repriseGNP_WO.csv';
        string woSubject = 'repriseGNP_Workorder';
        string woBody = 'reprise pour les missions ==> '+ woSize;
        List<String> lstAddresses = new List<String>();
        lstAddresses = (System.Label.NOB_GNP_Recipients).split(',');
        sendEmailRecords(woRecords,headerWO, csvNameWO, lstAddresses, woSubject, woBody, System.Label.NOB_GNP_LOG);
       woRecords = '';
       woSize = 0;
    }

    private void callFinishCase(){

        //string headerCase = 'Id,CaseNumber,NOB_Pricebook__c,NOB_lastMission__c, Apportaire Name, NOB_ScenarioCode__c,NOB_SkillSet__c,Status,NOB_BusinessProvider__c,NOB_TECH_DispoId,PFR_TECH_STDClaimNr__c\n';

        string headerCase = 'Id,CaseNumber,NOB_Pricebook__c,NOB_lastMission__c,Apportaire Name,CreatedBy.Name,Status\n';


        string csvNameCase = 'repriseGNP_CASE.csv';
        string caseSubject = 'repriseGNP_CASE';
        string caseBody = 'reprise pour les cases ==> '+ caseSize;
        List<String> lstAddresses = new List<String>();
        lstAddresses = (System.Label.NOB_GNP_Recipients).split(',');
        sendEmailRecords(caseRecords,headerCase,csvNameCase, lstAddresses, caseSubject, caseBody, System.Label.NOB_GNP_LOG);
       caseRecords = '';
       caseSize = 0;
    }
}