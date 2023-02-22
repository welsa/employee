@isTest
public with sharing class NOB_AP50_SelectionReparateurTEST {
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
    static list <Case> lstCase;
    static list<Account> lstbodyshopAcc;

    static {
        listAccount = new list <Account>();
        listMasterRule = new list <MasterRules__c>();
        listDetailRule = new list <DetailRule__c>();
        listObjectif = new list <NOB_Objective__c>();
        lstPlanning = new List<NOB_Planning__c>();
        //
        lstbodyshopAcc = new List<Account>();

        

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
           
            Account bs1 = TestFactory.createPrefikarBodyAccount('BodyShop_ScTest1','', '49492059811', 'actif');
            bs1.ShippingCountry = 'France';
            bs1.ShippingCountryCode = 'FR';
            bs1.ShippingLatitude = 49.12739;
            bs1.ShippingLongitude = 2.17758;
            bs1.ShippingStreet = '9 rue de la fontaine d’ascot';
            bs1.ShippingCity = 'Clery en Vexin';
            bs1.ShippingPostalCode = '95420';
            bs1.NOB_Ranking__c = 'Silver';
            bs1.NOB_DateDebutPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
            bs1.NOB_DateFinPlageHoraire__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()+1);
            bs1.NOB_Priorite__c = 'Priorisé';
            bs1.NOB_EngagementRate__c = 2;
            bs1.NOB_Statut__c = 'Actif';
            bs1.NOB_NetworkType__c = 'Réseau Platinium';
            bs1.NOB_SkillSet__c = 'Electrique';
            bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId();
            bs1.NOB_TechZoneIntervention__c = '95420;';
            lstbodyshopAcc.add(bs1);
            insert lstbodyshopAcc;

            //Create relation compte
            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstbodyshopAcc[0].Id, lstInsurerAccount[0].Id, 'Réparateur - Assureur')
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
                            MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstbodyshopAcc[0].Id, RecordTypeId = ContactRecTypeIdRep, MailingLatitude = 49.12739, MailingLongitude =2.17758),
                new Contact(LastName = 'Contact', FirstName = 'Dummy', Phone = '12345678', MailingStreet = '9 rue de la fontaine d’ascot',
                MailingCity = 'Clery en Vexin', MailingPostalCode = '95420',NOB_TECH_IsDummy__c = true, AccountId = lstInsurerAccount[0].Id, RecordTypeId = ContactRecTypeIdAssure, MailingLatitude = 49.12739, MailingLongitude = 1.84254)
            };
            insert lstContact;

            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstbodyshopAcc[0].Id),
                    TestFactory.createPlanning(lstbodyshopAcc[0].Id),
                    TestFactory.createPlanning(lstbodyshopAcc[0].Id)
            };
            
            lstPlanning[0].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 16, 00, 0);
            lstPlanning[0].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 17, 00, 0);
            lstPlanning[0].NOB_Status__c = 'Réservé';
            lstPlanning[0].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            
            lstPlanning[1].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 12, 00, 0);
            lstPlanning[1].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 13, 00, 0);
            lstPlanning[1].NOB_Status__c = 'Réservé';
            lstPlanning[1].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();

            lstPlanning[2].NOB_StartDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 17, 00, 0);
            lstPlanning[2].NOB_EndDate__c = DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()+3, 18, 00, 0);
            lstPlanning[2].NOB_Status__c = 'Réservé';
            lstPlanning[2].RecordTypeId = Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get('Planning Prefikar').getRecordTypeId();
            insert lstPlanning;

            mapParameters = new Map<String, List<String>>();
            mapParameters.put('Distance', new List<string>(new string[] {'latitude-'+lstContact[0].MailingLatitude, 'Longitude-'+lstContact[0].MailingLongitude}));
            String skillSet = 'NOB_SkillSet__c-Not_Equals-null';
            mapParameters.put('Account', new list<string>(new string[] {skillSet}));
            mapParameters.put('limit', new list<string>(new string[] {String.ValueOf(10)}));

            Datetime mydate = Datetime.newInstance(System.today().year(), System.today().month()-1, System.today().day(), 17, 00, 0);
            lstCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', lstContact[1].Id, lstInsurerAccount[0].Id, 'NISS', 'GTR','123456gfdgjkhab','test2', mydate,'AR345','Body1','Peinture')
            };
            
            lstCase[0].NOB_SkillSet__c = 'Electrique';
            insert lstCase;

            //Creating custom setting
            NOB_ObjectifsValues__c objValues = new NOB_ObjectifsValues__c();
            objValues.Name = 'NOB_ObjectifsValues';
            objValues.Score__c = 0;
            insert objValues;


            //Zone d'intervention
            zoneD = new NOB_InterventionZone__c(NOB_PostalCode__c = '95420', NOB_Account__c = lstbodyshopAcc[0].Id);
            insert zoneD;

            MasterRules__c mr1 = TestFactory.createMasterRule('TestNob', 'NOB_Recherche Réparateur', 'Case');
            mr1.FilterLogic__c = '(#1 AND #2 AND #3 AND ((#4 AND #9) OR (#7 AND #8)) AND #5 AND #6 AND #10)';
         
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
    public static void testGetWhere(){
        System.runAs(userAdmin){
            Test.startTest();
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.DateTime,'IN','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.DateTime,'NOT_IN','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.DateTime,'INCLUDES','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.DateTime,'EXCLUDES','12/12/2020');
            
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.Integer,'IN','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.Integer,'NOT_IN','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.Integer,'INCLUDES','12/12/2020');
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.Integer,'EXCLUDES','12/12/2020');
            
            NOB_AP50_SelectionReparateur.getWhereConditionLine('username', Schema.DisplayType.CURRENCY,'EXCLUDES','12/12/2020');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void TESTSelectionRep(){
        System.runAs(userAdmin){

            system.debug('case##'+ lstCase[0].Id);
            Test.startTest();
                map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
                String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
                String receivedEndDate =  System.now().day() + '/' +System.now().month()+'/'+System.now().year();
                mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));

            insert listDetailRule;

            list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                                sObject__c, FilterLogic__c,version__c,Name,
                                                (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                                 OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
                                                 FROM DetailRules__r
                                                 ORDER BY Number__c ASC),
                                                (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
                                                 NOB_ValueType__c, NOB_Weightage__c, /* ASE: 03/11/20 : RSIW-2868 */ NOB_Limit__c
                                                 FROM Objectifs__r)
                                                FROM MasterRules__c
                                                WHERE Process__c    = 'NOB_Recherche Réparateur'
                                                AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];
            
            mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(lstCase[0].Id, masterRules[0], masterRules[0].DetailRules__r, mapParameters);
            Test.stopTest();
        }
        
    }
    @isTest
    public static void TESTSelectionRepNULL(){
        System.runAs(userAdmin){
            
            system.debug('case##'+ lstCase[0].Id);
            Test.startTest();
            map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
            String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
            String receivedEndDate =  System.now().day() + '/' +System.now().month()+'/'+System.now().year();
            //mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));
            
            insert listDetailRule;
            
            list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                                sObject__c, FilterLogic__c,version__c,Name,
                                                (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                                 OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
                                                 FROM DetailRules__r
                                                 ORDER BY Number__c ASC),
                                                (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
                                                 NOB_ValueType__c, NOB_Weightage__c, /*ASE: 03/11/20 : RSIW-2868 */  NOB_Limit__c
                                                 FROM Objectifs__r)
                                                FROM MasterRules__c
                                                WHERE Process__c    = 'NOB_Recherche Réparateur'
                                                AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];
            
            mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(lstCase[0].Id, masterRules[0], masterRules[0].DetailRules__r, mapParameters);
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    public static void TESTSelectionRepNOTPriority(){
        System.runAs(userAdmin){
            
            system.debug('case##'+ lstCase[0].Id);
            Test.startTest();
            map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
            String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
            String receivedEndDate =  System.now().day() + '/' +System.now().month()+'/'+System.now().year();
            
            lstbodyshopAcc[0].NOB_Priorite__c = 'Dé-priorisé';
            update lstbodyshopAcc;
            
            mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));
                
                insert listDetailRule;

                list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                                    sObject__c, FilterLogic__c,version__c,Name,
                                                    (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                                            OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
                                                    FROM DetailRules__r
                                                    ORDER BY Number__c ASC),
                                                    (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
                                                    NOB_ValueType__c, NOB_Weightage__c, /* ASE: 03/11/20 : RSIW-2868 */ NOB_Limit__c
                                                    FROM Objectifs__r)
                                            FROM MasterRules__c
                                            WHERE Process__c    = 'NOB_Recherche Réparateur'
                                            AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];

                mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(lstCase[0].Id, masterRules[0], masterRules[0].DetailRules__r, mapParameters);
            Test.stopTest();
        }
    
    }
    
    @isTest
    public static void TESTSelectionRepStandard(){
        System.runAs(userAdmin){

            system.debug('case##'+ lstCase[0].Id);
            Test.startTest();
                map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
                 String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
                 String receivedEndDate =  System.now().day() + '/' +System.now().month()+'/'+System.now().year();
            
            lstbodyshopAcc[0].NOB_Priorite__c = 'Aucune';
            update lstbodyshopAcc;
            
                 mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));


                
                insert listDetailRule;

            
            
                list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                                    sObject__c, FilterLogic__c,version__c,Name,
                                                    (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                                            OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
                                                    FROM DetailRules__r
                                                    ORDER BY Number__c ASC),
                                                    (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
                                                    NOB_ValueType__c, NOB_Weightage__c, /* ASE: 03/11/20 : RSIW-2868 */ NOB_Limit__c
                                                    FROM Objectifs__r)
                                            FROM MasterRules__c
                                            WHERE Process__c    = 'NOB_Recherche Réparateur'
                                            AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];

                mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(lstCase[0].Id, masterRules[0], masterRules[0].DetailRules__r, mapParameters);
            Test.stopTest();
        }
        
    }
    
    
      @isTest
    public static void TESTgetRepWithDispo(){
        System.runAs(userAdmin){
  
            Test.startTest();
             NOB_AP50_SelectionReparateur.getReparateurWithDispo(lstbodyshopAcc);
            Test.stopTest();
        }
        
    }
    
    /* 
    @isTest
    public static void TESTSelectionRepEndDateBlank(){
    System.runAs(userAdmin){
    
    system.debug('case##'+ lstCase[0].Id);
    Test.startTest();
    map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
        
        lstbodyshopAcc[0].NOB_DateFinPlageHoraire__c = null;
        lstbodyshopAcc[0].NOB_Priorite__c = 'Aucune';
        update lstbodyshopAcc;
        
    String receivedStartDate = System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
    String receivedEndDate =   System.now().day()+ '/' +System.now().month()+'/'+System.now().year();
    
    mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));
    
    insert listDetailRule;
    
    list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
    sObject__c, FilterLogic__c,version__c,Name,
    (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
    OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
    FROM DetailRules__r
    ORDER BY Number__c ASC),
    (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
    NOB_ValueType__c, NOB_Weightage__c,  ASE: 03/11/20 : RSIW-2868  NOB_Limit__c
    FROM Objectifs__r)
    FROM MasterRules__c
    WHERE Process__c    = 'NOB_Recherche Réparateur'
    AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];
    
    mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(lstCase[0].Id, masterRules[0], masterRules[0].DetailRules__r, mapParameters);   
    Test.stopTest();
    }
    
    
    }
    */
    
    
}