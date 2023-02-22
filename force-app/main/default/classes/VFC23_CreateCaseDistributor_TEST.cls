/*************************************************************************************
Class Name - VFC23_CreateCaseDistributor_TEST
Version - 1.0
Created Date - 22 AUGUST 2018
Function - TestClass to VFC23_CreateCaseDistributor

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------
* Dourga U      22/08/2018  Original Version
* Abdool M      30/10/2018  Reworked
*************************************************************************************/

@isTest
private class VFC23_CreateCaseDistributor_TEST {
    static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PartList__c> partLists;
    static list<PurchaseOrder__c> listpurchaseOrders;
    static list<OrderLine__c> listOrderLines;
    static list<PrerequisiteOrder__c> listSalesOrders;
    static list<Offer__c> listOffers;
    static CountryCodeInformationsMapping__c cs;
    static List<CaseDetailsProcessMapping__c> caseMappingList;
    static boolean ErrorMsg;
   
    
    

    static {
        // initialising variables
        accounts = new list<Account>();
        assessments = new list <Assessment__c>();
        partLists = new list <PartList__c>();
        listpurchaseOrders = new list<PurchaseOrder__c>();
        listOrderLines =  new list<OrderLine__c>();
        listSalesOrders = new list<PrerequisiteOrder__c>();
        listOffers = new list<Offer__c>();
        cs = new  CountryCodeInformationsMapping__c();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = '258974136';
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
            cs = TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            cs.AdvancedCaseManagement__c  = true;
            
            insert cs;

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');            
            bs1.IsEligible__c = true;
            bs1.DistributorConnected__c = true;
            bs1.ReferenceNumber__c = '258974136';
            bs1.ContactUser__c = userAdmin.Id;

            accounts.add(bs1);
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            dist1.Name = 'Distributor_ScTest1';
            dist1.Tech_Distributor__c = 'Distributor_ScTest1';
            dist1.Categories__c = 'A';
            dist1.Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            dist1.ContactUser__c = userAdmin.Id;

            accounts.add(dist1);

            insert accounts;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = '299';
            ass1.EntityRules__c = '299';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.VINCheck__c = 2;
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.TECH_EntityCountryCode__c = 'ES';
            ass1.CrossReferences__c = 'njgnjrgnnn';
            ass1.ModelV2__c = 'PRIUS T4';
            ass1.Status__c = 'NEW';
            ass1.AssessmentNumber__c = 'Num001';
            ass1.AssessmentID__c = 'Num001';
            ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass1);
            
            
            
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            ass2.TECH_EntityCountryCode__c = '';
            assessments.add(ass2);
            
            insert assessments;
            
            
            PartList__c pl1 = TestFactory.createPartList(assessments[0]);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(assessments[0]);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);
            insert partLists;

            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(assessments[0], bs1, 'PREACCEPTANCE');
            so1.BodyShopOrderNumber__c = '1274';
            so1.Status__c = 'PREACCEPTANCE';
            listSalesOrders.add(so1);  

            insert listSalesOrders;

            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(assessments[0], so1, bs1, dist1, '');
            po1_1.Status__c = 'PREDRAFTQOUTE';
            listpurchaseOrders.add(po1_1);
            
            
            PurchaseOrder__c po2 = TestFactory.createPurchaseOrder(assessments[1], so1, bs1, dist1, '');
            listpurchaseOrders.add(po2);
            
            insert listpurchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol1.PartList__c = partLists[0].Id;
            ol1.Description__c = 'desc1';
            ol1.OrderType__c = 'FINAL';
            ol1.PartNumber__c = '123456';
            ol1.Suppliable__c = 'YES';
            listOrderLines.add(ol1);

            OrderLine__c ol2 = TestFactory.createOrderLineFinal(10,po1_1, 'INPROCESS');
            ol2.PartList__c = partLists[1].Id;
            ol2.Description__c = 'desc12';
            ol2.OrderType__c = 'FINAL';
            ol2.PartNumber__c = '1234';
            ol2.Suppliable__c = 'YES';
            listOrderLines.add(ol2);

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.PreselectedForOrder__c = true;
            off1.Accepted__c = 'YES';
            listOffers.add(off1);

            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INPROCESS');
            off2.Type__c = 'QUICK';
            listOffers.add(off2);

            insert listOffers;

            caseMappingList = TestFactory.createCaseDetailsProcessMapping();

            caseMappingList.add(new CaseDetailsProcessMapping__c(Name='ES-PO-DeliveryProblem',
                                                                Description__c='test desc', 
                                                                Due_Date_Duration__c=1, 
                                                                Due_Date_Unity__c='D', 
                                                                Origin__c='APPLICATION', 
                                                                Priority__c='HIGH', 
                                                                Reason__c='DELIVERY', 
                                                                Short_Description__c='test short desc', 
                                                                Subject__c='incidencia en pieza', 
                                                                Type__c='PROBLEM',
                                                                Active__c=true));
            
            insert caseMappingList;
        }  
    }
    
    static testmethod void testOrderYES(){
        system.runas(userAdmin){

            Test.startTest();
                VFC23_CreateCaseDistributor.createDiscussionCase(string.valueOf(listpurchaseOrders[0].Id),'test comment');
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Case__c where Id <> null].size());
        }
    }
    //KPA 25/09/2020
    @isTest
       static void CaseDistError(){
        system.runas(userAdmin){

            Test.startTest();
               
                
           Test.setCurrentPage(Page.VFP23_CreateCaseDistributor);
            
           ApexPages.currentPage().getParameters().put('Id', (string.valueOf(listpurchaseOrders[1].Id)));

           VFC23_CreateCaseDistributor VFC23 = new VFC23_CreateCaseDistributor();
      
            VFC23.displayErrorMsg=False;
            
            VFC23_CreateCaseDistributor.createDiscussionCase(string.valueOf(listpurchaseOrders[1].Id),'test commentz');
            
            Test.stopTest();

          
        }
    }
}