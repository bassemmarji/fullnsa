public with sharing class UpdateUserController {
    
    @AuraEnabled
    public static List<User> getUsers(String Id){
        return [SELECT Id,Email FROM User WHERE ContactId=:Id];
    }
    
    @AuraEnabled
    public static string updateEmailAddress(String email,String userId){
        
        List<User> users = [SELECT Id, ContactId FROM User WHERE Id=:userId];
        // List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE Id=:users[0].ContactId];
        if(users.isEmpty()) {
            throw new AuraHandledException('Could not find any user with given id!');
        }
        List<IntPS__Patient__c> patients = [SELECT Id,IntPS__Email__c,Account__c,RecordType.Name FROM IntPS__Patient__c WHERE Portal_User__c=:users[0].ContactId];
        Contact contact = new Contact();
        contact.Id = users[0].ContactId;
        contact.Email = email;
        update contact;

        if(!(patients.size() == 1 && patients[0].RecordType.Name == 'Dependent')) {
            //update plan member type patient and it's account
            Account acc = new Account();
            acc.Id = patients[0].Account__c;
            acc.Email__c = email;
            update acc;
            IntPS__Patient__c pm;
            for (IntPS__Patient__c patient : patients) {
                if(String.isNotBlank(patient.IntPS__Email__c) && patient.RecordType.Name == 'Plan Member') {
                    patient.IntPS__Email__c = email;
                    pm = patient;
                }
            }
            if(pm != null) {
                update pm;
                return 'Success';
            }
            return 'No Update';
        }else {
            //update dependent type patient
            patients[0].IntPS__Email__c = email;
            update patients;
            return 'Success';
        }



    }
}