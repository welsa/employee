/*
----------------------------------------------------------------------
-- - Name          : VFC15_PrintPartListForDistributor
-- - Author        : ABT
-- - Description   : Controller of VFP15_PrintPartListForDistributor
--                   Class is without sharing and workarounds has been done to display data due to FLS
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 03-APR-2017  ABT     1.0         Initial version
-- 09-FEB-2018  VSU     1.1         Modified to cater for BE - languages nl_BE and fr_BE
--              DUN     1.3         C-002392 Replace claim reference by mission number for belgium
-- 24-SEP-2018  WCH     1.4         C-002634 Ergonomie Bon de livraison PO
-- 01-APR-2019  WCH     1.5         C-003060 Agency Mode
-- 31-MAY-2019  WCH     1.6         C-003212 Notification d'un changement de téléphone
-- 17-OCT-2019  WCH     1.7         C-003417 SO Number in PO Delivery Note
-- 23-NOV-2019  WCH     1.8         C-003531 : Modify all email and delivery note templates sent to BS and Distributor
-- 06-Nov-2020  KPA     1.9         C-004026 : Pentest - Insecure Direct Object Reference
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class VFC15_PrintPartListForDistributor
{
    public PurchaseOrder__c currentPurchaseOrder{get;set;}
    public PurchaseOrder currentPurchaseOrderWrapper {get; set;}
    public String renderAs {get; set;}
    public Map<Id, OrderLineWrapper> mapOrderLineWrapper {get; set;}
    public String currentDate {get; set;}
    public Boolean hasPreselectedParts {get; set;}
    public String language {get; set;}
    public Boolean POisInAgencyMode {get; set;}//WCH 01/04/2019 C-003060 Agency Mode
    public Boolean displaySONumber {get; set;}//WCH 01/04/201 C-003417 SO Number in PO Delivery Note
    public Boolean isDDL {get; set;}//WCH 23/12/2019 C-003531 is demande de livraison
    public Boolean canSeePO {get;set;}
    public String callPrintDevNote {get;set;}
    

    public VFC15_PrintPartListForDistributor()
    {
        
        canSeePO = true;
        
        
        callPrintDevNote = ApexPages.currentPage().getParameters().get('callFrom');
        System.debug('~~~~  callPrintDevNote '+ callPrintDevNote);
        
         String purchaseOrderId ='';
        
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('Id'))){
         Blob decryptedData = EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('Id'));
         String decryptedId = decryptedData.toString();
         purchaseOrderId = decryptedId;
      
         if(!verifyPermission((Id)purchaseOrderId) && callPrintDevNote!= null && callPrintDevNote=='true'){
          canSeePO=false;
         }
        
        }
      
	   
        
     
        
        renderAs                    = 'pdf';
        mapOrderLineWrapper         = new Map<Id, OrderLineWrapper>();
        currentDate                 = System.today().format();
        hasPreselectedParts         = false;
        POisInAgencyMode            = false;//WCH 01/04/2019 C-003060 Agency Mode
        displaySONumber             = false;//WCH 01/04/201 C-003417 SO Number in PO Delivery Note
        isDDL                       = false;//WCH 23/12/2019 C-003531
        if(String.isNotBlank(purchaseOrderId))
        {
            currentPurchaseOrder        = [ SELECT  Id, Name, ClaimNumber__c, PlateNumber__c, BodyShopName__c, BodyShopAddress__c, Status__c, RecordType.Name , Assessment__r.MissionNumber__c,
                                            DistributorContact__r.LanguageLocaleKey, TECH_AssessmentCountryCode__c,BodyShopOrderNumber__c,VINNumber__c
                                            , AgencyMode__c,Assessment__r.BodyShop__r.Phone,Assessment__r.BodyShop__r.ContactUser__r.Fax,Assessment__r.BodyShop__r.ContactUser__r.Email,DistributorContact__r.Email,Distributor__r.Phone,Brand__c,Assessment__r.Comment__c //WCH 01/04/2019 C-003060 Agency Mode
                                            ,PrerequisiteOrder__r.Name//WCH 01/04/2019 C-003417 SO Number in PO Delivery Note
                                            FROM    PurchaseOrder__c
                                            WHERE   Id =:purchaseOrderId]; //06/07/2022 KEM C-004724  : Commentaire dans la commande (vision distributeur)

            language            = String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) ? ApexPages.currentPage().getParameters().get('lang') : currentPurchaseOrder.DistributorContact__r.LanguageLocaleKey;
            system.debug('##language: '+language);
            
            isDDL   = String.isNotBlank(ApexPages.currentPage().getParameters().get('isDDL')) && ApexPages.currentPage().getParameters().get('isDDL') == 'true' ? true : false;//WCH 23/12/2019 C-003531 isConfirmationDeCommande

            currentPurchaseOrderWrapper     = new PurchaseOrder(currentPurchaseOrder);

            //WCH 18/10/2019 C-003417 SO Number in PO Delivery Note
            CountryCodeInformationsMapping__c currentCountryInfo = CountryCodeInformationsMapping__c.getInstance(currentPurchaseOrder.TECH_AssessmentCountryCode__c);
            displaySONumber=(currentCountryInfo==null || String.isBlank(currentPurchaseOrder.PrerequisiteOrder__r.Name))?false:currentCountryInfo.ShowSONumberInDistributorDeliveryNote__c;

            POisInAgencyMode= (currentPurchaseOrder.AgencyMode__c && currentPurchaseOrder.TECH_AssessmentCountryCode__c.equals('FR'));//WCH 01/04/2019 C-003060 Agency Mode

            String fileName             = Label.Delivery_note + '_' + currentPurchaseOrder.Name + '_' + System.now().format('dd-MM-yy') + '.pdf';

            if(ApexPages.currentPage().getParameters().get('force_download') == 'true')
            {
                ApexPages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename=' + fileName);
            }
            else
            {
                ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
            }


            for (OrderLine__c currentOrderLine :[SELECT     Id, PartNumber__c, Description__c, Quantity__c, Type__c, CataloguePrice__c,
                                                            OrderType__c, OriginalItem__c, OriginalItem__r.OriginalItem__c, PreselectedForOrder__c,
                                                            CreatedDate, AcceptedCheck__c, Suppliable__c 
                                                FROM        OrderLine__c
                                                WHERE       PurchaseOrder__c = :currentPurchaseOrder.Id
                                                ORDER BY    Name ASC])


            {
                if(!hasPreselectedParts)
                {
                    hasPreselectedParts = currentOrderLine.PreselectedForOrder__c;
                }

                // check if the order line is an original one
                if (currentOrderLine.OrderType__c == 'ORIGINAL')
                {
                    if (!mapOrderLineWrapper.containsKey(currentOrderLine.Id))
                    {
                        mapOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
                    }
                    else
                    {
                        mapOrderLineWrapper.get(currentOrderLine.Id).setOriginalItem(currentOrderLine);
                    }
                }
                // check if the order line is a final one
                else if (currentOrderLine.OrderType__c == 'FINAL')
                {
                    // there are two types for the final order line
                    // One can be the original one itself (that has been converted to final)
                    // --- Therefore OriginalItem__c should be null
                    // The second one is that the final order line is the alternative or final of a bundle
                    // --- Therefore OriginalItem__c should not be null

                    if (currentOrderLine.OriginalItem__c == null)
                    {
                        // Original that has been converted to final
                        if (!mapOrderLineWrapper.containsKey(currentOrderLine.Id))
                        {
                            mapOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
                        }
                    }
                    else
                    {
                        // Final can be alternative or final for bundle
                        if (!mapOrderLineWrapper.containsKey(currentOrderLine.OriginalItem__c))
                        {
                            mapOrderLineWrapper.put(currentOrderLine.OriginalItem__c, new OrderLineWrapper(currentOrderLine));
                        }
                        else
                        {
                            mapOrderLineWrapper.get(currentOrderLine.OriginalItem__c).setFinalItem(currentOrderLine);
                        }
                    }
                }
                // check if it is a bundle item
                else if (currentOrderLine.OrderType__c == 'BUNDLEITEM')
                {
                    if (!mapOrderLineWrapper.containsKey(currentOrderLine.OriginalItem__r.OriginalItem__c))
                    {
                        mapOrderLineWrapper.put(currentOrderLine.OriginalItem__r.OriginalItem__c, new OrderLineWrapper(currentOrderLine));
                    }
                    else
                    {
                        mapOrderLineWrapper.get(currentOrderLine.OriginalItem__r.OriginalItem__c).addBundleItem(currentOrderLine);
                    }
                }
                // else if (currentOrderLine.OrderType__c == 'SHIPPING COST')
                // {
                //  mapOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
                // }
            }
        }
    }

    public class PurchaseOrder
    {
        public PurchaseOrder__c currentPurchaseOrder {get; set;}
        public String name {get; set;}
        public String BodyShopOrderNumber {get; set;}
        public String claimReference {get; set;}
        public String plateNumber {get; set;}
        public String status {get; set;}
        public String VINNumber {get; set;}
        public String SoNumber {get; set;}//WCH 22/10/2019 C-003417
        public Boolean isQuotation {get; set;}

        public PurchaseOrder(PurchaseOrder__c po)
        {
            currentPurchaseOrder    = po;
            name                    = currentPurchaseOrder.Name;
            BodyShopOrderNumber     = currentPurchaseOrder.BodyShopOrderNumber__c;
            claimReference          = currentPurchaseOrder.ClaimNumber__c;
            plateNumber             = currentPurchaseOrder.PlateNumber__c;
            status                  = currentPurchaseOrder.Status__c;
            VINNumber               = currentPurchaseOrder.VINNumber__c;
            SoNumber                = currentPurchaseOrder.PrerequisiteOrder__r.Name;//WCH 22/10/2019 C-003417

            if(currentPurchaseOrder.RecordType.Name == 'DraftQuote')
            {
                isQuotation         = true;
            }
            else
            {
                isQuotation         = false;
            }
        }
    }

    public String getAddress()
    {
        return    '\n'+
                    '<div style="text-align:right;">\n'+
                    '<p style="font-weight:bold;">' + String.valueOf(currentPurchaseOrder.BodyShopName__c) + '<br/>\n' +
                    String.valueOf(currentPurchaseOrder.BodyShopAddress__c) +
                    '</p>\n'+
                    //WCH 01/04/2019 C-003060 Agency Mode
                    ((currentPurchaseOrder.AgencyMode__c && currentPurchaseOrder.TECH_AssessmentCountryCode__c.equals('FR'))?(String.isBlank(currentPurchaseOrder.Assessment__r.BodyShop__r.Phone)?'':('<p>'+currentPurchaseOrder.Assessment__r.BodyShop__r.Phone+'</p>')):'')+
                    ((currentPurchaseOrder.AgencyMode__c && currentPurchaseOrder.TECH_AssessmentCountryCode__c.equals('FR'))?(String.isBlank(currentPurchaseOrder.Assessment__r.BodyShop__r.ContactUser__r.Fax)?'':('<p>'+currentPurchaseOrder.Assessment__r.BodyShop__r.ContactUser__r.Fax+'</p>')):'')+
                    ((currentPurchaseOrder.AgencyMode__c && currentPurchaseOrder.TECH_AssessmentCountryCode__c.equals('FR'))?(String.isBlank(currentPurchaseOrder.Assessment__r.BodyShop__r.ContactUser__r.Email)?'':('<p>'+currentPurchaseOrder.Assessment__r.BodyShop__r.ContactUser__r.Email+'</p>')):'')+
                    '</div>\n';
    }
    public String getAlphaScaleFranceContactInfo()
    {
        return    '\n'+
                    '<div style="text-align:left;">\n'+
                    '<p> <span style="font-weight:bold;">Alpha Scale France SAS</span><br/>Commandez la simplicité<br/>Une question ? Une Demande ?<br/>Contactez-nous au : '+Label.AspisStandardPhoneNumber+'<br/>'+Label.AspisServiceEmailAddress+/*WCH 31/05/2019 C-003212*/
                    '</p>\n'+
                    '</div>\n';
    }

    // Wrapper class for order lines
    public class OrderLineWrapper
    {
        // the original order line
        public OrderLineItem originalOrderLine {get; set;}
        
        // the final order line
        public OrderLineItem finalOrderLine {get; set;}
        
        // the list of bundle items
        public List<OrderLineItem> bundleItemList {get; set;}

        // variable to know if the wrapper contains an original order line with OrderType = FINAL
        public Boolean isFinalOriginal
        {
            get
            {
                return (finalOrderLine != null && 
                        finalOrderLine.currentOrderLine.OrderType__c == 'FINAL' &&
                        finalOrderLine.currentOrderLine.OriginalItem__c == null);
            }
        }

        // variable to know if there is an alternative for the original order line
        public Boolean isFinalAltenative
        {
            get
            {
                return (finalOrderLine != null &&
                        finalOrderLine.currentOrderLine.OrderType__c == 'FINAL' && 
                        finalOrderLine.currentOrderLine.OriginalItem__c != null &&
                        bundleItemList.size() == 0);
            }
        }

        // variable to know if the wrapper is a bundle one
        public Boolean isBundle
        {
            get
            {
                return (bundleItemList.size() > 0);
            }
        }

        public Boolean isPreselectedForOrder
        {
            get
            {
                if(isFinalOriginal)
                {
                    return finalOrderLine.currentOrderLine.PreselectedForOrder__c;
                }
                else
                {
                    return originalOrderLine.currentOrderLine.PreselectedForOrder__c;
                }
            }
        }

        public Boolean isAcceptedByBS
        {
            get
            {
                if(isFinalOriginal)
                {
                    return finalOrderLine.currentOrderLine.AcceptedCheck__c;
                }
                else
                {
                    return originalOrderLine.currentOrderLine.AcceptedCheck__c;
                }
            }
        }

        public Boolean isSuppliable
        {
            get
            {
                if(isFinalOriginal)
                {
                    return finalOrderLine.currentOrderLine.Suppliable__c != 'NO';
                }
                else
                {
                    return originalOrderLine.currentOrderLine.Suppliable__c != 'NO';
                }
            }
        }

        // public Boolean isSuppliableAndNotAcceptedByBS
        // {
        //  get
        //  {
        //      if(isFinalOriginal)
        //      {
        //          return  finalOrderLine.currentOrderLine.Suppliable__c == 'YES' &&
        //                  !finalOrderLine.currentOrderLine.AcceptedCheck__c;
        //      }
        //      else
        //      {
        //          return  originalOrderLine.currentOrderLine.Suppliable__c == 'YES' && 
        //                  !originalOrderLine.currentOrderLine.AcceptedCheck__c;
        //      }
        //  }
        // }


        public OrderLineWrapper(OrderLine__c currentOL)
        {
            // Initialising the list
            bundleItemList              = new List<OrderLineItem>();
            
            if (currentOL.OrderType__c == 'ORIGINAL')
            {
                originalOrderLine = new OrderLineItem(currentOL);
            }
            else if (currentOL.OrderType__c == 'FINAL'/* ||
                     currentOL.OrderType__c == 'SHIPPING COST'*/)
            {
                finalOrderLine = new OrderLineItem(currentOL);
            }
            else if (currentOL.OrderType__c == 'BUNDLEITEM')
            {
                bundleItemList.add(new OrderLineItem(currentOL));
            }
        }

        public void setOriginalItem(OrderLine__c originalOL)
        {
            if(originalOrderLine == null)
            {
                originalOrderLine = new OrderLineItem(originalOL);
            }
        }

        public void setFinalItem(OrderLine__c finalOL)
        {
            finalOrderLine = new OrderLineItem(finalOL);
        }

        public void addBundleItem(OrderLine__c currentOL)
        {
            bundleItemList.add(new OrderLineItem(currentOL));
        }
    }

    public class OrderLineItem
    {
        public OrderLine__c currentOrderLine {get; set;}
        public String partNumber {get; set;}
        public String description {get; set;}
        public Decimal quantity {get; set;}
        public String type {get; set;}
        public Decimal cataloguePrice {get; set;}
        public String createdDate {get; set;}

        public OrderLineItem(OrderLine__c ol)
        {
            currentOrderLine    = ol;
            partNumber          = ol.PartNumber__c;
            description         = ol.Description__c;
            quantity            = ol.Quantity__c;
            type                = ol.Type__c;
            cataloguePrice      = ol.CataloguePrice__c;
            createdDate         = ol.CreatedDate.date().format();
        }
    }
    
      public boolean verifyPermission(Id recordId){
        return ([SELECT  RecordId
                FROM    UserRecordAccess
                WHERE   RecordId =: recordId
                AND     UserId =: UserInfo.getUserId()
                AND     HasReadAccess = true].size() > 0);
    }
}