public with sharing class disclaimerController {
    @AuraEnabled
    public static Boolean aknowledgeUser(String userId) {
        User user=[Select Id,T_C_Acceptance__c,T_C_Acceptance_Date__c from User where Id=:userId];
        user.T_C_Acceptance__c=true;
        user.T_C_Acceptance_Date__c=date.today();
        update user;
        return true;
    }
}