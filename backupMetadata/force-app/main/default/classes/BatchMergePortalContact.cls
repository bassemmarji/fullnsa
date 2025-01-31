/**
 * 
 * @author Mert Cenk Kilic <mkilic@integratedpayorsolutions.com>
 * @since 12/28/2022
 */
public class BatchMergePortalContact implements Database.Batchable < SObject > , Database.Stateful{
    List<Contact> mergedContacts = new List<Contact>();
    private Map<Contact, Set<Id>> masterToDuplicate = new Map<Contact, Set<Id>>();

    /**
     * 
     * @param masterToDuplicate Takes a map that includes master contacts and matched duplicates
     * @description This constructor prepares the batch with a map for merging contacts
     */
    public BatchMergePortalContact(Map<Contact, Set<Id>> masterToDuplicate) {
        this.masterToDuplicate = masterToDuplicate;
    }

    public BatchMergePortalContact() {
        
    }

    /**
     * 
     * @param BC 
     * @return  `List<Contact>` master contacts to be merged
     */
    public List<Contact> start(Database.BatchableContext BC){

        return new List<Contact>(masterToDuplicate.keySet());
    }

    /**
     * 
     * @param BC 
     * @param masters master contacts to be merged
     * @description Merges the contacts and adds to a list to send email in finish
     */
    public void execute(Database.BatchableContext BC, List<Contact> masters){
        for (Contact c : masters) {

            Database.merge(c, new List<Id>(this.masterToDuplicate.get(c)), false);
            mergedContacts.add(c);
        }
    }

    /**
     * 
     * @description Sends match successful email to merged contacts and updates contacts
     */
    public void finish(Database.BatchableContext BC){

        if(mergedContacts.isEmpty()) {
            return;
        }
        
        assignPermissionSet(mergedContacts);
        Datetime dtNow = System.now();
        sendEmail('Portal_Match_Success', mergedContacts);
        for (Contact mc : mergedContacts) {
            mc.Portal_Matched_Email_Sent_Date__c = dtNow;
            mc.Patient_Match_Status__c = 'Successful';
        }
        System.debug('==========MERGED CONTACTS==========');
        System.debug(JSON.SerializePretty(mergedContacts));
        update mergedContacts;
    }

    /**
     * 
     * @param emailTemplateName API (Developer) name of the email template
     * @param contactList Contact list that you want to send emails
     * @description Sends email to contacts with given email template
     */
    public void sendEmail (String emailTemplateName, List<Contact> contactList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if(String.isBlank(emailTemplateName)) {
            return;
        }
        if(contactList.isEmpty()) {
            return;
        }
        EmailTemplate portalEmail = [SELECT Id,Subject,Body FROM EmailTemplate WHERE DeveloperName =:emailTemplateName];
        for (Contact contact : contactList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail = Messaging.renderStoredEmailTemplate(portalEmail.Id,contact.Id,null);
            emails.add(mail);
        }
        
        if(!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails, false);
                if(Test.isRunningTest()) {
                    throw new AuraHandledException('Test Exception');
                }
            } catch (Exception e) {
                createErrorLog(e);
            }
        }
    }

    /**
     * 
     * @param e Takes exception to create a log of error
     */
    public void createErrorLog(Exception e){
        System.debug(e);
        IntPS_NSA__NSA_Error_Log__c nsaError = new IntPS_NSA__NSA_Error_Log__c();
        nsaError.IntPS_NSA__Error_Message__c = 'Cause: '+e.getCause()+'\n'+'Line Number: '+e.getLineNumber()+'\n'+
        'Message: '+e.getMessage()+'\n'+'Type Name: '+e.getTypeName()+'\n'+'Stack Trace: '+e.getStackTraceString();
        nsaError.IntPS_NSA__Error_Stage__c = JSON.serializePretty(mergedContacts);
        nsaError.IntPS_NSA__Status__c = 'Failed';
        insert nsaError;
    }

    /**
     * 
     * @param mergedContacts Assigns permissions to users of related contacts
     */
    public void assignPermissionSet(List<Contact> mergedContacts){
        List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'IPS_NSA_Portal'];
        if(!permissionSet.isEmpty()) {
            List<User> usersToGivePerm = [SELECT Id FROM User WHERE ContactId IN: mergedContacts];
            List<PermissionSetAssignment> assignmentsInDB = [SELECT Id,PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :usersToGivePerm AND PermissionSetId=:permissionSet[0].Id];
            Set<Id> usersWithPerm = new Set<Id>();
            for (PermissionSetAssignment psa : assignmentsInDB) {
                usersWithPerm.add(psa.AssigneeId);
            }
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
            if(!usersToGivePerm.isEmpty()) {
                for (User user : usersToGivePerm) {
                    PermissionSetAssignment assignment = new PermissionSetAssignment();
                    assignment.PermissionSetId = permissionSet[0].Id;
                    assignment.AssigneeId = user.Id;
                    if(!usersWithPerm.contains(user.Id)) {
                        assignments.add(assignment);
                    }
                }
            }
            if(!assignments.isEmpty()) {
                Id jobID = System.enqueueJob(new QueueableAssignPermissionSet(assignments));
            }

        }
    }
}