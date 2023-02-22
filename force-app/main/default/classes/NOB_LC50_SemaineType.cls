public without sharing class NOB_LC50_SemaineType {
    
    private static Map<String,String> DAYS = new Map<String,String>();
    
    private static String FORMAT_LONG = 'yyyy-MM-dd\'T\'HH:mm:ss\'.000Z\'';
    
    private final static String[] TYPES = new String[]{'dispo', 'abs'};
    
    static{
        DAYS.put('lundi', 'Lundi');
        DAYS.put('mardi', 'Mardi');
        DAYS.put('mercredi', 'Mercredi');
        DAYS.put('jeudi', 'Jeudi');
        DAYS.put('vendredi', 'Vendredi');
        DAYS.put('samedi', 'Samedi');
    }
    
    
    @AuraEnabled
    public static String getSemaineType(){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, NOB_SemaineType__c FROM User WHERE Id=:userId];
        return u.NOB_SemaineType__c;
    }
    
    @AuraEnabled
    public static User saveSemaineType(String semaineType){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, NOB_SemaineType__c FROM User WHERE Id=:userId];
        u.NOB_SemaineType__c = semaineType;
        update u;
        return u;
    }
    
    public static void addInSemaineType(List<NOB_Planning__c> plannings){
        System.debug('addInSemaineType.plannings:' + plannings);
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, NOB_SemaineType__c FROM User WHERE Id=:userId];
        String ssemaineType = u.NOB_SemaineType__c;
        Map<String,Object> semaineType = new Map<String,Object>();
        if(ssemaineType != null && ssemaineType.length() > 0){
            semaineType = (Map<String,Object>)JSON.deserializeUntyped(ssemaineType);
        }else{
            semaineType = buildEmptySemaineType();
            
        }
        
        System.debug('semaineType Before:' + JSON.serialize(semaineType));
        
        for(NOB_Planning__c planning : plannings){
            String day = getDay(planning.NOB_StartDate__c);
            String startTime = planning.NOB_StartDate__c.format('HH:mm');
            String endTime = planning.NOB_EndDate__c.format('HH:mm');
            Integer quantity =planning.NOB_Quantity__c != null? Double.valueOf(planning.NOB_Quantity__c + '').intValue(): 1;
            String type = planning.NOB_Status__c == 'Absence'? 'abs':'dispo';
            injectValue(semaineType,day,startTime, endTime,quantity,type);
        }
        System.debug('semaineType After:' + JSON.serialize(semaineType));
        u.NOB_SemaineType__c = JSON.serialize(semaineType);
        update u;
        Date until = strtodt((String)semaineType.get('until'));
        Map<String,Object> config = (Map<String,Object>)semaineType.get('config');
        semaineType.put('config', convert(config));
        applySemaineType(semaineType, until, plannings);
    }
    
    public static void injectValue(Map<String,Object> semaineType, String day, String startTime, String endTime, Integer quantity, String type){
        Map<String,Object> config = (Map<String,Object>)semaineType.get('config');
        Map<String,Object> mday = (Map<String,Object>)config.get(day);
        List<Object> mtype = (List<Object>)mday.get(type);
        if(!isPresent(mtype, startTime, endTime)){
            Map<String,Object> val = new Map<String,Object>();
            val.put('from', startTime);
            val.put('to', endTime);
            val.put('quantity', quantity);
            addInList(mtype,val);
        }
    }
    

    public static Date strtodt(String str){
        String[] parts = str.split('T')[0].split('-');
        
        
        Date t = Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
        return t;
    }    
    
    
    private static void addInList(List<Object> times, Map<String,Object> val){
        times.add(val);
        List<Planning> plList = toPlanningList(times);
        plList.sort();
        times.clear();
        for(Planning pl : plList){
            times.add(pl.toMap());
        }
    }
    
    private static List<Planning> toPlanningList(List<Object> times){
        List<Planning> result = new List<Planning>();
        for(Object otime : times){
            Map<String,Object> tm = (Map<String,Object>)otime;
            String cstart = (String)tm.get('from');
            String cend = (String)tm.get('to');
            Object oquantity = tm.get('quantity');
            Integer quantity = 1;
            if(oquantity != null){
             	quantity = Integer.valueOf(oquantity);   
            }
            //Integer quantity = (Integer)tm.get('quantity');
            Planning pl = newPlanningInstance(cstart, cend,quantity);
            result.add(pl);
        }
        return result;
    }
    
     private static Planning newPlanningInstance(String startT, String endT, Integer quantity){
        Time tstart = Time.newInstance(Integer.valueOf(startT.split(':')[0]), Integer.valueOf(startT.split(':')[1]), 0, 0);
        Time tend = Time.newInstance(Integer.valueOf(endT.split(':')[0]), Integer.valueOf(endT.split(':')[1]), 0, 0);
        Planning pl = new Planning();
        pl.endTime = tend;
        pl.quantity = quantity;
        pl.startTime = tstart;
        return pl;
    }
    
    private static boolean isPresent(List<Object> times, String startTime, String endTime){
        for(Object otime : times){
            Map<String,Object> tm = (Map<String,Object>)otime;
            String cstart = (String)tm.get('from');
            String cend = (String)tm.get('to');
            if(cstart.equals(startTime) && cend.equals(endTime)){
                return true;
            }
        }
        return false;
    }
    
    
    private static Map<String,Object> buildEmptySemaineType(){
        Map<String,Object> result = new Map<String,Object>();
        Datetime dt = Datetime.now();
        dt = dt.addDays(35);
        result.put('until', dt.format(FORMAT_LONG));
        
        Map<String,Object> mpDay = new Map<String,Object>();
        for(String key : DAYS.keySet()){
            String day = DAYS.get(key);
            Map<String,List<Map<String,Object>>> mp = new Map<String,List<Map<String,Object>>>();
            for(String type : TYPES){
                mp.put(type, new List<Map<String,Object>>());
            }
            mpDay.put(day, mp);
        }
        result.put('config', mpDay);
        
       return result;
    }
    
    private static String getDay(Datetime dt){
        String frmt = dt.format('EEEE');
        String day = DAYS.get( toFrench(frmt));
        
        return day;
    }
    
    private static Time strToTime(String str){
        String[] parts = str.split(':');
        Time t = Time.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), 0, 0);
        return t;
    }
    
    @AuraEnabled
    public static Map<String,Object> applySemaineType(Map<String,Object> semaineType,Date until){
        return applySemaineType(semaineType, until,null);
    }
    
    
    public static Map<String,Object> applySemaineType(Map<String,Object> semaineType,Date until,List<NOB_Planning__c> toExclude){
        System.debug('until:' + until);
        System.debug('semaineType:' + JSON.serialize(semaineType));
        List<User> u = [SELECT Name, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        Id accountId = u.get(0).AccountId;
        String[] days = new String[]{'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'};
        WeekPlanning wpl = getWeekPlanning((Map<Object,Object>)semaineType.get('config'));
        List<NOB_Planning__c> allPlannings = getAllSemaineTypePlannings(accountId);
        PlanningData data = new PlanningData();
        for(String day : days){
            List<Datetime> dates = getAllDates(day, until);
            for(Datetime dt :dates){
                analyse(accountId, data, dt,wpl.getDayPlanning(day), toExclude);
            }
        }
        
        for(NOB_Planning__c planning : allPlannings){
            planning.IsDelete__c=true;//WCH 08/02/2021 RSIW-12107
            if(planning.NOB_Status__c == 'Absence'){
                data.toDelete.add(planning);
            }else if(planning.NOB_Status__c == 'Disponible'){
                data.toDelete.add(planning);
            }
        }
        
        
        data.flush();
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('data', data);
        result.put('weekplanning', wpl);
        return result;
        
    }
    
    
    
    public static Map<Object,Object> convert(Map<String,Object> mp){
       
        Map<Object,Object> week = new Map<Object,Object>(); 
        
        
        for(String key : mp.keySet()){
            Object val = mp.get(key);
            if(val instanceof Map<String,Object>){
              //  Map<Object,Object> oval = convert((Map<String,Object)val);
              Map<Object,Object> oval = convert((Map<String,Object>) val);
                week.put(key,oval);
            }else if(val instanceof List<Object>){
           		List<Object> lm = (List<Object>)val;
                List<Map<Object,Object>> lo = new List<Map<Object,Object>>();
                for(Object m: lm){
                    Map<Object,Object> o = convert((Map<String,Object>)m);
                    lo.add(o);
                }
                week.put(key,lo);
            }else{
            	week.put(key, val); 
            }
        }
        return week;
    }
    
    private static WeekPlanning getWeekPlanning(Map<Object,Object> semaineType){
        WeekPlanning wpl = new WeekPlanning();
        
        for(Object day : semaineType.keySet()){
            Map<Object,Object> val = (Map<Object,Object>)semaineType.get(day);
            System.debug(day+':');
            DayPlanning dplanning = new DayPlanning();
            for(Object type : val.keySet()){
                List<Object> times = (List<Object>)val.get(type);
                System.debug(type +':');
                for(Object otime : times){
                    Map<Object,Object> mtime = (Map<Object,Object>)otime;
                    String startTime = (String)mtime.get('from');
                    String endTime = (String)mtime.get('to');
                    Integer quantity = 1;
                    if(mtime.containsKey('quantity'))
                    	quantity = Integer.valueOf(mtime.get('quantity'));
                  	dplanning.addPlanning(type.toString(), startTime, endTime, quantity);
                }   
            }
            wpl.addDayPlanning(day.toString(), dplanning);
            
            
            //System.debug(dplanning);
        }
        return wpl;
    }
    
    
    
    private static List<NOB_Planning__c> getAllSemaineTypePlannings(Id accountId){
        Datetime tm = Datetime.now();
        List<NOB_Planning__c> plannings = [SELECT Id, 
                                           NOB_IntegrerEnSemaineType__c, 
                                           NOB_DeSemaineType__c, 
                                           NOB_Status__c,
                                           Name, NOB_StartDate__c, NOB_EndDate__c, 
                                           NOB_OriginalStartDate__c, NOB_OriginalEndDate__c, NOB_BodyShop__c FROM NOB_Planning__c 
                                           WHERE NOB_StartDate__c >=: tm AND NOB_DeSemaineType__c = true AND NOB_BodyShop__c=:accountId  ORDER BY NOB_StartDate__c];
                                                                                                              
  		return plannings;
    }
    
    
    private static List<Datetime> getAllDates(String day, Datetime until){
        Datetime tmp = Datetime.now();
        List<Datetime> result = new List<Datetime>();
        while(tmp.getTime() <= until.getTime()){
            String wday = tmp.format('EEEE').toLowerCase();
            if(isSameDay(wday,day)){
                result.add(tmp);
            }
            tmp = tmp.addDays(1);
        }
        return result;
        
    }
    
    
    /*private static List<NOB_Planning__c> getAllPlanningsOn(String type, Date dt, List<NOB_Planning__c> allPlannings){
        Datetime dtmDt = Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
        String fmtTstDt = dtmDt.format('yyyyMMdd');
        List<NOB_Planning__c> result = new List<NOB_Planning__c>();
        for(NOB_Planning__c planning : allPlannings){
            DateTime startDate = planning.NOB_StartDate__c;
            String fmtDt = startDate.format('yyyyMMdd');
            
            if(fmtDt.equals(fmtTstDt)){
                if(type =='dispo'){
                    if(planning.NOB_Status__c != 'Absence'){
                        result.add(planning);
                    }
                }else{
                    if(planning.NOB_Status__c == 'Absence'){
                        result.add(planning);
                    }
                }
            }
        }
        return result;
    }*/
    
    private static boolean isSameDatetime(DateTime dt1, DateTime dt2){
        return dt1.format('yyyyddMMHHmm').equals(dt2.format('yyyyddMMHHmm'));
    }
    
    private static boolean isPresent(NOB_Planning__c plan, List<NOB_Planning__c> toExclude){
        if(toExclude == null){
            return false;
        }
        DateTime start = plan.NOB_StartDate__c;
        DateTime to = plan.NOB_EndDate__c;
        for(NOB_Planning__c planning : toExclude){
            if(isSameDateTime(planning.NOB_StartDate__c,start) && isSameDateTime(planning.NOB_EndDate__c, to)){
                return true;
            }
        }
        return false;
    }
    
    /*private static void analyse(Id accountId, PlanningData data,Datetime st, DayPlanning dayPlanning){
    	analyse(accountId,  data, st,  dayPlanning, null);
    }*/
    
    private static void analyse(Id accountId, PlanningData data,Datetime st, DayPlanning dayPlanning, List<NOB_Planning__c> toExclude){
        
        List<Planning> abss = dayPlanning.abs;
        Datetime maintenant = Datetime.now();
        Long tm = maintenant.getTime();
        for(Planning abs : abss){
            Time startTime = abs.startTime;
            Time endTime = abs.endTime;
            Datetime dtmStart = Datetime.newInstance(st.date(), startTime);
            Datetime dtmEnd = Datetime.newInstance(st.date(), endTime);
            NOB_Planning__c plan = new NOB_Planning__c();
            plan.NOB_Status__c = 'Absence';
            plan.NOB_BodyShop__c = accountId;
            plan.NOB_StartDate__c = dtmStart;
            plan.NOB_EndDate__c = dtmEnd;
            plan.NOB_Quantity__c = 1;
            plan.NOB_DeSemaineType__c = true;
            plan.RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            if(dtmStart.getTime() > tm){
                if(!isPresent(plan,toExclude)){
            		data.toInsert.add(plan);
                }
            }
        }
        
        List<Planning> dispos = dayPlanning.dispo;
        for(Planning dispo : dispos){
            Time startTime = dispo.startTime;
            Time endTime = dispo.endTime;
            Integer quantity = 1;
            if(dispo.quantity != null){
                quantity = dispo.quantity;
            }
            Datetime dtmStart = Datetime.newInstance(st.date(), startTime);
            Datetime dtmEnd = Datetime.newInstance(st.date(), endTime);
            NOB_Planning__c plan = new NOB_Planning__c();
            plan.NOB_Status__c = 'Disponible';
            plan.NOB_BodyShop__c = accountId;
            plan.NOB_StartDate__c = dtmStart;
            plan.NOB_EndDate__c = dtmEnd;
            plan.NOB_Quantity__c = quantity;
            plan.NOB_DeSemaineType__c = true;
            plan.RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            if(dtmStart.getTime() > tm){
                if(!isPresent(plan, toExclude)){
                	data.toInsert.add(plan);
                }
            }
        }
        
        
    }
    
   
    
    
    
    
    private static boolean isSameDay(String d1, String d2){
        return toFrench(d1.toLowerCase()).equalsIgnoreCase(toFrench(d2.toLowerCase()));
    }
    
    private static String toFrench( String day2){
        if(day2.equalsIgnoreCase('monday')){
            return 'lundi';
        }else if(day2.equalsIgnoreCase('tuesday')){
            return 'mardi';
        }else if(day2.equalsIgnoreCase('wednesday')){
            return 'mercredi';
        }else if(day2.equalsIgnoreCase('thursday')){
            return 'jeudi';
        }else if(day2.equalsIgnoreCase('friday')){
            return 'vendredi';
        }else if(day2.equalsIgnoreCase('saturday')){
            return 'samedi';
        }else if(day2.equalsIgnoreCase('sunday')){
            return 'dimanche';
        }
        return day2;
    }
    
    
   
    
    
    public class PlanningData{
        
        @AuraEnabled
        public List<NOB_Planning__c> toInsert = new List<NOB_Planning__c>();
        
        @AuraEnabled
        public List<NOB_Planning__c> toDelete = new List<NOB_Planning__c>();
        
        @AuraEnabled
        public List<NOB_Planning__c> toUpdate = new List<NOB_Planning__c>();
        
        @AuraEnabled
        public Integer totalRecords = 0;
        
        public void flush(){
            if(toDelete.size() > 0){
                update toDelete;//WCH 08/02/2021 RSIW-12107
            }
            if(toUpdate.size() > 0){
                update toUpdate;
            }
            
            if(toInsert.size() > 0){
                insert toInsert;
            }
            
            for(NOB_Planning__c pl: toInsert){
                totalRecords = totalRecords + pl.NOB_Quantity__c.intValue();
            }
        }
    }
    
    public class Planning implements Comparable{
        
        @AuraEnabled
        public Time startTime;
        
        @AuraEnabled
        public Time endTime;
        
        @AuraEnabled
        public Integer quantity;
        
        public override String toString(){
            Map<String,String> mp = new Map<String,String>();
            mp.put('startTime', startTime + '');
            mp.put('endTime', endTime + '');
            mp.put('quantity', quantity + '');
            return mp.toString();
        }
        
        public Integer compareTo(Object other){
            Planning opl = (Planning)other;
            Integer chr = startTime.hour();
            Integer ohr = opl.startTime.hour();
            if(chr == ohr){
                return 0;
            }else if(chr > ohr){
                return 1;
            }else{
                return -1;
            }
        }
        
        public Map<String,Object> toMap(){
            Map<String,Object> result = new Map<String,Object>();
            result.put('from', Datetime.newInstance(Date.today(), startTime).format('HH:mm'));
            result.put('to', Datetime.newInstance(Date.today(), endTime).format('HH:mm'));
            result.put('quantity', quantity);
            return result;
        }
        
        
    }
    
    public class DayPlanning{
        
        @AuraEnabled
       public List<Planning> dispo = new List<Planning>();
        
        @AuraEnabled
        public List<Planning> abs = new List<Planning>();
        
        public void addPlanning(String type, String startTime, String endTime, Integer quantity){
            Planning planning = new Planning();
            planning.startTime = strToTime(startTime);
            planning.endTime = strToTime(endTime);
            planning.quantity = quantity;
            if(type == 'abs'){
                abs.add(planning);
            }else{
                dispo.add(planning);
            }
        }
        
        public override String toString(){
            Map<String, List<Planning>> mp = new Map<String, List<Planning>>();
            mp.put('abs', abs);
            mp.put('dispo', dispo);
            return mp.toString();
        }
    }
    
    
    public class WeekPlanning{
        
        @AuraEnabled
        public Map<String,DayPlanning> dayPlannings = new Map<String,DayPlanning>();
        
        
        public void addDayPlanning(String day, DayPlanning dp){
            dayPlannings.put(day, dp);
        }
        
        public DayPlanning getDayPlanning(String day){
            return dayPlannings.get(day);
        }
    }
   

}