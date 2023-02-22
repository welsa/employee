/*************************************************************************************
Class Name - NOB_AssetTriggerHandler
Version - 1.0
Created Date - 07-10-2021


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     07-10-2021  RSIW - 9164 : BESOIN DE LA VUE DE LISTE DU DETAIL DES VR SAISIS DANS LE PORTAIL REP DANS LE PORTAIL MY PREFIKAR
* Hansraj M     15/12/2021  RSIW - 11173 : Gestion du parc VR hors prefikar/ Prefikar
*************************************************************************************/
public class NOB_AssetTriggerHandler {
	
/**
 * THIS DEV NOT USED ANYMORE - HMO - 15-12-2021 - 11173
 */

    // private boolean bIsExecuting = false;
	// private integer iBatchSize = 0;
    
    // public NOB_AssetTriggerHandler(Boolean executing, Integer size) {
    //     this.bIsExecuting = executing;
    //     this.iBatchSize = size;
    // }
    
    // public void NOBonAfterInsert(List<Asset> lstNewAsset, Map<Id,Asset> mapOldAsset){
    //    List<Asset> lstAsset = new List<Asset>();
    //     for (Asset asset : lstNewAsset){
    //         if (asset.NOB_vehiculePrefikar__c){
                
    //             	lstAsset.add(asset);
                
    //         }
           
    //     }
        
    //     if (lstAsset != null && lstAsset.size() > 0){
    //         NOB_AP63_ManageAssets.updateAsset(lstAsset);
    //     }
    // }
    
    //  public void NOBonAfterUpdate(List<Asset> lstNewAsset, Map<Id,Asset> mapOldAsset){
    //     List<Asset> lstAsset = new List<Asset>();
    //      for(Asset asset : lstNewAsset){
    //          if (asset.NOB_vehiculePrefikar__c != mapOldAsset.get(asset.Id).NOB_vehiculePrefikar__c){
    //              lstAsset.add(asset);
    //          }
    //      }
         
    //      if (lstAsset != null && lstAsset.size() > 0){
    //          NOB_AP63_ManageAssets.updateAsset(lstAsset);
    //      }
    // }
}