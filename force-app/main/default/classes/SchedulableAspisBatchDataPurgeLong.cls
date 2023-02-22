global class SchedulableAspisBatchDataPurgeLong  implements schedulable {
/*
----------------------------------------------------------------------
-- - Name          : SchedulableAspisBatchDataPurgeLong
-- - Author        : WCH
-- - Description   : Class to schedule AspisBatchDataPurgeLong
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-DEC-2018  WCH   1.0      Initial version
----------------------------------------------------------------------*/  
    global void execute(SchedulableContext sc) {
            Database.executeBatch(new AspisBatchDataPurgeLong(), 200);
    }
}