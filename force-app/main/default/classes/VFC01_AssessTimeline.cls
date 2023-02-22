/*
----------------------------------------------------------------------
-- - Name          : VFC01_AssessTimeline
-- - Author        : ABT
-- - Description   : Controller VFP01_AssessTimeline
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 13-DEC-2016	ABT		1.0    Initial version
-- 25-APR-2017	DUN		1.1    case C-001904: No status after delivery
-- 04-JAN-2018	DUN		1.2    case C-002135: Agency Mode V2 (commented code for agency mode)
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC01_AssessTimeline
{
	public Assessment__c currentAssessment {get; set;}
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

	public Integer assessmentCurrentStepNumber {get; set;}

	public Decimal calculateSuccessfulLineWidth
	{
		get
		{
			return (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) * (assessmentCurrentStepNumber - 1);
		}
	}

	public Decimal calculateFailureLineWidth
	{
		get
		{
			return (hasFailed) ? calculateSuccessfulLineWidth + (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) : 0;
		}
	}

	public Map<String, Integer> mapStatusPosition = new Map<String, Integer>
	{
		ASPISConstants.ASSESS_STATUS_NEW		=> 1,
		ASPISConstants.ASSESS_STATUS_READY		=> 2,
		ASPISConstants.ASSESS_STATUS_CHECKED	=> 3,
		ASPISConstants.ASSESS_STATUS_SOURCED	=> 4,
		ASPISConstants.ASSESS_STATUS_OFFERING	=> 5,
		ASPISConstants.ASSESS_STATUS_INDELIVERY	=> 6,
		ASPISConstants.ASSESS_STATUS_INVOICED	=> 7,
		ASPISConstants.ASSESS_STATUS_CLOSED		=> 8
	};


	public VFC01_AssessTimeline(ApexPages.StandardController sc)
	{
		// Getting the current sales order
		currentAssessment 				= (Assessment__c) sc.getRecord();
		mapStepTranslatedStatus 		= new Map<Integer, String>();
		mapStatusTranslatedValue		= new Map<String, String>();
		assessmentCurrentStepNumber 	= 1;

		if(currentAssessment != null)
		{
			if(currentAssessment.HasBeenSubstituted__c)
			{
				mapStatusPosition.put(ASPISConstants.ASSESS_STATUS_SUBSTITUTION, 2);
				mapStatusPosition.remove(ASPISConstants.ASSESS_STATUS_READY);
			}
			//04/01/2018 DUN case C-002135 (commented code for agency mode)
			//if(Schema.sObjectType.Assessment__c.fields.AgencyMode__c.isAccessible() && currentAssessment.AgencyMode__c){
			//	mapStatusPosition.remove(ASPISConstants.ASSESS_STATUS_INVOICED);
			//	mapStatusPosition.put(ASPISConstants.ASSESS_STATUS_CLOSED, 7);
			//}

			if(	currentAssessment.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED ||
				currentAssessment.Status__c == ASPISConstants.ASSESS_STATUS_CANCELED ||
				currentAssessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDKO)
			{
				hasFailed = true;

				if(mapStatusPosition.containsKey(currentAssessment.PreviousStatus__c))
				{
					assessmentCurrentStepNumber = mapStatusPosition.get(currentAssessment.PreviousStatus__c);
				}
			}
			else
			{
				hasFailed = false;

				if(currentAssessment.Status__c == ASPISConstants.ASSESS_STATUS_CLOSEDOK)
				{
					currentAssessment.Status__c = ASPISConstants.ASSESS_STATUS_CLOSED;
				}

				if(mapStatusPosition.containsKey(currentAssessment.Status__c))
				{
					assessmentCurrentStepNumber = mapStatusPosition.get(currentAssessment.Status__c);
				}
			}

			populateMapStatusTranslatedValues();
		}
	}

	public void populateMapStatusTranslatedValues()
	{
		// Get the label of each status from the Schema.DescribeFieldResult
		Schema.DescribeFieldResult assessmentStatusSchema = Assessment__c.Status__c.getDescribe();

		for(Schema.PicklistEntry currentPicklistEntry : assessmentStatusSchema.getPicklistValues())
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