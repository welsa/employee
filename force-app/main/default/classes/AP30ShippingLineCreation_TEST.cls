/*************************************************************************************
Class Name - AP30ShippingLineCreation_TEST
Version - 1.0
Created Date - 10 NOV 2016
Function - Test Class for class AP30ShippingLineCreation

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      10/11/2016  Original version
*****************************************************************************/
@isTest
public class AP30ShippingLineCreation_TEST {
	static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Offer__c> l_Offers;
    static list <DirectOrder__c> l_directOrder;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;
    
    static {
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_directOrder = new list <DirectOrder__c>();
        l_Offers = new list<Offer__c>();
        l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();
        
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            bs1.ReferenceNumber__c = 'FR9124912491';//WCH 23/12/2020 C-004120
            bs1.isEligibleShippingCost__c = true;
            bs1.ShippingPostalCode = '03258';
            l_Accounts.add(bs1);
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ReferenceNumber__c = 'FR9124919123';//WCH 23/12/2020 C-004120
            bs2.isEligibleShippingCost__c = true;
            bs2.ShippingPostalCode = '2A963';
            l_Accounts.add(bs2);
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            //dist1.ShippingThresholdValue__c = 10000;
            dist1.ShippingCostRegionClassic__c = '01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 26; 27; 28; 29; 30; 31; 32; 33; 34; 35; 36; 37; 38; 39; 40; 41; 42; 43; 44; 45; 46; 47; 48; 49; 50; 51; 52; 53; 54; 55; 56; 57; 58; 59; 60; 61; 62; 63; 64; 65; 66; 67; 68; 69; 70; 71; 72; 73; 74; 75; 76; 77; 78; 79; 80; 81; 82; 83; 84; 85; 86; 87; 88; 89; 90; 91; 92; 93; 94; 95; 00';
            dist1.ShippingCostStepClassic__c = 500; 
            dist1.ShippingCostValueClassic__c = 10;
            dist1.ShippingCostRegionOther__c = '2A;2B';
            dist1.ShippingCostStepOther__c = 600; 
            dist1.ShippingCostValueOther__c = 20;
            l_Accounts.add(dist1);
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            //dist2.ShippingThresholdValue__c = 1;
            dist2.ShippingCostRegionClassic__c = '01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 26; 27; 28; 29; 30; 31; 32; 33; 34; 35; 36; 37; 38; 39; 40; 41; 42; 43; 44; 45; 46; 47; 48; 49; 50; 51; 52; 53; 54; 55; 56; 57; 58; 59; 60; 61; 62; 63; 64; 65; 66; 67; 68; 69; 70; 71; 72; 73; 74; 75; 76; 77; 78; 79; 80; 81; 82; 83; 84; 85; 86; 87; 88; 89; 90; 91; 92; 93; 94; 95; 00';
            dist2.ShippingCostStepClassic__c = 500; 
            dist2.ShippingCostValueClassic__c = 10;
            dist2.ShippingCostRegionOther__c = '2A;2B';
            dist2.ShippingCostStepOther__c = 600; 
            dist2.ShippingCostValueOther__c = 20;
            l_Accounts.add(dist2);
            insert l_Accounts;

            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.AssessmentID__c = '0912';
            ass1.EntityCode__c = '241';
            l_Assessments.add(ass1);  

            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            ass2.AssessmentID__c = '0913';
            ass2.EntityCode__c = '297';
            l_Assessments.add(ass2);            
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, '');
            so1.Status__c = 'INACCEPTANCE';
            l_SalesOrders.add(so1);

            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, '');
            so2.Status__c = 'INACCEPTANCE';
            l_SalesOrders.add(so2);            
            insert l_SalesOrders;

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'INDELIVERY');
            l_purchaseOrders.add(po1_1);

            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist2, 'INDELIVERY');
            l_purchaseOrders.add(po1_2);
            insert l_purchaseOrders;

            OrderLine__c ol1 = TestFactory.createOrderLineFinal(100,po1_1, 'INPROCESS');
            l_OrderLines.add(ol1);
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(100,po1_1, 'INPROCESS');
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
			 OrderLine__c ol3 = TestFactory.createOrderLineFinal(100,po1_2, 'INPROCESS');
            l_OrderLines.add(ol3);
            OrderLine__c ol4 = TestFactory.createOrderLineFinal(100,po1_2, 'INPROCESS');
            ol4.PartNumber__c = '1234';
            l_OrderLines.add(ol4);
            insert l_OrderLines;

            Offer__c off1 = TestFactory.createOfferLine(ol1, so1, 'INPROCESS');
            off1.Type__c = 'QUICK';
            off1.Accepted__c = 'YES';
            off1.Suppliable__c = true;
            l_Offers.add(off1);
            Offer__c off2 = TestFactory.createOfferLine(ol2, so1, 'INPROCESS');
            off2.Type__c = 'QUICK';
            off2.Accepted__c = 'YES';
            off2.Suppliable__c = true;
            l_Offers.add(off2);
            Offer__c off3 = TestFactory.createOfferLine(ol3, so2, 'INPROCESS');
            off3.Type__c = 'QUICK';
            off3.Accepted__c = 'YES';
            off3.Suppliable__c = true;
            l_Offers.add(off3);
            Offer__c off4 = TestFactory.createOfferLine(ol4, so2, 'INPROCESS');
            off4.Type__c = 'QUICK';
            off4.Accepted__c = 'YES';
            off4.Suppliable__c = true;
            l_Offers.add(off4);
            insert l_Offers;

            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);
            countryCode1.AlphaScaleEntity__c = String.valueOf(l_Accounts[3].Id);
            l_cs_CountryCodeIngformation.add(countryCode1);
            insert l_cs_CountryCodeIngformation;
        }
    }

    static testMethod void orderLineCreation_Test() {
        system.debug('#### Start of method orderLineCreation_Test');
        system.runAs(l_users[0]){

            test.starttest();   
                l_Offers[0].DeliveryStatus__c = 'INDELIVERY'; 
                l_Offers[1].DeliveryStatus__c = 'INDELIVERY'; 
                l_Offers[2].DeliveryStatus__c = 'INDELIVERY'; 
                l_Offers[3].DeliveryStatus__c = 'INDELIVERY'; 
                update l_Offers;
          
                l_SalesOrders[0].Status__c = 'INDELIVERY';
                l_SalesOrders[1].Status__c = 'INDELIVERY';
                update l_SalesOrders;
            test.stoptest();
            
            System.assertEquals([select Id from OrderLine__c where partNumber__c =: System.Label.ShippingCost].size() ,2);
        }//end runAs
    }//end method
}