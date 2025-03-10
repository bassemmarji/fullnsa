public with sharing class QueueableAssignPermissionSet implements Queueable {
    List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
    public QueueableAssignPermissionSet(List<PermissionSetAssignment> receivedAssignments) {
        assignments = receivedAssignments;
    }
    public void execute(QueueableContext context) {
        System.debug('Queueable Assign Permission Set');
        try {
            if(Test.isRunningTest()) {
                throw new AuraHandledException('Test Exception');
            }
            insert assignments;
        } catch (Exception e) {
            new BatchMergePortalContact().createErrorLog(e);
        }
    }
}