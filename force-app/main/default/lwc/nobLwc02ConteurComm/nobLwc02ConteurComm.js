import { LightningElement, wire,api } from 'lwc';
import portailBaseP from '@salesforce/community/basePath';
import getUrl from '@salesforce/apex/NOB_LC54_ConteurComm.getUrl';
import listView from '@salesforce/label/c.NOB_CommListView';
import userId from '@salesforce/user/Id';
import getUnreadComm from '@salesforce/apex/NOB_LC54_ConteurComm.getUnreadComm';
import communicationLabel from '@salesforce/label/c.NOB_CommNonLues';


export default class NobLwc02ConteurComm extends LightningElement {
    @api flexipageRegionWidth;
    commNonLue = 0;
    labels ={listView};
    error;
    siteUrl;
    label = {communicationLabel};

    connectedCallback(){
        this.calcCommunication();
    }

    calcCommunication(){
        //count number of comm non lue
        const params = {'userId' : userId};
        console.log(JSON.stringify(params));
        getUnreadComm(params).then(result =>{
            this.commNonLue = result;
            //console.log('£ result' + JSON.stringify(result));
        }).catch(err =>{
            console.error(JSON.stringify(err));
        });
    }

    openCommLink(){
        getUrl({}).then(results =>{
            if (results != null){
                this.siteUrl = results + portailBaseP + '/recordlist/NOB_Communication__c'+'/'+ this.labels.listView;
                //console.log('£ siteUrl '+ JSON.stringify(this.siteUrl));
                window.location.href = this.siteUrl;
            }
        }).catch(error=>{
            console.error(JSON.stringify(error));
        });
    }

    handleAddColor(){
        let div = this.template.querySelector('.clickDiv');
        div.style.background = "#006572";
    }

    handleRemoveColor(){
        let div = this.template.querySelector('.clickDiv');
        div.style.background = "#027180";
        div.style.transitionDelay = "0.15s";
    }

}