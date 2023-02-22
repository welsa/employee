/*************************************************************************************
Class Name - RESTCreateAssessment_V2_Test
Version - 1.0
Created Date - 01 JUN 2015
Function - Test class for the web service create assessment version 2

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  -----------------------
* Brayan Nunhuck    01/06/2015  Original Version 
* Shamina M         17/02/2016  C-001518: Removed unnecessary debug logs
* Dourga U          26/10/2016  increase coverage
*************************************************************************************/
@isTest
private with sharing class RESTCreateAssessment_V2_TEST {
    static id profileSysAdmin;
    static list <User> l_users;
    //static list <Account>  l_Accounts;
    static Assessment__c assmt1;
    static Assessment__c assmt2;
    static list<CarMapping__c> listCarMapping;
    static List<CaseDetailsProcessMapping__c> caseMappingList = TestFactory.createCaseDetailsProcessMapping();
    static list<PartList__c> partLists;
    static list <DirectOrder__c> directOrderList;
    static List<Account> accountList;
    static List<CrossReference__c> crossRefList;


    
    static{
        l_users = new list<user>();
        //l_Accounts = new list<Account>();  
        listCarMapping = new list<CarMapping__c>();      
        partLists = new list<PartList__c>(); 
        directOrderList = new list <DirectOrder__c>();


        //create userRole
        UserRole alphaUserRole = new UserRole(Name = 'FR - AlphaScale');
        insert alphaUserRole;
        UserRole alphaUserRoleES = new UserRole(Name = 'ES - AlphaScale');
        insert alphaUserRoleES;

        //inserting users
        User user1 = TestFactory.createUser('AUTOSOFT');
        user1.LastName = 'AUTOSOFT';
        user1.FirstName ='';
        user1.UserRoleId = alphaUserRole.Id;
        l_users.add(user1);

        User user2 = TestFactory.createUser('CATALOG');
        user2.LastName = 'CATALOG';
        user2.FirstName ='';
        user2.UserRoleId = alphaUserRoleES.Id;
        l_users.add(user2);


        insert l_users;
        
        system.runAs(l_users[0]){   
            //inserting body shop           
            /*bodyShopList = new list<Account>{new Account(Name='TestBodyShop',ReferenceNumber__c = '3726336104',ContactEmail__c = 'testEmail@gmail.com')};  
            insert bodyShopList;*/
            
            listCarMapping = TestFactory.createCarMappingList('AUTOSOFT');
            listCarMapping[0].Name = 'AUTOSOFT-AUTOSOFT';
            listCarMapping[0].CarDestination__c = 'CarDestination';
            insert listCarMapping;
            
            //Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            //bs2.ContactUser__c = l_users[0].Id;
            //bs2.ReferenceNumber__c = '3726336104';
            //accountList.add(bs2);   

            //Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest3', 'ES');
            //bs3.ContactUser__c = l_users[0].Id;
            //bs3.ReferenceNumber__c = 'ES4081686';
            //bs3.isEligibleSubstitution__c = true;
            //bs3.Feature__c = 'PilotDirectSourcing';
            //l_Accounts.add(bs3);   
            //insert l_Accounts;

            // Generating the account
            accountList = new List<Account>{
                TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_1', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_3', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest3', 'FR'),
                TestFactory.createAccountDistributor('Distributor_ScTest4', 'ES')
               
            };


            accountList[0].ReferenceNumber__c = 'FR3726336104';//WCH 23/12/2020 C-004120
            accountList[0].ContactUser__c = l_users[0].Id;
            accountList[0].type  = 'Expert';            
            //accountList[0].ReferenceNumber__c = 'ES4081687';
            accountList[0].isEligibleSubstitution__c = true;
            accountList[1].ContactEmail__c = 'test@test.com';
            accountList[1].type = 'Standard';
            accountList[1].ReferenceNumber__c = 'ES4081686';
            accountList[1].isEligibleSubstitution__c = true;
            accountList[1].Feature__c = 'PilotDirectSourcing';
            accountList[2].ReferenceNumber__c = 'ES4081688';
            accountList[2].isEligibleSubstitution__c = true;
            accountList[2].type = 'Standard';
            accountList[2].AXAPartner__c = true;
            
           

            insert accountList;

            Group newGroup = new Group();
            newGroup.Name = 'TestBodyShop';
            insert newGroup;

            assmt1 = TestFactory.createAssessment('BNU TEST 100', accountList[0]);
            assmt1.Entity__c = 'AXA Direct';
            assmt1.EntityRules__c = 'AXA Direct';
            assmt1.EntityCode__c = '299';
            assmt1.VINNumber__c = '444';
            assmt1.Manufacturer__c = 'TOYOTA';
            assmt1.BuildDate__c = date.today();
            assmt1.ModelV2__c = 'PRIUS T4';
            assmt1.AssessmentNumber__c = '172285RLA321-20180716';
            assmt1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

            insert assmt1;

            assmt2 = TestFactory.createAssessment('RLA TEST 100', accountList[1]);
            assmt2.Entity__c = 'AXA Direct';
            assmt2.EntityRules__c = 'AXA Direct';
            assmt2.EntityCode__c = '299';
            assmt2.VINNumber__c = '444';
            assmt2.Manufacturer__c = 'TOYOTA';
            assmt2.BuildDate__c = date.today();
            assmt2.ModelV2__c = 'PRIUS T4';
            assmt2.AssessmentNumber__c = '172285RLA321-20100716';
            assmt2.AssessmentExtIdCallerSystem__c = 'ES_AUDATEX172285RLA321-1';
            assmt2.AssessmentExternalId__c = '172285RLA321';
            assmt2.AssessmentVersion__c = 1;
            assmt2.MREligibility__c = true;
            assmt2.MRSourcing__c = accountList[6].Id + ';';
            assmt2.CrossReferences__c ='ASCR-101';
            assmt2.TECH_EntityCountryCode__c = 'ES';
            assmt2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();

            insert assmt2;

            crossRefList = new List<CrossReference__c>
            {
                TestFactory.createCrossReference('ES', '123456', 'TOYOTA', 1000, true),
                TestFactory.createCrossReference('ES', '654321', 'TOYOTA', 1000, true)                
            };
            crossRefList[1].UseClassicSourcing__c = true;
            insert crossRefList;

            PartList__c pl1 = TestFactory.createPartList(assmt1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 1;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(assmt1);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 3;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            pl2.CrossReferenceId__c = crossRefList[1].Id;            
            partLists.add(pl2);

            PartList__c pl3 = TestFactory.createPartList(assmt1);
            pl3.SelectedByBS__c = true;
            pl3.TECH_OrderedCounter__c = 1;
            pl3.Quantity__c = 2;
            pl3.TECH_OriginalPart__c = 'blabla-Num001-Numpl3-balbal';
            pl3.CrossReferenceId__c = crossRefList[0].Id;
            partLists.add(pl3);

            PartList__c pl4 = TestFactory.createPartList(assmt2);
            pl4.SelectedByBS__c = true;
            pl4.TECH_OrderedCounter__c = 1;
            pl4.TECH_OriginalPart__c = 'blabla-Num001-Numpl4-balbal';
            pl4.Quantity__c = 1;
            pl4.Description__c = pl4.PartNumber__c;
            partLists.add(pl4);

            PartList__c pl5 = TestFactory.createPartList(assmt2);
            pl5.SelectedByBS__c = true;
            pl5.TECH_OrderedCounter__c = 1;
            pl5.Quantity__c = 3;
            pl5.TECH_OriginalPart__c = 'blabla-Num001-Numpl5-balbal';
            pl5.CrossReferenceId__c = crossRefList[1].Id;   
            pl5.Description__c = pl5.PartNumber__c;
            partLists.add(pl5);

            PartList__c pl6 = TestFactory.createPartList(assmt2);
            pl6.SelectedByBS__c = true;
            pl6.TECH_OrderedCounter__c = 1;
            pl6.Quantity__c = 2;
            pl6.TECH_OriginalPart__c = 'blabla-Num001-Numpl6-balbal';
            pl6.CrossReferenceId__c = crossRefList[0].Id;
            pl6.Description__c = pl6.PartNumber__c;            
            partLists.add(pl6);
            insert partLists;


            CountryCodeInformationsMapping__c ccim = TestFactory.createCountryCodeInformationsMapping('ES', '01m24000000LWVT');
            ccim.CountryVAT__c = 21;
            insert ccim;

            //DUN 23/07/2018 case 1837
            DirectOrder__c dO1 = TestFactory.createDirectOrder(null, accountList[4].Id);
            dO1.State__c = '01;02;03;04;04;05;06;07;null';
            dO1.Part_Type__c = 'A';
            dO1.Priority__c = 'P0';
            dO1.Agency_mode__c = true;
            dO1.Active__c = true;
            dO1.Country__c = 'FR';
            dO1.Type__c = 'General';
            dO1.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO1);

            DirectOrder__c dO2 = TestFactory.createDirectOrder(accountList[0].Id, accountList[4].Id);
            dO2.State__c = '01;02;03;04;04;05;06;07;null';
            dO2.Part_Type__c = 'A';
            dO2.Priority__c = 'P0';
            dO2.Agency_mode__c = true;
            dO2.Active__c = true;
            dO2.Country__c = 'FR';
            dO2.Type__c = 'Exception';
            dO2.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO2.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO2);
            
            DirectOrder__c dO3 = TestFactory.createDirectOrder(accountList[1].Id, accountList[5].Id);
            dO3.State__c = '01;02;03;04;04;05;06;07;null';
            dO3.Part_Type__c = 'A;B';
            dO3.Priority__c = 'P0';
            dO3.Agency_mode__c = true;
            dO3.Active__c = true;
            dO3.Country__c = 'FR';
            dO3.Type__c = 'Exception';
            dO3.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO3.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO3);  

            DirectOrder__c dO4 = TestFactory.createDirectOrder(null, accountList[6].Id);
            dO4.State__c = '01;02;03;04;04;05;06;07;null';
            dO4.Part_Type__c = 'A;B';
            dO4.Priority__c = 'P0';
            dO4.Agency_mode__c = true;
            dO4.Active__c = true;
            dO4.Country__c = 'FR';
            dO4.Type__c = 'General';
            dO4.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO4.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO4);       

            DirectOrder__c dO5 = TestFactory.createDirectOrder(null, accountList[5].Id);  
            dO5.State__c = '01;02;03;04;04;05;06;07;null';
            dO5.Part_Type__c = 'A;B;C';
            dO5.Priority__c = 'P0';
            dO5.Agency_mode__c = true;
            dO5.Active__c = true;
            dO5.Country__c = 'FR';
            dO5.Type__c = 'General';
            dO5.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO5.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO5);

            DirectOrder__c dO6 = TestFactory.createDirectOrder(accountList[0].Id, accountList[5].Id);
            dO6.State__c = '01;02;03;04;04;05;06;07;null';
            dO6.Part_Type__c = 'A';
            dO6.Priority__c = 'P1';
            dO6.Agency_mode__c = true;
            dO6.Active__c = true;
            dO6.Country__c = 'FR';
            dO6.Type__c = 'Exception';
            dO6.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            dO6.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO6);

            DirectOrder__c dO7 = TestFactory.createDirectOrder(null, accountList[7].Id);
            dO7.State__c = '01;02;03;04;04;05;06;07;null';
            dO7.Part_Type__c = 'A;B';
            dO7.Priority__c = 'P0';
            dO7.Agency_mode__c = false;
            dO7.Active__c = true;
            dO7.Country__c = 'ES';
            dO7.Type__c = 'General';
            dO7.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;VW_Audi;';
            dO7.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO7);       

            DirectOrder__c dO8 = TestFactory.createDirectOrder(null, accountList[7].Id);
            dO8.State__c = '01;02;03;04;04;05;06;07;null';
            dO8.Part_Type__c = 'A;B';
            dO8.Priority__c = 'P1';
            dO8.Agency_mode__c = false;
            dO8.Active__c = true;
            dO8.Country__c = 'ES';
            dO8.Type__c = 'General';
            dO8.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;VW_Audi;';
            dO8.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            directOrderList.add(dO8);       


            //DirectOrder__c dO7 = TestFactory.createDirectOrder(accountList[0].Id, accountList[4].Id);
            //dO7.State__c = '01;02;03;04;04;05;06;07;null';
            //dO7.Part_Type__c = 'A';
            //dO7.Priority__c = 'P2';
            //dO7.Agency_mode__c = true;
            //dO7.Active__c = true;
            //dO7.Country__c = 'FR';
            //dO7.Type__c = 'Exception';
            //dO7.Brands__c = 'TOYOTA;AUDI;NISSAN;Mercedes;M1;';
            //dO7.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            //directOrderList.add(dO7);
            system.debug('@@@ directOrderList:'+directOrderList);
            insert directOrderList;
        
            
        }             
    }

   static testMethod void testCreateAssessment() {
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessment');
                
                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"AUTOSOFT","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                //String jsonStr = '[{"TransactionID":"014992MQ2U","AssessmentNumber":"0560-99-013310","BodyShopCreationDate":"2016-06-07","Entity":"PERITO NON SPECIFICATO","EntityCode":"299","MissionNumber":"014992MQ2U","Name":"0560-99-013310","PortfolioAgentCode":"0560","Parts":[{"Description":"PARAURTI ANTERIORE","Name":"PARAURTI ANTERIORE","PartNumber":"0000735480811","Price":326.58,"ProducerName":"Fiat / Lancia","Quantity":1,"Recordtype":"Material","Compliance":true},{"Description":"TEMPO DI PREPARAZIONE VEICOLO ","Name":"TEMPO DI PREPARAZIONE VEICOLO ","PartNumber":"7604A02","Price":7.54,"Quantity":1,"Recordtype":"Labour","Compliance":true},{"Description":"S/R PARAURTI ANTERIORE ","Name":"S/R PARAURTI ANTERIORE ","PartNumber":"7620C02","Price":16.82,"Quantity":1,"Recordtype":"Labour","Compliance":true},{"Description":"S/R ELEMENTI MONTATI PARAURTI ANT ","Name":"S/R ELEMENTI MONTATI PARAURTI ANT ","PartNumber":"7620A02","Price":14.79,"Quantity":1,"Recordtype":"Labour","Compliance":true},{"Description":"PARAURTI ANTERIORE VERNICIATURA COMPONENTE NUOVO","Name":"PARAURTI ANTERIORE VERNICIATURA COMPONENTE NUOVO","PartNumber":"7620P02","Price":39.73,"Quantity":1,"Recordtype":"Labour","Compliance":true},{"Description":"DURATA INTERVENTO PER VERNICIATURA A 2 STRATI","Name":"DURATA INTERVENTO PER VERNICIATURA A 2 STRATI","PartNumber":"7604B04","Price":63.56,"Quantity":1,"Recordtype":"Labour","Compliance":true},{"Description":"MATERIALE","Name":"MATERIALE","PartNumber":"7604B06","Price":56.96,"Quantity":1,"Recordtype":"Labour","Compliance":true}],"currentAsset":{"BuildDate":"2010-02-01","Colour":"","Engine":"Delta Oro","Manufacturer":"Fiat / Lancia","Model":"Lancia Delta da 06.2008","PlaceOfInspection":"PERO","PlateNumber":"EB144GB","FirstRegistrationDate":"2010-02-01","VINNumber":""},"currentBodyShop":{"ReferenceNumber":"0267091404"},"currentClaim":{"ClaimReference":"0560-99-013310","CompanyName":"AXA ASSICURAZIONI","DateOfIncident":"2014-09-07","PolicyNumber":"065438760","RepairsAuthorised":false,"VATPortionPayable":0.0,"Fraud":false,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":0.0}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));


               //create new assessment but for same claim and asset as above
                String jsonStr1 = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"R/ELECTRIC FAN","GuideNo":7794,"HeldDate":"2015-04-13","Name":"R/ELECTRIC FAN","PartNumber":"16361 28360","PartNumberOptimized":"None","Price":114,"PriceOptimized":0,"Quantity":1,"Recordtype":"Unknown","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 2","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 33","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"AUTOSOFT","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr1); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();

                //update existing assessment
                String jsonStr2 = '[{"AssessmentNumber":"BNU TEST 001","TransactionID":"ID011","Entity":"AXA Direct","MissionNumber":"00000121","Name":"JSA TEST V 2","PortfolioAgentCode":"Code123","Status":"New","Parts":[{"Description":"R/ELECTRIC FAN","GuideNo":7794,"HeldDate":"2015-04-13","Name":"R/ELECTRIC FAN","PartNumber":"16361 28360","PartNumberOptimized":"None","Price":114,"PriceOptimized":0,"Quantity":1,"Recordtype":"Unknown","Status":"New","Type":"A","VAT":20},{"Description":"RADIATOR SHROUD","GuideNo":7767,"HeldDate":"2015-04-13","Name":"RADIATOR SHROUD","PartNumber":"16711 37040","PartNumberOptimized":"None","Price":92,"PriceOptimized":0,"Quantity":2,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47031","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 2","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":4,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 2","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":null,"PriceOptimized":0,"Quantity":5,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"Travel","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"AUTOSOFT","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Name":"Asset mock001","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None"},"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"MIDAS Levallois","OrderEmail":"test@test.com","ReferenceNumber":"Auto-MIDAS-001","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"},"currentClaim":{"AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Authorised","ClaimReference":"2064150","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","Name":"Claim 2064150","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr2); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
            test.stopTest();
        }
    }
    
    

    static testMethod void testCreateAssessmentASync(){
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentASync');

                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"A","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"B","VAT":20},{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"C","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"D","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null);
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentWithNoPartList(){
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentWithNoPartList');

                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}},{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));

                String jsonStr1 = '[{"TransactionID":"BNU TEST 002","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Labour","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"81567 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;  
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json1 = RestContext.response.responseBody;
                //system.debug('>>> Json1<<< : '+  Json1.toString());
                system.assertEquals(true, Json1 != null); 
                system.assertEquals(true, Json1.toString().contains('TechnicalId'));
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentSync(){
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentSync');

                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));

                String jsonStr1 = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":2,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"81567 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;  
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json1 = RestContext.response.responseBody;
                //system.debug('>>> Json1<<< : '+  Json1.toString());
                system.assertEquals(true, Json1 != null); 
                system.assertEquals(true, Json1.toString().contains('TechnicalId'));
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentSyncCatch(){
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentSyncCatch');

                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));

                String jsonStr1 = '[{"AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":2,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"81567 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;  
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json1 = RestContext.response.responseBody;
                //system.debug('>>> Json1<<< : '+  Json1.toString());
                system.assertEquals(true, Json1 != null); 
                system.assertEquals(true, Json1.toString().contains('TechnicalId'));
            Test.stopTest();
        }
    }

    
    
    static testMethod void testCreateAssessmentSyncWithErrors(){
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentSyncWithErrors');

                // create from scratch
                //String jsonStr = '[{"test":"test"}]';
                String jsonStr = '[{"BodyShopCreationDate":"2015-09-28T08:45:02.000","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"C","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';

                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.assertEquals(true, Json == null);
            Test.stopTest();
        }
    }
    
    static testMethod void testCreateAssessmentWithDifferentAssessmentNumber() {
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentWithDifferentAssessmentNumber');

                // create from scratch
                String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));


                //create new assessment but for same claim and asset as above
                String jsonStr1 = '[{"TransactionID":"BNU TEST 002","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr1); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment(); 

            test.stopTest();
        }
    }
    
    static testMethod void Test_CatchException() {
      system.runAs(l_users[0]){  

        test.startTest();
            system.debug('@@@ start Test_CatchException');

            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            //Shamina M: dummy json string to test for catch exception section        
            String jsonStr;
            for(integer i=0;i<30000;i++){
                jsonStr += '*****INVALID_JSON';
            } 
            req.httpMethod = 'POST';
            req.requestURI = '/v2.0/createAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTCreateAssessment_V2.createNewAssessment();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            jsonStr = Json.toString();
            system.assertEquals(true, Json != null);
            system.assertEquals(true, jsonStr.contains('ErrorMessage')); 
        test.stopTest();
      }
    }

    static testMethod void testCreateUpdateAssessment() {
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            
            // create from scratch
            String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
            req.httpMethod = 'POST';
            req.requestURI = '/v2.0/createAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTCreateAssessment_V2.createNewAssessment();
                       
            test.starttest();
            system.debug('@@@ start testCreateUpdateAssessment');

            string jsonStr2 = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.GR.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.GR.","ProducerNameOptimized":"","Quantity":2,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JX","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":3,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
            req.httpMethod = 'POST';
            req.requestURI = '/v2.0/createAssessment/';
            req.requestBody = blob.valueOf(jsonStr2); 
            RestContext.request = req;
            RestContext.response = res;
            RESTCreateAssessment_V2.createNewAssessment();
            Blob Json = RestContext.response.responseBody;
            system.debug('>>> Json<<< : '+  Json.toString());
            system.assertEquals(true, Json != null); 
            system.assertEquals(true, Json.toString().contains('TechnicalId'));
            system.debug([Select AssessmentId__C from Assessment__c where AssessmentNumber__c = 'BNU TEST 001']);
            test.stopTest();
        }
    }

        static testMethod void testCreateUpdateAssessment2() {
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            
            // create from scratch
            String jsonStr = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","Price":29.23,"PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE L\'AMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE L\'AMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"3726336104","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE LAMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
            req.httpMethod = 'POST';
            req.requestURI = '/v2.0/createAssessment/';
            req.requestBody = blob.valueOf(jsonStr); 
            RestContext.request = req;
            RestContext.response = res;
            RESTCreateAssessment_V2.createNewAssessment();
                       
            test.starttest();
                system.debug('@@@ start testCreateUpdateAssessment2');

                string jsonStr2 = '[{"TransactionID":"BNU TEST 001","AssessmentNumber":"BNU TEST 001","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA ASSURANCES IARD MUTUELLE","EntityCode":"299","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"BANDEAU PORTE AVG.","GuideNo":0,"HeldDate":null,"Name":"BANDEAU PORTE AVG.","PartNumber":"8545 S6","PartNumberOptimized":"","PriceOptimized":0,"ProducerName":"BANDEAU PORTE AVG.","ProducerNameOptimized":"","Quantity":1,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.GR.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JK","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.GR.","ProducerNameOptimized":"","Quantity":2,"Recordtype":"Material","Status":"","Type":"","VAT":20},{"Description":"RETROVISEUR EXT.G.","GuideNo":0,"HeldDate":null,"Name":"RETROVISEUR EXT.G.","PartNumber":"8153 JX","PartNumberOptimized":"","Price":127.86,"PriceOptimized":0,"ProducerName":"RETROVISEUR EXT.G.","ProducerNameOptimized":"","Quantity":3,"Status":"","Type":"","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2000-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO (M) DU 07.96 AU 10.02 BERLINGO FAMILIALE MULTISPACE","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE LAMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE LAMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"37263361045","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE LAMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr2); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null); 
                system.assertEquals(true, Json.toString().contains('TechnicalId'));
                system.debug([Select AssessmentId__C from Assessment__c where AssessmentNumber__c = 'BNU TEST 001']);
            test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentWithBodyShopNotExist() {
        system.runAs(l_users[0]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse(); 
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentWithBodyShopNotExist');

                // create from scratch with body shop not existing 
                String jsonStr = '[{"AssessmentNumber":"ext1","TransactionID":"TransactionID11","Entity":"AXA Direct","MissionNumber":"0000012","Name":"AI360505","PortfolioAgentCode":"Code123","ExpertValidationDate":"2015-04-13","Status":"New","Parts":[{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"53102 47020","PartNumberOptimized":"None","Price":68,"PriceOptimized":0,"Quantity":10,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"53102 47020","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20},{"Description":"DescNew","GuideNo":2531,"HeldDate":"2015-04-15","Name":"FRONT LWR AIR GRILLE1","PartNumber":"53102 470204","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20},{"Description":"DescNew1","GuideNo":25311,"HeldDate":"2015-04-17","Name":"FRONT LWR AIR GRILLE11","PartNumber":"53102 4702041","PartNumberOptimized":"None","Price":100,"PriceOptimized":0,"Quantity":10,"Recordtype":"Labour","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"Asset 001","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"Toyota","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Name":"Asset mock001","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None"},"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"TestBodyShop1","OrderEmail":"test@test.com","ReferenceNumber":"testRefNum1","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"},"currentClaim":{"AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Authorised","ClaimReference":"2064156","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","Name":"mockclaim1","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null);
            test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentSyncNew(){
        system.runAs(l_users[1]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();              
                system.debug('@@@ start testCreateAssessmentSyncNew');

                String jsonStr1 = '[{"AssessmentNumber":"172285RLA321-20180716","TransactionID":"172285RLA32-1-1","BodyShopCreationDate":"2018-05-15T00:00:00","Entity":"AXA","EntityCode":"01","MissionNumber":"172285321","Name":"3141JAUDI-20180716","PortfolioAgentCode":"661726","Parts":[{"Description":"CILINDRO I.LIMPIAFAR","Name":"CILINDRO I.LIMPIAFAR","PartNumber":"8V0 955 101","Price":67.08,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SOP.EXT.I.PARAG.DL.","Name":"SOP.EXT.I.PARAG.DL.","PartNumber":"8V5 807 183","Price":7.56,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"PZA.CIERRE PARAG.DL.","Name":"PZA.CIERRE PARAG.DL.","PartNumber":"8V5 807 233","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"MOLDURA I.PARAG.DL.","Name":"MOLDURA I.PARAG.DL.","PartNumber":"8V5 807 533","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"TIRANTE ALETA I.","Name":"TIRANTE ALETA I.","PartNumber":"8V0 821 135 C","Price":19.76,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO I.CPL.","Name":"FARO I.CPL.","PartNumber":"8V0 941 043 C","Price":513.6,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO ANTINIEBLA I.","Name":"FARO ANTINIEBLA I.","PartNumber":"1NE 010 832-131","Price":66.88,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SENSOR DL.I.EXT.APAR","Name":"SENSOR DL.I.EXT.APAR","PartNumber":"5Q0 919 275 B GRU","Price":78.12,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"RECUBRIM.PARAGOLP.DL","Name":"RECUBRIM.PARAGOLP.DL","PartNumber":"8V5 807 065 C GRU","Price":372.3,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"REJILLA AIREAC.DL.I.","Name":"REJILLA AIREAC.DL.I.","PartNumber":"8V5 807 681 A 9B9","Price":38.44,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"LABOUR","Name":"LABOUR","PartNumber":"0","Price":595.63,"Quantity":"1","Recordtype":"Labour","Type":"A","VAT":"21"}],"currentAsset":{"Manufacturer":"AUDI","Model":"A3","PlateNumber":"3141J**","VINNumber":"WAUZZZ8VXF1130885"},"currentBodyShop":{"ReferenceNumber":"4081686"},"currentClaim":{"AbleToAuthoriseRepairs":false,"ClaimReference":"9928720286-20180716","CompanyName":"AXA","DateOfIncident":"2018-05-15","PolicyNumber":"44819717","RepairsAuthorised":true,"Fraud":false,"CommitmentFee":true,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":180.0,"AgentCode":"661726","individual":false,"SubstitutionAccepted":false,"IDCIA":"0011630781"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr1); 
                RestContext.request = req;  
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json1 = RestContext.response.responseBody;
                //system.debug('>>> Json1<<< : '+  Json1.toString());
                system.assertEquals(true, Json1 != null); 
                system.assertEquals(true, Json1.toString().contains('TechnicalId'));

            test.stopTest();

        }
    }

    static testMethod void testCreateAssessmentDirectSourcing(){
        system.runAs(l_users[1]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentDirectSourcing');

                // create from scratch
                String jsonStr = '[{"AssessmentNumber":"172285RLA321-201807168","TransactionID":"172285RLA32-1-1","BodyShopCreationDate":"2018-05-15T00:00:00","Entity":"AXA","EntityCode":"01","MissionNumber":"172285321","Name":"3141JAUDI-20180716","PortfolioAgentCode":"661726","Parts":[{"Description":"CILINDRO I.LIMPIAFAR","Name":"CILINDRO I.LIMPIAFAR","PartNumber":"8V0 955 101","Price":67.08,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SOP.EXT.I.PARAG.DL.","Name":"SOP.EXT.I.PARAG.DL.","PartNumber":"8V5 807 183","Price":7.56,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"PZA.CIERRE PARAG.DL.","Name":"PZA.CIERRE PARAG.DL.","PartNumber":"8V5 807 233","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"MOLDURA I.PARAG.DL.","Name":"MOLDURA I.PARAG.DL.","PartNumber":"8V5 807 533","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"TIRANTE ALETA I.","Name":"TIRANTE ALETA I.","PartNumber":"8V0 821 135 C","Price":19.76,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO I.CPL.","Name":"FARO I.CPL.","PartNumber":"8V0 941 043 C","Price":513.6,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO ANTINIEBLA I.","Name":"FARO ANTINIEBLA I.","PartNumber":"1NE 010 832-131","Price":66.88,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SENSOR DL.I.EXT.APAR","Name":"SENSOR DL.I.EXT.APAR","PartNumber":"5Q0 919 275 B GRU","Price":78.12,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"RECUBRIM.PARAGOLP.DL","Name":"RECUBRIM.PARAGOLP.DL","PartNumber":"8V5 807 065 C GRU","Price":372.3,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"REJILLA AIREAC.DL.I.","Name":"REJILLA AIREAC.DL.I.","PartNumber":"8V5 807 681 A 9B9","Price":38.44,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"LABOUR","Name":"LABOUR","PartNumber":"0","Price":595.63,"Quantity":"1","Recordtype":"Labour","Type":"A","VAT":"21"}],"currentAsset":{"Manufacturer":"AUDI","Model":"A3","PlateNumber":"3141J**","VINNumber":"WAUZZZ8VXF1130885"},"currentBodyShop":{"ReferenceNumber":"4081686"},"currentClaim":{"AbleToAuthoriseRepairs":false,"ClaimReference":"9928720286-20180716","CompanyName":"AXA","DateOfIncident":"2018-05-15","PolicyNumber":"44819717","RepairsAuthorised":true,"Fraud":false,"CommitmentFee":true,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":180.0,"AgentCode":"661726","individual":false,"SubstitutionAccepted":false,"IDCIA":"0011630781"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
                req.requestBody = blob.valueOf(jsonStr); 
                RestContext.request = req;
                RestContext.response = res;
                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;
                //system.debug('>>> Json<<< : '+  Json.toString());
                system.assertEquals(true, Json != null);
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentESAudatex(){
        system.runAs(l_users[1]){   
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentESAudatex');
                // create from scratch
                String jsonStr = '[{"AssessmentNumber":"172285RLA321-201807168","TransactionID":"172285RLA32-1-1","BodyShopCreationDate":"2018-05-15T00:00:00","Entity":"AXA","EntityCode":"01","MissionNumber":"172285321","Name":"3141JAUDI-20180716","PortfolioAgentCode":"661726","Parts":[{"Description":"CILINDRO I.LIMPIAFAR","Name":"CILINDRO I.LIMPIAFAR","PartNumber":"8V0 955 101","Price":67.08,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SOP.EXT.I.PARAG.DL.","Name":"SOP.EXT.I.PARAG.DL.","PartNumber":"8V5 807 183","Price":7.56,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"PZA.CIERRE PARAG.DL.","Name":"PZA.CIERRE PARAG.DL.","PartNumber":"8V5 807 233","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"MOLDURA I.PARAG.DL.","Name":"MOLDURA I.PARAG.DL.","PartNumber":"8V5 807 533","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"TIRANTE ALETA I.","Name":"TIRANTE ALETA I.","PartNumber":"8V0 821 135 C","Price":19.76,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO I.CPL.","Name":"FARO I.CPL.","PartNumber":"8V0 941 043 C","Price":513.6,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO ANTINIEBLA I.","Name":"FARO ANTINIEBLA I.","PartNumber":"1NE 010 832-131","Price":66.88,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SENSOR DL.I.EXT.APAR","Name":"SENSOR DL.I.EXT.APAR","PartNumber":"5Q0 919 275 B GRU","Price":78.12,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"RECUBRIM.PARAGOLP.DL","Name":"RECUBRIM.PARAGOLP.DL","PartNumber":"8V5 807 065 C GRU","Price":372.3,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"REJILLA AIREAC.DL.I.","Name":"REJILLA AIREAC.DL.I.","PartNumber":"8V5 807 681 A 9B9","Price":38.44,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"LABOUR","Name":"LABOUR","PartNumber":"0","Price":595.63,"Quantity":"1","Recordtype":"Labour","Type":"A","VAT":"21"}],"currentAsset":{"Manufacturer":"AUDI","Model":"A3","PlateNumber":"3141J**","VINNumber":"WAUZZZ8VXF1130885"},"currentBodyShop":{"ReferenceNumber":"4081686"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AssessmentExternalID":"172285RLA321_1","ClaimReference":"9928720286-20180716","CompanyName":"AXA","DateOfIncident":"2018-05-15","PolicyNumber":"44819717","RepairsAuthorised":true,"Fraud":false,"CommitmentFee":true,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":180.0,"AgentCode":"661726","individual":false,"SubstitutionAccepted":false,"IDCIA":"0011630781"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                RestContext.request = req;  
                RestContext.response = res;

                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;

                //system.debug('>>> Json<<< : '+  Json.toString());
                //system.assertEquals(true, Json != null);
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentESAudatex2(){
        system.runAs(l_users[1]){   
            crossRefList[1].UseClassicSourcing__c = false;
            update crossRefList;
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentESAudatex');
                // create from scratch
                String jsonStr = '[{"AssessmentNumber":"172285RLA321-201807168","TransactionID":"172285RLA32-1-1","BodyShopCreationDate":"2018-05-15T00:00:00","Entity":"AXA","EntityCode":"01","MissionNumber":"172285321","Name":"3141JAUDI-20180716","PortfolioAgentCode":"661726","Parts":[{"Description":"CILINDRO I.LIMPIAFAR","Name":"CILINDRO I.LIMPIAFAR","PartNumber":"8V0 955 101","Price":67.08,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SOP.EXT.I.PARAG.DL.","Name":"SOP.EXT.I.PARAG.DL.","PartNumber":"8V5 807 183","Price":7.56,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"PZA.CIERRE PARAG.DL.","Name":"PZA.CIERRE PARAG.DL.","PartNumber":"8V5 807 233","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"MOLDURA I.PARAG.DL.","Name":"MOLDURA I.PARAG.DL.","PartNumber":"8V5 807 533","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"TIRANTE ALETA I.","Name":"TIRANTE ALETA I.","PartNumber":"8V0 821 135 C","Price":19.76,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO I.CPL.","Name":"FARO I.CPL.","PartNumber":"8V0 941 043 C","Price":513.6,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO ANTINIEBLA I.","Name":"FARO ANTINIEBLA I.","PartNumber":"1NE 010 832-131","Price":66.88,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SENSOR DL.I.EXT.APAR","Name":"SENSOR DL.I.EXT.APAR","PartNumber":"5Q0 919 275 B GRU","Price":78.12,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"RECUBRIM.PARAGOLP.DL","Name":"RECUBRIM.PARAGOLP.DL","PartNumber":"8V5 807 065 C GRU","Price":372.3,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"REJILLA AIREAC.DL.I.","Name":"REJILLA AIREAC.DL.I.","PartNumber":"8V5 807 681 A 9B9","Price":38.44,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"LABOUR","Name":"LABOUR","PartNumber":"0","Price":595.63,"Quantity":"1","Recordtype":"Labour","Type":"A","VAT":"21"}],"currentAsset":{"Manufacturer":"AUDI","Model":"A3","PlateNumber":"3141J**","VINNumber":"WAUZZZ8VXF1130885"},"currentBodyShop":{"ReferenceNumber":"4081686"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AssessmentExternalID":"172285RLA321_1","ClaimReference":"9928720286-20180716","CompanyName":"AXA","DateOfIncident":"2018-05-15","PolicyNumber":"44819717","RepairsAuthorised":true,"Fraud":false,"CommitmentFee":true,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":180.0,"AgentCode":"661726","individual":false,"SubstitutionAccepted":false,"IDCIA":"0011630781"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                RestContext.request = req;  
                RestContext.response = res;

                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;

                //system.debug('>>> Json<<< : '+  Json.toString());
                //system.assertEquals(true, Json != null);
            Test.stopTest();
        }
    }

    static testMethod void testCreateAssessmentESAudatexorderTrue(){
        system.runAs(l_users[1]){   
            accountList[1].OrderFromAT__c = true;
            update accountList;
            Restrequest req = new Restrequest();
            Restresponse res = new Restresponse();
            
            test.starttest();
                system.debug('@@@ start testCreateAssessmentESAudatex');
                // create from scratch
                String jsonStr = '[{"AssessmentNumber":"172285RLA321-201807168","TransactionID":"172285RLA32-1-1","BodyShopCreationDate":"2018-05-15T00:00:00","Entity":"AXA","EntityCode":"01","MissionNumber":"172285321","Name":"3141JAUDI-20180716","PortfolioAgentCode":"661726","Parts":[{"Description":"CILINDRO I.LIMPIAFAR","Name":"CILINDRO I.LIMPIAFAR","PartNumber":"8V0 955 101","Price":67.08,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SOP.EXT.I.PARAG.DL.","Name":"SOP.EXT.I.PARAG.DL.","PartNumber":"8V5 807 183","Price":7.56,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"PZA.CIERRE PARAG.DL.","Name":"PZA.CIERRE PARAG.DL.","PartNumber":"8V5 807 233","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"MOLDURA I.PARAG.DL.","Name":"MOLDURA I.PARAG.DL.","PartNumber":"8V5 807 533","Price":32.79,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"TIRANTE ALETA I.","Name":"TIRANTE ALETA I.","PartNumber":"8V0 821 135 C","Price":19.76,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO I.CPL.","Name":"FARO I.CPL.","PartNumber":"8V0 941 043 C","Price":513.6,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"FARO ANTINIEBLA I.","Name":"FARO ANTINIEBLA I.","PartNumber":"1NE 010 832-131","Price":66.88,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"SENSOR DL.I.EXT.APAR","Name":"SENSOR DL.I.EXT.APAR","PartNumber":"5Q0 919 275 B GRU","Price":78.12,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"RECUBRIM.PARAGOLP.DL","Name":"RECUBRIM.PARAGOLP.DL","PartNumber":"8V5 807 065 C GRU","Price":372.3,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"REJILLA AIREAC.DL.I.","Name":"REJILLA AIREAC.DL.I.","PartNumber":"8V5 807 681 A 9B9","Price":38.44,"Quantity":"1","Recordtype":"Material","Type":"A","VAT":"21"},{"Description":"LABOUR","Name":"LABOUR","PartNumber":"0","Price":595.63,"Quantity":"1","Recordtype":"Labour","Type":"A","VAT":"21"}],"currentAsset":{"Manufacturer":"AUDI","Model":"A3","PlateNumber":"3141J**","VINNumber":"WAUZZZ8VXF1130885"},"currentBodyShop":{"ReferenceNumber":"4081686"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AssessmentExternalID":"172285RLA321_1","ClaimReference":"9928720286-20180716","CompanyName":"AXA","DateOfIncident":"2018-05-15","PolicyNumber":"44819717","RepairsAuthorised":true,"Fraud":false,"CommitmentFee":true,"TotalLoss":false,"Fleet":false,"Rental":false,"SpecialAgreement":false,"ExcessAmount":180.0,"AgentCode":"661726","individual":false,"SubstitutionAccepted":false,"IDCIA":"0011630781"}}]';
                req.httpMethod = 'POST';
                req.requestURI = '/v2.0/createAssessment/';
                req.requestBody = blob.valueOf(jsonStr); 
                req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
                RestContext.request = req;  
                RestContext.response = res;

                RESTCreateAssessment_V2.createNewAssessment();
                Blob Json = RestContext.response.responseBody;

                //system.debug('>>> Json<<< : '+  Json.toString());
                //system.assertEquals(true, Json != null);
            Test.stopTest();
        }
    }

}