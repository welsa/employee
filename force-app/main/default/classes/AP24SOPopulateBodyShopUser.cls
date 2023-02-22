/*************************************************************************************
Class Name - AP24PSOPopulateDistributorUser
Version - 1.0
Created Date - 16 DEC 2015
Function - Class to populate the DistributorContact__c on SO before inserting an SO

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* Brayan Nunhuck 16/12/2015  Original Version
*************************************************************************************/
public class AP24SOPopulateBodyShopUser { 
    public static void populateBodyShopContact(List<PrerequisiteOrder__c> l_SalesOrders, Set<Id> s_BodyShops){
        //map to store Id of ContactUser__c on account and a list of account
        //Note: a list of account is use as there can be Multiple account with same ContactUser
        Map<Id,Account> m_Accounts = new Map<Id,Account>();

        //Query account that are related to the distributor field present on SO
        for (Account a : [Select Id,ContactUser__c from Account where Id in :s_BodyShops order by CreatedDate DESC])
        {
            m_Accounts.put(a.Id, a);
        }

        //loop in trigger.new to assign the DistributorContact__c
        for (PrerequisiteOrder__c so : l_SalesOrders)
        {
            if (m_Accounts.containsKey(so.BodyShop__c))
            {
                //assign DistributorContact__c
                //Assumption : Taking the most recent account that has been created
                so.BodyShopContact__c = m_Accounts.get(so.BodyShop__c).ContactUser__c;
            }
        }
    }

}