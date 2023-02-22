/*************************************************************************************
Class Name - ASPISServicePrerequisiteOrder
Version - 1.0
Created Date - 02 APR 2015
Function - Class to Manage Acceptance process by BodyShop

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias             02/04/2015  Original Version
* Joao Dias             08/04/2015  Changing Accepted(YES/NO/Blank) to AcceptedCheck(true/false) checkbox
* Cecile LARTAUD        18/05/2015  Remove the obsolete Record Type "Line Ordered"
* Joao Dias				20/05/2015  Changing status of not accepted Purchase Orders -> status = 'REJECTED'
* Cecile L      		17/06/2015  Add the update of Assessment status when the SO is responded.
* Dourga U              04/07/2016  Commented class not longer in use(case 1653)
**************************************************************************************/
public with sharing class ASPISServicePrerequisiteOrder {
// implements ASPISService{

//    public void executeProcess(sObject obj){
//        system.debug('###PREREQUISITE CALLED###');
//        PrerequisiteOrder__c    preReq              = (PrerequisiteOrder__c) obj;
//        //Change  SalesOrder recordType
//    /*    PrerequisiteOrder__c    preReqSub = new PrerequisiteOrder__c(id = preReq.id, recordTypeID = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId());
//        update preReqSub;*/
//        List<PurchaseOrder__c>  listPurchaseOrder2Update   = new List<PurchaseOrder__c>();
//        List<OrderLine__c>  listOrderLine2Update   = new List<OrderLine__c>();
//        List<PurchaseOrder__c> listPurchaseOrder = ASPISWithoutSharingExceptions.getPurchaseOrderAndOrderLinesRegardingThisSalesOrder(preReq.id);
//        for(PurchaseOrder__c po: listPurchaseOrder){
//        	if(po.AcceptedLines__c > 0){
//        		po.status__c = 'ORDERED';
//	         /*   for(OrderLine__c ol:po.OrderLines__r){
//	                ol.LineToOrder__c = ol.purchaseOrder__c;
//	                ol.PrerequisiteSupplieable__c = preReq.id;
//	                ol.DeliveryStatus__c = system.Label.PURCHASEORDERINPROCESSDELIVERYSTATUS;
//	                listOrderLine2Update.add(ol);
//	            }     */

//        	}
//        	else{
//        		po.status__c = 'REJECTED';
//        	}
//        	listPurchaseOrder2Update.add(po);	
//        }

        
//        // @CLA	17/06/2015	Update the status of Assessment to "INDELIVERY", to track the progress.
//        Assessment__c parentAssessment= new Assessment__c(Id = preReq.Assessment__c, Status__c = 'INDELIVERY');
//        ASPISWithoutSharingExceptions.updateAssessmentList(new List<Assessment__c>{parentAssessment});
        
//     //   ASPISWithoutSharingExceptions.updatePurchaseOrderList(listPurchaseOrder2Update);
//    //    ASPISWithoutSharingExceptions.updateOrderLineList(listOrderLine2Update);
//    }
}