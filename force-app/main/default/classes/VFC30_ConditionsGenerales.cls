/*
----------------------------------------------------------------------
-- - Name          : VFC30_ConditionsGenerales
-- - Author        : NPE
-- - Description   : Controller for VFP30_ConditionsGenerales
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 05/05/2022   NPE     1.0         C-004704: AJOUT ONGLET POUR VISUALISER LES CGV ASF
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC30_ConditionsGenerales {
    public String cgvBody {get; set;}
    public String cgvBody2 {get; set;}
    public String cgvBody3 {get; set;}
    public String cgvPDF {get; set;}

    public VFC30_ConditionsGenerales(){
        String docIds='';
        cgvPDF= '';

        List<string> docs = new List<string>();

        
        String docsCGV = 'select CGVDocumentCol1__c, CGVDocumentCol2__c, CGVDocumentCol3__c, CGVDocumentPDF__c from ConditionGeneraleDeVente__mdt where showCGV__c = true';

        for(ConditionGeneraleDeVente__mdt currentCGV : Database.Query(docsCGV)){
            docs.add(currentCGV.CGVDocumentCol1__c);
            docs.add(currentCGV.CGVDocumentCol2__c);
            docs.add(currentCGV.CGVDocumentCol3__c);
            docs.add(currentCGV.CGVDocumentPDF__c);
        }

        System.debug('NPE docs '+ docs);
        List<Document> documentList = [ SELECT  Id, Body
                                        FROM    Document
                                        WHERE   DeveloperName IN :docs
                                        order by DeveloperName asc];

        System.debug('NPE doc list ' +documentList );
        if(!documentList.isEmpty()){
            cgvBody = documentList[0].Body.toString();
            cgvBody2 = documentList[1].Body.toString();
            cgvBody3 = documentList[2].Body.toString();
            
            docIds=documentList[3].Id;
            
            cgvPDF=URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.FileDownload?file='+docIds;

        }
    }
}