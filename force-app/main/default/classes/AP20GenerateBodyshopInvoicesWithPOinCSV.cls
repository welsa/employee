/*************************************************************************************
Class Name - AP20GenerateBodyshopInvoicesWithPOinCSV
Version - 1.0
Created Date - 27 NOV 2015
Function - Class to generate a CSV of all Bodyshop Invoices with PO and expected amount, to allows SAP to calculate the real benefits.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      27/11/2015  Original Version
*************************************************************************************/
public class AP20GenerateBodyshopInvoicesWithPOinCSV {
// ABT - 06-MAY-2016 - Commented
//    /*############################################################################
//    #   A.T.T.R.I.B.U.T.E.S
//    ##############################################################################*/
//    private final static String CSVTEXTDELIMITER = '"';
//    private final Static String CSVSEPARATOR = ',';     
//    private final Static String CSVENDLINE = '\n'; 
//    private final Static String CSVHEADER = CSVTEXTDELIMITER + 'invType' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invDate' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'bsRefNumber' + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'bsLocalRefNumber' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'soName' + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'poName' + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invID' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invClaimNumber' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invTotalGross' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invTotalNet' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'bsVATType' + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'invVAT' + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + 'poTotalExpectedAmount' + CSVTEXTDELIMITER
//                + CSVENDLINE;      
//    
//    /*
//    *    Wrapper Class : CSV Line
//    * 	 Contains all informations needed to generate the line in CSV format.
//    ******************************** */
//    public class CSVLineWrapper {
//        public String invType {get; set;}
//        public String invDate {get; set;}
//        public String invID {get; set;}
//        public String invClaimNumber {get; set;}
//        public String invTotalVAT {get; set;}
//        public String invTotalGross {get; set;}
//        public String invVAT {get; set;}
//        public String invTotalNet {get; set;}
//        public String bsRefNumber {get; set;}
//        public String bsLocalRefNumber {get; set;}
//        public String bsVATType {get; set;}
//        public String soName {get; set;}
//        public String poName {get; set;}
//        public String poTotalExpectedAmount {get; set;}
//        public Boolean isCloned {get; set;}
//
//        /*
//        * Format the current wrapper record in CSV formatting.
//        * **/
//        public String formatCSV(){
//            return CSVTEXTDELIMITER + invType + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invDate + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + bsRefNumber + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + bsLocalRefNumber + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + soName + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + poName + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invID + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invClaimNumber + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invTotalGross + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invTotalNet + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + bsVATType + CSVTEXTDELIMITER
//                + CSVSEPARATOR + CSVTEXTDELIMITER + invVAT + CSVTEXTDELIMITER 
//                + CSVSEPARATOR + CSVTEXTDELIMITER + poTotalExpectedAmount + CSVTEXTDELIMITER
//                + CSVENDLINE;                
//        }
//        
//        /*
//        * Construtor.
//        * **/
//        public CSVLineWrapper(String p_invType, String p_soName, String p_poName, Decimal p_poTotalExpectedAmount, Date p_invDate, ID p_invID, String p_invClaimNumber, Decimal p_invTotalVAT, Decimal p_invTotalGross, Decimal p_invVAT, Decimal p_invTotalNet, String p_bsRefNumber, String p_bsLocalRefNumber, String p_bsVATType){
//            invType = this.format(p_invType);
//            invDate = this.format(p_invDate);
//            invID = this.format(p_invID);
//            invClaimNumber = this.format(p_invClaimNumber);
//            invTotalVAT = this.format(p_invTotalVAT, 2);
//            invTotalGross = this.format(p_invTotalGross, 2);
//            invVAT = this.format(p_invVAT);
//            invTotalNet = this.format(p_invTotalNet, 2);
//            bsRefNumber = this.format(p_bsRefNumber);
//            bsLocalRefNumber = this.format(p_bsLocalRefNumber);
//            bsVATType = this.format(p_bsVATType);
//            soName = this.format(p_soName);
//            poName = this.format(p_poName);
//            poTotalExpectedAmount = this.format(p_poTotalExpectedAmount, 2);
//            isCloned = FALSE;
//        }
//            
//        /*
//        * Construtor by cloning existing csvLine.
//        * **/
//        public CSVLineWrapper(CSVLineWrapper csvLineClone, String p_poName, Decimal p_poTotalExpectedAmount){
//            invType = csvLineClone.invType;
//            invDate = csvLineClone.invDate;
//            invID = csvLineClone.invID;
//            invClaimNumber = csvLineClone.invClaimNumber;
//            invTotalVAT = csvLineClone.invTotalVAT;
//            invTotalGross = csvLineClone.invTotalGross;
//            invVAT = csvLineClone.invVAT;
//            invTotalNet = csvLineClone.invTotalNet;
//            bsRefNumber = csvLineClone.bsRefNumber;
//            bsLocalRefNumber = csvLineClone.bsLocalRefNumber;
//            bsVATType = csvLineClone.bsVATType;
//            soName = csvLineClone.soName;
//            poName = this.format(p_poName);
//            poTotalExpectedAmount = this.format(p_poTotalExpectedAmount, 2);
//            isCloned = TRUE;
//        }
//        
//        /*
//        * Format Date to String.
//        * **/
//        private String format(Date d)    {
//            return d != null ? (DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('yyyyMMdd')) : '';
//        }
//        /*
//        * Format String to String escaped.
//        * **/
//        private String format(String s) {
//            return s != null ? s.escapeCsv() : '';
//        }
//        /*
//        * Format Decimal to String, with specific scale.
//        * **/
//        private String format(Decimal d, Integer scale) {
//            return d != null ? String.valueOf(d.setScale(scale)) : '';
//        }
//        /*
//        * Format Decimal to String.
//        * **/
//        private String format(Decimal d) {
//            return format(d, 2);
//        }
//    }
//    
//    /*############################################################################
//    #   M.E.T.H.O.D.S
//    ##############################################################################*/
//    /*
//     * Get the type of Case we have to create on the COuntry Code in parameters. (The Queue is set in the trigger Case Before Insert)
//     ***/ 
//    public static void generateCSVFileForSOstatusInvoices(LIST<Invoice__c> l_BsInvoicesQueried){
//    //    MAP<Id,CSVLineWrapper> m_invoiceId_2_CSVLine = new MAP<Id,CSVLineWrapper>();
//        MAP<Id,List<CSVLineWrapper>> m_SOId_2_ListCSVLine = new MAP<Id,List<CSVLineWrapper>>();
//        List<CSVLineWrapper> l_CSVLineToInsert = new List<CSVLineWrapper>();
//        System.debug('####### generateCSVFileForSOstatusInvoices');
//        
//        // Query all the Bodyshop invoices where the SO status is INVOICED
//    /*    LIST<Invoice__c> l_BsInvoicesQueried = new List<Invoice__c>([SELECT Id, ClaimNumber__c, Type__c, Date__c, TotalVAT__c, TotalNet__c, VAT__c, BodyShop__r.LocalReferenceNumber__c, 
//                                                 BodyShop__r.ReferenceNumber__c, BodyShop__r.VAT_Type__c, PrerequisiteOrder__c, PrerequisiteOrder__r.Name
//                                                FROM Invoice__c
//                                                WHERE Status__c = 'SEND'
//                                                                    AND PrerequisiteOrder__r.TECH_BodyshopCountryCode__c = 'ES']);
//        */
//        // Build the map and the wrapper records
//        for(Invoice__c inv : l_BsInvoicesQueried){
//            CSVLineWrapper csvLine = new CSVLineWrapper(inv.Type__c, inv.PrerequisiteOrder__r.Name, '', null, inv.Date__c, inv.Id, inv.ClaimNumber__c, inv.TotalVAT__c, inv.TotalGrossAmount__c, inv.VAT__c, inv.TotalNet__c, inv.BodyShop__r.ReferenceNumber__c, inv.BodyShop__r.LocalReferenceNumber__c, inv.BodyShop__r.VAT_Type__c);
//        /*    if(!m_invoiceId_2_CSVLine.containsKey(inv.Id)){
//                m_invoiceId_2_CSVLine.put(inv.Id, csvLine);
//            } */
//            
//            if(!m_SOId_2_ListCSVLine.containsKey(inv.PrerequisiteOrder__c)){
//                m_SOId_2_ListCSVLine.put(inv.PrerequisiteOrder__c, new List<CSVLineWrapper>{csvLine});
//            }else{
//                List<CSVLineWrapper> l_csvlines = m_SOId_2_ListCSVLine.get(inv.PrerequisiteOrder__c);
//                l_csvlines.add(csvLine);
//                m_SOId_2_ListCSVLine.put(inv.PrerequisiteOrder__c, l_csvlines);
//            }
//        }
//        
//        // Query all the Purchase Orders of the current Sales Orders.
//        List<PrerequisiteOrder__c> l_SOwithPOs = [SELECT Id, (SELECT Id, Name, TotalExpectedAmount__c FROM PurchaseOrders__r WHERE Status__c != 'REJECTED' AND Status__c != 'CANCELED') FROM PrerequisiteOrder__c WHERE Id IN :m_SOId_2_ListCSVLine.keySet()];
//        
//        // Add the informations of PO in the CSVLine wrapper and duplicate the invoice per PO if needed.
//        for(PrerequisiteOrder__c so : l_SOwithPOs){
//            if(m_SOId_2_ListCSVLine.containsKey(so.Id)){
//                Boolean firstPO = TRUE;
//                for(PurchaseOrder__c po : so.PurchaseOrders__r){
//                    // If it is the first PO of the loop, we just update the existing CSVLine wrappers.
//                    if(firstPO){
//                        for(CSVLineWrapper csvL : m_SOId_2_ListCSVLine.get(so.Id)){
//                            csvL.poName = po.Name;
//                            csvL.poTotalExpectedAmount = csvL.format(po.TotalExpectedAmount__c, 2);
//                        }
//                        firstPO = FALSE;
//                    }else{
//                        // Duplicate the original Invoices to put the informations of others PO
//                        for(CSVLineWrapper csvL : m_SOId_2_ListCSVLine.get(so.Id)){
//                            if(!csvL.isCloned)
//                                m_SOId_2_ListCSVLine.get(so.Id).add(new CSVLineWrapper(csvl, po.Name, po.TotalExpectedAmount__c));
//                        }                        
//                    }
//                }
//            }
//            l_CSVLineToInsert.addall(m_SOId_2_ListCSVLine.get(so.Id));
//        }
//        
//        // Build the CSV file content
//        String csvFileContent = CSVHEADER;
//        for(CSVLineWrapper csvL : l_CSVLineToInsert){
//            csvFileContent += csvL.formatCSV();
//        }
//        
//        // Create the CSV file as Chatter File
//        ContentVersion contVersion = new ContentVersion();        
//        contVersion.Title = 'Extract Bodyshop Invoices ' + Datetime.now().format('yyyy-MM-dd') + '.csv';
//        contVersion.PathOnClient = 'Extract Bodyshop Invoices ' + Datetime.now().format('yyyy-MM-dd') + '.csv';
//        contVersion.VersionData = Blob.valueOf(csvFileContent);
//        contVersion.Origin = 'H';
//        insert contVersion;
//        
//        FeedItem elm = new FeedItem(Body = 'A new CSV File is available', ParentId = System.Label.ExtractInvoicesCSV_ChatterGroupID, RelatedRecordId = contVersion.Id, Type = 'ContentPost');
//        insert elm;
//        
// /*       Document csvDoc = new Document();
//        csvDoc.Name = 'MyCSVFileName';
//        csvDoc.Type = 'csv';
//        csvDoc.body = Blob.valueOf(csvFileContent);
//        csvDoc.FolderId = '00l24000000n9pq';  
//        csvDoc.IsInternalUseOnly = FALSE;
//        insert csvDoc; */
//    }
}