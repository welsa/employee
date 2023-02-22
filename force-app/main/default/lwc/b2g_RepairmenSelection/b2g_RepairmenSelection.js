import { LightningElement,api, track, wire} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import pubsub from 'c/pubsub';
import findRepairmen from '@salesforce/apex/b2g_RepaircenterSelection_CTL.getRepaircenters';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import B2G_CSS from '@salesforce/resourceUrl/b2gCSS';



export default class tstMaps extends LightningElement {

    @api maxDistance_ToQueryRepCenters;
    @api maxNumber_RepCentersToDisplay;

    @api markersTitle = "Réparateurs"

    @api isLoaded = false;
    @api btnAppointmentLabel = "Prendre RDV"
    @api selectRepairmenMsg = "Veuillez sélectionner un centre de reparations dans la liste pour prendre RDV";
    @api searchRepairmenMsg = "Recherchez un centre proche de chez vous dans la barre de recherche";
    @api noRepairmenFoundMsg = "😔 Aucun centre de réparateurs trouvé près de chez vous. Veuillez choisir un autre endroit dans la barre de recherche.";
    @api mobileSelectionHelpMsg = 'Choisissez un centre de réparateur dans la liste sous la carte'
    @api selectionMsg;
    @api selectionMsgType;


    @api markers;
    @api mapMarkers;

    @track repairmen;           //List of repairmen (Accounts)
    @track repairmenMap;        //Map of repairmen (Id , Object)
    @track selectedRepairman
    @track requireLoanVehicle;
    @track showMap = false;

    @api latitude;
    @api longitude;
    @api city;
    @api country;
    @api street;
    @api PostalCode;
    @api mySelectedLocation = 'Ma position';
    @api isSelected_HomeApt = false;
    
    @api selectedMarkerValue = null;
    @api isDebug = false;

    isSelected = false;
    variant = ''

    get hasMarkers(){
        return (this.markers != null && this.markers.length > 1)
    }

    get isMarkerSelected(){
        return this.selectedMarkerValue != null;
    }

    get canDisplayListView(){
       return (this.markers != null && this.ƒ.length > 1);
    }

    get getZoomLevel(){
        return (this.markers != null && this.markers.length > 1) ?  "10" : "5"
    }

    get getMapLayoutSize(){
        return this.isSelected  ? "9" : "12"
    }

    get cantMakeAppointment(){
        return (this.selectionMsgType == 'Error');
    }

    get getMsgVariant(){
        var css = "slds-text-align_center slds-m-top_small";
        return this.selectionMsgType != 'Error' ? css + " slds-text-color_success" :  css + " slds-text-color_destructive";
    }

    get usingMobilePhone(){
        return (FORM_FACTOR == 'Small');
    }

    get getSelectionMsg(){
        var msg = this.selectionMsg;
        return (this.selectionMsgType != 'Error' || msg == null) ? msg :  msg.substring(0, msg.indexOf('<br>'));
    }

    handleClick() {
        this.isSelected = !this.isSelected;
    }


    renderedCallback() {
        Promise.all([loadStyle(this, B2G_CSS)]);
    }

    connectedCallback() {
        this.register();
        if(this.isDebug) console.log('Form factor: ', FORM_FACTOR)
        this.showMap = true;
        if(this.longitude != null & this.latitude != null){
            if(this.isDebug) console.log('connectedCallback: calling repairmen on ')
            this.getRepairmen();
        }else{
            //Set initial marker to France
            this.markers = [
                {
                    location: {
                        Country: this.country
                    },
                    value: 'location001'
                },
            ];

        }
        this.isLoaded = true;
	}

    register(){
        pubsub.register('locationPublisher', this.handleEvent.bind(this));
        if(this.isDebug) console.log('event registered: locationPublisher');
    }

    handleEvent(messageFromEvt){
        if(this.isDebug) console.log('event handled ',messageFromEvt);
        if(messageFromEvt != null){
            var evtMsg = messageFromEvt; //JSON.stringify(messageFromEvt, null, '\t');
            if(this.isDebug) console.log('evtMsg', evtMsg);

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
                    this.isSelected_HomeApt = evtMsg.isSelected_HomeApt;
                    this.showMap = !evtMsg.isSelected_HomeApt;
                }
            }
        }
    }

    handleLoanVehicleDisplay(){
        if(this.isDebug) console.log('handleLoanVehicleDisplay START');

        if(this.repairmen == null || this.repairmen.length == 0){
            return;
        }

        this.isLoaded = false;
        var reparateurs = [];
        for(var i = 0; i < this.repairmen.length; i++){
            if(!this.requireLoanVehicle || (this.requireLoanVehicle && this.repairmen[i].Parent.b2g_CanProvideLoanVehicle__c)){
                reparateurs.push(this.repairmen[i]);
            }
        }

        
        if(this.repairmen != null){
            this.markers = reparateurs.map((acc) => {
                if(this.isDebug) console.log('processing element');
                return {
                    location : {
                        Latitude    : acc.BillingLatitude,
                        Longitude   : acc.BillingLongitude,
                        City        : acc.BillingCity,
                        Country     : acc.BillingCountry,
                        PostalCode  : acc.BillingPostalCode,
                        Street      : acc.BillingStreet
                    },

                    // Extra info for tile in list & info window
                    value: acc.b2g_branchId__c,
                    icon: acc.Name != 'You are here' ? 'custom:custom31' : 'standard:avatar',
                    title: acc.Name + ' | 🚗 ' + acc.Description , 
                    description: acc.BillingStreet + ' <br>' + acc.BillingPostalCode + ' - ' + acc.BillingCity + ' <br>📞 : ' + acc.Phone + '</b>'
                }
            });


            this.markers.push({
                    location : {
                        Latitude    : this.latitude,
                        Longitude   : this.longitude,
                        City        : this.city,
                        Country     : this.country,
                        PostalCode  : this.PostalCode,
                        Street      : this.street != null ? this.street :  this.mySelectedLocation
                    },
                    mapIcon : {
                        //path: 'M12 10c-1.104 0-2-.896-2-2s.896-2 2-2 2 .896 2 2-.896 2-2 2m0-5c-1.657 0-3 1.343-3 3s1.343 3 3 3 3-1.343 3-3-1.343-3-3-3m-7 2.602c0-3.517 3.271-6.602 7-6.602s7 3.085 7 6.602c0 3.455-2.563 7.543-7 14.527-4.489-7.073-7-11.072-7-14.527m7-7.602c-4.198 0-8 3.403-8 7.602 0 4.198 3.469 9.21 8 16.398 4.531-7.188 8-12.2 8-16.398 0-4.199-3.801-7.602-8-7.602',
                        //path:"M 45 0 C 32.957 0 23.159 9.798 23.159 21.841 c 0 11.369 8.732 20.732 19.841 21.746 V 88 c 0 1.104 0.896 2 2 2 s 2 -0.896 2 -2 V 43.587 c 11.109 -1.014 19.841 -10.377 19.841 -21.746 C 66.841 9.798 57.043 0 45 0 z M 50.863 20.5 c -3.032 0 -5.5 -2.467 -5.5 -5.5 c 0 -3.033 2.467 -5.5 5.5 -5.5 c 3.032 0 5.5 2.467 5.5 5.5 C 56.364 18.033 53.896 20.5 50.863 20.5 z",
                        path:"m730.940002,1839.630005c-38.765991,-190.300049 -107.116028,-348.670044 -189.903015,-495.440063c-61.406982,-108.869995 -132.543976,-209.359985 -198.363983,-314.939941c-21.972015,-35.242981 -40.93399,-72.476013 -62.046997,-109.052979c-42.216003,-73.137024 -76.444,-157.934998 -74.269012,-267.932007c2.125,-107.473022 33.208008,-193.684021 78.029999,-264.172028c73.718994,-115.934998 197.201019,-210.988983 362.884003,-235.968994c135.466003,-20.423996 262.474976,14.082001 352.54303,66.748001c73.596008,43.03801 130.596008,100.526993 173.915955,168.280014c45.219971,70.716003 76.359985,154.259979 78.969971,263.231964c1.340088,55.830017 -7.799927,107.532043 -20.679932,150.41803c-13.030029,43.408997 -33.98999,79.695007 -52.640015,118.453979c-36.410034,75.658997 -82.050049,144.984009 -127.859985,214.343994c-136.437012,206.609985 -264.496033,417.310059 -320.580017,706.030029z",
                        fillColor: '#0000FF',
                        fill:"blue",
                        fillOpacity: 10,
                        strokeWeight: 1,
                        scale: 0.02,
                    },
                    title: this.mySelectedLocation
                }
            );
        }

        this.isLoaded = true;
        if(this.isDebug) console.log('handleLoanVehicleDisplay END');
    }

    getRepairmen() {
        this.isLoaded = false;
        findRepairmen({ 
            latitude: this.latitude, 
            longitude: this.longitude,
            distancelimit: this.maxDistance_ToQueryRepCenters,
            displaylimits : this.maxNumber_RepCentersToDisplay
        })
            .then((result) => {
                if(this.isDebug) console.log('result: ' , result);
                this.repairmen = result;
                this.repairmenMap = new Map(result.map(element => [element.b2g_branchId__c, element]));
                this.handleLoanVehicleDisplay();
                this.isLoaded = true;

                if(FORM_FACTOR == 'Small' && !this.isSelected_HomeApt){
                    this.showNotification('', this.mobileSelectionHelpMsg , 'info');
                }
            })
            .catch((error) => {
                if(this.isDebug) console.log('Error :', error )
                this.isLoaded = true;
                this.searchRepairmenMsg = this.noRepairmenFoundMsg;
            });
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;  
        const repManMap = this.repairmenMap
        this.selectedRepairman = repManMap.get(this.selectedMarkerValue)
        if(this.isDebug) console.log('selectedMarkerValue : ', this.selectedMarkerValue)

        if(FORM_FACTOR == 'Small'){
           // this.showNotification('', 'Clicquer sur le bouton << Prendre RDV >> au bas pour prendre Rendez vous avec ' + this.selectedRepairman.Name , 'info');
        }
    }

    handleAppointment(event){
        const repManMap = this.repairmenMap
        if(this.isDebug) console.log('selection: ', repManMap.get(this.selectedMarkerValue));
        const navigateNextEvent = new FlowNavigationNextEvent();

        try {
            this.dispatchEvent(navigateNextEvent);
            if(this.isDebug) console.log('dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) console.log('Exception: ' + ex);
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}