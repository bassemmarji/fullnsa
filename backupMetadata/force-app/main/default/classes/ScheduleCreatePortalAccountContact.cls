public with sharing class ScheduleCreatePortalAccountContact implements Schedulable{
    

    public void execute(SchedulableContext sc){
        runBatchCreateProcess();
    }

    public void runBatchCreateProcess(){
        Id jobIdVariable = Database.executeBatch(new BatchCreatePortalAccountContact(), 100);
    }
}