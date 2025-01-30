@isTest
public with sharing class PatientTriggerHandlerTest {

    @IsTest
    static void testCreateNSAUser(){
        Account acc=new Account();
        acc.Name='test';
        insert acc;


        IntPS__Patient__c c = new IntPS__Patient__c();
        c.Name = 'TriggerTest';
        c.IntPS__First_Name__c = 'TriggerTest';
        c.IntPS__Last_Name__c = 'TriggerTest';
        c.IntPS__Employer__c=acc.id;
        c.IntPS__Email__c = 'testt@test.com';
        c.IntPS__Not_Unique_Member_Id__c = '1122334466';
        insert c;

        Test.startTest();
        c.Create_User__c = true;
        update c;
        Test.stopTest();
        
    }

    @isTest
    static void testcreateHouseholdAccountTest(){
        String dependentTypeId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        String planMemberTypeId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();


        Account acc=new Account();
        acc.Name='test';
        insert acc;


        IntPS__Patient__c c = new IntPS__Patient__c();
        c.Name = 'TriggerTest';
        c.IntPS__First_Name__c = 'TriggerTest';
        c.IntPS__Last_Name__c = 'TriggerTest';
        c.IntPS__Employer__c=acc.id;
        insert c;



        
       Test.startTest();

        Contact planMemberContact = new Contact();
        planMemberContact.FirstName = 'PlanMemberFirst';
        planMemberContact.LastName = 'PlanMemberLast';
        planMemberContact.Email = 'asd@asd.com';
        insert planMemberContact;
        IntPS__Patient__c c2 = new IntPS__Patient__c();
        // c2.Name = 'PlanMemberTest';
        c2.IntPS__First_Name__c = 'PlanMemberFirst';
        c2.IntPS__Last_Name__c = 'PlanMemberLast';
        c2.RecordTypeId=planMemberTypeId;
        c2.IntPS__Email__c='asd@asd.com';
        c2.IntPS__Employer__c=acc.id;
        c2.Portal_User__c = planMemberContact.Id;
        c2.Create_Account_Plan_Member__c=false;
        insert c2;
        IntPS__Patient__c patient = new IntPS__Patient__c();
        // patient.Name = 'DependentTest';
        patient.IntPS__First_Name__c = 'DependentFirst';
        patient.IntPS__Last_Name__c = 'DependentLast';
        patient.IntPS__Plan_Member__c = c2.Id;
        patient.IntPS__Email__c='mkilic+deptest@ankamee.com';
        patient.RecordTypeId=dependentTypeId;
        patient.IntPS__Employer__c=acc.id;
        insert patient;

        c2.IntPS__Not_Unique_Member_Id__c = '1122334466';
        c2.Create_Account_Plan_Member__c=true;
        update c2;

        patient.Account__c = acc.Id;
        patient.IntPS__Not_Unique_Member_Id__c = '1122334455';
        patient.Create_Portal_Contact_Dependent__c=true;
        update patient;
        Test.stopTest();
        IntPS__Patient__c planMember = [SELECT Id,Portal_User__r.FirstName, IntPS__First_Name__c FROM IntPS__Patient__c WHERE RecordTypeId =:planMemberTypeId];
        IntPS__Patient__c dep = [SELECT Id,Portal_User__r.FirstName,IntPS__First_Name__c FROM IntPS__Patient__c WHERE IntPS__Email__c = 'mkilic+deptest@ankamee.com'];
        System.debug(JSON.serializePretty(dep));
        System.assertEquals(planMember.Portal_User__r.FirstName, planMember.IntPS__First_Name__c);
        System.assertEquals(dep.Portal_User__r.FirstName, dep.IntPS__First_Name__c);

        
        Account patient2acc = new Account();
        patient2acc.Name = 'PlanMemberFirst2';
        patient2acc.Email__c = 'asd2@asd.com';
        insert patient2acc;
        Contact planMemberContact2 = new Contact();
        planMemberContact2.FirstName = 'PlanMemberFirst2';
        planMemberContact2.LastName = 'PlanMemberLast2';
        planMemberContact2.Email = 'asd2@asd.com';
        insert planMemberContact2;
        IntPS__Patient__c patient2 = new IntPS__Patient__c();
        // patient.Name = 'DependentTest';
        patient2.IntPS__First_Name__c = 'PlanMemberFirst2';
        patient2.IntPS__Last_Name__c = 'PlanMemberLast2';
        patient2.IntPS__Plan_Member__c = c2.Id;
        patient2.IntPS__Email__c='asd2@asd.com';
        patient2.RecordTypeId=planMemberTypeId;
        patient2.IntPS__Employer__c=acc.id;
        patient2.IntPS__Not_Unique_Member_Id__c = '1122334477';
        insert patient2;
        patient2.Create_Account_Plan_Member__c=true;
        update patient2;

    }
    @IsTest
    static void testMatchExistingContact(){
        


        String dependentTypeId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        String planMemberTypeId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();
        Account acc=new Account();
        acc.Name='test';
        acc.Email__c='test@asd.com';
        insert acc;
        Contact c = new Contact();
        c.FirstName = 'PlanMemberFirst';
        c.LastName = 'PlanMemberLast';
        c.Member_ID__c = '1122334455';
        c.Birthdate = Date.valueOf('1990-01-01');
        insert c;
        IntPS__Patient__c c2 = new IntPS__Patient__c();
        // c2.Name = 'PlanMemberTest';
        c2.IntPS__First_Name__c = 'PlanMemberFirst';
        c2.IntPS__Last_Name__c = 'PlanMemberLast';
        c2.RecordTypeId=planMemberTypeId;
        c2.IntPS__Email__c='test@asd.com';
        c2.IntPS__Not_Unique_Member_Id__c = '1122334455';
        c2.IntPS__Date_Of_Birth__c = Date.valueOf('1990-01-01');
        c2.IntPS__Employer__c=acc.id;
        insert c2;

       

        IntPS__Patient__c p = new IntPS__Patient__c();
        // c.Name = 'TriggerTest';
        p.IntPS__First_Name__c = 'TriggerTest';
        p.IntPS__Last_Name__c = 'TriggerTest';
        p.IntPS__Email__c='tewqest@asd.com';
        p.IntPS__Plan_Member__c=c2.id;
        p.IntPS__Not_Unique_Member_Id__c = '1122334456';
        p.RecordTypeId = dependentTypeId;
        p.IntPS__Date_Of_Birth__c = Date.valueOf('1991-01-01');
        p.IntPS__Employer__c=acc.id;

        insert p;
        
        Contact con = new Contact();
        con.FirstName = 'TriggerTest';
        con.LastName = 'TriggerTest';
        con.Member_ID__c = '1122334456';
        con.Birthdate = Date.valueOf('1991-01-01');
        insert con;
        Test.startTest();
        c2.Create_Account_Plan_Member__c=true;
        update c2;
        Test.stopTest();
        p.Create_Portal_Contact_Dependent__c = true;
        update p;
        
    }

    @isTest
    static void createHouseholdAccountTest(){
        String planMemberTypeId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();

        Account acc= new Account();
        acc.Name='test';
        acc.Email__c='asddd@asd.com';
        insert acc;

        IntPS__Patient__c patient = new IntPS__Patient__c();
        patient.Name = 'PlanMemberTest';
        patient.IntPS__First_Name__c = 'PMTest';
        patient.IntPS__Last_Name__c = 'PLast';
        // patient.Create_Member_Id_By_System__c = true;
        patient.IntPS__Email__c = 'asdss@asd.com';
        patient.RecordTypeId = planMemberTypeId;
        patient.IntPS__Not_Unique_Member_Id__c = '112233445577';
        insert patient;


        IntPS__Patient__c patient1 = new IntPS__Patient__c();
        patient1.Name = 'PlanMemberTest';
        patient1.IntPS__First_Name__c = 'PMTest2';
        patient1.IntPS__Last_Name__c = 'PLast';
        // patient1.Create_Member_Id_By_System__c = true;
        patient1.IntPS__Email__c = 'asddd@asd.com';
        patient1.RecordTypeId = planMemberTypeId;
        patient1.IntPS__Not_Unique_Member_Id__c = '112233445566';
        insert patient1;

        Test.startTest();
        List<IntPS__Patient__c> patients = [SELECT Id,Name,IntPS__Street__c,IntPS__Street1__c,IntPS__City__c,IntPS__State__c,IntPS__Zip_Code__c,IntPS__Country__c,IntPS__Phone_Number__c, IntPS__Email__c FROM IntPS__Patient__c where id =:patient.id];

        List<IntPS__Patient__c> patients2 = [SELECT Id,Name,IntPS__Street__c,IntPS__Street1__c,IntPS__City__c,IntPS__State__c,IntPS__Zip_Code__c,IntPS__Country__c,IntPS__Phone_Number__c, IntPS__Email__c FROM IntPS__Patient__c where id =:patient1.id];

        for (IntPS__Patient__c patient12 : patients) {
            patient12.Create_Account_Plan_Member__c=true;
        }

        for (IntPS__Patient__c patient12 : patients2) {
            patient12.Create_Account_Plan_Member__c=true;
        }

        update patients2;
        update patients;
        Test.stopTest();
        //PatientTriggerHandler.createHouseHoldAccount(patients);
    }

    @IsTest
    static void createCSVError(){

        Account acc=new Account();
        acc.Name='test';
        insert acc;


        IntPS__Patient__c c = new IntPS__Patient__c();
        c.Name = 'TriggerTest';
        c.IntPS__First_Name__c = 'TriggerTest';
        c.IntPS__Last_Name__c = 'TriggerTest';
        c.IntPS__Employer__c=acc.id;
        c.IntPS__Email__c = 'testt@test.com';
        c.IntPS__Not_Unique_Member_Id__c = '1122334466';
        insert c;
        IntPS__Patient__c c2 = new IntPS__Patient__c();
        c2.Name = 'TriggerTest';
        c2.IntPS__First_Name__c = 'TriggerTest';
        c2.IntPS__Last_Name__c = 'TriggerTest';
        c2.IntPS__Employer__c=acc.id;
        c2.IntPS__Email__c = 'testt@test.com';
        c2.IntPS__Not_Unique_Member_Id__c = '1122334465';
        insert c2;
        Test.startTest();
        c.Create_User__c = true;
        c2.Create_User__c = true;
        update c;
        update c2;
        Test.stopTest();
        
    }


}