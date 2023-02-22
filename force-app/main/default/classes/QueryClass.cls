public class QueryClass {
    
    public static String  gen(){
        List<String> cases = getAllField('Case', '');
        List<String> contacts = getAllField('Contact', 'Contact.');
        List<String> bodyshop = getAllField('Account', 'NOB_BodyShop__r.');
        List<String> dispo = getAllField('NOB_Planning__c', 'NOB_TECH_DispoId__r.');
        List<String> workorders = getAllField('WorkOrder', 'NOB_TECH_DispoId__r.NOB_WorkOrder__r.');
        
        String query = 'SELECT ';
        for(String field : cases){
            query = query + field + ', ';
        }
        
        for(String field : contacts){
            query = query + field + ', ';
        }
        
        for(String field : bodyshop){
            query = query + field + ', ';
        }
        
        for(String field : dispo){
            query = query + field + ', ';
        }
        
        for(String field : workorders){
            query = query + field + ', ';
        }
        
        query = query.removeEnd(', ');
        
        query = query + ' FROM Case LIMIT 1';
        
        System.debug('query:' + query);
        List<Case> cc = Database.query(query);
        return JSON.serialize(cc);
        //System.debug(cc);
        //return cc;
    }
    
    
    
    public static List<String> getAllField(String SobjectApiName, String prefix)
    {
        List<String> result = new List<String>();
        String query ='';
        //String SobjectApiName = 'Case';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        
        for(String fieldName : fieldMap.keyset() )
        {
            result.add(prefix + fieldName);
        }
        
       return result;
        
    }
    

}