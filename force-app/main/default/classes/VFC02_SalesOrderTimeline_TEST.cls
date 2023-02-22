/*************************************************************************************
Class Name - VFC02_SalesOrderTimeline_TEST
Version - 1.0
Created Date - 29 JAN 2016
Function - TestClass to VFC02_SalesOrderTimeline

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Cecile L      29/01/2016  Original Version
*************************************************************************************/
@isTest
private class VFC02_SalesOrderTimeline_TEST {
	static User userAdmin;
	static User userBodyshop;
	static User userAspisLocal;
	static Account testBodyshop;
	static Assessment__c testAss;
	static PrerequisiteOrder__c testSO;

	static{
		// Create different users to simulate the page displayed.
		userAdmin = TestFactory.createUser('userAdmin');
		userBodyshop = TestFactory.createUser('userBodyshop');
		userAspisLocal = TestFactory.createUser('userAspisLocal');

		System.runAs(userAdmin){
			// Create a Bodyshop and a Distributor.
			testBodyshop = TestFactory.createAccountBodyshop('testBodyshop', 'ES');
			insert testBodyshop;

			// Create an Assessments
			testAss = TestFactory.createAssessment('ASSESS_TEST-0001', testBodyshop);
			insert testAss;

			// Create a Sales Order
			testSO = TestFactory.createSalesOrder(testAss, testBodyshop, 'INACCEPTANCE');
			insert testSO;
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
	@isTest static void test_salesOrderTimeLineINACCEPTANCE() {
			
		testAss.AgencyMode__c = true;
		update testAss;

		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(1,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			System.assertEquals(0, VFC02.calculateSuccessfulLineWidth);
			System.assertEquals(0, VFC02.calculateFailureLineWidth);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 2 : Check that the step 2 is validated when the Sales Order is RESPONDED, independing on which kind of user see the page.
	* @param Status RESPONDED
	* @return Current Step Number = 2
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineRESPONDED() {		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testSO.Status__c = 'RESPONDED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(2,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 3 : Check that the step 3 is validated when the Sales Order is INDELIVERY, independing on which kind of user see the page.
	* @param Status INDELIVERY
	* @return Current Step Number = 3
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineINDELIVERY() {
		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			testSO.Status__c = 'INDELIVERY';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(3,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 4 : Check that the step 4 is validated when the Sales Order is DELIVERED, independing on which kind of user see the page.
	* @param Status DELIVERED
	* @return Current Step Number = 4
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineDELIVERED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testSO.Status__c = 'DELIVERED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(4,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 5 : Check that the step 5 is validated when the Sales Order is PREORDERCONFIRMED, independing on which kind of user see the page.
	* @param Status PREORDERCONFIRMED
	* @return Current Step Number = 5
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLinePREORDERCONFIRMED() {
		// Test as Bodyshop
		System.runAs(userBodyshop){
			test.starttest();

			testSO.Status__c = 'PREORDERCONFIRMED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(5,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 6 : Check that the step 6 is validated when the Sales Order is INVOICED, independing on which kind of user see the page.
	* @param Status INVOICED
	* @return Current Step Number = 6
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineINVOICED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			test.starttest();

			testSO.Status__c = 'INVOICED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(6,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
			test.stoptest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 7 : Check that the step 7 is validated when the Sales Order is PAID, independing on which kind of user see the page.
	* @param Status PAID
	* @return Current Step Number = 7
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLinePAID() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testSO.Status__c = 'PAID';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(7,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
		}

		// Test as Bodyshop
		System.runAs(userBodyshop){
			testSO.Status__c = 'PAID';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(7,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
		}
	}

	/**
	* @author Ashutosh Betchoo
	* @date 14/12/2016
	* @description Test 7 : Check that the step 7 is validated when the Sales Order is CLOSEDOK, independing on which kind of user see the page.
	* @param Status CLOSEDOK
	* @return Current Step Number = 7
	* @return hasFailed false
	*/
	@isTest static void test_salesOrderTimeLineCLOSEDOK() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testSO.Status__c = 'CLOSEDOK';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(7, VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false, VFC02.hasFailed);
		}

		// Test as Bodyshop
		System.runAs(userBodyshop){
			testSO.Status__c = 'CLOSEDOK';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(7, VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false, VFC02.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 8 : Check that the step 2 is validated when the Sales Order is CANCELED with previous status as RESPONDED, independing on which kind of user see the page.
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
			testSO.PreviousStatus__c = 'RESPONDED';
			testSO.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(2,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(true,VFC02.hasFailed);
			System.assertEquals(7, VFC02.totalNumberOfSteps);
		}

		// Test as Bodyshop
		System.runAs(userBodyshop){
			testSO.PreviousStatus__c = 'RESPONDED';
			testSO.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(2,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(true,VFC02.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 9 : Checks everything works fine even with null values
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
			testSO.PreviousStatus__c = null;
			testSO.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02_SalesOrderTimeline VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(1,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(true,VFC02.hasFailed);

			testSO.Status__c = null;
			Test.setCurrentPage(Page.VFP02_SalesOrderTimeline);
			VFC02 = new VFC02_SalesOrderTimeline(new ApexPages.StandardController(testSO));

			// Check results
			System.assertEquals(1,VFC02.salesOrderCurrentStepNumber);
			System.assertEquals(false,VFC02.hasFailed);
		}
	}

}