/*
----------------------------------------------------------------------
-- - Name          : VFC03_PurchaseOrderTimeline
-- - Author        : ABT
-- - Description   : Controller VFP03_PurchaseOrderTimelineLightning
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 09-DEC-2016  ABT     1.0    Initial version
-- 25-APR-2017  DUN     1.1    case C-001904: No status after delivery
-- 04-JAN-2018  DUN     1.2    case C-002135: Agency Mode V2 (added agency mode on PO)
-- 30-MAY-2018  RLA     1.3    C-1911: Flag the PO at least readden by the suppliers 
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC03_PurchaseOrderTimeline
{
    public PurchaseOrder__c currentPurchaseOrder {get; set;}
    public Map<Integer, String> mapStepTranslatedStatus {get; set;}
    public Map<String, String> mapStatusTranslatedValue {get; set;}
    public Boolean hasFailed {get; set;}
    public Integer totalNumberOfSteps
    {
        get
        {
            return (hasFailed) ? mapStatusPosition.size() : mapStatusPosition.size() - 1;
        }
    }

    public Integer purchaseOrderCurrentStepNumber {get; set;}

    public Decimal calculateSuccessfulLineWidth
    {
        get
        {
            return (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) * (purchaseOrderCurrentStepNumber - 1);
        }
    }

    public Decimal calculateFailureLineWidth
    {
        get
        {
            return (hasFailed) ? calculateSuccessfulLineWidth + (100.0 / totalNumberOfSteps).setScale(2, System.RoundingMode.DOWN) : 0;
        }
    }

    public Map<String, Integer> mapStatusPosition = new Map<String, Integer>
    {
        ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE          => 1,
        ASPISConstants.PUR_ORDER_STATUS_ISSUED              => 2,
        ASPISConstants.PUR_ORDER_STATUS_ORDERED             => 3,
        ASPISConstants.PUR_ORDER_STATUS_INDELIVERY          => 4,
        ASPISConstants.PUR_ORDER_STATUS_DELIVERED           => 5,
        ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED  => 6,
        ASPISConstants.PUR_ORDER_STATUS_PAYABLE             => 7,
        ASPISConstants.PUR_ORDER_STATUS_PAID                => 8
    };

    public Long startTimerInMillisecond {get; set;}
    public Long endTimerInMillisecond {get; set;}

    public Boolean hasPassedLevel1 {get; set;}
    public Boolean hasPassedLevel2 {get; set;}
    public Boolean hasPassedLevel3 {get; set;}

    public VFC03_PurchaseOrderTimeline(ApexPages.StandardController sc)
    {
        // Getting the current purchase order
        currentPurchaseOrder            = (PurchaseOrder__c) sc.getRecord();
        mapStepTranslatedStatus         = new Map<Integer, String>();
        mapStatusTranslatedValue        = new Map<String, String>();
        purchaseOrderCurrentStepNumber  = 1;
        hasPassedLevel1                 = false;
        hasPassedLevel2                 = false;
        hasPassedLevel3                 = false;

        if(currentPurchaseOrder != null)
        {
            //04/01/2018 DUN case C-002135 (added agency mode on PO)
            if(Schema.sObjectType.PurchaseOrder__c.fields.AgencyMode__c.isAccessible() && currentPurchaseOrder.AgencyMode__c){
                mapStatusPosition.remove(ASPISConstants.PUR_ORDER_STATUS_PAYABLE);
                mapStatusPosition.remove(ASPISConstants.PUR_ORDER_STATUS_PAID);
            }
            
            if( currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED ||
                currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_REJECTED ||
                currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE ||
                currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)
            {
                hasFailed = true;

                if(mapStatusPosition.containsKey(currentPurchaseOrder.PreviousStatus__c))
                {
                    purchaseOrderCurrentStepNumber = mapStatusPosition.get(currentPurchaseOrder.PreviousStatus__c);
                }
            }
            else
            {
                hasFailed = false;

                if(currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK)
                {
                    //04/01/2018 DUN case C-002135 (added agency mode on PO)
                     if(Schema.sObjectType.PurchaseOrder__c.fields.AgencyMode__c.isAccessible() && currentPurchaseOrder.AgencyMode__c)
                    {
                        currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
                    }
                    else
                    {
                        currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_PAID;
                    }
                }

                if(mapStatusPosition.containsKey(currentPurchaseOrder.Status__c))
                {
                    purchaseOrderCurrentStepNumber = mapStatusPosition.get(currentPurchaseOrder.Status__c);
                }
            }

            populateMapStatusTranslatedValues();

            // Business Hour
            User currentUser = [SELECT  Id, CountryCode
                                FROM    User
                                WHERE   Id =: UserInfo.getUserId()];

            String userCountyCode = (currentUser.CountryCode == null) ? 'FR-' : currentUser.CountryCode + '-';

            // List<BusinessHours> businessHoursList = [    SELECT  Id, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime,
            //                                                  MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime, SundayStartTime
            //                                          FROM    BusinessHours
            //                                          WHERE   Name LIKE: userCountyCode];

            // if(businessHoursList.size() == 0)
            // {
            //  businessHoursList = [   SELECT  Id, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime,
            //                                  MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime, SundayStartTime
            //                          FROM    BusinessHours
            //                          WHERE   Name = 'Default'];
            // }

            if( currentPurchaseOrder.SLAQuotationEntryDate__c != null &&
                currentPurchaseOrder.SLAQuotationLevel3__c != null)
            {
                startTimerInMillisecond = currentPurchaseOrder.SLAQuotationEntryDate__c.getTime();
                endTimerInMillisecond   = currentPurchaseOrder.SLAQuotationLevel3__c.getTime();
            }

            if( currentPurchaseOrder.SLAQuotationLevel1__c != null &&
                currentPurchaseOrder.SLAQuotationLevel1__c <= System.now())
            {
                hasPassedLevel1 = true;
            }

            if( currentPurchaseOrder.SLAQuotationLevel2__c != null &&
                currentPurchaseOrder.SLAQuotationLevel2__c <= System.now())
            {
                hasPassedLevel2 = true;
            }

            if( currentPurchaseOrder.SLAQuotationLevel3__c != null &&
                currentPurchaseOrder.SLAQuotationLevel3__c < System.now())
            {
                hasPassedLevel3 = true;  
            }

            // if(businessHoursList.size() > 0)
            // {
            //  Long deltaTotal = BusinessHours.diff(businessHoursList[0].Id, currentPurchaseOrder.SLAQuotationEntryDate__c, currentPurchaseOrder.SLAQuotationLevel3__c);
            //  System.debug('@@ deltaTotal : ' + deltaTotal);
            //  Long deltaNow = BusinessHours.diff(businessHoursList[0].Id, currentPurchaseOrder.SLAQuotationEntryDate__c, System.now());
            //  System.debug('@@ deltaNow : ' + deltaNow);

            //  Long deltaDay = BusinessHours.diff(businessHoursList[0].Id, currentPurchaseOrder.SLAQuotationEntryDate__c, System.now());

            // }
        }
    }

    //30-MAY-2018  RLA  C-1911: Flag the PO at least readden by the suppliers
    public void updateLastViewed(){
        if (currentPurchaseOrder.DistributorContact__c != null &&
            !currentPurchaseOrder.PObeenviewed__c && 
            ((String.valueOf(currentPurchaseOrder.DistributorContact__c)).left(15) == (String.valueOf(UserInfo.getUserId())).left(15))){
                PurchaseOrder__c  po = new PurchaseOrder__c (id = currentPurchaseOrder.Id, PObeenviewed__c = true );
                System.debug('po'+po);
                try{
                    update po;
                }catch (exception e){
                    ApexPages.addMessages(e);
                }
            }

    }

    public void populateMapStatusTranslatedValues()
    {
        // Get the label of each status from the Schema.DescribeFieldResult
        Schema.DescribeFieldResult purchaseOrderStatusSchema = PurchaseOrder__c.Status__c.getDescribe();

        for(Schema.PicklistEntry currentPicklistEntry : purchaseOrderStatusSchema.getPicklistValues())
        {
            mapStatusTranslatedValue.put(currentPicklistEntry.getValue(), currentPicklistEntry.getLabel());

            if(mapStatusPosition.containsKey(currentPicklistEntry.getValue()))
            {
                mapStepTranslatedStatus.put(mapStatusPosition.get(currentPicklistEntry.getValue()),
                                            currentPicklistEntry.getLabel());
            }
        }
    }
}