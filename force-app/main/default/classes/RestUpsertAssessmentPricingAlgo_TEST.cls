@isTest
private class RestUpsertAssessmentPricingAlgo_TEST {
/*
----------------------------------------------------------------------
-- - Name          : RestUpsertAssessmentPricingAlgo_TEST
-- - Author        : AMI
-- - Description   : Test class for RestUpsertAssessmentPricingAlgo
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-FEB-2018  AMI   1.0      Initial version
-- 28-SEP-2020  KPA   1.1      C-003930 : IG Test Classes
----------------------------------------------------------------------
**********************************************************************
*/	
	static User adminUser; 

    static{
        adminUser = TestFactory.createUser('adminUser');
    }    
        
	@isTest static void testPricingFrance() {
		system.debug('## Start testPricingFrance');

		System.runAs(adminUser){
			//initialise input param
			map <string,object> inputParam = new map <string,object>();

			//initialise response
			map <string,object> response = new map <string,object>();

			//defne input param
			inputParam.put('entity','fr');
			inputParam.put('isIG',true); //KPA C-003930
            inputParam.put('discount',0.15);
            inputParam.put('CatalogPrice',123.0);
            inputParam.put('AlphaScaleDiscount',0.20);

            Test.startTest();
                response = RestUpsertAssessmentPricingAlgo.returnUpdatedPrices(inputParam);
            Test.stopTest();
		}

		system.debug('## End testPricingFrance');
	}

  
   //KPA C-003930

	@isTest static void testPricingFrance_isIGfalse() {
		system.debug('## Start testPricingFrance');

		System.runAs(adminUser){
			//initialise input param
			map <string,object> inputParam = new map <string,object>();

			//initialise response
			map <string,object> response = new map <string,object>();

			//defne input param
			inputParam.put('entity','fr');
			inputParam.put('isIG',false);
            inputParam.put('discount',0.15);
            inputParam.put('CatalogPrice',123.0);
            inputParam.put('AlphaScaleDiscount',0.20);

            Test.startTest();
                response = RestUpsertAssessmentPricingAlgo.returnUpdatedPrices(inputParam);
            Test.stopTest();
		}

		system.debug('## End testPricingFrance');
	}


    //KPA C-003930

	@isTest static void testisIG() {
		system.debug('## Start testisIG');

		System.runAs(adminUser){
			//initialise input param
			map <string,object> inputParam = new map <string,object>();

			//initialise response
			map <string,object> response = new map <string,object>();

			//defne input param
			inputParam.put('entity','fr');
			inputParam.put('isIG',true);
            inputParam.put('discount',0.15);
            inputParam.put('CatalogPrice',123.0);
            inputParam.put('AlphaScaleDiscount',0.20);

            Test.startTest();
                response = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParam);
            Test.stopTest();
		}

		system.debug('## End testisIG');
	}
 
}