/* eslint-disable no-console */

/***
* @author P-E GROS
* @date   Dec. 2020
* @description  LWC Component for Flows enabling to display a path component to track a flow progress.
*               Multiple display modes are available (path, progress bar or even tabs and button bar) and
*               the component may be used for pure progress display or to graphically choose options
*               for the next flow steps to be executed (by setting an output variable which may then
*               be leveraged in flow decision nodes).
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent} from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class SfpegFlowPathFlw extends LightningElement {

    // Configuration parameters
    @api pathClass      = "slds-p-vertical_x-small";    // CSS Classes for the wrapping card div
    @api steps          = [];
    @api stepsConfig    = null;     // enables to provide a JSON striung instead of a list as input 
    @api currentStep    = null;
    @api mode           = "path";   // or tab or progress or button
    @api triggerNext    = false;
    @api alignment      = "center"; // or end or start (for button alignment)
    @api hasTopBorder   = false;    // to add top border above buttons
    @api isDebug        = false;    // Flag to display debug info.

    @api disableNextBtn;
    @api disablePrevBtn;

    // Flow Context Information
    @api   availableActions = [];

    // Technical parameter
    @track buttonList = null;  // enables 
    initDone          = false; // controls reentry in step change events at init.

    // Type Boolean testers
    get isPath() {
        if (this.isDebug) console.log('isPath called', (this.mode === "path"));
        return this.mode === "path";
    }
    get isTab() {
        if (this.isDebug) console.log('isTab called', (this.mode === "tab"));
        return this.mode === "tab";
    }
    get isProgress() {
        if (this.isDebug) console.log('isProgress called', (this.mode === "progress"));
        return this.mode === "progress";
    }
    get isButton() {
        if (this.isDebug) console.log('isButton called', (this.mode === "button"));
        return this.mode === "button";
    }
    get buttonClass() {
        if (this.isDebug) console.log('buttonClass called', ((this.hasTopBorder ? 'slds-border_top slds-p-top_small slds-m-top_small ' : '') + ' slds-grid slds-grid_align-' + this.alignment));
        return  (this.hasTopBorder ? 'slds-border_top slds-p-top_small slds-m-top_small ' : '')
                + ' slds-grid slds-grid_align-' + this.alignment;
    }

    get usingMobilePhone(){
        return (FORM_FACTOR == 'Small');
    }

    // Status change tracking
    enterStep(event) {
        if (this.isDebug) console.log('enterStep START');

        if (this.isDebug) console.log('enterStep: currentStep fetched', this.currentStep);
        if (this.isDebug) console.log('enterStep: event received',event);
        if (this.isDebug) console.log('enterStep: event target received',event.target);
        if (this.isDebug) console.log('enterStep: event detail received',event.detail);

        if ((this.initDone) && (this.triggerNext)) {
            // fetch new selected step either from progress-indicator vs tabset or button
            let newStep = event.target ? event.target.label : this.steps[event.detail.index];
            if (this.isDebug) console.log('enterStep: newStep fetched', newStep);
            
            if (this.currentStep === newStep) {
                if (this.isDebug) console.log('enterStep: END --> same step selected');
                return;
            }
            this.currentStep = newStep;
            if (this.isDebug) console.log('enterStep: currentStep updated', this.currentStep);

            const attributeChangeEvent = new FlowAttributeChangeEvent('currentStep', this.currentStep);
            this.dispatchEvent(attributeChangeEvent);
            if (this.isDebug) console.log('enterStep: currentStep change notified');

            if (this.isDebug) console.log('enterStep: available flow actions',this.availableActions);

            // check if NEXT is allowed on this screen
            if (this.availableActions.find(action => action === 'NEXT')) {
                // navigate to the next screen
                if (this.isDebug) console.log('enterStep: triggering NEXT event');
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
                if (this.isDebug) console.log('enterStep: NEXT event triggered');
            }
        }
        else {
            if (this.isDebug) console.log('enterStep: preventing default');
            event.preventDefault();
            event.stopPropagation();
        }
        if (this.isDebug) console.log('enterStep: END');
    }

    // Initializes component
    connectedCallback() {
        if (this.isDebug) console.log('Connected START');

        if (this.stepsConfig) {
            if (this.isDebug) console.log('Connected: parsing stepsConfig', this.stepsConfig);
            let steps = JSON.parse(this.stepsConfig);
            if (this.isDebug) console.log('Connected: stepsConfig parsed', steps);
            this.steps = steps;
        }
        else {
            if (this.isDebug) console.log('Connected: considering standard step list', this.steps);
            if (this.mode === "button") {
                if (this.isDebug) console.log('Connected: updating steps with button list');
                let buttonList = [];
                this.steps.forEach(item => {
                    if (this.currentStep === item) buttonList.push({"label":item,"variant":"brand"})
                    else buttonList.push({label:item,variant:"neutral"});
                });
                if (this.isDebug) console.log('Connected: buttonList init', buttonList);
                //this.buttonList = buttonList;
                this.steps = buttonList;
            }
            else {
                if (this.isDebug) console.log('Connected: steps not modified');
            }
        }
        if (this.isDebug) console.log('Connected END');
    }

    renderedCallback() {
        if (this.isDebug) console.log('Rendered START');
        this.initDone = true;
        if (this.isDebug) console.log('Rendered END');
    }

    handlePrevious(){
        if (this.isDebug) console.log('handlePrevious START');
        const navigatePreviousEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePreviousEvent);
        if (this.isDebug) console.log('handlePrevious END');
    }

    handleNext(){
        if (this.isDebug) console.log('handleNext START');
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
        if (this.isDebug) console.log('handleNext END');
    }
}