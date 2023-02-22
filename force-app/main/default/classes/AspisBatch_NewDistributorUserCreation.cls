global class AspisBatch_NewDistributorUserCreation  implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_NewDistributorUserCreation
-- - Author        : WCH 
-- - Description   : This batch will create associated Distributor User for selected Distributor
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 26-APR-2021  WCH   1.0      Initial version C-004308
--------------------------------------------------------------------------------------
database.executebatch(new AspisBatch_NewDistributorUserCreation(), 200); 
*/
    //this set will be used to store newly created User id 
    public set <id> newlyCreatedUser                                         = new set <id>();

	//dml status list for User to be created
    public list <string> statusCreate 											= new list <string>();

    List <Database.Saveresult> lstResultsUserCreate;

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err = false;

    //map containing corresponding LocaleSidKey based on locale
    public map <string,string> mapLocaldLocaleSidKey;

    //map containing corresponding TimeZoneSidKey based on locale
    public map <string,string> mapLocaleTimeZoneSidKey;

    //map containing corresponding LanguageLocaleKey based on locale
    public map <string,string> mapLocaleLanguageLocaleKey;

    public map <id,id> mapAccIdUserId = new map <id,id>();
    public map <String,id> mapAccRefNumAccId = new map <String,id>();

	global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_NewDistributorUserCreation - START');

        return Database.getQueryLocator([select id,Name,Locale__c,ContactEmail__c,ContactUser__c,Communities_Target_Profile__c,ReferenceNumber__c,CCUsername__c,ShippingCountry,ShippingPostalCode,ShippingState,ShippingCity,ShippingStreet,Phone,Fax,Tech_DistriutorUserRoleId__c
	                                        from Account
	                                        where createDistributorUser__c = true and recordtype.developername=: ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
    	system.debug('## Start AspisBatch_NewDistributorUserCreation - execute');

    	//list to hold new permssion set assigned
        list <User> userToInsertList               						= new list <User>();

        List<AspisBatchUserCreation__mdt> getASPISBatchUserCreationConfig = [select id,userActive__c from AspisBatchUserCreation__mdt where DeveloperName='AspisBatch_NewDistributorUserCreation'];
        //build mapLocaldLocaleSidKey,mapLocaleTimeZoneSidKey and mapLocaleLanguageLocaleKey
		mapLocaldLocaleSidKey 													= new map <string,string>{'dutchbelgium' => 'nl_BE',
																											'frenchbelgium' => 'fr_BE',
																											'french' => 'fr_FR',
																											'german' => 'de_DE',
																											'spanish' => 'es_ES'};

		mapLocaleTimeZoneSidKey 												= new map <string,string>{'dutchbelgium' => 'Europe/Brussels',
																											'frenchbelgium' => 'Europe/Brussels',
																											'french' => 'Europe/Paris',
																											'german' => 'Europe/Berlin',
																											'spanish' => 'Europe/Paris'};

		mapLocaleLanguageLocaleKey 												= new map <string,string>{'dutchbelgium' => 'nl_BE',
																											'frenchbelgium' => 'fr_BE',
																											'french' => 'fr',
																											'german' => 'de',
																											'spanish' => 'es'};

        //creating new contact
        for(Account acc : scope){
            //check required fields
            if(string.isBlank(acc.ContactEmail__c) ||
               string.isBlank(acc.Locale__c) ||
               string.isBlank(acc.Communities_Target_Profile__c) ||
               string.isBlank(acc.ReferenceNumber__c) ||
               string.isBlank(acc.CCUsername__c) ||
               string.isBlank(acc.Tech_DistriutorUserRoleId__c) ||
               string.isBlank(acc.ShippingStreet) ||
               string.isBlank(acc.ShippingCity) ||
               string.isBlank(acc.ShippingState) ||
               string.isBlank(acc.ShippingPostalCode) ||
               string.isBlank(acc.ShippingCountry) ||
               string.isBlank(acc.Name)){
                    err = true;
                    statusCreate.add(acc.Id + ',,KO,Missing Required Fields.\n');
            }else{
                system.debug('profile>>'+acc.Communities_Target_Profile__c.split(';')[1]);
                //all required fields present
                //check if there is no contact first
                if(acc.ContactUser__c==null){
                    userToInsertList.add(new User(  isActive                 = (getASPISBatchUserCreationConfig.size()>0 ? getASPISBatchUserCreationConfig[0].userActive__c:false),
                                                    ProfileId                = acc.Communities_Target_Profile__c.split(';')[1],
                                                    UserRoleId               = acc.Tech_DistriutorUserRoleId__c,
                                                    CurrencyIsoCode          = 'EUR',
                                                    LastName                 = acc.Name,
                                                    Username                 = acc.CCUsername__c,//(acc.Name.replaceAll('[^a-zA-Z0-9+]', '')) + '@alpha-scale.com',
                                                    Email                    = acc.ContactEmail__c,
                                                    Alias                    = acc.Name.trim().left(3) + acc.Name.trim().right(2)+String.valueOf(Crypto.getRandomInteger()).substring(1,4),//randomize   
                                                    Phone                    = acc.Phone,
                                                    Fax                      = acc.Fax,
                                                    TimeZoneSidKey           = mapLocaleTimeZoneSidKey.containsKey(acc.Locale__c.toLowerCase()) ?  mapLocaleTimeZoneSidKey.get(acc.Locale__c.toLowerCase()) : 'Europe/Paris',
                                                    LocaleSidKey             = mapLocaldLocaleSidKey.containsKey(acc.Locale__c.toLowerCase()) ?  mapLocaldLocaleSidKey.get(acc.Locale__c.toLowerCase()) : 'fr_FR',
                                                    LanguageLocaleKey        = mapLocaleLanguageLocaleKey.containsKey(acc.Locale__c.toLowerCase()) ? mapLocaleLanguageLocaleKey.get(acc.Locale__c.toLowerCase()) : 'fr',
                                                    EmailEncodingKey         = 'ISO-8859-1',
                                                    Street                   = acc.ShippingStreet,
                                                    City                     = acc.ShippingCity,
                                                    State                    = acc.ShippingState,
                                                    PostalCode               = acc.ShippingPostalCode,
                                                    Country                  = acc.ShippingCountry,
                                                    DistributorID__c         = acc.ReferenceNumber__c,
                                                    isaspis__c               = true));
                    mapAccRefNumAccId.put(acc.ReferenceNumber__c,acc.Id);
                }else{
                    statusCreate.add(acc.Id + ',,KO,This account already has a User associated.\n');
                    err                                                             = true;
                }
            }//end check on required fields	
        }//end looping in account

        //create contact
        system.debug('## userToInsertList.size() ' + userToInsertList.size());
        if(!userToInsertList.isEmpty()){
            lstResultsUserCreate                                                 = Database.insert(userToInsertList, false);

            //error management
            integer index                                                       = 0;
            string errorMsg                                                     = '';
            string successMsg                                                   = '';
            
            for(Database.SaveResult lRCC : lstResultsUserCreate){
                errorMsg                                                        = '';
                successMsg                                                      = '';

                if(!lRCC.isSuccess()){
                    //raise error
                    errorMsg  = userToInsertList[index].LastName + ',,KO,' + lRCC.getErrors()[0].getMessage() + '\n';
                    system.debug('## AspisBatch_NewDistributorUserCreation - errorMsg'+errorMsg);
                    statusCreate.add(errorMsg);
                    err                                                         = true;
                }else{
                    //no error
                    successMsg                                                  = ',' + lRCC.getId() + ',OK,' + '\n';
                    statusCreate.add(successMsg);

                    //get successfully created user
                    newlyCreatedUser.add(lRCC.getId());

                    mapAccIdUserId.put(mapAccRefNumAccId.get(userToInsertList[index].DistributorID__c),lRCC.getId());
                }

                index++;
            }//end looping in result list
        }//end if !userToInsertList.isEmpty()

    	system.debug('## End AspisBatch_NewDistributorUserCreation - execute');
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('>>>Start AspisBatch_NewDistributorUserCreation - FINISH');

        String emailSubject                                                     = '';
        String batchJobName                                                     = '';
        String csvHeader                                                        = '';

        if(err == true){
             emailSubject                                                       = '*Data RampUp - New Distributor User Creation Report';
        }
        else{
             emailSubject                                                       = 'Data RampUp - New Distributor User Creation Report';
        }
        
        if(!statusCreate.isEmpty()){
            batchJobName                                                        = 'AspisBatch_NewDistributorUserCreation';
            csvHeader                                                           = 'Account ID,User ID,Status,Error Message';

            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    emailSubject, 
                                                    csvHeader, 
                                                    'Distributor User Creation Status', 
                                                    statusCreate,
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }else{
            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    '*Data RampUp - New Distributor User Creation', 
                                                    csvHeader, 
                                                    'Distributor User Creation Status', 
                                                    new list <string>{',,KO,No records were processed'},
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }

        if(!newlyCreatedUser.isEmpty()){
            Database.executeBatch(new AspisBatch_NewBSAccountUpdate(mapAccIdUserId));
        }
        system.debug('>>>End AspisBatch_NewDistributorUserCreation - FINISH');
    }
}