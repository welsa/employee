/*
 @File Name          : NOB_VFC50_FicheIdentification
 @Description        : visualforce pdf NOB_VFP50_FicheIdentification
 @Author             : HMO
 @Group              : 
 @Last Modified By   : 
 @Last Modified On   : 
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    24/11/2021, 16:20      HMO      1.0
*/
public with sharing class NOB_VFC50_FicheIdentification {
    public ApexPages.StandardController controller {get;set;}
    public Account acc {get;set;}
    public Contact contact {get;set;}
    public Integer vrSize {get;set;}
    public List<Id> lstContentDocId {get;set;}
    public List<ContentVersion> files {get;set;}
    public String marques {get; set;}
    public Integer vrAutoSize {get;set;}
    public List<Asset> lstAssetAuto {get;set;}
    public String loueur {get;set;}
    public String typeReps {get;set;}
    public Integer vrMakeSize {get;set;}
    public List<Asset> lstAssetMake {get;set;}
    public Decimal mileage {get;set;}
    public List<Asset> lstAssets {get;set;}

    public NOB_VFC50_FicheIdentification(ApexPages.StandardController controller) {

        try{
            Id accountId = controller.getId();
            mileage = Decimal.valueOf(System.Label.NOB_MileageVR);
            acc = [
                SELECT Id,
                Name,
                NOB_TECH_NumeroClient__c,
                NOB_ContractType__c,
                NOB_LegalEntity__c,
                BillingStreet,
                BillingCity,
                toLabel(NOB_NetworkType__c),			
                BillingPostalCode,
                (select Id, Name, Phone, email from Contacts where NOB_FunctionServices__c includes( 'Dirigeant') AND NOB_Status__c = 'Actif' Order by createdDate ASC Limit 1),
                LocalReferenceNumber__c,
                VATNumber__c,
                NOB_CodeAPE__c,
                NOB_ShareCapital__c,			
                toLabel(NOB_HeadquartersLegalForm__c),				
                toLabel(NOB_InsuranceCompany__c),
                toLabel(NOB_ClientType__c),
                toLabel(NOB_Bodyshop_Brand__c), /**Multi select picklist */
                NOB_Group__c,
                NOB_GroupName__c,
                NOB_Independant__c,
                NOB_NumberofEligibleReplacementVehicle__c,
                toLabel(NOB_BodyShop__c), /**Multi select picklist */				
                NOB_BodyshopSurfaceArea__c,

                NOB_LiftBridge__c,
                NOB_StraighteningBench__c,
                NOB_SpotWelder__c,
                NOB_NumberofPaintBooths__c,
                toLabel(NOB_SkillSet__c), /**Multi select picklist */
                toLabel(NOB_Partners__c),
                NOB_Make__c,
                toLabel(NOB_EstimationSoftware__c),
                toLabel(NOB_EADSoftware__c),
                NOB_EADIdentifier__c,
                NOB_AccountingSoftware__c,
                toLabel(NOB_DMSSoftware__c),
                NOB_DarvaIdentifier__c,
                NOB_DarvaStandard__c,
                /**Vehicule de remplacement prefikar" -  champs "NOB_CirculationDate__c" inférieur à 3 ans  +  champs "NOB_Mileage__c" inférieur à 60 000km	
                */	
                (select Id, Name, NOB_CirculationDate__c, NOB_Mileage__c, NOB_transmission__c, NOB_Make__c from Assets WHERE NOB_Mileage__c <: mileage),

                toLabel(NOB_Renter__c), /**Multi picklist */
                NOB_ProductiveEmployees__c,
                NOB_TotalEmployees__c
                FROM Account
                WHERE Id =: accountId
            ];

            lstContentDocId = new List<Id>();
            files = new List<ContentVersion>();
            for (ContentDocumentLink cdl : [SELECT ContentDocumentId
                                            FROM ContentDocumentLink 
                                            WHERE 
                                            LinkedEntityId =: acc.Id]){
                                                lstContentDocId.add(cdl.ContentDocumentId);
            }


            for (ContentVersion cv : [SELECT Id, contentDocumentId, /*ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Title*/ contentDocument.Title FROM ContentVersion where NOB_Category__c = 'Garage (catégorie Candidature)' AND NOB_SubCategory__c = 'Photos' AND  ContentDocumentId IN: lstContentDocId ORDER BY createdDate Limit 8]){
                files.add(cv);
            }

            if (acc.contacts.size() > 0){
                contact = acc.contacts[0];
            }

            marques = '';
            if (acc.NOB_Bodyshop_Brand__c != null){
                marques = acc.NOB_Bodyshop_Brand__c.replace(';', ', ');
            }

            loueur = '';
            if (acc.NOB_Renter__c != null){
                loueur = acc.NOB_Renter__c.replace(';', ', ');
            }

            typeReps = '';
            if (acc.NOB_BodyShop__c != null){
                typeReps = acc.NOB_BodyShop__c.replace(';', ', ');
            }

            lstAssetAuto = new List<Asset>();
            lstAssetMake = new List<Asset>();
            lstAssets = new List<Asset>();



            //N last year not working in soql filter for
            for (Asset asset : acc.Assets){
                if (asset.NOB_CirculationDate__c != null && math.abs((system.today().year()) - (asset.NOB_CirculationDate__c.year())) <= 3){
                    lstAssets.add(asset);
                }
            }

            for (Asset asset : lstAssets){
                if (asset.NOB_transmission__c == 'Boîte automatique'){
                    lstAssetAuto.add(asset);
                }

                if (asset.NOB_Make__c == 'DUTI'){
                    lstAssetMake.add(asset);
                }
            }

            vrSize = 0;
            if (lstAssets.size() > 0){
                vrSize = lstAssets.size();
            }

            vrAutoSize = 0;
            if (lstAssetAuto.size() > 0){
                vrAutoSize = lstAssetAuto.size();
            }

            vrMakeSize = 0;
            if (lstAssetMake.size() > 0){
                vrMakeSize = lstAssetMake.size();
            }
        }
        catch(Exception e){
            System.debug('Error'+ e.getMessage() + e.getStackTraceString());
        }
    }
}