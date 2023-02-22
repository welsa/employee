/*************************************************************************************
Class Name - RESTGetOrderLineReport_Test
Version - 1.0
Created Date - 19 Oct 2015
Function - Test class for the order line report JSON creation

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Immo Salo    18/10/2015   Original Version 
* Dourga U     07/10/2016   No longer in use
*************************************************************************************/
@isTest
private class RESTGetOrderLineReport_Test {

/*static User UserAdmin; 
static User DistributorFrance1;
static Group TestDistributor1Group;
static map <String,Id> accRecordTypeMap = new map <String,Id>();
static map <String,Id> proRecordTypeMap = new map <String,Id>();
    
static User BodyshopFrance;
static Account BodyshopAccountFrance;
static Assessment__c testAssessment1;
static List<PartList__c> PartList;
static List<Account> Distributors;
static String DistributorRegionOfBodyshop = '99';

static List<PurchaseOrder__c> PurchaseOrders;
static List<OrderLine__c> OrderLines;
static List<PrerequisiteOrder__c> SalesOrders;

    
static{
    
    Id RecordTypeBodyshop = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
    BodyshopAccountFrance = new Account(
        Name='Test Bodyshop',
        ReferenceNumber__c = 'testRefNum',
        isEligible__c = True,
        ContactEmail__c = 'testEmail@gmail.com',
        ShippingCountry = 'France',
        ShippingPostalCode = DistributorRegionOfBodyshop+'000',
        RecordTypeId=RecordTypeBodyshop,
        VAT__c =10
    );  
    insert BodyshopAccountFrance;
    
    Id UserAdminProfile = ASPISConstants.getProfileAdminId();
    UserAdmin = new User(
        Username = 'testADMIN-41244-x@15test.com',
        LastName = '2938Ad73m',
        LanguageLocaleKey = 'en_US',
        FirstName = 'a8412s',
        Email = 'jean269@test.com',
        Alias = 'AdMdsas9',
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
             ShippingCountry = 'France',
             VAT__c =10         
         )
    };
    insert Distributors;    
    
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
  
    date mydate1 = date.parse('01/01/2014');
    date mydate2 = date.parse('16/09/2015');
    testAssessment1 = new Assessment__c(
        Name = 'Test Assessment1',
        BodyShop__c = BodyshopAccountFrance.Id,
        Entity__c = 'AXA Direct',
        EntityCode__c = '299',
        EntityRules__c = '299',
        AssessmentNumber__C = '1234',
        AssessmentID__c = '4321sdfs463442312rqefdsv',
        VINNumber__c = '123456789',
        ClaimReference__c = '2064150',
        PartA__c = 2,
        Manufacturer__c = 'TOYOTA',
        ModelV2__c = 'TOYOTA',
        BuildDate__c = mydate1,
        Status__c = 'OFFERING',
        MaximumValidityDate__c = mydate2,
        MinimumValidityDate__c = mydate2
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


         
    
        
    SalesOrders = New list<PrerequisiteOrder__c>{
        new PrerequisiteOrder__c(
            BodyShop__c = BodyshopAccountFrance.Id,
            Assessment__c = testAssessment1.Id,
            Status__c = 'INACCEPTANCE',
            RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId()
        )
    };
    insert SalesOrders;

    PurchaseOrders = New list<PurchaseOrder__c>{
        New PurchaseOrder__c(
            Distributor__c = Distributors[0].Id,
            Assessment__c = testAssessment1.Id,
            PrerequisiteOrder__c = SalesOrders[0].Id,
            Status__c = 'ISSUED',
            ValidityDate__c = mydate2  // has to be in the future
        )
    };
    insert PurchaseOrders;
    
    OrderLines = New list<OrderLine__c>{
        new OrderLine__c(
            PurchaseOrder__c = PurchaseOrders[0].Id,
            ExpectedDeliveryDuration__c = '1',
            CataloguePrice__c  = 177.00,
            Suppliable__c =  'YES',
            OrderType__c = 'FINAL',
            Quantity__c = 1,
            DeliveryStatus__c = 'DELIVERED', // used to sync with Offer__c
            RealDeliveryDate__c = date.today(),
            TechFinalTotalAxaPrice__c = 100.00,
            //TechGeneratedFinal__c = true, 
            AdditionnalDiscount__c = 20,
            VAT__c = 20,
            PartList__c = PartList[0].Id,
            PartNumber__c = '1234'
        ),
        new OrderLine__c(
            PurchaseOrder__c = PurchaseOrders[0].Id,
            ExpectedDeliveryDuration__c = '1',
            CataloguePrice__c  = 177.00,
            Suppliable__c =  'YES',
            OrderType__c = 'FINAL',
            Quantity__c = 2,
            DeliveryStatus__c = 'DELIVERED', // used to sync with Offer__c
            RealDeliveryDate__c = date.today(),
            TechFinalTotalAxaPrice__c = 100.00,
            //TechGeneratedFinal__c = true,
            AdditionnalDiscount__c = 20,
            VAT__c = 20,
            PartList__c = PartList[1].Id,
            PartNumber__c = '1235'
        )
    };
    insert OrderLines;
}



  @isTest static void testGetOrderLines() {

    system.runAs(UserAdmin){
      
        System.RestContext.request = new RestRequest();
  		System.RestContext.response = new RestResponse();
  		RestContext.request.requestURI = '/services/apexrest/getOrderLineReport/';  //Request URL
  		RestContext.request.httpMethod = 'GET';
        
		RestContext.request.addParameter('isTest', 'yes');
        
  		List<Map<String,String>> results = RESTGetOrderLineReport.getOrderLineReport();
        system.debug('$$$$$$ RESULTS ARE...: '+results);
        system.assertEquals(true, results != null);
	
    }
  }*/


}