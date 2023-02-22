/**
 * @description       : 
 * @author            : DUN
 * @group             : 
 * @last modified on  : 04-20-2021
 * @last modified by  : DUN
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-20-2021   DUN   Initial Version
**/
//Test Factory UAT
/***********************************************************************************************************
Trigger Name - TestFactory
Version - 1.0
Created Date - 18 NOV 2015
Function - Used to factorise creation of data in test classes.
-----------------------------------------------------------------------------
/!\
WARNING:
No DML operation in this class.
Only objects instantiation with a maximum of fields defined.
If a field has to be unique, use the randomize function to avoid duplicate errors.
/!\
-----------------------------------------------------------------------------
Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* CÃ©cile L      30/11/2015  Original Version
* Brayan N      07/01/2016  Creation of use
* Ashwina S     20/01/2016  Creation of CountryCodeInformationsMapping__c
* Dourga U      24/02/2016  Creation of masterRules , detailRules, globalVaraibles and partList
* Ashwina S     25/02/2016  Add method for createCaseDetailsProcessMapping
* Dourga U      01/03/2016  Creation of SLAConfiguration
* Dourga U      05/04/2016  Creation of manufacturer reference and distributor reference
* CÃ©cile L      28/06/2016  Add CountryCode by default
* Ruksaar L     24/06/2019  Add supplier__c method
* Welsa C       24/08/2020  C-003838 - Nob - Migrate Billing information to new fields
* Welsa C       24/03/2021  C-004291 - PREFITOOL - ASPISAccountSharing_TEST apex error
* Rojo L        09/12/2022  C-004776 - Setup Garage
************************************************************************************************************/
@isTest
public class TestFactory {

    /*
     *  Create User
     * *****/
    public static User createUser(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Ballack',
            FirstName = 'Jean',
            Email = 'Jean@test.com',
            Alias = 'JBAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = ASPISConstants.getProfileAdminId()
        );
    }
	public static User createPrefikarUser(String name){
		NOBTools.isUserPrefikar = true;
		return new User(
			Username = TestFactory.randomizeString(name) +'@test.com',
			LastName = 'Deau',
			FirstName = 'Melon',
			Email = 'md@test.com',
			Alias = 'MDO',
			CountryCode = 'FR',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'Europe/Paris',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = ASPISConstants.getProfileAdminId(),
			NOB_isPrefikar__c = true,
			NOB_isTestClass__c = true
		);
	}

    //RRJ C-004776 - Setup Garage 09/12/2022
    public static Action__c createActionTemplate(string name){
        return new Action__c(
            Name = name,
            Categorie__c = '',
            Description__c = '',
            Email_Alert__c = 'New_BS_Connect_SIDEXA',
            Field__c = 'Recordtype.Name',
            Field_Value__c = 'test',
            Filter_Logic__c = '',
            Number__c = 1,
            Object__c = '',
            ObjectToUpdate__c = '',
            Operator__c = 'EQUALS',
            Recipient__c = 'test@gmail.com',
            ValueFromType__c = 'static'
        );
    }
    /*
     *  Create ASPIS Local User
     * *****/
    public static User createUserASPISLocal(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Jack',
            FirstName = 'Kurry',
            Email = 'KurryJack@test.com',
            Alias = 'KJac',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
			ProfileId = [SELECT Id,Name FROM Profile WHERE Name LIKE '%ASPIS Local%' LIMIT 1].Id
        );
    }

    /*
     *  Create Bodyshop User
     * *****/
    //AMI 18/07/2018 : Community Rollout
    //               : preventing users with community license from being selected
    public static User createUserBodyshop(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Ballack',
            FirstName = 'Jean',
            Email = 'Jean@test.com',
            Alias = 'JBAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id 
                            FROM Profile 
							WHERE Name like 'Bodyshop' 
                            and (NOT UserLicense.Name LIKE '%Community%')
                            LIMIT 1].Id
        );
    }

    /*
     *  Create Distributor User
     * *****/
    public static User createUserDistributor(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Ballack',
            FirstName = 'Jean',
            Email = 'Jean@test.com',
            Alias = 'JBAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
			ProfileId = [SELECT Id FROM Profile WHERE Name like 'Distributor' LIMIT 1].Id
        );
    }

    /*
     *  Create Integration User
     * *****/
    public static User createUserIntegration(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Tousse',
            FirstName = 'Sali',
            Email = 'tSali@test.com',
            Alias = 'TSAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name LIKE 'ASPIS%Integration%' LIMIT 1].Id,//WCH 24/03/2021 C-004291
            UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleSpain'].Id
        );
    }

    /*
     *  Create Integration User
     * *****/
    public static User createUserInterface(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'interface',
            FirstName = 'User',
            Email = 'intUser@test.com',
            Alias = 'TSAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%ASPIS Interface%' LIMIT 1].Id,
            UserRoleId = [SELECT Id from UserRole where DeveloperName='AlphaScaleFrance'].Id
        );
    }


    /*
     *  Create an Assessment
     * *****/
    public static Assessment__c createAssessment(String name, Account bodyshop){
        return new Assessment__c(
            Name = TestFactory.randomizeString(Name),
            AssessmentNumber__c = TestFactory.randomizeString(Name),
            BodyShop__c = bodyshop.Id,
            Entity__c = 'Alpha Test',
            EntityCode__c = '999',
            EntityRules__c = 'FR999',
            MissionNumber__c = '01',
            PortfolioAgentCode__c = '355',
            TECH_EntityCountryCode__c = 'FR',
            Manufacturer__c = 'AUDI',
            //AssessmentID__c = '0912',
            //TechExternalId__c = '233'
            AssessmentID__c = TestFactory.randomizeString(Name),
            TechExternalId__c = TestFactory.randomizeString(Name)
        );
    }

    /*
     *  Create a 'FINAL' OrderLine
     * *****/
    public static OrderLine__c createOrderLineFinal(Decimal unitPrice, PurchaseOrder__c purchaseOrder, String deliveryStatus){
        return new OrderLine__c(
            PurchaseOrder__c = purchaseOrder.Id,
            CataloguePrice__c = unitPrice,
            AssessmentPrice__c = unitPrice - 10,
            Quantity__c = 1,
            OrderType__c = 'FINAL',
            AXADiscount__c = 20,
            BodyShopDiscount__c = 10,
            //AdditionnalDiscount__c = 0,
            VAT__c = 20,
            AcceptedCheck__c = TRUE,
            DeliveryStatus__c = deliveryStatus,
            Type__c = 'A',
            Suppliable__c = 'YES',
            ExpectedDeliveryDuration__c = '1',
            PartNumber__c = TestFactory.randomizeString('1234')
        );
    }

	// create an OrderLineWithPartList

	public static OrderLine__c createOrderLineFinalWithPartList(Decimal unitPrice, PurchaseOrder__c purchaseOrder, PartList__c partList ,String deliveryStatus){

		return new OrderLine__c(
			PurchaseOrder__c = purchaseOrder.Id,
			CataloguePrice__c = unitPrice,
			AssessmentPrice__c = unitPrice - 10,
			Quantity__c = 1,
			OrderType__c = 'FINAL',
			AXADiscount__c = 20,
			BodyShopDiscount__c = 10,
			//AdditionnalDiscount__c = 0,
			VAT__c = 20,
			AcceptedCheck__c = TRUE,
			DeliveryStatus__c = deliveryStatus,
			Type__c = 'A',
			Suppliable__c = 'YES',
			ExpectedDeliveryDuration__c = '1',
			PartNumber__c = TestFactory.randomizeString('1234'),
			PartList__c = partList.Id
		);

	}

    /*
     *  Create an Offer line
     * *****/
    public static Offer__c createOfferLine(OrderLine__c orderLine, PrerequisiteOrder__c salesOrder, String deliveryStatus){
        return new Offer__c(
            Prerequisiteorder__c = salesOrder.Id,
            OrderLine__c = orderLine.Id,
            DeliveryStatus__c = deliveryStatus,
            Accepted__c = 'YES'
        );
    }

    /*
     *  Create a Purchase Order
     * *****/
    public static PurchaseOrder__c createPurchaseOrder(Assessment__c assessment, PrerequisiteOrder__c salesOrder, Account bodyshop, Account distributor, String status ){
        return new PurchaseOrder__c(
            Assessment__c=assessment.id,
            Distributor__c = distributor.Id,
            PrerequisiteOrder__c = salesOrder.Id,
            ValidityDate__c=date.today(),
            SLAQuotationEntryDate__c = datetime.now(),
         /*   SLAQuotationLevel1__c = (datetime.now()).addDays(2),
            SLAQuotationLevel2__c = (datetime.now()).addDays(3),
            SLAQuotationLevel3__c = (datetime.now()).addDays(5),*/
            TECHSLAQuotationIsLevel1__c = false,
            TECHSLAQuotationIsLevel2__c = false,
            TECHSLAQuotationIsLevel3__c = false,
            Status__c = status,
            BodyShopOrderNumber__c = '3'
        );
    }

    /*
     *  Create a Sales Order
     * *****/
    public static PrerequisiteOrder__c createSalesOrder(Assessment__c assessment, Account bodyshop, String status ){
        return new PrerequisiteOrder__c(
            BodyShop__c = bodyshop.Id,
            Assessment__c = assessment.Id,
            OfferType__c = 'TEST',
            Status__c = status
        );
    }

    /*
     *  Create a Bodyshop
     * *****/
    public static Account createAccountPayment(String name, String countryCode){
        return new Account(
            Name = TestFactory.randomizeString(Name),
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
            ReferenceNumber__c = TestFactory.randomizeString('12345'),
            ContactEmail__c = 'dt1@gmail.com',
            ShippingCountryCode = countryCode,
            BillingCountryCode__c = countryCode,
			VAT__c = 20,
			isAspis__c = true
        );
    }

    /*
     *  Create a payment
     * *****/
    public static Account createAccountBodyshop(String name, String countryCode){
        return new Account(
            Name = TestFactory.randomizeString(Name),
            RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT).get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
            ReferenceNumber__c = TestFactory.randomizeString(countryCode),//WCH 23/12/2020 C-004120
            ContactEmail__c = 'dt1@gmail.com',
            ShippingCountryCode = countryCode,
            BillingCountryCode__c = countryCode,
            ASEntity__c = 'ASFR1',
			VATNumber__c = TestFactory.randomizeString(Name),
            VAT__c = 20,
            Payment_Type__c  = '49',
            PaymentTerms__c = ' NET30',
            LastPaymentDirectDebitDate__c = system.today(),
            ExpertSubstitutionMethod__c='FORCED',
            SubstitutionMethod2__c='PROPOSED',
			isAspis__c = true
        );
    }  

    /*
     *  Create a Distributor
     * *****/
    public static Account createAccountDistributor(String name, String countryCode){
        return new Account(
            Name = TestFactory.randomizeString(name),
            RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT).get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
            ReferenceNumber__c = TestFactory.randomizeString('12345'),
            ContactEmail__c = name+'@test-aspis.com',
            DistributorNextInvoiceDate__c = date.today(),
            DistributorInvoicePeriod__c = '15',
            Categories__c='A;B;C',
            ReferentialASforAParts__c = 25,
            ReferentialASforBCParts__c = 20,
            ShippingCountryCode = countryCode,
            BillingCountryCode__c = countryCode,
            DistributorCarBrandSupplied__c = 'ACM; ALFA ROMEO; ANIBAL; ARO; ASIA MOTORS; ASTON MARTIN; AUDI; AUTOBIANCHI; AUVERLAND; BENTLEY; BERTONE; BMW; CADILLAC; CHEVROLET-GM; CHRYSLER; CITROEN; DACIA; DAEWOO; DAIHATSU; DE TOMASO; DODGE; F.S.O; FERRARI; FIAT; FORD; HONDA; HYUNDAI; INNOCENTI; ISUZU; JAGUAR; JEEP-CHRYSLER; KIA; LADA; LAMBORGHINI; LANCIA; LAND ROVER; LEXUS; LOTUS; MAHINDRA; MASERATI; MAZDA; MERCEDES; MINI; MINI (BMW); MITSUBISHI; MORGAN; NISSAN; OPEL; PEUGEOT; PONTIAC; PORSCHE; RENAULT; ROLLS ROYCE; ROVER; SAAB; SANTANA; SEAT; SIMCA; SKODA; SMART; SSANGYONG; SUBARU; SUZUKI; TALBOT; TOYOTA; TRIUMPH; UMM; VM; VOLKSWAGEN; VOLVO; WARTBURG; YUGO',
			VAT__c = 20,
			isAspis__c = true
        );
    }

    /*
     *  Create a Bodyshop Invoice
     * *****/
    public static Invoice__c createBodyshopInvoice(String invoiceNumber, Decimal totalNet, String status, PrerequisiteOrder__c salesOrder){
        return new Invoice__c(
            Number__c = TestFactory.randomizeString(invoiceNumber),
            Assessment__c = salesOrder.Assessment__c,
            PrerequisiteOrder__c = salesOrder.id,
            Bodyshop__c = salesOrder.BodyShop__c,
            TotalNet__c  = totalNet, //salesOrder.TotalExpectedAmount__c,
            Status__c = status,
            RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
            Paymentterms__c = 'Test',
            Type__c = 'INVOICE',
            IsBodyShop__c = TRUE
        );
    }

    /*
     *  Create a Bodyshop CreditNote
     * *****/
    public static Invoice__c createBodyshopCreditNote(String invoiceNumber, Decimal totalNet, String status, PrerequisiteOrder__c salesOrder){
        return new Invoice__c(
            Number__c = TestFactory.randomizeString(invoiceNumber),
            Assessment__c = salesOrder.Assessment__c,
            PrerequisiteOrder__c = salesOrder.id,
            Bodyshop__c = salesOrder.BodyShop__c,
            TotalNet__c  = totalNet,
            Status__c = status,
            RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId(),
            Paymentterms__c = 'Test',
            Type__c = 'CREDITNOTE',
            IsBodyShop__c = TRUE
        );
    }

    /*
     *  Create a Distributor Invoice
     * *****/
    public static Invoice__c createDistributorInvoice(String invoiceNumber, Decimal totalNet, String status, PurchaseOrder__c purchaseOrder){
        return new Invoice__c(
            Number__c = TestFactory.randomizeString(invoiceNumber),
            Assessment__c = purchaseOrder.Assessment__c,
            PurchaseOrder__c = purchaseOrder.id,
            Distributor__c = purchaseOrder.Distributor__c,
            TotalNet__c  = totalNet,
            TotalASPrice__c = totalNet,
            VATDistributor__c = 20,
            TotalTTCDistributor__c = totalNet + (totalNet * 20),
            Status__c = status,
            RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
            Type__c = 'INVOICE',
            IsBodyShop__c = FALSE,
            DueDateDistributor__c = Date.today() + 5,
            Paymentterms__c = 'Test'
        );
    }

    /*
     *  Create a Distributor Credit Note
     * *****/
    public static Invoice__c createDistributorCreditNote(String invoiceNumber, Decimal totalNet, String status, PurchaseOrder__c purchaseOrder){
        return new Invoice__c(
            Number__c = TestFactory.randomizeString(invoiceNumber),
            Assessment__c = purchaseOrder.Assessment__c,
            PurchaseOrder__c = purchaseOrder.id,
            Distributor__c = purchaseOrder.Distributor__c,
            TotalNet__c  = totalNet,
            TotalASPrice__c = totalNet,
            VATDistributor__c = 20,
            TotalTTCDistributor__c = totalNet + (totalNet * 20),
            Status__c = status,
            RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
            Type__c = 'CREDITNOTE',
            IsBodyShop__c = FALSE,
            DueDateDistributor__c = Date.today() + 5,
            Paymentterms__c = 'Test'
        );
    }

    /*
     *  Create a Distributor Discount
     * *****/
    public static Discount__c createDistributorDiscount(Account distributor, Decimal discount, String partType, String brands){
        return new Discount__c(
            Distributor__c = distributor.Id,
            DistributorCode__c = 'TEST'+distributor.Name+discount,
            PartType__c = partType,
            Brand__c = brands,
            Manufacturer__c = '',
            BeginingDate__c = Date.today(),
            EndDate__c = Date.today()+5,
            TECH_VerifyUnicityActiveDiscount__c = TestFactory.randomizeString(brands),
            ASLowLevel__c  = discount-10,
            ASHighLimit__c = discount,
            RecordTypeID = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Distributor Discount').getRecordTypeId()
        );
    }

    /*
     *  Create a Bodyshop Discount
     * *****/
    public static Discount__c createBodyshopDiscount(Account distributor, Decimal discount, String partType, String brands){
        return new Discount__c(
            BodyShop__c = distributor.Id,
            PartType__c = partType,
            Brand__c = brands,
            BeginingDate__c = Date.today(),
            EndDate__c = Date.today()+5,
            TECH_VerifyUnicityActiveDiscount__c = TestFactory.randomizeString(brands),
            LowKeepDiscount__c  = discount-10,
            HighKeepDiscount__c = discount,
            RecordTypeID = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get('Bodyshop Discount').getRecordTypeId()
        );
    }

    /*
     *  Create a Bodyshop Discount
     * *****/
    public static Discount__c createVirtualADiscount(Account distributor, Decimal discount, String partType, String brands){
        return new Discount__c(
            BodyShop__c = distributor.Id,
            PartType__c = partType,
            Brand__c = brands,
            BeginingDate__c = Date.today(),
            EndDate__c = Date.today()+5,
            TECH_VerifyUnicityActiveDiscount__c = TestFactory.randomizeString(brands),
            Rebate__c  = discount-10,
            BSdiscount__c = discount,
            AS_Discount__c = discount-5,
            RecordTypeID = Schema.SObjectType.Discount__c.getRecordTypeInfosByName().get(ASPISConstants.DISCOUNT_RT_DeveloperName_VirtualADiscount).getRecordTypeId()
        );
    }

    /*
     *  Create a Case
     * *****/
     public static Case__c createCase(String subject,Integer effort, User owner){
        return new Case__c(
            Effort_in_man_days__c = effort,
            Subject__c = subject,
            OwnerId = owner.Id
        );
     }

    /*
     *  Randomize a string.
     * *****/
    //WCH 23/12/2020 C-004120
    public static String randomizeString(String name){
        String charsForRandom = '0123456789';
        String randStr = '';
        while (randStr.length() < 10){
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
           randStr += charsForRandom.substring(idx, idx+1);
        }
        return name+randStr;
    }
/**
     @description       : 
    @author            : KPA
    @group             : 
    @last modified on  : 01-25-2021

    /*
	 *  Create a Case standard obj
	****/

    public static Case createCaseStandard(String statut, Id insuredContactId, Id insurerAccountId, String make, String model, String Insurancenumber, String caseorigin, DateTime incident, /*String type,*/ String carnumber, string TypeDomage, String TypeCommande){
		 Datetime CreatedDateTime = system.now();
		return new Case(
			 Status=statut,
			 NOB_BusinessProvider__c = insurerAccountId,
			 //NOB_ContactPickup__c = insuredContactId,
			 ContactId = insuredContactId,
			 NOB_VehicleBrand__c = make,
			 NOB_VehicleModel__c = model,
			 NOB_InsurerClaimNumber__c = Insurancenumber,
			 Origin = caseorigin,
			 NOB_IncidentDateandTime__c = incident,
			 //Type= type,
			 NOB_VehicleRegistrationNumber__c = carnumber,
             NOB_DamageType__c = TypeDomage,
			 NOB_OrderType__c = TypeCommande
			//  NOB_TECH_DispoId__c = techDispo
			// CreatedDateTime = creationDate
			 
         );
      }
public static workOrder createWorkOrder(String status, Id caseId){
        return new workOrder(
			Status=status,
			CaseId=caseId
        );
    }
	public static NOB_AccountRelationship__c createRelationCompte(Id reparateur, Id assureur, String type){
		return new NOB_AccountRelationship__c(
			NOB_BODYSHOP__C=reparateur,
			NOB_COMPTE__C=assureur,
			NOB_TYPE__C=type
		);
	}
	public static Contact createInsuredContact(String firstName, String lastName, Id accountId, String secteurPrefikar ){
		return new Contact(
			FirstName = firstName,
			LastName = lastName,
			AccountId = accountId,
			NOB_Secteur_Nobilas__c = secteurPrefikar,
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Fiche_Assure').getRecordTypeId()
		);
	}

	public static Account createInsurerAccount(String name, String  SiretSiegeSocial){
		return new Account(
				Name = name,
            	NOB_SiretHeadquarters__c = SiretSiegeSocial,
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Assureur').getRecordTypeId()
		);
	}

	public static Account createPrefikarBodyAccount(String name, String typeReseau, String SiretSiegeSocial, string statut){
		return new Account(
				Name = name,
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BODYSHOP').getRecordTypeId(),
				ShippingCountry = 'France',
				ShippingCity = 'Paris',
				ShippingStreet = '5 RUE EMILE LEPEU',
				ShippingPostalCode = '75011',
				NOB_NetworkType__c = typeReseau,
				NOB_SiretHeadquarters__c = SiretSiegeSocial,
				NOB_Statut__c = statut
		);
	}
	public static Account createPrefikarManageBodyAccount(String name, String typeReseau, String SiretSiegeSocial){
		return new Account(
				Name = name,
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PFR_BodyshopNetworkManager').getRecordTypeId(),
				ShippingCountry = 'France',
				ShippingCity = 'Paris',
				ShippingStreet = '5 RUE EMILE LEPEU',
				ShippingPostalCode = '75011',
				NOB_NetworkType__c = typeReseau,
				NOB_SiretHeadquarters__c = SiretSiegeSocial
				// NOB_Statut__c = statut
		);
	}

	public static NOB_Planning__c createPlanning(Id bodyshopId){
		Datetime dt = Datetime.newInstance(System.today().year(),System.today().month(), System.today().day()+1, 9, 00, 00);
		return new NOB_Planning__c(
				NOB_BodyShop__c = bodyshopId,
				NOB_StartDate__c = dt,
				NOB_EndDate__c = dt.addMinutes(60),
				NOB_Quantity__c = 1,
				NOB_Status__c = 'Disponible',
				RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId()


		);
	}
    
	public static Asset createVehiculeRemplacement(Id bodyShopId){
		return new Asset(
				Name = 'VR01',
				AccountId = bodyShopId,
				NOB_Make__c = 'AUDI',
				NOB_Model__c = 'A3',
				NOB_IsAvailable__c = true,
				NOB_CirculationDate__c = Date.today(),
				NOB_ContractStartDate__c = Date.today(),
				NOB_Mileage__c = 1000,
				NOB_PlateNumber__c = 'V0001',
				//NOB_transmission__c = 'BoÃ®te automatique'
				NOB_transmission__c = 'Boîte automatique'
		);
	}

	public static NOB_Rent__c createPret(Id workorderId, Id vehiculeRemplacement){
		return new NOB_Rent__c(
				NOB_OrdreExecution__c = workorderId,
				NOB_ReplacementVehicule__c = vehiculeRemplacement,
				NOB_VehiculeRentalDate__c = Datetime.now(),
				NOB_VehiculeReturnDate__c = Datetime.now().addDays(5)
		);
	}

	/*
	 *  Randomize a string.
	 * *****/
	/*public static String randomizeString(String name){
		String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < 6) {
		   Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
		   randStr += charsForRandom.substring(idx, idx+1);
		}
		return name+randStr;
	}*/


    /*
     *  create CountryCodeInformationsMapping__c
     * *****/
    public static CountryCodeInformationsMapping__c createCountryCodeInformationsMapping(String customSettingsName, String businessHoursID){
        return new CountryCodeInformationsMapping__c(
            Name = customSettingsName,
            BusinessHoursID__c = businessHoursID
        );
    }

    /**
    * @author Cecile L
    * @date 01/02/2016
    * @description Create a RuleSet for SLA parameters.
    * @param entityRuleCode The entity rule code for which the rule should applied
    * @return MasterRules__c An active Rule Set instantiated with the right process.
    */
    public static MasterRules__c createRuleSetSLAPOQuotation(String entityRuleCode){
        return new MasterRules__c(
            Entity__c = entityRuleCode,
            RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Rule Set').getRecordTypeId(),
            Process__c = 'SLA',
            RuleStatus__c = 'Active'
        );
    }

    /**
    * @author Cecile L
    * @date 01/02/2016
    * @description create a MasterRule for SLA PO quotation parameters.
    * @param entityRuleCode The entity rule code for which the rule should applied
    * @param ruleSet The related Rule Set which contains this rule.
    * @return MasterRules__c A master Rule instantiated with the right process and SObject.
    */
    public static MasterRules__c createMasterRuleSLAPOQuotation(String entityRuleCode, MasterRules__c ruleSet){
        return new MasterRules__c(
            RuleSet__c = ruleSet.Id,
            Entity__c = entityRuleCode,
            RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('SLA Configuration').getRecordTypeId(),
            Process__c = 'QUOTATION',
            RuleStatus__c = 'Active',
            sObject__c = 'PurchaseOrder__c',
            ExternalID__c = TestFactory.randomizeString(entityRuleCode)
        );
    }

    /**
    * @author Cecile L
    * @date 01/02/2016
    * @description create a MasterRule for SLA PO quotation parameters.
    * @param entityRuleCode The entity rule code for which the rule should applied
    * @return List<DetailRule__c> A list with the setting for the 3 levels of SLA Quotation.
    */
    public static List<DetailRule__c> createListCriteriasSLAPOQuotation(String entityRuleCode, MasterRules__c masterRule, String SLAlevel1, String SLAlevel2, String SLAlevel3, String levelUnity){
        return new List<DetailRule__c>{
            new DetailRule__c(
                MasterRule__c = masterRule.Id,
                RecordTypeId = Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Parameters').getRecordTypeId(),
                sObject__c = 'PurchaseOrder__c',
                FieldsAPI__c = 'SLAQuotationLevel1__c',
                Operator__c = 'EQUALS',
                Value__c = SLAlevel1,
                ValueFrom__c = levelUnity,
                Number__c = 1
            ),
            new DetailRule__c(
                MasterRule__c = masterRule.Id,
                RecordTypeId = Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Parameters').getRecordTypeId(),
                sObject__c = 'PurchaseOrder__c',
                FieldsAPI__c = 'SLAQuotationLevel2__c',
                Operator__c = 'EQUALS',
                Value__c = SLAlevel2,
                ValueFrom__c = levelUnity,
                Number__c = 2
            ),
            new DetailRule__c(
                MasterRule__c = masterRule.Id,
                RecordTypeId = Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Parameters').getRecordTypeId(),
                sObject__c = 'PurchaseOrder__c',
                FieldsAPI__c = 'SLAQuotationLevel3__c',
                Operator__c = 'EQUALS',
                Value__c = SLAlevel3,
                ValueFrom__c = levelUnity,
                Number__c = 3
            )
        };
    }

    /**
    * @author Dourga U
    * @date 24/02/2016
    * @description create a MasterRule.
    * @param entityRuleCode, process name, sObjectName
    * @return MasterRules__c A master Rule instantiated with the right process and SObject.
    */
    public static MasterRules__c createMasterRule(String entityRuleCode, String process, String sObjectName){
        return new MasterRules__c(
            Entity__c = entityRuleCode,
            RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Master Rule').getRecordTypeId(),
            Process__c = process,
            RuleStatus__c = 'Active',
            sObject__c = sObjectName,
            ExternalID__c = TestFactory.randomizeString(entityRuleCode)
        );
    }

    /**
    * @author Dourga U
    * @date 24/02/2016
    * @description create a detailRule.
    * @param process, masterRule, field, operator, value, recordtypeName, sObjectName, number
    * @return DetailRule__c a detailRule.
    */
    public static DetailRule__c createDetailRule(String process, MasterRules__c masterRule, String field, String operator, String value, String recordtypeName, String sObjectName, Integer num){
        return new DetailRule__c(
            MasterRule__c = masterRule.Id,
            RecordTypeId = Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId(),
            Process__c = process,
            sObject__c = sObjectName,
            FieldsAPI__c = field,
            Operator__c = operator,
            Value__c = value,
            Number__c = num
        );
    }
/**
	* @author Dourga U
	* @date 31/08/2020
	* @description create an objective.
	* @param process, masterRule, field, operator, value, recordtypeName, sObjectName, number
	* @return NOB_Objective__c a detailRule.
	*/
	public static NOB_Objective__c createObjective(MasterRules__c masterRule, String name, String field, String objectName, String valueFrom, Integer Weight, String valueType, String function){
		return new NOB_Objective__c(
			NOB_MasterRule__c = masterRule.Id,
			Name = name,
			NOB_Field__c = field,
			NOB_Object__c = objectName,
			NOB_ValueFrom__c = valueFrom,
			NOB_Weightage__c = Weight,
			NOB_ValueType__c = valueType,
			NOB_Function__c = function
		);
	}

    /**
    * @author Dourga U
    * @date 24/02/2016
    * @description create global variables
    * @param objectName, orderNum, type, value, nameProcess
    * @return GlobalVariables__c a GlobalVariable.
    */
    public static GlobalVariables__c createGlobalVariable(String objectName, String orderNum, String type, String value, String nameProcess){
        return new GlobalVariables__c(
            Object__c = objectName,
            Order__c = orderNum,
            Type__c = type,
            Value__c = value,
            Name = nameProcess
        );
    }

    /**
    * @author Dourga U
    * @date 24/02/2016
    * @description create part list
    * @param assessment
    * @return PartList__c a PartList__c.
    */
    public static PartList__c createPartList(Assessment__c assessment){
        Date myDate = date.newInstance(2015, 2, 17);
        return new PartList__c(
            Assessment__c = assessment.Id,
            //Name = 'FRONT LWR AIR GRILLE',
            Name = TestFactory.randomizeString('partNumber'),
            //PartNumber__c = '53102 47020',
            PartNumber__c  = TestFactory.randomizeString('76TYGD90'),
            //HeldDate__c = myDate,
            HeldDate__c = date.today(),
            Price__c = 68,
            Quantity__c = 1
        );
    }

    /**
    * @author Ruksaar L
    * @date 25/01/2019
    * @description create ASCR part list
    * @param assessment
    * @return PartList__c a PartList__c.
    */
    public static PartList__c createPartListASCR(Assessment__c assessment, CrossReference__c crossRef, DistributorPrice__c distPrice){
        Date myDate = date.newInstance(2015, 2, 17);
        //system.debug('@@ got in');
        PartList__c part =  new PartList__c();
        part.Assessment__c = assessment.Id;
            //Name = 'FRONT LWR AIR GRILLE',
        part.Name = TestFactory.randomizeString('partNumber');
        //PartNumber__c = '53102 47020',
        part.PartNumber__c  = 'ASCR-' + TestFactory.randomizeString('76TYGD90');
        //HeldDate__c = myDate,
        part.HeldDate__c = date.today();
        part.Price__c = 68;
        part.Type__c = 'A';
        part.Quantity__c = 1;
        part.CrossReferenceId__c = crossRef.Id;
        part.DistributorPriceId__c = distPrice.Id;
        //system.debug('@@ got in'+part);

        return part;
        
        //return new PartList__c(
        //  Assessment__c = assessment.Id,
        //  //Name = 'FRONT LWR AIR GRILLE',
        //  Name = TestFactory.randomizeString('partNumber'),
        //  //PartNumber__c = '53102 47020',
        //  PartNumber__c  = 'ASCR' + TestFactory.randomizeString('76TYGD90'),
        //  //HeldDate__c = myDate,
        //  HeldDate__c = date.today(),
        //  Price__c = 68,
        //  Quantity__c = 1,
        //  CrossReferenceId__c = crossRef.Id,
        //  DistributorPriceId__c = distPrice.Id
        //);
    }

    /**
    * @author Ashwina S
    * @date 25/02/2016
    * @description create records for Custom Settings createCaseDetailsProcessMapping
    * @param null
    * @return list<CaseDetailsProcessMapping__c> List of records to be created.
    */
    public static list<CaseDetailsProcessMapping__c> createCaseDetailsProcessMapping(){
        list<CaseDetailsProcessMapping__c> caseDetailsProcessMappingList = new list<CaseDetailsProcessMapping__c>{
            new CaseDetailsProcessMapping__c(Name= 'FR-INV-OrderNotPaid', Description__c='Une facture ou un avoir distributeur sont au Â«Ã  payerÂ» depuis plus de 30 jours.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='INVOICING', Short_Description__c='Case created if the status of distributor Invoice/Credit Note is still Payable after 30 days', Subject__c='Commande non-payÃ©e', TriggeredDelayDays__c=30, Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'ES-PO-ASDiscountTooLow', Description__c='Caso generado cuando el descuento final de AS (AS% predeterminado + extra % definido por el Distribuidor) es menor que el Nivel MÃ­nimo de Descuento definido en el objeto Descuento.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the final AS discount (default AS% + extra % defined by the Distributor) is lower than the Low Level Discount defined on the Discount object.', Subject__c=    'D  escuento menor que el nivel mÃ­nimo de descuento definido', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-ASS-DuplicateParts', Description__c='Duplicate parts in Json\', only one will be created.', Due_Date_Duration__c=2, Due_Date_Unity__c='H', Origin__c='Webservice CreateAssessment', Priority__c='Low', Reason__c='Duplicate Part List', Short_Description__c='Duplicate Part List was found in JSON structure.', Subject__c='Duplicate Parts', Type__c='Warning', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-PO-NoInvoiceCreated',Description__c='Ce PO est au statut Â« livraison confirmÃ©e Â» et n\'a aucune facture associÃ©e depuis plus de 40 jours', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='INVOICING', Short_Description__c='Case created if PO\'s status is Delivered Confirmed and there is no invoice since 40 days.', Subject__c='Commande non-facturÃ©e', TriggeredDelayDays__c=2, Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-SO-DeliveryProblem',Description__c='Le Bodyshop a indiquÃ© avoir eu des problÃ¨mes de livraison avec sa commande.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez prendre contact avec lui et faire le necessaire.', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the Bodyshop indicates that the delivery of some parts is in issue.', Subject__c='Probleme lors de la livraison', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-PO-DeliveryProblem',Description__c='Le Bodyshop a indiquÃ© avoir eu des problÃ¨mes de livraison avec sa commande.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez prendre contact avec lui et faire le necessaire.', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the Bodyshop indicates that the delivery of some parts is in issue.', Subject__c='Probleme lors de la livraison', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-ASS-Offering',Description__c='L\'Offering n\'a pas fonctionnÃ©.', Due_Date_Duration__c=2, Due_Date_Unity__c='H', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Create a Case if the offering process has returned no results.', Subject__c='Action requise : La gÃ©nÃ©ration des offres n\'a rien donnÃ©.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-PO-Delayed',Description__c='La livraison d\'une partie des piÃ¨ces est retardÃ©e.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez contacter le rÃ©parateur au plus vite.', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the Distributor indicates the delivery of some parts will be delayed.', Subject__c='Retard dans la livraison des piÃ¨ces de la Vente RÃ©parateur.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-PO-Canceled',Description__c='Le distributeur a annulÃ© l\'Achat Distributeur.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez prendre contact au plus vite avec le rÃ©parateur pour dÃ©cider d\'une solution.', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the Distributor cancels a Purchase Offer after the Offering process.', Subject__c='Action requise : Achat distributeur annulÃ©', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-SO-DELIVERYCONFIRMEDSLA1',Description__c='Nous attendons la confirmation du rÃ©parateur concernant la livraison des piÃ¨ces de la Vente RÃ©parateur.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez contacter le rÃ©parateur au plus vite.', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='If the Bodyshop has not confirmed the delivery yet\', 1 day after the estimated delivery date\', create a Case to the admin.', Subject__c='Attente confirmation de livraison des piÃ¨ces de la Vente RÃ©parateur (Relance nÂ°1)', Type__c='OTHER', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-SO-DELIVERYCONFIRMEDSLA2',Description__c='Nous attendons la confirmation du rÃ©parateur concernant la livraison des piÃ¨ces de la Vente RÃ©parateur.', Due_Date_Duration__c=5, Due_Date_Unity__c='D', Internal_Comments__c='Veuillez contacter le rÃ©parateur au plus vite.', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='If the Bodyshop has not confirmed the delivery yet\', 5 days after the estimated delivery date\', create a Case to the admin.', Subject__c='Attente confirmation de livraison des piÃ¨ces de  la Vente RÃ©parateur (Relance nÂ°2)', Type__c='OTHER', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-PO-NotValidated', Description__c='Le montant du Purchase order est different du sales order.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='INVOICING', Short_Description__c='If the Total Expected amount is different than the Total Amount of Invoices and Credit Notes on PO\', create a Case to the admin.', Subject__c='Le montant est different.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-ASS-Sourcing',Description__c='La crÃ©ation de l\'offre a Ã©chouÃ©. Veuillez constituer manuellement une offre ou informer le rÃ©parateur qu\'il n\'est pas possible de lui proposer une offre d\'achat de piÃ¨ces.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Generate a Case if the sourcing process has returned no result.', Subject__c='Action requise : ProblÃ¨me lors du sourcing', Type__c='PROBLEM', Active__c=false),
                new CaseDetailsProcessMapping__c(Name= 'FR-CASE-SETDUEDATE-PROBLEM',Due_Date_Duration__c=1, Due_Date_Unity__c='D', Short_Description__c='Used to define the due date on Case created manually\', based on the Type field.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-CASE-SETDUEDATE-QUESTION',Due_Date_Duration__c=3, Due_Date_Unity__c='D', Short_Description__c='Used to define the due date on Case created manually\', based on the Type field.', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-CASE-SETDUEDATE-PROBLEM',Due_Date_Duration__c=1, Due_Date_Unity__c='D', Priority__c='MEDIUM', Short_Description__c='Used to define the due date on Case created manually\', based on the Type field.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name=' ES-CASE-SETDUEDATE-QUESTION',Due_Date_Duration__c=3, Due_Date_Unity__c='D', Priority__c='MEDIUM', Short_Description__c='Used to define the due date on Case created manually\', based on the Type field.', Type__c='QUESTION', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'FR-EmailService',Due_Date_Duration__c=3, Due_Date_Unity__c='D', Origin__c='EMAIL', Priority__c='LOW', Reason__c='OTHER', Short_Description__c='An User send an email to the Email2Case service.', Type__c='QUESTION', Active__c=true),
                new CaseDetailsProcessMapping__c(Name=' FR-SO-Canceled',Description__c='Cette commande a Ã©tÃ© annulÃ©e par le RÃ©parateur.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Internal_Comments__c='Prenez contact au plus vite avec le RÃ©parateur.', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='DELIVERY', Short_Description__c='Case created when the Bodyshop cancels a Sales Offer.', Subject__c='Action requise : Vente RÃ©parateur annulÃ©e par le RÃ©parateur.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-PO-QuotationSLA2',Description__c='L\'Achat Distributeur est en attente de rÃ©ponse du distributeur.', Due_Date_Duration__c=15, Due_Date_Unity__c='M', Internal_Comments__c='Veuillez contacter le distributeur rapidement.', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Case created when the Purchase Order reaches the level 2 of the SLA Quotation.', Subject__c='Achat Distributeur en attente de rÃ©ponse', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-PO-Unsupplied',Description__c='Le Disributeur a indiquÃ© ne pouvoir livrer aucune piÃ¨ce de la commande.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='The distributor is not able to provide any parts', Subject__c='Action requise : Aucune piÃ¨ce disponible', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-ASS-NotResponded',Description__c='Le chiffrage est bloquÃ© car aucun distributeur n\'a rÃ©pondu.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Create a Case if all Purchase Orders are not responded.', Subject__c='Action Requise : Aucun distributeur n\'a rÃ©pondu.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-DistributorPriceHigh',Description__c='Offered price by the Distributor is higher than the assessment price', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Offered price by the Distributor is higher than the assessment price', Subject__c='Offered price by the Distributor is higher than the assessment price', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-NotDelivered',Description__c='Se ha generado una factura sin que el pedido se encuentre en estado Entrega confirmada"."', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='INVOICING', Short_Description__c='Case created when an invoice is imported for a purchase order which are not in the Delivery Confirmed" status"', Subject__c='Que se haya generado una factura sin que el estado de Entrega se haya confirmado', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-ASMarginTooLow',Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='LOW', Reason__c='DELIVERY', Short_Description__c='Case created when at less one Order line of the Purchase Order has an AS Margin too low.', Type__c='PROBLEM', Active__c=false),
                new CaseDetailsProcessMapping__c(Name='ES-SO-Canceled',Description__c='El taller cancela una Orden de venta.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Case created when the Bodyshop cancels a Sales Offer.', Subject__c='El taller cancela la orden d venta', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-QuotationSLA2',Due_Date_Duration__c=15, Due_Date_Unity__c='M', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Case created when the Purchase Order reaches the level 2 of the SLA Quotation.', Subject__c='Respuesta Compra Distribuidor de espera', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-PO-NotDelivered',Description__c='Cette facture a Ã©tÃ© crÃ©Ã©e pour une commande non livrÃ©e.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='INVOICING', Short_Description__c='Case created when an invoice is imported for a purchase order which are not in the "Delivery Confirmed" status', Subject__c='Facture crÃ©Ã©e pour commande non livrÃ©e.', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-SO-DeliveryProblem',Description__c='Caso generado cuando el taller indica que hay una incidencia en la entrega de algunas piezas.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Case created when the Bodyshop indicates that the delivery of some parts is in issue.', Subject__c='incidencia en pieza', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-Delayed',Description__c='El distribuidor indica que la entrega de algunas piezas se retrasarÃ¡.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Case created when the Distributor indicates the delivery of some parts will be delayed.', Subject__c='Retraso en la entrega de alguna pieza', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'ES-PO-Canceled',Description__c='Caso generado cuando el distribuidor cancela una cotizaciÃ³n despuÃ©s del proceso de oferta.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Case created when the Distributor cancels a Purchase Offer after the Offering process.', Subject__c='CotizaciÃ³n cancelada tras el proceso de oferta', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-SO-DELIVERYCONFIRMEDSLA1',Description__c='Generar un caso para el administrador si el taller no ha confirmado la entrega 1 dÃ­a despuÃ©s de la fecha prevista.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='If the Bodyshop has not confirmed the delivery yet\', 1 day after the estimated delivery date\', create a Case to the admin.', Subject__c='Taller no confirma entrega 1 dÃ­a despuÃ©s de la fecha prevista', Type__c='OTHER', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-SO-DELIVERYCONFIRMEDSLA2',Description__c='El taller no ha confirmado la entrega 12h despuÃ©s de la fecha prevista.', Due_Date_Duration__c=5, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='If the Bodyshop has not confirmed the delivery yet\', 5 days after the estimated delivery date\', create a Case to the admin.', Subject__c='taller no confirma entrega 12h despuÃ©s de la fecha prevista', Type__c='OTHER', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-NotValidated',Description__c='La cantidad total prevista es diferente a la cantidad total que aparece en las facturas y en los abonos del pedido.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='CRITICAL', Reason__c='INVOICING', Short_Description__c='If the Total Expected amount is different than the Total Amount of Invoices and Credit Notes on PO\', create a Case to the admin.', Subject__c='Diferencia entre la cantidad total prevista y la que figura en las factruas y/o abonos del pe    di  do', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-ASS-Sourcing',Description__c='El proceso de bÃºsqueda de proveedores no obtuvo ningÃºn resultado.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Generate a Case if the sourcing process has returned no result.', Subject__c='No se encuentra proveedor para la pieza', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name= 'ES-EmailService',Due_Date_Duration__c=3, Due_Date_Unity__c='D', Origin__c='EMAIL', Priority__c='MEDIUM', Reason__c='OTHER', Short_Description__c='An User send an email to the Email2Case service.', Type__c='QUESTION', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-PO-Unsupplied',Description__c='El proveedor no es capaz de proporcionar las piezas.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='The distributor is not able to provide any parts', Subject__c='El proveedor no puede proporcionar las piezas', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-ASS-NotResponded',Description__c='NingÃºn pedido ha recibido respuesta.', Due_Date_Duration__c=1, Due_Date_Unity__c='D', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Create a Case if all Purchase Orders are not responded.', Subject__c='Pedidos sin respuesta', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='ES-ASS-Offering',Description__c='Caso generado si el proceso de oferta no obtuvo ningÃºn resultado: Order Line/Offer Delivery Duration: Translation 24/48hÂ 48/72h', Due_Date_Duration__c=2, Due_Date_Unity__c='H', Origin__c='APPLICATION', Priority__c='MEDIUM', Reason__c='DELIVERY', Short_Description__c='Create a Case if the offering process has returned no results.', Subject__c='Plazo para ofertar fuera de los SLA\'s establecidos', Type__c='PROBLEM', Active__c=true),
                new CaseDetailsProcessMapping__c(Name='FR-SO-OfferReturned',Description__c='PiÃ¨ce Ã  retourner', Due_Date_Duration__c=2, Due_Date_Unity__c='H', Origin__c='APPLICATION', Priority__c='HIGH', Reason__c='DELIVERY', Short_Description__c='Case created when the offer status returned by WS is \'RETURNED\'', Subject__c='PiÃ¨ce Ã  retourner', Type__c='PROBLEM', Active__c=true),
                // ABT 01-APR-2016
                new CaseDetailsProcessMapping__c(Name = 'ES-PO-AdditionalDiscount',
                                                 Description__c = 'Solicitd de Abono tramitada con posterioridad a la confirmaciÃ³n de la pieza; verificad posible gestiÃ³n de abono manual por parte del proveedor',
                                                 Due_Date_Duration__c = 0,
                                                 Due_Date_Unity__c = 'D',
                                                 Origin__c = 'APPLICATION',
                                                 Priority__c = 'LOW',
                                                 Reason__c = 'INVOICING',
                                                 Short_Description__c = 'Case is created when the batch is run and the Purchase Order is in the status DELIVERY CONFIRMED or PAYABLE and the purchase order does not already have a case.',
                                                 Subject__c = 'PiÃ¨ce Ã  retourner',
                                                 Type__c = 'OTHER',
                                                 Active__c = true),
                // ABT 21-APR-2016
                new CaseDetailsProcessMapping__c(Name = 'ES-ASS-TotalLoss',
                                                 Description__c = 'Total Loss',
                                                 Due_Date_Duration__c = 1,
                                                 Due_Date_Unity__c = 'D',
                                                 Origin__c = 'APPLICATION',
                                                 Priority__c = 'LOW',
                                                 Reason__c = 'Total Loss',
                                                 Short_Description__c = 'Total Loss',
                                                 Subject__c = 'Total Loss',
                                                 Type__c = 'PROBLEM',
                                                 Active__c = true),
                new CaseDetailsProcessMapping__c(Name = 'FR-ASS-TotalLoss',
                                                 Description__c = 'Total Loss',
                                                 Due_Date_Duration__c = 1,
                                                 Due_Date_Unity__c = 'D',
                                                 Origin__c = 'APPLICATION',
                                                 Priority__c = 'LOW',
                                                 Reason__c = 'Total Loss',
                                                 Short_Description__c = 'Total Loss',
                                                 Subject__c = 'Total Loss',
                                                 Type__c = 'PROBLEM',
                                                 Active__c = true),
                // ABT - 30-NOV-2016 - C-001459
                new CaseDetailsProcessMapping__c(Name                   = 'FR-PO-OrderLineRectification',
                                                 Description__c         = 'Le distributeur a modifiÃ© la/les ligne(s) de commande(s) {0} au tarif de {1} sur la {2}.',
                                                 Internal_Comments__c   = 'Veuillez contacter le distributeur rapidement.',
                                                 Due_Date_Duration__c   = 1,
                                                 Due_Date_Unity__c      = 'D',
                                                 Origin__c              = 'APPLICATION',
                                                 Priority__c            = 'CRITICAL',
                                                 Reason__c              = 'APPLICATION',
                                                 Short_Description__c   = 'Case is created when the order lines have been modified when the purchase order is InDelivery on the page VFP04_POManageOrderLines',
                                                 Subject__c             = 'Une ligne de commande a Ã©tÃ© modifiÃ© par un distributeur',
                                                 Type__c                = 'PROBLEM',
                                                 Active__c              = true)
                };

                    return caseDetailsProcessMappingList;
    }

    /**
    * @author Dourga U
    * @date 24/02/2016
    * @description create part list
    * @param assessment
    * @return PartList__c a PartList__c.
    */
    public static SLAConfiguration__c createSLAConfiguration(BusinessHours defaultHours){
        return new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id ,
                                          Name='FR-PO-QUOTATION-AXADirect' ,
                                          SLALevel1Minute__c=30 ,
                                          SLALevel2Minute__c=60 ,
                                          SLALevel3Minute__c=90 ,
                                          Entity__c= 'AXA Direct' ,
                                          Object__c = 'Purchase Order');
    }

    /**
    * @author Dourga U
    * @date 05/04/2016
    * @description create Manufacturer Reference__c
    * @param manufacturer, family, description, minQuantity, unit
    * @return Manufacturer_reference__c a Manufacturer Reference__c.
    */
    public static Manufacturer_reference__c createManufacturerReference(String manufacturer, String family, String description, Integer minQuantity, String unit){

        return new Manufacturer_reference__c(
            Brand__c = 'Debeer',
            Description__c = description,
            Family__c = family,
            Manufacturer__c = manufacturer,
            Manufacturer_ID__c =  TestFactory.randomizeString(manufacturer),
            Minimum_quantity__c = minQuantity,
            Public_price__c = 40,
            Substitution_countries__c = 'SP',
            //Type__c = 'P',
            Unit__c = unit
        );
    }

    /**
    * @author Dourga U
    * @date 05/04/2016
    * @description create Distributor Reference__c
    * @param manufacturer, family, description, minQuantity, unit
    * @return maunfacturerId, accountId, distributorPublicPrice, asDis, bsDis.
    */
    public static Distributor_reference__c createDistributorReference(Id maunfacturerId, Id accountId, Integer distributorPublicPrice, Integer asDis, Integer bsDis){
        return new Distributor_reference__c(
            Distributor__c = accountId,
            ASDiscount__c = asDis,
            AS_public_price__c = 40,
            BSDiscount__c =  bsDis,
            Distributor_NET_price__c = 40,
            Active_country__c = 'ES',
            Distributor_public_price__c = distributorPublicPrice,
            Manufacturer_reference__c = maunfacturerId,
            DistributorReference__c = TestFactory.randomizeString(maunfacturerId)
        );
    }


    /**
    * @author Dourga U
    * @date 15/04/2016
    * @description create a Direct Order
    * @param distributor, bodyshop
    * @return a DirectOrder__c.
    */
    public static DirectOrder__c createDirectOrder(Id bs,Id dis){
        return new DirectOrder__c(
            BodyShop__c = bs,
            Distributor__c = dis
        );
    }

    public static CrossReference__c createCrossReference(){
        return new CrossReference__c(
            CrossReferenceExtID__c = TestFactory.randomizeString('CrossReference')
        );
    }

    public static CrossReference__c createCrossReference(String countryCode, String partNum, String brand, Decimal price, Boolean active)
    {
        return new CrossReference__c
        (
            CountryCode__c              = countryCode,
            LanguageCode__c             = countryCode,
            OEMPartNumber__c            = partNum,
            OEMCleanPartNumber__c       = cleanseReference(partNum),
            OEMManufacturer__c          = brand,
            ActiveForSubstitution__c    = active,
            OEMPublicPrice__c           = price,
            ASPublicPrice__c            = price,
            IAMPublicPrice__c           = price,
            IAMPartNumber__c            = TestFactory.randomizeString(partNum),
            IAMManufacturer__c          = TestFactory.randomizeString(brand),
            IAMPartClass__c             = 'B',
            IAMPartDescription__c       = TestFactory.randomizeString(partNum) + ' '+TestFactory.randomizeString(brand),
            OEMKey__c                   = (countryCode + countryCode + cleanseReference(partNum) + brand).toUpperCase(),
            CrossReferenceExtID__c      = TestFactory.randomizeString('CrossReference'),
            IAMCertifyingOrganization__c= 'IAM'
        );
    }

    // ABT 15-SEP-2016
    public static String cleanseReference(String referenceToCleanse)
    {
        return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
    }

    public static DistributorPrice__c createDistributorPrice(Id accId, Id crossRef){
        return new DistributorPrice__c(
            DistributorID__c = accId,
            Description__c = 'PartTest',
            CrossReference__c = crossRef,
            DistributorPartNumber__c = '1346',
            DistributorPublicPrice__c = 52,
            DistributorPartDescription__c = 'PartTestDes',
            DIstributorPriceExtID__c = TestFactory.randomizeString('DistributorPrice')
        );
    }

    public class MyException extends Exception{}

    /**
    * @author Ashwina S
    * @date 16/08/2016
    * @description create records for Custom Settings CarMapping__c
    * @param systemCalling
    * @return list<CarMapping__c> List of carMapping__c to be created.
    */
    public static List<CarMapping__c> createCarMappingList(String systemCalling){
        list<CarMapping__c> carMappingList = new list<CarMapping__c>{
            new CarMapping__c ( CarCrossRef__c = 'Mercedes'
                               //,CarOrigin__c = 'M1'
                               ,Description__c = 'MERCEDES'
                               //,systemCalling__c = systemCalling
                               ,Name = systemCalling+'-M1'
            ),
            new CarMapping__c (CarCrossRef__c = 'Renault'
                              //,CarOrigin__c = 'RE1'
                              //,systemCalling__c = systemCalling
                              ,Description__c = 'RENAULT'
                              ,Name = systemCalling+'-RE1'
            ),
            new CarMapping__c (CarCrossRef__c = 'BMW'
                              //,CarOrigin__c = 'B1'
                             // ,systemCalling__c = systemCalling
                              ,Description__c = 'BMW'
                              ,Name = systemCalling+'-B1'
            )
        };
        return carMappingList;
    }

    /**
    * @author Ashwina S
    * @date 16/08/2016
    * @description create records for Custom Settings AccountRef__c
    * @param externalref, Bodyshop AccountId, systemCalling
    * @return AccountRef__c to be created.
    */
    public static AccountRef__c createAccountRef(String externalref, Id accountId, String systemCalling){
        return new AccountRef__c(//ExternalReference__c = externalref
                              InternalReference__c = accountId
                              //,systemCalling__c = systemCalling
                              ,Name = systemCalling+'-'+externalref
                              );
    }

    /**
    * @author Ruksaar L
    * @date 21/06/2019
    * @description create records for object supplier__c
    * @param name, 
    * @return supplier__c to be created.
    
    public static Supplier__c createSupplier(String name, string partClass){
        return new Supplier__c( Name = name,
                                Part_Class__c = partClass,
                                Certifying_Organization__c = 'TEST'
                              );
    }
*/
/**
	* @author Kejilen P
	* @date 13/01/2021
	* @description create a Service Contract
	* @param 
	* @return ServiceContract
	*/
    public static ServiceContract createServCon(Id accId  , String ServConName , String TypeContract , String NumRCS , Date startDate , Date endDate){
        return new ServiceContract(
             AccountId = accId,
             Name = ServConName ,
             NOB_ContractsType__c = TypeContract ,
             /*NOB_NumRCSRM__c = NumRCS ,*/
             StartDate = startDate ,
             EndDate = endDate
       );
   }
/**
	* @author Ashutoh R
	* @date 14/01/2021
	* @description create a task
	* @param Case
	* @return task
	*/
	public static Task createTask(Case c){
		return new Task(
		
			// PFR_CallStatus__c = 'Ã€ appeler',
			CallType = 'Outbound',
			Subject = 'Appel PlannifiÃ©',
			Type = 'Call',
			Status = 'En attente',
			Priority = 'High',
			PFR_CallPreferedStartTime__c = System.now(),
			PFR_CallPreferedEndTime__c = System.now() + 10,
			NOB_TECH_isAxaOrDa__c = true,
			CurrencyIsoCode = 'EUR',
			NOB_Case__c = c.Id ,
			WhatId = c.Id,
			WhoId = c.ContactId
			//PFR_CallStatus__c = 'À appeler'
		);
	}
    /**
	* @author Ashutoh R
	* @date 14/01/2021
	* @description create NOB_TauxNeg__c
	* @param Id, Date
	* @return NOB_TauxNeg__c
	*/
	public static NOB_TauxNeg__c createTauxNeg(Id AccountRelationship, Date startDate, Date endDate){
		return new NOB_TauxNeg__c(
			NOB_RelationCompte__c = AccountRelationship,
			NOB_StartDate__c = startDate,
			NOB_EndDate__c = endDate
		);
	}
    
    	/* ##################################### PREFITOOL TESTFACTOTY #########################################*/

	//create Prefitool User
	public static User createPrefitoolUser(String name){
		return new User(
			Username = TestFactory.randomizeString(name) +'@test.com',
			LastName = 'Mousse',
			FirstName = 'Pample',
			Email = 'md@test.com',
			Alias = 'MDO',
			CountryCode = 'FR',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'Europe/Paris',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = SVR_AP100_Constant.getProfilePrePRE_AnimationId(),
			NOB_isPrefikar__c = true
		);
	}
	// //create Prefitool Portal User
	// public static User createPrefitoolPortalUser(String name, Id PortalContactId){
	// 	// UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'AlphaScale' Limit 1];
	// 	// System.debug('#########iiiii: ' + userrole.RoleType);
	// 	return new User(
	// 		Username = TestFactory.randomizeString(name) +'@test.com',
	// 		LastName = 'na',
	// 		FirstName = 'zana',
	// 		Email = 'md@test.com',
	// 		Alias = 'MDO',
	// 		CountryCode = 'FR',
	// 		LanguageLocaleKey = 'en_US',
	// 		TimeZoneSidKey = 'Europe/Paris',
	// 		LocaleSidKey = 'en_US',
	// 		EmailEncodingKey = 'UTF-8',
	// 		ProfileId = SVR_AP100_Constant.getProfileCCP_BodyshopId(),
	// 		NOB_isPrefikar__c = true,
	// 		ContactId = PortalContactId,
	// 		isActive= true,
	// 		UserRoleId =  SVR_AP100_Constant.getPortalUserId()
	// 		// UserType = 'Standard'
	// 	);
	// }
	
	//create Prefitool Gestionnaire User
	public static User createPrefitoolGestionnaireUser(String name){
		return new User(
			Username = TestFactory.randomizeString(name) +'@test.com',
			LastName = 'na',
			FirstName = 'zana',
			Email = 'md@test.com',
			Alias = 'MDO',
			CountryCode = 'FR',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'Europe/Paris',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = SVR_AP100_Constant.getProfilePRE_FrontOfficeId(),
			NOB_isPrefikar__c = true,
			// ContactId = GestionnaireContactId,
			isActive= true
            
		);
	}

	// Create audit reseau
    public static SVR_AuditReseau__c createAuditRS(User u1, Account acc){
        return new SVR_AuditReseau__c(
            SVR_Collaborator__c = u1.Id,
            SVR_Bodyshop__c = acc.Id,
            SVR_ResponsableSecteur__c = u1.id
        );
    }

    // Create audit operationnel
    public static SVR_AuditOperationnel__c createAuditOP(User u1, Account acc){
        return new SVR_AuditOperationnel__c(
            SVR_Collaborator__c = u1.Id,
            SVR_Bodyshop__c = acc.Id
        );
    }

    public static Audit_Plan_Action__c createPlanActionOP(SVR_AuditOperationnel__c auditOP, String amel1, String amel2, String amel3){
        return new Audit_Plan_Action__c(
            SVR_AuditOperationnel__c =  auditOP.Id,
            SVR_StatutAmelioration1__c = amel1,
            SVR_StatutAmelioration2__c = amel2,
            SVR_StatutAmelioration3__c = amel3,
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(getPlanActionRecordTypeNameOP((String) auditOP.Id)).getRecordTypeId()
        );
    }

    public static Audit_Plan_Action__c createPlanActionRSCM(SVR_AuditReseau__c auditRS, String ai1, String statut1, String ai2, String statut2, String ai3, String statut3){
        return new Audit_Plan_Action__c(
            SVR_AuditReseau__c =  auditRS.Id,
            SVR_ActionIdentifie1__c = ai1,
            SVR_CMStatut1__c = statut1,
            SVR_ActionIdentifie2__c = ai2,
            SVR_CMStatut2__c = statut2,
            SVR_ActionIdentifie3__c = ai3,
            SVR_CMStatut3__c = statut3,
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauCM).getRecordTypeId()
        );
    }

    public static Audit_Plan_Action__c createPlanActionRSQuality(SVR_AuditReseau__c auditRS, String ai1, String statut1, String ai2, String statut2, String ai3, String statut3){
        return new Audit_Plan_Action__c(
            SVR_AuditReseau__c =  auditRS.Id,
            SVR_ActionIdentifie1__c = ai1,
            SVR_CMStatut1__c = statut1,
            SVR_ActionIdentifie2__c = ai2,
            SVR_CMStatut2__c = statut2,
            SVR_ActionIdentifie3__c = ai3,
            SVR_CMStatut3__c = statut3,
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauQualite).getRecordTypeId()
        );
    }

	public static Audit_Plan_Action__c createPlanActionRS(SVR_AuditReseau__c auditRS, String ai1, String statut1, String ai2, String statut2, String ai3, String statut3, String ai4, String statut4, String ai5, String statut5, String ai6, String statut6, String ai7, String statut7){
        
		Audit_Plan_Action__c planAction = new Audit_Plan_Action__c();
		System.debug('######## jpi sed: ' + getPlanActionRecordTypeNameRS((String) auditRS.Id));
		if(getPlanActionRecordTypeNameRS((String) auditRS.Id)== SVR_AP100_Constant.recordTypePAReseauCM){

			planAction.SVR_AuditReseau__c =  auditRS.Id;
            planAction.SVR_ActionIdentifie1__c = ai1;
            planAction.SVR_CMStatut1__c = statut1;
            planAction.SVR_ActionIdentifie2__c = ai2;
            planAction.SVR_CMStatut2__c = statut2;
            planAction.SVR_ActionIdentifie3__c = ai3;
            planAction.SVR_CMStatut3__c = statut3;
            planAction.SVR_ActionIdentifie4__c =ai4;
			planAction.SVR_CMStatut4__c = statut4;
            planAction.SVR_ActionIdentifie5__c =ai5;
			planAction.SVR_CMStatut5__c = statut5;
            planAction.SVR_ActionIdentifie6__c =ai6;
			planAction.SVR_CMStatut6__c = statut6;
            planAction.SVR_ActionIdentifie7__c =ai7;
			planAction.SVR_CMStatut7__c = statut7;
			planAction.RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(getPlanActionRecordTypeNameRS((String) auditRS.Id)).getRecordTypeId();

		}else if(getPlanActionRecordTypeNameRS((String) auditRS.Id)== SVR_AP100_Constant.recordTypePAReseauQualite){

			planAction.SVR_AuditReseau__c =  auditRS.Id;
            planAction.SVR_ActionIdentifie1__c = ai1;
            planAction.SVR_QUAStatut1__c = statut1;
            planAction.SVR_ActionIdentifie2__c = ai2;
            planAction.SVR_QUAStatut2__c = statut2;
            planAction.SVR_ActionIdentifie3__c = ai3;
            planAction.SVR_QUAStatut3__c = statut3;
            planAction.SVR_ActionIdentifie4__c =ai4;
			planAction.SVR_QUAStatut4__c = statut4;
            planAction.SVR_ActionIdentifie5__c =ai5;
			planAction.SVR_QUAStatut5__c = statut5;
            planAction.SVR_ActionIdentifie6__c =ai6;
			planAction.SVR_QUAStatut6__c = statut6;
            planAction.SVR_ActionIdentifie7__c =ai7;
			planAction.SVR_QUAStatut7__c = statut7;
			planAction.RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(getPlanActionRecordTypeNameRS((String) auditRS.Id)).getRecordTypeId();

		}

		return planAction;
    }

    //create contact Bodyshop
    public static Contact createBodyshopContact(String firstName, String lastName, Id accountId){
		return new Contact(
			FirstName = firstName,
			LastName = lastName,
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId()
		);
	}

	public static String getPlanActionRecordTypeNameOP(String Id) {

        List<SVR_AuditOperationnel__c> listAuditOP = [SELECT id, recordTypeId
                    FROM SVR_AuditOperationnel__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditOP[0].recordTypeId == Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId() ){
            return SVR_AP100_Constant.recordTypePAOperationnelBOAdmin;
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactu).getRecordTypeId()){
            return SVR_AP100_Constant.recordTypePAOperationnelBOFactu;
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPGrosChoc).getRecordTypeId()){
            return SVR_AP100_Constant.recordTypePAOperationnelBOGrosChoc;
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPAppels).getRecordTypeId()){
            return SVR_AP100_Constant.recordTypePAOperationnelBOAppel;
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPQualite).getRecordTypeId()){
            return SVR_AP100_Constant.recordTypePAOperationnelBOQualite;
        }

        return null;
    }

	public static String getPlanActionRecordTypeNameRS(String Id) {

        List<SVR_AuditReseau__c> listAuditRS = [SELECT id, recordTypeId
                    FROM SVR_AuditReseau__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId() || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId() ){
            System.debug('######## JPI Sed: ' + SVR_AP100_Constant.recordTypePAReseauQualite);
			return SVR_AP100_Constant.recordTypePAReseauQualite;
        }else  if(listAuditRS[0].recordTypeId== Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId() || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId() ){
            System.debug('######## JPI Sed: ' + SVR_AP100_Constant.recordTypePAReseauCM);
			return SVR_AP100_Constant.recordTypePAReseauCM;
        }
        return null;
    }

	// create Peformance
	public static SVR_Performance__c createPerformance(Account acc,User usr){
		return new SVR_Performance__c(
			SVR_NomGarage__c = acc.ID,
			SVR_ResponsableSecteur__c = acc.SVR_AreaManager__c,
			SVR_NomGestionnaire__c = usr.Id
		);
	}

	//create Audit preficontrol
	public static SVR_AuditPreficontrol__c createAuditpreficontrol(SVR_AuditReseau__c AR){
		return new SVR_AuditPreficontrol__c (
			SVR_AuditReseau__c = AR.Id,
			SVR_MoyenneChiffrageInitialHTGarageCal__c = null ,
			SVR_MoyenneT1GarageCal__c = null ,
			SVR_MoyenneT2GarageCal__c = null ,
			SVR_MoyenneT3GarageCal__c = null ,
			SVR_MoyenneTPIngGarageCal__c = null ,
			SVR_MontantMoyenPiecesHTGarageCal__c = null ,
			SVR_MoyenneT1PreficontrolCal__c = null ,
			SVR_MoyenneT2PreficontrolCal__c = null ,
			SVR_MoyenneT3PreficontrolCal__c = null ,
			SVR_MoyenneTPIngPreficontrolCal__c = null ,
			SVR_MontantMoyenPiecesHTPrefiCal__c = null ,
			SVR_TauxEADConformeCal__c = null ,
			SVR_TauxMoyenAlphascaleCal__c = null ,
			SVR_TauxPositionTechniqueReparateurCal__c = null ,
			SVR_ChiffrageConformeGarageCal__c = null 
		);

	}

	// create dossier preficontrol
	public static SVR_DossierPreficontrol__c createDossierPreficontrol(SVR_AuditPreficontrol__c AP,Double ChiffGge,Double T1Gge,Double T2Gge,Double T3Gge,Double TPGge,Double MontPieceHTGge,Double T1prefi,Double T2prefi,Double T3prefi,Double TPprefi,Double MontPiecePrefi,Double T1Exp,Double T2Exp,Double T3Exp,Double TPExp,Double MontantPiecesExp){
		return new SVR_DossierPreficontrol__c(
			SVR_AuditPreficontrol__c = AP.Id,
			SVR_ChiffrageInitialHTGarage__c = ChiffGge ,
			SVR_T1GarageCal__c =  T1Gge,
			SVR_T2GarageCal__c =  T2Gge,
			SVR_T3GarageCal__c =  T3Gge,
			SVR_TPIngGarageCal__c =  TPGge,
			SVR_MontantPiecesHTGarage__c =  MontPieceHTGge,
			SVR_T1Preficontrol__c =  T1prefi,
			SVR_T2Preficontrol__c =  T2prefi,
			SVR_T3Preficontrol__c =  T3prefi,
			SVR_TPIngPreficontrol__c =  TPprefi,
			SVR_MontantPiecesPreficontrol__c =  MontPiecePrefi,
			SVR_T1Expert__c = T1Exp,
			SVR_T2Expert__c = T2Exp,
			SVR_T3Expert__c = T3Exp,
			SVR_TPIngExpert__c = TPExp,
			SVR_MontantPiecesExpert__c = MontantPiecesExp
			
		);
	}
    
    public static Account createPrefikarBodyAccount(String name, String typeReseau){
		return new Account(
				Name = name,
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BODYSHOP').getRecordTypeId(),
				ShippingCountry = 'France',
				ShippingCity = 'Paris',
				ShippingStreet = '5 RUE EMILE LEPEU',
				ShippingPostalCode = '75011',
				NOB_NetworkType__c = typeReseau,
				BillingCountryCode = 'FR',
                NOB_isPrefikar__c = true,
                NOB_Statut__c = 'Actif'
		);
	}

	public static PFR_Transaction__c createTransaction(Id idDocFin){
		return new PFR_Transaction__c(
				PFR_ReferenceFinDoc__c = idDocFin
		);
	}
	

	//create ContentVersion
    public static ContentVersion createContentVersion(String title, String type) {
        return new ContentVersion(
            Title = title,
            PathOnClient = title +'.'+type,
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
    }

	 // create ContentVersion with ContentDocumentLink
	 public static ContentVersion createContentVersionWithLink(String parentId, String title, String type){
        ContentVersion cv = createContentVersion(title, type);
        insert cv;

        ContentVersion contentVersion = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id =:cv.Id];
        ContentDocumentLink cDocLink = new ContentDocumentLink(
            ContentDocumentId = contentVersion.ContentDocumentId,
            LinkedEntityId = parentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        Insert cDocLink;

        return contentVersion;
    }

	/**
	 * createAttestationAssurance create a record for NOB_MesDocuments
	 * @param contactId (String): Id of the contact
	 * @param accountId (String): Id of the repairman
	 * @return Nob_MesDocuments__c: new NOB_MesDocuments
	 */
	public static Nob_MesDocuments__c createAttestationAssurance(String contactId, String accountId){
		return new Nob_MesDocuments__c(
			Contact__c = contactId,
			NOB_CompagnieAssurance__c = 'test',
			NOB_DateDebut__c = Date.today(),
			NOB_DateFin__c = Date.today().addDays(10),
			NOB_Account__c = accountId,
			RecordTypeId = Schema.SObjectType.Nob_MesDocuments__c.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId()
		);
	}

	/**
	 * createZoneIntervention create a record for NOB_InterventionZone__c
	 * @param accountId (String): id of an account unique
	 * @param idExterne (String): external id
	 * @return NOB_InterventionZone__c: new NOB_InterventionZone__c
	 */
	public static NOB_InterventionZone__c createZoneIntervention(String accountId, String idExterne){
		return new NOB_InterventionZone__c(
			NOB_PostalCode__c = '75000',
			NOB_Account__c = accountId,
			NOB_ExternalId__c = idExterne
		);
	}
}