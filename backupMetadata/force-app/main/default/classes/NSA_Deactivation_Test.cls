/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class NSA_Deactivation_Test {
    @isTest
    static void testTerminateEligibilities() {
        // Create test data
        IntPS__Health_Plan__c testHealthPlan = new IntPS__Health_Plan__c(
            IntPS__Out_Of_Pocket_Calculation_Type__c='Embedded',
            IntPS__Deductible_Calculation_Type__c='Embedded'

        );
        insert testHealthPlan;

        IntPS__Eligibility__c testEligibility = new IntPS__Eligibility__c(
            IntPS__Health_Plan__c = testHealthPlan.Id
            /* add necessary fields */
        );
        insert testEligibility;

        // Create request parameters
        NSA_DeactivateGroup.requestParameters request = new NSA_DeactivateGroup.requestParameters();
        request.accountId = testHealthPlan.IntPS__Employer__c;
        request.terminationDate = Date.today();

        // Call the method
        List<NSA_DeactivateGroup.resultParameters> result = NSA_DeactivateGroup.terminate_eligibilities(new List<NSA_DeactivateGroup.requestParameters>{request});

        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected one result parameter');

        NSA_DeactivateGroup.resultParameters resultParam = result[0];
        System.assertEquals(testHealthPlan.Id, resultParam.hpId, 'Health Plan ID should match');
        // Add more assertions based on your requirements
    }
    @isTest
    static void testDeactivateUsers() {
        // Create test data
        Account a = new Account(Name='Test Account Name');
    insert a;

        Contact testContact = new Contact(LastName='test', AccountId = a.id);
        insert testContact;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'IPS NSA Portal' LIMIT 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        System.runAs(adminUser){
        User testUser = new User(
            ContactId = testContact.Id,
            IsActive = true,
            Username='aazzi@tttt.com',
            LastName='azzi',
            Email='aazzi@integratedpayorsolutions.com',
            Alias='aaz',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=testProfile.Id
                       /* add necessary fields */
        );
        insert testUser;
        
        // Create request parameters
        NSA_DeactivateUsers.requestParameters request = new NSA_DeactivateUsers.requestParameters();
        request.contactsList = new List<Id>{testContact.Id};

        // Call the method
        List<NSA_DeactivateUsers.resultParameters> result = NSA_DeactivateUsers.deactivate_users(new List<NSA_DeactivateUsers.requestParameters>{request});

        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected one result parameter');

        NSA_DeactivateUsers.resultParameters resultParam = result[0];
        System.assertEquals(1, resultParam.countUpdUsr, 'Expected one user to be deactivated');
        
        // Verify that the user is actually deactivated
       
        }
        // Add more assertions based on your requirements
    }
    @isTest
    static void testTerminateEligibilities2() {
        // Create test data
        IntPS__Health_Plan__c testHealthPlan = new IntPS__Health_Plan__c(
            IntPS__Out_Of_Pocket_Calculation_Type__c='Embedded',
            IntPS__Deductible_Calculation_Type__c='Embedded'

        );
        insert testHealthPlan;

        IntPS__Eligibility__c testEligibility = new IntPS__Eligibility__c(
            IntPS__Health_Plan__c = testHealthPlan.Id
            /* add necessary fields */
        );
        insert testEligibility;

        // Create request parameters
        NSA_DeactivatePlan.requestParameters request = new NSA_DeactivatePlan.requestParameters();
        request.hpList = new List<Id>{testHealthPlan.Id};
        request.terminationDate = Date.today();

        // Call the method
        List<NSA_DeactivatePlan.resultParameters> result = NSA_DeactivatePlan.terminate_eligibilities(new List<NSA_DeactivatePlan.requestParameters>{request});

        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected one result parameter');

        NSA_DeactivatePlan.resultParameters resultParam = result[0];
        System.assertEquals(1, resultParam.countUpdElg, 'Expected one eligibility to be terminated');
        
        // Verify that the eligibility is actually terminated
        IntPS__Eligibility__c updatedEligibility = [SELECT Id, IntPS__Term_Date__c FROM IntPS__Eligibility__c WHERE Id = :testEligibility.Id LIMIT 1];
        System.assertNotEquals(null, updatedEligibility.IntPS__Term_Date__c, 'Eligibility should have a termination date');

        // Add more assertions based on your requirements
    }
}