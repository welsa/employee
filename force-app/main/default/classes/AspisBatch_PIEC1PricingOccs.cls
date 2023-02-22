/*
  ----------------------------------------------------------------------
  -- - Name          : AspisBatch_PIEC1PricingOccs
  -- - Author        : KSM
  -- - Description   : Fill OEM Standard Discount on CrossRef, Fill Additional Margin for Occurences, Calculate best Occ for cross Ref
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------

  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class AspisBatch_PIEC1PricingOccs implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    static Map<String, List<Decimal>> mapStepExecTime = new Map<String, List<Decimal>>{'FillOEMdiscount' => new List<Decimal>(), 'FillAdditionalMargin' => new List<Decimal>(), 'GetBestOccurence' => new List<Decimal>()};
    static Datetime startTime;
    static Datetime endTime;
    static String errorMsg;
    static Set<String> setTechDist = new Set<String>();
    static String discountNull = '';
    static Boolean calculateAdditionalMargin;
    static Savepoint sp;
    static List<Messaging.SingleEmailMessage> outErrorEmails;
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AspisBatch_PIEC1PricingOccs(), 200);  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------- START AspisBatch_PIEC1PricingOccs - start --------------');

        startTime = Datetime.now();
        errorMsg = '';
        
        //Retrive log set by informatica to verify if occurences have been well inserted
        Log__c logInformatica = (Log__c)[SELECT Name, ProcessEnded__c, OccurenceTreatment__c FROM Log__c WHERE Name='ETL_Informatica' LIMIT 1];
        
        if(logInformatica.ProcessEnded__c){

            //Build set of Distibutor (Tech_Distributor on account) to be excluded
            List<String> lstDist = logInformatica.OccurenceTreatment__c.split('|');

            for(String dist : lstDist){
               List<String> lstTmp = dist.split(':');
               if(lstTmp[1].contains('Error'))
                   setTechDist.add(lstTmp[0]);
            }
        }
        else{

           //insert log with error and end batch execution
           Log__c logAbort = new Log__c();
           logAbort.Name = 'Batch 1 Pricing';  
           logAbort.Class__c = 'AspisBatch_PIEC1PricingOccs';
           logAbort.sObject__c =  'Occurence__c';
           logAbort.DateLog__c = System.now();
           logAbort.Status__c = Label.STATUSFAILED;
           logAbort.ErrorDescription__c = 'Insertion By informatica Failed, Batch Aborted';

           Database.insert(logAbort);

           System.abortJob(BC.getJobId());

        }

        // Set Savepoint (snapshot of database to allow rollback in case of errors)
        sp = Database.setSavepoint();

        // Set params for batch
        ConfigurationFlux__mdt batchConfig = ConfigurationFlux__mdt.getInstance('AspisBatch_PIEC1PricingOccs');
        calculateAdditionalMargin = batchConfig.CalculateAdditionalMargin__c;
        if(!batchConfig.CalculateOEMDiscountForAllCrossRef__c)
            discountNull = 'AND Discount__c = null';

        String query =  'SELECT CrossReference__c, CrossReference__r.OEMStandardDiscount__c, CrossReference__r.OEMStandardDiscount_tmp__c, ' +
                        'CrossReference__r.AdditionalMargin_tmp__c, CrossReference__r.AdditionalMargin__c,  CrossReference__r.Discount__c, ' + 
                        'AdditionalMargin__c, Quality__c' + 
                        'FROM Occurence__c ' + 
                        'WHERE CrossReference__r.Connected__c = true' +
                        'AND CrossReference__r.IAMPartClass__c = \'E\' ' + 
                        'AND CrossReference__r.CountryCode__c = \'FR\' ' +
                        'Status__c != \'Obselete\'' ;
        
        system.debug('## query:'+query);
        System.debug('------------- END AspisBatch_PIEC1PricingOccs - start ---------------'); 

        return Database.getQueryLocator(query); 
    }


    global void execute(Database.BatchableContext BC, List<Occurence__c> scope) {

        System.debug('------------ START AspisBatch_PIEC1PricingOccs - execute --------------');

        Map<String, Map<String, List<Occurence__c>>> mapXrefQualityOcc = new Map<String, Map<String, List<Occurence__c>>>();

        for(Occurence__c occ : scope){
            if(mapXrefQualityOcc.containsKey(occ.CrossReference__c)){
                if(mapXrefQualityOcc.get(occ.CrossReference__c).containsKey(occ.Quality__c)){
                    if(considerOccForPricing(occ))
                        mapXrefQualityOcc.get(occ.CrossReference__c).get(occ.Quality__c).add(occ);
                }
                else{
                    if(considerOccForPricing(occ))
                        mapXrefQualityOcc.get(occ.CrossReference__c).put(occ.Quality__c, new List<Occurence__c>{occ});
                }
            }
            else{
                if(considerOccForPricing(occ)){
                    mapXrefQualityOcc.put(occ.CrossReference__c, new Map<String, List<Occurence__c>>{occ.Quality__c => new List<Occurence__c>{occ}});
                }
                else{
                    //Cross ref as Key is still added in Map even for occ not to be considered as keySet is used for next Query
                    mapXrefQualityOcc.put(occ.CrossReference__c, null);
                }
            }
        }

        /*********************************************************************************************************
         * Fill the field OEM_StandardDiscount__c on the Cross refs ( With Status « New » or Discount__c = NULL, based on Discount Object)
         ********************************************************************************************************/ 

        Datetime startFillOEMdiscount = Datetime.now();

        Map<Id, CrossReference__c> mapConnectedXref = new Map<Id, CrossReference__c>();
        Map<String, CrossReference__c> mapUniqueKeyXref = new Map<String, CrossReference__c>();
        Map<String, String> mapUniqueFamilyKey = new Map<String, String>();
        Map<String, Discount__c> mapFamilyKeyDiscount = new Map<String, Discount__c>();

        for(CrossReference__c xref : Database.query('SELECT OEMStandardDiscount_tmp__c, Discount__c, OEMCleanPartNumber__c, OEMManufacturer__c FROM CrossReference__c WHERE Id IN :mapXrefQualityOcc.keySet() ' + discountNull)){
            mapConnectedXref.put(xref.Id, xref);
        }

        for(Id xrefId : mapConnectedXref.keySet()){
            mapUniqueKeyXref.put(mapConnectedXref.get(xrefId).OEMManufacturer__c+mapConnectedXref.get(xrefId).OEMCleanPartNumber__c, mapConnectedXref.get(xrefId));
            
            // Add UniqueKey for BRAND + ALLPARTNUMBERS
            if(!mapUniqueKeyXref.containsKey(mapConnectedXref.get(xrefId).OEMManufacturer__c+Label.ALLPARTNUMBERS))
                mapUniqueKeyXref.put(mapConnectedXref.get(xrefId).OEMManufacturer__c+Label.ALLPARTNUMBERS, mapConnectedXref.get(xrefId));
            
            // Add UniqueKey for ALLBRANDs + PartNumber (OR ALLBRAND + ALLPARTNUMBERS OR just ALLBRANDS => A confirmer )
            if(!mapUniqueKeyXref.containsKey('ALLBRANDS'+mapConnectedXref.get(xrefId).OEMCleanPartNumber__c))
                mapUniqueKeyXref.put('ALLBRANDS'+mapConnectedXref.get(xrefId).OEMCleanPartNumber__c, mapConnectedXref.get(xrefId));

        }

        //Map Unique key of oem referential to family key of discount by concatenating the distributor which is PREBYAS (can be hardcoded) 
        for(OEMReferentiel__c oemRef :  [SELECT FamilyKey__c,UniqueKey__c from OEMReferentiel__c WHERE (UniqueKey__c IN : mapUniqueKeyXref.keySet()) AND isActive__c=true ]){
            mapUniqueFamilyKey.put(oemRef.UniqueKey__c, oemRef.FamilyKey__c+Label.PREBYAS);
        }

        for(Discount__c discountOEM : [SELECT BSdiscount__c, FamilyKey__c FROM Discount__c WHERE RecordType.DeveloperName='DiscountOEM'  
        AND FamilyKey__c IN :mapUniqueFamilyKey.values()]){
            mapFamilyKeyDiscount.put(discountOEM.FamilyKey__c, discountOEM);
        }

        //Fill OEM Standard Discount for the xrefs + Build Map of xref with Discount object to be used for fillin Additional Margin on Occurences
        Map<Id, Discount__c> mapXrefDiscount = new Map<Id, Discount__c>();

        for(Id xrefId : mapConnectedXref.keySet()){

            String uniqueKey = mapConnectedXref.get(xrefId).OEMManufacturer__c + mapConnectedXref.get(xrefId).OEMCleanPartNumber__c;
            String familyKey = mapUniqueFamilyKey.get(uniqueKey);
            Discount__c disc = mapFamilyKeyDiscount.get(familyKey);

            if(disc.BSdiscount__c == null){ // Case No Discount Available for BRAND + PartNumber + PREBYAS
                uniqueKey = mapConnectedXref.get(xrefId).OEMManufacturer__c + Label.ALLPARTNUMBERS;
                familyKey = mapUniqueFamilyKey.get(uniqueKey);
                disc = mapFamilyKeyDiscount.get(familyKey);
            }
            if(disc.BSdiscount__c == null){ // Case No Discount Available for BRAND + ALLPARTNUMBERS + PREBYAS
                uniqueKey = 'ALLBRANDS' + mapConnectedXref.get(xrefId).OEMCleanPartNumber__c;
                familyKey = mapUniqueFamilyKey.get(uniqueKey);
                disc = mapFamilyKeyDiscount.get(familyKey);
            }

            if(disc.BSdiscount__c == null){ // Case No Discount available for ALLBRANDS + PartNumber + PREBYAS (Should not happen) 
                System.debug('~KSM~ No discount found to be assigned, (Not even default)');
            }
            else{
                mapConnectedXref.get(xrefId).OEMStandardDiscount_tmp__c = disc.BSdiscount__c;
                mapConnectedXref.get(xrefId).Discount__c = disc.Id;
            }

            mapXrefDiscount.put(xrefId, disc);

        }

        Datetime endFillOEMdiscount = Datetime.now();

        mapStepExecTime.get('FillOEMdiscount').add(endFillOEMdiscount.getTime() - startFillOEMdiscount.getTime());

        /*****************************************************************************************************
         * Fill the field AdditionalMargin__c on the Occurrences with Status « New » based on the Quality Grid
         ****************************************************************************************************/ 

        // Use Map of Cross Ref to Discount built above
        // Note that Quality_Grid_tech_doc will be renamed to Quality__c

        Datetime startFillAdditionalMargin = Datetime.now();

        if(calculateAdditionalMargin){
            List<Quality__c> lstQuality = [SELECT Active__c,AdditionalMargin__c, Discount__c, Quality__c FROM Quality__c WHERE Active__c = true AND Discount__c IN :mapXrefDiscount.values()];

            //Build Map of Discount grid with their associated  Id is of discount grid
            Map<Id, List<Quality__c>> mapDisQuality = new  Map<Id, List<Quality__c>>();
    
            for(Quality__c qgtd : lstQuality){
                if(mapDisQuality.containsKey(qgtd.Discount__c)){
                    mapDisQuality.get(qgtd.Discount__c).add(qgtd);
                }
                else{
                    mapDisQuality.put(qgtd.Discount__c, new List<Quality__c>{qgtd});
                }
            }
            
           for(Occurence__c occ : scope){
                //get the quality grid for this occ
                List<Quality__c> lstQty = mapDisQuality.get(mapXrefDiscount.get(occ.CrossReference__c).Id);
                //Select the Quality grid which matches the quality of the occ to the quality of the quality grid
                for(Quality__c qgtd : lstQty){
                    if(qgtd.Quality__c == occ.Quality__c){
                        occ.AdditionalMargin__c = qgtd.AdditionalMargin__c;
                    }
                }
                if(occ.AdditionalMargin__c == null)
                    occ.AdditionalMargin__c = 0;
            }    
        }

        Datetime endFillAdditionalMargin = Datetime.now();

        mapStepExecTime.get('FillOEMdiscount').add(endFillAdditionalMargin.getTime() - startFillAdditionalMargin.getTime());

        /*****************************************************************************************************
         * Find best Occurence for each Cross ref and populate their temporary fields with the occurrence data
         ****************************************************************************************************/ 

        Datetime startGetBestOccurence = Datetime.now();

        for(Id xref : mapXrefQualityOcc.keyset()){

            List<String> lstQualities= new List<String>(mapXrefQualityOcc.get(xref).keySet());
            lstQualities.sort();
           
            //Best Quality = first element after sorting
            String bestQuality = lstQualities[0];
        
            // get all occs with that quality
            List<Occurence__c> lstTmpOccs = mapXrefQualityOcc.get(xref).get(bestQuality);

            Occurence__c finalOcc = new Occurence__c();

            if(lstTmpOccs.size() > 1){
                //Take less expensive one
                //initialize a max price
                Decimal lessExpensive = 1000000.00;
                //Initialize Occurence
                for(Occurence__c occ : lstTmpOccs){
                    if(occ.ASSellingNetPrice__c < lessExpensive){
                        lessExpensive = occ.ASSellingNetPrice__c;
                        finalOcc = occ;
                    }
                }
            }
            else{
                finalOcc = lstTmpOccs[0];
            }

            if(finalOcc.CrossReference__r.PRE_Price__c == null ||
                String.isNotBlank(finalOcc.CrossReference__r.Quality_tmp__c) ||
                finalOcc.Quality__c < finalOcc.CrossReference__r.Quality_tmp__c || 
                (finalOcc.CrossReference__r.Quality_tmp__c.equalsIgnoreCase(finalOcc.Quality__c)  && finalOcc.ASSellingNetPrice__c < finalOcc.CrossReference__r.PRE_Price_tmp__c)){

                    finalOcc.CrossReference__r.PRE_Price_tmp__c = finalOcc.ASSellingNetPrice__c;
                    finalOcc.CrossReference__r.NONPARTNER_PRE_Price_tmp__c = finalOcc.NonPartner_ASSellingNetPrice__c;
                    finalOcc.CrossReference__r.AdditionalMargin_tmp__c = finalOcc.AdditionalMargin__c; //could be null as there is the option where additional margin is not calculated
                    finalOcc.CrossReference__r.Quality_tmp__c = finalOcc.Quality__c;
            }

        }

        Datetime endGetBestOccurence = Datetime.now();
        mapStepExecTime.get('GetBestOccurence').add(endGetBestOccurence.getTime() - startGetBestOccurence.getTime());
              
        try{
            Database.update(mapConnectedXref.values(), true);
            Database.update(scope, true);
        }
        catch(Exception e){
            System.debug('Error occured during update of occurences and xrefs : ' +  e.getMessage());
            errorMsg = 'Error occured during update of occurences and xrefs : ' +  e.getMessage();
        }
       
        System.debug('-------------- END AspisBatch_PIEC1PricingOccs - execute --------------');
        
    }

    global void finish(Database.BatchableContext context) {
        
        System.debug('---------------- START AspisBatch_PIEC1PricingOccs - finish --------------');
        
        System.debug('## errorMsg: ' + errorMsg);
        
        endTime = Datetime.now();
        Decimal tmpExecTime = endTime.getTime() - startTime.getTime();
        Decimal execTime = tmpExecTime.divide(1000,5);

        String executionTimeLog = 'Step  1 : Fill OEM Discount = ' + averageExecTime(mapStepExecTime.get('FillOEMdiscount')) + ' sec' +  '\n' + 
                                  'Step  2 : Fill Additional Margin = ' + averageExecTime(mapStepExecTime.get('FillAdditionalMargin')) + ' sec' +  '\n' +
                                  'Step  3 : Find and Store best occurence data = ' + averageExecTime(mapStepExecTime.get('GetBestOccurence')) + ' sec' +  '\n';
        
        Log__c log = new Log__c(); 

        if(String.isNotBlank(errorMsg)){

            Database.rollback(sp);

            log.Status__c = Label.STATUSFAILED;
            log.ErrorDescription__c = errorMsg;

            AsyncApexJob batchJob = [SELECT Id, TotalJobItems, CreatedBy.Email, CreatedBy.Name, ApexClass.Name 
            FROM AsyncApexJob
            WHERE Id =: context.getJobId()];

            List<String> emailAddList = getMailAddresses();
            emailAddList.addAll(new List<String>{'ashwina.seetaram@sc-mauritius.com','welsa.chan@sc-mauritius.com','nprieto@altirc.com'});   

            sendErrorEmail(batchJob, 'AspisBatch_1PricingOccurences Error', errorMsg, emailAddList);
        }
        else {
            log.Status__c = Label.STATUSPASSED;
        }
        
        log.Name = 'Batch 1 Pricing';  
        log.Class__c = 'AspisBatch_PIEC1PricingOccs';
        log.sObject__c =  'Occurence__c';
        log.DateLog__c = System.now();
        log.ExecutionTime__c = execTime; 
        log.ExecutionTimePerStep__c = executionTimeLog;

        Database.insert(log);

        if(String.isBlank(errorMsg)){
            //run nextBatch parameterized with excluded distributors
            Database.executeBatch(new  AspisBatch_PIEC2ActivateOccsXRef(setTechDist, sp) , 200);
        }

    }

    public List<String> getMailAddresses()
    {
        List<String> mailList       = new List<String>();
        List<String> mailAddresses  = new List<String>(); 

        for (GroupMember gm : [ SELECT UserOrGroupId
                                FROM    GroupMember 
                                WHERE   Group.DeveloperName = 'SystemAdmins']) 
        {
            mailList.add(gm.UserOrGroupId);
        }
    
        if(mailList.size() > 0)
        {
            List<User> userList = [ SELECT  Email 
                                    FROM    User
                                    WHERE   Id IN : mailList];
            for(User usr : userList) 
            {
                mailAddresses.add(usr.Email);
            }
        }       

        return mailAddresses;
    }

    public static void sendErrorEmail(AsyncApexJob a, String subject, String errorMessage, List<String> emailAddressList){
        String emailSubject = 'ASPIS - ' + subject;
        String emailBody = 'Hello, <br/><br/> The batch ' + a.ApexClass.Name + ' launched by ' + a.CreatedBy.Name + ' has treated ' + a.TotalJobItems + ' chunk(s) in the Organisation ' + UserInfo.getOrganizationId()
                         + '<br/><br/> ' + errorMessage + '<br/>Regards, <br/> ASPIS Back Office Team';
                        
        outErrorEmails                          = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage l_objMail  = new Messaging.SingleEmailMessage();

        l_objMail.setToAddresses(emailAddressList);
        l_objMail.setSubject(emailSubject);
        
        l_objMail.setHtmlBody(emailBody);
        outErrorEmails.add(l_objMail);
        
        if (outErrorEmails.size() > 0) {
            Messaging.sendEmail(outErrorEmails);
        }
    }

    public boolean considerOccForPricing(Occurence__c occ){
        if(setTechDist.contains(occ.Distributor__r.Tech_Distributor__c) && occ.Status__c=='Active'){
            return true;
        } 
        else if(!setTechDist.contains(occ.Distributor__r.Tech_Distributor__c) && occ.Status__c=='New'){
            return true;
        }
        else{
            return false;
        }
    }

    public decimal averageExecTime(List<Decimal> lstDecimal){
        decimal sum = 0;
        for(Decimal dec : lstDecimal){
            sum += dec.divide(1000,5);
        }
        return sum/lstDecimal.size();
    }
}