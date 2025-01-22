public with sharing class SelfRegisterIntroController {
    @AuraEnabled
    public static List<User> getUser(){
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id,FirstName,LastName,Date_Of_Birth__c,Member_ID__c,Confirmed_User_Info__c,Username,Email,Alias,TimeZoneSidKey,LocaleSidKey,EmailEncodingKey,ProfileId,LanguageLocaleKey,Contact.Patient_Match_Status__c,Profile.Name FROM User WHERE Id=:userId];
        System.debug(users);
        return users;
    }

    @AuraEnabled
    public static string updateUser(User user){
            user.Confirmed_User_Info__c = true;
            update user;
            return 'Success';
    }
}