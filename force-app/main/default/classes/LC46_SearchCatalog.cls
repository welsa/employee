global without sharing class LC46_SearchCatalog {
/*
----------------------------------------------------------------------
-- - Name          : LC46_SearchCatalog
-- - Author        : DUN
-- - Description   : Class for lightning component LC46_SearchCatalog
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 05-APR-2019  DMG   1.0      Initial version C-003081
-- 03-MAY-2019  ASE   1.1      C-003216: Filter is missing on Active Xref
-- 17-JUN-2019  RLA   1.1      C-003254: Log Car Clinic Queries
----------------------------------------------------------------------*/

    @AuraEnabled
    public static List <allBrandsWrapper> getBrands() {
        system.debug('getBrands ---');
        allBrandsWrapper optNone= new allBrandsWrapper();
        optNone.label = system.label.None;
        optNone.value = 'None';
        List < allBrandsWrapper > allOpts = new list < allBrandsWrapper > ();
        allOpts.add(optNone);  
        Set<String> setPicklist = new Set<String>();

        //retrieve CarMappings metadata
        List <CarMappings__mdt> lstBrandMetadataValues = new List<CarMappings__mdt>();
        lstBrandMetadataValues = [Select Id,MasterLabel,CarDestination__c from CarMappings__mdt where MasterLabel like 'CATALOG-%' order by MasterLabel asc];
        system.debug('lstBrandMetadataValues --->'+lstBrandMetadataValues);
            
        // Add these values to the selectoption list.
        for (CarMappings__mdt cm: lstBrandMetadataValues) {
            allBrandsWrapper opt= new allBrandsWrapper();
            //check if already avalaible
            if(!setPicklist.contains(cm.MasterLabel.substring(8))){
                setPicklist.add(cm.MasterLabel.substring(8));
                //opt.label = cm.CarDestination__c;
                opt.label = cm.MasterLabel.substring(8);
                //opt.value = cm.MasterLabel;
                opt.value = cm.CarDestination__c + ';' +cm.MasterLabel.substring(8) ;
                allOpts.add(opt);
            }

        }
        system.debug('allOpts ---->' + allOpts);
        
        return allOpts;
    }
    global class allBrandsWrapper{ 
        @AuraEnabled
        public string label {get;set;}  
        @AuraEnabled
        public string value {get;set;}  
    }
     @AuraEnabled
    public static map<String,Object> getCrossRef(string brand,string oem) {
        system.debug('getCrossRef --- : '+ brand + ' OEM: '+ oem);

        //RLA 17/06/2019 C-003254: Log Car Clinic Queries
        String logString = '';
        map<String,Object> mapOfResult = new map<String,Object>();
        // get language + countryCode
        User currentUser = [Select Id,LanguageLocaleKey,CountryCode,IAMPartClass__c,SubsGain__c  from User where Id=:UserInfo.getUserId()];
        system.debug('currentUser --- : '+ currentUser );

        List<String> lstOEM= new List<String>();
        Set<String> setOEMKeys = new Set<String>();
        Set<String> setOEM = new Set<String>();
        List<String> listPartClass = new List<String>();
        //check if oem values entered contains ;
        if(oem.contains(';')){
            lstOEM = oem.split(';');
        }else{
            lstOEM.add(oem);
        }
        system.debug('lstOEM --- : '+ lstOEM );

        //check IAMPartClass of User
        if(currentUser.IAMPartClass__c!=null){
            if(currentUser.IAMPartClass__c.contains(';')){
                listPartClass = currentUser.IAMPartClass__c.split(';');
            }else{
                    listPartClass.add(currentUser.IAMPartClass__c);
            }
        }

         system.debug('listPartClass --- : '+ listPartClass );

         //loop and build OEM Keys
         for(String s : lstOEM){
            String newOem = '';
            s=cleanseReference(s);
            newOem = currentUser.CountryCode + currentUser.LanguageLocaleKey.substring(0,2) + s + brand;
            newOem = newOem.toUpperCase();
            //newOem = cleanseReference(newOem);
            system.debug('newOem --- : '+ newOem );
            setOEMKeys.add(newOem);
         }
         system.debug('setOEMKeys --- : '+ setOEMKeys );

        List <CrossReference__c> lstCrossRef = new List<CrossReference__c>();

        //look for Cross reference by OEM Keys Built
        lstCrossRef= [select Id,Name,IAMManufacturer__c,IAMPartNumber__c,IAMPartDescription__c,IAMCertifyingOrganization__c,IAMPartClass__c,OEMPartNumber__c,OEMKey__c,IAMPublicPrice__c,ASPublicPrice__c ,OEMPublicPrice__c,OEMCleanPartNumber__c
                      from CrossReference__c 
                      where OEMKey__c in:setOEMKeys 
                      and IAMPartClass__c in:listPartClass
					  /*ASE 03/05/19: C-003216: */
                      and ActiveForSubstitution__c = true];

        for(String c:lstOEM){
            setOEM.add(cleanseReference(c));
        }

        system.debug('lstCrossRef --- : '+ lstCrossRef );
        mapOfResult.put('lstCrossRef',lstCrossRef);
        mapOfResult.put('setOEM',setOEM);
        mapOfResult.put('userSubGain',currentUser.SubsGain__c);

        logString = 'Brand: '+ brand + ', PartType: ' + currentUser.IAMPartClass__c + ', Country: ' + currentUser.CountryCode + ', OEMs: ';
        for (String strOem: setOEM){
            logString +=   strOem + ';';  
        }
        system.debug('logString --- : '+ logString );


        mapOfResult.put('setOEM',setOEM);

        //RLA 17/06/2019 C-003254: Log Car Clinic Queries
        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
        wrapperLog.className = 'LC46_SearchCatalog';
        wrapperLog.sobjectName = 'CrossReference__c';
        wrapperLog.inout = 'Inbound';        
        wrapperLog.status = Label.STATUSPASSED;

        wrapperLog.jsonmessage = logString != null && logString.length() <= 30000 ? logString : '';
         

        if(logString.length() > 30000){
            wrapperLog.attachmentRequestbody = logString;
        }
        APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');

       

       return mapOfResult;    
   }
    public static String cleanseReference(String referenceToCleanse)
    {
        return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
    }
}