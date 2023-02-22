/*
* @author:      Telesio Consultant
* @created:     21/01/2022
* @description: Invocable Apex class used in flow B2G - SelfCare to make a booking for
                a b2g Intervention.
*/
public with sharing class b2g_makeBooking{

    public class ObjectContext {     
        @InvocableVariable(required=false label='Brand code Id of selected repairmen' )
        public String brandCode;

        @InvocableVariable(required=true label='Workshop Brand' )
        public String workshopBrand;

        @InvocableVariable(required=true label='Slot Id' description='freeSlotId' )
        public String slotId;

        @InvocableVariable(required=true label='Intervention à domicile ?' description='Boolean true or false' )
        public Boolean isMobileService;        

        @InvocableVariable(required=false label='Postal code' description='Necessary if Intervention à Domicile' )
        public String postalCode;

        @InvocableVariable(required=false label='City' description='Necessary if Intervention à Domicile' )
        public String city;

        @InvocableVariable(required=false label='address' description='Necessary if Intervention à Domicile')
        public String address;

        @InvocableVariable(required=true description='"R - Réparable or NR - Non réparable or NA - Non disponible"' label='recommendedOperationType')
        public String recommendedOperationType;

        @InvocableVariable(required=false  label='is ADAS ?' description='IsAdas')
        public Boolean isAdas;

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

        @InvocableVariable(required=true  label='Matriculation' description='Immatriculation number')
        public String vrn;

        @InvocableVariable(required=true  label='insuranceName' description='Insurance Name')
        public String insuranceName;

        @InvocableVariable(required=true  label='insuranceCode' description='Insurance code')
        public String insuranceCode;

        @InvocableVariable(required=true  label='policyNumber' description='PolicyNumber')
        public String policyNumber;

        @InvocableVariable(required=true  label='folderRef' description='folderRef')
        public String folderRef;

        @InvocableVariable(required=true  label='lastname' description='lastname')
        public String lastname;

        @InvocableVariable(required=true  label='firstname' description='firstname')
        public String firstname;

        @InvocableVariable(required=true  label='email' description='email')
        public String email;

        @InvocableVariable(required=true  label='phoneNumber' description='phoneNumber')
        public String phoneNumber;

        @InvocableVariable(required=false label='WS Credential')
        public PFR_WsCredential__c wsCredential;

        @InvocableVariable(required=true label='Require a loan vehicle ?' description='Enter 1 if yes and 0 if No')
        public Integer share;

        @InvocableVariable(required=false label='Additional booking comments')
        public String comments;
    }

    public class partnerBranch{
        public String id; 

        public partnerBranch(String id){
            this.id = id;
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

    public class workshopBrand{
        public String brandCode;

        public workshopBrand(String brandCode){
            this.brandCode = brandCode;
        }
    }

    public class window{
        public String window;
        public Boolean isAdas;

        public window(String window, Boolean isAdas){
            this.window = window;
            this.isAdas = isAdas == null ? false : isAdas;
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

    public class vehicle{
        public String vrn;

        public vehicle(String vrn){
            this.vrn  = vrn;
        }
    }

    public class insured{
        public String lastname;
        public String firstname;
        public String email;
        public String phoneNumber;

        public insured(String lastname,  String firstname, String email, String phoneNumber){
            this.lastname = lastname;
            this.firstname = firstname;
            this.email = email;
            this.phoneNumber = phoneNumber;
        }
    }

    public class mobileServices{
        public String postalCode;
        public String city;
        public String address;

        public mobileServices(String postalCode, String city, String address){
            this.postalCode  = postalCode;
            this.city        = city;
            this.address     = address;
        }
    }

    public class policyInformation{
        public String insuranceName;
        public String insuranceCode;
        public String policyNumber;

        public policyInformation(String insuranceName,  String insuranceCode, String policyNumber){
            this.insuranceName = insuranceName;
            this.insuranceCode = insuranceCode;
            this.policyNumber = policyNumber;
        }
    }

    public class request{
        public workshopBrand workshopBrand; 
        public partnerBranch partnerBranch;  
        public String recommendedOperationType; 
        public damage damage;
        public vehicle vehicle; 
        public insured insured; 
        public policyInformation policyInformation; 
        public String folderRef;
        public String comments;
        public Integer share;

        public request( workshopBrand workshopBrand, 
                        partnerBranch partnerBranch, 
                        String recommendedOperationType, 
                        damage damage, 
                        vehicle vehicle,
                        insured insured,
                        policyInformation policyInformation, 
                        String folderRef,
                        Integer share,
                        String comments){
            this.workshopBrand = workshopBrand;
            this.partnerBranch  = partnerBranch;
            this.recommendedOperationType = recommendedOperationType;
            this.damage = damage;
            this.vehicle = vehicle;
            this.insured = insured;
            this.policyInformation = policyInformation;
            this.folderRef = folderRef;
            this.share = share;
            this.comments = comments;
        }
    }

    public class requestSAD{
        public workshopBrand workshopBrand; 
        public mobileServices mobileServices;
        public partnerBranch partnerBranch;  
        public String recommendedOperationType; 
        public damage damage;
        public vehicle vehicle; 
        public insured insured; 
        public policyInformation policyInformation; 
        public String folderRef;
        public String comments;
        public Integer share;

        public requestSAD( workshopBrand workshopBrand, 
                        mobileServices mobileServices, 
                        partnerBranch partnerBranch, 
                        String recommendedOperationType, 
                        damage damage, 
                        vehicle vehicle,
                        insured insured,
                        policyInformation policyInformation, 
                        String folderRef,
                        Integer share,
                        String comments){
            this.workshopBrand = workshopBrand;
            this.mobileServices = mobileServices;
            this.partnerBranch  = partnerBranch;
            this.recommendedOperationType = recommendedOperationType;
            this.damage = damage;
            this.vehicle = vehicle;
            this.insured = insured;
            this.policyInformation = policyInformation;
            this.folderRef = folderRef;
            this.share = share;
            this.comments = comments;
        }
    }


    public class Result {
        @InvocableVariable(required=false label='Is Success ?')
        public Boolean isSuccess;

        @InvocableVariable(required=false label='JSON Booking Resp')
        public String bookingResp;

        @InvocableVariable(required=false label='JSON Booking Req.')
        public String bookingReq;

        public Result(Boolean isSuccess, String bookingResp, String bookingReq){
            this.isSuccess = isSuccess;
            this.bookingResp = bookingResp;
            this.bookingReq = bookingReq;
        }
    }

    /***
    * @description	Method to prepare & do callout to book a b2g appointment
    * @param	    obj 
    * @return		List<Slots> 
    * @exception   	None
    ***/   
    @InvocableMethod(label='[b2g] Book Appointment' description='Make WS callout to book b2g appointment' callout=true)
    public static List<Result> bookAppointment(List<ObjectContext> obj) {
        System.debug(LoggingLevel.DEBUG, 'bookAppointment START with : ' + obj);

        List<impacts> impacts = new List<Impacts>();
        List<Window> windows = new List<Window>();

        String        recommendedOperationType  = obj[0].recommendedOperationType;
        partnerBranch partnerBranch             = null;

        mobileServices  mobileServices = null;

        partnerBranch  = new partnerBranch(obj[0].brandCode);

        workshopBrand workshopBrand = new workshopBrand(obj[0].workshopBrand);

        if(obj[0].isMobileService){
            mobileServices = new mobileServices(obj[0].postalCode, obj[0].city, obj[0].address);
        }else{
            mobileServices = new mobileServices('','','');
        }
        System.debug(LoggingLevel.DEBUG, 'bookAppointment mobileServices : ' + mobileServices);

        
        for(b2g_CarParts__mdt carpart : obj[0].selectedCarParts){
            windows.add(new window(carpart.Code__c,obj[0].isadas));
        }
        System.debug(LoggingLevel.DEBUG, 'bookAppointment windows : ' + windows);


        if(obj[0].type == 'I'){//Damage type is Impact
            String NumberOfImpacts = obj[0].NumOfImpacts;

            for(b2g_CarParts__mdt carpart : obj[0].selectedCarParts){
                impacts.add(new impacts(obj[0].size, obj[0].isInViewField, obj[0].isInEdge));
            }
        }
        System.debug(LoggingLevel.DEBUG, 'bookAppointment impacts : ' + windows);


        Damage damage = new Damage(windows, obj[0].type, impacts);
        System.debug(LoggingLevel.DEBUG, 'bookAppointment damage : ' + damage);

        vehicle vehicle = new vehicle(obj[0].vrn);
        System.debug(LoggingLevel.DEBUG, 'bookAppointment vehicle : ' + vehicle);

        insured insured = new insured(obj[0].lastname,  obj[0].firstname, obj[0].email, obj[0].phoneNumber);
        System.debug(LoggingLevel.DEBUG, 'bookAppointment insured : ' + insured);

        policyInformation policyInformation = new policyInformation(obj[0].insuranceName,  obj[0].insuranceCode, obj[0].policyNumber);

        //Take only first 60 chars for additional comments
        String additionalComments = obj[0].comments;
        if(additionalComments != null ){
            additionalComments = additionalComments.left(59);
        }

        Request req = new request(workshopBrand, partnerBranch, recommendedOperationType, damage, vehicle, insured, policyInformation, obj[0].folderRef, obj[0].share, additionalComments);
        RequestSAD reqSAD = new requestSAD(workshopBrand, mobileServices, partnerBranch, recommendedOperationType, damage, vehicle, insured, policyInformation, obj[0].folderRef, obj[0].share, additionalComments);
        System.debug(LoggingLevel.DEBUG, 'bookAppointment req : ' + req);
        System.debug(JSON.serialize(req));

        PFR_WsCredential__c credential = [
            select id,NOB_ClientId__c, NOB_ClientSecret__c, NOB_Endpoint__c from PFR_WsCredential__c where name = 'b2g' LIMIT 1
        ];


        String body = obj[0].isMobileService ? JSON.serialize(reqSAD) : JSON.serialize(req) ;
        System.debug('body: ' + body);
        String endpoint =    credential.NOB_Endpoint__c + 'freeslots/' + obj[0].slotId + '/book'; 
        Integer timeout = 120000;
        String method = 'POST';
        Map<String, String> headerConfigs = new Map<String,String>();
        headerConfigs.put('client_id', credential.NOB_ClientId__c);
        headerConfigs.put('client_secret', credential.NOB_ClientSecret__c);
        headerConfigs.put('Content-Type', 'application/json');
        HttpResponse resp = b2g_CalloutManager.getResponse(endpoint, method, timeout, body, headerConfigs);
	    System.debug(resp);
        System.debug(resp.getBody());
        System.debug(LoggingLevel.DEBUG, 'bookAppointment');

        if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
            return new List<Result>{new Result(true, resp.getBody(), body)};
        }else{
            return new List<Result>{new Result(false, resp.getBody(), body)};
        }
    }
}