/*
  ----------------------------------------------------------------------
  -- - Name          : Utils_BusinessDays_TEST
  -- - Author        : ABT
  -- - Description   : Test class for Utils_BusinessDays
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 28-OCT-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class Utils_BusinessDays_TEST
{
	//static User adminUser;
	//static List<BusinessHours> businessHoursList;
	//static List<Holiday> holidayList;

	//static
	//{
	//	adminUser = TestFactory.createUser('adminUser');

	//	insert adminUser;

	//	System.runAs(adminUser)
	//	{
	//		businessHoursList = new List<BusinessHours>
	//		{
	//			new BusinessHours
	//			(
	//				MondayStartTime		= Time.newInstance(9, 0, 0, 0),
	//				MondayEndTime		= Time.newInstance(18, 0, 0, 0),
	//				TuesdayStartTime 	= Time.newInstance(9, 0, 0, 0),
	//				TuesdayEndTime 		= Time.newInstance(18, 0, 0, 0),
	//				WednesdayStartTime 	= Time.newInstance(9, 0, 0, 0),
	//				WednesdayEndTime 	= Time.newInstance(18, 0, 0, 0),
	//				ThursdayStartTime 	= Time.newInstance(9, 0, 0, 0),
	//				ThursdayEndTime 	= Time.newInstance(18, 0, 0, 0),
	//				FridayStartTime 	= Time.newInstance(9, 0, 0, 0),
	//				FridayEndTime 		= Time.newInstance(18, 0, 0, 0),
	//				IsActive 			= true,
	//				IsDefault 			= true
	//			)
	//		};

	//		holidayList = new List<Holiday>
	//		{
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Christmas Eve',
	//				ActivityDate 			= Date.newInstance(2016, 12, 24),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'December',
	//				RecurrenceDayOfMonth 	= 24
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Christmas',
	//				ActivityDate 			= Date.newInstance(2016, 12, 25),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'December',
	//				RecurrenceDayOfMonth 	= 25
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_New Year',
	//				ActivityDate 			= Date.newInstance(2016, 1, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'January',
	//				RecurrenceDayOfMonth 	= 1
	//			)
	//		};
	//	}
	//}

	//@isTest static void constructor_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		// Creating an instance of the business days
	//		// but as the business days in the System may change at any time we are going to use the BusinessHours in the test class
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays();

	//		Test.startTest();
	//			businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//			businessDaysInstance.setHolidays(holidayList);
	//		Test.stopTest();

	//		// The first index in the businessDays is Sunday
	//		System.assertEquals(null, businessDaysInstance.businessDays[0].startTime);
	//		System.assertEquals(null, businessDaysInstance.businessDays[0].endTime);
	//		System.assertEquals(false, businessDaysInstance.businessDays[0].isBusinessDay);

	//		// Monday
	//		System.assertEquals(businessHoursList[0].MondayStartTime, businessDaysInstance.businessDays[1].startTime);
	//		System.assertEquals(businessHoursList[0].MondayEndTime, businessDaysInstance.businessDays[1].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[1].isBusinessDay);

	//		// Tuesday
	//		System.assertEquals(businessHoursList[0].TuesdayStartTime, businessDaysInstance.businessDays[2].startTime);
	//		System.assertEquals(businessHoursList[0].TuesdayEndTime, businessDaysInstance.businessDays[2].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[2].isBusinessDay);

	//		// Wednesday
	//		System.assertEquals(businessHoursList[0].WednesdayStartTime, businessDaysInstance.businessDays[3].startTime);
	//		System.assertEquals(businessHoursList[0].WednesdayEndTime, businessDaysInstance.businessDays[3].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[3].isBusinessDay);

	//		// Thursday
	//		System.assertEquals(businessHoursList[0].ThursdayStartTime, businessDaysInstance.businessDays[4].startTime);
	//		System.assertEquals(businessHoursList[0].ThursdayEndTime, businessDaysInstance.businessDays[4].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[4].isBusinessDay);

	//		// Friday
	//		System.assertEquals(businessHoursList[0].FridayStartTime, businessDaysInstance.businessDays[5].startTime);
	//		System.assertEquals(businessHoursList[0].FridayEndTime, businessDaysInstance.businessDays[5].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[5].isBusinessDay);
			
	//		// Saturday
	//		System.assertEquals(null, businessDaysInstance.businessDays[6].startTime);
	//		System.assertEquals(null, businessDaysInstance.businessDays[6].endTime);
	//		System.assertEquals(false, businessDaysInstance.businessDays[6].isBusinessDay);

	//		// No of holidays
	//		System.assertEquals(holidayList.size(), businessDaysInstance.holidays.size());
	//	}
	//}

	//@isTest static void constructorWithDefault_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		// Creating an instance of the business days
	//		// but as the business days in the System may change at any time we are going to use the BusinessHours in the test class
	//		Test.startTest();
	//			Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays(null);
	//			businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//			businessDaysInstance.setHolidays(holidayList);
	//		Test.stopTest();

	//		// Checking if the currBusinessHours is not null
	//		System.assertNotEquals(null, businessDaysInstance.currBusinessHours);

	//		// The first index in the businessDays is Sunday
	//		System.assertEquals(null, businessDaysInstance.businessDays[0].startTime);
	//		System.assertEquals(null, businessDaysInstance.businessDays[0].endTime);
	//		System.assertEquals(false, businessDaysInstance.businessDays[0].isBusinessDay);

	//		// Monday
	//		System.assertEquals(businessHoursList[0].MondayStartTime, businessDaysInstance.businessDays[1].startTime);
	//		System.assertEquals(businessHoursList[0].MondayEndTime, businessDaysInstance.businessDays[1].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[1].isBusinessDay);

	//		// Tuesday
	//		System.assertEquals(businessHoursList[0].TuesdayStartTime, businessDaysInstance.businessDays[2].startTime);
	//		System.assertEquals(businessHoursList[0].TuesdayEndTime, businessDaysInstance.businessDays[2].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[2].isBusinessDay);

	//		// Wednesday
	//		System.assertEquals(businessHoursList[0].WednesdayStartTime, businessDaysInstance.businessDays[3].startTime);
	//		System.assertEquals(businessHoursList[0].WednesdayEndTime, businessDaysInstance.businessDays[3].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[3].isBusinessDay);

	//		// Thursday
	//		System.assertEquals(businessHoursList[0].ThursdayStartTime, businessDaysInstance.businessDays[4].startTime);
	//		System.assertEquals(businessHoursList[0].ThursdayEndTime, businessDaysInstance.businessDays[4].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[4].isBusinessDay);

	//		// Friday
	//		System.assertEquals(businessHoursList[0].FridayStartTime, businessDaysInstance.businessDays[5].startTime);
	//		System.assertEquals(businessHoursList[0].FridayEndTime, businessDaysInstance.businessDays[5].endTime);
	//		System.assertEquals(true, businessDaysInstance.businessDays[5].isBusinessDay);
			
	//		// Saturday
	//		System.assertEquals(null, businessDaysInstance.businessDays[6].startTime);
	//		System.assertEquals(null, businessDaysInstance.businessDays[6].endTime);
	//		System.assertEquals(false, businessDaysInstance.businessDays[6].isBusinessDay);

	//		// No of holidays
	//		System.assertEquals(holidayList.size(), businessDaysInstance.holidays.size());
	//	}
	//}

	//@isTest static void constructorInvokedFromFlowWithDefault_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Test.startTest();
	//			Utils_BusinessDays.isInvokedFromFlow = true;
	//			Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays(null);
	//		Test.stopTest();

	//		// Checking if the currBusinessHours is not null
	//		System.assertNotEquals(null, businessDaysInstance.currBusinessHours);
	//	}
	//}

	//@isTest static void constructorInvokedFromFlowWithFR_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Test.startTest();
	//			Utils_BusinessDays.isInvokedFromFlow = true;
	//			Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays('FR');
	//		Test.stopTest();

	//		// Checking if the currBusinessHours is not null
	//		System.assertNotEquals(null, businessDaysInstance.currBusinessHours);
	//	}
	//}

	//@isTest static void isBusinessDay_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		// adding holidays for all months and also a non recurring holiday
	//		holidayList.addAll(new List<Holiday>
	//		{
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Feb',
	//				ActivityDate 			= Date.newInstance(2016, 2, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'February',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Mar',
	//				ActivityDate 			= Date.newInstance(2016, 3, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'March',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Apr',
	//				ActivityDate 			= Date.newInstance(2016, 4, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'April',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_May',
	//				ActivityDate 			= Date.newInstance(2016, 5, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'May',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Jun',
	//				ActivityDate 			= Date.newInstance(2016, 6, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'June',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Jul',
	//				ActivityDate 			= Date.newInstance(2016, 7, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'July',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Aug',
	//				ActivityDate 			= Date.newInstance(2016, 8, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'August',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Sep',
	//				ActivityDate 			= Date.newInstance(2016, 9, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'September',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Oct',
	//				ActivityDate 			= Date.newInstance(2016, 10, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'October',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Nov',
	//				ActivityDate 			= Date.newInstance(2016, 11, 1),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'November',
	//				RecurrenceDayOfMonth 	= 1
	//			),
	//			new Holiday
	//			(
	//				Name 					= 'ALL_Nov',
	//				ActivityDate 			= Date.newInstance(2016, 11, 2),
	//				IsRecurrence			= false
	//			)
	//		});

	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays();
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(holidayList);

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Friday 23/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 23)));
	//			// Saturday 24/12/2016
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 24)));
	//			// Sunday 25/12/2016
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 25)));
	//			// Monday 26/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 26)));
	//			// Tuesday 27/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 27)));
	//			// Wednesday 28/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 28)));
	//			// Thursday 29/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 29)));
	//			// Friday 30/12/2016
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 30)));
	//			// Saturday 31/12/2016
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 12, 31)));
	//			// Sunday 1/1/2017
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2017, 1, 1)));

	//			// Now the holidays recurring every year
	//			// This means that each year whatever the day is it will be a holiday
	//			// Christmas Eve
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2017, 12, 24)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2018, 12, 24)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2019, 12, 24)));
	//			// Christmas
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2017, 12, 25)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2018, 12, 25)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2019, 12, 25)));
	//			// New Year
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2017, 1, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2018, 1, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2019, 1, 1)));

	//			// Asserting all the holiday of each month
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 2, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 3, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 4, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 5, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 6, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 7, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 8, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 9, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 10, 1)));
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 11, 1)));

	//			// Asserting non recurring holiday
	//			System.assertEquals(false, businessDaysInstance.isBusinessDay(Date.newInstance(2016, 11, 2)));
	//			System.assertEquals(true, businessDaysInstance.isBusinessDay(Date.newInstance(2017, 11, 2)));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void nextBusinessDay_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays();
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(holidayList);

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Friday 23/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 23)));
	//			// Saturday 24/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 24)));
	//			// Sunday 25/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 25)));
	//			// Monday 26/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 27), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 26)));
	//			// Tuesday 27/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 28), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 27)));
	//			// Wednesday 28/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 29), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 28)));
	//			// Thursday 29/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 30), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 29)));
	//			// Friday 30/12/2016
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 30)));
	//			// Saturday 31/12/2016
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.nextBusinessDay(Date.newInstance(2016, 12, 31)));
	//			// Sunday 1/1/2017
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.nextBusinessDay(Date.newInstance(2017, 1, 1)));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void addBusinessDayWithDate_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays();
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(holidayList);

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Friday 23/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 23), 1));
	//			// Saturday 24/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 24), 1));
	//			// Sunday 25/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 26), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 25), 1));
	//			// Monday 26/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 27), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 26), 1));
	//			// Tuesday 27/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 28), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 27), 1));
	//			// Wednesday 28/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 29), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 28), 1));
	//			// Thursday 29/12/2016
	//			System.assertEquals(Date.newInstance(2016, 12, 30), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 29), 1));
	//			// Friday 30/12/2016
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 30), 1));
	//			// Saturday 31/12/2016
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.addBusinessDays(Date.newInstance(2016, 12, 31), 1));
	//			// Sunday 1/1/2017
	//			System.assertEquals(Date.newInstance(2017, 1, 2), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 1, 1), 1));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void addBusinessDayWithDateTime_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays();
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(holidayList);

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Friday 23/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 26, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 23, 9, 0, 0), 1));
	//			// Saturday 24/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 26, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 24, 9, 0, 0), 1));
	//			// Sunday 25/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 26, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 25, 9, 0, 0), 1));
	//			// Monday 26/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 27, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 26, 9, 0, 0), 1));
	//			// Tuesday 27/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 28, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 27, 9, 0, 0), 1));
	//			// Wednesday 28/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 29, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 28, 9, 0, 0), 1));
	//			// Thursday 29/12/2016
	//			System.assertEquals(DateTime.newInstance(2016, 12, 30, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 29, 9, 0, 0), 1));
	//			// Friday 30/12/2016
	//			System.assertEquals(DateTime.newInstance(2017, 1, 2, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 30, 9, 0, 0), 1));
	//			// Saturday 31/12/2016
	//			System.assertEquals(DateTime.newInstance(2017, 1, 2, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 31, 9, 0, 0), 1));
	//			// Sunday 1/1/2017
	//			System.assertEquals(DateTime.newInstance(2017, 1, 2, 9, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2017, 1, 1, 9, 0, 0), 1));

	//			// Now testing with different times
	//			// Friday 23/12/2016 After Hours
	//			System.assertEquals(DateTime.newInstance(2016, 12, 26, 18, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 23, 20, 0, 0), 1));
	//			System.assertEquals(DateTime.newInstance(2016, 12, 27, 18, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 23, 20, 0, 0), 2));
	//			System.assertEquals(DateTime.newInstance(2016, 12, 28, 18, 0, 0), businessDaysInstance.addBusinessDays(DateTime.newInstance(2016, 12, 23, 20, 0, 0), 3));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void removeBusinessHourCache_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays(null);
			
	//		Test.startTest();
	//			businessDaysInstance.removeBusinessHourCache();
	//		Test.stopTest();

	//		// Checking if the there is no business hour in the cache
	//		System.assertEquals(false, Cache.Org.contains(Utils_BusinessDays.BSCACHENAME));
	//	}
	//}

	//@isTest static void constructorUsingCache_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays(null);
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(holidayList);

	//		Test.startTest();
	//			Utils_BusinessDays businessDaysInstanceWithCache = new Utils_BusinessDays(null);
	//			businessDaysInstanceWithCache.setBusinessHours(businessHoursList[0]);
	//			businessDaysInstanceWithCache.setHolidays(holidayList);
	//		Test.stopTest();

	//		System.assertEquals(true, Cache.Org.contains(Utils_BusinessDays.BSCACHENAME));
	//	}
	//}

	//@isTest static void calculateDifferenceBetweenBusinessDateInMinutes_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays(null);
	//		businessDaysInstance.setHolidays(holidayList);

	//		// As the standard diff function is used the default business hours will be used
	//		// therefore cannot use the business hours in the test data, it depends on the business hour being default in the Org

	//		Test.startTest();
	//			// Friday 23/12/2016
	//			System.assertEquals(10 * 60, 
	//			businessDaysInstance.calculateDifferenceBetweenBusinessDateInMinutes(
	//				DateTime.newInstance(2016, 12, 23, 8, 0, 0), 
	//				DateTime.newInstance(2016, 12, 23, 18, 0, 0)));
	//			// Saturday 24/12/2016 - a non business day
	//			System.assertEquals(0, businessDaysInstance.calculateDifferenceBetweenBusinessDateInMinutes(
	//				DateTime.newInstance(2016, 12, 24, 8, 0, 0), DateTime.newInstance(2016, 12, 24, 20, 0, 0)));
	//			// Sunday 25/12/2016 - a non business day
	//			System.assertEquals(0, businessDaysInstance.calculateDifferenceBetweenBusinessDateInMinutes(
	//				DateTime.newInstance(2016, 12, 25, 8, 0, 0), DateTime.newInstance(2016, 12, 25, 20, 0, 0)));
	//			// Monday 26/12/2016 to Tuesday 27/12/2016
	//			// 10 * 60 + 10 * 60
	//			System.assertEquals(2 * (10 * 60), businessDaysInstance.calculateDifferenceBetweenBusinessDateInMinutes(
	//				DateTime.newInstance(2016, 12, 26, 8, 0, 0), DateTime.newInstance(2016, 12, 27, 18, 0, 0)));
	//			// Friday 23/12/2016 to Monday 26/12/2016
	//			// 10 * 60 + 10 * 60
	//			System.assertEquals(2 * (10 * 60), businessDaysInstance.calculateDifferenceBetweenBusinessDateInMinutes(
	//				DateTime.newInstance(2016, 12, 23, 8, 0, 0), DateTime.newInstance(2016, 12, 26, 18, 0, 0)));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void addBusinessDayWithDateFR_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays('FR');
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(new List<Holiday>
	//		{
	//			new Holiday
	//			(
	//				Name 					= 'FR_FêteNational',
	//				ActivityDate 			= Date.newInstance(2017, 7, 14),
	//				RecurrenceType 			= 'RecursYearly',
	//				RecurrenceMonthOfYear 	= 'July',
	//				RecurrenceDayOfMonth 	= 14
	//			)
	//		});

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Monday 17/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 17), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 0));
	//			// Monday 17/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 17), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 1));
	//			// Tuesday 18/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 18), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 2));
	//			// Wednesday 19/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 19), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 3));
	//		Test.stopTest();
	//	}
	//}

	//@isTest static void addBusinessDayWithDateES_TEST()
	//{
	//	System.runAs(adminUser)
	//	{
	//		Utils_BusinessDays businessDaysInstance = new Utils_BusinessDays('ES');
	//		businessDaysInstance.setBusinessHours(businessHoursList[0]);
	//		businessDaysInstance.setHolidays(new List<Holiday>());

	//		// Cannot make it dynamic as the year changes the same days will change
	//		// therefore to make these asserts we are going to fix the dates
	//		Test.startTest();
	//			// Friday 14/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 14), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 0));
	//			// Monday 17/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 17), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 1));
	//			// Tuesday 18/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 18), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 2));
	//			// Wednesday 19/07/2017
	//			System.assertEquals(Date.newInstance(2017, 7, 19), businessDaysInstance.addBusinessDays(Date.newInstance(2017, 7, 14), 3));
	//		Test.stopTest();
	//	}
	//}
}