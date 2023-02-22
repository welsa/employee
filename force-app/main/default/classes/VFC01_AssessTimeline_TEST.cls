/*
  ----------------------------------------------------------------------
  -- - Name          : VFC01_AssessTimeline_TEST
  -- - Author        : ABT
  -- - Description   : VFC01_AssessTimeline_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 04-MAY-2016  ABT    1.0     Reworked version
  -- 27-JUN-2016  CLA    2.0     Case C-001666 - Use directly the Assessment status to generate the timeline.
  -- 27-SEP-2016  ABT    2.1     Case C-001480 - Corrected the test method for status substitution only.
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Bhavish (sc)	01/06/2015  Original Version
  -- Shamina M		23/02/2016  case 1480 - reworked test class
 **********************************************************************
*/
@isTest
public class VFC01_AssessTimeline_TEST
{
	static User userAdmin;
	static User userBodyshop;
	static User userAspisLocal;
	static Account testBodyshop;
	static Assessment__c testAss;

	static{
		// Create different users to simulate the page displayed.
		userAdmin = TestFactory.createUser('userAdmin');
		userBodyshop = TestFactory.createUser('userBodyshop');
		userAspisLocal = TestFactory.createUser('userAspisLocal');

		// ABT - 29-SEP-2016 - C-001480 - Added insert of users
		insert new List<User>
		{
			userAdmin,
			userBodyshop,
			userAspisLocal
		};

		System.runAs(userAdmin){
			// Create a Bodyshop and a Distributor.
			testBodyshop = TestFactory.createAccountBodyshop('testBodyshop', 'ES');
			insert testBodyshop;

			// Create an Assessments
			testAss = TestFactory.createAssessment('ASSESS_TEST-0001', testBodyshop);
			insert testAss;
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 1 : Check that the step 1 is validated when the Sales Order is INACCEPTANCE, independing on which kind of user see the page.
	* @param Status INACCEPTANCE
	* @return Current Step Number = 1
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineNEW() {
		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			testAss.Status__c = 'NEW';
			testAss.AgencyMode__c = true;
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			System.assertEquals(0, VFC01.calculateSuccessfulLineWidth);
			System.assertEquals(0, VFC01.calculateFailureLineWidth);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 2 : Check that the step 2 is validated when the Sales Order is SUBSTITUTION, independing on which kind of user see the page.
	* @param Status SUBSTITUTION
	* @return Current Step Number = 2
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineSUBSTITUTION() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testAss.Status__c = 'SUBSTITUTION';

			// ABT 29-SEP-2016 - C-001480 - Added missing boolean field
			// The field HasBeenSubstituted__c becomes true by a workflow but no dml is done in this test method so boolean is set manually
			testAss.HasBeenSubstituted__c = true;

			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			// ABT 29-SEP-2016 - C-001480 - Corrected the assert which was wrong for assessment in status SUBSTITUTION
			//System.assertEquals(0,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(2, VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 3 : Check that the step 3 is validated when the Sales Order is READY, independing on which kind of user see the page.
	* @param Status READY
	* @return Current Step Number = 3
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineREADY() {
		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			testAss.Status__c = 'READY';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(2,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 4 : Check that the step 4 is validated when the Sales Order is CHECKED, independing on which kind of user see the page.
	* @param Status CHECKED
	* @return Current Step Number = 4
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineCHECKED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testAss.Status__c = 'CHECKED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(3,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 5 : Check that the step 5 is validated when the Sales Order is SOURCED, independing on which kind of user see the page.
	* @param Status SOURCED
	* @return Current Step Number = 5
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineSOURCED() {
		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			testAss.Status__c = 'SOURCED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(4,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 6 : Check that the step 6 is validated when the Sales Order is OFFERING, independing on which kind of user see the page.
	* @param Status OFFERING
	* @return Current Step Number = 6
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineOFFERING() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testAss.Status__c = 'OFFERING';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(5,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 7 : Check that the step 7 is validated when the Sales Order is INDELIVERY, independing on which kind of user see the page.
	* @param Status INDELIVERY
	* @return Current Step Number = 7
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineINDELIVERY() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testAss.Status__c = 'INDELIVERY';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(6,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}

		// Test as Bodyshop
		System.runAs(userBodyshop){
			testAss.Status__c = 'INDELIVERY';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(6,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 8 : Check that the step 8 is validated when the Sales Order is INVOICED, independing on which kind of user see the page.
	* @param Status INVOICED
	* @return Current Step Number = 8
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineINVOICED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testAss.Status__c = 'INVOICED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(7,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 9 : Check that the step 9 is validated when the Sales Order is CLOSED, independing on which kind of user see the page.
	* @param Status CLOSED
	* @return Current Step Number = 8
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineCLOSED() {
		// Test as ASPIS Local
		System.runAs(userBodyshop){
			testAss.Status__c = 'CLOSED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(8, VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}
	}

	/**
	* @author Ashutosh Betchoo
	* @date 14/12/2016
	* @description Test 12 : Check that the step 8 is validated when the Sales Order is CLOSEDOK, independing on which kind of user see the page.
	* @param Status CLOSEDOK
	* @return Current Step Number = 8
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineCLOSEDOK() {
		// Test as ASPIS Local
		System.runAs(userBodyshop){
			testAss.Status__c = 'CLOSEDOK';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(8, VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 10 : Check that the step 2 is validated when the Sales Order is CANCELED with previous status as RESPONDED, independing on which kind of user see the page.
	* @param Status CANCELED
	* @param Previous Status RESPONDED
	* @return Current Step Number = 2
	* @return hasFailed = true
	* @return maximumNumberSteps = 7
	* @return size of l_StepNumbers = 7
	*/
	@isTest static void test_salesOrderTimeLineCANCELED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testAss.PreviousStatus__c = 'NEW';
			testAss.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(true, VFC01.hasFailed);
			System.assertEquals(8, VFC01.totalNumberOfSteps);

			testAss.PreviousStatus__c = 'NEW';
			testAss.Status__c = 'REJECTED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(true, VFC01.hasFailed);
		}

		// Test as Bodyshop
		System.runAs(userBodyshop){
			testAss.PreviousStatus__c = 'NEW';
			testAss.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(true, VFC01.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 11 : Checks everything works fine even with null values
	* @param Status CANCELED
	* @param Previous Status null
	* @return Current Step Number = 1
	* @return hasFailed = true
	*
	* @param Status null
	* @param Previous Status null
	* @return Current Step Number = 0
	* @return hasFailed = false
	*/
	@isTest static void test_salesOrderTimeLineExceptions() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testAss.PreviousStatus__c = null;
			testAss.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP01_AssessTimeline);
			VFC01_AssessTimeline VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(true, VFC01.hasFailed);

			testAss.Status__c = null;
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC01 = new VFC01_AssessTimeline(new ApexPages.StandardController(testAss));

			// Check results
			System.assertEquals(1,VFC01.assessmentCurrentStepNumber);
			System.assertEquals(false, VFC01.hasFailed);
		}
	}

}