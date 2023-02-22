/*************************************************************************************
Class Name - VFC03_PurchaseOrderTimeline_TEST
Version - 1.0
Created Date - 29 JAN 2016
Function - TestClass to VFC03_PurchaseOrderTimeline

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      29/01/2016  Original Version
* Dourga U      16/01/2018  case C-002135: Agency Mode V2 (added agency mode on PO)
*************************************************************************************/
@isTest
private class VFC03_PurchaseOrderTimeline_TEST {
	static User userAdmin;
	static User userDistributor;
	static User userAspisLocalChina;
	static User userAspisLocal;
	static Account testBodyshop;
	static Account testDistributor;
	static Assessment__c testAss;
	static PrerequisiteOrder__c testSO;
	static PurchaseOrder__c testPO;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static{
		// Create different users to simulate the page displayed.
		userAdmin = TestFactory.createUser('userAdmin');
		userDistributor = TestFactory.createUserDistributor('userDistributor');
		userAspisLocal = TestFactory.createUserASPISLocal('userAspisLocal');
		userAspisLocalChina = TestFactory.createUserASPISLocal('userAspisLocalChina');
		userAspisLocalChina.CountryCode = 'CH';

		insert userAspisLocalChina;

		System.runAs(userAdmin){
			// Get Business Hours by default
			//List<BusinessHours> l_allBH = [SELECT Id,Name FROM BusinessHours WHERE isActive = true];
			//list<CountryCodeInformationsMapping__c> cList = new list<CountryCodeInformationsMapping__c>();
			//// Create the Custom Settings CountryCodeInformationsMapping__c to define the business hours based on the country
			//For(BusinessHours bh : l_allBH){
			//    if(bh.Name.left(3).right(1) == '-'){
			//        System.debug('######cla '+(bh.Name).Left(2));
			//        CountryCodeInformationsMapping__c ccim = TestFactory.createCountryCodeInformationsMapping((bh.Name).Left(2), bh.Id);
			//        cList.add(ccim);
			//    }
			//}

			//if(cList.size() > 0){
			//    insert cList;
			//}

			// access Business Hours
			defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('IT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
			};

			insert countryMappingList;


			// create SLA settings
			MasterRules__c ruleSet = TestFactory.createRuleSetSLAPOQuotation('FR999');
			insert ruleSet;

			MasterRules__c masterRule = TestFactory.createMasterRuleSLAPOQuotation('FR999', ruleSet);
			insert MasterRule;

			List<DetailRule__c> l_criterias = TestFactory.createListCriteriasSLAPOQuotation('FR999', masterRule, '2', '3', '4', 'H');
			insert l_criterias;

			// Create a Bodyshop and a Distributor.
			testBodyshop = TestFactory.createAccountBodyshop('testBodyshop', 'FR');
			insert testBodyshop;
			testDistributor = TestFactory.createAccountDistributor('testDistributor', 'FR');
			insert testDistributor;

			// Create an Assessments
			testAss = TestFactory.createAssessment('ASSESS_TEST-0001', testBodyshop);
			insert testAss;

			// Create a Sales Order
			testSO = TestFactory.createSalesOrder(testAss, testBodyshop, 'INACCEPTANCE');
			insert testSO;

			// Create a Purchase Order
			testPO = TestFactory.createPurchaseOrder(testAss, testSO, testBodyshop, testDistributor, 'DRAFTQUOTE');
			testPO.SLAQuotationEntryDate__c = dateTime.newInstance(2016, 1, 29, 17, 30, 0);
			insert testPO;

			// create an Orderline for the PO
			OrderLine__c ol = TestFactory.createOrderLineFinal(20, testPO, 'INPROCESS');
			ol.Suppliable__c = 'YES';
			insert ol;
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 1 : Check that the step 1 is validated when the Sales Order is DRAFTQUOTE, independing on which kind of user see the page.
	* @param Status DRAFTQUOTE
	* @return Current Step Number = 1
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineDRAFTQUOTE() {
		// Test as Distributor
		System.runAs(userDistributor){
			Test.startTest();

			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(1,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			System.assertEquals(0, VFC03.calculateSuccessfulLineWidth);
			System.assertEquals(0, VFC03.calculateFailureLineWidth);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 2 : Check that the step 2 is validated when the Sales Order is RESPONDED, because the PO go immediately on ISSUED step.
	* @param Status RESPONDED
	* @return Current Step Number = 2
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineRESPONDED() {

		testPO.Status__c = 'RESPONDED';
		testPO.AgencyMode__c = true;
		update testPO;
		update testAss;

		// ABT 21-MAY-2017 - Added TechAgencyMode__c as test class was failing		
		PurchaseOrder__c lastVersionPO = [SELECT Invoice__c,Status__c, prerequisiteOrder__c, PreviousStatus__c, AgencyMode__c,
 										  SLAQuotationEntryDate__c,SLAQuotationLevel1__c,SLAQuotationLevel2__c,SLAQuotationLevel3__c,
										  TECHSLAQuotationIsLevel1__c,TECHSLAQuotationIsLevel2__c,TECHSLAQuotationIsLevel3__c, TotalInvoicesAmount__c, InvoiceStatus__c, Reason__c FROM PurchaseOrder__c WHERE Id=:testPO.Id];

		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			Test.startTest();
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(lastVersionPO));

			// Check results
			System.assertEquals(2,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 2 : Check that the step 2 is validated when the Sales Order is ISSUED, independing on which kind of user see the page.
	* @param Status ISSUED
	* @return Current Step Number = 2
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineISSUED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			Test.startTest();

			testPO.Status__c = 'ISSUED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(2,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 3 : Check that the step 3 is validated when the Sales Order is ORDERED, independing on which kind of user see the page.
	* @param Status ORDERED
	* @return Current Step Number = 3
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineORDERED() {
		// Test as Distributor
		System.runAs(userDistributor){
			Test.startTest();

			testPO.Status__c = 'ORDERED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(3,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 4 : Check that the step 4 is validated when the Sales Order is INDELIVERY, independing on which kind of user see the page.
	* @param Status INDELIVERY
	* @return Current Step Number = 4
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineINDELIVERY() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			Test.startTest();

			testPO.Status__c = 'INDELIVERY';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(4,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 5 : Check that the step 5 is validated when the Sales Order is DELIVERED, independing on which kind of user see the page.
	* @param Status DELIVERED
	* @return Current Step Number = 5
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineDELIVERED() {
		// Test as Distributor
		System.runAs(userDistributor){
			Test.startTest();

			testPO.Status__c = 'DELIVERED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(5,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 6 : Check that the step 6 is validated when the Sales Order is DELIVEREDCONFIRMED, independing on which kind of user see the page.
	* @param Status DELIVEREDCONFIRMED
	* @return Current Step Number = 6
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineDELIVEREDCONFIRMED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			Test.startTest();

			testPO.Status__c = 'DELIVEREDCONFIRMED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(6,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
			Test.stopTest();
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 7 : Check that the step 7 is validated when the Sales Order is PAYABLE, independing on which kind of user see the page.
	* @param Status PAYABLE
	* @return Current Step Number = 7
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLinePAYABLE() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testPO.Status__c = 'PAYABLE';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(7,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
		}

		// Test as Distributor
		System.runAs(userDistributor){
			testPO.Status__c = 'PAYABLE';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(7,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 8 : Check that the step 8 is validated when the Sales Order is PAID, independing on which kind of user see the page.
	* @param Status PAID
	* @return Current Step Number = 8
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLinePAID() {
		// Test as Distributor
		System.runAs(userDistributor){
			testPO.Status__c = 'PAID';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(8,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
		}
	}

	/**
	* @author Ashutosh Betchoo
	* @date 14/12/2016
	* @description Test 13 : Check that the step 8 is validated when the Sales Order is CLOSEDOK, independing on which kind of user see the page.
	* @param Status CLOSEDOK
	* @return Current Step Number = 8
	* @return hasFailed false
	*/
	@isTest static void test_PurchaseOrderTimeLineCLOSEDOK() {
		// Test as Distributor
		System.runAs(userDistributor){
			testPO.Status__c = 'CLOSEDOK';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(8,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 9 : Check that the step 2 is validated when the Sales Order is CANCELED with previous status as ISSUED, independing on which kind of user see the page.
	* @param Status CANCELED
	* @param Previous Status ISSUED
	* @return Current Step Number = 2
	* @return hasFailed = true
	* @return maximumNumberSteps = 8
	* @return size of l_StepNumbers = 8
	*/
	@isTest static void test_PurchaseOrderTimeLineCANCELED() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testPO.PreviousStatus__c = 'ISSUED';
			testPO.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(2,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(true,VFC03.hasFailed);
			System.assertEquals(8, VFC03.totalNumberOfSteps);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 10 : Check that the step 3 is validated when the Sales Order is REJECTED with previous status as ORDERED, independing on which kind of user see the page.
	* @param Status REJECTED
	* @param Previous Status ORDERED
	* @return Current Step Number = 3
	* @return hasFailed = true
	*/
	@isTest static void test_PurchaseOrderTimeLineREJECTED() {
		// Test as Distributor
		System.runAs(userDistributor){
			testPO.PreviousStatus__c = 'ORDERED';
			testPO.Status__c = 'REJECTED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(3,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(true,VFC03.hasFailed);
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
	@isTest static void test_PurchaseOrderTimeLineExceptions() {
		// Test as ASPIS Local
		System.runAs(userASPISLocal){
			testPO.PreviousStatus__c = null;
			testPO.Status__c = 'CANCELED';
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(1,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(true,VFC03.hasFailed);

			testPO.Status__c = null;
			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(testPO));

			// Check results
			System.assertEquals(1,VFC03.purchaseOrderCurrentStepNumber);
			System.assertEquals(false,VFC03.hasFailed);
		}
	}

	/**
	* @author Cecile L
	* @date 29/01/2016
	* @description Test 12 : Checks Business Hours
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
	@isTest static void test_PurchaseOrderTimeLineBusinessHours() {
		// Test as ASPIS Local

		PurchaseOrder__c lastVersionPO ;
		System.runAs(userAdmin){

			// Create a Purchase Order
			/*PurchaseOrder__c testPObh = TestFactory.createPurchaseOrder(testAss, testSO, testBodyshop, testDistributor, 'DRAFTQUOTE');
			testPObh.SLAQuotationEntryDate__c = dateTime.newInstance(2016, 1, 1, 11, 0, 0);
			insert testPObh; */

			// ABT 21-MAY-2017 - Added TechAgencyMode__c as test class was failing
			lastVersionPO = [SELECT Invoice__c,Status__c, prerequisiteOrder__c, PreviousStatus__c, AgencyMode__c,
										  SLAQuotationEntryDate__c,SLAQuotationLevel1__c,SLAQuotationLevel2__c,SLAQuotationLevel3__c,
										  TECHSLAQuotationIsLevel1__c,TECHSLAQuotationIsLevel2__c,TECHSLAQuotationIsLevel3__c, TotalInvoicesAmount__c, InvoiceStatus__c, Reason__c FROM PurchaseOrder__c WHERE Id=:testPO.Id];

			Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(lastVersionPO));

			// Check results
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 9, 30, 0),lastVersionPO.SLAQuotationLevel1__c);
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 10, 30, 0),lastVersionPO.SLAQuotationLevel2__c);
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 11, 30, 0),lastVersionPO.SLAQuotationLevel3__c);
		}

		System.runAs(userAspisLocalChina){

			// Create a Purchase Order
			//PurchaseOrder__c testPObh = TestFactory.createPurchaseOrder(testAss, testSO, testBodyshop, testDistributor, 'DRAFTQUOTE');
			//testPObh.SLAQuotationEntryDate__c = dateTime.newInstance(2016, 1, 1, 11, 0, 0);
			//insert testPObh;
		   //PurchaseOrder__c lastVersionPO = [SELECT Invoice__c,Status__c, prerequisiteOrder__c, PreviousStatus__c,
		   //                               SLAQuotationEntryDate__c,SLAQuotationLevel1__c,SLAQuotationLevel2__c,SLAQuotationLevel3__c,
		   //                               TECHSLAQuotationIsLevel1__c,TECHSLAQuotationIsLevel2__c,TECHSLAQuotationIsLevel3__c, TotalInvoicesAmount__c, InvoiceStatus__c, Reason__c FROM PurchaseOrder__c WHERE Id=:testPO.Id];

		   // Test.setCurrentPage(Page.VFP03_PurchaseOrderTimeline);
			VFC03_PurchaseOrderTimeline VFC03 = new VFC03_PurchaseOrderTimeline(new ApexPages.StandardController(lastVersionPO));

			// Check results
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 9, 30, 0),lastVersionPO.SLAQuotationLevel1__c);
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 10, 30, 0),lastVersionPO.SLAQuotationLevel2__c);
			System.assertEquals(dateTime.newInstance(2016, 2, 1, 11, 30, 0),lastVersionPO.SLAQuotationLevel3__c);
		}
	}
}