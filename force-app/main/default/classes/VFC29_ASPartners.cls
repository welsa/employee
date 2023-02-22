/*************************************************************************************
Class Name - VFC29_ASPartners
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 06-08-2021
Function - Class for visualforce page ASPartners.vfp
#Ticket  - 

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           06-08-2021   Initial version
* WCH           30-08-2022   C-004781
* RRJ           31-08-2022   C-004781
*************************************************************************************/
public class VFC29_ASPartners {
    public static List<Account> lstDistributors {get;set;}
    public static Map<Id,Account> mapDistributors {get;set;}
    public static List<Distributeur> lstResult{get;set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public static User currentUser{get;set;}
    public static boolean hasAlreadyRunAsP {get;set;}
    public static String distNames {get;set;}
    public static Boolean doAllow = false;

    
    
    public VFC29_ASPartners(){
        VFC29_ASPartnersController();
    }    
    
    @RemoteAction
    public static string callDistributor(string TechDis, String manufacturerReferences){

        System.debug('@@ start of remote action call Distributor'+ TechDis);

        String searchUrl;
        String errMsg;
        String returnFactor;

        datetime qryStart = datetime.now();
        Map<String, Object> mapInputParams = new map<String,Object>();//WCH 30/08/2022 C-004781
        try{

            if ( String.isnotBlank(TechDis) && String.isnotBlank(manufacturerReferences) && TechDis.equals('OPISTO')){//WCH 30/08/2022 C-004781
                // String searchUrlRet;
                Account dist;
                

                if (manufacturerReferences != null){
                    for (Account dis: [select ReferenceNumber__c,Tech_Distributor__c
                            from account where Tech_Distributor__c =: TechDis.toUpperCase()
                            ]){
                        dist = dis;
                    }
                }            

                currentUser = [SELECT Name, Contact.Account.ReferenceNumber__c FROM User where id =: UserInfo.getUserId()];



                String accessToken = OrderConfirmation.getAuthentication();

                if ( (dist != null && dist.Tech_Distributor__c != null && String.isnotBlank(manufacturerReferences) && string.IsnotBlank(currentUser.Contact.Account.ReferenceNumber__c)) || doAllow  ){
                    String key = dist.Tech_Distributor__c + '-' + currentUser.Contact.Account.ReferenceNumber__c;
                    String bsExtId = RestDistributorUtility.getBSExtId (key.toUpperCase());
                    system.debug('## bsExtId' +bsExtId);
                    mapInputParams.put('manufacturerReferences', manufacturerReferences);
                    mapInputParams.put('accessToken', accessToken);
                    mapInputParams.put('bsExtId', bsExtId);
                    // searchUrl = calloutToDist(new mapInputParams<String,Object>{'manufacturerReferences' => manufacturerReferences, 'accessToken' => accessToken, 'bsExtId' => bsExtId});
                    if (String.isBlank(bsExtId)){
                        errMsg = system.label.AsPartnerNoREf;
                        returnFactor = 'Error';
                    }
                    else{
                        searchUrl = OrderConfirmation.calloutToDist(mapInputParams);
                    }
                    // mapResultcallDistforPart.put('searchUrl' , searchUrl);                
                }
                else{
                    errMsg = system.label.AsPartnerNoREf;
                    returnFactor = 'Error';
                }



                // map <String, Object> mapReturnCallout = callDistforPart(new map<String, Object> {'accessToken'=> accessToken, 'manufacturerReferences' => '123456', 'partId' => partIdToUpdate});

                // searchUrlRet =  mapReturnCallout.containsKey('searchUrl') ? (string)mapReturnCallout.get('searchUrl') : null;

            //RRJ 31/08/2022 C-004781
            }else if ( String.isnotBlank(TechDis) && TechDis.equals('FERRON')){//WCH 30/08/2022 C-004781
                currentUser = [SELECT Name, Contact.Account.ReferenceNumber__c FROM User where id =: UserInfo.getUserId()];
                mapInputParams.put('bsReferenceNo', currentUser.Contact.Account.ReferenceNumber__c);
                mapInputParams.put('NamedCredentialDevName', 'FerronJWT');
                searchUrl = OrderConfirmation.calloutToDistFerron(mapInputParams);
                if(string.isblank(searchUrl)){
                    errMsg = system.label.AsPartnerNoURL;
                    returnFactor = 'Error';
                }
                // else{
                //     returnFactor = searchUrl;
                // }
                //if searchUrl is blank > string.isblank 
                /* errMsg = system.label.AsPartnerNoREf;
                    returnFactor = 'Error'; 
                    add custom label pour dire connection error avec ferron */

            }
            else{
                errMsg = system.label.AsPArtnerErr;
                returnFactor = 'Error';
            }


            if (String.isnotBlank(searchUrl)){
                returnFactor = searchUrl;
            }
            
            

        }
         
        catch(Exception e){

            system.debug('@@@@@err'+e.getMessage() + e.getStackTraceString());
            errMsg = e.getMessage() + e.getStackTraceString();
            
            returnFactor = 'Error';
            

        }
         datetime qryEnd = datetime.now();
         decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
         tempExec = (tempExec.divide(1000, 5));

        if (String.isnotBlank(errMsg)){
            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            wrapperLog.className = 'VFC29_ASPartners';
            wrapperLog.process = 'EpartsOrdering';

            wrapperLog.objectreference = currentUser.Name;

            wrapperLog.sobjectName = TechDis;
            wrapperLog.jsonresponse = errMsg != null && errMsg.length() <= 30000 ? errMsg : '';

            wrapperLog.inout = 'Inbound;Outbound';

            if(errMsg.contains('Exceptions') || (errMsg.contains('Error') && !errMsg.contains('"ErrorMessage":null'))){
                wrapperLog.status = Label.STATUSFAILED;
            }
            else{
                wrapperLog.status = Label.STATUSPASSED;
            }  



            if(errMsg.length() > 30000){
                wrapperLog.attachmentResponsebody = errMsg;
            }  
            wrapperLog.executionTime = tempExec;
           
            APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');


        }
        return returnFactor;
    }
    
    
    public void VFC29_ASPartnersController(){
  		mapDistributors = new Map<Id, Account>();
        distNames = '';
        String recordTypeIdz = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('DISTRIBUTOR').getRecordTypeId();

        hasErrors = false;
        isToastError= false;

        hasAlreadyRunAsP = false;
        // rrentUser = [SELECT  Id, BodyShopId__c, DistributorId__c, UserRoleId, UserRole.DeveloperName,LanguageLocaleKey/*WCH 01/06/2020 C-003728*/
        //             FROM    User
        //             WHERE   Id =: UserInfo.getUserId()];

        for (Account acc : [SELECT Id, Name,  E_part_Order_Link__c, Partner_Available__c, ReferenceOEM__c,Tech_Distributor__c, toLabel(TypeOfService__c) FROM Account WHERE Partner_Available__c = true AND recordTypeId =: recordTypeIdz]){
            //lstDistributors.add(acc);
            mapDistributors.put(acc.Id, acc);
            distNames += acc.Tech_Distributor__c + ';';  
        }
        
        //System.debug('££££ accs distributors    =====: '+ lstDistributors);
        System.debug('££££ accs distributors    =====: '+ mapDistributors);
        if (mapDistributors != null && mapDistributors.size() > 0){
        	lstResult = getDistributorlogo(mapDistributors, 'LOGOASPARTNER');
        }
        //String accessToken = OrderConfirmation.getAuthentication();
    }
    @RemoteAction
    public static String authenticateRem(String accNames){

        try{
            system.debug('@@@ authenticateRem:');
            hasAlreadyRunAsP = true;
            if (String.isnotBlank(accNames)){
                for (String accName: accNames.split(';')){
                    system.debug('@@ accName:'+accName);
                    if (accName.toUpperCase() == 'OPISTO'){
                        String accessToken = OrderConfirmation.getAuthentication();
                    }
                }
            }   
            return null;
            
        }
        catch(exception e){
            system.debug(e.getMessage() + e.getStackTraceString());
            return null;
        }

    }
        
   public static List<Distributeur> getDistributorlogo(Map<Id, Account> mapDistributors, String nameFile)
    {
        System.debug('££££ in getDistributorlogo');
        String base64Img = '';
        nameFile = nameFile != null ? '%'+nameFile.toUpperCase()+'%' : nameFile;
        List<Distributeur> lstDistributeur = new List<Distributeur>();
       	Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>();
        if (mapDistributors != null){
            Set<Id> setDistributors = mapDistributors.keySet();
            for (attachment atcc : [SELECT Id, Name, Body, ParentId, ContentType FROM Attachment 
                                                WHERE ParentId IN: setDistributors AND (ContentType = 'image/png' OR ContentType = 'image/jpeg') AND Name LIKE :nameFile
                                   ORDER BY LastModifiedDate DESC]){
                                       mapAttachments.put(atcc.ParentId, atcc);
                                   }
        
            System.debug('££££ mapAttachments '+ mapAttachments);        

            // Taking the 1st one
            for (Id accId : mapDistributors.keySet()){
                base64Img = 'no-logo';
            
                System.debug('££££ mapDist '+ mapDistributors.get(accId));
                if(mapAttachments != null && mapAttachments.size() > 0)
                    {	
                        for (Id parentId : mapAttachments.keySet()){

                            if (mapDistributors.containsKey(parentId) && mapAttachments.containsKey(accId)){
                                base64Img = EncodingUtil.base64Encode(mapAttachments.get(accId).Body);
                            }
                    }
                    }

                Boolean isTokenExpired = false;
                if (String.isnotBlank(mapDistributors.get(accId).Tech_Distributor__c) && (mapDistributors.get(accId).Tech_Distributor__c == 'OPISTO')){
                    
                }
            
                Distributeur distr = new Distributeur(mapDistributors.get(accId), base64Img);
                System.debug('££££ distributeur '+ distr);
                lstDistributeur.add(distr);
            }  
        }
        System.debug('££££ map '+ lstDistributeur);
        return lstDistributeur;
    }
    
    public class Distributeur {
        public Account distributor {get; set;}
        // public Boolean isTokenExpired {get; set;}
        public String distributorLogo {get; set;}
        
         public Distributeur(Account distributor, String logo)	{
             this.distributor = distributor;
             this.distributorLogo = logo;
            //  this.isTokenExpired = isTokenExpired;
         }
    }
    
}