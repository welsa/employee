/*************************************************************************************
Class Name - VFC_PrintPartListForDistributor
Version - 1.0
Created Date - 
Function - Print Part List For Distributor

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date            Description
* ----------            ----------      -----------------------
* Dourga                21/01/2016      Updated for Case 1472 (bodyshop’s address instead of Alpha Scale)
* Dourga                09/08/2016      Updated for Case 1690 (Null address on Delivery Note for Distributor)
* Dourga                28/08/2016      Updated for case 1589 (Supplier's Delivery Note: Remove the Original line)
************************************************************************************/
public with sharing class VFC_PrintPartListForDistributor {

    private final Id PurchaseOrderId = ApexPages.currentPage().getParameters().get('id');
    public String displayAddress;
    public PurchaseOrder__c currentPO = [select Id, Name, Status__c, Distributor__r.ShippingCountry, BodyShopAddress__c, BodyShopName__c
                                        from PurchaseOrder__c 
                                        where Id=:PurchaseOrderId limit 1];
    public PurchaseOrder__c Assessment = [select Assessment__c from PurchaseOrder__c where Id=:PurchaseOrderId Limit 1];
    public Id AssessmentId = Assessment.Assessment__c;
    public string renderAs{get;set;}
    public VFC_PrintPartListForDistributor(ApexPages.StandardController controller) {
            if(ApexPages.currentPage().getParameters().get('pdf') != null && ApexPages.currentPage().getParameters().get('pdf') == 'true') 
            {
                renderAs = 'pdf';
                if(ApexPages.currentPage().getParameters().get('force_download') != null && ApexPages.currentPage().getParameters().get('force_download') == 'true') 
                {
                    Date dateNow = Date.today();
                    String day = String.valueOf(dateNow.day());
                    String month = String.valueOf(dateNow.month());
                    String year= String.valueOf(dateNow.year());                
                    string fileName = Label.Delivery_note+'_'+currentPO.Name+'_'+day+'-'+month+'-'+year+'.pdf';
                    
                    if(apexPages.currentPage().getParameters().get('filename') != null)
                    {
                        fileName = Label.Delivery_note+'_'+currentPO.Name+'_'+day+'-'+month+'-'+year+'.pdf';
                    }
               
                    Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
                }               
            }        
    }

    public List<OrderLine__c> getOrderLines()    {

        if (currentPO.Status__c == 'DRAFTQUOTE' || currentPO.Status__c == 'ISSUED') {
            return [Select Name, AssessmentPrice__c, Description__c, Quantity__c, Type__c, CataloguePrice__c, AXAPrice__c, AXATotalPrice__c, TotalDiscount__c, CreatedDate, PartNumber__c  from OrderLine__c where PurchaseOrder__c=:PurchaseOrderId and ((OrderType__c = 'FINAL' and TechGeneratedFinal__c = false) or OrderType__c = 'BUNDLEITEM')];
        }
        else {
            return [Select Name, AssessmentPrice__c, Description__c, Quantity__c, Type__c, CataloguePrice__c, AXAPrice__c, AXATotalPrice__c, TotalDiscount__c, CreatedDate, PartNumber__c from OrderLine__c where AcceptedCheck__c = True and PurchaseOrder__c=:PurchaseOrderId and ((OrderType__c = 'FINAL' and TechGeneratedFinal__c = false) or OrderType__c = 'BUNDLEITEM')];       
        }
    }

    public List<PurchaseOrder__c> getPurchaseOrder()    {
           return [select Id, Status__c, Name, PlateNumber__c, ClaimNumber__c from PurchaseOrder__c where Id=:PurchaseOrderId limit 1];
    }
    
    public String getDateToday() {
        Date dateNow = Date.today();
        String day = String.valueOf(dateNow.day());
        String month = String.valueOf(dateNow.month());
        String year= String.valueOf(dateNow.year());
        return day+'/'+month+'/'+year;
    }
    
    public String getAddress() {
        //Dourga case 1472
        //Dourga case 1690
        displayAddress = '\n'+
            '<div style="float:left;width:45%;text-align:right;">\n'+
            '<p style="font-weight:bold;">'+ String.valueOf(currentPO.BodyShopName__c) +'<br/>\n'+
            + String.valueOf(currentPO.BodyShopAddress__c) + '</p>\n'+
            '</div>\n';
        /*if(currentPO.Distributor__r.ShippingCountry == 'Spain') {
          displayAddress = '\n'+
          '<div style="float:left;width:45%;text-align:right;">\n'+
          '<p style="font-weight:bold;">Alpha Scale S.A., Sucursal en España<br/>\n'+
          'W0010418B<br/>\n'+
          'C/ Camino Fuente de la Mora, no 1<br/>\n'+
          '28050 Madrid</p>\n'+
          '</div>\n';
        }
        else if(currentPO.Distributor__r.ShippingCountry == 'France'){
          displayAddress = '\n'+
          '<div style="float:left;width:45%;text-align:right;">\n'+
          '<p style="font-weight:bold;">Alpha Scale France<br/>\n'+
          '21 Avenue Matignon<br/>\n'+
          '75008 Paris</p>\n'+
          '</div>\n';         
        }
        else {
          displayAddress = '\n'+
          '<div style="float:left;width:45%;text-align:right;">\n'+
          '<p style="font-weight:bold;">Alpha Scale S.A., Sucursal en España<br/>\n'+
          'W0010418B<br/>\n'+
          'C/ Camino Fuente de la Mora, no 1<br/>\n'+
          '28050 Madrid</p>\n'+
          '</div>\n';        
        }*/
        return displayAddress;      
    }    
  
}