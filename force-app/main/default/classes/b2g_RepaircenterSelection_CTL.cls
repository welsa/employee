/***
* @author      Telesio Consultant
* @date        09/12/2021
* @description Controller class for b2g lwc cmps to query repairmen
*              and makes REST callouts to Google places API
* @group       B2G 
* @see         
***/
public with sharing class b2g_RepaircenterSelection_CTL {


    /***
    * @description Query close repairmen (Account) based on given location
    * @param       latitude  - latitude of location
    * @param       longitude - longitude of location
    * @return      List<Account> Repairmen (accounts)  
    * @exception   none special.
    ***/
    @AuraEnabled(cacheable=true)
    public static List<Account> getRepaircenters(Decimal latitude, Decimal longitude, Integer distancelimit, Integer displaylimits) {     
        System.debug(LoggingLevel.INFO, 'getRepairmen START with longitude: ' + longitude + ', latitude: ' + latitude  + 'distancelimit: ' + distancelimit + ', displaylimits: ' + displaylimits );

        //To add this to constant class
        //Suggestion: Create object specific constant class (eg. accountConstants)
        String recTypeId_RepairCentre = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('b2g_RepairCenter').getRecordTypeId();

        Integer proximityDistance = distancelimit != null ? distancelimit  : 50;
        Integer accRetrieveLimits = displaylimits != null ? displaylimits : 10;
        
        List<Account> results = new List<Account>();

        //Get all repair centers
        List<Account> repairCenters = [
            SELECT   Id, Name, BillingLatitude, BillingLongitude, BillingStreet, BillingCity, BillingCountry, 
                     BillingPostalCode, Phone, Parent.b2g_CanProvideLoanVehicle__c, Parent.B2G_RankingPoints__c,
                     Parent.b2g_ProximityRange__c, Parent.b2g_ProximityPoints__c, b2g_points__c, Description,b2g_branchId__c
            FROM     Account
            WHERE    RecordTypeId = :recTypeId_RepairCentre
            AND      DISTANCE(BillingAddress, GEOLOCATION(:latitude,:longitude), 'km') < :proximityDistance
            AND      b2g_branchId__c != NULL
            WITH     SECURITY_ENFORCED
            ORDER BY DISTANCE(BillingAddress, GEOLOCATION(:latitude,:longitude), 'km'), Parent.B2G_RankingPoints__c DESC
            Limit 2000
        ];
        System.debug('getRepairmen repairCenters : ' + repairCenters);


        b2g_accSortWrapper[] accWrappers = new List<b2g_accSortWrapper>();

        Location userLocation = Location.newInstance(latitude, longitude);

        for(Account rc : repairCenters){
            Location accLocation = Location.newInstance(rc.BillingLatitude, rc.BillingLongitude);

            //Get distance between user's location and repair center
            Double DistanceUserAndAcc = Location.getDistance(userLocation, accLocation, 'km');

            Decimal distance = Decimal.valueOf(DistanceUserAndAcc);
            distance = distance.setScale(1);
            rc.Description = distance + ' km';

            //Add brand points, ...
            rc.b2g_points__c = rc.Parent.b2g_RankingPoints__c != null ? rc.Parent.b2g_RankingPoints__c : 0;

            if(DistanceUserAndAcc <= rc.Parent.b2g_ProximityRange__c){
                //Add proximity points if repair center is within range (b2g_ProximityRange)
                rc.b2g_points__c += rc.Parent.b2g_ProximityPoints__c;
            }

            //Add to wrapper class that will do sorting
            accWrappers.add(new b2g_accSortWrapper(rc));
        }


        if(!accWrappers.isEmpty()){
            accWrappers.sort();
            system.debug('accWrappers: '+ accWrappers);
    
            List<Account> accs = new List<Account>();
            for(integer i = 0; (i < accRetrieveLimits && i < accWrappers.size()); i++){
                accs.add(accWrappers[i].acc);
            }     
            system.debug('accs: '+ accs);

            return accs;
        }
        
        System.debug('No accounts retrieved'); 
        return null;
    }
}