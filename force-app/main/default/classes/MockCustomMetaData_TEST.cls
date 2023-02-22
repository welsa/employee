@isTest
public class MockCustomMetaData_TEST {
    @isTest
    public static void testCustomMetaData(){
        List<SObject> metaDataMap;
        Test.startTest();
          metaDataMap = new MockCustomMetaData().getMetaDataRecords('SELECT Active__c FROM NonAxaOrdering__mdt');
        Test.stopTest();
        System.assertEquals([SELECT Active__c FROM NonAxaOrdering__mdt].size(), metaDataMap.size());
    }
    
    public static void setMetaData(String name, List<SObject> records){
        MockCustomMetaData.metaDataMap.put(name, records);
    }
}