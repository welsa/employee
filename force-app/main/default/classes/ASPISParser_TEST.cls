/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISParser_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISParser_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 02-MAY-2016  ABT    1.0     Initial version
  ----------------------------------------------------------------------
*/
@isTest
public class ASPISParser_TEST 
{
	static User adminUser;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;
	}

	@isTest static void div_TEST()
	{
		ASPISParser parser = new ASPISParser();

		Test.startTest();
			Double returnedValue = parser.evalDouble('6/3');
		Test.stopTest();

		System.assertEquals(2, returnedValue);
	}

	@isTest static void mul_TEST()
	{
		ASPISParser parser = new ASPISParser();

		Test.startTest();
			Double returnedValue = parser.evalDouble('6*3');
		Test.stopTest();

		System.assertEquals(18, returnedValue);
	}

	@isTest static void add_TEST()
	{
		ASPISParser parser = new ASPISParser();

		Test.startTest();
			Double returnedValue = parser.evalDouble('6+3');
		Test.stopTest();

		System.assertEquals(9, returnedValue);
	}

	@isTest static void sub_TEST()
	{
		ASPISParser parser = new ASPISParser();

		Test.startTest();
			Double returnedValue = parser.evalDouble('6-3');
		Test.stopTest();

		System.assertEquals(3, returnedValue);
	}
}