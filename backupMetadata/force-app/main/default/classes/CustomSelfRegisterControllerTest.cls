/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class CustomSelfRegisterControllerTest {
    @isTest
    public static void testAll() {
        Account acc = new Account();
        acc.Name = 'Self Reg';
        insert acc;
        Contact c = new Contact();
        c.LastName = 'Contact Test';
        insert c;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS NSA Portal' LIMIT 1];
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>();
        SObjectField firstName = User.FirstName.getDescribe().getSObjectField();
        SObjectField lastName = User.LastName.getDescribe().getSObjectField();
        SObjectField email = User.Email.getDescribe().getSObjectField();
        SObjectField contactId = User.ContactId.getDescribe().getSObjectField();
        registrationAttributes.put(firstName, 'Test First');
        registrationAttributes.put(lastName, 'Test Last');
        // registrationAttributes.put(email, 'mkilic@ankamee.com');

        Map<SObjectField, String> registrationAttributes2 = new Map<SObjectField, String>();
        registrationAttributes2.put(firstName, 'Test First');
        registrationAttributes2.put(lastName, 'Test Last');
        registrationAttributes2.put(contactId, c.Id);
        Test.startTest();
        CustomSelfRegisterController customSelfRegister = new CustomSelfRegisterController();
        customSelfRegister.createUser(acc.Id,profileId.Id,registrationAttributes,null);
        // UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id];
        // System.runAs(usr){
        //     customSelfRegister.createUser(acc.Id,profileId.Id,registrationAttributes2,null);
        // }
        Test.stopTest();
    }
}