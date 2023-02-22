/*************************************************************************************
Class Name - NOB_AP63_ManageAssets
Version - 1.0
Created Date - 07-10-2021


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     07-10-2021  RSIW - 9164 : BESOIN DE LA VUE DE LISTE DU DETAIL DES VR SAISIS DANS LE PORTAIL REP DANS LE PORTAIL MY PREFIKAR
* Hansraj M     15/12/2021  RSIW - 11173 : Gestion du parc VR hors prefikar/ Prefikar
*************************************************************************************/


/**
 * THIS DEV NOT USED ANYMORE - HMO - 15-12-2021 - 11173
 */

public with sharing class NOB_AP63_ManageAssets {
//     public static void updateAsset(List<Asset> lstAsset){
//         Map<Id, Asset> mapAsset = new Map<Id, Asset>();

//         for(Asset asset : lstAsset){
//             Asset assetz= null;
//             if (asset.NOB_vehiculePrefikar__c){
//               	assetz= new Asset(Id = asset.Id);
//                 assetz.NOB_VRPrefikar__c = asset.AccountId;
//                 //set.NOB_VRPrefikar__c = asset.AccountId;
//             }
//             else{
//                assetz= new Asset(Id = asset.Id);
//                assetz.NOB_VRPrefikar__c = null;
//             }
            
//             if (assetz != null){
//             	mapAsset.put(assetz.Id, assetz);
//             }
//         }
        
//         if (mapAsset != null && mapAsset.size() > 0){
//             System.debug('££££ mapAsset'+ mapAsset);
//             update mapAsset.values();
//         }
//     }
}