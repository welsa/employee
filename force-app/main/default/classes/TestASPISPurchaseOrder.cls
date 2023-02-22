/*************************************************************************************
Class Name - TestASPISPurchaseOrder
Version - 1.0
Created Date - 22 May 2015
Function - test class for ASPISPurchaseOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)	     	22/05/2015  Original Version
* Bhavish (sc)			27/05/2015	Added Assert
* Dourga 				19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Shamina M             22/01/2016  case 1386 - business hours
* Dourga                22/09/2016  Updated Version 2 (case 1615)     
************************************************************************************/
@isTest
private class TestASPISPurchaseOrder {
	// ABT - 02-DEC-2016 - C-001625
	/*
	static list<Assessment__c> assessments;
	static User userAdmin;
	static list<PartList__c> parts;
	static list<account> distributors;
	static list <CountryCodeInformationsMapping__c> countryCodeInfos;
	static BusinessHours defaultHours;
    static list<Account> accounts;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
	
	static {
		
		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		
		UserRole rol = new UserRole(name = 'FR - Admin');
		insert rol;
		
		userAdmin = new User(Username = 'jean.paul-testingNewName1@test.com'  // checking for UNABLE_TO_LOCK_ROW error in running test parallel
            ,LastName = 'paul'
            ,LanguageLocaleKey = 'en_US'
            ,FirstName = 'jean'
            ,Email = 'jean@test1.com'
            ,Alias = 'jpa'
            ,TimeZoneSidKey = 'Europe/Dublin'
            ,LocaleSidKey = 'en_US'
            ,EmailEncodingKey = 'UTF-8'
			,UserRoleId = rol.Id
            ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
		
        system.runas(userAdmin){
				
        	// insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '123'
                    ,ContactEmail__c = 'bt1@gmail.com'
					,ShippingCountry = 'FRANCE'
                ),
                new Account(Name='BodyShop_ScTest2'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '1234'
                    ,ContactEmail__c = 'bt2@gmail.com'
					,ShippingCountry = 'FRANCE'
                ),
                new Account(Name='Distributor_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '12345'
                    ,ContactEmail__c = 'dt1@gmail.com'
                    ,Categories__c = 'A; B; C'
                ),
                new Account(Name='Distributor_ScTest2'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                    ,ReferenceNumber__c = '123456'
                    ,ContactEmail__c = 'dt1@gmail.com'
                     ,Categories__c = 'A; B; C'
                )
            };
            ASPISTestUtils.generateAccount (accounts);
            accounts[0].ShippingCountryCode = 'FR';
            accounts[1].ShippingCountryCode = 'FR';
            update accounts;

			assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0003',
																	AssessmentNumber__c = 'ASSESS_TEST-0003',
																	BodyShop__c = accounts[1].Id,
																	Entity__c = 'AXA Direct',
																	MissionNumber__c = '011',
																	PortfolioAgentCode__c = '3551',
																	AssessmentID__c = '09121',
																	TechExternalId__c = '2331',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED',
																	TECH_EntityCountryCode__c = 'FR'),
	                                                
	                                           		new Assessment__c(Name='ASSESS_TEST-0004',
																	AssessmentNumber__c = 'ASSESS_TEST-0004',
																	BodyShop__c = accounts[0].Id,
																	Entity__c = 'AXA Direct1',
																	MissionNumber__c = '021',
																	PortfolioAgentCode__c = '35451',
																	AssessmentID__c = '59121',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED',
																	TECH_EntityCountryCode__c = 'FR')
	                
	        };
	            
	        insert assessments;			
			
			//Get the default business hours (we might need it)
            defaultHours = [select Id from BusinessHours where IsDefault=true];
            
            // custom settings - CountryCodeInfo
            countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
                new CountryCodeInformationsMapping__c(
                    Name='FR'
                    ,BusinessHoursID__c = defaultHours.Id
                ),
                 new CountryCodeInformationsMapping__c(
                    Name='DEFAULT'
                    ,BusinessHoursID__c = defaultHours.Id
                )
            };
            insert countryCodeInfos;
	    	
	    	parts = new list<PartList__c>{
	    		new PartList__c(Assessment__c=assessments[0].id, 
	    						PartNumber__c='p01',
	    						Name='part 01',
	    						Description__c='test part 1',
	    						Quantity__c=1,
	    						Price__c=100,
	    						Type__c='A')
	    	};
	    	ASPISTestUtils.generatePartList(parts);
			distributors = new list<account>{accounts[2], accounts[3]};
	    }//end runas
	}

	static testMethod void testCreateOrders() {
		
		system.runas(userAdmin){
			test.starttest();
				ASPISPurchaseOrder.createOrders(assessments[0], distributors);
			test.stoptest();
			List<PurchaseOrder__c> purchaseOrders = new List<PurchaseOrder__c>([select assessment__c
																						,validityDate__c
																						,status__c
																						,distributor__c
																						,recordTypeId
																				from PurchaseOrder__c 
																				where (distributor__c =: distributors[0].id or distributor__c =: distributors[1].id) 
																				and status__c =:system.Label.PURCHASEORDERDRAFTQUOTESTATUS 
																				and assessment__c =: assessments[0].id]);
			System.assertEquals(2, purchaseOrders.size());
			System.assertNotEquals(null, purchaseOrders[0].validityDate__c);
			System.assertNotEquals(null, purchaseOrders[1].validityDate__c);
			System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(), purchaseOrders[0].recordTypeId);
			System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(), purchaseOrders[1].recordTypeId);
			
			
			List<OrderLine__c> orderLines = new List<OrderLine__c>([select partNumber__c
																			,description__c
																			,purchaseOrder__c
																			,type__c
																			,quantity__c
																			,AssessmentPrice__c
																			,CataloguePrice__c
																			,VAT__c
																			,PartList__c
																	from OrderLine__c
																	where (purchaseOrder__c=:purchaseOrders[0].id or purchaseOrder__c=:purchaseOrders[1].id)
																	]);
			System.assertEquals(2, orderLines.size());
			for(OrderLine__c oLine : orderLines){
				System.assertEquals(parts[0].partNumber__c, oLine.partNumber__c);
				System.assertEquals(parts[0].description__c, oLine.description__c);
				System.assertEquals(parts[0].type__c, oLine.type__c);
				System.assertEquals(parts[0].quantity__c, oLine.quantity__c);
				System.assertEquals(parts[0].Price__c, oLine.AssessmentPrice__c);
				System.assertEquals(parts[0].Price__c, oLine.CataloguePrice__c);
				System.assertEquals(parts[0].VAT__c, oLine.VAT__c);
				System.assertEquals(parts[0].id, oLine.PartList__c);
			}
		}//end runas 
	}


	static testMethod void testCreateOrdersV1() {
		
		system.runas(userAdmin){
			test.starttest();
				ASPISPurchaseOrder.createOrders(assessments[1], distributors);
			test.stoptest();
			List<PurchaseOrder__c> purchaseOrders = new List<PurchaseOrder__c>([select assessment__c
																						,validityDate__c
																						,status__c
																						,distributor__c
																						,recordTypeId
																				from PurchaseOrder__c 
																				where (distributor__c =: distributors[0].id or distributor__c =: distributors[1].id) 
																				and status__c =:system.Label.PURCHASEORDERDRAFTQUOTESTATUS 
																				and assessment__c =: assessments[1].id]);
			System.assertEquals(2, purchaseOrders.size());
			System.assertNotEquals(null, purchaseOrders[0].validityDate__c);
			System.assertNotEquals(null, purchaseOrders[1].validityDate__c);
			System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(), purchaseOrders[0].recordTypeId);
			System.assertEquals(Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(), purchaseOrders[1].recordTypeId);
			

		}//end runas 
	}
	*/
}