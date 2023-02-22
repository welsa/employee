/*
----------------------------------------------------------------------
-- - Name          : AP39AgencyMode
-- - Author        : AMI
-- - Description   : Class to Set DE PO/SO to CLOSEDOK for Agency Mode
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 11-JUL-2017  AMI     1.0         Initial version
-- 11-JAN-2018  DUN     1.1         C-002135 : Agency Mode V2
-- 23-MAY-2018  VSU     1.2         C-002214 : Invoices are not duplicate in some cases in Spain   
-- 12-JUN-2018  DUN     1.3         C-002214 : Invoices Spain 
-- 01-AUG-2019  WCH     1.3         C-003335 : SO status blocked / does not correspond to PO status 
-- 17-MAR-2022  NPE     1.4         C-003897: PO in agency mode does not change to CLOSEDKO after all delivered parts are set to returned
-- 04-MAY-2022  NPE     1.5         C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class AP39AgencyMode{
    
    //set status on SO
    public static void closedSODEAgencyMode(Set<id> setTriggeredSO){
        system.debug('## Start closedSODEAgencyMode');

        List<PrerequisiteOrder__c> lstUpdatedSO = new List<PrerequisiteOrder__c>();

        //DUN 11/01/2018  C-002135 agency Mode V2
        Integer countAgencyOffers = 0;
        Integer countNotDeliveredAgencyOffers = 0;
        Integer countDeliveredAgencyOffers = 0;

        //check for offers to determine status to apply to SO
        for(PrerequisiteOrder__c so : [select id,Status__c,Assessment__r.Status__c,
                                        (select id, Accepted__c, Suppliable__c, DeliveryStatus__c,
                                                AgencyMode__c,name
                                            from Offers__r),
                                        (select AgencyMode__c,Status__c from PurchaseOrders__r where AgencyMode__c = true)
                                        from PrerequisiteOrder__c
                                        where id IN :setTriggeredSO]){
            countAgencyOffers=0;//WCH 01/08/2019 C-003335 reset counter
            //DUN 11/01/2018  C-002135 agency Mode V2
            if(!so.Offers__r.isEmpty()){
                for(Offer__c off : so.Offers__r){
                    if(off.AgencyMode__c ){
                        countAgencyOffers ++;
                        
                        if(off.Accepted__c == 'YES' && off.Suppliable__c && off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED){

                            countDeliveredAgencyOffers ++;
                        }
                        else{
                            countNotDeliveredAgencyOffers ++;
                        }
                    }
                }
            }
            if(so.Offers__r.size() == countAgencyOffers){
                if(countDeliveredAgencyOffers > 0 && so.Status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK){
                    lstUpdatedSO.add(new PrerequisiteOrder__c(id = so.id,
                                                              Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK));
                }else if(countNotDeliveredAgencyOffers == countAgencyOffers && so.Status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO){
                    lstUpdatedSO.add(new PrerequisiteOrder__c(id = so.id,
                                                              Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO));
                }
            }
            //DUN 05/06/2018 case 2214
            //else if(so.Offers__r.size() != countAgencyOffers && countDeliveredAgencyOffers == countAgencyOffers && countAgencyOffers > 0){
            //    lstUpdatedSO.add(new PrerequisiteOrder__c(id = so.id,
            //                                                  Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK));
            //}

            system.debug('## lstUpdatedSO' + lstUpdatedSO.size());
            system.debug('##so.Offers__r.size() '+ so.Offers__r.size());
            system.debug('##countAgencyOffers '+countAgencyOffers);
            system.debug('##countdeliveredAgencyOffers '+ countdeliveredAgencyOffers);
        }//end looping in SO

        
        if(!lstUpdatedSO.isEmpty()){
            update lstUpdatedSO;
        }

        system.debug('## End closedSODEAgencyMode');
    }

    //NPE 17/03/2022 C-003897: PO in agency mode does not change to CLOSEDKO after all delivered parts are set to returned
    public static void closedPOAgencyModeWithAllOLReturned (set<id> setIdPO){
       
        List<PurchaseOrder__c> lstToUpdatePO = new List<PurchaseOrder__c>();
        for(PurchaseOrder__c po : [select id, status__c from PurchaseOrder__c where id In : setIdPO and status__c !='CLOSEDKO']){
            if(po.Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO){
               lstToUpdatePO.add(new PurchaseOrder__c(id = po.id,  Status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO));
            }
        }
        if(!lstToUpdatePO.isEmpty()){
            update lstToUpdatePO;
        }
    }

    //NPE 04/05/2022  C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned
    public static void getOLofPO(id currentPOID){
        Boolean OLNotReturned = false;
        set<id> setPOId = new set<id>();
        for(OrderLine__c currentOLNPE : [SELECT Id, Name, DeliveryStatus__c, PurchaseOrder__c
                            FROM   OrderLine__c
                            WHERE  PurchaseOrder__c =: currentPOID
                            AND    DeliveryStatus__c !=: ASPISConstants.ORD_LINE_STATUS_RETURNED]){
                            System.debug('NPE entered loop OL '+ currentOLNPE.DeliveryStatus__c);
                            OLNotReturned = true;
                            break;
                     
            }
            if (OLNotReturned == false){
                setPOId.add(currentPOID);
                System.debug('NPE calling my PO agency mode method ' + setPOId);
                AP39AgencyMode.closedPOAgencyModeWithAllOLReturned(setPOId);
            }
    }

    //set status on PO
    public static void closedPODEAgencyMode(set<id> setTriggeredPO){
        system.debug('## Start closedPODEAgencyMode');

        List<PurchaseOrder__c> lstUpdatedPO = new List<PurchaseOrder__c>();

        //check for order items to determine status to apply to PO
        for(PurchaseOrder__c po : [select id,Status__c,
                                        (select id
                                            from OrderLines__r
                                            where DeliveryStatus__c = :ASPISConstants.ORD_LINE_STATUS_DELIVERED
                                            and Suppliable__c = 'YES'
                                            and AcceptedCheck__c = true)
                                        from PurchaseOrder__c
                                        where id IN :setTriggeredPO]){
            if(!po.OrderLines__r.isempty() && po.Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK){
                lstUpdatedPO.add(new PurchaseOrder__c(id = po.id,
                                                      Status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK));
            }else if(po.Status__c != ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO){
                lstUpdatedPO.add(new PurchaseOrder__c(id = po.id,
                                                      Status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO));
            }
        }//end looping in PO

        system.debug('## lstUpdatedPO.size() ' + lstUpdatedPO);
        if(!lstUpdatedPO.isEmpty()){
            update lstUpdatedPO;
        }

        system.debug('## End closedPODEAgencyMode');
    }
}