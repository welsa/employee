/*
@File Name          : NOB_CaseTriggerHandler_TEST
@Description        : 
@Author             : HMO
@Group              : 
@Last Modified By   : ARA
@Last Modified On   : 01-20-2021
@Modification Log   : 
==============================================================================
Ver         Date                     Author      Modification
==============================================================================
1.0    18/11/2020, 11.10               HMO           1.0
1.1    14/01/2021                      KPA           1.1
*/
@isTest
public without sharing class NOB_CaseTriggerHandler_TEST {
    static User userAdmin;
    static List<Account> listUserAcc;
    static List<Contact> listUserContact;
    static User newUser;
    static List<Case> lstCase;
    static Map<Id, Case> mapCase;
    static Case case1,case2,case3;
    static Group groupe1;
    static QueueSobject queue1;
    static List<Account> ListBodyshop;
    static List<Asset> lstVehicules;
    static List<Account> listAccAssureur;
    static List<Contact> ListConAssureur;
    static List<NOB_DarvaMessageLog__c> ListDarvaMsg;
    static List<Task> lstTask;
    
    
    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        userAdmin.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Prefikar' LIMIT 1].Id;
        insert userAdmin;

        case1 = new Case();
        case2 = new Case();
        case3 = new Case();
        
        newUser = new User();
        lstCase = new List<Case>();
        lstVehicules = new List<Asset>();
        
        System.runAs(userAdmin){

            listUserAcc = new List<Account>{TestFactory.createInsurerAccount('compteAssure','siret1')};
            // listUserAcc[0].NOB_Statut__c = 'Actif';
            insert listUserAcc;
            
            listUserContact = new List<Contact>{TestFactory.createInsuredContact('Omega', 'SeaMaster', listUserAcc[0].Id, 'Alsace Lorraine')};
            insert listUserContact;
            
            groupe1 = new Group(Name='Nouvelle Demande', type='Queue');
            insert groupe1;
            
            queue1 = new QueueSObject(QueueID = groupe1.id, SObjectType = 'Case');
            insert queue1;

            newUser = TestFactory.createUser('newUser');
            newUser.profileId = [select id from profile where name='PRE_CCP Assureur'].Id;
            newUser.LastName = 'nob0Assureur';
            newUser.ContactId = listUserContact[0].Id;
            newUser.isActive = true;
            newUser.PortalRole = '';
            insert newUser;

            System.runAs(newUser){
                listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','siret2')};
                 listAccAssureur[0].ReferenceNumber__c = 'test23232';
                insert listAccAssureur;
                
                ListConAssureur = new List<Contact>{TestFactory.createInsuredContact('contact', 'Assureur', listAccAssureur[0].Id, 'Alsace Lorraine')};
                insert ListConAssureur;
                
                ListBodyshop = new List<Account> {TestFactory.createAccountBodyshop('compteRep', 'FR'),TestFactory.createAccountBodyshop('compteRep2', 'FR')};
                ListBodyshop[0].NOB_SiretHeadquarters__c='Siret123';
                ListBodyshop[0].BillingCity = 'Paris';
                ListBodyshop[0].BillingCountry = 'France';
                ListBodyshop[0].BillingStreet = 'Chemin endans';
                ListBodyshop[0].BillingPostalCode = '3070';
                ListBodyshop[0].NOB_NetworkType__c = 'Réseau Platinium';
                ListBodyshop[0].NOB_Statut__c = 'Actif';

                ListBodyshop[1].NOB_SiretHeadquarters__c='Siret1234';
                ListBodyshop[1].BillingCity = 'Paris';
                ListBodyshop[1].BillingCountry = 'France';
                ListBodyshop[1].BillingStreet = 'Chemin endans';
                ListBodyshop[1].BillingPostalCode = '3070';
                // ListBodyshop[1].NOB_NetworkType__c = 'Réseau Platinium';
                ListBodyshop[1].NOB_Statut__c = 'Actif';
                insert ListBodyshop;
                
                for(integer i = 0; i<5; i++){
                    lstVehicules.add(TestFactory.createVehiculeRemplacement(ListBodyshop[0].Id));
                    lstVehicules[0].NOB_Make__c = 'KIA';
                    lstVehicules[0].NOB_Model__c = 'Minor';
                }
                insert lstVehicules;
                
                String recordTypeNominal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NOB_Cas_nominal').getRecordTypeId();
                Date mydate = Date.newInstance(2020, 05, 20);

                lstCase = new List<Case>{TestFactory.createCaseStandard('Nouvelle', ListConAssureur[0].Id, listAccAssureur[0].Id, 'KIA', 'Minor','484296','caseOrigin',mydate,'zy67','typeDom','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', ListConAssureur[0].Id, listAccAssureur[0].Id, 'KIA', 'Minor','4842955','caseOriginz',mydate,'zy675445','typeDomz','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', ListConAssureur[0].Id, listAccAssureur[0].Id, 'Audi', 'R8','4843542955','caseOriginzz',mydate,'zy6R4454','typeDomzz','Réparation')

                };
                lstCase[0].Origin = 'Darva';
                lstCase[0].recordTypeId = recordTypeNominal;
                lstCase[0].NOB_Assure__c = ListConAssureur[0].Id;
                lstCase[0].PFR_TECH_STDClaimNr__c  = 'Test123456';

                lstCase[1].Origin = 'Web';
                lstCase[1].recordTypeId = recordTypeNominal;
                lstCase[1].PFR_CallPreferedStartTime__c = Datetime.newInstance(2021, 12, 1, 10, 24, 9);
                lstCase[1].NOB_Assure__c = ListConAssureur[0].Id;
                lstCase[1].PFR_TECH_STDClaimNr__c  = 'Test123456';

                lstCase[2].Origin = 'Web service';
                lstCase[2].recordTypeId = recordTypeNominal;
                lstCase[2].NOB_Assure__c = ListConAssureur[0].Id; 
                lstCase[1].PFR_TECH_STDClaimNr__c  = 'Test123456';

                // insert lstCase
                
            }
            
            lstTask = new List<Task>{
                TestFactory.createTask(lstcase[0])
            };
            insert lstTask;
        }
    }
    
    @isTest
    public static void onBeforeInsertTest(){
        System.runAs(newUser){
            Test.startTest();
            // NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 19, 24, 9);
            insert lstCase;
            Test.stopTest();
        }
    }

    @isTest
    public static void afterInsertTestTime(){
        System.runAs(newUser){
           
            Test.startTest();
            //Morning
            NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 19, 24, 9);
            insert lstCase;
            Date mydatez = Date.newInstance(2020, 06, 21);
            // > MorningStart and < MorningEnd
            // NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 9, 0, 9);
           
            Test.stopTest();
        }
    }

    @isTest 
    public static void onbeforeUpdateTest(){
        System.runAs(newUser){
            insert lstCase;
            lstCase[0].NOB_InsurerClaimNumber__c = 'Test123456';
            lstCase[0].PFR_ASCompDecisionFinal__c = 'O';
            Test.startTest();
            update lstCase[0];
            Test.stopTest();
        }

    }
    @isTest 
    public static void onAfterUpdateSD32Test(){
        
        System.runAs(newUser){
            insert lstCase;
            ListDarvaMsg = new List<NOB_DarvaMessageLog__c>{
                new NOB_DarvaMessageLog__c(NOB_Case__c=lstCase[0].Id, NOB_MessageType__c='SD32', NOB_MessageSubType__c = 'Type 4', NOB_Status__c='En attente AS',NOB_ActionType__c= 'New')
            };
            insert ListDarvaMsg;
            
            Test.startTest();
                NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 9, 24, 9);
                lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(2021, 12, 1, 8, 24, 9);
                lstCase[0].NOB_BodyShop__c = ListBodyshop[0].Id;
                lstCase[0].NOB_ScenarioCode__c = '36';
                lstCase[0].PFR_TECH_EngineerClaimNR__c = 'testing';
                
                update lstCase[0];
             
            Test.stopTest();
            
            
           
        }
    }
    
    @isTest 
    public static void onAfterUpdateSD40Test(){
        
        System.runAs(newUser){
            insert lstCase;
            ListDarvaMsg = new List<NOB_DarvaMessageLog__c>{
                new NOB_DarvaMessageLog__c(NOB_Case__c=lstCase[0].Id, NOB_MessageType__c='SD40', NOB_MessageSubType__c = 'Type 4', NOB_Status__c='En attente AS',NOB_ActionType__c= 'New')
            };
            insert ListDarvaMsg;
            
            Test.startTest();
                 NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 9, 24, 9);
                lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(2021, 12, 1, 8, 24, 9);
                lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(2021, 12, 1, 8, 24, 9);
                lstCase[0].NOB_BodyShop__c = ListBodyshop[0].Id;
                lstCase[0].NOB_ScenarioCode__c = '36';
                lstCase[0].PFR_TECH_EngineerClaimNR__c = 'testing';
                
                
                update lstCase[0];
             
            Test.stopTest();
            
           
        }
    }

    @isTest 
    public static void onAfterUpdateS40ElseTest(){
        
        System.runAs(newUser){
            insert lstCase;
            ListDarvaMsg = new List<NOB_DarvaMessageLog__c>{
                new NOB_DarvaMessageLog__c(NOB_Case__c=lstCase[0].Id, NOB_MessageType__c='SD40', NOB_Status__c='En attente AS',NOB_ActionType__c= 'New')
            };
            insert ListDarvaMsg;
        
            Test.startTest();
                NOB_CaseTriggerHandler.testDate = Datetime.newInstance(2020, 12, 1, 20, 24, 9);
                lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(2021, 12, 1, 8, 24, 9);
                lstCase[0].NOB_IncidentDateandTime__c = Datetime.newInstance(2021, 12, 1, 8, 24, 9);
                lstCase[0].NOB_BodyShop__c = ListBodyshop[0].Id;
                lstCase[0].NOB_ScenarioCode__c = '36';
                lstCase[0].PFR_TECH_EngineerClaimNR__c = 'testing';
                
                
                update lstCase[0];
             
            Test.stopTest();
            
       
           
        }
    }
    
}