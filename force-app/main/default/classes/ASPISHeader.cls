/*
----------------------------------------------------------------------
-- - Name          : ASPISHeader
-- - Author        : VSU
-- - Description   : Controller for component ASPISHeader
--
-- Maintenance History:
--
-- Date      Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 16-JUN-2017  VSU    1.0      Initial version
-- 22-OCT-2018  AMI    1.1      C-002781 : Migrate Spain to R4
                                         : Adding boolean to hide my invoices tab
-- 05-NOV-2018  AMI    1.2      C-002781 : Migrate Spain to R4
                                         : Adding boolean to show Alpha Store  
-- 12-NOV-2018  AMI    1.3      C-002781 : Migrate Spain to R4
                                         : Adding boolean to show My Cases                     
-- 03-JUL-2019  WCH    1.4      C-003316 : Spain R4 Nice to have
-- 17-AUG-2021  HMO    1.5      C-004433 : ASPartners  
-- 05-MAY-2022  NPE    1.6      C-004704: AJOUT ONGLET POUR VISUALISER LES CGV ASF
----------------------------------------------------------------------
**********************************************************************
*/
public class ASPISHeader{
  public String profilePicture {get; set;}
  public User currentUser {get; set;}
  public String encodedUserId {get;set;}
  public Boolean isEligibleQuotation {get; set;}
  //DUN 20/03/3018 case 2340
  public Boolean showWelcomeModal {get; set;}

  //AMI 22/10/2018 C-002781 : Migrate Spain to R4
  //                        : Adding boolean to hide my invoices tab
  public boolean showMyInvoice {get;set;}

  //AMI 22/10/2018 C-002781 : Migrate Spain to R4
  //                        : Adding boolean to show Alpha Store   
  public boolean showAStore {get;set;}
    
  //HMO 17/08/2021 C-004433  
  public boolean showASPartner {get;set;}
    

  //AMI 22/10/2018 C-002781 : Migrate Spain to R4
  //                        : Adding boolean to show My Cases   
  public boolean showMyCases {get;set;}

  //                        :getting custom label for stored alpha scale permission id
  public string communityPermissionSet = '';

  //AMI 25/01/2019 C-002781 : Migrate Spain to R4
  //                        : Adding boolean to show Home Page
  public boolean showChatter {get;set;}

  //WCH 03/07/2019 C-003316 
  public boolean showMyAssessments {get;set;}

   //NPE 05/05/2022 C-004704: AJOUT ONGLET POUR VISUALISER LES CGV ASF
   public boolean showCGenerale{get;set;}

  public ASPISHeader(){
    //DUN 20/03/3018 case 2340
    showWelcomeModal  = false;
    currentUser       = [  SELECT   SmallPhotoUrl, HideSiteWelcomePopup__c, UserRoleId, UserRole.Name,CountryCode 
                            FROM   User 
                            WHERE   User.Id =: UserInfo.getUserId()];
    system.debug('##currentUser'+currentUser.id);

    profilePicture      = currentUser.SmallPhotoUrl;

    //AMI 22/10/2018 C-002781 : Migrate Spain to R4
    //                        : Adding boolean to show My Cases Tab
    //AMI 22/10/2018  C-002781 : Migrate Spain to R4
    //                         : Adding boolean to hide My Invoices Tab
    if(currentUser.CountryCode != null &&
        currentUser.CountryCode.toLowerCase() == ASPISConstants.TECH_EntityCountryCodeES.toLowerCase()){
        showMyInvoice = false;
        showMyCases = true;
        showMyAssessments=true;//WCH 03/07/2019 C-003316 
    }else{
        showMyInvoice = true;
        showMyCases = false;
        showMyAssessments=false;//WCH 03/07/2019 C-003316 
    }

    //AMI 22/10/2018 C-002781 : Migrate Spain to R4
    //                        : Adding boolean to show Alpha Store   
    //                        : Initialising Boolean
    showAStore = false;

    //HMO 17/08/2021 C-004433 
    showASPartner =  false;

    //AMI 22/10/2018 C-002781 : Migrate Spain to R4
    //                        : getting custom label for stored alpha scale permission id
    if(string.isNotBlank(system.label.PaintingPermissionSetId)){
        communityPermissionSet = system.label.PaintingPermissionSetId.split('-')[1];

        //                        : Query Permission Set Assign To Connected User to see if alpha store
        //                        : should be displayed
        for(PermissionSetAssignment ps : [select id,AssigneeId
                                          from PermissionSetAssignment
                                          where AssigneeId = :UserInfo.getUserId()
                                          and PermissionSetId = :communityPermissionSet]){
            showAStore = true;
        }//end PermissionSetAssignment query 
    }//end check on community persmission set id custom label
    
    try{
        encodedUserId = encryptBase64(currentUser.id);
    }
    catch(Exception e){
        system.debug('##e.getMessage()'+e.getMessage());
    }

    if(!currentUser.HideSiteWelcomePopup__c )
        {
            showWelcomeModal = true;
        }

    Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();

    //NPE 05/05/2022 C-004704: AJOUT ONGLET POUR VISUALISER LES CGV ASF
    Boolean showCGV= mapCountryCodeMapping.get(currentUser.CountryCode).showCGV__c;

    isEligibleQuotation = eligibleQuotation(mapCountryCodeMapping);

    //AMI 25/01/2019 C-002781 : Migrate Spain to R4
    //                        : Adding boolean to show Home Page
    //                        : Initialising boolean
    showChatter = false;

    //AMI 25/01/2019 C-002781 : Migrate Spain to R4
    //                        : Adding boolean to show Home Page
    //                        : Query country code to see if eligible chatter
    if(string.isNotBlank(currentUser.CountryCode) && mapCountryCodeMapping.containsKey((currentUser.CountryCode).toUpperCase())){
        showChatter = mapCountryCodeMapping.get((currentUser.CountryCode).toUpperCase()).EnableChatterFeed__c;
    }

    //NPE 05/05/2022 C-004704: AJOUT ONGLET POUR VISUALISER LES CGV ASF
    if(showCGV){
        showCGenerale = true;
    }
    
    //HMO 17/08/2021 C-004433 
    if(string.isNotBlank(currentUser.CountryCode) && mapCountryCodeMapping.containsKey((currentUser.CountryCode).toUpperCase())){
        showASPartner = mapCountryCodeMapping.get((currentUser.CountryCode).toUpperCase()).showASPartner__c;

    }
  }

  public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);
        System.debug('Encrypted Text ' + encryptedData);

        return encryptedData;
    }

  public boolean eligibleQuotation(Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping)
    {

      CountryCodeInformationsMapping__c currentCountryInfo = (mapCountryCodeMapping.containsKey(currentUser.CountryCode) ? mapCountryCodeMapping.get(currentUser.CountryCode) : mapCountryCodeMapping.get('DEFAULT'));

      if(currentCountryInfo != null)
      {
        isEligibleQuotation = currentCountryInfo.EligibleQuotation__c;
      }
      return isEligibleQuotation;
    }

    //DUN 20/03/3018 case 2340
    public void checkHideSiteWelcomePopup()
    {
        if(currentUser.HideSiteWelcomePopup__c)
        {
            update new User(Id                      = currentUser.Id,
                            HideSiteWelcomePopup__c = true);
        }

        showWelcomeModal = false;
    }
}