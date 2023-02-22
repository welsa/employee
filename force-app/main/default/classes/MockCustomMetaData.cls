public class MockCustomMetaData {
  public static Map<String, List<SObject>> metaDataMap = new Map<String, List<SObject>>();
    
    public List<SObject> getMetaDataRecords(String name){
        if (!metaDataMap.containsKey(name)){
            metaDataMap.put(name, Database.query(name));
        }
        return metaDataMap.get(name);
    }
}