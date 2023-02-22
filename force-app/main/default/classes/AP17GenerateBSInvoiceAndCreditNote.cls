public class AP17GenerateBSInvoiceAndCreditNote {
/*************************************************************************************
Class Name - AP17GenerateBSInvoiceAndCreditNote
Version - 1.0
Created Date - unknown
Function - apex class function to be described

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Shamina M             03/02/2016  case 1517 - prevent null pointer when no payment account is found
* Shamina M             16/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S             16/06/2016  C-001647: Add check on SO.techisInvoiced
* Dourga U              04/05/2017  C-001904: No invoice/credit note needs to be generated for assessment in agency mode
* Dourga U              08/01/2018  C-002135: Agency Mode V2 
* Ruksaar L             08/01/2018  C-002214: Child Invoice
* Welsa C               13/02/2019  C-003059: Developer script exception 04022019
* Welsa C               01/04/2019  C-003152: Issue With VFC04_POManageOrderLines
*************************************************************************************/
    public static  integer countNum;
    public static void createInvoiceCreditNote(Map<Id,List<Offer__c>> mapSoOff){
        system.debug('## start createInvoiceCreditNote');

        //AMI 26/06/18 : Community Rollout 
        string aspisSystemUserId = '';
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

        //AMI 26/06/18 : Community Rollout 
        //             : Querying aspis system
        if(string.isNotBlank(system.label.UserAspisSystemName)){
            for(User us : [Select id,Profile.UserLicense.Name 
                            from User 
                            where Name = :system.label.UserAspisSystemName]){
                aspisSystemUserId = us.Id;
            }
        }

        if (countNum == null)
        {
            countNum = 0 ;
        }else{
            countNum++;
        }

        //System.debug('/// countNum: ' + countNum);
        Map<Id,List<Offer__c>> mapSoOffExisting = new Map<Id,List<Offer__c>>();
        Map<Id,List<Invoice__c>> mapSoInvInsert = new Map<Id,List<Invoice__c>>();
        list<Invoice__c> l_invoicesToBeInserted =new list<Invoice__c>();
        //Map<Invoice__c, List<Invoice__c>> mapParentChildInvIns =new Map<Invoice__c, List<Invoice__c>>();
        List<Invoice__c> listchildInvIns =new List<Invoice__c>();
        List<Offer__c> listOffers = new List<Offer__c>();
        list<Offer__c> l_OfferToBeUpdated= new list<Offer__c>();
        list<Orderline__c> l_OrderLinesToBeUpdated= new list<Orderline__c>();
        Set<Id> soIdSet = new Set<Id>();
        Set<Id> orderlineSet = new Set<Id>();
        //RLA 08/03/18 Case 2214 - map keeping the SO and purchase orders with agency mode false
        Map<Id,List<PurchaseOrder__c>> mapSoListPo = new Map<Id,List<PurchaseOrder__c>>();
        //RLA RLA 09/03/18 Case 2214 - map keeping the PO and its related wrapper of details for child invoice
        Map<Id, invoiceWrapper> mapPoInvoiceWrapper = new map<Id, invoiceWrapper>();

        /*map<Id, list<Invoice__c>> SOInvoiceList  = new map<Id, list<Invoice__c>>();  
        Boolean generateInvoice = true;*/
        
        Map<Id,PrerequisiteOrder__c> soMap = new Map<Id,PrerequisiteOrder__c>();
        Set<String> bsCodeSet = new Set<String>();

        //AMI 26/06/18 : Community Rollout 
        //             : Querying tech licence name on bodyshop
        for (PrerequisiteOrder__c so : [Select Id,Assessment__c,BodyShop__c,BodyShop__r.Tech_ContactUserLicenceName__c,
                                                BodyShop__r.ContactUser__c,PaymentTerms__c,TECH_BodyshopCountryCode__c 
                                        from PrerequisiteOrder__c 
                                        where Id In :mapSoOff.keySet()])
        {
            soMap.put(so.Id,so);
            bsCodeSet.add(so.TECH_BodyshopCountryCode__c);
        }
        for (PurchaseOrder__c po : [Select Id,Assessment__c,BodyShopName__c,TECH_AssessmentCountryCode__c,PrerequisiteOrder__c from  
                                        PurchaseOrder__c where PrerequisiteOrder__c In :mapSoOff.keySet()
                                        AND AgencyMode__c = false])
        {
            if (mapSoListPo.containsKey(po.PrerequisiteOrder__c)){
                mapSoListPo.get(po.PrerequisiteOrder__c).add(po);

            }
            else{
                mapSoListPo.put(po.PrerequisiteOrder__c, new list<PurchaseOrder__c>{po});
            }
        }
        /*// select invoices related to SO
        for(Invoice__c invoice: [Select id, RecordType.Name, PrerequisiteOrder__c from Invoice__c where PrerequisiteOrder__c  in :soMap.keySet()]){
            if(!SOInvoiceList.containsKey(invoice.PrerequisiteOrder__c)){
                list<Invoice__c> invLIst = new list<Invoice__c>();
                invList.add(invoice); 
                SOInvoiceList.put(invoice.PrerequisiteOrder__c, invList);
            }
            else{
                SOInvoiceList.get(invoice.PrerequisiteOrder__c).add(invoice);
            }
        }*/

        string rtacc_PaymenttId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            
        Map<String,Account> shipCodeMap = new Map<String,Account>();
        for (Account a : [Select Id,Name,ShippingCountryCode from Account WHERE RecordTypeID=:rtacc_PaymenttId and ShippingCountryCode in :bsCodeSet])
        {
            shipCodeMap.put(a.ShippingCountryCode,a);
        }

        // ABT - 18-JAN-2017 - C-001620 - Remove AdditionnalDiscount__c
        //DUN 04/05/2017  C-001904: added condition if assessment not in agency mode
        //DUN 08/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
        for (Offer__c existingOff : [SELECT Id,PriceWithoutAddDiscount__c,TotalASPrice__c,BSCreditNotePrice__c, PrerequisiteOrder__r.TechIsInvoiced__c,
                                            PartNumber__c, DeliveryStatus__c, OrderType__c, Quantity__c, Accepted__c,Price__c, Orderline__c, 
                                            Orderline__r.PurchaseOrder__c, PrerequisiteOrder__c, AgencyMode__c, PrerequisiteOrder__r.TECH_BodyshopCountryCode__c, Total__c, Discount__c, AdditionalDiscountAmount__c, orderline__r.PreviousAdditionalDiscountAmount__c   
                                     FROM   Offer__c 
                                     WHERE  PrerequisiteOrder__c in :mapSoOff.keySet()
                                     AND    Accepted__c = 'YES'
                                     AND    AgencyMode__c = false]){
            // ASE:16/06/2016: add check: if so.Isvoiced is true, do not generate further invoice/CR
            if(!existingOff.PrerequisiteOrder__r.TechIsInvoiced__c){
                system.debug('## here3');
                if (mapSoOffExisting.containsKey(existingOff.PrerequisiteOrder__c)){
                    mapSoOffExisting.get(existingOff.PrerequisiteOrder__c).add(existingOff);
                }
                else{
                    List<Offer__c> oList = new List<Offer__c>();
                    oList.add(existingOff);
                    mapSoOffExisting.put(existingOff.PrerequisiteOrder__c,oList);
                }
            }
        }
        System.debug('##mapSoOffExisting ' + mapSoOffExisting);

        for (Id soId : mapSoOffExisting.keySet())
        {
            system.debug('##soId: '+soId);
            /*if(SOInvoiceList.containsKey(soId)){
                if(SOInvoiceList.get(SoId).size() ==1){
                    if(SOInvoiceList.get(SoId)[0].RecordType.Name == 'BodyShop Invoice'){
                        generateInvoice = false;
                    }
                }
            }
            if(generateInvoice){*/
            
                Decimal returnedtotalNet = 0;
                Integer returnednumberOfParts = 0;
                Integer returnednumberOfPieces = 0;
                String OffRetIds = null;
                Boolean checkReturnedStatus = false;
                for (Offer__c off : mapSoOffExisting.get(soId)){
                    system.debug('##off id'+ off.id);
                    if (off.DeliveryStatus__c == 'CANCELED' || off.DeliveryStatus__c == 'RETURNED'){
                        system.debug('##orderline 132');
                        checkReturnedStatus = true;
                        returnedtotalNet +=  off.quantity__c * off.PriceWithoutAddDiscount__c;
                        ++returnednumberOfParts;
                        returnednumberOfPieces += off.Quantity__c.intValue();
                        OffRetIds = OffRetIds +'-'+off.Id;
                        listOffers.add(off);
                        //RLA 14/03/18 case-2214 -  keeping a set of orderlines whose TECH_ToBeProcessed__c will be updated
                        orderlineSet.add(off.OrderLine__c);
                        //RLA 08/03/18 Case 2214 - keeping a map of PO and wrapper invoice
                        if (CountryCodeInformationsMapping__c.getInstance(off.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c) != null &&
                            CountryCodeInformationsMapping__c.getInstance(off.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c).NeedInvoiceDetail__c){
                            InvoiceWrapper invWrapper;
                            if (mapPoInvoiceWrapper.containsKey(off.OrderLine__r.PurchaseOrder__c)){
                                system.debug('££ invWrapper: '+mapPoInvoiceWrapper.get(off.Orderline__r.PurchaseOrder__c));
                                invWrapper = mapPoInvoiceWrapper.get(off.Orderline__r.PurchaseOrder__c);
                                invWrapper.TotalGrossAmount += off.Total__c;
                                invWrapper.TotaldiscountAmount += (off.Total__c*off.Discount__c)/100;
                                //invWrapper.TotalNet += MATH.ABS( ((off.AdditionalDiscountAmount__c != null) ?         off.AdditionalDiscountAmount__c : 0) - ((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ?  off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
                                invWrapper.TotalNet += off.quantity__c * off.PriceWithoutAddDiscount__c;
                                invWrapper.ItemsNumber += 1;
                                invWrapper.TotalPieces += off.Quantity__c.intValue();
                                invWrapper.TechOfferIds = invWrapper.TechOfferIds + '-' + off.Id;
                                mapPoInvoiceWrapper.put(off.Orderline__r.PurchaseOrder__c, invWrapper);
                                    
                            }
                            else{       

                                invWrapper = new InvoiceWrapper(off.Total__c,
                                                                (off.Total__c*off.Discount__c)/100,
                                                                off.quantity__c * off.PriceWithoutAddDiscount__c,
                                                                1,
                                                                off.Quantity__c.intValue(),
                                                                off.Id
                                                                );   

                                //invWrapper.TotalGrossAmount = off.Total__c;
                                //invWrapper.TotaldiscountAmount = (off.Total__c*off.Discount__c)/100;
                                //invWrapper.TotalNet = MATH.ABS( ((off.AdditionalDiscountAmount__c != null) ? 
                                //                      off.AdditionalDiscountAmount__c : 0) - 
                                //                      ((off.orderline__r.PreviousAdditionalDiscountAmount__c != null) ?
                                //                      off.orderline__r.PreviousAdditionalDiscountAmount__c : 0));
                                //invWrapper.ItemsNumber = 1;
                                //invWrapper.TotalPieces = off.Quantity__c.intValue();
                                //invWrapper.TechOfferIds = off.Id;
                                mapPoInvoiceWrapper.put(off.Orderline__r.PurchaseOrder__c, invWrapper);

                            }
                        }
                        
                    }else{
                        checkReturnedStatus = false;
                        break;
                    }
                }

                if (checkReturnedStatus){
                    Invoice__c newDraftInvoice = new Invoice__c(
                        Assessment__c = soMap.get(soID).Assessment__c,
                        BodyShop__c = soMap.get(soID).BodyShop__c,
                        Status__c = 'SENT',
                        Prerequisiteorder__c = soID,
                        //Shamina M: case 1517 - check if map contains key before getting id
                        PaymentTo__c = ( shipCodeMap.containsKey(soMap.get(soID).TECH_BodyshopCountryCode__c) ?
                                            shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id : null),
                        //PaymentTo__c = shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id,  
                        RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
                        Type__c = 'INVOICE',
                        IsBodyShop__c = true,
                        Paymentterms__c = soMap.get(soID).PaymentTerms__c,
                        TotalNet__c = returnedtotalNet,
                        ItemsNumber__c = returnednumberOfParts,
                        TotalPieces__c = returnednumberOfPieces,
                        TechOfferIds__c = OffRetIds
                    );

                    //AMI 26/06/18 : Community Rollout 
                    //             : updating owner
                    string contactuserlicence = string.isNotBlank(soMap.get(soID).BodyShop__r.Tech_ContactUserLicenceName__c) ?
                                                soMap.get(soID).BodyShop__r.Tech_ContactUserLicenceName__c : 'fakelicence';

                    if(string.isNotBlank(formattedLicenseName) && 
                       formattedLicenseName.contains(contactuserlicence) &&
                       string.isNotBlank(aspisSystemUserId)){
                         newDraftInvoice.OwnerId = aspisSystemUserId;
                    }else if((string.isBlank(formattedLicenseName) || 
                        (string.isNotBlank(formattedLicenseName) && 
                        !formattedLicenseName.contains(contactuserlicence))) &&
                        soMap.get(soID).BodyShop__r.ContactUser__c != null){
                            newDraftInvoice.OwnerId = soMap.get(soID).BodyShop__r.ContactUser__c;
                    }

                    l_invoicesToBeInserted.add(newDraftInvoice);
                    
                   
                    Invoice__c newCreditNoteInvoice = new Invoice__c(
                        Assessment__c =  soMap.get(soID).Assessment__c,
                        BodyShop__c = soMap.get(soID).BodyShop__c,
                        Status__c = 'SENT',
                        Prerequisiteorder__c = soID,
                        //Shamina M: case 1517 - check if map contains key before getting id
                        PaymentTo__c = ( shipCodeMap.containsKey(soMap.get(soID).TECH_BodyshopCountryCode__c) ?
                                            shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id : null),
                        //PaymentTo__c = shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id, 
                        RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
                        Type__c = 'CREDITNOTE',
                        IsBodyShop__c = true,
                        Paymentterms__c = soMap.get(soID).PaymentTerms__c,
                        TotalNet__c = returnedtotalNet,
                        ItemsNumber__c = returnednumberOfParts,
                        TotalPieces__c =returnednumberOfPieces,
                        TechOfferIds__c = OffRetIds
                    );
                    l_invoicesToBeInserted.add(newCreditNoteInvoice);
                      

                    
                    
                }
            //}
        }

        System.debug('@@@ l_invoicesToBeInserted: ' + l_invoicesToBeInserted);
        //System.debug('@@@ mapParentChildInvIns: ' + mapParentChildInvIns);
        if(l_invoicesToBeInserted.size()>0){
            ASPISWithoutSharingExceptions.insertInvoices(l_invoicesToBeInserted);


            Map<String, List<Invoice__c>> m_Invoice = new Map<String, List<Invoice__c>>();
            Set<Id> soIdsToUpdate = new Set<Id>();

            //AMI 26/06/18 : Community Rollout 
            //             : Querying tech licence name on bodyshop
            for (Invoice__c inv : [Select Id,Assessment__c, BodyShop__c,BodyShop__r.Tech_ContactUserLicenceName__c,
                                            BodyShop__r.ContactUser__c,Status__c, TechOfferIds__c,RecordTypeID,Prerequisiteorder__c, 
                                            PaymentTo__c,Type__c, IsBodyShop__c, Paymentterms__c, TotalNet__c, ItemsNumber__c, 
                                            TotalPieces__c  
                                    from Invoice__c 
                                    where Id in :l_invoicesToBeInserted])
            {
                //RLA 08/03/18 Case 2214 - Create map of PO and list invoices
                // START
                if (mapSoInvInsert.containsKey(inv.Prerequisiteorder__c)){
                    mapSoInvInsert.get(inv.Prerequisiteorder__c).add(inv);
                }
                else{
                    mapSoInvInsert.put(inv.Prerequisiteorder__c, new list<Invoice__c>{inv});
                } 
                //END

                soIdsToUpdate.add(inv.Prerequisiteorder__c);
                //System.debug('//// inv.TechOfferIds__c: '+ inv.TechOfferIds__c);
                if (inv.TechOfferIds__c.contains('-'))
                {
                    for (String idsOff : inv.TechOfferIds__c.split('-'))
                    {
                        if (idsOff != 'null')
                        {
                            if (m_Invoice.containsKey(idsOff))
                            {
                                m_Invoice.get(idsOff).add(inv);
                            }else{
                                List<Invoice__c> invList = new List<Invoice__c>();
                                invList.add(inv);
                                m_Invoice.put(idsOff,invList);
                            }
                            //m_Invoice.put(idsOff, inv);
                        }
                    }
                }else{
                    if (inv.TechOfferIds__c != null && inv.TechOfferIds__c != 'null')
                    {
                        if (m_Invoice.containsKey(inv.TechOfferIds__c))
                        {
                            m_Invoice.get(inv.TechOfferIds__c).add(inv);
                        }else{
                            List<Invoice__c> invList = new List<Invoice__c>();
                            invList.add(inv);
                            m_Invoice.put(inv.TechOfferIds__c,invList);
                        }
                        //m_Invoice.put(inv.TechOfferIds__c, inv);
                    }
                }
            }
            //RLA 08/03/18 Case 2214 - for each PO non agency mode create Child invoices.
            // START

            System.debug('@@@ mapPoInvoiceWrapper: ' + mapPoInvoiceWrapper);

            if (mapPoInvoiceWrapper.size() > 0){
                for (Id soIds : mapSoOffExisting.keySet()){
                    For (PurchaseOrder__c po: mapSoListPo.get(soIds)){
                        if(mapPoInvoiceWrapper.containsKey(po.Id)){
                            for (Invoice__c parentInv : mapSoInvInsert.get(soIds)){
                                Invoice__c newDraftInvoiceChild = createChildInv(parentInv, po.Id, mapPoInvoiceWrapper);

                                //AMI 26/06/18 : Community Rollout 
                                //             : Updating Owner
                                string contactuserlicencev1 = string.isNotBlank(parentInv.BodyShop__r.Tech_ContactUserLicenceName__c) ?
                                                              parentInv.BodyShop__r.Tech_ContactUserLicenceName__c : 'fakelicence';

                                if(string.isNotBlank(formattedLicenseName) && 
                                   formattedLicenseName.contains(contactuserlicencev1) &&
                                   string.isNotBlank(aspisSystemUserId)){
                                     newDraftInvoiceChild.OwnerId = aspisSystemUserId;
                                }else if((string.isBlank(formattedLicenseName) ||
                                    (string.isNotBlank(formattedLicenseName) &&
                                    !formattedLicenseName.contains(contactuserlicencev1))) &&
                                    parentInv.BodyShop__r.ContactUser__c != null){
                                        newDraftInvoiceChild.OwnerId = parentInv.BodyShop__r.ContactUser__c;
                                }

                                listchildInvIns.add(newDraftInvoiceChild);
                            }
                        }
                    }  
                }
                System.debug('@@@ listchildInvIns: ' + listchildInvIns);
                if (listchildInvIns.size() > 0){

                    //WCH 13/02/2019 : C-003059: Developer script exception 04022019 
                    //insert listchildInvIns;                
                    ASPISWithoutSharingExceptions.insertInvoices(listchildInvIns);
                    
                }   
            }
            
            //END
            //System.debug('//// m_Invoice: '+ m_Invoice);

            for(Offer__c off1: listOffers){
                //System.debug('//// off1.Id: '+ off1.Id);
                if (m_Invoice.containsKey(off1.Id))
                {
                    for(Invoice__c inv : m_Invoice.get(off1.Id)){
                        if (inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())
                        {
                            off1.CreditNote__c = inv.Id;
                            off1.TechIsInvoiced__c = true;
                        }

                        if (inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId()){
                            off1.Invoice__c = inv.Id;
                            off1.TechIsInvoiced__c = true;
                        }
                    }
                    l_OfferToBeUpdated.add(off1);
                }
            }

            // loop in OLset to set TECH_ToBeProcessed__c to false
            for(Id OLId: orderlineSet){
                Orderline__c updatedOL = new Orderline__c(id= OLId, TECH_ToBeProcessed__c = false);
                l_OrderLinesToBeUpdated.add(updatedOL);
            }

            //System.debug('//// l_OfferToBeUpdated: '+ l_OfferToBeUpdated);
            if(l_OfferToBeUpdated.size()>0){
                update l_OfferToBeUpdated;
            }
            system.debug('##soIdsToUpdate '+soIdsToUpdate);
            List<PrerequisiteOrder__c> soToUpdate = new List<PrerequisiteOrder__c>();
            if (soIdsToUpdate.size() > 0)
            {
                for (Id soId : soIdsToUpdate)
                {
                    system.debug('##set techisInvoiced');
                    PrerequisiteOrder__c so = new PrerequisiteOrder__c(Id = soId);
                    so.TechIsInvoiced__c = true;
                    soToUpdate.add(so);
                }
            }

            if (soToUpdate.size() > 0)
            {
                update soToUpdate;
            }

            system.debug('######### l_OrderLinesToBeUpdated:'+l_OrderLinesToBeUpdated);            
            if(l_OrderLinesToBeUpdated.size()>0){
                //WCH 01/04/2019 C-003152 - Issue With VFC04_POManageOrderLines. comment dml
                //update l_OrderLinesToBeUpdated;
                ASPISWithoutSharingExceptions.updateOrderLineList(l_OrderLinesToBeUpdated);
            }
        }
        system.debug('## end createInvoiceCreditNote');
        /*for (Id soId : mapSoOffExisting.keySet())
        {
            boolean createInvoice = true;
            for (Offer__c off : mapSoOffExisting.get(soId))
            {
                if (off.DeliveryStatus__c != 'CANCELED' && off.DeliveryStatus__c != 'RETURNED')
                {
                    createInvoice = false;
                }
            }

            if (createInvoice)
            {
                for (Offer__c off : mapSoOff.get(soId))
                {
                    if (off.DeliveryStatus__c != 'CANCELED' && off.DeliveryStatus__c != 'RETURNED')
                    {
                        createInvoice = false;
                    }
                }
            }

            if (createInvoice)
            {
                soIdSet.add(soId);
            }
        }

        if (soIdSet.size() > 0)
        {

            Map<Id,PrerequisiteOrder__c> soMap = new Map<Id,PrerequisiteOrder__c>();
            Set<String> bsCodeSet = new Set<String>();
            for (PrerequisiteOrder__c so : [Select Id,Assessment__c,BodyShop__c,PaymentTerms__c,TECH_BodyshopCountryCode__c from  PrerequisiteOrder__c where Id In :soIdSet])
            {
                soMap.put(so.Id,so);
                bsCodeSet.add(so.TECH_BodyshopCountryCode__c);
            }

            string rtacc_PaymenttId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
            
            Map<String,Account> shipCodeMap = new Map<String,Account>();
            for (Account a : [Select Id,Name,ShippingCountryCode from Account WHERE RecordTypeID=:rtacc_PaymenttId and ShippingCountryCode in :bsCodeSet])
            {
                shipCodeMap.put(a.ShippingCountryCode,a);
            }

            for (Id soID : soIdSet)
            {
                Invoice__c newDraftInvoice = new Invoice__c(
                    Assessment__c = soMap.get(soID).Assessment__c,
                    BodyShop__c = soMap.get(soID).BodyShop__c,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = soID,
                    PaymentTo__c = shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id, 
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId(),
                    Type__c = 'INVOICE',
                    IsBodyShop__c = true,
                    Paymentterms__c = soMap.get(soID).PaymentTerms__c,
                    TotalNet__c = 0,
                    ItemsNumber__c = 0,
                    TotalPieces__c = 0
                );
                l_invoicesToBeInserted.add(newDraftInvoice);

                Invoice__c newCreditNoteInvoice = new Invoice__c(
                    Assessment__c =  soMap.get(soID).Assessment__c,
                    BodyShop__c = soMap.get(soID).BodyShop__c,
                    Status__c = 'SENT',
                    Prerequisiteorder__c = soID,
                    PaymentTo__c = shipCodeMap.get(soMap.get(soID).TECH_BodyshopCountryCode__c).Id, 
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId(),
                    Type__c = 'CREDITNOTE',
                    IsBodyShop__c = true,
                    Paymentterms__c = soMap.get(soID).PaymentTerms__c,
                    TotalNet__c = 0,
                    ItemsNumber__c = mapSoOffExisting.containsKey(soID) ? mapSoOffExisting.get(soID).size(): 0,
                    TotalPieces__c = mapSoOffExisting.containsKey(soID) ? mapSoOffExisting.get(soID).size(): 0
                );
                l_invoicesToBeInserted.add(newCreditNoteInvoice);
            }

            if (l_invoicesToBeInserted.size() > 0)
            {
                ASPISWithoutSharingExceptions.insertInvoices(l_invoicesToBeInserted);
            }
        }*/
    }

    public static Invoice__c createChildInv(Invoice__c invParent, Id poId, map<Id, InvoiceWrapper> mapPoInvWrapper){
        // Cloning the parent Invoice (Invoice/ Credit Note)
        Invoice__c childInvoice = invParent.clone(false, true);
        // Setting the parent of the child invoice and its purchase id
        //childInvoice.ParentInvoice__c     = invId;
        childInvoice.ParentInvoice__c       = invParent.Id ;
        childInvoice.PurchaseOrder__c       = poId;
        // clearing the values
        childInvoice.TotalGrossAmount__c    = mapPoInvWrapper.get(poId).TotalGrossAmount;
        childInvoice.TotaldiscountAmount__c = mapPoInvWrapper.get(poId).TotaldiscountAmount;
        childInvoice.TotalNet__c            = mapPoInvWrapper.get(poId).TotalNet;
        childInvoice.ItemsNumber__c         = mapPoInvWrapper.get(poId).ItemsNumber;
        childInvoice.TotalPieces__c         = mapPoInvWrapper.get(poId).TotalPieces;
        childInvoice.TechOfferIds__c        = mapPoInvWrapper.get(poId).TechOfferIds;
        //childInvoice.TECH_InvoiceParent__c  = String.ValueOf(System.now())+String.ValueOf(math.random());
        childInvoice.TECH_InvoiceParent__c  = null;
        childInvoice.TECH_Number__c = null;//RLA 15/06/2018 case 2617 - Duplicate TechNumber


        return childInvoice;

    }

    public class invoiceWrapper{

        public Decimal TotalGrossAmount ;
        public Decimal TotaldiscountAmount ;
        public Decimal TotalNet ;
        public Decimal ItemsNumber ;
        public Decimal TotalPieces ;
        public String TechOfferIds ;
       

        public invoiceWrapper(Decimal a,  Decimal b, Decimal c, Decimal d, Decimal e,String f ){   
            TotalGrossAmount = a;     
            TotaldiscountAmount = b;
            TotalNet = c;
            ItemsNumber = d;
            TotalPieces = e;
            TechOfferIds  = f;
        }
    }

}