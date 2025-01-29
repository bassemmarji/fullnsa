@isTest
public class UpdateUserControllerTest {
    @TestSetup
    static void setup() {
        Id planMemberId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();
        Id dependentId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        Long CURRENT_TIME = Datetime.now().getTime();
        IntPS__Patient__c planMember = new IntPS__Patient__c();
        planMember.IntPS__First_Name__c = 'PM';
        planMember.IntPS__Last_Name__c = 'Last Name';
        planMember.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(1);
        planMember.IntPS__Email__c = 'testclass@test.com';
        planMember.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
        planMember.RecordTypeId = planMemberId;
        planMember.IntPS__ExternalID__c = String.valueOf(1);

        IntPS__Patient__c dependent = new IntPS__Patient__c();
        IntPS__Patient__c pm = new IntPS__Patient__c ();
        pm.IntPS__ExternalID__c = String.valueOf(1);
        dependent.IntPS__First_Name__c = 'Dependent 1';
        dependent.IntPS__Last_Name__c = 'Last Name';
        dependent.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(2);
        dependent.IntPS__Plan_Member__r = pm;
        dependent.RecordTypeId = dependentId;
        Database.insert(planMember);
        Database.insert(dependent);
        Contact c = new Contact();
        Account acc = new Account();

        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'];
        System.runAs(admin) {
            acc.Name = planMember.IntPS__First_Name__c+' '+planMember.IntPS__Last_Name__c;
            acc.Email__c = planMember.IntPS__Email__c;
            acc.OwnerId = admin.Id;
            insert acc;
            c.FirstName = planMember.IntPS__First_Name__c;
            c.LastName = planMember.IntPS__Last_Name__c;
            c.Email = planMember.IntPS__Email__c;
            c.AccountId = acc.Id;
            insert c;
        }


        planMember.Account__c = acc.Id;
        planMember.Portal_User__c = c.Id;
        dependent.Account__c = acc.Id;
        dependent.Portal_User__c = c.Id;
        update planMember;
        update dependent;
        List<Contact> contacts = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Email = 'testclass@test.com'];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS NSA Portal'
            LIMIT 1
        ];
        Account acc1 = new Account();
        acc1.Name = 'Self Register';
        insert acc1;
        List<User> users = new List<User>();
        String locale = UserInfo.getLocale();
        String timeZoneId = UserInfo.getTimezone().getID();
        System.debug(JSON.serializePretty(contacts));
            
        User u = new User();
        u.ProfileId = profileId.Id;
        u.Email = contacts[0].Email;
        u.CommunityNickname = u.Email;
        if(String.isNotBlank(u.Email)) {
            if(u.Email.length() >= 40) {
                String splittedEmail = u.Email.substring(0, 40);
                u.CommunityNickname = splittedEmail;
            }
            String alias = u.Email.split('@')[0];
            if(alias.length()>8) {
                alias = alias.substring(0,8);
            }
            u.Alias = alias;
        }
        u.Username = contacts[0].Email;
        u.FirstName = contacts[0].FirstName;
        u.LastName = contacts[0].LastName;
        u.ContactId = contacts[0].Id;
        u.languagelocalekey = locale;
        u.localesidkey = locale;
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = timeZoneId;
        insert u;
        // Id uId = Site.createExternalUser(u, acc1.Id);
        System.debug('USER ID ==============');
        System.debug(u.Id);
        // System.debug(uId);
    }
    @IsTest
    static void startTest(){
        List<Contact> contacts = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Email = 'testclass@test.com'];

        Id userId = [SELECT Id FROM User WHERE ContactId=:contacts[0].Id].Id;
        UpdateUserController.getUsers(userId);
        UpdateUserController.updateEmailAddress('new@email.com', userId);
        
    }
}