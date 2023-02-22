trigger SMSLogTrigger on NOB_SMSLog__c (after insert, after update) {

    //HMO -- 07-07-2021 -- RSIW 10319
    NOB_SmsLogTriggerHandler handler = new NOB_SmsLogTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (ASPISTools.cantrigger('SMSLogTrigger')){

        //if (!System.isFuture() && !System.isBatch()){

            if(Trigger.isInsert && Trigger.isAfter ){
                system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
                handler.onAfterInsert(Trigger.new);
            }    
            if(Trigger.isUpdate && Trigger.isAfter ){
                system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isAfter');
                handler.onAfterUpdate(Trigger.new);
            }  
       // }
    }

}