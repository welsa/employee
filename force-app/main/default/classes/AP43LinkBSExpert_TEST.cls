/*
----------------------------------------------------------------------
-- - Name          : AP43LinkBSExpert_TEST
-- - Author        : DUN
-- - Description   : Test class for AP43LinkBSExpert
--
-- Maintenance History:
--
-- Date			Name  Version  Remarks
-- -----------	----  -------  ---------------------------------------
-- 24-NOV-2017	DUN		1.0    Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class AP43LinkBSExpert_TEST {
	
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;  
    static List<PartList__c> partList;
    static List<CrossReference__c> crossReferenceList;

    static{
        
        //create userRole
        UserRole alphaUserRole = new UserRole(Name = 'FR - AlphaScale');
        insert alphaUserRole;

        //inserting users
        adminUser = TestFactory.createUser('adminUser');
        adminUser.UserRoleId = alphaUserRole.Id;
        insert adminUser;

        System.runAs(adminUser) {
            // Generating the account
            accountList = new List<Account>{
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'FR')
            };

            accountList[0].ContactUser__c = adminUser.Id;
            accountList[0].ReferenceNumber__c = 'FR2763223906';//WCH 23/12/2020 C-004120
            accountList[0].isEligibleSubstitution__c = true;
            accountList[0].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[0].SubstitutionMethod2__c = 'PROPOSED';
            accountList[1].ContactEmail__c = 'test@test.com';
            accountList[1].ReferenceNumber__c = 'FR2763223905';//WCH 23/12/2020 C-004120
            accountList[1].isEligibleSubstitution__c = true;
            accountList[0].Type = 'Standard';
            accountList[1].Type = 'Expert';
            accountList[1].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[1].SubstitutionMethod2__c = 'PROPOSED';

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c> {
                TestFactory.createAssessment('Assessment_FR', accountList[0])
            };

            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[0].Manufacturer__c           = 'MERCEDES';
            assessmentList[0].EntityCode__c             = '299';
            assessmentList[0].Status__c                 = 'NEW';
            assessmentList[0].CrossReferences__c        = 'ASCR007';
            assessmentList[0].PlateNumber2__c           = 'AK2804';
            assessmentList[0].ClaimReference__c         = '280620ddffffff67';
            assessmentList[0].AssessmentNumber__c       = (assessmentList[0].ClaimReference__c + accountList[0].ReferenceNumber__c + assessmentList[0].PlateNumber2__c).toUpperCase();
            assessmentList[0].AssessmentID__c           = 'FR' + 'Mercedes' + assessmentList[0].AssessmentNumber__c;
            assessmentList[0].RecordTypeId              = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            insert assessmentList;

            crossReferenceList = new List<CrossReference__c>{
                TestFactory.createCrossReference('FR', 'A12 38 261290', 'Mercedes', 20.0, true),
                TestFactory.createCrossReference('FR', '0A12 38261390', 'Renault',  40.0, true),
                TestFactory.createCrossReference('FR', '0A12 38261390', 'Renault',  50.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261190', 'Mercedes', 45.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261290', 'Mercedes', 30.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261890', 'Mercedes', 30.0, true)
            };

            insert crossReferenceList;

            partList = new List<PartList__c>{
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0])
            };

            partList[2].CrossReferenceId__c = crossReferenceList[0].Id;
            partList[3].CrossReferenceId__c = crossReferenceList[1].Id;
            partList[2].SelectedByBS__c = true;
            partList[3].SelectedByBS__c = true;

            insert partList; 

        }
    }

    static testmethod void testAP43ExpertForced(){
        System.runAs(adminUser){

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accountList[1]);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = 'AK2804';
            ass1.ClaimReference__c = '280620ddffffff67';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            Test.startTest();
                Insert ass1;
            Test.stopTest();

            Assessment__c assessment = [select ExpertSubstitutionMethod__c , AssessmentID__c 
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001'];
            // System.assertEquals(assessment.ExpertSubstitutionMethod__c, 'FORCED');
        }
    }

    static testmethod void testAP43ExpertProposed(){
        System.runAs(adminUser){

            accountList[1].ExpertSubstitutionMethod__c = 'PROPOSED';
            update accountList[1];

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accountList[1]);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = 'AK2804';
            ass1.ClaimReference__c = '280620ddffffff67';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            Test.startTest();
                Insert ass1;
            Test.stopTest();

            Assessment__c assessment = [select ExpertSubstitutionMethod__c , AssessmentID__c 
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001'];
            // System.assertEquals(assessment.ExpertSubstitutionMethod__c, 'PROPOSED');
        }
    }

    static testmethod void testAP43NoSubstitute(){
        System.runAs(adminUser){

            assessmentList[0].CrossReferences__c = 'NONE';
            update assessmentList[0];

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accountList[1]);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = 'AK2804';
            ass1.ClaimReference__c = '280620ddffffff67';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            Test.startTest();
                Insert ass1;
            Test.stopTest();

            Assessment__c assessment = [select ExpertSubstitutionMethod__c , AssessmentID__c 
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001'];
            // System.assertEquals(assessment.ExpertSubstitutionMethod__c, 'PROPOSED');
        }
    }

    static testmethod void testAP43isNotEligible(){
        System.runAs(adminUser){

            accountList[0].isEligibleSubstitution__c  = false;
            update accountList[0];

            assessmentList[0].CrossReferences__c = 'NONE';
            update assessmentList[0];

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', accountList[1]);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = 'AK2804';
            ass1.ClaimReference__c = '280620ddffffff67';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'FR';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            Test.startTest();
                Insert ass1;
            Test.stopTest();

            Assessment__c assessment = [select ExpertSubstitutionMethod__c , AssessmentID__c 
                                        from Assessment__c 
                                        where AssessmentID__c = 'Num001'];
            // System.assertEquals(assessment.ExpertSubstitutionMethod__c, 'PROPOSED');
        }
    }
}