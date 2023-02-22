import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import powerbijs from '@salesforce/resourceUrl/powerbijs';
import getPowerBiAccess from '@salesforce/apex/mcr_CommunityController.getPowerBiAccess';
import getPowerBiReport from '@salesforce/apex/mcr_CommunityController.getPowerBiReport';

import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import USERNAME_FIELD from '@salesforce/schema/User.Username';
import PHOTOURL_FIELD from '@salesforce/schema/User.FullPhotoUrl';
import ACCOUNTNAME_FIELD from '@salesforce/schema/User.Contact.Account.Name';
import PORTALLOGO_FIELD from '@salesforce/schema/User.Contact.Account.MCR_Portal_Logo__c';
import PORTALCOLOR_FIELD from '@salesforce/schema/User.Contact.Account.MCR_Portal_Color__c';
import basePath from "@salesforce/community/basePath";

const fields = [NAME_FIELD, EMAIL_FIELD, USERNAME_FIELD, PHOTOURL_FIELD, ACCOUNTNAME_FIELD, PORTALLOGO_FIELD, PORTALCOLOR_FIELD ];

export default class Mcr_dxp_ReportComponent extends LightningElement {

    userId = Id;
    showUserCard = false;
    showUserSettings = false;
    skipRenderedCallback = false;
    portalLogo;
    portalColor;


    @track value = '';
    @track records;
    @track user;
    @track error;
    @track items;
    @track selectedWorkspaceId;
    @track selectedItemId = '';
    @track userName;
    @track email;
    @track userFullName;
    @track photoUrl;
    @track accountName;
    @track defaultItem;
    @track isFilterPaneVisible;
    @track isFilterPaneExpanded;
    @track isPageNavigationVisible;
    @track defaultReportPage;


  
  openUserCard(){
    this.skipRenderedCallback=true;

    // close others popovers
    if(this.showUserSettings == true){
      this.showUserSettings = false;
    }
    
    // open / close popover
    if(this.showUserCard == true){
        this.showUserCard = false;}
        else{
          this.showUserCard = true;
        }
    
  }

  openUserSettings(){ 
    this.skipRenderedCallback=true;
    
    if(this.showUserCard == true){
      this.showUserCard = false;
    }

    if(this.showUserSettings == true){
      this.showUserSettings = false;}
      else{
        this.showUserSettings = true;
      }
  }

  handleApplySettings(){
    this.skipRenderedCallback=true;
    this.showUserSettings = false;

  }

     // Get Connected User Informations
  @wire(getRecord, { recordId: '$userId', fields })
  wiredUser({ error, data }) {
    if (data) { 
      this.userName = getFieldValue(data,USERNAME_FIELD);
      this.email = getFieldValue(data, EMAIL_FIELD);
      this.userFullName = getFieldValue(data, NAME_FIELD);
      this.photoUrl = getFieldValue(data,PHOTOURL_FIELD);
      this.accountName = getFieldValue(data, ACCOUNTNAME_FIELD);
      this.portalLogo = getFieldValue(data, PORTALLOGO_FIELD);
      this.portalColor = getFieldValue(data, PORTALCOLOR_FIELD);

      const globalHeaderLogo = this.template.querySelector('.slds-global-header__logo');
      globalHeaderLogo.style.backgroundImage = "url('"+this.portalLogo+"')";

    const globalHeader = this.template.querySelector('.slds-global-header');
      globalHeader.style.backgroundColor = this.portalColor;


    } else if (error) {
      this.error = error;     
    }
  }

  @wire(getPowerBiAccess, { userId: '$userId' })
  wiredAccess({ error, data }) {
    if (data) {
      this.records = data;
      this.items = data.map((cls) => Object.assign({}, { label: cls.MCR_PowerBiItemId__r.Name, value: cls.MCR_PowerBiItemId__r.MCR_TECH_ExternalId__c })); 
      var defaultItem = data.find(e => e.MCR_IsDefault__c == true);


      if (defaultItem) {       
        this.selectedItemId = defaultItem.MCR_PowerBiItemId__r.MCR_TECH_ExternalId__c;
        this.selectedWorkspaceId = defaultItem.MCR_PowerBiItemId__r.MCR_TECH_ExternalWorkspaceId__c;
        this.isFilterPaneVisible = defaultItem.MCR_IsFilterPaneVisible__c;
        this.isFilterPaneExpanded = defaultItem.MCR_IsFilterPaneExpanded__c;
        this.isPageNavigationVisible = defaultItem.MCR_IsPageNavigationVisible__c;
        this.defaultReportPage = defaultItem.MCR_DefaultReportPage__c;
        this.value = this.selectedItemId;
      }    

    } else if (error) {
      this.error = error;
      console.error('error => ', error); // error handling
    }
  }

  @wire(getPowerBiReport, {
    workspaceId: "$selectedWorkspaceId",
    reportId: "$selectedItemId",
    userContext: "$userName"
  }) report;

  onChange(event) {
    this.skipRenderedCallback=false;
    var item = this.records.find(e => e.MCR_PowerBiItemId__r.MCR_TECH_ExternalId__c === event.detail.value);
    this.selectedItemId = item.MCR_PowerBiItemId__r.MCR_TECH_ExternalId__c;
    this.selectedWorkspaceId = item.MCR_PowerBiItemId__r.MCR_TECH_ExternalWorkspaceId__c;
    this.isFilterPaneVisible = item.MCR_IsFilterPaneVisible__c;
    this.isFilterPaneExpanded = item.MCR_IsFilterPaneExpanded__c;
    this.isPageNavigationVisible = item.MCR_IsPageNavigationVisible__c;
    this.defaultReportPage = item.MCR_DefaultReportPage__c;
   
  }

  get logoutLink  () {
    const sitePrefix = basePath.replace(/\/s$/i, "");
    return sitePrefix + "/secur/logout.jsp";
  }
 

  renderedCallback() {

    if(this.skipRenderedCallback == true){
      return;
    }
   
    Promise.all([loadScript(this, powerbijs)]).then(() => {

      if (this.report.data) {

        if (this.report.data.embedUrl && this.report.data.embedToken) {

          var reportContainer = this.template.querySelector('[data-id="embed-container"');
          powerbi.reset(reportContainer)
          
          var reportId = this.report.data.reportId;
          var embedUrl = this.report.data.embedUrl;
          var token = this.report.data.embedToken;

          var config = {
            "type": "report",
            "id": reportId,
            "embedUrl": embedUrl,
            "accessToken": token,
            "tokenType": 1,
            "contrastMode": 0,
            "permissions": 7,
         //   "pageName": "ReportSection24c83bcdfac27c2097f0",
            "settings": {
                //"zoomLevel": 0.5,
                "background": 1,
                "visualRenderedEvents": false,
                "panes": {
                   "filters": {
                        "expanded": false,
                        "visible": this.isFilterPaneVisible
                    },
                    "pageNavigation": {
                        "visible": true,
                        "position": 1
                    },
                    "bars": {
                        "actionBar": {
                            "visible": true
                        }
                    },
                    "localeSettings": {
                       "language": "fr",
                        "formatLocale": "fr"
                    }
                }
            }
        }
        ;
          var report = powerbi.embed(reportContainer, config);

        }
        else {
          console.log('Call "renderedCallback()" : no embedUrl or embedToken');
        }

      }
      else {
        console.log('Call "renderedCallback()" : no report.data yet');
      }
    });
  } 


}