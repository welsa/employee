@isTest
public class mcr_UnitTestData {
   
    public static SObject generateRecord(SObject obj, Boolean doInsert) {
        Map<Schema.SObjectField, Object> defaultValues = mcr_UnitTestDataDefaults.getDefaultValues(obj.getSObjectType());
        if(defaultValues != null) {
            populateFieldValues(obj, defaultValues);
        }
        
        if(doInsert){
            insert obj;
        }

        return obj;
    }

    private static SObject populateFieldValues(SObject obj, Map<Schema.SObjectField, Object> defaultValues) {
        for(Schema.SObjectField field : defaultValues.keySet()) {
            obj.put(field, defaultValues.get(field));
        }
        return obj;
    }
}