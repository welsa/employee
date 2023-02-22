/*************************************************************************************
Class Name - DataManager
Version - 1.0
Created Date - 02 APR 2015
Function - Class to Create Data for Unit tests and for FCn presentations

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias             02/04/2015  Original Version
**************************************************************************************/
public class DataManager{

  /*  public static void loadData(){

        Account distributor = new Account(
            name='Oscaro Distribution',
            referenceNumber__c='Oscaro Distribution',
      //      OrderEmail__c='accxx1@live.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId()
        );
        insert distributor;
            
        Account bs1 = new Account(
        name='Auto Sueco',
        referenceNumber__c='AUTO-SUECO',
        ShippingCountry = 'France',
        ShippingPostalCode= '92000',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Body Shop').getRecordTypeId()
        );
        insert bs1;
        Claim__c claim1 = new Claim__c(name='CLAIM-002');
        insert claim1;
        Asset__c a1 = new Asset__c(name='ASSET-001',claim__c=claim1.id, manufacturer__c='RENAULT',model__c='Twingo', builddate__c=date.newInstance(2009,12,27));
        insert a1;
        Assessment__c ass1 = new Assessment__c(
            name='ASSESSMENT-0001',
            status__c='NEW',
            claim__c=claim1.id,
            asset__c = a1.id,
            entity__c = 'AXA Direct',
            //distributor__c =distributor.id,
            AssessmentNumber__c ='AUTO-SUECO-0001',
            recordTypeID = [select id from RecordType where name = 'NewAssessment'][0].id,
            BodyShop__c=bs1.id);        
        //Assessment__c ass2 = new Assessment__c
        //(name='second assesment', claim__c=claim1.id, asset__c = a.id, AssessmentNumber__c ='ext2', BodyShop__c=bs.id);        

        insert ass1;
        
        PartList__c pl1 = new PartList__c(
            Name            = 'PL-00001',
            PartNumber__c   = 'REF-00001',
            Price__c        = 100.0,
            Description__c  = 'Left Door Renault Twingo',
            assessment__c = ass1.id,
            status__c = 'READY'
        );
        PartList__c pl2 = new PartList__c(
            Name            = 'PL-00002',
            PartNumber__c   = 'REF-00002',
            Price__c        = 50.0,
            Description__c  = 'Locker Left Door Renault Twingo',
            assessment__c = ass1.id,
            status__c = 'READY'
        );
        PartList__c pl3 = new PartList__c(
            Name            = 'PL-00003',
            PartNumber__c   = 'REF-00003',
            Price__c        = 150.0,
            Description__c  = 'Front Left Light Renault Twingo',
            assessment__c = ass1.id,
            status__c = 'READY'
        );
        List<PartList__c> listPartList = new List<PartList__c>();        
        listPartList.add(pl1);
        listPartList.add(pl2);
        listPartList.add(pl3);

        
        //2nd assessment
        Account bs2 = new Account(
        name='Versailles-Automobile',
        referenceNumber__c='Versailles-Automobile',
        ShippingCountry = 'France',
        ShippingPostalCode= '92000',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Body Shop').getRecordTypeId()
        );
        insert bs2;
        Claim__c claim2 = new Claim__c(name='CLAIM-003');
        insert claim2;
        Asset__c a2 = new Asset__c(name='ASSET-002',claim__c=claim1.id, manufacturer__c='CITROEN',model__c='C4 DS', builddate__c=date.newInstance(2010,8,15));
        insert a2;
        Assessment__c ass2 = new Assessment__c(
            name='ASSESSMENT-0002',
            status__c='NEW',
            claim__c=claim2.id,
            asset__c = a2.id,
            entity__c = 'AXA Direct',
            //distributor__c =distributor.id,
            AssessmentNumber__c ='Versailles-0001',
            recordTypeID = [select id from RecordType where name = 'NewAssessment'][0].id,
            BodyShop__c=bs2.id);
        
        insert ass2;
                    
       
        PartList__c pl4 = new PartList__c(
            Name            = 'PL-00004',
            PartNumber__c   = 'REF-00004',
            Price__c        = 100.0,
            Description__c  = 'Engine Head C4DS',
            assessment__c = ass2.id,
            status__c = 'READY'
        );
        PartList__c pl5 = new PartList__c(
            Name            = 'PL-00005',
            PartNumber__c   = 'REF-00005',
            Price__c        = 50.0,
            Description__c  = 'Back Mirror',
            assessment__c = ass2.id,
            status__c = 'READY'
        );
        PartList__c pl6 = new PartList__c(
            Name            = 'PL-00006',
            PartNumber__c   = 'REF-00006',
            Price__c        = 150.0,
            Description__c  = 'Breaker Front Kit',
            assessment__c = ass2.id,
            status__c = 'READY'
        );        
        listPartList.add(pl4);
        listPartList.add(pl5);
        listPartList.add(pl6);
        
        insert listPartList;
        
    }

    public static void deleteData(){
        
        delete [select id from partlist__c];    
        delete [select id from assessment__c];
        delete [select id from asset__c ];
        delete [select id from claim__c ];
        delete [select id from account  ];
        delete [select id from purchaseorder__c];
    }   
    
    public static void deleteDataOwner(){
        
        delete [select id from partlist__c      where assessment__r.ownerid = :Userinfo.getUserId()];    
        delete [select id from PrerequisiteOrder__c];
        delete [select id from invoice__c       where ownerid = :Userinfo.getUserId()];
        delete [select id from assessment__c    where ownerid = :Userinfo.getUserId()];
        delete [select id from asset__c         where ownerid = :Userinfo.getUserId()];
        delete [select id from claim__c         where ownerid = :Userinfo.getUserId()];
        delete [select id from account          where ownerid = :Userinfo.getUserId()];
        delete [select id from purchaseorder__c where ownerid = :Userinfo.getUserId()];
    }    */
}