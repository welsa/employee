/*************************************************************************************
Class Name - TestProcessFlow
Version - 1.0
Created Date - 
Function - TestClass to TestProcessFlow

Modification Log :
------------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Dourga U     19/01/2016  Updated for Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
*************************************************************************************/
@isTest(SeeAllData=true)
private class TestProcessFlowProblemCases2{
 
/*static User UserAdmin;
static User DistributorFrance1;
static Group TestDistributor1Group;
static Group TestDistributor2Group;

static User BodyshopFrance;
static User DistributorFrance2;
static Account BodyshopAccountFrance;
static Assessment__c testAssessment1;
static List<PartList__c> PartList;
static List<Account> Distributors;
static String DistributorRegionOfBodyshop = '99';  // This is used to only use Accounts created here, no such region as 99

static List<PurchaseOrder__c> PurchaseOrders;
static List<Case__c> Cases;    

    
static{

    Id RecordTypeBodyshop = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
    BodyshopAccountFrance = new Account(
        Name='Test Bodyshop',
        ReferenceNumber__c = 'testRefNum',
        isEligible__c = True,
        ContactEmail__c = 'testEmail@gmail.com',
        ShippingCountry = 'France',
        ShippingPostalCode = DistributorRegionOfBodyshop+'000',
        RecordTypeId=RecordTypeBodyshop
    );  
    insert BodyshopAccountFrance;

    Id UserAdminProfile = ASPISConstants.getProfileAdminId(); 
    UserAdmin = new User(
        Username = 'testADMIN-65467-x@test.com',
        LastName = '2938Adm',
        LanguageLocaleKey = 'en_US',
        FirstName = 'a84fs',
        Email = 'jean735@test.com',
        Alias = 'AdMiNI2',
        TimeZoneSidKey = 'Europe/Dublin',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = UserAdminProfile
    );       
    ASPISTestUtils.generateTestUser(UserAdmin);

     Id RecordTypeDistributor = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
     Distributors = new list<Account>{
         New Account(
             Name='TestDistributor1',
             ContactEmail__c = 'test1Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD1',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = DistributorRegionOfBodyshop,
             DistributorCarBrandSupplied__c = 'TOYOTA;PEUGEOT',
             Categories__c = 'A;B;C',
             ShippingCountry = 'France'         
         ),
         New Account(
             Name='TestDistributor2',
             ContactEmail__c = 'test2Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD2',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = DistributorRegionOfBodyshop,
             DistributorCarBrandSupplied__c = 'TOYOTA',
             Categories__c = 'A;B;C',
             ShippingCountry = 'France'
         ),
             
         // wrong shipping region
         New Account(
             Name='TestDistributor3',
             ContactEmail__c = 'test3Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD3',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = '49',
             DistributorCarBrandSupplied__c = 'TOYOTA',
             Categories__c = 'A;B;C',
             ShippingCountry = 'France'
         ),
             
         // wrong shipping country --> Spain
         New Account(
             Name='TestDistributor4',
             ContactEmail__c = 'test4Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD4',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = DistributorRegionOfBodyshop,
             DistributorCarBrandSupplied__c = 'TOYOTA',
             Categories__c = 'A;B;C',
             ShippingCountry = 'Spain'
         ),
             
         // wrong car brand
         New Account(
             Name='TestDistributor5',
             ContactEmail__c = 'test5Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD5',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = DistributorRegionOfBodyshop,
             DistributorCarBrandSupplied__c = 'NISSAN',
             Categories__c = 'A;B;C',
             ShippingCountry = 'France'
         ),
             
         // wrong product category
         New Account(
             Name='TestDistributor6',
             ContactEmail__c = 'test6Email@gmail.com',
             ReferenceNumber__c = 'testRefNumD6',
             RecordTypeId=RecordTypeDistributor,
             DistributorRegionsCovered__c = DistributorRegionOfBodyshop,
             DistributorCarBrandSupplied__c = 'TOYOTA',
             Categories__c = 'B;C',
             ShippingCountry = 'France'
         )
            
    };
    insert Distributors;    
    
    // Create Group, used for sharing objects 
    TestDistributor1Group = new Group();
    TestDistributor1Group.Name = 'DistributorFrance1';
    TestDistributor1Group.DeveloperName = 'TestDistributorGroup1';
    insert TestDistributor1Group;

    Id DistributorProfileId = [Select Id From Profile Where name = 'FR - Distributor'].Id;                
    DistributorFrance1 = new User(
        Username = 'test-241123-x@test.com',
        LastName = 'TestDistributor1',
        LanguageLocaleKey = 'en_US',
        Email = 'jean234@test.com',
        Alias = 'DistNX9',
        TimeZoneSidKey = 'Europe/Dublin',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = DistributorProfileId,
        DistributorID__c = 'testRefNumD1'
    );       
    // Create Group, used for sharing objects 
    TestDistributor2Group = new Group();
    TestDistributor2Group.Name = 'DistributorFrance2';
    TestDistributor2Group.DeveloperName = 'TestDistributorGroup2';
    insert TestDistributor2Group;
              
    DistributorFrance2 = new User(
        Username = 'test-2asd223-x@test.com',
        LastName = 'TestDistributor2',
        LanguageLocaleKey = 'en_US',
        Email = 'jeas234@test.com',
        Alias = 'DistNX9',
        TimeZoneSidKey = 'Europe/Dublin',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = DistributorProfileId,
        DistributorID__c = 'testRefNumD1'
    );  
    date mydate = date.parse('01/01/2014');
    testAssessment1 = new Assessment__c(
        Name = 'Test Assessment1',
        BodyShop__c = BodyshopAccountFrance.Id,
        Entity__c = 'AXA Direct',
        EntityCode__c = '299',
        EntityRules__c = 'FR299',
        AssessmentNumber__C = '1234',
        AssessmentID__c = '432163egsfgw2',
        VINNumber__c = '123456789',
        ClaimReference__c = '2064173',
        TECH_EntityCountryCode__c = 'FR',
        PartA__c = 2,
        Manufacturer__c = 'TOYOTA',
        ModelV2__c = 'TOYOTA', 
        FirstRegistrationDate__c = mydate,
        BuildDate__c = mydate
    );
    insert testAssessment1;
    
    PartList = new list<PartList__c>{
        New PartList__c(
            Name = 'AUX WATER RADIATOR',
            Description__c = 'AUX WATER RADIATOR',
            Type__c = 'A',
            PartNumber__c = 'G9010 47031',
            Quantity__c = 1,
            Price__c = 177.00,
            PriceOptimized__c = 177.00,
            VAT__c = 20.0,
            Assessment__c = testAssessment1.Id
        ),
        New PartList__c(
            Name = 'AUX WATER RADIATOR',
            Description__c = 'AUX WATER RADIATOR 2',
            Type__c = 'A',
            PartNumber__c = 'G9010 47030',
            Quantity__c = 1,
            Price__c = 177.00,
            PriceOptimized__c = 177.00,
            VAT__c = 20.0,
            Assessment__c = testAssessment1.Id
        )
        
     };
     insert PartList;
    

}
@isTest static void testM1() {
    test.starttest();
    
    // TEST SOURCING
    System.runAs(UserAdmin) {
        
        insert DistributorFrance1; // insert here or error --> "MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object..."
        insert DistributorFrance2;
        
        testAssessment1 = [SELECT Id, Status__c, TECHRulesAppliedDescription__c FROM Assessment__c WHERE Name = 'Test Assessment1' LIMIT 1]; 
        testAssessment1.Status__c = 'READY';
        update testAssessment1;
        PurchaseOrders = [select Id, Status__c from PurchaseOrder__c where Assessment__c =:testAssessment1.Id];
        
        System.assertEquals(2 ,PurchaseOrders.size());        
        system.debug('TEST RESULT SET NRO 1 ---- SOURCING $$$');
        system.debug('Sourcing works on checking distributor country $$$');  
        system.debug('Sourcing works on checking distributor brand suplied $$$');
        system.debug('Sourcing works on checking distributor categories $$$');
        system.debug('Sourcing works on checking distributor regions covered $$$');       

        List<OrderLine__c> OrderLines = [select Id from OrderLine__c where PurchaseOrder__c IN :PurchaseOrders];
        System.assertEquals(4 ,OrderLines.size()); // ORIGINAL: expecting 4, there are 2 PartLines per PO and 2 POs

        system.debug('POs are created, Order Lines are created $$$');         

    }
    
    // TEST OFFERING
    System.runAs(DistributorFrance1) {
        PurchaseOrder__c toBeUpdatedPO = [select Id, Status__c from PurchaseOrder__c where Id in :PurchaseOrders];
        toBeUpdatedPO.Status__c = 'CANCELED';
        toBeUpdatedPO.Comment__c = 'Testing';
    } // end running as DistributorFrance1
    
    System.runAs(DistributorFrance2) {
        PurchaseOrder__c toBeUpdatedPO = [select Id, Status__c from PurchaseOrder__c where Id in :PurchaseOrders];
        toBeUpdatedPO.Status__c = 'CANCELED';
        toBeUpdatedPO.Comment__c = 'Testing';
        update toBeUpdatedPO;
    } // end running as DistributorFrance2

    System.runAs(UserAdmin) {
        List<PrerequisiteOrder__c> createdSO = [select Id from PrerequisiteOrder__c where Bodyshop__c = :BodyshopAccountFrance.Id];
        System.assertEquals(0, createdSO.size());
        System.debug('No POs are Issued, SO is not created. $$$');

        // TEST CONTINUES IN CLASS "TestProcessFlow2"
        cases = [select Id from Case__c where Assesment__c =:TestAssessment1.Id];
        system.assertEquals(0, cases.size());
    }
    
test.stoptest();
    

}*/
    
}