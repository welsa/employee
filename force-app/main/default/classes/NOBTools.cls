/*************************************************************************************
Class Name - NOBTools
Version - 1.0
Created Date - 15 Oct 2020
Function - Common class to manage common methods in Nobilas

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Kureem R          15/10/2020  RSIW-1988: Original Version
* GBH                23/11/2020  RSIW-4580 1.1
* Ashutosh R        27/11/2020  RSIW-4182  1.2
* KPA               06/05/2021  RSIW-7051  1.3
*************************************************************************************/
public class NOBTools {
    public static DateTime testDate = System.now();
    public static boolean isUserPrefikar = false;
    public static boolean isMigrationUser = false;
    public static boolean isInterface = false;
    public static string nameUser='';
	public static string ProfileName='';
    static{
        
        
        User user = [Select NOB_isPrefikar__c, NOB_isMigrationUser__c, NOB_isInterfaceUser__c, Name, Profile.Name from User where Id =:UserInfo.getUserId() limit 1];
        
        isUserPrefikar = user.NOB_isPrefikar__c;
        isMigrationUser = user.NOB_isMigrationUser__c;
        isInterface = user.NOB_isInterfaceUser__c;
		nameUser=user.Name;
		ProfileName=user.Profile.Name;
    }
    
    public static boolean isPrefikarUser(){ 
        return(isUserPrefikar);
    }
    public static boolean isMigrationUser(){ 
        return(isMigrationUser);
    }
    
     public static boolean isInterfaceUser(){ 
        return(isInterface);
    }
	
	public static string nameUser(){
	  return nameUser;
	}
	
	public static string ProfileName(){
	 return ProfileName;
	}


    /**
     * Returns suggested possible start date and end date 
     * if use has not entered preferred start date or end date
     */
    public static DateTime[] suggestPossibleStartEndDates(Time morningStart, Time morningEnd, Time eveningEnd){
        Datetime createdDateTime = system.now();
       
        Datetime enteredStart;
        Datetime enteredEnd;
        
        
        if(Test.isRunningTest()){
            createdDateTime = testDate;
        }
        
        system.debug('createdDateTime '+ createdDateTime);
        
		Time createTime = UserInfo.getTimezone()==Timezone.getTimeZone('Europe/Paris')?createdDateTime.time():convertTimeToOtherTimeZone(createdDateTime, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString()).time();

        system.debug('createTime '+ createTime);

        if(createTime < morningStart){
            //before morning -> take morning
            enteredStart = Datetime.newInstance(createdDateTime.date(), morningStart);
            enteredEnd = Datetime.newInstance(createdDateTime.date(), morningEnd);
        }else if(createTime >= morningStart && createTime <= morningEnd){
            //morning -> take afternoon
            enteredStart = Datetime.newInstance(createdDateTime.date(), morningEnd);
            enteredEnd = Datetime.newInstance(createdDateTime.date(), eveningEnd);
        }else if(createTime > morningEnd){
            Datetime nextWDay = createdDateTime.date().addDays(1);
            nextWDay = nextWDay.addDays(NOBTools.getDaysBeforeMonday(nextWDay));
            enteredStart = Datetime.newInstance(nextWDay.date(), morningStart);
            enteredEnd = Datetime.newInstance(nextWDay.date(), morningEnd);
        }
        enteredStart = convertTimeToOtherTimeZone(enteredStart,Timezone.getTimeZone('Europe/Paris').toString(), UserInfo.getTimezone().toString());
        enteredEnd = convertTimeToOtherTimeZone(enteredEnd,Timezone.getTimeZone('Europe/Paris').toString(), UserInfo.getTimezone().toString());
        system.debug('enteredStart '+ enteredStart);
        system.debug('enteredEnd '+ enteredEnd);
        return new Datetime[]{enteredStart, enteredEnd};

    }
    public static Time addEuropeParisOffset3(Time dt){
        dt = dt.addHours(-UserInfo.getTimezone().getOffset( system.now() ) / 3600000 );
        return dt.addhours(Timezone.getTimeZone('Europe/Paris').getOffset(system.now())/3600000);
    }

    public static Datetime[] calculatePrefDates(Datetime enteredStart, Datetime enteredEnd,Time morningStart, Time morningEnd, Time eveningEnd){
        Integer daysBeforeMonday = getDaysBeforeMonday(enteredStart);
        Datetime prefStart;
        Datetime prefEnd;
        Datetime enteredStartParis=convertTimeToOtherTimeZone(enteredStart, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());
        Datetime enteredEndParis=convertTimeToOtherTimeZone(enteredEnd, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());
        system.debug('enteredStart '+ enteredStart);
        if(daysBeforeMonday > 0){
            //in weekend
            Date monday = enteredStart.date().addDays(daysBeforeMonday);
            prefStart = DateTime.newInstance(monday, morningStart);
            prefEnd = DateTime.newInstance(monday, morningEnd);
        }else{
            //in week day
            //Time createTime = enteredStart.time();
            Time createTime = UserInfo.getTimezone()==Timezone.getTimeZone('Europe/Paris')?enteredStart.time():convertTimeToOtherTimeZone(enteredStart, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString()).time();
            system.debug('createTime '+ createTime);
            
            if(createTime < morningStart){
                //before morning
                prefStart = DateTime.newInstance(enteredStart.date(), morningStart);
                prefEnd = DateTime.newInstance(enteredEnd.date(), morningEnd);
            }else if(createTime >= morningStart && createTime <= morningEnd){
                prefStart = enteredStartParis;
                prefEnd =   enteredEndParis;
                //morning
            }else if(createTime > morningEnd && createTime <= eveningEnd){
                //afternoon
                prefStart = enteredStartParis;
                prefEnd = enteredEndParis;
            }else if(createTime > eveningEnd){
                //night
                Date nextWDay = enteredStart.date().addDays(1);
                //add number of days if nextDay is weekend
                nextWDay = nextWDay.addDays(getDaysBeforeMonday(nextWDay));
                prefStart = DateTime.newInstance(nextWDay, morningStart);
                prefEnd = DateTime.newInstance(nextWDay, morningEnd);
            }
        }
        prefStart = convertTimeToOtherTimeZone(prefStart,Timezone.getTimeZone('Europe/Paris').toString(), UserInfo.getTimezone().toString());
        prefEnd = convertTimeToOtherTimeZone(prefEnd,Timezone.getTimeZone('Europe/Paris').toString(), UserInfo.getTimezone().toString());
        system.debug('prefStart '+ prefStart);
        system.debug('prefEnd '+ prefEnd);
        return new DateTime[]{prefStart, prefEnd};
    }

    public static Integer getDaysBeforeMonday(DateTime aDate){
        Integer week = dayOfWeekNumber(aDate.date());
        if(week == 0){
            return 1;
        }else if(week == 6){
            return 2;
        }else{
            return 0;
        }
    }

    private static Integer dayOfWeekNumber(Date aDate) {
        return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(aDate),7);
    }
    
    // ARA 27/11/2020 :Method check null
    public static String checkNull(String s){
        if(s == null){
           // s ='';
           System.debug('@@s'+s);
            return '';
        }
        return s;
      }
      public static String checkNull(Datetime s, String strRequestType){
        if(s == null){
            return '';
        }
        else if (strRequestType== NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE){
            return s.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        else if (strRequestType== NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS){
            return s.format('dd/MM/yyyy HH:mm:ss');
        }
        return '';
     }
     
     //GBH 07/06/2021
     public static Map<String,String> removeSpecialChar(Map<String,String> FieldMapString){
        Map<String,String> strFilteredString = new Map<String,String>();
        String strTmp ='';
        String regExp =  System.Label.NOB_PSC_RegEx;
        //String regExp = '[\\\\p{IsBasicLatin}a-zA-Z0-9àéèùÀÁÈÉÙâêîôûÂÊÎÔÛäëïöüÄËÏÖÜ§!çÇ\\\\\\-_$£%=+:/;.,?@€²~\'`«»#(){}°øØµ^|¨´&\\s]';
        String replacement = '';
        
        //Get special Characters
        String allStr = '';
        for (String str : FieldMapString.values()) {
            allStr = allStr + str;
        }

        allStr = String.escapeSingleQuotes(allStr);

        String strSpecialCharStr = allStr.replaceAll(regExp, replacement);
        Set<String> setSpecialChar = New Set <String>();
        
        List<String> LstTmp = strSpecialCharStr.split('');
        setSpecialChar.addAll(lstTmp);

        List <PrefikarSpecialCharacter__mdt> lstPSC_mdt = [SELECT Character__c, Replacement_Char__c FROM PrefikarSpecialCharacter__mdt WHERE Character__c IN :setSpecialChar];

        String mdtRep;
        String mdtCharacter;
        for (String s : FieldMapString.keySet()) {
            strTmp = FieldMapString.get(s);
            if(strTmp==null){
                strFilteredString.put(s,'');
                continue;
            }
            for (PrefikarSpecialCharacter__mdt mdt : lstPSC_mdt) {
                if (setSpecialChar.contains(mdt.Character__c)) {
                    mdtRep = (mdt.Replacement_Char__c == null)? '' : mdt.Replacement_Char__c;
                    mdtCharacter = mdt.Character__c;
                    strTmp = strTmp.replaceAll('\\' + String.valueOf(mdtCharacter), mdtRep);
                }
            }
            strFilteredString.put(s,strTmp);
        }
        return strFilteredString;
    }
    
    public static DateTime convertTimeToOtherTimeZone(DateTime dttime, string sourceTimezone, string targetTimezone){
        if(sourceTimezone.equals(targetTimezone)) return dttime;
        TimeZone tz = Timezone.getTimeZone(sourceTimezone);
        Integer offset=tz.getOffset(dttime);

        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
       	integer correction = offsetTotargetTZ- offset;
		
        return dttime.addMinutes(correction / (1000 * 60));
    }

    public static void sendEmail(List<Map<String,String>> lstEmailContents){
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Map<String,String> ec : lstEmailContents) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setTargetObjectId( (Id) ec.get('TargetObjectId'));
            email.setOrgWideEmailAddressId( (Id) ec.get('OrgWideEmailAddressId'));
            email.setSubject(ec.get('Subject'));
            email.setSaveAsActivity(Boolean.valueOf(ec.get('SaveAsActivity')));
            email.setHtmlBody(ec.get('HtmlBody'));
            emails.add(email);
        }
        if ( emails.size()>0 ){ 
            try {
                Messaging.sendEmail(emails, false);
            } catch (EmailException e) {
                Utils_ManageLogs.NOBCreateLogFromException('NOBTools.sendEmail()', 'WorkOrder', e, null);
            }
        }
    }
    public static String dateTimeToString(DateTime dt){
        String dateTimeStr = dt.format('HH:mm:ss dd/MM/yyyy');
        String year = dt.year() + '';
        String month = dt.month() < 10? '0' + dt.month(): dt.month() + '';
        String day = dt.day()< 10? '0' + dt.day(): dt.day() + '';
        String hour = dt.hour() < 10? '0' + dt.hour(): dt.hour() + '';
        String minute = dt.minute() < 10? '0' + dt.minute(): dt.minute() + '';
        String second = '00.000+0000';
        return dateTimeStr;
        //return hour + ':'+ minute + ' ' + day + '/' + month + '/' + year;
    }

    public static Map<String,String> removeNonNumeric(Map<String,String> fieldMapString) {
        String invalidNumbers = '[^0-9]';  
		Map<String,String> mapFilteredFieldMapString = new Map<String,String>();
        for (String s : FieldMapString.keySet()) {
            
            if( fieldMapString.get(s) == null ){
                mapFilteredFieldMapString.put(s,'');
                
            } else {
                mapFilteredFieldMapString.put(s, fieldMapString.get(s).replaceAll( invalidNumbers, '' ));
            }
        
        }
            
        return mapFilteredFieldMapString;
    }
}