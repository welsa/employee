import { LightningElement, api, track} from 'lwc';
import findSuggestions from '@salesforce/apex/b2g_AddressInput_CTL.getSuggestions';
import getPlaceDetail from '@salesforce/apex/b2g_AddressInput_CTL.getPlaceDetails';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';
import pubsub from 'c/pubsub'

    // The delay used when debouncing event handlers before firing the event
    const DELAY = 400;

export default class b2g_AddressInput extends LightningElement {

    @api searchLabel            = "Trouvez un centre proche de chez vous..";
    @api searchAddressLabel     = "Recherchez votre adresse..";
    @api btnCurrLocationLabel   = "Utiliser ma position";
    @api HomeInterventionLabel  = "Intervention à domicile ?";
    @api needLoanVehicleLabel   = "Besoin d'un véhicule de prêt ?";
    @api AddressLabel = "Adresse";
    @api streetLabel = "Rue";
    @api cityLabel = "Ville";
    @api countryLabel = "Pays";
    @api postalCodeLabel = "Code postal";

    //Google places
    @api key;
    @api searchableCountries;

    @api searchTerm;    //Search term value 
    @api predictions;   //List of predictions retrieved from Google Places REST
    @api place_id

    @api lat;
    @api long;
    @api formatted_address;
    @api country = 'France';
    @api locality;
    @api postal_code;
    @api route;
    @api street_number;

    @api btnAppointmentLabel = 'Prendre RDV'
    @api isDisableApppointment = false;

    @api handleHomeAppointment; //TO DELETE

    @api showPredictions;
    @api showSpinner = false;
    
    @api isSelected_LoanVehicle = false;
    @api isSelected_HomeApt = false;
    variant = "neutral";

    @api isDebug = false;

    @track sessionToken = Date.now() + Math.floor(Math.random() * 100);


    get predictionNotEmpty(){
        return (this.predictions != null && this.predictions.length > 0);
    }

    get showPlaceResult(){
        return (this.lat != null || this.long != null);
    }

    get canShowPredictions(){
        return this.showPredictions
    }

    get isMobileScreen(){
        return (FORM_FACTOR == 'Small');
    }

    get formFactorSize(){
        return (FORM_FACTOR == 'Small') ? "slds-var-m-around_x-small slds-size_5-of-6" : "slds-var-m-around_x-small slds-size_3-of-6";
    }

    get searchPlaceholder(){
        return this.isSelected_HomeApt ? this.searchAddressLabel : this.searchLabel;
    }

    get cantMakeAppointment(){
        return (!this.postal_code || !this.locality  || !this.route || !this.country) ;
    }

    connectedCallback(){ 
        if(this.isDebug) console.log('connectedCallback START ');
        if(this.isDebug) console.log('this.isSelected_HomeApt', this.isSelected_HomeApt)
        if(this.isDebug) console.log('this.isDisableApppointment', this.isDisableApppointment)


        if(this.isDisableApppointment){
            this.isSelected_HomeApt = false;
            this.isSelected_LoanVehicle = false;
        }

        this.variant_HomeApt = !this.isSelected_HomeApt ? "neutral" : "brand";
        this.variant_LoanVehicle = !this.isSelected_LoanVehicle ? "neutral" : "brand";

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.publishHandleHomeAppt();
            this.publishHandleVehicle();
        }, 500);


        if(this.isDebug) console.log('connectedCallback END ');

    }

    handleCLickHomeApt() {
        if(this.isDebug) console.log('handleCLickHomeApt');
        this.isSelected_HomeApt = !this.isSelected_HomeApt;
        this.variant_HomeApt = !this.isSelected_HomeApt ? "neutral" : "brand";
        this.setFocusOnElement("lightning-input.searchInput");
        this.publishHandleHomeAppt();
    }

    handleCLickLoanVehicle() {
        if(this.isDebug) console.log('handleCLickLoanVehicle');
        this.isSelected_LoanVehicle = !this.isSelected_LoanVehicle;
        this.variant_LoanVehicle = !this.isSelected_LoanVehicle ? "neutral" : "brand";
        this.publishHandleVehicle();
    }


    setFocusOnElement(controlIdentity) {
		let timer = window.setTimeout(() => {
			const lControl = this.template.querySelector(controlIdentity);
			lControl.focus();
			if(this.isDebug) console.log("constructor", lControl);
			window.clearTimeout(timer);
		});
	}



    getSuggestions(event) {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        if(this.isDebug) console.log('DELAYING');

        this.showPredictions = event.target.value != null && event.target.value.length != 0;
        this.searchTerm = event.target.value;

        this.delayTimeout = setTimeout(() => {
            if(this.isDebug) console.log('getSuggestions START callout')
            if(this.isDebug) console.log('value',this.searchTerm )
            if(this.searchTerm.length > 2){
                findSuggestions({ 
                    input:  this.searchTerm, 
                    key: this.key, 
                    token : this.sessionToken,
                    searchableCountries : this.searchableCountries  
                })
                .then((result) => {
                    if(this.isDebug) console.log('result: ', result)
                    var resp = JSON.parse(result);
                    this.predictions = resp.predictions;
                    if(this.isDebug) console.log('predictions: ', this.predictions)
                })
                .catch((error) => {
                    //this.error = error;
                    if(this.isDebug) console.log('Error :', error )
                });
            }
        }, DELAY);
    }

    //Make REST Callout to get specific place information from Google based on user selection
    getPlaceInformation(event){ 

        this.showPredictions = false;
        this.place_id  = event.currentTarget.id;
        if(this.isDebug) console.log('event', event)
        if(this.isDebug) console.log('place_id: ', this.place_id);

        if(this.isDebug) console.log('event',event)

        if (this.place_id.includes('-')) this.place_id = this.place_id.substring(0,this.place_id.lastIndexOf('-'));

        if(this.isDebug) console.log('getPlaceInformation START with ' + this.place_id)
        if(this.place_id != null){
            getPlaceDetail({ placeId :  this.place_id, key: this.key, token : this.sessionToken})
            .then((result) => {

                if(this.isDebug) console.log('result2: ', result)
                var result = JSON.parse(result)

                if(result == null){
                    if(this.isDebug) console.log('result is null');
                    return;
                }

                this.lat = result.result.geometry.location.lat;
                this.long = result.result.geometry.location.lng;
                this.formatted_address = result.result.formatted_address;
                this.searchTerm = this.formatted_address;

                //Get detailed address
                let addess_by_type = {};
                for (let i = 0; i < result.result.address_components.length; i++) {
                    let c = result.result.address_components[i];
                    addess_by_type[c.types[0]] = c;
                }

                if(addess_by_type != null ){
                    if(this.isDebug) console.log('addess_by_type: ', addess_by_type)

                    if(addess_by_type['country'] != null){
                        this.country = addess_by_type['country'].long_name;
                    }else{
                        this.country = null;
                    }

                    if(addess_by_type['locality'] != null){
                        this.locality = addess_by_type['locality'].long_name;
                    }else{
                        this.locality = null;
                    }

                    if(addess_by_type['postal_code'] != null){
                        this.postal_code = addess_by_type['postal_code'].long_name;
                    }else{
                        this.postal_code = null;
                    }

                    if(addess_by_type['route'] != null){
                        this.route = addess_by_type['route'].long_name;
                    }else{
                        this.route = null;
                    }

                    if(addess_by_type['street_number'] != null){
                        this.street_number = addess_by_type['street_number'].long_name;
                        this.route = this.street_number + ', ' + this.route;
                    }else{
                        this.street_number = null;
                    }

                    //Publish data to Map (b2g_RepairmenSelection) LWC component
                    this.publish();

                }

                if(this.isDebug) console.log('this.searchTerm', this.searchTerm)
            })
            .catch((error) => {
                //this.error = error;
                if(this.isDebug) console.log('Error :', error )
            });
        }

        if(this.isDebug) console.log('getPlaceInformation END')

    }

     //Get Current Location of user on Map
     getCurrentPosition(){
         if(this.isDebug) console.log('getCurrentPosition')
         this.showSpinner = true;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                this.lat = position.coords.latitude;
                this.long = position.coords.longitude;
                this.publish();
                this.showSpinner = false;
            });
        }
    }


    //Publish long & lat for other cmps to get it
    publish(){
        //Build object message to publish
        let message = {
            "long"       : this.lat,
            "lat"        : this.long,
            "city"       : this.locality,
            "PostalCode" : this.postal_code,
            "country"    : this.country,
            "street"     : this.route
        };
        pubsub.fire('locationPublisher', message);
        if(this.isDebug) console.log('Location published');
    }

    publishHandleVehicle(){
        //Build object message to publish
        let message = {
            "requireLoanVehicle"  : this.isSelected_LoanVehicle
        }
        pubsub.fire('locationPublisher', message);
        if(this.isDebug) console.log('handle vehicle  published');
    }

    publishHandleHomeAppt(){
        //Build object message to publish
        let message = {
            "isSelected_HomeApt"  : this.isSelected_HomeApt
        }
        pubsub.fire('locationPublisher', message);
        if(this.isDebug) console.log('publishHandleHomeAppt  published');
    }

    handleChangeAddress(event){
        this.postal_code = event.target.postalCode;
        this.route = event.target.street;
        this.locality = event.target.city;
        this.country = event.target.country;
    }

    handleAppointment(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        try {
            this.dispatchEvent(navigateNextEvent);
            if(this.isDebug) console.log('navigateNextEvent dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) console.log('Exception: ' + ex);
        }
    }
}