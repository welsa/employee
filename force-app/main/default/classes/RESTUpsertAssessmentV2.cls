/*************************************************************************************
Class Name - RESTUpsertAssessmentV2
Version - 1.0
Created Date - 09 MAY 2016
Function - Class REST to use inbound message to create/update an assessment with the related parts
in ASPIS application.


if assessmentNumber is null
    create all parts and perform substitution with best match (recommended by AS = true)

else
    get all parts and substitutes using assessmentId 
    loop on parts received in Json
    if part contains no alphascaleMRID ==> original part
        if parts exists
            send original part (SelectedbyBS = true) and related substitutes (SelectedbyBS = false)
        else
            create new part and perform substitution with best match (recommended by AS = true)
        end if
    else ==> substitute part
        if substitute part exists
            send original part (SelectedbyBS = false), substitute part (SelectedbyBS = true) and other substitutes (SelectedbyBS = false)
        else
            send error message 'this susbtitute does not exist'
        end if
end if

Modification Log :
-----------------------------------------------------------------------------  
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S      09/05/2016     Original Version
* Dourga U       11/08/2016     MasterRule substitution
* Ashutosh B     22/09/2016     C-001728: Added the new function of create attachment
* Ashwina S      27/09/2016     replace countryCode by userRolePrefix
* Ashwina S      28/09/2016     retrieve carOrigin by splitting Name.
* Ashwina S      17/11/2016     C-001803 : Assessment Public Identifier
* Ashwina S      09/12/2016     bug when having similar substitutes
* Ashwina S      30/01/2017     If shoppingList = true && AssessmentNumber ==null, 
                                - create Assessment with Name, Assessment Number, AssessmentId = BodyShop Ref + Timestamp
                                - Type  = claim, check IsShoppingList, No Substitution, Do not check SendingAccepted__c
                                Else If shoppingList = true && AssessmentNumber !=null, ignore assessment but generate response OK
* Ashwina S      01/03/2017     split description of substitute : take original description to search in Salesforce
* Ashwina S      XX/03/2017     - when part has no substitutes, set SelectedByBS__c to true.
                                - if no substitutes are recieved for assessment, HasBeenSubstituted__c on assessment= false
                                - isEligibleSubstitution on BS is false, do not perform substitution
* Ashwina S      13/03/2017     No substitution if brand is found in CarBrandExcluded__c
* Ashwina S      05/04/17       C-001825 : call restPostAssessment
* Ashwina S      15/06/2017     C-001937 :  
* Abdool M       06/07/2017     Adding warning message exception handling (C-001969)
* Abdool M       12/07/2017     Duplicate handling (C-001969)
* Abdool M       13/07/2017     Crash code handling (C-001969)
* Abdool M       17/07/2017     Commenting crash genereation record code (C-001969)
* Abdool M       19/07/2017     New External Id being sent in ass request
* Abdool M       20/07/2017     C-001934 : Upsert Evolution to add margins on original parts
* Abdool M       25/07/2017     C-001927 - upsertAssessent add External ID
* Ashwina S      24/08/2017     C-002016 - RunSubstitution & UpsertAssessment substitution : verify IAM part description
* Abdool M       04/10/2017     C-001969 - Evolutions of upsertAssessment - crash management
* Abdool M       25/10/2017     C-002041 - Distributor V2 - prevent eligibilty and sourcing from running from trigger
* Abdool M       26/10/2017     C-002041 - Distributor V2 - integrating call out before any dml (updating method so that call out
*                                                         - callout can be effected before DML)
* Abdool M       07/11/2017     C-002041 - Distributor V2 - WS Integration 
* Ashwina S      07/11/2017     C-002070 - UpsertAssessment - OEM Discount / Margin missing when doing an update
* Dourga U       07/11/2017     C-001994 - add parameters in runValidation Method
* Abdool M       08/11/2017     C-002041 - Distributor V2 - inserting log after callout effected
* Abdool M       09/11/2017     C-002041 - Distributor V2 - bulkifying distributor callout
* Abdool M       10/11/2017     C-002041 - Distributor V2 - processing response and updating parts
* Abdool M       13/11/2017     C-002041 - Distributor V2 - response generation after upsert operation
*                                                         - cater for parts created due to distributor callout 
* Ashwina S      13/11/2017     C-001988 - Expert assessments part list are not selected
* Abdool M       16/11/2017     C-002041 - Distributor V2 - update log based on distributor callout status
* Ashwina S      17/11/2017     C-002078 - ICE - Compensation new filed in upsertAssessment
* Abdool M       20/11/2017     C-002041 - Distributor V2 - pricing (best price + isSelectedByBS,RecommendedByBS)
* Abdool M       08/12/2017     C-002041 - Distributor V2 - changing Alpha_Scale_MRID__c for ASP parts
* Abdool M       13/12/2017     C-002041 - Distributor V2 - Adding Discount and margin to A' Parts
* Abdool M       18/12/2017     C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
* Abdool M       20/12/2017     C-002041 - Distributor V2 - updating map used to generate response for substitutes parts
* Abdool M       19/01/2018     C-002041 - Distributor V2 - Removing update on status and previous status so as not to relaunch 
*                                                         - sourcing in setCrossReferencesFieldForAssessment method
* Abdool M       24/01/2018     C-002041 - Distributor V2 - A' Creation Criteria 
* Ashwina S      24/01/2018     C-002185 - AssessmentNumber must not be updated if Claim number change
* Abdool M       25/01/2018     C-002041 - Distributor V2 - Do not update price on original during A' Creation    
* Abdool M       25/01/2018     C-002041 - Distributor V2 - Do not send ASCR to distributor if no distributor price present 
* Abdool M       25/01/2018     C-002195 - Audatex Integration
* Abdool M       26/01/2018     C-002189 - Informex Integration
* Abdool M       02/02/2018     C-002041 - Distributor V2 - Adding confirmedWithDelay as A' Creation Criteria
* Abdool M       02/02/2018     C-002041 - Distributor V2 - Updating A' Description
* Abdool M       02/02/2018     C-002041 - Distributor V2 - Prevent Creation of cross ref parts if price is greater than original
* Abdool M       05/02/2018     Updated Code Documentation
* Abdool M       06/02/2018     C-002041 - Distributor V2 - Do not update cross ref field on assessment since catered in new field (MRSourcing)
* Abdool M       08/02/2018     C-002195 - Audatex Integration - ExternalId Integration
* Abdool M       12/02/2018     C-002041 - Distributor V2 - ConnectedEndtoEnd__c
*                                        - Check if distributor callout is allowed in upsert
* Abdool M       12/02/2018     C-002041 - Distributor V2 - Update std discount and margin during A' Creation
* Abdool M       14/02/2018     C-002041 - Distributor V2 - adding cleanse reference key to techoriginalpart since if asp was selected in second call, 
*                                                         - isSelected checkbox was not updated  
* Abdool M       14/02/2018     C-002041 - Distributor V2 - updating key for subs to track parts transmitted in second call
*                                                         - ASCR and ASP should be in same format except MRID will be different
* Abdool M       15/02/2018     C-002041 - Distributor V2 - Setting Cross Reference field to none since query for master
                                                          - rule resulted in error during sourcing   
                                                          - (CrossReference__r.Name IN ('') AND DistributorID__r.DistributorRegionsCovered__c INCLUDES ('12') AND Active__c = TRUE) 
* Abdool M       15/02/2018     C-002041 - Distributor V2 - Removing 'ASP' in part number 
* Abdool M       19/02/2018     C-002041 - Distributor V2 - Sending Certifying Org in Return JSON for ASP Parts
* Abdool M       20/02/2018     C-002041 - Distributor V2 - New pricing algo called externally
* Abdool M       22/02/2018     C-002041 - Distributor V2 - Adding eligibilty process for all countries except france
* Abdool M       22/02/2018     C-002041 - Distributor V2 - Adding missing field to ASP Response
* ABdool M       28/02/2018     C-002041 - Distributor V2 - Sending Certifying Org in Return JSON for ASP Parts (for successive call)
* Abdool M       28/02/2018     C-002041 - Distributor V2 - Temporarily bypassing v2 methods for all countries
* Abdool M       01/03/2018     C-002041 - Distributor V2 - Update Crossref field on assessment with those selected
* Ashwina S      01/03/2018     C-002311 - Substitution expert - lien expert
* Ruksaar L      06/03/2018     C-002357 - roll up converted into Text field
* Ruksaar L      04/03/2018     C-002370 - DISTRIBUTOR V2 : add Eligibility in Distributor V2 process.
* Ashwina S      19/03/2018     C-002381
* Ruksaar L      26/03/18       C-002177: Corrections/evolutions sur les logs
* Dourga U       09/04/2018     C-002418: Bypass Order Choose Assessment 
* Ashwina S      13/04/2018     C-002370 - both asp and ascr are checked.
* Ashwina S      17/04/2018     C-002477: ASP- Prefix
* Ruksaar L      23/04/2018     C-002498: There is a need to be able to query Stock on Distributor connected for Expert
* Dourga U       23/04/2018     C-002482 : VAT on Invoice lines
* Ruksaar L      24/04/2018     C-002502 - 2nd Upsert for Audatex
* Ashwina S      23/04/2018     stock
* Ruksaar L      26/04/2018     C-002515 - Expert for Audatex
* Ruksaar L      02/05/2018     C-002443: Status of ICE on Assessment
* Ashwina S      07/05/2018     Rework response EIP
* Ashwina S      07/05/2018     C-002528 - ASP for Coler Distributor
* Ashwina S      08/05/2018     C-002278 - FR - New Distributor PSA
* Ashwina S      28/05/2018     changes in calculations
* Dourga         29/05/2018     C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
* Ruksaar L      18/06/2018     C-002602 : Pas d'ASP si la marque est en Agency Mode
* Ashwina S      26/06/2018     no call made if BS.DistributorConnected= false
* Ruksaar L      18/06/2018     C-002602 Pas d'ASP si la marque est en Agency Mode 
* Ashwina S      27/09/2018     cater mrSourcing for existing substitutes
* Ashwina S      27/09/2018     C-002600: Define bodyshop / expert granular level substitution rules 
* Welsa C        30/08/2018     C-002754 - PO with no parts created and assigned to distributor
* Ruksaar L      04/10/2018     C-002818: Substitution sur des manual parts
* Ruksaar L      08/11/2018     Case: C-002898 Sourcing de pièces non sélectionnées lors d'un update de l'assessment
* Ruksaar L      08/11/2018     C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing 
                                rule priority 1 is displayed in addition of the rule priority 0
* Welsa C        20/11/2018     C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
* Ruksaar L      20/11/2018     C-002782 CJP A'
* Ashwina S      17/01/2019     C-002968:  ASP to be generated for Brands in Agency Mode in DE
* Welsa C        02/04/2019     C-003155 : SASV2; Call to SAS for B parts during Substitution
* Ruksaar L      08/04/2019     C-003148: SAS V2 : non conservation de l'information du "recommended by AS" aprÃ¨s modification de sÃ©lection dans la matrice de substitution
* RUksaar L      15/04/2019     C-003187 : stock d'une ASCR dont le distributeur n'est pas connectÃƒÂ©
* Ruksaar L      04/04/2019     C-003133 : Direct Sourcing not done when creating assessment from scratch & for R4 ASP not taken into consideration 
* Ashwina S      27/09/2018     C-002692: Substitution on BE assessments
* Ruksaar L      06/09/2018     C-002692 : Substitution on BE assessments
* Ruksaar L      12/07/2018     C-002234 : BE - Informex Target LOT 2
* Welsa C        02/04/2019     C-003155 : SASV2; Call to SAS for B parts during Substitution
* Ruksaar L      04/04/2019     C-003133 : Direct Sourcing not done when creating assessment from scratch & for R4 ASP not taken into consideration 
* Ruksaar L      08/04/2019     C-003148: SAS V2 : non conservation de l'information du "recommended by AS" aprÃƒÂ¨s modification de sÃƒÂ©lection dans la matrice de substitution
* RUksaar L      15/04/2019     C-003187 : stock d'une ASCR dont le distributeur n'est pas connectÃƒÆ’Ã‚Â©
* Ruksaar L      09/04/2019     C-003099: Manage duplication in ASPIS when new version is created in Audatex
* RUksaar L      15/04/2019     C-003187 : stock d'une ASCR dont le distributeur n'est pas connecté
* Ruksaar L      03/06/2019     C-003143 : Preseletion de la pièce E pour la France 
* Ruksaar L      03/06/2019     C-003180:  Preselection de l'ASCR pour la Substitution belge
* Ruksaar L      10/06/2019     C-003260- UpsertAssessment to send back 'recommendedbyAS' information
* Ruksaar L      04/07/2019     C-003171: Flag Orders generated from Assessment Tool  
* Welsa C        22/07/2019     C-003354: Bodyshop activated in Pilot Direct Sourcing not able to order from estimates with ASP Parts
* Ruksaar L      30/07/2019     C-003344: Substitutes manual Parts for Italy
* Welsa C        12/09/2019     C-003387 : Assessment is rejected even if B Parts are suppliable
* Welsa C        18/09/2019     C-003391 : Error in Assessment when BS tries to source E Parts
* Ruksaar L      14/08/2019     C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
* Ruksaar L      10/10/2019     C-003418 : NENA : bug with parent assessment
* Ruksaar L      10/10/2019     C-003421: NENA KO sur une nouvelle pièce sur 2ieme appel Expert 
* Welsa C        25/11/2019     C-003490 - Wrong reason failure when the assessment is not eligible 
* Ruksaar L      10/12/2019     C-003534 : Assessments for BS not eligible for substitution has A' substituted parts
* Ruksaar L      08/01/2019     C-003513: B parts without distributor should not be proposed 
* Ruksaar L      14/01/2019     C-003492: SAS B parts with status PARTIAL should not be proposed 
* Ruksaar L      28/01/2019     C-003524 : Change Recommended part in France
* Ruksaar L      04/03/2020     C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
* Ruksaar L      03/09/2020     C-003621: Proposed Expert Assessment selection of partlists is not okay
* Ruksaar L      20/03/2020     C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
* Ruksaar L       12/06/2020    C-003754: IG - Update Query Call for Coler
* Welsa C         14/07/2020    C-003860: When FR Assessment not rejected
* Ruksaar L       04/08/2020    C-003881: A' par distributeur
* Ruksaar L       12/07/2020    C-003857: IG - Creation IGO 
* Ruksaar L       10/08/2020    C-003738: Recommend C part Bodyshop by Bodyshop
* Welsa C         17/08/2020    C-003578: Expert Assessment KO when claim reference does not meet required conditions
* Welsa C         18/08/2020    C-003864 - 2020 Connectivity changes for EIP
* Welsa C         24/08/2020    C-003906: Claims without any available A parts, but with available alternate spare parts are rejected
* Ruksaar L       10/08/2020    C-003738: Recommend C part Bodyshop by Bodyshop
* Welsa C         24/08/2020    C-003838: Nob - Migrate Billing information to new fields
* Welsa C         12/11/2020    C-003980: NOB - Compensated Invoices
* Ruksaar L       12/11/2020    C-004036: :Activate C part recommendation bodyshop by Bodyshop for Belgium
* Ruksaar L       18/11/2020    C-004030: From createAssessment to upsertAssessment
* Ruksaar L       12/11/2020    C-003879: Add field Partlist.PositionID
* Ruksaar L       17/12/2020    C-004118: 	Remove the cleansing for the account reference for Italy
* Ruksaar L       20/01/2020    C-004100: FR - Source Expert Assessment as Bodyshop 
* Ruksaar L       01/03/2021    C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY 
* Ruksaar L       23/03/2021    C-004102: FR - Aniel Distributor Integration 
* Welsa C         16/04/2021    C-004322: FR - Source Expert Assessment as Bodyshop bug 
* Ruksaar L       23/05/2021    C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
* Ruksaar L       16/08/2021    C-004408: PostNevada sends duplicate fields
* Hootesh R       13/10/2021    C-004405 : No Ordering on Fake References* Hootesh R      22/11/2021     C-004530: Substitution pour italy par rapport a l'age et la marque
* Neha P          14/12/2021    C-004540: Delete records of R3 Assessments and Part Lists created for BS's in Direct Ordering Process
* Neha  P         10/02/2022    C-004587: Send default value on PO's First Registration Date field for OrderMakeSelection calls to SAS if value is NULL                                                                                                                
* Hootesh R      21/02/2022     C-004530: Substitution pour italy par rapport a l'age et la marque
* Neha P          06/04/2022    C-004683 Call to Nevada fall in Mulesoft         
* Neha P          08/04/2022    C-004633 Post Nevada: remove filter based on AXAPartner__c  
* Ruksaar L       15/12/2021    C-004569: Substitution H 
* Hootesh R       13/10/2021    C-004405 : No Ordering on Fake References
* Ruksaar L       19/01/2022    C-004449: Algo Substitution Albax
* Welsa C         19/05/2022    C-004713 : When partlabel is empty , fill in with default value
* Rojo L          03/11/2022    C-004835 : Optimisation du RestUpsert-V2
* Kaviraj E       10/01/2023    C-004874 : PREv2 Connected - Lot 2 - Substitution
*************************************************************************************/
@RestResource(urlMapping='/v2.0/upsertAssessment/*')
global with sharing class RESTUpsertAssessmentV2 {    
    // static variables
    
    static Map<String, Id> recordTypePartTypeMap        = new Map<String, Id>();
    static Map<String, Id> recordTypeAssessTypeMap      = new Map<String, Id>();
    // map<error string, error string>
    static Map<String, String> mapErrorsCreation;
    //AMI 06/07/2017 - Adding warning message exception handling
    static Map<String, String> mapWarningCreation;
    //map<assessId, AccountRef__c> to get AccountRef__c custom setting values 
    static Map<String, AccountRef__c> assessAccountRefMap;
    //map<assessId, brand sent in response; car destination for callerId; car destination for CATALOG>
    static Map<String, String> assessCarMap;
    //map<AssessmentId, list<Parts from Json requiring substitution>>
    static Map<String, list<Object>> newOriginalMap;
    //build map <AssessmentId, entityCode>
    static Map<String, String> assessIDEntityCodeMap;
    // map<AssessmentId, valid assessments from json>
    static Map<String, Map<String, Object>> allValidAssessMap; 
    //map <BSId, BS>
    static Map<Id, Account> bsRefAccountMap ; 
    // ase: 05/12/17 : lien BS evol 
    static set<id> expertAccSet; 
    //map <AssessmentId, map<pl.TECH_OriginalPart__c, pl>> 
    static map<String, Partlist__c> originalPartsMap ;
    //map <AssessmentId, map<pl.TECH_OriginalPart__c, map<Substitute.TECH_OriginalPart__c, Substitute >>> 
    static map<String,list<Partlist__c>> originalSubstitutesMap = new map<String,list<Partlist__c>>(); 
    //map<assessId-substitute.alphascaleMRID, original.TechOriginalPart>
     static map<String, set<String>> allAssessSubOriginalMap = new map<String, set<String>>();
    //map<assessId-substitute, partList>
    static map<String, Object> assessSubstituteMap = new map<String, Object>();  
    //map<assessId-substitute, partList>
    //static map<String, Object> assessSubstituteMapWithDesc = new map<String, Object>(); 
    static String urlLink = URL.getSalesforceBaseUrl().toExternalForm();
    //map<AssessId-originalPart.TECH_OriginalPart__c, list<substitute>>
    static Map<String, List<PartList__c>> asessPartSubMap;
    //DUN 12/09/2016 MasterRule Update
    static Map<String, Set<String>> mapEntitysetPartListTechId = new Map<String, Set<String>>();
    // ASE 13/04/2018 
    static set<String> ascrNonSelectedSet = new set<String>();
    // role prefix of connectedUser
    static String userRolePrefix;
    //map<crashSubstitute.TECH_OriginalPart__c, claimSubstitute.TECH_OriginalPart__c>
    static Map<String, String> cloneSubstituteMap = new Map<String, String>();
    //map<AssessmentId, isEligibleSubstitution>
    static Map<String, String> isEligibleMap = new Map<String, String>();
    static set<String> assessTimestampSet = new set<String>(); 
    static Map<String, String> shoppingListAssessIDMap = new Map<String, String>();
    static Map<String, Id> assessSFDCIDMap = new Map<String, Id>();
    //map<AlphaScaleMrid -IAM partNUmber>
    static Map<String, String> ASCRPartNumbMap = new Map<String, String>();
    static set<String> shoppingListExistAssessFound = new set<String>(); 
    static set<String> partsToDelSet = new set<String>();
    static map<String, Partlist__c> allSubPartsMap ;
    static set<String> allOriSubPartsSet = new set<String>();    
    static map<String, set<String>> assessBSCategoriesMap = new map<String, set<String>>();
    static Set<String> igEntitySet = String.isBlank(Label.ASFRIGEntity) ? new Set<String>() : new Set<String>(Label.ASFRIGEntity.split(';'));
    static map<String, String> crashOriClaimOriMap = new map<String, String>(); 

    //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
    static map <string,CrossReference__c> mapPartNumCrossRef = new map <string,CrossReference__c>();
    static map<String, set<String>> expertOriginalPartsMap= new map<String, set<String>>();
    static map<Id, set<String>> crossRefMap = new map<Id, set<String>>(); 
     // ase: 05/12/17 : lien BS evol 
    static set<String> setClaim = new set<String>();
    static set<String> setPlate = new set<String>();
    static map<String, Id> claimPlateBSRefMap = new map<String, Id>(); 
    static map<Id, String> claimPlateCarBrandExcludedMap = new map<Id, String>(); 
    global static String expertSubstitutionMethod;
    static Boolean isExpert = false;
    // ASE : 26/06/2018- C-002651: no call made if BS.DistributorConnected= false    
    static Boolean BSConnected = false;
    // ASE: C-002692 : 27/09/2018
    static String BSLang = null;
    
    //AMI 13/11/17 - C-002041 - Distributor V2 - response generation after upsert operation
    //                                         - cater for parts created due to distributor callout
    //                                         - map <techoriginalkey,list <parts>>
    //                                         - this map will be used to during response writing back for caller system
    static map <string,list <Partlist__c>> mapSubsPartCreatedByDistCallout = new map <string,list <Partlist__c>>();

    //AMI 13/11/17 - C-002041 - Distributor V2 - response generation after upsert operation
    //                                         - cater for parts created due to distributor callout
    //                                         - this set will used to hold key of each substitute created due to dist call out
    //                                         - will be check against upserted partlist so that only upserted ones are taken into
    //                                         - consideration when writing response
    static set <string> setSubsCreatedByDistCallout = new set <string>();

    //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
    //                                           - this datetime field is used to know lasttime callout to distributor
    //                                           - was effected
    static datetime lastCallOut = null;

    //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
    //                                           - this string field is used to hold any error encountered
    //                                           - lasttime callout to distributor was effected
    static string distErrorMsg = '';

    //AMI 20/11/17 - C-002041 - Distributor V2 - this map will be used to get price info on original during pricing calculation
    //                                         - this map contains the techoriginalkey and corresponsding Partlist
    static map <string,PartList__c> mapOriginalTechOriginalPartPartlist = new map <string,PartList__c>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this map will be used to get price info on substitute during pricing calculation
    //                                         - this map contains the techoriginalkey and corresponsding Partlist
    static map <string,PartList__c> mapSubstituteTechOriginalPartPartlist = new map <string,PartList__c>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this map will contains original key with associated substitute key
    //                                         - used to calculate min price
    //                                         - will contains subs generated from cross ref and from distributor callout
    //                                         - note that this map will always contain as first value the original part
    //                                         - this will cater for originals having no subs at all
    static map <string,set <string>> mapOriginalTechOriginalPartSetSubsTechOriginalPart = new map <string,set <string>>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this map will contains updated selectedByBS and RecommendedByBS checkbox
    static map <string,PartList__c> mapUpdatedPartsBooleanCheck = new map <string,PartList__c>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this set contains all original already present where pricing should not be run
    //                                         - it will contains only original key with or without substitute
    static set <string> setExistingTechOriginalPart = new set <string>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this set contains all techoriginalparts of parts already present 
    //                                         - it will contain both original and subs
    //                                         - this will be used to check selectedbybs in case parts are being sent a second time 
    //                                         - and it already exists
    static set <string> setExistingParts = new set <string>();

    //AMI 20/11/17 - C-002041 - Distributor V2 - this set contains all tech original part that is transmitted
    //                                         - used to set boolean check for pricing 
    //                                         - populated only for second and ongoing call made from caller system
    static set <string> setTransmittedTechOriginalPart = new set <string>();

    //AMI 20/12/17 - C-002041 - Distributor V2 - updating map used to generate response for substitutes parts
    //                                         - this map will be used to generate response for substitutes parts
    //                                         - will be build after all substitute parts are updated
    static map <string,PartList__c> mapSubsKeySubForRespGeneration = new map <string,PartList__c>();

    //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
    //                        - this map will hold info for distributor rebate info
    static map <string,Account> mapEligiblePONameELigiblePO = new map <string,Account>();

    //AMI 25/01/18 : C-002195 - Audatex Integration
    //                        - Creating new variable to store the "NBWrkingUnit" received in the currentClaim section 
    static string NBWrkingUnit = '';

    //AMI 25/01/18 : C-002195 - Audatex Integration
    //                        - this map will save field send through json but nor saved in database so that
    //                        - same can be returned in response json
    static map <string,audatexUnSavedFields> mapTechOriginalPartKeyAudatexUnsavedFld = new map <string,audatexUnSavedFields>();

    //AMI 22/02/2018 : C-002041 - Distributor V2 - Adding eligibilty process for all countries except france
    //                          - declare variable that will store country
    //                          - this will determine whether or not to bypass eligibility
    static string assCountry = '';

    //RLA 22/02/2018: C-002195  - Audatex Integration
    //                          - Boolean which will determine if the json contains 'AssessmentExternalID'
    static boolean isAssExtIdTransmitted ;

    //ASE 19/03/2018: si l'account expert IT forced, assessment expert= forced
    static Boolean accountForced = false;

    //RLA 06/03/18 : C-002357 
    //                        - This map is used to get keep the number of parts for each assessment
    //                        - 
    static map <string, Integer> mapNumberPartsCorrespondingAssId = new map <string, Integer>();

    //RLA 27/03/2018 - C-002271:  Corrections/evolutions sur les log
    //                            - this string field is used to hold assessment Name
    //                                           
    static string assessmentName = '';
    static string assessmentId = '';

    //RLA 30/03/18 : C-002370 
    //                        - This map is used to get keep the eligibility results for each Assessment
    //                        - 
    static map <string, Boolean> mapAssessmentEligibility = new map <string, Boolean>();

   //RLA 02/04/17 : C-002370 Distributor V2 add Eligibility 
    //              : Run eligibility before substitution
    static private ASPISServiceEligibility.isEligibleWrapper eligibleWrap;
     //RLA 11/04/2018 - C-002271:  Corrections/evolutions sur les log        
    //                            - this string field is used to hold assessment Name  
    static private string systemCallingAss = '';                                                      
    static private String wsRequestCallout = '';        
    static private String wSResponseCallout = '';

    // ASE: 23/04/18
    static map<String, String> ASCRStockMap = new map<String, String>();
    
    //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
    static map<String,CountryCodeInformationsMapping__c> mapConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

    // ASE: 08/05/18: C-002278 
    static set<String> DistributorIdSet = new set<String>();

    // ASE: 21/05/2018 : C-002278 
    static map<String, set<String>> typeDistMap = new map<String, set<String>>();
    // static Id SASId;
    // static Id PSAId;
    static Id distRecordTypeId;

    // RLA: 18/06/2018 : C-002602 Pas d'ASP si la marque est en Agency Mode 
    static Boolean canCreateAsp = true;

    // RLA: 12/07/2018 : C-002234 : BE - Informex Target LOT 2 - In Progress 
    static Boolean isInformex = false;
    static Boolean isInformexExpertSucessful = false;
    static Assessment__c BSAssessment;
    static set<String> OEMNoATypeSet = new set<String>();
    //ASE C-002600
    static Boolean isBSForcedNoA = false;
    static Boolean isBSForced = false;  
    //RLA 19/01/2022 C-004449: Algo Substitution Albax
    static Boolean isBSForcedAlbax = false;

    static Boolean carBrandExcluded = false;
    static Boolean isForcedNoA = false;
    //RLA 19/01/2022 C-004449: Algo Substitution Albax
    static Boolean isForcedAlbax = false;
    static Boolean hasSubstitution = false;

    //RLA 11/12/2018 cjp
    static Boolean isProposed = false;
    static Decimal bsDiscount;
    static Decimal bsMargin;

    //WCH 30/08/2018 :C-002754 list of assessment to update after updating partlist is selected by BS(field MRSourcing__c)
    static Map<Id,Assessment__c> theAssesToUpdate;

    static set<String> OEMCRAPrimeExcludedSet = new set<String>();

    //RLA 06/09/2018 C-002692 : Substitution on BE assessments
    static map<string,string> mapOrigineValues = getMapTranslatedCertOrg();
    static boolean isCountryEs = false;

    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - This map is used to get all parts related to assessment to construct JSON to send to any given 
    //                        - connected distributor
    static map <string, list <PartList__c>> mapAssessIDListParts = new map <string, list <PartList__c>>();
    //ASE 21/12/18: C-002985 -  No Virtual A' on fake references
    static map <string, list <PartList__c>> VirtualAAssessListPartMap = new map <string, list <PartList__c>>();
    
    //RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex 
    static boolean isESAudatex = false;

    //RLA 03/06/2019 C-003143 : Preseletion de la pièce E pour la France 
    //MAP keeping the set of ASCR for each OEM
    static map <string,List <PartList__c>> mapOriginalTechOriginalPartSetSubsPartEs = new map <string,List <PartList__c>>();
    // A map that stores the OEMKEY and its related list of ASCR keys generated
    static map<string,string> mapOEMASCRSE = new map <String, String>();
    //A map of tech original part OEM and its partlist
    static map<String,Partlist__c> mapTechOriOem = new map<String,Partlist__c>();
    //a map of techOriginalPart and oem Manufacturer
    static map <string, string> mapTechOriOemManu = new map <String,String>();
    //RLA 30/07/2019 C-003344: Substitutes manual Parts for Italy
    static boolean isManualPartsAllowedforSubs = false;
    //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
    static boolean isAPrefixAllowedforSubs = false;
    //RLA  03/06/2019     C-003143 : Preseletion de la pièce E pour la France 
    static string enCode = '';

    //RLA 01/10/2019 debug NENA
    global static String traceVariables = '';
    
    //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
    static boolean isBsOrExpertLinkedAss = false;


    //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
    // static Map<String,List<String>> mapPartTypesStatusAllowed = new map<String, List<String>>();
    //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
    static Map<String, Map<String,List<String>>> mapDistPartTypesStatusAllowed = new map<String, map<String, List<String>>>();
    static map<String, String> ASCRStatusMap = new map<String, String>();
    //map containing the techoriginal part of the ASCR and its corresponding OEM
    static map<String,String> mapTechOriASCROEM = new map<String,String>();
    //map containing oem and all its ASCR
    static map <string,List <PartList__c>> mapOriginalTechOriginalPartSetSubsAllPart = new map <string,List <PartList__c>>();


    //RLA 28/01/2020 C-003524 : Change Recommended part in France  
    //map which contains the partType and its priority derived from masterRule
    static map<String,Integer> mapPartTypePriority = new map<String,Integer>();

    //RLA 28/02/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
    static map<String, map<string,String>> mapOEMKeyTechOri = new map<String, map<string,String>>();
    static Map<String, List<String>> newPartDescMapGlo    = new Map<String, List<String>>();
    static Map<String, PartList__c> newPartMapGlo         = new Map<String, PartList__c>();

    //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
    static String callersystemGlo = '';

    //RLA 09/04/2020 C-003694: IG - Substitution
    static String substitutionType;
    static boolean isIG = false;
    static String capturedDistributorsGlo ;

    //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
    static map<String, String> mapDistPrioConnected = new map <String, String>();
    static set <string> setAlreadyOrderedParts = new set <string>();

     //RLA 09/07/2020 C-003857: IG - Creation IGO 
    static String insuranceBroker;
    static map<String, String> mapOEMIdConnectedOemID = new map<String, String>();

    //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
    static String preferredType = '';

    //RLA 09/10/2020
    // C-003948 - Modifier l'adresse renvoyée dans l'upsert
    static string bodyshopId;
    
    //RLA 19/10/2020 C-004030: From createAssessment to upsertAssessment
    static Boolean isFromR3 = false;
    
    //RLA 17/12/2020 C-004118: 	Remove the cleansing for the account reference for Italy
    static String country; 

    //RLA 12/01/1010 C-004140: Time tracing of processes on restupsert
    static Decimal time1;
    static Decimal time2;
    static Decimal time3;
    static Decimal time4;
    static Decimal time5;
    static Decimal time6;
    static Decimal time7;
    static Decimal time8;
    static Decimal time9;
    static Decimal time10;
    //RRJ C-004835 03/11/2022
    static Decimal time11;
    static Decimal time12;
    static Decimal time13;
    static Decimal time14;
    static Decimal time15;
    static Decimal time16;
    static Decimal time17;

    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
    static global Account bodyshopToReplace;
    static string accRefNumberExpert;

    //RLA 01/03/2021 C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY
    static Boolean isEligibleToOrder = false; 
    
    //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
    static Boolean isNonAxa = false;
    static map<String, set<String>> nonAxaOriginalPartsMap= new map<String, set<String>>();
    static Boolean isSubsAllowed = true;
    
    //RLA C-004102: FR - Aniel Distributor Integration 
    static set<Id> setDistPriceIds = new set<Id>();

    //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
    static Map<String,String> mapXrefNameTechDis = new map<String, String>();

    //HRM 12/10/2021 C-004405 : No Ordering on Fake References
    static set<String> setFakeReferences = new set<String>();

    //NPE 14/12/2021: C-004540
    static String newAssessmentR3 = '';

    //RLA Substitution H 16/12/2021
    static Boolean isPilotBdg = false;

    //KEM 09/04/2020 C-004874
    static set<Id> SetOccurenceDistributor = new set<Id>();
    static map<Id, List<String>> mapXrefDisName = new map<Id, List<String>>();
    static map<Id, List<String>> mapXrefIdLstDistId = new map<Id, List<String>>();
    static map<Id, Set<String>> mapXrefIdLstOccDistId = new map<Id, Set<String>>();
    static map<Id, List<Occurence__c>> mapXrefIdLstOccurence = new map<Id, List<Occurence__c>>();
    static map<Id, Account> mapdistToDisFields = new map<Id, Account>();
    static map<Id, Account> piecXRefDistributor = new map<Id, Account>();
    static map<Id, CrossReference__c> mapXrefIdtoXref = new map<Id, CrossReference__c>();
    static map<Id, String> mapPartIdtoDisRef = new map<Id, String>();
    static String xRefCountryCode ;
    static boolean generateConnectedXrefForCountry = false ;
    static boolean isPartEConnected = false ;
    static Set<String> connectedELineIds = new Set<String>();

    
    /**
    * @description upsertAssessment
    * @return [description]
    */
    @HttpPost
    global static void upsertAssessment() {
        datetime qryStart = datetime.now();
        system.debug('@@@ qryStart: '+qryStart);
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - upsertAssessment ----------------------------------');
        
        // variables
        String jsonResponse= ''; 

        User intUser = [select UserRole.NAme from User where id =: UserInfo.getUserId()];
        userRolePrefix =  (intUser.UserRole != null  && intUser.UserRole.Name != null) ? intUser.UserRole.Name.left(2) : '';

        //build Mapto store recordtype for sobject PartList__c
        for(RecordType r : [SELECT  SobjectType, Id, DeveloperName 
                            FROM    RecordType 
                            WHERE   SobjectType =: Label.SOBJECTPARTLIST or SobjectType =: Label.SOBJECTASSESSMENT or SobjectType =: ASPISConstants.SOBJECT_ACCOUNT]){
            if(r.SobjectType == Label.SOBJECTPARTLIST){
                recordTypePartTypeMap.put(r.DeveloperName, r.Id);
            }
            else if(r.SobjectType == Label.SOBJECTASSESSMENT){
                recordTypeAssessTypeMap.put(r.DeveloperName, r.Id);
            }

            else if(r.SobjectType == ASPISConstants.SOBJECT_ACCOUNT && r.DeveloperName == ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor){
                distRecordTypeId = r.Id; 
            }
        }

        //Commented by RLA 25/01/2021
        // List<account> lstAccSAS = [select Id, Tech_Distributor__c, Feature__c from Account where (Feature__c = 'PilotPSA' or Tech_Distributor__c =: System.Label.AdditionalPartDistributor) and RecordtypeId =: distRecordTypeId];
        // if (lstAccSAS.size() > 0){
        //     for(Account acc: lstAccSAS){
        //         if(acc.Tech_Distributor__c == System.Label.AdditionalPartDistributor){
        //             SASId = acc.Id;   
        //         }
        //         if(acc.Feature__c == 'PilotPSA'){
        //             PSAId =  acc.Id;   
        //         }                
        //     }             
        // }
        //SASId = [select Id from Account where Tech_Distributor__c =: System.Label.AdditionalPartDistributor].Id; commented by RLA



        // deserialise response
        //convert the requestbodyv into a String
        String body = RestContext.request.requestBody.toString();
    
        
        if(body != null && body != ''){
            // call deserialiseResponse method
            jsonResponse = deserialiseResponse(body);

             String status = '';
                

            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            wrapperLog.className = 'RESTUpsertAssessmentV2';
            wrapperLog.objectreference = assessmentName;
            wrapperLog.sobjectid = assessmentId;
            wrapperLog.jsonmessage = body != null && body.length() <= 30000 ? body : '';
            wrapperLog.sobjectName = 'Assessment__c';
            wrapperLog.jsonresponse = jsonResponse != null && jsonResponse.length() <= 30000 ? jsonResponse : '';
            wrapperLog.wsdate = lastCallOut;
            wrapperLog.wserrormessage = distErrorMsg;
            wrapperLog.inout = 'Inbound;Outbound';
            wrapperLog.systemcalling = systemCallingAss;
            wrapperLog.wsRequest = wsRequestCallout;
            wrapperLog.wSResponse = wSResponseCallout;
            wrapperLog.TraceVariablesNena = traceVariables;

            if(jsonResponse.contains('Exceptions') || (jsonResponse.contains('Error') && !jsonResponse.contains('"ErrorMessage":null'))){
                wrapperLog.status = Label.STATUSFAILED;
            }
            else{
                wrapperLog.status = Label.STATUSPASSED;
            }  

            if(body.length() > 30000){
                wrapperLog.attachmentRequestbody = body;
            }

            if(jsonResponse.length() > 30000){
                wrapperLog.attachmentResponsebody = jsonResponse;
            }  
            datetime qryEnd = datetime.now();
            Decimal heapsize2 = Limits.getHeapSize() ;
            system.debug('@@@ heapsize End: '+heapsize2);

            decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
            tempExec = (tempExec.divide(1000, 5));


            wrapperLog.executionTime = tempExec;
            
            system.debug('@@@ qryEnd: '+qryEnd);
            system.debug('@@@ tempExec: '+tempExec);
            //system.debug('@@ total'+ (qryEnd.getTime() - qryStart.getTime()) );

            //RLA 12/01/1010 C-004140: Time tracing of processes on restupsert
            if (String.isnotBlank(system.label.TimeTracingRestupsert) && (system.label.TimeTracingRestupsert).toUpperCase() == 'YES'){
                wrapperLog.T1 = time1;
                wrapperLog.T2 = time2;
                wrapperLog.T3 = time3;
                wrapperLog.T4 = time4;
                wrapperLog.T5 = time5;
                wrapperLog.T6 = time6;
                wrapperLog.T7 = time7;
                wrapperLog.T8 = time8;
                wrapperLog.T9 = time9;
                wrapperLog.T10 = time10;
                wrapperLog.T11 = time11;
                wrapperLog.T12 = time12;
                wrapperLog.T13 = time13;
                wrapperLog.T14 = time14;
                wrapperLog.T15 = time15;
            }

            //RLA 19/10/2020 C-004030: From createAssessment to upsertAssessment
            if (isfromr3){
                APManageLogs.createWsLog(wrapperLog, 'insert');
            }
            else{   
                 //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
                APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');

            }
        }
        
        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
        //WCH 21/09/2021 C-004078
		RestContext.response.addHeader('X-XSS-Protection', '1') ;
        RestContext.response.addHeader('mode', 'block') ;
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - upsertAssessment ----------------------------------');
        



    }

    public static String deserialiseResponse(String body){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - deserialiseResponse ----------------------------------');

        // variable
        //set<AccountId> used to get BS
        Set<String> bsIdRefSet                              = new Set<String>();    
        bsRefAccountMap                                     = new Map<Id, Account>();
        // ase: 05/12/17 : lien BS evol
        expertAccSet                                        = new set<id>();                                    
        // map<AccountRef__c.Name, AccountRef__c>
        Map<String, AccountRef__c> accRefMap                = new Map<String, AccountRef__c>();
        // map<CarMapping__c.Name, CarMapping__c>
        assessAccountRefMap                                 = new Map<String, AccountRef__c>();     
        assessCarMap                                        = new Map<String, String>(); 
        //map<AssessmentId, receivedJson>
        Map<String, List<Object>> existingAssessMap         = new Map<String, List<Object>>();
        newOriginalMap                                      = new Map<String, list<Object>> ();
        allValidAssessMap                                   = new Map<String, Map<String, Object>>();
        originalPartsMap                                    = new map<String, Partlist__c>();
        originalSubstitutesMap                              = new map<String,list<Partlist__c>>(); 
        allAssessSubOriginalMap                             = new map<String, set<String>>();
        allSubPartsMap                                      = new map<String, Partlist__c>();

        List<Assessment__c> newAssessmentList               = new List<Assessment__c>();       
        
        //list<partList> to be inserted
        List<PartList__c> newPartList                           = new List<PartList__c>();
        //list<Substitues> to be inserted
        List<PartList__c> newSubstituteList                     = new List<PartList__c>();
        //map<AssessementId, list<PartList>>
        Map<String, List<PartList__c>> assessIdPartsMap         = new Map<String, List<PartList__c>>();
        Map<String, List<PartList__c>> shopAssessIdPartsMap     = new Map<String, List<PartList__c>>();
        //map<AssessementId, list<Substitutes>>
        Map<String, List<PartList__c>> assessSubstituteListMap  = new Map<String, List<PartList__c>>();   
        // Map<OEM PartNumber, all existing IAM>
        Map<String, List<CrossReference__c>> OEMIAMMap          = new Map<String, List<CrossReference__c>>();
        // C-2600:
        Map<String, List<CrossReference__c>> OEMNoACRMap        = new Map<String, List<CrossReference__c>>();
        // Map<AssessId, Assessment__c>
        Map<String, Assessment__c> assessMap                    = new Map<String, Assessment__c>();
        
        String response;
        String nevadaResponse;
        Boolean isNevada = false;

        // Map<OEM PartNumber, IAM with least price>
        Map<String, CrossReference__c> OEMIAMPriceMap           = new Map<String, CrossReference__c>();
        
        mapErrorsCreation                                       = new Map<String, String>();

        //AMI 06/07/2017 - Adding warning message exception handling
        mapWarningCreation                                      = new Map<String, String>();

        //DUN 11/08/2016 Mapof entity and Mapof AssNo-AssBrand-CountryCode as Key and a List of parts used to call method runSubstitution
        //map<entity, map<AssId-AssBrand-CountryCode, list<partList>>>
        Map<String, Map<String, List<Object>>> mapEntitymapAsslistParts;
        Map<String, ASPISServiceSubstitution.SubstituteWrapper> mapEntitySubstituteWrapper = new Map<String, ASPISServiceSubstitution.SubstituteWrapper>();

        // list of all assessments that are considered valid after checking for mandatory fields        
        List<Map<String, Object>> allValidAssessList                        = new List<Map<String, Object>>();
     
        asessPartSubMap                         = new Map<String, List<PartList__c>>();
        //map of AccountRef__c whose SubstitutionAccepted__c is not true
        Map<Id, AccountRef__c> accountRefToUpdate = new Map<Id, AccountRef__c>();
        Map<String, List<Object>> shoppingListExistAssessMap = new Map<String, List<Object>>();    

        //ASE: 02/03/2017: C-001885
        Set<String> carMapBrandSet = new Set<String>();
        Map<String, String> carMapBrandMap = new Map<String, String>();
        Map<String, String> carMapCrossRefMap  = new Map<String, String>();
        Set<String> carMapCrossRefSet = new Set<String>();

        //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
        //this list is used to get all received assessment map having external id
        List<Map<String, Object>> lstProcessedAssObj = new List<Map<String, Object>>();
        //  ASE: 17/11/17 C-002078
        map<String, Assessment__c> ICEAssessmentMap = new  map<String, Assessment__c>();
        list<Object> nonICEAssessList = new list<Object>();
        map<String, String> ICEAssessErrorMap = new map<String, String>();

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : this map will be used to hold correct order (position) of assessment
        map <string,integer> mapAssIdPositionNumber = new map <string,integer>();
        //RLA 02/04/17 : C-002370 Distributor V2 add Eligibility 
        //              : Run eligibility before substitution
        list<Assessment__c> lstAssessmentforEligibility;      

        //WCH 30/08/2018 30/08/2018 :C-002754 initialise map
        theAssesToUpdate=new Map<Id,Assessment__c>();

        //WCH 17/08/2020 C-003578
        boolean isExpertAssessmentCorrect=false;
        Map<string,object> mapInputParams = new Map<string,object>();
        Map<string,object> mapOutputParams = new Map<string,object>();

        //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
        String entityCode;

         //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
        set<String> setEntityCode = new set<String>();



        try{
            datetime qryStart15 = datetime.now();
            // deserialize body
            Decimal d2 = 0;
            Decimal d3 = 0;
            Decimal d16 = 0;
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(body);
            
            if(!objList.isEmpty()){
                // The index of the assessment in the objList
                Integer position = 0;
                
                for(Object receivedAssess : objList){
                    Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;
                    String callerSystem = (receivedAssessMap.get('callerSystem') != null && receivedAssessMap.get('callerSystem') != '') ? (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase() : null;
                    String AssessmentNumber = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;
     
                    isFromR3 = (receivedAssessMap.get('isFromR3') != null) ? Boolean.valueOf(receivedAssessMap.get('isFromR3')) : false;
                    system.debug('@@ isfromr3' + isfromr3);

                    newAssessmentR3 = (receivedAssessMap.get('assessmentR3') != null) ? String.valueOf(receivedAssessMap.get('assessmentR3')) : ''; //NPE 14/12/2021 C:004540

     
                    //  ASE: 17/11/17 C-002078
                    Boolean compensated = (receivedAssessMap.get('Compensated') != null) ? Boolean.valueOf(receivedAssessMap.get('Compensated')) : null;
                    
                    //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                     String brandMercedes = '';
                    if(receivedAssessMap.get('currentAsset') != null){
                        Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');    
                        brandMercedes = (currentAssetMap.get('Brand') != null && currentAssetMap.get('Brand') != '') ? String.valueOf(currentAssetMap.get('Brand')) : null;
                    }
                    String brandCallerSystem = (callerSystem != null) ? ((callerSystem.substring(2, 3) == '_') ? callerSystem.right(callerSystem.length()-3) : callerSystem) : null;
                    
                    //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS
                    insuranceBroker = (receivedAssessMap.containsKey('InsuranceBroker')) ? (string)receivedAssessMap.get('InsuranceBroker') : '';

                    //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                    entityCode = (receivedAssessMap.containsKey('EntityCode')) ? (string)receivedAssessMap.get('EntityCode') : '';

                    system.debug('@@ insuranceBroker: '+insuranceBroker);


                    if (callerSystem == 'BE_INFORMEX'){
                        isInformex = true;
                    }
                    //RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex
                    else if (callerSystem == 'ES_AUDATEX'){
                        isESAudatex = true;
                    }
                    else if (String.isnotBlank(insuranceBroker) && system.label.InsBrokerName.contains(insuranceBroker)){
                        isIG = true;
                        system.debug('@@ i am IG true here');
                    }
                   
                    if (String.isNotBlank(callerSystem)
                        && callerSystem.left(2) == 'ES'){
                        isCountryEs = true;    
                    }
                    //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
                    callersystemGlo = callerSystem;
                    
                    //RLA 30/07/2019 C-003344: Substitutes manual Parts for Italy
                    country = ((callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) : userRolePrefix).toUpperCase();
                    system.Debug('<<<country>>>' + country);
                    
                    if (mapConfigCountryCodeInfo.containsKey(country)
                        && String.isNotBlank(mapConfigCountryCodeInfo.get(country).CallerSystemForManualPartsSubs__c)){
                        List<String> lstCallersystemsAllowed = (mapConfigCountryCodeInfo.get(country).CallerSystemForManualPartsSubs__c).split(';');
                        system.debug('## lstCallersystemsAllowed:'+lstCallersystemsAllowed);

                        if (lstCallersystemsAllowed.contains(callerSystem.toUpperCase())){
                            isManualPartsAllowedforSubs = true;
                        }

                    }
                     //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                    if (mapConfigCountryCodeInfo.containsKey(country)
                        && String.isNotBlank(mapConfigCountryCodeInfo.get(country).CallerSystemForAPrefix__c)){
                        List<String> lstCallersystemsAllowed = (mapConfigCountryCodeInfo.get(country).CallerSystemForAPrefix__c).split(';');
                        system.debug('## lstCallersystemsAllowed:'+lstCallersystemsAllowed);

                        if (lstCallersystemsAllowed.contains(callerSystem.toUpperCase())){
                            String carMappingKey = (brandCallerSystem + '-' + brandMercedes).toUpperCase(); 
                            Map<String, String> carMapBrandMapMercedes = new Map<String, String>();
                            String keyBrand = brandCallerSystem + '-' +brandMercedes;

                            for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel = :keyBrand ]){
                                if(!carMapBrandMapMercedes.containsKey(carMapMdt.MasterLabel)){
                                    carMapBrandMapMercedes.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
                                }                               
                            }

                            String callerCarDest = carMapBrandMapMercedes.containsKey(carMappingKey) ? carMapBrandMapMercedes.get(carMappingKey) : null; 

                            system.debug('## callerCarDest:'+callerCarDest);
                            system.debug('## carMappingKey:'+carMappingKey);


                            if (String.isnotBlank(system.label.AllowedBrandsforAPrefix)
                                && callerCarDest != null){
                                List<String> lstMercedes = (system.label.AllowedBrandsforAPrefix).split(';');
                                if (lstMercedes.contains(callerCarDest.toUpperCase())){
                                 
                                    isAPrefixAllowedforSubs = true;
                                }
                            }
                        }

                    }
                    //HRM 12/10/2021 C-004405 : No Ordering on Fake References
                    setFakeReferences = getFakeReferences(country);

                    system.debug('## country:'+country);
                    system.debug('## isManualPartsAllowedforSubs:'+isManualPartsAllowedforSubs);
                    system.debug('## isAPrefixAllowedforSubs:'+isAPrefixAllowedforSubs);
                    system.debug('## isCountryEs:'+isCountryEs);

                    if(callerSystem == 'FR_ICE'){

                        if(compensated !=null && AssessmentNumber !=null){
                            if(!ICEAssessmentMap.containsKey(AssessmentNumber)){
                                ICEAssessmentMap.put(AssessmentNumber, new Assessment__c(AssessmentID__c = AssessmentNumber,  Compensated__c = compensated, CompensatedWSDate__c = Datetime.now()));
                                mapAssIdPositionNumber.put(AssessmentNumber,position);
                            }
                        }
                        else{
                            ICEAssessErrorMap.put('Assessment ['+ position + ']', 'Assessment ['+ position + '] not processed.  No AssessmentNumber or Compensated found.' );
                        }
                    }
                    else{
                        nonICEAssessList.add(receivedAssess);
                        String brand;    
                        if ( (receivedAssessMap.get('EntityCode') == '299'  || receivedAssessMap.get('EntityCode') == '392') && receivedAssessMap.get('isShoppingList')== false) {
                            isNevada = true;
                        }                     
                        if(receivedAssessMap.get('currentAsset') != null){
                            Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');    
                            brand = (currentAssetMap.get('Brand') != null && currentAssetMap.get('Brand') != '') ? String.valueOf(currentAssetMap.get('Brand')) : null;
                            //RLA 26/02/2020 Citroen Brand update
                            brand = modifyBrandCitroen(brand);
                        }
                                  
                        if(brandCallerSystem != null && brand !=null){
                            carMapBrandSet.add((brandCallerSystem + '-' +brand).toUpperCase()); 
                        }   
                    }                
                }
     
                //  ASE: 17/11/17 C-002078
                if(ICEAssessmentMap.size() > 0 || ICEAssessErrorMap.size() > 0){

                    //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
                    //             : pass new param to method
                    response = processICEAssessment(ICEAssessmentMap, ICEAssessErrorMap,mapAssIdPositionNumber);
                } 

                if(nonICEAssessList.size() > 0){
                    
                    //get carMapping from carMapping metadata to alphaScale manufacturer equivalent
                    for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel in: carMapBrandSet]){
                        if(!carMapBrandMap.containsKey(carMapMdt.MasterLabel)){
                            carMapBrandMap.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
                        }
                        carMapCrossRefSet.add(('CATALOG-' + carMapMdt.CarDestination__c));
                    }
                    
                    string informexBSId;
                    //get carMapping from carMapping metadata to alphaScale manufacturer equivalent
                    for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel in: carMapCrossRefSet]){
                        if(!carMapCrossRefMap.containsKey(carMapMdt.MasterLabel)){
                            carMapCrossRefMap.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
                        }
                    }
          
                    
                    for(Object receivedAssess : nonICEAssessList){
                        // Casting the received assessment to a map of string, object
                        Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;

                        //AMI 23/01/18 : C-002195 - Audatex Integration 
                        //                        - check if AssessmentExternalId is being transmitted
                        map<string,object> currentAssessmentInfoReceived = (map<string,object>)receivedAssessMap.get('currentClaim');
                        //RLA 22/02/18 : C-002195 - Audatex Integration 
                        //                        - check if currentAssessment contains AssessmentExternalID

                        isAssExtIdTransmitted = currentAssessmentInfoReceived != null ? currentAssessmentInfoReceived.containsKey('AssessmentExternalID') : false;

                        // check if assessment contains all mandatory fields
                        Boolean isValid = checkMandatoryFields(receivedAssessMap, position);

                        // if assessment is Valid, check if request contains an assessment number
                        if(isValid){
                            string assessmentNumber = String.valueOf(receivedAssessMap.get('AssessmentNumber'));
                            //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop                            
                            String entityCodeForExp = String.valueOf(receivedAssessMap.get('EntityCode'));
                            setEntityCode.add(entityCodeForExp);
                            
                            //AMI 23/01/18 : C-002195 - Audatex Integration 
                            //                        - AUdatex integration should not be taken into account for externalid levelling 
                            //                        - since this is a new integration
                            if(string.isNotBlank(assessmentNumber) && !isAssExtIdTransmitted){
                                lstProcessedAssObj.add(receivedAssessMap);
                            }

                            String callerSystem = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
                            
                            //RLA 17/12/2020 C-004118: 	Remove the cleansing for the account reference for Italy
                            String refNumber;
                            system.debug('@@ country: '+country);
                            if (country == 'IT'){
                                refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber'));
                                system.debug('@@ refNumber 1:'+refNumber);
                            }
                            else{
                                refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');
                                system.debug('@@ refNumber 2:'+refNumber);

                            } 
                            //C-002692 : ASE 27/09/2018*/
                            BSLang = ((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).containsKey('BSlanguage') ? String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('BSlanguage')) : null;
                            String brand        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));
                            //RLA 26/02/2020 Citroen Brand update
                            brand = modifyBrandCitroen(brand);
                            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;

                            // ase: 05/12/17 : lien BS evol
                            //RLA 22/02/18 : C-002195 - Audatex Integration 
                            //                        - if AssessmentExternalId is being transmitted, no ClaimReference will be transmitted
                            String claimRef = ((Map<String, Object>) receivedAssessMap.get('currentClaim')).containsKey('ClaimReference') ? String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentClaim')).get('ClaimReference')) : null;

                            String plateNum = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('PlateNumber'));
                            plateNum = (plateNum != null) ? removeSpaceHypen(plateNum) : plateNum;

                            // check if mapping exists in Account reference
                            AccountRef__c accRef = AccountRef__c.getValues(callerSystem + '-' + refNumber);

                            //WCH 17/08/2020 C-003578
                            Assessment__c theCurrentAss=new Assessment__c(RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId(),PlateNumber2__c=plateNum,ClaimReference__c=claimRef,isShoppingList__c=isShoppingList,BodyShop__c=(accRef!=null?accRef.InternalReference__c:null));
                            mapInputParams.put('ExpertAssessment',theCurrentAss);
                            mapOutputParams = RestDistributorUtility.isExpertAssessmentCorrect(mapInputParams);
                            system.debug('mapInputParams>>'+mapInputParams);
                            system.debug('mapOutputParams>>'+mapOutputParams);

                            //RLA 13/07/18 : C-002234 : BE - Informex Target LOT 2
                            String extId = ((Map<String, Object>) receivedAssessMap.get('currentClaim')).containsKey('AssessmentExternalID') ? String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentClaim')).get('AssessmentExternalID')) : null;

                            //RLA 09/04/2020 C-003694: IG - Substitution
                            substitutionType = receivedAssessMap.containsKey('SubstitutionType') ? (String.valueOf(receivedAssessMap.get('SubstitutionType'))).toUpperCase() : null;

                            if (String.isBlank(assessmentNumber)
                                && extId != null){
                                informexBSId = callerSystem +extId;
                            }
                      
                            // both accRef and carMap are not null when this part is being executed             

                            // Account Reference
                            if (accRef != null){
                                accRefMap.put(accRef.Name, accRef);
                                bsIdRefSet.add(accRef.InternalReference__c);
                                bodyshopId = accRef.InternalReference__c;

                                if(!accRef.SendingAccepted__c && !isShoppingList){
                                   accountRefToUpdate.put(accRef.Id, new AccountRef__c(Id = accRef.Id, SendingAccepted__c = true));
                                }
                            }                   
                            
                            // list that contains all the assessment that is valid to be processed
                            allValidAssessList.add(receivedAssessMap);  

                             //RLA 22/02/18 : C-002195 - Audatex Integration 
                            //                        - if AssessmentExternalId is being transmitted no need for lien Expert
                            if (!isAssExtIdTransmitted){ 
                                //ASE - 01/03/2018: C-002311
                                // ase: 05/12/17 : lien BS evol
                                //if (claimRef != null){
                                //       setClaim.add(claimRef);
                                //}
                                if (plateNum != null){
                                       setPlate.add(plateNum);
                                }
                                
                                if (accRef != null){
                                    if(accRef.InternalReference__c != null){
                                        //ASE - 01/03/2018: C-002311
                                        //claimPlateBSRefMap.put(claimRef + '-'+ plateNum, accRef.InternalReference__c);
                                        claimPlateBSRefMap.put(plateNum, accRef.InternalReference__c);      
                                    }   
                                }
                            }
                                           
                        }

                        // Increment the index for each loop
                        position++;
                    }


                    //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
                    //perform parts list external key levelling first - to allow old system 
                    //without ext id to work with new system having ext id
                    system.debug('## lstProcessedAssObj.size() ' + lstProcessedAssObj.size());
                    if(!lstProcessedAssObj.isEmpty()){
                        updatePartsKey(lstProcessedAssObj);
                    }                    
                
                    //AMI 26/10/17 : C-002041 - Distributor V2 - integrating call out before any dml
                    //                        - adding missing field to query
                    //AMI 26/10/17 : C-002041 - Distributor V2 - WS Integration
                    //   
                    //RLA 06/03/178: C-002041 - Distributor V2 - Run Eligibility
                    //                        - adding missing field to query
                    //DUN 30/07/18 : C-001837 - Added CarBrandsSuppliedAgency__c,WCH 24/08/2020 C-003838 changed BillingStateCode to custom field
                    if(!bsIdRefSet.isEmpty()){
                        for(Account acc: [  SELECT  Id, ShippingCountryCode, ContactUser__r.Email, ContactUser__c, ContactEmail__c, ReferenceNumber__c,
                                                    isEligibleSubstitution__c, CarBrandExcluded__c, Categories__c, Type, AXAPartner__c,ShippingCountry,
                                                    ShippingPostalCodeLeft2__c,VATNumber__c,Name,BillingStateCode__c, isEligible__c,DirectOrderingProcess__c, 
                                                    /*C-002278 : ASE 30/03/2018*/ Feature__c , Non_AXA_Authorised__c, TotalLoss__c, ExpertSubstitutionMethod__c, /*C-2600*/ SubstitutionMethod2__c,  DistributorConnected__c, 
                                                     CarBrandsSuppliedAgency__c  
                                                     ,OrderFromAT__c, //RLA 16/08/2018 C-002690 Spain audatex assessments in r4
                                                     AXA_Partner__c, //RLA 08/01/2020 C-003513
                                                     PreferredPartType__c  //RLA 10/08/2020 C-003738
                                                     ,keepAXA__c,KeepNonAXA__c ////RLA 19/05/2021 C-004337:
                                                     ,Pilote_BdG__c //RLA 16/12/2021 Substitution H
                                                     ,Brand_Rejected_on_Non_Partner__c//RLA 28/02/2022 C-004565
                                                                                                       
                                            FROM    Account 
                                            WHERE   Id IN: bsIdRefSet]){ 
                            // ASE : 26/06/2018- C-002651: no call made if BS.DistributorConnected= false                            
                            BSConnected = acc.DistributorConnected__c;
                            bsRefAccountMap.put(acc.Id, acc);
                            // ase: 05/12/17 : lien BS evol
                            if(acc.type == 'Expert'){
                                expertAccSet.add(acc.Id);
                                isNevada = false;
                                isExpert =  true;
                                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                                accRefNumberExpert = acc.ReferenceNumber__c;
                                //ASE 19/03/2018: 2381 : si l'account expert IT forced, assessment expert= forced
                                if(acc.ShippingCountryCode != 'FR' && acc.ExpertSubstitutionMethod__c == 'FORCED'){
                                    accountForced = true;
                                }
                            }

                            //NPE 08/04/2022 C-004633 Post Nevada: remove filter based on AXAPartner__c
                            // if (acc.AXAPartner__c == false){
                            //         isNevada = false;
                            // }

                            //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed                    
                            if(acc.type == 'Standard' && acc.AXA_Partner__c){
                                isBsOrExpertLinkedAss = true;
                                System.debug('#### isBsOrExpertLinkedAss'+isBsOrExpertLinkedAss);

                            }
                            //RLA 19/01/2022 C-004449: Algo Substitution Albax
                            if (!(acc.ExpertSubstitutionMethod__c == 'FORCEDALBAX' && carBrandExcluded)){
                            //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
                            preferredType = acc.PreferredPartType__c;
                            }

                            //RLA 07/03/2021 C-004631: l'expert n'ait pas la piece H, que ce soit un chiffrage avec ou sans chiffrage BS
                            if(acc.type != 'Expert'){
                                isPilotBdg = acc.Pilote_BdG__c;
                            }

                            //RLA 01/03/2021 C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY
                            isEligibleToOrder = acc.AXA_Partner__c;
                            system.debug('country>>'+country);
                            entityCode = String.isBlank(entityCode) ? system.label.EntityCodeDefaultValue : entityCode ;    
                            system.debug('entityCode>>'+entityCode);

                            
                            //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                            isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => country, 'entity' => entityCode, 'fromProcess' => 'Order'});
                            if (isNonAxa){
                                if ( (String.isnotblank(acc.Feature__c) && !acc.Feature__c.contains('NONAXASubstitution')) ||String.isblank(acc.Feature__c) ) {
                                    isSubsAllowed =  false;
                                }
                               
                            }


                        }
                    }
					String newRefNumber;
                    if(expertAccSet.size() > 0){
                        //WCH 17/08/2020 C-003578
                        if(mapOutputParams.containsKey('isExpertAssessmentCorrect') && (boolean)mapOutputParams.get('isExpertAssessmentCorrect')){
                            //ASE - 01/03/2018: C-002311
                            Boolean isAssessmentFound = false;
                            //RLA C-004481: Un chiffrage expert d'un Assureur ne doit pas être lié à un chiffrage garage d'un autre assureur.
                            String query = AP43LinkBSExpert.getQueryBSExpert( new map<String,Object> {'setPlate' => setPlate, 'setEntityCode' => setEntityCode});
                            system.debug('query>>'+query);

                            List<Assessment__c> assList = Database.query(query);
                            system.debug('assList>>'+assList);

                            for(Assessment__c assess: assList){
                            // for(Assessment__c assess: [Select CreatedDate, CrossReferences__c, NumASPParts__c, AssessmentId__c, ClaimReference__c, PlateNumber2__c, BodyShop__r.CarBrandExcluded__c,
                            // ParentAssessment__c , BodyShop__r.AXA_Partner__c /*RLA 08/01/2020 C-003513*/ 
                            // ,BodyShop__r.DistributorConnected__c, BodyShop__r.AXAPartner__c, BodyShop__r.PreferredPartType__c,
                            // BodyShop__r.ReferenceNumber__c, BodyShop__r.ExpertSubstitutionMethod__c,
                            // BodyShop__r.Categories__c, BodyShop__r.Name, BodyShop__r.VATNumber__c, BodyShop__r.Feature__c,
                            // BodyShop__r.CarBrandsSuppliedAgency__c, BodyShop__r.Id,TECH_EntityCountryCode__c, 
                            // BodyShop__r.isEligibleSubstitution__c,BodyShop__r.ShippingCountryCode,BodyShop__r.ContactUser__c,
                            // BodyShop__r.ContactUser__r.Email, BodyShop__r.ContactEmail__c, 
                            // BodyShop__r.Type,BodyShop__r.ShippingCountry,BodyShop__r.ShippingPostalCodeLeft2__c,
                            // BodyShop__r.BillingStateCode__c,BodyShop__r.isEligible__c,BodyShop__r.DirectOrderingProcess__c,
                            // BodyShop__r.Non_AXA_Authorised__c,BodyShop__r.TotalLoss__c,BodyShop__r.SubstitutionMethod2__c, BodyShop__r.KeepNonAXA__c, BodyShop__r.keepAXA__c
                            //  /*RLA 08/01/2020 C-004100*/ 
                            //                             from Assessment__c
                            //                             where (PlateNumber2__c in : setPlate) and BodyShop__r.Type = 'Standard'
                            //                             //RLA 04/10/2019 Nena 
                            //                             and BodyShop__r.ShippingCountryCode = 'FR'
                            //                             and RecordTypeId =: Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()
                            //                             and isShoppingList__c = false
                            //                             //RLA 23/02/2021 Do not link Expert Assessment to BS if from createToUpsert
                            //                             and isFromR3__c = false
                            //                             and CreatedDate >=: System.today().addMonths(-Integer.valueOf(System.label.AssessementCreatedmonth))//WCH 17/08/2020 C-003578
                            //                             and EntityCode__c IN:setEntityCode//RLA 12/10/2021 C-004100
                            //                             order by CreatedDate DESC]){
                                if(claimPlateBSRefMap.containskey(assess.PlateNumber2__c) && !isAssessmentFound){
                                    system.debug('@@ assess: '+assess);
                                    // C-002600                                 
                                    hasSubstitution = (assess.CreatedDate >= System.today().addMonths(-Integer.valueOf(System.label.AssessementCreatedmonth)) && (((assess.CrossReferences__c != null && assess.CrossReferences__c != '' && assess.CrossReferences__c != 'NONE') || (assess.NumASPParts__c > 0)))) ? true: false;

                                    if(assess.BodyShop__r.CarBrandExcluded__c != null){
                                        claimPlateCarBrandExcludedMap.put(claimPlateBSRefMap.get(assess.PlateNumber2__c), assess.BodyShop__r.CarBrandExcluded__c);
                                    }
                                    //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed   
                                    // if (assess.BodyShop__r.AXA_Partner__c){
                                        isBsOrExpertLinkedAss = true;
                                    // }
                                    System.debug('#### isBsOrExpertLinkedAss'+isBsOrExpertLinkedAss);

                                    
                                    system.debug('@@ hasSubstitution: '+hasSubstitution);

                                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                                    if (assess.TECH_EntityCountryCode__c == 'FR' && (system.label.switchFor4100ExpertAsBS).toUpperCase() == 'ON'){
                                        bodyshopToReplace = new Account(Id = assess.Bodyshop__r.Id,
                                                                       CarBrandExcluded__c = assess.BodyShop__r.CarBrandExcluded__c,
                                                                       AXA_Partner__c = assess.BodyShop__r.AXA_Partner__c, 
                                                                       DistributorConnected__c = assess.BodyShop__r.DistributorConnected__c, 
                                                                       AXAPartner__c = assess.BodyShop__r.AXAPartner__c, 
                                                                       PreferredPartType__c = assess.BodyShop__r.PreferredPartType__c,
                                                                       ReferenceNumber__c = assess.BodyShop__r.ReferenceNumber__c, 
                                                                       ExpertSubstitutionMethod__c = assess.BodyShop__r.ExpertSubstitutionMethod__c,
                                                                       Categories__c =  assess.BodyShop__r.Categories__c, 
                                                                       Name = assess.BodyShop__r.Name, 
                                                                       VATNumber__c = assess.BodyShop__r.VATNumber__c, 
                                                                       Feature__c = assess.BodyShop__r.Feature__c,
                                                                       CarBrandsSuppliedAgency__c = assess.BodyShop__r.CarBrandsSuppliedAgency__c,
                                                                       isEligibleSubstitution__c = assess.BodyShop__r.isEligibleSubstitution__c,
                                                                       ShippingCountryCode = assess.BodyShop__r.ShippingCountryCode,
                                                                       ContactUser__c = assess.BodyShop__r.ContactUser__c,
                                                                       ContactEmail__c = assess.BodyShop__r.ContactEmail__c,                           
                                                                       Type= assess.BodyShop__r.Type,
                                                                       ShippingCountry = assess.BodyShop__r.ShippingCountry,
                                                                    //    ShippingPostalCodeLeft2__c = assess.BodyShop__r.ShippingPostalCodeLeft2__c,
                                                                       BillingStateCode__c = assess.BodyShop__r.BillingStateCode__c,
                                                                       isEligible__c = assess.BodyShop__r.isEligible__c,
                                                                       DirectOrderingProcess__c = assess.BodyShop__r.DirectOrderingProcess__c,
                                                                       Non_AXA_Authorised__c = assess.BodyShop__r.Non_AXA_Authorised__c,
                                                                       TotalLoss__c = assess.BodyShop__r.TotalLoss__c,
                                                                       SubstitutionMethod2__c = assess.BodyShop__r.SubstitutionMethod2__c,
                                                                       //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                                                                       KeepNonAXA__c = assess.BodyShop__r.KeepNonAXA__c,
                                                                       keepAXA__c = assess.BodyShop__r.keepAXA__c,
                                                                       //RLA 07/03/2021 C-004631: l'expert n'ait pas la piece H, que ce soit un chiffrage avec ou sans chiffrage BS
                                                                    //    Pilote_BdG__c = assess.BodyShop__r.Pilote_BdG__c//RLA Substitution H 16/12/2021
                                                                       Brand_Rejected_on_Non_Partner__c = assess.BodyShop__r.Brand_Rejected_on_Non_Partner__c//RLA 28/02/2022 C-004565: Garages du Groupe Ferron - Marques Exclues sur du NON Partenaire
                                                                       
                                                                       );
                                        bodyshopToReplace.recalculateFormulas();

                                        BSConnected = assess.Bodyshop__r.DistributorConnected__c;
                                        //RLA 19/01/2022 C-004449: Algo Substitution Albax
                                        if (!(assess.Bodyshop__r.ExpertSubstitutionMethod__c == 'FORCEDALBAX' && carBrandExcluded)){
                                        preferredType = assess.Bodyshop__r.PreferredPartType__c;
                                        }
                                        //RLA 07/03/2021 C-004631: l'expert n'ait pas la piece H, que ce soit un chiffrage avec ou sans chiffrage BS
                                        // isPilotBdg = assess.Bodyshop__r.Pilote_BdG__c

                                        //NPE 08/04/2022 C-004633 Post Nevada: remove filter based on AXAPartner__c
                                        // if (assess.Bodyshop__r.AXAPartner__c == false){
                                        //     isNevada = false;
                                        // }

                                        isExpert = false;
                                        //RLA 01/03/2021 C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY
                                        isEligibleToOrder = assess.Bodyshop__r.AXA_Partner__c;

                                        // bsRefAccountMap = new map<Id, Account>();
                                        // bsRefAccountMap.put(bodyshopToReplace.Id, bodyshopToReplace);
                                        system.debug('sourced as BS: ');
                                        system.debug('assess.Bodyshop__r.Id '+assess.Bodyshop__r.Id);

                                        String convertedBsID = (String.ValueOf(assess.Bodyshop__r.Id)).left(15);

                                        For (AccountRef__c accRef: [select name, InternalReference__c, ExternalReference__c 
                                                                    from AccountRef__c
                                                                    Where (InternalReference__c = :assess.Bodyshop__r.Id or InternalReference__c = : convertedBsID)
                                                                    and systemCalling__c = :callersystemGlo ]){
                                            // accRefMap = new map<String, AccountRef__c>();
                                            // accRefMap.put(accRef.Name, accRef);
                                            // system.debug('@@@ got it');
                                            newRefNumber = accRef.ExternalReference__c;
                                        }
                                       
                                    }
                                    isAssessmentFound = true;
                                   



                                    if (assess.ParentAssessment__c != null){
                                        system.debug('@@ we break: ');
                                        break;
                                    }


                                }
                            }
                        }
                    }

                    // loop in allValidAssessList to filter assessmentNumber
                    if(!allValidAssessList.isEmpty()){
                        //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                        existingAssessMap = filterAssessment(allValidAssessList, accRefMap, carMapBrandMap, carMapCrossRefMap, shoppingListExistAssessMap, newRefNumber);
                    }
                    System.debug('#### existingAssessMap'+existingAssessMap);
                    System.debug('#### isBsOrExpertLinkedAss'+isBsOrExpertLinkedAss);
                    
                    if(!existingAssessMap.isEmpty() || !shoppingListExistAssessMap.isEmpty()){
                        // this method determines which parts and respective substitutes are contained in an assessment  


                        retrievePartHierachy(existingAssessMap.keySet() , shoppingListExistAssessMap.keySet(), assessMap);
                        
                        // filter partList from response to determine which partList really exists for request having an assessmentNumber
                        filterExistingPartList(existingAssessMap);
                    }       

                    if (allValidAssessMap.size() > 0){
                        eligibleWrap = ASPISServiceEligibility.createAssessmentforEligibility(allValidAssessMap,bsRefAccountMap,assessAccountRefMap,assessCarMap );

                    //}  

                        if (eligibleWrap.isEligible){
                            mapAssessmentEligibility.put(eligibleWrap.ass.AssessmentID__c,eligibleWrap.isEligible);


                            // build mapEntitymapAsslistParts to proceed with substitution
                            if(newOriginalMap !=null && eligibleWrap.isEligible){
                                mapEntitymapAsslistParts = buildSubstitutionMap(newOriginalMap);
                            }

                            //HRM 19/11/21 C-004530: Subtitution for italy
                            Boolean canBeSubstituted = false;
                            Assessment__c assess = ASPISServiceEligibility.createAssessmentforEligibilityOnly(allValidAssessMap,bsRefAccountMap,assessAccountRefMap,assessCarMap );
                            Map<String,Object> mapOutputParamsSubs = ASPISServiceSubstitution.canBeSubstitutedOrNot(new map<String,Object>{'Assessment' => assess});

                            canBeSubstituted = mapOutputParamsSubs.containsKey('issubstitutable') ? (Boolean)mapOutputParamsSubs.get('issubstitutable') : false;
                            system.debug('*** mapOutputParamsSubs'+mapOutputParamsSubs);

                            system.debug('*** canBeSubstituted'+canBeSubstituted);
                            if(!mapEntitymapAsslistParts.isEmpty() && eligibleWrap.isEligible && isSubsAllowed && canBeSubstituted){
                                system.debug('*** here 2');
                            
                                datetime qryStart = datetime.now();

                                //DUN 11/08/2016 apply Susbtitution
                                for(String entity : mapEntitymapAsslistParts.keySet()){
                                    // C-2600:
                                    map<String,map<String,CrossReference__c>> mapAssessmentIAMfinal = new map<String,map<String,CrossReference__c>> ();
                                    map<String,map<String,CrossReference__c>> mapAssmapOEMKeylistIAM = new map<String,map<String,CrossReference__c>> ();
                                    
                                    //RLA 09/04/2020 C-003693: IG - Substitution
                                     //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
                                    ASPISServiceSubstitution.SubstituteWrapper substituteWrapper = ASPISServiceSubstitution.runSubstitution(mapEntitymapAsslistParts.get(entity), entity, assessBSCategoriesMap, isAPrefixAllowedforSubs, isBsOrExpertLinkedAss,callersystemGlo, substitutionType,preferredType, isNonAxa,isPilotBdg, isForcedAlbax);
                                    
                                    System.debug('<<<<<substituteWrapper>>>>>' + substituteWrapper);
                                    
                                    for(String assNum : substituteWrapper.mapAssmapOEMKeylistIAM.keyset()){
                                        OEMIAMMap.putAll(substituteWrapper.mapAssmapOEMKeylistIAM.get(assNum));
                                        //OEMIAMPriceMap.putAll(substituteWrapper.mapAssessmentIAMfinal.get(assNum));
                                    }

                                    //KEM 09/04/2020 C-004874: PREv2 Connected - Lot 2 - Substitution

                                    Map<String, List<CrossReference__c>> MapCrossRef = new Map<String, List<CrossReference__c>>();
                                    List<CrossReference__c> LstXRef = new List<CrossReference__c>();
                                    List<Occurence__c> LstOccurence = new List<Occurence__c>();
                                    List<DistributorPrice__c> LstDistPrice = new List<DistributorPrice__c>();
                                    List<String> LstDistId = new List<String>();
                                    List<String> LstDistPriceName = new List<String>();
                                    List<String> LstXrefIdLstDistId = new List<String>();

                                    if( CountryCodeInformationsMapping__c.getall().get(country).Connected_XREF__c){
                                        system.debug('<<<<TESTCOUNTRYCODE>>>>' + country );
                                        generateConnectedXrefForCountry = true ;

                                        for(String key : substituteWrapper.mapAssmapOEMKeylistIAM.keyset()){
                                            System.debug('key1: ' + key + '  Value1: ' + substituteWrapper.mapAssmapOEMKeylistIAM.get(key));
                                        MapCrossRef = substituteWrapper.mapAssmapOEMKeylistIAM.get(key);
                                            
                                        for(String key2 : MapCrossRef.keyset()){
                                            System.debug('key2: ' + key2 + '  Value2: ' + MapCrossRef.get(key2));
                            
                                            for(CrossReference__c crossRef : MapCrossRef.get(key2)){
                                                if(!crossRef.Connected__c && String.isnotBlank(crossRef.IAMPartClass__c) && crossRef.IAMPartClass__c=='E') continue;
                                                LstXRef.add(crossRef);
                                                mapXrefIdtoXref.put(crossRef.id, crossRef);
                                                LstDistPrice.add(crossRef.Distributors__r);
                                                xRefCountryCode = crossRef.CountryCode__c;

                                                for(DistributorPrice__c Disprice : LstDistPrice){
                                                    LstDistPriceName.add(Disprice.DistributorID__r.Name);
                                                    LstXrefIdLstDistId.add(Disprice.DistributorID__c);

                                                    /* for(Distributor__c DisName : LstDistPrice){
                                                        LstDistPriceName.add(DisName.Name);
                                                    } */
                                                }
                                                mapXrefDisName.put(crossRef.Id, LstDistPriceName);
                                                mapXrefIdLstDistId.put(crossRef.Id,LstXrefIdLstDistId);
                                            }
                                            System.debug('<<<LstXRef>>>: ' + LstXRef);
                                            System.debug('<<<LstDistPrice>>>: ' + LstDistPrice);
                                            System.debug('<<<LstDistPriceName>>>: ' + LstDistPriceName);
                                        }
                                        }
                                        for(CrossReference__c key3 : LstXRef){
                                            System.debug('<<<key32>>>: ' + key3.Ocurrences__r);
                                            LstOccurence = key3.Ocurrences__r ;
                                            System.debug('<<<LstOccurence2>>>: ' + LstOccurence);
                                            Set<String> DistName = new Set<String>();

                                            if(LstOccurence.size() > 0){
                                                for(Occurence__c key4 : LstOccurence){
                                                    SetOccurenceDistributor.add(key4.Distributor__c); 
                                                    if(mapXrefIdLstOccDistId.containsKey(key3.Id)){mapXrefIdLstOccDistId.get(key3.Id).add(key4.Distributor__c);
                                                    }else{
                                                        mapXrefIdLstOccDistId.put(key3.Id,new Set<String>{key4.Distributor__c});
                                                    }
                                                    
                                                }
                                            }
                                            mapXrefIdLstOccurence.put(key3.id, LstOccurence);
                                        
                                        }
                                        System.debug('<<<mapXrefDisName>>>: ' + mapXrefDisName);
                                        System.debug('<<<SetOccurenceDistributor>>>: ' + SetOccurenceDistributor);
                                        System.debug('<<<mapXrefIdLstOccurence>>>: ' + mapXrefIdLstOccurence);
                                        System.debug('<<<xRefCountryCode>>>: ' + xRefCountryCode);
                                        System.debug('<<<generateConnectedXrefForCountry>>>: ' + generateConnectedXrefForCountry);
                                        System.debug('//mapXrefIdLstOccDistId' + mapXrefIdLstOccDistId);
                                    }

                                    mapEntitySubstituteWrapper.put(entity, substituteWrapper);

                                    mapPartTypePriority.putAll(substituteWrapper.mapPartTypePriority);

                                    //C-002600
                                    // find best match
                                    if(OEMIAMMap.size() > 0){
                                        //RLA 19/01/2022 C-004449: Algo Substitution Albax
                                        if(isForcedAlbax){
                                            // remove all A'
                                            system.debug('@@ are you forcedAlbax?');
                                            for(String OEMkey : OEMIAMMap.keyset()){
                                                for(CrossReference__c CR: OEMIAMMap.get(OEMkey)){
                                                    if(cr.IAMPartClass__c == 'E'){
                                                        if(!OEMNoACRMap.containsKey(OEMkey)){
                                                            OEMNoACRMap.put(OEMkey, new list<CrossReference__c>{CR});
                                                        }
                                                        else{                                                            
                                                            OEMNoACRMap.get(OEMkey).add(CR);
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        
                                            if(OEMNoACRMap.size() > 0){
                                                // find best match
                                                ASPISServiceSubstitution.processAllCRMap(new map <String, map<String, list<CrossReference__c>>>{eligibleWrap.ass.AssessmentID__c => OEMNoACRMap}, new map<String, map<String,list<CrossReference__c>>>(), mapAssessmentIAMfinal,preferredType,false);

                                                if(mapAssessmentIAMfinal.size() > 0){
                                                    system.debug('@@@ OEMIAMPriceMap put1'+OEMIAMPriceMap);
                                                    system.debug('@@@ OEMIAMPriceMap put what'+mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));

                                                    OEMIAMPriceMap.putAll(mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));
                                                }
                                            }
                                        }
                                        else if(isForcedNoA){
                                            // remove all A'
                                            for(String OEMkey : OEMIAMMap.keyset()){
                                                for(CrossReference__c CR: OEMIAMMap.get(OEMkey)){
                                                    if(cr.IAMPartClass__c != 'A'){
                                                        if(!OEMNoACRMap.containsKey(OEMkey)){
                                                            OEMNoACRMap.put(OEMkey, new list<CrossReference__c>{CR});
                                                        }
                                                        else{                                                            
                                                            OEMNoACRMap.get(OEMkey).add(CR);
                                                        }
                                                    }
                                                }
                                            }
                                            

                                            if(OEMNoACRMap.size() > 0){
                                                // find best match
                                                ASPISServiceSubstitution.processAllCRMap(new map <String, map<String, list<CrossReference__c>>>{eligibleWrap.ass.AssessmentID__c => OEMNoACRMap}, new map<String, map<String,list<CrossReference__c>>>(), mapAssessmentIAMfinal,preferredType,false);

                                                if(mapAssessmentIAMfinal.size() > 0){
                                                    system.debug('@@@ OEMIAMPriceMap put2'+OEMIAMPriceMap);
                                                    system.debug('@@@ OEMIAMPriceMap put2 what'+mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));
                                                    OEMIAMPriceMap.putAll(mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));
                                                }
                                            }
                                        }
                                        else{
                                            system.debug('@@@ OEMIAMPriceMap put3'+OEMIAMPriceMap);
                                                    system.debug('@@@ OEMIAMPriceMap put3 what'+substituteWrapper.mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));
                                            OEMIAMPriceMap.putAll(substituteWrapper.mapAssessmentIAMfinal.get(eligibleWrap.ass.AssessmentID__c));
                                        }
                                    }
                                   

                                }
                                time2 = ((datetime.now()).getTime() - qryStart.getTime());
                                time2 = (time2.divide(1000, 5));
                                system.debug('RRJ time 2 ='+time2);
                                d2 = time2;
                            }
                            
                        }     
                                
                    // process allValidAssessMap to upsert assessment, parts and substitutues
                    //if(!allValidAssessMap.isEmpty()){
                        datetime qryStart = datetime.now();
                        processValidAssess(allValidAssessMap, mapEntitySubstituteWrapper, newAssessmentList,newPartList, assessIdPartsMap, assessSubstituteListMap, assessMap, OEMIAMMap, OEMIAMPriceMap, existingAssessMap.keyset(), shoppingListExistAssessMap, shopAssessIdPartsMap); 
                        time3 = ((datetime.now()).getTime() - qryStart.getTime());
                        time3 = (time3.divide(1000, 5));
                        d3 = time3;
                    }           
                    
                    system.debug('<<<<newAssessmentList>>>>>' + newAssessmentList);
                    system.debug('<<<<accountRefToUpdate>>>>>' + accountRefToUpdate);
                    system.debug('<<<<assessIdPartsMap>>>>>' + assessIdPartsMap);
                    system.debug('<<<<assessMap>>>>>' + assessMap);
                    system.debug('<<<<assessSubstituteListMap>>>>>' +assessSubstituteListMap );
                    system.debug('<<<<mapEntitySubstituteWrapper>>>>>' +mapEntitySubstituteWrapper );
                    system.debug('<<<<OEMIAMMap>>>>>' + OEMIAMMap);
                    //----------- AMI 25/10/17 : Start C-002041 - Distributor V2 -----------//
                    datetime qryStart16 = datetime.now();
                    insertAll(newAssessmentList, accountRefToUpdate, assessIdPartsMap, assessMap, assessSubstituteListMap,OEMIAMMap);
                        
                    time16 = ((datetime.now()).getTime() - qryStart16.getTime());
                    time16 = (time16.divide(1000, 5));
                    d16 = time16;
                    //----------- AMI 25/10/17 - End C-002041 - Distributor V2 -----------//

                    //DUN 12/09/2016 MasterRule Pricing
                    //list of partlist to update
                    list<PartList__c> listPartListToUpdate = new list<PartList__c>();
                    //04-JUN-2019 RLA  C-003143 : Preseletion de la pièce E pour la France 
                    map<Id,Partlist__c> mapPartlistToUpdateNena = new map<Id,Partlist__c>();

                    //set of partlist tech id
                    set<String> setTechId = new set<String>();
                    for(String enCode : mapEntitysetPartListTechId.keySet()){
                        
                        if(mapEntitySubstituteWrapper.get(enCode) != null){
                            //DUN 07/11/2017 case 1994 add parameters in runValidation Method
                            //Testing original without entity
                            if(expertOriginalPartsMap.containsKey(enCode)){
                                mapEntitysetPartListTechId.get(enCode).addAll(expertOriginalPartsMap.get(enCode));
                            }
                            // ASE 13/04/2018 
                            if(ascrNonSelectedSet.size() > 0){
                                 
                                
                                mapEntitysetPartListTechId.get(enCode).removeAll(ascrNonSelectedSet);
                                
                            }
                            //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                            if (isNonAxa){
                                mapEntitysetPartListTechId.get(enCode).addAll(nonAxaOriginalPartsMap.get(enCode));

                            }

                            map<String,PartList__c> mapTechIdPartListtoUpdate = ASPISServiceSubstitution.runValidation(mapEntitySubstituteWrapper.get(enCode).listValidationCriteria, mapEntitySubstituteWrapper.get(enCode).listUpdateFieldsCriteria ,mapEntitysetPartListTechId.get(enCode), enCode, mapEntitySubstituteWrapper.get(enCode).validationLogicValue);
                            if (mapTechIdPartListtoUpdate.size() > 0) {
                                if (mapTechIdPartListtoUpdate.values()[0].getPopulatedFieldsAsMap().containsKey('Assessment__r') && mapTechIdPartListtoUpdate.values()[0].Assessment__r.getPopulatedFieldsAsMap().containsKey('ExpertSubstitutionMethod__c')){
                                   expertSubstitutionMethod = mapTechIdPartListtoUpdate.values()[0].Assessment__r.ExpertSubstitutionMethod__c;
                                   traceVariables += ' #update 1 with Partlist value: ' +expertSubstitutionMethod + '#';
                                }
                            }

                            if(mapTechIdPartListtoUpdate != null && mapTechIdPartListtoUpdate.size() > 0){
                                listPartListToUpdate.addAll(mapTechIdPartListtoUpdate.values());
                                setTechId.addAll(mapTechIdPartListtoUpdate.keySet()); 
                            } 
                            //. ASE 12/01/2017: case C-001828: check best substitutes in parent assessment
                            /*for(String crashSubstitute : cloneSubstituteMap.keySet()){
                                if(mapTechIdPartListtoUpdate.containskey(crashSubstitute)){
                                    PartList__c claimSubstitute =  new PartList__c(TECH_OriginalPart__c = cloneSubstituteMap.get(crashSubstitute), RecommendedByAS__c=true, SelectedByBS__c=true);
                                    listPartListToUpdate.add(claimSubstitute);
                                }
                            }*/
                            //20-SEP-2019 RLA  C-003143 : Preseletion de la pièce E pour la France 
                            map<String,Partlist__c> mapTechOriPartlistUpdate = new map<String,Partlist__c>();
                            mapPartlistToUpdateNena = new map<Id,Partlist__c>(listPartListToUpdate);
                             Id assessmentId;
                            for (partlist__c part: listPartListToUpdate){
                                mapTechOriPartlistUpdate.put(part.TECH_OriginalPart__c, part);
                            }
                            system.debug('@@ mapTechOriPartlistUpdate'+mapTechOriPartlistUpdate) ;  

                            
                            if(!mapOriginalTechOriginalPartSetSubsTechOriginalPart.isEmpty() && !mapTechOriPartlistUpdate.isEmpty()){

                                for(string originalKey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.keySet()){

                                    if (mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey).size() > 1 && !setExistingTechOriginalPart.contains(originalKey.toUpperCase()) ){

                                        for(string subsKey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey)){
                                            system.debug('@@ subsKey'+subsKey) ;  

                                            if (mapTechOriPartlistUpdate.containsKey(subsKey)){
                                                 
                                                if ( mapOriginalTechOriginalPartSetSubsPartEs.containskey(originalKey)
                                                    && mapOriginalTechOriginalPartSetSubsPartEs.get(originalKey).size() > 0
                                                    && mapTechOriPartlistUpdate.get(subsKey).Type__c == 'E'){
                                                    assessmentId = mapTechOriPartlistUpdate.get(subsKey).Assessment__c;

                                                    system.debug('## do selection E:'+subsKey);
                                                    String selectedEPArt;
                                                    if (system.label.EPartsDistributorsPrincipal != 'none'){
                                                        selectedEPArt = selectionE (mapOriginalTechOriginalPartSetSubsPartEs, originalKey, system.label.EPartsDistributorsPrincipal);
                                                        system.debug('## selectedEPArt Principal:'+selectedEPArt);

                                                    }
                                                    if (system.label.EPartsDistributors != 'none' && String.isBlank(selectedEPArt)){
                                                        selectedEPArt = selectionE (mapOriginalTechOriginalPartSetSubsPartEs, originalKey, system.label.EPartsDistributors);
                                                        system.debug('## selectedEPArt secondary:'+selectedEPArt);

                                                    }
                                                    system.debug('## selectedEPArt:'+selectedEPArt);
                                                    system.debug('@@ mapOEMASCRSE: '+mapOEMASCRSE) ;  


                                                    // if (mapTechOriPartlistUpdate.containsKey(selectedEPArt)){
                                                    //     system.debug('@@ remove exacte') ;  

                                                    //     mapPartlistToUpdateNena.remove(mapTechOriPartlistUpdate.get(subsKey).Id)  ; 
                                                    //     mapPartlistToUpdateNena.add()
                                                    // }
                                                    // else{
                                                        PartList__c aSCReToUpdate ;
                                                        Boolean updateOEM = false;
                                                    if (selectedEPArt != null){
                                                        if (mapOriginalTechOriginalPartSetSubsPartEs.containsKey(originalKey)){
                                                            for (PartList__c ascrEPart: mapOriginalTechOriginalPartSetSubsPartEs.get(originalKey)){
                                                                system.debug('@@ rascrEPart'+ascrEPart) ;  

                                                                // if (ascrEPart.TECH_OriginalPart__c != selectedEPArt){

                                                                    if (mapTechOriPartlistUpdate.containsKey(ascrEPart.TECH_OriginalPart__c)){
                                                                        system.debug('@@ remove rascrEPart'+ascrEPart) ;  

                                                                        mapPartlistToUpdateNena.remove(mapTechOriPartlistUpdate.get(ascrEPart.TECH_OriginalPart__c).Id)  ; 
                                                                        // mapTechOriPartlistUpdate.put()
                                                                    }

                                                                    if (ascrEPart.TECH_OriginalPart__c == selectedEPArt){
                                                                        aSCReToUpdate =  new partlist__c (Id = ascrEPart.Id,
                                                                                                        TECH_OriginalPart__c = ascrEPart.TECH_OriginalPart__c,
                                                                                                        RecommendedByAS__c = true,
                                                                                                        SelectedByBS__c = true,
                                                                                                        PartNumber__c = ascrEPart.PartNumber__c,
                                                                                                        Type__c = ascrEPart.Type__c,
                                                                                                        Assessment__c = assessmentId );   
                                                                    }
                                                                // }
                                                                // else{
                                                                //     updateOEM = true;
                                                                // }
                                                                
                                                                

                                                            }
                                                            if (aSCReToUpdate != null || updateOEM ){
                                                                //20-SEP-2019 RLA  C-003143 : Preseletion de la pièce E pour la France
                                                                if (mapOEMASCRSE.containskey(originalKey)
                                                                    && mapTechOriOem.containskey(originalKey) ){      
                                                                    system.debug('@@@ got in: ' + mapTechOriOem.get(originalKey));
                                                                    mapPartlistToUpdateNena.put(mapTechOriOem.get(originalKey).Id, new partlist__c(Id = mapTechOriOem.get(originalKey).Id,
                                                                                                                                                    ASCREListRandomNumber__c = mapOEMASCRSE.get(originalKey),
                                                                                                                                                    TECH_OriginalPart__c = originalKey,
                                                                                                                                                    PartNumber__c = mapTechOriOem.get(originalKey).PartNumber__c));

                                                                    // aSCReToUpdate.ASCREListRandomNumber__c = mapOEMASCRSE.get(originalKey);
                                                                    

                                                                } 
                                                                system.debug('@@@ aSCReToUpdate: '+aSCReToUpdate);
                                                                // aSCReToUpdate.Assessment__c = assessmentId;
                                                                if (aSCReToUpdate != null ){
                                                                    mapPartlistToUpdateNena.put(aSCReToUpdate.Id,aSCReToUpdate);
                                                                }
                                                            }
                                                        }

                                                    }
                                                    
                                                    // if (selectedEPArt != null){
                                                    //     selectedPart = selectedEPArt;
                                                    // }
                                                }
                                            }
                                        }

                                    }
                                }

                            }

                        }  
                    }            

                    // ASE : 136/11/17 : C-001988 
                    // to process expertOriginalPartsSet here
                    // if assessment is Expert and Proposed, check all originals in expertOriginalPartsSet
                    set<Id> setAssId = new set<Id>();
                    set<String> setDisId = new set<String>();
                    //04-JUN-2019 RLA  C-003143 : Preseletion de la pièce E pour la France 
                    if(mapPartlistToUpdateNena != null && mapPartlistToUpdateNena.size() > 0){
                        // ASE 12/01/2017: case C-001828
                        // AMI 20/11/17 : C-002041 - Distributor V2 - Pricing commented -- lowest price will be determined by code itself not from master rule
                        // ASE: 19/03/2018 : pricing bug. if assessment is Expert and Proposed, check all originals in expertOriginalPartsSet
                        if((isExpert && (expertSubstitutionMethod != 'FORCED' )) || !accountForced){
                            system.debug('## Applying best price for proposed assessment');
                            
                            

                            upsert mapPartlistToUpdateNena.values() TECH_OriginalPart__c; 
                        }

                        for(PartList__c updPart : mapPartlistToUpdateNena.values()){
                        // for(PartList__c updPart : listPartListToUpdate){
                            if (updPart.Assessment__c != null){
                                setAssId.add(updPart.Assessment__c);
                            }
                            if(updPart.PartNumber__c.StartsWith('ASCR-')){
                                if(!mapSubsKeySubForRespGeneration.containskey(updPart.TECH_OriginalPart__c)){
                                    mapSubsKeySubForRespGeneration.put(updPart.TECH_OriginalPart__c, updPart);
                                }
                                else{
                                    mapSubsKeySubForRespGeneration.remove(updPart.TECH_OriginalPart__c);
                                    mapSubsKeySubForRespGeneration.put(updPart.TECH_OriginalPart__c, updPart);
                                }
                                if(updPart.SelectedByBS__c){
                                    if(!crossRefMap.containsKey(updPart.Assessment__c)){
                                        crossRefMap.put(updPart.Assessment__c, new Set<String>{updPart.PartNumber__c});
                                    }
                                    else{
                                        crossRefMap.get(updPart.Assessment__c).add(updPart.PartNumber__c);
                                    }
                                    //WCH 30/08/2018 : C-002754 : add distributors in list
                                    if(!String.isBlank(updPart.TECHDistList__c)){
                                        setDisId.addAll(new List<String>(updPart.TECHDistList__c.split(';')));
                                    }
                                }                           
                            }
                        }
                    }  

                    // DUN : 23/11/17 : C-001988 
                    // to process expertOriginalPartsSet here
                    // if assessment is Expert and Proposed, check all originals in expertOriginalPartsSet
                    
                    if(assessSubstituteListMap.size() > 0){
                        for(list<PartList__c> listupdPart : assessSubstituteListMap.values()){
                            for(PartList__c updPart : listupdPart){
                                setAssId.add(updPart.Assessment__c); 
                                
                                if(updPart.PartNumber__c.StartsWith('ASCR-') && updPart.SelectedByBS__c){
                                    if(!crossRefMap.containsKey(updPart.Assessment__c)){
                                        crossRefMap.put(updPart.Assessment__c, new Set<String>{updPart.PartNumber__c});
                                    }
                                    else{
                                        crossRefMap.get(updPart.Assessment__c).add(updPart.PartNumber__c);
                                    }                            
                                }
                            }
                        }
                    }
                    
                    if(assessSubstituteListMap.size() == 0){
                        isNevada = false;
                    }
                    for(Id assId : setAssId){
                        if(!crossRefMap.containskey(assId) && assId != null){
                            crossRefMap.put(assId, new Set<String>{'NONE'});
                        }
                    }
                    
                    //WCH 30/08/2018 :C-002754 list of assessment to update field MRSourcing__c
                    for(Assessment__c theAss : theAssesToUpdate.values()){
                        /*if(!crossRefMap.containskey(assId) && assId != null){
                            crossRefMap.put(assId, new Set<String>{'NONE'});
                        }*/
                        if(!String.isBlank(theAss.MRSourcing__c) && !theAss.MRSourcing__c.equals('false')){//WCH 24/08/2020 C-003906
                            setDisId.addAll(new List<String>(theAss.MRSourcing__c.split(';')));
                        }
                        theAss.MRSourcing__c=string.join(new List<String>(setDisId),';');
                        //WCH 19/09/2019 C-003391 , 16/07/2020 C-003860
                        if((String.isBlank(theAss.MRSourcing__c) || theAss.MRSourcing__c=='false') && String.isBlank(theAss.ReasonFailure__c)){
                            theAss.MRSourcing__c = 'false';
                            theAss.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                            theAss.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                        }

                        string convertedList = String.join(new list <string>(crossRefMap.get(theAss.Id)), ';');

                        //Case 2600
                        if (String.isnotBlank(convertedList)){
                            theAss.CrossReferences__c = convertedList;
                        }
                        else{
                            theAss.CrossReferences__c = 'None';  

                        }
                    }
                    if(!theAssesToUpdate.keyset().isEmpty()){
                        update theAssesToUpdate.values();
                    }

                    //AMI - 06/02/18 - C-002041 - Distributor V2 - Do not updated cross ref field on assessment since catered in new field (MRSourcing)
                    /*// ASE : 14/11/17 C-001994 - issue 1
                    system.debug('## listPartListToUpdate:'+crossRefMap);
                    if(crossRefMap.size() > 0){
                        setCrossReferencesFieldForAssessment(crossRefMap);
                    }*/
                    
                    response = generateResponse(assessMap, assessIdPartsMap, OEMIAMMap, OEMIAMPriceMap, setTechId,shoppingListExistAssessMap, shopAssessIdPartsMap, false);
                    
                    
                    // ASE: 05/04/17 C-001825 : call restPostAssessment
                    callRESTPostAssessment(assessMap);
                    
                    //VSU: 21/07/17 C-001924 : send json response to NEVADA
                    
                    if (isNevada){
                      nevadaResponse = generateResponse(assessMap, assessIdPartsMap, OEMIAMMap, OEMIAMPriceMap, setTechId,shoppingListExistAssessMap, shopAssessIdPartsMap, true);
                      RESTPostNevada.sendRequest(nevadaResponse);
                    }

                }
            }   
            //RRJ Check time tracing for other methode 24/10/2022
            time15 = ((datetime.now()).getTime() - qryStart15.getTime());
            time15 = (time15.divide(1000, 5));
            time15 = time15 - d2 - d3 - d16;
            system.debug('RRJ time 15 ='+time15);
            System.debug('---------------------------------- END RESTUpsertAssessmentV2 - deserialiseResponse ----------------------------------');
        }
        catch(Exception ex){
            JSONGenerator genResults  = JSON.createGenerator(false);
            genResults.writeStartArray();
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'Insert');
                genResults.writeNullField('TechnicalId');
                genResults.writeNullField('FunctionalId');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                //genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getMessage());
                genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getMessage() + '.  Stack Trace : ' + ex.getStackTraceString()); 
            genResults.writeEndObject();
            genResults.writeEndArray(); 

            response = genResults.getAsString();
        }
        return response;
    }

    public static Map<String,Assessment__c> clonedAssessment(String callerSysExtId,  Map<String, Object> receivedAssessMap, map<String, AccountRef__c> accRefMap, String audatexExistingAssess){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - clonedAssessment ----------------------------------');
        

        //RLA 13/07/18 : C-002234 : BE - Informex Target LOT 2
        if (String.isNotBlank(callerSysExtId)){  

            Map<String,Assessment__c> mapAssNumberAss = new Map<String,Assessment__c> ();

            Map<String,PartList__c> mapPartlist = new map<String,PartList__c>();

            List<PartList__c> lstPartlist = new list<PartList__c>();

            Assessment__c assCloned;

            String assessmentBsId;

            String refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');

            String callerSystem = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
           
            String accountRefkey = callerSystem + '-' + refNumber;

            String accountRefMapKey = accRefMap != null && (accRefMap.get(accountRefkey) != null) ? accRefMap.get(accountRefkey).InternalReference__c : null;

            Account BSAccount = (bsRefAccountMap.get(accountRefMapKey) != null) ? bsRefAccountMap.get(accountRefMapKey): null; 

            String cleanseCallerSystem = (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;

            map<string,object> currentAssessmentInfoReceived = (map<string,object>)receivedAssessMap.get('currentClaim');

            string assessmentExtId = currentAssessmentInfoReceived.containsKey('AssessmentExternalID') ? string.valueOf(currentAssessmentInfoReceived.get('AssessmentExternalID')) : '';

            //WCH 27/11/2019 C-003508
            String ClaimCountryCode = cleanseCallerSystem.left(2);

            //WCH 10/05/2022 C-004713
            Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMappings = CountryCodeInformationsMapping__c.getAll();
            CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(String.isBlank(ClaimCountryCode)?'XXX':ClaimCountryCode)) ? mapCountryCodeMappings.get(ClaimCountryCode) : mapCountryCodeMappings.get('DEFAULT');
            

            //RLA 11/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
            Map<String, List<PartList__c>> mapAssPartList = new map<String, List<PartList__c>>();
            List<PartList__c> listAssExistingPartList = new List<PartList__c>();
            //RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex
            string assessmentVersionNumber = currentAssessmentInfoReceived.containsKey('AssessmentVersion') ? string.valueOf(currentAssessmentInfoReceived.get('AssessmentVersion')) : '';
            string cloneFrom = currentAssessmentInfoReceived.containsKey('CloneFrom') ? string.valueOf(currentAssessmentInfoReceived.get('CloneFrom')) : '';

            //RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex
            String query = ' Select AgencyMode__c,  AmtOthers__c,  AssessmentExternalId__c, AssessmentVersion__c,  callerSystem__c, ClaimReference__c, ' + 
                            ' Colour__c,  Comment__c,  CompanyName__c,  Compensated__c,  crashCode__c,  CrossReferences__c,  CurrencyIsoCode,' +
                            ' CVM__c,  DateOfIncident__c, Energy__c,  Engine__c, BodyShop__c, ' +
                            ' Entity__c,  EntityCode__c,  EntityRules__c,  ExcessAmount__c,  ExpertCode__c,  ExpertSubstitutionMethod__c,  ' +
                            ' ExpertType__c,  ExpertValidationDate__c,  FirstRegistrationDate__c,  Fleet__c,' +
                            ' GroupAgentCode__c,  GuaranteeType__c,  Id, IDCIA__c,  individual__c,  IsCareOrder__c,  ' +
                            ' IsDeleted, isShoppingList__c,  KMS__c,  LongTermDeletionDate__c,  Manufacturer__c,  MaximumValidityDate__c,  ' +
                            ' MinimumValidityDate__c,  MissionNumber__c,  ModelV2__c,  MREligibility__c,  MRSourcing__c,  NBHoursLabour__c,  ' +
                            ' NBHoursLabourLevel1__c,  NBHoursLabourLevel2__c,  NBHoursLabourLevel3__c,  NBHoursLabourPainting__c, ' + 
                            ' NetworkType__c,  OrderNumber__c,  OrderOrigin__c, ' +
                            ' OrderStatus__c,  PaintingType__c,  PartA__c,  PartB__c,  PartC__c,  PartD__c,  PartP__c,  ' +
                            ' PickupDate__c,  PlaceOfInspection__c,  PlateNumber2__c,  PortfolioAgentCode__c,  ProductCode__c, ' + 
                            ' QuotationAmountInclVAT__c,  QuotationAmtExlVAT__c,  RepairsAuthorised__c,  ' +
                            ' SelectedByBSPartTypes__c,  ShortTermDeletionDate__c,  SpecialAgreement__c,  SpecialRenting__c,  SubAgentCode__c, ' + 
                            ' SubstitutionAccepted__c,  SupposedOfFraud__c,  TECH_EntityCountryCode__c,  ' +
                            ' TechAutoNumber__c,  TechCompensatedIsChanged__c,  TECHRulesAppliedDescription__c,  ' +
                            ' TotalAmtExlVAT__c,  TotalAmtInclVAT__c,  TotalAmtLabour__c,  TotalAmtLabourExlPainting__c,  ' +
                            ' TotalAmtLabourPainting__c,  TotalAmtPainting__c,  TotalAmtPaintingInclLabour__c,  TotalAmtParts__c, ' + 
                            ' TotalDeducible__c,  TotalLabour__c,  TotalLabourAmtDiscount__c,  TotalLoss__c,  ' +
                            ' TotalMaterial__c,  TotalNumberOfParts__c,  TotalObsoleteRatio__c,  TotalPaintingAmtDiscount__c, ' + 
                            ' TotalPartsAmtDiscount__c,  TotalVAT__c,  TransactionId__c,  VATPortionPayable__c, ' + 
                            ' VDSCode__c,  VINCheck__c,  VINNumber__c,AssessmentNumber__c, AssessmentID__c,CapturedDistributors__c, ' +
                            ' (SELECT Alpha_Scale_MRID__c, DistributorPriceId__c, isDeleted__c, CrossReferenceId__c, SelectedByBS__c,' + 
                            ' OriginalPart__c,OriginalPart__r.ExternalId__c, OriginalPart__r.PartNumber__c, RecommendedByAS__c,' +
                            ' Description__c, Name, PartNumber__c, Price__c, ProducerName__c, Quantity__c,' + 
                            ' RecordTypeId, Type__c , Compliance__c, InputType__c, Currency__c, Assessment__c ,InterventionCode__c, TECHDistList__c, Distributor__c' +
                            ' ,NBHoursLabourPartLevel1__c, NBHoursLabourPartLevel2__c ,NBHoursLabourPartLevel3__c ,NBHoursLabourPainting__c' +
                            ' ,ARCAUTOCode__c ,VAT__c , CertifyingOrganization__c, Id, StandardMargin__c, StandardDiscount__c, Stock__c, Deducible__c,ObsoleteRatio__c, Distributors__c, ExternalId__c' +
                            ' FROM PartsLists__r Where isDeleted__c = false) ' +                 
                            ' From Assessment__c' + 
                            ' Where  RecordType.Name =\''+ASPISConstants.ASSESS_RT_DeveloperName_Claim +'\'' ;


            query = (isInformex ? query+=' AND AssessmentExtIdCallerSystem__c != null AND AssessmentExtIdCallerSystem__c =\''+callerSysExtId +'\' And BodyShop__r.Type = \'Standard\' ' : query);

            query = (isESAudatex ? query+=' AND (AssessmentID__c = \'' + callerSysExtId + '\''  : query);

            //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS
            query = (isIG ? query+=' AND AssessmentExtIdCallerSystem__c = \'' + callerSysExtId + '\''  : query);
            if(isESAudatex){
                if (String.isNotBlank(audatexExistingAssess)){
                    query+=' OR AssessmentID__c = \'' + audatexExistingAssess + '\')';
                }
                else{
                    query+= ') ' ;
                }
            }

            //add sorting
            query+=' ORDER BY LastModifiedDate DESC NULLS LAST ';

            system.debug('## query: ' + query);
            system.debug('## isESAudatex: ' + isESAudatex);
            system.debug('## callerSysExtId: ' + callerSysExtId);
            system.debug('## cloneFrom: ' + cloneFrom);
            system.debug('## isInformex: ' + isInformex);

            list<Assessment__c> listAssessment = Database.query(query);

            for (Assessment__c assBS :listAssessment){
                system.debug('## assBS1' + assBS);


                if (isInformex || ( assBS.AssessmentID__c == callerSysExtId && isESAudatex )){
                    system.debug('## assBS' + assBS);
                    
                    assessmentBsId =  assBs.Id;
                    assCloned = assBs.clone(false, false, false, false);
                    assCloned.Id = null;
                    
                    
                    
                    if (isInformex){
                        BSAssessment = assBs; 
                        assCloned.BodyShop__c = (BSAccount != null) ? BSAccount.Id : null;   
                        assCloned.AssessmentID__c = (cleanseCallerSystem + (assessmentExtId+refNumber)).toUpperCase();                
                        assCloned.AssessmentNumber__c =  (assessmentExtId+refNumber).toUpperCase();  
                        assCloned.Name = assCloned.AssessmentNumber__c.toUpperCase();
                        assCloned.AssessmentExtIdCallerSystem__c = callerSystem + assessmentExtId;
                        mapAssNumberAss.put(assBS.AssessmentNumber__c, assBS);
                    }
                    else if (isESAudatex){
                        assCloned.AssessmentID__c = (cleanseCallerSystem + assessmentExtId+ '-' + assessmentVersionNumber).toUpperCase(); 
                        assCloned.AssessmentNumber__c =  (assessmentExtId+ '-' + assessmentVersionNumber).toUpperCase(); 
                        assCloned.Name = assCloned.AssessmentNumber__c.toUpperCase();
                        assCloned.AssessmentExtIdCallerSystem__c = callerSystem + assessmentExtId + '-' + assessmentVersionNumber;
                        assCloned.AssessmentVersion__c = Integer.valueof(assessmentVersionNumber); 
                        assCloned.AlreadyQuoted__c = false;

                    }
                    system.debug('## assCloned' + assCloned);
                    mapAssNumberAss.put(assCloned.AssessmentNumber__c, assCloned);  
                    mapAssPartList.put(assessmentBsId, assBs.PartsLists__r); 
                }
                //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS
                else if (isIG && String.isNotBlank(assBS.CapturedDistributors__c)){
                    system.debug('## assBS CapturedDistributors__c' + assBS.CapturedDistributors__c);
                    capturedDistributorsGlo = assBS.CapturedDistributors__c;
                    break;                   

                }
                else if (String.isNotBlank(audatexExistingAssess) && isESAudatex && assBS.AssessmentID__c == audatexExistingAssess){
                    listAssExistingPartList.addall(assBs.PartsLists__r);

                }             

                
                
            }//end for

            if (assCloned != null  && mapAssPartList.containskey(assessmentBsId)){

                upsert assCloned AssessmentID__c ;
                if (isInformex){
                    BSAssessment.ParentAssessment__c = assCloned.Id;
                }
                
                map<String, PartList__c> mapPartNumberOriginal = new map<String, PartList__c>();
                Map<String,PartList__c> mapPartlistUpdate = new map<String,PartList__c>();

                //RLA 11/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2  
                for(PartList__c pl : mapAssPartList.get(assessmentBsId)){     
                       

                    PartList__c part = pl.clone(false, false, false, false);
                    part.Assessment__c = assCloned.Id;
                    String PN                           = pl.PartNumber__c;
                    String description                  = pl.Description__c;
                     String partName                     = String.isBlank(description) ? currentCountryCodeMapping.PartLabelEmptyText__c : description.left(80);
                    String manufacturer                 = pl.ProducerName__c;
                    string newExtId                     = pl.ExternalId__c != null ? pl.ExternalId__c : part.OriginalPart__r.ExternalId__c+'-'+part.PartNumber__c ;        

                    part.TECH_OriginalPart__c = buildPartTechnicalId(assCloned.AssessmentID__c, PN, partName, manufacturer,newExtId);
                    mapPartlist.put(part.TECH_OriginalPart__c,part);
                    if (String.isBlank(part.Alpha_Scale_MRID__c)){
                        mapPartNumberOriginal.put(part.PartNumber__c, part);
                    }
                }
                if (listAssExistingPartList.size() > 0){
                    delete listAssExistingPartList;
                }
                
                if (mapPartlist.size() > 0){
                    upsert mapPartlist.values() TECH_OriginalPart__c;
                }                

                for (PartList__c parts : mapPartlist.values()){
                    if (String.isNotBlank(parts.Alpha_Scale_MRID__c) &&
                        mapPartNumberOriginal.containskey(parts.originalPart__r.Partnumber__c)){
                        parts.originalPart__c = (mapPartNumberOriginal.get(parts.originalPart__r.Partnumber__c)).Id;
                        mapPartlistUpdate.put(parts.TECH_OriginalPart__c,parts);
                    }
                }                

                if (mapPartlistUpdate.size() > 0){
                    upsert mapPartlistUpdate.values() TECH_OriginalPart__c;
                }  

                return mapAssNumberAss;
            }
        }
        return null;

    }

    // check if assessment has missing mandatory fields
    public static Boolean checkMandatoryFields(Map<String, Object> receivedAssessMap, Integer position){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - checkMandatoryFields ----------------------------------');

        Boolean isValid = false;
        Set<String> assessfieldSet;
        Set<String> partFieldSet;
        Set<String> assetFieldSet = new Set<String>();
        Set<String> bsFieldSet;
        Set<String> claimFieldSet;
        
        String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;
        Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;

        // update
        if(assessNum != null && assessNum != ''){
            assessfieldSet  = new Set<String>{'AssessmentNumber', 'callerSystem', 'currentAsset', 'currentBodyShop', 'currentClaim', 'Parts'};
            partFieldSet    = new Set<String>{'PartLabel', 'PartNumber', 'Price', 'Quantity'};
            assetFieldSet.add('Brand');
            bsFieldSet      = new Set<String>{'ReferenceNumber'};
        }
        // new assessment
        else{
            assessfieldSet  = new Set<String>{'callerSystem', 'VINCheck', 'currentAsset', 'currentBodyShop', 'currentClaim', 'Parts'};
            partFieldSet    = new Set<String>{'PartLabel', 'PartNumber', 'Price', 'Quantity', 'RecordType'};
            assetFieldSet.add('Brand');
            bsFieldSet      = new Set<String>();
            
            if(!isShoppingList || isNonAxa){
                assessfieldSet.add('VINCheck');
                bsFieldSet.add('ReferenceNumber');
                //RLA 22/02/18 : C-002195 - Audatex Integration 
                //                        - if AssessmentExternalId is being transmitted ClaimReference is not a mandatory field
                if (!isAssExtIdTransmitted){
                    claimFieldSet   = new Set<String>{'ClaimReference'};
                }
            }
            else{
                partFieldSet.add('Currency');
                assetFieldSet.add('Model');                
            }              
        }

        String missingFields  = checkFields(assessfieldSet, partFieldSet, assetFieldSet, bsFieldSet, claimFieldSet, receivedAssessMap);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            mapErrorsCreation.put('Assessment at position[' + position +'] ', 'Exceptions: Missing fields: '+ missingFields);
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - checkMandatoryFields ----------------------------------');

        return isValid;
    }

    public static String checkFields(Set<String> assessfieldSet, Set<String> partFieldSet, Set<String> assetFieldSet, Set<String> bsFieldSet, Set<String> claimFieldSet, Map<String, Object> receivedAssessMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - checkFields ----------------------------------');

        Boolean isValid = true;
        String missingFields = '';

        // check if field exists in assessment
        for(String assessField: assessFieldSet){
            if(!receivedAssessMap.containsKey(assessField)){
                isValid         = false;
                missingFields   += assessField + '; ';
            }
        }

        // loop in inner JsonObjects
        if(isValid){
            // loop in Asset
            // build currentAssetMap
            if(receivedAssessMap.get('currentAsset') != null){
                Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');

                for(String assetField: assetFieldSet){
                    if(!currentAssetMap.containsKey(assetField)){
                        //isValid = false;
                        missingFields += 'currentAsset.' + assetField + '; ';
                    }

                    if(!currentAssetMap.containsKey('PlateNumber') && !currentAssetMap.containsKey('VINNumber')){
                        missingFields += 'currentAsset.PlateNumber or currentAsset.VINNumber' + '; ';
                    }
                }
            }

             // build currentBSMap
            if(receivedAssessMap.get('currentBodyShop') != null){
                Map<String, Object> currentBSMap = (Map<String, Object>) receivedAssessMap.get('currentBodyShop');

                // loop in bsFieldSet
                for(String bsField: bsFieldSet){
                    if(!currentBSMap.containsKey(BSField)){
                        //isValid = false;
                        missingFields += 'currentBodyShop.' + bsField + '; '; 
                    }
                }
            }

            // build currentClaimMap
            if(receivedAssessMap.get('currentClaim') != null && claimFieldSet != null){
                Map<String, Object> currentClaimMap = (Map<String, Object>) receivedAssessMap.get('currentClaim');

                // loop in ClaimFieldSet
                for(String claimField: claimFieldSet){
                    if(!currentClaimMap.containsKey(claimField)){
                        //isValid = false;
                        missingFields += 'currentClaim.' + claimField + '; ';
                    }                    
                }
            }

            // build List partlistMap
            if(receivedAssessMap.get('Parts') != null){
                for(Object receivedPart: (List<Object>)receivedAssessMap.get('Parts')){
                    Map<String, Object> receivedPartMap = (Map<String, Object>) receivedPart;

                    //check if partNumber exists in partList
                    if(!receivedPartMap.containsKey('PartNumber')){
                        missingFields += 'PartNumber missing in one of the partList';
                    }
                    else{

                        // loop in part's other mandatory fields
                        String missingPartFieldSet = 'Part: '+ String.ValueOf(receivedPartMap.get('PartNumber')) +'\'s missing fields: ';

                        Boolean foundMissingFields = false;
                        // loop in partFieldSet
                        for(String partField: partFieldSet){
                            if(!receivedPartMap.containsKey(partField)){
                                missingPartFieldSet += partField +'; ';
                                foundMissingFields  = true;
                            }
                        }

                        if(foundMissingFields){
                            missingFields += missingPartFieldSet;
                        }
                    }
                }
            }
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - checkFields ----------------------------------');

        return missingFields;
    }

    // ASE: 09/09/2016
    public static Map<String, List<Object>> filterAssessment(
        List<Map<String, Object>> allValidAssessList, 
        map<String, AccountRef__c> accRefMap, 
        Map<String, String> carMapBrandMap, 
        Map<String, String> carMapCrossRefMap, 
        Map<String, list<Object>> shoppingListExistAssessMap,
        String newRefNumber//RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
        ){

        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - filterAssessment ----------------------------------');

        Map<String, list<Object>> existingAssessMap = new Map<String, list<Object>>(); 
        assessIDEntityCodeMap =  new map <String, String>();  
        
        for(Map<String, Object> receivedAssessMap : allValidAssessList){
        
            String callerSystem = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
            //RLA 17/12/2020 C-004118: 	Remove the cleansing for the account reference for Italy
            String refNumber;
            if (country == 'IT'){
                refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber'));
                system.debug('@@ refNumber 1'+refNumber);
            }
            else{
                refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');
                system.debug('@@ refNumber 2'+refNumber);

            } 
            String brand        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));
            //RLA 26/02/2020 Citroen Brand update
            brand = modifyBrandCitroen(brand);
            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;
            String accountRefkey = callerSystem + '-' + refNumber;
            String brandCallerSystem = (callerSystem.substring(2, 3) == '_') ? callerSystem.right(callerSystem.length()-3) : callerSystem;
            String carMappingKey = (brandCallerSystem + '-' + brand).toUpperCase();
            String entityCode = String.valueOf(receivedAssessMap.get('EntityCode'));
            entityCode = String.isBlank(entityCode) ? system.label.EntityCodeDefaultValue : entityCode ;    

            String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;
            //RLA 22/02/18 : C-002195 - Audatex Integration 
            //                        - if AssessmentExternalId is being transmitted, ClaimReference will not be transmitted
            String claimRef = ((Map<String, Object>) receivedAssessMap.get('currentClaim')).containskey('ClaimReference') ? String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentClaim')).get('ClaimReference')) : null;
            String plateNum = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('PlateNumber'));
            plateNum = (plateNum != null) ? removeSpaceHypen(plateNum) : plateNum;
            
            // if plate number is null, take VIN
            String assessCode = (plateNum != null) ? plateNum : String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('VINNumber'));
            
            // case C-001885
            String callerCarDest = carMapBrandMap.containsKey(carMappingKey) ? carMapBrandMap.get(carMappingKey) : null;
            String catalogCarDest = callerCarDest != null ? carMapCrossRefMap.get('CATALOG-'+callerCarDest): null;
            
            String accountRefMapKey = (accRefMap.get(accountRefkey) != null) ? accRefMap.get(accountRefkey).InternalReference__c : null;
            Account BSAccount; 
            String accRefNumber;
            Boolean isEligibleSubstitution;

            

            // ASE: 13/03/2017 : No substitution if brand is found in CarBrandExcluded__c AND BS.ExpertSubstitutionMethod != Forced Exclude A' NENA 
            carBrandExcluded = false;  

            //AMI 23/01/18 : C-002195 - Audatex Integration 
            //                        - Getting assessment external id and/or assessment version if present
            map<string,object> currentAssessmentInfoReceived = (map<string,object>)receivedAssessMap.get('currentClaim');
            string assessmentExtId = currentAssessmentInfoReceived.containsKey('AssessmentExternalID') ? string.valueOf(currentAssessmentInfoReceived.get('AssessmentExternalID')) : '';
            string assessmentVersionNumber = currentAssessmentInfoReceived.containsKey('AssessmentVersion') ? string.valueOf(currentAssessmentInfoReceived.get('AssessmentVersion')) : '';
            string updatedAssId = string.isNotBlank(assessmentExtId) ? (string.isNotBlank(assessmentVersionNumber) ? assessmentExtId + '-' + assessmentVersionNumber : assessmentExtId) : '';
            
            //RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex
            string cloneFrom = currentAssessmentInfoReceived.containsKey('CloneFrom') ? string.valueOf(currentAssessmentInfoReceived.get('CloneFrom')) : '';


            if(accountRefMapKey != null){
                BSAccount = (bsRefAccountMap.get(accountRefMapKey) != null) ? bsRefAccountMap.get(accountRefMapKey): null;
                
                accRefNumber = BSAccount != null ?  BSAccount.ReferenceNumber__c : null;
                

                if (isNonAxa){
                    isEligibleSubstitution = isSubsAllowed;
                }
                else{
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                    isEligibleSubstitution = bodyshopToReplace != null ? bodyshopToReplace.isEligibleSubstitution__c : (BSAccount != null ?  BSAccount.isEligibleSubstitution__c : false);
                }
                system.debug('isEligibleSubstitution>>'+isEligibleSubstitution);
                system.debug('accRefNumber>>'+accRefNumber);
                system.debug('BSAccount>>'+BSAccount);
                
                // ase: 05/12/17 : lien BS evol
                String carBrandExcl;
                // expert BS
                if(claimPlateCarBrandExcludedMap.size() > 0 && claimPlateCarBrandExcludedMap.containskey(accountRefMapKey)){
                    carBrandExcl = claimPlateCarBrandExcludedMap.get(accountRefMapKey);
                }
                // standard BS
                else{
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                    carBrandExcl = bodyshopToReplace != null ? bodyshopToReplace.CarBrandExcluded__c :  ((bsRefAccountMap.containskey(accountRefMapKey)) ? bsRefAccountMap.get(accountRefMapKey).CarBrandExcluded__c : null);
                }
                
                carBrandExcluded = (carBrandExcl != null && callerCarDest != null) ? ((carBrandExcl.contains(callerCarDest)) ? true : false ): false;
                
                if (bodyshopToReplace != null){
                    isBSForced = (bodyshopToReplace != null  && bodyshopToReplace.ExpertSubstitutionMethod__c == 'FORCED' && !isExpert) ? true : false;
                    isBSForcedNoA = (bodyshopToReplace != null  && bodyshopToReplace.ExpertSubstitutionMethod__c == 'FORCED NO A\'' && !isExpert) ? true : false;
                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                    isBSForcedAlbax = (bodyshopToReplace != null  && bodyshopToReplace.ExpertSubstitutionMethod__c == 'FORCEDALBAX' && carBrandExcluded && !isExpert) ? true : false;
                }
                else{
                    isBSForced = (BSAccount != null  && BSAccount.ExpertSubstitutionMethod__c == 'FORCED' && !isExpert) ? true : false;
                    isBSForcedNoA = (BSAccount != null  && BSAccount.ExpertSubstitutionMethod__c == 'FORCED NO A\'' && !isExpert) ? true : false;
                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                    isBSForcedAlbax = (BSAccount != null  && BSAccount.ExpertSubstitutionMethod__c == 'FORCEDALBAX' && carBrandExcluded && !isExpert) ? true : false;
                }
                
            }
            else{
                accRefNumber = null;
                isEligibleSubstitution = false;
                carBrandExcluded = false;
            } 

            // C-2600: setting isForcedNoA to true if (BS = standard and BS.ExpertSubstitutionMethod__c = " FORCED NO A'" and Brand is excluded) OR (BS = expert AND no standard assessment/ no substitution is found on standard assessment AND expert.SubstitutionMethod2__c = " FORCED NO A'")
            //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
            if (bodyshopToReplace != null){
                 isForcedNoA = (bodyshopToReplace != null && ((!isExpert && carBrandExcluded && bodyshopToReplace.ExpertSubstitutionMethod__c == 'FORCED NO A\'') || (isExpert && !hasSubstitution && bodyshopToReplace.SubstitutionMethod2__c == 'FORCED NO A\''))) ? true : false;
                System.debug('### isForcedNoA>>' + isForcedNoA);
                //RLA 11/12/2018 C-002782 CJP A'
                isProposed = (bodyshopToReplace != null && (isExpert && hasSubstitution && (bodyshopToReplace.ExpertSubstitutionMethod__c == 'Proposed') || ((isExpert && !hasSubstitution && bodyshopToReplace.SubstitutionMethod2__c == 'Proposed' )))) ? true : false;
                //RLA 19/01/2022 C-004449: Algo Substitution Albax
                isForcedAlbax = (bodyshopToReplace != null && ((!isExpert && carBrandExcluded && bodyshopToReplace.ExpertSubstitutionMethod__c == 'FORCEDALBAX') || (isExpert && !hasSubstitution && bodyshopToReplace.SubstitutionMethod2__c == 'FORCEDALBAX' && carBrandExcluded))) ? true : false;
                System.debug('### isForcedAlbax>>' + isForcedAlbax);

            }
            else{
            isForcedNoA = (BSAccount != null && ((!isExpert && carBrandExcluded && BSAccount.ExpertSubstitutionMethod__c == 'FORCED NO A\'') || (isExpert && !hasSubstitution && BSAccount.SubstitutionMethod2__c == 'FORCED NO A\''))) ? true : false;

            //RLA 11/12/2018 C-002782 CJP A'
            isProposed = (BSAccount != null && (isExpert && hasSubstitution && (BSAccount.ExpertSubstitutionMethod__c == 'Proposed') || ((isExpert && !hasSubstitution && BSAccount.SubstitutionMethod2__c == 'Proposed' )))) ? true : false;
                //RLA 19/01/2022 C-004449: Algo Substitution Albax
                isForcedAlbax = (BSAccount != null && ((!isExpert && carBrandExcluded && BSAccount.ExpertSubstitutionMethod__c == 'FORCEDALBAX') || (isExpert && !hasSubstitution && BSAccount.SubstitutionMethod2__c == 'FORCEDALBAX' && carBrandExcluded))) ? true : false;
                System.debug('### isForcedAlbax>>' + isForcedAlbax);
            }    
            
           

            String assessmentID; 
            String cleanseCallerSystem = (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;
            
            System.debug('### assessNum' + assessNum);
            
            if((assessNum == null || assessNum == '')){ 

                 ///RLA 24/04/2018 C-002515 - Expert for Audatex
                if(cleanseCallerSystem == 'DEAUDATEX' && isExpert && String.isNotBlank(assessmentExtId)){                    
                    assessmentID = cleanseCallerSystem + assessmentExtId +  ' - ' +datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    assessNum =  assessmentExtId +  ' - ' +datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');                                                      
                } 

                else if(isShoppingList){
                    //C-001937 : ASE 2017/06/15
                    assessmentID = cleanseCallerSystem +  ' - ' +datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');   

                    //AMI 08/02/18 : C-002195 - Audatex Integration - ExternalId Integration
                    //                        - Update assessmentId based on external id if received
                    if(string.isNotBlank(updatedAssId)){
                        assessmentID = cleanseCallerSystem + '-' +  updatedAssId + '-' + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');   
                    }             
                }
                else{
                    //RLA 12/07/18 : C-002234 : BE - Informex Target LOT 2
                    if (isInformex) {
                        assessmentID = (cleanseCallerSystem + (assessmentExtId+refNumber)).toUpperCase();  
                        assessNum =  (assessmentExtId+refNumber).toUpperCase();   
                        String informexBSId = callerSystem +assessmentExtId;
                        
                        if(isExpert){
                            datetime qryStart = datetime.now();
                            Map<String,Assessment__c> mapAsses = clonedAssessment(informexBSId, receivedAssessMap, accRefMap,null);
                            time1 = ((datetime.now()).getTime() - qryStart.getTime());
                            time1 = (time1.divide(1000, 5));
                            
                            if (mapAsses != null){
                                isInformexExpertSucessful = true;
                                existingAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                            }
                        }
                    }//RLA 09/04/2019: C-003099: Manage duplication in ASPIS when new version is created in Audatex
                    else if (isESAudatex 
                             && String.isNotBlank(assessmentVersionNumber) 
                             && String.isNotBlank(cloneFrom)){

                        assessmentID = (cleanseCallerSystem + updatedAssId).toUpperCase();
                        //String audatexBSId = callerSystem +assessmentExtId;
                        assessNum =  updatedAssId.toUpperCase(); 
                        system.debug('## assessmentID before clone' + assessmentID);           

                        string idtoSend = cleanseCallerSystem +  assessmentExtId + '-' + cloneFrom ;
                        system.debug('## idtoSend' + idtoSend);  

                        string existingAssess = cleanseCallerSystem +  assessmentExtId + '-' + assessmentVersionNumber ;
                        system.debug('## existingAssess' + existingAssess);         

                        datetime qryStart = datetime.now();
                        Map<String,Assessment__c> mapAsses = clonedAssessment(idtoSend, receivedAssessMap, null,existingAssess);
                        existingAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                        time1 = ((datetime.now()).getTime() - qryStart.getTime());
                        time1 = (time1.divide(1000, 5));
                        
                    }
                    else if (isIG 
                             && String.isNotBlank(assessmentVersionNumber) 
                             ){
                        
                        system.debug('## here for IG' + assessmentID);           

                        assessmentID = (cleanseCallerSystem + updatedAssId).toUpperCase();
                        //String audatexBSId = callerSystem +assessmentExtId;
                        assessNum =  updatedAssId.toUpperCase(); 
                        system.debug('## assessmentID before clone' + assessmentID);           

                        string idtoSend = callerSystem +  assessmentExtId;
                        system.debug('## idtoSend' + idtoSend);  
         
                        datetime qryStart = datetime.now();
                        Map<String,Assessment__c> mapAsses = clonedAssessment(idtoSend, receivedAssessMap, null,null);
                        time1 = ((datetime.now()).getTime() - qryStart.getTime());
                        time1 = (time1.divide(1000, 5));
                        // existingAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                        
                    }
                    
                    //AMI 08/02/18 : C-002195 - Audatex Integration - ExternalId Integration
                    //                        - Update assessmentId based on external id if received
                    else if(string.isNotBlank(updatedAssId)){
                        assessmentID = (cleanseCallerSystem + updatedAssId).toUpperCase();  
                        assessNum =  updatedAssId.toUpperCase(); 
                    }                    
                    else{
                        assessmentID = (cleanseCallerSystem + claimRef + accRefNumber + assessCode + null).toUpperCase() ;  
                        assessNum =  (claimRef + accRefNumber + assessCode).toUpperCase(); 
                    }
                    
                } 
                          
                //RLA 26/09/18 : C-002234 : BE - Informex Target LOT 2

                if (!isInformexExpertSucessful){
                // create new part and perform substitution with best match and add in newOriginalMap
                    for(Object partList : (List<Object>)receivedAssessMap.get('Parts')){
                        // ASE : C-002600

                        boolean cannotSendForSubstitution = isShoppingList;
                        if (isNonAxa && isSubsAllowed){
                            cannotSendForSubstitution = false;
                        }
                        system.debug('@@ isSubsAllowed: '+isSubsAllowed);
                        system.debug('@@ cannotSendForSubstitution: '+cannotSendForSubstitution);
                        Object p = buildnewOriginalList(partList, isEligibleSubstitution, cannotSendForSubstitution,country);
                        system.debug('@@ p: '+p);
                        
                        if(p != null){
                            if(!newOriginalMap.containskey(assessmentID)){
                                List<Object> partListToReturn = new List<Object>();
                                partListToReturn.add(p);
                                newOriginalMap.put(assessmentID,  partListToReturn);
                            }
                            else{
                                newOriginalMap.get(assessmentID).add(p);
                            }   
                        }               
                    } 
                }
                

                allValidAssessMap.put(assessmentID, receivedAssessMap);   
                // ase: 18/04/18: 
                // ASE: C-002600 
                isEligibleMap.put(assessmentID, String.ValueOf(isEligibleSubstitution) + ':' + String.ValueOf(isShoppingList)); 
                   
            }
            // add in existingAssessMap to further get all parts and substitutes using assessmentId
            else{
                //C-001937 : ASE 2017/06/15  
                //AMI 08/02/18 : C-002195 - Audatex Integration - ExternalId Integration
                //                        - Update assessmentId based on external id if received
                assessmentID = string.isNotBlank(updatedAssId) ? (cleanseCallerSystem + assessNum).toUpperCase() : (cleanseCallerSystem + assessNum + null).toUpperCase(); 
                                  
                //RLA 12/07/18 : C-002234 : BE - Informex Target LOT 2
                if (isInformex){
                    //assessmentID = (cleanseCallerSystem + (assessmentExtId+refNumber)).toUpperCase();  
                    assessmentID = (cleanseCallerSystem + assessNum).toUpperCase();  
                }

                if(isShoppingList){
                    shoppingListExistAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                } 
                
                existingAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                // ASE: C-002600 
                isEligibleMap.put(assessmentID, String.ValueOf(isEligibleSubstitution) + ':' + String.ValueOf(isShoppingList)); 
                allValidAssessMap.put(assessmentID, receivedAssessMap);             
                        
            }

            //build map <AssessmentId, accountReference__c>
            if (accRefMap != null){
                assessAccountRefMap.put(assessmentID, accRefMap.get(accountRefkey));

                 //build map<assessmentId, CategoriesSet>
                 Set<String> BScategoriesSet;
                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                 String BScategories = bodyshopToReplace != null ? bodyshopToReplace.Categories__c : (BSAccount != null ?  BSAccount.Categories__c : null);
                 if(BScategories != null){
                     BScategoriesSet = new Set<String>(BScategories.split(';'));
                 }

                 assessBSCategoriesMap.put(assessmentID, BScategoriesSet);
            }
                
            //ASE: 02/03/2017: C-001885
            assessCarMap.put(assessmentID, brand + ';' + callerCarDest + ';' + catalogCarDest);

            //build map <AssessmentId, entityCode>
            assessIDEntityCodeMap.put(assessmentID, entityCode);      
                }
        
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - filterAssessment ----------------------------------');
    
        return existingAssessMap;
    }

    public static String removeSpaceHypen(String s){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - removeSpaceHypen ----------------------------------');

        s = s.replaceAll( '\\s+', '');
        s = s.replaceAll( '-', '');

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - removeSpaceHypen ----------------------------------');
        return s;
    }

    public static void retrievePartHierachy (set<String> existingAssessMapKeySet, set<String> shoppingListExistAssessKeySet, Map<String, Assessment__c> assessMap) {
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - retrievePartHierachy -------------------------------');

        // ASE 22/01/2017: case C-001828
        Set<String> bothAssessSet = new Set<String>();
        bothAssessSet.addAll(existingAssessMapKeySet);
        bothAssessSet.addAll(shoppingListExistAssessKeySet); 
             
             
        //AMI 26/01/18 : C-002189 - Informex Integration
        //                        - Adding newly created field
        for(PartList__c pl : [SELECT Alpha_Scale_MRID__c, DistributorPriceId__c, isDeleted__c, CrossReferenceId__r.IAMPartNumber__c, SelectedByBS__c, OriginalPart__c, OriginalPart__r.TECH_OriginalPart__c, OriginalPart__r.PartNumber__c, OriginalPart__r.Description__c,isSourced__c,crashCode__c,
                                     Assessment__r.AssessmentNumber__c ,Assessment__r.AssessmentId__c, Assessment__r.RecordTypeId, Description__c, Name, PartNumber__c, Price__c, ProducerName__c, Quantity__c, 
                                     RecordTypeId, Type__c , Compliance__c, InputType__c, Currency__c, Assessment__c ,InterventionCode__c,RecommendedByAS__c 
                                    ,NBHoursLabourPartLevel1__c, NBHoursLabourPartLevel2__c ,NBHoursLabourPartLevel3__c ,NBHoursLabourPainting__c
                                    ,ARCAUTOCode__c ,VAT__c , CertifyingOrganization__c, TECH_OriginalPart__c, Id, RecordType.Name, Assessment__r.CrossReferences__c,
                                     Assessment__r.callerSystem__c,Assessment__r.crashCode__c, Assessment__r.Entity__c,    Assessment__r.EntityCode__c,Assessment__r.MissionNumber__c, Assessment__r.VINCheck__c,  Assessment__r.Status__c,    Assessment__r.TECH_EntityCountryCode__c,Assessment__r.IsShoppingList__c,
                                     Assessment__r.OrderOrigin__c,   Assessment__r.PreviousStatus__c, Assessment__r.Manufacturer__c,  Assessment__r.ModelV2__c,   Assessment__r.PlateNumber2__c,  Assessment__r.FirstRegistrationDate__c, Assessment__r.VINNumber__c, Assessment__r.KMS__c,   Assessment__r.PaintingType__c,  Assessment__r.Colour__c,Assessment__r.PickupDate__c,
                                     Assessment__r.VDSCode__c,   Assessment__r.ClaimReference__c,    Assessment__r.CompanyName__c,   Assessment__r.DateOfIncident__c,    Assessment__r.RepairsAuthorised__c, Assessment__r.SupposedOfFraud__c,   Assessment__r.TotalLoss__c, Assessment__r.Fleet__c,Assessment__r.SpecialAgreement__c,  Assessment__r.QuotationAmtExlVAT__c,
                                     Assessment__r.QuotationAmountInclVAT__c,    Assessment__r.TotalAmtLabourPainting__c,    Assessment__r.TotalAmtLabour__c,    Assessment__r.TotalAmtParts__c, Assessment__r.TotalAmtPainting__c,  Assessment__r.TotalAmtExlVAT__c,    Assessment__r.TotalVAT__c,  Assessment__r.TotalAmtInclVAT__c,
                                     Assessment__r.NBHoursLabour__c, Assessment__r.NBHoursLabourLevel1__c,   Assessment__r.NBHoursLabourLevel2__c,   Assessment__r.NBHoursLabourLevel3__c, StandardMargin__c, StandardDiscount__c, Stock__c,
                                     Assessment__r.TotalAmtLabourExlPainting__c, Assessment__r.NBHoursLabourPainting__c, Assessment__r.TotalAmtPaintingInclLabour__c,Assessment__r.ExcessAmount__c,  Assessment__r.BodyShop__c,  Assessment__r.Name, Assessment__r.ParentAssessment__c, Assessment__r.ParentAssessment__r.AssessmentId__c,
                                     Deducible__c,ObsoleteRatio__c,Assessment__r.TotalObsoleteRatio__c,Assessment__r.VATPortionPayable__c,Assessment__r.TotalDeducible__c,Assessment__r.AssessmentExternalId__c,Assessment__r.AssessmentVersion__c, TECHDistList__c, Assessment__r.Feature__c, Assessment__r.TechCarBrandExcluded__c,
                                     ExternalId__c, DistributorPriceId__r.DistributorID__c,
                                     Assessment__r.ExpertSubstitutionMethod__c /*C-003418*/
                                     /*RLA 08/07/2019 C-003082*/, OriginalPart__r.ExternalId__c, Assessment__r.CapturedDistributors__c,Distributors__c/*C-003694*/,TECH_OrderedCounter__c
                              FROM PartList__c 
                              WHERE Assessment__r.AssessmentId__c in: bothAssessSet]){

            //RLA 09/07/2020 C-003857: IG - Creation IGO
             String prefixPartNumber = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);

            //RLA 13/04/2020 C-003694: IG - Sourcing                       
            capturedDistributorsGlo = String.isNotBlank(pl.Assessment__r.CapturedDistributors__c) ? pl.Assessment__r.CapturedDistributors__c : null;

            //RLa 12/11/2018 C-002234 BE - Informex Target LOT 2
            //C-003418 : NENA : bug with parent assessment
            if (String.isblank(expertSubstitutionMethod) && String.isnotBlank(pl.Assessment__r.ExpertSubstitutionMethod__c)){
                expertSubstitutionMethod = pl.Assessment__r.ExpertSubstitutionMethod__c;
            }
                
            //AMI 20/11/17 - C-002041 - Distributor V2 - populating setExistingTechOriginalPart
            if(pl.OriginalPart__c == null){
                //check if original part
                setExistingTechOriginalPart.add((pl.TECH_OriginalPart__c).toUpperCase());
            }else{
                //subtitute part
                setExistingTechOriginalPart.add((pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase());
            }

            //AMI 20/11/17 - C-002041 - Distributor V2 - populating setExistingParts
            setExistingParts.add((pl.TECH_OriginalPart__c).toUpperCase());   

            //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS            
            if (pl.TECH_OrderedCounter__c > 0 && String.isNotBlank(pl.OriginalPart__c)){                    
                setAlreadyOrderedParts.add((pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase());     
            }                  


            if(shoppingListExistAssessKeySet.contains(pl.Assessment__r.AssessmentId__c)){ 
                shoppingListExistAssessFound.add(pl.Assessment__r.AssessmentId__c); 

                assessSFDCIDMap.put(pl.Assessment__r.AssessmentId__c, pl.Assessment__c);
                              
                // AMI : Capturing existing assessment in database
                assessMap.put(pl.Assessment__r.AssessmentId__c,pl.Assessment__r);
                

            }//end shopping list

                     
            
                        
            if(pl.originalPart__c == null){
                if(pl.TECH_OriginalPart__c != null){
                    //AMI 05/02/18 - Set used to check against existing in order to delete parts to longer transmitted
                    allOriSubPartsSet.add(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase());

                    originalPartsMap.put(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase() , pl);                  
                }                 
            }
            else{               
                String subKey = pl.Assessment__r.AssessmentId__c + '-' + pl.Alpha_Scale_MRID__c + '-' + pl.Description__c.split(' - ')[0];

                if(!allAssessSubOriginalMap.containskey(subKey)){
                    allAssessSubOriginalMap.put(subKey, new set<String> {(pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase()});
                }
                else{
                    allAssessSubOriginalMap.get(subKey).add((pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase());
                }

                allsubPartsMap.put(subKey, pl);
                

                //AMI 05/02/18 - Set used to check against existing in order to delete parts to longer transmitted
                allOriSubPartsSet.add(subKey);
               
                if(!originalSubstitutesMap.containskey((pl.Assessment__r.AssessmentId__c + '-' + pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase())){
                    originalSubstitutesMap.put( pl.Assessment__r.AssessmentId__c + '-' + (pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase(), new List<PartList__c> {pl});
                }
                else{
                    originalSubstitutesMap.get(pl.Assessment__r.AssessmentId__c + '-' + (pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase()).add(pl);
                }

                if(shoppingListExistAssessKeySet.contains(pl.Assessment__r.AssessmentId__c)){
                    if(!shoppingListExistAssessFound.contains(pl.Assessment__r.AssessmentId__c)){
                        shoppingListExistAssessFound.add(pl.Assessment__r.AssessmentId__c);
                    }                                      
                }

                if(!ASCRPartNumbMap.containskey(pl.Alpha_Scale_MRID__c)){
                    ASCRPartNumbMap.put(pl.Alpha_Scale_MRID__c, pl.CrossReferenceId__r.IAMPartNumber__c);
                }  

                //RLA 09/07/2020 C-003857: IG - Creation IGO 
                if (isIG && String.isnotblank(pl.Alpha_Scale_MRID__c) && (pl.Alpha_Scale_MRID__c).startsWith(prefixPartNumber)){
                    mapOEMIdConnectedOemID.put(pl.OriginalPart__r.TECH_OriginalPart__c, pl.TECH_OriginalPart__c);
                }
            }                             
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - retrievePartHierachy ---------------------------------');
    }

    /*
        AMI 05/02/18
        This method  filters the json transmitted during second call in order to
        1) Create new parts transmitted that were not present during earlier call
        2) Set deleted boolean on existing parts that were not transmitted
        3) Raise warning alert for subs transmitted which do not belong to any existing original 
     */
    public static void filterExistingPartList(map<String , List<Object>> existingAssessMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - filterExistingPartList ----------------------------------');
        
        set<String> sentPartsSet = new set<String>();          
        
        // parts to be created
        if(existingAssessMap.size() > 0 ){
            for(String assessmentId: existingAssessMap.keyset()){

                String inExistingSubstitutes = '';            
                for (Object receivedPart : existingAssessMap.get(assessmentId)){
                    
                    Map<String, Object> receivedPartMap = (Map<String, Object>)receivedPart;
                    
                    String alphaScaleMRID               = (receivedPartMap.get('AlphaScaleMRID') != null) ? String.valueOf(receivedPartMap.get('AlphaScaleMRID')) : '';
                    String PN                           = String.valueOf(receivedPartMap.get('PartNumber'));
                    String description                  = String.valueOf(receivedPartMap.get('PartLabel'));
                    String partName                     = description.left(80);
                    String manufacturer                 = String.ValueOf(receivedPartMap.get('Manufacturer'));

                    //AMI 19/07/17 : New External Id being sent in ass request
                    string newExtId                     = String.ValueOf(receivedPartMap.get('ExternalID'));

                    if(alphaScaleMRID == ''){
                        //AMI 19/07/17 : New External Id being sent in ass request
                        String orignalKey = assessmentId + '-' + buildPartTechnicalId(assessmentId, PN, partName, manufacturer,newExtId);

                        sentPartsSet.add(orignalKey);

                        //AMI 20/11/17 - C-002041 - Distributor V2 - building setTransmittedTechOriginalPart
                        setTransmittedTechOriginalPart.add((buildPartTechnicalId(assessmentId, PN, partName, manufacturer,newExtId)).toUpperCase());

                        if(originalSubstitutesMap.get(orignalKey) != null){
                            for(PartList__c substitute : originalSubstitutesMap.get(orignalKey)){
                                String substituteKey = substitute.Assessment__r.AssessmentId__c + '-' + substitute.Alpha_Scale_MRID__c + '-' + substitute.Description__c.split(' - ')[0]; 
                                sentPartsSet.add(substituteKey);
                            }                                                                              
                        }                                           

                        if(!originalPartsMap.containsKey(orignalKey)){
                            //create new part and perform substitution with best match
                            if (isEligibleMap.containskey(assessmentId)){
                                list<String> booleanList = isEligibleMap.get(assessmentId).split(':');
                                //ASE : C-002600]
                                boolean sendForSubstitution = Boolean.ValueOf(booleanList[1]);
                                if (isNonAxa && isSubsAllowed){
                                    sendForSubstitution = false;
                                }
                                system.debug('####sendForSubstitution'+sendForSubstitution);
                                
                                Object p = buildnewOriginalList(receivedPart, Boolean.ValueOf(booleanList[0]),sendForSubstitution,country );
                                if(p != null){
                                    if(!newOriginalMap.containskey(assessmentID)){
                                        List<Object> partListToReturn = new List<Object>();
                                        partListToReturn.add(p);
                                        newOriginalMap.put(assessmentID,  partListToReturn);
                                    }
                                    else{
                                        newOriginalMap.get(assessmentID).add(p);
                                    }   
                                } 
                            }                      
                        }                        
                    }
                    else{

                        String substituteKey = assessmentID + '-' + alphaScaleMRID + '-' + description.split(' - ')[0]; 
                        //AMI 05/02/18 : Raise warning for subs transmitted that do not have any orginal
                        if(!allAssessSubOriginalMap.containsKey(substituteKey)){
                            inExistingSubstitutes += PN  + ','; 
                        }

                        // ASE : 13/12/16 : adding description to key to differentiate b/w substitutes                    
                        assessSubstituteMap.put(substituteKey, receivedPart);

                        sentPartsSet.add(substituteKey); 
                        
                        //AMI 20/11/17 - C-002041 - Distributor V2 - building setTransmittedTechOriginalPart
                        //AMI 14/02/18 - C-002041 - Distributor V2 - updating key for subs to track parts transmitted in second call
                        //                                         - ASCR and ASP should be in same format except MRID will be different 
                        string tempKey;
                        if(newExtId == null){
                            if(allSubPartsMap.containsKey(substituteKey)){
                                tempKey = allSubPartsMap.get(substituteKey).TECH_OriginalPart__c;
                            }
                        }
                        else{
                            tempKey = assessmentID + '-' + newExtId + '-' + alphaScaleMRID;
                        }
                        
                        if (String.isNotBlank(tempKey)){
                            setTransmittedTechOriginalPart.add(tempKey.toUpperCase());
                        }
                        if(allAssessSubOriginalMap.get(substituteKey) != null){
                            for(String original : allAssessSubOriginalMap.get(substituteKey)){                                
                                sentPartsSet.add(assessmentId + '-' +original);
                                for(PartList__c otherSub : originalSubstitutesMap.get(assessmentId + '-' +original)){
                                    String otherSubKey = otherSub.Assessment__r.AssessmentId__c + '-' + otherSub.Alpha_Scale_MRID__c + '-' + otherSub.Description__c.split(' - ')[0];                                 
                                    sentPartsSet.add(otherSubKey);                                
                                }                        
                            }                                                                                  
                        }
                    } 
                }

                if(inExistingSubstitutes != ''){
                    //AMI 06/07/2017 - Adding warning message exception handling 
                    mapWarningCreation.put('Assessment ID ' + assessmentID + 'do not contain substitutes: ', inExistingSubstitutes);              
                }
            }     
        }


        // loop in existing original parts only. Substitutes cannot exist without original.
        if(allOriSubPartsSet.size() > 0){
            for(String key : allOriSubPartsSet){
                if(!sentPartsSet.contains(key)){   
                    if(originalPartsMap.containskey(key)){
                        partsToDelSet.add(originalPartsMap.get(key).TECH_OriginalPart__c);
                        if(originalSubstitutesMap.get(key) != null){
                            for(PartList__c substitute : originalSubstitutesMap.get(key)){
                                partsToDelSet.add(substitute.TECH_OriginalPart__c);
                            }                                                                              
                        }                         
                    }
                    else{
                        if(allsubPartsMap.containsKey(key)){
                            partsToDelSet.add(allsubPartsMap.get(key).TECH_OriginalPart__c);
                            if(allAssessSubOriginalMap.get(key) != null){
                                for(String original : allAssessSubOriginalMap.get(key)){
                                    partsToDelSet.add(original);
                                }                                                                                  
                            }
                        }
                    }
                }                    
            }                    
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - filterExistingPartList ----------------------------------');
    }

    // method that build part.TECH_OriginalPart__c of the received assessments
    //AMI 19/07/17 : New External Id being sent in ass request
    public static String buildPartTechnicalId(String assessmentId, String partNumber, String partLabel, String manufacturer, string extId){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - buildPartTechnicalId ----------------------------------');

        String partExternalId   = '';

        if(string.isNotBlank(extId)){
            partExternalId  = assessmentId + '-' + extId;
        }else{
            partExternalId  = null + '-' 
                            + partNumber + '-' 
                            + partLabel.replaceAll('\\s+', '') + '-' 
                            + manufacturer + '-' 
                            + assessmentId + '-' 
                            + null;
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - buildPartTechnicalId ----------------------------------');
        return partExternalId.toUpperCase();
    }

    /*
        AMI 05/02/18
        This method will filter original parts to be created based on recordtype, inputtype, 
        isEligibleSubstitution, isShoppingList and carBrandExcluded
     */
    public static Object buildnewOriginalList (Object receivedPart, Boolean isEligibleSubstitution, Boolean isShoppingList,String theCountry){
        System.debug('----------------------- START RESTUpsertAssessmentV2 - buildPartToBeSubstitutedList -------------------------------');
        
        Map<String, Object> receivedPartMap = (Map<String, Object>) receivedPart;

        String recordType                   = String.valueOf(receivedPartMap.get('RecordType'));
        String inputType                    = String.valueOf(receivedPartMap.get('InputType'));
        CountryCodeInformationsMapping__c currentCountryCodeMapping = CountryCodeInformationsMapping__c.getAll().containsKey(String.isBlank(theCountry)?'XXX':theCountry)? CountryCodeInformationsMapping__c.getAll().get(theCountry):CountryCodeInformationsMapping__c.getAll().get('DEFAULT') ;
        //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
        String partLabel = string.isBlank(receivedPartMap.containsKey('PartLabel')?String.valueOf(receivedPartMap.get('PartLabel')):'XXX')? currentCountryCodeMapping.PartLabelEmptyText__c:(receivedPartMap.containsKey('PartLabel') ?String.valueOf(receivedPartMap.get('PartLabel')) : '');
        partLabel = partLabel.toUpperCase();
        Boolean allowSubs = true;
        if (callersystemGlo == 'FR_DIVA'
            && String.isnotBlank(system.label.DescriptionWithNoSubstitute)
            && partLabel.contains(system.label.DescriptionWithNoSubstitute)
            ){  
            allowSubs = false;
        }
        

        // parts having record type 'labour' and inputType 'manual' do not require substitution
        // ASE : C-002600
        //if(recordType.toUpperCase() !='LABOUR' && inputType.toUpperCase()  != 'MANUAL' && isEligibleSubstitution && !isShoppingList && !carBrandExcluded){
        //Bodyshop account : FORCED && Bodyshop is eligible for substitution && brand is an excluded brand on the B/S  => no substitution
        //RLA 30/07/2019 C-003344: Substitutes manual Parts for Italy       
        //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
        if(recordType.toUpperCase() !='LABOUR' && (inputType.toUpperCase()  != 'MANUAL'|| 
        (inputType.toUpperCase()  == 'MANUAL' && isManualPartsAllowedforSubs)) && isEligibleSubstitution && (!isShoppingList) && !(isBSForced && carBrandExcluded) && allowSubs){
            return receivedPart;
        }
        else{
            return null;
        }       
    }

    public static Map<String, Map<String, List<Object>>> buildSubstitutionMap(Map<String, list<Object>> originalMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - buildSubstitutionMap ----------------------------------');


        Map<String, Map<String, List<Object>>> mapEntitymapAsslistParts = new Map<String, Map<String, List<Object>>>();
      
        for(String assessmentID: originalMap.keySet()){
            List<Object> receivedPartList = originalMap.get(assessmentID);
            //ASE: 02/03/2017: C-001885
            String crossRefbrand = assessCarMap.get(assessmentID).split(';')[2];

            //C-001937
            String techCountryCode = assessmentID.left(2);

            String entityCode    = '';

            String langCode = techCountryCode;

            //RLA 20/02/2018 case 2370 BE Issues

             if(techCountryCode == 'BE'){
                //C-002692 : ASE 27/09/2018*/
                langCode = 'FR';
                if(assessIDEntityCodeMap.get(assessmentID) != 'NONAXA'){
                    entityCode =  'BEAXA';  
                }              
            }
            else{
                //set entity code
                entityCode = techCountryCode + assessIDEntityCodeMap.get(assessmentID);
            }

            if(mapEntitymapAsslistParts.containsKey(entityCode)){
                //C-002692 : ASE 27/09/2018*/
                //mapEntitymapAsslistParts.get(entityCode).put(assessmentID + '-' + crossRefbrand + '-' + techCountryCode, receivedPartList);
                mapEntitymapAsslistParts.get(entityCode).put(assessmentID + '-' + crossRefbrand + '-' + techCountryCode + '-' + langCode , receivedPartList);
            }
            else{
                //mapEntitymapAsslistParts.put(entityCode, new Map<String, List<Object>> {assessmentID + '-' + crossRefbrand + '-' + techCountryCode => receivedPartList});
                mapEntitymapAsslistParts.put(entityCode, new Map<String, List<Object>> {assessmentID + '-' + crossRefbrand + '-' + techCountryCode + '-' + langCode => receivedPartList});
            }           
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - buildSubstitutionMap ----------------------------------');
        return mapEntitymapAsslistParts;
    }

    public static void processValidAssess(
        Map<String, Map<String, Object>> validAssessMap, 
        Map<String, ASPISServiceSubstitution.SubstituteWrapper> mapEntitySubstituteWrapper, 
        List<Assessment__c> newAssessmentList, 
        List<PartList__c> newPartList, 
        Map<String, List<PartList__c>> assessIdPartsMap, 
        Map<String, List<PartList__c>> assessSubstituteListMap, 
        Map<String, Assessment__c> assessMap, 
        Map<String, List<CrossReference__c>> OEMIAMMap, 
        Map<String, CrossReference__c> OEMIAMPriceMap, 
        set<String> existingAssessMapKeySet,  
        Map<String, List<Object>> shoppingListExistAssessMap, 
        Map<String, List<PartList__c>> shopAssessIdPartsMap){
        
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - processValidAssess ----------------------------------');

        //AMI 05/02/18 : validAssessMap ==> build in filter assessment method (whether or not assessment number is transmitted)
        for(String assessmentID: validAssessMap.keySet()){
            Map<String, Object> receivedAssessMap               = validAssessMap.get(assessmentID);
            
            
            String techCountryCode = assessmentID.left(2);

            String entityCode = (receivedAssessMap.get('EntityCode') != null && receivedAssessMap.get('EntityCode') != '') ? String.valueOf(receivedAssessMap.get('EntityCode')) : system.label.EntityCodeDefaultValue;    


            if(techCountryCode == 'BE' && assessIDEntityCodeMap.get(assessmentID) != 'NONAXA'){
                entityCode =  'AXA';                
            }      
             
            String recordType = 'Claim';
            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;
            String assNumber = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf( receivedAssessMap.get('AssessmentNumber')) : 'none';          
            Assessment__c claimAssess,assess;

            //AMI 25/01/18 : C-002195 - Audatex Integration
            //                        - Creating new variable to store the "NBWorkingUnit","AssessmentExternalID","AssessmentVersion" received in the currentClaim section 
            map <string,Object> currentClaim = receivedAssessMap.get('currentClaim') != null ? (map <string,Object>)receivedAssessMap.get('currentClaim') : new map <string,Object>();
            
            NBWrkingUnit = (currentClaim.containsKey('NBWorkingUnit')) ? string.valueOf(currentClaim.get('NBWorkingUnit')) : '';

            if(!shoppingListExistAssessMap.containsKey(assessmentID)){
                assess = createAssessment(assessmentID, receivedAssessMap, recordType, OEMIAMMap);  
                newAssessmentList.add(assess);            
            } 
            else{
                assess = assessMap.get(assessmentID);
            }    

            encode = techCountryCode + entityCode;
             
            
            // create partList
            List<PartList__c> newPList                  = new List<PartList__c>();
            List<PartList__c> newSList                  = new List<PartList__c>();
            List<PartList__c> newSubsList               = new List<PartList__c>();
            Map<String, PartList__c> newPartMap         = new Map<String, PartList__c>();
            Map<String, List<String>> newPartDescMap    = new Map<String, List<String>>();

            if(assess != null){
                createPartList(assess.AssessmentID__c,
                               assess.IsShoppingList__c,
                               (List<Object>) receivedAssessMap.get('Parts'),
                               newPList,
                               newPartMap,
                               newPartDescMap,
                               recordType,
                               existingAssessMapKeySet,
                               OEMIAMMap,
                               shopAssessIdPartsMap,
                               shoppingListExistAssessMap.keyset(),
                               assess.BodyShop__c,
                               assess.TECH_EntityCountryCode__c + assess.EntityCode__c,
                               assess.TechCarBrandExcluded__c,
                               OEMIAMPriceMap,
                               techCountryCode
                            ); 
                newPartList.addAll(newPList);
                
                //RLA 02/03/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
                newPartDescMapGlo.putAll(newPartDescMap);
                newPartMapGlo.putAll(newPartMap);

            
                if(!assess.IsShoppingList__c || (isnonAxa && isSubsAllowed)){
                    

                    if(mapEntitySubstituteWrapper != null &&
                        mapEntitySubstituteWrapper.containsKey(techCountryCode + entityCode)){
                        //DUN 12/09/2016 MasterRule Updated(added entity code as parameter)
                        newSList = createSubstitute( assess.AssessmentID__c, 
                                                    mapEntitySubstituteWrapper.get(techCountryCode + entityCode).mapAssmapOEMKeylistIAM.get(assess.AssessmentID__c), 
                                                    // C-002600: mapEntitySubstituteWrapper.get(techCountryCode + entityCode).mapAssessmentIAMfinal.get(assess.AssessmentID__c), 
                                                    OEMIAMPriceMap,
                                                    mapEntitySubstituteWrapper.get(techCountryCode + entityCode).listUpdateFieldsCriteria,
                                                    newPartMap,
                                                    newPartDescMap,
                                                    techCountryCode + entityCode,
                                                    assess.TechCarBrandExcluded__c);
                        
                        newSubsList.addAll(newSList);
                    }
                    else{
                        //DUN 12/09/2016 MasterRule Updated(added entity code as parameter)
                        newSList = createSubstitute(    assess.AssessmentID__c, 
                                                        null, 
                                                        null, 
                                                        null,
                                                        newPartMap,
                                                        newPartDescMap,
                                                        techCountryCode + entityCode,
                                                        assess.TechCarBrandExcluded__c);
                        
                        newSubsList.addAll(newSList);
                    }
                }
                system.debug('newSubsList>>'+newSubsList);
                 // build Map<assessmentNumber, Assessment__c>
                if(!assessMap.containskey(assess.AssessmentID__c)){
                    assessMap.put(assess.AssessmentID__c, assess);
                }

                if(!newPList.isEmpty()){
                    assessIdPartsMap.put(assess.AssessmentID__c, newPList);       
                }

                if(!newSubsList.isEmpty()){ 
                    assessSubstituteListMap.put(assess.AssessmentID__c, newSubsList);             
                }
            }
            else{
                mapErrorsCreation.put('AssessmentID / Assessment Number not found: ', assessmentID + ' / ' +assNumber);      
            }
            system.debug('@@ mapErrorsCreation: '+mapErrorsCreation);
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - processValidAssess ----------------------------------');
    }

    public static Assessment__c createAssessment(String assessId, Map<String, Object> receivedAssessMap, String recordType, Map<String, List<CrossReference__c>> OEMIAMMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - createAssessment ----------------------------------');

        // build currentAssetMap
        Map<String, Object> currentAssetMap;
        if(receivedAssessMap.get('currentAsset') != null){
            currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');
        }

        // build currentClaimMap
        Map<String, Object> currentClaimMap;
        if(receivedAssessMap.get('currentClaim') != null){
            currentClaimMap = (Map<String, Object>) receivedAssessMap.get('currentClaim');
        }

        Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;  

        String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;

        //AMI 25/10/17 : C-002041 - Distributor V2
        //updating PreviousStatus__c to prevent workflow from setting status to ready
        Assessment__c newAssessment = new Assessment__c( callerSystem__c            = String.valueOf(receivedAssessMap.get('callerSystem'))
                                                        ,Entity__c                  = String.valueOf(receivedAssessMap.get('Entity'))
                                                        ,EntityCode__c              = (receivedAssessMap.get('EntityCode') != null && receivedAssessMap.get('EntityCode') != '') ? String.valueOf(receivedAssessMap.get('EntityCode')) : system.label.EntityCodeDefaultValue
                                                        ,MissionNumber__c           = String.valueOf(receivedAssessMap.get('MissionNumber'))
                                                        ,VINCheck__c                = Integer.valueOf(receivedAssessMap.get('VINCheck'))
                                                        ,Status__c                  = 'NEW'
                                                        ,TECH_EntityCountryCode__c  = assessId.left(2)
                                                        ,RecordTypeId               = recordTypeAssessTypeMap.get(recordType)
                                                        ,IsShoppingList__c          = isShoppingList 
                                                        ,OrderOrigin__c             = 'Upsert'   
                                                        ,PreviousStatus__c          = 'DoNotExecuteWF'   
                                                        ,HasBeenSubstituted__c      = (OEMIAMMap.size() > 0) ? true : false
                                                        ,SourceFailure__c = ''
                                                        ,ReasonFailure__c = ''  

                                                        ////
                                                        //AMI 15/02/18 - C-002041 - Distributor V2 - Setting Cross Reference field to none since query for master
                                                        //                                         - rule resulted in error during sourcing
                                                        //                                         - (CrossReference__r.Name IN ('') AND DistributorID__r.DistributorRegionsCovered__c INCLUDES ('12') AND Active__c = TRUE)  
                                                        ,CrossReferences__c = 'None'
                                                        // C-002600: field populated for MR Substitution
                                                        ,TechCarBrandExcluded__c = carBrandExcluded   
                                                        //RLA 13/10/2020 new IG Changes
                                                        ,substitutiontype__c = substitutiontype
                                                        //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                                                        , SourcedAsBodyshop__c = bodyshopToReplace != null ? bodyshopToReplace.Id : null
                                                        //RLA 23/02/2021 Do not link Expert Assessment to BS if from createToUpsert
                                                        , isFromR3__c = isFromR3 ? true : false
                                                        , R3_Assessment__c = newAssessmentR3  //NPE 14/12/2021: C-004540
                                                    );
        system.debug('%% CrossReferences__c'+newAssessment.CrossReferences__c);

        //RLA 09/04/2020 : C-003693: IG - Substitution
        newAssessment.InsuranceBroker__c = (receivedAssessMap.containsKey('InsuranceBroker')) ? (string)receivedAssessMap.get('InsuranceBroker') : '';

        if (String.isnotBlank(newAssessment.InsuranceBroker__c)){
            if (system.label.InsBrokerName.contains(newAssessment.InsuranceBroker__c)){
                isIG = true;
            }
        }

        //AMI 22/02/2018 : C-002041 - Distributor V2 - Adding eligibilty process for all countries except france
        //                          - populate assCountry
        assCountry = assessId.left(2);

        if(currentAssetMap != null){
            //ASE: 02/03/2017: C-001885
            //newAssessment.Manufacturer__c   = assessCarMap.get(assessId).CarCrossRef__c;
            list<String> assessCarMapList=  assessCarMap.get(assessId).split(';');
            newAssessment.Manufacturer__c   = assessCarMapList[1] != 'null' ? assessCarMapList[1]: assessCarMapList[0];
            newAssessment.ModelV2__c        = String.valueOf(currentAssetMap.get('Model'));
            String PlateNumber = String.valueOf(currentAssetMap.get('PlateNumber'));
            newAssessment.PlateNumber2__c   = (PlateNumber != null) ? removeSpaceHypen(PlateNumber) : PlateNumber ;

            if( currentAssetMap.get('FirstRegistrationDate') != null && 
                !String.isBlank(String.valueOf(currentAssetMap.get('FirstRegistrationDate')))){
                newAssessment.FirstRegistrationDate__c = (Date) JSON.deserialize('"' + currentAssetMap.get('FirstRegistrationDate') + '"', Date.class);
            }

            newAssessment.VINNumber__c      = String.valueOf(currentAssetMap.get('VINNumber'));
            newAssessment.KMS__c            = currentAssetMap.get('KMS') != null ? Integer.valueOf(currentAssetMap.get('KMS')) : null;
            newAssessment.PaintingType__c   = String.valueOf(currentAssetMap.get('PaintingType'));
            newAssessment.Colour__c         = String.valueOf(currentAssetMap.get('Colour'));
            newAssessment.PickupDate__c     = (currentAssetMap.get('PickupDate') != null && !String.isBlank(String.valueOf(currentAssetMap.get('PickupDate')))) ? (DateTime) JSON.deserialize('"' + currentAssetMap.get('PickupDate') + '"', DateTime.class) : null;
            newAssessment.VDSCode__c        = String.valueOf(currentAssetMap.get('VDSCode'));
        }

        if(currentClaimMap != null){
            //RLA 22/02/18 : C-002195 - Audatex Integration 
            //                        - if AssessmentExternalId is being transmitted, do not store ClaimReference
            newAssessment.ClaimReference__c             = currentClaimMap.containsKey(('ClaimReference')) ? String.valueOf(currentClaimMap.get('ClaimReference')) : null;
            newAssessment.CompanyName__c                = String.valueOf(currentClaimMap.get('CompanyName'));

            if(currentClaimMap.get('DateOfIncident') != null && !String.isBlank(String.valueOf(currentClaimMap.get('DateOfIncident')))){
                newAssessment.DateOfIncident__c         = (Date) JSON.deserialize('"' + currentClaimMap.get('DateOfIncident') + '"', Date.class);
            }

            newAssessment.RepairsAuthorised__c          = (currentClaimMap.get('RepairsAuthorised') != null) ? Boolean.valueOf(currentClaimMap.get('RepairsAuthorised')) : false;
            newAssessment.SupposedOfFraud__c            = (currentClaimMap.get('Fraud') != null) ? Boolean.valueOf(currentClaimMap.get('Fraud')) : false;
            newAssessment.TotalLoss__c                  = (currentClaimMap.get('TotalLoss') != null) ? Boolean.valueOf(currentClaimMap.get('TotalLoss')) : false;
            newAssessment.Fleet__c                      = (currentClaimMap.get('Fleet') != null) ? Boolean.valueOf(currentClaimMap.get('Fleet')) : false;
            newAssessment.SpecialAgreement__c           = (currentClaimMap.get('SpecialAgreement') != null) ? Boolean.valueOf(currentClaimMap.get('SpecialAgreement')) : false;
            newAssessment.QuotationAmtExlVAT__c         = (currentClaimMap.get('QuotationAmountExlVAT') != null) ? Double.valueOf(currentClaimMap.get('QuotationAmountExlVAT')) : null;
            newAssessment.QuotationAmountInclVAT__c     = (currentClaimMap.get('QuotationAmountInclVAT') != null) ? Double.valueOf(currentClaimMap.get('QuotationAmountInclVAT')) : null;
            newAssessment.TotalAmtLabourPainting__c     = (currentClaimMap.get('TotalAmtLabourPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabourPainting')) : null;
            newAssessment.TotalAmtLabour__c             = (currentClaimMap.get('TotalAmtLabour') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabour')) : null;
            newAssessment.TotalAmtParts__c              = (currentClaimMap.get('TotalAmtParts') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtParts')) : null;
            newAssessment.TotalAmtPainting__c           = (currentClaimMap.get('TotalAmtPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtPainting')) : null;
            newAssessment.TotalAmtExlVAT__c             = (currentClaimMap.get('TotalAmtExlVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtExlVAT')) : null;
            newAssessment.TotalVAT__c                   = (currentClaimMap.get('TotalVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalVAT')) : null;
            newAssessment.TotalAmtInclVAT__c            = (currentClaimMap.get('TotalAmtInclVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtInclVAT')) : null;
            newAssessment.NBHoursLabour__c              = (currentClaimMap.get('NBHoursLabour') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabour')) : null;
            newAssessment.NBHoursLabourLevel1__c        = (currentClaimMap.get('NBHoursLabourLevel1') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel1')) : null;
            newAssessment.NBHoursLabourLevel2__c        = (currentClaimMap.get('NBHoursLabourLevel2') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel2')) : null;
            newAssessment.NBHoursLabourLevel3__c        = (currentClaimMap.get('NBHoursLabourLevel3') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel3')) : null;
            newAssessment.TotalAmtLabourExlPainting__c  = (currentClaimMap.get('TotalAmtLabourExlPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabourExlPainting')) : null;
            newAssessment.NBHoursLabourPainting__c      = (currentClaimMap.get('NBHoursLabourPainting') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourPainting')) : null;
            newAssessment.TotalAmtPaintingInclLabour__c = (currentClaimMap.get('TotalAmtPaintingInclLabour') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtPaintingInclLabour')) : null;
            newAssessment.ExcessAmount__c               = (currentClaimMap.get('ExcessAmount') != null) ? Double.valueOf(currentClaimMap.get('ExcessAmount')) : null;
       
            //AMI 25/01/18 : C-002195 - Audatex Integration
            //                        - saving externalid/version number
            newAssessment.AssessmentExternalId__c       = (currentClaimMap.containsKey('AssessmentExternalID')) ? (string)currentClaimMap.get('AssessmentExternalID') : '';
            newAssessment.AssessmentVersion__c          = (currentClaimMap.containsKey('AssessmentVersion')) ? integer.valueOf(currentClaimMap.get('AssessmentVersion')) : null;

            //AMI 26/01/18 : C-002189 - Informex Integration
            //                        - saving newly created field
            newAssessment.TotalObsoleteRatio__c         = (currentClaimMap.get('TotalObsoleteRatio') != null) ? Double.valueOf(currentClaimMap.get('TotalObsoleteRatio')) : null;
            newAssessment.VATPortionPayable__c          = (currentClaimMap.get('VAT') != null) ? Double.valueOf(currentClaimMap.get('VAT')) : null;
            newAssessment.TotalDeducible__c             = (currentClaimMap.get('TotalDeducible') != null) ? Double.valueOf(currentClaimMap.get('TotalDeducible')) : null;
        
            //RLA 09/04/2020 : C-003693: IG - Substitution
            if (currentClaimMap.containsKey('InsBrokerNumber')){
                newAssessment.InsBrokerNumber__c = (String) currentClaimMap.get('InsBrokerNumber');
            }
        }
        if (assessAccountRefMap.get(assessId) != null){
            //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
            newAssessment.BodyShop__c   = assessAccountRefMap.get(assessId).InternalReference__c;
            //ASE 19/03/2018: si l'account expert IT forced, assessment expert= forced
            if(accountForced){
                traceVariables += '#update 2 for IT: Forced# ';
                newAssessment.ExpertSubstitutionMethod__c = 'FORCED';
            }      

            /*C-002278 : ASE 30/03/2018
            if(newAssessment.Manufacturer__c == 'PEUGEOT' || newAssessment.Manufacturer__c == 'CITROEN' || newAssessment.Manufacturer__c == 'DS'){
                if(bsRefAccountMap.containsKey(newAssessment.BodyShop__c) 
                    && (bsRefAccountMap.get(newAssessment.BodyShop__c).Feature__c) != null
                    &&  (bsRefAccountMap.get(newAssessment.BodyShop__c).Feature__c).contains('PilotPSA')){
                   newAssessment.Feature__c = 'PilotPSA' ;
                }                
            }  */    

            // ASE 17/09/2018: C-002600 : populate ExpertSubstitutionMethod__c on standard BS Assessment
            if(bsRefAccountMap.get(newAssessment.BodyShop__c) != null){
                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                Account BS = bodyshopToReplace != null ? bodyshopToReplace : bsRefAccountMap.get(newAssessment.BodyShop__c);
                
                if(!isExpert && BS.ExpertSubstitutionMethod__c != null){
                    if(BS.ExpertSubstitutionMethod__c == 'FORCED NO A\'' && !carBrandExcluded){
                        newAssessment.ExpertSubstitutionMethod__c = 'FORCED';
                    }
                    else{
                        newAssessment.ExpertSubstitutionMethod__c = BS.ExpertSubstitutionMethod__c;
                    }
                }            
                else if(isExpert && !hasSubstitution && BS.SubstitutionMethod2__c != null){
                    newAssessment.ExpertSubstitutionMethod__c = BS.SubstitutionMethod2__c; 
                } 
                // if (newAssessment.ExpertSubstitutionMethod__c != null){
                    traceVariables += '# update 3 isExpert:'+isExpert + ' ,hasSubstitution: '+hasSubstitution + ' ,BS.ExpertSubstitutionMethod__c: ' + BS.ExpertSubstitutionMethod__c + ' ,BS.SubstitutionMethod2__c: '+BS.SubstitutionMethod2__c + ' ,final value for ExpertSubstitutionMethod__c of assess: ' + newAssessment.ExpertSubstitutionMethod__c + '#' ;
                // }
                system.debug('@@@ newAssessment.ExpertSubstitutionMethod__c: '+newAssessment.ExpertSubstitutionMethod__c);
            }           
        }
        
        String refNumber = (newAssessment.BodyShop__c !=null) ? ((bsRefAccountMap.get(newAssessment.BodyShop__c)!= null) ? bsRefAccountMap.get(newAssessment.BodyShop__c).ReferenceNumber__c : null) : null;
        String assessCode = (newAssessment.PlateNumber2__c != null) ? newAssessment.PlateNumber2__c : newAssessment.VINNumber__c; 
        String assessCodeName = (newAssessment.PlateNumber2__c != null) ? newAssessment.PlateNumber2__c.left(5) : newAssessment.VINNumber__c; 
        
         
        newAssessment.Name =  (newAssessment.ClaimReference__c != null ? newAssessment.ClaimReference__c : '') + (assessCodeName != null ? assessCodeName : '');
        
        //if (newAssessment.AssessmentExternalId__c != null || newAssessment.AssessmentExternalId__c != ''){
            //   newAssessment.Name =  newAssessment.AssessmentExternalId__c;
        //}
        
        //newAssessment.Name = newAssessment.Name != null ? (newAssessment.Name).toUpperCase(): '';
        
        //AMI 08/02/18 - C-002195 - Audatex Integration - ExternalId Integration
        //                        - Build updated external id
        string updatedAssNum = string.isNotBlank(newAssessment.AssessmentExternalId__c) ? 
                                    (newAssessment.AssessmentVersion__c != null ? 
                                        newAssessment.AssessmentExternalId__c + '-' + string.valueOf(newAssessment.AssessmentVersion__c) : 
                                        newAssessment.AssessmentExternalId__c) : '';

        //AMI 08/02/18 - C-002195 - Audatex Integration - ExternalId Integration
        //                        - Update assessment number if externalid is transmitted
        newAssessment.AssessmentID__c  = assessId;
        
        if (assessNum == null ||  assessNum == ''){
            //RLA 12/07/18 : C-002234 : BE - Informex Target LOT 2
            if (isInformex){        
                newAssessment.AssessmentNumber__c =  newAssessment.AssessmentExternalId__c +  String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');
            }
            else{
                newAssessment.AssessmentNumber__c   = string.isBlank(newAssessment.AssessmentExternalId__c) ? (newAssessment.ClaimReference__c + refNumber + assessCode).toUpperCase() :  (updatedAssNum).toUpperCase() ; 
            }
        } else {
            newAssessment.AssessmentNumber__c = assessNum;
        }

        if (isESAudatex){
            newAssessment.AssessmentExtIdCallerSystem__c = string.isNotBlank(newAssessment.AssessmentExternalId__c) ? 
                                                            (newAssessment.AssessmentVersion__c != null ? 
                                                            newAssessment.CallerSystem__c +newAssessment.AssessmentExternalId__c + '-' + string.valueOf(newAssessment.AssessmentVersion__c) : 
                                                            newAssessment.CallerSystem__c + newAssessment.AssessmentExternalId__c) : '';
        }
        else{
            newAssessment.AssessmentExtIdCallerSystem__c = newAssessment.CallerSystem__c + newAssessment.AssessmentExternalId__c;
        }
        // if name is null, display assessmentNumber. else Name is displayed as ID.
        //newAssessment.Name = newAssessment.Name != null ? (newAssessment.Name).toUpperCase(): (newAssessment.AssessmentNumber__c).toUpperCase();
        newAssessment.Name = newAssessment.AssessmentNumber__c.toUpperCase();
        newAssessment.AlreadyQuoted__c = false;//VSU 05/12/17

        //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
        if (newAssessment.TECH_EntityCountryCode__c == 'ES'){
            if(bsRefAccountMap.containsKey(newAssessment.BodyShop__c)){ 
                if((bsRefAccountMap.get(newAssessment.BodyShop__c).OrderFromAT__c) == true){
                    newAssessment.OrderAuthorised__c = true;
                }                
            }
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - createAssessment ----------------------------------');
        return newAssessment;
    }

    public static void createPartList(
        String externalId, 
        Boolean shoppingList, 
        List<Object> partList, 
        List<PartList__c> newPartList, 
        Map<String, PartList__c> newPartMap, 
        Map<String, List<String>> newPartDescMap, 
        String recordtype, 
        set<String> existingAssessMapKeySet, 
        Map<String, List<CrossReference__c>> OEMIAMMap, 
        Map<String, List<PartList__c>> shopAssessIdPartsMap, 
        set<String> shoppingListExistAssessKey, 
        Id bodyShopId, 
        String entityCode,
        Boolean TechCarBrandExcluded,
        Map<String, CrossReference__c> OEMIAMPriceMap,
        String theCountryCode){

        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - createPartList ----------------------------------');
           
        //ASE: 02/03/2017: C-001885     
        String crossRefBrand = assessCarMap.get(externalId).split(';')[2];
        CountryCodeInformationsMapping__c currentCountryCodeMapping = CountryCodeInformationsMapping__c.getAll().containsKey(String.isBlank(theCountryCode)?'XXX':theCountryCode)? CountryCodeInformationsMapping__c.getAll().get(theCountryCode):CountryCodeInformationsMapping__c.getAll().get('DEFAULT') ;
        
        // loop in partList and assign assessement__c to ExternalId
        // even parts not existing in Cross reference are created here.
        for(Object part: partList){
            Map<String, Object> partListMap = (Map<String, Object>) part;

            String partNumber       = String.valueOf(partListMap.get('PartNumber'));                     
            String partDescription  = String.isblank(String.valueOf(partListMap.get('PartLabel'))) ? currentCountryCodeMapping.PartLabelEmptyText__c : String.valueOf(partListMap.get('PartLabel'));
            String partLabel        = partDescription.left(80);
            String alphaScaleMRID   = (partListMap.get('AlphaScaleMRID') != null) ? String.valueOf(partListMap.get('AlphaScaleMRID')) : '';
            Boolean isSelected      = (partListMap.get('IsSelected') != null) ? Boolean.valueOf(partListMap.get('IsSelected')) : false;
            String manufacturer     = String.ValueOf(partListMap.get('Manufacturer'));

            //AMI 19/07/17 : New External Id being sent in ass request
            string newExtId         = String.ValueOf(partListMap.get('ExternalID'));

            //AMI 19/07/17 : New External Id being sent in ass request
            String partExternalId   = '';
            if(string.isNotBlank(newExtId)){
                partExternalId = (externalId + '-' + newExtId).toUpperCase();
            }else{
                partExternalId  = (null + '-' 
                                + partNumber + '-' 
                                + partLabel.replaceAll('\\s+', '') + '-' 
                                + manufacturer + '-' 
                                + externalId + '-' 
                                + null).toUpperCase();
            }

            Integer quantity    = Integer.ValueOf(partListMap.get('Quantity'));

            PartList__c newPart;

            integer crash        = (partListMap.get('crashCode') != null && partListMap.get('crashCode') != '') ? integer.ValueOf(partListMap.get('crashCode')) : null;

            //AMI 25/01/18 : C-002195 - Audatex Integration
            //                        - fetching NBWorkingUnitLevel1,NBWorkingUnitLevel2 and NBWorkingUnitLevel3 
            decimal NBWorkingUnitLevel1 = (partListMap.get('NBWorkingUnitLevel1') != null) ? (decimal)(partListMap.get('NBWorkingUnitLevel1')) : 0.0;
            decimal NBWorkingUnitLevel2 = (partListMap.get('NBWorkingUnitLevel2') != null) ? (decimal)(partListMap.get('NBWorkingUnitLevel2')) : 0.0;
            decimal NBWorkingUnitLevel3 = (partListMap.get('NBWorkingUnitLevel3') != null) ? (decimal)(partListMap.get('NBWorkingUnitLevel3')) : 0.0;

            decimal nbWrkingHoursLvl1 = (partListMap.get('NBHoursLabourPartLevel1') != null) ? (decimal)(partListMap.get('NBHoursLabourPartLevel1')) : 0.0;
            decimal nbWrkingHoursLvl2 = (partListMap.get('NBHoursLabourPartLevel2') != null) ? (decimal)(partListMap.get('NBHoursLabourPartLevel2')) : 0.0;
            decimal nbWrkingHoursLvl3 = (partListMap.get('NBHoursLabourPartLevel3') != null) ? (decimal)(partListMap.get('NBHoursLabourPartLevel3')) : 0.0;
 
            decimal NBHoursLabourPartLevel1 = (string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel1 > 0) ? 
                                                NBWorkingUnitLevel1/decimal.valueOf(NBWrkingUnit) : 
                                                ((nbWrkingHoursLvl1 > 0) ? nbWrkingHoursLvl1 : 0.0);

            decimal NBHoursLabourPartLevel2 = (string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel2 > 0) ? 
                                                NBWorkingUnitLevel2/decimal.valueOf(NBWrkingUnit) : 
                                                ((nbWrkingHoursLvl2 > 0) ? nbWrkingHoursLvl2 : 0.0);

            decimal NBHoursLabourPartLevel3 = (string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel3 > 0) ? 
                                                NBWorkingUnitLevel3/decimal.valueOf(NBWrkingUnit) : 
                                                ((nbWrkingHoursLvl3 > 0) ? nbWrkingHoursLvl3 : 0.0);
            //HRM 12/10/2021 C-004405 : No Ordering on Fake References
            Boolean notForOrder= setFakeReferences.contains(partNumber) ? true : false;
            
            // this part is an original
            // map fields for upsert
            if(alphaScaleMRID == ''){
                String cleanseOEMKey = cleanseReference(partNumber) + '-' + crossRefBrand;
                

                //If (new assessment or existing assessment) AND new part and (does not have any substitute or (is a BS Exclude A' Nena and contains only A))
                if((!existingAssessMapKeySet.contains(externalId) || (existingAssessMapKeySet.contains(externalId) && (originalPartsMap.isEmpty() ||(!originalPartsMap.isEmpty() && !originalPartsMap.containsKey( externalId + '-' + partExternalId))) ))&& 
                    (OEMIAMPriceMap.isEmpty() || (!OEMIAMPriceMap.isEmpty() && !OEMIAMPriceMap.containsKey(cleanseOEMKey)))){
                    
                        isSelected = true;
                }
                else{
                    isSelected = false;
                }
                system.debug('## isSelected' + isSelected);

                //AMI 19/07/17 : New External Id being sent in ass request
                newPart = new PartList__c(Description__c                = partDescription
                                          ,Name                         = partLabel.left(80)
                                          ,PartNumber__c                = partNumber
                                          ,Price__c                     = Double.ValueOf(partListMap.get('Price'))
                                          ,ProducerName__c              = manufacturer
                                          ,Quantity__c                  = quantity
                                          ,RecordTypeId                 = recordTypePartTypeMap.get(String.valueOf(partListMap.get('RecordType')))
                                          ,Type__c                      = 'A'
                                          ,Compliance__c                = (partListMap.get('Compliance') != null) ? Boolean.valueOf(partListMap.get('Compliance')) : false
                                          ,InputType__c                 = String.valueOf(partListMap.get('InputType'))
                                          ,Currency__c                  = String.valueOf(partListMap.get('Currency'))
                                          ,TECH_OriginalPart__c         = partExternalId
                                          ,SelectedByBS__c              = isSelected
                                          ,InterventionCode__c          = String.valueOf(partListMap.get('InterventionCode'))
                                          ,NBHoursLabourPartLevel1__c   = (partListMap.get('NBHoursLabourPartLevel1') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel1')) : null
                                          ,NBHoursLabourPartLevel2__c   = (partListMap.get('NBHoursLabourPartLevel2') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel2')) : null
                                          ,NBHoursLabourPartLevel3__c   = (partListMap.get('NBHoursLabourPartLevel3') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel3')) : null
                                          ,NBHoursLabourPainting__c     = (partListMap.get('NBHoursLabourPainting') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPainting')) : null
                                          ,ARCAUTOCode__c               = String.valueOf(partListMap.get('ARCAUTOCode'))
                                          //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                          //,VAT__c                       = (partListMap.get('VATRate') != null) ? Double.ValueOf(partListMap.get('VATRate')) : null
                                          ,VAT__c                       = (externalId != null && mapConfigCountryCodeInfo.get(externalId.left(2)) != null && mapConfigCountryCodeInfo.get(externalId.left(2)).CountryVAT__c != null) ? mapConfigCountryCodeInfo.get(externalId.left(2)).CountryVAT__c : null
                                          ,CertifyingOrganization__c    = String.ValueOf(partListMap.get('CertifyingOrganization'))
                                          ,isSourced__c                 = false
                                          ,isDeleted__c                 = partsToDelSet.contains(externalId + '-' + partExternalId) ? true : false
                                           //,Stock__c                     = 'Available'
                                          ,Stock__c                     =  (originalPartsMap.containsKey( externalId + '-' + partExternalId) == true) ?  originalPartsMap.get( externalId + '-' + partExternalId).Stock__c : 'Available'                                                                               
                                          ,crashCode__c                 =  crash
                                          ,ExternalId__c                =  newExtId != null ? newExtId : ''
                                          //AMI 26/01/18 : C-002189 - Informex Integration
                                          //                        - Adding newly created field
                                          ,Deducible__c                 = (partListMap.get('Deducible') != null) ? double.valueOf(partListMap.get('Deducible')) : null
                                          ,ObsoleteRatio__c             = (partListMap.get('ObsoleteRatio') != null) ? double.valueOf(partListMap.get('ObsoleteRatio')) : null
                                          ,PositionID__c                = (partListMap.get('PositionID') != null) ? String.valueOf(partListMap.get('PositionID')) : ''//RLA 20/11/2020 C-003879 Add field Partlist.PositionID
                                          ////HRM 12/10/2021 C-004405 : No Ordering on Fake References
                                          ,NotForOrder__c               = notForOrder
                                        );

                //AMI 25/01/18 : C-002195 - Audatex Integration
                //                        - updating NBHoursLabourPartLevels
                if(NBHoursLabourPartLevel1 > 0){
                    newPart.NBHoursLabourPartLevel1__c = NBHoursLabourPartLevel1; 
                }

                if(NBHoursLabourPartLevel2 > 0){
                    newPart.NBHoursLabourPartLevel2__c = NBHoursLabourPartLevel2;
                }

                if(NBHoursLabourPartLevel3 > 0){
                    newPart.NBHoursLabourPartLevel3__c = NBHoursLabourPartLevel3;
                }

                // if (isIG && mapOEMIdConnectedOemID.containskey(partExternalId) && existingAssessMapKeySet.contains(externalId) && originalPartsMap.containsKey( externalId + '-' + partExternalId) ){
                //     newPart = originalPartsMap.get( externalId + '-' + partExternalId);

                // }

                // system.debug('@@ mapOEMIdConnectedOemID: '+mapOEMIdConnectedOemID.containskey(partExternalId) + newPart.Name);

                //AMI 25/01/18 : C-002195 - Audatex Integration
                //                        - build mapTechOriginalPartKeyAudatexUnsavedFld
                if((string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel1 > 0) || (string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel2 > 0)|| (string.isNotBlank(NBWrkingUnit) && NBWorkingUnitLevel3 > 0)){
                    mapTechOriginalPartKeyAudatexUnsavedFld.put(partExternalId.toUpperCase(),new audatexUnSavedFields(NBWorkingUnitLevel1,NBWorkingUnitLevel2,NBWorkingUnitLevel3));
                }

                newPart.Assessment__r = new Assessment__c(AssessmentID__c = externalId);
                
                if(!originalPartsMap.isEmpty() && originalPartsMap.containsKey( externalId + '-' + newPart.TECH_OriginalPart__c)){  
                    newPart.Id = originalPartsMap.get(externalId + '-' + newPart.TECH_OriginalPart__c).Id;
                    newPart.SelectedByBS__c = true;
                    newPart.RecommendedByAS__c = originalPartsMap.get(externalId + '-' + newPart.TECH_OriginalPart__c).RecommendedByAS__c;
                    newPart.isDeleted__c  = partsToDelSet.contains(externalId + '-' +newPart.TECH_OriginalPart__c) ? true : false;  

                    if(shoppingList || (!shoppingList && shoppingListExistAssessKey.contains(newPart.Assessment__r.AssessmentId__c))){
                        if(!shopAssessIdPartsMap.containsKey(newPart.Assessment__r.AssessmentId__c)){
                            newPart.SelectedByBS__c = true;
                            shopAssessIdPartsMap.put(newPart.Assessment__r.AssessmentId__c, new list<PartList__c>{newPart});
                        }
                        else{
                            newPart.SelectedByBS__c = true;      
                            shopAssessIdPartsMap.get(newPart.Assessment__r.AssessmentId__c).add(newPart);
                        }
                    }              
                }

                if(!newPartMap.containskey(newPart.TECH_OriginalPart__c)){
                    newPartMap.put(newPart.TECH_OriginalPart__c, newPart);
                    newPartList.add(newPart);
                }


                //AMI 20/11/17 - C-002041 - Distributor V2 - build mapOriginalTechOriginalPartPartlist
                mapOriginalTechOriginalPartPartlist.put(newPart.TECH_OriginalPart__c,newPart);
                
                system.debug('newPart.TECH_OriginalPart__c>>'+newPart.TECH_OriginalPart__c);
                //AMI 20/11/17 - C-002041 - Distributor V2 - building mapOriginalTechOriginalPartSetSubsTechOriginalPart
                //                                         - adding original as first value
                system.debug('buildMapOriginalTechOriginalPartSetSubsTechOriginalPart>>6');
                buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(newPart.TECH_OriginalPart__c,newPart);

            }

            // this a substitute. get original part from originalIdPartMap
            else{
                // ASE : 01/03/2017 : split description of substitute
                string substituteKey = externalId +'-'+ alphaScaleMRID +'-'+ partDescription.split(' - ')[0]; 
                
                if(!allAssessSubOriginalMap.isEmpty() && allAssessSubOriginalMap.containskey(substituteKey)){
                   if(!originalPartsMap.isEmpty()){ 
                        for(String x: allAssessSubOriginalMap.get(substituteKey)){
                            if(originalPartsMap.containskey(externalId + '-' + x)){                                 
                                newPart = originalPartsMap.get(externalId + '-' + x);
                                newPart.SelectedByBS__c = false;
                                newPart.Quantity__c = quantity;
                                newPart.isDeleted__c  = partsToDelSet.contains(externalId + '-' + newPart.TECH_OriginalPart__c) ? true : false;     

                                if(!newPartMap.containskey(newPart.TECH_OriginalPart__c)){
                                    newPartMap.put(newPart.TECH_OriginalPart__c, newPart);
                                    newPartList.add(newPart);
                                } 

                                PartList__c subsPart = allsubPartsMap.get(substituteKey);

                                if(shoppingList || (!shoppingList && shoppingListExistAssessKey.contains(subsPart.Assessment__r.AssessmentId__c))){
                                    if(!shopAssessIdPartsMap.containsKey(subsPart.Assessment__r.AssessmentId__c)){
                                        subsPart.SelectedByBS__c = true;
                                        shopAssessIdPartsMap.put(subsPart.Assessment__r.AssessmentId__c, new list<PartList__c>{subsPart});
                                    }
                                    else{
                                        subsPart.SelectedByBS__c = true;  
                                        shopAssessIdPartsMap.get(subsPart.Assessment__r.AssessmentId__c).add(subsPart);
                                    }

                                }                               
                            }
                        }
                    }
                }
            }

            // build map<AssessId-partNUmber-crossRefBrand, list<Part.TECH_OriginalPart__c>> because we may have parts with same partNUmber and different descriptions
            // used in createSubstitutes to clone susbtitutes when working with OEMIAMMap
            if(newPart != null){
                if(!newPartDescMap.containskey(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand)){
                    newPartDescMap.put(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand, new List<String>{newPart.TECH_OriginalPart__c});
                }
                else{
                    newPartDescMap.get(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand).add(newPart.TECH_OriginalPart__c);
                }
                //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                if (isNonAxa){
                    if(!nonAxaOriginalPartsMap.containsKey(entityCode)){
                        nonAxaOriginalPartsMap.put(entityCode, new set<String>{newPart.TECH_OriginalPart__c});
                    }
                    else{
                        nonAxaOriginalPartsMap.get(entityCode).add(newPart.TECH_OriginalPart__c);
                    }  

                }

                // ASE : 136/11/17 : C-001988                
                if(bsRefAccountMap.containsKey(bodyShopId)){
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                    String accType = bodyshopToReplace != null ? bodyshopToReplace.Type : bsRefAccountMap.get(bodyShopId).Type;
                    if(accType == 'Expert'
                       && ((!originalPartsMap.isEmpty() && !originalPartsMap.containsKey( externalId + '-' + newPart.TECH_OriginalPart__c)) || originalPartsMap.isEmpty() ))//RLA 03/09/2020 C-003621: Proposed Expert Assessment selection of partlists is not okay
                       {   
                        // system.debug('@@ we are putting: '+newPart.TECH_OriginalPart__c);                     
                        if(!expertOriginalPartsMap.containsKey(entityCode)){
                            expertOriginalPartsMap.put(entityCode, new set<String>{newPart.TECH_OriginalPart__c});
                        }
                        else{
                            expertOriginalPartsMap.get(entityCode).add(newPart.TECH_OriginalPart__c);
                        }                        
                    }
                }
            }         
        }


        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - createPartList ----------------------------------');
    }

    public static List<PartList__c> createSubstitute(String externalId, Map<String, List<CrossReference__c>> OEMIAMMap, Map<String, CrossReference__c> OEMIAMPriceMap, List<DetailRule__c> listFieldUpdatesDetailRules,  Map<String, PartList__c> newPartMap, Map<String, List<String>> newPartDescMap, String entityRule, Boolean TechCarBrandExcluded){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - createSubstitute ----------------------------------');


        //DUN 11/08/2016
        List<PartList__c> newPartListToUpdateField = new List<PartList__c>();

        // variables
        List<PartList__c> newPartList   = new List<PartList__c>();

        //ASE: 02/03/2017: C-001885 
        String crossRefBrand = assessCarMap.get(externalId).split(';')[2];
        

        set<String> categoriesSet = assessBSCategoriesMap.get(externalId);   



        // loop in newPartMap
        for(String newPartKey : newPartMap.keyset()){
            PartList__c pl = newPartMap.get(newPartKey);
            
            String cleanseOEMKey  = cleanseReference(pl.PartNumber__c) + '-' + crossRefBrand;
            String OEMKey         = pl.PartNumber__c + '-' + crossRefBrand;   

            String originalNonCleansePartNumber = pl.PartNumber__c;

            //AMI 19/07/17 : New External Id being sent in ass request
            string newExtId       = pl.ExternalId__c;

            // if OEMIAMMap contains parts, isSelected of substitutes is based on masterRule
            if(OEMIAMMap != null && OEMIAMMap.containsKey(cleanseOEMKey)){                
                for(CrossReference__c CR : OEMIAMMap.get(cleanseOEMKey)){

                     system.debug('#### here 9:'+CR.Name);

                    //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed                    
                    if (CR.Distributors__r != null &&  CR.Distributors__r.size() > 0 && String.isNotBlank(CR.Distributors__r[0].TechDistributorConnected__c)){
                        mapXrefNameTechDis.put(CR.Name, CR.Distributors__r[0].TechDistributorConnected__c);

                    }

                    double originalPrice = pl.Price__c != null ? pl.Price__c : 1000000.0;
                    //AMI 02/02/18 - C-002041 - Distributor V2 - Prevent Creation of cross ref parts if price is greater than original //xxxwch
                    double crossRefPrice = CR.connected__c? (CR.PRE_Price__c + (originalPrice * (CR.OEMStandardDiscount__c / 100)) + CR.AdditionalMargin__c):((CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c);

                    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages //xxxwch
                    if (isnonAxa){
                        crossRefPrice = CR.connected__c?((CR.NONPARTNER_PRE_Price__c == null) ?  0 : CR.NONPARTNER_PRE_Price__c) :((CR.NONAXA_AS_Public_Price__c == null) ?  0 : CR.NONAXA_AS_Public_Price__c);
                    }

                    


                    if((isNONAXA && (system.label.NONASSubstitutionIfPrice0.contains(callersystemGlo) || (!system.label.NONASSubstitutionIfPrice0.contains(callersystemGlo) && originalPrice >= crossRefPrice) ) ) || (!isNONAXA && originalPrice > crossRefPrice)){
                        //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                        if(CR.OEMStandardDiscount__c != null || CR.OEMStandardMargin__c != null){
                            mapPartNumCrossRef.put(CR.OEMCleanPartNumber__c,CR);
                        }                         

                        //C-002692 : ASE 27/09/2018*/
                        string translatedOrigine;
                        if(BSLang != null && BSLang == 'nl' && String.isnotblank(CR.IAMCertifyingOrganization__c) && mapOrigineValues != null){
                            //RLA 06/09/2018 C-002692 : Substitution on BE assessments
                            if (mapOrigineValues.containskey(CR.IAMCertifyingOrganization__c)){
                                translatedOrigine = mapOrigineValues.get(CR.IAMCertifyingOrganization__c);   
                                //translatedOrigine = system.label.ORIGINENL;   
                            }                         
                        } 

                        String substituteDescription = pl.Description__c + ' - ' + CR.IAMManufacturer__c + ' (' + CR.IAMPartNumber__c + ')';
                        // ASE : 13/12/16 : use original Name - manufacturer (IAM part Number) for substitute description
                        substituteDescription = (CR.IAMCertifyingOrganization__c != null) ? substituteDescription + ' - '+ ((translatedOrigine != null) ? translatedOrigine: CR.IAMCertifyingOrganization__c) : substituteDescription;  
                        
                        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                        double pricePart = (CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c;
                        if (isnonAxa){
                            if(CR.Connected__c && isnonAxa){
                                pricePart = pl.Price__c ; 
                            }else{
                                pricePart = (CR.NONAXA_AS_Public_Price__c == null) ?  0 : CR.NONAXA_AS_Public_Price__c;
                            }
                        }
                        //KEM add calculation of new price of connected part E 
                        else if (CR.Connected__c) {
                            pricePart = (CR.PRE_Price__c + (pl.Price__c * (CR.OEMStandardDiscount__c / 100)) + CR.AdditionalMargin__c) ; 
                        }  

                        System.debug('<<<pl.Price__c>>>' + pl.Price__c);
                        System.debug('<<<CR.PRE_Price__c>>>' + CR.PRE_Price__c);
                        System.debug('<<<CR.OEMStandardDiscount__c>>>' + CR.OEMStandardDiscount__c);
                        System.debug('<<<CR.AdditionalMargin__c>>>' + CR.AdditionalMargin__c);
                        System.debug('<<<pricePart2>>>' + pricePart);
                        

                        PartList__c newPart = new PartList__c(Description__c               = substituteDescription
                                                              ,Name                         = substituteDescription.left(80)                                                      
                                                              ,PartNumber__c                = CR.Name
                                                              ,Price__c                     = pricePart
                                                              ,ProducerName__c              = CR.IAMManufacturer__c
                                                              ,Type__c                      = CR.IAMPartClass__c
                                                              ,Assessment__r                = new Assessment__c(AssessmentID__c = externalId)
                                                              ,OriginalPart__r              = new PartList__c(TECH_OriginalPart__c = OEMKey + '-' + externalId)
                                                              ,Alpha_Scale_MRID__c          = CR.Name
                                                              ,CrossReferenceId__c          = CR.Id
                                                              //C-002692 : ASE 27/09/2018*/
                                                              ,CertifyingOrganization__c    = (translatedOrigine != null) ? translatedOrigine: CR.IAMCertifyingOrganization__c
                                                              ,isSourced__c                 = false                                                          
                                                              ,Stock__c                     = 'Available'
                                                               //ASE: 22/02/18
                                                              ,DistributorPriceId__c       = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].Id : null
                                                              // ASE: 08/05/18: C-002278 
                                                              ,Distributor__c            = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].DistributorID__c: null
                                                              ,TECHDistList__c  = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].DistributorID__c: null
                                                              //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                                              ,VAT__c                       = (externalId != null && mapConfigCountryCodeInfo.get(externalId.left(2)) != null && mapConfigCountryCodeInfo.get(externalId.left(2)).CountryVAT__c != null) ? mapConfigCountryCodeInfo.get(externalId.left(2)).CountryVAT__c : null
                                                              ,Distributors__c = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].DistributorID__c: null
                                                          );
                        
                        Decimal StandardMargin;
                        Decimal StandardDiscount;
                        Decimal ASNetPrice;


                        //RLA 10/05/2021 Aniel DP distributor not called during callout
                        if (newPart.DistributorPriceId__c != null){
                            setDistPriceIds.add(newPart.Distributor__c);
                        }
                        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                        if (isnonAxa){
                            if(CR.NONAXA_AS_Public_Price__c == null && CR.NONAXA_AS_Net_Price__c == null){
                                StandardMargin = null;
                                StandardDiscount = null;
                            }
                            else if((CR.NONAXA_AS_Public_Price__c == null || CR.NONAXA_AS_Public_Price__c == 0) && CR.NONAXA_AS_Net_Price__c != null){
                                StandardMargin = 0;
                                StandardDiscount = 0;
                            }
                            else{
                                CR.NONAXA_AS_Net_Price__c = (CR.NONAXA_AS_Net_Price__c != null) ? CR.NONAXA_AS_Net_Price__c : CR.NONAXA_AS_Public_Price__c;
                                StandardMargin = CR.NONAXA_AS_Public_Price__c - CR.NONAXA_AS_Net_Price__c ;
                                StandardDiscount = ((1 - (CR.NONAXA_AS_Net_Price__c / CR.NONAXA_AS_Public_Price__c))*100);
                            }
                        }
                        //ZZZ KEM
                        else if (CR.Connected__c){
                            if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                                StandardMargin = null;
                                StandardDiscount = null;
                            }
                            else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                                StandardMargin = 0;
                                StandardDiscount = 0;
                            }
                            else{
                                CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                                StandardMargin = pricePart - CR.PRE_Price__c ;
                                StandardDiscount = ((1 - (CR.PRE_Price__c / pricePart))*100);
                                ASNetPrice = CR.PRE_Price__c;
                            }
                        }
                        else{
                        if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                            StandardMargin = null;
                            StandardDiscount = null;
                        }
                        else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                            StandardMargin = 0;
                            StandardDiscount = 0;
                        }
                        else{
                            CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                            StandardMargin = CR.ASPublicPrice__c - CR.ASNetPrice__c ;
                            StandardDiscount = ((1 - (CR.ASNetPrice__c / CR.ASPublicPrice__c))*100);
                        }
                        }
                        

                        newPart.StandardMargin__c = StandardMargin;
                        newPart.StandardDiscount__c = StandardDiscount;
                        newPart.ASNetPrice__c = ASNetPrice;

                        // used to build substitutes for all parts having the same partNumber
                  
                        if(newPartDescMap.containsKey(externalId + '-' + OEMKey)){
                            for(String partKey: newPartDescMap.get(externalId + '-' + OEMKey)){
                                // 07/12/16: bug when using containsKey
                                //if(newPartMap.containsKey(partKey)){
                                if(newPartKey == partKey){
                                    PartList__c newSubstitute = newPart.clone(false, true);

                                    //AMI 19/07/17 : New External Id being sent in ass request
                                    if(string.isNotBlank(newExtId)){
                                        newSubstitute.TECH_OriginalPart__c  = externalId + '-' + newExtId + '-' + newSubstitute.PartNumber__c;
                                    }else{
                                        newSubstitute.TECH_OriginalPart__c  = originalNonCleansePartNumber + '-'
                                                                        + newSubstitute.PartNumber__c + '-'
                                                                        + newSubstitute.Name.replaceAll('\\s+', '') + '-'
                                                                        + newSubstitute.ProducerName__c + '-'
                                                                        + externalId;
                                    }

                                    newSubstitute.OriginalPart__r       = new PartList__c(TECH_OriginalPart__c = partKey);
                                    newSubstitute.Quantity__c           = newPartMap.get(partKey).Quantity__c;
                                    newSubstitute.RecordTypeId          = newPartMap.get(partKey).RecordTypeId;
                                    newSubstitute.InputType__c          = newPartMap.get(partKey).InputType__c;
                                    newSubstitute.Currency__c           = newPartMap.get(partKey).Currency__c;
                                    newSubstitute.isDeleted__c          = partsToDelSet.contains(partKey) ? true : false;   
                                    
                                    //DUN 12/09/2016 MasterRule Updated
                                    if(OEMIAMPriceMap != null && OEMIAMPriceMap.containskey(cleanseOEMKey) && OEMIAMPriceMap.get(cleanseOEMKey).Id == cr.Id){                                        
                                        if(mapEntitysetPartListTechId.containsKey(entityRule)){
                                            mapEntitysetPartListTechId.get(entityRule).add(newSubstitute.TECH_OriginalPart__c);
                                        }
                                        else{
                                            mapEntitysetPartListTechId.put(entityRule, new set<String>{newSubstitute.TECH_OriginalPart__c});
                                        }
                                    }
                                    newPartList.add(newSubstitute);   
                                    //crashSubCrashOriginalMap.put(newSubstitute.TECH_OriginalPart__c, partKey);  

                                    //AMI 20/11/17 - C-002041 - Distributor V2 - building mapSubstituteTechOriginalPartPartlist
                                    mapSubstituteTechOriginalPartPartlist.put(newSubstitute.TECH_OriginalPart__c,newSubstitute);
                                    system.debug('isForcedNoA>>'+isForcedNoA);
                                    system.debug('OEMIAMPriceMap>>'+OEMIAMPriceMap);
                                    system.debug('newSubstitute.Type__c>>'+newSubstitute.Type__c);
                                    system.debug('cleanseOEMKey>>'+cleanseOEMKey);
                                    system.debug('newSubstitute.PartNumber__c>>'+newSubstitute.PartNumber__c);
                                    system.debug('preferredType>>'+preferredType);
                                    //AMI 20/11/17 - C-002041 - Distributor V2 - building mapOriginalTechOriginalPartSetSubsTechOriginalPart
                                    //C-002600: 
                                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                                    if( (!(isForcedNoA && newSubstitute.Type__c == 'A')
                                         && !(isForcedAlbax && newSubstitute.Type__c != 'E'))
                                        && ( !OEMIAMPriceMap.isEmpty() 
                                            && OEMIAMPriceMap.containsKey(cleanseOEMKey) 
                                            && OEMIAMPriceMap.get(cleanseOEMKey).Name == newSubstitute.PartNumber__c
                                            // && ((isInformex && newSubstitute.Type__c == 'B') || !isInformex)
                                            ) //Added by RLA 03/12/2019 for 3180
                                        || (!OEMIAMPriceMap.containsKey(cleanseOEMKey) && newSubstitute.Type__c ==  preferredType)//RLA 21/08/2020 C-003738 C-Parts
                                        ){//RLA 28/05/2019 C-003180
                                            system.debug('buildMapOriginalTechOriginalPartSetSubsTechOriginalPart>>1');
                                        buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(partKey,newSubstitute);  
                                    } 
                                    system.debug('#### entityRule:'+entityRule);
                                    system.debug('#### isForcedAlbax:'+isForcedAlbax);
                                    system.debug('#### isForcedNoA:'+isForcedNoA);
                                    system.debug('#### newSubstitute.Type__c:'+newSubstitute.Type__c);
                                    // system.debug('#### newSubstitute.Type__c:'+newSubstitute.Type__c);
                                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                                    if( (!(isForcedNoA && newSubstitute.Type__c == 'A')
                                         && !(isForcedAlbax && newSubstitute.Type__c != 'E'))
                                        && String.isNotBlank(entityRule)
                                        && entityRule.left(2) == 'FR'
                                        && newSubstitute.Type__c == 'E')
                                    {
                                        buildmapOriginalTechOriginalPartSetSubsPartEs(partKey,newSubstitute,CR);  
                                    } 
                                    //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
                                    mapTechOriASCROEM.put(newSubstitute.TECH_OriginalPart__c,partKey );
                                    buildmapOriginalTechOriginalPartSetSubsAllPart(partKey,newSubstitute);

                                    system.debug('#### mapOriginalTechOriginalPartSetSubsPartEs:'+mapOriginalTechOriginalPartSetSubsPartEs);
                                    system.debug('#### mapOriginalTechOriginalPartSetSubsTechOriginalPart:'+mapOriginalTechOriginalPartSetSubsTechOriginalPart);

                                    if(newSubstitute.Type__c != 'A' && !OEMCRAPrimeExcludedSet.contains(pl.TECH_OriginalPart__c)){
                                        OEMCRAPrimeExcludedSet.add(pl.TECH_OriginalPart__c);      
                                    }   

                                    //RLA 20/02/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
                                    if (mapOEMKeyTechOri.containsKey(cleanseOEMKey)){
                                        mapOEMKeyTechOri.get(cleanseOEMKey).put(CR.Name,newSubstitute.TECH_OriginalPart__c);
                                    }
                                    else{
                                        mapOEMKeyTechOri.put(cleanseOEMKey,new map<String, String> {CR.Name => newSubstitute.TECH_OriginalPart__c}); 
                                    }                                 
                                }
                            }
                        } 
                    }//end if(originalPrice > crossRefPrice){ 
                    // ASE: 08/05/18: C-002278 
                    String distId = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].DistributorID__c : null;
                    if(distId != null){
                        DistributorIdSet.add(distId);
                    }  

                }//end looping in cross ref
            }
            else{
                // else if originalSubstituteListMap contains parts, the parts are already existing in partList
                if(!originalSubstitutesMap.isEmpty()){
                   
                    if(originalSubstitutesMap.containsKey(externalId + '-' + pl.TECH_OriginalPart__c)){   
                    for(PartList__c existingSubstitute: originalSubstitutesMap.get(externalId + '-' + pl.TECH_OriginalPart__c)){
                            PartList__c updatedSubstitute = existingSubstitute.clone(false, true);
                            updatedSubstitute.Quantity__c = pl.Quantity__c;
                            // ASE: 05/10/18: C-002822
                            if(updatedSubstitute.Distributor__c == null && updatedSubstitute.DistributorPriceId__c != null){  
                                updatedSubstitute.Distributor__c = updatedSubstitute.DistributorPriceId__r.DistributorID__c;                             
                                updatedSubstitute.Distributors__c = updatedSubstitute.DistributorPriceId__r.DistributorID__c;
                                updatedSubstitute.TECHDistList__c = updatedSubstitute.DistributorPriceId__r.DistributorID__c;
                            }
                            
                            //RLA 10/05/2021 Aniel DP distributor not called during callout
                            if (updatedSubstitute.Distributor__c != null){
                                setDistPriceIds.add(updatedSubstitute.Distributor__c);
                            }
                                              
                            // the original is sent in the response
                            if(pl.SelectedByBS__c){
                                updatedSubstitute.SelectedByBS__c = false;
                                updatedSubstitute.isDeleted__c = partsToDelSet.contains(externalId + '-' + pl.TECH_OriginalPart__c) ? true : false;
                            }

                            else{                                
                                // ASE : 13/12/16 : adding description to key to differentiate b/w substitutes
                                //String substituteKey = externalId + '-' + existingSubstitute.Alpha_Scale_MRID__c+ '-' + existingSubstitute.Description__c;                              
                                // ASE : 01/03/2017 : split description of substitute  
                                String substituteKey = externalId + '-' + existingSubstitute.Alpha_Scale_MRID__c+ '-' + existingSubstitute.Description__c.split(' - ')[0];  
                                if(assessSubstituteMap.containskey(substituteKey)){
                                    Map<String, Object> subsMap = (Map<String, Object>) assessSubstituteMap.get(substituteKey);   
                                    updatedSubstitute.SelectedByBS__c = true;
                                    updatedSubstitute.isDeleted__c = partsToDelSet.contains(substituteKey) ? true : false;
                                    // ase: 27/09/18 : cater mrSourcing for existing substitutes
                                    // ASE: 05/10/18: C-002822
                                    if(updatedSubstitute.TECHDistList__c != null){
                                        DistributorIdSet.add(updatedSubstitute.TECHDistList__c); 
                                    }
                                }
                                else{
                                    updatedSubstitute.SelectedByBS__c = false;
                                    updatedSubstitute.isDeleted__c = partsToDelSet.contains(substituteKey) ? true : false;
                                }
                            }
                                                       
                            newPartList.add(updatedSubstitute);

                            //AMI 20/11/17 - C-002041 - Distributor V2 - building mapSubstituteTechOriginalPartPartlist
                            mapSubstituteTechOriginalPartPartlist.put(updatedSubstitute.TECH_OriginalPart__c,updatedSubstitute);

                            //AMI 20/11/17 - C-002041 - Distributor V2 - building mapOriginalTechOriginalPartSetSubsTechOriginalPart
                            buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(pl.TECH_OriginalPart__c,updatedSubstitute);

                            if(!asessPartSubMap.containsKey(externalId + '-' + pl.TECH_OriginalPart__c)){
                                asessPartSubMap.put(externalId + '-' + pl.TECH_OriginalPart__c, new List<PartList__c>{updatedSubstitute});
                            }
                            else{
                                asessPartSubMap.get(externalId + '-' + pl.TECH_OriginalPart__c).add(updatedSubstitute);
                            }

                            ASCRPartNumbMap.put(updatedSubstitute.Alpha_Scale_MRID__c, updatedSubstitute.CrossReferenceId__r.IAMPartNumber__c);
                        }           
                    }
                }
            }
        }
      
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - createSubstitute ----------------------------------');

        return newPartList;
    } 

     // ABT - 26-AUG-2016 - C-001710
    public static String cleanseReference(String referenceToCleanse){
            return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
    }  

    // --------------------- Start Distributor V2 Utility Containers and Methods --------------------- //
    
    //AMI 26/10/17 : C-002041 - Distributor V2 - build partTypeWrapper
    //                                         - this wrapper helps to calculate number of parts 
    public class partTypeWrapper{
        public integer A;
        public integer B;
        public integer C;
        public integer D;
        public integer P;
        public partTypeWrapper(){
            A = 0;
            B = 0;
            C = 0;
            D = 0;
            P = 0;
        }
    }

    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - wrapper class used to return updated original and substitute parts
    //                        - + error if any (used in launchCallOut method)
    public class updatedPartsFromDistCallOut{
        public map <string,PartList__c>  mapTechOriginalKeyOriginalPart = new map <string,PartList__c>();
        list <PartList__c> substitutePart = new list <PartList__c>();
        string errorReported = '';
        public map <string,PartList__c>  mapTechOriginalKeyOriginalPartNoDist = new map <string,PartList__c>();
        map<String,Partlist__c> mapSubsToDel = new map <String, Partlist__c>();


        public updatedPartsFromDistCallOut(map <string,PartList__c>  mapTechOriginalKeyOriginalPart,list <PartList__c> substitutePart,string errorReported, map <string,PartList__c>  mapTechOriginalKeyOriginalPartNoDist, map<String,Partlist__c> mapSubsToDel){
            this.mapTechOriginalKeyOriginalPart = mapTechOriginalKeyOriginalPart;
            this.substitutePart = substitutePart;
            this.errorReported = errorReported;
            this.mapTechOriginalKeyOriginalPartNoDist = mapTechOriginalKeyOriginalPartNoDist;
            this.mapSubsToDel = mapSubsToDel;
        }
    }

    //AMI 02/02/18 - C-002041 - Distributor V2 - Updating A' Description
    //                        - Adding Brand Attribute so that latter can be used in A' Description
    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - wrapper class used to process received response
    public class Line{
        public string ID;
        public String Quantity;
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
        public boolean Bundle;
        public string Brand; 
        public String DistributorReference;//XXX
    }

    //ASE : 07/05/2018: Rework response EIP
    public class dist{
        public string ExternalOrderReference;
        public string Message;
        public string Success;
        public list <Line> Lines;
    }

    //AMI 26/10/17 : C-002041 - Distributor V2 - method to increment parttype found
    public static partTypeWrapper incrementType(partTypeWrapper tempWrap,PartList__c prt,string materialRt){
        system.debug('## Start incrementType');

        partTypeWrapper result = tempWrap;
        //WCH 13/05/2019 C-003194 comment if, rollback on C-002898
        //if (prt.SelectedByBS__c == true){//Added by RLA 08/11/2018 Case: C-002898 Sourcing de pièces non sélectionnées lors d'un update de l'assessment

            if(prt.Type__c == 'A' && prt.RecordTypeId == materialRt){
                tempWrap.A ++;
            }else if(prt.Type__c == 'B' && prt.RecordTypeId == materialRt){
                tempWrap.B ++;
            }else if(prt.Type__c == 'C' && prt.RecordTypeId == materialRt){
                tempWrap.C ++;
            }else if(prt.Type__c == 'D' && prt.RecordTypeId == materialRt){
                tempWrap.D ++;
            }else if(prt.Type__c == 'P' && prt.RecordTypeId == materialRt){
                tempWrap.P ++;            
            }
        //}

        system.debug('## End incrementType');
        return result;
    }

    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - Method used to construct request to call Distributor WS
    public static string buildDistributorRequest(
        Assessment__c assRecord, 
        Id labourRt, 
        list <Account> distributorLst, 
        list <PartList__c> partList,
        set <id> setCrossReferenceId){
        

        map <string,object> distributorObj = new map <string,object>();
        map <id,Account> distributorMap = new map <id,Account>();
        //RLa 26/03/18 : to store the brand name from custom metadata type of vehicle
        String distBrand;        
        String brandName;
        String idForExpert;

        string req = '';

        // datetime qryStart = datetime.now();
        // //C-002776 : Optimisation of RestUpsertAssessmentV2
        // // Map<String, String> mapLabelCarDestination = RestDistributorUtility.getCarMappingsMatrixV2();
        // time5 = ((datetime.now()).getTime() - qryStart.getTime());
        // time5 = (time5.divide(1000, 5));

        //query eligible PO and check if its eligible
        //AMI 12/02/18 : C-002041 - Distributor V2 - ConnectedEndtoEnd__c
        //                        - Check if distributor callout is allowed in upsert
        //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
        //                        - build mapEligiblePONameELigiblePO

        System.debug('<<<distributorLst>>>'+ distributorLst);
        for(Account acc : distributorLst){//RLA 20/11/2018 C-002782 CJP A'
            distributorMap.put(acc.id,acc);           

            if(string.isNotBlank(acc.Tech_Distributor__c)){
                mapEligiblePONameELigiblePO.put(acc.Tech_Distributor__c,acc);
                    // RLA: 18/06/2018 : C-002602 Pas d'ASP si la marque est en Agency Mode 
                    if (acc.CarBrandsSuppliedAgency__c != null){
                        list<string> tempBrandSupplied = acc.CarBrandsSuppliedAgency__c.split(';');
                        //set<String> distBrandSet = new set<String>();
                        //set<String> distBrandMapped = new set<String>();
                        for(String brand : tempBrandSupplied){
                            if (brand.toUpperCase() == (assRecord.Manufacturer__c).toUpperCase()){
                                canCreateAsp = false;   
                            }
                        }
                    }
            }
            System.debug('<<<mapEligiblePONameELigiblePO>>>'+ mapEligiblePONameELigiblePO);
        }

        System.debug('<<<distributorMap>>>'+ distributorMap);
    

        //stop further execution if distributor is not connected
        if(distributorMap.isEmpty()){
            return '';
        }

        //get cross reference info in order to send IAM PartNumber and IAM Manufacturer for ascr only for all types except A
        map <id,CrossReference__c> mapCrossRefIdCrossRef = new map <id,CrossReference__c>([select id,IAMManufacturer__c
                                                                                            from CrossReference__c
                                                                                            where id IN :setCrossReferenceId]);
        
        
        //build map cross ref id and list of associated parts
        //this is because same parts can be present more than once
        map<Id, set <string>> mapCrossRefPart = new map<Id, set <string>>(); 

        //build map distributor and set of parts
        //this map will be used to generate list of parts to check if suppliable by dist
        map<id, set<string>> mapDistributorSetPartTechOriginal = new map<id, set<string>>(); 

        //build map combination of dist id and tech original part with associated distributor price part number
        //this map will be used to replace part number of ascr with distributor price part number
        map <string,string> mapCombiDistIdPartIdAndDistPNumber = new map <string,string>();

        //RLA 11/05/2021
        //optimise callout by assigning partlists to their distributors
        map<String, List<Partlist__c>> mapDistListPartlist = new map<String, List<Partlist__c>>();

        for(id accId : distributorMap.keySet()){

        //build mapCrossRefPart
            for(PartList__c pt : partList){
                System.debug('<<<pt.CrossReferenceId__c>>>'+ pt.CrossReferenceId__c);
                if(pt.CrossReferenceId__c != null){
                    if(mapCrossRefPart.containsKey(pt.CrossReferenceId__c)){
                        mapCrossRefPart.get(pt.CrossReferenceId__c).add(pt.TECH_OriginalPart__c);
                    }else{
                        mapCrossRefPart.put(pt.CrossReferenceId__c, new set <string>{pt.TECH_OriginalPart__c});
                    }
                    System.debug('<<<mapDistListPartlist1>>>'+ mapDistListPartlist);
                }
                //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
                if ( (String.isnotblank(pt.Distributors__c) && pt.Distributors__c.contains(accid)) || isIG || (assCountry == 'DE' && isExpert) || assCountry == 'BE'){
                    if (mapDistListPartlist.containsKey(accId)){
                        mapDistListPartlist.get(accId).add(pt);
                    }
                    else{
                        mapDistListPartlist.put(accId, new list<Partlist__c> {pt});
                    }
                    System.debug('<<<mapDistListPartlist2>>>'+ mapDistListPartlist);
                }
                if(pt.CrossReferenceId__c != null && mapXrefDisName.containskey(pt.CrossReferenceId__c)){
                    System.debug('<<<mapXrefIdLstOccDistId>>>'+ mapXrefIdLstOccDistId);
                    if(mapXrefDisName.get(pt.CrossReferenceId__c).contains(System.label.xRefConnectedEDistributor) && mapXrefIdLstOccDistId.containsKey(pt.CrossReferenceId__c)){

                        for(String currentDisId :  mapXrefIdLstOccDistId.get(pt.CrossReferenceId__c) ){
                            if(currentDisId==accId){
                                if (mapDistListPartlist.containsKey(currentDisId)){
                                    mapDistListPartlist.get(currentDisId).add(pt);
                                } else {
                                    mapDistListPartlist.put(currentDisId, new list<Partlist__c> {pt});
                                } 
                            }
                        }
                    }
                    System.debug('<<<mapDistListPartlist3>>>'+ mapDistListPartlist);
                }
            }
            System.debug('<<<mapDistListPartlist>>>'+ mapDistListPartlist);
        }
        

        //build mapDistributorSetPartTechOriginal and mapCombiDistIdPartIdAndDistPNumber
        for(DistributorPrice__c dp : [Select CrossReference__c, DistributorID__c,DistributorPartNumber__c 
                                        from DistributorPrice__c 
                                        where Active__c = true 
                                        AND isDeleted__c = false 
                                        AND CrossReference__c in: mapCrossRefPart.keyset()]){
            if(!mapDistributorSetPartTechOriginal.containsKey(dp.DistributorID__c)){
                mapDistributorSetPartTechOriginal.put(dp.DistributorID__c, new set<string>(mapCrossRefPart.get(dp.CrossReference__c))); 
            } 
            else{
                mapDistributorSetPartTechOriginal.get(dp.DistributorID__c).addAll(mapCrossRefPart.get(dp.CrossReference__c));  
            }  

            system.debug('<<<<mapXrefDisName.get(dp.CrossReference__c):>>>> '+ mapXrefDisName.get(dp.CrossReference__c));
            system.debug('mapCrossRefPart.get(dp.CrossReference__c)' + mapCrossRefPart.get(dp.CrossReference__c));
            system.debug('mapXrefIdLstDistId' +mapXrefIdLstDistId);

            if(mapCrossRefPart.get(dp.CrossReference__c).size() > 1){
                //KEM 13/04/2020 C-004874
                    
                    for(String DisId: mapXrefIdLstDistId.get(dp.CrossReference__c)){

                            for(string techOriginalPart : mapCrossRefPart.get(dp.CrossReference__c)){ 

                                if(mapXrefDisName.get(dp.CrossReference__c).contains(System.label.xRefConnectedEDistributor)){
                                    
                                    for(Occurence__c occ : mapXrefIdLstOccurence.get(dp.CrossReference__c)){
                                        system.debug('<<<<occ:>>>> '+ occ);
                                        mapCombiDistIdPartIdAndDistPNumber.put(DisId + '-' + techOriginalPart,occ.DistributorReference__c);
                                    }
                                }else{
                                        mapCombiDistIdPartIdAndDistPNumber.put(dp.DistributorID__c + '-' + techOriginalPart,dp.DistributorPartNumber__c);
                                }
                            }
                            system.debug('<<<<DisId:>>>> '+ DisId);
                    }
                    system.debug('<<<<I am at PRE by alpha scale :>>>> '+ mapCombiDistIdPartIdAndDistPNumber);
                    system.debug('<<<<I am at PRE by alpha scale else part :>>>> '+ mapCombiDistIdPartIdAndDistPNumber);


            }else{
                list <string> tempListId = new list <string>(mapCrossRefPart.get(dp.CrossReference__c));
                system.debug('<<<<mapCrossRefPart.get(dp.CrossReference__c)>>>> '+ mapCrossRefPart.get(dp.CrossReference__c));
                system.debug('<<<<mapXrefIdLstOccurence>>>> '+ mapXrefIdLstOccurence);
                
                if(mapXrefDisName.get(dp.CrossReference__c).contains(System.label.xRefConnectedEDistributor)){
                    for(Occurence__c occ : mapXrefIdLstOccurence.get(dp.CrossReference__c)){
                        mapCombiDistIdPartIdAndDistPNumber.put( occ.Distributor__c + '-' + tempListId[0],occ.DistributorReference__c); 
                    }
                    system.debug('<<<<mapXrefDisName.get(dp.CrossReference__c)2222:>>>> '+mapXrefDisName.get(dp.CrossReference__c));
                }else{
                    mapCombiDistIdPartIdAndDistPNumber.put(dp.DistributorID__c + '-' + tempListId[0],dp.DistributorPartNumber__c);  
                    system.debug('<<<<dp.DistributorID__c2222:>>>> '+dp.DistributorID__c);
                }
            }
        }
        system.debug('<<<<mapCombiDistIdPartIdAndDistPNumber:>>>> '+mapCombiDistIdPartIdAndDistPNumber);
   

        RestDistributorUtility.BodyShop BodyShop ;
        RestDistributorUtility.Vehicle Vehicle ;
        RestDistributorUtility.mainRequest mainRequest ;
        String techDist;
        //RLA 09/07/2020 C-003857: IG - Creation IGO 
        String prefixPartNumber = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);

        datetime qryStart = datetime.now();
        //RLA 13/01/2020 C-001921: Optimisation : Review Upsert performance
        Set<String> setDistBrands = new set<String>();
        for(id accId : distributorMap.keySet()){

            //for(PartList__c prt : partList){
                String distBrands = (distributorMap.get(accId).Tech_Distributor__c+'-'+(assRecord.Manufacturer__c)).toUpperCase();
                setDistBrands.add(distBrands);
            //}
        }
        
        Map<String, String> mapLabelCarDestinationV2 = RestDistributorUtility.getCarMappingsMatrixV3(setDistBrands);
        time5 = ((datetime.now()).getTime() - qryStart.getTime());
        time5 = (time5.divide(1000, 5));

        for (Account Acc: [SELECT Name,DistributorConnected__c, id,Type_of_Substitutes__c FROM Account where Id IN : distributorMap.keySet() or Name=:System.label.xRefConnectedEDistributor] ){
            if(Acc.Name.equals(System.label.xRefConnectedEDistributor)){piecXRefDistributor.put(acc.id, acc);continue;}
            mapdistToDisFields.put(acc.id, acc);
        }
        //populating distributorObj
        for(id accId : distributorMap.keySet()){
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            Integer j = 0;
            //build parts to be asscoiated with each distributor
            list <RestDistributorUtility.Parts> tempSuppliedParts = new list <RestDistributorUtility.Parts>();
            list <RestDistributorUtility.PartsConnectedE> tempSuppliedPartsConnectedE = new list <RestDistributorUtility.PartsConnectedE>();

            //build categories associated with each distributor
            set <string> setCategory = new set <string>();

            if(distributorMap.get(accId).Categories__c != null){
                setCategory = new set <string>(new list <string>(distributorMap.get(accId).Categories__c.split(';')));
            }//end if distributorMap.get(accId).Categories__c != null

            system.debug('<<<setCategory:>>> '+setCategory);
            
            //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
            Set<String> setAllowedSubstitutes = new Set<String>();
            if (String.isnotBlank(distributorMap.get(accId).Type_of_Substitutes__c)){
                setAllowedSubstitutes = new Set<String>(distributorMap.get(accId).Type_of_Substitutes__c.split(';')) ;
            }
            system.debug('<<<setAllowedSubstitutes:>>> '+setAllowedSubstitutes);

            set <string> setPartTechOriginalPartSuppliedByDist = new set <string>();

            if(mapDistributorSetPartTechOriginal.containsKey(accId)){
                setPartTechOriginalPartSuppliedByDist = mapDistributorSetPartTechOriginal.get(accId);
            }
                    system.debug('@@ setAlreadyOrderedParts: '+setAlreadyOrderedParts);
                    system.debug('@@ setExistingParts: '+setExistingParts);
                    system.debug('@@ mapDistListPartlist: '+mapDistListPartlist);
                    system.debug('<<<accId>>>' + accId);
                    
            for(PartList__c prt : mapDistListPartlist.get(accId)){
                system.debug('<<<prt>>>' + prt);
                
                if(!setExistingParts.contains((prt.TECH_OriginalPart__c).toUpperCase())
                   || isIG){
                    //initialise new wrapper
                    //kem
                    RestDistributorUtility.Parts part = new RestDistributorUtility.Parts(0,'','','','','','','');
                    

                    //RLA 31/10/2020 C-004018: IG - Efa requirements
                    j++;
                    // part.sequenceID = String.valueOf(i)+String.valueOf(j);
                    part.sequenceID = String.valueOf(j);


                    Boolean makeSupplied = (distributorMap.get(accId).DistributorCarBrandSupplied__c != null && distributorMap.get(accId).DistributorCarBrandSupplied__c.contains(assRecord.Manufacturer__c));

                    string combiKey = accId + '-' + prt.TECH_OriginalPart__c;
                    system.debug('<<<combiKey>>>' + combiKey);
                    boolean allowSubs = true;
                    if (isIG){
                        if (setAlreadyOrderedParts.contains((prt.TECH_OriginalPart__c).toUpperCase())){
                           allowSubs = false ;
                        }
                        //RLA 09/07/2020 C-003857: IG - Creation IGO 
                        if (String.isnotBlank(prt.Partnumber__c) && (
                            (prt.Partnumber__c).startsWith(system.label.DEsubstiturePrefix)
                            || ( String.isnotBlank(prefixPartNumber) && (prt.Partnumber__c).startsWith(prefixPartNumber)))){
                            allowSubs = false;
                        }

                    }
                    system.debug('@@ allowSubs: '+allowSubs);
                    //if(prt.RecordTypeId == materialRt 
                    if(prt.RecordTypeId != labourRt //RLA 04/10/2018 Case C-002818: Substitution sur des manual parts  
                        && prt.Quantity__c > 0 
                        && prt.InputType__c != null 
                        && allowSubs
                        //RLA 30/07/2019 C-003344: Substitutes manual Parts for Italy  
                        && (prt.InputType__c.toUpperCase()  != 'MANUAL'|| 
                            (prt.InputType__c.toUpperCase()  == 'MANUAL' && isManualPartsAllowedforSubs))
                        ){

                        //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor  
                        techDist = distributorMap.get(accId).Tech_Distributor__c;
                        distBrand = (distributorMap.get(accId).Tech_Distributor__c+'-'+(assRecord.Manufacturer__c)).toUpperCase();
                        system.debug('<<<techDist:>>>'+techDist);
                        system.debug('<<<distBrand:>>> '+distBrand);
                       //RLA 11/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
                        // if (mapLabelCarDestination.containskey(distBrand)){
                        //     brandName = mapLabelCarDestination.get(distBrand);
                        // }
                        // system.debug('@@@@@@ before brand: '+brandName);
                        //RLA 11/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
                        if (mapLabelCarDestinationV2.containskey(distBrand)){
                            brandName = mapLabelCarDestinationV2.get(distBrand);
                        }
                        //brandName = RestDistributorUtility.getCarMappingsMatrix(distBrand);
                        if ( String.isBlank(brandName)){
                            brandName =  string.isNotBlank(assRecord.Manufacturer__c) ? assRecord.Manufacturer__c : '';  
                        } 

                        system.debug('prt.PartNumber__c' + prt.PartNumber__c);
                        system.debug('mapCombiDistIdPartIdAndDistPNumber' + mapCombiDistIdPartIdAndDistPNumber);
                        system.debug('setAllowedSubstitutes' + setAllowedSubstitutes);
                        
                        //AMI 25/01/18 : C-002041 - Distributor V2 - Do not send ASCR to distributor if no distributor price present  
                        if((prt.PartNumber__c.contains('ASCR') && mapCombiDistIdPartIdAndDistPNumber.containsKey(combiKey) && setAllowedSubstitutes.contains('CatalogSubstitute') ) || (!prt.PartNumber__c.contains('ASCR') && setAllowedSubstitutes.contains('Update OEM') && ((String.isnotblank(prt.Distributors__c) && prt.Distributors__c.contains(accId)) || isIG || (assCountry == 'DE' && isExpert) ))){
                            system.debug('@@@ i am here');
                            
                            part.ID = prt.TECH_OriginalPart__c;
                            
                            set<String> typeOfSub = new set<String> (mapdistToDisFields.get(accId).Type_of_Substitutes__c.split(';'));
                            System.debug('<<<<<typeOfSub>>>>>' + typeOfSub);
                            System.debug('<<<<<mapXrefIdtoXref.get(prt.CrossReferenceId__c)>>>>>' + mapXrefIdtoXref.get(prt.CrossReferenceId__c));
                            System.debug('<<<<<generateConnectedXrefForCountry>>>>>' + generateConnectedXrefForCountry);
                            System.debug('<<<<<mapdistToDisFields.containsKey(accId)>>>>>' + mapdistToDisFields.containsKey(accId));
                            System.debug('<<<<<mapXrefIdtoXref.containsKey(prt.CrossReferenceId__c)>>>>>' + mapXrefIdtoXref.containsKey(prt.CrossReferenceId__c));
                            Map<String, Object> mapParts = new Map<String, Object>();

                            if(generateConnectedXrefForCountry && mapdistToDisFields.containsKey(accId) && typeOfSub.contains('XREF Connected') && mapXrefIdtoXref.containsKey(prt.CrossReferenceId__c) && mapXrefIdtoXref.get(prt.CrossReferenceId__c).Connected__c){
                                //kem
                                isPartEConnected= true;
                                for(Occurence__c Occ: mapXrefIdLstOccurence.get(prt.CrossReferenceId__c)){
                                    if (accId == occ.Distributor__c){
                                        RestDistributorUtility.PartsConnectedE PartsConnectedE = new RestDistributorUtility.PartsConnectedE('',''); 
                                        PartsConnectedE.ID = prt.TECH_OriginalPart__c;
                                        PartsConnectedE.DistributorRef = occ.DistributorReference__c;
                                        tempSuppliedPartsConnectedE.add(PartsConnectedE);
                                    }
                                    System.debug('<<<<<occ.DistributorReference__c>>>>>' + occ.DistributorReference__c);
                                    System.debug('<<<<<prt.Distributor__c>>>>>' + prt.Distributor__c);
                                }
                                System.debug('<<<<<I am in the if condition>>>>>');
                                
                                System.debug('<<<<<part.DistributorRef>>>>>' + part.DistributorRef);
                                System.debug('<<<<<part.ID>>>>>' + part.ID);


                                
                                
                                System.debug('<<<<<tempSuppliedPartsConnectedE>>>>>' + tempSuppliedPartsConnectedE);

                            }else
                            {  //can supply specific parts
                                if((setCategory.contains(prt.Type__c) && makeSupplied) || (!setCategory.contains(prt.Type__c) && setPartTechOriginalPartSuppliedByDist != null && setPartTechOriginalPartSuppliedByDist.size()> 0 && setPartTechOriginalPartSuppliedByDist.contains(prt.TECH_OriginalPart__c))){
                                    part.Quantity = integer.valueOf(prt.Quantity__c);
                                    part.AllowAlternatives = 'false';
                                    
                                    part.PartNumber = mapCombiDistIdPartIdAndDistPNumber.containsKey(combiKey) ? (mapCombiDistIdPartIdAndDistPNumber.get(combiKey) != null ? mapCombiDistIdPartIdAndDistPNumber.get(combiKey) : ''): prt.PartNumber__c;
                                    part.Type = prt.Type__c;
    
                                    if(prt.CrossReferenceId__c != null && prt.Type__c != 'A'){
                                        if(mapCrossRefIdCrossRef.containsKey(prt.CrossReferenceId__c) && string.isNotBlank(mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c)){
                                            //RLA 14/03/18  Case-002380 
                                            String iamManu = mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c;
                                            if(iamManu != null ){
                                                string iamManuMapping = RestDistributorUtility.getCarMappingsMatrix((techDist + mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c).toUpperCase());
                                                 //WCH 02/04/19 C-003155 SASV2; Call to SAS for B parts during Substitution
                                                iamManuMapping = (!String.isblank(iamManuMapping)) ? iamManuMapping : (mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c).toUpperCase();
                                                part.Manufacturer = iamManuMapping != null ? iamManuMapping : brandName;
                                            }
                                            else{
                                                part.Manufacturer = brandName; //RLA 14/03/18  Case-002380 
                                            }
                                        }else{
                                            part.Manufacturer = brandName; //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
                                        }
                                    }else{
                                        part.Manufacturer = brandName; //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
                                    }
                                    
                                    part.Description = prt.Description__c; 
    
                                    //add to list
                                    tempSuppliedParts.add(part);
                                    system.debug('<<<tempSuppliedParts>>>'+ tempSuppliedParts);
                                }else{
                                    //can supply all parts
                                    part.Quantity = integer.valueOf(prt.Quantity__c);
                                    part.AllowAlternatives = 'false';
                                    part.ID = prt.TECH_OriginalPart__c;
                                    part.PartNumber = mapCombiDistIdPartIdAndDistPNumber.containsKey(combiKey) ? (mapCombiDistIdPartIdAndDistPNumber.get(combiKey) != null ? mapCombiDistIdPartIdAndDistPNumber.get(combiKey) : ''): prt.PartNumber__c;
                                    part.Type = prt.Type__c;
    
                                    if(prt.CrossReferenceId__c != null && prt.Type__c != 'A'){
                                        if(mapCrossRefIdCrossRef.containsKey(prt.CrossReferenceId__c) && string.isNotBlank(mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c)){
                                            String iamManu = mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c;
                                            if(iamManu != null ){
                                                string iamManuMapping = RestDistributorUtility.getCarMappingsMatrix((techDist + mapCrossRefIdCrossRef.get(prt.CrossReferenceId__c).IAMManufacturer__c).toUpperCase());
                                                part.Manufacturer = iamManuMapping != null ? iamManuMapping : brandName;
                                            }
                                            else{
                                                part.Manufacturer = brandName; 
                                            }
                                        }else{
                                            part.Manufacturer = brandName;
                                        }
                                    }else{
                                        part.Manufacturer = brandName;
                                    }
                                    
                                    part.Description = prt.Description__c;
    
                                    //add to list
                                    tempSuppliedParts.add(part);   
                                    system.debug('<<<tempSuppliedParts2>>>'+ tempSuppliedParts);
                                }

                            }

                          
                            
                        }//end check if ascr contains dp
                    }//end check on part recrordtype + quantity
                }
            }//end looping in partlist
            System.debug('<<<<<mapPartIdtoDisRef>>>>>' + mapPartIdtoDisRef);

            System.debug('<<<<<tempSuppliedParts>>>>>' + tempSuppliedParts);
            System.debug('<<<<<tempSuppliedPartsConnectedEs>>>>>' + tempSuppliedPartsConnectedE);

            //build distributorObj
            
            if((tempSuppliedParts != null && tempSuppliedParts.size() > 0) || (tempSuppliedPartsConnectedE !=null && tempSuppliedPartsConnectedE.size() > 0)){
                if (distributorMap.containskey(accId)){                    
                    idForExpert = distributorMap.get(accId).IdforExpert__c;
                }  
                 //RLA 31/10/2020 C-004018: IG - Efa requirements
                String bsExtId = RestdistributorUtility.getBSExtId (distributorMap.get(accId).Tech_Distributor__c + '-' + bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c);
                //RLA 20/04/2020 Case 3695: Subject IG - IGP Substitution part
                // for (String accountId: distributorMap.keyset()){

                    if((tempSuppliedPartsConnectedE !=null && tempSuppliedPartsConnectedE.size() > 0)){
                        distributorObj.put(distributorMap.get(accId).Tech_Distributor__c,new RestDistributorUtility.distributorXref('', null,false, tempSuppliedPartsConnectedE,bsExtId));
                        System.debug('<<<<<distributorObj1>>>>>' + distributorObj);

                    }
                    if((tempSuppliedParts != null && tempSuppliedParts.size() > 0)){
                        distributorObj.put(distributorMap.get(accId).Tech_Distributor__c,new RestDistributorUtility.distributor('', null,false, tempSuppliedParts,bsExtId));
                        System.debug('<<<<<distributorObj2>>>>>' + distributorObj);

                    }
                // }
                
                // distributorObj.put('SAS',new RestDistributorUtility.distributor('', null, tempSuppliedParts));
                system.debug('@@ distributorObj: '+distributorObj);

            }
        }//end looping in account

        
        //isExpert = false;
        //RLA 23/04/2018 Case-2498: There is a need to be able to query Stock on Distributor connected for Expert
        if (isExpert){
            //if (String.isNotBlank(idForExpert)){
                if (idForExpert == 'DONOTSEND'){
                    
                    BodyShop = null;
                }
                else{
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop                    
                    if (bodyshopToReplace != null){
                        BodyShop = new RestDistributorUtility.BodyShop(
                            bodyshopToReplace.Name,
                            String.isNotBlank(idForExpert) ? idForExpert : '',
                            string.isNotBlank(bodyshopToReplace.VATNumber__c) ? bodyshopToReplace.VATNumber__c : '');
                    
                    }
                    //build bodyshop
                    else if(bsRefAccountMap.size() > 0){
                    

                        BodyShop = new RestDistributorUtility.BodyShop(
                            bsRefAccountMap.get(assRecord.BodyShop__c).Name,
                            String.isNotBlank(idForExpert) ? idForExpert : '',
                            string.isNotBlank(bsRefAccountMap.get(assRecord.BodyShop__c).VATNumber__c) ? bsRefAccountMap.get(assRecord.BodyShop__c).VATNumber__c : '');
                    }//end if bsRefAccountMap.size() > 0

                }
           // }
                        
        }
        else{
            //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
            if (bodyshopToReplace != null){
                BodyShop = new RestDistributorUtility.BodyShop(
                    bodyshopToReplace.Name,
                    //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
                    RestDistributorUtility.isColer(bodyshopToReplace.ReferenceNumber__c)? system.label.FakeBodyshopReference: string.isNotBlank(bodyshopToReplace.ReferenceNumber__c) ? bodyshopToReplace.ReferenceNumber__c : '', //RLA case 2603
                    //string.isNotBlank(bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c) ? bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c : '',
                    string.isNotBlank(bodyshopToReplace.VATNumber__c) ? bodyshopToReplace.VATNumber__c : '');

            }
            //build bodyshop
            else if(bsRefAccountMap.size() > 0){
                BodyShop = new RestDistributorUtility.BodyShop(
                    bsRefAccountMap.get(assRecord.BodyShop__c).Name,
                    //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
                    RestDistributorUtility.isColer(bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c)? system.label.FakeBodyshopReference: string.isNotBlank(bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c) ? bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c : '', //RLA case 2603
                    //string.isNotBlank(bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c) ? bsRefAccountMap.get(assRecord.BodyShop__c).ReferenceNumber__c : '',
                    string.isNotBlank(bsRefAccountMap.get(assRecord.BodyShop__c).VATNumber__c) ? bsRefAccountMap.get(assRecord.BodyShop__c).VATNumber__c : '');
            }//end if bsRefAccountMap.size() > 0
            else{
                BodyShop = new RestDistributorUtility.BodyShop('','','');
            }
                   
        }
        
        //build vehicle
         Vehicle = new RestDistributorUtility.Vehicle(
            //string.isNotBlank(assRecord.Manufacturer__c) ? assRecord.Manufacturer__c : '', 
            brandName, //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
            string.isNotBlank(assRecord.ModelV2__c) ? assRecord.ModelV2__c : '',
            assRecord.FirstRegistrationDate__c != null ? string.valueOf(assRecord.FirstRegistrationDate__c) : '01/01/1900', //NPE 10/02/2022 C-004587
            string.isNotBlank(assRecord.PlateNumber2__c) ? assRecord.PlateNumber2__c : '',
            string.isNotBlank(assRecord.VINNumber__c) ? assRecord.VINNumber__c : '',
            null);
            
            system.debug('<<<<distributorObj>>>>' + distributorObj);   

        //build main request
        if(distributorObj != null && distributorObj.size() > 0){
            mainRequest = new RestDistributorUtility.mainRequest(
                string.isNotBlank(assRecord.ClaimReference__c) ? assRecord.ClaimReference__c : '',
                false,
                'Draft',
                '',
                (object)distributorObj,
                BodyShop,
                Vehicle);

            //serialise request while eliminating null param
            req                                                           = Json.serialize(mainRequest,true);
        }
        
        system.debug('<<<<mainRequest>>>>' + mainRequest);   

        system.debug('## req ' + req);
        wsRequestCallout = req;
        
        system.debug('## End buildDistributorRequest');
        return req;
    }

    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - Method used to launch callout
    //                        - launch callout + catch potential errors + call processing for successful response
    //                        - received
    public static updatedPartsFromDistCallOut launchCallOut(
        string req,
        boolean doNotProcessResp,
        integer noOfAss,
        map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart,
        map <string, string> mapTechOriginalPartKeyCorrespondingAssId,
        map <String, String> mapPrioTechDist//RLA 20/04/2020 Case 3695: Subject IG - IGP Substitution part
        ){
        
        system.debug('## Start launchCallOut');
        //WCH 07/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'EIP_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

        //initialise rest callout
        HttpResponse response = new HttpResponse();
        Http http = new http();
        HttpRequest request = new HttpRequest();

        datetime qryStart = datetime.now();

        //initialise callout methods return type
        updatedPartsFromDistCallOut returnWrap;

        request.setEndpoint((String)responseEIPEndpoint.get('EIP_EndPoint'));//WCH 18/08/2020 C-003864
        request.setMethod('POST');
        request.setTimeout(integer.valueOf(system.label.EIPTimeout));
        request.setHeader('Content-Type','application/json; charset=UTF-8');
        request.setbody(req);

        try{
            response = http.send(request);
            system.debug('## response ' + response);
            time6 = ((datetime.now()).getTime() - qryStart.getTime());
            time6 = (time6.divide(1000, 5));

            qryStart = datetime.now();


            //process response
            if(response != null && !doNotProcessResp){
                 wSResponseCallout = response.getBody();
                Boolean isSimulation = false;
                system.debug('## wSResponseCallout ' + wSResponseCallout);
                if (system.label.responseCalloutDist != 'none' && system.label.responseCalloutDist.StartsWith('a0D')){
                    Log__c logResponse = [Select id,WSResponse__c from Log__c Where Id = :system.label.responseCalloutDist];
                    
                    if ( logResponse.WSResponse__c != null){
                        isSimulation = true;
                        wSResponseCallout = logResponse.WSResponse__c;
                    }
                }
               

                System.debug('wSResponseCallout' + wSResponseCallout);

                if(response.getStatusCode() == 200 || isSimulation ) {
                    //process received response
                    returnWrap = processDistResponse(wSResponseCallout,noOfAss,mapTechOriginalPartKeyCorrespondingPart,mapTechOriginalPartKeyCorrespondingAssId, mapPrioTechDist);//RLA 20/04/2020 Case 3695: Subject   IG - IGP Substitution part
                    // returnWrap = processDistResponse(response.getBody(),noOfAss,mapTechOriginalPartKeyCorrespondingPart,mapTechOriginalPartKeyCorrespondingAssId, mapPrioTechDist);//RLA 20/04/2020 Case 3695: Subject   IG - IGP Substitution part

                }else{
                    returnWrap = new updatedPartsFromDistCallOut(new map <string,PartList__c>(),new list <PartList__c>(),'Call to Distributor Failed!Contact System Admin.',new map <string,PartList__c>(),new map <string,PartList__c>());

                    //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
                    //                                           - fill in error encountered last time callout effected
                    distErrorMsg = response.getBody() != null ? response.getBody() : 'Call to Distributor Failed!Contact System Admin.';
                }
            }else{
                returnWrap = new updatedPartsFromDistCallOut(new map <string,PartList__c>(),new list <PartList__c>(),'Call to Distributor Failed!Contact System Admin.',new map <string,PartList__c>(),new map <string,PartList__c>());
                
                //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
                //                                           - fill in error encountered last time callout effected
                distErrorMsg = response.getBody() != null ? response.getBody() : 'Call to Distributor Failed!Contact System Admin.';
            }
            time7 = ((datetime.now()).getTime() - qryStart.getTime());
            time7 = (time7.divide(1000, 5));
        }catch(System.CalloutException e) {
            //return error message
            //call out exception
            system.debug('Call out exception ' + e);
            returnWrap = new updatedPartsFromDistCallOut(new map <string,PartList__c>(),new list <PartList__c>(),e.getMessage(),new map <string,PartList__c>(),new map <string,PartList__c>());

            //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
            //                                           - fill in error encountered last time callout effected
            distErrorMsg = e.getMessage();
        }

        //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
        //                                           - fill in last datetime callout effected
        lastCallOut = system.now();

        system.debug('## End launchCallOut');
        return returnWrap;
    }
                            
    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - Method used to process distributor response
    //                        - update original part with distributor info and create susbstitute
    public static updatedPartsFromDistCallOut  processDistResponse(
        string respFromDistributor,
        integer noOfAss,
        map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart,
        map <string, string> mapTechOriginalPartKeyCorrespondingAssId,
        map <String, String> mapPrioTechDist //RLA 20/04/2020 Case 3695: Subject    IG - IGP Substitution part
        ){

        system.debug('## Start processDistResponse');
        System.debug('//mapTechOriginalPartKeyCorrespondingPart '+mapTechOriginalPartKeyCorrespondingPart);
        System.debug('//mapTechOriginalPartKeyCorrespondingAssId '+mapTechOriginalPartKeyCorrespondingAssId);
        System.debug('//mapPrioTechDist '+mapPrioTechDist);
        System.debug('//respFromDistributor'+respFromDistributor);

        //initialise wrapper to send as method return type
        updatedPartsFromDistCallOut updatedPartsWrap;

        //map and list to send updated partlist to upsert
        map <string,PartList__c>  mapTechOriginalKeyOriginalPartToUpdate = new map <string,PartList__c>();
        
        list <PartList__c> substitutePartToUpdate = new list <PartList__c>();

        //string used to check if response status returned is true or false
        string respToProcess = respFromDistributor;

        //deserialise global response to see if success is false or true
        if(noOfAss == 1){
            respFromDistributor = '[' + respFromDistributor + ']';
        }


        //deserialse returned info from connected distributors into list of lines
        map <string, List <Line>> mapDistNameListLineReturned = deserialiseRESP(respFromDistributor,noOfAss);

        //RLA 20/04/2020 Case 3695: Subject IG - IGP Substitution part
        map<String, list<Line>> mapAllAllowedLinesWithDist = new map<String,list<line>>();
        
        map <string,PartList__c> mapTechOriginalKeyOriginalPartNoDist =new map <string,PartList__c>();

        //RLA 12/08/2020 C-003881: IG - Aprime per distributor
        map<String,Partlist__c> mapSubsToDel = new map <String, Partlist__c>();

        //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
        Set<String> setAllowedSubstitutes = new Set<String>();

        List<PartList__c> plToRemove = new List<PartList__c>();//xxx

        System.debug('//mapDistNameListLineReturned'+mapDistNameListLineReturned);
        System.debug('//mapEligiblePONameELigiblePO'+mapEligiblePONameELigiblePO);

        for(string distName : mapDistNameListLineReturned.keySet()){

            //xxxwch
            Map<String,Map<String,List<String>>> allowedPartsByCurrentDist = new Map<String,Map<String,List<String>>>();
            if(mapEligiblePONameELigiblePO.containsKey(distName) && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).AllowedBPartsStatusForDistConnected__c))
                allowedPartsByCurrentDist=splitForBPartTypesStatusPerDist(mapEligiblePONameELigiblePO.get(distName).AllowedBPartsStatusForDistConnected__c,distName);

            for(Line ln : mapDistNameListLineReturned.get(distName)){
                //string receivedStatus = (ln.Status == 'CONFIRMED') ? 'Available' : ((ln.Status == 'CONFIRMEDWITHDELAY ') ? 'In order' : 'Unavailable');
                string receivedStatus = '';
                System.debug('//distName'+distName);
                System.debug('//mapEligiblePONameELigiblePO.get(distName)'+mapEligiblePONameELigiblePO.get(distName));
                if (String.isnotBlank(mapEligiblePONameELigiblePO.get(distName).Type_of_Substitutes__c)){
                    setAllowedSubstitutes = new Set<String>(mapEligiblePONameELigiblePO.get(distName).Type_of_Substitutes__c.split(';')) ;
                }
                // System.debug('@@ ln'+ln);
                //RLA 23/03/19 Case-2408 upsertAssessment - Stock availability manageable at Account level
                if (mapEligiblePONameELigiblePO.containsKey(distName)){

                    if (ln.Status == 'CONFIRMED'
                        && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c;
                    } 
                    else if (ln.Status == 'CONFIRMEDWITHDELAY'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c;
                    } 
                    else if (ln.Status == 'PARTIAL'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c;
                    } 
                    else if (ln.Status == 'NOTFOUND'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c;
                    } 
                    else if (ln.Status == 'OTHER'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c;
                    } 
                }
                // ASE: 23/04/18
               //RLA   30/04/2022    C-004086: BE - Van Wezel Distributor
                if(ln.ID.contains('-ASCR-') &&  setAllowedSubstitutes.contains('CatalogSubstitute') ){
                    system.debug('@@@ RLA C-004086 here for ASCR'+ ln.ID);
                    ASCRStockMap.put(ln.ID, receivedStatus);
                    //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
                    ASCRStatusMap.put(ln.ID,ln.Status);
                }

                //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
                //                        - get rebate info
                decimal rebate = (mapEligiblePONameELigiblePO.containsKey(distName) && mapEligiblePONameELigiblePO.get(distName).Rebate__c != null) ? 
                                (mapEligiblePONameELigiblePO.get(distName).Rebate__c) /100 : 0.0;

                set<String> setDistName =  new Set<String>((system.label.DistributorsConnectedUseRebate).split(';'));
                set<String> setNotAllowedStatus =  new Set<String>((system.label.statusForSubsToDel).split(';'));
                set<String> setDistNameLineDiscount =  new Set<String>((system.label.AdditionalPartDistributor).split(';'));

                // ASE: 07/05/18 : C-002528
                decimal discountToUse =  (setDistNameLineDiscount.contains(distName)) ? (ln.AlphaScaleDiscountAdditional/100)  : ((setDistName.contains(distName))? rebate : 0.0); 
                // system.debug('@@ discountToUse'+discountToUse);
                             
                String assessId;
                Boolean isEligible;
                
                
                Boolean containsLine = mapTechOriginalPartKeyCorrespondingAssId.containsKey(ln.ID);
                
                if(containsLine){
                    assessId = mapTechOriginalPartKeyCorrespondingAssId.get(ln.ID);
                    
                    list<String> booleanList = isEligibleMap.containsKey(assessId) ? isEligibleMap.get(assessId).split(':') : null;
                    
                    isEligible = booleanList != null ? Boolean.valueOf(booleanList[0]) : false;                            
                }

                System.debug('//isEligible'+isEligible);

                //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
                Boolean allowSubs = true;
                if (String.isnotBlank(ln.Description)
                    && callersystemGlo == 'FR_DIVA'
                    && String.isnotBlank(system.label.DescriptionWithNoSubstitute)
                    && ln.Description.contains(system.label.DescriptionWithNoSubstitute)
                    ){  
                    allowSubs = false;
                }
                
                //RLA 09/04/2020 C-003693: IG - Substitution
                if (String.isnotblank(substitutionType) && isIG ){
                    List<String> lstSubstitutionType = substitutionType.split(';');
                    set<String> setSubsType = new set<String> ();
                    setSubsType.addAll(lstSubstitutionType);
                    if (!setSubsType.contains(ln.Type)){
                        allowSubs = false;    
                    }
                }

                //RLA 01/03/2021 C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY
                Boolean isASPStatusOK = false;
                // isEligibleToOrder = false;

                // set<String> setDistNameLineDiscount =  new Set<String>((system.label.AdditionalPartDistributor).split(';'));
                if (setDistNameLineDiscount.contains(distName)){//found in custom label AdditionalPartDistributor
                    if (!isExpert){
                        if(discountToUse > 0
                            && ((isEligibleToOrder && ln.Status == 'CONFIRMED')
                                || (!isEligibleToOrder && (ln.Status == 'CONFIRMED' || ln.Status == 'CONFIRMEDWITHDELAY')))
                            ){
                                isASPStatusOK = true;
                        }
                    
                    }
                    else if (isExpert 
                             && discountToUse > 0 && (ln.Status == 'CONFIRMED' || ln.Status == 'CONFIRMEDWITHDELAY')){
                            isASPStatusOK = true;
                    }
                }
                else{
                    isASPStatusOK = true;
                }
                system.debug('@@ canCreateAsp: '+canCreateAsp);
                system.debug('## allowed line:' + ln.ID + '-' + ln.Status + '-' + discountToUse + '-' + containsLine + '-' +  isEligible + '-' +  canCreateAsp +  '-' + allowSubs + '-' + isASPStatusOK);

                System.debug('//line'+ln);

                if(isASPStatusOK && //RLA 01/03/2021 C-004214: Do not Create ASP on Connected Distributor if CONFIRMEDWITHDELAY
                    ln.PartNumber != null && String.isnotBlank(ln.PartNumber) && //RLA 24/09/2020
                   // ASE: 07/05/18 : C-002528
                   //(ln.AlphaScaleDiscountAdditional > 0 || rebate > 0) &&
                    discountToUse  > 0 &&
                    containsLine &&  
                    //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS
                   (!setExistingParts.contains((ln.ID).toUpperCase()) || isIG)
                   // ASE : 18/04/18: if EligibleForSubstitition is false, do not create ASP
                   && isEligible
                   && canCreateAsp //RLA 18/06/2019 : C-002602 - Pas d'ASP si la marque est en Agency Mode
                   && allowSubs //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
                   ){

                    // system.debug('## allowed line:' + ln.ID);
                    if (mapAllAllowedLinesWithDist.containsKey(distname)){
                        mapAllAllowedLinesWithDist.get(distname).add(ln);

                    }
                    else{
                        mapAllAllowedLinesWithDist.put(distName, new list<Line> {ln});
                    }

                    
                } //xxx
                else if( String.isNotBlank(ln.ID) 
                             && allowedPartsByCurrentDist.containsKey(distName)
                             && allowedPartsByCurrentDist.get(distName).containsKey('E')
                             && allowedPartsByCurrentDist.get(distName).get('E').contains(ln.Status)
                            && (ln.ID).contains('ASCR')
                             && String.isNotBlank(ln.DistributorReference)){//when contains DistributorReference, it is E part connected
                                connectedELineIds.add(ln.ID);
                }
                else if ((isIG
                        &&String.isNotBlank(ln.ID) 
                        && setNotAllowedStatus.contains(ln.Status) 
                        && !(ln.ID).contains('ASCR')) 
                        ){
                    // system.debug('@@ removing this line'+ln.ID);
                    mapTechOriginalKeyOriginalPartNoDist.put(ln.ID, new partlist__c(Stock__c = receivedStatus));
                    // mapTechOriginalKeyOriginalPartNoDist.put(ln.ID,new PartList__c(Stock__c = receivedStatus ,TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null, Distributors__c = isIG ? mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null : mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c != null ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c : null));
                    // partsToDelSet.add(system.label.DEsubstiturePrefix + ln.PartNumber);
                    System.debug('enter');
                }

                
                
            }
        }//end for building allowed lines per dist

        system.debug('@@ mapTechOriginalKeyOriginalPartNoDist: '+mapTechOriginalKeyOriginalPartNoDist);
        system.debug('@@ mapAllAllowedLinesWithDist: '+mapAllAllowedLinesWithDist);
        system.debug('@@ mapPrioTechDist: '+mapPrioTechDist);
        system.debug('@@ connectedELineIds: '+connectedELineIds);
        map<String, List <Line>> mapDistAllowedLines = new map<String, List <Line>>();

        if (isIG){
            set<String> setLinesProcess = new set<String>();
            List<String> lstPrios = new List<String>();
            if (!mapPrioTechDist.isEmpty()){
                lstPrios.addAll(mapPrioTechDist.Keyset());
                lstPrios.sort();

            }
            system.debug('@@ lstPrios: '+lstPrios);
            

            for (String priority : lstPrios){
                system.debug('@@ priority: '+priority);

                string dist = mapPrioTechDist.get(priority);
                system.debug('@@ priority: '+dist);

                if (mapAllAllowedLinesWithDist.containsKey(dist)){

                    for (line tempLine: mapAllAllowedLinesWithDist.get(dist)){

                        system.debug('@@ tempLine: '+tempLine);
                        // system.debug('@@ dist: '+dist);
                        // system.debug('@@ priority: '+priority);
                        if (mapTechOriginalKeyOriginalPartNoDist.containskey(tempLine.ID)){
                            system.debug('@@ removing this line'+tempLine.ID);
                            mapTechOriginalKeyOriginalPartNoDist.remove(tempLine.ID);

                        }


                        if (mapDistAllowedLines.containsKey(dist)){
                            if (!setLinesProcess.contains(tempLine.Id)){
                                mapDistAllowedLines.get(dist).add(tempLine);
                                setLinesProcess.add(tempLine.Id);
                                system.debug('got in another time');
                            }

                        }
                        else{
                            if (!setLinesProcess.contains(tempLine.Id)){
                                mapDistAllowedLines.put(dist, new list<Line> {tempLine});
                                setLinesProcess.add(tempLine.Id);
                                system.debug('got in first time');
                            }
                        }

                    }
                }
            }
            // system.debug('@@ setLinesProcess: '+setLinesProcess);
            // system.debug('@@ mapDistAllowedLines: '+mapDistAllowedLines);
            for (String extId : mapTechOriginalKeyOriginalPartNoDist.keyset()){                
                
                string distName = mapPrioTechDist.get(lstPrios[0]);
                // system.debug('@@ the dist with lowest prio for deleted part'+distname);

                mapTechOriginalKeyOriginalPartNoDist.get(extId).Distributors__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null;
                                                            
                mapTechOriginalKeyOriginalPartNoDist.get(extId).TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null;

                if (mapOEMIdConnectedOemID.containskey(extId)){
                    // system.debug('@@ here where you need me to be: ');

                      //RLA 12/08/2020 C-003881: IG - Aprime per distributor
                    PartList__c tempPart = new PartList__c(TECH_OriginalPart__c = mapOEMIdConnectedOemID.get(extId));
                    mapSubsToDel.put(mapOEMIdConnectedOemID.get(extId),tempPart);
                    // mapSubsToDel.put()

                }
               

            }
            
        // system.debug('@@ mapTechOriginalKeyOriginalPartNoDist: '+mapTechOriginalKeyOriginalPartNoDist);
        }
        else{
            mapDistAllowedLines.putAll(mapAllAllowedLinesWithDist);    
        }
        // system.debug('@@ mapOEMIdConnectedOemID: '+mapOEMIdConnectedOemID);

        
        
        System.debug('//mapDistAllowedLines'+mapDistAllowedLines);



        //loop to update original and/or create alternatives

        for(string distName : mapDistAllowedLines.keySet()){
            // system.debug('@@ distName: '+distName);
            //RLA 04/08/2020 C-003881: A' par distributeur
           
             
            // system.debug('@@ setAllowedSubstitutes: '+setAllowedSubstitutes);
           
            for(Line ln : mapDistAllowedLines.get(distName)){
                //string receivedStatus = (ln.Status == 'CONFIRMED') ? 'Available' : ((ln.Status == 'CONFIRMEDWITHDELAY ') ? 'In order' : 'Unavailable');
                string receivedStatus = '';
                // System.debug('@@ ln'+ln);
                //RLA 23/03/19 Case-2408 upsertAssessment - Stock availability manageable at Account level
                if (mapEligiblePONameELigiblePO.containsKey(distName)){

                    if (ln.Status == 'CONFIRMED'
                        && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c;
                    } 
                    else if (ln.Status == 'CONFIRMEDWITHDELAY'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c;
                    } 
                    else if (ln.Status == 'PARTIAL'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c;
                    } 
                    else if (ln.Status == 'NOTFOUND'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c;
                    } 
                    else if (ln.Status == 'OTHER'
                            && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c))
                    {
                        receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c;
                    } 
                }

                if (isIG){
                    //update original
                    mapTechOriginalKeyOriginalPartToUpdate.put(ln.ID,new PartList__c(Stock__c = receivedStatus ,TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null, Distributors__c = isIG ? mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null : mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c != null ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c : null));
                }
                else{
                    mapTechOriginalKeyOriginalPartToUpdate.put(ln.ID,new PartList__c(Stock__c = receivedStatus));

                }

                System.debug('isIG'+isIG);

                System.debug('//mapTechOriginalKeyOriginalPartToUpdate'+ mapTechOriginalKeyOriginalPartToUpdate);

                

                //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
                //                        - get rebate info
                decimal rebate = (mapEligiblePONameELigiblePO.containsKey(distName) && mapEligiblePONameELigiblePO.get(distName).Rebate__c != null) ? 
                                (mapEligiblePONameELigiblePO.get(distName).Rebate__c) /100 : 0.0;


                set<String> setDistName =  new Set<String>((system.label.DistributorsConnectedUseRebate).split(';'));

                set<String> setDistNameLineDiscount =  new Set<String>((system.label.AdditionalPartDistributor).split(';'));

                // ASE: 07/05/18 : C-002528
                decimal discountToUse =  (setDistNameLineDiscount.contains(distName)) ? (ln.AlphaScaleDiscountAdditional/100)  : ((setDistName.contains(distName))? rebate : 0.0); 
                system.debug('@@ discountToUse'+discountToUse);

                String assessId;
                Boolean containsLine = mapTechOriginalPartKeyCorrespondingAssId.containsKey(ln.ID);
                                
                if(containsLine){
                    assessId = mapTechOriginalPartKeyCorrespondingAssId.get(ln.ID);
                }        

                system.debug('## start creation:' + ln.Description);
                
                /*
                - Part number : "ASP-"+received Part Number 
                - Description : OEM Description - OEM Brand (OEM Part Number) 
                - AS Net Price = Distributor Public Price * (1 - Alpha Scale %)  * (1- (AS Additional Discount % OR Rebate__c))
                - AS Public Price = Distributor Public Price - AS Net Price * (AS Additional Discount % OR Rebate__c)
                    */
                string parentPartNumber = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).PartNumber__c : '';
                //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part                
                string substitutePartNumber = isIG ? system.label.DEsubstiturePrefix + ln.PartNumber : 'ASP-' + ln.PartNumber;
                String techTypeOfSubsPartNumber = 'ASP-' + ln.PartNumber;

                //AMI 14/02/18 - C-002041 - Distributor V2 - adding cleanse reference key to techoriginalpart since if asp was selected in second call, 
                //                                         - isSelected checkbox was not updated 
                string substituteKey = ln.ID + '-' +  substitutePartNumber.replaceAll( '\\s+', '');
                
                //AMI 02/02/18 - C-002041 - Distributor V2 - Updating A' Description
                string description = '';

                //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
                if(mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID)){
                    if(string.isNotBlank(ln.Brand)){
                    if (isIG){
                            description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + ln.Brand + ' -OEM (' + ln.PartNumber + ')';

                    }
                    else{
                            description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + ln.Brand + ' (' + ln.PartNumber + ') - ' + system.label.ASPDesc;
                        }
                    }else{
                        if (isIG){
                            description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' -OEM ' + '(' + ln.PartNumber + ')';
                        }
                        else{
                            description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + '(' + ln.PartNumber + ') - '+ system.label.ASPDesc;

                    }
                    }
                } 

                decimal asPublicPrice = 0.0,ASNETPRICE = 0.0;
                decimal OEMPrice = 0.0,OEMASNETPRICE = 0.0;

                //AMI 12/02/2018 - C-002041 - Distributor V2 - Update std discount and margin during A' Creation
                decimal oemStdDiscount = 0.0, oemStdMargin = 0.0;

                //ASE: 28/05/2018-C-002041 changes in calculations
                decimal aspStdDiscount = 0.0, aspStdMargin = 0.0;

                //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
                //                        - calculate discount to apply (either as additional discount or rebate)
                //                        
                decimal discount = ln.AlphaScaleDiscountAdditional > 0 ? (ln.AlphaScaleDiscountAdditional/100) : (rebate > 0 ? rebate : 0.0);

                //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                //                                         - this map will be used to pass param to calculate price values
                map <string,object> inputParamForPriceCalc = new map <string,object>();

                //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                //                                         - this map will be used get updated price values
                map <string,object> updatedPricing = new map <string,object>();

                //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                //                                         - populate inputParamForPriceCalc
                inputParamForPriceCalc.put('entity','fr');                                         
                // ASE: 07/05/18 : C-002528
                //inputParamForPriceCalc.put('discount',discount);
                inputParamForPriceCalc.put('discount', discountToUse);
                
                inputParamForPriceCalc.put('CatalogPrice',ln.CatalogPrice);
                inputParamForPriceCalc.put('AlphaScaleDiscount',ln.AlphaScaleDiscount);

                //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
                inputParamForPriceCalc.put('isIG', isIG);

                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                Decimal keepAXA = 0;
                Decimal keepNonAXA = 0;
                Decimal keepToUse = 0;

                if (bodyshopToReplace != null) {
                    keepAXA = (bodyshopToReplace.keepAXA__c != null && bodyshopToReplace.keepAXA__c != 0 ? (bodyshopToReplace.keepAXA__c) / 100 : 0);

                    keepNonAXA = (bodyshopToReplace.KeepNonAXA__c != null && bodyshopToReplace.KeepNonAXA__c != 0 ? (bodyshopToReplace.KeepNonAXA__c) / 100 : 0);
                }
                else{
                    for (Account BS: bsRefAccountMap.values()){
                        keepAXA = (BS.keepAXA__c != null && BS.keepAXA__c != 0 ? (BS.keepAXA__c) / 100 : 0);

                        keepNonAXA = (BS.KeepNonAXA__c != null && BS.KeepNonAXA__c != 0 ? (BS.KeepNonAXA__c) / 100 : 0);
                    }
                    
                }

                system.debug('@@@ keepAXA:'+keepAXA);
                system.debug('@@@ keepNonAXA:'+keepNonAXA);


                if (isNonAxa && keepNonAXA != 0){
                    keepToUse = keepNonAXA;
                }
                else if (keepAXA != 0){
                    keepToUse = keepAXA;
                }
                inputParamForPriceCalc.put('keepAXAorNONAXA', keepToUse);


                if(ln.CatalogPrice > 0){ 
                    //AMI 25/01/18 : C-002041 - Distributor V2 - Do not update price on original during A' Creation
                    /*
                    OEMPrice = ln.CatalogPrice - (ln.CatalogPrice * (ln.BodyShopDiscount/100));
                    OEMASNETPRICE = (ln.CatalogPrice * (ln.BodyShopDiscount/100));*/
                    
                    //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                    //                                         - get updated values
                    updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPrices(inputParamForPriceCalc);
                    

                    ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;
                    asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;
                    oemStdDiscount = updatedPricing.containsKey('oemStdDiscount') ? (decimal)updatedPricing.get('oemStdDiscount') : 0.0;
                    oemStdMargin = updatedPricing.containsKey('oemStdMargin') ? (decimal)updatedPricing.get('oemStdMargin') : 0.0;
                    aspStdDiscount = updatedPricing.containsKey('aspStdDiscount') ? (decimal)updatedPricing.get('aspStdDiscount') : 0.0;
                    aspStdMargin = updatedPricing.containsKey('aspStdMargin') ? (decimal)updatedPricing.get('aspStdMargin') : 0.0;
                }
                 //RLA 22/04/2020  Case 3695: Subject   IG - IGP Substitution part
               
                //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
                //                        - apply additional check before creating A' Parts
                //RLA NONAXA
                Decimal priceOfOEMToCompare = 922337203685480000.00;
                if (mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) && mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Price__c != null && !isNonAxa){
                    priceOfOEMToCompare = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Price__c;
                }
                        
                system.debug('## priceOfOEMToCompare'+priceOfOEMToCompare);


                if(priceOfOEMToCompare > asPublicPrice || isIG)
                {
                    system.debug('## creation of parts 2');
                    //AMI 25/01/18 : C-002041 - Distributor V2 - Do not update price on original during A' Creation
                    /*//update pricing for OEM PARTS
                    PartList__c tempPartList = mapTechOriginalKeyOriginalPartToUpdate.get(ln.ID);
                    tempPartList.Price__c = OEMPrice;
                    tempPartList.ASNetPrice__c = OEMASNETPRICE;
                    tempPartList.StandardDiscount__c = ln.BodyShopDiscount != null ? ln.BodyShopDiscount : 0.0;
                    tempPartList.StandardMargin__c = ln.BodyShopDiscount != null && ln.BodyShopDiscount > 0 ? (OEMPrice * (ln.BodyShopDiscount/100)) : 0.0;

                    //add to mapTechOriginalKeyOriginalPartToUpdate
                    mapTechOriginalKeyOriginalPartToUpdate.put(ln.ID,tempPartList);*/

                    //if there exists IGP do not update OEM
                    //RLA 09/07/2020 C-003857: IG - Creation IGO
                    // if (!mapOEMIdConnectedOemID.containskey(ln.ID)){
                    //RLA 04/08/2020 C-003881: A' par distributeur
                    if (setAllowedSubstitutes.size() > 0 || isExpert){

                        if (setAllowedSubstitutes.contains('Connected Substitute') || isExpert){
                            //AMI 12/02/2018 - C-002041 - Distributor V2 - Update std discount and margin during A' Creation
                            PartList__c tempPartList = mapTechOriginalKeyOriginalPartToUpdate.get(ln.ID);
                            tempPartList.StandardDiscount__c = oemStdDiscount > 0 ? oemStdDiscount.setScale(2) : 0.0;
                            tempPartList.StandardMargin__c = oemStdMargin > 0 ? oemStdMargin.setScale(2) : 0.0;

                            //add to mapTechOriginalKeyOriginalPartToUpdate
                            mapTechOriginalKeyOriginalPartToUpdate.put(ln.ID,tempPartList);

                            

                            //AMI 08/12/17 : C-002041 - Distributor V2 - changing Alpha_Scale_MRID__c for ASP parts
                            PartList__c tempPart = new PartList__c(TECH_OriginalPart__c = substituteKey,
                                                                    Name = description.left(80),
                                                                    ProducerName__c = ln.Manufacturer,
                                                                    Quantity__c = integer.valueOf(ln.Quantity),
                                                                    Type__c = ln.Type,
                                                                    Stock__c = receivedStatus,

                                                                    //AMI 15/02/18 - C-002041 - Distributor V2 - Removing 'ASP' in part number 
                                                                    //ASE 17/04/18 C-002477: PartNumber__c = ln.PartNumber.replaceAll( '\\s+', ''),
                                                                    PartNumber__c = substitutePartNumber.replaceAll( '\\s+', ''),
                                                                    Description__c = description,
                                                                    Price__c = asPublicPrice.setScale(2),
                                                                    Assessment__r = new Assessment__c(AssessmentID__c = assessId),
                                                                    OriginalPart__r = new PartList__c(TECH_OriginalPart__c = ln.ID),
                                                                    ASNetPrice__c = ASNETPRICE.setScale(2),
                                                                    Alpha_Scale_MRID__c = substitutePartNumber.replaceAll( '\\s+', ''),

                                                                    //AMI 19/12/17 : Adding Discount and margin to A' Parts
                                                                    //**** ASE: 28/05/2018-C-002041changes in calculations*/
                                                                    //StandardDiscount__c = ln.BodyShopDiscount != null ? ln.BodyShopDiscount.setScale(2) : 0.0,
                                                                    //StandardMargin__c = ln.BodyShopDiscount != null && ln.BodyShopDiscount > 0 ? (price * (ln.BodyShopDiscount/100)).setScale(2) : 0.0,

                                                                    StandardDiscount__c = aspStdDiscount,
                                                                    StandardMargin__c = aspStdMargin,

                                                                    /****/ 

                                                                    //AMI 22/02/18 : C-002041 - Distributor V2 - Adding missing field to ASP Response
                                                                    InputType__c = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).InputType__c : '',
                                                                    Currency__c = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Currency__c : ''
                                                                    //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                                                    ,VAT__c = (assessId != null && mapConfigCountryCodeInfo.get(assessId.left(2)) != null && mapConfigCountryCodeInfo.get(assessId.left(2)).CountryVAT__c != null) ? mapConfigCountryCodeInfo.get(assessId.left(2)).CountryVAT__c : null
                                                                    ,Distributor__c= mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null
                                                                    ,TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null
                                                                    //RLA 03/04/2019 C-3133 
                                                                    ,NextDistributors__c = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID)? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).NextDistributors__c : null
                                                                    ,Distributors__c = isIG ? mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null : mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c : null,
                                                                    //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
                                                                    techTypeOfSubsPartNumber__c = techTypeOfSubsPartNumber,
                                                                    TechCatalog_Price_Dist_Connected__c =ln.CatalogPrice
                                                                    );


                            //add to substitutePartToUpdate
                            substitutePartToUpdate.add(tempPart);

                            //AMI 13/11/17 - C-002041 - Distributor V2 - response generation after upsert operationbuidl
                            //                                         - build setSubsCreatedByDistCallout
                            setSubsCreatedByDistCallout.add(substituteKey);

                            //AMI 20/11/17 - C-002041 - Distributor V2 - building mapSubstituteTechOriginalPartPartlist
                            mapSubstituteTechOriginalPartPartlist.put(tempPart.TECH_OriginalPart__c,tempPart);

                            Boolean allowA = true;
                            if (mapPartTypePriority.size() > 0 && !mapPartTypePriority.containskey(tempPart.Type__c )){
                                allowA = false;

                            }
                            system.debug('@@ allowA: '+allowA);

                            //AMI 20/11/17 - C-002041 - Distributor V2 - building mapOriginalTechOriginalPartSetSubsTechOriginalPart
                            //RLA 19/01/2022 C-004449: Algo Substitution Albax
                            if(!( (isForcedNoA || isForcedAlbax)  && tempPart.Type__c == 'A')                               
                                && allowA){//RLA 28/01/2020 C-003524 : Change Recommended part in France  
                                buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(ln.ID,tempPart);
                                system.debug('^^^ here 3: '+tempPart);

                            }    

                            
                            if(isNONAXA){                                        
                                if(mapEntitysetPartListTechId.containsKey(encode)){
                                    mapEntitysetPartListTechId.get(encode).add(tempPart.TECH_OriginalPart__c);
                                }
                                else{
                                    mapEntitysetPartListTechId.put(encode, new set<String>{tempPart.TECH_OriginalPart__c});
                                }
                            }

                        }
                        else if (setExistingParts.contains(substituteKey)){
                            //RLA 12/08/2020 C-003881: IG - Aprime per distributor
                            PartList__c tempPart = new PartList__c(TECH_OriginalPart__c = substituteKey);
                            mapSubsToDel.put(substituteKey,tempPart);
                        }
                    }//end create connected substitute
                    

                    //RLA 09/07/2020 C-003857: IG - Creation IGO 
                    CustomerInformationsMapping__mdt customerInformationsMapping;
                    Boolean isConnectedOemAllowed = false;
                    if (String.isnotblank(insuranceBroker)){
                        customerInformationsMapping = RestDistributorUtility.getcustomerMapping(insuranceBroker);
                    } 
                    if (customerInformationsMapping != null){
                        isConnectedOemAllowed = customerInformationsMapping.Activate_Connected_OEM__c;

                    }
                   
                    if(isConnectedOemAllowed
                        && (setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected OEM'))){//RLA 04/08/2020 C-003881: A' par distributeur
                        map <string,object> inputParamForIGO = new map <string,object>();
                        map <string,object> getIGO = new map <string,object>();

                        inputParamForIGO.put('line',ln);
                        inputParamForIGO.put('mapTechOriginalPartKeyCorrespondingPart',mapTechOriginalPartKeyCorrespondingPart);
                        inputParamForIGO.put('mapEligiblePONameELigiblePO',mapEligiblePONameELigiblePO);
                        inputParamForIGO.put('isIG',isIG);
                        inputParamForIGO.put('receivedStatus',receivedStatus);
                        inputParamForIGO.put('distName',distName);
                        inputParamForIGO.put('assessId',assessId);
                        inputParamForIGO.put('insuranceBroker',insuranceBroker);

                        getIGO = RestDistributorUtility.createIGO(inputParamForIGO);
                        System.debug('@@@ getIGO:'+getIGO);
                        System.debug('@@@ oemStdDiscount:'+oemStdDiscount);
                        System.debug('@@@ oemStdMargin:'+oemStdMargin);

                        //RLA 18/02/2021 C-004176:UpsertAssessment : valeurs renvoyées pour l'OEM Margin et OEM Discount
                        // if (!mapTechOriginalKeyOriginalPartToUpdate.containsKey(ln.ID))  {
                            PartList__c tempPartList = mapTechOriginalKeyOriginalPartToUpdate.get(ln.ID);
                            tempPartList.StandardDiscount__c = oemStdDiscount > 0 ? oemStdDiscount.setScale(2) : 0.0;
                            tempPartList.StandardMargin__c = oemStdMargin > 0 ? oemStdMargin.setScale(2) : 0.0;

                            //add to mapTechOriginalKeyOriginalPartToUpdate
                            mapTechOriginalKeyOriginalPartToUpdate.put(ln.ID,tempPartList);
                        // }                      
                        

                        PartList__c tempOemConnected = getIGO.containskey('partlist') ? (PartList__c) getIGO.get('partlist') : null;
                        Boolean allowA = true;
                        if (mapPartTypePriority.size() > 0 && !mapPartTypePriority.containskey(tempOemConnected.Type__c )){
                            allowA = false;

                        }

                        if (tempOemConnected != null){
                            substitutePartToUpdate.add(tempOemConnected);
                            mapSubstituteTechOriginalPartPartlist.put(tempOemConnected.TECH_OriginalPart__c,tempOemConnected);
                            setSubsCreatedByDistCallout.add(tempOemConnected.TECH_OriginalPart__c);
                            //RLA 19/01/2022 C-004449: Algo Substitution Albax
                            if(!( (isForcedNoA || isForcedAlbax) && tempOemConnected.Type__c == 'A')                                
                            && allowA){//RLA 28/01/2020 C-003524 : Change Recommended part in France  
                            buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(ln.ID,tempOemConnected);
                            system.debug('^^^ here 3: '+tempOemConnected);

                        }
                       

                    }  





                    }                
                }
            }//end looping in lines

            System.debug('@@@ mapTechOriginalKeyOriginalPartToUpdate:'+mapTechOriginalKeyOriginalPartToUpdate);
            
            System.debug('@@@ ASCRStockMap:'+ASCRStockMap);
            System.debug('@@@ ASCRStatusMap:'+ASCRStatusMap);
            
            System.debug('@@@ substitutePartToUpdate:'+substitutePartToUpdate);
        }//end for loop in lines per dist
        System.debug('@@@ mapSubsToDel:'+mapSubsToDel);
       
        

        
        //add to wrapper
        updatedPartsWrap = new updatedPartsFromDistCallOut(mapTechOriginalKeyOriginalPartToUpdate,substitutePartToUpdate,'',mapTechOriginalKeyOriginalPartNoDist,mapSubsToDel);

        system.debug('## End processDistResponse');
  
        return updatedPartsWrap;
    }

    //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
    //                        - Method used to deserialse distributor response to get all lines (irrespective of their assessment)
    public static map <string, List <Line>> deserialiseRESP(string respFromDistributor,integer noOfAss){
        system.debug('## Start deserialiseRESP');

        map <string, List <Line>> mapDistNameListLineReturned = new map <string, List <Line>>();

        string responseToProcess = respFromDistributor;

        if(noOfAss == 1){
            respFromDistributor = '[' + respFromDistributor + ']';
        }

        //deserialise received response
        list <object> deserialiseJSONResp = (list <object>)JSON.deserializeUntyped(respFromDistributor);
        

        //loop in deserialise objects to get distributors
        for(object obj : deserialiseJSONResp){
            //serialise json to be able to look for lines
            string objToSerialise = JSON.serialize(obj);  
            
            
            

            //AMI 02/02/18 - C-002041 - Distributor V2 - Updating A' Description
            //                        - Getting Brand info from returned JSON 
            //remove square brackets to be able to deserialise into obj
            string singleObjToSerialise = (objToSerialise.removeEnd(']')).removeStart('[');
            

            map <string,object> receivedJSON = (map <string,object>)JSON.deserializeUntyped(singleObjToSerialise);
            
            map <string,object> vehicle = (map <string,object>)receivedJSON.get('Vehicle');
            string brand = vehicle.containsKey('Brand') ? (string)vehicle.get('Brand') : '';
            //RLA 26/02/2020 Citroen Brand update
            brand = modifyBrandCitroen(brand);
            //deserialise received distributor
            map <string,object> mapDistributor = (map <string,object>)receivedJSON.get('Distributors');
            

            string serialiseDistributor = JSON.serialize(mapDistributor);   
            

            //ASE : 07/05/2018: Rework response EIP
            //build map distributor name distributor wrapper
            map <string, dist> deserialiseDist = (map <string, dist>)JSON.deserialize(serialiseDistributor, map <string, dist>.class);
            

            if( deserialiseDist != null ){
                for(String distName : deserialiseDist.keyset()){
                    dist distIns = deserialiseDist.get(distName);
                    system.debug('@@ distIns: '+distIns);
                    // string message = objToSerialise.substringBetween('{"Message":"','",');
                    system.debug('@@ distIns: '+distIns.Message);   
                    string message = distIns.Message;        
                    system.debug('@@ message: '+message);

                    if ((message != null && string.isBlank(message)) || message == null){
                        if(distIns.Success == 'true'){
                            list <Line> part = distIns.Lines;
                            if(string.isNotBlank(brand)){
                                for(Line ln : part){
                                    ln.Brand = brand;
                                }
                            }//end if string.isNotBlank(brand)

                            //add to map
                            if(mapDistNameListLineReturned.containsKey(distname)){
                                mapDistNameListLineReturned.get(distname).addAll(part);
                            }
                            else{
                                mapDistNameListLineReturned.put(distname, new list <Line>(part));
                            }
                        }
                        else{
                            distErrorMsg = 'Success false';
                        }
                    }
                    else{
                         distErrorMsg = message; 
                    }
                }
            }
            else{
                //AMI 16/11/2017 - C-002041 - Distributor V2 - update log based on distributor callout status
                //                                           - fill in error encountered last time callout effected
                distErrorMsg = 'No distributor Response'; 
            }            
        }

        system.debug('## End deserialiseRESP');
        return mapDistNameListLineReturned; 
    }

    //AMI 20/11/17 : C-002041 - Distributor V2 - Pricing Calculation
    //                        - Method used to build mapOriginalTechOriginalPartSetSubsTechOriginalPart which will be used to calculate min price
    public static void buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(string originalKey,PartList__c tempPartList){
        system.debug('## Start buildMapOriginalTechOriginalPartSetSubsTechOriginalPart');

        if(tempPartList != null){
            if(mapOriginalTechOriginalPartSetSubsTechOriginalPart.containsKey(originalKey)){
                mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey).add(tempPartList.TECH_OriginalPart__c);
            }
            else{
                mapOriginalTechOriginalPartSetSubsTechOriginalPart.put(originalKey,new set <string>{tempPartList.TECH_OriginalPart__c});
            }
        }//end if tempPartList != null

        system.debug('## End buildMapOriginalTechOriginalPartSetSubsTechOriginalPart');
    }

    //RLA 03/06/2019 C-003143 : Preseletion de la pièce E pour la France - In Progress
    //Map used to store all techOriginal of E parts
    //used for France only
    public static void buildmapOriginalTechOriginalPartSetSubsPartEs(string originalKey,PartList__c tempPartList, CrossReference__c cReffs){
        system.debug('## Start buildmapOriginalTechOriginalPartSetSubsPartEs');

        if(tempPartList != null){
            if(mapOriginalTechOriginalPartSetSubsPartEs.containsKey(originalKey)){
                mapOriginalTechOriginalPartSetSubsPartEs.get(originalKey).add(tempPartList);
            }
            else{
                mapOriginalTechOriginalPartSetSubsPartEs.put(originalKey,new List <PartList__c>{tempPartList});
            }
             mapTechOriOemManu.put(tempPartList.TECH_OriginalPart__c,cReffs.IAMManufacturer__c);
            
        }//end if tempPartList != null


        system.debug('## End buildmapOriginalTechOriginalPartSetSubsPartEs');
    }


    //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
    //Map used to store all techOriginal of all parts
    //used for France only
    public static void buildmapOriginalTechOriginalPartSetSubsAllPart(string originalKey,PartList__c tempPartList){
        system.debug('## Start buildmapOriginalTechOriginalPartSetSubsAllPart');

        if(tempPartList != null){
            if(mapOriginalTechOriginalPartSetSubsAllPart.containsKey(originalKey)){
                mapOriginalTechOriginalPartSetSubsAllPart.get(originalKey).add(tempPartList);
            }
            else{
                mapOriginalTechOriginalPartSetSubsAllPart.put(originalKey,new List <PartList__c>{tempPartList});
            }
            
        }//end if tempPartList != null


        system.debug('## End buildmapOriginalTechOriginalPartSetSubsAllPart');
    }

    //RLA 20/11/2018 C-002782 CJP A'
    public static updatedPartsFromDistCallOut generateVirtualA(Assessment__c assRecord, 
                                                    String materialRt,
                                                    list <Account> distributorLst, 
                                                    Map<String,list <PartList__c>> mapPartList,
                                                    String assessmentId,
                                                    String partTypes){
        system.debug('## Start RESTUpsertAssessmentV2 generateVirtualA');
        system.debug('## assRecord'+assRecord);
        system.debug('## mapAssessIDListParts ' + mapAssessIDListParts);



        Discount__c disToUse = null;
        List<PartList__c> lstPartlistReturn = new List<PartList__c>();
        map<string,string> mapOrigineValues = RESTUpsertAssessmentV2.getMapTranslatedCertOrg();
        list <PartList__c> substitutePartToUpdate = new list <PartList__c>();
        updatedPartsFromDistCallOut updatedPartsWrap;
        map <string,PartList__c>  mapTechOriginalKeyOriginalPartToUpdate = new map <string,PartList__c>();

        String countryCode = assRecord.TECH_EntityCountryCode__c;
        String manufacturer = assRecord.Manufacturer__c;
        set<String> partTypesSet = new set<String>();
        String allBrands = '';


        if(partTypes != ''){
            partTypesSet.addAll(partTypes.split(';'));
        }
        set<String> brandSet = new set<String>();
        if(manufacturer != ''){
            brandSet.addAll(manufacturer.split(';'));
            if(brandSet.size() > 0){
                for(String t : brandSet){
                    allBrands += '\'' + t + '\',';
                }
                allBrands = allBrands.removeEnd(',');
            }
            
        }
        system.debug('## partTypesSet ' + partTypesSet);
        system.debug('## manufacturer ' + manufacturer);
        system.debug('## distributorLst ' + distributorLst);
        system.debug('## countryCode ' + countryCode);


        String query = 'SELECT Active__c,BodyShop__c,Brand__c,Distributor__c,Manufacturer__c,Name,PartType__c, '+
                                    'Id,  Rebate__c, BSdiscount__c ,AS_Discount__c '+
                                    'FROM Discount__c '+
                                    'WHERE Distributor__c in  :distributorLst '+
                                    ' AND Active__c = true '+
                                    ' AND ActiveCountry__c =  :countryCode' +
                                    ' AND Brand__c INCLUDES ( ' + allBrands + ' ) '  +
                                    //'AND PartType__c includes ' + partTypes + ' ';
                                    ' AND PartType__c in :partTypesSet '+
                                    ' AND RecordType.Name = \''+ ASPISConstants.DISCOUNT_RT_DeveloperName_VirtualADiscount +'\'';                                    
                                     
        system.debug('## query discount : '+query);                                              
        List<Discount__c> lstdis =  database.query(query);


        if (lstdis.size() > 0){
            disToUse = lstdis[0];
            For (PartList__c prt: mapPartList.get(assessmentId) ){
            //system.debug('## prt : '+prt);                            
                 //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
                Boolean allowSubs = true;
                if (String.isnotBlank(prt.Description__c)
                    && callersystemGlo == 'FR_DIVA'
                    && String.isnotBlank(system.label.DescriptionWithNoSubstitute)
                    && prt.Description__c.contains(system.label.DescriptionWithNoSubstitute)
                    ){  
                    allowSubs = false;
                }

                if(prt.RecordTypeId == materialRt 
                    && prt.Quantity__c > 0
                    //RLA 30/07/2019 C-003344: Substitutes manual Parts for Italy  
                    && (prt.inputType__c.toUpperCase()  != 'MANUAL'|| 
                        (prt.inputType__c.toUpperCase()  == 'MANUAL' && isManualPartsAllowedforSubs))
                    && prt.inputType__c.toUpperCase() !='LABOUR'
                    && prt.Price__c != null
                    && prt.Price__c != 0                    
                    && string.isBlank(prt.Alpha_Scale_MRID__c)
                    && !setExistingParts.contains((prt.TECH_OriginalPart__c).toUpperCase())
                    && allowSubs //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
                    
                    ) {

                    String translatedOrigine = '';
                    string description = '';

                    PartList__c newPart = prt.clone();

                    newPart.PartNumber__c = 'ASP-' + prt.PartNumber__c;
                    system.debug('## newPart.PartNumber__c : '+newPart.PartNumber__c);                            

                    newPart.Distributor__c = disToUse.Distributor__c;
                    newPart.TECHDistList__c = disToUse.Distributor__c;
                    newPart.Distributors__c = disToUse.Distributor__c;
                    string substituteKey = prt.TECH_OriginalPart__c + '-' +  newPart.PartNumber__c;
                    //string substituteKey = (prt.TECH_OriginalPart__c + '-' +  newPart.PartNumber__c).replaceAll( '\\s+', '');
                    newPart.TECH_OriginalPart__c = substituteKey;
                    //newPart.TECH_OriginalPart__c = substituteKey.replaceAll( '\\s+', '');

                    newPart.Assessment__r = new Assessment__c (AssessmentID__c = assRecord.AssessmentID__c);

                    
                    newPart.OriginalPart__r = new PartList__c(TECH_OriginalPart__c = prt.TECH_OriginalPart__c);
                    newPart.Alpha_Scale_MRID__c = newPart.PartNumber__c ;
                    newPart.DiscountRecord__c = disToUse.Id;
                    //if (mapOrigineValues.containskey(system.label.ASPDesc)){
                    //    translatedOrigine = mapOrigineValues.get(system.label.ASPDesc);   
                    newPart.CertifyingOrganization__c = system.label.ASPDesc;

                    newPart.SelectedByBS__c = false;
                    //newPart.Description__c = prt.Description__c + ' - ' + system.label.ASPDesc;
                    //} 

                     if(string.isBlank(prt.ProducerName__c)){
                        newPart.ProducerName__c = manufacturer;
                        //description = prt.Description__c + ' - ' + prt.ProducerName__c + ' (' + prt.PartNumber__c + ') - ' + system.label.ASPDesc;
                    }
                    //else{
                    //    description = prt.Description__c + ' - ' + '(' + prt.PartNumber__c + ') - '+ system.label.ASPDesc;
                    //}

                    if(string.isNotBlank(newPart.ProducerName__c)){
                        description = prt.Description__c + ' - ' + newPart.ProducerName__c + ' (' + prt.PartNumber__c + ') - ' + system.label.ASPDesc;
                    }
                    else{
                        description = prt.Description__c + ' - ' + '(' + prt.PartNumber__c + ') - '+ system.label.ASPDesc;
                    }

                    newPart.Description__c = description;

                    system.debug('## prt.ProducerName__c : '+prt.ProducerName__c);                            
                    system.debug('## description : '+description);                            
                    system.debug('## disToUse.BSdiscount__c : '+disToUse.BSdiscount__c);                            
                    system.debug('## disToUse.Rebate__c : '+disToUse.Rebate__c);                            

                    


                    Decimal keepAXA = 0;
                    Decimal keepNonAXA = 0;
                    DEcimal keepToUse = 0;

                    if (bodyshopToReplace != null) {
                        keepAXA = (bodyshopToReplace.keepAXA__c != null && bodyshopToReplace.keepAXA__c != 0 ? (bodyshopToReplace.keepAXA__c) / 100 : 0);

                        keepNonAXA = (bodyshopToReplace.KeepNonAXA__c != null && bodyshopToReplace.KeepNonAXA__c != 0 ? (bodyshopToReplace.KeepNonAXA__c) / 100 : 0);
                    }
                    else{
                        keepAXA = bsRefAccountMap.containsKey(assRecord.BodyShop__c) ? (bsRefAccountMap.get(assRecord.BodyShop__c).keepAXA__c != null && bsRefAccountMap.get(assRecord.BodyShop__c).keepAXA__c != 0 ? (bsRefAccountMap.get(assRecord.BodyShop__c).keepAXA__c) / 100 : 0) : 0;

                        keepNonAXA = bsRefAccountMap.containsKey(assRecord.BodyShop__c) ? (bsRefAccountMap.get(assRecord.BodyShop__c).KeepNonAXA__c != null && bsRefAccountMap.get(assRecord.BodyShop__c).KeepNonAXA__c != 0 ? (bsRefAccountMap.get(assRecord.BodyShop__c).KeepNonAXA__c) / 100 : 0) : 0;
                    }

                    system.debug('@@@ keepAXA:'+keepAXA);
                    system.debug('@@@ keepNonAXA:'+keepNonAXA);
                    

                    if (isNonAxa && keepNonAXA != 0){
                        keepToUse =  keepNonAXA;
                    }
                    else if (keepAXA != 0){
                        keepToUse = keepAXA;
                    }
                    
                    Decimal rebateAmount = (prt.Price__c * (1- (disToUse.AS_Discount__c/100)) ) * ((disToUse.Rebate__c/100)  * (1 - keepToUse));

                    system.debug('@@@ rebateAmount before:'+rebateAmount);

                    bsMargin = prt.Price__c * (disToUse.BSdiscount__c/100);
                    bsDiscount = disToUse.BSdiscount__c;
                    Decimal netPrice = prt.Price__c - bsMargin - rebateAmount;
                

                    newPart.Price__c = prt.Price__c - rebateAmount;
                    newPart.StandardDiscount__c = (1- (netPrice / newPart.Price__c))*100;

                    newPart.StandardMargin__c = prt.Price__c * (disToUse.BSdiscount__c/100);

                    newPart.ASNetPrice__c = netPrice;

                    prt.DiscountRecord__c = disToUse.Id;

                    prt.StandardDiscount__c = disToUse.BSdiscount__c;
                    prt.StandardMargin__c = bsMargin;
                    newPart.TechCatalog_Price_Dist_Connected__c = prt.Price__c;

                    //system.debug('## rebateAmount : '+rebateAmount);                            
                    //system.debug('## bsMargin : '+bsMargin);                            
                    //system.debug('## netPrice : '+netPrice);                            
                    //system.debug('## newPart.StandardDiscount__c : '+newPart.StandardDiscount__c);   
                    //system.debug('## newPart.StandardMargin__c : '+newPart.StandardMargin__c);                            
                    //system.debug('## newPart.Price__c : '+newPart.Price__c);                            
                    system.debug('## newPart: '+newPart);                            
                    //system.debug('## prt.TECH_OriginalPart__c: '+prt.TECH_OriginalPart__c);                            


                    string originalTechPart = (prt.TECH_OriginalPart__c).replaceAll( '\\s+', '');
                    mapTechOriginalKeyOriginalPartToUpdate.put(originalTechPart,prt);
                    //system.debug('## originalTechPart: '+originalTechPart);                            



                    //add to substitutePartToUpdate
                    substitutePartToUpdate.add(newPart);

                                                            //- build setSubsCreatedByDistCallout
                    setSubsCreatedByDistCallout.add(substituteKey);

                    mapSubstituteTechOriginalPartPartlist.put(newPart.TECH_OriginalPart__c,newPart);

                    Boolean allowA = true;
                    if (mapPartTypePriority.size() > 0 && !mapPartTypePriority.containskey(newPart.Type__c )){
                        allowA = false;

                    }
                    system.debug('@@ allowA: '+allowA);

                    //RLA C-2600
                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                    if(!( (isForcedNoA || isForcedAlbax) && newPart.Type__c == 'A')                        
                        && allowA){//RLA 28/01/2020 C-003524 : Change Recommended part in France  
                        buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(prt.TECH_OriginalPart__c,newPart);
                    }

                    if(isNONAXA){                                        
                        if(mapEntitysetPartListTechId.containsKey(encode)){
                            mapEntitysetPartListTechId.get(encode).add(newPart.TECH_OriginalPart__c);
                        }
                        else{
                            mapEntitysetPartListTechId.put(encode, new set<String>{newPart.TECH_OriginalPart__c});
                        }
                    }

                    //lstPartlistReturn.add(newPart);                    
                }
            }
        }//end if distributors list

        updatedPartsWrap = new updatedPartsFromDistCallOut(mapTechOriginalKeyOriginalPartToUpdate,substitutePartToUpdate,'',new map <string,PartList__c>(),new map <string,PartList__c>());
            
        system.debug('## END RESTUpsertAssessmentV2 generateVirtualA');

        return updatedPartsWrap;

    }


    // --------------------- End Distributor V2 Utility Containers and Methods --------------------- //

    //AMI 25/10/17 : C-002041 - Distributor V2 - change return type to set of assessmentid (this set will be used to query all fiels on upserted ass to process eligibility)                                         
    public static set <id> insertAll(
        List<Assessment__c> newAssessmentList, 
        Map<Id, AccountRef__c> accountRefToUpdate, 
        Map<String, List<PartList__c>> assessIdPartsMap, 
        Map<String, Assessment__c> assessMap, 
        Map<String, List<PartList__c>> assessSubstituteListMap,
        Map<String, List<CrossReference__c>> OEMIAMMap){
        //RRJ Check time tracing for other methode 24/10/2022
        datetime qryStart11 = datetime.now();
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - insertAll ----------------------------------');

        // --------------- Start Variable declaration and initialisation --------------- //
        
        //AMI 25/10/17 : C-002041 - Distributor V2 - this set (sucessfully processed assessment) will be used as return 
        //                                         - type to process eligibility in same transaction
        set <id> setAssId = new set <id>();
        
        Set<String> assessmentErrorSet  = new Set<String>();

        //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - This set is used to get all cross ref id associated with ASCR only
        //                        - to get IAMManufacturer and IAMPartNumber to construct JSON to send to any given 
        //                        - connected distributor
        set <id> setCrossReferenceId = new set <id>();

        string materialRt = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        Id labourRt = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Labour').getRecordTypeId();

        //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - This string is used to get json to send to connected distributors
        string distributorReq = '';

        //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
        //                                         - this integer will help to determine proper deserialisation in case of
        //                                         - only one ass or multiple ass
        integer noOfAss = 0;

        //AMI 26/10/17 : C-002041 - Distributor V2 - build assessment parttypes if calling system is Distributor V2
        //                                         - this build is required since assessment is not queried where those field 
        //                                         - are rollup
        map <string,partTypeWrapper> mapAssessIdpartTypeWrapper = new map <string,partTypeWrapper>();

        map <string,string> mapAssessIdFinalPartType = new map <string,string>();

        //AMI 07/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - This map is used to get all parts related to assessment to construct JSON to send to any given 
        //                        - connected distributor
        //map <string, list <PartList__c>> mapAssessIDListParts = new map <string, list <PartList__c>>();

        //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
        //                                         - this map will be used to set proper assessment as 
        //                                         - method parameter in case several ass is sent in request
        map <string,Assessment__c> mapAssessIdAss = new map <string,Assessment__c>();

        //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
        //                                         - this map will be used to hold each eligible distributor
        //                                         - per assessment (in case several ass is sent in request)
        map <string,list <Account>> mapAssessIdDist = new map <string,list <Account>>();

        //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
        //                                         - this map will be used to hold each json to send to connected distributor
        //                                         - per assessment (in case several ass is sent in request)
        map <string,string> mapAssessIdDistJSONReq = new map <string,string>();

        //AMI 09/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - This map is used to get all parts (original) from assessIdPartsMap so that info from
        //                        - latter can be used to construct A' during distributor integration
        map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart = new map <string, PartList__c>();


        //AMI 09/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - This map is used to get related assessment id when creating substitute
        //                        - 
        map <string, string> mapTechOriginalPartKeyCorrespondingAssId = new map <string, string>();

        //AMI 09/11/17 : C-002041 - Distributor V2 - WS Integration
        //                        - result returned after response processing
        updatedPartsFromDistCallOut returnWrap;
        updatedPartsFromDistCallOut returnWrapVirtualAprime;
        updatedPartsFromDistCallOut returnWrapConnectedAprime;

        //RLA 06/03/18 : C-002357 
        //                        - This map is used to get keep the list of parts for each assessment
        //                        - 
        map <string, List<PartList__c>> mapPartsCorrespondingAssId = new map <string, List<PartList__c>>();
        Decimal d4 = 0;
        Decimal d17 = 0;

        // --------------- End Variable declaration and initialisation --------------- //
        
        //AMI 28/02/2018 : C-002041 - Distributor V2 - Temporarily bypassing v2 methods for all countries
        //AMI 22/02/2018 : C-002041 - Distributor V2 - Adding eligibilty process for all countries except france
        //                          - check country before processing callout
        //                          - if country == fr > perform sourcing,callout and dml in same transaction
        //                          - else launch old process (status change by wf that launch eligibility,sourcing,etc...)
        //set <string> eligibleCountryForV2 = new set <string>();

        //if(string.isNotBlank(system.label.DistributorV2)){
        //    if(system.label.DistributorV2.contains(';')){
        //        eligibleCountryForV2.addAll(new set <string>(new list<string>(system.label.DistributorV2.split(';'))));
        //    }else{
        //        eligibleCountryForV2.add(system.label.DistributorV2);
        //    }
        //}

        //if(Test.isRunningTest()){
        //    eligibleCountryForV2 = new set <string>{'ZZ','FR'};
        //}

        //if(eligibleCountryForV2.contains(assCountry)){
            // --------------- Start Distributor V2 Integration --------------- //

            System.debug('//assessIdPartsMap'+assessIdPartsMap);
            //loop in parts (original) to be inserted in order to populate mapAssessIdpartTypeWrapper
            for(String key: assessIdPartsMap.keyset()){
                for(PartList__c prt : assessIdPartsMap.get(key)){
                    
                    //build mapAssessIdpartTypeWrapper
                    if(mapAssessIdpartTypeWrapper.containsKey(key)){
                        partTypeWrapper tempWrap = mapAssessIdpartTypeWrapper.get(key);

                        tempWrap = incrementType(tempWrap,prt,materialRt);

                        mapAssessIdpartTypeWrapper.put(key,tempWrap);
                    }else{
                        partTypeWrapper tempWrap = new partTypeWrapper();

                        tempWrap = incrementType(tempWrap,prt,materialRt);

                        mapAssessIdpartTypeWrapper.put(key,tempWrap);
                    }

                    //AMI 09/11/17 : build mapTechOriginalPartKeyCorrespondingPart
                    mapTechOriginalPartKeyCorrespondingPart.put(prt.TECH_OriginalPart__c,prt);

                    //AMI 09/11/17 : build mapTechOriginalPartKeyCorrespondingAssId
                    mapTechOriginalPartKeyCorrespondingAssId.put(prt.TECH_OriginalPart__c,key);
                }  

                //AMI 07/11/17 : build mapAssessIDListParts
                if(mapAssessIDListParts.containsKey(key)){
                    mapAssessIDListParts.get(key).addAll(assessIdPartsMap.get(key)); 
                }else{
                    mapAssessIDListParts.put(key, new list <PartList__c>(assessIdPartsMap.get(key)));
                }  
            }


            //loop in parts (substitute) to be inserted in order to populate mapAssessIdpartTypeWrapper
            for(String key: assessSubstituteListMap.keyset()){
                for(PartList__c prt : assessSubstituteListMap.get(key)){
                   
                    if(mapAssessIdpartTypeWrapper.containsKey(key)){
                        partTypeWrapper tempWrap = mapAssessIdpartTypeWrapper.get(key);

                        tempWrap = incrementType(tempWrap,prt,materialRt);

                        mapAssessIdpartTypeWrapper.put(key,tempWrap);
                    }else{
                        partTypeWrapper tempWrap = new partTypeWrapper();

                        tempWrap = incrementType(tempWrap,prt,materialRt);

                        mapAssessIdpartTypeWrapper.put(key,tempWrap);
                    }

                    //AMI 07/11/17 : build setCrossReferenceId
                    if(prt.CrossReferenceId__c != null){
                        setCrossReferenceId.add(prt.CrossReferenceId__c);
                    }
                }

                //AMI 07/11/17 : build mapAssessIDListParts
                if(mapAssessIDListParts.containsKey(key)){
                    mapAssessIDListParts.get(key).addAll(assessSubstituteListMap.get(key));
                }else{
                    mapAssessIDListParts.put(key, new list <PartList__c>(assessSubstituteListMap.get(key)));
                }    
            }


            //build mapAssessIdFinalPartType
            for(string str : mapAssessIdpartTypeWrapper.keySet()){
                string finalType = '';
                partTypeWrapper tempWrap = mapAssessIdpartTypeWrapper.get(str);

                if(tempWrap.A > 0){
                    finalType = 'A';
                }

                if(tempWrap.B > 0){
                    if(string.isNotBlank(finalType)){
                        finalType += ';B';
                    }else{
                        finalType = 'B';
                    }
                }

                if(tempWrap.C > 0){
                    if(string.isNotBlank(finalType)){
                        finalType += ';C';
                    }else{
                        finalType = 'C';
                    }
                }

                if(tempWrap.D > 0){
                    if(string.isNotBlank(finalType)){
                        finalType += ';D';
                    }else{
                        finalType = 'D';
                    }
                }

                if(tempWrap.P > 0){
                    if(string.isNotBlank(finalType)){
                        finalType += ';P';
                    }else{
                        finalType = 'P';
                    }
                }

                mapAssessIdFinalPartType.put(str,finalType);
            }


            For (string key: mapAssessIDListParts.keyset()){
                for (PartList__c part: mapAssessIDListParts.get(key)){

                    if (part.RecordtypeId == Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId()
                        //&& part.SelectedByBS__c //RLA 20/03/2017 Run Eligibilibility for parts irrespective being selected Case 2370
                        ){
                        if (mapNumberPartsCorrespondingAssId.containskey(key)){
                            mapNumberPartsCorrespondingAssId.put(key, mapNumberPartsCorrespondingAssId.get(key) + 1);
                        }
                        else{
                            mapNumberPartsCorrespondingAssId.put(key, 1);
                        }
                    }

                    //ASE 21/12/18: C-002985 -  No Virtual A' on fake references
                    String partNumber = '\''+ part.PartNumber__c + '\'' ;
                    if(!system.label.FakeReferences.contains(partNumber)){
                        if(!VirtualAAssessListPartMap.containsKey(key)){
                            VirtualAAssessListPartMap.put(key, new list<PartList__c>{part});
                        }
                        else{
                            VirtualAAssessListPartMap.get(key).add(part);
                        }  
                    }
                }
            }
            
            //RLA 20/11/2018 C-002782 CJP A'
            string feature = '';
            
            //launch sourcing process
            for(Assessment__c ass : newAssessmentList){
                
                 //if ass is eligible, proceed with souring
                if(eligibleWrap.isEligible){

                    //RLA 07/03/2018 Eligibility
                    //add returned assessment to assToUpdate (update status)
                    //update assessment
                    ass.Status__c = eligibleWrap.ass.Status__c;
                    ass.TECHRulesAppliedDescription__c = eligibleWrap.ass.TECHRulesAppliedDescription__c;
                    ass.ReasonFailure__c = eligibleWrap.ass.ReasonFailure__c;
                    ass.MREligibility__c = eligibleWrap.ass.MREligibility__c;
                    // ASE: 08/05/18: c 
                    ass.MRSourcing__c = String.join(new List<String>(DistributorIdSet), ';');
                    

                    //AMI 09/11/17 : populate mapAssessIdAss
                    mapAssessIdAss.put(ass.AssessmentID__c,ass);
                    //RLA 20/11/2018 C-002782 CJP A'
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                    feature = bodyshopToReplace != null ? bodyshopToReplace.Feature__c : (bsRefAccountMap.containsKey(ass.BodyShop__c) ? (bsRefAccountMap.get(ass.BodyShop__c).Feature__c) : '');
                    
                    datetime qryStart = datetime.now();
                    
                    //DUN 30/05/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                    //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                    if( (bsRefAccountMap.containsKey(ass.BodyShop__c) 
                        && (bsRefAccountMap.get(ass.BodyShop__c).Feature__c) != null
                        && (bsRefAccountMap.get(ass.BodyShop__c).Feature__c).contains('PilotDirectSourcing'))
                        || (bodyshopToReplace != null
                            && bodyshopToReplace.Feature__c != null
                            && bodyshopToReplace.Feature__c.contains('PilotDirectSourcing')) ){

                        String alldirectOrderIds = '';
                        String allFirstDistributorsIds = '';
                        String allAgencyDistributorsIds = '';
                        String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 
                        String allDistibutors = ''; //RLA 20/04/2020 C-003695

                        set<String> partTypes = new set <String>();
                        //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                        ass.Feature__c = bodyshopToReplace != null ? bodyshopToReplace.Feature__c : bsRefAccountMap.get(ass.BodyShop__c).Feature__c;

                        for(String key: assessIdPartsMap.keyset()){  
                            for(partlist__c pl : assessIdPartsMap.get(key)){
                                if(pl.RecordTypeId != recordTypePartTypeMap.get('Labour')){
                                    partTypes.add(pl.Type__c);
                                }
                            }
                        }
                        if(partTypes.size() > 0){

                            map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();
                            map <String, String> mapDistPrio = new map <String,String>();
                                // system.debug('@@ capturedDistributorsGlo'+capturedDistributorsGlo);

                            //RLA 13/04/2020 C-003694: IG - Sourcing                       
                            if (!(isIG && String.isNotBlank(capturedDistributorsGlo))){
                                // system.debug('@@ do direct sourcing');
                                //get wrapper containing distributors(P0), next distributors (P1, P2, ...), agencyDistributors, directOrder 
                                system.debug('@@@ ass.Manufacturer__c: '+ass.Manufacturer__c);
                                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                                if (bodyshopToReplace != null){
                                    //WCH 16/04/2021 C-004322
                                    mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(ass.TECH_EntityCountryCode__c,bodyshopToReplace.Id,ass.Manufacturer__c ,bodyshopToReplace.ShippingPostalCodeLeft2__c, bodyshopToReplace.CarBrandsSuppliedAgency__c, partTypes);
                                }
                                else{
                                mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(ass.TECH_EntityCountryCode__c,ass.BodyShop__c,ass.Manufacturer__c ,bsRefAccountMap.get(ass.BodyShop__c).ShippingPostalCodeLeft2__c, bsRefAccountMap.get(ass.BodyShop__c).CarBrandsSuppliedAgency__c, partTypes);
                            }
                            }
                            else{
                                // system.debug('@@ do not do direct sourcing');
                                
                                
                                mapDistPrio = ASPISDirectSourcing.buildmapDistPrio(capturedDistributorsGlo);
                                

                            }
                            //RLA 13/04/2020 C-003694: IG - Sourcing
                            if(!mapPartTypeDistributorsWrap.isEmpty()
                             || !mapDistPrio.isEmpty()){

                                if (!mapPartTypeDistributorsWrap.isEmpty()){
                                    for(String key: assessIdPartsMap.keyset()){  
                                        for(partlist__c pl : assessIdPartsMap.get(key)){
                                            if(pl.RecordTypeId != recordTypePartTypeMap.get('Labour')){
                                                pl.Distributors__c = mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor;
                                                pl.NextDistributors__c = mapPartTypeDistributorsWrap.get(pl.Type__c).NextDistributors;
                                                pl.TECHDistList__c = mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor;
                                                for(Id directOrderIds : mapPartTypeDistributorsWrap.get(pl.Type__c).DirectOrderIds){
                                                    if(!alldirectOrderIds.contains(directOrderIds))
                                                        alldirectOrderIds += directOrderIds + ';' ;
                                                }
                                                for(String disId : pl.Distributors__c.split(';')){
                                                    if(disId.contains('-true')){
                                                    disId = disId.remove('-true');
                                                    }
                                                    if(!allFirstDistributorsIds.contains(disId)){
                                                        allFirstDistributorsIds += disId + ';';
                                                    }
                                                }
                                                if(mapPartTypeDistributorsWrap.get(pl.Type__c).AgencyDistributors != null && mapPartTypeDistributorsWrap.get(pl.Type__c).AgencyDistributors != '' ){
                                                    for(String agencydisId : mapPartTypeDistributorsWrap.get(pl.Type__c).AgencyDistributors.split(';')){
                                                        if(!allAgencyDistributorsIds.contains(agencydisId)){
                                                            allAgencyDistributorsIds += agencydisId + ';';
                                                        }     
                                                    }
                                                }
                                                //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                                if (String.isNotBlank(mapPartTypeDistributorsWrap.get(pl.Type__c).DistributorsDirOrders) ){
                                                    //WCH 20/11/2018: C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
                                                    if (!allDistributorsDirOrders.contains(mapPartTypeDistributorsWrap.get(pl.Type__c).DistributorsDirOrders)){
                                                        allDistributorsDirOrders += ','+mapPartTypeDistributorsWrap.get(pl.Type__c).DistributorsDirOrders;
                                                    }
                                                }
                                            }   
                                        }
                                        if(alldirectOrderIds != ''){
                                            alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                                        }   
                                        if(allFirstDistributorsIds != ''){
                                            allFirstDistributorsIds = allFirstDistributorsIds.removeEnd(';');
                                        } 
                                        if(allAgencyDistributorsIds != ''){
                                            allAgencyDistributorsIds = allAgencyDistributorsIds.removeEnd(';');
                                        }   

                                        //RLA 13/04/2020 C-003694: IG - Sourcing
                                        String capturedDistributors = '';
                                        //RLA 09/11/2020 Fill in for all distributors instead of only IG
                                        if (String.isnotBlank(allDistributorsDirOrders) && String.isBlank(ass.CapturedDistributors__c)){
                                            Map<String, String> mapDistributorsPriority = new map<String,String>();
                                            mapDistributorsPriority = ASPISDirectSourcing.buildMapDisPrio(allDistributorsDirOrders);
                                            for (String distDo: mapDistributorsPriority.keyset()){
                                                String dist = (distDo.split('-'))[0];
                                                // system.debug('@@@ dist'+dist);
                                                allDistibutors += dist + ';';
                                                String priority = mapDistributorsPriority.get(distDo);
                                                // map containing the distributor Id and its priority
                                                mapDistPrioConnected.put(dist, priority);
                                                // system.debug('@@@ priority: '+priority);
                                                capturedDistributors += priority + '-' + dist + ';';
                                                // system.debug('@@ capturedDistributors: '+capturedDistributors);
                                            }

                                            // system.debug('@@@ mapDistributorsPriority: '+mapDistributorsPriority);
                                            // system.debug('@@@ allDistibutors: '+allDistibutors);

                                        }
                                        ass.CapturedDistributors__c = String.isnotBlank(capturedDistributors) ? capturedDistributors : null;

                                        ass.Status__c = 'NEW';
                                        ass.TECHRulesAppliedDescription__c += 'Results: Number of Purchase orders: ' + allFirstDistributorsIds.split(';').size();
                                        ass.MRSourcing__c = allFirstDistributorsIds; 
                                        ass.AgencyDistributors__c = allAgencyDistributorsIds;
                                        //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                                        ass.Tech_DirectOrders__c=alldirectOrderIds;
                                        //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                        ass.TechDistAndDirectOrder__c=allDistributorsDirOrders;

                                    }

                                    if(!ass.isShoppingList__c || (isNONAXA && isSubsAllowed)){
                                        list <Account> accList = new  list <Account>();

                                        //RLA 20/04/2020 Case 3695: Subject IG - IGP Substitution part
                                        if (isIG){
                                            for(String accId : allDistibutors.split(';')){
                                                accList.add(new Account(Id = accId));
                                            }
                                        }
                                        else{
                                            for(String accId : allFirstDistributorsIds.split(';')){
                                                accList.add(new Account(Id = accId));
                                            }
                                        }
                                        
                                        mapAssessIdDist.put(ass.AssessmentID__c, accList);
                                    }

                                    System.debug('//mapAssessIdDist'+ mapAssessIdDist);
                                    
                                    //WCH 22/07/2019 C-003354 : set distributor and next distributors for substitutes
                                    for(String subtituteKey: assessSubstituteListMap.keyset()){
                                        for(partlist__c pl : assessSubstituteListMap.get(subtituteKey)){
                                            if(pl.RecordTypeId != recordTypePartTypeMap.get('Labour') && mapPartTypeDistributorsWrap.containskey(pl.Type__c)){
                                                system.debug('@@ substitute distributor added'+pl.Name);
                                                pl.Distributors__c = mapPartTypeDistributorsWrap.get(pl.Type__c).FirstDistributor;
                                                pl.NextDistributors__c = mapPartTypeDistributorsWrap.get(pl.Type__c).NextDistributors;
                                            }
                                        }
                                    }
                                }//RLA 13/04/2020 C-003694: IG - Sourcing
                                else if (!mapDistPrio.isEmpty()){
                                    String firstDistributor;
                                    String nextDistributors = '';
                                   
                                    integer i = 1;
                                    for (String priority: mapDistPrio.keyset()){
                                        mapDistPrioConnected.put(mapDistPrio.get(priority), priority);

                                        if (mapAssessIdDist.containsKey(ass.AssessmentID__c)){
                                            mapAssessIdDist.get(ass.AssessmentID__c).add(new Account(id =mapDistPrio.get(priority)));
                                        }
                                        else{
                                            mapAssessIdDist.put(ass.AssessmentID__c,new list<Account> {new Account (id =mapDistPrio.get(priority))});

                                        }


                                        if (i == 1){
                                            firstDistributor = mapDistPrio.get(priority);
                                        }
                                        else{
                                            nextDistributors += '{' +  priority + ':' +  mapDistPrio.get(priority) + '}';  
                                            nextDistributors = i < mapDistPrio.size() ?  nextDistributors + ',' : nextDistributors;
                                        }
                                        i++;

                                    }
                                    system.debug('@@ firstDistributor: '+firstDistributor);
                                    system.debug('@@ nextDistributors: '+nextDistributors);
                                    system.debug('@@ originalPartsMap: '+originalPartsMap);
                                    
                                    for(String key: assessIdPartsMap.keyset()){  
                                        
                                        for(partlist__c pl : assessIdPartsMap.get(key)){
                                           
                                            if(pl.RecordTypeId != recordTypePartTypeMap.get('Labour')
                                               && !setExistingTechOriginalPart.contains(pl.TECH_OriginalPart__c)){
                                                    system.debug('@@ new part: '+ pl.TECH_OriginalPart__c);
                                                pl.Distributors__c = firstDistributor;
                                                pl.NextDistributors__c = nextDistributors;
                                                pl.TECHDistList__c = firstDistributor;

                                                for(String disId : pl.Distributors__c.split(';')){
                                                    if(disId.contains('-true')){
                                                    disId = disId.remove('-true');
                                                    }
                                                    if(!allFirstDistributorsIds.contains(disId)){
                                                        allFirstDistributorsIds += disId + ';';
                                                    }
                                                }
                                            }

                                            if (originalPartsMap.containsKey( key + '-' + (pl.TECH_OriginalPart__c).toUpperCase())){   
                                                if ((originalPartsMap.get( key + '-' + (pl.TECH_OriginalPart__c).toUpperCase())).RecordTypeId != recordTypePartTypeMap.get('Labour')){
                                                    for(String disId : (originalPartsMap.get( key + '-' + (pl.TECH_OriginalPart__c).toUpperCase())).Distributors__c.split(';')){
                                                        if(disId.contains('-true')){
                                                        disId = disId.remove('-true');
                                                        }
                                                        if(!allFirstDistributorsIds.contains(disId)){
                                                            allFirstDistributorsIds += disId + ';';
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }

                                        ass.Status__c = 'NEW';
                                        ass.TECHRulesAppliedDescription__c += 'Results: Number of Purchase orders: ' + allFirstDistributorsIds.split(';').size();
                                        ass.MRSourcing__c = allFirstDistributorsIds; 
                                        
                                    }

                                    if(!ass.isShoppingList__c || (isNONAXA && isSubsAllowed)){
                                        list <Account> accList = new  list <Account>();
                                        system.debug('@@ hello'+allFirstDistributorsIds);

                                        for(String accId : allFirstDistributorsIds.split(';')){
                                            accList.add(new Account(Id = accId));
                                        }
                                        
                                        // mapAssessIdDist.put(ass.AssessmentID__c, accList);
                                    }
                                    
                                

                                }//end for use captured distributors
                                system.debug('## new assessSubstituteListMap>>>>:'+assessSubstituteListMap);
                            }
                            else{
                                if(String.isblank(ass.MRSourcing__c)){//WCH 12/09/2019 C-003387 add condition to not set rejected if distributor found(mrsourcing not blank)
                                    ass.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                                    ass.TECHRulesAppliedDescription__c += '\n\n No direct orders found';
                                    ass.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                                    ass.MRSourcing__c = 'false';
                                }
                            }
                        }
                        else{
                            if(String.isblank(ass.MRSourcing__c)){//WCH 12/09/2019 C-003387 add condition to not set rejected if distributor found(mrsourcing not blank)
                                ass.Status__c = system.Label.ASSESSMENTSTATUSREJECTEDLABEL;
                                ass.TECHRulesAppliedDescription__c += '\n\n No direct orders found';
                                ass.ReasonFailure__c = system.Label.ASSESSMENTREASONSOURCEFAILLABEL;
                                ass.MRSourcing__c = 'false';
                            }
                        }
                    }
                    else{

                        //launch sourcing
                        ASPISServiceSourcing.sourcingWrapper sourcingWrap = ASPISServiceSourcing.processObjForSourcing(ass,false,bsRefAccountMap,mapAssessIdFinalPartType);
                        if(!sourcingWrap.distributorLst.isEmpty()){ 
                            // ASE: 21/05/2018 : C-002278 
                            for(Account acc : sourcingWrap.distributorLst){
                                List<String> accountCat;
                                if(acc.Categories__c != null){
                                    accountCat = acc.Categories__c.split(';');
                                }
                                if(accountCat != null){
                                    for(String acctype : accountCat){
                                        if(!typeDistMap.containsKey(acctype)){
                                            typeDistMap.put(acctype, new set<String>{String.ValueOf(acc.Id)});
                                        }
                                        else{
                                            typeDistMap.get(acctype).add(String.ValueOf(acc.Id));
                                        }
                                    }
                                }
                            }
                            //add returned assessment to assToUpdate (update status)
                            //update assessment
                            ass.Status__c = sourcingWrap.ass.Status__c;
                            ass.TECHRulesAppliedDescription__c = sourcingWrap.ass.TECHRulesAppliedDescription__c;
                            ass.ReasonFailure__c = sourcingWrap.ass.ReasonFailure__c;
                            ass.MRSourcing__c = sourcingWrap.ass.MRSourcing__c;


                            //AMI 09/11/17 : populate mapAssessIdDist 
                            //               this map should be populated only if assessment is not a shoppingList
                            if(!ass.isShoppingList__c || (isnonAxa && isSubsAllowed)){
                                mapAssessIdDist.put(ass.AssessmentID__c, new list <Account>(sourcingWrap.distributorLst));
                            }
                        }else{
                            //sourcing failed
                            //update ass with error message
                            //update assessment
                            ass.Status__c = sourcingWrap.ass.Status__c;
                            ass.TECHRulesAppliedDescription__c = sourcingWrap.ass.TECHRulesAppliedDescription__c;
                            ass.ReasonFailure__c = sourcingWrap.ass.ReasonFailure__c;
                            ass.MRSourcing__c = 'false';

                        }//end if !sourcingWrap.distributorLst.isEmpty()
                    }
                    time4 = ((datetime.now()).getTime() - qryStart.getTime());
                    time4 = (time4.divide(1000, 5));
                    d4 = time4;
                    //RLA 10/05/2021 Aniel DP distributor not called during callout
                    if (mapAssessIdDist.isEmpty() && !setDistPriceIds.isEmpty()){
                         List<Account> lstAccDist = new list<Account>();
                        for (id allDist: setDistPriceIds){
                            lstAccDist.add(new Account(id = allDist));                        
                        }
                         mapAssessIdDist.put(ass.AssessmentID__c, lstAccDist);

                    }
                }
                else{
                    //Eligibility failed
                    //update ass with error message
                    //update assessment
                    ass.Status__c = eligibleWrap.ass.Status__c;
                    ass.TECHRulesAppliedDescription__c = eligibleWrap.ass.TECHRulesAppliedDescription__c;
                    ass.ReasonFailure__c = eligibleWrap.ass.ReasonFailure__c;
                    ass.MREligibility__c = false;
                    ass.MRSourcing__c = 'false';//WCH 25/11/2019 C-003490

                }//end if not Eligible
            }//end looping in assessment
           //RLA 20/04/2020 Case 3695: Subject  IG - IGP Substitution part
            map <String, String> mapPrioTechDist = new map<String, String>();
            //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
            //                                         - build request to send to Dist for each assessment received
            if(!mapAssessIdDist.isEmpty()){
               
                for(string assessmentId : mapAssessIdDist.keySet()){
                    system.debug('@@@ i have already done callout');
                    
                    //RLA 10/05/2021 Aniel DP distributor not called during callout
                    set<Id> setAccDist = new set<Id>();
                    List<Account> lstAccDist = mapAssessIdDist.get(assessmentId);
                    for (Account acc: lstAccDist){
                    	setAccDist.add(acc.Id);    
                    }
                    system.debug('@@@ setAccDist:'+setAccDist); 
                    
                    for (Id dist: setDistPriceIds){
                        system.debug('@@@ acc:'+dist);
                        if (!setAccDist.contains(dist)){
                            setAccDist.add(dist);
                        }
                    }
                    system.debug('@@@ setAccDist after :'+setAccDist); 
                    
                    for (id allDist: setAccDist){
						lstAccDist.add(new Account(id = allDist));                        
                    }
                    mapAssessIdDist.put(assessmentId,lstAccDist );
                    
                    system.debug('@@@ mapAssessIdDist after :'+mapAssessIdDist); 

                    for(Account acc :mapAssessIdDist.get(assessmentId)){
                        SetOccurenceDistributor.add(acc.id);
                    }

                     //RLA 20/11/2018 C-002782 CJP A' Use one main select for distributor connected and Virtual A
                    List<Account> lstDistributorsDisConnected = new list<Account>();
                    List<Account> lstDistributorsVirtualA = new list<Account>();
                    for (Account acc:  [select id, Name, Categories__c, PartTypeRegionDelayMatrix__c,DistributorConnected__c,DistributorCarBrandSupplied__c,ConnectedEndtoEnd__c,
                                  Tech_Distributor__c,Rebate__c, Tech_ATConfirmed__c, Tech_ATConfirmedWithDelay__c,
                                  Tech_ATPartial__c, Tech_ATNotFound__c, Tech_ATOther__c, IdforExpert__c, /*C-2602*/CarBrandsSuppliedAgency__c, EligibleVirtualA__c, /*C-003492*/AllowedBPartsStatusForDistConnected__c,
                                  Type_of_Substitutes__c /*C-003881 */
                                  ,ReferenceNumber__c /*C-004018 */
                            from Account
                            where id IN : SetOccurenceDistributor]){
                            System.debug('<<<accDraftcall>>>' + acc);
                        // if (acc.DistributorConnected__c == true
                        if (RestDistributorUtility.isConnectedDist(acc.Type_of_Substitutes__c)
                            &&  acc.ConnectedEndtoEnd__c == true
                            //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                            && RestDistributorUtility.canMakeDraftCall(acc.Type_of_Substitutes__c)
                            ){
                            lstDistributorsDisConnected.add(acc);

                            //RLA 20/04/2020 Case 3695: Subject IG - IGP Substitution part
                            if (mapDistPrioConnected.containsKey(acc.Id)){
                                mapPrioTechDist.put(mapDistPrioConnected.get(acc.Id), acc.Tech_Distributor__c);    
                            }

                            //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
                            if (String.isnotBlank(acc.AllowedBPartsStatusForDistConnected__c)){
                                //***Tocomment */
                                // mapPartTypesStatusAllowed = splitForBPartTypesStatus(acc.AllowedBPartsStatusForDistConnected__c);
                                // system.debug('@@ i am splitting 4482:'+ acc.Tech_Distributor__c);
                                mapDistPartTypesStatusAllowed = splitForBPartTypesStatusPerDist(acc.AllowedBPartsStatusForDistConnected__c, acc.Tech_Distributor__c);
                            }

                            
                        }
                        if (acc.EligibleVirtualA__c){
                            lstDistributorsVirtualA.add(acc);   
                        }
                        

                    }

                    string builtJSONReq = '';
                    system.debug('## lstDistributorsVirtualA:'+lstDistributorsVirtualA);
                    system.debug('## feature:'+feature);
                    system.debug('## VirtualAAssessListPartMap:'+VirtualAAssessListPartMap);
                    system.debug('## mapAssessIdFinalPartType:'+mapAssessIdFinalPartType);
                    system.debug('## carBrandExcluded:'+carBrandExcluded);
                    system.debug('## mapAssessIdDist:'+mapAssessIdDist);
                    system.debug('## mapAssessIdAss:'+mapAssessIdAss);
                    
                    if(mapAssessIdAss.containsKey(assessmentId) &&
                       string.isNotBlank(labourRt) &&  //RLA 04/10/2018 Case C-002818: Substitution sur des manual parts 
                       mapAssessIdDist.containsKey(assessmentId) &&
                       mapAssessIDListParts.containsKey(assessmentId) &&
                       // ASE : 26/06/2018- no call made if BS.DistributorConnected= false
                       BSConnected
                       /*C- 2600 when BS is forced and brand is excluded, no substitution required*/ && !(isBSForced && carBrandExcluded)
                       && !isFromR3 //RLA C-004030: From createAssessment to upsertAssessment 
                       && isSubsAllowed //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                      // && lstDistributorsDisConnected.size() > 0
                       ){
							system.debug('mapAssessIdAss.get(assessmentId)' + mapAssessIdAss.get(assessmentId));
							system.debug('labourRt' + labourRt);
							system.debug('lstDistributorsDisConnected' + lstDistributorsDisConnected);
							system.debug('mapAssessIDListParts.get(assessmentId)' + mapAssessIDListParts.get(assessmentId));
							system.debug('setCrossReferenceId' + setCrossReferenceId);
							system.debug('@@ here');
                            //build json to send to connected distributor
                            builtJSONReq = buildDistributorRequest(mapAssessIdAss.get(assessmentId),
                                                                    labourRt, //RLA 04/10/2018 Case C-002818: Substitution sur des manual parts 
                                                                    lstDistributorsDisConnected,//RLA 20/11/2018 C-002782 CJP A'
                                                                    mapAssessIDListParts.get(assessmentId),
                                                                    setCrossReferenceId);

                            System.debug('<<<<builtJSONReq>>>>' + builtJSONReq);

                            if(string.isNotBlank(builtJSONReq)){
                                mapAssessIdDistJSONReq.put(assessmentId,builtJSONReq);
                            }
                    }//end check on build json method param

                    list<String> booleanList = isEligibleMap.containsKey(assessmentId) ? isEligibleMap.get(assessmentId).split(':') : null;
                    
                    //RLA 13/12/2019 C-003534 - Assessments for BS not eligible for substitution has A' substituted parts
                    Boolean isEligible = booleanList != null ? Boolean.valueOf(booleanList[0]) : false; 
                    system.debug('## isEligible:'+isEligible);
                    system.debug('## booleanList:'+booleanList);
                    system.debug('## isEligibleMap:'+isEligibleMap);
                   
                    //RLA 20/11/2018 C-002782 CJP A'
                    if (lstDistributorsVirtualA.size() > 0
                        && String.isnotblank(feature)
                        && feature.contains('Virtual A\'')
                        && mapAssessIdAss.containsKey(assessmentId)
                        && mapAssessIdDist.containsKey(assessmentId)
                        //&& mapAssessIDListParts.containsKey(assessmentId)
                        && VirtualAAssessListPartMap.containsKey(assessmentId)
                        && mapAssessIdFinalPartType.containsKey(assessmentId)
                        && !carBrandExcluded //If a brand is excluded, the virtual A' must not be generated.
                        && isEligible  //RLA 13/12/2019 C-003534 - Assessments for BS not eligible for substitution has A' substituted parts
                        ){
                        system.debug('## got in cjp a:');

                        returnWrapVirtualAprime = generateVirtualA(mapAssessIdAss.get(assessmentId),
                                                                        materialRt,
                                                                        lstDistributorsVirtualA,
                                                                        //mapAssessIDListParts,
                                                                        VirtualAAssessListPartMap,
                                                                        assessmentId,
                                                                        mapAssessIdFinalPartType.get(assessmentId));

                    }


                }//end looping in each assessment
            }//end !mapAssessIdDist.isEmpty()
            

            //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
            //                                         - build distributorReq to make only one callout for every assessment
            //                                         - received
            if(mapAssessIdDistJSONReq.size() > 1){
                distributorReq = '[' ;
                for(string str : mapAssessIdDistJSONReq.values()){
                    distributorReq += str + ',';
                }

                distributorReq = distributorReq.removeEnd(',') + ']';

                //set number of assessment treated
                noOfAss = mapAssessIdDistJSONReq.size();
            }else if(!mapAssessIdDistJSONReq.isEmpty()){
                distributorReq = mapAssessIdDistJSONReq.values()[0];

                //set number of assessment treated
                noOfAss = 1;
            }
            

            //AMI 09/11/17 : C-002041 - Distributor V2 - bulkifying distributor callout
            //                                         - perform callout
            //   
            datetime qryStart17 = datetime.now();
            if(string.isNotBlank(distributorReq)){
                
                // returnWrap = launchCallOut(distributorReq,false,noOfAss,mapTechOriginalPartKeyCorrespondingPart,mapTechOriginalPartKeyCorrespondingAssId, mapPrioTechDist);
                returnWrapConnectedAprime =  launchCallOut(distributorReq,false,noOfAss,mapTechOriginalPartKeyCorrespondingPart,mapTechOriginalPartKeyCorrespondingAssId, mapPrioTechDist);
                
            }
            //RRJ Check time tracing for other methode 24/10/2022
            time17 = ((datetime.now()).getTime() - qryStart17.getTime());
            time17 = (time17.divide(1000, 5));
            d17 = time17;
            system.debug('## returnWrapVirtualAprime:'+returnWrapVirtualAprime);
            system.debug('## returnWrapConnectedAprime:'+returnWrapConnectedAprime);
            // map1 = returnWrapVirtualAprime.mapTechOriginalKeyOriginalPart;
            // map2 = returnWrapConnectedAprime.mapTechOriginalKeyOriginalPart;
            // map1.putAll(map2);

            if (returnWrapVirtualAprime != null || returnWrapConnectedAprime != null ){
                map <string,PartList__c>  mapTechOriginalKeyOriginalPartTemp = new map <string,PartList__c>();
                list <PartList__c> substitutePartTemp = new list <PartList__c>();
                string errorReportedTemp = '';
                map <string,PartList__c>  mapTechOriginalKeyOriginalPartNoDistTemp = new map <string,PartList__c>();
                map<String,Partlist__c> mapSubsToDelTemp = new map <String, Partlist__c>();

                if (returnWrapVirtualAprime != null){
                    if (returnWrapVirtualAprime.mapTechOriginalKeyOriginalPart != null && returnWrapVirtualAprime.mapTechOriginalKeyOriginalPart.size() > 0){
                        mapTechOriginalKeyOriginalPartTemp.putAll(returnWrapVirtualAprime.mapTechOriginalKeyOriginalPart);
                    }
                    if (returnWrapVirtualAprime.substitutePart != null && returnWrapVirtualAprime.substitutePart.size() > 0){
                        substitutePartTemp.addAll(returnWrapVirtualAprime.substitutePart);
                    }
                    if (returnWrapVirtualAprime.errorReported != null){
                        errorReportedTemp = returnWrapVirtualAprime.errorReported;
                    }
                    if (returnWrapVirtualAprime.mapTechOriginalKeyOriginalPartNoDist != null && returnWrapVirtualAprime.mapTechOriginalKeyOriginalPartNoDist.size() > 0){
                        mapTechOriginalKeyOriginalPartNoDistTemp.putAll(returnWrapVirtualAprime.mapTechOriginalKeyOriginalPartNoDist);
                    }
                    if (returnWrapVirtualAprime.mapSubsToDel != null && returnWrapVirtualAprime.mapSubsToDel.size() > 0){
                        mapSubsToDelTemp.putAll(returnWrapVirtualAprime.mapSubsToDel);
                    }

                }

                if (returnWrapConnectedAprime != null){
                    if (returnWrapConnectedAprime.mapTechOriginalKeyOriginalPart != null && returnWrapConnectedAprime.mapTechOriginalKeyOriginalPart.size() > 0){
                        mapTechOriginalKeyOriginalPartTemp.putAll(returnWrapConnectedAprime.mapTechOriginalKeyOriginalPart);
                    }
                    if (returnWrapConnectedAprime.substitutePart != null && returnWrapConnectedAprime.substitutePart.size() > 0){
                        substitutePartTemp.addAll(returnWrapConnectedAprime.substitutePart);
            }
                    if (returnWrapConnectedAprime.errorReported != null){
                        errorReportedTemp = returnWrapConnectedAprime.errorReported;
                    }
                    if (returnWrapConnectedAprime.mapTechOriginalKeyOriginalPartNoDist != null && returnWrapConnectedAprime.mapTechOriginalKeyOriginalPartNoDist.size() > 0){
                        mapTechOriginalKeyOriginalPartNoDistTemp.putAll(returnWrapConnectedAprime.mapTechOriginalKeyOriginalPartNoDist);
                    }
                    if (returnWrapConnectedAprime.mapSubsToDel != null && returnWrapConnectedAprime.mapSubsToDel.size() > 0){
                        mapSubsToDelTemp.putAll(returnWrapConnectedAprime.mapSubsToDel);
                    }

                }
                returnWrap = new updatedPartsFromDistCallOut(mapTechOriginalKeyOriginalPartTemp,substitutePartTemp,errorReportedTemp,mapTechOriginalKeyOriginalPartNoDistTemp,mapSubsToDelTemp);
            }

            // --------------- End Distributor V2 Integration --------------- //
        //}else{
        //    //update previous status to null so that old process can be performed
        //    if(!newAssessmentList.isEmpty()){
        //        for(Assessment__c ass : newAssessmentList){
        //            ass.PreviousStatus__c = '';
        //        }
        //    }
        //}//end else

        //RRJ Check time tracing for other methode 24/10/2022
        time11 = ((datetime.now()).getTime() - qryStart11.getTime());
        time11 = (time11.divide(1000, 5));
        //time11 = time11 - decimal.valueOf(time4) - decimal.valueOf(time17);
        time11 = time11 - d4 - d17;
        system.debug('RRJ time 11 ='+time11);

        //RRJ Check time tracing for other methode 24/10/2022
        datetime qryStart12 = datetime.now();
        if(!newAssessmentList.isEmpty()){
            //RLa 27/03/18 C-002271:  Corrections/evolutions sur les log        
            assessmentName = newAssessmentList[0].Name;
            Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;
            integer totNumberPartsV1 = 0;
            String finalTypeV1 ='';

            if (assessIdPartsMap.size() > 0){
                if (assessIdPartsMap.containskey(newAssessmentList[0].AssessmentID__c)){
                    for (PartList__c part: assessIdPartsMap.get(newAssessmentList[0].AssessmentID__c)){
                        if (part.SelectedByBS__c == true && part.RecordTypeId == materialRt)  {
                            totNumberPartsV1++;
                            finalTypeV1 = concatenateFinalType(part.Type__c, finalTypeV1);

                        } 
                    }   
                }   
            }

            //RLA 13/07/18 : C-002234 : BE - Informex Target LOT 2
            if (isInformex && BSAssessment != null){
                newAssessmentList.add(BSAssessment);    
            }
                        
            datetime qryStart = datetime.now();
            //upsert assessments
            List<Database.upsertResult> uResults = Database.upsert(newAssessmentList, assessExtId, false);
            time8 = ((datetime.now()).getTime() - qryStart.getTime());
            time8 = (time8.divide(1000, 5));

            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(uResults[idx].isSuccess()) {
                    // if success populate the Set of id that has been successful
                    assessSFDCIDMap.put(newAssessmentList[idx].AssessmentId__c, uResults[idx].getId() );  
                    
                    //AMI 25/10/17 : C-002041 - Distributor V2
                    //add to set id (use as return type)
                    setAssId.add(uResults[idx].getId());
                    assessmentId = uResults[idx].getId();         
                }
                else {
                    //generate the json that will be used for errors as reponse
                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('## err.getMessage() ' + err.getMessage());
                        mapErrorsCreation.put(newAssessmentList[idx].AssessmentId__c, Label.Error + ': ' + err.getMessage());
                        assessmentErrorSet.add(newAssessmentList[idx].AssessmentId__c);                        
                    }
                    // do not insert partlist, subtitutes related to assessment
                    assessIdPartsMap.remove(newAssessmentList[idx].AssessmentId__c);
                    assessSubstituteListMap.remove(newAssessmentList[idx].AssessmentId__c);
                }
            }
        }
        system.debug('assessSubstituteListMap when failure remove parts>>'+assessSubstituteListMap);
        // update account Ref
        if(!accountRefToUpdate.isEmpty()){
            update accountRefToUpdate.values();
        }

        //RRJ Check time tracing for other methode 24/10/2022
        time12 = ((datetime.now()).getTime() - qryStart12.getTime());
        time12 = (time12.divide(1000, 5)); 
        time12 = time12 - time8;
        system.debug('RRJ Time 12 = '+time12);

        //RRJ Check time tracing for other methode 24/10/2022
        datetime qryStart14 = datetime.now();
        if(!assessIdPartsMap.isEmpty()){
            //RRJ Check time tracing for other methode 24/10/2022
            datetime qryStart13 = datetime.now();
            List<PartList__c> plList =  new List<PartList__c>();
            List<PartList__c> delPlList =  new List<PartList__c>();

            
            for(String key: assessIdPartsMap.keyset()){
                plList.addAll(assessIdPartsMap.get(key));
                // ASE: 21/05/2018 : C-002278 
                if(typeDistMap.size() > 0 ){
                    for(partlist__c pl : plList){
                        
                        pl.TECHDistList__c = String.join(new List<String>(typeDistMap.get(pl.Type__c)), ';');
                        
                    }
                }                
            }

            
            for(String techPart : partsToDelSet){
                delPlList.add(new PartList__c(TECH_OriginalPart__c = techPart, isDeleted__c = true));
            }

            system.debug(delPlList);
            if(delPlList.size() > 0){
                plList.addAll(delPlList);
            }
            system.debug('setTransmittedTechOriginalPart>>'+setTransmittedTechOriginalPart);
            system.debug('setExistingParts>>'+setExistingParts);
            //AMI 20/11/17 : C-002041 - Distributor V2 - pricing (best price + isSelectedByBS,RecommendedByBS)
            // --------------- Start Distributor V2 Pricing --------------- //
            
            //build mapUpdatedPartsBooleanCheck for parts transmitted during second call only --> for these parts existing, they should always be checked and 
            //no best price algo should be run
            String prefixPartNumber = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);
            if(!setTransmittedTechOriginalPart.isEmpty()){
                if(!setExistingParts.isEmpty()){
                    for(string str : setTransmittedTechOriginalPart){
                        if(setExistingParts.contains(str.toUpperCase())){   
                            if (isIG){
                                string keyOEMIG = '-'+system.label.DEsubstiturePrefix;
                                system.debug('@@ str.substringBeforeLast(keyOEMIG): '+str.substringBeforeLast(keyOEMIG));

                                if (isIG && returnwrap != null && returnwrap.mapTechOriginalKeyOriginalPartNoDist != null && returnwrap.mapTechOriginalKeyOriginalPartNoDist != null && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(str.substringBeforeLast(keyOEMIG))) {
                                    mapUpdatedPartsBooleanCheck.put((str.substringBeforeLast(keyOEMIG)).toUpperCase(),new PartList__c(SelectedByBS__c = true, RecommendedByAS__c = true));
                                }
                                else if (isIG && returnwrap != null && returnwrap.mapTechOriginalKeyOriginalPartNoDist != null && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(str.substringBeforeLast('-ASCR-'))) {
                                    
                                    mapUpdatedPartsBooleanCheck.put((str.substringBeforeLast('-ASCR-')).toUpperCase(),new PartList__c(SelectedByBS__c = true, RecommendedByAS__c = true));
                                    system.debug('^^^ isSelected after '+true+'-'+(str.substringBeforeLast('-ASCR-')));
                                }
                               //RLA 12/08/2020 C-003881: IG - Aprime per distributor
                                else if(returnwrap != null && returnwrap.mapSubsToDel != null && returnwrap.mapSubsToDel.containskey(str)){
                                    if (str.contains('-'+system.label.DEsubstiturePrefix)){
                                        string keyOEMIGO = '-'+prefixPartNumber;
                                        //select the IGO if IGP is no longer available
                                        if (mapOEMIdConnectedOemID.containskey(str.substringBeforeLast(keyOEMIG))){
                                            mapUpdatedPartsBooleanCheck.put(mapOEMIdConnectedOemID.get(str.substringBeforeLast(keyOEMIG)).toUpperCase(),new PartList__c(SelectedByBS__c = true, RecommendedByAS__c = true));
                                            system.debug('^^^ isSelected after IGO '+true+'-'+(mapOEMIdConnectedOemID.get(str.substringBeforeLast(keyOEMIG)).toUpperCase()));
                                        }
                                        //select the IGO if IGP is no longer available
                                        else{
                                            mapUpdatedPartsBooleanCheck.put((str.substringBeforeLast(keyOEMIG)).toUpperCase(),new PartList__c(SelectedByBS__c = true, RecommendedByAS__c = true));
                                            system.debug('^^^ isSelected after OEM '+true+'-'+(str.substringBeforeLast(keyOEMIG)));

                                        }
                                        
                                    }
                                    else if (str.contains('-'+prefixPartNumber)){
                                        string keyOEMIGO = '-'+prefixPartNumber;
                                        mapUpdatedPartsBooleanCheck.put((str.substringBeforeLast(keyOEMIGO)).toUpperCase(),new PartList__c(SelectedByBS__c = true, RecommendedByAS__c = true));
                                        mapUpdatedPartsBooleanCheck.put(str.toUpperCase(),new PartList__c(RecommendedByAS__c = false));
                                        
                                    }
                                    

                                }
                                else{
                                    mapUpdatedPartsBooleanCheck.put(str.toUpperCase(),new PartList__c(SelectedByBS__c = true));
                                    system.debug('^^^ isSelected after '+true+'-'+str);

                                }
                            }      
                            else{            
                                //add to mapUpdatedPartsBooleanCheck
                                
                                mapUpdatedPartsBooleanCheck.put(str.toUpperCase(),new PartList__c(SelectedByBS__c = true));
                            }

                        }
                    }
                }//end if !setExistingTechOriginalPart.isEmpty()
            }//end if !setTransmittedTechOriginalPart.isEmpty()
            //Boolean TechCarBrandExcluded = false;
            //if(!newAssessmentList.isEmpty()){
            //    TechCarBrandExcluded = newAssessmentList[0].TechCarBrandExcluded__c;
            //}
            
            system.debug('isBsOrExpertLinkedAss>>'+isBsOrExpertLinkedAss);
            system.debug('mapDistPartTypesStatusAllowed>>'+mapDistPartTypesStatusAllowed);
            system.debug('preferredType>>'+preferredType);
            system.debug('OEMIAMMap>>'+OEMIAMMap);

            if (isBsOrExpertLinkedAss 
                || mapDistPartTypesStatusAllowed.size() > 0
                || String.isnotBlank(preferredType ) ){//RLA 10/02/2021 C-004175: Preferred part type pour un Expert 

                // for (String OEMKey: mapOriginalTechOriginalPartSetSubsAllPart.keyset()){
                //     system.debug('@@ OEMKEy: '+OEMKey);    

                    // if(OEMIAMMap != null && OEMIAMMap.containsKey(cleanseOEMKey)){ 
                        if(OEMIAMMap.size() > 0){
                            Map<String, List<CrossReference__c>> OEMNoPartialACRMap = new Map<String, List<CrossReference__c>>();
                            map<String,map<String,CrossReference__c>> mapAssessmentIAMfinale = new map<String,map<String,CrossReference__c>> ();
                            Map<String, String> mapTechOriCrName = new map<String, string>();

                                                
                            // if(isForcedNoA){
                                // remove all A'
                                for(String OEMkey : OEMIAMMap.keyset()){
                                    // system.debug('@@ OEMKEy ' + OEMkey);
                                    Map<String, String> mapOemTechOriP = new map<String, string>();
                                    if (mapOEMKeyTechOri.containsKey(OEMKEy)){
                                        mapOemTechOriP.putAll(mapOEMKeyTechOri.get(OEMKEy));
                                    }
                                    // system.debug('@@ mapOemTechOriP ' + mapOemTechOriP);

                                    for(CrossReference__c CR: OEMIAMMap.get(OEMkey)){
                                        Boolean allowBPartial = true;  

                                        // if (mapOemTechOriP.containsKey(CR.Name)){
                                        //     mapTechOriCrName.put(mapOemTechOriP.get(CR.Name), CR.Name);
                                        // }
                                        Map<String, List<String>> mapPartTypesStatusAllowed = splitForPartTypesStatus(CR.Name);
                                        system.debug('@@ mapPartTypesStatusAllowed ' + mapPartTypesStatusAllowed);

                                       
                                        if (isBsOrExpertLinkedAss 
                                            && mapPartTypesStatusAllowed.size() > 0
                                            //&& String.IsnotBlank(mapSubstituteTechOriginalPartPartlist.get(subsKey).PartNumber__c) 
                                            //&& (mapSubstituteTechOriginalPartPartlist.get(subsKey).PartNumber__c).startsWith('ASCR-') 
                                            && mapOemTechOriP.containsKey(CR.Name)
                                            && ASCRStatusMap.containsKey(mapOemTechOriP.get(CR.Name)) 
                                            && mapPartTypesStatusAllowed.containskey(cr.IAMPartClass__c)
                                            ){   

                                            string stock = ASCRStatusMap.get(mapOemTechOriP.get(CR.Name)) ;
                                            // system.debug('@@@ stock: '+stock);
                                            if (!mapPartTypesStatusAllowed.get(cr.IAMPartClass__c).contains(stock)){
                                                allowBPartial = false;
                                                // system.debug('@@@ CR.NAme: '+CR.NAme);

                                            }
                                            else{
                                                system.debug('i am not sending this ASCR: '+CR.NAme);
                                                    
                                            }
                                        }
                                        // system.debug('@@ allowBPartial: '+allowBPartial);
                                        
                                        //RLA 19/01/2022 C-004449: Algo Substitution Albax
                                        if(allowBPartial 
                                          && (!(isForcedNoA && CR.IAMPartClass__c == 'A')
                                              && !(isForcedAlbax && CR.IAMPartClass__c != 'E'))
                                          ){

                                            if(!OEMNoPartialACRMap.containsKey(OEMkey)){
                                                OEMNoPartialACRMap.put(OEMkey, new list<CrossReference__c>{CR});
                                            }
                                            else{                                                            
                                                OEMNoPartialACRMap.get(OEMkey).add(CR);
                                            }
                                        
                                        }
                                }
                        }
                    // }
                    

                    if(OEMNoPartialACRMap.size() > 0){
                            //RLA 10/08/2020 C-003738: Recommend C part Bodyshop by Bodyshop
                            Boolean doPreferred = false;
                            if (String.isnotBlank(preferredType )){
                                doPreferred = true;

                            }
                    //         // find best match
                            ASPISServiceSubstitution.processAllCRMap(new map <String, map<String, list<CrossReference__c>>>{newAssessmentList[0].AssessmentID__c => OEMNoPartialACRMap}, new map<String, map<String,list<CrossReference__c>>>(),  mapAssessmentIAMfinale,preferredType,doPreferred);
                            // system.debug('@@ mapAssessmentIAMfinale: '+mapAssessmentIAMfinale);
                            // system.debug('@@ mapTechOriCrName: '+mapTechOriCrName);

                            // Map<OEM PartNumber, IAM with least price>
                            Map<String, CrossReference__c> OEMIAMPriceMapNoPartial  = new Map<String, CrossReference__c>();
                            Map<String, CrossReference__c> OEMIAMPriceMapNew  = new Map<String, CrossReference__c>();
                            mapEntitysetPartListTechId = new Map<String, Set<String>>();

                            if(mapAssessmentIAMfinale.size() > 0){
                                OEMIAMPriceMapNoPartial.putAll(mapAssessmentIAMfinale.get(newAssessmentList[0].AssessmentID__c));
                                // OEMIAMPriceMapNew.putAll(mapAssessmentIAMfinale.get(newAssessmentList[0].AssessmentID__c));


                                
                            }

                            
                            // system.debug('@@ OEMIAMPriceMapNoPartial: '+OEMIAMPriceMapNoPartial);
                            // system.debug('@@ newPartMapGlo: '+newPartMapGlo);

                           
                           String crossRefBrand = assessCarMap.get(newAssessmentList[0].AssessmentID__c).split(';')[2];

                            for(String newPartKey : newPartMapGlo.keyset()){
                                PartList__c pl = newPartMapGlo.get(newPartKey);
                                String cleanseOEMKey  = cleanseReference(pl.PartNumber__c) + '-' + crossRefBrand;
                                // string newExtId       = pl.ExternalId__c;
                                String OEMKey         = pl.PartNumber__c + '-' + crossRefBrand;   

                                if(OEMIAMMap != null && OEMIAMMap.containsKey(cleanseOEMKey)){                
                                    for(CrossReference__c CR : OEMIAMMap.get(cleanseOEMKey)){

                                        if(newPartDescMapGlo.containsKey(newAssessmentList[0].AssessmentID__c + '-' + OEMKey)){

                                            for(String partKey: newPartDescMapGlo.get(newAssessmentList[0].AssessmentID__c + '-' + OEMKey)){
                                                // 07/12/16: bug when using containsKey
                                                //if(newPartMap.containsKey(partKey)){
                                                if(newPartKey == partKey){
                                                    // system.debug('@@ partKey: '+partKey);
                                                    // system.debug('@@ mapOriginalTechOriginalPartSetSubsTechOriginalPart: '+mapOriginalTechOriginalPartSetSubsTechOriginalPart.containsKey(partKey));

                                                    if (mapOriginalTechOriginalPartSetSubsTechOriginalPart.containsKey(partKey)){
                                                        for (String subsTechKey: mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(partKey)){
                                                            system.debug('@@ subsTechKey'+subsTechKey);
                                                            // system.debug('@@ subsTechKey'+OEMIAMPriceMapNoPartial.containsKey(cleanseOEMKey)); 

                                                            if (subsTechKey.contains(CR.Name)){

                                                               //RLA 17/08/2020 RLA  C-003738: Recommend C part Bodyshop by Bodyshop
                                                               //Line to remove to rollback 3728
                                                                Boolean isPartialStillPresent = OEMIAMPriceMapNoPartial.containsKey(cleanseOEMKey) && OEMIAMPriceMapNoPartial.get(cleanseOEMKey).Name == CR.Name && !OEMNoPartialACRMap.containskey(cleanseOEMKey);
                                                                // Boolean isPartialStillPresent = false;

                                                                
                                                                // system.debug('@@@  CR.Name: '+ CR.Name);
                                                                // system.debug('@@@ isPartialStillPresent: '+isPartialStillPresent);

                                                                if (!isPartialStillPresent){
                                                                    Map<String, String> mapOemTechOriSubs = new map<String, string>();

                                                                    if (mapOEMKeyTechOri.containsKey(cleanseOEMKey)){
                                                                        mapOemTechOriSubs.putAll(mapOEMKeyTechOri.get(cleanseOEMKey));
                                                                    }

                                                                    // system.debug('@@@  OmapOemTechOriSubs: '+ mapOemTechOriSubs);
                                                                    // system.debug('@@@  OEMIAMPriceMapNoPartial.get(cleanseOEMKey).Name: '+ OEMIAMPriceMapNoPartial.get(cleanseOEMKey).Name);
                                                                    String newSubskeyToadd = OEMIAMPriceMapNoPartial.containskey(cleanseOEMKey) ? (mapOemTechOriSubs.containsKey(OEMIAMPriceMapNoPartial.get(cleanseOEMKey).Name) ? mapOemTechOriSubs.get((OEMIAMPriceMapNoPartial.get(cleanseOEMKey).Name)) : null) : null;

                                                                                                                                                                                                             system.debug('@@@  newSubskeyToadd: '+ newSubskeyToadd);

                                                        
                                                                    mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(partKey).remove(subsTechKey);
                                                                    if (String.isnotBlank(newSubskeyToadd)){
                                                                        mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(partKey).add(newSubskeyToadd);
                                                                    }
                                                                                                                                         
                                                                    //added such that in case of forcedNoA it will launch master rules
                                                                    if(OEMIAMPriceMapNoPartial != null && OEMIAMPriceMapNoPartial.containskey(cleanseOEMKey) && enCode != null){              
                                                                        if(mapEntitysetPartListTechId.containsKey(enCode)){
                                                                            mapEntitysetPartListTechId.get(enCode).add(newSubskeyToadd);
                                                                        }
                                                                        else{
                                                                            mapEntitysetPartListTechId.put(enCode, new set<String>{newSubskeyToadd});
                                                                        }
                                                                    }
                                                                }

                                                            }
                                                           
                                                            // if (OEMIAMPriceMapNoPartial.containsKey(cleanseOEMKey)){

                                                            //     Boolean = 
                                                            //     system.debug('@@ OEMIAMPriceMapNoPartial.get(cleanseOEMKey)'+OEMIAMPriceMapNoPartial.get(cleanseOEMKey));

                                                            //     Map
                                                            // }
                                                        }
                                                    }
                                                    

                                                }
                                            }

                                            // buildMapOriginalTechOriginalPartSetSubsTechOriginalPart(partKey,newSubstitute);
                                        } 
                                    }
                                }//endfor OEMIAMMap
                                 system.debug('@@@ mapEntitysetPartListTechId: '+mapEntitysetPartListTechId);

                            }

                        // if(!mapOriginalTechOriginalPartSetSubsTechOriginalPart.isEmpty()){

                        //     for(string originalKey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.keySet()){
                        //         system.debug('@@ originalKey'+originalKey);
                        //         for (String subskey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey)){
                        //             if (mapTechOriCrName.containsKey(subskey)){
                        //                 system.debug('@@ say yeah'+mapTechOriCrName.get(subskey));
                        //                 // if (mapAssessmentIAMfinale)
                        //             }
                        //         } 
                        //     }                         

                        // }
                    }
                }

            }
             system.debug('^^^^ mapOriginalTechOriginalPartSetSubsTechOriginalPart '+mapOriginalTechOriginalPartSetSubsTechOriginalPart);
             system.debug('^^^^ setExistingTechOriginalPart '+setExistingTechOriginalPart);

            //find best match for new parts only
            if(!mapOriginalTechOriginalPartSetSubsTechOriginalPart.isEmpty()){
                for(string originalKey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.keySet()){
                    
                    system.debug('^^^^ for OEM: originalKey '+originalKey);
                    //check if no subs exist for this original ==> originalKey.size() must be one
                    //in this case, no pricing should be run and this original part should be selected by default if part is new only
                    if(mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey).size() == 1 && !setExistingTechOriginalPart.contains(originalKey.toUpperCase())){
                        
                        //add to mapUpdatedPartsBooleanCheck
                        mapUpdatedPartsBooleanCheck.put(originalKey.toUpperCase(),new PartList__c(SelectedByBS__c = true,
                        RecommendedByAS__c = true));
                        system.debug('^^^^ mapUpdatedPartsBooleanCheck '+mapUpdatedPartsBooleanCheck);
                        
                    }
                    else if(mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey).size() > 1 && !setExistingTechOriginalPart.contains(originalKey.toUpperCase()) && !isForcedNoA
                    && !isProposed //RLA 11/12/2018 CJP
                    && !isForcedAlbax //RLA 19/01/2022 C-004449: Algo Substitution Albax
                    // && !isNonAxa //RLA //RLA 31/03/2021 C-004277
                        ){
                    //get intial original price
                        //Integer noCrossRefsE = 0;
                        //price of ASP
                        double price = (returnWrap != null && 
                                       returnWrap.mapTechOriginalKeyOriginalPart.containsKey(originalKey) &&
                                       returnWrap.mapTechOriginalKeyOriginalPart.get(originalKey).Price__c != null &&
                                       string.isBlank(returnWrap.errorReported)) ? 
                                       (returnWrap.mapTechOriginalKeyOriginalPart.get(originalKey).Price__c) :
                                       ((mapOriginalTechOriginalPartPartlist.containsKey(originalKey) &&
                                       mapOriginalTechOriginalPartPartlist.get(originalKey).Price__c != null) ? 
                                       mapOriginalTechOriginalPartPartlist.get(originalKey).Price__c : 0.0);

                        if (isIG){
                            price = 922337203685480000.00;
                        }
                        string selectedPart = originalKey;

                        String selectedEPArt;
                        //base on subs, check if subs price is less than price defined above
                        Integer priority = 1000;
                        Decimal priceOfPreferred;

                        for(string subsKey : mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey)){

                            if(mapSubstituteTechOriginalPartPartlist.containsKey(subsKey) ){
                                Integer currentPriority = mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c != null ? rankingOfPartlists(mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c) : 1000; 

                                Boolean allowBPartial = true;                                 
                                // system.debug('@@@ got in 4482: '+stock);

                                 //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
                                Map<String, List<String>> mapPartTypesStatusAllowed = splitForPartTypesStatus(mapSubstituteTechOriginalPartPartlist.get(subsKey).PartNumber__c);
                                system.debug('mapPartTypesStatusAllowed>>'+mapPartTypesStatusAllowed);
                                if (isBsOrExpertLinkedAss 
                                    && mapPartTypesStatusAllowed.size() > 0
                                    && String.IsnotBlank(mapSubstituteTechOriginalPartPartlist.get(subsKey).PartNumber__c) 
                                    && (mapSubstituteTechOriginalPartPartlist.get(subsKey).PartNumber__c).startsWith('ASCR-') 
                                    && ASCRStatusMap.containsKey(mapSubstituteTechOriginalPartPartlist.get(subsKey).TECH_OriginalPart__c) 
                                    && mapPartTypesStatusAllowed.containskey(mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c)){   

                                    string stock = ASCRStatusMap.get(mapSubstituteTechOriginalPartPartlist.get(subsKey).TECH_OriginalPart__c);
                                     system.debug('@@@ stock: '+stock);
                                     system.debug('@@@ mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c: '+mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c);
                                    if (!mapPartTypesStatusAllowed.get((mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c)).contains(stock)){
                                        allowBPartial = false;
                                    }
                                }
                                         
                                 system.debug('## allowB:'+allowBPartial);  
                                // system.debug('## type:'+mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c);
                                // system.debug('## TECH_OriginalPart__c:'+mapSubstituteTechOriginalPartPartlist.get(subsKey).TECH_OriginalPart__c);
                                // system.debug('## currentPriority:'+currentPriority);
                                // system.debug('## priority:'+priority);

                                Boolean allowWithPreffered = true;

                                if (priceOfPreferred != null && priceOfPreferred < mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c){
                                    allowWithPreffered = false;    
                                }
                                // system.debug('## allowWithPreffered:'+allowWithPreffered);
                                // system.debug('## priceOfPreferred:'+priceOfPreferred);


                                if (allowBPartial){
                                    //bypassPriority if there is a preferred parttype
                                    if (preferredType == mapSubstituteTechOriginalPartPartlist.get(subsKey).type__c && mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c != null &&mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c < price){
                                            price = mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c;
                                            if (currentPriority == null){
                                                priority = 0;
                                            }
                                            
                                            selectedPart = subsKey;
                                            priceOfPreferred = price;
                                            // system.debug('## here preferredtype:');

                                    }
                                    //Bypass pricing ig current priority is less than old priority
                                    else if (currentPriority < priority 
                                        && allowWithPreffered){
                                        priority = currentPriority;
                                        price = mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c;
                                        selectedPart = subsKey;
                                        // system.debug('## here less:');


                                    }
                                    //RLA 12/08/2020 C-003881: IG - Aprime per distributor
                                    else if (currentPriority == priority 
                                            && mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c != null && (mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c < price || (isIG && mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c <= price)) ){
                                            price = mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c;
                                            priority = currentPriority;
                                            selectedPart = subsKey;
                                            // system.debug('## here equal:');

                                    }

                                    //RLA  03/06/2019     C-003143 : Preseletion de la pièce E pour la France 
                                    if (mapOriginalTechOriginalPartSetSubsPartEs.containskey(originalKey)
                                        && mapOriginalTechOriginalPartSetSubsPartEs.get(originalKey).size() > 0
                                        && mapSubstituteTechOriginalPartPartlist.get(subsKey).Type__c == 'E'){
                                        system.debug('## do selection E:'+mapSubstituteTechOriginalPartPartlist.get(subsKey).Description__c);
                                        if (system.label.EPartsDistributorsPrincipal != 'none'){
                                            selectedEPArt = selectionE (mapOriginalTechOriginalPartSetSubsPartEs, originalKey, system.label.EPartsDistributorsPrincipal);
                                            system.debug('## selectedEPArt Principal:'+selectedEPArt);

                                        }
                                        if (system.label.EPartsDistributors != 'none' && String.isBlank(selectedEPArt)){
                                            selectedEPArt = selectionE (mapOriginalTechOriginalPartSetSubsPartEs, originalKey, system.label.EPartsDistributors);
                                            system.debug('## selectedEPArt secondary:'+selectedEPArt);

                                        }
                                        // system.debug('## selectedEPArt:'+selectedEPArt);
                                        if (selectedEPArt != null){
                                            selectedPart = selectedEPArt;
                                        } 
                                    }
                                    // system.debug('## subsKey:'+subsKey);
                                    // system.debug('## mapEntitysetPartListTechId:'+mapEntitysetPartListTechId);
                                }

                                //if price is < than above, set price with this new value and the parts from which this occurs
                                // if(
                                //    && allowBPartial
                                //    ){
                                    // price = mapSubstituteTechOriginalPartPartlist.get(subsKey).Price__c;
                                    // system.debug('## mapSubstituteTechOriginalPartPartlist.get(subsKey):'+mapSubstituteTechOriginalPartPartlist.get(subsKey));


                                    // selectedPart = subsKey;
                                    
                                    
                                // }
                            }
                        }//end looping in each subs for each original 

                        //add to mapUpdatedPartsBooleanCheck
                        mapUpdatedPartsBooleanCheck.put(selectedPart.toUpperCase(),new PartList__c(SelectedByBS__c = true,
                                                                                                    RecommendedByAS__c = true));
                        // system.debug('^^^ isSelected after '+true+'-'+selectedPart);
                        // system.debug('^^^ selectedEPArt:'+selectedEPArt);

                        if (selectedPart == selectedEPArt ){
                            if(mapEntitysetPartListTechId.containsKey(encode)){
                                set<String> tempSetSubsTechOri = new set<String>();

                                tempSetSubsTechOri = mapEntitysetPartListTechId.get(encode);
                                // system.debug('## tempSetSubsTechOri:'+tempSetSubsTechOri);

                                if (tempSetSubsTechOri.size() > 0
                                    && !tempSetSubsTechOri.contains(selectedPart)){
                                    mapEntitysetPartListTechId.get(encode).add(selectedPart);

                                }
                            }
                            else{
                                mapEntitysetPartListTechId.put(encode, new set<String>{selectedPart});
                                // system.debug('## got here');
                            }

                        }

                        // ASE 13/04/2018 
                        mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey).remove(selectedPart);
                        for(String SubKey2 : mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey)){
                            if(SubKey2.contains('ASCR-')){
                                ascrNonSelectedSet.add(SubKey2);
                            }
                        }
                    }
                }//end looping in map.keySet()
            }//end if mapOriginalTechOriginalPartSetSubsTechOriginalPart.isEmpty()
 

            // --------------- End Distributor V2 Pricing --------------- //
            // system.debug('@@mapOriginalTechOriginalPartSetSubsAllPart' + mapOriginalTechOriginalPartSetSubsAllPart);
            // system.debug('@@mapTechOriASCROEM' + mapTechOriASCROEM);
            // system.debug('@@isForcedNoA' + isForcedNoA);

            //RRJ Check time tracing for other methode 24/10/2022
            time13 = ((datetime.now()).getTime() - qryStart13.getTime());
            time13 = (time13.divide(1000, 5));
            system.debug('RRJ time 13 ='+time13);
            //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 

            
            set<String> setAllowedSubstitutes = new set<String>();

            for(String key: assessSubstituteListMap.keyset()){
                //RLA 19/01/2022 C-004449: Algo Substitution Albax
                if (isBsOrExpertLinkedAss && (isForcedNoA || isForcedAlbax))   {
                    for (PartList__c substitutes: assessSubstituteListMap.get(key)){ 
                        // system.debug('@@@ substitutes: '+substitutes);
                         //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
                        Map<String, List<String>> mapPartTypesStatusAllowed = splitForPartTypesStatus(substitutes.PartNumber__c);
                        
                        if(String.IsnotBlank(substitutes.PartNumber__c) && substitutes.PartNumber__c.startsWith('ASCR-') && ASCRStatusMap.containsKey(substitutes.TECH_OriginalPart__c) && mapPartTypesStatusAllowed.size() > 0 && mapPartTypesStatusAllowed.containskey(substitutes.type__c)){
                            string stock = ASCRStatusMap.get(substitutes.TECH_OriginalPart__c);
                            // system.debug('@@@ stock: '+stock);
                            // if (mapPartTypesStatusAllowed.containskey(substitutes.type__c)){
                            if (!((mapPartTypesStatusAllowed.get(substitutes.type__c)).contains(stock))){
                                // setAllowedSubstitutes(substitutes);  
                                // system.debug('@@@ i will select oem');
                                // system.debug('@@@ mapTechOriASCROEM '+ mapTechOriASCROEM.containskey(substitutes.TECH_OriginalPart__c));
                                if (mapTechOriASCROEM.containsKey(substitutes.TECH_OriginalPart__c)){
                                    string oemKey = mapTechOriASCROEM.get(substitutes.TECH_OriginalPart__c);
                                    // system.debug('@@@ oemKey '+ oemKey);
                                    // system.debug('@@@ mapOriginalTechOriginalPartSetSubsAllPart '+ (mapOriginalTechOriginalPartSetSubsAllPart.get(oemKey)).size());
                                    if (mapOriginalTechOriginalPartSetSubsAllPart.containsKey(oemKey)){
                                        if ((mapOriginalTechOriginalPartSetSubsAllPart.get(oemKey)).size() == 1){
                                            mapUpdatedPartsBooleanCheck.put(oemKey.toUpperCase(),new    PartList__c(SelectedByBS__c = true,RecommendedByAS__c = true));
                                            // system.debug('^^^ IsSelected '+ oemKey );
                                        }
                                    }
                                }
                                
                            }
                            // }
                            
                        } 
                        // else{
                        //     setAllowedSubstitutes(substitutes);
                        // }
                    }
                }
               
            }

            //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
            for(PartList__c pl : plList){
                if(pl.PartNumber__c != null){

                    //Commented by RLA C-004176 UpsertAssessment : valeurs renvoyées pour l'OEM Margin et OEM Discount
                    // if(mapPartNumCrossRef.containsKey(cleanseReference(pl.PartNumber__c))){
                    //     pl.StandardDiscount__c = mapPartNumCrossRef.get(cleanseReference(pl.PartNumber__c)).OEMStandardDiscount__c;
                    //     pl.StandardMargin__c = mapPartNumCrossRef.get(cleanseReference(pl.PartNumber__c)).OEMStandardMargin__c;
                    // }else{
                        //ASE : 08/11/17 : case C-002070
                        String plKey = pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase();
                        if(originalPartsMap.containsKey(plKey)){
                            PartList__c existingPL = originalPartsMap.get(plKey);
                            pl.StandardDiscount__c = existingPL.StandardDiscount__c;
                            pl.StandardMargin__c = existingPL.StandardMargin__c;
                        }
                        else if(pl.StandardDiscount__c == 0.0 && pl.StandardMargin__c == 0.0){
                            pl.StandardDiscount__c = 0.0;
                            pl.StandardMargin__c = 0.0;
                        }
                    // }
                    // // ASE : C-002782: 12/12/18
                    // if((isProposed || isForcedNoA)//RLA 25/02/2019 cjp A'            
                    //     && !setExistingParts.contains((pl.TECH_OriginalPart__c).toUpperCase())//RLA 08/04/2019 C-003148: SAS V2    
                    // ){                        
                    //     pl.RecommendedByAS__c = pl.SelectedByBS__c; 
                    //     system.debug('@@got in 1 after' + pl.RecommendedByAS__c);

                    // }   
                    // //07-JUN-2019 RLA  C-003143 : Preseletion de la pièce E pour la France
                    // if (mapOEMASCRSE.containskey(pl.TECH_OriginalPart__c)){                        
                    //     pl.ASCREListRandomNumber__c = mapOEMASCRSE.get(pl.TECH_OriginalPart__c);

                    // }                 
                }
                // system.debug('@@ returnWrap.mapTechOriginalKeyOriginalPart'+returnWrap.mapTechOriginalKeyOriginalPart);

                //AMI 10/11/17 : C-002041 - Distributor V2 - processing response and updating parts
                //                        - upsert parts based on distributor returned response
                if(returnWrap != null && string.isBlank(returnWrap.errorReported)){
                    //updating original parts with info from distributor
                    //if there exists IGP do not update OEM
                    
                     if(returnWrap.mapTechOriginalKeyOriginalPart.containsKey(pl.TECH_OriginalPart__c) ){
                        //RLA 09/07/2020 C-003857: IG - Creation IGO
                        // if (!mapOEMIdConnectedOemID.containskey(pl.TECH_OriginalPart__c)){ 
                            pl.Stock__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).Stock__c;

                            //AMI 25/01/18 : C-002041 - Distributor V2 - Do not update price on original during A' Creation
                            /*//AMI 17/01/18 : Check if update of this field is availble in map else use original transmiited
                            if(returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).Price__c != null){
                                pl.Price__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).Price__c;
                            }
            
                            pl.ASNetPrice__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).ASNetPrice__c;
                            pl.StandardDiscount__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).StandardDiscount__c;
                            pl.StandardMargin__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).StandardMargin__c;*/

                            //AMI 12/02/2018 - C-002041 - Distributor V2 - Update std discount and margin during A' Creation
                            pl.StandardDiscount__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).StandardDiscount__c;
                            pl.StandardMargin__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).StandardMargin__c;
                        // }
                        //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
                        if (isIG){
                            pl.TECHDistList__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).TECHDistList__c;
                            pl.Distributors__c = returnWrap.mapTechOriginalKeyOriginalPart.get(pl.TECH_OriginalPart__c).Distributors__c;
                        }
                    }
                    else if (isIG && returnWrap != null && string.isBlank(returnWrap.errorReported) && !returnWrap.mapTechOriginalKeyOriginalPartNoDist.isEmpty()){
                        // system.debug('@@ we are in map of updating oem with no dist');
                        if(returnWrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(pl.TECH_OriginalPart__c)){
                            // pl.SelectedByBS__c = false;
                            // pl.RecommendedByAS__c = mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).RecommendedByAS__c;
                             pl.TECHDistList__c = returnWrap.mapTechOriginalKeyOriginalPartNoDist.get(pl.TECH_OriginalPart__c).TECHDistList__c;
                            pl.Distributors__c = returnWrap.mapTechOriginalKeyOriginalPartNoDist.get(pl.TECH_OriginalPart__c).Distributors__c;
                            pl.Stock__c = returnWrap.mapTechOriginalKeyOriginalPartNoDist.get(pl.TECH_OriginalPart__c).Stock__c;

                        }

                    }
                }
                // system.debug('### expertSubstitutionMethod: '+expertSubstitutionMethod);
                //AMI 20/11/17 : C-002041 - Distributor V2 - pricing (best price + isSelectedByBS,RecommendedByBS)
                // ase: 07/03/18 : do not run algo 
                if(!isExpert || (isExpert && (expertSubstitutionMethod == 'FORCED' )) || (accountForced) || (expertSubstitutionMethod == 'FORCED NO A\'')){
                    if(mapUpdatedPartsBooleanCheck.containsKey(pl.TECH_OriginalPart__c.toUpperCase())){
                        pl.SelectedByBS__c = mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).SelectedByBS__c;
                        Boolean toUpdate = (mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).getPopulatedFieldsAsMap()).containsKey('RecommendedByAS__c');
                        if(toUpdate){
                            pl.RecommendedByAS__c = mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).RecommendedByAS__c;
                        }
                    }else{
                        pl.SelectedByBS__c = false;
                    }
                }

                if (isnonAxa){
                    pl.SelectedByBS__c = true;
                    pl.RecommendedByAS__c = true;


                }
                //moved here by RLA 24/08/2020 C-003738 Recommend C part Bodyshop by Bodyshop
                if(pl.PartNumber__c != null){
                    // ASE : C-002782: 12/12/18
                    //RLA 19/01/2022 C-004449: Algo Substitution Albax
                    if((isProposed || isForcedNoA || isForcedAlbax)//RLA 25/02/2019 cjp A'            
                        && !setExistingParts.contains((pl.TECH_OriginalPart__c).toUpperCase())//RLA 08/04/2019 C-003148: SAS V2    
                    ){                        
                        pl.RecommendedByAS__c = pl.SelectedByBS__c; 
                        // system.debug('@@got in 1 after' + pl.RecommendedByAS__c);

                    }   
                    //07-JUN-2019 RLA  C-003143 : Preseletion de la pièce E pour la France
                    if (mapOEMASCRSE.containskey(pl.TECH_OriginalPart__c)){                        
                        pl.ASCREListRandomNumber__c = mapOEMASCRSE.get(pl.TECH_OriginalPart__c);

                    }     

                }
            }//endfor plList
            // system.debug('@@ plList: '+plList);
            

            datetime qryStart = datetime.now();
            system.debug('upserting partlist 1');
            //system.debug('upserting partlist 1 nonConnectedEToRemove>>'+nonConnectedEToRemove);
            system.debug('upserting partlist 1 plList>>'+plList);
            upsert plList TECH_OriginalPart__c;
            time9 = ((datetime.now()).getTime() - qryStart.getTime());
            time9 = (time9.divide(1000, 5));


            
            //20-09-2019 RLA  C-003143 : Preseletion de la pièce E pour la France 
            if (plList.size() > 0){
                for (partlist__c part:plList ){
                    mapTechOriOem.put(part.TECH_OriginalPart__c, part);
                }
            }
            // system.debug('@@ mapTechOriOem: '+mapTechOriOem);
            // system.debug('@@ isBsOrExpertLinkedAss: '+isBsOrExpertLinkedAss);
            // system.debug('@@ mapPartTypesStatusAllowed.size(): '+mapPartTypesStatusAllowed.size());
            // system.debug('@@ ASCRStatusMap: '+ASCRStatusMap);
            // system.debug('@@ allsubPartsMap: '+allsubPartsMap);

            //RLA 04/05/2020 C-003696: IG - Part recommendation & selected by BS

            // List<PartList__c> plaList =  new List<PartList__c>();
            map<String, partlist__c> mapPlaList = new map<String,partlist__c>();
             //RLA 09/07/2020 C-003857: IG - Creation IGO
            //  String prefixPartNumber = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);

            //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
            for(String key: assessSubstituteListMap.keyset()){
                if (isBsOrExpertLinkedAss  && !isIG)   {
                     //RLA okay for using a different map
                    for (PartList__c substitutes: assessSubstituteListMap.get(key)){ 
                        system.debug('@@@ substitutes: '+substitutes);
                        //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
                        Map<String, List<String>> mapPartTypesStatusAllowed = splitForPartTypesStatus(substitutes.PartNumber__c);
                        if(String.IsnotBlank(substitutes.PartNumber__c) && substitutes.PartNumber__c.startsWith('ASCR-') && ASCRStatusMap.containsKey(substitutes.TECH_OriginalPart__c) && mapPartTypesStatusAllowed.size() > 0 && mapPartTypesStatusAllowed.containskey(substitutes.type__c)){
                            string stock = ASCRStatusMap.get(substitutes.TECH_OriginalPart__c);
                            system.debug('@@@ stock: '+stock);
                            // if (mapPartTypesStatusAllowed.containskey(substitutes.type__c)){
                            if ((mapPartTypesStatusAllowed.get(substitutes.type__c)).contains(stock)){
                                // plaList.add(substitutes); 
                                mapPlaList.put(substitutes.TECH_OriginalPart__c, substitutes);   
                            }
                            // }
                            
                        } 
                        else{
                            // plaList.add(substitutes);
                            mapPlaList.put(substitutes.TECH_OriginalPart__c, substitutes);   

                        }
                    }
                }
                else if(isIG ){
                    map<String, partlist__c> mapUpdatedSubs = new map<String, partlist__c>();
                    if (returnWrap != null && string.isBlank(returnWrap.errorReported)  ){
                        
                        if (returnWrap.substitutePart.size() > 0){
                            for (partlist__c part: returnWrap.substitutePart){
                            // System.debug('@@@@part: '+part);
                            mapUpdatedSubs.put(part.TECH_OriginalPart__c, part);
                            // returnWrap.substitutePart.remove(part);
                        }

                        }
                        
                            // System.debug('@@@@mapUpdatedSubs: '+mapUpdatedSubs);

                        for (partlist__c part: assessSubstituteListMap.get(key)){
                            // System.debug('@@@@part: '+part.TECH_OriginalPart__c);
                            if (mapUpdatedSubs.containskey(part.TECH_OriginalPart__c)){
                                part.Stock__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).Stock__c;
                                part.StandardDiscount__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).StandardDiscount__c;
                                part.StandardMargin__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).StandardMargin__c;
                                //RLA 22/04/2020  Case 3695: Subject    IG - IGP Substitution part
                                part.TECHDistList__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).TECHDistList__c;
                                part.Distributors__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).Distributors__c;
                                part.Distributor__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).Distributors__c;
                                part.ASNetPrice__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).ASNetPrice__c;
                                part.Price__c = mapUpdatedSubs.get(part.TECH_OriginalPart__c).Price__c;
                                // plaList.add(part);
                                mapPlaList.put(part.TECH_OriginalPart__c, part);   

                            }
                            //RLA 09/07/2020 C-003857: IG - Creation IGO 
                            else if(returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+system.label.DEsubstiturePrefix)) || returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+'ASCR-')) || ( String.isnotBlank(prefixPartNumber) && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+prefixPartNumber)))) {
                                // system.debug('@@ we have an IGP with no availability:'+part.TECH_OriginalPart__c);
                               

                                if (returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+system.label.DEsubstiturePrefix))){
                                     part.Stock__c = (returnwrap.mapTechOriginalKeyOriginalPartNoDist.get(part.TECH_OriginalPart__c.substringBeforeLast('-'+system.label.DEsubstiturePrefix))).Stock__c;
                                }
                                //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                else if (( String.isnotBlank(prefixPartNumber) && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+prefixPartNumber)))) {
                                    part.Stock__c = (returnwrap.mapTechOriginalKeyOriginalPartNoDist.get(part.TECH_OriginalPart__c.substringBeforeLast('-'+prefixPartNumber))).Stock__c;

                                }
                                 //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                else if (( String.isnotBlank('ASCR-') && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast('-'+'ASCR-')))) {
                                    part.Stock__c = (returnwrap.mapTechOriginalKeyOriginalPartNoDist.get(part.TECH_OriginalPart__c.substringBeforeLast('-'+'ASCR-'))).Stock__c;

                                }
                                //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
                                Map<String, List<String>> mapPartTypesStatusAllowed = splitForPartTypesStatus(part.PartNumber__c);
                                //RLA Creation ASCR
                                if (mapPartTypesStatusAllowed.size() > 0 )   {                                    
                                    // system.debug('@@@ partssy: '+part);

                                    if(String.IsnotBlank(part.PartNumber__c) && part.PartNumber__c.startsWith('ASCR-') && ASCRStatusMap.containsKey(part.TECH_OriginalPart__c) && mapPartTypesStatusAllowed.containskey(part.type__c)){
                                        string stock = ASCRStatusMap.get(part.TECH_OriginalPart__c);
                                        // system.debug('@@@ stock: '+stock);
                                        // system.debug('@@@ allsubPartsMap.containskey(part.TECH_OriginalPart__c): '+setExistingParts.contains(part.TECH_OriginalPart__c));
                                        // if (mapPartTypesStatusAllowed.containskey(substitutes.type__c)){
                                        if ((mapPartTypesStatusAllowed.get(part.type__c)).contains(stock)){
                                            // plaList.add(substitutes); 
                                            mapPlaList.put(part.TECH_OriginalPart__c, part);   
                                            // system.debug('@@@ put ASCR Here: '+part.TECH_OriginalPart__c);

                                        }
                                        else if (setExistingParts.contains(part.TECH_OriginalPart__c)){
                                            // system.debug('@@@ put ASCR to IsDeleted Here: '+part.TECH_OriginalPart__c);
                                            part.isDeleted__c = true;
                                            part.RecommendedByAS__c = false;
                                            mapPlaList.put(part.TECH_OriginalPart__c, part);   
                                        }
                                        // }
                                        
                                    } 
                                    else {
                                        // plaList.add(substitutes);
                                        

                                        part.isDeleted__c = true;
                                        part.RecommendedByAS__c = false;
                                        mapPlaList.put(part.TECH_OriginalPart__c, part);   

                                    }
                                    
                                } 
                                else{
                                    part.isDeleted__c = true;
                                    part.RecommendedByAS__c = false;
                                    mapPlaList.put(part.TECH_OriginalPart__c, part);  

                                }


                            }
                            //RLA 12/08/2020 C-003881: IG - Aprime per distributor
                            else if(returnwrap.mapSubsToDel.containsKey(part.TECH_OriginalPart__c)){
                                // system.debug('@@ delete one substitue');
                                part.isDeleted__c = true;
                                part.RecommendedByAS__c = false;
                                part.SelectedByBS__c = false;
                                mapPlaList.put(part.TECH_OriginalPart__c, part);  


                            }
                            else{
                                // plaList.add(part);    
                                mapPlaList.put(part.TECH_OriginalPart__c, part);   

                            }
                            

                            // returnWrap.substitutePart.remove(mapUpdatedSubs.get(part.TECH_OriginalPart__c));
                        }
                    }
                    //RLA 20/10/2020 IG Selection
                    else{
                        for (partlist__c part: assessSubstituteListMap.get(key)){
                            mapPlaList.put(part.TECH_OriginalPart__c, part);   
                        }

                    }
                    // system.debug('@@ part.TECH_OriginalPart__c:'+part.TECH_OriginalPart__c);
                    // if (returnWrap != null && string.isBlank(returnWrap.errorReported) && returnWrap.mapTechOriginalKeyOriginalPartNoDist.size() > 0 ){
                    //     string keyOEMIG = '-'+system.label.DEsubstiturePrefix;
                    //     system.debug('@@ str.substringBeforeLast(keyOEMIG): '+part.TECH_OriginalPart__c.substringBeforeLast(keyOEMIG));

                    //     if (isIG && returnwrap.mapTechOriginalKeyOriginalPartNoDist.containsKey(part.TECH_OriginalPart__c.substringBeforeLast(keyOEMIG))) {
                    //         system.debug('@@ we have an IGP with no availability');
                    //     }
                    // }
                }//endfor isIG
               
                else{
                    for (partlist__c part: assessSubstituteListMap.get(key)){
                        mapPlaList.put(part.TECH_OriginalPart__c, part);

                    }
                    // plaList.addAll(assessSubstituteListMap.get(key));
                }
            }
            // System.debug('@@@@ plaList before adding updated parts: '+mapPlaList);
            // System.debug('@@@@ returnWrap.substitutePart: '+returnWrap.substitutePart);
            
            //AMI 10/11/17 : C-002041 - Distributor V2 - processing response and updating parts
            //                        - upsert parts based on distributor returned response
            //add substitute created based on info from distributor
            if(returnWrap != null && string.isBlank(returnWrap.errorReported)){
                if(returnWrap.substitutePart.size() > 0){
                    for (partlist__c part: returnWrap.substitutePart){
                        if (!mapPlaList.containsKey(part.TECH_OriginalPart__c)){
                            mapPlaList.put(part.TECH_OriginalPart__c, part);
                        }


                    }
                    // plaList.addAll(returnWrap.substitutePart);
                }//end if returnWrap.substitutePart.size() > 0
            }


            integer count = 0;
            //xxxwch
            List<String> nonConnectedEToRemove = new List<String>();
            Map<Id,String> mapOriginalsToUpdate = new Map<Id,String>();
            Map<String,integer> countNoASCRPerOEM =new Map<String,integer>();
            system.debug('mapUpdatedPartsBooleanCheck>>'+mapUpdatedPartsBooleanCheck);
            //AMI 20/11/17 : C-002041 - Distributor V2 - pricing (best price + isSelectedByBS,RecommendedByBS)
            // ase: 07/03/18 : do not run algo
            for(PartList__c pl : mapPlaList.values()){
                if(!isExpert || (isExpert && (expertSubstitutionMethod == 'FORCED' )) || (accountForced) || (expertSubstitutionMethod == 'FORCED NO A\'')){
                
                    count++;
                    if(mapUpdatedPartsBooleanCheck.containsKey(pl.TECH_OriginalPart__c.toUpperCase()) && !isNONAXA){
                        system.debug('^^^ isSelected before '+pl.SelectedByBS__c+'-'+pl.PartNumber__c);
                        pl.SelectedByBS__c = mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).SelectedByBS__c;
                        Boolean toUpdate = (mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).getPopulatedFieldsAsMap()).containsKey('RecommendedByAS__c');
                        if(toUpdate){
                            pl.RecommendedByAS__c = mapUpdatedPartsBooleanCheck.get(pl.TECH_OriginalPart__c.toUpperCase()).RecommendedByAS__c;
                        }
                    }else{
                        pl.SelectedByBS__c = false;
                    }
                }

                // ASE: 23/04/18 : stock
                if(pl.PartNumber__c.startsWith('ASCR-') && ASCRStockMap.containsKey(pl.TECH_OriginalPart__c)){
                    pl.Stock__c = ASCRStockMap.get(pl.TECH_OriginalPart__c);
                }       
                //XXXwch
                if(String.isNotBlank(pl.Type__c) && pl.Type__c.equals('E')){
                    boolean hasConnectedEDist=false;
                    List<String> lineInfo = (String.isNotBlank(pl.TECH_OriginalPart__c) ? pl.TECH_OriginalPart__c : 'NOTFOUND-NOTFOUND-NOTFOUND').split('-');
                    system.debug('lineInfo>>'+lineInfo);
                    system.debug('pl.TECH_OriginalPart__c>>'+pl.TECH_OriginalPart__c);
                    for(String currentConnectedELineId : connectedELineIds){
                        system.debug('currentConnectedELineId>>'+currentConnectedELineId);
                        if(String.isNotBlank(pl.TECH_OriginalPart__c) && !pl.TECH_OriginalPart__c.equals(currentConnectedELineId) && currentConnectedELineId.containsIgnoreCase(lineInfo[0]+'-'+lineInfo[1]+'-ASCR-')){
                            system.debug('got in>>'+lineInfo[0]+'-'+lineInfo[1]+'-ASCR-');
                            nonConnectedEToRemove.add(pl.TECH_OriginalPart__c);
                        }
                        else if(String.isNotBlank(pl.TECH_OriginalPart__c) && pl.TECH_OriginalPart__c.equals(currentConnectedELineId)){
                            hasConnectedEDist=true;
                            pl.RecommendedByAS__c=true;
                            pl.SelectedByBS__c=true;
                        }
                    }
                    if(!hasConnectedEDist){//remove Partlist with dist pre by AS 
                        if(String.isNotBlank(pl.Distributor__c) && piecXRefDistributor.containsKey(pl.Distributor__c) && piecXRefDistributor.get(pl.Distributor__c).Name.equals(System.label.xRefConnectedEDistributor) && String.isNotBlank(pl.TECH_OriginalPart__c)){
                            List<String> techOrig=pl.TECH_OriginalPart__c.split('-ASCR');
                            mapOriginalsToUpdate.put(pl.OriginalPart__c,techOrig[0]);
                            nonConnectedEToRemove.add(pl.TECH_OriginalPart__c);
                        }
                    }
                }
                if(pl.SelectedByBS__c)
                    countNoASCRPerOEM.put(pl.OriginalPart__c,(!countNoASCRPerOEM.containsKey(pl.OriginalPart__c)?1:(countNoASCRPerOEM.get(pl.OriginalPart__c)+1)));
            }
            

            System.debug('//mapPlaList'+mapPlaList);

            qryStart = datetime.now();
            system.debug('upserting partlist 2');
            system.debug('upserting partlist 2 nonConnectedEToRemove>>'+nonConnectedEToRemove);
            system.debug('upserting partlist 2 mapPlaList values before>>'+mapPlaList.values());
            //xxxwch remove all non connectedE if part has connected E
            if(nonConnectedEToRemove.size()>0){
                mapPlaList.keySet().removeAll(nonConnectedEToRemove);
            }
            if(mapOriginalsToUpdate.keySet().size()>0){
                for(String currentPLId : mapOriginalsToUpdate.keySet()){
                    if(!countNoASCRPerOEM.containsKey(currentPLId))
                        mapPlaList.put(mapOriginalsToUpdate.get(currentPLId),new PartList__c(TECH_OriginalPart__c=mapOriginalsToUpdate.get(currentPLId),RecommendedByAS__c=true,SelectedByBS__c=true));
                }
            }
            system.debug('upserting partlist 2 mapPlaList values after>>'+mapPlaList.values());

            upsert mapPlaList.values() TECH_OriginalPart__c;
            time10 = ((datetime.now()).getTime() - qryStart.getTime());
            time10 = (time10.divide(1000, 5));
       

            //AMI 01/03/18 : C-002041 - Distributor V2 - Update Crossref field on assessment with those selected
            //             : this map will hold all values to be inserted in cross ref field
            map <id,set <string>> mapAssessmentSFIdSetASCRName = new map <id,set <string>>();

            //AMI 01/03/18 : C-002041 - Distributor V2 - Update Crossref field on assessment with those selected
            //             : this list will hold updated assessment containing the cross ref field
            list <Assessment__c> assToUpdateCrossRefList = new list <Assessment__c>();
            //RLA 07/03/18 : C-002041 - Distributor V2 - Update Crossref field on assessment with those selected
            //             : this map will hold updated assessment containing the cross ref field and total number of parts
            map <Id,Assessment__c> mapAssToUpdateCrossRef = new map <Id,Assessment__c>();

            //
            map <id,set <string>> mapAssessmentSFIdSetDistId = new map <id,set <string>>();

            // psa ase 31/05/18            
            set<String> PSASet = new set<String>();


            //AMI 01/03/18 : C-002041 - Distributor V2 - Update Crossref field on assessment with those selected
            //             : ReQuery Upserted assessment so that selected cross ref can be obtained in order to update cross ref field on assessment
            //AMI 13/11/17 - C-002041 - Distributor V2 - response generation after upsert operation
            //                                         - loop in upserted parts and get only those upserted due to dist callout to build
            //                                         - mapSubsPartCreatedByDistCallout
            for(PartList__c prt : [select id,OriginalPart__r.TECH_OriginalPart__c,TECH_OriginalPart__c,PartNumber__c,Price__c,Quantity__c,Type__c,
                                        Currency__c,InputType__c,Description__c,Name,ProducerName__c,Stock__c,ASNetPrice__c,Alpha_Scale_MRID__c,
                                        SelectedByBS__c,StandardDiscount__c,StandardMargin__c,isDeleted__c,CertifyingOrganization__c,CrossReferenceId__c,
                                        CrossReferenceId__r.Name,Assessment__c, TECHDistList__c, Assessment__r.Feature__c,RecommendedByAS__c /*RLA 12/06/2019 C-003260*/
                                    from PartList__c
                                    where 
                                    (id IN :mapPlaList.values()
                                    or Assessment__c IN : assessSFDCIDMap.values())
                                    //and Alpha_Scale_MRID__c != null
                                    /*and TECH_OriginalPart__c IN :setSubsCreatedByDistCallout*/]){
                if(prt.Alpha_Scale_MRID__c != null){
                    if(setSubsCreatedByDistCallout.contains(prt.TECH_OriginalPart__c)){
                        if(mapSubsPartCreatedByDistCallout.containsKey(prt.OriginalPart__r.TECH_OriginalPart__c)){
                            mapSubsPartCreatedByDistCallout.get(prt.OriginalPart__r.TECH_OriginalPart__c).add(prt);
                        }else{
                            mapSubsPartCreatedByDistCallout.put(prt.OriginalPart__r.TECH_OriginalPart__c,new list<PartList__c>{prt});
                        }
                    }
                    //AMI 20/12/17 - C-002041 - Distributor V2 - updating map used to generate response for substitutes parts
                    //                                         - build mapSubsKeySubForRespGeneration
                    mapSubsKeySubForRespGeneration.put(prt.TECH_OriginalPart__c,prt);

                    //get only parts related with ASCR that is selected only
                    if(prt.CrossReferenceId__c != null && prt.SelectedByBS__c){
                        if(mapAssessmentSFIdSetASCRName.containsKey(prt.Assessment__c)){
                            mapAssessmentSFIdSetASCRName.get(prt.Assessment__c).add(prt.CrossReferenceId__r.Name);
                        }else{
                            mapAssessmentSFIdSetASCRName.put(prt.Assessment__c,new set <string>{prt.CrossReferenceId__r.Name});
                        }
                    } 
                }

                
                String mrSourcingstring = '';
                if(prt.SelectedByBS__c){
                    // ASE: 21/05/2018 : C-002278
                    List<String> distList;
                    if(prt.TECHDistList__c != null){
                        distList = prt.TECHDistList__c.split(';');
                    } 
                    if(distList != null){  
                        for(String dist: distList){                 
                            if(mapAssessmentSFIdSetDistId.containsKey(prt.Assessment__c)){
                                mapAssessmentSFIdSetDistId.get(prt.Assessment__c).add(dist);
                            }
                            else{
                                mapAssessmentSFIdSetDistId.put(prt.Assessment__c,new set <string>{dist});
                            }
                        }
                    }
                 
                        /* WCH 18/09/2019 C-003391 commented code PSA
                        if(prt.Alpha_Scale_MRID__c!= null && prt.Alpha_Scale_MRID__c.startsWith('ASP-') && prt.Assessment__r.Feature__c == 'PilotPSA'){
                        //aspPLCounter ++;
                        ///PSAPartMap.put(prt.Assessment__c, aspPLCounter);
                        PSASet.add(prt.Assessment__c);
                        } 
                        */                     
                }

            }


            
            //loop in upserted assess first so that if not present in mapAssessmentSFIdSetASCRName, clear cross ref field for those ass
            if(assessSFDCIDMap.size() > 0){
                for(String assessId : assessSFDCIDMap.keyset()){
                    Id assid = assessSFDCIDMap.get(assessId);
                    Assessment__c ass = new Assessment__c(id = assid);
                    if(mapAssessmentSFIdSetASCRName.containsKey(assid)){                            
                        string convertedList = String.join(new list <string>(mapAssessmentSFIdSetASCRName.get(assid)), ';');
                        //Case2526 : Analyse et résolution des 3 cas « non selective query » de ce jour à 10h26 (upsert Sidexa)
                        if (String.isnotBlank(convertedList)){
                             ass.CrossReferences__c = convertedList;

                        }
                        else{
                            ass.CrossReferences__c = 'None';  

                        }
                    } 
                    else{
                        ass.CrossReferences__c = 'None'; 

                    } 
                    /* WCH 18/09/2019 C-003391 commented code PSA
                    // ASE: 21/05/2018 : C-002278
                    if(mapAssessmentSFIdSetDistId.size() > 0 && mapAssessmentSFIdSetDistId.containsKey(assid)){
                        set<String> distSet = mapAssessmentSFIdSetDistId.get(assid);
                   
                        if(assessMap.containskey(assessId) && assessMap.get(assessId).Feature__c == 'PilotPSA' && (PSASet.size() == 0 || (PSASet.size() > 0 && !PSASet.contains(assid)))){
                            if(distSet.contains(SASId)){
                               distSet.remove(SASId);
                            }

                        }

                        if((assessMap.containskey(assessId) && (assessMap.get(assessId).Feature__c == null || assessMap.get(assessId).Feature__c != 'PilotPSA'))  && distSet.contains(PSAId)){
                            distSet.remove(PSAId);                           
                        }
                        system.debug('@@ distSet: '+distSet);                        
                        
                        ass.MRSourcing__c = String.join(new list <string>(distSet), ';');                
                    }
                    else{
                        //WCH 30/08/2018 C-002754:update MRSourcing__c even when not found in mapAssessmentSFIdSetDistId 
                        ass.MRSourcing__c = null;
                    }  */  
                    //WCH 18/09/2019 C-003391 rewrite part where mrsourcing populated
                    if(mapAssessmentSFIdSetDistId.size() > 0 && mapAssessmentSFIdSetDistId.containsKey(assid)){
                        set<String> distSet = mapAssessmentSFIdSetDistId.get(assid);
                        ass.MRSourcing__c = String.join(new list <string>(distSet), ';');
                    }else ass.MRSourcing__c = 'false';//WCH 25/11/2019 C-003490
                    system.debug('>>3 theAss.MRSourcing__c>>'+ass.MRSourcing__c);
                    
                    //WCH 31/08/2018 C-002754: comment since map will not be updated here
                    theAssesToUpdate.put(assid,ass);                                    
                }
            }//end if assessSFDCIDMap.size() > 0


            /*system.debug('## mapAssToUpdateCrossRef ' + mapAssToUpdateCrossRef);
            if(!mapAssToUpdateCrossRef.isEmpty()){
                update mapAssToUpdateCrossRef.values();
            }*/
            //RRJ Check time tracing for other methode 24/10/2022
            time14 = ((datetime.now()).getTime() - qryStart14.getTime());
            time14 = (time14.divide(1000, 5));
            time14 = time14 - time10 - time9 - time13;
            system.debug('RRJ time 14 ='+time14);
        }


        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - insertAll ----------------------------------');
        
        //AMI 25/10/17 : C-002041 - Distributor V2
        //return successful upserted assessment
        
        return setAssId;
    }   

    public static String concatenateFinalType (String typePart, String typefinal){
        String finalType;
        
        if(typePart == 'A' ){
            if(string.isNotBlank(typefinal) ){
                if (!typefinal.contains('A')){
                    typefinal += ';A';
                }
            }else{
                typefinal = 'A';
            }
        }

        if(typePart == 'B'  ){           
            if(string.isNotBlank(typefinal)){
                if ( !typefinal.contains('B')){
                    typefinal += ';B';
                }
            }else{
                typefinal = 'B';
            }
        }

        if(typePart == 'C' ){
            if(string.isNotBlank(typefinal) ){
                if (!typefinal.contains('C')){
                    typefinal += ';C';
                }
            }else{
                typefinal = 'C';
            }
        }

        if(typePart == 'D' ){
            if(string.isNotBlank(typefinal) ){
                if(!typefinal.contains('D')){
                    typefinal += ';D';
                }
            }else{
                typefinal = 'D';
            }
        }

        if(typePart  == 'P'){
            if(string.isNotBlank(typefinal) ){
                if(!typefinal.contains('P')){
                    typefinal += ';P';
                }
            }else{
                typefinal = 'P';
            }
        }
        if(typePart  == 'X'){
            if(string.isNotBlank(typefinal) ){
                if(!typefinal.contains('X')){
                    typefinal += ';X';
                }
            }else{
                typefinal = 'X';
            }
        } 

        return typefinal; 
    }
   

    public static String generateResponse(Map<String, Assessment__c> assessMap, Map<String, List<PartList__c>> assessIdPartsMap, Map<String, List<CrossReference__c>> OEMIAMMap, Map<String, CrossReference__c> OEMIAMPriceMap, set<String> setTechId, Map<String, list<Object>> shoppingListExistAssessMap, Map<String, List<PartList__c>> shopAssessIdPartsMap, Boolean isNevada){
        System.debug('---------------------------------- START RESTUpsertAssessmentV2 - generateResponse ----------------------------------');
        String response = '';
        
        //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
        map<String,Set<String>> mapAssmntToolIamManu = new map<String,Set<String>>();
        // if (true){
            mapAssmntToolIamManu = ASPISServiceSubstitution.createMapAssmntIamManu(system.label.CS_XrefHidden);
        // }
        system.debug('@@ mapAssmntToolIamManu: '+mapAssmntToolIamManu);
        boolean useMockResponse = false;
        //RRJ 04/08/2022
        Log__c logResponse = null;
        if (system.label.Response_Upsert_Assessment != 'none' && system.label.Response_Upsert_Assessment.StartsWith('a0D')){
            logResponse = [Select id,JSONResponse__c from Log__c Where Id = :system.label.Response_Upsert_Assessment];
            if (logResponse != null && logResponse.JSONResponse__c != null){
                useMockResponse = true;
                
            }
        }
        
        if(logResponse != null && useMockResponse){
            response = logResponse.JSONResponse__c;
        }
        else{
            // JSONGenerator;
            JSONGenerator genResults = JSON.createGenerator(false);
            // start array of Assessment
            if(isNevada){
                genResults.writeStartObject();
                    genResults.writeFieldName('Assessments');
            }
            genResults.writeStartArray();
                if(assessSFDCIDMap != null){
                    for(String assessExtId : assessSFDCIDMap.keySet()){
                        if(assessMap.containsKey(assessExtId)){
                            String assessId = assessMap.get(assessExtId).Id; 
                            String assessmentId;
                            String carBrandRes = assessCarMap.get(assessExtId).split(';')[0];
                            String carManBrand = assessCarMap.get(assessExtId).split(';')[2];

                            // start Object Assessment
                            genResults.writeStartObject();
                                if(isNevada){//VSU 24/07/17
                                    if(assessMap.get(assessExtId).callerSystem__c != null){
                                        //genResults.writeStringField('callerSystem', assessMap.get(assessExtId).callerSystem__c);
                                        if(assessMap.get(assessExtId).callerSystem__c.contains('DIVA')){
                                            genResults.writeStringField('callerSystem','Lacour' );
                                        }
                                        else if(assessMap.get(assessExtId).callerSystem__c.contains('SIDEXA')){
                                            genResults.writeStringField('callerSystem','Sidexa');
                                        }else{
                                            genResults.writeStringField('callerSystem','FR_ICE');
                                        }
                                    }                                
                                }
                                system.debug('JSAAssessmentNumber' + assessMap.get(assessExtId).AssessmentNumber__c);
                                system.debug('JSAAssessmentNumber2' + assessMap.get(assessExtId));
                                //RLA 06/12/2021 NONAXA should never receive Assessment Number
                                //C-004544: Bug - NON AXA - Sendback the assessment number
                                if(assessMap.get(assessExtId).AssessmentNumber__c != null && (!assessMap.get(assessExtId).isShoppingList__c)){
                                    genResults.writeStringField('AssessmentNumber',  assessMap.get(assessExtId).AssessmentNumber__c);
                                } else {
                                    genResults.writeStringField('AssessmentNumber',  '');
                                }

                                if(assessMap.get(assessExtId).Entity__c != null){
                                    genResults.writeStringField('Entity', assessMap.get(assessExtId).Entity__c);
                                }
                                genResults.writeStringField('EntityCode', assessMap.get(assessExtId).EntityCode__c);
                                
                                if(assessMap.get(assessExtId).MissionNumber__c != null){
                                    genResults.writeStringField('MissionNumber', assessMap.get(assessExtId).MissionNumber__c);
                                }
                                
                                String assessName;

                                if(assessMap.get(assessExtId).isShoppingList__c){
                                    if(assessMap.get(assessExtId).Name != null){
                                        assessName = assessMap.get(assessExtId).Name;
                                    }
                                    else{
                                        assessName = assessMap.get(assessExtId).AssessmentNumber__c;
                                    }
                                }
                                else{
                                    assessName = assessMap.get(assessExtId).Name;
                                }
                                genResults.writeStringField('Name', assessName);
                                
                                if(assessMap.get(assessExtId).VINCheck__c != null){
                                    genResults.writeNumberField('VINCheck', assessMap.get(assessExtId).VINCheck__c);
                                }
                                                            
                                assessmentId = assessId;                       

                                Blob data = Blob.valueOf(assessmentId);
                                String encryptedAssessId = EncodingUtil.base64Encode(data);
                                String siteURL = system.label.SiteOrder+'?AssessmentId=' + encryptedAssessId;
                                // ASE : 27/02/ 2018: case 2186
                                //DUN 09/04/2018 case C-002418: Bypass Order Choose Assessment
                                // system.debug('## systemCalling:'+assessMap.get(assessExtId).callerSystem__c);
                                string callerSystem = assessMap.get(assessExtId).callerSystem__c;

                                list<String> systemCalling = callerSystem.contains('_') ? callerSystem.split('_') : null;
                                //siteURL = (system.label.bypass.contains(callerSystem.left(2)) || (systemCalling != null && systemCalling[1].equals('DAT'))) ? (siteURL + '&Order=1') : siteURL;
                                siteURL = (system.label.bypass.contains(callerSystem.left(2))) ? (siteURL + '&Order=1') : siteURL;
                                //RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
                                //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop 
                                siteURL = !isExpert && bodyshopToReplace == null ? siteURL + '&flag=true' : siteURL;
                                // System.debug(' ## siteURL:' +siteURL);  

                                if(isIG && String.isnotBlank(bodyshopId)){
                                    string bsRef = '';
                                    for (AccountRef__c accRef: [SELECT ExternalReference__c FROM AccountRef__c WHERE InternalReference__c = :bodyshopId AND systemCalling__c = :system.label.CallerSystemSiteUrlIG]){
                                        bsRef = accRef.ExternalReference__c ;

                                    }
                                    
                                    // ASE: 27/10/16: retrieve ReferenceNumber by splitting Name.
                                    //genResults.writeStringField('ReferenceNumber', accRef.ExternalReference__c);
                                    // if (accRef != null){
                                    //     bsRef = accRef.Name.substringAfter('-');
                                    // } 
                                    String assessIdIG = assessMap.get(assessExtId).AssessmentID__c;
                                    siteURL = system.label.IGSiteURL + 'mcid=' +bsRef + '&assessmentid='+assessIdIG;    
                                }
                                
                                if(!isNevada){
                                    genResults.writeStringField('URL', siteURL);
                                }

                                // start write Parts
                                genResults.writeFieldName('Parts');  

                                // start array of Parts
                                genResults.writeStartArray();
                                    if(assessIdPartsMap.containskey(assessExtId) && !shoppingListExistAssessMap.containsKey(assessExtId)){
                            
                                        for(PartList__c partList: assessIdPartsMap.get(assessExtId)){                                            
                                            // start Object Part
                                            // system.debug('## partList:'+partList);
                                            if(!partList.isDeleted__c){
                                                // ASE : 13/04/17: sent manual parts as well, as per CCH
                                                //if ( (String.valueOf(partList.InputType__c)).toUpperCase() != 'MANUAL'){
                                                    genResults.writeStartObject();
                                                        genResults.writeStringField('PartLabel', partList.Description__c);
                                                        //genResults.writeStringField('Name', partList.Name);
                                                        genResults.writeStringField('PartNumber', partList.PartNumber__c);
                                                        genResults.writeNumberField('Price', partList.Price__c);

                                                        if(partList.ProducerName__c != null){
                                                            genResults.writeStringField('Manufacturer', partList.ProducerName__c);
                                                        }
                                                        
                                                        genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                        if(partList.InputType__c != null){
                                                            genResults.writeStringField('InputType', partList.InputType__c);
                                                        }

                                                        if(isNevada){
                                                            if(partList.InterventionCode__c != null){
                                                                genResults.writeStringField('InterventionCode', partList.InterventionCode__c);
                                                            }
                                                            //RLA 16/08/2021 C-004408: PostNevada sends duplicate fields
                                                            // if(partList.NBHoursLabourPartLevel1__c != null){
                                                            //     genResults.writeNumberField('NBHoursLabourPartLevel1', partList.NBHoursLabourPartLevel1__c);
                                                            // }
                                                            system.debug('@@@ check nevada 3');
                                                        
                                                        
                                                            if(partList.NBHoursLabourPartLevel2__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPartLevel2', partList.NBHoursLabourPartLevel2__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPartLevel3__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPartLevel3', partList.NBHoursLabourPartLevel3__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPainting__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPainting', partList.NBHoursLabourPainting__c);
                                                            }

                                                            if(partList.ARCAUTOCode__c != null){
                                                                genResults.writeStringField('ARCAUTOCode',partList.ARCAUTOCode__c);
                                                            }
                                                            //RLA 16/08/2021 C-004408: PostNevada sends duplicate fields
                                                            // if(partList.Compliance__c != null){
                                                            //     genResults.writeBooleanField('RecordType',partList.Compliance__c); 
                                                            // }

                                                            if(partList.RecordTypeId != null){
                                                                genResults.writeStringField('RecordType',partList.RecordTypeId);
                                                            }

                                                        }
                                                        
                                                        if(partList.Currency__c != null){
                                                            genResults.writeStringField('Currency', partList.Currency__c);
                                                        }                                                

                                                        if(partList.Type__c != null){
                                                            genResults.writeStringField('Type', partList.Type__c);
                                                        }

                                                        if(setTechId.size() > 0 && setTechId.contains(partList.TECH_OriginalPart__c)){
                                                            genResults.writeBooleanField('IsSelected', true);
                                                        }
                                                        else{
                                                            genResults.writeBooleanField('IsSelected', partList.SelectedByBS__c);
                                                            //RLA 12/06/2019 C-003260- UpsertAssessment to send back 'recommendedbyAS' information
                                                            if ((!partList.RecommendedByAS__c) ){
                                                                genResults.writeStringField('ASChoice', '**');
                                                            }
                                                            else{
                                                                genResults.writeStringField('ASChoice', '');                                                                
                                                            }
                                                        }

                                                        if(partList.CrashCode__c != null){
                                                            genResults.writeNumberField('crashCode', integer.valueOf(partList.CrashCode__c));
                                                        }

                                                        //AMI 19/07/17 : New External Id being sent in ass request
                                                        if(partList.ExternalId__c != null){
                                                            genResults.writeStringField('ExternalID', partList.ExternalId__c);
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        if(partList.StandardDiscount__c != null){
                                                            genResults.writeNumberField('OEMStandardDiscount', partList.StandardDiscount__c);
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        if(partList.StandardMargin__c != null){
                                                            //RLA 14/12/2018 C-002782 CJP A'
                                                            genResults.writeNumberField('OEMStandardMargin', (partList.StandardMargin__c).setScale(2, System.RoundingMode.HALF_UP));
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        genResults.writeStringField('OEMStock', partList.Stock__c);

                                                        //AMI 25/01/18 : C-002195 - Audatex Integration
                                                        //                        - send updated values (nb working hours/unit)
                                                        if(partList.NBHoursLabourPartLevel1__c != null && partList.NBHoursLabourPartLevel1__c > 0){
                                                            genResults.writeNumberField('NBHoursLabourPartLevel1', partList.NBHoursLabourPartLevel1__c);
                                                        }

                                                        if(partList.NBHoursLabourPartLevel2__c != null && partList.NBHoursLabourPartLevel2__c > 0){
                                                            genResults.writeNumberField('NBHoursLabourPartLevel2', partList.NBHoursLabourPartLevel2__c);
                                                        }

                                                        if(partList.NBHoursLabourPartLevel3__c != null && partList.NBHoursLabourPartLevel3__c > 0){
                                                            genResults.writeNumberField('NBHoursLabourPartLevel3', partList.NBHoursLabourPartLevel3__c);
                                                        }

                                                        if(mapTechOriginalPartKeyAudatexUnsavedFld.containsKey(partList.TECH_OriginalPart__c.toUpperCase())){
                                                            audatexUnSavedFields tempAudatexFLd = mapTechOriginalPartKeyAudatexUnsavedFld.get(partList.TECH_OriginalPart__c.toUpperCase());
                                                            
                                                            if(tempAudatexFLd.NBWorkingUnitLevel1 != null && tempAudatexFLd.NBWorkingUnitLevel1 > 0){
                                                                genResults.writeNumberField('NBWorkingUnitLevel1', tempAudatexFLd.NBWorkingUnitLevel1);
                                                            }

                                                            if(tempAudatexFLd.NBWorkingUnitLevel2 != null && tempAudatexFLd.NBWorkingUnitLevel2 > 0){
                                                                genResults.writeNumberField('NBWorkingUnitLevel2', tempAudatexFLd.NBWorkingUnitLevel2);
                                                            }

                                                            if(tempAudatexFLd.NBWorkingUnitLevel3 != null && tempAudatexFLd.NBWorkingUnitLevel3 > 0){
                                                                genResults.writeNumberField('NBWorkingUnitLevel3', tempAudatexFLd.NBWorkingUnitLevel3);
                                                            }
                                                        }//end outer if

                                                        //AMI 25/01/18 : C-002189 - Informex Integration
                                                        //                        - send newly added info
                                                        if(partList.Deducible__c != null && partList.Deducible__c > 0){
                                                            genResults.writeNumberField('Deducible', partList.Deducible__c);
                                                        }

                                                        if(partList.ObsoleteRatio__c != null && partList.ObsoleteRatio__c > 0){
                                                            genResults.writeNumberField('ObsoleteRatio', partList.ObsoleteRatio__c);
                                                        }

                                                        // start write Substitutions
                                                        genResults.writeFieldName('Substitutions');
                                                        // start array of Substitution
                                                        genResults.writeStartArray();

                                                        String partKey =  partList.PartNumber__c + '-' + carManBrand;
                                                        String cleansePartKey =  cleanseReference(partList.PartNumber__c) + '-' + carManBrand;
                                                        
                                                        if(OEMIAMMap != null && OEMIAMMap.containskey(cleansePartKey)){
                                                            for(CrossReference__c cr: OEMIAMMap.get(cleansePartKey)){


                                                                //AMI 02/02/18 - C-002041 - Distributor V2 - Prevent Creation of cross ref parts if price is greater than original
                                                                double crossRefPrice = (CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c;
                                                                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                                                                if (isnonAxa){
                                                                    if(CR.Connected__c && isnonAxa){
                                                                        crossRefPrice = partList.Price__c ; 
                                                                    }else{
                                                                        crossRefPrice = (CR.NONAXA_AS_Public_Price__c == null) ?  0 : CR.NONAXA_AS_Public_Price__c;
                                                                    }
                                                                }

                                                                //ZZZ kem
                                                                if(CR.Connected__c){
                                                                    crossRefPrice = (CR.PRE_Price__c + (partList.Price__c * (CR.OEMStandardDiscount__c / 100)) + CR.AdditionalMargin__c) ; 
                                                                    System.debug('<<<crossRefPrice>>>' + crossRefPrice);
                                                                } 


                                                                double originalPrice = partList.Price__c != null ? partList.Price__c : 1000000.0;
                                                                if(originalPrice > crossRefPrice){
                                                                    
                                                                    string translatedOrigine;
                                                                    
                                                                    if(BSLang != null && BSLang == 'nl' && String.isnotblank(CR.IAMCertifyingOrganization__c) && mapOrigineValues != null){
                                                                        //RLA 06/09/2018 C-002692 : Substitution on BE assessments
                                                                        if (mapOrigineValues.containskey(CR.IAMCertifyingOrganization__c)){
                                                                            translatedOrigine = mapOrigineValues.get(CR.IAMCertifyingOrganization__c);   
                                                                        }                         
                                                                    } 
                                                                    //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue                                                                
                                                                    String partNumber = CR.IAMPartNumber__c;
                                                                    Boolean hidePartNum = false; 

                                                                    if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank(CR.IAMManufacturer__c))) {

                                                                        if (mapAssmntToolIamManu.containskey(callersystemGlo)) {
    
                                                                            if ((mapAssmntToolIamManu.get(callersystemGlo)).contains(CR.IAMManufacturer__c)) {
                                                                                hidePartNum = true;
                                                                                partNumber = system.label.CS_cfHidden;
                                                                            }
                                                                        }
                                                                    }
                                                                    system.debug('@@ hidePartNum'+hidePartNum);
                                                                    system.debug('@@ partNumber'+partNumber);


                                                                    // ASE : 13/12/16 : use original Name - manufacturer (IAM part Number) for substitute description
                                                                    String substituteDescription = partList.Description__c + ' - ' + CR.IAMManufacturer__c + ' (' + partNumber + ')';
                                                                    substituteDescription = (CR.IAMCertifyingOrganization__c != null) ? substituteDescription + ' - '+ ((translatedOrigine != null) ? translatedOrigine : CR.IAMCertifyingOrganization__c) : substituteDescription; 

                                                                    String subName                      = substituteDescription.left(80);

                                                                    //AMI 19/07/17 : New External Id being sent in ass request
                                                                    String substituteTECH_OriginalPart  = '';
                                                                    if(string.isNotBlank(partList.ExternalId__c)){
                                                                        substituteTECH_OriginalPart  =assessExtId + '-' + partList.ExternalId__c + '-' + cr.Name;
                                                                    }else{
                                                                        substituteTECH_OriginalPart  = partList.PartNumber__c + '-'
                                                                                                    + cr.Name + '-'
                                                                                                    + subName.replaceAll('\\s+', '') + '-'
                                                                                                    + cr.IAMManufacturer__c + '-'                                                                                                
                                                                                                    + assessExtId ;
                                                                    }
                                                                    //RLA 29/06/2021 C-004391: PostNevada: envoyer les pieces avec AS Choice= vide
                                                                    system.debug('@@ nevada starts');
                                                                    system.debug('@@ substituteTECH_OriginalPart'+substituteTECH_OriginalPart);
                                                                    // if((!isNevada || (isNevada && ((setTechId != null && setTechId.contains(substituteTECH_OriginalPart)) || (mapSubsKeySubForRespGeneration.containsKey(substituteTECH_OriginalPart) && mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).RecommendedByAS__c)) )) && !isnonAxa){
                                                                    //RLA C-004545: The ASCR should not be sent in response if it distributor sends status NOT FOUND 12/10/2021
                                                                    if(mapSubsKeySubForRespGeneration.containsKey(substituteTECH_OriginalPart) && (!isNevada || (isNevada && (mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).SelectedByBS__c || mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).RecommendedByAS__c ) )) && !isnonAxa ){
                                                                        // start Object Substitution
                                                                        genResults.writeStartObject();
                                                                            //ASE :24/08/2017 - C-002016
                                                                            //if(cr.IAMPartDescription__c != null){
                                                                                genResults.writeStringField('PartLabel', substituteDescription);
                                                                            //}

                                                                            // genResults.writeStringField('PartNumber', cr.IAMPartNumber__c);

                                                                            //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
                                                                            // if(cr.IAMPartNumber__c != null){                                                                           
                                                                            
                                                                                genResults.writeStringField('PartNumber', hidePartNum ? system.label.CS_cfHidden : cr.IAMPartNumber__c);

                                                                            // }

                                                                            
                                                                            Double subsPrice = (CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c;
                                                                            //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                                                                            if (isnonAxa){
                                                                                subsPrice = (CR.NONAXA_AS_Public_Price__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.NONAXA_AS_Public_Price__c;
                                                                            }
                                                                            genResults.writeNumberField('Price',subsPrice);
                                                                            
                                                                            
                                                                            if(cr.IAMManufacturer__c != null){
                                                                                genResults.writeStringField('Manufacturer', cr.IAMManufacturer__c);
                                                                            }                                                            

                                                                            genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                                            if(cr.IAMPartClass__c != null){
                                                                                genResults.writeStringField('Type', cr.IAMPartClass__c);
                                                                            }

                                                                            genResults.writeStringField('AlphaScaleMRID', cr.Name);
                                                                            
                                                                            if(partList.InputType__c != null){
                                                                                genResults.writeStringField('InputType', partList.InputType__c);
                                                                            }
                                                                        
                                                                            if(partList.Currency__c != null){
                                                                                genResults.writeStringField('Currency', partList.Currency__c);
                                                                            }
                                                                            
                                                                            if (cr.IAMCertifyingOrganization__c != null){
                                                                                //C-002692 : ASE 27/09/2018*/
                                                                                genResults.writeStringField('CertifyingOrganization', (translatedOrigine != null) ? translatedOrigine : cr.IAMCertifyingOrganization__c);                      
                                                                            }

                                                                            Decimal StandardMargin;
                                                                            Decimal StandardDiscount;
                                                                            Decimal ASNetPrice;
                                                                            //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                                                                            if (isnonAxa){
                                                                                if(CR.NONAXA_AS_Public_Price__c == null && CR.NONAXA_AS_Net_Price__c == null){
                                                                                    StandardMargin = null;
                                                                                    StandardDiscount = null;
                                                                                }
                                                                                else if((CR.NONAXA_AS_Public_Price__c == null || CR.NONAXA_AS_Public_Price__c == 0) && CR.NONAXA_AS_Net_Price__c != null){
                                                                                    StandardMargin = 0;
                                                                                    StandardDiscount = 0;
                                                                                }
                                                                                else{
                                                                                    CR.NONAXA_AS_Net_Price__c = (CR.NONAXA_AS_Net_Price__c != null) ? CR.NONAXA_AS_Net_Price__c : CR.NONAXA_AS_Public_Price__c;
                                                                                    StandardMargin = CR.NONAXA_AS_Public_Price__c - CR.NONAXA_AS_Net_Price__c ;
                                                                                    StandardDiscount = ((1 - (CR.NONAXA_AS_Net_Price__c / CR.NONAXA_AS_Public_Price__c))*100);
                                                                                }
                                                                            }
                                                                            //ZZZ
                                                                            else if(CR.Connected__c){
                                                                                if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                                                                                    StandardMargin = null;
                                                                                    StandardDiscount = null;
                                                                                }
                                                                                else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                                                                                    StandardMargin = 0;
                                                                                    StandardDiscount = 0;
                                                                                }
                                                                                else{
                                                                                    //kem
                                                                                    CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                                                                                    StandardMargin = crossRefPrice - CR.PRE_Price__c ;
                                                                                    StandardDiscount = ((1 - (CR.PRE_Price__c / crossRefPrice))*100);
                                                                                    ASNetPrice = CR.PRE_Price__c;
                                                                                }
                                                                            }
                                                                            else{
                                                                            if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                                                                                StandardMargin = null;
                                                                                StandardDiscount = null;
                                                                            }
                                                                            else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                                                                                StandardMargin = 0;
                                                                                StandardDiscount = 0;
                                                                            }
                                                                            else{
                                                                                CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                                                                                StandardMargin = CR.ASPublicPrice__c - CR.ASNetPrice__c ;
                                                                                StandardDiscount = ((1 - (CR.ASNetPrice__c / CR.ASPublicPrice__c))*100);
                                                                            }
                                                                            }

                                                                        
                                                                                    
                                                                            if (standardMargin != null){
                                                                                genResults.writeNumberField('StandardMargin', StandardMargin.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }
                                                                            
                                                                            if (standardDiscount != null){
                                                                                genResults.writeNumberField('StandardDiscount', StandardDiscount.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }
                                                                            //RLA 15/04/2019 C-003187
                                                                            String stock =  ASCRStockMap.containskey(substituteTECH_OriginalPart) ? ASCRStockMap.get(substituteTECH_OriginalPart) : 'Available';
                                                                            genResults.writeStringField('Stock', stock);

                                                                            /*
                                                                            if(setTechId != null && setTechId.contains(substituteTECH_OriginalPart)){
                                                                                genResults.writeBooleanField('IsSelected', true);
                                                                            }
                                                                            else{
                                                                                genResults.writeBooleanField('IsSelected', false);
                                                                            }*/
                                                                            //AMI 20/12/17 - C-002041 - Distributor V2 - updating map used to generate response for substitutes parts
                                                                            //                                         - generate response for subs parts
                                                                            if(mapSubsKeySubForRespGeneration.containsKey(substituteTECH_OriginalPart)){
                                                                                genResults.writeBooleanField('IsSelected', mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).SelectedByBS__c);
                                                                                // System.debug('====> Recommended ASCR:'+mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).RecommendedByAS__c);
                                                                                //RLA 12/06/2019 C-003260- UpsertAssessment to send back 'recommendedbyAS' information
                                                                                if ((!(mapSubsKeySubForRespGeneration.get(substituteTECH_OriginalPart).RecommendedByAS__c)) ){
                                                                                    genResults.writeStringField('ASChoice', '**');
                                                                                }
                                                                                else{
                                                                                    genResults.writeStringField('ASChoice', '');
                                                                                }
                                                                            }
                                                                            
                                                                        // End Object Substitution`
                                                                        genResults.writeEndObject();
                                                                    }
                                                                }//end if originalPrice > crossRefPrice
                                                            }
                                                        }

                                                        String subPartKey =  assessExtId + '-' + partList.TECH_OriginalPart__c; 
                                                        Boolean isAllowed = true;
                                                        if (isIG && mapSubsPartCreatedByDistCallout.containsKey(partList.TECH_OriginalPart__c)){
                                                            isAllowed = false;    
                                                        }
                                                        // system.debug('@@ isAllowed: '+isAllowed);
                                                        //RLA 31/03/2021 C-004277
                                                        if(asessPartSubMap.containskey(subPartKey) && isAllowed && !isNonAxa){
                                                            
                                                            for(PartList__c sub: asessPartSubMap.get(subPartKey)){
                                                                // start Object Substitution
                                                                if(!sub.isDeleted__c){
                                                                    //RLA 29/06/2021 C-004391: PostNevada: envoyer les pieces avec AS Choice= vide
                                                                    if(!isNevada || (isNevada && (sub.SelectedByBS__c || (mapSubsKeySubForRespGeneration.containskey(sub.TECH_OriginalPart__c) && mapSubsKeySubForRespGeneration.get(sub.TECH_OriginalPart__c).RecommendedByAS__c)))){
                                                                        genResults.writeStartObject();
                                                                            //ASE 17/04/18 C-002477:
                                                                            String partNumber = ASCRPartNumbMap.get(sub.PartNumber__c) == null ? sub.PartNumber__c : ASCRPartNumbMap.get(sub.PartNumber__c);
                                                                            
                                                                            //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
                                                                            Boolean hidePartNum = false; 
                                                                            String subDescri = sub.Description__c;
                                                                            // ASE  06/04/2020 C-003401 : correction of condition
                                                                            //if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank( sub.ProducerName__c)) && (partNumber).startsWith('ASCR-')) {
                                                                            if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank( sub.ProducerName__c)) && (sub.Alpha_Scale_MRID__c).startsWith('ASCR-')) {
                                                                                if (mapAssmntToolIamManu.containskey(callersystemGlo)) {
                                                                                    if ((mapAssmntToolIamManu.get(callersystemGlo)).contains(sub.ProducerName__c)) {
                                                                                        hidePartNum = true;
                                                                                        if (String.isNotBlank(subDescri) && subDescri.contains(partNumber)){
                                                                                            subDescri = subDescri.replace(partNumber, system.label.CS_cfHidden);
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }

                                                                            if(sub.Description__c != null){
                                                                                genResults.writeStringField('PartLabel', subDescri);
                                                                            }
                                                                            
                                                                            // genResults.writeStringField('PartNumber', ((partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber));
                                                                            
                                                                            
                                                                            genResults.writeStringField('PartNumber', hidePartNum ? system.label.CS_cfHidden : ((partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber));
                                                                                                                                                
                                                                            genResults.writeNumberField('Price', sub.Price__c);

                                                                            if(sub.ProducerName__c != null){
                                                                            genResults.writeStringField('Manufacturer', sub.ProducerName__c);
                                                                            }
                                                                                                                                                
                                                                            genResults.writeNumberField('Quantity', sub.Quantity__c);
                                                                            
                                                                            if(sub.Type__c != null){
                                                                                genResults.writeStringField('Type', sub.Type__c);
                                                                            }

                                                                            genResults.writeStringField('AlphaScaleMRID', sub.Alpha_Scale_MRID__c);
                                                                            
                                                                            if(sub.InputType__c != null){
                                                                                genResults.writeStringField('InputType', sub.InputType__c);
                                                                            }
                                                                            
                                                                            if(sub.Currency__c != null){
                                                                                genResults.writeStringField('Currency', sub.Currency__c);
                                                                            }
                                                                            string translatedOrigine;
                                                                            
                                                                                                                            //AMI 28/02/18 C-002041 - Distributor V2 - Sending Certifying Org in Return JSON for ASP Parts (for successive call)
                                                                            if(sub.Alpha_Scale_MRID__c != null && string.isNotBlank(sub.Alpha_Scale_MRID__c) && sub.Alpha_Scale_MRID__c.contains('ASP-')){
                                                                                //C-002692 : ASE 27/09/2018*/
                                                                                
                                                                                if(BSLang != null && BSLang == 'nl' && system.label.ASPDesc != null && mapOrigineValues != null){
                                                                                    //string translatedOrigine = system.label.ORIGINENL;    
                                                                                    //genResults.writeStringField('CertifyingOrganization', (translatedOrigine != null) ? translatedOrigine : system.label.ASPDesc);                        
                                                                                    //RLA 06/09/2018 C-002692 : Substitution on BE assessments
                                                                                    if (mapOrigineValues.containskey(system.label.ASPDesc)){
                                                                                        translatedOrigine = mapOrigineValues.get(system.label.ASPDesc);   
                                                                                        genResults.writeStringField('CertifyingOrganization', (translatedOrigine != null) ? translatedOrigine : system.label.ASPDesc);                        

                                                                                        //translatedOrigine = system.label.ORIGINENL;   
                                                                                    } 
                                                                                } 
                                                                                else{
                                                                                    genResults.writeStringField('CertifyingOrganization', system.label.ASPDesc);

                                                                                }
                                                                            }
                                                                            else if(sub.Alpha_Scale_MRID__c != null && sub.CertifyingOrganization__c != null){
                                                                                if(BSLang != null && BSLang == 'nl' && mapOrigineValues != null){
                                                                                    //string translatedOrigine = system.label.ORIGINENL;    
                                                                                    if (mapOrigineValues.containskey(sub.CertifyingOrganization__c)){
                                                                                        translatedOrigine = mapOrigineValues.get(sub.CertifyingOrganization__c);   
                                                                                        //translatedOrigine = system.label.ORIGINENL; 
                                                                                        genResults.writeStringField('CertifyingOrganization', (translatedOrigine != null) ? translatedOrigine : sub.CertifyingOrganization__c);                        

                                                                                    } 
                                                                                } 
                                                                                else{
                                                                                    genResults.writeStringField('CertifyingOrganization', sub.CertifyingOrganization__c);

                                                                                }
                                                                            }

                                                                            if (sub.standardMargin__c != null){
                                                                                genResults.writeNumberField('StandardMargin', sub.StandardMargin__c.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }
                                                                            
                                                                            if (sub.standardDiscount__c != null){
                                                                                
                                                                                genResults.writeNumberField('StandardDiscount', sub.StandardDiscount__c.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }

                                                                            //genResults.writeStringField('Stock', 'Available');
                                                                            genResults.writeStringField('Stock', sub.Stock__c);
                                                                            
                                                                            //AMI 20/12/17 - C-002041 - Distributor V2 - updating map used to generate response for substitutes parts
                                                                            //                                         - generate response for subs parts
                                                                            if(mapSubsKeySubForRespGeneration.containsKey(sub.TECH_OriginalPart__c)){
                                                                                genResults.writeBooleanField('IsSelected', mapSubsKeySubForRespGeneration.get(sub.TECH_OriginalPart__c).SelectedByBS__c);
                                                                                //RLA 12/06/2019 C-003260- UpsertAssessment to send back 'recommendedbyAS' information
                                                                                if ((!(mapSubsKeySubForRespGeneration.get(sub.TECH_OriginalPart__c).RecommendedByAS__c))){
                                                                                    genResults.writeStringField('ASChoice', '**');
                                                                                }
                                                                                else{
                                                                                    genResults.writeStringField('ASChoice', '');
                                                                                }
                                                                                
                                                                            }
                                                                        // End Object Substitution`
                                                                        genResults.writeEndObject();  
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        //AMI 13/11/17 - C-002041 - Distributor V2 - response generation after upsert operation
                                                        //                                         - write created subs due to dist callout
                                                        //RLA 31/03/2021 C-004277
                                                        if(mapSubsPartCreatedByDistCallout.containsKey(partList.TECH_OriginalPart__c) && !isNonAxa){
                                                            //construct return data for newly created subs due to dist callout
                                                            for(PartList__c prt : mapSubsPartCreatedByDistCallout.get(partList.TECH_OriginalPart__c)){
                                                                genResults.writeStartObject();
                                                                    
                                                                    if(prt.Description__c != null){
                                                                        genResults.writeStringField('PartLabel', prt.Description__c);
                                                                    }

                                                                    //ASE 17/04/18 C-002477:
                                                                    //genResults.writeStringField('PartNumber', prt.PartNumber__c);
                                                                    genResults.writeStringField('PartNumber', (prt.PartNumber__c.startsWith('ASP-')) ? prt.PartNumber__c.split('ASP-')[1]: prt.PartNumber__c);
                                                                    
                                                                    
                                                                    genResults.writeNumberField('Price', prt.Price__c.setScale(2, System.RoundingMode.HALF_UP));

                                                                    if(prt.ProducerName__c != null){
                                                                        genResults.writeStringField('Manufacturer', prt.ProducerName__c);
                                                                    }
                                                                
                                                                    genResults.writeNumberField('Quantity', prt.Quantity__c);
                                                                    
                                                                    if(prt.Type__c != null){
                                                                        genResults.writeStringField('Type', prt.Type__c);
                                                                    }

                                                                    if(prt.InputType__c != null){
                                                                        genResults.writeStringField('InputType', prt.InputType__c);
                                                                    }
                                                                    
                                                                    if(prt.Currency__c != null){
                                                                        genResults.writeStringField('Currency', prt.Currency__c);
                                                                    }
                                                                
                                                                    genResults.writeStringField('Stock', prt.Stock__c);

                                                                    genResults.writeStringField('AlphaScaleMRID', prt.Alpha_Scale_MRID__c);

                                                                    genResults.writeBooleanField('IsSelected', prt.SelectedByBS__c);
                                                                    //RLA 12/06/2019 C-003260- UpsertAssessment to send back 'recommendedbyAS' information
                                                                    if ((!prt.RecommendedByAS__c) ){
                                                                        genResults.writeStringField('ASChoice', '**');
                                                                    }
                                                                    else{
                                                                        genResults.writeStringField('ASChoice', '');
                                                                    }



                                                                    genResults.writeNumberField('StandardDiscount', prt.StandardDiscount__c.setScale(2, System.RoundingMode.HALF_UP));

                                                                    genResults.writeNumberField('StandardMargin', prt.StandardMargin__c.setScale(2, System.RoundingMode.HALF_UP));
                                                                
                                                                    //AMI 19/02/18 C-002041 - Distributor V2 - Sending Certifying Org in Return JSON for ASP Parts
                                                                    if(prt.Alpha_Scale_MRID__c != null && string.isNotBlank(prt.Alpha_Scale_MRID__c) && prt.Alpha_Scale_MRID__c.contains('ASP-')){
                                                                        string translatedOrigine;
                                                                        //RLA 06/09/2018 C-002692 : Substitution on BE assessments
                                                                        if(BSLang != null && BSLang == 'nl' && system.label.ASPDesc != null && mapOrigineValues != null){
                                                                        //string translatedOrigine = system.label.ORIGINENL;    
                                                                            if (mapOrigineValues.containskey(system.label.ASPDesc)){
                                                                                translatedOrigine = mapOrigineValues.get(system.label.ASPDesc);   
                                                                                //translatedOrigine = system.label.ORIGINENL; 
                                                                                genResults.writeStringField('CertifyingOrganization', (translatedOrigine != null) ? translatedOrigine : system.label.ASPDesc);                        

                                                                            } 
                                                                        } 
                                                                        else{
                                                                            genResults.writeStringField('CertifyingOrganization', system.label.ASPDesc);

                                                                        }

                                                                    }     

                                                                // End Object Substitution`
                                                                genResults.writeEndObject();
                                                            }
                                                        }

                                                        // End Array Substitution
                                                        genResults.writeEndArray();
                                                    // End Object Part
                                                    genResults.writeEndObject();
                                                //}
                                            }
                                        }//end for 
                                    }//end if assessIdPartsMap.containskey(assessExtId) && !shoppingListExistAssessMap.containsKey(assessExtId)

                                    // ShoppingListTrue + existingAssessment 
                                    if(shopAssessIdPartsMap != null && shopAssessIdPartsMap.containskey(assessExtId)){
                                        for(PartList__c partList: shopAssessIdPartsMap.get(assessExtId)){
                                            system.debug(partList.PartNumber__c);

                                            genResults.writeStartObject();
                                                String partNumber = partList.PartNumber__c;
                                                                            
                                                //RLA 20/03/2020 C-003401: Autoglass Spain : Automatise offering for certain part types in ASPIS catalogue
                                                Boolean hidePartNum = false; 
                                                String subDescri = partList.Description__c;
                                            // ASE  06/04/2020 correction of condition
                                            //if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank( partList.Description__c)) && partNumber.startsWith('ASCR-')) {
                                            if (!mapAssmntToolIamManu.isEmpty() && (String.isNotBlank( partList.Description__c)) && String.isNotBlank(partList.Alpha_Scale_MRID__c) && partList.Alpha_Scale_MRID__c.startsWith('ASCR-')) {
                                                    if (mapAssmntToolIamManu.containskey(callersystemGlo)) {
                                                        if ((mapAssmntToolIamManu.get(callersystemGlo)).contains( partList.Description__c)) {
                                                            hidePartNum = true;
                                                            if (String.isNotBlank(subDescri) && subDescri.contains(partNumber)){
                                                                subDescri = subDescri.replace(partNumber, system.label.CS_cfHidden);
                                                            }
                                                        }
                                                    }
                                                }

                                                genResults.writeStringField('PartLabel', subDescri);
                                                genResults.writeStringField('PartNumber', hidePartNum ? system.label.CS_cfHidden :partList.PartNumber__c);    

                                                genResults.writeNumberField('Price', partList.Price__c);

                                                if(partList.ProducerName__c != null){
                                                    genResults.writeStringField('Manufacturer', partList.ProducerName__c);
                                                }                                           
                                                
                                                genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                if(partList.InputType__c != null){
                                                    genResults.writeStringField('InputType', partList.InputType__c);
                                                }
                                                
                                                if(partList.Currency__c != null){
                                                    genResults.writeStringField('Currency', partList.Currency__c);
                                                }                                                

                                                if(partList.Type__c != null){
                                                    genResults.writeStringField('Type', partList.Type__c);
                                                }                                            

                                                genResults.writeBooleanField('IsSelected', partList.SelectedByBS__c);
                                                //RLA 12/06/2019 C-003260- UpsertAssessment to send back 'recommendedbyAS' information
                                                if ((!partList.RecommendedByAS__c) ){
                                                    genResults.writeStringField('ASChoice', '**');
                                                }
                                                else{
                                                    genResults.writeStringField('ASChoice', '');
                                                }


                                                //AMI 17/07/17 - Crash code handling (C-001969)
                                                if(partList.CrashCode__c != null){
                                                    genResults.writeNumberField('crashCode', integer.valueOf(partList.CrashCode__c));
                                                }

                                                //AMI 25/01/18 : C-002195 - Audatex Integration
                                                //                        - send updated values (nb working hours/unit)
                                                if(partList.NBHoursLabourPartLevel1__c != null && partList.NBHoursLabourPartLevel1__c > 0){
                                                    genResults.writeNumberField('NBHoursLabourPartLevel1', partList.NBHoursLabourPartLevel1__c);
                                                }

                                                if(partList.NBHoursLabourPartLevel2__c != null && partList.NBHoursLabourPartLevel2__c > 0){
                                                    genResults.writeNumberField('NBHoursLabourPartLevel2', partList.NBHoursLabourPartLevel2__c);
                                                }

                                                if(partList.NBHoursLabourPartLevel3__c != null && partList.NBHoursLabourPartLevel3__c > 0){
                                                    genResults.writeNumberField('NBHoursLabourPartLevel3', partList.NBHoursLabourPartLevel3__c);
                                                }

                                                if(mapTechOriginalPartKeyAudatexUnsavedFld.containsKey(partList.TECH_OriginalPart__c.toUpperCase())){
                                                    audatexUnSavedFields tempAudatexFLd = mapTechOriginalPartKeyAudatexUnsavedFld.get(partList.TECH_OriginalPart__c.toUpperCase());
                                                    
                                                    if(tempAudatexFLd.NBWorkingUnitLevel1 != null && tempAudatexFLd.NBWorkingUnitLevel1 > 0){
                                                        genResults.writeNumberField('NBWorkingUnitLevel1', tempAudatexFLd.NBWorkingUnitLevel1);
                                                    }

                                                    if(tempAudatexFLd.NBWorkingUnitLevel2 != null && tempAudatexFLd.NBWorkingUnitLevel2 > 0){
                                                        genResults.writeNumberField('NBWorkingUnitLevel2', tempAudatexFLd.NBWorkingUnitLevel2);
                                                    }

                                                    if(tempAudatexFLd.NBWorkingUnitLevel3 != null && tempAudatexFLd.NBWorkingUnitLevel3 > 0){
                                                        genResults.writeNumberField('NBWorkingUnitLevel3', tempAudatexFLd.NBWorkingUnitLevel3);
                                                    }
                                                }//end outer if

                                                //AMI 25/01/18 : C-002189 - Informex Integration
                                                //                        - send newly added info
                                                if(partList.Deducible__c != null && partList.Deducible__c > 0){
                                                    genResults.writeNumberField('Deducible', partList.Deducible__c);
                                                }

                                                if(partList.ObsoleteRatio__c != null && partList.ObsoleteRatio__c > 0){
                                                    genResults.writeNumberField('ObsoleteRatio', partList.ObsoleteRatio__c);
                                                }
                                            genResults.writeEndObject();
                                        }//end for
                                    }

                                // End Array Part
                                genResults.writeEndArray();

                                // write Object currentAsset
                                genResults.writeFieldName('currentAsset');
                                // Start Object currentAsset
                                genResults.writeStartObject();
                                    genResults.writeStringField('Brand', carBrandRes);


                                    if(assessMap.get(assessExtId).ModelV2__c != null){
                                        genResults.writeStringField('Model', assessMap.get(assessExtId).ModelV2__c);
                                    }
                                    
                                    if(assessMap.get(assessExtId).PlateNumber2__c != null){
                                        genResults.writeStringField('PlateNumber', assessMap.get(assessExtId).PlateNumber2__c);
                                    }

                                    if(assessMap.get(assessExtId).FirstRegistrationDate__c != null){
                                        genResults.writeDateField('FirstRegistrationDate', assessMap.get(assessExtId).FirstRegistrationDate__c);
                                    }
                                    
                                    if(assessMap.get(assessExtId).VINNumber__c != null){
                                        genResults.writeStringField('VINNumber', assessMap.get(assessExtId).VINNumber__c);
                                    }
                                // End Object currentAsset
                                genResults.writeEndObject();

                                // write Object currentBodyshop
                                genResults.writeFieldName('currentBodyshop');
                                // Start Object currentBodyshop
                                genResults.writeStartObject();
                                    //AccountRef__c accRef    = assessAccountRefMap.get(assessExtId.split(' - ')[0]);
                                    AccountRef__c accRef    = assessAccountRefMap.get(assessExtId);
                                    // ASE: 27/10/16: retrieve ReferenceNumber by splitting Name.
                                    //genResults.writeStringField('ReferenceNumber', accRef.ExternalReference__c);
                                    if (accRef != null){
                                        genResults.writeStringField('ReferenceNumber', accRef.Name.substringAfter('-'));
                                        } else {
                                            genResults.writeStringField('ReferenceNumber', '');
                                        }
                                    
                                    Account currentBodyShop = null;
                                    if (accRef != null){
                                        currentBodyShop = bsRefAccountMap.get(accRef.InternalReference__c);
                                    }
                                    
                                    if(currentBodyShop != null && currentBodyShop.ContactUser__c != null && currentBodyShop.ContactUser__r.Email != null){
                                        genResults.writeStringField('BodyShopEmail', currentBodyShop.ContactUser__r.Email);
                                    }
                                    else if(currentBodyShop != null && currentBodyShop.ContactEmail__c != null)
                                    {
                                        genResults.writeStringField('BodyShopEmail', currentBodyShop.ContactEmail__c);
                                    }else {
                                        genResults.writeStringField('BodyShopEmail', '');
                                    }
                                // End Object currentBodyshop
                                genResults.writeEndObject();

                                // write Object currentClaim
                                genResults.writeFieldName('currentClaim'); 
                                // Start Object currentClaim
                                genResults.writeStartObject();
                                    if(assessMap.get(assessExtId).ClaimReference__c != null){
                                        genResults.writeStringField('ClaimReference', assessMap.get(assessExtId).ClaimReference__c);
                                    }
                                    if(assessMap.get(assessExtId).CompanyName__c != null){
                                        genResults.writeStringField('CompanyName', assessMap.get(assessExtId).CompanyName__c);
                                    }
                                
                                    if(assessMap.get(assessExtId).DateOfIncident__c != null){
                                        genResults.writeDateField('DateOfIncident', assessMap.get(assessExtId).DateOfIncident__c);
                                    }
                                    
                                    //genResults.writeStringField('PolicyNumber', assessMap.get(assessExtId).PolicyNumber__c);
                                    genResults.writeBooleanField('RepairsAuthorised', assessMap.get(assessExtId).RepairsAuthorised__c);
                                    genResults.writeBooleanField('Fraud', assessMap.get(assessExtId).SupposedOfFraud__c);
                                    genResults.writeBooleanField('TotalLoss', assessMap.get(assessExtId).TotalLoss__c);
                                    genResults.writeBooleanField('Fleet', assessMap.get(assessExtId).Fleet__c);
                                    // genResults.writeBooleanField('Rental', assessMap.get(assessExtId).SpecialRenting__c);
                                    genResults.writeBooleanField('SpecialAgreement', assessMap.get(assessExtId).SpecialAgreement__c);

                                    if(assessMap.get(assessExtId).ExcessAmount__c != null){
                                        genResults.writeNumberField('ExcessAmount', assessMap.get(assessExtId).ExcessAmount__c);
                                    }

                                    //AMI 25/01/18 : C-002195 - Audatex Integration
                                    //                        - send NBWrkingUnit/externalid/version number transmitted
                                    if(string.isNotBlank(NBWrkingUnit)){
                                        genResults.writeNumberField('NBWrkingUnit', integer.valueOf(NBWrkingUnit));
                                    }

                                    if(string.isNotBlank(assessMap.get(assessExtId).AssessmentExternalId__c)){
                                        genResults.writeStringField('AssessmentExternalID', assessMap.get(assessExtId).AssessmentExternalId__c);
                                    }

                                    if(assessMap.get(assessExtId).AssessmentVersion__c != null){
                                        genResults.writeNumberField('AssessmentVersion', integer.valueOf(assessMap.get(assessExtId).AssessmentVersion__c));
                                    }

                                    //AMI 25/01/18 : C-002189 - Informex Integration
                                    //                        - send newly added info
                                    if(assessMap.get(assessExtId).TotalObsoleteRatio__c != null){
                                        genResults.writeNumberField('TotalObsoleteRatio', assessMap.get(assessExtId).TotalObsoleteRatio__c);
                                    }

                                    if(assessMap.get(assessExtId).VATPortionPayable__c != null){
                                        genResults.writeNumberField('VAT', assessMap.get(assessExtId).VATPortionPayable__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalDeducible__c != null){
                                        genResults.writeNumberField('Deducible', assessMap.get(assessExtId).TotalDeducible__c);
                                    }

                                    if(isNevada){
                                        genResults.writeBooleanField('Rental', assessMap.get(assessExtId).SpecialRenting__c);

                                        if(assessMap.get(assessExtId).QuotationAmtExlVAT__c != null){
                                            genResults.writeNumberField('QuotationAmountExlVAT', assessMap.get(assessExtId).QuotationAmtExlVAT__c);
                                        }

                                        if(assessMap.get(assessExtId).QuotationAmountInclVAT__c != null){
                                            genResults.writeNumberField('QuotationAmountInclVAT', assessMap.get(assessExtId).QuotationAmountInclVAT__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtLabourPainting__c != null){
                                            genResults.writeNumberField('TotalAmtLabourPainting', assessMap.get(assessExtId).TotalAmtLabourPainting__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtLabour__c != null){
                                            genResults.writeNumberField('TotalAmtLabour', assessMap.get(assessExtId).TotalAmtLabour__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtParts__c != null){
                                            genResults.writeNumberField('TotalAmtParts', assessMap.get(assessExtId).TotalAmtParts__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtPainting__c != null){
                                            genResults.writeNumberField('TotalAmtPainting', assessMap.get(assessExtId).TotalAmtPainting__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtExlVAT__c != null){
                                            genResults.writeNumberField('TotalAmtExlVAT', assessMap.get(assessExtId).TotalAmtExlVAT__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalVAT__c != null){
                                            genResults.writeNumberField('TotalVAT', assessMap.get(assessExtId).TotalVAT__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtInclVAT__c != null){
                                            genResults.writeNumberField('TotalAmtInclVAT', assessMap.get(assessExtId).TotalAmtInclVAT__c);
                                        }

                                        //RLA 16/08/2021 C-004408: PostNevada sends duplicate fields
                                        // if(assessMap.get(assessExtId).TotalAmtExlVAT__c != null){
                                        //     genResults.writeNumberField('TotalAmtExlVAT', assessMap.get(assessExtId).TotalAmtExlVAT__c);
                                        // }

                                        if(assessMap.get(assessExtId).NBHoursLabour__c != null){
                                            genResults.writeNumberField('NBHoursLabour', assessMap.get(assessExtId).NBHoursLabour__c);
                                        }

                                        if(assessMap.get(assessExtId).NBHoursLabourLevel1__c != null){
                                            genResults.writeNumberField('NBHoursLabourLevel1', assessMap.get(assessExtId).NBHoursLabourLevel1__c);
                                        }

                                        if(assessMap.get(assessExtId).NBHoursLabourLevel2__c != null){
                                            genResults.writeNumberField('NBHoursLabourLevel2', assessMap.get(assessExtId).NBHoursLabourLevel2__c);
                                        }

                                        if(assessMap.get(assessExtId).NBHoursLabourLevel3__c != null){
                                            genResults.writeNumberField('NBHoursLabourLevel3', assessMap.get(assessExtId).NBHoursLabourLevel3__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtLabourExlPainting__c != null){
                                            genResults.writeNumberField('TotalAmtLabourExlPainting', assessMap.get(assessExtId).TotalAmtLabourExlPainting__c);
                                        }

                                        if(assessMap.get(assessExtId).NBHoursLabourPainting__c != null){
                                            genResults.writeNumberField('NBHoursLabourPainting', assessMap.get(assessExtId).NBHoursLabourPainting__c);
                                        }

                                        if(assessMap.get(assessExtId).TotalAmtPaintingInclLabour__c != null){
                                            genResults.writeNumberField('TotalAmtPaintingInclLabour', assessMap.get(assessExtId).TotalAmtPaintingInclLabour__c);
                                        }

                                        if(assessMap.get(assessExtId).AmtOthers__c != null){
                                            genResults.writeNumberField('AmtOthers', assessMap.get(assessExtId).AmtOthers__c);
                                        }
                                    }
                                    
                                // End Object currentClaim
                                genResults.writeEndObject();

                            // End Object Assessment
                            genResults.writeEndObject();
                        }
                    }
                }
                
                //AMI 06/07/2017 - Adding warning message exception handling
                if(mapWarningCreation.size() > 0 &&!isNevada){  //NPE 06/04/2022: C-004683 Call to Nevada fall in Mulesoft
                    for(String suc : mapWarningCreation.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'Insert');
                            genResults.writeNullField('TechnicalId');
                            genResults.writeStringField('FunctionalId', suc);
                            genResults.writeBooleanField('Success', true);
                            genResults.writeStringField('Warning', 'Exceptions: ' + mapWarningCreation.get(suc));
                            genResults.writeNullField('ErrorMessage');
                        genResults.writeEndObject();
                    }
                }

                if(mapErrorsCreation.size() > 0){
                    for(String suc : mapErrorsCreation.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'Insert');
                            genResults.writeNullField('TechnicalId');
                            genResults.writeStringField('FunctionalId', suc);
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            genResults.writeStringField('ErrorMessage', 'Exceptions: ' + mapErrorsCreation.get(suc));
                        genResults.writeEndObject();
                    }
                }

                if(shoppingListExistAssessMap.size() > 0){
                    for(String key : shoppingListExistAssessMap.keySet()){
                        if(!shoppingListExistAssessFound.contains(key)){
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'Upsert');
                                genResults.writeNullField('TechnicalId');
                                genResults.writeStringField('FunctionalId', key);
                                genResults.writeBooleanField('Success', false);
                                genResults.writeNullField('Warning');
                                genResults.writeStringField('ErrorMessage', 'Exceptions: Assessment not found in system.'); 
                            genResults.writeEndObject();
                        }
                    }
                }

            // End array of Assessment
            genResults.writeEndArray();
            if(isNevada){
                genResults.writeEndObject();
            }
            
            if(assessSFDCIDMap != null){
                    for(String assessExtId : assessSFDCIDMap.keySet()){
                        if(assessMap.containsKey(assessExtId)){
                                    if (assessMap.get(assessExtId).Entity__c == '299'){
                                        response = '';
                                    }
                                }
                    }
            }
            response = genResults.getAsString();
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV2 - generateResponse ----------------------------------');
        return response;
    } 

    //C-001825
    public static void callRESTPostAssessment(Map<String, Assessment__c> assessMap){
       System.debug('---------------------------------- START RESTUpsertAssessmentV2 - callRESTPostAssessment -------------------------------');
       system.debug('## start postAssesssmentIdSet: ');

       Set<Id> postAssesssmentIdSet    = new Set<Id>();
       for(String assessID : assessSFDCIDMap.keyset()){
           if(assessMap.containsKey(assessID)){
               Assessment__c assessment = assessMap.get(assessID);
               //if(!assessment.isShoppingList__c && igEntitySet.contains(assessment.TECH_EntityCountryCode__c+assessment.EntityCode__c)){
               if(igEntitySet.contains(assessment.TECH_EntityCountryCode__c+assessment.EntityCode__c)){
                   if(assessment.RecordTypeId == recordTypeAssessTypeMap.get('Claim')){
                       system.debug('## Claim Id:'+assessment.Id);
                       postAssesssmentIdSet.add(assessment.Id);
                   }                       
               }
           }
       }
       system.debug('## end postAssesssmentIdSet: ');
       if(postAssesssmentIdSet.size() > 0 && !isFromR3){
           RESTPostAssessment.buildJSONAsyncForRestUpsert(postAssesssmentIdSet, true);
       }
        
       System.debug('---------------------------------- END RESTUpsertAssessmentV2 - callRESTPostAssessment -------------------------------');
    }

    //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
    public static void updatePartsKey(List<Map<String, Object>> lstProcessedAssObj){
        system.debug('## Start updatePartsKey');

        map <string,string> mapOldExtIdNewExtId  = new map <string,string>();
        string oldKey,newKey,subNewKey           = '';
        list <PartList__c> partsToBeUpdated      = new list <PartList__c>();
        map <string,string> mapOriOldKeyAssId    = new map <string,string>();
        map <string,string> mapOriOldKeyExtId    = new map <string,string>();

        //build mapOldExtIdNewExtId
        for(map <string,object> assessement : lstProcessedAssObj){
            for(object partList : (list <object>) assessement.get('Parts')){

                map <string, object> partListMap = (map <string, object>) partList;

                oldKey                           = '';
                newKey                           = '';
                string newExtId                  = String.ValueOf(partListMap.get('ExternalID'));
                //process only parts having externalid
                if(string.isNotBlank(newExtId)){

                    //build old key
                    string callerSystem          = (string.valueOf(assessement.get('callerSystem'))).toUpperCase();
                    String cleanseCallerSystem   = (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;
                    string assessNum             = (assessement.get('AssessmentNumber') != null) ? string.valueOf(assessement.get('AssessmentNumber')) : null;
                    string receivedCrashCode     = (assessement.get('crashCode') != null) ? string.valueOf( assessement.get('crashCode')) : null;
                    string crashCode             = (receivedCrashCode != null && receivedCrashCode.trim().length() == 1) ? ('0' + receivedCrashCode) : receivedCrashCode;
                    
                    //AMI 04/10/17 : Catering for crash code on parts
                    string crashCodePart         = string.ValueOf(partListMap.get('crashCode'));

                    string assessmentID          = '';

                    if(!string.isBlank(crashCodePart)){
                        assessmentID             = (cleanseCallerSystem + assessNum + '(' + ((crashCodePart.length() == 1) ? ('0' + crashCodePart) : crashCodePart) + ')').toUpperCase(); 
                    }else{
                        assessmentID             = (cleanseCallerSystem + assessNum + crashCode).toUpperCase(); 
                    }
                     
                    string partNumber            = string.valueOf(partListMap.get('PartNumber'));
                    string partDescription       = string.valueOf(partListMap.get('PartLabel'));
                    string partLabel             = partDescription.left(80);
                    string alphaScaleMRID        = (partListMap.get('AlphaScaleMRID') != null) ? String.valueOf(partListMap.get('AlphaScaleMRID')) : '';
                    string manufacturer          = string.ValueOf(partListMap.get('Manufacturer'));

                    //original
                    if(string.isBlank(alphaScaleMRID)){
                        oldKey                   = null + '-' 
                                                 + partNumber + '-' 
                                                 + partLabel.replaceAll('\\s+', '') + '-' 
                                                 + manufacturer + '-' 
                                                 + assessmentID + '-' 
                                                 + null;

                        //AMI 04/10/17 : assessmentID reconstructed since we cannot take into account old crash code since key in new system
                        //               will always contain null for crashcode
                        newKey                   = (cleanseCallerSystem + assessNum + 'null').toUpperCase() + '-' + newExtId;

                    }

                    //add to map
                    if(string.isNotBlank(oldKey) && string.isNotBlank(newKey)){
                        mapOldExtIdNewExtId.put(oldKey.toUpperCase(),newKey);
                        mapOriOldKeyAssId.put(oldKey.toUpperCase(),assessmentID);
                        mapOriOldKeyExtId.put(oldKey.toUpperCase(),newExtId);
                    }
                }//end if if(string.isNotBlank(newExtId)){
            }//end looping in parts transmitted
        }//end looping in assessment


        //query all parts having old externalid
        for(PartList__c pl : [select id,TECH_OriginalPart__c,OriginalPart__c,PartNumber__c,OriginalPart__r.TECH_OriginalPart__c
                                from PartList__c
                                where TECH_OriginalPart__c IN :mapOldExtIdNewExtId.keySet()
                                or OriginalPart__r.TECH_OriginalPart__c IN :mapOldExtIdNewExtId.keySet()]){
         
            subNewKey                           = '';

            //substitute parts
            if(pl.OriginalPart__c != null){ 
                //build old key for subs
                subNewKey                       = mapOriOldKeyAssId.get(pl.OriginalPart__r.TECH_OriginalPart__c) + '-' + 
                                                  mapOriOldKeyExtId.get(pl.OriginalPart__r.TECH_OriginalPart__c) + '-' + pl.PartNumber__c;

                subNewKey                       = subNewKey.replaceAll('\\([0-9]+\\)', 'NULL');

                partsToBeUpdated.add(new PartList__c(id = pl.id,TECH_OriginalPart__c = subNewKey));
            }else{
                //original parts
                partsToBeUpdated.add(new PartList__c(id = pl.id,TECH_OriginalPart__c = mapOldExtIdNewExtId.get(pl.TECH_OriginalPart__c)));
            }
        }//end looping in partlist

       
        if(!partsToBeUpdated.isEmpty()){
            update partsToBeUpdated;
        }

        system.debug('## End updatePartsKey'); 
    }

    //  ASE: 17/11/17 C-002078
    public static String processICEAssessment (map<String, Assessment__c> ICEAssessmentMap, map<String, String> ICEAssessErrorMap,map <string,integer> mapAssIdPositionNumber){
        system.debug('## processICEAssessment START');

        String results = '';

        map<String, String> ICEAssessSuccessMap = new map<String, String>();   

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : list that will contain assessment to update
        list <Assessment__c> assessmentToUpdate = new list <Assessment__c>();

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : set used to check against transmitted assessment id to raise error is latter not present
        set <string> setExistingAssId = new set <string>();

        if(ICEAssessmentMap.size() > 0){
            //WCH 26/11/2020 C-003980
            List<ConfigurationFlux__mdt> getProperIceCompensationConfigs = [select id,Runnable__c from ConfigurationFlux__mdt where DeveloperName='ICE_Compensation'];

            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : Query Assesement based on assessment ID
            for(Assessment__c ass : [select AssessmentID__c, CompensatedWSDate__c,TECH_EntityCountryCode__c
                                        from Assessment__c
                                        where AssessmentID__c IN :ICEAssessmentMap.Keyset()]){
                //WCH 26/11/2020 C-003980
                if((String.isNotBlank(ass.TECH_EntityCountryCode__c) && mapConfigCountryCodeInfo.containsKey(ass.TECH_EntityCountryCode__c) && mapConfigCountryCodeInfo.get(ass.TECH_EntityCountryCode__c).New_Compensation_Activate__c) || (getProperIceCompensationConfigs.size()>0 && !getProperIceCompensationConfigs[0].Runnable__c)){
                    assessmentToUpdate.add(new Assessment__c(AssessmentID__c = ass.AssessmentID__c,
                                                         CompensatedWSDate__c = DateTime.now()));
                }else{
                    assessmentToUpdate.add(new Assessment__c(AssessmentID__c = ass.AssessmentID__c, 
                                                         Compensated__c = ICEAssessmentMap.get(ass.AssessmentID__c).Compensated__c,
                                                         CompensatedWSDate__c = DateTime.now()));
                }
                setExistingAssId.add(ass.AssessmentID__c);
            }//end looping in assessment


            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : Check against existing assessment
            //             : if not present raise an error
            for(string assid : ICEAssessmentMap.Keyset()){
                if(!setExistingAssId.contains(assid)){
                    ICEAssessErrorMap.put('Assessment ['+ mapAssIdPositionNumber.get(assid) + ']', 'Assessment ['+ mapAssIdPositionNumber.get(assid) + '] not processed.  No AssessmentNumber or Compensated found.' );
                }
            }

            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : updating list to update
            //upsert assessments
            Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;
            List<Database.upsertResult> uResults = Database.upsert(assessmentToUpdate, assessExtId, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(uResults[idx].isSuccess()) {
                    // if success populate the Set of id that has been successful
                    ICEAssessSuccessMap.put(assessmentToUpdate[idx].AssessmentId__c, uResults[idx].getId() );                          
                }
                else {
                    //generate the json that will be used for errors as reponse
                    for(Database.Error err : uResults[idx].getErrors()){
                        ICEAssessErrorMap.put(assessmentToUpdate[idx].AssessmentId__c, Label.Error + ': ' + err.getMessage());                                           
                    }             
                }
            }
        }

        system.debug('## ICEAssessSuccessMap:'+ICEAssessSuccessMap);  
        system.debug('## ICEAssessErrorMap:'+ICEAssessErrorMap);  

        if(ICEAssessSuccessMap.size() > 0 || ICEAssessErrorMap.size() > 0){
            JSONGenerator genResults = JSON.createGenerator(false);

            genResults.writeStartArray();
                if(ICEAssessSuccessMap.size() > 0){
                    for(String suc : ICEAssessSuccessMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', ICEAssessSuccessMap.get(suc));
                            genResults.writeStringField('FunctionalId', suc);                            
                            genResults.writeBooleanField('Success', true);
                            genResults.writeNullField('Warning');
                            genResults.writeNullField('ErrorMessage'); 
                        genResults.writeEndObject();
                    }
                }               

                if (ICEAssessErrorMap.size()> 0){
                    for(String err : ICEAssessErrorMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', '');
                            genResults.writeStringField('FunctionalId', err);
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            genResults.writeStringField('ErrorMessage','Exception:' + ICEAssessErrorMap.get(err));                        
                        genResults.writeEndObject();
                    }   
                }
            genResults.writeEndArray();
            
            results = genResults.getAsString();
            system.debug('## results' + results);              
        }

        system.debug('## processICEAssessment END'); 
        return results;       
    } 

    //AMI 25/01/18 : C-002195 - Audatex Integration
    //                        - wrapper to store values send in json request which is not saved in database so that
    //                        - same can be returned in response json
    public class audatexUnSavedFields{
        public decimal NBWorkingUnitLevel1;
        public decimal NBWorkingUnitLevel2;
        public decimal NBWorkingUnitLevel3;

        public audatexUnSavedFields(decimal NBWorkingUnitLevel1,decimal NBWorkingUnitLevel2,decimal NBWorkingUnitLevel3){
            this.NBWorkingUnitLevel1 = NBWorkingUnitLevel1;
            this.NBWorkingUnitLevel2 = NBWorkingUnitLevel2;
            this.NBWorkingUnitLevel3 = NBWorkingUnitLevel3; 
        }
    }
    //RLA 06/09/2018 C-002692 : Substitution on BE assessments
    public static Map<String, String> getMapTranslatedCertOrg(){
        string nLOrigin = system.label.ORIGINENL;
        map<string,string> mapOrigineValues = new map<String, String>();

        if (String.isNotBlank(nLOrigin)){
            List<String> listTranslatedPaired = nLOrigin.split(';');
            if (listTranslatedPaired.size() > 0){
                for (string translatedPairs: listTranslatedPaired){
                    
                    if (String.isNotBlank(translatedPairs)){
                        List<String> translatedUnPaired = translatedPairs.split(':');
                        if (translatedUnPaired.size() == 2){
                            mapOrigineValues.put(translatedUnPaired[0].deleteWhitespace(), translatedUnPaired[1].deleteWhitespace());
                        }               
                    }
                }
            }
        }

        if (mapOrigineValues != null){
            return mapOrigineValues;
        }
        else{
            return null;
        }
    }
    //04-JUN-2019 RLA  C-003143 : Preseletion de la pièce E pour la France 
    //20-JUN-2021 RLA  C-004275 : FR - E parts Substitution Change Request
    public static String selectionE ( map <string,List <PartList__c>> mapOriginalTechOriginalPartSetSubsTechOriginalPart,
                                      String originalKey, String customLabelToTake ){
        System.debug('---------------------------------- START ASPISServiceSubstitution - selectionE ----------------------------------');

        System.debug('### mapOriginalTechOriginalPartSetSubsTechOriginalPart: '+mapOriginalTechOriginalPartSetSubsTechOriginalPart);
        //System.debug('### mapOriginalDistributorPartSetSubsPartEs: '+mapOriginalTechOriginalPartSetSubsTechOriginalPart);
        System.debug('### originalKey: '+originalKey);

        Map<String, Decimal> mapASCRDistributorPercentage = new map<String, Decimal>();
        Map<String, String> mapTechOriginalPartAndPartNumberASCR = new map<String, String>();
        Map<String, List<PartList__c>> mapDistributorPartlist = new map<String, List<PartList__c>>();
        List<String> lstASCRKeys = new list<String>();
        String strofAscrForEParts = '{';

        if (mapOriginalTechOriginalPartSetSubsTechOriginalPart.containskey(originalKey)){

            For (PartList__c part: mapOriginalTechOriginalPartSetSubsTechOriginalPart.get(originalKey)){

                if (mapTechOriOemManu.containskey(part.TECH_OriginalPart__c)){
                    if (mapDistributorPartlist.containskey(mapTechOriOemManu.get(part.TECH_OriginalPart__c))){
                        mapDistributorPartlist.get(mapTechOriOemManu.get(part.TECH_OriginalPart__c)).add(part);
                    }
                    else{
                        mapDistributorPartlist.put(mapTechOriOemManu.get(part.TECH_OriginalPart__c), new list<PartList__c>{part});   
                    }
                }
                mapTechOriginalPartAndPartNumberASCR.put(part.TECH_OriginalPart__c, part.PartNumber__c);
                //OEMPartNumber = part.OriginalPart__r;
                //System.debug('### part.OriginalPart__r: '+part.OriginalPart__r);

                //mapDistributorASCRKey.put(part.Distributor__c, part.TECH_OriginalPart__c);
                //mapDistributorPartNumber.put(part.Distributor__c, part.PartNumber__c);
            }
            System.debug('### mapDistributorPartlist: '+mapDistributorPartlist);
            System.debug('### mapTechOriginalPartAndPartNumberASCR: '+mapTechOriginalPartAndPartNumberASCR);

           if (String.isNotBlank(customLabelToTake)){
                For (String str: customLabelToTake.split(';')){
                    List<String> manuAndPercent = str.split(':');    
                     
                    if (manuAndPercent.size() > 1){ 
                        String manufacturer =  manuAndPercent[0]; 
                        String percentageDistri =  manuAndPercent[1]; 

                        if (String.isNotBlank(manufacturer) && String.isNotBlank(percentageDistri) ){
                            if (mapDistributorPartlist.containsKey(manufacturer)){
                                for ( PartList__c part: mapDistributorPartlist.get(manufacturer)){
                                    mapASCRDistributorPercentage.put(part.TECH_OriginalPart__c,(integer.valueof(percentageDistri)) );  
                                }  
                            }
                        }
                    }
                }

            }

            System.debug('### mapASCRDistributorPercentage: '+mapASCRDistributorPercentage);

            if (mapASCRDistributorPercentage.size() > 0){
                
                for (String ASCRKey: mapASCRDistributorPercentage.keySet()){
                    for (Integer j=0; j<mapASCRDistributorPercentage.get(ASCRKey); j++ ){
                        // System.debug('### j'+ j);
                        lstASCRKeys.add(ASCRKey);
                        

                    }
                }

                //}
                // System.debug('### lstASCRKeys: '+lstASCRKeys);
                // System.debug('### lstASCRKeys: '+lstASCRKeys.size());
                lstASCRKeys = randomizeList(lstASCRKeys);
                for (String ASCRKey: lstASCRKeys){
                    if (mapTechOriginalPartAndPartNumberASCR.containskey(ASCRKey)){

                        strofAscrForEParts += mapTechOriginalPartAndPartNumberASCR.get(ASCRKey)+';';
                        
                    }    
                }
                // System.debug('### lstASCRKeys after: '+lstASCRKeys);
                // System.debug('### strofAscrForEParts after: '+strofAscrForEParts);
                Double randomNumber = Math.random();
                // System.debug('### randomNumber: '+randomNumber);

                Integer arrayLength = lstASCRKeys.size();
                Integer randomIndex = (randomNumber *(arrayLength-1)).intValue();
                // System.debug('randomIndex: '+randomIndex);
                strofAscrForEParts += '}!RandomNumber:'+(randomIndex+1);
                // System.debug('### strofAscrForEParts after: '+strofAscrForEParts);

                mapOEMASCRSE.put(originalKey,strofAscrForEParts.left(130000) );

                //Output the element at the list index generated above
                // System.debug('Random element: '+lstASCRKeys[randomIndex]); 
                return lstASCRKeys[randomIndex];
            }
            else{
                return null;
            }



        }

        System.debug('---------------------------------- END ASPISServiceSubstitution - selectionE ----------------------------------');

        return null;



    }

    public static list<String> randomizeList (List<String> lstString){
        integer currentIndex = lstString.size();
        String temporaryValue;
        integer randomIndex;
        // While there remain elements to shuffle...
        while (0 != currentIndex) {
            // Pick a remaining element...
            randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
            currentIndex -= 1;
            // And swap it with the current element.
            temporaryValue = lstString[currentIndex];
            lstString[currentIndex] = lstString[randomIndex];
            lstString[randomIndex] = temporaryValue;
        }

        return lstString;
    }

    //     return mapPartTypesStatusAllowed;
    // }
    //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
    public static Map<String,List<String>> splitForPartTypesStatus(String xrefName){
        // String s = 'B:CONFIRMED;CONFIRMEDWITHDELAY-C:PARTIAL-D:CANCELED';
        Map<String,List<String>> mapPartTypesStatusAllowedInt = new map<String, List<String>>();
         String techDisName = mapXrefNameTechDis.containskey(xrefName) ? mapXrefNameTechDis.get(xrefName) : '';
        // system.debug('@@@ techDisName 4482: '+techDisName);
        // system.debug('@@@ xrefName 4482: '+xrefName);
        // system.debug('@@@ mapXrefNameTechDis 4482: '+mapXrefNameTechDis);

        if (String.isNotBlank(techDisName)){
            if (mapDistPartTypesStatusAllowed.containsKey(techDisName)){
                // system.debug('@@@ contains techdis 4482: '+xrefName);

                mapPartTypesStatusAllowedInt = mapDistPartTypesStatusAllowed.get(techDisName);
            }
        }

        system.debug('@@@ mapPartTypesStatusAllowedInt: '+mapPartTypesStatusAllowedInt);

        return mapPartTypesStatusAllowedInt;
    }

   

    //RLA C-004482 : ANIEL C parts with status NOT FOUND should not be proposed
    public static Map<String,Map<String,List<String>>> splitForBPartTypesStatusPerDist(String typesStatus, String techDis){
        // String s = 'B:CONFIRMED;CONFIRMEDWITHDELAY-C:PARTIAL-D:CANCELED';

        List<String> lstTypesStatus = typesStatus.Split('-');
        Map<String,List<String>> mapPartTypesStatusAllowed = new map<String, List<String>>();
        system.debug('@@@ lstTypesStatus : '+lstTypesStatus );

        for (String str: lstTypesStatus ){
            list<String> lstStr = str.split(':');
            for (integer i = 1; i<lstStr.size(); i++){
                list<String> listString = lstStr[i].split(';');
                mapPartTypesStatusAllowed.put(lstStr[0], listString );
            }   
        }
        system.debug('@@@ mapPartTypesStatusAllowed: '+mapPartTypesStatusAllowed);
        mapDistPartTypesStatusAllowed.put(techDis,mapPartTypesStatusAllowed );

        return mapDistPartTypesStatusAllowed;
    }

    //RLA 13/01/2020 C-003492: SAS B parts with status PARTIAL should not be proposed 
    // public static Map<String,List<String>> splitForBPartTypesStatus(String typesStatus){
    //     // String s = 'B:CONFIRMED;CONFIRMEDWITHDELAY-C:PARTIAL-D:CANCELED';

    //     List<String> lstTypesStatus = typesStatus.Split('-');
    //     Map<String,List<String>> mapPartTypesStatusAllowed = new map<String, List<String>>();
    //     system.debug('@@@ lstTypesStatus : '+lstTypesStatus );

    //     for (String str: lstTypesStatus ){
    //         list<String> lstStr = str.split(':');
    //         for (integer i = 1; i<lstStr.size(); i++){
    //             list<String> listString = lstStr[i].split(';');
    //             mapPartTypesStatusAllowed.put(lstStr[0], listString );
    //         }   
    //     }
    //     system.debug('@@@ mapPartTypesStatusAllowed: '+mapPartTypesStatusAllowed);

    //     return mapPartTypesStatusAllowed;
    // }

    //RLA 28/01/2020 C-003524 : Change Recommended part in France  
    public static integer rankingOfPartlists(String PartType){

        system.debug('@@ PartType: '+PartType);
        if (mapPartTypePriority.containskey(PartType )){
            system.debug('@@ mapPartTypePriority.get(PartType): '+mapPartTypePriority.get(PartType));
            return mapPartTypePriority.get(PartType);

        }
        else{
            system.debug('@@ mapPartTypePriority.get(PartType): '+null);

            return 1000;
        }

    }

    //RLA 26/02/2020 Citroen Brand update
    public static String modifyBrandCitroen (String brand){
        system.debug('@@@ modifyBrandCitroen brand:'+brand);

        if (brand == 'CITROËN' || brand == 'Citroën' ){
            system.debug('@@ return CITROEN');
            return 'CITROEN';
        }
        else {
            system.debug('@@ return brand'+brand);
            return brand;
        }
    }

     //RLA 28/02/2020 C-003524 : Change Recommended part in France  
    // public static map<Integer,list <PartList__c>> rankingOfParts(List<PartList__c> lstParts){
    //     //map which contains the partType and its priority derived from masterRule
    //     // map<String,Integer> mapPartTypePriority = new map<String,Integer>{'A'=> 1, 'B'=> 1,'C'=> 3,'E'=> 2,'D' => 3};
    //     //map which contains prioritised partlists

    //     map<Integer,list <PartList__c>> mapPriotisedParts  = new map<Integer, list<PartList__c>>();
    //     for (integer i=0; i<20; i++){
    //         mapPriotisedParts.put(i, new list<PartList__c>()); 
    //     }

    //     //loop in partlists
    //     FOR (PartList__c part: lstParts ){
            
    //         if (mapPartTypePriority.containskey(part.Type__c )){
    //             //Add partType to map according to its priority
    //             if (mapPriotisedParts.containskey(mapPartTypePriority.get(part.Type__c))){
    //                 mapPriotisedParts.get(mapPartTypePriority.get(part.Type__c)).add(part);
    //             }
    //             else{
    //                 mapPriotisedParts.put(mapPartTypePriority.get(part.Type__c), new list<PartList__c>{part});
    //             }            
    //         }
    //     }//endfor

    //     system.debug('@@ mapPriotisedXrefs: '+mapPriotisedParts);
    //     return mapPriotisedParts;
    // }
    
   //HRM 12/10/2021 C-004405 : No Ordering on Fake References
    public static Set<String> getFakeReferences (String Country){
        Set<String> setFakeReferencesIn = new set <string>();
        if (mapConfigCountryCodeInfo.containsKey(country) && String.isNotBlank(mapConfigCountryCodeInfo.get(country).LogsForFakeReferences__c)){
            Set<String> setFakeReferencesLogNames = new set <string>(new list <string>(mapConfigCountryCodeInfo.get(country).LogsForFakeReferences__c.split(';') ));
            
            system.debug('## setFakeReferencesLogNames:'+setFakeReferencesLogNames);
            for (Log__c log : [SELECT JSONMessage__c FROM Log__c WHERE Name IN :setFakeReferencesLogNames]) {
                if(String.isNotBlank(log.JSONMessage__c))
                {
                    setFakeReferencesIn.addAll(new list <string>(log.JSONMessage__c.split(';')));
                }
            }
        }
        return setFakeReferencesIn;
    }
    

    //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment


    public class Assesment {

        public string callerSystem;
        public string Entity;
        public string EntityCode;
        public Decimal VINCheck;
        public Boolean isShoppingList;
        public Claim currentClaim;
        public Asset currentAsset;
        public BodyShop currentBodyShop;
        public List<Part> Parts;
        public Boolean isFromR3;
        public String assessmentR3; //NPE 14/12/2021: C-004540

        public Assesment(string callerSystem, string Entity, string EntityCode, Decimal VINCheck, Boolean isShoppingList, Claim currentClaim, Asset currentAsset, BodyShop currentBodyShop, List<Part> Parts, Boolean isFromR3, String assessmentR3){ //NPE 14/12/2021: C-004540
            this.callerSystem = callerSystem;
            this.Entity  = Entity;
            this.EntityCode  = EntityCode;
            this.VINCheck  = VINCheck;
            this.isShoppingList  = isShoppingList;
            this.currentClaim = currentClaim;
            this.currentAsset  = currentAsset;
            this.currentBodyShop  = currentBodyShop;
            this.Parts  = Parts;
            this.isFromR3 = isFromR3;
            this.assessmentR3 = assessmentR3; //NPE 14/12/2021: C-004540
        }
    }

    public class BodyShop
    {
        public String ReferenceNumber;

        public BodyShop(string ReferenceNumber){
            this.ReferenceNumber = ReferenceNumber;           
        }
    }

    public class Claim
    {
        public Decimal TotalAmtParts;
        public Decimal TotalAmtLabour;
        public Decimal TotalAmtLabourPainting;
        public Decimal TotalAmtLabourExlPainting;
        public Decimal TotalAmtPainting;
        public Decimal TotalAmtPaintingInclLabour;
        public Decimal AmtOthers;
        public Decimal TotalAmtExlVAT;
        public Decimal TotalVAT;
        public Decimal TotalAmtInclVAT;
        public Decimal QuotationAmountExlVAT;
        public Decimal QuotationAmountInclVAT;
        public Decimal NBHoursLabour;
        public Decimal NBHoursLabourLevel1;
        public Decimal NBHoursLabourLevel2;
        public Decimal NBHoursLabourLevel3;
        public Decimal NBHoursLabourPainting;      
        public String ClaimReference;
        public String CompanyName;
        public Date DateOfIncident;


        public Claim(Decimal TotalAmtParts, Decimal TotalAmtLabour, Decimal TotalAmtLabourPainting, Decimal TotalAmtLabourExlPainting, Decimal TotalAmtPainting, Decimal TotalAmtPaintingInclLabour, Decimal AmtOthers, Decimal TotalAmtExlVAT, Decimal TotalVAT, Decimal TotalAmtInclVAT, Decimal QuotationAmountExlVAT, Decimal NBHoursLabour, Decimal NBHoursLabourLevel1,  Decimal NBHoursLabourLevel2, Decimal NBHoursLabourLevel3, Decimal NBHoursLabourPainting, String ClaimReference, String CompanyName, Date DateOfIncident ){
            this.TotalAmtParts = TotalAmtParts;
            this.TotalAmtLabour  = TotalAmtLabour;
            this.TotalAmtLabourPainting  = TotalAmtLabourPainting;
            this.TotalAmtLabourExlPainting  = TotalAmtLabourExlPainting;
            this.TotalAmtPainting = TotalAmtPainting;
            this.TotalAmtPaintingInclLabour  = TotalAmtPaintingInclLabour;
            this.AmtOthers  = AmtOthers;
            this.TotalAmtExlVAT  = TotalAmtExlVAT;
            this.TotalVAT = TotalVAT;
            this.TotalAmtInclVAT  = TotalAmtInclVAT;
            this.QuotationAmountExlVAT  = QuotationAmountExlVAT;
            this.NBHoursLabour  = NBHoursLabour;
            this.NBHoursLabourLevel1 = NBHoursLabourLevel1;
            this.NBHoursLabourLevel2  = NBHoursLabourLevel2;
            this.NBHoursLabourLevel3  = NBHoursLabourLevel3;
            this.NBHoursLabourPainting  = NBHoursLabourPainting;
            this.ClaimReference  = ClaimReference;
            this.CompanyName = CompanyName;
            this.DateOfIncident = DateOfIncident;
        }
     
    }

    public class Asset
    {
        public String Colour;
        public Date FirstRegistrationDate;
        public String Brand;
        public String Model;
        public String PlateNumber;
        public String VINNumber;
        public String Manufacturer;
        public String KMS;
        public String PaintingType;
        public String Energy;
        public String VDSCode;   
        public Date BuildDate;


        public Asset(string Colour, Date FirstRegistrationDate, string Brand, String Model, String PlateNumber, String VINNumber, String KMS, string PaintingType, String Energy, String VDSCode, Date BuildDate){
            this.Colour = Colour;
            this.FirstRegistrationDate  = FirstRegistrationDate;
            this.Brand  = Brand;
            this.Model  = Model;
            this.PlateNumber = PlateNumber;
            this.VINNumber  = VINNumber;
            //this.Manufacturer  = Manufacturer;
            this.KMS  = KMS;
            this.PaintingType  = PaintingType;
            this.Energy  = Energy;
            this.VDSCode  = VDSCode;
            this.BuildDate = BuildDate;
        }    

    }

    public class Part
    {
        public String PartLabel;
        public String PartNumber;
        public Decimal Price;
        // public String Currency;
        public Decimal Quantity;
        public String RecordType;
        public String Status;
        public String InputType;        
        public Boolean Compliance;

        public Part(string PartLabel, String PartNumber, Decimal Price, Decimal Quantity, String RecordType, String Status, String InputType, Boolean Compliance){
            this.PartLabel = PartLabel;
            this.PartNumber  = PartNumber;
            this.Price  = Price;
            // this.Currency  = Currency;
            this.Quantity = Quantity;
            this.RecordType  = RecordType;
            this.Status  = Status;
            this.InputType  = InputType;
            this.Compliance  = Compliance;
          
        }   
    }




    
}