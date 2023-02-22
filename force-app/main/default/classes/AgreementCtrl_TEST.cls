/*
  ----------------------------------------------------------------------
  -- - Name          : AgreementCtrl_TEST 
  -- - Author        : ABT 
  -- - Description   : AgreementCtrl_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 22-APR-2016  ABT    1.0     Reworked version + Coverage to 100%
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Immo Salo		08/07/2015	Original Version
 **********************************************************************
*/
@isTest
public class AgreementCtrl_TEST 
{
	static User BSUserFR;
	static User adminUserES;
	static User DistUserIT;
	static List<Document> documentList;
	static List<CS_Agreement__c> csAgreementList;

	static
	{
		BSUserFR					  = TestFactory.createUserBodyshop('BSUserFR');
		BSUserFR.LanguageLocaleKey = 'FR';

		adminUserES					  = TestFactory.createUserASPISLocal('adminUserES');
		adminUserES.LanguageLocaleKey = 'ES';
        
		DistUserIT					  = TestFactory.createUserDistributor('DistUserIT');
		DistUserIT.LanguageLocaleKey = 'IT';

		List<User> userList = new List<User>
		{
			BSUserFR,
			adminUserES,
                DistUserIT
		};

		insert userList;

		documentList = new List<Document>	
		{
			new Document(	Name			= 'General Agreement',
							DeveloperName	= 'General_Agreement',
							Description		= 'Love it',
							Body			= Blob.valueOf('Hi Friends'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= UserInfo.getUserId(),
							FolderId		= UserInfo.getUserId()
						),                
			new Document(	Name			= 'AgreementFrench',
							DeveloperName	= 'AgreementFrench',
							Description		= 'Love it',
							Body			= Blob.valueOf('Hi Friends'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= UserInfo.getUserId(),
							FolderId		= UserInfo.getUserId()
						)
		};

		insert documentList;

		csAgreementList = new List<CS_Agreement__c>
		{

			new CS_Agreement__c(Name					= 'DEFAULT',
								Agreement_Document__c	= 'General_Agreement',
								User_Field__c			= 'General_Agreement__c',
								Url_Context__c			= '/home/home.jsp',
								Active__c				= true,
								General__c				= true),                
			new CS_Agreement__c(Name					= 'FR',
								Agreement_Document__c	= 'AgreementFrench',
								User_Field__c			= 'General_Agreement__c',
								Url_Context__c			= '/home/home.jsp',
								Active__c				= true,
								General__c				= false),
			new CS_Agreement__c(Name					= 'ES',
								Agreement_Document__c	= 'AgreementSpain',
								User_Field__c			= 'General_Agreement__c',
								Url_Context__c			= '/home/home.jsp',
								Active__c				= true,
								General__c				= false)
		};

		insert csAgreementList;
	}

	@isTest static void agreementTestWithFRUser()
	{
		System.runAs(BSUserFR)
		{
			Test.setCurrentPage(Page.AgreementVFPage);

			Test.startTest();
				ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
				AgreementCtrl ac = new AgreementCtrl();
				//ac.Init();
				//ApexPages.currentPage().getParameters().put('name', 'DEFAULT');
				ac.Init();
				ac.Agree();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: BSUserFR.Id];
							         
			System.assertEquals(true, updatedUser.General_Agreement__c);
			System.assertEquals('FR', ac.AgreementName);
		}
	}

	@isTest static void agreementTestWithFRUserWithNoAgreementName()
	{
		System.runAs(BSUserFR)
		{
			Test.setCurrentPage(Page.AgreementVFPage);

			Test.startTest();
				ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
				AgreementCtrl ac = new AgreementCtrl();
				ac.Init();
				ac.Agree();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: BSUserFR.Id];
							         
			System.assertEquals(true, updatedUser.General_Agreement__c);
			System.assertEquals('FR', ac.AgreementName);
		}
	}

	@isTest static void agreementTestWithESUser()
	{
		System.runAs(adminUserES)
		{
			Test.setCurrentPage(Page.AgreementVFPage);

			Test.startTest();
				ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
				AgreementCtrl ac = new AgreementCtrl();
				//ac.Init();
				//ApexPages.currentPage().getParameters().put('name', 'AgreementConfiguration');
				ac.Init();
            	System.assertEquals('ES', ac.AgreementName);
				ApexPages.currentPage().getParameters().put('name', 'ES');
				ac.Init();
				ac.Agree();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: adminUserES.Id];
							         
			System.assertEquals(true, updatedUser.General_Agreement__c);
            
            // Check that a log has been created
            List<Log__c> l_logs = [SELECT Id, ErrorCode__c,ErrorDescription__c FROM Log__c WHERE CreatedDate = TODAY AND CreatedById = :adminUserES.Id];
            System.assertEquals('Document Missing', l_logs[0].ErrorCode__c);
            System.assertEquals('Unable to find the agreement document for this configuration ES', l_logs[0].ErrorDescription__c);            
		}
	}

	@isTest static void agreementTestWithITUser()
	{
		System.runAs(DistUserIT)
		{
			Test.setCurrentPage(Page.AgreementVFPage);

			Test.startTest();
				ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
				AgreementCtrl ac = new AgreementCtrl();
				//ac.Init();
				//ApexPages.currentPage().getParameters().put('name', 'DEFAULT');
				ac.Init();
            	System.assertEquals('DEFAULT', ac.AgreementName);
				ac.Agree();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: DistUserIT.Id];
							         
			System.assertEquals(true, updatedUser.General_Agreement__c);
            
            // Check that a log has been created
            List<Log__c> l_logs = [SELECT Id, ErrorCode__c FROM Log__c WHERE CreatedDate = TODAY AND CreatedById = :DistUserIT.Id];
            for(Log__c log : l_logs){
                System.assertEquals('Configuration Missing', log.ErrorCode__c);
            }
		}
	}

/*	@isTest static void disagreeementWithoutGeneralAgreement()
	{
		System.runAs(BSUserFR)
		{
			csAgreementList[0].General__c = false;

			update csAgreementList;
			
			Test.setCurrentPage(Page.AgreementVFPage);

			ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
			AgreementCtrl ac = new AgreementCtrl();
			ac.Init();

			Test.startTest();
				PageReference pr = ac.Redirect();
			Test.stopTest();
            				         
			System.assertEquals('/home/home.jsp', pr.getUrl());
		}
	}*/

	@isTest static void disagreeementWithGeneralAgreement()
	{
		System.runAs(BSUserFR)
		{	
			Test.setCurrentPage(Page.AgreementVFPage);

			ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
            ApexPages.currentPage().getParameters().put('name', 'FR');
			AgreementCtrl ac = new AgreementCtrl();
			ac.Init();

			Test.startTest();
				PageReference pr = ac.Redirect();
			Test.stopTest();
            				         
			System.assertEquals('/secur/logout.jsp', pr.getUrl());
		}
	}

	@isTest static void DocumentNotFound()
	{
        DELETE documentList;
		System.runAs(BSUserFR)
		{	
			Test.startTest();
                Test.setCurrentPage(Page.AgreementVFPage);    
                ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
                ApexPages.currentPage().getParameters().put('name', 'FR');
                AgreementCtrl ac = new AgreementCtrl();
                ac.Init();
				ac.Agree();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: BSUserFR.Id];
							         
			System.assertEquals(true, updatedUser.General_Agreement__c);
			System.assertEquals('FR', ac.AgreementName);
            
            // Check that a log has been created
            List<Log__c> l_logs = [SELECT Id, ErrorCode__c,ErrorDescription__c FROM Log__c WHERE CreatedDate = TODAY AND CreatedById = :BSUserFR.Id];
            
            System.assertEquals('Document Missing', l_logs[0].ErrorCode__c);
            System.assertEquals('Unable to find the default agreement document', l_logs[0].ErrorDescription__c);
            
		}
	}

	@isTest static void ConfigNotFound()
	{
        DELETE documentList;
        DELETE csAgreementList;
		System.runAs(BSUserFR)
		{	
			Test.startTest();
                Test.setCurrentPage(Page.AgreementVFPage);    
                ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
                AgreementCtrl ac = new AgreementCtrl();
                ac.Init();
			Test.stopTest();
            
			// check that General_Agreement__c field was checked True
			User updatedUser = [SELECT Id, General_Agreement__c 
								FROM User 
								WHERE Id =: BSUserFR.Id];
							                     
            // Check that a log has been created
            List<Log__c> l_logs = [SELECT Id, ErrorCode__c,ErrorDescription__c FROM Log__c WHERE CreatedDate = TODAY AND CreatedById = :BSUserFR.Id];
            
            System.assertEquals('Configuration Missing', l_logs[0].ErrorCode__c);
            System.assertEquals('Unable to find the agreement configuration for this country FR', l_logs[0].ErrorDescription__c);
            System.assertEquals('Configuration Missing', l_logs[1].ErrorCode__c);
            System.assertEquals('Unable to find any agreement configuration', l_logs[1].ErrorDescription__c);
            
            PageReference pr = ac.Redirect();
			System.assertEquals('/home/home.jsp', pr.getUrl());
		}
	}
}