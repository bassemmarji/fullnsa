trigger PatientTrigger on IntPS__Patient__c(before insert,before update,after insert,after update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            PatientTriggerHandler.createUserHelper(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isInsert) {
            PatientTriggerHandler.updateContactAccountLookup(Trigger.New);
        }
    }
    
}