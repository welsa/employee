/*************************************************************************************
Class Name - ASPISCtrlOrdManageOrderLines
Version - 1.0
Created Date - 8 APRIL 2015
Function - Controller to support updating status on Purchase Order Lines

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias             08/04/2015  Original Version
**************************************************************************************/
public with sharing class ASPISCtrlOrdManageOrderLines {

    private final PurchaseOrder__c po;
    private List<Orderline__c> listOrderedLines {get;set;}
    
    public ASPISCtrlOrdManageOrderLines(Apexpages.StandardController std){
        po = (PurchaseOrder__c)std.getRecord();
    }

    public List<OrderLine__c> getlistOrderedLines(){
        listOrderedLines = [select 
                                Name,
                                PartNumber__c,
                                Description__c,
                                BodyShopPrice__c,
                                DeliveryStatus__c
                            from OrderLine__c where PurchaseOrder__c = :po.id and acceptedCheck__c = true
        ];      
        return listOrderedLines;
    }
    
    public void updateConfirmedLines(){
        update  listOrderedLines;
    }   
}