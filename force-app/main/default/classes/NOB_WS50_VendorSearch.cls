/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_WS50_VendorSearch
  -- - Author        : ASE
  -- - Description   : Class used by xxx to retrieve availability
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 27-AUG-2020    ASE     1.0     Initial version
  -- 24-NOV-2020    ASE     1.0     RSIW-3762
  -- 09-DEC-2020    ARA     1.1     RSIW-5493
  -- 18-AUG-2021    GBH     1.2     RSIW-10608
  -- 30-SEP-2021    LMU     1.3     RSIW-10608 
  -- 01-APR-2022    HMO     1.4     RSIW-11798
  **********************************************************************
*/
@RestResource(urlMapping='/v1.0/getPlanning/*')
global with sharing class NOB_WS50_VendorSearch {

    @HttpPost
    global static void processRequest() {
        ///services/apexrest/v1.0/getPlanning/*
        System.debug('### START METHOD processRequest');
        map<String,String> mapHeaders = new map<String,String>();
        xResponse results = null;
        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;

        //convert the requestBody into a string
      //  try{
            String body = RestContext.request.requestBody.toString();
            //String body = '{"addrCity":"Cléry"," addrLine1":"8 rue de la porte","addrLine2":"","addrPostCode":"95420","capabilities":"","endDate":"","maxReturn":"","repairType":"","startDate":"","vehicleType":""}';
            system.debug('## body:' + body);

            
            results = getPlanning(body);
            if(results.code == '404' || results.code == '405' || results.code == '406' || results.code == '400' || results.code == '409'){
                RestContext.response.StatusCode = Integer.valueOf(results.code);
                Map<String,String> res = new Map<String,String>();
                res.put('code', results.code);
                res.put('description', results.description);
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
            }else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(results));
            }
     //   }
    //    catch(Exception ex){
      //      results = 'No results found due to: '+ex.getMessage();
       // }
       // RestContext.response.responseBody = Blob.valueOf(results);
        
        System.debug('### END METHOD processResponse');
    }
    
    public static Map<String,String> getAllCompetences(){
        Map<String,String> item =new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Case.NOB_SkillSet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            item.put(pickListVal.getValue(), pickListVal.getLabel());
            
            //lstRet.add(item);
        } 
        return item;
    }

    public static xResponse getPlanning(String body) {
        System.debug('### START METHOD getPlanning');

        xResponse results = null;
        String callerSystem = null;
        Id insurerId = null;
        map<String,list<String>> mapParameters = new map<String,list<String>>();

       //try{
            requestDetails receivedRequest =(requestDetails)JSON.deserialize(body, requestDetails.class);
            // check who's calling
            system.debug('## receivedRequest.keyAccountID'+ receivedRequest.keyAccountID);
            if(receivedRequest.keyAccountID != null){
                list<Account> assureurList = [Select Id, NOB_CallerSystem__c from account where NOB_KeyAccountId__c = : receivedRequest.keyAccountID limit 1];
                if(assureurList.size() > 0){
                    callerSystem = assureurList[0].NOB_CallerSystem__c;
                    insurerId = assureurList[0].Id;
                }
            }
            system.debug('##callerSystem'+ callerSystem);
            //callerSystem = 'MACSF';
            if(callerSystem == null){
                //@error
                 results = createResponseSolaris('409', 'Key account number not found in Salesforce', null);
                //results = JSON.serialize(responseInstance);
            }
            else{
                String capabilities =  receivedRequest.capabilities;
                if(capabilities != null && capabilities.length() > 0){
                    Map<String,String> competences = getAllCompetences();
                    String delimiter = ';';
                    if(capabilities.contains(',')){
                        delimiter = ',';
                    }
                    String[] asCapabilities = capabilities.split(delimiter);
                    for(String capability : asCapabilities){
                        if(!competences.containsKey(capability)){
                            //@error
                             results = createResponseSolaris('406', 'Invalid Capability:' + capability, null);
                            //results = JSON.serialize(responseInstance);
                            return results;
                        }
                    }
                }

                String addrStreet =  (String.IsNotBlank(receivedRequest.addrLine2)) ? (receivedRequest.addrLine1+ ' '+ receivedRequest.addrLine2) : receivedRequest.addrLine1;
                System.debug('addrStreet:' + addrStreet);
                
                if(receivedRequest!= null) {
                    List<Contact> contactList = [Select Id, MailingLatitude, MailingLongitude, NOB_TECH_IsDummy__c
                    from Contact
                    where MailingStreet =:addrStreet  AND
                    MailingCity = :receivedRequest.addrCity AND
                    MailingPostalCode = :receivedRequest.addrPostCode
                    ];

                    Contact conDetail = (contactList.size() > 0 ) ? contactList[0]: null;
                    System.debug('conDetail:' + conDetail);
                    if(conDetail != null){
                        
                        // build map of parameters dates

                        // build map of parameters location
                        //RSIW-11798-HMO-01-04-2022
                        //Commenting check Latitudes for contact
                     
                        /*if(conDetail.MailingLatitude != null && conDetail.MailingLongitude != null){*/
                            mapParameters.put('Distance', new List<string>(new string[] {'latitude-'+conDetail.MailingLatitude, 'Longitude-'+conDetail.MailingLongitude}));

                            String receivedStartDate =  (receivedRequest.startDate != null) ? (receivedRequest.startDate.day() +'/'+  receivedRequest.startDate.month() +'/'+receivedRequest.startDate.year()) : (system.today().day()+'/'+system.today().month()+'/'+system.today().year());
                            system.debug('## receivedStartDate: '+receivedStartDate);
                            dateTime recStartDate =  date.parse(receivedStartDate);

                            String receivedEndDate;
                            If(callerSystem == 'Solaris') {
                                receivedEndDate =(receivedRequest.endDate != null) ? (receivedRequest.endDate.day() + '/' + receivedRequest.endDate.month() + '/' + receivedRequest.endDate.year()) : (recStartDate.addDays(7).day() + '/' + recStartDate.addDays(7).month() + '/' + recStartDate.addDays(7).year());
                            }
                            else{
                                integer capacityScopeDays = (receivedRequest.capacityScope != null) ?  Integer.valueOf(receivedRequest.capacityScope) : 7;
                                receivedEndDate = recStartDate.addDays(capacityScopeDays).day() + '/' + recStartDate.addDays(capacityScopeDays).month() + '/' +recStartDate.addDays(capacityScopeDays).year();
                            }
                            mapParameters.put('Disponibilite__r', new List<string>(new string[] {'Startdate-Greater_Than-'+receivedStartDate, 'Enddate-Less_Than-'+receivedEndDate}));
                            String skillSet = (receivedRequest.capabilities != null) ? 'NOB_SkillSet__c-INCLUDES-'+ String.valueOf(receivedRequest.capabilities) : 'NOB_SkillSet__c-Not_Equals-null';
                            //String postalCode = (receivedRequest.addrPostCode != null) ? 'NOB_TechZoneIntervention__c-Contains-'+ String.valueOf(receivedRequest.addrPostCode) : null;
                            //RSIW-3762  ASE 23/11/2020 :
                            String postalCode = (receivedRequest.addrPostCode != null) ? 'Id IN (SELECT NOB_Account__c FROM NOB_InterventionZone__c WHERE NOB_PostalCode__c =-Inner-'+ String.valueOf(receivedRequest.addrPostCode) : null;

                            // ASE 16/11/2020 :
                            String insurerIdParam = insurerId !=null ? 'Id IN (SELECT NOB_Bodyshop__c FROM NOB_AccountRelationship__c WHERE PFR_Inactive__c=false AND NOB_Compte__c =-Inner-' + String.valueOf(insurerId) : null;
                            List<string> accountParams = new list<string>(new string[] {skillSet});
                            if(postalCode !=null){
                                accountParams.add(postalCode);
                            }

                            // ASE 16/11/2020 : 
                            if(insurerIdParam !=null){
                                accountParams.add(insurerIdParam);
                            }
                            mapParameters.put('Account', accountParams);




                            mapParameters.put('limit', new list<string>(new string[] {String.ValueOf(receivedRequest.maxReturn)}));

                            system.debug('## mapParameters:'+mapParameters);
                        /*}
                        else{
                            //@error
                             results = createResponseSolaris('404', 'No vendor found. Please pass correct address details', null);
                            //results = JSON.serialize(responseInstance);
                        }*/
                    }
                    else{
                        // create dummmy contact
                        insert new Contact(  FirstName = 'Dummy'
                                ,lastName = 'Contact'
                                ,Phone = '0145261167'
                                ,MobilePhone='01234567'
                                ,MailingStreet = addrStreet
                                ,MailingCity = receivedRequest.addrCity
                                ,MailingPostalCode = receivedRequest.addrPostCode
                                ,NOB_TECH_IsDummy__c = true);

                        /*Integer start = System.Now().millisecond();
                        while(System.Now().millisecond()< start+700){
                            system.debug('## XX: '+ [Select Id, MailingLatitude, MailingLongitude, NOB_TECH_IsDummy__c
                            from Contact
                            where MailingStreet =:addrStreet  AND
                            MailingCity = :receivedRequest.addrCity AND
                            MailingPostalCode = :receivedRequest.addrPostCode AND
                            Name = 'Dummy Contact' AND
                            Phone = '0145261167'
                            ]);
                        }*/
                         results = createResponseSolaris('0', 'Unable to find address.  Please try later', null);
                        //results = JSON.serialize(responseInstance);
                    }


                    if(mapParameters.size() >0){
                        // send parameters to RulesEngines
                        list<account> vendorList = NOB_AP50_RulesEngines.getReparateur(null, mapParameters);
                        if(vendorList.size() > 0){
                            results = buildVendorResponse(vendorList, receivedRequest.maxReturn, callerSystem,insurerId);//LMU RSIW-10608 30/09/2021 Add the insurer ID to filter relationship
                            if(conDetail.NOB_TECH_IsDummy__c){
                                delete conDetail;
                            }
                        }
                        else{
                            //@error
                             results = createResponseSolaris('405', 'No vendor found', null);
                            //results = JSON.serialize(responseInstance);
                        }
                    }
                }
                System.debug('### END METHOD getPlanning: +results');
            }
        /*}
        catch(Exception e){
            //@error
             results = createResponseSolaris('400', 'Unknow error:' + e.getMessage(), null);
            //results =JSON.serialize(responseInstance);
        }*/

        return results;
    }

    public static xResponse buildVendorResponse(list<account> vendorList, integer maxReturn, string callerSystem,Id InsurerId){
        System.debug('### START METHOD buildVendorResponse: ');
        
        //GBH  RSIW-10608 18/08/2021 Added one parameter
        //LMU RSIW-10608 30/09/2021 Add the insurer ID and inactive flag to filter relationship
        List <NOB_AccountRelationship__c> lstAccRel = new List<NOB_AccountRelationship__c> ([SELECT Id, NOB_Bodyshop__c, NOB_KAexternalid__c FROM NOB_AccountRelationship__c WHERE NOB_Compte__c = :InsurerId and PFR_Inactive__c = false and NOB_Bodyshop__c IN :vendorList]);
        system.debug('vendorList: '+ vendorList);
        system.debug('lstAccRel: '+ lstAccRel);
        Map <String, String> mapAccRel = new Map<String, String>();
        for (NOB_AccountRelationship__c ar : lstAccRel) {
            if (!mapAccRel.containsKey(ar.Id)) {
                mapAccRel.put(ar.NOB_Bodyshop__c, ar.NOB_KAexternalid__c);
            }
        }

        /////////////

        xResponse response = null;
        List<axaSlotsSolaris> axaSlotsSolarisList = new List<axaSlotsSolaris>();
        List<axaSlotsMACSF> axaSlotsMACSFList = new List<axaSlotsMACSF>();
        map<Id, account> mapAccDetails = new map<Id, account>();
        map<String,integer> mapAccSlotDetails = new map<String, integer>();
        Map<String,Integer> mapUniqueIndex = new Map<String,Integer>();
        Integer index = 0;
        Integer cmptMaxReturn = 0; //8994
        Boolean iCheckPlanning = false; //8994
        for(Account acc: vendorList){
            iCheckPlanning = false; //8994
            if(!mapAccDetails.containsKey(acc.Id)){
                mapAccDetails.put(acc.Id, acc);
            }
            if(!mapUniqueIndex.containsKey(acc.Id)){
                index++;
                mapUniqueIndex.put(acc.Id,index);
            }
            if(acc.Disponibilite__r != null) {
                System.debug('### buildVendorResponse -acc.Id-'+acc.Id+'-maxReturn-'+maxReturn+'-acc.Disponibilite__r-'+acc.Disponibilite__r); //8994
                if (maxReturn == null || cmptMaxReturn < maxReturn ) { //8994
                    System.debug('### buildVendorResponse - cmptMaxReturn-'+cmptMaxReturn+'-acc.Id-'+acc.Id+'-maxReturn-'+maxReturn); //8994
                    for (NOB_Planning__c planning : acc.Disponibilite__r) {
                        if (((callerSystem == 'MACSF') && mapAccRel.get(acc.Id) != null) || (callerSystem != 'MACSF')){ //LMU RSIW-10608 30/09/2021 don't return account without external id for MACSF
                            iCheckPlanning = true;
                        }
                        DateTime splitTime;
                        DateTime splitEndTime;
                        string key;
                        //System.debug('### buildVendorResponse - planning.NOB_StartDate__c.getTime()-'+planning.NOB_StartDate__c.getTime()+'-planning.NOB_EndDate__c.getTime()-'+planning.NOB_EndDate__c.getTime()); //8994
                        if ((planning.NOB_EndDate__c.getTime() - planning.NOB_StartDate__c.getTime()) / 1000 / 60 > 30) {
                            splitTime = planning.NOB_StartDate__c;
                            splitEndTime = splitTime.addMinutes(60);
                            while (splitEndTime.getTime() <= planning.NOB_EndDate__c.getTime()) {
                                key = acc.Id  + ';' + String.ValueOf(splitTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')); //ARA :RSIW-5493 change datetime format to timezone format
                                //System.debug('### buildVendorResponse - key-'+key); //8994
                                if(!mapAccSlotDetails.containsKey(key)){
                                    mapAccSlotDetails.put(key, 1);
                                }
                                else {
                                    mapAccSlotDetails.put(key, mapAccSlotDetails.get(key)+1);
                                }
                                splitTime = splitTime + (0.5 / 24);
                                splitEndTime = splitEndTime.addMinutes(30);
                            }
                        }
                        else {
                            splitTime = planning.NOB_StartDate__c;
                            key = acc.Id  + ';' + String.ValueOf(splitTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')); //ARA :RSIW-5493 change datetime format to timezone format
                            //System.debug('### buildVendorResponse - key-'+key); //8994
                            if (!mapAccSlotDetails.containsKey(key)) {
                                mapAccSlotDetails.put(key,1);
                            }
                            else {
                                mapAccSlotDetails.put(key, mapAccSlotDetails.get(key)+1);
                            }
                        }
                    }
                    if (iCheckPlanning) {//8994
                        cmptMaxReturn++; //8994
                    }//8994
            	} //8994
            }
            else{
                //@error
                 response = createResponseSolaris('405', 'No vendor found', null);
                //response = JSON.serialize(responseInstance);
            }
        }

        System.debug('## mapAccSlotDetails: '+ mapAccSlotDetails);
        // building response
        if(mapAccSlotDetails != null){
            for(string mapKey : mapAccSlotDetails.keySet()){
                if(mapAccSlotDetails.get(mapKey)!= null){
                    Id accountId =  Id.valueOf(mapKey.split(';')[0]);
                    String startDateTime = mapKey.split(';')[1];
                    integer counter = mapAccSlotDetails.get(mapKey);
                    Integer uniqueIndex = mapUniqueIndex.get(accountId);
                    if(callerSystem == 'MACSF'){
                        axaSlotsMACSF axaSlotDetail = createInstanceMACSF(mapAccDetails.get(accountId), startDateTime, counter, callerSystem, uniqueIndex, mapAccRel.get(accountId));//GBH  RSIW-10608  18/08/2021  Added one parameter
                        axaSlotsMACSFList.add(axaSlotDetail);
                    }
                    else{
                        axaSlotsSolaris axaSlotDetail = createInstanceSolaris(mapAccDetails.get(accountId), startDateTime, counter, callerSystem, uniqueIndex);
                        axaSlotsSolarisList.add(axaSlotDetail);
                    }
                }
            }
        }

        system.debug('## axaSlotsSolarisList:'+axaSlotsSolarisList);
        if(axaSlotsSolarisList.size() > 0){
             response = createResponseSolaris('0', null, axaSlotsSolarisList);
            //response = JSON.serialize(responseSolarisInstance);
        }
        else if(axaSlotsMACSFList.size() > 0){
             response= createResponseMACSF('0', null, axaSlotsMACSFList);
            //response = JSON.serialize(responseMACSFInstance);
        }else{
           response = createResponseSolaris('405', 'No vendor found', null);
        }

        System.debug('### END METHOD buildVendorResponse: '+response);
        return response;
    }

    public static xResponse createResponseMACSF(string code, String description, list<axaSlotsMACSF> axaSlotsMACSFList){
        system.debug('### START METHOD createResponseMACSF: ');

        responseMACSF responseMACSFInstance  = new responseMACSF();
        responseMACSFInstance.code = code;
        responseMACSFInstance.description = description;
        responseMACSFInstance.slots = axaSlotsMACSFList;

        system.debug('### END METHOD createResponseMACSF: ');
        return responseMACSFInstance;
    }

    public static axaSlotsMACSF createInstanceMACSF(Account a, String splitPreviousTime, integer counter, string callerSystem, Integer uniqueIndex, String KAexternalid){
        system.debug('### START METHOD createInstanceMACSF: ');

        axaSlotsMACSF axaSlotsDetail = new axaSlotsMACSF();
        axaSlotsDetail.repairerTaxID = a.VATNumber__c;
        axaSlotsDetail.supplierid = a.ReferenceNumber__c;
        axaSlotsDetail.volume = String.valueOf(counter);
       if(a.BillingLatitude == null || a.BillingLatitude == 0){
            axaSlotsDetail.addressLat = '0';
        }else{
        	axaSlotsDetail.addressLat = a.BillingLatitude + '';//String.valueOf(a.BillingLatitude);    
        }
        
        if(a.BillingLongitude == null || a.BillingLongitude == 0){
            axaSlotsDetail.addressLong = '0';
        }else{
        	axaSlotsDetail.addressLong = a.BillingLongitude + '';//String.valueOf(a.BillingLatitude);    
        }
        axaSlotsDetail.capabilities = (a.NOB_SkillSet__c) ;
        axaSlotsDetail.repairerEmail = a.NOB_EmailAddress__c ;
        axaSlotsDetail.distance= String.ValueOf(a.get('Distance'));
        axaSlotsDetail.repairerAddress = a.BillingStreet;
        axaSlotsDetail.repairerName = a.Name;
        axaSlotsDetail.repairerPhoneNo =a.Phone;
        axaSlotsDetail.repairerPostCode = a.BillingPostalCode +','+a.BillingCity;
        axaSlotsDetail.repairerRank = uniqueIndex + ''; //String.ValueOf(a.NOB_Tech_RankingNumeric__c);
        axaSlotsDetail.slotDateTime = splitPreviousTime; 
        axaSlotsDetail.IdentifiantExterneClient = KAexternalid;

        system.debug('### END METHOD createInstanceMACSF: ');
        return axaSlotsDetail;
    }

    public static xResponse createResponseSolaris(string code, String description, list<axaSlotsSolaris> axaSlotsSolarisList){
        system.debug('### START METHOD createResponseSolaris: ');

        responseSolaris responseSolarisInstance  = new responseSolaris();
        responseSolarisInstance.code = code;
        responseSolarisInstance.description = description;
        responseSolarisInstance.slots = axaSlotsSolarisList;

        system.debug('### END METHOD createResponseSolaris: ');
        return responseSolarisInstance;
    }

    public static axaSlotsSolaris createInstanceSolaris(Account a, String splitPreviousTime, integer counter, string callerSystem, Integer uniqueIndex){
        system.debug('### START METHOD createInstanceSolaris: ');
        axaSlotsSolaris axaSlotsDetail = new axaSlotsSolaris();
        axaSlotsDetail.availableSlots = String.valueOf(counter);
        axaSlotsDetail.fceCode = a.ReferenceNumber__c;
        if(!Test.isRunningTest())
        	axaSlotsDetail.distance= String.ValueOf(a.get('Distance'));
        axaSlotsDetail.repairerAddress = a.BillingStreet;
        axaSlotsDetail.repairerName = a.Name;
        axaSlotsDetail.repairerPhoneNo =a.Phone;
        axaSlotsDetail.repairerPostCode = a.BillingPostalCode +','+a.BillingCity;
        axaSlotsDetail.repairerRank = uniqueIndex + '';//String.ValueOf(a.NOB_Tech_RankingNumeric__c);
        axaSlotsDetail.slotDateTime = splitPreviousTime; 
        system.debug('### END METHOD createInstanceSolaris: ');
        return axaSlotsDetail;
    }

    // wrapper VendorSearchRequest
    public class requestDetails{
        //public string callerSystem;
        public string addrCity;
        public string addrLine1;
        public string addrLine2;
        public String addrPostCode;
        public String capabilities;
        public dateTime endDate; // solaris only
        public integer maxReturn;
        public string repairType; // Solaris only. to add in RulesEngine
        public dateTime startDate;
        public string vehicleType; // solaris only     Champ reçu via le flux Solaris et non utilisé pour la recherche
        public string capacityScope; // MACF only.
        public boolean courtesyCar; // MACF only. to add in RulesEngine. to confirm.
        public string keyAccountID; // MACF only.
        public string searchType; // MACF only.not to add in RulesEngine
    }
    
    virtual class xResponse{
        public String code;
        public String description;
    }

    class responseMACSF extends xResponse{
        
        public list<axaSlotsMACSF> slots;
    }

    public class axaSlotsMACSF{
        public String addressLat; // MACSF only
        public String addressLong; // MACSF only
        public String capabilities; // MACSF only
        public String distance;
        public String repairerAddress;
        public String repairerEmail; // MACSF only
        public String repairerName;
        public String repairerPhoneNo;
        public String repairerPostCode;
        public String repairerRank;
        public String repairerTaxID; // MACSF only
        public String supplierid; // MACSF only
        public String volume;  // MACSF only
        public String slotDateTime; 
        public String IdentifiantExterneClient;  // MACSF only
    }

    class responseSolaris extends xResponse{
        
        public list<axaSlotsSolaris> slots;
    }

    public class axaSlotsSolaris{
        public String availableSlots;  // Solaris only
        public String distance;
        public String fceCode; // Solaris only
        public String repairerAddress;
        public String repairerName;
        public String repairerPhoneNo;
        public String repairerPostCode;
        public String repairerRank;
        public String slotDateTime; 
    }
}