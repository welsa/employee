/*************************************************************************************
Class Name - TestVFC_PrintPartListForBodyshop
Version - 1.0
Created Date - 20 Nov 2015
Function - test class for VFC_PrintPartListForBodyshop

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Immo S                20/11/2015  Original Version
************************************************************************************/
@isTest
public class TestVFC_PrintPartListForBodyshop{
    // ABT 02-DEC-2016 - C-001625
/*
static User UserAdmin; 
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
static List<Offer__c> Offers;  

    
static{
    
    Id UserAdminProfile = ASPISConstants.getProfileAdminId();
    UserAdmin = new User(
        Username = 'testADMIN-1g432s-x@test.com',
        LastName = '44f8Adm',
        LanguageLocaleKey = 'en_US',
        FirstName = 'sd44t',
        Email = 'jeanf23e5@test.com',
        Alias = 'AdMiNa33',
        TimeZoneSidKey = 'Europe/Dublin',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = UserAdminProfile
    );       
    ASPISTestUtils.generateTestUser(UserAdmin);
    System.runAs(UserAdmin) {
    
        Id DistributorProfileId = [Select Id From Profile Where name = 'FR - Distributor'].Id;

        DistributorFrance1 = new User(
            Username = 'test-w1dasd23-x@test.com',
            LastName = 'TestDistributor1',
            LanguageLocaleKey = 'en_US',
            Email = 'jean2ewd2@test.com',
            Alias = 'DistfRX9',
            TimeZoneSidKey = 'Europe/Dublin',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = DistributorProfileId,
            DistributorID__c = 'testRefNumD1'
        );  
        insert DistributorFrance1;
        
        Id RecordTypeBodyshop = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
        BodyshopAccountFrance = new Account(
            Name='Test Bodyshop',
            ReferenceNumber__c = 'testRefNum',
            isEligible__c = True,
            ContactEmail__c = 'tedsassaal@gmaidsdl.com',
            ShippingCountry = 'France',
            ShippingPostalCode = DistributorRegionOfBodyshop+'000',
            RecordTypeId=RecordTypeBodyshop
            ,VAT__c= 10
        );  
        insert BodyshopAccountFrance;

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
                 ,VAT__c= 10      
             )
        };
        insert Distributors;    
        
        // TestDistributor1Group = new Group();
        // TestDistributor1Group.Name = 'DistributorFrance1';
        // TestDistributor1Group.DeveloperName = 'TestDistributorGroup1';
        // insert TestDistributor1Group;
      
        //date mydate1 = date.parse('01/01/2014');
        //date mydate2 = date.parse('16/09/2016');

        date mydate1 = Date.newInstance(2014, 1, 1);
        date mydate2 = Date.newInstance(2016, 9, 16);

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
                DeliveryStatus__c = 'INPROCESS', // used to sync with Offer__c
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
                DeliveryStatus__c = 'INPROCESS', // used to sync with Offer__c
                PartList__c = PartList[1].Id,
                PartNumber__c = '1235'
            )
        };
        insert OrderLines;
        
        
        Offers = New list<Offer__c>{
            new Offer__c(
                Type__c = 'QUICK',
                Prerequisiteorder__c = SalesOrders[0].Id,
                OrderLine__c = OrderLines[0].Id,
                //Accepted__c = 'YES',
                ExpectedDeliveryDate__c = date.today()+1,
                DeliveryStatus__c = 'INPROCESS',
                DisplayPriority__c = 1.0            
            ),
            new Offer__c(
                Type__c = 'QUICK',
                Prerequisiteorder__c = SalesOrders[0].Id,
                OrderLine__c = OrderLines[1].Id,
                //Accepted__c = 'YES',
                ExpectedDeliveryDate__c = date.today()+1,
                DeliveryStatus__c = 'INPROCESS',
                DisplayPriority__c = 1.0
            )
        };
        insert Offers;
    }

}
@isTest static void testM2() {
    test.starttest();
    

    System.runAs(UserAdmin) {

       // insert DistributorFrance1; // insert here or error --> "MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object..."

    }
    

    System.runAs(DistributorFrance1) {

    } // end running as DistributorFrance1
    
    // TEST ACCEPTING OFFER LINES, MAKING DELIVERY AND ACCEPTING INVOICE
    System.runAs(UserAdmin) {
        List<PrerequisiteOrder__c> createdSO = [select Id, OfferType__c from PrerequisiteOrder__c where Bodyshop__c = :BodyshopAccountFrance.Id];
        System.assertEquals(1, createdSO.size());

        List<Offer__c> OfferList = [select Id, Accepted__c from Offer__c where PrerequisiteOrder__c =:createdSO[0].Id];
        System.assertEquals(2, OfferList.size());
        
        
        PageReference pageRef = Page.VF_PrintPartListForBodyshop;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(createdSO[0]);
        ApexPages.currentPage().getParameters().put('id', createdSO[0].Id);
        ApexPages.currentPage().getParameters().put('pdf', 'true'); 
        ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
        ApexPages.currentPage().getParameters().put('force_download', 'true');
        ApexPages.currentPage().getParameters().put('filename', 'filename'); 
        VFC_PrintPartListForBodyshop sc = new VFC_PrintPartListForBodyshop(controller);
        String S = sc.getDateToday();
    String dateToday= String.valueOf(Datetime.now());
        String getAddress = sc.getAddress();
    List<Offer__c> OfferLines = sc.getOfferLines();
            
             

        system.assertEquals(2, Offers.size());
      
        
  }
    
test.stoptest();
    

}
    */
}