import { LightningElement, api} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class B2g_TermsConditions extends LightningElement {

    @api isDebug = false;
    @api areTermsAccepted = false;
    @api termsConditionsMsg;
    @api additionalTermsConditionsMsg;
    @api incorrectInputCheckbox;

    connectedCallback() {
        this.setFocusOnElement("lightning-input.terms");
	}

    get getLayoutSize(){
        return FORM_FACTOR == 'Small' ? 12 : 12;
    }

    setFocusOnElement(controlIdentity) {
		let timer = window.setTimeout(() => {
			const lControl = this.template.querySelector(controlIdentity);
			lControl.focus();
			if(this.isDebug) console.log("constructor", lControl);
			window.clearTimeout(timer);
		});
	}

    handleTermsSelection(event){
        if(this.isDebug) console.log('handleTermsSelection START');
        this.areTermsAccepted = event.detail.checked;
        if(this.isDebug) console.log('handleChandleTermsSelectionhange areTermsAccepted: ', this.areTermsAccepted);
        if(this.isDebug) console.log('handleChandleTermsSelectionhange END');
    }

}