/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 01-26-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-07-2020   GBH   Initial Version
 * 1.1   10-NOV-2020   HMO   Modified version
 * 1.2   16-Dec-2020  ARA    
**/

@isTest
public with sharing class NOB_PlanningTriggerHandler_TEST {
    static User userAdmin;
    static list<Account> lstBodyShop;
    static list<NOB_Planning__c> lstPlanning;
    static list<ServiceContract> lstServiceContracts;
    static List<Account> listAccAssureur;
    static List<Case> lstCases;
    static List<WorkOrder> lstWorkOrder;
    static List<Contact> listContactAssure;
    static Pricebook2 pricebook;
    static NOB_AccountPricebook__c catalogueCompte;

    static {
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){
            lstBodyShop = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Premium', '44057565200035','Actif')
                  
            };

            lstBodyShop[0].NOB_Ranking__c = 'Gold';
            lstBodyShop[1].NOB_Ranking__c = 'Silver';
            lstBodyShop[2].NOB_Ranking__c = 'Bronze';

            lstBodyShop[0].NOB_SiretHeadquarters__c ='Test';
            lstBodyShop[1].NOB_SiretHeadquarters__c ='Test1';
            lstBodyShop[2].NOB_SiretHeadquarters__c ='Test2';

            lstBodyShop[2].BillingCity = 'Paris';
            lstBodyShop[2].BillingCountry = 'France';
            lstBodyShop[2].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[2].BillingPostalCode = '75011';
            lstBodyShop[1].BillingCity = 'Paris';
            lstBodyShop[1].BillingCountry = 'France';
            lstBodyShop[1].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[1].BillingPostalCode = '75011';
            lstBodyShop[0].BillingCity = 'Paris';
            lstBodyShop[0].BillingCountry = 'France';
            lstBodyShop[0].BillingStreet = '5 RUE EMILE LEPEU';
            lstBodyShop[0].BillingPostalCode = '75011';
            
            lstBodyShop[0].ContactEmail__c = 'test32@gmail.com';
            lstBodyShop[0].VATNumber__c='544';
             lstBodyShop[0].ReferenceNumber__c = 'FR0123656787';
             lstBodyShop[0].ASEntity__c = 'ASFR1';
            lstBodyShop[0].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[0].Phone = '0123456789';
            
            
            
              lstBodyShop[1].ContactEmail__c = 'test324@gmail.com';
            lstBodyShop[1].VATNumber__c='5445';
             lstBodyShop[1].ReferenceNumber__c = 'FR0123656887';
             lstBodyShop[1].ASEntity__c = 'ASFR1';
            lstBodyShop[1].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[1].Phone = '0123456789';
            
            
                 lstBodyShop[2].ContactEmail__c = 'test32443@gmail.com';
            lstBodyShop[2].VATNumber__c='54453';
             lstBodyShop[2].ReferenceNumber__c = 'FR0123636887';
             lstBodyShop[2].ASEntity__c = 'ASFR1';
            lstBodyShop[2].ExpertSubstitutionMethod__c = 'Forced';
			lstBodyShop[2].Phone = '0123456789';
            
            insert lstBodyShop;

            lstPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(lstBodyShop[0].id),
                TestFactory.createPlanning(lstBodyShop[1].id),
                TestFactory.createPlanning(lstBodyShop[2].id),
                TestFactory.createPlanning(lstBodyShop[1].id)
            };

            for(integer i = 0; i <= 2; i++){
                lstPlanning[i].NOB_Status__c = 'Disponible';
                lstPlanning[i].IsDelete__c = false;
                lstPlanning[i].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 16, 00, 0);
                lstPlanning[i].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+i, 17, 00, 0);
            }
            


            lstServiceContracts = new List<ServiceContract>{
                new ServiceContract(Name = 'contrat 1', AccountId=lstBodyShop[0].id,
                                   StartDate=Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day() -5 ),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month() +12, 
                                   System.today().day()), NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 7,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0),
                new ServiceContract(Name = 'contrat 2', AccountId=lstBodyShop[1].id,
                                   StartDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day() -5 ),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month()+12, 
                                   System.today().day()), NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 10,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0),
                new ServiceContract(Name = 'contrat 3', AccountId=lstBodyShop[2].id,
                                   StartDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()),
                                   NOB_DateDeFormation__c = Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day() -5 ),
                                   EndDate= Date.newInstance(System.today().year(),
                                   System.today().month(), 
                                   System.today().day()), NOB_ContractsType__c = 'Partinium', /*NOB_NumRCSRM__c = '2',*/ NOB_GlobalCommitment__c = 1,NOB_NombreRendezvousAnnuel__c = 20,NOB_Dispo_entrees_annee__c=0,NOB_Dispo_entrees_semaine__c=0)
            };
            //HMO -- 29-03-2022
            NOB_AP61_UpdateRankingQuarter.testDate = System.today();
            insert lstServiceContracts;
            
            lstCases = new List<Case>();
        lstWorkOrder = new List<WorkOrder>();
        listContactAssure = new List<Contact>();
		
		
		   listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','Nord'),TestFactory.createInsurerAccount('accAssureur1','Bourgogne'),TestFactory.createInsurerAccount('accAssureurAxa','31049995900891')};
            listAccAssureur[0].Nob_CTICampaignNumber__c = 'Test';
            listAccAssureur[1].Nob_CTICampaignNumber__c = 'Test1';
			listAccAssureur[0].ReferenceNumber__c = 'FR0121237264';
            listAccAssureur[1].ReferenceNumber__c = 'FR0121237464';
			listAccAssureur[0].Phone = '0123456789';
            insert listAccAssureur;
			
			
			  listContactAssure.add(TestFactory.createInsuredContact('contact', 'Assuree', listAccAssureur[0].Id,'Nord'));
            listContactAssure.add(TestFactory.createInsuredContact('contact1', 'Assuree1', listAccAssureur[1].Id,'Bourgogne'));
              listContactAssure.add(TestFactory.createInsuredContact('contact2', 'Assuree2', listAccAssureur[2].Id,'Bourgogne'));
            listContactAssure[2].Email='conAssure2@gmail.com';
            insert listContactAssure;
            
            
            pricebook = new Pricebook2(Name='AXA-SAD',NOB_Offer__c='SAD',IsActive=true);
            insert pricebook;
            
            catalogueCompte = new NOB_AccountPricebook__c(Name='AXA Offre SAD',NOB_Account__c=listAccAssureur[2].Id,NOB_Pricebook__c=pricebook.Id); 
            insert catalogueCompte;

            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[0].Id, listAccAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[1].Id, listAccAssureur[1].Id, 'BMW', 'X6','128765sdd','test2',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR16534','Body','Réparation'));
            lstCases[0].NOB_ScenarioCode__c = '36';
            lstCases[0].PFR_TECH_EngineerClaimNR__c = 'testing';
            lstCases[0].NOB_ContactPickup__c = listContactAssure[0].Id;
            
               lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[2].Id, listAccAssureur[2].Id, 'BMW', 'X1','128765sddz','test3',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR145678','Body','Réparation'));
            lstCases[2].NOB_Pricebook__c=catalogueCompte.Id;
            lstCases[2].NOB_ContactPickup__c= listContactAssure[2].Id;
            lstCases[2].NOB_ScenarioCode__c = '36';
            lstCases[2].PFR_TECH_EngineerClaimNR__c = 'testing';
            lstCases[2].NOB_ContactPickup__c = listContactAssure[2].Id;
            lstCases[2].Origin = 'Email';
            
            
            insert lstCases;

            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[1].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[2].Id));
            lstWorkOrder[0].recordTypeId = recordTypeWo;
            lstWorkOrder[0].PFR_ExcludeFG__c = false;
            lstWorkOrder[1].recordTypeId = recordTypeWo;
            lstWorkOrder[1].PFR_ExcludeFG__c = false;
            lstWorkOrder[2].recordTypeId = recordTypeWo;
            lstWorkOrder[2].PFR_ExcludeFG__c = false;
            lstWorkOrder[2].NOB_BusinessProvider__c = listAccAssureur[2].Id;
           // lstWorkOrder[2].NOB_Reparateur__c=lstBodyShop[0].Id;
            insert lstWorkOrder;
            

        }
        
        
    }
    @isTest
    public static void afterInsertTest(){
        System.runAs(userAdmin){
            lstPlanning[0].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();
            lstPlanning[0].NOB_Status__c = 'Réservé';
            lstPlanning[0].NOB_WorkOrder__c=lstWorkOrder[2].id;
            Test.startTest();

                 listAccAssureur[2].NOB_SiretHeadquarters__c = System.Label.PFR_SiretAXA;
                 update listAccAssureur[2];

                 lstCases[2].NOB_TECH_DispoId__c =  lstPlanning[0].Id;
                 lstCases[2].NOB_BusinessProvider__c = listAccAssureur[2].Id;

                 update lstCases[2];

                 lstWorkOrder[2].NOB_Pricebook__c = catalogueCompte.Id;
                 update lstWorkOrder[2];

                 insert lstPlanning;

            Test.stopTest();
        List<NOB_Planning__c> lstPlanInserted = [SELECT Id FROM NOB_Planning__c WHERE Id =: lstPlanning];
        System.assertEquals(lstPlanInserted.size(), 4);
        }
    }
    @isTest
    public static void TestBeforeUpdateDateEqual(){
        System.runAs(userAdmin){
            
            insert lstPlanning;
            Test.startTest();
            try{
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                       System.today().month(), 
                                                                       System.today().day(), 17, 00, 0);                                                 
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                     System.today().month(), 
                                                                     System.today().day(), 17, 00,0);                               
                lstPlanning[0].NOB_Status__c = 'Disponible';
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin));
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void testBeforeUpdateInvalidTime(){
        System.runAs(userAdmin){
            
            insert lstPlanning;
            Test.startTest();
            try{
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                       System.today().month(), 
                                                                       System.today().day(), 22, 0, 0);

                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                     System.today().month(), 
                                                                     System.today().day(), 23, 0, 0);
                lstPlanning[0].NOB_Status__c = 'Disponible';
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_NoCreationEventBetween_21_to_6));
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void beforeUpdateStartDateGreaterTest(){
        System.runAs(userAdmin){

            insert lstPlanning;
            Test.startTest();
            try{
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                       System.today().month(),
                                                                       System.today().day()+2, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c =  Datetime.newInstance(System.today().year(),
                                                                      System.today().month(),
                                                                      System.today().day(), 17, 00, 0);
                lstPlanning[0].NOB_Status__c = 'Disponible';
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_GreaterThan_DateFin));
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void afterUpdateTest(){
        System.runAs(userAdmin){
                insert lstPlanning;
            Test.startTest();
                lstPlanning[0].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();
                lstPlanning[0].NOB_Status__c = 'Annulé';
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(),
                                                                    System.today().day(), 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(),
                                                                    System.today().day(), 17, 00, 0);

                lstPlanning[1].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();
                lstPlanning[1].NOB_Status__c = 'Disponible';
                //HMO -- 29-03-2022 lstPlanning[1].IsDelete__c = true;
                lstPlanning[1].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(),
                                                                    System.today().day(), 16, 00, 0);
                lstPlanning[1].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(),
                                                                    System.today().day(), 17, 00, 0);
                System.debug('@@@lstplanningtest' +lstPlanning);
                update lstPlanning;
            Test.stopTest();
            List<NOB_Planning__c> lstPlanUpdated = [SELECT Id,NOB_Status__c FROM NOB_Planning__c WHERE Id =: lstPlanning[0].Id];
            String status = (String)lstPlanUpdated[0].get('NOB_Status__c');
            System.assertEquals('Annulé', status);
        }
    }

    @isTest
    public static void onBeforeInsertInvalidTimeTest(){
        System.runAs(userAdmin){
            lstPlanning[0].NOB_Status__c = 'Disponible';
            lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                   System.today().month(),
                                                                   System.today().day(), 22, 00, 0);

            lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(),
                                                                    System.today().day(), 23, 00, 0);

            Test.startTest();
            try{
                insert lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_NoCreationEventBetween_21_to_6));
            }
            
            Test.stopTest();
        }
    }

    @isTest
    public static void onBeforeInsertTimeEqualTest(){
        System.runAs(userAdmin){
            NOB_Planning__c newPlanning =  TestFactory.createPlanning(lstBodyShop[0].id);
          
            //Date Equal
            Datetime dt1 = Datetime.newInstance(System.today().year(),
                                                 System.today().month(), 
                                                 System.today().day(), 11, 0, 0);
            newPlanning.NOB_StartDate__c = dt1;
            newPlanning.NOB_EndDate__c = dt1;
            newPlanning.NOB_OriginalEndDate__c = dt1;

            Test.startTest();
            try{
                insert newPlanning;

            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_SelectValidDateTime));
            }
            
            Test.stopTest();
        }
    }

    @isTest
    public static void onBeforeInsertStartTimeGreaterTest(){
        System.runAs(userAdmin){
            NOB_Planning__c newPlanning =  TestFactory.createPlanning(lstBodyShop[0].id);
            
          
            //Date Equal
            Datetime dt1 = Datetime.newInstance(System.today().year(),
                                                 System.today().month(), 
                                                 System.today().day()+10, 7, 7, 7);
            
            Datetime dt2 = Datetime.newInstance(System.today().year(),
                                                System.today().month(), 
                                                System.today().day()+1, 7, 7, 7);

            newPlanning.NOB_StartDate__c = dt1;
            newPlanning.NOB_OriginalEndDate__c = dt2;
            newPlanning.NOB_EndDate__c = dt2;

            Test.startTest();
            try{
                insert newPlanning;
                
            } catch (DmlException e){
                system.debug(e.getMessage());
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_SelectValidDateTime));
            }
            
            Test.stopTest();
        }
    }
    @isTest
    public static void onBeforeInsertTest(){
        System.runAs(userAdmin){
        
           List<NOB_Planning__c> newPlanning = new List<NOB_Planning__c>{
                                                                         TestFactory.createPlanning(lstBodyShop[0].id),
                                                                         TestFactory.createPlanning(lstBodyShop[1].id)};
           
            
          System.debug('@@newPlanningtest'+newPlanning);
            //Date Equal
            Datetime dt1 = Datetime.newInstance(System.today().year(),
                                                 System.today().month(), 
                                                 System.today().day()+1, 10, 0, 0);
            
            Datetime dt2 = Datetime.newInstance(System.today().year(),
                                                System.today().month(), 
                                                System.today().day()+1, 11, 0, 0);

            newPlanning[0].NOB_StartDate__c = dt1;
            newPlanning[0].NOB_OriginalEndDate__c = dt2;
            newPlanning[0].NOB_EndDate__c = dt2;
            newPlanning[1].NOB_StartDate__c = dt1;
            newPlanning[1].NOB_OriginalEndDate__c = dt2;
            newPlanning[1].NOB_EndDate__c = dt2;

            newPlanning[0].NOB_Status__c = 'Disponible';
            newPlanning[1].NOB_Status__c = null;
            newPlanning[0].NOB_IntegrerEnSemaineType__c =true;
            newPlanning[1].NOB_IntegrerEnSemaineType__c =true;
            newPlanning[0].IsDelete__c = false;
            newPlanning[1].IsDelete__c = false;

            Test.startTest();
                insert newPlanning;
            Test.stopTest();
        }

    }

    // ARA 15/12/2020
    @isTest
    public static void TestOnAfterDelete(){
        System.runAs(userAdmin){
            for(Integer i = 0; i < lstPlanning.size(); i++){
                lstPlanning[i].NOB_Status__c = 'Annulé';
            }
            insert lstPlanning;
            
            Test.startTest();
            delete lstPlanning[1];
            List<NOB_Planning__c> lstPlanRemain = [SELECT Id FROM NOB_Planning__c WHERE Id =: lstPlanning];
            System.assertEquals(lstPlanRemain.size(), 3);
            
            Test.stopTest();
        }
    }
    
    
     @isTest
    public static void TestBeforeUpdateDateReserve(){
        System.runAs(userAdmin){
             lstPlanning[0].NOB_Status__c = 'Disponible';
                lstPlanning[0].IsDelete__c = false;
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 17, 00, 0);
            insert lstPlanning;
            Test.startTest();
            try{
                                          
                lstPlanning[0].NOB_Status__c = 'Réservé';
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin));
            }
            Test.stopTest();
        }
    }
    
     @isTest
    public static void TestBeforeUpdateIntegreSemaineType(){
        System.runAs(userAdmin){
             lstPlanning[0].NOB_Status__c = 'Disponible';
           lstPlanning[0].NOB_IntegrerEnSemaineType__c = false;
                lstPlanning[0].IsDelete__c = false;
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 17, 00, 0);
            insert lstPlanning;
            Test.startTest();
            try{
                                          
                lstPlanning[0].NOB_IntegrerEnSemaineType__c = true;
                 
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin));
            }
            Test.stopTest();
        }
    }
    
    
      @isTest
    public static void TestBeforeUpdateStatusNull(){
         System.runAs(userAdmin){
             lstPlanning[0].NOB_Status__c = 'Disponible';
           lstPlanning[0].NOB_IntegrerEnSemaineType__c = false;
                lstPlanning[0].IsDelete__c = false;
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 17, 00, 0);
            insert lstPlanning;
            Test.startTest();
            try{
                                          
                lstPlanning[0].NOB_IntegrerEnSemaineType__c = true;
                lstPlanning[0].NOB_Status__c = '';
                 
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin));
            }
            Test.stopTest();
        }
    }
    
    
      @isTest
    public static void TestAfterUpdateWO(){
         System.runAs(userAdmin){
             lstPlanning[0].NOB_Status__c = 'Disponible';
         
                lstPlanning[0].IsDelete__c = false;
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 17, 00, 0);
            insert lstPlanning;
            Test.startTest();
            try{
                                          
              
               lstPlanning[0].NOB_WorkOrder__c=lstWorkOrder[0].id;
                 lstPlanning[0].NOB_Status__c = 'Réservé';
                update lstPlanning;
            } catch (DmlException e){
                System.assert(e.getMessage().contains(System.label.NOB_Planning_Error_DateDebut_Equal_DateFin));
            }
            Test.stopTest();
        }
    }
    
      @isTest
    public static void TestAfterUpdateWOAXA(){
         System.runAs(userAdmin){
            lstPlanning[0].RecordTypeId = Schema.SObjectType.NOB_Planning__c.getRecordTypeInfosByDeveloperName().get('NOB_PlanningNobilas').getRecordTypeId();
             lstPlanning[0].NOB_Status__c = 'Disponible';
         
                lstPlanning[0].IsDelete__c = false;
                lstPlanning[0].NOB_StartDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 16, 00, 0);
                lstPlanning[0].NOB_EndDate__c = Datetime.newInstance(System.today().year(),
                                                                    System.today().month(), 
                                                                    System.today().day()+1, 17, 00, 0);
            insert lstPlanning;
             
             lstWorkOrder[2].NOB_Reparateur__c=lstBodyShop[0].Id;
             update lstWorkOrder;
             
            Test.startTest();                                
               lstPlanning[0].NOB_WorkOrder__c=lstWorkOrder[2].id;
               lstPlanning[0].NOB_Status__c = 'Réservé';
                update lstPlanning;

            Test.stopTest();
        }
    }
    
}