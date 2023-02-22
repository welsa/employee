/***
* @author      Telesio Consultant
* @date        20/12/2021
* @description Wrapper class to sort (Account) repair centers
*              by ranking points (b2g_Points__c)
* @group       B2G 
* @see         
***/
global class b2g_accSortWrapper implements Comparable {

    public Account acc;
    
    // Constructor
    public b2g_accSortWrapper(Account ac) {
        acc = ac;
    }
    
    global Integer compareTo(Object compareTo) {
        // Cast argument to AccountWrapper
        b2g_accSortWrapper compareToacc = (b2g_accSortWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        
        if(acc.b2g_points__c < compareToacc.acc.b2g_points__c) { returnValue = 1;} 
        else if (acc.b2g_points__c > compareToacc.acc.b2g_points__c) { returnValue = -1;} 
        else if ((acc.b2g_points__c == null) && (compareToacc.acc.b2g_points__c != null)){ returnValue = -1;} 
        else if ((acc.b2g_points__c != null) && (compareToacc.acc.b2g_points__c == null)){ returnValue = 1; }        
        return returnValue;       
    }
}