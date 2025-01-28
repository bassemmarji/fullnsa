@isTest
public class ScheduleMatchPortalMemberTest {
    
    @IsTest
    static void startMatch() {
        
        
	    Long CURRENT_TIME = Datetime.now().getTime();

        Account portalAccount = new Account();
        portalAccount.Name = 'Self Register';
        insert portalAccount;
        Account patientAccount = new Account();
        patientAccount.Name = 'Self Reg';
        insert patientAccount;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS NSA Portal' LIMIT 1];



        List<IntPS__Patient__c> planMembers = new List<IntPS__Patient__c>();
        List<IntPS__Patient__c> dependents = new List<IntPS__Patient__c>();
        List<Contact> userContacts = new List<Contact>();
        List<Contact> patientContacts = new List<Contact>();
        List<User> users = new List<User>();
        List<String> uniqueStrings = new List<String> {
            'gerry_kovacek@hotmail.com',
            'luna.moen7@gmail.com',
            'tiffany.frami@gmail.com',
            'therese49@hotmail.com',
            'albin73@yahoo.com',
            'veronica41@gmail.com',
            'dolly.purdy@hotmail.com',
            'florence40@yahoo.com',
            'abdul_green41@hotmail.com',
            'jovan.kuhic65@gmail.com'
        };
        List<String> uniqueAlias = new List<String>{
            'bawling',
            'conformer',
            'firebrat',
            'kirsches',
            'selfaccusation',
            'battlers',
            'nebbishes',
            'hoopoes',
            'ouananiche',
            'oilstones'
        };
        for (Integer count = 0; count < 5; count++) {
            IntPS__Patient__c patient = new IntPS__Patient__c();
            patient.IntPS__First_Name__c = String.valueOf(CURRENT_TIME)+'MASSIMILIANO'+ String.valueOf(count);
            patient.IntPS__Last_Name__c = String.valueOf(CURRENT_TIME)+'BIGANZOLI';
            patient.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME)+'290000248';
            patient.IntPS__Email__c = uniqueStrings[count];
            patient.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
            planMembers.add(patient);
            IntPS__Patient__c dependent = new IntPS__Patient__c();
            dependent.IntPS__First_Name__c = String.valueOf(CURRENT_TIME)+'Dependent '+ String.valueOf(count);
            dependent.IntPS__Last_Name__c = String.valueOf(CURRENT_TIME)+'BIGANZOLI';
            dependent.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME)+'290000248';
            dependent.IntPS__Plan_Member__r = patient;
            dependents.add(dependent);

            Contact patientContact = new Contact();
            patientContact.FirstName = patient.IntPS__First_Name__c;
            patientContact.LastName = patient.IntPS__Last_Name__c;
            patientContact.Email = uniqueStrings[count];
            patientContact.FirstName = patient.IntPS__First_Name__c;
            patientContact.AccountId = patientAccount.Id;
            patientContact.Member_ID__c = patient.IntPS__Not_Unique_Member_Id__c;
            patientContact.Birthdate = patient.IntPS__Date_Of_Birth__c;
            patientContacts.add(patientContact);
            // patient.Portal_User__r = patientContact;
            Contact userContact = new Contact();
            userContact.FirstName = patient.IntPS__First_Name__c;
            userContact.LastName = patient.IntPS__Last_Name__c;
            userContact.Email = uniqueStrings[count];
            userContact.FirstName = patient.IntPS__First_Name__c;
            userContact.AccountId = portalAccount.Id;
            userContact.Member_ID__c = patient.IntPS__Not_Unique_Member_Id__c;
            userContact.Birthdate = patient.IntPS__Date_Of_Birth__c;
            userContacts.add(userContact);

            User user1 = new User();
            user1.Username = uniqueStrings[count];
            user1.FirstName = patient.IntPS__First_Name__c;
            user1.LastName = patient.IntPS__Last_Name__c;
            user1.Alias = generateAlias(CURRENT_TIME);
            user1.CommunityNickName = uniqueAlias[count];
            user1.Email = uniqueStrings[count];
            user1.ProfileId = profileId.Id;
            user1.EmailEncodingKey = 'UTF-8';
            user1.CommunityNickname = uniqueStrings[count];
            user1.TimeZoneSidKey = 'America/Los_Angeles';
            user1.LocaleSidKey = 'en_US';
            user1.LanguageLocaleKey = 'en_US';
            user1.Member_ID__c = patient.IntPS__Not_Unique_Member_Id__c;
            user1.Date_Of_Birth__c = patient.IntPS__Date_Of_Birth__c;
            // user1.Contact = userContact;
            users.add(user1);
            
        }
        Database.insert(planMembers);
        Database.insert(dependents);
        Database.insert(userContacts);
        Database.insert(patientContacts);
        for (Integer i = 0; i < userContacts.size(); i++) {
            users[i].ContactId = userContacts[i].Id;
            users[i].Confirmed_User_Info__c = true;
        }

        Database.insert(users);
        Contact testContact = new Contact();
        testContact.FirstName = 'First Test';
        testContact.LastName = 'Last Test';
        testContact.Email = 'test@test.com';
        testContact.AccountId = portalAccount.Id;
        insert testContact;
        User testUser = new User();
        testUser.Username = 'test@test.com';
        testUser.FirstName = 'First Test';
        testUser.LastName = 'Last Test';
        testUser.Alias = generateAlias(CURRENT_TIME);
        testUser.CommunityNickName = 'testerr';
        testUser.Email = 'test@test.com';
        testUser.ProfileId = profileId.Id;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.CommunityNickname = 'tester';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Member_ID__c = '999999999999';
        testUser.ContactId = testContact.Id;
        testUser.Confirmed_User_Info__c = true;
        testUser.Date_Of_Birth__c = System.today();
        insert testUser;
        // for (IntPS__Patient__c p : planMembers) {
        //     p.Create_Account_Plan_Member__c = true;
        // }
        for (Integer i = 0; i < planMembers.size(); i++) {
            planMembers[i].Portal_User__c = patientContacts[i].Id;
            
        }
        update planMembers;




        Test.startTest();
        
        new ScheduleMatchPortalMember().matchPatients();
        new BatchMergePortalContact().sendEmail('', new List<Contact>());
        new BatchMergePortalContact().sendEmail('Test', new List<Contact>());
        Test.stopTest();

        
    }

    
	static String generateAlias(Long currentTime) {
		String timeString = String.valueOf(currentTime);
		return timeString.substring(timeString.length() - 8);
	}
}