/*************************************************************************************
Class Name - VFC10_CloneAssessment
Version - 1.0
Created Date - 15 APRIL 2015
Function - Controller extension for cloning of assessment object 
		   and launching process eligibility, sourcing and offering

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       15/04/2015  Original Version (case 1567 : painting ordering)
**************************************************************************************/
public without sharing class VFC10_CloneAssessment {
	
	//Varaible Declaration
    public ApexPages.StandardController controller {get;set;}
    public Assessment__c ass {get;set;}
    public Id newAssId {get;set;}

	//Initialisation of constructor
    public VFC10_CloneAssessment(ApexPages.StandardController controller) {
        this.controller = controller;
        ass = (Assessment__c)controller.getRecord();
    }

	//Method of type page reference to clone assessment(parent) and partlist(child) and to launch process eligibility, sourcing and offering
    public PageReference cloneAssessment(){
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
        
        list<PurchaseOrder__c> purchaseOrders = new list<PurchaseOrder__c>();
        list<OrderLine__c> orderLines = new list<OrderLine__c>();
        list<PrerequisiteOrder__c> salesOrders = new list<PrerequisiteOrder__c>();
        list<Offer__c> offers = new list<Offer__c>();
        list <MasterRules__c> ruleSet = new list <MasterRules__c>();
		
		//Varaible Declaration
        Assessment__c newAss;
        List<Schema.SObjectField> fieldListAssessment = schema.SObjectType.Assessment__c.fields.getMap().values();
        String AssessmentId = (String)ass.Id;
		
		//Building the string to query from assessment
        String queryAssessment = 'SELECT ';
        for(Schema.SObjectField s : fieldListAssessment){
            if( s.getDescribe().isUpdateable()){
                queryAssessment += s.getDescribe().getName() + ',';  
            }         
        }
        queryAssessment = queryAssessment.substring(0,queryAssessment.length()-1);
        queryAssessment += ' FROM Assessment__c WHERE id =: AssessmentId';
        try{
			//Selecting the assessment to clone
            ass =  Database.query(queryAssessment); 
            
			//Cloning the assessment
            newAss = ass.clone();
            
			//Setting the status to new
            newAss.Status__c = 'NEW';
			
			//Inserting the assessment
            insert newAss;
			
            list <PartList__c> PartListList = new list <PartList__c>();
            list<Schema.SObjectField> fieldListPartList = schema.SObjectType.PartList__c.fields.getMap().values();

			//Building the string to query from part list
            String queryPartList = 'SELECT ';
            for(Schema.SObjectField s : fieldListPartList){
                if(s.getDescribe().isUpdateable()){
                    queryPartList += s.getDescribe().getName() + ',';   
                }            
            }
            queryPartList = queryPartList.substring(0,queryPartList.length()-1);
			queryPartList += ' FROM PartList__c WHERE Assessment__c = : AssessmentId';
			
			//Selecting the part list to clone and adding them to a list
            for(PartList__c pl : Database.query(queryPartList)){
                PartList__c newPL = pl.clone();
                newPL.Assessment__c = newAss.Id;
                PartListList.add(newPL);
            }

			// inserting the part list
            if(PartListList.size() > 0){
                insert PartListList;
            }
        }
        catch (Exception e){	
			//Creating a log if exception occurs
            Utils_ManageLogs.createLogFromException('VFC10_CloneAssessment', 'Assessment__c', e);
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        newAssId = newAss.Id;

        list <Account> listBS = [select Id, OwnerId, Name from Account where Name =: UserInfo.getName()];
        //Querying the inserted assessment to retrieve TechAutoNumber__c to concatenate it with BodyShop Name for fields Name and AssessmentNumber__c
        Assessment__c currAssInserted = [select Id,TechAutoNumber__c,EntityRules__c from Assessment__c where Id =: newAss.Id];

        //Querying MasterRule to check if need of automatic process
        ruleSet = [SELECT Id, Entity__c, Process__c, RuleStatus__c, AutomaticProcess__c
                  FROM MasterRules__c
                  WHERE Process__c    =: 'PAINTING'
                  AND Entity__c       =: newAss.EntityRules__c
                  AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL ];

        Assessment__c currAssToUpdate = new Assessment__c();
        currAssToUpdate.Id = newAss.Id;
        currAssToUpdate.ClaimReference__c = System.label.PartClaimNumber;

        if(listBS.size() > 0){
            currAssToUpdate.Name = 'PAINTING-' + listBS[0].Name + currAssInserted.TechAutoNumber__c;
            currAssToUpdate.AssessmentNumber__c = 'PAINTING-' + listBS[0].Name + currAssInserted.TechAutoNumber__c;
        }
        else{
            currAssToUpdate.Name = 'PAINTING-' + currAssInserted.TechAutoNumber__c;
            currAssToUpdate.AssessmentNumber__c = 'PAINTING-' + currAssInserted.TechAutoNumber__c;
        }
        //update status to ready to execute eligibility and sourcing process
        if(ruleSet.size() > 0 && ruleSet[0].AutomaticProcess__c){
            currAssToUpdate.Status__c = 'READY';
        }
        update currAssToUpdate;

        if(ruleSet.size() > 0 && ruleSet[0].AutomaticProcess__c){

            List <PurchaseOrder__c> listPO = [SELECT Assessment__c, Status__c,(SELECT Id, Suppliable__c FROM OrderLines__r) FROM PurchaseOrder__c WHERE Assessment__c =: currAssInserted.Id];

            //system.debug('##assInserted'+[select Id, Status__c, TECHRulesAppliedDescription__c from Assessment__c where Id =: currAssInserted.Id]);

            for(PurchaseOrder__c po : listPO){
                purchaseOrders.add(po);
                for(OrderLine__c ol : po.OrderLines__r){
                    ol.Suppliable__c = 'YES';
                    ol.OrderType__c = 'FINAL';
                    ol.ExpectedDeliveryDuration__c = '1';
                    //DUN 25/04/2016 To be defined later, for the tim being using labels
                    ol.BodyShopDiscount__c = Double.valueOf(system.Label.PartBS);
                    ol.AXADiscount__c = Double.valueOf(system.Label.PartAS);
                    orderLines.add(ol);
                }
            }

            if(orderLines.size() > 0){
                update orderLines;
            }
            for(PurchaseOrder__c po : listPO){
                po.Status__c = 'ISSUED';
            }

            //update purchase orders to execute offering process
            if(purchaseOrders.size() > 0){
                update purchaseOrders;
            }

            List <PrerequisiteOrder__c> listSO = [select Id, Assessment__c, Status__c, (select Name, Type__c , Accepted__c, Selected__c, DeliveryStatus__c from Offers__r) from PrerequisiteOrder__c where Assessment__c =: currAssInserted.Id];
            
            for(PrerequisiteOrder__c so : listSO){
                for(Offer__c off : so.Offers__r){
                    off.Accepted__c = 'YES';
                    offers.add(off);
                }
            }

            if(offers.size() > 0){
                update offers;
            }

            for(PrerequisiteOrder__c so : listSO){
                so.Status__c = 'RESPONDED';
                salesOrders.add(so);
            }
            //system.debug('## so '+salesOrders);

            //updating salesorder to execute process till it reach staus indelivery
            if(salesOrders.size() > 0){
                update salesOrders;
            }
        }

        return null;
    }
}