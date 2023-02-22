trigger WorkOrderTrigger on WorkOrder (after insert , after update) {

   NOB_WorkOrderTriggerHandler WOhandler = new  NOB_WorkOrderTriggerHandler();

   if(NOBTools.isPrefikarUser()){
    
   if(Trigger.isInsert && Trigger.isAfter ){
    system.debug('~~~~~~~~~~ INSERT Trigger.isInsert && Trigger.isAfter');
    WOhandler.onAfterInsert(Trigger.new); 
    }

    if(Trigger.isUpdate && Trigger.isAfter){
    system.debug('~~~~~~~~~~ UPDATE Trigger.isInsert && Trigger.isAfter');
        
       WOhandler.onAfterUpdate(Trigger.new, Trigger.old);
    }

}
    
}