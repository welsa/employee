// TO BE DELETED
/*************************************************************************************
Class Name - VFC06_SOManageOffers_V2
Version - 1.0
Created Date - 
Function - Controller for page VFP06_SOManageOffers_V2

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga U              09/02/2016  updated code for case 1523  
*************************************************************************************/
public with sharing class VFC06_SOManageOffers_V2 { 
//
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
//    public List<Offer__c> l_OffersToUpdate { get; set;}
//    public Set<String> s_OfferTypesToUpdate { get; set;}
//    
//    // Indicates if some changes need to be saved.
//    public Boolean hasSomeChangesNotSaved{ get; set; }
//    
//    // Map which stores all existing Order Lines related to the current Purchase Order.
//    //   - Key :    SFDC Id of the Order Item
//    //   - Value :  Offer  
//    public Map<Id,Offer__c> m_Id2Offer {get;set;}
//    
//    public Map<String, Integer> m_OfferType2NbItems {get;set;}
//    public Map<Id, Boolean> m_OfferId2HasSomeAlternatives {get;set;}
//    
//    public Map<Id, List<OfferBundleItemWrapper>> m_OfferId2ListBundleItems {get;set;}
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
//    public Map<String,Integer> m_OfferType2DisplayPriority {get;set;}
//
//    public List<Offer__c> l_UnsuppliableOffers {
//        get{
//            return m_OfferType2ListItems.get(System.Label.OFFERUNSUPPLIEABLEITEM);
//        }
//        set;
//    }    
//    
//    public List<SelectOption> l_OfferTypeOptions {get;set;}
//    public String typeByDefault {get; set;}
//    public Boolean noData {get;set;}
//    public String previousSelectedOfferType {get;set;}
//
//    // new dev: can we respond
//    public String isDisabled {get;set;}
//    public String isDisabledSave {get;set;}
//    public String styleClassValidateButton {get;set;}
//	
//	public Boolean renderSelectOption{get;Set;}
//
//    /*############################################################################
//    #   C.O.N.S.T.R.U.C.T.O.R
//    ##############################################################################*/
//    public VFC06_SOManageOffers_V2(ApexPages.StandardController controller) {
//        // Get the current Sales Order
//        currSalesOrder = (PrerequisiteOrder__c)controller.getRecord();
//        
//        l_OffersToUpdate = new List<Offer__c>();
//        s_OfferTypesToUpdate = new Set<String>();
//        m_OfferType2ListItems = new Map<String, List<Offer__c>>();
//        m_OfferType2ListTable = new Map<String, List<String>>();
//        m_OfferType2LabelSection = new Map<String, String>();
//        m_OfferId2HasSomeAlternatives = new Map<Id, Boolean>();
//        m_OfferType2NbItems = new Map<String, Integer>();
//        m_OfferType2DisplayPriority = new Map<String,Integer>();
//        m_OfferId2ListBundleItems = new Map<Id, List<OfferBundleItemWrapper>>();
//        isEditMode = TRUE;
//		renderSelectOption = FALSE;
//        Integer Counter = 0;
//        
//        // Check if the connected user is an admin
//        isAdmin = System.Label.PROFILEADMINIDS.contains(UserInfo.getProfileId());
//        // If the current Purchase Order has not the Status "DRAFTQUOTE", the page stays in read only mode, except if the connected user is an admin.
//        /*       if(currSalesOrder.Status__c == 'DELIVEREDCONFIRMED' && !isAdmin)
//isAlwaysReadOnly = TRUE;
//else
//isAlwaysReadOnly = FALSE;*/
//
//        m_Id2Offer = new Map<Id,Offer__c>([SELECT Id,Name,Accepted__c,ParentOffer__c, Prerequisiteorder__r.OfferType__c, CataloguePrice__c,ExpectedDeliveryDuration__c,DisplayPriority__c,OrderType__c,OriginalCatalogPrice__c,OriginalDescription__c,OriginalManufacturer__c,OriginalPartNumber__c,OriginalType__c,BundleItemsDescription__c,OrderLine__r.PartList__r.CompliantPart__c,OrderLine__r.PurchaseOrder__r.Distributor__r.Id,BSTotalPrice__c ,DeliveryStatus__c,Description__c,Discount__c,Distributor__c ,Invoice__c,FinalType__c,Manufacturer__c,OfferReference__c,OrderLine__c,PartNUmber__c,Price__c,PurchaseOrder__c,Quantity__c,Prerequisiteorder__c,Selected__c,TechOrder__c,Total__c,Type__c  FROM Offer__c WHERE Prerequisiteorder__c = :controller.getId() ORDER BY DisplayPriority__c,Type__c,Name ASC]);
//
//        // new dev: can we respond-DUN 11/08/2015
//        Integer countaccpnull  = 0; 
//        Integer countaccpval  = 0;  
//        String offerType = ''; 
//        for(Offer__c off: m_Id2Offer.values()){
//            offerType = off.Prerequisiteorder__r.OfferType__c;
//        }
//
//        for(Offer__c off: m_Id2Offer.values()){ 
//            if(off.Type__c == offerType){
//                if(off.Accepted__c == null){ 
//                    countaccpnull ++; 
//                } 
//                else{ 
//                    countaccpval ++; 
//                } 
//            }
//        }
//    
//        if(countaccpval > 0 && countaccpnull == 0) {
//            isDisabled = 'false';
//            styleClassValidateButton = 'styleClassValidateButtonActive';
//        }
//        else if(countaccpval == 0 && countaccpnull > 0) {
//            isDisabled = 'true';
//            styleClassValidateButton = 'styleClassValidateButtonPassive';
//        }
//        else if(countaccpval > 0 && countaccpnull > 0) {
//            isDisabled = 'true';
//            styleClassValidateButton = 'styleClassValidateButtonPassive';
//        }
//        else if(countaccpval == 0 && countaccpnull == 0) {
//            isDisabled = 'true';
//            styleClassValidateButton = 'styleClassValidateButtonPassive';
//        }
//
//        if(currSalesOrder.Status__c == 'RESPONDED'){
//            isDisabled = 'true';
//            isDisabledSave = 'true';
//            styleClassValidateButton = 'styleClassValidateButtonPassive';
//        }
//
//        for(Offer__c off: m_Id2Offer.values()){ 
//            // Build the list of Offer based on Offer type.
//            // Add the current offer to the list of Offers with this specific type.
//            //DUN 08/01/2015 - correction of display when final
//            if(off.OrderType__c == 'FINAL'){
//                if(m_OfferType2ListItems.containsKey(off.Type__c)){
//                    m_OfferType2ListItems.get(off.Type__c).add(off);
//                    m_OfferType2ListItems.get(off.Type__c).sort();
//                } else {
//                    m_OfferType2ListItems.put(off.Type__c, new List<Offer__c>{off});
//                }
//            }
//            
//            // Store the number of item with this specific type.
//            if(m_OfferType2ListItems.containsKey(off.Type__c)){
//                m_OfferType2NbItems.put(off.Type__c, m_OfferType2ListItems.get(off.Type__c).size());
//            }
//
//            if(!m_OfferType2ListItems.containsKey(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c)){
//                m_OfferType2ListItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c, new List<Offer__c>());
//                m_OfferType2NbItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + off.Type__c, 0);
//            }
//            if(!m_OfferType2ListItems.containsKey(System.Label.OFFERNOTSELECTEDITEM + off.Type__c)){
//                m_OfferType2ListItems.put(System.Label.OFFERNOTSELECTEDITEM + off.Type__c, new List<Offer__c>());
//                m_OfferType2NbItems.put(System.Label.OFFERNOTSELECTEDITEM + off.Type__c, 0);
//            }
//
//            // Add the current offer to the list of Offers with this specific type.
//            if(!m_OfferType2ListTable.containsKey(off.Type__c) && !off.Type__c.contains(System.Label.OFFERNOTSELECTEDITEM) && !off.Type__c.contains(System.Label.OFFERUNSUPPLIEABLEITEM) ){
//                m_OfferType2ListTable.put(off.Type__c, new List<String>{off.Type__c, System.Label.OFFERNOTSELECTEDITEM+off.Type__c, System.Label.OFFERUNSUPPLIEABLEITEM+off.Type__c});
//                m_OfferType2LabelSection.put(off.Type__c, System.Label.SuppliedBy);
//                m_OfferType2LabelSection.put(System.Label.OFFERNOTSELECTEDITEM+off.Type__c, System.Label.NotSelected);
//                m_OfferType2LabelSection.put(System.Label.OFFERUNSUPPLIEABLEITEM+off.Type__c, System.Label.NotSupplied);
//            }
//
//            // Build Hierarchie of Offers based on Order Type.
//            // Build the list of bundle Items, if applicable
//            List<String> l_bundleItems = new List<String>();
//            List<String> l_bundleItemFields = new List<String>();
//
//            //DUN 08/07/2015 Commented as it has been indicated that bundle description is obsolete
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
//                }
//            } else {
//                m_OfferId2HasSomeAlternatives.put(off.Id, FALSE);
//            }*/
//
//            if(off.ParentOffer__c != null){
//                m_OfferId2HasSomeAlternatives.put(off.ParentOffer__c, TRUE);
//                OfferBundleItemWrapper newOffer = new OfferBundleItemWrapper(
//                                off.Id,
//                                String.valueOf(off.FinalType__c),
//                                String.valueOf(off.PartNUmber__c),
//                                String.valueOf(off.Description__c),
//                                String.valueOf(off.Manufacturer__c),
//                                String.valueOf(off.CataloguePrice__c),
//                                String.valueOf(off.ExpectedDeliveryDuration__c),
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
//
//            // Build the display priority list
//            
//            if(!m_OfferType2DisplayPriority.containsKey(off.Type__c)){
//                counter++;
//                m_OfferType2DisplayPriority.put(off.Type__c, counter);
//            }
//        }
//
//        // Initiate the picklist values with the display priority if exist
//        if(m_OfferType2DisplayPriority.values() != null){
//            l_OfferTypeOptions = new SelectOption[m_OfferType2DisplayPriority.values().size()+1];
//        }
//        else{
//            //system.debug('## if');             
//            l_OfferTypeOptions = new List<SelectOption>();
//        }
//        
//        // Create the options list for the picklist "Offer Type"
//        for(String offType : m_OfferType2ListItems.keySet()){
//            if(!offType.contains(System.Label.OFFERUNSUPPLIEABLEITEM) && !offType.contains(System.Label.OFFERNOTSELECTEDITEM)){
//                if(m_OfferType2DisplayPriority.containsKey(offType) && m_OfferType2DisplayPriority.get(offType) != null){
//                    //if(l_OfferTypeOptions.size() > m_OfferType2DisplayPriority.get(offType)){
//                        l_OfferTypeOptions.set(m_OfferType2DisplayPriority.get(offType), new SelectOption(offType, offType));
//                    //}
//                }
//                else{
//                    l_OfferTypeOptions.add(new SelectOption(offType, offType));
//                }
//            }
//			else{
//				if(m_OfferType2ListItems.get(offType).size() > 0){
//					String typeValue = '';
//					if(offType.contains(System.Label.OFFERUNSUPPLIEABLEITEM)){
//						if(offType.split(System.Label.OFFERUNSUPPLIEABLEITEM).size() > 1)
//							typeValue = offType.split(System.Label.OFFERUNSUPPLIEABLEITEM)[1];
//						
//					}
//					else if(offType.contains(System.Label.OFFERNOTSELECTEDITEM)){
//						if(offType.split(System.Label.OFFERNOTSELECTEDITEM).size() > 0)
//							typeValue = offType.split(System.Label.OFFERNOTSELECTEDITEM)[1];
//						
//					}
//					Boolean existValue = false;
//					for(SelectOption sp: l_OfferTypeOptions){
//						if(sp != null && sp.getValue() == typeValue){
//							existValue = true;
//							break;
//						}
//					}
//					if(existValue == false)
//						l_OfferTypeOptions.add(new SelectOption(typeValue, typeValue));
//				}
//			}
//			/*String typeValue = offType;
//			if(offType.contains(System.Label.OFFERUNSUPPLIEABLEITEM)){
//				typeValue = typeValue.split(System.Label.OFFERUNSUPPLIEABLEITEM)[1];
//				
//			}
//			if(offType.contains(System.Label.OFFERNOTSELECTEDITEM)){
//				typeValue = typeValue.split(System.Label.OFFERUNSUPPLIEABLEITEM)[1];
//				
//			}*/
//        }
//
//        //l_OfferTypeOptions.sort();
//
//        // Add a "None" type in the map if no type has been found.
//        if(l_OfferTypeOptions.size() == 0){
//            l_OfferTypeOptions.add(new SelectOption('','--None--'));
//        }
//        
//        // Add default value for the picklist.
//        if(currSalesOrder.OfferType__c == null)
//        {
//            /*if(m_OfferType2ListItems.containsKey('QUICK')){
//                currSalesOrder.OfferType__c = 'QUICK';
//            }/*else if(l_OfferTypeOptions[0] != null && l_OfferTypeOptions[0].getValue() != ''){
//                currSalesOrder.OfferType__c = l_OfferTypeOptions[0].getValue();
//            } */
//            //else{
//                for(integer i=0; i < l_OfferTypeOptions.size(); i++){
//                    if(l_OfferTypeOptions[i] != null && l_OfferTypeOptions[i].getValue() != ''){
//                        currSalesOrder.OfferType__c = l_OfferTypeOptions[i].getValue();
//                    }
//                }
//            //}
//         } 
//        // Add the current Sales Order Offertype in the map if not already exist.
//        else {
//            if(!m_OfferType2ListItems.containsKey(currSalesOrder.OfferType__c)) {            
//                m_OfferType2ListTable.put(currSalesOrder.OfferType__c, new List<String>{currSalesOrder.OfferType__c, System.Label.OFFERNOTSELECTEDITEM+currSalesOrder.OfferType__c, System.Label.OFFERUNSUPPLIEABLEITEM+currSalesOrder.OfferType__c});
//                m_OfferType2ListItems.put(currSalesOrder.OfferType__c, new List<Offer__c>());
//                m_OfferType2NbItems.put(currSalesOrder.OfferType__c, 0);
//                m_OfferType2LabelSection.put(currSalesOrder.OfferType__c, System.Label.SuppliedBy);
//                m_OfferType2LabelSection.put(System.Label.OFFERNOTSELECTEDITEM+currSalesOrder.OfferType__c, System.Label.NotSelected);
//                m_OfferType2LabelSection.put(System.Label.OFFERUNSUPPLIEABLEITEM+currSalesOrder.OfferType__c, System.Label.NotSupplied);
//            }
//            if(!m_OfferType2ListItems.containsKey(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c)){
//                m_OfferType2ListItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c, new List<Offer__c>());
//                m_OfferType2NbItems.put(System.Label.OFFERUNSUPPLIEABLEITEM + currSalesOrder.OfferType__c, 0);
//            }
//            if(!m_OfferType2ListItems.containsKey(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c)){
//                m_OfferType2ListItems.put(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c, new List<Offer__c>());
//                m_OfferType2NbItems.put(System.Label.OFFERNOTSELECTEDITEM + currSalesOrder.OfferType__c, 0);
//            }
//        }
//        previousSelectedOfferType = currSalesOrder.OfferType__c;
//		
//		//16.10.2015 DUN
//		Integer isNotNullValue = 0;
//		if(!(l_OfferTypeOptions.isEmpty())){
//			for(SelectOption sop : l_OfferTypeOptions){
//				if(sop != null){
//					//renderSelectOption = FALSE;
//					isNotNullValue ++;
//				}
//			}		
//		}
//		if(isNotNullValue >= 1){
//			renderSelectOption = TRUE;
//		}
//		/*for(SelectOption sop : l_OfferTypeOptions){
//			if(sop.getValue() == null)
//				System.debug('##sop');
//		}*/
//        
//     /*   if(currSalesOrder.AcceptedLines__c != 0)
//            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Please don\'t forget to validate your order by using the "Respond" button, after choosing your offer.'));
//       */
//    }
//    
//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    public PageReference saveAllChanges(){
//        List<Offer__c> l_OffersToUpdate = new List<Offer__c>();
//
//        for(STring offType : s_OfferTypesToUpdate){
//            l_OffersToUpdate.addAll(m_OfferType2ListItems.get(offType));
//        }
//
//        try{
//            if(l_OffersToUpdate.size() > 0)
//                update l_OffersToUpdate;
//            update currSalesOrder;
//        }catch(Exception ex){
//            Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers_V2', 'Prerequisiteorder__c', ex);
//            hasSomeChangesNotSaved = true;    
//            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the update.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            return null;
//        }
//        hasSomeChangesNotSaved = FALSE;
//
//        //DUN 18/08/2015 refresh embedded visualforce page           
//        //Pagereference redirect = new Pagereference('/'+currSalesOrder.Id);
//        Pagereference redirect = ApexPages.currentPage();
//        redirect.getParameters().put('Id',currSalesOrder.Id);
//        redirect.setRedirect(TRUE);
//        return redirect;
//    }
//    
//    public void changeOfferTypeSelected(){
//        hasSomeChangesNotSaved = true;
//        if(previousSelectedOfferType != currSalesOrder.OfferType__c){
//            for(Offer__c off : m_OfferType2ListItems.get(previousSelectedOfferType)){
//                off.Accepted__c = '';
//            }
//            if(!s_OfferTypesToUpdate.contains(previousSelectedOfferType))
//                s_OfferTypesToUpdate.add(previousSelectedOfferType); 
//            previousSelectedOfferType = currSalesOrder.OfferType__c;            
//        }
//    }
//
//    public void currentLineNeedUpdate(){
//        hasSomeChangesNotSaved = true;
//        if(!s_OfferTypesToUpdate.contains(m_Id2Offer.get(selectedOrderItem).Type__c))
//            s_OfferTypesToUpdate.add(m_Id2Offer.get(selectedOrderItem).Type__c); 
//    }
//    
//    public void currOfferIsAcceptedByBS() {
//        hasSomeChangesNotSaved = true;
//        m_Id2Offer.get(selectedOrderItem).Accepted__c = 'YES';
//        if(m_OfferId2ListBundleItems.containsKey(selectedOrderItem)){
//            for(OfferBundleItemWrapper offwrap : m_OfferId2ListBundleItems.get(selectedOrderItem)){
//                l_OffersToUpdate.add(new Offer__c(Id = offwrap.OffId, Accepted__c = 'YES'));
//            }
//        }
//
//        if(!s_OfferTypesToUpdate.contains(m_Id2Offer.get(selectedOrderItem).Type__c))
//            s_OfferTypesToUpdate.add(m_Id2Offer.get(selectedOrderItem).Type__c);
//
//        if(m_Id2Offer.get(selectedOrderItem).Type__c.contains(System.Label.OFFERNOTSELECTEDITEM))
//            m_Id2Offer.get(selectedOrderItem).Type__c = m_Id2Offer.get(selectedOrderItem).Type__c.replaceAll(System.Label.OFFERNOTSELECTEDITEM,'');
//
//        if(l_OffersToUpdate.size() > 0)
//                update l_OffersToUpdate;
//    }
//    
//    public void currOfferIsNotAcceptedByBS() {
//        hasSomeChangesNotSaved = true;
//        m_Id2Offer.get(selectedOrderItem).Accepted__c  = 'NO';
//        if(m_OfferId2ListBundleItems.containsKey(selectedOrderItem)){
//            for(OfferBundleItemWrapper offwrap : m_OfferId2ListBundleItems.get(selectedOrderItem)){
//                l_OffersToUpdate.add(new Offer__c(Id = offwrap.OffId, Accepted__c = 'NO'));
//            }
//        }
//
//        if(!s_OfferTypesToUpdate.contains(m_Id2Offer.get(selectedOrderItem).Type__c))
//            s_OfferTypesToUpdate.add(m_Id2Offer.get(selectedOrderItem).Type__c);
//
//        if(!m_Id2Offer.get(selectedOrderItem).Type__c.contains(System.Label.OFFERNOTSELECTEDITEM))            
//            m_Id2Offer.get(selectedOrderItem).Type__c = System.Label.OFFERNOTSELECTEDITEM + m_Id2Offer.get(selectedOrderItem).Type__c;
//
//        if(l_OffersToUpdate.size() > 0)
//                update l_OffersToUpdate;
//
//        //m_OfferType2ListItems.get(System.Label.OFFERNOTSELECTEDITEM + m_Id2Offer.get(selectedOrderItem).Type__c).add(m_Id2Offer.get(selectedOrderItem));
//        //m_OfferType2NbItems.put(System.Label.OFFERNOTSELECTEDITEM + m_Id2Offer.get(selectedOrderItem).Type__c,m_OfferType2ListItems.get(System.Label.OFFERNOTSELECTEDITEM + m_Id2Offer.get(selectedOrderItem).Type__c).size());
//    }
//    
//        
//    public pagereference goToEditMode(){    
//        isEditMode = TRUE;
//        //isDisabled = 'false'; // new dev
//        //styleClassValidateButton = 'styleClassValidateButtonActive';
//        return null;
//    }    
}