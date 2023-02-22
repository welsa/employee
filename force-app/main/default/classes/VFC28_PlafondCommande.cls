/**
 * @description       : 
 * @author            : HRM
 * @group             : 
 * @last modified on  : 02-10-2022
 * @last modified by  : HRM
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   10-22-2021   HRM   Initial Version
**/
public class VFC28_PlafondCommande {
	public String currentRecordId {get;set;}
    public Decimal plafond {get;set;}
    public Decimal totalOrders {get;set;}
    public Decimal progressBarWidth {get;set;}
    public boolean allowPlafond {get;set;}
    public Account record { get; private set; }
    
    public VFC28_PlafondCommande(ApexPages.StandardController controller){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        plafond = getMaxOrderAmount(currentRecordId);
        totalOrders = getSumTotalPriceOrdered(currentRecordId);
        List<String> fields = new List<String>{'ShippingCountryCode'};
        if (!Test.isRunningTest()) controller.addFields(fields);
        record = (Account)controller.getRecord();
        Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();
        if( mapCountryCodeMapping.containsKey(record.ShippingCountryCode) && mapCountryCodeMapping.get(record.ShippingCountryCode).AllowPlafondCommande__c){
            allowPlafond=true;
        }
        else{
            allowPlafond=false;
        }
        if(totalOrders != null && plafond != null){
            if((totalOrders/plafond)*100 > 100){
                progressBarWidth = 100; }
            else {
                progressBarWidth = (totalOrders/plafond)*100;
                progressBarWidth = progressBarWidth.round(System.RoundingMode.HALF_UP);              
            }
        }
        else{
            if(plafond != null){
                progressBarWidth = 0;
            }
            if(totalOrders == null){
                totalOrders = 0;
            }
        }
        
    }
    
   	public static Decimal getSumTotalPriceOrdered(Id bodyshopId){
        AggregateResult ar = [SELECT SUM(BSTotalPrice__c)sum FROM Offer__c WHERE AgencyMode__c = false AND CreatedDate = LAST_N_DAYS:29 AND Accepted__c = 'YES' AND OrderType__c = 'FINAL' AND OrderLine__r.PurchaseOrder__r.status__c!='PREDRAFTQUOTE' AND Prerequisiteorder__r.Assessment__r.BodyShop__c=:bodyshopId];
    	return (Decimal)ar.get('sum');
    }
    public static Decimal getMaxOrderAmount(Id bodyshopId){
        AggregateResult ar = [SELECT SUM(Amount__c)sum FROM Plafond_Commande__c WHERE Bodyshop__c =: bodyshopId AND Available__c = true];
        return (Decimal)ar.get('sum');
    }
    //HRM 18/10/21 : C-004215 - Plafond Commande
	/**
     * Function to Create a Case When Order limit of the bodyshop is reached and send notification email to support and financial dept 
     * @param  bodyshopId  The id of the bodyshop which the limit has reached
     * @return Null
     */
    public static void ReportError(Assessment__c assessment, String emailAddress,Boolean limitReached){
        //Boolean limitReached = false;
        Case__c newCase = new Case__c( 
                                        RecordTypeId= Schema.SObjectType.Case__c.getRecordTypeInfosByDeveloperName().get('Business_process_case').getRecordTypeId()
                                        //RecordTypeId= Schema.SObjectType.Case__c.getRecordTypeInfosByName().get('Business process case').getRecordTypeId()
                                        ,Origin__c='APPLICATION'
                                        ,Type__c='PROBLEM'
                                        ,Case_Reason__c='ORDERING'
                                        ,Priority__c='CRITICAL'
                                        ,Subject__c='Maximum Order amount exceeded on '+ assessment.BodyShop__r.Name
                                        ,Account_Name__c = assessment.BodyShop__c
                                        ,Assesment__c = assessment.Id
                                        ,SubmittedBy__c = UserInfo.getUserId());
        if(emailAddress != null){
            EmailTemplate template = new EmailTemplate ();
            if(limitReached){
                template = [SELECT Body,HtmlValue,Subject FROM EmailTemplate WHERE DeveloperName =: System.Label.PlafondCommandeLimitReachedEmailTemplate]; 
                System.debug('HRM limit Reached');    
            }

            else if(!limitReached && newCase != null ){
                insert newCase;
                template = [SELECT Body,HtmlValue,Subject FROM EmailTemplate WHERE DeveloperName =: System.Label.PlafondCommandeLimitExceededEmailTemplate];    
                System.debug('HRM limit Exceeded');   
            }
            
            if(template != null){
                System.debug('HRM template not null');  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddress.split(';'));
                if(!limitReached && newCase.Id != null){
                    String htmlVal =template.HtmlValue.replace('{!Account.Name}', assessment.BodyShop__r.Name);
                    htmlVal = htmlVal.replace('{!Case.Link}',  URL.getSalesforceBaseUrl().toExternalForm()+'/'+newCase.Id);
                    mail.setHtmlBody(htmlVal);
                }
                else{
                    mail.setPlainTextBody(template.Body.replace('{!Account.Name}', assessment.BodyShop__r.Name));
                }
                mail.setSubject(template.Subject.replace('{!Account.Name}', assessment.BodyShop__r.Name));
                mail.setOrgWideEmailAddressId(system.label.OrgWideEmailAddressId);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        }
    }
    @future
    public static void isPlafondReached(String currentAssessmentId){
            Assessment__c currentAssessment = [SELECT TECH_EntityCountryCode__c,BodyShop__r.Name FROM Assessment__c WHERE Id = : currentAssessmentId];
            Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();
            if(mapCountryCodeMapping.containsKey(currentAssessment.TECH_EntityCountryCode__c) && mapCountryCodeMapping.get(currentAssessment.TECH_EntityCountryCode__c).AllowPlafondCommande__c){
                Decimal maxAmountForOrders = VFC28_PlafondCommande.getMaxOrderAmount(currentAssessment.BodyShop__c);
                Decimal sumTotalPriceOrdered = VFC28_PlafondCommande.getSumTotalPriceOrdered(currentAssessment.BodyShop__c);
                System.debug('###HRM1: '+maxAmountForOrders);
                System.debug('###HRM2: '+sumTotalPriceOrdered);
                sumTotalPriceOrdered = sumTotalPriceOrdered != null ? sumTotalPriceOrdered : 0;
                maxAmountForOrders = maxAmountForOrders != null ? maxAmountForOrders : 0;
                if(maxAmountForOrders != null){
                    if(sumTotalPriceOrdered>=maxAmountForOrders){
                        String reportToEmailAddress = mapCountryCodeMapping.get(currentAssessment.TECH_EntityCountryCode__c).FinanceAndSupportEmail__c;
                        VFC28_PlafondCommande.ReportError(currentAssessment,reportToEmailAddress,true);
                    }
                }
            }
    }
}