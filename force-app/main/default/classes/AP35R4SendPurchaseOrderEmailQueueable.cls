/*************************************************************************************
Class Name - AP35R4SendPurchaseOrderEmailQueueable
Version - 1.0
Created Date - 21 SEP 2017


Modification Log :
---------------------------------------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* WCH            15/04/2020     Original version
*********************************************************************************************************/
public class AP35R4SendPurchaseOrderEmailQueueable implements Queueable {
    private Set<Id> orderEmailIdSet;
    private Set<Id> quotationEmailIdSet;
    private Set<Id> quotationOrderEmailIdSet;
    public  AP35R4SendPurchaseOrderEmailQueueable(Set<Id> orderEmailIdSet, Set<Id> quotationEmailIdSet, Set<Id> quotationOrderEmailIdSet){
        this.orderEmailIdSet=orderEmailIdSet;
        this.quotationEmailIdSet=quotationEmailIdSet;
        this.quotationOrderEmailIdSet=quotationOrderEmailIdSet;
    }
    public void execute(QueueableContext context) {
        System.debug('in Queable2 class');
        AP35R4SendPurchaseOrderEmail.sendEmailASync(orderEmailIdSet,quotationEmailIdSet,quotationOrderEmailIdSet);
    }

}