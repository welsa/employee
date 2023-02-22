/*
  ----------------------------------------------------------------------
  -- - Name          : RESTUpsertAssessmentV2_TEST 
  -- - Author        : RLA 
  -- - Description   : Test class for WS RESTUpsertAssessment
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-Feb-2018  RLA    1.0     Initial Version
  -- 15-OCT-2018  WCH    1.1     C-002754: add TECHDistList__c field
  -- 23-DEC-2020  WCH    1.2     C-004120 - Format du Reference Number
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class RESTUpsertAssessmentV2_TEST {

    static User adminUser;
    static User adminUserNevada;
    static User user2;
    static User user3;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PartList__c> partList;
    static List<CrossReference__c> crossReferenceList;
    static BusinessHours defaultHours;


    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;

    //static List<CarMapping__c> carMappingList;
    static List<CarMappings__mdt> carMappingList;
    static List<AccountRef__c> accountRefList;

    static CrossReference__c cr;
    static list <DirectOrder__c> directOrderList;
    static CountryCodeInformationsMapping__c cs;



    static{
        directOrderList = new list <DirectOrder__c>();
        cs = new  CountryCodeInformationsMapping__c();
        
        //create userRole
        UserRole alphaUserRole = new UserRole(Name = 'FR - AlphaScale');
        insert alphaUserRole;
        UserRole alphaUserRoleES = new UserRole(Name = 'BE - AlphaScale');
        insert alphaUserRoleES;

        UserRole alphaUserRoleDE = new UserRole(Name = 'DE - AlphaScale');
        insert alphaUserRoleDE;

        //inserting users
        adminUser = TestFactory.createUser('adminUser');
        adminUser.UserRoleId = alphaUserRole.Id;
       
        insert adminUser;

        //inserting users
        adminUserNevada = TestFactory.createUser('adminUser');
        adminUserNevada.UserRoleId = alphaUserRole.Id;
        adminUserNevada.CreateToUpsert__c = true;
        adminUserNevada.callersystem__c = 'FR_NEVADA';       
        insert adminUserNevada;


        User user2 = TestFactory.createUser('CATALOG');
        user2.LastName = 'CATALOG';
        user2.FirstName ='';
        user2.UserRoleId = alphaUserRoleES.Id;
        insert user2;

        user3 = TestFactory.createUser('adminUser');
        user3.LastName = 'CATALOG';
        user3.FirstName ='';
        user3.UserRoleId = alphaUserRoleDE.Id;
        insert user3;

        System.runAs(adminUser) {
            ASPISTools.bypassTrigger = ';DetailRuleTrigger;MasterRuleTrigger;';

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
			Log__c logFake = new log__c(JSONMessage__c = 'sdfds;iuteer');
            insert logFake;
            cs = TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.id);
            // cs.bodyshopOrderNumber__c = true;
            cs.CountryVAT__c = 1;
            cs.LogsForFakeReferences__c = logFake.Name;
            cs.CallerSystemForManualPartsSubs__c = 'DIVA';
            cs.CallerSystemForAPrefix__c = 'DIVA';
            
            insert cs;
            system.debug('@@ cs'+cs);

            // Generating the account
            accountList = new List<Account>{
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_3', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_Std', 'BE'),
                TestFactory.createAccountBodyshop('BodyShop_Exp', 'BE'),
                TestFactory.createAccountBodyshop('BodyShop_Std', 'DE'),
                TestFactory.createAccountDistributor('COLER', 'DE'),
                TestFactory.createAccountDistributor('NORA', 'DE')               
            };

            accountList[0].ContactUser__c = adminUser.Id;
            accountList[0].type  = 'Expert';            
            //accountList[0].ReferenceNumber__c = '2763223906'; //WCH 23/12/2020 C-004120
            accountList[0].isEligibleSubstitution__c = true;
            accountList[0].SubstitutionMethod2__c='PROPOSED';
            accountList[0].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[1].ContactEmail__c = 'test@test.com';
            accountList[1].type = 'Standard';
            //accountList[1].ReferenceNumber__c = '2763223905'; //WCH 23/12/2020 C-004120
            accountList[1].isEligibleSubstitution__c = true;
            accountList[1].Feature__c = 'PilotDirectSourcing';
            accountList[1].ExpertSubstitutionMethod__c = 'FORCED';
            //accountList[2].ReferenceNumber__c = '2763223907'; //WCH 23/12/2020 C-004120
            accountList[2].isEligibleSubstitution__c = true;
            accountList[2].type = 'Standard';
            accountList[2].AXAPartner__c = true;
            accountList[2].AXA_Partner__c = true;
            accountList[2].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[6].ReferenceNumber__c = '404483367';
            accountList[6].isEligibleSubstitution__c = true;
            accountList[6].type = 'Standard';
            accountList[6].AXAPartner__c = true;
            accountList[6].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[7].ReferenceNumber__c = '18690';
            accountList[7].isEligibleSubstitution__c = true;
            accountList[7].type = 'Expert';
            accountList[7].AXAPartner__c = true;
            accountList[7].ExpertSubstitutionMethod__c = 'FORCED';

            accountList[8].ReferenceNumber__c = 'IG123';
            accountList[8].isEligibleSubstitution__c = true;
            accountList[8].type = 'Standard';
            accountList[8].AXAPartner__c = true;
            accountList[8].ExpertSubstitutionMethod__c = 'FORCED';
            accountList[8].Feature__c = 'PilotDirectSourcing';
            accountList[8].ShippingPostalCode = '12012';
            accountList[8].DistributorConnected__c = true;

            accountList[9].ReferenceNumber__c = 'DE1234!!';
            accountList[9].Tech_Distributor__c = 'COLER';
            accountList[9].Type_of_Substitutes__c = 'Connected Substitute;Connected OEM;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            accountList[9].Rebate__c = 5;
            accountList[9].DistributorConnected__c = true;
            accountList[9].ConnectedEndtoEnd__c = true;
            accountList[9].Tech_ATConfirmed__c = 'Available';
            accountList[9].Tech_ATConfirmedWithDelay__c = 'Available';
            accountList[9].Tech_ATPartial__c = 'Unavailable';
            accountList[9].Tech_ATNotFound__c = 'Unavailable';
            accountList[9].Tech_ATOther__c = 'Unavailable';
            accountList[9].ShippingCountryCode = 'DE';

            accountList[9].PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48_48}';

            accountList[10].ReferenceNumber__c = 'DE1234';
            accountList[10].Tech_Distributor__c = 'NORA';
            accountList[10].Type_of_Substitutes__c = 'Connected Substitute;Connected OEM;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            accountList[10].Rebate__c = 5;
            accountList[10].DistributorConnected__c = true;
            accountList[10].ConnectedEndtoEnd__c = true;
            accountList[10].Tech_ATConfirmed__c = 'Available';
            accountList[10].Tech_ATConfirmedWithDelay__c = 'Available';
            accountList[10].Tech_ATPartial__c = 'Unavailable';
            accountList[10].Tech_ATNotFound__c = 'Unavailable';
            accountList[10].Tech_ATOther__c = 'Unavailable';

            accountList[10].PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24_48;C:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48_48}';
               
           
            system.debug('accountList@@'+accountList);
            insert accountList;

            /*carMappingList = new List<CarMappings__mdt>();
            carMappingList.addAll(TestFactory.createCarMappingList('GTMOTIVE'));
            carMappingList.addAll(TestFactory.createCarMappingList('DIVA'));

            insert carMappingList;*/

            //CarMappings__mdt carMapMdt = [Select D]
            
            accountRefList = new List<AccountRef__c>{
                //TestFactory.createAccountRef('2763223904', accountList[0].Id, 'GTMOTIVE'),
                TestFactory.createAccountRef('2763223905', accountList[1].Id, 'DIVA'),
                TestFactory.createAccountRef('2763223906', accountList[0].Id, 'DIVA'),
                TestFactory.createAccountRef('2763223907', accountList[2].Id, 'DIVA'),
                TestFactory.createAccountRef('2763223904', accountList[2].Id, 'FR_DIVA'),
                TestFactory.createAccountRef('404483367', accountList[6].Id, 'BE_INFORMEX'),
                TestFactory.createAccountRef('18690', accountList[7].Id, 'BE_INFORMEX'),
                TestFactory.createAccountRef('IG123', accountList[8].Id, 'DE_IG')

            };

            insert accountRefList;

            // Generating the assessments
            assessmentList = new List<Assessment__c> {
                TestFactory.createAssessment('Assessment_FR', accountList[0])
            };

            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[0].Manufacturer__c           = 'MERCEDES';
            assessmentList[0].EntityCode__c             = '299';
            assessmentList[0].Status__c                 = 'SUBSTITUTION';
            assessmentList[0].crashCode__c              = 0;
            assessmentList[0].PlateNumber2__c           = 'AK2804';
            assessmentList[0].ClaimReference__c         = '28062006';
            assessmentList[0].AssessmentNumber__c       = (assessmentList[0].ClaimReference__c + accountList[0].ReferenceNumber__c + assessmentList[0].PlateNumber2__c).toUpperCase();
            assessmentList[0].AssessmentID__c           = 'FR' + accountRefList[0].Name.substringAfter('-') + 'Mercedes' + assessmentList[0].AssessmentNumber__c;

            insert assessmentList;

            partList = new List<PartList__c>{
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0])
            };
            insert partList;

            crossReferenceList = new List<CrossReference__c>{
                TestFactory.createCrossReference('FR', 'A12 38 261290', 'Mercedes', 20.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261290', 'Mercedes', 20.0, true),
                TestFactory.createCrossReference('FR', '0A12 38261390', 'Mercedes',  40.0, true),
                TestFactory.createCrossReference('FR', '0A12 38261390', 'Renault',  50.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261190', 'Mercedes', 45.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261290', 'Mercedes', 30.0, true),
                TestFactory.createCrossReference('FR', 'A12 38 261890', 'Mercedes', 30.0, true),
                TestFactory.createCrossReference('FR', 'A12'+'/'+'38 261290', 'Mercedes', 20.0, true)

            };
            crossReferenceList[0].IAMPublicPrice__c = 20.0;
            crossReferenceList[1].IAMPublicPrice__c = 40.0;
            crossReferenceList[2].IAMPublicPrice__c = 50.0;
            crossReferenceList[3].IAMPublicPrice__c = 45.0;
            crossReferenceList[4].IAMPublicPrice__c = 30.0;
            crossReferenceList[0].OEMStandardDiscount__c = 2 ;
            crossReferenceList[0].OEMStandardMargin__c = 12.2;
            crossReferenceList[0].IAMPartClass__c = 'E';
            crossReferenceList[0].OEMPartDescription__c = 'test';
            crossReferenceList[0].IAMManufacturer__c = 'Opisto';
            

            crossReferenceList[1].OEMStandardDiscount__c = 2;
            crossReferenceList[1].OEMStandardMargin__c = 12;
            crossReferenceList[1].OEMPartDescription__c = 'test';
            crossReferenceList[1].IAMPartClass__c = 'E';
            crossReferenceList[1].IAMManufacturer__c = 'Opisto';



            crossReferenceList[2].OEMStandardDiscount__c = 2;
            crossReferenceList[2].OEMStandardMargin__c = 12;
            crossReferenceList[2].OEMPartDescription__c = 'test';
            crossReferenceList[2].IAMPartClass__c = 'B';


            crossReferenceList[3].OEMStandardDiscount__c = 2;
            crossReferenceList[3].OEMStandardMargin__c = 12;
            crossReferenceList[3].OEMPartDescription__c = 'test';
            crossReferenceList[3].IAMPartClass__c = 'B';


            crossReferenceList[4].OEMStandardDiscount__c = 2;
            crossReferenceList[4].OEMStandardMargin__c = 12;
            crossReferenceList[4].OEMPartDescription__c = 'test';
            crossReferenceList[4].IAMPartClass__c = 'C';

            crossReferenceList[1].OEMStandardDiscount__c = 1;
            crossReferenceList[1].OEMStandardMargin__c = 15;
            crossReferenceList[1].OEMPartDescription__c = 'test';
            crossReferenceList[1].IAMPartClass__c = 'T';
            crossReferenceList[1].IAMManufacturer__c = 'Opisto';



            insert crossReferenceList; 
            List<CrossReference__c> updatedCRList = new List<CrossReference__c>();
            crossReferenceList[0].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[0]);
            crossReferenceList[1].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[1]);
            crossReferenceList[2].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[2]);
            crossReferenceList[3].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[3]);
            crossReferenceList[4].ActiveForSubstitution__c = true;
            updatedCRList.add(crossReferenceList[4]);
            update updatedCRList;

            cr = [Select IAMManufacturer__c, IAMPartNumber__c, Name from CrossReference__c where  OEMPartNumber__c = 'A12 38 261190'];


            masterRuleList = new List<MasterRules__c> {
                TestFactory.createMasterRule('FR299', 'SUBSTITUTION', 'CrossReference__c')
            };

            masterRuleList[0].ConditionLogic__c = '2';
            masterRuleList[0].ValidationLogic__c = '(((7 OR 9) AND 12) OR (10 AND 11 AND (13)))';
            masterRuleList[0].Xref_Criterias_Logic__c = '((17 AND 19) OR 18)';
            masterRuleList[0].Priority_Queue_Logic__c = '26 AND 27 AND 28';
            
            
            MasterRules__c mr1 = TestFactory.createMasterRule('FR299', 'ELIGIBILITY', 'Assessment__c');
            mr1.FilterLogic__c = '(1)';
            masterRuleList.add(mr1);

            MasterRules__c mr2 = TestFactory.createMasterRule('FR299', 'Sourcing', 'Assessment__c');
            mr2.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            masterRuleList.add(mr2);

            MasterRules__c mr3 = TestFactory.createMasterRule('DEIG', 'ELIGIBILITY', 'Assessment__c');
            mr3.FilterLogic__c = '(1)';
            masterRuleList.add(mr3);
            
            insert masterRuleList;

            detailRuleList = new List<DetailRule__c> {
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'OEMCleanPartNumber__c-OEMManufacturer__c', null, null, 'Key Field', 'CrossReference__c', 1),

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'ASPublicPrice__c', 'Min', null, 'Criteria', 'CrossReference__c', 2),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'RecommendedByAS__c', 'Equals', 'TRUE', 'Update Field', 'PartList__c', 3),

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Name, (Select id, DistributorID__c,TechDistributorConnected__c from Distributors__r where Active__c = true and isDeleted__c= false limit 1), OEMCleanPartNumber__c, OEMPartNumber__c, OEMManufacturer__c, IAMPublicPrice__c, ActiveForSubstitution__c, IAMManufacturer__c, IAMPartClass__c, IAMPartDescription__c, IAMPartNumber__c, ASPublicPrice__c,IAMCertifyingOrganization__c, ASNetPrice__c,OEMStandardDiscount__c,OEMStandardMargin__c,OEMPartDescription__c,Price_to_Compare__c', null, null, 'Primary Fields Needed', 'CrossReference__c', 4),

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'SelectedByBS__c', 'EQUALS', 'TRUE', 'Update Field', 'PartList__c', 6),//

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Assessment__r.BodyShop__r.Type', 'NOT_EQUALS', 'Expert', 'Validation', 'PartList__c', 7),

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'ASPublicPrice__c', 'NOT_EQUALS', '0', 'Filter Condition', 'CrossReference__c', 8),//

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Assessment__r.ExpertSubstitutionMethod__c', 'EQUALS', 'FORCED', 'Validation', 'PartList__c', 9),//

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Assessment__r.BodyShop__r.Type', 'EQUALS', 'Expert', 'Validation', 'PartList__c', 10),//

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'Assessment__r.ExpertSubstitutionMethod__c', 'EQUALS', 'PROPOSED', 'Validation', 'PartList__c', 11),//

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'PartNumber__c', 'LIKE', 'ASCR%', 'Validation', 'PartList__c', 12),

                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'NOT PartNumber__c', 'LIKE', 'ASCR%', 'Validation', 'PartList__c', 13),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'Not Equals', 'B', 'Xref Criterias', 'CrossReference__c', 17),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'Not Equals', 'B', 'Xref Criterias', 'CrossReference__c', 18),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'ActiveforSubDistributorPrices__c', 'Greater', '0', 'Xref Criterias', 'CrossReference__c', 19),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'Not Equals', 'A', 'Xref Criterias', 'CrossReference__c', 20),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'PRIORITY', 'E=2', 'Priority Part Type', 'CrossReference__c', 26),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'PRIORITY', 'A=2', 'Priority Part Type', 'CrossReference__c', 27),
                TestFactory.createDetailRule('SUBSTITUTION', masterRuleList[0], 'IAMPartClass__c', 'PRIORITY', 'B=1', 'Priority Part Type', 'CrossReference__c', 28)
            };
             DetailRule__c dr0 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'EntityCode__c', 'EQUALS', '299', 'Filter Condition', 'Assessment__c', 1);
            detailRuleList.add(dr0);
            
            DetailRule__c dr1 = TestFactory.createDetailRule('Sourcing', masterRuleList[2], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1);
            dr1.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Sourcing', masterRuleList[2], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2);
            dr2.ValueFrom__c = 'Criteria sObject';
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Sourcing', masterRuleList[2], 'Categories__c', 'IN', 'PartTypes__c', 'Filter Condition', 'Account', 3);
            dr3.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Sourcing', masterRuleList[2], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4);
            dr4.ValueFrom__c = 'Master sObject';
            detailRuleList.add(dr4);

            DetailRule__c dr5 = TestFactory.createDetailRule('Eligibility', masterRuleList[3], 'VINNumber__c', 'Not Equals', '0', 'Filter Condition', 'Assessment__c', 1);
            detailRuleList.add(dr5);

           
            
            insert detailRuleList;

            DirectOrder__c dO1 = TestFactory.createDirectOrder(null, accountList[3].Id);
            dO1.State__c = '01;02;03;04;04;05;06;07';
            dO1.Part_Type__c = 'A';
            dO1.Priority__c = 'P0';
            dO1.Agency_mode__c = true;
            dO1.Active__c = true;
            dO1.Country__c = 'FR';
            dO1.Type__c = 'General';
            dO1.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO1);

            DirectOrder__c dO2 = TestFactory.createDirectOrder(accountList[0].Id, accountList[3].Id);
            dO2.State__c = '01;02;03;04;04;05;06;07';
            dO2.Part_Type__c = 'A';
            dO2.Priority__c = 'P0';
            dO2.Agency_mode__c = true;
            dO2.Active__c = true;
            dO2.Country__c = 'FR';
            dO2.Type__c = 'Exception';
            dO2.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO2.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO2);
            
            DirectOrder__c dO3 = TestFactory.createDirectOrder(accountList[1].Id, accountList[4].Id);
            dO3.State__c = '01;02;03;04;04;05;06;07';
            dO3.Part_Type__c = 'A;B';
            dO3.Priority__c = 'P0';
            dO3.Agency_mode__c = true;
            dO3.Active__c = true;
            dO3.Country__c = 'FR';
            dO3.Type__c = 'Exception';
            dO3.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO3.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO3);  

            DirectOrder__c dO4 = TestFactory.createDirectOrder(null, accountList[5].Id);
            dO4.State__c = '01;02;03;04;04;05;06;07';
            dO4.Part_Type__c = 'A;B';
            dO4.Priority__c = 'P0';
            dO4.Agency_mode__c = true;
            dO4.Active__c = true;
            dO4.Country__c = 'FR';
            dO4.Type__c = 'General';
            dO4.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO4.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO4);       

            DirectOrder__c dO5 = TestFactory.createDirectOrder(null, accountList[4].Id);  
            dO5.State__c = '01;02;03;04;04;05;06;07';
            dO5.Part_Type__c = 'A;B;C';
            dO5.Priority__c = 'P0';
            dO5.Agency_mode__c = true;
            dO5.Active__c = true;
            dO5.Country__c = 'FR';
            dO5.Type__c = 'General';
            dO5.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO5.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO5);

            DirectOrder__c dO6 = TestFactory.createDirectOrder(accountList[0].Id, accountList[4].Id);
            dO6.State__c = '01;02;03;04;04;05;06;07';
            dO6.Part_Type__c = 'A';
            dO6.Priority__c = 'P1';
            dO6.Agency_mode__c = true;
            dO6.Active__c = true;
            dO6.Country__c = 'FR';
            dO6.Type__c = 'Exception';
            dO6.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO6.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO6);

            DirectOrder__c dO7 = TestFactory.createDirectOrder(accountList[8].Id, accountList[9].Id);
            dO7.State__c = '12';
            dO7.Part_Type__c = 'A;B;C';
            dO7.Priority__c = 'P0';
            dO7.Agency_mode__c = false;
            dO7.Active__c = true;
            dO7.Country__c = 'DE';
            dO7.Type__c = 'Exception';
            dO7.Brands__c = 'PEUGEOT;AUDI;NISSAN;Mercedes;M1;';
            dO7.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO7);

            DirectOrder__c dO8 = TestFactory.createDirectOrder(accountList[8].Id, accountList[10].Id);
            dO8.State__c = '12';
            dO8.Part_Type__c = 'A;B;C';
            dO8.Priority__c = 'P1';
            dO8.Agency_mode__c = false;
            dO8.Active__c = true;
            dO8.Country__c = 'DE';
            dO8.Type__c = 'Exception';
            dO8.Brands__c = 'PEUGEOT;AUDI;NISSAN;Mercedes;M1;';
            dO8.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO8);

            //DirectOrder__c dO7 = TestFactory.createDirectOrder(accountList[0].Id, accountList[4].Id);
            //dO7.State__c = '01;02;03;04;04;05;06;07;null';
            //dO7.Part_Type__c = 'A';
            //dO7.Priority__c = 'P2';
            //dO7.Agency_mode__c = true;
            //dO7.Active__c = true;
            //dO7.Country__c = 'FR';
            //dO7.Type__c = 'Exception';
            //dO7.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            //dO7.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            ////directOrderList.add(dO7);
            system.debug('@@2 directOrderList'+directOrderList);
            insert directOrderList;
            system.debug('@@3 directOrderList'+directOrderList);


           
        }
    }
    
    @isTest static void upsertAssessmentException_TEST(){
        System.runAs(adminUser) {
            System.debug('## assessSubstituteListMap upsertAssessmentException_TEST');

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"3","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"2064156","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"2","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261390","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"2064157","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

    @isTest static void upsertAssessmentExtIdException_TEST(){
        System.runAs(adminUser) {

            System.debug('## assessSubstituteListMap upsertAssessmentExtIdException_TEST');

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"3","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"2064156","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"2","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261390","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"2064157","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('ErrorMessage'));
        }
    }

     @isTest static void noAccountReferenceMappingFound_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap noAccountReferenceMappingFound_TEST');
            

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906745"},"currentClaim":{"ClaimReference":"281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('No Account Reference Mapping found'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE '28128627632239063220ZY09%'];

            //System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void upsertAssessmentMissingFieldAssessment_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentMissingFieldAssessment_TEST');


            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);

           //System.assertEquals(true, jsonResponseString.contains('currentAsset.Brand'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                          WHERE AssessmentNumber__c LIKE '28128627632239063220ZY09%'];
 
            //System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void upsertAssessmentMissingFieldAssessmentExtId_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentMissingFieldAssessmentExtId_TEST');


            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","Price":58,"Manufacturer":"BOSH","InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","FirstRegistrationDate":"2015-04-13","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"ASH","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","Price":58,"Manufacturer":"BOSH","InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"ASH","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"AssessmentNumber":"","BSInternalRef":"ext1","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"Parts":[{"PartNumber":"A1238261290","Manufacturer":"BOSH","InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","FirstRegistrationDate":"2015-04-13","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"AssessmentNumber":"XXXXX","BSInternalRef":"ext1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Model":"PRIUS T4","FirstRegistrationDate":"2015-04-13","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{},"currentClaim":{"CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}]},{"callerSystem":"DIVA","AssessmentNumber":"YYYYY","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0},{"callerSystem":"DIVA","AssessmentNumber":"YYYYY","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}]}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);

           //System.assertEquals(true, jsonResponseString.contains('currentAsset.Brand'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                          WHERE AssessmentNumber__c LIKE '28128627632239063220ZY09%'];
 
            //System.assertEquals(0, assessmentCreatedList.size());
        }
    }

    @isTest static void upsertAssessmentWithUpsertError_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentWithUpsertError_TEST');


            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') +'"},"currentClaim":{"ClaimReference":"281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"0","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') +'"},"currentClaim":{"ClaimReference":"281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"6","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[0].Name.substringAfter('-') +'"},"currentClaim":{"ClaimReference":"281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('Exceptions:'));
        }
    }

    @isTest static void upsertAssessmentWithCatchError_TEST()
    {
        System.runAs(adminUser)
        {
            System.debug('## assessSubstituteListMap upsertAssessmentWithCatchError_TEST');

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":"0","Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"' + accountRefList[1].Name.substringAfter('-') +'"},"currentClaim":{"ClaimReference":"281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();

            //System.assertEquals(true, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                          WHERE AssessmentNumber__c LIKE '28128627632239063220ZY09%'];
 
            //System.assertEquals(0, assessmentCreatedList.size());
        }
    }
    @isTest static void upsertAssessmentNew_TEST()    {
        System.runAs(adminUser){
            
            System.debug('## assessSubstituteListMap upsertAssessmentNew_TEST');

            String requestJSONString ='[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":2,"InterventionCode":"A01","Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR"},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentNewzzdIVA_TEST()    {
        System.runAs(adminUser){
            
            System.debug('## assessSubstituteListMap upsertAssessmentNew_TEST');

            String requestJSONString ='[{"callerSystem":"ZZ_DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"ZZ_DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Directive","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"ASH-281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentNewNevada_TEST()    {
        System.runAs(adminUser){

            System.debug('## assessSubstituteListMap upsertAssessmentNewNevada_TEST');

            String requestJSONString ='[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"ASH-281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentNewExtId_TEST()    {
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentNewExtId_TEST');

            
            String requestJSONString ='[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"FR_ICE","AssessmentNumber":"","Compensated":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":false,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }
    
    @isTest static void upsertAssessmentNewExtIdCallout_TEST()    {
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentNewExtIdCallout_TEST');

            
            String requestJSONString ='[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"3","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"2064156","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}},{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"2","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE","PartNumber":"A1238261390","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"M1","Model":"PRIUS T4","PlateNumber":"245CZE","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"2064157","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    
    @isTest static void upsertAssessmentUpdate_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentUpdate_TEST');

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment(); 

            Blob jsonBlob2          = RestContext.response.responseBody;


            String jsonResponseString2  =  jsonBlob2.toString();
            system.debug('## jsonResponseString2:'+jsonResponseString2);
            
            
            String requestJSONString2 ='[{"callerSystem":"DIVA","AssessmentNumber":"ASH-228128627632239063220ZY09","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"ASCR-XXXXXX","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request2        = new RestRequest();
            request2.httpMethod         = 'POST';
            request2.requestURI         = '/v2.0/upsertAssessment/*';
            request2.requestBody        = Blob.valueOf(requestJSONString2);

            RestContext.request         = request2;
            RestContext.response        = new RestResponse();
            

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();              
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

           //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            system.debug('## jsonResponseString: '+jsonResponseString);

            //System.assertEquals(true, jsonResponseString.contains('not contain substitutes: '));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 
            
            list<PartList__c> plList = [Select id, Name, Alpha_Scale_MRID__c, PartNumber__c from PartList__c where isDeleted__c = true and Assessment__c =: assessmentCreatedList[0].Id];
            system.debug('## plList:'+plList);
            //System.assertEquals(4, plList.size()); 
            
        }
    }

     @isTest static void upsertAssessmentUpdateExtId_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentUpdateExtId_TEST');

            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment(); 

            Blob jsonBlob2          = RestContext.response.responseBody;


            String jsonResponseString2  =  jsonBlob2.toString();
            system.debug('## jsonResponseString2:'+jsonResponseString2);
            
            
            String requestJSONString2 ='[{"callerSystem":"DIVA","AssessmentNumber":"ASH-228128627632239063220ZY09","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"ASCR-XXXXXX","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';
            RestRequest request2        = new RestRequest();
            request2.httpMethod         = 'POST';
            request2.requestURI         = '/v2.0/upsertAssessment/*';
            request2.requestBody        = Blob.valueOf(requestJSONString2);

            RestContext.request         = request2;
            RestContext.response        = new RestResponse();
            

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();              
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

           //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            system.debug('## jsonResponseString: '+jsonResponseString);

            //System.assertEquals(true, jsonResponseString.contains('not contain substitutes: '));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 
            
           // list<PartList__c> plList = [Select id, Name, Alpha_Scale_MRID__c, PartNumber__c from PartList__c where isDeleted__c = true and Assessment__c =: assessmentCreatedList[0].Id];
            //system.debug('## plList:'+plList);
            //System.assertEquals(4, plList.size()); 
            
        }
    }

    @isTest static void upsertAssessmentUpdateShip_TEST(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentUpdateShip_TEST');
            String requestJSONString    = '[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment(); 

            Blob jsonBlob2          = RestContext.response.responseBody;


            String jsonResponseString2  =  jsonBlob2.toString();
            
            
            String requestJSONString2 ='[{"callerSystem":"DIVA","AssessmentNumber":"ASH-228128627632239063220ZY09","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"isShoppingList":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"ASCR-XXXXXX","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"ASH-2281286","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200}}]';
            RestRequest request2        = new RestRequest();
            request2.httpMethod         = 'POST';
            request2.requestURI         = '/v2.0/upsertAssessment/*';
            request2.requestBody        = Blob.valueOf(requestJSONString2);

            RestContext.request         = request2;
            RestContext.response        = new RestResponse();
            

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();              
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;

            //System.assertNotEquals(null, jsonBlob);

            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString: '+jsonResponseString);

            //System.assertEquals(true, jsonResponseString.contains('not contain substitutes: '));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                        //  WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'
                                                         ];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 
            
            list<PartList__c> plList = [Select id, Name, Alpha_Scale_MRID__c, PartNumber__c from PartList__c where isDeleted__c = true and Assessment__c =: assessmentCreatedList[0].Id];
            system.debug('## plList:'+plList);
            //System.assertEquals(4, plList.size()); 
            
        }
    }

    @isTest static void audatexUnSavedFields(){
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentUpdateShip_TEST');
            String body    = '[{"callerSystem":"FR_DIVA","AssessmentNumber":"EXTAMI0001-2","Entity":"DIRECT ASSURANCES","EntityCode":"299","isShoppingList":false,"VINCheck":0,"Parts":[{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|df3739acb535be4d8f0ce88b5cc5468f","PartLabel":"PORTE AV G","PartNumber":"9002 S8","Price":444.240,"Quantity":1,"InputType":"Automatic","Currency":"EUR","NBWorkingUnitLevel1":200,"NBWorkingUnitLevel2":300,"NBWorkingUnitLevel3":400,"AlphaScaleMRID":"ASCR-0018660029"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|3605460f8221c8a0911da0eb347bfe6f","PartLabel":"CHARNIERE INFERIEURE DE PORTE AV G","PartNumber":"9035 G6","Price":43.200,"Quantity":1,"InputType":"Automatic","Currency":"EUR","ObsoleteRatio":15.0,"Deducible":16},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|ba962b8bc807a65ac559d12ae75eb23c","PartLabel":"CHARNIERE SUPERIEURE DE PORTE AV G","PartNumber":"9035 G5","Price":43.340,"Quantity":1,"InputType":"Automatic","Currency":"EUR","NBWorkingUnitLevel1":50,"NBWorkingUnitLevel2":60,"NBWorkingUnitLevel3":70},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|530aa8820e8a6aba43b63925260be8e7","PartLabel":"LOT DE FIXATIONS DE PORTE AV G","PartNumber":"6999 GX","Price":34.870,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|f250d4811c92d58f387eba2b8f54d7f1","PartLabel":"PROTECTEUR DE PORTE AV G","PartNumber":"8545 W4","Price":46.850,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|ec60c7c1029e30ca251cdd356a9805fe","PartLabel":"PORTE AR G","PartNumber":"9006 E7","Price":478.310,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|a67ef35c387b46cf3210ed415ccdc3a5","PartLabel":"CHARNIERE INFERIEURE DE PORTE AR G","PartNumber":"9035 G6","Price":43.200,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|955062a4578d816e6a5b3188783a3f6a","PartLabel":"CHARNIERE SUPERIEURE DE PORTE AR G","PartNumber":"9035 G5","Price":43.340,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|05fb781e25907b5a98f9aff3dc0d577d","PartLabel":"LOT DE FIXATIONS DE PORTE AR G","PartNumber":"6999 GX","Price":34.870,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|399fca81bd1e8c5cdd2f3555519ab7a3","PartLabel":"PROTECTEUR DE PORTE AR G","PartNumber":"8546 H7","Price":50.000,"Quantity":1,"InputType":"Automatic","Currency":"EUR","AlphaScaleMRID":"ASP-8546H7"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|643d07c99afcf32808a1a8dcbc72e628","PartLabel":"FEUILLE DETANCHEITE DE PORTE AR G","PartNumber":"9365 L1","Price":51.990,"Quantity":1,"InputType":"Automatic","Currency":"EUR"},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|a92335bc23548af0ad25b3688580c826","PartLabel":"LOT DENJOLIVEURS DE MONTANTS DE PORTES G","PartNumber":"8665 Z0","Price":23.130,"Quantity":1,"InputType":"Automatic","Currency":"EUR"}],"currentAsset":{"Colour":"NOIR OBSIDIEN EFFECT","Engine":"DIESEL TURBO DW10BTED4 FAP","Brand":"PEUGEOT","Model":"307 SW ","PlateNumber":"EQ-402-SW","FirstRegistrationDate":"2006-05-02","VINNumber":"VF33HRHRH84634505"},"currentBodyShop":{"ReferenceNumber":"2763223907"},"currentClaim":{"ClaimReference":"000000AMIv445247926673","DateOfIncident":"2017-11-10","NBWorkingUnit":5,"TotalObsoleteRatio":1.0,"VAT":2.0,"TotalDeducible":3.0,"AssessmentExternalID":"extami0001","AssessmentVersion":2}}]';
            List<PartList__c> partLists = new List<PartList__c>{
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0]),
            TestFactory.createPartList(assessmentList[0])
            };
            partLists[0].TECH_OriginalPart__c = 'null-8665 Z0-LOTDENJOLIVEURSDEMONTANTSDEPORTESG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[1].TECH_OriginalPart__c = 'null-9035 G5-CHARNIERESUPERIEUREDEPORTEAVG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[2].TECH_OriginalPart__c = 'null-6999 GX-LOTDEFIXATIONSDEPORTEAVG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[3].TECH_OriginalPart__c = 'null-8545 W4-PROTECTEURDEPORTEAVG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[4].TECH_OriginalPart__c = 'null-9006 E7-PORTEARG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[5].TECH_OriginalPart__c = 'null-9035 G6-CHARNIEREINFERIEUREDEPORTEARG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[6].TECH_OriginalPart__c = 'null-9035 G5-CHARNIERESUPERIEUREDEPORTEARG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[7].TECH_OriginalPart__c = 'null-6999 GX-LOTDEFIXATIONSDEPORTEARG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[8].TECH_OriginalPart__c = 'null-9365 L1-FEUILLEDETANCHEITEDEPORTEARG-null-FRDIVAEXTAMI0001-2(01)-null';
            partLists[8].OriginalPart__c = partList[0].Id;
            partLists[9].TECH_OriginalPart__c = 'null-8665 Z0-LOTDENJOLIVEURSDEMONTANTSDEPORTESG-null-FRDIVAEXTAMI0001-2(01)-null';
             partLists[9].OriginalPart__c = partList[1].Id;
            insert partLists;

            List<Object> objList = (List<Object>) JSON.deserializeUntyped(body);
            List<Map<String, Object>> lstProcessedAssObj = new List<Map<String, Object>>();
            if(!objList.isEmpty()){
                

                for(Object receivedAssess : objList){
                    Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;
                    //Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;
                    lstProcessedAssObj.add(receivedAssessMap);
                }
                if(!lstProcessedAssObj.isEmpty()){
                    RESTUpsertAssessmentV2.updatePartsKey(lstProcessedAssObj);
                }
            }
        }
    }
    
    @isTest static void upsertAssessmentNewExtId_TES2T()    {
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentNewExtId_TEST');
            Test.setMock(HttpCalloutMock.class, new WS_Sendreq()); 
            Account acc = TestFactory.createAccountDistributor('dist1', 'FR');
            
            acc.DistributorConnected__c = true;
            //RLA 23/09/2020
            acc.Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            acc.ConnectedEndtoEnd__c = true;
            acc.Tech_Distributor__c = 'SAS';
            acc.Categories__c = 'A';
            acc.ShippingCountry = '';
            acc.DistributorRegionsCovered__c = '';
            
            insert acc;

            accountList[3].DistributorConnected__c = true;
            accountList[3].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            accountList[4].DistributorConnected__c = true;
            accountList[4].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[5].DistributorConnected__c = true;
            accountList[5].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[0].DistributorConnected__c = true;
           // accountList[0].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[1].DistributorConnected__c = true;
            //accountList[1].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[2].DistributorConnected__c = true;
           // accountList[2].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[3].DistributorConnected__c = true;
            update accountList;
            
            String requestJSONString ='[{"callerSystem":"FR_DIVA","AssessmentNumber":"","Entity":"DIRECT ASSURANCES","EntityCode":"299","isShoppingList":false,"VINCheck":0,"Parts":[{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|df3739acb535be4d8f0ce88b5cc5468f","PartLabel":"PORTE AV G","PartNumber":"9002 S8","Price":444.24,"Quantity":1,"InputType":"Automatic","Currency":"EUR","IsSelected":false,"NBWorkingUnitLevel1":200,"NBWorkingUnitLevel2":300,"NBWorkingUnitLevel3":400},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|3605460f8221c8a0911da0eb347bfe6f","PartLabel":"CHARNIERE INFERIEURE DE PORTE AV G","PartNumber":"9035 G6","Price":43.2,"Quantity":1,"InputType":"Automatic","Currency":"EUR","IsSelected":false,"ObsoleteRatio":15,"Deducible":16}],"currentAsset":{"Colour":"NOIR OBSIDIEN EFFECT","Engine":"DIESEL TURBO DW10BTED4 FAP","Brand":"PEUGEOT","Model":"307 SW ","PlateNumber":"EQ-402-SW","FirstRegistrationDate":"2006-05-02","VINNumber":"VF33HRHRH84634505"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"ASE445247926673","DateOfIncident":"2017-11-10","NBWorkingUnit":5,"TotalObsoleteRatio":1,"VAT":2,"TotalDeducible":3,"AssessmentExternalID":"ASE2812","AssessmentVersion":1}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentShoppingList()    {
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertAssessmentNewExtId_TEST');
            Test.setMock(HttpCalloutMock.class, new WS_Sendreq()); 
            Account acc = TestFactory.createAccountDistributor('dist1', 'FR');
            
            acc.DistributorConnected__c = true;
            //RLA 23/09/2020
            acc.Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            acc.ConnectedEndtoEnd__c = true;
            acc.Tech_Distributor__c = 'SAS';
            acc.Categories__c = 'A';
            acc.ShippingCountry = '';
            acc.DistributorRegionsCovered__c = '';
            
            insert acc;

            accountList[3].DistributorConnected__c = true;
            accountList[3].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            accountList[4].DistributorConnected__c = true;
            accountList[4].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[5].DistributorConnected__c = true;
            accountList[5].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[0].DistributorConnected__c = true;
           // accountList[0].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[1].DistributorConnected__c = true;
            //accountList[1].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[2].DistributorConnected__c = true;
           // accountList[2].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[3].DistributorConnected__c = true;
            update accountList;
            
            String requestJSONString ='[{"callerSystem":"FR_DIVA","AssessmentNumber":"","Entity":"DIRECT ASSURANCES","EntityCode":"299","isShoppingList":true,"VINCheck":0,"Parts":[{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|df3739acb535be4d8f0ce88b5cc5468f","PartLabel":"PORTE AV G","PartNumber":"9002 S8","Price":444.24,"Quantity":1,"InputType":"Automatic","Currency":"EUR","IsSelected":false,"NBWorkingUnitLevel1":200,"NBWorkingUnitLevel2":300,"NBWorkingUnitLevel3":400},{"RecordType":"Material","Compliance":true,"crashCode":1,"ExternalID":"1|3605460f8221c8a0911da0eb347bfe6f","PartLabel":"CHARNIERE INFERIEURE DE PORTE AV G","PartNumber":"9035 G6","Price":43.2,"Quantity":1,"InputType":"Automatic","Currency":"EUR","IsSelected":false,"ObsoleteRatio":15,"Deducible":16}],"currentAsset":{"Colour":"NOIR OBSIDIEN EFFECT","Engine":"DIESEL TURBO DW10BTED4 FAP","Brand":"PEUGEOT","Model":"307 SW ","PlateNumber":"EQ-402-SW","FirstRegistrationDate":"2006-05-02","VINNumber":"VF33HRHRH84634505"},"currentBodyShop":{"ReferenceNumber":"2763223904"},"currentClaim":{"ClaimReference":"ASE445247926673","DateOfIncident":"2017-11-10","NBWorkingUnit":5,"TotalObsoleteRatio":1,"VAT":2,"TotalDeducible":3,"AssessmentExternalID":"ASE2812","AssessmentVersion":1}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

           /* List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);*/

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }
    
    @isTest static void upsertAssessmentInformex_TEST()    {
        System.runAs(adminUser){
            System.debug('## upsertAssessmentInformex_TEST');
            Test.setMock(HttpCalloutMock.class, new WS_Sendreq()); 
            Account acc = TestFactory.createAccountDistributor('dist1', 'ES');            
            acc.DistributorConnected__c = true;
            acc.ConnectedEndtoEnd__c = true;
            acc.Tech_Distributor__c = 'SAS';
            acc.Categories__c = 'A';
            acc.ShippingCountry = '';
            acc.DistributorRegionsCovered__c = '';
            acc.Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            
            insert acc;

            accountList[2].Categories__c = 'A;E;B';
            accountList[3].DistributorConnected__c = true;
            accountList[3].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';
            accountList[4].DistributorConnected__c = true;
            accountList[4].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[5].DistributorConnected__c = true;
            accountList[5].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[0].DistributorConnected__c = true;
            //accountList[0].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[1].DistributorConnected__c = true;
            //accountList[1].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[2].DistributorConnected__c = true;
           // accountList[2].Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            accountList[3].DistributorConnected__c = true;
            update accountList;
            
            String requestJSONString ='[{"callerSystem":"BE_INFORMEX","MissionNumber":"20188856626","isShoppingList":false,"Parts":[{"RecordType":"Material","PartLabel":"PROT PARE-CHOCS AV","PartNumber":"3D0 807 217CCGRU","Price":662,"Quantity":1,"Currency":"EUR","ExternalID":"3D0 807 217CCGRUPROT PARE-CHOCS AV","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PHARE G CPL","PartNumber":"3D1 941 017N","Price":907,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 941 017NPHARE G CPL","InputType":"Automatic"}],"VINCheck":2,"EntityCode":"0392","currentAsset":{"Brand":"06","Model":"PHAETON (3D)","PlateNumber":"HHHHH","FirstRegistationDate":"2009-01-01","VINNumber":"VSSZZZ6JZBR156584"},"currentBodyShop":{"ReferenceNumber":"404483367","BSlanguage":"fr"},"currentClaim":{"AssessmentExternalID":"RLAV820188856626"}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment();

            system.debug('@@ second upsert');
            requestJSONString = '[{"callerSystem":"BE_INFORMEX","MissionNumber":"20182481553","isShoppingList":false,"Parts":[{"RecordType":"Material","PartLabel":"PROT PARE-CHOCS AV","PartNumber":"3D0 807 217CCGRU","Price":662,"Quantity":1,"Currency":"EUR","ExternalID":"3D0 807 217CCGRUPROT PARE-CHOCS AV","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PHARE G CPL","PartNumber":"3D1 941 017N","Price":907,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 941 017NPHARE G CPL","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"ENTRETOISE","PartNumber":"443 845 631A","Price":2.6,"Quantity":2,"Currency":"EUR","ExternalID":"443 845 631AENTRETOISE","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PARE-BRISE","PartNumber":"3D1 845 011AQ","Price":684,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 845 011AQPARE-BRISE","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"APPLICATEUR","PartNumber":"D00950 025","Price":3.6,"Quantity":1,"Currency":"EUR","ExternalID":"D00950 025APPLICATEUR","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"FIL A DECOUPER","PartNumber":"357 853 999B","Price":18.5,"Quantity":1,"Currency":"EUR","ExternalID":"357 853 999BFIL A DECOUPER","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"KIT COLLE PARE-BRISE","PartNumber":"D00466 0M2","Price":53.9,"Quantity":1,"Currency":"EUR","ExternalID":"D00466 0M2KIT COLLE PARE-BRISE","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PRIMER PARE-BRISE","PartNumber":"D00920 002","Price":9.9,"Quantity":1,"Currency":"EUR","ExternalID":"D00920 002PRIMER PARE-BRISE","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"BALAI ESSUIE-GLACE G","PartNumber":"3D1 998 002","Price":54.9,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 998 002BALAI ESSUIE-GLACE G","InputType":"Automatic"}],"VINCheck":2,"EntityCode":"0392","currentAsset":{"Brand":"06","Model":"PHAETON (3D)","PlateNumber":"HHHHH","FirstRegistationDate":"2009-01-01","VINNumber":"VSSZZZ6JZBR156584"},"currentBodyShop":{"ReferenceNumber":"18690","BSlanguage":"fr"},"currentClaim":{"AssessmentExternalID":"RLAV820188856626"}}]';

            request.requestBody         = Blob.valueOf(requestJSONString);


            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'RLAV820188856626%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

     @isTest static void upsertAssessmenvirtualA_TEST()    {
        System.runAs(adminUser){
            System.debug('## upsertAssessmenvirtualA_TEST');
            //Test.setMock(HttpCalloutMock.class, new WS_Sendreq()); 
            Account acc = TestFactory.createAccountDistributor('dist1', 'FR');            
            acc.EligibleVirtualA__c = true;
            //acc.ConnectedEndtoEnd__c = true;
            acc.Tech_Distributor__c = 'SAS';
            acc.Categories__c = 'A';
            acc.ShippingCountry = '';
            acc.DistributorRegionsCovered__c = '';
            
            insert acc;

            Discount__c dis = TestFactory.createVirtualADiscount(acc, 20, 'A', 'PEUGEOT');
            //dis.Active__c = true;
            dis.ActiveCountry__c = 'FR';
            dis.Distributor__c = acc.Id;
            insert dis;

            System.debug('## dis: '+dis);


            
            accountList[2].Feature__c = 'Virtual A\'';
            accountList[2].DistributorConnected__c = true;
            update accountList;
            
            String requestJSONString ='[{"callerSystem":"FR_DIVA","AssessmentNumber":"","Entity":"DIRECT ASSURANCES","EntityCode":"299","isShoppingList":false,"VINCheck":0,"Parts":[{"RecordType":"Material","PartLabel":"PROT PARE-CHOCS AV","PartNumber":"3D0 807 217CCGRU","Price":662,"Quantity":1,"Currency":"EUR","ExternalID":"3D0 807 217CCGRUPROT PARE-CHOCS AV","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PHARE G CPL","PartNumber":"3D1 941 017N","Price":907,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 941 017NPHARE G CPL","InputType":"Automatic"}],"currentAsset":{"Brand":"PEUGEOT","Model":"PHAETON (3D)","PlateNumber":"HHHHH","FirstRegistationDate":"2009-01-01","VINNumber":"VSSZZZ6JZBR156584"},"currentBodyShop":{"ReferenceNumber":"2763223904","BSlanguage":"fr"},"currentClaim":{"ClaimReference":"RLA123456789011"}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment();

           
            
            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'RLAV820188856626%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentEParts_TEST()    {
        System.runAs(adminUser){
            System.debug('## upsertAssessmenvirtualA_TEST');
            //Test.setMock(HttpCalloutMock.class, new WS_Sendreq()); 
            Account acc = TestFactory.createAccountDistributor('dist1', 'FR');            
            //acc.EligibleVirtualA__c = true;
            //acc.ConnectedEndtoEnd__c = true;
            acc.Tech_Distributor__c = 'SAS';
            acc.Categories__c = 'A';
            acc.ShippingCountry = '';
            acc.DistributorRegionsCovered__c = '';
            acc.DistributionPercentage__c = 50;  
            acc.Type_of_Substitutes__c = 'Connected Substitute;Draft Call;Order Call;Distributor Connected;CatalogSubstitute;Update OEM';

            insert acc;

            Discount__c dis = TestFactory.createVirtualADiscount(acc, 20, 'A', 'PEUGEOT');
            //dis.Active__c = true;
            dis.ActiveCountry__c = 'FR';
            dis.Distributor__c = acc.Id;
            insert dis;

            System.debug('## dis: '+dis);


            
            accountList[3].DistributionPercentage__c = 20;
            accountList[4].DistributionPercentage__c = 30;
            accountList[5].DistributionPercentage__c = 20;
            update accountList;


            List<DistributorPrice__c> lstDps = new list<DistributorPrice__c> {
                                                    TestFactory.createDistributorPrice(accountList[3].Id,crossReferenceList[0].Id),
                                                    TestFactory.createDistributorPrice(accountList[4].Id,crossReferenceList[1].Id),
                                                    TestFactory.createDistributorPrice(accountList[5].Id,crossReferenceList[2].Id),
                                                    TestFactory.createDistributorPrice(acc.Id,crossReferenceList[3].Id)
                                                };
            Insert lstDps;

            crossReferenceList[0].IAMPartClass__c = 'E';            
            crossReferenceList[0].ActiveForSubstitution__c = true;  
            crossReferenceList[0].OEMPartNumber__c = '3D0 807 217CCGRU'; 
            crossReferenceList[0].IAMCleanPartNumber__c = '3D0807217CCGRU'; 
            crossReferenceList[0].OEMCleanPartNumber__c = '3D0807217CCGRU'; 
            crossReferenceList[0].IAMManufacturer__c = 'Opisto';
            crossReferenceList[0].OEMManufacturer__c = 'Peugeot';
            crossReferenceList[0].OEMKey__c = 'FRFR3D0807217CCGRUPEUGEOT';

            crossReferenceList[1].IAMPartClass__c = 'E';            
            crossReferenceList[1].ActiveForSubstitution__c = true;  
            crossReferenceList[1].OEMPartNumber__c = '3D0 807 217CCGRU';
            crossReferenceList[1].IAMCleanPartNumber__c = '3D0807217CCGRU'; 
            crossReferenceList[1].OEMCleanPartNumber__c = '3D0807217CCGRU'; 
            crossReferenceList[1].IAMManufacturer__c = 'Opisto';
            crossReferenceList[1].OEMManufacturer__c = 'Peugeot';
            crossReferenceList[1].OEMKey__c = 'FRFR3D0807217CCGRUPEUGEOT';



            crossReferenceList[2].IAMPartClass__c = 'E';            
            crossReferenceList[2].ActiveForSubstitution__c = true; 
            crossReferenceList[2].OEMPartNumber__c = '3D0 807 217CCGRU'; 
            crossReferenceList[2].IAMCleanPartNumber__c = '3D0807217CCGRU';
            crossReferenceList[2].OEMCleanPartNumber__c = '3D0807217CCGRU';
            crossReferenceList[2].IAMManufacturer__c = 'Precis';
            crossReferenceList[2].OEMManufacturer__c = 'Peugeot';
            crossReferenceList[2].OEMKey__c = 'FRFR3D0807217CCGRUPEUGEOT';



            crossReferenceList[3].IAMPartClass__c = 'E';
            crossReferenceList[3].ActiveForSubstitution__c = true;
            crossReferenceList[3].IAMManufacturer__c = 'Precis'; 
            crossReferenceList[3].OEMManufacturer__c = 'Peugeot';
            crossReferenceList[3].OEMKey__c = 'FRFR3D0807217CCGRUPEUGEOT'; 
            crossReferenceList[3].IAMCleanPartNumber__c = '3D0807217CCGRU'; 
            crossReferenceList[3].OEMCleanPartNumber__c = '3D0807217CCGRU';   

            update crossReferenceList;

            List< CrossReference__c> lstcf = [Select Name,OEMKey__c, OEMCleanPartNumber__c, OEMPartNumber__c, OEMManufacturer__c, IAMPublicPrice__c, ActiveForSubstitution__c, IAMManufacturer__c, IAMPartClass__c, IAMPartDescription__c, IAMPartNumber__c, ASPublicPrice__c,IAMCertifyingOrganization__c, ASNetPrice__c,OEMStandardDiscount__c,OEMStandardMargin__c,OEMPartDescription__c From CrossReference__c ];
            System.debug('@@ lstcf: '+lstcf);  


            String requestJSONString ='[{"callerSystem":"FR_DIVA","AssessmentNumber":"","Entity":"DIRECT ASSURANCES","EntityCode":"299","isShoppingList":false,"VINCheck":0,"Parts":[{"RecordType":"Material","PartLabel":"PROT PARE-CHOCS AV","PartNumber":"3D0 807 217CCGRU","Price":662,"Quantity":1,"Currency":"EUR","ExternalID":"3D0 807 217CCGRUPROT PARE-CHOCS AV","InputType":"Automatic"},{"RecordType":"Material","PartLabel":"PHARE G CPL","PartNumber":"3D1 941 017N","Price":907,"Quantity":1,"Currency":"EUR","ExternalID":"3D1 941 017NPHARE G CPL","InputType":"Automatic"}],"currentAsset":{"Brand":"PEUGEOT","Model":"PHAETON (3D)","PlateNumber":"HHHHH","FirstRegistationDate":"2009-01-01","VINNumber":"VSSZZZ6JZBR156584"},"currentBodyShop":{"ReferenceNumber":"2763223904","BSlanguage":"fr"},"currentClaim":{"AssessmentExternalID":"RLAV820199856626"}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            RESTUpsertAssessmentV2.upsertAssessment();

           
            
            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'RLAV820199856626%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            List<Partlist__c> PartlistsCreatedList = [SELECT Id, Name
                                                         FROM   Partlist__c
                                                         WHERE  Assessment__c =: assessmentCreatedList[0].id];
            

            system.debug('##PartlistsCreatedList upsertAssessmentUpdate_TEST' +PartlistsCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    @isTest static void upsertAssessmentIG()    {

        System.runAs(user3){
            
            System.debug('## upsertAssessmentIG');

            String requestJSONString ='[{"AssessmentNumber":"","SubstitutionType":"A","callerSystem":"DE_IG","InsuranceBroker":"IG","InsBrokerNumber":"IG123","Entity":"IG","EntityCode":"IG","isShoppingList":false,"VINCheck":"2","Parts":[{"PartLabel":"BEF-SATZ STOSSF V","PartNumber":"6999 G9","Price":17.28,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0350"},{"PartLabel":"SCHEINWERFER L","PartNumber":"6204 S9","Price":247.26,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0561"},{"PartLabel":"SATZ ABD WA-DUESEN","PartNumber":"6438 E4","Price":103.73,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0613"},{"PartLabel":"WASCHDUESE SCHEINW L","PartNumber":"6438 E5","Price":64.13,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0625"},{"PartLabel":"WASCHDUESE SCHEINW R","PartNumber":"6438 E5","Price":64.13,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0626"},{"PartLabel":"KOTFLUEGEL V R","PartNumber":"7841 L8","Price":159.14,"Quantity":1.0,"RecordType":"Material","InputType":"Automatic","Currency":"EUR","ExternalID":"0742"}],"currentAsset":{"Brand":"PEUGEOT","Model":"206 CC (2D) Cabrio ab 09/00-04/07 [11]","PlateNumber":"OG-SW 7404","FirstRegistrationDate":"2005-08-01","VINNumber":"VF32D9HZA44782784","KMS":117003,"Colour":"BLAU","Energy":"DIESEL KAT"},"currentBodyShop":{"ReferenceNumber":"IG123"},"currentClaim":{"ClaimReference":"","AssessmentExternalID":"RLA-20200522-2344","DateOfIncident":"2019-12-21"}}]';
            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();
            Test.setMock(HttpCalloutMock.class, new WS_SendreqIG()); 

            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'ASH-228128627632239063220ZY09%'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }
    @isTest static void upsertExpertValidAssessment_TEST()    {
        System.runAs(adminUser){
            System.debug('## assessSubstituteListMap upsertExpertValidAssessment_TEST');
            Assessment__c bsAss = new Assessment__c(BodyShop__c=accountList[1].Id,RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId(),PlateNumber2__c=RESTUpsertAssessmentV2.removeSpaceHypen('3220 ZY 09'),isShoppingList__c=false);
            insert bsAss;

            String requestJSONString ='[{"callerSystem":"DIVA","AssessmentNumber":"","BSInternalRef":"ext1","crashCode":"1","Entity":"AXA Direct","EntityCode":"299","ExpertValidationDate":"2015-04-13T14:10:33.278Z","MissionNumber":"0000012","Name":"AI360505","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"FRONT LWR AIR GRILLE A12 38 261190","PartNumber":"A12 38 261190","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE A2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"A12 38 261290","PartNumber":"A12 38 261290","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH2812","PartNumber":"ASH2812","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Labour","Compliance":true,"InputType":"Automatic","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false},{"PartLabel":"FRONT LWR AIR GRILLE ASH281286","PartNumber":"ASH281286","Price":58,"Manufacturer":"BOSH","Quantity":10,"InterventionCode":"A01","NBHoursLabourPartLevel1":50,"NBHoursLabourPartLevel2":50,"NBHoursLabourPartLevel3":50,"NBHoursLabourPainting":50,"Discount":50,"VATRate":20,"ARCAUTOCode":"AB01","RecordType":"Material","Compliance":true,"InputType":"Manual","Currency":"EUR","CertifyingOrganization":"CR","AlphaScaleMRID":"","IsSelected":false}],"currentAsset":{"Brand":"MERCEDES","Model":"PRIUS T4","PlateNumber":"3220 ZY 09","FirstRegistrationDate":"2015-04-13","VINNumber":"JTDKN36U601451563","KMS":32000,"PaintingType":"V","Colour":"Green","Energy":"Energy","PickupDate":"2015-04-13T14:10:33.278Z","VDSCode":"02"},"currentBodyShop":{"ReferenceNumber":"2763223906"},"currentClaim":{"ClaimReference":"WCH2812862343487","CompanyName":"CPY","DateOfIncident":"2015-04-13","RepairsAuthorised":true,"Fraud":true,"TotalLoss":true,"Fleet":true,"Rental":true,"SpecialAgreement":true,"ExcessAmount":234.23,"QuotationAmountExlVAT":500,"QuotationAmountInclVAT":500,"TotalAmtLabourPainting":200,"TotalAmtLabour":200,"TotalAmtParts":200,"TotalAmtPainting":200,"TotalAmtExlVAT":200,"TotalVAT":200,"TotalAmtInclVAT":200,"NBHoursLabour":200,"NBHoursLabourLevel1":200,"NBHoursLabourLevel2":200,"NBHoursLabourLevel3":200,"TotalAmtLabourExlPainting":200,"NBHoursLabourPainting":200,"TotalAmtPaintingInclLabour":200,"AmtOthers":200,"AssessmentVersion":2}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI          = '/v2.0/upsertAssessment/*';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            
            request.requestBody         = Blob.valueOf(requestJSONString);


            Test.startTest();
                RESTUpsertAssessmentV2.upsertAssessment();
            Test.stopTest();

            
            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                         WHERE  AssessmentNumber__c LIKE 'EXTAMI0001-2'];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }
    //RLA
    @isTest static void isFromR3_TEST()    {

        System.runAs(adminUserNevada){  
            System.debug('## aisFromR3_TEST');
            accountList[1].ReferenceNumber__c = 'FR3563653004'; 
            update accountList[1];

            AccountRef__c accref = TestFactory.createAccountRef('FR3563653004', accountList[1].Id, 'FR_NEVADA');
            accref.ExternalReference__c = 'FR3563653004';
            insert accref;

            String requestJSONString ='[{"TransactionID":"00000060508504732019030119055384","AssessmentNumber":"0000002201181273","BodyShopCreationDate":"2019-03-01T19:05:07.000","Entity":"CAB-MR-NEVADA","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"891398","Name":"MEL2201dCITROEN","PortfolioAgentCode":"","Status":"NEW","MissionId":891398,"DirectReparirerId":0,"Parts":[{"Compliance":true,"Description":"BAS CAISSE D","GuideNo":0,"HeldDate":null,"Name":"BAS CAISSE D","PartNumber":"1608968580","PartNumberOptimized":"","Price":435.01,"PriceOptimized":0.0,"ProducerName":"BAS CAISSE D","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0},{"Compliance":true,"Description":"PORTE AV D","GuideNo":0,"HeldDate":null,"Name":"PORTE AV D","PartNumber":"9801572480","PartNumberOptimized":"","Price":594.24,"PriceOptimized":0.0,"ProducerName":"PORTE AV D","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0},{"Compliance":true,"Description":"JT AV PORTE AV D","GuideNo":0,"HeldDate":null,"Name":"JT AV PORTE AV D","PartNumber":"9678379980","PartNumberOptimized":"","Price":34.57,"PriceOptimized":0.0,"ProducerName":"JT AV PORTE AV D","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0},{"Compliance":true,"Description":"PORTE AR D","GuideNo":0,"HeldDate":null,"Name":"PORTE AR D","PartNumber":"9801572880","PartNumberOptimized":"","Price":594.24,"PriceOptimized":0.0,"ProducerName":"PORTE AR D","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0},{"Compliance":true,"Description":"JT PORTE AR D","GuideNo":0,"HeldDate":null,"Name":"JT PORTE AR D","PartNumber":"9678247280","PartNumberOptimized":"","Price":48.37,"PriceOptimized":0.0,"ProducerName":"JT PORTE AR D","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0},{"Compliance":true,"Description":"Frais de port Alpha Scale","GuideNo":0,"HeldDate":null,"Name":"Frais de port Alpha Scale","PartNumber":"FDP","PartNumberOptimized":"","Price":0.0,"PriceOptimized":0.0,"ProducerName":"Frais de port Alpha Scale","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20.0}],"CurrentAsset":{"BrakesPedalTravel":"","BuildDate":"2014-04-30","Colour":"BL","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"C4 PICASSO","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"","PlateNumber":"EG-571-NV","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2014-04-30","RegistrationMonth":"avril","RegistrationNumber":"","RegistrationYear":2014,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":50.0,"TreadDepthLHR":10.0,"TreadDepthRHF":50.0,"TreadDepthRHR":10.0,"VINNumber":"VF73D9HC8EJ640422","VehicleStatusInspection":"","KMS":0,"PaintingType":null,"Energy":null,"PickupDate":"0001-01-01T00:00:00","VDSCode":null},"CurrentBodyShop":{"BillingCity":"","BillingStreet":"","BillingZipCode":"85170","ClientScoring":"","InvoicePeriod":"","Name":"CARROS&APOS;STYLE,85","OrderEmail":"","ReferenceNumber":"3563653004","FourniseurId":null,"ShippingCity":"","ShippingStreet":"","ShippingZipCode":"85170"},"CurrentClaim":{"TotalLoss":false,"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000002201181273","CompanyName":"CAB-MR-NEVADA","DateOfIncident":"2019-02-22","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0.0,"WorkProvider":"","QuotationAmountExlVAT":null,"QuotationAmountInclVAT":null,"TotalAmtLabourPainting":null,"TotalAmtLabour":null,"TotalAmtParts":null,"TotalAmtPainting":null,"TotalAmtExlVAT":null,"TotalVAT":null,"TotalAmtInclVAT":null,"NBHoursLabour":null,"NBHoursLabourLevel1":null,"NBHoursLabourLevel2":null,"NBHoursLabourLevel3":null,"TotalAmtLabourExlPainting":null,"TotalAmtPaintingInclLabour":null,"AmtOthers":null}}]';

            RestRequest request         = new RestRequest();
            request.httpMethod          = 'POST';
            request.requestURI = '/v2.0/createAssessment/';
            request.requestBody         = Blob.valueOf(requestJSONString);

            RestContext.request         = request;
            RestContext.response        = new RestResponse();

            
            request.requestBody         = Blob.valueOf(requestJSONString);


            Test.startTest();
                RESTCreateAssessment_V2.createNewAssessment();
            Test.stopTest();

            
            Blob jsonBlob               = RestContext.response.responseBody;


            String jsonResponseString   =  jsonBlob.toString();
            //system.debug('## jsonResponseString:'+jsonResponseString);
            
            //System.assertEquals(false, jsonResponseString.contains('Exceptions:'));

            List<Assessment__c> assessmentCreatedList = [SELECT Id, Name, Status__c, AssessmentNumber__c, BodyShop__c,
                                                                EntityCode__c, Manufacturer__c, VINCheck__c
                                                         FROM   Assessment__c
                                                        //  WHERE  AssessmentNumber__c LIKE 'EXTAMI0001-2'
                                                         ];
            

            system.debug('##assessmentCreatedList upsertAssessmentUpdate_TEST' +assessmentCreatedList);

            //System.assertEquals(2, assessmentCreatedList.size()); 

        } 
    }

    //RLA
    @isTest static void modifyBrandCitroen()  {
        System.runAs(adminUser){
            System.debug('## modifyBrandCitroen');

            Test.startTest();
                
                RESTUpsertAssessmentV2.modifyBrandCitroen('CITRO�N');
            Test.stopTest();


        }
    }

    //RLA
    @isTest static void splitForBPartTypesStatusPerDist()  {
        System.runAs(adminUser){
            System.debug('## splitForBPartTypesStatus');

            Test.startTest();
                
                Map<String,Map<String,List<String>>> mapReturn = RESTUpsertAssessmentV2.splitForBPartTypesStatusPerDist('A:CONFIRMED;CONFIRMEDWITHDELAY-B:PARTIAL;NOTFOUND', 'SAS');
            Test.stopTest();


        }
    }
    
    @isTest static void getFakeReferences()  {
        System.runAs(adminUser){
            System.debug('## getFakeReferences');

            Test.startTest();
                
                Set<String> setReturn = RESTUpsertAssessmentV2.getFakeReferences('FR');
            Test.stopTest();


        }
    }
	
    
    public class WS_Sendreq implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String responseHttp;
            //responseHttp = '[Endpoint=http://labo.vitemescomptes.fr:5000/applications/exponens/v1.0/updateDistributorInvoiceStatus, Method=POST]';
            responseHttp = '{"ClaimReference":"ASE445247926673","Request":"Draft","Distributors":{"SAS":{"ExternalOrderReference":"","Lines":[{"ID":"FRDIVAASE2812-1-1|DF3739ACB535BE4D8F0CE88B5CC5468F","Quantity":1,"PartNumber":"9002 S8","Type":"A","Manufacturer":"PEUGEOT","Description":"PORTE AV G","CatalogPrice":435.24,"AlphaScaleDiscount":17,"AlphaScaleDiscountAdditional":5,"BodyShopDiscount":17,"Status":"CONFIRMED","StatusMessage":"","Bundle":false},{"ID":"FRDIVAASE2812-1-1|3605460F8221C8A0911DA0EB347BFE6F","Quantity":1,"PartNumber":"9035 G6","Type":"A","Manufacturer":"PEUGEOT","Description":"CHARNIERE INFERIEURE DE PORTE AV G","CatalogPrice":43.2,"AlphaScaleDiscount":13,"AlphaScaleDiscountAdditional":0,"BodyShopDiscount":13,"Status":"CONFIRMEDWITHDELAY","StatusMessage":"","Bundle":false}],"Success":"true"}},"BodyShop":{"VATNumber":"FR24532658044","Name":"OPN AUTO NIMES","ExternalReference":"FR1215727904"},"Vehicle":{"VinNumber":"VF33HRHRH84634505","PlateNumber":"EQ402SW","Model":"307 SW ","FirstRegistrationDate":"2006-05-02","Brand":"PEUGEOT"}}';
            //responseHttp = '[{"diagnosis":{"id":1,"diagnosisDescKey":"diag.prospecting.mobility","subCategoryDescKey":"sub_category_full","version":"0.0.1"},"questionList":[{"id":961,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.repartition","relevanceLevel":0,"answerTypeId":1,"minValue":0,"maxValue":10000000},{"id":962,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice1","relevanceLevel":2,"answerTypeId":113}, {"id":1210,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice4","relevanceLevel":2,"answerTypeId":117}]}]';

            HttpResponse res = new HttpResponse();
            res.setBody(responseHttp);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class WS_SendreqIG implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String responseHttp;
            //responseHttp = '[Endpoint=http://labo.vitemescomptes.fr:5000/applications/exponens/v1.0/updateDistributorInvoiceStatus, Method=POST]';
            responseHttp = '{"ClaimReference":"","Request":"DRAFT","Distributors":{"COLER":{"ExternalOrderReference":"","Lines":[{"ID":"DEIGRLA-20200522-2344-0350","Quantity":1,"PartNumber":"6999G9","Type":"A","Manufacturer":"Peugeot","Description":"Bef Schild Vo","CatalogPrice":17.28,"AlphaScaleDiscount":25.0,"BodyShopDiscount":25.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"DEIGRLA-20200522-2344-0561","Quantity":1,"PartNumber":"6204S9","Type":"A","Manufacturer":"Peugeot","Description":"Scheinwerfer","CatalogPrice":247.26,"AlphaScaleDiscount":30.0,"BodyShopDiscount":30.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0613","Quantity":1,"PartNumber":"6438E4","Type":"A","Manufacturer":"Peugeot","Description":"Satz Kappe","CatalogPrice":103.73,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"DEIGRLA-20200522-2344-0625","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":64.13,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0626","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":64.13,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"NOTFOUND","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0742","Quantity":1,"PartNumber":"7841L8","Type":"A","Manufacturer":"Peugeot","Description":"Kotfluegel Vorn","CatalogPrice":159.14,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"NOTFOUND","Bundle":false,"DeliveryDays":"1"}]},"NORA":{"ExternalOrderReference":"","Lines":[{"ID":"DEIGRLA-20200522-2344-0350","Quantity":1,"PartNumber":"6999G9","Type":"A","Manufacturer":"Peugeot","Description":"Bef Schild Vo","CatalogPrice":17.28,"AlphaScaleDiscount":25.0,"BodyShopDiscount":25.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"DEIGRLA-20200522-2344-0561","Quantity":1,"PartNumber":"6204S9","Type":"A","Manufacturer":"Peugeot","Description":"Scheinwerfer","CatalogPrice":247.26,"AlphaScaleDiscount":30.0,"BodyShopDiscount":30.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0613","Quantity":1,"PartNumber":"6438E4","Type":"A","Manufacturer":"Peugeot","Description":"Satz Kappe","CatalogPrice":103.73,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMEDWITHDELAY","Bundle":false,"DeliveryDays":"2"},{"ID":"DEIGRLA-20200522-2344-0625","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":64.13,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0626","Quantity":1,"PartNumber":"6438E5","Type":"A","Manufacturer":"Peugeot","Description":"Scheinw W-Duese","CatalogPrice":64.13,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"},{"ID":"DEIGRLA-20200522-2344-0742","Quantity":1,"PartNumber":"7841L8","Type":"A","Manufacturer":"Peugeot","Description":"Kotfluegel Vorn","CatalogPrice":159.14,"AlphaScaleDiscount":20.0,"BodyShopDiscount":20.0,"Status":"CONFIRMED","Bundle":false,"DeliveryDays":"1"}],"Success":"true"}},"BodyShop":{"VATNumber":"DE253475183","Name":"Car Top Zentrum Stuttgart","ExternalReference":"123456789"},"Vehicle":{"VinNumber":"VF32D9HZA44782784","PlateNumber":"OGSW7404","Model":"206 CC (2D) Cabrio ab 09/00-04/07 [11]","FirstRegistrationDate":"2005-08-01","Brand":"Peugeot"}}';
            //responseHttp = '[{"diagnosis":{"id":1,"diagnosisDescKey":"diag.prospecting.mobility","subCategoryDescKey":"sub_category_full","version":"0.0.1"},"questionList":[{"id":961,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.repartition","relevanceLevel":0,"answerTypeId":1,"minValue":0,"maxValue":10000000},{"id":962,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice1","relevanceLevel":2,"answerTypeId":113}, {"id":1210,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice4","relevanceLevel":2,"answerTypeId":117}]}]';

            HttpResponse res = new HttpResponse();
            res.setBody(responseHttp);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}