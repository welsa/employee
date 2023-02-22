/*
----------------------------------------------------------------------
-- - Name          : ASPISHomePage
-- - Author        : AMI
-- - Description   : Controller for page ASPISHomePage
--
-- Maintenance History:
--
-- Date      	Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 10-JAN-2019  AMI   1.0        Initial version
-- 27-MAY-2019  WCH   1.1        C-002781 R4 Spain
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class ASPISHomePage{
	public String locale {get; set;}
	public string caseObjPrefix {get; set;}
	public string assObjPrefix {get; set;}
	public string soObjPrefix {get; set;}
	public string feedSize {get;set;}
	public string cntryCode 													   	= '';
	public map <string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo 	= new map <string,CountryCodeInformationsMapping__c>();
	public string communityId {get;set;}

	public ASPISHomePage() {
		system.debug('##ASPISHomePage Constructor');

		locale 																		= '';
		
		//query connected user info
		for(User usr : [SELECT id,CountryCode,LocaleSidKey
						from User
						where id = :UserInfo.getUserId() ]){
			locale 																	= usr.LocaleSidKey;
			cntryCode 																= usr.CountryCode;
		}

        caseObjPrefix																= system.label.caseObjPrefix;
		assObjPrefix																= system.label.assObjPrefix;
		soObjPrefix																	= system.label.soObjPrefix;

		//initialise community id
		communityId																	= '';

		//get community id
		for(Network nt : [select id,name,UrlPathPrefix 
							from Network
							where /*(NOT UrlPathPrefix Like 'r3')*/ Description like '%R4%'/*WCH 27/05/2019 C-002781 */]){
			communityId 															= nt.id;
		}

		//get country code mappping
		allConfigCountryCodeInfo 													= CountryCodeInformationsMapping__c.getAll();

		if(string.isNotBlank(cntryCode) && allConfigCountryCodeInfo.containsKey(cntryCode.toUpperCase())){
			if(allConfigCountryCodeInfo.get(cntryCode.toUpperCase()).DisplayFeedSize__c != null){
				feedSize																	= string.valueOf(integer.valueOf(allConfigCountryCodeInfo.get(cntryCode.toUpperCase()).DisplayFeedSize__c));
			}else{
				feedSize																	= '9';
			}
		}else{
			feedSize																		= '9';
		}
	}
}