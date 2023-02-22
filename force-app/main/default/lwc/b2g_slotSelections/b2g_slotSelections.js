import { LightningElement, api, track, wire } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class tstMaps extends LightningElement {

    @api selectedSlot = false;
    @api availableDays;
    @api selectedDay = '';
    @api selectedSlotId;
    @api selectedBranchId;
    @api slotDays;
    @api btnAppointmentLabel = 'Prendre RDV';
    @api selectedSlotTime;
    @api timezones;
    @api timezone;

    @api country;

    @api slotOpenStatus;
    @api slotClosedStatus;
    @api slotExcpClosedStatus;

    @api response; 
    @api availableDates = [];
    @api availableDatesDisplayed = [];
    @track slotIdToDatetime = new Map();
    @track noSlotsFound = false;

    @api isDebug = false;
    @api noSlots_Header = "😥 Aucun slot disponible pour ce glacier";
    @api noSlots_Body = "Veuillez en sélectionner un autre. Merci";

    @api process_FPB_timeAdjustment = false;

    get disablePrevBtn(){
        return this.availableDates.map(function(e) { return e}).indexOf(this.availableDatesDisplayed) == 0 ? true : false;
    }

    get disableNextBtn(){
        return this.availableDates.map(function(e) { return e}).indexOf(this.availableDatesDisplayed) == (this.availableDates.length - 1) ? true : false;
    }


    get getAvailableDateSlots(){
        let availableDateSlots = [];
        for(let i = 0; i < this.availableDatesDisplayed.length; i++){
            let temp1 = this.availableDatesDisplayed[i];
            temp1.statusClass = (temp1.status == 'O' || temp1.status == 'Ouvert') ? 'slds-text-color_success' : 'slds-text-color_error';
            temp1.status = this.getDayStatus(temp1.status);
            temp1.hasTwoOpenings = (temp1.openingTime2 == null || temp1.openingTime2 == undefined) ? false : true;

            try{
                var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                let formattedDate = this.isDate(temp1.day) ? temp1.day : new Date(temp1.day);
                temp1.formmattedDate = '🗓️ '+ formattedDate.toLocaleDateString("fr-FR", options);
            }catch(e){
                if(this.isDebug) console.log('Exception: ', e)
            }

            let availableSlots = this.availableDatesDisplayed[i].availableSlots.map((item, index) => {
                const id = item.id;
                const start = item.start;
                const selectionClass = item.id === this.selectedSlotId ? 'lgc-bg slds-box  selectedItem' : 'lgc-bg slds-box';
                return {
                    id,
                    selectionClass,
                    start,
                };
            });

            //Filter out duplicates by slotId
            availableSlots = availableSlots.filter((v,i,a)=>a.findIndex(t=>(t.id===v.id))===i);

            //Filter out duplicates by start date
            availableSlots = availableSlots.filter((v,i,a)=>a.findIndex(t=>(t.start===v.start))===i);

            temp1.availableSlots = availableSlots;
            availableDateSlots.push(temp1);
        }
        return availableDateSlots;
    }
    


    get isSelectedSlot(){
        return this.selectedSlotId != null;
    }

    get slotColumnSize(){
        return FORM_FACTOR == 'Small' ? 4 : 2;
    }

    get btnColumnSize(){
        return FORM_FACTOR == 'Small' ? 2 : 1;
    }

    getDayStatus(status){
        switch(status){
            case 'O':
                return this.slotOpenStatus;
            case 'C':
                return this.slotClosedStatus;
            case 'EC':
                return this.slotExcpClosedStatus
            default:
                return this.slotOpenStatus;
        }
    }

    get numOfDaysPerScreen(){
        return FORM_FACTOR == 'Small' ? 5 : 5;
    }

    get isMobileScreen(){
        return FORM_FACTOR == 'Small';
    }

    get isSlotsAvailable(){
        return this.response !== undefined && this.response !== null && this.response.constructor == Object;
    }

    connectedCallback() {
        if(this.isDebug) console.log('connectedCallback b2g_slotSelections START')
        try{
            if(this.response != null){
                this.response = JSON.parse(this.response);
                this.response = this.response[0] != null ? this.response[0] : this.response;
            }else{
                if(this.isDebug) console.log('response null');
                return;
            }
            if(this.isDebug) console.log('response: ', this.response);

            if(this.response != null && this.response.partnerSlots != null && this.response.partnerSlots.days != null && this.response.partnerSlots.days.length > 0){
                this.slotDays = this.response.partnerSlots.days;
                if(this.isDebug) console.log('slots days: ', this.slotDays)
            }else{
                if(this.isDebug) console.log('No slots found ');
                this.noSlotsFound = true;
            }


            //Get branchId
            if(this.response != null && this.response.partnerSlots != null && this.response.partnerSlots.partnerBranch != null && this.response.partnerSlots.partnerBranch.id != null){
                this.selectedBranchId = this.response.partnerSlots.partnerBranch.id;
            }
            if(this.isDebug) console.log('selectedBranchId: ', this.selectedBranchId );

            //Get proper timezone
            if(this.timezones != null && this.response != null && this.response.partnerSlots != null 
                    && this.response.partnerSlots.partnerBranch != null && this.response.partnerSlots.partnerBranch.postalCode != null){
                
                this.timezones = JSON.parse(this.timezones);
                let postalCodePrefix = this.response.partnerSlots.partnerBranch.postalCode.substring(0,3);
                if(this.isDebug) console.log('postalCodePrefix: ', postalCodePrefix)
                if(this.isDebug) console.log('timezones:', this.timezones)
                if(this.timezones[postalCodePrefix] != null){
                    if(this.isDebug) console.log('timezone in postal code')
                    this.timezone = this.timezones[postalCodePrefix]   
                }else{
                    if(this.isDebug) console.log('timezone not found in list');
                    if(this.isDebug) console.log('timezone for country ', this.country);
                    this.timezone = this.timezones[this.country];
                }
            }
            if(this.isDebug) console.log('timezone: ', this.timezone)



            //Set proper slot times for FPB
            //if(this.process_FPB_timeAdjustment){ 
                // console.log('processing slot time adjustement for FPB START')
                // for(let i = 0; i < this.slotDays.length; i++){
                //     let temp1 = this.slotDays[i];
                //     let availableSlots = temp1.availableSlots;
                //     console.log('availableSlots: ', availableSlots)

                //     for(let y = 0 ; y < availableSlots.length; y++){
                //         let start = availableSlots[i].start;
                //         console.log('initial start: ', start);
                        
                //         if(new Date(start) > new Date("2022-03-27")){
                //             start = start.replace("+01:00","+02:00")
                //             console.log('new start', start);
                //         }
                //         //availableSlots[i].start = start;
                //     }
                // }
                // console.log('processing slot time adjustement for FPB END')
            //}
            

            //Merge common slots (Especially for FPB Cases)
            let mapBookingdays = new Map();
            for(let i = 0; i < this.slotDays.length; i++){
                if(mapBookingdays.get(this.slotDays[i].day) == undefined){
                    if(this.isDebug) console.log('item do not exist in mapBookingdays, adding...')
                    mapBookingdays.set(this.slotDays[i].day, this.slotDays[i]);
                }else{
                    if(this.isDebug) console.log('item do exist in mapBookingdays, merging...')

                    let temp1 = this.slotDays[i].availableSlots;
                    if(this.isDebug) console.log('temp1', temp1)

                    if(this.isDebug) console.log('item2 in map: ', mapBookingdays.get(this.slotDays[i].day))
                    let mapBookingValue = mapBookingdays.get(this.slotDays[i].day)
                    let temp2 = mapBookingValue.availableSlots;
                    if(this.isDebug) console.log('temp2', temp2);

                    let mergeArray = temp1.concat(temp2)
                    if(this.isDebug) console.log('mergeArray unsorted', mergeArray);

                    mergeArray = this.sortArrayObjects(mergeArray, 'start');
                    if(this.isDebug) console.log('mergeArray sorted', mergeArray);

                    let temp1_opening = this.slotDays[i].openingTime;
                    if(this.isDebug) console.log('temp1_opening', temp1_opening)
                    let temp1_closing = this.slotDays[i].closingTime;
                    if(this.isDebug) console.log('temp1_closing', temp1_closing)
                    let temp2_opening = mapBookingdays.get(this.slotDays[i].day).openingTime;
                    if(this.isDebug) console.log('temp2_opening', temp2_opening)
                    let temp2_closing = mapBookingdays.get(this.slotDays[i].day).closingTime;
                    if(this.isDebug) console.log('temp2_closing', temp2_closing)

                    if(new Date(temp1_opening) < new Date(temp2_opening)){
                        this.slotDays[i].openingTime = temp1_opening;
                        this.slotDays[i].closingTime = temp1_closing;
                        this.slotDays[i].openingTime2 = temp2_opening;
                        this.slotDays[i].closingTime2 = temp2_closing;
                    }else{
                        this.slotDays[i].openingTime = temp2_opening;
                        this.slotDays[i].closingTime = temp2_closing;
                        this.slotDays[i].openingTime2 = temp1_opening;
                        this.slotDays[i].closingTime2 = temp1_closing;

                    }
                    
                    this.slotDays[i].availableSlots = mergeArray;
                    mapBookingdays.set(this.slotDays[i].day, this.slotDays[i]);
                }
            }
            if(this.isDebug) console.log('mapBookingdays: ', mapBookingdays)
            if(this.isDebug) console.log('array of mapBookingdays',  Array.from(mapBookingdays.values()))
            this.slotDays = Array.from(mapBookingdays.values());
            if(this.isDebug) console.log('this.slotdays: ', this.slotDays)


            //Instantiate proper dates 
            let formattedBookingDays = [];
            for(let i = 0; i < this.slotDays.length; i++){
                let temp1 = this.slotDays[i];
                let unformatteddate = temp1.day;
                if(!this.isDate(unformatteddate)){
                    let formattedDateDay = new Date(unformatteddate.substring(0,4), unformatteddate.substring(4,6) -1 , unformatteddate.substring(6,8));
                    temp1.day = formattedDateDay;
                }else{
                    temp1.day = new Date(unformatteddate);
                }
                formattedBookingDays.push(temp1);
            }
            //Order booking days
            formattedBookingDays = this.sortArrayObjects(formattedBookingDays, 'day');
            this.slotDays = formattedBookingDays;


            
            //Create groups of slots to display based on screen size
            for(let i = 0 ; i < this.slotDays.length; i += this.numOfDaysPerScreen){
                let arr = [];
                //if(this.isDebug) console.log('i : ', i);
                for(let y = i;  y < (i + this.numOfDaysPerScreen) && y < this.slotDays.length; y++){
                    //if(this.isDebug) console.log('y : ', y);
                    if(this.slotDays[y] != null){
                        arr.push(this.slotDays[y])
                    }
                }
                this.availableDates.push(arr);
            }
            
            //Create map of SlotId > DateTime
            for(let i = 0; i < this.slotDays.length; i++){
                //if(this.isDebug) console.log('i: ' + i);
                for(let y = 0 ; y < this.slotDays[i].availableSlots.length; y++){
                    //if(this.isDebug) console.log('y: ' +  y)
                    this.slotIdToDatetime.set(this.slotDays[i].availableSlots[y].id, this.slotDays[i].availableSlots[y].start);
                }
            }


            if(this.isDebug) console.log('this.slotIdToDatetime', this.slotIdToDatetime)
            if(this.isDebug) console.log('numOfDaysPerScreen :', this.numOfDaysPerScreen)
            if(this.isDebug) console.log('availableDates :', this.availableDates)
            this.availableDatesDisplayed = this.availableDates[0];
            if(this.isDebug) console.log('availableDatesDisplayed: ', this.availableDatesDisplayed);
            if(this.isDebug) console.log('connectedCallback END')

        }catch(e){
            if(this.isDebug) console.log('Exception in connectedCallback: ', e);
        }
    }


    setSlotSelection(event){
        if(this.isDebug) console.log('slot selection START')

        let selectedSlotId = event.currentTarget.id;
        selectedSlotId = selectedSlotId.substring(0,selectedSlotId.lastIndexOf('-'));

        if(selectedSlotId == this.selectedSlotId){
            //Handle Unselect
            this.selectedSlotId = null;
            this.selectedSlotTime = null;
        }else{
            //Handle Select
            this.selectedSlotId = selectedSlotId;
            this.selectedSlotTime = this.slotIdToDatetime.get(this.selectedSlotId);
            if(this.isDebug) console.log('slotIdToDatetime: ', this.slotIdToDatetime);
            if(this.isDebug) console.log('selectedSlotId: ', this.selectedSlotId);

            this.handleAppointment(event);

        }

        if(this.isDebug) console.log('slot selection END')
    }

    handleNextDay(event){
        let availableDates = this.availableDates;
        let currentIndex = availableDates.map(function(e) { return e }).indexOf(this.availableDatesDisplayed);
        if(this.isDebug) console.log('currentIndex', currentIndex)

        if(currentIndex < (availableDates.length - 1)){
            let newIndex = currentIndex + 1;
            if(this.isDebug) console.log('newIndex: ', newIndex);
            this.availableDatesDisplayed = this.availableDates[newIndex];
        }
    }

    handlePreviousDay(event){
        let availableDates = this.availableDates;
        let currentIndex = availableDates.map(function(e) { return e }).indexOf(this.availableDatesDisplayed);
        if(this.isDebug) console.log('currentIndex', currentIndex)

        if(currentIndex > 0){
            let newIndex = currentIndex - 1;
            if(this.isDebug) console.log('newIndex: ', newIndex);
            this.availableDatesDisplayed = this.availableDates[newIndex];
        }
    }

    handleAppointment(event){
        const navigateNextEvent = new FlowNavigationNextEvent();
        try {
            this.dispatchEvent(navigateNextEvent);
            if(this.isDebug) console.log('dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) console.log('Exception: ' + ex);
        }
    }


    isDate(date){
        return (new Date(date) !== "Invalid Date") && !isNaN(new Date(date));
    }

    sortArrayObjects(list, key){
        return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
    }

}