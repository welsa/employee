@isTest
private class AspisBatch_NewDistUserCreation_TEST
/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_NewDistUserCreation_TEST
-- - Author        : WCH

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-MAY-2021  WCH   1.0      Initial version
----------------------------------------------------------------------
*/
{
    static list <User> userList;
    static List <Account> lstAccount;
    static List <Contact> lstContact;
    static Map <string,string> mapProfileKey;
    static Map <string,string> mapUserRoleKey;
    static
    {
        //initialising user
        userList                                        = new list <User>{TestFactory.createUser('adminUser')};
        insert userList;
        mapProfileKey = new Map <string,string>();
        mapUserRoleKey = new Map <string,string>();
        List<Profile> distributorProfile = [select Id,name from Profile where name in ('FR - Distributor','Distributor')];
        for(Profile currentProfile:distributorProfile){
            if(currentProfile.name.contains('FR')){
                mapProfileKey.put('FR', (currentProfile.Name+';'+currentProfile.Id));
            }else{
                mapProfileKey.put('OTHERS', (currentProfile.Name+';'+currentProfile.Id));
            }
        }
        List<UserRole> distributorUserRole = [select Id,name from UserRole where name in ('BE - AlphaScale','DE - AlphaScale','ES - AlphaScale','FR - AlphaScale')];
        for(UserRole currentUR:distributorUserRole){
            mapUserRoleKey.put(currentUR.name.left(2), currentUR.Id);
        }

        system.runAs(userList[0]){
            //creating BS account
            lstAccount                                  = new List <Account>{TestFactory.createAccountDistributor('Distributorv1', 'FR'),
                                                                                TestFactory.createAccountDistributor('Distributorv2', 'DE'),
                                                                                TestFactory.createAccountDistributor('Distributorv3', 'ES'),
                                                                                TestFactory.createAccountDistributor('Distributorv4', 'BE'),
                                                                                TestFactory.createAccountDistributor('Distributorv5', 'BE')};

            lstAccount[0].CCUsername__c                 = 'NewDistUserCreationv1@test.com';
            lstAccount[0].ContactEmail__c               = 'NewDistUserCreationv1@test.com';
            lstAccount[0].Locale__c                     = 'French';
            lstAccount[0].Communities_Target_Profile__c = mapProfileKey.get('FR');
            lstAccount[0].Tech_DistriutorUserRoleId__c = mapUserRoleKey.get('FR');
            lstAccount[0].Phone                         = '4543333';
            lstAccount[0].Fax                           = '122333';
            lstAccount[0].createDistributorUser__c      = true;
            lstAccount[0].ReferenceNumber__c            = 'FR0000033333';//WCH 23/12/2020 C-004120
            lstAccount[0].ShippingStreet                = 'aaa';
            lstAccount[0].ShippingCity                  = 'bbb';
            lstAccount[0].ShippingPostalCode            = '456';
            lstAccount[0].ShippingCountry               = 'France';
            lstAccount[0].ShippingState               = 'Lot';

            lstAccount[1].CCUsername__c                 = 'NewCommunityUserCreationBodyShopv2@test.com';
            lstAccount[1].ContactEmail__c               = 'NewCommunityUserCreationBodyShopv2@test.com';
            lstAccount[1].Locale__c                     = 'German';
            lstAccount[1].Communities_Target_Profile__c = mapProfileKey.get('OTHERS');
            lstAccount[1].Tech_DistriutorUserRoleId__c = mapUserRoleKey.get('DE');
            lstAccount[1].BillingStreet__c              = 'xxx';
            lstAccount[1].BillingCity__c                    = 'yyy';
            lstAccount[1].BillingPostalCode__c          = '123';
            lstAccount[1].BillingCountry__c                 = 'Germany';
            lstAccount[1].Phone                         = '4543333';
            lstAccount[1].Fax                           = '122333';
            lstAccount[1].ReferenceNumber__c            = 'DE00000v1';
            lstAccount[1].createDistributorUser__c      = true;
            lstAccount[1].ShippingStreet                = 'aaa';
            lstAccount[1].ShippingCity                  = 'bbb';
            lstAccount[1].ShippingPostalCode            = '456';
            lstAccount[1].ShippingCountry               = 'Germany';

            lstAccount[2].CCUsername__c                 = 'NewCommunityUserCreationBodyShopv3@test.com';
            lstAccount[2].ContactEmail__c               = 'NewCommunityUserCreationBodyShopv3@test.com';
            lstAccount[2].Locale__c                     = 'Spanish';
            lstAccount[2].Communities_Target_Profile__c = mapProfileKey.get('OTHERS');
            lstAccount[2].Tech_DistriutorUserRoleId__c = mapUserRoleKey.get('ES');
            lstAccount[2].ShippingStreet                = 'aaa';
            lstAccount[2].ShippingCity                  = 'bbb';
            lstAccount[2].ShippingPostalCode            = '456';
            lstAccount[2].ShippingCountry               = 'Spain';
            lstAccount[2].Phone                         = '4543333';
            lstAccount[2].Fax                           = '122333';
            lstAccount[2].ReferenceNumber__c            = 'ES00000v2';
            lstAccount[2].createDistributorUser__c      = true;

            lstAccount[3].CCUsername__c                 = 'NewCommunityUserCreationBodyShopv4@test.com';
            lstAccount[3].ContactEmail__c               = 'NewCommunityUserCreationBodyShopv4@test.com';
            lstAccount[3].Locale__c                     = 'FrenchBelgium';
            lstAccount[3].Communities_Target_Profile__c = mapProfileKey.get('OTHERS');
            lstAccount[3].Tech_DistriutorUserRoleId__c = mapUserRoleKey.get('BE');
            lstAccount[3].createDistributorUser__c      = true;
            lstAccount[3].ShippingStreet                = 'aaa';
            lstAccount[3].ShippingCity                  = 'bbb';
            lstAccount[3].ShippingPostalCode            = '456';
            lstAccount[3].ShippingCountry               = 'Belgium';
            lstAccount[3].ContactUser__c               = userList[0].Id;

            lstAccount[4].CCUsername__c                 = 'NewCommunityUserCreationBodyShopv5@test.com';
            lstAccount[4].ContactEmail__c               = 'NewCommunityUserCreationBodyShopv5@test.com';
            lstAccount[4].Locale__c                     = 'DutchBelgium';
            lstAccount[4].Communities_Target_Profile__c = mapProfileKey.get('OTHERS');
            lstAccount[4].Tech_DistriutorUserRoleId__c = mapUserRoleKey.get('BE');
            lstAccount[4].createDistributorUser__c      = true;
            lstAccount[4].ShippingStreet                = 'aaa';
            lstAccount[4].ShippingCity                  = 'bbb';
            lstAccount[4].ShippingPostalCode            = '456';
            lstAccount[4].ShippingCountry               = '';

            insert lstAccount;


            string BypassTrigger                        = 'AccountTrigger;AssessmentTrigger;CaseTriggerHandler;DetailRuleTrigger;' 
                                                        + 'DiscountTrigger;InvoiceTrigger;MasterRuleTrigger;OfferTrigger;'
                                                        + 'OrderLineTrigger;PrerequisiteOrderTrigger;PurchaseOrderTrigger;'
                                                        + 'UserTrigger';
            //inserting bypass
            Bypass__c customSetting                     = new Bypass__c(Name = 'testBypass',
                                                                        SetupOwnerId = userList[0].Id,
                                                                        BypassValidationRules__c = true,
                                                                        BypassWorkflows__c = true,
                                                                        BypassTrigger__c = BypassTrigger);

            Database.upsert(customSetting, Bypass__c.Name.getDescribe().getSObjectField(), false);
        }//end system.runAs
    }//end static

    @isTest static void NewCommunityUserCreationTest(){
        system.runAs(userList[0]){
            //start test
            Test.startTest();
                AspisBatch_NewDistributorUserCreation batch = new AspisBatch_NewDistributorUserCreation();
                Database.executeBatch(batch);
            Test.stopTest();

            //assert
            List<Account> lstAcc = [SELECT id FROM Account WHERE Id IN :lstAccount];
            //System.assertEquals(5,lstAcc.size());
        }
    }
    
    
    
}