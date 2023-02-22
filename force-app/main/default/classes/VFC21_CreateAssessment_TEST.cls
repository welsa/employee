@isTest
private class VFC21_CreateAssessment_TEST
{
    static User userAdmin;
    static User userAdmin2;
    static BusinessHours defaultHours;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PartList__c> partLists;
    static CountryCodeInformationsMapping__c cs;


     static {
        // initialising variables
        accounts = new list<Account>();
        assessments = new list <Assessment__c>();
        partLists = new list <PartList__c>();
        cs = new  CountryCodeInformationsMapping__c();


        // creating user
        userAdmin = TestFactory.createUser('Spoon');
        userAdmin.BodyShopID__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        insert userAdmin;
        system.debug('@@@ userAdmin:'+userAdmin);
        PermissionSet permi = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Assessment_From_scratch'];

        // creating user
        userAdmin2 = TestFactory.createUserASPISLocal('SpoonTest');
        userAdmin2.BodyShopID__c = '258974134';
        userAdmin2.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Bodyshop' LIMIT 1].Id;
        insert userAdmin2;

        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permi.Id, AssigneeId = userAdmin.Id);
        insert psa;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.IsEligible__c = true;
            bs1.DistributorConnected__c = true;
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
            bs1.Type = 'Standard';
            bs1.isEligibleShippingCost__c = true;
            bs1.ContactUser__c = userAdmin2.Id;
            bs1.Feature__c = 'PilotDirectSourcing';
            bs1.ShippingPostalCode = '12';
            //bs1.TypeAssessment__c = 'Claim';
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            bs2.Type = 'Expert';
            bs2.isEligibleShippingCost__c = true;
            bs2.ContactUser__c = userAdmin2.Id;

            accounts.add(bs2);

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');            
            bs3.IsEligible__c = true;
            bs3.DistributorConnected__c = true;
            bs3.ReferenceNumber__c = 'FR2589741651';//WCH 23/12/2020 C-004120
            bs3.Type = 'Standard';
            bs3.isEligibleShippingCost__c = true;
            bs3.ContactUser__c = userAdmin2.Id;
            //bs3.TypeAssessment__c = 'NewAssessment';
            accounts.add(bs3);

            //AMI 26/09/17 : setting distributor to connected
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
            dist1.Name = 'Distributor_ScTest1';
            dist1.Tech_Distributor__c = 'Distributor_ScTest1';
            dist1.Categories__c = 'A';
            dist1.Type_of_Substitutes__c = ('Connected Substitute;Draft Call;Order Call;Distributor Connected');
            dist1.ShippingCountryCode = 'FR';
            dist1.PartTypeRegionDelayMatrix__c = '{A:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:24;B:01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,2A,2B,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95:48}';
            accounts.add(dist1);

            insert accounts;

            cs = TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.id);
            cs.bodyshopOrderNumber__c = true;
            cs.AlphaScaleEntity__c = accounts[0].Id;
            
            insert cs;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'FR';
            ass1.EntityCode__c = '299';
            ass1.ClaimReference__c = 'TRE73';
            ass1.VINNumber__c = '444';
            ass1.PlateNumber2__c = '123';
            ass1.callerSystem__c = 'Sidexa';
            ass1.Manufacturer__c = 'Citroen';
            //ass1.BuildDate__c = date.today();
            ass1.PlateNumber2__c = 'FRTY6';
            ass1.ModelV2__c = 'PRIUS T4';
            //ass1.AssessmentNumber__c = 'Num001';
            //ass1.AssessmentID__c = 'Num001';
            //ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass1);

             Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass2.Entity__c = 'FR';
            ass2.EntityCode__c = '299';
            ass2.ClaimReference__c = 'TRE73';
            ass2.VINNumber__c = '444';
            ass2.PlateNumber2__c = '123';
            ass2.callerSystem__c = 'Sidexa';
            ass2.Manufacturer__c = 'Citroen';
            //ass1.BuildDate__c = date.today();
            ass2.PlateNumber2__c = 'FRTY6';
            ass2.ModelV2__c = 'PRIUS T4';
            ass2.AssessmentNumber__c = 'Num001';
            ass2.Name = 'Num001';
            //ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass2);

            //insert assessments;

            PartList__c pl1 = TestFactory.createPartList(ass1);
            pl1.SelectedByBS__c = true;
            pl1.TECH_OrderedCounter__c = 1;
            pl1.TECH_OriginalPart__c = 'blabla-Num001-Numpl1-balbal';
            pl1.Quantity__c = 15;
            partLists.add(pl1);

            PartList__c pl2 = TestFactory.createPartList(ass2);
            pl2.SelectedByBS__c = true;
            pl2.TECH_OrderedCounter__c = 1;
            pl2.Quantity__c = 15;
            pl2.TECH_OriginalPart__c = 'blabla-Num001-Numpl2-balbal';
            partLists.add(pl2);
            //insert partLists;

            DirectOrder__c dO1 = TestFactory.createDirectOrder(null, dist1.Id);
            dO1.State__c = '01;02;03;12;04;05;06;07';
            dO1.Part_Type__c = 'A';
            dO1.Priority__c = 'P0';
            dO1.Agency_mode__c = false;
            dO1.Active__c = true;
            dO1.Country__c = 'FR';
            dO1.Type__c = 'General';
            dO1.Brands__c = 'TOYOTA;AUDI;NISSAN;CITROEN';
            dO1.Distributor__c = accounts[3].Id;
            dO1.RecordTypeId = Schema.SObjectType.DirectOrder__c.getRecordTypeInfosByName().get('Direct Sourcing').getRecordTypeId();
            insert dO1;


        }

    }
    //@isTest
    //static void controller()
    //{
    //  VFC21_CreateAssessment createAss = new VFC21_CreateAssessment();
    //}

    static testmethod void testOrderClaimSave(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';
            ass.EntityRules__c = 'FR299';


            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[0].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = 'A' +count;
                    pl.Name =  'A' +count;
                    pl.Price__c = 68;
                    pl.Quantity__c = 1;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                controller.selectedEntity = 'FR299';
                PageReference pr = controller.createNewAssPartsSave();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(3, assessment[0].PartsLists__r.size());
            System.assertEquals(controller.apexError, false);
        }
    }

    static testmethod void testOrderClaimSaveVal(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';
            ass.EntityRules__c = 'FR299';


            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[0].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = 'A' +count;
                    pl.Name =  'A' +count;
                    pl.Price__c = 68;
                    pl.Quantity__c = 1;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                controller.selectedEntity = 'FR299';

                PageReference pr = controller.createNewAssPartsSaveVal();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(3, assessment[0].PartsLists__r.size());
            System.assertEquals(controller.apexError, false);
        }
    }


    static testmethod void testOrderNewAssSave(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';

            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = 'A' +count;
                    pl.Name =  'A' +count;
                    pl.Price__c = 68;
                    pl.Quantity__c = 1;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                controller.selectedEntity = 'FR299';

                PageReference pr = controller.createNewAssPartsSave();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(3, assessment[0].PartsLists__r.size());
            System.assertEquals(controller.apexError, false);
        }
    }

    static testmethod void testOrderNewAssSaveVal(){
        system.runas(userAdmin){

            userAdmin2.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Bodyshop Order' LIMIT 1].Id;
            update userAdmin2;

            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';

            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = 'A' +count;
                    pl.Name =  'A' +count;
                    pl.Price__c = 68;
                    pl.Quantity__c = 1;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                controller.selectedEntity = 'FR299';

                PageReference pr = controller.createNewAssPartsSaveVal();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(3, assessment[0].PartsLists__r.size());
            System.assertEquals(controller.apexError, false);
        }


    }

    static testmethod void testOrderValidationError(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';

            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = null;
                    pl.Name =  null;
                    pl.Price__c = null;
                    pl.Quantity__c = null;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                PageReference pr = controller.createNewAssPartsSaveVal();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(controller.apexError, true);
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
            System.assertEquals(0, assessment.size());

        }


    }

    static testmethod void testOrderValidationError2(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = null;
            ass.ClaimReference__c = null;
            ass.Entity__c = null;
            ass.EntityCode__c = null;
            ass.Manufacturer__c = null;
            ass.VINNumber__c = null;

            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();
                controller.addNewPL();

                Integer count = 0;
                for(PartList__c pl : controller.listNewPartList){
                    pl.PartNumber__c = null;
                    pl.Name =  null;
                    pl.Price__c = null;
                    pl.Quantity__c = null;
                }
                controller.listNewPartList[0].SelectedByBS__c = false;
                PageReference pr = controller.createNewAssPartsSaveVal();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            System.assertEquals(controller.apexError, true);
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
            System.assertEquals(0, assessment.size());

        }


    }

    static testmethod void testOrderNoPartlist(){
        system.runas(userAdmin){
            Assessment__c ass = new Assessment__c ();
            ass.callerSystem__c = 'SIDEXA';
            ass.ClaimReference__c = 'hello73';
            ass.Entity__c = 'FR';
            ass.EntityCode__c = '299';
            ass.Manufacturer__c = 'CITROEN';
            ass.VINNumber__c = '5698';

            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                list<String> lstS = controller.getManufacturerOptions();
                controller.dateFromJs = '01/01/2018';
                controller.assessment = ass;
                
                PageReference pr = controller.createNewAssPartsSaveVal();
                //controller.addNewPL();
            Test.stopTest();

            list<Assessment__c> assessment = [select Status__c, AssessmentID__c , TECHRulesAppliedDescription__c, TotalNumberOfParts__c,                                      
                                        (select Id
                                         from PartsLists__r)
                                        from Assessment__c 
                                        //where AssessmentID__c = 'Num001-3'
                                        ];
            system.debug('@@ ass'+Assessment );
            //System.assertEquals('SOURCED', assessment.Status__c);
            //System.assertEquals(0, assessment[0].PartsLists__r.size());
            System.assertEquals(0, assessment.size());
            System.assertEquals(controller.apexError, true);
        }
    }
    
    static testmethod void testWrongId(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf('1293')));

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                //controller.encryptBase64('1239');
                controller.back();
                controller.addNewPL();
                controller.listNewPartList[0].SelectedByBS__c = false;
                PageReference pr = controller.createNewAssPartsSave();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
            System.assertEquals(controller.apexError, true);

        }
    }

    static testmethod void testNoPermission(){
        system.runas(userAdmin2){
            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', accounts[2].Id);

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                //controller.encryptBase64('1239');
                //controller.redirectPage();
                //controller.addNewPL();
                //controller.listNewPartList[0].SelectedByBS__c = false;
                //PageReference pr = controller.createNewAssPartsSave();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
        }
    }
    
    static testmethod void testWrongPOId(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP21_CreateAssessment);

            ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(Blob.valueOf('0015800000e3qHJ')));

            Test.startTest();
                VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
                //controller.encryptBase64('1239');
                controller.redirectPage();
                controller.addNewPL();
                controller.listNewPartList[0].PartNumber__c = null;
                PageReference pr = controller.createNewAssPartsSave();
            Test.stopTest();

            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
        }
    }

    static testmethod void getentityCodes(){
        system.runas(userAdmin){
            VFC21_CreateAssessment controller = new VFC21_CreateAssessment();
            List<Selectoption> lst = controller.getentityCodes();
        }

    }

}