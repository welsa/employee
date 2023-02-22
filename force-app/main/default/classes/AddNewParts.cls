/*************************************************************************************
Class Name - AddNewParts
Version - 1.0
Created Date - 24 April 2016
Function - Controller for page AddNewParts

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       24/04/2018  Original Version (case 2488 : Creation de PO vierge)
* Welsa        08/04/2018  C-004312 : newCompensatedProcess not properly initialized on PO created by Distributors
**************************************************************************************/
public without sharing class AddNewParts{
    public List<PartList__c> listNewPartList{get;set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public String encryptedText {get; set;}
    public String decryptedPOId {get;set;}
    public PurchaseOrder__c previousPO {get;set;}
    public Boolean isAgencyMode {get;set;}
    public Boolean displayBodyshopOrderNumber {get;set;}
    public String assessmentComment {get;set;}
    public Boolean isShippingEligible {get;set;}
    public String shippingLabel {get;set;}
    public String bodyShopOrderNumber{get;set;}

    public AddNewParts(){
        listNewPartList = new List<PartList__c>();
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;
        isAgencyMode = false;
        displayBodyshopOrderNumber = false;
        isShippingEligible = false;

        try{
            if(ApexPages.currentPage().getParameters().get('Id') != null){
                encryptedText = ApexPages.currentPage().getParameters().get('Id');
                decryptedPOId = decryptBase64(encryptedText);

                if(!verifyPermission((Id)decryptedPOId)){
                    hasErrors = true;
                    isToastError = false;
                    redirectionInErrorModal = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.InsufficientPrivileges));
                }


                previousPO = [select Id, Name, Distributor__c, Rebate__c, Distributor__r.ReferenceNumber__c, AgencyMode__c, TECH_AssessmentCountryCode__c, Assessment__r.Compensated__c,
                                      Assessment__r.ParentAssessment__r.AlreadyQuoted__c, Assessment__r.ParentAssessment__r.Status__c, Assessment__r.ParentAssessment__r.isShoppingList__c, 
                                      Assessment__r.ParentAssessment__c, Assessment__r.Name, Assessment__r.BodyShop__c, Assessment__r.ParentAssessment__r.Entity__c, Assessment__r.ParentAssessment__r.Name,
                                      Assessment__r.ParentAssessment__r.AssessmentNumber__c, Assessment__r.ParentAssessment__r.CreatedDate, Assessment__r.ParentAssessment__r.LastModifiedDate, 
                                      Assessment__r.ParentAssessment__r.SpecialAgreement__c, Assessment__r.ParentAssessment__r.SpecialRenting__c, Assessment__r.ParentAssessment__r.VINCheck__c, 
                                      Assessment__r.ParentAssessment__r.Fleet__c, Assessment__r.ParentAssessment__r.TotalLoss__c, Assessment__r.ParentAssessment__r.BuildDate__c, Assessment__r.ParentAssessment__r.CrossReferences__c,
                                      Assessment__r.ParentAssessment__r.SupposedOfFraud__c, Assessment__r.ParentAssessment__r.DateOfIncident__c, Assessment__r.ParentAssessment__r.FirstRegistrationDate__c, 
                                      Assessment__r.ParentAssessment__r.EntityCode__c, Assessment__r.ParentAssessment__r.ReasonFailure__c, Assessment__r.ParentAssessment__r.Compensated__c,
                                      Assessment__r.ParentAssessment__r.ModelV2__c, Assessment__r.ParentAssessment__r.MissionNumber__c, Assessment__r.ParentAssessment__r.ClaimReference__c, 
                                      Assessment__r.ParentAssessment__r.Manufacturer__c, Assessment__r.ParentAssessment__r.EntityRules__c, Assessment__r.ParentAssessment__r.ASReference__c, 
                                      Assessment__r.ParentAssessment__r.Bodyshop_is_Eligible_Non_AXA__c, Assessment__r.ParentAssessment__r.PlateNumber2__c, Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c, 
                                      Assessment__r.ParentAssessment__r.VINNumber__c, Assessment__r.ParentAssessment__r.AssessmentID__c, Assessment__r.ParentAssessment__r.BodyShop__r.Type, 
                                      Assessment__r.ParentAssessment__r.BodyShop__r.SepaValid__c, Assessment__r.ParentAssessment__r.MREligibility__c, Assessment__r.ParentAssessment__r.MRSourcing__c,
                                      Assessment__r.ParentAssessment__r.BodyShop__r.isEligibleShippingCost__c, Assessment__r.ParentAssessment__r.BodyShop__r.ShippingPostalCodeLeft2__c,
                                      Assessment__r.ParentAssessment__r.newcompensatedprocess__c//WCH 08/04/2021 C-004312
                              from PurchaseOrder__c
                              where Id =: decryptedPOId];

                CountryCodeInformationsMapping__c countryCodeMapping = CountryCodeInformationsMapping__c.getall().get(previousPO.TECH_AssessmentCountryCode__c);

                if(previousPO.AgencyMode__c){
                   isAgencyMode = true;
                }
                if(countryCodeMapping.BodyShopOrderNumber__c){
                    displayBodyshopOrderNumber = true;
                }

                if(previousPO.Assessment__r.ParentAssessment__r.BodyShop__r.isEligibleShippingCost__c &&
                   countryCodeMapping.AlphaScaleEntity__c != null){
                    Account shippingAccount = [select id, ShippingCostStepClassic__c, ShippingCostValueClassic__c, ShippingCostRegionClassic__c,
                                                      ShippingCostRegionOther__c, ShippingCostStepOther__c, ShippingCostValueOther__c 
                                               from Account
                                               where id =: countryCodeMapping.AlphaScaleEntity__c];
                    
                    if(shippingAccount != null){
                        isShippingEligible = true;
                        if(shippingAccount.ShippingCostRegionClassic__c!= null && shippingAccount.ShippingCostRegionClassic__c.contains(previousPO.Assessment__r.ParentAssessment__r.BodyShop__r.ShippingPostalCodeLeft2__c)){
                            shippingLabel = String.format(Label.EligibleShippingCost, new List<String>{String.valueOf(shippingAccount.ShippingCostValueClassic__c), String.valueOf(shippingAccount.ShippingCostStepClassic__c)});
                        }
                        else if(shippingAccount.ShippingCostRegionOther__c!=null && shippingAccount.ShippingCostRegionOther__c.contains(previousPO.Assessment__r.ParentAssessment__r.BodyShop__r.ShippingPostalCodeLeft2__c)){
                            shippingLabel = String.format(Label.EligibleShippingCost, new List<String>{String.valueOf(shippingAccount.ShippingCostValueOther__c), String.valueOf(shippingAccount.ShippingCostStepOther__c)});
                        }
                        
                    }
                }

                listNewPartList.add(new PartList__c(Manual_Creation__c = true, SelectedByBS__c = true));
            }

        }
        catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){ 
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }else{
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.NoPurchaseOrderFound));
            }
        }
    }

    public List<SelectOption> getPartTypeOptions(){
        system.debug('## START getPartTypeOptions');
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('A', 'A'));
        system.debug('## END getPartTypeOptions');   
        return optns;       
    }

    public String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public String encryptBase64(String text){
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);
        System.debug('Encrypted Text ' + encryptedData);

        return encryptedData;
    }

    public boolean verifyPermission(Id recordId){
        return ([SELECT  RecordId
                FROM    UserRecordAccess
                WHERE   RecordId =: recordId
                AND     UserId =: UserInfo.getUserId()
                AND     HasReadAccess = true].size() > 0);
    }

    public PageReference redirectPage()
    {
        return null;
    }

    public PageReference back(){
        listNewPartList.clear();
        hasErrors = false;
        isToastError = false;

        return new PageReference('/'+decryptedPOId);
    }

    public void addNewPL(){
        hasErrors = false;
        isToastError = false;
        listNewPartList.add(new PartList__c(Manual_Creation__c = true, Type__c = 'A', Quantity__c = 1, SelectedByBS__c = true));
    }

    public String getAssessmentNumberSuffix(Id claimAssessmentId){
        Integer assessmentNumberSuffix = 1;
        for(Assessment__c existingClaimOrder : [SELECT  Id, AssessmentNumber__c
                                                FROM    Assessment__c
                                                WHERE   ParentAssessment__c =: claimAssessmentId
                                                AND     RecordType.DeveloperName = 'ClaimOrder'])
        {
            if(assessmentNumberSuffix <= Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')))
            {
                assessmentNumberSuffix = Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')) + 1;
            }
        }
    

        return String.valueOf(assessmentNumberSuffix);
    }

    public PageReference createNewAssPOSO(){
        try{
            List<OrderLine__c> listOrderLinesToInsert = new List<OrderLine__c>();
            List<Offer__c> listOffersToInsert = new List<Offer__c>();
            list<Integer> listPositionToRemove = new list<Integer>();
            system.debug('## listNewPartList ' + listNewPartList);

            for(integer i=0; i < listNewPartList.size(); i++){
                if(!listNewPartList[i].SelectedByBS__c){
                    listPositionToRemove.add(i);
                }
            }
            for(integer i=listPositionToRemove.size()-1; i >= 0 ; i--){
                listNewPartList.remove(listPositionToRemove[i]);
            }
            
            if(listNewPartList.size() > 0){

                String assessmentNumberSuffix = getAssessmentNumberSuffix(PreviousPO.Assessment__r.ParentAssessment__c);
                system.debug('## assessmentNumberSuffix ' + assessmentNumberSuffix);

                Assessment__c newClaimOrderAssessment = new Assessment__c();
                newClaimOrderAssessment.Name = previousPO.Assessment__r.ParentAssessment__r.Name.left(78) + '-' + assessmentNumberSuffix;
                newClaimOrderAssessment.AssessmentNumber__c = previousPO.Assessment__r.ParentAssessment__r.AssessmentNumber__c.left(78) + '-' + assessmentNumberSuffix;
                newClaimOrderAssessment.AssessmentID__c = previousPO.Assessment__r.ParentAssessment__r.AssessmentID__c.left(78) + '-' + assessmentNumberSuffix;
                newClaimOrderAssessment.AlreadyQuoted__c = previousPO.Assessment__r.ParentAssessment__r.AlreadyQuoted__c;
                newClaimOrderAssessment.Status__c = previousPO.Assessment__r.ParentAssessment__r.Status__c;
                newClaimOrderAssessment.isShoppingList__c = previousPO.Assessment__r.ParentAssessment__r.isShoppingList__c;
                newClaimOrderAssessment.ParentAssessment__c = previousPO.Assessment__r.ParentAssessment__c;
                newClaimOrderAssessment.BodyShop__c = previousPO.Assessment__r.BodyShop__c;
                newClaimOrderAssessment.Entity__c = previousPO.Assessment__r.ParentAssessment__r.Entity__c;
                newClaimOrderAssessment.SpecialAgreement__c = previousPO.Assessment__r.ParentAssessment__r.SpecialAgreement__c;
                newClaimOrderAssessment.SpecialRenting__c = previousPO.Assessment__r.ParentAssessment__r.SpecialRenting__c;
                newClaimOrderAssessment.VINCheck__c = previousPO.Assessment__r.ParentAssessment__r.VINCheck__c;
                newClaimOrderAssessment.Fleet__c = previousPO.Assessment__r.ParentAssessment__r.Fleet__c;
                newClaimOrderAssessment.TotalLoss__c = previousPO.Assessment__r.ParentAssessment__r.TotalLoss__c;
                newClaimOrderAssessment.BuildDate__c = previousPO.Assessment__r.ParentAssessment__r.BuildDate__c;
                newClaimOrderAssessment.CrossReferences__c = previousPO.Assessment__r.ParentAssessment__r.CrossReferences__c;
                newClaimOrderAssessment.SupposedOfFraud__c = previousPO.Assessment__r.ParentAssessment__r.SupposedOfFraud__c;
                newClaimOrderAssessment.DateOfIncident__c = previousPO.Assessment__r.ParentAssessment__r.DateOfIncident__c;
                newClaimOrderAssessment.FirstRegistrationDate__c = previousPO.Assessment__r.ParentAssessment__r.FirstRegistrationDate__c;
                newClaimOrderAssessment.EntityCode__c = previousPO.Assessment__r.ParentAssessment__r.EntityCode__c;
                newClaimOrderAssessment.ReasonFailure__c = previousPO.Assessment__r.ParentAssessment__r.ReasonFailure__c;
                newClaimOrderAssessment.Compensated__c = previousPO.Assessment__r.ParentAssessment__r.Compensated__c;
                newClaimOrderAssessment.ModelV2__c = previousPO.Assessment__r.ParentAssessment__r.ModelV2__c;
                newClaimOrderAssessment.MissionNumber__c = previousPO.Assessment__r.ParentAssessment__r.MissionNumber__c;
                newClaimOrderAssessment.ClaimReference__c = previousPO.Assessment__r.ParentAssessment__r.ClaimReference__c;
                newClaimOrderAssessment.Manufacturer__c = previousPO.Assessment__r.ParentAssessment__r.Manufacturer__c;
                newClaimOrderAssessment.EntityRules__c = previousPO.Assessment__r.ParentAssessment__r.EntityRules__c;
                newClaimOrderAssessment.PlateNumber2__c = previousPO.Assessment__r.ParentAssessment__r.PlateNumber2__c;
                newClaimOrderAssessment.TECH_EntityCountryCode__c = previousPO.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c;
                newClaimOrderAssessment.VINNumber__c = previousPO.Assessment__r.ParentAssessment__r.VINNumber__c;
                newClaimOrderAssessment.MREligibility__c = previousPO.Assessment__r.ParentAssessment__r.MREligibility__c;
                newClaimOrderAssessment.MRSourcing__c = previousPO.Assessment__r.ParentAssessment__r.MRSourcing__c;
                newClaimOrderAssessment.Comment__c = assessmentComment;
                newClaimOrderAssessment.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
                newClaimOrderAssessment.OrderOrigin__c = 'ASPIS';
                newClaimOrderAssessment.Status__c = 'SOURCED';
                newClaimOrderAssessment.newcompensatedprocess__c = previousPO.Assessment__r.ParentAssessment__r.newcompensatedprocess__c;//WCH 08/04/2021 C-004312

                system.debug('## newClaimOrderAssessment ' + newClaimOrderAssessment);
                system.debug('## listNewPartList ' + listNewPartList);
                insert newClaimOrderAssessment;
                for(PartList__c pl : listNewPartList){
                    pl.Assessment__c = newClaimOrderAssessment.Id;
                    pl.RecordTypeId = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
                }
                insert listNewPartList;

                PrerequisiteOrder__c newSalesOrder = new PrerequisiteOrder__c(Assessment__c = newClaimOrderAssessment.Id,
                                                                              BodyShop__c   = newClaimOrderAssessment.BodyShop__c,
                                                                              Status__c     = 'INACCEPTANCE',
                                                                              RecordTypeId  = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId());
                insert newSalesOrder;

                BusinessHours businessDays = ASPISConstants.getBusinessHours(PreviousPO.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c);
                CountryCodeInformationsMapping__c configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(PreviousPO.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c);

                PurchaseOrder__c newPurchaseOrder = new PurchaseOrder__c(
                    assessment__c   = newClaimOrderAssessment.id,
                    AgencyMode__c = previousPO.AgencyMode__c,
                    Rebate__c   = previousPO.Rebate__c,
                    validityDate__c = Date.valueOf(Businesshours.add(businessDays.id,datetime.now(),configCountryCodeInfo.Validity_Duration_Purchase_Order__c!=null?Integer.valueOf(configCountryCodeInfo.Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),
                    status__c = system.Label.PURCHASEORDERDRAFTQUOTESTATUS,
                    distributor__c = previousPO.Distributor__c,
                    BodyShopOrderNumber__c = displayBodyshopOrderNumber ? bodyShopOrderNumber : null,
                    recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId(),
                    SLAQuotationEntryDate__c = datetime.now(),
                    Tech_ExternalId__c = String.valueOf(newClaimOrderAssessment.id) + String.valueOf(previousPO.Distributor__c),
                    PrerequisiteOrder__c = newSalesOrder.Id
                );

                system.debug('## newPurchaseOrder ' + newPurchaseOrder);
                insert newPurchaseOrder;

                PurchaseOrder__c pOInserted = [Select Id, Name from PurchaseOrder__c where Id =: newPurchaseOrder.Id];

                for(PartList__c pl : listNewPartList){

                    OrderLine__c newOL = new OrderLine__c(PartNumber__c = pl.PartNumber__c,
                                                          Description__c = pl.Description__c,
                                                          Type__c = pl.Type__c,
                                                          Quantity__c = pl.Quantity__c,
                                                          AssessmentPrice__c = pl.Price__c,
                                                          CataloguePrice__c = pl.Price__c,
                                                          VAT__c = pl.VAT__c,
                                                          Manufacturer__c = previousPO.Assessment__r.ParentAssessment__r.Manufacturer__c, 
                                                          PartList__c = pl.Id,
                                                          PurchaseOrder__c = pOInserted.Id,
                                                          Suppliable__c = 'YES',
                                                          AcceptedCheck__c = true,
                                                          PreselectedForOrder__c = true,
                                                          Rebate__c = previousPO.Rebate__c,
                                                          TechExternalId__c = pOInserted.Name+ '-' + pl.Id);
                    listOrderLinesToInsert.add(newOL);

                    Offer__c newOff = new Offer__c(PrerequisiteOrder__c = newSalesOrder.Id,
                                                   Accepted__c = 'YES',
                                                   Suppliable__c = true,
                                                   OrderLine__r = new OrderLine__c(TechExternalId__c = pOInserted.Name + '-' + pl.Id),
                                                   Type__c = previousPO.Distributor__r.ReferenceNumber__c);
                    listOffersToInsert.add(newOff);
                }

                system.debug('## listOrderLinesToInsert ' + listOrderLinesToInsert);
                system.debug('## listOffersToInsert ' + listOffersToInsert);
                insert listOrderLinesToInsert;
                insert listOffersToInsert;

                return new PageReference('/'+pOInserted.Id);
            }
            else{
                hasErrors = true;
                isToastError = true;
                redirectionInErrorModal = true;
                listNewPartList.add(new PartList__c(Manual_Creation__c = true, Type__c = 'A', Quantity__c = 1, SelectedByBS__c = true));
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.AtLeastOnePart));
            }
        }
        catch (DMLException e)
        {
            hasErrors = true;

            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }
        }
        catch(Exception e)
        {
            hasErrors = true;

            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
        }

        return null;
    }
}