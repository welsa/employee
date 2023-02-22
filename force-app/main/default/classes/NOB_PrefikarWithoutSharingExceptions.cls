/*************************************************************************************
Class Name - NOB_PrefikarWithoutSharingExceptions
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 30-09-2021
Function - This class is used to perform DML for objects which have sharing for prefikar application only
#Ticket  - RSIW : 5863 + 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           30-09-2021   Initial version  
*************************************************************************************/
public without sharing class NOB_PrefikarWithoutSharingExceptions {
    
    public static void updateServContracts(List<servicecontract> lstServicesToUpdate){
       update lstServicesToUpdate;
    }
    
}