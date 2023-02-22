import { LightningElement, api } from 'lwc';
import {FlowNavigationBackEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import pubsub from 'c/pubsub';


export default class B2g_customFooter extends LightningElement {

    @api disablePrevious = false;
    @api disableNext = false;
    @api nextLabel = "Next";
    @api previousLabel = "Previous";
    @api hideNextBtn = false;
    @api hidePreviousBtn = false;

    @api isDebug = false;

    connectedCallback(){
        this.register();
    }

    get HideNextButton(){
        return this.hideNextBtn ? "slds-hide" : "slds-show";
    }

    get HidePreviousButton(){
        return this.hidePreviousBtn ? "slds-hide" : "slds-show slds-m-right_x-small";
    }

    register(){
        pubsub.register('customFooter', this.handleEvent.bind(this));
        if(this.isDebug) if(this.isDebug) console.log('event registered: customFooter');
    }

    handleEvent(messageFromEvt){
        if(this.isDebug) if(this.isDebug) console.log('event handled ',messageFromEvt);
        if(messageFromEvt != null){
            var evtMsg = messageFromEvt; 
            if(this.isDebug) if(this.isDebug) console.log('evtMsg', evtMsg);

            if(evtMsg != null){
        
                if(evtMsg.long != null && evtMsg.lat != null){
                    this.latitude   = evtMsg.long;
                    this.longitude  = evtMsg.lat;
                    this.street     = evtMsg.street;
                    this.country    = evtMsg.country;
                    this.PostalCode = evtMsg.PostalCode;
                    this.city       = evtMsg.city
                    this.getRepairmen();
                }

                if(evtMsg.requireLoanVehicle != null ){
                    this.requireLoanVehicle = evtMsg.requireLoanVehicle;
                    this.handleLoanVehicleDisplay();
                }

                if(evtMsg.isSelected_HomeApt != null){
                    this.showMap = !evtMsg.isSelected_HomeApt;
                }
            }
        }
    }


    handleNext(event){
        const navigateNextEvent = new FlowNavigationNextEvent();
        try {
            this.dispatchEvent(navigateNextEvent);
            if(this.isDebug) if(this.isDebug) console.log('navigateNextEvent dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) if(this.isDebug) console.log('Exception: ' + ex);
        }
    }

    handlePrevious(event){
        const navigatePreviousEvent = new FlowNavigationBackEvent();
        try {
            this.dispatchEvent(navigatePreviousEvent);
            if(this.isDebug) if(this.isDebug) console.log('navigatePreviousEvent dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) console.log('Exception: ' + ex);
        }
    }

}