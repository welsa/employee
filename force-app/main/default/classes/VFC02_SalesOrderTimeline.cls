/*
----------------------------------------------------------------------
-- - Name          : VFC02_SalesOrderTimeline
-- - Author        : ABT
-- - Description   : Controller VFP02_SalesOrderTimeline
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 13-DEC-2016	ABT		1.0    Initial version
-- 25-APR-2017	DUN		1.1    case C-001904: No status after delivery
-- 04-JAN-2018	DUN		1.2    case C-002135: Agency Mode V2 (commented code for agency mode)
-- 11-OCT-2018  AMI     1.3    C-002045 - Advance case management - Display Managed Status
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC02_SalesOrderTimeline
{
	public PrerequisiteOrder__c currentSalesOrder {get; set;}
	public Map<Integer, String> mapStepTranslatedStatus {get; set;}
	public Map<String, String> mapStatusTranslatedValue {get; set;}
	public Boolean hasFailed {get; set;}
	public Integer totalNumberOfSteps
	{
		get
		{
			return (hasFailed) ? mapStatusPosition.size() : mapStatusPosition.size() - 1;
		}
	}

	public Integer salesOrderCurrentStepNumber {get; set;}

	public Decimal calculateSuccessfulLineWidth
	{
		get
		{
			return (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) * (salesOrderCurrentStepNumber - 1);
		}
	}

	public Decimal calculateFailureLineWidth
	{
		get
		{
			return (hasFailed) ? calculateSuccessfulLineWidth + (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) : 0;
		}
	}

	//AMI 11/10/2018 : C-002045 - Advance case management
	//				 : Reworked map so that Managed is added to timeline only if status is manage
	public map <string, integer> mapStatusPosition = new Map<string, integer>();
	//				 : boolean to render coloured icon
	public boolean isManaged {get;set;}

	public VFC02_SalesOrderTimeline(ApexPages.StandardController sc)
	{
		// Getting the current sales order
		currentSalesOrder 				= (PrerequisiteOrder__c) sc.getRecord();
		mapStepTranslatedStatus 		= new Map<Integer, String>();
		mapStatusTranslatedValue		= new Map<String, String>();
		salesOrderCurrentStepNumber 	= 1;
		isManaged						= false;

		if(currentSalesOrder != null)
		{	
			//AMI 11/10/2018 : C-002045 - Advance case management
			//				 : Reworked map so that Managed is added to timeline only if status is manage
			if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_MANAGED){
				isManaged = true;
				mapStatusPosition = new Map<String, Integer>{
					ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE		=> 1,
					ASPISConstants.PRE_ORDER_STATUS_RESPONDED			=> 2,
					ASPISConstants.PRE_ORDER_STATUS_INDELIVERY			=> 3,
					ASPISConstants.PRE_ORDER_STATUS_DELIVERED			=> 4,
					ASPISConstants.PRE_ORDER_STATUS_MANAGED				=> 5,
					ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED	=> 6,
					ASPISConstants.PRE_ORDER_STATUS_INVOICED			=> 7,
					ASPISConstants.PRE_ORDER_STATUS_PAID				=> 8
				};
			}else{
				mapStatusPosition = new Map<String, Integer>{
					ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE		=> 1,
					ASPISConstants.PRE_ORDER_STATUS_RESPONDED			=> 2,
					ASPISConstants.PRE_ORDER_STATUS_INDELIVERY			=> 3,
					ASPISConstants.PRE_ORDER_STATUS_DELIVERED			=> 4,
					ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED	=> 5,
					ASPISConstants.PRE_ORDER_STATUS_INVOICED			=> 6,
					ASPISConstants.PRE_ORDER_STATUS_PAID				=> 7
				};
			}

			//04/01/2018 DUN case C-002135 (commented code for agency mode)
			//if(Schema.sObjectType.Assessment__c.fields.AgencyMode__c.isAccessible() && currentSalesOrder.Assessment__r.AgencyMode__c){
			//	mapStatusPosition.remove(ASPISConstants.PRE_ORDER_STATUS_INVOICED);
			//	mapStatusPosition.remove(ASPISConstants.PRE_ORDER_STATUS_PAID);
			//}
			
			if(	currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELED ||
				currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE ||
				currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
			{
				hasFailed = true;

				if(mapStatusPosition.containsKey(currentSalesOrder.PreviousStatus__c))
				{
					salesOrderCurrentStepNumber = mapStatusPosition.get(currentSalesOrder.PreviousStatus__c);
				}
			}
			else
			{
				hasFailed = false;

				if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK)
				{
					//04/01/2018 DUN case C-002135 (commented code for agency mode)
					//if(Schema.sObjectType.PrerequisiteOrder__c.fields.AgencyMode__c.isAccessible() && currentSalesOrder.AgencyMode__c)
					//{
					//	currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
					//}
					//else
					//{
						currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
					//}
				}

				if(mapStatusPosition.containsKey(currentSalesOrder.Status__c))
				{
					salesOrderCurrentStepNumber = mapStatusPosition.get(currentSalesOrder.Status__c);
				}
			}

			populateMapStatusTranslatedValues();
		}
	}

	public void populateMapStatusTranslatedValues()
	{
		// Get the label of each status from the Schema.DescribeFieldResult
		Schema.DescribeFieldResult salesOrderStatusSchema = PrerequisiteOrder__c.Status__c.getDescribe();

		for(Schema.PicklistEntry currentPicklistEntry : salesOrderStatusSchema.getPicklistValues())
		{
			mapStatusTranslatedValue.put(currentPicklistEntry.getValue(), currentPicklistEntry.getLabel());

			if(mapStatusPosition.containsKey(currentPicklistEntry.getValue()))
			{
				mapStepTranslatedStatus.put(mapStatusPosition.get(currentPicklistEntry.getValue()),
											currentPicklistEntry.getLabel());
			}
		}
	}
}