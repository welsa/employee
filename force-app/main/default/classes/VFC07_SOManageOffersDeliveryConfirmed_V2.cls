// TO BE DELETED
public with sharing class VFC07_SOManageOffersDeliveryConfirmed_V2 { 
//    public class OfferBundleItemWrapper {
//        public Id OffId {get;set;}
//        public String Name {get;set;}
//        public String Type {get;set;}
//        public String PartNumber {get;set;}
//        public String Description {get;set;}
//        public String Manufacturer {get;set;}
//        public String UnitPrice {get;set;}
//        public String Delivery {get;set;}
//        public String Quantity {get;set;}
//        public String TotalCPrice {get;set;}
//        public String Discount {get;set;}
//        public String Price {get;set;}
//        public String BSPrice {get;set;}
//
//        public OfferBundleItemWrapper(Id pId,String pType,String pPartNb,String pDescr,String pManuf,String pUnitPrice, String pDelivery,String pQuantity,String pTotalCPrice,String pDiscount,String pPrice,String pBSPrice){
//            this.OffId = pId;
//            this.Type = pType;
//            this.PartNumber = pPartNb;
//            this.Description = pDescr;
//            this.Manufacturer = pManuf;
//            this.UnitPrice = pUnitPrice;
//            this.Delivery = pDelivery;
//            this.Quantity = pQuantity;
//            this.TotalCPrice = pTotalCPrice;
//            this.Discount = pDiscount;
//            this.Price = pPrice;
//            this.BSPrice = pBSPrice;
//        } 
//    }   
//    /*############################################################################
//    #   A.T.T.R.I.B.U.T.E.S
//    ##############################################################################*/
//    // Current Purchase Order 
//    public PrerequisiteOrder__c currSalesOrder {get;set;}
//    // Indicates if we are in the edit mode or the read only mode
//    public Boolean isEditMode {get;set;}
//    // Indicates if we should always be in the read only mode
//    public Boolean isAlwaysReadOnly {get;set;}
//    // Indicates if the connected user is an Admin
//    public Boolean isAdmin {get;set;}
//    
//    // Identify the line selected for the action
//    public String selectedOrderItem {get;set;}
//    public Integer selectedAltItem {get;set;}
//    public String selectedOfferType {get;set;}
//        
//    // Set of SFDC Id of original items that have been modified. Used to find the wrapper and update all related items.
//    public Set<Offer__c> s_OffersToUpdate { get; set;}
//    
//    // Indicates if some changes need to be saved.
//    public Boolean hasSomeChangesNotSaved{ get; set; }
//    
//    // Map which stores all existing Order Lines related to the current Purchase Order.
//    //   - Key :    SFDC Id of the Order Item
//    //   - Value :  Offer  
//    public Map<Id,Offer__c> m_Id2Offer {get;set;}
//    public List<Offer__c> l_Offers {
//        get{
//            return m_Id2Offer.values();
//        }
//        set;
//    }
//
//    
//    public Map<String, Integer> m_OfferType2NbItems {get;set;}
//    public Map<Id, Boolean> m_OfferId2HasSomeAlternatives {get;set;}
//    
//    public Map<Id, List<OfferBundleItemWrapper>> m_OfferId2ListBundleItems {get;set;}
//
//    public Map<String, List<Offer__c>> m_OfferType2ListItems {get;set;}
//    public List<String> l_OffersType {
//        get{
//            return new List<String>(m_OfferType2ListItems.keySet());
//        }
//        set;
//    } 
//    
//    public Map<String, List<String>> m_OfferType2ListTable {get;set;}
//    public Map<String, String> m_OfferType2LabelSection {get;set;}
//
//
//    public List<SelectOption> l_OfferTypeOptions {get;set;}
//    public String typeByDefault {get; set;}
//    public Boolean noData {get;set;}
//    public String previousSelectedOfferType {get;set;}
//    public List<Offer__c> l_OffersToUpdate = new List<Offer__c>();
//
//	// ABT 12-APR-2016
//	// Boolean to know if save is successful
//	public Boolean isSaveSuccessful {get; set;}
//
//
//    /*############################################################################
//    #   C.O.N.S.T.R.U.C.T.O.R
//    ##############################################################################*/
//    public VFC07_SOManageOffersDeliveryConfirmed_V2(ApexPages.StandardController controller) {
//        // Get the current Sales Order
//        currSalesOrder = (PrerequisiteOrder__c)controller.getRecord();
//        s_OffersToUpdate = new Set<Offer__c>();
//        l_OfferTypeOptions = new List<SelectOption>();
//        m_OfferType2ListItems = new Map<String, List<Offer__c>>();
//        m_OfferType2ListTable = new Map<String, List<String>>();
//        m_OfferType2LabelSection = new Map<String, String>();
//        m_OfferId2HasSomeAlternatives = new Map<Id, Boolean>();
//        m_OfferType2NbItems = new Map<String, Integer>();
//        m_OfferId2ListBundleItems = new Map<Id, List<OfferBundleItemWrapper>>();
//        isEditMode = TRUE;
//
//		// ABT 12-APR-2016
//		isSaveSuccessful = false;
//        
//        // Check if the connected user is an admin
//        isAdmin = System.Label.PROFILEADMINIDS.contains(UserInfo.getProfileId());
//        // If the current Purchase Order has the Status "PREORDERCONFIRMED", the page stays in read only mode, except if the connected user is an admin.
//        if(currSalesOrder.Status__c == 'PREORDERCONFIRMED' && !isAdmin)
//            isAlwaysReadOnly = TRUE;
//        else
//            isAlwaysReadOnly = FALSE;
//        
//        m_Id2Offer = new Map<Id,Offer__c>([SELECT Id,Name,Accepted__c,RealDeliveryDate__c,OrderLine__r.PartList__r.CompliantPart__c,ExpectedDeliveryDate__c,ParentOffer__c,ExpectedDeliveryDuration__c,CataloguePrice__c,TotalASPrice__c,BSCreditNotePrice__c, AdditionnalDiscount__c,OrderType__c,OriginalCatalogPrice__c,OriginalDescription__c,OriginalManufacturer__c,OriginalPartNumber__c,OriginalType__c,BundleItemsDescription__c,OrderLine__r.PurchaseOrder__r.Distributor__r.Id,BSTotalPrice__c,DeliveryStatus__c,Description__c,Discount__c,Distributor__c ,Invoice__c,FinalType__c,Manufacturer__c,OfferReference__c,OrderLine__c,PartNUmber__c,Price__c,PurchaseOrder__c,Quantity__c,Prerequisiteorder__c,Selected__c,TechOrder__c,Total__c,Type__c,Prerequisiteorder__r.TECH_BodyshopCountryCode__c  FROM Offer__c WHERE Prerequisiteorder__c = :controller.getId() AND Accepted__c = 'YES' ORDER BY Type__c,Name ASC]);
//        //system.debug('m_Id2Offer:'+m_Id2Offer.values());
//        for(Offer__c off: m_Id2Offer.values()){
//            if(off.RealDeliveryDate__c == null){
//                off.RealDeliveryDate__c = system.today();
//            }
//            //system.debug('offer:'+off);
//            //system.debug('offerType:'+off.Type__c);
//            if(off.Type__c!=null){
//                // Build the list of Offer based on Offer type.
//                // Add the current offer to the list of Offers with this specific type.
//                if(off.OrderType__c == 'FINAL'){
//                    if(m_OfferType2ListItems.containsKey(off.Type__c)){
//                        m_OfferType2ListItems.get(off.Type__c).add(off);
//                        m_OfferType2ListItems.get(off.Type__c).sort();
//                    } else {
//                        m_OfferType2ListItems.put(off.Type__c, new List<Offer__c>{off});
//                    }
//                }
//                // Store the number of item with this specific type.
//                m_OfferType2NbItems.put(off.Type__c, m_OfferType2ListItems.get(off.Type__c).size());
//
//                if(!m_OfferType2ListItems.containsKey(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c)){
//                    m_OfferType2ListItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c, new List<Offer__c>());
//                    m_OfferType2NbItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c, 0);
//                }
//                if(!m_OfferType2ListItems.containsKey(System.Label.OFFERNOTSELECTEDITEM + off.Type__c)){
//                    m_OfferType2ListItems.put(System.Label.OFFERNOTSELECTEDITEM + off.Type__c, new List<Offer__c>());
//                    m_OfferType2NbItems.put(System.Label.OFFERNOTSELECTEDITEM + off.Type__c, 0);
//                }
//
//                // Add the current offer to the list of Offers with this specific type.
//                if(!m_OfferType2ListTable.containsKey(off.Type__c) && !off.Type__c.contains(System.Label.OFFERNOTSELECTEDITEM) && !off.Type__c.contains(System.Label.OFFERUNSUPPLIEABLEITEM) ){
//                 //   m_OfferType2ListTable.put(off.Type__c, new List<String>{off.Type__c, System.Label.OFFERNOTSELECTEDITEM+off.Type__c, System.Label.OFFERUNSUPPLIEABLEITEM+off.Type__c});
//                    m_OfferType2ListTable.put(off.Type__c, new List<String>{off.Type__c});
//                    m_OfferType2LabelSection.put(off.Type__c, System.Label.SuppliedBy);
//                 //   m_OfferType2LabelSection.put(System.Label.OFFERNOTSELECTEDITEM+off.Type__c, System.Label.NotSelected);
//                 //   m_OfferType2LabelSection.put(System.Label.OFFERUNSUPPLIEABLEITEM+off.Type__c, System.Label.NotSupplied);
//                }
//            }
//            // Build Hierarchie of Offers based on Order Type.
//            // Build the list of bundle Items, if applicable
//            List<String> l_bundleItems = new List<String>();
//            List<String> l_bundleItemFields = new List<String>();
//
//            //DUN 09/07/2015 Commented as it has been indicated that bundle description is obsolete
//            /*if(off.BundleItemsDescription__c != null){
//                m_OfferId2HasSomeAlternatives.put(off.Id, TRUE);
//                l_bundleItems = off.BundleItemsDescription__c.split('\\|');
//                for(String item : l_bundleItems){
//                    if(item != ''){
//                        l_bundleItemFields = item.split(';');
//                        if(l_bundleItems.size() != 0 && l_bundleItemFields.size() != 0){
//                            OfferBundleItemWrapper newOffer = new OfferBundleItemWrapper(
//                                l_bundleItemFields[0],
//                                l_bundleItemFields[1],
//                                l_bundleItemFields[2],
//                                l_bundleItemFields[3],
//                                l_bundleItemFields[4]
//                            );
//
//                            if(m_OfferId2ListBundleItems.containsKey(off.Id)){
//                                m_OfferId2ListBundleItems.get(off.Id).add(newOffer);
//                            } else {
//                                m_OfferId2ListBundleItems.put(off.Id, new List<OfferBundleItemWrapper>{newOffer});
//                            }
//                        }
//                    }
//
//                }
//            } else {
//                m_OfferId2HasSomeAlternatives.put(off.Id, FALSE);
//            }*/
//            if(off.ParentOffer__c != null){
//                m_OfferId2HasSomeAlternatives.put(off.ParentOffer__c, TRUE);
//                OfferBundleItemWrapper newOffer = new OfferBundleItemWrapper(
//                                off.Id,
//                                String.valueOf(off.FinalType__c),
//                                String.valueOf(off.PartNUmber__c),
//                                String.valueOf(off.Description__c),
//                                String.valueOf(off.Manufacturer__c),
//                                String.valueOf(off.CataloguePrice__c),
//                                //DUN case C-001464
//								//String.valueOf(off.ExpectedDeliveryDuration__c),
//								//String.valueOf(off.ExpectedDeliveryDate__c),
//								off.ExpectedDeliveryDate__c != null ? off.ExpectedDeliveryDate__c.format() : '',
//                                String.valueOf(off.Quantity__c),
//                                String.valueOf(off.Total__c),
//                                String.valueOf(off.Discount__c),
//                                String.valueOf(off.Price__c),
//                                String.valueOf(off.BSTotalPrice__c)
//                            );
//                if(m_OfferId2ListBundleItems.containsKey(off.ParentOffer__c)){
//                    m_OfferId2ListBundleItems.get(off.ParentOffer__c).add(newOffer);
//                } else {
//                    m_OfferId2ListBundleItems.put(off.ParentOffer__c, new List<OfferBundleItemWrapper>{newOffer});
//                }
//            }
//            else {
//                m_OfferId2HasSomeAlternatives.put(off.Id, FALSE);
//            }
//        }
//
//        // Create the options list for the picklist "Offer Type"
//        for(String offType : m_OfferType2ListItems.keySet()){
//            if(!offType.contains(System.Label.OFFERUNSUPPLIEABLEITEM) && !offType.contains(System.Label.OFFERNOTSELECTEDITEM)){
//                l_OfferTypeOptions.add(new SelectOption(offType, offType));
//            }
//        }
//        l_OfferTypeOptions.sort();
//
//        // Add a "None" type in the map if no type has been found.
//        if(l_OfferTypeOptions.size() == 0){
//            l_OfferTypeOptions.add(new SelectOption('','--None--'));
//        }
//        
//        // Add default value for the picklist.
//        if(currSalesOrder.OfferType__c == null && m_OfferType2ListItems.containsKey('QUICK')){
//            currSalesOrder.OfferType__c = 'QUICK';
//            previousSelectedOfferType = 'QUICK';
//        }else if(l_OfferTypeOptions[0].getValue() != ''){
//            currSalesOrder.OfferType__c = l_OfferTypeOptions[0].getValue();
//        }
//        previousSelectedOfferType = currSalesOrder.OfferType__c;
//        
//
//        // Add the current Sales Order Offertype in the map if not already exist.
//        if(!m_OfferType2ListItems.containsKey(currSalesOrder.OfferType__c)){
//            m_OfferType2ListTable.put(currSalesOrder.OfferType__c, new List<String>{currSalesOrder.OfferType__c, System.Label.OFFERNOTSELECTEDITEM+currSalesOrder.OfferType__c, System.Label.OFFERUNSUPPLIEABLEITEM+currSalesOrder.OfferType__c});
//            m_OfferType2ListItems.put(currSalesOrder.OfferType__c, new List<Offer__c>());
//            m_OfferType2NbItems.put(currSalesOrder.OfferType__c, 0);
//            m_OfferType2LabelSection.put(currSalesOrder.OfferType__c, System.Label.SuppliedBy);
//            m_OfferType2LabelSection.put(System.Label.OFFERNOTSELECTEDITEM+currSalesOrder.OfferType__c, System.Label.NotSelected);
//            m_OfferType2LabelSection.put(System.Label.OFFERUNSUPPLIEABLEITEM+currSalesOrder.OfferType__c, System.Label.NotSupplied);
//        }
//        
//        if(!m_OfferType2ListItems.containsKey(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c)){
//            m_OfferType2ListItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c, new List<Offer__c>());
//            m_OfferType2NbItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c, 0);
//        }
//        if(!m_OfferType2ListItems.containsKey(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c)){
//            m_OfferType2ListItems.put(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c, new List<Offer__c>());
//            m_OfferType2NbItems.put(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c, 0);
//        }
//
//    }
//    
//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    public PageReference saveAllChanges(){
//        l_OffersToUpdate = new List<Offer__c>(s_OffersToUpdate);
//        List<OrderLine__c> l_orderLinesToUpdate = new List<OrderLine__c>();
//        List<OrderLine__c> listOL = new List<OrderLine__c>();
//        Map<Id,Offer__c> mapOLIdOff = new Map<Id,Offer__c>();
//        Map<Id,List<OrderLine__c>> mapOLFinalListOL = new Map<Id,List<OrderLine__c>>();
//        OrderLine__c ol;
//
//		// ABT 12-APR-2016
//		isSaveSuccessful = false;
//    
//        //Check if some line is in Error status so a case should be created (unless parent purchaseorder is already associated with a case)
//        Boolean existErrorredLines = false;
//        for(Offer__c off: l_OffersToUpdate){
//            if(off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_MISSING || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DAMAGED || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_ERROR ){
//                ol = new OrderLine__c(Id=off.OrderLine__c, DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_ISSUE);
//            }
//            else if(off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_INDELIVERY || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELIVERED || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_DELAYED || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_CANCELED || off.DeliveryStatus__c==ASPISConstants.OFFER_STATUS_RETURNED ){
//                ol = new OrderLine__c(Id=off.OrderLine__c, DeliveryStatus__c = off.DeliveryStatus__c, RealDeliveryDate__c = off.RealDeliveryDate__c);
//            }
//            l_orderLinesToUpdate.add(ol);         
//
//            if(off.DeliveryStatus__c == 'NOTDELIVERED' || off.DeliveryStatus__c == 'MISSING' || off.DeliveryStatus__c == 'DAMAGED' || off.DeliveryStatus__c == 'ERROR' ){
//                existErrorredLines = true;
//                break;  
//            }
//        }
//        if(existErrorredLines){
//            Prerequisiteorder__c so = new Prerequisiteorder__c( id = currSalesOrder.id, HasSomeDeliveryIssuedCaseCreated__c = true);
//            try{
//                update so;
//            }catch(Exception ex){
//                if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
//                    Utils_ManageLogs.createLogFromException('VFC07_SOManageOffersDeliveryConfirmed_V2', 'Prerequisiteorder__c', ex);
//                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the Sales Order update.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//                }
//                return null;
//            }           
//        }
//
//        // Update the list of Offers.
//        try{
//            if(l_OffersToUpdate.size() > 0){
//                update l_OffersToUpdate;
//            }
//            if(l_orderLinesToUpdate.size()>0){
//                ASPISWithoutSharingExceptions.updateOrderLineList(l_orderLinesToUpdate);
//            }
//
//        }catch(Exception ex){
//            ////ASE: 06/04/2016: C-001587: Block the Bodyshop when he tries to canceled or returned an offer line 
//            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
//                Utils_ManageLogs.createLogFromException('VFC07_SOManageOffersDeliveryConfirmed_V2', 'Offer__c', ex);
//                hasSomeChangesNotSaved = true;    
//			     ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the update.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            }
//            return null;
//        }
//        
//        for(Offer__c off : s_OffersToUpdate){
//            if(m_Id2Offer.containsKey(off.Id)){
//                mapOLIdOff.put(m_Id2Offer.get(off.Id).OrderLine__c,m_Id2Offer.get(off.Id));
//            }
//        }
//        //DUN added query for all order lines - original, final, bundle
//        map <Id,OrderLine__c> mapIdOrderLine = new Map<Id,OrderLine__c>([select Id, OriginalItem__c, RealDeliveryDate__c, DeliveryStatus__c, OrderType__c from OrderLine__c where PurchaseOrder__r.PrerequisiteOrder__c =: currSalesOrder.Id]);
//        for(OrderLine__c orl:mapIdOrderLine.values()){
//            if(orl.OrderType__c == 'FINAL' && orl.OriginalItem__c != null){
//                if(mapOLFinalListOL.containsKey(orl.Id))
//                    mapOLFinalListOL.get(orl.Id).add(mapIdOrderLine.get(orl.OriginalItem__c));
//                else
//                    mapOLFinalListOL.put(orl.Id,new List <OrderLine__c>{mapIdOrderLine.get(orl.OriginalItem__c)});
//            }
//            else if(orl.OrderType__c == 'BUNDLEITEM'){
//                if(mapOLFinalListOL.containsKey(orl.OriginalItem__c))
//                    mapOLFinalListOL.get(orl.OriginalItem__c).add(mapIdOrderLine.get(orl.Id));
//                else
//                    mapOLFinalListOL.put(orl.OriginalItem__c,new List <OrderLine__c>{mapIdOrderLine.get(orl.Id)});
//            }
//        }
//        for(Id olId: mapOLIdOff.keySet()){
//            if(mapOLFinalListOL.containsKey(olId)){
//                for(OrderLine__c orl:mapOLFinalListOL.get(olId)){
//                    listOL.add(new OrderLine__c(Id=orl.Id, DeliveryStatus__c = mapOLIdOff.get(olId).DeliveryStatus__c, RealDeliveryDate__c = mapOLIdOff.get(olId).RealDeliveryDate__c));
//                }
//            }
//        }
//        if(listOL.size() > 0){
//            update listOL;
//        }
//
//		//Pagereference redirect = new Pagereference('/'+currSalesOrder.Id);
//		// ABT 12-APR-2016
//		isSaveSuccessful = true;
//		Pagereference redirect = ApexPages.currentPage();
//        redirect.setRedirect(false);
//        hasSomeChangesNotSaved = FALSE;
//        return redirect;
//    }
//
//    public void currentLineNeedUpdate(){
//        hasSomeChangesNotSaved = true;
//        map<Id,Offer__c> offmap = new map<Id,Offer__c>();
//        if(!s_OffersToUpdate.contains(m_Id2Offer.get(selectedOrderItem))){
//            if(m_OfferId2ListBundleItems.containsKey(selectedOrderItem)){
//                for(OfferBundleItemWrapper offwrap : m_OfferId2ListBundleItems.get(selectedOrderItem)){
//                    offmap.put(offwrap.OffId, new Offer__c(Id = offwrap.OffId, DeliveryStatus__c = m_Id2Offer.get(selectedOrderItem).DeliveryStatus__c, RealDeliveryDate__c = m_Id2Offer.get(selectedOrderItem).RealDeliveryDate__c));
//                }
//            }
//            s_OffersToUpdate.add(m_Id2Offer.get(selectedOrderItem));
//        }
//        if(offmap.size() > 0)
//            update offmap.values();
//    }
//        
//    public pagereference goToEditMode(){    
//        isEditMode = TRUE;
//        return null;
//    } 
//	
//	public void setDeliveredStatus(){    
//        if(m_OfferType2ListItems.containsKey(currSalesOrder.OfferType__c)){
//			for (Offer__c off : m_OfferType2ListItems.get(currSalesOrder.OfferType__c))
//			{
//				off.DeliveryStatus__c = 'DELIVERED';
//				off.RealDeliveryDate__c = Date.today();
//				s_OffersToUpdate.add(off);
//			}
//		}
//    }
}