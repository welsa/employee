///***************************************************************************************************************
//Class Name - Utils_BusinessDays
//Version - 1.0
//Created Date - unknown
//Function - Class to manage business hours/days methods and new cache feature

//Modification Log :
//------------------------------------------------------------------------------------------------------------------
//* Developer     Date        Description
//* ----------    ----------  --------------------------------------------------------------------------------------
//* Dourga/Shamina 14/12/2015 C-001386 - new business hours mgt
//* Ashwina S      17/02/2016 C-001452 - when regularDifferenceInHours = 0, use standard business hour method
//* Ashutosh B     03/11/2016 C-001781 - modified the calculateDifferenceBetweenBusinessDateInMinutes and the nextBusinessDay using date only
//******************************************************************************************************************/

public class Utils_BusinessDays {

//    //public Integer loopCounter = 0;

//    private Date knownSunday = date.newInstance(2012, 7, 1);

//    public BusinessHours currBusinessHours;
//    public List<Holiday> holidays;
//    //business days list from post by:
//    // Scott - August 13, 2012
//    //http://blog.internetcreations.com/2012/08/businessdays/
//    public List<Day> businessDays;

//    public Static LONG ELAPSEDDURATIONINHOURS = 60 / 60 / 1000L;
//    public Static LONG ELAPSEDDURATIONINMINUTES = 60 / 1000L;

//    //Dourga 14/12/2015 case 1386
//    //public BusinessHoursSetting__mdt currBusinessHours2 = new BusinessHoursSetting__mdt();
//    //public list <Holidays_Setting__mdt> holidays2 = new list <Holidays_Setting__mdt>();
//    public List<Day> businessDays2;

//    //Shamina M: case 1386
//    public map<String,BusinessHours> mapStdBusinessHours;
//    private final Static String DEFAULTBS = 'DEFAULT';
//    public static Boolean isInvokedFromFlow = false;
//    public final Static String BSCACHENAME = 'stdBusinessHours';
//    public final Static String HOLCACHENAME = 'stdHolidays';

//    // ABT - 14-JUL-2017 - C-001970
//    public Map<String, List<Holiday>> mapCountryCodeHolidays;

//    /*############################################################################
//    #   C.O.N.S.T.R.U.C.T.O.R
//    ##############################################################################*/
//    /*
//     * Constructor without Business Hours :
//     *  - Get the Business Hours by default.
//     ***/
//    public Utils_BusinessDays(){
//        currBusinessHours = [SELECT Id, Name, IsDefault, IsActive, TimeZoneSidKey, 
//                                    MondayEndTime, MondayStartTime, 
//                                    TuesdayEndTime, TuesdayStartTime, 
//                                    WednesdayEndTime, WednesdayStartTime, 
//                                    ThursdayEndTime, ThursdayStartTime, 
//                                    FridayEndTime, FridayStartTime, 
//                                    SaturdayEndTime, SaturdayStartTime, 
//                                    SundayEndTime, SundayStartTime
//                            FROM BusinessHours
//                            WHERE IsDefault = true];
        
//        configureBusinessWeek();

//        holidays = new List<Holiday>();

//        String countryCode = currBusinessHours.Name.substringBefore('-');
//        queryHolidays(new List<String>{countryCode + '_%'});

//        if(mapCountryCodeHolidays.containsKey(countryCode))
//        {
//            holidays = mapCountryCodeHolidays.get(countryCode);
//        }
//    }

//    // See above for a cleaner code
//    // public Utils_BusinessDays(){
//    //     //(Shamina 28/01/2016 case 1386) - this constructor is maintained for use case where SOQL is run only once
//    //     //e.g in visualforce VFC03, since cache methods cannot be executed from visualforce controller code

//    //     //loopCounter++;
//    //     //system.debug('loopCounter --> '+loopCounter);
//    //     //by default, get default
//    //     //system.debug('************* I AM LOOPING, IT IS MY FAULT 1!');
//    //     currBusinessHours = [SELECT Id, name,IsDefault, IsActive,TimeZoneSidKey
//    //                         , MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime
//    //                         , WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime
//    //                         , FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime
//    //                             FROM BusinessHours
//    //                             WHERE IsDefault=true];
//    //     holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth
//    //                 , RecurrenceMonthOfYear
//    //                 from Holiday LIMIT 100]; // WARNING: Need further information to determine if Holidays will be used, and if so, by how many country.

//    //     configureBusinessWeek();
//    //     /*
//    //     //(Dourga 14/12/2015 case 1386) -- Default business hour
//    //     currBusinessHours2 = [SELECT Id, EntityCountryCode__c, MasterLabel, FridayEndTime__c, FridayFullDay__c, FridayStartTime__c, FridayWorkedDay__c, MondayEndTime__c, MondayFullDay__c, MondayStartTime__c, MondayWorkedDay__c, SaturdayEndTime__c,
//    //                                 SaturdayFullDay__c, SaturdayStartTime__c, SaturdayWorkedDay__c, SundayEndTime__c, SundayFullDay__c, SundayStartTime__c, SundayWorkedDay__c, TuesdayEndTime__c, TuesdayFullDay__c, TuesdayStartTime__c,
//    //                                 TuesdayWorkedDay__c, ThursdayEndTime__c, ThursdayFullDay__c, ThursdayStartTime__c, ThursdayWorkedDay__c, WednesdayEndTime__c, WednesdayFullDay__c, WednesdayStartTime__c, WednesdayWorkedDay__c
//    //                         FROM BusinessHoursSetting__mdt
//    //                         WHERE MasterLabel = 'DEFAULT'];
//    //     holidays2 = [SELECT Id, ActivityDate__c, RecurrenceDayOfMonth__c, RecurrenceDayOfWeekMask__c, Description__c, RecurrenceEndDateOnly__c, EndTimeInMinutes__c, EntityCountryCode__c, RecurrenceInstance__c, RecurrenceInterval__c, IsAllDay__c,
//    //                         IsRecurrence__c, RecurrenceMonthOfYear__c, RecurrenceStartDate__c, StartTimeInMinutes__c,RecurrenceType__c
//    //                 from Holidays_Setting__mdt
//    //                 LIMIT 100];

//    //     configureBusinessWeek2();
//    //     */
//    // }

//    /*
//     * Constructor with Business Hours ID in parameters :
//     ***/
//   /*public Utils_BusinessDays(String businessHourId){
//        loopCounter++;
//        system.debug('loopCounter --> '+loopCounter);
//        system.debug('************* I AM LOOPING, IT IS MY FAULT 2!');
//        List<BusinessHours> results = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE Id =: businessHourId];
//        if(results == null || results.size() == 0)
//                system.debug('************* I AM LOOPING, IT IS MY FAULT 3!');
//            results = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime FROM BusinessHours WHERE IsDefault=true];

//        currBusinessHours = results[0];
//        holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday LIMIT 100]; // WARNING: Need further information to determine if Holidays will be used, and if so, by how many country.
//        System.debug('######## holidays:'+holidays);
//        configureBusinessWeek();
//    }*/

//    /*public Utils_BusinessDays(BusinessHours bh,List<Holiday> hol){
//        currBusinessHours = bh;
//        holidays = hol;
//        configureBusinessWeek();
//    }*/

//    /*
//     * Constructor with Assessment Country Code in parameters :
//    (Dourga 14/12/2015 case 1386)
//     ***/
//    public Utils_BusinessDays(String countryCode){

//        String query,condition = '';
//        String filter = '';
//        //System.debug('## countryCode= '+countryCode + ' ,isInvokedFromFlow = ' + isInvokedFromFlow);
//        //(Shamina 28/01/2016 case 1386) -- replaced by cache version

//        countryCode = (String.isBlank(countryCode) ? DEFAULTBS : countryCode);
//        //cannot execute cache method from process builder flow, using isInvokedFromFlow to determine if method invoked from flow
//        if(isInvokedFromFlow) {
//            if(countryCode == DEFAULTBS)
//                condition = ' where IsDefault=true ' ;
//            else{
//                filter = countryCode +'-%';
//                condition = ' where Name like :filter';
//            }

//            query = ' SELECT Id, name,IsDefault, IsActive,TimeZoneSidKey';
//            query += ' , MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime';
//            query += ' , WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime ';
//            query += ' , FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime  ';
//            query += '  FROM BusinessHours  ';
//            query += condition;

//            //System.debug('#query =' + query);
//            currBusinessHours = Database.query(query);

//            // ABT - 14-JUL-2017 - C-001970
//            holidays = new List<Holiday>();

//            // String countryCode = currBusinessHours.Name.substringBefore('-');
//            queryHolidays(new List<String>{countryCode + '_%'});

//            if(mapCountryCodeHolidays.containsKey(countryCode))
//            {
//                holidays = mapCountryCodeHolidays.get(countryCode);
//            }

//            isInvokedFromFlow = false;
//        }
//        else{
//            system.debug('## countryCode:'+countryCode);
//            init();
//            currBusinessHours = mapStdBusinessHours.get(countryCode);
            
//            // ABT - 14-JUL-2017 - C-001970
//            holidays = new List<Holiday>();
            
//            if(mapCountryCodeHolidays.containsKey(countryCode))
//            {
//                holidays = mapCountryCodeHolidays.get(countryCode);
//            }

//            system.debug('## currBusinessHours:'+currBusinessHours);
//        }
//        //system.debug('###currBusinessHours = ' + currBusinessHours);
//        configureBusinessWeek();
//        /*
//        for(BusinessHoursSetting__mdt currBH : [SELECT Id, MasterLabel, EntityCountryCode__c, FridayEndTime__c, FridayFullDay__c, FridayStartTime__c, FridayWorkedDay__c, MondayEndTime__c, MondayFullDay__c, MondayStartTime__c, MondayWorkedDay__c, SaturdayEndTime__c,
//                                    SaturdayFullDay__c, SaturdayStartTime__c, SaturdayWorkedDay__c, SundayEndTime__c, SundayFullDay__c, SundayStartTime__c, SundayWorkedDay__c, TuesdayEndTime__c, TuesdayFullDay__c, TuesdayStartTime__c,
//                                    TuesdayWorkedDay__c, ThursdayEndTime__c, ThursdayFullDay__c, ThursdayStartTime__c, ThursdayWorkedDay__c, WednesdayEndTime__c, WednesdayFullDay__c, WednesdayStartTime__c, WednesdayWorkedDay__c
//                            FROM BusinessHoursSetting__mdt
//                            WHERE MasterLabel =: countryCode]){
//            currBusinessHours2 = currBH;
//        }
//        holidays2 = [SELECT Id, ActivityDate__c, RecurrenceDayOfMonth__c, RecurrenceDayOfWeekMask__c, Description__c, RecurrenceEndDateOnly__c, EndTimeInMinutes__c, EntityCountryCode__c, RecurrenceInstance__c, RecurrenceInterval__c, IsAllDay__c,
//                            IsRecurrence__c, RecurrenceMonthOfYear__c, RecurrenceStartDate__c, StartTimeInMinutes__c,RecurrenceType__c
//                    from Holidays_Setting__mdt
//                    where EntityCountryCode__c =: countryCode
//                    LIMIT 100];

//        System.debug('## currBusinessHours2'+currBusinessHours2);
//        configureBusinessWeek2();
//        */
//    }

//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    /*
//     * Give the next business day.
//     * @return: [Date] next available business day;
//     ***/
//    public Date nextBusinessDay(Date d){
//        DateTime returnDateTime = getEndOfBusinessDayFromDate(d, 1);
//        return returnDateTime.date();
//    }

//    // returns back date in numberOfDays business days
//    public Date addBusinessDays (Date startDate, integer numberOfDays){
//        //System.debug('##addBusinessDays= '+ startDate +' ## ' + numberOfDays);
//        DateTime returnDateTime = getEndOfBusinessDayFromDate(startDate, numberOfDays);
//        //System.debug('##returnDateTime= '+ returnDateTime);
//        return returnDateTime.date();
//    }

//    // Shamina M: case 1386 - returns back datetime in numberOfDays business days
//    public DateTime addBusinessDays (Datetime startDate, integer numberOfDays){
//        //System.debug('##addBusinessDays'+ startDate +' ## ' + numberOfDays);
//        DateTime returnDateTime = getEndOfBusinessDayFromDate(startDate, numberOfDays);
//        //System.debug('##addBusinessDays2 returnDateTime= '+ returnDateTime);
//        return returnDateTime;
//    }

//    //(Dourga 14/12/2015 case 1386)
//    /*
//    public Utils_BusinessDays configureBusinessWeek2() {
//        businessDays2 = new Day[7];
//        if(currBusinessHours2.SundayStartTime__c == null || currBusinessHours2.SundayEndTime__c == null){
//            businessDays2[0] = new Day(
//                (currBusinessHours2.SundayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[0] = new Day(
//                (currBusinessHours2.SundayStartTime__c != null),
//                (currBusinessHours2.SundayStartTime__c).time(),
//                (currBusinessHours2.SundayEndTime__c).time()
//            );
//        }
//        if(currBusinessHours2.MondayStartTime__c == null || currBusinessHours2.MondayStartTime__c == null){
//            businessDays2[1] = new Day(
//                (currBusinessHours2.MondayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[1] = new Day(
//                (currBusinessHours2.MondayStartTime__c != null),
//                currBusinessHours2.MondayStartTime__c.time() ,
//                currBusinessHours2.MondayEndTime__c.time()
//            );
//        }
//        if(currBusinessHours2.TuesdayStartTime__c == null || currBusinessHours2.TuesdayStartTime__c == null){
//            businessDays2[2] = new Day(
//                (currBusinessHours2.TuesdayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[2] = new Day(
//                (currBusinessHours2.TuesdayStartTime__c != null),
//                currBusinessHours2.TuesdayStartTime__c.time() ,
//                currBusinessHours2.TuesdayEndTime__c.time()
//            );
//        }
//        if(currBusinessHours2.WednesdayStartTime__c == null || currBusinessHours2.WednesdayStartTime__c == null){
//            businessDays2[3] = new Day(
//                (currBusinessHours2.WednesdayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[3] = new Day(
//                (currBusinessHours2.WednesdayStartTime__c != null),
//                currBusinessHours2.WednesdayStartTime__c.time() ,
//                currBusinessHours2.WednesdayEndTime__c.time()
//            );
//        }
//        if(currBusinessHours2.ThursdayStartTime__c == null || currBusinessHours2.ThursdayStartTime__c == null){
//            businessDays2[3] = new Day(
//                (currBusinessHours2.ThursdayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[4] = new Day(
//                (currBusinessHours2.ThursdayStartTime__c != null),
//                currBusinessHours2.ThursdayStartTime__c.time() ,
//                currBusinessHours2.ThursdayEndTime__c.time()
//            );
//        }

//        if(currBusinessHours2.FridayStartTime__c == null || currBusinessHours2.FridayStartTime__c == null){
//            businessDays2[3] = new Day(
//                (currBusinessHours2.FridayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[5] = new Day(
//                (currBusinessHours2.FridayStartTime__c != null),
//                currBusinessHours2.FridayStartTime__c.time() ,
//                currBusinessHours2.FridayEndTime__c.time()
//            );
//        }
//        if(currBusinessHours2.SaturdayStartTime__c == null || currBusinessHours2.SaturdayEndTime__c == null){
//            businessDays2[6] = new Day(
//                (currBusinessHours2.SaturdayStartTime__c != null),
//                null ,
//                null
//            );
//        }
//        else{
//            businessDays2[6] = new Day(
//                (currBusinessHours2.SaturdayStartTime__c != null),
//                currBusinessHours2.SaturdayStartTime__c.time() ,
//                currBusinessHours2.SaturdayEndTime__c.time()
//            );
//        }
//        return this;//chainable
//    }
//    */

//    public Utils_BusinessDays configureBusinessWeek() {
//        businessDays = new Day[7];
//        businessDays[0] = new Day(
//            (currBusinessHours.SundayStartTime != null),
//            currBusinessHours.SundayStartTime ,
//            currBusinessHours.SundayEndTime
//        );
//        businessDays[1] = new Day(
//            (currBusinessHours.MondayStartTime != null),
//            currBusinessHours.MondayStartTime ,
//            currBusinessHours.MondayEndTime
//        );
//        businessDays[2] = new Day(
//            (currBusinessHours.TuesdayStartTime != null),
//            currBusinessHours.TuesdayStartTime ,
//            currBusinessHours.TuesdayEndTime
//        );
//        businessDays[3] = new Day(
//            (currBusinessHours.WednesdayStartTime != null),
//            currBusinessHours.WednesdayStartTime ,
//            currBusinessHours.WednesdayEndTime
//        );
//        businessDays[4] = new Day(
//            (currBusinessHours.ThursdayStartTime != null),
//            currBusinessHours.ThursdayStartTime ,
//            currBusinessHours.ThursdayEndTime
//        );
//        businessDays[5] = new Day(
//            (currBusinessHours.FridayStartTime != null),
//            currBusinessHours.FridayStartTime ,
//            currBusinessHours.FridayEndTime
//        );
//        businessDays[6] = new Day(
//            (currBusinessHours.SaturdayStartTime != null),
//            currBusinessHours.SaturdayStartTime ,
//            currBusinessHours.SaturdayEndTime
//        );
//        return this;//chainable
//    }

//    //used in test class only
//    public Utils_BusinessDays setBusinessHours(BusinessHours currBusinessHoursIn) {
//        currBusinessHours = currBusinessHoursIn;
//        return configureBusinessWeek();//chainable
//    }

//    //used in test class only
//    public Utils_BusinessDays setHolidays(List<Holiday> holidaysIn) {
//        holidays = holidaysIn;
//        return this;//chain
//    }
//    /*
//    public Utils_BusinessDays setBusinessHours(BusinessHoursSetting__mdt currBusinessHoursIn) {
//        currBusinessHours2 = currBusinessHoursIn;
//        return configureBusinessWeek2();//chainable
//    }

//    //used in test class only
//    public Utils_BusinessDays setHolidays(List<Holidays_Setting__mdt> holidaysIn) {
//        holidays2 = holidaysIn;
//        return this;//chain
//    }
//    */

//    public Boolean isBusinessDay(DateTime datetimeToCheck){
//        Date dateToCheck = datetimeToCheck.date();
//        for(Holiday holiday : this.holidays) {
//            if(holiday.RecurrenceType == null) {//no recurence
//                if(holiday.ActivityDate == dateToCheck) {
//                    //system.debug('***Match: ' + holiday.ActivityDate + ' - ' + dateToCheck);
//                    return false;
//                }
//            } else if(holiday.RecurrenceType == 'RecursYearly') {
//                Integer dayOfMonth = dateToCheck.day();
//                Integer monthOfYear = dateToCheck.month();
//                Integer holidayDayOfMonth = holiday.RecurrenceDayOfMonth;
//                Integer holidayMonthOfYear;

//                //big if statement to translate month to day
//                if(holiday.RecurrenceMonthOfYear == 'January') {
//                    holidayMonthOfYear = 1;
//                } else if(holiday.RecurrenceMonthOfYear == 'February') {
//                    holidayMonthOfYear = 2;
//                } else if(holiday.RecurrenceMonthOfYear == 'March') {
//                    holidayMonthOfYear = 3;
//                } else if(holiday.RecurrenceMonthOfYear == 'April') {
//                    holidayMonthOfYear = 4;
//                } else if(holiday.RecurrenceMonthOfYear == 'May') {
//                    holidayMonthOfYear = 5;
//                } else if(holiday.RecurrenceMonthOfYear == 'June') {
//                    holidayMonthOfYear = 6;
//                } else if(holiday.RecurrenceMonthOfYear == 'July') {
//                    holidayMonthOfYear = 7;
//                } else if(holiday.RecurrenceMonthOfYear == 'August') {
//                    holidayMonthOfYear = 8;
//                } else if(holiday.RecurrenceMonthOfYear == 'September') {
//                    holidayMonthOfYear = 9;
//                } else if(holiday.RecurrenceMonthOfYear == 'October') {
//                    holidayMonthOfYear = 10;
//                } else if(holiday.RecurrenceMonthOfYear == 'November') {
//                    holidayMonthOfYear = 11;
//                } else if(holiday.RecurrenceMonthOfYear == 'December') {
//                    holidayMonthOfYear = 12;
//                }
                
//                if((dayOfMonth == holidayDayOfMonth) && (monthOfYear == holidayMonthOfYear))
//                {
//                    return false;
//                }
//            }
//        }
        
//        //passed the holiday check, now lets check the business day.        
//        Integer dayOfWeek = Math.mod(this.knownSunday.daysBetween(dateToCheck),7);
        
//        return businessDays[dayOfWeek].isBusinessDay;//return the business day status
//    }

//    //(Dourga 14/12/2015 case 1386)
//    /*
//    public Boolean isBusinessDay(DateTime datetimeToCheck){
//        Date dateToCheck = datetimeToCheck.date();
//        //Shamina M: case 1386 - added check for business hour
//        //Boolean isBusinessHour = false;
//        system.debug('#datetimeToCheck = ' + datetimeToCheck);
//        for(Holidays_Setting__mdt holiday : this.holidays2) {
//            if(holiday.RecurrenceType__c == null) {//no recurence
//                if(holiday.ActivityDate__c == dateToCheck) {
//                    system.debug('***Match: ' + holiday.ActivityDate__c + ' - ' + dateToCheck);
//                    return false;
//                }
//            } else if(holiday.RecurrenceType__c == 'RecursYearly') {
//                Integer dayOfMonth = dateToCheck.day();
//                Integer monthOfYear = dateToCheck.month();
//                Integer holidayDayOfMonth = (Integer)holiday.RecurrenceDayOfMonth__c;
//                Integer holidayMonthOfYear;

//                //big if statement to translate month to day
//                if(holiday.RecurrenceMonthOfYear__c == 1) {
//                    holidayMonthOfYear = 1;
//                } else if(holiday.RecurrenceMonthOfYear__c == 2) {
//                    holidayMonthOfYear = 2;
//                } else if(holiday.RecurrenceMonthOfYear__c == 3) {
//                    holidayMonthOfYear = 3;
//                } else if(holiday.RecurrenceMonthOfYear__c == 4) {
//                    holidayMonthOfYear = 4;
//                } else if(holiday.RecurrenceMonthOfYear__c == 5) {
//                    holidayMonthOfYear = 5;
//                } else if(holiday.RecurrenceMonthOfYear__c == 6) {
//                    holidayMonthOfYear = 6;
//                } else if(holiday.RecurrenceMonthOfYear__c == 7) {
//                    holidayMonthOfYear = 7;
//                } else if(holiday.RecurrenceMonthOfYear__c == 8) {
//                    holidayMonthOfYear = 8;
//                } else if(holiday.RecurrenceMonthOfYear__c == 9) {
//                    holidayMonthOfYear = 9;
//                } else if(holiday.RecurrenceMonthOfYear__c == 10) {
//                    holidayMonthOfYear = 10;
//                } else if(holiday.RecurrenceMonthOfYear__c == 11) {
//                    holidayMonthOfYear = 11;
//                } else if(holiday.RecurrenceMonthOfYear__c == 12) {
//                    holidayMonthOfYear = 12;
//                }
//                if((dayOfMonth == holidayDayOfMonth) && (monthOfYear == holidayMonthOfYear))
//                    return false;
//            }
//        }
//        //passed the holiday check, now lets check the business day.
//        //Integer
//        //if()
//        Integer dayOfWeek = Math.mod(this.knownSunday.daysBetween(dateToCheck),7);
//        return businessDays2[dayOfWeek].isBusinessDay;//return the business day status

//    }
//    */

//    public Boolean isBusinessDay(Date dateToCheck) {
//        return isBusinessDay(DateTime.newInstance(dateToCheck, DateTime.now().time()));
//    }

//    // ABT - 14 JUL 2017 - C-001970 - Commented as it contains a bug with 0 days passed
//    // public DateTime getEndOfBusinessDayFromDate(DateTime dateStarted, Integer numberOfBusinessDays) {
//    //     Integer businessDayCounter = 0;//count of business days actually hit.
//    //     Integer dayCounter = 0;//loops through the days one at a time, starts with 1
//    //     DateTime endOfDayDateTime;
//    //     while(businessDayCounter < numberOfBusinessDays) {
//    //         //(Dourga 14/12/2015 case 1386)
//    //         if(isBusinessDay(dateStarted.addDays(dayCounter + 1))) {//check tomorrow in the loop
//    //             businessDayCounter++;
//    //         }

//    //         dayCounter++;
//    //     }
//    //     endOfDayDateTime = dateStarted.addDays(dayCounter);

//    //     return getEndOfBusinessDay(endOfDayDateTime);
//    // }

//    public DateTime getEndOfBusinessDayFromDate(Date dateStarted, Integer numberOfBusinessDays) {
//        //return getEndOfBusinessDayFromDate(DateTime.newInstance(dateStarted, DateTime.now().time()), numberOfBusinessDays);
//        // ABT 28-OCT-2016
//        return getEndOfBusinessDayFromDate(DateTime.newInstance(dateStarted, Time.newInstance(0, 0, 0, 0)), numberOfBusinessDays);
//    }

//    public DateTime getEndOfBusinessDay(DateTime dateToCast) {
//        //will return null if its not a business day, you should probably route this
//        //through another function anyways, ya know, like the one above ;)
//        //system.debug('### dateToCast= ' + dateToCast);
//        Date businessDayDate = dateToCast.date();
//        Day businessDay = getDayWrapperOfDate(businessDayDate);
//        Time businessDayEndTime =  businessDay.endTime;
//        //system.debug('### businessDayEndTime= ' + businessDayEndTime);
//        Datetime computedDateTime = null;
//        if(businessDayDate != null && businessDayEndTime != null){
//            //Shamina M: case 1386 - added check for business startTime and endtime
//            Time timeStarted = dateToCast.Time();
//            if(timeStarted < businessDay.startTime )
//                computedDateTime = DateTime.newInstance(businessDayDate, businessDay.startTime);
//            else if(timeStarted >= businessDay.startTime && timeStarted < businessDay.endTime)
//                computedDateTime = DateTime.newInstance(businessDayDate, timeStarted);
//            else if(timeStarted >= businessDay.endTime )
//            {
//                // ABT C-001781 - 03-NOV-2016
//                computedDateTime = DateTime.newInstance(businessDayDate, businessDay.endTime);
//                //computedDateTime = getEndOfBusinessDayFromDate(DateTime.newInstance(businessDayDate,businessDay.startTime),1);
//            }
//        }

//        //system.debug('### computedDateTime= ' + computedDateTime);
//        return computedDateTime;
//    }

//    // returns back date in numberOfDays business days
//    // ABT C-001781 - 03-NOV-2016
//    // public Integer calculateDifferenceBetweenBusinessDateInMinutes (DateTime startDateTime, DateTime endDateTime){
//    //     System.debug('######## BEGIN calculateDifferenceBetweenBusinessDateInMinutes');
//    //     Integer durationInMinutes = 0;
//    //     //System.debug('##startDay'+getDayWrapperOfDate(startDateTime.date()));
//    //     Day startDay = getDayWrapperOfDate(startDateTime.date());
//    //     //System.debug('##endDay');
//    //     Day endDay = getDayWrapperOfDate(endDateTime.date());
//    //
//    //     Long regularDifferenceInHours = (endDateTime.getTime() - startDateTime.getTime()) / 60 / 60 / 1000L ;
//    //     //System.debug('##regularDifferenceInHours= ' + regularDifferenceInHours);
//    //     // Case 1: The 2 dates are separated by more than 24 regular hours.
//    //     // Count the business days then convert them to minutes.
//    //     if( regularDifferenceInHours >= 24 ){
//    //         Integer elapsedBusinessDays = 0;
//    //         Date dateCounter = startDateTime.date();
//    //         while(dateCounter < endDateTime) {
//    //             // check if we don't pass the end time.
//    //             if(DateTime.newInstance(nextBusinessDay(dateCounter), startDateTime.time()) <= endDateTime) {
//    //                 elapsedBusinessDays++;
//    //             }
//    //             dateCounter = nextBusinessDay(dateCounter);
//    //         }
//    //         durationInMinutes += elapsedBusinessDays * 24 * 60;
//    //
//    //         // Calculate if we have extra hours and minutes
//    //         if( Math.mod(regularDifferenceInHours, 24) > 0 ){
//    //             Long elapsedTime = 0;
//    //             if(startDateTime.time() < endDateTime.time()){
//    //                  Time timeBeforeEndBusinessHours = getElapsedTime(startDateTime.time(), endDateTime.time());
//    //                 elapsedTime = timeBeforeEndBusinessHours.Hour() * 60 + timeBeforeEndBusinessHours.minute();
//    //             } else {
//    //                 Time timeBeforeEndBusinessHours = getElapsedTime(startDateTime.time(), startDay.endTime); //.getTime() / 60 / 1000L;
//    //                 Time timeAfterBeginBusinessHours = getElapsedTime(endDay.startTime, endDateTime.time()); //.getTime() / 60 / 1000L;
//    //                 Long timeWorkingStartDayInMin = (timeBeforeEndBusinessHours.hour() * 60) + timeBeforeEndBusinessHours.minute();
//    //                 Long timeWorkingEndDayInMin = (timeAfterBeginBusinessHours.hour() * 60) + timeAfterBeginBusinessHours.minute();
//    //                 elapsedTime =  timeWorkingStartDayInMin + timeWorkingEndDayInMin;
//    //             }
//    //             durationInMinutes += elapsedTime.intValue();
//    //         }
//    //     }
//    //     /**************************************************
//    //     // ASE: 2016/02/17: commenting this condition. when hour is less than 1, regularDifferenceInHours returns O.
//    //     // when regularDifferenceInHours returns O, use standard function in else part below.
//    //     // Case 3: Less or equal to than 0 regular hours separate the 2 dates.
//    //    /* else if(regularDifferenceInHours <= 0){
//    //         durationInMinutes = 0;
//    //     }*/
//    //     // Case 3: Less than 24 regular hours separate the 2 dates.
//    //     // Use the standard method to calculate the business hours.
//    //    /*********************************/
//    //     else {
//    //         //Shamina M:case 1386
//    //         durationInMinutes = (BusinessHours.diff(currBusinessHours.Id, startDateTime, endDateTime) / 60 / 1000L).intValue();
//    //         //durationInMinutes = (BusinessHours.diff(currBusinessHours2.Id, startDateTime, endDateTime) / 60 / 1000L).intValue();
//    //     }
//    //     System.debug('######## END calculateDifferenceBetweenBusinessDateInMinutes');
//    //     return durationInMinutes;
//    // }
//    //
//    // public static Time GetElapsedTime(Time startTime, Time endTime) {
//    //     if(startTime == null || endTime == null)
//    //         return Time.newInstance(0, 0, 0, 0);
//    //
//    //     Integer elapsedHours = endTime.hour() - startTime.hour();
//    //     Integer elapsedMinutes = endTime.minute() - startTime.minute();
//    //     Integer elapsedSeconds = endTime.second() - startTime.second();
//    //     Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
//    //
//    //     return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
//    // }

//    public Integer calculateDifferenceBetweenBusinessDateInMinutes(DateTime startDateTime, DateTime endDateTime)
//    {
//        Integer durationInMinutes = (BusinessHours.diff(currBusinessHours.Id, startDateTime, endDateTime) / 60 / 1000L).intValue();

//        return durationInMinutes;
//    }

//    // returns the wrapper class Day of business day
//    public Day getDayWrapperOfDate(Date businessDayDate){
//        //System.debug('##dayOfWeek');
//        integer dayOfWeek = Math.mod(this.knownSunday.daysBetween(businessDayDate),7);
//        //(Dourga 14/12/2015 case 1386)
//        //System.debug('##dayOfWeek2'+dayOfWeek);
//        //System.debug('##dayOfWeek3'+businessDays2);
//        //Day businessDay = this.businessDays2[dayOfWeek];
//        Day businessDay = this.businessDays[dayOfWeek];
//        return businessDay;
//    }

//    public class Day {
//        public Boolean isBusinessDay;
//        public Time startTime;
//        public Time endTime;

//        public Day(Boolean isBusinessDayIn, Time startTimeIn, Time endTimeIn) {
//            this.isBusinessDay = isBusinessDayIn;
//            this.startTime = startTimeIn;
//            this.endTime = endTimeIn;
//        }
//    }

//    // ABT - 14-JUL-2017 - C-001970 - Commented see below
//    //Shamina M: case 1386 method to initialise business hour map and holidays list
//    // public void init(){
//    //     mapStdBusinessHours= new map<String,BusinessHours>();
//    //     String key = '';

//    //     //add business hours in cache if does not already exist
//    //     if (!Cache.Org.contains(BSCACHENAME)) {
//    //         for(BusinessHours bs: [SELECT Id, name,IsDefault, IsActive,TimeZoneSidKey, 
//    //                                     MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, 
//    //                                     WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, 
//    //                                     FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, 
//    //                                     SundayEndTime, SundayStartTime
//    //                             FROM BusinessHours
//    //                             where IsActive = true]){
//    //             if(bs.IsDefault)
//    //                 mapStdBusinessHours.put(DEFAULTBS, bs);

//    //             //if BS name contains -, e.g FR-France, extract the country code as map key, else take full name
//    //             key = (String)bs.Name;
//    //             key = ( key.contains('-') ? key.left(key.indexof('-')) : key);
//    //             mapStdBusinessHours.put(key, bs);
//    //         }
//    //         Cache.Org.put(BSCACHENAME, mapStdBusinessHours);
//    //     }
//    //     else
//    //        mapStdBusinessHours = (map<String,BusinessHours>)Cache.Org.get(BSCACHENAME);

//    //     //add holidays in cache if does not already exist
//    //     if (!Cache.Org.contains(HOLCACHENAME)) {
//    //         holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear
//    //                     from Holiday LIMIT 100];
//    //         Cache.Org.put(HOLCACHENAME, holidays);
//    //     }
//    //     else
//    //        holidays = (list<Holiday>)Cache.Org.get(HOLCACHENAME);

//    // }

//    public void removeBusinessHourCache() {
//        //Shamina M: 20160128 - case 1386
//        //use this method with caution as it will remove stored cached records for business hours and holidays
//        //execute constructor method to initialise new cached data
//        Cache.Org.remove(BSCACHENAME);
//        Cache.Org.remove(HOLCACHENAME);
//    }

//    private void initialiseHolidayMap()
//    {
//        mapCountryCodeHolidays = new Map<String, List<Holiday>>();

//        if(mapStdBusinessHours != null && mapStdBusinessHours.size() > 0)
//        {
//            for(String countryCode : mapStdBusinessHours.keySet())
//            {
//                mapCountryCodeHolidays.put(countryCode, new List<Holiday>());
//            }
//        }
//    }

//    private void populateBusinessHourHolidays(List<Holiday> holidayList)
//    {
//        initialiseHolidayMap();

//        for(Holiday currentHoliday : holidayList)
//        {
//            String holidayPrefix = currentHoliday.Name.substringBefore('_');

//            if(holidayPrefix == 'ALL')
//            {
//                // add in all country codes
//                addHolidayInAllCountries(currentHoliday);
//            }
//            else
//            {
//                // add in the specific country
//                addHolidayInSpecificCountry(holidayPrefix, currentHoliday);
//            }
//        }
//    }

//    private void addHolidayInSpecificCountry(String holidayPrefix, Holiday currentHoliday)
//    {
//        if(mapCountryCodeHolidays.containsKey(holidayPrefix))
//        {
//            mapCountryCodeHolidays.get(holidayPrefix).add(currentHoliday);
//        }
//        else
//        {
//            mapCountryCodeHolidays.put(holidayPrefix, new List<Holiday>{currentHoliday});
//        }
//    }

//    private void addHolidayInAllCountries(Holiday currentHoliday)
//    {
//        for(String countryCode : mapCountryCodeHolidays.keySet())
//        {
//            mapCountryCodeHolidays.get(countryCode).add(currentHoliday);
//        }
//    }

//    private void queryHolidays(List<String> holidayPrefixList)
//    {
//        // Add ALL_ to add the holidays for all countries in the query
//        holidayPrefixList.add('ALL_%');

//         List<Holiday> holidayList = [SELECT  Id, Name, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear
//                                     FROM    Holiday
//                                     WHERE   Name LIKE: holidayPrefixList
//                                     LIMIT   100];

//        populateBusinessHourHolidays(holidayList);
//    }

//    public void init()
//    {
//        mapStdBusinessHours= new Map<String, BusinessHours>();

//        // add business hours in cache if does not already exist
//        if (!Cache.Org.contains(BSCACHENAME)) 
//        {
//            for(BusinessHours currentBusinessHour: [SELECT  Id, Name, IsDefault, IsActive, TimeZoneSidKey, 
//                                                            MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, 
//                                                            WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, 
//                                                            FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, 
//                                                            SundayEndTime, SundayStartTime
//                                                    FROM    BusinessHours
//                                                    where   IsActive = true])
//            {
//                if(currentBusinessHour.IsDefault)
//                {
//                    mapStdBusinessHours.put(DEFAULTBS, currentBusinessHour);
//                }

//                String key = currentBusinessHour.Name.substringBefore('-');
//                mapStdBusinessHours.put(key, currentBusinessHour);
//            }

//            Cache.Org.put(BSCACHENAME, mapStdBusinessHours);
//        }
//        else
//        {
//           mapStdBusinessHours = (Map<String, BusinessHours>) Cache.Org.get(BSCACHENAME);
//        }

//        //add holidays in cache if does not already exist
//        if (!Cache.Org.contains(HOLCACHENAME))
//        {
//            List<String> holidayPrefixList = buildHolidayPrefixList(mapStdBusinessHours.keySet());
            
//            queryHolidays(holidayPrefixList);

//            Cache.Org.put(HOLCACHENAME, mapCountryCodeHolidays);
//        }
//        else
//        {
//           mapCountryCodeHolidays = (Map<String, List<Holiday>>) Cache.Org.get(HOLCACHENAME);
//        }
//    }

//    private List<String> buildHolidayPrefixList(Set<String> prefixSet)
//    {
//        List<String> holidayPrefixList = new List<String>();

//        for(String currentPrefix : prefixSet)
//        {
//            holidayPrefixList.add(currentPrefix + '_%');
//        }

//        return holidayPrefixList;
//    }

//    public DateTime getEndOfBusinessDayFromDate(DateTime dateStarted, Integer numberOfBusinessDays)
//    {
//        // needs to add the number of business days in the date passed as parameter
//        Integer dayCounter = 0;
//        // the number of business days passed
//        Integer businessDayPassed = 0;

//        if(numberOfBusinessDays == 0)
//        {
//            do
//            {
//                // check if the current date it is a business day
//                if(isBusinessDay(dateStarted.addDays(dayCounter)))
//                {
//                    businessDayPassed++;
//                }

//                dayCounter++;
//            }
//            while((businessDayPassed < (numberOfBusinessDays + 1)));

//            return getEndOfBusinessDay(dateStarted.addDays(dayCounter - 1));
//        }
//        else
//        {
//            do
//            {
//                // check if the current date it is a business day
//                if(isBusinessDay(dateStarted.addDays(dayCounter + 1)))
//                {
//                    businessDayPassed++;
//                }

//                dayCounter++;
//            }
//            while((businessDayPassed < numberOfBusinessDays));

//            return getEndOfBusinessDay(dateStarted.addDays(dayCounter));
//        }
//    }
}