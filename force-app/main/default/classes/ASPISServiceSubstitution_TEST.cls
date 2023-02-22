/*************************************************************************************
Class Name - ASPISServiceSubstitution_TEST
Version - 1.0
Created Date - 25 FEB 2016
Function - TestClass for ASPISServiceSubstitution

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date           Description
* ----------    ----------     -----------------------
 Dourga U       18/08/2016     MasterRule Substitution (case 1622,1673)
 Welsa C 		11/10/2018	   C-002754: add TECHDistList__c field
*************************************************************************************/
@isTest
public with sharing class ASPISServiceSubstitution_TEST {
	static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> listAccounts;
    static list<Assessment__c> listAssessments;
    static list<CrossReference__c> listCrossReferences;
	static list<MasterRules__c> listMasterRule;
	static list<DetailRule__c> listDetailRule;
    static list<CarMapping__c> listCarMapping;
    static list<AccountRef__c> listAccountRef;
    static list<PartList__c> listPartLists;
    static Map<String, Schema.SObjectType> gloDescribe;
    static Schema.SObjectType objectTypeBMatch;
    static Map<String, Schema.SobjectField> fieldMapBMatch;
    static Schema.SObjectType objectTypeUpdateF;
    static Map<String, Schema.SobjectField> fieldMapUpdateF;


	static {
        // initialising variables
        listAccounts = new list <Account>();
        listAssessments = new list <Assessment__c>();
        listCrossReferences = new list<CrossReference__c>();
		listMasterRule = new list<MasterRules__c>();
		listDetailRule = new list<DetailRule__c>();
    	listCarMapping = new list<CarMapping__c>();
    	listAccountRef = new list<AccountRef__c>();
        listPartLists = new list <PartList__c>();
        gloDescribe = Schema.getGlobalDescribe();  
        objectTypeBMatch = gloDescribe.get('CrossReference__c');
        fieldMapBMatch = objectTypeBMatch.getDescribe().fields.getMap();
        objectTypeUpdateF = gloDescribe.get('PartList__c');
        fieldMapUpdateF = objectTypeUpdateF.getDescribe().fields.getMap();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.isEligible__c = true;
            bs1.Categories__c = 'A; B';
            bs1.ExpertSubstitutionMethod__c = 'FORCED';
            listAccounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Categories__c = '';
            bs2.ExpertSubstitutionMethod__c = 'FORCED';
            listAccounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Categories__c = 'P';
            listAccounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            listAccounts.add(dist2);  

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            listAccounts.add(dist3);    

            insert listAccounts;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'SUBSTITUTION';
            ass1.AssessmentNumber__c = 'Num001';
            listAssessments.add(ass1);
        
            //Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            //ass2.Entity__c = 'AXA Direct1';
            //ass2.EntityRules__c = 'AXA Direct1';
            //ass2.EntityCode__c = '213';
            //ass2.BuildDate__c = date.today()+1;
            //ass2.Status__c = 'SOURCED';
            //ass2.AssessmentNumber__c = 'Num001';
            //listAssessments.add(ass2);
        
            //Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            //ass3.Entity__c = 'AXA Direct2';
            //ass3.EntityRules__c = 'AXA Direct2';
            //ass3.EntityCode__c = '299';
            //ass3.Status__c = 'SUBSTITUTION';
            //ass3.AssessmentNumber__c = 'Num001';
            //listAssessments.add(ass3);  

            insert listAssessments;

            CrossReference__c crossRef1 = TestFactory.createCrossReference('FR', 'A1238261290', 'Mercedes', 50.0, true);
            crossRef1.IAMPublicPrice__c = 50.0;
            listCrossReferences.add(crossRef1);

            CrossReference__c crossRef2 = TestFactory.createCrossReference('FR', 'A10111291', 'Renault', 40.0, true);
            crossRef2.IAMPublicPrice__c = 40.0;
            listCrossReferences.add(crossRef2);

            CrossReference__c crossRef3 = TestFactory.createCrossReference('FR', 'A10111292', 'BMW', 50.0, true);
            crossRef3.IAMPublicPrice__c = 50.0;
            listCrossReferences.add(crossRef3);

            CrossReference__c crossRef4 = TestFactory.createCrossReference('FR', 'A1238261290', 'Mercedes', 40.0, true);
            crossRef4.IAMPublicPrice__c = 40.0;
            listCrossReferences.add(crossRef4);

            CrossReference__c crossRef5 = TestFactory.createCrossReference('FR', 'A0008200266', 'Mercedes', 40.0, true);
            crossRef5.IAMPublicPrice__c = 40.0;
            listCrossReferences.add(crossRef5);

            CrossReference__c crossRef6 = TestFactory.createCrossReference('FR', 'A1238261290', 'Mercedes', 40.0, true);
            crossRef6.IAMPublicPrice__c = 40.0;
            listCrossReferences.add(crossRef6);

            CrossReference__c crossRef7 = TestFactory.createCrossReference('FR', 'A1238261290', 'Mercedes', 60.0, true);
            crossRef7.IAMPublicPrice__c = 60.0;
            listCrossReferences.add(crossRef7);

            insert listCrossReferences;
            
			listCarMapping = TestFactory.createCarMappingList('GTMOTIVE');

			insert listCarMapping;

			AccountRef__c accountRef1 = TestFactory.createAccountRef('2763223904', listAccounts[0].Id, 'GTMOTIVE');
			listAccountRef.add(accountRef1);

			insert listAccountRef;

            MasterRules__c masterRule1 = TestFactory.createMasterRule('FR299', 'SUBSTITUTION', 'CrossReference__c');
            masterRule1.FilterLogic__c = '5';
            masterRule1.ValidationLogic__c = '6';
            masterRule1.RuleStatus__c = system.Label.RULESTATUSACTIVELABEL;
            masterRule1.LogicSubstitutionCriteria__c = '5';
            listMasterRule.add(masterRule1);

            MasterRules__c masterRule2 = TestFactory.createMasterRule('FR298', 'SUBSTITUTION', 'CrossReference__c');
            masterRule2.ValidationLogic__c = '18';
            listMasterRule.add(masterRule2);

			insert listMasterRule;

            DetailRule__c detailRule1 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Name, OEMPartNumber__c, OEMManufacturer__c, OEMPublicPrice__c, ActiveForSubstitution__c, IAMManufacturer__c, IAMPartClass__c, IAMPartDescription__c, IAMPartNumber__c, IAMPublicPrice__c, IAMCertifyingOrganization__c', null, null, 'Primary Fields Needed', 'CrossReference__c', 1);
            listDetailRule.add(detailRule1);

            DetailRule__c detailRule2 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'OEMPartNumber__c-OEMManufacturer__c', null, null, 'Key Field', 'CrossReference__c', 2);
            listDetailRule.add(detailRule2);

            DetailRule__c detailRule3 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'IAMPublicPrice__c', 'MIN', null, 'Criteria', 'CrossReference__c', 3);
            listDetailRule.add(detailRule3);    

            DetailRule__c detailRule4 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'SelectedByBS__c', 'Equals', 'TRUE', 'Update Field', 'PartList__c', 4);
            listDetailRule.add(detailRule4); 

            DetailRule__c detailRule5 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'Name, OEMPartNumber__c, OEMManufacturer__c, OEMPublicPrice__c, ActiveForSubstitution__c, IAMManufacturer__c, IAMPartClass__c, IAMPartDescription__c, IAMPartNumber__c, IAMPublicPrice__c, IAMCertifyingOrganization__c', null, null, 'Primary Fields Needed', 'CrossReference__c', 1);
            listDetailRule.add(detailRule5);

            DetailRule__c detailRule6 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'OEMPartNumber__c', null, null, 'Key Field', 'CrossReference__c', 2);
            listDetailRule.add(detailRule6);

            DetailRule__c detailRule7 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'GREATER_EQUALS', '0', 'Criteria', 'CrossReference__c', 3);
            listDetailRule.add(detailRule7);    

            DetailRule__c detailRule8 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'GREATER', '0', 'Criteria', 'CrossReference__c', 4);
            listDetailRule.add(detailRule8);   

            DetailRule__c detailRule9 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'SelectedByBS__c', 'Equals', 'TRUE', 'Update Field', 'PartList__c', 5);
            listDetailRule.add(detailRule9);   

            DetailRule__c detailRule10 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'LESS_EQUALS', '100', 'Criteria', 'CrossReference__c', 6);
            listDetailRule.add(detailRule10);    

            DetailRule__c detailRule11 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'LESS', '100', 'Criteria', 'CrossReference__c', 7);
            listDetailRule.add(detailRule11);   

            DetailRule__c detailRule12 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'MAX', null, 'Criteria', 'CrossReference__c', 8);
            listDetailRule.add(detailRule12);           

            DetailRule__c detailRule13 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'MIN', null, 'Criteria', 'CrossReference__c', 9);
            listDetailRule.add(detailRule13);           

            DetailRule__c detailRule14 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'NBHoursLabourPartLevel1__c', 'Equals', '5', 'Update Field', 'PartList__c', 10);
            listDetailRule.add(detailRule14);   

            DetailRule__c detailRule15 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'Description__c', 'Equals', 'descriptionOfPart', 'Update Field', 'PartList__c', 11);
            listDetailRule.add(detailRule15);   

            DetailRule__c detailRule16 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'HeldDate__c', 'Equals', '2016-08-23', 'Update Field', 'PartList__c', 12);
            listDetailRule.add(detailRule16);          

            DetailRule__c detailRule17 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPublicPrice__c', 'Equals', '40', 'Criteria', 'CrossReference__c', 13);
            listDetailRule.add(detailRule17); 

            DetailRule__c detailRule18 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'ASPublicPrice__c', 'NOT_EQUALS', '0', 'Filter Condition', 'CrossReference__c', 5);
            listDetailRule.add(detailRule18);  

            DetailRule__c detailRule19 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Assessment__r.BodyShop__r.Type', 'NOT_EQUALS', 'Expert', 'Validation', 'PartList__c', 6);
            listDetailRule.add(detailRule19);     

            DetailRule__c detailRule20 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'DistributorReferencesAvailable__c', 'Equals', 'true', 'Filter Condition', 'CrossReference__c', 14);
            listDetailRule.add(detailRule20);   

            DetailRule__c detailRule21 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPartDescription__c', 'Equals', 'descriptionOfPart', 'Filter Condition', 'CrossReference__c', 15);
            listDetailRule.add(detailRule21);   

            DetailRule__c detailRule22 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'IAMPriceDate__c', 'Equals', '2016-08-23', 'Filter Condition', 'CrossReference__c', 16);
            listDetailRule.add(detailRule22); 

            DetailRule__c detailRule23 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'CreationDate__c', 'Equals', '2016-06-10T14:07:00.000Z', 'Filter Condition', 'CrossReference__c', 17);
            listDetailRule.add(detailRule23); 

            DetailRule__c detailRule24 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'Assessment__r.BodyShop__r.Type', 'EQUALS', 'Expert', 'Validation', 'PartList__c', 18);
            listDetailRule.add(detailRule24);   

            DetailRule__c detailRule25 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'Description__c', 'GREATER', 'Expert', 'Validation', 'PartList__c', 19);
            listDetailRule.add(detailRule25);   

            DetailRule__c detailRule26 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'InputType__c', 'GREATER_EQUALS', 'Expert', 'Validation', 'PartList__c', 20);
            listDetailRule.add(detailRule26);   

            DetailRule__c detailRule27 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'InterventionCode__c', 'LESS', 'Expert', 'Validation', 'PartList__c', 21);
            listDetailRule.add(detailRule27);   

            DetailRule__c detailRule28 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[1], 'ProducerName__c', 'LESS_EQUALS', 'Expert', 'Validation', 'PartList__c', 22);
            listDetailRule.add(detailRule28);    

            DetailRule__c detailRule29 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'ASPublicPrice__c', 'NOT_EQUALS', 'null', 'Filter Condition', 'CrossReference__c', 23);
            listDetailRule.add(detailRule29);  

            // DetailRule__c detailRule30 = TestFactory.createDetailRule(system.Label.PROCESSSOURCINGLABEL, listMasterRule[0], 'Categories__c', 'NOT_EQUALS', 'null', 'Filter Condition', 'Account', 23);
            // listDetailRule.add(detailRule30);  

            // DetailRule__c detailRule31 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'LIMIT', '50', 'Filter Condition', 'Account', 23);
            // listDetailRule.add(detailRule31);  


       /*      DetailRule__c detailRule32 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'NOT_IN', '50', 'Filter Condition', 'Account', 23);
            listDetailRule.add(detailRule32); 

            
            DetailRule__c detailRule33 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'NOT_IN', '50', 'Tyres_Criteria', 'Account', 23);
            listDetailRule.add(detailRule33); 

            DetailRule__c detailRule34 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'EQUALS', '50', 'Tyres_Criteria', 'Account', 23);
            listDetailRule.add(detailRule34); 
   
            DetailRule__c detailRule35 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'NOT_EQUALS', '50', 'Tyres_Criteria', 'Account', 23);
            listDetailRule.add(detailRule35); 

            DetailRule__c detailRule36 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'IN', '50', 'Tyres_Criteria', 'Account', 23);
            listDetailRule.add(detailRule36); 

            DetailRule__c detailRule37 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'GREATER', '50', 'Tyres_Criteria', 'Account', 23);
            listDetailRule.add(detailRule37); 


            DetailRule__c detailRule38 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'NOT_IN', '50', 'Xref_Criterias', 'Account', 23);
            listDetailRule.add(detailRule38); 

            DetailRule__c detailRule39 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'EQUALS', '50', 'Xref_Criterias', 'Account', 23);
            listDetailRule.add(detailRule39); 
   
            DetailRule__c detailRule40 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'NOT_EQUALS', '50', 'Xref_Criterias', 'Account', 23);
            listDetailRule.add(detailRule40); 

            DetailRule__c detailRule41 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'IN', '50', 'Xref_Criterias', 'Account', 23);
            listDetailRule.add(detailRule41); 

            DetailRule__c detailRule42 = TestFactory.createDetailRule('SUBSTITUTION', listMasterRule[0], 'Categories__c', 'GREATER', '50', 'Xref_Criterias', 'Account', 23);
            listDetailRule.add(detailRule42);  */ 



			insert listDetailRule;

            PartList__c pl1 = TestFactory.createPartList(listAssessments[0]);
            pl1.CrossReferenceId__c = listCrossReferences[0].Id;            
            listPartLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(listAssessments[0]);
            pl2.CrossReferenceId__c = listCrossReferences[0].Id;
            listPartLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartList(listAssessments[0]);
            pl3.CrossReferenceId__c = listCrossReferences[0].Id;
            listPartLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(listAssessments[0]);
            pl4.CrossReferenceId__c = listCrossReferences[0].Id;            
            listPartLists.add(pl4);

            PartList__c pl5 = TestFactory.createPartList(listAssessments[0]);
            pl5.CrossReferenceId__c = listCrossReferences[0].Id;            
            listPartLists.add(pl5);

            PartList__c pl6 = TestFactory.createPartList(listAssessments[0]);
            pl6.CrossReferenceId__c = listCrossReferences[1].Id;
            listPartLists.add(pl6);

            PartList__c pl7 = TestFactory.createPartList(listAssessments[0]);
            listPartLists.add(pl7);

            PartList__c pl8 = TestFactory.createPartList(listAssessments[0]);
            listPartLists.add(pl8);

            //insert listPartLists;

        }
    }

    @isTest static void test_SubstitiutionRunSubstitution() {
        system.debug('#### Start of test_SubstitiutionRunSubstitution');

        system.runAs(userAdmin){  
        String body = '[{"callerSystem":"DIVA","crashCode":1,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"AILE AV G","PartNumber":"A1238261290","Price":110,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"},{"PartLabel":"AILE AV G","PartNumber":"A0008200266","Price":110,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}},{"callerSystem":"DIVA","crashCode":2,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"CAPOT-MOTEUR","PartNumber":"A0008200266","Price":320,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}},{"callerSystem":"DIVA","crashCode":2,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"CAPOTE-MOTEUR","PartNumber":"A1238261690","Price":320,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}}]';
            List<Object> objList =  (List<Object>)JSON.deserializeUntyped(body);
            List<Object> receivedPartList = new List<Object>();
            set<String> setTechId = new set<String>();
            for(Object receivedAssess: objList){
                Map<String,Object> receivedAssessMap = (Map<String, Object>)receivedAssess;
                for(Object pa: (List<Object>)receivedAssessMap.get('Parts')){
                    map<String,Object> mappa = (map<String,Object>)pa;
                    receivedPartList.add(pa);
                }
            }
            String body2 = '[{"callerSystem":"DIVA","crashCode":1,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"AILE AV G","PartNumber":"A1238261290","Price":110,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}}]';
            List<Object> objList2 =  (List<Object>)JSON.deserializeUntyped(body2);
            List<Object> receivedPartList2 = new List<Object>();
            for(Object receivedAssess2: objList2){
                Map<String,Object> receivedAssessMap2 = (Map<String, Object>)receivedAssess2;
                for(Object pa2: (List<Object>)receivedAssessMap2.get('Parts')){
                    map<String,Object> mappa2 = (map<String,Object>)pa2;
                    receivedPartList2.add(pa2);
                }
            }
            test.starttest();
                map<String,list<Object>> mapAsslistParts = new map<String,list<Object>>{'DM1-Mercedes-FR' => receivedPartList,'DM2-Mercedes-FR' => receivedPartList2}; 
                String entityCode = 'FR299';
                map<String, set<String>> assessBSCategoriesMap = new map<String, set<String>>{'DM1-Mercedes-FR' => new set<String>{'A', 'B'}, 'DM2-Mercedes-FR' => null};
                
                ASPISServiceSubstitution.SubstituteWrapper newSubWrap = ASPISServiceSubstitution.runSubstitution(mapAsslistParts, entityCode, assessBSCategoriesMap);
                system.debug('## newSubWrap:'+newSubWrap);
                system.debug('## listPartLists:'+listPartLists);
                system.debug('## 2:'+newSubWrap.listUpdateFieldsCriteria);
                system.debug('## 3:'+fieldMapUpdateF);


                list<SObject> listPartListFieldUpdate = ASPISServiceSubstitution.updateField(listPartLists, 'PartList__c', newSubWrap.listUpdateFieldsCriteria, fieldMapUpdateF, new set <string>(), new map <string,Schema.DisplayType>());
                insert listPartLists;
                for(PartList__c pl : listPartLists){
                    setTechId.add(pl.TECH_OriginalPart__c);
                }
                map<String,PartList__c> mapTechIdPart = ASPISServiceSubstitution.runValidation(newSubWrap.listValidationCriteria, newSubWrap.listUpdateFieldsCriteria ,setTechId, 'FR299',newSubWrap.validationLogicValue);
                System.assertNotEquals(newSubWrap, null);  
                System.assertEquals(listPartListFieldUpdate.size(), 8);  
            test.stoptest();
        }
    }

    @isTest static void test_SubstitiutionRunSubstitutionFieldAsKey() {
        system.debug('#### Start of test_SubstitiutionRunSubstitutionFieldAsKey');

        system.runAs(userAdmin){  
        String body = '[{"callerSystem":"DIVA","crashCode":1,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"CAPOT-MOTEUR","PartNumber":"A0008200266","Price":320,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"},{"PartLabel":"AILE AV G","PartNumber":"A1238261290","Price":110,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}},{"callerSystem":"DIVA","crashCode":2,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"CAPOT-MOTEUR","PartNumber":"A0008200266","Price":320,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}},{"callerSystem":"DIVA","crashCode":2,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"CAPOTE-MOTEUR","PartNumber":"A1238261690","Price":320,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}}]';
            List<Object> objList =  (List<Object>)JSON.deserializeUntyped(body);
            List<Object> receivedPartList = new List<Object>();
            set<String> setTechId = new set<String>();
            for(Object receivedAssess: objList){
                Map<String,Object> receivedAssessMap = (Map<String, Object>)receivedAssess;
                for(Object pa: (List<Object>)receivedAssessMap.get('Parts')){
                    map<String,Object> mappa = (map<String,Object>)pa;
                    receivedPartList.add(pa);
                }
            }
            String body2 = '[{"callerSystem":"DIVA","crashCode":1,"AssessmentNumber":"","Entity":"AXA FRANCE","EntityCode":"299","IsSubstitution":true,"VINCheck":0,"Parts":[{"PartLabel":"AILE AV G","PartNumber":"A1238261290","Price":110,"Quantity":1,"RecordType":"Material","Compliance":true,"InputType":"Automatic"}],"currentAsset":{"Colour":"BELLE ILE MET","Engine":"INJECTION EP3C","Brand":"Peugeot","Model":"207","PlateNumber":"CA-547-QW","FirstRegistrationDate":"2012-01-24","VINNumber":"VF3WC8FP0CT006888"},"currentBodyShop":{"ReferenceNumber":"05310001"},"currentClaim":{"ClaimReference":"123456"}}]';
            List<Object> objList2 =  (List<Object>)JSON.deserializeUntyped(body2);
            List<Object> receivedPartList2 = new List<Object>();
            for(Object receivedAssess2: objList2){
                Map<String,Object> receivedAssessMap2 = (Map<String, Object>)receivedAssess2;
                for(Object pa2: (List<Object>)receivedAssessMap2.get('Parts')){
                    map<String,Object> mappa2 = (map<String,Object>)pa2;
                    receivedPartList2.add(pa2);
                }
            }
            test.starttest();
                map<String,list<Object>> mapAsslistParts = new map<String,list<Object>>{'DM1-Mercedes-FR' => receivedPartList,'DM2-Mercedes-FR' => receivedPartList2}; 
                String entityCode = 'FR298';
                map<String, set<String>> assessBSCategoriesMap = new map<String, set<String>>{'DM1-Mercedes-FR' => null, 'DM2-Mercedes-FR' => new set<String>{'A', 'B'}};
                
                ASPISServiceSubstitution.SubstituteWrapper newSubWrap = ASPISServiceSubstitution.runSubstitution(mapAsslistParts, entityCode, assessBSCategoriesMap);
                list<SObject> listPartListFieldUpdate = ASPISServiceSubstitution.updateField(listPartLists, 'PartList__c', newSubWrap.listUpdateFieldsCriteria, fieldMapUpdateF, new set <string>(), new map <string,Schema.DisplayType>());
                insert listPartLists;
                for(PartList__c pl : listPartLists){
                    setTechId.add(pl.TECH_OriginalPart__c);
                }
                map<String,PartList__c> mapTechIdPart = ASPISServiceSubstitution.runValidation(newSubWrap.listValidationCriteria, newSubWrap.listUpdateFieldsCriteria ,setTechId, 'FR298',newSubWrap.validationLogicValue);
                system.debug('listDetailRule[12]'+listDetailRule[12]);
                list<SObject> listBestMatch = ASPISServiceSubstitution.findBestMatch('CrossReference__c', listCrossReferences ,listDetailRule[12]/*,fieldMapBMatch, new set <string>(), new map <string,Schema.DisplayType>()*/);
                list<SObject> listBestMatch2 = ASPISServiceSubstitution.findBestMatch('CrossReference__c', listCrossReferences ,listDetailRule[16]/*,fieldMapBMatch, new set <string>(), new map <string,Schema.DisplayType>()*/);
                System.assertNotEquals(newSubWrap, null);  
                System.assertEquals(listPartListFieldUpdate.size(), 8);  
            test.stoptest();
        }
    }


    @isTest static void test_selectionE() {
        system.debug('#### Start of test_selectionE');

        system.runAs(userAdmin){  
           map<String,List<Partlist__c>> mapOriginalTechParts = new map <String,List<Partlist__c>>();

           List<Account> lstDist = new list<Account>();

           Account dist = TestFactory.createAccountDistributor('Precis','FR');
        //    dist.DistributionPercentage__c = 50;
           lstDist.add(dist);
           

           Account dist2 = TestFactory.createAccountDistributor('Opisto','FR');
        //    dist2.DistributionPercentage__c = 40;
           lstDist.add(dist2);

           insert lstDist;


           String originalKeyz='qwerty';

           PartList__c pl1 = TestFactory.createPartList(listAssessments[0]);
            pl1.CrossReferenceId__c = listCrossReferences[0].Id;            
            pl1.Distributor__c = dist.Id;            
            pl1.TECH_OriginalPart__c = '123';            
            listPartLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(listAssessments[0]);
            pl2.CrossReferenceId__c = listCrossReferences[0].Id;
            pl2.Distributor__c = dist2.Id; 
            pl2.TECH_OriginalPart__c = '1234';            


            listPartLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartList(listAssessments[0]);
            pl3.CrossReferenceId__c = listCrossReferences[0].Id;
            pl3.Distributor__c = dist.Id; 
            pl3.TECH_OriginalPart__c = '12345';            


            listPartLists.add(pl3);

            insert listPartLists;

           mapOriginalTechParts.put('qwerty',listPartLists);

           Test.startTest();
        //  ASPISServiceSubstitution.selectionE(mapOriginalTechParts, originalKeyz);
           Test.stopTest();

        }

    }

    @isTest static void test_randomizeList(){
        system.debug('~~~~~~ Start of test_randomizeList');
        system.runAs(userAdmin){  

            List<String> lstStr = new List<String>();
            lstStr.add('qwerty');
            lstStr.add('1234');

            Test.startTest();
            //  ASPISServiceSubstitution.randomizeList(lstStr);
              Test.stopTest();
   

        }

    }


    @isTest static void test_processAllTyresCrossRefs(){
        system.debug('~~~~~~ Start of test_processAllTyresCrossRefs');
        system.runAs(userAdmin){ 
            Test.startTest();
            // ASPISServiceSubstitution.processAllTyresCrossRefs(listDetailRule,listCrossReferences);
             Test.stopTest();
       }
    }


    @isTest static void test_filterTyresCrossRefs_Else(){
        system.debug('~~~~~ Start of test_filterTyresCrossRefs');
        system.runAs(userAdmin){ 

            Test.startTest();
            // ASPISServiceSubstitution.filterTyresCrossRefs(listDetailRule[30],listCrossReferences);
             Test.stopTest();


       }
    }


    @isTest static void test_checkPrefixOnPartNumber(){
        system.debug('~~~~~ Start of test_filterTyresCrossRefs');
        system.runAs(userAdmin){ 

            String partnumber = 'partNum';

            Test.startTest();
            ASPISServiceSubstitution.checkPrefixOnPartNumber(partnumber);
             Test.stopTest();

             

       }
    }


    @isTest static void test_getlowestPricedCrossref(){
        system.runAs(userAdmin){ 
          
            String prefType='B';


        

            Test.startTest();
            ASPISServiceSubstitution.getlowestPricedCrossref(listCrossReferences,prefType);
             Test.stopTest();

             

       }
    }



    @isTest static void test_rankingOfCrossRefs(){
        system.runAs(userAdmin){ 
          
          
            Test.startTest();
            ASPISServiceSubstitution.rankingOfCrossRefs(listCrossReferences);
             Test.stopTest();


       }
    }
    
        @isTest static void test_processObjForCanBeSubstituted(){
        system.runAs(userAdmin){ 
          listAssessments[0].EntityRules__c = 'FR299';
          update listAssessments;
            
            
          
            Test.startTest();

            ASPISServiceSubstitution.processObjForCanBeSubstituted(listAssessments[0]);
             Test.stopTest();


       }
    }





    
}