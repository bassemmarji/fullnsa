public with sharing class PortalUserService {
	@AuraEnabled(cacheable=true)
    public static User findUserByContactId(Id contactId) {
        List<User> users = [
            SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1
        ];
        return users.isEmpty() ? null : users[0];
    }
}