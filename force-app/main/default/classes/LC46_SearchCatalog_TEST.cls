@isTest
/*
----------------------------------------------------------------------
-- - Name          : LC46_SearchCatalog
-- - Author        : DUN
-- - Description   : Test Class for lightning component LC46_SearchCatalog
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-APR-2019  DMG   1.0      Initial version
----------------------------------------------------------------------*/
private class LC46_SearchCatalog_TEST {
    static User adminUser;

    static{
        
        //create userRole
        UserRole alphaUserRole = new UserRole(Name = 'FR - AlphaScale');
        insert alphaUserRole;
        UserRole alphaUserRoleES = new UserRole(Name = 'BE - AlphaScale');
        insert alphaUserRoleES;

        //inserting users
        adminUser = TestFactory.createUser('adminUser');
        adminUser.UserRoleId = alphaUserRole.Id;
        adminUser.IAMPartClass__c = 'A;B';
       
        insert adminUser;

    }

    @isTest static void test_getBrands() {
        system.debug('## Starting test method test_getBrands');
        System.runAs(adminUser){    
            Test.startTest();
                List <LC46_SearchCatalog.allBrandsWrapper> lstResult = new List <LC46_SearchCatalog.allBrandsWrapper>();
                lstResult = LC46_SearchCatalog.getBrands();
            Test.stopTest();
            system.assert(lstResult.size() > 0); //check if we have a list of picklist options
        }   
    }
    
    @isTest static void test_getCrossRef() {
        System.runAs(adminUser){    
            Test.startTest();
                map<String,Object> lstResult = new map<String,Object>();
                lstResult = LC46_SearchCatalog.getCrossRef('7701065737;7711130007;6025370197;','Renault');
            Test.stopTest();
            system.assert(lstResult.size() > 0);
        }   
    }
    
}