/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 08-04-2021
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   08-04-2021   GBH   Initial Version
**/

public class NOB_BatchUpdateLastModifiedDate implements Database.Batchable<SObject>{
    public final String Query;
    public final List<String> FieldToUpdate;
    public final map <String, String> Values;
    
    public NOB_BatchUpdateLastModifiedDate(String q, List<String> f, map <String, String> v) {
        Query=q; FieldToUpdate=f; Values=v;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if (scope.size() > 0) {
            
            List<SObject> lstsObjectToUpdate = new List<SObject>();

            for (sObject o : scope) {
                String objectName = o.Id.getSObjectType().getDescribe().getName();

                //new sObject instance
                SObject record = Id.valueOf(o.Id).getSObjectType().newSObject();
                record.put('Id', o.Id);

                try {
                    System.debug('FieldToUpdate: ' + FieldToUpdate);
                    for (String f : FieldToUpdate) {
                        //Get datatype and value
                        String fieldName =  f;
                        
                        Schema.DisplayType fieldType = Schema.getGlobalDescribe()
                                                        .get(objectName)
                                                        .getDescribe()
                                                        .fields
                                                        .getMap()
                                                        .get(fieldName)
                                                        .getDescribe()
                                                        .getType(); 
                        system.debug('fieldType: ' + fieldType);

                        if(fieldType == Schema.DisplayType.BOOLEAN) {
                            Boolean fieldValue = Boolean.valueOf(Values.get(f));
                            record.put(f, fieldValue);

                        } else if(fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea || fieldType == Schema.DisplayType.Picklist) {
                            String fieldValue = Values.get(f);
                            record.put(f, fieldValue);

                        } else if(fieldType == Schema.DisplayType.Integer) {
                            Integer fieldValue = Integer.valueOf(Values.get(f));
                            record.put(f, fieldValue);

                        } else if(fieldType == Schema.DisplayType.Date) {
                            Date fieldValue = Date.parse(Values.get(f));
                            record.put(f, fieldValue);
                        }
                        else if(fieldType == Schema.DisplayType.DateTime) {
                            Datetime fieldValue = (Values.get(f) == 'NOW')? System.now(): Datetime.parse(Values.get(f));
                            record.put(f, fieldValue);
                        }
                        else if(fieldType == Schema.DisplayType.Double) {
                            Double fieldValue = Double.valueOf(Values.get(f));
                            record.put(f, fieldValue);

                        }
                    }
                    lstsObjectToUpdate.add(record);
                } catch (Exception e) {
                    Utils_ManageLogs.NOBCreateLogFromException('NOB_BatchUpdateLastModifiedDate', objectName, e, o.Id);
                }
            }

            //Update sObject
            if (lstsObjectToUpdate.size()>0) { update lstsObjectToUpdate;}
        }
    }

    public void finish(Database.BatchableContext BC){
        
    }

     
}