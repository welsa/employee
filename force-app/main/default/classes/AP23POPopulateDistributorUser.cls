/*************************************************************************************
Class Name - AP23PPOPoulateDistributorUser
Version - 1.0
Created Date - 16 DEC 2015
Function - Class to populate the DistributorContact__c on PO before inserting an PO

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* Brayan Nunhuck 16/12/2015  Original Version
*************************************************************************************/
public class AP23POPopulateDistributorUser { 
    public static void populateDistributorContact(List<PurchaseOrder__c> l_PurchaseOrders, Set<Id> s_Distributors){
        //map to store Id of ContactUser__c on account and a list of account
        //Note: a list of account is use as there can be Multiple account with same ContactUser
        Map<Id,Account> m_Accounts = new Map<Id,Account>();
        
        /**** C-001435 
        // set of assessment
        Set<Id> s_Assessment = new Set<Id>();
        
        //map Assessment
        Map<Id,Assessment__c> m_Assessments = new Map<Id,Assessment__c>();
        //set Bodyshop
        Set<Id> s_BodyShops = new Set<Id>();

        //loop in po to build a set of Assessment Id
        //this will serve to retrieve bodyshop on assessment to be put on PO
        for (PurchaseOrder__c po : l_PurchaseOrders)
        {
            if(po.Assessment__c != null){
                s_Assessment.add(po.Assessment__c);
            }
        }

        if (s_Assessment.size() > 0 )
        {
            for (Assessment__c a : [Select Id,BodyShop__c from Assessment__c where Id in :s_Assessment])
            {
                m_Assessments.put(a.Id,a);
                s_BodyShops.add(a.BodyShop__c);
            }
        }
        */

        //Query account that are related to the distributor field present on PO
        for (Account a : [Select Id,ContactUser__c from Account where Id in :s_Distributors/* C-001435  OR Id in :s_BodyShops*/ order by CreatedDate DESC])
        {
            m_Accounts.put(a.Id,a);
        }

        //loop in trigger.new to assign the DistributorContact__c
        for (PurchaseOrder__c po : l_PurchaseOrders)
        {
            if (m_Accounts.containsKey(po.Distributor__c))
            {
                //assign DistributorContact__c
                //Assumption : Taking the most recent account that has been created
                po.DistributorContact__c = m_Accounts.get(po.Distributor__c).ContactUser__c;
            }

            /* C-001435 
            if (m_Assessments.containsKey(po.Assessment__c))
            {
                //get assessment related to PO
                Assessment__c assessment = m_Assessments.get(po.Assessment__c);

                if (assessment.BodyShop__c != null)
                {
                    if (m_Accounts.containsKey(assessment.BodyShop__c))
                    {
                        po.BodyShopContact__c = m_Accounts.get(assessment.BodyShop__c).ContactUser__c;
                    }
                }
            } */
        }
    }
}