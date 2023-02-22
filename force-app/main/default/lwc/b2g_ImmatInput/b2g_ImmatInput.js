import { LightningElement, api} from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class B2g_ImmatInput extends LightningElement {
    @api isValidImmat = false;
    @api showIcons = false;
    @api immatriculation;
    @api immatInput;


    @api placeholder;
    @api msgWhenMismatched;
    @api label;
    @api regexPattern ;  
    @api isDebug = false;

    @api areTermsAccepted = false;
    @api termsConditionsMsg;
    @api focusOnTermsCheckbox = false;
    @api incorrectInputCheckbox;

    get getLayoutSize(){
        return FORM_FACTOR == 'Small' ? 12 : 6;
    }

    connectedCallback() {
        this.setFocusOnElement("lightning-input.immat");
	}


    setFocusOnElement(controlIdentity) {
		let timer = window.setTimeout(() => {
			const lControl = this.template.querySelector(controlIdentity);
			lControl.focus();
			if(this.isDebug) console.log("constructor", lControl);
			window.clearTimeout(timer);
		});
	}

    setBlurOnElement(controlIdentity) {
		let timer = window.setTimeout(() => {
			const lControl = this.template.querySelector(controlIdentity);
			lControl.blur();
			if(this.isDebug) console.log("constructor", lControl);
			window.clearTimeout(timer);
		});
	}


    handleChange(evt){
        if(this.isDebug) console.log('handleChange START');
        //this.immatriculation = evt.target.value;

        var value = evt.target.value;
        this.immatInput = value.toUpperCase();

        if(this.isDebug) console.log(JSON.stringify(evt.target));
        var valid = evt.target.validity.valid;
        if(this.isDebug) console.log(evt.target.validity.valid)

        if(value != value.toUpperCase()){
            this.immatInput = value.toUpperCase();
            this.setBlurOnElement("lightning-input.immat");
            this.setFocusOnElement("lightning-input.immat");
            return;
        }

        if(this.immatInput == null || this.immatInput == ''){
            this.isValidImmat = false;
            this.showIcons = false;
        }else{        
            this.showIcons = true;
            this.isValidImmat = evt.target.validity.valid;
        }

        const attributeChangeEvent = new FlowAttributeChangeEvent('isValidImmat', this.isValidImmat);
        const attributeChangeEvent2 = new FlowAttributeChangeEvent('immatriculation', value);
        this.dispatchEvent(attributeChangeEvent);
        this.dispatchEvent(attributeChangeEvent2);
        if(this.isDebug) console.log('handleChange END');
    }
}