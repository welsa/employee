// TO BE DELETED
public without sharing class VFC04_POManageOrderLines_V3 {
//    /*############################################################################
//    #   C.U.S.T.O.M. C.L.A.S.S
//    ##############################################################################*/
//    /*
//    *    Wrapper Class : Alternative
//    ******************************** */
//    public class AlternativeOrderLineWrapper {
//        public Integer index {get; set;}
//        public OrderLine__c alternative {get;set;}
//
//        // Total Price of the current item.
//        public Decimal ItemTotalNetPrice{
//            get{
//                Decimal total = 0;
//                
//                if(alternative != null && alternative.CataloguePrice__c != null && alternative.Quantity__c != null){
//                    
//                    total = alternative.CataloguePrice__c * alternative.Quantity__c;
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//
//         // AXA Total Price of the current item.
//        public Decimal ItemAXATotalNetPrice{
//            get{
//                Decimal total = 0;
//                if(alternative != null && alternative.Quantity__c != null){
//                    total = ItemAXAPrice * alternative.Quantity__c;
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//
//        // AXA Unit Price of the current item.
//        public Decimal ItemAXAPrice{
//            get{
//                Decimal total = 0;
//                
//                if(alternative != null && alternative.CataloguePrice__c != null && alternative.AXADiscount__c != null){
//                    total = alternative.CataloguePrice__c * (1-(alternative.AXADiscount__c/100));
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//        
//        /*---------------------------
//        -   C.O.N.S.T.R.U.C.T.O.R   -
//        ----------------------------*/
//        public AlternativeOrderLineWrapper(Integer i, OrderLine__c alt){
//            this.index = i;
//            this.alternative = alt;
//        }
//    }
//    
//    /*
//    *    Wrapper Class : Original
//    ******************************** */
//    public class OriginalOrderLineWrapper{
//        public OrderLine__c originalItem {get;set;}
//        // Is a "Final" order Line. Represents an unique alternative to the original, or the bundle which stores the bundle items.
//        public OrderLine__c bundleItem {get;set;}
//        
//        public Map<Integer, AlternativeOrderLineWrapper> m_index2AlternativeWrappers {get;set;}        
//        public List<AlternativeOrderLineWrapper> l_AlternativeWrappers {
//            get{
//                return m_index2AlternativeWrappers.values();
//            }
//            set;
//        }
//                
//        // Number of Bundle Items inside the current bundle.
//        public Integer nbAlternatives {
//            get{
//                return (l_AlternativeWrappers.size());
//            }
//            set;
//        }
//        
//        // Total Price of the current item.
//        public Decimal ItemTotalNetPrice{
//            get{
//                Decimal total = 0;
//                
//                if(originalItem != null && originalItem.CataloguePrice__c != null && originalItem.Quantity__c != null){
//                    if(bundleitem == null || bundleitem.CataloguePrice__c == null || bundleitem.Quantity__c == null)
//                        total = originalItem.CataloguePrice__c * originalItem.Quantity__c;
//                    else
//                        total = bundleitem.CataloguePrice__c * bundleitem.Quantity__c;
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//        
//        // AXA Total Price of the current item.
//        public Decimal ItemAXATotalNetPrice{
//            get{
//                Decimal total = 0;
//                if(originalItem != null && originalItem.Quantity__c != null){
//                    if(bundleitem == null || bundleitem.Quantity__c == null)
//                        total = ItemAXAPrice * originalItem.Quantity__c;
//                    else
//                        total = ItemAXAPrice * bundleitem.Quantity__c;
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//        
//        // AXA Unit Price of the current item.
//        public Decimal ItemAXAPrice{
//            get{
//                Decimal total = 0;
//                
//                if(originalItem != null && originalItem.CataloguePrice__c != null && originalItem.AXADiscount__c != null){
//                    if(bundleitem == null || bundleitem.CataloguePrice__c == null || bundleitem.AXADiscount__c == null)
//                        total = originalItem.CataloguePrice__c * (1-(originalItem.AXADiscount__c/100));
//                    else
//                        total = bundleitem.CataloguePrice__c * (1-(bundleitem.AXADiscount__c/100));
//                }
//                return total.SetScale(2);
//            }
//            set;
//        }
//        
//        // Indicates if the current Original Order Line has some bundle items.
//        public Boolean hasAlternatives {
//            get{
//                //system.debug('##'+l_AlternativeWrappers.size() +'&' +bundleItem);
//                if(l_AlternativeWrappers.size() == 0 && bundleItem == null)
//                    return FALSE;
//                else
//                    return TRUE;
//            }
//            set;
//        }
//        
//        /*---------------------------
//        -   C.O.N.S.T.R.U.C.T.O.R   -
//        ----------------------------*/
//        public OriginalOrderLineWrapper(OrderLine__c ori, OrderLine__c bundle, Map<Integer,AlternativeOrderLineWrapper> m_AltWraps){
//            this.originalItem = ori;
//            this.bundleItem = bundle;
//            this.m_index2AlternativeWrappers = new Map<Integer,AlternativeOrderLineWrapper>();
//            if(m_AltWraps != null)
//                this.m_index2AlternativeWrappers = m_AltWraps;
//        }
//    }
//    
//    /*############################################################################
//    #   A.T.T.R.I.B.U.T.E.S
//    ##############################################################################*/
//    // Current Purchase Order 
//    public PurchaseOrder__c currPurchaseOrder {get;set;}
//    // Indicates if we are in the edit mode or the read only mode
//    public Boolean isEditMode {get;set;}
//    public Boolean isNotValidated {get;set;}
//    
//    // new dev: can we validate
//    public String isDisabled {get;set;}
//    public String styleClassValidateButton {get;set;}
//    
//    
//    // Indicates if we should always be in the read only mode
//    public Boolean isAlwaysReadOnly {get;set;}
//    // Indicates if the connected user is an Admin
//    public Boolean isAdmin {get;set;}
//    
//    //RecordType name
//    Public String recordTypeEliminatedId {
//        get
//        { return  Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Eliminated').getRecordTypeId();}
//    }
//    
//    // Identify the line selected for the action
//    public String selectedOrderItem {get;set;}
//    public Integer selectedAltItem {get;set;}
//    //selected unsupplied
//    public String selectedOrderItemUnSupplied {get;set;}
//    
//    // Map which stores all existing Order Lines related to the current Purchase Order.
//    //   - Key :    SFDC Id of the Order Item
//    //   - Value :  Order Line  
//    public Map<Id,OrderLine__c> m_Id2OrderLine {get;set;}
//    public Map<Id, List<OrderLine__c>> m_OriginalOrderId2Alternatives {get;set;}
//    
//    // Map which stores all OriginalOrderLineWrapper records.
//    //   - Key :    SFDC Id of the original Order Item which are described in the wrapper
//    //   - Value :  Wrapper for an Order Line with some other informations   
//    public Map<Id,OriginalOrderLineWrapper> m_OriginalId2Wrapper {get;set;}
//    public List<OriginalOrderLineWrapper> l_OriginalWrappers {
//        get{
//            list<OriginalOrderLineWrapper> listSuppliable = new list<OriginalOrderLineWrapper>();
//            for(OriginalOrderLineWrapper supp : m_OriginalId2Wrapper.values()){
//                if(supp.originalItem.Suppliable__c != 'NO'){
//                    listSuppliable.add(supp);
//                }
//            }
//            //return m_OriginalId2Wrapper.values();
//            return listSuppliable;
//        }
//        set;
//    }
//
//    public List<OriginalOrderLineWrapper> l_OriginalWrappersUnSupp {
//        get{
//            list<OriginalOrderLineWrapper> listUnSuppliable = new list<OriginalOrderLineWrapper>();
//            for(OriginalOrderLineWrapper supp : m_OriginalId2Wrapper.values()){
//                if(supp.originalItem.Suppliable__c == 'NO'){
//                    listUnSuppliable.add(supp);
//                }
//            }
//            //return m_OriginalId2Wrapper.values();
//            return listUnSuppliable;
//        }
//        set;
//    }
//    
//    // List of existing Order Items we want to delete.
//    public List<OrderLine__c> l_AltItemsToDelete {get;set;}
//    // Set of SFDC Id of original items that have been modified. Used to find the wrapper and update all related items.
//    public Set<Id> s_OriginalItemsIdToUpsert { get; set;}
//    
//    // Indicates if some changes need to be saved.
//    public Boolean hasSomeChangesNotSaved{ get; set; }
//    public Boolean refreshPage { get; set; }
//
//    //List to display unsuppliable items
//    public list<OrderLine__c> l_UnsuppliableItems {get;set;}
//    
//    //BS
//    public String TypeOrderLine {get;Set;}
//    public Integer rowIndex {get;Set;}
//
//	// Variable CountryCodeInformationsMapping__c that keeps data about the min and max discount for A/S and B/S for france
//	// C-001578
//	CountryCodeInformationsMapping__c franceDiscountInfo;
//        
//    /*############################################################################
//    #   C.O.N.S.T.R.U.C.T.O.R
//    ##############################################################################*/
//    public VFC04_POManageOrderLines_V3(ApexPages.StandardController controller) {
//        // Get the current Purchase Order
//        currPurchaseOrder = (PurchaseOrder__c)controller.getRecord();
//        
//        s_OriginalItemsIdToUpsert = new Set<Id>();
//        l_AltItemsToDelete = new List<OrderLine__c>();
//        l_UnsuppliableItems = new List<OrderLine__c>();
//        m_OriginalOrderId2Alternatives = new Map<Id, List<OrderLine__c>>();
//        m_OriginalId2Wrapper = new Map<Id, OriginalOrderLineWrapper>();
//        isEditMode = FALSE;
//        isNotValidated = TRUE;
//        
//        // new dev: can we validate
//        Integer count1 = [ Select count() FROM OrderLine__c WHERE PurchaseOrder__c = :currPurchaseOrder.Id]; // number of OLs
//        Integer count2 = [ Select count() FROM OrderLine__c WHERE (Suppliable__c = 'YES' OR Suppliable__c = 'NO') AND PurchaseOrder__c = :currPurchaseOrder.Id]; // number of OLs checked YES or NO
//        if(apexpages.currentpage().getparameters().get('KeepEdit') == 'true'){
//            isEditMode = TRUE;
//        }
//        if(count1 == count2) {
//            isDisabled = 'false';
//            styleClassValidateButton = 'styleClassValidateButtonActive';
//        }
//        else {
//            isDisabled = 'true';
//            styleClassValidateButton = 'styleClassValidateButtonPassive';
//        }
//
//        // Check if the connected user is an admin
//        isAdmin = System.Label.PROFILEADMINIDS.contains(UserInfo.getProfileId());
//        // If the current Purchase Order has not the Status "DRAFTQUOTE", the page stays in read only mode, except if the connected user is an admin.
//        //if(currPurchaseOrder.Status__c != 'DRAFTQUOTE' && !isAdmin)
//        //    isAlwaysReadOnly = TRUE;
//        //else
//        //    isAlwaysReadOnly = FALSE;
//           
//		isAlwaysReadOnly = (currPurchaseOrder.Status__c != 'DRAFTQUOTE' && !isAdmin) ? true : false;
//        
//     /* CLA: not used because already done by the previous lines 
//       // new dev
//        if(currPurchaseOrder.Status__c == 'ISSUED'){
//            isNotValidated = FALSE;  // don't show buttons
//        }
//        else {
//            isNotValidated = TRUE;  // show buttons
//        }*/
//        
//        m_Id2OrderLine = new Map<Id,OrderLine__c>([SELECT Id,Name,AcceptedCheck__c,AdditionnalDiscount__c,VAT__c,TechGeneratedFinal__c,PartList__r.CompliantPart__c,Type__c,AXATotalPrice__c,BundleItemsDescription__c,PartList__c,OrderType__c,TotalPrice__c,OriginalItem__r.OriginalItem__c,PartNumber__c,ExpectedDeliveryDuration__c ,PartFamily__c,Manufacturer__c,Description__c,OriginalItem__c,CataloguePrice__c,Quantity__c,AXADiscount__c,AXAPrice__c,BodyShopDiscount__c,BodyShopPrice__c,Suppliable__c  FROM OrderLine__c WHERE PurchaseOrder__c = :controller.getId() ORDER BY Name ASC]);
//         
//        for(OrderLine__c ol : m_Id2OrderLine.values()){
//            //commented by bnu 10082015
//            //if(ol.Suppliable__c == 'YES' || ol.Suppliable__c == null){
//               if(ol.OrderType__c == 'BUNDLEITEM'){
//                    if(m_OriginalId2Wrapper.containsKey(ol.OriginalItem__r.OriginalItem__c)){
//                        m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).m_index2AlternativeWrappers.put(m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives, new AlternativeOrderLineWrapper(m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives,ol));
//                    } else {
//                        m_OriginalId2Wrapper.put(ol.OriginalItem__r.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__r.OriginalItem__c), m_Id2OrderLine.get(ol.OriginalItem__c), new Map<Integer,AlternativeOrderLineWrapper>{0 => new AlternativeOrderLineWrapper(0,ol)}));
//                    }
//                }
//                else if(ol.OrderType__c == 'FINAL'){
//                    if(ol.OriginalItem__c == null){
//                        if(!m_OriginalId2Wrapper.containsKey(ol.Id)){
//                            m_OriginalId2Wrapper.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                        }
//                    }
//                    else{
//                        if(m_OriginalId2Wrapper.containsKey(ol.OriginalItem__c)){
//                            m_OriginalId2Wrapper.get(ol.OriginalItem__c).bundleItem = ol;
//                        } else {
//                            m_OriginalId2Wrapper.put(ol.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__c), ol, new Map<Integer,AlternativeOrderLineWrapper>() ));
//                        }
//                    }
//                }
//                else{
//                    if(!m_OriginalId2Wrapper.containsKey(ol.Id)){
//                        m_OriginalId2Wrapper.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                    }
//                } 
//            //}
//            // //commented by bnu 10082015
//            /*
//            else if(ol.Suppliable__c == 'NO'){
//                l_UnsuppliableItems.add(ol);
//            }*/
//        }
//
//		// ABT - 28-MAR-2016 C-001578
//		// Retrieving custom settings for france
//		// in case not found display an error message
//		franceDiscountInfo = CountryCodeInformationsMapping__c.getInstance(currPurchaseOrder.TECH_AssessmentCountryCode__c);
//		if (franceDiscountInfo == null)
//		{
//			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.NoFRCountryMappingFound));
//		}
//    }
//    
//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    public void currOrderItemIsSuppliable() {
//        hasSomeChangesNotSaved = true;
//        if (m_OriginalId2Wrapper.get(selectedOrderItem) != null){
//            m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c  = 'YES';
//        }
//        if(!s_OriginalItemsIdToUpsert.contains(selectedOrderItem))
//            s_OriginalItemsIdToUpsert.add(selectedOrderItem);        
//    }
//    
//    public void currOrderItemIsNotSuppliable() {
//        hasSomeChangesNotSaved = true;
//        if (m_OriginalId2Wrapper.get(selectedOrderItem) != null){
//            m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c  = 'NO';
//        }
//        if(!s_OriginalItemsIdToUpsert.contains(selectedOrderItem))
//            s_OriginalItemsIdToUpsert.add(selectedOrderItem);        
//    }
//
//    public Pagereference currOrderItemIsUnSuppliable() {
//        list <Orderline__c> olToUpsert = new list <Orderline__c>();
//        if (m_Id2OrderLine.get(selectedOrderItemUnSupplied) != null){
//            m_Id2OrderLine.get(selectedOrderItemUnSupplied).Suppliable__c  = null;
//            olToUpsert.add(m_Id2OrderLine.get(selectedOrderItemUnSupplied));
//        }       
//
//        if(olToUpsert.size() > 0){
//            upsert olToUpsert;
//        }
//
//        Pagereference redirect = ApexPages.currentPage();
//        redirect.getParameters().put('Id',currPurchaseOrder.Id);
//        redirect.getParameters().put('KeepEdit','true');
//        redirect.setRedirect(TRUE);
//        return redirect;
//    }
//    
//    public void addNewAlternative(){
//        try{
//            hasSomeChangesNotSaved = true;
//
//			// ABT 06-MAY-2016 - Commented - C-001617
//			/*
//			// ABT 28-MAR-2016 C-001578
//			// Checking the AS and BS discount value before adding the bundle
//			// note once added the bundles data is check on save
//			if (franceDiscountInfo != null &&
//				(franceDiscountInfo.MinDiscountAS__c != null && m_Id2OrderLine.get(selectedOrderItem).AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c))
//			{
//				// Gives the error message
//
//				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//														   String.format(Label.ASDiscountErrorMsg, new List<String>
//																								   {
//																										String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																								   }
//																		 )
//														  )
//									 );
//			}
//			else if (franceDiscountInfo != null &&
//					 (franceDiscountInfo.MinDiscountBS__c != null && 
//					  franceDiscountInfo.DefaultBSDiscount__c == null && 
//					  m_Id2OrderLine.get(selectedOrderItem).BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c))
//			{
//				// Gives the error message
//				//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//
//				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//														   String.format(Label.BSDiscountErrorMsg, new List<String>
//																								   {
//																										String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																								   }
//																		 )
//														  )
//									 );
//			}
//            else 
//			*/
//			if(m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem == null){
//
//				// Create a new "FINAL" Order Line
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem = new OrderLine__c();
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.OriginalItem__c = selectedOrderItem;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.PartList__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.PartList__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.PurchaseOrder__c = currPurchaseOrder.Id;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.TechGeneratedFinal__c = false;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.OrderType__c = 'FINAL';
//
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Type__c = m_Id2OrderLine.get(selectedOrderItem).Type__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.PartNumber__c = m_Id2OrderLine.get(selectedOrderItem).PartNumber__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Description__c = m_Id2OrderLine.get(selectedOrderItem).Description__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Manufacturer__c = m_Id2OrderLine.get(selectedOrderItem).Manufacturer__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c = m_Id2OrderLine.get(selectedOrderItem).ExpectedDeliveryDuration__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Quantity__c = m_Id2OrderLine.get(selectedOrderItem).Quantity__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c = m_Id2OrderLine.get(selectedOrderItem).AXADiscount__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c = m_Id2OrderLine.get(selectedOrderItem).BodyShopDiscount__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.CataloguePrice__c = m_Id2OrderLine.get(selectedOrderItem).CataloguePrice__c;
//				m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.VAT__c = m_Id2OrderLine.get(selectedOrderItem).VAT__c;
//
//
//				// Update the "Original" Order Line to clear the useless fields.
//				//m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.AXADiscount__c = null;
//				//m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.CataloguePrice__c = null;
//				//m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.BodyShopDiscount__c = null;
//				//m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Quantity__c = null;
//				m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.OrderType__c = 'ORIGINAL';
//				m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.ExpectedDeliveryDuration__c = null;
//
//				if(!s_OriginalItemsIdToUpsert.contains(selectedOrderItem))
//					s_OriginalItemsIdToUpsert.add(selectedOrderItem);  
//            } else {
//                OrderLine__c newAlt = new OrderLine__c();
//                
//                // If the bundle already exists in Salesforce, add its ID on the OriginalItem field.
//                if(m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Id != null)
//                    newAlt.OriginalItem__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Id;
//                
//                newAlt.OrderType__c = 'BUNDLEITEM';
//                newAlt.Type__c = m_Id2OrderLine.get(selectedOrderItem).Type__c;
//                newAlt.PurchaseOrder__c = currPurchaseOrder.Id;
//
//                newAlt.PartNumber__c = m_Id2OrderLine.get(selectedOrderItem).PartNumber__c;
//                newAlt.Description__c = m_Id2OrderLine.get(selectedOrderItem).Description__c;
//                newAlt.Manufacturer__c = m_Id2OrderLine.get(selectedOrderItem).Manufacturer__c;
//                newAlt.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                newAlt.Quantity__c = m_Id2OrderLine.get(selectedOrderItem).Quantity__c;
//                newAlt.AXADiscount__c = m_Id2OrderLine.get(selectedOrderItem).AXADiscount__c;
//                newAlt.BodyShopDiscount__c = m_Id2OrderLine.get(selectedOrderItem).BodyShopDiscount__c;
//                newAlt.PartList__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.PartList__c;
//                newAlt.CataloguePrice__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.CataloguePrice__c;
//                newAlt.VAT__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.VAT__c;
//                
//                m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.put(m_OriginalId2Wrapper.get(selectedOrderItem).nbAlternatives, new AlternativeOrderLineWrapper(m_OriginalId2Wrapper.get(selectedOrderItem).nbAlternatives,newAlt));
//                
//                if(!s_OriginalItemsIdToUpsert.contains(selectedOrderItem))
//                    s_OriginalItemsIdToUpsert.add(selectedOrderItem);        
//            }
//        } catch(Exception ex){
//            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//        }
//    }
//    
//    public PageReference saveAllChanges(){
//        Map<Id,List<OrderLine__c>> m_OriginalID2AlternativesToInsert = new Map<Id,List<OrderLine__c>>();
//        List<OrderLine__c> l_OrderLinesToUpsert = new List<OrderLine__c>();
//        List<OrderLine__c> l_OrderLinesToInsert = new List<OrderLine__c>();
//        List<OrderLine__c> l_OrderLinesFinalToDelete = new List<OrderLine__c>();
//        Integer maxDeliveryDuration = 0;
//        Set<Id> finalGeneratedIds = new Set<Id>();
//        
//        // Delete all existing Alternatives to remove
//        if(l_AltItemsToDelete != null && l_AltItemsToDelete.size() != 0){
//            try{
//                list<OrderLine__c> l_OrderLineToDel = new list<OrderLine__c>();
//                for(OrderLine__c ol : l_AltItemsToDelete){
//                    if(ol.Id != null){
//                        l_OrderLineToDel.add(ol);
//                        //system.debug('////// ol.OriginalItem__c: ' + ol.OriginalItem__c);
//                        finalGeneratedIds.add(ol.OriginalItem__c);
//                    }
//                }
//                if(l_OrderLineToDel.size() > 0){
//                    delete l_OrderLineToDel;
//					l_AltItemsToDelete = new List<OrderLine__c>();
//                }
//
//                for(OrderLine__c ol : [Select Id,TechGeneratedFinal__c,(Select Id from AlternativeItem__r)
//                                        From OrderLine__c where Id in:finalGeneratedIds
//                                        And TechGeneratedFinal__c = true])
//                {
//                    if(ol.AlternativeItem__r.size() == 0){
//                        l_OrderLinesFinalToDelete.add(ol);
//                    }
//                }
//
//                if(l_OrderLinesFinalToDelete.size() > 0){
//                    delete l_OrderLinesFinalToDelete;
//                }
//            }catch(Exception ex){
//                hasSomeChangesNotSaved = true;
//                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the delete.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//                return null;
//            }
//        }
//        
//        // Insert all new Bundles and update all existing final and alternatives
//        for(Id originalId : s_OriginalItemsIdToUpsert){
//            if(m_OriginalId2Wrapper.containsKey(originalId)){
//                // We want to upsert the updated Order Lines and the new Final Order Lines. There are 3 cases.
//                // 1. if the bundleItem is null, we have an original updated. So we change its type to "Final" and add it to the list.
//                if(m_OriginalId2Wrapper.get(originalId).bundleItem == null){
//                    m_OriginalId2Wrapper.get(originalId).originalItem.OrderType__c = 'FINAL';
//                    l_OrderLinesToUpsert.add(m_OriginalId2Wrapper.get(originalId).originalItem);
//                    
//                    // Store the maximum expected delivery duration
//                    if(m_OriginalId2Wrapper.get(originalId).originalItem.ExpectedDeliveryDuration__c != null && Integer.valueOf(m_OriginalId2Wrapper.get(originalId).originalItem.ExpectedDeliveryDuration__c) > maxDeliveryDuration)
//                        maxDeliveryDuration = Integer.valueOf(m_OriginalId2Wrapper.get(originalId).originalItem.ExpectedDeliveryDuration__c);
//
//					// ABT 06-MAY-2016 - C-001617
//					if(m_OriginalId2Wrapper.get(originalId).originalItem.Suppliable__c == 'YES')
//					{
//						if (franceDiscountInfo != null &&
//							(franceDiscountInfo.MinDiscountAS__c != null && m_OriginalId2Wrapper.get(originalId).originalItem.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//							 !(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).originalItem.PartNumber__c))
//						   )
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																	   String.format(Label.ASDiscountErrorMsg, new List<String>
//																											   {
//																													String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																											   }
//																					 )
//																	  )
//												 );
//
//							// stops execution
//							return null;
//						}
//						else if (franceDiscountInfo != null &&
//								 (franceDiscountInfo.MinDiscountBS__c != null && 
//								  franceDiscountInfo.DefaultBSDiscount__c == null && 
//								  m_OriginalId2Wrapper.get(originalId).originalItem.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//								!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).originalItem.PartNumber__c)) )
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																	   String.format(Label.BSDiscountErrorMsg, new List<String>
//																											   {
//																													String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																											   }
//																					 )
//																	  )
//												 );
//
//							// stops execution
//							return null;
//						}
//					}
//                } 
//                // 2. The bundleitem is not null, but has no ID. We have to update this item before insert the alternative items (stored in a map).
//                else if(m_OriginalId2Wrapper.get(originalId).bundleItem.Id == null){  
//                    // Update the field with the last value on the Original
//                    m_OriginalId2Wrapper.get(originalId).originalItem.OrderType__c = 'ORIGINAL';
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.Suppliable__c = m_OriginalId2Wrapper.get(originalId).originalItem.Suppliable__c;
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.PartList__c = m_OriginalId2Wrapper.get(originalId).originalItem.PartList__c;
//                    List<OrderLine__c> l_alts = new List<OrderLine__c>();
//                    String bundleItemsDesc = '';
//                    for(AlternativeOrderLineWrapper olWrap : m_OriginalId2Wrapper.get(originalId).l_AlternativeWrappers){
//                        olWrap.alternative.Suppliable__c = m_OriginalId2Wrapper.get(originalId).originalItem.Suppliable__c;
//                        olWrap.alternative.PartList__c = m_OriginalId2Wrapper.get(originalId).originalItem.PartList__c;
//                        olWrap.alternative.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                        //olWrap.alternative.Quantity__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Quantity__c;
//                        //olWrap.alternative.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//                        //olWrap.alternative.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c;          
//
//                        // Merge the informations of the bundle items in the Bundle field.
//                        bundleItemsDesc += olWrap.alternative.Type__c+';'+olWrap.alternative.PartNumber__c+';'+olWrap.alternative.Description__c+';'+olWrap.alternative.Manufacturer__c+';'+olWrap.alternative.CataloguePrice__c+'|';
//                        l_alts.add(olWrap.alternative);
//
//						// ABT 06-MAY-2016 - C-001617
//						if(olWrap.alternative.Suppliable__c == 'YES')
//						{
//							if (franceDiscountInfo != null &&
//								(franceDiscountInfo.MinDiscountAS__c != null && olWrap.alternative.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//								 !(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(olWrap.alternative.PartNumber__c))
//							   )
//							{
//								// Gives the error message
//								//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//								ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		   String.format(Label.ASDiscountErrorMsg, new List<String>
//																												   {
//																														String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																												   }
//																						 )
//																		  )
//													 );
//
//								// stops execution
//								return null;
//							}
//							else if (franceDiscountInfo != null &&
//									 (franceDiscountInfo.MinDiscountBS__c != null && 
//									  franceDiscountInfo.DefaultBSDiscount__c == null && 
//									  olWrap.alternative.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//									!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(olWrap.alternative.PartNumber__c)) )
//							{
//								// Gives the error message
//								//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//								ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		   String.format(Label.BSDiscountErrorMsg, new List<String>
//																												   {
//																														String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																												   }
//																						 )
//																		  )
//													 );
//
//								// stops execution
//								return null;
//							}
//						}
//                    }
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.BundleItemsDescription__c = bundleItemsDesc;
//
//                    // Add to the Upsert List
//                    l_OrderLinesToUpsert.add(m_OriginalId2Wrapper.get(originalId).originalItem);
//                    l_OrderLinesToUpsert.add(m_OriginalId2Wrapper.get(originalId).bundleItem);
//                    // Add to the map to be inserted later
//                    m_OriginalID2AlternativesToInsert.put(originalId, l_alts);
//                    
//                    // Store the maximum expected delivery duration
//                    if(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c != null && Integer.valueOf(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c) > maxDeliveryDuration)
//                        maxDeliveryDuration = Integer.valueOf(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c);
//
//					// ABT 09-MAY-2016 - C-001617
//					if(m_OriginalId2Wrapper.get(originalId).bundleItem.Suppliable__c == 'YES')
//					{
//						if (franceDiscountInfo != null &&
//							(franceDiscountInfo.MinDiscountAS__c != null && m_OriginalId2Wrapper.get(originalId).bundleItem.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//								!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).bundleItem.PartNumber__c))
//							)
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		String.format(Label.ASDiscountErrorMsg, new List<String>
//																												{
//																													String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																												}
//																						)
//																		)
//													);
//
//							// stops execution
//							return null;
//						}
//						else if (franceDiscountInfo != null &&
//									(franceDiscountInfo.MinDiscountBS__c != null && 
//									franceDiscountInfo.DefaultBSDiscount__c == null && 
//									m_OriginalId2Wrapper.get(originalId).bundleItem.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//								!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).bundleItem.PartNumber__c)) )
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		String.format(Label.BSDiscountErrorMsg, new List<String>
//																												{
//																													String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																												}
//																						)
//																		)
//													);
//
//							// stops execution
//							return null;
//						}
//					}
//                }
//                // 3. The bundleitem ID is not null, so this is an existing bundle item. We can update this item and upsert the alternative list with the field OriginalItem__c set.
//                else{
//                    // Update the field with the last value on the Original
//                    m_OriginalId2Wrapper.get(originalId).originalItem.OrderType__c = 'ORIGINAL';
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.Suppliable__c = m_OriginalId2Wrapper.get(originalId).originalItem.Suppliable__c;
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.PartList__c = m_OriginalId2Wrapper.get(originalId).originalItem.PartList__c;
//                    String bundleItemsDesc = '';
//                    for(AlternativeOrderLineWrapper olWrap : m_OriginalId2Wrapper.get(originalId).l_AlternativeWrappers){
//                        olWrap.alternative.Suppliable__c = m_OriginalId2Wrapper.get(originalId).originalItem.Suppliable__c;
//                        olWrap.alternative.PartList__c = m_OriginalId2Wrapper.get(originalId).originalItem.PartList__c;
//                        olWrap.alternative.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                        //olWrap.alternative.Quantity__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.Quantity__c;
//                        //olWrap.alternative.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//                        //olWrap.alternative.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c;
//                        
//                        // Merge the informations of the bundle items in the Bundle field.
//                        bundleItemsDesc +=olWrap.alternative.Type__c+';'+olWrap.alternative.PartNumber__c+';'+olWrap.alternative.Description__c+';'+olWrap.alternative.Manufacturer__c+';'+olWrap.alternative.CataloguePrice__c+'|';
//                        l_OrderLinesToUpsert.add(olWrap.alternative);
//
//						// ABT 06-MAY-2016 - C-001617
//						if(olWrap.alternative.Suppliable__c == 'YES')
//						{
//							if (franceDiscountInfo != null &&
//								(franceDiscountInfo.MinDiscountAS__c != null && olWrap.alternative.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//								 !(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(olWrap.alternative.PartNumber__c))
//							   )
//							{
//								// Gives the error message
//								//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//								ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		   String.format(Label.ASDiscountErrorMsg, new List<String>
//																												   {
//																														String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																												   }
//																						 )
//																		  )
//													 );
//						
//								// stops execution
//								return null;
//							}
//							else if (franceDiscountInfo != null &&
//									 (franceDiscountInfo.MinDiscountBS__c != null && 
//									  franceDiscountInfo.DefaultBSDiscount__c == null && 
//									  olWrap.alternative.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//									!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(olWrap.alternative.PartNumber__c)) )
//							{
//								// Gives the error message
//								//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//								ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		   String.format(Label.BSDiscountErrorMsg, new List<String>
//																												   {
//																														String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																												   }
//																						 )
//																		  )
//													 );
//						
//								// stops execution
//								return null;
//							}
//						}
//                    }
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.BundleItemsDescription__c = bundleItemsDesc;
//
//                    // Add to the Upsert List
//                    l_OrderLinesToUpsert.add(m_OriginalId2Wrapper.get(originalId).originalItem);
//                    l_OrderLinesToUpsert.add(m_OriginalId2Wrapper.get(originalId).bundleItem);
//                    
//                    // Store the maximum expected delivery duration
//                    if(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c != null && Integer.valueOf(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c) > maxDeliveryDuration)
//                        maxDeliveryDuration = Integer.valueOf(m_OriginalId2Wrapper.get(originalId).bundleItem.ExpectedDeliveryDuration__c);
//
//					// ABT 09-MAY-2016 - C-001617
//					if(m_OriginalId2Wrapper.get(originalId).bundleItem.Suppliable__c == 'YES')
//					{
//						if (franceDiscountInfo != null &&
//							(franceDiscountInfo.MinDiscountAS__c != null && m_OriginalId2Wrapper.get(originalId).bundleItem.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//								!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).bundleItem.PartNumber__c))
//							)
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		String.format(Label.ASDiscountErrorMsg, new List<String>
//																												{
//																													String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//																												}
//																						)
//																		)
//													);
//
//							// stops execution
//							return null;
//						}
//						else if (franceDiscountInfo != null &&
//									(franceDiscountInfo.MinDiscountBS__c != null && 
//									franceDiscountInfo.DefaultBSDiscount__c == null && 
//									m_OriginalId2Wrapper.get(originalId).bundleItem.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//								!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(m_OriginalId2Wrapper.get(originalId).bundleItem.PartNumber__c)) )
//						{
//							// Gives the error message
//							//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//							ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//																		String.format(Label.BSDiscountErrorMsg, new List<String>
//																												{
//																													String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//																												}
//																						)
//																		)
//													);
//
//							// stops execution
//							return null;
//						}
//					}
//                }
//            }
//        }
//
//		// ABT 28-MAR-2016 C-001578
//		// check if all the order lines respect the min and max discount for AS and BS
//		//for (OrderLine__c ol : l_OrderLinesToUpsert)
//		//{
//		//	// ABT 14-APR-2016
//		//	if(ol.Suppliable__c == 'YES')
//		//	{
//		//		if (franceDiscountInfo != null &&
//		//			(franceDiscountInfo.MinDiscountAS__c != null && ol.AXADiscount__c <= franceDiscountInfo.MinDiscountAS__c) &&
//		//			 !(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(ol.PartNumber__c))
//		//		   )
//		//		{
//		//			// Gives the error message
//		//			//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid A/S Discount. A/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountAS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountAS__c) + '%.'));
//		//			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//		//													   String.format(Label.ASDiscountErrorMsg, new List<String>
//		//																							   {
//		//																									String.valueOf(franceDiscountInfo.MinDiscountAS__c)
//		//																							   }
//		//																	 )
//		//													  )
//		//								 );
//		//
//		//			// stops execution
//		//			return null;
//		//		}
//		//		else if (franceDiscountInfo != null &&
//		//				 (franceDiscountInfo.MinDiscountBS__c != null && 
//		//				  franceDiscountInfo.DefaultBSDiscount__c == null && 
//		//				  ol.BodyShopDiscount__c <= franceDiscountInfo.MinDiscountBS__c) &&
//		//				!(franceDiscountInfo.DiscountException__c != null && franceDiscountInfo.DiscountException__c.contains(ol.PartNumber__c)) )
//		//		{
//		//			// Gives the error message
//		//			//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid B/S Discount. B/S Discount should be between ' + String.valueOf(franceDiscountInfo.MinDiscountBS__c) + '% and ' + String.valueOf(franceDiscountInfo.MaxDiscountBS__c) + '%.'));
//		//			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
//		//													   String.format(Label.BSDiscountErrorMsg, new List<String>
//		//																							   {
//		//																									String.valueOf(franceDiscountInfo.MinDiscountBS__c)
//		//																							   }
//		//																	 )
//		//													  )
//		//								 );
//		//
//		//			// stops execution
//		//			return null;
//		//		}
//		//	}
//		//}
//
//        try{
//            if(l_OrderLinesToUpsert.size() != 0 )
//                ASPISWithoutSharingExceptions.upsertListOrderLines(l_OrderLinesToUpsert);
//        }catch(Exception ex){
//            hasSomeChangesNotSaved = true;   
//            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
//                Utils_ManageLogs.createLogFromException('VFC04_POManageOrderLines_V3', 'OrderLine__c', ex); 
//                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the upsert.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            }
//            return null;
//        }
//        
//        // Insert all Alternative Items
//        for(OrderLine__c ol : l_OrderLinesToUpsert){
//            if(ol.OrderType__c == 'FINAL' && ol.OriginalItem__c != null){
//                if(m_OriginalID2AlternativesToInsert.containskey(ol.OriginalItem__c)){
//                    for(OrderLine__c alt: m_OriginalID2AlternativesToInsert.get(ol.OriginalItem__c)){
//                        alt.OriginalItem__c = ol.Id;
//                    }
//                    l_OrderLinesToInsert.addAll(m_OriginalID2AlternativesToInsert.get(ol.OriginalItem__c));
//                }
//            }
//        }
//        
//        try{
//            if(l_OrderLinesToInsert.size() != 0 )
//                ASPISWithoutSharingExceptions.insertListOrderLines(l_OrderLinesToInsert);
//        }catch(Exception ex){
//            hasSomeChangesNotSaved = true;
//            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
//                Utils_ManageLogs.createLogFromException('VFC04_POManageOrderLines_V3', 'OrderLine__c', ex); 
//                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the insert.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            }
//            return null;
//        }
//        
//        // Update the current Purchase Order with the maximum delivery duration.
//        currPurchaseOrder.MaximumDeliveryDuration__c = maxDeliveryDuration;
//        try{
//            update currPurchaseOrder;
//        }catch(Exception ex){
//            hasSomeChangesNotSaved = true;
//            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
//                Utils_ManageLogs.createLogFromException('VFC04_POManageOrderLines_V3', 'PurchaseOrder__c', ex); 
//                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the update of the Purchase Order.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            }
//            return null;
//        }
//
//        map<Id,OrderLine__c> m_Original = new map<Id,OrderLine__c>();
//        for(OrderLine__c ol : [Select Id,Name,Type__c,AXATotalPrice__c,BundleItemsDescription__c,
//                                PartList__c,OrderType__c,TotalPrice__c,OriginalItem__r.OriginalItem__c,
//                                PartNumber__c,ExpectedDeliveryDuration__c ,PartFamily__c,Manufacturer__c,
//                                Description__c,OriginalItem__c,CataloguePrice__c,Quantity__c,AXADiscount__c,
//                                AXAPrice__c,BodyShopDiscount__c,BodyShopPrice__c,Suppliable__c,VAT__c,
//                                AdditionnalDiscount__c,BodyshopTotalPrice__c,AcceptedCheck__c
//                                from OrderLine__c where PurchaseOrder__c =:currPurchaseOrder.Id])
//        {
//            if(ol.OriginalItem__c == null){
//                m_Original.put(ol.Id,ol);
//            }
//        }
//
//        map<Id,list<OrderLine__c>> m_OriginalAndBundleItem = new map<Id,list<OrderLine__c>>();
//        for(OrderLine__c bundles : [Select Id, OrderType__c,OriginalItem__c, OriginalItem__r.OriginalItem__c,
//                                    PurchaseOrder__c,TechGeneratedFinal__c,TotalPrice__c,AdditionnalDiscount__c,VAT__c,
//                                    ExpectedDeliveryDuration__c,AXATotalPrice__c,BodyshopTotalPrice__c,Quantity__c,AcceptedCheck__c
//                                    from OrderLine__c where OriginalItem__r.OriginalItem__c in:m_Original.keySet()])
//        {
//            if(bundles.OriginalItem__r.OriginalItem__c != null){
//                if(m_OriginalAndBundleItem.containsKey(bundles.OriginalItem__r.OriginalItem__c)){
//                    m_OriginalAndBundleItem.get(bundles.OriginalItem__r.OriginalItem__c).add(bundles);
//                }else{
//                    list<OrderLine__c> l_Oline = new list<OrderLine__c>();
//                    l_Oline.add(bundles);
//                    m_OriginalAndBundleItem.put(bundles.OriginalItem__r.OriginalItem__c,l_Oline);
//                }
//            }
//        }
//
//        for(OrderLine__c finalAlt : [Select Id, OrderType__c,OriginalItem__c, OriginalItem__r.OriginalItem__c,
//                                    PurchaseOrder__c,TechGeneratedFinal__c,TotalPrice__c,AXATotalPrice__c,VAT__c,
//                                    BodyshopTotalPrice__c,ExpectedDeliveryDuration__c,AdditionnalDiscount__c,Quantity__c,AcceptedCheck__c
//                                    from OrderLine__c where OriginalItem__c in:m_Original.keySet()])
//        {
//            if(finalAlt.OriginalItem__c != null && finalAlt.TechGeneratedFinal__c == false){
//                if(m_OriginalAndBundleItem.containsKey(finalAlt.OriginalItem__c)){
//                    m_OriginalAndBundleItem.get(finalAlt.OriginalItem__c).add(finalAlt);
//                }else{
//                    list<OrderLine__c> l_Oline = new list<OrderLine__c>();
//                    l_Oline.add(finalAlt);
//                    m_OriginalAndBundleItem.put(finalAlt.OriginalItem__c,l_Oline);
//                }
//            }
//        }
//
//        list<OrderLine__c> l_GeneratedFinalToInsert = new list<OrderLine__c>();
//        for(Id originalId : m_OriginalAndBundleItem.keySet()){
//            list<OrderLine__c> l_OlLines = m_OriginalAndBundleItem.get(originalId);
//            
//            if(l_OlLines.size() > 1){
//
//                Decimal totalPriceFinal = 0;
//                Decimal axaTotalPriceFinal = 0;
//                Decimal bsTotalPriceFinal = 0;
//                Decimal totalQty = 0;
//                Integer firstDelivery = l_OlLines[0].ExpectedDeliveryDuration__c == null ? 1 : integer.valueOf(l_OlLines[0].ExpectedDeliveryDuration__c);
//                String maxDelivery = '1';
//                for(OrderLine__c ol : l_OlLines){
//                    totalPriceFinal += ol.TotalPrice__c == null ? 0 :ol.TotalPrice__c;
//                    axaTotalPriceFinal += ol.AXATotalPrice__c == null ? 0 :ol.AXATotalPrice__c;
//                    bsTotalPriceFinal += ol.BodyshopTotalPrice__c == null ? 0 :ol.BodyshopTotalPrice__c;
//                    totalQty += ol.Quantity__c == null ? 0 : ol.Quantity__c;
//
//                    if(ol.ExpectedDeliveryDuration__c != null){
//                        if(Integer.valueOf(ol.ExpectedDeliveryDuration__c) > firstDelivery){
//                            maxDelivery = ol.ExpectedDeliveryDuration__c;
//                            firstDelivery = Integer.valueOf(ol.ExpectedDeliveryDuration__c);
//                        }
//                    }
//                }
//
//                Decimal bsDiscount = 0;
//
//                if(totalPriceFinal > 0 && bsTotalPriceFinal > 0){
//                    bsDiscount = ((totalPriceFinal - bsTotalPriceFinal)/totalPriceFinal) * 100;
//                }   
//                Decimal axaDiscount = 0;
//                if(totalPriceFinal >0 && axaTotalPriceFinal >0){
//                    axaDiscount = ((totalPriceFinal - axaTotalPriceFinal)/totalPriceFinal) * 100;
//                }
//
//
//                //generate new final
//                OrderLine__c newAlt = new OrderLine__c();
//                newAlt.OriginalItem__c = originalId;
//                newAlt.OrderType__c = 'FINAL';
//                newAlt.PurchaseOrder__c = currPurchaseOrder.Id;
//                newAlt.TechFinalTotalPrice__c = totalPriceFinal;
//                newAlt.TechFinalTotalAxaPrice__c = axaTotalPriceFinal;
//                newAlt.TechFinalBSTotalPrice__c = bsTotalPriceFinal;
//                newAlt.TechGeneratedFinal__c = true;
//                newAlt.PartNumber__c = m_Original.get(originalId).PartNumber__c;
//                newAlt.Description__c = m_Original.get(originalId).Description__c;
//                newAlt.Type__c = m_Original.get(originalId).Type__c;
//                newAlt.PartList__c = m_Original.get(originalId).PartList__c;
//                newAlt.Manufacturer__c = m_Original.get(originalId).Manufacturer__c;
//                newAlt.Suppliable__c = m_Original.get(originalId).Suppliable__c;
//                newAlt.VAT__c =  m_Original.get(originalId).VAT__c;
//                newAlt.AXADiscount__c = axaDiscount;
//                newAlt.BodyShopDiscount__c = bsDiscount;
//                newAlt.ExpectedDeliveryDuration__c = maxDelivery;
//                newAlt.Quantity__c = totalQty;
//                l_GeneratedFinalToInsert.add(newAlt);
//            }
//        }
//
//        if(l_GeneratedFinalToInsert.size() > 0){
//            insert l_GeneratedFinalToInsert;
//
//            map<Id,Id> m_selectedOrderItemFianlId = new map<Id,Id>();
//            for(OrderLine__c ol : [Select Id,OriginalItem__c
//                               from OrderLine__c 
//                               where Id in:l_GeneratedFinalToInsert]){
//                m_selectedOrderItemFianlId.put(ol.OriginalItem__c,ol.Id);
//            }
//
//            list<OrderLine__c> l_BundleItemToUpdate = new list<OrderLine__c>();
//            for(Id originalId : m_OriginalAndBundleItem.keySet()){
//                list<OrderLine__c> l_OlLines = m_OriginalAndBundleItem.get(originalId);
//                if(l_OlLines.size() > 1){
//                    for(OrderLine__c ol : l_OlLines){
//                        ol.OriginalItem__c = m_selectedOrderItemFianlId.get(originalId);
//                        ol.OrderType__c = 'BUNDLEITEM';
//                        l_BundleItemToUpdate.add(ol);
//                    }
//                }
//
//            }
//
//            if(l_BundleItemToUpdate.size() > 0){
//                update l_BundleItemToUpdate;
//            }
//
//
//            map<Id,list<OrderLine__c>> m_OldestFinal = new map<Id,list<OrderLine__c>>();
//            for(OrderLine__c ol : [Select Id,OriginalItem__c,TechGeneratedFinal__c,CreatedDate
//                                    from OrderLine__c 
//                                    where OriginalItem__c in:m_selectedOrderItemFianlId.keySet()
//                                    and TechGeneratedFinal__c = true
//                                    and OrderType__c = 'FINAL'
//                                    Order by CreatedDate asc])
//            {
//                if(m_OldestFinal.containsKey(ol.OriginalItem__c)){
//                    m_OldestFinal.get(ol.OriginalItem__c).add(ol);
//                }else{
//                    list<OrderLine__c> l_OlinesFinal = new list<OrderLine__c>();
//                    l_OlinesFinal.add(ol);
//                    m_OldestFinal.put(ol.OriginalItem__c,l_OlinesFinal);
//                }
//            }
//
//            list<OrderLine__c> l_OrderLineFinalToDel = new list<OrderLine__c>();
//
//            for(Id selectedOrderItem : m_OldestFinal.keySet()){
//                list<OrderLine__c> l_OlLines = m_OldestFinal.get(selectedOrderItem);
//
//                if(l_OlLines.size() > 1){
//                    DateTime firstDate = l_OlLines[0].CreatedDate;
//                    Orderline__c olToDelete = l_OlLines[0];
//                    for(OrderLine__c ol: l_OlLines){
//                        if(ol.CreatedDate < firstDate){
//                            olToDelete = ol;
//                            firstDate = ol.CreatedDate;
//                        }
//                    }
//
//                    l_OrderLineFinalToDel.add(olToDelete);
//                }
//            }
//
//            //delete older orderline line final that was generated
//            if(l_OrderLineFinalToDel.size() > 0){
//                delete l_OrderLineFinalToDel;
//            } 
//
//            list<OrderLine__c> l_OrderLineSup = new list<OrderLine__c>();
//            for(OrderLine__c ol : [Select Id,OriginalItem__c,OriginalItem__r.Suppliable__c,Suppliable__c
//                                        from OrderLine__c 
//                                        where OriginalItem__c in:m_selectedOrderItemFianlId.keySet()])
//            {
//                if(ol.OriginalItem__r.Suppliable__c != null){
//                    ol.Suppliable__c = ol.OriginalItem__r.Suppliable__c;
//                    l_OrderLineSup.add(ol);
//                }
//            }
//
//            if(l_OrderLineSup.size() > 0){
//                update l_OrderLineSup;
//            }
//        
//        }
//
//
//
//        //Pagereference redirect = new Pagereference('/'+currPurchaseOrder.Id);
//        Pagereference redirect = ApexPages.currentPage();
//        redirect.getParameters().put('Id',currPurchaseOrder.Id);
//        redirect.setRedirect(TRUE);
//        return redirect;
//    }
//    
//    public void currentLineNeedUpdate(){
//        hasSomeChangesNotSaved = true;
//        s_OriginalItemsIdToUpsert.add(selectedOrderItem);
//    }
//    
//    public pagereference removeAlternative(){
//        hasSomeChangesNotSaved = true;
//        if(m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.containskey(selectedAltItem)){
//            AlternativeOrderLineWrapper altToRemove = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.remove(selectedAltItem);
//            if(altToRemove.alternative.Id != null)
//                l_AltItemsToDelete.add(altToRemove.alternative);
//        }
//        return null;
//    }
//    
//    public pagereference removeBundle(){
//        hasSomeChangesNotSaved = true;
//
//        if(m_OriginalId2Wrapper.get(selectedOrderItem) != null && m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem != null && m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.size() > 0){
//            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,system.label.ErrorDeletion));
//            return null;
//        }else{
//            if(m_OriginalId2Wrapper.get(selectedOrderItem) != null && m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem != null){  
//                // Remove the bundle 
//                if (m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.id != null){         
//                 l_AltItemsToDelete.add(m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem);
//                }
//                m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem = null;
//                
//                /*// Remove alternatives
//                if(m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers != null){
//                    for(AlternativeOrderLineWrapper wrap : m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()){
//                        l_AltItemsToDelete.add(wrap.alternative);
//                    }
//                    m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers = new Map<Integer, AlternativeOrderLineWrapper>();
//                }*/
//            }
//        }
//        
//        return null;
//    }
//    
//    public pagereference goToEditMode(){    
//        isEditMode = TRUE;
//         isDisabled = 'true'; // new dev
//         styleClassValidateButton = 'styleClassValidateButtonPassive';
//        return null;
//    }
//    
//    public void addBSValue(){   
//        if(TypeOrderLine == 'Alternative' && m_OriginalId2Wrapper.containsKey(selectedOrderItem) && m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values() != null && rowIndex != null && Integer.valueOf(rowIndex) > 0){
//            for(AlternativeOrderLineWrapper altOl : m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()){
//                if(altOl.index == (Integer.valueOf(rowIndex) - 1)){
//                    altOl.alternative.BodyShopDiscount__c = altOl.alternative.AXADiscount__c;
//                }
//            }
//        }
//        else if(TypeOrderLine == 'Bundle' && m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem != null){
//            m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//        }   
//        else if(TypeOrderLine == 'Original' && m_OriginalId2Wrapper.get(selectedOrderItem).originalItem != null){
//            m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.AXADiscount__c;
//        }
//        
//        currentLineNeedUpdate();
//    }
//    
//    public void addSuppliableAndDelivery(){
//        
//        List <OrderLine__c> olToUpdate = new List <OrderLine__c>();
//        if(selectedOrderItem != null && m_OriginalId2Wrapper.containsKey(selectedOrderItem)){
//            if( m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem == null &&  m_OriginalId2Wrapper.get(selectedOrderItem).originalItem != null){
//                for(OrderLine__c ol: m_Id2OrderLine.values()){
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values() != null){
//                        for(AlternativeOrderLineWrapper olAltWrapper : m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values()){
//                            
//                            olAltWrapper.alternative.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                            olAltWrapper.alternative.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.ExpectedDeliveryDuration__c;
//                            olAltWrapper.alternative.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.AXADiscount__c;
//                            olAltWrapper.alternative.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.BodyShopDiscount__c;
//                            //olToUpdate.add(olAltWrapper.alternative);
//                        }
//                    }
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).bundleItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.BodyShopDiscount__c;
//                        //olToUpdate.add(m_OriginalId2Wrapper.get(ol.Id).bundleItem);
//                    }
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).originalItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.BodyShopDiscount__c;
//                    }
//                    olToUpdate.add(ol);
//                    s_OriginalItemsIdToUpsert.add(ol.Id);
//                }
//            }
//            else if(m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem != null){
//                for(OrderLine__c ol: m_Id2OrderLine.values()){
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values() != null){
//                        for(AlternativeOrderLineWrapper olAltWrapper : m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values()){
//                            olAltWrapper.alternative.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                            olAltWrapper.alternative.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                            olAltWrapper.alternative.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//                            olAltWrapper.alternative.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c;
//                            //olToUpdate.add(olAltWrapper.alternative);
//                        }
//                    }
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).bundleItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c;
//                        //olToUpdate.add(m_OriginalId2Wrapper.get(ol.Id).bundleItem);
//                    }
//                    
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).originalItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).bundleItem.BodyShopDiscount__c;
//                    }
//                    olToUpdate.add(ol);
//                    s_OriginalItemsIdToUpsert.add(ol.Id);
//                }
//            }
//            else if(m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values() != null){
//                for(OrderLine__c ol: m_Id2OrderLine.values()){
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers != null && m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values() != null){
//                        for(AlternativeOrderLineWrapper olAltWrapper : m_OriginalId2Wrapper.get(ol.Id).m_index2AlternativeWrappers.values()){
//                            olAltWrapper.alternative.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                            olAltWrapper.alternative.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.ExpectedDeliveryDuration__c;
//                            olAltWrapper.alternative.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.AXADiscount__c;
//                            olAltWrapper.alternative.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.BodyShopDiscount__c;
//                            //olToUpdate.add(olAltWrapper.alternative);
//                        }
//                    }
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).bundleItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).bundleItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.BodyShopDiscount__c;
//                        //olToUpdate.add(m_OriginalId2Wrapper.get(ol.Id).bundleItem);
//                    }
//                    
//                    if(ol.Id != null && m_OriginalId2Wrapper.get(ol.Id) != null && m_OriginalId2Wrapper.get(ol.Id).originalItem != null){
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.ExpectedDeliveryDuration__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.AXADiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.AXADiscount__c;
//                        m_OriginalId2Wrapper.get(ol.Id).originalItem.BodyShopDiscount__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.BodyShopDiscount__c;
//                    }
//                    //ol.Suppliable__c = m_OriginalId2Wrapper.get(selectedOrderItem).originalItem.Suppliable__c;
//                    //ol.ExpectedDeliveryDuration__c = m_OriginalId2Wrapper.get(selectedOrderItem).m_index2AlternativeWrappers.values()[0].alternative.ExpectedDeliveryDuration__c;
//                    olToUpdate.add(ol);
//                    s_OriginalItemsIdToUpsert.add(ol.Id);
//                }
//            }
//        }
//    
//        
//        /*List <OrderLine__c> olToUpdate = new List <OrderLine__c>();
//        if(selectedOrderItem != null){
//            for(OrderLine__c ol: m_Id2OrderLine.values()){
//                ol.Suppliable__c = m_Id2OrderLine.get(selectedOrderItem).Suppliable__c;
//                ol.ExpectedDeliveryDuration__c = m_Id2OrderLine.get(selectedOrderItem).ExpectedDeliveryDuration__c;
//                ol.AXADiscount__c = m_Id2OrderLine.get(selectedOrderItem).AXADiscount__c;
//                ol.BodyShopDiscount__c = m_Id2OrderLine.get(selectedOrderItem).BodyShopDiscount__c;
//                olToUpdate.add(ol);
//            }
//        }
//        if(olToUpdate.size() > 0){
//            update olToUpdate;
//        }*/
//    }
}