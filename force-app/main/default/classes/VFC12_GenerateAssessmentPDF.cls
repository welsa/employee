/*
----------------------------------------------------------------------
-- - Name          : VFC12_GenerateAssessmentPDF
-- - Author        : ABT
-- - Description   : Controller for VFP12_GenerateAssessmentPDF
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 21-DEC-2016	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC12_GenerateAssessmentPDF 
{
	public Assessment__c currentAssessment {get; set;}
	public List<PartList__c> partList {get; set;}
	public String createdDateString {get; set;}
	// public String renderAs {get; set;}

	public VFC12_GenerateAssessmentPDF(ApexPages.StandardController sc) 
	{
		currentAssessment 	= (Assessment__c) sc.getRecord();
		// renderAs 			= ApexPages.currentPage().getParameters().get('renderAs');
		partList			= new List<PartList__c>();

		String fileName = 'Alpha Scale - ';

		if(	currentAssessment != null &&
			currentAssessment.Id != null)
		{
			// Extracting the date from created date and formatting it to the locale of the user
			// CreatedDate cannot be null
			createdDateString = currentAssessment.CreatedDate.date().format();

			partList = [SELECT	Id, PartNumber__c, Description__c, Quantity__c, Type__c, Price__c
						FROM	PartList__c
						WHERE	Assessment__c =: currentAssessment.Id];
					
			filename += currentAssessment.AssessmentNumber__c + ' - ' + currentAssessment.PlateNumber2__c;
		}
		
		// Setting the filename to the pdf so as when saving it has the correct name
		Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
	}
}