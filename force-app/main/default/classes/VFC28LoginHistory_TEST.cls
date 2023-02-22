@isTest
private class VFC28LoginHistory_TEST {
    
    static User adminUser;
    
    static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;
        
    }
    
    
    @isTest static void constructor_TEST() 
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP28LoginHistory);

			Test.startTest();
				VFC28LoginHistory controller = new VFC28LoginHistory(new ApexPages.StandardController(new user()));
			Test.stopTest();

			
		}
	}

}