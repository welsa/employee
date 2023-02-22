/** 
 * @Author: Telesio Consultant
 * @Date: 13/02/2022
 * @description: Used to schedule Queue b2g_DeleteLogs_QUE
 **/
public with sharing class b2g_ScheduleDeleteLogs implements Schedulable {
    private Integer lastNDays = 30;

    public void execute(SchedulableContext CTX) {
        system.debug('b2g_ScheduleDeleteLogs START');
        System.enqueueJob(new b2g_DeleteLogs_QUE());
        system.debug('b2g_ScheduleDeleteLogs END');
    }

    public b2g_ScheduleDeleteLogs(Integer lastNDays){
        system.debug('b2g_ScheduleDeleteLogs START with: ' + lastNDays);
        this.lastNDays = lastNDays;
    }

    public b2g_ScheduleDeleteLogs(){
        this(30);
    }
}