trigger PRE_DarvaLogEventsTrigger on PRE_DarvaLog_Events__e (After Insert) {
PRE_DarvaLogEventsTriggerHandler handler = new PRE_DarvaLogEventsTriggerHandler();
    handler.handleAfterInsert(Trigger.new);

}