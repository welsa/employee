/*
@description       : 
@author            : KPA
@group             : 
@last modified on  : 08-31-2020
@last modified by  : KPA
Modifications Log 
Ver   Date         Author   Modification
1.0   08-28-2020   KPA   Initial Version
*/
public with sharing class VFC27_AccountReferences {
    public Account currentAcc {get; set;}
 
    public Id AccId;
    
    public list <AccountRef__c> lstAccRef {get; set;}
    
    public VFC27_AccountReferences(ApexPages.StandardController sc){
        
        lstAccRef= new List<AccountRef__c>();
        
        currentAcc = (Account) sc.getRecord();
        AccId = currentAcc.Id;
        
        String newId = AccId + '%';
        
        String query = 'SELECT Name,InternalReference__c,systemCalling__c,	ExternalReference__c,SendingAccepted__c,SubstitutionAccepted__c,VinCheckAuto__c,CreatedBy.Name,LastModifiedBy.Name,LastModifiedDate FROM AccountRef__c WHERE  InternalReference__c  LIKE   \''+newId+'\' OR InternalReference__c LIKE \''+newId.left(15)+'\' ' ;
        
        
        
        lstAccRef= Database.Query(query);  
        system.debug('~~~~~~~~:'+query);
        system.debug('~~~~~~~~:'+lstAccRef);
    }
    
    
    
    
}