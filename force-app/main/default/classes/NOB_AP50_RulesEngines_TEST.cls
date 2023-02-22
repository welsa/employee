/*
  ------------------------------------------------------------------------
  -- - Name          : NOB_AP50_RulesEngines_TEST
  -- - Author        : DUN
  -- - Description   : Test class for rules engine
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   --------------------------------------
  -- 28-AUG-2020    DUN     1.0     Initial version
  -- 21-OCT-2020    HMO     1.1     Modified version - #Ticket:RSIW 550
  ************************************************************************
*/
@isTest
private class NOB_AP50_RulesEngines_TEST {
    
    static User userAdmin;
    static list<Account> listAccount;
    static List<Contact> lstContact;
    static Case newCase;
    static Map<String,List<String>> mapParameters;
    static Map<String,List<String>> mapParamEmptyDate;
    static map<String, List<String>> mapParamToday;
    static list <MasterRules__c> listMasterRule;
    static list <DetailRule__c> listDetailRule;
    static list <NOB_Objective__c> listObjectif;
    static List<NOB_Planning__c> lstPlanning;
    static List<Account> lstInsurerAccount;
    static List<Account> lstResult;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static NOB_InterventionZone__c zoneD;
    //
    static Account bodyshopAcc;

    static {
        listAccount = new list <Account>();
        listMasterRule = new list <MasterRules__c>();
        listDetailRule = new list <DetailRule__c>();
        listObjectif = new list <NOB_Objective__c>();
        lstPlanning = new List<NOB_Planning__c>();
        //
        bodyshopAcc = new Account();

        

        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        
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

        system.runAs(userAdmin){
            lstInsurerAccount = new List<Account>{
                TestFactory.createInsurerAccount('testAccAssure', '49492059811')
            };
            insert lstInsurerAccount;
           
            bodyshopAcc = TestFactory.createPrefikarBodyAccount('BodyShop_ScTest1','', '49492059811', 'actif');
            bodyshopAcc.ShippingCountry = 'France';
            bodyshopAcc.ShippingCountryCode = 'FR';
            bodyshopAcc.ShippingLatitude = 49.12739;
            bodyshopAcc.ShippingLongitude = 2.17758;
            bodyshopAcc.ShippingStreet = '9 rue de la fontaine d’ascot';
            bodyshopAcc.ShippingCity = 'Clery en Vexin';
            bodyshopAcc.ShippingPostalCode = '95420';
            bodyshopAcc.NOB_Ranking__c = 'Silver';
            bodyshopAcc.NOB_DateDebutPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bodyshopAcc.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            bodyshopAcc.NOB_Priorite__c = 'Priorisé';
            bodyshopAcc.NOB_EngagementRate__c = 2;
            bodyshopAcc.NOB_Statut__c = 'Actif';
            bodyshopAcc.NOB_NetworkType__c = 'Réseau Platinium';
            bodyshopAcc.NOB_SkillSet__c = 'Electrique';
            bodyshopAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bodyshopAcc.NOB_TechZoneIntervention__c = '95420;';
            insert bodyshopAcc;

            //Create relation compte
            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(bodyshopAcc.Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur')
            };
            insert lstRelationCompte;

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Categories__c='';
            listAccount.add(dist1);
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist2.Categories__c='';
            listAccount.add(dist2);

            Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR');
            dist3.Categories__c='';
            listAccount.add(dist3);
            
            Account dist4 = TestFactory.createAccountDistributor('Distributor_ScTest4', 'FR');
            dist4.Categories__c='';
            listAccount.add(dist4);

            insert listAccount;


            Id ContactRecTypeIdRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            Id ContactRecTypeIdAssure = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Fiche_Assure').getRecordTypeId();

            lstContact = new List<Contact>{
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '9 rue de la fontaine d’ascot',
                MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = bodyshopAcc.Id, RecordTypeId = ContactRecTypeIdRep, MailingLatitude = 49.12739, MailingLongitude =2.17758),
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '9 rue de la fontaine d’ascot',
                MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstInsurerAccount[0].Id, RecordTypeId = ContactRecTypeIdAssure, MailingLatitude = 49.12739, MailingLongitude = 1.84254)
            };
            insert lstContact;

            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(bodyshopAcc.Id),
                TestFactory.createPlanning(bodyshopAcc.Id),
                TestFactory.createPlanning(bodyshopAcc.Id)
            };
            
            lstPlanning[0].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 16, 00, 0);
            lstPlanning[0].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 17, 00, 0);
            lstPlanning[0].NOB_Status__c = 'Disponible';
            lstPlanning[0].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            
            lstPlanning[1].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 12, 00, 0);
            lstPlanning[1].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 13, 00, 0);
            lstPlanning[1].NOB_Status__c = 'Disponible';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();

            lstPlanning[2].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 17, 00, 0);
            lstPlanning[2].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 18, 00, 0);
            lstPlanning[2].NOB_Status__c = 'Disponible';
            lstPlanning[2].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            insert lstPlanning;

            mapParameters = new Map<String, List<String>>();
            mapParameters.put('Distance', new List<string>(new string[] {'latitude-'+lstContact[0].MailingLatitude, 'Longitude-'+lstContact[0].MailingLongitude}));
            String skillSet = 'NOB_SkillSet__c-Not_Equals-null';
            mapParameters.put('Account', new list<string>(new string[] {skillSet}));
            mapParameters.put('limit', new list<string>(new string[] {String.ValueOf(10)}));

            Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month()-1, System.today().day(), 17, 00, 0);
            newCase = TestFactory.createCaseStandard('Nouvelle', lstContact[1].Id, lstInsurerAccount[0].Id, 'NISS', 'GTR','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture');
            newCase.NOB_SkillSet__c = 'Electrique';
            insert newCase;

            //Creating custom setting
            NOB_ObjectifsValues__c objValues = new NOB_ObjectifsValues__c();
            objValues.Name = 'NOB_ObjectifsValues';
            objValues.Score__c = 0;
            insert objValues;


            //Zone d'intervention
            zoneD = new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = bodyshopAcc.Id);
            insert zoneD;

            MasterRules__c mr1 = TestFactory.createMasterRule('TestNob', 'NOB_Recherche Réparateur', 'Case');
            mr1.FilterLogic__c = '(#1 AND #2 AND #3 AND ((#4 AND #9) OR (#7 AND #8)) AND #5 AND #6 AND #10)';
            // mr1.FilterLogic__c = '(#1 AND #2 )';
            //mr1.FilterLogic__c = '(#1)';
            listMasterRule.add(mr1);
            insert listMasterRule;

            DetailRule__c dr1 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_SkillSet__c', 'INCLUDES', 'NOB_SkillSet__c', 'Filter Condition', 'Account', 1); //OK
            dr1.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_NetworkType__c', 'NOT_EQUALS', 'Hors réseau', 'Filter Condition', 'Account', 2); //OK
            dr2.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr2);
            
            DetailRule__c dr3 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'RecordTypeId', 'EQUALS', '012240000005tlRAAQ', 'Filter Condition', 'Account', 3); //OK
            dr3.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr3);

            DetailRule__c dr4 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'shippingAddress', 'LESS', 'NOB_ContactPickup__r.MailingLatitude,NOB_ContactPickup__r.MailingLongitude', 'Filter Condition', 'Account', 4); //
            dr4.ValueFrom__c = 'Master sObject';
            dr4.NOB_RangeValue__c = '60';
            listDetailRule.add(dr4);

            DetailRule__c dr5 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_Statut__c', 'EQUALS', 'Actif', 'Filter Condition', 'Account', 5);
            dr5.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr5);

            DetailRule__c dr6 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'Name', 'NOT_EQUALS', 'null', 'Filter Condition', 'Account', 6);
            dr6.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr6);

            DetailRule__c dr7 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'Id IN (SELECT NOB_Account__c FROM NOB_InterventionZone__c WHERE NOB_PostalCode__c =', 'INNER', 'NOB_ContactPickup__r.MailingPostalCode', 'Filter Condition', 'Account', 7);
            dr7.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr7);
            
            
            DetailRule__c dr8 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_NetworkType__c', 'IN','Réseau Platinium,Réseau Premium', 'Filter Condition', 'Account', 8);
            dr8.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr8);

            DetailRule__c dr9 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_NetworkType__c', 'NOT_IN','Réseau Platinium,Réseau Premium', 'Filter Condition', 'Account', 9);
            dr9.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr9);

            //HMO --25-11-2020
            DetailRule__c dr10 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'Id IN (SELECT NOB_Bodyshop__c FROM NOB_AccountRelationship__c WHERE NOB_Compte__c =', 'INNER','NOB_BusinessProvider__c', 'Filter Condition', 'Account', 10);
            dr10.ValueFrom__c = 'Master sObject';
            listDetailRule.add(dr10);

            DetailRule__c dr11 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'Id, BillingAddress, BillingCity, BillingCountry, BillingStreet, BillingLatitude, BillingLongitude, BillingPostalCode, BillingState, Name, NOB_DateDebutPlageHoraire__c, NOB_DateFinPlageHoraire__c, NOB_Priorite__c, NOB_EngagementRate__c, NOB_BodyshopStatus__c, NOB_ExternalId__c, NOB_Tech_RankingNumeric__c, NOB_Ranking__c, NOB_Reparateur__c, NOB_Statut__c, Phone, NOB_TauxEngagement__c, NOB_NetworkType__c, NOB_SkillSet__c, ReferenceNumber__c, VATNumber__c, NOB_EmailAddress__c, RecordTypeId, (Select Id, NOB_tech_DiffHeure__c, NOB_StartDate__c, NOB_EndDate__c, NOB_Status__c, NOB_ExternalId__c, NOB_WorkOrder__c, NOB_Quantity__c from Disponibilite__r Where NOB_StartDate__c >= TODAY And NOB_EndDate__c <=  Next_N_Days:7 And NOB_Status__c = \'Disponible\'  and IsDelete__c = false order by   NOB_EndDate__c asc, NOB_tech_DiffHeure__c asc, NOB_ExternalId__c  asc)', null, null, 'Primary Fields Needed', 'Account', null);
            listDetailRule.add(dr11);

            DetailRule__c dr12 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_DateDebutPlageHoraire__c', 'LESS_EQUALS', 'TODAY', 'Criteria', 'Account', null);
            dr12.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr12);

            DetailRule__c dr13 = TestFactory.createDetailRule('Recherche Réparateur', listMasterRule[0], 'NOB_DateFinPlageHoraire__c', 'GREATER_EQUALS', 'Next_N_Days:7', 'Criteria', 'Account', null);
            dr13.ValueFrom__c = 'Criteria sObject';
            listDetailRule.add(dr13);

            // insert listDetailRule;

            NOB_Objective__c obj1 = TestFactory.createObjective(listMasterRule[0], 'Distance', 'Distance', 'Account', 'SOBJECT', 3, 'Distance', 'MIN');
            obj1.NOB_Limit__c = '60';
            listObjectif.add(obj1);

            NOB_Objective__c obj2 = TestFactory.createObjective(listMasterRule[0], 'Disponibility', 'NOB_StartDate__c', 'Disponibilite__r', 'CHILD', 3, 'DATE/TIME', 'MIN');
            obj2.NOB_Limit__c = '20160';
            listObjectif.add(obj2);
            
            NOB_Objective__c obj3 = TestFactory.createObjective(listMasterRule[0], 'Ranking', 'NOB_Ranking__c', 'Account', 'SOBJECT', 4, 'CUSTOM SETTING', 'MAX');
            obj3.NOB_Limit__c = '';
            listObjectif.add(obj3);
            
            NOB_Objective__c obj4 = TestFactory.createObjective(listMasterRule[0], 'Type Réseau', 'NOB_NetworkType__c', 'Account', 'SOBJECT', 5, 'CUSTOM SETTING', 'MAX');
            obj4.NOB_Limit__c = '';
            listObjectif.add(obj4);

            NOB_Objective__c obj5 = TestFactory.createObjective(listMasterRule[0], 'Taux', 'NOB_EngagementRate__c', 'Account', 'SOBJECT', 2, 'Numeric', 'MIN');
            obj2.NOB_Limit__c = '100';
            listObjectif.add(obj5);
            insert listObjectif;
    

        }
    }  

    
    @isTest
    public static void testReparateurIsPriority(){
        System.runAs(userAdmin){
            Test.startTest();
                String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
                String receivedEndDate =  System.now().day() + '/' +System.now().month()+'/'+System.now().year();
                // String receivedEndDate =  System.now().year()+'/'+System.now().month()+'/'+System.now().day();
                mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));

                insert listDetailRule;

                lstResult = NOB_AP50_RulesEngines.getReparateur(newCase.Id, mapParameters);
                Test.stopTest();
           // System.assertEquals(0, lstResult.size());
            System.assertNotEquals(0, lstResult.size());
        }
    }
//------
    @isTest
    public static void testReparateurNotPriority(){
        System.runAs(userAdmin){
            Test.startTest();
              
                bodyshopAcc.NOB_DateDebutPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
                bodyshopAcc.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            	bodyshopAcc.NOB_Priorite__c = 'Dé-priorisé';
            	update bodyshopAcc;
              
                String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
                String receivedEndDate = System.now().addDays(6).day()+ '/' +System.now().month()+'/'+System.now().year();

                mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));

                insert listDetailRule;

                lstResult = NOB_AP50_RulesEngines.getReparateur(newCase.Id, mapParameters);
            Test.stopTest();
            //System.assertEquals(0, lstResult.size());
            System.assertNotEquals(0, lstResult.size());
        }
    }
//------
    @isTest
    public static void testReparateurNull(){
        System.runAs(userAdmin){
            Test.startTest();
              
                 String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
                 //String receivedEndDate = '29/09/2020';
                 String receivedDate = System.now().addDays(7).day()+ '/' +System.now().month()+'/'+System.now().year();
              //  mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedDate}));

                insert listDetailRule;

                lstResult = NOB_AP50_RulesEngines.getReparateur(newCase.Id, mapParameters);

            Test.stopTest();
             // System.assertEquals(0, lstResult.size());
            System.assertNotEquals(0, lstResult.size());
        }
    }
//-----
    @isTest
    public static void testReparateurDateToday(){
        System.runAs(userAdmin){
            Test.startTest();
                listAccount[0].NOB_DateDebutPlageHoraire__c = Date.newInstance(system.today().year(), system.today().month(), system.today().day()+1);
                listAccount[0].NOB_DateFinPlageHoraire__c = Date.newInstance(system.today().year(), system.today().month(), system.today().day()+2);
                update listAccount;

                bodyshopAcc.NOB_DateDebutPlageHoraire__c = null;
                bodyshopAcc.NOB_DateFinPlageHoraire__c = null;
            	bodyshopAcc.NOB_Priorite__c = 'Aucune';
            	update bodyshopAcc;

                String receivedStartDate = system.now().day()+'/'+system.now().month()+'/'+system.now().year();
                String receivedEndDate = system.now().addDays(7).day() + '/' + system.now().addDays(7).month() + '/' + system.now().addDays(7).year();
                mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));

                insert listDetailRule;

                lstResult = NOB_AP50_RulesEngines.getReparateur(newCase.Id, mapParameters);
            Test.stopTest();
             // System.assertEquals(0, lstResult.size());
           System.assertNotEquals(0, lstResult.size());
        }
    } 
    
    
     @isTest
    public static void testMultipleReparateur(){
        System.runAs(userAdmin){
            Test.startTest();
                listAccount[0].NOB_DateDebutPlageHoraire__c = Date.newInstance(system.today().year(), system.today().month(), system.today().day()+1);
                listAccount[0].NOB_DateFinPlageHoraire__c = Date.newInstance(system.today().year(), system.today().month(), system.today().day()+2);
                update listAccount;
            
                bodyshopAcc.NOB_DateDebutPlageHoraire__c = null;
                bodyshopAcc.NOB_DateFinPlageHoraire__c = null;
            	bodyshopAcc.NOB_Priorite__c = 'Aucune';
            	update bodyshopAcc;
            
            List<Account> listAccBs = new List<Account>();
            Account bs1 = TestFactory.createPrefikarBodyAccount('Bs1','', '49492059811', 'actif');
            bs1.ShippingCountry = 'France';
            bs1.ShippingCountryCode = 'FR';
            bs1.ShippingLatitude = 49.12739;
            bs1.ShippingLongitude = 2.17758;
            bs1.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs1.ShippingCity = 'Clery en Vexin';
            bs1.ShippingPostalCode = '95420';
            bs1.NOB_Ranking__c = 'Silver';
            bs1.NOB_DateDebutPlageHoraire__c =  null;
            bs1.NOB_DateFinPlageHoraire__c = null;
            bs1.NOB_Priorite__c = 'Aucune';
            bs1.NOB_EngagementRate__c = 2;
            bs1.NOB_Statut__c = 'Actif';
            bs1.NOB_NetworkType__c = 'Réseau Platinium';
            bs1.NOB_SkillSet__c = 'Electrique';
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs1.NOB_TechZoneIntervention__c = '95420;';
            listAccBs.add(bs1);
            
            Account bs2 = TestFactory.createPrefikarBodyAccount('Bs2','', '49492059812', 'actif');
            bs2.ShippingCountry = 'France';
            bs2.ShippingCountryCode = 'FR';
            bs2.ShippingLatitude = 49.12739;
            bs2.ShippingLongitude = 2.17758;
            bs2.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs2.ShippingCity = 'Clery en Vexin';
            bs2.ShippingPostalCode = '95421';
            bs2.NOB_Ranking__c = 'Silver';
            bs2.NOB_DateDebutPlageHoraire__c =  Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bs2.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            bs2.NOB_Priorite__c = 'Priorisé';
            bs2.NOB_EngagementRate__c = 2;
            bs2.NOB_Statut__c = 'Actif';
            bs2.NOB_NetworkType__c = 'Réseau Platinium';
            bs2.NOB_SkillSet__c = 'Electrique';
            bs2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs2.NOB_TechZoneIntervention__c = '95420;';
            listAccBs.add(bs2);
            
            Account bs3 = TestFactory.createPrefikarBodyAccount('Bs3','', '49492059813', 'actif');
            bs3.ShippingCountry = 'France';
            bs3.ShippingCountryCode = 'FR';
            bs3.ShippingLatitude = 49.12739;
            bs3.ShippingLongitude = 2.17758;
            bs3.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs3.ShippingCity = 'Clery en Vexin';
            bs3.ShippingPostalCode = '95421';
            bs3.NOB_Ranking__c = 'Silver';
            bs3.NOB_DateDebutPlageHoraire__c =  Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bs3.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            bs3.NOB_Priorite__c = 'Priorisé';
            bs3.NOB_EngagementRate__c = 2;
            bs3.NOB_Statut__c = 'Actif';
            bs3.NOB_NetworkType__c = 'Réseau Platinium';
            bs3.NOB_SkillSet__c = 'Electrique';
            bs3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs3.NOB_TechZoneIntervention__c = '95420;';
            listAccBs.add(bs3);
            
            Account bs4 = TestFactory.createPrefikarBodyAccount('Bs4','', '49492059814', 'actif');
            bs4.ShippingCountry = 'France';
            bs4.ShippingCountryCode = 'FR';
            bs4.ShippingLatitude = 49.12739;
            bs4.ShippingLongitude = 2.17758;
            bs4.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs4.ShippingCity = 'Clery en Vexin';
            bs4.ShippingPostalCode = '95421';
            bs4.NOB_Ranking__c = 'Silver';
            bs4.NOB_DateDebutPlageHoraire__c =  Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bs4.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            bs4.NOB_Priorite__c = 'Dé-priorisé';
            bs4.NOB_EngagementRate__c = 2;
            bs4.NOB_Statut__c = 'Actif';
            bs4.NOB_NetworkType__c = 'Réseau Platinium';
            bs4.NOB_SkillSet__c = 'Electrique';
            bs4.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs4.NOB_TechZoneIntervention__c = '95420;';
            listAccBs.add(bs4);
            
            Account bs5 = TestFactory.createPrefikarBodyAccount('Bs5','', '49492059815', 'actif');
            bs5.ShippingCountry = 'France';
            bs5.ShippingCountryCode = 'FR';
            bs5.ShippingLatitude = 49.12739;
            bs5.ShippingLongitude = 2.17758;
            bs5.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs5.ShippingCity = 'Clery en Vexin';
            bs5.ShippingPostalCode = '95421';
            bs5.NOB_Ranking__c = 'Silver';
            bs5.NOB_DateDebutPlageHoraire__c =  Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bs5.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+15);
            bs5.NOB_Priorite__c = 'Dé-priorisé';
            bs5.NOB_EngagementRate__c = 2;
            bs5.NOB_Statut__c = 'Actif';
            bs5.NOB_NetworkType__c = 'Réseau Platinium';
            bs5.NOB_SkillSet__c = 'Electrique';
            bs5.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs5.NOB_TechZoneIntervention__c = '95420;';
            listAccBs.add(bs5);
            
            insert listAccBs;
            
            list<NOB_AccountRelationship__c> lstRelationCompte2 = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(listAccBs[0].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(listAccBs[1].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(listAccBs[2].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(listAccBs[3].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(listAccBs[4].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur')
                    
            };
            insert lstRelationCompte2;
            
                  List<NOB_InterventionZone__c> lstZoneD2 = new List<NOB_InterventionZone__c>{
                    new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = listAccBs[0].Id),
                    new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = listAccBs[1].Id),
                    new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = listAccBs[2].Id),
                    new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = listAccBs[3].Id),
                    new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = listAccBs[4].Id)
            };
      
          insert lstZoneD2;

                String receivedStartDate = system.now().day()+'/'+system.now().month()+'/'+system.now().year();
                String receivedEndDate = system.now().addDays(7).day() + '/' + system.now().addDays(7).month() + '/' + system.now().addDays(7).year();
                mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));

                insert listDetailRule;

                lstResult = NOB_AP50_RulesEngines.getReparateur(newCase.Id, mapParameters);
            Test.stopTest();
             // System.assertEquals(0, lstResult.size());
           System.assertNotEquals(0, lstResult.size());
        }
    }


}