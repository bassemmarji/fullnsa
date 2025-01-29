public class BatchCreatePortalAccountContact implements Database.Batchable < SObject > , Database.Stateful{
    public BatchCreatePortalAccountContact() {

    }


    public List<IntPS__Patient__c> start(Database.BatchableContext BC){
        return Database.query('SELECT Id,Name FROM IntPS__Patient__c WHERE Portal_User__c=null AND '+
         'Account__c = null AND Create_Account_Plan_Member__c=false AND IntPS__Email__c!=null AND RecordType.Name = \'Plan Member\'');
    }

    public void execute(Database.BatchableContext BC, List<IntPS__Patient__c> patients){
        System.debug('----BATCH Patients----');
        System.debug(JSON.serializePretty(patients));
        ID jobID = System.enqueueJob(new QueueableCreatePortalAccountContact(patients));
    }

    public void finish(Database.BatchableContext BC){
        
    }


}