public class QueueableCreatePortalAccountContact implements Queueable {
    List<IntPS__Patient__c> patients = new List<IntPS__Patient__c>();
    public QueueableCreatePortalAccountContact(List<IntPS__Patient__c> patients){
        this.patients = patients;
    }
    public void execute(QueueableContext context) {
        System.debug('Queueable Patients');
        System.debug(JSON.SerializePretty(patients));
        for(IntPS__Patient__c patient: patients){
            patient.Create_Account_Plan_Member__c = true;
        }
        update patients;
    }
}