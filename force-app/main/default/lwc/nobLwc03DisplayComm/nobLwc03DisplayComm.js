import { LightningElement, api, wire,track } from 'lwc';
import renderCommunication from '@salesforce/apex/NOB_LC54_ConteurComm.renderCommunication';
import setLue from '@salesforce/apex/NOB_LC54_ConteurComm.setLue';
import { getRecord  } from 'lightning/uiRecordApi';
import dateLue from '@salesforce/schema/NOB_Communication__c.NOB_DateLue__c';
import reception from '@salesforce/schema/NOB_Communication__c.NOB_Reception__c';
import unread from '@salesforce/label/c.NOB_ButtonLabel_Unread';
import read from '@salesforce/label/c.NOB_ButtonLabel_Read';

export default class NobLwc03DisplayComm extends LightningElement {
    @api flexipageRegionWidth;
    @api recordId;

    labels = {unread, read};
    sujet;
    versionData;
    titre;
    nom;
    buttonLabel;
    @track isDisabled=false;
    alreadyRead = false;
    isOnPortal = false;

    siteURL;
    alreadyRendered = true;
    
    @wire(getRecord, {recordId : '$recordId', fields : [dateLue, reception]})
    checkLue({error, data}){
        if (error) {
            console.error('error:', 
                error.body.errorCode, 
                error.body.message
            );
        } else if (data) {
            //console.log('data', JSON.stringify(data));
            if (data.fields.NOB_DateLue__c.value === null && data.fields.NOB_Reception__c.value === 'NonLue'){
                this.setButtonEnable();
            }
            else{
                this.setButtonDisable();
            }
        }
    }


    renderedCallback(){
        if (this.alreadyRendered){
            this.displayComm();
            this.alreadyRendered = false;
        }

    }




    setButtonEnable(){
        this.buttonLabel = this.labels.unread;
        this.isDisabled = false;
    }

    setButtonDisable(){
        this.buttonLabel = this.labels.read;
        this.isDisabled = true;
    }

    displayComm(){
        const params = {'recordId' : this.recordId};
        renderCommunication(params).then(result =>{
            console.log(JSON.stringify(result))
            this.sujet = result.sujet;
            this.versionData = result.contenu;
            this.titre = result.titre;
            this.nom = result.nom;
            this.isOnPortal = result.userPortail;

        }).catch(err =>{
            console.error(JSON.stringify(err));
        });
    }


    handleLue(){
        const params = {'recordId' : this.recordId};
        //console.log('inside handleLue');

        setLue(params).then(result =>{
            //console.log('x',JSON.stringify(result));
            if (result){

                this.setButtonDisable();
            }
        }).catch(err =>{
            console.error(JSON.stringify(err));
        });
    }

}