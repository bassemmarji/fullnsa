@IsTest
public class BassemTestAs {
    public static User createUser(String roleId, String profileId, String firstName, String lastName) {
           User tmpUser = prepareUser(roleId, profileId, firstName, lastName);
           return tmpUser;
    }
    
    private static User prepareUser(String roleId, String profileId, String firstName, String lastName){
            String orgId      = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf( math.rint(math.random() * 1000000));
            String  uniqueName = orgId + dateString + randomInt;
            User tmpUser = new User(
                 FirstName = firstName
                ,LastName  = lastName
                ,email     = uniqueName+'@sfdc'+orgId+'.org'
                ,UserName  = uniqueName+'@sfdc'+orgId+'.org'
                ,EmailEncodingKey = 'UTF-8'
                ,Alias=uniqueName.substring(18,23)
                ,TimeZoneSidKey = 'Asia/Beirut'//'America/Los_Angeles'
                ,LanguageLocaleKey='en_US'
                ,LocaleSidKey='ar_LB'
                ,ProfileId = profileId
            );
            If (String.isBlank(roleId) == false){
                tmpUser.UserRoleId = roleId;                                                                                
            }
            return tmpUser;                                                                                                                                                                                 
    }
    
    public static Account createAccount(String Name){
           Account portalAccount = new Account(name = Name);
           return portalAccount;
    }
    
    public static Contact createContact(String firstName, String lastName,String email, String accountId){
           Contact portalContact = new Contact (
                   FirstName = firstName
                 , LastName  = lastName
                 , Email     = email
                 , AccountId = accountId
           );
           return portalContact;
    }
    
    public static User createCommunityUser(String contactId, String profileId, String firstName, String lastName){
           User tmpUser = prepareUser('',profileId, firstName, lastName);
           tmpUser.ContactId = ContactId;
           return tmpUser;
    }
    
    @isTest
    public static void createCommunityUser(){
        test.startTest();
        Id profileId = [SELECT Id FROM Profile WHERE Name='IPS NSA Portal'].Id;
        Account acc = createAccount('Test Account');
        insert acc;
        System.debug('Account='+acc.Id);
        Contact con = createContact('test','Contact','test@gmail.com',acc.Id);
        insert con;
        System.debug('Contact='+con.Id);
        User u = createCommunityUser(con.Id,profileId,'Bassem','Marji');
        Insert u;
        System.debug('User='+u.Id);
        System.runAs(u) {
            System.debug('Before');
            
            if (Schema.SobjectType.IntPS__Eligibility__c.isaccessible()){
                System.debug('User has permission to query Eligibility Records');
            }
                
            List <Contact> contactList = [Select Id, FirstName from Contact];
            System.debug('contactList=' + contactList);

            List <IntPS_NSA__Release__c> releasedList = [Select Id, Name from IntPS_NSA__Release__c];
            System.debug('releasedList=' + releasedList);
           
			List < IntPS__Eligibility__c > properEligibilityList = [SELECT Id
                                                                    , IntPS__Health_Plan__c
                                                                    //,IntPS__Health_Plan__r.Name
                                                                    , IntPS__Payer_Name__c
                                                                    //, IntPS__Payer_Name__r.Name
                                                                    , IntPS__Begin_Date__c
                                                                    , IntPS__Term_Date__c
                                                                    //,IntPS__Patient__r.IntPS__Employer__c
                                                                    ,IntPS__Patient__c
                                                                    //,IntPS__Patient__r.IntPS__Employer__r.Name 
                                                                    FROM IntPS__Eligibility__c 
                                                                   //WHERE IntPS__Patient__c in ('a0QQy00000EKUEUMA5')
                                                                   // and (IntPS__Health_Plan__r.IntPS_NSA__Plan_Type__c = 'Medical' or IntPS__Health_Plan__r.Plan_Type__c = 'Medical') 
                                                                    ORDER BY IntPS__Begin_Date__c DESC];
           System.debug('properEligibilityList=' + properEligibilityList);
           System.debug('After');
       }
       test.stopTest();
    }
   /*
   public static testMethod void test1() {
       Profile p = [SELECT Id FROM Profile WHERE Name='IPS NSA Portal'];
       System.debug('Profile='+p); 
       Contact c = new Contact (FirstName = 'Bassem1'
                               ,LastName = 'Marji1'
                               ,Email='bmarji1@integratedpayorsolutions.com');
       insert c;
       System.debug('Contact='+c.Id); 
       
       UserRole ur=[SELECT Id FROM UserRole WHERE Name='CEO'];
       
	   User u = new User(Alias = 'bmarj'
                       , Email='bmarji1@integratedpayorsolutions.com'
                       , EmailEncodingKey='UTF-8'
                       , LastName='Marji'
                       , LanguageLocaleKey='en_US'
                       , LocaleSidKey='ar_LB'
                       , ProfileId = p.Id
                       , TimeZoneSidKey= 'Asia/Beirut'//'America/Los_Angeles'
                       , UserName='bmarji1@integratedpayorsolutions.com'
                       , ContactId=c.Id
                       , UserRoleId = ur.Id);
	   //insert u;
       System.debug('User='+u.Id); 
       System.runAs(u) {
			List < IntPS__Eligibility__c > properEligibilityList = [SELECT Id
                                                                    , IntPS__Health_Plan__c,IntPS__Health_Plan__r.Name
                                                                    , IntPS__Payer_Name__c
                                                                    , IntPS__Payer_Name__r.Name
                                                                    , IntPS__Begin_Date__c
                                                                    , IntPS__Term_Date__c
                                                                    ,IntPS__Patient__r.IntPS__Employer__c
                                                                    ,IntPS__Patient__c
                                                                    ,IntPS__Patient__r.IntPS__Employer__r.Name 
                                                                    FROM IntPS__Eligibility__c 
                                                                   WHERE IntPS__Patient__c in ('a0QQy00000EKUEUMA5')
                                                                    and (IntPS__Health_Plan__r.IntPS_NSA__Plan_Type__c = 'Medical' or IntPS__Health_Plan__r.Plan_Type__c = 'Medical') 
                                                                    ORDER BY IntPS__Begin_Date__c DESC];
           System.debug('properEligibilityList=' + properEligibilityList);
                                                                      

       }
   }
  */
}