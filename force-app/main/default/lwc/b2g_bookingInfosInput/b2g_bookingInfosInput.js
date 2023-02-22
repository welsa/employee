import { LightningElement , api} from 'lwc';

export default class B2g_bookingInfosInput extends LightningElement {
    @api firstNameLabel;
    @api lastNameLabel;
    @api emailLabel;
    @api phoneLabel;
    @api additionalInfoLabel;

    @api firstNameValue;
    @api lastNameValue;
    @api emailValue;
    @api phoneValue;
    @api additionalInfoValue;

    @api isDebug;

    connectedCallback(){
        if (this.isDebug) console.log('b2g_BookingsInfos START ')
    }

    debugValues(){
        if (this.isDebug) console.log('firstNameValue : ', this.firstNameValue)
        if (this.isDebug) console.log('lastNameValue : ', this.lastNameValue)
        if (this.isDebug) console.log('phoneValue : ', this.phoneValue)
        if (this.isDebug) console.log('additionalInfoValue : ', this.additionalInfoValue)
        if (this.isDebug) console.log('emailValue : ', this.emailValue)
    }

    handlefirstNameInputChange(event){
        this.firstNameValue = event.detail.value;
        this.debugValues();
    }

    handlelastNameInputChange(event){
        this.lastNameValue = event.detail.value;
        this.debugValues();
    }

    handleEmailInputChange(event){
        this.emailValue = event.detail.value;
        this.debugValues();
    }

    handlePhoneInputChange(event){
        this.phoneValue = event.detail.value;
        this.debugValues();
    }

    handleAdditionalInputChange(event){
        this.additionalInfoValue = event.detail.value;
        this.debugValues();
    }
}