/*
  ----------------------------------------------------------------------
  -- - Name          : AP28UserAccountGroupSharing 
  -- - Author        : ABT 
  -- - Description   : Class to manage group creation, management according to Reference number--


  -- a. Create User
  -- b. Create group based on BodyshopId/DistributorId. Add user as group member in group created.
  -- c. Share account with same reference Id as group Name.
  -- d. When BodyshopId/DistributorId is modified on User, 
  --    (i)  delete user as group member from old group
  --    (ii) repeat process of insert.

  -- a. In case Account is created first, create group based on referenceNumber. 
  -- b. Search for users with same BodyshopId/DistributorId. Add user as group member in group created.

  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 05-APR-2016  ABT    1.0     C-001496: Use the Reference Number in Public Group for sharing to BS and Dist
  -- 05-APR-2016  ASE    1.1     Add method updateGroupMember. 
  -- 12-APR-2016  ABT	 1.2	 Added the funtionality of having the developername containing the prefix of the country
  -- 02-SEP-2020  WCH	 1.3	 C-003913: NOB - DEVS l'impact si on cr�e un nouveau recordtype pour les experts
    ----------------------------------------------------------------------
 **********************************************************************
*/
public without sharing class AP28UserAccountGroupSharing 
{

	public static void shareAccount(Map<String, Account> mapReferenceNumberAccount)
	{
		System.debug('---------------------------------- START AP28UserAccountGroupSharing - shareAccount ----------------------------------');

		// Get all the Groups from the Reference Numbers collected
		// Check for non existing Groups and create them
		// A Map will be used to store the relationship of Reference Numbers and Group
		// Select Users having the Reference Numbers in the Distributor Id or BodyShopId
		// Add them to the group of that reference number

		Map<String, Group> mapReferenceNumberGroup = new Map<String, Group>();

		// Getting existing group
		for (Group gr : [SELECT Id, Name
						 FROM	Group
						 WHERE	Name IN : mapReferenceNumberAccount.keySet()])
		{
			mapReferenceNumberGroup.put(gr.Name, gr);
		}

		// Checking if group exists or not
		// If not add it to list to create the group
		List<Group> groupsToCreateList = new List<Group>(); 
		for (String refNumber : mapReferenceNumberAccount.keySet())
		{
			// if not present in map
			if (!mapReferenceNumberGroup.containsKey(refNumber))
			{
				// Create a group with that name
				Group g = new Group( Name			= refNumber,
									 DeveloperName	= (mapReferenceNumberAccount.get(refNumber).ShippingCountryCode != null) ? mapReferenceNumberAccount.get(refNumber).ShippingCountryCode + refNumber :  null
								   );
				mapReferenceNumberGroup.put(refNumber, g);
				groupsToCreateList.add(g);
			}
		}

		// Insert the groups
		if (groupsToCreateList.size() > 0)
		{
			insert groupsToCreateList;
		}

		Set<String> groupIdUserSet = new Set<String>();
		// Getting the users having the reference number in either Distributor Id or BodyShopId
		//AMI 18/07/2018 : Community Rollout
		//				 : Bypassing users addition to public group if profile is community

		string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
		string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

		for (User u : [SELECT Id, BodyShopID__c, DistributorID__c,Profile.UserLicense.Name
					   FROM	  User
					   WHERE  IsActive = true
					   AND	  (BodyShopID__c IN: mapReferenceNumberAccount.keySet()
					   OR	   DistributorID__c IN: mapReferenceNumberAccount.keySet())])
		{
			// Checks if the body shop id is not null
			if (u.BodyShopID__c != null &&
     			(string.isBlank(formattedLicenseName) ||
     			(string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((u.Profile.UserLicense.Name).toLowerCase())))
				){
				groupIdUserSet.add(mapReferenceNumberGroup.get(u.BodyShopID__c).Id + ';' + u.Id);
			}

			// Checks if the distributor id is not null
			if (u.DistributorID__c != null &&
     			(string.isBlank(formattedLicenseName) ||
     			(string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((u.Profile.UserLicense.Name).toLowerCase())))
				){
				groupIdUserSet.add(mapReferenceNumberGroup.get(u.DistributorID__c).Id + ';' + u.Id);
			}
		}

		if (groupIdUserSet.size() > 0)
		{
			AP28UserAccountGroupSharing.generateGroupMember(groupIdUserSet);
		}


		// inserting account sharing
		List<AccountShare> accountShareList = new List<AccountShare>();
		for (String refNumber : mapReferenceNumberAccount.keySet())
		{
			accountShareList.add( new AccountShare(	AccountId				= mapReferenceNumberAccount.get(refNumber).Id,
													AccountAccessLevel		= 'Edit',
													OpportunityAccessLevel	= 'Edit',
													UserOrGroupId			= mapReferenceNumberGroup.get(refNumber).Id)
								);
		}

		if (accountShareList.size() > 0)
		{
			insert accountShareList;
		}
		System.debug('---------------------------------- END AP28UserAccountGroupSharing - shareAccount ----------------------------------');
	}

	public static void shareUser(Map<String, List<User>> mapReferenceNumberUser)
	{
		System.debug('---------------------------------- START AP28UserAccountGroupSharing - shareUser ----------------------------------');

		// Get all the Groups from the Reference Numbers collected
		// Check for non existing Groups and create them
		// A Map will be used to store the relationship of Reference Numbers and Group
		// Select Users having the Reference Numbers in the Distributor Id or BodyShopId
		// Add them to the group of that reference number

		// Map Record Type for Account
		Map<String, Id> accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

		Map<String, Group> mapReferenceNumberGroup = new Map<String, Group>();

		// Getting existing group
		for (Group gr : [SELECT Id, Name
						 FROM	Group
						 WHERE	Name IN : mapReferenceNumberUser.keySet()])
		{
			mapReferenceNumberGroup.put(gr.Name, gr);
		}

		// Getting the roles and its prefix
		Map<String, String> mapReferenceNumberGroupPrefix = new Map<String, String>();

		//Set<User> userList = new Set<User>(); 
		//for (String refNumber : mapReferenceNumberUser.keySet())
		//{
		//	userList.addAll(mapReferenceNumberUser.get(refNumber));
		//}

		// ABR 12-APR-2016 - same code as below moved here
		Set<User> userSet = new Set<User>(); 
		for (String refNumber : mapReferenceNumberUser.keySet())
		{
			userSet.addAll(mapReferenceNumberUser.get(refNumber));
		}

		//AMI 18/07/2018 : Community Rollout
		//				 : Bypassing public group automatic creation  and users addition to latter if profile is community
		set <User> validUserSet = new set <User>();

		string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
		string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

		for(User u : [SELECT Id, UserRoleId, UserRole.Name, BodyShopID__c, DistributorID__c,Profile.UserLicense.Name
					  FROM User
					  WHERE Id IN: userSet])
		{
			System.debug('## Entered Role Selection');

			//AMI 18/07/2018 : Community Rollout
			//				 : Continue action if and only if user profile is not community
			if( string.isBlank(formattedLicenseName) ||
			    (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains((u.Profile.UserLicense.Name).toLowerCase()))
			){	
				if (u.BodyShopID__c != null && u.UserRoleId != null){
					mapReferenceNumberGroupPrefix.put( u.BodyShopID__c, u.UserRole.Name.left(2) );
				}

				if (u.DistributorID__c != null && u.UserRoleId != null){
					mapReferenceNumberGroupPrefix.put( u.DistributorID__c, u.UserRole.Name.left(2) );
				}

				//AMI 18/07/2018 : Community Rollout
				//				 : update valid user set only with those who don't have a community license
				validUserSet.add(u);
			}
		}

		// Checking if group exists or not
		// If not add it to list to create the group
		List<Group> groupsToCreateList = new List<Group>(); 
		for (String refNumber : mapReferenceNumberUser.keySet())
		{
			// if not present in map
			if (!mapReferenceNumberGroup.containsKey(refNumber))
			{
				// Create a group with that name
				Group g = new Group( Name			= refNumber,
									 DeveloperName	= ( mapReferenceNumberGroupPrefix.containsKey(refNumber) ) ? mapReferenceNumberGroupPrefix.get(refNumber) + refNumber : null
								   );
				mapReferenceNumberGroup.put(refNumber, g);
				groupsToCreateList.add(g);
			}
		}

		// Insert the groups
		if (groupsToCreateList.size() > 0)
		{
			insert groupsToCreateList;
		}

		System.debug('## mapReferenceNumberGroup: ' + mapReferenceNumberGroup);

		Set<String> groupIdUserSet = new Set<String>();
		// Getting the users having the reference number in either Distributor Id or BodyShopId
		//for (User u : [SELECT Id, BodyShopID__c, DistributorID__c
		//			   FROM	  User
		//			   WHERE  BodyShopID__c IN: mapReferenceNumberUser.keySet()
		//			   OR	  DistributorID__c IN: mapReferenceNumberUser.keySet()])
		//{
		//	// Checks if the body shop id is not null
		//	if (u.BodyShopID__c != null)
		//	{
		//		groupIdUserSet.add(mapReferenceNumberGroup.get(u.BodyShopID__c).Id + ';' + u.Id);
		//	}
		//
		//	// Checks if the distributor id is not null
		//	if (u.DistributorID__c != null)
		//	{
		//		groupIdUserSet.add(mapReferenceNumberGroup.get(u.DistributorID__c).Id + ';' + u.Id);
		//	}
		//}


		// Extract all the users in the map
		// ABT 12-APR-2016 - Commented (Moved Above)
		// Set<User> userSet = new Set<User>(); 
		// for (String refNumber : mapReferenceNumberUser.keySet())
		// {
		// 	userSet.addAll(mapReferenceNumberUser.get(refNumber));
		// }

		// Loop in the user being inserted
		//AMI 18/07/2018 : Community Rollout
		//				 : change loop set from userSet to validUserSet
		for (User u : validUserSet)
		{
			if (u.BodyShopID__c != null)
			{
				groupIdUserSet.add(mapReferenceNumberGroup.get(u.BodyShopID__c).Id + ';' + u.Id);
			}

			if (u.DistributorID__c != null)
			{
				groupIdUserSet.add(mapReferenceNumberGroup.get(u.DistributorID__c).Id + ';' + u.Id);
			}
		}

		System.debug('## groupIdUserSet: ' + groupIdUserSet);

		if (groupIdUserSet.size() > 0)
		{
			AP28UserAccountGroupSharing.generateGroupMember(groupIdUserSet);
		}

		// ASE: 18/04/16 using @future method to avoid mixed dml operations
		// Getting account that has the same reference number as the user
		// inserting account sharing
		List<AccountShare> accountShareList = new List<AccountShare>();
		Set<String> accountShareSet = new Set<String>();
		for (Account acc : [SELECT Id, ReferenceNumber__c, RecordTypeId
							FROM   Account
							WHERE  ReferenceNumber__c IN: mapReferenceNumberUser.keySet()
							AND	   (RecordTypeId =: accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
							OR		RecordTypeId =: accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
							OR		RecordTypeId =: accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Expert)/*WCH 02/09/2020 C-003913 */)])
		{
			/*accountShareList.add( new AccountShare(	AccountId				= acc.Id,
													AccountAccessLevel		= 'Edit',
													OpportunityAccessLevel	= 'Edit',
													UserOrGroupId			= mapReferenceNumberGroup.get(acc.ReferenceNumber__c).Id)
								);*/
			// ASE: 20/04/2016
			accountShareSet.add(acc.Id + ';' + mapReferenceNumberGroup.get(acc.ReferenceNumber__c).Id);
		}


		/*if (accountShareList.size() > 0)
		{
			insert accountShareList;
		}*/

		if (accountShareSet.size() > 0)
		{
			AP28UserAccountGroupSharing.generateAccountShare(accountShareSet);
		}

		System.debug('---------------------------------- END AP28UserAccountGroupSharing - shareUser ----------------------------------');
	}

	@future
	public static void generateGroupMember(Set<String> gmList)
	{
		// @Future method to avoid mixed dml operations
		// function used to assign the users to the public group
		List<GroupMember> groupMemberList = new List<GroupMember>(); 

		for (String groupMember : gmList)
		{
			// Splitting the string using ; as delimiter
			// Index 0 --> Group Id
			// Index 1 --> User Id
			List<String> groupIdUserList = groupMember.split(';'); 
			groupMemberList.add( new GroupMember( GroupId		= groupIdUserList[0],
												  UserOrGroupId = groupIdUserList[1])
							   );
		}

		if (groupMemberList.size() > 0)
		{
			insert groupMemberList;
		}
	}

	// ASE: 18/04/16 
	@future
	public static void generateAccountShare(Set<String> accountShareSet)
	{
		// @Future method to avoid mixed dml operations
		// function used to insert accountshare
		List<AccountShare> accountShareList = new List<AccountShare>();

		for (String accShare : accountShareSet)
		{
			// Splitting the string using ; as delimiter
			// Index 0 --> AccountId
			// Index 1 --> UserOrGroupId
			List<String> accIdGroupIdList = accShare.split(';'); 
			accountShareList.add( new AccountShare(AccountId = accIdGroupIdList[0],
												  AccountAccessLevel = 'Edit',
												  OpportunityAccessLevel = 'Edit',
												  UserOrGroupId	= accIdGroupIdList[1])
							   );
		}

		if (accountShareList.size() > 0)
		{
			insert accountShareList;
		}
	}




	// ASE:06/04/2016  Case C-001496
	public static void updateGroupMember(set<String>oldDistributorIds, set<String>oldBodyShopIds, list<User> users,  Map<String, List<User>> mapReferenceNumberListOfUser){
        system.debug('######### updateGroupMember START');
        set<String> allRefSet = new set<String>();
        list<GroupMember> groupMemberToBeDeleted = new list<GroupMember>();

        // all ref in set
        allRefSet.addAll(oldDistributorIds);
        allRefSet.addAll(oldBodyShopIds);


         //find group member for the old acc
        for(GroupMember gM:[select UserOrGroupId
                                   ,Id
                                   ,GroupId
                                   ,Group.Name 
                            From GroupMember
                            where UserOrGroupId IN:users]){
            //check old account group
            if(oldDistributorIds!=null){
            	if(oldDistributorIds.contains(gM.Group.Name)){
	                groupMemberToBeDeleted.add(gM);
	            }
            }
            if(oldBodyShopIds!=null){
	            if(oldBodyShopIds.contains(gM.Group.Name)){
	                groupMemberToBeDeleted.add(gM);
	            }
	        }
        }//end loop
        if(groupMemberToBeDeleted.size()>0){
            delete groupMemberToBeDeleted;
        }

        // call method to share user        
        if(mapReferenceNumberListOfUser.size()>0){
        	System.enqueueJob(new AP28ShareUserQueueable(mapReferenceNumberListOfUser));
            //AP28ShareUserQueueable.shareUser(mapReferenceNumberListOfUser);        
        }
        
        system.debug('######### updateGroupMember END');
    }
}