/*
* @author:      Telesio Consultant
* @created:     19/01/2021
* @description: Invocable Apex class used in flow B2G - SelfCare to retrieve all 
*               timezones; to be used in the flow to set booking time/date based on the timezones
*/
public with sharing class b2g_getTimezones {
    /***
    * @description	Method to prepare callout to retrieve slots 
    * @param	    NONE
    * @return		List<Stirng> JSON stringified map of postalcodes prefixes to timezones 
    * @exception   	None
    ***/   
    @InvocableMethod(label='[b2g] get timezones' description='Get a JSON stringified map of timezones and associated postal codes prefixes' callout=false)
    public static List<String> getTimezones() {

        Map<String, Object> postalCodeToTimezone = new Map<String,Object>();
        for(b2g_Timezone__mdt tz : [SELECT  b2g_PostalCodePrefix__c, b2g_timezone__c FROM B2G_Timezone__mdt WITH SECURITY_ENFORCED]){
            postalCodeToTimezone.put(tz.b2g_PostalCodePrefix__c, tz.b2g_timezone__c);
        }
        System.debug(LoggingLevel.DEBUG, 'postalCodeToTimezone: ' + JSON.serialize(postalCodeToTimezone));

        if(postalCodeToTimezone != null){
            return new List<String>{JSON.serialize(postalCodeToTimezone)};
        }

        return null;
    }
}