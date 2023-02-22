/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_SendEmail_TEST
-- - Author        : NPE
-- - Description   : Test class for the batch of AspisBatch_SendEmail
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 08-Nov-2021	NPE		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class AspisBatch_SendEmail_TEST {

    static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
    static list<OrderLine__c> l_OrderLines;
    static list<Invoice__c> l_Invoices;
    static BusinessHours defaultHours;
    
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;

    static List<Group> groupList;
    static List<GroupMember> groupMemberList;

    static Map<String, String> mapUserIdCountryCode = new Map<String, String>();
    static Map <Id,Id> accountIdMapUserId= new Map <Id,Id> ();
    static Map<Id,List<Invoice__c>> userMapInvoiceObj = new Map<Id,List<Invoice__c>>();
    
    
    static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_OrderLines =  new list<OrderLine__c>();
        l_Invoices = new list<Invoice__c>();
        l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();
        
        
        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        user1.languagelocalekey='fr';
        user1.countryCode='fr';
        l_users.add(user1);

        User user2 = TestFactory.createUser('ScUserTest1');
        user2.languagelocalekey='fr';
        user1.countryCode='fr';
        l_users.add(user2);

        User user3 = TestFactory.createUser('ScUserTest2');
        user3.languagelocalekey='fr';
        user1.countryCode='fr';
        l_users.add(user3);

        User user4 = TestFactory.createUser('ScUserTest3');
        user4.languagelocalekey='fr';
        user1.countryCode='fr';
        l_users.add(user4);

        insert l_users;
        
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
        
            // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');
            bs1.ContactUser__c = l_users[0].Id;
            bs1.ShippingCountryCode = 'FR';
            l_Accounts.add(bs1);
            //l_Accounts.add(l_users);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.ContactUser__c = l_users[0].Id;
            l_Accounts.add(bs2);    
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);  
        
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'BE');
            l_Accounts.add(dist2);
            l_Accounts[0].vat__c = 21;
            l_Accounts[1].vat__c = 20;
            l_Accounts[2].vat__c = 21;
            l_Accounts[3].vat__c = 20;
            insert l_Accounts;

            if (l_Accounts.size() > 0 || l_users.size() >0 ) {

                for (Integer i = 0; i < l_Accounts.size(); i ++){
                    accountIdMapUserId.put(l_Accounts[i].id,l_users[i].Id );
                }
            }


            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            l_Assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);        
            insert l_Assessments;

            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so1);
        
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so2);
        
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'PREORDERCONFIRMED');
            l_SalesOrders.add(so3);            
            insert l_SalesOrders;

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'PAYABLE');
            po1_1.TechToBeProcessed__c = true;
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'PAYABLE');
            po1_2.TechToBeProcessed__c = true;            
            l_purchaseOrders.add(po1_2);                 
            insert l_purchaseOrders;


            // Create several orderlines.
            OrderLine__c ol1 = TestFactory.createOrderLineFinal(50,po1_1, 'DELIVERED');
            l_OrderLines.add(ol1);
        
            OrderLine__c ol2 = TestFactory.createOrderLineFinal(60,po1_1, 'DELIVERED');
            ol2.PartNumber__c = '1234';
            l_OrderLines.add(ol2);
        
            OrderLine__c ol3 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');           
            l_OrderLines.add(ol3);
        
            OrderLine__c ol4 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');           
            l_OrderLines.add(ol4);
            insert l_OrderLines;
        
            // Create several invoices.
            Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 4.40, 'PAYABLE', po1_1);
            l_Invoices.add(inv1);
        
            Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'PAYABLE', po1_2);
            l_Invoices.add(inv2);
            
            Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 4.40, 'PAYABLE', po1_1);
            l_Invoices.add(inv3);
        
            Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 4.40, 'PAYABLE', po1_2);
            l_Invoices.add(inv4);

            Invoice__c inv5 = TestFactory.createBodyshopInvoice('test1', 10, 'PAID', so1);
            inv5.Number__c = null;
            inv5.InvoicePaidDate__c=DateTime.Now().AddDays(1);
            l_Invoices.add(inv5);

            Invoice__c inv6 = TestFactory.createBodyshopCreditNote('test2', 10, 'PAID', so1);
            inv6.Number__c = null;
            inv6.InvoicePaidDate__c=DateTime.Now().AddDays(2);
            l_Invoices.add(inv6);

            insert l_Invoices;


            if(l_Invoices.size() > 0 ) {
                for (Integer i = 1; i < l_Invoices.size(); i ++){
                    userMapInvoiceObj.put(user1.id, l_Invoices);
                }
            }

            // access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];
            //bhs = [select Id from BusinessHoursSetting__mdt where DeveloperName='DEFAULT'];

        
            // create countryCode
            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            l_cs_CountryCodeIngformation.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('fr',defaultHours.id);            
            countryCode2.URLInvoiceDistributor__c= 'xxxxx';
            countryCode2.LoginInvoiceDistributor__c = 'login';
            countryCode2.PasswordInvoiceDistributor__c = 'pwd';
            countryCode2.LoginInvoiceBodyShop__c = 'Test';
            countryCode2.PasswordInvoiceBodyShop__c = 'Test';
            countryCode2.URLInvoiceBodyShop__c = 'Test';
            l_cs_CountryCodeIngformation.add(countryCode2);

            CountryCodeInformationsMapping__c countryCode3 = TestFactory.createCountryCodeInformationsMapping('BE',defaultHours.id);            
            countryCode3.URLInvoiceDistributor__c= 'xxxxx';
            countryCode3.LoginInvoiceDistributor__c = 'login';
            countryCode3.PasswordInvoiceDistributor__c = 'pwd';
            countryCode3.LoginInvoiceBodyShop__c = 'Test';
            countryCode3.PasswordInvoiceBodyShop__c = 'Test';
            countryCode3.URLInvoiceBodyShop__c = 'Test';
            l_cs_CountryCodeIngformation.add(countryCode3);
            insert l_cs_CountryCodeIngformation;

            //String BccEmails = Label.AspisBatchSendEmailInvoiceBCCAdmins  + ((mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))!=null && mapUserIdCountryCode.get(accountIdMapUserId.get(bsId)).contains(ASPISConstants.TECH_EntityCountryCodeBE))? (';'+Label.BatchInvoiceTemplateBccBE) : ''); //WCH 24/12/2020 C-003973
            if (l_Accounts.size()>0){
                for (integer i = 0; i < l_Accounts.size(); i++){
                    //String countryCode = String.valueOf(l_cs_CountryCodeIngformation[i]);

                    mapUserIdCountryCode.put((String.valueOf((accountIdMapUserId.get(l_Accounts[1].id)))), user1.CountryCode);
                   
                    String IDTest = mapUserIdCountryCode.get(accountIdMapUserId.get(l_Accounts[i].id));
                    Id IDTest2 =accountIdMapUserId.get(l_Accounts[i].id);
                    system.debug('NPE MAPUserID'+ mapUserIdCountryCode.get(accountIdMapUserId.get(l_Accounts[1].id)));
                    
                    system.debug('NPE AccountMapUserID GET '+ accountIdMapUserId.get(l_Accounts[i].id)  );
                    system.debug('NPE LAccounts.iD '+ (l_Accounts[i].id)  );

                    system.debug('NPE IDTest'+ IDTest);
                    system.debug('NPE IDTest2'+ IDTest2  );
                    system.debug('NPE AccountIDMAPUSERID'+ accountIdMapUserId  );


                    system.debug('NPECountry' +mapUserIdCountryCode);
                }
                
            }
            
            
            

            groupList = new List<Group>
            {
                new Group(Name = 'SystemAdmins',
                          Type = 'Regular')
            };

            insert groupList;

            groupMemberList = new List<GroupMember>
            {
                new GroupMember(GroupId         = groupList[0].Id,
                                UserOrGroupId   = l_users[0].Id)
            };
            
            insert groupMemberList;
        }
    }



    @isTest static void AspisBatchSendEmailTest() {    
        system.runas(l_users[0]){
            try{
                Test.startTest();
                Database.executeBatch(new AspisBatch_SendEmail(mapUserIdCountryCode,accountIdMapUserId, userMapInvoiceObj), 200);         
                Test.stopTest(); 
            }
            catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
                System.debug(theException.getMessage());
			}
        }    
    }


}