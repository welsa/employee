/*************************************************************************************
Class Name - VFC09_PartListSelection
Version - 1.0
Created Date - 21 MAR 2016
Function - Controller for page VFP09_PartListSelection

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Dourga            21/03/2016  Original Version(case 1567:Painting ordering)
* Cecile L          18/04/2016  Add filter on Bodyshop eligible
* Dourga            25/04/2016  Updates (case C-001613:Evolutions on Painting)
* Dourga            08/07/2016  Updates (case C-001672: Painting Module - Sourcing process creates PO for all distributors)
* Dourga            26/08/2016  C-001675 : Evolutions on Painting 2
* Dourga            11/10/2016  C-001752 : Linking Bodyshop & Paint Distributor
* Dourga            25/11/2016  C-001812 : New painting mapping between User bodyshop and Account Distributor
* Dourga            19/11/2017  C-001766 - Logistic profile : multiple logistic users working with distributors across spain.
* Axel              18/07/2017  Add the filter on painting item only
* Dourga            25/08/2017  C-002006 : New Product Non Painting
* Vaynee            28/11/2017  C-002008 : Businesshours optimisation
* Ruksaar           22/03/2018  C-002279 : Easy way to identify in SAP the annex assessment vs painting assessment
* Welsa             25/01/2019  C-002764 : Add a new information to fill by the BS when ordering painting and non painting products
* Welsa C           02/07/2019  C-003199 - Painting & Annexes in Agency Mode for Selected BS     
* Welsa C           29/01/2020  C-003548 - ACTIVATE OR DEACTIVATE PAINTING-ANNEXES TARIFFS
* Welsa C           06/05/2020  C-003728 - AlphaStore for FR Covid-19          
* Welsa C           28/05/2020  C-003726 - AlphaStore on loading query on DO fetch all DO 
* Welsa C           03/12/2020  C-004085 - Bodyshop and Distributor dropdown menus in Alpha-Store should be displayed in alphabetical order
* Neha P            25/02/2022  C-004596 - PACKAGING CONTENT MULTIPLY UNITS/PRICES + ERASE DEBUG LOGS 

*************************************************************************************/
public without sharing class VFC09_PartListSelection {

    public Map<String, String> bsIdNameMap;
    public Set<String> setBsNameId;//WCH 03/12/2020 C-004085
    public Map<String, String> disIdNameMap;
    public Set<String> setDistNameId;//WCH 03/12/2020 C-004085
    public String userCurrency{get;set;}
    public String manufacturer{get;set;}
    public String family{get;set;}
    public String rtType{get;set;}
    public String directOrderQuery{get;set;}
    public String distributor{get;set;}
    public String bodyshop{get;set;}
    public String POComments{get;set;}//WCH 25/01/2019 C-002764 : Add a new information to fill by the BS when ordering painting and non painting products
    public Boolean isPicklistdisabledBrand{get;set;}
    public Boolean isPicklistdisabledFamily{get;set;}
    public map<String,List<SelectOption>> mapDisIdBSlist{get;set;}
    public map<String,List<SelectOption>> mapBSIdDisList{get;set;}
    public map<String,set<String>> mapManufacturerSetBrand{get;set;}
    public map<String,set<String>> mapManufacturerSetFamily{get;set;}
    public User currentUser{get;set;}
    public static  map<String,Manufacturer_reference__c> mapPartNumberToMR = new  map<String,Manufacturer_reference__c>();//KEM 06/12/2022 C-004824


    public VFC09_PartListSelection() {

        // rName = [Select UserRole.DeveloperName from user where id= :UserInfo.getUserId()].UserRole.DeveloperName;
        currentUser = [SELECT  Id, BodyShopId__c, DistributorId__c, UserRoleId, UserRole.DeveloperName
                            FROM    User
                            WHERE   Id =: UserInfo.getUserId()];

        //bsIdNameMap = new Map<String, String>();
        //disIdNameMap = new Map<String, String>();
        //mapDisIdBSlist = new map<String,List<SelectOption>>();
        //mapBSIdDisList = new map<String,List<SelectOption>>();
        //SObject someObject = new Distributor_reference__c();
        //mapManufacturerSetBrand = new map<String,set<String>>(); 
        //mapManufacturerSetFamily = new map<String,set<String>>(); 
        //// rName = [Select UserRole.DeveloperName from user where id= :UserInfo.getUserId()].UserRole.DeveloperName;
        //User currentUser = [SELECT  Id, BodyShopId__c, DistributorId__c, UserRoleId, UserRole.DeveloperName
        //                    FROM    User
        //                    WHERE   Id =: UserInfo.getUserId()];

        ////select fields to be displayed as selection option on page
        //for(Manufacturer_reference__c manuRef : [select Id, Family__c, Manufacturer__c, Brand__c, Recordtype.DeveloperName,
        //                                                (select Distributor__c, Distributor__r.Name, Distributor__r.ReferenceNumber__c 
        //                                                 from Distributor_references__r)
        //                                        from Manufacturer_reference__c 
        //                                        where Id <> null /*AND Recordtype.DeveloperName = 'Painting'*/]){
        //    if(manuRef.Distributor_references__r.size() > 0){
        //        for(Distributor_reference__c distRef : manuRef.Distributor_references__r){
        //            //building map<Manufacturer,set<Brands>
        //            if(mapManufacturerSetBrand.containsKey(distRef.Distributor__r.ReferenceNumber__c)){
        //                mapManufacturerSetBrand.get(distRef.Distributor__r.ReferenceNumber__c).add(manuRef.Brand__c);
        //            }
        //            else{
        //                mapManufacturerSetBrand.put(distRef.Distributor__r.ReferenceNumber__c,new set<String>{manuRef.Brand__c});
        //            }
        //            //building map<Manufacturer,set<Family>
        //            if(mapManufacturerSetFamily.containsKey(distRef.Distributor__r.ReferenceNumber__c)){
        //                mapManufacturerSetFamily.get(distRef.Distributor__r.ReferenceNumber__c).add(manuRef.Family__c);
        //            }
        //            else{
        //                mapManufacturerSetFamily.put(distRef.Distributor__r.ReferenceNumber__c,new set<String>{manuRef.Family__c});
        //            }
        //        }
        //    }
        //}
        //system.debug('## mapManufacturerSetBrand:'+mapManufacturerSetBrand);
        //system.debug('## mapManufacturerSetFamily:'+mapManufacturerSetFamily);

        ////get currency based on user connected, used for price field
        //String currencyIso = (UserInfo.isMultiCurrencyOrganization() && someObject.get('CurrencyIsoCode') != null ) ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        //if(currencyIso != null){
        //    userCurrency = 
        //       ('USD' == currencyIso ? '$' : ('CAD' == currencyIso ? '$' : ('EUR' == currencyIso ? '€' : ('GBP' == currencyIso ? '£' : ('JPY' == currencyIso ? '¥' : ('KRW' == currencyIso ? '₩' : ('CNY' == currencyIso ? '元' : currencyIso)))))));
        //}

        ////selecting related distributors and related bodyshop from junction object direct orders
        //for(DirectOrder__c dOrder : [select Id, BodyShop__c, BodyShop__r.Name, BodyShop__r.ReferenceNumber__c, BodyShop__r.ContactUser__c ,Distributor__c ,Distributor__r.Name, Distributor__r.ReferenceNumber__c, Distributor__r.ContactUser__c from DirectOrder__c where Id <> null AND BodyShop__r.isEligible__c = TRUE /*AND RecordType.DeveloperName = 'Painting'*/]){
        //    if(mapDisIdBSlist.containsKey(dOrder.Distributor__r.ContactUser__c)){
        //        mapDisIdBSlist.get(dOrder.Distributor__r.ContactUser__c).add(new selectOption(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name));
        //    }
        //    else{
        //        List<SelectOption> optns = new List<Selectoption>();
        //        optns.add(new selectOption('', '-- Select Value--'));
        //        optns.add(new selectOption(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name));
        //        mapDisIdBSlist.put(dOrder.Distributor__r.ContactUser__c,optns);
        //    }
        //    if(mapBSIdDisList.containsKey(dOrder.BodyShop__r.ContactUser__c)){
        //        mapBSIdDisList.get(dOrder.BodyShop__r.ContactUser__c).add(new selectOption(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name));
        //    }
        //    else{
        //        List<SelectOption> optns = new List<Selectoption>();
        //        optns.add(new selectOption('', '-- Select Value--'));
        //        optns.add(new selectOption(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name));
        //        mapBSIdDisList.put(dOrder.BodyShop__r.ContactUser__c,optns);
        //    }
        //    bsIdNameMap.put(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name);
        //    disIdNameMap.put(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name);
        //}
        //system.debug('##mapBSIdDisList'+mapBSIdDisList);
        //system.debug('##mapDisIdBSlist'+mapDisIdBSlist);
        //system.debug('##bsIdNameMap'+bsIdNameMap);
        //system.debug('##disIdNameMap'+disIdNameMap);

        //for(String bsId : mapBSIdDisList.KeySet()){
        //    if(mapBSIdDisList.get(bsId).size() == 2){
        //        mapBSIdDisList.get(bsId).remove(0);                 
        //    }      
        //}

        //for(String disId : mapDisIdBSlist.KeySet()){
        //    if(mapDisIdBSlist.get(disId).size() == 2){
        //        mapDisIdBSlist.get(disId).remove(0);                 
        //    }      
        //}

        //system.debug('### distributor:'+distributor);
        //if(currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('Distributor')){
        //    isPicklistdisabledBrand = false; 
        //    isPicklistdisabledFamily = false;
        //    distributor = currentUser.DistributorId__c;
        //}
        //else{
        //    isPicklistdisabledBrand = true; 
        //    isPicklistdisabledFamily = true;
        //}
        //system.debug('### distributor:'+distributor);
        displayProductType();

    } 

    public void displayProductType(){
        bsIdNameMap = new Map<String, String>();
        setBsNameId = new Set<String>();//WCH 03/12/2020 C-004085
        disIdNameMap = new Map<String, String>();
        setDistNameId = new Set<String>();//WCH 03/12/2020 C-004085
        mapDisIdBSlist = new map<String,List<SelectOption>>();
        mapBSIdDisList = new map<String,List<SelectOption>>();
        SObject someObject = new Distributor_reference__c();
        mapManufacturerSetBrand = new map<String,set<String>>(); 
        mapManufacturerSetFamily = new map<String,set<String>>(); 
        directOrderQuery = '';

        //WCH 25/01/2019 C-002764 : Add a new information to fill by the BS when ordering painting and non painting products
        POComments='';

        //select fields to be displayed as selection option on page
        for(Manufacturer_reference__c manuRef : [select Id, Family__c, Manufacturer__c, Brand__c, Recordtype.DeveloperName,ClaimNumber__c, Recordtype.Name,
                                                        (select Distributor__c, Distributor__r.Name, Distributor__r.ReferenceNumber__c 
                                                         from Distributor_references__r)
                                                from Manufacturer_reference__c 
                                                where Id <> null /*AND Recordtype.DeveloperName = 'Painting'*/
                                                AND Active__c = true /* WCH 29/01/2020 C-003548 */ ]){
            if(manuRef.Distributor_references__r.size() > 0){
                for(Distributor_reference__c distRef : manuRef.Distributor_references__r){
                    //building map<Manufacturer,set<Brands>
                    if(mapManufacturerSetBrand.containsKey(distRef.Distributor__r.ReferenceNumber__c)){
                        mapManufacturerSetBrand.get(distRef.Distributor__r.ReferenceNumber__c).add(manuRef.Brand__c);
                    }
                    else{
                        mapManufacturerSetBrand.put(distRef.Distributor__r.ReferenceNumber__c,new set<String>{manuRef.Brand__c});
                    }
                    //building map<Manufacturer,set<Family>
                    if(mapManufacturerSetFamily.containsKey(distRef.Distributor__r.ReferenceNumber__c)){
                        mapManufacturerSetFamily.get(distRef.Distributor__r.ReferenceNumber__c).add(manuRef.Family__c);
                    }
                    else{
                        mapManufacturerSetFamily.put(distRef.Distributor__r.ReferenceNumber__c,new set<String>{manuRef.Family__c});
                    }
                }
            }
        }
        system.debug('## mapManufacturerSetBrand:'+mapManufacturerSetBrand);
        system.debug('## mapManufacturerSetFamily:'+mapManufacturerSetFamily);

        //get currency based on user connected, used for price field
        String currencyIso = (UserInfo.isMultiCurrencyOrganization() && someObject.get('CurrencyIsoCode') != null ) ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        if(currencyIso != null){
            userCurrency = 
               ('USD' == currencyIso ? '$' : ('CAD' == currencyIso ? '$' : ('EUR' == currencyIso ? '€' : ('GBP' == currencyIso ? '£' : ('JPY' == currencyIso ? '¥' : ('KRW' == currencyIso ? '₩' : ('CNY' == currencyIso ? '元' : currencyIso)))))));
        }

        directOrderQuery = 'select Id, BodyShop__c, BodyShop__r.Name, BodyShop__r.ReferenceNumber__c, BodyShop__r.ContactUser__c ,Distributor__c , ' +
                                  'Distributor__r.Name, Distributor__r.ReferenceNumber__c, Distributor__r.ContactUser__c ' +
                           ' from DirectOrder__c '+
                           ' where Id <> null '+
                           ' and BodyShop__r.isEligible__c = TRUE '; 

        system.debug('## rtType' + rtType);
        if(rtType != null && rtType != ''){
            directOrderQuery += ' and RecordType.DeveloperName = \''+ rtType +'\'';
        }
        else{
            directOrderQuery += ' and RecordType.DeveloperName in (\'Painting\',\'Store Item\') limit 40000 ';//WCH 28/05/2020 C-003726
        }
                           
        system.debug('## directOrderQuery' + directOrderQuery);

        //selecting related distributors and related bodyshop from junction object direct orders
        for(DirectOrder__c dOrder : Database.query(directOrderQuery)){
            if(mapDisIdBSlist.containsKey(dOrder.Distributor__r.ContactUser__c)){
                mapDisIdBSlist.get(dOrder.Distributor__r.ContactUser__c).add(new selectOption(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name));
            }
            else{
                List<SelectOption> optns = new List<Selectoption>();
                optns.add(new selectOption('', System.label.SelectValue));
                optns.add(new selectOption(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name));
                mapDisIdBSlist.put(dOrder.Distributor__r.ContactUser__c,optns);
            }
            if(mapBSIdDisList.containsKey(dOrder.BodyShop__r.ContactUser__c)){
                mapBSIdDisList.get(dOrder.BodyShop__r.ContactUser__c).add(new selectOption(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name));
            }
            else{
                List<SelectOption> optns = new List<Selectoption>();
                optns.add(new selectOption('', System.label.SelectValue));
                optns.add(new selectOption(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name));
                mapBSIdDisList.put(dOrder.BodyShop__r.ContactUser__c,optns);
            }
            bsIdNameMap.put(dOrder.BodyShop__r.ReferenceNumber__c, dOrder.BodyShop__r.Name);
            disIdNameMap.put(dOrder.Distributor__r.ReferenceNumber__c, dOrder.Distributor__r.Name);

            //WCH 03/12/2020 C-004085
            setBsNameId.add(dOrder.BodyShop__r.Name+'_'+dOrder.BodyShop__r.ReferenceNumber__c);
            setDistNameId.add(dOrder.Distributor__r.Name+'_'+dOrder.Distributor__r.ReferenceNumber__c);
        }
        system.debug('##mapBSIdDisList'+mapBSIdDisList);
        system.debug('##mapDisIdBSlist'+mapDisIdBSlist);
        system.debug('##bsIdNameMap'+bsIdNameMap);
        system.debug('##disIdNameMap'+disIdNameMap);

        for(String bsId : mapBSIdDisList.KeySet()){
            if(mapBSIdDisList.get(bsId).size() == 2){
                mapBSIdDisList.get(bsId).remove(0);                 
            }      
        }

        for(String disId : mapDisIdBSlist.KeySet()){
            if(mapDisIdBSlist.get(disId).size() == 2){
                mapDisIdBSlist.get(disId).remove(0);                 
            }      
        }

        system.debug('### distributor:'+distributor);
        if(currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('Distributor')){
            isPicklistdisabledBrand = false; 
            isPicklistdisabledFamily = false;
            distributor = currentUser.DistributorId__c;
        }
        else{
            isPicklistdisabledBrand = true; 
            isPicklistdisabledFamily = true;
        }
        system.debug('### distributor:'+distributor);
    }

    public PageReference brandFamilyResults() {
        system.debug('## START brandFamilyResults');
        isPicklistdisabledBrand = false; 
        isPicklistdisabledFamily = false;
        return null;
    }

    public PageReference typeResults() {
        system.debug('## START brandFamilyResults');
        displayProductType();
        return null;
    }

    public List<SelectOption> getBrandOptions(){
        system.debug('## START getBrandOptions');
        system.debug('## distributor' + distributor);
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', System.label.SelectValue));
        if(mapManufacturerSetBrand.containsKey(distributor)){
            for(String brand : mapManufacturerSetBrand.get(distributor)){   
                optns.add(new selectOption(brand, brand));
            }   
        }   
        if(optns.size() == 2){
            optns.remove(0);                 
        }
        else if(optns.size() == 1 && String.valueOf(optns.get(0)).contains(System.label.SelectValue) && !isPicklistdisabledBrand){
            optns.remove(0);
            optns.add(new selectOption('', System.label.NoValue));
            isPicklistdisabledBrand = true;
        }
        system.debug('## END getBrandOptions');   
        return optns;       
    }

    public List<SelectOption> getRecordTypeOptions(){
        system.debug('## START getRecordTypeOptions');
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', System.label.SelectValue));
        optns.add(new selectOption('Painting', System.label.Painting));
        optns.add(new selectOption('Store_Item', System.label.Refinish));
        system.debug('## END getRecordTypeOptions');   
        return optns;       
    }

    public List<SelectOption> getFamilyOptions(){
        system.debug('## START getFamilyOptions'); 
        system.debug('## distributor' + distributor);  
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', System.label.SelectValue));

        if(mapManufacturerSetFamily.containsKey(distributor)){
            for(String fam : mapManufacturerSetFamily.get(distributor)){   
                optns.add(new selectOption(fam, fam));
            }        
            if(optns.size() == 2){
                optns.remove(0);                 
            }      
        }
        else if(optns.size() == 1 && String.valueOf(optns.get(0)).contains(System.label.SelectValue) && !isPicklistdisabledFamily){
            optns.remove(0);
            optns.add(new selectOption('', System.label.NoValue));
            isPicklistdisabledFamily = true;
        }   
        system.debug('## END getFamilyOptions');      
        return optns;  
        
    } 

    public List<SelectOption> getDistributorOptions(){
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', System.label.SelectValue));

        //WCH 03/12/2020 C-004085
        List<String> orderedDistNameRef = new List<String>();
        orderedDistNameRef.addAll(setDistNameId);
        orderedDistNameRef.sort();
        for(String currentDistNameRef : orderedDistNameRef){
            List<String> currentArray = currentDistNameRef.split('_');
            if(currentArray.size()>0 && String.isNotBlank(currentArray[0]) && String.isNotBlank(currentArray[1])){
                optns.add(new selectOption(currentArray[1], currentArray[0]));
            }
        }

        /* for(String dis : disIdNameMap.keySet()){   
            optns.add(new selectOption(dis, disIdNameMap.get(dis)));
        }    */    
        if(optns.size() == 2){
            optns.remove(0);                 
        }   
        return optns; 
    } 

    public List<SelectOption> getBodyShopOptions(){
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', System.label.SelectValue));

        //WCH 03/12/2020 C-004085
        List<String> orderedBSNameRef = new List<String>();
        orderedBSNameRef.addAll(setBsNameId);
        orderedBSNameRef.sort();
        for(String currentBsNameRef : orderedBSNameRef){
            List<String> currentArray = currentBsNameRef.split('_');
            if(currentArray.size()>0 && String.isNotBlank(currentArray[0]) && String.isNotBlank(currentArray[1])){
                optns.add(new selectOption(currentArray[1], currentArray[0]));
            }
        } 

        /* for(String bs : bsIdNameMap.keySet()){   
            optns.add(new selectOption(bs, bsIdNameMap.get(bs)));
        } */           
        if(optns.size() == 2){
            optns.remove(0);                 
        }   
        return optns;       
    }

    //Selecting fields to be displayed for partList information table on clicking search button
    @RemoteAction
    public static list<Distributor_reference__c> partListDisplay(String manu, String fami, String brand, String rTtype){
        String partListQuery = '';
        //replaced Manufacturer_reference__r.Manufacturer__c by Distributor__c
        partListQuery = 'select Id, AS_public_price__c,BSPrice__c, Discount__c, Distributor_public_price__c,ASDiscount__c,BSDiscount__c, '+ 
                            'Distributor__r.Name, Manufacturer_reference__r.Unit__c, '+
                            'Manufacturer_reference__r.Type__c, Manufacturer_reference__r.Description__c, '+
                            'Manufacturer_reference__r.Family__c, Manufacturer_reference__r.Manufacturer_ID__c, '+
                            'Manufacturer_reference__r.Brand__c, Manufacturer_reference__r.Name, '+
                            'Manufacturer_reference__r.Minimum_quantity__c, toLabel(Manufacturer_reference__r.Recordtype.Name), '+
                            'Manufacturer_reference__r.Recordtype.DeveloperName, '+
                            'Active_country__c, '+//WCH 05/05/2020 C-003728
                            'Manufacturer_reference__r.ClaimNumber__c '+
                        'from Distributor_reference__c '+
                        'where Manufacturer_reference__r.Active__c=true and Distributor__r.ReferenceNumber__c  = \'' + manu + '\' '+ /* WCH 29/01/2020 C-003548 */
                        'and Manufacturer_reference__r.Family__c = \'' + fami + '\' '+
                        'and Manufacturer_reference__r.Brand__c = \'' + brand + '\' ';
        if(rTtype != ''){
            partListQuery += 'and Manufacturer_reference__r.Recordtype.DeveloperName =\''+ rTtype +'\' ';
        }
        return Database.query(partListQuery);     
    }

    //creating assessment and partList on clicking save button
    @RemoteAction
    public static String saveAssPL(Map<Id, Distributor_reference__c> mapIdDiSRef, Map<Id,Integer> mapIdQuantity, String bsName, String orderNum, String disName,String commentsForPO){//WCH 25/01/2019 C-002764 - Add a new information to fill by the BS when ordering painting and non painting products,added parameter commentsForPO
        list<PartList__c> listPartListToInsert = new list<PartList__c>();
        list<PurchaseOrder__c> purchaseOrders = new list<PurchaseOrder__c>();
        list<OrderLine__c> orderLines = new list<OrderLine__c>();
        list<OrderLine__c> orderLinesIoInsert = new list<OrderLine__c>();
        list<PrerequisiteOrder__c> salesOrders = new list<PrerequisiteOrder__c>();
        list<Offer__c> offers = new list<Offer__c>();
        list <Account> listBS = new list <Account>();
        list <MasterRules__c> ruleSet = new list <MasterRules__c>();
        list <PurchaseOrder__c> listPurchaseOrderToUpdate = new list <PurchaseOrder__c>();
        map<String,Account> mapNameAccount = new map<String,Account>();
        String assessmentName = '';
        String PaintingOrAnnexes = '';//WCH 02/07/2019 C-003199

        //Utils_BusinessDays class
        //Utils_BusinessDays businessDays;
        BusinessHours businessDays;

        //set to true as vf page cannot use cache
        //Utils_BusinessDays.isInvokedFromFlow = true;
        ASPISConstants.isInvokedFromFlow = true;

        //DUN 08/07/2016 C-001672
        /*if(bsName == ''){
            listBS = [select Id, OwnerId, Name from Account where Name =: UserInfo.getName()];
        }
        else{
            listBS = [select Id, OwnerId, Name from Account where Name =: bsName];
        }*/

        // if(bsName != '' || disName != ''){
            // ABT - 23-MAR-2017
            // Selecting on User to get the bodyshopid or distributor id
            

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license
        string aspisSystemUserId = '';
        string accountId = '';
        string accountName = '';
        string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
        string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
        boolean isCommunityUser = false;
        User currentUser = null;

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : add check to see if connected user have a community license
        for(User us : [Select id,Profile.UserLicense.Name,BodyShopId__c, DistributorId__c, UserRoleId, UserRole.DeveloperName,Contact.AccountId,Contact.Account.Name
                        from User 
                        where Id=: UserInfo.getUserId() 
                        Or Name = :system.label.UserAspisSystemName]){
            if((string.valueOf(us.id)).contains(UserInfo.getUserId())){
                if(string.isBlank(formattedLicenseName)){
                    isCommunityUser = false;
                }else{
                    isCommunityUser = formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase()) ? true : false;
                }

                if(isCommunityUser){
                    accountId = us.Contact.AccountId;
                    accountName = us.Contact.Account.Name;
                }
                currentUser = us;
            }else{
                aspisSystemUserId = us.Id;
            }
        }

        if(!isCommunityUser && currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('BodyShop'))
        {
            bsName = currentUser.BodyShopId__c;
        }
        else if(currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('Distributor'))
        {
            disName = currentUser.DistributorId__c;
        }

        for(Account acc : [ SELECT  Id, Name, ReferenceNumber__c 
                            FROM    Account 
                            WHERE   ReferenceNumber__c =: bsName 
                            OR      ReferenceNumber__c =: disName]){
            if(acc.ReferenceNumber__c!= null && !mapNameAccount.containsKey(acc.ReferenceNumber__c)){
                mapNameAccount.put(acc.ReferenceNumber__c, acc);
            }
        }
        // }

        //WCH 05/05/2020 C-003728
        String countryRetrieved='';

        // DUN 08.09.2017 Different Assessment Name depending on product type
        if(mapIdDiSRef.size() > 0){
            assessmentName = (mapIdDiSRef.values()[0].Manufacturer_reference__r.Recordtype.DeveloperName == 'Painting' ? System.label.Painting.toUpperCase() : System.label.Refinish.toUpperCase());
            //WCH 02/07/2019 C-003199
            PaintingOrAnnexes = (mapIdDiSRef.values()[0].Manufacturer_reference__r.Recordtype.DeveloperName == 'Painting' ? ASPISConstants.DIRECTORDER_RT_DeveloperName_Painting : ASPISConstants.DIRECTORDER_RT_DeveloperName_Annexes);
            //WCH 05/05/2020 C-003728
            countryRetrieved=mapIdDiSRef.values()[0].Active_country__c;
        }
        

        Assessment__c currAssToInsert = new Assessment__c();
        
        //WCH 05/05/2020 C-003728
        if(String.isNotBlank(countryRetrieved) && CountryCodeInformationsMapping__c.getall().containsKey(countryRetrieved)){
            currAssToInsert.EntityCode__c = CountryCodeInformationsMapping__c.getall().get(countryRetrieved).AlphaStoreEntityCode__c;
            currAssToInsert.Entity__c = CountryCodeInformationsMapping__c.getall().get(countryRetrieved).AlphaStoreEntityCode__c;
            currAssToInsert.TECH_EntityCountryCode__c = countryRetrieved;
        }else{
            currAssToInsert.EntityCode__c = '05';
            currAssToInsert.Entity__c = '05';
            currAssToInsert.TECH_EntityCountryCode__c = 'ES';
        }
        currAssToInsert.OrderNumber__c = orderNum;
        //mapIdDiSRef.values()[0].Manufacturer_reference__r.ClaimNumber s
        //currAssToInsert.ClaimReference__c = System.label.PartClaimNumber;
        //RLA 22/03/18 Case-2279 Easy way to identify in SAP the annex assessment vs painting assessment
        currAssToInsert.ClaimReference__c = mapIdDiSRef.values()[0].Manufacturer_reference__r.ClaimNumber__c;
        currAssToInsert.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();     
        

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Adding correct bodyshop if connected user have a community license
        if(string.isNotBlank(accountId)){
            currAssToInsert.BodyShop__c = accountId;
        }else if(mapNameAccount.containsKey(bsName)){
            currAssToInsert.BodyShop__c = mapNameAccount.get(bsName).Id;
        }

        // else if(mapNameAccount.containsKey(UserInfo.getName())){
        //     currAssToInsert.BodyShop__c = mapNameAccount.get(UserInfo.getName()).Id;
        // }
        currAssToInsert.Status__c = 'NEW';
        currAssToInsert.PartP__c = mapIdQuantity.size();

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license
        if(isCommunityUser && string.isNotBlank(aspisSystemUserId)){
            currAssToInsert.OwnerId = aspisSystemUserId;
        }

        currAssToInsert.isFromAlphastore__c = true;

        insert currAssToInsert;

        //WCH 02/07/2019 C-003199 add field BodyShop__c
        //Querying the inserted assessment to retrieve TechAutoNumber__c to concatenate it with BodyShop Name for fields Name and AssessmentNumber__c
        Assessment__c currAssInserted = [select Id,TechAutoNumber__c,TECH_EntityCountryCode__c,EntityRules__c,BodyShop__c from Assessment__c where Id =: currAssToInsert.Id];
        //system.debug('##currAssInserted'+currAssInserted);

        //Querying MasterRule to check if need of automatic process
        ruleSet = [SELECT Id, Entity__c, Process__c, RuleStatus__c, AutomaticProcess__c
                  FROM MasterRules__c
                  WHERE Process__c    =: 'PAINTING'
                  AND Entity__c       =: currAssInserted.EntityRules__c
                  AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL ];
        //system.debug('##ruleSet'+ruleSet);


        Assessment__c currAssToUpdate = new Assessment__c();
        currAssToUpdate.Id = currAssInserted.Id;

        /*********************************/
        //AMI 26/06/18 : Community Rollout 
        //             : Adding correct bodyshop if connected user have a community license
        if(string.isNotBlank(accountName)){
            currAssToUpdate.Name = assessmentName + '-' + accountName + currAssInserted.TechAutoNumber__c;
            currAssToUpdate.AssessmentNumber__c = assessmentName + '-' + accountName + currAssInserted.TechAutoNumber__c;
        }else if(mapNameAccount.containsKey(bsName)){
            currAssToUpdate.Name = assessmentName + '-' + mapNameAccount.get(bsName).Name + currAssInserted.TechAutoNumber__c;
            currAssToUpdate.AssessmentNumber__c = assessmentName + '-' + mapNameAccount.get(bsName).Name + currAssInserted.TechAutoNumber__c;
        }
        else{
            currAssToUpdate.Name = assessmentName + '-' + currAssInserted.TechAutoNumber__c;
            currAssToUpdate.AssessmentNumber__c = assessmentName + '-' + currAssInserted.TechAutoNumber__c;
        }

        CountryCodeInformationsMapping__c configCountryCodeInfo;
        //businessDays = new Utils_BusinessDays(currAssInserted.TECH_EntityCountryCode__c);
        businessDays = ASPISConstants.getBusinessHours(currAssInserted.TECH_EntityCountryCode__c);

        if(CountryCodeInformationsMapping__c.getall().containsKey(currAssInserted.TECH_EntityCountryCode__c))
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(currAssInserted.TECH_EntityCountryCode__c);
        else
            configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get('DEFAULT');

        Double ActualPrice = 0;
        if(mapIdDiSRef.size() > 0){
            for(Distributor_reference__c disRef : mapIdDiSRef.values()){
                //creating new partlist for the new asessment
                PartList__c newPL = new PartList__c(Assessment__c = currAssInserted.Id, 
                                                    TECH_OriginalPart__c = disRef.Manufacturer_reference__r.Manufacturer_ID__c+'-'+disRef.Distributor__r.Name+'-'+currAssInserted.Id,
                                                    Name = disRef.Manufacturer_reference__r.Description__c.left(80),
                                                    Description__c = disRef.Manufacturer_reference__r.Description__c,
                                                    Family__c = disRef.Manufacturer_reference__r.Family__c,
                                                    ProducerName__c = disRef.Distributor__r.Name,
                                                    PartNumber__c = disRef.Manufacturer_reference__r.Manufacturer_ID__c,
                                                    Price__c = disRef.Distributor_public_price__c,
                                                    Type__c = (disRef.Manufacturer_reference__r.Recordtype.DeveloperName == 'Painting' ? 'P' : 'X'),
                                                    IsSourced__c = TRUE,
                                                    RecordTypeID = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId());

                if(mapIdQuantity.containsKey(disRef.Id)){
                    //NPE 25/02/2022 C-004596 PACKAGING CONTENT MULTIPLY UNITS/PRICES
                    newPL.Quantity__c = Integer.valueOf(mapIdQuantity.get(disRef.Id));//*disRef.Manufacturer_reference__r.Minimum_quantity__c;
                    system.debug('## shane5 ' + newPL.Quantity__c);
                }

                //KEM 06/12/2022 C-004824
                mapPartNumberToMR.put(disRef.Manufacturer_reference__r.Manufacturer_ID__c,disRef.Manufacturer_reference__r);

                system.debug('##TECH_OriginalPart__c'+newPL.TECH_OriginalPart__c);
                listPartListToInsert.add(newPL);

                //KEM 20/08/2022 C-004766: FLOOR PRICE LIMIT IN PAINTING - SINNEK DISTRIBUTORS
                ActualPrice = ActualPrice + (disRef.BSPrice__c * newPL.Quantity__c);
                system.debug('## shane4' + (disRef.BSPrice__c * newPL.Quantity__c));
            }
            //KEM 20/08/2022 C-004766: FLOOR PRICE LIMIT IN PAINTING - SINNEK DISTRIBUTORS
            Double floorLimit = 0;
            System.debug('### Shane3' + ActualPrice); 
            Id distributorID = mapNameAccount.get(disName).id;
            System.debug('### Shane' + distributorID);  
            List<Account> lstDisAccount = [SELECT Id, hasFloorLimit__c, floorLimit__c
                                            FROM Account
                                            WHERE Id =: distributorID];
            Account DisAccount = lstDisAccount[0];
            System.debug('### Shane1'+ DisAccount);
            if (DisAccount.hasFloorLimit__c && CountryCodeInformationsMapping__c.getall().get(currAssInserted.TECH_EntityCountryCode__c).ApplyFloorLimit__c ){
                floorLimit = DisAccount.floorLimit__c;
            }
            System.debug('### Shane2'+ floorLimit); 
            
            if (floorLimit > ActualPrice) {
                return String.valueOf(floorLimit);
            }

            if(listPartListToInsert.size() > 0){
                insert listPartListToInsert;
            }
            //if automatic process true,create PO and OL and then launch offering 
            if(ruleSet.size() > 0 && ruleSet[0].AutomaticProcess__c){
                system.debug('##Businesshours id: '+businessDays.id);
                system.debug('##configCountryCodeInfo: '+configCountryCodeInfo);

                //creating new Purchase order for this distributor
                PurchaseOrder__c newpo = new PurchaseOrder__c(
                    assessment__c   = currAssToUpdate.Id,
                    //validityDate__c = businessDays.addBusinessDays(date.today(), integer.valueof(system.Label.ValidityDays)),
                    validityDate__c = Date.valueOf(BusinessHours.add(businessDays.id,date.today(),configCountryCodeInfo.Validity_Duration_Purchase_Order__c!=null?integer.valueof(configCountryCodeInfo.Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),
                    status__c = system.Label.PURCHASEORDERDRAFTQUOTESTATUS,
                    Distributor__c = mapNameAccount.get(disName).id,
                    recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(system.Label.PurchaseOrderDraftQuoteRTLabel).getRecordTypeId(),
                    SLAQuotationEntryDate__c = datetime.now(),
                    Tech_ExternalId__c = String.valueOf(currAssToUpdate.Id) + String.valueOf(mapNameAccount.get(disName).Id)

                    //WCH 25/01/2019 C-002764 - Add a new information to fill by the BS when ordering painting and non painting products 
                    , Comment__c=commentsForPO
                );

                currAssToUpdate.Status__c = 'SOURCED';

                update currAssToUpdate;
                insert newpo;

                //WCH 02/07/2019 C-003199
                map<String,DirectOrder__c> mapDO = new Map<String, DirectOrder__c>();
                for(DirectOrder__c theDO : [SELECT Id, Agency_mode__c,BodyShop__c,Distributor__c FROM DirectOrder__c WHERE RecordType.DeveloperName=:PaintingOrAnnexes AND Distributor__c =: mapNameAccount.get(disName).id AND BodyShop__c =:currAssInserted.BodyShop__c]){
                  mapDO.put(theDO.BodyShop__c+'-'+theDO.Distributor__c,theDO);
                }

                for(Distributor_reference__c disRef : mapIdDiSRef.values()){
                    OrderLine__c newOl = new OrderLine__c(
                                                    partNumber__c = disRef.Manufacturer_reference__r.Manufacturer_ID__c, 
                                                    description__c = disRef.Manufacturer_reference__r.Description__c,
                                                    purchaseOrder__c = newpo.Id,
                                                    type__c = (disRef.Manufacturer_reference__r.Recordtype.DeveloperName == 'Painting' ? 'P' : 'X'),
                                                    AssessmentPrice__c = disRef.Distributor_public_price__c,
                                                    CataloguePrice__c = disRef.Distributor_public_price__c,
                                                    PartList__r = (new PartList__c(TECH_OriginalPart__c = disRef.Manufacturer_reference__r.Manufacturer_ID__c+'-'+disRef.Distributor__r.Name+'-'+currAssInserted.Id)),
                                                    Manufacturer__c = disRef.Distributor__r.Name,
                                                    BodyShopDiscount__c = disRef.BSDiscount__c,
                                                    AXADiscount__c = (currAssInserted.TECH_EntityCountryCode__c != null && currAssInserted.TECH_EntityCountryCode__c=='ES')?disRef.ASDiscount__c:0 //KEM 06/07/2022 C-004754  : AS Discount is not uploaded in PO for products in Painting for Agency Mode
                                                    
                                                    );

                    if(mapIdQuantity.containsKey(disRef.Id)){
                        //NPE 25/02/2022 C-004596 PACKAGING CONTENT MULTIPLY UNITS/PRICES
                        newOl.quantity__c = Integer.valueOf(mapIdQuantity.get(disRef.Id));//*disRef.Manufacturer_reference__r.Minimum_quantity__c;
                    }

                    orderLinesIoInsert.add(newOl);
                }
                insert orderLinesIoInsert;

                //select PO and its OL to update suppliable orderlines
                List <PurchaseOrder__c> listPO = [SELECT Assessment__c, Status__c,(SELECT Id, Suppliable__c FROM OrderLines__r) FROM PurchaseOrder__c WHERE Assessment__c =: currAssInserted.Id];

                for(PurchaseOrder__c po : listPO){
                    po.OrderNumber__c = orderNum;
                    purchaseOrders.add(po);
                    for(OrderLine__c ol : po.OrderLines__r){
                        ol.Suppliable__c = 'YES';
                        ol.OrderType__c = 'FINAL';
                        ol.ExpectedDeliveryDuration__c = '1';
                        //DUN 25/04/2016 To be defined later, for the tim being using labels
                        //DUN 14/07/2016 Use fields from Distributor_reference__c table
                        //ol.BodyShopDiscount__c = Double.valueOf(system.Label.PartBS);
                        //ol.AXADiscount__c = Double.valueOf(system.Label.PartAS);
                        orderLines.add(ol);
                    }
                }

                if(orderLines.size() > 0){
                    update orderLines;
                }
                for(PurchaseOrder__c po : listPO){
                    po.Status__c = 'ISSUED';
                }

                //update purchase orders to execute offering process
                if(purchaseOrders.size() > 0){
                    update purchaseOrders;
                }

                List <PrerequisiteOrder__c> listSO = [select Id, Assessment__c, Status__c, (select Name, Type__c , Accepted__c, Selected__c, DeliveryStatus__c from Offers__r) from PrerequisiteOrder__c where Assessment__c =: currAssInserted.Id];
                
                for(PrerequisiteOrder__c so : listSO){
                    for(Offer__c off : so.Offers__r){
                        off.Accepted__c = 'YES';
                        offers.add(off);
                    }
                }

                if(offers.size() > 0){
                    update offers;
                }

                for(PrerequisiteOrder__c so : listSO){
                    so.Status__c = 'RESPONDED';
                    so.OfferType__c = 'OFFERING';
                    salesOrders.add(so);
                }
                system.debug('## so '+salesOrders);

                //updating salesorder to execute process till it reach staus indelivery
                if(salesOrders.size() > 0){
                    update salesOrders;
                }
            }
        }

        return currAssToInsert.Id;
    }
 
}