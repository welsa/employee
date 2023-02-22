/*************************************************************************************
Class Name - AP22PopulateContactOnAccount
Version - 1.0
Created Date - 14 DEC 2015
Function - Class to populate the ContactUser__c on Account before inserting an Account

Modification Log :
-----------------------------------------------------------------------------
* Developer  	 Date       	Description
* ---------- 	 ----------  -----------------------
* Brayan Nunhuck 14/12/2015  Original Version
*************************************************************************************/
public class AP22PopulateContactOnAccount { 

	public static void populateContact(List<Account> l_Accounts, Set<String> s_ReferenceNumber){
		//Map to store AccountReference and its corresponding Users
		Map<String,User> m_Users = new Map<String,User>();

		
		//Query user to be able to build map m_Users
		for (User u : [Select Id,BodyShopID__c,DistributorID__c 
						from User 
							where BodyShopID__c in :s_ReferenceNumber OR DistributorID__c in :s_ReferenceNumber])
		{
			//as BodyShopID__c is account reference, put it as a key with the corresponding user
			if (u.BodyShopID__c != null)
			{
				m_Users.put(u.BodyShopID__c,u);
			}
			//as DistributorID__c is account reference, put it as a key with the corresponding user
			if (u.DistributorID__c != null)
			{
				m_Users.put(u.DistributorID__c,u);
			}
		}

		//loop in l_Accounts which represents trigger.new to populate ContactUser__c
		for (Account a : l_Accounts)
		{
			if (m_Users.containsKey(a.ReferenceNumber__c))
			{
				a.ContactUser__c = m_Users.get(a.ReferenceNumber__c).Id;
			}
		}
	}

}