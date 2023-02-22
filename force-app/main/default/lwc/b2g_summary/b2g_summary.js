import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class B2g_summary extends LightningElement {

    //Labels
    @api homeInterventionLabel   = "Intervention à domicile";
    @api dateRVLabel             = "Date de rendez-vous";
    @api interventionLabel       = "Intervention";
    @api reparationDurationLabel = "Durée de la réparation";
    @api immatriculationLabel    = "Immatriculation"

    //Values
    @api timezone;
    @api appointmentDate;
    @api isSAD = false;
    @api repairCenterName;
    @api repairCenterAddress;
    @api repairCenterPhone;
    @api reparationDuration;
    @api immatriculation;
    @api reparationDescription;
    @api homeInterventionAddress;

    @api isDebug;


    connectedCallback(){
        if(this.isDebug) console.log('timezone: ', this.timezone);
        if(this.isDebug) console.log('appointmentDate: ', this.appointmentDate);
        if(this.isDebug) console.log('repairCenterName: ', this.repairCenterName);
        if(this.isDebug) console.log('repairCenterAddress: ', this.repairCenterAddress);
        if(this.isDebug) console.log('repairCenterPhone: ', this.repairCenterPhone);
        if(this.isDebug) console.log('reparationDuration: ', this.reparationDuration);
        if(this.isDebug) console.log('immatriculation: ', this.immatriculation);
        if(this.isDebug) console.log('reparationDescription: ', this.reparationDescription);
        if(this.isDebug) console.log('homeInterventionAddress: ', this.homeInterventionAddress);
    }

    get borderCSS(){
        return FORM_FACTOR == "Small" ? "" : "slds-border_left";
    }
}