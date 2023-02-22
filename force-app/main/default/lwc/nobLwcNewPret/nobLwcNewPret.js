import { LightningElement, api , wire } from 'lwc';
import getObsolete from '@salesforce/apex/NOB_LC53_NouveauPret.checkVR';
import getWorkOrderFields from '@salesforce/apex/NOB_LC53_NouveauPret.getWorkOrderFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NOB_LC53_Cancel from '@salesforce/label/c.NOB_LC53_Cancel'
import NOB_LC53_Save from '@salesforce/label/c.NOB_LC53_Save'
import NOB_LC53_VrWarning from '@salesforce/label/c.NOB_LC53_VrWarning'
import NOB_LC53_OrdreDexecution from '@salesforce/label/c.NOB_LC53_OrdreDexecution'

export default class NobLwcNewPret extends LightningElement {

    label = {
        NOB_LC53_Cancel,NOB_LC53_Save,NOB_LC53_VrWarning,NOB_LC53_OrdreDexecution
    };

    @api recordId;  
    isObsolete;
    datePriseCharge;
    dateRestitution;
    woNumber;
    isLoading;
    msg1;msg2;

    connectedCallback(){
        const params = { 'recordId': this.recordId};
        getWorkOrderFields(params).then(results =>{
            console.log('results '+ JSON.stringify(results));
            if (results.hasOwnProperty('WorkOrderNumber')){
                this.woNumber = results.WorkOrderNumber;
            }

            if (results.hasOwnProperty('NOB_VehiculeReturnDate__c')){
                this.dateRestitution = results.NOB_VehiculeReturnDate__c;
            }

            if (results.hasOwnProperty('NOB_TECHDateRendezVousPrisEnCharge__c')){
                this.datePriseCharge = results.NOB_TECHDateRendezVousPrisEnCharge__c;
            }

        }).catch(error=>{
            console.error(JSON.stringify(error));
        }) 
    }

    handleload(){
        //let cancelButton = this.template.querySelector('[data-id="cancelBtn"]');
        //cancelButton.focus();
       
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        fields.NOB_OrdreExecution__c = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isLoading = true;
    }

    handleSuccess(event){
        this.isLoading = false;
        const insertedRecord = event.detail.id;
        const message = 'Prêt' + ' '+insertedRecord+' '+ 'a été crée';
        this.showToast('', message, 'success');
        this.closeQuickAction();
        this.refreshScreen();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
        title: title,
        variant: variant,
        message: message,
        mode: variant == "warning" ? "sticky" : "dismissible"
        });
        this.dispatchEvent(event);
    }

    handleError(event){ 
        console.error('erreur' + JSON.stringify(event.detail.detail));
        this.template.querySelector('[data-id="form-err"]').setError('Une erreur est survenue.'); 
        this.isLoading = false;
    }

    handleObsolete(event){
        let vrId = '';
        if(event.target.name=='inp1')
            vrId= event.target.value;
        const params = { 'vrId': vrId};

        getObsolete(params).then(results =>{
            this.isObsolete =  results;
            let message = new String(this.label.NOB_LC53_VrWarning);
            let processedMsg = (message != null) ? message.split(',') : null;
            this.msg1 = (processedMsg != null) ? processedMsg[0] : '';
            this.msg2 = (processedMsg != null) ? processedMsg[1] : '';

        }).catch(error=>{
           console.warn(JSON.stringify(error));
        }) 

    }

    closeQuickAction() {
        const evtclose = new CustomEvent('close');
        this.dispatchEvent(evtclose);
    }

    refreshScreen(){
        
        const evtRefresh = new CustomEvent('refresh');
        this.dispatchEvent(evtRefresh);
    }

    handleCancel(){
        this.closeQuickAction();
    }
}