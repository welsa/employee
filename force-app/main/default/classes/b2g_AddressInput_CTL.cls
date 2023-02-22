/***
* @author      Telesio Consultant
* @date        09/12/2021
* @description Controller class for b2g lwc cmps to 
               makes REST callouts to Google places API
* @group       B2G 
* @see         
***/
public with sharing class b2g_AddressInput_CTL {


    /***
    * @description WS Google callout to get places suggestions
    * @param       input place name
    * @return      JSON Stringified callout response of place suggestions
    * @exception   none special.
    ***/
    @AuraEnabled
	public static string getSuggestions(String input, String key, String token, String searchableCountries) {
        //return '{"predictions":[{"description":"Montluçon,France","matched_substrings":[{"length":5,"offset":0}] ,"place_id":"ChIJC1ulycSn8EcR8L_ry688CQQ","reference":"ChIJC1ulycSn8EcR8L_ry688CQQ","structured_formatting":{"main_text":"Montluçon","main_text_matched_substrings":[{"length":5,"offset":0}],"secondary_text":"France"},"terms":[{"offset":0,"value":"Montluçon"},{"offset":11,"value":"France"}],"types":["locality","political","geocode"]},{"description":"Montlhéry,France","matched_substrings":[{"length":5,"offset":0}],"place_id":"ChIJ3Y9tMtzZ5UcRwEOLaMOCCwQ","reference":"ChIJ3Y9tMtzZ5UcRwEOLaMOCCwQ","structured_formatting":{"main_text":"Montlhéry","main_text_matched_substrings":[{"length":5,"offset":0}],"secondary_text":"France"},"terms":[{"offset":0,"value":"Montlhéry"},{"offset":11,"value":"France"}],"types":["locality","political","geocode"]},{"description":"Montluel,France","matched_substrings":[{"length":5,"offset":0}],"place_id":"ChIJJ8lL4-a59EcRToCv5v9Ghi4","reference":"ChIJJ8lL4-a59EcRToCv5v9Ghi4","structured_formatting":{"main_text":"Montluel","main_text_matched_substrings":[{"length":5,"offset":0}],"secondary_text":"France"},"terms":[{"offset":0,"value":"Montluel"},{"offset":10,"value":"France"}],"types":["locality","political","geocode"]},{"description":"Montlouis-sur-Loire,France","matched_substrings":[{"length":5,"offset":0}],"place_id":"ChIJL7qibsHN_EcRgIo4BdfIDQQ","reference":"ChIJL7qibsHN_EcRgIo4BdfIDQQ","structured_formatting":{"main_text":"Montlouis-sur-Loire","main_text_matched_substrings":[{"length":5,"offset":0}],"secondary_text":"France"},"terms":[{"offset":0,"value":"Montlouis-sur-Loire"},{"offset":21,"value":"France"}],"types":["locality","political","geocode"]},{"description":"Montlingen,Oberriet,Switzerland","matched_substrings":[{"length":5,"offset":0}],"place_id":"ChIJB68VFbg9m0cRkMmSiFHXkoY","reference":"ChIJB68VFbg9m0cRkMmSiFHXkoY","structured_formatting":{"main_text":"Montlingen","main_text_matched_substrings":[{"length":5,"offset":0}],"secondary_text":"Oberriet,Switzerland"},"terms":[{"offset":0,"value":"Montlingen"},{"offset":12,"value":"Oberriet"},{"offset":22,"value":"Switzerland"}],"types":["sublocality_level_1","sublocality","political","geocode"]}],"status":"OK"}';
        //French countries: 'fr', 'gp', 're', 'mq', 'gf', 'nc', 'yt', 'pf'
        //&components=country:fr%7Ccountry:gp%7Ccountry:re%7Ccountry:mq%7Ccountry:nc
        System.debug('getSuggestions START with input: ' +input +  ' searchableCountries: ' +  searchableCountries);

        String countriesToSearch = searchableCountries != null ? ('&components=' +searchableCountries) : '';

        String endpoint = 'callout:Google_places/autocomplete/json?input=' + EncodingUtil.urlEncode(input, 'UTF-8')
                        + countriesToSearch
                        + '&key=' + key
                        + '&sessiontoken=' + token;
        System.debug('getSuggestions Endpoint: ' + endpoint);

        HttpResponse resp = b2g_CalloutManager.getResponse(endpoint, 'GET', 120000, null, null);
        String respBody = resp.getBody();
        return respBody;
	}

    /***
    * @description WS callout to get specific details (e.g. Geocode) about a place
    * @param       placeId
    * @return      JSON Stringified callout response of placeId
    * @exception   none special.
    ***/
    @AuraEnabled
	public static string getPlaceDetails(String placeId, String key, String token) {
        //return '{"html_attributions":[],"result":{"address_components":[{"long_name":"Montluçon","short_name":"Montluçon","types":["locality","political"]},{"long_name":"Allier","short_name":"Allier","types":["administrative_area_level_2","political"]},{"long_name":"Auvergne-Rhône-Alpes","short_name":"Auvergne-Rhône-Alpes","types":["administrative_area_level_1","political"]},{"long_name":"France","short_name":"FR","types":["country","political"]},{"long_name":"03100","short_name":"03100","types":["postal_code"]}],"formatted_address":"03100Montluçon,France","geometry":{"location":{"lat":46.3415466,"lng":2.6019912},"viewport":{"northeast":{"lat":46.37243051520585,"lng":2.645854509180803},"southwest":{"lat":46.31313187177363,"lng":2.570027143532611}}},"icon":"https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png","icon_background_color":"#7B9EB0","icon_mask_base_uri":"https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet","name":"Montluçon","place_id":"ChIJC1ulycSn8EcR8L_ry688CQQ","reference":"ChIJC1ulycSn8EcR8L_ry688CQQ","types":["locality","political"],"url":"https://maps.google.com/?q=03100+Montlu%C3%A7on,+France&ftid=0x47f0a7c4c9a55b0b:0x4093cafcbebbff0","utc_offset":60,"vicinity":"Montluçon"},"status":"OK"}';
        System.debug('placeId : ' +  placeId);
        String endpoint = 'callout:Google_places/details/json?placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
                        //+ '&components=country:fr'
                        + '&key=' + key
                        + '&sessiontoken=' + token;
            
        HttpResponse resp = b2g_CalloutManager.getResponse(endpoint, 'GET', 120000, null, null);
	    String respBody = resp.getBody();
	    return respBody;
	}
}