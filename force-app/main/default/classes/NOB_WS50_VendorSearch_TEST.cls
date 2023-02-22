/**
* Created by Hansraj Mohiputlall on 30/09/2020.
*/
/*
----------------------------------------------------------------------
-- - Name          : NOB_WS50_VendorSearch_TEST
-- - Author        : HMO
-- - Description   : Test class
--
-- Maintenance History:
--
-- Date           Name  Version   Remarks
-- -----------    ----  -------   ---------------------------------------
-- 30-SEPT-2020    HMO     1.0     Initial version
-- 27-NOV-2020     KPA     1.1
**********************************************************************
*/
@isTest
public class NOB_WS50_VendorSearch_TEST {
    static User userAdmin;
    static List<Account> lstAcc;
    static List<Contact> lstCon;
    static List<MasterRules__c> lstMRules;
    static List<DetailRule__c> listDetailRule;
    static List<NOB_Objective__c> lstObjective;
    static List<NOB_Planning__c> lstPlanning;
    static NOB_InterventionZone__c zoneD;
    static NOB_AccountRelationship__c relationCompte;
    static list <NOB_Objective__c> listObjectif;
    static List <NOB_AccountRelationship__c> lstRelationCompte;
    static List<Case> lstCase;
    static Case newCase;
    
    static{

        lstMRules = new List<MasterRules__c>();
        listDetailRule = new List<DetailRule__c>();
        lstObjective = new List<NOB_Objective__c>();
        lstPlanning = new List<NOB_Planning__c>();

        // creating user
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        insert userAdmin;

        Bypass__c bypass = new Bypass__c(BypassTrigger__c='AP05;AP07;AP08');
        insert bypass;

        List<NOB_ObjectifsValues__c> lstNOB_ObjectifsValues = new List<NOB_ObjectifsValues__c>{
            new NOB_ObjectifsValues__c(name ='Bronze',Score__c=24),
            new NOB_ObjectifsValues__c(name ='Gold',Score__c=99),
            new NOB_ObjectifsValues__c(name ='Réseau Platinium',Score__c=1),
            new NOB_ObjectifsValues__c(name ='Réseau Premium',Score__c=49),
            new NOB_ObjectifsValues__c(name ='Réseau Proximité',Score__c=24),
            new NOB_ObjectifsValues__c(name ='Silver',Score__c=49)
        };				
        insert lstNOB_ObjectifsValues;
        
        System.runAs(userAdmin){
            lstAcc = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Monkey','Réseau Premium', '44057565200035','Actif'),
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createInsurerAccount('Test 2','Bourgogne')
            };

            lstAcc[0].ShippingCountry = 'France';
            lstAcc[0].ShippingCountryCode = 'FR';
            lstAcc[0].ShippingLatitude = 59.127390000000000;
            lstAcc[0].ShippingLongitude = 3.177580000000000;
            lstAcc[0].ShippingStreet = '10 rue de la fontaine d’ascot';
            lstAcc[0].ShippingCity = 'Cléry-en-Vexin';
            lstAcc[0].ShippingPostalCode = '95420';
            lstAcc[0].NOB_Ranking__c = 'Gold';
            lstAcc[0].NOB_DateDebutPlageHoraire__c = System.today();
            lstAcc[0].NOB_DateFinPlageHoraire__c = System.today();
            lstAcc[0].NOB_Priorite__c = 'true';
            lstAcc[0].NOB_EngagementRate__c = 2;
            lstAcc[0].NOB_Statut__c = 'Actif';
            lstAcc[0].NOB_NetworkType__c = 'Réseau Platinium';
            lstAcc[0].NOB_SkillSet__c = '100000068';
            lstAcc[0].RecordTypeId = '012240000005tlRAAQ';
            lstAcc[0].NOB_TechZoneIntervention__c = '95420';
            lstAcc[0].BillingCity = 'Cléry-en-Vexin';
            lstAcc[0].BillingCountry='France';
            lstAcc[0].BillingStreet='10 rue de la fontaine d’ascot';
            lstAcc[0].BillingPostalCode='95420';
            lstAcc[0].BillingCountryCode = 'FR';
            lstAcc[0].BillingLatitude = 59.127390000000000;
            lstAcc[0].BillingLongitude = 3.177580000000000;
            lstAcc[1].NOB_CallerSystem__c = 'MACSF';
            lstAcc[1].NOB_KeyAccountId__c = '123456';
            lstAcc[2].NOB_CallerSystem__c = 'Solaris';
            lstAcc[2].NOB_KeyAccountId__c = '123456';
            insert lstAcc;

            //Create relation compte
            // relationCompte = new NOB_AccountRelationship__c(NOB_Compte__c = lstAcc[1].Id, NOB_Bodyshop__c = lstAcc[0].Id);
            // insert relationCompte;
            
          
            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstAcc[0].Id, lstAcc[1].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstAcc[0].Id, lstAcc[2].Id, 'Réparateur - Assureur')
            };
            lstRelationCompte[0].NOB_KAexternalid__c = 'KA00001';
            lstRelationCompte[1].NOB_KAexternalid__c = 'KA00002';
            insert lstRelationCompte;
            
            
            //Contact reparateur
            String ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Réparateur').getRecordTypeId();
            lstCon = new List<Contact>{
                
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '10 Rue de la Fontaine d’Ascot',
                            MailingCity = 'Cléry-en-Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstAcc[0].Id, 
                            RecordTypeId = ContactRecTypeId),
                    
                //Not same as request
                new Contact(LastName = 'Contact1', FirstName = 'Dummy', Phone = '23456869', MailingStreet = 'test',
                            MailingCity = 'test', MailingPostalCode = '1234',NOB_TECH_IsDummy__c = true, AccountId = lstAcc[0].Id,
                            RecordTypeId = ContactRecTypeId),
                
                //No Latitude and Longitude
                new Contact(LastName = 'Contact2', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '11 Rue de la Fontaine d’Ascot',
                                MailingCity = 'Clery-en-Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstAcc[0].Id, RecordTypeId = ContactRecTypeId ),
                
                //Contact Assureur
                TestFactory.createInsuredContact('Luffy', 'Monkey', lstAcc[1].Id, 'Nord'),
                TestFactory.createInsuredContact('Roronoa', 'Zoro', lstAcc[2].id,'Bourgogne')
                };

            lstCon[3].Phone = '77777777';
            lstCon[4].Phone = '88888888';
            insert lstCon;


            //Zone d'intervention
            zoneD = new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = lstAcc[0].Id);
            insert zoneD;

            Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month()-1, System.today().day(), 17, 00, 0);
            Datetime mydate2 = Datetime.newInstance(System.today().year(), System.today().month()-2, System.today().day(), 15, 00, 0);
            // newCase = TestFactory.createCaseStandard('Nouvelle', lstCon[3].Id, lstAcc[1].Id, 'NISS', 'GTR','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture');
            // newCase.NOB_SkillSet__c = 'Electrique';
            // insert newCase;

            lstCase = new List<Case>{
                newCase = TestFactory.createCaseStandard('Nouvelle', lstCon[3].Id, lstAcc[1].Id, 'NISS', 'GTR','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture'),
                newCase = TestFactory.createCaseStandard('Nouvelle', lstCon[3].Id, lstAcc[2].Id, 'NISS', 'GTR','1234987678vv7','test3', mydate2,'dc-09','Body3','Peinture')
            };
            lstCase[0].NOB_SkillSet__c = 'Electrique';
            lstCase[1].NOB_SkillSet__c = 'Electrique';
            insert lstCase;


            //Creating custom setting
            NOB_ObjectifsValues__c objValues = new NOB_ObjectifsValues__c();
            objValues.Name = 'NOB_ObjectifsValues';
            objValues.Score__c = 0;
            insert objValues;

            //Master rule insertion
            MasterRules__c mr1 = TestFactory.createMasterRule('TestNob', 'NOB_Recherche Réparateur', 'Case');
            mr1.FilterLogic__c = '(#1 AND #2 AND #3 AND ((#4 AND #9) OR (#7 AND #8)) AND #5 AND #6 AND #10)';
            lstMRules.add(mr1);
            insert lstMRules;
            
            DetailRule__c dr1 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_SkillSet__c', 'INCLUDES', 'NOB_SkillSet__c', 'Filter Condition', 'Account', 1); //OK
            dr1.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_NetworkType__c', 'NOT_EQUALS', 'Hors réseau', 'Filter Condition', 'Account', 2); //OK
            dr2.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr2);
            
            DetailRule__c dr3 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'RecordTypeId', 'EQUALS', '012240000005tlRAAQ', 'Filter Condition', 'Account', 3); //OK
            dr3.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr3);

            DetailRule__c dr4 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'shippingAddress', 'LESS', 'NOB_ContactPickup__r.MailingLatitude,NOB_ContactPickup__r.MailingLongitude', 'Filter Condition', 'Account', 4); //
            dr4.ValueFrom__c = 'Master sObject';
            dr4.NOB_RangeValue__c = '60';
            listDetailRule.add(dr4);

            DetailRule__c dr5 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_Statut__c', 'EQUALS', 'Actif', 'Filter Condition', 'Account', 5);
            dr5.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr5);

            DetailRule__c dr6 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'Name', 'NOT_EQUALS', 'null', 'Filter Condition', 'Account', 6);
            dr6.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr6);

            DetailRule__c dr7 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'Id IN (SELECT NOB_Account__c FROM NOB_InterventionZone__c WHERE NOB_PostalCode__c =', 'INNER', 'NOB_ContactPickup__r.MailingPostalCode', 'Filter Condition', 'Account', 7);
            dr7.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr7);
            
            DetailRule__c dr8 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_NetworkType__c', 'IN','Réseau Platinium,Réseau Premium', 'Filter Condition', 'Account', 8);
            dr8.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr8);

            DetailRule__c dr9 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_NetworkType__c', 'NOT_IN','Réseau Platinium,Réseau Premium', 'Filter Condition', 'Account', 9);
            dr9.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr9);

            //HMO --25-11-2020
            DetailRule__c dr10 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'Id IN (SELECT NOB_Bodyshop__c FROM NOB_AccountRelationship__c WHERE PFR_Inactive__c=false AND NOB_Compte__c =', 'INNER','NOB_BusinessProvider__c', 'Filter Condition', 'Account', 10);
            dr10.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr10);

            DetailRule__c dr11 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'Id, BillingAddress, BillingCity, BillingCountry, BillingStreet, BillingLatitude, BillingLongitude, BillingPostalCode, BillingState, Name, NOB_DateDebutPlageHoraire__c, NOB_DateFinPlageHoraire__c, NOB_Priorite__c, NOB_EngagementRate__c, NOB_BodyshopStatus__c, NOB_ExternalId__c, NOB_Tech_RankingNumeric__c, NOB_Ranking__c, NOB_Reparateur__c, NOB_Statut__c, Phone, NOB_TauxEngagement__c, NOB_NetworkType__c, NOB_SkillSet__c,ReferenceNumber__c, VATNumber__c, NOB_EmailAddress__c, RecordTypeId, (Select Id, NOB_tech_DiffHeure__c, NOB_StartDate__c, NOB_EndDate__c, NOB_Status__c, NOB_ExternalId__c, NOB_WorkOrder__c, NOB_Quantity__c from Disponibilite__r Where NOB_StartDate__c >= TODAY And NOB_EndDate__c <=  Next_N_Days:7 And NOB_Status__c = \'Disponible\'  and IsDelete__c = false order by   NOB_EndDate__c asc, NOB_tech_DiffHeure__c asc, NOB_ExternalId__c  asc)', null, null, 'Primary Fields Needed', 'Account', null);
            listDetailRule.add(dr11);

            DetailRule__c dr12 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_DateDebutPlageHoraire__c', 'GREATER_EQUALS', 'TODAY', 'Criteria', 'Account', null);
            dr12.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr12);

            DetailRule__c dr13 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_DateFinPlageHoraire__c', 'GREATER_EQUALS', 'Next_N_Days:7', 'Criteria', 'Account', null);
            dr13.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr13);
            
            DetailRule__c dr14 = TestFactory.createDetailRule('Recherche Réparateur', lstMRules[0], 'NOB_Priorite__c', 'EQUALS', 'true', 'Criteria', 'Account', null);
            dr14.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr14);
            insert listDetailRule;
            System.debug('£££ DETAIL RULE INSERTED'+ listDetailRule);
            
            //create Objectives
            lstObjective.add(TestFactory.createObjective(lstMRules[0], 'Distance', 'Distance', 'Account', 'sObject', 3, 'Distance', 'Min'));
            lstObjective.add(TestFactory.createObjective(lstMRules[0], 'Disponibility', 'NOB_StartDate__c', 'Disponibilite__r', 'Child', 4, 'Date/Time', 'Min'));
            lstObjective.add(TestFactory.createObjective(lstMRules[0], 'Ranking', 'NOB_Ranking__c', 'Account', 'sObject', 4, 'Custom setting', 'Max'));
            lstObjective.add(TestFactory.createObjective(lstMRules[0], 'Type Réseau', 'NOB_NetworkType__c', 'Account', 'sObject', 100, 'Custom setting', 'Max'));
            lstObjective.add(TestFactory.createObjective(lstMRules[0], 'Taux', 'NOB_EngagementRate__c', 'Account', 'sObject', 2, 'Numeric', 'Min'));
            insert lstObjective;
            System.debug('£££ lstObjective INSERTED'+ lstObjective);
            
            //Create PLanning
            for (integer i =0; i < 3; i++){
                lstPlanning.add(TestFactory.createPlanning(lstAcc[0].Id));
            }
            lstPlanning[0].NOB_StartDate__c = DateTime.newInstance(2021, 12, 12, 09,00,0);
            lstPlanning[0].NOB_EndDate__c = DateTime.newInstance(2021, 12, 12, 10, 00, 0);
            lstPlanning[0].NOB_Status__c = 'Disponible';
            lstPlanning[0].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            
            lstPlanning[1].NOB_StartDate__c = DateTime.newInstance(2021, 12, 12, 11,30,0);
            lstPlanning[1].NOB_EndDate__c = DateTime.newInstance(2021, 12, 12, 12,30,0);
            lstPlanning[1].NOB_Status__c = 'Disponible';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            
            lstPlanning[2].NOB_StartDate__c = DateTime.newInstance(2021, 12, 12, 12,00,0);
            lstPlanning[2].NOB_EndDate__c = DateTime.newInstance(2021, 12, 12, 13,00,0);
            lstPlanning[2].NOB_Status__c = 'Disponible';
            lstPlanning[2].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            insert lstPlanning;
        }
    }
    
    //************************************************************************************ */
    @isTest
    public static void testSolaris(){
        System.debug('£££ START OF METHOD testSolaris');
        System.runAs(userAdmin){

            NOB_WS50_VendorSearch.requestDetails req = new NOB_WS50_VendorSearch.requestDetails();
            req.addrCity = 'Cléry-en-Vexin';
            req.addrLine1 = '10 Rue de la Fontaine d’Ascot';
            req.addrLine2 = '';
            req.addrPostCode = '95420';
            req.capabilities = '100000068,30';
            req.maxReturn = 4;
            req.capacityScope = '1';
            req.courtesyCar = true;
            req.keyAccountID = '123456';
            req.searchType = '12345';
            req.startDate = DateTime.newInstance(2021,12,12);
            req.endDate = DateTime.newInstance(2021, 12, 12);
            String body = JSON.serialize(req);

            // String body = '{"addrCity":"Cléry-en-Vexin","addrLine1":"10 Rue de la Fontaine d’Ascot","addrLine2":"","addrPostCode":"95420","maxReturn":"10","startDate":"2021-10-28","capabilities":"30"}';    

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            lstCon[0].MailingLatitude = 59.12739;
            lstCon[0].MailingLongitude = 3.17758;
            update lstCon[0];
            NOB_WS50_VendorSearch.processRequest();
            Test.stopTest();
            
            String fakeResponse = response.responseBody.toString();
            System.assert(fakeResponse != null);
            System.debug('£££ fakeResponse '+fakeResponse);
            System.debug('£££ END OF METHOD testSolaris');
        }
    }
    
    
    @isTest
    public static void testCreateInstanceSolaris(){
        System.runAs(userAdmin){
            Test.startTest();
            Account acc = [Select Id, BillingAddress, BillingCity, BillingCountry, BillingStreet, BillingLatitude, BillingLongitude, BillingPostalCode, BillingState, Name, NOB_DateDebutPlageHoraire__c, 
NOB_DateFinPlageHoraire__c, NOB_Priorite__c, NOB_EngagementRate__c, NOB_BodyshopStatus__c, NOB_ExternalId__c, NOB_Tech_RankingNumeric__c, NOB_Ranking__c, NOB_Reparateur__c, 
NOB_Statut__c, Phone, NOB_TauxEngagement__c, NOB_NetworkType__c, NOB_SkillSet__c, ReferenceNumber__c, VATNumber__c, NOB_EmailAddress__c, RecordTypeId, 
 DISTANCE(billingaddress, GEOLOCATION( 48.832910000000000 , 2.369985000000000), 'km')Distance From Account LIMIT 1];
           
           NOB_WS50_VendorSearch.axaSlotsSolaris solari = NOB_WS50_VendorSearch.createInstanceSolaris(acc, Datetime.now().format(), 2, 'Solaris', 2);
            
            acc.BillingLatitude = null;
            acc.BillingLongitude = null;
            NOB_WS50_VendorSearch.axaSlotsMACSF macsf = NOB_WS50_VendorSearch.createInstanceMACSF(acc, Datetime.now().format(), 2, 'MACSF', 2, lstRelationCompte[0].NOB_KAexternalid__c);
            System.debug(JSON.serialize(solari));
            Test.stopTest();
        }
    }
    //****************************************************************************** */
    
    
    // @isTest
    // public static void requestBodyFail(){
    //     System.runAs(userAdmin){
    //     String body = 'INVALID_JSON';
    //     RestRequest request = new RestRequest();
    //     RestResponse response = new RestResponse();
    //     request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
    //     request.httpMethod = 'POST';
    //     request.requestBody = Blob.valueof(body);
    //     RestContext.request = request;
    //     RestContext.response = response;

    //     Test.startTest();
    //     NOB_WS50_VendorSearch.processRequest();
    //     Test.stopTest();

    //     String fakeResponse = response.responseBody.toString();
    //     System.assert(fakeResponse != null);
    //     System.debug('£££ fakeResponse '+fakeResponse);
    //     }
    // }

    
    @isTest
    public static void testInvalidResponseSolaris(){
        System.debug('£££ START OF METHOD testInvalidResponseSolaris');
        System.runAs(userAdmin){
            String body = '{"addrCity":"Clery-en-Vexin","addrLine1":"9 Rue de la Fontaine d’Ascot","addrLine2":"","addrPostCode":"12345","maxReturn":"10","startDate":"2021-10-28","capabilities":"30"}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            NOB_WS50_VendorSearch.processRequest();
            Test.stopTest();
            
            String fakeResponse = response.responseBody.toString();
            System.assert(fakeResponse != null);
            System.debug('£££ END OF METHOD testInvalidResponseSolaris');
        }
    }
    
    @isTest
    public static void testNoVendorFoundSolaris(){
        System.debug('£££ START OF testNoVendorFoundSolaris');
        System.runAs(userAdmin){
            String body = '{"addrCity":"Clery-en-Vexin","addrLine1":"9 Rue de la Fontaine d’Ascot","addrLine2":"","addrPostCode":"95420","maxReturn":"4","startDate":"2021-10-26","capabilities":"30"}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            NOB_WS50_VendorSearch.processRequest();
            Test.stopTest();
            
            String fakeResponse = response.responseBody.toString();
            System.assert(fakeResponse != null);
            System.debug('£££ fakeResponse '+fakeResponse);
            System.debug('£££ END OF METHOD testNoVendorFoundSolaris');
        }
    }
    
    
    
    @isTest
    public static void testMACSF(){
        System.debug('£££ START OF METHOD testMACSFRest');
        System.runAs(userAdmin){
            NOB_WS50_VendorSearch.requestDetails req = new NOB_WS50_VendorSearch.requestDetails();
            req.addrCity = 'Cléry-en-Vexin';
            req.addrLine1 = '10 Rue de la Fontaine d’Ascot';
            req.addrLine2 = '';
            req.addrPostCode = '95420';
            req.capabilities = '100000068';
            req.maxReturn = 4;
            req.capacityScope = '1';
            req.courtesyCar = true;
            req.keyAccountID = '123456';
            req.searchType = '12345';
            req.startDate = DateTime.newInstance(2021,12,12);
            req.endDate = DateTime.newInstance(2021, 12, 12);
            String body = JSON.serialize(req);
                //'{"addrCity":"Cléry-en-Vexin","addrLine1":"10 Rue de la Fontaine d’Ascot","addrLine2":"","addrPostCode":"95420",
                //"capabilities":"100000068,30","maxReturn":"4","capacityScope":"1","courtesyCar":true,"keyAccountID":"123456","searchType":"12345", "startDate": "29/01/2021"}';
            
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            // lstCon[4].MailingCity = 'Cléry-en-Vexin';
            // lstCon[4].MailingStreet = '10 Rue de la Fontaine d’Ascot';
            // lstCon[4].MailingLatitude = 49.12739;
            // lstCon[4].MailingLongitude = 1.84254;

            lstCon[0].MailingLatitude = 59.12739;
            lstCon[0].MailingLongitude = 3.17758;
            update lstCon[0];
            
            NOB_WS50_VendorSearch.processRequest();
            Test.stopTest();
            
            String fakeResponse = response.responseBody.toString();
            System.assert(fakeResponse != null);
            System.debug('£££ fakeResponse '+fakeResponse);
            System.debug('£££ END OF METHOD testMACSFRest');
        }
    }

    @isTest
    public static void testCompetenceInvalid(){
        System.runAs(userAdmin){
            String body = '{"addrCity":"Cléry-en-Vexin","addrLine1":"10 Rue de la Fontaine d’Ascot","addrLine2":"","addrPostCode":"95420","capabilities":"888","maxReturn":"4","capacityScope":"1","courtesyCar":true,"keyAccountID":"123456","searchType":"12345"}';
            
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/v1.0/getPlanning/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            lstCon[4].MailingCity = 'Clery-en-Vexin';
            lstCon[4].MailingStreet = '9 Rue de la Fontaine d’Ascot';
            lstCon[4].MailingLatitude = 49.12739;
            lstCon[4].MailingLongitude = 1.84254;
            update lstCon[4];
            NOB_WS50_VendorSearch.processRequest();
            Test.stopTest();
            
            String fakeResponse = response.responseBody.toString();
            System.assert(fakeResponse != null);
        }
    }
    
    @isTest
    public static void testgetAllCompetences(){
      System.debug('Start of testgetAllCompetences');
        System.runAs(userAdmin){
           Test.startTest();
            NOB_WS50_VendorSearch.getAllCompetences();
            Test.stopTest();
         System.debug('Stop of testgetAllCompetences');
       }
    }
}