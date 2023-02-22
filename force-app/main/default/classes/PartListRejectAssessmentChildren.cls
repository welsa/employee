public class PartListRejectAssessmentChildren{
    @InvocableMethod(label='Reject PartList Assessment Children')
    public static void invoke(List<ID> listParentAssessmentIDs){
        delete [select id from PartList__c where Assessment__c in :listParentAssessmentIDs];
        System.debug('Number of PartList deleted = ' + listParentAssessmentIDs.size());
    }
}