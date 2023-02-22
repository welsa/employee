/*
@File Name          : NOB_ServiceContractTriggerHandler_TEST
@Description        : 
@Author             : KPA
@Group              : 
@Modification Log   : 
==============================================================================
Ver         Date                     Author      Modification
==============================================================================
1.0    12/01/2021                     KPA           1.0
*/
@isTest
public with sharing class NOB_ServiceContractTriggerHandler_TEST {
    static User userAdmin;
    static Account accReparateur;
    static List<ServiceContract> lstServCon;
   static map<Id,ServiceContract> mapOldServContract;
    
    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        //userAdmin.BypassValidationRules__c = true;
        //userAdmin.BypassWorkflows__c = true;
        UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Prefikar' LIMIT 1];
        userAdmin.UserRoleId = userRole.Id;
        insert userAdmin;
        
      lstServCon = new List<ServiceContract>();
        
      mapOldServContract = new map<Id,ServiceContract>();
        
       accReparateur = new Account();
        
        System.runAs(userAdmin){
            accReparateur = TestFactory.createPrefikarBodyAccount('accRep', 'Réseau Premium','49492059811','Actif');
             accReparateur.NOB_SiretHeadquarters__c='siret';
            insert accReparateur;
            
                       
        }
        
       
        
    }
    
     @isTest 
        public static void NOBOnAfterUpdateTest(){
            System.runAs(userAdmin){
          
            Date startD = date.newInstance(2020, 8, 18);
            Date endD = date.newInstance(2021, 8, 17);
           
                lstServCon.add( TestFactory.createServCon( accReparateur.id  ,  'servConName' , 'Partinium' , '8776545' , startD , endD ));
                lstServCon[0].NOB_NombreMissionAnnuel__c=100;
                lstServCon[0].NOB_DateDeFormation__c = startD.addDays(-1);
                insert lstServCon;
                
           Test.startTest(); 
                
                
                System.debug('## lstlstServCon Id '+lstServCon[0].id);
                 System.debug('## lstlstServCon Gold after insert '+ lstServCon[0].NOB_NombreMissionAnnuel__c);
                
              set<Id> setReparateurId = new Set<Id>();
              setReparateurId.add(accReparateur.Id);
                
                lstServCon[0].NOB_NombreMissionAnnuel__c=200;
                update lstServCon;
                System.debug('## lstlstServCon Gold after update '+ lstServCon[0].NOB_NombreMissionAnnuel__c);


                
           Test.stopTest();
                
            }
        }
    
    
    
}