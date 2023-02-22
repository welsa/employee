/*************************************************************************************
Class Name - PFR_docFinTriggerHandler_TEST
Version - 1.0
Created Date - 26-04-2021
Created By - hansraj.mohiputlall@spoonconsulting.com

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
*Spoon Consulting 09/03/2021 Original Version

*************************************************************************************/
@isTest
public without sharing class PFR_docFinTriggerHandler_TEST {
    static User userAdmin;
    static List<Account> lstEmetteur;
    static List<RecordType> lstRecordTypeDocFin;
    static Map<string, string> mapDocFinRecType;
    static List<PFR_FinancialDocument__c> lstDocNew;
    static User userBodyShop;
    static user userBackOffice;
    static Profile profil1;
    static Profile profilBO;
    static Contact cont;
    static UserRole role;
    static Account bs1;
    static  List<PFR_FinancialDocument__c>  lstdocFin;
    
    static List<Case> lstCases;
    static List<Contact> listContactAssure = new List<Contact>();
    static List<Account> listAccAssureur;
    
    static{
        
        UserRole portalRole1 = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        userAdmin = TestFactory.createPrefikarUser('userAdmin'); 
        userAdmin.UserRoleId = portalRole1.Id;
        insert userAdmin;
        
        NOBTools.ProfileName='PRE_Back office/Credit management';
        
        lstCases = new List<Case>();
        
        System.runAs(userAdmin){
            
            listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','Nord')};
            listAccAssureur[0].Nob_CTICampaignNumber__c = 'Test';
			listAccAssureur[0].ReferenceNumber__c = 'FR0121237264';
			listAccAssureur[0].Phone = '0123456789';
            insert listAccAssureur;
            
            listContactAssure.add(TestFactory.createInsuredContact('contact', 'Assuree', listAccAssureur[0].Id,'Nord'));
            insert listContactAssure;
            /*
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[0].Id, listAccAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));
            lstCases[0].NOB_ScenarioCode__c = '36';
            lstCases[0].PFR_TECH_EngineerClaimNR__c = 'testing';
            insert lstCases;
            */
            lstEmetteur = new List<Account>();
            lstDocNew = new List<PFR_FinancialDocument__c>();
            mapDocFinRecType = new Map<String,String>{};
                
            lstEmetteur.add(TestFactory.createAccountBodyshop('compteEmetteur', 'FR'));
            lstEmetteur[0].NOB_Statut__c = 'Actif';
            insert lstEmetteur;
            
            lstRecordTypeDocFin = [Select DeveloperName, Id From RecordType 
                                   where sObjectType='PFR_FinancialDocument__c' and isActive=true];
            for (RecordType rt :  lstRecordTypeDocFin){
                mapDocFinRecType.put(rt.DeveloperName, rt.Id);
            }
            System.debug('## mapDocFinRecType ' + mapDocFinRecType);
            String recTypeFR = mapDocFinRecType.get('FR');
            for (integer i = 0; i < 20; i++){
                lstDocNew.add(
                    new PFR_FinancialDocument__c(
                        RecordTypeId = (Id)recTypeFR,
                        PFR_RepairInvoiceNumber__c = 'repair1234'+i,
                        PFR_FinancialDocumentFrom__c = lstEmetteur[0].Id,
                        PFR_CreditNumber__c = '1234'+i,
                        PFR_ExclVATTotalAmount__c = 2344+i,
                        PFR_FinDocDateOfIssue__c = system.today()
                    )
                );
            }
            /*
            lstDocNew.add(
                    new PFR_FinancialDocument__c(
                        RecordTypeId = (Id) mapDocFinRecType.get('FS'),
                        PFR_RepairInvoiceNumber__c = 'RIN0001',
                        PFR_FinancialDocumentFrom__c = lstEmetteur[0].Id,
                        PFR_CreditNumber__c = '00001',
                        PFR_ExclVATTotalAmount__c = 20,
                        PFR_FinDocDateOfIssue__c = system.today(),
                        PFR_ContractNumber__c = '999938',
                        PFR_Case__c  = lstCase[0].id,
                        PFR_ServiceType__c = 'SAD'
                    )
                );
            */
            bs1 =TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif');
            insert bs1;
            
            cont=new Contact(AccountId=bs1.id,LastName='BsContact');
            cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            insert cont;
          
            userBodyShop = TestFactory.createUser('UserBS');
            profil1=[SELECT Id FROM Profile WHERE Name='CCP Bodyshop'];
            userBodyShop.ProfileId=profil1.Id;
            userBodyShop.ContactId=cont.Id;
            userBodyShop.NOB_isPrefikar__c=true;
            insert userBodyShop;
            
            userBackOffice = TestFactory.createUser('UserBO');
            profilBO=[SELECT Id FROM Profile WHERE Name='PRE_Back office/Credit management'];
            userBackOffice.ProfileId=profilBO.Id;
            userBackOffice.NOB_isPrefikar__c=true;
            userBackOffice.isAspis__c=false;
            insert userBackOffice;
            
            String docfinRT = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByName().get('Facture de réparation').getRecordTypeId();
            lstdocFin = new List<PFR_FinancialDocument__c>{
                new PFR_FinancialDocument__c(recordTypeId= docfinRT ,PFR_FinancialDocumentFrom__c=bs1.Id,PFR_ExclVATTotalAmount__c=10, 
                                             PFR_DocumentStatus__c='NU', PFR_RepairInvoiceNumber__c='76543',
                                             PFR_VATAmount__c =10,PFR_InclVATTotalAmount__c = 10, OwnerId=userBackOffice.Id, PFR_FinDocDateOfIssue__c = system.today())
                    };
            insert lstdocFin;
            
        }
    }
    
    @isTest
    public static void onBeforeInsertTest(){
        System.runAs(userAdmin){
            Test.startTest();
            
            lstDocNew.add(
                    new PFR_FinancialDocument__c(
                        RecordTypeId = (Id) mapDocFinRecType.get('AV'),
                        PFR_RepairInvoiceNumber__c = 'RIN0001',
                        PFR_FinancialDocumentFrom__c = lstEmetteur[0].Id,
                        PFR_CreditNumber__c = '00001',
                        PFR_ExclVATTotalAmount__c = 20,
                        PFR_FinDocDateOfIssue__c = system.today(),
                        PFR_ContractNumber__c = '999938',
                        
                        PFR_ServiceType__c = 'SAD'
                    )
                );
            lstDocNew.add(
                    new PFR_FinancialDocument__c(
                        RecordTypeId = (Id) mapDocFinRecType.get('AV'),
                        PFR_RepairInvoiceNumber__c = 'RIN0001',
                        PFR_FinancialDocumentFrom__c = lstEmetteur[0].Id,
                        PFR_ExclVATTotalAmount__c = 20,
                        PFR_FinDocDateOfIssue__c = system.today(),
                        PFR_ContractNumber__c = '999938',
                        
                        PFR_ServiceType__c = 'SAD'
                    )
                );

            insert lstDocNew;
            Test.stopTest();
            List<PFR_FinancialDocument__c> lstDocsInserted = [SELECT Id FROM PFR_FinancialDocument__c];
            System.assertEquals(23, lstDocsInserted.size());
        }
    }
    
    @isTest
    public static void onBeforeUpdateBSError(){
        System.runAs(userBodyshop){
            String recTypeFR = mapDocFinRecType.get('FR');
            Test.startTest();
            lstDocNew.add(
                new PFR_FinancialDocument__c(
                    RecordTypeId = (Id)recTypeFR,
                    PFR_RepairInvoiceNumber__c = 'repair123467',
                    PFR_FinancialDocumentFrom__c = lstEmetteur[0].Id,
                    PFR_CreditNumber__c = '123467',
                    PFR_ExclVATTotalAmount__c = 234455,
                    PFR_DocumentStatus__c='MA',
                    PFR_InclVATTotalAmount__c=5,
                    PFR_StatusReason__c='AM',
                    PFR_VATAmount__c=5,
                    PFR_FinDocDateOfIssue__c = system.today()
                )
            );
            insert lstDocNew;
            
            try{
                lstDocNew[20].PFR_VATAmount__c=4;
                update lstDocNew[20];
            }catch (Exception e){
                Boolean errMsg =  e.getMessage().contains(System.label.NOB_DocFinReparateurStatusNewError) ? true : false;
                System.AssertEquals(errMsg, false);
            }
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void onBeforeUpdateTestError(){
        System.runAs(userAdmin){
            insert lstDocNew;
            lstDocNew[1].PFR_TechUniqueDocIdentifier__c = null;
            lstDocNew[1].PFR_RepairInvoiceNumber__c = 'repair12340';
            Test.startTest();
            try{
                update lstDocNew;
                System.assertEquals(lstDocNew[0].PFR_RepairInvoiceNumber__c, 'repair12342');
                System.assertEquals(lstDocNew[1].PFR_RepairInvoiceNumber__c, 'repair12343');
                
            }catch (Exception e){
                Boolean errMsg =  e.getMessage().contains(System.Label.NOB_FRnumber_ErrorMsg) ? true : false;
                System.AssertEquals(errMsg, true);
            }
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void onBeforeUpdateBackOfficeDocFinNU(){
        System.runAs(userBackOffice){ 
            Test.startTest();
                PFR_docFinTriggerHandler.SkipValidation=false;
                lstdocFin[0].PFR_VATAmount__c =11;
                update lstdocFin[0];
            Test.stopTest();
        } 
    }
    
    @isTest
    public static void onBeforeUpdateBackOfficeDocFinNotNU(){
        System.runAs(userBackOffice){  
            Test.startTest();
                PFR_docFinTriggerHandler.SkipValidation=false;
                lstdocFin[0].PFR_DocumentStatus__c ='AN';
                lstdocFin[0].PFR_StatusReason__c='AM';
                update lstdocFin[0];
            Test.stopTest();
        }
        
        System.debug('##Profile.Name : '+userBackOffice);
        
    }  
}