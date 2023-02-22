/*
  ----------------------------------------------------------------------
  -- - Name          : AP31PopulateBodyShopDiscount
  -- - Author        : ABT
  -- - Description   : Class to populate the bodyshop discount on OrderLines
  --
  -- Maintenance History:
  --
  -- Date           Name  Version  Remarks
  -- -----------    ----  -------  ---------------------------------------
  -- 14-NOV-2016    ABT    1.0     C-001799
  -- 05-MAY-2017    DUN    1.1     C-001905
  -- 08-NOV-2017    DUN    1.2     C-002055 : Discount for Total Loss Assessment
  -- 15-MAR-2018    VSU    1.3     C-002284 : Total Discount cannot be > 100%
  -- 10-AUG-2018    RLA    1.4     C-002726 : F part Extra AS discount not taken into account in PO
  -- 17-AUG-2018    WCH    1.5     C-002738 : Activate the Part V for Spain
  -- 21-NOV-2018    WCH    1.6     C-002868 : check if PO has distributor and if distributor has BS keep discount 
  -- 14-JUN-2019    WCH    1.7     C-003287 : On Agency Mode BS Discount should not take into consideration the Low and High keep Discount on the Discount table 
    ----------------------------------------------------------------------
 **********************************************************************
*/
public without sharing class AP31PopulateBodyShopDiscount
{
    /*public static void fillOrderLineBodyShopDiscountField(List<OrderLine__c> orderLineList, Set<Id> setPurchaseOrderId)
    {
        system.debug('#### START AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField');
        //Varaible Declaration
        Set<Id> setBodyShopId   = new Set<Id>();
        Set<String> setBrand    = new Set<String>();
        Set<String> setPartType = new Set<String>();
        String brandValue       = '';
        Map<String, Discount__c> mapKeyDiscount = new Map<String, Discount__c>();

        //Selecting a map of purchase order
        Map <Id,PurchaseOrder__c> mapIdPurchaseOrder = new Map <Id,PurchaseOrder__c> ([ SELECT  Id, Brand__c, Distributor__r.ReferentialASforAParts__c,
                                                                                                Distributor__r.ReferentialASforBCParts__c, Assessment__r.BodyShop__c,
                                                                                                TECH_AssessmentCountryCode__c, Assessment__r.TotalLoss__c,
                                                                                                Distributor__r.BSKeepDiscount__c
                                                                                        FROM    PurchaseOrder__c
                                                                                        WHERE   Id IN: setPurchaseOrderId
                                                                                        AND     TECH_AssessmentCountryCode__c != 'DE']);

        //Populating a set of brand and a set of bodyshop id
        for(PurchaseOrder__c currentPurchaseOrder : mapIdPurchaseOrder.values())
        {
            setBrand.add(currentPurchaseOrder.Brand__c);
            setBodyShopId.add(currentPurchaseOrder.Assessment__r.BodyShop__c);
        }

        //Populating sets of part type (A/B;C)
        for(OrderLine__c ol : orderLineList)
        {
            if(ol.Type__c == 'A')
            {
                setPartType.add('A');
            }
            else if(ol.Type__c == 'B' || ol.Type__c == 'C')
            {
                setPartType.add('B;C');
            }
            else if(ol.Type__c == 'F')
            {
                setPartType.add('F');
            }
        }

        //Copying values of brand from discount into brandValue for soql use
        for(String brand : setBrand)
        {
            brandValue += brand + '\',\'';
        }

        brandValue = brandValue.removeEnd('\',\'');

        //Selecting discount and building map mapKeyDiscount having key brand, part type and bodyshop id and values discount
        for(Discount__c currentDiscount : [ SELECT Id, Active__c,PartType__c, BodyShop__c, Brand__c, LowKeepDiscount__c, HighKeepDiscount__c, CreatedDate
                                            FROM Discount__c
                                            WHERE Active__c = true
                                            AND RecordType.DeveloperName =: ASPISConstants.DISCOUNT_RT_DeveloperName_BodyshopDiscount
                                            AND BodyShop__c in: setBodyShopId
                                            AND(
                                                    Brand__c includes (: brandValue )
                                                OR  PartType__c in: setPartType)
                                            ORDER BY CreatedDate DESC])
        {
            if(currentDiscount.Brand__c != null)
            {
                for(String brand : currentDiscount.Brand__c.split(';'))
                {
                    if(!mapKeyDiscount.containsKey(brand.toUpperCase() + currentDiscount.PartType__c + currentDiscount.BodyShop__c))
                    {
                        mapKeyDiscount.put(brand.toUpperCase() + currentDiscount.PartType__c + currentDiscount.BodyShop__c, currentDiscount);
                    }
                }
            }
        }

        //Looping through the list of orderlines to fill in the field bodyshop discount
        for(OrderLine__c ol : orderLineList)
        {
            if(mapIdPurchaseOrder.containsKey(ol.PurchaseOrder__c))
            {
                if(ol.TECH_ExtraAS__c == null)
                {
                    ol.TECH_ExtraAS__c = 0;
                }

                if(ol.AXADiscount__c == null)
                {
                    ol.AXADiscount__c = 0;
                }
                //DUN 08/11/2017 case 2055
                if(mapIdPurchaseOrder.get(ol.PurchaseOrder__c).TECH_AssessmentCountryCode__c == 'ES' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.TotalLoss__c){
                    ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.BSKeepDiscount__c;

                }
                else{
                    // Create a key by concatenate the main fields to identify the Bodyshop Discount
                    // We capitalize it to avoid case sensitive mismatch.
                    String discountKeyA     = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'A' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;
                    String discountKeyBC    = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'B;C' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;

                    if(ol.Type__c == 'A' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c != null && mapKeyDiscount.containsKey(discountKeyA))
                    {
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - mapKeyDiscount.get(discountKeyA).HighKeepDiscount__c;
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - mapKeyDiscount.get(discountKeyA).LowKeepDiscount__c;
                        }
                    }
                    else if((ol.Type__c == 'B' || ol.Type__c == 'C' || ol.Type__c == 'F' ) && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c != null && mapKeyDiscount.containsKey(discountKeyBC))
                    {
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - mapKeyDiscount.get(discountKeyBC).HighKeepDiscount__c;
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - mapKeyDiscount.get(discountKeyBC).LowKeepDiscount__c;
                        }
                    }
                }
                if(ol.BodyShopDiscount__c <= 0 || ol.BodyShopDiscount__c == null)
                {
                    CountryCodeInformationsMapping__c currentCountryMapping = CountryCodeInformationsMapping__c.getValues(mapIdPurchaseOrder.get(ol.PurchaseOrder__c).TECH_AssessmentCountryCode__c);

                    if(currentCountryMapping != null)
                    {
                        ol.BodyShopDiscount__c = currentCountryMapping.DefaultBSDiscount__c;

                    }
                }else if(ol.BodyShopDiscount__c >= 100){
                    system.debug('##ol.BodyShopDiscount__c: '+ol.BodyShopDiscount__c);
                    ol.addError(system.label.BsDiscountTooLarge);//vsu 13/03/18
                }
            }
        }
        system.debug('#### END AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField');
    }*/

    public static Boolean isInvokedFromOfferTrigger = false;
    public static void updateBodyShopDiscount(Set<Id> orderLineIdSet)
    {
        system.debug('#### START AP31PopulateBodyShopDiscount.updateBodyShopDiscount');
        List<OrderLine__c> orderLinesToUpdateList   = new List<OrderLine__c>();
        // Set<Id> purchaseOrderIdSet                   = new Set<Id>();

        Map<Id, List<OrderLine__c>> mapPurchaseOrderOrderLines = new Map<Id, List<OrderLine__c>>();

        for(OrderLine__c currentOrderLine : [SELECT Id, Type__c, AXADiscount__c, PurchaseOrder__c, BodyShopDiscount__c, TECH_ExtraAS__c
                                                    ,PurchaseOrder__r.AgencyMode__c/*WCH 17/06/2019 C-003287*/
                                             FROM   OrderLine__c
                                             WHERE  Id IN: orderLineIdSet
                                             AND    PurchaseOrder__c != null])
        {
            // orderLinesToUpdateList.add(currentOrderLine);
            // purchaseOrderIdSet.add(currentOrderLine.PurchaseOrder__c);

            if(!mapPurchaseOrderOrderLines.containsKey(currentOrderLine.PurchaseOrder__c))
            {
                mapPurchaseOrderOrderLines.put(currentOrderLine.PurchaseOrder__c, new List<OrderLine__c>{currentOrderLine});
            }
            else
            {
                mapPurchaseOrderOrderLines.get(currentOrderLine.PurchaseOrder__c).add(currentOrderLine);
            }
        }

        if(mapPurchaseOrderOrderLines.size() > 0)
        {
            // Calling the existing function to populate the bodyshop discount
            //fillOrderLineBodyShopDiscountField(orderLinesToUpdateList, purchaseOrderIdSet);
            fillOrderLineBodyShopDiscountField(mapPurchaseOrderOrderLines);

            for(List<OrderLine__c> currentOrderLineList : mapPurchaseOrderOrderLines.values())
            {
                orderLinesToUpdateList.addAll(currentOrderLineList);
            }

            // Setting the variable isInvokedFromOfferTrigger to true to prevent the OrderLineTriggerHandler to re-execute the same process
            isInvokedFromOfferTrigger = true;
            update orderLinesToUpdateList;
            isInvokedFromOfferTrigger = false;
        }
        system.debug('#### END AP31PopulateBodyShopDiscount.updateBodyShopDiscount');
    }

    public static void fillOrderLineBodyShopDiscountField(Map<Id, List<OrderLine__c>> mapPurchaseOrderOrderLines)
    {
        system.debug('#### START AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField 2');
        //Varaible Declaration
        Map<String, Discount__c> mapKeyDiscount = new Map<String, Discount__c>();

        String discountQuery =  'SELECT Id, Active__c,PartType__c, BodyShop__c, Brand__c, LowKeepDiscount__c, HighKeepDiscount__c, CreatedDate ' +
                                'FROM   Discount__c ' +
                                'WHERE  Active__c = true ' +
                                'AND    RecordType.DeveloperName = \'' + ASPISConstants.DISCOUNT_RT_DeveloperName_BodyshopDiscount + '\' ' +
                                'AND    ';


        //Selecting a map of purchase order
        Map <Id, PurchaseOrder__c> mapIdPurchaseOrder = new Map <Id, PurchaseOrder__c>([SELECT  Id, Brand__c, Distributor__r.ReferentialASforAParts__c,
                                                                                                Distributor__r.ReferentialASforBCParts__c, Assessment__r.BodyShop__c,
                                                                                                TECH_AssessmentCountryCode__c, Assessment__r.TotalLoss__c,
                                                                                                Distributor__r.BSKeepDiscount__c,AgencyMode__c/*WCH 17/06/2019 C-003287*/
                                                                                        FROM    PurchaseOrder__c
                                                                                        WHERE   Id IN: mapPurchaseOrderOrderLines.keySet()
                                                                                        AND     Brand__c != null
                                                                                        AND     TECH_AssessmentCountryCode__c != 'DE']);

        String queryConditions = '(';
        //Populating a set of brand and a set of bodyshop id
        for(PurchaseOrder__c currentPurchaseOrder : mapIdPurchaseOrder.values())
        {
            queryConditions +=  '(BodyShop__c = \'' + currentPurchaseOrder.Assessment__r.BodyShop__c + '\' ' +
                                'AND Brand__c INCLUDES (\'' + String.escapeSingleQuotes(currentPurchaseOrder.Brand__c) + '\') ' +
                                'AND PartType__c IN (';
            
            // Loop in the order lines of the purchase order to capture the Part Types that the Order Lines are
            Set<String> typeSet = new Set<String>();

            String allTypes = Label.DiscountCategory; 
            List<String> DiscountCategories = allTypes.split(';');
            System.debug('<<<<<<allTypes>>>>>>' + allTypes );
            System.debug('<<<<<<DiscountCategories>>>>>>' + DiscountCategories );

            for(OrderLine__c currentOrderLine : mapPurchaseOrderOrderLines.get(currentPurchaseOrder.Id))
            {
                if(currentOrderLine.Type__c == 'A')
                {
                    typeSet.add('A');
                }
                else if(currentOrderLine.Type__c == 'B' || currentOrderLine.Type__c == 'C')
                {
                    typeSet.add('B;C');
                }
                else if(currentOrderLine.Type__c == 'F')
                {
                    typeSet.add('F');
                }
                else if(currentOrderLine.Type__c == 'V')
                {
                    typeSet.add('V');
                }
            }
            system.debug('@@ typeSet: '+typeSet);

            for(String type : typeSet)
            {
                queryConditions += '\'' + String.escapeSingleQuotes(type) + '\' ,';
            }

            queryConditions = queryConditions.removeEnd(' ,');

            queryConditions += ')) OR ';
        }

        queryConditions = queryConditions.removeEnd(' OR ');
        queryConditions += ')';

        discountQuery += queryConditions;
        System.debug('## discountQuery: ' + discountQuery);

        if(!discountQuery.contains('()'))
        {
            //Selecting discount and building map mapKeyDiscount having key brand, part type and bodyshop id and values discount
            for(Discount__c currentDiscount : Database.query(discountQuery))
            {
                if(currentDiscount.Brand__c != null)
                {
                    for(String brand : currentDiscount.Brand__c.split(';'))
                    {
                        if(!mapKeyDiscount.containsKey(brand.toUpperCase() + currentDiscount.PartType__c + currentDiscount.BodyShop__c))
                        {
                            mapKeyDiscount.put(brand.toUpperCase() + currentDiscount.PartType__c + currentDiscount.BodyShop__c, currentDiscount);
                        }
                    }
                }
            }
        }
        system.debug('## mapKeyDiscount:' +mapKeyDiscount);
        //Looping through the list of orderlines to fill in the field bodyshop discount
        List<OrderLine__c> orderLineList = new List<OrderLine__c>();
        for(List<OrderLine__c> currentOrderLineList : mapPurchaseOrderOrderLines.values())
        {
            orderLineList.addAll(currentOrderLineList);
        }

        for(OrderLine__c ol : orderLineList)
        {
            if(mapIdPurchaseOrder.containsKey(ol.PurchaseOrder__c))
            {
                if(ol.TECH_ExtraAS__c == null)
                {
                    ol.TECH_ExtraAS__c = 0;
                }

                if(ol.AXADiscount__c == null)
                {
                    ol.AXADiscount__c = 0;
                }


                //DUN 08/11/2017 case 2055
                if(mapIdPurchaseOrder.get(ol.PurchaseOrder__c).TECH_AssessmentCountryCode__c == 'ES' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.TotalLoss__c){
                    //WCH 21/11/2018: 002868 : check if PO has distributor and if distributor has BS keep discount 
                    ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c? 0 :(mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__c !=null && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.BSKeepDiscount__c!=null ?mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.BSKeepDiscount__c : 0));/*WCH 17/06/2019 C-003287*/
                }
                else{
                    // Create a key by concatenate the main fields to identify the Bodyshop Discount
                    // We capitalize it to avoid case sensitive mismatch.
                    String discountKeyA     = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'A' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;
                    String discountKeyBC    = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'B;C' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;
                    String discountKeyF    = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'F' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;//RLA 10/08/2018 C-002726 : F part Extra AS discount not taken into account in PO
                    String discountKeyV    = ((mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c != null) ? mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Brand__c.toUpperCase() : null) + 'V' + mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Assessment__r.BodyShop__c;//WCH 17/08/2018 C-002738 : Activate the Part V for Spain

                    system.debug('## discountKeyA: '+discountKeyA);
                    system.debug('## discountKeyBC: '+discountKeyBC);
                    system.debug('## discountKeyF: '+discountKeyF);
                    system.debug('## discountKeyXX : '+mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c); 
                    system.debug('## discountKeyXY : '+mapKeyDiscount.containsKey(discountKeyBC));

                    if(ol.Type__c == 'A' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c != null && mapKeyDiscount.containsKey(discountKeyA))
                    {
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyA).HighKeepDiscount__c);//WCH 17/06/2019 C-003287
                            system.debug('## a part greater> ol.BodyShopDiscount__c'+ ol.BodyShopDiscount__c);
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforAParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyA).LowKeepDiscount__c);//WCH 17/06/2019 C-003287
                            system.debug('## a part less equal> ol.BodyShopDiscount__c'+ ol.BodyShopDiscount__c);
                        }
                    }
                    else if((ol.Type__c == 'B' || ol.Type__c == 'C') && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c != null && mapKeyDiscount.containsKey(discountKeyBC) )
                    {
                        system.debug('## discount here:');
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyBC).HighKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyBC).LowKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                    }
                    //RLA 10/08/2018 C-002726 : F part Extra AS discount not taken into account in PO
                    else if( ol.Type__c == 'F' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c != null && mapKeyDiscount.containsKey(discountKeyF))
                    {
                        system.debug('## discount here F:');
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyF).HighKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {                           
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyF).LowKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                        
                    }
                    //WCH 17/08/2018 C-002738 : Activate the Part V for Spain
                    else if( ol.Type__c == 'V' && mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c != null && mapKeyDiscount.containsKey(discountKeyV))
                    {
                        system.debug('## discount here V:');
                        if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) > mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyV).HighKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                        else if((ol.AXADiscount__c + ol.TECH_ExtraAS__c) <= mapIdPurchaseOrder.get(ol.PurchaseOrder__c).Distributor__r.ReferentialASforBCParts__c)
                        {                           
                            ol.BodyShopDiscount__c = (ol.AXADiscount__c + ol.TECH_ExtraAS__c) - (mapIdPurchaseOrder.get(ol.PurchaseOrder__c).AgencyMode__c ? 0 : mapKeyDiscount.get(discountKeyV).LowKeepDiscount__c);//WCH 17/06/2019 C-003287
                        }
                        
                    }
                }
                if(ol.BodyShopDiscount__c <= 0 || ol.BodyShopDiscount__c == null)
                {
                    CountryCodeInformationsMapping__c currentCountryMapping = CountryCodeInformationsMapping__c.getValues(mapIdPurchaseOrder.get(ol.PurchaseOrder__c).TECH_AssessmentCountryCode__c);

                    if(currentCountryMapping != null)
                    {
                        ol.BodyShopDiscount__c = currentCountryMapping.DefaultBSDiscount__c;
                    }
                }else if(ol.BodyShopDiscount__c >= 100){
                    system.debug('##ol.BodyShopDiscount__c: '+ol.BodyShopDiscount__c);
                    ol.addError(system.label.BsDiscountTooLarge);//vsu 14/03/18
                }
                system.debug('##ol.BodyShopDiscount__c'+ ol.BodyShopDiscount__c);
            }
        }
        system.debug('#### END AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField 2');
    }

    /**
     * Function to fill BodyShop Discount on DE Orderlines (case 1905)
     * @param mapPurchaseOrderOrderLines map of Purchase Order Id and its list of Order Lines
     * @param setDiscountId set of discount Id
     */
    public static void fillOrderLineBodyShopDiscountFieldDE(Map<Id, List<OrderLine__c>> mapPurchaseOrderOrderLines, Set<Id> setDiscountId){

        system.debug('#### START AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountFieldDE');
        Map <Id, PurchaseOrder__c> mapIdPurchaseOrder = new Map <Id, PurchaseOrder__c>([SELECT  TECH_AssessmentCountryCode__c,AgencyMode__c/*WCH 14/06/2019 C-003287*/
                                                                                        FROM    PurchaseOrder__c
                                                                                        WHERE   Id IN: mapPurchaseOrderOrderLines.keySet()
                                                                                        AND     TECH_AssessmentCountryCode__c = 'DE']);

        Map <Id, Discount__c> mapIdDiscount = new Map <Id, Discount__c>([SELECT Id , ASKeep__c
                                                                         FROM Discount__c
                                                                         WHERE Active__c = true
                                                                         AND Id in: setDiscountId]);

        for(Id poId : mapPurchaseOrderOrderLines.keySet()){
            if(mapIdPurchaseOrder.containsKey(poId)){
                for(OrderLine__c ol : mapPurchaseOrderOrderLines.get(poId)){
                    if(mapIdDiscount.containsKey(ol.Discount__c)){
                        /*WCH 14/06/2019 C-003287 if PO in agency, discard the keep discount*/
                        ol.BodyShopDiscount__c =mapIdPurchaseOrder.get(poId).AgencyMode__c ? ol.AXADiscount__c : (mapIdDiscount.get(ol.Discount__c).ASKeep__c != null ? (ol.AXADiscount__c - mapIdDiscount.get(ol.Discount__c).ASKeep__c) : ol.AXADiscount__c);
                    }
                    if(ol.BodyShopDiscount__c <= 0 || ol.BodyShopDiscount__c == null){
                        CountryCodeInformationsMapping__c currentCountryMapping = CountryCodeInformationsMapping__c.getValues(mapIdPurchaseOrder.get(poId).TECH_AssessmentCountryCode__c);

                        if(currentCountryMapping != null){
                            ol.BodyShopDiscount__c = currentCountryMapping.DefaultBSDiscount__c;
                        }
                    }
                    else if(ol.BodyShopDiscount__c >= 100){
                        ol.addError(system.label.BsDiscountTooLarge);//vsu 14/03/18
                    }
                }
            }
        }
        system.debug('#### END AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountFieldDE');
    }
}