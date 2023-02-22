import { LightningElement, api, track} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor';



export default class B2g_BookingSlotsMgt extends LightningElement {

    //List of responses returned by WS MuleSoft (getAvailabilities) 
    @api responses = '[{"brandCode":"FPB","errors":[{"title":null,"type":"ANY","detail":""}]},{"brandCode":"MPB","mobileServices":{"interventionDuration":60,"immobilisationDuration":180},"partnerSlots":{"isMobileServices":true,"partnerBranch":{"id":"9311","name":"MondialPare-BriseSaint-Denis","address":"33avenueduColonelFabien","postalCode":"93200","city":"SAINT-DENIS"},"days":[{"day":"20220209","status":"O","openingTime":"2022-02-09T08:00:00Z","closingTime":"2022-02-09T14:15:00Z","availableSlots":[{"id":"25262","start":"2022-02-09T08:00:00Z"},{"id":"25266","start":"2022-02-09T09:00:00Z"},{"id":"25248","start":"2022-02-09T13:00:00Z"},{"id":"25269","start":"2022-02-09T14:00:00Z"}]},{"day":"20220208","status":"O","openingTime":"2022-02-08T08:00:00Z","closingTime":"2022-02-08T14:15:00Z","availableSlots":[{"id":"25249","start":"2022-02-08T08:00:00Z"},{"id":"25250","start":"2022-02-08T09:00:00Z"},{"id":"25253","start":"2022-02-08T13:00:00Z"},{"id":"25254","start":"2022-02-08T14:00:00Z"}]},{"day":"20220207","status":"O","openingTime":"2022-02-07T08:00:00Z","closingTime":"2022-02-07T14:15:00Z","availableSlots":[{"id":"25229","start":"2022-02-07T08:00:00Z"},{"id":"25230","start":"2022-02-07T09:00:00Z"},{"id":"25233","start":"2022-02-07T13:00:00Z"},{"id":"25234","start":"2022-02-07T14:00:00Z"}]},{"day":"20220129","status":"O","openingTime":"2022-01-29T07:00:00Z","closingTime":"2022-01-29T08:15:00Z","availableSlots":[{"id":"25061","start":"2022-01-29T07:00:00Z"},{"id":"25051","start":"2022-01-29T08:00:00Z"}]},{"day":"20220128","status":"O","openingTime":"2022-01-28T08:00:00Z","closingTime":"2022-01-28T14:15:00Z","availableSlots":[{"id":"25050","start":"2022-01-28T08:00:00Z"},{"id":"25054","start":"2022-01-28T09:00:00Z"},{"id":"25070","start":"2022-01-28T13:00:00Z"},{"id":"25058","start":"2022-01-28T14:00:00Z"}]},{"day":"20220205","status":"O","openingTime":"2022-02-05T07:00:00Z","closingTime":"2022-02-05T08:15:00Z","availableSlots":[{"id":"25195","start":"2022-02-05T07:00:00Z"},{"id":"25205","start":"2022-02-05T08:00:00Z"}]},{"day":"20220127","status":"O","openingTime":"2022-01-27T08:00:00Z","closingTime":"2022-01-27T14:15:00Z","availableSlots":[{"id":"25052","start":"2022-01-27T08:00:00Z"},{"id":"25056","start":"2022-01-27T09:00:00Z"},{"id":"25071","start":"2022-01-27T13:00:00Z"},{"id":"25059","start":"2022-01-27T14:00:00Z"}]},{"day":"20220204","status":"O","openingTime":"2022-02-04T08:00:00Z","closingTime":"2022-02-04T14:15:00Z","availableSlots":[{"id":"25206","start":"2022-02-04T08:00:00Z"},{"id":"25202","start":"2022-02-04T09:00:00Z"},{"id":"25186","start":"2022-02-04T13:00:00Z"},{"id":"25198","start":"2022-02-04T14:00:00Z"}]},{"day":"20220126","status":"O","openingTime":"2022-01-26T08:00:00Z","closingTime":"2022-01-26T14:15:00Z","availableSlots":[{"id":"25053","start":"2022-01-26T08:00:00Z"},{"id":"25057","start":"2022-01-26T09:00:00Z"},{"id":"25029","start":"2022-01-26T13:00:00Z"},{"id":"25060","start":"2022-01-26T14:00:00Z"}]},{"day":"20220203","status":"O","openingTime":"2022-02-03T08:00:00Z","closingTime":"2022-02-03T14:15:00Z","availableSlots":[{"id":"25204","start":"2022-02-03T08:00:00Z"},{"id":"25200","start":"2022-02-03T09:00:00Z"},{"id":"25185","start":"2022-02-03T13:00:00Z"},{"id":"25197","start":"2022-02-03T14:00:00Z"}]},{"day":"20220125","status":"O","openingTime":"2022-01-25T08:00:00Z","closingTime":"2022-01-25T14:15:00Z","availableSlots":[{"id":"25031","start":"2022-01-25T08:00:00Z"},{"id":"25033","start":"2022-01-25T09:00:00Z"},{"id":"25039","start":"2022-01-25T13:00:00Z"},{"id":"25041","start":"2022-01-25T14:00:00Z"}]},{"day":"20220202","status":"O","openingTime":"2022-02-02T08:00:00Z","closingTime":"2022-02-02T14:15:00Z","availableSlots":[{"id":"25203","start":"2022-02-02T08:00:00Z"},{"id":"25199","start":"2022-02-02T09:00:00Z"},{"id":"25227","start":"2022-02-02T13:00:00Z"},{"id":"25196","start":"2022-02-02T14:00:00Z"}]},{"day":"20220124","status":"O","openingTime":"2022-01-24T08:00:00Z","closingTime":"2022-01-24T14:15:00Z","availableSlots":[{"id":"25030","start":"2022-01-24T08:00:00Z"},{"id":"25032","start":"2022-01-24T09:00:00Z"},{"id":"25038","start":"2022-01-24T13:00:00Z"},{"id":"25040","start":"2022-01-24T14:00:00Z"}]},{"day":"20220201","status":"O","openingTime":"2022-02-01T08:00:00Z","closingTime":"2022-02-01T14:15:00Z","availableSlots":[{"id":"25225","start":"2022-02-01T08:00:00Z"},{"id":"25223","start":"2022-02-01T09:00:00Z"},{"id":"25217","start":"2022-02-01T13:00:00Z"},{"id":"25215","start":"2022-02-01T14:00:00Z"}]},{"day":"20220210","status":"O","openingTime":"2022-02-10T08:00:00Z","closingTime":"2022-02-10T14:15:00Z","availableSlots":[{"id":"25261","start":"2022-02-10T08:00:00Z"},{"id":"25265","start":"2022-02-10T09:00:00Z"},{"id":"25280","start":"2022-02-10T13:00:00Z"},{"id":"25268","start":"2022-02-10T14:00:00Z"}]},{"day":"20220131","status":"O","openingTime":"2022-01-31T08:00:00Z","closingTime":"2022-01-31T14:15:00Z","availableSlots":[{"id":"25226","start":"2022-01-31T08:00:00Z"},{"id":"25224","start":"2022-01-31T09:00:00Z"},{"id":"25218","start":"2022-01-31T13:00:00Z"},{"id":"25216","start":"2022-01-31T14:00:00Z"}]},{"day":"20220119","status":"O","openingTime":"2022-01-19T08:00:00Z","closingTime":"2022-01-19T14:15:00Z","availableSlots":[{"id":"25004","start":"2022-01-19T08:00:00Z"},{"id":"25000","start":"2022-01-19T09:00:00Z"},{"id":"25028","start":"2022-01-19T13:00:00Z"},{"id":"24997","start":"2022-01-19T14:00:00Z"}]},{"day":"20220216","status":"O","openingTime":"2022-02-16T08:00:00Z","closingTime":"2022-02-16T14:15:00Z","availableSlots":[{"id":"25395","start":"2022-02-16T08:00:00Z"},{"id":"25391","start":"2022-02-16T09:00:00Z"},{"id":"25409","start":"2022-02-16T13:00:00Z"},{"id":"25388","start":"2022-02-16T14:00:00Z"}]},{"day":"20220215","status":"O","openingTime":"2022-02-15T08:00:00Z","closingTime":"2022-02-15T14:15:00Z","availableSlots":[{"id":"25408","start":"2022-02-15T08:00:00Z"},{"id":"25407","start":"2022-02-15T09:00:00Z"},{"id":"25404","start":"2022-02-15T13:00:00Z"},{"id":"25403","start":"2022-02-15T14:00:00Z"}]},{"day":"20220214","status":"O","openingTime":"2022-02-14T08:00:00Z","closingTime":"2022-02-14T14:15:00Z","availableSlots":[{"id":"25428","start":"2022-02-14T08:00:00Z"},{"id":"25427","start":"2022-02-14T09:00:00Z"},{"id":"25424","start":"2022-02-14T13:00:00Z"},{"id":"25423","start":"2022-02-14T14:00:00Z"}]},{"day":"20220212","status":"O","openingTime":"2022-02-12T07:00:00Z","closingTime":"2022-02-12T08:15:00Z","availableSlots":[{"id":"25270","start":"2022-02-12T07:00:00Z"},{"id":"25260","start":"2022-02-12T08:00:00Z"}]},{"day":"20220211","status":"O","openingTime":"2022-02-11T08:00:00Z","closingTime":"2022-02-11T14:15:00Z","availableSlots":[{"id":"25259","start":"2022-02-11T08:00:00Z"},{"id":"25263","start":"2022-02-11T09:00:00Z"},{"id":"25279","start":"2022-02-11T13:00:00Z"},{"id":"25267","start":"2022-02-11T14:00:00Z"}]},{"day":"20220122","status":"O","openingTime":"2022-01-22T07:00:00Z","closingTime":"2022-01-22T08:15:00Z","availableSlots":[{"id":"24996","start":"2022-01-22T07:00:00Z"},{"id":"25006","start":"2022-01-22T08:00:00Z"}]},{"day":"20220121","status":"O","openingTime":"2022-01-21T08:00:00Z","closingTime":"2022-01-21T14:15:00Z","availableSlots":[{"id":"25007","start":"2022-01-21T08:00:00Z"},{"id":"25003","start":"2022-01-21T09:00:00Z"},{"id":"24987","start":"2022-01-21T13:00:00Z"},{"id":"24999","start":"2022-01-21T14:00:00Z"}]},{"day":"20220120","status":"O","openingTime":"2022-01-20T08:00:00Z","closingTime":"2022-01-20T14:15:00Z","availableSlots":[{"id":"25005","start":"2022-01-20T08:00:00Z"},{"id":"25001","start":"2022-01-20T09:00:00Z"},{"id":"24986","start":"2022-01-20T13:00:00Z"},{"id":"24998","start":"2022-01-20T14:00:00Z"}]}]}}]';        
    @api isSAD  = false;   //Boolean check if is HomeIntervention


    @api country;
    @api selectedBooking;
    @api selectedBranchPostalCode;
    @api selectedBranchId;
    @api selectedBranchCode;
    @api timezones;

    @track selectedBranch;
    @track bookings = [];
    @track bookingsMap;

    @api isDebug = false;

    @api parentRepairCenters = [];
    @track repCenterToPoints = new Map();
    @track repCenterCodeToName = new Map();

    get getBookings(){
        let bookings = this.bookings.map((item, index) => {
            const branch = item.branch;
            const timezone = item.timezone;
            const branchName = item.branchName
            const hasSlots = item.hasSlots;
            const ranking = item.ranking;
            const response = item.response;
            const firstAvailSlot = item.firstAvailSlot;
            const icon = item.hasSlots ? "custom:custom31" : "standard:first_non_empty";
            const selectionClass = item.branch === this.selectedBranch ? 'lgc-bg slds-box  selectedItem' : 'lgc-bg slds-box';
            const disableClass = item.hasSlots ? "" : "disabled"
            return {
                branch,
                branchName,
                ranking,
                response,
                selectionClass,
                hasSlots,
                firstAvailSlot,
                disableClass,
                icon,
                timezone
            };
        });
        return bookings;
    }

    get layoutItemSize(){
        return FORM_FACTOR == 'Small' ? 10 : 3;
    }

    connectedCallback(){
        if(this.isDebug) console.log('connectedCallback b2g_BookingSlotsMgt START');


        if(this.isDebug) console.log('parentRepairCenters: ', JSON.stringify(this.parentRepairCenters));
        if(this.parentRepairCenters != null){
            this.repCenterToPoints  = new Map(this.parentRepairCenters.map(element => [element.b2g_BrandCodeId__c, element.B2G_RankingPoints__c]));   
            if(this.isDebug) console.log('repCenterToPoints: ', this.repCenterToPoints);

            this.repCenterCodeToName  = new Map(this.parentRepairCenters.map(element => [element.b2g_BrandCodeId__c, element.Name]));   
            if(this.isDebug) console.log('repCenterCodeToName: ', this.repCenterCodeToName);
        }
     

        this.timezones = JSON.parse(this.timezones);
        if(this.isDebug) console.log('timezones: ', this.timezones);

        try {
            //Parse JSON Responses
            if(this.responses != null){
                this.responses = JSON.parse(this.responses);
                if(this.responses.length > 0){

                    //Loop eacg response
                    for(let i = 0; i < this.responses.length; i++){
                        let booking  = this.responses[i];
                        if(this.isDebug) console.log('booking' + i , booking);

                        if(booking.partnerSlots != null && booking.partnerSlots.days != null && booking.partnerSlots.days.length > 0){
                            let bookingPartnerSlots = booking.partnerSlots;
                            let bookingDays = bookingPartnerSlots.days;
                            let formattedBookingDays = [];

                            //Get branchName
                            let brandName = booking.partnerSlots.partnerBranch.name;

                            //Get branch Id
                            let branchCode = booking.partnerSlots.partnerBranch.id;

                            //Get branch postal code
                            let branchPostalCode = booking.partnerSlots.partnerBranch.postalCode;

                            let timezone;
                            if(this.timezones != null){
                                let postalCodePrefix = branchPostalCode.substring(0,3);
                                if(this.isDebug) console.log('postalCodePrefix: ', postalCodePrefix)
                                if(this.timezones[postalCodePrefix] != null){
                                    timezone = this.timezones[postalCodePrefix]   
                                }else{
                                    if(this.isDebug) console.log('timezone for country ', this.country)
                                    timezone = this.timezones[this.country]   
                                }
                            }

                            //Get branchCode 
                            let brandCode = booking.brandCode;
                            
                            //Format date
                            for(let i = 0; i < bookingDays.length; i++){
                                let temp1 = bookingDays[i];
                                let unformatteddate = temp1.day;
                                let formattedDateDay = new Date(unformatteddate.substring(0,4), unformatteddate.substring(4,6) -1 , unformatteddate.substring(6,8));
                                temp1.day = formattedDateDay;
                                formattedBookingDays.push(temp1);
                            }
                            formattedBookingDays = this.sortArrayObjects(formattedBookingDays, 'day')


                            let firstAvailSlot;

                            //Get first available slot
                            for(let i =0 ; i < formattedBookingDays.length; i++){
                                if(formattedBookingDays[i] != null 
                                    && formattedBookingDays[i].availableSlots[0] != null 
                                    && formattedBookingDays[i].availableSlots[0].start != null){
                                        if(this.isDebug) console.log('first available slots found in iteration ', i);
                                        firstAvailSlot = formattedBookingDays[i].availableSlots[0].start;
                                        break;
                                }
                            }

                            if(firstAvailSlot == null || firstAvailSlot == undefined){
                                if(this.isDebug) console.log('booking has no partnerSlots / days');
                                if(this.isDebug) console.log('brandCode: ', booking.brandCode);
                                if(this.isDebug) console.log('partnerBrand: ', booking.partnerBrand);
                                let branchCode = booking.brandCode != null ? booking.brandCode : booking.partnerBrand;
                                if(branchCode != null){
                                    this.bookings.push(this.createBookingNoSlots(branchCode))
                                }
                                if(this.isDebug) console.log('bookings: ', this.bookings)
                                break;
                            }

                            //firstAvailSlot = formattedBookingDays[0].availableSlots[0].start
                            if(this.isDebug) console.log('first available slot: ', firstAvailSlot);

                            if(this.isDebug) console.log('formattedBookingDays after sorting ', formattedBookingDays);

                            bookingPartnerSlots.days = formattedBookingDays;
                            booking.partnerSlots = bookingPartnerSlots;
                            if(this.isDebug) console.log('updated booking ', booking)

                            this.bookings.push(this.createBooking(brandCode, brandName, firstAvailSlot, branchCode, branchPostalCode, booking, timezone))
                            if(this.isDebug) console.log('bookings: ', this.bookings)

                        }else{
                            if(this.isDebug) console.log('booking has no partnerSlots / days');
                            if(this.isDebug) console.log('brandCode: ', booking.brandCode);
                            if(this.isDebug) console.log('partnerBrand: ', booking.partnerBrand);
                            let branchCode = booking.brandCode != null ? booking.brandCode : booking.partnerBrand;
                            if(branchCode != null){
                                this.bookings.push(this.createBookingNoSlots(branchCode))
                            }
                            if(this.isDebug) console.log('bookings: ', this.bookings)
                        }
                    }
                }else{
                    if(this.isDebug) console.log('No repsonses');
                }
            }else{
                if(this.isDebug) console.log('response null');
                return
            }

            if(this.bookings != null){
              this.bookingsMap  = new Map(this.bookings.map(element => [element.branch, element]));
              this.bookings = this.sortBookingsByRanking(this.bookings, 'ranking')
            }

        }
        catch (e) {
            if(this.isDebug) console.log('Exception in connectedCallback: ', e);
        }
    }

    setBookingSelection(event){
        if(this.isDebug) console.log('booking selection START')
        let selectedBranch = event.currentTarget.id;
        this.selectedBranch = selectedBranch.substring(0,selectedBranch.lastIndexOf('-'));
        if(this.isDebug) console.log('selectedBranch:  ', this.selectedBranch);
        
        let bookingsMap = this.bookingsMap;
        if(this.isDebug) console.log('bookingsMap: ', this.bookingsMap);

        let selectedBookingObj = bookingsMap.get(this.selectedBranch);
        if(this.isDebug) console.log('selectedBookning: ', this.selectedBooking);

        this.selectedBooking = JSON.stringify(selectedBookingObj.response);
        if(this.isDebug) console.log('selectedBookingResp: ', this.selectedBooking);

        this.selectedBranchId = selectedBookingObj.branchId;
        this.selectedBranchCode = selectedBookingObj.branch;
        if(this.isDebug) console.log('selectedBranchId: ', this.selectedBranchId)
        if(this.isDebug) console.log('selectedBranchCode: ', this.selectedBranchCode)


        this.selectedBranchPostalCode = selectedBookingObj.branchPostalCode;
        if(this.isDebug) console.log('selectedBranchId: ', this.selectedBranchId)

        this.navigateNext();
    }
    
    createBookingNoSlots(branch){
        let booking = new Object();
        booking.branch = branch;
        booking.branchName = this.getBranchName(branch);
        booking.hasSlots = false;
        booking.ranking = this.getRanking(branch);
        if(this.isDebug) console.log('booking has no slots: ', booking);
        return booking;
    }

    createBooking(branch, branchName, firstAvailSlot, branchId, branchPostalCode, response, timezone){
        let booking = new Object();
        booking.hasSlots = true;
        booking.firstAvailSlot = firstAvailSlot;
        booking.branchId = branchId;
        booking.branchPostalCode = branchPostalCode;
        booking.id = branch;
        booking.branch = branch;
        booking.branchName = this.getBranchName(branch);
        booking.response = response;
        booking.ranking = this.getRanking(branch);
        booking.timezone = timezone
        if(this.isDebug) console.log('booking: ', booking);
        return booking;
    }

    sortArrayObjects(list, key){
        return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
    }

    sortBookingsByRanking(list, key){
        return list.sort((a, b) => (a[key] < b[key]) ? 1 : -1);
    }

    getRanking(branch){
        let repCenterToPoints = this.repCenterToPoints;
        return repCenterToPoints.get(branch);
    }

    getBranchName(branch){
        let repCenterCodeToName = this.repCenterCodeToName;
        return repCenterCodeToName.get(branch);
    }

    navigateNext(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        try {
            this.dispatchEvent(navigateNextEvent);
            if(this.isDebug) console.log('dispatchedSuccesfully');
        } catch (ex) {
            if(this.isDebug) console.log('Exception: ' + ex);
        }
    }
}