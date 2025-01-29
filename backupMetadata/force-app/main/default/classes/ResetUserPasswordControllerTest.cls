/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class ResetUserPasswordControllerTest {
    @IsTest
    public static void openRessources() {
        Contact contact1;
       UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
system.debug('portalRole is ' + portalRole);

Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
User portalAccountOwner1 = new User(
UserRoleId = portalRole.Id,
ProfileId = profile1.Id,
Username = System.now().millisecond() + 'test2@test.com',
Alias = 'batman',
Email='bruce.wayne@wayneenterprises.com',
EmailEncodingKey='UTF-8',
Firstname='Bruce',
Lastname='Wayne',
LanguageLocaleKey='en_US',
LocaleSidKey='en_US',
TimeZoneSidKey='America/Chicago'
);
Database.insert(portalAccountOwner1);

//User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];

System.runAs ( portalAccountOwner1 ) {
//Create account
Account portalAccount1 = new Account(
Name = 'TestAccount',
OwnerId = portalAccountOwner1.Id
);
Database.insert(portalAccount1);

//Create contact
 contact1 = new Contact(
FirstName = 'Test',
Lastname = 'McTesty',
AccountId = portalAccount1.Id,
Email = System.now().millisecond() + 'test@test.com'
);
Database.insert(contact1);

//Create user
Profile portalProfile = [SELECT Id FROM Profile where name = 'IPS NSA Portal'];
User user1 = new User(
Username = System.now().millisecond() + 'test12345@test.com',
ContactId = contact1.Id,
ProfileId = portalProfile.Id,
Alias = 'test123',
Email = 'test12345@test.com',
EmailEncodingKey = 'UTF-8',
LastName = 'McTesty',
CommunityNickname = 'test12345',
TimeZoneSidKey = 'America/Los_Angeles',
LocaleSidKey = 'en_US',
LanguageLocaleKey = 'en_US'
);
Database.insert(user1);
}

ResetUserPasswordController.resetUserPassword(contact1.Id);
        try{
     ResetUserPasswordController.resetUserPassword('');
    }catch(Exception e){
      Assert.isNotNull(e);
    }  
             try{
     ResetUserPasswordController.resetUserPassword('aa');
    }catch(Exception e){
      Assert.isNotNull(e);
    } 

    }
}