/*
  ----------------------------------------------------------------------
  -- - Name          : APCreateAttachments_TEST 
  -- - Author        : ABT 
  -- - Description   : Test Class for APCreateAttachments
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 20-SEP-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class APCreateAttachments_TEST 
{
	static User adminUser;
	static Log__c log;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			log = new Log__c(
								DateLog__c	= System.now(),
								Status__c	= 'Passed'
							);
		
			insert log;
		}
	}

	@isTest static void createAttachmentWithFileExtension_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				APCreateAttachments.createAttachment('Request.txt', 'This is the body of the attachment', log);
			Test.stopTest();

			List<Attachment> attachmentList =	[SELECT Id, Name, ParentId
												 FROM	Attachment
												 WHERE	ParentId =: log.Id];
			
			System.assertEquals(1, attachmentList.size());
			System.assertEquals('Request.txt', attachmentList[0].Name);
		}
	}

	@isTest static void createAttachmentWithoutFileExtension_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				APCreateAttachments.createAttachment('Response', 'This is the body of the attachment', log);
			Test.stopTest();

			List<Attachment> attachmentList =	[SELECT Id, Name, ParentId
												 FROM	Attachment
												 WHERE	ParentId =: log.Id];
			
			System.assertEquals(1, attachmentList.size());
			System.assertEquals('Response.txt', attachmentList[0].Name);
		}
	}
}