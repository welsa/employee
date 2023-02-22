@isTest
public without sharing class NOB_AP57_TauxNegOverlappingDates_TEST {
    static User userAdmin;
    static List<NOB_TauxNeg__c> TauxNeg;
    static List<NOB_AccountRelationship__c> RelatioCompte;
    static Account accBodyshop;
    static Account accAssureur;
    
    static{
        userAdmin = new User();
        TauxNeg = new List<NOB_TauxNeg__c>();
        RelatioCompte =  new List<NOB_AccountRelationship__c>();
        accBodyshop = new Account();
        accAssureur = new Account();
        
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        insert userAdmin;
        
        
        System.runAs(userAdmin){
            accBodyshop = TestFactory.createPrefikarBodyAccount('accReparateur', 'Hors réseau','49492059811','Actif'); //need to change based on cls
            insert accBodyshop;

            accAssureur = TestFactory.createInsurerAccount('JBalvin','Nord');
            insert accAssureur;

            RelatioCompte =  new List <NOB_AccountRelationship__c>{
                new NOB_AccountRelationship__c(NOB_Compte__c =accAssureur.Id , NOB_Bodyshop__c = accBodyshop.Id, NOB_Type__c = 'Réparateur - Assureur')
                    
                    };
                        insert RelatioCompte;
            NOB_TauxNeg__c tauxNeg1 = new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id, NOB_StartDate__c = System.today(),NOB_EndDate__c = System.today()+5);
            insert TauxNeg1;
            
            TauxNeg = new list<NOB_TauxNeg__c>{
                new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id, NOB_StartDate__c = System.today(),NOB_EndDate__c = System.today()+5),
                    new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id,NOB_StartDate__c = System.today()+1,NOB_EndDate__c = System.today() +1),
                    new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id,NOB_StartDate__c = System.today()-2,NOB_EndDate__c = System.today() +10),
                    new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id,NOB_StartDate__c = System.today()-3,NOB_EndDate__c =null),
                    new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id,NOB_StartDate__c = System.today()+10,NOB_EndDate__c = System.today()+15)   
                    
                    };
                        }
    }
    
    
   // @isTest
    public static void checkOverlappingDates(){
        System.runAs(userAdmin){
            Map <Id,NOB_TauxNeg__c> mapTauxNeg = New Map <Id,NOB_TauxNeg__c>();
            Set<Id> setIdRelCompte = new Set<Id>();
            
            mapTauxNeg.put(TauxNeg[0].Id,TauxNeg[0]);
            setIdRelCompte.add(RelatioCompte[0].Id);
            
            TauxNeg[0].NOB_StartDate__c = System.today() +6;
            TauxNeg[0].NOB_EndDate__c = System.today() +7;
            
            insert TauxNeg[0];
            Test.startTest();
            
            try {
                
                TauxNeg[0].NOB_StartDate__c = System.today() +2;
                TauxNeg[0].NOB_EndDate__c = System.today() +6;
                update TauxNeg[0];
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Les dates indiquées sont déjà couvertes par un ensemble de taux négociés'));
            }
            Test.stopTest();
            
        }
        list <NOB_TauxNeg__c> lsttaux = [SELECT Id FROM NOB_TauxNeg__c];
        System.assertEquals(2, lsttaux.size());
    }
    
  //  @isTest
    public static void checkOverlappingDatesUpdate(){
        
        System.runAs(userAdmin){
            
            Map <Id,NOB_TauxNeg__c> mapTauxNeg = New Map <Id,NOB_TauxNeg__c>();
            Set<Id> setIdRelCompte = new Set<Id>();
            
            
            TauxNeg[0].NOB_StartDate__c = System.today() +6;
            TauxNeg[0].NOB_EndDate__c = System.today() +7;
            insert TauxNeg[0];         
            
            Test.startTest();
            
            try {
                TauxNeg[0].NOB_StartDate__c = System.today() +2;
                TauxNeg[0].NOB_EndDate__c = System.today() +6;
                update TauxNeg[0];
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Les dates indiquées sont déjà couvertes par un ensemble de taux négociés'));
            }
            
            Test.stopTest();
            
        }
        list <NOB_TauxNeg__c> lsttaux = [SELECT Id FROM NOB_TauxNeg__c];
        System.assertEquals(2, lsttaux.size());
    }
    
    
    @isTest
    public static void checkOverlappingDatesUpdateNotNull(){
        System.runAs(userAdmin){
            
            Map <Id,NOB_TauxNeg__c> mapTauxNeg = New Map <Id,NOB_TauxNeg__c>();
            Set<Id> setIdRelCompte = new Set<Id>();
            
            TauxNeg[0].NOB_EndDate__c = null;
            System.debug('before insert TauxNeg:' + TauxNeg);
            insert TauxNeg;
            System.debug('after insert TauxNeg:' + TauxNeg);
            Test.startTest();
            
            try {
                TauxNeg[3].NOB_StartDate__c = System.today();
                Tauxneg[3].NOB_EndDate__c = null;
                update TauxNeg[3];
            }
            Catch(exception e){
                
                Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.NOB_AP57_DateCovered)) ? true : false;
                
               // System.AssertEquals(expectedExceptionThrown, true);
                
                
                
            }
            
            Test.stopTest();
            
            
            
        }
        list <NOB_TauxNeg__c> lsttaux = [SELECT Id FROM NOB_TauxNeg__c];
        System.assertEquals(6, lsttaux.size());
        
        
    }
    
    
    
    @isTest
    public static void checkOverlappingDatesError(){
        
        System.runAs(userAdmin){
            
            Map <Id,NOB_TauxNeg__c> mapTauxNeg = New Map <Id,NOB_TauxNeg__c>();
            Set<Id> setIdRelCompte = new Set<Id>();
            
            
            TauxNeg[0].NOB_StartDate__c = System.today() +12;
            TauxNeg[0].NOB_EndDate__c = System.today() +15;
            insert TauxNeg[0];         
            
            Test.startTest();
            
            try {
                TauxNeg[0].NOB_StartDate__c = System.today() +13;
                TauxNeg[0].NOB_EndDate__c = System.today() +16;
                update TauxNeg[0];
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Les dates indiquées sont déjà couvertes par un ensemble de taux négociés'));
            }
            
            Test.stopTest();
            
        }
        
    }
    
    
    
    
}