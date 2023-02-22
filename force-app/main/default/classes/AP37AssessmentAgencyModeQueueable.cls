/*************************************************************************************
Class Name - AP37AssessmentAgencyModeQueueable
Version - 1.0
Created Date - 26 APR 2017
Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Dourga U  	 26/04/2017		Original version: C-001904
* Dourga U     04/01/2018     C-002135 : Agency Mode V2
* Dourga U     04/09/2018    Modificcations to add Direct sourcing
* Welsa C      03/06/2019    C-003199 : Painting & Annexes in Agency Mode for Selected BS
* Welsa C      02/06/2020    C-003728 : AlphaStore for FR Covid-19
*********************************************************************************************************/
public without sharing class AP37AssessmentAgencyModeQueueable{
    public static void setPOAgencyMode(map<Id,list<PurchaseOrder__c>> mapAssIdlistPO, set<Id> setDistID){
        system.debug('###### setPOAgencyMode Start');
        system.debug('###### mapAssIdlistPO' + mapAssIdlistPO);
        system.debug('###### setDistID' + setDistID);

        map<Id,Account> mapDistributors = new Map<Id, Account>([SELECT Id, CarBrandsSuppliedAgency__c
                                                                 FROM   Account
                                                                 WHERE  Id IN: setDistID
                                                                 AND    RecordType.DeveloperName =: ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor]);

        //DUN 04/09/2018 Modificcations to add Direct sourcing
        map<Id,Assessment__c> mapAssessment = new Map<Id, Assessment__c>([SELECT Id, BodyShop__r.CarBrandsSuppliedAgency__c, BodyShop__r.Feature__c
                                                                                ,BodyShop__c,Name /*WCH 03/06/2019 C-003199 */
                                                                          FROM   Assessment__c
                                                                          WHERE  Id IN: mapAssIdlistPO.keySet()]);
        //WCH 03/06/2019 C-003199 : Painting & Annexes in Agency Mode for Selected BS
        String PaintingOrAnnexes = '';
        Set<Id> setBSID = new Set<Id>();
        for(Id theAssId : mapAssessment.keyset()){
          setBSID.add(mapAssessment.get(theAssId).BodyShop__c);
          PaintingOrAnnexes=mapAssessment.get(theAssId).Name.substringBefore('-').equals(System.label.Painting.toUpperCase())?ASPISConstants.DIRECTORDER_RT_DeveloperName_Painting : ASPISConstants.DIRECTORDER_RT_DeveloperName_Annexes;
        }
        map<String,DirectOrder__c> mapDO = new Map<String, DirectOrder__c>();
        for(DirectOrder__c theDO : [SELECT Id, Agency_mode__c,BodyShop__c,Distributor__c FROM DirectOrder__c WHERE RecordType.DeveloperName=:PaintingOrAnnexes AND Distributor__c IN: setDistID AND BodyShop__c IN :setBSID]){
          mapDO.put(theDO.BodyShop__c+'-'+theDO.Distributor__c,theDO);
        }
        system.debug('###### mapDO' + mapDO);

        for(Id assId : mapAssIdlistPO.keySet()){
            for(PurchaseOrder__c po : mapAssIdlistPO.get(assId)){
                if(mapDistributors.containsKey(po.Distributor__c) && 
                   mapDistributors.get(po.Distributor__c).CarBrandsSuppliedAgency__c != null && 
                   mapDistributors.get(po.Distributor__c).CarBrandsSuppliedAgency__c.contains(po.Brand__c) &&
                   mapAssessment.size() > 0 &&
                   mapAssessment.containsKey(assId) && 
                   (mapAssessment.get(assId).BodyShop__r.Feature__c == null ||
                    (mapAssessment.get(assId).BodyShop__r.Feature__c != null &&
                     !mapAssessment.get(assId).BodyShop__r.Feature__c.contains('PilotDirectSourcing'))) && 
                   mapAssessment.get(assId).BodyShop__r.CarBrandsSuppliedAgency__c != null && 
                   mapAssessment.get(assId).BodyShop__r.CarBrandsSuppliedAgency__c.contains(po.Brand__c)

                   //WCH 03/06/2019 C-003199 updated 02/06/2020 C-003728
                   || (String.isNotBlank(po.TECH_AssessmentCountryCode__c) && CountryCodeInformationsMapping__c.getall().containsKey(po.TECH_AssessmentCountryCode__c) && CountryCodeInformationsMapping__c.getall().get(po.TECH_AssessmentCountryCode__c).activateAlphaStoreAgencyMode__c && !mapDO.isEmpty() && mapDO.containsKey(mapAssessment.get(assId).BodyShop__c+'-'+po.Distributor__c) && mapDO.get(mapAssessment.get(assId).BodyShop__c+'-'+po.Distributor__c).Agency_mode__c)
                  ){
                    po.AgencyMode__c = true;
                }
            }
        }
        system.debug('###### setPOAgencyMode End');
    } 
}


/*implements Queueable {

	public map<Id,list<PurchaseOrder__c>> mapAssessIdListPO;
	public set<Id> setDistribID;

	public AP37AssessmentAgencyModeQueueable(map<Id,list<PurchaseOrder__c>> mapAssIdListPO, set<Id> setDistID){
		system.debug('###### AP37AssessmentAgencyModeQueueable Constructor Start');
		mapAssessIdListPO = mapAssIdListPO;
		setDistribID = setDistID;
		system.debug('###### AP37AssessmentAgencyModeQueueable Constructor End');
	}

	public void execute(QueueableContext context) {
		system.debug('###### AP37AssessmentAgencyModeQueueable execute Start');
		list<Assessment__c> listAssessmentToUpdate = new list<Assessment__c>();
        map<Id,Account> mapDistributors = new Map<Id, Account>([SELECT Id, CarBrandsSuppliedAgency__c
                                                                 FROM   Account
                                                                 WHERE  Id IN: setDistribID
                                                                 AND    RecordType.DeveloperName =: ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor]);

        for(Id assId : mapAssessIdListPO.keyset()){
            for(PurchaseOrder__c po : mapAssessIdListPO.get(assId)){
                if(mapDistributors.containsKey(po.Distributor__c) && 
                   mapDistributors.get(po.Distributor__c).CarBrandsSuppliedAgency__c != null && 
                   mapDistributors.get(po.Distributor__c).CarBrandsSuppliedAgency__c.contains(po.Brand__c)){
                    listAssessmentToUpdate.add(new Assessment__c(Id = po.Assessment__c, AgencyMode__c = true));
                    break;
                }
            }
        }

        if(listAssessmentToUpdate.size() > 0){
            update listAssessmentToUpdate;
        }
		system.debug('###### AP37AssessmentAgencyModeQueueable execute End');
		
	}
}*/