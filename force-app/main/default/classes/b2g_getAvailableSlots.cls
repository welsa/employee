/*
* @author:      Telesio Consultant
* @created:     27/12/2021
* @description: Invocable Apex class used in flow B2G - SelfCare to retrieve available 
*               slots for reservation for a repairmen
*/
public with sharing class b2g_getAvailableSlots {

    public class ObjectContext {     
        @InvocableVariable(required=false label='Brand code of selected repairmen' description='Eg. CARG, FPB,...' )
        public String brandCode;

        @InvocableVariable(required=true label='Intervention à domicile ?' description='Boolean true or false' )
        public Boolean isMobileService;        

        @InvocableVariable(required=false label='Postal code' description='Necessary if Intervention à Domicile' )
        public String postalCode;

        @InvocableVariable(required=false label='City' description='Necessary if Intervention à Domicile' )
        public String city;

        @InvocableVariable(required=false label='address' description='Necessary if Intervention à Domicile')
        public String address;

        @InvocableVariable(required=false label='Partner Branch Reference Number' description='Reference Number of partner branch' )
        public String partnerBranchId;

        @InvocableVariable(required=true description='"R - Réparable or NR - Non réparable or NA - Non disponible"' label='recommendedOperationType')
        public String recommendedOperationType;

        @InvocableVariable(required=false  label='is ADAS ?' description='IsAdas')
        public Boolean isAdas;

        @InvocableVariable(required=true label='Require a loan vehicle ?' description='Enter 1 if yes and 0 if No')
        public Integer share;

        @InvocableVariable(required=true label='Selected car parts' description='Selected Car parts')
        public List<b2g_CarParts__mdt> selectedCarParts;        

        @InvocableVariable(required=true label='Damage type' description='Damage type: B - Casse | C - Fissure | I - Impact| N/A - Non disponible' )
        public String type;

        @InvocableVariable(required=false label='Impact size' description='B - Plus grand qu’une pièce de 2 euros |S - Plus petit qu’une pièce de 2 euros| U - Ne sait pas' )
        public String size;

        @InvocableVariable(required=false label='isInViewField' description='True or False' )
        public Boolean isInViewField;

        @InvocableVariable(required=false  label='isInEdge' description='True or False')
        public Boolean isInEdge;

        @InvocableVariable(required=false  label='Number of impacts' description='Number of impacts')
        public String NumOfImpacts;
    }

    public class request{
        public workshopBrand workshopBrand; 
        public mobileServices mobileServices;
        public partnerBranch partnerBranch;  
        public String recommendedOperationType; 
        public Integer share; 
        public damage damage;

        public request( workshopBrand workshopBrand, 
                        mobileServices mobileServices, 
                        partnerBranch partnerBranch, 
                        String recommendedOperationType, 
                        Integer share, 
                        damage damage){
            this.workshopBrand = workshopBrand;
            this.mobileServices = mobileServices;
            this.partnerBranch = partnerBranch;
            this.recommendedOperationType = recommendedOperationType;
            this.share = share;
            this.damage = damage;
        }
    }

    public class requestSAD{
        public mobileServices mobileServices;
        public partnerBranch partnerBranch;  
        public String recommendedOperationType; 
        public Integer share; 
        public damage damage;

        public requestSAD(mobileServices mobileServices, 
        partnerBranch partnerBranch, 
        String recommendedOperationType, 
        Integer share, 
        damage damage){
            this.mobileServices = mobileServices;
            this.partnerBranch = partnerBranch;
            this.recommendedOperationType = recommendedOperationType;
            this.share = share;
            this.damage = damage;
        }
    }


    public class workshopBrand{
        public String brandCode;

        public workshopBrand(String brandCode){
            this.brandCode = brandCode;
        }
    }

    public class mobileServices{
        public String postalCode;
        public String city;

        public mobileServices(String postalCode, String city){
            this.postalCode  = postalCode;
            this.city        = city;
        }
    }

    public class partnerBranch{
        public String[] ids; 

        public partnerBranch(String[] ids){
            this.ids = ids;
        }
    }

    public class window{
        public String window;
        //public String oem;
        public Boolean isAdas;

        // public window(String window, String oem, Boolean isadas){
        //     this.window = window;
        //     this.oem    = oem;
        //     this.isadas = isadas == null ? false : isadas;
        // }

        public window(String window, Boolean isAdas){
            this.window = window;
            //this.oem    = oem;
            this.isAdas = isAdas == null ? false : isadas;
        }
    }

    public class damage{
        public window[] window;
        public String type;
        public impacts[] impacts;

        public damage(window[] window, String type, impacts[] impacts){
            this.window  = window;
            this.type    = type;
            this.impacts = impacts;
        }
    }

    public class impacts{
        public String size;
        public Boolean isInViewField;
        public Boolean isInEdge;

        public impacts(String size, Boolean isInViewField, Boolean isInEdge){
            this.size           = size;
            this.isInViewField  = isInViewField == null ? false : isInViewField;
            this.isInEdge       = isInEdge == null ? false : isInEdge;
        }
    }

    public class Result {
        @InvocableVariable(required=false label='Is Success ?')
        public Boolean isSuccess;

        @InvocableVariable(required=false label='Response : Available Slots')
        public String availableSlotsJson;

        @InvocableVariable(required=false label='JSON Request')
        public String requestJson;

        public Result(Boolean isSuccess, String availableSlotsJson, String requestJson){
            this.isSuccess = isSuccess;
            this.availableSlotsJson = availableSlotsJson;
            this.requestJson = requestJson;
        }
    }


    /***
    * @description	Method to prepare callout to retrieve slots 
    * @param	    obj 
    * @return		List<Slots> 
    * @exception   	None
    ***/   
    @InvocableMethod(label='[b2g] get Available Slots' description='Make WS callout to retrieve available slots for selection repairmen' callout=true)
    public static List<Result> getAvailSlotsActions(List<ObjectContext> obj) {
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions START with : ' + obj);

        List<impacts> impacts = new List<Impacts>();
        List<Window> windows = new List<Window>();

        workshopBrand workshopBrand;
        Integer       share                     = obj[0].share;
        String        recommendedOperationType  = obj[0].recommendedOperationType;
        partnerBranch partnerBranch; 

        new partnerBranch(new List<String>{obj[0].partnerBranchId});

        mobileServices  mobileServices = null;
        if(obj[0].isMobileService){
            //mobileServices = new mobileServices(obj[0].address, obj[0].postalCode, obj[0].city);
            mobileServices = new mobileServices(obj[0].postalCode, obj[0].city);
            partnerBranch = new partnerBranch(new List<String>());
        }else{
            mobileServices  = new mobileServices('','');
            partnerBranch   = new partnerBranch(new List<String>{obj[0].partnerBranchId});
            workshopBrand   = new workshopBrand(obj[0].brandCode);

        }
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions mobileServices : ' + mobileServices);

        if(obj[0].selectedCarParts != null){
            for(b2g_CarParts__mdt carpart : obj[0].selectedCarParts){
               // windows.add(new window(carpart.Code__c, null, obj[0].isadas));
               windows.add(new window(carpart.Code__c, obj[0].isadas));
            }
        }
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions windows : ' + windows);


        if(obj[0].type == 'I' && obj[0].selectedCarParts != null){//Damage type is Impact
            String NumberOfImpacts = obj[0].NumOfImpacts;
            for(b2g_CarParts__mdt carpart : obj[0].selectedCarParts){
                impacts.add(new impacts(obj[0].size, obj[0].isInViewField, obj[0].isInEdge));
            }
        }
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions impacts : ' + windows);


        Damage damage = new Damage(windows, obj[0].type, impacts);
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions damage : ' + damage);
    
        String body;
        if(obj[0].isMobileService){
            system.debug('getAvailSlotsActions isSAD');
            RequestSAD req = new requestSAD(mobileServices, partnerBranch, recommendedOperationType, share, damage);
            body = JSON.serialize(req);
            System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions body : ' + body);

        }else{
            Request req = new request(workshopBrand, mobileServices, partnerBranch, recommendedOperationType, share, damage);
            body = JSON.serialize(req);
            System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions body : ' + body);

        }


        PFR_WsCredential__c credential = [
            select id,NOB_ClientId__c, NOB_ClientSecret__c, NOB_Endpoint__c from PFR_WsCredential__c where name = 'b2g' LIMIT 1
        ];


        String endpoint =    credential.NOB_Endpoint__c + 'availabilities'; 
        Integer timeout = 120000;
        String method = 'POST';
        Map<String, String> headerConfigs = new Map<String,String>();
        headerConfigs.put('client_id', credential.NOB_ClientId__c);
        headerConfigs.put('client_secret', credential.NOB_ClientSecret__c);
        headerConfigs.put('Content-Type', 'application/json');
        HttpResponse resp = b2g_CalloutManager.getResponse(endpoint, method, timeout, body, headerConfigs);
	    System.debug(resp);
        System.debug(resp.getBody());
        System.debug(LoggingLevel.DEBUG, 'getAvailSlotsActions');

        if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
            return new List<Result>{new Result(true, resp.getBody(), body)};
        }else{
            return new List<Result>{new Result(false, resp.getBody(), body)};
        }
    }



}