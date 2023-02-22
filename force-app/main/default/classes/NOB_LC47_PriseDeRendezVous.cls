/**
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_LC47_PriseDeRendezVous
  -- - Author        : -
  -- - Description   : 
  -- - #Ticket       : 
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- -----------    -     1.0     Initial version
  -- 28-OCT-2020    HMO   1.1     Replacing static values from NOB_AP00_Constants
  -- 22-JUN-2021    HMO   1.2     RSIW-9883 KPI ruleEngine
  -- 03-JUL-2021    GBH   1.3     RSIW-10531
  -- 20-JUL-2021    HMO   1.4     RSIW-9377
  **********************************************************************
*/
public without sharing class NOB_LC47_PriseDeRendezVous {
    public static List<Account> lstRepTest = new List<Account>();

    @AuraEnabled
    public static List<NOB_Planning__c> doGenDispo(Integer week, String ids){
        //Id[] ids = new Id[]{'0011l00000emznuAAA','0011l00000dmTf1AAE','0011l00000emzxcAAA','0011l00000fHU13AAG'};
        List<NOB_Planning__c> result = new List<NOB_Planning__c>();
        String[] sids = ids.split('\n');   
        for(String repId : sids){
            if(repId != null && repId.length() == '0011l00000emznuAAA'.length() && repId.startsWith('0011l'))
            	result.addAll( generateDispos(repId, week));    
        }
        
        return result;
            
    }
    
    public static List<NOB_Planning__c> generateDispos(String reparateurId,  Integer weeksFromNow){
        List<NOB_Planning__c> plannings = new List<NOB_Planning__c>();
        DateTime st = DateTime.now();
        DateTime maintenant = DateTime.now();
        maintenant = maintenant.addDays(weeksFromNow*7);
        st = DateTime.newInstanceGmt(st.year(), st.month(), st.day(), 9, 0, 0);
     //   Random randomInt = new Random();
       Double randomNum = Math.random()*100;
        for(Integer i =0; i < 7;i++){
            //1 - 30
            Double numberOfPlansForThisDay = Math.random()*5;
            for(Integer j = 0; j < numberOfPlansForThisDay; j++){
                st = DateTime.newInstanceGmt(maintenant.year(), maintenant.month(), maintenant.day(), 7, 0, 0);
                Integer hourOfPlan =   Integer.valueOf(((Math.random()*12)));
                
            	st = st.addDays(i);
                st = st.addHours(hourOfPlan);
                //st = st.addMinutes(j*30);
                DateTime en = st.addMinutes(60);
                NOB_Planning__c planning = new NOB_Planning__c();
                planning.NOB_BodyShop__c =reparateurId;
                planning.NOB_StartDate__c = st;
                planning.NOB_EndDate__c = en;
                planning.NOB_Status__c = NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE;
                plannings.add(planning);
                    
            }
       		
        }
        System.debug(plannings);
        insert plannings;
        return plannings;
    }
    
    
     
    
    
	 
    
    
    
    
    @AuraEnabled
    public static Map<String,Object> getRuleEngineCompetences(Id caseId, Map<String,List<String>> filter){
    	Map<String,String> allCompetences = getAllCompetences();
        
        //HMO 20/08/2021 -- RSIW 9377
        Boolean isUserAssureur = false;
        Boolean showReseau = false;
        //
        
        //GBH   02.08.2021  RSIW-10531
        List<Case> lstCa = new List <Case> ([SELECT Id, ContactId,Contact.Name, Status, 
                   Contact.MailingLatitude, Contact.MailingLongitude,Contact.MailingCity,
                   Contact.MailingCountry,Contact.MailingStreet,Contact.MailingPostalCode, 
                   NOB_SkillSet__c FROM Case WHERE Id=: caseId]);
        Case ca = lstCa.size()>0? lstCa[0] : new Case();
        //
        
        
        //HMO 20/08/2021 -- RSIW 9377
        String userProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()]?.Name;
        if (userProfile != null){
            if (userProfile != System.Label.NOB_CCP_Bodyshop){
                isUserAssureur = true;
            }

            if (userProfile == System.Label.NOB_CCP_Bodyshop || userProfile != System.Label.NOB_PRE_CCP_Assureur){              
                showReseau = true;
                System.debug('£££ show reseau '+ showReseau);
            }
        }
        //
        List<Map<String,String>> caseCompetences = new List<Map<String,String>>();
        String skillsets = ca.NOB_SkillSet__c;
        if(skillsets != null && skillsets.length() > 0){
            String[] skills = skillsets.split(';');
            for(String skill : skills){
                Map<String,String> item = new Map<String,String>();
                item.put('name', skill);
                item.put('label', allCompetences.get(skill));
                caseCompetences.add(item);
            }
        }
       // ca.Status
        Map<String,Object> result = new Map<String,Object>();

        result.put('competences', caseCompetences);
        result.put('allCompetences', allCompetences);
        result.put('case', ca);
        //HMO -- 20/08/2021
        result.put('userAssureur', isUserAssureur);
        result.put('showReseau', showReseau);
        //
        result.put('canCustom', canSelectCustomTime());
        result.put('profileId', UserInfo.getProfileId());
        //Map<String,Object> js = 
      //  List<Account> accounts = new List<Account>();
        List<Account> accounts = NOB_AP50_RulesEngines.getReparateur(caseId,filter );

        result.put('ruleengine', accounts);
        result.put('defaultDuration', getDefaultPlanningDuration());
        result.put('mycc', QueryClass.gen());
        result.put('offset', NOB_AP00_Constants.TimeZoneHours);
        return result;
    }
    
    
     @AuraEnabled
    public static Map<String,Object> getDisponibilities(Id caseId){

        List <NOB_Planning__c> dispos = [SELECT 
                                            Id, 
                                            Name, 
                                            NOB_StartDate__c, 
                                            NOB_EndDate__c, 
                                            NOB_Status__c, 
                                            NOB_WorkOrder__c, 
                                            NOB_Quantity__c, 
                                            NOB_BodyShop__c, 
                                            NOB_BodyShop__r.ShippingAddress, 
                                            NOB_BodyShop__r.ShippingCity, 
                                            NOB_BodyShop__r.ShippingCountry, 
                                            NOB_BodyShop__r.ShippingStreet, 
                                            NOB_BodyShop__r.ShippingLatitude, 
                                            NOB_BodyShop__r.ShippingLongitude, 
                                            NOB_BodyShop__r.ShippingPostalCode, 
                                            NOB_BodyShop__r.ShippingState, 
                                            NOB_BodyShop__r.Name, 
                                            NOB_BodyShop__r.NOB_BodyshopStatus__c, 
                                            NOB_BodyShop__r.NOB_Ranking__c, 
                                            NOB_BodyShop__r.NOB_Reparateur__c, 
                                            NOB_BodyShop__r.NOB_Statut__c ,
                                            NOB_BodyShop__r.Phone,
                                            NOB_BodyShop__r.NOB_NetworkType__c,
                                            NOB_BodyShop__r.NOB_SkillSet__c
                                        FROM NOB_Planning__c 
                                        WHERE IsDelete__c = false 
                                            AND NOB_BodyShop__r.RecordType.DeveloperName=:NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP 
                                            AND NOB_BodyShop__c != null  
                                            AND NOB_StartDate__c != NULL 
                                            AND NOB_Status__c =:NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE 
                                            AND NOB_StartDate__c >= TODAY 
                                        ORDER BY NOB_BodyShop__r.NOB_Tech_RankingNumeric__c, NOB_StartDate__c];
        Case ca = [SELECT Id, ContactId,Contact.Name, Contact.MailingLatitude, Contact.MailingLongitude,Contact.MailingCity,Contact.MailingCountry,Contact.MailingStreet,Contact.MailingPostalCode, NOB_SkillSet__c FROM Case WHERE Id=: caseId];
        Location lfrom = null; 
        if(ca.ContactId != null){
            Decimal lat = ca.Contact.MailingLatitude;
            Decimal lon = ca.Contact.MailingLongitude;
            lfrom = Location.newInstance(lat, lon);    
        }
        Map<Id,Double> distances = new Map<Id,Decimal>();
        for(NOB_Planning__c di : dispos){
            Id accId = di.NOB_BodyShop__c;
            if(!distances.containsKey(accId)){
                if(lfrom != null){
                    Decimal lon1 = di.NOB_BodyShop__r.ShippingLongitude; 
                    Decimal lat1 = di.NOB_BodyShop__r.ShippingLatitude;
                    Location lto = Location.newInstance(lat1, lon1);
                    Double dist = Location.getDistance(lfrom, lto, 'km');
                    distances.put(accId, dist);
                }else{
                    distances.put(accId, 0);
                }    
            }
            
        }	
        system.debug('###distances.keySet()###'+ distances.keySet());
        
        List<Account> horsresaux = getRepHorReseaux(distances.keySet());
        for(Account acc : horsresaux){
            Id accId = acc.Id;
            if(!distances.containsKey(accId)){
                if(lfrom != null){
                    Decimal lon1 = acc.ShippingLongitude; 
                    Decimal lat1 = acc.ShippingLatitude;
                    Location lto = Location.newInstance(lat1, lon1);
                    Double dist = Location.getDistance(lfrom, lto, 'km');
                    distances.put(accId, dist);
                }else{
                    distances.put(accId, 0);
                }    
            }
        }
        
        List<Account> nodispos = getRepWithoutDisp(distances.keySet());
        for(Account acc : nodispos){
            Id accId = acc.Id;
            if(!distances.containsKey(accId)){
                if(lfrom != null){
                    Decimal lon1 = acc.ShippingLongitude; 
                    Decimal lat1 = acc.ShippingLatitude;
                    Location lto = Location.newInstance(lat1, lon1);
                    Double dist = Location.getDistance(lfrom, lto, 'km');
                    distances.put(accId, dist);
                }else{
                    distances.put(accId, 0);
                }    
            }
        }
        
        Map<String,String> allCompetences = getAllCompetences();
        
        List<Map<String,String>> caseCompetences = new List<Map<String,String>>();
        String skillsets = ca.NOB_SkillSet__c;
        if(skillsets != null && skillsets.length() > 0){
            String[] skills = skillsets.split(';');
            for(String skill : skills){
                Map<String,String> item = new Map<String,String>();
                item.put('name', skill);
                item.put('label', allCompetences.get(skill));
                caseCompetences.add(item);
            }
        }
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('distances', distances);
        result.put('dispos', dispos);
        result.put('horsreseaux', horsresaux);
        result.put('nodispos', nodispos);
        result.put('competences', caseCompetences);
        result.put('allCompetences', allCompetences);
        result.put('defaultDuration', getDefaultPlanningDuration());
        result.put('offset', NOB_AP00_Constants.TimeZoneHours);
        system.debug('##dispos: '+ dispos);
        return result;
    }
    
    
    
    
    @AuraEnabled
    public static Map<String,Object> getDisponibilyForReparateur(Id caseId, String reparateur){

        reparateur = '%' + reparateur + '%';
        
        //List<Account> accts = [SELECT Id, Name, NOB_NetworkType__c, (SELECT Id, Name FROM Disponibilite__r)  FROM Account WHERE NOB_NetworkType__c != NULL]
        
        List<Account> accts = [SELECT  Id, 
                                  BillingAddress, 
                                  BillingCity, 
                                  BillingCountry, 
                                  BillingStreet, 
                                  BillingLatitude, 
                                  BillingLongitude, 
                                  BillingPostalCode, 
                                  BillingState, 
                                  Name, 
                                  NOB_BodyshopStatus__c, 
                                  NOB_Ranking__c, 
                                  NOB_Reparateur__c, 
                                  NOB_Statut__c ,
                                  NOB_NetworkType__c,
                                  NOB_SkillSet__c,
                                  Phone, (SELECT Id, 
                                              Name, 
                                              NOB_StartDate__c, 
                                              NOB_EndDate__c, 
                                              NOB_Status__c, 
                                              NOB_WorkOrder__c, 
                                              NOB_Quantity__c 
                                          FROM Disponibilite__r 
                                          WHERE IsDelete__c = false 
                                          AND NOB_StartDate__c != NULL 
                                          AND NOB_Status__c =:NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE 
                                          AND NOB_StartDate__c >= TODAY 
                                          ORDER BY NOB_EndDate__c asc, NOB_tech_DiffHeure__c asc, NOB_ExternalId__c asc) 
                               FROM Account 
                               WHERE RecordType.DeveloperName=:NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP 
                               AND Name LIKE :reparateur];

         Case ca = [SELECT Id, ContactId,Contact.Name, Status, 
                   Contact.MailingLatitude, Contact.MailingLongitude,Contact.MailingCity,
                   Contact.MailingCountry,Contact.MailingStreet,Contact.MailingPostalCode, 
                   NOB_SkillSet__c FROM Case WHERE Id=: caseId];
        Location lfrom = null; 
        if(ca.ContactId != null){
            Decimal lat = ca.Contact.MailingLatitude;
            Decimal lon = ca.Contact.MailingLongitude;
            lfrom = Location.newInstance(lat, lon);    
        }
        
        Map<Id,Double> distances = new Map<Id,Decimal>();
        
        for(Account acc : accts){
            Id accId = acc.Id;
            if(!distances.containsKey(accId)){
                if(lfrom != null){
                    Decimal lon1 = acc.BillingLongitude; 
                    Decimal lat1 = acc.BillingLatitude;
                    Location lto = Location.newInstance(lat1, lon1);
                    Double dist = Location.getDistance(lfrom, lto, 'km');
                    distances.put(accId, dist);
                }else{
                    distances.put(accId, 0);
                }    
            }
        }
        
        Map<String,String> allCompetences = getAllCompetences();
        
        List<Map<String,String>> caseCompetences = new List<Map<String,String>>();
        String skillsets = ca.NOB_SkillSet__c;
        if(skillsets != null && skillsets.length() > 0){
            String[] skills = skillsets.split(';');
            for(String skill : skills){
                Map<String,String> item = new Map<String,String>();
                item.put('name', skill);
                item.put('label', allCompetences.get(skill));
                caseCompetences.add(item);
            }
        }
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('distances', distances);
        result.put('ruleengine', accts);
       	result.put('case',ca);
        result.put('competences', caseCompetences);
        result.put('allCompetences', allCompetences);
        result.put('canCustom', canSelectCustomTime());
        result.put('profileId', UserInfo.getProfileId());
        result.put('defaultDuration', getDefaultPlanningDuration());
        result.put('offset', NOB_AP00_Constants.TimeZoneHours);

        return result;
    }
    
    
    public static Map<String,String> getAllCompetences(){
        Map<String,String> item =new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.NOB_SkillSet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            item.put(pickListVal.getValue(), pickListVal.getLabel());
            
            //lstRet.add(item);
        } 
        return item;
    }
    
    
    public static List<Account> getRepWithoutDisp(Set<Id> excludes){
         List<Account> accounts = [SELECT  Id, 
                                  ShippingAddress, 
                                  ShippingCity, 
                                  ShippingCountry, 
                                  ShippingStreet, 
                                  ShippingLatitude, 
                                  ShippingLongitude, 
                                  ShippingPostalCode, 
                                  ShippingState, 
                                  Name, 
                                  NOB_BodyshopStatus__c, 
                                  NOB_Ranking__c, 
                                  NOB_Reparateur__c, 
                                  NOB_Statut__c ,
                                  NOB_NetworkType__c,
                                  NOB_SkillSet__c,
                                  Phone FROM Account WHERE RecordType.DeveloperName =:NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP AND  NOB_NetworkType__c!=:NOB_AP00_Constants.ACCOUNT_NETWORKTYPE_HORSRESEAU AND Id NOT IN :excludes ORDER BY NOB_Tech_RankingNumeric__c];
        return accounts;
    }
    
    
    public static List<Account> getRepHorReseaux(Set<Id> excludes){
        List<Account> accounts = [SELECT  Id, 
                                  ShippingAddress, 
                                  ShippingCity, 
                                  ShippingCountry, 
                                  ShippingStreet, 
                                  ShippingLatitude, 
                                  ShippingLongitude, 
                                  ShippingPostalCode, 
                                  ShippingState, 
                                  Name, 
                                  NOB_BodyshopStatus__c, 
                                  NOB_Ranking__c, 
                                  NOB_Reparateur__c, 
                                  NOB_Statut__c ,
                                  NOB_NetworkType__c,
                                  NOB_SkillSet__c,
                                  Phone FROM Account WHERE RecordType.DeveloperName =: NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP AND  NOB_NetworkType__c=:NOB_AP00_Constants.ACCOUNT_NETWORKTYPE_HORSRESEAU AND Id NOT IN :excludes ORDER BY NOB_Tech_RankingNumeric__c];
        return accounts;
    }
    
    @AuraEnabled
    public static Account createReparateur(String name, String phone, String street, String postalCode, String city, String province, String country){
        Account rep = new Account();
        rep.Name = name;
        rep.ShippingCity = city;
        rep.ShippingCountry = country;
        rep.ShippingPostalCode = postalCode;
        rep.ShippingState = province;
        rep.ShippingStreet = street;
        rep.Phone = phone;
        rep.BillingCity = city;
        rep.BillingCountry = country;
        rep.BillingPostalCode = postalCode;
        rep.BillingState = province;
        rep.BillingStreet = street;
        rep.NOB_Statut__c = 'Prospect';
      //  rep.ContactEmail__c = 'rep'+Datetime.now().getTime()+'@gmail.com';
        rep.ASEntity__c = NOB_AP00_Constants.ACCOUNT_ASENTITY_ASBE1;
        rep.ExpertSubstitutionMethod__c = NOB_AP00_Constants.ACCOUNT_EXPERT_SUBSTITUTION_METHOD_FORCED;
      //  rep.VATNumber__c = '21345668901234' + Datetime.now().getTime();
        rep.NOB_NetworkType__c= NOB_AP00_Constants.ACCOUNT_NETWORKTYPE_HORSRESEAU;
        rep.NOB_IncorporationDate__c = Date.today();
        Id repRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP).getRecordTypeId();
        
        rep.RecordTypeId = repRecTypeId;
        
        insert rep;
        
        Account res = [SELECT  Id, 
                                  ShippingAddress, 
                                  ShippingCity, 
                                  ShippingCountry, 
                                  ShippingStreet, 
                                  ShippingLatitude, 
                                  ShippingLongitude, 
                                  ShippingPostalCode, 
                                  ShippingState, 
                                  Name, 
                                  NOB_BodyshopStatus__c, 
                                  NOB_Ranking__c, 
                                  NOB_Reparateur__c, 
                                  NOB_Statut__c ,
                       			  NOB_NetworkType__c,
                       			  NOB_SkillSet__c,
                                  Phone FROM Account WHERE Id=: rep.Id];
        
        return res;
    }
    
    @AuraEnabled
    public static Map<String,Object> createWorkOrderHorsRes(Id reparateurId, Id caseId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            Case ca = [SELECT Id FROM Case WHERE Id=: caseId];
        
            ca.NOB_BodyShop__c = reparateurId;
            ca.NOB_TECH_DispoId__c = null;
            update ca;
            
            result.put('case',ca);
            result.put('haserror',false);	

            map<string, String> mapWOFlags = new map <String, String>();
            mapWOFlags.put('CaseId', String.valueOf(caseId));
            mapWOFlags.put('BodyshopId', String.valueOf(reparateurId));
            mapWOFlags.put('dispoId', null);
            System.debug('££££ mapWOFlags createWOHorsRes'+ mapWOFlags);
            updateWOrkOrderFlags(mapWOFlags, true);

        } catch (Exception e) {
            String errorMessage = 'Error: ' + e.getMessage() + ' Trace String: ' + e.getStackTraceString();

            Utils_ManageLogs.NOBCreateLogFromException('NOB_LC47_PriseDeRendezVousRulesEngine', 'Case', e, caseId);
            result.put('haserror',true);	
            result.put('error',errorMessage);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String,Object> createWorkOrder(Id dispoId, Id caseId, String selectedTime){

        System.debug('');
        Map<String,Object> result = new Map<String,Object>();
        try {
            NOB_Planning__c dispo = [SELECT 
                                        Id, 
                                        Name, 
                                        NOB_StartDate__c, 
                                        NOB_EndDate__c, 
                                        NOB_Status__c, 
                                        NOB_WorkOrder__c, 
                                        NOB_Quantity__c, 
                                        NOB_BodyShop__c, 
                                        NOB_BodyShop__r.ShippingAddress, 
                                        NOB_BodyShop__r.ShippingCity, 
                                        NOB_BodyShop__r.ShippingCountry, 
                                        NOB_BodyShop__r.ShippingStreet, 
                                        NOB_BodyShop__r.ShippingLatitude, 
                                        NOB_BodyShop__r.ShippingLongitude, 
                                        NOB_BodyShop__r.ShippingPostalCode, 
                                        NOB_BodyShop__r.ShippingState, 
                                        NOB_BodyShop__r.Name, 
                                        NOB_BodyShop__r.NOB_BodyshopStatus__c, 
                                        NOB_BodyShop__r.NOB_Ranking__c, 
                                        NOB_BodyShop__r.NOB_Reparateur__c, 
                                        NOB_BodyShop__r.NOB_Statut__c ,
                                        NOB_BodyShop__r.Phone
                                        FROM NOB_Planning__c WHERE Id =: dispoId];
            
            Case ca = [SELECT Id FROM Case WHERE Id=: caseId];

            Integer defaultDuration = getDefaultPlanningDuration();
            if(selectedTime != null){
                DateTime startTime = DateTime.newInstance(Long.valueOf(selectedTime));
                DateTime endtime = startTime.addMinutes(defaultDuration);
                dispo.NOB_StartDate__c = startTime;
                dispo.NOB_EndDate__c = endtime;
                dispo.NOB_TECH_ByPassReasonVR__c = true;
                //dispo.NOB_CancelReason__c = 'A la demande de l\'assuré';
            }else{
                DateTime starttime = dispo.NOB_StartDate__c;
                DateTime endtime = dispo.NOB_EndDate__c;
                Long duration = (endtime.getTime() - starttime.getTime())/(1000*60);
                if(duration < defaultDuration){
                    endtime = startTime.addMinutes(defaultDuration);
                    dispo.NOB_EndDate__c = endtime;
                    dispo.NOB_TECH_ByPassReasonVR__c = true;
            //update dispo;
                    //dispo.NOB_CancelReason__c = 'A la demande de l\'assuré';
                }
                //if( start.getTime())
            }
            dispo.NOB_Status__c = NOB_AP00_Constants.PLANNING_STATUS_RESERVE;
            update dispo;

            System.debug('Updating dispo:' + dispo);
            
            WorkOrder work = prepareWO(dispo,ca);

            ca.NOB_BodyShop__c = dispo.NOB_BodyShop__c;
            ca.NOB_TECH_DispoId__c = dispoId;
            update ca;

            

            

    
            System.debug('Updating case:' + ca);
            //Map<String,Object> result = new Map<String,Object>();
            result.put('case', ca);
            result.put('dispo', dispo);
            result.put('haserror',false);	
            dispo.NOB_TECH_ByPassReasonVR__c = false;
            update dispo;

            map<string, String> mapWOFlags = new map <String, String>();
            Boolean affectationManuel = false;
            mapWOFlags.put('CaseId', String.valueOf(caseId));
            mapWOFlags.put('BodyshopId', String.valueOf(dispo.NOB_BodyShop__c));
            mapWOFlags.put('dispoId', String.valueOf(dispoId));
            System.debug('££££ mapWOFlags '+ mapWOFlags);
            updateWOrkOrderFlags(mapWOFlags, false);

            system.debug('@@@ calling in future finished');

            return result;
        } catch (Exception e) {
            String errorMessage = 'Error: ' + e.getMessage() + ' Trace String: ' + e.getStackTraceString();
            //createLog(errorMessage, caseId);
            Utils_ManageLogs.NOBCreateLogFromException('NOB_LC47_PriseDeRendezVousRulesEngine', 'Case', e, caseId);
            result.put('haserror',true);	
            result.put('error',errorMessage);
        }
        return result;
    }

    //RLA 28/06/2021
    @future
    public static void updateWOrkOrderFlags (map<String,String> mapWorkOrderTOUpd, Boolean manual ){

        System.debug('££££ rsiw - 9883 mapWorkOrderFlags start ££££');
       // update workOrder;
			
        Id workOrderID = mapWorkOrderTOUpd.containsKey('Id') ? (Id)mapWorkOrderTOUpd.get('Id') : null;
        Id caseId = mapWorkOrderTOUpd.containsKey('CaseId') ? (Id)mapWorkOrderTOUpd.get('CaseId') : null;
        Id BodyshopId = mapWorkOrderTOUpd.containsKey('BodyshopId') ? (Id)mapWorkOrderTOUpd.get('BodyshopId') : null;
        Id dispoId = mapWorkOrderTOUpd.containsKey('dispoId') ? (Id)mapWorkOrderTOUpd.get('dispoId') : null;
        Boolean isCreatedFromMyPrefikar = mapWorkOrderTOUpd.containsKey('PRE_TECH_CreationDispoDepuisMyPrefikar') ? (mapWorkOrderTOUpd.get('PRE_TECH_CreationDispoDepuisMyPrefikar')=='true'?true:false) : false;//WCH 21/12/21 RSIW-10850
    

        WorkOrder mission = updateFlags(caseId, dispoId, manual);
      

        System.debug('££££ rsiw - 9883 mapWorkOrderFlags after updateFlags');
        //RSIW - 9883
        //   //after ca update - query wo and perform update
       WorkOrder workOrder = null;

       for (workOrder wo : [SELECT Id, workOrderNumber, NOB_Dispo10Jsur3PremiersReparateurs__c, NOB_Dispo10Jsur10PremiersReparateurs__c,NOB_Dispo10JensembleReparateur__c, NOB_AffectationManuelle__c, NOB_CanalDaffectation__c, NOB_Reparateur__c, CaseId from WorkOrder WHERE NOB_Reparateur__c =: BodyshopId and CaseId =: caseId and Case.NOB_TECH_DispoId__c =: dispoId ORDER BY workOrderNumber DESC Limit 1]){
            workOrder = wo;
        }

          

        if (mission != null && workOrder != null){
            workOrder.NOB_Dispo10Jsur3PremiersReparateurs__c = mission.NOB_Dispo10Jsur3PremiersReparateurs__c;
            workOrder.NOB_Dispo10Jsur10PremiersReparateurs__c = mission.NOB_Dispo10Jsur10PremiersReparateurs__c;
            workOrder.NOB_Dispo10JensembleReparateur__c = mission.NOB_Dispo10JensembleReparateur__c;
            if (manual){
                workOrder.NOB_AffectationManuelle__c = true;
            }
            else{
                workOrder.NOB_AffectationManuelle__c = mission.NOB_AffectationManuelle__c;
            }
            workOrder.NOB_CanalDaffectation__c = mission.NOB_CanalDaffectation__c;
            workOrder.PRE_TECH_CreationDispoDepuisMyPrefikar__c = isCreatedFromMyPrefikar;//WCH 21/12/21 RSIW-10850
            update workOrder;

        }

        System.debug('££££ mapWorkOrderFlags end ');
    }

    //HMO -- 18-06-2021 -- RSIW 9883
    @AuraEnabled
    public static WorkOrder updateFlags(Id caseId, Id dispoId, Boolean manual){
        
        System.debug('£££ START OF UPDATE FLAG FUNCTION £££');
		List<Account> lstRepsRE = new List<Account>();
        Map<String, List<String>> filter = new Map<String, List<String>>();
        system.debug('## caseId in method updateflags' + caseId);
        system.debug('## dispoId' + dispoId);


      
        //HMO -- 12-07-2021 -- bypassing rule engine search in test class
        if (!Test.isRunningTest()){
           lstRepsRE = NOB_AP50_RulesEngines.getReparateur(caseId, filter);
          
        }else{
            lstRepsRE.addAll(lstRepTest);
       
        }

        WorkOrder wo = new WorkOrder();

        //String siteUrl =  URL.getSalesforceBaseUrl().toExternalForm();
        Id userProfileId = UserInfo.getProfileId();
        Profile profile = [SELECT Name from Profile WHERE Id =: userProfileId];
        List<Schema.PicklistEntry> lstVals = getPicklistValues(WorkOrder.NOB_CanalDaffectation__c);

        if (profile.Name == Label.NOB_PRE_CCP_Assureur){
            wo.NOB_CanalDaffectation__c = lstVals.get(1).getValue();
        }
        if (profile.Name == Label.NOB_ProfilePreIntegration){
            wo.NOB_CanalDaffectation__c = lstVals.get(2).getValue();
        }
        
        if (profile.Name != Label.NOB_ProfilePreIntegration && profile.Name != Label.NOB_PRE_CCP_Assureur){

            wo.NOB_CanalDaffectation__c = lstVals.get(0).getValue();
        }


        if (lstRepsRE.size() > 0){
            Map<Id, Account> mapAccDispos;
            List<Id> lstAccIds = new List<Id>();
            for (Account acc : lstRepsRE){
                lstAccIds.add(acc.Id);
            }

            if (manual){
                mapAccDispos = new Map<Id, Account>([Select Id, Name, (Select Id, NOB_StartDate__c ,NOB_EndDate__c, NOB_Status__c
                from Disponibilite__r
                where NOB_StartDate__c >= Today AND IsDelete__c = FALSE
                and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS AND (NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE) ORDER BY NOB_StartDate__c ASC) 
                from Account
                where Id in: lstAccIds]);
            }
            else{
                mapAccDispos = new Map<Id, Account>([Select Id, Name, (Select Id, NOB_StartDate__c ,NOB_EndDate__c, NOB_Status__c
                from Disponibilite__r
                where NOB_StartDate__c >= Today AND IsDelete__c = FALSE
                and RecordType.DeveloperName =: NOB_AP00_Constants.PLANNING_RECORDTYPE_PLANNING_NOBILAS AND (NOB_Status__c =: NOB_AP00_Constants.PLANNING_STATUS_DISPONIBLE OR id =: dispoId) ORDER BY NOB_StartDate__c ASC) 
                from Account
                where Id in: lstAccIds]);
            }


                
            Map<Id, Integer> mapPlannings = new Map<Id, Integer>();
               for (Id key : mapAccDispos.keySet()){
                   Account acc = mapAccDispos.get(key);
                   List<NOB_Planning__c> lstDispoExclWE = new List<NOB_Planning__c>();
                   if (acc.Disponibilite__r.size() > 0){

                       //get dispo starting in weekdays
                       for (NOB_Planning__c dispos : mapAccDispos.get(key).Disponibilite__r){
                        //    system.debug('@@@ dispos:'+dispos);
                            if(checkDay(dispos.NOB_StartDate__c)){
                                lstDispoExclWE.add(dispos);
                            }
                       }

     
                       //Check number of days from today to start of first dispo
                       if (lstDispoExclWE.size() > 0){
                            NOB_Planning__c planning = new NOB_Planning__c();
                            planning = lstDispoExclWE.get(0);
                        
                            Date firstDispoDate = (planning.NOB_StartDate__c).date();
       
                            Integer numDaysPlanning = getDaysExclWE(System.today(), firstDispoDate);
                        
                            mapPlannings.put(acc.Id, numDaysPlanning);
                       }
                   }
                   //Bodyshop no dispos at all
                   else{
                       mapPlannings.put(acc.Id, 0);
                   }
               }


               if (mapPlannings.size()>0){
                    for(Id key : mapPlannings.keySet()){
                        if (mapPlannings.get(key)>0){
                            Integer rank = lstAccIds.indexOf(key);
                            if(rank  < 3 && mapPlannings.get(key)<=10){
                                wo.NOB_Dispo10Jsur3PremiersReparateurs__c = true;
                                wo.NOB_Dispo10Jsur10PremiersReparateurs__c = true;
                                wo.NOB_Dispo10JensembleReparateur__c = true;
                            }
                            if (rank < 10 && mapPlannings.get(key)<=10){
                                wo.NOB_Dispo10Jsur10PremiersReparateurs__c = true;
                                wo.NOB_Dispo10JensembleReparateur__c = true;
                            }
                            if (rank > 10 && mapPlannings.get(key)<=10){
                                wo.NOB_Dispo10JensembleReparateur__c = true;
                                wo.NOB_AffectationManuelle__c	= true;
                            }
                            
                        }
                    }
                }
                NOB_Planning__c planning = new NOB_Planning__c();

                if (dispoId == null){
                    wo.NOB_AffectationManuelle__c	= true;
                }
                else{
                    planning = [SELECT NOB_BodyShop__c from NOB_Planning__c WHERE Id =: dispoId];
                    if (!mapPlannings.containsKey(planning.NOB_BodyShop__c)){
                        wo.NOB_AffectationManuelle__c	= true;
                    }
                }
        }
        System.debug('£££ END OF UPDATE FLAG FUNCTION £££ WO' +wo);
        return wo;
    }

    //RSIW - 9883
    public static Boolean checkDay(DateTime dt){
        System.debug('££££ start checkDay method ');
        if (dt.format('E') != 'Sat' && dt.format('E') != 'Sun'){
            return true;
        }
        return false;
    }

    //RSIW - 9883
    public static Integer getDaysExclWE(Datetime dt1, Datetime dt2){
        System.debug('££££ getDaysExclWE start date '+ dt1 + dt2);


        Integer numDays = 0;

        //RSIW - 9883
        //implies dispo same date as date affectation
        if (Date.valueOf(dt1).daysBetween(Date.valueOf(dt2)) == 0){
            numDays = 1;
        }
        else {
            while (dt1 < dt2){
                if (dt1.format('E') != 'Sat' && dt1.format('E') != 'Sun'){
                    numDays++;
                }
                dt1 = dt1.addDays(1);
            }
        }
        
        System.debug('££££ getDaysExclWE numDays '+ numDays);
        return numDays;
    }

    public static List<Schema.PicklistEntry> getPicklistValues(
        Schema.sObjectField field) {

    List<Schema.PicklistEntry> entries = field.getDescribe().getPickListValues();
    List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }
        return activeEntries;
    }



    public static Integer getDefaultPlanningDuration(){
       List<NOB_PriseRendezVous__c> duration = [SELECT Id, Name, NOB_AppointmentDuration__c FROM NOB_PriseRendezVous__c LIMIT 1];
        if(duration.size() > 0){
            Decimal d = duration.get(0).NOB_AppointmentDuration__c;
            return d.intValue();
            //return duration.get(0).NOB_Duration__c;
        }else{
            return 60;
        }
    }
    
    public static Boolean canSelectCustomTime(){
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
        String profileName = profile.Name;
        List<NOB_PriseRendezVous__c> setProfile = [SELECT Id, Name, NOB_CustomTimeProfile__c FROM NOB_PriseRendezVous__c LIMIT 1];
        if(setProfile.size() > 0){
            String customTime = setProfile.get(0).NOB_CustomTimeProfile__c;
            if(customTime != null){
                String[] pps = customTime.split(',');
                for(String p : pps){
                    if(p == profileName){
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    public static WorkOrder prepareWO(NOB_Planning__c dispo, Case ca){
        WorkOrder wo = new WorkOrder();
        wo.NOB_Reparateur__c = dispo.NOB_BodyShop__c;
        wo.Status = 'New';
        wo.CaseId = ca.Id;
        wo.Description = 'Demande de reparation....';
        wo.CurrencyIsoCode = 'EUR';
        return wo;
    }
    
    private static DateTime parseDateTime(String dt){
        String[] secs = dt.split('T');
        String[] secDts = secs[0].split('-');
        String[] secTms = secs[1].split(':');
        
        DateTime tm = DateTime.newInstance(Integer.valueOf(secDts[0]), Integer.valueOf(secDts[1]), Integer.valueOf(secDts[2]), Integer.valueOf(secTms[0]), Integer.valueOf(secTms[1]), 0);
        return tm;
    }
    
    @AuraEnabled
    public static Map<String,Object> createOtherDispossss(Id reparateurId, Id caseId, String startDateTime, String endDateTime){
        System.debug('startDateTime:' + startDateTime);
        System.debug('endDateTime:' + endDateTime);
        Map<String,Object> result = new Map<String,Object>();
        DateTime st = parseDateTime(startDateTime); 
        st = st.addHours(NOB_AP00_Constants.TimeZoneHours);
        DateTime en = parseDateTime(endDateTime);
        en = en.addHours(NOB_AP00_Constants.TimeZoneHours);
        NOB_Planning__c dispo = new NOB_Planning__c();
        dispo.NOB_StartDate__c = st;
        dispo.NOB_EndDate__c = en;
        dispo.NOB_Quantity__c = 1;
        dispo.NOB_Status__c = NOB_AP00_Constants.PLANNING_STATUS_RESERVE;
        dispo.NOB_BodyShop__c = reparateurId;
        dispo.NOB_TECH_ByPassReasonVR__c = true;
        //dispo.NOB_CancelReason__c = 'A la demande de l\'assuré';

        //HMO --02-12-2020
        String errMsg = '';
        try{
            insert dispo;
            
            Case ca = [SELECT Id FROM Case WHERE Id=: caseId];
            
            WorkOrder work = prepareWO(dispo,ca);
            ca.NOB_BodyShop__c = dispo.NOB_BodyShop__c;
            ca.NOB_TECH_DispoId__c = dispo.Id;
            update ca;

            dispo.NOB_TECH_ByPassReasonVR__c = false;
            update dispo;
            result.put('dispo',dispo);
            result.put('haserror',false);	

            //RSIW - 9883
            map<string, String> mapWOFlags = new map <String, String>();
            mapWOFlags.put('CaseId', String.valueOf(caseId));
            mapWOFlags.put('BodyshopId', String.valueOf(dispo.NOB_BodyShop__c));
            mapWOFlags.put('dispoId', String.valueOf(dispo.Id));
            mapWOFlags.put('PRE_TECH_CreationDispoDepuisMyPrefikar', 'true');//WCH 21/12/21 RSIW-10850
            updateWOrkOrderFlags(mapWOFlags, true);


        }catch(DmlException e){
            system.debug('createOtherDispo catch');
            
            Utils_ManageLogs.NOBCreateLogFromException('NOB_LC47_PriseDeRendezVousRulesEngine', 'Case', e, caseId);
            for(integer i =0; i< e.getNumDml(); i++){
                errMsg =+ e.getDmlMessage(i) + '\n';
            }
            //createLog(errMsg, caseId);
            Utils_ManageLogs.NOBCreateLogFromException('NOB_LC47_PriseDeRendezVousRulesEngine', 'Case', e, caseId);
            /* AuraHandledException dmlError = new AuraHandledException(errMsg);
            dmlError.setMessage(errMsg); 
            throw dmlError;*/
            result.put('haserror',true);	
            result.put('error',errMsg);
        } catch (Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + ' Trace String: ' + e.getStackTraceString();
            //createLog(errorMessage, caseId);
            Utils_ManageLogs.NOBCreateLogFromException('NOB_LC47_PriseDeRendezVousRulesEngine', 'Case', e, caseId);
            result.put('haserror',true);	
            result.put('error',errorMessage);
        }
        return result;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText ){
                                      
                                      
       	if(objectName == 'Competences'){
            List<ResultWrapper> lstRet = new List<ResultWrapper>();
            Schema.DescribeFieldResult fieldResult = Case.NOB_SkillSet__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                ResultWrapper obj = new ResultWrapper();
                obj.objName = objectName;
                //String sss = '';
                //sss.contains(str)
                obj.text = pickListVal.getLabel();
                obj.val = pickListVal.getValue();
                if(obj.text.toLowerCase().contains(searchText.trim().toLowerCase()))
                	lstRet.add(obj);
            } 
         
            
             return JSON.serialize(lstRet) ;
            
       	}
                                      
        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';

        
        String query = 'SELECT NOB_NetworkType__c,'+fld_API_Text+' ,'+fld_API_Val+
            			' FROM '+objectName+
            				' WHERE '+fld_API_Search+' LIKE '+searchText+ 
            			'AND NOB_Statut__c <> \'Inactif\' AND RecordType.DeveloperName = \'BODYSHOP\' LIMIT '+lim;
        
                                      
        System.debug(query);
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            obj.val = String.valueOf(s.get(fld_API_Val))  ;
            obj.subtitle = String.valueOf(s.get('NOB_NetworkType__c'));
            lstRet.add(obj);
        } 
         return JSON.serialize(lstRet) ;
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String subtitle{get;set;}
        public String val{get;set;}
    }
}