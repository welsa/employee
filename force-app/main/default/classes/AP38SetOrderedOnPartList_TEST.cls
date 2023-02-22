/*
  ----------------------------------------------------------------------
  -- - Name          : AP38SetOrderedOnPartList_TEST
  -- - Author        : VSU
  -- - Description   : Test class for AP38SetOrderedOnPartList
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 08-JUN-2017    VSU     1.0     Initial version
  ----------------------------------------------------------------------
  **********************************************************************
*/
@isTest
private class AP38SetOrderedOnPartList_TEST{
  static User adminUser;
  static List<Account> accountList;
  static List<partList__c>partList;
  static List<Assessment__c> assessmentList;

  static
  {
    adminUser = TestFactory.createUser('adminUser');

    insert adminUser;

    System.runAs(adminUser)
    {
      accountList = new List<Account>
      {
        TestFactory.createAccountBodyshop('BodyShopFR_1', 'FR'),
        TestFactory.createAccountBodyshop('BodyShopES_1', 'ES'),

        TestFactory.createAccountDistributor('DistributorFR_1', 'FR'),
        TestFactory.createAccountDistributor('DistributorFR_2', 'FR'),
        TestFactory.createAccountDistributor('DistributorFR_3', 'FR'),
        TestFactory.createAccountDistributor('DistributorFR_4', 'FR'),

        TestFactory.createAccountDistributor('DistributorES_1', 'ES'),
        TestFactory.createAccountDistributor('DistributorES_2', 'ES'),
        TestFactory.createAccountDistributor('DistributorES_3', 'ES'),
        TestFactory.createAccountDistributor('DistributorES_4', 'ES')
      };

      insert accountList;

      assessmentList = new List<Assessment__c>
      {
        TestFactory.createAssessment('AssessmentFR_1', accountList[0]),
        TestFactory.createAssessment('AssessmentES_1', accountList[1])
      };

      // Setting the TECH_EntityCountryCode__c as ES in the second assessment
      assessmentList[0].TECH_EntityCountryCode__c = 'FR';

      insert assessmentList;

      partList = new List <partList__c>{
        TestFactory.createPartList(assessmentList[0]),
        TestFactory.createPartList(assessmentList[0]),
        TestFactory.createPartList(assessmentList[1]),
        TestFactory.createPartList(assessmentList[1]),
        TestFactory.createPartList(assessmentList[1])
      };

      partList[0].TECH_OrderedCounter__c = 0;
      partList[1].TECH_OrderedCounter__c = 0;
      partList[2].TECH_OrderedCounter__c = 0;
      partList[3].TECH_OrderedCounter__c = 0;
      partList[4].TECH_OrderedCounter__c = 0;

      partList[0].name = 'parentA';
      partList[1].name = 'childA1';
      partList[2].name = 'parentB';
      partList[3].name = 'childB1';
      partList[4].name = 'childB2';

      insert partList;

      partList[1].originalPart__c = partList[0].id;
      partList[3].originalPart__c = partList[2].id;
      partList[4].originalPart__c = partList[2].id;

      update partList;  

    }
  }

    @isTest static void setOrderedOnParentPL(){
      system.runAs(adminUser){
        system.debug('##partList '+partList);
          Test.startTest();
            partList[0].TECH_OrderedCounter__c = 1;
            partList[2].TECH_OrderedCounter__c = 1;
            update partList;

          Test.stopTest();

          list <partList__c> retrievedPLList1 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[0].id) or (id =: partList[0].id)
                                ];
            system.debug('##retrievedPLList1 '+retrievedPLList1);
            system.assertEquals(retrievedPLList1[0].ordered__c,true);
            system.assertEquals(retrievedPLList1[1].ordered__c,true);

          list <partList__c> retrievedPLList2 = [select id,name,ordered__c 
                                from partList__c 
                                where originalPart__c =: partList[2].id or id =: partList[2].id 
                                ];
            system.debug('##retrievedPLList2 '+retrievedPLList2);
            system.assertEquals(retrievedPLList2[0].ordered__c,true);
            system.assertEquals(retrievedPLList2[1].ordered__c,true);
            system.assertEquals(retrievedPLList2[2].ordered__c,true);
      } 
    }      
  
   @isTest static void unsetOrderedOnParentPL(){
      system.runAs(adminUser){
          Test.startTest(); 
            partList[0].TECH_OrderedCounter__c = 1;
            
            update partList[0];

            partList[0].TECH_OrderedCounter__c = 0;

            update partList[0];
          Test.stopTest();

          list <partList__c> retrievedPLList1 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[0].id) or (id =: partList[0].id)
                                ];
            system.debug('##retrievedPLList1 '+retrievedPLList1);
            system.assertEquals(retrievedPLList1[0].ordered__c,false);
            system.assertEquals(retrievedPLList1[1].ordered__c,false);

      }
   }

    @isTest static void setOrderedOnSubsPL(){
      system.runAs(adminUser){
          Test.startTest(); 
            partList[1].TECH_OrderedCounter__c = 1;
            partList[4].TECH_OrderedCounter__c = 1;
            update partList;

          Test.stopTest();

          list <partList__c> retrievedPLList1 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[0].id) or (id =: partList[0].id) 
                                ];
            system.debug('##retrievedPLList1 '+retrievedPLList1);
            system.assertEquals(retrievedPLList1[0].ordered__c,true);
            system.assertEquals(retrievedPLList1[1].ordered__c,true);
          
          list <partList__c> retrievedPLList2 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[2].id) or (id =: partList[2].id) 
                                ];
            system.debug('##retrievedPLList2 '+retrievedPLList2);
            system.assertEquals(retrievedPLList2[0].ordered__c,true);
            system.assertEquals(retrievedPLList2[1].ordered__c,true);
            system.assertEquals(retrievedPLList2[2].ordered__c,true);
      } 
    }
    
    @isTest static void unsetOrderedOnSubsPL(){
      system.runAs(adminUser){
          Test.startTest(); 
            partList[1].TECH_OrderedCounter__c = 1;
            partList[4].TECH_OrderedCounter__c = 1;
            update partList;
            partList[1].TECH_OrderedCounter__c = 0;
            partList[4].TECH_OrderedCounter__c = 0;
            update partList;
          Test.stopTest();

          list <partList__c> retrievedPLList1 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[0].id) or (id =: partList[0].id) 
                                ];
            system.debug('##retrievedPLList1 '+retrievedPLList1);
            system.assertEquals(retrievedPLList1[0].ordered__c,false);
            system.assertEquals(retrievedPLList1[1].ordered__c,false);
          
          list <partList__c> retrievedPLList2 = [select id,name,ordered__c 
                                from partList__c 
                                where (originalPart__c =: partList[2].id) or (id =: partList[2].id) 
                                ];
            system.debug('##retrievedPLList2 '+retrievedPLList2);
            system.assertEquals(retrievedPLList2[0].ordered__c,false);
            system.assertEquals(retrievedPLList2[1].ordered__c,false);
            system.assertEquals(retrievedPLList2[2].ordered__c,false);
      } 
    }
}