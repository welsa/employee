/*************************************************************************************
Class Name - CaseTriggerHandler
Version - 1.0
Created Date - 2 APR 2015
Function - Class to Manage Case Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      08/06/2015  Original Version
* Cecile L      17/06/2015  When assign the Case to an individual User, change the status to "ASSIGNED"
* Immo S        06/07/2015  When case is added, use manual sharing to give access to the case to bodyshop or distributor - UNDER DEVELOPMENT
* Cecile L      02/09/2015  Add the uncheck of the Purchase Order field ASMarginTooLowCaseCreated__c when case is closed.
* Dourga U      19/11/2015  Add the uncheck of the Purchase Order field DistributorPriceHigger__c when case is closed.
* Dourga U      19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Dourga U      12/02/2016  case C-001529 : added field NotDeliveredCaseCreated__c to avoid duplicate of case creation
* Shamina M     17/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S     11/03/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
* Ashwina S     15/03/2015  C-001428: Gestion des pièces "à retourner" depuis ICE
* Dourga U      25/10/2016  C-001772: Create an exclusion on Incompatible Part Case RT
* Dourga U      08/08/2018  C-001851: Communication between Supplier vs B/S
* Neha P 		17/03/2022 	C-004642: Fermeture automatique des cases FR

*************************************************************************************/
public class CaseTriggerHandler {

	private boolean bIsExecuting = false;
	private integer iBatchSize = 0;
	public static boolean bFirstRun = true;
	public static Integer runNumber = 0;    
	
	public Static String COUNTRYCODEDEFAULT = 'ALL'; 
	public static String OBJECTCODE = '-CASE';
	public Static String DEFAULTCONFIG = '-DEFAULT';
	public Static String PROCESSDUEDATE = '-SETDUEDATE-';
	
	public CaseTriggerHandler(boolean isExecuting, integer size){
		bIsExecuting = isExecuting;
		iBatchSize = size;
	}
	
	public void OnBeforeInsert(Case__c[] newCases){
		system.debug('####### Start Case Before Insert process ');

		List<Id> l_assessmentIDs = new List<Id>();
		List<Id> l_purchaseOrderIDs = new List<Id>();
		List<Id> l_salesOrderIDs = new List<Id>();
		for(Case__c c:newCases){
			if(c.CountryCode__c == null){
				if(c.Assesment__c != null)
					l_assessmentIDs.add(c.Assesment__c);
				else if(c.Purchase_order__c != null)
					l_purchaseOrderIDs.add(c.Purchase_order__c);
				else                    
					l_salesOrderIDs.add(c.Sales_order__c);
			}
		}
		// Create a map to find the CountryCode from the Assessment, the Purchase Order or the Sales Order for each Case
		MAP<Id,Assessment__c> m_AssId2Assessment; 
		MAP<Id,PurchaseOrder__c> m_poId2PurchaseOrder; 
		MAP<Id,PrerequisiteOrder__c> m_soId2SalesOrder; 

		//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
		map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();
		
		if(l_assessmentIDs.size() > 0)
			m_AssId2Assessment = new Map<Id,Assessment__c>([SELECT Id, TECH_EntityCountryCode__c FROM Assessment__c WHERE Id IN :l_assessmentIDs]);
		if(l_purchaseOrderIDs.size() > 0)
			m_poId2PurchaseOrder = new Map<Id,PurchaseOrder__c>([SELECT Id, Assessment__r.TECH_EntityCountryCode__c FROM PurchaseOrder__c WHERE Id IN :l_purchaseOrderIDs]);
		if(l_salesOrderIDs.size() > 0)
			m_soId2SalesOrder = new Map<Id,PrerequisiteOrder__c>([SELECT Id, Assessment__r.TECH_EntityCountryCode__c FROM PrerequisiteOrder__c WHERE Id IN :l_salesOrderIDs]);
			
		//AMI 06/08/18 : Community Rollout 
        //             : New Variable Assignement
        boolean isCommunityUser = false;
        string commAccountId = '';
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

        //AMI 06/08/18 : Community Rollout 
        //             : Query connected user
        for(User us : [Select id,Profile.UserLicense.Name,Contact.AccountId,BodyShopID__c
                        from User 
                        where Id=: UserInfo.getUserId()]){
            if(string.isNotBlank(formattedLicenseName) && 
               formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase()) &&
               string.isNotBlank(us.BodyShopID__c)){
                    isCommunityUser = true;

                    if(string.isNotBlank(us.Contact.AccountId)){
                    commAccountId = us.Contact.AccountId;
                }
            }
        }

		for(Case__c c: newCases){
			// Copy the CountryCOde from the Assessment to the Case, if not already stored.
			if(c.CountryCode__c == null){
				if(m_AssId2Assessment != null && m_AssId2Assessment.containsKey(c.Assesment__c))
					c.CountryCode__c = m_AssId2Assessment.get(c.Assesment__c).TECH_EntityCountryCode__c;
				if(m_poId2PurchaseOrder != null && m_poId2PurchaseOrder.containsKey(c.Purchase_order__c))
					c.CountryCode__c = m_poId2PurchaseOrder.get(c.Purchase_order__c).Assessment__r.TECH_EntityCountryCode__c;
				if(m_soId2SalesOrder != null && m_soId2SalesOrder.containsKey(c.Sales_order__c))
					c.CountryCode__c = m_soId2SalesOrder.get(c.Sales_order__c).Assessment__r.TECH_EntityCountryCode__c;
			}
			
			// Assign the Case to a Queue depending on its details
			//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S added !allConfigCountryCodeInfo.get(newPurchaseOrderList[i].TECH_BodyshopCountryCode__c).AdvancedCaseManagement__c)
			if(!((String)c.OwnerId).contains('00G') &&
				(!allConfigCountryCodeInfo.containsKey(c.CountryCode__c) || 
				(allConfigCountryCodeInfo.containsKey(c.CountryCode__c) && 
			   	!allConfigCountryCodeInfo.get(c.CountryCode__c).AdvancedCaseManagement__c))){
				String configId = COUNTRYCODEDEFAULT+DEFAULTCONFIG;
				
				if(c.CountryCode__c != null && c.Case_Reason__c != null && c.Case_Reason__c != '')
					configId = c.CountryCode__c+'-'+c.Case_Reason__c;
				
				CountryQueueMapping__c configQueues;
				if(CountryQueueMapping__c.getall().containsKey(configId))
					configQueues = CountryQueueMapping__c.getall().get(configId);
				else if(CountryQueueMapping__c.getall().containsKey(c.CountryCode__c+DEFAULTCONFIG))
					configQueues = CountryQueueMapping__c.getall().get(c.CountryCode__c+DEFAULTCONFIG);
				else
					configQueues = CountryQueueMapping__c.getall().get(COUNTRYCODEDEFAULT+DEFAULTCONFIG);
				
				//DUN 25/10/2016  C-001772: added recordtype Incompatible Part Case
				if (configQueues != NULL && c.RecordTypeId != Schema.SObjectType.Case__c.getRecordTypeInfosByName().get('Incompatible Part Case').getRecordTypeId()) {
					c.OwnerId = configQueues.Queue_ID__c;
				}
			}
			
			// Calculate the Due Date based on its type                        
			if(c.Due_Date__c == null){
				CountryCodeInformationsMapping__c configCountryCodeInfo;
				CaseDetailsProcessMapping__c configCaseDetails;
				
				if(c.CountryCode__c != null){
					configCountryCodeInfo = allConfigCountryCodeInfo.get(c.CountryCode__c);
					configCaseDetails = Utils_ManageCaseCustom.getConfigurationDataForCase(OBJECTCODE, c.CountryCode__c, PROCESSDUEDATE+c.Type__c);
				}else{
					configCountryCodeInfo = allConfigCountryCodeInfo.get(COUNTRYCODEDEFAULT);
					configCaseDetails = Utils_ManageCaseCustom.getConfigurationDataForCase(OBJECTCODE, COUNTRYCODEDEFAULT, PROCESSDUEDATE+c.Type__c);
				}
				
				if(configCaseDetails != null && configCountryCodeInfo != null)
					c.Due_Date__c = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(configCaseDetails, configCountryCodeInfo, c.CountryCode__c);
			}

			//NPE 17/03/2022 C-004642: Fermeture automatique des cases FR
			if ((c.TECH_AutomaticCreationFromProcess__c == '-PO-Unsupplied' || c.TECH_AutomaticCreationFromProcess__c =='-PO-QuotationSLA2' || c.TECH_AutomaticCreationFromProcess__c == '-PO-OrderLineRectification') && c.countryCode__c== 'FR'){
				c.status__c = 'Closed';
			}
				
			//AMI 06/08/18 : Community Rollout 
            //             : Update Tech_BSAccount__c
            system.debug('## isCommunityUser ' + isCommunityUser);
            system.debug('## commAccountId ' + commAccountId);
            if(isCommunityUser && string.isNotBlank(commAccountId)){
                c.Tech_BSAccount__c = commAccountId;
            }  	
		} // for loop ends
		   
	}
	
	
	public void OnBeforeUpdate(Case__c[] oldCases, Case__c[] updatedCases, Map<ID, Case__c> CasesMap){
		system.debug('####### Start Case Before Update process ');

		for(Case__c c: updatedCases){
			//system.debug('####### c.OwnerId '+c.OwnerId);
			// If the Case is assigned to an individual user, set the status to "ASSIGNED"
			if(((String)c.OwnerId).contains('005') && c.Status__c == 'NEw'){
				c.Status__c = 'ASSIGNED';
			}
			
			// If the Case is Assigned, store the Resolution date and calculate the Assignation duration.
			if(c.Status__c == 'ASSIGNED' && CasesMap.get(c.Id).Status__c != c.Status__c){
				Utils_ManageCaseCustom.runSLAOnStatus_Assigned(c, c.CountryCode__c);
			}
			
			// If the Case is closed, store the closed date and calculate the Resolution duration.
			if(c.Status__c == 'CLOSED' && CasesMap.get(c.Id).Status__c != c.Status__c){
				Utils_ManageCaseCustom.runSLAOnStatus_Closed(c, c.CountryCode__c);
			}
		}
	}
	
	public void OnAfterUpdate(Case__c[] oldCases, Case__c[] updatedCases, Map<ID, Case__c> CasesMap){
		system.debug('####### Start Case After Update process ');
		List<PurchaseOrder__c> l_PurchaseOrdersIdToUpdate = new List<PurchaseOrder__c>();
		List<PrerequisiteOrder__c> l_SalesOrdersIdToUpdate = new List<PrerequisiteOrder__c>();
		for(Case__c c: updatedCases){
			// If the Case is closed, uncheck the checkbox on the Sales Order or the Purchase Order.
			if(c.Status__c == 'CLOSED' && CasesMap.get(c.Id).Status__c != c.Status__c){
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-Delayed' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, DelayedCaseCreated__c = FALSE));
				if(c.TECH_AutomaticCreationFromProcess__c == '-SO-DeliveryProblem' && c.Sales_order__c != null){
					l_SalesOrdersIdToUpdate.add(new PrerequisiteOrder__c(Id=c.Sales_order__c, HasSomeDeliveryIssuedCaseCreated__c = FALSE));
					//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
					if(c.Purchase_order__c != null){
						l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, OrderDiscussionCase__c = FALSE));
					}
				}
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-ASMarginTooLow' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, ASMarginTooLowCaseCreated__c = FALSE));
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-NotValidated' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, InvoiceStatusNotValidated__c = FALSE));
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-DistributorPriceHigh' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, DistributorPriceHigger__c = FALSE));
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-NotDelivered' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, NotDeliveredCaseCreated__c = FALSE));
				//ASE:15/03/2015 :C-001428
				if(c.TECH_AutomaticCreationFromProcess__c == '-SO-OfferReturned' && c.Sales_order__c != null)
					l_SalesOrdersIdToUpdate.add(new PrerequisiteOrder__c(Id=c.Sales_order__c, PartReturnedCaseCreated__c = FALSE));
					
				//DUN:05/10/2017 ticket 403
				if(c.TECH_AutomaticCreationFromProcess__c == '-ASS-BsNotFound' && c.Purchase_order__c != null){
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, BsNotFoundCaseCreated__c = FALSE));
				}

				// ABT 31-MAR-2016 C-001581
				if(c.TECH_AutomaticCreationFromProcess__c == '-PO-AdditionalDiscount' && c.Purchase_order__c != null)
					l_PurchaseOrdersIdToUpdate.add(new PurchaseOrder__c(Id=c.Purchase_order__c, HasCaseForAdditionalDiscount__c = FALSE));
			}
			
			//System.debug('##TECH_AutomaticCreationFromProcess__c'+c.TECH_AutomaticCreationFromProcess__c);
		}
		if(l_PurchaseOrdersIdToUpdate.size() != 0){
			update l_PurchaseOrdersIdToUpdate;
		}
		if(l_SalesOrdersIdToUpdate.size() != 0){
			update l_SalesOrdersIdToUpdate;
		}
		
		// IS 28/08, add manual sharing if case owner has changed

		//AMI 06/08/18 : Community Rollout 
        //             : Case sharing code commented since the logic is the same as that in the after insert 
        //             : trigger
        /*
			// add list for cases with manual sharing, IS 6.7.2015
			List<Case__Share> CasesToShare = New List<Case__Share>();
 

			Map<Id, Id> CaseCreatedByMap = New Map<Id, Id>();
			for(Case__c c: updatedCases){
				CaseCreatedByMap.put(c.CreatedById, c.Id); // here is user who created case id and case id
				//system.debug('c.CreatedById: '+c.CreatedById);
				//system.debug('c.Id: '+c.Id);
			}
		
			List<User> UsersWhoCreatedCases = [SELECT Id, BodyShopID__c, DistributorID__c FROM User WHERE Id IN :CaseCreatedByMap.KeySet()];

			Map<String, Id> AccountAndUserIdMap = New Map<String, Id>();

			Boolean isThereValueInBodyshopOrDistributorUserField = True;
			List<String> AccountsIdsToGetGroupName = New List<String>();
			for(User u:UsersWhoCreatedCases){
				if(u.BodyShopID__c!=Null){
					AccountsIdsToGetGroupName.add(u.BodyShopID__c);

					AccountAndUserIdMap.put(u.BodyShopID__c,u.Id);  // here comes account Id and user d who created case
					//system.debug('u.BodyShopID__c: '+u.BodyShopID__c);
					//system.debug('u.id: '+u.id);
				}
				else if(u.DistributorID__c!=Null){
					AccountsIdsToGetGroupName.add(u.DistributorID__c);
					AccountAndUserIdMap.put(u.DistributorID__c,u.Id);  // here comes account Id and user id who created case
				}
				else{
					isThereValueInBodyshopOrDistributorUserField = False;
				}
			}

			if(isThereValueInBodyshopOrDistributorUserField==True) {   
				//ASE: 11/03/2016  Case C-001496
				// CODE REWORK SINCE GROUPNAME IS NOW BASED ON REFERENCE NUMBER

				//Map<String, Id> GroupNamesToUserIdsMap = New Map<String, Id>();
		
				// NEW Development: Id replaced by ReferenceNumber__c and above Id.valueof removed
				//List<Account> AccountNamesToGetGroupName = [SELECT ReferenceNumber__c, Id, Name FROM Account WHERE ReferenceNumber__c IN :AccountsIdsToGetGroupName];
				//List<String> Names = New List<String>();
				//for(Account a:AccountNamesToGetGroupName){
				//	Names.add(a.Name);
				//   GroupNamesToUserIdsMap.put(a.Name, AccountAndUserIdMap.get(a.ReferenceNumber__c)); // Account and also Group name and user id who created the case
					
					//system.debug('a.ReferenceNumber__c: '+a.ReferenceNumber__c);
					//system.debug('AccountAndUserIdMap.get(a.ReferenceNumber__c): '+AccountAndUserIdMap.get(a.ReferenceNumber__c));
				//}
		
				//List<Group> GroupsToShare = [SELECT Id, Name FROM Group WHERE Name IN :Names];
				//Map<String, Id> GroupsToShareMap = new Map<String, Id>([SELECT Name FROM Group WHERE Name IN :Names],[SELECT Id FROM Group WHERE Name IN :Names]);
		
				//Map<Id,Id> FinalMap = New Map<Id,Id>();
				//for(Group g:GroupsToShare){
				//	FinalMap.put(CaseCreatedByMap.get(GroupNamesToUserIdsMap.get(g.Name)),g.Id); //account nimi on sama kuin group nimi eli silla saandaan user id ja sen perusteella case id
				//	//system.debug('GroupNamesToUserIdsMap.get(g.Name): '+GroupNamesToUserIdsMap.get(g.Name));
				//	system.debug('g.Id: '+g.Id);
				//}

				List<Group> GroupsToShare = [SELECT Id, Name FROM Group WHERE Name IN :AccountAndUserIdMap.KeySet()];
				Map<Id,Id> FinalMap = New Map<Id,Id>();
				for(Group g:GroupsToShare){
					 //ASE: 11/03/2016  Case C-001496
					// FinalMap.put(CaseCreatedByMap.get(GroupNamesToUserIdsMap.get(g.Name)),g.Id); //account nimi on sama kuin group nimi eli silla saandaan user id ja sen perusteella case id
			
					FinalMap.put(CaseCreatedByMap.get(AccountAndUserIdMap.get(g.Name)),g.Id); 
				}

				for(Case__c c: updatedCases){
					Case__Share caseShr  = new Case__Share();
					caseShr.ParentId = c.Id;
					caseShr.UserOrGroupId = FinalMap.get(c.Id);
					//system.debug('Group id is: '+FinalMap.get(c.Id));
					caseShr.AccessLevel = 'Edit';
					caseShr.RowCause = Schema.Case__Share.RowCause.Manual;
					casesToShare.add(caseShr);
				}
			} // end if isThereValueInBodyshopOrDistributorUserField == True

			for(Case__c c: updatedCases){
				if(c.SubmittedBy__c != null){
					Case__Share caseShr  = new Case__Share();
					caseShr.ParentId = c.Id;
					caseShr.UserOrGroupId = c.SubmittedBy__c;
					caseShr.AccessLevel = 'Edit'; // was read
					caseShr.RowCause = Schema.Case__Share.RowCause.Manual;
					casesToShare.add(caseShr);
				}           
			} // for-loop ends
		
			// save manual sharing for cases 
			Database.SaveResult[] srList = Database.insert(casesToShare,false);

		
		*/
	} // onAfterUpdate ends
	
	public void OnAfterInsert(Case__c[] newCases){
	
		// add list for cases with manual sharing, IS 6.7.2015
		List<Case__Share> CasesToShare = New List<Case__Share>();

		//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
		map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();
		map<Id,list<Case__c>> mapAccIdListCase = new map<Id,list<Case__c>>();

		Map<Id, Id> CaseCreatedByMap = New Map<Id, Id>();

		for(Case__c c: newCases){
			//AMI 06/08/18 : Community Rollout 
            //             : Execute apex sharing rule only if connected user do not have a community licence 
            if(c.Tech_BSAccount__c == null){
                CaseCreatedByMap.put(c.CreatedById, c.Id); // here is user who created case id and case id
                //system.debug('c.CreatedById: '+c.CreatedById);
                //system.debug('c.Id: '+c.Id);
            }

			//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S 
			if(allConfigCountryCodeInfo != null && 
			   allConfigCountryCodeInfo.containsKey(c.CountryCode__c) && 
			   allConfigCountryCodeInfo.get(c.CountryCode__c).AdvancedCaseManagement__c && 
			   c.TECH_AutomaticCreationFromProcess__c != null &&
			   c.TECH_AutomaticCreationFromProcess__c.contains('-DeliveryProblem')){
				if(!mapAccIdListCase.containsKey(c.Account_Name__c)){
					mapAccIdListCase.put(c.Account_Name__c,new list <Case__c>{c});
				}
				else{
					mapAccIdListCase.get(c.Account_Name__c).add(c);
				}
			}
        	system.debug('## mapAccIdListCase ' + mapAccIdListCase);
		}
		
		List<User> UsersWhoCreatedCases = [SELECT Id, BodyShopID__c, DistributorID__c FROM User WHERE Id IN :CaseCreatedByMap.KeySet()];

		Map<String, Id> AccountAndUserIdMap = New Map<String, Id>();

		Boolean isThereValueInBodyshopOrDistributorUserField = True;
		List<String> AccountsIdsToGetGroupName = New List<String>();
		for(User u:UsersWhoCreatedCases){
			if(u.BodyShopID__c!=Null){
				AccountsIdsToGetGroupName.add(u.BodyShopID__c);

				AccountAndUserIdMap.put(u.BodyShopID__c,u.Id);  // here comes account Id and user d who created case
				//system.debug('u.BodyShopID__c: '+u.BodyShopID__c);
				//system.debug('u.id: '+u.id);
			}
			else if(u.DistributorID__c!=Null){
				AccountsIdsToGetGroupName.add(u.DistributorID__c);
				AccountAndUserIdMap.put(u.DistributorID__c,u.Id);  // here comes account Id and user id who created case
			}
			else{
				isThereValueInBodyshopOrDistributorUserField = False;
			}
		}

		if(isThereValueInBodyshopOrDistributorUserField==True) {  
				//ASE: 11/03/2016  Case C-001496
				// CODE REWORK SINCE GROUPNAME IS NOW BASED ON REFERENCE NUMBER      
		/*Map<String, Id> GroupNamesToUserIdsMap = New Map<String, Id>();
		
		// NEW Development: Id replaced by ReferenceNumber__c and above Id.valueof removed
		List<Account> AccountNamesToGetGroupName = [SELECT ReferenceNumber__c, Id, Name FROM Account WHERE ReferenceNumber__c IN :AccountsIdsToGetGroupName];
		List<String> Names = New List<String>();
		for(Account a:AccountNamesToGetGroupName){
			Names.add(a.Name);
			GroupNamesToUserIdsMap.put(a.Name, AccountAndUserIdMap.get(a.ReferenceNumber__c)); // Account and also Group name and user id who created the case
			//system.debug('a.Name: '+a.Name);
			//system.debug('AccountAndUserIdMap.get(a.ReferenceNumber__c): '+AccountAndUserIdMap.get(a.ReferenceNumber__c));
		}
		
		List<Group> GroupsToShare = [SELECT Id, Name FROM Group WHERE Name IN :Names];
		//Map<String, Id> GroupsToShareMap = new Map<String, Id>([SELECT Name FROM Group WHERE Name IN :Names],[SELECT Id FROM Group WHERE Name IN :Names]);
		*/
			List<Group> GroupsToShare = [SELECT Id, Name FROM Group WHERE Name IN :AccountAndUserIdMap.KeySet()];
		
			Map<Id,Id> FinalMap = New Map<Id,Id>();
			for(Group g:GroupsToShare){
				//ASE: 11/03/2016  Case C-001496
				//FinalMap.put(CaseCreatedByMap.get(GroupNamesToUserIdsMap.get(g.Name)),g.Id); //account nimi on sama kuin group nimi eli silla saandaan user id ja sen perusteella case id
				FinalMap.put(CaseCreatedByMap.get(AccountAndUserIdMap.get(g.Name)),g.Id);
			}

			for(Case__c c: newCases){
				Case__Share caseShr  = new Case__Share();
				caseShr.ParentId = c.Id;
				caseShr.UserOrGroupId = FinalMap.get(c.Id);
				//system.debug('Group id is: '+FinalMap.get(c.Id));
				caseShr.AccessLevel = 'Edit';
				caseShr.RowCause = Schema.Case__Share.RowCause.Manual;
				casesToShare.add(caseShr);
			}
		} // end if isThereValueInBodyshopOrDistributorUserField == True

		for(Case__c c: newCases){


		  if(c.SubmittedBy__c != null){
			   Case__Share caseShr  = new Case__Share();
			   caseShr.ParentId = c.Id;
			   caseShr.UserOrGroupId = c.SubmittedBy__c;
			   caseShr.AccessLevel = 'Edit'; // was read
			   caseShr.RowCause = Schema.Case__Share.RowCause.Manual;
			   casesToShare.add(caseShr);
		  }
		   
		} // for-loop ends

		//DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S 
		if(mapAccIdListCase.size() > 0){
			for(Account acc: [Select Id, ContactUser__c from Account where Id in: mapAccIdListCase.KeySet()]){
				if(mapAccIdListCase.containsKey(acc.Id)){
					for(Case__c ca : mapAccIdListCase.get(acc.Id)){
        				system.debug('## ca ' + ca);
        				//Share case with user
        				Case__Share caseShr  = new Case__Share();
						caseShr.ParentId = ca.Id;
						caseShr.UserOrGroupId = acc.ContactUser__c;
						caseShr.AccessLevel = 'edit'; // was read
						caseShr.RowCause = Schema.Case__Share.RowCause.Manual;
						casesToShare.add(caseShr);
					}
				}
			}
		}
		
		// save manual sharing for cases 
		Database.SaveResult[] srList = Database.insert(casesToShare,false);

		if(mapAccIdListCase.size() > 0 && !Test.isRunningTest()){
			for(Account acc: [Select Id, ContactUser__c from Account where Id in: mapAccIdListCase.KeySet()]){
				if(mapAccIdListCase.containsKey(acc.Id)){
					for(Case__c ca : mapAccIdListCase.get(acc.Id)){
						// Post a feed item that has an @-mention.
						ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
						ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
						ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
						ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
						messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
						mentionSegmentInput.id = acc.ContactUser__c;
						messageBodyInput.messageSegments.add(mentionSegmentInput);
						textSegmentInput.text = ' ' + ((string.isNotBlank(ca.Comment__c)) ? ca.Comment__c : System.label.CaseCreationMessage);
						messageBodyInput.messageSegments.add(textSegmentInput);
						feedItemInput.body = messageBodyInput;
						feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
						feedItemInput.subjectId = ca.Id;
        				system.debug('## feedItemInput ' + feedItemInput);
						ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
					}
				}
			}
		}

	} // onAfterInsert ends

}//end class