/***
* @author P-E GROS
* @date   Feb. 2021
* @description LWC Component for Flows enabling to display a set of records and select one of them.
*              Multiple display modes are available for the set of records to display from.
*              It is also possible to provide a first selected record at initialisation.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

import { LightningElement, wire , api, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import pubsub from 'c/pubsub'

import LOCALE       from '@salesforce/i18n/locale';
import CURRENCY     from '@salesforce/i18n/currency';
import ALL_LABEL    from '@salesforce/label/c.sfpegListMultiSelectorAll';
import SELECT_LABEL from '@salesforce/label/c.sfpegListMultiSelectorHeader';
import SEARCH_LABEL from '@salesforce/label/c.sfpegListMultiSelectorSearchHeader';
import SEARCH_PLACEHOLDER from '@salesforce/label/c.sfpegListMultiSelectorSearchPlaceholder';
import LIST_LABEL   from '@salesforce/label/c.sfpegListMultiSelectorListHeader';
import SORT_LABEL   from '@salesforce/label/c.sfpegListMultiSelectorSortAction';



import CARPARTS_IMAGES from '@salesforce/resourceUrl/b2g_CarPartsImages';

const FIELDS = [
    'B2G_FlowConfig__mdt.MasterLabel',
    'B2G_FlowConfig__mdt.DeveloperName',
    'B2G_FlowConfig__mdt.b2g_Step2_RVNotForMultiSelect__c',
    'B2G_FlowConfig__mdt.b2g_Step2_OnlineRVNotAvail__c',
    'B2G_FlowConfig__mdt.b2g_Step2_itemNotCoveredByB2G__c',
    'B2G_FlowConfig__mdt.B2G_Step2_Intervention2040mins__c',
    'B2G_FlowConfig__mdt.B2G_Step2_Intervention3hours__c',
];


export default class SfpegListMultiSelectorFlw extends LightningElement {


    @api b2g_FlowConfigId;
    @api canPublishWarnings
    
    @api selectionLength;

    @api selectionMsg;
    @api selectionMsgType;

    @wire(getRecord, { recordId: '$b2g_FlowConfigId', fields: FIELDS })
    flowConfig;


    // Configuration fields - Main Container Display
    @api cardTitle;                 // Title of the wrapping Card
    @api cardIcon;                  // Icon of the wrapping Card
    @api cardClass;                 // CSS Classes for the wrapping card div
    @api displayMode    = 'tiles';  // selected display mode (list, tiles, table)
    @api tileSize       = 4;        // tile size (in tiles or table mode)
    @api tileSizeMedium = 6;
    @api tileSizeSmall = 6;
    @api searchHeight   = 0;        // Height (in px) of the Search list display area (0 : no scroll)

    // Configuration fields - Selection Record List 
    @api nameLabel      = 'Title';  // Label of the field to be used as title for each record
    @api nameField      = 'Name';   // API name of the field to be used as title for each record
    @api keyField       = 'Id';     // Record single identification key (usually Salesforce Id)
    @api selectName     = false;    // Flag to tell whether title field should be selected as search option by default
    @api fieldSetName   = null;     // fieldset for additional info in tiles
    @api recordList     = [];       // input record list to display
    @api selectionList  = [];       // output selected record list
    @api preselectionList  = [];    // input preselected record list

    // Configuration fields - Options selection
    @api isDebug = false;           // Flag to display debug info.
    @api showSearch = false;        // Flag to display search box.
    @api showSelection = false;     // Flag to display selection box.
    @api showSort = false;          // Flag to display Sort button-menu.
    @api isSearchAuto = false;      // Flag to trigger automatic search upon search bar user entry 
    @api defaultSortedBy = null;    // API name of the field by which the list should be sorted by default (optional)

    // Internal fields for Selection
    @track isReady      = false;        // Controls initialisation of the component.
    @track displayItems = [];           // Display Items corresponding to recordList.
    fieldSetDesc        = [];           // fieldset description data fetched
    detailFieldsJson    = [];           // list of detail fields.
    selectHeader        = SELECT_LABEL; // Header label of the selected record section
    searchHeader        = SEARCH_LABEL; // Header label of the search section
    searchPlaceholder   = SEARCH_PLACEHOLDER; // Placeholder label of the search input
    listHeader          = LIST_LABEL;   // Header label of the record list selection section
    sortTitle           = SORT_LABEL;   // Label of the sort button menu.

    // Internal Fields for Sort
    @track sortFields = null;       // List of field sort options for List display mode (for the sort menu)
    @track sortDirection = 'asc';     // Current sorting direction (asc/desc)
    @track sortedBy = null;           // Field upon which the current sorting is done

    // Internal Fields for Search
    searchScopes = [{'label':ALL_LABEL,'value':"ALL",'isChecked':true}] ; // possible scopes for Search ("All" + all fieldset fields)
    searchScope = {'label':ALL_LABEL,'value':"ALL",'isChecked':true};     // Selected search scope
    searchString = null;            // Search criteria entered by User



    // Display mode getters
    get isTiles() {
        if (this.isDebug) console.log('connectedCallback: isTiles', this.displayMode === 'tiles');
        return this.displayMode === 'tiles';
    }



    // Component Initialisation
    connectedCallback() {

        if (!this.fieldSetName) {
            if (this.isDebug) console.log('wiredFieldSet: no fieldSet to set');

            this.recordList.forEach(eachRecord => {
                if (this.isDebug) console.log('wiredFieldSet: processing record ', JSON.stringify(eachRecord));

                //let recordSelectIndex = this.preselectionList.findIndex(eachSelection => eachSelection.Id === eachRecord.Id);
                let recordSelectIndex = this.preselectionList.findIndex(eachSelection => (eachSelection[this.keyField]) === (eachRecord[this.keyField]));

                if (this.isDebug) console.log('preselectionList: ', this.preselectionList)
                
                if (this.isDebug) console.log('wiredFieldSet: record selection index determined ', recordSelectIndex);
                let newItem = {
                    'label': eachRecord[this.nameField],
                    'imageName' : CARPARTS_IMAGES + '/' + eachRecord["b2g_ImageName__c"],

                    //'id': eachRecord.Id,
                    'id': eachRecord[this.keyField],
                    'isSelected': (recordSelectIndex != -1),
                    'isFiltered': true,
                    'class': 'slds-box slds-box_x-small slds-var-m-around_xx-small slds-theme_default' + ((recordSelectIndex != -1) ? ' selectedItem' : ''),
                    'details': [],
                    'value':eachRecord
                };
                if (this.isDebug) console.log('wiredFieldSet: newItem init', JSON.stringify(newItem));
                this.displayItems.push(newItem);

                if (recordSelectIndex != -1) {
                    if (this.isDebug) console.log('wiredFieldSet: registering record in selection', JSON.stringify(eachRecord));
                    this.selectionList.push(eachRecord);
                } 
            });
            if (this.isDebug) console.log('wiredFieldSet: items init', JSON.stringify(this.displayItems));
        }


        this.isReady = true;
        if (this.isDebug) console.log('connectedCallback: START');
        if (this.isDebug) console.log('connectedCallback: displayMode configured ', this.displayMode);
        if (this.isDebug) console.log('connectedCallback: nameField configured ', this.nameField);
        if (this.isDebug) console.log('connectedCallback: nameLabel configured ', this.nameLabel);
        if (this.isDebug) console.log('connectedCallback: selectName configured ', this.selectName);
        if (this.isDebug) console.log('connectedCallback: fieldSetName configured ', this.fieldSetName);
        if (this.isDebug) console.log('connectedCallback: recordList configured ', JSON.stringify(this.recordList));                            
        if (this.isDebug) console.log('connectedCallback: selectionList configured ', JSON.stringify(this.selectionList));
        if (this.isDebug) console.log('connectedCallback: defaultSortedBy configured ', this.defaultSortedBy);
        this.sortedBy = this.defaultSortedBy;
        if (this.isDebug) console.log('connectedCallback: sortedBy init ', this.sortedBy);

        if ((this.nameField) && (this.nameLabel)) {
            if (this.isDebug) console.log('connectedCallback: registering name/title in search fields');

            if (this.selectName) {
                if (this.isDebug) console.log('connectedCallback: selecting name/title as default in search fields');
                this.searchScopes.push({'label':this.nameLabel,'value':this.nameField,'isChecked':true});
                this.searchScopes[0].isChecked = false; // resetting default value
                this.searchScope = {'label':this.nameLabel,'value':this.nameField,'isChecked':true};
            }
            else {
                if (this.isDebug) console.log('connectedCallback: keeping ALL as default in search fields');
                this.searchScopes.push({'label':this.nameLabel,'value':this.nameField,'isChecked':false});
            }
            if (this.isDebug) console.log('connectedCallback: search scopes init', JSON.stringify(this.searchScopes));
            if (this.isDebug) console.log('connectedCallback: selected search scope init', JSON.stringify(this.searchScope));
        }
        else {
            console.warn('connectedCallback: missing title name/label parameters');
        }

        if (this.isDebug) console.log('connectedCallback: END');
    }

    // Component Rendering Handling
    renderedCallback() {
        if (this.isDebug) console.log('renderedCallback: START');
        if (this.isDebug) console.log('renderedCallback: END');
    }

    //#####################################
    // User Interaction Handling
    //#####################################
    // Record Selection handling
    handleSelect(event) {
        if (this.isDebug) console.log('handleSelection: START');
        let selectId = event.currentTarget.id;
        if (this.isDebug) console.log('handleSelection: selectId fetched', selectId);
              
        if (selectId) {
            if (this.isDebug) console.log('handleSelection: processing event');
            event.preventDefault();
            event.stopPropagation();
            if (this.isDebug) console.log('handleSelection: propagation stopped');

            if (selectId.includes('-')) selectId = selectId.substring(0,selectId.indexOf('-'));
            if (this.isDebug) console.log('handleSelection: new selected ID',selectId);

            if (this.isDebug) console.log('handleSelection: recordList fetched',JSON.stringify(this.recordList)); 
            let selectedRecord = this.recordList.find(eachRecord => {
                if (this.isDebug) console.log('handleSelection: processing record',JSON.stringify(eachRecord));
                //if (this.isDebug) console.log('handleSelection: record Id',eachRecord.Id);
                //if (this.isDebug) console.log('handleSelection: test ',(eachRecord.Id === selectId));
                //return (eachRecord.Id === selectId);
                if (this.isDebug) console.log('handleSelection: record Key',eachRecord[this.keyField]);
                if (this.isDebug) console.log('handleSelection: test selection ',(eachRecord[this.keyField] === selectId));
                return ((eachRecord[this.keyField]) === selectId);
            });
            if (this.isDebug) console.log('handleSelection: selectedRecord fetched',JSON.stringify(selectedRecord)); 
            //let selectedIndex = this.selectionList.findIndex(eachRecord => (eachRecord.Id === selectId));
            let selectedIndex = this.selectionList.findIndex(eachRecord => (eachRecord[this.keyField] === selectId));
            if (this.isDebug) console.log('handleSelection: selectedIndex evaluated',selectedIndex);
            let selectedItem = this.displayItems.find(item => (item.id === selectId));
            if (this.isDebug) console.log('handleSelection: selectedItem fetched',JSON.stringify(selectedItem));

            // select new tile
            if (selectedIndex != -1) {
                if (this.isDebug) console.log('handleSelection: unselecting record',selectId);

                this.selectionList.splice(selectedIndex,1);
                if (this.isDebug) console.log('handleSelection: selectionList updated');          

                selectedItem.isSelected = false;
                selectedItem.class = 'slds-box slds-box_x-small slds-var-m-around_xx-small slds-theme_default';
                if (this.isDebug) console.log('handleSelection: selectedItem updated',JSON.stringify(selectedItem));

                let unselectEvent = new CustomEvent('unselect', {
                    "detail": {
                        "record": selectedRecord,
                        "list": this.selectionList
                    }
                });
                if (this.isDebug) console.log('handleSelection: unselectEvent init',JSON.stringify(unselectEvent));   
                this.dispatchEvent(unselectEvent);
                if (this.isDebug) console.log('handleSelection: unselectEvent dispatched'); 
            }
            else {
                if (this.isDebug) console.log('handleSelection: selecting new record',selectId);

                this.selectionList.push(selectedRecord);
                if (this.isDebug) console.log('handleSelection: selectionList updated');          

                selectedItem.isSelected = true;
                //selectedItem.class = 'slds-box slds-box_x-small slds-var-m-around_xx-small slds-theme_info';
                selectedItem.class = 'slds-box slds-box_x-small slds-var-m-around_xx-small slds-theme_default selectedItem';
                if (this.isDebug) console.log('handleSelection: selectedItem updated',JSON.stringify(selectedItem));   
           
                let selectEvent = new CustomEvent('select', {
                    "detail": {
                        "record": selectedRecord,
                        "list": this.selectionList
                    }
                });
                if (this.isDebug) console.log('handleSelection: selectEvent init',JSON.stringify(selectEvent));   
                this.dispatchEvent(selectEvent);
                if (this.isDebug) console.log('handleSelection: selectEvent dispatched');
            }
        }
        else {
            if (this.isDebug) console.log('handleSelection: ignoring event');
        } 
        
        if (this.isDebug) console.log('this.selectionList.length', this.selectionList.length);

        this.handlePublisherMsg();

        if (this.isDebug) console.log('handleSelection: END');        
    }

    handleDeselect(event) {
        if (this.isDebug) console.log('handleRemove: START');
        if (this.isDebug) console.log('handleRemove: event',event);
        if (this.isDebug) console.log('handleRemove: detail',JSON.stringify(event.detail));

        if (this.isDebug) console.log('handleRemove: item removed',event.detail.item.name);
        if (this.isDebug) console.log('handleRemove: index removed',event.detail.index);

        if (this.displayItems.length > 1) {
            this.displayItems.splice(event.detail.index,1);
            if (this.isDebug) console.log('handleRemove: displayItems updated',JSON.stringify(this.displayItems)); 
        }

        if (this.displayItems.length == 1) {
            //this.selectedRecord = this.recordList.find(element => element.Id === this.displayItems[0].name);
            this.selectedRecord = this.recordList.find(element => ((element[this.keyField]) === (this.displayItems[0].name)));
            if (this.isDebug) console.log('handleRemove: selection set',JSON.stringify(this.selectedRecord)); 
        }

        this.handlePublisherMsg();

        if (this.isDebug) console.log('handleRemove: END');


    }



    handlePublisherMsg(){

        if(!this.canPublishWarnings){
            return;
        }

        if(this.isDebug) console.log('flowConfig', this.flowConfig);
        if(this.isDebug) console.log('recordId: ', this.b2g_FlowConfigId);

        var RV_NotAllowedOnMultiSelect, ItemNotCoveredByB2G, InterventionTime3hrs, InterventionTime20Mins, RVOnline_NotAvail;
        if(this.flowConfig != null && this.flowConfig.data != null){
            RV_NotAllowedOnMultiSelect = this.flowConfig.data.fields.b2g_Step2_RVNotForMultiSelect__c.value;
            ItemNotCoveredByB2G        = this.flowConfig.data.fields.b2g_Step2_itemNotCoveredByB2G__c.value;
            InterventionTime3hrs       = this.flowConfig.data.fields.B2G_Step2_Intervention3hours__c.value;
            InterventionTime20Mins     = this.flowConfig.data.fields.B2G_Step2_Intervention2040mins__c.value;
            RVOnline_NotAvail          = this.flowConfig.data.fields.b2g_Step2_OnlineRVNotAvail__c.value;
        }

        let message = {
            "message" : null,
            "messageVariant" : "slds-text-color_error slds-text-heading_small"
        }

        if(this.selectionList != null && this.selectionList.length > 0){

            if(this.selectionList.length > 1){
                //More than 1 selection
                this.selectionMsg = RV_NotAllowedOnMultiSelect;
                this.selectionMsgType = 'Error';

                if(this.isDebug) console.log('More than 1 selection is not allowed for RV');
                message = {
                    "message" : RV_NotAllowedOnMultiSelect,
                    "messageVariant" : "slds-text-color_error slds-text-heading_small"
                }
            }else{
                if(this.selectionList[0].CanMakeAppointmentOnline__c && this.selectionList[0].IsCoveredUnderB2G__c){
                    if(this.isDebug) console.log(this.selectionList[0].b2g_ReparationTime__c);
                    if(this.isDebug) console.log(this.selectionList[0].b2g_ReparationTime__c);
    
                    if(this.selectionList[0].b2g_ReparationTime__c == '20 - 40 minutes'){
                        if(this.isDebug) console.log('Reparation time 20-40 minutes');
                        this.selectionMsg = InterventionTime20Mins;
                        this.selectionMsgType = 'Info';
                        message = {
                            "message" : InterventionTime20Mins,
                            "messageVariant" : "slds-text-color_default slds-text-heading_small"
                        }
                    }
    
                    if(this.selectionList[0].b2g_ReparationTime__c == '3 hours'){
                        if(this.isDebug) console.log('Reparation time 3 hours');
                        this.selectionMsg = InterventionTime3hrs;
                        this.selectionMsgType = 'Info';
                        message = {
                            "message" : InterventionTime3hrs,
                            "messageVariant" : "slds-text-color_default slds-text-heading_small"
                        }
                    }
    
                }

                if(!this.selectionList[0].IsCoveredUnderB2G__c ){
                    //Item not covered by B2G
                    if(this.isDebug) console.log('Not covered by B2G Warranty');
                    this.selectionMsg = ItemNotCoveredByB2G;
                    this.selectionMsgType = 'Error';
                    message = {
                        "message" : ItemNotCoveredByB2G,
                        "messageVariant" : "slds-text-color_error slds-text-heading_small"
                    }
                }
    
                if(!this.selectionList[0].CanMakeAppointmentOnline__c){
                    //More than 1 selection
                    if(this.isDebug) console.log('More than 1 selection is not allowed for RV');
                    this.selectionMsg = RVOnline_NotAvail;
                    this.selectionMsgType = 'Error';
                    message = {
                        "message" : RVOnline_NotAvail,
                        "messageVariant" : "slds-text-color_error slds-text-heading_small"
                    }
                }
    
            }
        }

        pubsub.fire('msgChannelPublisher', message);
        if(this.isDebug) console.log('pubsub event fired')
    }
}