trigger CustomProcessingLogTrigger on IntPS__Processing_Log__c(before update) {

    List < string > plIdList=new List < string > ();
    for (IntPS__Processing_Log__c newPl: (List < IntPS__Processing_Log__c > ) Trigger.new) {
        IntPS__Processing_Log__c oldPL = (IntPS__Processing_Log__c) Trigger.oldMap.get(newPl.Id);
        if ( newPl.Create_Patients_Contact__c == true &&
        newPl.Create_Patients_Contact__c != oldPL.Create_Patients_Contact__c) {
            Database.executeBatch(new BatchCreatePatientsContact(newPl.Id));
            Database.executeBatch(new BatchUpdateEligibility(), 1000);
        }
    }
   
    
}