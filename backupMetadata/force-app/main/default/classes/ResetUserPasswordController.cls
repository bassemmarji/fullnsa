public with sharing class ResetUserPasswordController {
    
    @AuraEnabled
    public static void resetUserPassword(String recordId) {
        System.debug('CONTACT RECORD ID');
        System.debug(recordId);
        if(String.isBlank(recordId)) {
            throw new AuraHandledException('There is no Contact Id!');
        }
        List<User> users = [SELECT Id FROM User WHERE ContactId =:recordId AND IsActive=true];
        if(!users.isEmpty()) {
            if (test.isRunningTest()) {}
            else{
                            System.resetPassword(users[0].Id, true);

            }
        }else {
            throw new AuraHandledException('There is no user record for this Contact!');
        }
    }
}