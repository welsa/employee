/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchShortTermDeletion
  -- - Author        : ABT
  -- - Description   : Batch to delete all the expired short term assessmentszzz
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 24-APR-2017	ABT		1.0    	Initial version
  ----------------------------------------------------------------------
  Execution Code:
  Database.executeBatch(new ASPISBatchShortTermDeletion(), 200);
  **********************************************************************
*/
public class ASPISBatchShortTermDeletion implements Database.Batchable<sObject>, Schedulable
{
	public void execute(SchedulableContext sc)
	{
		ASPISBatchShortTermDeletion batch = new ASPISBatchShortTermDeletion();
		Database.executeBatch(batch, 200);
	}

	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		System.debug('---------------------------------- START ASPISBatchShortTermDeletion - start ----------------------------------');
		
		DateTime now = System.now().addHours(-1);

		// [SELECT Id, (SELECT Id FROM Cases__r) FROM Assessment__c]
		String query = 	'SELECT	Id, isShoppingList__c, RecordType.DeveloperName, ' +
								'(SELECT Id, Status__c FROM PrerequisiteOrders__r), ' +
								'(SELECT Id FROM PurchaseOrders__r), ' +
								'(SELECT Id FROM Invoices__r), ' +
								'(SELECT Id FROM Cases__r), ' +
								'(SELECT Id, Status__c, RecordType.DeveloperName FROM Assessments__r) ' +
						'FROM 	Assessment__c '+
						'WHERE	ShortTermDeletionDate__c != null ' +
						'AND 	ShortTermDeletionDate__c <: now ' +
						'AND 	(RecordType.DeveloperName = \'ClaimOrder\' '+
								'OR (isShoppingList__c = true AND RecordType.DeveloperName = \'Claim\')) ';
						//'WHERE Id = \'a005800000FyWwM\'';
						//		//'Id = \'a0025000008uaDR\' or '+
						//		//'Id = \'a0025000008twa7\'  ';
		
		System.debug('---------------------------------- END ASPISBatchShortTermDeletion - start ----------------------------------');
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext bc, List<Assessment__c> scope)
	{
		System.debug('---------------------------------- START ASPISBatchShortTermDeletion - execute ----------------------------------');

		Map<Id, sObject> mapSObjectToUpdate = new Map<Id, sObject>();

		DeleteWrapper currentDeleteWrapper = new DeleteWrapper();
			
		// can only make check on the claim orders being ordered or not but not the claims as 2 inner select is impossible
		Set<Id> claimShoppingListAssessmentIdSet = new Set<Id>();

		// Loop in the assessment and make a check whether the claim orders has not been ordered
		for(Assessment__c currentAssessment : scope)
		{

			// capturing the id of shopping list assessment
			if(currentAssessment.isShoppingList__c && currentAssessment.RecordType.DeveloperName == 'Claim')
			{
				claimShoppingListAssessmentIdSet.add(currentAssessment.Id);
				continue;
			}

			// AT THIS POINT THERE IS ONLY CLAIM ORDERS UNLESS YOU HAVE MODIFIED THE QUERY

			// check if the assessment has not been ordered
			if(isClaimOrderAssessmentNotOrdered(currentAssessment))
			{
				// can be deleted
				deleteAssessment(currentAssessment, currentDeleteWrapper);
				System.debug('@@ currentAssessment can be deleted'+currentAssessment);
			}
			else
			{
				// clear the deletion date so that it does not get picked up by the batch again
				clearAssessmentDeletionDate(currentAssessment, mapSObjectToUpdate);
				System.debug('@@ currentAssessment stdd cleared'+currentAssessment);

			}
		}

		if(claimShoppingListAssessmentIdSet.size() > 0)
		{
			// needs to change the logic
			
			Map<Id, List<Assessment__c>> mapParentIdAssessmentList = new Map<Id, List<Assessment__c>>();

			for(Assessment__c currentAssessment : [	SELECT	Id, RecordType.DeveloperName, ParentAssessment__c,
															(SELECT Id, Status__c FROM PrerequisiteOrders__r),
															(SELECT Id FROM PurchaseOrders__r),
															(SELECT Id FROM Invoices__r),
															(SELECT Id FROM Cases__r)
													FROM	Assessment__c
													WHERE	ParentAssessment__c IN: claimShoppingListAssessmentIdSet])
			{
				if(!mapParentIdAssessmentList.containsKey(currentAssessment.ParentAssessment__c))
				{
					mapParentIdAssessmentList.put(currentAssessment.ParentAssessment__c, new List<Assessment__c>{currentAssessment});
				}
				else
				{
					mapParentIdAssessmentList.get(currentAssessment.ParentAssessment__c).add(currentAssessment);
				}
			}



			// Retrieving the claim assessment
			for(Assessment__c currentAssessment : [SELECT	Id, RecordType.DeveloperName,
															(SELECT Id, Status__c FROM PrerequisiteOrders__r),
															(SELECT Id FROM PurchaseOrders__r),
															(SELECT Id FROM Invoices__r),
															(SELECT Id FROM Cases__r),
															(SELECT Id, Status__c, RecordType.DeveloperName FROM Assessments__r)
												FROM		Assessment__c
												WHERE	Id IN: claimShoppingListAssessmentIdSet])
			{
				List<Assessment__c> childAssessmentList = (mapParentIdAssessmentList.containsKey(currentAssessment.Id)) ? mapParentIdAssessmentList.get(currentAssessment.Id) : new List<Assessment__c>();
				System.debug('@@loop in parent,' +currentAssessment);
				if(isClaimShoppingListNotOrdered(childAssessmentList))
				{
					system.debug('@@can be deleted,' +currentAssessment);

					// can be deleted
					deleteAssessment(currentAssessment, currentDeleteWrapper);

					for(Assessment__c currentChildAssessment : childAssessmentList)
					{
						deleteAssessment(currentChildAssessment, currentDeleteWrapper);
					}
				}
				else
				{
					system.debug('@@clear,' +currentAssessment);
					// clear the deletion date so that it does not get picked up by the batch again
					clearAssessmentDeletionDate(currentAssessment, mapSObjectToUpdate);
				}
			}
		}
		system.debug('@@ mapSObjectToUpdate:'+mapSObjectToUpdate);
		// Performing update before delete
		if(mapSObjectToUpdate.size() > 0)
		{
			update mapSObjectToUpdate.values();
		}

		currentDeleteWrapper.purgeData();

		System.debug('---------------------------------- END ASPISBatchShortTermDeletion - execute ----------------------------------');
	}

	public void finish(Database.BatchableContext bc)
	{
		System.debug('---------------------------------- START ASPISBatchShortTermDeletion - finish ----------------------------------');
		System.debug('---------------------------------- END ASPISBatchShortTermDeletion - finish ----------------------------------');
	}

	/**
	 * Function to check if the claim order assessment has been orderd or not
	 * @param  currentAssessment The current claim order assessment that needs to be checked
	 * @return                   The boolean value whether it is ordered or not
	 */
	private Boolean isClaimOrderAssessmentNotOrdered(Assessment__c currentAssessment)
	{
		Boolean isNotOrder = true;

		if(currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
		{
			for(PrerequisiteOrder__c currentSalesOrder : currentAssessment.PrerequisiteOrders__r)
			{
				if(currentSalesOrder.Status__c != 'PREACCEPTANCE')
				{
					isNotOrder = false;
				}
			}
		}
		System.debug('@@ isNotOrder:'+isNotOrder);

		return isNotOrder;
	}

	/**
	 * Function to check if the claim shopping list assessment has been orderd or not
	 * @param  childAssessmentList The child assessment of the claim shopping list
	 * @return                     The boolean value whether the claim shopping list assessment has been ordered or not
	 */
	private Boolean isClaimShoppingListNotOrdered(List<Assessment__c> childAssessmentList)
	{
		Boolean isNotOrder = true;

		// check if it has claim order that has been ordered
		for(Assessment__c childAssessment : childAssessmentList)
		{
			// check if it is a claim order
			if(childAssessment.RecordType.DeveloperName == 'ClaimOrder')
			{
				isNotOrder = isNotOrder && isClaimOrderAssessmentNotOrdered(childAssessment);
			}
		}

		return isNotOrder;
	}

	/**
	 * Function to clear the deletion date of the assessments
	 * @param  mapAssessmentToUpdate The map that needs to be populated with the assessment's deletion date cleared
	 * @param  currentAssessment     The current assessment that needs to have its deletion date cleared
	 */
	private void clearAssessmentDeletionDate(Assessment__c currentAssessment, Map<Id, sObject> mapSObjectToUpdate)
	{
		if(currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
		{
			// Add it to the map
			mapSObjectToUpdate.put(currentAssessment.Id, new Assessment__c(Id = currentAssessment.Id,
																			  ShortTermDeletionDate__c = null));
		}
		//Added by RLA
		else if(currentAssessment.RecordType.DeveloperName == 'Claim')
		{
			// Add it to the map
			mapSObjectToUpdate.put(currentAssessment.Id, new Assessment__c(Id = currentAssessment.Id,
																			  ShortTermDeletionDate__c = null));
		}
		else
		{
			// Loop in the claim assessment to add its child to be deleted
			for(Assessment__c childAssessment : currentAssessment.Assessments__r)
			{
				// clearing only crash as there could be ordered and unordered claim orders
				if(childAssessment.RecordType.DeveloperName == 'Crash')
				{
					mapSObjectToUpdate.put(childAssessment.Id, new Assessment__c(Id = childAssessment.Id,
																					ShortTermDeletionDate__c = null));
				}
			}
		}
	}

	/**
	 * Function to filter the assessment depending on its record type and delete the objects
	 * @param  currentAssessment    The assessment that needs to be check for deletion
	 * @param  currentDeleteWrapper The wrapper class containing all the records to delete
	 */
	private void deleteAssessment(Assessment__c currentAssessment, DeleteWrapper currentDeleteWrapper)
	{
		if(currentAssessment.RecordType.DeveloperName == 'ClaimOrder')
		{
			currentDeleteWrapper.populateDeleteWrapper(currentAssessment);
		}
		else
		{
			// Loop in the claim assessment to add its child to be deleted
			for(Assessment__c childAssessment : currentAssessment.Assessments__r)
			{
				if(childAssessment.RecordType.DeveloperName == 'ClaimOrder')
				{
					currentDeleteWrapper.populateDeleteWrapper(childAssessment);
				}
				else
				{
					// adding the crash to delete
					currentDeleteWrapper.populateDeleteWrapper(childAssessment);
				}
			}

			// Adding the claim shopping list to be deleted also
			currentDeleteWrapper.populateDeleteWrapper(currentAssessment);
		}
	}

	private class DeleteWrapper
	{
		private Map<Id, Assessment__c> mapAssessmentToDelete;
		private Map<Id, PrerequisiteOrder__c> mapSalesOrderToDelete;
		private Map<Id, PurchaseOrder__c> mapPurchaseOrderToDelete;
		private Map<Id, Invoice__c> mapInvoiceToDelete;
		private Map<Id, Case__c> mapCaseToDelete;

		public DeleteWrapper()
		{
			mapAssessmentToDelete		= new Map<Id, Assessment__c>();
			mapSalesOrderToDelete		= new Map<Id, PrerequisiteOrder__c>();
			mapPurchaseOrderToDelete	= new Map<Id, PurchaseOrder__c>();
			mapInvoiceToDelete			= new Map<Id, Invoice__c>();
			mapCaseToDelete				= new Map<Id, Case__c>();
		}

		/**
		 * Function to add the assessment and its child sObjects to the maps
		 * @param  currentAssessment The current assessment to delete
		 */
		public void populateDeleteWrapper(Assessment__c currentAssessment)
		{
			mapAssessmentToDelete.put(currentAssessment.Id, currentAssessment);

			for(PurchaseOrder__c currentPurchaseOrder : currentAssessment.PurchaseOrders__r)
			{
				mapPurchaseOrderToDelete.put(currentPurchaseOrder.Id, currentPurchaseOrder);
			}

			for(Invoice__c currentInvoice : currentAssessment.Invoices__r)
			{
				mapInvoiceToDelete.put(currentInvoice.Id, currentInvoice);
			}

			for(Case__c currentCase : currentAssessment.Cases__r)
			{
				mapCaseToDelete.put(currentCase.Id, currentCase);
			}

			for(PrerequisiteOrder__c currentSalesOrder : currentAssessment.PrerequisiteOrders__r)
			{
				mapSalesOrderToDelete.put(currentSalesOrder.Id, currentSalesOrder);
			}
		}

		/**
		 * Function to delete all the data in the maps
		 */
		public void purgeData()
		{
			System.debug('@@ mapSalesOrderToDelete: '+mapSalesOrderToDelete);
			System.debug('@@ mapAssessmentToDelete: '+mapAssessmentToDelete);
			System.debug('@@ mapPurchaseOrderToDelete: '+mapPurchaseOrderToDelete);
			System.debug('@@ mapInvoiceToDelete: '+mapInvoiceToDelete);
			System.debug('@@ mapCaseToDelete: '+mapCaseToDelete);
			

			if(mapSalesOrderToDelete.size() > 0)
			{
				delete mapSalesOrderToDelete.values();
			}

			if(mapAssessmentToDelete.size() > 0)
			{
				delete mapAssessmentToDelete.values();
			}

			if(mapPurchaseOrderToDelete.size() > 0)
			{
				delete mapPurchaseOrderToDelete.values();
			}

			if(mapInvoiceToDelete.size() > 0)
			{
				delete mapInvoiceToDelete.values();
			}

			if(mapCaseToDelete.size() > 0)
			{
				delete mapCaseToDelete.values();
			}
		}
	}
}