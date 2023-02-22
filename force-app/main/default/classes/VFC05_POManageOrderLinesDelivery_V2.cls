// TO BE DELETED
/*************************************************************************************
Class Name - VFC05_POManageOrderLinesDelivery_V2
Version - 1.0
Created Date - 
Function - Controller for VFC05_POManageOrderLinesDelivery_V2
Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Dourga            22/01/2016  Updated code for case C-001459
*************************************************************************************/
public with sharing class VFC05_POManageOrderLinesDelivery_V2 { 
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
//    // Indicates if we should always be in the read only mode
//    public Boolean isAlwaysReadOnly {get;set;}
//    // Indicates if the connected user is an Admin
//    public Boolean isAdmin {get;set;}
//
//    //DUN 22/01/2016 case C-001459
//    public Boolean needModification {get;set;}
//    
//    // Identify the line selected for the action
//    public String selectedOrderItem {get;set;}
//    public Integer selectedAltItem {get;set;}
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
//    public Map<Id,OriginalOrderLineWrapper> m_OriginalId2WrapperNotSelected {get;set;} 
//    public Map<Id,OriginalOrderLineWrapper> m_OriginalId2WrapperNotsuppliable {get;set;}
//
//    public List<OriginalOrderLineWrapper> l_OriginalWrappers {
//        get{
//            return m_OriginalId2Wrapper.values();
//        }
//        set;
//    }
//    public List<OriginalOrderLineWrapper> l_OriginalWrappersNotSelected {
//        get{
//            return m_OriginalId2WrapperNotSelected.values();
//        }
//        set;
//    }
//
//    public Map<String,List<OriginalOrderLineWrapper>> m_titleListWrapper {get;set;}
//    
//    // Set of SFDC Id of original items that have been modified. Used to find the wrapper and update all related items.
//    public Set<Id> s_OriginalItemsIdToUpsert { get; set;}
//    
//    // Indicates if some changes need to be saved.
//    public Boolean hasSomeChangesNotSaved{ get; set; }
//
//    //Business days
//    public Utils_BusinessDays businessDays;
//        
//    /*############################################################################
//    #   C.O.N.S.T.R.U.C.T.O.R
//    ##############################################################################*/
//    public VFC05_POManageOrderLinesDelivery_V2(ApexPages.StandardController controller) {
//        // Get the current Purchase Order
//        currPurchaseOrder = (PurchaseOrder__c)controller.getRecord();
//        Utils_BusinessDays.isInvokedFromFlow = true;
//        businessDays = new Utils_BusinessDays(currPurchaseOrder.TECH_AssessmentCountryCode__c);
//        
//        s_OriginalItemsIdToUpsert = new Set<Id>();
//        m_OriginalOrderId2Alternatives = new Map<Id, List<OrderLine__c>>();
//        m_OriginalId2Wrapper = new Map<Id, OriginalOrderLineWrapper>();
//        m_OriginalId2WrapperNotSelected = new Map<Id, OriginalOrderLineWrapper>();
//        m_OriginalId2WrapperNotsuppliable = new Map<Id, OriginalOrderLineWrapper>();
//        isEditMode = FALSE;
//        
//        //DUN 22/01/2016 case C-001459
//        if(currPurchaseOrder.Status__c == 'ORDERED' || currPurchaseOrder.Status__c == 'INDELIVERY' || currPurchaseOrder.Status__c == 'DELIVERED'){
//            needModification = TRUE;
//        }
//        else{
//            needModification = FALSE;
//        }
//
//        // Check if the connected user is an admin
//        isAdmin = System.Label.PROFILEADMINIDS.contains(UserInfo.getProfileId());
//        // If the current Purchase Order has the Status "DELIVEREDCONFIRMED", the page stays in read only mode, except if the connected user is an admin.
//        if(currPurchaseOrder.Status__c == 'DELIVEREDCONFIRMED' && !isAdmin)
//            isAlwaysReadOnly = TRUE;
//        else
//            isAlwaysReadOnly = FALSE;
//        
//        m_Id2OrderLine = new Map<Id,OrderLine__c>([SELECT Id,AdditionnalDiscount__c,AcceptedCheck__c,TechGeneratedFinal__c,PartList__r.CompliantPart__c,Name,Type__c,AXATotalPrice__c,OrderType__c,DeliveryStatus__c,TotalPrice__c,OriginalItem__r.OriginalItem__c,PartNumber__c,ExpectedDeliveryDuration__c ,PartFamily__c,Manufacturer__c,Description__c,OriginalItem__c,CataloguePrice__c,Quantity__c,AXADiscount__c,AXAPrice__c,BodyShopDiscount__c,BodyShopPrice__c,Suppliable__c  FROM OrderLine__c WHERE PurchaseOrder__c = :controller.getId() /*and AcceptedCheck__c = true*/ ORDER BY Name ASC]);
//        
//        for(OrderLine__c ol : m_Id2OrderLine.values()){
//            if(ol.AcceptedCheck__c == true){
//                if(ol.OrderType__c == 'BUNDLEITEM'){
//                    if(m_OriginalId2Wrapper.containsKey(ol.OriginalItem__r.OriginalItem__c)){
//                        m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).m_index2AlternativeWrappers.put(m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives, new AlternativeOrderLineWrapper(m_OriginalId2Wrapper.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives,ol));
//                    } else {
//                        m_OriginalId2Wrapper.put(ol.OriginalItem__r.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__r.OriginalItem__c), m_Id2OrderLine.get(ol.OriginalItem__c), new Map<Integer,AlternativeOrderLineWrapper>{0 => new AlternativeOrderLineWrapper(0,ol)}));
//                    }
//                }else if(ol.OrderType__c == 'FINAL'){
//                    if(ol.OriginalItem__c == null){
//                        if(!m_OriginalId2Wrapper.containsKey(ol.Id)){
//                            m_OriginalId2Wrapper.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                        }
//                    }else{
//                        if(m_OriginalId2Wrapper.containsKey(ol.OriginalItem__c)){
//                            m_OriginalId2Wrapper.get(ol.OriginalItem__c).bundleItem = ol;
//                        } else {
//                            m_OriginalId2Wrapper.put(ol.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__c), ol, new Map<Integer,AlternativeOrderLineWrapper>() ));
//                        }
//                    }
//                }else{
//                    if(!m_OriginalId2Wrapper.containsKey(ol.Id)){
//                        m_OriginalId2Wrapper.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                    }
//                }
//            }
//            else if(ol.AcceptedCheck__c == false && ol.Suppliable__c == 'YES'){
//                if(ol.OrderType__c == 'BUNDLEITEM'){
//                    if(m_OriginalId2WrapperNotSelected.containsKey(ol.OriginalItem__r.OriginalItem__c)){
//                        m_OriginalId2WrapperNotSelected.get(ol.OriginalItem__r.OriginalItem__c).m_index2AlternativeWrappers.put(m_OriginalId2WrapperNotSelected.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives, new AlternativeOrderLineWrapper(m_OriginalId2WrapperNotSelected.get(ol.OriginalItem__r.OriginalItem__c).nbAlternatives,ol));
//                    } else {
//                        m_OriginalId2WrapperNotSelected.put(ol.OriginalItem__r.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__r.OriginalItem__c), m_Id2OrderLine.get(ol.OriginalItem__c), new Map<Integer,AlternativeOrderLineWrapper>{0 => new AlternativeOrderLineWrapper(0,ol)}));
//                    }
//                }else if(ol.OrderType__c == 'FINAL'){
//                    if(ol.OriginalItem__c == null){
//                        if(!m_OriginalId2WrapperNotSelected.containsKey(ol.Id)){
//                            m_OriginalId2WrapperNotSelected.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                        }
//                    }else{
//                        if(m_OriginalId2WrapperNotSelected.containsKey(ol.OriginalItem__c)){
//                            m_OriginalId2WrapperNotSelected.get(ol.OriginalItem__c).bundleItem = ol;
//                        } else {
//                            m_OriginalId2WrapperNotSelected.put(ol.OriginalItem__c, new OriginalOrderLineWrapper(m_Id2OrderLine.get(ol.OriginalItem__c), ol, new Map<Integer,AlternativeOrderLineWrapper>() ));
//                        }
//                    }
//                }else{
//                    if(!m_OriginalId2WrapperNotSelected.containsKey(ol.Id)){
//                        m_OriginalId2WrapperNotSelected.put(ol.Id, new OriginalOrderLineWrapper(ol,null,new Map<Integer,AlternativeOrderLineWrapper>()));
//                    }
//                }
//            }
//        }
//    }
//    
//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    public PageReference saveAllChanges(){
//        List<OrderLine__c> l_OrderLinesToUpdate = new List<OrderLine__c>();
//        list<Offer__c> l_offersToUpdate = new list<Offer__c>();
//        set<Id>olIds = new set<Id>();
//
//        // Insert all new Bundles and update all existing final and alternatives
//        for(Id originalId : s_OriginalItemsIdToUpsert){
//            if(m_OriginalId2Wrapper.containsKey(originalId)){     
//                // Add the Original to the list to update.
//                m_OriginalId2Wrapper.get(originalId).originalItem.EstimatedDeliveryDate__c = businessDays.addBusinessDays(Date.valueOf(currPurchaseOrder.SLADeliveryEntryDate__c), Integer.valueOf(m_OriginalId2Wrapper.get(originalId).originalItem.ExpectedDeliveryDuration__c));
//                l_OrderLinesToUpdate.add(m_OriginalId2Wrapper.get(originalId).originalItem);
//                
//                // If exists, update the field Delivery Status with the same value as Original then add the Bundle to the list to update.
//                if(m_OriginalId2Wrapper.get(originalId).bundleItem != null){
//                    m_OriginalId2Wrapper.get(originalId).bundleItem.DeliveryStatus__c = m_OriginalId2Wrapper.get(originalId).originalItem.DeliveryStatus__c;
//                    l_OrderLinesToUpdate.add(m_OriginalId2Wrapper.get(originalId).bundleItem);
//                }
//
//                // If exists, update the field Delivery Status with the same value as Original then add all the Bundle Items to the list to update.
//                if(m_OriginalId2Wrapper.get(originalId).l_AlternativeWrappers != null && m_OriginalId2Wrapper.get(originalId).l_AlternativeWrappers.size() > 0){
//                    for(AlternativeOrderLineWrapper olWrap : m_OriginalId2Wrapper.get(originalId).l_AlternativeWrappers){
//                        olWrap.alternative.DeliveryStatus__c = m_OriginalId2Wrapper.get(originalId).originalItem.DeliveryStatus__c;
//                        l_OrderLinesToUpdate.add(olWrap.alternative);
//                    }
//                }
//                
//            }
//        }
//        
//        //Check if some line is in Delayed status so a case should be created (unless parent purchaseorder is already associated with a case)
//        Boolean existDelayedLines = false;
//        for(OrderLine__c ol: l_OrderLinesToUpdate){
//                if(ol.DeliveryStatus__c == 'DELAYED'){
//                    olIds.add(ol.Id);
//                    existDelayedLines = true;
//                    break;  
//                }
//        }
//        if(existDelayedLines){
//            PurchaseOrder__c po = new PurchaseOrder__c( id = currPurchaseOrder.id, delayedCaseCreated__c = true);
//            try{
//                update po;
//            }catch(Exception ex){
//            Utils_ManageLogs.createLogFromException('VFC05_POManageOrderLinesDelivery_V2', 'PurchaseOrder__c', ex);
//                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the Purchase Order update.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//                return null;
//            }           
//        }
//        
//            
//        try{
//            //Added by Yudish
//            for(Offer__c off: [Select Id,DeliveryStatus__c FROM Offer__c WHERE OrderLine__c IN:olIds]){
//                off.DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELAYED;
//                l_offersToUpdate.add(off);
//            }
//
//            if(l_offersToUpdate.size()>0){
//                update l_offersToUpdate;
//            }
//
//            if(l_OrderLinesToUpdate.size() > 0)
//                update l_OrderLinesToUpdate;
//        }catch(Exception ex){
//            Utils_ManageLogs.createLogFromException('VFC05_POManageOrderLinesDelivery_V2', 'Offer__c', ex);
//            hasSomeChangesNotSaved = true;    
//            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'An exception occurred during the upsert.<br/> Please contact your administrator.<br/><i>'+ex.getMessage()+' : '+ex.getStackTraceString()+'</i>'));
//            return null;
//        }
//        
//        Pagereference redirect = new PageReference('/apex/ASPISPagePurchaseOrderManageOrderLines?id='+currPurchaseOrder.Id);
//        redirect.setRedirect(TRUE);
//        hasSomeChangesNotSaved = FALSE;
//        isEditMode = FALSE;
//        return null;
//    }
//    
//    public void currentLineNeedUpdate(){
//        hasSomeChangesNotSaved = true;
//        s_OriginalItemsIdToUpsert.add(selectedOrderItem);
//    }
//    
//    public pagereference goToEditMode(){    
//        isEditMode = TRUE;
//        return null;
//    }    
}