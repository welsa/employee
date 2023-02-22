/*************************************************************************************
Class Name - ASPISConstants
Version - 1.0
Created Date - 27 MAR 2015
Function - Class contains all the constants variable used in the application

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Andry Ramarijaona     27/03/2015  Original Version
* Brayan SC             09/04/2015  Added constants concerning the due date calculation class
* Yudish SC             28/04/2015  Added getDeveloperIdMap method
* Dourga SC             29/04/2015  Added constants for field type on object offer
* Yudish SC             29/04/2015  Added constants for field object prerequisiteOrder
* Ashwina               28/11/2016  C-001674 : remove status missing and damaged
* Abdool                17/09/2018  Adding Assessment Tools Constant
* Welsa                 27/09/2018  Adding Purchase Order Not validated invoice status Constant
* Abdool                05/10/2018  Adding new orderline status
* Welsa                 11/10/2018  Adding Invoice compensated Constants
* Welsa                 13/12/2018  Adding Country code  Constants
* Welsa                 29/01/2019  Adding Country code  Constants
* Welsa                 03/06/2019  C-003199 : Painting & Annexes in Agency Mode for Selected BS
* Ruksaar L       12/06/2020   C-003754: IG - Update Query Call for Coler
* Welsa C         31/08/2020   C-003913: NOB - Anticipation - Create Expert RT on Account
* Welsa C         14/10/2020  C-004007: when creating account with recordtype expert, fill the Type field to Expert
* Welsa C         09/11/2020  C-003980: NOB - Compensated Invoices

*************************************************************************************/ 
public class ASPISConstants {

    public static final String STRING_SEPARATOR = ';';

    /*****************************************************************
    *               USER STATIC VALUES
    ******************************************************************/
    //AMI 22/10/2018 : Adding CountryCode
    public static final String userCountryCodeES = 'ES';

     /*****************************************************************
    *               Business Hours STATIC VALUES
    ******************************************************************/
    public static final String spainBusinessHour  = 'ES-Spain';

    /*****************************************************************
    *               PROCESS STATIC VALUES
    ******************************************************************/
    public static final String PROCESS_ELIGIBILITY  = 'Eligibility';
    public static final String PROCESS_SOURCING     = 'Sourcing';

    /*****************************************************************
    *               SOBJECT FIELD NAMES STATIC VALUES
    ******************************************************************/
    public static final String ENTITY_FIELD_API_NAME = 'Entity__c';
    public static final String STATUS_FIELD_API_NAME = 'Status__c';

    /*****************************************************************
    *               SOBJECT RULE STATUS FIELD VALUES
    ******************************************************************/
    public static final String RULE_STATUS_ACTIVE   = 'ACTIVE';

    /*****************************************************************
    *           SOBJECT RULE RECORDTYPE DEVELOPER NAME FIELD VALUES
    ******************************************************************/
    public static final String RULE_RT_NAME_DETAIL_RULE = 'DETAIL_RULE';

    /*****************************************************************
    *               SOBJECT ASSESSMENT STATUS FIELD VALUES
    ******************************************************************/
    public static final String ASSESS_STATUS_CHECKED        = 'CHECKED';
    public static final String ASSESS_STATUS_REJECTED       = 'REJECTED';
    public static final String ASSESS_STATUS_SOURCED        = 'SOURCED';
    public static final String ASSESS_STATUS_READY          = 'READY';
    public static final String ASSESS_STATUS_CANCELED       = 'CANCELED';
    public static final String ASSESS_STATUS_INDELIVERY     = 'INDELIVERY';
    public static final String ASSESS_STATUS_INVOICED       = 'INVOICED';
    public static final String ASSESS_STATUS_CLOSEDOK       = 'CLOSEDOK';
    public static final String ASSESS_STATUS_CLOSEDKO       = 'CLOSEDKO';

    public static final String ASSESS_STATUS_NEW            = 'NEW';
    public static final String ASSESS_STATUS_SUBSTITUTION   = 'SUBSTITUTION';
    public static final String ASSESS_STATUS_OFFERING       = 'OFFERING';
    public static final String ASSESS_STATUS_CLOSED         = 'CLOSED';
        

    public static final String ASSESS_REASONFAILURE_ELIGIBILITYFAILURE   = 'EligibilityFailure';
    public static final String ASSESS_REASONFAILURE_CANCELEDBYBODYSHOP   = 'CanceledByBodyshop';

    public static final String ASSESS_RT_DeveloperName_ClaimOrder = 'ClaimOrder';
    public static final String ASSESS_RT_Name_ClaimOrder = 'Claim Order';
    public static final String ASSESS_RT_DeveloperName_NewAssessment = 'NewAssessment';
    public static final String ASSESS_RT_DeveloperName_Claim = 'Claim';
    public static final String ASSESS_RT_DeveloperName_Crash = 'Crash';

    //AMI 17/09/2018 : Adding Assessment Tools Constant
    public static final String assToolsFRSIDEXA = 'FR_SIDEXA';
    public static final String assToolsBEINFORMEX = 'BE_INFORMEX';
    public static final String assToolsFRDIVA = 'FR_DIVA';

    //AMI 25/10/2018 : Adding TECH_EntityCountryCode
    public static final String assTECH_EntityCountryCodeES = 'ES';

    /*****************************************************************
    *               SOBJECT ORDER LINES STATUS FIELD VALUES
    ******************************************************************/

    public static final String ORD_LINE_STATUS_ISSUE        = 'ISSUE';
    public static final String ORD_LINE_STATUS_INDELIVERY   = 'INDELIVERY';
    public static final String ORD_LINE_STATUS_DELIVERED    = 'DELIVERED';
    public static final String ORD_LINE_STATUS_CANCELED     = 'CANCELED';
    public static final String ORD_LINE_STATUS_INPROCESS    = 'INPROCESS';
    public static final String ORD_LINE_STATUS_DELAYED      = 'DELAYED';
    public static final String ORD_LINE_STATUS_RETURNED     = 'RETURNED';

    //AMI 05/10/2018 : Adding new orderline status
    public static final String ORD_LINE_STATUS_MANAGED     = 'MANAGED';

    /*****************************************************************
    *               SOBJECT PURCHASE ORDER STATUS FIELD VALUES
    ******************************************************************/
    public static final String PUR_ORDER_STATUS_DRAFTQUOTE          = 'DRAFTQUOTE';
    public static final String PUR_ORDER_STATUS_RESPONDED           = 'RESPONDED';
    public static final String PUR_ORDER_STATUS_ISSUED              = 'ISSUED';
    public static final String PUR_ORDER_STATUS_INDELIVERY          = 'INDELIVERY';
    public static final String PUR_ORDER_STATUS_DELIVERED           = 'DELIVERED';
    public static final string PUR_ORDER_STATUS_UNSUPPLIEDQUOTE     = 'UNSUPPLIEDQUOTE';
    public static final String PUR_ORDER_STATUS_DELIVEREDCONFIRMED  = 'DELIVEREDCONFIRMED';
    public static final String PUR_ORDER_STATUS_ORDERED             = 'ORDERED';
    public static final String PUR_ORDER_STATUS_PAYABLE             = 'PAYABLE';
    public static final String PUR_ORDER_STATUS_CANCELED            = 'CANCELED';
    public static final String PUR_ORDER_STATUS_REJECTED            = 'REJECTED';
    public static final String PUR_ORDER_STATUS_CANCELEDINVOICE     = 'CANCELEDINVOICE';
    public static final String PUR_ORDER_STATUS_CLOSEDOK            = 'CLOSEDOK';
    public static final String PUR_ORDER_STATUS_CLOSEDKO            = 'CLOSEDKO';
    public static final String PUR_ORDER_STATUS_PAID                = 'PAID';

    public static final String PUR_ORDER_REASON_CANCELEDBYBS     = 'CanceledByBS';
    public static final String PUR_ORDER_REASON_REJECTEDQUOTE    = 'REJECTEDQUOTE';
    public static final String PUR_ORDER_REASON_UNSUPPLIEDQUOTE  = 'UNSUPPLIEDQUOTE';
    public static final String PUR_ORDER_REASON_NOTSELECTED  = 'NOTSELECTED';

    public static final String PUR_ORDER_INVOICESTATUS_VALIDATED     = 'VALIDATED';
    public static final String PUR_ORDER_INVOICESTATUS_NOTVALIDATED     = 'NOTVALIDATED';


    /*****************************************************************
    *               SOBJECT PREREQUISITE ORDER STATUS FIELD VALUES
    ******************************************************************/

    public static final String PRE_ORDER_STATUS_INACCEPTANCE        = 'INACCEPTANCE';
    public static final String PRE_ORDER_STATUS_RESPONDED           = 'RESPONDED';
    public static final String PRE_ORDER_STATUS_INDELIVERY          = 'INDELIVERY';
    public static final String PRE_ORDER_STATUS_DELIVERED           = 'DELIVERED';
    public static final String PRE_ORDER_STATUS_PREORDERCONFIRMED   = 'PREORDERCONFIRMED';
    public static final String PRE_ORDER_STATUS_CANCELED            = 'CANCELED';
    public static final String PRE_ORDER_STATUS_INVOICED            = 'INVOICED';
    public static final String PRE_ORDER_STATUS_PAID                = 'PAID';
    public static final String PRE_ORDER_STATUS_CANCELEDINVOICE     = 'CANCELEDINVOICE';
    public static final String PRE_ORDER_STATUS_CLOSEDKO            = 'CLOSEDKO';
    public static final String PRE_ORDER_STATUS_CLOSEDOK            = 'CLOSEDOK';
    public static final String PRE_ORDER_STATUS_PREACCEPTANCE       = 'PREACCEPTANCE';
    public static final String PRE_ORDER_STATUS_PENDINGDISTRIBUTORCARE  =  'PENDING DISTRIBUTOR (CARE)';
    public static final String PRE_ORDER_WSSTATUS_ICEOK  =  'ICE Assessment - OK';
    public static final String PRE_ORDER_WSSTATUS_ICEKO  =  'ICE Assessment - KO ';

    //AMI 05/10/2018 : Adding new orderline status
    public static final String PRE_ORDER_STATUS_MANAGED             = 'MANAGED';

    //AMI 22/10/2018 : Adding TECH_EntityCountryCode
    public static final String TECH_EntityCountryCodeES             = 'ES';
    //WCH 13/12/2018 : Adding TECH_EntityCountryCode BE
    public static final String TECH_EntityCountryCodeBE             = 'BE';
    //WCH 29/01/2019 : C-002963 - Select/Unselect ALL on R4 Order page, Adding TECH_EntityCountryCode DE
    public static final String TECH_EntityCountryCodeDE             = 'DE';

    /*****************************************************************
    *               SOBJECT INVOICE STATUS FIELD VALUES
    ******************************************************************/

    public static final String INV_STATUS_SENT      = 'SENT';
    public static final String INV_STATUS_PAID      = 'PAID';
    public static final String INV_STATUS_PAYABLE   = 'PAYABLE';
    public static final String INV_STATUS_ANNULLED_BY_DISTRIBUTOR   = 'INVOICE_ANNULLED_BY_DISTRIBUTOR';//WCH 26/03/2020 C-003679

    public static final String INV_TYPE_CREDITNOTE  = 'CREDITNOTE';
    public static final String INV_TYPE_INVOICE     = 'INVOICE';

    public static final String INV_COMPENSATED_INVOICE     = '97';
    public static final String INV_NOTCOMPENSATED_INVOICE     = '49';

    /*****************************************************************
    *               SOBJECT OFFER TYPE FIELD VALUES
    ******************************************************************/
    public static final String OFFER_TYPE_QUICK        = 'QUICK';
    public static final String OFFER_TYPE_BASIC        = 'BASIC';
    public static final String OFFER_TYPE_OPPORTUNITY  = 'OPPORTUNITY';

    /*****************************************************************
    *               SOBJECT OFFER STATUS FIELD VALUES
    ******************************************************************/
    public static final String OFFER_STATUS_INPROCESS   = 'INPROCESS';
    public static final String OFFER_STATUS_INDELIVERY  = 'INDELIVERY';
    public static final String OFFER_STATUS_DELAYED     = 'DELAYED';
    public static final String OFFER_STATUS_CANCELED    = 'CANCELED';
    //ASE : 28/11/2016 : C-001674
    public static final String OFFER_STATUS_DAMAGED     = 'DAMAGED';
    public static final String OFFER_STATUS_ERROR       = 'ERROR';
    //ASE : 28/11/2016 : C-001674
    public static final String OFFER_STATUS_MISSING     = 'MISSING';
    public static final String OFFER_STATUS_DELIVERED   = 'DELIVERED';
    public static final String OFFER_STATUS_RETURNED    = 'RETURNED';

    //AMI 05/10/2018 : Adding new orderline status
    public static final String OFFER_STATUS_MANAGED     = 'MANAGED';

    /*****************************************************************
    *               OPERATOR STATIC VALUES
    ******************************************************************/
    public static final String LOGICAL_OPERATOR_AND     = 'AND';
    public static final String LOGICAL_OPERATOR_OR      = 'OR';
    public static final String OPERATOR_EQUALS          = 'EQUALS';
    public static final String OPERATOR_NOT_EQUALS      = 'NOT_EQUALS';
    public static final String OPERATOR_GREATER         = 'GREATER';
    public static final String OPERATOR_GREATER_EQUALS  = 'GREATER_EQUALS';
    public static final String OPERATOR_LESS            = 'LESS';
    public static final String OPERATOR_LESS_EQUALS     = 'LESS_EQUALS';
    public static final String OPERATOR_IN              = 'IN';
    public static final String OPERATOR_CONTAINS        = 'CONTAINS';
    public static final String OPERATOR_BETWEEN         = 'BETWEEN';

    /*****************************************************************
    *               ACCOUNT RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_ACCOUNT = 'Account';

    public static final String ACCOUNT_RT_LABEL_DISTRIBUTOR = 'Distributor';
    public static final String ACCOUNT_RT_LABEL_PAYMENT     = 'Payment';

    public static final String ACCOUNT_RT_DeveloperName_Distributor = 'DISTRIBUTOR';
    public static final String ACCOUNT_RT_DeveloperName_BodyShop = 'BODYSHOP';
    public static final String ACCOUNT_RT_DeveloperName_Expert = 'NOB_Expert';//WCH 31/08/2020 C-003913
    public static final String ACCOUNT_RT_DeveloperName_Payment = 'Payment';

    //AMI 02/10/2018 : Adding Account Fields Constant
    public static final String ACCOUNT_Locale_French = 'French';
    //WCH 14/10/2020 C-004007
    public static final String ACCOUNT_Type_Expert = 'Expert';
    /*****************************************************************
    *               INVOICE RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_INVOICE = 'Invoice__c';

    public static final String INVOICE_RT_LABEL_CreditNote  = 'BodyShop Credit Note';
    public static final String INVOICE_RT_LABEL_Draft       = 'BodyShop Invoice';
    //public static final String INVOICE_RT_DeveloperName_Distributor = 'DISTRIBUTOR';
    public static final String INVOICE_RT_LABEL_DISTRIBUTORCREDITNOTE   = 'Distributor Credit Note';
    public static final String INVOICE_RT_LABEL_DISTRIBUTORINVOICE      = 'Distributor Invoice';

    public static final String INVOICE_RT_DeveloperName_CreditNote = 'CreditNote';
    public static final String INVOICE_RT_DeveloperName_Draft = 'Draft';

    public static final String INVOICE_RT_DeveloperName_DISTRIBUTORCREDITNOTE = 'DISTRIBUTORCREDITNOTE';
    public static final String INVOICE_RT_DeveloperName_DISTRIBUTORINVOICE    = 'DISTRIBUTORINVOICE';

    /*****************************************************************
    *               PARTLIST RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static final String PARTLIST_RT_DeveloperName_Labour = 'Labour';

    /*****************************************************************
    *               DISCOUNT RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static final String DISCOUNT_RT_DeveloperName_VirtualADiscount = 'VirtualADiscount';

    /*****************************************************************
    *               DIRECT ORDERS RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static final String DIRECTORDER_RT_DeveloperName_Painting = 'Painting';//WCH 03/06/2019 C-003199 : Painting & Annexes in Agency Mode for Selected BS
    public static final String DIRECTORDER_RT_DeveloperName_Annexes = 'Store_Item';//WCH 03/06/2019 C-003199 : Painting & Annexes in Agency Mode for Selected BS
    /*****************************************************************
    *               PREREQUISITE ORDER RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_PREREQUISITEORDER = 'PrerequisiteOrder__c';

    public static final String PREREQUISITEORDER_RT_Name_InAcceptance   = 'InAcceptance';
    public static final String PREREQUISITEORDER_RT_Name_InDelivery     = 'InDelivery';
    public static final String PREREQUISITEORDER_RT_Name_Eliminated     = 'Eliminated';

    public static final String PREREQUISITEORDER_RT_DeveloperName_InAcceptance = 'InAcceptance';
    public static final String PREREQUISITEORDER_RT_DeveloperName_InDelivery = 'InDelivery';

    /*****************************************************************
    *               PURCHASE ORDER RECORDTYPE STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_PURCHASEORDER = 'PurchaseOrder__c';

    public static final String PURCHASEORDER_RT_Name_DraftQuote = 'DraftQuote';
    public static final String PURCHASEORDER_RT_Name_Eliminated = 'Eliminated';
    public static final String PURCHASEORDER_RT_Name_InDelivery = 'In Delivery';
    public static final String PURCHASEORDER_RT_Name_Ordered    = 'Ordered';

    /*****************************************************************
    *               DISCOUNT RECORDTYPE STATIC VALUES
    ******************************************************************/

    public static final String DISCOUNT_RT_DeveloperName_BodyshopDiscount   = 'BodyshopDiscount';

    /*****************************************************************
    *               CASE STATIC VALUES
    ******************************************************************/

    public static final String caseComplainantInt = 'Intermediary';
    public static final string caseStatus2 = '2';
    public static final integer caseSLASevenDays = 7;
    public static final integer caseSLAFourteenDays= 14;

    //AMI 29/10/2018 : Adding status
    public static final string caseStatusClosed = 'Closed';

    //AMI 15/11/2018 : Adding type
    public static final string caseTypePROBLEM = 'PROBLEM';
    public static final string caseTypeQUESTION = 'QUESTION';

    //AMI 19/11/2018 : Adding RecordType
    public static final string caseRTDevNameBusinessProcessCase = 'Business_process_case';
    public static final string caseSObjectName = 'Case__c';

    //WCH 09/11/2020 : C-003980
    public static final string PFR_ASCompDecisionFinalOui = 'O';
    public static final string PFR_ASCompDecisionFinalNon = 'N';
    /*****************************************************************
    *               MASTER RULE STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_MASTER_RULE = 'MasterRules__c';

    public static final String MASTER_RULE_RT_DeveloperName_RULESET = 'RULESET';
    public static final String MASTER_RULE_RT_DeveloperName_MASTERRULE = 'MASTERRULE';

    public static final String MASTER_RULE_STATUS_ACTIVE = 'ACTIVE';
    public static final String MASTER_RULE_STATUS_ARCHIVED = 'ARCHIVED';

    /*****************************************************************
    *               CRITERIA STATIC VALUES
    ******************************************************************/
    public static string SOBJECT_CRITERIA = 'DetailRule__c';

    public static final String CRITERIA_RT_DeveloperName_ACTION = 'ACTION';
    public static final String CRITERIA_RT_DeveloperName_AggregateCriteria = 'AggregateCriteria';
    public static final String CRITERIA_RT_DeveloperName_CRITERIA = 'CRITERIA';
    public static final String CRITERIA_RT_DeveloperName_FILTERCONDITION = 'FILTERCONDITION';
    public static final String CRITERIA_RT_DeveloperName_FILTERINPUT = 'FILTERINPUT';
    public static final String CRITERIA_RT_DeveloperName_GroupByCriteria = 'GroupByCriteria';
    public static final String CRITERIA_RT_DeveloperName_Parameters = 'Parameters';

    // ABT 27-APR-2016
    public static final String CRITERIA_RT_LABEL_ACTION                 = 'Action';
    public static final String CRITERIA_RT_LABEL_AggregateCriteria      = 'Aggregate Criteria';
    public static final String CRITERIA_RT_LABEL_CRITERIA               = 'Criteria';
    public static final String CRITERIA_RT_LABEL_FILTERCONDITION        = 'Filter Condition';
    public static final String CRITERIA_RT_LABEL_FILTERINPUT            = 'Filter Input';
    public static final String CRITERIA_RT_LABEL_GroupByCriteria        = 'Group By Criteria';
    public static final String CRITERIA_RT_LABEL_Parameters             = 'Parameters';

    /*****************************************************************
    *               SOBJECT CONTACT
    ******************************************************************/
    public static final String CONTACT_RT_DeveloperName_MULTIADDRESS                 = 'Multiaddress';
    /***********************************************************************
    *               PROFILE ID METHOD
    ************************************************************************/
    public static id getProfileAdminId(){
        return ([Select Id From Profile
                Where name = 'Administrateur système'
                    OR name = 'System Administrator'
                    OR name = 'Amministratore del sistema'
                    OR name = 'Systemadministrator'
                    OR name = 'Systemadministratör'
                    OR name = 'Administrador do sistema'
                    OR name = 'Systeembeheerder'
                    OR name = 'Systemadministrator' order by createddate asc limit 1].ID);
    }

    public static set<Id> getProfileIdAdmin(){
        Set<Id> setId = new set<Id> ();
       
        for (Profile off : [SELECT	Id
							FROM	Profile
                            Where name = 'Administrateur système'
                            OR name = 'System Administrator'
                            OR name = 'Amministratore del sistema'
                            OR name = 'Systemadministrator'
                            OR name = 'Systemadministratör'
                            OR name = 'Administrador do sistema'
                            OR name = 'Systeembeheerder'
                            OR name = 'System Administrator2'                    
                            OR name = 'Systemadministrator'
                                ]){
            setId.add(off.Id);                    
        }        

        return setId;
    }

    /*****************************************************************
    * Method to generate a map that contains developer Name and id for a specific Sobject Type
    ******************************************************************/
    public static map<String,Id> getDeveloperIdMap(String ObjectType){
        map <String,Id> developerIdMap = new map <String,Id>();

        //populating developerIdMap
        for(RecordType r : [select DeveloperName,Id
                                        from RecordType
                                        where SobjectType =: ObjectType ]){
            developerIdMap.put(r.DeveloperName,r.Id);
        }
        return developerIdMap;
    }

    public static Boolean manualSourcingPO = false;

    /***********************************************************************
    *               BUSINESSHOURS QUERY 
    ************************************************************************/
    public static BusinessHours currBusinessHours;
    public final Static String DEFAULTBS = 'DEFAULT';
    public static Boolean isInvokedFromFlow = false; 
    public final Static String BSCACHENAME = 'stdBusinessHours';
    public static map<String,BusinessHours> mapStdBusinessHours = new Map<String, BusinessHours>();

    public static BusinessHours getBusinessHours(String countryCode){               
        
        countryCode = (String.isBlank(countryCode) ? DEFAULTBS : countryCode);
        String query,filter,condition = '';
        //cannot execute cache method from process builder flow, using isInvokedFromFlow to determine if method invoked from flow
        if(isInvokedFromFlow) {
            system.debug('##NOCACHE');
            if(countryCode == DEFAULTBS)
                condition = ' where IsDefault=true ' ;
            else{
                filter = countryCode +'-%';
                condition = ' where Name like :filter';
            }

            query = ' SELECT Id, name,IsDefault, IsActive,TimeZoneSidKey';
            query += ' , MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime';
            query += ' , WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime ';
            query += ' , FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime  ';
            query += '  FROM BusinessHours  ';
            query += condition;

            currBusinessHours = Database.query(query);

            isInvokedFromFlow = false;
        }
        else{
            system.debug('##CACHE');
            // add business hours in cache if does not already exist
            if (!Cache.Org.contains(BSCACHENAME)) 
            {
                for(BusinessHours currentBusinessHour: [SELECT  Id, Name, IsDefault, IsActive, TimeZoneSidKey, 
                                                            MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, 
                                                            WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, 
                                                            FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, 
                                                            SundayEndTime, SundayStartTime
                                                    FROM    BusinessHours
                                                    where   IsActive = true]){
                    if(currentBusinessHour.IsDefault)
                    {
                        mapStdBusinessHours.put(DEFAULTBS, currentBusinessHour);
                    }

                    String key = currentBusinessHour.Name.substringBefore('-');
                    mapStdBusinessHours.put(key, currentBusinessHour);
                }

                Cache.Org.put(BSCACHENAME, mapStdBusinessHours);
            }
            else
            {
                mapStdBusinessHours = (Map<String, BusinessHours>) Cache.Org.get(BSCACHENAME);
            }
            currBusinessHours = mapStdBusinessHours.get(countryCode);
        }

        system.debug('##currBusinessHours: '+currBusinessHours);

        return currBusinessHours;
    }

    public static Integer calculateDifferenceBetweenBusinessDateInMinutes(DateTime startDateTime, DateTime endDateTime, BusinessHours bh)
    {
        Integer durationInMinutes = (BusinessHours.diff(bh.Id, startDateTime, endDateTime) / 60 / 1000L).intValue();

        return durationInMinutes;
    }

    

    /**** request container ****/

    public class mainRequest{
        public string ClaimReference;
        public boolean AutomaticValidation;
        public string Request;
        public string AlphaScalePO;
        public Object Distributors;
        public BodyShop BodyShop;
        public Vehicle Vehicle;
        public string Message;
        public String BSReferenceNumber;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        public String InsBrokerNumber;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        public String AssessmentID;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        public String SO;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        public String Distributor;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        public String DistributorOrderNumber;//RLA 06/02/2020  C-003882 IG - Order Quality Check outside ASPIS

        public mainRequest(string ClaimReference, boolean AutomaticValidation, string Request, string AlphaScalePO, Object Distributors, BodyShop BodyShop, Vehicle Vehicle, String BSReferenceNumber, String InsBrokerNumber, String AssessmentID, String SO, String Distributor, String DistributorOrderNumber){
            this.ClaimReference                                          = ClaimReference;
            this.AutomaticValidation                                     = AutomaticValidation;
            this.Request                                                 = Request;
            this.AlphaScalePO                                            = AlphaScalePO;
            this.Distributors                                            = Distributors;
            this.BodyShop                                                = BodyShop;
            this.Vehicle                                                 = Vehicle;
            this.BSReferenceNumber = BSReferenceNumber;
            this.InsBrokerNumber = InsBrokerNumber;
            this.AssessmentID = AssessmentID;
            this.SO = SO;
            this.Distributor = Distributor;
            this.DistributorOrderNumber = DistributorOrderNumber;
        }
    }


    public class distributor{
        public string ExternalOrderReference;
        public String AgencyMode;//RLA 10/06/2020 C-003753: IG - New features for Order Call.
        public String BodyShopOrderReference;
        public String Comment;
        public Boolean Option1;//RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
        public list <Parts> Parts; 
        public string BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements


        public distributor(string ExternalOrderReference, String AgencyMode, String BodyShopOrderReference, String Comment, Boolean Option1,  list <Parts> Parts, string BSExternalReference){
            this.ExternalOrderReference = ExternalOrderReference;
            this.AgencyMode = AgencyMode;
            this.BodyShopOrderReference = BodyShopOrderReference;
            this.Comment = Comment;
            this.Option1 = Option1;
            this.Parts = Parts;
            this.BSExternalReference = BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements
            
        }
    }

    public class Parts{
        //used for request
        public decimal Quantity;
        public string AllowAlternatives;
        public string ID;
        public string PartNumber;
        public string Type;
        public string Manufacturer;
        public string Description;
        public double AlphaScalePublicPrice;//RLA 10/06/2020 C-003753:
        public double BodyshopNetPrice;//RLA 10/06/2020 C-003753:
        public double Discount;//RLA 25/08/2020 C-003882:
        public string DistributorStatus;//RLA 25/08/2020 C-003882:
        public string DistributorAction;//RLA 25/08/2020 C-003882:
        public string OldPartNumber;//RLA 25/08/2020 C-003882:
        public string OldDescription;//RLA 25/08/2020 C-003882:
        public string SequenceID;//RLA 31/10/2020 C-004018: IG - Efa requirements


        //used for response
        public double CatalogPrice;
        public double AlphaScaleDiscount;
        public double AlphaScaleDiscountAdditional;
        public double BodyShopDiscount;
        public string Status;
        public string StatusMessage;

        public Parts(decimal Quantity, string AllowAlternatives, string ID, string PartNumber, string Type, string Manufacturer, string Description, double AlphaScalePublicPrice, double BodyshopNetPrice, double Discount, String DistributorStatus, String DistributorAction,String OldPartNumber,String OldDescription,string SequenceID ){
            this.Quantity                                                = Quantity;
            this.AllowAlternatives                                       = AllowAlternatives;
            this.ID                                                      = ID;
            this.PartNumber                                              = PartNumber;
            this.Type                                                    = Type;
            this.Manufacturer                                            = Manufacturer;
            this.Description                                             = Description;
            this.AlphaScalePublicPrice  = AlphaScalePublicPrice;//RLA 10/06/2020 C-003753:
            this.BodyshopNetPrice = BodyshopNetPrice;//RLA 10/06/2020 C-003753:
            this.Discount = Discount;//RLA 10/06/2020 C-003882:
            this.DistributorStatus = DistributorStatus;//RLA 10/06/2020 C-003882:
            this.DistributorAction = DistributorAction;//RLA 10/06/2020 C-003882:
            this.OldPartNumber = OldPartNumber;//RLA 10/06/2020 C-003882:
            this.OldDescription = OldDescription;//RLA 10/06/2020 C-003882:
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            this.SequenceID                                              = SequenceID;
        }
    }

    public class BodyShop{
        public string Name;
        public string ExternalReference;
        public string VATNumber;

        public BodyShop(string Name, string ExternalReference, string VATNumber){
            this.Name                                                    = Name;
            //this.ExternalReference                                       = '12345678901234';
            //this.ExternalReference                                       = '123456789';
            this.ExternalReference                                       = ExternalReference;
            this.VATNumber                                               = VATNumber;
        }
    }

    public class Vehicle{
        public string Brand;
        public string Model;
        public string FirstRegistrationDate;
        public string PlateNumber;
        public string VinNumber;
        public string BuildDate;

        public Vehicle(string Brand, string Model, string FirstRegistrationDate, string PlateNumber, string VinNumber, string BuildDate){
            this.Brand                                                   = Brand;
            this.Model                                                   = Model;
            this.FirstRegistrationDate                                   = FirstRegistrationDate;
            this.PlateNumber                                             = PlateNumber;
            this.VinNumber                                               = VinNumber;
            this.BuildDate                                               = BuildDate;
        }
    }

    /**** response container ****/

    public class dist{
        public string ExternalOrderReference;
        public list <Lines> Lines;
    }

    public class Lines{
        public decimal Quantity;
        public string ID;
        public string PartNumber;
        public string Type;
        public string Manufacturer;
        public string Description;
        public decimal CatalogPrice;
        public decimal AlphaScaleDiscount;
        public decimal AlphaScaleDiscountAdditional;
        public decimal BodyShopDiscount;
        public string Status;
        public string StatusMessage;
        public decimal DeliveryDays;
        public boolean Bundle;
        public list <Parts> Parts;
        public list <Alternatives> Alternatives;
    }

    public class Alternatives{
        public string PartNumber;
        public string Description;
        public string Manufacturer;
        public decimal CatalogPrice;
        public decimal Quantity;
        public decimal AlphaScaleDiscount;
        public decimal AlphaScaleDiscountAdditional;
        public decimal BodyShopDiscount;
        public string Type;
        public string Status;
        public string StatusMessage;
    }
}