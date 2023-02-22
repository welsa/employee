/*************************************************************************************
Class Name - AP11ShareInvoices
Version - 1.0
Created Date - 21 AUG 2015
Function - class to generate sharing when invoice is created

Modification Log :
-----------------------------------------------------------------------------
* Developer  		Date       	Description
* ---------- 		----------  -----------------------
* Brayan Nunhuck    21/08/2015 	Original Version 
* Shamina M     	16/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S     	09/03/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
*************************************************************************************/
public with sharing class AP11ShareInvoices {
// ABT 04-MAY-2016 - Commented due to no usage of the class and also same process is done by the standard sharing rules
/*
	public static void shareInvoice(list<Invoice__c> newInvoicesList,set<Id> BSNDisIdsSet){
		//set of name of distributor and bodyshop
		set<String> nameAccountSet = new set<String>();
		// map of group Name and group
		map<String,Group> groupMap = new map<String,Group>();
		//map Account
		map<Id,Account> accountMap = new map<Id,Account>();
		//list invoice share to insert
		list<Invoice__Share> invShareListToInsert = new list<Invoice__Share>();

		//system.debug('////// BSNDisIdsSet: ' + BSNDisIdsSet.size());
		//ASE: 09/03/2016:  Case C-001496
		for(Account a : [Select Id,ReferenceNumber__c from Account where Id in:BSNDisIdsSet]){
			//nameAccountSet.add(a.Name);
			nameAccountSet.add(a.ReferenceNumber__c);
			accountMap.put(a.Id,a);
		}
		//system.debug('////// nameAccountSet: ' + nameAccountSet.size());
		//system.debug('////// accountMap: ' + accountMap.size());

		for(Group g : [SELECT DeveloperName,Id,Name,Type 
			           FROM Group 
			           WHERE Name in:nameAccountSet 
			           AND Type='Regular'])
		{
			groupMap.put(g.Name, g);
		}
		//system.debug('////// groupMap: ' + groupMap.size());

		for(Invoice__c inv : newInvoicesList){
			if(inv.BodyShop__c != null){
				//system.debug('////// inv.BodyShop__c != null');
				if(accountMap.containsKey(inv.BodyShop__c)){
					//system.debug('////// accountMap.containsKey(inv.BodyShop__c)');

					Account bodyShop = accountMap.get(inv.BodyShop__c);

					if(bodyShop != null){
						//ASE: 09/03/2016:  Case C-001496
						//if(groupMap.containsKey(bodyShop.Name)){
							if(groupMap.containsKey(bodyShop.ReferenceNumber__c)){
							//ASE: 09/03/2016:  Case C-001496
							//Group g = groupMap.get(bodyShop.Name);
							Group g = groupMap.get(bodyShop.ReferenceNumber__c);
							Invoice__Share ins = createSharing(g,inv);

							if(ins != null){
								invShareListToInsert.add(ins);
							}
						}
					}
				}
			}

			if(inv.Distributor__c != null){
				//system.debug('////// inv.Distributor__c != null');
				if(accountMap.containsKey(inv.Distributor__c)){
					//system.debug('////// accountMap.containsKey(inv.Distributor__c)');
					Account distributor = accountMap.get(inv.Distributor__c);

					if(distributor != null){
						//system.debug('////// distributor != null');
						//ASE: 09/03/2016:  Case C-001496
						//if(groupMap.containsKey(distributor.Name)){
						if(groupMap.containsKey(distributor.ReferenceNumber__c)){
							//system.debug('////// groupMap.containsKey(distributor.Name)');
							//ASE: 09/03/2016:  Case C-001496
							//Group g = groupMap.get(distributor.Name);
							Group g = groupMap.get(distributor.ReferenceNumber__c);
							Invoice__Share ins = createSharing(g,inv);

							if(ins != null){
								invShareListToInsert.add(ins);
							}
						}
					}
				}
			}
		}

		//system.debug('////// invShareListToInsert.size(): ' + invShareListToInsert.size());
		if(invShareListToInsert.size()>0){
			insert invShareListToInsert;
		}

	}

	public static Invoice__Share createSharing(Group g, Invoice__c i){
		Invoice__Share invShare = null;
		//SELECT AccessLevel,ParentId,RowCause,UserOrGroupId FROM Invoice__Share
		if(g != null && i != null){
			invShare = new Invoice__Share(AccessLevel = 'Read' , ParentId = i.Id, RowCause = Schema.Invoice__Share.RowCause.Manual , UserOrGroupId = g.Id);
		}
		return invShare;
	}*/
}